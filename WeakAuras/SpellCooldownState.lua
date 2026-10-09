if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Spell cooldown state under secret values, shared by the spell cooldown trigger,
-- its conditions and the cooldown desaturation:
-- * per spell secret detection (C_Secrets predicate when the client has it),
-- * charges read from never secret fields,
-- * GCD only cooldowns (event flag isOnGCD, or a readable empty timer),
-- * loss of control replacing the normal cooldown,
-- * wand hold: while Shoot runs, other spells report the Shoot timer, so the
--   last timer seen before the shot is kept and shown instead.

local type, pcall, wipe, GetTime = type, pcall, wipe, GetTime

local SHOOT_SPELL_ID = 5019
local WAND_HOLD_WINDOW = 3
local WAND_SHOT_MERGE_WINDOW = 0.05
-- Pre-shot timers are copied at most this often per spell.
local WAND_SNAPSHOT_INTERVAL = 0.5
local ACTIVE_REMAINING_THRESHOLD = 0.001

local SpellCooldownState = {
  SHOOT_SPELL_ID = SHOOT_SPELL_ID,
}
Private.SpellCooldownState = SpellCooldownState

local function ReadRemainingMethod(value)
  return value.GetRemainingDuration
end

-- Same answer as Private.IsDurationObject, without allocating a closure per call.
local function IsDuration(value)
  if type(value) ~= "userdata" then
    return false
  end
  local ok, method = pcall(ReadRemainingMethod, value)
  return ok and method ~= nil
end
SpellCooldownState.IsDuration = IsDuration

local function ReadableBoolean(value)
  if type(value) == "boolean" and not Private.IsSecret(value) then
    return value
  end
end

local function ReadableNumber(value)
  if type(value) == "number" and not Private.IsSecret(value) then
    return value
  end
end

local function CallForDuration(apiFunction, ...)
  if not apiFunction then
    return nil
  end
  local ok, duration = pcall(apiFunction, ...)
  if ok and IsDuration(duration) then
    return duration
  end
end

local function ReadableIsZero(duration)
  local ok, isZero = pcall(duration.IsZero, duration)
  if ok then
    return ReadableBoolean(isZero)
  end
end

local function ReadableRemaining(duration)
  local ok, remaining = pcall(duration.GetRemainingDuration, duration)
  return ok and ReadableNumber(remaining) or nil
end
SpellCooldownState.ReadableRemaining = ReadableRemaining

local shouldSpellCooldownBeSecret = C_Secrets and C_Secrets.ShouldSpellCooldownBeSecret

-- true / false from the client predicate, nil when the client cannot tell.
function SpellCooldownState.IsCooldownSecret(spellID)
  if not shouldSpellCooldownBeSecret then
    return nil
  end
  local ok, isSecret = pcall(shouldSpellCooldownBeSecret, spellID)
  if ok then
    return ReadableBoolean(isSecret)
  end
end

-- GCD flags: isOnGCD is only trustworthy while handling SPELL_UPDATE_COOLDOWN.
local gcdFlags, gcdFlagSince = {}, {}

function SpellCooldownState.UpdateGCDFlag(spellID)
  local info = C_Spell.GetSpellCooldown(spellID)
  local onGCD = info and ReadableBoolean(info.isOnGCD)
  if onGCD ~= true then
    gcdFlagSince[spellID] = nil
  elseif gcdFlags[spellID] ~= true then
    gcdFlagSince[spellID] = GetTime()
  end
  gcdFlags[spellID] = onGCD
end

function SpellCooldownState.GetGCDFlag(spellID)
  return gcdFlags[spellID], gcdFlagSince[spellID]
end

function SpellCooldownState.ForgetGCDFlag(spellID)
  gcdFlags[spellID], gcdFlagSince[spellID] = nil, nil
end

function SpellCooldownState.ClearGCDFlags()
  wipe(gcdFlags)
  wipe(gcdFlagSince)
end

-- Wand hold
local wandShotAt, wandLastShotUpdate = -math.huge, -math.huge
local wandUsed = false
local castAfterShot, lastCastAt, wandSnapshots, wandSnapshotAt = {}, {}, {}, {}

function SpellCooldownState.ClearWandHold()
  wipe(castAfterShot)
  wipe(wandSnapshots)
  wipe(wandSnapshotAt)
  wandShotAt, wandLastShotUpdate = -math.huge, -math.huge
end

local function NoteWandShot()
  local now = GetTime()
  if now - wandLastShotUpdate > WAND_SHOT_MERGE_WINDOW then
    wandShotAt = now
    wipe(castAfterShot)
  end
  wandLastShotUpdate = now
  wandUsed = true
end

function SpellCooldownState.NotePlayerCast(spellID)
  if type(spellID) ~= "number" or Private.IsSecret(spellID) then
    SpellCooldownState.ClearWandHold()
  elseif spellID == SHOOT_SPELL_ID then
    NoteWandShot()
  else
    lastCastAt[spellID] = GetTime()
    castAfterShot[spellID] = true
    wandSnapshotAt[spellID] = nil
  end
end

function SpellCooldownState.NoteCooldownEvent(spellID, baseSpellID)
  if ReadableNumber(spellID) ~= SHOOT_SPELL_ID and ReadableNumber(baseSpellID) ~= SHOOT_SPELL_ID then
    return
  end
  local info = C_Spell.GetSpellCooldown(SHOOT_SPELL_ID)
  if info and ReadableBoolean(info.isActive) then
    NoteWandShot()
  end
end

function SpellCooldownState.GetLastCast(spellID)
  return lastCastAt[spellID]
end

local function IsWandHeld(spellID)
  return spellID ~= SHOOT_SPELL_ID and GetTime() - wandShotAt < WAND_HOLD_WINDOW and not castAfterShot[spellID]
end
SpellCooldownState.IsWandHeld = IsWandHeld

function SpellCooldownState.GetWandHoldEnd()
  return wandShotAt + WAND_HOLD_WINDOW
end

local function ApplyWandHold(spellID, duration)
  if IsWandHeld(spellID) then
    return wandSnapshots[spellID] or duration, true
  end
  local now = GetTime()
  if wandUsed and duration and now - (wandSnapshotAt[spellID] or -math.huge) >= WAND_SNAPSHOT_INTERVAL then
    wandSnapshots[spellID], wandSnapshotAt[spellID] = duration:Copy(), now
  end
  return duration, false
end
SpellCooldownState.ApplyWandHold = ApplyWandHold

-- Durations
local emptyDuration
local function GetEmptyDuration()
  if not emptyDuration and C_DurationUtil and C_DurationUtil.CreateDuration then
    emptyDuration = C_DurationUtil.CreateDuration()
  end
  return emptyDuration
end

local function IsGCDOnly(spellID, durationWithoutGCD)
  local info = C_Spell.GetSpellCooldown(spellID)
  if not (info and ReadableBoolean(info.isActive) and ReadableBoolean(info.isEnabled) ~= false) then
    return false
  end
  local isZero = durationWithoutGCD and ReadableIsZero(durationWithoutGCD)
  if isZero ~= nil then
    return isZero
  end
  return gcdFlags[spellID] == true
end

function SpellCooldownState.IsGCDOnly(spellID)
  return IsGCDOnly(spellID, CallForDuration(C_Spell.GetSpellCooldownDuration, spellID, true))
end

-- Own cooldown of the spell: GCD only shows as an empty timer, wand hold shows the pre-shot timer.
function SpellCooldownState.GetCooldownDurationWithoutGCD(spellID)
  local duration = CallForDuration(C_Spell.GetSpellCooldownDuration, spellID, true)
  if IsGCDOnly(spellID, duration) then
    return GetEmptyDuration() or duration
  end
  return (ApplyWandHold(spellID, duration))
end

local function GetLossOfControlDuration(spellID)
  if not C_Spell.GetSpellLossOfControlCooldownInfo then
    return nil
  end
  local ok, info = pcall(C_Spell.GetSpellLossOfControlCooldownInfo, spellID)
  if ok and info and ReadableBoolean(info.shouldReplaceNormalCooldown) then
    return CallForDuration(C_Spell.GetSpellLossOfControlCooldownDuration, spellID)
  end
end

-- Returns the timer to display, then the same timer without the GCD.
function SpellCooldownState.GetDisplayDurations(spellID, useCharges, showGCD, showLossOfControl)
  local lossOfControl = showLossOfControl and GetLossOfControlDuration(spellID)
  if lossOfControl then
    return lossOfControl, lossOfControl
  end
  if useCharges then
    local charge = CallForDuration(C_Spell.GetSpellChargeDuration, spellID)
    return charge, charge
  end
  local withoutGCD = SpellCooldownState.GetCooldownDurationWithoutGCD(spellID)
  if showGCD and not IsWandHeld(spellID) then
    return CallForDuration(C_Spell.GetSpellCooldownDuration, spellID, false), withoutGCD
  end
  return withoutGCD, withoutGCD
end

-- Charges: maxCharges is never secret, current charges and cast count become nil when secret.
function SpellCooldownState.ReadCharges(spellID)
  local current, maximum, count
  local info = C_Spell.GetSpellCharges and C_Spell.GetSpellCharges(spellID)
  if info then
    current = ReadableNumber(info.currentCharges)
    maximum = ReadableNumber(info.maxCharges)
  end
  if C_Spell.GetSpellCastCount then
    local ok, castCount = pcall(C_Spell.GetSpellCastCount, spellID)
    count = ok and ReadableNumber(castCount) or nil
  end
  return current, maximum, count
end

-- Selectors: valueIfTrue while the timer runs, possibly as a secret only usable by secret aware sinks.
local remainingCurves = {}
local function GetRemainingCurve(valueIfTrue, valueIfFalse)
  local key = valueIfTrue .. "|" .. valueIfFalse
  local curve = remainingCurves[key]
  if not curve then
    curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, valueIfFalse)
    curve:AddPoint(ACTIVE_REMAINING_THRESHOLD, valueIfTrue)
    remainingCurves[key] = curve
  end
  return curve
end

-- Returns nil when the duration cannot answer, so callers keep their readable fallback.
local function SelectDuration(duration, valueIfTrue, valueIfFalse)
  if not IsDuration(duration) then
    return nil
  end
  local remaining = ReadableRemaining(duration)
  if remaining then
    if remaining > 0 then
      return valueIfTrue
    end
    return valueIfFalse
  end
  if type(valueIfTrue) == "number" and type(valueIfFalse) == "number" and C_CurveUtil and C_CurveUtil.CreateCurve
     and not Private.IsSecret(valueIfTrue, valueIfFalse) then
    local ok, value = pcall(duration.EvaluateRemainingDuration, duration, GetRemainingCurve(valueIfTrue, valueIfFalse))
    if ok then
      return value
    end
  end
  local ok, isZero = pcall(duration.IsZero, duration)
  if ok and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
    return C_CurveUtil.EvaluateColorValueFromBoolean(isZero, valueIfFalse, valueIfTrue)
  end
end
SpellCooldownState.SelectDuration = SelectDuration

-- Spell on its own cooldown: GCD, wand hold and charges left count as ready.
function SpellCooldownState.SelectSpell(spellID, valueIfTrue, valueIfFalse)
  return SelectDuration(SpellCooldownState.GetCooldownDurationWithoutGCD(spellID), valueIfTrue, valueIfFalse)
end

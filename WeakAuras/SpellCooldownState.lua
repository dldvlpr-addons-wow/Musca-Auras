if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local IsSecret = Private.IsSecret
local ShouldCooldownBeSecret = C_Secrets and C_Secrets.ShouldSpellCooldownBeSecret

local SHOOT = 5019
local HOLD_WINDOW = 3
local SHOT_MERGE_WINDOW = 0.05
local SNAPSHOT_INTERVAL = 0.5
local ACTIVE_THRESHOLD = 0.001
local NEVER = -math.huge

local SpellCooldownState = {
  SHOOT_SPELL_ID = SHOOT,
}
Private.SpellCooldownState = SpellCooldownState

local gcdFlags, gcdFlagSince = {}, {}
local castAfterShot, lastCastAt = {}, {}
local wandSnapshots, wandSnapshotAt = {}, {}
local wandShotAt, wandLastShotUpdate = NEVER, NEVER
local wandUsed = false
local emptyDuration
local selectCurves = {}

local function PlainBoolean(value)
  if type(value) == "boolean" and not IsSecret(value) then
    return value
  end
end

local function PlainNumber(value)
  if type(value) == "number" and not IsSecret(value) then
    return value
  end
end

local function RemainingField(value)
  return value.GetRemainingDuration
end

local function Remaining(duration)
  return duration:GetRemainingDuration()
end

local function Zero(duration)
  return duration:IsZero()
end

local function CopyOf(duration)
  return duration:Copy()
end

local function IsDuration(value)
  if type(value) ~= "userdata" then
    return false
  end
  local ok, field = pcall(RemainingField, value)
  return ok and field ~= nil
end
SpellCooldownState.IsDuration = IsDuration

local function CheckedDuration(ok, value)
  if ok and IsDuration(value) then
    return value
  end
end

local function SafeDuration(getter, ...)
  if getter then
    return CheckedDuration(pcall(getter, ...))
  end
end

local function CooldownInfo(spellID)
  local getter = C_Spell and C_Spell.GetSpellCooldown
  if not getter then
    return nil
  end
  local ok, info = pcall(getter, spellID)
  if ok and type(info) == "table" then
    return info
  end
end

local function DurationIgnoringGCD(spellID)
  return SafeDuration(C_Spell and C_Spell.GetSpellCooldownDuration, spellID, true)
end

function SpellCooldownState.ReadableRemaining(duration)
  local ok, remaining = pcall(Remaining, duration)
  if ok then
    return PlainNumber(remaining)
  end
end
local ReadableRemaining = SpellCooldownState.ReadableRemaining

function SpellCooldownState.IsCooldownSecret(spellID)
  if not ShouldCooldownBeSecret then
    return nil
  end
  local ok, secret = pcall(ShouldCooldownBeSecret, spellID)
  if ok then
    return PlainBoolean(secret)
  end
end

function SpellCooldownState.UpdateGCDFlag(spellID)
  local info = CooldownInfo(spellID)
  local flag = info and PlainBoolean(info.isOnGCD)
  if flag == true then
    if gcdFlags[spellID] ~= true then
      gcdFlagSince[spellID] = GetTime()
    end
  else
    gcdFlagSince[spellID] = nil
  end
  gcdFlags[spellID] = flag
end

function SpellCooldownState.GetGCDFlag(spellID)
  return gcdFlags[spellID], gcdFlagSince[spellID]
end

function SpellCooldownState.ForgetGCDFlag(spellID)
  gcdFlags[spellID] = nil
  gcdFlagSince[spellID] = nil
end

function SpellCooldownState.ClearGCDFlags()
  wipe(gcdFlags)
  wipe(gcdFlagSince)
end

function SpellCooldownState.ClearWandHold()
  wipe(castAfterShot)
  wipe(wandSnapshots)
  wipe(wandSnapshotAt)
  wandShotAt, wandLastShotUpdate = NEVER, NEVER
end
local ClearWandHold = SpellCooldownState.ClearWandHold

local function RecordShot()
  local now = GetTime()
  if now - wandLastShotUpdate > SHOT_MERGE_WINDOW then
    wandShotAt = now
    wipe(castAfterShot)
  end
  wandLastShotUpdate = now
  wandUsed = true
end

function SpellCooldownState.NotePlayerCast(spellID)
  if type(spellID) ~= "number" or IsSecret(spellID) then
    ClearWandHold()
  elseif spellID == SHOOT then
    RecordShot()
  else
    lastCastAt[spellID] = GetTime()
    castAfterShot[spellID] = true
    wandSnapshotAt[spellID] = nil
  end
end

function SpellCooldownState.NoteCooldownEvent(spellID, baseSpellID)
  if PlainNumber(spellID) ~= SHOOT and PlainNumber(baseSpellID) ~= SHOOT then
    return
  end
  local info = CooldownInfo(SHOOT)
  if info and PlainBoolean(info.isActive) == true then
    RecordShot()
  end
end

function SpellCooldownState.GetLastCast(spellID)
  return lastCastAt[spellID]
end

function SpellCooldownState.IsWandHeld(spellID)
  return spellID ~= SHOOT and GetTime() - wandShotAt < HOLD_WINDOW and not castAfterShot[spellID]
end
local IsWandHeld = SpellCooldownState.IsWandHeld

function SpellCooldownState.GetWandHoldEnd()
  return wandShotAt + HOLD_WINDOW
end

function SpellCooldownState.ApplyWandHold(spellID, duration)
  if IsWandHeld(spellID) then
    return wandSnapshots[spellID] or duration, true
  end
  if wandUsed and duration ~= nil then
    local now = GetTime()
    if now - (wandSnapshotAt[spellID] or NEVER) >= SNAPSHOT_INTERVAL then
      local ok, copy = pcall(CopyOf, duration)
      if ok then
        wandSnapshots[spellID] = copy
        wandSnapshotAt[spellID] = now
      end
    end
  end
  return duration, false
end
local ApplyWandHold = SpellCooldownState.ApplyWandHold

local function GCDOnly(spellID, durationWithoutGCD)
  local info = CooldownInfo(spellID)
  if not info or PlainBoolean(info.isActive) ~= true or PlainBoolean(info.isEnabled) == false then
    return false
  end
  if durationWithoutGCD then
    local ok, isZero = pcall(Zero, durationWithoutGCD)
    if ok then
      local plain = PlainBoolean(isZero)
      if plain ~= nil then
        return plain
      end
    end
  end
  return gcdFlags[spellID] == true
end

function SpellCooldownState.IsGCDOnly(spellID)
  return GCDOnly(spellID, DurationIgnoringGCD(spellID))
end

local function EmptyDuration()
  if not emptyDuration and C_DurationUtil and C_DurationUtil.CreateDuration then
    emptyDuration = C_DurationUtil.CreateDuration()
  end
  return emptyDuration
end

function SpellCooldownState.GetCooldownDurationWithoutGCD(spellID)
  local duration = DurationIgnoringGCD(spellID)
  if GCDOnly(spellID, duration) then
    return EmptyDuration() or duration
  end
  return (ApplyWandHold(spellID, duration))
end
local GetCooldownDurationWithoutGCD = SpellCooldownState.GetCooldownDurationWithoutGCD

local function LossOfControlDuration(spellID)
  local getInfo = C_Spell and C_Spell.GetSpellLossOfControlCooldownInfo
  if not getInfo then
    return nil
  end
  local ok, info = pcall(getInfo, spellID)
  if ok and type(info) == "table" and PlainBoolean(info.shouldReplaceNormalCooldown) == true then
    return SafeDuration(C_Spell.GetSpellLossOfControlCooldownDuration, spellID)
  end
end

function SpellCooldownState.GetDisplayDurations(spellID, useCharges, showGCD, showLossOfControl)
  if showLossOfControl then
    local lossOfControl = LossOfControlDuration(spellID)
    if lossOfControl then
      return lossOfControl, lossOfControl
    end
  end
  if useCharges then
    local charge = SafeDuration(C_Spell and C_Spell.GetSpellChargeDuration, spellID)
    return charge, charge
  end
  local withoutGCD = GetCooldownDurationWithoutGCD(spellID)
  if showGCD and not IsWandHeld(spellID) then
    return SafeDuration(C_Spell and C_Spell.GetSpellCooldownDuration, spellID, false), withoutGCD
  end
  return withoutGCD, withoutGCD
end

function SpellCooldownState.ReadCharges(spellID)
  local current, maximum, count
  local getCharges = C_Spell and C_Spell.GetSpellCharges
  if getCharges then
    local ok, info = pcall(getCharges, spellID)
    if ok and type(info) == "table" then
      current = PlainNumber(info.currentCharges)
      maximum = PlainNumber(info.maxCharges)
    end
  end
  local getCount = C_Spell and C_Spell.GetSpellCastCount
  if getCount then
    local ok, value = pcall(getCount, spellID)
    if ok then
      count = PlainNumber(value)
    end
  end
  return current, maximum, count
end

local function SelectCurve(valueIfTrue, valueIfFalse)
  local byFalse = selectCurves[valueIfTrue]
  if not byFalse then
    byFalse = {}
    selectCurves[valueIfTrue] = byFalse
  end
  local curve = byFalse[valueIfFalse]
  if not curve then
    curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, valueIfFalse)
    curve:AddPoint(ACTIVE_THRESHOLD, valueIfTrue)
    byFalse[valueIfFalse] = curve
  end
  return curve
end

local function EvaluateRemaining(duration, curve)
  return duration:EvaluateRemainingDuration(curve)
end

function SpellCooldownState.SelectDuration(duration, valueIfTrue, valueIfFalse)
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
  if type(valueIfTrue) == "number" and type(valueIfFalse) == "number"
    and not IsSecret(valueIfTrue, valueIfFalse)
    and C_CurveUtil and C_CurveUtil.CreateCurve then
    local curveOk, curve = pcall(SelectCurve, valueIfTrue, valueIfFalse)
    if curveOk then
      local ok, value = pcall(EvaluateRemaining, duration, curve)
      if ok then
        return value
      end
    end
  end
  local ok, isZero = pcall(Zero, duration)
  if ok and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
    return C_CurveUtil.EvaluateColorValueFromBoolean(isZero, valueIfFalse, valueIfTrue)
  end
  return nil
end
local SelectDuration = SpellCooldownState.SelectDuration

function SpellCooldownState.SelectSpell(spellID, valueIfTrue, valueIfFalse)
  return SelectDuration(GetCooldownDurationWithoutGCD(spellID), valueIfTrue, valueIfFalse)
end

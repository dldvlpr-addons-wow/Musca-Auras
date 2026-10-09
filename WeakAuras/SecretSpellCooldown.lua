-- Spell cooldown event handler for secret cooldown values: duration objects, GCD and latency margins.
-- Defines Private.CreateSecretSpellCooldown and Private.IsDurationObjectRunning; used by GenericTrigger.lua.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local pairs, next, type, pcall, select, math = pairs, next, type, pcall, select, math

local SECRET_POLL_INTERVAL = 0.1
local RECHECK_MARGIN = 0.05
local DEFAULT_GCD_LENGTH = 1.5
local GCD_LATENCY_MARGIN = 0.1

function Private.IsDurationObjectRunning(durationObject)
  local okZero, isZero = pcall(durationObject.IsZero, durationObject)
  local okExpired, hasExpired = pcall(durationObject.HasExpired, durationObject)
  if okZero and okExpired and type(isZero) == "boolean" and type(hasExpired) == "boolean"
     and not Private.IsSecret(isZero, hasExpired)
  then
    return not isZero and not hasExpired
  end
end

function Private.CreateSecretSpellCooldown(SpellDetails, GetRuneDuration)
  local SpellCooldownState = Private.SpellCooldownState
  local gcdSpellID = WeakAuras.IsClassicOrTBCOrWrath() and 29515 or 61304
  local knownGCDLength = DEFAULT_GCD_LENGTH

  -- Shortest time a spell must stay unavailable to be a real cooldown rather than the GCD.
  local function GetGCDWindow()
    local info = C_Spell.GetSpellCooldown(gcdSpellID)
    local duration = info and info.duration
    if type(duration) == "number" and not Private.IsSecret(duration) and duration > 0 then
      knownGCDLength = duration
    end
    return knownGCDLength + GCD_LATENCY_MARGIN
  end

  -- ready, active, readable remaining time
  local function GetSecretSpellReady(spellID)
    local info = C_Spell.GetSpellCooldown(spellID)
    if not info or Private.IsSecret(info.isActive) or type(info.isActive) ~= "boolean" then
      return nil, false
    end
    if not Private.IsSecret(info.isEnabled) and info.isEnabled == false then
      return false, info.isActive
    end
    if not info.isActive then
      return true, false
    end
    local ok, cooldown = pcall(C_Spell.GetSpellCooldownDuration, spellID, true)
    if ok and SpellCooldownState.IsDuration(cooldown) then
      local okZero, zero = pcall(cooldown.IsZero, cooldown)
      if okZero and type(zero) == "boolean" and not Private.IsSecret(zero) then
        return zero, true, not zero and SpellCooldownState.ReadableRemaining(cooldown) or nil
      end
    end
    return (SpellCooldownState.GetGCDFlag(spellID)), true
  end

  local secretSpells = {}
  local polledSpells, pollQueue, staleSpells = {}, {}, {}
  local recheckTimers, recheckDeadlines = {}, {}

  local function CancelRecheckTimer(spellID)
    if recheckTimers[spellID] then
      recheckTimers[spellID]:Cancel()
      recheckTimers[spellID], recheckDeadlines[spellID] = nil, nil
    end
  end

  local function ForgetSecretSpell(spellID)
    CancelRecheckTimer(spellID)
    secretSpells[spellID], polledSpells[spellID] = nil, nil
    SpellCooldownState.ForgetGCDFlag(spellID)
  end

  local function RecheckSecretSpell(spellID)
    local detail = SpellDetails.data[spellID]
    if not (detail and detail.secret) then
      ForgetSecretSpell(spellID)
      return
    end
    SpellDetails.quietSecretCheck = true
    SpellDetails:CheckSpellCooldown(spellID, GetRuneDuration())
    SpellDetails.quietSecretCheck = nil
  end

  -- Last resort when no deadline is readable.
  local poller = CreateFrame("Frame")
  poller:Hide()
  poller.elapsed = 0
  poller:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < SECRET_POLL_INTERVAL then
      return
    end
    self.elapsed = 0
    local count = 0
    for spellID in pairs(polledSpells) do
      count = count + 1
      pollQueue[count] = spellID
    end
    for index = 1, count do
      local spellID = pollQueue[index]
      pollQueue[index] = nil
      if polledSpells[spellID] then
        RecheckSecretSpell(spellID)
      end
    end
    if not next(polledSpells) then
      self:Hide()
    end
  end)

  local function ScheduleRecheck(spellID, recheckAt)
    if not recheckAt then
      CancelRecheckTimer(spellID)
      polledSpells[spellID] = true
      poller:Show()
      return
    end
    polledSpells[spellID] = nil
    if recheckDeadlines[spellID] and math.abs(recheckDeadlines[spellID] - recheckAt) < RECHECK_MARGIN then
      return
    end
    CancelRecheckTimer(spellID)
    recheckDeadlines[spellID] = recheckAt
    recheckTimers[spellID] = C_Timer.NewTimer(math.max(recheckAt - GetTime(), 0) + RECHECK_MARGIN, function()
      recheckTimers[spellID], recheckDeadlines[spellID] = nil, nil
      RecheckSecretSpell(spellID)
    end)
  end

  local function StopRecheck(spellID)
    CancelRecheckTimer(spellID)
    polledSpells[spellID] = nil
  end

  function SpellDetails:UpdateSecretReady(effectiveSpellId)
    local detail = self.data[effectiveSpellId]
    if not secretSpells[effectiveSpellId] then
      secretSpells[effectiveSpellId] = true
      SpellCooldownState.UpdateGCDFlag(effectiveSpellId)
    end
    local ready, active, remaining = GetSecretSpellReady(effectiveSpellId)
    local now = GetTime()
    local recheckAt = remaining and now + remaining
    local gcdWindow = GetGCDWindow()
    local onGCD, onGCDSince = SpellCooldownState.GetGCDFlag(effectiveSpellId)
    local gcdHold = false
    if ready == true and active and onGCD == true and onGCDSince and now - onGCDSince < gcdWindow then
      ready, gcdHold = false, true
      recheckAt = onGCDSince + gcdWindow
    end
    local wandOnly = false
    if detail.notReadyWand then
      local cast = SpellCooldownState.GetLastCast(effectiveSpellId)
      wandOnly = not cast or (detail.lastReadyAt and cast < detail.lastReadyAt - 0.2) or false
    end
    -- A not-ready span made only of GCD holds never fires READY, however late its end timer runs.
    if detail.secretReady == false and ready == true and detail.notReadySince and not wandOnly and not detail.gcdHoldOnly
       and now - detail.notReadySince > gcdWindow + 2 * RECHECK_MARGIN and not WeakAuras.IsPaused()
    then
      self:SendEventsForSpell(effectiveSpellId, "SPELL_COOLDOWN_READY", effectiveSpellId)
    end
    if ready == false then
      if detail.secretReady ~= false or not detail.notReadySince then
        detail.notReadySince = now
        detail.notReadyWand = SpellCooldownState.IsWandHeld(effectiveSpellId) or nil
        detail.gcdHoldOnly = gcdHold or nil
      elseif not gcdHold then
        detail.gcdHoldOnly = nil
      end
      ScheduleRecheck(effectiveSpellId, recheckAt)
    else
      detail.notReadySince, detail.notReadyWand, detail.gcdHoldOnly = nil, nil, nil
      if ready == true then
        detail.lastReadyAt = now
      end
      StopRecheck(effectiveSpellId)
    end
    local secretGCDOnly = gcdHold or nil
    local changed = detail.secretReady ~= ready or detail.secretGCDOnly ~= secretGCDOnly
    detail.secretReady = ready
    detail.secretGCDOnly = secretGCDOnly
    return changed
  end

  function SpellDetails:ClearSecretReady(effectiveSpellId)
    local detail = self.data[effectiveSpellId]
    detail.secretReady, detail.notReadySince, detail.notReadyWand, detail.gcdHoldOnly, detail.secretGCDOnly = nil, nil, nil, nil, nil
    ForgetSecretSpell(effectiveSpellId)
  end

  local function UpdateSecretSpellGCDFlags()
    local staleCount = 0
    for spellID in pairs(secretSpells) do
      if SpellDetails.data[spellID] then
        SpellCooldownState.UpdateGCDFlag(spellID)
      else
        staleCount = staleCount + 1
        staleSpells[staleCount] = spellID
      end
    end
    for index = 1, staleCount do
      ForgetSecretSpell(staleSpells[index])
      staleSpells[index] = nil
    end
  end

  return function(inWorld, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      SpellCooldownState.NotePlayerCast((select(3, ...)))
      return true
    elseif event == "SPELL_UPDATE_COOLDOWN" then
      if inWorld then
        SpellCooldownState.NoteCooldownEvent(...)
        UpdateSecretSpellGCDFlags()
      end
    elseif event == "PLAYER_ENTERING_WORLD" then
      SpellCooldownState.ClearWandHold()
    elseif event == "PLAYER_LEAVING_WORLD" then
      SpellCooldownState.ClearGCDFlags()
    end
  end
end

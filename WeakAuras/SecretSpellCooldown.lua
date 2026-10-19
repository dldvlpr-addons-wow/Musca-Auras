-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Readiness of spells whose cooldown timing is secret in combat, for the
-- spell cooldown trigger. Without readable start and duration, the module
-- tells a real cooldown from the global cooldown, sends the ready event and
-- re-checks the spell when its cooldown should end.

local State = Private.SpellCooldownState
local IsSecret = Private.IsSecret

local POLL_INTERVAL = 0.1
local RECHECK_MARGIN = 0.05
local DEFAULT_GCD_LENGTH = 1.5
local GCD_LATENCY = 0.1
-- A cast of the spell this long before its last ready time belongs to an
-- older cooldown.
local CAST_TOLERANCE = 0.2
local SECRET_READY_FIELDS = {
  "secretReady", "secretGCDOnly", "notReadySince", "notReadyWand", "gcdHoldOnly",
}

local function ReadableBoolean(value)
  if type(value) == "boolean" and not IsSecret(value) then
    return value
  end
end

-- true while running, false when empty or expired, nil when unreadable.
function Private.IsDurationObjectRunning(duration)
  local zeroOk, isZero = pcall(duration.IsZero, duration)
  local expiredOk, hasExpired = pcall(duration.HasExpired, duration)
  if not (zeroOk and expiredOk) then
    return nil
  end
  isZero, hasExpired = ReadableBoolean(isZero), ReadableBoolean(hasExpired)
  if isZero == nil or hasExpired == nil then
    return nil
  end
  return not isZero and not hasExpired
end

-- ready (true, false or nil when unknown), active, readable remaining time.
local function ReadReadiness(spellID)
  local info = C_Spell.GetSpellCooldown(spellID)
  local isActive = info and ReadableBoolean(info.isActive)
  if isActive == nil then
    return nil, false
  end
  if ReadableBoolean(info.isEnabled) == false then
    return false, isActive
  end
  if not isActive then
    return true, false
  end
  local ok, duration = pcall(C_Spell.GetSpellCooldownDuration, spellID, true)
  if ok and State.IsDuration(duration) then
    local zeroOk, isZero = pcall(duration.IsZero, duration)
    if zeroOk and ReadableBoolean(isZero) ~= nil then
      if isZero then
        return true, true
      end
      return false, true, State.ReadableRemaining(duration)
    end
  end
  -- No readable timer: only the GCD flag recorded on the last cooldown event.
  return (State.GetGCDFlag(spellID)), true
end

function Private.CreateSecretSpellCooldown(SpellDetails, GetRuneDuration)
  local gcdSpellID = 29515
  local gcdLength = DEFAULT_GCD_LENGTH
  local tracked = {}
  local timers = {}
  local polled = {}
  local pollFrame = CreateFrame("Frame")
  pollFrame:Hide()

  -- Shortest time a spell must stay unavailable to count as a real cooldown.
  local function GCDWindow()
    local info = C_Spell.GetSpellCooldown(gcdSpellID)
    local duration = info and info.duration
    if type(duration) == "number" and not IsSecret(duration) and duration > 0 then
      gcdLength = duration
    end
    return gcdLength + GCD_LATENCY
  end

  local function CancelTimer(spellID)
    local scheduled = timers[spellID]
    if scheduled then
      scheduled.timer:Cancel()
      timers[spellID] = nil
    end
  end

  local function StopRecheck(spellID)
    CancelTimer(spellID)
    polled[spellID] = nil
  end

  local function Forget(spellID)
    StopRecheck(spellID)
    tracked[spellID] = nil
    State.ForgetGCDFlag(spellID)
  end

  local function Recheck(spellID)
    local detail = SpellDetails.data[spellID]
    if not (detail and detail.secret) then
      Forget(spellID)
      return
    end
    SpellDetails.quietSecretCheck = true
    SpellDetails:CheckSpellCooldown(spellID, GetRuneDuration())
    SpellDetails.quietSecretCheck = nil
  end

  -- Scratch lists, reused on every call.
  local due, orphans = {}, {}

  local function ClearList(list)
    for index = #list, 1, -1 do
      list[index] = nil
    end
  end

  local sinceLastPoll = 0
  pollFrame:SetScript("OnUpdate", function(frame, elapsed)
    sinceLastPoll = sinceLastPoll + elapsed
    if sinceLastPoll < POLL_INTERVAL then
      return
    end
    sinceLastPoll = 0
    -- A recheck can add or remove polled spells.
    ClearList(due)
    for spellID in pairs(polled) do
      due[#due + 1] = spellID
    end
    for _, spellID in ipairs(due) do
      if polled[spellID] then
        Recheck(spellID)
      end
    end
    if next(polled) == nil then
      frame:Hide()
    end
  end)

  -- Without a readable deadline, the spell is polled instead.
  local function ScheduleRecheck(spellID, recheckAt)
    if not recheckAt then
      CancelTimer(spellID)
      polled[spellID] = true
      pollFrame:Show()
      return
    end
    polled[spellID] = nil
    local scheduled = timers[spellID]
    if scheduled and math.abs(scheduled.deadline - recheckAt) < RECHECK_MARGIN then
      return
    end
    CancelTimer(spellID)
    local entry = { deadline = recheckAt }
    entry.timer = C_Timer.NewTimer(math.max(recheckAt - GetTime(), 0) + RECHECK_MARGIN, function()
      if timers[spellID] == entry then
        timers[spellID] = nil
      end
      Recheck(spellID)
    end)
    timers[spellID] = entry
  end

  -- A not ready span started while the wand held the spell, with no cast of
  -- the spell since it was last ready, only showed the Shoot timer.
  local function IsWandOnlySpan(spellID, detail)
    if not detail.notReadyWand then
      return false
    end
    local cast = State.GetLastCast(spellID)
    if not cast then
      return true
    end
    local readyAt = detail.lastReadyAt
    if readyAt == nil then
      return false
    end
    local oldestCurrentCast = readyAt - CAST_TOLERANCE
    return cast < oldestCurrentCast
  end

  -- Not ready span after this update, from the values of the previous one:
  -- start time, wand flag, and whether only GCD holds made it so far.
  local function NextSpan(spellID, detail, ready, gcdHold, now)
    if ready ~= false then
      return nil, nil, nil
    end
    local since = detail.notReadySince
    if since and detail.secretReady == false then
      local holdOnly = nil
      if gcdHold then
        holdOnly = detail.gcdHoldOnly
      end
      return since, detail.notReadyWand, holdOnly
    end
    return now, State.IsWandHeld(spellID) or nil, gcdHold or nil
  end

  -- A real cooldown, longer than the GCD window, has just ended. A span made
  -- only of GCD holds never counts.
  local function EndsRealCooldown(spellID, detail, ready, now, window)
    if ready ~= true or detail.secretReady ~= false then
      return false
    end
    local since = detail.notReadySince
    if not since or detail.gcdHoldOnly then
      return false
    end
    if now - since <= window + 2 * RECHECK_MARGIN then
      return false
    end
    return not IsWandOnlySpan(spellID, detail)
  end

  function SpellDetails:UpdateSecretReady(spellID)
    local detail = self.data[spellID]
    if not tracked[spellID] then
      tracked[spellID] = true
      State.UpdateGCDFlag(spellID)
    end

    local ready, active, remaining = ReadReadiness(spellID)
    local now = GetTime()
    local window = GCDWindow()
    local recheckAt = remaining and now + remaining

    -- Ready inside the GCD of a spell flagged on GCD: the empty timer is the
    -- GCD itself, so the spell is held as not ready until the window ends.
    local onGCD, onGCDSince = State.GetGCDFlag(spellID)
    local gcdHold = ready == true and active and onGCD == true and onGCDSince ~= nil
                    and now - onGCDSince < window
    if gcdHold then
      ready = false
      recheckAt = onGCDSince + window
    end

    local since, wand, holdOnly = NextSpan(spellID, detail, ready, gcdHold, now)
    if EndsRealCooldown(spellID, detail, ready, now, window) and not WeakAuras.IsPaused() then
      self:SendEventsForSpell(spellID, "SPELL_COOLDOWN_READY", spellID)
    end
    detail.notReadySince = since
    detail.notReadyWand = wand
    detail.gcdHoldOnly = holdOnly

    if ready == false then
      ScheduleRecheck(spellID, recheckAt)
    else
      if ready then
        detail.lastReadyAt = now
      end
      StopRecheck(spellID)
    end

    local secretGCDOnly = gcdHold or nil
    local changed = detail.secretReady ~= ready or detail.secretGCDOnly ~= secretGCDOnly
    detail.secretReady, detail.secretGCDOnly = ready, secretGCDOnly
    return changed
  end

  function SpellDetails:ClearSecretReady(spellID)
    local detail = self.data[spellID]
    if detail then
      for _, field in ipairs(SECRET_READY_FIELDS) do
        detail[field] = nil
      end
    end
    Forget(spellID)
  end

  -- Returns true when the event is fully handled here.
  return function(inWorld, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      State.NotePlayerCast((select(3, ...)))
      return true
    elseif event == "SPELL_UPDATE_COOLDOWN" then
      if inWorld then
        State.NoteCooldownEvent(...)
        ClearList(orphans)
        for spellID in pairs(tracked) do
          if SpellDetails.data[spellID] then
            State.UpdateGCDFlag(spellID)
          else
            orphans[#orphans + 1] = spellID
          end
        end
        for _, spellID in ipairs(orphans) do
          Forget(spellID)
        end
      end
    elseif event == "PLAYER_ENTERING_WORLD" then
      State.ClearWandHold()
    elseif event == "PLAYER_LEAVING_WORLD" then
      State.ClearGCDFlags()
    end
  end
end

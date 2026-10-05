if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local pairs, next, type, pcall, select, wipe = pairs, next, type, pcall, select, wipe

local SHOOT_SPELL_ID = 5019
local WAND_HOLD_WINDOW = 3
local SECRET_POLL_INTERVAL = 0.1
local SECRET_MIN_COOLDOWN = 2.0

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
  local gcdFlags, gcdFlagSince = {}, {}
  local wandShotAt, wandLastShotUpdate = -math.huge, -math.huge
  local castAfterShot, lastCast = {}, {}

  local function UpdateSpellCooldownGCD(spellID)
    local info = C_Spell.GetSpellCooldown(spellID)
    local wasOnGCD = gcdFlags[spellID] == true
    gcdFlags[spellID] = nil
    if info and not Private.IsSecret(info.isOnGCD) and type(info.isOnGCD) == "boolean" then
      gcdFlags[spellID] = info.isOnGCD
    end
    if gcdFlags[spellID] ~= true then
      gcdFlagSince[spellID] = nil
    elseif not wasOnGCD then
      gcdFlagSince[spellID] = GetTime()
    end
  end

  local function ClearWandHold()
    wipe(castAfterShot)
    wandShotAt, wandLastShotUpdate = -math.huge, -math.huge
  end

  local function NoteWandShot()
    local now = GetTime()
    if now - wandLastShotUpdate > 0.05 then
      wandShotAt = now
      wipe(castAfterShot)
    end
    wandLastShotUpdate = now
  end

  local function NotePlayerCast(spellID)
    if Private.IsSecret(spellID) or type(spellID) ~= "number" then
      ClearWandHold()
    elseif spellID == SHOOT_SPELL_ID then
      NoteWandShot()
    else
      lastCast[spellID] = GetTime()
      castAfterShot[spellID] = true
    end
  end

  local function IsWandHeldSpell(spellID)
    return spellID ~= SHOOT_SPELL_ID and GetTime() - wandShotAt < WAND_HOLD_WINDOW and not castAfterShot[spellID]
  end

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
    if ok and Private.IsDurationObject(cooldown) then
      local okZero, zero = pcall(cooldown.IsZero, cooldown)
      if okZero and type(zero) == "boolean" and not Private.IsSecret(zero) then
        return zero, true
      end
    end
    return gcdFlags[spellID], true
  end

  local secretPolled = {}
  local secretPoller = CreateFrame("Frame")
  secretPoller:Hide()
  secretPoller.elapsed = 0
  secretPoller:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < SECRET_POLL_INTERVAL then
      return
    end
    self.elapsed = 0
    SpellDetails.quietSecretCheck = true
    for id in pairs(secretPolled) do
      if SpellDetails.data[id] and SpellDetails.data[id].secret then
        local info = C_Spell.GetSpellCooldown(id)
        local active = info and info.isActive
        if Private.IsSecret(active) or active ~= true or gcdFlags[id] == true then
          SpellDetails:CheckSpellCooldown(id, GetRuneDuration())
        end
      else
        secretPolled[id] = nil
      end
    end
    SpellDetails.quietSecretCheck = nil
    if not next(secretPolled) then
      self:Hide()
    end
  end)

  function SpellDetails:UpdateSecretReady(effectiveSpellId)
    local detail = self.data[effectiveSpellId]
    local ready, active = GetSecretSpellReady(effectiveSpellId)
    local now = GetTime()
    if ready == true and active and gcdFlags[effectiveSpellId] == true and gcdFlagSince[effectiveSpellId]
       and now - gcdFlagSince[effectiveSpellId] < SECRET_MIN_COOLDOWN
    then
      ready = false
    end
    local wandOnly = false
    if detail.notReadyWand then
      local cast = lastCast[effectiveSpellId]
      wandOnly = not cast or (detail.lastReadyAt and cast < detail.lastReadyAt - 0.2) or false
    end
    if detail.secretReady == false and ready == true and detail.notReadySince and not wandOnly
       and now - detail.notReadySince > SECRET_MIN_COOLDOWN and not WeakAuras.IsPaused()
    then
      self:SendEventsForSpell(effectiveSpellId, "SPELL_COOLDOWN_READY", effectiveSpellId)
    end
    if ready == false then
      if detail.secretReady ~= false or not detail.notReadySince then
        detail.notReadySince = now
        detail.notReadyWand = IsWandHeldSpell(effectiveSpellId) or nil
      end
      secretPolled[effectiveSpellId] = true
      secretPoller:Show()
    else
      detail.notReadySince, detail.notReadyWand = nil, nil
      if ready == true then
        detail.lastReadyAt = now
      end
      secretPolled[effectiveSpellId] = nil
    end
    local changed = detail.secretReady ~= ready
    detail.secretReady = ready
    return changed
  end

  function SpellDetails:ClearSecretReady(effectiveSpellId)
    local detail = self.data[effectiveSpellId]
    detail.secretReady, detail.notReadySince, detail.notReadyWand = nil, nil, nil
    secretPolled[effectiveSpellId] = nil
  end

  return function(event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      NotePlayerCast((select(3, ...)))
      return true
    elseif event == "SPELL_UPDATE_COOLDOWN" then
      local arg1, baseSpellID = ...
      if (not Private.IsSecret(arg1) and arg1 == SHOOT_SPELL_ID)
         or (not Private.IsSecret(baseSpellID) and baseSpellID == SHOOT_SPELL_ID)
      then
        local info = C_Spell.GetSpellCooldown(SHOOT_SPELL_ID)
        if info and not Private.IsSecret(info.isActive) and info.isActive == true then
          NoteWandShot()
        end
      end
      for id in pairs(SpellDetails.data) do
        UpdateSpellCooldownGCD(id)
      end
    elseif event == "PLAYER_ENTERING_WORLD" then
      ClearWandHold()
    elseif event == "PLAYER_LEAVING_WORLD" then
      wipe(gcdFlags)
      wipe(gcdFlagSince)
    end
  end
end

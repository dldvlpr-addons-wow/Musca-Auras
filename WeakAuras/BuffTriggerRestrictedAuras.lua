if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local tinsert, wipe = table.insert, wipe
local pairs, next, type = pairs, next, type

function Private.CreateAddReadableRestrictedAuras(matchData, ScanUnit, MarkRescanPending, scanFuncName, scanFuncSpellId,
                                                  scanFuncGeneral, scanFuncNameGroup, scanFuncSpellIdGroup,
                                                  scanFuncGeneralGroup)
  local restrictedAddedAuras = {}
  local restrictedUpdateInfo = { addedAuras = restrictedAddedAuras }
  local unitScanFuncs = {
    scanFuncName, scanFuncSpellId, scanFuncGeneral, scanFuncNameGroup, scanFuncSpellIdGroup, scanFuncGeneralGroup
  }
  local function HasScanFuncs(unit, filter)
    for _, scanFuncs in ipairs(unitScanFuncs) do
      if scanFuncs[unit] and scanFuncs[unit][filter] and next(scanFuncs[unit][filter]) then
        return true
      end
    end
    return false
  end
  local function AcceptsSecretAuras(unit, filter)
    for _, scanFuncs in ipairs({scanFuncGeneral, scanFuncGeneralGroup}) do
      for triggerInfo in pairs(scanFuncs[unit] and scanFuncs[unit][filter] or {}) do
        if triggerInfo.acceptsSecretAuras then
          return true
        end
      end
    end
    return false
  end

  local function ReadSecretIcon(unit, auraInstanceID)
    local ok, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, auraInstanceID)
    if not ok or type(aura) == "nil" then
      return nil
    end
    local iconOk, icon = pcall(function() return aura.icon end)
    if iconOk then
      return icon
    end
  end

  local function CreateSecretAura(unit, filter, auraInstanceID)
    return {
      name = "",
      auraInstanceID = auraInstanceID,
      isHelpful = filter == "HELPFUL",
      isHarmful = filter == "HARMFUL",
      isSecretPlaceholder = true,
      secretIcon = ReadSecretIcon(unit, auraInstanceID),
    }
  end

  local function AddReadableRestrictedAuras(unit)
    wipe(restrictedAddedAuras)
    local secretAuras
    for _, filter in ipairs({"HELPFUL", "HARMFUL"}) do
      local ok, auraInstanceIDs
      if HasScanFuncs(unit, filter) then
        ok, auraInstanceIDs = pcall(C_UnitAuras.GetUnitAuraInstanceIDs, unit, filter)
      end
      if ok and type(auraInstanceIDs) == "table" and not Private.IsSecret(auraInstanceIDs) then
        local known = matchData[unit] and matchData[unit][filter]
        local acceptsSecret
        for _, auraInstanceID in ipairs(auraInstanceIDs) do
          if type(auraInstanceID) == "number" and not Private.IsSecret(auraInstanceID)
             and not (known and known[auraInstanceID])
          then
            local restricted = Private.IsRestricted("auraInstance", unit, auraInstanceID)
            if restricted == false then
              local readOk, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, auraInstanceID)
              if readOk and aura then
                tinsert(restrictedAddedAuras, aura)
              end
            elseif restricted then
              if acceptsSecret == nil then
                acceptsSecret = AcceptsSecretAuras(unit, filter)
              end
              if acceptsSecret then
                tinsert(restrictedAddedAuras, CreateSecretAura(unit, filter, auraInstanceID))
                secretAuras = secretAuras or {}
                secretAuras[auraInstanceID] = filter
              end
            end
          end
        end
      end
    end
    if restrictedAddedAuras[1] and not pcall(ScanUnit, GetTime(), unit, restrictedUpdateInfo) then
      MarkRescanPending()
    end
    for auraInstanceID, filter in pairs(secretAuras or {}) do
      local data = matchData[unit] and matchData[unit][filter] and matchData[unit][filter][auraInstanceID]
      if data then
        local durationOk, durationObject = pcall(C_UnitAuras.GetAuraDuration, unit, auraInstanceID)
        data.durationObject = nil
        if durationOk then
          data.durationObject = durationObject
        end
        local stacksOk, secretStacks = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, auraInstanceID)
        data.secretStacks = nil
        if stacksOk and type(secretStacks) == "string" then
          data.secretStacks = secretStacks
        end
      end
    end
  end

  return AddReadableRestrictedAuras
end

function Private.CreateRestrictedAuraRefresh(matchData, matchDataByTrigger, matchDataChanged, TooltipHelper, MarkRescanPending)
  local function RemoveMatchData(matchDataChanged, unit, filter, auraInstanceID)
    local data = matchData[unit] and matchData[unit][filter] and matchData[unit][filter][auraInstanceID]
    if data then
      matchData[unit][filter][auraInstanceID] = nil
      for id, triggerData in pairs(data.auras) do
        for triggernum in pairs(triggerData) do
          matchDataByTrigger[id][triggernum][unit][auraInstanceID] = nil
          matchDataChanged[id] = matchDataChanged[id] or {}
          matchDataChanged[id][triggernum] = true
        end
      end
      if data.dataInstanceID then
        TooltipHelper:Untrack(data.dataInstanceID, data)
      end
    end
  end

  local function RefreshRestrictedAuras(matchDataChanged, unit)
    if not matchData[unit] then
      return
    end
    for filter, matchDataPerFilter in pairs(matchData[unit]) do
      for auraInstanceID, data in pairs(matchDataPerFilter) do
        local ok, durationObject
        if next(data.auras) then
          ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, unit, auraInstanceID)
        end
        if ok then
          if durationObject == nil then
            RemoveMatchData(matchDataChanged, unit, filter, auraInstanceID)
          else
            local stacksOk, secretStacks = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, auraInstanceID)
            data.secretStacks = nil
            if stacksOk and type(secretStacks) == "string" then
              data.secretStacks = secretStacks
            end
            data.durationObject = durationObject
            for id, triggerData in pairs(data.auras) do
              for triggernum in pairs(triggerData) do
                matchDataChanged[id] = matchDataChanged[id] or {}
                matchDataChanged[id][triggernum] = true
              end
            end
          end
        end
      end
    end
  end

  local function ResetRecastPlayerAuras(time, spellId)
    local playerAuras = matchData.player and matchData.player.HELPFUL
    if not playerAuras or type(spellId) ~= "number" or Private.IsSecret(spellId) then
      return
    end
    for _, data in pairs(playerAuras) do
      local duration = data.duration
      if data.spellId == spellId and data.unitCaster == "player"
         and not Private.IsSecret(duration) and type(duration) == "number" and duration > 0
      then
        local modRate = not Private.IsSecret(data.modRate) and data.modRate or 1
        data.expirationTime = time + duration * modRate
        data.lastChanged = time
        MarkRescanPending()
        for id, triggerData in pairs(data.auras) do
          for triggernum in pairs(triggerData) do
            matchDataChanged[id] = matchDataChanged[id] or {}
            matchDataChanged[id][triggernum] = true
          end
        end
      end
    end
  end

  return RefreshRestrictedAuras, ResetRecastPlayerAuras
end

function Private.RegisterRestrictionChangedRescan(frame, restrictedRefreshUnits, SetAurasRestricted, ConsumeRescanPending,
                                                 HandleEvent)
  Private.callbacks:RegisterCallback("RestrictionChanged", function(_, isRestricted)
    local restricted = Private.IsRestricted("auras")
    if restricted == nil then
      restricted = isRestricted
    end
    SetAurasRestricted(restricted)
    if not restricted then
      wipe(restrictedRefreshUnits)
    end
    if not restricted and ConsumeRescanPending() then
      HandleEvent(frame, "PLAYER_ENTERING_WORLD")
      for _, unit in ipairs({"player", "pet", "target", "focus", "party1", "party2", "party3", "party4"}) do
        if UnitExists(unit) then
          HandleEvent(frame, "UNIT_AURA", unit)
        end
      end
    end
  end)
end

function Private.CreateProtectedUpdateStates(UpdateStates, MarkRescanPending, IsAurasRestricted)
  local singleMatchDataChanged = {}
  return function(matchDataChanged, time)
    for id, triggers in pairs(matchDataChanged) do
      singleMatchDataChanged[id] = triggers
      local ok, errorMessage = pcall(UpdateStates, singleMatchDataChanged, time)
      singleMatchDataChanged[id] = nil
      if not ok then
        Private.StopProfileAura(id)
        MarkRescanPending()
        if not (IsAurasRestricted() or Private.IsRestricted("auras")) then
          geterrorhandler()(errorMessage)
        end
      end
    end
  end
end

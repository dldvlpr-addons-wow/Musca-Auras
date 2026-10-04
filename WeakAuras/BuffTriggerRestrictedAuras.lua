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

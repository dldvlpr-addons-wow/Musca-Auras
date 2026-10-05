if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local tinsert = table.insert
local pairs, type, pcall = pairs, type, pcall

function Private.CreateNativeFilter(newAPI)
  local function NativeFilterString(trigger)
    if not (newAPI and C_UnitAuras.IsAuraFilteredOutByInstanceID and trigger.useNativeFilter)
       or trigger.unit == "multi" then
      return nil
    end
    local tokens = {}
    for token, enabled in pairs(type(trigger.nativeFilter) == "table" and trigger.nativeFilter or {}) do
      if enabled and Private.aura_native_filter_types[token] then
        tinsert(tokens, token)
      end
    end
    for token, enabled in pairs(type(trigger.nativeFilterNot) == "table" and trigger.nativeFilterNot or {}) do
      if enabled and Private.aura_native_filter_types[token] then
        tinsert(tokens, "!" .. token)
      end
    end
    table.sort(tokens)
    return tokens[1] and table.concat(tokens, "|") or nil
  end

  local function PassesNativeFilter(matchData, nativeFilter)
    if not matchData.auraInstanceID then
      return false
    end
    local ok, filteredOut = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID, matchData.unit, matchData.auraInstanceID,
                                  matchData.filter .. "|" .. nativeFilter)
    return ok and filteredOut == false
  end

  return NativeFilterString, PassesNativeFilter
end

if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

function Private.CreateNativeFilter(newAPI)
  local function AddTokens(tokens, selection, prefix)
    if type(selection) ~= "table" then
      return
    end
    for token, enabled in pairs(selection) do
      if enabled and Private.aura_native_filter_types[token] then
        tokens[#tokens + 1] = prefix .. token
      end
    end
  end

  local function NativeFilterString(trigger)
    if not (newAPI and C_UnitAuras.IsAuraFilteredOutByInstanceID
            and trigger.useNativeFilter and trigger.unit ~= "multi") then
      return nil
    end
    local tokens = {}
    AddTokens(tokens, trigger.nativeFilter, "")
    AddTokens(tokens, trigger.nativeFilterNot, "!")
    if #tokens == 0 then
      return nil
    end
    table.sort(tokens)
    return table.concat(tokens, "|")
  end

  local function PassesNativeFilter(matchData, nativeFilter)
    if not matchData.auraInstanceID then
      return false
    end
    local ok, filteredOut = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID, matchData.unit,
      matchData.auraInstanceID, matchData.filter .. "|" .. nativeFilter)
    return ok and not Private.IsSecret(filteredOut) and filteredOut == false
  end

  return NativeFilterString, PassesNativeFilter
end

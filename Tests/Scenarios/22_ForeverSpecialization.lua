-- ForeverSpecialization: the specialization load option follows the tree with the most points spent.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret = test.Secret
  local IsSpec = private.ExecEnv.IsForeverSpecialization
  local spent = {}
  C_SpecializationInfo = C_SpecializationInfo or {}
  C_SpecializationInfo.GetActiveSpecGroup = function() return 1 end
  C_SpecializationInfo.GetCombatConfigIDForSpecGroup = function(group) return group == 1 and 42 or nil end
  C_Traits = C_Traits or {}
  C_Traits.GetConfigInfo = function(configID) return configID == 42 and { treeIDs = { 7 } } or nil end
  C_Traits.GetGroupDisplayInfoByTreeID = function(treeID)
    assert(treeID == 7, "tree " .. tostring(treeID))
    return { { groupID = 100, orderIndex = 0 }, { groupID = 101, orderIndex = 1 }, { groupID = 102, orderIndex = 2 } }
  end
  C_Traits.GetGroupCurrencyInfo = function(configID, groupIDs)
    assert(configID == 42, "config " .. tostring(configID))
    assert(#groupIDs == 3, "groups asked: " .. #groupIDs)
    local result = { { traitNodeGroupID = 999, currencyInfos = { { spent = 50 } } } }
    for _, groupID in ipairs(groupIDs) do
      local points = spent[groupID - 99]
      if points ~= nil then
        result[#result + 1] = { traitNodeGroupID = groupID, currencyInfos = { { spent = points } } }
      end
    end
    return result
  end
  local function Matches()
    local result = {}
    for _, key in ipairs({ "WARRIOR_ARMS", "WARRIOR_FURY", "WARRIOR_PROTECTION", "MAGE_FIRE" }) do
      if IsSpec(key) then
        result[#result + 1] = key
      end
    end
    return table.concat(result, ",")
  end

  assert(Matches() == "", "no points: " .. Matches())
  spent = { nil, 13, nil }
  assert(Matches() == "WARRIOR_FURY", "13 points in the second tree: " .. Matches())
  spent = { 20, 5, 26 }
  assert(Matches() == "WARRIOR_PROTECTION", "most points in the third tree: " .. Matches())
  spent = { 20, 20, 0 }
  assert(Matches() == "WARRIOR_ARMS,WARRIOR_FURY", "tie: " .. Matches())
  spent = { 0, Secret.Wrap(13), 0 }
  assert(Matches() == "", "secret points: " .. Matches())
  C_Traits.GetGroupCurrencyInfo = function() error("blocked") end
  assert(Matches() == "", "API error: " .. Matches())
end

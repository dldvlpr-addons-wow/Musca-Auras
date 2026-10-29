local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- One icon per equipment set, grey when not worn; a click equips the set, out of combat only.
local pack = Utility.New("Equipment Sets", "muUtilEquipmentSetsV1", { anchorPoint = "BOTTOM", selfPoint = "BOTTOM",
  yOffset = 180 })

local UPDATE = [[function(allstates)
  for _, state in pairs(allstates) do
    state.show, state.changed = false, true
  end
  for _, setID in ipairs(C_EquipmentSet.GetEquipmentSetIDs() or {}) do
    local name, icon, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
    if name then
      allstates[setID] = { show = true, changed = true, name = name, icon = icon, setID = setID,
        equipped = equipped and true or false }
    end
  end
  return true
end]]

local trigger = { type = "custom", custom_type = "stateupdate", check = "event", custom = UPDATE,
  events = "EQUIPMENT_SETS_CHANGED PLAYER_EQUIPMENT_CHANGED EQUIPMENT_SWAP_FINISHED PLAYER_ENTERING_WORLD",
  customVariables = [[{ equipped = "bool" }]] }
local data = pack.Icon("Set", { trigger }, { size = { 36, 36 }, outOfCombat = true,
  subRegions = { Parts.Text("%n", "BOTTOM", 9) },
  conditions = { Parts.Condition("equipped", 0, "desaturate", true) } })
-- The region goes back to the pool when hidden: the click is set on show and taken off on hide.
data.actions.start = { do_custom = true, custom = [[local state = aura_env.state
local setID = state and state.setID
if not setID then return end
aura_env.region:EnableMouse(true)
aura_env.region:SetScript("OnMouseUp", function()
  if not InCombatLockdown() then C_EquipmentSet.UseEquipmentSet(setID) end
end)]] }
data.actions.finish = { do_custom = true, custom = [[aura_env.region:EnableMouse(false)
aura_env.region:SetScript("OnMouseUp", nil)]] }

return pack.Finish()

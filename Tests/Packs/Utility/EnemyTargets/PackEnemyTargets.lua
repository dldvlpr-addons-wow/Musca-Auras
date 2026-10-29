local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- The name of each hostile enemy's target, above its nameplate, in combat. The name can read secret: it is only
-- handed to the text, never compared. The anchor follows the default Blizzard nameplates.
local pack = Utility.New("Enemy Targets", "muUtilEnemyTargetsV1", { grow = "UP", useAnchorPerUnit = true,
  anchorPerUnit = "NAMEPLATE", anchorPoint = "TOP", selfPoint = "BOTTOM", yOffset = 40 })

local hostile = Parts.Generic({ type = "unit", event = "Unit Characteristics", unit = "nameplate", use_unit = true,
  use_hostility = true, hostility = "hostile" })
local data = pack.Text("Target", { hostile }, "%c", { inCombat = true, fontSize = 11, color = {1, 0.82, 0, 1} })
data.customText = [[function()
  local state = aura_env.state
  return state and state.unit and UnitName(state.unit .. "target")
end]]
data.customTextUpdate = "update"

return pack.Finish()

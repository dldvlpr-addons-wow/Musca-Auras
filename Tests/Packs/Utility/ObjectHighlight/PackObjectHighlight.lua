local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Turns on the game's interaction icons over nearby objects (herbs, veins, chests), out of combat. Nothing is shown
-- and the settings stay on after the pack is removed.
local pack = Utility.New("Object Highlight", "muUtilObjectHighlightV1", {})

local always = Parts.Generic({ type = "unit", event = "Conditions", use_alwaystrue = true })
local data = pack.Text("Interact Icons", { always }, "", { outOfCombat = true })
data.actions.start = { do_custom = true, custom = [[if not InCombatLockdown() then
  C_CVar.SetCVar("SoftTargetInteract", "3")
  C_CVar.SetCVar("SoftTargetIconGameObject", "1")
  C_CVar.SetCVar("SoftTargetInteractArc", "2")
end]] }

return pack.Finish()

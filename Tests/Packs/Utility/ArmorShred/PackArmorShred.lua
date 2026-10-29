local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Armor reduction under each enemy nameplate, from any caster: Sunder Armor with its stacks, Expose Armor. The
-- group is framed on the default Blizzard nameplates.
local pack = Utility.New("Armor Shred", "muUtilArmorShredV1", { flow = "CENTER_HORIZONTAL",
  blizzardFlowFrames = "NAMEPLATE", anchorPoint = "BOTTOM", selfPoint = "TOP", yOffset = -2 })

pack.Icon("Sunder Armor", { Utility.AnyCaster({ 7386, 7405, 8380, 11596, 11597 }, "showOnActive", "nameplate",
  "HARMFUL") }, { size = { 20, 20 }, countdown = true, subRegions = { Parts.Text("%s", "INNER_BOTTOMRIGHT", 10) } })
pack.Icon("Expose Armor", { Utility.AnyCaster({ 8647, 8649, 8650, 11197, 11198 }, "showOnActive", "nameplate",
  "HARMFUL") }, { size = { 20, 20 }, countdown = true })

return pack.Finish()

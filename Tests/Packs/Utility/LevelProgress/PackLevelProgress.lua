local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Experience bar below level 60, with the rested experience as an overlay.
local pack = Utility.New("Level Progress", "muUtilLevelProgressV1", { anchorPoint = "BOTTOM", selfPoint = "BOTTOM",
  yOffset = 130 })

local experience = Parts.Generic({ type = "unit", event = "Experience", use_level = true, level = { "60" },
  level_operator = { "<" }, use_showRested = true })
local level, percent = Parts.Text("Level %level", "INNER_LEFT", 11), Parts.Text("%percentXP%", "INNER_RIGHT", 11)
percent.text_text_format_percentXP_format, percent.text_text_format_percentXP_decimal_precision = "Number", 1
local data = pack.Add("Experience", "aurabar", { experience },
  { subRegions = { { type = "subbackground" }, { type = "subforeground" }, level, percent } })
data.width, data.height = 300, 14
data.barColor, data.backgroundColor, data.overlays = {0.58, 0, 0.55, 1}, {0, 0, 0, 0.5}, { {0, 0.4, 1, 0.6} }
data.texture, data.orientation, data.icon = "Blizzard", "HORIZONTAL", false

return pack.Finish()

local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Your threat percent above each enemy nameplate, in combat, coloured by your threat status. The anchor follows the
-- default Blizzard nameplates; an addon that replaces them hides the anchor.
local pack = Utility.New("Nameplate Aggro", "muUtilNameplateAggroV1", { grow = "UP", useAnchorPerUnit = true,
  anchorPerUnit = "NAMEPLATE", anchorPoint = "TOP", selfPoint = "BOTTOM", yOffset = 2 })

local function Status(value, color)
  return Parts.Condition("status", value, "color", color, "==")
end

local threat = Parts.Generic({ type = "unit", event = "Threat Situation", unit = "nameplate", use_unit = true,
  use_threatpct = true, threatpct = { "0" }, threatpct_operator = { ">" } })
local data = pack.Text("Threat", { threat }, "%threatpct", { inCombat = true, fontSize = 13,
  color = {0.7, 0.7, 0.7, 1}, conditions = {
    Status(1, {1, 1, 0.47, 1}), Status(2, {1, 0.6, 0, 1}), Status(3, {1, 0, 0, 1}),
  } })
data.displayText_format_threatpct_format, data.displayText_format_threatpct_decimal_precision = "Number", 0

return pack.Finish()

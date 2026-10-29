local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Your main stats in one panel, out of combat: the game keeps them secret in combat.
local LINES = {
  { "Strength", "strength" }, { "Agility", "agility" }, { "Stamina", "stamina" }, { "Intellect", "intellect" },
  { "Spirit", "spirit" }, { "Attack Power", "attackpower" }, { "Spell Power", "spellpower" },
  { "Crit", "criticalpercent", "%" }, { "Dodge", "dodgepercent", "%" }, { "Armor", "armorrating" },
}

local pack = Utility.New("Character Stats", "muUtilCharacterStatsV1", { anchorPoint = "LEFT", selfPoint = "LEFT",
  xOffset = 20 })

local text = {}
for index, line in ipairs(LINES) do text[index] = line[1] .. ": %" .. line[2] .. (line[3] and "%%" or "") end
local stats = pack.Text("Stats", { Parts.Generic({ type = "unit", event = "Character Stats" }) }, table.concat(text, "\n"),
  { fontSize = 12, outOfCombat = true })
stats.justify = "LEFT"
for _, line in ipairs(LINES) do
  stats["displayText_format_" .. line[2] .. "_format"] = "Number"
  stats["displayText_format_" .. line[2] .. "_decimal_precision"] = line[3] and 1 or 0
end

return pack.Finish()

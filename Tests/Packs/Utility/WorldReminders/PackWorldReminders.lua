local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Out of combat reminders: the zone buffs of the Leyline area missing or fading, and the herb and mineral tracking
-- off while the spell is known.
local LEYLINE_ZONE = "2521"
local FADING = 180

local pack = Utility.New("World Reminders", "muUtilWorldRemindersV1", { yOffset = 240 })

local function Options(text, load)
  local options = { size = { 36, 36 }, countdown = true, outOfCombat = true, subRegions = { Parts.Text(text, "BOTTOM", 10) } }
  for key, value in pairs(load) do options[key] = value end
  return options
end

pack.Icon("Blessing of Zephras", { Utility.AnyCaster({ 1258510 }, "showOnMissing") },
  Options("+40%%", { zone = LEYLINE_ZONE }))
pack.Icon("Energized", { Utility.AnyCaster({ 1270842 }, "showOnMissing") }, Options("Leyline", { zone = LEYLINE_ZONE }))
local fading = Utility.AnyCaster({ 1270842 }, "showOnActive")
fading.secretUseRem, fading.secretRemOperator, fading.secretRem = true, "<", FADING
pack.Icon("Energized (Fading)", { fading }, Options("Leyline", { zone = LEYLINE_ZONE }))
pack.Icon("Find Minerals", { Parts.AuraTrigger({ 2580 }, "showOnMissing") }, Options("Minerals", { known = 2580 }))
pack.Icon("Find Herbs", { Parts.AuraTrigger({ 2383 }, "showOnMissing") }, Options("Herbs", { known = 2383 }))

return pack.Finish()

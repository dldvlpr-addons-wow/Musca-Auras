local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Flask and food before the pull, in a group, out of combat and away from rest: missing, or fading within two
-- minutes.
local FADING = 120
local CONSUMABLES = {
  { "Flask", { 17624, 17626, 17627, 17628, 17629, 1293740, 1293741, 1293742, 1293743 } },
  { "Food", { 19705, 18194, 22730, 18192, 15852, 18125, 18141, 25661, 24799 } },
}

-- A dynamic group, not a Modern Aura Group: the remaining time condition of the Fading auras is not available
-- inside a Modern Aura Group yet, so each aura keeps a fixed slot.
local pack = Utility.New("Pre-Pull Check", "muUtilPrePullCheckV1", { yOffset = 160 })

local function Options(text)
  return { size = { 40, 40 }, countdown = true, outOfCombat = true, inGroup = true, notResting = true,
    subRegions = { Parts.Text(text, "BOTTOM", 10) } }
end

for _, consumable in ipairs(CONSUMABLES) do
  local name, ids = consumable[1], consumable[2]
  pack.Icon("Missing " .. name, { Utility.AnyCaster(ids, "showOnMissing") }, Options("No " .. name))
  -- The native remaining time filter needs a single icon on an active aura.
  local fading = Utility.AnyCaster(ids, "showOnActive")
  fading.secretUseRem, fading.secretRemOperator, fading.secretRem = true, "<", FADING
  pack.Icon("Fading " .. name, { fading }, Options("Fading"))
end

return pack.Finish()

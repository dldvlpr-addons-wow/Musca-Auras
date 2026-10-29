local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Raid debuffs on the target, in combat, from any caster: a missing debuff stays grey. Stacking debuffs show their
-- count.
local DEBUFFS = {
  { "Sunder Armor", { 7386, 7405, 8380, 11596, 11597 }, stacks = true },
  { "Expose Armor", { 8647, 8649, 8650, 11197, 11198 } },
  { "Faerie Fire", { 770, 778, 9749, 9907 } },
  { "Curse of Recklessness", { 704, 7658, 7659, 11717 } },
  { "Curse of the Elements", { 440892, 1311676, 1311677, 1311680 } },
  { "Demoralize", { 1160, 6190, 11554, 11555, 11556, 99, 1735, 9490, 9747, 9898 } },
  { "Thunder Clap", { 6343, 8198, 8204, 8205, 11580, 11581 } },
  { "Fire Vulnerability", { 22959 }, stacks = true },
  { "Winter's Chill", { 12579 }, stacks = true },
  { "Judgement of Light", { 20185, 20344, 20345, 20346 } },
  { "Judgement of Wisdom", { 20186, 20354, 20355 } },
  { "Insect Swarm", { 5570, 24974, 24975, 24976, 24977 } },
  { "Scorpid Sting", { 3043 } },
}

local pack = Utility.New("Target Debuffs", "muUtilTargetDebuffsV1", { grow = "GRID", gridType = "HD", gridWidth = 7,
  rowSpace = 2, columnSpace = 2, selfPoint = "TOP", useLimit = false, xOffset = 260, yOffset = -60 })

for _, debuff in ipairs(DEBUFFS) do
  pack.Icon(debuff[1], { Utility.AnyCaster(debuff[2], "showAlways", "target", "HARMFUL") },
    { size = { 26, 26 }, missing = true, countdown = true, inCombat = true,
      subRegions = debuff.stacks and { Parts.Text("%s", "INNER_BOTTOMRIGHT", 11) } or nil })
end

return pack.Finish()

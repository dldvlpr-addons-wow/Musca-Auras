local Pack = dofile("Tests/Packs/PackBuilder.lua")

local reminders = {
  { name = "main-hand poison", enchant = "main", known = 8681 },
  { name = "off-hand poison", enchant = "off", offhand = true, known = 8681 },
}
-- Poison stock in the bags, item and recipe of each rank (ItemSparse and SpellEffect, DB2 build 70532). A rank
-- loads only while the next recipe is unknown: one reminder per poison, for the highest rank known.
local poisonRanks = {
  { { "Instant Poison", 6947, 8681 }, { "Instant Poison II", 6949, 8687 }, { "Instant Poison III", 6950, 8691 },
    { "Instant Poison IV", 8926, 11341 }, { "Instant Poison V", 8927, 11342 }, { "Instant Poison VI", 8928, 11343 } },
  { { "Deadly Poison", 2892, 2835 }, { "Deadly Poison II", 2893, 2837 }, { "Deadly Poison III", 8984, 11357 },
    { "Deadly Poison IV", 8985, 11358 }, { "Deadly Poison V", 20844, 25347 } },
}
for _, ranks in ipairs(poisonRanks) do
  for index, rank in ipairs(ranks) do
    local nextRank = ranks[index + 1]
    reminders[#reminders + 1] = { name = rank[1], item = rank[2], below = 5, known = rank[3],
      unknown = nextRank and nextRank[3] }
  end
end

return Pack.Build({
  class = "ROGUE", name = "Rogue", prefix = "mcRogueV1",
  rotation = {
    { name = "Sinister Strike", spell = 1752 },
    { name = "Backstab", spell = 53 },
    { name = "Mutilate", spell = 1310707 },
    { name = "Hemorrhage", spell = 16511 },
    { name = "Ambush", spell = 8676 },
    { name = "Eviscerate", spell = 2098 },
    { name = "Ghostly Strike", spell = 14278 },
  },
  cooldowns = {
    { name = "Kick", spell = 1766 },
    { name = "Blind", spell = 2094 },
    { name = "Feint", spell = 1966 },
    { name = "Kidney Shot", spell = 408 },
    { name = "Gouge", spell = 1776 },
    { name = "Vanish (cooldown)", spell = 1856 },
    { name = "Sprint (cooldown)", spell = 2983 },
    { name = "Evasion (cooldown)", spell = 5277 },
    { name = "Adrenaline Rush (cooldown)", spell = 13750 },
    { name = "Blade Flurry (cooldown)", spell = 13877 },
    { name = "Cold Blood (cooldown)", spell = 14177 },
    { name = "Preparation", spell = 14185 },
    { name = "Premeditation (cooldown)", spell = 14183 },
    { name = "Distract", spell = 1725 },
    { name = "Stealth (cooldown)", spell = 1784 },
    { name = "Riposte (cooldown)", spell = 14251 },
  },
  procs = {
    { name = "Riposte", usable = 14251 },
  },
  -- Evasion up is in the Defensives icon, its cooldown above.
  defensives = { 5277 },
  buffs = {
    { name = "Slice and Dice", aura = { 5171, 6774 }, warn = 3 },
    { name = "Blade Flurry", aura = { 13877 }, known = 13877 },
    { name = "Adrenaline Rush", aura = { 13750 }, known = 13750 },
    { name = "Cold Blood", aura = { 14177 }, known = 14177 },
    { name = "Premeditation", aura = { 14183 }, known = 14183 },
    { name = "Sprint", aura = { 2983, 8696, 11305 } },
    { name = "Stealth", aura = { 1784, 1785, 1786, 1787 } },
    { name = "Vanish", aura = { 1856, 1857, 11327, 11329 } },
    { name = "Venom", aura = { 1310703 }, known = 1310703 },
    { name = "Remorseless Attacks", aura = { 14143 }, known = 14144, flash = 2 },
  },
  debuffs = {
    { name = "Rupture", aura = { 1943, 8639, 8640, 11273, 11274, 11275 }, dot = true },
    { name = "Garrote", aura = { 703, 8631, 8632, 8633, 11289, 11290 } },
    { name = "Expose Armor", aura = { 8647, 8649, 8650, 11197, 11198 } },
    { name = "Kidney Shot", aura = { 408, 8643 } },
    { name = "Cheap Shot", aura = { 1833 } },
    { name = "Gouge", aura = { 1776, 1777, 8629, 11285, 11286 } },
    { name = "Blind", aura = { 2094 } },
    { name = "Sap", aura = { 6770, 2070, 11297 } },
    { name = "Hemorrhage", aura = { 16511 }, known = 16511 },
    { name = "Riposte", aura = { 14251 }, known = 14251 },
    { name = "Deadly Poison", aura = { 2818, 2819, 11353, 11354, 25349, 434312, 434313, 434314, 434315, 434316 } },
    { name = "Wound Poison", aura = { 13218, 13222, 13223, 13224 } },
    { name = "Crippling Poison", aura = { 3409, 25809, 11201 } },
    { name = "Mind-numbing Poison", aura = { 5760, 25810, 8692, 11398 } },
  },
  enchants = { "main", "off" },
  swing = { "main", "off" },
  power = { { label = "Energy", type = 3 }, { label = "Combo Points", type = 4, segments = 5 } },
  castBar = true,
  meleeRange = { { name = "Sinister Strike", spell = 1752 } },
  reminders = reminders,
})

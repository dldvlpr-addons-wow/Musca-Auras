local Pack = dofile("Tests/Packs/PackBuilder.lua")

local armor = { 687, 696, 706, 1086, 11733, 11734, 11735 }
local corruption = { 172, 6222, 6223, 7648, 11671, 11672, 25311 }
local immolate = { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 }
local agony = { 980, 1014, 6217, 11711, 11712, 11713 }
local elements = { 440892, 1311676, 1311677, 1311680 }

return Pack.Build({
  class = "WARLOCK", name = "Warlock", prefix = "mcLockV1",
  rotation = {
    { name = "Shadowburn", spell = 17877 },
    { name = "Conflagrate", spell = 1293817 },
    { name = "Soul Fire", spell = 6353 },
    { name = "Death Coil", spell = 6789 },
  },
  cooldowns = {
    { name = "Howl of Terror", spell = 5484 },
    { name = "Fel Domination", spell = 18708 },
    { name = "Amplify Curse", spell = 18288 },
    { name = "Bane of Doom", spell = 603 },
    { name = "Shadow Ward", spell = 6229 },
  },
  buffs = {
    { name = "Shadow Trance", aura = { 17941 } },
    { name = "Demon Armor", aura = armor },
    { name = "Shadow Ward (active)", aura = { 6229, 11739, 11740, 28610 }, known = 6229 },
    { name = "Soul Link", aura = { 19028 }, known = 19028 },
    { name = "Amplify Curse (active)", aura = { 18288 }, known = 18288 },
  },
  debuffs = {
    { name = "Corruption", aura = corruption, dot = true },
    { name = "Immolate", aura = immolate, dot = true },
    { name = "Bane of Agony", aura = agony, dot = true },
    { name = "Bane of Doom", aura = { 603 }, known = 603 },
    { name = "Curse of the Elements", aura = elements },
    { name = "Curse of Recklessness", aura = { 704, 7658, 7659, 11717 } },
    { name = "Curse of Weakness", aura = { 702, 1108, 6205, 7646, 11707, 11708 } },
    { name = "Curse of Tongues", aura = { 1714, 11719 } },
    { name = "Siphon Life", aura = { 18265, 18879, 18880, 18881 }, known = 18265, dot = true },
    { name = "Shadow Vulnerability", aura = { 17794 } },
    { name = "Fear", aura = { 5782, 6213, 6215 } },
  },
  power = { { label = "Mana", type = 0 } },
  pet = true,
  fiveSecondRule = { 686, 348, 172, 980, 5676, 412758, 689, 1120, 5782, 6353, 5740, 1949 },
  reminders = {
    { name = "Demon Armor", aura = armor },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

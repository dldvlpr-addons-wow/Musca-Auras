local Pack = dofile("Tests/Packs/PackBuilder.lua")

local armor = { 687, 696, 706, 1086, 11733, 11734, 11735 }
local corruption = { 172, 6222, 6223, 7648, 11671, 11672, 25311 }
local immolate = { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 }
local agony = { 980, 1014, 6217, 11711, 11712, 11713 }
local sacrifice = { 7812, 19438, 19440, 19441, 19442, 19443 }
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
    { name = "Inferno", spell = 1122 },
    -- Pet abilities: they load only when the matching pet is out (the pet spells count as known).
    { name = "Spell Lock", spell = 19244 },
    { name = "Seduction", spell = 6358 },
    { name = "Suffering", spell = 17735 },
  },
  buffs = {
    { name = "Shadow Trance", aura = { 17941 }, sound = true },
    { name = "Demon Armor", aura = armor },
    { name = "Soul Link", aura = { 25228, 19028 }, known = 19028 },
    { name = "Sacrifice", aura = sacrifice, known = 697 },
    { name = "Demonic Sacrifice", aura = { 18789, 18790, 18791, 18792 }, known = 18788 },
    { name = "Decimation", aura = { 440873 }, flash = 2, sound = true },
    { name = "Fel Domination (active)", aura = { 18708 }, known = 18708 },
    { name = "Pyroclasm", aura = { 1293803 }, known = 18096 },
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
    { name = "Fear", aura = { 5782, 6213, 6215 }, glow = true },
    { name = "Banish", aura = { 710, 18647 }, known = 710, glow = true },
    { name = "Bane of Havoc", aura = { 1225228 }, known = 1225228 },
    { name = "Death Coil", aura = { 6789, 17925, 17926 }, known = 6789 },
    { name = "Howl of Terror", aura = { 5484, 17928 }, known = 5484 },
    -- From any warlock's succubus, not only the player's.
    { name = "Seduction", aura = { 6358 }, anyCaster = true },
  },
  -- Shadow Ward up is in the Defensives icon, its cooldown above.
  defensives = { 6229, 11739, 11740, 28610 },
  power = { { label = "Mana", type = 0 } },
  pet = true,
  fiveSecondRule = { 686, 348, 172, 980, 5676, 412758, 689, 1120, 5782, 6353, 5740, 1949 },
  castBar = true,
  swing = { "ranged" },
  swingKnown = 5019,
  reminders = {
    { name = "Demon Armor", aura = armor, known = 687, fading = 300 },
    { name = "Pet", pet = true, known = 688, unknown = 18788 },
    { name = "Soul Link", aura = { 25228, 19028 }, known = 19028, needsPet = true },
    { name = "Soul Shard", item = 6265, below = 1, known = 1120, icon = true,
      texture = "Interface\\Icons\\INV_Misc_Gem_Amethyst_02" },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

local Pack = dofile("Tests/Packs/PackBuilder.lua")

local blessings = {
  19740, 19834, 19835, 19836, 19837, 19838, 25291,
  19742, 19850, 19852, 19853, 19854, 25290,
  20217,
  25782, 25916, 25894, 25918, 25898,
}
local paladinAuras = {
  465, 10290, 643, 10291, 1032, 10292, 10293,
  7294, 10298, 10299, 10300, 10301,
  19746,
}

return Pack.Build({
  class = "PALADIN", name = "Paladin", prefix = "mcPalaV1",
  procs = {
    { name = "Hammer of Wrath", usable = 24275 },
  },
  rotation = {
    { name = "Judgement", spell = 20271 },
    { name = "Holy Strike", spell = 679 },
    { name = "Hammer of the Righteous", spell = 407632 },
    { name = "Consecration", spell = 26573 },
    { name = "Exorcism", spell = 879 },
    { name = "Holy Shock", spell = 1311606 },
    { name = "Holy Shield", spell = 20925 },
  },
  cooldowns = {
    { name = "Hammer of Justice", spell = 853 },
    { name = "Divine Shield", spell = 642 },
    { name = "Divine Protection", spell = 498 },
    { name = "Lay on Hands", spell = 633 },
    { name = "Blessing of Protection", spell = 1022 },
    { name = "Blessing of Freedom", spell = 1044 },
    { name = "Divine Favor", spell = 20216 },
    { name = "Repentance", spell = 20066 },
  },
  buffs = {
    { name = "Seal of Righteousness", aura = { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 21084 } },
    { name = "Seal of the Crusader", aura = { 21082, 20162, 20305, 20306, 20307, 20308 } },
    { name = "Seal of Command", aura = { 20375, 20915, 20918, 20919, 20920, 20424 } },
    { name = "Seal of Wisdom", aura = { 20166, 20356, 20357 } },
    { name = "Seal of Light", aura = { 20165, 20347, 20348, 20349 } },
    { name = "Seal of Justice", aura = { 20164 } },
    { name = "Seal of Fury", aura = { 1311649, 1311656, 20163, 20419, 20421, 20422, 20423 } },
    { name = "Righteous Fury", aura = { 25780 } },
    { name = "Divine Favor (active)", aura = { 20216 }, known = 20216 },
    { name = "Holy Shield (active)", aura = { 20925, 20927, 20928 }, stacks = true, known = 20925 },
    { name = "Divine Shield (active)", aura = { 642, 1020 } },
    { name = "Vengeance", aura = { 20050 }, stacks = true, known = 20049 },
    { name = "Redoubt", aura = { 20128 }, known = 20127 },
  },
  debuffs = {
    { name = "Judgement of the Crusader", aura = { 21183, 20188, 20300, 20301, 20302, 20303 } },
    { name = "Judgement of Light", aura = { 20185, 20344, 20345, 20346 } },
    { name = "Judgement of Wisdom", aura = { 20186, 20354, 20355 } },
    { name = "Judgement of Justice", aura = { 20184 } },
    { name = "Hammer of Justice", aura = { 853, 5588, 5589, 10308 } },
  },
  power = { { label = "Mana", type = 0 } },
  swing = { "main" },
  fiveSecondRule = { 635, 19750, 1311606, 879, 26573, 24275, 20271, 20154, 21082, 20375, 20166, 20165, 20164 },
  reminders = {
    { name = "Blessing", aura = blessings },
    { name = "Paladin aura", aura = paladinAuras },
    { name = "Righteous Fury", aura = { 25780 }, known = 20925 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

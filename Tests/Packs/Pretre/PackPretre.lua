local Pack = dofile("Tests/Packs/PackBuilder.lua")

-- Shield on the target with its cooldown; on the player it is in Defensives.
local shield = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 }
local renew = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 }
local innerFire = { 588, 602, 1006, 7128, 10951, 10952 }
local fortitude = { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 }
local shadowWordPain = { 589, 594, 970, 992, 2767, 10892, 10893, 10894 }
local devouringPlague = { 2944, 19276, 19277, 19278, 19279, 19280 }
local divineSpirit = { 14752, 14818, 14819, 27841, 27681 }
local shadowProtection = { 976, 10957, 10958, 27683 }

return Pack.Build({
  class = "PRIEST", name = "Priest", prefix = "mcPrieV1",
  rotation = {
    { name = "Mind Blast", spell = 8092 },
    { name = "Shadow Word: Death", spell = 1309595 },
    { name = "Holy Fire", spell = 14914 },
    { name = "Penance", spell = 402174 },
    { name = "Prayer of Mending", spell = 401859 },
    { name = "Power Word: Shield", spell = 17, aura = shield, unit = "target" },
  },
  cooldowns = {
    { name = "Psychic Scream", spell = 8122 },
    { name = "Fade", spell = 586 },
    { name = "Inner Focus", spell = 14751 },
    { name = "Fear Ward", spell = 6346 },
    { name = "Shadowfiend", spell = 401977 },
    { name = "Silence", spell = 15487 },
    { name = "Power Infusion", spell = 10060 },
    { name = "Desperate Prayer", spell = 13908 },
    { name = "Elune's Grace", spell = 2651 },
    { name = "Feedback", spell = 13896 },
  },
  buffs = {
    { name = "Weakened Soul", aura = { 6788 }, kind = "HARMFUL", known = 17 },
    { name = "Renew", aura = renew },
    { name = "Inner Fire", aura = innerFire },
    { name = "Shadowform", aura = { 15473 }, known = 15473 },
    { name = "Inner Focus (active)", aura = { 14751 }, known = 14751 },
    { name = "Power Infusion (active)", aura = { 10060 } },
    { name = "Fear Ward (active)", aura = { 6346 } },
    { name = "Spirit Tap", aura = { 15271 } },
    { name = "Divine Spirit", aura = divineSpirit, known = 14752 },
    { name = "Holy Purpose", aura = { 1284536 }, flash = 2, sound = true },
    { name = "Shadow Protection", aura = shadowProtection, known = 976 },
    { name = "Shadowguard", aura = { 18137, 19308, 19309, 19310, 19311, 19312 }, known = 18137 },
    { name = "Touch of Weakness", aura = { 2652, 19261, 19262, 19264, 19265, 19266 }, known = 2652 },
  },
  debuffs = {
    { name = "Shadow Word: Pain", aura = shadowWordPain, dot = true },
    { name = "Vampiric Embrace", aura = { 15286 }, known = 15286 },
    { name = "Devouring Plague", aura = devouringPlague, dot = true },
    { name = "Shadow Weaving", aura = { 15258 } },
    { name = "Weakened Soul", aura = { 6788 }, known = 17, anyCaster = true },
    { name = "Silence", aura = { 15487 }, known = 15487 },
    { name = "Blackout", aura = { 15269 } },
    { name = "Psychic Scream", aura = { 8122, 8124, 10888, 10890 }, known = 8122 },
    { name = "Shackle Undead", aura = { 9484, 9485, 10955 }, known = 9484 },
  },
  power = { { label = "Mana", type = 0 } },
  fiveSecondRule = { 8092, 589, 585, 14914, 15407, 2061, 2060, 2054, 2050, 139, 17, 596 },
  castBar = true,
  swing = { "ranged" },
  swingKnown = 5019,
  reminders = {
    { name = "Power Word: Fortitude", aura = fortitude, known = 1243, fading = 300 },
    { name = "Divine Spirit", aura = divineSpirit, known = 14752, fading = 300 },
    { name = "Inner Fire", aura = innerFire, known = 588 },
    { name = "Shadowform", aura = { 15473 }, known = 15473, combat = "always" },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

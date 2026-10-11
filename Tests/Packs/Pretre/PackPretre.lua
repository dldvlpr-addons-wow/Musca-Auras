local Pack = dofile("Tests/Packs/PackBuilder.lua")

local shield = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 }
local renew = { 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 }
local innerFire = { 588, 602, 1006, 7128, 10951, 10952 }
local fortitude = { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 }
local shadowWordPain = { 589, 594, 970, 992, 2767, 10892, 10893, 10894 }
local devouringPlague = { 2944, 19276, 19277, 19278, 19279, 19280 }

return Pack.Build({
  class = "PRIEST", name = "Priest", prefix = "mcPrieV1",
  rotation = {
    { name = "Mind Blast", spell = 8092 },
    { name = "Shadow Word: Death", spell = 1309595 },
    { name = "Holy Fire", spell = 14914 },
    { name = "Penance", spell = 402174 },
    { name = "Prayer of Mending", spell = 401859 },
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
  },
  buffs = {
    { name = "Power Word: Shield", aura = shield },
    { name = "Renew", aura = renew },
    { name = "Inner Fire", aura = innerFire },
    { name = "Shadowform", aura = { 15473 }, known = 15473 },
    { name = "Inner Focus (active)", aura = { 14751 }, known = 14751 },
    { name = "Power Infusion (active)", aura = { 10060 } },
    { name = "Fear Ward (active)", aura = { 6346 } },
    { name = "Spirit Tap", aura = { 15271 } },
  },
  debuffs = {
    { name = "Shadow Word: Pain", aura = shadowWordPain },
    { name = "Vampiric Embrace", aura = { 15286 }, known = 15286 },
    { name = "Devouring Plague", aura = devouringPlague },
    { name = "Shadow Weaving", aura = { 15258 } },
  },
  power = { { label = "Mana", type = 0 } },
  fiveSecondRule = { 8092, 589, 585, 14914, 15407, 2061, 2060, 2054, 2050, 139, 17, 596 },
  reminders = {
    { name = "Power Word: Fortitude", aura = fortitude },
    { name = "Inner Fire", aura = innerFire },
    { name = "Shadowform", aura = { 15473 }, known = 15473 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

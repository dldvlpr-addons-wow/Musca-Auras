local Pack = dofile("Tests/Packs/PackBuilder.lua")

local moonfire = { 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 }
local insectSwarm = { 5570, 24974, 24975, 24976, 24977 }
local rejuvenation = { 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }
local regrowth = { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }
local markOfTheWild = { 1126, 5232, 6756, 5234, 8907, 9884, 9885 }
local natureGrasp = { 16689, 16810, 16811, 16812, 16813, 17329 }
local thorns = { 467, 782, 1075, 8914, 9756, 9910 }

return Pack.Build({
  class = "DRUID", name = "Druid", prefix = "mcDruiV1",
  rotation = {
    { name = "Bash", spell = 5211, gate = 1 },
    { name = "Growl", spell = 6795, gate = 1 },
    { name = "Swiftmend", spell = 18562, gate = 0 },
  },
  cooldowns = {
    { name = "Cower", spell = 8998, gate = 3 },
    { name = "Dash", spell = 1850, gate = 3, aura = { 1850, 9821 } },
    { name = "Enrage", spell = 5229, gate = 1, aura = { 5229 } },
    { name = "Frenzied Regeneration", spell = 22842, gate = 1, aura = { 22842 } },
    { name = "Challenging Roar", spell = 5209, gate = 1 },
    { name = "Feral Charge", spell = 1238122, gate = 1 },
    { name = "Hurricane", spell = 16914, gate = 0 },
    { name = "Nature's Swiftness", spell = 17116, gate = 0 },
    { name = "Innervate", spell = 29166, gate = 0 },
    { name = "Rebirth", spell = 20484, gate = 0 },
    { name = "Barkskin", spell = 22812, gate = 0 },
    { name = "Tranquility", spell = 740, gate = 0 },
    { name = "Wild Growth", spell = 408120, gate = 0 },
    { name = "Nature's Grasp (cooldown)", spell = 16689, gate = 0 },
  },
  procs = {
    { name = "Maul", queued = 6807, gate = 1 },
  },
  buffs = {
    { name = "Clearcasting", aura = { 16870 }, known = 16864 },
    { name = "Nature's Grace", aura = { 16886 }, known = 16880 },
    { name = "Enrage (active)", aura = { 5229 }, foreverAurasOnly = true },
    { name = "Frenzied Regeneration (active)", aura = { 22842 }, foreverAurasOnly = true },
    { name = "Barkskin (active)", aura = { 22812 } },
    { name = "Innervate (active)", aura = { 29166 } },
    { name = "Nature's Swiftness (active)", aura = { 17116 } },
    { name = "Dash (active)", aura = { 1850, 9821 }, foreverAurasOnly = true },
    { name = "Nature's Grasp", aura = natureGrasp, known = 16689 },
    { name = "Prowl", aura = { 5215, 6783, 9913 }, known = 5215, gate = 3 },
    { name = "Rejuvenation", aura = rejuvenation },
    { name = "Regrowth", aura = regrowth },
  },
  debuffs = {
    { name = "Moonfire", aura = moonfire, dot = true },
    { name = "Insect Swarm", aura = insectSwarm, known = 5570, dot = true },
    { name = "Rake", aura = { 1822, 1823, 1824, 9904 }, dot = true },
    { name = "Rip", aura = { 1079, 9492, 9493, 9752, 9894, 9896 }, dot = true },
    { name = "Lacerate", aura = { 414644, 1235826, 1235827 }, stacks = true, gate = 1, known = 414644 },
    { name = "Pounce", aura = { 9007, 9824, 9826 } },
    { name = "Faerie Fire", aura = { 770, 778, 9749, 9907 } },
    { name = "Demoralizing Roar", aura = { 99, 1735, 9490, 9747, 9898 } },
    { name = "Entangling Roots", aura = { 339, 1062, 5195, 5196, 9852, 9853 } },
    { name = "Hibernate", aura = { 2637, 18657, 18658 } },
  },
  power = {
    { label = "Energy", type = 3, gate = 3 },
    { label = "Combo Points", type = 4, gate = 3, segments = 5 },
    { label = "Rage", type = 1, gate = 1 },
    { label = "Mana", type = 0 },
  },
  fiveSecondRule = { 5176, 2912, 8921, 5570, 5185, 8936, 774 },
  castBar = true,
  meleeRange = { { name = "Claw", spell = 1082, gate = 3 }, { name = "Maul", spell = 6807, gate = 1 } },
  reminders = {
    { name = "Mark of the Wild", aura = markOfTheWild, known = 1126 },
    { name = "Thorns", aura = thorns, known = 467 },
    { name = "Moonkin Form", aura = { 24858 }, known = 24858, gate = 0 },
    { name = "Omen of Clarity", aura = { 16864 }, known = 16864 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

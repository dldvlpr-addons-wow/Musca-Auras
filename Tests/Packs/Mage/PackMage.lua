local Pack = dofile("Tests/Packs/PackBuilder.lua")

local arcaneIntellect = { 1459, 1460, 1461, 10156, 10157, 23028 }
local armors = { 168, 7300, 7301, 7302, 7320, 10219, 10220, 6117, 22782, 22783 }

return Pack.Build({
  class = "MAGE", name = "Mage", prefix = "mcMageV1",
  rotation = {
    { name = "Fire Blast", spell = 2136 },
    { name = "Frost Nova", spell = 122 },
    { name = "Cone of Cold", spell = 120 },
    { name = "Blast Wave", spell = 11113 },
    { name = "Arcane Blast", spell = 400574 },
  },
  cooldowns = {
    { name = "Counterspell", spell = 2139 },
    { name = "Blink", spell = 1953 },
    { name = "Ice Block", spell = 11958 },
    { name = "Evocation", spell = 12051 },
    { name = "Arcane Power", spell = 12042 },
    { name = "Combustion", spell = 11129 },
    { name = "Presence of Mind", spell = 12043 },
    { name = "Cold Snap", spell = 12472 },
    { name = "Ice Barrier", spell = 11426 },
    { name = "Fire Ward", spell = 543 },
    { name = "Frost Ward", spell = 6143 },
  },
  -- Shields up are in the Defensives icon, their cooldowns above: Ice Barrier, Fire Ward, Frost Ward, Mana Shield.
  defensives = { 11426, 13031, 13032, 13033, 543, 8457, 8458, 10223, 10225, 6143, 8461, 8462, 10177, 28609,
    1463, 8494, 8495, 10191, 10192, 10193 },
  buffs = {
    { name = "Clearcasting", aura = { 12536 }, sound = true },
    { name = "Missile Barrage", aura = { 400589 }, flash = 2, sound = true },
    { name = "Fingers of Frost", aura = { 400670 }, stacks = true, flash = 2 },
    { name = "Heating Up", aura = { 400625 }, stacks = true },
    { name = "Arcane Power (active)", aura = { 12042 } },
    { name = "Combustion (active)", aura = { 28682 } },
    { name = "Presence of Mind (active)", aura = { 12043 } },
    { name = "Ice Block (active)", aura = { 11958 } },
    { name = "Slow Fall", aura = { 130 }, known = 130 },
    { name = "Armor", aura = armors },
    { name = "Arcane Intellect", aura = arcaneIntellect },
  },
  debuffs = {
    { name = "Winter's Chill", aura = { 12579 }, known = 11180, dot = true },
    { name = "Fire Vulnerability", aura = { 22959 }, known = 11095, stacks = true, dot = true },
    { name = "Ignite", aura = { 3261, 412538, 1234540 }, known = 11119 },
    { name = "Pyroblast", aura = { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 }, known = 11366 },
    { name = "Frostbolt", aura = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 } },
    { name = "Polymorph", aura = { 118, 12824, 12825, 12826, 28272, 28271, 28270 } },
  },
  -- Arcane Blast stacks (debuff 400573, 4 stacks, 15 s in DB2 build 70532) counted from the casts: each rank adds
  -- one. The aura has no proc charge in that build, so no other spell spends them: they only expire.
  segments = { name = "Arcane Blast", count = 4, known = 400574, casts = {
    add = { 400574, 1239696, 1239697, 1239699, 1239700 },
    duration = 15 } },
  power = { { label = "Mana", type = 0 } },
  fiveSecondRule = { 116, 133, 5143, 2948, 2136, 122, 120, 1449, 10, 2120, 11366, 118, 400574 },
  castBar = true,
  swing = { "ranged" },
  swingKnown = 5019,
  reminders = {
    { name = "Arcane Intellect", aura = arcaneIntellect, known = 1459, fading = 300 },
    { name = "armor", aura = armors, known = 168, fading = 300 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

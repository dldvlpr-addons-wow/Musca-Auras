local Pack = dofile("Tests/Packs/PackBuilder.lua")

return Pack.Build({
  class = "SHAMAN", name = "Layout test", prefix = "mcEssai",
  rotation = {
    { name = "Earth Shock", spell = 8042 },
    { name = "Flame Shock", spell = 8050, aura = { 8050 }, unit = "target", kind = "HARMFUL", warn = 3 },
    { name = "Frost Shock", spell = 8056, unknown = 17364 },
    { name = "Stormstrike", spell = 17364, form = 1 },
    { name = "Chain Lightning", spell = 421, level = 32 },
    { name = "Lightning Bolt", spell = 403 },
    { name = "Purge", spell = 370 },
    { name = "Healing Wave", spell = 331 },
    { name = "Lesser Healing Wave", spell = 8004 },
  },
  cooldowns = {
    { name = "Nature's Swiftness", spell = 16188, aura = { 16188 } },
  },
  buffs = {
    { name = "Lightning Shield", aura = { 324 }, stacks = true, warn = 30 },
    { name = "Pet shield", aura = { 324 }, unit = "pet" },
  },
  debuffs = { { name = "Flame Shock", aura = { 8050 } } },
  totems = true,
  enchants = { "main" },
  power = { { label = "Mana", type = 0 } },
  swing = { "main" },
  fiveSecondRule = { 403, 421, 331, 8004 },
  reminders = {
    { name = "Lightning Shield", aura = { 324 }, known = 324, icon = true },
    { name = "weapon enchant", enchant = "main", known = 8017, icon = true, texture = "Interface\\Icons\\Spell_Nature_RockBiter" },
    { name = "Ankh", item = 17030, below = 1, known = 20608, icon = true, texture = "Interface\\Icons\\INV_Jewelry_Talisman_06" },
    { name = "Lightning Shield text", aura = { 324 }, known = 324 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

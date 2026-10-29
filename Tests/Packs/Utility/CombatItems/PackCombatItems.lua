local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Combat consumables in your bags, in combat, with their cooldown and count. An item shows only while you carry it.
local ITEMS = {
  { "Major Healing Potion", 13446 }, { "Major Mana Potion", 13444 }, { "Mighty Rage Potion", 13442 },
  { "Major Healthstone", 9421 }, { "Major Healthstone (1)", 19012 }, { "Major Healthstone (2)", 19013 },
  { "Demonic Rune", 12662 }, { "Dark Rune", 20520 }, { "Free Action Potion", 5634 },
  { "Limited Invulnerability Potion", 3387 }, { "Greater Fire Protection Potion", 13457 },
  { "Greater Frost Protection Potion", 13456 }, { "Greater Shadow Protection Potion", 13459 },
  { "Greater Nature Protection Potion", 13458 }, { "Greater Arcane Protection Potion", 13461 },
  { "Thistle Tea", 7676 }, { "Mana Agate", 5514 }, { "Mana Jade", 5513 }, { "Mana Citrine", 8007 },
  { "Mana Ruby", 8008 }, { "Goblin Sapper Charge", 10646 }, { "Dense Dynamite", 18641 }, { "Iron Grenade", 4390 },
  { "Thorium Grenade", 15993 },
}

local pack = Utility.New("Combat Items", "muUtilCombatItemsV1", { grow = "GRID", gridType = "HD", gridWidth = 8,
  rowSpace = 2, columnSpace = 2, selfPoint = "TOP", useLimit = false, yOffset = -200 })

for _, item in ipairs(ITEMS) do
  local cooldown = Parts.Generic({ type = "item", event = "Cooldown Progress (Item)", itemName = item[2],
    genericShowOn = "showAlways", use_genericShowOn = true })
  local carried = Parts.Generic({ type = "item", event = "Item Count", itemName = item[2], use_exact_itemName = true,
    use_count = true, count = "0", count_operator = ">" })
  pack.Icon(item[1], { cooldown, carried }, { size = { 30, 30 }, countdown = true, inCombat = true, all = true,
    subRegions = { Parts.Text("%2.stacks", "INNER_BOTTOMRIGHT", 11) } })
end

return pack.Finish()

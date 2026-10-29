local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Mage only, out of combat: the conjured water and food in your bags with their count, to hand them out.
local ITEMS = {
  { "Conjured Crystal Water", 8079 }, { "Conjured Sparkling Water", 8078 }, { "Conjured Mineral Water", 8077 },
  { "Conjured Spring Water", 3772 }, { "Conjured Purified Water", 2136 }, { "Conjured Fresh Water", 2288 },
  { "Conjured Water", 5350 }, { "Conjured Cinnamon Roll", 22895 }, { "Conjured Sweet Roll", 8076 },
  { "Conjured Sourdough", 8075 }, { "Conjured Pumpernickel", 1487 }, { "Conjured Rye", 1114 },
  { "Conjured Bread", 1113 }, { "Conjured Muffin", 5349 },
}

local pack = Utility.New("Conjured Supplies", "muUtilConjuredSuppliesV1", { yOffset = -240 })

for _, item in ipairs(ITEMS) do
  pack.Icon(item[1], { Parts.Generic({ type = "item", event = "Item Count", itemName = item[2], use_exact_itemName = true,
    use_count = true, count = "0", count_operator = ">" }) }, { size = { 32, 32 }, outOfCombat = true, class = "MAGE",
    subRegions = { Parts.Text("%1.stacks", "INNER_BOTTOMRIGHT", 11) } })
end

return pack.Finish()

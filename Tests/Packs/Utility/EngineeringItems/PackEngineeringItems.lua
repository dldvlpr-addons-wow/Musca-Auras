local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Engineering items with a use effect, while equipped: grey with the countdown on cooldown, lit when ready.
local ITEMS = { { "Gnomish Cloaking Device", 4397 }, { "Gnomish Rocket Boots", 10724 }, { "Goblin Rocket Boots", 7189 } }

local pack = Utility.New("Engineering Items", "muUtilEngineeringItemsV1", { yOffset = -160 })

for _, item in ipairs(ITEMS) do
  local cooldown = Parts.Generic({ type = "item", event = "Cooldown Progress (Item)", itemName = item[2],
    genericShowOn = "showAlways", use_genericShowOn = true })
  local equipped = Parts.Generic({ type = "item", event = "Item Equipped", itemName = item[2] })
  pack.Icon(item[1], { cooldown, equipped }, { size = { 36, 36 }, countdown = true, all = true,
    conditions = { Parts.Condition("onCooldown", 1, "desaturate", true) } })
end

return pack.Finish()

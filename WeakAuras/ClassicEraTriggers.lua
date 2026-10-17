-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

if not WeakAuras.IsClassicEra() then return end

local L = WeakAuras.L
local ExecEnv = Private.ExecEnv

local PROJECTILE_ITEM_CLASS = 6
local GENERAL_BAG_FAMILY = 0

local function LastBag()
  return NUM_BAG_SLOTS or 4
end

function ExecEnv.GetCarriedAmmoCount()
  if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
    return 0
  end
  local carried = 0
  for bag = 0, LastBag() do
    for slot = 1, C_Container.GetContainerNumSlots(bag) or 0 do
      local item = C_Container.GetContainerItemInfo(bag, slot)
      if item and item.itemID and select(6, C_Item.GetItemInfoInstant(item.itemID)) == PROJECTILE_ITEM_CLASS then
        carried = carried + (item.stackCount or 0)
      end
    end
  end
  return carried
end

function ExecEnv.GetBagSpace(includeSpecialty)
  if not (C_Container and C_Container.GetContainerNumFreeSlots and C_Container.GetContainerNumSlots) then
    return 0, 0
  end
  local free, total = 0, 0
  for bag = 0, LastBag() do
    local bagFree, family = C_Container.GetContainerNumFreeSlots(bag)
    if Private.IsSecret(bagFree, family) then
      return nil, nil
    end
    if family == GENERAL_BAG_FAMILY or (includeSpecialty and family) then
      free = free + (bagFree or 0)
      total = total + (C_Container.GetContainerNumSlots(bag) or 0)
    end
  end
  return free, total
end

function ExecEnv.GetEquipmentDurability(slot)
  if not GetInventoryItemDurability then
    return 100, 100, 0
  end
  local first, last = INVSLOT_FIRST_EQUIPPED or 1, INVSLOT_LAST_EQUIPPED or 19
  if slot and slot >= first then
    first, last = slot, slot
  end
  local lowest, current, maximum, broken = 100, 0, 0, 0
  for inventorySlot = first, last do
    local now, most = GetInventoryItemDurability(inventorySlot)
    if Private.IsSecret(now, most) then
      return nil, nil, nil
    end
    if now and most and most > 0 then
      lowest = math.min(lowest, now / most * 100)
      current, maximum = current + now, maximum + most
      if now == 0 then
        broken = broken + 1
      end
    end
  end
  local overall = maximum > 0 and math.floor(current / maximum * 100) or 100
  return math.floor(lowest), overall, broken
end

function ExecEnv.GetActiveTracking(spellIDs)
  if not (C_Minimap and C_Minimap.GetNumTrackingTypes and C_Minimap.GetTrackingInfo) then
    return false
  end
  local anyTracking = spellIDs[1] == nil
  for index = 1, C_Minimap.GetNumTrackingTypes() or 0 do
    local info = C_Minimap.GetTrackingInfo(index)
    if info and info.active and (anyTracking or tIndexOf(spellIDs, info.spellID)) then
      return true, info.spellID, info.name, info.texture
    end
  end
  return false
end

local function Stored(name, init, extra)
  local arg = { name = name, init = init, hidden = true, store = true, test = "true" }
  for key, value in pairs(extra or {}) do
    arg[key] = value
  end
  return arg
end

local function Number(name, display)
  return { name = name, display = display, type = "number", init = name, store = true, conditionType = "number" }
end

local function Quoted(text)
  return string.format("%q", text)
end

local function SpellList(trigger)
  local ids = {}
  if trigger.use_trackingSpell then
    local spells = trigger.trackingSpell
    for _, value in ipairs(type(spells) == "table" and spells or { spells }) do
      local id = tonumber(value)
      if id then
        table.insert(ids, id)
      end
    end
  end
  return ids
end

local BAG_ICON = "Interface\\Icons\\INV_Misc_Bag_08"
local DURABILITY_ICON = "Interface\\Icons\\Trade_BlackSmithing"

local prototypes = {
  {
    category = "item",
    event = "Ammo",
    events = {
      events = { "BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED" },
      unit_events = { player = { "UNIT_INVENTORY_CHANGED" } },
    },
    force_events = "UNIT_INVENTORY_CHANGED",
    hasItemID = true,
    progressType = "static",
    GetNameAndIcon = function()
      return L["Ammo"], GetInventoryItemTexture("player", INVSLOT_AMMO)
    end,
    init = function()
      return [[
        local itemId = GetInventoryItemID("player", INVSLOT_AMMO)
        local count = itemId and GetInventoryItemCount("player", INVSLOT_AMMO) or 0
        local carried = Private.ExecEnv.GetCarriedAmmoCount()
      ]]
    end,
    args = {
      Number("count", L["Count"]),
      Number("carried", L["Total Carried"]),
      {
        name = "ammoItem",
        display = L["Ammo Item"],
        type = "item",
        multiEntry = { operator = "or" },
        test = "itemId == tonumber([[%s]])",
        only_exact = true,
      },
      Stored("stacks", "count"),
      Stored("value", "count"),
      Stored("total", "0"),
      Stored("progressType", "'static'"),
      Stored("itemId", "itemId", { display = L["ItemId"], conditionType = "number", operator_types = "only_equal" }),
      Stored("name", "itemId and C_Item.GetItemNameByID(itemId)"),
      Stored("icon", "GetInventoryItemTexture('player', INVSLOT_AMMO)"),
    },
  },
  {
    category = "item",
    event = "Bag Space",
    events = { events = { "BAG_UPDATE_DELAYED" } },
    force_events = "BAG_UPDATE_DELAYED",
    progressType = "static",
    GetNameAndIcon = function()
      return L["Bag Space"], BAG_ICON
    end,
    init = function(trigger)
      return string.format("local free, total = Private.ExecEnv.GetBagSpace(%s)\n",
        tostring(trigger.use_includeSpecialty and true or false))
    end,
    args = {
      { name = "includeSpecialty", display = L["Include Specialty Bags"], type = "toggle", test = "true" },
      Number("free", L["Free Slots"]),
      { name = "used", display = L["Used Slots"], type = "number", init = "free and total - free", store = true,
        conditionType = "number" },
      Stored("stacks", "free"),
      Stored("value", "free"),
      Stored("name", Quoted(L["Bag Space"])),
      Stored("icon", Quoted(BAG_ICON)),
      Stored("total", "total"),
      Stored("progressType", "'static'"),
    },
  },
  {
    category = "item",
    event = "Equipment Durability",
    events = { events = { "UPDATE_INVENTORY_DURABILITY", "PLAYER_EQUIPMENT_CHANGED" } },
    force_events = "UPDATE_INVENTORY_DURABILITY",
    progressType = "static",
    GetNameAndIcon = function()
      return L["Equipment Durability"], DURABILITY_ICON
    end,
    init = function(trigger)
      local slot = trigger.use_durabilitySlot and tonumber(trigger.durabilitySlot)
      local progress = trigger.durabilityProgress == "lowest" and "lowest" or "overall"
      return string.format("local lowest, overall, broken = Private.ExecEnv.GetEquipmentDurability(%s)\n"
        .. "local progress = %s\n", tostring(slot), progress)
    end,
    args = {
      { name = "durabilitySlot", display = L["Equipment Slot"], type = "select", values = "item_slot_types", test = "true" },
      { name = "durabilityProgress", display = L["Progress Value"], type = "select", values = "durability_progress_types",
        required = true, default = "overall", test = "true" },
      Number("lowest", L["Lowest Item Durability (%)"]),
      Number("overall", L["Overall Durability (%)"]),
      Number("broken", L["Broken Items"]),
      Stored("value", "progress"),
      Stored("name", Quoted(L["Equipment Durability"])),
      Stored("icon", Quoted(DURABILITY_ICON)),
      Stored("total", "100"),
      Stored("progressType", "'static'"),
    },
  },
  {
    category = "unit",
    event = "Role",
    events = { events = { "PLAYER_ROLES_ASSIGNED", "ROLE_CHANGED_INFORM", "GROUP_ROSTER_UPDATE" } },
    force_events = "PLAYER_ROLES_ASSIGNED",
    progressType = "none",
    init = function()
      return [[
        local role = UnitGroupRolesAssigned("player")
        if Private.ExecEnv.IsSecret(role) or role == "NONE" then
          role = nil
        end
      ]]
    end,
    args = {
      { name = "role", display = L["Role"], type = "select", values = "role_types", init = "role", store = true,
        conditionType = "select" },
      { hidden = true, test = "role ~= nil" },
    },
  },
  {
    category = "unit",
    event = "Tracking",
    events = { events = { "MINIMAP_UPDATE_TRACKING" } },
    force_events = "MINIMAP_UPDATE_TRACKING",
    progressType = "none",
    GetNameAndIcon = function(trigger)
      local spells = trigger.trackingSpell
      local spellID = trigger.use_trackingSpell and tonumber(type(spells) == "table" and spells[1] or spells)
      if spellID then
        return ExecEnv.GetSpellName(spellID), ExecEnv.GetSpellIcon(spellID)
      end
      return L["Tracking"], "Interface\\Minimap\\Tracking\\None"
    end,
    init = function(trigger)
      return string.format("local found, spellId, name, icon = Private.ExecEnv.GetActiveTracking({%s})\n"
        .. "local inverse = %s\n", table.concat(SpellList(trigger), ", "), tostring(trigger.use_inverse and true or false))
    end,
    args = {
      { name = "trackingSpell", display = L["Tracking Spell"], type = "spell", multiEntry = { operator = "or" },
        test = "true", only_exact = true },
      { name = "inverse", display = L["Inverse"], type = "toggle", test = "true" },
      { hidden = true, test = "found ~= inverse" },
      Stored("spellId", "spellId", { display = L["Spell ID"], conditionType = "number", operator_types = "only_equal" }),
      Stored("name", "name"),
      Stored("icon", "icon"),
    },
  },
}

for _, prototype in ipairs(prototypes) do
  local category, event = prototype.category, prototype.event
  prototype.category, prototype.event = nil, nil
  prototype.type = category
  prototype.name = L[event]
  prototype.internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD" }
  prototype.statesParameter = "one"
  prototype.automaticrequired = true
  Private.event_prototypes[event] = prototype
  Private.category_event_prototype[category][event] = prototype.name
end

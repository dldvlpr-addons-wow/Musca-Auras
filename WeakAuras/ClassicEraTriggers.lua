if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local L = WeakAuras.L
local tinsert = table.insert

if WeakAuras.IsClassicEra() then
  Private.ExecEnv.GetCarriedAmmoCount = function()
    local total = 0
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
      return total
    end
    for bag = 0, NUM_BAG_SLOTS or 4 do
      for slot = 1, C_Container.GetContainerNumSlots(bag) or 0 do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID)) == 6 then
          total = total + (info.stackCount or 0)
        end
      end
    end
    return total
  end

  Private.event_prototypes["Ammo"] = {
    type = "item",
    events = {
      ["events"] = {
        "BAG_UPDATE_DELAYED",
        "PLAYER_EQUIPMENT_CHANGED",
      },
      ["unit_events"] = {
        ["player"] = {"UNIT_INVENTORY_CHANGED"}
      }
    },
    internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD", },
    force_events = "UNIT_INVENTORY_CHANGED",
    name = L["Ammo"],
    init = function(trigger)
      return [[
        local itemId = GetInventoryItemID("player", INVSLOT_AMMO)
        local count = itemId and GetInventoryItemCount("player", INVSLOT_AMMO) or 0
        local carried = Private.ExecEnv.GetCarriedAmmoCount()
      ]]
    end,
    GetNameAndIcon = function(trigger)
      return L["Ammo"], GetInventoryItemTexture("player", INVSLOT_AMMO)
    end,
    statesParameter = "one",
    hasItemID = true,
    args = {
      {
        name = "count",
        display = L["Count"],
        type = "number",
        init = "count",
        store = true,
        conditionType = "number",
      },
      {
        name = "carried",
        display = L["Total Carried"],
        type = "number",
        init = "carried",
        store = true,
        conditionType = "number",
      },
      {
        name = "ammoItem",
        display = L["Ammo Item"],
        type = "item",
        multiEntry = {
          operator = "or"
        },
        test = "itemId == tonumber([[%s]])",
        only_exact = true,
      },
      {
        name = "stacks",
        init = "count",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "value",
        init = "count",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "total",
        init = 0,
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "progressType",
        init = "'static'",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "itemId",
        display = L["ItemId"],
        init = "itemId",
        hidden = true,
        store = true,
        test = "true",
        conditionType = "number",
        operator_types = "only_equal",
      },
      {
        name = "name",
        init = "itemId and C_Item.GetItemNameByID(itemId)",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "icon",
        init = "GetInventoryItemTexture('player', INVSLOT_AMMO)",
        hidden = true,
        store = true,
        test = "true",
      },
    },
    automaticrequired = true,
    progressType = "static"
  }

  Private.ExecEnv.GetBagSpace = function(includeSpecialty)
    local free, total = 0, 0
    if not (C_Container and C_Container.GetContainerNumFreeSlots and C_Container.GetContainerNumSlots) then
      return free, total
    end
    for bag = 0, NUM_BAG_SLOTS or 4 do
      local bagFree, bagFamily = C_Container.GetContainerNumFreeSlots(bag)
      if Private.IsSecret(bagFree, bagFamily) then
        return nil, nil
      end
      if bagFamily == 0 or (includeSpecialty and bagFamily) then
        free = free + (bagFree or 0)
        total = total + (C_Container.GetContainerNumSlots(bag) or 0)
      end
    end
    return free, total
  end

  Private.event_prototypes["Bag Space"] = {
    type = "item",
    events = {
      ["events"] = { "BAG_UPDATE_DELAYED" }
    },
    internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD", },
    force_events = "BAG_UPDATE_DELAYED",
    name = L["Bag Space"],
    init = function(trigger)
      return ([[
        local free, total = Private.ExecEnv.GetBagSpace(%s)
      ]]):format(trigger.use_includeSpecialty and "true" or "false")
    end,
    GetNameAndIcon = function(trigger)
      return L["Bag Space"], "Interface\\Icons\\INV_Misc_Bag_08"
    end,
    statesParameter = "one",
    args = {
      {
        name = "includeSpecialty",
        display = L["Include Specialty Bags"],
        type = "toggle",
        test = "true",
      },
      {
        name = "free",
        display = L["Free Slots"],
        type = "number",
        init = "free",
        store = true,
        conditionType = "number",
      },
      {
        name = "used",
        display = L["Used Slots"],
        type = "number",
        init = "free and total - free",
        store = true,
        conditionType = "number",
      },
      {
        name = "stacks",
        init = "free",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "value",
        init = "free",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "name",
        init = ("%q"):format(L["Bag Space"]),
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "icon",
        init = "'Interface\\\\Icons\\\\INV_Misc_Bag_08'",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "total",
        init = "total",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "progressType",
        init = "'static'",
        hidden = true,
        store = true,
        test = "true",
      },
    },
    automaticrequired = true,
    progressType = "static"
  }

  Private.ExecEnv.GetEquipmentDurability = function(slot)
    local lowest, broken, current, maximum = 100, 0, 0, 0
    if not GetInventoryItemDurability then
      return lowest, lowest, broken
    end
    if slot and slot < (INVSLOT_FIRST_EQUIPPED or 1) then
      slot = nil
    end
    for itemSlot = slot or INVSLOT_FIRST_EQUIPPED or 1, slot or INVSLOT_LAST_EQUIPPED or 19 do
      local itemCurrent, itemMaximum = GetInventoryItemDurability(itemSlot)
      if Private.IsSecret(itemCurrent, itemMaximum) then
        return nil, nil, nil
      end
      if itemCurrent and itemMaximum and itemMaximum > 0 then
        lowest = math.min(lowest, itemCurrent / itemMaximum * 100)
        current, maximum = current + itemCurrent, maximum + itemMaximum
        if itemCurrent == 0 then
          broken = broken + 1
        end
      end
    end
    return math.floor(lowest), maximum > 0 and math.floor(current / maximum * 100) or 100, broken
  end

  Private.event_prototypes["Equipment Durability"] = {
    type = "item",
    events = {
      ["events"] = { "UPDATE_INVENTORY_DURABILITY", "PLAYER_EQUIPMENT_CHANGED" }
    },
    internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD", },
    force_events = "UPDATE_INVENTORY_DURABILITY",
    name = L["Equipment Durability"],
    init = function(trigger)
      return ([[
        local lowest, overall, broken = Private.ExecEnv.GetEquipmentDurability(%s)
        local progress = %s
      ]]):format(trigger.use_durabilitySlot and tonumber(trigger.durabilitySlot) or "nil",
                 trigger.durabilityProgress == "lowest" and "lowest" or "overall")
    end,
    GetNameAndIcon = function(trigger)
      return L["Equipment Durability"], "Interface\\Icons\\Trade_BlackSmithing"
    end,
    statesParameter = "one",
    args = {
      {
        name = "durabilitySlot",
        display = L["Equipment Slot"],
        type = "select",
        values = "item_slot_types",
        test = "true",
      },
      {
        name = "durabilityProgress",
        display = L["Progress Value"],
        type = "select",
        values = "durability_progress_types",
        required = true,
        default = "overall",
        test = "true",
      },
      {
        name = "lowest",
        display = L["Lowest Item Durability (%)"],
        type = "number",
        init = "lowest",
        store = true,
        conditionType = "number",
      },
      {
        name = "overall",
        display = L["Overall Durability (%)"],
        type = "number",
        init = "overall",
        store = true,
        conditionType = "number",
      },
      {
        name = "broken",
        display = L["Broken Items"],
        type = "number",
        init = "broken",
        store = true,
        conditionType = "number",
      },
      {
        name = "value",
        init = "progress",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "name",
        init = ("%q"):format(L["Equipment Durability"]),
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "icon",
        init = "'Interface\\\\Icons\\\\Trade_BlackSmithing'",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "total",
        init = 100,
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "progressType",
        init = "'static'",
        hidden = true,
        store = true,
        test = "true",
      },
    },
    automaticrequired = true,
    progressType = "static"
  }

  Private.event_prototypes["Role"] = {
    type = "unit",
    events = {
      ["events"] = { "PLAYER_ROLES_ASSIGNED", "ROLE_CHANGED_INFORM", "GROUP_ROSTER_UPDATE" }
    },
    internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD", },
    force_events = "PLAYER_ROLES_ASSIGNED",
    name = L["Role"],
    init = function(trigger)
      return [[
        local role = UnitGroupRolesAssigned("player")
        if Private.ExecEnv.IsSecret(role) or role == "NONE" then
          role = nil
        end
      ]]
    end,
    statesParameter = "one",
    args = {
      {
        name = "role",
        display = L["Role"],
        type = "select",
        values = "role_types",
        init = "role",
        store = true,
        conditionType = "select",
      },
      {
        hidden = true,
        test = "role ~= nil",
      },
    },
    automaticrequired = true,
    progressType = "none"
  }

  Private.ExecEnv.GetActiveTracking = function(spellIDs)
    if not (C_Minimap and C_Minimap.GetNumTrackingTypes and C_Minimap.GetTrackingInfo) then
      return false
    end
    for index = 1, C_Minimap.GetNumTrackingTypes() or 0 do
      local info = C_Minimap.GetTrackingInfo(index)
      if info and info.active and (not spellIDs[1] or tIndexOf(spellIDs, info.spellID)) then
        return true, info.spellID, info.name, info.texture
      end
    end
    return false
  end

  Private.event_prototypes["Tracking"] = {
    type = "unit",
    events = {
      ["events"] = { "MINIMAP_UPDATE_TRACKING" }
    },
    internal_events = { "WA_DELAYED_PLAYER_ENTERING_WORLD", },
    force_events = "MINIMAP_UPDATE_TRACKING",
    name = L["Tracking"],
    init = function(trigger)
      local spellIDs = {}
      if trigger.use_trackingSpell then
        local entries = type(trigger.trackingSpell) == "table" and trigger.trackingSpell or { trigger.trackingSpell }
        for _, entry in ipairs(entries) do
          if tonumber(entry) then
            tinsert(spellIDs, tonumber(entry))
          end
        end
      end
      return ([[
        local found, spellId, name, icon = Private.ExecEnv.GetActiveTracking({%s})
        local inverse = %s
      ]]):format(table.concat(spellIDs, ", "), trigger.use_inverse and "true" or "false")
    end,
    GetNameAndIcon = function(trigger)
      local spellID = type(trigger.trackingSpell) == "table" and trigger.trackingSpell[1] or trigger.trackingSpell
      if trigger.use_trackingSpell and tonumber(spellID) then
        return Private.ExecEnv.GetSpellName(tonumber(spellID)), Private.ExecEnv.GetSpellIcon(tonumber(spellID))
      end
      return L["Tracking"], "Interface\\Minimap\\Tracking\\None"
    end,
    statesParameter = "one",
    args = {
      {
        name = "trackingSpell",
        display = L["Tracking Spell"],
        type = "spell",
        multiEntry = {
          operator = "or"
        },
        test = "true",
        only_exact = true,
      },
      {
        name = "inverse",
        display = L["Inverse"],
        type = "toggle",
        test = "true",
      },
      {
        hidden = true,
        test = "found ~= inverse",
      },
      {
        name = "spellId",
        display = L["Spell ID"],
        init = "spellId",
        hidden = true,
        store = true,
        test = "true",
        conditionType = "number",
        operator_types = "only_equal",
      },
      {
        name = "name",
        init = "name",
        hidden = true,
        store = true,
        test = "true",
      },
      {
        name = "icon",
        init = "icon",
        hidden = true,
        store = true,
        test = "true",
      },
    },
    automaticrequired = true,
    progressType = "none"
  }

  Private.category_event_prototype.item["Ammo"] = L["Ammo"]
  Private.category_event_prototype.item["Bag Space"] = L["Bag Space"]
  Private.category_event_prototype.item["Equipment Durability"] = L["Equipment Durability"]
  Private.category_event_prototype.unit["Role"] = L["Role"]
  Private.category_event_prototype.unit["Tracking"] = L["Tracking"]
end

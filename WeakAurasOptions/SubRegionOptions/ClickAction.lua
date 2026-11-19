-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

local mouseButtonNames = {
  { key = "Left", name = L["Left Click"] },
  { key = "Right", name = L["Right Click"] },
  { key = "Middle", name = L["Middle Click"] },
}

-- Name of the aura of another click action on the same key, if any: the same aura can hold two.
local function OtherAuraWithKey(data, key)
  for id, aura in pairs(WeakAurasSaved.displays) do
    if aura.subRegions then
      for _, subRegion in ipairs(aura.subRegions) do
        if subRegion ~= data and subRegion.type == "subclickaction" and subRegion.clickBinding == key then
          return id
        end
      end
    end
  end
end

local function BindingConflict(data)
  local key = data.clickBinding
  if not key or key == "" then
    return
  end
  local otherAura = OtherAuraWithKey(data, key)
  if otherAura then
    return L["The key %s is also used by the aura %s."]:format(key, otherAura)
  end
  -- checkOverride: a key taken by an override binding of another addon counts too.
  local action = GetBindingAction(key, true)
  if action and action ~= "" and not action:find("^CLICK MuscaAurasClick") then
    return L["The key %s is bound to %s in the game. The aura takes it while it is loaded."]:format(key, action)
  end
end

local function createOptions(parentData, data, index, subIndex)
  local options = {
    __title = L["Click Action %s"]:format(subIndex),
    __order = 1,
    clickLimits = {
      type = "description",
      width = WeakAuras.doubleWidth,
      name = L["The clickable area is updated out of combat only. In combat it keeps its position and its state: it does not follow an aura moved, resized or shown in combat, nor a dynamic group. A clone shown in combat is not clickable before the end of combat. The game gives no access to buffs on the secure side: a click active only while a buff is present is not possible in combat."],
      fontSize = "medium",
      order = 1,
    },
  }

  for position, button in ipairs(mouseButtonNames) do
    local typeKey = "click" .. button.key .. "Type"
    local order = 1 + position
    options[typeKey] = {
      type = "select",
      width = WeakAuras.normalWidth,
      name = button.name,
      values = OptionsPrivate.Private.click_action_types,
      order = order,
    }
    options["click" .. button.key .. "Value"] = {
      type = "input",
      width = WeakAuras.normalWidth,
      name = function()
        local actionType = data[typeKey]
        if actionType == "item" then
          return L["Item Name or ID"]
        elseif actionType == "macro" then
          return L["Macro Text"]
        end
        return L["Spell Name or ID"]
      end,
      -- AceConfig reads multiline as a plain value: two lines fit a name and a short macro.
      multiline = 2,
      order = order + 0.1,
      hidden = function() return data[typeKey] == "none" or data[typeKey] == "target" end,
    }
    options["click" .. button.key .. "Unit"] = {
      type = "select",
      width = WeakAuras.normalWidth,
      name = L["Unit"],
      -- Targeting needs an explicit unit: no default for it.
      values = function()
        local units = CopyTable(OptionsPrivate.Private.click_action_units)
        if data[typeKey] == "target" then
          units[""] = nil
        end
        return units
      end,
      order = order + 0.2,
      hidden = function()
        local actionType = data[typeKey]
        return actionType == "none" or actionType == "macro" or actionType == "cancelaura"
      end,
    }
  end

  options.clickBinding = {
    type = "keybinding",
    width = WeakAuras.normalWidth,
    name = L["Key Binding"],
    desc = L["Does the left click action. Set out of combat while the aura is clickable, removed when the aura is unloaded or deleted."],
    order = 10,
  }
  options.clickBindingConflict = {
    type = "description",
    width = WeakAuras.doubleWidth,
    name = function() return "|cFFFF8800" .. (BindingConflict(data) or "") .. "|r" end,
    order = 10.1,
    hidden = function() return BindingConflict(data) == nil end,
  }
  options.clickCombatMode = {
    type = "select",
    width = WeakAuras.normalWidth,
    name = L["Clickable in Combat"],
    values = OptionsPrivate.Private.click_combat_modes,
    order = 11,
  }
  options.clickCombatCondition = {
    type = "input",
    width = WeakAuras.normalWidth,
    name = L["Macro Condition"],
    desc = L["Shows the clickable area when the condition is true, in combat too. Example: [combat][mod:shift] show; hide"],
    order = 11.1,
    hidden = function() return data.clickCombatMode ~= "macro" end,
  }
  options.clickAlwaysWarning = {
    type = "description",
    width = WeakAuras.doubleWidth,
    name = L["A click on the area does the action even while the aura is hidden."],
    order = 11.2,
    hidden = function() return data.clickCombatMode ~= "always" end,
  }

  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, "subclickaction")

  return options
end

WeakAuras.RegisterSubRegionOptions("subclickaction", createOptions,
  L["Casts a spell, uses an item or a macro, targets a unit or cancels a buff when the aura is clicked"])

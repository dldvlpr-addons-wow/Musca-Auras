if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L;

local actionTypes = {
  none = L["None"],
  spell = L["Cast a Spell"],
  item = L["Use an Item"],
  macro = L["Run a Macro"],
  target = L["Target a Unit"],
  cancelaura = L["Remove a Buff"],
}

local unitTypes = {
  default = L["Default"],
  player = L["Player"],
  target = L["Target"],
  mouseover = L["Mouseover"],
  focus = L["Focus"],
}

local valueNames = {
  spell = L["Spell Name or ID"],
  item = L["Item Name or ID"],
  cancelaura = L["Buff Name or ID"],
}

local combatModes = {
  visible = L["Aura visible when combat starts"],
  combat = L["When the aura shows, and the whole combat"],
  always = L["Always, while the aura is loaded"],
  macro = L["Macro Condition"],
}

local function createOptions(parentData, data, index, subIndex)
  local options = {
    __title = L["Click Action %s"]:format(subIndex),
    __order = 1,
  }

  local order = 1
  for _, mouse in ipairs({
    { prefix = "left", name = L["Left Click"] },
    { prefix = "right", name = L["Right Click"] },
    { prefix = "middle", name = L["Middle Click"] },
  }) do
    local actionKey = mouse.prefix .. "_action"
    options[actionKey] = {
      type = "select",
      width = WeakAuras.normalWidth,
      name = mouse.name,
      values = actionTypes,
      order = order,
    }
    options[mouse.prefix .. "_unit"] = {
      type = "select",
      width = WeakAuras.normalWidth,
      name = L["Unit"],
      values = unitTypes,
      order = order + 0.1,
      hidden = function() return data[actionKey] == "none" or data[actionKey] == "cancelaura" end,
    }
    options[mouse.prefix .. "_value"] = {
      type = "input",
      width = WeakAuras.doubleWidth,
      name = function() return valueNames[data[actionKey]] or "" end,
      order = order + 0.2,
      hidden = function() return valueNames[data[actionKey]] == nil end,
    }
    -- A field of its own: the options are not built again when the action changes, and a macro needs several lines.
    options[mouse.prefix .. "_macro"] = {
      type = "input",
      multiline = 4,
      width = WeakAuras.doubleWidth,
      name = L["Macro Text"],
      order = order + 0.3,
      hidden = function() return data[actionKey] ~= "macro" end,
    }
    order = order + 1
  end

  options.keybind = {
    type = "keybinding",
    width = WeakAuras.normalWidth,
    name = L["Key"],
    desc = L["The key does the action of the left click."],
    order = order,
    -- The macro condition only shows and hides the clickable area, it cannot bind and unbind the key.
    hidden = function() return data.combat_mode == "macro" end,
  }
  options.keybindWarning = {
    type = "description",
    width = WeakAuras.doubleWidth,
    name = function()
      local key = data.keybind
      if not key or key == "" then
        return ""
      end
      local lines = {}
      local action = GetBindingAction(key)
      if action and action ~= "" then
        lines[#lines + 1] = L["This key is already bound by the game: %s"]:format(action)
      end
      local others = OptionsPrivate.Private.ClickButtons.AurasBindingKey(key, parentData.id)
      if #others > 0 then
        lines[#lines + 1] = L["This key is already bound by the aura: %s"]:format(table.concat(others, ", "))
      end
      return #lines > 0 and ("|cFFFF8800" .. table.concat(lines, "\n") .. "|r") or ""
    end,
    order = order + 0.1,
    hidden = function()
      local key = data.keybind
      if not key or key == "" or data.combat_mode == "macro" then
        return true
      end
      local action = GetBindingAction(key)
      return (not action or action == "")
             and #OptionsPrivate.Private.ClickButtons.AurasBindingKey(key, parentData.id) == 0
    end,
  }
  options.combat_mode = {
    type = "select",
    width = WeakAuras.normalWidth,
    name = L["Clickable in Combat"],
    values = combatModes,
    order = order + 0.2,
  }
  options.macro_condition = {
    type = "input",
    width = WeakAuras.doubleWidth,
    name = L["Macro Condition"],
    desc = L["Shows the clickable area when the condition is true, as in a macro. Example: [combat][mod:shift] show; hide"],
    order = order + 0.3,
    hidden = function() return data.combat_mode ~= "macro" end,
  }
  options.limits = {
    type = "description",
    width = WeakAuras.doubleWidth,
    name = L["The game forbids moving a clickable area in combat. In combat: an aura in a dynamic group keeps its place of the combat start; a clone that appears gets no click until the combat ends; an aura moved or resized is not followed. With \"Always\", the click works even while the aura is hidden. The clickable area cannot read the aura. The click does nothing while the options are open. With \"When the aura shows, and the whole combat\", in combat the click works even while the aura is hidden, at its place of the combat start, even over an aura that took that place."],
    order = order + 0.4,
  }

  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, "subclickaction")

  return options
end

WeakAuras.RegisterSubRegionOptions("subclickaction", createOptions, L["Casts a spell, uses an item or runs a macro on a click on the aura"]);

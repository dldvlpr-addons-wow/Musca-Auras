-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local L = WeakAuras.L

local AuraEditor = {}
OptionsPrivate.AuraEditor = AuraEditor

-- Readable is the fallback for any other trigger type.
local MODE_OF_TYPE = { secretAura = "native", aura2 = "readable" }
local NATIVE_DEBUFF_TYPE = { BOTH = "HELPFUL" }
-- The unit frame debuff order is not offered once the aura type changes.
local SORT_AFTER_TYPE_CHANGE = { UnitFrameDebuff = "Default" }

function AuraEditor.Mode(trigger)
  local chosen = trigger.auraTracking
  if chosen == "native" or chosen == "readable" then
    return chosen
  end
  if MODE_OF_TYPE[trigger.type] == "native" then
    return "native"
  end
  return "readable"
end

-- Readable-only settings are kept aside while the trigger is native, so switching back restores them.
local function ToNative(data, trigger, Display)
  trigger.auraReadableSettings = {
    onlyMaw = trigger.onlyMaw,
    automaticWidth = data.automaticWidth,
    debuffType = trigger.debuffType,
  }
  trigger.debuffType = NATIVE_DEBUFF_TYPE[trigger.debuffType] or trigger.debuffType
  trigger.secretUseSpellIDs = not not trigger.useExactSpellId
  trigger.type = "secretAura"
  Display.Migrate(data)
end

local function ToReadable(data, trigger, Display)
  trigger.useExactSpellId = Display.UsesSpellIDs(trigger)
  local kept = trigger.auraReadableSettings
  if kept then
    trigger.onlyMaw = kept.onlyMaw
    data.automaticWidth = kept.automaticWidth
    if kept.debuffType == "BOTH" then trigger.debuffType = "BOTH" end
  end
  trigger.type = "aura2"
  trigger.auraReadableSettings = nil
end

local CONVERT_TO = { native = ToNative, readable = ToReadable }

function AuraEditor.Resolve(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local current = MODE_OF_TYPE[trigger.type]
  local wanted = AuraEditor.Mode(trigger)
  -- Only aura triggers convert, and only when their type disagrees with the chosen mode.
  if current and current ~= wanted then
    CONVERT_TO[wanted](data, trigger, OptionsPrivate.Private.BlizzardAuraDisplay)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
end

function OptionsPrivate.SaveAuraTrigger(data, triggernum)
  AuraEditor.Resolve(data, triggernum)
  WeakAuras.Add(data)
end

local DEBUFF_TYPES = {
  native = {
    values = { HELPFUL = L["Buff"], HARMFUL = L["Debuff"] },
    sorting = { "HELPFUL", "HARMFUL" },
  },
  readable = {
    values = { HELPFUL = L["Buff"], HARMFUL = L["Debuff"], BOTH = L["Buff or Debuff"] },
    sorting = { "HELPFUL", "HARMFUL", "BOTH" },
  },
}

local function NormalizeSeconds(value)
  if type(value) == "string" then return (value:gsub(",", ".")) end
  return value
end

-- strict: the value must be above 0; otherwise 0 is allowed.
local function SecondsValidator(strict, message)
  return function(_, value)
    local seconds = tonumber(NormalizeSeconds(value))
    local valid = seconds ~= nil and seconds == seconds and seconds ~= math.huge and seconds ~= -math.huge
      and (strict and seconds > 0 or not strict and seconds >= 0)
    return valid or message
  end
end

local UNITS_THAT_MAY_BE_MISSING = {
  target = true, focus = true, pet = true, targettarget = true, focustarget = true, member = true,
}

function AuraEditor.AddOptions(options, data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local treeMode = MODE_OF_TYPE[trigger.type] == "native" and "native" or "readable"

  local function save()
    OptionsPrivate.SaveAuraTrigger(data, triggernum)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end

  local debuffTypes = DEBUFF_TYPES[treeMode]
  local debuffType = options.debuffType
  debuffType.values = debuffTypes.values
  debuffType.sorting = debuffTypes.sorting
  debuffType.get = function() return trigger.debuffType end
  debuffType.set = function(_, value)
    if not debuffTypes.values[value] then return end
    trigger.processedAuraType = "any"
    trigger.debuffType = value
    trigger.sortMethod = SORT_AFTER_TYPE_CHANGE[trigger.sortMethod] or trigger.sortMethod
    save()
  end

  if treeMode == "readable" then
    options.auraCapabilities = {
      type = "description", order = 1.3, width = "full", fontSize = "small",
      name = L["Legacy Auras rarely function in combat as most are Blizzard-controlled."],
    }
    return
  end

  local Display = OptionsPrivate.Private.BlizzardAuraDisplay
  options.help.fontSize = "small"

  local thresholds = {
    {
      keys = { "useRem", "remOperator", "rem", "useRemSpace" },
      orders = { 10.01, 10.02, 10.03, 10.04 },
      title = L["Remaining Time"],
      flag = "secretUseRem", operator = "secretRemOperator", value = "secretRem",
      defaultOperator = "<",
      operators = Display.remOperators, sorting = { "<", "<=", ">", ">=" },
      -- Remaining time only makes sense while the aura is shown because it is found.
      blocked = function() return Display.RawShowOn(trigger) ~= "showOnActive" end,
      onEnable = function()
        if tonumber(trigger.secretRem) == nil then trigger.secretRem = "5" end
      end,
      validate = SecondsValidator(false, L["Enter a number of seconds, 0 or more."]),
      parse = NormalizeSeconds,
    },
    {
      keys = { "useTotal", "totalOperator", "total", "useTotalSpace" },
      orders = { 10.05, 10.06, 10.07, 10.08 },
      title = L["Total Duration"],
      flag = "secretUseTotal", operator = "secretTotalOperator", value = "secretTotal",
      defaultOperator = "=",
      operators = Display.totalOperators, sorting = { "=", "<=", ">=" },
      validate = SecondsValidator(true, L["Enter a number of seconds above 0."]),
      parse = NormalizeSeconds,
    },
    {
      keys = { "useStacks", "stacksOperator", "stacks", "useStacksSpace" },
      orders = { 10.085, 10.086, 10.087, 10.088 },
      title = L["Stack Count"],
      flag = "secretUseStacks", operator = "secretStacksOperator", value = "secretStacks",
      defaultOperator = ">=",
      operators = Display.stackOperators, sorting = { "=", ">=", ">", "<=", "<" },
      validate = function(_, value)
        local count = tonumber(value)
        if count and count == math.floor(count) and count >= 0 and count <= Display.STACK_LIMIT then
          return true
        end
        return L["Enter a whole number from 0 to %d."]:format(Display.STACK_LIMIT)
      end,
      parse = tonumber,
    },
  }

  for _, threshold in ipairs(thresholds) do
    local blocked = threshold.blocked or function() return false end
    local function controlsHidden()
      return blocked() or not trigger[threshold.flag]
    end
    local toggleKey, operatorKey, valueKey, spaceKey = unpack(threshold.keys)
    local toggleOrder, operatorOrder, valueOrder, spaceOrder = unpack(threshold.orders)

    options[toggleKey] = {
      type = "toggle", name = threshold.title, order = toggleOrder, width = WeakAuras.normalWidth,
      hidden = threshold.blocked,
      get = function() return trigger[threshold.flag] or false end,
      set = function(_, enabled)
        trigger[threshold.flag] = enabled or nil
        if enabled and trigger[threshold.operator] == nil then
          trigger[threshold.operator] = threshold.defaultOperator
        end
        if enabled and threshold.onEnable then threshold.onEnable() end
        save()
      end,
    }
    options[operatorKey] = {
      type = "select", name = L["Operator"], order = operatorOrder, width = WeakAuras.halfWidth,
      values = threshold.operators, sorting = threshold.sorting, hidden = controlsHidden,
      get = function() return trigger[threshold.operator] or threshold.defaultOperator end,
      set = function(_, value)
        trigger[threshold.operator] = value
        save()
      end,
    }
    options[valueKey] = {
      type = "input", name = threshold.title, order = valueOrder, width = WeakAuras.halfWidth,
      hidden = controlsHidden, validate = threshold.validate,
      get = function()
        local value = trigger[threshold.value]
        return value and tostring(value) or ""
      end,
      set = function(_, value)
        trigger[threshold.value] = threshold.parse(value)
        save()
      end,
    }
    options[spaceKey] = {
      type = "description", name = "", order = spaceOrder, width = WeakAuras.normalWidth,
      hidden = function() return blocked() or trigger[threshold.flag] and true or false end,
    }
  end

  options.secretApproximate = {
    type = "toggle", name = L["Approximate Match"], order = 4.02, width = "full",
    desc = L["Approximates the selected spell ID based on its duration and other learned information."],
    hidden = function()
      return not Display.approximateUnits[Display.UnitCategory(trigger)]
        or trigger.debuffType ~= "HARMFUL"
        or #Display.GetSpellIDs(trigger, true) <= 0
    end,
    get = function() return trigger.secretApproximate or false end,
    set = function(_, value)
      trigger.secretApproximate = value or nil
      save()
    end,
  }

  options.show_settings_header = { type = "header", name = L["Show and Clone Settings"], order = 69.91 }

  -- Native auras are always tied to Show On, so the toggle stays checked and locked.
  options.use_matchesShowOn = {
    type = "toggle", name = L["Show On"], order = 71, width = WeakAuras.normalWidth, disabled = true,
    get = function() return true end,
  }
  options.matchesShowOn = {
    type = "select", name = L["Show On"], order = 71.1, width = WeakAuras.normalWidth,
    values = Display.showOnValues, sorting = { "showOnActive", "showOnMissing", "showAlways" },
    get = function() return Display.RawShowOn(trigger) end,
    set = function(_, value)
      if not Display.showOnValues[value] then return end
      -- Found is the default and is not stored.
      if value == "showOnActive" then value = nil end
      trigger.secretShowOn = value
      save()
    end,
  }
  options.unitExists = {
    type = "toggle", name = L["Show If Unit Does Not Exist"], order = 71.3, width = WeakAuras.doubleWidth,
    desc = L["Keep this trigger active while there is no such unit. Otherwise it is inactive then, so other triggers can supply the display."],
    hidden = function() return not UNITS_THAT_MAY_BE_MISSING[trigger.unit] end,
    get = function() return trigger.unitExists or false end,
    set = function(_, value)
      trigger.unitExists = value or nil
      save()
    end,
  }
  options.showClones = {
    type = "toggle", name = L["Auto-Clone (Show All Matches)"], order = 72, width = "full", disabled = true,
    get = function() return trigger.showClones or false end,
  }
  options.combineMode = {
    type = "select", name = L["Preferred Match"], order = 72.6, width = WeakAuras.normalWidth, disabled = true,
    values = OptionsPrivate.Private.bufftrigger_2_preferred_match_types,
    get = function() return trigger.combineMode or "showLowest" end,
  }
  options.nativeShowNotice = {
    type = "description", order = 73, width = "full", fontSize = "small",
    name = function()
      if not Display.IsSingle(trigger, data) then
        return L["You cannot control clones with an Aura (Modern). Use the Aura (Modern) Settings under Display."]
      end
      return L["One aura is shown, chosen by Sort by under Aura (Modern) Settings in Display."]
    end,
  }
end

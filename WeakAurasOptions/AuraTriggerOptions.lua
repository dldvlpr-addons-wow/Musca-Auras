if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local AuraEditor = {}
OptionsPrivate.AuraEditor = AuraEditor

local UNITS_WITHOUT_EXISTENCE = {
  target = true, focus = true, pet = true, targettarget = true, focustarget = true, member = true,
}

local function resolveMode(trigger)
  local tracking = trigger.auraTracking
  if tracking == "native" or tracking == "readable" then return tracking end
  if trigger.type == "secretAura" then return "native" end
  return "readable"
end
AuraEditor.Mode = resolveMode

local function convertToNative(data, trigger)
  trigger.auraReadableSettings = {
    onlyMaw = trigger.onlyMaw,
    automaticWidth = data.automaticWidth,
    debuffType = trigger.debuffType,
  }
  if trigger.debuffType == "BOTH" then
    trigger.debuffType = "HELPFUL"
  end
  trigger.secretUseSpellIDs = trigger.useExactSpellId or false
  trigger.type = "secretAura"
  OptionsPrivate.Private.BlizzardAuraDisplay.Migrate(data)
end

local function convertToReadable(data, trigger)
  local remembered = trigger.auraReadableSettings
  trigger.useExactSpellId = OptionsPrivate.Private.BlizzardAuraDisplay.UsesSpellIDs(trigger)
  if remembered then
    trigger.onlyMaw = remembered.onlyMaw
    data.automaticWidth = remembered.automaticWidth
    if remembered.debuffType == "BOTH" then
      trigger.debuffType = "BOTH"
    end
  end
  trigger.type = "aura2"
  trigger.auraReadableSettings = nil
end

AuraEditor.Resolve = function(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local currentType = trigger.type
  if currentType ~= "aura2" and currentType ~= "secretAura" then return end
  local wantsNative = AuraEditor.Mode(trigger) == "native"
  if (wantsNative and "secretAura" or "aura2") == currentType then return end
  if wantsNative then
    convertToNative(data, trigger)
  else
    convertToReadable(data, trigger)
  end
  OptionsPrivate.QueueOptionsRefresh(data.id)
end

OptionsPrivate.SaveAuraTrigger = function(data, triggernum)
  AuraEditor.Resolve(data, triggernum)
  WeakAuras.Add(data)
end

local function normalizeSeconds(value)
  if type(value) == "string" then
    return (value:gsub(",", "."))
  end
  return value
end

local function secondsProblem(value, strict)
  local seconds = tonumber(normalizeSeconds(value))
  if not seconds or seconds ~= seconds or seconds == math.huge then return true end
  if strict then return seconds <= 0 end
  return seconds < 0
end

local function secondsValidator(strict, message)
  return function(_, value)
    if secondsProblem(value, strict) then return message end
    return true
  end
end

local function describeSpacer(order, hidden)
  return {type = "description", name = "", order = order, width = WeakAuras.normalWidth, hidden = hidden}
end

local function addThresholdGroup(options, trigger, save, spec)
  local flag, operatorKey, valueKey = spec.flagKey, spec.operatorKey, spec.valueKey
  local orders = spec.orders
  local gate = spec.gate
  local function blocked()
    return gate and gate() or false
  end
  options[spec.toggleName] = {
    type = "toggle", name = spec.title, order = orders[1], width = WeakAuras.normalWidth,
    hidden = gate,
    get = function() return trigger[flag] or false end,
    set = function(_, enabled)
      trigger[flag] = enabled or nil
      if enabled and trigger[operatorKey] == nil then trigger[operatorKey] = spec.defaultOperator end
      if spec.onEnable then spec.onEnable(enabled) end
      save()
    end,
  }
  options[spec.operatorName] = {
    type = "select", name = "Operator", order = orders[2], width = WeakAuras.halfWidth,
    values = spec.operators, sorting = spec.sorting,
    hidden = function() return blocked() or not trigger[flag] end,
    get = function() return trigger[operatorKey] or spec.defaultOperator end,
    set = function(_, value) trigger[operatorKey] = value; save() end,
  }
  options[spec.inputName] = {
    type = "input", name = spec.title, order = orders[3], width = WeakAuras.halfWidth,
    hidden = function() return blocked() or not trigger[flag] end,
    validate = spec.validate,
    get = function()
      local stored = trigger[valueKey]
      return stored and tostring(stored) or ""
    end,
    set = function(_, value) trigger[valueKey] = spec.parse(value); save() end,
  }
  options[spec.spacerName] = describeSpacer(orders[4], function() return blocked() or trigger[flag] end)
end

local function addNativeOptions(options, data, trigger, save)
  local display = OptionsPrivate.Private.BlizzardAuraDisplay
  local function notShowingOnActive() return display.RawShowOn(trigger) ~= "showOnActive" end

  addThresholdGroup(options, trigger, save, {
    toggleName = "useRem", operatorName = "remOperator", inputName = "rem", spacerName = "useRemSpace",
    title = "Remaining Time", orders = {10.01, 10.02, 10.03, 10.04}, gate = notShowingOnActive,
    flagKey = "secretUseRem", operatorKey = "secretRemOperator", valueKey = "secretRem", defaultOperator = "<",
    operators = display.remOperators, sorting = {"<", "<=", ">", ">="},
    onEnable = function(enabled)
      if enabled and tonumber(trigger.secretRem) == nil then trigger.secretRem = "5" end
    end,
    validate = secondsValidator(false, "Enter a number of seconds, 0 or more."),
    parse = normalizeSeconds,
  })
  addThresholdGroup(options, trigger, save, {
    toggleName = "useTotal", operatorName = "totalOperator", inputName = "total", spacerName = "useTotalSpace",
    title = "Total Duration", orders = {10.05, 10.06, 10.07, 10.08},
    flagKey = "secretUseTotal", operatorKey = "secretTotalOperator", valueKey = "secretTotal", defaultOperator = "=",
    operators = display.totalOperators, sorting = {"=", "<=", ">="},
    validate = secondsValidator(true, "Enter a number of seconds above 0."),
    parse = normalizeSeconds,
  })
  addThresholdGroup(options, trigger, save, {
    toggleName = "useStacks", operatorName = "stacksOperator", inputName = "stacks", spacerName = "useStacksSpace",
    title = "Stack Count", orders = {10.085, 10.086, 10.087, 10.088},
    flagKey = "secretUseStacks", operatorKey = "secretStacksOperator", valueKey = "secretStacks", defaultOperator = ">=",
    operators = display.stackOperators, sorting = {"=", ">=", ">", "<=", "<"},
    validate = function(_, value)
      local count = tonumber(value)
      if not count or count ~= math.floor(count) or count < 0 or count > display.STACK_LIMIT then
        return "Enter a whole number from 0 to " .. display.STACK_LIMIT .. "."
      end
      return true
    end,
    parse = tonumber,
  })

  options.secretApproximate = {
    type = "toggle", name = "Approximate Match", order = 4.02, width = "full",
    desc = "Approximates the selected spell ID based on its duration and other learned information.",
    hidden = function()
      if not display.approximateUnits[display.UnitCategory(trigger)] then return true end
      if trigger.debuffType ~= "HARMFUL" then return true end
      return #display.GetSpellIDs(trigger, true) <= 0
    end,
    get = function() return trigger.secretApproximate or false end,
    set = function(_, value) trigger.secretApproximate = value or nil; save() end,
  }
  options.show_settings_header = {type = "header", name = "Show and Clone Settings", order = 69.91}
  options.use_matchesShowOn = {
    type = "toggle", name = "Show On", order = 71, width = WeakAuras.normalWidth,
    disabled = true, get = function() return true end,
  }
  options.matchesShowOn = {
    type = "select", name = "Show On", order = 71.1, width = WeakAuras.normalWidth,
    values = display.showOnValues, sorting = {"showOnActive", "showOnMissing", "showAlways"},
    get = function() return display.RawShowOn(trigger) end,
    set = function(_, value)
      if not display.showOnValues[value] then return end
      if value ~= "showOnActive" then trigger.secretShowOn = value else trigger.secretShowOn = nil end
      save()
    end,
  }
  options.unitExists = {
    type = "toggle", name = "Show If Unit Does Not Exist", order = 71.3, width = WeakAuras.doubleWidth,
    desc = "Keep this trigger active while there is no such unit. Otherwise it is inactive then, so other triggers can supply the display.",
    hidden = function() return not UNITS_WITHOUT_EXISTENCE[trigger.unit] end,
    get = function() return trigger.unitExists or false end,
    set = function(_, value) trigger.unitExists = value or nil; save() end,
  }
  options.showClones = {
    type = "toggle", name = "Auto-Clone (Show All Matches)", order = 72, width = "full",
    disabled = true, get = function() return trigger.showClones or false end,
  }
  options.combineMode = {
    type = "select", name = "Preferred Match", order = 72.6, width = WeakAuras.normalWidth,
    disabled = true, values = OptionsPrivate.Private.bufftrigger_2_preferred_match_types,
    get = function() return trigger.combineMode or "showLowest" end,
  }
  options.nativeShowNotice = {
    type = "description", order = 73, width = "full", fontSize = "small",
    name = function()
      if not display.IsSingle(trigger, data) then
        return "You cannot control clones with an Aura (Modern). Use the Aura (Modern) Settings under Display."
      end
      return "One aura is shown, chosen by Sort by under Aura (Modern) Settings in Display."
    end,
  }
end

AuraEditor.AddOptions = function(options, data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local isNative = trigger.type == "secretAura"
  local function save()
    OptionsPrivate.SaveAuraTrigger(data, triggernum)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end

  if isNative then
    options.help.fontSize = "small"
  else
    options.auraCapabilities = {
      type = "description", order = 1.3, width = "full", fontSize = "small",
      name = "Legacy Auras rarely function in combat as most are Blizzard-controlled.",
    }
  end

  local auraType = options.debuffType
  if isNative then
    auraType.values = {HELPFUL = "Buff", HARMFUL = "Debuff"}
    auraType.sorting = {"HELPFUL", "HARMFUL"}
  else
    auraType.values = {HELPFUL = "Buff", HARMFUL = "Debuff", BOTH = "Buff or Debuff"}
    auraType.sorting = {"HELPFUL", "HARMFUL", "BOTH"}
  end
  auraType.get = function() return trigger.debuffType end
  auraType.set = function(_, value)
    if not auraType.values[value] then return end
    trigger.processedAuraType = "any"
    trigger.debuffType = value
    if trigger.sortMethod == "UnitFrameDebuff" then
      trigger.sortMethod = "Default"
    end
    save()
  end

  if isNative then
    addNativeOptions(options, data, trigger, save)
  end
end

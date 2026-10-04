if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local GROUP_UNITS = {group = true, party = true, raid = true}

local CLASSIFICATION_FILTERS = {Buff = "HELPFUL", Debuff = "HARMFUL", Dispel = "HARMFUL"}

local AURA_TYPE_TITLES = {
  HELPFUL = "Buff", HARMFUL = "Debuff",
  Buff = "Blizzard: Buff", Debuff = "Blizzard: Debuff", Dispel = "Blizzard: Dispellable",
}

local NAMEPLATE_FLAG_DESCRIPTIONS = {
  nameplateShowAll = "Only match auras Blizzard marks for display on all nameplates.",
  nameplateShowPersonal = "Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar.",
}
local NAMEPLATE_FLAG_SUFFIX = " This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura."

local DISPEL_SELECTORS = {
  {key = "includeDispelTypes", title = "Include dispel types", order = 24},
  {key = "excludeDispelTypes", title = "Exclude dispel types", order = 25},
}

local function inGroupUnit(trigger)
  return GROUP_UNITS[trigger.unit] == true
end

local function selectedAuraType(trigger)
  local classification = trigger.processedAuraType
  if not classification or classification == "any" then
    return trigger.debuffType
  end
  if CLASSIFICATION_FILTERS[classification] ~= trigger.debuffType then
    return classification .. ":" .. trigger.debuffType
  end
  return classification
end

local function buildAuraTypeValues(trigger)
  local values = {}
  for key, title in pairs(AURA_TYPE_TITLES) do
    values[key] = title
  end
  local selected = selectedAuraType(trigger)
  if not values[selected] then
    local classificationTitle = AURA_TYPE_TITLES[trigger.processedAuraType] or trigger.processedAuraType
    local filterTitle = AURA_TYPE_TITLES[trigger.debuffType] or trigger.debuffType
    values[selected] = classificationTitle .. " (" .. filterTitle .. " filter)"
  end
  return values
end

local function createTriState(options, key, title, order, description, readValue, writeValue)
  options[key] = {
    type = "toggle", width = "full", order = order, desc = description,
    name = function()
      local value = readValue()
      if value == nil then return title end
      if value then return "|cFF00FF00" .. title .. "|r" end
      return "|cFFFF0000Not " .. title .. "|r"
    end,
    get = function()
      local value = readValue()
      if value == nil then return false end
      if value then return "true" end
      return "false"
    end,
    set = function(_, checked)
      if checked then
        writeValue(true)
      elseif readValue() == false then
        writeValue(nil)
      else
        writeValue(false)
      end
    end,
  }
end

local function addUnitOptions(options, ctx)
  local trigger, width, save = ctx.trigger, ctx.width, ctx.save
  options.alwaysActive = {
    type = "description", order = 1.95, width = "full", fontSize = "medium",
    name = "|cffffffffNote: Trigger Always Active|r",
  }
  options.help = {
    type = "description", order = 2, width = "full", fontSize = "small",
    name = function() return ctx.display.TriggerStatus(ctx.data, trigger) end,
  }
  options.unitLabel = {
    type = "toggle", name = "Unit", order = 3, width = width,
    disabled = true, get = function() return true end,
  }
  options.unit = {
    type = "select", name = "Unit", order = 3.01, width = width, values = ctx.display.units,
    get = function() return trigger.unit end,
    set = function(_, value) save("unit", value) end,
  }
  local function notMember() return trigger.unit ~= "member" end
  options.specificUnitSpace = {type = "description", name = "", order = 3.02, width = width, hidden = notMember}
  options.specificUnit = {
    type = "input", name = "Specific Unit", order = 3.03, width = width,
    desc = "party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5.",
    hidden = notMember,
    validate = function(_, value)
      if ctx.display.SpecificUnit({specificUnit = value}) then return true end
      return "Enter a unit such as party1, raid5, boss1 or arena2."
    end,
    get = function() return trigger.specificUnit or "" end,
    set = function(_, value) save("specificUnit", value:lower():match("^%s*(%S+)%s*$")) end,
  }
  options.auraTypeLabel = {
    type = "toggle", name = "Aura Type", order = 4, width = width,
    disabled = true, get = function() return true end,
  }
  options.debuffType = {
    type = "select", name = "Aura Type", order = 4.01, width = width,
    values = function() return buildAuraTypeValues(trigger) end,
    sorting = function()
      local sequence = {"HELPFUL", "HARMFUL", "Buff", "Debuff", "Dispel"}
      local selected = selectedAuraType(trigger)
      if not AURA_TYPE_TITLES[selected] then
        sequence[#sequence + 1] = selected
      end
      return sequence
    end,
    desc = "Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden.",
    get = function() return selectedAuraType(trigger) end,
    set = function(_, value)
      if not AURA_TYPE_TITLES[value] then return end
      local classification = CLASSIFICATION_FILTERS[value] and value or "any"
      trigger.debuffType = CLASSIFICATION_FILTERS[value] or value
      if trigger.sortMethod == "UnitFrameDebuff" and classification ~= "Debuff" and classification ~= "Dispel" then
        trigger.sortMethod = "Default"
      end
      save("processedAuraType", classification)
    end,
  }
end

local function addGroupMemberOptions(options, ctx)
  local trigger, width, save = ctx.trigger, ctx.width, ctx.save
  options.useUnitNames = {
    type = "toggle", name = "Player Name(s)", order = 4.1, width = width,
    desc = "Only track these group members. This also limits which units can play configured aura sounds.",
    hidden = function() return not inGroupUnit(trigger) end,
    get = function() return trigger.useUnitNames or false end,
    set = function(_, value) save("useUnitNames", value) end,
  }
  options.unitNames = {
    type = "input", name = "Player Names", order = 4.2, width = "full",
    desc = "Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match.",
    hidden = function() return not trigger.useUnitNames or not inGroupUnit(trigger) end,
    get = function() return table.concat(trigger.unitNames or {}, ", ") end,
    set = function(_, value)
      local names = {}
      for piece in value:gmatch("[^,]+") do
        piece = strtrim(piece)
        if piece ~= "" then names[#names + 1] = piece end
      end
      save("unitNames", names)
    end,
  }
  options.useUnitRoles = {
    type = "toggle", name = "Group Role", order = 4.3, width = width,
    desc = "Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled.",
    hidden = function() return not inGroupUnit(trigger) end,
    get = function() return trigger.useUnitRoles or false end,
    set = function(_, value) save("useUnitRoles", value) end,
  }
  options.unitRoles = {
    type = "multiselect", name = "Group Roles", order = 4.4, width = "full",
    values = {TANK = "Tank", HEALER = "Healer", DAMAGER = "Damage", NONE = "Unassigned"},
    desc = "Uses Blizzard's assigned group role. Members without a role assigned match Unassigned.",
    hidden = function() return not trigger.useUnitRoles or not inGroupUnit(trigger) end,
    get = function(_, role) return (trigger.unitRoles or {})[role] or false end,
    set = function(_, role, value)
      trigger.unitRoles = trigger.unitRoles or {}
      trigger.unitRoles[role] = value or nil
      save("unitRoles", trigger.unitRoles)
    end,
  }
  options.filtersHeader = {type = "header", name = "Aura Filters", order = 10}
  options.includeNameplateOnly = {
    type = "toggle", name = "Include nameplate-only auras", order = 21, width = "full",
    desc = "Also allows auras normally returned only for nameplate displays. Other filters still apply.",
    hidden = function() return trigger.unit ~= "nameplate" end,
    get = function() return trigger.includeNameplateOnly or false end,
    set = function(_, value) save("includeNameplateOnly", value) end,
  }
end

local function positiveSpellId(_, value)
  if value == "" then return true end
  local id = tonumber(value)
  if not id or id <= 0 or id >= 2147483647 or id ~= math.floor(id) then
    return "Enter a positive whole-number Spell ID."
  end
  return true
end

local function addSpellIdList(options, ctx, spec)
  local trigger, width = ctx.trigger, ctx.width
  local isEnabled = spec.isEnabled
  options[spec.toggleKey] = {
    type = "toggle", name = spec.title, order = spec.order, width = width - 0.2,
    get = function() return isEnabled(trigger) end,
    set = function(_, value) ctx.save(spec.flagKey, value) end,
  }
  options[spec.prefix .. "DisabledSpace"] = {
    type = "description", name = "", order = spec.order + 0.001, width = width + 0.2,
    hidden = function() return isEnabled(trigger) end,
  }
  local entryCount = #(trigger[spec.storageKey] or {}) + 1
  OptionsPrivate.CreateAuraSpellOptions(options, ctx.data, ctx.triggernum, entryCount,
    true, false, spec.prefix, spec.order, spec.flagKey, spec.storageKey, spec.inputName,
    nil,
    false, function() return isEnabled(trigger) end)
  for position = 1, entryCount do
    options[spec.prefix .. position].validate = positiveSpellId
  end
end

local function addSpellSelection(options, ctx)
  local trigger, display = ctx.trigger, ctx.display
  options.spellSelectionHeader = {type = "header", name = "Spell Selection Filters", order = 4.5}

  addSpellIdList(options, ctx, {
    toggleKey = "useRankSpellIDs", prefix = "rankspellid", storageKey = "auraRankSpellIDs",
    title = "Spell ID(s) (All Ranks)", inputName = "Spell ID", order = 4.95,
    isEnabled = display.UsesRankSpellIDs, flagKey = "secretUseRankSpellIDs",
  })
  options.useRankSpellIDs.desc = "Enter a Spell ID to track all ranks of that spell."

  local function unsupportedRanks()
    local unsupported = {}
    for _, entry in ipairs(trigger.auraRankSpellIDs or {}) do
      local id = tonumber(entry)
      if id and not OptionsPrivate.Private.AuraSpellRankSupported(id) then
        unsupported[#unsupported + 1] = tostring(entry)
      end
    end
    return unsupported
  end
  options.rankCoverage = {
    type = "description", order = 5.9, width = "full", fontSize = "small",
    hidden = function() return not display.UsesRankSpellIDs(trigger) or #unsupportedRanks() == 0 end,
    name = function()
      return "Other ranks could not be found for: " .. table.concat(unsupportedRanks(), ", ")
        .. ". Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)."
    end,
  }

  addSpellIdList(options, ctx, {
    toggleKey = "useSpellIDs", prefix = "spellid", storageKey = "auraspellids",
    title = "Exact Spell ID(s)", inputName = "Exact Spell ID", order = 6,
    isEnabled = display.UsesSpellIDs, flagKey = "secretUseSpellIDs",
  })
  addSpellIdList(options, ctx, {
    toggleKey = "useExcludedSpellIDs", prefix = "ignorespellid", storageKey = "excludedAuraSpellIDs",
    title = "Ignored Exact Spell ID(s)", inputName = "Ignored Spell ID", order = 7,
    isEnabled = display.UsesExcludedSpellIDs, flagKey = "secretUseExcludedSpellIDs",
  })
end

local function copyShallow(source)
  local copy = {}
  for key, value in pairs(source) do copy[key] = value end
  return copy
end

local function addFilterOptions(options, ctx)
  local trigger, display, save = ctx.trigger, ctx.display, ctx.save

  for position, field in ipairs(display.booleanFilters) do
    local key = field[1]
    createTriState(options, key, field[2], 10 + position, field[3],
      function() return trigger[key] end,
      function(value) save(key, value) end)
    local nameplateText = NAMEPLATE_FLAG_DESCRIPTIONS[key]
    if nameplateText then
      options[key].hidden = function() return trigger.unit ~= "nameplate" end
      options[key].desc = nameplateText .. NAMEPLATE_FLAG_SUFFIX
    end
  end

  for _, selector in ipairs(DISPEL_SELECTORS) do
    local key = selector.key
    options[key] = {
      type = "multiselect", name = selector.title, order = selector.order, width = "full",
      values = display.dispelTypes,
      get = function(_, name) return trigger[key] and trigger[key][name] or false end,
      set = function(_, name, value)
        local updated = copyShallow(trigger[key] or {})
        updated[name] = value and true or nil
        save(key, next(updated) and updated or nil)
      end,
    }
  end

  for position, field in ipairs(display.nativeFilters) do
    local key = field[1]
    createTriState(options, "native" .. key, field[2], 20 + position / 20, field[3],
      function() return (trigger.nativeFilters or {})[key] end,
      function(value)
        local updated = copyShallow(trigger.nativeFilters or {})
        updated[key] = value
        save("nativeFilters", next(updated) and updated or nil)
      end)
  end

  local width = ctx.width
  options.isFromPlayerOrPlayerPet.width = width
  options.nativePLAYER.width = width
  options.nativePLAYER.order = options.isFromPlayerOrPlayerPet.order
  options.isFromPlayerOrPlayerPet.order = options.nativePLAYER.order + 0.01

  for _, field in ipairs(display.processingOptions) do
    options[field[1]] = nil
  end

  local function guardByApplicability(optionKey, filterKey)
    local option = options[optionKey]
    if not option then return end
    local previous = option.hidden
    option.hidden = function()
      return not display.FilterApplies(filterKey, trigger) or (type(previous) == "function" and previous()) or previous == true
    end
  end
  for _, field in ipairs(display.nativeFilters) do
    guardByApplicability("native" .. field[1], field[1])
  end
  for _, field in ipairs(display.booleanFilters) do
    guardByApplicability(field[1], field[1])
  end
end

local function buildTriggerOptions(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local ctx = {
    data = data, trigger = trigger, triggernum = triggernum,
    display = OptionsPrivate.Private.BlizzardAuraDisplay,
    width = WeakAuras.normalWidth,
  }
  ctx.save = function(key, value)
    trigger[key] = value
    OptionsPrivate.SaveAuraTrigger(data, triggernum)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end

  local options = {}
  addUnitOptions(options, ctx)
  addGroupMemberOptions(options, ctx)
  addSpellSelection(options, ctx)
  addFilterOptions(options, ctx)

  OptionsPrivate.commonOptions.AddCommonTriggerOptions(options, data, triggernum, true)
  OptionsPrivate.AuraEditor.AddOptions(options, data, triggernum)
  OptionsPrivate.AddTriggerMetaFunctions(options, data, triggernum)
  return {["trigger." .. triggernum .. ".secretAura"] = options}
end

WeakAuras.RegisterTriggerSystemOptions({"secretAura"}, buildTriggerOptions)

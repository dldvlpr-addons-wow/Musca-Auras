-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local L = WeakAuras.L
local normalWidth = WeakAuras.normalWidth

local GROUP_UNITS = { group = true, party = true, raid = true }
local MAX_SPELL_ID = 2147483647

local NAMEPLATE_FILTER_DESCRIPTIONS = {
  nameplateShowAll = L["Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura."],
  nameplateShowPersonal = L["Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura."],
}

local AURA_TYPE_CHOICES = {
  HELPFUL = { label = L["Buff"], debuffType = "HELPFUL", processedAuraType = "any" },
  HARMFUL = { label = L["Debuff"], debuffType = "HARMFUL", processedAuraType = "any" },
  Buff = { label = L["Blizzard: Buff"], debuffType = "HELPFUL", processedAuraType = "Buff" },
  Debuff = { label = L["Blizzard: Debuff"], debuffType = "HARMFUL", processedAuraType = "Debuff", unitFrameSort = true },
  Dispel = { label = L["Blizzard: Dispellable"], debuffType = "HARMFUL", processedAuraType = "Dispel", unitFrameSort = true },
}
local AURA_TYPE_SORTING = { "HELPFUL", "HARMFUL", "Buff", "Debuff", "Dispel" }
local AURA_TYPE_BY_PAIR = {}
for key, choice in pairs(AURA_TYPE_CHOICES) do
  AURA_TYPE_BY_PAIR[choice.processedAuraType .. ":" .. choice.debuffType] = key
end

local SHARED_ROW_ORDERS = { nativePLAYER = 11, isFromPlayerOrPlayerPet = 11.01 }

local SPELL_LISTS = {
  {
    toggle = "useRankSpellIDs", caption = L["Spell ID(s) (All Ranks)"], order = 4.95, prefix = "rankspellid",
    storage = "auraRankSpellIDs", flag = "secretUseRankSpellIDs", enabled = "UsesRankSpellIDs",
    inputName = L["Spell ID or Name"],
    desc = L["Enter a Spell ID or a spell name to track all ranks of that spell. A name is replaced by the IDs of all its ranks."],
  },
  {
    toggle = "useSpellIDs", caption = L["Exact Spell ID(s)"], order = 6, prefix = "spellid",
    storage = "auraspellids", flag = "secretUseSpellIDs", enabled = "UsesSpellIDs",
    inputName = L["Exact Spell ID or Name"],
  },
  {
    toggle = "useExcludedSpellIDs", caption = L["Ignored Exact Spell ID(s)"], order = 7, prefix = "ignorespellid",
    storage = "excludedAuraSpellIDs", flag = "secretUseExcludedSpellIDs", enabled = "UsesExcludedSpellIDs",
    inputName = L["Ignored Spell ID or Name"],
  },
}

local function Trim(text)
  return (text:match("^%s*(.-)%s*$"))
end

local rankIDsByName

local function RankIDsByName()
  if not rankIDsByName then
    rankIDsByName = {}
    for _, family in ipairs(OptionsPrivate.Private.AuraSpellFamilies or {}) do
      local name = OptionsPrivate.Private.ExecEnv.GetSpellName(family[1])
      if name then
        local key = name:lower()
        local ids = rankIDsByName[key] or {}
        for _, id in ipairs(family) do ids[#ids + 1] = id end
        rankIDsByName[key] = ids
      end
    end
  end
  return rankIDsByName
end

local function ResolveSpellName(text)
  if type(text) ~= "string" then return end
  text = Trim(text)
  if text == "" or tonumber(text) then return end
  local ids = RankIDsByName()[text:lower()]
  if ids then return ids end
  local lookup = C_Spell and C_Spell.GetSpellIDForSpellIdentifier
  local id = lookup and lookup(text)
  if id then return OptionsPrivate.Private.GetAuraSpellRanks(id) end
end

local function ValidateSpellInput(_, text)
  text = Trim(text or "")
  if text == "" then return true end
  local id = tonumber(text)
  if id then
    if id > 0 and id < MAX_SPELL_ID and id == math.floor(id) then return true end
    return L["Enter a positive whole-number Spell ID."]
  end
  if ResolveSpellName(text) then return true end
  return L["Unknown spell name. Enter its Spell ID, or its exact name as shown in the game."]
end

local function ExpandSpellNameInput(option, trigger, storage, index)
  local defaultSet = option.set
  option.validate = ValidateSpellInput
  option.set = function(info, text)
    local ids = ResolveSpellName(text)
    if not ids then
      if type(text) == "string" and Trim(text) == "" then text = "" end
      return defaultSet(info, text)
    end
    local list = trigger[storage] or {}
    trigger[storage] = list
    local present = {}
    for position, entry in pairs(list) do
      local id = tonumber(entry)
      if id and position ~= index then present[id] = true end
    end
    local added = {}
    for _, id in ipairs(ids) do
      if not present[id] then
        present[id] = true
        added[#added + 1] = tostring(id)
      end
    end
    if #added == 0 then return defaultSet(info, "") end
    list[index] = added[1]
    for position = 2, #added do list[#list + 1] = added[position] end
    defaultSet(info, added[1])
  end
end

local function Toggle(context, field, name, order, desc, hidden, falseAsNil)
  local trigger = context.trigger
  return {
    type = "toggle", name = name, desc = desc, order = order, width = normalWidth, hidden = hidden,
    get = function() return trigger[field] and true or false end,
    set = function(_, value)
      if falseAsNil and not value then value = nil end
      context.Save(field, value)
    end,
  }
end

local function Label(name, order)
  return { type = "toggle", name = name, order = order, width = normalWidth, disabled = true, get = function() return true end }
end

local function AddUnitOptions(context)
  local options, trigger, display = context.options, context.trigger, context.display
  local function NotMember() return trigger.unit ~= "member" end

  options.alwaysActive = {
    type = "description", name = "|cffffffff" .. L["Note: Trigger Always Active"] .. "|r", order = 1.95, width = "full", fontSize = "medium",
  }
  options.help = {
    type = "description", order = 2, width = "full", fontSize = "small",
    name = function() return display.TriggerStatus(context.data, trigger) end,
  }
  options.unitLabel = Label(L["Unit"], 3)
  options.unit = {
    type = "select", name = L["Unit"], order = 3.01, width = normalWidth, values = display.units,
    get = function() return trigger.unit end,
    set = function(_, value) context.Save("unit", value) end,
  }
  options.specificUnitSpace = { type = "description", name = "", order = 3.02, width = normalWidth, hidden = NotMember }
  options.specificUnit = {
    type = "input", name = L["Specific Unit"], order = 3.03, width = normalWidth, hidden = NotMember,
    desc = L["party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5."],
    validate = function(_, text)
      if display.SpecificUnit({ specificUnit = text }) then return true end
      return L["Enter a unit such as party1, raid5, boss1 or arena2."]
    end,
    get = function() return trigger.specificUnit or "" end,
    set = function(_, text)
      local unit = Trim(text or ""):lower()
      context.Save("specificUnit", unit ~= "" and unit or nil)
    end,
  }
end

local function AddAuraTypeOption(context)
  local options, trigger = context.options, context.trigger

  local function AuraTypeLabel(key)
    local choice = AURA_TYPE_CHOICES[key]
    return choice and choice.label or key
  end
  local function Selected()
    local classification = trigger.processedAuraType or "any"
    local pair = classification .. ":" .. tostring(trigger.debuffType)
    local key = AURA_TYPE_BY_PAIR[pair]
    if key then return key end
    if classification == "any" then return trigger.debuffType end
    return pair, classification
  end

  options.auraTypeLabel = Label(L["Aura Type"], 4)
  options.debuffType = {
    type = "select", name = L["Aura Type"], order = 4.01, width = normalWidth,
    desc = L["Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden."],
    values = function()
      local values = {}
      for key, choice in pairs(AURA_TYPE_CHOICES) do values[key] = choice.label end
      local pair, classification = Selected()
      if classification then
        values[pair] = L["%s (%s filter)"]:format(AuraTypeLabel(classification), AuraTypeLabel(tostring(trigger.debuffType)))
      end
      return values
    end,
    sorting = function()
      local sorting = { unpack(AURA_TYPE_SORTING) }
      local pair, classification = Selected()
      if classification then sorting[#sorting + 1] = pair end
      return sorting
    end,
    get = function() return (Selected()) end,
    set = function(_, value)
      local choice = AURA_TYPE_CHOICES[value]
      if not choice then return end
      trigger.debuffType = choice.debuffType
      if not choice.unitFrameSort and trigger.sortMethod == "UnitFrameDebuff" then trigger.sortMethod = "Default" end
      context.Save("processedAuraType", choice.processedAuraType)
    end,
  }
end

local function AddGroupOptions(context)
  local options, trigger = context.options, context.trigger
  local function NotGroup() return not GROUP_UNITS[trigger.unit] end
  local function HiddenUnless(field)
    return function() return not (GROUP_UNITS[trigger.unit] and trigger[field]) end
  end

  options.useUnitNames = Toggle(context, "useUnitNames", L["Player Name(s)"], 4.1,
    L["Only track these group members. This also limits which units can play configured aura sounds."], NotGroup)
  options.unitNames = {
    type = "input", name = L["Player Names"], order = 4.2, width = "full", hidden = HiddenUnless("useUnitNames"),
    desc = L["Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match."],
    get = function() return table.concat(trigger.unitNames or {}, ", ") end,
    set = function(_, text)
      local names = {}
      for part in (text or ""):gmatch("[^,]+") do
        local name = Trim(part)
        if name ~= "" then names[#names + 1] = name end
      end
      context.Save("unitNames", names)
    end,
  }
  options.useUnitRoles = Toggle(context, "useUnitRoles", L["Group Role"], 4.3,
    L["Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled."],
    NotGroup)
  options.unitRoles = {
    type = "multiselect", name = L["Group Roles"], order = 4.4, width = "full", hidden = HiddenUnless("useUnitRoles"),
    desc = L["Uses Blizzard's assigned group role. Members without a role assigned match Unassigned."],
    values = { TANK = L["Tank"], HEALER = L["Healer"], DAMAGER = L["Damage"], NONE = L["Unassigned"] },
    get = function(_, role) return (trigger.unitRoles and trigger.unitRoles[role]) == true end,
    set = function(_, role, checked)
      local roles = trigger.unitRoles or {}
      roles[role] = checked or nil
      context.Save("unitRoles", roles)
    end,
  }
  options.ignoreDead = Toggle(context, "ignoreDead", L["Ignore Dead"], 4.41,
    L["Hide this member's auras while it is dead or a ghost."], NotGroup, true)
  options.ignoreDisconnected = Toggle(context, "ignoreDisconnected", L["Ignore Disconnected"], 4.42,
    L["Hide this member's auras while it is offline."], NotGroup, true)
  options.useIncludePets = Toggle(context, "use_includePets", L["Include Pets"], 4.5,
    L["Also track the pets of the group members."], NotGroup)
  local savePets = options.useIncludePets.set
  options.useIncludePets.set = function(info, value)
    if value and not trigger.includePets then trigger.includePets = "PlayersAndPets" end
    savePets(info, value)
  end
  options.includePets = {
    type = "select", name = L["Include Pets"], order = 4.6, width = normalWidth, hidden = HiddenUnless("use_includePets"),
    values = { PlayersAndPets = L["Players and Pets"], PetsOnly = L["Pets only"] },
    get = function() return trigger.includePets end,
    set = function(_, value) context.Save("includePets", value) end,
  }
end

local function AddSpellLists(context)
  local options, trigger, display = context.options, context.trigger, context.display
  options.spellSelectionHeader = { type = "header", name = L["Spell Selection Filters"], order = 4.7 }

  for _, list in ipairs(SPELL_LISTS) do
    local function Enabled() return display[list.enabled](trigger) and true or false end
    options[list.toggle] = {
      type = "toggle", name = list.caption, desc = list.desc, order = list.order, width = normalWidth - 0.2,
      get = Enabled,
      set = function(_, value) context.Save(list.flag, value) end,
    }
    options[list.prefix .. "DisabledSpace"] = {
      type = "description", name = "", order = list.order + 0.001, width = normalWidth + 0.2, hidden = Enabled,
    }
    local size = #(trigger[list.storage] or {}) + 1
    OptionsPrivate.CreateAuraSpellOptions(options, context.data, context.triggernum, size, true, false, list.prefix,
      list.order, list.flag, list.storage, list.inputName, nil, false, Enabled)
    for index = 1, size do
      ExpandSpellNameInput(options[list.prefix .. index], trigger, list.storage, index)
    end
    if list.storage == "auraRankSpellIDs" then
      local function UnsupportedRanks()
        local missing = {}
        for _, entry in ipairs(trigger.auraRankSpellIDs or {}) do
          local id = tonumber(entry)
          if id and not OptionsPrivate.Private.AuraSpellRankSupported(id) then missing[#missing + 1] = entry end
        end
        return missing
      end
      options.rankCoverage = {
        type = "description", order = 5.9, width = "full", fontSize = "small",
        hidden = function() return not (Enabled() and #UnsupportedRanks() > 0) end,
        name = function()
          return L["Other ranks could not be found for: %s. Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)."]:format(table.concat(UnsupportedRanks(), ", "))
        end,
      }
    end
  end
end

local function TriState(caption, desc, order, read, write, hidden)
  return {
    type = "toggle", desc = desc, order = order, width = "full", hidden = hidden,
    name = function()
      local value = read()
      if value == nil then return caption end
      if value then return "|cFF00FF00" .. caption .. "|r" end
      return "|cFFFF0000" .. L["Not %s"]:format(caption) .. "|r"
    end,
    get = function()
      local value = read()
      if value == nil then return false end
      return tostring(value)
    end,
    set = function(_, checked)
      local value
      if checked then
        value = true
      elseif read() ~= false then
        value = false
      end
      write(value)
    end,
  }
end

local function AddFilters(context)
  local options, trigger, display = context.options, context.trigger, context.display
  local function FilterHidden(field, nameplateOnly)
    return function()
      if not display.FilterApplies(field, trigger) then return true end
      return nameplateOnly and trigger.unit ~= "nameplate"
    end
  end

  local function AddTriState(key, option)
    local sharedOrder = SHARED_ROW_ORDERS[key]
    if sharedOrder then
      option.order, option.width = sharedOrder, normalWidth
    end
    options[key] = option
  end

  options.filtersHeader = { type = "header", name = L["Aura Filters"], order = 10 }

  for rank, row in ipairs(display.booleanFilters) do
    local field, caption, tooltip = row[1], row[2], row[3]
    local nameplateDescription = NAMEPLATE_FILTER_DESCRIPTIONS[field]
    AddTriState(field, TriState(caption, nameplateDescription or tooltip, 10 + rank,
      function() return trigger[field] end,
      function(value) context.Save(field, value) end,
      FilterHidden(field, nameplateDescription ~= nil)))
  end

  for rank, row in ipairs(display.nativeFilters) do
    local field, caption, tooltip = row[1], row[2], row[3]
    AddTriState("native" .. field, TriState(caption, tooltip, 20 + rank / 20,
      function() return trigger.nativeFilters and trigger.nativeFilters[field] end,
      function(value) context.SaveEntry("nativeFilters", field, value) end,
      FilterHidden(field, false)))
  end

  options.includeNameplateOnly = {
    type = "toggle", name = L["Include nameplate-only auras"], order = 21, width = "full",
    desc = L["Also allows auras normally returned only for nameplate displays. Other filters still apply."],
    hidden = function() return trigger.unit ~= "nameplate" end,
    get = function() return trigger.includeNameplateOnly and true or false end,
    set = function(_, value) context.Save("includeNameplateOnly", value) end,
  }

  for field, setting in pairs({ includeDispelTypes = { L["Include dispel types"], 24 }, excludeDispelTypes = { L["Exclude dispel types"], 25 } }) do
    options[field] = {
      type = "multiselect", name = setting[1], order = setting[2], width = "full",
      values = display.dispelTypes,
      get = function(_, dispelType) return (trigger[field] and trigger[field][dispelType]) == true end,
      set = function(_, dispelType, checked) context.SaveEntry(field, dispelType, checked or nil) end,
    }
  end
end

local function BuildOptions(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local context = {
    options = {}, data = data, triggernum = triggernum, trigger = trigger,
    display = OptionsPrivate.Private.BlizzardAuraDisplay,
  }
  function context.Save(field, value)
    trigger[field] = value
    OptionsPrivate.SaveAuraTrigger(data, triggernum)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
  function context.SaveEntry(field, key, value)
    local copy = {}
    for entryKey, entryValue in pairs(trigger[field] or {}) do copy[entryKey] = entryValue end
    copy[key] = value
    context.Save(field, next(copy) ~= nil and copy or nil)
  end

  AddUnitOptions(context)
  AddAuraTypeOption(context)
  AddGroupOptions(context)
  AddSpellLists(context)
  AddFilters(context)
  local options = context.options
  OptionsPrivate.commonOptions.AddCommonTriggerOptions(options, data, triggernum, true)
  OptionsPrivate.AuraEditor.AddOptions(options, data, triggernum)
  OptionsPrivate.AddTriggerMetaFunctions(options, data, triggernum)
  return { ["trigger." .. triggernum .. ".secretAura"] = options }
end

WeakAuras.RegisterTriggerSystemOptions({ "secretAura" }, BuildOptions)

if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local viewStates = setmetatable({}, {__mode = "k"})

local EXPECTED_EVENT_BUFF = "Blizzard CDM Buff"
local EXPECTED_EVENT_ITEM = "Blizzard CDM Item"
local COMPARISON_OPERATORS = {"<", "<=", ">", ">="}
local SECONDS_ERROR = "Enter a non-negative number of seconds."

local function NewOperatorValues(withEquality)
  local values = {}
  for _, symbol in ipairs(COMPARISON_OPERATORS) do values[symbol] = symbol end
  if withEquality then
    values["=="] = "="
    values["~="] = "!="
  end
  return values
end

local function ValidateSeconds(_, value)
  local number = tonumber(value)
  return (number and number >= 0 and number < math.huge) or SECONDS_ERROR
end

local function ValidateWholeCount(_, value)
  local number = tonumber(value)
  return (number and number >= 0 and number < math.huge and number == math.floor(number))
    or "Enter a non-negative whole number."
end

local function ValidateIdentifier(isItem)
  return function(_, value)
    if value == "" then return true end
    local id = tonumber(value)
    return (id and id > 0 and id < 2147483647 and id == math.floor(id))
      or (isItem and "Enter a positive whole-number Item ID." or "Enter a positive whole-number Spell ID.")
  end
end

local function ResolveViewState(data, triggerIndex)
  local perData = viewStates[data]
  if not perData then
    perData = {}
    viewStates[data] = perData
  end
  local view = perData[triggerIndex]
  if not view then
    view = {}
    perData[triggerIndex] = view
  end
  return view
end

local function PurgeStaleOptions(options)
  for key in pairs(options) do
    if key:find("cdmSpells", 1, true) or key:find("cdmShowGCD", 1, true) then
      options[key] = nil
    end
  end
end

local function MigrateLegacySpell(Private, trigger, data)
  if trigger.cdmSpell == nil then return end
  if trigger.cdmSelection ~= "spell" and trigger.event == "Blizzard Cooldown Manager" then
    local resolved = Private.ResolveCDMSpell(trigger, "OPTIONS")
    local catalog = Private.CDMCatalog()
    local known = #resolved == 1 and catalog[resolved[1]]
    local info = known and C_CooldownViewer.GetCooldownViewerCooldownInfo(resolved[1])
    if info and (info.equipSlot or info.spellCategoryID) then
      trigger.event = EXPECTED_EVENT_ITEM
    end
  end
  if tostring(trigger.cdmSpell):find("%S") then
    local text = tostring(trigger.cdmSpell)
    if trigger.cdmExact then
      trigger.cdmExactIDs = trigger.cdmExactIDs or {text}
      trigger.cdmUseExactIDs = true
    else
      trigger.cdmNames = trigger.cdmNames or {text}
      trigger.cdmUseNames = true
    end
  end
  trigger.cdmSpell, trigger.cdmExact = nil, nil
  C_Timer.After(0, function()
    WeakAuras.Add(data)
    Private.UpdateFakeStatesFor(data.id)
  end)
end

local function BuildEntryRows(Private, trigger, catalog)
  local rows, highestRank = {}, {}
  local isItem = trigger.event == EXPECTED_EVENT_ITEM
  for id, entry in pairs(catalog) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info and Private.CDMEntryMatches(trigger, entry, info) then
      local identity = Private.CDMIdentity(id, entry, info)
      local spellID = info.spellID or identity.spellID
      local spell = spellID and C_Spell.GetSpellInfo(spellID)
      local name = not isItem and spell and spell.name or identity.name
      local rankText = not isItem and spellID and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)
      local rank = rankText and tonumber(rankText:match("%d+")) or 0
      local label = name
      if rankText and rankText ~= "" then label = label .. " (" .. rankText .. ")" end
      local shownID = isItem and identity.itemID or spellID
      if shownID then label = label .. " [" .. shownID .. "]" end
      rows[#rows + 1] = {
        id = id,
        name = name,
        label = label,
        rank = rank,
        known = entry.known,
        icon = not isItem and spell and spell.iconID or identity.icon,
        category = Private.CDMCategoryName(entry.category),
      }
      highestRank[name] = math.max(highestRank[name] or 0, rank)
    end
  end
  table.sort(rows, function(left, right)
    if left.name ~= right.name then return left.name < right.name end
    if left.rank ~= right.rank then return left.rank > right.rank end
    return left.id < right.id
  end)
  return rows, highestRank
end

function OptionsPrivate.AddCooldownViewerOptions(options, data, triggernum)
  local Private = OptionsPrivate.Private
  local trigger = data.triggers[triggernum].trigger
  Private.MigrateCDMCooldownTrigger(trigger)
  if trigger.type == "cdm" then
    trigger.cdmSource = trigger.event == EXPECTED_EVENT_BUFF and "buff" or "cooldown"
  end
  local view = ResolveViewState(data, triggernum)
  PurgeStaleOptions(options)

  local function Refresh()
    WeakAuras.ClearAndUpdateOptions(data.id)
  end

  local function Save(key, value)
    trigger[key] = value
    WeakAuras.Add(data)
    Private.ScanForLoads({[data.id] = true})
    WeakAuras.UpdateThumbnail(data)
    Private.UpdateFakeStatesFor(data.id)
    Refresh()
  end

  local nextOrder = 10.01
  local function Add(key, option)
    option.order = nextOrder
    nextOrder = nextOrder + 0.001
    options["cdmPicker_" .. key] = option
  end

  local function IsBuff() return trigger.cdmSource == "buff" end
  local function IsItem() return trigger.event == EXPECTED_EVENT_ITEM end
  local function IsNotBuffEvent() return trigger.event ~= EXPECTED_EVENT_BUFF end
  local function HiddenOutsideExtras()
    return IsBuff() or IsItem() or not view.extra
  end

  local function AddToggle(key, name, stateKey, width, extra)
    local option = {
      type = "toggle", name = name, width = width,
      get = function() return trigger[stateKey] or false end,
      set = function(_, value) Save(stateKey, value) end,
    }
    for field, value in pairs(extra or {}) do option[field] = value end
    Add(key, option)
  end

  local function AddThresholdFilter(prefix, spec)
    local halfWidth = WeakAuras.normalWidth - 0.5
    local function HiddenUnlessEnabled()
      return IsNotBuffEvent() or not trigger[spec.enableKey]
    end
    AddToggle(prefix .. "Enabled", spec.title, spec.enableKey, WeakAuras.normalWidth, {
      hidden = IsNotBuffEvent,
      desc = spec.desc,
    })
    Add(prefix .. "Operator", {
      type = "select", name = "", width = 0.5,
      values = NewOperatorValues(spec.withEquality),
      hidden = HiddenUnlessEnabled,
      get = function() return trigger[spec.operatorKey] or spec.defaultOperator end,
      set = function(_, value) Save(spec.operatorKey, value) end,
    })
    Add(prefix .. spec.valueSuffix, {
      type = "input", name = spec.valueLabel, width = halfWidth,
      hidden = HiddenUnlessEnabled,
      get = function() return tostring(trigger[spec.valueKey] or spec.defaultValue) end,
      validate = spec.validate,
      set = function(_, value) Save(spec.valueKey, tonumber(value)) end,
    })
  end

  trigger.cdmSpells = trigger.cdmSpells or {multi = {}}
  trigger.cdmSpells.multi = trigger.cdmSpells.multi or {}
  local selected = trigger.cdmSpells.multi
  MigrateLegacySpell(Private, trigger, data)

  Add("typeSpacer", {type = "description", name = " ", width = "full"})
  Add("help", {
    type = "description", width = "full",
    name = "Spells must be active in the CDM to be displayed. Type /cdm and add them.",
  })
  Add("open", {
    type = "execute", name = "Open CDM", width = WeakAuras.normalWidth,
    disabled = function() return InCombatLockdown() or not C_CooldownViewer end,
    func = function()
      if not C_AddOns.IsAddOnLoaded("Blizzard_CooldownViewer") then
        C_AddOns.LoadAddOn("Blizzard_CooldownViewer")
      end
      if CooldownViewerSettings then ShowUIPanel(CooldownViewerSettings) end
    end,
  })
  Add("refresh", {
    type = "execute", name = "Refresh from Blizzard CDM", width = WeakAuras.normalWidth, func = Refresh,
  })
  Add("display", {type = "header", name = "Display", hidden = IsItem})
  Add("show", {
    type = "select", name = "Show", width = WeakAuras.normalWidth,
    desc = "Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches.",
    values = {always = "Always", cooldown = "On Cooldown", ready = "Not on Cooldown", usable = "Usable", unusable = "Not Usable"},
    hidden = function() return IsBuff() or IsItem() end,
    get = function() return trigger.cdmShow or "always" end,
    set = function(_, value) Save("cdmShow", value) end,
  })
  Add("buffShow", {
    type = "select", name = "Show", width = WeakAuras.normalWidth,
    values = {always = "Always", active = "Aura Active", missing = "Aura Missing"},
    hidden = function() return not IsBuff() end,
    get = function() return trigger.cdmBuffShow or "active" end,
    set = function(_, value) Save("cdmBuffShow", value) end,
  })
  AddToggle("requireTarget", "Require attackable target", "cdmRequireTarget", WeakAuras.normalWidth, {
    hidden = function() return not IsBuff() end,
    desc = "Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes.",
  })

  AddThresholdFilter("remaining", {
    title = "Remaining Time", valueLabel = "Seconds", valueSuffix = "Seconds",
    desc = "Filters active, timed auras using readable CDM remaining time. Missing, permanent, or secret timers do not match.",
    enableKey = "cdmUseRemaining", operatorKey = "cdmRemainingOperator", defaultOperator = "<",
    valueKey = "cdmRemainingTime", defaultValue = 10, validate = ValidateSeconds,
  })
  AddThresholdFilter("total", {
    title = "Total Duration", valueLabel = "Seconds", valueSuffix = "Seconds",
    desc = "Filters active, timed auras using readable CDM total time. Missing, permanent, or secret timers do not match.",
    enableKey = "cdmUseTotal", operatorKey = "cdmTotalOperator", defaultOperator = "<",
    valueKey = "cdmTotalTime", defaultValue = 10, validate = ValidateSeconds,
  })
  AddThresholdFilter("elapsed", {
    title = "Elapsed Time", valueLabel = "Seconds", valueSuffix = "Seconds",
    desc = "Filters active, timed auras using readable CDM elapsed time. Missing, permanent, or secret timers do not match.",
    enableKey = "cdmUseElapsed", operatorKey = "cdmElapsedOperator", defaultOperator = ">=",
    valueKey = "cdmElapsedTime", defaultValue = 10, validate = ValidateSeconds,
  })
  AddThresholdFilter("stacks", {
    title = "Stack Count", valueLabel = "Stacks", valueSuffix = "Count",
    desc = "Filters active auras using readable CDM stack counts. Missing or secret stack counts do not match. All enabled filters must match.",
    enableKey = "cdmUseStacks", operatorKey = "cdmStackOperator", defaultOperator = ">=",
    valueKey = "cdmStackCount", defaultValue = 1, validate = ValidateWholeCount, withEquality = true,
  })

  Add("extra", {
    type = "execute", control = "WeakAurasExpandSmall", width = "full",
    hidden = function() return IsBuff() or IsItem() end,
    name = function()
      local parts = {}
      if trigger.cdmTrack == "cooldown" then
        parts[#parts + 1] = "Cooldown"
      elseif trigger.cdmTrack == "charges" then
        parts[#parts + 1] = "Charge recharge"
      end
      if trigger.use_ignoreSpellKnown then parts[#parts + 1] = "Disable Spell Known Check" end
      if trigger.use_cdmShowGCD then parts[#parts + 1] = "Show GCD" end
      if trigger.cdmHideGCDText ~= false then parts[#parts + 1] = "Hide GCD text" end
      return "|cFFffcc00Extra Options:|r " .. (#parts > 0 and table.concat(parts, "; ") or "None")
    end,
    image = function() return view.extra and "expanded" or "collapsed" end,
    imageWidth = 15, imageHeight = 15,
    func = function()
      view.extra = not view.extra
      Refresh()
    end,
  })
  Add("track", {
    type = "select", name = "Track cooldowns", width = WeakAuras.normalWidth,
    hidden = HiddenOutsideExtras,
    values = {auto = "Auto", cooldown = "Cooldown", charges = "Charge recharge"},
    get = function() return trigger.cdmTrack or "auto" end,
    set = function(_, value) Save("cdmTrack", value) end,
  })
  Add("trackSpacer", {type = "description", name = "", width = WeakAuras.normalWidth, hidden = HiddenOutsideExtras})
  AddToggle("includeGCD", "Show global cooldown", "use_cdmShowGCD", "full", {hidden = HiddenOutsideExtras})
  Add("hideGCDText", {
    type = "toggle", name = "Hide global cooldown text", width = "full",
    hidden = HiddenOutsideExtras,
    desc = "Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown.",
    get = function() return trigger.cdmHideGCDText ~= false end,
    set = function(_, value) Save("cdmHideGCDText", value) end,
  })
  AddToggle("ignoreSpellKnown", "Disable Spell Known Check", "use_ignoreSpellKnown", "full", {hidden = HiddenOutsideExtras})

  nextOrder = 20
  Add("spellSelection", {type = "header", name = "Spell Selection Filters"})

  local function AddSelector(title, label, prefix, flag, storage, exact, baseOrder, isItem)
    options[prefix .. "Toggle"] = {
      type = "toggle", name = title, width = WeakAuras.normalWidth - 0.2, order = baseOrder,
      get = function() return trigger[flag] or false end,
      set = function(_, value) Save(flag, value) end,
    }
    options[prefix .. "DisabledSpace"] = {
      type = "description", name = "", width = WeakAuras.normalWidth + 0.2, order = baseOrder + 0.001,
      hidden = function() return trigger[flag] == true end,
    }
    local size = #(trigger[storage] or {}) + 1
    OptionsPrivate.CreateAuraSpellOptions(options, data, triggernum, size, exact, false,
      prefix, baseOrder, flag, storage, label, nil, false, function() return trigger[flag] == true end,
      function() Save(storage, trigger[storage]) end)
    for index = 1, size do
      local input = options[prefix .. index]
      if isItem then
        local function LookupItemName()
          local id = tonumber(trigger[storage] and trigger[storage][index])
          Private.CDMRequestItemData(id)
          return id and C_Item and C_Item.GetItemNameByID(id)
        end
        local icon = options[prefix .. "icon" .. index]
        icon.name = function() return LookupItemName() or "" end
        icon.image = function()
          local id = tonumber(trigger[storage] and trigger[storage][index])
          local texture = id and C_Item and C_Item.GetItemIconByID(id)
          return texture and tostring(texture) or "", 18, 18
        end
        icon.disabled = function() return not LookupItemName() end
        input.get = function()
          local raw = trigger[storage] and trigger[storage][index]
          if not raw then return "" end
          return ("%s (%s)"):format(raw, LookupItemName() or "Unknown Item") .. "\0" .. raw
        end
      end
      if exact then input.validate = ValidateIdentifier(isItem) end
    end
  end

  AddSelector("Name(s)", IsBuff() and "Aura Name" or "Spell Name", "cdmPicker_name", "cdmUseNames", "cdmNames", false, 21)
  AddSelector("Exact Spell ID(s)", "Spell ID", "cdmPicker_spellid", "cdmUseExactIDs", "cdmExactIDs", true, 25)
  if IsItem() then
    AddSelector("Exact Item ID(s)", "Item ID", "cdmPicker_itemid", "cdmUseItemIDs", "cdmItemIDs", true, 29, true)
  end

  nextOrder = 35
  Add("filters", {type = "header", name = "Blizzard CDM Filters"})
  Add("search", {
    type = "input", name = "Search", width = "full",
    get = function() return view.search or "" end,
    set = function(_, value)
      view.search = value
      Refresh()
    end,
  })
  Add("available", {
    type = "toggle", name = "Show only available", width = WeakAuras.normalWidth,
    get = function() return view.availableOnly or false end,
    set = function(_, value)
      view.availableOnly = value
      Refresh()
    end,
  })
  Add("maxRank", {
    type = "toggle", name = "Show only max rank", width = WeakAuras.normalWidth,
    get = function() return view.maxRank or false end,
    set = function(_, value)
      view.maxRank = value
      Refresh()
    end,
  })
  Add("entries", {type = "header", name = "Blizzard CDM Entries"})

  local catalog = C_CooldownViewer and Private.CDMCatalog() or {}
  local rows, highestRank = BuildEntryRows(Private, trigger, catalog)
  local query = (view.search or ""):lower()
  for _, row in ipairs(rows) do
    local passesAvailability = not view.availableOnly or row.known
    local passesRank = not view.maxRank or row.rank == highestRank[row.name]
    if passesAvailability and row.label:lower():find(query, 1, true) and passesRank then
      Add("entry" .. row.id, {
        type = "toggle", name = row.label, desc = row.category, width = "full",
        image = row.icon, imageWidth = 18, imageHeight = 18,
        get = function() return selected[row.id] or selected[tostring(row.id)] or false end,
        set = function(_, value)
          selected[row.id] = nil
          selected[tostring(row.id)] = value or nil
          Save("cdmSpells", trigger.cdmSpells)
        end,
      })
    end
  end
end

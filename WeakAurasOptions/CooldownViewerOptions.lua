-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local L = WeakAuras.L

local PREFIX = "cdmPicker_"
local EVENT_COOLDOWN = "Blizzard Cooldown Manager"
local EVENT_BUFF = "Blizzard CDM Buff"
local EVENT_ITEM = "Blizzard CDM Item"
local VIEWER_ADDON = "Blizzard_CooldownViewer"
local MAX_ID = 2147483647
local STEP = 0.001

local COMPARISONS = { ["<"] = "<", ["<="] = "<=", [">"] = ">", [">="] = ">=" }
local STACK_COMPARISONS = { ["<"] = "<", ["<="] = "<=", [">"] = ">", [">="] = ">=", ["=="] = "=", ["~="] = "!=" }

local SHOW_MODES = {
  always = L["Always"], cooldown = L["On Cooldown"], ready = L["Not on Cooldown"], usable = L["Usable"], unusable = L["Not Usable"],
}
local BUFF_SHOW_MODES = { always = L["Always"], active = L["Aura Active"], missing = L["Aura Missing"] }
local TRACK_MODES = { auto = L["Auto"], cooldown = L["Cooldown"], charges = L["Charge recharge"] }

local function TimedFilterDesc(what)
  return L["Filters active, timed auras using readable CDM %s time. Missing and permanent timers, or timers the game hides, do not match."]:format(what)
end

local NUMERIC_FILTERS = {
  { key = "remaining", label = L["Remaining Time"], desc = TimedFilterDesc(L["remaining"]),
    enabled = "cdmUseRemaining", operator = "cdmRemainingOperator", defaultOperator = "<",
    amount = "cdmRemainingTime", defaultAmount = 10 },
  { key = "total", label = L["Total Duration"], desc = TimedFilterDesc(L["total"]),
    enabled = "cdmUseTotal", operator = "cdmTotalOperator", defaultOperator = "<",
    amount = "cdmTotalTime", defaultAmount = 10 },
  { key = "elapsed", label = L["Elapsed Time"], desc = TimedFilterDesc(L["elapsed"]),
    enabled = "cdmUseElapsed", operator = "cdmElapsedOperator", defaultOperator = ">=",
    amount = "cdmElapsedTime", defaultAmount = 10 },
  { key = "stacks", label = L["Stack Count"],
    desc = L["Filters active auras using readable CDM stack counts. Missing stack counts, or counts the game hides, do not match. All enabled filters must match."],
    enabled = "cdmUseStacks", operator = "cdmStackOperator", defaultOperator = ">=",
    amount = "cdmStackCount", defaultAmount = 1, whole = true },
}

local SELECTION_GROUPS = {
  { prefix = "name", label = L["Name(s)"], use = "cdmUseNames", list = "cdmNames", order = 21 },
  { prefix = "spellid", label = L["Exact Spell ID(s)"], row = L["Spell ID"], use = "cdmUseExactIDs", list = "cdmExactIDs",
    order = 25, invalid = L["Enter a positive whole-number Spell ID."] },
  { prefix = "itemid", label = L["Exact Item ID(s)"], row = L["Item ID"], use = "cdmUseItemIDs", list = "cdmItemIDs",
    order = 29, invalid = L["Enter a positive whole-number Item ID."], itemOnly = true },
}

local viewStates = setmetatable({}, { __mode = "k" })

local function GetViewState(data, triggernum)
  local perTrigger = viewStates[data]
  if not perTrigger then
    perTrigger = {}
    viewStates[data] = perTrigger
  end
  perTrigger[triggernum] = perTrigger[triggernum] or { expanded = false, search = "", available = false, maxRank = false }
  return perTrigger[triggernum]
end

local function EventKind(trigger)
  if trigger.event == EVENT_BUFF then return "buff" end
  if trigger.event == EVENT_ITEM then return "item" end
  return "spell"
end

local function ParseAmount(text, whole)
  local value = tonumber(text)
  if not value or value ~= value or value < 0 or value == math.huge then return nil end
  if whole and value % 1 ~= 0 then return nil end
  return value
end

local function IsValidID(text)
  local value = tonumber(text)
  return value ~= nil and value > 0 and value < MAX_ID and value % 1 == 0
end

local LEGACY_TARGETS = {
  [true] = { list = "cdmExactIDs", use = "cdmUseExactIDs" },
  [false] = { list = "cdmNames", use = "cdmUseNames" },
}

local function LegacyQueryIsItem(Private, trigger)
  if trigger.cdmSelection == "spell" or trigger.event ~= EVENT_COOLDOWN or not C_CooldownViewer then
    return false
  end
  local selection = Private.ResolveCDMSpell(trigger, "OPTIONS")
  if not selection or #selection ~= 1 then return false end
  local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(selection[1])
  return info ~= nil and (info.equipSlot ~= nil or info.spellCategoryID ~= nil)
end

local function MigrateLegacySpell(Private, data, trigger)
  local text = tostring(trigger.cdmSpell)
  local target = LEGACY_TARGETS[trigger.cdmExact and true or false]
  if LegacyQueryIsItem(Private, trigger) then
    trigger.event = EVENT_ITEM
  end
  trigger.cdmSpell, trigger.cdmExact = nil, nil

  if text:find("%S") then
    trigger[target.list] = trigger[target.list] or { text }
    trigger[target.use] = true
  end

  C_Timer.After(0, function()
    WeakAuras.Add(data)
    Private.UpdateFakeStatesFor(data.id)
  end)
end

local function PrepareTrigger(Private, data, trigger)
  Private.MigrateCDMCooldownTrigger(trigger)
  if trigger.cdmSpell ~= nil then
    MigrateLegacySpell(Private, data, trigger)
  end
  trigger.cdmSource = trigger.event == EVENT_BUFF and "buff" or "cooldown"
  trigger.cdmSpells = trigger.cdmSpells or {}
  trigger.cdmSpells.multi = trigger.cdmSpells.multi or {}
end

local function Saved(context, option, field, default)
  local trigger = context.trigger
  option.get = function()
    local value = trigger[field]
    if value == nil then return default end
    return value
  end
  option.set = function(_, value)
    trigger[field] = value
    context.commit()
  end
  return option
end

local function Viewed(context, option, field)
  option.get = function() return context.view[field] end
  option.set = function(_, value)
    context.view[field] = value
    context.refresh()
  end
  return option
end

local function Place(options, base, entries)
  for index, entry in ipairs(entries) do
    local option = entry[2]
    option.order = base + (index - 1) * STEP
    options[PREFIX .. entry[1]] = option
  end
end

local function NumericFilterEntries(context, filter, entries)
  local trigger = context.trigger
  local N = WeakAuras.normalWidth
  local function notBuff() return context.kind() ~= "buff" end
  local function inactive() return notBuff() or not trigger[filter.enabled] end

  entries[#entries + 1] = { filter.key .. "Enabled", Saved(context, {
    type = "toggle", name = filter.label, desc = filter.desc, width = N, hidden = notBuff,
  }, filter.enabled, false) }

  entries[#entries + 1] = { filter.key .. "Operator", Saved(context, {
    type = "select", name = "", width = 0.5, hidden = inactive,
    values = filter.whole and STACK_COMPARISONS or COMPARISONS,
  }, filter.operator, filter.defaultOperator) }

  local invalid = filter.whole and L["Enter a non-negative whole number."] or L["Enter a non-negative number of seconds."]
  entries[#entries + 1] = { filter.key .. (filter.whole and "Count" or "Seconds"), {
    type = "input", name = filter.whole and L["Stacks"] or L["Seconds"], width = N - 0.5, hidden = inactive,
    get = function()
      local value = trigger[filter.amount]
      if value == nil then value = filter.defaultAmount end
      return tostring(value)
    end,
    set = function(_, text)
      trigger[filter.amount] = tonumber(text)
      context.commit()
    end,
    validate = function(_, text)
      return ParseAmount(text, filter.whole) ~= nil or invalid
    end,
  } }
end

local function ExtraSummary(trigger)
  local active = {}
  if trigger.cdmTrack == "cooldown" or trigger.cdmTrack == "charges" then
    active[#active + 1] = TRACK_MODES[trigger.cdmTrack]
  end
  if trigger.use_ignoreSpellKnown then active[#active + 1] = L["Disable Spell Known Check"] end
  if trigger.use_cdmShowGCD then active[#active + 1] = L["Show GCD"] end
  if trigger.cdmHideGCDText ~= false then active[#active + 1] = L["Hide GCD text"] end
  return "|cFFffcc00" .. L["Extra Options:"] .. "|r " .. (#active > 0 and table.concat(active, "; ") or L["None"])
end

local function EnsureViewerAddOn()
  return C_AddOns.IsAddOnLoaded(VIEWER_ADDON) or C_AddOns.LoadAddOn(VIEWER_ADDON)
end

local function OpenCooldownManager()
  if InCombatLockdown() then return end
  EnsureViewerAddOn()
  local panel = CooldownViewerSettings
  if panel then ShowUIPanel(panel) end
end

local function AddMainBlock(context, options)
  local trigger, view = context.trigger, context.view
  local N = WeakAuras.normalWidth
  local function is(kind) return function() return context.kind() == kind end end
  local function isNot(kind) return function() return context.kind() ~= kind end end
  local function extraClosed() return context.kind() ~= "spell" or not view.expanded end

  local entries = {
    { "typeSpacer", { type = "description", name = " ", width = "full" } },
    { "help", { type = "description", width = "full",
      name = L["Spells must be active in the CDM to be displayed. Type /cdm and add them."] } },
    { "open", { type = "execute", name = L["Open CDM"], width = N, func = OpenCooldownManager,
      disabled = function() return InCombatLockdown() or not C_CooldownViewer end } },
    { "refresh", { type = "execute", name = L["Refresh from Blizzard CDM"], width = N, func = context.refresh } },
    { "display", { type = "header", name = L["Display"], hidden = is("item") } },
    { "show", Saved(context, { type = "select", name = L["Show"], width = N, values = SHOW_MODES,
      desc = L["Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches."],
      hidden = isNot("spell") }, "cdmShow", "always") },
    { "buffShow", Saved(context, { type = "select", name = L["Show"], width = N, values = BUFF_SHOW_MODES,
      hidden = isNot("buff") }, "cdmBuffShow", "active") },
    { "requireTarget", Saved(context, { type = "toggle", name = L["Require attackable target"], width = N,
      desc = L["Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes."],
      hidden = isNot("buff") }, "cdmRequireTarget", false) },
  }

  for _, filter in ipairs(NUMERIC_FILTERS) do
    NumericFilterEntries(context, filter, entries)
  end

  entries[#entries + 1] = { "extra", {
    type = "execute", control = "WeakAurasExpandSmall", width = "full", imageWidth = 15, imageHeight = 15,
    name = function() return ExtraSummary(trigger) end,
    image = function() return view.expanded and "expanded" or "collapsed" end,
    hidden = isNot("spell"),
    func = function()
      view.expanded = not view.expanded
      context.refresh()
    end,
  } }
  entries[#entries + 1] = { "track", Saved(context, { type = "select", name = L["Track cooldowns"], width = N,
    values = TRACK_MODES, hidden = extraClosed }, "cdmTrack", "auto") }
  entries[#entries + 1] = { "trackSpacer", { type = "description", name = "", width = N, hidden = extraClosed } }
  entries[#entries + 1] = { "includeGCD", Saved(context, { type = "toggle", name = L["Show global cooldown"],
    width = "full", hidden = extraClosed }, "use_cdmShowGCD", false) }
  entries[#entries + 1] = { "hideGCDText", Saved(context, { type = "toggle", name = L["Hide global cooldown text"],
    desc = L["Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown."],
    width = "full", hidden = extraClosed }, "cdmHideGCDText", true) }
  entries[#entries + 1] = { "ignoreSpellKnown", Saved(context, { type = "toggle", name = L["Disable Spell Known Check"],
    width = "full", hidden = extraClosed }, "use_ignoreSpellKnown", false) }

  Place(options, 10.01, entries)
end

local function ItemIDAt(trigger, index)
  local list = trigger.cdmItemIDs
  return list and tonumber(list[index])
end

local function ItemName(Private, itemID)
  if not itemID then return nil end
  Private.CDMRequestItemData(itemID)
  return C_Item.GetItemNameByID(itemID)
end

local function DecorateItemRows(context, options, prefix, size)
  local Private, trigger = context.Private, context.trigger
  for index = 1, size do
    local icon = options[prefix .. "icon" .. index]
    icon.name = function() return ItemName(Private, ItemIDAt(trigger, index)) or "" end
    icon.image = function()
      local itemID = ItemIDAt(trigger, index)
      local texture = itemID and C_Item.GetItemIconByID(itemID)
      return texture and tostring(texture) or "", 18, 18
    end
    icon.disabled = function() return ItemName(Private, ItemIDAt(trigger, index)) == nil end

    options[prefix .. index].get = function()
      local raw = trigger.cdmItemIDs and trigger.cdmItemIDs[index]
      if not raw or raw == "" then return "" end
      local name = ItemName(Private, tonumber(raw)) or L["Unknown Item"]
      return ("%s (%s)"):format(raw, name) .. "\0" .. raw
    end
  end
end

local function AddSelectionGroup(context, options, group)
  local trigger, data = context.trigger, context.data
  local N = WeakAuras.normalWidth
  local prefix = PREFIX .. group.prefix
  local function enabled() return trigger[group.use] and true or false end

  options[prefix .. "Toggle"] = Saved(context, {
    type = "toggle", name = group.label, width = N - 0.2, order = group.order,
  }, group.use, false)
  options[prefix .. "DisabledSpace"] = {
    type = "description", name = "", width = N + 0.2, order = group.order + STEP, hidden = enabled,
  }

  local rowLabel = group.row or (context.kind() == "buff" and L["Aura Name"] or L["Spell Name"])
  local size = #(trigger[group.list] or {}) + 1
  OptionsPrivate.CreateAuraSpellOptions(options, data, context.triggernum, size, group.invalid ~= nil, false,
    prefix, group.order, group.use, group.list, rowLabel, nil, false, enabled, context.commit)

  if group.invalid then
    for index = 1, size do
      options[prefix .. index].validate = function(_, text)
        return text == "" or IsValidID(text) or group.invalid
      end
    end
  end
  if group.itemOnly then
    DecorateItemRows(context, options, prefix, size)
  end
end

local function AddSelectionGroups(context, options)
  options[PREFIX .. "spellSelection"] = { type = "header", name = L["Spell Selection Filters"], order = 20 }
  local isItem = context.kind() == "item"
  for _, group in ipairs(SELECTION_GROUPS) do
    if isItem or not group.itemOnly then
      AddSelectionGroup(context, options, group)
    end
  end
end

local function DescribeEntry(Private, id, entry, info, isItem)
  local identity = Private.CDMIdentity(id, entry, info) or {}
  local name, icon, shownID, subtext = identity.name, identity.icon, identity.itemID, ""
  if not isItem then
    shownID = info.spellID or identity.spellID
    local spell = shownID and C_Spell.GetSpellInfo(shownID)
    if spell then
      name = spell.name or name
      icon = spell.iconID or icon
    end
    if shownID and C_Spell.GetSpellSubtext then
      subtext = C_Spell.GetSpellSubtext(shownID) or ""
    end
  end
  name = name or ""

  local label = name
  if subtext ~= "" then label = label .. " (" .. subtext .. ")" end
  if shownID then label = label .. " [" .. shownID .. "]" end

  local rank = tonumber(subtext:match("%d+")) or 0
  return {
    id = id, name = name, label = label, icon = icon, known = entry.known, rank = rank,
    category = Private.CDMCategoryName(entry.category),
    sortKey = { name, -rank, id },
  }
end

local function BySortKey(left, right)
  for index = 1, #left.sortKey do
    local a, b = left.sortKey[index], right.sortKey[index]
    if a ~= b then return a < b end
  end
  return false
end

local function ListEntries(context)
  if not C_CooldownViewer then return {} end
  local Private, trigger, view = context.Private, context.trigger, context.view
  local isItem = context.kind() == "item"

  local candidates, bestRank = {}, {}
  for id, entry in pairs(Private.CDMCatalog() or {}) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info and Private.CDMEntryMatches(trigger, entry, info) then
      local row = DescribeEntry(Private, id, entry, info, isItem)
      candidates[#candidates + 1] = row
      bestRank[row.name] = math.max(bestRank[row.name] or 0, row.rank)
    end
  end

  local needle = view.search ~= "" and view.search:lower()
  local rows = {}
  for _, row in ipairs(candidates) do
    if (not view.available or row.known)
      and (not view.maxRank or row.rank == bestRank[row.name])
      and (not needle or row.label:lower():find(needle, 1, true)) then
      rows[#rows + 1] = row
    end
  end

  table.sort(rows, BySortKey)
  return rows
end

local function EntryOption(context, row)
  local trigger = context.trigger
  local key = tostring(row.id)
  return {
    type = "toggle", name = row.label, desc = row.category, width = "full",
    image = row.icon, imageWidth = 18, imageHeight = 18,
    get = function()
      local multi = trigger.cdmSpells.multi
      return (multi[row.id] or multi[key]) and true or false
    end,
    set = function(_, checked)
      local multi = trigger.cdmSpells.multi
      multi[row.id] = nil
      multi[key] = checked and true or nil
      context.commit()
    end,
  }
end

local function AddEntrySection(context, options)
  local N = WeakAuras.normalWidth
  local entries = {
    { "filters", { type = "header", name = L["Blizzard CDM Filters"] } },
    { "search", Viewed(context, { type = "input", name = L["Search"], width = "full" }, "search") },
    { "available", Viewed(context, { type = "toggle", name = L["Show only available"], width = N }, "available") },
    { "maxRank", Viewed(context, { type = "toggle", name = L["Show only max rank"], width = N }, "maxRank") },
    { "entries", { type = "header", name = L["Blizzard CDM Entries"] } },
  }
  for _, row in ipairs(ListEntries(context)) do
    entries[#entries + 1] = { "entry" .. row.id, EntryOption(context, row) }
  end
  Place(options, 35, entries)
end

local REPLACED_PROTOTYPE_FIELDS = { "cdmSpells", "cdmShowGCD" }

local function DropReplacedPrototypeOptions(options)
  local replaced = {}
  for key in pairs(options) do
    for _, field in ipairs(REPLACED_PROTOTYPE_FIELDS) do
      if key:find(field, 1, true) then
        replaced[#replaced + 1] = key
        break
      end
    end
  end
  for _, key in ipairs(replaced) do
    options[key] = nil
  end
end

function OptionsPrivate.AddCooldownViewerOptions(options, data, triggernum)
  local Private = OptionsPrivate.Private
  local trigger = data.triggers[triggernum].trigger
  PrepareTrigger(Private, data, trigger)

  DropReplacedPrototypeOptions(options)

  local context = {
    Private = Private, data = data, trigger = trigger, triggernum = triggernum,
    view = GetViewState(data, triggernum),
    kind = function() return EventKind(trigger) end,
    refresh = function() WeakAuras.ClearAndUpdateOptions(data.id) end,
    commit = function()
      WeakAuras.Add(data)
      Private.ScanForLoads({ [data.id] = true })
      Private.UpdateFakeStatesFor(data.id)
      WeakAuras.UpdateThumbnail(data)
      WeakAuras.ClearAndUpdateOptions(data.id)
    end,
  }

  AddMainBlock(context, options)
  AddSelectionGroups(context, options)
  AddEntrySection(context, options)
end

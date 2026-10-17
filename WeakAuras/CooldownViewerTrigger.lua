-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end

-- Cooldown Manager trigger, part 3 of 3: the four prototypes of the "cdm" trigger type.
-- One builder declares Cooldown, Buff/Debuff, Item and the legacy Utility event; they only
-- differ by kind (spell, buff, item), which drives their args, events and GCD watching.
--
-- The trigger function is still a source string compiled by Private.LoadFunction, which caches
-- by text. The chunk therefore only holds an immutable copy of the saved settings; the work is
-- done by Private.ExecEnv.UpdateCDMTrigger, which memoises an execution plan per settings table
-- and writes into the allstates of the calling aura only.

local _, Private = ...

local CooldownViewer = Private.CooldownViewer
local Catalog = CooldownViewer.Catalog
local ReadableOrNil = Private.ReadableOrNil

local FALLBACK_NAME = "Cooldown Manager"
local FALLBACK_ICON = 134400
local REMAINING_TOLERANCE = 0.05

-- Saved fields the trigger function reads; anything else stays out of the compiled text.
local SETTINGS_FIELDS = {
  "type", "event", "cdmSelection", "cdmSpell", "cdmExact", "cdmSpells",
  "cdmUseNames", "cdmNames", "cdmUseExactIDs", "cdmExactIDs", "cdmUseItemIDs", "cdmItemIDs",
  "cdmShow", "cdmBuffShow", "cdmRequireTarget", "cdmTrack", "use_cdmShowGCD", "cdmHideGCDText", "use_ignoreSpellKnown",
  "cdmUseRemaining", "cdmRemainingOperator", "cdmRemainingTime",
  "cdmUseStacks", "cdmStackOperator", "cdmStackCount",
  "cdmUseTotal", "cdmTotalOperator", "cdmTotalTime",
  "cdmUseElapsed", "cdmElapsedOperator", "cdmElapsedTime",
}

-- Buff filters in the argument order of UpdateCDMBuffFilters, with their defaults.
local BUFF_FILTERS = {
  { enabled = "cdmUseRemaining", value = "cdmRemainingTime", operator = "cdmRemainingOperator", defaultValue = 10, defaultOperator = "<" },
  { enabled = "cdmUseStacks", value = "cdmStackCount", operator = "cdmStackOperator", defaultValue = 1, defaultOperator = ">=" },
  { enabled = "cdmUseTotal", value = "cdmTotalTime", operator = "cdmTotalOperator", defaultValue = 10, defaultOperator = "<" },
  { enabled = "cdmUseElapsed", value = "cdmElapsedTime", operator = "cdmElapsedOperator", defaultValue = 10, defaultOperator = ">=" },
}

local BASE_EVENTS = {
  "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "SPELLS_CHANGED", "SPELL_UPDATE_COOLDOWN",
  "SPELL_UPDATE_CHARGES", "SPELL_UPDATE_ICON", "PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_COOLDOWN",
  "PLAYER_TARGET_CHANGED", "PLAYER_TOTEM_UPDATE",
}
local VIEWER_EVENTS = {
  "COOLDOWN_VIEWER_DATA_LOADED", "COOLDOWN_VIEWER_TABLE_HOTFIXED", "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED",
}
local KIND_EVENTS = {
  spell = { "ACTIONBAR_UPDATE_USABLE", "ACTION_USABLE_CHANGED", "SPELL_UPDATE_USABLE", "UPDATE_SHAPESHIFT_FORM" },
  item = { "GET_ITEM_INFO_RECEIVED", "ITEM_DATA_LOAD_RESULT" },
  buff = {},
}

---------------------------------------------------------------------------------------------------
-- Settings literal
---------------------------------------------------------------------------------------------------

-- Orders keys of mixed types: numbers first, then by text.
local function KeyBefore(a, b)
  if type(a) ~= type(b) then
    return type(a) == "number"
  end
  return a < b
end

-- Deterministic Lua literal of a saved value (strings, numbers, booleans and tables of them).
local function Literal(value)
  local valueType = type(value)
  if valueType == "string" then
    return string.format("%q", value)
  elseif valueType == "number" then
    return string.format("%.17g", value)
  elseif valueType == "boolean" then
    return tostring(value)
  elseif valueType ~= "table" then
    return "nil"
  end
  local keys = {}
  for key in pairs(value) do
    if type(key) == "string" or type(key) == "number" then
      keys[#keys + 1] = key
    end
  end
  table.sort(keys, KeyBefore)
  local parts = {}
  for index, key in ipairs(keys) do
    parts[index] = "[" .. Literal(key) .. "]=" .. Literal(value[key])
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

-- Source of the trigger function: a settings literal and a call to the shared runner.
local function TriggerFunction(trigger)
  CooldownViewer.SyncSource(trigger)
  local settings = {}
  for _, field in ipairs(SETTINGS_FIELDS) do
    settings[field] = trigger[field]
  end
  return "local settings = " .. Literal(settings) .. "\n"
    .. "return function(allstates, event) return Private.ExecEnv.UpdateCDMTrigger(allstates, event, settings) end"
end

---------------------------------------------------------------------------------------------------
-- Runner
---------------------------------------------------------------------------------------------------

-- Execution plan of a settings table, computed once; settings tables are never modified.
local plans = setmetatable({}, { __mode = "k" })

-- What a trigger with these settings composes, and how its buff filters apply.
local function PlanOf(settings)
  local plan = plans[settings]
  if plan then
    return plan
  end
  plan = { queries = Private.CDMSpellQueries(settings) }
  if not plan.queries then
    plan.legacy = CooldownViewer.LegacyQuery(settings)
    if not plan.legacy then
      plan.picker = CooldownViewer.QueryFromTrigger(settings, nil, false, false, settings.cdmSelection)
    end
  end
  if CooldownViewer.KindOf(settings.event) == "buff" then
    local arguments, active = {}, false
    for _, filter in ipairs(BUFF_FILTERS) do
      local enabled = settings[filter.enabled] == true
      active = active or enabled
      arguments[#arguments + 1] = enabled and tostring(settings[filter.value] or filter.defaultValue) or ""
      arguments[#arguments + 1] = settings[filter.operator] or filter.defaultOperator
    end
    plan.filters = active and arguments or nil
  end
  plans[settings] = plan
  return plan
end

-- Runs one compiled trigger: composes its states, then filters or commits them.
function Private.ExecEnv.UpdateCDMTrigger(allstates, event, settings)
  local plan = PlanOf(settings)
  local produced
  if plan.queries then
    produced = CooldownViewer.MergeQueries(plan.queries, event)
  elseif plan.legacy then
    produced = CooldownViewer.ComposeQuery(plan.legacy, event)
  else
    local selection = Private.GetCDMPickerSelections(settings, event)
    produced = CooldownViewer.ComposeStates(selection, CooldownViewer.RequestFromQuery(plan.picker, event))
  end
  if plan.filters then
    return Private.ExecEnv.UpdateCDMBuffFilters(allstates, produced, event, unpack(plan.filters))
  end
  return CooldownViewer.CommitStates(allstates, produced)
end

---------------------------------------------------------------------------------------------------
-- Prototype callbacks
---------------------------------------------------------------------------------------------------

-- Selections of every query of the trigger, as the options resolve them, in query order.
local function SelectedEntries(trigger)
  local sources = Private.CDMSpellQueries(trigger) or {}
  if #sources == 0 then
    sources = { CooldownViewer.LegacyQuery(trigger) }
  end
  local lists = {}
  for index, source in ipairs(sources) do
    lists[index] = Private.ResolveCDMSpell(source, "OPTIONS")
  end
  lists[1] = lists[1] or Private.GetCDMPickerSelections(trigger, "OPTIONS")
  return lists
end

-- Name and icon of the first selected entry that has both, or the generic ones.
local function GetNameAndIcon(trigger)
  local entries, viewerFrames = Catalog:Get("OPTIONS"), Private.CDMFrames()
  for _, selection in ipairs(SelectedEntries(trigger)) do
    for _, id in ipairs(selection) do
      local info = entries[id] and Catalog:Info(id)
      local found = info and Private.CDMIdentity(id, entries[id], info, viewerFrames[id])
      if found and found.name and found.icon then
        return found.name, found.icon
      end
    end
  end
  return FALLBACK_NAME, FALLBACK_ICON
end

-- Picker labels: every catalogue entry with its spell or item id, plus checked entries missing from it.
local function PickerValues(trigger)
  local values = {}
  if not trigger then
    return values
  end
  local catalog = Catalog:Get("OPTIONS")
  local frames = Private.CDMFrames()
  for id, entry in pairs(catalog) do
    local info = Catalog:Info(id)
    if info then
      local identity = Private.CDMIdentity(id, entry, info, frames[id])
      local status = entry.displayed == true and "Displayed" or entry.displayed == false and "Not displayed" or "Layout unavailable"
      local name = ReadableOrNil(identity.name)
      local shownID = ReadableOrNil(identity.itemID) or ReadableOrNil(identity.spellID) or "?"
      values[id] = status .. " - " .. Private.CDMCategoryName(entry.category) .. " - "
        .. (type(name) == "string" and name or "Unknown") .. " [" .. tostring(shownID) .. "]"
        .. (entry.known and "" or " - Not learned")
    end
  end
  local checked = type(trigger.cdmSpells) == "table" and trigger.cdmSpells.multi
  for key in pairs(type(checked) == "table" and checked or {}) do
    local id = tonumber(key)
    if id and not values[id] then
      values[id] = "Unavailable in this specialization [" .. id .. "]"
    end
  end
  return values
end

-- Event lists of a trigger of the given kind.
local function EventsOf(kind)
  local events = {}
  for _, list in ipairs({ BASE_EVENTS, C_CooldownViewer and VIEWER_EVENTS or {}, KIND_EVENTS[kind] }) do
    for _, event in ipairs(list) do
      events[#events + 1] = event
    end
  end
  return {
    events = events,
    unit_events = { player = { "UNIT_AURA" }, target = { "UNIT_AURA", "UNIT_FACTION", "UNIT_FLAGS" } },
  }
end

-- Readable remaining time of a shown, active buff state, or nil.
local function ActiveRemaining(state)
  if state and state.show and state.cdmBuff and state.auraActive == true then
    return CooldownViewer.ReadRemaining(state)
  end
end

-- Remaining time condition; == and ~= allow a small tolerance.
local function TestRemaining(state, needle, op)
  local remaining, wanted = ActiveRemaining(state), tonumber(needle)
  if not (remaining and wanted) then
    return false
  elseif op == "==" or op == "~=" then
    return (math.abs(remaining - wanted) <= REMAINING_TOLERANCE) == (op == "==")
  end
  local compare = CooldownViewer.OPERATORS[op]
  return compare ~= nil and compare(remaining, wanted)
end

-- Time at which the remaining time condition may change its answer: the next bound it crosses.
local function RecheckRemaining(state, needle)
  local remaining, wanted = ActiveRemaining(state), tonumber(needle)
  if not (remaining and wanted) then
    return nil
  end
  for _, bound in ipairs({ wanted + REMAINING_TOLERANCE, wanted, wanted - REMAINING_TOLERANCE }) do
    if remaining > bound then
      return GetTime() + (remaining - bound) * CooldownViewer.TimeScale(state)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Prototypes
---------------------------------------------------------------------------------------------------

-- Hidden arg exposed as a condition; stored ones also feed the text replacements.
local function Condition(name, display, conditionType, stored)
  local argType = conditionType == "bool" and "toggle" or conditionType
  return { name = name, display = display, type = argType, conditionType = conditionType, store = stored, hidden = true,
    operator_types = stored and conditionType == "number" and "only_equal" or nil }
end

-- Args of a prototype of the given kind.
local function ArgsOf(kind)
  local args = {
    {
      name = "cdmSpells", display = "Cooldown Manager entries", type = "multiselect",
      values = PickerValues, required = true, multiNoSingle = true, sorted = true, hidden = true,
    },
  }
  if kind ~= "buff" then
    args[#args + 1] = { name = "cdmShowGCD", display = "Include global cooldown", type = "toggle", hidden = true }
  end
  args[#args + 1] = Condition("spellId", "Spell ID", "number", true)
  args[#args + 1] = Condition("name", "Spell Name", "string", true)
  if kind ~= "buff" then
    args[#args + 1] = Condition("onCooldown", "On Cooldown", "bool")
    args[#args + 1] = Condition("isReady", "Ready", "bool")
    args[#args + 1] = Condition("recharging", "Recharging", "bool")
  end
  args[#args + 1] = Condition("itemId", "Item ID", "number", true)
  args[#args + 1] = Condition("cdmCategory", "CDM Category", "string", true)
  args[#args + 1] = Condition("cdmDisplayed", "Displayed in CDM", "bool")
  if kind == "spell" then
    args[#args + 1] = Condition("inRange", "Spell In Range", "bool")
    args[#args + 1] = Condition("isUsable", "Spell Usable", "bool")
    args[#args + 1] = Condition("insufficientResources", "Insufficient Resources", "bool")
  elseif kind == "buff" then
    args[#args + 1] = Condition("auraActive", "Aura Active (when readable)", "bool")
    local remaining = Condition("cdmRemaining", "Remaining Time (when readable)", "number")
    remaining.noProgressSource = true
    remaining.conditionTest = TestRemaining
    remaining.conditionRecheckTime = RecheckRemaining
    args[#args + 1] = remaining
  end
  return args
end

-- Prototype of one event; kind is "spell", "buff" or "item".
local function NewPrototype(name, kind)
  local prototype = {
    type = "cdm",
    name = name,
    statesParameter = "full",
    progressType = "timed",
    automaticrequired = true,
    cooldownViewerProgress = true,
    force_events = "PLAYER_ENTERING_WORLD",
    internal_events = { "WA_CDM_REFRESH", "WA_CDM_LAYOUT_CHANGED" },
    args = ArgsOf(kind),
    events = function() return EventsOf(kind) end,
    triggerFunction = TriggerFunction,
    GetNameAndIcon = GetNameAndIcon,
  }
  if kind == "spell" then
    -- GCD watching feeds Private.SpellCooldownState; WatchGCD is defined later, by GenericTrigger.
    prototype.loadFunc = function() WeakAuras.WatchGCD() end
  end
  return prototype
end

Private.CooldownViewerPrototype = NewPrototype("Cooldown", "spell")
Private.CooldownViewerUtilityPrototype = NewPrototype("Cooldown", "spell")
Private.CooldownViewerBuffPrototype = NewPrototype("Buff/Debuff", "buff")
Private.CooldownViewerItemPrototype = NewPrototype("Item", "item")

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end

-- Cooldown Manager trigger, part 1 of 3: which catalogue entries a trigger selects.
-- Owns the cached view of the catalogue (CooldownViewerCatalog.lua stays the source of truth),
-- the text queries of a trigger (names, spell ids, item ids), their resolution to cooldownIDs
-- and the checked entries of the picker. Part 2 (CooldownViewerStates.lua) turns a selection
-- into states, part 3 (CooldownViewerTrigger.lua) declares the prototypes.
--
-- Shared helpers live in Private.CooldownViewer so the three files read the same rules.
--
-- A selection is a sorted list of cooldownIDs with extra fields:
--   singleClone          all entries share one clone, keyed "spell"
--   buffSpellIDsByEntry  cooldownID -> aura spell ids of the entry
--   buffEntryIDs         buff entries matching a name, best first
--   buffSpellIDs         aura spell ids matching a name
--   buffName             resolved display name of a buff query
--   buffResolvedSpellID  spell id imposed on the state of a buff found by name
--   previewSpell         stand-in shown by the options when nothing matches
--   picked               checked in the picker: admitted even when the entry is not learned

local _, Private = ...

local CooldownViewer = {}
Private.CooldownViewer = CooldownViewer

local EVENT_COOLDOWN = "Blizzard Cooldown Manager"
local EVENT_BUFF = "Blizzard CDM Buff"
local EVENT_ITEM = "Blizzard CDM Item"
local EVENT_UTILITY = "Blizzard CDM Utility"
local LAYOUT_EVENT = "WA_CDM_LAYOUT_CHANGED"
local MAX_SPELL_ID = 2147483647
local PREVIEW_ICON = 134400

-- Events after which the Cooldown Manager may describe other entries.
local RELOAD_EVENTS = {
  PLAYER_ENTERING_WORLD = true,
  PLAYER_SPECIALIZATION_CHANGED = true,
  SPELLS_CHANGED = true,
  PLAYER_EQUIPMENT_CHANGED = true,
  [LAYOUT_EVENT] = true,
  COOLDOWN_VIEWER_DATA_LOADED = true,
  COOLDOWN_VIEWER_TABLE_HOTFIXED = true,
  COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED = true,
}

-- Text lists of a trigger, each one producing queries of one kind.
local QUERY_LISTS = {
  { enabled = "cdmUseNames", values = "cdmNames" },
  { enabled = "cdmUseExactIDs", values = "cdmExactIDs", exact = true },
  { enabled = "cdmUseItemIDs", values = "cdmItemIDs", itemExact = true, itemOnly = true },
}

local IsSecret, ReadableOrNil = Private.IsSecret, Private.ReadableOrNil

---------------------------------------------------------------------------------------------------
-- Small shared rules
---------------------------------------------------------------------------------------------------

-- "buff", "item" or "spell" for a trigger event; unknown events behave as cooldowns.
function CooldownViewer.KindOf(event)
  if event == EVENT_BUFF then
    return "buff"
  elseif event == EVENT_ITEM then
    return "item"
  end
  return "spell"
end

-- Saved cdmSource derived from the event, kept for the options that read it.
function CooldownViewer.SyncSource(trigger)
  trigger.cdmSource = trigger.event == EVENT_BUFF and "buff" or "cooldown"
end

-- Visibility mode of a trigger with its per-kind default.
function CooldownViewer.ShowModeOf(trigger)
  if trigger.event == EVENT_BUFF then
    return trigger.cdmBuffShow or "active"
  end
  return trigger.cdmShow or "always"
end

-- Trimmed text, or "" for anything that is not a readable string or number.
function CooldownViewer.Trim(value)
  if IsSecret(value) or (type(value) ~= "string" and type(value) ~= "number") then
    return ""
  end
  return (tostring(value):match("^%s*(.-)%s*$"))
end

-- Readable positive spell id, or nil.
local function SpellIDOrNil(value)
  value = ReadableOrNil(value)
  if type(value) == "number" and value > 0 and value < MAX_SPELL_ID then
    return value
  end
end
CooldownViewer.SpellIDOrNil = SpellIDOrNil

-- Lower-cased readable spell name, or nil.
local function LowerSpellName(spellID)
  local info = spellID and C_Spell.GetSpellInfo(spellID)
  local name = info and ReadableOrNil(info.name)
  return type(name) == "string" and name:lower() or nil
end

-- Rank number read from the spell subtext ("Rank 3" -> 3), 0 when absent.
local function SpellRank(spellID)
  if not (spellID and C_Spell.GetSpellSubtext) then
    return 0
  end
  local text = ReadableOrNil(C_Spell.GetSpellSubtext(spellID))
  return type(text) == "string" and tonumber(text:match("%d+")) or 0
end

-- Appends the readable spell ids among the values to list, once each, and returns list.
local function AppendSpells(list, ...)
  for index = 1, select("#", ...) do
    local spellID = SpellIDOrNil((select(index, ...)))
    local present = false
    for _, listed in ipairs(list) do
      present = present or listed == spellID
    end
    if spellID and not present then
      list[#list + 1] = spellID
    end
  end
  return list
end

-- Linked spell ids of a cooldown info, as values.
local function LinkedSpells(info)
  if type(info.linkedSpellIDs) == "table" then
    return unpack(info.linkedSpellIDs)
  end
end

-- Empty selection of a query or a picker.
local function EmptySelection(selectionMode)
  return { singleClone = selectionMode == "spell", buffSpellIDsByEntry = {} }
end

-- Spell shown in place of spellID by the spellbook, or spellID itself.
function CooldownViewer.DisplayedSpell(spellID)
  if spellID and C_SpellBook and C_SpellBook.FindSpellOverrideByID then
    return SpellIDOrNil(C_SpellBook.FindSpellOverrideByID(spellID)) or spellID
  end
  return spellID
end

---------------------------------------------------------------------------------------------------
-- Catalogue cache
---------------------------------------------------------------------------------------------------

-- One cached load of Private.CDMCatalog with the infos and resolutions computed from it.
local Catalog = { entries = nil, loadedAt = nil, infos = {}, resolutions = {} }
CooldownViewer.Catalog = Catalog

-- Reads the catalogue again and forgets everything derived from the previous load.
function Catalog:Load()
  self.entries = Private.CDMCatalog()
  self.loadedAt = GetTime()
  wipe(self.infos)
  wipe(self.resolutions)
end

-- Drops the cached load; the next read reloads.
function Catalog:Invalidate()
  self.entries = nil
end

-- Entries for an event: reload events reload once per scan batch, OPTIONS once per instant.
function Catalog:Get(event)
  if RELOAD_EVENTS[event] then
    local batch = Private.cdmScanBatch
    if not (batch and batch.cdmCatalogReloaded) then
      if batch then
        batch.cdmCatalogReloaded = true
      end
      Private.CDMResetIdentities()
      self:Load()
    end
  elseif not self.entries or (event == "OPTIONS" and self.loadedAt ~= GetTime()) then
    self:Load()
  end
  return self.entries or {}
end

-- Cooldown info of an entry, read once per load.
function Catalog:Info(cooldownID)
  local info = self.infos[cooldownID]
  if info == nil then
    local ok, result = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
    info = ok and result or false
    self.infos[cooldownID] = info
  end
  return info or nil
end

-- The layout of the Cooldown Manager changed: forget now, tell the triggers next frame.
local layoutPending = false
local function OnLayoutDataChanged()
  Catalog:Invalidate()
  if layoutPending then
    return
  end
  layoutPending = true
  C_Timer.After(0, function()
    layoutPending = false
    if Private.ScanEvents then
      Private.ScanEvents(LAYOUT_EVENT)
    end
  end)
end

if EventRegistry and EventRegistry.RegisterCallback then
  EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", OnLayoutDataChanged, Catalog)
end

---------------------------------------------------------------------------------------------------
-- Entry rules
---------------------------------------------------------------------------------------------------

local SPELL_CATEGORIES = { "Essential", "Utility" }
local EQUIPMENT_CATEGORIES = { "EquipSlotEssential", "EquipSlotTracked" }

-- Whether a viewer category is one of the named Enum.CooldownViewerCategory values.
local function InCategories(value, names)
  local categories = Enum.CooldownViewerCategory
  for _, name in ipairs(names) do
    if value == categories[name] then
      return true
    end
  end
  return false
end

-- True for entries that track an item (equipment slot, item category or item viewer source).
local function IsItemEntry(entry, info)
  return (info and (info.equipSlot or info.spellCategoryID)) and true or InCategories(entry.sourceCategory, EQUIPMENT_CATEGORIES)
end

-- "buff", "item" or "spell" for a catalogue entry.
function CooldownViewer.EntryKind(entry, info)
  if Private.CDMIsBuff(entry.category) then
    return "buff"
  elseif IsItemEntry(entry, info) then
    return "item"
  end
  return "spell"
end

-- Whether a catalogue entry suits the event of a trigger: same kind, and spells only from the
-- spell viewers. Hidden entries count only in the options preview.
function Private.CDMEntryMatches(trigger, entry, info, preview)
  local visible = entry ~= nil and (preview or entry.displayed == true)
  if not visible then
    return false
  end
  local kind = CooldownViewer.EntryKind(entry, info)
  return kind == CooldownViewer.KindOf(trigger.event) and (kind ~= "spell" or InCategories(entry.category, SPELL_CATEGORIES))
end

-- Sorted unique readable aura spell ids carried by a cooldown info.
function Private.CDMAuraSpellIDs(info)
  if not info then
    return {}
  end
  local list = AppendSpells({}, LinkedSpells(info))
  AppendSpells(list, info.linkedSpellID, info.overrideTooltipSpellID, info.overrideSpellID, info.spellID)
  table.sort(list)
  return list
end

-- Readable spell ids an entry points to besides its own spell: overrides, displayed spell, linked spells.
function CooldownViewer.RelatedSpells(info)
  local list = AppendSpells({}, info.overrideSpellID, info.overrideTooltipSpellID,
    CooldownViewer.DisplayedSpell(SpellIDOrNil(info.spellID)))
  return AppendSpells(list, LinkedSpells(info))
end

---------------------------------------------------------------------------------------------------
-- Queries
---------------------------------------------------------------------------------------------------

-- Query table carrying the display settings of a trigger and one text to look up.
function CooldownViewer.QueryFromTrigger(trigger, text, exact, itemExact, selectionMode)
  local kind = CooldownViewer.KindOf(trigger.event)
  return {
    type = trigger.type,
    event = trigger.event,
    cdmSource = kind == "buff" and "buff" or "cooldown",
    cdmSelection = selectionMode,
    cdmSpell = text,
    cdmExact = exact == true,
    cdmItemExact = itemExact == true,
    use_ignoreSpellKnown = trigger.use_ignoreSpellKnown == true,
    showGCD = trigger.use_cdmShowGCD == true,
    track = trigger.cdmTrack or "auto",
    hideGCDText = trigger.cdmHideGCDText ~= false,
    showMode = CooldownViewer.ShowModeOf(trigger),
    requireTarget = kind == "buff" and trigger.cdmRequireTarget == true,
  }
end

-- One query per distinct non-empty value of the enabled lists, or nil when no list is enabled.
function Private.CDMSpellQueries(trigger)
  local isItem = CooldownViewer.KindOf(trigger.event) == "item"
  local queries
  for _, list in ipairs(QUERY_LISTS) do
    if trigger[list.enabled] and (isItem or not list.itemOnly) then
      queries = queries or {}
      local seen = {}
      for _, value in ipairs(type(trigger[list.values]) == "table" and trigger[list.values] or {}) do
        local text = CooldownViewer.Trim(value)
        if text ~= "" and not seen[text] then
          seen[text] = true
          queries[#queries + 1] = CooldownViewer.QueryFromTrigger(trigger, text, list.exact, list.itemExact, "spell")
        end
      end
    end
  end
  return queries
end

-- Legacy free text of a trigger, as a query, or nil.
function CooldownViewer.LegacyQuery(trigger)
  local text = CooldownViewer.Trim(trigger.cdmSpell)
  if text == "" or CooldownViewer.KindOf(trigger.event) == "item" then
    return nil
  end
  return CooldownViewer.QueryFromTrigger(trigger, text, trigger.cdmExact, false, trigger.cdmSelection)
end

---------------------------------------------------------------------------------------------------
-- Resolution of a query
---------------------------------------------------------------------------------------------------

-- Spells of an entry: the two strong ones identify it, weak ones only point to it (may hold nils).
local function EntrySpells(kind, info, identity)
  local strong = { identity.spellID, info.spellID }
  if kind == "buff" then
    return strong, Private.CDMAuraSpellIDs(info)
  end
  return strong, CooldownViewer.RelatedSpells(info)
end

-- Spell granted by the item of an entry, and its name.
local function ItemSpell(identity)
  if not (identity.itemID and C_Item and C_Item.GetItemSpell) then
    return nil
  end
  local name, spellID = C_Item.GetItemSpell(identity.itemID)
  return SpellIDOrNil(spellID), ReadableOrNil(name)
end

-- Lower-cased name a query looks for; a numeric text stands for the name of that spell.
local function QueryName(query)
  local text = query.cdmSpell
  return LowerSpellName(SpellIDOrNil(tonumber(text))) or text:lower()
end

-- How a query recognises a spell: by exact id or by lower-cased name.
local function NewMatcher(query)
  if query.cdmExact then
    local wantedID = tonumber(query.cdmSpell)
    return function(spellID) return spellID ~= nil and spellID == wantedID end
  end
  local lowered = QueryName(query)
  return function(spellID) return LowerSpellName(spellID) == lowered end
end

-- Best match of an entry for a query: {id, spellID, score, rank, known, displayed} or nil.
local function MatchEntry(query, kind, id, entry, info, identity, matches)
  if kind == "item" then
    local itemSpellID, itemSpellName = ItemSpell(identity)
    local hit
    if query.cdmItemExact then
      hit = identity.itemID == tonumber(query.cdmSpell)
    elseif query.cdmExact then
      hit = matches(SpellIDOrNil(info.spellID)) or matches(identity.spellID) or matches(itemSpellID)
    else
      local lowered = QueryName(query)
      hit = (type(identity.name) == "string" and not IsSecret(identity.name) and identity.name:lower() == lowered)
        or (type(itemSpellName) == "string" and itemSpellName:lower() == lowered)
    end
    return hit and { id = id, spellID = identity.spellID, score = 2 } or nil
  end
  local strong, weak = EntrySpells(kind, info, identity)
  for index = 1, 2 do
    local spellID = SpellIDOrNil(strong[index])
    if spellID and matches(spellID) then
      return { id = id, spellID = spellID, score = 2 }
    end
  end
  local entryRank = SpellRank(SpellIDOrNil(info.spellID))
  for _, spellID in ipairs(weak) do
    if matches(spellID) and (kind == "buff" or SpellRank(spellID) == entryRank) then
      return { id = id, spellID = spellID, score = 1 }
    end
  end
end

-- Order of preference between matches: learned, direct, higher rank, displayed, smaller id.
local function BetterMatch(a, b)
  if a.known ~= b.known then
    return a.known
  elseif a.score ~= b.score then
    return a.score > b.score
  elseif a.rank ~= b.rank then
    return a.rank > b.rank
  elseif a.displayed ~= b.displayed then
    return a.displayed
  end
  return a.id < b.id
end

-- Every catalogue entry of the query's kind matching its text, best first.
local function FindMatches(query, catalog, preview)
  local kind = CooldownViewer.KindOf(query.event)
  local frames = Private.CDMFrames()
  local matches = NewMatcher(query)
  local found = {}
  for id, entry in pairs(catalog) do
    local info = Catalog:Info(id)
    if info and Private.CDMEntryMatches(query, entry, info, preview) then
      local identity = Private.CDMIdentity(id, entry, info, frames[id])
      local match = MatchEntry(query, kind, id, entry, info, identity, matches)
      if match then
        match.known = entry.known == true
        match.rank = SpellRank(match.spellID)
        match.displayed = entry.displayed == true
        found[#found + 1] = match
      end
    end
  end
  table.sort(found, BetterMatch)
  return found, kind
end

-- Buff matches whose spell the player knows, highest rank first; every match when none is known.
local function KnownBuffMatches(found)
  local known = {}
  for _, match in ipairs(found) do
    if WeakAuras.IsSpellKnownIncludingPet(match.spellID) then
      known[#known + 1] = match
    end
  end
  if not known[1] then
    return found
  end
  table.sort(known, function(a, b)
    if a.rank ~= b.rank then
      return a.rank > b.rank
    end
    return BetterMatch(a, b)
  end)
  return known
end

-- Stand-in of a query text for the options: the real spell when the text names one.
local function PreviewSpell(text)
  local info = C_Spell.GetSpellInfo(tonumber(text) or text)
  local name = info and ReadableOrNil(info.name)
  local icon = info and ReadableOrNil(info.iconID)
  return {
    name = type(name) == "string" and name or text,
    iconID = icon or PREVIEW_ICON,
    spellID = info and SpellIDOrNil(info.spellID) or tonumber(text),
  }
end

-- Builds the selection of a query from the catalogue.
local function BuildSelection(query, event, catalog)
  local preview = event == "OPTIONS"
  local selection = EmptySelection(query.cdmSelection)
  local text = query.cdmSpell
  if (query.cdmExact or query.cdmItemExact) and not tonumber(text) then
    return selection
  end

  local found, kind = FindMatches(query, catalog, preview)
  if kind == "buff" and not query.cdmExact and not preview then
    found = KnownBuffMatches(found)
  end
  if kind == "item" then
    for _, match in ipairs(found) do
      selection[#selection + 1] = match.id
    end
    table.sort(selection)
  elseif found[1] then
    selection[1] = found[1].id
  end

  if kind == "buff" and found[1] and not query.cdmExact then
    local spellIDs, seen = {}, {}
    selection.buffEntryIDs = {}
    for _, match in ipairs(found) do
      selection.buffEntryIDs[#selection.buffEntryIDs + 1] = match.id
      if not seen[match.spellID] then
        seen[match.spellID] = true
        spellIDs[#spellIDs + 1] = match.spellID
      end
    end
    table.sort(spellIDs)
    selection.buffSpellIDs = spellIDs
    local info = C_Spell.GetSpellInfo(found[1].spellID)
    selection.buffName = info and ReadableOrNil(info.name) or text
    if not preview then
      selection.buffResolvedSpellID = found[1].spellID
    end
  end

  if preview and not selection[1] then
    selection.previewSpell = PreviewSpell(text)
  end
  for _, id in ipairs(selection) do
    selection.buffSpellIDsByEntry[id] = Private.CDMAuraSpellIDs(Catalog:Info(id))
  end
  return selection
end

-- Selection of a query (or of a legacy trigger), memoised until the next catalogue load.
function Private.ResolveCDMSpell(trigger, event)
  CooldownViewer.SyncSource(trigger)
  local catalog = Catalog:Get(event)
  local text = CooldownViewer.Trim(trigger.cdmSpell)
  local query = trigger
  if text ~= trigger.cdmSpell then
    query = setmetatable({ cdmSpell = text }, { __index = trigger })
  end
  local key = table.concat({
    tostring(trigger.cdmSelection), tostring(trigger.event), text, tostring(trigger.cdmExact == true),
    tostring(trigger.cdmItemExact == true), tostring(trigger.cdmSource),
    tostring(trigger.use_ignoreSpellKnown == true), tostring(event == "OPTIONS"),
  }, "\031")
  local selection = Catalog.resolutions[key]
  if not selection then
    if text == "" then
      selection = EmptySelection(trigger.cdmSelection)
    else
      selection = BuildSelection(query, event, catalog)
    end
    Catalog.resolutions[key] = selection
  end
  return selection
end

---------------------------------------------------------------------------------------------------
-- Picker
---------------------------------------------------------------------------------------------------

-- Checked entries of the picker present in the catalogue and suiting the event, sorted.
function Private.GetCDMPickerSelections(trigger, event)
  local preview = event == "OPTIONS"
  local catalog = Catalog:Get(event)
  local selection = EmptySelection(trigger.cdmSelection)
  selection.picked = true
  local checked = type(trigger.cdmSpells) == "table" and trigger.cdmSpells.multi
  for key, isChecked in pairs(type(checked) == "table" and checked or {}) do
    local id = tonumber(key)
    local entry = id and catalog[id]
    if isChecked and entry and not selection.buffSpellIDsByEntry[id] then
      local info = Catalog:Info(id)
      if info and Private.CDMEntryMatches(trigger, entry, info, preview) then
        selection[#selection + 1] = id
        selection.buffSpellIDsByEntry[id] = Private.CDMAuraSpellIDs(info)
      end
    end
  end
  table.sort(selection)
  return selection
end
Private.ExecEnv.GetCDMPickerSelections = Private.GetCDMPickerSelections

---------------------------------------------------------------------------------------------------
-- Migration
---------------------------------------------------------------------------------------------------

-- Moves legacy Utility triggers to the Cooldown event.
function Private.MigrateCDMCooldownTrigger(trigger)
  if trigger.type == "cdm" and trigger.event == EVENT_UTILITY then
    trigger.event = EVENT_COOLDOWN
    trigger.cdmSource = "cooldown"
  end
end

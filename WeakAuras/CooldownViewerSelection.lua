-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local IsSecret = Private.IsSecret
local ReadableOrNil = Private.ReadableOrNil

local COOLDOWN_EVENT = "Blizzard Cooldown Manager"
local BUFF_EVENT = "Blizzard CDM Buff"
local ITEM_EVENT = "Blizzard CDM Item"
local UTILITY_EVENT = "Blizzard CDM Utility"
local LAYOUT_EVENT = "WA_CDM_LAYOUT_CHANGED"
local OPTIONS_EVENT = "OPTIONS"
local FALLBACK_ICON = 134400
local SPELL_ID_LIMIT = 2147483647

local reloadEvents = {
  PLAYER_ENTERING_WORLD = true,
  PLAYER_SPECIALIZATION_CHANGED = true,
  SPELLS_CHANGED = true,
  PLAYER_EQUIPMENT_CHANGED = true,
  [LAYOUT_EVENT] = true,
  COOLDOWN_VIEWER_DATA_LOADED = true,
  COOLDOWN_VIEWER_TABLE_HOTFIXED = true,
  COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED = true,
}

local CooldownViewer = {}
Private.CooldownViewer = CooldownViewer

local function categoryValue(name)
  local categories = Enum and Enum.CooldownViewerCategory
  return categories and categories[name]
end

local function isCategory(category, name)
  local value = categoryValue(name)
  return value ~= nil and category ~= nil and not IsSecret(category) and category == value
end

local function kindOf(event)
  if event == BUFF_EVENT then return "buff" end
  if event == ITEM_EVENT then return "item" end
  return "spell"
end
CooldownViewer.KindOf = kindOf

function CooldownViewer.SyncSource(trigger)
  trigger.cdmSource = trigger.event == BUFF_EVENT and "buff" or "cooldown"
end

local function showModeOf(trigger)
  if trigger.event == BUFF_EVENT then
    return trigger.cdmBuffShow or "active"
  end
  return trigger.cdmShow or "always"
end
CooldownViewer.ShowModeOf = showModeOf

local function trim(value)
  if IsSecret(value) then return "" end
  local valueType = type(value)
  if valueType ~= "string" and valueType ~= "number" then return "" end
  return (tostring(value):match("^%s*(.-)%s*$"))
end
CooldownViewer.Trim = trim

local function spellIDOrNil(value)
  value = ReadableOrNil(value)
  if type(value) == "number" and value > 0 and value < SPELL_ID_LIMIT then
    return value
  end
  return nil
end
CooldownViewer.SpellIDOrNil = spellIDOrNil

local function displayedSpell(spellID)
  if spellID ~= nil and C_SpellBook and C_SpellBook.FindSpellOverrideByID then
    return spellIDOrNil(C_SpellBook.FindSpellOverrideByID(spellID)) or spellID
  end
  return spellID
end
CooldownViewer.DisplayedSpell = displayedSpell

local function entryKind(entry, info)
  if Private.CDMIsBuff(entry.category) then return "buff" end
  if info and (info.equipSlot or info.spellCategoryID) then return "item" end
  local source = entry.sourceCategory
  if isCategory(source, "EquipSlotEssential") or isCategory(source, "EquipSlotTracked") then
    return "item"
  end
  return "spell"
end
CooldownViewer.EntryKind = entryKind

local function spellCollector()
  local list, seen = {}, {}
  return list, function(value)
    local spellID = spellIDOrNil(value)
    if spellID and not seen[spellID] then
      seen[spellID] = true
      list[#list + 1] = spellID
    end
  end
end

local function relatedSpells(info)
  local list, add = spellCollector()
  add(info.overrideSpellID)
  add(info.overrideTooltipSpellID)
  add(displayedSpell(spellIDOrNil(info.spellID)))
  if type(info.linkedSpellIDs) == "table" then
    for _, spellID in ipairs(info.linkedSpellIDs) do add(spellID) end
  end
  return list
end
CooldownViewer.RelatedSpells = relatedSpells

function Private.CDMAuraSpellIDs(info)
  local list, add = spellCollector()
  if not info then return list end
  if type(info.linkedSpellIDs) == "table" then
    for _, spellID in pairs(info.linkedSpellIDs) do add(spellID) end
  end
  add(info.linkedSpellID)
  add(info.overrideTooltipSpellID)
  add(info.overrideSpellID)
  add(info.spellID)
  table.sort(list)
  return list
end

function Private.CDMEntryMatches(trigger, entry, info, preview)
  if not entry then return false end
  if not preview and entry.displayed ~= true then return false end
  local kind = entryKind(entry, info)
  if kind ~= kindOf(trigger.event) then return false end
  return kind ~= "spell" or isCategory(entry.category, "Essential") or isCategory(entry.category, "Utility")
end

local function queryFromTrigger(trigger, text, exact, itemExact, selectionMode)
  local isBuff = kindOf(trigger.event) == "buff"
  return {
    type = trigger.type,
    event = trigger.event,
    cdmSource = isBuff and "buff" or "cooldown",
    cdmSelection = selectionMode,
    cdmSpell = text,
    cdmExact = exact == true,
    cdmItemExact = itemExact == true,
    use_ignoreSpellKnown = trigger.use_ignoreSpellKnown == true,
    showGCD = trigger.use_cdmShowGCD == true,
    track = trigger.cdmTrack or "auto",
    hideGCDText = trigger.cdmHideGCDText ~= false,
    showMode = showModeOf(trigger),
    requireTarget = isBuff and trigger.cdmRequireTarget == true,
  }
end
CooldownViewer.QueryFromTrigger = queryFromTrigger

local queryLists = {
  { toggle = "cdmUseNames", values = "cdmNames" },
  { toggle = "cdmUseExactIDs", values = "cdmExactIDs", exact = true },
  { toggle = "cdmUseItemIDs", values = "cdmItemIDs", itemExact = true, itemOnly = true },
}

function Private.CDMSpellQueries(trigger)
  local isItem = kindOf(trigger.event) == "item"
  local queries
  for _, list in ipairs(queryLists) do
    if trigger[list.toggle] and (isItem or not list.itemOnly) then
      queries = queries or {}
      local values = trigger[list.values]
      if type(values) == "table" then
        local seen = {}
        for _, value in ipairs(values) do
          local text = trim(value)
          if text ~= "" and not seen[text] then
            seen[text] = true
            queries[#queries + 1] = queryFromTrigger(trigger, text, list.exact, list.itemExact, "spell")
          end
        end
      end
    end
  end
  return queries
end

function CooldownViewer.LegacyQuery(trigger)
  local text = trim(trigger.cdmSpell)
  if text == "" or kindOf(trigger.event) == "item" then return nil end
  return queryFromTrigger(trigger, text, trigger.cdmExact, false, trigger.cdmSelection)
end

local Catalog = { entries = nil, loadedAt = nil, infos = {}, resolutions = {} }
CooldownViewer.Catalog = Catalog

function Catalog:Load()
  self.entries = Private.CDMCatalog()
  self.loadedAt = GetTime()
  wipe(self.infos)
  wipe(self.resolutions)
end

function Catalog:Invalidate()
  self.entries = nil
end

function Catalog:Get(event)
  if reloadEvents[event] then
    local batch = Private.cdmScanBatch
    if not (batch and batch.cdmCatalogReloaded) then
      if batch then batch.cdmCatalogReloaded = true end
      Private.CDMResetIdentities()
      self:Load()
    end
  elseif self.entries == nil or (event == OPTIONS_EVENT and self.loadedAt ~= GetTime()) then
    self:Load()
  end
  return self.entries or {}
end

function Catalog:Info(cooldownID)
  if cooldownID == nil then return nil end
  local cached = self.infos[cooldownID]
  if cached == nil then
    local ok, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
    cached = ok and info or false
    self.infos[cooldownID] = cached
  end
  return cached or nil
end

if EventRegistry and EventRegistry.RegisterCallback then
  local layoutEmitPending = false
  local function emitLayoutChanged()
    layoutEmitPending = false
    if Private.ScanEvents then
      Private.ScanEvents(LAYOUT_EVENT)
    end
  end
  EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
    Catalog:Invalidate()
    if layoutEmitPending then return end
    layoutEmitPending = true
    C_Timer.After(0, emitLayoutChanged)
  end, Catalog)
end

local function spellName(spellID)
  if spellID == nil or not C_Spell or not C_Spell.GetSpellInfo then return nil end
  local info = C_Spell.GetSpellInfo(spellID)
  if type(info) ~= "table" then return nil end
  local name = ReadableOrNil(info.name)
  if type(name) == "string" then return name end
  return nil
end

local function lowerSpellName(spellID)
  local name = spellName(spellID)
  return name and name:lower()
end

local function spellRank(spellID)
  if spellID == nil or not C_Spell or not C_Spell.GetSpellSubtext then return 0 end
  local subtext = ReadableOrNil(C_Spell.GetSpellSubtext(spellID))
  if type(subtext) ~= "string" then return 0 end
  return tonumber(subtext:match("%d+")) or 0
end

local function itemGrantedSpell(itemID)
  if itemID == nil or not C_Item or not C_Item.GetItemSpell then return nil end
  local _, spellID = C_Item.GetItemSpell(itemID)
  return spellIDOrNil(spellID)
end

local function newSelection(selectionMode)
  return { singleClone = selectionMode == "spell", buffSpellIDsByEntry = {} }
end

local function matchItem(search, identity, info)
  local itemID = ReadableOrNil(identity.itemID)
  local identitySpell = ReadableOrNil(identity.spellID)
  if search.itemExact then
    return itemID ~= nil and itemID == search.id, identitySpell
  end
  local granted = itemGrantedSpell(itemID)
  if search.exact then
    local wanted = search.id
    local found = spellIDOrNil(info.spellID) == wanted or identitySpell == wanted
      or (granted ~= nil and granted == wanted)
    return found, identitySpell
  end
  local name = ReadableOrNil(identity.name)
  if type(name) == "string" and name:lower() == search.name then
    return true, identitySpell
  end
  local grantedName = granted and lowerSpellName(granted)
  return grantedName ~= nil and grantedName == search.name, identitySpell
end

local function matchSpell(search, kind, identity, info)
  local strongSpells = { spellIDOrNil(identity.spellID), spellIDOrNil(info.spellID) }
  for index = 1, 2 do
    local spellID = strongSpells[index]
    if spellID and search.recognizes(spellID) then return true, spellID, 2 end
  end
  local weakSpells = kind == "buff" and Private.CDMAuraSpellIDs(info) or relatedSpells(info)
  local baseRank
  for _, spellID in ipairs(weakSpells) do
    if search.recognizes(spellID) then
      if kind == "buff" then return true, spellID, 1 end
      baseRank = baseRank or spellRank(spellIDOrNil(info.spellID))
      if spellRank(spellID) == baseRank then return true, spellID, 1 end
    end
  end
  return false
end

local function betterMatch(a, b)
  if a.known ~= b.known then return a.known end
  if a.score ~= b.score then return a.score > b.score end
  if a.rank ~= b.rank then return a.rank > b.rank end
  if a.displayed ~= b.displayed then return a.displayed end
  return a.id < b.id
end

local function higherRankFirst(a, b)
  if a.rank ~= b.rank then return a.rank > b.rank end
  return betterMatch(a, b)
end

local function newSearch(query, text)
  local search = {
    exact = query.cdmExact == true,
    itemExact = query.cdmItemExact == true,
    id = tonumber(text),
  }
  if search.exact or search.itemExact then
    search.recognizes = function(spellID) return spellID == search.id end
  else
    local asSpell = spellIDOrNil(search.id)
    search.name = (asSpell and lowerSpellName(asSpell)) or text:lower()
    search.recognizes = function(spellID)
      local name = lowerSpellName(spellID)
      return name ~= nil and name == search.name
    end
  end
  return search
end

local function findMatches(query, search, kind, catalog, preview)
  local matches = {}
  local frames
  for cooldownID, entry in pairs(catalog) do
    local info = Catalog:Info(cooldownID)
    if info and Private.CDMEntryMatches(query, entry, info, preview) then
      frames = frames or Private.CDMFrames()
      local identity = Private.CDMIdentity(cooldownID, entry, info, frames[cooldownID])
      local found, spellID, score
      if kind == "item" then
        found, spellID = matchItem(search, identity, info)
        score = 2
      else
        found, spellID, score = matchSpell(search, kind, identity, info)
      end
      if found then
        matches[#matches + 1] = {
          id = cooldownID,
          spellID = spellID,
          score = score,
          known = entry.known == true,
          rank = spellRank(spellID),
          displayed = entry.displayed == true,
        }
      end
    end
  end
  table.sort(matches, betterMatch)
  return matches
end

local function keepLearnedBuffs(matches)
  local learned = {}
  for _, match in ipairs(matches) do
    if match.spellID and WeakAuras.IsSpellKnownIncludingPet(match.spellID) then
      learned[#learned + 1] = match
    end
  end
  if #learned == 0 then return matches end
  table.sort(learned, higherRankFirst)
  return learned
end

local function fillBuffFields(selection, matches, text, preview)
  local entryIDs, spellIDs, seen = {}, {}, {}
  for index, match in ipairs(matches) do
    entryIDs[index] = match.id
    local spellID = match.spellID
    if spellID ~= nil and not seen[spellID] then
      seen[spellID] = true
      spellIDs[#spellIDs + 1] = spellID
    end
  end
  table.sort(spellIDs)
  local best = matches[1]
  selection.buffEntryIDs = entryIDs
  selection.buffSpellIDs = spellIDs
  selection.buffName = spellName(best.spellID) or text
  if not preview then
    selection.buffResolvedSpellID = best.spellID
  end
end

local function previewSpellFor(text)
  local wantedID = tonumber(text)
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(wantedID or text)
  if type(info) ~= "table" then
    return { name = text, iconID = FALLBACK_ICON, spellID = wantedID }
  end
  local name = ReadableOrNil(info.name)
  return {
    name = type(name) == "string" and name or text,
    iconID = ReadableOrNil(info.iconID) or FALLBACK_ICON,
    spellID = spellIDOrNil(info.spellID) or wantedID,
  }
end

local function buildSelection(query, text, event, catalog)
  local selection = newSelection(query.cdmSelection)
  if text == "" then return selection end
  local search = newSearch(query, text)
  if (search.exact or search.itemExact) and not search.id then return selection end
  local preview = event == OPTIONS_EVENT
  local kind = kindOf(query.event)
  local matches = findMatches(query, search, kind, catalog, preview)

  if kind == "buff" and not search.exact and not search.itemExact and not preview then
    matches = keepLearnedBuffs(matches)
  end

  if kind == "item" then
    for index, match in ipairs(matches) do selection[index] = match.id end
    table.sort(selection)
  elseif matches[1] then
    selection[1] = matches[1].id
  end

  if kind == "buff" and matches[1] and not search.exact and not search.itemExact then
    fillBuffFields(selection, matches, text, preview)
  end

  if preview and #selection == 0 then
    selection.previewSpell = previewSpellFor(text)
  end

  for _, cooldownID in ipairs(selection) do
    selection.buffSpellIDsByEntry[cooldownID] = Private.CDMAuraSpellIDs(Catalog:Info(cooldownID))
  end
  return selection
end

local KEY_SEPARATOR = "\031"

function Private.ResolveCDMSpell(trigger, event)
  CooldownViewer.SyncSource(trigger)
  local catalog = Catalog:Get(event)
  local text = trim(trigger.cdmSpell)
  local query = trigger
  if IsSecret(trigger.cdmSpell) or text ~= trigger.cdmSpell then
    query = setmetatable({ cdmSpell = text }, { __index = trigger })
  end
  local key = table.concat({
    tostring(query.cdmSelection),
    tostring(query.event),
    text,
    tostring(query.cdmExact == true),
    tostring(query.cdmItemExact == true),
    tostring(query.cdmSource),
    tostring(query.use_ignoreSpellKnown == true),
    tostring(event == OPTIONS_EVENT),
  }, KEY_SEPARATOR)
  local selection = Catalog.resolutions[key]
  if not selection then
    selection = buildSelection(query, text, event, catalog)
    Catalog.resolutions[key] = selection
  end
  return selection
end

function Private.GetCDMPickerSelections(trigger, event)
  local preview = event == OPTIONS_EVENT
  local catalog = Catalog:Get(event)
  local selection = newSelection(trigger.cdmSelection)
  selection.picked = true
  local spells = trigger.cdmSpells
  local multi = type(spells) == "table" and spells.multi
  if type(multi) == "table" then
    local added = {}
    for key, checked in pairs(multi) do
      local cooldownID = checked and tonumber(key)
      if cooldownID and not added[cooldownID] then
        local entry = catalog[cooldownID]
        local info = entry and Catalog:Info(cooldownID)
        if info and Private.CDMEntryMatches(trigger, entry, info, preview) then
          added[cooldownID] = true
          selection[#selection + 1] = cooldownID
          selection.buffSpellIDsByEntry[cooldownID] = Private.CDMAuraSpellIDs(info)
        end
      end
    end
  end
  table.sort(selection)
  return selection
end
Private.ExecEnv.GetCDMPickerSelections = Private.GetCDMPickerSelections

function Private.MigrateCDMCooldownTrigger(trigger)
  if trigger and trigger.type == "cdm" and trigger.event == UTILITY_EVENT then
    trigger.event = COOLDOWN_EVENT
    trigger.cdmSource = "cooldown"
  end
end

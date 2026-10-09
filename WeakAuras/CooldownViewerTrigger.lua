if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

function Private.MigrateCDMCooldownTrigger(trigger)
  if not trigger then return end
  if trigger.type ~= "cdm" or trigger.event ~= "Blizzard CDM Utility" then return end
  trigger.event = "Blizzard Cooldown Manager"
  trigger.cdmSource = "cooldown"
end

local RELOAD_EVENTS = {}
for _, eventName in ipairs({
  "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "SPELLS_CHANGED", "PLAYER_EQUIPMENT_CHANGED",
  "WA_CDM_LAYOUT_CHANGED", "COOLDOWN_VIEWER_DATA_LOADED", "COOLDOWN_VIEWER_TABLE_HOTFIXED",
  "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED",
}) do
  RELOAD_EVENTS[eventName] = true
end

local IsSecret = Private.IsSecret

local function readFlag(value)
  if not IsSecret(value) and type(value) == "boolean" then return value end
end

local function readPositiveNumber(value)
  return not IsSecret(value) and type(value) == "number" and value > 0
end

local function viewerApiReady()
  return C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet
    and C_CooldownViewer.GetCooldownViewerCooldownInfo
    and Enum and Enum.CooldownViewerCategory
    and C_Spell and C_Spell.GetSpellCooldownDuration
end

local catalogCache
local catalogStamp

local function shouldReloadCatalog(event)
  if RELOAD_EVENTS[event] then return true end
  if event ~= "OPTIONS" then return false end
  return not (catalogCache and catalogStamp == GetTime())
end

local function loadCatalog(forceReload)
  local batch = Private.cdmScanBatch
  if batch and batch.catalog then return batch.catalog end
  if not catalogCache or forceReload then
    catalogCache = viewerApiReady() and Private.CDMCatalog() or {}
    catalogStamp = GetTime()
  end
  if batch then batch.catalog = catalogCache end
  return catalogCache
end

local function rankFromSubtext(spellID)
  if IsSecret(spellID) or type(spellID) ~= "number" then return end
  local subtext = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)
  if IsSecret(subtext) or type(subtext) ~= "string" then return nil end
  return tonumber(subtext:match("%d+"))
end

local function sameReadable(value, wanted)
  return not IsSecret(value) and value == wanted
end

local function matchStrength(info, wanted)
  if sameReadable(info.spellID, wanted) then return 2 end
  local ownRank, wantedRank = rankFromSubtext(info.spellID), rankFromSubtext(wanted)
  if ownRank and wantedRank and ownRank ~= wantedRank then return 0 end
  if sameReadable(info.linkedSpellID, wanted) or sameReadable(info.overrideSpellID, wanted) then return 1 end
  for _, linkedID in ipairs(info.linkedSpellIDs or {}) do
    if sameReadable(linkedID, wanted) then return 1 end
  end
  return 0
end

function Private.CDMEntryMatches(trigger, entry, info, preview)
  if not preview and entry.displayed ~= true then return false end
  local categories = Enum.CooldownViewerCategory
  local isItem = info.equipSlot ~= nil or info.spellCategoryID ~= nil
    or entry.sourceCategory == categories.EquipSlotEssential
    or entry.sourceCategory == categories.EquipSlotTracked
  local kind = trigger.event
  if kind == "Blizzard CDM Item" then return isItem and not Private.CDMIsBuff(entry.category) end
  if kind == "Blizzard CDM Buff" then return Private.CDMIsBuff(entry.category) end
  if isItem then return false end
  return entry.category == categories.Essential or entry.category == categories.Utility
end

function Private.CDMAuraSpellIDs(info)
  local ids, known = {}, {}
  local function push(candidate)
    if readPositiveNumber(candidate) and not known[candidate] then
      known[candidate] = true
      ids[#ids + 1] = candidate
    end
  end
  for _, field in ipairs({"spellID", "overrideSpellID", "overrideTooltipSpellID", "linkedSpellID"}) do
    push(info[field])
  end
  for _, linkedID in ipairs(info.linkedSpellIDs or {}) do push(linkedID) end
  table.sort(ids)
  return ids
end

function Private.CDMSpellQueries(trigger)
  local useItems = trigger.event == "Blizzard CDM Item" and trigger.cdmUseItemIDs
  if not (trigger.cdmUseNames or trigger.cdmUseExactIDs or useItems) then return end
  local isBuff = trigger.event == "Blizzard CDM Buff"
  local template = {
    type = "cdm",
    event = trigger.event,
    cdmSource = isBuff and "buff" or "cooldown",
    cdmSelection = "spell",
    use_ignoreSpellKnown = trigger.use_ignoreSpellKnown,
    showGCD = trigger.use_cdmShowGCD == true,
    track = trigger.cdmTrack or "auto",
    hideGCDText = trigger.cdmHideGCDText ~= false,
    showMode = isBuff and (trigger.cdmBuffShow or "active") or (trigger.cdmShow or "always"),
    requireTarget = isBuff and trigger.cdmRequireTarget == true,
  }
  local queries, taken = {}, {}
  local function collect(values, exact, itemExact)
    for _, raw in ipairs(values or {}) do
      local text = tostring(raw):match("^%s*(.-)%s*$")
      local dedupeKey = (itemExact and "item:" or exact and "id:" or "name:") .. text
      if text ~= "" and not taken[dedupeKey] then
        taken[dedupeKey] = true
        local query = {}
        for field, value in pairs(template) do query[field] = value end
        query.cdmSpell = text
        query.cdmExact = exact
        query.cdmItemExact = itemExact == true
        queries[#queries + 1] = query
      end
    end
  end
  if trigger.cdmUseNames then collect(trigger.cdmNames, false) end
  if trigger.cdmUseExactIDs then collect(trigger.cdmExactIDs, true) end
  if useItems then collect(trigger.cdmItemIDs, false, true) end
  return queries
end

local lookupCache = {}

local function indexBuffNames(entries)
  if lookupCache.buffNames then return lookupCache.buffNames end
  local byName, spellRecords = {}, {}
  local frames = Private.CDMFrames()
  local function recordFor(spellID)
    local record = spellRecords[spellID]
    if record == nil then
      local spellInfo = C_Spell.GetSpellInfo(spellID)
      record = spellInfo and {name = spellInfo.name:lower(), id = spellID} or false
      spellRecords[spellID] = record
    end
    return record
  end
  for entryID, entry in pairs(entries) do
    local info = Private.CDMIsBuff(entry.category) and C_CooldownViewer.GetCooldownViewerCooldownInfo(entryID)
    if info then
      local shown = entry.displayed == true
      local spellIDs = Private.CDMAuraSpellIDs(info)
      local frame = frames[entryID]
      local frameSpell = frame and frame.GetSpellID and frame:GetSpellID()
      if not IsSecret(frameSpell) and type(frameSpell) == "number" then spellIDs[#spellIDs + 1] = frameSpell end
      for _, spellID in ipairs(spellIDs) do
        local record = recordFor(spellID)
        if record then
          local bucket = byName[record.name]
          if not bucket then
            bucket = {}
            byName[record.name] = bucket
          end
          bucket[#bucket + 1] = {
            spell = record,
            entryID = entryID,
            displayed = shown,
            direct = sameReadable(info.spellID, spellID) and 1 or 0,
          }
        end
      end
    end
  end
  lookupCache.buffNames = byName
  return byName
end

local function pickItemEntries(trigger, entries, event, query)
  local picked = {buffSpellIDsByEntry = {}}
  local numeric = tonumber(query)
  local spell = numeric and not trigger.cdmItemExact and C_Spell.GetSpellInfo(numeric)
  local lowered = (spell and spell.name or query):lower()
  local frames = Private.CDMFrames()
  local preview = event == "OPTIONS"
  for entryID, entry in pairs(entries) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(entryID)
    if info and Private.CDMEntryMatches(trigger, entry, info, preview) then
      local identity = Private.CDMIdentity(entryID, entry, info, frames[entryID])
      local itemSpell
      if identity.itemID and C_Item and C_Item.GetItemSpell then
        local _, linkedSpell = C_Item.GetItemSpell(identity.itemID)
        itemSpell = linkedSpell
      end
      local effective = itemSpell or identity.spellID
      local spellInfo = effective and C_Spell.GetSpellInfo(effective)
      local hit
      if trigger.cdmItemExact then
        hit = numeric and identity.itemID == numeric
      elseif trigger.cdmExact then
        hit = numeric and (matchStrength(info, numeric) > 0 or identity.spellID == numeric or itemSpell == numeric)
      else
        hit = query ~= "" and (identity.name:lower() == lowered or spellInfo and spellInfo.name:lower() == lowered)
      end
      if hit then picked[#picked + 1] = entryID end
    end
  end
  table.sort(picked)
  return picked
end

local function pickBuffByName(entries, lowered)
  local topEntry, topSpell, topRank, topDirect
  for _, candidate in ipairs(indexBuffNames(entries)[lowered] or {}) do
    local record = candidate.spell
    if record.known == nil then
      record.known = WeakAuras.IsSpellKnownIncludingPet(record.id) == true
      if record.known then record.rank = rankFromSubtext(record.id) or 0 end
    end
    if record.known then
      local rank, direct, entryID = record.rank, candidate.direct, candidate.entryID
      local displayed = candidate.displayed
      local beatsTop = not topSpell or rank > topRank
        or (rank == topRank and displayed
          and (not topEntry or direct > topDirect or (direct == topDirect and entryID < topEntry)))
      if beatsTop then
        topEntry, topSpell, topRank, topDirect = displayed and entryID or nil, record.id, rank, direct
      end
    end
  end
  local picked = topEntry and {topEntry} or {}
  picked.singleClone = true
  picked.buffName = lowered
  picked.buffResolvedSpellID = topSpell
  picked.buffSpellIDs = topSpell and {topSpell} or {}
  return picked
end

local function memoizedLookups(memo)
  if memo and not memo.entryInfo then
    memo.entryInfo, memo.identities, memo.spellNames = {}, {}, {}
  end
  local function cooldownInfo(entryID)
    if not memo then return C_CooldownViewer.GetCooldownViewerCooldownInfo(entryID) end
    local stored = memo.entryInfo[entryID]
    if stored == nil then
      stored = C_CooldownViewer.GetCooldownViewerCooldownInfo(entryID) or false
      memo.entryInfo[entryID] = stored
    end
    return stored or nil
  end
  local function identityOf(entryID, entry, info)
    if not memo then return Private.CDMIdentity(entryID, entry, info) end
    local stored = memo.identities[entryID]
    if not stored then
      stored = Private.CDMIdentity(entryID, entry, info)
      memo.identities[entryID] = stored
    end
    return stored
  end
  local function loweredSpellName(spellID)
    if not memo then
      local spellInfo = C_Spell.GetSpellInfo(spellID)
      return spellInfo and spellInfo.name:lower()
    end
    local stored = memo.spellNames[spellID]
    if stored == nil then
      local spellInfo = C_Spell.GetSpellInfo(spellID)
      stored = spellInfo and spellInfo.name:lower() or false
      memo.spellNames[spellID] = stored
    end
    return stored or nil
  end
  return cooldownInfo, identityOf, loweredSpellName
end

local function scanEntries(trigger, entries, event, query, numeric, spell, lowered)
  local preview = event == "OPTIONS"
  local exact = trigger.cdmExact == true
  local wantsBuff = trigger.cdmSource == "buff"
  local spreadAuras = not exact and wantsBuff
  local auraSpellList, auraSeen, auraEntryList = {}, {}, {}
  local function addAuraSpell(spellID)
    if IsSecret(spellID) or type(spellID) ~= "number" or auraSeen[spellID] then return end
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo and spellInfo.name:lower() == lowered then
      auraSeen[spellID] = true
      auraSpellList[#auraSpellList + 1] = spellID
    end
  end
  local cooldownInfo, identityOf, loweredSpellName = memoizedLookups(preview and lookupCache)
  local topEntry, topRank, topScore
  for entryID, entry in pairs(entries) do
    local admitted = preview or entry.known or exact or spreadAuras or trigger.use_ignoreSpellKnown
    if admitted and Private.CDMIsBuff(entry.category) == wantsBuff then
      local info = cooldownInfo(entryID)
      if info and (trigger.cdmSelection ~= "spell" or Private.CDMEntryMatches(trigger, entry, info, preview)) then
        local identity = identityOf(entryID, entry, info)
        local score = exact and matchStrength(info, numeric) or 1
        local hit = exact and score > 0 or not exact and identity.name:lower() == lowered
        local auraIDs = spreadAuras and Private.CDMAuraSpellIDs(info)
        if spreadAuras and not hit then
          for _, auraID in ipairs(auraIDs) do
            if loweredSpellName(auraID) == lowered then
              hit = true
              break
            end
          end
        end
        if hit and spreadAuras then
          auraEntryList[#auraEntryList + 1] = entryID
          addAuraSpell(identity.spellID)
          for _, auraID in ipairs(auraIDs) do addAuraSpell(auraID) end
          score = entry.known and 1 or 0
        end
        if hit and identity.spellID then
          local probe = trigger.cdmSelection == "spell" and info.spellID or identity.spellID
          local subtext = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(probe)
          local rank = not IsSecret(subtext) and type(subtext) == "string" and tonumber(subtext:match("%d+")) or 0
          local better = not topEntry or score > topScore
            or (score == topScore and (rank > topRank or (rank == topRank and entryID < topEntry)))
          if better then topEntry, topRank, topScore = entryID, rank, score end
        end
      end
    end
  end
  if preview and not topEntry then
    return {previewSpell = spell or {name = query, iconID = 134400, spellID = numeric}, singleClone = true}
  end
  local result = topEntry and {topEntry} or {}
  if spreadAuras then
    table.sort(auraSpellList)
    table.sort(auraEntryList)
    result.buffSpellIDs = auraSpellList
    if trigger.cdmSelection == "spell" then result.buffEntryIDs = auraEntryList end
  end
  if trigger.cdmSelection == "spell" then result.singleClone = true end
  return result
end

function Private.ResolveCDMSpell(trigger, event)
  if trigger.type == "cdm" then
    trigger.cdmSource = trigger.event == "Blizzard CDM Buff" and "buff" or "cooldown"
  end
  if RELOAD_EVENTS[event] then Private.CDMResetIdentities() end
  local entries = loadCatalog(shouldReloadCatalog(event))
  local query = tostring(trigger.cdmSpell or ""):match("^%s*(.-)%s*$")
  if trigger.event == "Blizzard CDM Item" then
    return pickItemEntries(trigger, entries, event, query)
  end
  local cacheKey = tostring(trigger.cdmSelection) .. ":" .. tostring(trigger.event) .. ":" .. query
    .. ":" .. tostring(trigger.cdmExact) .. ":" .. (trigger.cdmSource or "cooldown")
    .. ":" .. tostring(trigger.use_ignoreSpellKnown) .. ":" .. tostring(event == "OPTIONS")
  if lookupCache.entries ~= entries then lookupCache = {entries = entries} end
  if lookupCache[cacheKey] then return lookupCache[cacheKey] end
  local numeric = tonumber(query)
  if trigger.cdmExact and not numeric then return {} end
  local spell = numeric and C_Spell.GetSpellInfo(numeric)
  local lowered = (spell and spell.name or query):lower()
  local outcome
  if event ~= "OPTIONS" and trigger.event == "Blizzard CDM Buff" and trigger.cdmExact ~= true then
    outcome = pickBuffByName(entries, lowered)
  else
    outcome = scanEntries(trigger, entries, event, query, numeric, spell, lowered)
  end
  lookupCache[cacheKey] = outcome
  return outcome
end

function Private.GetCDMPickerSelections(trigger, event)
  local picked = {buffSpellIDsByEntry = {}}
  local entries = loadCatalog(shouldReloadCatalog(event))
  local chosen = trigger.cdmSpells and trigger.cdmSpells.multi or {}
  for rawKey, enabled in pairs(chosen) do
    local id = tonumber(rawKey)
    local entry = id and entries[id]
    local info = entry and C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if enabled and info and Private.CDMEntryMatches(trigger, entry, info, event == "OPTIONS") then
      picked[#picked + 1] = id
      picked.buffSpellIDsByEntry[id] = Private.CDMAuraSpellIDs(info)
    end
  end
  table.sort(picked)
  return picked
end

local function hasFreeTextSpell(trigger)
  return trigger.cdmSpell ~= nil and tostring(trigger.cdmSpell):find("%S") and trigger.event ~= "Blizzard CDM Item"
end

function Private.CDMNativeSelections(trigger)
  local queries = Private.CDMSpellQueries(trigger)
  if queries then
    local bindings = {}
    for _, query in ipairs(queries) do
      for _, ids in ipairs(Private.CDMNativeSelections(query)) do bindings[#bindings + 1] = ids end
    end
    return bindings
  end
  if hasFreeTextSpell(trigger) then
    local resolution = Private.ResolveCDMSpell(trigger)
    local exactID = trigger.cdmExact and tonumber(trigger.cdmSpell)
    return {exactID and resolution[1] and {exactID} or resolution.buffSpellIDs}
  end
  local picked = Private.GetCDMPickerSelections(trigger, "OPTIONS")
  local bindings = {}
  for _, id in ipairs(picked) do bindings[#bindings + 1] = picked.buffSpellIDsByEntry[id] end
  return bindings
end

local function collectSelectionIDs(trigger)
  local queries = Private.CDMSpellQueries(trigger)
  if queries then
    local merged, present = {}, {}
    for _, query in ipairs(queries) do
      for _, id in ipairs(Private.ResolveCDMSpell(query)) do
        if not present[id] then
          merged[#merged + 1] = id
          present[id] = true
        end
      end
    end
    return merged
  end
  if hasFreeTextSpell(trigger) then return Private.ResolveCDMSpell(trigger) end
  return Private.GetCDMPickerSelections(trigger)
end

local function describeEntries(trigger)
  local labels = {}
  local frames = Private.CDMFrames()
  for id, entry in pairs(loadCatalog(true)) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      local identity = Private.CDMIdentity(id, entry, info, frames[id])
      local placement = "Layout unavailable"
      if entry.displayed == true then placement = "Displayed"
      elseif entry.displayed == false then placement = "Not displayed" end
      local suffix = entry.known and "" or " - Not learned"
      local reference = identity.spellID or identity.itemID or "Unknown"
      labels[id] = table.concat({
        placement, Private.CDMCategoryName(entry.category), identity.name .. " [" .. reference .. "]" .. suffix,
      }, " - ")
    end
  end
  for _, id in ipairs(collectSelectionIDs(trigger)) do
    if type(id) == "number" and not labels[id] then labels[id] = "Unavailable in this specialization" end
  end
  return labels
end

local cooldownFlags = {}

local function trackCooldownFlags(spellID, event)
  local info = C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
  local active = info and readFlag(info.isActive)
  if active == nil then return end
  local flags = cooldownFlags[spellID]
  if not flags then
    flags = {}
    cooldownFlags[spellID] = flags
  end
  if not active then
    flags.onCooldown, flags.onGCD = false, false
  elseif event == "SPELL_UPDATE_COOLDOWN" then
    if readFlag(info.isOnGCD) == nil then
      flags.onCooldown, flags.onGCD = nil, nil
    else
      local gcdRunning = info.isOnGCD == true
      flags.onCooldown, flags.onGCD = not gcdRunning, gcdRunning
    end
  end
  return flags.onCooldown, true, flags.onGCD
end

local blankDurationObject

local function blankDuration()
  blankDurationObject = blankDurationObject or C_DurationUtil.CreateDuration()
  return blankDurationObject
end

local touchedClones = {}

local RESET_FIELDS = {
  "durationObject", "duration", "expirationTime", "modRate",
  "cdmTextDurationObject", "cdmTextDurationRequired",
  "cdmAuraRenderUnit", "cdmAuraRenderSpellIDs",
  "cdmCountdownSource", "cdmStackSource", "cdmTextRecord", "cdmDispelName",
  "debuffClass", "isUsable", "insufficientResources",
  "onCooldown", "isReady", "recharging", "stacks", "auraActive",
}

local FRESH_DEFAULTS = {
  show = true,
  changed = true,
  autoHide = false,
  progressType = "static",
  value = 1,
  total = 1,
  cdmSuppressGCD = false,
  cdmNativePaused = false,
  cdmGCDOnly = false,
}

local SHOW_FILTERS = {
  cooldown = function(state) return state.onCooldown == true end,
  ready = function(state) return state.onCooldown == false end,
  active = function(state) return state.auraActive == true end,
  missing = function(state) return state.auraActive == false end,
}

local function fillPreviewState(state)
  state.progressType, state.duration, state.expirationTime = "timed", 6, GetTime() + 6
  state.value, state.total = nil, nil
  state.stacks, state.auraActive, state.onCooldown = 3, true, true
  state.cdmHideGCDText = false
end

local function fillBuffState(state, ctx, cooldownID, identity, info, bindingIDs)
  local selected, available, frames = ctx.selected, ctx.available, ctx.frames
  if not selected.buffEntryIDs then
    Private.CDMApplyAura(state, identity, info, frames[cooldownID], ctx.opts.exactID, bindingIDs or selected.buffSpellIDs)
    return
  end
  local topAura, topScore
  for _, auraID in ipairs(selected.buffEntryIDs) do
    local auraInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(auraID)
    if auraInfo and available[auraID] then
      local trial = {}
      local auraIdentity = Private.CDMIdentity(auraID, available[auraID], auraInfo, frames[auraID])
      Private.CDMApplyAura(trial, auraIdentity, auraInfo, frames[auraID], nil, selected.buffSpellIDs)
      local score = 0
      if trial.auraActive == true then score = 2 elseif trial.auraActive == nil then score = 1 end
      if not topAura or score > topScore then topAura, topScore = trial, score end
    end
  end
  for field, value in pairs(topAura or {}) do state[field] = value end
  if state.progressType ~= "static" then state.value, state.total = nil, nil end
end

local function fillSpellState(state, identity, frame, event, opts)
  local spellID = identity.spellID
  if C_SpellBook and C_SpellBook.FindSpellOverrideByID then
    local replacement = C_SpellBook.FindSpellOverrideByID(spellID)
    if readPositiveNumber(replacement) then spellID = replacement end
  end
  if C_Spell.IsSpellUsable then
    local usable, lacksResources = C_Spell.IsSpellUsable(spellID)
    state.isUsable = readFlag(usable)
    state.insufficientResources = readFlag(lacksResources)
  end
  local onCooldown, flagsKnown, onGCD = trackCooldownFlags(spellID, event)
  local realDuration = onGCD == true and blankDuration() or C_Spell.GetSpellCooldownDuration(spellID, true)
  -- While Shoot runs, other spells report the Shoot timer: show the timer copied before the shot
  local wandHeld = false
  if onGCD ~= true then
    realDuration, wandHeld = Private.SpellCooldownState.ApplyWandHold(spellID, realDuration)
    if wandHeld then
      local remaining = realDuration and Private.SpellCooldownState.ReadableRemaining(realDuration)
      if remaining then
        onCooldown = remaining > 0
      else
        onCooldown = nil
      end
    end
  end
  local textDuration = realDuration
  local native = Private.CDMGetNativeCooldown(frame, identity.spellID)
  state.cdmNativeRevision = native and native.revision
  local shownDuration = opts.showGCD and native and native.duration or realDuration
  state.cdmNativePaused = native and native.paused == true or false
  if native then
    state.inRange = native.inRange
    state.stacks = native.charges
    if native.charges ~= nil then state.isReady = native.charges > 0 end
    if native.onGCD ~= nil then state.cdmGCDOnly = native.onGCD end
    if native.onCooldown ~= nil then
      state.onCooldown = native.onCooldown
      if state.stacks == nil then state.isReady = not native.onCooldown end
    end
    if native.recharging ~= nil then state.recharging = native.recharging end
  end
  if onCooldown ~= nil then
    state.onCooldown, state.isReady = onCooldown, not onCooldown
    state.cdmNativePaused = false
    if onCooldown then
      shownDuration = realDuration
      state.cdmGCDOnly = false
    elseif onGCD then
      shownDuration = opts.showGCD and C_Spell.GetSpellCooldownDuration(spellID) or nil
      state.cdmGCDOnly = true
    else
      shownDuration = realDuration
      state.cdmGCDOnly = false
    end
  elseif flagsKnown and not state.cdmGCDOnly then
    shownDuration = opts.showGCD and C_Spell.GetSpellCooldownDuration(spellID) or realDuration
    state.cdmNativePaused = false
  end
  if wandHeld then
    shownDuration, state.cdmGCDOnly, state.cdmNativePaused = realDuration, false, false
  end
  local charges = C_Spell.GetSpellCharges and C_Spell.GetSpellCharges(spellID)
  if charges then
    local current = charges.currentCharges
    local refilling = readFlag(charges.isActive)
    if refilling ~= nil then state.recharging = refilling end
    if not IsSecret(current) and type(current) == "number" then
      state.stacks = current
      state.isReady, state.onCooldown = current > 0, current == 0
    elseif native and native.recharging == true then
      state.isReady, state.onCooldown = true, false
    end
  end
  local track = opts.track
  if C_Spell.GetSpellChargeDuration and (track == "charges" or (track == "auto" and state.recharging == true)) then
    local chargeDuration = C_Spell.GetSpellChargeDuration(spellID)
    if chargeDuration then
      shownDuration, textDuration = chargeDuration, chargeDuration
      state.cdmGCDOnly, state.cdmNativePaused = false, false
    end
  end
  if state.cdmGCDOnly and not opts.showGCD then shownDuration = nil end
  state.cdmSuppressGCD = not shownDuration
  state.value, state.total = nil, nil
  if shownDuration then
    state.progressType, state.durationObject = "durationObject", shownDuration
  else
    state.progressType, state.duration, state.expirationTime = "timed", 0, 0
  end
  if opts.hideGCDText then
    state.cdmTextDurationObject = textDuration
    state.cdmTextDurationRequired = true
  end
end

local function anySpellKnown(candidates)
  for _, id in pairs(candidates) do
    if readPositiveNumber(id) and id < 2147483647 and WeakAuras.IsSpellKnownIncludingPet(id) then
      return true
    end
  end
  return false
end

local function finalizeVisibility(state, entry, info, identity, opts)
  local mode = opts.showMode
  if mode == "usable" then
    state.show = state.isUsable == true
  elseif mode == "unusable" then
    state.show = state.isUsable == false
  end
  if not opts.ignoreSpellKnown and not state.cdmBuff
      and not Private.CDMEntryMatches({event = "Blizzard CDM Item"}, entry, info) then
    local learned = anySpellKnown({identity.spellID, info.spellID, info.overrideSpellID, info.linkedSpellID})
    if not learned then state.show = false end
  end
  local filter = state.show and SHOW_FILTERS[mode]
  if filter then state.show = filter(state) end
end

local function composeEntry(allstates, ctx, index, cooldownID, entry, info)
  local selected, event, opts = ctx.selected, ctx.event, ctx.opts
  local frame = ctx.frames[cooldownID]
  local identity = Private.CDMIdentity(cooldownID, entry, info, frame)
  local forcedSpell = opts.exactID or selected.buffResolvedSpellID
  if forcedSpell then
    local forcedInfo = C_Spell.GetSpellInfo(forcedSpell)
    identity = {
      spellID = forcedSpell,
      name = forcedInfo and forcedInfo.name or identity.name,
      icon = forcedInfo and forcedInfo.iconID or identity.icon,
    }
  end
  local cloneID = selected.singleClone and "spell" or tostring(cooldownID)
  local state = allstates[cloneID]
  if not state then
    state = {}
    allstates[cloneID] = state
  elseif not touchedClones[cloneID] then
    wipe(state)
  end
  touchedClones[cloneID] = true
  for field, value in pairs(FRESH_DEFAULTS) do state[field] = value end
  for _, field in ipairs(RESET_FIELDS) do state[field] = nil end
  local isBuff = Private.CDMIsBuff(entry.category)
  local bindingIDs = selected.buffSpellIDsByEntry and selected.buffSpellIDsByEntry[cooldownID]
  state.index, state.name, state.icon = index, identity.name, identity.icon
  state.spellId, state.itemId = identity.spellID, identity.itemID
  state.cooldownID = type(cooldownID) == "number" and cooldownID or nil
  state.cdmDisplayed, state.cdmCategory = entry.displayed, Private.CDMCategoryName(entry.category)
  state.cdmBuff = isBuff
  state.cdmAuraSpellIDs = nil
  if isBuff then
    state.cdmAuraSpellIDs = bindingIDs or (opts.exactID and {opts.exactID}) or selected.buffSpellIDs or {identity.spellID}
  end
  state.cdmTextPreview = event == "OPTIONS"
  state.cdmHideGCDText = opts.hideGCDText == true

  if event == "OPTIONS" then
    fillPreviewState(state)
  elseif isBuff then
    fillBuffState(state, ctx, cooldownID, identity, info, bindingIDs)
  elseif identity.slot or identity.itemID then
    Private.CDMApplyItem(state, identity)
  elseif identity.spellID then
    fillSpellState(state, identity, frame, event, opts)
  end
  if event ~= "OPTIONS" then finalizeVisibility(state, entry, info, identity, opts) end
  state.hasTimer = state.durationObject ~= nil or state.progressType == "timed"
end

local PASSIVE_EVENTS = {
  WA_CDM_REFRESH = true,
  OPTIONS = true,
  GET_ITEM_INFO_RECEIVED = true,
  ITEM_DATA_LOAD_RESULT = true,
}

local IDENTITY_RESET_EVENTS = {
  PLAYER_SPECIALIZATION_CHANGED = true,
  PLAYER_EQUIPMENT_CHANGED = true,
  PLAYER_ENTERING_WORLD = true,
}

local function buildStates(allstates, selected, event, opts)
  wipe(touchedClones)
  if IDENTITY_RESET_EVENTS[event] then Private.CDMResetIdentities() end
  local available = loadCatalog(shouldReloadCatalog(event))
  local frames = Private.CDMFrames()
  for _, state in pairs(allstates) do
    state.show = false
    state.changed = true
  end

  if not PASSIVE_EVENTS[event] and #selected > 0 then Private.QueueCDMRefresh() end
  if event == "OPTIONS" and selected.previewSpell then
    local sample = selected.previewSpell
    allstates.spell = {
      show = true, changed = true, progressType = "timed", duration = 6,
      expirationTime = GetTime() + 6, autoHide = false, name = sample.name, icon = sample.iconID,
      spellId = sample.spellID, cdmTextPreview = true, index = 1,
    }
    touchedClones.spell = true
    return true
  end
  if not viewerApiReady() then return true end
  if opts.requireTarget and event ~= "OPTIONS" then
    local targetExists = UnitExists("target")
    local targetHostile = UnitCanAttack("player", "target")
    if IsSecret(targetExists, targetHostile) then return true end
    if not targetExists or not targetHostile then return true end
  end

  local ctx = {selected = selected, event = event, opts = opts, available = available, frames = frames}
  for index, cooldownID in ipairs(selected) do
    local entry = available[cooldownID]
    local admitted = entry and (event == "OPTIONS" or entry.known or opts.exactID
      or selected.buffSpellIDs or selected.buffSpellIDsByEntry or opts.ignoreSpellKnown)
    if admitted then
      local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
      if info then composeEntry(allstates, ctx, index, cooldownID, entry, info) end
    end
  end
  return true
end

local outputPool = setmetatable({}, {__mode = "k"})

local function childTable(parent, key)
  local child = parent[key]
  if not child then
    child = {}
    parent[key] = child
  end
  return child
end

local function computeOutputs(selected, event, showGCD, track, hideGCDText, showMode, exactID, requireTarget, ignoreSpellKnown)
  local batch = Private.cdmScanBatch
  local key = (event or "") .. ":" .. tostring(showGCD) .. ":" .. tostring(track) .. ":" .. tostring(hideGCDText)
    .. ":" .. tostring(showMode) .. ":" .. tostring(exactID) .. ":" .. tostring(requireTarget)
    .. ":" .. tostring(ignoreSpellKnown)
  local batchBucket
  if batch then
    batch.outputs = batch.outputs or {}
    batchBucket = childTable(batch.outputs, selected)
    if batchBucket[key] then return batchBucket[key] end
  end
  local outputs = childTable(childTable(outputPool, selected), key)
  buildStates(outputs, selected, event, {
    showGCD = showGCD, track = track, hideGCDText = hideGCDText, showMode = showMode,
    exactID = exactID, requireTarget = requireTarget, ignoreSpellKnown = ignoreSpellKnown,
  })
  for cloneID in pairs(outputs) do
    if not touchedClones[cloneID] then outputs[cloneID] = nil end
  end
  if batchBucket then batchBucket[key] = outputs end
  return outputs
end

local function unchangedSince(previous, current)
  if not previous or current.cdmBuff then return false end
  if InCombatLockdown and InCombatLockdown() then return false end
  for field, value in pairs(current) do
    if field ~= "changed" then
      local before = previous[field]
      if IsSecret(value, before) or value ~= before then return false end
    end
  end
  for field in pairs(previous) do
    if field ~= "changed" and current[field] == nil then return false end
  end
  return true
end

local lastApplied = setmetatable({}, {__mode = "k"})

local function stripSnapshotFields(state, snapshot)
  if not snapshot then return end
  for field in pairs(snapshot) do
    if field ~= "changed" then state[field] = nil end
  end
end

local function copyFields(destination, source)
  for field, value in pairs(source) do destination[field] = value end
end

local function applyOutputs(allstates, outputs)
  local history = childTable(lastApplied, allstates)
  local dirty = false
  for key, output in pairs(outputs) do
    local state = allstates[key]
    local snapshot = history[key]
    if not state or not unchangedSince(snapshot, output) or state.show ~= output.show then
      if not state then
        state = {}
        allstates[key] = state
      end
      stripSnapshotFields(state, snapshot)
      copyFields(state, output)
      state.changed = true
      dirty = true
    end
    if snapshot then
      wipe(snapshot)
    else
      snapshot = {}
      history[key] = snapshot
    end
    copyFields(snapshot, output)
  end
  for key, state in pairs(allstates) do
    if not outputs[key] and state.show then
      stripSnapshotFields(state, history[key])
      state.show, state.changed = false, true
      dirty = true
    end
  end
  for key in pairs(history) do
    if not outputs[key] then history[key] = nil end
  end
  return dirty
end

Private.UpdateCooldownViewerStates = function(allstates, ...)
  return applyOutputs(allstates, computeOutputs(...))
end

Private.ExecEnv.UpdateCooldownViewerStates = Private.UpdateCooldownViewerStates
Private.ExecEnv.GetCDMPickerSelections = Private.GetCDMPickerSelections

Private.ExecEnv.UpdateCDMSpell = function(allstates, config, event, ...)
  local selected = Private.ResolveCDMSpell(config, event)
  local exactID = config.cdmExact and tonumber(config.cdmSpell) or nil
  return Private.UpdateCooldownViewerStates(allstates, selected, event, config.showGCD, config.track,
    config.hideGCDText, config.showMode, exactID, config.requireTarget, config.use_ignoreSpellKnown)
end

local listOutputs = setmetatable({}, {__mode = "k"})
local listClones = setmetatable({}, {__mode = "k"})

Private.ExecEnv.UpdateCDMSelectionList = function(allstates, queries, event)
  local merged = listOutputs[allstates]
  if merged then wipe(merged) else merged = {}; listOutputs[allstates] = merged end
  local cloneStore = childTable(listClones, allstates)
  for queryIndex, query in ipairs(queries) do
    local selected = Private.ResolveCDMSpell(query, event)
    local exactID = query.event ~= "Blizzard CDM Item" and query.cdmExact and tonumber(query.cdmSpell) or nil
    local produced = computeOutputs(selected, event, query.showGCD, query.track, query.hideGCDText,
      query.showMode, exactID, query.requireTarget, query.use_ignoreSpellKnown)
    for _, candidate in pairs(produced) do
      local state = candidate
      local key = tostring(state.cooldownID) .. ":" .. tostring(state.spellId or query.cdmSpell)
      if query.event == "Blizzard CDM Buff" then
        if query.cdmExact then
          key = "id:" .. tostring(tonumber(query.cdmSpell))
        else
          key = "name:" .. (selected.buffName or query.cdmSpell)
        end
        local clone = cloneStore[key]
        if clone then wipe(clone) else clone = {}; cloneStore[key] = clone end
        copyFields(clone, state)
        clone.index = queryIndex
        state = clone
      end
      local current = merged[key]
      if not current or not current.show or state.show then merged[key] = state end
    end
  end
  return applyOutputs(allstates, merged)
end

local function boolTest(field)
  return function(state, needle)
    return state and state.show and state[field] ~= nil and state[field] == (needle == 1)
  end
end

local function conditionArg(name, display, conditionType)
  local arg = {name = name, display = display, conditionType = conditionType, hidden = true}
  if conditionType == "bool" then arg.conditionTest = boolTest(name) end
  if conditionType == "number" then arg.operator_types = "only_equal" end
  return arg
end

local ORDER_TESTS = {
  ["<"] = function(left, right) return left < right end,
  ["<="] = function(left, right) return left <= right end,
  [">"] = function(left, right) return left > right end,
  [">="] = function(left, right) return left >= right end,
}

local STACK_TESTS = {
  ["<"] = ORDER_TESTS["<"],
  ["<="] = ORDER_TESTS["<="],
  [">"] = ORDER_TESTS[">"],
  [">="] = ORDER_TESTS[">="],
  ["=="] = function(left, right) return left == right end,
  ["~="] = function(left, right) return left ~= right end,
}

local REMAINING_TESTS = {
  ["<"] = ORDER_TESTS["<"],
  ["<="] = ORDER_TESTS["<="],
  [">"] = ORDER_TESTS[">"],
  [">="] = ORDER_TESTS[">="],
  ["=="] = function(left, right) return math.abs(left - right) < 0.05 end,
  ["~="] = function(left, right) return math.abs(left - right) >= 0.05 end,
}

local function auraRemaining(state)
  if not state or not state.show or not state.cdmBuff or state.auraActive ~= true then return end
  local remaining, scale = nil, 1
  local timer = state.durationObject
  if timer then
    local total = timer:GetTotalDuration()
    if IsSecret(total) or type(total) ~= "number" or total <= 0 then return end
    remaining = timer:GetRemainingDuration()
  else
    local span, expiresAt, rate = state.duration, state.expirationTime, state.modRate
    if IsSecret(span, expiresAt, rate) then return end
    if type(span) ~= "number" or span <= 0 or type(expiresAt) ~= "number" then return end
    rate = rate or 1
    if type(rate) ~= "number" or rate <= 0 then return end
    remaining = (expiresAt - GetTime()) / rate
    scale = rate
  end
  if not IsSecret(remaining) and type(remaining) == "number" and remaining == remaining and remaining < math.huge then
    return math.max(0, remaining), scale
  end
end

local function auraTimeValue(state, wantElapsed)
  if not state.show or not state.cdmBuff or state.auraActive ~= true then return end
  local total, measured, scale = nil, nil, 1
  local timer = state.durationObject
  if timer then
    total = timer:GetTotalDuration()
    if IsSecret(total) or type(total) ~= "number" or total <= 0 or total >= math.huge then return end
    if wantElapsed then measured = timer:GetElapsedDuration() else measured = total end
  else
    total, scale = state.duration, state.modRate
    if IsSecret(total, scale) then return end
    scale = scale or 1
    if type(total) ~= "number" or total <= 0 or total >= math.huge then return end
    if type(scale) ~= "number" or scale <= 0 or scale >= math.huge then return end
    measured = total / scale
    if wantElapsed then
      local expiresAt = state.expirationTime
      if IsSecret(expiresAt) or type(expiresAt) ~= "number" then return end
      measured = (GetTime() - (expiresAt - total)) / scale
    end
  end
  if not IsSecret(measured) and type(measured) == "number" and measured == measured and measured < math.huge then
    return math.max(0, measured), scale
  end
end

local function stacksPass(state, wanted, op)
  local count = state.stacks
  if state.auraActive ~= true or IsSecret(count) or type(count) ~= "number" then return false end
  local compare = STACK_TESTS[op]
  return compare and compare(count, wanted) or false
end

local function timePass(measured, threshold, op)
  if measured == nil then return false end
  local compare = ORDER_TESTS[op]
  return compare and compare(measured, threshold) or false
end

local remainingCondition = {
  name = "cdmRemaining",
  display = "Remaining Time (when readable)",
  hidden = true,
  conditionType = "number",
  noProgressSource = true,
  conditionTest = function(state, value, op)
    local remaining = auraRemaining(state)
    value = tonumber(value)
    if remaining == nil or not value then return false end
    local compare = REMAINING_TESTS[op]
    return compare and compare(remaining, value) or false
  end,
  conditionRecheckTime = function(state, value)
    local remaining, scale = auraRemaining(state)
    value = tonumber(value)
    if not remaining or remaining <= 0 or not value then return end
    local wait = remaining * scale
    for _, boundary in ipairs({value + 0.05, value, value - 0.05}) do
      if boundary >= 0 and remaining >= boundary then
        wait = math.min(wait, (remaining - boundary) * scale + 0.001)
      end
    end
    return GetTime() + math.max(0.001, wait)
  end,
}

local filterOutputs = setmetatable({}, {__mode = "k"})
local pendingWakeups = setmetatable({}, {__mode = "k"})

local function scheduleWakeup(rawStates, nextCheck)
  local pending = pendingWakeups[rawStates]
  if pending and pending.at == nextCheck then return end
  if pending and pending.timer and pending.timer.Cancel then pending.timer:Cancel() end
  pendingWakeups[rawStates] = nil
  if not nextCheck then return end
  local wakeup = {at = nextCheck}
  pendingWakeups[rawStates] = wakeup
  local function fire()
    if pendingWakeups[rawStates] == wakeup then
      pendingWakeups[rawStates] = nil
      Private.QueueCDMRefresh()
    end
  end
  local wait = math.max(0.001, nextCheck - GetTime())
  if C_Timer.NewTimer then
    wakeup.timer = C_Timer.NewTimer(wait, fire)
  else
    C_Timer.After(wait, fire)
  end
end

Private.ExecEnv.UpdateCDMBuffFilters = function(allstates, rawStates, event, value, op, stackValue, stackOp, totalValue, totalOp, elapsedValue, elapsedOp)
  value, stackValue = tonumber(value), tonumber(stackValue)
  totalValue, elapsedValue = tonumber(totalValue), tonumber(elapsedValue)
  local outputs = childTable(filterOutputs, rawStates)
  for key in pairs(outputs) do
    if not rawStates[key] then outputs[key] = nil end
  end
  local nextCheck
  local function earliest(candidate)
    if not nextCheck or candidate < nextCheck then nextCheck = candidate end
  end
  for key, state in pairs(rawStates) do
    local output = outputs[key]
    if output then wipe(output) else output = {} end
    copyFields(output, state)
    if event ~= "OPTIONS" then
      if value then
        output.show = state.show and remainingCondition.conditionTest(state, value, op) or false
        local recheck = remainingCondition.conditionRecheckTime(state, value)
        if recheck then earliest(recheck) end
      end
      if stackValue then output.show = output.show and stacksPass(state, stackValue, stackOp) or false end
      if totalValue then output.show = output.show and timePass(auraTimeValue(state), totalValue, totalOp) or false end
      if elapsedValue then
        local elapsed, scale = auraTimeValue(state, true)
        output.show = output.show and timePass(elapsed, elapsedValue, elapsedOp) or false
        local remaining = auraRemaining(state)
        if elapsed and remaining and remaining > 0 and elapsed <= elapsedValue then
          local wait = math.min((elapsedValue - elapsed) * scale + 0.001, remaining * scale)
          earliest(GetTime() + math.max(0.001, wait))
        end
      end
    end
    outputs[key] = output
  end
  scheduleWakeup(rawStates, nextCheck)
  return applyOutputs(allstates, outputs)
end

local function presentEvents()
  local list = {
    "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "SPELLS_CHANGED",
    "SPELL_UPDATE_COOLDOWN", "SPELL_UPDATE_CHARGES", "SPELL_UPDATE_ICON",
    "PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_COOLDOWN", "PLAYER_TARGET_CHANGED", "PLAYER_TOTEM_UPDATE",
  }
  if viewerApiReady() then
    for _, eventName in ipairs({
      "COOLDOWN_VIEWER_DATA_LOADED", "COOLDOWN_VIEWER_TABLE_HOTFIXED", "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED",
    }) do
      list[#list + 1] = eventName
    end
  end
  return {events = list, unit_events = {
    player = {"UNIT_AURA"},
    target = {"UNIT_AURA", "UNIT_FACTION", "UNIT_FLAGS"},
  }}
end

local function extendEvents(extras)
  return function()
    local result = presentEvents()
    for _, eventName in ipairs(extras) do result.events[#result.events + 1] = eventName end
    return result
  end
end

local spellEvents = extendEvents({
  "ACTIONBAR_UPDATE_USABLE", "ACTION_USABLE_CHANGED", "SPELL_UPDATE_USABLE", "UPDATE_SHAPESHIFT_FORM",
})
local itemEvents = extendEvents({"GET_ITEM_INFO_RECEIVED", "ITEM_DATA_LOAD_RESULT"})

local function nameAndIcon(trigger)
  local entries, frames = loadCatalog(), Private.CDMFrames()
  for _, id in ipairs(collectSelectionIDs(trigger)) do
    local info = entries[id] and C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      local identity = Private.CDMIdentity(id, entries[id], info, frames[id])
      return identity.name, identity.icon
    end
  end
  return "Cooldown Manager", 134400
end

local function thresholdText(enabled, value, fallback)
  return enabled and tostring(value or fallback) or ""
end

local function compileTrigger(trigger)
  local isBuff = trigger.event == "Blizzard CDM Buff"
  if isBuff then Private.CDMFrames() end
  if isBuff and (trigger.cdmUseRemaining or trigger.cdmUseStacks or trigger.cdmUseTotal or trigger.cdmUseElapsed) then
    local inner = {}
    for field, value in pairs(trigger) do inner[field] = value end
    inner.cdmUseRemaining, inner.cdmUseStacks, inner.cdmUseTotal, inner.cdmUseElapsed = nil, nil, nil, nil
    local innerSource = compileTrigger(inner)
    local template = "local update=(function() %s end)()\nlocal rawStates={}\n"
      .. "return function(allstates,event) update(rawStates,event); "
      .. "return Private.ExecEnv.UpdateCDMBuffFilters(allstates,rawStates,event,%q,%q,%q,%q,%q,%q,%q,%q) end"
    return template:format(
      innerSource,
      thresholdText(trigger.cdmUseRemaining, trigger.cdmRemainingTime, 10), trigger.cdmRemainingOperator or "<",
      thresholdText(trigger.cdmUseStacks, trigger.cdmStackCount, 1), trigger.cdmStackOperator or ">=",
      thresholdText(trigger.cdmUseTotal, trigger.cdmTotalTime, 10), trigger.cdmTotalOperator or "<",
      thresholdText(trigger.cdmUseElapsed, trigger.cdmElapsedTime, 10), trigger.cdmElapsedOperator or ">=")
  end
  local queries = Private.CDMSpellQueries(trigger)
  if queries then
    local literals = {}
    local queryTemplate = "{type='cdm',event=%q,cdmSelection='spell',cdmSpell=%q,cdmExact=%s,"
      .. "cdmItemExact=%s,use_ignoreSpellKnown=%s,showGCD=%s,track=%q,hideGCDText=%s,"
      .. "showMode=%q,requireTarget=%s}"
    for _, query in ipairs(queries) do
      literals[#literals + 1] = queryTemplate:format(
        query.event, query.cdmSpell, tostring(query.cdmExact), tostring(query.cdmItemExact),
        tostring(query.use_ignoreSpellKnown == true), tostring(query.showGCD), query.track,
        tostring(query.hideGCDText), query.showMode, tostring(query.requireTarget))
    end
    return ("local queries={%s}\nreturn function(allstates,event) "
      .. "return Private.ExecEnv.UpdateCDMSelectionList(allstates,queries,event) end"):format(table.concat(literals, ","))
  end
  if trigger.type == "cdm" then
    trigger.cdmSource = isBuff and "buff" or "cooldown"
  end
  if hasFreeTextSpell(trigger) then
    local buffSource = trigger.cdmSource == "buff"
    local template = "local config = {type=%q,event=%q,cdmSelection=%q,cdmSpell=%q, cdmExact=%s, "
      .. "cdmSource=%q, showGCD=%s, track=%q, hideGCDText=%s, showMode=%q, requireTarget=%s, "
      .. "use_ignoreSpellKnown=%s}\n"
      .. "return function(allstates,event,...) return Private.ExecEnv.UpdateCDMSpell(allstates,config,event,...) end"
    return template:format(
      trigger.type or "", trigger.event or "", trigger.cdmSelection or "", trigger.cdmSpell,
      tostring(trigger.cdmExact == true), trigger.cdmSource or "cooldown",
      tostring(trigger.use_cdmShowGCD == true), trigger.cdmTrack or "auto",
      tostring(trigger.cdmHideGCDText ~= false),
      buffSource and (trigger.cdmBuffShow or "active") or (trigger.cdmShow or "always"),
      tostring(buffSource and trigger.cdmRequireTarget == true),
      tostring(trigger.use_ignoreSpellKnown == true))
  end
  local literalKeys = {}
  for rawKey, enabled in pairs(trigger.cdmSpells and trigger.cdmSpells.multi or {}) do
    local id = tonumber(rawKey)
    if enabled and id then literalKeys[#literalKeys + 1] = ("[%d]=true"):format(id) end
  end
  local template = "local config={type='cdm',event=%q,cdmSpells={multi={%s}}}\n"
    .. "return function(allstates,event,...) "
    .. "local selected=Private.ExecEnv.GetCDMPickerSelections(config,event); "
    .. "return Private.ExecEnv.UpdateCooldownViewerStates(allstates,selected,event,%s,%q,%s,%q,nil,%s,%s) end"
  return template:format(
    trigger.event or "Blizzard Cooldown Manager", table.concat(literalKeys, ","),
    tostring(trigger.use_cdmShowGCD == true), trigger.cdmTrack or "auto",
    tostring(trigger.cdmHideGCDText ~= false),
    isBuff and (trigger.cdmBuffShow or "active") or (trigger.cdmShow or "always"),
    tostring(isBuff and trigger.cdmRequireTarget == true),
    tostring(trigger.use_ignoreSpellKnown == true))
end

local argByName = {
  cdmSpells = {
    name = "cdmSpells",
    display = "Cooldown Manager entries",
    type = "multiselect",
    required = true,
    multiNoSingle = true,
    sorted = true,
    values = describeEntries,
  },
  cdmShowGCD = {name = "cdmShowGCD", display = "Include global cooldown", type = "toggle"},
  spellId = conditionArg("spellId", "Spell ID", "number"),
  name = conditionArg("name", "Spell Name", "string"),
  onCooldown = conditionArg("onCooldown", "On Cooldown", "bool"),
  isReady = conditionArg("isReady", "Ready", "bool"),
  recharging = conditionArg("recharging", "Recharging", "bool"),
  itemId = conditionArg("itemId", "Item ID", "number"),
  cdmCategory = conditionArg("cdmCategory", "CDM Category", "string"),
  cdmDisplayed = conditionArg("cdmDisplayed", "Displayed in CDM", "bool"),
  auraActive = conditionArg("auraActive", "Aura Active (when readable)", "bool"),
  inRange = conditionArg("inRange", "Spell In Range", "bool"),
  isUsable = conditionArg("isUsable", "Spell Usable", "bool"),
  insufficientResources = conditionArg("insufficientResources", "Insufficient Resources", "bool"),
}

local function argList(names)
  local list = {}
  for position, argName in ipairs(names) do list[position] = argByName[argName] end
  return list
end

local cooldownNames = {
  "cdmSpells", "cdmShowGCD", "spellId", "name", "onCooldown", "isReady", "recharging",
  "itemId", "cdmCategory", "cdmDisplayed",
}
local cooldownArgs = argList(cooldownNames)
local spellNames = {unpack(cooldownNames)}
for _, extra in ipairs({"inRange", "isUsable", "insufficientResources"}) do spellNames[#spellNames + 1] = extra end
local spellArgs = argList(spellNames)
local buffArgs = argList({"cdmSpells", "spellId", "name", "itemId", "cdmCategory", "cdmDisplayed", "auraActive"})
buffArgs[#buffArgs + 1] = remainingCondition

local INTERNAL_EVENTS = {"WA_CDM_REFRESH", "WA_CDM_LAYOUT_CHANGED"}

-- Starts the cooldown handler, which feeds the Shoot hold of SpellCooldownState
local function watchSpellCasts()
  WeakAuras.WatchGCD()
end

local function newPrototype(displayName, eventsFunction, args)
  return {
    loadFunc = eventsFunction == spellEvents and watchSpellCasts or nil,
    type = "cdm",
    name = displayName,
    statesParameter = "full",
    progressType = "timed",
    cooldownViewerProgress = true,
    automaticrequired = true,
    force_events = "PLAYER_ENTERING_WORLD",
    internal_events = INTERNAL_EVENTS,
    GetNameAndIcon = nameAndIcon,
    events = eventsFunction,
    triggerFunction = compileTrigger,
    args = args,
  }
end

Private.CooldownViewerPrototype = newPrototype("Cooldown", spellEvents, spellArgs)
Private.CooldownViewerBuffPrototype = newPrototype("Buff/Debuff", presentEvents, buffArgs)
Private.CooldownViewerUtilityPrototype = newPrototype("Cooldown", spellEvents, spellArgs)
Private.CooldownViewerItemPrototype = newPrototype("Item", itemEvents, cooldownArgs)

if EventRegistry and EventRegistry.RegisterCallback then
  EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
    catalogCache = nil
    C_Timer.After(0, function()
      if Private.ScanEvents then Private.ScanEvents("WA_CDM_LAYOUT_CHANGED") end
    end)
  end, Private.CooldownViewerPrototype)
end

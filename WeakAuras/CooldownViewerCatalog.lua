-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end

local _, Private = ...

local function isSecret(value)
  return issecretvalue ~= nil and issecretvalue(value) and true or false
end

local function readable(value)
  if isSecret(value) then return nil end
  return value
end

local function readNumber(value)
  if isSecret(value) or type(value) ~= "number" then return nil end
  return value
end

local function readBoolean(value)
  if isSecret(value) or type(value) ~= "boolean" then return nil end
  return value
end

local function readString(value)
  if isSecret(value) or type(value) ~= "string" then return nil end
  return value
end

local function weakKeyed()
  return setmetatable({}, { __mode = "k" })
end

local nativeRecords = weakKeyed()
local watchedViewers = weakKeyed()
local nativeSpells = weakKeyed()
local timerMemories = weakKeyed()
local identityMemory = {}
local requestedItems = {}
local pendingSelfCasts = {}
local refreshPending = false

local viewerNames = { "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer" }
local buffViewerNames = { BuffIconCooldownViewer = true, BuffBarCooldownViewer = true }

local categoryLabels = {
  TrackedBar = "Tracked Bars",
  TrackedBuff = "Tracked Buffs",
  GroupBuff = "Group Buffs",
  SpecAgnosticTracked = "Shared Buffs",
  SpecAgnosticEssential = "Shared Cooldowns",
  EquipSlotTracked = "Item Buffs",
  EquipSlotEssential = "Item Cooldowns",
  Utility = "Utility",
  Essential = "Essential",
}

local buffCategoryNames = { "TrackedBuff", "TrackedBar", "GroupBuff", "SpecAgnosticTracked", "EquipSlotTracked" }

local textWords = { bp = true, bs = true, p = true, s = true, caster = true, dispel = true }

local function queueRefresh()
  if refreshPending then return end
  refreshPending = true
  C_Timer.After(0, function()
    refreshPending = false
    if Private.ScanEvents then
      Private.ScanEvents("WA_CDM_REFRESH")
    end
  end)
end

Private.QueueCDMRefresh = queueRefresh

function Private.CDMRequestItemData(itemID)
  if not itemID or not C_Item or not C_Item.IsItemDataCachedByID or not C_Item.RequestLoadItemDataByID then return end
  if requestedItems[itemID] or C_Item.IsItemDataCachedByID(itemID) then return end
  requestedItems[itemID] = true
  C_Item.RequestLoadItemDataByID(itemID)
end

function Private.CDMResetIdentities()
  local batch = Private.cdmScanBatch
  if batch then
    if batch.identitiesReset then return end
    batch.identitiesReset = true
  end
  identityMemory = {}
end

function Private.CDMCategoryName(category)
  local categories = Enum and Enum.CooldownViewerCategory
  if categories and category ~= nil then
    for name, value in pairs(categories) do
      if value == category then
        return categoryLabels[name] or name
      end
    end
  end
  return "Other"
end

function Private.CDMIsBuff(category)
  local categories = Enum and Enum.CooldownViewerCategory or {}
  for _, name in ipairs(buffCategoryNames) do
    if category == categories[name] then return true end
  end
  return false
end

local function newDuration()
  if C_DurationUtil and C_DurationUtil.CreateDuration then
    return C_DurationUtil.CreateDuration()
  end
  return nil
end

local function rereadFrame(frame, record)
  record.read = true
  record.cooldownID = readable(frame.cooldownID)
  record.spellID = nil
  if frame.GetSpellID then
    record.spellID = readable(frame:GetSpellID())
  end
  record.onCooldown = readBoolean(frame.isOnActualCooldown)
  record.recharging = readBoolean(frame.wasSetFromCharges)
  record.paused = readable(frame.cooldownPaused) == true
  if record.completedRevision ~= nil and record.completedRevision == record.revision then
    record.onCooldown = false
    record.recharging = false
  end
  record.charges = readNumber(frame.cooldownChargesCount)
  record.onGCD = readBoolean(frame.isOnGCD)
  if record.onCooldown or record.recharging or readable(frame.cooldownUseAuraDisplayTime) == true then
    record.onGCD = false
  end
end

local function restartTimer(frame, record, durationObject, raw)
  record.revision = record.revision + 1
  record.duration = durationObject
  record.raw = raw
  record.converted = nil
  rereadFrame(frame, record)
  queueRefresh()
end

local function convertRaw(record)
  if record.converted then return record.converted end
  local raw = record.raw
  if not raw then return nil end
  local object = newDuration()
  if object and pcall(object.SetTimeFromStart, object, raw.start, raw.duration, raw.modRate) then
    record.converted = object
    return object
  end
  return nil
end

local function timerExpired(record)
  if record.paused then return false end
  local object = record.duration or record.converted
  if object and object.GetRemainingDuration then
    local ok, remaining = pcall(object.GetRemainingDuration, object)
    remaining = ok and readNumber(remaining) or nil
    return remaining ~= nil and remaining <= 0
  end
  local raw = record.raw
  if raw then
    local start = readNumber(raw.start)
    local duration = readNumber(raw.duration)
    local modRate = raw.modRate
    if isSecret(modRate) then
      modRate = nil
    elseif modRate == nil then
      modRate = 1
    else
      modRate = readNumber(modRate)
    end
    if start and duration and modRate and modRate > 0 then
      return GetTime() >= start + duration / modRate
    end
  end
  return false
end

local function hookMethod(target, method, handler)
  if hooksecurefunc and type(target[method]) == "function" then
    hooksecurefunc(target, method, handler)
  end
end

local function seedFromWidget(frame, record, widget)
  local raw
  if widget.GetCooldownTimes then
    local ok, start, duration = pcall(widget.GetCooldownTimes, widget)
    start = ok and readNumber(start) or nil
    duration = ok and readNumber(duration) or nil
    if start and duration then
      raw = { start = start / 1000, duration = duration / 1000, modRate = frame.cooldownModRate }
    end
  end
  if not raw and frame.RefreshSpellCooldownInfo then
    raw = { start = frame.cooldownStartTime, duration = frame.cooldownDuration, modRate = frame.cooldownModRate }
  end
  record.raw = raw
end

local function observeFrame(frame)
  if nativeRecords[frame] or not hooksecurefunc then return end
  local record = { revision = 0 }
  nativeRecords[frame] = record

  local function restart()
    restartTimer(frame, record, nil, nil)
  end
  local function relay()
    rereadFrame(frame, record)
    queueRefresh()
  end
  local function auraInfoChanged()
    if frame.RefreshSpellCooldownInfo then
      queueRefresh()
    else
      restart()
    end
  end

  for _, method in ipairs({ "OnCooldownIDSet", "OnCooldownIDCleared", "ResetCooldownData" }) do
    hookMethod(frame, method, restart)
  end
  for _, method in ipairs({ "ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet" }) do
    hookMethod(frame, method, auraInfoChanged)
  end
  for _, method in ipairs({ "RefreshData", "RefreshCooldownOnly" }) do
    hookMethod(frame, method, relay)
  end
  for _, method in ipairs({ "SetAuraInstanceInfo", "OnUnitAuraRemovedEvent", "OnUnitAuraUpdatedEvent", "OnNewTarget", "OnActiveStateChanged", "RefreshIconColor" }) do
    hookMethod(frame, method, queueRefresh)
  end
  if frame.HookScript then
    frame:HookScript("OnShow", queueRefresh)
    frame:HookScript("OnHide", queueRefresh)
  end

  local widget = frame.Cooldown or frame.cooldown
  if not widget then return end
  hookMethod(widget, "SetCooldownFromDurationObject", function(_, object)
    restartTimer(frame, record, object, nil)
  end)
  hookMethod(widget, "SetCooldown", function(_, start, duration, modRate)
    restartTimer(frame, record, nil, { start = start, duration = duration, modRate = modRate })
  end)
  hookMethod(widget, "Clear", restart)
  hookMethod(widget, "Pause", function()
    record.paused = true
    queueRefresh()
  end)
  hookMethod(widget, "Resume", function()
    record.paused = false
    queueRefresh()
  end)
  if widget.HookScript then
    widget:HookScript("OnCooldownDone", function()
      rereadFrame(frame, record)
      if readable(frame.cooldownUseAuraDisplayTime) == false and record.onGCD == false and timerExpired(record) then
        record.completedRevision = record.revision
        record.onCooldown = false
        record.recharging = false
      end
      queueRefresh()
    end)
  end
  seedFromWidget(frame, record, widget)
  rereadFrame(frame, record)
end

local function observeViewer(viewer, name)
  if watchedViewers[viewer] then return end
  watchedViewers[viewer] = true
  if not hooksecurefunc then return end
  for _, method in ipairs({ "OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange" }) do
    hookMethod(viewer, method, queueRefresh)
  end
  if buffViewerNames[name] then
    hookMethod(viewer, "RefreshData", queueRefresh)
    hookMethod(viewer, "OnAcquireItemFrame", function(_, itemFrame)
      if itemFrame then observeFrame(itemFrame) end
    end)
  end
end

function Private.CDMFrames()
  local batch = Private.cdmScanBatch
  if batch and batch.frames then return batch.frames end
  local frames = {}
  for _, name in ipairs(viewerNames) do
    local viewer = _G[name]
    if viewer then
      observeViewer(viewer, name)
      local pool = viewer.itemFramePool
      if pool and pool.EnumerateActive then
        for frame in pool:EnumerateActive() do
          local cooldownID = readNumber(frame.cooldownID)
          if cooldownID then
            observeFrame(frame)
            frames[cooldownID] = frame
          end
        end
      end
    end
  end
  if batch then batch.frames = frames end
  return frames
end

function Private.CDMGetNativeCooldown(frame, spellID)
  if not frame then return nil end
  local record = nativeRecords[frame]
  if not record or not record.read then return nil end
  if record.cooldownID ~= readable(frame.cooldownID) then return nil end
  local wanted = readable(spellID)
  if record.spellID ~= wanted then return nil end
  if frame.GetSpellID then
    local current = readable(frame:GetSpellID())
    if current ~= wanted then return nil end
  end
  local inRange
  local outOfRange = readBoolean(frame.spellOutOfRange)
  if outOfRange ~= nil then inRange = not outOfRange end
  return {
    duration = record.duration or convertRaw(record),
    revision = record.revision,
    onGCD = record.onGCD,
    onCooldown = record.onCooldown,
    recharging = record.recharging,
    charges = record.charges,
    inRange = inRange,
    paused = record.paused == true,
  }
end

local function dataProviderLayout()
  local provider
  if CooldownViewerSettings and CooldownViewerSettings.GetDataProvider then
    provider = CooldownViewerSettings:GetDataProvider()
  end
  provider = provider or CooldownViewerDataProvider
  if provider and provider.GetDisplayData and not (provider.IsDirty and provider:IsDirty()) then
    local display = provider:GetDisplayData()
    return display and display.cooldownInfoByID
  end
  return nil
end

function Private.CDMCatalog()
  local catalog = {}
  local layout = dataProviderLayout()
  local frames = Private.CDMFrames()
  local categories = Enum.CooldownViewerCategory
  for _, source in pairs(categories) do
    if type(source) == "number" and source >= 0 then
      local setOk, identifiers = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, source, true)
      if not setOk or type(identifiers) ~= "table" then identifiers = {} end
      for _, rawID in ipairs(identifiers) do
        local cooldownID = readNumber(rawID)
        local infoOk, info = false, nil
        if cooldownID then infoOk, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID) end
        info = infoOk and info or nil
        if info then
          local placement
          local displayed
          local placed = layout and layout[cooldownID]
          local layoutCategory = placed and readNumber(placed.category)
          if layoutCategory then
            placement = layoutCategory
            displayed = placement == categories.Essential or placement == categories.Utility
              or placement == categories.TrackedBuff or placement == categories.TrackedBar
          elseif frames[cooldownID] then
            displayed = true
            local viewerFrame = frames[cooldownID].viewerFrame
            placement = viewerFrame and readNumber(viewerFrame.cooldownViewerCategory) or nil
          end
          local category = source
          if placement and placement >= 0 then category = placement end
          catalog[cooldownID] = {
            category = category,
            sourceCategory = source,
            displayed = displayed,
            known = readBoolean(info.isKnown) ~= false,
          }
        end
      end
    end
  end
  return catalog
end

function Private.CDMIdentity(id, entry, info, frame)
  local spellID, itemID, slot
  if frame and frame.GetSpellID then
    spellID = readNumber(frame:GetSpellID())
  end
  if not spellID then
    spellID = readNumber(info.linkedSpellID) or readNumber(info.overrideTooltipSpellID) or readNumber(info.overrideSpellID)
  end
  if not spellID and Private.CDMIsBuff(entry.category) and type(info.linkedSpellIDs) == "table" then
    for _, linked in ipairs(info.linkedSpellIDs) do
      local candidate = readNumber(linked)
      if candidate and candidate > 0 then
        spellID = candidate
        break
      end
    end
  end
  if not spellID then
    spellID = readNumber(info.spellID)
  end

  slot = readNumber(info.equipSlot)
  if slot then
    itemID = readNumber(GetInventoryItemID("player", slot))
  end
  if itemID == nil and frame and frame.cooldownInfo then
    itemID = readNumber(frame.cooldownInfo.lastItemIDForCategory)
  end

  if not spellID then
    local spellCategory = readNumber(info.spellCategoryID)
    if spellCategory and C_Spell and C_Spell.GetLastCategoryCooldownSource then
      local categorySpell, categoryItem = C_Spell.GetLastCategoryCooldownSource(spellCategory)
      spellID = readNumber(categorySpell)
      if itemID == nil then itemID = readNumber(categoryItem) end
    end
  end

  local name, icon
  if spellID and spellID > 0 then
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then
      name = spellInfo.name
      icon = spellInfo.iconID
    end
  end
  if itemID and C_Item then
    Private.CDMRequestItemData(itemID)
    name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
    icon = C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID) or icon
  end

  local previous = identityMemory[id]
  if previous and (slot or (itemID and itemID ~= previous.itemID)) then
    previous = nil
  end
  previous = previous or {}
  local identity = {
    spellID = spellID or previous.spellID,
    itemID = itemID or previous.itemID,
    slot = slot,
    name = name or previous.name or (slot and ("Equipment slot " .. slot)) or ("CDM entry " .. tostring(id)),
    icon = icon or previous.icon or 134400,
  }
  identityMemory[id] = {
    spellID = identity.spellID,
    itemID = identity.itemID,
    slot = identity.slot,
    name = identity.name,
    icon = identity.icon,
  }
  return identity
end

function Private.CDMApplyItem(state, identity)
  local start, duration, enabled
  if identity.slot then
    if GetInventoryItemCooldown then
      start, duration, enabled = GetInventoryItemCooldown("player", identity.slot)
    end
  elseif identity.itemID and C_Item and C_Item.GetItemCooldown then
    start, duration, enabled = C_Item.GetItemCooldown(identity.itemID)
  end
  start = readNumber(start)
  duration = readNumber(duration)
  if not start or not duration then return end
  local expirationTime = start + duration
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = expirationTime
  state.modRate = 1
  state.value = nil
  state.total = nil
  state.onCooldown = duration > 0 and expirationTime > GetTime()
  state.isReady = not state.onCooldown
  if readNumber(enabled) == 0 then
    state.isReady = false
  end
end

local function spellLabel(spellID)
  local name, _, icon = Private.ExecEnv.GetSpellInfo(spellID)
  name = readString(name)
  if not name then return nil end
  if icon then
    return "|T" .. icon .. ":16|t " .. name
  end
  return name
end

local function forEachOptionEntry(categoryNames, visit)
  local viewerApi = C_CooldownViewer
  local categories = Enum and Enum.CooldownViewerCategory
  if not viewerApi or not viewerApi.GetCooldownViewerCategorySet or not categories then return end
  for _, categoryName in ipairs(categoryNames) do
    local category = categories[categoryName]
    if category ~= nil then
      local ok, identifiers = pcall(viewerApi.GetCooldownViewerCategorySet, category)
      if ok and type(identifiers) == "table" then
        for _, rawID in ipairs(identifiers) do
          local cooldownID = readNumber(rawID)
          if cooldownID then
            local infoOk, info = pcall(viewerApi.GetCooldownViewerCooldownInfo, cooldownID)
            if infoOk and info then
              visit(cooldownID, info)
            end
          end
        end
      end
    end
  end
end

function Private.GetCooldownManagerSpells()
  local spells = {}
  forEachOptionEntry({ "Essential", "Utility" }, function(_, info)
    local spellID = readNumber(info.spellID)
    if spellID and spells[spellID] == nil then
      spells[spellID] = spellLabel(spellID)
    end
  end)
  return spells
end

function Private.GetCooldownManagerAuras()
  local auras = {}
  forEachOptionEntry({ "TrackedBuff", "TrackedBar" }, function(cooldownID, info)
    local spellID = readNumber(info.spellID)
    if spellID then
      auras[cooldownID] = spellLabel(spellID)
    end
  end)
  return auras
end

function Private.GetCooldownManagerAuraSpellIDs(cooldownID)
  local list = {}
  local viewerApi = C_CooldownViewer
  if not viewerApi or not viewerApi.GetCooldownViewerCooldownInfo then return list end
  local ok, info = pcall(viewerApi.GetCooldownViewerCooldownInfo, cooldownID)
  if not ok or not info then return list end
  if type(info.linkedSpellIDs) == "table" then
    for _, spellID in ipairs(info.linkedSpellIDs) do
      list[#list + 1] = spellID
    end
  end
  local tooltipSpell = readNumber(info.overrideTooltipSpellID)
  if tooltipSpell then list[#list + 1] = tooltipSpell end
  local baseSpell = readNumber(info.spellID)
  if baseSpell then list[#list + 1] = baseSpell end
  return list
end

local function playerAuraLookupAvailable()
  return C_UnitAuras ~= nil and C_UnitAuras.GetPlayerAuraBySpellID ~= nil and not WeakAuras.IsRestricted()
end

local function setObjectTiming(state, object)
  state.progressType = "durationObject"
  state.durationObject = object
  state.value = nil
  state.total = nil
end

local function setTimedTiming(state, duration, expirationTime, modRate)
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = expirationTime
  state.modRate = modRate
  state.value = nil
  state.total = nil
end

local function applyAuraData(state, aura)
  state.stacks = readNumber(aura.applications)
  if not state.durationObject then
    local object = newDuration()
    if object and pcall(object.SetTimeFromEnd, object, aura.expirationTime, aura.duration, aura.timeMod) then
      setObjectTiming(state, object)
    end
  end
  local duration = readNumber(aura.duration)
  local expirationTime = readNumber(aura.expirationTime)
  if duration and expirationTime then
    if not state.durationObject then
      setTimedTiming(state, duration, expirationTime, readNumber(aura.timeMod) or 1)
    end
    state.auraActive = duration == 0 or expirationTime > GetTime()
  end
end

local function findStackSource(frame)
  local applications = frame.Applications
  local icon = frame.Icon
  if applications then
    local candidate = applications.Applications or applications
    if candidate.GetText then return candidate end
  end
  if icon and icon.Applications and icon.Applications.GetText then
    return icon.Applications
  end
  return nil
end

local function findCountdownSource(frame)
  local widget = frame.Cooldown or frame.cooldown
  local source
  if widget and widget.GetCountdownFontString then
    source = widget:GetCountdownFontString()
  end
  if not source and frame.Bar then
    source = frame.Bar.Duration
  end
  return source
end

local function expandRanks(list)
  local seen = {}
  local expanded = {}
  for _, spellID in ipairs(list) do
    local family = Private.GetAuraSpellRanks(spellID) or { spellID }
    for _, member in ipairs(family) do
      if not seen[member] then
        seen[member] = true
        expanded[#expanded + 1] = member
      end
    end
  end
  return expanded
end

local function restoreMemory(state, memory)
  state.progressType = memory.progressType
  state.durationObject = memory.durationObject
  state.duration = memory.duration
  state.expirationTime = memory.expirationTime
  state.modRate = memory.modRate
  state.value = nil
  state.total = nil
end

local function remainingOf(object)
  if not object or not object.GetRemainingDuration then return nil end
  local ok, remaining = pcall(object.GetRemainingDuration, object)
  return ok and readNumber(remaining) or nil
end

local function totalOf(object)
  if not object or not object.GetTotalDuration then return nil end
  local ok, total = pcall(object.GetTotalDuration, object)
  return ok and readNumber(total) or nil
end

local function rememberTimer(state, frame, cooldownID, previous)
  if previous and previous.cooldownID ~= cooldownID then previous = nil end
  local auraData = type(frame.auraDataCached) == "table" and frame.auraDataCached or nil
  local trackedSpell = readNumber(frame.auraSpellID) or (auraData and readNumber(auraData.spellId)) or (previous and previous.spellID)
  local duration = readNumber(state.duration)
  local expirationTime = readNumber(state.expirationTime)
  local expiresAt
  if duration and expirationTime and duration > 0 then
    expiresAt = expirationTime
  else
    local remaining = remainingOf(state.durationObject)
    if remaining and remaining > 0 then expiresAt = GetTime() + remaining end
  end
  timerMemories[frame] = {
    cooldownID = cooldownID,
    progressType = state.progressType,
    durationObject = state.durationObject,
    duration = state.duration,
    expirationTime = state.expirationTime,
    modRate = state.modRate,
    spellID = trackedSpell,
    expiresAt = expiresAt,
    totalDuration = duration or totalOf(state.durationObject) or (previous and previous.totalDuration),
  }
end

local function keepTimerAcrossSecrets(state, frame)
  local memory = timerMemories[frame]
  local cooldownID = readable(frame.cooldownID)
  if state.auraActive == false or state.cdmAuraUnit == "target" then
    timerMemories[frame] = nil
  elseif state.progressType == "static" then
    if memory then
      if memory.cooldownID ~= cooldownID or (memory.expiresAt and memory.expiresAt <= GetTime()) then
        timerMemories[frame] = nil
      else
        restoreMemory(state, memory)
      end
    end
  else
    rememberTimer(state, frame, cooldownID, memory)
  end
end

local function resetInactive(state)
  state.progressType = "static"
  state.value = 1
  state.total = 1
  state.durationObject = nil
  state.duration = nil
  state.expirationTime = nil
  state.modRate = nil
  state.cdmCountdownSource = nil
  state.cdmStackSource = nil
  state.cdmTextRecord = nil
  state.stacks = nil
  state.cdmDispelName = nil
  state.debuffClass = nil
end

local function chooseFilter(aura, unit)
  local filter = "HELPFUL"
  local harmful = aura and readBoolean(aura.isHarmful)
  if harmful ~= nil then
    filter = harmful and "HARMFUL" or "HELPFUL"
  elseif unit == "target" then
    filter = readBoolean(UnitIsFriend("player", "target")) == true and "HELPFUL" or "HARMFUL"
  end
  if unit == "target" then
    filter = filter == "HELPFUL" and "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY" or "HARMFUL|PLAYER"
  end
  return filter
end

function Private.CDMApplyAura(state, identity, info, frame, exactID, buffSpellIDs)
  state.cdmAuraUnit = "player"
  state.cdmAuraFilter = "HELPFUL"
  state.cdmAuraTotem = false

  local aura = frame and frame.auraDataCached
  if type(aura) ~= "table" then aura = nil end
  local unit = frame and readString(frame.auraDataUnit) or nil
  if unit == "player" or unit == "target" then
    state.cdmAuraUnit = unit
  end
  state.cdmAuraFilter = chooseFilter(aura, state.cdmAuraUnit)

  local instanceID = frame and frame.auraInstanceID
  local instanceSecret = isSecret(instanceID)
  local nativeSpell
  local matches
  if exactID == nil then
    matches = frame ~= nil
  elseif not frame then
    matches = false
  else
    nativeSpell = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId)) or nil
    if not nativeSpell and unit == "player" and playerAuraLookupAvailable() then
      local ok, found = pcall(C_UnitAuras.GetPlayerAuraBySpellID, exactID)
      if ok then
        if type(found) == "table" and readBoolean(found.isFromPlayerOrPlayerPet) == true then
          aura = found
          nativeSpell = exactID
        else
          nativeSpells[frame] = nil
        end
      end
    end
    if nativeSpell then
      nativeSpells[frame] = nativeSpell
    elseif aura and WeakAuras.IsRestricted() then
      nativeSpell = nativeSpells[frame]
    end
    matches = nativeSpell ~= nil and nativeSpell == exactID
  end

  if matches and frame and not instanceSecret then
    if instanceID ~= nil then
      state.auraActive = true
    elseif aura == nil then
      state.auraActive = false
    end
  end
  if exactID ~= nil and aura and not matches then
    aura = nil
  end
  local nativeAbsent = frame ~= nil and not instanceSecret and instanceID == nil and frame.auraDataCached == nil
  if nativeAbsent then
    state.auraActive = false
  end
  if aura then
    state.auraActive = true
  end
  local usable = frame ~= nil and matches and not nativeAbsent
  local record = frame and nativeRecords[frame]

  state.cdmAuraRenderUnit = nil
  state.cdmAuraRenderSpellIDs = nil
  if usable and (unit == "player" or unit == "target") then
    state.cdmAuraRenderUnit = unit
    local renderSpell = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId)) or nil
    local list = renderSpell and { renderSpell } or buffSpellIDs
    if exactID == nil and Private.GetAuraSpellRanks and type(list) == "table" then
      list = expandRanks(list)
    end
    state.cdmAuraRenderSpellIDs = list
  end

  local totem = (not aura and frame) and frame.totemData or nil
  if totem then
    state.cdmAuraTotem = true
    state.auraActive = nil
    local duration = readNumber(totem.duration)
    local expirationTime = readNumber(totem.expirationTime)
    if duration and expirationTime then
      setTimedTiming(state, duration, expirationTime, readNumber(totem.modRate) or 1)
      state.auraActive = expirationTime > GetTime()
    end
  else
    if usable then
      state.cdmCountdownSource = findCountdownSource(frame)
      local stackSource = findStackSource(frame)
      if stackSource then state.cdmStackSource = stackSource end
      state.cdmTextRecord = record
      if (instanceSecret or type(instanceID) == "number") and (unit == "player" or unit == "target")
        and C_UnitAuras and C_UnitAuras.GetAuraDuration then
        local ok, object = pcall(C_UnitAuras.GetAuraDuration, unit, instanceID)
        if ok and Private.IsDurationObject(object) then
          setObjectTiming(state, object)
        end
      end
      if record then
        if not state.durationObject then
          local object = record.duration or convertRaw(record)
          if object then
            setObjectTiming(state, object)
          elseif record.raw then
            local start = readNumber(record.raw.start)
            local duration = readNumber(record.raw.duration)
            if start and duration then
              setTimedTiming(state, duration, start + duration, readNumber(record.raw.modRate) or 1)
            end
          end
        end
        state.cdmNativePaused = record.paused == true
      end
    end
    if aura then
      applyAuraData(state, aura)
    end
    local renderList = state.cdmAuraRenderSpellIDs
    if usable and unit == "player" and not state.durationObject and not state.duration
      and playerAuraLookupAvailable() and renderList then
      for _, spellID in ipairs(renderList) do
        local ok, found = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
        if ok and type(found) == "table" and readBoolean(found.isFromPlayerOrPlayerPet) == true then
          applyAuraData(state, found)
          break
        end
      end
    end
  end

  local dispelName = aura and readString(aura.dispelName)
  if dispelName then
    state.cdmDispelName = dispelName
    state.debuffClass = dispelName == "" and "enrage" or dispelName:lower()
  end

  if frame and state.auraActive ~= false then
    local isActive = frame.isActive
    if isSecret(isActive) then
      state.auraActive = nil
    elseif type(isActive) == "boolean" then
      state.auraActive = isActive
      if isActive and exactID ~= nil then
        local auraData = type(frame.auraDataCached) == "table" and frame.auraDataCached or nil
        local compared = nativeSpell or readNumber(frame.auraSpellID) or (auraData and readNumber(auraData.spellId)) or nil
        if compared then
          state.auraActive = compared == exactID
        else
          state.auraActive = nil
        end
      end
    end
  end

  if frame then
    keepTimerAcrossSecrets(state, frame)
  end

  if state.auraActive == false then
    resetInactive(state)
  end
end

local function relaunchAfterCast(castSpellID)
  local ranks = Private.GetAuraSpellRanks and Private.GetAuraSpellRanks(castSpellID) or { castSpellID }
  local family = {}
  for _, member in ipairs(ranks) do family[member] = true end
  for frame, remembered in pairs(nativeSpells) do
    if family[remembered] and remembered ~= castSpellID then
      nativeSpells[frame] = castSpellID
    end
  end
  local relaunched = false
  for _, memory in pairs(timerMemories) do
    local total = memory.totalDuration
    if memory.spellID and family[memory.spellID] and total and total > 0 then
      local expiresAt = GetTime() + total * (memory.modRate or 1)
      local done = false
      if memory.progressType == "durationObject" then
        local object = newDuration()
        if object and pcall(object.SetTimeFromEnd, object, expiresAt, total, memory.modRate) then
          memory.durationObject = object
          done = true
        end
      else
        memory.expirationTime = expiresAt
        done = true
      end
      if done then
        memory.expiresAt = expiresAt
        relaunched = true
      end
    end
  end
  if relaunched then queueRefresh() end
end

local castListener = CreateFrame("Frame")
for _, eventName in ipairs({ "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED" }) do
  castListener:RegisterUnitEvent(eventName, "player")
end
castListener:SetScript("OnEvent", function(_, event, _, first, second, third)
  if event == "UNIT_SPELLCAST_SENT" then
    if isSecret(first) or isSecret(second) or second == nil then return end
    if first == nil or first == "" then
      pendingSelfCasts[second] = true
    else
      local playerName = UnitName("player")
      if not isSecret(playerName) and first == playerName then
        pendingSelfCasts[second] = true
      end
    end
    return
  end
  if isSecret(first) or first == nil then return end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if not pendingSelfCasts[first] then return end
    pendingSelfCasts[first] = nil
    local castSpellID = readNumber(second)
    if castSpellID then relaunchAfterCast(castSpellID) end
  else
    pendingSelfCasts[first] = nil
  end
end)

function Private.ParseCDMText(value)
  if isSecret(value) or type(value) ~= "string" then return nil end
  local token = value:match("^%%{([^{}]+)}$") or value:match("^%%([%w%.]+)$")
  if not token then return nil end
  if textWords[token] then return token end
  local index, word = token:match("^(%d+)%.(%a+)$")
  if index and textWords[word] then
    return word, tonumber(index)
  end
  return nil
end

function Private.IsCDMBuffText(value, data)
  local kind, index = Private.ParseCDMText(value)
  if not kind then return false end
  if kind == "bp" or kind == "bs" then return true end
  local triggers = data and data.triggers
  if type(triggers) ~= "table" then return false end
  if not index then
    local source = type(data.progressSource) == "table" and data.progressSource[1] or nil
    if source == 0 then return false end
    if type(source) == "number" and source > 0 then
      index = source
    elseif type(triggers.activeTriggerMode) == "number" and triggers.activeTriggerMode > 0 then
      index = triggers.activeTriggerMode
    elseif #triggers == 1 then
      index = 1
    else
      return false
    end
  end
  local entry = triggers[index]
  local trigger = type(entry) == "table" and entry.trigger or nil
  return type(trigger) == "table" and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff"
end

local function countdownTextFor(state, kind)
  if kind == "caster" then return "" end
  if kind == "dispel" then
    if state.show and state.cdmDispelName then return state.cdmDispelName end
    return ""
  end
  local stack = kind == "bs" or kind == "s"
  local buff = state.cdmBuff
  if not stack and buff and state.show and not state.cdmTextPreview and Private.IsDurationObject(state.durationObject) then
    return Private.FormatDurationText(state.durationObject, false, 99, 0, 0)
  end
  local source
  if state.show then
    if stack then
      source = state.cdmStackSource
    else
      source = state.cdmCountdownSource
    end
  end
  if source and source.IsForbidden and source:IsForbidden() then
    source = nil
  end
  if source then
    if (stack or buff) and source.IsShown and readBoolean(source:IsShown()) == false then
      return ""
    end
    local text = source:GetText()
    if not stack and buff and not isSecret(text) and tonumber(text) == 0 then
      return ""
    end
    return text
  end
  if state.show and state.cdmTextPreview then
    if stack then return "3" end
    if state.expirationTime then
      return tostring(math.ceil(math.max(0, state.expirationTime - GetTime())))
    end
    return "6"
  end
  return ""
end

function Private.CopyCDMCountdownText(destination, state, kind)
  destination:SetText(countdownTextFor(state or {}, kind))
end

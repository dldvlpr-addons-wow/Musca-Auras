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

local function readTyped(value, wanted)
  if isSecret(value) or type(value) ~= wanted then return nil end
  return value
end

local function readNumber(value) return readTyped(value, "number") end
local function readBoolean(value) return readTyped(value, "boolean") end
local function readString(value) return readTyped(value, "string") end

local weakKeys = { __mode = "k" }
local frameRecords = setmetatable({}, weakKeys)
local observedViewers = setmetatable({}, weakKeys)
local rememberedAuraSpells = setmetatable({}, weakKeys)
local timerMemories = setmetatable({}, weakKeys)
local identityMemory = {}
local requestedItems = {}
local pendingCasts = {}
local refreshPending = false

local function emitRefresh()
  refreshPending = false
  if Private.ScanEvents then
    Private.ScanEvents("WA_CDM_REFRESH")
  end
end

function Private.QueueCDMRefresh()
  if refreshPending then return end
  refreshPending = true
  C_Timer.After(0, emitRefresh)
end

local function queueRefresh()
  Private.QueueCDMRefresh()
end

local function createDuration(setter, first, second, third)
  local util = C_DurationUtil
  if not util or not util.CreateDuration then return nil end
  local ok, duration = pcall(function()
    local object = util.CreateDuration()
    object[setter](object, first, second, third)
    return object
  end)
  if ok then return duration end
  return nil
end

local function durationNumber(duration, method)
  if not duration or not duration[method] then return nil end
  local ok, value = pcall(duration[method], duration)
  if not ok then return nil end
  return readNumber(value)
end

local function readFrame(frame, record)
  record.read = true
  record.cooldownID = readable(frame.cooldownID)
  record.spellID = nil
  if frame.GetSpellID then
    record.spellID = readable(frame:GetSpellID())
  end
  record.onCooldown = readBoolean(frame.isOnActualCooldown)
  record.recharging = readBoolean(frame.wasSetFromCharges)
  record.paused = readable(frame.cooldownPaused) == true
  if record.finishedRevision ~= nil and record.finishedRevision == record.revision then
    record.onCooldown = false
    record.recharging = false
  end
  record.charges = readNumber(frame.cooldownChargesCount)
  local onGCD = readBoolean(frame.isOnGCD)
  if record.onCooldown or record.recharging or readBoolean(frame.cooldownUseAuraDisplayTime) == true then
    onGCD = false
  end
  record.onGCD = onGCD
end

local function restartTimer(frame, record, duration, raw)
  record.revision = record.revision + 1
  record.duration = duration
  record.raw = raw
  record.converted = nil
  readFrame(frame, record)
  queueRefresh()
end

local function convertedDuration(record)
  if record.converted then return record.converted end
  local raw = record.raw
  if not raw then return nil end
  local duration = createDuration("SetTimeFromStart", raw.start, raw.duration, raw.modRate)
  record.converted = duration
  return duration
end

local function timerExpired(record)
  if record.paused then return false end
  local duration = record.duration or record.converted
  if duration and duration.GetRemainingDuration then
    local remaining = durationNumber(duration, "GetRemainingDuration")
    return remaining ~= nil and remaining <= 0
  end
  local raw = record.raw
  if not raw then return false end
  local start, length = readNumber(raw.start), readNumber(raw.duration)
  local modRate
  if isSecret(raw.modRate) then
    modRate = nil
  elseif raw.modRate == nil then
    modRate = 1
  else
    modRate = readNumber(raw.modRate)
  end
  if start and length and modRate and modRate > 0 then
    return GetTime() >= start + length / modRate
  end
  return false
end

local function hookMethod(target, method, handler)
  if type(target[method]) == "function" then
    hooksecurefunc(target, method, handler)
  end
end

local function hookMethods(target, methods, handler)
  for _, method in ipairs(methods) do
    hookMethod(target, method, handler)
  end
end

local function initialRaw(frame, widget)
  if widget.GetCooldownTimes then
    local ok, start, duration = pcall(widget.GetCooldownTimes, widget)
    if ok then
      start, duration = readNumber(start), readNumber(duration)
      if start and duration then
        return { start = start / 1000, duration = duration / 1000, modRate = frame.cooldownModRate }
      end
    end
  end
  if frame.RefreshSpellCooldownInfo then
    return { start = frame.cooldownStartTime, duration = frame.cooldownDuration, modRate = frame.cooldownModRate }
  end
  return nil
end

local function observeFrame(frame)
  if frameRecords[frame] or not hooksecurefunc then return end
  local record = { revision = 0 }
  frameRecords[frame] = record

  local function restart() restartTimer(frame, record) end
  local function reread()
    readFrame(frame, record)
    queueRefresh()
  end

  hookMethods(frame, { "OnCooldownIDSet", "OnCooldownIDCleared", "ResetCooldownData" }, restart)
  hookMethods(frame, { "ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet" }, function()
    if frame.RefreshSpellCooldownInfo then
      queueRefresh()
    else
      restart()
    end
  end)
  hookMethods(frame, { "RefreshData", "RefreshCooldownOnly" }, reread)
  hookMethods(frame, { "SetAuraInstanceInfo", "OnUnitAuraRemovedEvent", "OnUnitAuraUpdatedEvent", "OnNewTarget",
    "OnActiveStateChanged", "RefreshIconColor" }, queueRefresh)
  if frame.HookScript then
    frame:HookScript("OnShow", queueRefresh)
    frame:HookScript("OnHide", queueRefresh)
  end

  local widget = frame.Cooldown or frame.cooldown
  if not widget then return end

  hookMethod(widget, "SetCooldownFromDurationObject", function(_, duration)
    restartTimer(frame, record, duration)
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
      readFrame(frame, record)
      if readBoolean(frame.cooldownUseAuraDisplayTime) == false and record.onGCD == false and timerExpired(record) then
        record.finishedRevision = record.revision
        record.onCooldown = false
        record.recharging = false
      end
      queueRefresh()
    end)
  end

  record.raw = initialRaw(frame, widget)
  readFrame(frame, record)
end

local function observeViewer(viewer, isBuffViewer)
  if observedViewers[viewer] or not hooksecurefunc then return end
  observedViewers[viewer] = true
  hookMethods(viewer, { "OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange" }, queueRefresh)
  if isBuffViewer then
    hookMethod(viewer, "RefreshData", queueRefresh)
    hookMethod(viewer, "OnAcquireItemFrame", function(_, itemFrame)
      if itemFrame then observeFrame(itemFrame) end
    end)
  end
end

function Private.CDMRequestItemData(itemID)
  local items = C_Item
  if not itemID or not items or not items.IsItemDataCachedByID or not items.RequestLoadItemDataByID then return end
  if requestedItems[itemID] or items.IsItemDataCachedByID(itemID) then return end
  requestedItems[itemID] = true
  items.RequestLoadItemDataByID(itemID)
end

function Private.CDMResetIdentities()
  local batch = Private.cdmScanBatch
  if batch then
    if batch.identitiesReset then return end
    batch.identitiesReset = true
  end
  identityMemory = {}
end

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
local displayedCategoryNames = { "Essential", "Utility", "TrackedBuff", "TrackedBar" }

local function categoryEnum()
  return Enum and Enum.CooldownViewerCategory
end

local function categoryIn(category, names)
  local categories = categoryEnum()
  if not categories or category == nil or isSecret(category) then return false end
  for _, name in ipairs(names) do
    local value = categories[name]
    if value ~= nil and value == category then return true end
  end
  return false
end

function Private.CDMCategoryName(category)
  local categories = categoryEnum()
  if categories and category ~= nil and not isSecret(category) then
    for name, value in pairs(categories) do
      if value == category then
        return categoryLabels[name] or name
      end
    end
  end
  return "Other"
end

function Private.CDMIsBuff(category)
  return categoryIn(category, buffCategoryNames)
end

local viewerNames = { "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer" }
local buffViewerNames = { BuffIconCooldownViewer = true, BuffBarCooldownViewer = true }

function Private.CDMFrames()
  local batch = Private.cdmScanBatch
  if batch and batch.frames then return batch.frames end
  local frames = {}
  for _, viewerName in ipairs(viewerNames) do
    local viewer = _G[viewerName]
    if viewer then
      observeViewer(viewer, buffViewerNames[viewerName])
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
  local record = frameRecords[frame]
  if not record or not record.read then return nil end
  if record.cooldownID ~= readable(frame.cooldownID) then return nil end
  local wanted = readable(spellID)
  if record.spellID ~= wanted then return nil end
  if frame.GetSpellID and readable(frame:GetSpellID()) ~= wanted then return nil end
  local inRange
  local outOfRange = readBoolean(frame.spellOutOfRange)
  if outOfRange ~= nil then inRange = not outOfRange end
  return {
    duration = record.duration or convertedDuration(record),
    revision = record.revision,
    onGCD = record.onGCD,
    onCooldown = record.onCooldown,
    recharging = record.recharging,
    charges = record.charges,
    inRange = inRange,
    paused = record.paused == true,
  }
end

local function layoutByID()
  local provider
  if CooldownViewerSettings and CooldownViewerSettings.GetDataProvider then
    provider = CooldownViewerSettings:GetDataProvider()
  end
  provider = provider or CooldownViewerDataProvider
  if not provider or not provider.GetDisplayData then return nil end
  if provider.IsDirty and provider:IsDirty() then return nil end
  local displayData = provider:GetDisplayData()
  return displayData and displayData.cooldownInfoByID
end

local function placementOf(cooldownID, layout, frames)
  local laidOut = layout and layout[cooldownID]
  local laidCategory = laidOut and readNumber(laidOut.category)
  if laidCategory then
    return laidCategory, categoryIn(laidCategory, displayedCategoryNames)
  end
  local frame = frames[cooldownID]
  if frame then
    local viewerFrame = frame.viewerFrame
    return viewerFrame and readNumber(viewerFrame.cooldownViewerCategory), true
  end
  return nil, nil
end

function Private.CDMCatalog()
  local catalog = {}
  local categories = categoryEnum()
  local api = C_CooldownViewer
  if not categories or not api then return catalog end
  local layout = layoutByID()
  local frames = Private.CDMFrames()
  for _, source in pairs(categories) do
    if type(source) == "number" and source >= 0 then
      local ok, ids = pcall(api.GetCooldownViewerCategorySet, source, true)
      if ok and type(ids) == "table" then
        for _, rawID in ipairs(ids) do
          local cooldownID = readNumber(rawID)
          if cooldownID then
            local infoOk, info = pcall(api.GetCooldownViewerCooldownInfo, cooldownID)
            if infoOk and info then
              local placement, displayed = placementOf(cooldownID, layout, frames)
              local category = source
              if placement ~= nil and placement >= 0 then category = placement end
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
    end
  end
  return catalog
end

local function firstNumber(...)
  for index = 1, select("#", ...) do
    local value = readNumber((select(index, ...)))
    if value then return value end
  end
  return nil
end

local function identitySpell(entry, info, frame)
  local spellID
  if frame and frame.GetSpellID then
    spellID = readNumber(frame:GetSpellID())
  end
  spellID = spellID or firstNumber(info.linkedSpellID, info.overrideTooltipSpellID, info.overrideSpellID)
  if not spellID and Private.CDMIsBuff(entry and entry.category) and type(info.linkedSpellIDs) == "table" then
    for _, linked in ipairs(info.linkedSpellIDs) do
      local value = readNumber(linked)
      if value and value > 0 then
        spellID = value
        break
      end
    end
  end
  return spellID or readNumber(info.spellID)
end

function Private.CDMIdentity(id, entry, info, frame)
  local spellID = identitySpell(entry, info, frame)
  local slot = readNumber(info.equipSlot)
  local itemID
  if slot and GetInventoryItemID then
    itemID = readNumber(GetInventoryItemID("player", slot))
  end
  if not itemID and frame and frame.cooldownInfo then
    itemID = readNumber(frame.cooldownInfo.lastItemIDForCategory)
  end
  if not spellID then
    local spellCategory = readNumber(info.spellCategoryID)
    if spellCategory and C_Spell and C_Spell.GetLastCategoryCooldownSource then
      local categorySpell, categoryItem = C_Spell.GetLastCategoryCooldownSource(spellCategory)
      spellID = readNumber(categorySpell)
      itemID = itemID or readNumber(categoryItem)
    end
  end

  local name, icon
  if spellID and spellID > 0 and C_Spell and C_Spell.GetSpellInfo then
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if type(spellInfo) == "table" then
      name, icon = spellInfo.name, spellInfo.iconID
    end
  end
  if itemID and C_Item then
    Private.CDMRequestItemData(itemID)
    name = (C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)) or ("Item " .. itemID)
    icon = (C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID)) or icon
  end

  local previous = id ~= nil and identityMemory[id] or nil
  if slot or (previous and itemID and itemID ~= previous.itemID) then
    previous = nil
  end
  previous = previous or {}
  local identity = {
    spellID = spellID or previous.spellID,
    itemID = itemID or previous.itemID,
    slot = slot,
    name = name or previous.name or (slot and "Equipment slot " .. slot) or "CDM entry " .. tostring(id),
    icon = icon or previous.icon or 134400,
  }
  if id ~= nil then
    identityMemory[id] = {
      spellID = identity.spellID,
      itemID = identity.itemID,
      slot = identity.slot,
      name = identity.name,
      icon = identity.icon,
    }
  end
  return identity
end

function Private.CDMApplyItem(state, identity)
  local start, duration, enabled
  if identity.slot then
    if not GetInventoryItemCooldown then return end
    start, duration, enabled = GetInventoryItemCooldown("player", identity.slot)
  elseif identity.itemID and C_Item and C_Item.GetItemCooldown then
    start, duration, enabled = C_Item.GetItemCooldown(identity.itemID)
  else
    return
  end
  start, duration = readNumber(start), readNumber(duration)
  if not start or not duration then return end
  local expirationTime = start + duration
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = expirationTime
  state.modRate = 1
  state.value = nil
  state.total = nil
  local onCooldown = duration > 0 and expirationTime > GetTime()
  state.onCooldown = onCooldown
  state.isReady = not onCooldown
  if readNumber(enabled) == 0 then
    state.isReady = false
  end
end

local function setDurationObject(state, duration)
  state.progressType = "durationObject"
  state.durationObject = duration
  state.value = nil
  state.total = nil
end

local function setTimed(state, duration, expirationTime, modRate)
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = expirationTime
  state.modRate = modRate
  state.value = nil
  state.total = nil
end

local function playerAuraLookupAvailable()
  return C_UnitAuras ~= nil and C_UnitAuras.GetPlayerAuraBySpellID ~= nil and not WeakAuras.IsRestricted()
end

local function ownPlayerAura(spellID)
  local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
  if not ok then return false end
  if type(aura) == "table" and readBoolean(aura.isFromPlayerOrPlayerPet) == true then
    return true, aura
  end
  return true, nil
end

local function cachedAura(frame)
  local aura = frame and frame.auraDataCached
  if type(aura) == "table" then return aura end
  return nil
end

local function applyAuraData(state, aura)
  state.stacks = readNumber(aura.applications)
  if not state.durationObject then
    local duration = createDuration("SetTimeFromEnd", aura.expirationTime, aura.duration, aura.timeMod)
    if duration then setDurationObject(state, duration) end
  end
  local duration, expirationTime = readNumber(aura.duration), readNumber(aura.expirationTime)
  if duration and expirationTime then
    if not state.durationObject then
      setTimed(state, duration, expirationTime, readNumber(aura.timeMod) or 1)
    end
    state.auraActive = duration == 0 or expirationTime > GetTime()
  end
end

local function withSpellRanks(spellIDs)
  local expanded, seen = {}, {}
  for _, spellID in ipairs(spellIDs) do
    for _, member in ipairs(Private.GetAuraSpellRanks(spellID) or { spellID }) do
      if not seen[member] then
        seen[member] = true
        expanded[#expanded + 1] = member
      end
    end
  end
  return expanded
end

local function countdownSourceOf(frame)
  local widget = frame.Cooldown or frame.cooldown
  if widget and widget.GetCountdownFontString then
    local fontString = widget:GetCountdownFontString()
    if fontString then return fontString end
  end
  if frame.Bar then return frame.Bar.Duration end
  return nil
end

local function stackSourceOf(frame)
  local applications = frame.Applications
  if applications then
    local candidate = applications.Applications or applications
    if candidate.GetText then return candidate end
  end
  local icon = frame.Icon
  if icon and icon.Applications and icon.Applications.GetText then
    return icon.Applications
  end
  return nil
end

local function resolveAuraFilter(state, aura)
  local filter = "HELPFUL"
  local harmful = aura and readBoolean(aura.isHarmful)
  if harmful ~= nil then
    filter = harmful and "HARMFUL" or "HELPFUL"
  elseif state.cdmAuraUnit == "target" then
    local friendly = UnitIsFriend and readBoolean(UnitIsFriend("player", "target"))
    filter = friendly == true and "HELPFUL" or "HARMFUL"
  end
  if state.cdmAuraUnit == "target" then
    filter = filter == "HELPFUL" and "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY" or "HARMFUL|PLAYER"
  end
  state.cdmAuraFilter = filter
end

local function matchExactSpell(frame, aura, unit, exactID)
  local nativeSpell = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId))
  if not nativeSpell and unit == "player" and playerAuraLookupAvailable() then
    local ok, found = ownPlayerAura(exactID)
    if ok then
      if found then
        aura = found
        nativeSpell = exactID
      else
        rememberedAuraSpells[frame] = nil
      end
    end
  end
  if nativeSpell then
    rememberedAuraSpells[frame] = nativeSpell
  elseif aura and WeakAuras.IsRestricted() then
    nativeSpell = rememberedAuraSpells[frame]
  end
  return nativeSpell, aura
end

local function applyNativeTiming(state, frame, unit, instanceID, instanceSecret, record)
  if (instanceSecret or type(instanceID) == "number") and (unit == "player" or unit == "target")
    and C_UnitAuras and C_UnitAuras.GetAuraDuration then
    local ok, duration = pcall(C_UnitAuras.GetAuraDuration, unit, instanceID)
    if ok and Private.IsDurationObject(duration) then
      setDurationObject(state, duration)
    end
  end
  if not record then return end
  if not state.durationObject then
    local duration = record.duration or convertedDuration(record)
    if duration then
      setDurationObject(state, duration)
    else
      local raw = record.raw
      local start = raw and readNumber(raw.start)
      local length = raw and readNumber(raw.duration)
      if start and length then
        setTimed(state, length, start + length, readNumber(raw.modRate) or 1)
      end
    end
  end
  state.cdmNativePaused = record.paused == true
end

local function applyTotem(state, totem)
  state.cdmAuraTotem = true
  state.auraActive = nil
  local duration, expirationTime = readNumber(totem.duration), readNumber(totem.expirationTime)
  if duration and expirationTime then
    setTimed(state, duration, expirationTime, readNumber(totem.modRate) or 1)
    state.auraActive = expirationTime > GetTime()
  end
end

local function applyNativeActive(state, frame, exactID, nativeSpell)
  local isActive = frame.isActive
  if isSecret(isActive) then
    state.auraActive = nil
  elseif type(isActive) == "boolean" then
    state.auraActive = isActive
    if isActive and exactID ~= nil then
      local cached = cachedAura(frame)
      local compared = nativeSpell or readNumber(frame.auraSpellID) or (cached and readNumber(cached.spellId))
      if compared then
        state.auraActive = compared == exactID
      else
        state.auraActive = nil
      end
    end
  end
end

local function rememberTimer(state, frame)
  local cooldownID = readable(frame.cooldownID)
  local memory = timerMemories[frame]
  if state.auraActive == false or state.cdmAuraUnit == "target" then
    timerMemories[frame] = nil
    return
  end
  if state.progressType == "static" then
    if not memory then return end
    if memory.cooldownID ~= cooldownID or (memory.expiresAt and memory.expiresAt <= GetTime()) then
      timerMemories[frame] = nil
      return
    end
    state.progressType = memory.progressType
    state.durationObject = memory.durationObject
    state.duration = memory.duration
    state.expirationTime = memory.expirationTime
    state.modRate = memory.modRate
    state.value = nil
    state.total = nil
    return
  end
  if memory and memory.cooldownID ~= cooldownID then memory = nil end
  local cached = cachedAura(frame)
  local spellID = readNumber(frame.auraSpellID) or (cached and readNumber(cached.spellId)) or (memory and memory.spellID)
  local duration, expirationTime = readNumber(state.duration), readNumber(state.expirationTime)
  local expiresAt
  if duration and expirationTime and duration > 0 then
    expiresAt = expirationTime
  else
    local remaining = durationNumber(state.durationObject, "GetRemainingDuration")
    if remaining and remaining > 0 then
      expiresAt = GetTime() + remaining
    end
  end
  timerMemories[frame] = {
    cooldownID = cooldownID,
    progressType = state.progressType,
    durationObject = state.durationObject,
    duration = state.duration,
    expirationTime = state.expirationTime,
    modRate = state.modRate,
    spellID = spellID,
    expiresAt = expiresAt,
    totalDuration = duration or durationNumber(state.durationObject, "GetTotalDuration") or (memory and memory.totalDuration),
  }
end

local inactiveClearedFields = { "durationObject", "duration", "expirationTime", "modRate", "cdmCountdownSource",
  "cdmStackSource", "cdmTextRecord", "stacks", "cdmDispelName", "debuffClass" }

local function resetInactive(state)
  state.progressType = "static"
  state.value = 1
  state.total = 1
  for _, field in ipairs(inactiveClearedFields) do
    state[field] = nil
  end
end

function Private.CDMApplyAura(state, identity, info, frame, exactID, buffSpellIDs)
  state.cdmAuraUnit = "player"
  state.cdmAuraFilter = "HELPFUL"
  state.cdmAuraTotem = false

  local aura = cachedAura(frame)
  local unit
  if frame then unit = readString(frame.auraDataUnit) end
  if unit == "player" or unit == "target" then
    state.cdmAuraUnit = unit
  end
  resolveAuraFilter(state, aura)

  local matches, nativeSpell
  if exactID == nil then
    matches = frame ~= nil
  elseif not frame then
    matches = false
  else
    nativeSpell, aura = matchExactSpell(frame, aura, unit, exactID)
    matches = nativeSpell ~= nil and nativeSpell == exactID
  end

  local instanceID
  if frame then instanceID = frame.auraInstanceID end
  local instanceSecret = isSecret(instanceID)
  if matches and frame and not instanceSecret then
    if instanceID ~= nil then
      state.auraActive = true
    elseif aura == nil then
      state.auraActive = false
    end
  end
  if exactID ~= nil and aura and not matches then aura = nil end
  local nativeAbsent = frame ~= nil and not instanceSecret and instanceID == nil and frame.auraDataCached == nil
  if nativeAbsent then state.auraActive = false end
  if aura then state.auraActive = true end
  local usable = frame ~= nil and matches and not nativeAbsent
  local record = frame and frameRecords[frame]
  local renderUnit = unit == "player" or unit == "target"

  state.cdmAuraRenderUnit = nil
  state.cdmAuraRenderSpellIDs = nil
  if usable and renderUnit then
    state.cdmAuraRenderUnit = unit
    local renderSpell = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId))
    local spellIDs = buffSpellIDs
    if renderSpell then spellIDs = { renderSpell } end
    if exactID == nil and Private.GetAuraSpellRanks and type(spellIDs) == "table" then
      spellIDs = withSpellRanks(spellIDs)
    end
    state.cdmAuraRenderSpellIDs = spellIDs
  end

  local totem = not aura and frame and frame.totemData or nil
  if totem then
    applyTotem(state, totem)
  else
    if usable then
      state.cdmCountdownSource = countdownSourceOf(frame)
      local stackSource = stackSourceOf(frame)
      if stackSource then state.cdmStackSource = stackSource end
      state.cdmTextRecord = record
      applyNativeTiming(state, frame, unit, instanceID, instanceSecret, record)
    end
    if aura then applyAuraData(state, aura) end
    if usable and unit == "player" and not state.durationObject and not state.duration
      and playerAuraLookupAvailable() and state.cdmAuraRenderSpellIDs then
      for _, spellID in ipairs(state.cdmAuraRenderSpellIDs) do
        local ok, found = ownPlayerAura(spellID)
        if ok and found then
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
    applyNativeActive(state, frame, exactID, nativeSpell)
  end
  if frame then rememberTimer(state, frame) end
  if state.auraActive == false then resetInactive(state) end
end

local function relaunchAfterCast(castSpellID)
  local family = Private.GetAuraSpellRanks and Private.GetAuraSpellRanks(castSpellID) or { castSpellID }
  local inFamily = {}
  for _, spellID in ipairs(family) do inFamily[spellID] = true end

  for frame, spellID in pairs(rememberedAuraSpells) do
    if inFamily[spellID] and spellID ~= castSpellID then
      rememberedAuraSpells[frame] = castSpellID
    end
  end

  local relaunched = false
  for _, memory in pairs(timerMemories) do
    local total = memory.totalDuration
    if memory.spellID ~= nil and inFamily[memory.spellID] and total and total > 0 then
      local modRate = readNumber(memory.modRate) or 1
      local expiresAt = GetTime() + total * modRate
      local done = false
      if memory.progressType == "durationObject" then
        local duration = createDuration("SetTimeFromEnd", expiresAt, total, modRate)
        if duration then
          memory.durationObject = duration
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

local castWatcher = CreateFrame("Frame")
for _, event in ipairs({ "UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED",
  "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED" }) do
  castWatcher:RegisterUnitEvent(event, "player")
end
castWatcher:SetScript("OnEvent", function(_, event, _, first, second)
  if event == "UNIT_SPELLCAST_SENT" then
    if isSecret(first) or isSecret(second) or second == nil then return end
    if first == nil or first == "" then
      pendingCasts[second] = true
    else
      local playerName = readable(UnitName("player"))
      if playerName ~= nil and playerName == first then
        pendingCasts[second] = true
      end
    end
    return
  end
  if first == nil or isSecret(first) then return end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if not pendingCasts[first] then return end
    pendingCasts[first] = nil
    local spellID = readNumber(second)
    if spellID then relaunchAfterCast(spellID) end
  else
    pendingCasts[first] = nil
  end
end)

local textKinds = { bp = true, bs = true, p = true, s = true, caster = true, dispel = true }

function Private.ParseCDMText(value)
  if isSecret(value) or type(value) ~= "string" then return nil end
  local content = value:match("^%%{([^{}]*)}$") or value:match("^%%([%w%.]+)$")
  if not content then return nil end
  if textKinds[content] then return content, nil end
  local number, word = content:match("^(%d+)%.(%a+)$")
  if number and textKinds[word] then
    return word, tonumber(number)
  end
  return nil
end

local function targetedTriggerIndex(data, triggers)
  local progressSource = data.progressSource
  local source = type(progressSource) == "table" and progressSource[1] or nil
  if source == 0 then return nil end
  if type(source) == "number" and source > 0 then return source end
  local mode = triggers.activeTriggerMode
  if type(mode) == "number" and mode > 0 then return mode end
  if #triggers == 1 then return 1 end
  return nil
end

function Private.IsCDMBuffText(value, data)
  local kind, index = Private.ParseCDMText(value)
  if not kind then return false end
  if kind == "bp" or kind == "bs" then return true end
  local triggers = data and data.triggers
  if type(triggers) ~= "table" then return false end
  index = index or targetedTriggerIndex(data, triggers)
  if not index then return false end
  local entry = triggers[index]
  local trigger = type(entry) == "table" and entry.trigger or nil
  return type(trigger) == "table" and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff"
end

local function countdownText(state, kind)
  if kind == "caster" then return "" end
  if kind == "dispel" then
    if state.show and state.cdmDispelName ~= nil then return state.cdmDispelName end
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
    if source and source.IsForbidden and source:IsForbidden() then source = nil end
  end
  if source then
    if (stack or buff) and source.IsShown and readBoolean(source:IsShown()) == false then return "" end
    local text = source:GetText()
    if not stack and buff and not isSecret(text) and tonumber(text) == 0 then return "" end
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
  destination:SetText(countdownText(state or {}, kind))
end

local function forEachCategoryInfo(categoryNames, callback)
  local api = C_CooldownViewer
  local categories = categoryEnum()
  if not api or not api.GetCooldownViewerCategorySet or not categories then return end
  for _, categoryName in ipairs(categoryNames) do
    local category = categories[categoryName]
    if category ~= nil then
      local ok, ids = pcall(api.GetCooldownViewerCategorySet, category)
      if ok and type(ids) == "table" then
        for _, rawID in ipairs(ids) do
          local cooldownID = readNumber(rawID)
          if cooldownID then
            local infoOk, info = pcall(api.GetCooldownViewerCooldownInfo, cooldownID)
            if infoOk and info then callback(cooldownID, info) end
          end
        end
      end
    end
  end
end

local function spellLabel(spellID)
  local name, _, icon = Private.ExecEnv.GetSpellInfo(spellID)
  name = readString(name)
  if not name then return nil end
  icon = readable(icon)
  if icon then return "|T" .. icon .. ":16|t " .. name end
  return name
end

function Private.GetCooldownManagerSpells()
  local spells = {}
  forEachCategoryInfo({ "Essential", "Utility" }, function(_, info)
    local spellID = readNumber(info.spellID)
    if spellID and spells[spellID] == nil then
      spells[spellID] = spellLabel(spellID)
    end
  end)
  return spells
end

function Private.GetCooldownManagerAuras()
  local auras = {}
  forEachCategoryInfo({ "TrackedBuff", "TrackedBar" }, function(cooldownID, info)
    local spellID = readNumber(info.spellID)
    if spellID then
      auras[cooldownID] = spellLabel(spellID)
    end
  end)
  return auras
end

function Private.GetCooldownManagerAuraSpellIDs(cooldownID)
  local spellIDs = {}
  local api = C_CooldownViewer
  if not api or not api.GetCooldownViewerCooldownInfo then return spellIDs end
  local ok, info = pcall(api.GetCooldownViewerCooldownInfo, cooldownID)
  if not ok or not info then return spellIDs end
  if type(info.linkedSpellIDs) == "table" then
    for _, spellID in ipairs(info.linkedSpellIDs) do
      spellIDs[#spellIDs + 1] = spellID
    end
  end
  local tooltipSpell = readNumber(info.overrideTooltipSpellID)
  if tooltipSpell then spellIDs[#spellIDs + 1] = tooltipSpell end
  local baseSpell = readNumber(info.spellID)
  if baseSpell then spellIDs[#spellIDs + 1] = baseSpell end
  return spellIDs
end

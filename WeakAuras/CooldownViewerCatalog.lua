if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local identityCache = {}
local itemRequests = {}
local nativeRecords = setmetatable({}, {__mode = "k"})
local hookedViewers = setmetatable({}, {__mode = "k"})
local refreshPending = false

local VIEWER_FRAMES = {
  "EssentialCooldownViewer",
  "UtilityCooldownViewer",
  "BuffIconCooldownViewer",
  "BuffBarCooldownViewer",
}

local CATEGORY_LABELS = {
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

local BUFF_CATEGORY_KEYS = {"TrackedBuff", "TrackedBar", "GroupBuff", "SpecAgnosticTracked", "EquipSlotTracked"}

local TARGET_AURA_FILTERS = {
  HELPFUL = "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY",
  HARMFUL = "HARMFUL|PLAYER",
}

local PLAIN_TEXT_TOKENS = {bp = true, bs = true, p = true, s = true, caster = true, dispel = true}

local function isReadable(value)
  return not (issecretvalue and issecretvalue(value))
end

local function readNumber(value)
  if isReadable(value) and type(value) == "number" then return value end
end

local function readBoolean(value)
  if isReadable(value) and type(value) == "boolean" then return value end
end

local function firstNumber(...)
  for position = 1, select("#", ...) do
    local number = readNumber((select(position, ...)))
    if number then return number end
  end
end

local function isUnitToken(unit)
  return isReadable(unit) and (unit == "player" or unit == "target")
end

local function hookMethods(target, names, handler)
  for _, name in ipairs(names) do
    if type(target[name]) == "function" then hooksecurefunc(target, name, handler) end
  end
end

local function queueRefresh()
  if refreshPending then return end
  refreshPending = true
  C_Timer.After(0, function()
    refreshPending = false
    if Private.ScanEvents then Private.ScanEvents("WA_CDM_REFRESH") end
  end)
end
Private.QueueCDMRefresh = queueRefresh

function Private.CDMRequestItemData(itemID)
  local items = C_Item
  if not itemID or not (items and items.IsItemDataCachedByID and items.RequestLoadItemDataByID) then return end
  if itemRequests[itemID] or items.IsItemDataCachedByID(itemID) then return end
  itemRequests[itemID] = true
  items.RequestLoadItemDataByID(itemID)
end

function Private.CDMResetIdentities()
  local batch = Private.cdmScanBatch
  if batch then
    if batch.identitiesReset then return end
    batch.identitiesReset = true
  end
  identityCache = {}
end

function Private.CDMCategoryName(category)
  for key, value in pairs(Enum.CooldownViewerCategory) do
    if value == category then return CATEGORY_LABELS[key] or key end
  end
  return "Other"
end

function Private.CDMIsBuff(category)
  local enum = Enum.CooldownViewerCategory
  for _, key in ipairs(BUFF_CATEGORY_KEYS) do
    if category == enum[key] then return true end
  end
  return false
end

local function hasTimerExpired(rec)
  if rec.paused then return end
  local duration = rec.duration or rec.converted
  if duration and duration.GetRemainingDuration then
    local remaining = readNumber(duration:GetRemainingDuration())
    if remaining then return remaining <= 0 end
    return
  end
  local raw = rec.raw
  if not raw then return end
  local startAt, total = readNumber(raw.start), readNumber(raw.duration)
  local rate = readNumber(raw.modRate)
  if isReadable(raw.modRate) and raw.modRate == nil then rate = 1 end
  if startAt and total and rate and rate > 0 then
    return GetTime() >= startAt + total / rate
  end
end

local function captureState(frame, rec)
  rec.cooldownID = readNumber(frame.cooldownID)
  rec.spellID = frame.GetSpellID and readNumber(frame:GetSpellID())
  rec.onCooldown = readBoolean(frame.isOnActualCooldown)
  rec.recharging = readBoolean(frame.wasSetFromCharges)
  rec.paused = readBoolean(frame.cooldownPaused) == true
  if rec.completedRevision and rec.completedRevision == rec.revision then
    rec.onCooldown, rec.recharging = false, false
  end
  rec.charges = readNumber(frame.cooldownChargesCount)
  rec.onGCD = readBoolean(frame.isOnGCD)
  local busy = rec.onCooldown == true or rec.recharging == true
    or readBoolean(frame.cooldownUseAuraDisplayTime) == true
  if busy then rec.onGCD = false end
end

local function startRevision(rec, durationObject, raw)
  rec.revision = (rec.revision or 0) + 1
  rec.duration, rec.raw, rec.converted = durationObject, raw, nil
end

local function convertRawTiming(rec)
  if not (C_DurationUtil and C_DurationUtil.CreateDuration) then return end
  local candidate = C_DurationUtil.CreateDuration()
  local raw = rec.raw
  if candidate.SetTimeFromStart
      and pcall(candidate.SetTimeFromStart, candidate, raw.start, raw.duration, raw.modRate) then
    rec.converted = candidate
    return candidate
  end
end

local function observeFrame(frame)
  if nativeRecords[frame] or not hooksecurefunc then return end
  local rec = {}
  nativeRecords[frame] = rec

  local function resync()
    captureState(frame, rec)
    queueRefresh()
  end
  local function reset()
    startRevision(rec, nil, nil)
    resync()
  end
  local function onAuraInstanceChange()
    if frame.RefreshSpellCooldownInfo then queueRefresh() else reset() end
  end
  local function onCooldownDone()
    captureState(frame, rec)
    local auraTimed = frame.cooldownUseAuraDisplayTime
    if isReadable(auraTimed) and not auraTimed and rec.onGCD == false and hasTimerExpired(rec) == true then
      rec.completedRevision = rec.revision
      rec.onCooldown, rec.recharging = false, false
    end
    queueRefresh()
  end

  hookMethods(frame, {"ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet"}, onAuraInstanceChange)
  hookMethods(frame, {"OnCooldownIDSet", "OnCooldownIDCleared", "ResetCooldownData"}, reset)
  hookMethods(frame, {"SetAuraInstanceInfo", "OnUnitAuraRemovedEvent", "OnUnitAuraUpdatedEvent", "OnNewTarget",
    "OnActiveStateChanged", "RefreshIconColor"}, queueRefresh)
  hookMethods(frame, {"RefreshData", "RefreshCooldownOnly"}, resync)
  if frame.HookScript then
    frame:HookScript("OnShow", queueRefresh)
    frame:HookScript("OnHide", queueRefresh)
  end

  local cooldown = frame.Cooldown or frame.cooldown
  if not cooldown then return end
  if cooldown.HookScript then cooldown:HookScript("OnCooldownDone", onCooldownDone) end
  if cooldown.SetCooldownFromDurationObject then
    hooksecurefunc(cooldown, "SetCooldownFromDurationObject", function(_, durationObject)
      startRevision(rec, durationObject, nil)
      resync()
    end)
  end
  if cooldown.SetCooldown then
    hooksecurefunc(cooldown, "SetCooldown", function(_, startAt, duration, modRate)
      startRevision(rec, nil, {start = startAt, duration = duration, modRate = modRate})
      resync()
    end)
  end
  if cooldown.Clear then hooksecurefunc(cooldown, "Clear", reset) end
  if cooldown.Pause then
    hooksecurefunc(cooldown, "Pause", function()
      rec.paused = true
      queueRefresh()
    end)
  end
  if cooldown.Resume then
    hooksecurefunc(cooldown, "Resume", function()
      rec.paused = false
      queueRefresh()
    end)
  end
  if cooldown.GetCooldownTimes then
    local ok, startMs, durationMs = pcall(cooldown.GetCooldownTimes, cooldown)
    startMs, durationMs = readNumber(startMs), readNumber(durationMs)
    if ok and startMs and durationMs then
      rec.raw = {start = startMs / 1000, duration = durationMs / 1000, modRate = frame.cooldownModRate}
    elseif frame.RefreshSpellCooldownInfo then
      rec.raw = {start = frame.cooldownStartTime, duration = frame.cooldownDuration, modRate = frame.cooldownModRate}
    end
  end
  captureState(frame, rec)
end

function Private.CDMGetNativeCooldown(frame, spellID)
  if not frame then return end
  local rec = nativeRecords[frame]
  if not rec or rec.cooldownID ~= readNumber(frame.cooldownID) or rec.spellID ~= spellID then return end
  local liveSpellID = frame.GetSpellID and readNumber(frame:GetSpellID())
  if liveSpellID ~= spellID then return end

  local duration = rec.duration or rec.converted
  if not duration and rec.raw then duration = convertRawTiming(rec) or duration end

  local outOfRange = readBoolean(frame.spellOutOfRange)
  local inRange
  if outOfRange ~= nil then inRange = not outOfRange end
  return {
    duration = duration,
    revision = rec.revision,
    onGCD = rec.onGCD,
    onCooldown = rec.onCooldown,
    recharging = rec.recharging,
    charges = rec.charges,
    inRange = inRange,
    paused = rec.paused,
  }
end

function Private.CDMFrames()
  local batch = Private.cdmScanBatch
  if batch and batch.frames then return batch.frames end
  local byCooldownID = {}
  for _, viewerName in ipairs(VIEWER_FRAMES) do
    local viewer = _G[viewerName]
    if viewer and hooksecurefunc and not hookedViewers[viewer] then
      hookedViewers[viewer] = true
      if viewerName == "BuffIconCooldownViewer" or viewerName == "BuffBarCooldownViewer" then
        if type(viewer.OnAcquireItemFrame) == "function" then
          hooksecurefunc(viewer, "OnAcquireItemFrame", function(_, frame) observeFrame(frame) end)
        end
        if type(viewer.RefreshData) == "function" then hooksecurefunc(viewer, "RefreshData", queueRefresh) end
      end
      hookMethods(viewer, {"OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange"}, queueRefresh)
    end
    local pool = viewer and viewer.itemFramePool
    if pool and pool.EnumerateActive then
      for frame in pool:EnumerateActive() do
        local cooldownID = readNumber(frame.cooldownID)
        if cooldownID then
          observeFrame(frame)
          byCooldownID[cooldownID] = frame
        end
      end
    end
  end
  if batch then batch.frames = byCooldownID end
  return byCooldownID
end

local function collectCategories()
  local set = {}
  for _, value in pairs(Enum.CooldownViewerCategory) do
    if type(value) == "number" and value >= 0 then set[value] = true end
  end
  return set
end

local function readLayout()
  local viewerSettings = _G.CooldownViewerSettings
  local provider = viewerSettings and viewerSettings.GetDataProvider and viewerSettings:GetDataProvider()
  provider = provider or _G.CooldownViewerDataProvider
  if provider and provider.GetDisplayData and (not provider.IsDirty or not provider:IsDirty()) then
    local display = provider:GetDisplayData()
    return display and display.cooldownInfoByID
  end
end

local function isShownCategory(placement)
  local enum = Enum.CooldownViewerCategory
  return placement == enum.Essential or placement == enum.Utility
    or placement == enum.TrackedBuff or placement == enum.TrackedBar
end

function Private.CDMCatalog()
  local catalog = {}
  local layout = readLayout()
  local frames = Private.CDMFrames()
  for sourceCategory in pairs(collectCategories()) do
    for _, id in ipairs(C_CooldownViewer.GetCooldownViewerCategorySet(sourceCategory, true) or {}) do
      local info = readNumber(id) and C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
      if info then
        local arranged = layout and layout[id]
        local placement = arranged and readNumber(arranged.category)
        local displayed
        if placement ~= nil then
          displayed = isShownCategory(placement)
        elseif frames[id] then
          displayed = true
          local viewerFrame = frames[id].viewerFrame
          placement = viewerFrame and readNumber(viewerFrame.cooldownViewerCategory)
        end
        catalog[id] = {
          category = placement and placement >= 0 and placement or sourceCategory,
          sourceCategory = sourceCategory,
          displayed = displayed,
          known = isReadable(info.isKnown) and info.isKnown ~= false,
        }
      end
    end
  end
  return catalog
end

function Private.CDMIdentity(id, entry, info, frame)
  local spellID = frame and frame.GetSpellID and readNumber(frame:GetSpellID())
  spellID = spellID or firstNumber(info.linkedSpellID, info.overrideTooltipSpellID, info.overrideSpellID)
  if not spellID and Private.CDMIsBuff(entry.category) then
    for _, linked in ipairs(info.linkedSpellIDs or {}) do
      local candidate = readNumber(linked)
      if candidate and candidate > 0 then
        spellID = candidate
        break
      end
    end
  end
  spellID = spellID or readNumber(info.spellID)

  local slot = readNumber(info.equipSlot)
  local itemID = slot and readNumber(GetInventoryItemID("player", slot))
  if not itemID and frame and frame.cooldownInfo then
    itemID = readNumber(frame.cooldownInfo.lastItemIDForCategory)
  end
  local categoryID = readNumber(info.spellCategoryID)
  if not spellID and categoryID and C_Spell.GetLastCategoryCooldownSource then
    local sourceSpell, sourceItem = C_Spell.GetLastCategoryCooldownSource(categoryID)
    spellID, itemID = readNumber(sourceSpell), itemID or readNumber(sourceItem)
  end

  local spell = spellID and spellID > 0 and C_Spell.GetSpellInfo(spellID)
  local name, icon = spell and spell.name, spell and spell.iconID
  if itemID and C_Item then
    Private.CDMRequestItemData(itemID)
    name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
    icon = C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID) or icon
  end

  local previous = identityCache[id] or {}
  if slot or (itemID and itemID ~= previous.itemID) then previous = {} end
  local identity = {
    spellID = spellID or previous.spellID,
    itemID = itemID or previous.itemID,
    slot = slot,
    name = name or previous.name or (slot and ("Equipment slot " .. slot)) or ("CDM entry " .. id),
    icon = icon or previous.icon or 134400,
  }
  identityCache[id] = identity
  return identity
end

local function applyTimes(state, startAt, duration, modRate)
  startAt, duration, modRate = readNumber(startAt), readNumber(duration), readNumber(modRate)
  if not startAt or not duration then return false end
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = startAt + duration
  state.modRate = modRate or 1
  state.value, state.total = nil, nil
  return true
end

local function useDurationObject(state, durationObject)
  state.progressType, state.durationObject = "durationObject", durationObject
  state.value, state.total = nil, nil
end

function Private.CDMApplyItem(state, identity)
  local startAt, duration, enabled
  if identity.slot then
    startAt, duration, enabled = GetInventoryItemCooldown("player", identity.slot)
  elseif identity.itemID and C_Item and C_Item.GetItemCooldown then
    startAt, duration, enabled = C_Item.GetItemCooldown(identity.itemID)
  end
  if not applyTimes(state, startAt, duration) then return end
  state.onCooldown = state.duration > 0 and state.expirationTime > GetTime()
  state.isReady = not state.onCooldown
  if readNumber(enabled) == 0 then state.isReady = false end
end

local function applyAuraSource(state, unit, aura)
  state.cdmAuraFilter = "HELPFUL"
  if isUnitToken(unit) then state.cdmAuraUnit = unit end
  local harmful = aura and aura.isHarmful
  if isReadable(harmful) and type(harmful) == "boolean" then
    state.cdmAuraFilter = harmful and "HARMFUL" or "HELPFUL"
  elseif state.cdmAuraUnit == "target" then
    local friend = UnitIsFriend and UnitIsFriend("player", "target")
    state.cdmAuraFilter = isReadable(friend) and friend == true and "HELPFUL" or "HARMFUL"
  end
  if state.cdmAuraUnit == "target" then
    state.cdmAuraFilter = TARGET_AURA_FILTERS[state.cdmAuraFilter] or TARGET_AURA_FILTERS.HARMFUL
  end
end

local function markNativeInstance(state, frame, aura)
  local instance = frame.auraInstanceID
  if not isReadable(instance) then return end
  if instance ~= nil then
    state.auraActive = true
  elseif not aura then
    state.auraActive = false
  end
end

local function expandRanks(spellIDs)
  local ranks, seen = {}, {}
  for _, id in ipairs(spellIDs) do
    for _, rankID in ipairs(Private.GetAuraSpellRanks(id) or {id}) do
      if not seen[rankID] then
        seen[rankID] = true
        ranks[#ranks + 1] = rankID
      end
    end
  end
  return ranks
end

local function setRenderSource(state, frame, aura, unit, exactID, buffSpellIDs)
  local spellID = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId))
  state.cdmAuraRenderUnit = unit
  state.cdmAuraRenderSpellIDs = spellID and {spellID} or buffSpellIDs
  if not exactID and Private.GetAuraSpellRanks and type(state.cdmAuraRenderSpellIDs) == "table" then
    state.cdmAuraRenderSpellIDs = expandRanks(state.cdmAuraRenderSpellIDs)
  end
end

local function setDispel(state, aura)
  local dispelName = aura.dispelName
  if not (isReadable(dispelName) and type(dispelName) == "string") then return end
  state.cdmDispelName = dispelName
  state.debuffClass = dispelName == "" and "enrage" or dispelName:lower()
end

local function applyTotem(state, totem)
  state.cdmAuraTotem = true
  state.auraActive = nil
  local duration, expiration = readNumber(totem.duration), readNumber(totem.expirationTime)
  if duration and expiration then
    applyTimes(state, expiration - duration, duration, totem.modRate)
    state.auraActive = expiration > GetTime()
  end
end

local function captureNativeWidgets(state, frame, unit)
  local cooldown = frame.Cooldown or frame.cooldown
  if cooldown and cooldown.GetCountdownFontString then state.cdmCountdownSource = cooldown:GetCountdownFontString() end
  if not state.cdmCountdownSource and frame.Bar then state.cdmCountdownSource = frame.Bar.Duration end
  local applications = frame.Applications
  local stacks = applications and (applications.Applications or applications)
  if not stacks or not stacks.GetText then stacks = frame.Icon and frame.Icon.Applications end
  if stacks and stacks.GetText then state.cdmStackSource = stacks end
  state.cdmTextRecord = nativeRecords[frame]

  local instance = frame.auraInstanceID
  local canAsk = not isReadable(instance) or type(instance) == "number"
  if canAsk and isUnitToken(unit) and C_UnitAuras and C_UnitAuras.GetAuraDuration then
    local ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, unit, instance)
    if ok and Private.IsDurationObject(durationObject) then useDurationObject(state, durationObject) end
  end
end

local function applyNativeRecord(state, rec)
  if not state.durationObject and rec.duration then
    useDurationObject(state, rec.duration)
  elseif not state.durationObject and rec.raw then
    local duration = rec.converted
    if not duration then duration = convertRawTiming(rec) or duration end
    if duration then
      useDurationObject(state, duration)
    else
      applyTimes(state, rec.raw.start, rec.raw.duration, rec.raw.modRate)
    end
  end
  state.cdmNativePaused = rec.paused == true
end

local function applyAuraTiming(state, aura)
  state.stacks = readNumber(aura.applications)
  if not state.durationObject and C_DurationUtil and C_DurationUtil.CreateDuration then
    local built = C_DurationUtil.CreateDuration()
    if built.SetTimeFromEnd and pcall(built.SetTimeFromEnd, built, aura.expirationTime, aura.duration, aura.timeMod) then
      useDurationObject(state, built)
    end
  end
  local duration, expiration = readNumber(aura.duration), readNumber(aura.expirationTime)
  if not (duration and expiration) then return end
  if not state.durationObject then applyTimes(state, expiration - duration, duration, aura.timeMod) end
  state.auraActive = duration == 0 or expiration > GetTime()
end

local function applyCachedAura(state, frame, exactID, buffSpellIDs)
  local aura, unit
  state.cdmAuraUnit, state.cdmAuraFilter, state.cdmAuraTotem = "player", "HELPFUL", false
  if frame then aura, unit = frame.auraDataCached, frame.auraDataUnit end
  applyAuraSource(state, unit, aura)

  local nativeMatches = frame and not exactID
  if frame and exactID then
    local nativeSpellID = readNumber(frame.auraSpellID) or (aura and readNumber(aura.spellId))
    nativeMatches = nativeSpellID == exactID
  end
  if nativeMatches then markNativeInstance(state, frame, aura) end
  if exactID and aura and not nativeMatches then aura, unit = nil, nil end

  local nativeAbsent = frame and isReadable(frame.auraInstanceID) and frame.auraInstanceID == nil
    and not frame.auraDataCached
  state.cdmAuraRenderUnit, state.cdmAuraRenderSpellIDs = nil, nil
  if nativeMatches and not nativeAbsent and isUnitToken(unit) then
    setRenderSource(state, frame, aura, unit, exactID, buffSpellIDs)
  end
  if nativeAbsent then state.auraActive = false end
  if aura then
    state.auraActive = true
    setDispel(state, aura)
  end

  local totem = not aura and frame and frame.totemData
  if totem then
    applyTotem(state, totem)
    return
  end

  local usable = nativeMatches and not nativeAbsent
  if usable then captureNativeWidgets(state, frame, unit) end
  if usable and nativeRecords[frame] then applyNativeRecord(state, nativeRecords[frame]) end
  if aura then applyAuraTiming(state, aura) end
end

local function resolveNativeActive(state, frame, exactID)
  local active = frame.isActive
  if not isReadable(active) then
    state.auraActive = nil
    return
  end
  if type(active) ~= "boolean" then return end
  state.auraActive = active
  if active and exactID then
    local nativeSpellID = readNumber(frame.auraSpellID)
      or (frame.auraDataCached and readNumber(frame.auraDataCached.spellId))
    if nativeSpellID then state.auraActive = nativeSpellID == exactID else state.auraActive = nil end
  end
end

function Private.CDMApplyAura(state, identity, info, frame, exactID, buffSpellIDs)
  applyCachedAura(state, frame, exactID, buffSpellIDs)
  if frame and state.auraActive ~= false then resolveNativeActive(state, frame, exactID) end
  if state.auraActive ~= false then return end
  state.progressType, state.value, state.total = "static", 1, 1
  state.durationObject, state.duration, state.expirationTime, state.modRate = nil, nil, nil, nil
  state.cdmCountdownSource, state.cdmStackSource, state.cdmTextRecord = nil, nil, nil
  state.stacks, state.cdmDispelName, state.debuffClass = nil, nil, nil
end

function Private.ParseCDMText(value)
  if type(value) ~= "string" then return end
  local token = value:match("^%%{(.-)}$") or value:match("^%%(.+)$")
  if not token then return end
  if PLAIN_TEXT_TOKENS[token] then return token end
  local triggerIndex, shortKind = token:match("^(%d+)%.(b?[ps])$")
  if triggerIndex then return shortKind, tonumber(triggerIndex) end
  local index, field = token:match("^(%d+)%.(%a+)$")
  if field == "caster" or field == "dispel" then return field, tonumber(index) end
end

local function resolveTriggerIndex(index, triggers, data)
  if not index and data.progressSource and data.progressSource[1] then
    local source = data.progressSource[1]
    if source == 0 then return nil, true end
    if source > 0 then index = source end
  end
  return index or (triggers.activeTriggerMode and triggers.activeTriggerMode > 0 and triggers.activeTriggerMode)
    or (#triggers == 1 and 1)
end

function Private.IsCDMBuffText(value, data)
  local kind, index = Private.ParseCDMText(value)
  if not kind then return false end
  if kind == "bp" or kind == "bs" then return true end
  local triggers = data and data.triggers
  if not triggers then return false end
  local resolved, rejected = resolveTriggerIndex(index, triggers, data)
  if rejected then return false end
  local entry = resolved and triggers[resolved]
  local trigger = type(entry) == "table" and entry.trigger
  return trigger and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff" or false
end

function Private.CopyCDMCountdownText(destination, state, kind)
  if kind == "caster" then
    destination:SetText("")
    return
  end
  if kind == "dispel" then
    destination:SetText(state and state.show and state.cdmDispelName or "")
    return
  end
  if kind == "s" then kind = "bs" end
  local isStack = kind == "bs"
  if not isStack and state and state.cdmBuff and state.show and not state.cdmTextPreview
      and Private.IsDurationObject(state.durationObject) then
    destination:SetText(Private.FormatDurationText(state.durationObject, false, 99, 0, 0))
    return
  end

  local source = state and state.show and (isStack and state.cdmStackSource or not isStack and state.cdmCountdownSource)
  if source and source.IsForbidden and source:IsForbidden() then source = nil end
  if source and (isStack or (state and state.cdmBuff)) and source.IsShown then
    local shown = source:IsShown()
    if isReadable(shown) and not shown then
      destination:SetText("")
      return
    end
  end

  if source then
    local text = source:GetText()
    if not isStack and state and state.cdmBuff and isReadable(text) and tonumber(text) == 0 then text = "" end
    destination:SetText(text)
  elseif state and state.show and state.cdmTextPreview then
    local remaining = state.expirationTime and math.max(0, state.expirationTime - GetTime()) or 6
    destination:SetText(isStack and "3" or tostring(math.ceil(remaining)))
  else
    destination:SetText("")
  end
end

local tinsert = table.insert

local function ForEachCooldownManagerEntry(categoryNames, func)
  if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and Enum and Enum.CooldownViewerCategory) then
    return
  end
  for _, categoryName in ipairs(categoryNames) do
    local category = Enum.CooldownViewerCategory[categoryName]
    local ok, cooldownIDs = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, category)
    if category and ok and type(cooldownIDs) == "table" then
      for _, cooldownID in ipairs(cooldownIDs) do
        local infoOk, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
        if infoOk and info then
          func(cooldownID, info)
        end
      end
    end
  end
end

local function SpellLabel(spellID)
  local name, _, icon = Private.ExecEnv.GetSpellInfo(spellID)
  return name and (icon and ("|T%s:16|t %s"):format(icon, name) or name)
end

function Private.GetCooldownManagerSpells()
  local spells = {}
  ForEachCooldownManagerEntry({"Essential", "Utility"}, function(cooldownID, info)
    local spellID = info.spellID
    if spellID and not spells[spellID] then
      spells[spellID] = SpellLabel(spellID)
    end
  end)
  return spells
end

function Private.GetCooldownManagerAuras()
  local auras = {}
  ForEachCooldownManagerEntry({"TrackedBuff", "TrackedBar"}, function(cooldownID, info)
    if info.spellID then
      auras[cooldownID] = SpellLabel(info.spellID)
    end
  end)
  return auras
end

function Private.GetCooldownManagerAuraSpellIDs(cooldownID)
  local spellIDs = {}
  local info = C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
  if info then
    for _, spellID in ipairs(info.linkedSpellIDs or {}) do
      tinsert(spellIDs, spellID)
    end
    for _, spellID in ipairs({info.overrideTooltipSpellID or false, info.spellID or false}) do
      if spellID then
        tinsert(spellIDs, spellID)
      end
    end
  end
  return spellIDs
end

if not WeakAuras.IsLibsOK() then return end
local Private = select(2, ...)

local isSecret = Private.IsSecret

local weakKeys = { __mode = "k" }
local identityCache = {}
local requestedItems = {}
local nativeRecords = setmetatable({}, weakKeys)
local lastNativeSpells = setmetatable({}, weakKeys)
local keptTimings = setmetatable({}, weakKeys)
local hookedViewers = setmetatable({}, weakKeys)
local pendingSelfCasts = {}
local refreshPending = false

local viewerNames = {
  "EssentialCooldownViewer",
  "UtilityCooldownViewer",
  "BuffIconCooldownViewer",
  "BuffBarCooldownViewer",
}

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

local simpleTextKinds = {
  bp = true,
  bs = true,
  p = true,
  s = true,
  caster = true,
  dispel = true,
}

local function readValue(value)
  if isSecret(value) then
    return nil
  end
  return value
end

local function readNumber(value)
  if isSecret(value) or type(value) ~= "number" then
    return nil
  end
  return value
end

local function readBoolean(value)
  if isSecret(value) or type(value) ~= "boolean" then
    return nil
  end
  return value
end

local function readString(value)
  if isSecret(value) or type(value) ~= "string" then
    return nil
  end
  return value
end

local function queueRefresh()
  if refreshPending then
    return
  end
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
  if not itemID then
    return
  end
  if not (C_Item and C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID) then
    return
  end
  if requestedItems[itemID] then
    return
  end
  if C_Item.IsItemDataCachedByID(itemID) then
    return
  end
  requestedItems[itemID] = true
  C_Item.RequestLoadItemDataByID(itemID)
end

function Private.CDMResetIdentities()
  local batch = Private.cdmScanBatch
  if batch then
    if batch.identitiesReset then
      return
    end
    batch.identitiesReset = true
  end
  wipe(identityCache)
end

function Private.CDMCategoryName(category)
  for memberName, memberValue in pairs(Enum.CooldownViewerCategory) do
    if memberValue == category then
      return categoryLabels[memberName] or memberName
    end
  end
  return "Other"
end

function Private.CDMIsBuff(category)
  local categories = Enum.CooldownViewerCategory
  return category == categories.TrackedBuff
    or category == categories.TrackedBar
    or category == categories.GroupBuff
    or category == categories.SpecAgnosticTracked
    or category == categories.EquipSlotTracked
end

local function convertRawTimes(record)
  if record.converted then
    return record.converted
  end
  local raw = record.raw
  if not raw or not (C_DurationUtil and C_DurationUtil.CreateDuration) then
    return nil
  end
  local duration = C_DurationUtil.CreateDuration()
  if pcall(duration.SetTimeFromStart, duration, raw.start, raw.duration, raw.modRate) then
    record.converted = duration
  end
  return record.converted
end

local function isTimerExpired(record)
  if record.paused then
    return false
  end
  local durationObject = record.duration or record.converted
  if durationObject and durationObject.GetRemainingDuration then
    local remaining = readNumber(durationObject:GetRemainingDuration())
    if remaining == nil then
      return false
    end
    return remaining <= 0
  end
  local raw = record.raw
  if raw then
    local start = readNumber(raw.start)
    local duration = readNumber(raw.duration)
    local modRate
    if not isSecret(raw.modRate) and raw.modRate == nil then
      modRate = 1
    else
      modRate = readNumber(raw.modRate)
    end
    if start and duration and modRate and modRate > 0 then
      return GetTime() >= start + duration / modRate
    end
  end
  return false
end

local function gatherState(frame, record)
  record.cooldownID = readValue(frame.cooldownID)
  if frame.GetSpellID then
    record.spellID = readValue(frame:GetSpellID())
  else
    record.spellID = nil
  end
  local onCooldown = readBoolean(frame.isOnActualCooldown)
  local recharging = readBoolean(frame.wasSetFromCharges)
  record.paused = readValue(frame.cooldownPaused) == true
  if record.completedRevision and record.completedRevision == record.revision then
    onCooldown = false
    recharging = false
  end
  record.onCooldown = onCooldown
  record.recharging = recharging
  record.charges = readNumber(frame.cooldownChargesCount)
  local onGCD = readBoolean(frame.isOnGCD)
  if onCooldown or recharging or readValue(frame.cooldownUseAuraDisplayTime) then
    onGCD = false
  end
  record.onGCD = onGCD
end

local function resync(frame, record)
  gatherState(frame, record)
  queueRefresh()
end

local function startRevision(frame, record, durationObject, raw)
  record.revision = record.revision + 1
  record.duration = durationObject
  record.raw = raw
  record.converted = nil
  resync(frame, record)
end

local function hookMethod(target, methodName, handler)
  if target[methodName] then
    hooksecurefunc(target, methodName, handler)
  end
end

local function observeCooldownWidget(frame, record, cooldown)
  if cooldown.HookScript then
    cooldown:HookScript("OnCooldownDone", function()
      gatherState(frame, record)
      if readValue(frame.cooldownUseAuraDisplayTime) == false
        and record.onGCD == false
        and isTimerExpired(record) then
        record.completedRevision = record.revision
        record.onCooldown = false
        record.recharging = false
      end
      queueRefresh()
    end)
  end
  hookMethod(cooldown, "SetCooldownFromDurationObject", function(_, durationObject)
    startRevision(frame, record, durationObject, nil)
  end)
  hookMethod(cooldown, "SetCooldown", function(_, start, duration, modRate)
    startRevision(frame, record, nil, { start = start, duration = duration, modRate = modRate })
  end)
  hookMethod(cooldown, "Clear", function()
    startRevision(frame, record, nil, nil)
  end)
  hookMethod(cooldown, "Pause", function()
    record.paused = true
    queueRefresh()
  end)
  hookMethod(cooldown, "Resume", function()
    record.paused = false
    queueRefresh()
  end)

  if cooldown.GetCooldownTimes then
    local succeeded, startMilliseconds, durationMilliseconds = pcall(cooldown.GetCooldownTimes, cooldown)
    local start = succeeded and readNumber(startMilliseconds)
    local duration = succeeded and readNumber(durationMilliseconds)
    if start and duration then
      record.raw = { start = start / 1000, duration = duration / 1000, modRate = frame.cooldownModRate }
    elseif frame.RefreshSpellCooldownInfo then
      record.raw = {
        start = frame.cooldownStartTime,
        duration = frame.cooldownDuration,
        modRate = frame.cooldownModRate,
      }
    end
  elseif frame.RefreshSpellCooldownInfo then
    record.raw = {
      start = frame.cooldownStartTime,
      duration = frame.cooldownDuration,
      modRate = frame.cooldownModRate,
    }
  end
  gatherState(frame, record)
end

local function observeFrame(frame)
  if not hooksecurefunc or nativeRecords[frame] then
    return
  end
  local record = { revision = 0 }
  nativeRecords[frame] = record

  local function resetOrQueue()
    if frame.RefreshSpellCooldownInfo then
      queueRefresh()
    else
      startRevision(frame, record, nil, nil)
    end
  end
  local function reset()
    startRevision(frame, record, nil, nil)
  end
  local function resyncRecord()
    resync(frame, record)
  end

  hookMethod(frame, "ClearAuraInstanceInfo", resetOrQueue)
  hookMethod(frame, "OnAuraInstanceInfoCleared", resetOrQueue)
  hookMethod(frame, "OnAuraInstanceInfoSet", resetOrQueue)
  hookMethod(frame, "OnCooldownIDSet", reset)
  hookMethod(frame, "OnCooldownIDCleared", reset)
  hookMethod(frame, "ResetCooldownData", reset)
  hookMethod(frame, "SetAuraInstanceInfo", queueRefresh)
  hookMethod(frame, "OnUnitAuraRemovedEvent", queueRefresh)
  hookMethod(frame, "OnUnitAuraUpdatedEvent", queueRefresh)
  hookMethod(frame, "OnNewTarget", queueRefresh)
  hookMethod(frame, "OnActiveStateChanged", queueRefresh)
  hookMethod(frame, "RefreshIconColor", queueRefresh)
  hookMethod(frame, "RefreshData", resyncRecord)
  hookMethod(frame, "RefreshCooldownOnly", resyncRecord)
  if frame.HookScript then
    frame:HookScript("OnShow", queueRefresh)
    frame:HookScript("OnHide", queueRefresh)
  end

  local cooldown = frame.Cooldown or frame.cooldown
  if cooldown then
    observeCooldownWidget(frame, record, cooldown)
  end
end

local function hookViewer(viewerName, viewer)
  if hookedViewers[viewer] or not hooksecurefunc then
    return
  end
  hookedViewers[viewer] = true
  if viewerName == "BuffIconCooldownViewer" or viewerName == "BuffBarCooldownViewer" then
    hookMethod(viewer, "OnAcquireItemFrame", function(_, itemFrame)
      if itemFrame then
        observeFrame(itemFrame)
      end
    end)
    hookMethod(viewer, "RefreshData", queueRefresh)
  end
  hookMethod(viewer, "OnUnitAura", queueRefresh)
  hookMethod(viewer, "OnPlayerTargetChanged", queueRefresh)
  hookMethod(viewer, "RefreshActiveFramesForTargetChange", queueRefresh)
end

function Private.CDMFrames()
  local batch = Private.cdmScanBatch
  if batch and batch.frames then
    return batch.frames
  end
  local frames = {}
  for _, viewerName in ipairs(viewerNames) do
    local viewer = _G[viewerName]
    if viewer then
      hookViewer(viewerName, viewer)
      local pool = viewer.itemFramePool
      if pool and pool.EnumerateActive then
        for frame in pool:EnumerateActive() do
          local cooldownID = readNumber(frame.cooldownID)
          if cooldownID ~= nil then
            observeFrame(frame)
            frames[cooldownID] = frame
          end
        end
      end
    end
  end
  if batch then
    batch.frames = frames
  end
  return frames
end

function Private.CDMGetNativeCooldown(frame, spellID)
  if not frame then
    return nil
  end
  local record = nativeRecords[frame]
  if not record then
    return nil
  end
  if record.cooldownID ~= readValue(frame.cooldownID) then
    return nil
  end
  if record.spellID ~= spellID then
    return nil
  end
  if frame.GetSpellID and readValue(frame:GetSpellID()) ~= spellID then
    return nil
  end
  local inRange
  local outOfRange = readBoolean(frame.spellOutOfRange)
  if outOfRange ~= nil then
    inRange = not outOfRange
  end
  return {
    duration = record.duration or convertRawTimes(record),
    revision = record.revision,
    onGCD = record.onGCD,
    onCooldown = record.onCooldown,
    recharging = record.recharging,
    charges = record.charges,
    inRange = inRange,
    paused = record.paused and true or false,
  }
end

function Private.CDMCatalog()
  local provider
  if CooldownViewerSettings and CooldownViewerSettings.GetDataProvider then
    provider = CooldownViewerSettings:GetDataProvider()
  end
  provider = provider or CooldownViewerDataProvider
  local layout
  if provider and provider.GetDisplayData and not (provider.IsDirty and provider:IsDirty()) then
    local displayData = provider:GetDisplayData()
    layout = displayData and displayData.cooldownInfoByID
  end

  local frames = Private.CDMFrames()
  local categories = Enum.CooldownViewerCategory
  local catalog = {}

  for _, sourceCategory in pairs(categories) do
    if type(sourceCategory) == "number" and sourceCategory >= 0 then
      local cooldownIDs = C_CooldownViewer.GetCooldownViewerCategorySet(sourceCategory, true) or {}
      for _, rawCooldownID in ipairs(cooldownIDs) do
        local cooldownID = readNumber(rawCooldownID)
        local info = cooldownID ~= nil and C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
        if info then
          local layoutEntry = layout and layout[cooldownID]
          local placement = layoutEntry and readNumber(layoutEntry.category)
          local displayed
          if placement ~= nil and placement ~= false then
            displayed = placement == categories.Essential
              or placement == categories.Utility
              or placement == categories.TrackedBuff
              or placement == categories.TrackedBar
          else
            placement = nil
            local frame = frames[cooldownID]
            if frame then
              displayed = true
              placement = frame.viewerFrame and readNumber(frame.viewerFrame.cooldownViewerCategory)
              if placement == false then
                placement = nil
              end
            end
          end
          local category = sourceCategory
          if placement and placement >= 0 then
            category = placement
          end
          catalog[cooldownID] = {
            category = category,
            sourceCategory = sourceCategory,
            displayed = displayed,
            known = not isSecret(info.isKnown) and info.isKnown ~= false,
          }
        end
      end
    end
  end
  return catalog
end

local function firstReadableNumber(...)
  for index = 1, select("#", ...) do
    local number = readNumber((select(index, ...)))
    if number ~= nil then
      return number
    end
  end
  return nil
end

function Private.CDMIdentity(id, entry, info, frame)
  local spellID
  if frame and frame.GetSpellID then
    spellID = readNumber(frame:GetSpellID())
  end
  if spellID == nil then
    spellID = firstReadableNumber(info.linkedSpellID, info.overrideTooltipSpellID, info.overrideSpellID)
  end
  if spellID == nil and Private.CDMIsBuff(entry.category) and info.linkedSpellIDs then
    for _, linkedSpellID in ipairs(info.linkedSpellIDs) do
      local readable = readNumber(linkedSpellID)
      if readable and readable > 0 then
        spellID = readable
        break
      end
    end
  end
  if spellID == nil then
    spellID = readNumber(info.spellID)
  end

  local slot = readNumber(info.equipSlot)
  local itemID
  if slot then
    itemID = readNumber(GetInventoryItemID("player", slot))
  end
  if itemID == nil and frame and frame.cooldownInfo then
    itemID = readNumber(frame.cooldownInfo.lastItemIDForCategory)
  end

  if spellID == nil then
    local spellCategoryID = readNumber(info.spellCategoryID)
    if spellCategoryID and C_Spell and C_Spell.GetLastCategoryCooldownSource then
      local sourceSpell, sourceItem = C_Spell.GetLastCategoryCooldownSource(spellCategoryID)
      spellID = readNumber(sourceSpell)
      if itemID == nil then
        itemID = readNumber(sourceItem)
      end
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
    name = (C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)) or ("Item " .. itemID)
    icon = (C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID)) or icon
  end

  local previous = identityCache[id]
  if slot or (itemID and previous and itemID ~= previous.itemID) then
    previous = nil
  end
  previous = previous or {}

  local resolvedName = name or previous.name
  if not resolvedName then
    if slot then
      resolvedName = "Equipment slot " .. slot
    else
      resolvedName = "CDM entry " .. tostring(id)
    end
  end

  local identity = {
    spellID = spellID or previous.spellID,
    itemID = itemID or previous.itemID,
    slot = slot,
    name = resolvedName,
    icon = icon or previous.icon or 134400,
  }
  identityCache[id] = {
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
    start, duration, enabled = GetInventoryItemCooldown("player", identity.slot)
  elseif identity.itemID and C_Item and C_Item.GetItemCooldown then
    start, duration, enabled = C_Item.GetItemCooldown(identity.itemID)
  end
  start = readNumber(start)
  duration = readNumber(duration)
  if start == nil or duration == nil then
    return
  end
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

local function setDurationMode(state, durationObject)
  state.progressType = "durationObject"
  state.durationObject = durationObject
  state.value = nil
  state.total = nil
end

local function setTimedMode(state, duration, expirationTime, modRate)
  state.progressType = "timed"
  state.duration = duration
  state.expirationTime = expirationTime
  state.modRate = modRate
  state.value = nil
  state.total = nil
end

local function canQueryPlayerAuras()
  return C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and not WeakAuras.IsRestricted()
end

local function applyAuraTiming(state, aura)
  state.stacks = readValue(aura.applications)
  if not state.durationObject and C_DurationUtil and C_DurationUtil.CreateDuration then
    local durationObject = C_DurationUtil.CreateDuration()
    if pcall(durationObject.SetTimeFromEnd, durationObject, aura.expirationTime, aura.duration, aura.timeMod) then
      setDurationMode(state, durationObject)
    end
  end
  local duration = readNumber(aura.duration)
  local expirationTime = readNumber(aura.expirationTime)
  if duration ~= nil and expirationTime ~= nil then
    if not state.durationObject then
      setTimedMode(state, duration, expirationTime, readNumber(aura.timeMod) or 1)
    end
    state.auraActive = duration == 0 or expirationTime > GetTime()
  end
end

local function captureNativeWidgets(state, frame, unit)
  local cooldown = frame.Cooldown or frame.cooldown
  local countdownSource
  if cooldown and cooldown.GetCountdownFontString then
    countdownSource = cooldown:GetCountdownFontString()
  end
  if not countdownSource and frame.Bar then
    countdownSource = frame.Bar.Duration
  end
  state.cdmCountdownSource = countdownSource

  local applications = frame.Applications
  if applications then
    local candidate = applications.Applications or applications
    if candidate.GetText then
      state.cdmStackSource = candidate
    elseif frame.Icon and frame.Icon.Applications and frame.Icon.Applications.GetText then
      state.cdmStackSource = frame.Icon.Applications
    end
  elseif frame.Icon and frame.Icon.Applications and frame.Icon.Applications.GetText then
    state.cdmStackSource = frame.Icon.Applications
  end

  state.cdmTextRecord = nativeRecords[frame]

  local instanceID = frame.auraInstanceID
  if (isSecret(instanceID) or type(instanceID) == "number")
    and (unit == "player" or unit == "target")
    and C_UnitAuras and C_UnitAuras.GetAuraDuration then
    local succeeded, durationObject = pcall(C_UnitAuras.GetAuraDuration, unit, instanceID)
    if succeeded and Private.IsDurationObject(durationObject) then
      setDurationMode(state, durationObject)
    end
  end
end

local function applyNativeRecord(state, record)
  if not state.durationObject then
    if record.duration then
      setDurationMode(state, record.duration)
    elseif record.raw then
      local converted = convertRawTimes(record)
      if converted then
        setDurationMode(state, converted)
      else
        local start = readNumber(record.raw.start)
        local duration = readNumber(record.raw.duration)
        if start ~= nil and duration ~= nil then
          setTimedMode(state, duration, start + duration, readNumber(record.raw.modRate) or 1)
        end
      end
    end
  end
  state.cdmNativePaused = record.paused == true
end

local function expandWithRanks(spellIDs)
  local expanded = {}
  local seen = {}
  for _, spellID in ipairs(spellIDs) do
    for _, rankSpellID in ipairs(Private.GetAuraSpellRanks(spellID)) do
      if not seen[rankSpellID] then
        seen[rankSpellID] = true
        expanded[#expanded + 1] = rankSpellID
      end
    end
  end
  return expanded
end

local function resolveCachedAura(state, frame, exactID, buffSpellIDs)
  state.cdmAuraUnit = "player"
  state.cdmAuraFilter = "HELPFUL"
  state.cdmAuraTotem = false

  local aura, unit
  if frame then
    aura = frame.auraDataCached
    unit = readString(frame.auraDataUnit)
  end

  if unit == "player" or unit == "target" then
    state.cdmAuraUnit = unit
  end
  local filter
  local harmful = aura and readBoolean(aura.isHarmful)
  if harmful ~= nil then
    filter = harmful and "HARMFUL" or "HELPFUL"
  elseif state.cdmAuraUnit == "target" then
    if readValue(UnitIsFriend("player", "target")) == true then
      filter = "HELPFUL"
    else
      filter = "HARMFUL"
    end
  else
    filter = "HELPFUL"
  end
  if state.cdmAuraUnit == "target" then
    if filter == "HELPFUL" then
      filter = "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY"
    else
      filter = "HARMFUL|PLAYER"
    end
  end
  state.cdmAuraFilter = filter

  local nativeSpellID
  local nativeMatches
  if not exactID then
    nativeMatches = frame and true or false
  elseif frame then
    nativeSpellID = readNumber(frame.auraSpellID)
    if nativeSpellID == nil and aura then
      nativeSpellID = readNumber(aura.spellId)
    end
    if nativeSpellID == nil and unit == "player" and canQueryPlayerAuras() then
      local succeeded, foundAura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, exactID)
      if succeeded then
        if foundAura and foundAura.isFromPlayerOrPlayerPet == true then
          aura = foundAura
          nativeSpellID = exactID
        else
          lastNativeSpells[frame] = nil
        end
      end
    end
    if nativeSpellID ~= nil then
      lastNativeSpells[frame] = nativeSpellID
    elseif aura and WeakAuras.IsRestricted() then
      nativeSpellID = lastNativeSpells[frame]
    end
    nativeMatches = nativeSpellID ~= nil and nativeSpellID == exactID
  else
    nativeMatches = false
  end

  if nativeMatches then
    local instanceID = frame.auraInstanceID
    if not isSecret(instanceID) then
      if instanceID ~= nil then
        state.auraActive = true
      elseif not aura then
        state.auraActive = false
      end
    end
  end

  if exactID and aura and not nativeMatches then
    aura = nil
    unit = nil
  end

  local nativeAbsent = false
  if frame then
    local instanceID = frame.auraInstanceID
    nativeAbsent = not isSecret(instanceID) and instanceID == nil and not frame.auraDataCached
  end

  state.cdmAuraRenderUnit = nil
  state.cdmAuraRenderSpellIDs = nil
  if nativeMatches and not nativeAbsent and (unit == "player" or unit == "target") then
    state.cdmAuraRenderUnit = unit
    local renderSpellID = readNumber(frame.auraSpellID)
    if renderSpellID == nil and aura then
      renderSpellID = readNumber(aura.spellId)
    end
    local renderSpellIDs
    if renderSpellID ~= nil then
      renderSpellIDs = { renderSpellID }
    else
      renderSpellIDs = buffSpellIDs
    end
    if not exactID and Private.GetAuraSpellRanks and type(renderSpellIDs) == "table" then
      renderSpellIDs = expandWithRanks(renderSpellIDs)
    end
    state.cdmAuraRenderSpellIDs = renderSpellIDs
  end

  if nativeAbsent then
    state.auraActive = false
  end

  if aura then
    state.auraActive = true
    local dispelName = readString(aura.dispelName)
    if dispelName ~= nil then
      state.cdmDispelName = dispelName
      if dispelName == "" then
        state.debuffClass = "enrage"
      else
        state.debuffClass = dispelName:lower()
      end
    end
  end

  local totemData = frame and frame.totemData
  if not aura and totemData then
    state.cdmAuraTotem = true
    state.auraActive = nil
    local duration = readNumber(totemData.duration)
    local expirationTime = readNumber(totemData.expirationTime)
    if duration ~= nil and expirationTime ~= nil then
      setTimedMode(state, duration, expirationTime, readNumber(totemData.modRate) or 1)
      state.auraActive = expirationTime > GetTime()
    end
    return nativeSpellID
  end

  local usable = nativeMatches and not nativeAbsent
  if usable then
    captureNativeWidgets(state, frame, unit)
    local record = nativeRecords[frame]
    if record then
      applyNativeRecord(state, record)
    end
  end
  if aura then
    applyAuraTiming(state, aura)
  end

  if usable and unit == "player" and not state.durationObject and not state.duration
    and canQueryPlayerAuras() and state.cdmAuraRenderSpellIDs then
    for _, renderSpellID in ipairs(state.cdmAuraRenderSpellIDs) do
      local succeeded, foundAura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, renderSpellID)
      if succeeded and foundAura and foundAura.isFromPlayerOrPlayerPet == true then
        applyAuraTiming(state, foundAura)
        break
      end
    end
  end

  return nativeSpellID
end

local function resolveActiveState(state, frame, exactID, nativeSpellID)
  local active = frame.isActive
  if isSecret(active) then
    state.auraActive = nil
    return
  end
  if type(active) ~= "boolean" then
    return
  end
  state.auraActive = active
  if active and exactID then
    local spellID = nativeSpellID
    if spellID == nil then
      spellID = readNumber(frame.auraSpellID)
    end
    if spellID == nil and frame.auraDataCached then
      spellID = readNumber(frame.auraDataCached.spellId)
    end
    if spellID ~= nil then
      state.auraActive = spellID == exactID
    else
      state.auraActive = nil
    end
  end
end

local function trackedSpellID(frame, previousKept)
  local spellID = readNumber(frame.auraSpellID)
  if spellID == nil and frame.auraDataCached then
    spellID = readNumber(frame.auraDataCached.spellId)
  end
  if spellID == nil and previousKept then
    spellID = previousKept.spellID
  end
  return spellID
end

local function keepOrRestoreTiming(state, frame)
  local kept = keptTimings[frame]
  local cooldownID = readValue(frame.cooldownID)
  local now = GetTime()

  if state.progressType == "static" then
    if not kept then
      return
    end
    if kept.cooldownID ~= cooldownID or (kept.expiresAt and kept.expiresAt <= now) then
      keptTimings[frame] = nil
      return
    end
    state.progressType = kept.progressType
    state.durationObject = kept.durationObject
    state.duration = kept.duration
    state.expirationTime = kept.expirationTime
    state.modRate = kept.modRate
    state.value = nil
    state.total = nil
    return
  end

  if kept and kept.cooldownID ~= cooldownID then
    kept = nil
  end

  local stateDuration = readNumber(state.duration)
  local stateExpiration = readNumber(state.expirationTime)
  local durationObject = state.durationObject

  local expiresAt
  if stateDuration and stateExpiration and stateDuration > 0 then
    expiresAt = stateExpiration
  elseif durationObject then
    local succeeded, remaining = pcall(durationObject.GetRemainingDuration, durationObject)
    remaining = succeeded and readNumber(remaining)
    if remaining and remaining > 0 then
      expiresAt = now + remaining
    end
  end

  local totalDuration = stateDuration
  if totalDuration == nil and durationObject then
    local succeeded, total = pcall(durationObject.GetTotalDuration, durationObject)
    totalDuration = succeeded and readNumber(total) or nil
  end
  if totalDuration == nil and kept then
    totalDuration = kept.totalDuration
  end

  keptTimings[frame] = {
    cooldownID = cooldownID,
    progressType = state.progressType,
    durationObject = durationObject,
    duration = state.duration,
    expirationTime = state.expirationTime,
    modRate = state.modRate,
    spellID = trackedSpellID(frame, kept),
    expiresAt = expiresAt,
    totalDuration = totalDuration,
  }
end

function Private.CDMApplyAura(state, identity, info, frame, exactID, buffSpellIDs)
  local nativeSpellID = resolveCachedAura(state, frame, exactID, buffSpellIDs)

  if frame and state.auraActive ~= false then
    resolveActiveState(state, frame, exactID, nativeSpellID)
  end

  if frame then
    if state.auraActive == false or state.cdmAuraUnit == "target" then
      keptTimings[frame] = nil
    else
      keepOrRestoreTiming(state, frame)
    end
  end

  if state.auraActive ~= false then
    return
  end

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

function Private.ParseCDMText(value)
  if type(value) ~= "string" then
    return nil
  end
  local token = value:match("^%%{(.+)}$") or value:match("^%%(.+)$")
  if not token then
    return nil
  end
  if simpleTextKinds[token] then
    return token
  end
  local index, kind = token:match("^(%d+)%.(%a+)$")
  if kind and simpleTextKinds[kind] then
    return kind, tonumber(index)
  end
  return nil
end

function Private.IsCDMBuffText(value, data)
  local kind, index = Private.ParseCDMText(value)
  if not kind then
    return false
  end
  if kind == "bp" or kind == "bs" then
    return true
  end
  local triggers = data and data.triggers
  if not triggers then
    return false
  end
  if not index then
    local source = data.progressSource and data.progressSource[1]
    if source == 0 then
      return false
    elseif type(source) == "number" and source > 0 then
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
  if type(entry) ~= "table" or type(entry.trigger) ~= "table" then
    return false
  end
  return entry.trigger.type == "cdm" and entry.trigger.event == "Blizzard CDM Buff"
end

function Private.CopyCDMCountdownText(destination, state, kind)
  if kind == "caster" then
    destination:SetText("")
    return
  end
  if kind == "dispel" then
    if state and state.show and state.cdmDispelName then
      destination:SetText(state.cdmDispelName)
    else
      destination:SetText("")
    end
    return
  end
  if kind == "s" then
    kind = "bs"
  end
  local isStack = kind == "bs"

  if not isStack and state and state.cdmBuff and state.show and not state.cdmTextPreview
    and Private.IsDurationObject(state.durationObject) then
    destination:SetText(Private.FormatDurationText(state.durationObject, false, 99, 0, 0))
    return
  end

  local source
  if state and state.show then
    if isStack then
      source = state.cdmStackSource
    else
      source = state.cdmCountdownSource
    end
  end
  if source and source.IsForbidden and source:IsForbidden() then
    source = nil
  end

  if source and (isStack or state.cdmBuff) and source.IsShown then
    local shown = source:IsShown()
    if not isSecret(shown) and not shown then
      destination:SetText("")
      return
    end
  end

  if source then
    local text = source:GetText()
    if not isStack and state.cdmBuff and not isSecret(text) and tonumber(text) == 0 then
      text = ""
    end
    destination:SetText(text)
    return
  end

  if state and state.show and state.cdmTextPreview then
    if isStack then
      destination:SetText("3")
    elseif state.expirationTime then
      destination:SetText(tostring(math.ceil(math.max(0, state.expirationTime - GetTime()))))
    else
      destination:SetText("6")
    end
    return
  end

  destination:SetText("")
end

local function forEachCooldownEntry(categoryNames, callback)
  if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and Enum.CooldownViewerCategory) then
    return
  end
  for _, categoryName in ipairs(categoryNames) do
    local categoryValue = Enum.CooldownViewerCategory[categoryName]
    local succeeded, cooldownIDs = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, categoryValue)
    if succeeded and type(cooldownIDs) == "table" then
      for _, cooldownID in ipairs(cooldownIDs) do
        local infoSucceeded, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
        if infoSucceeded and info then
          callback(cooldownID, info)
        end
      end
    end
  end
end

local function spellLabel(spellID)
  local name, _, icon = Private.ExecEnv.GetSpellInfo(spellID)
  if not name then
    return nil
  end
  if icon then
    return "|T" .. icon .. ":16|t " .. name
  end
  return name
end

function Private.GetCooldownManagerSpells()
  local spells = {}
  forEachCooldownEntry({ "Essential", "Utility" }, function(_, info)
    local spellID = info.spellID
    if spellID and spells[spellID] == nil then
      spells[spellID] = spellLabel(spellID)
    end
  end)
  return spells
end

function Private.GetCooldownManagerAuras()
  local auras = {}
  forEachCooldownEntry({ "TrackedBuff", "TrackedBar" }, function(cooldownID, info)
    if info.spellID then
      auras[cooldownID] = spellLabel(info.spellID)
    end
  end)
  return auras
end

function Private.GetCooldownManagerAuraSpellIDs(cooldownID)
  local spellIDs = {}
  if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCooldownInfo) then
    return spellIDs
  end
  local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
  if not info then
    return spellIDs
  end
  for _, linkedSpellID in ipairs(info.linkedSpellIDs or {}) do
    spellIDs[#spellIDs + 1] = linkedSpellID
  end
  if info.overrideTooltipSpellID then
    spellIDs[#spellIDs + 1] = info.overrideTooltipSpellID
  end
  if info.spellID then
    spellIDs[#spellIDs + 1] = info.spellID
  end
  return spellIDs
end

local function isInRankFamily(rankSpellIDs, spellID)
  for _, rankSpellID in ipairs(rankSpellIDs) do
    if rankSpellID == spellID then
      return true
    end
  end
  return false
end

local function restartKeptTiming(kept)
  local modRate = kept.modRate
  local expiresAt = GetTime() + kept.totalDuration * (modRate or 1)
  if kept.progressType == "durationObject" then
    if not (C_DurationUtil and C_DurationUtil.CreateDuration) then
      return false
    end
    local durationObject = C_DurationUtil.CreateDuration()
    if not pcall(durationObject.SetTimeFromEnd, durationObject, expiresAt, kept.totalDuration, modRate) then
      return false
    end
    kept.durationObject = durationObject
  else
    kept.expirationTime = expiresAt
  end
  kept.expiresAt = expiresAt
  return true
end

local function handleSelfCastSucceeded(castSpellID)
  local rankSpellIDs = Private.GetAuraSpellRanks(castSpellID)
  for frame, lastSpellID in pairs(lastNativeSpells) do
    if lastSpellID ~= castSpellID and isInRankFamily(rankSpellIDs, lastSpellID) then
      lastNativeSpells[frame] = castSpellID
    end
  end
  local restarted = false
  for _, kept in pairs(keptTimings) do
    if kept.spellID and isInRankFamily(rankSpellIDs, kept.spellID)
      and kept.totalDuration and kept.totalDuration > 0 then
      if restartKeptTiming(kept) then
        restarted = true
      end
    end
  end
  if restarted then
    queueRefresh()
  end
end

local recastFrame = CreateFrame("Frame")
for _, eventName in ipairs({
  "UNIT_SPELLCAST_SENT",
  "UNIT_SPELLCAST_SUCCEEDED",
  "UNIT_SPELLCAST_FAILED",
  "UNIT_SPELLCAST_FAILED_QUIET",
  "UNIT_SPELLCAST_INTERRUPTED",
}) do
  recastFrame:RegisterUnitEvent(eventName, "player")
end

recastFrame:SetScript("OnEvent", function(_, event, ...)
  if event == "UNIT_SPELLCAST_SENT" then
    local _, target, castGUID = ...
    if isSecret(target) or isSecret(castGUID) or not castGUID then
      return
    end
    local playerName = UnitName("player")
    if target == nil or target == "" or (not isSecret(playerName) and target == playerName) then
      pendingSelfCasts[castGUID] = true
    end
    return
  end

  local _, castGUID, spellID = ...
  if isSecret(castGUID) or castGUID == nil then
    return
  end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if not pendingSelfCasts[castGUID] then
      return
    end
    pendingSelfCasts[castGUID] = nil
    local castSpellID = readNumber(spellID)
    if castSpellID == nil then
      return
    end
    handleSelfCastSucceeded(castSpellID)
  else
    pendingSelfCasts[castGUID] = nil
  end
end)

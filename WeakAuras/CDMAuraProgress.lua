if not WeakAuras.IsLibsOK() then return end
local Private = select(2, ...)

local isSecret = Private.IsSecret

local CONTAINER_ADDON = "Blizzard_AuraContainer"
local SLOT_NAME = "Timer"
local BAR_TEXTURE = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite"
local OWN_TIMER_REASON = "own"
local OBSERVED_EVENTS = {
  "PLAYER_TARGET_CHANGED",
  "PLAYER_FOCUS_CHANGED",
  "UNIT_PET",
  "UNIT_TARGET",
  "PLAYER_ENTERING_WORLD",
}

local Display = {}
Private.CDMAuraProgress = Display

local weakKeys = { __mode = "k" }
local linkedTextOwners = setmetatable({}, weakKeys)
local pendingOwners = setmetatable({}, weakKeys)
local barRegions = setmetatable({}, weakKeys)

local function isRestricted()
  return WeakAuras.IsRestricted()
end

local function runGuarded(callback)
  return xpcall(callback, geterrorhandler())
end

local function containerAvailable()
  if not C_AddOns.IsAddOnLoaded(CONTAINER_ADDON) then
    C_AddOns.LoadAddOn(CONTAINER_ADDON)
  end
  return CustomAuraContainerAuraProcessingPolicy ~= nil
end

local function isStylable(widget, initializing)
  if initializing then return true end
  if not widget.CanBeAccessedInContext then return false end
  local succeeded, result = pcall(widget.CanBeAccessedInContext, widget)
  return succeeded and not isSecret(result) and result == true
end

local function resolveState(source, explicitIndex)
  local index = explicitIndex
  if not index then
    local progressSource = source.progressSource
    index = progressSource and progressSource[1] or -1
  end
  if index > 0 then
    return source.states and source.states[index]
  elseif index == -1 then
    return source.state
  end
  return nil
end

local function isCDMBuffEntry(entry)
  if type(entry) ~= "table" then return false end
  local trigger = entry.trigger
  return type(trigger) == "table" and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff"
end

local function parseTextToken(text)
  return Private.ParseCDMText(text or "")
end

local function durationFormat(config, triggerIndex)
  local prefix = "text_text_format_" .. (triggerIndex and (triggerIndex .. ".") or "") .. "p_"
  local timeFormat = config[prefix .. "time_format"] or 0
  if timeFormat == -1 then
    return "default", nil
  end
  local rounding = config[prefix .. "time_legacy_floor"] and 0 or 99
  local threshold = config[prefix .. "time_dynamic_threshold"] or 60
  local precision = config[prefix .. "time_precision"] or 1
  local dynamic = timeFormat == -2
  local formatter = Private.GetDurationTextFormatter(rounding, threshold, precision, dynamic, timeFormat)
  local signature = table.concat({ "format", rounding, threshold, precision, tostring(dynamic), timeFormat }, "|")
  return signature, { textFormatter = formatter }
end

local function ownTimerFormat(config)
  local kind, triggerIndex = parseTextToken(config.text_text)
  if kind == "bp" then
    return "bp", { textFormatter = Private.GetDurationTextFormatter(99, 0, 0) }
  end
  return durationFormat(config, triggerIndex)
end

function Display.ResolveNativeSource(state)
  if not CustomAuraContainerAuraProcessingPolicy then return end
  if not state or not state.cdmBuff or not state.show then return end
  if state.cdmTextPreview or state.cdmAuraTotem then return end
  if state.auraActive == false then return end
  if state.progressType ~= "static" then return end
  local spellIDs = state.cdmAuraRenderSpellIDs
  if type(spellIDs) ~= "table" or next(spellIDs) == nil then return end

  local unit = state.cdmAuraRenderUnit
  local filter = state.cdmAuraFilter or "HELPFUL"
  if unit == "target" and state.cdmAuraFilter == "HARMFUL|PLAYER" then
    return unit, filter, spellIDs
  end
  if unit == "player" and filter == "HELPFUL" and isRestricted() then
    return unit, filter, spellIDs
  end
end

function Display.IsConfigured(data)
  if not data or type(data.triggers) ~= "table" then return false end
  local triggers = data.triggers
  local index = data.progressSource and data.progressSource[1] or -1
  if index == 0 then return false end
  if index < 0 then
    index = triggers.activeTriggerMode or -1
    if index < 0 and #triggers == 1 then
      index = 1
    end
  end
  return isCDMBuffEntry(triggers[index])
end

function Display.IsInactive(region)
  local state = resolveState(region)
  return state ~= nil and state.cdmBuff and state.auraActive == false or false
end

local function releaseNative(container)
  if not container or not container.wanted then return end
  container.wanted = false
  container.frame:SetEnabled(false)
end

local function createNativeContainer(owner, finishButton)
  local container = { owner = owner }
  local frame = CreateFrame("AuraContainer", nil, owner, "CustomAuraContainerTemplate")
  container.frame = frame
  frame:SetEnabled(false)
  frame:SetAllPoints(owner)
  frame:SetFrameLevel(owner:GetFrameLevel())
  frame:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  frame:AddAuraSlot(SLOT_NAME, "HELPFUL", {
    candidateFilters = { includeSpellIDs = {} },
    initializeFrame = function(button)
      container.button = button
      button:SetAllPoints(frame)
      button:SetFrameLevel(frame:GetFrameLevel())
      button:EnableMouse(false)
      finishButton(container, button)
    end,
  })
  owner:HookScript("OnHide", function()
    frame:SetEnabled(false)
  end)
  owner:HookScript("OnShow", function()
    if container.wanted then
      frame:SetEnabled(true)
    end
  end)
  return container
end

local function attachNative(container, unit, filter, spellIDs)
  local included = {}
  local sorted = {}
  for _, spellID in ipairs(spellIDs) do
    if type(spellID) == "number" and not isSecret(spellID) and spellID > 0 and not included[spellID] then
      included[spellID] = true
      sorted[#sorted + 1] = spellID
    end
  end
  table.sort(sorted)
  local key = unit .. "|" .. filter .. "|" .. table.concat(sorted, ",")
  local frame = container.frame
  if key ~= container.bindKey then
    frame:SetEnabled(false)
    frame:SetUnit(unit)
    frame:SetAuraSlotFilterString(SLOT_NAME, filter)
    frame:SetAuraSlotCandidateFilters(SLOT_NAME, { includeSpellIDs = included })
    container.bindKey = key
  end
  if key == container.enabledKey and container.wanted then return end
  container.wanted = true
  container.enabledKey = key
  if container.owner:IsVisible() then
    frame:SetEnabled(true)
  end
end

local function applyBarDirection(region, container)
  local button = container.button
  if not button then return end
  if container.direction and isRestricted() then return end
  local directions = Enum.StatusBarTimerDirection
  local direction = region.inverseDirection and directions.ElapsedTime or directions.RemainingTime
  if direction == container.direction then return end
  container.direction = direction
  button:SetDurationBar(container.statusBar, { direction = direction })
end

local function buildIconContainer(region)
  return createNativeContainer(region, function(container, button)
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    container.cooldown = cooldown
    cooldown:SetAllPoints(region.icon)
    cooldown:SetDrawBling(false)
    cooldown:SetFrameLevel(button:GetFrameLevel())
    Display.Style(region, container)
    button:SetDurationCooldown(cooldown)
  end)
end

local function buildBarContainer(region)
  return createNativeContainer(region, function(container, button)
    local bar = region.bar
    local statusBar = CreateFrame("StatusBar", nil, button)
    container.statusBar = statusBar
    statusBar:SetAllPoints(bar)
    statusBar:SetStatusBarTexture(BAR_TEXTURE)
    statusBar:SetFrameLevel(bar:GetFrameLevel())
    bar.nativeBars = bar.nativeBars or {}
    bar.nativeBars.cdm = statusBar
    barRegions[region] = true
    bar:StyleCdmBar()
    applyBarDirection(region, container)
  end)
end

local function selectBuilder(regionType, data)
  if not data then return nil end
  if regionType == "icon" and data.cooldown then
    return buildIconContainer
  end
  if regionType == "aurabar" and Enum.StatusBarTimerDirection then
    return buildBarContainer
  end
  return nil
end

function Display.Modify(region, data)
  releaseNative(region.cdmAuraTimer)
  region.cdmProgressData = data
  region.cdmNativeProgress = nil

  local restricted = isRestricted()
  local builder = selectBuilder(region.regionType or (data and data.regionType), data)

  if not region.cdmAuraTimer and not restricted and Display.IsConfigured(data) and builder and containerAvailable() then
    region.cdmAuraTimer = builder(region)
  end

  local container = region.cdmAuraTimer
  if container and container.statusBar and not restricted then
    region.bar:ShowNativeBar(container.statusBar)
  end

  if not container and restricted and builder and Display.IsConfigured(data) then
    pendingOwners[region] = true
  end
end

function Display.HasContainer(clone)
  if clone.cdmAuraTimer then return true end
  local subRegions = clone.subRegions
  if subRegions then
    for _, subRegion in ipairs(subRegions) do
      if subRegion.cdmAuraTimer then return true end
    end
  end
  return false
end

local function wantsContainer(regionType, data)
  if Display.IsConfigured(data) and selectBuilder(regionType, data) then
    return true
  end
  for _, subData in ipairs(data.subRegions or {}) do
    if subData.type == "subtext" then
      local kind = parseTextToken(subData.text_text)
      if (kind == "p" or kind == "bp") and Private.IsCDMBuffText(subData.text_text, data) then
        return true
      end
    end
  end
  return false
end

function Display.TakeClone(pool, data, loaded)
  local wants = wantsContainer(data.regionType, data)
  local ordinaryIndex, unusedReserveIndex
  for index = #pool, 1, -1 do
    local clone = pool[index]
    if not Display.HasContainer(clone) then
      ordinaryIndex = ordinaryIndex or index
    elseif wants then
      local owner = clone.cdmProgressData
      if owner and owner.uid == data.uid then
        return table.remove(pool, index)
      end
      if not owner or loaded[owner.id] == nil then
        unusedReserveIndex = unusedReserveIndex or index
      end
    end
  end
  local chosen = unusedReserveIndex or ordinaryIndex
  if chosen then
    return table.remove(pool, chosen)
  end
  return nil
end

local function clearSubRegions(clone)
  local subRegions = clone.subRegions
  if not subRegions then return end
  local subRegionTypes = Private.subRegionTypes or {}
  for index = #subRegions, 1, -1 do
    local subRegion = subRegions[index]
    local subRegionType = subRegionTypes[subRegion.type]
    if subRegionType and subRegionType.release then
      subRegionType.release(subRegion)
    end
    subRegions[index] = nil
  end
end

local function prepareSpareTexts(clone, data)
  local textType = Private.subRegionTypes and Private.subRegionTypes.subtext
  if not textType then return end
  clearSubRegions(clone)
  clone.subRegions = clone.subRegions or {}
  for _, subData in ipairs(data.subRegions or {}) do
    if subData.type == "subtext" then
      runGuarded(function()
        local subRegion = textType.acquire()
        clone.subRegions[#clone.subRegions + 1] = subRegion
        textType.modify(clone, subRegion, data, subData, false)
      end)
    end
  end
end

local UNANCHORABLE_FRAME_TYPES = { CUSTOM = true, UNITFRAME = true, NAMEPLATE = true }

local function anchorSpare(clone, data, parent)
  if not parent or parent.regionType == "dynamicgroup" then return end
  if UNANCHORABLE_FRAME_TYPES[data.anchorFrameType] then return end
  clone.id = data.id
  clone:SetOffset(data.xOffset or 0, data.yOffset or 0)
  clone:SetOffsetRelative(0, 0)
  clone:SetOffsetAnim(0, 0)
  runGuarded(function()
    Private.AnchorFrame(data, clone, parent)
  end)
end

local function applySpareAppearance(clone, data)
  clone.inverseDirection = data.inverse
  if clone.bar and data.orientation then
    clone.bar.orientation = data.orientation
  end
  if clone.UpdateStatusBarTexture and data.barColor then
    clone.textureSource = data.textureSource
    clone.texture = data.texture
    clone.textureInput = data.textureInput
    clone:UpdateStatusBarTexture()
    local color = data.barColor
    clone.color_r, clone.color_g, clone.color_b, clone.color_a = color[1], color[2], color[3], color[4]
    clone.barColor2 = data.barColor2
    clone.enableGradient = data.enableGradient
    clone.gradientOrientation = data.gradientOrientation
    clone:UpdateForegroundColor()
  end
  clone.cooldownSwipe = data.cooldownSwipe
  clone.cooldownEdge = data.cooldownEdge
  clone.cdmConfiguredHideNumbers = data.cooldownTextDisabled
end

function Display.AddSpareClone(pool, regionType, data, create, parent)
  if isRestricted() or not wantsContainer(regionType, data) or not containerAvailable() then return end

  for _, existing in ipairs(pool) do
    local owner = existing.cdmProgressData
    if owner and owner.uid == data.uid and Display.HasContainer(existing) then
      Private.BlizzardAuraDisplay.Release(existing, true)
      prepareSpareTexts(existing, data)
      anchorSpare(existing, data, parent)
      return
    end
  end

  local clone
  for index = #pool, 1, -1 do
    if not Display.HasContainer(pool[index]) then
      clone = table.remove(pool, index)
      Private.BlizzardAuraDisplay.Release(clone, true)
      clone:SetParent(WeakAurasFrame)
      clone:ClearAllPoints()
      clone:SetPoint("CENTER", UIParent, "CENTER")
      break
    end
  end
  clone = clone or create()
  clone.regionType = regionType
  clone:Hide()
  applySpareAppearance(clone, data)
  Display.Modify(clone, data)
  clone.cdmProgressData = data
  prepareSpareTexts(clone, data)

  if not Display.HasContainer(clone) then
    clearSubRegions(clone)
    clone:Hide()
    clone.cdmProgressData = nil
    pool[#pool + 1] = clone
    return
  end

  anchorSpare(clone, data, parent)
  pool[#pool + 1] = clone
end

function Display.SyncFrameLevels(region)
  local container = region.cdmAuraTimer
  if not container then return end
  local reference = region.cooldown or region.bar
  container.frame:SetFrameLevel(reference:GetFrameLevel())
  if container.statusBar and not isRestricted() then
    container.statusBar:SetFrameLevel(region.bar:GetFrameLevel())
  end
end

function Display.Style(region, initializing)
  local container = initializing or region.cdmAuraTimer
  if not container then return end
  Display.SyncFrameLevels(region)
  local cooldown = container.cooldown
  if not cooldown or not isStylable(cooldown, initializing) then return end
  cooldown:SetDrawSwipe(region.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(region.cooldownEdge == true)
  local regionInverse = region.inverseDirection and true or false
  local cooldownInverse = (region.cooldown and region.cooldown.inverse) and true or false
  cooldown:SetReverse(regionInverse == cooldownInverse)
  cooldown:SetHideCountdownNumbers(region.cdmConfiguredHideNumbers == true)
end

function Display.Update(region)
  region.cdmNativeProgress = nil
  local unit, filter, spellIDs = Display.ResolveNativeSource(resolveState(region))
  local data = region.cdmProgressData
  local builder = selectBuilder(region.regionType or (data and data.regionType), data)
  if not unit or not builder then
    releaseNative(region.cdmAuraTimer)
    return
  end

  local container = region.cdmAuraTimer
  if not container then
    if isRestricted() then
      pendingOwners[region] = true
      return
    end
    if not containerAvailable() then return end
    container = builder(region)
    region.cdmAuraTimer = container
  end

  if container.cooldown then
    region.cdmNativeProgress = true
    if region.cooldown then
      region.cooldown:Hide()
    end
    Display.Style(region)
  elseif container.statusBar then
    applyBarDirection(region, container)
    region.bar:ShowNativeBar(container.statusBar)
    region.cdmNativeProgress = true
  end

  attachNative(container, unit, filter, spellIDs)
end

local function styleTextInto(subRegion, container, initializing)
  local config = subRegion.cdmTextConfig
  if not container or not config then return end
  container.stylePending = true
  local nativeText = container.text
  if not nativeText or not isStylable(nativeText, initializing) then return end
  local font, size, flags = subRegion.text:GetFont()
  if not font then return end
  Private.ApplyTextFont(nativeText, nil, font, size, flags,
    config.text_shadowColor, config.text_shadowXOffset, config.text_shadowYOffset)
  nativeText:SetTextColor(
    subRegion.color_anim_r or subRegion.color_r or 1,
    subRegion.color_anim_g or subRegion.color_g or 1,
    subRegion.color_anim_b or subRegion.color_b or 1,
    subRegion.color_anim_a or subRegion.color_a or 1)
  nativeText:SetJustifyH(config.text_justify or "CENTER")
  local fixedWidth = config.text_automaticWidth == "Fixed"
  nativeText:SetWidth(fixedWidth and config.text_fixedWidth or 0)
  local wrap = not fixedWidth or config.text_wordWrap == "WordWrap"
  nativeText:SetWordWrap(wrap)
  nativeText:SetNonSpaceWrap(wrap)
  if subRegion.AnchorNativeText then
    subRegion:AnchorNativeText(nativeText)
  end
  container.stylePending = false
end

function Display.StyleText(subRegion, initializing)
  styleTextInto(subRegion, initializing or subRegion.cdmAuraTimer, initializing ~= nil)
end

local function createNativeText(container, button, subRegion)
  local nativeText = button:CreateFontString(nil, "OVERLAY")
  container.text = nativeText
  local font, size, flags = subRegion.text:GetFont()
  if font then
    nativeText:SetFont(font, size, flags)
  end
  styleTextInto(subRegion, container, true)
  return nativeText
end

local function prepareOwnTimerText(subRegion)
  if isRestricted() or not subRegion.text:GetFont() then return end
  local config = subRegion.cdmTextConfig
  if not config then return end
  local kind = parseTextToken(config.text_text)
  if kind ~= "p" and kind ~= "bp" then return end
  local signature, options = ownTimerFormat(config)

  local existing = subRegion.cdmAuraTimer
  if existing then
    if existing.button and existing.format ~= signature and not InCombatLockdown()
      and existing.text and isStylable(existing.text) then
      existing.button:SetDurationText(existing.text, options)
      existing.format = signature
    end
    return
  end

  if not containerAvailable() then return end
  subRegion.cdmAuraTimer = createNativeContainer(subRegion, function(container, button)
    local nativeText = createNativeText(container, button, subRegion)
    button:SetDurationText(nativeText, options)
    container.format = signature
  end)
end

local function showOwnTimerText(subRegion, config, unit, filter, spellIDs)
  subRegion.cdmTextConfig = config
  if not subRegion.cdmAuraTimer then
    prepareOwnTimerText(subRegion)
  end
  local container = subRegion.cdmAuraTimer
  if not container then return false end
  if container.stylePending then
    styleTextInto(subRegion, container, false)
  end
  container.frame:SetFrameLevel(subRegion:GetFrameLevel())
  subRegion.cdmNativeText = true
  subRegion.text:SetText("")
  attachNative(container, unit, filter, spellIDs)
  return true
end

local function isLinkedTrigger(parentData, triggerIndex)
  if not triggerIndex or not parentData or type(parentData.triggers) ~= "table" then return false end
  local entry = parentData.triggers[triggerIndex]
  local trigger = entry and entry.trigger
  if not trigger or trigger.type ~= "secretAura" then return false end
  local blizzardDisplay = Private.BlizzardAuraDisplay
  if blizzardDisplay.Enabled(parentData) then return false end
  return blizzardDisplay.IsSingleUnit(trigger) and true or false
end

local function createLinkedText(subRegion, kind, triggerIndex)
  if not containerAvailable() then return nil end
  local linked = createNativeContainer(subRegion, function(container, button)
    local nativeText = createNativeText(container, button, subRegion)
    if kind == "s" then
      button:SetApplicationCount(nativeText)
      container.format = "count"
    else
      local signature, options = durationFormat(subRegion.cdmTextConfig, triggerIndex)
      button:SetDurationText(nativeText, options)
      container.format = signature
    end
  end)
  subRegion.linkedAuraTexts = subRegion.linkedAuraTexts or {}
  subRegion.linkedAuraTexts[kind] = linked
  return linked
end

local function prepareLinkedText(subRegion, parentData, kind, triggerIndex)
  if kind ~= "p" and kind ~= "s" then return end
  if isRestricted() or not subRegion.text:GetFont() then return end
  if not isLinkedTrigger(parentData, triggerIndex) then return end
  if not (subRegion.linkedAuraTexts and subRegion.linkedAuraTexts[kind]) then
    createLinkedText(subRegion, kind, triggerIndex)
  end
end

local function releaseLinkedTexts(subRegion, keptKind)
  local linkedTexts = subRegion.linkedAuraTexts
  if not linkedTexts then return end
  local keptWanted = false
  for kind, linked in pairs(linkedTexts) do
    if kind ~= keptKind then
      releaseNative(linked)
    elseif linked.wanted then
      keptWanted = true
    end
  end
  if not keptWanted then
    linkedTextOwners[subRegion] = nil
  end
end

local function showLinkedText(parent, subRegion, config, kind, triggerIndex)
  if kind ~= "p" and kind ~= "s" then return false end
  local parentData = parent.id and WeakAuras.GetData(parent.id)
  if not parentData or not isLinkedTrigger(parentData, triggerIndex) then return false end
  if WeakAuras.IsOptionsOpen() then return false end

  local trigger = parentData.triggers[triggerIndex].trigger
  local unit = trigger.unit
  if unit == "member" then
    unit = Private.BlizzardAuraDisplay.SpecificUnit(trigger)
  end
  if not unit then return false end

  subRegion.cdmTextConfig = config
  local linked = subRegion.linkedAuraTexts and subRegion.linkedAuraTexts[kind]
  if not linked then
    if isRestricted() then
      pendingOwners[subRegion] = true
      subRegion.text:SetText("")
      return true
    end
    linked = createLinkedText(subRegion, kind, triggerIndex)
    if not linked then return false end
  end
  releaseLinkedTexts(subRegion, kind)

  if linked.stylePending and not InCombatLockdown() and linked.text and isStylable(linked.text) then
    styleTextInto(subRegion, linked, false)
    if kind == "p" then
      local signature, options = durationFormat(config, triggerIndex)
      if linked.format ~= signature then
        linked.button:SetDurationText(linked.text, options)
        linked.format = signature
      end
    end
  end

  local frame = linked.frame
  if linked.boundUnit ~= unit or linked.boundData ~= parentData or linked.boundIndex ~= triggerIndex then
    local blizzardDisplay = Private.BlizzardAuraDisplay
    local proxy = setmetatable({ progressSource = { triggerIndex, "" } }, { __index = parentData })
    frame:SetEnabled(false)
    frame:SetUnit(unit)
    frame:SetAuraSlotFilterString(SLOT_NAME, blizzardDisplay.FilterString(trigger))
    frame:SetAuraSlotCandidateFilters(SLOT_NAME, blizzardDisplay.CandidateFilters(proxy))
    frame:SetAuraSlotSortMethod(SLOT_NAME, blizzardDisplay.SortOrder(proxy, trigger))
    linked.boundUnit = unit
    linked.boundData = parentData
    linked.boundIndex = triggerIndex
  end
  frame:SetFrameLevel(subRegion:GetFrameLevel())
  linked.wanted = true
  if subRegion:IsVisible() then
    frame:SetEnabled(true)
  end
  subRegion.text:SetText("")
  linkedTextOwners[subRegion] = true
  pendingOwners[subRegion] = nil
  return true
end

function Display.ModifyText(parent, subRegion, parentData, config)
  subRegion.cdmTextConfig = config
  Display.StyleText(subRegion)
  if subRegion.linkedAuraTexts then
    for _, linked in pairs(subRegion.linkedAuraTexts) do
      linked.boundData = nil
      linked.stylePending = true
    end
  end

  local kind, triggerIndex = parseTextToken(config.text_text)
  prepareLinkedText(subRegion, parentData, kind, triggerIndex)

  if (kind == "p" or kind == "bp") and Private.IsCDMBuffText(config.text_text, parentData) then
    if isRestricted() then
      pendingOwners[subRegion] = OWN_TIMER_REASON
    end
    prepareOwnTimerText(subRegion)
  end
end

function Display.HideText(subRegion)
  releaseNative(subRegion.cdmAuraTimer)
  if subRegion.linkedAuraTexts then
    for _, linked in pairs(subRegion.linkedAuraTexts) do
      releaseNative(linked)
    end
  end
  linkedTextOwners[subRegion] = nil
  pendingOwners[subRegion] = nil
  subRegion.cdmNativeText = nil
end

function Display.UpdateText(parent, subRegion, config, kind, explicitTrigger)
  if not kind then
    Display.HideText(subRegion)
    return false
  end

  local state = resolveState(parent, explicitTrigger)
  if not state or not state.cdmBuff then
    releaseNative(subRegion.cdmAuraTimer)
    subRegion.cdmNativeText = nil
    if subRegion.text:GetFont() and showLinkedText(parent, subRegion, config, kind, explicitTrigger) then
      return true
    end
    releaseLinkedTexts(subRegion)
    return false
  end

  releaseLinkedTexts(subRegion)
  if not subRegion.text:GetFont() then return true end

  local unit, filter, spellIDs = Display.ResolveNativeSource(state)
  local wantsOwnTimer = unit ~= nil and (kind == "p" or kind == "bp")
  if wantsOwnTimer and showOwnTimerText(subRegion, config, unit, filter, spellIDs) then
    return true
  end

  Display.HideText(subRegion)
  if wantsOwnTimer then
    pendingOwners[subRegion] = OWN_TIMER_REASON
  end
  Private.CopyCDMCountdownText(subRegion.text, state, kind)
  if subRegion.UpdateAnchorOnTextChange then
    subRegion:UpdateAnchorOnTextChange()
  end
  return true
end

function Display.ReleaseIndicator(subRegion)
  if subRegion.preview then
    subRegion.preview:Hide()
  end
  if subRegion.dispelBorder then
    subRegion.dispelBorder:Hide()
  end
  if subRegion.dispelEdges then
    Private.DispelTypeDisplay.Hide(subRegion.dispelEdges)
  end
end

function Display.ModifyIndicator(parent, subRegion)
  Display.ReleaseIndicator(subRegion)
end

function Display.UpdateIndicator(parent, subRegion)
  local state = resolveState(parent)
  local dispelName
  if subRegion.visible and state and state.show and state.cdmBuff then
    if state.cdmTextPreview then
      dispelName = "Magic"
    else
      dispelName = state.cdmDispelName
    end
  end
  Display.ReleaseIndicator(subRegion)
  if isSecret(dispelName) or type(dispelName) ~= "string" or dispelName == "" then return end

  if subRegion.dispelEdges then
    for _, edge in ipairs(subRegion.dispelEdges) do
      AuraUtil.SetAuraBorderColor(edge, dispelName)
      edge:Show()
    end
  elseif subRegion.preview then
    AuraUtil.SetAuraDispelTypeIcon(subRegion.preview, dispelName)
    subRegion.preview:SetVertexColor(1, 1, 1, 1)
    subRegion.preview:Show()
  end
end

local function finishPendingOwner(owner, reason)
  if reason == OWN_TIMER_REASON and owner.cdmTextConfig then
    runGuarded(function()
      prepareOwnTimerText(owner)
    end)
  end
  if owner.cdmProgressData and not owner.cdmAuraTimer then
    runGuarded(function()
      Display.Modify(owner, owner.cdmProgressData)
    end)
  end
  if owner.Update and owner:IsVisible() then
    runGuarded(function()
      owner:Update()
    end)
  end
end

Private.callbacks:RegisterCallback("RestrictionChanged", function(_, restricted)
  if restricted then return end
  if Private.QueueCDMRefresh then
    Private.QueueCDMRefresh()
  end
  for region in pairs(barRegions) do
    runGuarded(function()
      region.bar:StyleCdmBar()
    end)
  end
  local waiting = {}
  for owner, reason in pairs(pendingOwners) do
    waiting[#waiting + 1] = { owner = owner, reason = reason }
  end
  for _, entry in ipairs(waiting) do
    pendingOwners[entry.owner] = nil
  end
  for _, entry in ipairs(waiting) do
    finishPendingOwner(entry.owner, entry.reason)
  end
end)

local observer = CreateFrame("Frame")
for _, eventName in ipairs(OBSERVED_EVENTS) do
  observer:RegisterEvent(eventName)
end
observer:SetScript("OnEvent", function()
  for owner in pairs(linkedTextOwners) do
    if owner.linkedAuraTexts then
      for _, linked in pairs(owner.linkedAuraTexts) do
        if linked.wanted then
          linked.frame:UpdateAllAuras()
        end
      end
    end
  end
end)

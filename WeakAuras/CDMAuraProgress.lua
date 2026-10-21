-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = {}
Private.CDMAuraProgress = Display

local IsSecret = Private.IsSecret

local SLOT_NAME = "Timer"
local OWN_REASON = "own"
local BAR_TEXTURE = [[Interface\AddOns\WeakAuras\Media\Textures\Square_FullWhite]]
local UNANCHORED_TYPES = { CUSTOM = true, UNITFRAME = true, NAMEPLATE = true }
local OBSERVED_EVENTS = {
  "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_PET", "UNIT_TARGET", "PLAYER_ENTERING_WORLD",
}

local pendingOwners = setmetatable({}, { __mode = "k" })
local nativeBarRegions = setmetatable({}, { __mode = "k" })
local linkedTextOwners = setmetatable({}, { __mode = "k" })

local function Restricted()
  return WeakAuras.IsRestricted()
end

local function Protected(func, ...)
  local count, args = select("#", ...), { ... }
  xpcall(function() func(unpack(args, 1, count)) end, geterrorhandler())
end

local function MarkPending(owner, reason)
  if pendingOwners[owner] ~= OWN_REASON then
    pendingOwners[owner] = reason or true
  end
end

local function Accessible(widget)
  local check = widget and widget.CanBeAccessedInContext
  if not check then return false end
  local ok, result = pcall(check, widget)
  if not ok or IsSecret(result) then return false end
  return result == true
end

local function HasFont(subRegion)
  return subRegion.text ~= nil and subRegion.text:GetFont() ~= nil
end

local function ResolveState(source, index)
  if not source then return nil end
  if index == nil then
    local progressSource = source.progressSource
    index = progressSource and progressSource[1] or -1
  end
  if index > 0 then
    return source.states and source.states[index]
  elseif index == -1 then
    return source.state
  end
end

local function IsCDMTrigger(trigger)
  return type(trigger) == "table" and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff"
end

local function ContainerAvailable()
  if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
    C_AddOns.LoadAddOn("Blizzard_AuraContainer")
  end
  return CustomAuraContainerAuraProcessingPolicy ~= nil
end

local function ReleaseContainer(container)
  if not container or not container.wanted then return end
  container.wanted = false
  container.frame:SetEnabled(false)
end

local function CreateContainer(owner, finish)
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
      finish(container, owner, button)
      Private.SnapLateTextures(button)
    end,
  })
  owner:HookScript("OnHide", function()
    frame:SetEnabled(false)
  end)
  owner:HookScript("OnShow", function()
    if container.wanted then frame:SetEnabled(true) end
  end)
  return container
end

local function ApplyBarDirection(container, region)
  local button = container.button
  if not button then return end
  if container.direction ~= nil and Restricted() then return end
  local directions = Enum.StatusBarTimerDirection
  local direction = region.inverseDirection and directions.ElapsedTime or directions.RemainingTime
  if direction == container.direction then return end
  container.direction = direction
  button:SetDurationBar(container.statusBar, { direction = direction })
end

local function FinishIcon(container, region, button)
  local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
  container.cooldown = cooldown
  cooldown:SetAllPoints(region.icon)
  cooldown:SetDrawBling(false)
  cooldown:SetFrameLevel(button:GetFrameLevel())
  Display.Style(region, container)
  button:SetDurationCooldown(cooldown)
end

local function FinishBar(container, region, button)
  local bar = region.bar
  local statusBar = CreateFrame("StatusBar", nil, button)
  container.statusBar = statusBar
  statusBar:SetAllPoints(bar)
  statusBar:SetStatusBarTexture(BAR_TEXTURE)
  statusBar:SetFrameLevel(bar:GetFrameLevel())
  bar.nativeBars = bar.nativeBars or {}
  bar.nativeBars.cdm = statusBar
  nativeBarRegions[region] = true
  bar:StyleCdmBar()
  ApplyBarDirection(container, region)
end

local function FindBuilder(regionType, data)
  if not data then return nil end
  if regionType == "icon" then
    return data.cooldown and FinishIcon or nil
  elseif regionType == "aurabar" then
    return Enum and Enum.StatusBarTimerDirection and FinishBar or nil
  end
end

local function NeedsContainer(data)
  if not data then return false end
  if Display.IsConfigured(data) and FindBuilder(data.regionType, data) then return true end
  if type(data.subRegions) ~= "table" then return false end
  for _, subData in ipairs(data.subRegions) do
    if subData.type == "subtext" then
      local kind = Private.ParseCDMText(subData.text_text or "")
      if (kind == "p" or kind == "bp") and Private.IsCDMBuffText(subData.text_text, data) then
        return true
      end
    end
  end
  return false
end

local function BindSource(container, unit, filter, spellIDs)
  local included, sorted = {}, {}
  for _, spellID in ipairs(spellIDs) do
    if not IsSecret(spellID) and type(spellID) == "number" and spellID > 0 and not included[spellID] then
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

function Display.ResolveNativeSource(state)
  if CustomAuraContainerAuraProcessingPolicy == nil then return end
  if not state or not state.cdmBuff or not state.show then return end
  if state.cdmTextPreview or state.cdmAuraTotem then return end
  if state.auraActive == false or state.progressType ~= "static" then return end
  local spellIDs = state.cdmAuraRenderSpellIDs
  if type(spellIDs) ~= "table" or next(spellIDs) == nil then return end
  local unit, rawFilter = state.cdmAuraRenderUnit, state.cdmAuraFilter
  local filter = rawFilter or "HELPFUL"
  if unit == "target" and rawFilter == "HARMFUL|PLAYER" then
    return unit, filter, spellIDs
  end
  if unit == "player" and filter == "HELPFUL" and Restricted() then
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
    if index < 0 and #triggers == 1 then index = 1 end
  end
  local entry = triggers[index]
  return type(entry) == "table" and IsCDMTrigger(entry.trigger)
end

function Display.IsInactive(region)
  local state = ResolveState(region)
  if state and state.cdmBuff and state.auraActive == false then return true end
  return false
end

function Display.Modify(region, data)
  local container = region.cdmAuraTimer
  ReleaseContainer(container)
  region.cdmProgressData = data
  region.cdmNativeProgress = nil
  local finish = FindBuilder(region.regionType or (data and data.regionType), data)
  if finish and not container and Display.IsConfigured(data) then
    if Restricted() then
      MarkPending(region)
    elseif ContainerAvailable() then
      container = CreateContainer(region, finish)
      region.cdmAuraTimer = container
    end
  end
  if container and container.statusBar and not Restricted() then
    region.bar:ShowNativeBar(container.statusBar)
  end
end

function Display.HasContainer(clone)
  if clone.cdmAuraTimer then return true end
  if clone.subRegions then
    for _, subRegion in ipairs(clone.subRegions) do
      if subRegion.cdmAuraTimer then return true end
    end
  end
  return false
end

function Display.TakeClone(pool, data, loaded)
  local wants = NeedsContainer(data)
  local plainIndex, spareIndex
  for index = #pool, 1, -1 do
    local clone = pool[index]
    if not Display.HasContainer(clone) then
      plainIndex = plainIndex or index
    elseif wants then
      local ownerData = clone.cdmProgressData
      if ownerData and ownerData.uid == data.uid then
        return table.remove(pool, index)
      end
      if not spareIndex and (not ownerData or loaded[ownerData.id] == nil) then
        spareIndex = index
      end
    end
  end
  local index = spareIndex or plainIndex
  if index then
    return table.remove(pool, index)
  end
end

local function ClearSubRegions(clone)
  local subRegions = clone.subRegions
  if not subRegions then return end
  for index = #subRegions, 1, -1 do
    local subRegion = subRegions[index]
    local subRegionType = subRegion.type and Private.subRegionTypes[subRegion.type]
    if subRegionType and subRegionType.release then
      subRegionType.release(subRegion)
    end
    subRegions[index] = nil
  end
end

local function RebuildTexts(clone, data)
  local subtext = Private.subRegionTypes.subtext
  if not subtext then return end
  ClearSubRegions(clone)
  clone.subRegions = clone.subRegions or {}
  if type(data.subRegions) ~= "table" then return end
  for _, subData in ipairs(data.subRegions) do
    if subData.type == "subtext" then
      Protected(function()
        local subRegion = subtext.acquire()
        subRegion.type = "subtext"
        table.insert(clone.subRegions, subRegion)
        subtext.modify(clone, subRegion, data, subData, false)
      end)
    end
  end
end

local function PrepareAnchorTarget(data)
  if data.anchorFrameType ~= "SELECTFRAME" or type(data.anchorFrameFrame) ~= "string" then return end
  local target = data.anchorFrameFrame:match("^WeakAuras:(.+)$")
  if not target or target == data.id then return end
  if not WeakAuras.GetData(target) or WeakAuras.GetRegion(target) then return end
  local region = Private.EnsureRegion(target)
  if region and region.blizzardAuraDisplay and not Private.loaded[target] and not WeakAuras.IsOptionsOpen() then
    Private.BlizzardAuraDisplay.Release(region)
  end
end

local function AnchorSpare(clone, data, parent)
  if not parent or parent.regionType == "dynamicgroup" or UNANCHORED_TYPES[data.anchorFrameType] then return end
  clone.id = data.id
  clone:SetOffset(data.xOffset or 0, data.yOffset or 0)
  clone:SetOffsetRelative(0, 0)
  clone:SetOffsetAnim(0, 0)
  Protected(PrepareAnchorTarget, data)
  Protected(Private.AnchorFrame, data, clone, parent)
end

local function ApplySpareAppearance(clone, data)
  clone.inverseDirection = data.inverse
  if clone.bar and data.orientation then
    clone.bar.orientation = data.orientation
  end
  local color = data.barColor
  if clone.UpdateStatusBarTexture and color then
    clone.textureSource, clone.texture, clone.textureInput = data.textureSource, data.texture, data.textureInput
    clone:UpdateStatusBarTexture()
    clone.color_r, clone.color_g, clone.color_b, clone.color_a = color[1], color[2], color[3], color[4]
    clone.barColor2, clone.enableGradient = data.barColor2, data.enableGradient
    clone.gradientOrientation = data.gradientOrientation
    clone:UpdateForegroundColor()
  end
  clone.cooldownSwipe, clone.cooldownEdge = data.cooldownSwipe, data.cooldownEdge
  clone.cdmConfiguredHideNumbers = data.cooldownTextDisabled
end

function Display.AddSpareClone(pool, regionType, data, create, parent)
  if Restricted() or not NeedsContainer(data) or not ContainerAvailable() then return end
  for _, clone in ipairs(pool) do
    if Display.HasContainer(clone) and clone.cdmProgressData and clone.cdmProgressData.uid == data.uid then
      Private.BlizzardAuraDisplay.Release(clone, true)
      RebuildTexts(clone, data)
      AnchorSpare(clone, data, parent)
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
  ApplySpareAppearance(clone, data)
  Display.Modify(clone, data)
  clone.cdmProgressData = data
  RebuildTexts(clone, data)
  if not Display.HasContainer(clone) then
    ClearSubRegions(clone)
    clone:Hide()
    clone.cdmProgressData = nil
    table.insert(pool, clone)
    return
  end
  AnchorSpare(clone, data, parent)
  table.insert(pool, clone)
end

function Display.SyncFrameLevels(region)
  local container = region.cdmAuraTimer
  if not container then return end
  local reference = region.cooldown or region.bar
  if reference then
    container.frame:SetFrameLevel(reference:GetFrameLevel())
  end
  if container.statusBar and not Restricted() then
    container.statusBar:SetFrameLevel(region.bar:GetFrameLevel())
  end
end

function Display.Style(region, initializing)
  local container = initializing or region.cdmAuraTimer
  if not container then return end
  Display.SyncFrameLevels(region)
  local cooldown = container.cooldown
  if not cooldown then return end
  if not initializing and not Accessible(cooldown) then return end
  local regionInverse = region.cooldown and region.cooldown.inverse
  cooldown:SetDrawSwipe(region.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(region.cooldownEdge == true)
  cooldown:SetHideCountdownNumbers(region.cdmConfiguredHideNumbers == true)
  cooldown:SetReverse((not region.inverseDirection) == (not regionInverse))
end

function Display.Update(region)
  region.cdmNativeProgress = nil
  local data = region.cdmProgressData
  local unit, filter, spellIDs = Display.ResolveNativeSource(ResolveState(region))
  local finish = FindBuilder(region.regionType or (data and data.regionType), data)
  local container = region.cdmAuraTimer
  if not unit or not finish then
    ReleaseContainer(container)
    return
  end
  if not container then
    if Restricted() then
      MarkPending(region)
      return
    end
    if not ContainerAvailable() then return end
    container = CreateContainer(region, finish)
    region.cdmAuraTimer = container
  end
  if container.cooldown then
    region.cdmNativeProgress = true
    if region.cooldown then region.cooldown:Hide() end
    Display.Style(region)
  elseif container.statusBar then
    ApplyBarDirection(container, region)
    region.bar:ShowNativeBar(container.statusBar)
    region.cdmNativeProgress = true
  end
  BindSource(container, unit, filter, spellIDs)
end

local function ColorChannel(subRegion, channel)
  return subRegion["color_anim_" .. channel] or subRegion["color_" .. channel] or 1
end

function Display.StyleText(subRegion, initializing)
  local container = initializing or subRegion.cdmAuraTimer
  local config = subRegion.cdmTextConfig
  if not container or not config then return end
  container.stylePending = true
  local nativeText = container.text
  if not nativeText or (not initializing and not Accessible(nativeText)) then return end
  local font, size, flags = subRegion.text:GetFont()
  if not font then return end
  Private.ApplyTextFont(nativeText, nil, font, size, flags,
    config.text_shadowColor, config.text_shadowXOffset, config.text_shadowYOffset)
  nativeText:SetTextColor(ColorChannel(subRegion, "r"), ColorChannel(subRegion, "g"),
    ColorChannel(subRegion, "b"), ColorChannel(subRegion, "a"))
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

local function DurationFormat(config, triggerIndex)
  local prefix = "text_text_format_" .. (triggerIndex and (triggerIndex .. ".") or "") .. "p_"
  local timeFormat = config[prefix .. "time_format"] or 0
  if timeFormat == -1 then
    return "default", function() return nil end
  end
  local rounding = config[prefix .. "time_legacy_floor"] and 0 or 99
  local threshold = config[prefix .. "time_dynamic_threshold"] or 60
  local precision = config[prefix .. "time_precision"] or 1
  local dynamic = timeFormat == -2
  local signature = table.concat({ "format", rounding, threshold, precision, tostring(dynamic), timeFormat }, "|")
  return signature, function()
    return { textFormatter = Private.GetDurationTextFormatter(rounding, threshold, precision, dynamic, timeFormat) }
  end
end

local function OwnTimerFormat(config, kind)
  if kind == "bp" then
    return "bp", function() return { textFormatter = Private.GetDurationTextFormatter(99, 0, 0) } end
  end
  local _, triggerIndex = Private.ParseCDMText(config.text_text or "")
  return DurationFormat(config, triggerIndex)
end

local function CreateNativeText(container, subRegion, button)
  local nativeText = button:CreateFontString(nil, "OVERLAY")
  container.text = nativeText
  local font, size, flags = subRegion.text:GetFont()
  if font then
    nativeText:SetFont(font, size, flags)
  end
  Display.StyleText(subRegion, container)
  return nativeText
end

local function PrepareOwnTimer(subRegion, kind)
  local config = subRegion.cdmTextConfig
  if Restricted() or not HasFont(subRegion) or not config then return end
  kind = kind or Private.ParseCDMText(config.text_text or "")
  if kind ~= "p" and kind ~= "bp" then return end
  local signature, makeOptions = OwnTimerFormat(config, kind)
  local container = subRegion.cdmAuraTimer
  if container then
    local button, nativeText = container.button, container.text
    if button and container.format ~= signature and not InCombatLockdown() and nativeText and Accessible(nativeText) then
      button:SetDurationText(nativeText, makeOptions())
      container.format = signature
    end
    return
  end
  if not ContainerAvailable() then return end
  subRegion.cdmAuraTimer = CreateContainer(subRegion, function(created, owner, button)
    local nativeText = CreateNativeText(created, owner, button)
    button:SetDurationText(nativeText, makeOptions())
    created.format = signature
  end)
end

local function LinkedTrigger(parentData, triggerIndex)
  if not triggerIndex or not parentData or type(parentData.triggers) ~= "table" then return nil end
  local entry = parentData.triggers[triggerIndex]
  local trigger = type(entry) == "table" and entry.trigger
  if type(trigger) ~= "table" or trigger.type ~= "secretAura" then return nil end
  if Private.BlizzardAuraDisplay.Enabled(parentData) or not Private.BlizzardAuraDisplay.IsSingleUnit(trigger) then
    return nil
  end
  return trigger
end

local function CreateLinkedText(subRegion, kind, triggerIndex)
  if not ContainerAvailable() then return nil end
  local container = CreateContainer(subRegion, function(created, owner, button)
    local nativeText = CreateNativeText(created, owner, button)
    if kind == "s" then
      button:SetApplicationCount(nativeText)
      created.format = "count"
    else
      local signature, makeOptions = DurationFormat(owner.cdmTextConfig, triggerIndex)
      button:SetDurationText(nativeText, makeOptions())
      created.format = signature
    end
  end)
  subRegion.linkedAuraTexts = subRegion.linkedAuraTexts or {}
  subRegion.linkedAuraTexts[kind] = container
  return container
end

local function PrepareLinkedText(subRegion, parentData, kind, triggerIndex)
  if kind ~= "p" and kind ~= "s" then return end
  if Restricted() or not HasFont(subRegion) or not LinkedTrigger(parentData, triggerIndex) then return end
  if subRegion.linkedAuraTexts and subRegion.linkedAuraTexts[kind] then return end
  CreateLinkedText(subRegion, kind, triggerIndex)
end

local function ReleaseLinkedTexts(subRegion, keptKind)
  local linked = subRegion.linkedAuraTexts
  if linked then
    for kind, container in pairs(linked) do
      if kind ~= keptKind then ReleaseContainer(container) end
    end
  end
  local kept = linked and keptKind and linked[keptKind]
  if not (kept and kept.wanted) then
    linkedTextOwners[subRegion] = nil
  end
end

local function ShowLinkedText(parent, subRegion, config, kind, triggerIndex)
  if kind ~= "p" and kind ~= "s" then return false end
  local parentData = parent.id and WeakAuras.GetData(parent.id)
  if not parentData then return false end
  local trigger = LinkedTrigger(parentData, triggerIndex)
  if not trigger or WeakAuras.IsOptionsOpen() then return false end
  local unit = trigger.unit
  if unit == "member" then
    unit = Private.BlizzardAuraDisplay.SpecificUnit(trigger)
  end
  if not unit then return false end
  subRegion.cdmTextConfig = config
  local container = subRegion.linkedAuraTexts and subRegion.linkedAuraTexts[kind]
  if not container then
    if Restricted() then
      MarkPending(subRegion)
      subRegion.text:SetText("")
      return true
    end
    container = CreateLinkedText(subRegion, kind, triggerIndex)
    if not container then return false end
  end
  ReleaseLinkedTexts(subRegion, kind)
  local nativeText = container.text
  if container.stylePending and not InCombatLockdown() and nativeText and Accessible(nativeText) then
    Display.StyleText(subRegion, container)
    if kind == "p" and container.button then
      local signature, makeOptions = DurationFormat(config, triggerIndex)
      if signature ~= container.format then
        container.button:SetDurationText(nativeText, makeOptions())
        container.format = signature
      end
    end
  end
  local frame = container.frame
  if container.boundUnit ~= unit or container.boundData ~= parentData or container.boundIndex ~= triggerIndex then
    local proxy = setmetatable({ progressSource = { triggerIndex, "" } }, { __index = parentData })
    frame:SetEnabled(false)
    frame:SetUnit(unit)
    frame:SetAuraSlotFilterString(SLOT_NAME, Private.BlizzardAuraDisplay.FilterString(trigger))
    frame:SetAuraSlotCandidateFilters(SLOT_NAME, Private.BlizzardAuraDisplay.CandidateFilters(proxy))
    frame:SetAuraSlotSortMethod(SLOT_NAME, Private.BlizzardAuraDisplay.SortOrder(proxy, trigger))
    container.boundUnit, container.boundData, container.boundIndex = unit, parentData, triggerIndex
  end
  frame:SetFrameLevel(subRegion:GetFrameLevel())
  container.wanted = true
  if subRegion:IsVisible() then
    frame:SetEnabled(true)
  end
  subRegion.text:SetText("")
  linkedTextOwners[subRegion] = true
  pendingOwners[subRegion] = nil
  return true
end

local function ShowOwnTimer(subRegion, config, kind, unit, filter, spellIDs)
  subRegion.cdmTextConfig = config
  if not subRegion.cdmAuraTimer then
    PrepareOwnTimer(subRegion, kind)
  end
  local container = subRegion.cdmAuraTimer
  if not container then return false end
  if container.stylePending then
    Display.StyleText(subRegion)
  end
  container.frame:SetFrameLevel(subRegion:GetFrameLevel())
  subRegion.cdmNativeText = true
  subRegion.text:SetText("")
  BindSource(container, unit, filter, spellIDs)
  return true
end

function Display.ModifyText(parent, subRegion, parentData, config)
  subRegion.cdmTextConfig = config
  Display.StyleText(subRegion)
  if subRegion.linkedAuraTexts then
    for _, container in pairs(subRegion.linkedAuraTexts) do
      container.boundData = nil
      container.stylePending = true
    end
  end
  local kind, triggerIndex = Private.ParseCDMText(config.text_text or "")
  PrepareLinkedText(subRegion, parentData, kind, triggerIndex)
  if (kind == "p" or kind == "bp") and Private.IsCDMBuffText(config.text_text, parentData) then
    if Restricted() then
      MarkPending(subRegion, OWN_REASON)
    end
    PrepareOwnTimer(subRegion, kind)
  end
end

function Display.HideText(subRegion)
  ReleaseContainer(subRegion.cdmAuraTimer)
  if subRegion.linkedAuraTexts then
    for _, container in pairs(subRegion.linkedAuraTexts) do
      ReleaseContainer(container)
    end
  end
  linkedTextOwners[subRegion] = nil
  pendingOwners[subRegion] = nil
  subRegion.cdmNativeText = nil
end

function Display.UpdateText(parent, subRegion, config, kind, explicitTrigger)
  if kind == nil then
    Display.HideText(subRegion)
    return false
  end
  local state = ResolveState(parent, explicitTrigger)
  if not state or not state.cdmBuff then
    ReleaseContainer(subRegion.cdmAuraTimer)
    subRegion.cdmNativeText = nil
    if HasFont(subRegion) and ShowLinkedText(parent, subRegion, config, kind, explicitTrigger) then
      return true
    end
    ReleaseLinkedTexts(subRegion)
    return false
  end
  ReleaseLinkedTexts(subRegion)
  if not HasFont(subRegion) then return true end
  local unit, filter, spellIDs = Display.ResolveNativeSource(state)
  local wantsOwnTimer = unit ~= nil and (kind == "p" or kind == "bp")
  if wantsOwnTimer and ShowOwnTimer(subRegion, config, kind, unit, filter, spellIDs) then
    return true
  end
  Display.HideText(subRegion)
  if wantsOwnTimer then
    MarkPending(subRegion, OWN_REASON)
  end
  Private.CopyCDMCountdownText(subRegion.text, state, kind)
  if subRegion.UpdateAnchorOnTextChange then
    subRegion:UpdateAnchorOnTextChange()
  end
  return true
end

function Display.ReleaseIndicator(subRegion)
  if subRegion.preview then subRegion.preview:Hide() end
  if subRegion.dispelBorder then subRegion.dispelBorder:Hide() end
  if subRegion.dispelEdges then Private.DispelTypeDisplay.Hide(subRegion.dispelEdges) end
end

function Display.ModifyIndicator(_, subRegion)
  Display.ReleaseIndicator(subRegion)
end

function Display.UpdateIndicator(parent, subRegion)
  local state = ResolveState(parent)
  local dispelName
  if subRegion.visible and state and state.show and state.cdmBuff then
    dispelName = state.cdmTextPreview and "Magic" or state.cdmDispelName
  end
  Display.ReleaseIndicator(subRegion)
  if IsSecret(dispelName) or type(dispelName) ~= "string" or dispelName == "" then return end
  if subRegion.dispelEdges then
    for _, edge in ipairs(subRegion.dispelEdges) do
      AuraUtil.SetAuraBorderColor(edge, dispelName)
      edge:Show()
    end
  elseif subRegion.preview then
    local preview = subRegion.preview
    AuraUtil.SetAuraDispelTypeIcon(preview, dispelName)
    preview:SetVertexColor(1, 1, 1, 1)
    preview:Show()
  end
end

local function ResumePending(owner, reason)
  if reason == OWN_REASON and owner.cdmTextConfig then
    Protected(PrepareOwnTimer, owner)
  end
  if owner.cdmProgressData and not owner.cdmAuraTimer then
    Protected(Display.Modify, owner, owner.cdmProgressData)
  end
  if owner.Update and owner:IsVisible() then
    Protected(owner.Update, owner)
  end
end

Private.callbacks:RegisterCallback("RestrictionChanged", function(_, restricted)
  if restricted then return end
  if Private.QueueCDMRefresh then
    Private.QueueCDMRefresh()
  end
  for region in pairs(nativeBarRegions) do
    Protected(region.bar.StyleCdmBar, region.bar)
  end
  local waiting = {}
  for owner, reason in pairs(pendingOwners) do
    waiting[owner] = reason
  end
  for owner in pairs(waiting) do
    pendingOwners[owner] = nil
  end
  for owner, reason in pairs(waiting) do
    ResumePending(owner, reason)
  end
end)

local observer = CreateFrame("Frame")
for _, event in ipairs(OBSERVED_EVENTS) do
  observer:RegisterEvent(event)
end
observer:SetScript("OnEvent", function()
  for owner in pairs(linkedTextOwners) do
    if owner.linkedAuraTexts then
      for _, container in pairs(owner.linkedAuraTexts) do
        if container.wanted then container.frame:UpdateAllAuras() end
      end
    end
  end
end)

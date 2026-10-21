-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local AttachedElements = Shared.AttachedElements
local CLIP_TEMPLATE = Shared.CLIP_TEMPLATE
local DISPEL_ELEMENTS = Shared.DISPEL_ELEMENTS
local ElementTextKind = Shared.ElementTextKind
local FOLLOW_TICK = Shared.FOLLOW_TICK
local Followable = Shared.Followable
local HasWindow = Shared.HasWindow
local HideDurationTexts = Shared.HideDurationTexts
local IsTable = Shared.IsTable
local IsTextOfKind = Shared.IsTextOfKind
local KEEP_WHEN_LIMITED = Shared.KEEP_WHEN_LIMITED
local PilotIndex = Shared.PilotIndex
local ReadableNumber = Shared.ReadableNumber
local SpanClip = Shared.SpanClip
local StyleCountdown = Shared.StyleCountdown

function AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData)
  local auraContainer = nativeDisplay.container
  local gateText = auraContainer and auraContainer.remainingGateText
  local clip
  if gateText and not nativeDisplay.preview then
    clip = nativeDisplay.remainingClip
    if not clip then
      clip = CreateFrame("Frame", nil, nativeDisplay.button, CLIP_TEMPLATE)
      nativeDisplay.remainingClip = clip
    end
    SpanClip(clip, gateText, "TOPLEFT", 0, gateText, "BOTTOMRIGHT")
    clip:Show()
  end
  local limited = not nativeDisplay.preview and auraData.regionType == "icon" and HasWindow(auraData)
  local base = nativeDisplay.gateClip or nativeDisplay.button
  for index, element in AttachedElements(auraData) do
    local hostFrame = (nativeDisplay.elementFrames or {})["shared" .. index]
    if hostFrame then
      local keep = KEEP_WHEN_LIMITED[element.type] or (element.type == "subtext" and ElementTextKind(element) == "duration")
      local target = base
      if limited and not keep then target = clip end
      if not target then
        hostFrame:Hide()
      elseif hostFrame:GetParent() ~= target then
        local frameLevel = hostFrame:GetFrameLevel()
        hostFrame:SetParent(target)
        hostFrame:SetFrameLevel(frameLevel)
        if target == clip then hostFrame:Show() end
      end
    end
  end
end

function AuraDisplay.StyleRemainingList(nativeDisplay, auraData)
  nativeDisplay.remainingHidesIcon = nil
  AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData)
  if nativeDisplay.preview then return end
  local limited = auraData.regionType == "icon" and HasWindow(auraData)
  local overlay = nativeDisplay.conditionOverlay
  if overlay then
    if limited then overlay:Hide() else overlay:Show() end
  end
  if not limited then return end
  nativeDisplay.remainingHidesIcon = true
  if nativeDisplay.icon then
    nativeDisplay.button:ClearIcon()
    nativeDisplay.icon:Hide()
  end
  if nativeDisplay.cooldown then
    nativeDisplay.button:ClearDurationCooldown()
    nativeDisplay.cooldown:Hide()
  end
  if nativeDisplay.border then nativeDisplay.border:Hide() end
end

function AuraDisplay.StyleMissingIcon(nativeDisplay, auraData)
  if nativeDisplay.icon then nativeDisplay.icon:SetDesaturated(auraData.desaturate == true) end
  for _, record in ipairs(nativeDisplay.conditionPreview or {}) do
    if record.kind == "faAuraMissing" then record.texture:Show() else record.texture:Hide() end
  end
  AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
  if nativeDisplay.cooldown then nativeDisplay.cooldown:Hide() end
  for index, element in ipairs(auraData.subRegions or {}) do
    local record = DISPEL_ELEMENTS[element.type] and (nativeDisplay.sharedElements or {})[index]
    if record then
      if record.texture then record.texture:Hide() end
      Private.DispelTypeDisplay.Hide(record.dispelEdges)
    end
  end
end

function AuraDisplay.KeepMissingDesaturated(nativeDisplay, auraData)
  AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
end

local function Bound(auraButton, name)
  local bindings = auraButton.bindings
  local list = IsTable(bindings) and bindings[name]
  return IsTable(list) and list or {}
end

local emptyDuration

local function ResetBars(auraButton)
  if not emptyDuration and C_DurationUtil and C_DurationUtil.CreateDuration then
    emptyDuration = C_DurationUtil.CreateDuration()
  end
  for _, binding in ipairs(Bound(auraButton, "DurationBar")) do
    local fillBar = binding.widget
    if emptyDuration then pcall(fillBar.SetTimerDuration, fillBar, emptyDuration) end
    fillBar:SetMinMaxValues(0, 6)
    fillBar:SetValue(0)
  end
  for _, binding in ipairs(Bound(auraButton, "DurationText")) do binding.widget:SetText("") end
end

local function ResetCooldown(nativeDisplay, auraData)
  nativeDisplay.cooldown:Clear()
  nativeDisplay.cooldown:Hide()
  for index, element in AttachedElements(auraData, "subtext") do
    local shared = (nativeDisplay.sharedElements or {})[index]
    if shared and shared.text and IsTextOfKind(element, "duration") then shared.text:Show() end
  end
end

local function ProgressApplied(sweepCooldown, triggerState)
  if triggerState.progressType == "durationObject" and triggerState.durationObject and sweepCooldown.SetCooldownFromDurationObject then
    return (pcall(sweepCooldown.SetCooldownFromDurationObject, sweepCooldown, triggerState.durationObject))
  end
  local duration, expiration = triggerState.duration, triggerState.expirationTime
  if triggerState.progressType == "timed" and ReadableNumber(duration) and ReadableNumber(expiration)
    and duration > 0 and expiration ~= math.huge then
    return (pcall(sweepCooldown.SetCooldown, sweepCooldown, expiration - duration, duration))
  end
  return false
end

local function ShowStateIcon(nativeDisplay, auraData, triggerState)
  local icon = triggerState.icon
  if icon == nil then icon = AuraDisplay.SingleIcon(auraData) end
  if not pcall(nativeDisplay.icon.SetTexture, nativeDisplay.icon, icon) then
    nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
  end
end

local function FollowIcon(missingState, auraData, triggerState)
  local nativeDisplay = missingState.native
  if not triggerState then
    if missingState.following then
      missingState.following = nil
      nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
      ResetCooldown(nativeDisplay, auraData)
    end
    return
  end
  missingState.following = true
  ShowStateIcon(nativeDisplay, auraData, triggerState)
  local sweepCooldown = nativeDisplay.cooldown
  if not ProgressApplied(sweepCooldown, triggerState) then
    ResetCooldown(nativeDisplay, auraData)
    return
  end
  local drawsCooldown = auraData.cooldown ~= false
  sweepCooldown:SetDrawSwipe(drawsCooldown and auraData.cooldownSwipe ~= false)
  sweepCooldown:SetDrawEdge(drawsCooldown and auraData.cooldownEdge == true)
  sweepCooldown:SetReverse(auraData.inverse == true)
  local countdown = HideDurationTexts(nativeDisplay, auraData)
  local hidden = Private.ShouldHideDurationText and Private.ShouldHideDurationText(triggerState) and true or false
  if countdown then
    sweepCooldown:SetHideCountdownNumbers(hidden)
    StyleCountdown(sweepCooldown, nativeDisplay, countdown)
  else
    sweepCooldown:SetHideCountdownNumbers(hidden or auraData.cooldownTextDisabled ~= false)
  end
  sweepCooldown:Show()
end

local function DurationObjectOf(missingState, triggerState)
  if triggerState.progressType == "durationObject" then return triggerState.durationObject end
  local duration, expiration = triggerState.duration, triggerState.expirationTime
  if triggerState.progressType == "timed" and ReadableNumber(duration) and ReadableNumber(expiration)
    and duration > 0 and expiration ~= math.huge then
    local object = missingState.followDuration
    if not object then
      object = C_DurationUtil.CreateDuration()
      missingState.followDuration = object
    end
    if pcall(object.SetTimeFromStart, object, expiration - duration, duration) then return object end
  end
end

local function FollowTicker(auraButton, duration)
  local elapsed = 0
  return function(_, delta)
    elapsed = elapsed + delta
    if elapsed < FOLLOW_TICK then return end
    elapsed = 0
    for _, binding in ipairs(Bound(auraButton, "DurationText")) do
      local formatter = binding.options and binding.options.textFormatter
      if not formatter then
        local made, fallback = pcall(Private.GetDurationTextFormatter, 99, 0, 0)
        formatter = made and fallback or nil
      end
      local ok, caption = pcall(duration.FormatRemainingDuration, duration, formatter, Enum.DurationTimeModifier.RealTime)
      binding.widget:SetText(ok and caption or "")
    end
  end
end

local function FollowTimer(missingState, auraData, triggerState)
  local nativeDisplay = missingState.native
  local auraButton = nativeDisplay.button
  local duration = triggerState and DurationObjectOf(missingState, triggerState)
  if not duration then
    if missingState.following then
      missingState.following = nil
      auraButton:SetScript("OnUpdate", nil)
      ResetBars(auraButton)
      nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
    end
    return
  end
  missingState.following = true
  ShowStateIcon(nativeDisplay, auraData, triggerState)
  local direction = auraData.inverse and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime
  for _, binding in ipairs(Bound(auraButton, "DurationBar")) do
    pcall(binding.widget.SetTimerDuration, binding.widget, duration, Enum.StatusBarInterpolation.Immediate, direction)
  end
  if #Bound(auraButton, "DurationText") == 0 then
    auraButton:SetScript("OnUpdate", nil)
  else
    auraButton:SetScript("OnUpdate", FollowTicker(auraButton, duration))
  end
end

local function ResolveSource(auraRegion, auraData, origin)
  if origin ~= "next" then return origin end
  local pilot = PilotIndex(auraData)
  for index in ipairs(auraData.triggers or {}) do
    local triggerState = auraRegion.states and auraRegion.states[index]
    if index ~= pilot and Followable(auraData, index) and IsTable(triggerState) and triggerState.show then return index end
  end
end

local function ApplySource(auraRegion, auraData, missingState, origin)
  local resolved = ResolveSource(auraRegion, auraData, origin)
  local triggerState = resolved and auraRegion.states and auraRegion.states[resolved]
  if not (IsTable(triggerState) and triggerState.show) then triggerState = nil end
  if auraData.regionType == "icon" then FollowIcon(missingState, auraData, triggerState) else FollowTimer(missingState, auraData, triggerState) end
  missingState.native.button:SetAlpha((not missingState.foundMode or missingState.following) and 1 or 0)
end

function AuraDisplay.UpdateMissingSource(auraRegion)
  local nativeDisplay = auraRegion.blizzardAuraDisplay
  if not (nativeDisplay and nativeDisplay.active) then return end
  local origin = AuraDisplay.MissingSource(nativeDisplay.data)
  for _, instance in ipairs(nativeDisplay.instances or {}) do
    local missingState = instance.single and instance.single.missing
    if missingState and missingState.active and (origin or missingState.following) then
      ApplySource(auraRegion, nativeDisplay.data, missingState, origin)
    end
  end
end

Shared.ApplySource = ApplySource
Shared.ResetBars = ResetBars

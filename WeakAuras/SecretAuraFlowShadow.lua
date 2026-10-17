-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Shadows of the centered growths. A shadow is an invisible container that takes the room of half
-- of the content on the side opposite to the growth, so the visible content ends up centered.
-- A found aura gets one shadow per instance; a missing display gets a single shadow behind
-- the start of the shadow. Registers in Private.AuraFlow and Display.

local AuraDisplay = Private.BlizzardAuraDisplay
local Anchor = Private.AuraAnchor
local Flow = Private.AuraFlow

local SHADOW_GROUP = "MuscaShadow"
local ANCHOR_TEMPLATE = "DisableUntrustedLayoutScriptsTemplate"
local SHADOW_SPACING = -1

-- Hides a shadow owner (an instance, or the missing state of one) for good measure.
local function Silence(owner)
  if not owner then return end
  owner.flowShadowActive = false
  local shadow = owner.flowShadow
  if shadow then
    shadow:SetEnabled(false)
    shadow:Hide()
  end
end

local function ConfigureFlow(shadow, shadowGrowth)
  shadow:SetFlowLayoutAxis(shadowGrowth:Axis())
  shadow:SetFlowLayoutAnchorPoint(shadowGrowth:StartPoint())
  shadow:SetFlowLayoutGrowthDirection(shadowGrowth:Directions())
end

local function HideButton(auraButton)
  auraButton:SetAlpha(0)
  auraButton:EnableMouse(false)
end

-- Creates the shadow of owner, or refreshes it. False when the client refuses the aura group.
-- frameLimit caps the shadow below the aura's own limit (one slot for a missing aura).
local function EnsureShadow(owner, childRegion, auraData, auraTrigger, layout, frameLimit)
  local shadow = owner.flowShadow
  local filter, candidateList = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData)
  local limit = frameLimit or AuraDisplay.MaxAuras(auraData)
  if shadow then
    shadow:SetAuraGroupFilterString(SHADOW_GROUP, filter)
    shadow:SetAuraGroupCandidateFilters(SHADOW_GROUP, candidateList)
    shadow:SetAuraGroupLayout(SHADOW_GROUP, layout)
    shadow:SetAuraGroupMaxFrameCount(SHADOW_GROUP, limit)
    if shadow.SetAuraGroupEnabled then shadow:SetAuraGroupEnabled(SHADOW_GROUP, true) end
    owner.flowShadowActive = true
    return true
  end
  shadow = AuraDisplay.CreateAuraContainer(childRegion, auraData)
  shadow:SetEnabled(false)
  shadow:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  shadow:SetPoint("TOPLEFT", childRegion, "TOPLEFT")
  local isAdded = pcall(shadow.AddAuraGroup, shadow, SHADOW_GROUP, filter, {
    maxFrameCount = limit,
    candidateFilters = candidateList,
    layout = layout,
    initializeFrame = HideButton,
  })
  if not isAdded then
    shadow:Hide()
    owner.flowShadowActive, owner.flowShadow = false, nil
    return false
  end
  owner.flowShadow, owner.flowShadowActive = shadow, true
  return true
end

local function BuildShadowStart(flow, childRegion, shadowGrowth)
  if not flow.shadowStart then
    local start = CreateFrame("Frame", nil, childRegion, ANCHOR_TEMPLATE)
    start:SetSize(1, 1)
    start:EnableMouse(false)
    local point = shadowGrowth:StartPoint()
    start:SetPoint(point, childRegion, point)
    flow.shadowStart = start
  end
  flow.shadowStart:Show()
end

function AuraDisplay.EnsureFlowShadows(childRegion, auraData)
  local nativeDisplay = childRegion.blizzardAuraDisplay
  local flow = nativeDisplay.flow
  local modern = Flow.Modern(auraData)
  local shadowGrowth = modern and modern.growth.shadow
  local instances = nativeDisplay.instances or {}
  local first = instances[1]
  local missing = first and first.single and first.single.missing
  if not (flow and shadowGrowth) then
    for _, instance in ipairs(instances) do Silence(instance) end
    Silence(missing)
    if flow and flow.shadowStart then flow.shadowStart:Hide() end
    return
  end
  BuildShadowStart(flow, childRegion, shadowGrowth)

  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local isHorizontal = shadowGrowth:IsHorizontal()
  flow.half = ((isHorizontal and iconWidth or iconHeight) + modern.spacing) / 2
  local layout = {
    elementWidth = isHorizontal and flow.half + 1 or iconWidth,
    elementHeight = isHorizontal and iconHeight or flow.half + 1,
    elementSpacing = SHADOW_SPACING,
  }
  flow.shadowKind = "fixed"
  flow.shadowList = nil

  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  if not auraTrigger then return end
  local showOn = AuraDisplay.ShowOn(auraTrigger)
  if showOn == "showOnActive" and not AuraDisplay.UsesGate(auraData) then
    Silence(missing)
    local list = {}
    for _, instance in ipairs(instances) do
      if EnsureShadow(instance, childRegion, auraData, auraTrigger, layout) then
        ConfigureFlow(instance.flowShadow, shadowGrowth)
        list[#list + 1] = instance.flowShadow
      end
    end
    if #list > 0 then flow.shadowKind, flow.shadowList = "list", list end
    return
  end

  for _, instance in ipairs(instances) do Silence(instance) end
  if not (showOn == "showOnMissing" and missing and missing.active) then
    Silence(missing)
    return
  end
  local single = { elementWidth = flow.half + 1, elementHeight = flow.half + 1 }
  if not EnsureShadow(missing, childRegion, auraData, auraTrigger, layout, 1) then
    return
  end
  ConfigureFlow(missing.flowShadow, shadowGrowth)
  missing.flowShadowActive = Anchor.Behind(missing.flowShadow, shadowGrowth, flow.shadowStart,
    single.elementWidth, single.elementHeight, childRegion)
  if missing.flowShadowActive then
    flow.shadowKind, missing.flowShadowBoundUnit = "missing", nil
  end
end

function AuraDisplay.RefreshFlowShadow(instance, unit, isShown)
  local shadow = instance.flowShadow
  if not (instance.flowShadowActive and shadow) then return end
  if unit and unit ~= instance.flowShadowUnit then
    shadow:SetEnabled(false)
    instance.flowShadowUnit = unit
    shadow:SetUnit(instance.flowShadowUnit)
  end
  shadow:SetShown(isShown)
  shadow:SetEnabled(isShown)
  if isShown then shadow:UpdateAllAuras() end
end

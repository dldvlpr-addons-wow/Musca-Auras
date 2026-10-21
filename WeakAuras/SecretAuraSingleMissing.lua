-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local ApplySource = Shared.ApplySource
local CLIP_TEMPLATE = Shared.CLIP_TEMPLATE
local FOLLOWER_KEYS = Shared.FOLLOWER_KEYS
local IsTable = Shared.IsTable
local MISSING_GROUP = Shared.MISSING_GROUP
local OFFSET_KEYS = Shared.OFFSET_KEYS
local PRESENCE_GROUP = Shared.PRESENCE_GROUP
local ReportProblem = Shared.ReportProblem
local ResetBars = Shared.ResetBars

local function MissingMargin(auraData, iconWidth, iconHeight)
  local largest = math.ceil(math.max(iconWidth, iconHeight))
  local margin = 2 * largest + 64
  for _, element in ipairs(auraData.subRegions or {}) do
    local reach = 0
    for _, slotKey in ipairs(OFFSET_KEYS) do reach = math.max(reach, math.abs(tonumber(element[slotKey]) or 0)) end
    local extra = largest + reach + 64
    if element.type == "subglow" then extra = extra + math.ceil(math.max(iconWidth, iconHeight) * (element.glowScale or 1)) end
    margin = math.max(margin, extra)
  end
  return margin
end

local function CreateGroupContainer(auraRegion, auraData, slotKey, filterString, options)
  local auraContainer = AuraDisplay.CreateAuraContainer(auraRegion, auraData)
  auraContainer:SetEnabled(false)
  auraContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  auraContainer:SetPoint("TOPLEFT", auraRegion, "TOPLEFT")
  local ok, refusal = pcall(auraContainer.AddAuraGroup, auraContainer, slotKey, filterString, options)
  if not ok then auraContainer:Hide() end
  return auraContainer, ok, refusal
end

local function UpdateGroup(auraContainer, slotKey, filterString, candidateList, layout)
  auraContainer:SetAuraGroupFilterString(slotKey, filterString)
  auraContainer:SetAuraGroupCandidateFilters(slotKey, candidateList)
  auraContainer:SetAuraGroupLayout(slotKey, layout)
  auraContainer:SetAuraGroupEnabled(slotKey, true)
end

local function SilenceFollower(owner, slotKey)
  local trailer = owner[slotKey]
  if trailer then
    trailer:SetEnabled(false)
    trailer:Hide()
  end
end

local function EnsurePresence(missingState, auraRegion, auraData, filterString, candidateList)
  missingState.presenceActive = false
  if not (AuraDisplay.FlowGroup and AuraDisplay.FlowGroup(auraData)) then
    SilenceFollower(missingState, "presence")
    return
  end
  if missingState.presenceFailed then return end
  local layout = AuraDisplay.FlowPresenceSize(auraData)
  if missingState.presence then
    UpdateGroup(missingState.presence, PRESENCE_GROUP, filterString, candidateList, layout)
  else
    local auraContainer, ok, refusal = CreateGroupContainer(auraRegion, auraData, PRESENCE_GROUP, filterString, {
      maxFrameCount = 1,
      candidateFilters = candidateList,
      layout = layout,
      initializeFrame = function(auraButton)
        auraButton:EnableMouse(false)
        auraButton:SetAlpha(0)
        auraButton:SetSize(layout.elementWidth, layout.elementHeight)
      end,
    })
    if not ok then
      missingState.presenceFailed = true
      ReportProblem(auraData, "Blizzard could not create the Modern Aura Group spacing: " .. tostring(refusal))
      return
    end
    missingState.presence = auraContainer
  end
  missingState.presenceBoundUnit = nil
  if AuraDisplay.AnchorFlowPresence(auraRegion, auraData, missingState.presence) then
    missingState.presenceActive = true
    return
  end
  SilenceFollower(missingState, "presence")
  ReportProblem(auraData, "Blizzard refused the Modern Aura Group spacing; this display keeps a fixed space.")
end

local function SpellName(auraTrigger)
  local spellId = AuraDisplay.GetSpellIDs(auraTrigger, false)[1]
  local info = spellId and C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
  return IsTable(info) and info.name or ""
end

local function StyleMissingButton(missingState, auraRegion, auraData, auraTrigger)
  local nativeDisplay = missingState.native
  AuraDisplay.StyleNative(nativeDisplay, auraData, auraRegion)
  nativeDisplay.button:ClearAllPoints()
  nativeDisplay.button:SetPoint("TOPLEFT", AuraDisplay.ContentAnchor(auraRegion), "TOPLEFT")
  AuraDisplay.FillSampleBindings(nativeDisplay.button, AuraDisplay.SingleIcon(auraData), SpellName(auraTrigger), auraData, false)
  AuraDisplay.StyleMissingIcon(nativeDisplay, auraData)
end

local function BuildMissing(singleState, auraRegion, auraData, filterString, candidateList, layout)
  local missingState = singleState.missing
  local iconHeight = layout.elementHeight
  local auraContainer, ok, refusal = CreateGroupContainer(auraRegion, auraData, MISSING_GROUP, filterString, {
    maxFrameCount = 1,
    candidateFilters = candidateList,
    layout = layout,
    initializeFrame = function(auraButton)
      auraButton:SetSize(layout.elementWidth, iconHeight)
      auraButton:EnableMouse(false)
      Private.SnapLateTextures(auraButton, auraRegion)
    end,
  })
  if not ok then
    singleState.missingFailed = "Blizzard could not create the Aura(s) Missing display: " .. tostring(refusal)
    ReportProblem(auraData, singleState.missingFailed)
    return false
  end
  local clip = CreateFrame("Frame", nil, auraRegion, CLIP_TEMPLATE)
  clip:EnableMouse(false)
  clip:SetClipsChildren(true)
  missingState.container, missingState.clip = auraContainer, clip
  missingState.native = AuraDisplay.CreateSampleNative(clip)
  return true
end

local function PlaceMissing(missingState, auraRegion, margin)
  local auraContainer, clip = missingState.container, missingState.clip
  local reference = auraRegion
  if AuraDisplay.AnchorToContent(auraContainer, "TOPLEFT", auraRegion, "TOPLEFT", 0, 0) then
    reference = AuraDisplay.ContentAnchor(auraRegion)
  end
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", auraContainer, "TOPRIGHT", -1 - margin, margin)
  clip:SetPoint("BOTTOMRIGHT", reference, "BOTTOMRIGHT", margin, -margin)
end

local function EnsureMissing(instance, auraRegion, auraData, auraTrigger)
  local singleState = instance.single
  if singleState.missingFailed then
    ReportProblem(auraData, singleState.missingFailed)
    return
  end
  singleState.missing = singleState.missing or {}
  local missingState = singleState.missing
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local margin = MissingMargin(auraData, iconWidth, iconHeight)
  local layout = { elementWidth = iconWidth + 1 + 2 * margin, elementHeight = iconHeight }
  local filterString, candidateList = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData)
  if missingState.container then
    UpdateGroup(missingState.container, MISSING_GROUP, filterString, candidateList, layout)
  elseif not BuildMissing(singleState, auraRegion, auraData, filterString, candidateList, layout) then
    return
  end
  PlaceMissing(missingState, auraRegion, margin)
  EnsurePresence(missingState, auraRegion, auraData, filterString, candidateList)
  local frameLevel = auraRegion:GetFrameLevel() + 1
  missingState.clip:SetFrameLevel(frameLevel)
  missingState.container:SetFrameLevel(frameLevel)
  StyleMissingButton(missingState, auraRegion, auraData, auraTrigger)
  missingState.active = true
  local auraButton = missingState.native.button
  auraButton:SetScript("OnUpdate", nil)
  if missingState.following then ResetBars(auraButton) end
  missingState.following = nil
  missingState.foundMode = singleState.foundMode
  auraButton:SetAlpha(1)
  local origin = AuraDisplay.MissingSource(auraData, auraTrigger)
  if origin or missingState.foundMode then ApplySource(auraRegion, auraData, missingState, origin) end
end

local function DisableMissing(singleState)
  local missingState = singleState.missing
  if not (missingState and missingState.active) then return end
  missingState.active = false
  for _, slotKey in ipairs(FOLLOWER_KEYS) do SilenceFollower(missingState, slotKey) end
  SilenceFollower(missingState, "container")
  pcall(missingState.container.SetAuraGroupEnabled, missingState.container, MISSING_GROUP, false)
  missingState.clip:Hide()
  if missingState.native then AuraDisplay.StopSampleAnimations(missingState.native) end
  missingState.boundUnit = nil
end

Shared.DisableMissing = DisableMissing
Shared.EnsureMissing = EnsureMissing

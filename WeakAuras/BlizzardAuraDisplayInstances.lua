-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Anchor = Private.AuraAnchor
local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local AURA_GROUP = Shared.AURA_GROUP
local DEFAULT_GLOW_COLOR = Shared.DEFAULT_GLOW_COLOR
local GLOW_FRAME_LEVEL_STEP = Shared.GLOW_FRAME_LEVEL_STEP
local GLOW_MARGIN_RATIO = Shared.GLOW_MARGIN_RATIO
local GLOW_SLOT = Shared.GLOW_SLOT
local Glow = Shared.Glow
local InPreview = Shared.InPreview
local Instances = Shared.Instances
local LayoutInstance = Shared.LayoutInstance
local Queues = Shared.Queues
local ReadLevel = Shared.ReadLevel
local queuedApplies = Shared.queuedApplies

local glowMargins = setmetatable({}, { __mode = "k" })

local function NotifyUnitFrames() Display.UnitFramesChanged() end

function Glow.Surround(holder, target)
  local margin = glowMargins[target]
  if not margin then
    margin = { 0, 0 }
    glowMargins[target] = margin
    pcall(target.HookScript, target, "OnSizeChanged", NotifyUnitFrames)
  end
  local width, height = target:GetSize()
  if not (issecretvalue(width) or issecretvalue(height)) then
    margin[1], margin[2] = width * GLOW_MARGIN_RATIO, height * GLOW_MARGIN_RATIO
  end
  holder:SetPoint("TOPLEFT", target, "TOPLEFT", 0 - margin[1], margin[2])
  holder:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", margin[1], 0 - margin[2])
end

function Glow.StyleHalo(unitEntry)
  local glow = unitEntry.unitGlow
  local settings = unitEntry.data.blizzardAuraDisplay or {}
  glow.glowEntry = glow.glowEntry or { native = glow }
  local color = DEFAULT_GLOW_COLOR
  if settings.unitUseGlowColor ~= false and settings.unitGlowColor then color = settings.unitGlowColor end
  local padding = settings.unitGlowPadding or 0
  Display.StyleElementGlow(glow.glowEntry, glow.button, glow.overlay, glow.button, {
    glow = settings.unitGlow and true or false,
    glowType = settings.unitGlowType == "pulse" and "pulse" or "Proc",
    useGlowColor = true,
    glowColor = color,
    glowDuration = settings.unitGlowDuration,
    glowDurationMax = math.huge,
    glowXOffset = padding,
    glowYOffset = padding,
  }, nil, nil, settings.unitGlowX, settings.unitGlowY)
end

function Glow.SetupButton(unitEntry, button)
  local glow = unitEntry.unitGlow
  local overlayFrame = CreateFrame("Frame", nil, button)
  glow.button, glow.overlay = button, overlayFrame
  button:EnableMouse(false)
  button:SetAllPoints(glow.container)
  overlayFrame:SetAllPoints(button)
  local level = ReadLevel(glow.container)
  if level then
    for offset, frame in ipairs({ button, overlayFrame }) do frame:SetFrameLevel(level + offset) end
  end
  Glow.StyleHalo(unitEntry)
end

function Glow.Configure(unitEntry, auraData, triggerConfig)
  local settings = auraData.blizzardAuraDisplay or {}
  local glow = unitEntry.unitGlow
  if auraData.anchorFrameType ~= "UNITFRAME" or not settings.unitGlow then
    if glow then
      Display.ClearElementGlow(glow.glowEntry)
      glow.container:SetEnabled(false)
      glow.container:Hide()
    end
    return
  end
  local created = glow == nil
  if created then
    glow = { container = CreateFrame("AuraContainer", nil, unitEntry.region, "CustomAuraContainerTemplate") }
    unitEntry.unitGlow = glow
  end
  local holder = glow.container
  local filterString = Display.FilterString(triggerConfig)
  local candidateList = Display.CandidateFilters(auraData)

  holder:SetEnabled(false)
  holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  if created then
    holder:AddAuraSlot(GLOW_SLOT, filterString, {
      candidateFilters = candidateList,
      initializeFrame = function(button) Glow.SetupButton(unitEntry, button) end,
    })
  else
    if glow.button then Glow.StyleHalo(unitEntry) end
    Display.RefreshShownAnimations(glow)
  end
  holder:SetAuraSlotFilterString(GLOW_SLOT, filterString)
  holder:SetAuraSlotCandidateFilters(GLOW_SLOT, candidateList)
  holder:SetAuraSlotSortMethod(GLOW_SLOT, Display.SortOrder(auraData, triggerConfig))
end

function Glow.Refresh(auraRegion, state, unitEntry, unitId, anchorFrame, unitFrameMode)
  local glow = unitEntry.unitGlow
  local holder = glow.container
  local settings = state.data.blizzardAuraDisplay or {}
  local target
  if unitFrameMode and unitId ~= nil and settings.unitGlow and anchorFrame then
    local forbidden = anchorFrame.IsForbidden and anchorFrame:IsForbidden()
    if not issecretvalue(forbidden) and not forbidden then target = anchorFrame end
  end
  local visible = not InPreview() and target ~= nil and auraRegion:IsShown() and not state.unitGlowsHidden
    and settings.unitGlow == true and not unitEntry.statusHidden
  local host = target or auraRegion
  Anchor.Rebind(glow, holder, unitId, host)
  holder:ClearAllPoints()
  if target then
    Glow.Surround(holder, target)
  else
    holder:SetAllPoints(host)
  end

  local strata, currentStrata = host:GetFrameStrata(), holder:GetFrameStrata()
  if issecretvalue(strata) or issecretvalue(currentStrata) or strata ~= currentStrata then
    pcall(holder.SetFrameStrata, holder, strata)
  end
  local hostLevel = ReadLevel(host)
  if hostLevel then
    local wanted, current = hostLevel + GLOW_FRAME_LEVEL_STEP, holder:GetFrameLevel()
    if issecretvalue(current) or current ~= wanted then holder:SetFrameLevel(wanted) end
  end

  holder:SetShown(visible)
  holder:SetEnabled(visible)
  if visible then holder:UpdateAllAuras() end
end

function Display.HideUnitGlows(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  if not state then return end
  state.unitGlowsHidden = true
  for _, unitEntry in ipairs(state.instances) do
    local glow = unitEntry.unitGlow
    if glow then
      glow.container:SetEnabled(false)
      glow.container:Hide()
    end
  end
end

function Instances.Create(auraRegion, auraData)
  local holder, isFlowContainer = Display.CreateAuraContainer(auraRegion, auraData)
  local unitEntry = { container = holder, region = auraRegion, flowContainer = isFlowContainer and true or false, buttons = {}, data = auraData }
  local triggerConfig = Display.GetTrigger(auraData)
  local sortMethod, sortDirection = Display.SortOrder(auraData, triggerConfig)
  holder:SetEnabled(false)
  holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  holder:SetPoint("TOPLEFT", auraRegion, "TOPLEFT")
  holder:AddAuraGroup(AURA_GROUP, Display.FilterString(triggerConfig), {
    maxFrameCount = Display.MaxAuras(auraData),
    candidateFilters = Display.CandidateFilters(auraData),
    sortMethod = sortMethod,
    sortDirection = sortDirection,
    initializeFrame = function(button)
      Display.SetupAuraButton(unitEntry, auraRegion, holder, button)
      Private.SnapLateTextures(button, auraRegion)
    end,
  })
  return unitEntry
end

function Instances.Configure(auraRegion, state, position, unitEntry, restyle)
  local auraData = state.data
  local holder = unitEntry.container
  local triggerConfig = Display.GetTrigger(auraData)
  unitEntry.data = auraData

  holder:SetEnabled(false)
  holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  holder:SetAuraGroupFilterString(AURA_GROUP, Display.FilterString(triggerConfig))
  holder:SetAuraGroupCandidateFilters(AURA_GROUP, Display.CandidateFilters(auraData))
  holder:SetAuraGroupSortMethod(AURA_GROUP, Display.SortOrder(auraData, triggerConfig))

  if restyle then
    for _, buttonState in ipairs(unitEntry.buttons) do Display.StyleNative(buttonState, auraData, auraRegion) end
  end
  LayoutInstance(unitEntry, auraRegion, auraData, position)
  Glow.Configure(unitEntry, auraData, triggerConfig)
  Display.ConfigureSingle(unitEntry, auraRegion, auraData, position)
end

function Instances.Remove(unitEntry)
  for _, buttonState in ipairs(unitEntry.buttons) do
    for _, entry in pairs(buttonState.sharedElements or {}) do Display.ClearElementGlow(entry) end
  end
  local glow = unitEntry.unitGlow
  Display.ClearElementGlow(glow and glow.glowEntry)
  unitEntry.container:SetEnabled(false)
  unitEntry.container:Hide()
  Display.RefreshSingle(unitEntry, nil, false)
  local missing = unitEntry.single and unitEntry.single.missing
  if missing then missing.active = false end
  Display.RetireFrame(unitEntry.container)
  Display.RetireFrame(unitEntry.flowShadow)
  if glow then Display.RetireFrame(glow.container) end
end

function Instances.RemoveAll(state)
  local list = state.instances
  for position = #list, 1, -1 do
    Instances.Remove(list[position])
    list[position] = nil
  end
end

function Display.FlushInstanceQueue(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  local queue = state and state.instanceQueue
  if not queue then return end
  state.instanceQueue = nil
  Queues.instanceRegions[auraRegion] = nil
  if WeakAuras.IsRestricted() then
    queuedApplies[auraRegion] = queue.data
    return
  end
  if state.data ~= queue.data then return end
  for position = queue.nextIndex, #state.instances do
    Instances.Configure(auraRegion, state, position, state.instances[position], true)
  end
end

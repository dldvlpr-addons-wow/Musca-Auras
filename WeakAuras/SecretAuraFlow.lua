if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

local FRAMED_MODES = {UNITFRAME = true, NAMEPLATE = true}
local DEFAULT_SPACING = 2
local DEFAULT_LIMIT = 20
local MAX_PREVIEW_UNITS = 5
local SHADOW_GROUP = "FAShadow"
local BASE_TEMPLATE = "CustomAuraContainerTemplate"
local LOCKED_TEMPLATE = BASE_TEMPLATE .. ", DisableUntrustedLayoutScriptsTemplate"
local OPPOSITE = {TOPLEFT = "TOPRIGHT", TOPRIGHT = "TOPLEFT", BOTTOMLEFT = "TOPLEFT"}
local CENTER_REMAP = {
  CENTER_HORIZONTAL = {{"LEFT", "RIGHT"}, {"RIGHT", "LEFT"}},
  CENTER_VERTICAL = {{"TOP", "DOWN"}, {"BOTTOM", "UP"}},
}
local PROBLEMS = {
  notIcon = "In a Modern Aura Group, use an Icon display.",
  remaining = "In a Modern Aura Group, Remaining Time is not available yet.",
  single = "Grouped by unit frame or nameplate, use Show On: Aura(s) Found.",
  nameplate = "Grouped by nameplate, choose the Nameplate unit.",
  unitFrame = "Grouped by unit frame, choose a unit other than Nameplate.",
}

Display.flowFrameModes = {
  SCREEN = "Screen",
  UNITFRAME = "Unit Frames",
  NAMEPLATE = "Nameplates",
}
Display.flowGrowths = {
  RIGHT = "Right",
  LEFT = "Left",
  DOWN = "Down",
  UP = "Up",
  CENTER_HORIZONTAL = "Centered Horizontal",
  CENTER_VERTICAL = "Centered Vertical",
}

local function NewGrowth(start, listEnd, far, pixelX, pixelY, signX, signY)
  return {
    start = start,
    listEnd = listEnd,
    pixel = {pixelX, pixelY},
    far = far,
    sign = {signX, signY},
  }
end

local GROWTH = {
  RIGHT = NewGrowth("TOPLEFT", "TOPRIGHT", "TOPRIGHT", -1, 0, 1, 0),
  LEFT = NewGrowth("TOPRIGHT", "TOPLEFT", "TOPLEFT", 1, 0, -1, 0),
  DOWN = NewGrowth("TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", 0, 1, 0, -1),
  UP = NewGrowth("BOTTOMLEFT", "TOPLEFT", "TOPLEFT", 0, -1, 0, 1),
}

local function NewCenteredGrowth(visibleKey, shadowKey, centerPoint)
  local base = GROWTH[visibleKey]
  local growth = NewGrowth(base.start, base.listEnd, base.far, base.pixel[1], base.pixel[2], base.sign[1], base.sign[2])
  growth.visible = visibleKey
  growth.shadow = GROWTH[shadowKey]
  growth.centerPoint = centerPoint
  return growth
end

GROWTH.CENTER_HORIZONTAL = NewCenteredGrowth("RIGHT", "LEFT", "TOP")
GROWTH.CENTER_VERTICAL = NewCenteredGrowth("DOWN", "UP", "LEFT")

local function SpacingOf(group)
  return tonumber(group.blizzardFlowSpacing) or DEFAULT_SPACING
end

local function GrowthKey(group)
  local requested = group.blizzardFlowGrowth
  local growth = GROWTH[requested] and requested or "RIGHT"
  if not FRAMED_MODES[group.blizzardFlowFrames] then return growth end
  local remap = CENTER_REMAP[growth]
  if not remap then return growth end
  local selfPoint = group.selfPoint or "CENTER"
  for _, pair in ipairs(remap) do
    if selfPoint:find(pair[1]) then return pair[2] end
  end
  return growth
end

local function NewAnchorFrame(parent)
  local frame = CreateFrame("Frame", nil, parent, "DisableUntrustedLayoutScriptsTemplate")
  frame:EnableMouse(false)
  return frame
end

local function ActiveNative(childId)
  local entry = Private.regions[childId]
  local native = entry and entry.region and entry.region.blizzardAuraDisplay
  if native and native.active then return native end
end

local function FramePosition(group)
  return group.anchorPoint or "CENTER", tonumber(group.xOffset) or 0, tonumber(group.yOffset) or 0
end

local function CrossKeyword(selfPoint, horizontal)
  local names = horizontal and {"TOP", "BOTTOM"} or {"LEFT", "RIGHT"}
  for _, name in ipairs(names) do
    if selfPoint:find(name) then return name end
  end
  return ""
end

local function AlignPoint(point, horizontal, cross)
  if horizontal then
    return cross .. (point:find("LEFT") and "LEFT" or "RIGHT")
  end
  return (point:find("TOP") and "TOP" or "BOTTOM") .. cross
end

local function AlignedPoints(group, growth)
  local horizontal = growth.sign[1] ~= 0
  local cross = CrossKeyword(group.selfPoint or "CENTER", horizontal)
  return AlignPoint(growth.start, horizontal, cross),
    AlignPoint(growth.listEnd, horizontal, cross),
    AlignPoint(growth.far, horizontal, cross)
end

local function CrossOffset(group, growth, cross)
  local anchor = group.selfPoint or "CENTER"
  local horizontal = growth.sign[1] ~= 0
  local first, second = "LEFT", "RIGHT"
  if horizontal then first, second = "TOP", "BOTTOM" end
  if anchor:find(first) then return 0, 0 end
  local onSecond = anchor:find(second)
  if horizontal then return 0, onSecond and cross or cross / 2 end
  return onSecond and -cross or -cross / 2, 0
end

local function UnitAnchor(mode, unit)
  local frame
  if mode == "UNITFRAME" then frame = WeakAuras.GetUnitFrame(unit) end
  if not frame and mode == "NAMEPLATE" then frame = C_NamePlate.GetNamePlateForUnit(unit) end
  if frame and not frame:IsForbidden() then return frame end
end

local function BackwardPoint(growth)
  local mirrored = growth.sign[1] ~= 0 and OPPOSITE[growth.start]
  if mirrored then return mirrored end
  return growth.start == "TOPLEFT" and "BOTTOMLEFT" or "TOPLEFT"
end

local function AnchorBackwards(container, growth, startFrame, size, region)
  local point = BackwardPoint(growth)
  container:ClearAllPoints()
  local placed = pcall(container.SetPoint, container, point, startFrame, growth.start, growth.sign[1] * size, growth.sign[2] * size)
  if placed then return placed end
  container:ClearAllPoints()
  container:SetPoint("TOPLEFT", region, "TOPLEFT")
  return placed
end

local function HideShadow(holder, key)
  local container = holder and holder[key]
  if not container then return end
  holder[key .. "Active"] = false
  container:SetEnabled(false)
  container:Hide()
end

local function BuildShadowContainer(region, data, layout, maxCount, filter, candidates)
  local container = Display.CreateAuraContainer(region, data)
  container:SetEnabled(false)
  container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  container:SetPoint("TOPLEFT", region, "TOPLEFT")
  local settings = {
    candidateFilters = candidates,
    maxFrameCount = maxCount,
    layout = layout,
    initializeFrame = function(button)
      button:SetSize(layout.elementWidth, layout.elementHeight)
      button:SetAlpha(0)
      button:EnableMouse(false)
    end,
  }
  if pcall(container.AddAuraGroup, container, SHADOW_GROUP, filter, settings) then return container end
  container:Hide()
  return nil
end

local function MeasureContainer(existing, region, data, growth, layout, maxCount, filter, candidates)
  local container = existing
  if container then
    container:SetAuraGroupFilterString(SHADOW_GROUP, filter)
    container:SetAuraGroupCandidateFilters(SHADOW_GROUP, candidates)
    container:SetAuraGroupLayout(SHADOW_GROUP, layout)
    container:SetAuraGroupMaxFrameCount(SHADOW_GROUP, maxCount)
    container:SetAuraGroupEnabled(SHADOW_GROUP, true)
  else
    container = BuildShadowContainer(region, data, layout, maxCount, filter, candidates)
    if not container then return nil end
  end
  local axis = AnchorUtil.FlowLayoutAxis
  local directions = AnchorUtil.FlowDirection
  container:SetFlowLayoutAxis(growth.sign[2] ~= 0 and axis.Vertical or axis.Horizontal)
  container:SetFlowLayoutAnchorPoint(growth.start)
  container:SetFlowLayoutGrowthDirection(growth.sign[1] < 0 and directions.Left or directions.Right,
    growth.sign[2] > 0 and directions.Up or directions.Down)
  return container
end

local function ShadowLayout(along, width, height, size)
  if along then return {elementWidth = size, elementHeight = height, elementSpacing = -1} end
  return {elementWidth = width, elementHeight = size, elementSpacing = -1}
end

local function MeasureListShadows(native, flow, region, data, shadowGrowth, layout, filter, candidates)
  flow.shadowList = {}
  for _, instance in ipairs(native.instances) do
    local limit = Display.MaxAuras(data)
    instance.flowShadow = MeasureContainer(instance.flowShadow, region, data, shadowGrowth, layout, limit, filter, candidates)
    instance.flowShadowActive = instance.flowShadow ~= nil
    if instance.flowShadow then
      flow.shadowList[#flow.shadowList + 1] = instance.flowShadow
    end
  end
  if #flow.shadowList > 0 then flow.shadowKind = "list" end
end

local function MeasureMissingShadow(missing, flow, region, data, shadowGrowth, along, dimensions, size, filter, candidates)
  local width, height = dimensions[1], dimensions[2]
  local single = {elementWidth = along and size or width, elementHeight = along and height or size}
  missing.flowShadow = MeasureContainer(missing.flowShadow, region, data, shadowGrowth, single, 1, filter, candidates)
  missing.flowShadowActive = missing.flowShadow ~= nil
    and AnchorBackwards(missing.flowShadow, shadowGrowth, flow.shadowStart, size, region)
  missing.flowShadowBoundUnit = nil
  if missing.flowShadowActive then flow.shadowKind = "missing" end
end

local function ChainShadows(flow)
  local shadow = flow.growth.shadow
  local kind = flow.shadowKind
  if kind == "list" then
    local list = flow.shadowList
    for index, container in ipairs(list) do
      container:ClearAllPoints()
      if index == 1 then
        pcall(container.SetPoint, container, shadow.start, flow.shadowStart, shadow.start)
      else
        pcall(container.SetPoint, container, shadow.start, list[index - 1], shadow.listEnd, shadow.pixel[1], shadow.pixel[2])
      end
    end
    return {list[#list], shadow.listEnd, shadow.pixel[1], shadow.pixel[2]}
  end
  if kind == "missing" then
    local missing = flow.region.blizzardAuraDisplay.instances[1].single.missing
    return {missing.flowShadow, shadow.start, 0, 0}
  end
  return {flow.shadowStart, shadow.start, shadow.sign[1] * flow.half, shadow.sign[2] * flow.half}
end

local function NameplatePreview(group)
  if not (Private.ensurePRDFrame and WeakAuras.IsOptionsOpen()) then return end
  Private.ensurePRDFrame()
  local frame = Private.personalRessourceDisplayFrame
  if frame and frame.anchorFrame then
    frame:anchorFrame(group.id, "NAMEPLATE")
  end
  return frame
end

local function PreviewFrame(group, unit)
  local candidate
  if group.blizzardFlowFrames == "NAMEPLATE" then
    candidate = NameplatePreview(group)
  elseif unit then
    candidate = WeakAuras.GetUnitFrame(unit)
  end
  if candidate and not candidate:IsForbidden() then return candidate end
end

local function MovePreviewRegion(region, button)
  if not (region.SetAnchor and region.SetOffset) then return end
  local relativeTo = region.relativeTo
  local boundElsewhere = relativeTo ~= button and not (type(relativeTo) == "table" and relativeTo.bindings)
  if boundElsewhere then
    region.flowPreviewSaved = {
      region.anchorPoint,
      relativeTo,
      region.relativePoint,
      region.GetXOffset and region:GetXOffset() or 0,
      region.GetYOffset and region:GetYOffset() or 0,
    }
  end
  region:SetAnchor("TOPLEFT", button, "TOPLEFT")
  region:SetOffset(0, 0)
end

local function PreviewBox(growth, length, cross)
  local signX, signY = growth.sign[1], growth.sign[2]
  if signX > 0 then return 0, -cross, length, 0 end
  if signX < 0 then return -length, -cross, 0, 0 end
  if signY < 0 then return 0, -length, cross, 0 end
  return 0, 0, cross, length
end

local function SetGroupPreviewBounds(group, growth, length, cross, offsetX, offsetY)
  local entry = Private.regions[group.id]
  local region = entry and entry.region
  if not region then return end
  local left, bottom, right, top = PreviewBox(growth, length, cross)
  left, right, bottom, top = left + offsetX, right + offsetX, bottom + offsetY, top + offsetY
  if region.GetBoundingRect ~= region.flowPreviewBoundsFn then
    region.flowPreviewBoundsSaved = region.GetBoundingRect
  end
  local function BoundsProvider(self)
    self.blx, self.bly, self.trx, self.try = left, bottom, right, top
    return left, bottom, right, top
  end
  region.flowPreviewBoundsFn = BoundsProvider
  region.GetBoundingRect = BoundsProvider
  region:GetBoundingRect()
end

local function StaleGrowth(group, childId)
  local native = ActiveNative(childId)
  local flow = native and native.flow
  local current = flow and flow.growth
  if not current then return false end
  return current ~= GROWTH[GrowthKey(group)]
end

local staleRebuilds = {}

local function ScheduleStaleRebuilds(group)
  if InCombatLockdown() then return end
  for _, childId in ipairs(group.controlledChildren or {}) do
    if StaleGrowth(group, childId) and not staleRebuilds[childId] then
      staleRebuilds[childId] = true
      C_Timer.After(0, function()
        staleRebuilds[childId] = nil
        local child = WeakAuras.GetData(childId)
        if child and not InCombatLockdown() and StaleGrowth(group, childId) then
          WeakAuras.Add(child)
        end
      end)
    end
  end
end

local function CollectChainedFlows(group, growth)
  local flows = {}
  for _, childId in ipairs(group.controlledChildren or {}) do
    local entry = Private.regions[childId]
    local region = entry and entry.region
    local native = region and region.blizzardAuraDisplay
    local flow = native and native.active and native.flow
    if flow and flow.endFrame and flow.growth == growth then
      flow.region = region
      flows[#flows + 1] = flow
    end
  end
  return flows
end

local function ChainShadowStarts(flows, growth, spacing)
  local shadowEnd
  for _, flow in ipairs(flows) do
    if flow.shadowStart and flow.shadowKind then
      flow.shadowStart:ClearAllPoints()
      local chained = shadowEnd and pcall(flow.shadowStart.SetPoint, flow.shadowStart, growth.shadow.start,
        shadowEnd[1], shadowEnd[2], shadowEnd[3], shadowEnd[4])
      if not chained then
        flow.shadowStart:ClearAllPoints()
        flow.shadowStart:SetPoint(growth.shadow.start, flows[1].region, growth.centerPoint)
      end
      shadowEnd = ChainShadows(flow)
    end
  end
  if not shadowEnd then return end
  return {
    endFrame = shadowEnd[1],
    endPoint = shadowEnd[2],
    x = shadowEnd[3] + growth.sign[1] * spacing / 2,
    y = shadowEnd[4] + growth.sign[2] * spacing / 2,
  }
end

function Display.FlowGroup(data)
  local parentId = data and data.parent
  local parent = parentId and WeakAuras.GetData(parentId)
  if parent and parent.regionType == "group" and parent.blizzardFlow then return parent end
end

function Display.FlowFrameMode(data)
  local group = Display.FlowGroup(data)
  local mode = group and group.blizzardFlowFrames
  if FRAMED_MODES[mode] then return mode end
end

function Display.FlowGrowth(data)
  local group = Display.FlowGroup(data)
  if not group then return end
  return GrowthKey(group), SpacingOf(group)
end

Display.FlowGrowthKey = GrowthKey

function Display.VisibleGrowth(growth)
  local entry = GROWTH[growth]
  return entry and entry.visible or growth
end

function Display.FlowLimit(data)
  local group = Display.FlowGroup(data)
  if not group then return end
  if group.blizzardFlowUseLimit then
    return math.max(1, math.floor(tonumber(group.blizzardFlowLimit) or 5))
  end
  return DEFAULT_LIMIT
end

function Display.FrameAnchorType(data)
  if not Display.FlowGroup(data) then return data.anchorFrameType end
  return Display.FlowFrameMode(data) or "SCREEN"
end

local function SortSettings(group, trigger)
  if group then return group.blizzardFlowSort, group.blizzardFlowReverse end
  return trigger.sortMethod, trigger.sortReverse
end

function Display.SortOrder(data, trigger)
  local method, reverse = SortSettings(Display.FlowGroup(data), trigger)
  method = method or "Default"
  if not Display.sortMethods[method] or method == "UnitFrameDebuff" then method = "Default" end
  local sortValue = AuraContainerSortMethod[method]
  return sortValue, reverse and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal
end

function Display.FlowProblem(data, trigger)
  if not Display.FlowGroup(data) then return end
  if data.regionType ~= "icon" then return PROBLEMS.notIcon end
  if Display.RemainingWindow(trigger) then return PROBLEMS.remaining end
  local mode = Display.FlowFrameMode(data)
  if not mode then return end
  if Display.IsSingle(trigger) then return PROBLEMS.single end
  if mode == "NAMEPLATE" and trigger.unit ~= "nameplate" then return PROBLEMS.nameplate end
  if mode == "UNITFRAME" and trigger.unit == "nameplate" then return PROBLEMS.unitFrame end
end

function Display.CreateAuraContainer(parent, data)
  if Display.FlowGroup(data) then
    local created, container = pcall(CreateFrame, "AuraContainer", nil, parent, LOCKED_TEMPLATE)
    if created and container then return container, true end
  end
  return CreateFrame("AuraContainer", nil, parent, BASE_TEMPLATE), false
end

function Display.ContentAnchor(region)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  return flow and flow.start or region
end

function Display.AnchorToContent(container, point, region, relativePoint, x, y)
  x, y = x or 0, y or 0
  local anchor = Display.ContentAnchor(region)
  local redirected = anchor ~= region
  if redirected and pcall(container.SetPoint, container, point, anchor, relativePoint, x, y) then return true end
  container:ClearAllPoints()
  container:SetPoint(point, region, relativePoint, x, y)
  return not redirected
end

function Display.EnsureFlowStart(region, data)
  local native = region.blizzardAuraDisplay
  if not Display.FlowGroup(data) then
    local previous = native.flow
    if previous then
      previous.start:Hide()
      native.flow = nil
    end
    return
  end
  native.flow = native.flow or {}
  local flow = native.flow
  if not flow.start then
    flow.start = NewAnchorFrame(region)
  end
  local width, height = Display.Dimensions(data)
  flow.start:SetSize(width, height)
  flow.start:Show()
  flow.growth = GROWTH[(Display.FlowGrowth(data))]
  flow.start:ClearAllPoints()
  flow.start:SetPoint(flow.growth.start, region, flow.growth.start)
end

function Display.SetFlowEnd(region, data, presence)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  if not flow then return end
  local growth = flow.growth
  local trigger = Display.GetTrigger(data)
  local _, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local showOn = Display.ShowOn(trigger)
  if showOn == "showOnMissing" and presence then
    flow.endFrame, flow.endPoint, flow.x, flow.y = presence, growth.start, 0, 0
  elseif showOn == "showOnActive" and not Display.UsesGate(data) and native.instances[1] then
    local last = native.instances[#native.instances]
    flow.endFrame, flow.endPoint = last.container, growth.listEnd
    flow.x, flow.y = growth.pixel[1], growth.pixel[2]
  else
    flow.endFrame, flow.endPoint = flow.start, growth.start
    flow.x, flow.y = growth.sign[1] * (width + spacing), growth.sign[2] * (height + spacing)
  end
end

function Display.FlowPresenceSize(data)
  local growthKey, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local horizontal = GROWTH[growthKey].sign[1] ~= 0
  local size = (horizontal and width or height) + spacing + 1
  if horizontal then return {elementWidth = size, elementHeight = height} end
  return {elementWidth = width, elementHeight = size}
end

function Display.AnchorFlowPresence(region, data, container)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  if not flow then return false end
  local layout = Display.FlowPresenceSize(data)
  local horizontal = flow.growth.sign[1] ~= 0
  local size = horizontal and layout.elementWidth or layout.elementHeight
  return AnchorBackwards(container, flow.growth, flow.start, size, region)
end

function Display.EnsureFlowShadows(region, data)
  local native = region.blizzardAuraDisplay
  local flow = native and native.flow
  local shadowGrowth = flow and flow.growth.shadow
  local first = native and native.instances[1]
  local missing = first and first.single and first.single.missing
  if not shadowGrowth then
    for _, instance in ipairs(native and native.instances or {}) do
      HideShadow(instance, "flowShadow")
    end
    HideShadow(missing, "flowShadow")
    if flow and flow.shadowStart then flow.shadowStart:Hide() end
    return
  end
  if not flow.shadowStart then
    local anchor = NewAnchorFrame(region)
    anchor:SetSize(1, 1)
    flow.shadowStart = anchor
  end
  flow.shadowStart:Show()
  local trigger = Display.GetTrigger(data)
  local _, spacing = Display.FlowGrowth(data)
  local width, height = Display.Dimensions(data)
  local along = shadowGrowth.sign[1] ~= 0
  flow.half = ((along and width or height) + spacing) / 2
  local size = flow.half + 1
  local layout = ShadowLayout(along, width, height, size)
  local filter, candidates = Display.FilterString(trigger), Display.CandidateFilters(data)
  local showOn = Display.ShowOn(trigger)
  flow.shadowKind, flow.shadowList = "fixed", nil
  if showOn == "showOnActive" and not Display.UsesGate(data) then
    MeasureListShadows(native, flow, region, data, shadowGrowth, layout, filter, candidates)
  else
    for _, instance in ipairs(native.instances) do
      HideShadow(instance, "flowShadow")
    end
  end
  if showOn == "showOnMissing" and missing and missing.active then
    MeasureMissingShadow(missing, flow, region, data, shadowGrowth, along, {width, height}, size, filter, candidates)
  else
    HideShadow(missing, "flowShadow")
  end
end

function Display.RefreshFlowShadow(instance, unit, shown)
  local container = instance.flowShadowActive and instance.flowShadow
  if not container then return end
  if unit and instance.flowShadowUnit ~= unit then
    container:SetEnabled(false)
    container:SetUnit(unit)
    instance.flowShadowUnit = unit
  end
  container:SetShown(shown)
  container:SetEnabled(shown)
  if shown then container:UpdateAllAuras() end
end

function Display.RestorePreviewRegion(region)
  local saved = region and region.flowPreviewSaved
  if not saved then return end
  region.flowPreviewSaved = nil
  local point, relativeTo, relativePoint, x, y = unpack(saved, 1, 5)
  if point and relativeTo then region:SetAnchor(point, relativeTo, relativePoint) end
  region:SetOffset(x, y)
end

function Display.RestoreGroupPreview(group)
  local entry = group and Private.regions[group.id]
  local region = entry and entry.region
  if not region or not region.flowPreviewBoundsSaved then return end
  if region.GetBoundingRect == region.flowPreviewBoundsFn then
    region.GetBoundingRect = region.flowPreviewBoundsSaved
  end
  region.flowPreviewBoundsSaved, region.flowPreviewBoundsFn = nil, nil
  region.boundingRect = false
  region:GetBoundingRect()
end

function Display.ReleaseNameplatePreview(group)
  local frame = Private.personalRessourceDisplayFrame
  if group and frame and frame.anchorFrame then
    frame:anchorFrame(group.id, nil)
  end
end

local pendingBatch

function Display.BeginFlowBatch()
  pendingBatch = pendingBatch or {}
end

function Display.EndFlowBatch()
  local groups = pendingBatch
  pendingBatch = nil
  for group in pairs(groups or {}) do
    Display.RelinkFlowUnits(group)
  end
end

local function EachBoundInstance(group, visit)
  for _, childId in ipairs(group.controlledChildren or {}) do
    local native = ActiveNative(childId)
    if native then
      for _, instance in ipairs(native.instances) do
        visit(instance, instance.visible and instance.boundUnit)
      end
    end
  end
end

function Display.RelinkFlowUnits(group)
  local mode = group and group.blizzardFlowFrames
  if not FRAMED_MODES[mode] then return end
  if pendingBatch then
    pendingBatch[group] = true
    return
  end
  local growth = GROWTH[GrowthKey(group)]
  local point, frameX, frameY = FramePosition(group)
  local start, listEnd = AlignedPoints(group, growth)
  local spacing = SpacingOf(group)
  local lastShadow = {}
  local shadowGrowth = growth.shadow
  local shadowStart, shadowEnd
  if shadowGrowth then
    shadowStart, shadowEnd = AlignedPoints(group, shadowGrowth)
    EachBoundInstance(group, function(instance, unit)
      local shadow = unit and instance.flowShadowActive and instance.flowShadow
      if not shadow then return end
      shadow:ClearAllPoints()
      local linked = lastShadow[unit] and pcall(shadow.SetPoint, shadow, shadowStart, lastShadow[unit], shadowEnd,
        shadowGrowth.pixel[1], shadowGrowth.pixel[2])
      local frame = not linked and UnitAnchor(mode, unit)
      if frame then shadow:SetPoint(shadowStart, frame, point, frameX, frameY) end
      lastShadow[unit] = shadow
    end)
  end
  local lastContainer = {}
  EachBoundInstance(group, function(instance, unit)
    if not unit then return end
    local container = instance.container
    container:ClearAllPoints()
    local linked = lastContainer[unit] and pcall(container.SetPoint, container, start, lastContainer[unit], listEnd,
      growth.pixel[1], growth.pixel[2])
    if not linked and lastShadow[unit] then
      linked = pcall(container.SetPoint, container, start, lastShadow[unit], shadowEnd,
        shadowGrowth.pixel[1] + growth.sign[1] * spacing / 2, shadowGrowth.pixel[2] + growth.sign[2] * spacing / 2)
    end
    if not linked then
      local frame = UnitAnchor(mode, unit)
      if frame then
        container:ClearAllPoints()
        container:SetPoint(start, frame, point, frameX, frameY)
      end
    end
    lastContainer[unit] = container
  end)
end

function Display.FlowPreviewUnits(data)
  if Display.FlowFrameMode(data) ~= "UNITFRAME" then return {false} end
  local units = {}
  local tokens = Display.UnitTokens(Display.GetTrigger(data) or {})
  for _, unit in ipairs(tokens) do
    if UnitExists(unit) and WeakAuras.GetUnitFrame(unit) then
      units[#units + 1] = unit
      if #units >= MAX_PREVIEW_UNITS then break end
    end
  end
  if #units == 0 then units[1] = "player" end
  return units
end

function Display.FlowPreviewFrame(group)
  local mode = group and group.blizzardFlow and group.blizzardFlowFrames
  if not FRAMED_MODES[mode] or not WeakAuras.IsOptionsOpen() then return end
  local unit
  for _, childId in ipairs(group.controlledChildren or {}) do
    local child = WeakAuras.GetData(childId)
    if child and Display.Enabled(child) then
      unit = Display.FlowPreviewUnits(child)[1]
      break
    end
  end
  return PreviewFrame(group, unit or "player")
end

local function SamplesRegion(childId)
  local entry = Private.regions[childId]
  local region = entry and entry.region
  if region and region.secretAuraSamplesActive then return region end
end

function Display.ArrangeFlowPreview(group)
  if not group then return end
  local mode = group.blizzardFlowFrames
  local framed = mode == "UNITFRAME" or mode == "NAMEPLATE"
  if mode ~= "NAMEPLATE" then Display.ReleaseNameplatePreview(group) end
  local growth = GROWTH[GrowthKey(group)]
  local spacing = SpacingOf(group)
  local along = growth.sign[1] ~= 0
  local point, frameX, frameY = FramePosition(group)
  local function KeyOf(sample)
    return mode == "UNITFRAME" and sample.previewUnit or ""
  end
  local length, cross, firstKey = {}, {}, nil
  for _, childId in ipairs(group.controlledChildren or {}) do
    local region = SamplesRegion(childId)
    for _, sample in ipairs(region and (region.secretAuraSamples or {}) or {}) do
      local button = sample.button
      if button:IsShown() then
        local key = KeyOf(sample)
        firstKey = firstKey or key
        local width, height = button:GetWidth() or 0, button:GetHeight() or 0
        length[key] = (length[key] or 0) + (along and width or height) + spacing
        cross[key] = math.max(cross[key] or 0, along and height or width)
      end
    end
  end
  local function CenterOffset(key)
    if not growth.shadow then return 0, 0 end
    local half = math.max(0, (length[key] or 0) - spacing) / 2
    return -growth.sign[1] * half, -growth.sign[2] * half
  end
  local previous = {}
  local onFrame = false
  for _, childId in ipairs(group.controlledChildren or {}) do
    local region = SamplesRegion(childId)
    if region then
      local moved = false
      for _, sample in ipairs(region.secretAuraSamples or {}) do
        local button = sample.button
        if button:IsShown() then
          local key = KeyOf(sample)
          local frame = framed and PreviewFrame(group, sample.previewUnit or nil)
          local offsetX, offsetY = CenterOffset(key)
          local startPoint, farPoint = growth.start, growth.far
          if framed then
            local alignedStart, _, alignedFar = AlignedPoints(group, growth)
            startPoint, farPoint = alignedStart, alignedFar
          end
          button:ClearAllPoints()
          if previous[key] then
            button:SetPoint(startPoint, previous[key], farPoint, growth.sign[1] * spacing, growth.sign[2] * spacing)
          elseif frame then
            button:SetPoint(startPoint, frame, point, frameX + offsetX, frameY + offsetY)
          elseif growth.shadow then
            button:SetPoint(growth.start, region, growth.centerPoint, offsetX, offsetY)
          else
            button:SetPoint(growth.start, region, growth.start)
          end
          if frame and not moved then
            MovePreviewRegion(region, button)
            moved = true
          end
          onFrame = onFrame or frame ~= nil and frame ~= false
          previous[key] = button
        end
      end
      if not moved then Display.RestorePreviewRegion(region) end
    end
  end
  if not (onFrame and firstKey) then
    Display.RestoreGroupPreview(group)
    return
  end
  local offsetX, offsetY = CenterOffset(firstKey)
  local crossX, crossY = CrossOffset(group, growth, cross[firstKey] or 0)
  SetGroupPreviewBounds(group, growth, math.max(0, (length[firstKey] or 0) - spacing), cross[firstKey] or 0,
    offsetX + crossX, offsetY + crossY)
end

function Display.RechainFlow(group)
  if not group then return end
  if FRAMED_MODES[group.blizzardFlowFrames] then
    ScheduleStaleRebuilds(group)
    Display.RelinkFlowUnits(group)
    return
  end
  if InCombatLockdown() then return end
  local growth = GROWTH[group.blizzardFlowGrowth] or GROWTH.RIGHT
  local flows = CollectChainedFlows(group, growth)
  local previous
  if growth.shadow and flows[1] then
    previous = ChainShadowStarts(flows, growth, SpacingOf(group))
  end
  for _, flow in ipairs(flows) do
    flow.start:ClearAllPoints()
    local chained = previous and pcall(flow.start.SetPoint, flow.start, flow.growth.start,
      previous.endFrame, previous.endPoint, previous.x, previous.y)
    if not chained then
      flow.start:ClearAllPoints()
      flow.start:SetPoint(flow.growth.start, flow.region, flow.growth.start)
    end
    previous = flow
  end
end

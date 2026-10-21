-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Anchor = Private.AuraAnchor
local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local GLOW_FRAME_LEVEL_STEP = Shared.GLOW_FRAME_LEVEL_STEP
local SlotCount = Shared.SlotCount

Display.RetireFrame = Anchor.Retire
Display.LocateAnchor = Anchor.LocateAnchor
local lockedRegions = setmetatable({}, { __mode = "k" })

local function HasChanged(currentValue, isWanted)
  return issecretvalue(currentValue) or currentValue ~= isWanted
end

local function PackUnits(auraData)
  if Display.FlowGroup(auraData) and not Display.FlowFrameMode(auraData) then
    return SlotCount(Display.GetTrigger(auraData)) > 1
  end
  return auraData.anchorFrameType ~= "UNITFRAME" and not Display.UsesNameplates(auraData)
    and SlotCount(Display.GetTrigger(auraData)) > 1
end

local function LayoutInstance(displayInstance, auraRegion, auraData)
  local frameWidth, frameHeight = Display.Dimensions(auraData)
  local displayOptions = auraData.blizzardAuraDisplay
  local growth = Anchor.GrowthFor(Display.Growth(auraData))
  local drawn = growth.visible
  local isVertical = not drawn:IsHorizontal()
  local startPoint = drawn:StartPoint()
  local auraContainer = displayInstance.container
  auraContainer:ClearAllPoints()
  Anchor.Forget(auraContainer)
  if growth.centerPoint then
    auraContainer:SetPoint("CENTER", auraRegion, "CENTER")
  else
    Display.AnchorToContent(auraContainer, startPoint, auraRegion, startPoint)
  end
  auraContainer:SetFlowLayoutAxis(drawn:Axis())
  auraContainer:SetFlowLayoutAnchorPoint(startPoint)
  auraContainer:SetFlowLayoutGrowthDirection(drawn:Directions())
  local _, flowGap = Display.FlowGrowth(auraData)
  local gap = flowGap or displayOptions.spacing or 6
  local compactList = not growth.centerPoint and (PackUnits(auraData) or flowGap ~= nil)
  if Display.UsesGate(auraData) then gap = -(isVertical and frameHeight or frameWidth) end
  auraContainer:SetAuraGroupLayout("Auras", {
    elementWidth = frameWidth + (compactList and not isVertical and gap + 1 or 0),
    elementHeight = frameHeight + (compactList and isVertical and gap + 1 or 0),
    elementSpacing = compactList and -1 or gap,
  })
  auraContainer:SetAuraGroupMaxFrameCount("Auras", Display.MaxAuras(auraData))
end

local function AttachModes(auraData, attachMode)
  if Display.FlowGroup(auraData) then
    return attachMode == "UNITFRAME", attachMode == "NAMEPLATE"
  end
  local unitFrameMap = auraData.anchorFrameType == "UNITFRAME"
  return unitFrameMap, not unitFrameMap and Display.UsesNameplates(auraData)
end


local function Settle(auraContainer, isPlaced, ...)
  if isPlaced then Anchor.Remember(auraContainer, ...) else Anchor.Forget(auraContainer) end
end

local function AnchorContainer(auraContainer, point, relativeTo, relativePoint, x, y)
  if Anchor.Holds(auraContainer, point, relativeTo, relativePoint, x, y) then return end
  local status = Anchor.Attach(auraContainer, point, relativeTo, relativePoint, x, y)
  if status ~= "locked" then Settle(auraContainer, status == "ok", point, relativeTo, relativePoint, x, y) end
end

local function AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  local frameLevel = anchorTarget and displayOptions.unitGlow and anchorTarget:GetFrameLevel() + GLOW_FRAME_LEVEL_STEP + 3
    or parentFrame:GetFrameLevel() + 1
  if HasChanged(auraContainer:GetFrameLevel(), frameLevel) then auraContainer:SetFrameLevel(frameLevel) end
  if not attachMode then
    local point, relativePoint, x, y = Anchor.GroupPosition(auraData)
    AnchorContainer(auraContainer, point, anchorTarget or auraRegion, relativePoint, x, y)
  end
end

local function AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
  local point, relativePoint, x, y = "BOTTOM", "TOP", displayOptions.nameplateX or 0, displayOptions.nameplateY or 8
  if auraData.anchorFrameType == "NAMEPLATE" then
    point, relativePoint, x, y = Anchor.GroupPosition(auraData, "BOTTOM", "TOP")
  end
  AnchorContainer(auraContainer, point, anchorTarget or auraRegion, relativePoint, x, y)
end

local function AttachToList(displayState, position, auraContainer, auraRegion, auraData, growthDirection)
  local growth = Anchor.GrowthFor(growthDirection)
  local start = growth.visible:StartPoint()
  local point, relativeTo, relativePoint, x, y = start, Display.ContentAnchor(auraRegion), start, 0, 0
  local followsContent = true
  if growth.centerPoint then
    point, relativeTo, relativePoint, followsContent = "CENTER", auraRegion, "CENTER", false
  elseif PackUnits(auraData) and position > 1 then
    relativeTo = displayState.instances[position - 1].container
    relativePoint = growth:FrontPoint()
    x, y = growth:Overlap()
    followsContent = false
  end
  if Anchor.Holds(auraContainer, point, relativeTo, relativePoint, x, y) then return end
  local isPlaced
  if followsContent then
    isPlaced = Display.AnchorToContent(auraContainer, start, auraRegion, start)
  else
    isPlaced = Anchor.Attach(auraContainer, point, relativeTo, relativePoint, x, y) == "ok"
  end
  Settle(auraContainer, isPlaced, point, relativeTo, relativePoint, x, y)
end

local function PlaceInstance(auraRegion, displayInstance, auraData, position, parentFrame, anchorTarget, unitFrameMap, plateMap, growthDirection)
  local auraContainer = displayInstance.container
  local displayOptions = auraData.blizzardAuraDisplay
  local attachMode = Display.FlowFrameMode(auraData)
  local strataName = (auraData.frameStrata == nil or auraData.frameStrata == 1) and parentFrame:GetFrameStrata() or auraRegion:GetFrameStrata()
  if HasChanged(auraContainer:GetFrameStrata(), strataName) then auraContainer:SetFrameStrata(strataName) end
  if unitFrameMap then
    AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  elseif not attachMode then
    if plateMap then
      AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
    else
      AttachToList(auraRegion.blizzardAuraDisplay, position, auraContainer, auraRegion, auraData, growthDirection)
    end
  end
end

Shared.AttachModes = AttachModes
Shared.LayoutInstance = LayoutInstance
Shared.PlaceInstance = PlaceInstance
Shared.lockedRegions = lockedRegions

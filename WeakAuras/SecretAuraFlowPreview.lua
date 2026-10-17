-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Editor preview of a modern group. The sample buttons of its children are laid out like the real
-- containers would be: chained from the preview frame (a unit frame or the personal resource
-- display) or from their own region, in lines for the grid. The child regions follow their first
-- button, and the bounds of the group are replaced while the preview is on.
-- Registers in Display.

local AuraDisplay = Private.BlizzardAuraDisplay
local Anchor = Private.AuraAnchor
local Flow = Private.AuraFlow

local PREVIEW_UNIT_CAP = 5

-----------------------------------------------------------------------------------------------
-- Units and frame

function AuraDisplay.FlowPreviewUnits(auraData)
  if AuraDisplay.FlowFrameMode(auraData) ~= "UNITFRAME" then return { false } end
  local units = {}
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  for _, unit in ipairs(auraTrigger and AuraDisplay.UnitTokens(auraTrigger) or {}) do
    if #units >= PREVIEW_UNIT_CAP then break end
    if type(unit) == "string" and UnitExists(unit) and WeakAuras.GetUnitFrame(unit) then
      units[#units + 1] = unit
    end
  end
  if not units[1] then units[1] = "player" end
  return units
end

local function PreviewUnit(groupData)
  for _, id in ipairs(groupData.controlledChildren or {}) do
    local auraData = WeakAuras.GetData(id)
    if auraData and AuraDisplay.Enabled(auraData) then
      return AuraDisplay.FlowPreviewUnits(auraData)[1] or "player"
    end
  end
  return "player"
end

local function PreviewFrame(groupData, unit)
  local modern = Flow.Describe(groupData)
  if not (groupData.blizzardFlow and modern.mode) then return nil end
  local hostFrame
  if modern.mode == "NAMEPLATE" then
    if Private.ensurePRDFrame then Private.ensurePRDFrame() end
    hostFrame = Private.personalRessourceDisplayFrame
    if hostFrame and hostFrame.anchorFrame then hostFrame:anchorFrame(groupData.id, modern.mode) end
  else
    hostFrame = WeakAuras.GetUnitFrame(unit or PreviewUnit(groupData))
  end
  if hostFrame and hostFrame.IsForbidden and hostFrame:IsForbidden() then return nil end
  return hostFrame
end

-- Frame the group hangs on while the editor is open.
function AuraDisplay.FlowPreviewFrame(groupData, unit)
  if not WeakAuras.IsOptionsOpen() then return nil end
  return PreviewFrame(groupData, unit)
end

-----------------------------------------------------------------------------------------------
-- Restoring

function AuraDisplay.RestorePreviewRegion(childRegion)
  local saved = childRegion.flowPreviewSaved
  if not saved then return end
  childRegion.flowPreviewSaved = nil
  if saved.point and saved.relativeTo then
    childRegion:SetAnchor(saved.point, saved.relativeTo, saved.relativePoint)
  end
  childRegion:SetOffset(saved.x, saved.y)
end

local function GroupRegion(groupData)
  local registration = groupData and Private.regions[groupData.id]
  return registration and registration.region
end

function AuraDisplay.RestoreGroupPreview(groupData)
  local groupRegion = GroupRegion(groupData)
  if not (groupRegion and groupRegion.flowPreviewBoundsSaved) then return end
  if groupRegion.GetBoundingRect == groupRegion.flowPreviewBoundsFn then
    groupRegion.GetBoundingRect = groupRegion.flowPreviewBoundsSaved
  end
  groupRegion.flowPreviewBoundsSaved, groupRegion.flowPreviewBoundsFn = nil, nil
  groupRegion.boundingRect = false
  groupRegion:GetBoundingRect()
end

function AuraDisplay.ReleaseNameplatePreview(groupData)
  local hostFrame = Private.personalRessourceDisplayFrame
  if groupData and hostFrame and hostFrame.anchorFrame then hostFrame:delete(groupData.id) end
end

-----------------------------------------------------------------------------------------------
-- Layout

-- The shown samples of the children with an active preview, grid members or not.
local function Collect(groupData, modern, wantsGrid)
  local items = {}
  local isHorizontal = modern.growth.visible:IsHorizontal()
  for _, id in ipairs(groupData.controlledChildren or {}) do
    local registration = Private.regions[id]
    local childRegion = registration and registration.region
    local auraData = childRegion and WeakAuras.GetData(id)
    if auraData and childRegion.secretAuraSamplesActive and (AuraDisplay.GridMember(auraData) == true) == wantsGrid then
      local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
      for _, sample in ipairs(childRegion.secretAuraSamples or {}) do
        local isShown = sample.button:IsShown()
        if isShown then
          items[#items + 1] = {
            region = childRegion,
            button = sample.button,
            key = modern.mode == "UNITFRAME" and sample.previewUnit or "",
            width = iconWidth,
            height = iconHeight,
            along = isHorizontal and iconWidth or iconHeight,
          }
        end
      end
    end
  end
  return items
end

local Bounds = {}
Bounds.__index = Bounds

local function Span(point, first, second, anchor, size)
  if point:find(first, 1, true) then return anchor, anchor + size end
  if point:find(second, 1, true) then return anchor - size, anchor end
  return anchor - size / 2, anchor + size / 2
end

-- Adds the button placed by point at (x, y) from the origin of the group.
function Bounds:Add(point, x, y, iconWidth, iconHeight)
  local left, right = Span(point, "LEFT", "RIGHT", x, iconWidth)
  local bottom, top = Span(point, "BOTTOM", "TOP", y, iconHeight)
  self.left, self.right = math.min(self.left, left), math.max(self.right, right)
  self.bottom, self.top = math.min(self.bottom, bottom), math.max(self.top, top)
end

local function NewBounds()
  return setmetatable({ left = 0, right = 0, bottom = 0, top = 0 }, Bounds)
end

-- The first button of a region carries the region, once, and remembers where the region was.
local function Follow(childRegion, auraButton, point)
  if not childRegion.SetAnchor then return end
  if not childRegion.flowPreviewSaved and childRegion.relativeTo and childRegion.relativeTo ~= auraButton then
    childRegion.flowPreviewSaved = {
      point = childRegion.anchorPoint,
      relativeTo = childRegion.relativeTo,
      relativePoint = childRegion.relativePoint,
      x = childRegion.xOffset,
      y = childRegion.yOffset,
    }
  end
  childRegion:SetAnchor(point, auraButton, point)
  childRegion:SetOffset(0, 0)
end

-- Where the buttons of a key hang: the frame of their unit when there is one.
local function ChainItems(items, modern, frameFor, position, bounds, carried)
  local selfPoint, anchorPoint, x, y = unpack(position)
  local drawn, spacing = modern.growth.visible, modern.spacing
  local totals = {}
  for _, item in ipairs(items) do totals[item.key] = (totals[item.key] or 0) + item.along + spacing end
  local boundsKey = items[1] and items[1].key
  local previous, covered = {}, {}
  for _, item in ipairs(items) do
    local auraButton, key = item.button, item.key
    local hostFrame = frameFor(key)
    local starts = hostFrame and drawn:Aligned(selfPoint, false) or drawn:StartPoint()
    local ends = hostFrame and drawn:Aligned(selfPoint, true) or drawn:FrontPoint()
    local before = previous[key]
    auraButton:ClearAllPoints()
    local alongX, alongY = 0, 0
    if modern.growth.centerPoint then alongX, alongY = drawn:Step(-(totals[key] - spacing) / 2) end
    local cumulated = covered[key] or 0
    if before then
      local stepX, stepY = drawn:Step(spacing)
      auraButton:SetPoint(starts, before, ends, stepX, stepY)
    elseif hostFrame then
      auraButton:SetPoint(starts, hostFrame, anchorPoint, x + alongX, y + alongY)
    else
      auraButton:SetPoint(starts, item.region, modern.growth.centerPoint or drawn:StartPoint(), alongX, alongY)
    end
    if hostFrame then
      if key == boundsKey then
        bounds:Add(starts, alongX + drawn.signX * cumulated, alongY + drawn.signY * cumulated, item.width, item.height)
      end
      if not carried[item.region] then carried[item.region] = { button = auraButton, point = starts, chained = true } end
    end
    covered[key] = cumulated + item.along + spacing
    previous[key] = auraButton
  end
end

local function GridItems(items, groupData, modern, frameFor, position, carried)
  local _, anchorPoint, x, y = unpack(position)
  local shape = Flow.Grid.Shape(AuraDisplay.GridType(groupData))
  local perRow = Flow.Grid.PerRow(groupData)
  local alongSpace, betweenSpace = Flow.Grid.Spacings(groupData, modern, shape)
  local pitchWidth, pitchHeight, counts, previous, lineHead = {}, {}, {}, {}, {}
  for _, item in ipairs(items) do
    pitchWidth[item.key] = math.max(pitchWidth[item.key] or 0, item.width)
    pitchHeight[item.key] = math.max(pitchHeight[item.key] or 0, item.height)
  end
  for _, item in ipairs(items) do
    local key, auraButton = item.key, item.button
    local hostFrame = frameFor(key)
    local count = counts[key] or 0
    counts[key] = count + 1
    local column, row = count % perRow, math.floor(count / perRow)
    auraButton:ClearAllPoints()
    if hostFrame then
      local lineX, lineY = shape.line:Step(column * (pitchWidth[key] + alongSpace), column * (pitchHeight[key] + alongSpace))
      local rowX, rowY = shape.row:Step(row * (pitchWidth[key] + betweenSpace), row * (pitchHeight[key] + betweenSpace))
      auraButton:SetPoint(shape.corner, hostFrame, anchorPoint, x + lineX + rowX, y + lineY + rowY)
      if not carried[item.region] then carried[item.region] = { button = auraButton, point = shape.corner } end
    elseif count == 0 then
      auraButton:SetPoint(shape.corner, item.region, shape.corner, 0, 0)
    elseif column == 0 then
      local stepX, stepY = shape.row:Step(pitchWidth[key] + betweenSpace, pitchHeight[key] + betweenSpace)
      auraButton:SetPoint(shape.corner, lineHead[key], shape.corner, stepX, stepY)
    else
      local stepX, stepY = shape.line:Step(pitchWidth[key] + alongSpace, pitchHeight[key] + alongSpace)
      auraButton:SetPoint(shape.corner, previous[key], shape.corner, stepX, stepY)
    end
    if column == 0 then lineHead[key] = auraButton end
    previous[key] = auraButton
  end
end

local function ReplaceBounds(groupData, bounds)
  local boxRegion = GroupRegion(groupData)
  if boxRegion == nil then return end
  if boxRegion.GetBoundingRect ~= boxRegion.flowPreviewBoundsFn then
    boxRegion.flowPreviewBoundsSaved = boxRegion.GetBoundingRect
  end
  local rect = { bounds.left, bounds.bottom, bounds.right, bounds.top }
  boxRegion.flowPreviewBoundsFn = function() return rect[1], rect[2], rect[3], rect[4] end
  boxRegion.GetBoundingRect = boxRegion.flowPreviewBoundsFn
  boxRegion.blx, boxRegion.bly, boxRegion.trx, boxRegion.try = rect[1], rect[2], rect[3], rect[4]
end

function AuraDisplay.ArrangeFlowPreview(groupData)
  if not groupData then return end
  local modern = Flow.Describe(groupData)
  if modern.mode ~= "NAMEPLATE" then AuraDisplay.ReleaseNameplatePreview(groupData) end
  local frames = {}
  local function FrameFor(key)
    if frames[key] == nil then
      local unit = modern.mode == "UNITFRAME" and key ~= "" and key or nil
      frames[key] = PreviewFrame(groupData, unit) or false
    end
    return frames[key] or nil
  end
  local position = { Anchor.GroupPosition(groupData) }
  local bounds, carried = NewBounds(), {}

  ChainItems(Collect(groupData, modern, false), modern, FrameFor, position, bounds, carried)
  local gridItems = Collect(groupData, modern, true)
  if #gridItems > 0 then GridItems(gridItems, groupData, modern, FrameFor, position, carried) end

  local isFollowing = false
  for _, id in ipairs(groupData.controlledChildren or {}) do
    local registration = Private.regions[id]
    local childRegion = registration and registration.region
    if childRegion and childRegion.secretAuraSamples then
      local carrier = carried[childRegion]
      if carrier then
        -- Only chained samples feed the bounds; grid samples follow without resizing the mover.
        isFollowing = isFollowing or carrier.chained == true
        Follow(childRegion, carrier.button, carrier.point)
      else
        AuraDisplay.RestorePreviewRegion(childRegion)
      end
    end
  end
  if isFollowing then ReplaceBounds(groupData, bounds) else AuraDisplay.RestoreGroupPreview(groupData) end
end

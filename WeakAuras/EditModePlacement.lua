-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Placement with the Edit Mode of Blizzard: while it is open, each loaded top-level aura anchored to the screen gets a
-- labelled box over it, shown even when the aura is not. Dragging the box moves the aura and saves its offsets
-- through WeakAuras.Add, watched by the time machine so the move can be undone in /wa. Auras anchored to a unit, a
-- nameplate, the mouse or a custom frame, and groups that spread their children over unit frames, are left out:
-- their position depends on something else than their offsets.

local movableAnchors = { SCREEN = true, UIPARENT = true }
-- Under the selections of Blizzard, MEDIUM at level 1000, so the frames of the game stay on top.
local boxStrata, boxLevel = "MEDIUM", 900
-- Distance under which a dropped box sticks to the grid of the Edit Mode, the one Blizzard uses for its frames.
local snapDistance = 8
local boxes = {}
local unusedBoxes = {}
local active = false
local dragging = false
-- Offsets of the auras before their first move since the Edit Mode opened or its layout was saved, by uid.
local offsetsBeforeMove = {}
local RebuildBoxes
-- Parent of the boxes. The Edit Mode hides itself without "EditMode.Exit" while a settings panel of Blizzard or the
-- quick keybind mode is open, so the boxes follow the shown state of its frame too.
local holder = CreateFrame("Frame", nil, UIParent)
holder:SetAllPoints()

local function ScaleFromBoxToRegion(region)
  return UIParent:GetEffectiveScale() / region:GetEffectiveScale()
end

-- A group is a 2x2 frame at its anchor, its children spread around it in its bounding rectangle.
local function CoverRegion(box, region)
  box:ClearAllPoints()
  if region.GetBoundingRect then
    local left, bottom, right, top = region:GetBoundingRect()
    local scale = 1 / ScaleFromBoxToRegion(region)
    box:SetPoint("BOTTOMLEFT", region, "CENTER", left * scale, bottom * scale)
    box:SetSize(math.max(right - left, 16) * scale, math.max(top - bottom, 16) * scale)
  else
    box:SetAllPoints(region)
  end
end

-- Shift that puts the nearest of the given positions on a grid line, nil when none is close enough.
local function ShiftToGrid(center, spacing, ...)
  local best
  for i = 1, select("#", ...) do
    local position = select(i, ...)
    local shift = center + math.floor((position - center) / spacing + 0.5) * spacing - position
    if not best or math.abs(shift) < math.abs(best) then
      best = shift
    end
  end
  return best and math.abs(best) <= snapDistance and best or nil
end

-- Shift that sticks a dropped box to the grid, like the frames of Blizzard, when the snap option is on and the grid
-- is shown. Zero otherwise.
local function ShiftOfSnap(box)
  local manager = EditModeManagerFrame
  local grid = manager and manager.Grid
  if not (grid and grid:IsShown() and grid.gridSpacing and manager.IsSnapEnabled and manager:IsSnapEnabled()) then
    return 0, 0
  end
  local scale = grid:GetEffectiveScale() / box:GetEffectiveScale()
  local centerX, centerY = grid:GetCenter()
  local spacing = grid.gridSpacing * scale
  local left, bottom, width, height = box:GetLeft(), box:GetBottom(), box:GetWidth(), box:GetHeight()
  return ShiftToGrid(centerX * scale, spacing, left, left + width / 2, left + width) or 0,
    ShiftToGrid(centerY * scale, spacing, bottom, bottom + height / 2, bottom + height) or 0
end

local function RefreshOptions(id)
  if WeakAuras.IsOptionsOpen() and WeakAuras.ClearAndUpdateOptions then
    WeakAuras.ClearAndUpdateOptions(id)
  end
end

local function OnDragStart(box)
  box.startLeft, box.startBottom = box:GetLeft(), box:GetBottom()
  dragging = true
  box:StartMoving()
end

local function OnDragStop(box)
  box:StopMovingOrSizing()
  dragging = false
  local startLeft, startBottom = box.startLeft, box.startBottom
  box.startLeft, box.startBottom = nil, nil
  local data = WeakAuras.GetData(box.auraId)
  local region = WeakAuras.GetRegion(box.auraId)
  if data and region and startLeft then
    local shiftX, shiftY = ShiftOfSnap(box)
    local scale = ScaleFromBoxToRegion(region)
    if not offsetsBeforeMove[data.uid] then
      offsetsBeforeMove[data.uid] = { data.xOffset, data.yOffset }
    end
    Private.TimeMachine:Watch(data)
    data.xOffset = (data.xOffset or 0) + (box:GetLeft() + shiftX - startLeft) * scale
    data.yOffset = (data.yOffset or 0) + (box:GetBottom() + shiftY - startBottom) * scale
    -- WeakAuras.Add rebuilds the boxes, this one may now cover another aura or none.
    WeakAuras.Add(data, true)
    RefreshOptions(data.id)
    -- Blizzard enables "Revert All Changes" only for its own frames. The widget is set, no field of the manager.
    local revertButton = EditModeManagerFrame and EditModeManagerFrame.RevertAllChangesButton
    if revertButton then
      revertButton:SetEnabled(true)
    end
  else
    -- The aura was deleted while dragged: the rebuild skipped meanwhile is done now.
    RebuildBoxes()
  end
  region = box.auraId and WeakAuras.GetRegion(box.auraId)
  if region then
    CoverRegion(box, region)
  end
end

local function NewBox()
  local box = CreateFrame("Frame", nil, holder)
  box:SetFrameStrata(boxStrata)
  box:SetFrameLevel(boxLevel)
  box:SetMovable(true)
  box:EnableMouse(true)
  box:RegisterForDrag("LeftButton")
  box:SetScript("OnDragStart", OnDragStart)
  box:SetScript("OnDragStop", OnDragStop)
  local background = box:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0.1, 0.5, 0.9, 0.35)
  box.label = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  box.label:SetPoint("CENTER")
  return box
end

local function CanBePlaced(data, region)
  return data and not data.parent and movableAnchors[data.anchorFrameType or "SCREEN"]
    and not data.useAnchorPerUnit and not (data.blizzardFlow and data.blizzardFlowFrames)
    and region and not region:IsProtected()
end

local function RemoveBoxes()
  for id, box in pairs(boxes) do
    box:StopMovingOrSizing()
    box:Hide()
    box.auraId, box.startLeft, box.startBottom = nil, nil, nil
    tinsert(unusedBoxes, box)
    boxes[id] = nil
  end
  dragging = false
end

local function PlaceBoxes()
  for id in pairs(Private.loaded) do
    local data = WeakAuras.GetData(id)
    local region = data and not data.parent and Private.EnsureRegion(id)
    if CanBePlaced(data, region) then
      local box = tremove(unusedBoxes) or NewBox()
      box.auraId = id
      box.label:SetText(id)
      CoverRegion(box, region)
      box:Show()
      boxes[id] = box
    end
  end
end

-- An aura added, loaded, renamed or deleted while the Edit Mode is open gets, keeps or loses its box.
function RebuildBoxes()
  if active and not dragging then
    RemoveBoxes()
    PlaceBoxes()
  end
end

-- "Revert All Changes" of Blizzard puts the auras moved since the Edit Mode opened or was saved back too.
local function RevertMoves()
  for uid, offsets in pairs(offsetsBeforeMove) do
    local data = Private.GetDataByUID(uid)
    if data then
      Private.TimeMachine:Watch(data)
      data.xOffset, data.yOffset = offsets[1], offsets[2]
      WeakAuras.Add(data, true)
      RefreshOptions(data.id)
    end
  end
  wipe(offsetsBeforeMove)
end

local function FollowEditMode()
  local manager = EditModeManagerFrame
  if holder.followsEditMode or not manager then
    return
  end
  manager:HookScript("OnShow", function() holder:Show() end)
  manager:HookScript("OnHide", function()
    -- A drag cut by the hiding never gets its OnDragStop.
    dragging = false
    RebuildBoxes()
    holder:Hide()
  end)
  if manager.RevertAllChangesButton then
    manager.RevertAllChangesButton:HookScript("OnClick", RevertMoves)
  end
  holder.followsEditMode = true
end

local function ShowBoxes()
  FollowEditMode()
  active = true
  holder:Show()
  wipe(offsetsBeforeMove)
  RemoveBoxes()
  PlaceBoxes()
end

local function HideBoxes()
  active = false
  wipe(offsetsBeforeMove)
  RemoveBoxes()
end

--- The box over this aura while the Edit Mode is open, nil otherwise.
function Private.GetPlacementBox(id)
  return boxes[id]
end

for _, event in ipairs({ "Add", "Delete", "Rename", "ScanForLoads" }) do
  Private.callbacks:RegisterCallback(event, RebuildBoxes)
end

if EventRegistry and EventRegistry.RegisterCallback then
  EventRegistry:RegisterCallback("EditMode.Enter", ShowBoxes, boxes)
  EventRegistry:RegisterCallback("EditMode.Exit", HideBoxes, boxes)
  EventRegistry:RegisterCallback("EditMode.SavedLayouts", function() wipe(offsetsBeforeMove) end, offsetsBeforeMove)
end

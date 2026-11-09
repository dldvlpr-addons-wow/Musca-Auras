-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Placement with the Edit Mode of Blizzard: while it is open, each loaded aura anchored to the screen, top-level or in
-- a group, gets a labelled box over it, shown even when the aura is not. Dragging the box moves the aura and saves its offsets
-- through WeakAuras.Add, watched by the time machine so the move can be undone in /wa. Auras anchored to a unit, a
-- nameplate, the mouse or a custom frame, and groups that spread their children over unit frames, are left out:
-- their position depends on something else than their offsets. So are the children of a dynamic group, placed by it.

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

-- Whether the aura id is inside the group groupId, at any depth.
local function IsInside(id, groupId)
  local data = WeakAuras.GetData(id)
  while data and data.parent do
    if data.parent == groupId then
      return true
    end
    data = WeakAuras.GetData(data.parent)
  end
  return false
end

local function ScaleFromBoxToRegion(region)
  return UIParent:GetEffectiveScale() / region:GetEffectiveScale()
end

-- A group is a 2x2 frame at its anchor, its children spread around it in its bounding rectangle.
local function CoverRegion(box, region)
  box:ClearAllPoints()
  if region.GetBoundingRect then
    -- Cached by the group until it is added again: a text child may have changed its size since.
    region.boundingRect = false
    local left, bottom, right, top = region:GetBoundingRect()
    local scale = 1 / ScaleFromBoxToRegion(region)
    box:SetPoint("BOTTOMLEFT", region, "CENTER", left * scale, bottom * scale)
    box:SetSize(math.max(right - left, 16) * scale, math.max(top - bottom, 16) * scale)
  else
    box:SetAllPoints(region)
  end
end

-- Shift on one axis that puts an edge or, with centers, the center of the box on the best line, nil out of reach.
-- Without centers, the center of the box sticks to the screen and grid lines only, never to the edge of an aura.
local function ShiftOnAxis(screenLines, auraLines, positions, centers, low, middle, high)
  local Snap = Private.PlacementSnap
  local candidates, auraCandidates
  if centers then
    candidates = Snap.Candidates(screenLines, snapDistance, middle)
    auraCandidates = Snap.Candidates(auraLines, snapDistance, middle)
  else
    candidates = Snap.Candidates(screenLines, snapDistance, low, high, middle)
    auraCandidates = Snap.Candidates(auraLines, snapDistance, low, high)
  end
  for _, line in ipairs(auraCandidates) do
    candidates[#candidates + 1] = line
  end
  local best = Snap.Best(candidates, positions, snapDistance)
  return best and best.delta
end

-- Shift that sticks a dropped box, when the snap option of the Edit Mode is on and Shift is not held, to the edges
-- of the other boxes (not those of its own groups or children, which move with it), the edges of the screen and, when it is shown, the grid. Ctrl aligns the centers. nil, nil
-- without snap; nil on an axis without a line in reach.
local function ShiftOfSnap(box)
  local manager = EditModeManagerFrame
  if not (manager and manager.IsSnapEnabled and manager:IsSnapEnabled()) or IsShiftKeyDown() then
    return nil, nil
  end
  local Snap = Private.PlacementSnap
  local centers = IsControlKeyDown()
  local scale = UIParent:GetEffectiveScale() / box:GetEffectiveScale()
  local spacing, centerX, centerY
  local grid = manager.Grid
  if grid and grid:IsShown() and grid.gridSpacing then
    local gridScale = grid:GetEffectiveScale() / box:GetEffectiveScale()
    spacing = grid.gridSpacing * gridScale
    centerX, centerY = grid:GetCenter()
    centerX, centerY = centerX * gridScale, centerY * gridScale
  end
  local vertical, horizontal = {}, {}
  for _, position in ipairs(Snap.ScreenLines(UIParent:GetWidth() * scale, centerX or 0, spacing)) do
    vertical[#vertical + 1] = Snap.NewLine(position, true)
  end
  for _, position in ipairs(Snap.ScreenLines(UIParent:GetHeight() * scale, centerY or 0, spacing)) do
    horizontal[#horizontal + 1] = Snap.NewLine(position, true)
  end
  local auraVertical, auraHorizontal = {}, {}
  for id, other in pairs(boxes) do
    if other ~= box and not IsInside(box.auraId, id) and not IsInside(id, box.auraId) then
      local left, bottom, right, top = other:GetLeft(), other:GetBottom(), other:GetRight(), other:GetTop()
      local otherX, otherY = other:GetCenter()
      Snap.AddAuraLines(auraVertical, auraHorizontal, id, { left, bottom, right, top, otherX, otherY }, centers,
        true, true, Snap.NewLine)
    end
  end
  local left, bottom, width, height = box:GetLeft(), box:GetBottom(), box:GetWidth(), box:GetHeight()
  local positions = { LEFT = left, RIGHT = left + width, BOTTOM = bottom, TOP = bottom + height,
    CENTERX = left + width / 2, CENTERY = bottom + height / 2 }
  return ShiftOnAxis(vertical, Snap.MergeLines(auraVertical), positions, centers, left, left + width / 2, left + width),
    ShiftOnAxis(horizontal, Snap.MergeLines(auraHorizontal), positions, centers, bottom, bottom + height / 2,
      bottom + height)
end

local function RefreshOptions(id)
  if WeakAuras.IsOptionsOpen() and WeakAuras.ClearAndUpdateOptions then
    WeakAuras.ClearAndUpdateOptions(id)
  end
end

local arrowDirections = { UP = { 0, 1 }, DOWN = { 0, -1 }, LEFT = { -1, 0 }, RIGHT = { 1, 0 } }
--- Arrow keys on a shown frame call Move(deltaX, deltaY): one unit, ten with Shift, like the frames of Blizzard.
--- Move returns true when it moved something; the other keys go on to the game. EnableKeyboard is protected and
--- SetPropagateKeyboardInput restricted in combat: the keyboard is let go at PLAYER_REGEN_DISABLED when still
--- allowed, taken back at the end of combat, and the key up gives the keys back to the game, so a keyboard kept in
--- combat lets every key through.
function Private.MoveWithArrowKeys(frame, Move)
  frame:SetScript("OnKeyDown", function(self, key)
    if InCombatLockdown() then
      return
    end
    local direction = arrowDirections[key]
    local step = IsShiftKeyDown() and 10 or 1
    self:SetPropagateKeyboardInput(not (direction and Move(direction[1] * step, direction[2] * step)))
  end)
  frame:SetScript("OnKeyUp", function(self)
    if not InCombatLockdown() then
      self:SetPropagateKeyboardInput(true)
    end
  end)
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:SetScript("OnEvent", function(self, event)
    if not InCombatLockdown() then
      self:EnableKeyboard(event == "PLAYER_REGEN_ENABLED")
    end
  end)
  if not InCombatLockdown() then
    frame:SetPropagateKeyboardInput(true)
    frame:EnableKeyboard(true)
  end
end

-- Offsets of a moved aura saved through WeakAuras.Add, watched by the time machine, kept for "Revert All Changes".
local function SaveOffsets(data, xOffset, yOffset)
  if not offsetsBeforeMove[data.uid] then
    offsetsBeforeMove[data.uid] = { data.xOffset, data.yOffset }
  end
  -- The groups are watched too: their re-add below must not clear the history.
  Private.TimeMachine:Watch(data)
  data.xOffset, data.yOffset = xOffset, yOffset
  -- WeakAuras.Add rebuilds the boxes, a dragged one may now cover another aura or none.
  WeakAuras.Add(data, true)
  -- The groups of a moved child get their bounding rectangle again.
  Private.AddParents(data)
  RefreshOptions(data.id)
  -- Blizzard enables "Revert All Changes" only for its own frames. The widget is set, no field of the manager.
  local revertButton = EditModeManagerFrame and EditModeManagerFrame.RevertAllChangesButton
  if revertButton then
    revertButton:SetEnabled(true)
  end
end

-- The box clicked last takes the arrow keys, drawn brighter.
local selectedId
local function ColorBoxes()
  for id, box in pairs(boxes) do
    box.background:SetColorTexture(0.1, 0.5, 0.9, id == selectedId and 0.6 or 0.35)
  end
end

-- With Alt, the box of a group, which the boxes of its children may cover all of: the group of the clicked box, one
-- level higher on each click while the selected box is a group of it, back to the first group at the top.
local function Target(box)
  local data = IsAltKeyDown() and WeakAuras.GetData(box.auraId)
  if not (data and data.parent and boxes[data.parent]) then
    return box
  end
  local selected = selectedId and selectedId ~= box.auraId and IsInside(box.auraId, selectedId)
    and WeakAuras.GetData(selectedId)
  return selected and selected.parent and boxes[selected.parent] or boxes[data.parent]
end

local function OnMouseDown(box)
  selectedId = Target(box).auraId
  ColorBoxes()
end

local function MoveSelected(deltaX, deltaY)
  local data = not dragging and selectedId and boxes[selectedId] and WeakAuras.GetData(selectedId)
  if not data then
    return false
  end
  -- The axis not moved keeps its value, maybe stuck to a grid line.
  SaveOffsets(data, deltaX ~= 0 and Round(data.xOffset or 0) + deltaX or data.xOffset,
    deltaY ~= 0 and Round(data.yOffset or 0) + deltaY or data.yOffset)
  return true
end
-- Shown with the boxes only: outside the Edit Mode no key goes through the addon.
local arrowKeys = CreateFrame("Frame", nil, holder)
arrowKeys:Hide()
Private.MoveWithArrowKeys(arrowKeys, MoveSelected)

-- While dragged, a ghost of the box shows where the drop would stick it to the grid. Run only during the drag.
local function PreviewSnap(box)
  local shiftX, shiftY = ShiftOfSnap(box)
  local preview = box.snapPreview
  if shiftX or shiftY then
    preview:ClearAllPoints()
    preview:SetPoint("BOTTOMLEFT", box, "BOTTOMLEFT", shiftX or 0, shiftY or 0)
    preview:SetPoint("TOPRIGHT", box, "TOPRIGHT", shiftX or 0, shiftY or 0)
    preview:Show()
  else
    preview:Hide()
  end
end

local function StopPreview(box)
  box:SetScript("OnUpdate", nil)
  box.snapPreview:Hide()
end

local function OnDragStart(box)
  -- The mouse down came first and chose the box: the clicked one, or with Alt one of its groups, kept if Alt is let go.
  local selected = selectedId and boxes[selectedId]
  box.dragTarget = selected and (selectedId == box.auraId or IsInside(box.auraId, selectedId)) and selected or box
  box = box.dragTarget
  box.startLeft, box.startBottom = box:GetLeft(), box:GetBottom()
  dragging = true
  box:StartMoving()
  box:SetScript("OnUpdate", PreviewSnap)
end

local function OnDragStop(box)
  box.dragTarget, box = nil, box.dragTarget or box
  box:StopMovingOrSizing()
  StopPreview(box)
  dragging = false
  local startLeft, startBottom = box.startLeft, box.startBottom
  box.startLeft, box.startBottom = nil, nil
  local data = WeakAuras.GetData(box.auraId)
  local region = WeakAuras.GetRegion(box.auraId)
  if data and region and startLeft then
    local shiftX, shiftY = ShiftOfSnap(box)
    local scale = ScaleFromBoxToRegion(region)
    local xOffset = (data.xOffset or 0) + (box:GetLeft() + (shiftX or 0) - startLeft) * scale
    local yOffset = (data.yOffset or 0) + (box:GetBottom() + (shiftY or 0) - startBottom) * scale
    -- Whole units: readable X/Y in the options. An axis stuck to a grid line keeps its exact value.
    SaveOffsets(data, shiftX and xOffset or Round(xOffset), shiftY and yOffset or Round(yOffset))
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
  box:SetScript("OnMouseDown", OnMouseDown)
  box.background = box:CreateTexture(nil, "BACKGROUND")
  box.background:SetAllPoints()
  box.snapPreview = box:CreateTexture(nil, "BORDER")
  box.snapPreview:SetColorTexture(1, 0.82, 0, 0.35)
  box.snapPreview:Hide()
  box.label = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  box.label:SetPoint("CENTER")
  return box
end

-- A child moves by its offsets in its group: placed when its group is a simple group that can be placed itself.
-- A Modern Aura Group (blizzardFlow) chains the content of its children: they are not placed.
-- The region of the aura when it can be placed, made only then: a child of a dynamic group gets none.
local function PlacedRegion(data)
  if not (data and movableAnchors[data.anchorFrameType or "SCREEN"]
    and not data.useAnchorPerUnit and not (data.blizzardFlow and data.blizzardFlowFrames)) then
    return nil
  end
  local parentData = data.parent and WeakAuras.GetData(data.parent)
  if data.parent and not (parentData and parentData.regionType == "group" and not parentData.blizzardFlow
    and PlacedRegion(parentData)) then
    return nil
  end
  local region = Private.EnsureRegion(data.id)
  return region and not region:IsProtected() and region or nil
end

local function RemoveBoxes()
  for id, box in pairs(boxes) do
    box:StopMovingOrSizing()
    StopPreview(box)
    box:Hide()
    box.auraId, box.startLeft, box.startBottom, box.dragTarget = nil, nil, nil, nil
    tinsert(unusedBoxes, box)
    boxes[id] = nil
  end
  dragging = false
end

local function PlaceBoxes()
  for id in pairs(Private.loaded) do
    local data = WeakAuras.GetData(id)
    local region = PlacedRegion(data)
    if region then
      local box = tremove(unusedBoxes) or NewBox()
      -- A child over its group, one level per depth.
      local depth = 0
      local parent = data.parent
      while parent do
        depth = depth + 1
        parent = WeakAuras.GetData(parent) and WeakAuras.GetData(parent).parent
      end
      box:SetFrameLevel(boxLevel + depth)
      box.auraId = id
      box.label:SetText(id)
      CoverRegion(box, region)
      box:Show()
      boxes[id] = box
    end
  end
  ColorBoxes()
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
      Private.AddParents(data)
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
  -- A Blizzard frame clicked takes the selection: the arrow keys no longer move an aura.
  if manager.SelectSystem then
    hooksecurefunc(manager, "SelectSystem", function()
      selectedId = nil
      ColorBoxes()
    end)
  end
  holder.followsEditMode = true
end

local function ShowBoxes()
  FollowEditMode()
  active = true
  holder:Show()
  arrowKeys:Show()
  wipe(offsetsBeforeMove)
  RemoveBoxes()
  PlaceBoxes()
end

local function HideBoxes()
  active = false
  selectedId = nil
  arrowKeys:Hide()
  wipe(offsetsBeforeMove)
  RemoveBoxes()
end

--- The box over this aura while the Edit Mode is open, nil otherwise.
function Private.GetPlacementBox(id)
  return boxes[id]
end

-- The selection follows a renamed aura and is lost with a deleted one, before the boxes are rebuilt.
Private.callbacks:RegisterCallback("Rename", function(_, _, oldid, newid)
  if selectedId == oldid then
    selectedId = newid
  end
end)
Private.callbacks:RegisterCallback("Delete", function(_, _, id)
  if selectedId == id then
    selectedId = nil
  end
end)
for _, event in ipairs({ "Add", "Delete", "Rename", "ScanForLoads" }) do
  Private.callbacks:RegisterCallback(event, RebuildBoxes)
end

if EventRegistry and EventRegistry.RegisterCallback then
  EventRegistry:RegisterCallback("EditMode.Enter", ShowBoxes, boxes)
  EventRegistry:RegisterCallback("EditMode.Exit", HideBoxes, boxes)
  EventRegistry:RegisterCallback("EditMode.SavedLayouts", function() wipe(offsetsBeforeMove) end, offsetsBeforeMove)
end

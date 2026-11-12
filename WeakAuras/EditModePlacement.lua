-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Placement with the Edit Mode of Blizzard: while it is open, each loaded aura anchored to the screen, top-level or in
-- a group, gets a labelled box over it, shown even when the aura is not. Dragging the box moves the aura and saves its offsets
-- through WeakAuras.Add, watched by the time machine so the move can be undone in /wa. Auras anchored to a unit, a
-- nameplate, the mouse or a custom frame, and groups that spread their children over unit frames, are left out:
-- their position depends on something else than their offsets. So are the children of a dynamic group, placed by it.
-- An aura linked to another aura keeps its box: its offsets place it from its target. The Anchor link of a hovered
-- box links it to the next box clicked, on the side picked in the anchor menu, in place.

-- The same boxes serve the placement mode of Musca (/wa unlock), through another host: see Private.PlacementBoxes.

local movableAnchors = { SCREEN = true, UIPARENT = true }
local AnchorLinks = Private.AnchorLinks
local Style = Private.Style
local L = WeakAuras.L
-- Distance under which a dropped box sticks to a line, shared with /wa.
local snapDistance = Private.PlacementSnap.snapDistance
local boxes = {}
local unusedBoxes = {}
local active = false
local dragging = false
-- Placement of the auras (offsets, size, anchor) before their first change since the Edit Mode opened or its layout
-- was saved, by uid.
local offsetsBeforeMove = {}
local placementFields = { "xOffset", "yOffset", "width", "height", "anchorFrameType", "anchorFrameFrame",
  "anchorFrameParent", "selfPoint", "anchorPoint", "grow", "align", "space" }
-- With the load fields set by the right click menu.
local loadFields = { "use_never", "use_combat" }
local function RememberPlacement(data)
  if not offsetsBeforeMove[data.uid] then
    local placement = { load = {} }
    for _, field in ipairs(placementFields) do
      placement[field] = data[field]
    end
    for _, field in ipairs(loadFields) do
      placement.load[field] = data.load[field]
    end
    offsetsBeforeMove[data.uid] = placement
  end
end

-- Blizzard enables "Revert All Changes" only for its own frames, and sets it again at each of its changes, saves
-- and reverts: enabled too while an aura moved since the Edit Mode opened or was saved. The widget is set, no field
-- of the manager.
local function UpdateRevertButton()
  local manager = EditModeManagerFrame
  local revertButton = manager and manager.RevertAllChangesButton
  if revertButton then
    revertButton:SetEnabled(next(offsetsBeforeMove) ~= nil
      or (manager.HasActiveChanges and manager:HasActiveChanges() and true or false))
  end
end

-- What the boxes depend on. The Edit Mode of Blizzard: under its selections, MEDIUM at level 1000, so the frames of the
-- game stay on top; its snap option and grid; the loaded auras. The placement mode of Musca gives its own host.
-- Grid returns the spacing and the center of the grid lines in UIParent units, nil without a grid shown.
local editModeHost = {
  strata = "MEDIUM",
  level = 900,
  backgroundAlpha = 0.95,
  SnapEnabled = function()
    local manager = EditModeManagerFrame
    return manager and manager.IsSnapEnabled and manager:IsSnapEnabled()
  end,
  Grid = function()
    local grid = EditModeManagerFrame and EditModeManagerFrame.Grid
    if grid and grid:IsShown() and grid.gridSpacing then
      local scale = grid:GetEffectiveScale() / UIParent:GetEffectiveScale()
      local centerX, centerY = grid:GetCenter()
      return grid.gridSpacing * scale, centerX * scale, centerY * scale
    end
  end,
  -- The loaded auras, and those disabled from the menu since the last save: their box stays to enable them again.
  Ids = function()
    local ids = {}
    for id in pairs(Private.loaded) do
      ids[id] = true
    end
    for uid in pairs(offsetsBeforeMove) do
      local data = Private.GetDataByUID(uid)
      if data and data.load.use_never then
        ids[data.id] = true
      end
    end
    return ids
  end,
  OnChange = UpdateRevertButton,
}
local host = editModeHost
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
    -- A box kept at 16 to stay clickable snaps with the true edges of its group: the part added is left out.
    box.snapInsetX = math.max(16 - (right - left), 0) * scale
    box.snapInsetY = math.max(16 - (top - bottom), 0) * scale
  else
    box:SetAllPoints(region)
    box.snapInsetX, box.snapInsetY = 0, 0
  end
end

-- The edges the box snaps with: its own, less the part added to a small group to keep it clickable.
local function SnapRect(box)
  local left, bottom = box:GetLeft(), box:GetBottom()
  local right, top = box:GetRight() - (box.snapInsetX or 0), box:GetTop() - (box.snapInsetY or 0)
  return left, bottom, right, top
end

-- Shift on one axis that puts an edge or, with centers, the center of the box on the best line, nil out of reach.
-- Without centers, the center of the box sticks to the screen and grid lines only, never to the edge of an aura.
-- A spacing line only snaps the edge of its side: low for LEFT and BOTTOM, high for RIGHT and TOP.
local function ShiftOnAxis(screenLines, auraLines, positions, centers, low, middle, high, spacingLines)
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
  local lowSpacing, highSpacing = {}, {}
  for _, line in ipairs(spacingLines or {}) do
    local side = line.references[1].side
    table.insert((side == "LEFT" or side == "BOTTOM") and lowSpacing or highSpacing, line)
  end
  for _, line in ipairs(Snap.Candidates(lowSpacing, snapDistance, low)) do
    candidates[#candidates + 1] = line
  end
  for _, line in ipairs(Snap.Candidates(highSpacing, snapDistance, high)) do
    candidates[#candidates + 1] = line
  end
  local best = Snap.Best(candidates, positions, snapDistance)
  return best and best.delta, best
end

-- Shift that sticks a dropped box, when the snap option of the Edit Mode is on and Shift is not held, to the edges
-- of the other boxes (not those of its own groups or children, which move with it), the edges of the screen and, when it is shown, the grid. Ctrl aligns the centers. nil, nil
-- without snap; nil on an axis without a line in reach. Then the chosen lines, positions in box units. With sizing,
-- the box is resized from its bottom right corner: only its right and bottom edges stick, never its center.
local function ShiftOfSnap(box, sizing)
  if not host.SnapEnabled() or IsShiftKeyDown() then
    return nil, nil
  end
  local Snap = Private.PlacementSnap
  local centers = not sizing and IsControlKeyDown()
  local scale = UIParent:GetEffectiveScale() / box:GetEffectiveScale()
  -- Without the grid, the middle of the screen; with it, its lines through its center.
  local centerX, centerY = UIParent:GetCenter()
  local spacing, gridX, gridY = host.Grid()
  if spacing then
    spacing, centerX, centerY = spacing * scale, gridX, gridY
  end
  centerX, centerY = centerX * scale, centerY * scale
  local vertical, horizontal = {}, {}
  for _, position in ipairs(Snap.ScreenLines(UIParent:GetWidth() * scale, centerX, spacing)) do
    vertical[#vertical + 1] = Snap.NewLine(position, true)
  end
  for _, position in ipairs(Snap.ScreenLines(UIParent:GetHeight() * scale, centerY, spacing)) do
    horizontal[#horizontal + 1] = Snap.NewLine(position, true)
  end
  -- The other boxes do not move during a drag: their lines are built once per mode, reset at each mouse down.
  local mode = centers and "centers" or sizing and "sizing" or "edges"
  box.otherLines = box.otherLines or {}
  local others = box.otherLines[mode]
  if not others then
    local auraVertical, auraHorizontal, rects = {}, {}, {}
    local spacingVertical, spacingHorizontal = {}, {}
    for id, other in pairs(boxes) do
      -- Nor those of the auras that follow it through a link.
      if other ~= box and not IsInside(box.auraId, id) and not IsInside(id, box.auraId)
      and not AnchorLinks.DependsOn(id, box.auraId) then
        local left, bottom, right, top = SnapRect(other)
        Snap.AddAuraLines(auraVertical, auraHorizontal, id, { left, bottom, right, top, (left + right) / 2,
          (bottom + top) / 2 }, centers, true, true, Snap.NewLine)
        rects[#rects + 1] = { id = id, left = left, bottom = bottom, right = right, top = top }
      end
    end
    if not (centers or sizing) then
      Snap.AddSpacingLines(spacingVertical, spacingHorizontal, rects, 2 * snapDistance, Snap.NewLine)
    end
    others = { Snap.MergeLines(auraVertical), Snap.MergeLines(auraHorizontal), spacingVertical, spacingHorizontal }
    box.otherLines[mode] = others
  end
  local auraVertical, auraHorizontal, spacingVertical, spacingHorizontal = unpack(others)
  local left, bottom = box:GetLeft(), box:GetBottom()
  local width, height = box:GetWidth() - (box.snapInsetX or 0), box:GetHeight() - (box.snapInsetY or 0)
  local positions = { LEFT = left, RIGHT = left + width, BOTTOM = bottom, TOP = bottom + height,
    CENTERX = left + width / 2, CENTERY = bottom + height / 2 }
  local shiftX, lineX = ShiftOnAxis(vertical, auraVertical, positions, centers,
    not sizing and left or nil, not sizing and left + width / 2 or nil, left + width, spacingVertical)
  local shiftY, lineY = ShiftOnAxis(horizontal, auraHorizontal, positions, centers, bottom,
    not sizing and bottom + height / 2 or nil, not sizing and bottom + height or nil, spacingHorizontal)
  return shiftX, shiftY, lineX, lineY
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

-- Offsets of a moved aura, and with width the size of a resized one, saved through WeakAuras.Add, watched by the
-- time machine, kept for "Revert All Changes".
local function SaveOffsets(data, xOffset, yOffset, width, height)
  RememberPlacement(data)
  -- The groups are watched too: their re-add below must not clear the history.
  Private.TimeMachine:Watch(data)
  data.xOffset, data.yOffset = xOffset, yOffset
  if width then
    data.width, data.height = width, height
  end
  -- WeakAuras.Add rebuilds the boxes, a dragged one may now cover another aura or none.
  WeakAuras.Add(data, true)
  -- The groups of a moved child get their bounding rectangle again.
  Private.AddParents(data)
  if width and WeakAuras.UpdateThumbnail then
    WeakAuras.UpdateThumbnail(data)
  end
  RefreshOptions(data.id)
  host.OnChange()
end

-- The box clicked last takes the arrow keys, drawn with a brass border. During a drag, the boxes of the auras the
-- drop would stick to, references[id] true, get a frost border. While a link is picked, the auras that cannot be its
-- target, as they follow the aura linked, get a red border. The box under the mouse is lighter.
local selectedId
-- The aura of the Anchor link clicked, until its target is clicked.
local linkSource
local hoveredBox
-- Brass outline of the selected box, drawn above the boxes of its children, which may cover all of a group; no mouse.
local selectionOutline = CreateFrame("Frame", nil, holder, "BackdropTemplate")
selectionOutline:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
selectionOutline:SetBackdropBorderColor(Style.Color("primary"))
selectionOutline:EnableMouse(false)
selectionOutline:Hide()
local function ColorBoxes(references)
  local selectedBox = selectedId and boxes[selectedId]
  if selectedBox then
    selectionOutline:ClearAllPoints()
    selectionOutline:SetAllPoints(selectedBox)
    selectionOutline:SetFrameStrata(host.strata)
    selectionOutline:SetFrameLevel(host.level + 40)
  end
  selectionOutline:SetShown(selectedBox and true or false)
  -- Over a child of the selected group, the group lights up: a drag from there moves the group.
  local litBox = hoveredBox
  if litBox and selectedBox and not linkSource and litBox.auraId ~= selectedId and litBox.auraId
    and IsInside(litBox.auraId, selectedId) then
    litBox = selectedBox
  end
  -- The box of the group is under the boxes of its children: its outline shows the mouse over it.
  selectionOutline:SetBackdropBorderColor(Style.Color(selectedBox and litBox == selectedBox and "primaryHover"
    or "primary"))
  for id, box in pairs(boxes) do
    local border = "boxBorder"
    if references and references[id] then
      border = "snapGuide"
    elseif id == selectedId or id == linkSource then
      border = "primary"
    elseif linkSource and AnchorLinks.DependsOn(id, linkSource) then
      border = "error"
    elseif box == litBox then
      border = "boxBorderHover"
    end
    box:SetBackdropBorderColor(Style.Color(border))
    box:SetBackdropColor(Style.Color("boxBackground",
      math.min(host.backgroundAlpha + (box == litBox and 0.15 or 0), 1)))
    box.highlight:SetShown(id == selectedId)
    box.sizer:SetShown(id == selectedId and box.resizable or false)
  end
end

-- Depth of the selection, from the widest to the narrowest: the panel of /wa unlock lists the groups of the selected
-- aura to select one of them; a click inside the selected group selects one level lower (see OnMouseDown); Alt, below.
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

local function Select(id)
  local box = id and id ~= selectedId and boxes[id]
  selectedId = id
  ColorBoxes()
  if box then
    box.pulse:Play()
  end
  if host.OnSelect then
    host.OnSelect(id)
  end
end

-- Value of a load field shared by the aura, or by all the auras of a group; "mixed" when they differ. Never is true
-- or nil.
local function LoadState(data, field)
  local state, seen
  for child in Private.TraverseLeafsOrAura(data) do
    local value = child.load[field]
    if field == "use_never" then
      value = value and true or nil
    end
    if seen and value ~= state then
      return "mixed"
    end
    state, seen = value, true
  end
  return state
end

-- Sets a load field on the aura, or on all the auras of a group, watched by the time machine and kept for "Revert
-- All Changes".
local function SetLoad(id, field, value)
  local data = WeakAuras.GetData(id)
  if not data then
    return
  end
  for child in Private.TraverseLeafsOrAura(data) do
    RememberPlacement(child)
    Private.TimeMachine:Watch(child)
    child.load[field] = value
    WeakAuras.Add(child)
  end
  RefreshOptions(id)
  host.OnChange()
end

-- The aura in the options. /wa unlock ends first, its changes kept, as /wa does.
local function EditInOptions(id)
  if host.Leave then
    host.Leave()
  end
  if not WeakAuras.IsOptionsOpen() then
    WeakAuras.OpenOptions()
  end
  if WeakAuras.IsOptionsOpen() and WeakAuras.PickDisplay then
    WeakAuras.PickDisplay(id)
  end
end

-- Right click menu: when the aura shows (load "In Combat": nil always, true in combat, false out of combat), whether
-- it loads at all (load "Never"), and its options in /wa. The current choice in brass.
local function ShowAuraMenu(id)
  local data = WeakAuras.GetData(id)
  local combat = LoadState(data, "use_combat")
  local disabled = LoadState(data, "use_never") == true
  local function Show(text, value)
    return { text = text, color = combat == value and "primary" or "text",
      onPick = function() SetLoad(id, "use_combat", value) end }
  end
  AnchorLinks.ShowChoices({
    Show(L["Show always"], nil),
    Show(L["Show in combat"], true),
    Show(L["Show out of combat"], false),
    { text = disabled and L["Enable"] or L["Disable"], color = disabled and "primary" or "error",
      onPick = function() SetLoad(id, "use_never", not disabled or nil) end },
    { text = L["Edit in /wa"], onPick = function() EditInOptions(id) end },
  })
end

-- The aura one level under the selected group on the way to the aura id: its child that is id or holds it.
local function OneLevelLower(id)
  local data = WeakAuras.GetData(id)
  while data and data.parent and data.parent ~= selectedId do
    data = WeakAuras.GetData(data.parent)
  end
  return data and boxes[data.id] and data.id or id
end

local PickLinkTarget
local function OnMouseDown(box, button)
  -- Another click during a move or a resize keeps the selection: a hidden sizer would miss its mouse up.
  if dragging then
    return
  end
  if linkSource then
    PickLinkTarget(Target(box).auraId, button)
    return
  end
  -- A left click inside the selected group keeps it, for a drag of the whole group from any of its children. Let go
  -- without a drag, it selects one level lower: group, subgroup, aura.
  if button == "LeftButton" and not IsAltKeyDown() and selectedId and box.auraId ~= selectedId
    and IsInside(box.auraId, selectedId) then
    box.clickedLower = OneLevelLower(box.auraId)
    return
  end
  Select(Target(box).auraId)
  if button == "RightButton" then
    ShowAuraMenu(selectedId)
  end
end

local function OnMouseUp(box)
  local lower = box.clickedLower
  box.clickedLower = nil
  if lower and not dragging then
    Select(lower)
  end
end

local function MoveSelected(deltaX, deltaY)
  local data = not dragging and not linkSource and not AnchorLinks.MenuShown() and selectedId and boxes[selectedId]
    and WeakAuras.GetData(selectedId)
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

-- Alignment guides: during a drag, the line of each axis the drop would stick the box to.
-- Above the boxes, under the selections of Blizzard; no mouse.
local guides = CreateFrame("Frame", nil, holder)
guides:SetAllPoints()
local function NewGuide()
  local guide = guides:CreateTexture(nil, "OVERLAY")
  guide:SetColorTexture(Style.Color("snapGuide"))
  guide:Hide()
  return guide
end
local verticalGuide, horizontalGuide = NewGuide(), NewGuide()

-- Shows the guide on the line (positions in box units, the same as the guides frame), hides it without a line. A
-- screen or grid line goes across the screen; the line of other auras from the dragged box to the farthest of them.
local function ShowGuide(guide, line, vertical, box)
  if not line then
    guide:Hide()
    return
  end
  local position = line.position
  local low, high
  if not line.gridLine and line.references[1] then
    if vertical then
      low, high = box:GetBottom(), box:GetTop()
    else
      low, high = box:GetLeft(), box:GetRight()
    end
    for _, ref in ipairs(line.references) do
      low, high = math.min(low, ref.pos1), math.max(high, ref.pos2)
    end
  end
  guide:ClearAllPoints()
  if vertical and low then
    guide:SetPoint("BOTTOM", guides, "BOTTOMLEFT", position, low)
    guide:SetSize(2, high - low)
  elseif vertical then
    guide:SetPoint("TOP", guides, "TOPLEFT", position, 0)
    guide:SetPoint("BOTTOM", guides, "BOTTOMLEFT", position, 0)
    guide:SetWidth(2)
  elseif low then
    guide:SetPoint("LEFT", guides, "BOTTOMLEFT", low, position)
    guide:SetSize(high - low, 2)
  else
    guide:SetPoint("LEFT", guides, "BOTTOMLEFT", 0, position)
    guide:SetPoint("RIGHT", guides, "BOTTOMRIGHT", 0, position)
    guide:SetHeight(2)
  end
  guide:Show()
end

-- The auras of the lines, as a set of ids.
local function ReferencedAuras(lineX, lineY)
  local references = {}
  for _, line in ipairs({ lineX or {}, lineY or {} }) do
    for _, ref in ipairs(line.references or {}) do
      references[ref.id] = true
    end
  end
  return references
end

-- Link marker of a hovered or dragged linked box: its target framed, the two points of the link shown.
local linkMarker = AnchorLinks.CreateMarker(guides)
local function ShowLinkMarker(box)
  local data = WeakAuras.GetData(box.auraId)
  local targetId = data and AnchorLinks.TargetAura(data)
  local region = targetId and WeakAuras.GetRegion(targetId)
  if not region then
    linkMarker:Hide()
    return
  end
  AnchorLinks.ShowMarker(linkMarker, box, boxes[targetId] or region, region, data)
end

local linkHint = Style.NewText(guides, "title", "l")
linkHint:SetShadowOffset(1, -1)
linkHint:SetShadowColor(0, 0, 0, 0.9)
linkHint:SetPoint("TOP", guides, "TOP", 0, -120)
linkHint:Hide()

local function CancelLink()
  linkSource = nil
  linkHint:Hide()
  ColorBoxes()
end

local function StartLink(id)
  linkSource, selectedId = id, id
  linkHint:SetText(L["Click the aura %s will follow. Right click: cancel."]:format(id))
  linkHint:Show()
  ColorBoxes()
end

-- Links the aura sourceId to targetId on the side, or unlinks it without a side, in place, kept for "Revert All
-- Changes" and watched by the time machine.
local function LinkTo(sourceId, targetId, side)
  local data, region = WeakAuras.GetData(sourceId), WeakAuras.GetRegion(sourceId)
  local target = WeakAuras.GetRegion(targetId)
  if not (data and region and target) or (side and AnchorLinks.DependsOn(targetId, sourceId)) then
    return
  end
  RememberPlacement(data)
  local done
  if side then
    done = AnchorLinks.LinkInPlace(data, region, target, "WeakAuras:" .. targetId, side)
  else
    done = AnchorLinks.UnlinkInPlace(data, region)
  end
  if not done then
    return
  end
  WeakAuras.Add(data)
  Private.AddParents(data)
  RefreshOptions(data.id)
  host.OnChange()
end

-- A left click on a box that may be the target opens the anchor menu; any other click cancels.
function PickLinkTarget(targetId, button)
  local sourceId = linkSource
  if button ~= "LeftButton" or targetId == sourceId then
    CancelLink()
    return
  end
  if AnchorLinks.DependsOn(targetId, sourceId) then
    return
  end
  CancelLink()
  AnchorLinks.ShowMenu(AnchorLinks.TargetAura(WeakAuras.GetData(sourceId)) ~= nil, function(side)
    LinkTo(sourceId, targetId, side)
  end)
end

-- Offsets the aura gets at the drop of the box with these shifts, nil when the aura or the drag start is gone.
-- Whole units: readable X/Y in the options. An axis stuck to a line keeps its exact value.
local function DropOffsets(box, shiftX, shiftY)
  local data = WeakAuras.GetData(box.auraId)
  local region = WeakAuras.GetRegion(box.auraId)
  if not (data and region and box.startLeft) then
    return nil
  end
  local scale = ScaleFromBoxToRegion(region)
  local xOffset = (data.xOffset or 0) + (box:GetLeft() + (shiftX or 0) - box.startLeft) * scale
  local yOffset = (data.yOffset or 0) + (box:GetBottom() + (shiftY or 0) - box.startBottom) * scale
  return shiftX and xOffset or Round(xOffset), shiftY and yOffset or Round(yOffset), data
end

-- While dragged, a ghost of the box shows where the drop would stick it to the grid, the guides the lines it
-- sticks to, the auras of these lines, and the label the offsets of the drop. Run only during the drag.
local function PreviewSnap(box)
  local shiftX, shiftY, lineX, lineY = ShiftOfSnap(box)
  local xOffset, yOffset = DropOffsets(box, shiftX, shiftY)
  if xOffset then
    box.label:SetText(("(%.2f, %.2f)"):format(xOffset, yOffset))
  end
  ShowGuide(verticalGuide, lineX, true, box)
  ShowGuide(horizontalGuide, lineY, false, box)
  ColorBoxes(ReferencedAuras(lineX, lineY))
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
  box.label:SetText(box.auraId)
  verticalGuide:Hide()
  horizontalGuide:Hide()
end

local function OnDragStart(box)
  -- No drag while a link target is picked or the anchor menu is open.
  if linkSource or AnchorLinks.MenuShown() then
    return
  end
  -- A drag, not a click: the selected group stays selected.
  box.clickedLower = nil
  -- The mouse down came first and chose the box: the clicked one, or with Alt one of its groups, kept if Alt is let go.
  local selected = selectedId and boxes[selectedId]
  local target = selected and (selectedId == box.auraId or IsInside(box.auraId, selectedId)) and selected or box
  -- A box without a rect would start its move from the bottom left of the screen: refused, as OnDragStop expects.
  if not target:GetLeft() then
    return
  end
  box.dragTarget = target
  box = target
  box.startLeft, box.startBottom = box:GetLeft(), box:GetBottom()
  box.otherLines = nil
  dragging = true
  box:StartMoving()
  box:SetScript("OnUpdate", PreviewSnap)
  box.anchorButton:Hide()
  ShowLinkMarker(box)
end

local function OnDragStop(box)
  -- A drag refused at its start.
  if not box.dragTarget then
    return
  end
  box.dragTarget, box = nil, box.dragTarget or box
  linkMarker:Hide()
  box:StopMovingOrSizing()
  StopPreview(box)
  ColorBoxes()
  dragging = false
  local xOffset, yOffset, data = DropOffsets(box, ShiftOfSnap(box))
  box.startLeft, box.startBottom = nil, nil
  if xOffset then
    SaveOffsets(data, xOffset, yOffset)
  else
    -- The aura was deleted while dragged: the rebuild skipped meanwhile is done now.
    RebuildBoxes()
  end
  local region = box.auraId and WeakAuras.GetRegion(box.auraId)
  if region then
    CoverRegion(box, region)
  end
end

-- Size the aura gets at the release of the sizer with these shifts of its right and bottom edges, then its offsets:
-- its top left corner stays, wherever its own anchor point is. nil when the aura or the sizing start is gone. Whole
-- units, except on an axis stuck to a line.
local function DropSize(box, shiftX, shiftY)
  local data = WeakAuras.GetData(box.auraId)
  local region = WeakAuras.GetRegion(box.auraId)
  if not (data and region and box.sizing and data.width and data.height) then
    return nil
  end
  -- The change of the box since the press, added to the saved size: an animation or a condition that scales the
  -- region shows a box of another size, which must not be saved.
  local scale = ScaleFromBoxToRegion(region)
  local width = data.width + (box:GetWidth() + (shiftX or 0) - box.startWidth) * scale
  local height = data.height + (box:GetHeight() - (shiftY or 0) - box.startHeight) * scale
  width = math.max(shiftX and width or Round(width), 1)
  height = math.max(shiftY and height or Round(height), 1)
  local deltaWidth, deltaHeight = width - data.width, height - data.height
  local selfPoint = data.selfPoint or "CENTER"
  local xOffset, yOffset = data.xOffset or 0, data.yOffset or 0
  if selfPoint:find("RIGHT") then
    xOffset = xOffset + deltaWidth
  elseif not selfPoint:find("LEFT") then
    xOffset = xOffset + deltaWidth / 2
  end
  if selfPoint:find("BOTTOM") then
    yOffset = yOffset - deltaHeight
  elseif not selfPoint:find("TOP") then
    yOffset = yOffset - deltaHeight / 2
  end
  return width, height, xOffset, yOffset, data
end

-- While resized, the ghost shows the size the release would stick the box to, the guides and the auras of the lines,
-- and the label the size of the release.
local function PreviewSize(box)
  -- At the size of the press, the release saves nothing: no snap shown, ghost and guides hidden.
  local shiftX, shiftY, lineX, lineY
  if box:GetWidth() ~= box.startWidth or box:GetHeight() ~= box.startHeight then
    shiftX, shiftY, lineX, lineY = ShiftOfSnap(box, true)
  end
  local width, height = DropSize(box, shiftX, shiftY)
  if width then
    box.label:SetText(("(%.2f, %.2f)"):format(width, height))
  end
  ShowGuide(verticalGuide, lineX, true, box)
  ShowGuide(horizontalGuide, lineY, false, box)
  ColorBoxes(ReferencedAuras(lineX, lineY))
  local preview = box.snapPreview
  if shiftX or shiftY then
    -- Kept at least 1 wide and high, as the saved size: a line behind the fixed corner would turn the ghost over.
    local previewX = math.max(shiftX or 0, 1 - box:GetWidth())
    local previewY = math.min(shiftY or 0, box:GetHeight() - 1)
    preview:ClearAllPoints()
    preview:SetPoint("TOPLEFT", box, "TOPLEFT")
    preview:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", previewX, previewY)
    preview:Show()
  else
    preview:Hide()
  end
end

-- The left button only, as the drag of the box.
local function OnSizerDown(sizer, button)
  local box = sizer:GetParent()
  -- A box without a rect would be pinned at the bottom left of the screen.
  if dragging or button ~= "LeftButton" or linkSource or AnchorLinks.MenuShown() or not box:GetLeft() then
    return
  end
  box.sizing = true
  box.startWidth, box.startHeight = box:GetWidth(), box:GetHeight()
  box.otherLines = nil
  -- One TOPLEFT anchor, as every frame Blizzard sizes: SetAllPoints may keep StartSizing from resizing the box.
  -- CoverRegion puts the box back on its aura at the mouse up.
  local left, top = box:GetLeft(), box:GetTop()
  box:ClearAllPoints()
  box:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", left, top)
  box:SetSize(box.startWidth, box.startHeight)
  dragging = true
  box:StartSizing("BOTTOMRIGHT")
  box:SetScript("OnUpdate", PreviewSize)
end

local function OnSizerUp(sizer, button)
  local box = sizer:GetParent()
  if not box.sizing or button ~= "LeftButton" then
    return
  end
  box:StopMovingOrSizing()
  StopPreview(box)
  ColorBoxes()
  dragging = false
  -- A click without a move changes nothing: no snap, no rounding.
  local moved = box:GetWidth() ~= box.startWidth or box:GetHeight() ~= box.startHeight
  local width, height, xOffset, yOffset, data = DropSize(box, ShiftOfSnap(box, true))
  box.sizing, box.startWidth, box.startHeight = nil, nil, nil
  if moved and width then
    SaveOffsets(data, xOffset, yOffset, width, height)
  else
    RebuildBoxes()
  end
  local region = box.auraId and WeakAuras.GetRegion(box.auraId)
  if region then
    CoverRegion(box, region)
  end
end

-- The Anchor link of a box shows from the mouse entering the box until it leaves both the box and the link. A
-- child box over its group takes it: the group box gets its OnLeave then.
local function OnBoxEnter(box)
  hoveredBox = box
  ColorBoxes()
  box.anchorButton:SetShown(not (dragging or linkSource))
  if not dragging then
    ShowLinkMarker(box)
  end
end

local function OnBoxLeave(box)
  if hoveredBox == box then
    hoveredBox = nil
    ColorBoxes()
  end
  if not box.anchorButton:IsMouseOver() then
    box.anchorButton:Hide()
  end
  if not dragging then
    linkMarker:Hide()
  end
end

local function NewBox()
  local box = CreateFrame("Frame", nil, holder, "BackdropTemplate")
  box:SetMovable(true)
  box:EnableMouse(true)
  box:RegisterForDrag("LeftButton")
  box:SetScript("OnDragStart", OnDragStart)
  box:SetScript("OnDragStop", OnDragStop)
  box:SetScript("OnMouseDown", OnMouseDown)
  box:SetScript("OnMouseUp", OnMouseUp)
  box:SetScript("OnEnter", OnBoxEnter)
  box:SetScript("OnLeave", OnBoxLeave)
  box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
  box.highlight = box:CreateTexture(nil, "ARTWORK")
  box.highlight:SetAllPoints()
  box.highlight:SetColorTexture(Style.Color("boxBackgroundSelected"))
  box.highlight:Hide()
  -- Selected: the fill beats twice, then stays.
  box.pulse = box.highlight:CreateAnimationGroup()
  for beat = 0, 1 do
    Style.AddFade(box.pulse, 1, 0.35, 0.125, beat * 0.25, "OUT")
    Style.AddFade(box.pulse, 0.35, 1, 0.125, beat * 0.25 + 0.125, "IN")
  end
  box.pulse:SetToFinalAlpha(true)
  box.snapPreview = box:CreateTexture(nil, "BORDER")
  -- Frost at a quarter: the deep snapTarget alone vanishes under the veil and the box fill.
  box.snapPreview:SetColorTexture(Style.Color("snapGuide", 0.25))
  box.snapPreview:Hide()
  -- The name on a plate over the top left corner, outside the box: the aura stays visible under it.
  box.label = Style.NewText(box, "text", "xs", "textSecondary")
  box.label:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 4, 3)
  local plate = box:CreateTexture(nil, "ARTWORK")
  plate:SetColorTexture(Style.Color("labelBackground"))
  plate:SetPoint("TOPLEFT", box.label, "TOPLEFT", -4, 2)
  plate:SetPoint("BOTTOMRIGHT", box.label, "BOTTOMRIGHT", 4, -2)
  -- Over the top right corner, outside the box: a small box keeps its name readable.
  box.anchorButton = CreateFrame("Button", nil, box, "BackdropTemplate")
  box.anchorButton:SetSize(52, 16)
  box.anchorButton:SetPoint("BOTTOMRIGHT", box, "TOPRIGHT")
  Style.Fill(box.anchorButton, "raised", "borderField")
  local anchorText = Style.NewText(box.anchorButton, "text", "xs")
  anchorText:SetPoint("CENTER")
  anchorText:SetText(L["Anchor"])
  box.anchorButton:SetScript("OnEnter", function(button) button:SetBackdropBorderColor(Style.Color("primary")) end)
  box.anchorButton:SetScript("OnClick", function(button)
    button:Hide()
    StartLink(button:GetParent().auraId)
  end)
  -- Back into the box, its OnEnter shows the link again.
  box.anchorButton:SetScript("OnLeave", function(button)
    button:SetBackdropBorderColor(Style.Color("borderField"))
    button:Hide()
  end)
  box.anchorButton:Hide()
  -- Resize from the bottom right corner, shown on the selected box of an aura with a width and a height.
  box:SetResizable(true)
  box:SetResizeBounds(1, 1)
  box.sizer = CreateFrame("Frame", nil, box)
  box.sizer:SetSize(10, 10)
  box.sizer:SetPoint("BOTTOMRIGHT")
  box.sizer:EnableMouse(true)
  box.sizer:SetScript("OnMouseDown", OnSizerDown)
  box.sizer:SetScript("OnMouseUp", OnSizerUp)
  -- A handle of 6 in the corner, caught on 10.
  local grip = box.sizer:CreateTexture(nil, "OVERLAY")
  grip:SetSize(6, 6)
  grip:SetPoint("BOTTOMRIGHT")
  grip:SetColorTexture(Style.Color("primary"))
  box.sizer:Hide()
  return box
end

-- A child moves by its offsets in its group: placed when its group is a simple group that can be placed itself.
-- A Modern Aura Group (blizzardFlow) chains the content of its children: they are not placed.
-- The region of the aura when it can be placed, made only then: a child of a dynamic group gets none. An aura linked
-- to another aura is placed by its offsets from it.
local function PlacedRegion(data)
  if not (data and (movableAnchors[data.anchorFrameType or "SCREEN"] or AnchorLinks.TargetAura(data))
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
    box.auraId, box.startLeft, box.startBottom, box.dragTarget, box.sizing = nil, nil, nil, nil, nil
    box.clickedLower = nil
    tinsert(unusedBoxes, box)
    boxes[id] = nil
  end
  selectionOutline:Hide()
  dragging = false
  linkMarker:Hide()
end

local function PlaceBoxes()
  for id in pairs(host.Ids()) do
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
      box:SetFrameStrata(host.strata)
      box:SetFrameLevel(host.level + depth)
      box:SetBackdropColor(Style.Color("boxBackground", host.backgroundAlpha))
      box.auraId = id
      box.label:SetText(id)
      -- Disabled (load "Never"): dimmed.
      box:SetAlpha(LoadState(data, "use_never") == true and 0.45 or 1)
      CoverRegion(box, region)
      -- Not a group: its size comes from its children.
      box.resizable = region:IsResizable() and data.width and data.height and not region.GetBoundingRect and true
        or false
      box:Show()
      boxes[id] = box
    end
  end
  if selectedId and not boxes[selectedId] then
    selectedId = nil
  end
  ColorBoxes()
  -- The host shows the placement of the selected aura, maybe changed.
  if host.OnSelect then
    host.OnSelect(selectedId)
  end
end

-- An aura added, loaded, renamed or deleted while the Edit Mode is open gets, keeps or loses its box.
function RebuildBoxes()
  if active and not dragging then
    RemoveBoxes()
    PlaceBoxes()
  end
end

-- "Revert All Changes" of Blizzard puts the auras moved, resized or linked since the Edit Mode opened or was saved
-- back too.
local function RevertMoves()
  for uid, placement in pairs(offsetsBeforeMove) do
    local data = Private.GetDataByUID(uid)
    if data then
      Private.TimeMachine:Watch(data)
      for _, field in ipairs(placementFields) do
        data[field] = placement[field]
      end
      for _, field in ipairs(loadFields) do
        data.load[field] = placement.load[field]
      end
      WeakAuras.Add(data)
      Private.AddParents(data)
      RefreshOptions(data.id)
      if WeakAuras.UpdateThumbnail then
        WeakAuras.UpdateThumbnail(data)
      end
    end
  end
  wipe(offsetsBeforeMove)
  host.OnChange()
end

local function FollowEditMode()
  local manager = EditModeManagerFrame
  if holder.followsEditMode or not manager then
    return
  end
  manager:HookScript("OnShow", function()
    if host == editModeHost then
      holder:Show()
    end
  end)
  manager:HookScript("OnHide", function()
    if host ~= editModeHost then
      return
    end
    -- A drag cut by the hiding never gets its OnDragStop.
    dragging = false
    RebuildBoxes()
    holder:Hide()
  end)
  if manager.RevertAllChangesButton then
    manager.RevertAllChangesButton:HookScript("OnClick", function()
      if host == editModeHost then
        RevertMoves()
      end
    end)
  end
  if manager.SetHasActiveChanges then
    hooksecurefunc(manager, "SetHasActiveChanges", UpdateRevertButton)
  end
  -- A Blizzard frame clicked takes the selection: the arrow keys no longer move an aura.
  if manager.SelectSystem then
    hooksecurefunc(manager, "SelectSystem", function()
      if host == editModeHost then
        selectedId = nil
        ColorBoxes()
      end
    end)
  end
  holder.followsEditMode = true
end

-- keepChanges keeps the placements to revert, as when the placement mode of Musca comes back after a combat.
local function ShowBoxes(newHost, keepChanges)
  if newHost == editModeHost then
    FollowEditMode()
  end
  host = newHost
  active = true
  guides:SetFrameStrata(host.strata)
  guides:SetFrameLevel(host.level + 50)
  holder:Show()
  arrowKeys:Show()
  if not keepChanges then
    wipe(offsetsBeforeMove)
  end
  RemoveBoxes()
  PlaceBoxes()
end

local function HideBoxes(keepChanges)
  active = false
  selectedId = nil
  CancelLink()
  AnchorLinks.HideMenu()
  arrowKeys:Hide()
  if not keepChanges then
    wipe(offsetsBeforeMove)
  end
  RemoveBoxes()
end

--- The boxes for another host than the Edit Mode: the placement mode of Musca. The host table has the fields of
--- editModeHost, OnSelect(id) called with the selected aura or nil, and Leave() called when the Edit Mode opens.
Private.PlacementBoxes = {
  Show = ShowBoxes,
  Hide = HideBoxes,
  Revert = function() RevertMoves() end,
  HasChanges = function() return next(offsetsBeforeMove) ~= nil end,
  -- The changes are kept: nothing left to revert.
  Forget = function() wipe(offsetsBeforeMove) end,
  Remember = RememberPlacement,
  Selected = function() return selectedId end,
  Select = Select,
  StartLink = StartLink,
  Unlink = function(id)
    local data = WeakAuras.GetData(id)
    local targetId = data and AnchorLinks.TargetAura(data)
    if targetId then
      LinkTo(id, targetId)
    end
  end,
  --- Closes the top layer: the anchor menu, the link being picked, then the selection. false when none was open.
  Escape = function()
    if AnchorLinks.MenuShown() then
      AnchorLinks.HideMenu()
    elseif linkSource then
      CancelLink()
    elseif selectedId then
      Select(nil)
    else
      return false
    end
    return true
  end,
}

--- The box over this aura while the Edit Mode is open, nil otherwise.
function Private.GetPlacementBox(id)
  return boxes[id]
end

--- The vertical and horizontal alignment guides of the Edit Mode drag.
function Private.GetPlacementGuides()
  return verticalGuide, horizontalGuide
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
  EventRegistry:RegisterCallback("EditMode.Enter", function()
    -- The placement mode of Musca closes first, its changes kept, even suspended by a combat.
    if host ~= editModeHost and host.Leave then
      host.Leave()
    end
    ShowBoxes(editModeHost)
  end, boxes)
  EventRegistry:RegisterCallback("EditMode.Exit", function()
    if host == editModeHost then
      HideBoxes()
    end
  end, boxes)
  EventRegistry:RegisterCallback("EditMode.SavedLayouts", function()
    if host == editModeHost then
      wipe(offsetsBeforeMove)
      UpdateRevertButton()
    end
  end, offsetsBeforeMove)
end

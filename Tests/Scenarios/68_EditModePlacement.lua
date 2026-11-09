local function Icon(id, anchorFrameType, parent)
  return {
    id = id, uid = id, parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
    anchorFrameType = anchorFrameType, xOffset = 10, yOffset = -5,
  }
end

-- Placement with the Edit Mode: while it is open, the top-level auras anchored to the screen get a box, even when
-- not shown; dragging the box moves the aura by the same distance. Children of a simple group get one too, children
-- of a dynamic group and mouse-anchored auras none.
return function(test)
  local saved = { displays = {
    Free = Icon("Free", "SCREEN"),
    Mouse = Icon("Mouse", "MOUSE"),
    Pack = {
      id = "Pack", uid = "Pack", regionType = "group", internalVersion = 91, controlledChildren = { "Inner" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
    Inner = Icon("Inner", "SCREEN", "Pack"),
    Outer = {
      id = "Outer", uid = "Outer", regionType = "group", internalVersion = 91, controlledChildren = { "Sub" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
  } }
  saved.displays.Scaled = {}
  saved.displays.PerUnit = {}
  for key, value in pairs(saved.displays.Pack) do
    saved.displays.Scaled[key], saved.displays.PerUnit[key] = value, value
  end
  saved.displays.Scaled.id, saved.displays.Scaled.uid = "Scaled", "Scaled"
  saved.displays.Scaled.controlledChildren, saved.displays.Scaled.scale = {}, 2
  saved.displays.PerUnit.id, saved.displays.PerUnit.uid = "PerUnit", "PerUnit"
  saved.displays.PerUnit.controlledChildren, saved.displays.PerUnit.useAnchorPerUnit = {}, true
  saved.displays.Sub = {}
  for key, value in pairs(saved.displays.Outer) do
    saved.displays.Sub[key] = value
  end
  saved.displays.Sub.id, saved.displays.Sub.uid, saved.displays.Sub.parent = "Sub", "Sub", "Outer"
  saved.displays.Sub.controlledChildren, saved.displays.Sub.xOffset = { "Leaf" }, 100
  saved.displays.Leaf = Icon("Leaf", "SCREEN", "Sub")
  saved.displays.Flow = {}
  for key, value in pairs(saved.displays.Outer) do
    saved.displays.Flow[key] = value
  end
  saved.displays.Flow.id, saved.displays.Flow.uid, saved.displays.Flow.blizzardFlow = "Flow", "Flow", true
  saved.displays.Flow.controlledChildren, saved.displays.Flow.xOffset = { "FlowKid" }, -300
  saved.displays.FlowKid = Icon("FlowKid", "SCREEN", "Flow")
  saved.displays.Dyn = {
    id = "Dyn", uid = "Dyn", regionType = "dynamicgroup", internalVersion = 91, controlledChildren = { "DynKid" },
    load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
  saved.displays.DynKid = Icon("DynKid", "SCREEN", "Dyn")
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  assert(private.GetPlacementBox("Free") == nil, "no box before the Edit Mode")

  -- The harness has no Edit Mode frame: a plain one stands for it.
  _G.EditModeManagerFrame = CreateFrame("Frame", nil, UIParent)
  local revertButton = CreateFrame("Button", nil, EditModeManagerFrame)
  EditModeManagerFrame.RevertAllChangesButton = revertButton
  EditModeManagerFrame.SelectSystem = function() end
  -- Regions made only for the auras that get a box.
  local EnsureRegion, ensured = private.EnsureRegion, {}
  private.EnsureRegion = function(id, ...)
    ensured[id] = true
    return EnsureRegion(id, ...)
  end
  EventRegistry:TriggerEvent("EditMode.Enter")
  private.EnsureRegion = EnsureRegion
  assert(ensured.Free and not ensured.DynKid and not ensured.FlowKid, "no region asked for a child of a dynamic group")
  local box = private.GetPlacementBox("Free")
  assert(box and box:IsVisible(), "box over a hidden screen aura")
  assert(private.GetPlacementBox("Pack"), "box over a group")
  assert(private.GetPlacementBox("Inner") and private.GetPlacementBox("Leaf"), "box for a child of a simple group")
  assert(private.GetPlacementBox("Dyn"), "box for a dynamic group")
  assert(not private.GetPlacementBox("DynKid") and not private.GetPlacementBox("Mouse"),
    "no box for a child of a dynamic group or the mouse")
  assert(private.GetPlacementBox("Flow") and not private.GetPlacementBox("FlowKid"),
    "no box for a child of a Modern Aura Group, which chains its children")
  assert(private.GetPlacementBox("Inner"):GetFrameLevel() > private.GetPlacementBox("Pack"):GetFrameLevel(),
    "child box over the box of its group")
  assert(not private.GetPlacementBox("PerUnit"), "no box for a group spread over unit frames")
  assert(box:GetFrameStrata() == "MEDIUM" and box:GetFrameLevel() < 1000, "boxes under the selections of Blizzard")
  local _, _, outerRight = WeakAuras.GetRegion("Outer"):GetBoundingRect()
  assert(outerRight == 142, "rectangle of a group placed with the offsets of its sub group")
  WeakAuras.GetData("Sub").scale = 2
  WeakAuras.GetRegion("Outer").boundingRect = false
  _, _, outerRight = WeakAuras.GetRegion("Outer"):GetBoundingRect()
  assert(outerRight == 284, "offsets of a scaled sub group drawn at its scale, got " .. tostring(outerRight))
  WeakAuras.GetData("Sub").scale = nil
  WeakAuras.GetRegion("Outer").boundingRect = false

  box:GetScript("OnDragStart")(box)
  local left, bottom = box:GetLeft(), box:GetBottom()
  box.GetLeft = function() return left + 30 end
  box.GetBottom = function() return bottom - 12 end
  box:GetScript("OnDragStop")(box)
  box.GetLeft, box.GetBottom = nil, nil
  local data = WeakAuras.GetData("Free")
  assert(data.xOffset == 40 and data.yOffset == -17, "drag moves the aura by the same distance")
  private.TimeMachine:StepBackward()
  data = WeakAuras.GetData("Free")
  assert(data.xOffset == 10 and data.yOffset == -5, "drag undone")

  -- Offsets rounded at the drop (WeakAuras.Add rebuilt the boxes: take the current one).
  local roundedBox = private.GetPlacementBox("Free")
  roundedBox:GetScript("OnDragStart")(roundedBox)
  local roundedLeft, roundedBottom = roundedBox:GetLeft(), roundedBox:GetBottom()
  roundedBox.GetLeft = function() return roundedLeft + 30.6 end
  roundedBox.GetBottom = function() return roundedBottom - 12.4 end
  roundedBox:GetScript("OnDragStop")(roundedBox)
  roundedBox.GetLeft, roundedBox.GetBottom = nil, nil
  data = WeakAuras.GetData("Free")
  assert(data.xOffset == 41 and data.yOffset == -17, "offsets rounded at the drop, got "
    .. tostring(data.xOffset) .. ", " .. tostring(data.yOffset))
  private.TimeMachine:StepBackward()

  local scaledBox = private.GetPlacementBox("Scaled")
  scaledBox:GetScript("OnDragStart")(scaledBox)
  local scaledLeft = scaledBox:GetLeft()
  scaledBox.GetLeft = function() return scaledLeft + 30 end
  scaledBox:GetScript("OnDragStop")(scaledBox)
  scaledBox.GetLeft = nil
  assert(WeakAuras.GetData("Scaled").xOffset == 15, "drag of a scaled group in its own units")

  -- The harness centers every frame on 500, 400: the boxes other than Free are put away, Pack at 708 to 724 on x,
  -- the others at 100 to 116, all at 100 to 116 on y, so that their edges are snap targets at known places.
  -- WeakAuras.Add rebuilds the boxes from a pool after each drop: called again before each drag.
  local function PutOthersAway()
    for id in pairs(private.loaded) do
      local other = private.GetPlacementBox(id)
      if other and id == "Free" then
        other.GetLeft, other.GetRight, other.GetCenter, other.GetBottom, other.GetTop = nil, nil, nil, nil, nil
        -- The harness SetAllPoints keeps the size of the recycled box: the size of the icon.
        other:SetSize(64, 64)
      elseif other then
        local left = id == "Pack" and 708 or 100
        other.GetLeft = function() return left end
        other.GetRight = function() return left + 16 end
        other.GetCenter = function() return left + 8, 108 end
        other.GetBottom = function() return 100 end
        other.GetTop = function() return 116 end
      end
    end
  end
  local function Drag(dragged, deltaX)
    PutOthersAway()
    dragged:GetScript("OnDragStart")(dragged)
    local startLeft = dragged:GetLeft()
    dragged.GetLeft = function() return startLeft + deltaX end
    dragged:GetScript("OnDragStop")(dragged)
    dragged.GetLeft = nil
  end

  WeakAuras.Add(Icon("Late", "SCREEN"))
  assert(private.GetPlacementBox("Late"), "box for an aura added in the Edit Mode")
  WeakAuras.Delete(WeakAuras.GetData("Late"))
  assert(not private.GetPlacementBox("Late"), "box removed with its aura")

  -- Deleted while dragged: the box goes at the drop.
  WeakAuras.Add(Icon("Late", "SCREEN"))
  local lateBox = private.GetPlacementBox("Late")
  lateBox:GetScript("OnDragStart")(lateBox)
  WeakAuras.Delete(WeakAuras.GetData("Late"))
  lateBox:GetScript("OnDragStop")(lateBox)
  assert(not private.GetPlacementBox("Late"), "box of an aura deleted while dragged removed at the drop")

  -- Hidden while dragged, without OnDragStop: the next changes still rebuild the boxes.
  local freeBox = private.GetPlacementBox("Free")
  freeBox:GetScript("OnDragStart")(freeBox)
  EditModeManagerFrame:Hide()
  EditModeManagerFrame:Show()
  WeakAuras.Add(Icon("Late", "SCREEN"))
  assert(private.GetPlacementBox("Late"), "boxes rebuilt after a drag cut by the hiding")
  WeakAuras.Delete(WeakAuras.GetData("Late"))

  local revertEnabled
  revertButton.SetEnabled = function(_, enabled) revertEnabled = enabled end
  Drag(private.GetPlacementBox("Free"), 30)
  assert(WeakAuras.GetData("Free").xOffset == 40, "moved before the revert")
  assert(revertEnabled == true, "a move enables Revert All Changes")
  revertButton:GetScript("OnClick")(revertButton)
  assert(WeakAuras.GetData("Free").xOffset == 10, "Revert All Changes puts the aura back")
  Drag(private.GetPlacementBox("Free"), 30)
  EventRegistry:TriggerEvent("EditMode.SavedLayouts")
  revertButton:GetScript("OnClick")(revertButton)
  assert(WeakAuras.GetData("Free").xOffset == 40, "a saved layout keeps the move")

  -- Placement 5: the box clicked last takes the arrow keys, kept through the rebuild of each move.
  local arrowKeys
  for _, child in ipairs({ private.GetPlacementBox("Free"):GetParent():GetChildren() }) do
    if child:GetScript("OnKeyDown") then
      arrowKeys = child
    end
  end
  local OnKeyDown = arrowKeys and arrowKeys:GetScript("OnKeyDown")
  assert(OnKeyDown and arrowKeys:IsVisible() and arrowKeys:IsKeyboardEnabled(), "arrow keys in the Edit Mode")
  OnKeyDown(arrowKeys, "RIGHT")
  assert(WeakAuras.GetData("Free").xOffset == 40 and arrowKeys:GetPropagateKeyboardInput(), "no move without a selection")
  local clicked = private.GetPlacementBox("Free")
  clicked:GetScript("OnMouseDown")(clicked, "LeftButton")
  OnKeyDown(arrowKeys, "RIGHT")
  OnKeyDown(arrowKeys, "DOWN")
  assert(WeakAuras.GetData("Free").xOffset == 41 and WeakAuras.GetData("Free").yOffset == -6
    and not arrowKeys:GetPropagateKeyboardInput(), "arrow keys move the selected aura")
  -- A Blizzard frame clicked takes the selection from the aura.
  EditModeManagerFrame:SelectSystem({})
  OnKeyDown(arrowKeys, "RIGHT")
  assert(WeakAuras.GetData("Free").xOffset == 41 and arrowKeys:GetPropagateKeyboardInput(),
    "no key move after a Blizzard frame is selected")
  revertButton:GetScript("OnClick")(revertButton)
  assert(WeakAuras.GetData("Free").xOffset == 40, "Revert All Changes undoes the key moves")

  -- Grid lines every 100 from the center of the grid, at 500 in the harness: a box dropped 3 off a line sticks to it.
  local grid = CreateFrame("Frame", nil, EditModeManagerFrame)
  grid.gridSpacing = 100
  EditModeManagerFrame.Grid = grid
  local snapEnabled = false
  EditModeManagerFrame.IsSnapEnabled = function() return snapEnabled end
  local freeBox = private.GetPlacementBox("Free")
  local deltaToLine = 503 - freeBox:GetLeft()
  Drag(freeBox, deltaToLine)
  assert(WeakAuras.GetData("Free").xOffset == 40 + deltaToLine, "no snap with the option off")
  snapEnabled = true
  freeBox = private.GetPlacementBox("Free")
  local before = WeakAuras.GetData("Free").xOffset
  local deltaToSnap = 500 - freeBox:GetLeft()
  -- Placement 3: during the drag, a ghost shows the snapped place, 3 left of the box; none out of reach.
  PutOthersAway()
  freeBox:GetScript("OnDragStart")(freeBox)
  local previewStart = freeBox:GetLeft()
  freeBox.GetLeft = function() return previewStart + deltaToSnap + 3 end
  freeBox:GetScript("OnUpdate")(freeBox, 0)
  local _, previewAnchor, _, previewX, previewY = freeBox.snapPreview:GetPoint(1)
  assert(freeBox.snapPreview:IsShown() and previewAnchor == freeBox and previewX == -3 and previewY == 0,
    "snap ghost 3 left of the dragged box, got " .. tostring(previewX))
  freeBox.GetLeft = function() return previewStart + deltaToSnap + 50 end
  freeBox:GetScript("OnUpdate")(freeBox, 0)
  _, _, _, previewX, previewY = freeBox.snapPreview:GetPoint(1)
  -- The box center is on the line at y 400: the ghost stays, unshifted on x.
  assert(freeBox.snapPreview:IsShown() and previewX == 0 and previewY == 0, "x out of reach: ghost not shifted on x")
  -- No line in reach on either axis: no ghost.
  local previewBottom = freeBox:GetBottom()
  freeBox.GetBottom = function() return previewBottom + 50 end
  freeBox:GetScript("OnUpdate")(freeBox, 0)
  assert(not freeBox.snapPreview:IsShown(), "no ghost out of reach of any line")
  freeBox.GetBottom = nil
  freeBox.GetLeft = function() return previewStart + deltaToSnap + 3 end
  freeBox:GetScript("OnUpdate")(freeBox, 0)
  freeBox:GetScript("OnDragStop")(freeBox)
  freeBox.GetLeft = nil
  assert(not freeBox:GetScript("OnUpdate") and not freeBox.snapPreview:IsShown(), "ghost and OnUpdate gone at the drop")
  assert(WeakAuras.GetData("Free").xOffset == before + deltaToSnap, "snap to the grid line")
  -- The 64 wide box dropped at 550: its left edge, center and right edge are all more than 8 from a line.
  Drag(private.GetPlacementBox("Free"), deltaToSnap + 50)
  assert(WeakAuras.GetData("Free").xOffset == before + 2 * deltaToSnap + 50, "no snap farther than 8 from a line")
  -- A line on a half unit (spacing 100.5: line at 600.5), as with an odd width or a non-whole screen center:
  -- the axis stuck to it keeps its exact offset instead of being rounded.
  grid.gridSpacing = 100.5
  -- The box may come from the pool with the edges put away: PutOthersAway gives Free its own.
  PutOthersAway()
  local halfBox = private.GetPlacementBox("Free")
  local halfBefore = WeakAuras.GetData("Free").xOffset
  local deltaToHalfLine = 600.5 - halfBox:GetLeft()
  Drag(halfBox, deltaToHalfLine + 3)
  local halfAfter = WeakAuras.GetData("Free").xOffset
  assert(halfAfter % 1 == 0.5 and halfAfter == halfBefore + deltaToHalfLine,
    "axis stuck to a line not rounded, got " .. tostring(halfAfter))
  -- An arrow key on the other axis keeps that half unit.
  local halfSelected = private.GetPlacementBox("Free")
  halfSelected:GetScript("OnMouseDown")(halfSelected, "LeftButton")
  local yBefore = WeakAuras.GetData("Free").yOffset
  OnKeyDown(arrowKeys, "UP")
  assert(WeakAuras.GetData("Free").xOffset == halfAfter and WeakAuras.GetData("Free").yOffset == yBefore + 1,
    "arrow key on y keeps x on the half line, got " .. tostring(WeakAuras.GetData("Free").xOffset))

  -- Placement 4: the snap of /wa. Shift added to the drop of Free with its left edge at left (Pack box at 708 to
  -- 724, grid lines every 100 through 500, screen 1920 wide).
  grid.gridSpacing = 100
  local function DropShift(left)
    WeakAuras.GetData("Free").xOffset = 0
    PutOthersAway()
    local dropped = private.GetPlacementBox("Free")
    local startLeft = dropped:GetLeft()
    dropped:GetScript("OnDragStart")(dropped)
    dropped.GetLeft = function() return left end
    dropped:GetScript("OnDragStop")(dropped)
    dropped.GetLeft = nil
    return WeakAuras.GetData("Free").xOffset - (left - startLeft)
  end
  assert(DropShift(703) == 5, "edge of another box before a nearer grid line")
  assert(DropShift(727) == -3, "right edge of another box")
  _G.IsShiftKeyDown = function() return true end
  assert(DropShift(727) == 0, "Shift: no snap")
  _G.IsShiftKeyDown = function() return false end
  -- Center at 718: 6 from the right edge of Pack, 2 from its center. Without Ctrl, a center never sticks to an edge.
  assert(DropShift(686) == 0, "without Ctrl, no center on the edge of another box")
  _G.IsControlKeyDown = function() return true end
  assert(DropShift(686) == -2, "Ctrl: center on the center of another box")
  _G.IsControlKeyDown = function() return false end
  grid:Hide()
  assert(DropShift(3) == -3, "left edge of the screen, grid hidden")
  assert(DropShift(703) == 5, "other boxes without the grid")

  -- Placement 6: a child moves in its group, which gets its rectangle again, and the drag can be undone. Neither the
  -- child nor its group sticks to the other, which covers it: Pack and Inner keep their places, both centered on 500,
  -- the other boxes are put at 100 to 116. With Ctrl, a center 3 from the other one would stick to it.
  local function DragInGroup(id, deltaX)
    for otherId in pairs(private.loaded) do
      local other = private.GetPlacementBox(otherId)
      if other and (otherId == "Pack" or otherId == "Inner") then
        other.GetLeft, other.GetRight, other.GetCenter, other.GetBottom, other.GetTop = nil, nil, nil, nil, nil
      elseif other then
        other.GetLeft = function() return 100 end
        other.GetRight = function() return 116 end
        other.GetCenter = function() return 108, 108 end
        other.GetBottom = function() return 100 end
        other.GetTop = function() return 116 end
      end
    end
    local dragged = private.GetPlacementBox(id)
    dragged:GetScript("OnDragStart")(dragged)
    local startLeft = dragged:GetLeft()
    dragged.GetLeft = function() return startLeft + deltaX end
    _G.IsControlKeyDown = function() return true end
    dragged:GetScript("OnDragStop")(dragged)
    _G.IsControlKeyDown = function() return false end
    dragged.GetLeft = nil
  end
  local _, _, packRight = WeakAuras.GetRegion("Pack"):GetBoundingRect()
  assert(packRight == 42, "rectangle of Pack before the move, got " .. tostring(packRight))
  -- The time machine refuses edits in the frame where it last cleared its history: a frame later.
  test.Environment.Advance(1)
  DragInGroup("Inner", 3)
  assert(WeakAuras.GetData("Inner").xOffset == 13, "child moved in its group, not stuck to it, got "
    .. tostring(WeakAuras.GetData("Inner").xOffset))
  _, _, packRight = WeakAuras.GetRegion("Pack"):GetBoundingRect()
  assert(packRight == 45, "rectangle of the group after the move of its child, got " .. tostring(packRight))
  local function PackBoxLeft()
    return select(4, private.GetPlacementBox("Pack"):GetPoint())
  end
  assert(PackBoxLeft() == -19, "box of the group after the move of its child, got " .. tostring(PackBoxLeft()))
  -- The undo adds the group again once: its cached rectangle, read by the mover of /wa, is computed again.
  local Add, added = private.Add, {}
  private.Add = function(data, ...)
    added[data.id] = (added[data.id] or 0) + 1
    return Add(data, ...)
  end
  private.TimeMachine:StepBackward()
  private.Add = Add
  assert(added.Pack == 1, "group added again once by the undo, got " .. tostring(added.Pack))
  assert(WeakAuras.GetData("Inner").xOffset == 10, "move of a child undone")
  assert(PackBoxLeft() == -22, "box of the group after the undo, got " .. tostring(PackBoxLeft()))
  -- With Alt, the box of a child moves its group, which it may cover.
  _G.IsAltKeyDown = function() return true end
  local innerBox, packBox = private.GetPlacementBox("Inner"), private.GetPlacementBox("Pack")
  local packStart = WeakAuras.GetData("Pack").xOffset or 0
  innerBox:GetScript("OnMouseDown")(innerBox, "LeftButton")
  -- Alt let go between the click and the drag: the group selected by the click moves.
  _G.IsAltKeyDown = function() return false end
  innerBox:GetScript("OnDragStart")(innerBox)
  local packLeft = packBox:GetLeft()
  packBox.GetLeft = function() return packLeft + 50 end
  innerBox:GetScript("OnDragStop")(innerBox)
  packBox.GetLeft = nil
  _G.IsAltKeyDown = function() return false end
  assert(WeakAuras.GetData("Pack").xOffset == packStart + 50 and WeakAuras.GetData("Inner").xOffset == 10,
    "Alt drag of a child moves its group, got " .. tostring(WeakAuras.GetData("Pack").xOffset))
  private.TimeMachine:StepBackward()
  -- Nested groups: each Alt click on the child goes one level higher, then back to its own group.
  local selectedAlpha = {}
  for _, id in ipairs({ "Leaf", "Sub", "Outer" }) do
    private.GetPlacementBox(id).background.SetColorTexture = function(_, _, _, _, alpha) selectedAlpha[id] = alpha end
  end
  local leafBox = private.GetPlacementBox("Leaf")
  _G.IsAltKeyDown = function() return true end
  for _, expected in ipairs({ "Sub", "Outer", "Sub" }) do
    leafBox:GetScript("OnMouseDown")(leafBox, "LeftButton")
    assert(selectedAlpha[expected] == 0.6 and selectedAlpha.Leaf == 0.35,
      "Alt click on a nested child selects " .. expected)
  end
  _G.IsAltKeyDown = function() return false end
  leafBox:GetScript("OnMouseDown")(leafBox, "LeftButton")
  assert(selectedAlpha.Leaf == 0.6 and selectedAlpha.Sub == 0.35, "click without Alt selects the child")
  for _, id in ipairs({ "Leaf", "Sub", "Outer" }) do
    private.GetPlacementBox(id).background.SetColorTexture = nil
  end
  local packBefore = WeakAuras.GetData("Pack").xOffset or 0
  DragInGroup("Pack", 3)
  assert(WeakAuras.GetData("Pack").xOffset == packBefore + 3, "group not stuck to its child")
  private.TimeMachine:StepBackward()
  grid:Show()
  EditModeManagerFrame.Grid, EditModeManagerFrame.IsSnapEnabled = nil, nil

  EditModeManagerFrame:Hide()
  assert(not box:IsVisible(), "boxes hidden with the Edit Mode hidden by a settings panel")
  EditModeManagerFrame:Show()
  assert(box:IsVisible(), "boxes back with the Edit Mode")

  EventRegistry:TriggerEvent("EditMode.Exit")
  assert(not box:IsShown() and private.GetPlacementBox("Free") == nil, "boxes hidden at the exit")
end

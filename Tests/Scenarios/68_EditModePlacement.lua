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
-- not shown; dragging the box moves the aura by the same distance. Child and mouse-anchored auras get none.
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
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  assert(private.GetPlacementBox("Free") == nil, "no box before the Edit Mode")

  -- The harness has no Edit Mode frame: a plain one stands for it.
  _G.EditModeManagerFrame = CreateFrame("Frame", nil, UIParent)
  local revertButton = CreateFrame("Button", nil, EditModeManagerFrame)
  EditModeManagerFrame.RevertAllChangesButton = revertButton
  EventRegistry:TriggerEvent("EditMode.Enter")
  local box = private.GetPlacementBox("Free")
  assert(box and box:IsVisible(), "box over a hidden screen aura")
  assert(private.GetPlacementBox("Pack"), "box over a group")
  assert(not private.GetPlacementBox("Inner") and not private.GetPlacementBox("Mouse"), "no box for a child or the mouse")
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

  local scaledBox = private.GetPlacementBox("Scaled")
  scaledBox:GetScript("OnDragStart")(scaledBox)
  local scaledLeft = scaledBox:GetLeft()
  scaledBox.GetLeft = function() return scaledLeft + 30 end
  scaledBox:GetScript("OnDragStop")(scaledBox)
  scaledBox.GetLeft = nil
  assert(WeakAuras.GetData("Scaled").xOffset == 15, "drag of a scaled group in its own units")

  local function Drag(dragged, deltaX)
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
  Drag(freeBox, deltaToSnap + 3)
  assert(WeakAuras.GetData("Free").xOffset == before + deltaToSnap, "snap to the grid line")
  -- The 64 wide box dropped at 550: its left edge, center and right edge are all more than 8 from a line.
  Drag(private.GetPlacementBox("Free"), deltaToSnap + 50)
  assert(WeakAuras.GetData("Free").xOffset == before + 2 * deltaToSnap + 50, "no snap farther than 8 from a line")
  EditModeManagerFrame.Grid, EditModeManagerFrame.IsSnapEnabled = nil, nil

  EditModeManagerFrame:Hide()
  assert(not box:IsVisible(), "boxes hidden with the Edit Mode hidden by a settings panel")
  EditModeManagerFrame:Show()
  assert(box:IsVisible(), "boxes back with the Edit Mode")

  EventRegistry:TriggerEvent("EditMode.Exit")
  assert(not box:IsShown() and private.GetPlacementBox("Free") == nil, "boxes hidden at the exit")
end

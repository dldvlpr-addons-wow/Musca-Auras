-- PlacementSnap: the snap of the /wa mover on the edges of the other auras (ticket Placement 4), written before the
-- code moved to a common module: an aura line wins over a grid line, Ctrl aligns the centers, Shift turns the snap off.
-- The harness has no real geometry: every frame is centered on 500, 400; the moved aura gets its edges by hand.
return function(test)
  local function Icon(id)
    return {
      id = id, uid = id, regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    }
  end
  local saved = { displays = { Box = Icon("Box"), Other = Icon("Other") } }
  -- Other spans 392 to 608 on x: its edges are 8 from the grid lines at 400 and 600.
  saved.displays.Other.width = 216
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/OptionsFrames/MoverSizer.lua")
  local optionsPrivate = { Private = private, savedVars = { db = { displays = saved.displays } },
    ResetMoverSizer = function() end,
    displayButtons = { Other = { data = saved.displays.Other, view = { visibility = 1 } } } }
  -- MoverSizer keeps IsShiftKeyDown as a local from its load.
  local shiftDown = false
  _G.IsShiftKeyDown = function() return shiftDown end
  local ok, message = test.Loader.RunFile(path, "WeakAurasOptions", optionsPrivate)
  assert(ok, "MoverSizer.lua: " .. tostring(message))
  WeakAuras.UpdateThumbnail, WeakAuras.FillOptions = function() end, function() end
  _G.WeakAurasOptionsSaved = { magnetAlign = true }
  local Same = test.Assertions.Same

  local frame, mover = optionsPrivate.MoverSizer(UIParent)
  local region = WeakAuras.GetRegion("Box")
  Same(WeakAuras.GetRegion("Other"):GetLeft(), 392, "Other left edge")

  -- Shift of the moved aura on x when its left edge is at left, nil without a line in reach.
  local function SnapDeltaAt(left, width)
    width = width or 64
    region.GetLeft = function() return left end
    region.GetRight = function() return left + width end
    region.GetCenter = function() return left + width / 2, 150 end
    region.GetBottom = function() return 150 - 32 end
    region.GetTop = function() return 150 + 32 end
    frame:SetToRegion(region, WeakAuras.GetData("Box"))
    mover.startMoving()
    mover.onUpdate(mover, 0)
    local delta = mover.verticalDelta
    mover.doneMoving()
    region.GetLeft, region.GetRight, region.GetCenter, region.GetBottom, region.GetTop = nil, nil, nil, nil, nil
    return delta
  end

  -- Left edge 3 right of the right edge of Other.
  Same(SnapDeltaAt(611), -3, "right edge of the other aura")
  Same(SnapDeltaAt(625), nil, "nothing in reach")
  -- Grid line at 600 nearer than the edge of Other at 608: the aura line still wins.
  WeakAurasOptionsSaved.gridAlign, WeakAurasOptionsSaved.gridSpacing = true, 100
  optionsPrivate.UpdatePlacementGrid()
  Same(SnapDeltaAt(603), 5, "aura line before a nearer grid line")
  Same(SnapDeltaAt(703), -3, "grid line alone")
  -- Edit Mode open: the /wa grid is hidden, and its lines no longer snap.
  _G.EditModeManagerFrame = { IsEditModeActive = function() return true end }
  optionsPrivate.UpdatePlacementGrid()
  Same(SnapDeltaAt(703), nil, "no hidden grid line in Edit Mode")
  _G.EditModeManagerFrame = nil
  WeakAurasOptionsSaved.gridAlign = nil
  optionsPrivate.UpdatePlacementGrid()
  -- Ctrl: the centers only. The center of a 40 wide aura at 482 is at 502, 2 from the centers at 500 (screen middle
  -- and Other); its edges are 18 and 22 from that line. Without Ctrl it sticks to the screen middle only.
  Same(SnapDeltaAt(482, 40), -2, "without Ctrl, the center on the middle of the screen, as in the Edit Mode")
  _G.IsControlKeyDown = function() return true end
  Same(SnapDeltaAt(482, 40), -2, "Ctrl: center on the centers")
  Same(SnapDeltaAt(611, 40), nil, "Ctrl: edges ignored")
  _G.IsControlKeyDown = function() return false end
  -- Shift with Magnetically Align on: no snap.
  shiftDown = true
  Same(SnapDeltaAt(611), nil, "Shift: no snap")
  shiftDown = false

  -- The module itself.
  local Snap = private.PlacementSnap
  Same(table.concat(Snap.ScreenLines(1000, 500, 300), ","), "0,1000,200,500,800", "screen edges and grid lines")
  Same(table.concat(Snap.ScreenLines(1000, 500), ","), "0,1000,500", "screen edges and middle without a spacing")
  local vertical, horizontal = {}, {}
  Snap.AddAuraLines(vertical, horizontal, "A", { 10, 20, 50, 60, 30, 40 }, false, true, true, Snap.NewLine)
  Snap.AddAuraLines(vertical, horizontal, "B", { 50.4, 100, 90, 140, 70.2, 120 }, false, true, false, Snap.NewLine)
  Same(#horizontal, 2, "B adds no horizontal line")
  vertical = Snap.MergeLines(vertical)
  Same(#vertical, 3, "right of A and left of B merged")
  Same(vertical[2].position, 50.2, "merged at the mean position")
  Same(#vertical[2].references, 2, "merged line keeps both references")
  local centers = {}
  Snap.AddAuraLines(centers, {}, "A", { 10, 20, 50, 60, 30, 40 }, true, true, true, Snap.NewLine)
  Same(#centers == 1 and centers[1].references[1].side, "CENTERX", "Ctrl: center line only")
  -- Aura at 53 to 75 on x, 20 to 60 on y: its left edge is 2.8 from the merged line, the other lines out of reach.
  local positions = { LEFT = 53, RIGHT = 75, BOTTOM = 20, TOP = 60, CENTERX = 64, CENTERY = 40 }
  local grid = Snap.NewLine(55, true)
  local candidates, isCandidate = Snap.Candidates({ vertical[1], vertical[2], vertical[3], grid }, 10, 53, 75)
  Same(#candidates, 2, "merged line and grid line in reach")
  Same(isCandidate[grid] and grid.delta, 2, "grid line delta")
  Same(Snap.Best(candidates, positions, 10), vertical[2], "aura line before the nearer grid line")
  Same(Snap.Best({}, positions, 10), nil, "no candidate")
  -- A narrow aura from 93 to 117 near the line at 100: its center at 105 is nearer than its left edge.
  local near = Snap.Candidates({ Snap.NewLine(100, true) }, 8, 93, 117, 105)
  Same(near[1] and near[1].delta, -5, "nearest edge of the aura")
  local otherGrid = Snap.NewLine(50, true)
  otherGrid.delta = -3
  Same(Snap.Best({ grid, otherGrid }, positions, 10), grid, "equal scores: the nearest wins")
  -- Placement 13: A at 0 to 20 and B at 50 to 70 in a row (30 apart): lines at 100 after B and at -30 before A. C,
  -- under them, and D, 10 right of A, are left out: not in the row, gap under minGap.
  local spacingVertical, spacingHorizontal = {}, {}
  Snap.AddSpacingLines(spacingVertical, spacingHorizontal, {
    { id = "A", left = 0, bottom = 0, right = 20, top = 20 },
    { id = "B", left = 50, bottom = 5, right = 70, top = 25 },
    { id = "C", left = 200, bottom = -100, right = 220, top = -80 },
  }, 20, Snap.NewLine)
  Same(#spacingVertical, 2, "one pair in a row")
  Same(spacingVertical[1].position .. spacingVertical[1].references[1].side, "100LEFT", "line after B")
  Same(spacingVertical[2].position .. spacingVertical[2].references[1].side, "-30RIGHT", "line before A")
  Same(spacingVertical[1].references[1].id .. spacingVertical[1].references[2].id, "AB", "both auras referenced")
  Same(spacingVertical[1].references[1].pos1 .. "," .. spacingVertical[1].references[1].pos2, "5,20",
    "span of the row")
  Same(#spacingHorizontal, 0, "no pair in a column")
  local tight = {}
  Snap.AddSpacingLines(tight, {}, { { id = "A", left = 0, bottom = 0, right = 20, top = 20 },
    { id = "D", left = 30, bottom = 0, right = 50, top = 20 } }, 20, Snap.NewLine)
  Same(#tight, 0, "gap under minGap left out")
  -- X, Y, Z in a row, 20 apart: X and Z, with Y between them, give no line at their gap of 80.
  local row = {}
  Snap.AddSpacingLines(row, {}, { { id = "X", left = 0, bottom = 0, right = 40, top = 20 },
    { id = "Y", left = 60, bottom = 0, right = 100, top = 20 },
    { id = "Z", left = 120, bottom = 0, right = 160, top = 20 } }, 20, Snap.NewLine)
  local rowPositions = {}
  for index, line in ipairs(row) do
    rowPositions[index] = line.position
  end
  Same(table.concat(rowPositions, ","), "120,-20,180,40", "neighbours only, not X and Z")
  -- Y stuck to X up to a float error still sits between X and Z.
  local touching = {}
  Snap.AddSpacingLines(touching, {}, { { id = "X", left = 0, bottom = 0, right = 40, top = 20 },
    { id = "Y", left = 39.9999, bottom = 0, right = 100, top = 20 },
    { id = "Z", left = 120, bottom = 0, right = 160, top = 20 } }, 20, Snap.NewLine)
  Same(#touching, 2, "touching neighbour between X and Z")
  local column = {}
  Snap.AddSpacingLines({}, column, { { id = "A", left = 0, bottom = 0, right = 20, top = 20 },
    { id = "E", left = 0, bottom = 40, right = 20, top = 60 } }, 20, Snap.NewLine)
  Same(column[1] and column[1].position .. column[1].references[1].side, "80BOTTOM", "line above in a column")
  -- Its two references share one span: the score counts them once, as one aura edge on the same span.
  local edge = Snap.NewLine(80, false)
  edge.references[1] = column[1].references[1]
  local columnPositions = { BOTTOM = 82, TOP = 102, LEFT = 0, RIGHT = 20 }
  Same(Snap.Score(column[1], columnPositions, 10), Snap.Score(edge, columnPositions, 10),
    "spacing line scored as one reference")

  -- Placement 15: align and spread a selection. A at 0..20, B at 50..60 higher, C at 30..40.
  local selection = { { left = 0, bottom = 0, right = 20, top = 20 }, { left = 50, bottom = 10, right = 60, top = 40 },
    { left = 30, bottom = 5, right = 40, top = 15 } }
  local function Shifts(command, axis)
    local result = {}
    for index, shift in ipairs(Snap.AlignShifts(selection, command)) do
      result[index] = shift[axis]
    end
    return table.concat(result, ",")
  end
  Same(Shifts("LEFT", 1), "0,-50,-30", "left edges on the leftmost")
  Same(Shifts("RIGHT", 1), "40,0,20", "right edges on the rightmost")
  Same(Shifts("CENTERX", 1), "20,-25,-5", "centers on the middle of the selection")
  Same(Shifts("TOP", 2), "20,0,25", "top edges on the highest")
  Same(Shifts("BOTTOM", 2) .. "/" .. Shifts("BOTTOM", 1), "0,-10,-5/0,0,0", "bottom edges, x kept")
  -- 40 of sizes in 60: two gaps of 10, A and B kept, C put at 30.
  Same(Shifts("SPREADX", 1), "0,0,0", "already spread")
  selection[3].left, selection[3].right = 22, 32
  Same(Shifts("SPREADX", 1) .. "/" .. Shifts("SPREADX", 2), "0,0,8/0,0,0", "equal gaps between the auras")
  -- In height, from the bottom A, C then B: 60 of sizes in 40, overlapping by equal gaps of -10, C put at 10.
  Same(Shifts("SPREADY", 2), "0,0,5", "spread in height, in their order from the bottom")
  -- A wide bar B around a small icon C: ordered by center, B stays last and the spread keeps the span 0..300.
  selection = { { left = 0, bottom = 0, right = 10, top = 10 }, { left = 20, bottom = 0, right = 300, top = 10 },
    { left = 100, bottom = 0, right = 110, top = 10 } }
  Same(Shifts("SPREADX", 1), "0,0,-90", "spread by center, inside the selection")
  -- A wide A around B, then C: by center B 0..10, A 55..155, C 200..210, the span 0..210 is kept.
  selection = { { left = 0, bottom = 0, right = 100, top = 10 }, { left = 30, bottom = 0, right = 40, top = 10 },
    { left = 200, bottom = 0, right = 210, top = 10 } }
  Same(Shifts("SPREADX", 1), "55,-30,0", "span of the selection kept")
end

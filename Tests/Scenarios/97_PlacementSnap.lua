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
  Same(SnapDeltaAt(603), 5, "aura line before a nearer grid line")
  Same(SnapDeltaAt(703), -3, "grid line alone")
  WeakAurasOptionsSaved.gridAlign = nil
  -- Ctrl: the centers only. The center of a 40 wide aura at 482 is at 502, 2 from the centers at 500 (screen middle
  -- and Other); its edges are 18 and 22 from that line.
  Same(SnapDeltaAt(482, 40), nil, "without Ctrl, the edges are out of reach")
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
  Same(table.concat(Snap.ScreenLines(1000, 500), ","), "0,1000", "screen edges only without a spacing")
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
end

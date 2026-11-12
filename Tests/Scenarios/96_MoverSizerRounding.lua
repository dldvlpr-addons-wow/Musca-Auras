-- MoverSizerRounding: the /wa mover and sizer write whole units at the drop (ticket Placement 2): the moved aura,
-- the resized aura (width, height and the offsets the sizing changed), and the arrow buttons.
-- The harness has no real geometry: the mouse is played by the size of the region and the centers of the mover icons.
return function(test)
  local saved = { displays = {
    Box = {
      id = "Box", uid = "Box", regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 10, yOffset = -5,
    },
  } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/OptionsFrames/MoverSizer.lua")
  local optionsPrivate = { savedVars = { db = { displays = saved.displays } },
    ResetMoverSizer = function() end, displayButtons = {} }
  -- As in game: the file loads before the first /wa sets OptionsPrivate.Private (WeakAurasOptions.lua ToggleOptions).
  local ok, message = test.Loader.RunFile(path, "WeakAurasOptions", optionsPrivate)
  assert(ok, "MoverSizer.lua: " .. tostring(message))
  optionsPrivate.Private = private
  -- Set by the other option files, not loaded here.
  WeakAuras.UpdateThumbnail, WeakAuras.FillOptions = function() end, function() end
  -- Magnetic alignment off and Shift up: no alignment line applies.
  _G.WeakAurasOptionsSaved = { magnetAlign = false }
  local Same = test.Assertions.Same

  local frame, mover = optionsPrivate.MoverSizer(UIParent)
  local data = WeakAuras.GetData("Box")
  local region = WeakAuras.GetRegion("Box")
  frame:SetToRegion(region, data)

  -- Resize by the right edge to 70.4: the CENTER anchored aura moves by half the change, both rounded.
  -- The OnUpdate of the sizing writes the data every frame before the release, as in game.
  -- Height and y offset are fractional (an earlier snap): the right edge does not move that axis.
  assert(frame.startSizing, "the icon is resizable")
  data.yOffset, data.height = -5.3, 64.4
  region:SetHeight(64.4)
  frame.startSizing("RIGHT")
  region:SetWidth(70.4)
  frame:GetScript("OnUpdate")(frame)
  frame.doneSizing()
  data = WeakAuras.GetData("Box")
  Same(data.width, 70, "width rounded")
  Same(data.xOffset, 13, "offset changed by the sizing rounded")
  Same(data.height, 64.4, "height of the axis not dragged kept exact")
  Same(data.yOffset, -5.3, "offset of the axis not dragged kept exact")

  -- LEFT self point, right edge pulled: the offset does not change and keeps its fraction.
  data.selfPoint, data.xOffset, data.height, data.yOffset = "LEFT", 10.3, 64, -5
  frame:SetToRegion(region, data)
  frame.startSizing("RIGHT")
  region:SetWidth(80.6)
  frame:GetScript("OnUpdate")(frame)
  frame.doneSizing()
  data = WeakAuras.GetData("Box")
  Same(data.width, 81, "width rounded")
  Same(data.xOffset, 10.3, "offset untouched by the sizing kept")
  data.selfPoint, data.xOffset = "CENTER", 13

  -- Move: the self point ends 30.6 right and 12.4 down of the anchor point.
  frame:SetToRegion(region, data)
  mover.startMoving()
  mover.selfPointIcon.GetCenter = function() return 530.6, 387.6 end
  mover.doneMoving()
  mover.selfPointIcon.GetCenter = nil
  data = WeakAuras.GetData("Box")
  Same(data.xOffset, 31, "x rounded at the drop")
  Same(data.yOffset, -12, "y rounded at the drop")

  -- Arrows: from a fractional offset, round then step one unit. Not 17.5: the client rounding of halves is unchecked.
  data.xOffset = 17.6
  frame:SetToRegion(region, data)
  local buttons = {}
  for _, holder in ipairs({ frame:GetChildren() }) do
    for _, child in ipairs({ holder:GetChildren() }) do
      if child:GetScript("OnClick") then
        buttons[#buttons + 1] = child
      end
    end
  end
  Same(#buttons, 4, "four arrow buttons")
  -- Order of ConstructMover: top, bottom, left, right.
  buttons[4]:GetScript("OnClick")(buttons[4])
  Same(WeakAuras.GetData("Box").xOffset, 19, "right arrow: rounded then one unit")
  buttons[1]:GetScript("OnClick")(buttons[1])
  Same(WeakAuras.GetData("Box").yOffset, -11, "top arrow: one unit up")

  -- Placement 5: arrow keys move like the buttons, ten units with Shift; the axis not moved keeps its fraction.
  -- The other keys go on to the game. The keyboard is let go at the start of combat, taken back at its end.
  data = WeakAuras.GetData("Box")
  data.yOffset = -11.4
  frame:SetToRegion(region, data)
  Same(frame:IsKeyboardEnabled(), true, "keyboard taken by the mover")
  local OnKeyDown = frame:GetScript("OnKeyDown")
  -- Several auras picked (the options frame holds a table): the mover stays on the first one, the keys go to the game.
  UIParent.pickedDisplay = {}
  OnKeyDown(frame, "LEFT")
  Same(WeakAuras.GetData("Box").xOffset, 19, "no key move with several auras picked")
  Same(frame:GetPropagateKeyboardInput(), true, "several auras picked: key given to the game")
  UIParent.pickedDisplay = "Box"
  -- While the mover is dragged, the keys do not move the aura.
  mover.isMoving = true
  OnKeyDown(frame, "LEFT")
  mover.isMoving = nil
  Same(WeakAuras.GetData("Box").xOffset, 19, "no key move while dragging")
  OnKeyDown(frame, "LEFT")
  Same(WeakAuras.GetData("Box").xOffset, 18, "left key: one unit")
  Same(WeakAuras.GetData("Box").yOffset, -11.4, "left key: y kept")
  Same(frame:GetPropagateKeyboardInput(), false, "arrow key kept from the game")
  frame:GetScript("OnKeyUp")(frame, "LEFT")
  Same(frame:GetPropagateKeyboardInput(), true, "keys given back to the game at the key up")
  _G.IsShiftKeyDown = function() return true end
  OnKeyDown(frame, "UP")
  _G.IsShiftKeyDown = function() return false end
  Same(WeakAuras.GetData("Box").yOffset, -1, "Shift up: ten units")
  OnKeyDown(frame, "W")
  Same(frame:GetPropagateKeyboardInput(), true, "other key given to the game")
  test.Frames.Fire("PLAYER_REGEN_DISABLED")
  Same(frame:IsKeyboardEnabled(), false, "keyboard let go in combat")
  test.Frames.Fire("PLAYER_REGEN_ENABLED")
  Same(frame:IsKeyboardEnabled(), true, "keyboard back after combat")
  -- Lockdown already on at PLAYER_REGEN_DISABLED: no blocked call, keys left to the game.
  test.WowApi.inCombat = true
  test.Frames.Fire("PLAYER_REGEN_DISABLED")
  OnKeyDown(frame, "LEFT")
  Same(WeakAuras.GetData("Box").xOffset, 18, "no key move in combat")
  test.WowApi.inCombat = false
  test.Frames.Fire("PLAYER_REGEN_ENABLED")
  -- Lock Positions: the keys go to the game.
  WeakAurasOptionsSaved.lockPositions = true
  OnKeyDown(frame, "LEFT")
  Same(WeakAuras.GetData("Box").xOffset, 18, "no key move with Lock Positions")
  Same(frame:GetPropagateKeyboardInput(), true, "Lock Positions: key given to the game")
  -- The arrow buttons too.
  local leftButton
  for _, child in ipairs({ frame:GetChildren() }) do
    for _, button in ipairs({ child:GetChildren() }) do
      if button:GetPoint() == "LEFT" and button:GetScript("OnClick") then
        leftButton = button
      end
    end
  end
  assert(leftButton, "left arrow button")
  leftButton:GetScript("OnClick")(leftButton)
  Same(WeakAuras.GetData("Box").xOffset, 18, "no arrow button move with Lock Positions")
  WeakAurasOptionsSaved.lockPositions = nil
  leftButton:GetScript("OnClick")(leftButton)
  Same(WeakAuras.GetData("Box").xOffset, 17, "arrow button moves without Lock Positions")
  OnKeyDown(frame, "RIGHT")
  -- A child of a dynamic group: the group places it, the keys go to the game.
  local GetData = WeakAuras.GetData
  WeakAuras.GetData = function(id)
    return id == "Dyn" and { id = "Dyn", regionType = "dynamicgroup" } or GetData(id)
  end
  mover.moving.data.parent = "Dyn"
  OnKeyDown(frame, "LEFT")
  mover.moving.data.parent = nil
  WeakAuras.GetData = GetData
  Same(WeakAuras.GetData("Box").xOffset, 18, "no key move for a child of a dynamic group")
  Same(frame:GetPropagateKeyboardInput(), true, "dynamic group child: key given to the game")

  -- Placement 1: with Magnetically Align, the screen edges are snap targets; with the Grid option, the lines of
  -- the /wa grid too (pitch set to 100 here, centered on UIParent, 500 in the harness).
  -- The aura is played 3 right of the line at 600 and 4 right of the left edge of the screen.
  _G.WeakAurasOptionsSaved = { magnetAlign = true }
  local function SnapDeltaAt(left, width)
    width = width or 64
    region.GetLeft = function() return left end
    region.GetRight = function() return left + width end
    region.GetCenter = function() return left + width / 2, 400 end
    frame:SetToRegion(region, WeakAuras.GetData("Box"))
    mover.startMoving()
    mover.onUpdate(mover, 0)
    local delta = mover.verticalDelta
    mover.doneMoving()
    region.GetLeft, region.GetRight, region.GetCenter = nil, nil, nil
    return delta
  end
  Same(SnapDeltaAt(603), nil, "no grid line without the Grid option")
  Same(SnapDeltaAt(4), -4, "left edge of the screen")
  WeakAurasOptionsSaved.gridAlign, WeakAurasOptionsSaved.gridSpacing = true, 100
  optionsPrivate.UpdatePlacementGrid()
  Same(SnapDeltaAt(603), -3, "grid line at 600")
  -- Left edge 3 from the line at 700, right edge 7 from the line at 1000, center 48 from 800: the nearest line wins.
  Same(SnapDeltaAt(703, 290), -3, "nearest of two grid lines")
  -- A region without a rect, as just re-anchored: no move from the bottom left of the screen. A rect without a
  -- center on the first update: no error, the move goes on.
  local startMoving = rawget(region, "StartMoving")
  local moves = 0
  rawset(region, "StartMoving", function() moves = moves + 1 end)
  region.GetLeft = function() return nil end
  frame:SetToRegion(region, WeakAuras.GetData("Box"))
  mover.startMoving()
  Same(moves, 0, "no move without a rect")
  Same(mover.isMoving or false, false, "mover not moving without a rect")
  region.GetLeft = function() return 100 end
  region.GetCenter = function() return nil end
  mover.startMoving()
  Same(moves, 1, "move with a rect")
  Same(mover.isMoving, true, "start goes on without a center")
  mover.doneMoving()
  -- Self and anchor points at the same center in the harness: 0, not the -3 snapped at 703 above.
  Same(WeakAuras.GetData("Box").xOffset, 0, "no snap of the previous move")
  region.GetLeft, region.GetCenter = nil, nil
  rawset(region, "StartMoving", startMoving)
  -- The same for a sizing: no size from the bottom left of the screen.
  local startSizing = rawget(region, "StartSizing")
  local sizings = 0
  rawset(region, "StartSizing", function() sizings = sizings + 1 end)
  region.GetLeft = function() return nil end
  frame:SetToRegion(region, WeakAuras.GetData("Box"))
  frame.startSizing("RIGHT")
  Same(sizings, 0, "no sizing without a rect")
  Same(mover.isMoving, false, "mover not sizing without a rect")
  region.GetLeft = nil
  rawset(region, "StartSizing", startSizing)
  -- Without Ctrl, the center sticks to a grid line too: center at 802, edges 32 from a line.
  Same(SnapDeltaAt(770, 64), -2, "center on a grid line without Ctrl")
  -- Pitch of the slider, 30: line at 530 from the center at 500. The Edit Mode grid is ignored.
  WeakAurasOptionsSaved.gridSpacing = 30
  _G.EditModeManagerFrame = { Grid = { gridSpacing = 60, GetEffectiveScale = function() return 1 end } }
  Same(SnapDeltaAt(532), -2, "grid line at 530")
  _G.EditModeManagerFrame = nil
  WeakAurasOptionsSaved.gridSpacing = nil
  Same(optionsPrivate.GridSpacing(), 64, "default pitch")

  -- The grid is drawn while the options frame (UIParent here) is shown with the Grid option, the middle lines
  -- stronger, and hidden without the option.
  local grid = optionsPrivate.PlacementGrid
  -- Lines drawn by the snap checks above were made before the CreateLine hook below: start from an empty grid.
  grid:Hide()
  for index = #grid.lines, 1, -1 do
    grid.lines[index] = nil
  end
  local CreateLine = grid.CreateLine
  grid.CreateLine = function(self, ...)
    local line = CreateLine(self, ...)
    line.SetThickness = function(_, thickness) line.thickness = thickness end
    return line
  end
  local function ShownLines()
    local shown, middle = 0, 0
    for _, line in ipairs(grid.lines) do
      if line:IsShown() then
        shown = shown + 1
        -- Thickness in whole pixels: 2 pixels for a middle line, under it for the others.
        if line.thickness == PixelUtil.GetNearestPixelSize(2, line:GetEffectiveScale(), 2) then
          middle = middle + 1
        end
      end
    end
    return shown, middle
  end
  WeakAurasOptionsSaved.gridAlign, WeakAurasOptionsSaved.gridSpacing = true, 100
  optionsPrivate.UpdatePlacementGrid()
  Same(grid:IsShown(), true, "grid shown with the option")
  -- Per axis: the two edges, the middle, and the lines on each side of it (the harness middle is not centered).
  local width, height = UIParent:GetWidth(), UIParent:GetHeight()
  local midX, midY = UIParent:GetCenter()
  local function Count(length, middle, spacing)
    return 3 + math.floor(middle / spacing) + math.floor((length - middle) / spacing)
  end
  local expected = Count(width, midX, 100) + Count(height, midY, 100)
  Same(select(1, ShownLines()), expected, "edges and lines every 100 from the middle")
  Same(select(2, ShownLines()), 2, "two middle lines")
  WeakAurasOptionsSaved.gridSpacing = 50
  optionsPrivate.UpdatePlacementGrid()
  expected = Count(width, midX, 50) + Count(height, midY, 50)
  Same(select(1, ShownLines()), expected, "drawn again at the new pitch")
  WeakAurasOptionsSaved.gridSpacing = 100
  optionsPrivate.UpdatePlacementGrid()
  Same(select(1, ShownLines()), Count(width, midX, 100) + Count(height, midY, 100), "lines of the finer pitch hidden")
  UIParent:Hide()
  Same(grid:IsShown(), false, "hidden with the options frame")
  UIParent:Show()
  Same(grid:IsShown(), true, "shown again with the options frame")
  -- Edit Mode opened over /wa: its own grid only.
  local editModeActive = true
  _G.EditModeManagerFrame = CreateFrame("Frame")
  EditModeManagerFrame.IsEditModeActive = function() return editModeActive end
  EventRegistry:TriggerEvent("EditMode.Enter")
  Same(grid:IsShown(), false, "hidden in Edit Mode")
  editModeActive = false
  EventRegistry:TriggerEvent("EditMode.Exit")
  Same(grid:IsShown(), true, "shown again after Edit Mode")
  _G.EditModeManagerFrame = nil
  -- Saved pitch out of the slider range: bounded, never zero.
  WeakAurasOptionsSaved.gridSpacing = 0
  Same(optionsPrivate.GridSpacing(), 8, "pitch 0 bounded to 8")
  WeakAurasOptionsSaved.gridSpacing = 500.4
  Same(optionsPrivate.GridSpacing(), 128, "pitch bounded to 128")
  WeakAurasOptionsSaved.gridSpacing = "x"
  Same(optionsPrivate.GridSpacing(), 64, "invalid pitch: default")
  WeakAurasOptionsSaved.gridAlign = false
  optionsPrivate.UpdatePlacementGrid()
  Same(grid:IsShown(), false, "hidden without the option")
end

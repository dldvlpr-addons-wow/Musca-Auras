-- Contract of the flow layout of modern groups, observed through the anchors the code sets (SetPoint, SetParent,
-- SetFrameStrata, SetFrameLevel) and through returned values: centered growth chained in screen mode, flow preview
-- (one frame per preview unit, bounds), grid preview, grid on a frame or a nameplate, screen grid, grid spaces for
-- the four vertical types, grid buttons kept in the instance across a disable / enable, Show On rules of the shadows, shadows of a
-- centered growth with Limit on clones and with Show On Missing.
-- Complements scenarios 27, 28 and 44.
-- Not covered: a failing Rebind that must not stop UpdateInstance (spec only: the former code had no such path,
-- see the end of the file). The replay of a locked container is covered for the grid only (case 11).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function ExpectPoint(frame, point, relativeTo, relativePoint, x, y, message)
    assert(frame:GetNumPoints() == 1, ("%s: %d points"):format(message, frame:GetNumPoints()))
    local actualPoint, actualRelativeTo, actualRelativePoint, actualX, actualY = frame:GetPoint(1)
    Same(actualPoint, point, message .. " point")
    assert(actualRelativeTo == relativeTo, message .. " relative frame")
    Same(actualRelativePoint, relativePoint, message .. " relative point")
    Same(actualX, x, message .. " x")
    Same(actualY, y, message .. " y")
  end

  -- Shared stubs, all restored at the end.
  local groups = {}
  local originals = {
    GetData = WeakAuras.GetData, GetUnitFrame = WeakAuras.GetUnitFrame, CreateFrame = CreateFrame,
    GetNamePlateForUnit = C_NamePlate and C_NamePlate.GetNamePlateForUnit, policy = CustomAuraContainerAuraProcessingPolicy,
    SetupAuraButton = Display.SetupAuraButton, UnitTokens = Display.UnitTokens, StyleNative = Display.StyleNative,
  }
  WeakAuras.GetData = function(id) return groups[id] or originals.GetData(id) end
  local sortMethodsBefore, sortDirectionBefore = AuraContainerSortMethod, AuraContainerSortDirection
  AuraContainerSortMethod, AuraContainerSortDirection = {}, { Normal = 0, Reverse = 1 }
  local sortValue = 0
  for name in pairs(Display.sortMethods) do
    AuraContainerSortMethod[name] = sortValue
    sortValue = sortValue + 1
  end
  CustomAuraContainerAuraProcessingPolicy = { None = 0 }
  local unitFrames, plates = {}, {}
  WeakAuras.GetUnitFrame = function(unit) return unitFrames[unit] end
  C_NamePlate = C_NamePlate or {}
  C_NamePlate.GetNamePlateForUnit = function(unit) return plates[unit] end
  -- A trigger may carry the units a test wants: the harness group is empty.
  Display.UnitTokens = function(trigger) return trigger.testUnits or originals.UnitTokens(trigger) end
  Display.StyleNative = function() end
  -- The real button needs the whole native style: only the kind's bookkeeping is kept.
  Display.SetupAuraButton = function(kind, _, _, button)
    kind.buttons[#kind.buttons + 1] = { button = button }
  end

  -- The harness has no AuraContainer: a frame with recording stubs stands in for it.
  local containerLog, failSetParent = {}, false
  local function WithContainerMethods(frame)
    frame.log, frame.calls = {}, {}
    local function Record(name)
      return function(self, ...)
        self.log[#self.log + 1] = { name = name, ... }
        containerLog[#containerLog + 1] = { frame = self, name = name, ... }
      end
    end
    for _, name in ipairs({ "SetAuraGroupFilterString", "SetAuraGroupCandidateFilters", "SetAuraGroupLayout",
      "SetAuraGroupMaxFrameCount", "SetAuraGroupSortMethod", "SetAuraGroupEnabled", "SetFlowLayoutAxis",
      "SetFlowLayoutAnchorPoint", "SetFlowLayoutGrowthDirection", "SetFlowLayoutMaximumLineSize",
      "SetAuraProcessingPolicy", "UpdateAllAuras", "SetUnit" }) do
      frame[name] = Record(name)
    end
    frame.SetEnabled = function(self, value)
      self.enabledValue = value
      self.log[#self.log + 1] = { name = "SetEnabled", value }
    end
    frame.AddAuraGroup = function(self, groupName, filter, settings)
      self.log[#self.log + 1] = { name = "AddAuraGroup", groupName, filter, settings }
      containerLog[#containerLog + 1] = { frame = self, name = "AddAuraGroup", groupName, filter, settings }
      if groupName:find("^MuscaGrid") and settings.initializeFrame then
        for _ = 1, 2 do settings.initializeFrame(originals.CreateFrame("Frame")) end
      end
    end
    for _, name in ipairs({ "SetPoint", "SetParent", "SetFrameStrata", "SetFrameLevel" }) do
      local base = frame[name]
      frame[name] = function(self, ...)
        self.calls[#self.calls + 1] = { name = name, ... }
        if name == "SetParent" and failSetParent then error("Anchoring disallowed") end
        return base(self, ...)
      end
    end
    return frame
  end
  CreateFrame = function(frameType, name, parent, template)
    local frame = originals.CreateFrame(frameType == "AuraContainer" and "Frame" or frameType, name, parent, template)
    if frameType == "AuraContainer" then WithContainerMethods(frame) end
    return frame
  end
  local function CountAdded(groupPrefix)
    local total = 0
    for _, entry in ipairs(containerLog) do
      if entry.name == "AddAuraGroup" and entry[1]:find("^" .. groupPrefix) then total = total + 1 end
    end
    return total
  end
  local function AddedSettings(key)
    for index = #containerLog, 1, -1 do
      local entry = containerLog[index]
      if entry.name == "AddAuraGroup" and entry[1] == key then return entry[3] end
    end
  end

  local function Group(id, extra)
    local group = { id = id, uid = id, regionType = "group", blizzardFlow = true, controlledChildren = {} }
    for key, value in pairs(extra or {}) do group[key] = value end
    groups[id] = group
    return group
  end
  local function Child(extra)
    local data = { id = "Child", uid = "Child", parent = "Flow", regionType = "icon", width = 30, height = 20,
      triggers = { activeTriggerMode = 1, { trigger = { type = "secretAura", unit = "player", secretShowOn = "showOnActive" } } } }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function TriggerOf(data) return data.triggers[1].trigger end
  local function Rechain(group)
    Display.RechainFlow(group)
    test.Environment.Advance(0.1)
  end

  ------------------------------------------------------------------------------------------------
  -- 1. Screen mode, centered horizontal growth, three auras: shadow chain, first visible start, centering.
  ------------------------------------------------------------------------------------------------
  do
    local ids = { "ScreenA", "ScreenB", "ScreenC" }
    local group = Group("Screen", { blizzardFlowGrowth = "CENTER_HORIZONTAL", blizzardFlowSpacing = 4,
      controlledChildren = ids })
    local regions, flows = {}, {}
    for index, childId in ipairs(ids) do
      local region = CreateFrame("Frame")
      local instances = {}
      for slot = 1, 2 do instances[slot] = { container = CreateFrame("Frame") } end
      region.blizzardAuraDisplay = { instances = instances, active = true }
      local data = Child({ id = childId, uid = childId, parent = "Screen" })
      groups[childId] = data
      Display.EnsureFlowStart(region, data)
      Display.EnsureFlowShadows(region, data)
      Display.SetFlowEnd(region, data)
      private.regions[childId] = { region = region }
      regions[index], flows[index] = region, region.blizzardAuraDisplay.flow
      for _, shadow in ipairs(flows[index].shadowList) do
        shadow:SetWidth(18)
      end
    end
    Rechain(group)

    ExpectPoint(flows[1].shadowStart, "TOPRIGHT", regions[1], "TOP", 0, 0, "first shadow start on the center point")
    for index = 1, 3 do
      local list = flows[index].shadowList
      Same(#list, 2, "shadows of flow " .. index)
      ExpectPoint(list[1], "TOPRIGHT", flows[index].shadowStart, "TOPRIGHT", 0, 0, "first list shadow " .. index)
      ExpectPoint(list[2], "TOPRIGHT", list[1], "TOPLEFT", 1, 0, "second list shadow " .. index)
    end
    ExpectPoint(flows[2].shadowStart, "TOPRIGHT", flows[1].shadowList[2], "TOPLEFT", 1, 0, "second shadow start chained")
    ExpectPoint(flows[3].shadowStart, "TOPRIGHT", flows[2].shadowList[2], "TOPLEFT", 1, 0, "third shadow start chained")
    -- First visible start: on the end of the last shadow, shifted by sign * spacing / 2 (4 / 2) on top of the pixel.
    local lastShadow = flows[3].shadowList[2]
    ExpectPoint(flows[1].start, "TOPLEFT", lastShadow, "TOPLEFT", 3, 0, "first visible start")
    ExpectPoint(flows[2].start, "TOPLEFT", regions[1].blizzardAuraDisplay.instances[2].container, "TOPRIGHT", -1, 0,
      "second visible start chained on the first flow")
    ExpectPoint(flows[3].start, "TOPLEFT", regions[2].blizzardAuraDisplay.instances[2].container, "TOPRIGHT", -1, 0,
      "third visible start chained on the second flow")

    -- Centered: with the shadows as wide as the layout says, the visible content spans -V/2 .. V/2.
    local function Fraction(point) return point:find("LEFT") and 0 or point:find("RIGHT") and 1 or 0.5 end
    local function EdgeX(frame, point)
      if frame:GetNumPoints() == 0 then return Fraction(point) * frame:GetWidth() end
      local own, relativeTo, relativePoint, x = frame:GetPoint(1)
      return EdgeX(relativeTo, relativePoint) + x - Fraction(own) * frame:GetWidth() + Fraction(point) * frame:GetWidth()
    end
    local settings
    for _, entry in ipairs(containerLog) do
      if entry.name == "AddAuraGroup" and entry[1] == "MuscaShadow" then settings = entry[3] break end
    end
    Same(settings.layout.elementWidth, 18, "shadow width")
    local slots = 6
    local visible = slots * (30 + 4) - 4
    Same(EdgeX(flows[1].start, "TOPLEFT"), -visible / 2, "left edge of the visible content")
  end

  ------------------------------------------------------------------------------------------------
  -- 2 and 3. Flow preview on unit frames: one frame per preview unit, then the bounds of the group preview.
  ------------------------------------------------------------------------------------------------
  local function PreviewButtons(region, count, key)
    region.secretAuraSamplesActive = true
    region.secretAuraSamples = region.secretAuraSamples or {}
    local buttons = {}
    for index = 1, count do
      local button = CreateFrame("Frame")
      button:SetSize(30, 20)
      button:Show()
      region.secretAuraSamples[#region.secretAuraSamples + 1] = { button = button, previewUnit = key }
      buttons[index] = button
    end
    return buttons
  end
  local function PreviewGroup(id, extra, plan)
    local group = Group(id, { blizzardFlowFrames = "UNITFRAME", blizzardFlowGrowth = "RIGHT", blizzardFlowSpacing = 2,
      selfPoint = "TOPLEFT", anchorPoint = "TOPLEFT", xOffset = 0, yOffset = 0 })
    for key, value in pairs(extra or {}) do group[key] = value end
    local groupRegion = CreateFrame("Frame")
    private.regions[id] = { region = groupRegion }
    local childId = id .. "Child"
    group.controlledChildren = { childId }
    groups[childId] = Child({ id = childId, uid = childId, parent = id })
    local region = CreateFrame("Frame")
    private.regions[childId] = { region = region }
    local buttons = {}
    for _, entry in ipairs(plan) do buttons[entry[1]] = PreviewButtons(region, entry[2], entry[1]) end
    Display.ArrangeFlowPreview(group)
    return group, groupRegion, buttons
  end

  do
    local plan = {}
    for index = 1, 5 do
      local unit = "party" .. index
      unitFrames[unit] = CreateFrame("Frame")
      plan[index] = { unit, index == 1 and 2 or 1 }
    end
    local _, _, buttons = PreviewGroup("PreviewUnits", nil, plan)
    for index = 1, 5 do
      local unit = "party" .. index
      local button = buttons[unit][1]
      Same(button:GetNumPoints(), 1, unit .. " preview button points")
      assert(select(2, button:GetPoint(1)) == unitFrames[unit], unit .. " preview frame")
    end
    -- The second button of a unit follows the first one, not another unit frame.
    assert(select(2, buttons.party1[2]:GetPoint(1)) == buttons.party1[1], "second preview button of a unit chained")
  end

  do
    local function Bounds(groupRegion) return groupRegion:GetBoundingRect() end
    local function Check(groupRegion, left, bottom, right, top, message)
      local actual = { Bounds(groupRegion) }
      Same(actual[1], left, message .. " left")
      Same(actual[2], bottom, message .. " bottom")
      Same(actual[3], right, message .. " right")
      Same(actual[4], top, message .. " top")
    end
    unitFrames.player = CreateFrame("Frame")
    local _, groupRegion = PreviewGroup("BoundsTopLeft", nil, { { "player", 1 } })
    Check(groupRegion, 0, -20, 30, 0, "one button at TOPLEFT 0,0")

    _, groupRegion = PreviewGroup("BoundsDown", { blizzardFlowGrowth = "DOWN", selfPoint = "CENTER", anchorPoint = "CENTER" },
      { { "player", 3 } })
    Check(groupRegion, -15, -64, 15, 0, "three buttons DOWN at CENTER")

    -- Only the first key counts: three buttons of party2 first, then one of party1.
    _, groupRegion = PreviewGroup("BoundsFirstKey", nil, { { "party2", 3 }, { "party1", 1 } })
    Check(groupRegion, 0, -20, 94, 0, "first key with three buttons")
    _, groupRegion = PreviewGroup("BoundsOtherKey", nil, { { "party1", 1 }, { "party2", 3 } })
    Check(groupRegion, 0, -20, 30, 0, "first key with one button")
  end

  ------------------------------------------------------------------------------------------------
  -- 4 and 8 (preview side). Grid preview without frame: first button on its region, the others chained; spaces.
  ------------------------------------------------------------------------------------------------
  local function MemberOfGrid(group, childId, extra)
    local data = Child({ id = childId, uid = childId, parent = group.id })
    for key, value in pairs(extra or {}) do data[key] = value end
    groups[childId] = data
    group.controlledChildren[#group.controlledChildren + 1] = childId
    return data
  end
  do
    local group = Group("GridPreview", { blizzardFlowGrid = true, blizzardFlowPerRow = 3 })
    MemberOfGrid(group, "GridPreviewChild")
    local region = CreateFrame("Frame")
    private.regions.GridPreviewChild = { region = region }
    local buttons = PreviewButtons(region, 4)
    Display.ArrangeFlowPreview(group)
    ExpectPoint(buttons[1], "TOPLEFT", region, "TOPLEFT", 0, 0, "first grid preview button on its region")
    ExpectPoint(buttons[2], "TOPLEFT", buttons[1], "TOPLEFT", 32, 0, "second grid preview button")
    ExpectPoint(buttons[3], "TOPLEFT", buttons[2], "TOPLEFT", 32, 0, "third grid preview button")
    ExpectPoint(buttons[4], "TOPLEFT", buttons[1], "TOPLEFT", 0, -22, "new line of the grid preview")
  end

  -- 8. Vertical grid types with RowSpace 10 and ColumnSpace 2: 10 between two auras of a column, 2 between columns.
  local verticalTypes = {
    DR = { "TOPLEFT", 1, -1 }, DL = { "TOPRIGHT", -1, -1 }, UR = { "BOTTOMLEFT", 1, 1 }, UL = { "BOTTOMRIGHT", -1, 1 },
  }
  for gridType, row in pairs(verticalTypes) do
    local group = Group("Spaces" .. gridType, { blizzardFlowGrid = true, blizzardFlowGridType = gridType,
      blizzardFlowPerRow = 2, blizzardFlowRowSpace = 10, blizzardFlowColumnSpace = 2 })
    MemberOfGrid(group, group.id .. "Child")
    local region = CreateFrame("Frame")
    private.regions[group.id .. "Child"] = { region = region }
    local buttons = PreviewButtons(region, 3)
    Display.ArrangeFlowPreview(group)
    ExpectPoint(buttons[1], row[1], region, row[1], 0, 0, gridType .. " first preview button")
    ExpectPoint(buttons[2], row[1], buttons[1], row[1], 0, row[3] * (20 + 10), gridType .. " vertical gap")
    ExpectPoint(buttons[3], row[1], buttons[1], row[1], row[2] * (30 + 2), 0, gridType .. " horizontal gap")
  end

  ------------------------------------------------------------------------------------------------
  -- Live grid: one shared container per unit, built from the members.
  ------------------------------------------------------------------------------------------------
  local function GridFixture(id, extra, units)
    local group = Group(id, { blizzardFlowGrid = true })
    for key, value in pairs(extra or {}) do group[key] = value end
    local childId = id .. "Member"
    local data = MemberOfGrid(group, childId)
    TriggerOf(data).testUnits = units
    local region = CreateFrame("Frame")
    region:Show()
    local instances = {}
    for position = 1, #units do instances[position] = { container = CreateFrame("Frame"), buttons = {} } end
    local native = { gridMember = true, generation = 1, active = true, data = data, instances = instances }
    region.blizzardAuraDisplay = native
    private.regions[childId] = { region = region }
    return group, region, native
  end
  local function GridContainer(key)
    for index = #containerLog, 1, -1 do
      local entry = containerLog[index]
      if entry.name == "AddAuraGroup" and entry[1] == key then return entry.frame end
    end
  end

  -- 8. Live side: the layout carries the same spaces.
  for gridType, _ in pairs(verticalTypes) do
    local group = GridFixture("Live" .. gridType, { blizzardFlowGridType = gridType, blizzardFlowRowSpace = 10,
      blizzardFlowColumnSpace = 2 }, { "player" })
    Rechain(group)
    local settings = AddedSettings("MuscaGrid" .. group.id .. "Member")
    assert(settings, gridType .. ": grid group not added")
    Same(settings.layout.elementSpacing, 10, gridType .. " vertical gap")
    Same(settings.layout.lineSpacing, 2, gridType .. " horizontal gap")
  end
  do
    local group = GridFixture("LiveRD", { blizzardFlowGridType = "RD", blizzardFlowRowSpace = 10,
      blizzardFlowColumnSpace = 2 }, { "player" })
    Rechain(group)
    local settings = AddedSettings("MuscaGrid" .. group.id .. "Member")
    Same(settings.layout.elementSpacing, 2, "RD horizontal gap")
    Same(settings.layout.lineSpacing, 10, "RD vertical gap")
  end

  -- 5. Grid on a unit frame: anchored by the corner of the grid, not by selfPoint.
  do
    local frame = CreateFrame("Frame")
    unitFrames.player = frame
    local group = GridFixture("FrameGrid", { blizzardFlowFrames = "UNITFRAME", blizzardFlowGridType = "RD",
      selfPoint = "BOTTOMRIGHT", anchorPoint = "BOTTOM", xOffset = 3, yOffset = -4 }, { "player" })
    Rechain(group)
    local container = GridContainer("MuscaGridFrameGridMember")
    assert(container, "grid container not built")
    ExpectPoint(container, "TOPLEFT", frame, "BOTTOM", 3, -4, "grid container on a unit frame")
    assert(container:GetParent() == frame, "grid container not reparented on the unit frame")
  end

  -- 6. Grid on a nameplate: strata and level copied, also when SetParent fails.
  do
    local plate = CreateFrame("Frame")
    plate:SetFrameStrata("HIGH")
    plate:SetFrameLevel(7)
    plates.player = plate
    local group = GridFixture("PlateGrid", { blizzardFlowFrames = "NAMEPLATE", blizzardFlowGridType = "RD",
      selfPoint = "BOTTOMRIGHT", anchorPoint = "TOP", xOffset = 1, yOffset = 2 }, { "player" })
    Rechain(group)
    local container = GridContainer("MuscaGridPlateGridMember")
    assert(container, "nameplate grid container not built")
    ExpectPoint(container, "TOPLEFT", plate, "TOP", 1, 2, "grid container on a nameplate")
    Same(container:GetFrameStrata(), "HIGH", "nameplate grid strata")
    Same(container:GetFrameLevel(), 8, "nameplate grid level")

    failSetParent = true
    local refusedGroup = GridFixture("PlateRefused", { blizzardFlowFrames = "NAMEPLATE", blizzardFlowGridType = "RD",
      selfPoint = "BOTTOMRIGHT", anchorPoint = "TOP", xOffset = 1, yOffset = 2 }, { "player" })
    Rechain(refusedGroup)
    local refused = GridContainer("MuscaGridPlateRefusedMember")
    assert(refused, "refused nameplate grid container not built")
    ExpectPoint(refused, "TOPLEFT", plate, "TOP", 1, 2, "nameplate grid anchored although SetParent fails")
    Same(refused:GetFrameStrata(), "HIGH", "refused nameplate grid strata")
    Same(refused:GetFrameLevel(), 8, "refused nameplate grid level")

    local frame = CreateFrame("Frame")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(3)
    unitFrames.player = frame
    local framedGroup = GridFixture("FrameRefused", { blizzardFlowFrames = "UNITFRAME", blizzardFlowGridType = "RD",
      selfPoint = "BOTTOMRIGHT", anchorPoint = "BOTTOM", xOffset = 3, yOffset = -4 }, { "player" })
    Rechain(framedGroup)
    failSetParent = false
    local framed = GridContainer("MuscaGridFrameRefusedMember")
    assert(framed, "refused unit frame grid container not built")
    ExpectPoint(framed, "TOPLEFT", frame, "BOTTOM", 3, -4, "unit frame grid anchored although SetParent fails")
    Same(framed:GetFrameStrata(), "DIALOG", "unit frame grid strata")
    Same(framed:GetFrameLevel(), 4, "unit frame grid level")
  end

  -- 7. Screen grid: the first container sits on the region of the first member, the next units are stacked.
  do
    local group, region = GridFixture("ScreenGrid", { blizzardFlowGridType = "RD" }, { "player", "party1" })
    private.regions.ScreenGrid = { region = CreateFrame("Frame") }
    Rechain(group)
    local first = GridContainer("MuscaGridScreenGridMember")
    assert(first, "screen grid container not built")
    local containers = {}
    for _, entry in ipairs(containerLog) do
      if entry.name == "AddAuraGroup" and entry[1] == "MuscaGridScreenGridMember" then containers[#containers + 1] = entry.frame end
    end
    Same(#containers, 2, "one screen grid container per unit")
    ExpectPoint(containers[1], "TOPLEFT", region, "TOPLEFT", 0, 0, "first screen grid container")
    ExpectPoint(containers[2], "TOPLEFT", containers[1], "BOTTOMLEFT", 0, -2, "second screen grid container")
  end

  -- 9. A grid disabled then enabled again keeps its buttons in the list of the instance, without duplicates.
  do
    local group, _, native = GridFixture("Toggle", { blizzardFlowGridType = "RD" }, { "player" })
    local instance = native.instances[1]
    Rechain(group)
    Same(#instance.buttons, 2, "grid buttons in the instance after the build")
    group.blizzardFlowGrid, native.gridMember = false, false
    Rechain(group)
    Same(#instance.buttons, 0, "grid buttons left in the instance after the grid is disabled")
    group.blizzardFlowGrid, native.gridMember = true, true
    Rechain(group)
    Same(#instance.buttons, 2, "grid buttons in the instance after the grid is enabled again")
    local seen = {}
    for _, buttonState in ipairs(instance.buttons) do
      assert(not seen[buttonState], "button listed twice in the instance")
      seen[buttonState] = true
    end
    group.blizzardFlowSpacing = 5
    Rechain(group)
    Same(#instance.buttons, 2, "grid buttons after a rebuild with another signature")
  end

  ------------------------------------------------------------------------------------------------
  -- 10. Show On: Always is not "found"; the missing shadow only exists for Show On: Missing.
  ------------------------------------------------------------------------------------------------
  do
    local function ShadowRegion(showOn)
      local group = Group("ShowOn" .. showOn, { blizzardFlowGrowth = "CENTER_HORIZONTAL", blizzardFlowSpacing = 2 })
      local region = CreateFrame("Frame")
      region.blizzardAuraDisplay = { instances = { { container = CreateFrame("Frame"), single = { missing = { active = true } } },
        { container = CreateFrame("Frame") } }, active = true }
      local data = Child({ id = group.id .. "Child", uid = group.id .. "Child", parent = group.id })
      TriggerOf(data).secretShowOn = showOn
      Display.EnsureFlowStart(region, data)
      local before = CountAdded("MuscaShadow")
      Display.EnsureFlowShadows(region, data)
      return region.blizzardAuraDisplay, CountAdded("MuscaShadow") - before
    end
    local native, added = ShadowRegion("showOnActive")
    Same(added, 2, "found: one shadow per instance")
    Same(native.flow.shadowKind, "list", "found: shadow kind")
    Same(native.instances[1].single.missing.flowShadow, nil, "found: missing shadow created")

    native, added = ShadowRegion("showAlways")
    Same(added, 0, "always: no shadow created")
    Same(native.flow.shadowKind, "fixed", "always: shadow kind")
    Same(native.instances[1].flowShadow, nil, "always: list shadow kept")
    Same(native.instances[1].single.missing.flowShadow, nil, "always: missing shadow created")

    native, added = ShadowRegion("showOnMissing")
    Same(added, 1, "missing: one shadow created")
    Same(native.flow.shadowKind, "missing", "missing: shadow kind")
    Same(native.instances[1].flowShadow, nil, "missing: list shadow created")
    assert(native.instances[1].single.missing.flowShadow, "missing: missing shadow absent")

    -- Always does not make the display a grid member either.
    Group("Flow", { blizzardFlowGrid = true })
    local child = Child()
    TriggerOf(child).secretShowOn = "showAlways"
    assert(Display.GridMember(child) == false, "Show On Always accepted by the grid")
  end

  -- 11. A grid container locked in combat (protected) keeps its anchor, then is replaced when combat ends.
  do
    local firstFrame, secondFrame = CreateFrame("Frame"), CreateFrame("Frame")
    unitFrames.player = firstFrame
    local group = GridFixture("LockedGrid", { blizzardFlowFrames = "UNITFRAME", blizzardFlowGridType = "RD",
      selfPoint = "TOPLEFT", anchorPoint = "TOPLEFT", xOffset = 0, yOffset = 0 }, { "player" })
    Rechain(group)
    local container = GridContainer("MuscaGridLockedGridMember")
    assert(container, "locked grid container not built")
    ExpectPoint(container, "TOPLEFT", firstFrame, "TOPLEFT", 0, 0, "locked grid container before combat")
    unitFrames.player = secondFrame
    test.Frames.SetProtected(container, true)
    test.Units.SetCombat(true)
    Rechain(group)
    ExpectPoint(container, "TOPLEFT", firstFrame, "TOPLEFT", 0, 0, "locked grid container kept in combat")
    test.Units.SetCombat(false)
    test.Frames.SetProtected(container, false)
    test.Environment.Advance(0.1)
    ExpectPoint(container, "TOPLEFT", secondFrame, "TOPLEFT", 0, 0, "locked grid container replaced after combat")
  end

  -- 12. Centered growth: Limit caps the shadow of every clone, and a missing display gets a single shadow
  -- of one slot, half an element plus a pixel behind the center, before the first visible start.
  do
    local group = Group("Limited", { blizzardFlowGrowth = "CENTER_HORIZONTAL", blizzardFlowSpacing = 4,
      blizzardFlowUseLimit = true, blizzardFlowLimit = 3, controlledChildren = { "LimitedChild" } })
    local region = CreateFrame("Frame")
    region.blizzardAuraDisplay = { instances = { { container = CreateFrame("Frame") }, { container = CreateFrame("Frame") } },
      active = true }
    local data = Child({ id = "LimitedChild", uid = "LimitedChild", parent = "Limited" })
    groups.LimitedChild = data
    Display.EnsureFlowStart(region, data)
    Display.EnsureFlowShadows(region, data)
    local flow = region.blizzardAuraDisplay.flow
    Same(#flow.shadowList, 2, "limited: one shadow per clone")
    for slot, shadow in ipairs(flow.shadowList) do
      local settings
      for _, entry in ipairs(shadow.log) do
        if entry.name == "AddAuraGroup" then settings = entry[3] end
      end
      Same(settings.maxFrameCount, 3, "limited: shadow of clone " .. slot .. " capped by the group limit")
      Same(settings.layout.elementWidth, (30 + 4) / 2 + 1, "limited: shadow element width of clone " .. slot)
    end

    group = Group("Missing", { blizzardFlowGrowth = "CENTER_HORIZONTAL", blizzardFlowSpacing = 4,
      blizzardFlowUseLimit = true, blizzardFlowLimit = 3, controlledChildren = { "MissingChild" } })
    region = CreateFrame("Frame")
    local missing = { active = true }
    region.blizzardAuraDisplay = { instances = { { container = CreateFrame("Frame"), single = { missing = missing } } },
      active = true }
    data = Child({ id = "MissingChild", uid = "MissingChild", parent = "Missing" })
    TriggerOf(data).secretShowOn = "showOnMissing"
    groups.MissingChild = data
    Display.EnsureFlowStart(region, data)
    Display.EnsureFlowShadows(region, data)
    Display.SetFlowEnd(region, data)
    private.regions.MissingChild = { region = region }
    Rechain(group)
    flow = region.blizzardAuraDisplay.flow
    Same(flow.shadowKind, "missing", "missing: shadow kind")
    Same(AddedSettings("MuscaShadow").maxFrameCount, 1, "missing: one slot, whatever the limit")
    ExpectPoint(flow.shadowStart, "TOPRIGHT", region, "TOP", 0, 0, "missing: shadow start on the center point")
    ExpectPoint(missing.flowShadow, "TOPLEFT", flow.shadowStart, "TOPRIGHT", -18, 0, "missing: shadow behind the center")
    ExpectPoint(flow.start, "TOPLEFT", missing.flowShadow, "TOPRIGHT", 2, 0, "missing: visible start after the shadow")
    private.regions.MissingChild = nil
  end

  -- 13 (spec only). A Rebind that fails (SetParent refused, container locked) must not stop UpdateInstance:
  -- SetUnit, SetShown and the rest still run. The former AttachContainer had no failure path (an error from
  -- SetParent escapes), so the case cannot run against it.

  -- Restores.
  private.regions.Screen = nil
  CreateFrame = originals.CreateFrame
  Display.SetupAuraButton, Display.UnitTokens = originals.SetupAuraButton, originals.UnitTokens
  Display.StyleNative = originals.StyleNative
  AuraContainerSortMethod, AuraContainerSortDirection = sortMethodsBefore, sortDirectionBefore
  CustomAuraContainerAuraProcessingPolicy = originals.policy
  WeakAuras.GetData, WeakAuras.GetUnitFrame = originals.GetData, originals.GetUnitFrame
  C_NamePlate.GetNamePlateForUnit = originals.GetNamePlateForUnit
end

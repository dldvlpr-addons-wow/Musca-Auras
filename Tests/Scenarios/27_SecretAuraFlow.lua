-- SecretAuraFlow: flow group settings (growth, limit, sort, problems), container creation, flow start and
-- chaining, deferred chaining in combat.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local sortMethodsBefore, sortDirectionBefore = AuraContainerSortMethod, AuraContainerSortDirection
  AuraContainerSortMethod, AuraContainerSortDirection = {}, { Normal = 0, Reverse = 1 }
  local sortValue = 0
  for name in pairs(Display.sortMethods) do
    AuraContainerSortMethod[name] = sortValue
    sortValue = sortValue + 1
  end

  local groups = {}
  local getData = WeakAuras.GetData
  WeakAuras.GetData = function(id) return groups[id] or getData(id) end
  local function Child(extra)
    local data = { id = "Child", uid = "Child", parent = "Flow", regionType = "icon", width = 30, height = 20 }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  groups.Flow = { id = "Flow", regionType = "group", blizzardFlow = true }

  assert(Display.FlowGroup(Child()) == groups.Flow, "flow group not found")
  assert(Display.FlowGroup({ id = "Alone" }) == nil, "group found without a parent")
  assert(Display.FlowGroup(Child({ parent = "Other" })) == nil, "unknown parent used")
  groups.Plain = { id = "Plain", regionType = "group" }
  assert(Display.FlowGroup(Child({ parent = "Plain" })) == nil, "group without blizzardFlow used")
  assert(Display.FlowGroup(nil) == nil, "nil data")

  local growth, spacing = Display.FlowGrowth(Child())
  assert(growth == "RIGHT" and spacing == 2, ("defaults: %s, %s"):format(tostring(growth), tostring(spacing)))
  groups.Flow.blizzardFlowGrowth, groups.Flow.blizzardFlowSpacing = "UP", "7"
  growth, spacing = Display.FlowGrowth(Child())
  assert(growth == "UP" and spacing == 7, ("settings: %s, %s"):format(tostring(growth), tostring(spacing)))
  groups.Flow.blizzardFlowGrowth = "SIDEWAYS"
  assert(Display.FlowGrowth(Child()) == "RIGHT", "unknown growth kept")
  assert(Display.FlowGrowth({ id = "Alone" }) == nil, "growth without group")

  groups.Flow.blizzardFlowGrowth, groups.Flow.selfPoint = "CENTER_VERTICAL", "BOTTOMLEFT"
  assert(Display.FlowGrowth(Child()) == "CENTER_VERTICAL", "centered growth remapped without frames")
  groups.Flow.blizzardFlowFrames = "UNITFRAME"
  assert(Display.FlowGrowth(Child()) == "UP", "centered vertical not remapped from a bottom self point")
  groups.Flow.selfPoint = "TOPRIGHT"
  assert(Display.FlowGrowth(Child()) == "DOWN", "centered vertical not remapped from a top self point")
  groups.Flow.selfPoint = nil
  assert(Display.FlowGrowth(Child()) == "CENTER_VERTICAL", "centered growth remapped from the center")
  groups.Flow.blizzardFlowGrowth, groups.Flow.selfPoint = "CENTER_HORIZONTAL", "LEFT"
  assert(Display.FlowGrowth(Child()) == "RIGHT", "centered horizontal not remapped from a left self point")
  assert(Display.VisibleGrowth("CENTER_HORIZONTAL") == "RIGHT" and Display.VisibleGrowth("CENTER_VERTICAL") == "DOWN",
    "visible growth of centered")
  assert(Display.VisibleGrowth("LEFT") == "LEFT" and Display.VisibleGrowth("nope") == "nope", "visible growth of plain")

  assert(Display.FlowFrameMode(Child()) == "UNITFRAME", "frame mode")
  assert(Display.FrameAnchorType(Child()) == "UNITFRAME", "anchor type in a framed group")
  groups.Flow.blizzardFlowFrames = "SCREEN"
  assert(Display.FlowFrameMode(Child()) == nil and Display.FrameAnchorType(Child()) == "SCREEN", "unframed group")
  assert(Display.FrameAnchorType({ id = "Alone", anchorFrameType = "MOUSE" }) == "MOUSE", "anchor type without group")

  assert(Display.FlowLimit(Child()) == 20, "default limit")
  groups.Flow.blizzardFlowUseLimit = true
  assert(Display.FlowLimit(Child()) == 5, "limit without value")
  groups.Flow.blizzardFlowLimit = 7.9
  assert(Display.FlowLimit(Child()) == 7, "limit not floored")
  groups.Flow.blizzardFlowLimit = -3
  assert(Display.FlowLimit(Child()) == 1, "limit below one")
  assert(Display.FlowLimit({ id = "Alone" }) == nil, "limit without group")

  local trigger = { sortMethod = "Name", sortReverse = true }
  local method, direction = Display.SortOrder({ id = "Alone" }, trigger)
  assert(method == AuraContainerSortMethod.Name and direction == AuraContainerSortDirection.Reverse,
    "sort taken from the trigger outside a group")
  groups.Flow.blizzardFlowSort = "Expiration"
  method, direction = Display.SortOrder(Child(), trigger)
  assert(method == AuraContainerSortMethod.Expiration and direction == AuraContainerSortDirection.Normal,
    "sort taken from the trigger inside a group")
  groups.Flow.blizzardFlowReverse = true
  assert(select(2, Display.SortOrder(Child(), trigger)) == AuraContainerSortDirection.Reverse, "group reverse ignored")
  groups.Flow.blizzardFlowSort = "UnitFrameDebuff"
  assert(Display.SortOrder(Child(), trigger) == AuraContainerSortMethod.Default, "UnitFrameDebuff sort kept")
  groups.Flow.blizzardFlowSort = "Bogus"
  assert(Display.SortOrder(Child(), trigger) == AuraContainerSortMethod.Default, "unknown sort kept")
  groups.Flow.blizzardFlowSort = nil
  assert(Display.SortOrder(Child(), trigger) == AuraContainerSortMethod.Default, "missing sort not Default")

  local active = { secretShowOn = "showOnActive", unit = "player" }
  assert(Display.FlowProblem({ id = "Alone", regionType = "text" }, active) == nil, "problem outside a group")
  assert(Display.FlowProblem(Child({ regionType = "text" }), active):find("Icon or Progress Bar"), "text display accepted")
  assert(Display.FlowProblem(Child({ regionType = "aurabar" }), active) == nil, "aurabar refused")
  assert(Display.FlowProblem(Child(), active) == nil, "valid child refused")
  groups.Flow.blizzardFlowFrames = "NAMEPLATE"
  assert(Display.FlowProblem(Child(), active):find("choose the Nameplate unit"), "nameplate group with a player unit")
  assert(Display.FlowProblem(Child(), { secretShowOn = "showOnActive", unit = "nameplate" }) == nil, "nameplate refused")
  assert(Display.FlowProblem(Child(), { secretShowOn = "showOnMissing", unit = "nameplate" }):find("Aura%(s%) Found"),
    "missing aura accepted in a framed group")
  groups.Flow.blizzardFlowFrames = "UNITFRAME"
  assert(Display.FlowProblem(Child(), { secretShowOn = "showOnActive", unit = "nameplate" }):find("other than Nameplate"),
    "nameplate unit in a unit frame group")

  local container, locked = Display.CreateAuraContainer(CreateFrame("Frame"), Child())
  assert(container and locked == true, "flow container not locked")
  local savedCreateFrame = CreateFrame
  CreateFrame = function(frameType, name, parent, template)
    if template and template:find("DisableUntrustedLayoutScriptsTemplate") then error("template unknown") end
    return savedCreateFrame(frameType, name, parent, template)
  end
  container, locked = Display.CreateAuraContainer(CreateFrame("Frame"), Child())
  CreateFrame = savedCreateFrame
  assert(container and locked == false, "no fallback when the locked template fails")
  container, locked = Display.CreateAuraContainer(CreateFrame("Frame"), { id = "Alone" })
  assert(container and locked == false, "locked container outside a group")

  groups.Flow.blizzardFlowFrames, groups.Flow.blizzardFlowGrowth, groups.Flow.blizzardFlowSpacing = nil, "DOWN", 4
  local size = Display.FlowPresenceSize(Child())
  assert(size.elementWidth == 30 and size.elementHeight == 25, ("vertical presence: %s x %s"):format(size.elementWidth, size.elementHeight))
  groups.Flow.blizzardFlowGrowth = "LEFT"
  size = Display.FlowPresenceSize(Child())
  assert(size.elementWidth == 35 and size.elementHeight == 20, ("horizontal presence: %s x %s"):format(size.elementWidth, size.elementHeight))

  groups.Flow.blizzardFlowGrowth, groups.Flow.blizzardFlowSpacing = "RIGHT", 2
  local region = CreateFrame("Frame")
  region.blizzardAuraDisplay = { instances = {} }
  local data = Child({ triggers = { { trigger = { type = "secretAura", unit = "player", secretShowOn = "showOnActive" } } } })
  Display.EnsureFlowStart(region, data)
  local flow = region.blizzardAuraDisplay.flow
  assert(flow and flow.start and flow.start:IsShown(), "flow start not created")
  assert(flow.start:GetWidth() == 30 and flow.start:GetHeight() == 20, "flow start size")
  local point, relativeTo, relativePoint = flow.start:GetPoint(1)
  assert(point == "TOPLEFT" and relativeTo == region and relativePoint == "TOPLEFT", "flow start anchor")
  Display.EnsureFlowStart(region, data)
  assert(region.blizzardAuraDisplay.flow == flow and flow.start:GetNumPoints() == 1, "flow start rebuilt or anchored twice")
  Display.SetFlowEnd(region, data)
  assert(flow.endFrame == flow.start and flow.endPoint == "TOPLEFT" and flow.x == 32 and flow.y == 0,
    ("flow end without instance: %s %s"):format(tostring(flow.x), tostring(flow.y)))
  local last = { container = CreateFrame("Frame") }
  region.blizzardAuraDisplay.instances[1] = last
  Display.SetFlowEnd(region, data)
  assert(flow.endFrame == last.container and flow.endPoint == "TOPRIGHT" and flow.x == -1 and flow.y == 0, "flow end after the last instance")
  Display.EnsureFlowStart({ blizzardAuraDisplay = region.blizzardAuraDisplay }, { id = "Alone" })
  assert(region.blizzardAuraDisplay.flow == nil and not flow.start:IsShown(), "flow start kept outside a group")

  local function NewChild(id)
    local childRegion = CreateFrame("Frame")
    childRegion.blizzardAuraDisplay = { instances = {}, active = true }
    local childData = Child({ id = id, uid = id, triggers = data.triggers })
    Display.EnsureFlowStart(childRegion, childData)
    local childFlow = childRegion.blizzardAuraDisplay.flow
    childFlow.endFrame, childFlow.endPoint, childFlow.x, childFlow.y = childFlow.start, "TOPLEFT", 32, 0
    private.regions[id] = { region = childRegion }
    return childFlow
  end
  groups.Flow.controlledChildren = { "First", "Second" }
  local first, second = NewChild("First"), NewChild("Second")
  test.Units.SetCombat(true)
  second.start:ClearAllPoints()
  Display.RechainFlow(groups.Flow)
  test.Environment.Advance(0.1)
  assert(second.start:GetNumPoints() == 0, "flow chained in combat")
  assert(#test.Environment.forbidden == 0, "forbidden call while chaining in combat")
  test.Units.SetCombat(false)
  test.Environment.Advance(0.1)
  point, relativeTo, relativePoint = second.start:GetPoint(1)
  assert(point == "TOPLEFT" and relativeTo == first.endFrame and relativePoint == "TOPLEFT",
    "deferred chaining not replayed after combat")
  second.start:ClearAllPoints()
  Display.RechainFlow(groups.Flow)
  test.Environment.Advance(0.1)
  local x
  point, relativeTo, relativePoint, x = second.start:GetPoint(1)
  assert(second.start:GetNumPoints() == 1 and relativeTo == first.endFrame and x == 32, "chaining outside combat")

  private.regions.First, private.regions.Second = nil, nil
  WeakAuras.GetData = getData
  AuraContainerSortMethod, AuraContainerSortDirection = sortMethodsBefore, sortDirectionBefore
end

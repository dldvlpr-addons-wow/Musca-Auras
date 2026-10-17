-- Contract of SecretAuraFlow anchoring (complements scenarios 21 and 27): backward anchoring of the presence
-- frame, centered-growth shadow containers, per-unit relinking on unit frames (chaining, shadow chaining,
-- protected frames in combat, refused SetPoint, batching), grid type and grid membership warning, flow
-- problem precedence, anchor lookup differences between UnitAnchor and LocateAnchor.
-- Not covered: grid build, purge and refresh (needs button setup), the flow preview arrangement (scenarios 28, 35,
-- 38), KeepsAnchor / NoteAnchor of BlizzardAuraDisplay (local to UpdateInstance), droppedUnit through a batch.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function PointOf(frame, index, message)
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(index or 1)
    assert(point, (message or "point") .. ": no point set")
    return point, relativeTo, relativePoint, x, y
  end
  local function ExpectPoint(frame, point, relativeTo, relativePoint, x, y, message)
    assert(frame:GetNumPoints() == 1, ("%s: %d points"):format(message, frame:GetNumPoints()))
    local actualPoint, actualRelativeTo, actualRelativePoint, actualX, actualY = PointOf(frame, 1, message)
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
    UpdateWarning = private.AuraWarnings.UpdateWarning,
  }
  WeakAuras.GetData = function(id) return groups[id] or originals.GetData(id) end
  CustomAuraContainerAuraProcessingPolicy = { None = 0 }
  local unitFrames, plates = {}, {}
  WeakAuras.GetUnitFrame = function(unit) return unitFrames[unit] end
  C_NamePlate = C_NamePlate or {}
  C_NamePlate.GetNamePlateForUnit = function(unit) return plates[unit] end

  local warnings = {}
  private.AuraWarnings.UpdateWarning = function(uid, key, severity, message)
    warnings[#warnings + 1] = { uid = uid, key = key, severity = severity, message = message }
  end

  -- The harness has no AuraContainer: a frame with recording stubs stands in for it.
  local containerLog, failAddGroup = {}, false
  local function WithContainerMethods(frame)
    frame.log = {}
    local function Record(name)
      return function(self, ...)
        self.log[#self.log + 1] = { name = name, ... }
        containerLog[#containerLog + 1] = { frame = self, name = name, ... }
      end
    end
    for _, name in ipairs({ "SetAuraGroupFilterString", "SetAuraGroupCandidateFilters", "SetAuraGroupLayout",
      "SetAuraGroupMaxFrameCount", "SetAuraGroupEnabled", "SetFlowLayoutAxis", "SetFlowLayoutAnchorPoint",
      "SetFlowLayoutGrowthDirection", "SetAuraProcessingPolicy", "UpdateAllAuras", "SetUnit" }) do
      frame[name] = Record(name)
    end
    frame.SetEnabled = function(self, value)
      self.enabledValue = value
      self.log[#self.log + 1] = { name = "SetEnabled", value }
    end
    frame.AddAuraGroup = function(self, groupName, filter, settings)
      if failAddGroup then error("group refused") end
      self.log[#self.log + 1] = { name = "AddAuraGroup", groupName, filter, settings }
    end
    return frame
  end
  local function Calls(frame, name)
    local found = {}
    for _, entry in ipairs(frame.log) do
      if entry.name == name then found[#found + 1] = entry end
    end
    return found
  end
  CreateFrame = function(frameType, name, parent, template)
    local frame = originals.CreateFrame(frameType == "AuraContainer" and "Frame" or frameType, name, parent, template)
    if frameType == "AuraContainer" then WithContainerMethods(frame) end
    return frame
  end

  groups.Flow = { id = "Flow", uid = "Flow", regionType = "group", blizzardFlow = true }
  local function Child(extra)
    local data = { id = "Child", uid = "Child", parent = "Flow", regionType = "icon", width = 30, height = 20,
      triggers = { activeTriggerMode = 1, { trigger = { type = "secretAura", unit = "player", secretShowOn = "showOnActive" } } } }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function TriggerOf(data) return data.triggers[1].trigger end

  ------------------------------------------------------------------------------------------------
  -- GridType: explicit valid type, then the type implied by the growth, then RD.
  ------------------------------------------------------------------------------------------------
  Same(Display.GridType({ blizzardFlowGridType = "LU" }), "LU", "explicit grid type")
  Same(Display.GridType({ blizzardFlowGridType = "XX", blizzardFlowGrowth = "UP" }), "UR", "invalid type, growth UP")
  Same(Display.GridType({ blizzardFlowGrowth = "LEFT" }), "LD", "growth LEFT")
  Same(Display.GridType({ blizzardFlowGrowth = "DOWN" }), "DR", "growth DOWN")
  Same(Display.GridType({ blizzardFlowGrowth = "CENTER_VERTICAL" }), "DR", "growth centered vertical")
  Same(Display.GridType({ blizzardFlowGrowth = "CENTER_HORIZONTAL" }), "RD", "growth centered horizontal")
  Same(Display.GridType({ blizzardFlowGrowth = "BOGUS" }), "RD", "unknown growth")
  Same(Display.GridType({}), "RD", "no growth")
  Same(Display.GridType({ blizzardFlowGridType = "UL", blizzardFlowGrowth = "LEFT" }), "UL", "explicit type beats growth")

  ------------------------------------------------------------------------------------------------
  -- GridMember: membership rule and the warning written or cleared on every call.
  ------------------------------------------------------------------------------------------------
  local function LastWarning(message)
    local last = warnings[#warnings]
    assert(last, message .. ": no warning call")
    Same(last.key, "blizzard_aura_grid", message .. " key")
    return last
  end
  assert(Display.GridMember({ id = "Alone", uid = "Alone" }) == false, "member outside a group")
  local last = LastWarning("outside a group")
  assert(last.severity == nil and last.message == nil and last.uid == "Alone", "warning not cleared outside a group")

  local child = Child()
  assert(Display.GridMember(child) == false, "member of a group without grid")
  last = LastWarning("group without grid")
  assert(last.severity == nil and last.message == nil and last.uid == "Child", "warning raised without grid")

  groups.Flow.blizzardFlowGrid = true
  assert(Display.GridMember(child) == true, "plain Aura(s) Found display refused by the grid")
  last = LastWarning("member")
  assert(last.severity == nil and last.message == nil, "warning kept for a member")

  TriggerOf(child).secretShowOn = "showOnMissing"
  assert(Display.GridMember(child) == false, "missing display accepted by the grid")
  last = LastWarning("missing display")
  Same(last.severity, "warning", "missing display severity")
  assert(type(last.message) == "string" and last.message:find("group grid"), "missing display message")

  child = Child({ blizzardAuraDisplay = { unitGlow = true } })
  assert(Display.GridMember(child) == false, "unit glow accepted by the grid")
  Same(LastWarning("unit glow").severity, "warning", "unit glow severity")

  child = Child()
  TriggerOf(child).secretUseRem, TriggerOf(child).secretRem = true, 5
  assert(Display.GridMember(child) == false, "remaining window accepted by the grid")
  Same(LastWarning("remaining window").severity, "warning", "remaining window severity")

  child = Child({ triggers = { activeTriggerMode = 1, { trigger = { type = "other" } } } })
  assert(Display.GridMember(child) == false, "display without a secret aura trigger accepted")
  Same(LastWarning("no trigger").severity, "warning", "no trigger severity")

  groups.Flow.blizzardFlowGrid = nil
  local callsBefore = #warnings
  Display.GridMember(Child())
  Same(#warnings, callsBefore + 1, "one warning call per GridMember call")

  ------------------------------------------------------------------------------------------------
  -- FlowProblem precedence: not an icon, remaining, no framed mode, single, nameplate, unit frame.
  ------------------------------------------------------------------------------------------------
  local activeTrigger = { secretShowOn = "showOnActive", unit = "player" }
  assert(Display.FlowProblem({ id = "Alone", regionType = "text" }, activeTrigger) == nil, "problem outside a group")
  groups.Flow.blizzardFlowFrames = "UNITFRAME"
  local problem = Display.FlowProblem(Child({ regionType = "text" }), { secretShowOn = "showAlways", unit = "nameplate" })
  assert(problem and problem:find("Icon or Progress Bar"), "display type must come first")
  problem = Display.FlowProblem(Child(), { secretShowOn = "showOnActive", secretUseRem = true, secretRem = 5, unit = "nameplate" })
  assert(problem and problem:find("Remaining Time"), "remaining must come before single")
  groups.Flow.blizzardFlowFrames = nil
  assert(Display.FlowProblem(Child(), { secretShowOn = "showAlways", unit = "nameplate" }) == nil,
    "single and unit rules apply without a framed mode")
  problem = Display.FlowProblem(Child(), { secretUseRem = true, secretRem = 5, secretShowOn = "showOnActive" })
  assert(problem and problem:find("Remaining Time"), "remaining must apply without a framed mode")
  groups.Flow.blizzardFlowFrames = "NAMEPLATE"
  problem = Display.FlowProblem(Child(), { secretShowOn = "showOnActive", unit = "player" })
  assert(problem and problem:find("Nameplate unit"), "nameplate group with another unit")
  assert(Display.FlowProblem(Child(), { secretShowOn = "showOnActive", unit = "nameplate" }) == nil, "nameplate group ok")
  groups.Flow.blizzardFlowFrames = nil

  ------------------------------------------------------------------------------------------------
  -- UnitAnchor and LocateAnchor: same job, different inputs.
  ------------------------------------------------------------------------------------------------
  local unitFrame, plate = CreateFrame("Frame"), CreateFrame("Frame")
  unitFrames.player, plates.player = unitFrame, plate
  Same(Display.UnitAnchor("NAMEPLATE", "player"), plate, "nameplate mode ignores the unit frame")
  Same(Display.UnitAnchor("UNITFRAME", "player"), unitFrame, "unit frame mode")
  Same(Display.UnitAnchor("SCREEN", "player"), nil, "unknown mode")
  Same(Display.UnitAnchor(nil, "player"), nil, "no mode")
  Same(Display.LocateAnchor("player", true, true), unitFrame, "unit frame map wins over the nameplate map")
  unitFrames.player = nil
  Same(Display.LocateAnchor("player", true, true), nil, "unit frame map never falls back to a nameplate")
  unitFrames.player = unitFrame
  Same(Display.LocateAnchor("player", true, false, "player"), unitFrame, "dropped unit excludes only nameplates")
  Same(Display.LocateAnchor("player", false, true, "target"), plate, "other dropped unit")

  ------------------------------------------------------------------------------------------------
  -- AnchorFlowPresence: backward anchoring on the flow start for each growth, then the fallback.
  ------------------------------------------------------------------------------------------------
  local function FlowRegion(growth, spacing)
    groups.Flow.blizzardFlowGrowth, groups.Flow.blizzardFlowSpacing = growth, spacing
    local region = CreateFrame("Frame")
    region.blizzardAuraDisplay = { instances = {}, active = true }
    local data = Child()
    Display.EnsureFlowStart(region, data)
    return region, data, region.blizzardAuraDisplay.flow
  end
  local expected = {
    RIGHT = { "TOPRIGHT", "TOPLEFT", 33, 0 },
    LEFT = { "TOPLEFT", "TOPRIGHT", -33, 0 },
    DOWN = { "BOTTOMLEFT", "TOPLEFT", 0, -23 },
    UP = { "TOPLEFT", "BOTTOMLEFT", 0, 23 },
    CENTER_HORIZONTAL = { "TOPRIGHT", "TOPLEFT", 33, 0 },
    CENTER_VERTICAL = { "BOTTOMLEFT", "TOPLEFT", 0, -23 },
  }
  for growth, row in pairs(expected) do
    local region, data, flow = FlowRegion(growth, 2)
    local presence = CreateFrame("Frame")
    presence:SetPoint("CENTER", UIParent, "CENTER")
    assert(Display.AnchorFlowPresence(region, data, presence) == true, growth .. ": anchoring refused")
    ExpectPoint(presence, row[1], flow.start, row[2], row[3], row[4], growth .. " presence")
  end

  local region, data, flow = FlowRegion("RIGHT", 2)
  local refusing = CreateFrame("Frame")
  local setPoint = refusing.SetPoint
  refusing.SetPoint = function(self, point, target, ...)
    if target == flow.start then error("Anchoring disallowed") end
    return setPoint(self, point, target, ...)
  end
  assert(Display.AnchorFlowPresence(region, data, refusing) == false, "refused anchor reported as success")
  ExpectPoint(refusing, "TOPLEFT", region, "TOPLEFT", 0, 0, "refused presence fallback")
  assert(Display.AnchorFlowPresence(CreateFrame("Frame"), data, CreateFrame("Frame")) == false, "presence without a flow")

  ------------------------------------------------------------------------------------------------
  -- EnsureFlowShadows and RefreshFlowShadow: centered growth only.
  ------------------------------------------------------------------------------------------------
  local function ShadowRegion(growth, instanceCount)
    local shadowRegion, shadowData, shadowFlow = FlowRegion(growth, 2)
    for index = 1, instanceCount do
      shadowRegion.blizzardAuraDisplay.instances[index] = { container = CreateFrame("Frame") }
    end
    return shadowRegion, shadowData, shadowFlow
  end
  local shadowRegion, shadowData, shadowFlow = ShadowRegion("CENTER_HORIZONTAL", 2)
  local instances = shadowRegion.blizzardAuraDisplay.instances
  Display.EnsureFlowShadows(shadowRegion, shadowData)
  assert(shadowFlow.shadowStart and shadowFlow.shadowStart:IsShown(), "shadow start missing")
  Same(shadowFlow.shadowStart:GetWidth(), 1, "shadow start width")
  Same(shadowFlow.shadowStart:GetHeight(), 1, "shadow start height")
  Same(shadowFlow.half, 16, "half of one slot")
  Same(shadowFlow.shadowKind, "list", "shadow kind")
  Same(#shadowFlow.shadowList, 2, "one shadow per instance")
  for index, instance in ipairs(instances) do
    assert(instance.flowShadow and instance.flowShadowActive == true, "instance " .. index .. " shadow")
    assert(shadowFlow.shadowList[index] == instance.flowShadow, "shadow list order")
    local added = Calls(instance.flowShadow, "AddAuraGroup")
    Same(#added, 1, "shadow group created once")
    Same(added[1][1], "MuscaShadow", "shadow group name")
    local settings = added[1][3]
    Same(settings.maxFrameCount, 20, "shadow limit follows the display limit")
    Same(settings.layout.elementWidth, 17, "shadow width")
    Same(settings.layout.elementHeight, 20, "shadow height")
    Same(settings.layout.elementSpacing, -1, "shadow spacing")
    Same(instance.flowShadow.enabledValue, false, "shadow created disabled")
    Same(Calls(instance.flowShadow, "SetAuraProcessingPolicy")[1][1], 0, "shadow processing policy")
    Same(Calls(instance.flowShadow, "SetFlowLayoutAxis")[1][1], AnchorUtil.FlowLayoutAxis.Horizontal, "shadow axis")
    Same(Calls(instance.flowShadow, "SetFlowLayoutAnchorPoint")[1][1], "TOPRIGHT", "shadow flow anchor point")
  end
  local firstShadow = instances[1].flowShadow
  Display.EnsureFlowShadows(shadowRegion, shadowData)
  assert(instances[1].flowShadow == firstShadow, "shadow rebuilt")
  Same(#Calls(firstShadow, "AddAuraGroup"), 1, "shadow group added twice")
  assert(#Calls(firstShadow, "SetAuraGroupLayout") >= 1 and #Calls(firstShadow, "SetAuraGroupEnabled") >= 1,
    "existing shadow not updated")

  -- A group the client refuses leaves the instance without shadow.
  instances[3] = { container = CreateFrame("Frame") }
  failAddGroup = true
  Display.EnsureFlowShadows(shadowRegion, shadowData)
  failAddGroup = false
  Same(instances[3].flowShadowActive, false, "refused shadow marked active")
  Same(instances[3].flowShadow, nil, "refused shadow kept")
  Same(#shadowFlow.shadowList, 2, "refused shadow listed")
  instances[3] = nil

  -- Missing display: one shadow anchored backwards on the shadow start, list shadows hidden.
  TriggerOf(shadowData).secretShowOn = "showOnMissing"
  shadowRegion.blizzardAuraDisplay.instances[1].single = { missing = { active = true } }
  shadowData.triggers[1].trigger.secretShowOn = "showOnMissing"
  shadowRegion.blizzardAuraDisplay.instances[2] = nil
  shadowRegion.blizzardAuraDisplay.instances[1].flowShadowActive = true
  Display.EnsureFlowShadows(shadowRegion, shadowData)
  Same(shadowFlow.shadowKind, "missing", "missing shadow kind")
  Same(shadowFlow.shadowList, nil, "shadow list kept for a missing display")
  Same(instances[1].flowShadowActive, false, "list shadow kept active for a missing display")
  Same(firstShadow.enabledValue, false, "list shadow not disabled")
  assert(not firstShadow:IsShown(), "list shadow not hidden")
  local missing = instances[1].single.missing
  assert(missing.flowShadow and missing.flowShadowActive == true, "missing shadow absent")
  ExpectPoint(missing.flowShadow, "TOPLEFT", shadowFlow.shadowStart, "TOPRIGHT", -17, 0, "missing shadow")

  -- A growth without shadow hides every shadow and the shadow start.
  groups.Flow.blizzardFlowGrowth = "RIGHT"
  Display.EnsureFlowStart(shadowRegion, shadowData)
  Display.EnsureFlowShadows(shadowRegion, shadowData)
  Same(missing.flowShadowActive, false, "missing shadow kept with a plain growth")
  assert(not missing.flowShadow:IsShown() and not shadowFlow.shadowStart:IsShown(), "shadow frames not hidden")

  -- RefreshFlowShadow: rebinding order, visibility and update.
  local shadow = WithContainerMethods(CreateFrame("Frame"))
  local instance = { flowShadow = shadow, flowShadowActive = true }
  Display.RefreshFlowShadow(instance, "party1", true)
  Same(shadow.log[1].name, "SetEnabled", "shadow disabled before rebinding")
  Same(shadow.log[1][1], false, "shadow disabled before rebinding value")
  Same(shadow.log[2].name, "SetUnit", "shadow rebound")
  Same(shadow.log[2][1], "party1", "shadow unit")
  Same(instance.flowShadowUnit, "party1", "shadow unit remembered")
  assert(shadow:IsShown() and shadow.enabledValue == true, "shadow not shown")
  Same(#Calls(shadow, "UpdateAllAuras"), 1, "shadow update")
  Display.RefreshFlowShadow(instance, "party1", true)
  Same(#Calls(shadow, "SetUnit"), 1, "shadow rebound for the same unit")
  Same(#Calls(shadow, "UpdateAllAuras"), 2, "shown shadow not updated again")
  Display.RefreshFlowShadow(instance, nil, false)
  assert(not shadow:IsShown() and shadow.enabledValue == false, "shadow not hidden")
  Same(#Calls(shadow, "UpdateAllAuras"), 2, "hidden shadow updated")
  Same(#Calls(shadow, "SetUnit"), 1, "unit lost without unit")
  local inactive = WithContainerMethods(CreateFrame("Frame"))
  Display.RefreshFlowShadow({ flowShadow = inactive, flowShadowActive = false }, "party2", true)
  Same(#inactive.log, 0, "inactive shadow touched")

  ------------------------------------------------------------------------------------------------
  -- RelinkFlowUnits on unit frames: chain per unit, shadow chaining, protection, refusal, batches.
  ------------------------------------------------------------------------------------------------
  local deferredGroup = { id = "Relink", uid = "Relink", regionType = "group", blizzardFlow = true,
    blizzardFlowFrames = "UNITFRAME", blizzardFlowGrowth = "RIGHT", selfPoint = "TOP", anchorPoint = "BOTTOM",
    xOffset = 3, yOffset = -4 }
  groups.Relink = deferredGroup
  local playerFrame, targetFrame = CreateFrame("Frame"), CreateFrame("Frame")
  unitFrames.player, unitFrames.target = playerFrame, targetFrame
  local function BoundInstance(unit, visible)
    local container = CreateFrame("Frame")
    container:SetPoint("CENTER", UIParent, "CENTER")
    return { container = container, boundUnit = unit, visible = visible ~= false }
  end
  local function AddChild(id, childInstances)
    local childRegion = CreateFrame("Frame")
    childRegion.blizzardAuraDisplay = { instances = childInstances, active = true }
    private.regions[id] = { region = childRegion }
  end
  local playerFirst, playerSecond, targetOnly = BoundInstance("player"), BoundInstance("player"), BoundInstance("target")
  local hidden = BoundInstance("player", false)
  local noFrame = BoundInstance("focus")
  deferredGroup.controlledChildren = { "RelinkA", "RelinkB" }
  AddChild("RelinkA", { playerFirst, hidden })
  AddChild("RelinkB", { playerSecond, targetOnly, noFrame })
  Display.RelinkFlowUnits(deferredGroup)
  ExpectPoint(playerFirst.container, "TOPLEFT", playerFrame, "BOTTOM", 3, -4, "first container of a unit")
  ExpectPoint(playerSecond.container, "TOPLEFT", playerFirst.container, "TOPRIGHT", -1, 0, "second container of a unit")
  ExpectPoint(targetOnly.container, "TOPLEFT", targetFrame, "BOTTOM", 3, -4, "other unit starts on its unit frame")
  Same(hidden.container:GetNumPoints(), 1, "invisible instance moved")
  assert(select(2, PointOf(hidden.container)) == UIParent, "invisible instance re-anchored")
  Same(noFrame.container:GetNumPoints(), 0, "container of a unit without frame keeps points")
  Display.RelinkFlowUnits(groups.Flow)
  Display.RelinkFlowUnits(nil)

  -- Protected container in combat: untouched, then anchored once combat ends.
  playerFirst.container:ClearAllPoints()
  playerFirst.container:SetPoint("CENTER", UIParent, "CENTER")
  test.Frames.SetProtected(playerFirst.container, true)
  test.Units.SetCombat(true)
  Display.RelinkFlowUnits(deferredGroup)
  assert(#test.Environment.forbidden == 0, "protected container touched in combat")
  assert(select(2, PointOf(playerFirst.container)) == UIParent, "protected container moved in combat")
  ExpectPoint(targetOnly.container, "TOPLEFT", targetFrame, "BOTTOM", 3, -4, "unprotected container in combat")
  test.Units.SetCombat(false)
  test.Environment.Advance(0.1)
  ExpectPoint(playerFirst.container, "TOPLEFT", playerFrame, "BOTTOM", 3, -4, "deferred container after combat")
  ExpectPoint(playerSecond.container, "TOPLEFT", playerFirst.container, "TOPRIGHT", -1, 0, "chain after combat")

  -- SetPoint refused by the client: no error, retried when restrictions change.
  local refusal = true
  local targetSetPoint = targetOnly.container.SetPoint
  targetOnly.container.SetPoint = function(self, point, relativeTo, ...)
    if refusal and relativeTo == targetFrame then error("Anchoring disallowed") end
    return targetSetPoint(self, point, relativeTo, ...)
  end
  Display.RelinkFlowUnits(deferredGroup)
  Same(targetOnly.container:GetNumPoints(), 0, "refused container kept a point")
  refusal = false
  private.callbacks:Fire("RestrictionChanged")
  ExpectPoint(targetOnly.container, "TOPLEFT", targetFrame, "BOTTOM", 3, -4, "refused container after restriction change")

  -- Batch: requests collapse into one relink, a second Begin does not nest.
  local relinks = 0
  local playerSetPoint = playerFirst.container.SetPoint
  playerFirst.container.SetPoint = function(self, ...)
    relinks = relinks + 1
    return playerSetPoint(self, ...)
  end
  Display.BeginFlowBatch()
  Display.BeginFlowBatch()
  Display.RelinkFlowUnits(deferredGroup)
  Display.RefreshFlowUnits(deferredGroup, "target")
  Display.RefreshFlowUnits(deferredGroup)
  Same(relinks, 0, "relink during a batch")
  Display.EndFlowBatch()
  Same(relinks, 1, "relinks after a batch")
  Display.RelinkFlowUnits(deferredGroup)
  Same(relinks, 2, "relink after the batch ended")
  Display.EndFlowBatch()
  Same(relinks, 2, "empty batch relinked")

  -- Shadows chain per unit and the containers follow the last shadow.
  local shadowGroup = { id = "Shadows", uid = "Shadows", regionType = "group", blizzardFlow = true,
    blizzardFlowFrames = "UNITFRAME", blizzardFlowGrowth = "CENTER_HORIZONTAL", selfPoint = "TOP", anchorPoint = "BOTTOM",
    xOffset = 3, yOffset = -4 }
  groups.Shadows = shadowGroup
  local function ShadowedInstance()
    local bound = BoundInstance("player")
    bound.flowShadow, bound.flowShadowActive = WithContainerMethods(CreateFrame("Frame")), true
    return bound
  end
  local shadowFirst, shadowSecond = ShadowedInstance(), ShadowedInstance()
  shadowGroup.controlledChildren = { "ShadowChild" }
  AddChild("ShadowChild", { shadowFirst, shadowSecond })
  Display.RelinkFlowUnits(shadowGroup)
  ExpectPoint(shadowFirst.flowShadow, "TOPRIGHT", playerFrame, "BOTTOM", 3, -4, "first shadow on the unit frame")
  ExpectPoint(shadowSecond.flowShadow, "TOPRIGHT", shadowFirst.flowShadow, "TOPLEFT", 1, 0, "second shadow chained")
  ExpectPoint(shadowFirst.container, "TOPLEFT", shadowSecond.flowShadow, "TOPLEFT", 2, 0, "first container on the last shadow")
  ExpectPoint(shadowSecond.container, "TOPLEFT", shadowFirst.container, "TOPRIGHT", -1, 0, "second container chained")

  -- Protected shadow in combat: not moved, group deferred, chain still advances.
  shadowFirst.flowShadow:ClearAllPoints()
  test.Frames.SetProtected(shadowFirst.flowShadow, true)
  test.Units.SetCombat(true)
  Display.RelinkFlowUnits(shadowGroup)
  assert(#test.Environment.forbidden == 0, "protected shadow touched in combat")
  Same(shadowFirst.flowShadow:GetNumPoints(), 0, "protected shadow moved in combat")
  test.Units.SetCombat(false)
  test.Environment.Advance(0.1)
  ExpectPoint(shadowFirst.flowShadow, "TOPRIGHT", playerFrame, "BOTTOM", 3, -4, "protected shadow after combat")

  private.regions.RelinkA, private.regions.RelinkB, private.regions.ShadowChild = nil, nil, nil

  -- Restores.
  private.AuraWarnings.UpdateWarning = originals.UpdateWarning
  CreateFrame = originals.CreateFrame
  CustomAuraContainerAuraProcessingPolicy = originals.policy
  WeakAuras.GetData, WeakAuras.GetUnitFrame = originals.GetData, originals.GetUnitFrame
  C_NamePlate.GetNamePlateForUnit = originals.GetNamePlateForUnit
end

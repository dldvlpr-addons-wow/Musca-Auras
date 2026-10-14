-- Native aura anchors: container on the flow start, unit frame and nameplate lookup, inner and outer points,
-- text offset conditions.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local region = CreateFrame("Frame")
  assert(Display.ContentAnchor(region) == region, "plain region anchor")
  local container = CreateFrame("Frame")
  container:SetPoint("LEFT", UIParent, "LEFT")
  assert(Display.AnchorToContent(container, "TOP", region, "BOTTOM", 3) == true, "plain region refused")
  local point, relativeTo, relativePoint, x, y = container:GetPoint(1)
  assert(container:GetNumPoints() == 1, "old point kept")
  assert(point == "TOP" and relativeTo == region and relativePoint == "BOTTOM" and x == 3 and y == 0, "plain region point")

  local start = CreateFrame("Frame")
  region.blizzardAuraDisplay = { flow = { start = start } }
  assert(Display.ContentAnchor(region) == start, "flow start not used")
  container:ClearAllPoints()
  assert(Display.AnchorToContent(container, "CENTER", region, "CENTER", 1, 2) == true, "flow start refused")
  point, relativeTo, relativePoint, x, y = container:GetPoint(1)
  assert(relativeTo == start and x == 1 and y == 2, "container not on flow start")

  local refusing = CreateFrame("Frame")
  local setPoint = refusing.SetPoint
  refusing.SetPoint = function(self, anchorPoint, target, ...)
    if target == start then error("Anchoring disallowed") end
    return setPoint(self, anchorPoint, target, ...)
  end
  assert(Display.AnchorToContent(refusing, "CENTER", region, "CENTER") == false, "refused flow start reported as success")
  point, relativeTo = refusing:GetPoint(1)
  assert(relativeTo == region and refusing:GetNumPoints() == 1, "fallback not on the region")

  local unitFrame, plate = CreateFrame("Frame"), CreateFrame("Frame")
  local forbidden = CreateFrame("Frame")
  forbidden.IsForbidden = function() return true end
  local frames = { player = unitFrame, target = forbidden }
  local plates = { nameplate1 = plate, nameplate2 = forbidden }
  WeakAuras.GetUnitFrame = function(unit) return frames[unit] end
  C_NamePlate = C_NamePlate or {}
  C_NamePlate.GetNamePlateForUnit = function(unit) return plates[unit] end

  assert(Display.UnitAnchor("UNITFRAME", "player") == unitFrame, "unit frame not found")
  assert(Display.UnitAnchor("UNITFRAME", "nameplate1") == nil, "unit frame mode used a nameplate")
  assert(Display.UnitAnchor("NAMEPLATE", "nameplate1") == plate, "nameplate not found")
  assert(Display.UnitAnchor("UNITFRAME", "target") == nil and Display.UnitAnchor("NAMEPLATE", "nameplate2") == nil,
    "forbidden frame returned")

  assert(Display.LocateAnchor(nil, true, true) == nil, "anchor without unit")
  assert(Display.LocateAnchor("player", true, false) == unitFrame, "unit frame map")
  assert(Display.LocateAnchor("nameplate1", false, true) == plate, "nameplate map")
  assert(Display.LocateAnchor("nameplate1", false, true, "nameplate1") == nil, "dropped nameplate used")
  assert(Display.LocateAnchor("target", true, false) == nil, "forbidden unit frame used")
  assert(Display.LocateAnchor("nameplate1", false, false) == nil, "no map, anchor found")

  local native, button = { inner = CreateFrame("Frame"), outer = CreateFrame("Frame") }, CreateFrame("Frame")
  local target, splitPoint = Display.SplitAnchorTarget(native, button, "INNER_TOPLEFT")
  assert(target == native.inner and splitPoint == "TOPLEFT", "inner anchor")
  target, splitPoint = Display.SplitAnchorTarget(native, button, "OUTER_BOTTOM")
  assert(target == native.outer and splitPoint == "BOTTOM", "outer anchor")
  target, splitPoint = Display.SplitAnchorTarget(native, button, "CENTER")
  assert(target == button and splitPoint == "CENTER", "button anchor")

  local label = button:CreateFontString()
  label:SetPoint("LEFT", button, "RIGHT", 4, 6)
  local entry = { text = label }
  Display.AnchorOffsetApplier(true)(entry, nil, nil, 10)
  point, relativeTo, relativePoint, x, y = label:GetPoint(1)
  assert(label:GetNumPoints() == 1 and point == "LEFT" and relativeTo == button and relativePoint == "RIGHT",
    "label anchor changed")
  assert(x == 10 and y == 6, ("horizontal offset: %s, %s"):format(tostring(x), tostring(y)))
  Display.AnchorOffsetApplier(false)(entry, nil, nil, -3)
  point, relativeTo, relativePoint, x, y = label:GetPoint(1)
  assert(x == 10 and y == -3, "vertical offset")
  Display.AnchorOffsetApplier(true)(entry, nil, nil, nil)
  point, relativeTo, relativePoint, x, y = label:GetPoint(1)
  assert(x == 10 and y == -3, "nil offset changed the label")
  Display.AnchorOffsetApplier(true)({}, nil, nil, 5)
end

-- AnchorLinks: the links of the /wa Link tool and of the Edit Mode. The offsets keep the aura in place once anchored,
-- each side of the anchor menu gives its points, a link that would make a loop is refused, Link and Unlink write the anchor fields.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {} })
  local AnchorLinks = private.AnchorLinks
  local Same = test.Assertions.Same

  -- Source 64x64 at 100,100; target 200x50 at 300,400; both at scale 1.
  local x, y = AnchorLinks.Offsets({ 100, 100, 64, 64 }, 1, "TOPLEFT", { 300, 400, 200, 50 }, 1, "BOTTOMLEFT")
  Same(x, -200, "TOPLEFT to BOTTOMLEFT, x")
  Same(y, -236, "TOPLEFT to BOTTOMLEFT, y")
  x, y = AnchorLinks.Offsets({ 100, 100, 64, 64 }, 1, "CENTER", { 300, 400, 200, 50 }, 1, "RIGHT")
  Same(x, -368, "CENTER to RIGHT, x")
  Same(y, -293, "CENTER to RIGHT, y")
  -- Source at scale 2: its rectangle and its offsets are in its own units.
  x, y = AnchorLinks.Offsets({ 50, 50, 32, 32 }, 2, "BOTTOMLEFT", { 300, 400, 200, 50 }, 1, "BOTTOMLEFT")
  Same(x, -100, "scale 2, x")
  Same(y, -150, "scale 2, y")

  -- Sides of the anchor menu: the aura on that side of its target; a group keeps its selfPoint.
  local sides = {}
  for _, side in ipairs(AnchorLinks.sides) do
    sides[side.label] = side
  end
  Same(#AnchorLinks.sides, 8, "4 sides and 4 corners")
  Same(table.concat({ AnchorLinks.SidePoints({}, sides["Anchor to Left"]) }, " "), "RIGHT LEFT", "left side")
  Same(table.concat({ AnchorLinks.SidePoints({}, sides["Anchor to Bottom"]) }, " "), "TOP BOTTOM", "bottom side")
  Same(table.concat({ AnchorLinks.SidePoints({}, sides["Anchor to Top Right"]) }, " "), "BOTTOMRIGHT TOPRIGHT",
    "top right corner")
  Same(table.concat({ AnchorLinks.SidePoints({ regionType = "dynamicgroup", selfPoint = "TOPLEFT" },
    sides["Anchor to Right"]) }, " "), "TOPLEFT RIGHT", "a group keeps its selfPoint")

  -- A follows B, C is in group G, G follows D.
  local displays = {
    A = { id = "A", anchorFrameType = "SELECTFRAME", anchorFrameFrame = "WeakAuras:B" },
    B = { id = "B", anchorFrameType = "SCREEN" },
    C = { id = "C", parent = "G", anchorFrameType = "SCREEN" },
    G = { id = "G", regionType = "group", anchorFrameType = "SELECTFRAME", anchorFrameFrame = "WeakAuras:D" },
    D = { id = "D", anchorFrameType = "SELECTFRAME", anchorFrameFrame = "PlayerFrame" },
  }
  local GetData = WeakAuras.GetData
  WeakAuras.GetData = function(id) return displays[id] end
  Same(AnchorLinks.TargetAura(displays.A), "B", "target aura")
  Same(AnchorLinks.TargetAura(displays.D), nil, "a game frame is no aura")
  Same(AnchorLinks.DependsOn("A", "B"), true, "B to A would loop")
  Same(AnchorLinks.DependsOn("B", "A"), false, "A to B is fine")
  Same(AnchorLinks.DependsOn("C", "G"), true, "a group cannot follow its child")
  Same(AnchorLinks.DependsOn("C", "D"), true, "D cannot follow a child of the group that follows D")
  Same(AnchorLinks.DependsOn("G", "C"), false, "a child can follow its group")
  Same(AnchorLinks.DependsOn("A", "A"), true, "an aura cannot follow itself")
  -- A loop already saved does not hang the check.
  displays.B.anchorFrameType, displays.B.anchorFrameFrame = "SELECTFRAME", "WeakAuras:A"
  Same(AnchorLinks.DependsOn("A", "D"), false, "saved loop")
  WeakAuras.GetData = GetData

  local data = { id = "E", parent = "G", anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER" }
  AnchorLinks.Link(data, "WeakAuras:B", "TOPLEFT", "BOTTOMRIGHT", 4, -2)
  Same(data.anchorFrameType, "SELECTFRAME", "linked type")
  Same(data.anchorFrameFrame, "WeakAuras:B", "linked frame")
  Same(data.anchorFrameParent, false, "position only")
  Same(data.selfPoint .. " " .. data.anchorPoint, "TOPLEFT BOTTOMRIGHT", "linked points")
  Same(data.xOffset .. " " .. data.yOffset, "4 -2", "linked offsets")
  AnchorLinks.Unlink(data, 10, 20)
  Same(data.anchorFrameType, "SCREEN", "unlinked type")
  Same(data.anchorFrameFrame, nil, "unlinked frame")
  Same(data.anchorFrameParent, nil, "unlinked parent flag")
  Same(data.anchorPoint, "CENTER", "a child of a group is anchored on its center")
  Same(data.xOffset .. " " .. data.yOffset, "10 20", "unlinked offsets")

  -- In place: the aura, 64x64 at 100,100 in its group P (2x2 at 0,0), linked on the left of a 200x50 frame at 300,400.
  local function Rect(left, bottom, width, height)
    return {
      GetRect = function() return left, bottom, width, height end,
      GetEffectiveScale = function() return 1 end,
      GetScale = function() return 1 end,
    }
  end
  local region, target = Rect(100, 100, 64, 64), Rect(300, 400, 200, 50)
  private.regions.P = { region = Rect(0, 0, 2, 2) }
  local Watch = private.TimeMachine.Watch
  private.TimeMachine.Watch = function() end
  data = { id = "E", parent = "P", anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER" }
  Same(AnchorLinks.LinkInPlace(data, region, target, "WeakAuras:B", sides["Anchor to Left"]), true, "linked in place")
  Same(data.selfPoint .. " " .. data.anchorPoint, "RIGHT LEFT", "points of the side")
  Same(data.xOffset .. " " .. data.yOffset, "-136 -293", "offsets that keep the aura in place")
  Same(AnchorLinks.UnlinkInPlace(data, region), true, "unlinked in place")
  Same(data.anchorFrameType .. " " .. data.anchorPoint, "SCREEN CENTER", "back on the center of its group")
  Same(data.xOffset .. " " .. data.yOffset, "163 131", "offsets from the center of its group")
  -- A rectangle the game refuses changes nothing.
  local refused = Rect(nil, nil, nil, nil)
  Same(AnchorLinks.LinkInPlace(data, region, refused, "WeakAuras:B", sides["Anchor to Left"]), false, "refused")
  Same(data.anchorFrameType, "SCREEN", "nothing changed when refused")
  private.TimeMachine.Watch = Watch
  private.regions.P = nil
end

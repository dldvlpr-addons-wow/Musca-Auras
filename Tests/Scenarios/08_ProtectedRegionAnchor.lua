return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Shield = {
      id = "Shield", uid = "Shield", regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
  } })
  test.Environment.Advance(1)

  local region = WeakAuras.GetRegion("Shield")
  local data = WeakAuras.GetData("Shield")
  assert(region, "region not created")
  local secure = CreateFrame("Frame", nil, region)
  test.Frames.SetProtected(secure, true)
  assert(region:IsProtected(), "region with a protected child not protected")

  test.Units.SetCombat(true)
  data.anchorPoint = "TOP"
  private.AnchorFrame(data, region, nil)
  test.Environment.Advance(1.5)
  assert(#test.Environment.forbidden == 0, "protected region anchored in combat: " .. tostring(test.Environment.forbidden[1]))

  test.Units.SetCombat(false)
  test.Environment.Advance(1.5)
  assert(#test.Environment.forbidden == 0, "protected region anchored after combat")
  local _, _, relativePoint = region:GetPoint(1)
  assert(relativePoint == "TOP", "postponed anchor not applied after combat: " .. tostring(relativePoint))

  local clone = private.EnsureRegion("Shield", "c1")
  assert(clone and clone ~= region, "clone not created")
  test.Frames.SetProtected(CreateFrame("Frame", nil, clone), true)
  test.Units.SetCombat(true)
  data.anchorPoint = "BOTTOM"
  private.AnchorFrame(data, clone, nil)
  test.Environment.Advance(1.5)
  assert(#test.Environment.forbidden == 0, "protected clone anchored in combat")
  test.Units.SetCombat(false)
  test.Environment.Advance(1.5)
  local _, _, cloneRelativePoint = clone:GetPoint(1)
  assert(cloneRelativePoint == "BOTTOM", "postponed clone anchor not applied: " .. tostring(cloneRelativePoint))
end

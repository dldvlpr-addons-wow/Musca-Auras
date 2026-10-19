local function Aura(id, parent)
  return {
    id = id, uid = id, parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "event", event = "Conditions", use_alwaystrue = true }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 32, height = 32, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Group(id, regionType, child, conditions)
  return { id = id, uid = id, regionType = regionType, internalVersion = 91, controlledChildren = { child },
    load = {}, triggers = {}, conditions = conditions, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0, alpha = 1 }
end

local function InCombatAlpha(alpha)
  return { { check = { trigger = -1, variable = "incombat", value = 1 }, changes = { { property = "alpha", value = alpha } } } }
end

-- Conditions of a group: global checks only, applied to the group region, the children follow.
return function(test)
  local saved = { displays = {
    Pack = Group("Pack", "group", "Icon", InCombatAlpha(0.3)),
    Row = Group("Row", "dynamicgroup", "Bar", InCombatAlpha(0)),
    Plain = Group("Plain", "group", "Other", {}),
    Icon = Aura("Icon", "Pack"),
    Bar = Aura("Bar", "Row"),
    Other = Aura("Other", "Plain"),
    Fight = Group("Fight", "group", "Swing", InCombatAlpha(0.4)),
    Swing = Aura("Swing", "Fight"),
  } }
  saved.displays.Swing.load = { use_combat = true }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Alpha(id)
    return WeakAuras.GetRegion(id):GetAlpha()
  end

  assert(Alpha("Pack") == 1 and Alpha("Row") == 1, "full alpha out of combat")
  assert(next(private.GetTriggerConditions(saved.displays.Pack)) == nil, "no trigger condition on a group")

  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Alpha("Pack") == 0.3, "group dimmed in combat, got " .. tostring(Alpha("Pack")))
  assert(Alpha("Row") == 0, "dynamic group hidden in combat, got " .. tostring(Alpha("Row")))
  assert(Alpha("Plain") == 1, "group without condition untouched")

  -- An edit in combat rebuilds the region and the conditions at once.
  saved.displays.Pack.conditions = InCombatAlpha(0.5)
  WeakAuras.Add(saved.displays.Pack)
  assert(Alpha("Pack") == 0.5, "edited condition applied at once, got " .. tostring(Alpha("Pack")))

  -- A move (simple change) rebuilds the region too, the conditions apply again.
  saved.displays.Pack.xOffset = 10
  WeakAuras.Add(saved.displays.Pack, true)
  assert(Alpha("Pack") == 0.5, "condition kept after a move, got " .. tostring(Alpha("Pack")))
  test.Environment.Advance(0.5)

  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  assert(Alpha("Pack") == 1 and Alpha("Row") == 1, "alpha back after combat")

  -- Conditions removed: the group no longer follows the combat.
  saved.displays.Pack.conditions = {}
  WeakAuras.Add(saved.displays.Pack)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Alpha("Pack") == 1, "removed condition no longer applied")
  test.Units.SetCombat(false)

  -- A group whose children are all unloaded stops its conditions; reloaded, it follows the combat again.
  saved.displays.Bar.load = { use_never = true }
  WeakAuras.Add(saved.displays.Bar)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  saved.displays.Bar.load = {}
  WeakAuras.Add(saved.displays.Bar)
  assert(Alpha("Row") == 0, "reloaded group follows the combat, got " .. tostring(Alpha("Row")))
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  assert(Alpha("Row") == 1, "reloaded group back after combat")

  -- A child that could be loaded does not run: the conditions of its group stop.
  private.loaded.Bar = false
  private.UpdateGroupConditions(saved.displays.Row)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Alpha("Row") == 1, "no condition while the child could only be loaded")
  test.Units.SetCombat(false)
  private.loaded.Bar = true
  private.UpdateGroupConditions(saved.displays.Row)

  -- Options open: the conditions of the groups stop and the region gets its settings back; they run again on close.
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Alpha("Row") == 0, "condition applied before the pause")
  private.Pause()
  assert(Alpha("Row") == 1, "settings back while paused, got " .. tostring(Alpha("Row")))
  test.Units.SetCombat(false)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Alpha("Row") == 1, "no condition while paused")
  private.Resume()
  test.Environment.Advance(0.5)
  assert(Alpha("Row") == 0, "conditions back after the pause, got " .. tostring(Alpha("Row")))
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)

  -- A child loaded in combat only: out of combat the conditions of its group stop and start over, so a sound or a
  -- message plays again at the next combat.
  for _ = 1, 2 do
    test.Units.SetCombat(true)
    test.Environment.Advance(0.5)
    assert(Alpha("Fight") == 0.4, "group of a combat child dimmed, got " .. tostring(Alpha("Fight")))
    test.Units.SetCombat(false)
    test.Environment.Advance(0.5)
    assert(Alpha("Fight") == 1, "settings back when the child unloads, got " .. tostring(Alpha("Fight")))
    assert(WeakAuras.GetRegion("Fight").activatedConditions == nil, "conditions start over")
  end

  WeakAuras.Delete(saved.displays.Row)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
end

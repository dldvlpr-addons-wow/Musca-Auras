return function(test)
  local path = assert(os.getenv("PACK"), "set PACK to a pack file")
  local transmit = dofile(path)
  local displays, ids, uids = { [transmit.d.id] = transmit.d }, { [transmit.d.id] = true }, { [transmit.d.uid] = true }
  for _, child in ipairs(transmit.c) do
    assert(not ids[child.id], "duplicate id " .. child.id)
    assert(not uids[child.uid], "duplicate uid " .. child.uid)
    ids[child.id], uids[child.uid] = true, true
    displays[child.id] = child
  end
  for _, child in ipairs(transmit.c) do
    assert(ids[child.parent], child.id .. ": unknown parent " .. tostring(child.parent))
    for _, name in ipairs(child.controlledChildren or {}) do assert(ids[name], child.id .. ": unknown child " .. name) end
  end
  test.Units.DefineUnit("player", { name = "Tester", class = transmit.d.load.class.single or "WARRIOR", level = 60 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  AuraUtil.IsValidFilterString = function(filter) return filter == "HELPFUL" or filter == "HARMFUL" or filter == "HELPFUL|PLAYER" or filter == "HARMFUL|PLAYER" end
  local display = test.Loader.private.BlizzardAuraDisplay
  for _, child in ipairs(transmit.c) do
    assert(WeakAuras.GetData(child.id), child.id .. ": not loaded")
    if child.triggers.disjunctive == "expression" then
      local _, problem = test.Loader.private.CompileTriggerExpression(child.triggers.triggerExpression, #child.triggers)
      assert(not problem, child.id .. ": " .. tostring(problem))
    end
    if child.triggers[1].trigger.type == "secretAura" then
      local issue = display.Validate(WeakAuras.GetData(child.id))
      assert(issue == nil, child.id .. ": " .. tostring(issue))
    end
  end
  -- A child of a dynamic group is created on demand: an anchor to it is retried every second.
  test.Environment.Advance(1.1)
  for _, child in ipairs(transmit.c) do
    if child.anchorFrameType == "SELECTFRAME" then
      local region, target = WeakAuras.GetRegion(child.id), WeakAuras.GetRegion(child.anchorFrameFrame:sub(11))
      local _, relativeTo = region:GetPoint(1)
      assert(target and relativeTo == target, child.id .. ": not anchored to " .. child.anchorFrameFrame)
      assert(region:GetParent() ~= target, child.id .. ": parented to its anchor")
    end
  end
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
end

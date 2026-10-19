local function Icon(id, parent)
  return {
    id = id, uid = id, parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Group(id, children)
  return {
    id = id, uid = id, regionType = "group", internalVersion = 91, controlledChildren = children,
    load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
end

-- Undo and redo of the edits that the option panels write themselves and pass to WeakAuras.Add: the watched auras
-- are compared with their last copy, close edits make one step, and an unwatched edit still clears the history.
return function(test)
  local saved = {
    displays = {
      Pack = Group("Pack", { "Shout", "Shield" }),
      Shout = Icon("Shout", "Pack"),
      Shield = Icon("Shield", "Pack"),
      Alone = Icon("Alone"),
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  local TimeMachine = private.TimeMachine
  local shout, shield = WeakAuras.GetData("Shout"), WeakAuras.GetData("Shield")
  local function auraSpell(data)
    return data.triggers[1].trigger.auraspellids[1]
  end

  -- The login adds cleared the history in their own frame.
  test.Environment.Advance(2)
  -- Picking the group watches the group and its children.
  TimeMachine:Watch(WeakAuras.GetData("Pack"))
  WeakAuras.Add(shout)
  assert(TimeMachine:DescribePrevious() == nil, "an add without change is not a step")

  shout.triggers[1].trigger.auraspellids[1] = "2048"
  WeakAuras.Add(shout)
  assert(TimeMachine.index == 1, "trigger edit not recorded")
  test.Environment.Advance(2)
  shout.width = 40
  WeakAuras.Add(shout)
  assert(TimeMachine.index == 2, "a later edit is its own step")

  TimeMachine:StepBackward()
  assert(shout.width == 64 and auraSpell(shout) == "2048", "undo of the size")
  TimeMachine:StepBackward()
  assert(auraSpell(shout) == "6673", "undo of the trigger")
  assert(shout.id == "Shout" and shout.parent == "Pack", "undo keeps the id and the group")
  TimeMachine:StepForward()
  TimeMachine:StepForward()
  assert(auraSpell(shout) == "2048" and shout.width == 40, "redo")

  -- A multi-selection edit, and a slider drag on the same aura, make one step.
  test.Environment.Advance(2)
  shout.height, shield.height = 30, 30
  WeakAuras.Add(shout)
  WeakAuras.Add(shield)
  shout.height = 20
  WeakAuras.Add(shout)
  assert(TimeMachine.index == 3 and #TimeMachine.changes == 3, "close edits not merged")
  TimeMachine:StepBackward()
  assert(shout.height == 64 and shield.height == 64, "one undo for the whole multi-selection")
  TimeMachine:StepForward()
  assert(shout.height == 20 and shield.height == 30, "redo of the merged step")

  -- A time machine edit refreshes the copy: the next add of the same aura is not recorded again.
  test.Environment.Advance(2)
  TimeMachine:Append({ uid = "Shout", actionType = "set", path = { "desc" }, payload = "raid" })
  assert(TimeMachine.index == 4, "time machine edit")
  WeakAuras.Add(shout)
  assert(TimeMachine.index == 4 and #TimeMachine.changes == 4, "time machine edit recorded twice")

  -- A new edit after an undo drops the redo branch.
  TimeMachine:StepBackward()
  test.Environment.Advance(2)
  shield.width = 10
  WeakAuras.Add(shield)
  assert(TimeMachine.index == 4 and #TimeMachine.changes == 4 and TimeMachine:DescribeNext() == nil, "redo branch kept")

  -- The history keeps the last 50 steps.
  for size = 1, 60 do
    test.Environment.Advance(2)
    shield.width = size
    WeakAuras.Add(shield)
  end
  assert(#TimeMachine.changes == 50 and TimeMachine.index == 50, "history not bounded: " .. #TimeMachine.changes)

  -- An edit of an aura that is not watched cannot be undone and clears the history, with the rest of its frame.
  shout.width = 7
  WeakAuras.Add(WeakAuras.GetData("Alone"))
  WeakAuras.Add(shout)
  assert(#TimeMachine.changes == 0 and TimeMachine.index == 0, "unwatched edit kept the history")
  local function Edited(size)
    test.Environment.Advance(2)
    shout.width = size
    WeakAuras.Add(shout)
    assert(TimeMachine.index == 1, "recording did not resume")
    test.Environment.Advance(2)
  end

  -- An import, a move, a rename and a conversion clear the history.
  Edited(8)
  private.SetImporting(true)
  shout.width = 9
  WeakAuras.Add(shout)
  private.SetImporting(false)
  assert(#TimeMachine.changes == 0, "import recorded")
  Edited(10)
  local pack = WeakAuras.GetData("Pack")
  pack.controlledChildren = { "Shout" }
  shield.parent = nil
  WeakAuras.Add(pack)
  WeakAuras.Add(shield)
  assert(#TimeMachine.changes == 0, "move recorded")
  Edited(11)
  WeakAuras.Rename(shout, "Shout2")
  assert(#TimeMachine.changes == 0 and shout.id == "Shout2", "rename recorded")
  Edited(12)
  private.Pause()
  private.Convert(shout, "aurabar")
  assert(#TimeMachine.changes == 0 and shout.regionType == "aurabar", "conversion recorded")

  TimeMachine:ForgetWatched()
  WeakAuras.Add(shout)
  assert(#TimeMachine.changes == 0, "watched after the options closed")
end

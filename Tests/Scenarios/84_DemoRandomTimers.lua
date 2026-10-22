-- /wa demo: sample timers get random durations, and an expired one hides a few seconds before it starts again.
-- Without the demo, an expired sample timer starts again at once with the same duration.
return function(test)
  local saved = {
    displays = {
      Shout = {
        id = "Shout", uid = "Shout", regionType = "icon", internalVersion = 91,
        triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
          useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
          activeTriggerMode = -10 },
        load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
        animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
        subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
      },
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  WeakAuras.IsOptionsOpen = function() return true end
  WeakAuras.GetMoverSizerId = function() end
  WeakAuras.ClearAndUpdateOptions = function() end

  local function sample()
    return WeakAuras.GetTriggerStateForTrigger("Shout", 1)[""]
  end

  -- Options without the demo: the sample buff of 65 s starts again with the same duration.
  private.SetFakeStates()
  private.FakeStatesFor("Shout", true)
  local state = assert(sample(), "no sample state")
  assert(state.duration == 65, "sample duration: " .. tostring(state.duration))
  test.Environment.Advance(62)
  assert(sample() == state and state.duration == 65 and state.expirationTime > GetTime(), "sample timer not looped")
  private.ClearFakeStates()
  assert(sample() == nil, "sample state left after the options closed")

  -- Second opening, with the demo: random durations, a pause hidden, then a new timer.
  private.SetFakeStates()
  private.FakeStatesFor("Shout", true)
  private.StartDemoTimers()
  test.Environment.Advance(1.5)
  state = assert(sample(), "no sample state in the demo")
  assert(state.duration >= 4 and state.duration <= 20, "demo duration: " .. tostring(state.duration))
  assert(state.expirationTime > GetTime() and state.expirationTime <= GetTime() + state.duration, "demo timer not spread")
  assert(state.stacks >= 1 and state.stacks <= 5, "demo stacks: " .. tostring(state.stacks))

  local hidden = false
  for _ = 1, 22 do
    test.Environment.Advance(1)
    if sample() == nil then
      hidden = true
      break
    end
  end
  assert(hidden, "expired demo timer not hidden")

  local back = false
  for _ = 1, 8 do
    test.Environment.Advance(1)
    if sample() then
      back = true
      break
    end
  end
  assert(back, "hidden demo timer never started again")
  assert(sample().expirationTime > GetTime() and sample().show == true, "demo timer back without a running timer")

  -- Sample states made again during the demo (eye toggled, aura edited) get a demo timer too.
  private.FakeStatesFor("Shout", false)
  private.FakeStatesFor("Shout", true)
  assert(sample().duration >= 4 and sample().duration <= 20, "new sample state kept its default timer")

  -- A clone hidden by the demo does not come back once an edit removed the clones.
  local data = WeakAuras.GetData("Shout")
  data.triggers[1].trigger.showClones = true
  WeakAuras.Add(data)
  private.FakeStatesFor("Shout", false)
  private.FakeStatesFor("Shout", true)
  local clones = WeakAuras.GetTriggerStateForTrigger("Shout", 1)
  assert(clones[1], "no sample clone")
  local clone = clones[1]
  for _ = 1, 22 do
    test.Environment.Advance(1)
    if clones[1] ~= clone then break end
  end
  assert(clones[1] == nil, "clone not hidden by the demo")
  data.triggers[1].trigger.showClones = false
  WeakAuras.Add(data)
  clones = WeakAuras.GetTriggerStateForTrigger("Shout", 1)
  assert(clones[1] == nil, "clone made without showClones")
  test.Environment.Advance(8)
  clones = WeakAuras.GetTriggerStateForTrigger("Shout", 1)
  assert(clones[1] == nil, "hidden clone came back after the edit")

  -- Closing the options ends the demo: nothing comes back.
  private.ClearFakeStates()
  test.Environment.Advance(30)
  assert(sample() == nil, "demo state came back after the options closed")
end

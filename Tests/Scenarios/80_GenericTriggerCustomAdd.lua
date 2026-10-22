local function Icon(id, trigger, untrigger)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = trigger, untrigger = untrigger or {} }, activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

-- Custom branch of GenericTrigger.Add, seen through its observable result: the states a custom trigger shows after
-- its events, the custom untrigger, duration / name / icon / stacks functions, the event lists and the warnings.
return function(test)
  local saved = {
    displays = {
      -- custom event trigger, hidden by a custom untrigger
      EventCustom = Icon("EventCustom", {
        type = "custom", custom_type = "event", events = "MUSCA_TEST_EVENT", custom_hide = "custom",
        custom = "function(event, shown) return shown == true end",
        customDuration = "function() return 10, 1000 end", customName = "function() return 'Named' end",
        customIcon = "function() return 134400 end", customStacks = "function() return 3 end",
      }, { custom = "function(event, shown) return shown == false end" }),
      -- status trigger checked on events, with a custom untrigger
      StatusEvents = Icon("StatusEvents", {
        type = "custom", custom_type = "status", check = "event", events = "MUSCA_STATUS_EVENT",
        custom = "function() return _G.MuscaStatusShown == true end",
      }, { custom = "function() return _G.MuscaStatusShown ~= true end" }),
      -- status trigger checked on every frame
      StatusUpdate = Icon("StatusUpdate", {
        type = "custom", custom_type = "status", check = "update",
        custom = "function() return _G.MuscaUpdateShown == true end",
      }),
      -- unit events, a pets variant, an internal event and a trigger request
      UnitEvents = Icon("UnitEvents", {
        type = "custom", custom_type = "status", check = "event",
        events = "UNIT_HEALTH:player UNIT_POWER_UPDATE:target:pets PLAYER_ENTERING_WORLD TRIGGER:2",
        custom = "function() return true end",
      }),
      -- code that does not compile
      Broken = Icon("Broken", {
        type = "custom", custom_type = "event", events = "MUSCA_BROKEN_EVENT",
        custom = "function(", customName = "function(",
      }),
      -- unfiltered combat log
      CombatLog = Icon("CombatLog", {
        type = "custom", custom_type = "status", check = "event", events = "CLEU",
        custom = "function() return true end",
      }),
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)

  local function State(id)
    return WeakAuras.GetTriggerStateForTrigger(id, 1)[""]
  end
  -- Scans are queued until the next frame.
  local function Scan(...)
    WeakAuras.ScanEvents(...)
    test.Environment.Advance(1)
  end
  local function Warnings(id)
    return private.AuraWarnings.GetAllWarnings(id)
  end

  -- Event trigger with custom functions: shown by its event, hidden by the custom untrigger.
  assert(State("EventCustom") == nil, "event aura shown before its event")
  Scan("MUSCA_TEST_EVENT", true)
  local state = State("EventCustom")
  assert(state, "custom event trigger did not show")
  assert(state.name == "Named", "custom name: " .. tostring(state.name))
  assert(state.icon == 134400, "custom icon: " .. tostring(state.icon))
  assert(state.stacks == 3, "custom stacks: " .. tostring(state.stacks))
  assert(state.duration == 10 and state.expirationTime == 1000, "custom duration")
  Scan("MUSCA_TEST_EVENT", false)
  assert(State("EventCustom") == nil, "custom untrigger did not hide")

  -- Status trigger on events: the untrigger function hides it.
  _G.MuscaStatusShown = true
  Scan("MUSCA_STATUS_EVENT")
  assert(State("StatusEvents"), "status on events did not show")
  _G.MuscaStatusShown = false
  Scan("MUSCA_STATUS_EVENT")
  assert(State("StatusEvents") == nil, "status untrigger did not hide")
  assert(not (Warnings("StatusEvents") or {}).warning, "status on events must not warn")

  -- Status trigger on every frame: listens to the frame update and warns about the cost.
  _G.MuscaUpdateShown = true
  test.Environment.Advance(1)
  assert(State("StatusUpdate"), "status on update did not show")
  _G.MuscaUpdateShown = false
  test.Environment.Advance(1)
  assert(State("StatusUpdate") == nil, "status on update did not hide")
  local warning = (Warnings("StatusUpdate") or {}).warning
  assert(warning and warning.message:find("each frame", 1, true), "every frame warning missing")

  -- Unit events, internal events and trigger requests load without error and do not break the aura.
  assert(WeakAuras.GetData("UnitEvents"), "unit events aura not added")
  assert(not (Warnings("UnitEvents") or {}).warning, "unit events must not warn")

  -- Code that does not compile: no state, no error, the aura stays added.
  assert(WeakAuras.GetData("Broken"), "broken aura not added")
  Scan("MUSCA_BROKEN_EVENT", true)
  assert(State("Broken") == nil, "broken custom code showed")

  -- Unfiltered combat log: the spammy event error.
  local cleuWarning = (Warnings("CombatLog") or {}).error
  assert(cleuWarning, "unfiltered CLEU error missing")
  assert(not (Warnings("EventCustom") or {}).error, "unrelated aura got the CLEU error")

  -- Adding again replaces the previous entries and clears the warnings that no longer apply.
  local data = WeakAuras.GetData("StatusUpdate")
  data.triggers[1].trigger.onUpdateThrottle = 0.5
  WeakAuras.Add(data)
  assert(not (Warnings("StatusUpdate") or {}).warning, "throttled aura still warns")
  data = WeakAuras.GetData("CombatLog")
  data.triggers[1].trigger.events = "COMBAT_LOG_EVENT_UNFILTERED:SPELL_DAMAGE"
  WeakAuras.Add(data)
  assert(not (Warnings("CombatLog") or {}).error, "filtered CLEU still errors")
end

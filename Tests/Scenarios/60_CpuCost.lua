local function Icon(id, trigger)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Custom(customType, check, events, throttle)
  return { type = "custom", custom_type = customType, check = check, events = events, onUpdateThrottle = throttle,
    custom = "function() return true end", customDuration = "", customName = "", customIcon = "", customTexture = "",
    customStacks = "" }
end

-- Custom code run on each frame without a throttle gets a warning.
-- A profiling gives the cost of each aura once it stops.
return function(test)
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", {}, function(addonPrivate)
    private = addonPrivate
  end)
  test.Environment.Advance(1)

  local function Warned(trigger)
    WeakAuras.Add(Icon("Custom", trigger))
    local warnings = private.AuraWarnings.GetAllWarnings("Custom")
    return warnings and warnings.warning and warnings.warning.message:find("each frame", 1, true) and true or false
  end
  assert(Warned(Custom("status", "update")), "status on update")
  assert(Warned(Custom("stateupdate", "update", nil, 0)), "stateupdate with a throttle of 0")
  assert(Warned(Custom("status", "event", "UNIT_AURA FRAME_UPDATE")), "FRAME_UPDATE event")
  assert(not Warned(Custom("status", "update", nil, 0.1)), "throttled")
  assert(not Warned(Custom("event", "update")), "event trigger")
  assert(not Warned(Custom("status", "event", "UNIT_AURA")), "status on events")
  assert(Warned(Custom("event", nil, "FRAME_UPDATE")), "event trigger on FRAME_UPDATE")

  local function TextWarned(throttle, text)
    local data = Icon("Text", { type = "unit", event = "Health", unit = "player" })
    data.customText, data.customTextUpdate, data.customTextUpdateThrottle = "function() return 1 end", "update", throttle
    data.subRegions = { { type = "subtext", text_text = text } }
    WeakAuras.Add(data)
    local warnings = private.AuraWarnings.GetAllWarnings("Text")
    return warnings and warnings.warning and warnings.warning.message:find("custom text", 1, true) and true or false
  end
  assert(TextWarned(0, "%c"), "custom text on each frame")
  assert(not TextWarned(0.2, "%c"), "throttled custom text")
  assert(not TextWarned(0, "%p"), "text without %c")
  local data = Icon("Text", { type = "unit", event = "Health", unit = "player" })
  data.customText, data.customTextUpdate = "function() return 1 end", "update"
  data.subRegions = { { type = "subtext", text_text = "%p" } }
  data.conditions = { { check = {}, changes = { { property = "sub.1.text_text", value = "%c" } } } }
  WeakAuras.Add(data)
  local warnings = private.AuraWarnings.GetAllWarnings("Text")
  assert(warnings and warnings.warning and warnings.warning.message:find("custom text", 1, true), "%c set by a condition")

  local profilingFrame = { UnregisterAllEvents = function() end, UpdateButtons = function() end,
    RegisterEvent = function() end }
  profilingFrame.SetScript = function(_, script, handler) profilingFrame[script] = handler end
  _G.WeakAurasProfilingFrame = profilingFrame
  local updates = 0
  private.callbacks:RegisterCallback("ProfileCostsUpdated", function() updates = updates + 1 end)

  assert(private.GetProfileCost("Custom") == nil, "cost before any profiling")
  local clock = 0
  local realProfile = _G.debugprofilestop
  _G.debugprofilestop = function() return clock end
  WeakAuras.StartProfile()
  assert(updates == 1, "start does not refresh the badges")
  private.StartProfileAura("Custom")
  clock = clock + 5
  private.StopProfileAura("Custom")
  assert(private.GetProfileCost("Custom") == nil, "cost while profiling")
  clock = 2000
  WeakAuras.StopProfile()
  assert(updates == 2, "stop does not refresh the badges")
  local cost, spike = private.GetProfileCost("Custom")
  assert(cost == 2.5 and spike == 5, ("cost %s, spike %s"):format(tostring(cost), tostring(spike)))
  assert(private.GetProfileCost("Other") == nil, "cost of an aura that did not run")
  WeakAuras.StartProfile()
  assert(private.GetProfileCost("Custom") == nil, "cost kept after a new start")
  WeakAuras.StopProfile()
  -- "/wa pstart combat" before the window was ever opened: the combat events start and stop the profiling
  WeakAuras.StartProfile("combat")
  local before = updates
  assert(profilingFrame.OnEvent, "no event handler before the window is opened")
  profilingFrame.OnEvent(profilingFrame, "PLAYER_REGEN_DISABLED")
  assert(updates == before + 1, "combat start does not start the profiling")
  profilingFrame.OnEvent(profilingFrame, "PLAYER_REGEN_ENABLED")
  assert(updates == before + 2, "combat end does not stop the profiling")
  _G.debugprofilestop = realProfile
end

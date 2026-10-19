local function Aura(id, trigger)
  return {
    id = id, uid = id .. "Uid", regionType = "icon", internalVersion = 91,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Watch(id, watchedUid, inverse)
  return Aura(id, { type = "event", event = "Aura Shown", auraUid = watchedUid, use_inverse = inverse })
end

-- Trigger "Aura Shown": the watcher follows the watched aura one frame later, the inverse follows its absence, and
-- auras that watch each other in a loop never show.
return function(test)
  local saved = { displays = {
    Shout = Aura("Shout", { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }),
    Follower = Watch("Follower", "ShoutUid"),
    Absent = Watch("Absent", "ShoutUid", true),
    Second = Watch("Second", "FollowerUid"),
    LoopA = Watch("LoopA", "LoopBUid"),
    LoopB = Watch("LoopB", "LoopAUid", true),
    LoopC = Watch("LoopC", "ShoutUid"),
    LoopD = Watch("LoopD", "LoopCUid", true),
    Hub = Aura("Hub", { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }),
    HubBack = Watch("HubBack", "HubUid", true),
    Outsider = Watch("Outsider", "HubUid"),
    Blind = Watch("Blind", "", true),
    Broken = Watch("Broken", { "ShoutUid" }, true),
  } }
  -- LoopC closes its loop through its second trigger only.
  tinsert(saved.displays.LoopC.triggers, { trigger = { type = "event", event = "Aura Shown", auraUid = "LoopDUid" },
    untrigger = {} })
  -- Hub shows on its own first trigger and is in a loop with HubBack through its second one; Outsider is in no loop.
  saved.displays.Hub.triggers.disjunctive = "any"
  tinsert(saved.displays.Hub.triggers, { trigger = { type = "event", event = "Aura Shown", auraUid = "HubBackUid" },
    untrigger = {} })
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Shown(id)
    local region = WeakAuras.GetRegion(id)
    return region ~= nil and region:IsShown()
  end

  assert(not Shown("Shout") and not Shown("Follower") and Shown("Absent"), "watched aura hidden at login")
  assert(not Shown("Blind"), "an inverse watcher without a chosen aura never shows")
  assert(WeakAuras.GetData("Broken") and not Shown("Broken"), "a broken reference loads and watches nothing")

  local shout = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  assert(Shown("Shout") and Shown("Follower") and not Shown("Absent"), "watcher follows the watched aura")
  assert(Shown("Second"), "a chain of watchers follows")
  assert(not Shown("LoopD"), "a loop through a second trigger never shows")
  assert(Shown("Hub") and not Shown("HubBack") and Shown("Outsider"), "a watcher out of the loop still follows")

  private.Pause()
  test.Environment.Advance(0.5)
  assert(WeakAuras.IsPaused() and not private.IsAuraActive("AbsentUid"), "pause does not wake the inverse watcher")
  private.Resume()
  test.Environment.Advance(0.5)

  test.Units.RemoveAura("player", shout)
  test.Environment.Advance(0.5)
  assert(not Shown("Follower") and not Shown("Second") and Shown("Absent"), "watcher hides with the watched aura")

  assert(not Shown("LoopA") and not Shown("LoopB") and not Shown("LoopD"), "a loop never shows")

  -- A new uid for the watched aura, from a copy or a uid change in /wa, follows into the watcher.
  local follower = WeakAuras.GetData("Follower")
  assert(private.RemapWatchedAuras(follower, { ShoutUid = "CopyUid" }), "reference remapped")
  assert(follower.triggers[1].trigger.auraUid == "CopyUid", "watcher points to the new uid")
  assert(not private.RemapWatchedAuras(follower, { ShoutUid = "Other" }), "other references left alone")
end

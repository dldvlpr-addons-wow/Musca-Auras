local function StackAura(id, main, start, finish)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, actions = { start = {}, finish = {}, init = {} },
    conditions = { {
      check = { trigger = 1, variable = "stacks", op = ">=", value = "3" },
      changes = { { property = "conditionAnimation", value = "pulse" } },
    } },
    animation = { start = start or { type = "none" }, main = main, finish = finish or { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local saved = { displays = {
    Plain = StackAura("Plain", { type = "none" }),
    Spinning = StackAura("Spinning", { type = "preset", preset = "spin" }),
    Fading = StackAura("Fading", { type = "none" }, { type = "preset", preset = "fade" }),
    Closing = StackAura("Closing", { type = "none" }, nil, { type = "preset", preset = "fade" }),
  } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local lastMain = {}
  local animate = private.Animate
  private.Animate = function(namespace, uid, animationType, anim, region, ...)
    if animationType == "main" then
      lastMain[uid] = anim and (anim.preset or anim.type) or "nil"
    end
    return animate(namespace, uid, animationType, anim, region, ...)
  end

  local properties = private.GetProperties(saved.displays.Plain)
  assert(properties.conditionAnimation, "conditionAnimation property missing")
  assert(properties.conditionAnimation.values.pulse and properties.conditionAnimation.values.none,
    "conditionAnimation values incomplete")

  local buff = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, applications = 1, duration = 120 })
  test.Environment.Advance(0.5)
  local plain, spinning = WeakAuras.GetRegion("Plain"), WeakAuras.GetRegion("Spinning")
  assert(plain:IsShown() and spinning:IsShown(), "auras hidden with buff")
  assert(plain.conditionAnimation == nil, "Plain animated below 3 stacks")
  assert(lastMain.Spinning == "spin", "Spinning main animation not started: " .. tostring(lastMain.Spinning))

  test.Units.UpdateAura("player", buff, { applications = 3 })
  test.Environment.Advance(0.5)
  assert(plain.conditionAnimation and plain.conditionAnimation.preset == "pulse", "Plain not pulsing at 3 stacks")
  assert(lastMain.Plain == "pulse", "Plain pulse not started: " .. tostring(lastMain.Plain))
  assert(lastMain.Spinning == "pulse", "Spinning pulse not started: " .. tostring(lastMain.Spinning))
  WeakAuras.Add(saved.displays.Spinning, true)
  assert(lastMain.Spinning == "pulse", "Spinning pulse lost after a simple change: " .. tostring(lastMain.Spinning))
  lastMain.Plain = nil
  WeakAuras.GetRegion("Plain"):SetConditionAnimation("wobble")
  assert(lastMain.Plain == "none", "Plain wobble without rotation support: " .. tostring(lastMain.Plain))
  WeakAuras.GetRegion("Plain"):SetConditionAnimation("pulse")

  test.Units.UpdateAura("player", buff, { applications = 1 })
  test.Environment.Advance(0.5)
  assert(plain.conditionAnimation == nil, "Plain still pulsing below 3 stacks")
  assert(lastMain.Plain == "none", "Plain pulse not stopped: " .. tostring(lastMain.Plain))
  assert(lastMain.Spinning == "spin", "Spinning main animation not restored: " .. tostring(lastMain.Spinning))

  test.Units.UpdateAura("player", buff, { applications = 4 })
  test.Environment.Advance(0.5)
  test.Units.RemoveAura("player", buff)
  test.Environment.Advance(0.5)
  assert(not plain:IsShown(), "Plain still shown after removal")
  assert(not WeakAuras.GetRegion("Closing"):IsShown(), "Closing still shown after its finish animation")
  lastMain.Plain, lastMain.Fading = nil, nil
  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, applications = 5, duration = 120 })
  test.Environment.Advance(0.1)
  assert(WeakAuras.GetRegion("Fading"):IsShown(), "Fading hidden after new buff")
  assert(lastMain.Fading == nil, "Fading start animation cut: " .. tostring(lastMain.Fading))
  test.Environment.Advance(0.4)
  assert(plain:IsShown(), "Plain hidden after new buff")
  assert(lastMain.Plain == "pulse", "Plain not pulsing when shown with 5 stacks: " .. tostring(lastMain.Plain))
  assert(lastMain.Fading == "pulse", "Fading not pulsing after its start animation: " .. tostring(lastMain.Fading))
end

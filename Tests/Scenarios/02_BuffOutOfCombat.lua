local function BuffAura(id, trigger)
  trigger.type, trigger.unit, trigger.debuffType = "aura2", "player", "HELPFUL"
  trigger.matchesShowOn = trigger.matchesShowOn or "showOnActive"
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local saved = { displays = {
    ByName = BuffAura("ByName", { useName = true, auranames = { "Battle Shout" } }),
    BySpellId = BuffAura("BySpellId", { useExactSpellId = true, auraspellids = { "6673" } }),
    Missing = BuffAura("Missing", { useName = true, auranames = { "Battle Shout" }, matchesShowOn = "showOnMissing" }),
  } }
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Shown(id)
    local region = WeakAuras.GetRegion(id)
    return region ~= nil and region:IsShown()
  end

  assert(not Shown("ByName"), "ByName shown without buff")
  assert(Shown("Missing"), "Missing hidden without buff")

  test.Units.ApplyAura("player", { name = "Weakened Soul", spellId = 6788, duration = 600, isHarmful = true })
  local buff = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  assert(Shown("ByName"), "ByName hidden with buff")
  assert(Shown("BySpellId"), "BySpellId hidden with buff")
  assert(not Shown("Missing"), "Missing shown with buff")

  test.Units.RemoveAura("player", buff)
  test.Environment.Advance(0.5)
  assert(not Shown("ByName"), "ByName still shown after removal")
  assert(Shown("Missing"), "Missing hidden after removal")

  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 2 })
  test.Environment.Advance(0.5)
  assert(Shown("ByName"), "ByName hidden with short buff")
  test.Environment.Advance(3)
  assert(not Shown("ByName"), "ByName still shown after expiry")
end

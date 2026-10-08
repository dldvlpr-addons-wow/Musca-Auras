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
  local function Report(step)
    io.stdout:write(string.format("  [%s] ByName=%s BySpellId=%s Missing=%s", step,
      tostring(Shown("ByName")), tostring(Shown("BySpellId")), tostring(Shown("Missing"))) .. "\n")
  end

  local before = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  Report("buff before combat")
  assert(Shown("ByName") and Shown("BySpellId") and not Shown("Missing"), "out of combat state wrong")

  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  Report("combat start, buff kept")
  assert(Shown("ByName"), "ByName lost when entering combat")
  assert(Shown("BySpellId"), "BySpellId lost when entering combat")
  assert(not Shown("Missing"), "Missing shown when entering combat")

  test.Units.RemoveAura("player", before)
  test.Environment.Advance(0.5)
  Report("buff removed in combat")
  assert(not Shown("ByName"), "ByName stays after removal in combat")
  assert(not Shown("BySpellId"), "BySpellId stays after removal in combat")
  assert(Shown("Missing"), "Missing hidden after removal in combat")

  local during = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  Report("buff applied in combat")
  -- unverified in game: every aura secret in combat, GetAuraDataByAuraInstanceID raises for it
  local ok, data = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, "player", during.auraInstanceID)
  io.stdout:write("  restricted=" .. tostring(test.Units.restricted) .. " read=" .. tostring(ok)
    .. " secretName=" .. tostring(ok and data and test.Secret.IsSecret(data.name)) .. "\n")

  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  Report("combat end")
  assert(Shown("ByName"), "ByName hidden after combat with buff")
  assert(Shown("BySpellId"), "BySpellId hidden after combat with buff")
  assert(not Shown("Missing"), "Missing shown after combat with buff")

  test.Units.RemoveAura("player", during)
  test.Environment.Advance(0.5)
  Report("buff removed after combat")
  assert(not Shown("ByName") and Shown("Missing"), "state after final removal wrong")
end

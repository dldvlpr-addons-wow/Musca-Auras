local function HealthTrigger(extra)
  local trigger = { type = "unit", event = "Health", unit = "player", use_unit = true,
    debuffType = "HELPFUL", names = {}, spellIds = {} }
  for key, value in pairs(extra) do
    trigger[key] = value
  end
  return { trigger = trigger, untrigger = {} }
end

local function Aura(id, regionType, trigger, extra)
  local data = {
    id = id, uid = id, regionType = regionType, internalVersion = 91,
    triggers = { trigger, activeTriggerMode = -10 },
    load = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  for key, value in pairs(extra or {}) do
    data[key] = value
  end
  return data
end

return function(test)
  local Secret, Units = test.Secret, test.Units
  local both = { use_showAbsorb = true, use_showHealAbsorb = true }
  local saved = { displays = {
    AbsorbText = Aura("AbsorbText", "text", HealthTrigger(both),
      { displayText = "%absorb / %healabsorb", conditions = {} }),
    AbsorbThreshold = Aura("AbsorbThreshold", "icon",
      HealthTrigger({ use_showAbsorb = true, use_absorb = true, absorb = { "100" }, absorb_operator = { ">" } }),
      { conditions = { { check = { trigger = 1, variable = "absorb", op = ">", value = "100" },
        changes = { { property = "alpha", value = 0.5 } } } } }),
    AbsorbOff = Aura("AbsorbOff", "text", HealthTrigger({}), { displayText = "%absorb", conditions = {} }),
    AbsorbNumber = Aura("AbsorbNumber", "text", HealthTrigger({ use_showAbsorb = true }),
      { displayText = "%absorb", conditions = {}, displayText_format_absorb_format = "Number",
        displayText_format_absorb_decimal_precision = 0 }),
    AbsorbBraces = Aura("AbsorbBraces", "text", HealthTrigger({ use_showAbsorb = true }),
      { displayText = "%{absorb} / %healabsorb", conditions = {}, displayText_format_absorb_format = "Number",
        displayText_format_absorb_decimal_precision = 0 }),
  } }

  Units.DefineUnit("player", { class = "PRIEST", powerType = 0, power = 1000, powerMax = 1000,
    health = 1000, healthMax = 1000 })
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)

  local prototype = private.event_prototypes["Health"]
  local function Registers(trigger, event)
    for _, registered in ipairs((prototype.events(trigger).unit_events or {}).player or {}) do
      if registered == event then return true end
    end
    return false
  end
  local offTrigger = HealthTrigger({}).trigger
  assert(not Registers(offTrigger, "UNIT_ABSORB_AMOUNT_CHANGED"), "absorb event registered while Show Absorb is off")
  assert(not Registers(offTrigger, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"),
    "heal absorb event registered while Show Heal Absorb is off")
  local bothTrigger = HealthTrigger(both).trigger
  assert(Registers(bothTrigger, "UNIT_ABSORB_AMOUNT_CHANGED"), "absorb event missing")
  assert(Registers(bothTrigger, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"), "heal absorb event missing")
  for _, arg in ipairs(prototype.args) do
    if arg.name == "absorb" or arg.name == "healabsorb" then
      assert(arg.conditionType == nil, arg.name .. " offers a condition on a secret amount")
    end
  end

  local function TextOf(id)
    local region = WeakAuras.GetRegion(id)
    assert(region and region:IsShown(), id .. " hidden")
    return region.text:GetText()
  end
  local function Expect(id, expected, label)
    local text = TextOf(id)
    assert(Secret.IsSecret(text), id .. " text not drawn from the secret amount " .. label)
    assert(Secret.Reveal(text) == expected,
      ("%s text %s, expected %s %s"):format(id, tostring(Secret.Reveal(text)), expected, label))
  end

  for _, inCombat in ipairs({ false, true }) do
    local label = inCombat and "in combat" or "out of combat"
    Units.SetCombat(inCombat)
    Units.Get("player").absorb = 0
    Units.Get("player").healAbsorb = 0
    test.Frames.Fire("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    test.Frames.Fire("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
    test.Environment.Advance(0.2)
    Expect("AbsorbText", "0 / 0", "without shield " .. label)

    Units.Get("player").absorb = 250
    test.Frames.Fire("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    test.Environment.Advance(0.2)
    Expect("AbsorbText", "250 / 0", "with a shield " .. label)
    Expect("AbsorbNumber", "250", "with a Number format " .. label)
    Expect("AbsorbBraces", "250 / ", "with braces and a Number format " .. label)

    Units.Get("player").healAbsorb = 40
    test.Frames.Fire("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
    test.Environment.Advance(0.2)
    Expect("AbsorbText", "250 / 40", "with a heal absorb " .. label)

    local threshold = WeakAuras.GetRegion("AbsorbThreshold")
    assert(threshold and threshold:IsShown(), "a threshold on the absorb hides the aura " .. label)
    assert(not Secret.IsSecret(threshold.alpha) and threshold.alpha == 1,
      "a condition on the absorb changed the alpha " .. label)

    local off = WeakAuras.GetRegion("AbsorbOff")
    assert(off and off:IsShown(), "AbsorbOff hidden " .. label)
    assert(not Secret.IsSecret(off.text:GetText()), "absorb read while Show Absorb is off " .. label)
  end
  Units.SetCombat(false)
end

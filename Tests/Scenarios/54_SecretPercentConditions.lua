local function PowerTrigger()
  return { trigger = { type = "unit", event = "Power", unit = "player", use_unit = true,
    use_powertype = true, powertype = 0, debuffType = "HELPFUL", names = {}, spellIds = {} }, untrigger = {} }
end

local function HealthTrigger()
  return { trigger = { type = "unit", event = "Health", unit = "player", use_unit = true,
    debuffType = "HELPFUL", names = {}, spellIds = {} }, untrigger = {} }
end

local function Aura(id, regionType, trigger, conditions)
  local data = {
    id = id, uid = id, regionType = regionType, internalVersion = 91,
    triggers = { trigger, activeTriggerMode = -10 }, conditions = conditions,
    load = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  if regionType == "text" then
    data.displayText = "toto"
  end
  return data
end

local function Alpha(variable, op, value, alpha)
  return { check = { trigger = 1, variable = variable, op = op, value = value },
    changes = { { property = "alpha", value = alpha } } }
end

return function(test)
  local Secret, Units = test.Secret, test.Units
  local file = assert(io.open((test.tocPath:gsub("WeakAuras/WeakAuras%.toc$",
    "Tests/Packs/Demoniste/PackDemonisteForeverAuras.txt"))))
  local exported = file:read("*a"):gsub("%s", "")
  file:close()

  local saved = { displays = {
    ManaText = Aura("ManaText", "text", PowerTrigger(), { Alpha("percentpower", ">=", "20", 0) }),
    ManaIcon = Aura("ManaIcon", "icon", PowerTrigger(), { Alpha("percentpower", ">=", "20", 0) }),
    ManaValue = Aura("ManaValue", "icon", PowerTrigger(), { Alpha("power", ">", "500", 0.5) }),
    ManaDeficit = Aura("ManaDeficit", "icon", PowerTrigger(), { Alpha("deficit", "<=", "200", 0.25) }),
    ManaAnd = Aura("ManaAnd", "icon", PowerTrigger(), { {
      check = { variable = "AND", checks = {
        { trigger = 1, variable = "show", value = 1 },
        { trigger = 1, variable = "percentpower", op = "<", value = "20" },
      } },
      changes = { { property = "alpha", value = 0.5 } },
    } }),
    ManaAndReversed = Aura("ManaAndReversed", "icon", PowerTrigger(), { {
      check = { variable = "AND", checks = {
        { trigger = 1, variable = "percentpower", op = "<", value = "20" },
        { trigger = 1, variable = "show", value = 1 },
      } },
      changes = { { property = "alpha", value = 0.5 } },
    } }),
    HealthIcon = Aura("HealthIcon", "icon", HealthTrigger(), { {
      check = { trigger = 1, variable = "percenthealth", op = "<", value = "50" },
      changes = { { property = "color", value = { 1, 0, 0, 1 } } },
    } }),
  } }

  Units.DefineUnit("player", { class = "WARLOCK", powerType = 0, power = 1000, powerMax = 1000,
    health = 1000, healthMax = 1000 })
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(private)
    local received = private.StringToTable(exported, true)
    assert(type(received) == "table" and received.m == "d", "pack not decoded: " .. tostring(received))
    private.ConvertForeverAurasImport(received.d, received.c)
    saved.displays[received.d.id] = received.d
    for _, child in ipairs(received.c) do
      saved.displays[child.id] = child
    end
    private.SyncParentChildRelationships()
    private.ValidateUniqueDataIds(true)
  end)
  local env = private.ExecEnv
  test.Environment.Advance(2)

  local function SetPower(power)
    Units.Get("player").power = power
    test.Frames.Fire("UNIT_POWER_FREQUENT", "player", "MANA")
    test.Environment.Advance(0.2)
  end
  local function SetHealth(health)
    Units.Get("player").health = health
    test.Frames.Fire("UNIT_HEALTH", "player")
    test.Environment.Advance(0.2)
  end
  local function AlphaOf(id)
    local region = WeakAuras.GetRegion(id)
    assert(region and region:IsShown(), id .. " hidden")
    return Secret.Reveal(region.alpha), Secret.IsSecret(region.alpha)
  end
  local function Expect(id, alpha, label)
    local value, secret = AlphaOf(id)
    assert(secret, id .. " alpha not secret " .. label)
    assert(math.abs(value - alpha) < 1e-6, ("%s alpha %s, expected %s %s"):format(id, tostring(value), alpha, label))
  end

  local readable = { percentpower = 50, total = 100, unit = "player", powertype = 0 }
  assert(env.SecretPercentSelect(readable, "power", "percent", ">=", 20, true, 0, 1) == 0,
    "readable active")
  assert(env.SecretPercentSelect(readable, "power", "percent", ">=", 20, false, 0, 1) == 1,
    "readable inactive")
  local secretState = { secretValue = Secret.Wrap(50), secretTotal = 100, unit = "player", powertype = 0 }
  assert(env.SecretPercentSelect(secretState, "power", "percent", ">=", 0, false, 0, 1) == 0,
    ">= 0 always true")
  assert(env.SecretPercentSelect(secretState, "power", "percent", "<", 0, true, 0, 1) == 1,
    "< 0 always false")
  local secretZero = Secret.Wrap(0)
  assert(rawequal(env.SecretPercentSelect(secretState, "power", "percent", ">=", 20, true,
    secretZero, 1), secretZero), "secret outputs fall back to the ordinary test")
  local noTotal = { secretValue = Secret.Wrap(5), secretTotal = Secret.Wrap(10), unit = "player", powertype = 0 }
  assert(env.SecretPercentSelect(noTotal, "power", "value", ">", 2, false, 0, 1) == 1,
    "secret total falls back to the ordinary test")

  for _, inCombat in ipairs({ false, true }) do
    local label = inCombat and "in combat" or "out of combat"
    Units.SetCombat(inCombat)
    SetPower(1000)
    SetHealth(1000)
    Expect("ManaText", 0, "full mana " .. label)
    Expect("ManaIcon", 0, "full mana " .. label)
    Expect("ManaValue", 0.5, "full mana " .. label)
    Expect("ManaDeficit", 0.25, "full mana " .. label)
    Expect("ManaAnd", 1, "full mana " .. label)
    Expect("ManaAndReversed", 1, "full mana " .. label)
    Expect("Warlock - LOW MANA", 0, "full mana " .. label)

    SetPower(200)
    Expect("ManaText", 0, "20% mana " .. label)
    Expect("ManaValue", 1, "20% mana " .. label)
    Expect("ManaAnd", 1, "20% mana " .. label)
    Expect("ManaAndReversed", 1, "20% mana " .. label)

    SetPower(100)
    Expect("ManaText", 1, "10% mana " .. label)
    Expect("ManaIcon", 1, "10% mana " .. label)
    Expect("ManaDeficit", 1, "10% mana " .. label)
    Expect("ManaAnd", 0.5, "10% mana " .. label)
    Expect("ManaAndReversed", 0.5, "10% mana " .. label)
    Expect("Warlock - LOW MANA", 1, "10% mana " .. label)

    SetPower(800)
    Expect("ManaDeficit", 0.25, "80% mana " .. label)
    SetPower(799)
    Expect("ManaDeficit", 1, "79.9% mana " .. label)

    local colors = {}
    local icon = WeakAuras.GetRegion("HealthIcon")
    local color = icon.Color
    icon.Color = function(self, r, g, b, a)
      colors[#colors + 1] = { r, g, b, a }
      return color(self, r, g, b, a)
    end
    SetHealth(400)
    local last = colors[#colors]
    assert(last and Secret.IsSecret(last[2]), "health color not secret " .. label)
    assert(Secret.Reveal(last[1]) == 1 and Secret.Reveal(last[2]) == 0, "health color not red at 40% " .. label)
    SetHealth(900)
    last = colors[#colors]
    assert(Secret.Reveal(last[2]) == 1, "health color not white at 90% " .. label)
    icon.Color = color
  end
  Units.SetCombat(false)
end

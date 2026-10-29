-- Secret threat values: the Threat Situation trigger takes them without raising (the state keeps the last readable
-- values, the secret value stays in secretValue), and a Number format at precision 0 rounds a secret custom text
-- number with string.format instead of floor, ceil or Round.
local function Aura(id, unit, extra)
  local data = {
    id = id, uid = id, regionType = "text", internalVersion = 91,
    triggers = { { trigger = { type = "unit", event = "Threat Situation", unit = unit, use_unit = true },
      untrigger = {} }, activeTriggerMode = -10 },
    load = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
    conditions = {},
  }
  for key, value in pairs(extra) do
    data[key] = value
  end
  return data
end

return function(test)
  local Secret, Units = test.Secret, test.Units
  local secretThreat = false
  local function Value(value)
    return secretThreat and Secret.Wrap(value) or value
  end
  _G.UnitDetailedThreatSituation = function()
    return Value(true), Value(3), Value(80.6), Value(96.7), Value(12000)
  end
  _G.ScenarioThreatNumber = function() return Value(80.6) end
  -- Blizzard's Round: the harness stub returns 0
  _G.Round = function(value) return math.floor(value + 0.5) end

  local saved = { displays = {} }
  for _, round in ipairs({ "floor", "ceil", "round" }) do
    local id = "Threat_" .. round
    saved.displays[id] = Aura(id, "target", { displayText = "%threatpct", displayText_format_threatpct_format = "Number",
      displayText_format_threatpct_decimal_precision = 0, displayText_format_threatpct_round_type = round })
    id = "Custom_" .. round
    saved.displays[id] = Aura(id, "target", { displayText = "%c", customText = "function() return ScenarioThreatNumber() end",
      customTextUpdate = "event", displayText_format_c_format = "Number", displayText_format_c_decimal_precision = 0,
      displayText_format_c_round_type = round })
  end

  Units.DefineUnit("player", { class = "WARRIOR" })
  Units.DefineUnit("target", { canAttack = true, isPlayerControlled = false })
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  assert(private.event_prototypes["Threat Situation"], "Threat Situation prototype missing")

  local function Region(id)
    local region = WeakAuras.GetRegion(id)
    assert(region and region:IsShown(), id .. " hidden")
    return region
  end
  local expected = { floor = "80", ceil = "81", round = "81" }
  for _, secret in ipairs({ false, true }) do
    secretThreat = secret
    local label = secret and "with secret threat" or "with readable threat"
    test.Frames.Fire("UNIT_THREAT_LIST_UPDATE", "target")
    test.Environment.Advance(0.2)
    for round, want in pairs(expected) do
      local region = Region("Threat_" .. round)
      local text = region.text:GetText()
      assert(not Secret.IsSecret(text) and text == want, ("%s shows %s, expected %s %s"):format(round,
        tostring(Secret.Reveal(text)), want, label))
      assert(Secret.IsSecret(region.state.secretValue) == secret, round .. " secret value kept " .. label)
      -- 12000 threat at 80.6 %: the total is computed while readable, then kept while secret
      assert(math.abs(region.state.total - 12000 * 100 / 80.6) < 0.01, round .. " threat total " .. label)

      text = Region("Custom_" .. round).text:GetText()
      assert(Secret.IsSecret(text) == secret, round .. " custom text secrecy " .. label)
      -- string.format rounds a secret to the nearest integer, whatever the round mode
      want = secret and "81" or want
      assert(Secret.Reveal(text) == want, ("custom %s shows %s, expected %s %s"):format(round,
        tostring(Secret.Reveal(text)), want, label))
    end
  end
  assert(#Secret.violations == 0, "secret value violation: " .. tostring(Secret.violations[1]))
end

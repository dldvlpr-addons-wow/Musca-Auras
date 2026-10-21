-- Characterization of SecretAuraTrigger, SecretConditions, SecretSpellCooldown and PrototypeSecretHelpers
-- through their public exports only (Private.ExecEnv.*, Private.Create*, trigger system registry).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Units, Frames, Clock = test.Secret, test.Units, test.Frames, test.Clock
  local env = private.ExecEnv

  local restores = {}
  local function Override(target, key, value)
    restores[#restores + 1] = { target, key, target[key] }
    target[key] = value
  end
  local function NoError(label, step, ...)
    local results = { pcall(step, ...) }
    assert(results[1], label .. ": " .. tostring(results[2]))
    return results[2], results[3]
  end
  local function Timer(remaining, total, secret)
    local duration = Units.NewDuration()
    local start = GetTime() + remaining - total
    duration:SetTimeFromStart(secret and Secret.Wrap(start) or start, total)
    return duration
  end
  local function Describe(value)
    return Secret.IsSecret(value) and "<secret>" or tostring(value)
  end
  local function Same(actual, expected, label)
    assert(rawequal(actual, expected), label .. ": expected " .. Describe(expected) .. ", got " .. Describe(actual))
  end

  ---------------------------------------------------------------------------------------------
  -- PrototypeSecretHelpers
  ---------------------------------------------------------------------------------------------
  local secretFive, secretTen = Secret.Wrap(5), Secret.Wrap(10)
  Same(env.PercentOrSecret(50, 200), 25, "percent readable")
  Same(env.PercentOrSecret(5, 0), nil, "percent total 0")
  Same(env.PercentOrSecret(0, 0), nil, "percent 0/0")
  Same(env.PercentOrSecret(secretFive, 10), secretFive, "percent secret value returned as is")
  Same(env.PercentOrSecret(5, secretTen), secretTen, "percent secret total returned as is")
  Same(env.PercentOrSecret(secretFive, secretTen), secretFive, "percent value secret first")
  Same(env.PercentOrSecret(secretFive, 0), secretFive, "percent secret value with total 0")
  Same(env.DeficitOrSecret(30, 100), 70, "deficit readable")
  Same(env.DeficitOrSecret(100, 100), 0, "deficit full")
  Same(env.DeficitOrSecret(secretFive, 10), secretFive, "deficit secret value")
  Same(env.DeficitOrSecret(5, secretTen), secretTen, "deficit secret total")
  Same(env.DeficitOrSecret(secretFive, secretTen), secretFive, "deficit value first")

  local originalCurveConstants = rawget(_G, "CurveConstants")
  local originalHealthPercent = rawget(_G, "UnitHealthPercent")
  local originalPowerPercent = rawget(_G, "UnitPowerPercent")
  local healthCalls, powerCalls = {}, {}
  local healthResult, powerResult = 0.5, 0.25
  _G.CurveConstants = { ScaleTo100 = "scale100", ZeroToOne = "zeroOne" }
  _G.UnitHealthPercent = function(...) healthCalls[#healthCalls + 1] = { ... } return healthResult end
  _G.UnitPowerPercent = function(...) powerCalls[#powerCalls + 1] = { ... } return powerResult end

  Same(env.SecretPercent("health", "target", 5, 10), nil, "SecretPercent readable inputs")
  Same(env.SecretPercent("health", "target", secretFive, 10), 0.5, "SecretPercent health")
  assert(healthCalls[1][1] == "target" and healthCalls[1][2] == true and healthCalls[1][3] == "zeroOne", "health call args")
  Same(env.SecretPercent("health", "target", 5, secretTen, nil, true), 0.5, "SecretPercent scaled")
  Same(healthCalls[2][3], "scale100", "scale100 curve")
  Same(env.SecretPercent("power", "player", secretFive, 10, 3), 0.25, "SecretPercent power")
  assert(powerCalls[1][1] == "player" and powerCalls[1][2] == 3 and powerCalls[1][3] == false
    and powerCalls[1][4] == "zeroOne", "power call args")
  healthResult = "text"
  Same(env.SecretPercent("health", "target", secretFive, 10), nil, "SecretPercent non-number")
  _G.UnitHealthPercent = function() error("boom") end
  Same(env.SecretPercent("health", "target", secretFive, 10), nil, "SecretPercent error swallowed")
  _G.CurveConstants = { ZeroToOne = "zeroOne" }
  Same(env.SecretPercent("power", "player", secretFive, 10, 0, true), 0.25, "SecretPercent missing ScaleTo100")
  _G.CurveConstants = nil
  Same(env.SecretPercent("power", "player", secretFive, 10), nil, "SecretPercent without CurveConstants")

  -- ThresholdAlpha
  Same(env.ThresholdAlpha("health", "target", nil, 0, false), nil, "threshold 0")
  Same(env.ThresholdAlpha("health", "target", nil, nil, false), nil, "threshold nil")
  Same(env.ThresholdAlpha("health", "target", nil, -5, false), nil, "threshold negative")
  healthResult = 1
  _G.UnitHealthPercent = function(...) healthCalls[#healthCalls + 1] = { ... } return healthResult end
  healthCalls = {}
  Same(env.ThresholdAlpha("health", "target", nil, 30, false), 1, "threshold health result")
  assert(healthCalls[1][2] == true and healthCalls[1][3] ~= nil, "threshold health args")
  local belowCurve = healthCalls[1][3]
  assert(Secret.Reveal(belowCurve:Evaluate(0.1)) == 1 and belowCurve:Evaluate(0.5) == 0, "below curve")
  env.ThresholdAlpha("health", "target", nil, 30, false)
  Same(healthCalls[2][3], belowCurve, "below curve cached")
  env.ThresholdAlpha("health", "target", nil, 30, true)
  local aboveCurve = healthCalls[3][3]
  assert(aboveCurve ~= belowCurve, "above curve distinct from below curve")
  assert(aboveCurve:Evaluate(0.1) == 0 and aboveCurve:Evaluate(0.5) == 1, "above curve")
  env.ThresholdAlpha("health", "target", nil, 30, true)
  Same(healthCalls[4][3], aboveCurve, "above curve cached")
  powerResult = 0
  Same(env.ThresholdAlpha("power", "player", 3, 20, false), 0, "threshold power result")
  assert(powerCalls[#powerCalls][2] == 3 and powerCalls[#powerCalls][3] == false, "threshold power args")
  healthResult = nil
  Same(env.ThresholdAlpha("health", "target", nil, 30, false), nil, "threshold non-number")
  local originalCreateCurve = C_CurveUtil.CreateCurve
  C_CurveUtil.CreateCurve = nil
  Same(env.ThresholdAlpha("health", "target", nil, 77, false), nil, "threshold without CreateCurve")
  C_CurveUtil.CreateCurve = originalCreateCurve
  _G.CurveConstants, _G.UnitHealthPercent, _G.UnitPowerPercent =
    originalCurveConstants, originalHealthPercent, originalPowerPercent

  -- display count, importance, cast and totem durations
  Override(C_Spell, "GetSpellDisplayCount", nil)
  Same(env.GetSpellDisplayCount(1), nil, "display count API absent")
  C_Spell.GetSpellDisplayCount = function() return "3" end
  Same(env.GetSpellDisplayCount(1), "3", "display count")
  Same(env.GetSpellDisplayCount(nil), nil, "display count nil id")
  Same(env.GetSpellDisplayCount(false), nil, "display count false id")
  C_Spell.GetSpellDisplayCount = function() return 3 end
  Same(env.GetSpellDisplayCount(1), nil, "display count non-string")
  C_Spell.GetSpellDisplayCount = function() error("boom") end
  Same(env.GetSpellDisplayCount(1), nil, "display count error")

  Override(C_Spell, "IsSpellImportant", nil)
  Same(env.IsSpellImportant(1), nil, "important API absent")
  C_Spell.IsSpellImportant = function() return false end
  Same(env.IsSpellImportant(1), false, "important false kept")
  Same(env.IsSpellImportant(nil), nil, "important nil id")
  local secretImportant = Secret.Wrap(true)
  C_Spell.IsSpellImportant = function() return secretImportant end
  Same(env.IsSpellImportant(1), secretImportant, "important secret kept")
  C_Spell.IsSpellImportant = function() error("boom") end
  Same(env.IsSpellImportant(1), nil, "important error")

  local castDuration, channelDuration = Timer(2, 3), Timer(4, 5)
  Override(_G, "UnitCastingDuration", function() return castDuration end)
  Override(_G, "UnitChannelDuration", function() return channelDuration end)
  Same(env.GetCastDurationObject("target"), castDuration, "cast duration default")
  Same(env.GetCastDurationObject("target", "cast"), castDuration, "cast duration cast")
  Same(env.GetCastDurationObject("target", "channel"), channelDuration, "channel duration")
  _G.UnitCastingDuration = function() return 5 end
  Same(env.GetCastDurationObject("target"), nil, "cast duration not an object")
  _G.UnitCastingDuration = function() error("boom") end
  Same(env.GetCastDurationObject("target"), nil, "cast duration error")
  _G.UnitCastingDuration = nil
  Same(env.GetCastDurationObject("target"), nil, "cast duration API absent")

  local totemDuration = Timer(10, 20)
  Override(_G, "GetTotemDuration", function() return totemDuration end)
  Same(env.GetTotemDurationObject(1), totemDuration, "totem duration")
  _G.GetTotemDuration = function() return "x" end
  Same(env.GetTotemDurationObject(1), nil, "totem not an object")
  _G.GetTotemDuration = function() error("boom") end
  Same(env.GetTotemDurationObject(1), nil, "totem error")
  _G.GetTotemDuration = nil
  Same(env.GetTotemDurationObject(1), nil, "totem API absent")

  -- CastCombatStatus
  local L = WeakAuras.L
  local worksInCombat = L["|cff33ff99Fully usable in combat.|r"]
  local unfiltered = L["|cffff9933Other units' casts: shown in combat, never filtered.|r"]
  local blockedFormat = L["|cffff2020Ignored in combat:|r %s |cffff9933(other units' casts are unreadable)|r"]
  local function Blocked(...) return blockedFormat:format(table.concat({ ... }, ", ")) end
  local status = private.CastCombatStatus
  Same(status(nil), worksInCombat, "status nil trigger")
  Same(status("text"), worksInCombat, "status non-table trigger")
  Same(status({}), worksInCombat, "status default unit")
  Same(status({ unit = "player", use_interruptible = true }), worksInCombat, "status player ignores arguments")
  Same(status({ unit = "member", specificUnit = "Player" }), worksInCombat, "status member player")
  Same(status({ unit = "member", specificUnit = "party1", use_stage = true }), Blocked("Stage"), "status member other")
  Same(status({ unit = "target" }), unfiltered, "status target no argument")
  Same(status({ unit = "target", use_interruptible = false }), Blocked("Interruptible"), "status false counts")
  Same(status({ unit = "target", use_remaining = true, use_interruptible = true, use_spell = true }),
    Blocked("Spellname", "Interruptible", "Remaining Time"), "status labels in list order")
  Same(status({ unit = "target", use_spellId = true, use_empowered = true, use_stageTotal = true, use_charged = true }),
    Blocked("Spell ID", "Empowered", "Stage Total", "Charged"), "status other labels")
  Same(status({ unit = "target", use_spellNames = true }), Blocked("Name(s)"), "status names without list")
  Same(status({ unit = "target", use_spellIds = true, spellIds = {} }), Blocked("Exact Spell ID(s)"), "status empty list")
  Same(status({ unit = "target", use_spellIds = true, spellIds = { 1, 2 } }), Blocked("Exact Spell ID(s)"),
    "status ids unreadable without SecrecyLevel")
  Override(C_Secrets, "GetSpellCastSecrecy", function(id) return id == 2 and 2 or 0 end)
  Override(Enum, "SecrecyLevel", { NeverSecret = 0, AlwaysSecret = 1, ContextuallySecret = 2 })
  Same(status({ unit = "target", use_spellIds = true, spellIds = { 1, 3 } }), unfiltered, "status all never secret")
  Same(status({ unit = "target", use_spellIds = true, spellIds = { 1, 2 } }), Blocked("Exact Spell ID(s)"),
    "status one secret id blocks")
  Same(status({ unit = "target", use_spellNames = true, spellNames = { 1 } }), unfiltered, "status single readable id")
  Same(status({ unit = "target", use_spellNames = true, spellNames = { "1" } }), unfiltered, "status numeric string id")
  Same(status({ unit = "target", use_spellId = true, spellId = { 1 } }), Blocked("Spell ID"),
    "status spellId never readable")
  Enum.SecrecyLevel = nil
  Same(status({ unit = "target", use_spellIds = true, spellIds = { 1 } }), Blocked("Exact Spell ID(s)"),
    "status without SecrecyLevel")

  ---------------------------------------------------------------------------------------------
  -- SecretConditions
  ---------------------------------------------------------------------------------------------
  Same(env.SecretPick(nil, 1, 0), 0, "SecretPick nil")
  local forwarded
  Override(private.BlizzardAuraDisplay, "SetConditionProperty", function(...) forwarded = { n = select("#", ...), ... } end)
  env.SetSecretAuraConditionProperty("regionToken", "alpha", 0.5, "extra")
  assert(forwarded.n == 4 and forwarded[1] == "regionToken" and forwarded[2] == "alpha"
    and forwarded[3] == 0.5 and forwarded[4] == "extra", "SetSecretAuraConditionProperty forwards all arguments")

  -- SecretTimerSelect revealed values, >=, > and the decreasing operators
  Units.SetCombat(true)
  local secretState = { durationObject = Timer(5, 10, true) }
  assert(secretState.durationObject:HasSecretValues(), "setup: duration not secret")
  local function Reveal(op, threshold, state)
    local result = env.SecretTimerSelect(state or secretState, op, threshold, false, 1, 0)
    assert(Secret.IsSecret(result), "timer " .. op .. " " .. threshold .. " must be secret")
    return Secret.Reveal(result)
  end
  Same(Reveal(">", 5), 1, "> 5 with 5 left (remaining at threshold)")
  Same(Reveal(">=", 5), 1, ">= 5 with 5 left")
  Same(Reveal(">", 6), 0, "> 6 with 5 left")
  Same(Reveal(">=", 6), 0, ">= 6 with 5 left")
  Same(Reveal(">", 3), 1, "> 3 with 5 left")
  Same(Reveal("<", 6), 1, "< 6 with 5 left")
  Same(Reveal("<=", 6), 1, "<= 6 with 5 left")
  Same(Reveal("<", 5), 0, "< 5 with 5 left (remaining at threshold)")
  Same(Reveal("<=", 5), 0, "<= 5 with 5 left (remaining at threshold)")
  Same(Reveal("<", 3), 0, "< 3 with 5 left")
  Same(Reveal("<", 6, { durationObject = Timer(0, 10, true) }), 0, "< 6 with nothing left")
  -- results are cached per (op, threshold, outputs): same answer on repeat
  Same(Reveal(">", 6), 0, "repeat call")
  -- readable fallbacks
  Same(env.SecretTimerSelect(secretState, ">", -1, true, 1, 0), 1, "negative threshold readable, active")
  Same(env.SecretTimerSelect(secretState, ">", -1, false, 1, 0), 0, "negative threshold readable, inactive")
  Same(env.SecretTimerSelect({ durationObject = Timer(5, 10) }, ">", 3, false, 1, 0), 0, "readable duration follows readableActive")
  Same(env.SecretTimerSelect(secretState, ">", 3, true, Secret.Wrap(1), 0) ~= nil, true, "secret output handled")
  assert(Secret.IsSecret(env.SecretTimerSelect(secretState, ">", 3, false, 1, Secret.Wrap(0))), "secret output stays secret")
  Same(env.SecretValueSelect(function() return false end, {}, false, true, 1, 0), false, "selector false kept")
  Units.SetCombat(false)

  -- refresher behaviour through the native refresh registry
  local refreshed = {}
  local region = CreateFrame("Frame")
  Override(private, "SetNativeRefresh", function(target, key, refresher)
    refreshed[#refreshed + 1] = { target = target, key = key, refresher = refresher }
  end)
  env.SetSecretConditionRefresh(region, true)
  Same(refreshed[1].target, region, "refresh region")
  Same(refreshed[1].key, "secretConditions", "refresh key")
  assert(type(refreshed[1].refresher) == "function", "refresher registered")
  env.SetSecretConditionRefresh(region, false)
  Same(refreshed[2].key, "secretConditions", "refresh off key")
  Same(refreshed[2].refresher, nil, "refresh off")
  local runConditionsCalls = {}
  Override(private, "RunConditions", function(...) runConditionsCalls[#runConditionsCalls + 1] = { ... } end)
  region.toShow, region.states, region.uid = true, {}, "uid-1"
  refreshed[1].refresher(region)
  assert(#runConditionsCalls == 1 and runConditionsCalls[1][1] == region and runConditionsCalls[1][2] == "uid-1"
    and runConditionsCalls[1][3] == false, "refresher runs conditions without hiding")
  Same(#refreshed, 2, "refresher registered nothing while shown")
  region.toShow = false
  refreshed[1].refresher(region)
  Same(#runConditionsCalls, 1, "refresher idle while hidden")
  Same(#refreshed, 3, "refresher unregisters when hidden")
  Same(refreshed[3].key, "secretConditions", "unregister key")
  Same(refreshed[3].refresher, nil, "unregistered")

  -- CreateSecretConditionCode
  local conditionHelpers = env.conditionHelpers
  assert(type(conditionHelpers) == "table", "conditionHelpers missing")
  local properties = {
    alpha = { type = "number", secretCapable = true, setter = "SetAlpha" },
    color = { type = "color", secretCapable = true, setter = "Color" },
    glow = { type = "bool", secretCapable = true, setter = "SetGlow", secretSetter = "SetGlowSecret" },
    plain = { type = "number", setter = "SetPlain" },
    boolNoSecret = { type = "bool", secretCapable = true, setter = "SetB" },
    sub = { type = "number", secretCapable = true, setter = "SetValue", arg1 = "mode" },
  }
  local selectCalls = {}
  local template = {
    [1] = {
      ready = { type = "bool", secretTest = function() return "T" end, secretInverted = true },
      choice = { type = "bool", secretSelect = function() return nil end },
      expirationTime = { type = "timer" },
      other = { type = "number" },
    },
  }
  local runnable = false
  local function CreateTest(_, check)
    if runnable then return "true" end
    return "TEST(" .. tostring(check.variable) .. ")"
  end
  local function ParseProperty(property)
    return property == "sub" and 2 or nil
  end
  local function BaseProperty(_, property)
    if property == "color" then return { 0.1, 0.2, 0.3, 0.4 } end
    if property == "glow" then return true end
    if property == "alpha" then return 0.9 end
    return nil
  end
  local function Generate(conditions, extraProperties)
    local ret = {}
    conditionHelpers["contract-uid"] = nil
    local data = { uid = "contract-uid", id = "Contract", conditions = conditions }
    private.CreateSecretConditionCode(ret, data, extraProperties or properties, template, CreateTest, ParseProperty, BaseProperty)
    return table.concat(ret), data
  end
  local function Leaf(variable, value, op) return { trigger = 1, variable = variable, value = value, op = op } end
  local function Condition(check, ...)
    local changes = {}
    for _, change in ipairs({ ... }) do changes[#changes + 1] = { property = change[1], value = change[2] } end
    return { check = check, changes = changes }
  end
  local function Find(text, fragment, init)
    local from, to = text:find(fragment, init or 1, true)
    assert(from, "fragment not generated: " .. fragment .. "\n" .. text)
    return from, to
  end

  Same(Generate({}), "", "no conditions emit nothing")
  Same(Generate({ Condition(Leaf("other", 1), { "alpha", 0 }) }), "", "ordinary leaf emits nothing")
  Same(Generate({ Condition(Leaf("ready", 1), { "plain", 0 }) }), "", "non secret-capable property emits nothing")
  Same(Generate({ Condition(Leaf("ready", 1), { "boolNoSecret", true }) }), "", "bool without secretSetter emits nothing")
  Same(Generate({ Condition(Leaf("ready", 1), { "unknown", 0 }) }), "", "unknown property emits nothing")
  Same(Generate({ { check = Leaf("ready", 1) } }), "", "condition without changes emits nothing")
  Same(Generate({ Condition(Leaf("ready", 1), { "alpha", 0 }), { linked = true, check = Leaf("other", 1), changes = {} } }),
    "", "condition followed by linked emits nothing")
  Same(Generate({ Condition(Leaf("ready", 1), { "alpha", 0 }), Condition(Leaf("ready", 1), { "alpha", 1 }) }) ~= "", true,
    "unlinked pair emits")
  local linkedSecond = Condition(Leaf("ready", 1), { "alpha", 0 })
  linkedSecond.linked = true
  Same(Generate({ linkedSecond }), "", "linked condition emits nothing")

  local code = Generate({ Condition(Leaf("ready", 1), { "alpha", 0.3 }) })
  Find(code, "if not hideRegion then")
  Find(code, "local secretTimerApplied = false")
  Find(code, "local v1 = 0.9")
  Find(code, "v1 = Private.ExecEnv.SecretBoolSelect(Private.ExecEnv.conditionHelpers[\"contract-uid\"].secretTests[1](state[1]), true, (TEST(ready)), 0.3, v1)")
  Find(code, "if Private.ExecEnv.IsSecret(v1) then")
  Find(code, "region.secretConditionProperties = region.secretConditionProperties or {}")
  Find(code, "region.secretConditionProperties[\"alpha\"] = true")
  Find(code, "region:SetAlpha(v1)")
  Find(code, "elseif region.secretConditionProperties and region.secretConditionProperties[\"alpha\"] then")
  Find(code, "region.secretConditionProperties[\"alpha\"] = nil")
  Find(code, "Private.ExecEnv.SetSecretConditionRefresh(region, secretTimerApplied)")
  assert(not code:find("secretTimerApplied = true", 1, true), "plain bool leaf does not flag timer")
  assert(#conditionHelpers["contract-uid"].secretTests == 1, "secret test registered")
  Same(conditionHelpers["contract-uid"].secretTests[1], template[1].ready.secretTest, "registered test is the template one")

  -- value 0 flips the inversion, select kind and the timer flag
  code = Generate({ Condition(Leaf("ready", 0), { "alpha", 1 }) })
  Find(code, "secretTests[1](state[1]), false, (TEST(ready)), 1, v1)")
  code = Generate({ Condition(Leaf("choice", 0), { "alpha", 1 }) })
  Find(code, "Private.ExecEnv.SecretValueSelect(Private.ExecEnv.conditionHelpers[\"contract-uid\"].secretSelects[1], state[1], true, (TEST(choice)), 1, v1)")
  Find(code, "secretTimerApplied = true")
  code = Generate({ Condition(Leaf("choice", 1), { "alpha", 1 }) })
  Find(code, "state[1], false, (TEST(choice)), 1, v1)")

  -- timer leaf
  code = Generate({ Condition(Leaf("expirationTime", "5", "<"), { "alpha", 0 }) })
  Find(code, "v1 = Private.ExecEnv.SecretTimerSelect(state[1], \"<\", 5, (TEST(expirationTime)), 0, v1)")
  Find(code, "secretTimerApplied = true")
  Same(Generate({ Condition(Leaf("expirationTime", "5", "=="), { "alpha", 0 }) }), "", "timer with == emits nothing")
  Same(Generate({ Condition(Leaf("expirationTime", "abc", "<"), { "alpha", 0 }) }), "", "timer with bad number emits nothing")

  -- AND / OR: timers last, nesting from the last test to the first
  local timerLeaf = Leaf("expirationTime", 5, ">=")
  local andCheck = { variable = "AND", checks = { timerLeaf, Leaf("ready", 1), Leaf("choice", 1) } }
  code = Generate({ Condition(andCheck, { "alpha", 1 }) })
  local readyAt = Find(code, "secretTests[")
  local choiceAt = Find(code, "secretSelects[")
  local timerAt = Find(code, "SecretTimerSelect(state[1]")
  assert(readyAt < choiceAt or choiceAt < readyAt, "sanity")
  -- AND: the expression of later tests is the "if true" value of earlier ones
  Find(code, "v1 = Private.ExecEnv.SecretBoolSelect(")
  local lineEnd = code:find("\n", code:find("v1 = Private.ExecEnv.SecretBoolSelect(", 1, true), true)
  local line = code:sub(code:find("v1 = Private.ExecEnv.SecretBoolSelect(", 1, true), lineEnd)
  local selectInLine = line:find("SecretValueSelect(", 1, true)
  local timerInLine = line:find("SecretTimerSelect(", 1, true)
  assert(selectInLine and timerInLine and selectInLine < timerInLine, "AND order: bool outermost, timer innermost\n" .. line)
  Find(line, "SecretTimerSelect(state[1], \">=\", 5, (TEST(expirationTime)), 1, v1)")
  Find(line, "(TEST(choice)), Private.ExecEnv.SecretTimerSelect(")
  Find(line, "(TEST(ready)), Private.ExecEnv.SecretValueSelect(")
  Find(line, ", v1)")

  local orCheck = { variable = "OR", checks = { timerLeaf, Leaf("ready", 1), Leaf("choice", 1) } }
  code = Generate({ Condition(orCheck, { "alpha", 1 }) })
  line = code:match("v1 = Private%.ExecEnv%.SecretBoolSelect%([^\n]*")
  assert(line, "OR line missing")
  Find(line, "(TEST(ready)), 1, Private.ExecEnv.SecretValueSelect(")
  Find(line, "(TEST(choice)), 1, Private.ExecEnv.SecretTimerSelect(")
  Find(line, "SecretTimerSelect(state[1], \">=\", 5, (TEST(expirationTime)), 1, v1)")

  -- ordinary leaves in a mixed check use SecretPick; a lone ordinary leaf with no test emits nothing
  code = Generate({ Condition({ variable = "AND", checks = { Leaf("ready", 1), Leaf("other", 1) } }, { "alpha", 1 }) })
  Find(code, "Private.ExecEnv.SecretPick((TEST(other)), 1, v1)")
  local noTest = function() return nil end
  local ret = {}
  private.CreateSecretConditionCode(ret, { uid = "contract-uid", conditions = {
    Condition({ variable = "AND", checks = { Leaf("ready", 1), Leaf("other", 1) } }, { "alpha", 1 }) } },
    properties, template, noTest, ParseProperty, BaseProperty)
  code = table.concat(ret)
  Find(code, "(false), 1, v1)")
  assert(not code:find("SecretPick", 1, true), "ordinary leaf without test emits no SecretPick")

  -- colors: four channels
  code = Generate({ Condition(Leaf("ready", 1), { "color", { 1, 0.5, 0, 0.25 } }) })
  Find(code, "local v1 = 0.1")
  Find(code, "local v2 = 0.2")
  Find(code, "local v3 = 0.3")
  Find(code, "local v4 = 0.4")
  Find(code, "(TEST(ready)), 1, v1)")
  Find(code, "(TEST(ready)), 0.5, v2)")
  Find(code, "(TEST(ready)), 0, v3)")
  Find(code, "(TEST(ready)), 0.25, v4)")
  Find(code, "region:Color(v1, v2, v3, v4)")
  Find(code, "if Private.ExecEnv.IsSecret(v1, v2, v3, v4) then")
  -- bool
  code = Generate({ Condition(Leaf("ready", 1), { "glow", false }) })
  Find(code, "local v1 = 1")
  Find(code, "(TEST(ready)), 0, v1)")
  Find(code, "region:SetGlowSecret(v1)")
  Find(code, "region:SetGlow(v1 == 1)")
  -- sub region and arg1
  code = Generate({ Condition(Leaf("ready", 1), { "sub", 7 }) })
  Find(code, "local v1 = 0\n")
  Find(code, "region.subRegions[2]:SetValue('mode', v1)")
  properties.sub.arg1 = 4
  code = Generate({ Condition(Leaf("ready", 1), { "sub", 7 }) })
  Find(code, "region.subRegions[2]:SetValue(4, v1)")
  properties.sub.arg1 = nil

  -- non secret condition on the same property: readable chain, secret conditions after
  code = Generate({
    Condition(Leaf("other", 1), { "alpha", 0.2 }),
    Condition(Leaf("ready", 1), { "alpha", 0.7 }),
  })
  local readableAt = Find(code, "if newActiveConditions[1] then")
  Find(code, "v1 = 0.2", readableAt)
  local secretAt = Find(code, "SecretBoolSelect(")
  assert(readableAt < secretAt, "readable condition precedes the secret one")
  assert(not code:find("newActiveConditions[2]", 1, true), "secret condition has no readable branch")
  -- last change of a property wins within a condition
  code = Generate({ Condition(Leaf("ready", 1), { "alpha", 0.2 }, { "alpha", 0.8 }) })
  Find(code, "(TEST(ready)), 0.8, v1)")
  assert(not code:find("0.2", 1, true) or code:find("local v1 = 0.9", 1, true), "first change ignored")
  -- several properties: one block each, one refresh call, timers flag per property
  code = Generate({
    Condition(Leaf("choice", 1), { "alpha", 1 }),
    Condition(Leaf("ready", 1), { "glow", true }),
  })
  Find(code, "region.secretConditionProperties[\"alpha\"] = true")
  Find(code, "region.secretConditionProperties[\"glow\"] = true")
  local _, refreshCount = code:gsub("SetSecretConditionRefresh", "")
  Same(refreshCount, 1, "single refresh call")
  local _, doCount = code:gsub("\n    do\n", "")
  Same(doCount, 2, "one block per property")

  -- executing the generated code
  local function Compile(text)
    local source = "local Private, region, state, newActiveConditions, hideRegion = ...\n" .. text
    local chunk = assert(loadstring(source))
    return function(...) return chunk(private, ...) end
  end
  local function Run(conditions, stateValue, active)
    runnable = true
    local text = Generate(conditions)
    runnable = false
    local calls = {}
    local owner = setmetatable({}, { __index = { SetAlpha = function(_, value) calls[#calls + 1] = value end } })
    NoError("generated code", Compile(text), owner, { stateValue }, active or {}, false)
    return owner, calls
  end
  template[1].ready.secretTest = function(state) return state end
  local owner, calls = Run({ Condition(Leaf("ready", 1), { "alpha", 0.3 }) }, Secret.Wrap(true), {})
  Same(#calls, 1, "secret path applies the setter")
  assert(Secret.IsSecret(calls[1]), "secret path value is secret")
  Same(owner.secretConditionProperties.alpha, true, "secretConditionProperties set")
  -- readable value: nothing applied unless the property was secret before
  owner, calls = Run({ Condition(Leaf("ready", 1), { "alpha", 0.3 }) }, false, {})
  Same(#calls, 0, "readable path leaves the setter to the normal chain")
  Same(owner.secretConditionProperties, nil, "readable path creates nothing")
  Same(env.IsSecret(1), false, "ExecEnv.IsSecret exists")
  -- hideRegion skips everything
  local hidden = {}
  NoError("hidden", Compile(Generate({ Condition(Leaf("ready", 1), { "alpha", 0.3 }) })),
    setmetatable({}, { __index = { SetAlpha = function() hidden[#hidden + 1] = true end } }), { Secret.Wrap(true) }, {}, true)
  Same(#hidden, 0, "hideRegion skips the block")

  ---------------------------------------------------------------------------------------------
  -- SecretSpellCooldown
  ---------------------------------------------------------------------------------------------
  Same(private.IsDurationObjectRunning(Timer(5, 10)), true, "running duration")
  Same(private.IsDurationObjectRunning(Timer(0, 0)), false, "zero duration")
  Same(private.IsDurationObjectRunning(Timer(-3, 10)), false, "expired duration")
  Same(private.IsDurationObjectRunning(Timer(5, 10, true)), nil, "secret duration")
  Same(private.IsDurationObjectRunning({ IsZero = function() return false end, HasExpired = function() return "no" end }),
    nil, "non-boolean result")
  Same(private.IsDurationObjectRunning({ IsZero = function() error("boom") end, HasExpired = function() return false end }),
    nil, "failing call")
  Same(private.IsDurationObjectRunning({}), nil, "object without methods")

  local sent, checks = {}, {}
  local details = {
    data = {},
    SendEventsForSpell = function(_, spellId, event, ...) sent[#sent + 1] = { spellId, event, ... } end,
    CheckSpellCooldown = function(self, spellId, runeDuration)
      checks[#checks + 1] = { spellId = spellId, quiet = self.quietSecretCheck, rune = runeDuration }
    end,
  }
  local handler = private.CreateSecretSpellCooldown(details, function() return "rune" end)
  assert(type(handler) == "function" and type(details.UpdateSecretReady) == "function"
    and type(details.ClearSecretReady) == "function", "factory contract")

  local infos, cooldowns = {}, {}
  local gcdInfo = { duration = 1.5 }
  Override(C_Spell, "GetSpellCooldown", function(spellId)
    if spellId == 61304 or spellId == 29515 then return gcdInfo end
    return infos[spellId]
  end)
  Override(C_Spell, "GetSpellCooldownDuration", function(spellId) return cooldowns[spellId] end)

  -- real cooldown, then ready: event only after the GCD window
  local SPELL = 700
  details.data[SPELL] = { secret = true }
  infos[SPELL] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[SPELL] = Timer(5, 10)
  local began = GetTime()
  Same(details:UpdateSecretReady(SPELL), true, "first update changes state")
  local detail = details.data[SPELL]
  Same(detail.secretReady, false, "not ready")
  Same(detail.secretGCDOnly, nil, "not GCD only")
  Same(detail.notReadySince, began, "notReadySince")
  Same(detail.notReadyWand, nil, "no wand")
  Same(detail.gcdHoldOnly, nil, "no hold")
  Same(details:UpdateSecretReady(SPELL), false, "second identical update unchanged")
  Same(#sent, 0, "no event while cooling down")
  infos[SPELL] = { isActive = false, isEnabled = true }
  Clock.Advance(5.2)
  Same(#checks >= 1 and checks[1].spellId or nil, SPELL, "end timer rechecks the spell")
  Same(checks[1].quiet, true, "recheck is quiet")
  Same(checks[1].rune, "rune", "recheck passes rune duration")
  Same(details.quietSecretCheck, nil, "quiet flag reset")
  Same(details:UpdateSecretReady(SPELL), true, "ready update changes state")
  Same(detail.secretReady, true, "ready")
  Same(#sent, 1, "ready event sent")
  Same(sent[1][1], SPELL, "event spell")
  Same(sent[1][2], "SPELL_COOLDOWN_READY", "event name")
  Same(sent[1][3], SPELL, "event argument")
  Same(detail.notReadySince, nil, "notReadySince cleared")
  Same(detail.lastReadyAt, GetTime(), "lastReadyAt")
  Same(details:UpdateSecretReady(SPELL), false, "ready again unchanged")
  Same(#sent, 1, "no repeated event")

  -- too short to be a real cooldown: no event
  infos[SPELL] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[SPELL] = Timer(1, 1)
  details:UpdateSecretReady(SPELL)
  Same(detail.secretReady, false, "short cooldown not ready")
  infos[SPELL] = { isActive = false, isEnabled = true }
  Clock.Advance(1)
  details:UpdateSecretReady(SPELL)
  Same(detail.secretReady, true, "short cooldown over")
  Same(#sent, 1, "no event inside the GCD window")

  -- disabled spell is not ready
  infos[SPELL] = { isActive = false, isEnabled = false }
  details:UpdateSecretReady(SPELL)
  Same(detail.secretReady, false, "disabled spell")
  -- secret or missing info: unknown
  infos[SPELL] = nil
  details:UpdateSecretReady(SPELL)
  Same(detail.secretReady, nil, "missing info is unknown")
  infos[SPELL] = { isActive = Secret.Wrap(true), isEnabled = true }
  details:UpdateSecretReady(SPELL)
  Same(detail.secretReady, nil, "secret isActive is unknown")

  -- GCD hold: ready inside the GCD window of a GCD flagged spell is reported as not ready, never fires READY
  local HOLD = 701
  details.data[HOLD] = { secret = true }
  infos[HOLD] = { isActive = true, isEnabled = true, isOnGCD = true }
  cooldowns[HOLD] = Timer(0, 0)
  local sentBefore = #sent
  Same(details:UpdateSecretReady(HOLD), true, "GCD hold changes state")
  local hold = details.data[HOLD]
  Same(hold.secretReady, false, "held by the GCD")
  Same(hold.secretGCDOnly, true, "GCD only flag")
  Same(hold.gcdHoldOnly, true, "hold only span")
  Same(hold.notReadySince ~= nil, true, "hold start recorded")
  Clock.Advance(2)
  infos[HOLD] = { isActive = false, isEnabled = true }
  Same(details:UpdateSecretReady(HOLD), true, "end of the hold changes state")
  Same(hold.secretReady, true, "hold released")
  Same(hold.secretGCDOnly, nil, "GCD only flag cleared")
  Same(#sent, sentBefore, "GCD hold never fires READY")

  -- wand: not ready span started while the wand holds the spell does not fire READY
  local WAND = 702
  details.data[WAND] = { secret = true }
  infos[WAND] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[WAND] = Timer(5, 10)
  handler(true, "UNIT_SPELLCAST_SUCCEEDED", "player", "castGUID", 5019)
  details:UpdateSecretReady(WAND)
  Same(details.data[WAND].notReadyWand, true, "wand held span")
  Clock.Advance(3)
  infos[WAND] = { isActive = false, isEnabled = true }
  sentBefore = #sent
  details:UpdateSecretReady(WAND)
  Same(#sent, sentBefore, "wand only span fires no READY")
  Same(details.data[WAND].secretReady, true, "wand spell ready")
  Same(details.data[WAND].notReadyWand, nil, "wand flag cleared")

  -- paused: no event
  local PAUSE = 703
  details.data[PAUSE] = { secret = true }
  infos[PAUSE] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[PAUSE] = Timer(5, 10)
  details:UpdateSecretReady(PAUSE)
  Clock.Advance(3)
  infos[PAUSE] = { isActive = false, isEnabled = true }
  Override(WeakAuras, "IsPaused", function() return true end)
  sentBefore = #sent
  details:UpdateSecretReady(PAUSE)
  Same(#sent, sentBefore, "paused fires no READY")
  WeakAuras.IsPaused = restores[#restores][3]
  restores[#restores] = nil

  -- ClearSecretReady
  local CLEAR = 704
  details.data[CLEAR] = { secret = true, lastReadyAt = 12 }
  infos[CLEAR] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[CLEAR] = Timer(5, 10)
  details:UpdateSecretReady(CLEAR)
  details:ClearSecretReady(CLEAR)
  local cleared = details.data[CLEAR]
  assert(cleared.secretReady == nil and cleared.notReadySince == nil and cleared.notReadyWand == nil
    and cleared.gcdHoldOnly == nil and cleared.secretGCDOnly == nil, "ClearSecretReady clears the state")
  Same(cleared.lastReadyAt, 12, "ClearSecretReady keeps lastReadyAt")
  local checksBefore = #checks
  Clock.Advance(10)
  Same(#checks, checksBefore, "ClearSecretReady stops the recheck")

  -- polling when no deadline is readable
  local POLL = 705
  details.data[POLL] = { secret = true }
  infos[POLL] = { isActive = true, isEnabled = true, isOnGCD = false }
  cooldowns[POLL] = nil
  C_Spell.GetSpellCooldownDuration = function() return nil end
  details:UpdateSecretReady(POLL)
  Same(details.data[POLL].secretReady, false, "no duration: not ready")
  infos[POLL] = { isActive = true, isEnabled = true, isOnGCD = true }
  handler(true, "SPELL_UPDATE_COOLDOWN", POLL)
  details:UpdateSecretReady(POLL)
  checksBefore = #checks
  Clock.Advance(0.5)
  local polled = 0
  for index = checksBefore + 1, #checks do
    if checks[index].spellId == POLL then polled = polled + 1 end
  end
  Same(polled == 0, true, "unknown readiness is not polled")

  -- handler
  Same(handler(true, "UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 123), true, "cast event consumed")
  Same(handler(true, "SPELL_UPDATE_COOLDOWN"), nil, "cooldown event not consumed")
  Same(handler(false, "SPELL_UPDATE_COOLDOWN"), nil, "cooldown event outside the world")
  Same(handler(true, "PLAYER_ENTERING_WORLD"), nil, "entering world")
  Same(handler(true, "PLAYER_LEAVING_WORLD"), nil, "leaving world")
  Same(select("#", handler(true, "SOMETHING_ELSE")), 0, "other events return nothing")
  -- leaving the world clears the GCD flags
  local State = private.SpellCooldownState
  infos[HOLD] = { isActive = true, isEnabled = true, isOnGCD = true }
  State.UpdateGCDFlag(HOLD)
  Same(State.GetGCDFlag(HOLD), true, "flag set")
  handler(true, "PLAYER_LEAVING_WORLD")
  Same(State.GetGCDFlag(HOLD), nil, "flags cleared on leaving world")
  -- a tracked spell that lost its data is forgotten on SPELL_UPDATE_COOLDOWN
  details.data[HOLD] = nil
  State.UpdateGCDFlag(HOLD)
  handler(true, "SPELL_UPDATE_COOLDOWN")
  Same(State.GetGCDFlag(HOLD), nil, "spell without data forgotten")

  ---------------------------------------------------------------------------------------------
  -- SecretAuraTrigger (trigger system secretAura)
  ---------------------------------------------------------------------------------------------
  local system = private.triggerTypes.secretAura
  assert(type(system) == "table", "secretAura trigger system not registered")
  for _, name in ipairs({ "Add", "CreateFallbackState", "CreateFakeStates", "LoadDisplays", "UnloadDisplays", "UnloadAll",
    "Delete", "Rename", "FinishLoadUnload", "GetName", "CanHaveTooltip", "SetToolTip", "GetOverlayInfo",
    "GetAdditionalProperties", "GetProgressSources", "GetTriggerConditions", "GetNameAndIcon", "GetTriggerDescription" }) do
    assert(type(system[name]) == "function", "missing trigger system method " .. name)
  end
  Same(system.GetName(), "Aura (Modern)", "name")
  Same(system.CanHaveTooltip(), false, "tooltip")
  Same(system.SetToolTip(), false, "SetToolTip")
  Same(system.FinishLoadUnload(), nil, "FinishLoadUnload")
  local overlay, overlayAgain = system.GetOverlayInfo(), system.GetOverlayInfo()
  assert(next(overlay) == nil and overlay ~= overlayAgain, "overlay info fresh and empty")
  local additional, additionalAgain = system.GetAdditionalProperties(), system.GetAdditionalProperties()
  assert(next(additional) == nil and additional ~= additionalAgain, "additional properties fresh and empty")
  local conditions, conditionsAgain = system.GetTriggerConditions(), system.GetTriggerConditions()
  assert(next(conditions) == nil and conditions ~= conditionsAgain, "trigger conditions fresh and empty")
  local sources = { "first" }
  system.GetProgressSources({}, 3, sources)
  Same(#sources, 2, "one progress source added")
  local source = sources[2]
  assert(source.trigger == 3 and source.property == "value" and source.type == "number"
    and source.display == "Aura (Modern)" and source.total == "total", "progress source content")

  local Display = private.BlizzardAuraDisplay
  local optionsOpen = false
  Override(WeakAuras, "IsOptionsOpen", function() return optionsOpen end)
  local displayEnabled, validation, unitExists, previewUnit = false, nil, true, "target"
  local spellIds = {}
  local migrations, activated, released = {}, {}, {}
  Override(Display, "MigrateNativeConditions", function(data) migrations[#migrations + 1] = "native:" .. data.id end)
  Override(Display, "MigrateFallback", function(data) migrations[#migrations + 1] = "fallback:" .. data.id end)
  Override(Display, "Enabled", function() return displayEnabled end)
  Override(Display, "Validate", function() return validation end)
  Override(Display, "SingleUnitExists", function() return unitExists end)
  Override(Display, "GetPreviewUnit", function() return previewUnit end)
  Override(Display, "GetSpellIDs", function() return spellIds end)
  Override(Display, "Activate", function(region, data) activated[#activated + 1] = { region, data.id } end)
  Override(Display, "Release", function(region) released[#released + 1] = region end)

  local function SecretData(id, triggers)
    local data = { id = id, triggers = {} }
    for index, trigger in ipairs(triggers) do
      data.triggers[index] = { trigger = trigger }
    end
    return data
  end
  local dataById, statesById, updated = {}, {}, {}
  Override(WeakAuras, "GetData", function(id) return dataById[id] end)
  Override(WeakAuras, "GetTriggerStateForTrigger", function(id, triggernum)
    statesById[id] = statesById[id] or {}
    statesById[id][triggernum] = statesById[id][triggernum] or {}
    return statesById[id][triggernum]
  end)
  Override(private, "UpdatedTriggerState", function(id) updated[#updated + 1] = id end)
  local regionTable = {}
  Override(private, "regions", regionTable)

  -- GetNameAndIcon
  local aura = SecretData("NameAura", { { type = "secretAura", unit = "player" } })
  spellIds = {}
  local name, icon = system.GetNameAndIcon(aura, 1)
  Same(name, "Secret Auras", "default name")
  Same(icon, 134400, "default icon")
  spellIds = { 1234 }
  local originalGetSpellInfo = C_Spell.GetSpellInfo
  Override(C_Spell, "GetSpellInfo", function(spellId)
    if spellId == 1234 then return { name = "Contract Spell", iconID = 4242 } end
    if spellId == 1235 then return { iconID = 1 } end
  end)
  name, icon = system.GetNameAndIcon(aura, 1)
  Same(name, "Contract Spell", "spell name")
  Same(icon, 4242, "spell icon")
  spellIds = { 1235 }
  name, icon = system.GetNameAndIcon(aura, 1)
  Same(name, "Secret Auras", "name falls back alone")
  Same(icon, 1, "icon kept alone")
  spellIds = { 999 }
  name, icon = system.GetNameAndIcon(aura, 1)
  Same(name, "Secret Auras", "unknown spell name")
  Same(icon, 134400, "unknown spell icon")
  spellIds = {}

  -- CreateFallbackState
  local state = {}
  system.CreateFallbackState(aura, 1, state)
  Same(state.show, true, "fallback shows when disabled")
  Same(state.changed, true, "fallback changed")
  Same(state.progressType, "static", "fallback static")
  Same(state.value, 1, "fallback value")
  Same(state.total, 1, "fallback total")
  Same(state.name, "Secret Auras", "fallback name")
  Same(state.icon, 134400, "fallback icon")
  Same(state.unit, nil, "fallback unit closed")
  Same(state.duration, nil, "fallback duration closed")
  displayEnabled, validation = true, "invalid"
  state = {}
  system.CreateFallbackState(aura, 1, state)
  Same(state.show, false, "fallback hidden when native settings are invalid")
  validation = nil
  state = {}
  system.CreateFallbackState(aura, 1, state)
  Same(state.show, true, "fallback shown when native settings are valid")
  displayEnabled = false
  optionsOpen = true
  state = {}
  system.CreateFallbackState(aura, 1, state)
  Same(state.progressType, "timed", "fallback preview timer")
  Same(state.duration, 6, "preview duration")
  Same(state.expirationTime, GetTime() + 6, "preview expiration")
  Same(state.stacks, 3, "preview stacks")
  Same(state.value, 1, "preview value")
  Same(state.total, 1, "preview total")
  Same(state.unit, "target", "preview unit")
  previewUnit = false
  state = {}
  system.CreateFallbackState(aura, 1, state)
  Same(state.unit, nil, "preview unit false becomes nil")
  optionsOpen = false

  -- Add / registration / LoadDisplays / UnloadDisplays
  local plain = SecretData("PlainAura", { { type = "aura2" } })
  dataById.PlainAura = plain
  system.Add(plain)
  Same(table.concat(migrations, ","), "native:PlainAura,fallback:PlainAura", "migration order")
  local targeted = SecretData("TargetAura", { { type = "aura2" }, { type = "secretAura", unit = "target" } })
  dataById.TargetAura = targeted
  system.Add(targeted)
  local regionOne = { name = "region one" }
  regionTable.TargetAura = { region = regionOne }
  regionTable.PlainAura = { region = { name = "plain region" } }
  system.LoadDisplays({ PlainAura = true, Unknown = true })
  Same(#activated, 0, "unregistered ids ignored")
  Same(#updated, 0, "unregistered ids trigger no update")
  unitExists = false
  system.LoadDisplays({ TargetAura = true })
  Same(#activated, 1, "region activated")
  Same(activated[1][1], regionOne, "activated region")
  Same(activated[1][2], "TargetAura", "activated data")
  Same(#updated, 1, "one trigger state update per loaded aura")
  Same(updated[1], "TargetAura", "updated aura")
  local fakeState = statesById.TargetAura[2][""]
  assert(fakeState, "fake state created for the secretAura trigger")
  Same(statesById.TargetAura[1], nil, "no fake state for other triggers")
  Same(fakeState.show, false, "target absent hides the fake state")
  Same(fakeState.name, "Secret Auras", "fake state name")

  -- events: target changes
  unitExists = true
  updated = {}
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(fakeState.show, true, "target appears")
  Same(fakeState.changed, true, "state flagged changed")
  Same(#updated, 1, "update sent once")
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(#updated, 1, "no update when nothing changed")
  unitExists = false
  Frames.Fire("PLAYER_FOCUS_CHANGED")
  Same(fakeState.show, true, "focus change ignored for target triggers")
  Frames.Fire("UNIT_TARGET", "focus")
  Same(fakeState.show, true, "UNIT_TARGET of focus ignored for target triggers")
  Frames.Fire("UNIT_TARGET", "target")
  Same(fakeState.show, true, "UNIT_TARGET of target concerns targettarget only")
  Frames.Fire("PLAYER_ENTERING_WORLD")
  Same(fakeState.show, false, "entering world recomputes target")
  Same(#updated, 2, "update after hide")
  unitExists = true
  Frames.Fire("GROUP_ROSTER_UPDATE")
  Same(fakeState.show, false, "roster update concerns members only")
  optionsOpen = true
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(fakeState.show, false, "events ignored while options are open")
  optionsOpen = false
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(fakeState.show, true, "events handled when options closed")
  -- trigger.unitExists keeps the display
  targeted.triggers[2].trigger.unitExists = true
  unitExists = false
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(fakeState.show, true, "unitExists keeps the display shown")
  targeted.triggers[2].trigger.unitExists = nil

  -- member / pet routing
  local member = SecretData("MemberAura", { { type = "secretAura", unit = "member", specificUnit = "party1" } })
  local pet = SecretData("PetAura", { { type = "secretAura", unit = "pet" } })
  dataById.MemberAura, dataById.PetAura = member, pet
  system.Add(member)
  system.Add(pet)
  unitExists = true
  system.LoadDisplays({ MemberAura = true, PetAura = true })
  local memberState, petState = statesById.MemberAura[1][""], statesById.PetAura[1][""]
  Same(memberState.show, true, "member shown")
  Same(petState.show, true, "pet shown")
  unitExists = false
  updated = {}
  Frames.Fire("GROUP_ROSTER_UPDATE")
  Same(memberState.show, false, "roster update hides member")
  Same(petState.show, true, "roster update leaves pet")
  unitExists = true
  Frames.Fire("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
  Same(memberState.show, true, "encounter engage refreshes member")
  unitExists = false
  Frames.Fire("ARENA_OPPONENT_UPDATE", "arena1", "seen")
  Same(memberState.show, false, "arena update refreshes member")
  unitExists = true
  Frames.Fire("UNIT_PET", "player")
  Same(memberState.show, false, "UNIT_PET of player refreshes pet only")
  Frames.Fire("UNIT_PET", "party1")
  Same(memberState.show, true, "UNIT_PET of another unit refreshes members")
  unitExists = false
  Frames.Fire("UNIT_PET", "player")
  Same(petState.show, false, "UNIT_PET of player hides absent pet")
  Frames.Fire("UNIT_PET")
  Same(memberState.show, true, "UNIT_PET without unit ignored")
  Frames.Fire("PLAYER_ENTERING_WORLD")
  Same(memberState.show, false, "entering world refreshes members")

  -- Rename / UnloadDisplays / Delete / UnloadAll
  released = {}
  system.UnloadDisplays({ TargetAura = true, PlainAura = true })
  Same(#released, 1, "only registered auras released")
  Same(released[1], regionOne, "released region")
  unitExists = true
  Frames.Fire("PLAYER_TARGET_CHANGED")
  Same(fakeState.show, false, "unloaded aura no longer follows events")
  system.Rename("MemberAura", "MemberRenamed")
  regionTable.MemberRenamed = { region = "renamed region" }
  released = {}
  system.UnloadAll()
  assert(#released >= 1, "UnloadAll releases active auras")
  local releasedRenamed = false
  for _, value in ipairs(released) do if value == "renamed region" then releasedRenamed = true end end
  Same(releasedRenamed, true, "renamed aura was active under its new id")
  Same(#released, 1, "only auras with a region are released")
  released = {}
  system.UnloadAll()
  Same(#released, 0, "nothing left to unload")
  system.Delete("TargetAura")
  system.LoadDisplays({ TargetAura = true })
  Same(#activated, 1, "deleted aura cannot load")
  system.Delete("TargetAura")

  -- CreateFakeStates on its own
  dataById.Standalone = SecretData("Standalone", { { type = "secretAura", unit = "player" } })
  statesById.Standalone = { [1] = { stale = { show = true }, [""] = { old = true } } }
  system.CreateFakeStates("Standalone", 1)
  local standalone = statesById.Standalone[1]
  Same(standalone.stale, nil, "states wiped")
  Same(standalone[""].old, nil, "state replaced")
  Same(standalone[""].show, true, "player trigger shown")
  Same(standalone[""].changed, true, "created changed")
  displayEnabled, validation = true, "invalid"
  system.CreateFakeStates("Standalone", 1)
  Same(statesById.Standalone[1][""].show, false, "invalid native settings hide the fake state")
  displayEnabled, validation = false, nil
  dataById.Standalone.triggers[1].trigger.unit = "focus"
  unitExists = false
  system.CreateFakeStates("Standalone", 1)
  Same(statesById.Standalone[1][""].show, false, "absent focus hides the fake state")
  optionsOpen = true
  system.CreateFakeStates("Standalone", 1)
  Same(statesById.Standalone[1][""].show, true, "options open always show")
  optionsOpen = false

  -- GetTriggerDescription
  local labels = { player = "Player", target = "Target" }
  Override(Display, "units", labels)
  Override(Display, "showOnValues", { active = "Show On Active", missing = "Show On Missing" })
  local showOn, window, comparator, seconds = "active", nil, nil, nil
  Override(Display, "ShowOn", function() return showOn end)
  Override(Display, "RemainingWindow", function() return comparator, seconds end)
  Override(Display, "SpecificUnit", function(trigger) return trigger.specificUnit end)
  local usesRanks, usesIds = true, true
  Override(Display, "UsesRankSpellIDs", function() return usesRanks end)
  Override(Display, "UsesSpellIDs", function() return usesIds end)
  local described = SecretData("Described", { {
    type = "secretAura", unit = "player", auraRankSpellIDs = { 1, 2, 3, 4, 5 }, auraspellids = { 10, 20 },
  } })
  local lines = { { "existing", "line" } }
  system.GetTriggerDescription(described, 1, lines)
  Same(#lines, 5, "four lines appended")
  Same(lines[1][1], "existing", "existing lines kept")
  assert(lines[2][1] == "Secret Auras" and lines[2][2] == "Player", "unit line")
  assert(lines[3][1] == "Show On" and lines[3][2] == "Show On Active", "show on line")
  assert(lines[4][1] == "Spell IDs (All Ranks)" and lines[4][2] == "1, 2, 3 (+2 more)", "rank ids line: " .. tostring(lines[4][2]))
  assert(lines[5][1] == "Exact Spell IDs" and lines[5][2] == "10, 20", "exact ids line")
  comparator, seconds = "<", 5
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[2][2], "Show On Active, remaining < 5 s", "remaining window")
  comparator, seconds = nil, nil
  described.triggers[1].trigger.unit = "mystery"
  described.triggers[1].trigger.auraRankSpellIDs = { 1, 2, 3 }
  described.triggers[1].trigger.auraspellids = {}
  usesRanks = false
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[1][2], "mystery", "unknown unit shown raw")
  Same(lines[3][2], "None", "disabled ranks")
  Same(lines[4][2], "None", "empty ids")
  usesRanks = true
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[3][2], "1, 2, 3", "exactly three ids without suffix")
  described.triggers[1].trigger.unit = "member"
  described.triggers[1].trigger.specificUnit = "Thrall"
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[1][2], "Thrall", "specific unit")
  described.triggers[1].trigger.specificUnit = nil
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[1][2], "Specific Unit", "specific unit fallback")
  described.triggers[1].trigger.auraspellids = nil
  lines = {}
  system.GetTriggerDescription(described, 1, lines)
  Same(lines[4][2], "None", "nil ids")

  for index = #restores, 1, -1 do
    local entry = restores[index]
    entry[1][entry[2]] = entry[3]
  end
  Units.SetCombat(false)
end

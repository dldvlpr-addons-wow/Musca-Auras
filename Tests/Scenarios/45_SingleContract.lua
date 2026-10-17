-- SecretAuraSingle exports: show-on / remaining-window predicates, growth and max auras, icon and unit checks,
-- migrations, fallback choice, spell ID notes, status text, validation order, total / stack / remaining gates,
-- learned durations and profiles (event frame), late glow spec, and the manage paths that run on fake containers.
-- Not covered here: native frames built by the real Blizzard container (missing, presence, remaining slots, duration gate
-- text, stack gate bar), which the harness cannot create.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local CreateFrame = _G.CreateFrame

  local restores = {}
  local function Override(owner, key, value)
    restores[#restores + 1] = {owner = owner, key = key, value = owner[key]}
    owner[key] = value
  end
  local function RestoreAll()
    for position = #restores, 1, -1 do
      local entry = restores[position]
      entry.owner[entry.key] = entry.value
    end
    restores = {}
  end
  local function Eq(actual, expected, label)
    assert(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Near(actual, expected, label)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Has(text, fragment, label)
    assert(type(text) == "string" and text:find(fragment, 1, true), ("%s: %q not in %s"):format(label, fragment, tostring(text)))
  end
  local function Trigger(extra)
    local trigger = {type = "secretAura", unit = "player"}
    for key, value in pairs(extra or {}) do trigger[key] = value end
    return trigger
  end
  local function Data(trigger, extra)
    local data = {
      regionType = "icon", id = "Test Aura", uid = "uid", triggers = {{trigger = trigger}}, blizzardAuraDisplay = {},
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  -- Object whose every method call is recorded as "tag:method(args)".
  local function Fake(tag, log)
    return setmetatable({tag = tag}, {__index = function(self, method)
      return function(_, ...)
        local parts = {}
        for index = 1, select("#", ...) do parts[index] = tostring((select(index, ...))) end
        log[#log + 1] = tag .. ":" .. method .. "(" .. table.concat(parts, ",") .. ")"
      end
    end})
  end
  local function Contains(log, entry)
    for _, line in ipairs(log) do if line == entry then return true end end
    return false
  end
  local function Wipe(log) for key in pairs(log) do log[key] = nil end end
  local function Count(log, entry)
    local total = 0
    for _, line in ipairs(log) do if line == entry then total = total + 1 end end
    return total
  end

  -- Client features the gates and the remaining check need. Added only when the harness lacks them.
  local bindings = Enum.DurationTextBindingProperty
  if not (bindings and bindings.TotalDuration ~= nil and bindings.RemainingDuration ~= nil) then
    Override(Enum, "DurationTextBindingProperty", {RemainingDuration = 1, TotalDuration = 2})
  end
  if not (C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions) then
    Override(_G, "C_AuraContainerUtil", {ProcessCustomAuraButtonApplicationBarOptions = function() end})
  end
  assert(Display.SupportsDurationColorCondition(), "harness lacks color curves")

  -- Tables and constants
  Eq(Display.STACK_LIMIT, 100, "STACK_LIMIT")
  for _, unit in ipairs({"player", "target", "focus", "pet", "targettarget", "focustarget"}) do
    Eq(Display.singleUnits[unit], true, "singleUnits " .. unit)
  end
  Eq(Display.singleUnits.party1, nil, "singleUnits party1")
  Eq(Display.showOnValues.showOnMissing, "Aura(s) Missing", "showOn label")
  Eq(Display.showOnValues.showAlways, "Always", "showOn label always")
  Eq(Display.showOnValues.showOnActive, "Aura(s) Found", "showOn label found")
  Eq(Display.remOperators["<="], "<=", "remOperators")
  Eq(Display.remOperators["="], nil, "remOperators =")
  Eq(Display.totalOperators["="], "=", "totalOperators")
  Eq(Display.totalOperators[">"], nil, "totalOperators >")
  Eq(Display.stackOperators["<"], "<", "stackOperators")
  Eq(Display.approximateUnits.raid, true, "approximateUnits raid")
  Eq(Display.approximateUnits.target, nil, "approximateUnits target")
  Eq(Display.missingTypes.text, true, "missingTypes text")
  Eq(Display.missingTypes.model, nil, "missingTypes model")

  -- IsSingleUnit, RawShowOn / ShowOn, IsSingle
  Eq(Display.IsSingleUnit(nil), false, "IsSingleUnit nil")
  Eq(Display.IsSingleUnit("player"), false, "IsSingleUnit string")
  Eq(Display.IsSingleUnit({unit = "focustarget"}), true, "IsSingleUnit focustarget")
  Eq(Display.IsSingleUnit({unit = "party"}), false, "IsSingleUnit party")
  Eq(Display.IsSingleUnit({unit = "member"}), false, "IsSingleUnit member without specific unit")
  local member = {unit = "member", specificUnit = "party1"}
  Eq(Display.IsSingleUnit(member), Display.SpecificUnit(member) ~= nil, "IsSingleUnit member follows SpecificUnit")
  Eq(Display.IsSingleUnit({unit = "member", specificUnit = "nonsense"}), false, "IsSingleUnit member unknown")
  Eq(Display.RawShowOn(nil), "showOnActive", "RawShowOn nil")
  Eq(Display.RawShowOn({secretShowOn = "bogus"}), "showOnActive", "RawShowOn bogus")
  Eq(Display.RawShowOn({secretShowOn = "showAlways"}), "showAlways", "RawShowOn always")
  Eq(Display.ShowOn({secretShowOn = "showOnMissing"}), "showOnMissing", "ShowOn alias")
  Eq(Display.IsSingle(Trigger()), false, "IsSingle plain")
  Eq(Display.IsSingle(Trigger({secretShowOn = "showAlways"})), true, "IsSingle always")
  Eq(Display.IsSingle(Trigger({secretShowOn = "showOnMissing"}), {regionType = "model"}), true, "IsSingle missing any region")
  Eq(Display.IsSingle(Trigger({secretUseRem = true})), true, "IsSingle remaining without data")
  Eq(Display.IsSingle(Trigger({secretUseRem = true}), {regionType = "icon"}), true, "IsSingle remaining icon")
  Eq(Display.IsSingle(Trigger({secretUseRem = true}), {regionType = "aurabar"}), false, "IsSingle remaining bar")
  Eq(Display.IsSingle(Trigger({secretUseRem = 1}), {regionType = "icon"}), false, "IsSingle remaining needs true")
  Eq(Display.IsSingle(Trigger({secretUseRem = true, secretShowOn = "showOnMissing"})), true, "IsSingle missing wins")

  -- RemainingWindow, InRemainingWindow, RemainingWindowPoints
  local operator, seconds = Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = "5"}))
  Eq(operator, "<", "window default operator")
  Eq(seconds, 5, "window seconds from string")
  operator, seconds = Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = 0, secretRemOperator = ">="}))
  Eq(operator, ">=", "window >=")
  Eq(seconds, 0, "window zero is valid")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = -1})), nil, "window negative")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = "abc"})), nil, "window text")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = 0 / 0})), nil, "window NaN")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = math.huge})), nil, "window infinite")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = 3, secretRemOperator = "=="})), nil, "window bad operator")
  Eq(Display.RemainingWindow(Trigger({secretUseRem = true, secretRem = 3, secretShowOn = "showOnMissing"})), nil, "window ignored in missing mode")
  Eq(Display.RemainingWindow(Trigger({secretRem = 3})), nil, "window off")
  Eq(Display.InRemainingWindow(3, "<", 3), false, "in window < equal")
  Eq(Display.InRemainingWindow(3, "<=", 3), true, "in window <= equal")
  Eq(Display.InRemainingWindow(3, ">", 3), false, "in window > equal")
  Eq(Display.InRemainingWindow(3.1, ">", 3), true, "in window > above")
  Eq(Display.InRemainingWindow(3, ">=", 3), true, "in window >= equal")
  Eq(Display.InRemainingWindow(2, "weird", 3), false, "in window unknown below")
  Eq(Display.InRemainingWindow(3, "weird", 3), true, "in window unknown falls to >=")
  local points = Display.RemainingWindowPoints("ignored", 7)
  Eq(#points, 2, "window points count")
  Near(points[1], 7, "window point 1")
  Near(points[2], 7.001, "window point 2")

  -- DrawsOne, PreviewShowsMissing
  Eq(Display.DrawsOne(Data(Trigger({secretShowOn = "showAlways"}))), true, "DrawsOne always")
  Eq(Display.DrawsOne(Data(Trigger())), false, "DrawsOne plain")
  Eq(Display.DrawsOne(Data(Trigger({secretUseRem = true, secretRem = 3}), {regionType = "aurabar"})), false, "DrawsOne bar")
  Eq(Display.PreviewShowsMissing(Data(Trigger())), false, "preview plain")
  Eq(Display.PreviewShowsMissing(Data(Trigger({secretShowOn = "showOnMissing"}))), true, "preview missing")
  Eq(Display.PreviewShowsMissing(Data(Trigger({secretShowOn = "showAlways"}))), false, "preview always")
  Eq(Display.PreviewShowsMissing(Data(Trigger({secretUseRem = true, secretRem = 3}))), false, "preview remaining")

  -- Growth, MaxAuras (no flow group)
  Eq(Display.Growth(Data(Trigger())), "RIGHT", "growth default")
  Eq(Display.Growth(Data(Trigger(), {blizzardAuraDisplay = {growth = "LEFT"}})), "LEFT", "growth saved")
  Eq(Display.Growth(Data(Trigger({secretShowOn = "showAlways"}), {blizzardAuraDisplay = {growth = "LEFT"}})), "RIGHT", "growth one element")
  Eq(Display.MaxAuras(Data(Trigger())), 10, "max default")
  Eq(Display.MaxAuras(Data(Trigger(), {blizzardAuraDisplay = {maxIcons = 3}})), 3, "max saved")
  Eq(Display.MaxAuras(Data(Trigger({secretShowOn = "showOnMissing"}), {blizzardAuraDisplay = {maxIcons = 3}})), 1, "max one element")
  Eq(Display.MaxAuras(Data(Trigger({secretUseTotal = true, secretTotal = 5}), {blizzardAuraDisplay = {maxIcons = 3}})), 10, "max with gate")
  -- Flow group from the parent
  local flowGroup = {id = "Flow Group", regionType = "group", blizzardFlow = true, blizzardFlowUseLimit = true, blizzardFlowLimit = 4}
  local realGetData = WeakAuras.GetData
  Override(WeakAuras, "GetData", function(id)
    if id == "Flow Group" then return flowGroup end
    return realGetData(id)
  end)
  local flowData = Data(Trigger(), {parent = "Flow Group", blizzardAuraDisplay = {maxIcons = 3}})
  Eq(Display.MaxAuras(flowData), 4, "max flow limit")
  Eq(Display.Growth(flowData), Display.VisibleGrowth((Display.FlowGrowth(flowData))), "growth flow")
  Eq(Display.MaxAuras(Data(Trigger({secretShowOn = "showOnMissing"}), {parent = "Flow Group"})), 1, "max one element in flow")
  -- Fallback is impossible in a flow group
  local flowFallback = Data(Trigger({secretShowOn = "showOnMissing"}), {parent = "Flow Group"})
  flowFallback.triggers[2] = {trigger = {type = "aura2"}}
  Eq(Display.Fallback(flowFallback), nil, "fallback impossible in flow")
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)

  -- SingleIcon
  Eq(Display.SingleIcon(Data(Trigger(), {iconSource = 0, displayIcon = "Interface\\Icons\\Custom"})), "Interface\\Icons\\Custom", "icon manual")
  Eq(Display.SingleIcon(Data(Trigger(), {iconSource = 0, displayIcon = ""})), 134400, "icon manual empty")
  Eq(Display.SingleIcon(Data(Trigger(), {iconSource = -1, displayIcon = "x"})), 134400, "icon manual source off")
  Override(C_Spell, "GetSpellTexture", function(spellId) return spellId == 4242 and 5555 or nil end)
  Eq(Display.SingleIcon(Data(Trigger({auraspellids = {4242}}))), 5555, "icon spell")
  Eq(Display.SingleIcon(Data(Trigger({auraspellids = {4243}}))), 134400, "icon unknown spell")
  Override(C_Spell, "GetSpellTexture", function() return test.Secret.Wrap(777) end)
  Eq(Display.SingleIcon(Data(Trigger({auraspellids = {4242}}))), 134400, "icon secret texture")
  RestoreAll()

  -- SingleUnitExists
  Eq(Display.SingleUnitExists(nil), true, "exists nil trigger")
  Eq(Display.SingleUnitExists({unit = "player"}), true, "exists player")
  Eq(Display.SingleUnitExists({unit = "member"}), false, "exists member without unit")
  local existing = {}
  Override(_G, "UnitExists", function(unit) return existing[unit] == true end)
  Eq(Display.SingleUnitExists({unit = "target"}), false, "exists target absent")
  existing.target = true
  Eq(Display.SingleUnitExists({unit = "target"}), true, "exists target present")
  Override(_G, "UnitExists", function() error("boom") end)
  Eq(Display.SingleUnitExists({unit = "target"}), true, "exists on error")
  Override(_G, "UnitExists", function() return test.Secret.Wrap(false) end)
  Eq(Display.SingleUnitExists({unit = "focus"}), true, "exists secret")
  RestoreAll()

  -- InDynamicGroup
  local groups = {
    ["Dyn Group"] = {id = "Dyn Group", regionType = "dynamicgroup"},
    ["Plain Group"] = {id = "Plain Group", regionType = "group", parent = "Dyn Group"},
    ["Flat Group"] = {id = "Flat Group", regionType = "group"},
  }
  Override(WeakAuras, "GetData", function(id) return groups[id] or realGetData(id) end)
  Eq(Display.InDynamicGroup({parent = "Dyn Group"}), true, "dynamic parent")
  Eq(Display.InDynamicGroup({parent = "Plain Group"}), true, "dynamic grandparent")
  Eq(Display.InDynamicGroup({parent = "Flat Group"}), false, "plain group")
  Eq(Display.InDynamicGroup({parent = "Missing Group"}), false, "missing parent")
  Eq(Display.InDynamicGroup({}), false, "no parent")
  RestoreAll()

  -- FitsOneSlot is dead code today; its rule is kept until it is deleted.
  if Display.FitsOneSlot then
    Eq(Display.FitsOneSlot({anchorFrameType = "SCREEN"}, Trigger()), true, "fits slot")
    Eq(Display.FitsOneSlot({anchorFrameType = "NAMEPLATE"}, Trigger()), false, "fits slot nameplate")
    Eq(Display.FitsOneSlot({}, nil), false, "fits slot without trigger")
  end

  do
  -- Migrations
  local old = Trigger({secretTracking = "single", matchesShowOn = "showOnMissing", useRem = true, remOperator = ">=", rem = 4})
  local oldData = Data(old, {blizzardAuraDisplay = nil})
  Display.MigrateSingle(oldData, old)
  Eq(old.secretTracking, nil, "tracking cleared")
  Eq(old.secretShowOn, "showOnMissing", "show on migrated")
  Eq(old.secretUseRem, true, "remaining migrated")
  Eq(old.secretRemOperator, ">=", "remaining operator migrated")
  Eq(old.secretRem, 4, "remaining seconds migrated")
  Eq(oldData.blizzardAuraDisplay.maxIcons, 1, "max icons forced to 1")
  Eq(old.matchesShowOn, "showOnMissing", "legacy field kept")
  local keep = Trigger({secretTracking = "single", matchesShowOn = "showOnMissing", secretShowOn = "showAlways", secretUseRem = false, useRem = true})
  Display.MigrateSingle(Data(keep), keep)
  Eq(keep.secretShowOn, "showAlways", "show on kept")
  Eq(keep.secretUseRem, false, "use remaining kept")
  local activeLegacy = Trigger({secretTracking = "single", matchesShowOn = "showOnActive"})
  Display.MigrateSingle(Data(activeLegacy), activeLegacy)
  Eq(activeLegacy.secretShowOn, nil, "legacy show on active not copied")
  local other = Trigger({secretTracking = "multi"})
  local otherData = Data(other)
  Display.MigrateSingle(otherData, other)
  Eq(other.secretTracking, nil, "other tracking cleared")
  Eq(otherData.blizzardAuraDisplay.maxIcons, nil, "other tracking leaves max icons")
  local untouched = Trigger({matchesShowOn = "showOnMissing"})
  Display.MigrateSingle(Data(untouched), untouched)
  Eq(untouched.secretShowOn, nil, "no tracking, no migration")

  local exact = Trigger({secretExactDuration = true, secretDuration = 12, maxDuration = 30})
  Display.MigrateTotal(exact)
  Eq(exact.secretUseTotal, true, "exact total")
  Eq(exact.secretTotalOperator, "=", "exact operator")
  Eq(exact.secretTotal, "12", "exact total text")
  Eq(exact.maxDuration, nil, "max duration cleared")
  Eq(exact.secretExactDuration, nil, "exact flag cleared")
  Eq(exact.secretDuration, nil, "duration cleared")
  local atMost = Trigger({maxDuration = 30})
  Display.MigrateTotal(atMost)
  Eq(atMost.secretUseTotal, true, "max total")
  Eq(atMost.secretTotalOperator, "<=", "max operator")
  Eq(atMost.secretTotal, "30", "max total text")
  local already = Trigger({secretUseTotal = false, maxDuration = 30, secretDuration = 5, secretExactDuration = true})
  Display.MigrateTotal(already)
  Eq(already.secretUseTotal, false, "existing total flag kept")
  Eq(already.secretTotal, nil, "existing total flag, no copy")
  Eq(already.maxDuration, nil, "existing flag still clears max")
  Eq(already.secretDuration, nil, "existing flag still clears duration")
  local noNumber = Trigger({secretExactDuration = true, secretDuration = "x"})
  Display.MigrateTotal(noNumber)
  Eq(noNumber.secretUseTotal, nil, "exact without number")

  local migrateFallbackData = {triggers = {
    {trigger = Trigger({secretMissingSource = "2"})}, {trigger = Trigger({secretMissingSource = 3})}, {trigger = {type = "x"}}, "junk",
  }}
  Display.MigrateFallback(migrateFallbackData)
  Eq(migrateFallbackData.triggers.secretFallback, 2, "first source wins")
  Eq(migrateFallbackData.triggers[1].trigger.secretMissingSource, nil, "source 1 cleared")
  Eq(migrateFallbackData.triggers[2].trigger.secretMissingSource, nil, "source 2 cleared")
  local keepFallback = {triggers = {secretFallback = "none", {trigger = Trigger({secretMissingSource = "2"})}}}
  Display.MigrateFallback(keepFallback)
  Eq(keepFallback.triggers.secretFallback, "none", "existing fallback kept")
  Eq(keepFallback.triggers[1].trigger.secretMissingSource, nil, "source cleared anyway")
  local textSource = {triggers = {{trigger = Trigger({secretMissingSource = "abc"})}}}
  Display.MigrateFallback(textSource)
  Eq(textSource.triggers.secretFallback, nil, "non numeric source")
  Eq(textSource.triggers[1].trigger.secretMissingSource, nil, "non numeric source cleared")
  Display.MigrateFallback({})

  -- Fallback choice and follow
  local function FallbackData(trigger, extra, secondType)
    local data = Data(trigger, extra)
    data.triggers[2] = {trigger = {type = secondType or "aura2"}}
    return data
  end
  local missing = Trigger({secretShowOn = "showOnMissing"})
  local fallbackData = FallbackData(missing)
  Eq(Display.FallbackChoice(fallbackData), "next", "choice default")
  Eq(Display.Fallback(fallbackData), "next", "fallback next")
  fallbackData.triggers.secretFallback = 2
  Eq(Display.FallbackChoice(fallbackData), 2, "choice number")
  Eq(Display.Fallback(fallbackData), 2, "fallback number")
  fallbackData.triggers.secretFallback = "2"
  Eq(Display.FallbackChoice(fallbackData), 2, "choice numeric text")
  fallbackData.triggers.secretFallback = 1
  Eq(Display.Fallback(fallbackData), nil, "fallback is the driver")
  Has(Display.FallbackProblem(fallbackData), "Trigger Combination", "driver choice is a problem (secretAura target)")
  fallbackData.triggers.secretFallback = 3
  Eq(Display.Fallback(fallbackData), nil, "fallback missing trigger")
  Has(Display.FallbackProblem(fallbackData), "Trigger Combination", "fallback problem")
  fallbackData.triggers.secretFallback = "none"
  Eq(Display.FallbackChoice(fallbackData), "none", "choice none")
  Eq(Display.Fallback(fallbackData), nil, "fallback none")
  Eq(Display.FallbackProblem(fallbackData), nil, "none is no problem")
  fallbackData.triggers.secretFallback = "garbage"
  Eq(Display.FallbackChoice(fallbackData), "next", "choice garbage")
  fallbackData.triggers.secretFallback = nil
  fallbackData.triggers[2].trigger.type = "secretAura"
  Eq(Display.Fallback(fallbackData), nil, "next needs a followable trigger")
  fallbackData.triggers.secretFallback = 2
  Has(Display.FallbackProblem(fallbackData), "Trigger Combination", "secretAura target is a problem")
  Eq(Display.Fallback(Data(missing)), "next" and nil, "fallback without other trigger")
  Eq(Display.Fallback(FallbackData(missing, {regionType = "model"})), nil, "fallback region type")
  Eq(Display.Fallback(FallbackData(missing, {anchorFrameType = "UNITFRAME"})), nil, "fallback anchored to unit frame")
  Eq(Display.Fallback(FallbackData(missing, {anchorFrameType = "NAMEPLATE"})), nil, "fallback anchored to nameplate")
  Eq(Display.Fallback(FallbackData(Trigger({unit = "party", secretShowOn = "showOnMissing"}))), nil, "fallback group unit")
  Eq(Display.Fallback(FallbackData(Trigger({secretUseRem = true, secretRem = 3}))), nil, "fallback with remaining on found")
  Eq(Display.Fallback(FallbackData(Trigger({secretUseRem = true, secretShowOn = "showAlways"}))), "next", "remaining ignored when always")
  Eq(Display.Fallback(fallbackData, "bad"), nil, "fallback bad trigger")
  Eq(Display.FoundFollow(FallbackData(Trigger())), "next", "found follow")
  Eq(Display.FoundFollow(FallbackData(missing)), nil, "found follow only on found")
  Eq(Display.MissingSource(FallbackData(missing)), "next", "missing source missing")
  Eq(Display.MissingSource(FallbackData(Trigger({secretShowOn = "showAlways"}))), "next", "missing source always")
  Eq(Display.MissingSource(FallbackData(Trigger())), "next", "missing source found")
  Eq(Display.MissingSource(FallbackData(Trigger()), "bad"), nil, "missing source bad trigger")

  -- SpellIDFilterNote
  local function Severity(extra) return Display.SpellIDFilterNote(Trigger(extra)) end
  Eq(Severity({debuffType = "HARMFUL"}), nil, "note without ids")
  local severity, message = Severity({debuffType = "HARMFUL", auraspellids = {910001}})
  Eq(severity, "error", "debuff on player")
  Has(message, "Approximate Match", "debuff on player advice")
  severity, message = Severity({debuffType = "HARMFUL", unit = "pet", auraspellids = {910001}})
  Eq(severity, "error", "debuff on pet")
  severity, message = Severity({debuffType = "HELPFUL", unit = "boss", auraspellids = {910001}})
  Eq(severity, "error", "buff on boss")
  Has(message, "buffs", "buff on boss text")
  assert(not message:find("Approximate", 1, true), "buff on boss mentions Approximate")
  severity, message = Severity({debuffType = "HARMFUL", unit = "arena", auraspellids = {910001}})
  Eq(severity, nil, "debuff on arena is fine")
  Eq(Severity({debuffType = "HELPFUL", auraspellids = {910001}}), nil, "buff on player is fine")
  severity, message = Severity({debuffType = "HARMFUL", unit = "target", auraspellids = {910001}})
  Eq(severity, "note", "debuff on target")
  Has(message, "hostile", "debuff target note")
  severity, message = Severity({debuffType = "HELPFUL", unit = "target", auraspellids = {910001}})
  Eq(severity, "note", "buff on target")
  Has(message, "friendly", "buff target note")
  Eq(Severity({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {910001}}), nil, "note skipped for approximate")
  severity = Severity({debuffType = "HARMFUL", excludedAuraSpellIDs = {910002, "x"}, secretUseExcludedSpellIDs = true})
  Eq(severity, "error", "excluded ids count")
  Eq(Severity({debuffType = "HARMFUL", unit = "party", auraspellids = {910001}}), "error", "debuff on party")
  severity = Severity({debuffType = "HARMFUL", unit = "member", specificUnit = "party1", auraspellids = {910001}})
  Eq(severity, "error", "debuff on specific party member")
  local neverSecretLevel = 0
  if Enum.SecrecyLevel and Enum.SecrecyLevel.NeverSecret ~= nil then neverSecretLevel = Enum.SecrecyLevel.NeverSecret
  else Override(Enum, "SecrecyLevel", {NeverSecret = 0}) end
  Override(C_Secrets, "GetSpellAuraSecrecy", function() return neverSecretLevel end)
  Eq(Severity({debuffType = "HARMFUL", auraspellids = {910101, 910102}}), nil, "never secret ids give no note")
  Override(C_Secrets, "GetSpellAuraSecrecy", function(spellId) if spellId == 910202 then return neverSecretLevel + 1 end return neverSecretLevel end)
  Eq(Severity({debuffType = "HARMFUL", auraspellids = {910201, 910202}}), "error", "one secret id gives the note")
  Override(C_Secrets, "GetSpellAuraSecrecy", function() error("denied") end)
  Eq(Severity({debuffType = "HARMFUL", auraspellids = {910301}}), "error", "secrecy error counts as secret")
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)

  -- TriggerStatus (Display.Validate replaced; the validation steps are covered below)
  local calmData = Data(Trigger())
  Override(Display, "Validate", function() return "broken thing" end)
  local text = Display.TriggerStatus(calmData, Trigger())
  Has(text, "|cffff2020Won't work:|r broken thing", "status validate problem")
  Override(Display, "Validate", function() return nil end)
  Eq(Display.TriggerStatus(calmData, Trigger()), "|cff33ff99Fully usable in combat.|r", "status plain")
  text = Display.TriggerStatus(calmData, Trigger({debuffType = "HARMFUL", auraspellids = {911001}}))
  Has(text, "|cffff2020Won't work:|r", "status error")
  Has(text, "|cffff9933Sounds in Actions still play.|r", "status error sounds")
  text = Display.TriggerStatus(calmData, Trigger({debuffType = "HARMFUL", unit = "target", auraspellids = {911001}}))
  Has(text, "|cff33ff99Fully usable in combat.|r", "status note keeps usable")
  Has(text, "|cffff9933Hostile units only.|r", "status hostile note")
  text = Display.TriggerStatus(calmData, Trigger({debuffType = "HELPFUL", unit = "target", auraspellids = {911001}}))
  Has(text, "Friendly units only.", "status friendly note")
  Override(WeakAuras, "GetData", function(id) return groups[id] or realGetData(id) end)
  text = Display.TriggerStatus(Data(Trigger(), {parent = "Dyn Group"}), Trigger())
  Has(text, "Dynamic Group", "status dynamic group")
  RestoreAll()
  Override(Display, "Validate", function() return nil end)
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  local approx = Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {911101}})
  Has(Display.TriggerStatus(calmData, approx), "|cffff2020Won't work:|r", "status approximate without profile")
  WeakAurasSaved.auraProfiles = {[911101] = {duration = 12}}
  text = Display.TriggerStatus(calmData, approx)
  Has(text, "Fully usable in combat.", "status approximate with profile")
  Has(text, "Approximate match, may not be exact.", "status approximate exact-ish")
  Override(Enum, "DurationTextBindingProperty", {RemainingDuration = 1})
  text = Display.TriggerStatus(calmData, approx)
  Has(text, "shorter debuffs", "status approximate without client support")
  RestoreAll()
  WeakAurasSaved.auraProfiles = nil

  -- ValidateSingle order and messages (the gate steps need the harness features restored)
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)
  local function Validate(extraTrigger, extraData)
    local trigger = Trigger(extraTrigger)
    local data = Data(trigger, extraData)
    return Display.ValidateSingle(data, trigger), data, trigger
  end
  Eq((Validate()), nil, "validate plain")
  Has((Validate({secretShowOn = "showOnMissing", secretUseTotal = true, secretTotal = 5, secretUseStacks = true, secretStacks = 3})),
    "Total Duration", "validate total before stacks")
  Has((Validate({secretShowOn = "showOnMissing", secretUseStacks = true, secretStacks = 3})), "Stack Count only works", "validate stack before fallback")
  Has((Validate({secretUseStacks = true, secretStacks = 3}, {anchorFrameType = "UNITFRAME"})), "Stack Count can't anchor", "validate stack anchor")
  local fallbackIssue = Validate({}, {})
  Eq(fallbackIssue, nil, "validate baseline")
  local brokenFallback = Data(Trigger())
  brokenFallback.triggers.secretFallback = 5
  Has(Display.ValidateSingle(brokenFallback, brokenFallback.triggers[1].trigger), "Trigger Combination", "validate fallback")
  local glowCondition = {{check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 5}, changes = {{property = "sub.1.glow", value = true}}}}
  Has((Validate({}, {regionType = "aurabar", conditions = glowCondition, subRegions = {{type = "subglow", glow = true}}})),
    "needs an Icon display", "validate glow on bar")
  Eq((Validate({}, {regionType = "icon", conditions = glowCondition, subRegions = {{type = "subglow", glow = true}}})), nil, "validate glow on icon")
  Has((Validate({secretShowOn = "showOnMissing", unit = "party"})), "watch one unit", "validate unit")
  Has((Validate({secretUseRem = true, secretRem = "x"})), "Remaining Time: pick a comparison", "validate remaining without window")
  Has((Validate({secretUseRem = true, secretRem = "x"}, {regionType = "aurabar"})), "Remaining Time: pick a comparison", "validate remaining gate window")
  Has((Validate({secretShowOn = "showOnMissing"}, {anchorFrameType = "UNITFRAME"})), "Show On: Aura(s) Missing cannot anchor", "validate missing anchor")
  Has((Validate({secretShowOn = "showAlways"}, {anchorFrameType = "NAMEPLATE"})), "Show On: Always cannot anchor", "validate always anchor")
  Has((Validate({secretShowOn = "showOnMissing"}, {regionType = "model"})), "available for Icon, Bar, Progress Texture and Text", "validate missing region type")
  Eq((Validate({secretShowOn = "showOnMissing"}, {regionType = "aurabar"})), nil, "validate missing bar")
  Has((Validate({secretUseRem = true, secretRem = 3}, {anchorFrameType = "UNITFRAME"})), "Remaining Time cannot anchor", "validate remaining anchor")
  Has((Validate({secretShowOn = "showOnMissing", debuffType = "HARMFUL", auraspellids = {912001}})), "hides your own and your pet's debuffs from spell ID lookup", "validate player debuff missing")
  Eq((Validate({secretShowOn = "showOnMissing", debuffType = "HARMFUL", secretApproximate = true, auraspellids = {912001}})), nil,
    "validate player debuff missing approximate")
  Eq((Validate({secretShowOn = "showOnMissing", debuffType = "HARMFUL", unit = "target", auraspellids = {912001}})), nil, "validate target debuff missing")
  Eq((Validate({secretUseRem = true, secretRem = 3})), nil, "validate window")
  local percentConditions = {{check = {trigger = 1, variable = "faAuraRemainingPercent", op = "<", value = 50}, changes = {}}}
  Has((Validate({secretUseRem = true, secretRem = 3}, {conditions = percentConditions})), "Countdown conditions used with Remaining Time", "validate window with percent condition")
  local secondsConditions = {{check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 50}, changes = {}}}
  Eq((Validate({secretUseRem = true, secretRem = 3}, {conditions = secondsConditions})), nil, "validate window with seconds condition")
  Eq((Validate({secretShowOn = "showOnMissing"}, {conditions = percentConditions})), nil, "percent condition fine without window")
  Override(C_CurveUtil, "CreateColorCurve", nil)
  Has((Validate({secretUseRem = true, secretRem = 3})), "Remaining Time filtering is not available", "validate window without client support")
  RestoreAll()

  -- TotalFilter, UsesApproximate
  local operator2, seconds2 = Display.TotalFilter(Trigger({secretUseTotal = true, secretTotal = "5"}))
  Eq(operator2, "=", "total default operator")
  Eq(seconds2, 5, "total seconds")
  Eq((Display.TotalFilter(Trigger({secretUseTotal = true, secretTotal = 5, secretTotalOperator = "<="}))), "<=", "total <=")
  Eq(Display.TotalFilter(Trigger({secretUseTotal = true, secretTotal = 0})), nil, "total zero")
  Eq(Display.TotalFilter(Trigger({secretUseTotal = true, secretTotal = 5, secretTotalOperator = ">"})), nil, "total bad operator")
  Eq(Display.TotalFilter(Trigger({secretUseTotal = true, secretTotal = math.huge})), nil, "total infinite")
  Eq(Display.TotalFilter(Trigger({secretTotal = 5})), nil, "total off")
  Eq(Display.TotalFilter("x"), nil, "total not a table")
  Eq(Display.UsesApproximate(approx), true, "approximate")
  Eq(Display.UsesApproximate(Trigger({secretApproximate = true, debuffType = "HARMFUL"})), false, "approximate needs ids")
  Eq(Display.UsesApproximate(Trigger({secretApproximate = true, debuffType = "HELPFUL", auraspellids = {1}})), false, "approximate needs debuff")
  Eq(Display.UsesApproximate(Trigger({secretApproximate = true, debuffType = "HARMFUL", unit = "target", auraspellids = {1}})), false, "approximate needs group unit")
  Eq(Display.UsesApproximate(Trigger({secretApproximate = 1, debuffType = "HARMFUL", auraspellids = {1}})), false, "approximate needs true")
  Eq(Display.UsesApproximate(Trigger({secretApproximate = true, debuffType = "HARMFUL", unit = "raid", secretUseRankSpellIDs = true, auraRankSpellIDs = {5}})),
    true, "approximate with ranks")
  Eq(Display.UsesApproximate(nil), false, "approximate nil")

  end

  -- Learned durations, described durations, profiles
  WeakAurasSaved.auraDurations, WeakAurasSaved.auraProfiles = nil, nil
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  local total, source = Display.LateGlowTotal(Trigger({secretUseTotal = true, secretTotal = 30, auraspellids = {913001}}))
  Eq(total, 30, "late total manual")
  Eq(source, "manual", "late total manual source")
  Eq(Display.LateGlowTotal(Trigger({auraspellids = {913001}})), nil, "late total unknown")
  WeakAurasSaved.auraDurations = {[913001] = 45.5, [913002] = "12.5"}
  total, source = Display.LateGlowTotal(Trigger({auraspellids = {913001, 913002}}))
  Near(total, 45.5, "late total seen")
  Eq(source, "seen", "late total seen source")
  total, source = Display.LateGlowTotal(Trigger({secretUseTotal = true, secretTotal = 30, secretTotalOperator = "<=", auraspellids = {913002}}))
  Near(total, 12.5, "late total seen with <= filter")
  Eq(source, "seen", "late total seen with <= filter source")
  WeakAurasSaved.auraDurations = nil
  local descriptions = {[913101] = "Lasts 2.5 sec.", [913102] = "Deals damage. Lasts 10 seconds, then 1 min.", [913103] = "Nothing here.",
    [913104] = "Lasts 2 hours.", [913105] = "Lasts 1,5 minutes."}
  Override(C_Spell, "GetSpellDescription", function(spellId) return descriptions[spellId] or "" end)
  total, source = Display.LateGlowTotal(Trigger({auraspellids = {913101}}))
  Near(total, 2.5, "described seconds")
  Eq(source, "described", "described source")
  Near(Display.LateGlowTotal(Trigger({auraspellids = {913102}})), 60, "described longest")
  Eq(Display.LateGlowTotal(Trigger({auraspellids = {913103}})), nil, "described nothing")
  Near(Display.LateGlowTotal(Trigger({auraspellids = {913104}})), 7200, "described hours")
  Near(Display.LateGlowTotal(Trigger({auraspellids = {913105}})), 90, "described decimal comma")
  Near(Display.LateGlowTotal(Trigger({auraspellids = {913101, 913102}})), 60, "described maximum over ids")
  Override(C_Spell, "GetSpellDescription", function() return test.Secret.Wrap("Lasts 99 sec.") end)
  Eq(Display.LateGlowTotal(Trigger({auraspellids = {913106}})), nil, "described secret text ignored")
  RestoreAll()

  -- Description not loaded: one request, answer later through the event frame
  local requests = {}
  Override(C_Spell, "GetSpellDescription", function(spellId) return descriptions[spellId] or "" end)
  Override(C_Spell, "RequestLoadSpellData", function(spellId) requests[#requests + 1] = spellId end)
  local eventFrame
  for _, frame in ipairs(test.Frames.eventFrames) do
    local state = test.Frames.State[frame]
    if state.events.SPELL_DATA_LOAD_RESULT and state.events.PLAYER_TARGET_CHANGED and state.events.UNIT_AURA and state.events.PLAYER_REGEN_ENABLED then
      assert(not eventFrame, "several learning event frames")
      eventFrame = frame
    end
  end
  assert(eventFrame, "learning event frame not found")
  local function Fire(event, ...) test.Frames.State[eventFrame].scripts.OnEvent(eventFrame, event, ...) end
  local pendingTrigger = Trigger({auraspellids = {914001}})
  Eq(Display.LateGlowTotal(pendingTrigger), nil, "described pending")
  Eq(#requests, 1, "one load request")
  Eq(requests[1], 914001, "load request id")
  Display.LateGlowTotal(pendingTrigger)
  Eq(#requests, 1, "no second request while pending")
  descriptions[914001] = "Lasts 5 sec."
  Fire("SPELL_DATA_LOAD_RESULT", 914001)
  Near(Display.LateGlowTotal(pendingTrigger), 5, "described after load")
  Fire("SPELL_DATA_LOAD_RESULT", 914999)
  RestoreAll()

  -- ApproximateProfile and ApproximateFilters
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  local profileTrigger = Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915001, 915002}})
  WeakAurasSaved.auraProfiles = {
    [915001] = {duration = 10, dispel = "Magic", canApplyAura = true, isStealable = false, friendly = true},
    [915002] = {duration = 15, dispel = "Curse", canApplyAura = true, isStealable = true},
  }
  local profile, profileSource = Display.ApproximateProfile(profileTrigger)
  Eq(profileSource, "seen", "profile source")
  Eq(profile.duration, 15, "profile max duration")
  Eq(profile.dispel, nil, "profile dispel divergence")
  Eq(profile.canApplyAura, true, "profile shared flag")
  Eq(profile.isStealable, nil, "profile flag divergence")
  Eq(WeakAurasSaved.auraProfiles[915001].duration, 10, "stored profile untouched")
  Eq(WeakAurasSaved.auraProfiles[915001].dispel, "Magic", "stored dispel untouched")
  local manualTrigger = Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915001, 915002}, secretUseTotal = true, secretTotal = 20})
  profile, profileSource = Display.ApproximateProfile(manualTrigger)
  Eq(profileSource, "manual", "profile manual source")
  Eq(profile.duration, 20, "profile manual duration")
  manualTrigger.secretTotalOperator = ">="
  profile, profileSource = Display.ApproximateProfile(manualTrigger)
  Eq(profileSource, "manual", "profile manual >= source")
  Eq(profile.duration, nil, "profile manual >= has no duration")
  local blank = Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915003}, secretUseTotal = true, secretTotal = 8})
  profile, profileSource = Display.ApproximateProfile(blank)
  Eq(profileSource, "manual", "profile manual without learned data")
  Eq(profile.duration, 8, "profile manual without learned data duration")
  Eq(Display.ApproximateProfile(Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915004}})), nil, "profile unknown")
  descriptions[915005] = "Lasts 6 sec."
  Override(C_Spell, "GetSpellDescription", function(spellId) return descriptions[spellId] or "" end)
  profile, profileSource = Display.ApproximateProfile(Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915005}}))
  Eq(profileSource, "duration", "profile from description")
  Eq(profile.duration, 6, "profile described duration")
  Override(C_Spell, "GetSpellDescription", function() return "" end)

  local plainFilters = {maxDuration = 5}
  Eq(Display.ApproximateFilters(Trigger({auraspellids = {915001}}), plainFilters), plainFilters, "filters pass through")
  Eq(plainFilters.maxDuration, 5, "filters untouched without approximate")
  local unknownFilters = Display.ApproximateFilters(Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915004}}),
    {includeSpellIDs = {1}})
  Eq(#unknownFilters.includeSpellIDs, 0, "filters without profile match nothing")
  local filters = Display.ApproximateFilters(profileTrigger, {includeSpellIDs = {1}, excludeSpellIDs = {2}, isStealable = false})
  Eq(filters.includeSpellIDs, nil, "filters drop include")
  Eq(filters.excludeSpellIDs, nil, "filters drop exclude")
  Near(filters.maxDuration, 15.5, "filters max duration")
  Eq(filters.includeDispelTypes, nil, "filters diverging dispel dropped")
  Eq(filters.canApplyAura, true, "filters take shared flag")
  Eq(filters.isStealable, false, "filters keep existing flag")
  WeakAurasSaved.auraProfiles = {[915010] = {duration = 10, dispel = "Magic", isBossAura = true}}
  filters = Display.ApproximateFilters(Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915010}}), {maxDuration = 5})
  Near(filters.maxDuration, 5, "filters keep smaller max duration")
  Eq(filters.includeDispelTypes.Magic, true, "filters dispel")
  Eq(filters.isBossAura, true, "filters boss flag")
  WeakAurasSaved.auraProfiles = {[915011] = {dispel = "Magic"}}
  filters = Display.ApproximateFilters(Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {915011}}), {})
  Eq(filters.maxDuration, nil, "filters no duration, no max")
  WeakAurasSaved.auraProfiles = nil
  RestoreAll()

  -- Gates
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)
  local function Gate(extraTrigger, extraData)
    local trigger = Trigger(extraTrigger)
    local data = Data(trigger, extraData)
    return data, trigger
  end
  local data, trigger = Gate({secretUseTotal = true, secretTotal = 5})
  local lower, upper, gateSource, gateIssue = Display.GateRange(data, trigger)
  Near(lower, 4.5, "gate = lower")
  Near(upper, 5.5, "gate = upper")
  Eq(gateSource, "filter", "gate = source")
  Eq(gateIssue, nil, "gate = problem")
  lower, upper = Display.DurationGate(data, trigger)
  Near(lower, 4.5, "duration gate lower")
  Near(upper, 5.5, "duration gate upper")
  data, trigger = Gate({secretUseTotal = true, secretTotal = 5, secretTotalOperator = ">="})
  lower, upper, gateSource = Display.GateRange(data, trigger)
  Near(lower, 4.5, "gate >= lower")
  Eq(upper, nil, "gate >= has no upper")
  Eq(gateSource, "filter", "gate >= source")
  data, trigger = Gate({secretUseTotal = true, secretTotal = 0.2})
  Near((Display.GateRange(data, trigger)), 0.001, "gate lower floor")
  data, trigger = Gate({secretUseTotal = true, secretTotal = 5, secretTotalOperator = "<="})
  Eq(Display.GateRange(data, trigger), nil, "gate <= is a plain filter")
  Eq(Display.UsesGate(data), false, "no gate for <=")
  data, trigger = Gate({secretUseTotal = true, secretTotal = 5, secretShowOn = "showOnMissing"})
  lower, upper, gateSource, gateIssue = Display.GateRange(data, trigger)
  Eq(gateSource, "filter", "missing gate source")
  Has(gateIssue, "only work with Show On: Aura(s) Found", "missing gate problem")
  Eq(Display.DurationGate(data, trigger), nil, "problem hides the gate")
  Has(Display.TotalFilterProblem(data, trigger), "only work with Show On", "total filter problem")
  data, trigger = Gate({secretUseTotal = true, secretTotal = 5}, {anchorFrameType = "UNITFRAME"})
  Has(select(4, Display.GateRange(data, trigger)), "can't anchor", "gate anchor problem")
  Override(Enum, "DurationTextBindingProperty", {RemainingDuration = 1})
  data, trigger = Gate({secretUseTotal = true, secretTotal = 5})
  Has(select(4, Display.GateRange(data, trigger)), "This client can't check Total Duration", "gate client problem")
  Has(Display.TotalFilterProblem(data, trigger), "This client", "total filter client problem")
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  WeakAurasSaved.auraProfiles = {[916001] = {duration = 12}}
  data, trigger = Gate({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {916001}})
  lower, upper, gateSource, gateIssue = Display.GateRange(data, trigger)
  Near(lower, 11.5, "approximate gate lower")
  Near(upper, 12.5, "approximate gate upper")
  Eq(gateSource, "approximate", "approximate gate source")
  Eq(gateIssue, nil, "approximate gate problem")
  data, trigger = Gate({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {916001}}, {anchorFrameType = "UNITFRAME"})
  Eq(Display.TotalFilterProblem(data, trigger), nil, "approximate problem does not block validation")
  Eq(Display.DurationGate(data, trigger), nil, "approximate problem hides the gate")
  WeakAurasSaved.auraProfiles = nil
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)

  local function Stack(operator, count)
    return Display.StackFilter(Trigger({secretUseStacks = true, secretStacksOperator = operator, secretStacks = count}))
  end
  local kind, count = Stack("=", 3)
  Eq(kind, "exactly", "stack =")
  Eq(count, 3, "stack = count")
  kind, count = Stack(">=", 3)
  Eq(kind, "atLeast", "stack >=")
  Eq(count, 3, "stack >= count")
  kind, count = Stack(">", 3)
  Eq(kind, "atLeast", "stack >")
  Eq(count, 4, "stack > shifts up")
  kind, count = Stack("<=", 3)
  Eq(kind, "atMost", "stack <=")
  Eq(count, 3, "stack <= count")
  kind, count = Stack("<", 3)
  Eq(kind, "atMost", "stack <")
  Eq(count, 2, "stack < shifts down")
  Eq((Stack("<", 0)), "never", "stack < 0")
  Eq(Stack(">=", 0), nil, "stack >= 0 always true")
  kind, count = Stack("<=", 0)
  Eq(kind, "atMost", "stack <= 0")
  Eq(count, 0, "stack <= 0 count")
  kind, count = Stack(">", 100)
  Eq(kind, "atLeast", "stack > limit")
  Eq(count, 101, "stack > limit count")
  Eq(Stack(">=", 101), nil, "stack above limit")
  Eq(Stack(">=", 2.5), nil, "stack fraction")
  Eq(Stack(">=", -1), nil, "stack negative")
  Eq(Stack(">=", "x"), nil, "stack text")
  Eq(Stack("!=", 3), nil, "stack bad operator")
  Eq((Display.StackFilter(Trigger({secretUseStacks = true, secretStacks = 4}))), "atLeast", "stack default operator")
  Eq(Display.StackFilter(Trigger({secretStacks = 4})), nil, "stack off")

  local function StackIssue(extraTrigger, extraData)
    local stackTrigger = Trigger({secretUseStacks = true, secretStacksOperator = ">=", secretStacks = 3})
    for key, value in pairs(extraTrigger or {}) do stackTrigger[key] = value end
    return Display.StackFilterProblem(Data(stackTrigger, extraData), stackTrigger)
  end
  Eq(StackIssue(), nil, "stack problem none")
  Has(StackIssue({secretStacks = 101}), "whole number from 0 to 100", "stack problem range")
  Has(StackIssue({secretStacks = 2.5}), "whole number", "stack problem fraction")
  Has(StackIssue({secretStacksOperator = "<", secretStacks = 0}), "never matches", "stack problem never")
  Eq(StackIssue({secretStacksOperator = ">=", secretStacks = 0}), nil, "stack problem always true")
  Eq(StackIssue({secretStacksOperator = "!="}), nil, "stack problem bad operator")
  Has(StackIssue({}, {anchorFrameType = "NAMEPLATE"}), "Stack Count can't anchor", "stack problem anchor")
  Has(StackIssue({secretShowOn = "showAlways"}, {anchorFrameType = "NAMEPLATE"}), "Stack Count can't anchor", "stack problem anchor first")
  Has(StackIssue({secretShowOn = "showAlways"}), "only works with Show On: Aura(s) Found", "stack problem single")
  Has(StackIssue({secretUseTotal = true, secretTotal = 5}), "can't be combined", "stack problem total")
  Override(C_AuraContainerUtil, "ProcessCustomAuraButtonApplicationBarOptions", nil)
  Has(StackIssue(), "This client can't check Stack Count", "stack problem client")
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)
  local stackTrigger = Trigger({secretUseStacks = true, secretStacksOperator = "=", secretStacks = 2})
  kind, count = Display.StackGate(Data(stackTrigger), stackTrigger)
  Eq(kind, "exactly", "stack gate")
  Eq(count, 2, "stack gate count")
  local badStack = Trigger({secretUseStacks = true, secretStacks = 3, secretShowOn = "showAlways"})
  Eq(Display.StackGate(Data(badStack), badStack), nil, "stack gate blocked by problem")
  local neverStack = Trigger({secretUseStacks = true, secretStacksOperator = "<", secretStacks = 0})
  Eq(Display.StackGate(Data(neverStack), neverStack), nil, "stack gate never")
  Eq(Display.UsesGate(Data(stackTrigger)), true, "uses gate for stacks")

  local function Remaining(operator3, secondsValue, extraData)
    local remainingTrigger = Trigger({secretUseRem = true, secretRemOperator = operator3, secretRem = secondsValue})
    return Data(remainingTrigger, extraData or {regionType = "aurabar"}), remainingTrigger
  end
  local remainingData, remainingTrigger = Remaining("<", 5)
  lower, upper = Display.RemainingGateRange(remainingData, remainingTrigger)
  Near(lower, 0, "remaining < lower")
  Near(upper, 4.999, "remaining < upper")
  remainingData, remainingTrigger = Remaining("<=", 5)
  lower, upper = Display.RemainingGateRange(remainingData, remainingTrigger)
  Near(lower, 0, "remaining <= lower")
  Near(upper, 5, "remaining <= upper")
  remainingData, remainingTrigger = Remaining(">", 5)
  lower, upper = Display.RemainingGateRange(remainingData, remainingTrigger)
  Near(lower, 5.001, "remaining > lower")
  Eq(upper, nil, "remaining > has no upper")
  remainingData, remainingTrigger = Remaining(">=", 5)
  lower, upper = Display.RemainingGateRange(remainingData, remainingTrigger)
  Near(lower, 5, "remaining >= lower")
  Eq(upper, nil, "remaining >= has no upper")
  Eq(Display.UsesGate(remainingData), true, "uses gate for remaining on a bar")
  Eq(Display.MaxAuras(remainingData), 10, "max auras with remaining gate")
  remainingData, remainingTrigger = Remaining("<", 5, {regionType = "icon"})
  Eq(Display.RemainingGateRange(remainingData, remainingTrigger), nil, "no remaining gate on icons")
  Eq(Display.RemainingGateProblem(remainingData, remainingTrigger), nil, "no remaining problem on icons")
  Eq(Display.UsesGate(remainingData), false, "icon window needs no gate")
  remainingData, remainingTrigger = Remaining("<", "x")
  Has(Display.RemainingGateProblem(remainingData, remainingTrigger), "Remaining Time: pick a comparison", "remaining problem window")
  Eq(Display.RemainingGateRange(remainingData, remainingTrigger), nil, "remaining problem hides range")
  remainingData, remainingTrigger = Remaining("<", 5, {regionType = "aurabar", anchorFrameType = "UNITFRAME"})
  Has(Display.RemainingGateProblem(remainingData, remainingTrigger), "Remaining Time can't anchor", "remaining problem anchor")
  remainingData, remainingTrigger = Remaining("<", 5)
  remainingTrigger.secretUseTotal, remainingTrigger.secretTotal = true, 4
  Has(Display.RemainingGateProblem(remainingData, remainingTrigger), "can't be combined with Total Duration", "remaining problem total")
  remainingTrigger.secretUseTotal = nil
  Eq(Display.RemainingGateProblem(remainingData, remainingTrigger), nil, "remaining problem none")
  Override(Enum, "DurationTextBindingProperty", {TotalDuration = 2})
  Has(Display.RemainingGateProblem(remainingData, remainingTrigger), "This client can't check Remaining Time", "remaining problem client")
  RestoreAll()
  Override(Enum, "DurationTextBindingProperty", Enum.DurationTextBindingProperty)
  Eq(Display.RemainingGateProblem(Data(Trigger(), {regionType = "aurabar"}), Trigger()), nil, "remaining problem off")

  -- LateGlowSpec
  local glowElements = {{type = "subglow", glow = true}}
  local function Spec(extraTrigger, extraData)
    local specTrigger = Trigger(extraTrigger)
    local specData = Data(specTrigger, extraData)
    specData.subRegions = specData.subRegions or glowElements
    return Display.LateGlowSpec(specData, specTrigger)
  end
  local edge, element, index, above, elapsed = Spec({secretUseRem = true, secretRem = 5, secretRemOperator = "<="})
  Near(edge, 5.001, "spec <= edge")
  Eq(element, glowElements[1], "spec <= element")
  Eq(index, 1, "spec <= index")
  Eq(above, false, "spec <= below")
  Eq(elapsed, nil, "spec window is not elapsed")
  edge, _, _, above = Spec({secretUseRem = true, secretRem = 5, secretRemOperator = "<"})
  Near(edge, 5, "spec < edge")
  Eq(above, false, "spec < below")
  edge, _, _, above = Spec({secretUseRem = true, secretRem = 5, secretRemOperator = ">"})
  Near(edge, 5.001, "spec > edge")
  Eq(above, true, "spec > above")
  edge, _, _, above = Spec({secretUseRem = true, secretRem = 5, secretRemOperator = ">="})
  Near(edge, 5, "spec >= edge")
  Eq(above, true, "spec >= above")
  Eq(Spec({secretUseRem = true, secretRem = 5}, {subRegions = {{type = "subtext"}}}), nil, "spec window without glow element")
  Eq(Spec({secretUseRem = true, secretRem = 5}, {subRegions = {{type = "subglow", glow = false}}}), nil, "spec window with glow off")
  Eq(Spec({secretUseRem = true, secretRem = 5}, {regionType = "aurabar"}), nil, "spec on a bar")
  edge, element, index, above, elapsed = Spec({}, {conditions = {
    {check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 7}, changes = {{property = "sub.1.glow", value = true}}}}})
  Near(edge, 7, "spec condition edge")
  Eq(element, glowElements[1], "spec condition element")
  Eq(index, 1, "spec condition index")
  Eq(above, false, "spec condition below")
  Eq(elapsed, false, "spec remaining condition is not elapsed")
  _, _, _, _, elapsed = Spec({}, {conditions = {
    {check = {trigger = 1, variable = "faAuraElapsed", op = "<", value = 7}, changes = {{property = "sub.1.glow", value = true}}}}})
  Eq(elapsed, true, "spec elapsed condition")
  Eq(Spec({}, {conditions = {{check = {trigger = 1, variable = "faAuraRemaining", op = ">", value = 7}, changes = {{property = "sub.1.glow", value = true}}}}}),
    nil, "spec condition operator")
  Eq(Spec({}, {conditions = {{linked = true, check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 7}, changes = {{property = "sub.1.glow", value = true}}}}}),
    nil, "spec linked condition")
  Eq(Spec({}, {conditions = {{check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 0}, changes = {{property = "sub.1.glow", value = true}}}}}),
    nil, "spec zero edge")
  Eq(Spec({}, {conditions = {{check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 7}, changes = {{property = "sub.1.glow", value = false}}}}}),
    nil, "spec change off")
  Eq(Spec({}, {conditions = {{check = {trigger = 2, variable = "faAuraRemaining", op = "<", value = 7}, changes = {{property = "sub.1.glow", value = true}}}}}),
    nil, "spec foreign trigger")
  edge, _, index = Spec({}, {subRegions = {{type = "subtext"}, {type = "subglow", glow = true}}, conditions = {
    {check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 3}, changes = {{property = "sub.1.text_color", value = true}}},
    {check = {trigger = 1, variable = "faAuraRemaining", op = "<", value = 9}, changes = {{property = "sub.2.glow", value = true}}}}})
  Near(edge, 9, "spec scans later conditions")
  Eq(index, 2, "spec second glow index")

  -- TimedGlowHolder refusals
  local glowTrigger = Trigger({secretUseRem = true, secretRem = 5, secretRemOperator = "<="})
  local glowData = Data(glowTrigger)
  glowData.subRegions = glowElements
  local timedFrame = CreateFrame("Frame")
  Eq(Display.TimedGlowHolder({preview = true}, glowData, 1, timedFrame), nil, "holder in preview")
  Eq(Display.TimedGlowHolder({}, glowData, 2, timedFrame), nil, "holder wrong index")
  Eq(Display.TimedGlowHolder({}, Data(Trigger()), 1, timedFrame), nil, "holder without spec")
  WeakAurasSaved.auraDurations = nil
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  glowTrigger.auraspellids = {917001}
  Eq(Display.TimedGlowHolder({}, glowData, 1, timedFrame), false, "holder unknown total")
  WeakAurasSaved.auraDurations = {[917001] = 5}
  Eq(Display.TimedGlowHolder({}, glowData, 1, timedFrame), false, "holder total not above edge")
  WeakAurasSaved.auraDurations = nil
  RestoreAll()

  -- Learning through the event frame
  local learnTrigger = Trigger({auraspellids = {918001}})
  local learnData = Data(learnTrigger, {id = "Learn Aura"})
  local learnRegion = {}
  local applied = {}
  Override(Display, "Apply", function(region, auraData) applied[#applied + 1] = {region, auraData} end)
  Override(WeakAuras, "GetData", function(id) if id == "Learn Aura" then return learnData end return realGetData(id) end)
  local scanAuras = {}
  Override(C_UnitAuras, "GetAuraDataByIndex", function(unit, slot, filter)
    local list = scanAuras[unit .. ":" .. filter]
    return list and list[slot]
  end)
  WeakAurasSaved.auraDurations, WeakAurasSaved.auraProfiles = {}, {}
  Display.WatchAuraLearning(learnRegion, learnData, learnTrigger, true)
  scanAuras["target:HELPFUL"] = {{spellId = 918001, duration = 12.34, isHarmful = false}}
  Fire("PLAYER_TARGET_CHANGED")
  Near(WeakAurasSaved.auraDurations[918001], 12.3, "learned duration rounded to tenths")
  Eq(#applied, 1, "region reapplied after a change")
  Eq(applied[1][1], learnRegion, "reapplied region")
  Eq(applied[1][2], learnData, "reapplied data")
  Fire("PLAYER_TARGET_CHANGED")
  Eq(#applied, 1, "no reapply without a change")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918001, duration = 7.77, isHarmful = false}}})
  Near(WeakAurasSaved.auraDurations[918001], 7.8, "learned from added aura")
  Eq(#applied, 2, "reapplied after added aura")
  Fire("UNIT_AURA", "nameplate1", {addedAuras = {{spellId = 918001, duration = 9, isHarmful = false}}})
  Near(WeakAurasSaved.auraDurations[918001], 7.8, "enemy nameplate ignored")
  Fire("UNIT_AURA", "party2", {addedAuras = {{spellId = 918001, duration = 9, isHarmful = false}}})
  Near(WeakAurasSaved.auraDurations[918001], 9, "party member learned")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918001, duration = test.Secret.Wrap(30), isHarmful = false}}})
  Near(WeakAurasSaved.auraDurations[918001], 9, "secret duration ignored")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918001, duration = 0, isHarmful = false}}})
  Near(WeakAurasSaved.auraDurations[918001], 9, "zero duration ignored")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918002, duration = 5, isHarmful = false}}})
  Eq(WeakAurasSaved.auraDurations[918002], nil, "unwatched spell ignored")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918001, duration = 4, isHarmful = test.Secret.Wrap(false)}}})
  Near(WeakAurasSaved.auraDurations[918001], 9, "secret harmful flag skips the aura")
  Override(C_UnitAuras, "GetAuraDataByAuraInstanceID", function(unit, instanceId)
    if instanceId == 11 then return {spellId = 918001, duration = 20, isHarmful = false} end
    error("denied")
  end)
  Fire("UNIT_AURA", "player", {updatedAuraInstanceIDs = {12, 11}})
  Near(WeakAurasSaved.auraDurations[918001], 20, "updated aura read, error skipped")
  scanAuras["player:HELPFUL"] = {{spellId = 918001, duration = 25, isHarmful = false}, "not a table", {spellId = 918001, duration = 99}}
  Fire("UNIT_AURA", "player", {isFullUpdate = true})
  Near(WeakAurasSaved.auraDurations[918001], 25, "full update scans slots until a non table")
  Override(WeakAuras, "IsRestricted", function() return true end)
  scanAuras["player:HELPFUL"] = {{spellId = 918001, duration = 33, isHarmful = false}}
  Fire("UNIT_AURA", "player", {isFullUpdate = true})
  Near(WeakAurasSaved.auraDurations[918001], 25, "no learning while restricted")
  RestoreAll()
  -- restore what the block above needs after RestoreAll
  Override(Display, "Apply", function(region, auraData) applied[#applied + 1] = {region, auraData} end)
  Override(WeakAuras, "GetData", function(id) if id == "Learn Aura" then return learnData end return realGetData(id) end)
  Override(C_UnitAuras, "GetAuraDataByIndex", function(unit, slot, filter)
    local list = scanAuras[unit .. ":" .. filter]
    return list and list[slot]
  end)
  Display.ReleaseAuraLearning(learnRegion)
  Fire("PLAYER_TARGET_CHANGED")
  scanAuras["target:HELPFUL"] = {{spellId = 918001, duration = 50, isHarmful = false}}
  Fire("PLAYER_TARGET_CHANGED")
  Near(WeakAurasSaved.auraDurations[918001], 25, "released region learns nothing")

  -- Region replaced while waiting: released, not reapplied
  local staleRegion, staleData = {}, Data(Trigger({auraspellids = {918101}}), {id = "Stale Aura"})
  WeakAurasSaved.auraDurations = {}
  Display.WatchAuraLearning(staleRegion, staleData, staleData.triggers[1].trigger, true)
  local appliedBefore = #applied
  scanAuras["target:HELPFUL"] = {{spellId = 918101, duration = 6, isHarmful = false}}
  Fire("PLAYER_TARGET_CHANGED")
  Near(WeakAurasSaved.auraDurations[918101], 6, "stale region still learns")
  Eq(#applied, appliedBefore, "stale region not reapplied")
  scanAuras["target:HELPFUL"] = {{spellId = 918101, duration = 8, isHarmful = false}}
  Fire("PLAYER_TARGET_CHANGED")
  Near(WeakAurasSaved.auraDurations[918101], 6, "stale region released")
  scanAuras["target:HELPFUL"] = nil

  -- Profiles
  local profileRegion = {}
  local profileLearnTrigger = Trigger({debuffType = "HARMFUL", secretApproximate = true, auraspellids = {918201}})
  local profileData = Data(profileLearnTrigger, {id = "Profile Aura"})
  WeakAurasSaved.auraProfiles = {}
  Override(WeakAuras, "GetData", function(id) if id == "Profile Aura" then return profileData end return realGetData(id) end)
  Display.WatchAuraLearning(profileRegion, profileData, profileLearnTrigger, nil)
  local harmfulAura = {spellId = 918201, duration = 15.04, isHarmful = true, dispelName = "Magic", canApplyAura = true, isStealable = false,
    isBossAura = test.Secret.Wrap(true)}
  Fire("UNIT_AURA", "player", {addedAuras = {harmfulAura}})
  local learned = WeakAurasSaved.auraProfiles[918201]
  assert(learned, "profile not learned")
  Near(learned.duration, 15, "profile duration")
  Eq(learned.friendly, true, "profile friendly")
  Eq(learned.dispel, "Magic", "profile dispel")
  Eq(learned.canApplyAura, true, "profile flag")
  Eq(learned.isStealable, false, "profile false flag")
  Eq(learned.isBossAura, nil, "profile secret flag skipped")
  Eq(WeakAurasSaved.auraDurations[918201], nil, "profile aura is not a glow duration")
  Fire("UNIT_AURA", "target", {addedAuras = {{spellId = 918201, duration = 30, isHarmful = true, dispelName = "Curse", canApplyAura = false}}})
  Near(WeakAurasSaved.auraProfiles[918201].duration, 15, "hostile does not overwrite friendly profile")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918201, duration = 20, isHarmful = false}}})
  Near(WeakAurasSaved.auraProfiles[918201].duration, 15, "beneficial aura ignored for profiles")
  Fire("UNIT_AURA", "player", {addedAuras = {{spellId = 918201, duration = 0, isHarmful = true}}})
  Near(WeakAurasSaved.auraProfiles[918201].duration, 0, "zero duration profile accepted")
  Eq(WeakAurasSaved.auraProfiles[918201].dispel, nil, "profile replaced as a whole")
  WeakAurasSaved.auraProfiles = {}
  Fire("UNIT_AURA", "target", {addedAuras = {{spellId = 918201, duration = 30, isHarmful = true, dispelName = "Curse", canApplyAura = false}}})
  learned = WeakAurasSaved.auraProfiles[918201]
  Near(learned.duration, 30, "hostile profile")
  Eq(learned.friendly, nil, "hostile profile not friendly")
  Eq(learned.dispel, "Curse", "hostile profile dispel")
  Eq(learned.canApplyAura, nil, "hostile profile has no flags")
  Display.ReleaseAuraLearning(profileRegion)

  -- Spell data arrives during combat: reapply after the fight
  local combatRegion = {}
  local combatTrigger = Trigger({auraspellids = {918301}})
  local combatData = Data(combatTrigger, {id = "Combat Aura"})
  Override(WeakAuras, "GetData", function(id) if id == "Combat Aura" then return combatData end return realGetData(id) end)
  Override(C_Spell, "GetSpellDescription", function() return "" end)
  Override(C_Spell, "RequestLoadSpellData", function() end)
  Display.WatchAuraLearning(combatRegion, combatData, combatTrigger, true)
  Display.LateGlowTotal(combatTrigger)
  local inCombat = true
  Override(_G, "InCombatLockdown", function() return inCombat end)
  local appliedBeforeCombat = #applied
  Fire("SPELL_DATA_LOAD_RESULT", 918301)
  Eq(#applied, appliedBeforeCombat, "no reapply during combat")
  inCombat = false
  Fire("PLAYER_REGEN_ENABLED")
  Eq(#applied, appliedBeforeCombat + 1, "reapply after combat")
  Eq(applied[#applied][1], combatRegion, "reapplied combat region")
  Display.ReleaseAuraLearning(combatRegion)
  RestoreAll()
  WeakAurasSaved.auraDurations, WeakAurasSaved.auraProfiles = nil, nil

  -- Warning clear
  local warnings = {}
  Override(private.AuraWarnings, "UpdateWarning", function(uid, key, severity2, text2) warnings[#warnings + 1] = {uid, key, severity2, text2} end)
  Display.ClearSingleWarning({uid = "uid-7"})
  Eq(#warnings, 1, "warning cleared once")
  Eq(warnings[1][1], "uid-7", "warning uid")
  Eq(warnings[1][2], "blizzard_aura_single", "warning key")
  Eq(warnings[1][3], nil, "warning severity cleared")
  RestoreAll()

  -- StyleMissingIcon, KeepMissingDesaturated
  local log = {}
  local appliedConditions = {}
  Override(Display, "ApplyMissingConditions", function(nativeView, auraData) appliedConditions[#appliedConditions + 1] = {nativeView, auraData} end)
  local hiddenEdges = {}
  Override(private.DispelTypeDisplay, "Hide", function(edges) hiddenEdges[#hiddenEdges + 1] = edges end)
  local previewMissing, previewOther = CreateFrame("Frame"), CreateFrame("Frame")
  local dispelTexture, borderTexture = CreateFrame("Frame"), CreateFrame("Frame")
  local missingNative = {
    icon = Fake("icon", log), cooldown = Fake("cooldown", log),
    conditionPreview = {{texture = previewMissing, kind = "faAuraMissing"}, {texture = previewOther, kind = "faAuraRemaining"}},
    sharedElements = {{texture = dispelTexture, dispelEdges = "edges"}, {texture = borderTexture}, nil},
  }
  local missingStyleData = Data(Trigger(), {desaturate = true, subRegions = {{type = "subcdmdispel"}, {type = "subtexture"}, {type = "subcdmdispelborder"}}})
  Display.StyleMissingIcon(missingNative, missingStyleData)
  Eq(Contains(log, "icon:SetDesaturated(true)"), true, "missing icon desaturated")
  Eq(Contains(log, "cooldown:Hide()"), true, "missing cooldown hidden")
  Eq(previewMissing:IsShown(), true, "missing preview shown")
  Eq(previewOther:IsShown(), false, "other preview hidden")
  Eq(#appliedConditions, 1, "missing conditions applied")
  Eq(appliedConditions[1][1], missingNative, "missing conditions native")
  Eq(dispelTexture:IsShown(), false, "dispel texture hidden")
  Eq(borderTexture:IsShown(), true, "other texture untouched")
  Eq(#hiddenEdges, 1, "dispel edges hidden once")
  Eq(hiddenEdges[1], "edges", "dispel edges argument")
  Display.StyleMissingIcon({}, Data(Trigger(), {desaturate = false}))
  for key in pairs(log) do log[key] = nil end
  Display.StyleMissingIcon(missingNative, Data(Trigger(), {desaturate = 1}))
  Eq(Contains(log, "icon:SetDesaturated(false)"), true, "desaturate needs true")
  local conditionsBefore = #appliedConditions
  Display.KeepMissingDesaturated(missingNative, missingStyleData)
  Eq(#appliedConditions, conditionsBefore + 1, "KeepMissingDesaturated applies conditions")
  Eq(appliedConditions[#appliedConditions][2], missingStyleData, "KeepMissingDesaturated data")
  RestoreAll()

  -- AttachRemainingHolders, StyleRemainingList
  local oldParent, gateParent = CreateFrame("Frame"), CreateFrame("Frame")
  local buttonFrame = CreateFrame("Frame")
  local gateText = CreateFrame("Frame")
  local function Holders()
    local holders = {}
    for position = 1, 5 do holders["shared" .. position] = CreateFrame("Frame", nil, oldParent) end
    return holders
  end
  local holderElements = {{type = "subglow"}, {type = "subtext", text_text = "%p"}, {type = "subtext", text_text = "%s"},
    {type = "subbackground"}, {type = "subtext", text_text = "%s", secretAuraDetached = true}}
  local limitedData = Data(Trigger({secretUseRem = true, secretRem = 3}), {subRegions = holderElements})
  local limitedNative = {button = buttonFrame, container = {remainingGateText = gateText}, elementFrames = Holders()}
  Display.AttachRemainingHolders(limitedNative, limitedData)
  Eq(limitedNative.elementFrames.shared1:GetParent(), buttonFrame, "glow stays with the button")
  Eq(limitedNative.elementFrames.shared2:GetParent(), buttonFrame, "duration text stays with the button")
  Eq(limitedNative.elementFrames.shared4:GetParent(), buttonFrame, "background stays with the button")
  Eq(limitedNative.elementFrames.shared3:GetParent(), limitedNative.remainingClip, "stack text goes in the clip")
  Eq(limitedNative.elementFrames.shared3:IsShown(), true, "clipped holder shown")
  Eq(limitedNative.elementFrames.shared5:GetParent(), oldParent, "detached element untouched")
  local noClipNative = {button = buttonFrame, container = {}, elementFrames = Holders()}
  Display.AttachRemainingHolders(noClipNative, limitedData)
  Eq(noClipNative.elementFrames.shared3:IsShown(), false, "no clip, stack text hidden")
  Eq(noClipNative.elementFrames.shared3:GetParent(), oldParent, "no clip, parent untouched")
  Eq(noClipNative.remainingClip, nil, "no gate text, no clip")
  local previewNative = {button = buttonFrame, preview = true, container = {remainingGateText = gateText}, elementFrames = Holders()}
  Display.AttachRemainingHolders(previewNative, limitedData)
  Eq(previewNative.elementFrames.shared3:GetParent(), buttonFrame, "preview moves everything to the button")
  Eq(previewNative.remainingClip, nil, "preview has no clip")
  local plainNative = {button = buttonFrame, gateClip = gateParent, container = {remainingGateText = gateText}, elementFrames = Holders()}
  Display.AttachRemainingHolders(plainNative, Data(Trigger(), {subRegions = holderElements}))
  Eq(plainNative.elementFrames.shared3:GetParent(), gateParent, "no window, everything goes to the gate clip")
  Eq(plainNative.elementFrames.shared1:GetParent(), gateParent, "no window, glow goes to the gate clip")
  local barNative = {button = buttonFrame, container = {remainingGateText = gateText}, elementFrames = Holders()}
  Display.AttachRemainingHolders(barNative, Data(Trigger({secretUseRem = true, secretRem = 3}), {regionType = "aurabar", subRegions = holderElements}))
  Eq(barNative.elementFrames.shared3:GetParent(), buttonFrame, "window on a bar does not limit")

  local styleLog = {}
  local overlay, border, iconFrame, cooldownFrame = CreateFrame("Frame"), CreateFrame("Frame"), CreateFrame("Frame"), CreateFrame("Frame")
  local listNative = {
    button = Fake("button", styleLog), conditionOverlay = overlay, icon = iconFrame, cooldown = cooldownFrame, border = border,
    container = {}, elementFrames = {}, remainingHidesIcon = true,
  }
  Display.StyleRemainingList(listNative, Data(Trigger()))
  Eq(listNative.remainingHidesIcon, nil, "list: icon not hidden without window")
  Eq(overlay:IsShown(), true, "list: overlay shown without window")
  Eq(#styleLog, 0, "list: button untouched without window")
  Display.StyleRemainingList(listNative, Data(Trigger({secretUseRem = true, secretRem = 3})))
  Eq(listNative.remainingHidesIcon, true, "list: icon hidden with window")
  Eq(overlay:IsShown(), false, "list: overlay hidden with window")
  Eq(iconFrame:IsShown(), false, "list: icon hidden")
  Eq(cooldownFrame:IsShown(), false, "list: cooldown hidden")
  Eq(border:IsShown(), false, "list: border hidden")
  Eq(Contains(styleLog, "button:ClearIcon()"), true, "list: icon binding cleared")
  Eq(Contains(styleLog, "button:ClearDurationCooldown()"), true, "list: cooldown binding cleared")
  listNative.preview = true
  overlay:Show()
  listNative.remainingHidesIcon = nil
  Display.StyleRemainingList(listNative, Data(Trigger({secretUseRem = true, secretRem = 3})))
  Eq(listNative.remainingHidesIcon, nil, "list: preview keeps icon")
  Eq(overlay:IsShown(), true, "list: preview keeps overlay")

  -- UpdateMissingSource on a fake native
  local missingLog = {}
  Override(C_Spell, "GetSpellTexture", function(spellId) return spellId == 920101 and 6666 or nil end)
  local followData = Data(Trigger({secretShowOn = "showOnMissing", auraspellids = {920101}}), {id = "Follow Aura"})
  followData.triggers[2] = {trigger = {type = "aura2"}}
  local followNative = {
    button = Fake("button", missingLog), icon = Fake("icon", missingLog), cooldown = Fake("cooldown", missingLog),
  }
  followNative.button.bindings = {}
  local missingDisplay = {active = true, native = followNative}
  local followRegion = {
    blizzardAuraDisplay = {active = true, data = followData, instances = {{single = {missing = missingDisplay}}}},
    states = {{show = false}, {show = true, icon = 4321, progressType = "timed", duration = 10, expirationTime = 105}},
  }
  Display.UpdateMissingSource(followRegion)
  Eq(missingDisplay.following, true, "following started")
  Eq(Contains(missingLog, "icon:SetTexture(4321)"), true, "followed icon")
  Eq(Contains(missingLog, "cooldown:SetCooldown(95,10)"), true, "followed cooldown")
  Eq(Contains(missingLog, "cooldown:SetDrawSwipe(true)"), true, "followed swipe")
  Eq(Contains(missingLog, "cooldown:SetDrawEdge(false)"), true, "followed edge")
  Eq(Contains(missingLog, "cooldown:SetReverse(false)"), true, "followed reverse")
  Eq(Contains(missingLog, "cooldown:SetHideCountdownNumbers(true)"), true, "followed countdown numbers hidden")
  Eq(Contains(missingLog, "cooldown:Show()"), true, "followed cooldown shown")
  Eq(Contains(missingLog, "button:SetAlpha(1)"), true, "followed button visible")
  followRegion.states[2].show = false
  Wipe(missingLog)
  Display.UpdateMissingSource(followRegion)
  Eq(missingDisplay.following, nil, "following stopped")
  Eq(Contains(missingLog, "icon:SetTexture(6666)"), true, "default icon back is the spell texture")
  Eq(Contains(missingLog, "cooldown:Clear()"), true, "followed cooldown cleared")
  Eq(Contains(missingLog, "cooldown:Hide()"), true, "followed cooldown hidden")
  Wipe(missingLog)
  Display.UpdateMissingSource(followRegion)
  Eq(#missingLog, 1, "idle follow only refreshes the alpha")
  Eq(missingLog[1], "button:SetAlpha(1)", "idle follow alpha")
  missingDisplay.foundMode = true
  followRegion.states[2] = {show = true, icon = 4321, progressType = "timed", duration = 0, expirationTime = 105}
  followRegion.blizzardAuraDisplay.data = Data(Trigger(), {id = "Found Aura"})
  followRegion.blizzardAuraDisplay.data.triggers[2] = {trigger = {type = "aura2"}}
  Display.UpdateMissingSource(followRegion)
  Eq(missingDisplay.following, true, "found mode follows")
  Eq(Contains(missingLog, "cooldown:SetCooldown(105,0)"), false, "zero duration not applied")
  Eq(Contains(missingLog, "cooldown:Clear()"), true, "unapplied cooldown reset")
  Eq(Contains(missingLog, "button:SetAlpha(1)"), true, "found mode visible while following")
  followRegion.states[2].show = false
  Wipe(missingLog)
  Display.UpdateMissingSource(followRegion)
  Eq(Contains(missingLog, "button:SetAlpha(0)"), true, "found mode hidden when nothing is followed")
  missingDisplay.active = false
  Wipe(missingLog)
  followRegion.states[2] = {show = true, icon = 1, progressType = "timed", duration = 10, expirationTime = 105}
  Display.UpdateMissingSource(followRegion)
  Eq(#missingLog, 0, "inactive missing display untouched")
  Display.UpdateMissingSource({})
  Display.UpdateMissingSource({blizzardAuraDisplay = {active = false}})
  RestoreAll()

  -- ConfigureSingle on instances that never build native frames
  local configureLog = {}
  local function Instance()
    local button = Fake("button", configureLog)
    local container = Fake("container", configureLog)
    return {container = container, buttons = {{button = button, elementFrames = {}}}}, button
  end
  local configureRegion = {}
  local configureTrigger = Trigger({secretShowOn = "showOnMissing", unit = "party"})
  local invalidData = Data(configureTrigger, {id = "Configure Aura"})
  local instance = Instance()
  Display.WatchAuraLearning(configureRegion, Data(Trigger({auraspellids = {919001}}), {id = "Configure Aura"}), Trigger({auraspellids = {919001}}), true)
  Display.ConfigureSingle(instance, configureRegion, invalidData, 1)
  Eq(instance.single, nil, "invalid data builds nothing")
  Eq(#configureLog, 0, "invalid data touches nothing")
  WeakAurasSaved.auraDurations = {}
  Override(C_UnitAuras, "GetAuraDataByIndex", function(unit, slot, filter)
    if unit == "target" and filter == "HELPFUL" and slot == 1 then return {spellId = 919001, duration = 4, isHarmful = false} end
  end)
  Fire("PLAYER_TARGET_CHANGED")
  Eq(WeakAurasSaved.auraDurations[919001], nil, "invalid data released the learning")
  RestoreAll()
  WeakAurasSaved.auraDurations = nil
  instance = Instance()
  Display.ConfigureSingle(instance, configureRegion, Data(Trigger(), {id = "Plain Aura"}), 1)
  Eq(instance.single, nil, "valid plain data builds nothing")
  Display.ConfigureSingle(instance, configureRegion, Data(Trigger({secretShowOn = "showOnMissing"}), {id = "Plain Aura"}), 2)
  Eq(instance.single, nil, "secondary trigger index builds nothing")
  Eq(#configureLog, 0, "plain data touches nothing")

  -- ConfigureSingle with an existing single state: back to the plain list
  configureLog = {}
  instance = Instance()
  local missingClip = Fake("clip", configureLog)
  local missingContainer = Fake("missingContainer", configureLog)
  instance.container.remainingGateText = "old"
  instance.single = {
    foundMode = true, listDisabled = true,
    missing = {active = true, container = missingContainer, clip = missingClip},
    slots = {kept = {used = true}, stale = {used = true}},
  }
  Display.ConfigureSingle(instance, configureRegion, Data(Trigger(), {id = "Plain Aura"}), 2)
  Eq(instance.single.missing.active, false, "missing disabled")
  Eq(Contains(configureLog, "missingContainer:SetEnabled(false)"), true, "missing container disabled")
  Eq(Contains(configureLog, "missingContainer:Hide()"), true, "missing container hidden")
  Eq(Contains(configureLog, "missingContainer:SetAuraGroupEnabled(MuscaMissing,false)"), true, "missing group disabled")
  Eq(Contains(configureLog, "clip:Hide()"), true, "missing clip hidden")
  Eq(rawget(instance.container, "remainingGateText"), nil, "gate text cleared")
  Eq(instance.single.foundMode, false, "found mode off")
  Eq(Contains(configureLog, "container:SetAuraSlotEnabled(kept,false)"), true, "unused slot kept disabled")
  Eq(Contains(configureLog, "container:SetAuraSlotEnabled(stale,false)"), true, "unused slot stale disabled")
  Eq(instance.single.listDisabled, false, "list draws")
  Eq(Contains(configureLog, "container:SetAuraGroupEnabled(Auras,true)"), true, "list group enabled")
  Eq(Contains(configureLog, "button:SetAlpha(1)"), true, "list buttons visible")
  Eq(instance.single.slots.kept.used, false, "slots reset to unused")

  -- RefreshSingle
  local refreshLog = {}
  local function RefreshInstance(extra)
    local refreshInstance = {
      container = Fake("list", refreshLog),
      data = Data(Trigger({unitExists = true})),
      single = {
        listDisabled = false,
        missing = {active = true, container = Fake("missing", refreshLog), clip = Fake("clip", refreshLog)},
      },
    }
    for key, value in pairs(extra or {}) do refreshInstance[key] = value end
    return refreshInstance
  end
  local refreshInstance = RefreshInstance()
  Display.RefreshSingle(refreshInstance, "target", true)
  local expected = {"missing:SetEnabled(false)", "missing:SetUnit(target)", "missing:SetShown(true)", "missing:SetEnabled(true)",
    "clip:SetShown(true)", "clip:SetAlpha(1)", "missing:UpdateAllAuras()"}
  for position, line in ipairs(expected) do Eq(refreshLog[position], line, "refresh step " .. position) end
  Eq(#refreshLog, #expected, "refresh step count")
  Wipe(refreshLog)
  Display.RefreshSingle(refreshInstance, "target", true)
  Eq(Contains(refreshLog, "missing:SetUnit(target)"), false, "same unit not rebound")
  Eq(Contains(refreshLog, "missing:UpdateAllAuras()"), true, "shown updates auras")
  Wipe(refreshLog)
  Display.RefreshSingle(refreshInstance, "focus", true)
  Eq(Contains(refreshLog, "missing:SetUnit(focus)"), true, "new unit rebound")
  Wipe(refreshLog)
  Display.RefreshSingle(refreshInstance, "focus", false)
  Eq(Contains(refreshLog, "missing:SetShown(false)"), true, "hidden")
  Eq(Contains(refreshLog, "missing:SetEnabled(false)"), true, "hidden disabled")
  Eq(Contains(refreshLog, "clip:SetShown(false)"), true, "clip hidden")
  Eq(Contains(refreshLog, "missing:UpdateAllAuras()"), false, "hidden skips update")
  Wipe(refreshLog)
  Display.RefreshSingle(refreshInstance, nil, true)
  Eq(Contains(refreshLog, "missing:SetShown(false)"), true, "no unit hides even when shown")
  Eq(Contains(refreshLog, "missing:UpdateAllAuras()"), false, "no unit skips update")
  Eq(Contains(refreshLog, "clip:SetAlpha(1)"), true, "unit exists flag keeps the clip visible without a unit")
  local absentInstance = RefreshInstance({data = Data(Trigger())})
  Wipe(refreshLog)
  Override(_G, "UnitExists", function() return false end)
  Display.RefreshSingle(absentInstance, "target", true)
  Eq(Contains(refreshLog, "clip:SetAlpha(0)"), true, "absent unit hides the clip")
  Override(_G, "UnitExists", function() return true end)
  Wipe(refreshLog)
  Display.RefreshSingle(RefreshInstance({data = Data(Trigger())}), "target", true)
  Eq(Contains(refreshLog, "clip:SetAlpha(1)"), true, "present unit shows the clip")
  RestoreAll()
  Wipe(refreshLog)
  local followed = RefreshInstance()
  followed.single.missing.presence = Fake("presence", refreshLog)
  followed.single.missing.presenceActive = true
  followed.single.missing.flowShadow = Fake("shadow", refreshLog)
  Display.RefreshSingle(followed, "target", true)
  Eq(Contains(refreshLog, "presence:SetUnit(target)"), true, "follower bound")
  Eq(Contains(refreshLog, "presence:SetShown(true)"), true, "follower shown")
  Eq(Contains(refreshLog, "presence:UpdateAllAuras()"), true, "follower updated")
  Eq(Contains(refreshLog, "shadow:SetUnit(target)"), false, "inactive follower untouched")
  Wipe(refreshLog)
  Display.RefreshSingle(followed, "target", true)
  Eq(Contains(refreshLog, "presence:SetUnit(target)"), false, "follower not rebound")
  local disabledList = RefreshInstance({single = {listDisabled = true}})
  Wipe(refreshLog)
  Display.RefreshSingle(disabledList, "target", true)
  Eq(Contains(refreshLog, "list:SetAuraGroupEnabled(Auras,false)"), true, "disabled list stays disabled")
  Wipe(refreshLog)
  Display.RefreshSingle(disabledList, "target", false)
  Eq(#refreshLog, 0, "hidden refresh leaves the list alone")
  local inactive = RefreshInstance()
  inactive.single.missing.active = false
  Wipe(refreshLog)
  Display.RefreshSingle(inactive, "target", true)
  Eq(#refreshLog, 0, "inactive missing display untouched by refresh")
  Display.RefreshSingle({}, "target", true)


  -- Recorder objects that keep the arguments they receive
  local function Rec(tag)
    local calls = {}
    return setmetatable({tag = tag, calls = calls}, {__index = function(self, method)
      return function(_, ...)
        calls[#calls + 1] = {name = method, n = select("#", ...), ...}
      end
    end})
  end
  local function CallsOf(recorder, name)
    local found = {}
    for _, call in ipairs(recorder.calls) do if call.name == name then found[#found + 1] = call end end
    return found
  end
  local function LastCall(recorder, name)
    local found = CallsOf(recorder, name)
    return found[#found]
  end
  local function ExpectPoints(formatter, expected, label)
    local points = formatter.points
    assert(points, label .. ": formatter without breakpoints")
    Eq(#points, #expected, label .. " point count")
    for position, wanted in ipairs(expected) do
      Near(points[position].threshold, wanted[1], label .. " threshold " .. position)
      if wanted[2] == "fill" then
        assert(points[position].format:find("^W+"), label .. " fill " .. position)
      else
        Eq(points[position].format, "", label .. " format " .. position)
      end
    end
  end
  local barDirections = Enum.StatusBarTimerDirection
  if not (barDirections and barDirections.RemainingTime ~= nil) then
    Override(Enum, "StatusBarTimerDirection", {RemainingTime = 1, ElapsedTime = 2})
  end
  if not Enum.StatusBarInterpolation then Override(Enum, "StatusBarInterpolation", {Immediate = 0}) end
  local formatterFailure
  local formatterCount = 0
  Override(C_StringUtil, "CreateNumericRuleFormatter", function()
    formatterCount = formatterCount + 1
    local formatter = {}
    formatter.SetBreakpoints = function(_, points)
      if formatterFailure then error(formatterFailure, 0) end
      formatter.points = points
    end
    return formatter
  end)
  Override(_G, "CreateFrame", function(frameType, name, parent, template)
    if parent and not test.Frames.State[parent] then parent = nil end
    return CreateFrame(frameType, name, parent, template)
  end)
  local warned = {}
  Override(private.AuraWarnings, "UpdateWarning", function(uid, key, severity3, text3) warned[#warned + 1] = text3 end)
  local function GateView()
    local view = {button = Rec("button"), gateClip = Rec("clip"), gateText = Rec("gate"), cooldown = Rec("cooldown")}
    view.button.CreateFontString = function() return Rec("stackText") end
    return view
  end
  local function RunGate(extraTrigger, extraData)
    local gateRunData = Data(Trigger(extraTrigger), extraData)
    local view = GateView()
    Display.StyleDurationGate(view, gateRunData)
    return view, gateRunData
  end
  local function GateFormatter(view)
    local call = LastCall(view.button, "SetDurationText")
    assert(call, "no duration text binding")
    return call[2].textFormat.components[1].formatter, call[2], call[1]
  end
  local TOTAL, REMAINING = Enum.DurationTextBindingProperty.TotalDuration, Enum.DurationTextBindingProperty.RemainingDuration

  -- Duration gate on total duration
  local view = RunGate({secretUseTotal = true, secretTotal = 5.25})
  local formatter, options, boundText = GateFormatter(view)
  Eq(boundText, view.gateText, "total gate binds the gate text")
  Eq(options.textFormat.formatString, "{}", "total gate format string")
  Eq(options.textFormat.components[1].property, TOTAL, "total gate property")
  Eq(options.textColor.property, TOTAL, "total gate color property")
  assert(options.textColor.curve, "total gate invisible curve")
  ExpectPoints(formatter, {{0, ""}, {4.75, "fill"}, {5.751, ""}}, "total =")
  Eq(#CallsOf(view.gateText, "Show"), 1, "total gate text shown")
  Eq(#CallsOf(view.gateText, "SetWordWrap"), 1, "total gate no wrap")
  assert(LastCall(view.gateText, "SetFont")[2] > 0, "total gate font size")
  Eq(LastCall(view.gateClip, "SetClipsChildren")[1], true, "total gate clips")
  local clipPoint = CallsOf(view.gateClip, "SetPoint")
  Eq(#clipPoint, 2, "total gate clip anchors")
  Eq(clipPoint[1][2], view.gateText, "total gate clip follows the text")
  view = RunGate({secretUseTotal = true, secretTotal = 7.3, secretTotalOperator = ">="})
  ExpectPoints(GateFormatter(view), {{0, ""}, {6.8, "fill"}}, "total >=")
  local cachedCount = formatterCount
  RunGate({secretUseTotal = true, secretTotal = 7.3, secretTotalOperator = ">="})
  Eq(formatterCount, cachedCount, "same gate range reuses the formatter")

  -- Duration gate on remaining time (bar), including an empty window
  view = RunGate({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<"}, {regionType = "aurabar"})
  formatter, options = GateFormatter(view)
  Eq(options.textFormat.components[1].property, REMAINING, "remaining gate property")
  ExpectPoints(formatter, {{0, "fill"}, {5.5, ""}}, "remaining <")
  view = RunGate({secretUseRem = true, secretRem = 9.5, secretRemOperator = "<="}, {regionType = "aurabar"})
  ExpectPoints(GateFormatter(view), {{0, "fill"}, {9.501, ""}}, "remaining <=")
  view = RunGate({secretUseRem = true, secretRem = 8.5, secretRemOperator = ">="}, {regionType = "aurabar"})
  ExpectPoints(GateFormatter(view), {{0, ""}, {8.5, "fill"}}, "remaining >=")
  view = RunGate({secretUseRem = true, secretRem = 0, secretRemOperator = "<"}, {regionType = "aurabar"})
  ExpectPoints(GateFormatter(view), {{0, ""}}, "remaining < 0 never shows")

  -- Gate refusals warn and leave the text hidden
  warned = {}
  formatterFailure = "boom"
  view = RunGate({secretUseTotal = true, secretTotal = 6.25})
  formatterFailure = nil
  Eq(#CallsOf(view.button, "SetDurationText"), 0, "refused breakpoints, nothing bound")
  Eq(#CallsOf(view.gateText, "Show"), 0, "refused breakpoints, text not shown")
  Eq(warned[1], "Blizzard refused the Total Duration check: boom", "refused breakpoints warning")
  warned = {}
  local refusingView = GateView()
  refusingView.button.SetDurationText = function() error("denied", 0) end
  Display.StyleDurationGate(refusingView, Data(Trigger({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<"}), {regionType = "aurabar"}))
  Eq(warned[1], "Blizzard refused the Remaining Time check: denied", "refused binding warning")
  Eq(#CallsOf(refusingView.gateText, "Show"), 0, "refused binding, text not shown")
  warned = {}
  local previewView = GateView()
  previewView.preview = true
  Display.StyleDurationGate(previewView, Data(Trigger({secretUseTotal = true, secretTotal = 5})))
  Eq(#previewView.button.calls, 0, "preview gets no gate")
  local clipless = GateView()
  clipless.gateClip = nil
  Display.StyleDurationGate(clipless, Data(Trigger({secretUseTotal = true, secretTotal = 5})))
  Eq(#clipless.button.calls, 0, "no clip, no gate")

  -- Total gate drives the countdown of an icon
  view = RunGate({secretUseTotal = true, secretTotal = 5.75}, {subRegions = {{type = "subtext", text_text = "%p"}}, cooldown = false})
  Eq(LastCall(view.cooldown, "SetMinimumCountdownDuration")[1], 5250, "countdown minimum from the lower bound")
  Eq(LastCall(view.cooldown, "SetUseAuraDisplayTime")[1], true, "countdown uses the aura time")
  Eq(LastCall(view.cooldown, "SetDrawSwipe")[1], false, "cooldown swipe off when the cooldown is off")
  Eq(LastCall(view.button, "SetDurationCooldown")[1], view.cooldown, "countdown bound to the button")
  view = RunGate({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<"}, {regionType = "aurabar", subRegions = {{type = "subtext", text_text = "%p"}}})
  Eq(#CallsOf(view.cooldown, "SetMinimumCountdownDuration"), 0, "remaining gate leaves the countdown alone")
  local textHidden = Rec("shared")
  view = GateView()
  view.sharedElements = {{text = textHidden}}
  Display.StyleDurationGate(view, Data(Trigger({secretUseTotal = true, secretTotal = 5.75}), {subRegions = {{type = "subtext", text_text = "%p"}}}))
  Eq(#CallsOf(textHidden, "Hide"), 1, "duration text element hidden under a gate")

  -- No gate at all
  view = RunGate({})
  Eq(#CallsOf(view.gateText, "Hide"), 1, "no gate hides the gate text")
  Eq(LastCall(view.cooldown, "SetMinimumCountdownDuration")[1], 0, "no gate clears the countdown minimum")
  Eq(LastCall(view.gateClip, "SetClipsChildren")[1], false, "no gate stops clipping")
  Eq(LastCall(view.gateClip, "SetAllPoints")[1], view.button, "no gate clip covers the button")

  -- Stack gate variants
  local function StackData(operator, count, extra)
    return Data(Trigger({secretUseStacks = true, secretStacksOperator = operator, secretStacks = count}), extra)
  end
  local stackView = GateView()
  stackView.sharedElements = {{text = Rec("stackShared")}}
  local stackExtra = {subRegions = {{type = "subtext", text_text = "%s"}}}
  Display.StyleDurationGate(stackView, StackData("=", 3, stackExtra))
  local countCall = LastCall(stackView.button, "SetApplicationCount")
  assert(countCall, "exact stack gate not bound")
  ExpectPoints(countCall[2].formatter, {{0, ""}, {3, "fill"}, {3.001, ""}}, "stack =")
  local stackText = countCall[1]
  Eq(LastCall(stackText, "SetAlpha")[1], 0, "exact gate text invisible")
  Eq(#CallsOf(stackText, "Show"), 1, "exact gate text shown")
  Eq(#CallsOf(stackView.sharedElements[1].text, "SetText"), 1, "stack count text refreshed")
  Eq(LastCall(stackView.gateClip, "SetClipsChildren")[1], true, "exact gate clips")
  Eq(#CallsOf(stackView.button, "SetApplicationBar"), 0, "exact gate uses no bar")
  local dimensionWidth, dimensionHeight = Display.Dimensions(stackView and StackData("=", 3))
  local margin = math.ceil(math.max(dimensionWidth, dimensionHeight) * 0.5) + 8
  local step = dimensionWidth + 2 * margin

  Display.StyleDurationGate(stackView, StackData(">=", 3, stackExtra))
  local barCall = LastCall(stackView.button, "SetApplicationBar")
  assert(barCall, "atLeast stack gate not bound")
  Eq(barCall[2].maxApplications, 3, "atLeast capacity")
  local stackBar = barCall[1]
  Eq(stackBar:IsShown(), true, "atLeast bar shown")
  Near(stackBar:GetWidth(), 3 * step, "atLeast bar width")
  Near(stackBar:GetHeight(), dimensionHeight + 2 * margin, "atLeast bar height")
  Eq(#CallsOf(stackText, "Hide"), 1, "exact text hidden once the bar takes over")
  local atLeastPoints = CallsOf(stackView.gateClip, "SetPoint")
  Eq(atLeastPoints[#atLeastPoints - 1][2], stackBar, "atLeast clip starts on the bar")
  Near(atLeastPoints[#atLeastPoints - 1][4], 2 * step, "atLeast clip offset")
  local barAnchor = stackBar:GetPoint(1)
  Eq(barAnchor, "LEFT", "atLeast bar anchored on the left")

  Display.StyleDurationGate(stackView, StackData("<=", 3, stackExtra))
  barCall = LastCall(stackView.button, "SetApplicationBar")
  Eq(barCall[2].maxApplications, 4, "atMost capacity")
  Near(stackBar:GetWidth(), 4 * step, "atMost bar width")
  Eq(stackBar:GetPoint(1), "RIGHT", "atMost bar anchored on the right")
  local atMostPoints = CallsOf(stackView.gateClip, "SetPoint")
  Eq(atMostPoints[#atMostPoints - 1][3], "TOPRIGHT", "atMost clip starts after the bar fill")

  Display.StyleDurationGate(stackView, StackData("<", 3, stackExtra))
  Eq(LastCall(stackView.button, "SetApplicationBar")[2].maxApplications, 3, "atMost from < shifts the capacity")

  local clearsBefore = #CallsOf(stackView.button, "ClearApplicationBar")
  Display.StyleDurationGate(stackView, StackData("=", 2, stackExtra))
  Eq(#CallsOf(stackView.button, "ClearApplicationBar"), clearsBefore + 1, "exact gate clears the bar")
  Eq(stackBar:IsShown(), false, "exact gate hides the bar")
  ExpectPoints(LastCall(stackView.button, "SetApplicationCount")[2].formatter, {{0, ""}, {2, "fill"}, {2.001, ""}}, "stack = 2")
  Display.StyleDurationGate(stackView, Data(Trigger({}), stackExtra))
  Eq(stackBar:IsShown(), false, "no stack gate, bar hidden")

  warned = {}
  local refusedBar = GateView()
  refusedBar.button.SetApplicationBar = function() error("nope", 0) end
  Display.StyleDurationGate(refusedBar, StackData(">=", 4))
  Eq(warned[1], "Blizzard refused the Stack Count check: nope", "refused stack bar warning")
  warned = {}
  local refusedCount = GateView()
  refusedCount.button.SetApplicationCount = function() error("nope", 0) end
  Display.StyleDurationGate(refusedCount, StackData("=", 4))
  Eq(warned[1], "Blizzard refused the Stack Count check: nope", "refused stack count warning")
  warned = {}
  formatterFailure = "bad"
  Display.StyleDurationGate(GateView(), StackData("=", 9))
  formatterFailure = nil
  Eq(warned[1], "Blizzard refused the Stack Count check: bad", "refused stack breakpoints warning")
  Eq(#warned, 1, "one warning per refusal")

  -- Stack gate with a duration gate: the duration gate wins and the stack gate is torn down
  stackView = GateView()
  Display.StyleDurationGate(stackView, StackData(">=", 3))
  local stackBarAfter = LastCall(stackView.button, "SetApplicationBar")[1]
  Display.StyleDurationGate(stackView, Data(Trigger({secretUseTotal = true, secretTotal = 6.5}), {}))
  Eq(stackBarAfter:IsShown(), false, "duration gate removes the stack bar")

  -- ConfigureSingle with a remaining window on an icon: two Blizzard slots
  Override(C_Spell, "GetSpellTexture", function(spellId) return spellId == 920201 and 7777 or nil end)
  for _, enumName in ipairs({"AuraContainerSortMethod", "AuraContainerSortDirection"}) do
    if not _G[enumName] then Override(_G, enumName, setmetatable({}, {__index = function(_, name) return name end})) end
  end
  local slotContainer = Rec("slotContainer")
  local slotButtons = {}
  slotContainer.AddAuraSlot = function(self, key, filter, slotOptions)
    self.calls[#self.calls + 1] = {name = "AddAuraSlot", n = 2, key, filter}
    local slotButton = Rec(key)
    slotButton.CreateFontString = function() return Rec(key .. "Text") end
    slotButtons[key] = slotButton
    slotOptions.initializeFrame(slotButton)
  end
  local slotInstance = {container = slotContainer, buttons = {}}
  local slotRegion = {}
  local slotData = Data(Trigger({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<=", auraspellids = {920201}}), {id = "Slot Aura"})
  Display.ConfigureSingle(slotInstance, slotRegion, slotData, 1)
  Eq(#CallsOf(slotContainer, "AddAuraSlot"), 2, "two slots added")
  local iconButton, gateButton = slotButtons.MuscaRemainIcon, slotButtons.MuscaRemainGate
  assert(iconButton and gateButton, "slot buttons")
  local iconCall = LastCall(iconButton, "SetDurationText")
  assert(iconCall, "remaining icon text not bound")
  Has(iconCall[2].textFormat.formatString, "|T7777:", "remaining icon markup uses the spell texture")
  Eq(iconCall[2].textColor.property, REMAINING, "remaining icon color property")
  assert(iconCall[2].textColor.curve, "remaining icon curve")
  Eq(#CallsOf(iconButton, "ClearDurationText"), 1, "remaining icon text cleared before binding")
  local gateCall = LastCall(gateButton, "SetDurationText")
  assert(gateCall, "remaining gate text not bound")
  ExpectPoints(gateCall[2].textFormat.components[1].formatter, {{0, "fill"}, {5.501, ""}}, "slot gate <=")
  Eq(rawget(slotContainer, "remainingGateText"), gateCall[1], "container remembers the gate text")
  Eq(Contains(slotContainer.calls and (function()
    local lines = {}
    for _, call in ipairs(slotContainer.calls) do lines[#lines + 1] = call.name .. ":" .. tostring(call[1]) .. "," .. tostring(call[2]) end
    return lines
  end)(), "SetAuraSlotEnabled:MuscaRemainIcon,true"), true, "icon slot enabled")
  Eq(slotInstance.single.slots.MuscaRemainGate.used, true, "gate slot used")
  Display.ConfigureSingle(slotInstance, slotRegion, Data(Trigger({secretUseRem = true, secretRem = 5.5}), {id = "Slot Aura"}), 2)
  Eq(slotInstance.single.slots.MuscaRemainGate.used, false, "secondary trigger resets the slots")
  Display.ReleaseAuraLearning(slotRegion)

  warned = {}
  local refusedContainer = Rec("refusedContainer")
  refusedContainer.AddAuraSlot = function(self, key, filter, slotOptions)
    local slotButton = Rec(key)
    slotButton.CreateFontString = function() return Rec(key .. "Text") end
    slotButton.SetDurationText = function() error("denied", 0) end
    slotOptions.initializeFrame(slotButton)
  end
  local refusedInstance = {container = refusedContainer, buttons = {}}
  Display.ConfigureSingle(refusedInstance, {}, Data(Trigger({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<="}), {id = "Refused Slot"}), 1)
  Eq(warned[1], "Blizzard refused the Remaining Time icon: denied", "refused remaining icon warning")
  Eq(rawget(refusedContainer, "remainingGateText"), nil, "no gate after a refused icon")
  warned = {}
  local failingContainer = Rec("failingContainer")
  failingContainer.AddAuraSlot = function() error("no slot", 0) end
  Display.ConfigureSingle({container = failingContainer, buttons = {}}, {}, Data(Trigger({secretUseRem = true, secretRem = 5.5, secretRemOperator = "<="}), {id = "Failing Slot"}), 1)
  Eq(warned[1], "Blizzard could not create the Remaining Time display: no slot", "slot creation warning")
  Display.ReleaseAuraLearning({})

  -- Following a trigger on a bar: timer, text and fallback icon
  local followBar, followText = Rec("followBar"), Rec("followText")
  local barButton = Rec("barButton")
  barButton.bindings = {DurationBar = {{widget = followBar}}, DurationText = {{widget = followText, options = {}}}}
  local barNative = {button = barButton, icon = Rec("barIcon"), cooldown = Rec("barCooldown")}
  local barDisplay = {active = true, native = barNative}
  local barFollowData = Data(Trigger({secretShowOn = "showOnMissing", auraspellids = {920301}}), {id = "Bar Follow", regionType = "aurabar"})
  barFollowData.triggers[2] = {trigger = {type = "aura2"}}
  Override(C_Spell, "GetSpellTexture", function(spellId) return spellId == 920301 and 8888 or nil end)
  local barRegion = {
    blizzardAuraDisplay = {active = true, data = barFollowData, instances = {{single = {missing = barDisplay}}}},
    states = {{show = false}, {show = true, icon = 4321, progressType = "timed", duration = 10, expirationTime = 105}},
  }
  Display.UpdateMissingSource(barRegion)
  Eq(barDisplay.following, true, "bar follow started")
  local timerCall = LastCall(followBar, "SetTimerDuration")
  assert(timerCall, "bar timer not set")
  Eq(timerCall[3], Enum.StatusBarTimerDirection.RemainingTime, "bar counts down")
  Eq(LastCall(barNative.icon, "SetTexture")[1], 4321, "bar follow icon")
  local updater = LastCall(barButton, "SetScript")
  Eq(updater[1], "OnUpdate", "bar follow text updater")
  updater[2](barButton, 1)
  Eq(#CallsOf(followText, "SetText"), 1, "text updated after the interval")
  updater[2](barButton, 0.01)
  Eq(#CallsOf(followText, "SetText"), 1, "text not updated before the next interval")
  barFollowData.inverse = true
  Display.UpdateMissingSource(barRegion)
  Eq(LastCall(followBar, "SetTimerDuration")[3], Enum.StatusBarTimerDirection.ElapsedTime, "inverse bar counts up")
  barRegion.states[2].show = false
  Display.UpdateMissingSource(barRegion)
  Eq(barDisplay.following, nil, "bar follow stopped")
  Eq(LastCall(barButton, "SetScript")[2], nil, "bar follow updater removed")
  Eq(LastCall(followBar, "SetValue")[1], 0, "bar follow bar emptied")
  Eq(LastCall(followBar, "SetMinMaxValues")[2], 6, "bar follow range reset")
  Eq(LastCall(followText, "SetText")[1], "", "bar follow text cleared")
  Eq(LastCall(barNative.icon, "SetTexture")[1], 8888, "bar follow icon back to the spell texture")
  RestoreAll()

  RestoreAll()
end

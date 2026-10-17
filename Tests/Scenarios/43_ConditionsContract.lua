-- SecretAuraConditions exports: native condition kinds and properties, threshold rules (duration curve, stack formatter),
-- migration, validation messages, forced-on appearance copy, property application on fake buttons, indicators and preview.
-- Not covered here: AnchorOffsetApplier (scenario 21), real Blizzard aura buttons.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local function Near(actual, expected, label)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Same(actual, expected, label)
    assert(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Data(extra)
    local data = {
      regionType = "icon", id = "Test Aura", uid = "uid",
      triggers = { { trigger = { type = "secretAura", unit = "player" } } },
      subRegions = {}, conditions = {}, blizzardAuraDisplay = {},
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function Rule(variable, op, value, changes, linked)
    return { check = { trigger = 1, variable = variable, op = op, value = value }, changes = changes, linked = linked }
  end
  local function Change(property, value) return { property = property, value = value } end
  local function Text(text, extra)
    local element = { type = "subtext", text_text = text }
    for key, value in pairs(extra or {}) do element[key] = value end
    return element
  end
  local function Glow(on) return { type = "subglow", glow = on } end
  local function RGBA(color) return color:GetRGBA() end
  local function Recorder()
    local calls = {}
    return setmetatable({ calls = calls }, { __index = function(_, name)
      return function(_, ...)
        local call = { name, ... }
        call.n = select("#", ...) + 1
        calls[#calls + 1] = call
      end
    end })
  end
  local function Last(recorder, name)
    for index = #recorder.calls, 1, -1 do
      if recorder.calls[index][1] == name then return unpack(recorder.calls[index], 2, recorder.calls[index].n) end
    end
  end
  local function CountCalls(recorder, name)
    local count = 0
    for _, call in ipairs(recorder.calls) do if call[1] == name then count = count + 1 end end
    return count
  end

  local curves, formatters = {}, {}
  local realCurve, realFormatter = C_CurveUtil.CreateColorCurve, C_StringUtil.CreateNumericRuleFormatter
  C_CurveUtil.CreateColorCurve = function()
    local curve = { points = {} }
    function curve:SetType(kind) self.kind = kind end
    function curve:AddPoint(x, color) self.points[#self.points + 1] = { x = x, color = color } end
    curves[#curves + 1] = curve
    return curve
  end
  C_StringUtil.CreateNumericRuleFormatter = function()
    local formatter = {}
    function formatter:SetBreakpoints(steps) self.steps = steps end
    formatters[#formatters + 1] = formatter
    return formatter
  end

  -- Kinds
  local data = Data({ triggers = {
    { trigger = { type = "secretAura", unit = "player" } },
    { trigger = { type = "aura2" } },
    "bad",
  } })
  Same(Display.NativeConditionKind(data, nil), nil, "nil check")
  Same(Display.NativeConditionKind(data, { trigger = 1, variable = "faAuraRemaining" }), "faAuraRemaining", "native kind")
  Same(Display.NativeConditionKind(data, { trigger = 1, variable = "stacks" }), nil, "unknown variable")
  Same(Display.NativeConditionKind(data, { trigger = 2, variable = "faAuraRemaining" }), nil, "other trigger type")
  Same(Display.NativeConditionKind(data, { trigger = 3, variable = "faAuraRemaining" }), nil, "trigger entry not a table")
  Same(Display.NativeConditionKind(data, { trigger = 9, variable = "faAuraRemaining" }), nil, "missing trigger")
  Same(Display.NativeConditionKind(Data({ triggers = false }), { trigger = 1, variable = "faAuraRemaining" }), nil, "no triggers")
  for _, variable in ipairs({ "faAuraPandemic", "faAuraStealable", "faAuraNotStealable", "faAuraDispel", "faAuraType",
    "faAuraPresent", "faAuraApplications", "faAuraMissing", "faAuraRemaining", "faAuraRemainingPercent", "faAuraElapsed",
    "faAuraElapsedPercent", "faAuraTotal", "faAuraStart", "faAuraEnd" }) do
    Same(Display.NativeConditionKind(data, { trigger = 1, variable = variable }), variable, "kind " .. variable)
  end
  Same(Display.IsNativeDurationCondition(nil), nil, "duration check nil")
  assert(Display.IsNativeDurationCondition({ variable = "faAuraEnd" }) == true, "duration variable")
  assert(Display.IsNativeDurationCondition({ variable = "faAuraPandemic" }) == false, "non duration variable")
  assert(Display.IsNativeDurationCondition({ variable = "faAuraApplications" }) == false, "stack is not duration")

  local nested = { variable = "AND", checks = { { trigger = 2, variable = "x" },
    { variable = "OR", checks = { { trigger = 1, variable = "faAuraPandemic" } } } } }
  assert(Display.ContainsNativeCondition(data, nested) == true, "nested native condition")
  assert(Display.ContainsNativeCondition(data, { variable = "AND", checks = { { trigger = 2, variable = "x" } } }) == false,
    "no native condition")
  assert(Display.ContainsNativeCondition(data, nil) == false, "nil condition")

  -- Client support
  assert(Display.SupportsDurationColorCondition(), "duration curves supported in the harness")
  local function Without(owner, key, body)
    local saved = owner[key]
    owner[key] = nil
    body()
    owner[key] = saved
  end
  Without(C_CurveUtil, "CreateColorCurve", function() assert(not Display.SupportsDurationColorCondition(), "no curve") end)
  Without(Enum.LuaCurveType, "Step", function() assert(not Display.SupportsDurationColorCondition(), "no step curve") end)
  Without(Enum.DurationTextBindingProperty, "RemainingDuration",
    function() assert(not Display.SupportsDurationColorCondition(), "no remaining binding") end)

  -- Glow property
  local glowData = Data({ subRegions = { Glow(false), Text("%p"), Text("x", { secretAuraDetached = true }) } })
  assert(Display.IsGlowProperty(glowData, "sub.1.glow") == true, "glow element")
  assert(Display.IsGlowProperty(glowData, "sub.2.glow") == false, "text element is not a glow")
  assert(Display.IsGlowProperty(glowData, "sub.9.glow") == false, "missing element")
  assert(Display.IsGlowProperty(glowData, "sub.1.text_color") == false, "other key")
  assert(Display.IsGlowProperty(glowData, "glow") == false, "root path")
  assert(Display.IsGlowProperty(glowData, nil) == false, "nil path")
  glowData.subRegions[1].secretAuraDetached = true
  assert(Display.IsGlowProperty(glowData, "sub.1.glow") == true, "detached flag does not hide a glow element")

  -- Pandemic glow support frames
  local function PandemicData(glow)
    return Data({
      subRegions = { Glow(glow), Text("%p") },
      conditions = { Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", true) }) },
    })
  end
  local native = { button = CreateFrame("Frame") }
  local levelFrame = CreateFrame("Frame")
  levelFrame:SetFrameLevel(10)
  local holder = Display.PandemicGlowHolder(native, PandemicData(false), 1, levelFrame)
  assert(holder, "holder for a glow turned on by the pandemic window")
  Same(holder:GetFrameLevel(), 11, "holder level")
  assert(holder:IsShown() == false, "holder hidden")
  Same(holder:GetParent(), native.button, "holder parent without gate clip")
  Same(native.pandemicGlows[1], holder, "holder registered")
  levelFrame:SetFrameLevel(20)
  holder:Show()
  Same(Display.PandemicGlowHolder(native, PandemicData(false), 1, levelFrame), holder, "holder reused")
  Same(holder:GetFrameLevel(), 21, "holder level refreshed")
  assert(holder:IsShown() == false, "holder hidden again")
  local gate = CreateFrame("Frame")
  local gated = { button = CreateFrame("Frame"), gateClip = gate }
  Same(Display.PandemicGlowHolder(gated, PandemicData(false), 1, levelFrame):GetParent(), gate, "holder parent is the gate clip")
  assert(Display.PandemicGlowHolder({ button = native.button }, PandemicData(true), 1, levelFrame) == nil, "glow already on")
  assert(Display.PandemicGlowHolder({ button = native.button }, PandemicData(false), 2, levelFrame) == nil, "not a glow element")
  assert(Display.PandemicGlowHolder({ button = native.button }, PandemicData(false), 3, levelFrame) == nil, "missing element")
  local linkedData = PandemicData(false)
  linkedData.conditions[1].linked = true
  assert(Display.PandemicGlowHolder({ button = native.button }, linkedData, 1, levelFrame) == nil, "linked condition ignored")
  local otherData = PandemicData(false)
  otherData.conditions[1].check.variable = "faAuraRemaining"
  assert(Display.PandemicGlowHolder({ button = native.button }, otherData, 1, levelFrame) == nil, "other kind ignored")
  local offData = PandemicData(false)
  offData.conditions[1].changes[1].value = false
  assert(Display.PandemicGlowHolder({ button = native.button }, offData, 1, levelFrame) == nil, "change turning the glow off")
  local forced = PandemicData(true)
  forced.nativeConditionBaseData = PandemicData(false)
  assert(Display.PandemicGlowHolder({ button = native.button }, forced, 1, levelFrame), "base data decides, not the forced copy")
  local second = { button = native.button }
  local secondHolder = Display.PandemicGlowHolder(second, PandemicData(false), 1, levelFrame)
  secondHolder:Show()
  Display.ResetPandemicGlows(second)
  assert(secondHolder:IsShown() == false, "reset hides")
  Same(next(second.pandemicGlows), nil, "reset empties the list")
  Same(second.pandemicGlowFrames[1], secondHolder, "reset keeps the frames")
  Display.ResetPandemicGlows({})

  -- Properties allowed per condition kind
  local function Allows(auraData, variable, property)
    return Display.NativeConditionAllowsProperty(auraData, { trigger = 1, variable = variable }, property)
  end
  local propertyData = Data({ subRegions = { Text("%p"), Text("%s"), Glow(false), Text("hello"),
    Text("%n", { secretAuraDetached = true }) } })
  for _, variable in ipairs({ "faAuraRemaining", "faAuraElapsed", "faAuraPandemic" }) do
    assert(Allows(propertyData, variable, "sub.3.glow") == true, variable .. " drives a glow")
  end
  assert(Allows(propertyData, "faAuraTotal", "sub.3.glow") == false, "total duration does not drive a glow")
  assert(Allows(propertyData, "faAuraApplications", "sub.3.glow") == false, "stacks do not drive a glow")
  assert(Allows(propertyData, "faAuraRemaining", "sub.1.text_color") == true, "duration color")
  assert(Allows(propertyData, "faAuraRemaining", "sub.1.text_visible") == true, "duration visibility")
  assert(Allows(propertyData, "faAuraRemaining", "sub.1.text_text") == false, "duration text is not a channel")
  assert(Allows(propertyData, "faAuraRemaining", "sub.2.text_color") == false, "stack text for a duration condition")
  assert(Allows(propertyData, "faAuraRemaining", "sub.4.text_color") == false, "literal text for a duration condition")
  assert(Allows(propertyData, "faAuraRemaining", "faAuraHighlightColor") == false, "highlight for a duration condition")
  assert(Allows(propertyData, "faAuraRemaining", "sub.5.text_color") == false, "detached text")
  assert(Allows(propertyData, "faAuraApplications", "sub.2.text_color") == true, "stack color")
  assert(Allows(propertyData, "faAuraApplications", "sub.2.text_text") == true, "stack text")
  assert(Allows(propertyData, "faAuraApplications", "sub.1.text_color") == false, "duration text for a stack condition")
  assert(Allows(propertyData, "faAuraPandemic", "faAuraHighlightStyle") == true, "highlight for a native condition")
  assert(Allows(propertyData, "faAuraStealable", "faAuraHighlightPulse") == true, "highlight for stealable")
  assert(Allows(propertyData, "faAuraStealable", "sub.1.text_color") == false, "text for a highlight only kind")
  assert(Allows(propertyData, "faAuraDispel", "desaturate") == false, "root property for a highlight only kind")
  assert(Display.NativeConditionAllowsProperty(propertyData, { trigger = 1, variable = "x" }, "sub.1.text_color") == true,
    "ordinary condition on a text property")
  assert(Display.NativeConditionAllowsProperty(propertyData, { trigger = 1, variable = "x" }, "faAuraHighlightSize") == false,
    "ordinary condition on a highlight property")
  assert(Display.NativeConditionAllowsProperty(propertyData, nil, "faAuraHighlightColor") == false, "no check, highlight")
  assert(Display.NativeConditionAllowsProperty(propertyData, nil, "width") == true, "no check, other property")
  local textData = Data({ regionType = "text", displayText = "%p" })
  assert(Allows(textData, "faAuraRemaining", "color") == true, "root duration text color")
  assert(Allows(textData, "faAuraRemaining", "displayText") == false, "root text channel")
  assert(Allows(textData, "faAuraApplications", "color") == false, "root duration text for stacks")
  assert(Allows(Data({ regionType = "text", displayText = "%s" }), "faAuraApplications", "color") == true, "root stack color")

  local missingData = Data({ subRegions = { Text("%p"), Glow(false), Text("x", { secretAuraDetached = true }) } })
  local missingAllowed = { "desaturate", "color", "zoom", "faAuraHighlightColor", "sub.1.text_visible", "sub.1.text_color",
    "sub.2.glow" }
  for _, property in ipairs(missingAllowed) do assert(Allows(missingData, "faAuraMissing", property) == true, "missing " .. property) end
  for _, property in ipairs({ "fontSize", "inverse", "barColor", "sub.1.text_text", "sub.1.text_fontSize", "sub.2.text_visible",
    "sub.3.text_color", "sub.9.glow", "foregroundColor" }) do
    assert(Allows(missingData, "faAuraMissing", property) == false, "missing refuses " .. property)
  end
  assert(Allows(Data({ regionType = "aurabar" }), "faAuraMissing", "barColor") == true, "missing bar color")
  assert(Allows(Data({ regionType = "aurabar" }), "faAuraMissing", "zoom") == false, "missing bar zoom")
  assert(Allows(Data({ regionType = "progresstexture" }), "faAuraMissing", "desaturateForeground") == true, "missing progress")
  assert(Allows(Data({ regionType = "text" }), "faAuraMissing", "color") == true, "missing text color")
  assert(Allows(Data({ regionType = "text" }), "faAuraMissing", "desaturate") == false, "missing text desaturate")
  assert(Allows(Data({ regionType = "model" }), "faAuraMissing", "color") == false, "missing on an unsupported region")
  assert(Allows(Data({ regionType = "model" }), "faAuraMissing", "faAuraHighlightColor") == false,
    "missing highlight on an unsupported region")
  Same(Display.missingRootProperties.icon.zoom, true, "missing root table icon")
  Same(Display.missingRootProperties.aurabar.icon_color, true, "missing root table bar")
  Same(Display.missingRootProperties.text.color, true, "missing root table text")
  Same(Display.missingRootProperties.progresstexture.backgroundColor, true, "missing root table progress")
  Same(Display.missingRootProperties.icon.fontSize, nil, "missing root table is narrow")

  -- Missing desaturation
  local function MissingData(op, value, kind, linked)
    return Data({ conditions = { Rule(kind or "faAuraMissing", nil, nil, { Change("desaturate", value) }, linked) } })
  end
  assert(Display.MissingDesaturated(MissingData(nil, true)) == true, "missing desaturates")
  assert(Display.MissingDesaturated(MissingData(nil, true, nil, true)) == true, "linked missing condition still counts")
  assert(Display.MissingDesaturated(MissingData(nil, false)) == false, "desaturate off")
  assert(Display.MissingDesaturated(MissingData(nil, true, "faAuraPandemic")) == false, "other kind")
  assert(Display.MissingDesaturated(Data()) == false, "no conditions")

  -- Migration of the legacy switches
  local function Migrate(extra, legacy)
    local migrated = Data(extra)
    migrated.conditions = nil
    migrated.blizzardAuraDisplay = legacy
    Display.MigrateNativeConditions(migrated)
    return migrated
  end
  local migrated = Migrate({}, { missingDesaturate = true })
  Same(#migrated.conditions, 1, "missing condition added")
  Same(migrated.conditions[1].check.variable, "faAuraMissing", "missing variable")
  Same(migrated.conditions[1].check.trigger, 1, "missing trigger")
  Same(migrated.conditions[1].changes[1].property, "desaturate", "missing property")
  Same(migrated.conditions[1].changes[1].value, true, "missing value")
  Same(migrated.blizzardAuraDisplay.missingDesaturate, nil, "missing flag cleared")
  migrated = Data({ triggers = { { trigger = { type = "aura2" } }, { trigger = { type = "secretAura" } } },
    conditions = { Rule("faAuraPandemic", nil, nil, {}) }, blizzardAuraDisplay = { missingDesaturate = true } })
  Display.MigrateNativeConditions(migrated)
  Same(#migrated.conditions, 2, "condition appended after existing ones")
  Same(migrated.conditions[2].check.trigger, 2, "first secret trigger")
  migrated = Migrate({ triggers = { { trigger = { type = "aura2" } } } }, { missingDesaturate = true })
  Same(migrated.conditions, nil, "no secret trigger, no condition")
  Same(migrated.blizzardAuraDisplay.missingDesaturate, true, "no secret trigger, flag kept")
  migrated = Migrate({ triggers = false }, { missingDesaturate = true, remainingTimeColorEnabled = true })
  Same(migrated.conditions, nil, "no triggers at all")
  migrated = Data({ blizzardAuraDisplay = false })
  Display.MigrateNativeConditions(migrated)
  Same(#migrated.conditions, 0, "no legacy table")
  migrated = Migrate({}, { missingDesaturate = false })
  Same(migrated.conditions, nil, "flag false")

  local function RemainingLegacy(extra, legacy)
    legacy = legacy or {}
    legacy.remainingTimeColorEnabled = true
    return Migrate(extra, legacy)
  end
  migrated = RemainingLegacy({ subRegions = { Text("%s"), Text("%p"), Text("%p") } })
  Same(#migrated.conditions, 1, "remaining condition added")
  local check, change = migrated.conditions[1].check, migrated.conditions[1].changes[1]
  Same(check.variable, "faAuraRemaining", "remaining variable")
  Same(check.op, "<", "remaining operator")
  Same(check.value, 10, "remaining default threshold")
  Same(change.property, "sub.2.text_color", "first duration text")
  Same(change.value[1], 1, "remaining default color red")
  Same(change.value[2], 0, "remaining default color green")
  Same(migrated.blizzardAuraDisplay.remainingTimeColorEnabled, nil, "remaining flag cleared")
  migrated = RemainingLegacy({ subRegions = { Text("%p") } }, { remainingTimeColorThreshold = 4, remainingTimeColor = { 0, 1, 0, 1 } })
  Same(migrated.conditions[1].check.value, 4, "remaining threshold")
  Same(migrated.conditions[1].changes[1].value[2], 1, "remaining color")
  migrated = RemainingLegacy({ regionType = "text", displayText = "%p", subRegions = { Text("%p") } })
  Same(migrated.conditions[1].changes[1].property, "color", "text region duration")
  migrated = RemainingLegacy({ regionType = "text", displayText = "hello", subRegions = { Text("%p") } })
  Same(migrated.conditions[1].changes[1].property, "sub.1.text_color", "text region without duration falls back to elements")
  migrated = RemainingLegacy({ subRegions = { Text("%p", { text_visible = false }), Text("%p", { secretAuraDetached = true }),
    Text("%s"), Text("%p") } })
  Same(migrated.conditions[1].changes[1].property, "sub.4.text_color", "hidden and detached texts skipped")
  migrated = RemainingLegacy({ subRegions = { Text("%s") } })
  Same(migrated.conditions, nil, "no duration text, no condition")
  Same(migrated.blizzardAuraDisplay.remainingTimeColorEnabled, true, "no duration text, flag kept")
  migrated = Migrate({ subRegions = { Text("%p") } }, { remainingTimeColorEnabled = false })
  Same(migrated.conditions, nil, "remaining flag false")
  migrated = Data({ subRegions = { Text("%p") }, conditions = { Rule("faAuraPandemic", nil, nil, {}) },
    blizzardAuraDisplay = { remainingTimeColorEnabled = true, missingDesaturate = true } })
  Display.MigrateNativeConditions(migrated)
  Same(#migrated.conditions, 3, "both migrations")
  Same(migrated.conditions[2].check.variable, "faAuraMissing", "missing first")
  Same(migrated.conditions[3].check.variable, "faAuraRemaining", "remaining second")

  -- Duration color curve
  local function Curve(auraData, property, base, window)
    local before = #curves
    local result = Display.DurationColorCondition(auraData, base or { 1, 1, 1, 1 }, property or "sub.1.text_color", window)
    if result then
      Same(#curves, before + 1, "one curve built")
      Same(result.curve, curves[#curves], "returned curve")
      Same(curves[#curves].kind, Enum.LuaCurveType.Step, "step curve")
    else
      Same(#curves, before, "no curve built")
    end
    return result, curves[#curves]
  end
  local function Points(curve)
    local list = {}
    for _, point in ipairs(curve.points) do list[#list + 1] = point.x end
    return list
  end
  local function DurationData(rules, extra)
    return Data({ subRegions = { Text("%p") }, conditions = rules })
  end
  local red = { 1, 0, 0, 1 }
  local result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) }))
  Same(result.property, Enum.DurationTextBindingProperty.RemainingDuration, "remaining binding")
  assert(#curve.points == 2, "two breakpoints")
  Near(curve.points[1].x, 0, "first breakpoint")
  Near(curve.points[2].x, 10, "threshold breakpoint")
  Near(select(2, RGBA(curve.points[1].color)), 0, "below threshold, rule color")
  Near(select(1, RGBA(curve.points[1].color)), 1, "below threshold red")
  Near(select(2, RGBA(curve.points[2].color)), 1, "at threshold with <, base color")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", ">=", 10, { Change("sub.1.text_color", red) }) }))
  Near(select(2, RGBA(curve.points[1].color)), 1, "below threshold with >=, base color")
  Near(select(2, RGBA(curve.points[2].color)), 0, "at threshold with >=, rule color")
  result, curve = Curve(DurationData({ Rule("faAuraRemainingPercent", "<", 50, { Change("sub.1.text_color", red) }) }))
  Same(result.property, Enum.DurationTextBindingProperty.RemainingPercent, "percent binding")
  Near(curve.points[2].x, 0.5, "percent threshold divided by 100")
  result, curve = Curve(DurationData({ Rule("faAuraElapsed", "<", 3, { Change("sub.1.text_color", red) }) }))
  Same(result.property, Enum.DurationTextBindingProperty.ElapsedDuration, "elapsed binding")
  result, curve = Curve(DurationData({ Rule("faAuraTotal", ">=", 3, { Change("sub.1.text_color", red) }) }))
  Same(result.property, Enum.DurationTextBindingProperty.TotalDuration, "total binding")
  result, curve = Curve(DurationData({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.1.text_color", { 0, 0, 1, 1 }) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.1.text_color", { 0, 1, 0, 1 }) }),
  }))
  Same(#curve.points, 3, "sorted breakpoints")
  assert(curve.points[2].x == 5 and curve.points[3].x == 10, "breakpoint order")
  assert(select(3, RGBA(curve.points[1].color)) == 0 and select(2, RGBA(curve.points[1].color)) == 1, "last matching rule wins")
  Near(select(1, RGBA(curve.points[3].color)), 1, "above all thresholds, base color")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", { 2, -1, "x", 0.5 }) }) }))
  local r, g, b, a = RGBA(curve.points[1].color)
  assert(r == 1 and g == 0 and b == 1 and a == 0.5, "rule color clamped, bad channel falls back to white")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", "bad") }) }))
  r, g, b, a = RGBA(curve.points[1].color)
  assert(r == 1 and g == 1 and b == 1 and a == 1, "rule color not a table")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) }), nil, "bad")
  Near(select(1, RGBA(curve.points[2].color)), 1, "base color not a table")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_visible", false) }) }))
  Near(select(4, RGBA(curve.points[1].color)), 0, "hidden below threshold")
  Near(select(4, RGBA(curve.points[2].color)), 1, "visible above threshold")
  local hiddenBase = DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_visible", true) }) })
  hiddenBase.subRegions[1].text_visible = false
  result, curve = Curve(hiddenBase)
  Near(select(4, RGBA(curve.points[1].color)), 1, "shown by the rule")
  Near(select(4, RGBA(curve.points[2].color)), 0, "hidden by the base element")
  local forcedCopy = DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) })
  forcedCopy.nativeConditionBaseData = Data({ subRegions = { Text("%p", { text_visible = false }) } })
  result, curve = Curve(forcedCopy)
  Near(select(4, RGBA(curve.points[2].color)), 0, "base visibility read from the original data")
  Display.ForgetConditionRules(forcedCopy)

  assert(Curve(DurationData({})) == nil, "no rules, no window")
  assert(Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) }), "sub.2.text_color") == nil,
    "other property")
  for label, rule in pairs({
    linked = Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }, true),
    negative = Rule("faAuraRemaining", "<", -1, { Change("sub.1.text_color", red) }),
    infinite = Rule("faAuraRemaining", "<", math.huge, { Change("sub.1.text_color", red) }),
    nan = Rule("faAuraRemaining", "<", 0 / 0, { Change("sub.1.text_color", red) }),
    text = Rule("faAuraRemaining", "<", "abc", { Change("sub.1.text_color", red) }),
    operator = Rule("faAuraRemaining", ">", 10, { Change("sub.1.text_color", red) }),
    channel = Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_text", "x") }),
    stack = Rule("faAuraApplications", ">=", 2, { Change("sub.1.text_color", red) }),
  }) do
    assert(Curve(DurationData({ rule })) == nil, "ignored rule: " .. label)
  end
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", "10", { Change("sub.1.text_color", red) }) }))
  assert(result, "numeric string threshold")
  assert(Curve(DurationData({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }),
    Rule("faAuraElapsed", "<", 3, { Change("sub.1.text_color", red) }),
  })) == nil, "two time bases on one text")
  Without(Enum.DurationTextBindingProperty, "ElapsedDuration", function()
    assert(Curve(DurationData({ Rule("faAuraElapsed", "<", 3, { Change("sub.1.text_color", red) }) })) == nil, "missing binding")
  end)
  Without(C_CurveUtil, "CreateColorCurve", function()
    assert(Display.DurationColorCondition(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) }),
      red, "sub.1.text_color") == nil, "unsupported client")
  end)
  local textRegion = Data({ regionType = "text", displayText = "%p",
    conditions = { Rule("faAuraRemaining", "<", 10, { Change("color", red) }) } })
  result, curve = Curve(textRegion, "color")
  assert(result, "root text color")

  -- Remaining window
  local windowRules = DurationData({})
  result, curve = Curve(windowRules, nil, nil, { ">=", 5 })
  Same(#curve.points, 3, "window breakpoints")
  Near(curve.points[2].x, 5, "window limit")
  assert(curve.points[3].x > 5 and curve.points[3].x < 5.01, "window edge just above the limit")
  Near(select(4, RGBA(curve.points[1].color)), 0, "outside the window, hidden")
  Near(select(4, RGBA(curve.points[2].color)), 1, "at the window limit, shown")
  result, curve = Curve(windowRules, nil, nil, { "<", 5 })
  Near(select(4, RGBA(curve.points[1].color)), 1, "inside a < window")
  Near(select(4, RGBA(curve.points[2].color)), 0, "limit of a < window")
  result, curve = Curve(DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) }), nil, nil, { "<", 5 })
  Same(#curve.points, 4, "rules and window combined")
  assert(Curve(DurationData({ Rule("faAuraElapsed", "<", 3, { Change("sub.1.text_color", red) }) }), nil, nil, { "<", 5 }) == nil,
    "window with a non remaining basis")
  Display.ForgetConditionRules(windowRules)

  -- Cached rules
  local cached = DurationData({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) })
  assert(Curve(cached), "rules found")
  cached.conditions = {}
  assert(Curve(cached), "rules cached per aura")
  Display.ForgetConditionRules(cached)
  assert(Curve(cached) == nil, "rules forgotten")
  Display.ForgetConditionRules({})

  -- Stack text
  local function StackData(rules, text)
    return Data({ subRegions = { Text(text or "%s") }, conditions = rules })
  end
  local function StackOf(auraData, count) return Display.StackTextFor(auraData, "sub.1.text_color", count) end
  local plain = StackData({})
  Same(StackOf(plain, 1), "", "single stack hidden")
  Same(StackOf(plain, 0), "", "zero stack hidden")
  Same(StackOf(plain, 2), "2", "two stacks")
  Same(StackOf(plain, 12), "12", "many stacks")
  local colored = StackData({ Rule("faAuraApplications", ">=", 5, { Change("sub.1.text_color", red) }) })
  Same(StackOf(colored, 1), "", "colored, hidden at one")
  Same(StackOf(colored, 3), "3", "colored, below threshold")
  Same(StackOf(colored, 5), "|cffff0000" .. "5|r", "colored at threshold")
  Same(StackOf(colored, 9), "|cffff0000" .. "9|r", "colored above threshold")
  local worded = StackData({
    Rule("faAuraApplications", "==", 1, { Change("sub.1.text_text", "One") }),
    Rule("faAuraApplications", ">=", 4, { Change("sub.1.text_text", "50%") }),
    Rule("faAuraApplications", ">=", 4, { Change("sub.1.text_color", { 0, 0, 1, 1 }) }),
  })
  Same(StackOf(worded, 1), "One", "text rule shown at one stack")
  Same(StackOf(worded, 2), "2", "between text rules")
  Same(StackOf(worded, 4), "|cff0000ff" .. "50%|r", "literal percent, colored")
  Same(StackOf(worded, 0), "", "zero below every rule")
  local vanishing = StackData({ Rule("faAuraApplications", ">", 3, { Change("sub.1.text_visible", false) }) })
  Same(StackOf(vanishing, 3), "3", "visible up to the threshold")
  Same(StackOf(vanishing, 4), "", "hidden above the threshold")
  local reshown = StackData({ Rule("faAuraApplications", "<", 2, { Change("sub.1.text_visible", true) }) })
  Same(StackOf(reshown, 1), "1", "shown at one by a rule")
  local fractional = StackData({ Rule("faAuraApplications", "<=", 2.5, { Change("sub.1.text_color", red) }) })
  Same(StackOf(fractional, 2), "|cffff0000" .. "2|r", "fractional threshold below")
  Same(StackOf(fractional, 3), "3", "fractional threshold above")
  local invalidStack = StackData({
    Rule("faAuraApplications", "<", -1, { Change("sub.1.text_color", red) }),
    Rule("faAuraApplications", "~", 3, { Change("sub.1.text_color", red) }),
    Rule("faAuraApplications", ">=", 3, { Change("sub.1.text_color", red) }, true),
    Rule("faAuraApplications", ">=", math.huge, { Change("sub.1.text_color", red) }),
    Rule("faAuraRemaining", ">=", 3, { Change("sub.1.text_color", red) }),
  })
  Same(StackOf(invalidStack, 5), "5", "invalid stack rules ignored")
  Same(Display.StackTextFor(colored, "sub.2.text_color", 5), "5", "rules of another property")
  local rootStack = Data({ regionType = "text", displayText = "%s",
    conditions = { Rule("faAuraApplications", ">=", 2, { Change("color", red) }) } })
  Same(Display.StackTextFor(rootStack, "color", 2), "|cffff0000" .. "2|r", "root text stacks")
  for _, operator in ipairs({ "<", ">=", ">", "<=", "==", "~=" }) do
    local operatorData = StackData({ Rule("faAuraApplications", operator, 3, { Change("sub.1.text_text", "hit") }) })
    local expected = { ["<"] = { 2 }, [">="] = { 3, 4 }, [">"] = { 4 }, ["<="] = { 2, 3 }, ["=="] = { 3 }, ["~="] = { 2, 4 } }
    for _, count in ipairs({ 2, 3, 4 }) do
      local want = false
      for _, hit in ipairs(expected[operator]) do if hit == count then want = true end end
      Same(StackOf(operatorData, count) == "hit", want, "stack operator " .. operator .. " at " .. count)
    end
  end

  -- Stack formatter
  assert(Display.StackTextCondition(plain, "sub.1.text_color") == nil, "no rules, no formatter")
  local formatter = Display.StackTextCondition(colored, "sub.1.text_color")
  assert(formatter == formatters[#formatters], "formatter returned")
  local thresholds, formats = {}, {}
  for _, step in ipairs(formatter.steps) do thresholds[#thresholds + 1] = step.threshold; formats[#formats + 1] = step.format end
  Same(table.concat(thresholds, ","), "0,2,5,6", "stack breakpoints")
  Same(formats[1], "", "hidden at zero")
  Same(formats[2], "%d", "plain at two")
  Same(formats[3], "|cffff0000%d|r", "colored breakpoint")
  Same(formats[4], "|cffff0000%d|r", "colored above")
  formatter = Display.StackTextCondition(worded, "sub.1.text_color")
  thresholds, formats = {}, {}
  for _, step in ipairs(formatter.steps) do thresholds[#thresholds + 1] = step.threshold; formats[#formats + 1] = step.format end
  Same(table.concat(thresholds, ","), "0,1,2,4,5", "text rule breakpoints")
  Same(formats[2], "One", "text rule format")
  Same(formats[4], "|cff0000ff50%%|r", "percent doubled in the format")
  Without(C_StringUtil, "CreateNumericRuleFormatter", function()
    assert(Display.StackTextCondition(colored, "sub.1.text_color") == nil, "no formatter factory")
  end)

  -- Property types
  assert(Display.IsNativeConditionProperty(Data(), "chat") == false, "action property")
  assert(Display.IsNativeConditionProperty(Data(), "glowexternal") == false, "external glow action")
  assert(Display.IsNativeConditionProperty(Data(), "color") == true, "icon color")
  assert(Display.IsNativeConditionProperty(Data(), "zoom") == true, "icon zoom")
  assert(Display.IsNativeConditionProperty(Data(), "fontSize") == false, "icon font size")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "model" }), "color") == false, "unsupported region")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "aurabar" }), "barColor") == true, "bar color")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "progresstexture" }), "desaturateForeground") == true, "progress")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "text", displayText = "hello" }), "displayText") == true, "literal text")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "text", displayText = "%p" }), "displayText") == false, "code text")
  assert(Display.IsNativeConditionProperty(Data({ regionType = "text", displayText = "%p" }), "fontSize") == true, "text size")
  local subData = Data({ subRegions = { Text("hello"), Text("%p"), Glow(false), Text("x", { secretAuraDetached = true }) } })
  assert(Display.IsNativeConditionProperty(subData, "sub.1.text_text") == true, "literal element text")
  assert(Display.IsNativeConditionProperty(subData, "sub.2.text_text") == false, "code element text")
  assert(Display.IsNativeConditionProperty(subData, "sub.2.text_alpha") == true, "element alpha")
  assert(Display.IsNativeConditionProperty(subData, "sub.3.glow") == true, "glow")
  assert(Display.IsNativeConditionProperty(subData, "sub.3.glowType") == false, "glow type")
  assert(Display.IsNativeConditionProperty(subData, "sub.4.text_color") == false, "detached element")
  assert(Display.IsNativeConditionProperty(subData, "sub.9.text_color") == false, "missing element")
  assert(Display.IsNativeConditionProperty(subData, "bogus") == false, "unknown property")

  -- Highlight definitions
  local definitions = {}
  Same(Display.FilterConditionProperties(Data({ regionType = "model" }), definitions), definitions, "same table, disabled")
  Same(next(definitions), nil, "nothing added when disabled")
  Same(Display.FilterConditionProperties(Data(), definitions), definitions, "same table, enabled")
  local keys = {}
  for key in pairs(definitions) do keys[#keys + 1] = key end
  table.sort(keys)
  Same(table.concat(keys, ","), "faAuraHighlightColor,faAuraHighlightPulse,faAuraHighlightSize,faAuraHighlightStyle,faAuraHighlightTexture",
    "highlight keys")
  Same(definitions.faAuraHighlightColor.type, "color", "color type")
  Same(definitions.faAuraHighlightColor.default[2], 0.82, "color default")
  Same(definitions.faAuraHighlightStyle.type, "list", "style type")
  Same(definitions.faAuraHighlightStyle.default, "border", "style default")
  local styles = {}
  for key in pairs(definitions.faAuraHighlightStyle.values) do styles[#styles + 1] = key end
  table.sort(styles)
  Same(table.concat(styles, ","), "border,glow,overlay,pulseBorder,pulseGlow,texture", "style values")
  Same(definitions.faAuraHighlightPulse.default, 1, "pulse default")
  Same(definitions.faAuraHighlightPulse.min, 0.2, "pulse min")
  Same(definitions.faAuraHighlightPulse.max, 5, "pulse max")
  Same(definitions.faAuraHighlightSize.default, 2, "size default")
  Same(definitions.faAuraHighlightSize.max, 64, "size max")
  Same(definitions.faAuraHighlightTexture.type, "string", "texture type")
  Same(definitions.faAuraHighlightTexture.default, "Interface\\Buttons\\UI-ActionButton-Border", "texture default")

  Same(Display.HighlightBorderLimit(Data({ width = 100, height = 60 })), 15, "limit from the smaller side")
  Same(Display.HighlightBorderLimit(Data({ width = 30, height = 90 })), 7, "limit rounds down")
  Same(Display.HighlightBorderLimit(Data({ width = 3, height = 3 })), 1, "limit at least one")
  Same(Display.HighlightBorderLimit(Data()), 16, "limit of the default size")

  local sizeDefinition = { type = "number", max = 64, display = "Size" }
  local sizeData = Data({ width = 80, height = 40 })
  local function SizeOptions(...)
    local changes = {}
    for index, value in ipairs({ ... }) do changes[index] = Change("faAuraHighlightStyle", value) end
    return Display.HighlightPropertyOptions(sizeData, { changes = changes }, "faAuraHighlightSize", sizeDefinition)
  end
  Same(Display.HighlightPropertyOptions(sizeData, {}, "faAuraHighlightColor", sizeDefinition), sizeDefinition, "other property untouched")
  Same(Display.HighlightPropertyOptions(sizeData, {}, "faAuraHighlightSize", nil), nil, "no definition")
  local borderOptions, pulseBorderOptions = SizeOptions(), SizeOptions("pulseBorder")
  assert(borderOptions ~= sizeDefinition and sizeDefinition.max == 64 and sizeDefinition.display == "Size", "definition copied")
  Same(borderOptions.max, 10, "border limit")
  Same(pulseBorderOptions.max, 10, "pulsing border limit")
  Same(pulseBorderOptions.display, borderOptions.display, "pulsing border label")
  Same(pulseBorderOptions.description, borderOptions.description, "pulsing border hint")
  local paddingOptions = SizeOptions("glow")
  Same(paddingOptions.max, 64, "padding maximum")
  assert(paddingOptions.display ~= borderOptions.display and paddingOptions.description ~= borderOptions.description,
    "padding label and hint differ")
  assert(type(borderOptions.display) == "string" and borderOptions.display ~= "" and type(paddingOptions.description) == "string"
    and paddingOptions.description ~= "", "labels are texts")
  for _, style in ipairs({ "pulseGlow", "overlay", "texture" }) do Same(SizeOptions(style).max, 64, "padding style " .. style) end
  Same(SizeOptions("glow", "border").max, 10, "last style change wins")
  Same(Display.HighlightPropertyOptions(sizeData, {}, "faAuraHighlightSize", sizeDefinition).max, 10, "no change, border")

  -- Templates
  local templates = { [1] = { x = 1 }, [2] = { y = 2 }, [3] = { z = 3 }, [4] = { w = 4 } }
  local original = {}
  for index, entry in pairs(templates) do original[index] = entry end
  local multi = Data({ triggers = { { trigger = { type = "secretAura" } }, { trigger = { type = "aura2" } },
    { trigger = { type = "secretAura" } } }, conditions = {
    { check = { variable = "AND", checks = { { trigger = 3, variable = "faAuraStart" }, { trigger = 1, variable = "faAuraEnd" } } } },
  } })
  Same(Display.FilterConditionTemplates(Data({ regionType = "model" }), templates), templates, "disabled keeps the table")
  Same(templates[1], original[1], "disabled keeps the entries")
  local filtered = Display.FilterConditionTemplates(multi, templates)
  Same(filtered, templates, "enabled keeps the table")
  Same(filtered[2], original[2], "non secret trigger untouched")
  Same(filtered[4], original[4], "trigger without entry untouched")
  assert(filtered[1] ~= original[1] and filtered[1].x == nil, "secret trigger replaced")
  local fixed = { faAuraPandemic = "alwaystrue", faAuraStealable = "alwaystrue", faAuraNotStealable = "alwaystrue",
    faAuraPresent = "alwaystrue", faAuraMissing = "alwaystrue", faAuraType = "select", faAuraDispel = "select",
    faAuraApplications = "number", faAuraRemaining = "number", faAuraRemainingPercent = "number", faAuraElapsed = "number",
    faAuraElapsedPercent = "number", faAuraTotal = "number" }
  local labels = {}
  for variable, kind in pairs(fixed) do
    local entry = filtered[1][variable]
    assert(entry, "template " .. variable)
    Same(entry.type, kind, "template type " .. variable)
    assert(type(entry.display) == "string" and entry.display ~= "" and not labels[entry.display], "template label " .. variable)
    labels[entry.display] = true
  end
  assert(filtered[1].faAuraStart == nil, "start not offered on a trigger that does not use it")
  Same(filtered[1].faAuraEnd.operator_types, "native_aura_duration", "end offered where used")
  Same(filtered[1].faAuraRemaining.operator_types, "native_aura_duration", "duration operators")
  Same(filtered[1].faAuraType.operator_types, "native_aura_dispel", "type operators")
  Same(filtered[1].faAuraType.values.HELPFUL ~= nil and filtered[1].faAuraType.values.HARMFUL ~= nil, true, "type values")
  local dispelKeys = {}
  for key in pairs(filtered[1].faAuraDispel.values) do dispelKeys[#dispelKeys + 1] = key end
  table.sort(dispelKeys)
  Same(table.concat(dispelKeys, ","), "Bleed,Curse,Disease,Enrage,Magic,None,Poison", "dispel values")
  Same(filtered[1].faAuraDispel.operator_types, "native_aura_dispel", "dispel operators")
  assert(filtered[3].faAuraStart.type == "number" and filtered[3].faAuraEnd == nil, "start offered on the trigger that uses it")
  local plainTemplates = Display.FilterConditionTemplates(Data(), { [1] = {} })
  assert(plainTemplates[1].faAuraStart == nil and plainTemplates[1].faAuraEnd == nil, "start and end hidden when unused")
  local otherTrigger = Data({ triggers = { { trigger = { type = "secretAura" } }, { trigger = { type = "secretAura" } } },
    conditions = { Rule("faAuraStart", ">=", 1, {}) } })
  local offered = Display.FilterConditionTemplates(otherTrigger, { [1] = {}, [2] = {} })
  assert(offered[1].faAuraStart and offered[2].faAuraStart == nil, "start offered on the trigger that uses it")
  Without(C_CurveUtil, "CreateColorCurve", function()
    local limited = Display.FilterConditionTemplates(Data(), { [1] = {} })[1]
    assert(limited.faAuraRemaining == nil and limited.faAuraTotal == nil, "no durations without curves")
    assert(limited.faAuraApplications and limited.faAuraPandemic, "other templates kept")
  end)
  Without(C_StringUtil, "CreateNumericRuleFormatter", function()
    local limited = Display.FilterConditionTemplates(Data(), { [1] = {} })[1]
    assert(limited.faAuraApplications == nil and limited.faAuraRemaining, "no stack count without formatter")
  end)
  Without(Enum.DurationTextBindingProperty, "TotalDuration", function()
    local limited = Display.FilterConditionTemplates(Data(), { [1] = {} })[1]
    assert(limited.faAuraTotal == nil and limited.faAuraRemaining, "duration without binding hidden")
  end)

  -- Validation
  local function Problem(rules, extra)
    local validated = Data(extra)
    validated.conditions = rules
    return Display.ValidateConditions(validated)
  end
  local messages = {}
  local function Expect(label, problem)
    assert(type(problem) == "string" and problem ~= "", label .. ": no problem reported")
    for other, text in pairs(messages) do assert(text ~= problem or other == label, label .. " shares its message with " .. other) end
    messages[label] = problem
  end
  local function Alias(label, base, problem)
    assert(problem and problem == messages[base], label .. ": expected the message of " .. base)
  end
  local validSubs = { Glow(false), Glow(false), Text("%p"), Text("%s") }
  local function V(rules, extra)
    extra = extra or {}
    extra.subRegions = extra.subRegions or validSubs
    return Problem(rules, extra)
  end
  Same(Display.ValidateConditions(Data({ conditions = false })), nil, "no conditions")
  Same(V({}), nil, "empty conditions")
  Same(V({ Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_color", red) }) }), nil, "valid duration color")
  Same(V({ Rule("faAuraRemaining", nil, 10, { Change("sub.3.text_color", red) }) }), nil, "operator may be unset")
  Same(V({ Rule("faAuraApplications", ">=", 3, { Change("sub.4.text_color", red) }) }), nil, "valid stack color")
  Same(V({ { check = { trigger = 2, variable = "x" }, changes = { Change("width", 3) } } },
    { triggers = { { trigger = { type = "secretAura" } }, { trigger = { type = "aura2" } } } }), nil, "ordinary condition")
  Same(V({ { check = { trigger = -1, variable = "x" } } }), nil, "global condition")
  Same(V({ { check = { variable = nil } } }), nil, "unfinished condition")
  Expect("foreign missing", V({ { check = { trigger = 7, variable = "x" } } }))
  assert(V({ { check = { trigger = 1, variable = "stacks" } } }) == messages["foreign missing"], "foreign unknown variable")
  Same(V({ { check = { trigger = 7, variable = "AND", checks = { { trigger = -1, variable = "x" } } } } }), nil, "group of globals")
  Same(select("#", V({ { check = { variable = "OR", checks = { { trigger = 1, variable = "stacks" } } } } })), 1, "one result")
  assert(V({ { check = { variable = "OR", checks = { { trigger = -1, variable = "x" }, { trigger = 1, variable = "stacks" } } } } }),
    "nested unknown variable")
  Expect("grouping", V({ { check = { variable = "AND", checks = { { trigger = 1, variable = "faAuraPandemic" } } } } }))
  Alias("linked", "grouping", V({ Rule("faAuraRemaining", "<", 10, {}), Rule("faAuraRemaining", "<", 5, {}, true) }))
  Alias("linked self", "grouping", V({ Rule("faAuraRemaining", "<", 10, {}, true) }))
  Expect("time operator", V({ Rule("faAuraRemaining", "==", 10, {}) }))
  Same(V({ Rule("faAuraRemaining", ">=", 10, {}) }), nil, ">= accepted")
  assert(V({ Rule("faAuraElapsed", ">", 10, {}) }) == messages["time operator"], "> refused for durations")
  assert(V({ Rule("faAuraTotal", "<=", 10, {}) }) == messages["time operator"], "<= refused for durations")
  Expect("type operator", V({ Rule("faAuraType", "<", "HELPFUL", {}) }))
  assert(V({ Rule("faAuraDispel", ">=", "Magic", {}) }) == messages["type operator"], "dispel operator")
  Same(V({ Rule("faAuraType", "==", "HELPFUL", {}) }), nil, "type ==")
  Same(V({ Rule("faAuraDispel", "~=", "Magic", {}) }), nil, "dispel ~=")
  Same(V({ Rule("faAuraType", nil, "HELPFUL", {}) }), nil, "type without operator")
  Expect("missing region", V({ Rule("faAuraMissing", nil, nil, {}) }, { regionType = "model" }))
  local missingTrigger = function(showOn) return { { trigger = { type = "secretAura", secretShowOn = showOn } } } end
  Expect("missing show on", V({ Rule("faAuraMissing", nil, nil, {}) }))
  Alias("missing show on active", "missing show on", V({ Rule("faAuraMissing", nil, nil, {}) }, { triggers = missingTrigger("showOnActive") }))
  Same(V({ Rule("faAuraMissing", nil, nil, {}) }, { triggers = missingTrigger("showOnMissing") }), nil, "missing with showOnMissing")
  Same(V({ Rule("faAuraMissing", nil, nil, {}) }, { triggers = missingTrigger("showAlways") }), nil, "missing with always")
  Same(V({ Rule("faAuraMissing", nil, nil, {}) }, { triggers = missingTrigger("bogus") }) ~= nil, true, "unknown show on is Aura Found")
  Expect("remaining glow operator", V({ Rule("faAuraRemaining", ">=", 10, { Change("sub.1.glow", true) }) }))
  Alias("remaining glow off", "remaining glow operator", V({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", false) }) }))
  Expect("elapsed glow operator", V({ Rule("faAuraElapsed", ">=", 10, { Change("sub.1.glow", true) }) }))
  Alias("elapsed glow off", "elapsed glow operator", V({ Rule("faAuraElapsed", "<", 10, { Change("sub.1.glow", false) }) }))
  Expect("pandemic glow off", V({ Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", false) }) }))
  Same(V({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", true) }) }), nil, "remaining glow valid")
  Same(V({ Rule("faAuraElapsed", "<", 10, { Change("sub.1.glow", true) }) }), nil, "elapsed glow valid")
  Same(V({ Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", true) }) }), nil, "pandemic glow valid")
  Expect("late glow remaining", V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", true) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.2.glow", true) }),
  }))
  Alias("late glow elapsed", "late glow remaining", V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", true) }),
    Rule("faAuraElapsed", "<", 5, { Change("sub.2.glow", true) }),
  }))
  Alias("late glow pandemic", "late glow remaining", V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", true) }),
    Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", true) }),
  }))
  Same(V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", true) }),
    Rule("faAuraPandemic", nil, nil, { Change("sub.2.glow", true) }),
  }), nil, "pandemic on another glow")
  Alias("late glow after a window", "late glow remaining", V({ Rule("faAuraRemaining", "<", 10, { Change("sub.2.glow", true) }) }, {
    triggers = { { trigger = { type = "secretAura", secretUseRem = true, secretRem = 8 } } },
    subRegions = { Glow(true), Glow(false) },
  }))
  Same(V({ Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", true) }) }, {
    triggers = { { trigger = { type = "secretAura", secretUseRem = true, secretRem = 8 } } },
    subRegions = { Glow(true), Glow(false) },
  }) ~= nil, true, "pandemic glow on the window glow")
  Expect("time basis", V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_color", red) }),
    Rule("faAuraElapsed", "<", 5, { Change("sub.3.text_visible", false) }),
  }))
  Same(V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_color", red) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.3.text_visible", false) }),
  }), nil, "same time basis twice")
  Same(V({
    Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_color", red) }),
    Rule("faAuraElapsed", "<", 5, { Change("sub.1.glow", true) }),
  }), nil, "different targets")
  Expect("property", V({ Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_text", "x") }) }))
  assert(V({ Rule("faAuraRemaining", "<", 10, { Change("width", 5) }) }) == messages.property, "unsupported property")
  assert(V({ Rule("faAuraApplications", ">=", 2, { Change("sub.3.text_color", red) }) }) == messages.property, "duration text for stacks")
  assert(V({ Rule("faAuraPandemic", nil, nil, { Change("sub.3.text_color", red) }) }) == messages.property, "text for pandemic")
  Same(V({ Rule("faAuraPandemic", nil, nil, { Change("faAuraHighlightColor", red) }) }), nil, "highlight for pandemic")
  Same(V({ Rule("faAuraRemaining", "<", 10, { { value = 3 } }) }), nil, "change without property")
  Same(V({ { check = { trigger = 1, variable = "faAuraRemaining", op = "<" } } }), nil, "condition without changes")
  Same(V({ Rule("faAuraRemaining", "<", 10, { Change("sub.3.text_color", red) }), { check = { trigger = 7, variable = "x" } } }) ~= nil,
    true, "later foreign condition")
  local first = V({ Rule("faAuraRemaining", "==", 10, {}), { check = { trigger = 7, variable = "x" } } })
  assert(first == messages["time operator"], "first problem returned")
  assert(V({ { check = { trigger = 7, variable = "x" } }, Rule("faAuraRemaining", "==", 10, {}) }) == messages["foreign missing"],
    "condition order")
  local header = V({ Rule("faAuraRemaining", "==", 10, { Change("sub.1.glow", true) }) })
  assert(header == messages["time operator"], "header problems before change problems")
  local glowFirst = V({ Rule("faAuraRemaining", "<", 10, { Change("sub.1.glow", false), Change("width", 3) }) })
  assert(glowFirst == messages["remaining glow operator"], "glow problem before property problem")

  -- Forced-on appearance copy
  local base = Data({ subRegions = { Glow(false), Text("%p", { text_visible = false }), Text("x") },
    conditions = { Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", true), Change("sub.1.text_color", red) }) } })
  Same(Display.PrepareConditionAppearance(base) == base, false, "glow forced on, copy")
  local appearance = Display.PrepareConditionAppearance(base)
  Same(appearance.nativeConditionBaseData, base, "base data kept")
  Same(appearance.subRegions[1].glow, true, "glow forced")
  Same(base.subRegions[1].glow, false, "original untouched")
  Same(appearance.subRegions[2], base.subRegions[2], "other elements shared")
  Same(appearance.id, base.id, "fields copied")
  Same(appearance.conditions, base.conditions, "conditions shared")
  Same(appearance.subRegions[1].type, "subglow", "element fields copied")
  local plainBase = Data({ subRegions = { Glow(false), Text("%p") }, conditions = {
    Rule("faAuraPandemic", nil, nil, { Change("sub.1.text_color", red), Change("sub.2.glow", true), Change(nil, true) }),
    Rule("faAuraRemaining", "<", 5, { Change("faAuraHighlightColor", red) }),
  } })
  Same(Display.PrepareConditionAppearance(plainBase), plainBase, "nothing forced, same data")
  local both = Data({ subRegions = { Glow(false), Text("%p", { text_visible = false }) }, conditions = {
    Rule("faAuraPandemic", nil, nil, { Change("sub.1.glow", false) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.2.text_visible", false), Change("sub.2.text_visible", false) }),
    Rule("faAuraRemaining", "<", 5, { Change("sub.2.glow", true) }),
  } })
  appearance = Display.PrepareConditionAppearance(both)
  Same(appearance.subRegions[1].glow, true, "forced even when the change turns it off")
  Same(appearance.subRegions[2].text_visible, true, "text forced visible")
  Same(both.subRegions[2].text_visible, false, "text original untouched")
  local detached = Data({ subRegions = { Text("x", { secretAuraDetached = true }) },
    conditions = { Rule("faAuraRemaining", "<", 5, { Change("sub.1.text_visible", false) }) } })
  Same(Display.PrepareConditionAppearance(detached), detached, "detached text not forced")
  local twice = Data({ subRegions = { Text("%p", { text_visible = false }) }, conditions = {
    Rule("faAuraRemaining", "<", 5, { Change("sub.1.text_visible", true) }),
    Rule("faAuraRemaining", "<", 3, { Change("sub.1.text_visible", true) }),
  } })
  appearance = Display.PrepareConditionAppearance(twice)
  Same(appearance.subRegions[1].text_visible, true, "same element forced twice")
  local textOnGlow = Data({ subRegions = { Glow(false) },
    conditions = { Rule("faAuraRemaining", "<", 5, { Change("sub.1.text_visible", true) }) } })
  Same(Display.PrepareConditionAppearance(textOnGlow), textOnGlow, "text key on a glow element")
  Same(Display.PrepareConditionAppearance(Data({ conditions = false })).id, "Test Aura", "no conditions")


  -- Property application on fake native buttons
  local function Native()
    return {
      icon = Recorder(), cooldown = Recorder(), mainText = Recorder(), bar = Recorder(), barBackground = Recorder(),
      progressTexture = { texture = Recorder() }, progressBackground = Recorder(),
      sharedElements = { { text = Recorder(), elementFrames = { glow = Recorder() } }, { text = Recorder(), elementFrames = { glow = Recorder() } } },
    }
  end
  local function Region(auraData, buttons, missing)
    local instance = { buttons = buttons, single = missing and { missing = { native = missing } } or nil }
    return { blizzardAuraDisplay = { active = true, data = auraData, instances = { instance } } }
  end
  local appliedData = Data({ subRegions = { Text("hello"), Text("%s"), Glow(false) } })
  local button = Native()
  local region = Region(appliedData, { button })
  Display.SetConditionProperty(region, "color", 1, 0.5, 0.25, 1)
  local r1, g1, b1, a1 = Last(button.icon, "SetVertexColor")
  assert(r1 == 1 and g1 == 0.5 and b1 == 0.25 and a1 == 1, "icon color applied")
  Same(region.secretAuraConditionValues.color[2], 0.5, "color stored as a list")
  Display.SetConditionProperty(region, "color", 1, 0.5, 0.25, 1)
  Same(CountCalls(button.icon, "SetVertexColor"), 1, "same color not applied twice")
  Display.SetConditionProperty(region, "color", 1, 0.5, 0.25, 0.5)
  Same(CountCalls(button.icon, "SetVertexColor"), 2, "different color applied")
  Display.SetConditionProperty(region, "desaturate", true)
  Same(Last(button.icon, "SetDesaturated"), true, "desaturate applied")
  Display.SetConditionProperty(region, "desaturate", true)
  Same(CountCalls(button.icon, "SetDesaturated"), 1, "same boolean not applied twice")
  Display.SetConditionProperty(region, "desaturate", false)
  Same(Last(button.icon, "SetDesaturated"), false, "boolean change applied")
  Display.SetConditionProperty(region, "inverse", true)
  Same(Last(button.cooldown, "SetReverse"), true, "reverse")
  Display.SetConditionProperty(region, "cooldownSwipe", false)
  Same(Last(button.cooldown, "SetDrawSwipe"), false, "swipe")
  Display.SetConditionProperty(region, "cooldownEdge", true)
  Same(Last(button.cooldown, "SetDrawEdge"), true, "edge")
  Display.SetConditionProperty(region, "cooldownTextDisabled", true)
  Same(Last(button.cooldown, "SetHideCountdownNumbers"), true, "countdown numbers")
  Display.SetConditionProperty(region, "zoom", 0.2)
  assert(CountCalls(button.icon, "SetTexCoord") >= 1, "zoom applies texture coordinates")
  Display.SetConditionProperty(region, "chat", "x")
  Same(region.secretAuraConditionValues.chat, "x", "action property stored")
  Display.SetConditionProperty(region, "fontSize", 12)
  Same(region.secretAuraConditionValues.fontSize, nil, "unknown property for the region ignored")
  Display.SetConditionProperty(region, "sub.1.text_color", 0, 1, 0, 1)
  Same(Last(button.sharedElements[1].text, "SetTextColor"), 0, "element color")
  Display.SetConditionProperty(region, "sub.1.text_text", "50%%")
  Same(Last(button.sharedElements[1].text, "SetText"), "50%", "element text, percent unescaped")
  Display.SetConditionProperty(region, "sub.2.text_text", "never")
  Same(CountCalls(button.sharedElements[2].text, "SetText"), 0, "code text refused")
  Display.SetConditionProperty(region, "sub.1.text_fontSize", 14)
  Same(select(2, Last(button.sharedElements[1].text, "SetFont")), 14, "element font size")
  Display.SetConditionProperty(region, "sub.1.text_visible", false)
  Same(Last(button.sharedElements[1].text, "SetAlpha"), 0, "hidden element")
  Display.SetConditionProperty(region, "sub.1.text_alpha", 0.5)
  Same(Last(button.sharedElements[1].text, "SetAlpha"), 0, "alpha kept hidden")
  Display.SetConditionProperty(region, "sub.1.text_visible", true)
  Same(Last(button.sharedElements[1].text, "SetAlpha"), 0.5, "shown with the stored alpha")
  Display.SetConditionProperty(region, "sub.3.glow", true)
  Same(CountCalls(button.sharedElements[1].elementFrames.glow, "SetAlpha"), 0, "no shared entry for a missing slot")
  appliedData.subRegions[1], appliedData.subRegions[3] = appliedData.subRegions[3], appliedData.subRegions[1]
  Display.SetConditionProperty(region, "sub.1.glow", true)
  Same(Last(button.sharedElements[1].elementFrames.glow, "SetAlpha"), 1, "glow on")
  Display.SetConditionProperty(region, "sub.1.glow", false)
  Same(Last(button.sharedElements[1].elementFrames.glow, "SetAlpha"), 0, "glow off")
  Display.SetConditionProperty(region, "sub.1.text_anchorXOffset", 3)
  Display.SetConditionProperty({ blizzardAuraDisplay = { active = false } }, "color", 1, 1, 1, 1)
  Display.SetConditionProperty({}, "color", 1, 1, 1, 1)

  local secretRegion = Region(Data(), { Native() })
  local secretButton = secretRegion.blizzardAuraDisplay.instances[1].buttons[1]
  local secretValue = test.Secret.Wrap(true)
  Display.SetConditionProperty(secretRegion, "desaturate", secretValue)
  Display.SetConditionProperty(secretRegion, "desaturate", secretValue)
  Same(CountCalls(secretButton.icon, "SetDesaturated"), 2, "secret values always applied")

  local restricted = Region(Data(), { Native() })
  local restrictedButton = restricted.blizzardAuraDisplay.instances[1].buttons[1]
  local isRestricted = WeakAuras.IsRestricted
  WeakAuras.IsRestricted = function() return true end
  Display.SetConditionProperty(restricted, "desaturate", true)
  Same(CountCalls(restrictedButton.icon, "SetDesaturated"), 0, "nothing applied while restricted")
  Same(restricted.secretAuraConditionValues.desaturate, true, "value still stored while restricted")
  restrictedButton.preview = true
  Display.SetConditionProperty(restricted, "desaturate", false)
  Same(Last(restrictedButton.icon, "SetDesaturated"), false, "preview ignores the restriction")
  WeakAuras.IsRestricted = isRestricted

  local owned = Data({ subRegions = { Text("%p") }, conditions = { Rule("faAuraRemaining", "<", 10, { Change("sub.1.text_color", red) }) } })
  local ownedRegion = Region(owned, { Native() })
  Display.SetConditionProperty(ownedRegion, "sub.1.text_color", 0, 0, 1, 1)
  Same(CountCalls(ownedRegion.blizzardAuraDisplay.instances[1].buttons[1].sharedElements[1].text, "SetTextColor"), 0,
    "duration color left to the curve")
  Display.ForgetConditionRules(owned)
  local stacked = Data({ subRegions = { Text("%s") }, conditions = { Rule("faAuraApplications", ">=", 3, { Change("sub.1.text_color", red) }) } })
  local stackedRegion = Region(stacked, { Native() })
  Display.SetConditionProperty(stackedRegion, "sub.1.text_color", 0, 0, 1, 1)
  Same(CountCalls(stackedRegion.blizzardAuraDisplay.instances[1].buttons[1].sharedElements[1].text, "SetTextColor"), 0,
    "stack color left to the formatter")
  Display.ForgetConditionRules(stacked)

  local textual = Data({ regionType = "text", displayText = "hello" })
  local textButton = Native()
  local textRegion2 = Region(textual, { textButton })
  Display.SetConditionProperty(textRegion2, "color", 1, 0, 0, 1)
  Same(Last(textButton.mainText, "SetTextColor"), 1, "main text color")
  Same(CountCalls(textButton.icon, "SetVertexColor"), 0, "icon untouched on a text region")
  Display.SetConditionProperty(textRegion2, "fontSize", 20)
  Same(select(2, Last(textButton.mainText, "SetFont")), 20, "main font size")
  Display.SetConditionProperty(textRegion2, "displayText", "a%%b")
  Same(Last(textButton.mainText, "SetText"), "a%b", "main text")
  local barData = Data({ regionType = "aurabar" })
  local barButton = Native()
  local barRegion = Region(barData, { barButton })
  Display.SetConditionProperty(barRegion, "barColor", 1, 0, 0, 1)
  Same(Last(barButton.bar, "SetStatusBarColor"), 1, "bar color")
  Display.SetConditionProperty(barRegion, "icon_color", 0, 1, 0, 1)
  Same(select(2, Last(barButton.icon, "SetVertexColor")), 1, "bar icon color")
  Display.SetConditionProperty(barRegion, "backgroundColor", 0, 0, 1, 1)
  Same(CountCalls(barButton.progressBackground, "SetColor"), 1, "background through the progress background")
  barButton.progressBackground = nil
  Display.SetConditionProperty(barRegion, "backgroundColor", 0, 1, 1, 1)
  Same(select(2, Last(barButton.barBackground, "SetColorTexture")), 1, "background through the bar background")
  local progressData = Data({ regionType = "progresstexture" })
  local progressButton = Native()
  local progressRegion = Region(progressData, { progressButton })
  Display.SetConditionProperty(progressRegion, "foregroundColor", 1, 0, 0, 1)
  Same(Last(progressButton.progressTexture.texture, "SetVertexColor"), 1, "foreground color")
  Display.SetConditionProperty(progressRegion, "desaturateForeground", true)
  Same(Last(progressButton.progressTexture.texture, "SetDesaturated"), true, "foreground desaturation")

  -- Missing display and appearance refresh
  local missingData = Data({ subRegions = { Text("%p"), Glow(false) }, conditions = {
    Rule("faAuraMissing", nil, nil, { Change("desaturate", true), Change("sub.1.text_color", { 1, 0, 0, 1 }),
      Change("faAuraHighlightColor", { 1, 1, 1, 1 }), Change("fontSize", 9), Change("sub.2.glow", true) }),
    Rule("faAuraMissing", nil, nil, { Change("desaturate", false), Change("zoom", nil) }),
    Rule("faAuraPandemic", nil, nil, { Change("color", { 0, 0, 1, 1 }) }),
  } })
  local missingButton = Native()
  Display.ApplyMissingConditions(missingButton, missingData)
  Same(Last(missingButton.icon, "SetDesaturated"), false, "last missing value wins")
  Same(CountCalls(missingButton.icon, "SetVertexColor"), 0, "other kinds ignored")
  Same(CountCalls(missingButton.icon, "SetTexCoord"), 0, "nil value skipped")
  Same(Last(missingButton.sharedElements[1].text, "SetTextColor"), 1, "allowed element color")
  Same(CountCalls(missingButton.mainText, "SetFont"), 0, "refused property skipped")
  Same(Last(missingButton.sharedElements[2].elementFrames.glow, "SetAlpha"), 1, "missing glow")
  Display.ApplyMissingConditions(Native(), Data())

  local shown, hidden = Native(), Native()
  local refreshData = Data({ subRegions = { Text("hello", { text_visible = false, text_alpha = 0.4 }), Glow(true),
    Text("x", { secretAuraDetached = true }) } })
  local refreshed = Region(refreshData, { shown }, hidden)
  Display.RefreshConditionAppearance(refreshed)
  Same(#shown.icon.calls, 0, "no stored values, nothing refreshed")
  refreshed.secretAuraConditionValues = { ["sub.1.text_visible"] = true }
  Display.RefreshConditionAppearance(refreshed)
  Same(Last(shown.sharedElements[1].text, "SetAlpha"), 0.4, "stored visibility with the base opacity")
  Same(CountCalls(shown.sharedElements[1].text, "SetAlpha"), 2, "base state then stored value")
  Same(Last(shown.sharedElements[1].elementFrames.glow, "SetAlpha"), nil, "glow slot belongs to element one")
  Same(Last(hidden.sharedElements[1].text, "SetAlpha"), 0.4, "missing button refreshed")
  Display.RefreshConditionAppearance({})
  Display.RefreshConditionAppearance({ blizzardAuraDisplay = { active = false }, secretAuraConditionValues = {} })

  local missingRegion = Region(missingData, { Native() }, Native())
  missingRegion.secretAuraConditionValues = {}
  Display.SetConditionProperty(missingRegion, "color", 1, 1, 1, 1)
  local missingNative = missingRegion.blizzardAuraDisplay.instances[1].single.missing.native
  Same(Last(missingNative.icon, "SetVertexColor"), 1, "applied on the missing display")
  Same(Last(missingNative.icon, "SetDesaturated"), false, "missing desaturation kept")

  -- Indicators
  local function IndicatorButton()
    local frame = CreateFrame("Frame")
    frame.log = {}
    for _, name in ipairs({ "AddDispelTypeTexture", "RemoveDispelTypeTexture", "AddPandemicRegion", "ClearPandemicRegions",
      "AddAuraShownAnimation", "RemoveAuraShownAnimation" }) do
      frame[name] = function(_, ...) frame.log[#frame.log + 1] = { name, ... } end
    end
    return frame
  end
  local function Calls(frame, name)
    local found = {}
    for _, entry in ipairs(frame.log) do if entry[1] == name then found[#found + 1] = entry end end
    return found
  end
  local function Indicators(conditions, preview, extra)
    local auraButton = IndicatorButton()
    local native = { button = auraButton, cooldown = CreateFrame("Frame"), preview = preview }
    local auraData = Data({ conditions = conditions })
    for key, value in pairs(extra or {}) do auraData[key] = value end
    Display.StyleNativeConditionIndicators(native, auraData)
    return native, auraButton, auraData
  end
  local function Highlight(style, extra)
    local changes = { Change("faAuraHighlightColor", { 0.2, 0.4, 0.6, 1 }) }
    if style then changes[#changes + 1] = Change("faAuraHighlightStyle", style) end
    for property, value in pairs(extra or {}) do changes[#changes + 1] = Change(property, value) end
    return changes
  end
  local native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight()) })
  Same(#Calls(auraButton, "AddDispelTypeTexture"), 4, "border draws four edges")
  local options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  Same(options.showWhenHarmful, false, "stealable shows on buffs only")
  Same(options.showWhenHelpful, true, "stealable buffs")
  assert(options.stealableFilter == Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable, "stealable filter")
  Same(options.style, Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset, "custom asset style")
  Same(options.customDispelAssetMap.Magic.asset, "Interface\\Buttons\\WHITE8X8", "border asset")
  Same(options.customDispelColorMap.Magic:GetRGBA(), 0.2, "border color")
  Same(options.customDispelAssetMap[""] ~= nil and options.customDispelAssetMap.Bleed ~= nil, true, "all dispel keys")
  Same(#native.conditionDispelTextures, 4, "textures tracked")
  Same(native.conditionIndicators[1][1]:GetAlpha(), 1, "edge alpha from the color")
  local edgeOne = native.conditionIndicators[1][1]
  Same(edgeOne:GetBlendMode(), "BLEND", "border blend")
  Same(edgeOne:IsDesaturated(), false, "border not desaturated")
  Same(edgeOne:GetHeight(), 2, "top edge thickness")
  Same(native.conditionIndicators[1][3]:GetWidth(), 2, "left edge thickness")
  Same(native.conditionOverlay:GetParent(), auraButton, "overlay on the button without a gate")

  native, auraButton = Indicators({ Rule("faAuraNotStealable", nil, nil, Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.stealableFilter == Enum.CustomAuraButtonDispelTypeStealableFilter.NotStealable, "not stealable filter")
  native, auraButton = Indicators({ Rule("faAuraType", "==", "HARMFUL", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.showWhenHarmful == true and options.showWhenHelpful == false, "debuff only")
  native, auraButton = Indicators({ Rule("faAuraType", "~=", "HARMFUL", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.showWhenHarmful == false and options.showWhenHelpful == true, "not a debuff")
  native, auraButton = Indicators({ Rule("faAuraType", "~=", "HELPFUL", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.showWhenHarmful == true and options.showWhenHelpful == false, "not a buff")
  native, auraButton = Indicators({ Rule("faAuraDispel", "==", "Magic", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.customDispelAssetMap.Magic and not options.customDispelAssetMap.Curse and not options.customDispelAssetMap[""],
    "only the wanted dispel type")
  native, auraButton = Indicators({ Rule("faAuraDispel", "~=", "Magic", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(not options.customDispelAssetMap.Magic and options.customDispelAssetMap.Curse and options.customDispelAssetMap[""],
    "every other dispel type")
  native, auraButton = Indicators({ Rule("faAuraDispel", "==", "Enrage", Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.customDispelAssetMap[""] and not options.customDispelAssetMap.Magic, "enrage is the empty key")
  native, auraButton = Indicators({ Rule("faAuraPresent", nil, nil, Highlight()) })
  options = Calls(auraButton, "AddDispelTypeTexture")[1][3]
  assert(options.showWhenHelpful and options.showWhenHarmful and options.customDispelAssetMap.Magic and options.customDispelAssetMap[""],
    "present shows everything")
  native, auraButton = Indicators({ Rule("faAuraPandemic", nil, nil, Highlight("glow")) })
  Same(#Calls(auraButton, "AddPandemicRegion"), 1, "glow style draws one texture")
  Same(#Calls(auraButton, "AddDispelTypeTexture"), 0, "pandemic is not a dispel texture")
  local glowEdge = native.conditionIndicators[1][1]
  Same(glowEdge:GetBlendMode(), "ADD", "glow blend")
  Same(glowEdge:IsDesaturated(), true, "glow desaturated")
  Same(glowEdge:GetNumPoints(), 2, "glow anchored by two corners")
  Same(select(4, glowEdge:GetPoint(1)), -10, "glow inset is thickness plus eight")
  Same(native.conditionIndicators[1][2]:IsShown(), false, "unused edges hidden")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("glow")) })
  Same(Calls(auraButton, "AddDispelTypeTexture")[1][2]:GetTexture(), "Interface\\Buttons\\UI-ActionButton-Border", "glow asset")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("overlay")) })
  Same(select(4, native.conditionIndicators[1][1]:GetPoint(1)), 0, "overlay has no inset")
  Same(#Calls(auraButton, "AddDispelTypeTexture"), 1, "overlay draws one texture")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("texture", {
    faAuraHighlightTexture = "Interface\\Custom\\Mark", faAuraHighlightSize = 6 })) })
  Same(Calls(auraButton, "AddDispelTypeTexture")[1][2]:GetTexture(), "Interface\\Custom\\Mark", "custom texture")
  Same(select(4, native.conditionIndicators[1][1]:GetPoint(1)), -6, "texture inset is the thickness")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("texture", { faAuraHighlightTexture = "" })) })
  Same(Calls(auraButton, "AddDispelTypeTexture")[1][2]:GetTexture(), "Interface\\Buttons\\WHITE8X8", "empty custom texture")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("border", { faAuraHighlightSize = 500 })) },
    false, { width = 40, height = 40 })
  Same(native.conditionIndicators[1][1]:GetHeight(), 10, "border thickness capped by the limit")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("glow", { faAuraHighlightSize = 500 })) })
  Same(select(4, native.conditionIndicators[1][1]:GetPoint(1)), -72, "padding thickness capped at 64")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("glow", { faAuraHighlightSize = 0 })) })
  Same(select(4, native.conditionIndicators[1][1]:GetPoint(1)), -9, "thickness at least one")
  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("glow", { faAuraHighlightSize = 0 / 0 })) })
  Same(select(4, native.conditionIndicators[1][1]:GetPoint(1)), -10, "invalid thickness falls back to two")

  native, auraButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight("pulseBorder", { faAuraHighlightPulse = 2 })) })
  local host = native.conditionHosts[1]
  assert(host.pulse and host.pulseOwner == auraButton, "pulse registered on the button")
  Same(#Calls(auraButton, "AddAuraShownAnimation"), 1, "pulse added once")
  local half
  host.fadeOut.SetDuration = function(_, seconds) half = seconds end
  local function Pulse(style, period)
    Display.StyleNativeConditionIndicators(native, Data({ conditions = { Rule("faAuraStealable", nil, nil,
      Highlight(style, { faAuraHighlightPulse = period })) } }))
    return half
  end
  Same(Pulse("pulseBorder", 2), 1, "half period")
  Same(Pulse("pulseBorder", 99), 2.5, "period capped at five")
  Same(#Calls(auraButton, "RemoveAuraShownAnimation"), 2, "pulse removed before redrawing")
  Same(#Calls(auraButton, "RemoveDispelTypeTexture"), 8, "previous textures removed")
  Same(#Calls(auraButton, "ClearPandemicRegions"), 3, "pandemic regions cleared outside the preview")
  Near(Pulse("pulseGlow", 0.01), 0.1, "period floored at 0.2")
  Same(native.conditionIndicators[1][1]:GetBlendMode(), "ADD", "pulsing glow")
  Same(Pulse("pulseGlow", 0 / 0), 0.5, "invalid period falls back to one")
  Display.StyleNativeConditionIndicators(native, Data({ conditions = { Rule("faAuraStealable", nil, nil, Highlight("border")) } }))
  Same(host.pulseOwner, nil, "pulse released")
  Same(host:GetAlpha(), 1, "host opacity restored")

  local ignored = Indicators({
    Rule("faAuraRemaining", "<", 5, Highlight()),
    Rule("faAuraApplications", ">=", 2, Highlight()),
    Rule("faAuraStealable", nil, nil, Highlight(), true),
    Rule("faAuraStealable", nil, nil, { Change("sub.1.glow", true) }),
    Rule("faAuraType", "<", "HELPFUL", Highlight()),
    Rule("faAuraType", "==", "BOTH", Highlight()),
    Rule("faAuraDispel", "==", 5, Highlight()),
    Rule("faAuraDispel", ">=", "Magic", Highlight()),
    Rule("faAuraMissing", nil, nil, Highlight()),
    { check = { trigger = 2, variable = "faAuraStealable" }, changes = Highlight() },
  })
  Same(next(ignored.conditionIndicators), nil, "no indicator for ignored conditions")
  local _, bareButton = Indicators({ Rule("faAuraStealable", nil, nil, Highlight()) })
  bareButton.AddDispelTypeTexture = nil
  local bare = { button = bareButton, cooldown = CreateFrame("Frame") }
  Display.StyleNativeConditionIndicators(bare, Data({ conditions = { Rule("faAuraStealable", nil, nil, Highlight()) } }))
  Same(#bare.conditionDispelTextures, 0, "no dispel texture support")
  local gateFrame = CreateFrame("Frame")
  gateFrame:SetFrameLevel(3)
  local gatedButton = IndicatorButton()
  local base = CreateFrame("Frame")
  base:SetFrameLevel(30)
  local gated = { button = gatedButton, gateClip = gateFrame, cooldown = CreateFrame("Frame"), elementFrames = { sharedBase = base },
    bar = CreateFrame("Frame") }
  gated.cooldown:SetFrameLevel(5)
  gated.bar:SetFrameLevel(12)
  Display.StyleNativeConditionIndicators(gated, Data())
  Same(gated.conditionOverlay:GetParent(), gateFrame, "overlay on the gate clip")
  Same(gated.conditionOverlay:GetFrameLevel(), 31, "overlay above the base")
  base:SetFrameLevel(2)
  Display.StyleNativeConditionIndicators(gated, Data())
  Same(gated.conditionOverlay:GetFrameLevel(), 13, "overlay above the bar")
  gated.bar = nil
  Display.StyleNativeConditionIndicators(gated, Data())
  Same(gated.conditionOverlay:GetFrameLevel(), 6, "overlay above the cooldown")
  gated.elementFrames = nil
  gatedButton:SetFrameLevel(40)
  Display.StyleNativeConditionIndicators(gated, Data())
  Same(gated.conditionOverlay:GetFrameLevel(), 41, "overlay above the button without a base")

  local pandemicNative = { button = IndicatorButton(), cooldown = CreateFrame("Frame"),
    pandemicGlows = { [1] = CreateFrame("Frame") } }
  Display.StyleNativeConditionIndicators(pandemicNative, Data())
  Same(#Calls(pandemicNative.button, "AddPandemicRegion"), 1, "pandemic glow frame attached")
  Same(pandemicNative.conditionData, nil, "no condition data outside the preview")

  -- Preview
  local sample = Display.PREVIEW_SAMPLE_DURATION
  local previewNative = Indicators({ Rule("faAuraPresent", nil, nil, Highlight("overlay")) }, true)
  Same(#previewNative.button.log, 0, "nothing attached to a real button in the preview")
  Same(previewNative.conditionData ~= nil, true, "preview keeps the data")
  Same(#previewNative.conditionPreview, 1, "overlay preview entry")
  Same(previewNative.conditionPreview[1].texture:IsShown(), true, "present shown in the preview")
  previewNative = Indicators({ Rule("faAuraPresent", nil, nil, Highlight()) }, true)
  Same(#previewNative.conditionPreview, 4, "border preview entries")
  local function Shown(variable, op, value, remaining, extra)
    local auraData = Data(extra)
    auraData.conditions = { Rule(variable, op, value, Highlight("overlay")) }
    local previewDisplay = { button = IndicatorButton(), cooldown = CreateFrame("Frame"), preview = true }
    Display.StyleNativeConditionIndicators(previewDisplay, auraData)
    if remaining then Display.UpdateConditionPreview(previewDisplay, auraData, remaining) end
    return previewDisplay.conditionPreview[1].texture:IsShown()
  end
  Same(Shown("faAuraMissing", nil, nil), false, "missing has no preview rule")
  Same(Shown("faAuraStealable", nil, nil), false, "stealable has no preview rule")
  Same(Shown("faAuraNotStealable", nil, nil), true, "not stealable on a buff sample")
  local harmful = { triggers = { { trigger = { type = "secretAura", unit = "player", debuffType = "HARMFUL" } } } }
  Same(Shown("faAuraNotStealable", nil, nil, nil, harmful), false, "not stealable on a debuff sample")
  Same(Shown("faAuraType", "==", "HELPFUL"), true, "buff sample is a buff")
  Same(Shown("faAuraType", "==", "HARMFUL"), false, "buff sample is not a debuff")
  Same(Shown("faAuraType", "~=", "HARMFUL"), true, "buff sample is not a debuff, negated")
  Same(Shown("faAuraType", "==", "HARMFUL", nil, harmful), true, "debuff sample")
  Same(Shown("faAuraType", "~=", "HELPFUL", nil, harmful), true, "debuff sample is not a buff")
  Same(Shown("faAuraDispel", "==", "Magic"), true, "magic sample")
  Same(Shown("faAuraDispel", "==", "Curse"), false, "not curse")
  Same(Shown("faAuraDispel", "~=", "Magic"), false, "not magic negated")
  Same(Shown("faAuraDispel", "~=", "Curse"), true, "not curse negated")
  Same(Shown("faAuraPandemic", nil, nil, sample * 0.3), true, "pandemic at the fraction")
  Same(Shown("faAuraPandemic", nil, nil, sample * 0.3 + 0.01), false, "pandemic above the fraction")
  Same(Shown("faAuraPandemic", nil, nil, 0), false, "pandemic at zero")
  Same(Shown("faAuraPandemic", nil, nil, 1), sample * 0.3 >= 1, "pandemic at one second")
  local missingPreview = Indicators({ Rule("faAuraMissing", nil, nil, Highlight("overlay")) }, true)
  Same(#missingPreview.conditionPreview, 1, "missing drawn in the preview")
  Display.UpdateConditionPreview({}, Data(), 1)
  local frames = { conditionPreview = { { texture = CreateFrame("Frame"), kind = "faAuraPresent" },
    { texture = CreateFrame("Frame"), kind = "unknown" } } }
  frames.conditionPreview[2].texture:Show()
  Display.UpdateConditionPreview(frames, Data(), 1)
  Same(frames.conditionPreview[1].texture:IsShown(), true, "preview rule shows")
  Same(frames.conditionPreview[2].texture:IsShown(), false, "unknown kind hidden")
  local pandemicPreview = { button = IndicatorButton(), cooldown = CreateFrame("Frame"), preview = true, pandemicGlows = { [1] = CreateFrame("Frame") } }
  Display.StyleNativeConditionIndicators(pandemicPreview, Data())
  Same(pandemicPreview.conditionPreview[1].kind, "faAuraPandemic", "pandemic frame listed in the preview")
  Same(#pandemicPreview.button.log, 0, "pandemic frame not attached in the preview")
  Same(pandemicPreview.conditionPreview[1].texture:IsShown(), false, "pandemic frame hidden at the full sample")
  Display.UpdateConditionPreview(pandemicPreview, Data(), sample * 0.2)
  Same(pandemicPreview.conditionPreview[1].texture:IsShown(), true, "pandemic frame shown in the window")

  C_CurveUtil.CreateColorCurve, C_StringUtil.CreateNumericRuleFormatter = realCurve, realFormatter
end

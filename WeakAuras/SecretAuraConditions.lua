if not WeakAuras.IsLibsOK() then
  return
end
local _, AddonPrivate = ...
local AuraDisplay = AddonPrivate.BlizzardAuraDisplay

local SECRET_TRIGGER_TYPE = "secretAura"
local STEP_COLOR = {1, 1, 1, 1}
local HIGHLIGHT_COLOR = {1, 0.82, 0, 1}
local PULSE_BOUNDS = {min = 0.2, max = 5}
local DISPEL_KEYS = {"None", "Magic", "Curse", "Disease", "Poison", "Bleed", "Enrage", ""}
local STACK_OPERATORS = {["<"] = true, [">="] = true, [">"] = true, ["<="] = true, ["=="] = true, ["~="] = true}
local TIME_OPERATORS = {["<"] = true, [">="] = true}
local TEXT_CHANNELS = {text_color = "color", text_visible = "visible", text_text = "text"}
local ROOT_TEXT_CHANNELS = {color = "color", displayText = "text"}

local MESSAGES = {
  grouping = "Aura (Modern) conditions cannot use AND, OR, or Else If.",
  timeOperator = "Aura (Modern) time conditions support < and >=.",
  typeOperator = "Aura (Modern) type conditions support = and !=.",
  missingRegion = "Aura Missing works on Icon, Bar, Progress Texture and Text displays.",
  missingShowOn = "Aura Missing needs the trigger's Show On set to Aura(s) Missing or Always.",
  remainingGlow = "A Remaining Time glow condition must use < and turn the glow on.",
  pandemicGlow = "An In Pandemic Window glow condition must turn the glow on.",
  lateGlow = "A Glow can follow Remaining Time or the pandemic window, not both.",
  timeBasis = "Use one time basis per countdown text: seconds, percentage, elapsed, total, start, or end.",
  property = "Choose a supported property for this Aura (Modern) condition.",
  foreignTrigger = "Use another trigger or a global condition. Aura (Modern) does not expose aura state to conditions.",
  borderDisplay = "Aura Highlight Border Thickness",
  paddingDisplay = "Aura Highlight Padding",
  borderHint = "Border thickness in UI units, limited to one quarter of the aura's smaller dimension so the center stays visible. Set style and color in this same condition.",
  paddingHint = "Extra space around a glow or custom texture, in UI units. Overlay always fills the aura and ignores padding. Set style and color in this same condition.",
}

local actionProperties = {
  chat = "chat",
  sound = "sound",
  customcode = "customcode",
  glowexternal = "glowexternal",
}

local function Flags(...)
  local set = {}
  for _, name in ipairs({...}) do set[name] = true end
  return set
end

local function TypedProperties(groups)
  local typeByName = {}
  for valueType, names in pairs(groups) do
    for _, name in ipairs(names) do typeByName[name] = valueType end
  end
  return typeByName
end

local rootPropertyTypes = {
  icon = TypedProperties({
    color = {"color"},
    bool = {"desaturate", "inverse", "cooldownSwipe", "cooldownEdge", "cooldownTextDisabled"},
    number = {"zoom"},
  }),
  aurabar = TypedProperties({
    color = {"barColor", "backgroundColor", "icon_color"},
    bool = {"desaturate"},
  }),
  text = TypedProperties({
    color = {"color"},
    number = {"fontSize"},
    string = {"displayText"},
  }),
  progresstexture = TypedProperties({
    color = {"foregroundColor", "backgroundColor"},
    bool = {"desaturateForeground"},
  })}

local subRegionPropertyTypes = {
  subtext = TypedProperties({
    color = {"text_color"},
    bool = {"text_visible"},
    string = {"text_text"},
    number = {"text_fontSize", "text_anchorXOffset", "text_anchorYOffset", "text_alpha"},
  }),
  subglow = TypedProperties({bool = {"glow"}})}

local function DurationVariable(binding, label, divisor)
  return {binding = binding, label = label, divisor = divisor}
end

local durationDefinitions = {
  faAuraRemaining = DurationVariable("RemainingDuration", "Remaining Time", 1),
  faAuraRemainingPercent = DurationVariable("RemainingPercent", "Remaining Time (%)", 100),
  faAuraElapsed = DurationVariable("ElapsedDuration", "Elapsed Time", 1),
  faAuraElapsedPercent = DurationVariable("ElapsedPercent", "Elapsed Time (%)", 100),
  faAuraTotal = DurationVariable("TotalDuration", "Total Duration", 1),
  faAuraStart = DurationVariable("StartTime", "Start Time (game clock)", 1),
  faAuraEnd = DurationVariable("EndTime", "End Time (game clock)", 1)}

local nativeVariableSet = Flags("faAuraPandemic", "faAuraStealable", "faAuraNotStealable", "faAuraDispel",
  "faAuraType", "faAuraPresent", "faAuraApplications", "faAuraMissing")
for variableName in pairs(durationDefinitions) do nativeVariableSet[variableName] = true end

local highlightProperties = Flags("faAuraHighlightColor", "faAuraHighlightStyle", "faAuraHighlightSize",
  "faAuraHighlightTexture", "faAuraHighlightPulse")

AuraDisplay.missingRootProperties = {
  icon = Flags("desaturate", "color", "zoom"),
  aurabar = Flags("barColor", "backgroundColor", "icon_color", "desaturate"),
  progresstexture = Flags("foregroundColor", "backgroundColor", "desaturateForeground"),
  text = Flags("color"),
}

local COMPARATORS = {
  ["<"] = function(left, right) return left < right end,
  [">="] = function(left, right) return left >= right end,
  [">"] = function(left, right) return left > right end,
  ["<="] = function(left, right) return left <= right end,
  ["=="] = function(left, right) return left == right end,
  ["~="] = function(left, right) return left ~= right end,
}

local function SomeCheck(node, predicate)
  if predicate(node) then return true end
  local children = node and node.checks or {}
  for _, child in ipairs(children) do
    if SomeCheck(child, predicate) then return true end
  end
  return false
end

local function UsesVariable(rootCheck, triggerIndex, variableName)
  return SomeCheck(rootCheck, function(node)
    return node and node.trigger == triggerIndex and node.variable == variableName
  end)
end

local function SubRegionAt(auraData, position)
  return position and auraData.subRegions and auraData.subRegions[tonumber(position)]
end

function AuraDisplay.IsNativeDurationCondition(conditionCheck)
  if not conditionCheck then return conditionCheck end
  return durationDefinitions[conditionCheck.variable] ~= nil
end

function AuraDisplay.NativeConditionKind(auraData, conditionCheck)
  if not conditionCheck then return nil end
  local triggerEntry = auraData.triggers and auraData.triggers[conditionCheck.trigger]
  local triggerSettings = type(triggerEntry) == "table" and triggerEntry.trigger
  if type(triggerSettings) ~= "table" or triggerSettings.type ~= SECRET_TRIGGER_TYPE then return nil end
  if nativeVariableSet[conditionCheck.variable] then return conditionCheck.variable end
  return nil
end

function AuraDisplay.ContainsNativeCondition(auraData, conditionCheck)
  return SomeCheck(conditionCheck, function(node)
    return AuraDisplay.NativeConditionKind(auraData, node)
  end)
end

function AuraDisplay.SupportsDurationColorCondition()
  local curvesReady = C_CurveUtil and C_CurveUtil.CreateColorCurve and CreateColor
  local bindingsReady = Enum and Enum.LuaCurveType and Enum.LuaCurveType.Step ~= nil and Enum.DurationTextBindingProperty
    and Enum.DurationTextBindingProperty.RemainingDuration ~= nil
  return curvesReady and bindingsReady
end

local function RootTextTarget(auraData, propertyPath, textKind)
  if auraData.regionType ~= "text" or AuraDisplay.TextKind(auraData.displayText) ~= textKind then return end
  local channel = ROOT_TEXT_CHANNELS[propertyPath]
  if channel then return "color", channel end
end

local function SubTextTarget(auraData, propertyPath, textKind)
  local position, field
  if propertyPath then position, field = propertyPath:match("^sub%.(%d+)%.(.*)$") end
  local subRegion = SubRegionAt(auraData, position)
  local usable = subRegion and subRegion.type == "subtext" and not AuraDisplay.IsDetachedElement(auraData, subRegion)
    and AuraDisplay.TextKind(subRegion.text_text) == textKind
  if not usable then return end
  local channel = TEXT_CHANNELS[field]
  if channel then return "sub." .. position .. ".text_color", channel end
end

local function TextProperty(auraData, propertyPath, textKind)
  local target, channel = RootTextTarget(auraData, propertyPath, textKind)
  if target then return target, channel end
  return SubTextTarget(auraData, propertyPath, textKind)
end

local function IsGlowPath(auraData, propertyPath)
  local subRegion = SubRegionAt(auraData, propertyPath and propertyPath:match("^sub%.(%d+)%.glow$"))
  if subRegion == nil then return false end
  return subRegion.type == "subglow" and not AuraDisplay.IsDetachedElement(auraData, subRegion)
end
AuraDisplay.IsGlowProperty = IsGlowPath

local function HasEnabledChange(auraData, variableKind, propertyPath, skipLinked)
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    local applies = not (skipLinked and conditionEntry.linked)
      and AuraDisplay.NativeConditionKind(auraData, conditionEntry.check) == variableKind
    if applies then
      for _, propertyChange in ipairs(conditionEntry.changes or {}) do
        if propertyChange.property == propertyPath and propertyChange.value == true then return true end
      end
    end
  end
  return false
end

local function TurnsGlowOn(auraData, position)
  return HasEnabledChange(auraData, "faAuraPandemic", "sub." .. position .. ".glow", true)
end

local function PandemicGlow(auraData, position)
  local baseData = auraData.nativeConditionBaseData or auraData
  local subRegion = baseData.subRegions and baseData.subRegions[position]
  if not subRegion or subRegion.type ~= "subglow" or subRegion.glow then return false end
  return TurnsGlowOn(auraData, position)
end

function AuraDisplay.PandemicGlowHolder(nativeDisplay, auraData, position, levelFrame)
  if not PandemicGlow(auraData, position) then return end
  nativeDisplay.pandemicGlowFrames = nativeDisplay.pandemicGlowFrames or {}
  local glowFrame = nativeDisplay.pandemicGlowFrames[position]
  if not glowFrame then
    glowFrame = CreateFrame("Frame", nil, nativeDisplay.gateClip or nativeDisplay.button)
    nativeDisplay.pandemicGlowFrames[position] = glowFrame
  end
  glowFrame:ClearAllPoints()
  glowFrame:SetAllPoints(nativeDisplay.button)
  glowFrame:SetFrameLevel(levelFrame:GetFrameLevel() + 1)
  glowFrame:Hide()
  nativeDisplay.pandemicGlows = nativeDisplay.pandemicGlows or {}
  nativeDisplay.pandemicGlows[position] = glowFrame
  return glowFrame
end

function AuraDisplay.ResetPandemicGlows(nativeDisplay)
  for _, glowFrame in pairs(nativeDisplay.pandemicGlowFrames or {}) do glowFrame:Hide() end
  nativeDisplay.pandemicGlows = {}
end

local function MissingAllows(auraData, propertyPath)
  local allowed = AuraDisplay.missingRootProperties[auraData.regionType]
  if not allowed then return false end
  if highlightProperties[propertyPath] or allowed[propertyPath] then return true end
  local position, key = (propertyPath or ""):match("^sub%.(%d+)%.(.+)$")
  local subRegion = SubRegionAt(auraData, position)
  if not subRegion or AuraDisplay.IsDetachedElement(auraData, subRegion) then return false end
  if subRegion.type == "subglow" then return key == "glow" end
  return subRegion.type == "subtext" and (key == "text_visible" or key == "text_color")
end

function AuraDisplay.NativeConditionAllowsProperty(auraData, conditionCheck, propertyPath)
  local variableKind = AuraDisplay.NativeConditionKind(auraData, conditionCheck)
  local glowKind = variableKind == "faAuraRemaining" or variableKind == "faAuraPandemic"
  if glowKind and IsGlowPath(auraData, propertyPath) then return true end
  if durationDefinitions[variableKind] then
    local target, channel = TextProperty(auraData, propertyPath, "duration")
    return target ~= nil and channel ~= "text"
  end
  if variableKind == "faAuraApplications" then return TextProperty(auraData, propertyPath, "stack") ~= nil end
  if variableKind == "faAuraMissing" then return MissingAllows(auraData, propertyPath) end
  if variableKind then return highlightProperties[propertyPath] == true end
  return not highlightProperties[propertyPath]
end

function AuraDisplay.MissingDesaturated(auraData)
  return HasEnabledChange(auraData, "faAuraMissing", "desaturate", false)
end

local function FirstSecretTrigger(auraData, strict)
  for triggerIndex, triggerEntry in ipairs(auraData.triggers or {}) do
    if strict then
      if triggerEntry.trigger.type == SECRET_TRIGGER_TYPE then return triggerIndex end
    elseif type(triggerEntry) == "table" and triggerEntry.trigger and triggerEntry.trigger.type == SECRET_TRIGGER_TYPE then
      return triggerIndex
    end
  end
end

local function MigrateMissing(auraData, legacy)
  if not legacy.missingDesaturate then return end
  local triggerIndex = FirstSecretTrigger(auraData, false)
  if not triggerIndex then return end
  auraData.conditions = auraData.conditions or {}
  table.insert(auraData.conditions, {
    check = {trigger = triggerIndex, variable = "faAuraMissing"},
    changes = {{property = "desaturate", value = true}},
  })
  legacy.missingDesaturate = nil
end

local function ResolveDurationProperty(auraData, propertyPath)
  for position, subRegion in ipairs(auraData.subRegions or {}) do
    local candidate = not propertyPath and subRegion.type == "subtext" and subRegion.text_visible ~= false
      and not AuraDisplay.IsDetachedElement(auraData, subRegion) and AuraDisplay.TextKind(subRegion.text_text) == "duration"
    if candidate then propertyPath = "sub." .. position .. ".text_color" end
  end
  return propertyPath
end

local function MigrateRemaining(auraData, legacy)
  if not legacy.remainingTimeColorEnabled then return end
  local propertyPath
  if auraData.regionType == "text" and AuraDisplay.TextKind(auraData.displayText) == "duration" then
    propertyPath = "color"
  end
  propertyPath = ResolveDurationProperty(auraData, propertyPath)
  local triggerIndex = FirstSecretTrigger(auraData, true)
  if not (triggerIndex and propertyPath) then return end
  local conditionList = auraData.conditions or {}
  auraData.conditions = conditionList
  table.insert(auraData.conditions, {
    check = {trigger = triggerIndex, variable = "faAuraRemaining", op = "<",
      value = legacy.remainingTimeColorThreshold or 10},
    changes = {{property = propertyPath, value = legacy.remainingTimeColor or {1, 0, 0, 1}}},
  })
  legacy.remainingTimeColorEnabled = nil
end

function AuraDisplay.MigrateNativeConditions(auraData)
  local legacy = auraData.blizzardAuraDisplay or {}
  MigrateMissing(auraData, legacy)
  MigrateRemaining(auraData, legacy)
end

local function Clamped(component, fallback)
  if type(component) == "number" and component == component then return math.max(0, math.min(1, component)) end
  return fallback
end

local function ClampedColor(components, fallback)
  if type(components) ~= "table" then components = fallback end
  local channels = {}
  for slot = 1, 4 do channels[slot] = Clamped(components[slot], fallback[slot]) end
  return CreateColor(unpack(channels))
end

local function ThresholdRules(auraData, propertyPath, stack)
  local collected = {}
  local textKind = stack and "stack" or "duration"
  local operators = stack and STACK_OPERATORS or TIME_OPERATORS
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    local variableKind = AuraDisplay.NativeConditionKind(auraData, conditionEntry.check)
    local relevant
    if stack then relevant = variableKind == "faAuraApplications" else relevant = durationDefinitions[variableKind] end
    if not conditionEntry.linked and relevant then
      local conditionCheck = conditionEntry.check
      local threshold = tonumber(conditionCheck.value)
      if threshold and threshold == threshold and threshold >= 0 and threshold < math.huge and operators[conditionCheck.op] then
        local divisor = stack and 1 or durationDefinitions[variableKind].divisor
        for _, propertyChange in ipairs(conditionEntry.changes or {}) do
          local target, channel = TextProperty(auraData, propertyChange.property, textKind)
          if target == propertyPath and (stack or channel ~= "text") then
            collected[#collected + 1] = {
              threshold = threshold / divisor,
              op = conditionCheck.op,
              value = propertyChange.value,
              channel = channel,
              kind = variableKind,
            }
          end
        end
      end
    end
  end
  return collected
end

local function RuleMatches(amount, rule)
  local comparator = COMPARATORS[rule.op]
  return comparator and comparator(amount, rule.threshold)
end

local function BaseTextVisible(auraData, propertyPath)
  local position = propertyPath and propertyPath:match("^sub%.(%d+)%.text_color$")
  local baseData = auraData.nativeConditionBaseData or auraData
  local subRegion = position and baseData.subRegions and baseData.subRegions[tonumber(position)]
  return not subRegion or subRegion.text_visible ~= false
end

local function DurationBreakpoints(thresholdRules, variableKind, window)
  local points, seen = {0}, {[0] = true}
  local function Add(point)
    if seen[point] then return end
    points[#points + 1] = point
    seen[point] = true
  end
  for _, rule in ipairs(thresholdRules) do
    if rule.kind ~= variableKind then return end
    Add(rule.threshold)
  end
  local windowPoints = window and AuraDisplay.RemainingWindowPoints(window[1], window[2]) or {}
  for _, point in ipairs(windowPoints) do Add(point) end
  table.sort(points)
  return points
end

local function StepColor(auraData, thresholdRules, baseColor, propertyPath, window, point)
  local stepColor, shown = baseColor, BaseTextVisible(auraData, propertyPath)
  for _, rule in ipairs(thresholdRules) do
    if RuleMatches(point, rule) then
      if rule.channel == "color" then
        stepColor = rule.value
      elseif rule.channel == "visible" then
        shown = rule.value ~= false
      end
    end
  end
  if window and not AuraDisplay.InRemainingWindow(point, window[1], window[2]) then shown = false end
  local color = ClampedColor(stepColor, STEP_COLOR)
  if shown then return color end
  local red, green, blue = color:GetRGB()
  return CreateColor(red, green, blue, 0)
end

function AuraDisplay.DurationColorCondition(auraData, baseColor, propertyPath, window)
  if not AuraDisplay.SupportsDurationColorCondition() then return end
  local thresholdRules = ThresholdRules(auraData, propertyPath)
  if #thresholdRules == 0 and not window then return end
  local firstRule = thresholdRules[1]
  local variableKind = firstRule and firstRule.kind or "faAuraRemaining"
  if window and variableKind ~= "faAuraRemaining" then return end
  local binding = Enum.DurationTextBindingProperty[durationDefinitions[variableKind].binding]
  if binding == nil then return end
  local points = DurationBreakpoints(thresholdRules, variableKind, window)
  if not points then return end
  local colorCurve = C_CurveUtil.CreateColorCurve()
  colorCurve:SetType(Enum.LuaCurveType.Step)
  for _, point in ipairs(points) do
    local stepColor = StepColor(auraData, thresholdRules, baseColor, propertyPath, window, point)
    colorCurve:AddPoint(point, stepColor)
  end
  return {curve = colorCurve, property = binding}
end

local function StackPoints(thresholdRules)
  local points, seen = {0, 2}, {[0] = true, [2] = true}
  for _, rule in ipairs(thresholdRules) do
    local lower, upper = math.floor(rule.threshold), math.ceil(rule.threshold)
    for _, point in ipairs({lower, upper, math.floor(rule.threshold) + 1}) do
      if point >= 0 and not seen[point] then
        points[#points + 1] = point
        seen[point] = true
      end
    end
  end
  table.sort(points)
  return points
end

local function ColoredFormat(color, pattern)
  local red, green, blue = ClampedColor(color, STEP_COLOR):GetRGB()
  local function Byte(channel) return math.floor(channel * 255 + 0.5) end
  return ("|cff%02x%02x%02x"):format(Byte(red), Byte(green), Byte(blue)) .. pattern .. "|r"
end

local function StackStep(auraData, thresholdRules, propertyPath, point)
  local pattern, shown, stepColor = "%d", point >= 2 and BaseTextVisible(auraData, propertyPath), nil
  for _, rule in ipairs(thresholdRules) do
    if RuleMatches(point, rule) then
      if rule.channel == "color" then
        stepColor = rule.value
      elseif rule.channel == "visible" then
        shown = rule.value ~= false
      elseif rule.channel == "text" and type(rule.value) == "string" then
        pattern = rule.value:gsub("%%", "%%%%")
        shown = true
      end
    end
  end
  if not shown then return "" end
  if stepColor then return ColoredFormat(stepColor, pattern) end
  return pattern
end

local function StackBreakpoints(auraData, propertyPath)
  local thresholdRules = ThresholdRules(auraData, propertyPath, true)
  if #thresholdRules == 0 then return end
  local steps = {}
  for _, point in ipairs(StackPoints(thresholdRules)) do
    steps[#steps + 1] = {threshold = point, format = StackStep(auraData, thresholdRules, propertyPath, point)}
  end
  return steps
end

function AuraDisplay.StackTextFor(auraData, propertyPath, count)
  local steps = StackBreakpoints(auraData, propertyPath)
  if not steps then return count >= 2 and tostring(count) or "" end
  local pattern = ""
  for position = #steps, 1, -1 do
    local step = steps[position]
    if step.threshold <= count then
      pattern = step.format
      break
    end
  end
  local pieces = {}
  for piece in (pattern .. "%%"):gmatch("(.-)%%%%") do
    pieces[#pieces + 1] = (piece:gsub("%%d", tostring(count)))
  end
  return table.concat(pieces, "%")
end

function AuraDisplay.StackTextCondition(auraData, propertyPath)
  local available = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
  if not available then return end
  local steps = StackBreakpoints(auraData, propertyPath)
  if not steps then return end
  local ruleFormatter = C_StringUtil.CreateNumericRuleFormatter()
  ruleFormatter:SetBreakpoints(steps)
  return ruleFormatter
end

local function OwnsDurationColor(auraData, propertyPath)
  local durationTarget = TextProperty(auraData, propertyPath, "duration")
  if durationTarget and AuraDisplay.SupportsDurationColorCondition() and #ThresholdRules(auraData, durationTarget) > 0 then
    return true
  end
  local stackTarget = TextProperty(auraData, propertyPath, "stack")
  return stackTarget and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
    and #ThresholdRules(auraData, stackTarget, true) > 0
end

local function DetachedPropertyType(auraData, subRegion, key)
  local subRegionType = AddonPrivate.subRegionTypes[subRegion.type]
  local definitions = subRegionType and subRegionType.properties
  definitions = type(definitions) == "function" and definitions(auraData, subRegion) or definitions
  local definition = definitions and definitions[key]
  if definition and not definition.valueFromBoolean and not definition.colorFromBoolean then return definition.type end
end

local function PropertyType(auraData, propertyPath)
  if actionProperties[propertyPath] then return actionProperties[propertyPath] end
  local position, key = propertyPath:match("^sub%.(%d+)%.(.+)$")
  if not position then
    if propertyPath == "displayText" and AuraDisplay.TextKind(auraData.displayText) ~= "literal" then return end
    local typesForRegion = rootPropertyTypes[auraData.regionType]
    return typesForRegion and typesForRegion[propertyPath]
  end
  local subRegion = auraData.subRegions and auraData.subRegions[tonumber(position)]
  if AuraDisplay.IsDetachedElement(auraData, subRegion) then return DetachedPropertyType(auraData, subRegion, key) end
  if subRegion and key == "text_text" and AuraDisplay.TextKind(subRegion.text_text) ~= "literal" then return end
  local typesForSubRegion = subRegion and subRegionPropertyTypes[subRegion.type]
  return typesForSubRegion and typesForSubRegion[key]
end

function AuraDisplay.IsNativeConditionProperty(auraData, propertyPath)
  if actionProperties[propertyPath] or AuraDisplay.IsDetachedProperty(auraData, propertyPath) then return false end
  return PropertyType(auraData, propertyPath) ~= nil
end

local function HighlightDefinitions()
  return {
    {"faAuraHighlightColor", {display = "Aura Highlight Color", type = "color", default = {1, 0.82, 0, 1}}},
    {"faAuraHighlightStyle", {
      display = "Aura Highlight Style",
      type = "list",
      default = "border",
      values = {
        border = "Border",
        glow = "Glow (Static)",
        pulseBorder = "Border (Pulsing)",
        pulseGlow = "Glow (Pulsing)",
        overlay = "Overlay",
        texture = "Custom Texture",
      },
    }},
    {"faAuraHighlightPulse", {
      display = "Aura Highlight Pulse Duration", type = "number", default = 1, min = 0.2, max = 5, step = 0.1,
    }},
    {"faAuraHighlightSize", {
      display = "Aura Highlight Thickness / Padding", type = "number", default = 2, min = 1, max = 64, step = 1,
    }},
    {"faAuraHighlightTexture", {
      display = "Aura Highlight Texture", type = "string", default = "Interface\\Buttons\\UI-ActionButton-Border",
    }},
  }
end

function AuraDisplay.FilterConditionProperties(auraData, definitions)
  if not AuraDisplay.Enabled(auraData) then return definitions end
  for _, pair in ipairs(HighlightDefinitions()) do definitions[pair[1]] = pair[2] end
  return definitions
end

function AuraDisplay.FilterGlobalConditions(_, globalTemplates)
  return globalTemplates
end

function AuraDisplay.HighlightBorderLimit(auraData)
  local frameWidth, frameHeight = AuraDisplay.Dimensions(auraData)
  local quarter = math.floor(math.min(frameWidth, frameHeight) / 4)
  return math.max(1, quarter)
end

function AuraDisplay.HighlightPropertyOptions(auraData, conditionEntry, propertyPath, definition)
  if propertyPath ~= "faAuraHighlightSize" or not definition then return definition end
  local highlightStyle = "border"
  for _, propertyChange in ipairs(conditionEntry.changes or {}) do
    if propertyChange.property == "faAuraHighlightStyle" then highlightStyle = propertyChange.value end
  end
  local options = CopyTable(definition)
  local bordered = highlightStyle == "border" or highlightStyle == "pulseBorder"
  options.display = bordered and MESSAGES.borderDisplay or MESSAGES.paddingDisplay
  options.max = bordered and AuraDisplay.HighlightBorderLimit(auraData) or 64
  options.description = bordered and MESSAGES.borderHint or MESSAGES.paddingHint
  return options
end

local function AlwaysTrue(label)
  return {display = label, type = "alwaystrue"}
end

local function NativeSelect(label, choices)
  return {display = label, type = "select", operator_types = "native_aura_dispel", values = choices}
end

local function OfferedDuration(auraData, triggerIndex, variableName)
  if variableName ~= "faAuraStart" and variableName ~= "faAuraEnd" then return true end
  local offered = false
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    offered = UsesVariable(conditionEntry.check, triggerIndex, variableName) or offered
  end
  return offered
end

local function NativeTemplates(auraData, triggerIndex)
  local templates = {
    faAuraPandemic = AlwaysTrue("In Pandemic Window"),
    faAuraStealable = AlwaysTrue("Buff Is Stealable"),
    faAuraNotStealable = AlwaysTrue("Buff Is Not Stealable"),
    faAuraPresent = AlwaysTrue("Aura Present"),
    faAuraMissing = AlwaysTrue("Aura Missing"),
    faAuraType = NativeSelect("Aura Type", {HELPFUL = "Buff", HARMFUL = "Debuff"}),
    faAuraDispel = NativeSelect("Dispel Type", {
      Magic = "Magic",
      Curse = "Curse",
      Disease = "Disease",
      Poison = "Poison",
      Bleed = "Bleed",
      Enrage = "Enrage",
      None = "None",
    }),
  }
  if AuraDisplay.SupportsDurationColorCondition() then
    for variableName, variable in pairs(durationDefinitions) do
      local offered = OfferedDuration(auraData, triggerIndex, variableName)
      if offered and Enum.DurationTextBindingProperty[variable.binding] ~= nil then
        templates[variableName] = {display = variable.label, type = "number", operator_types = "native_aura_duration"}
      end
    end
  end
  local stackFormatter = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
  if stackFormatter then templates.faAuraApplications = {display = "Stack Count", type = "number"} end
  return templates
end

function AuraDisplay.FilterConditionTemplates(auraData, templatesByTrigger)
  if not AuraDisplay.Enabled(auraData) then return templatesByTrigger end
  for triggerIndex, triggerTemplates in pairs(templatesByTrigger) do
    local triggerEntry = auraData.triggers[triggerIndex]
    local triggerSettings = triggerEntry and triggerEntry.trigger
    local secret = triggerSettings and triggerSettings.type == SECRET_TRIGGER_TYPE
    templatesByTrigger[triggerIndex] = secret and NativeTemplates(auraData, triggerIndex) or triggerTemplates
  end
  return templatesByTrigger
end

local function ValidCheck(auraData, conditionCheck)
  if not conditionCheck or not conditionCheck.variable then return true end
  local variableName = conditionCheck.variable
  if variableName == "AND" or variableName == "OR" then
    for _, nested in ipairs(conditionCheck.checks or {}) do
      if not ValidCheck(auraData, nested) then return false end
    end
    return true
  end
  if conditionCheck.trigger == -1 then return true end
  local triggerEntry = auraData.triggers[conditionCheck.trigger]
  local triggerSettings = triggerEntry and triggerEntry.trigger
  return triggerSettings
    and (triggerSettings.type ~= SECRET_TRIGGER_TYPE or AuraDisplay.NativeConditionKind(auraData, conditionCheck) ~= nil)
end

local function ConditionHeaderProblem(auraData, position, conditionEntry, variableKind)
  local nextEntry = auraData.conditions[position + 1]
  if not variableKind or conditionEntry.linked or (nextEntry and nextEntry.linked) then return MESSAGES.grouping end
  local operator = conditionEntry.check.op
  if durationDefinitions[variableKind] and operator and operator ~= "<" and operator ~= ">=" then
    return MESSAGES.timeOperator
  end
  local typeKind = variableKind == "faAuraDispel" or variableKind == "faAuraType"
  if typeKind and operator and operator ~= "==" and operator ~= "~=" then return MESSAGES.typeOperator end
  if variableKind ~= "faAuraMissing" then return end
  local showOn = AuraDisplay.ShowOn(AuraDisplay.GetTrigger(auraData))
  if not AuraDisplay.missingRootProperties[auraData.regionType] then return MESSAGES.missingRegion end
  if showOn ~= "showOnMissing" and showOn ~= "showAlways" then return MESSAGES.missingShowOn end
end

local GLOW_CHECKS = {
  faAuraRemaining = function(auraData, conditionEntry, propertyChange)
    if not IsGlowPath(auraData, propertyChange.property) then return end
    if conditionEntry.check.op ~= "<" or propertyChange.value ~= true then return MESSAGES.remainingGlow end
  end,
  faAuraPandemic = function(auraData, _, propertyChange)
    if not IsGlowPath(auraData, propertyChange.property) then return end
    if propertyChange.value ~= true then return MESSAGES.pandemicGlow end
    local _, _, lateGlowIndex = AuraDisplay.LateGlowSpec(auraData, AuraDisplay.GetTrigger(auraData))
    if lateGlowIndex and propertyChange.property == "sub." .. lateGlowIndex .. ".glow" then return MESSAGES.lateGlow end
  end,
}

local function ChangeProblem(auraData, conditionEntry, propertyChange, variableKind, timeBases)
  local glowCheck = GLOW_CHECKS[variableKind]
  local problem = glowCheck and glowCheck(auraData, conditionEntry, propertyChange)
  if problem then return problem end
  local propertyPath = propertyChange.property
  if durationDefinitions[variableKind] and propertyPath then
    local target = TextProperty(auraData, propertyPath, "duration")
    if target then
      local previous = timeBases[target]
      if previous and previous ~= variableKind then return MESSAGES.timeBasis end
      timeBases[target] = variableKind
    end
  end
  if propertyPath and not AuraDisplay.NativeConditionAllowsProperty(auraData, conditionEntry.check, propertyPath) then
    return MESSAGES.property
  end
end

local function NativeConditionProblem(auraData, position, conditionEntry, timeBases)
  local variableKind = AuraDisplay.NativeConditionKind(auraData, conditionEntry.check)
  local headerProblem = ConditionHeaderProblem(auraData, position, conditionEntry, variableKind)
  if headerProblem then return headerProblem end
  for _, propertyChange in ipairs(conditionEntry.changes or {}) do
    local changeProblem = ChangeProblem(auraData, conditionEntry, propertyChange, variableKind, timeBases)
    if changeProblem then return changeProblem end
  end
end

function AuraDisplay.ValidateConditions(auraData)
  local timeBases = {}
  for position, conditionEntry in ipairs(auraData.conditions or {}) do
    if AuraDisplay.ContainsNativeCondition(auraData, conditionEntry.check) then
      local problem = NativeConditionProblem(auraData, position, conditionEntry, timeBases)
      if problem then return problem end
    end
    if not ValidCheck(auraData, conditionEntry.check) then return MESSAGES.foreignTrigger end
  end
end

local function CopyForAppearance(auraData)
  local copy = {}
  for field, fieldValue in pairs(auraData) do copy[field] = fieldValue end
  copy.subRegions = {}
  for position, subRegion in ipairs(auraData.subRegions) do copy.subRegions[position] = subRegion end
  return copy
end

function AuraDisplay.PrepareConditionAppearance(auraData)
  local appearance
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    for _, propertyChange in ipairs(conditionEntry.changes or {}) do
      local propertyPath = propertyChange.property
      local rawPosition, key = (propertyPath or ""):match("^sub%.(%d+)%.(.+)$")
      local position = tonumber(rawPosition)
      local forcedOn = position and not AuraDisplay.IsDetachedProperty(auraData, propertyPath)
        and (key == "glow" or key == "text_visible") and PropertyType(auraData, propertyPath)
      if forcedOn then
        appearance = appearance or CopyForAppearance(auraData)
        local original = auraData.subRegions[position]
        if appearance.subRegions[position] == original then
          appearance.subRegions[position] = CopyTable(auraData.subRegions[position])
        end
        appearance.subRegions[position][key] = true
      end
    end
  end
  if not appearance then return auraData end
  appearance.nativeConditionBaseData = auraData
  return appearance
end

local function SetFontSize(fontString, fontSize)
  local fontPath, _, fontFlags = fontString:GetFont()
  fontString:SetFont(fontPath, fontSize, fontFlags)
end

local function ApplyTextAlpha(sharedEntry, auraData, position, _, overrides)
  local label = sharedEntry.text
  if not label then return end
  local prefix = "sub." .. position .. "."
  local shown = overrides[prefix .. "text_visible"]
  if shown == nil then shown = auraData.subRegions[position].text_visible ~= false end
  local opacity = overrides[prefix .. "text_alpha"] or auraData.subRegions[position].text_alpha or 1
  label:SetAlpha(shown and opacity or 0)
end

local function AnchorOffsetApplier(horizontal)
  return function(sharedEntry, _, _, offset)
    local label = sharedEntry.text
    if not label then return end
    local anchorPoint, relativeTo, relativePoint, offsetX, offsetY = label:GetPoint(1)
    label:ClearAllPoints()
    if horizontal then offsetX = offset or offsetX else offsetY = offset or offsetY end
    label:SetPoint(anchorPoint, relativeTo, relativePoint, offsetX, offsetY)
  end
end

local SUB_APPLIERS = {
  text_color = function(sharedEntry, _, _, color)
    if sharedEntry.text then sharedEntry.text:SetTextColor(unpack(color)) end
  end,
  text_visible = ApplyTextAlpha,
  text_alpha = ApplyTextAlpha,
  text_text = function(sharedEntry, _, _, text)
    if sharedEntry.text then sharedEntry.text:SetText((text:gsub("%%%%", "%%"))) end
  end,
  text_fontSize = function(sharedEntry, _, _, fontSize)
    if sharedEntry.text then SetFontSize(sharedEntry.text, fontSize) end
  end,
  text_anchorXOffset = AnchorOffsetApplier(true),
  text_anchorYOffset = AnchorOffsetApplier(false),
  glow = function(sharedEntry, _, _, enabled)
    local glowFrame = sharedEntry.elementFrames and sharedEntry.elementFrames.glow
    if glowFrame then glowFrame:SetAlpha(enabled and 1 or 0) end
  end,
}

local ROOT_APPLIERS = {
  color = function(auraButton, auraData, color)
    if auraData.regionType ~= "text" then
      auraButton.icon:SetVertexColor(unpack(color))
    elseif auraButton.mainText then
      auraButton.mainText:SetTextColor(unpack(color))
    end
  end,
  foregroundColor = function(auraButton, _, color)
    if auraButton.progressTexture then auraButton.progressTexture.texture:SetVertexColor(unpack(color)) end
  end,
  desaturateForeground = function(auraButton, _, enabled)
    if auraButton.progressTexture then auraButton.progressTexture.texture:SetDesaturated(enabled) end
  end,
  backgroundColor = function(auraButton, _, color)
    if auraButton.progressBackground then
      auraButton.progressBackground:SetColor(unpack(color))
    elseif auraButton.barBackground then
      auraButton.barBackground:SetColorTexture(unpack(color))
    end
  end,
  barColor = function(auraButton, _, color)
    if auraButton.bar then auraButton.bar:SetStatusBarColor(unpack(color)) end
  end,
  desaturate = function(auraButton, _, enabled) auraButton.icon:SetDesaturated(enabled) end,
  icon_color = function(auraButton, _, color) auraButton.icon:SetVertexColor(unpack(color)) end,
  zoom = function(auraButton, auraData, zoom) AuraDisplay.StyleIconTexCoords(auraButton, auraData, zoom) end,
  inverse = function(auraButton, _, enabled) auraButton.cooldown:SetReverse(enabled) end,
  cooldownSwipe = function(auraButton, _, enabled) auraButton.cooldown:SetDrawSwipe(enabled) end,
  cooldownEdge = function(auraButton, _, enabled) auraButton.cooldown:SetDrawEdge(enabled) end,
  cooldownTextDisabled = function(auraButton, _, enabled) auraButton.cooldown:SetHideCountdownNumbers(enabled) end,
  fontSize = function(auraButton, _, fontSize)
    if auraButton.mainText then SetFontSize(auraButton.mainText, fontSize) end
  end,
  displayText = function(auraButton, _, text)
    if auraButton.mainText then auraButton.mainText:SetText((text:gsub("%%%%", "%%"))) end
  end,
}

local function ApplyProperty(auraButton, auraData, propertyPath, propertyValue, overrides)
  if OwnsDurationColor(auraData, propertyPath) then return end
  if not auraButton.preview and (InCombatLockdown() or C_Secrets.ShouldAurasBeSecret()) then return end
  local rawPosition, key = propertyPath:match("^sub%.(%d+)%.(.+)$")
  if not rawPosition then
    local rootApplier = ROOT_APPLIERS[propertyPath]
    if rootApplier then rootApplier(auraButton, auraData, propertyValue) end
    return
  end
  local position = tonumber(rawPosition)
  local sharedEntry = auraButton.sharedElements and auraButton.sharedElements[position]
  if not sharedEntry then return end
  local subApplier = SUB_APPLIERS[key]
  if subApplier then subApplier(sharedEntry, auraData, position, propertyValue, overrides) end
end

function AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
  local missingValues = {}
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    if AuraDisplay.NativeConditionKind(auraData, conditionEntry.check) == "faAuraMissing" then
      for _, propertyChange in ipairs(conditionEntry.changes or {}) do
        local propertyPath = propertyChange.property
        local accepted = propertyPath and not highlightProperties[propertyPath] and propertyChange.value ~= nil
          and AuraDisplay.NativeConditionAllowsProperty(auraData, conditionEntry.check, propertyPath)
        if accepted then missingValues[propertyPath] = propertyChange.value end
      end
    end
  end
  for propertyPath, propertyValue in pairs(missingValues) do
    ApplyProperty(nativeDisplay, auraData, propertyPath, propertyValue, missingValues)
  end
end

function AuraDisplay.ApplyConditionAppearance(auraButton, region, auraData)
  local overrides = region.secretAuraConditionValues or {}
  for position, subRegion in ipairs(auraData.subRegions or {}) do
    if not AuraDisplay.IsDetachedElement(auraData, subRegion) then
      local prefix = "sub." .. position .. "."
      local subRegionType = subRegion.type
      if subRegionType == "subglow" then
        ApplyProperty(auraButton, auraData, prefix .. "glow", subRegion.glow == true, overrides)
      elseif subRegionType == "subtext" then
        ApplyProperty(auraButton, auraData, prefix .. "text_visible", subRegion.text_visible ~= false, overrides)
      end
    end
  end
  local stored = region.secretAuraConditionValues or {}
  for propertyPath, propertyValue in pairs(stored) do
    ApplyProperty(auraButton, auraData, propertyPath, propertyValue, overrides)
  end
end

local function ForEachInstance(nativeDisplay, visit)
  for _, displayInstance in ipairs(nativeDisplay.instances) do visit(displayInstance) end
end

local function MissingNative(displayInstance)
  local missing = displayInstance.single and displayInstance.single.missing
  return missing and missing.native
end

function AuraDisplay.SetConditionProperty(region, propertyPath, ...)
  local nativeDisplay = region.blizzardAuraDisplay
  if not nativeDisplay or not nativeDisplay.active then return end
  local auraData = nativeDisplay.data
  local valueType = PropertyType(auraData, propertyPath)
  if not valueType then return end
  local propertyValue
  if valueType == "color" then propertyValue = {...} else propertyValue = (...) end
  local stored = region.secretAuraConditionValues or {}
  region.secretAuraConditionValues = stored
  stored[propertyPath] = propertyValue
  ForEachInstance(nativeDisplay, function(displayInstance)
    for _, auraButton in ipairs(displayInstance.buttons) do
      ApplyProperty(auraButton, nativeDisplay.data, propertyPath, propertyValue, region.secretAuraConditionValues)
    end
    local missingButton = MissingNative(displayInstance)
    if missingButton then
      ApplyProperty(missingButton, nativeDisplay.data, propertyPath, propertyValue, region.secretAuraConditionValues)
      AuraDisplay.KeepMissingDesaturated(missingButton, nativeDisplay.data)
    end
  end)
end

function AuraDisplay.RefreshConditionAppearance(region)
  local nativeDisplay = region.blizzardAuraDisplay
  local ready = nativeDisplay and nativeDisplay.active and region.secretAuraConditionValues
  if not ready then return end
  ForEachInstance(nativeDisplay, function(displayInstance)
    for _, auraButton in ipairs(displayInstance.buttons) do
      AuraDisplay.ApplyConditionAppearance(auraButton, region, nativeDisplay.data)
    end
    local missingButton = MissingNative(displayInstance)
    if missingButton then
      AuraDisplay.ApplyConditionAppearance(missingButton, region, nativeDisplay.data)
      AuraDisplay.KeepMissingDesaturated(missingButton, nativeDisplay.data)
    end
  end)
end

local function ClearIndicatorState(nativeDisplay, auraData, auraButton)
  if not nativeDisplay.preview and auraButton.ClearPandemicRegions then auraButton:ClearPandemicRegions() end
  for _, edgeTextures in pairs(nativeDisplay.conditionIndicators or {}) do
    for _, edge in ipairs(edgeTextures) do edge:Hide() end
  end
  nativeDisplay.conditionIndicators = nativeDisplay.conditionIndicators or {}
  local hosts = nativeDisplay.conditionHosts or {}
  nativeDisplay.conditionHosts = hosts
  for _, indicatorFrame in pairs(nativeDisplay.conditionHosts) do
    local pulse = indicatorFrame.pulse
    if pulse then pulse:Stop() end
    indicatorFrame:SetAlpha(1)
  end
  for _, dispelTexture in ipairs(nativeDisplay.conditionDispelTextures or {}) do
    auraButton:RemoveDispelTypeTexture(dispelTexture)
  end
  nativeDisplay.conditionDispelTextures = {}
  local previewEntries = {}
  nativeDisplay.conditionPreview = previewEntries
  nativeDisplay.conditionData = nativeDisplay.preview and auraData or nil
  for _, glowFrame in pairs(nativeDisplay.pandemicGlows or {}) do
    if nativeDisplay.preview then
      previewEntries[#previewEntries + 1] = {texture = glowFrame, kind = "faAuraPandemic"}
    elseif auraButton.AddPandemicRegion then
      auraButton:AddPandemicRegion(glowFrame)
    end
  end
end

local function EnsureOverlay(nativeDisplay, auraButton)
  local overlay = nativeDisplay.conditionOverlay or CreateFrame("Frame", nil, nativeDisplay.gateClip or auraButton)
  nativeDisplay.conditionOverlay = overlay
  overlay:SetAllPoints(auraButton)
  local sharedBase = nativeDisplay.elementFrames and nativeDisplay.elementFrames.sharedBase
  local cooldownLevel = nativeDisplay.cooldown:GetFrameLevel()
  local barLevel = nativeDisplay.bar and nativeDisplay.bar:GetFrameLevel() or 0
  local baseLevel = sharedBase and sharedBase:GetFrameLevel() or auraButton:GetFrameLevel()
  overlay:SetFrameLevel(math.max(cooldownLevel, barLevel, baseLevel) + 1)
end

local function IndicatorSettings(conditionEntry)
  local highlight, configured = {}, false
  for _, propertyChange in ipairs(conditionEntry.changes or {}) do
    local propertyPath = propertyChange.property
    if highlightProperties[propertyPath] then
      highlight[propertyPath] = propertyChange.value
      configured = true
    end
  end
  return highlight, configured
end

local function IsIndicatorValid(nativeDisplay, variableKind, conditionCheck)
  local comparable = conditionCheck.op == "==" or conditionCheck.op == "~="
  if variableKind == "faAuraType" then
    return comparable and (conditionCheck.value == "HELPFUL" or conditionCheck.value == "HARMFUL")
  end
  if variableKind == "faAuraDispel" then return comparable and type(conditionCheck.value) == "string" end
  if variableKind == "faAuraMissing" then return nativeDisplay.preview end
  return true
end

local function EnsureHost(nativeDisplay, position, auraButton)
  local indicatorFrame = nativeDisplay.conditionHosts[position]
  if not indicatorFrame then
    indicatorFrame = CreateFrame("Frame", nil, nativeDisplay.conditionOverlay)
    indicatorFrame:SetAllPoints(auraButton)
    nativeDisplay.conditionHosts[position] = indicatorFrame
  end
  return indicatorFrame
end

local function EnsureTextures(nativeDisplay, position, indicatorFrame)
  local edgeTextures = nativeDisplay.conditionIndicators[position]
  if not edgeTextures then
    edgeTextures = {}
    for side = 1, 4 do edgeTextures[side] = indicatorFrame:CreateTexture(nil, "OVERLAY", nil, 7) end
    nativeDisplay.conditionIndicators[position] = edgeTextures
  end
  return edgeTextures
end

local function EnsurePulse(indicatorFrame)
  if indicatorFrame.pulse then return end
  local group = indicatorFrame:CreateAnimationGroup()
  indicatorFrame.pulse = group
  group:SetLooping("REPEAT")
  local fadeOut = group:CreateAnimation("Alpha")
  indicatorFrame.fadeOut = fadeOut
  fadeOut:SetOrder(1)
  fadeOut:SetFromAlpha(1)
  fadeOut:SetToAlpha(0.2)
  local fadeIn = group:CreateAnimation("Alpha")
  indicatorFrame.fadeIn = fadeIn
  fadeIn:SetOrder(2)
  fadeIn:SetFromAlpha(0.2)
  fadeIn:SetToAlpha(1)
end

local function StartPulse(indicatorFrame, highlight)
  local period = tonumber(highlight.faAuraHighlightPulse) or 1
  if period == period then
    period = math.max(PULSE_BOUNDS.min, math.min(PULSE_BOUNDS.max, period))
  else
    period = 1
  end
  EnsurePulse(indicatorFrame)
  local half = period / 2
  indicatorFrame.fadeOut:SetDuration(half)
  indicatorFrame.fadeIn:SetDuration(half)
  indicatorFrame.pulse:Play()
end

local function IndicatorAsset(highlightStyle, highlight)
  if highlightStyle == "glow" then return "Interface\\Buttons\\UI-ActionButton-Border" end
  local customPath = highlight.faAuraHighlightTexture
  if highlightStyle == "texture" and type(customPath) == "string" and customPath ~= "" then return customPath end
  return "Interface\\Buttons\\WHITE8X8"
end

local function IndicatorSize(highlight, highlightStyle, auraData)
  local thickness = tonumber(highlight.faAuraHighlightSize) or 2
  if thickness == thickness then thickness = math.max(1, math.min(64, thickness)) else thickness = 2 end
  if highlightStyle ~= "border" then return thickness end
  return math.min(thickness, AuraDisplay.HighlightBorderLimit(auraData))
end

local function PlaceTexture(edge, anchor, highlightStyle, side, thickness)
  if highlightStyle == "border" then
    if side <= 2 then
      local edgeName = side == 1 and "TOP" or "BOTTOM"
      edge:SetPoint(edgeName .. "LEFT", anchor, edgeName .. "LEFT")
      edge:SetPoint(edgeName .. "RIGHT", anchor, edgeName .. "RIGHT")
      edge:SetHeight(thickness)
    else
      local edgeName = side == 3 and "LEFT" or "RIGHT"
      edge:SetPoint("TOP" .. edgeName, anchor, "TOP" .. edgeName)
      edge:SetPoint("BOTTOM" .. edgeName, anchor, "BOTTOM" .. edgeName)
      edge:SetWidth(thickness)
    end
    return
  end
  local inset = 0
  if highlightStyle == "glow" then inset = thickness + 8 elseif highlightStyle == "texture" then inset = thickness end
  edge:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
  edge:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
end

local function DispelOptions(variableKind, conditionCheck, equal, asset, red, green, blue)
  local options = {
    showWhenHelpful = true,
    showWhenHarmful = true,
    showWithoutDispelType = true,
    style = Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset,
    customDispelAssetMap = {},
    customDispelColorMap = {},
  }
  local stealable = variableKind == "faAuraStealable" or variableKind == "faAuraNotStealable"
  if variableKind == "faAuraType" then
    local auraFilter = conditionCheck.value
    if not equal then
      if auraFilter == "HELPFUL" then auraFilter = "HARMFUL" else auraFilter = "HELPFUL" end
    end
    options.showWhenHelpful = auraFilter == "HELPFUL"
    options.showWhenHarmful = auraFilter == "HARMFUL"
  elseif stealable then
    options.showWhenHarmful = false
    local filterName = variableKind == "faAuraStealable" and "Stealable" or "NotStealable"
    options.stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter[filterName]
  end
  for _, dispelName in ipairs(DISPEL_KEYS) do
    local wanted = conditionCheck.value
    if wanted == "Enrage" then wanted = "" end
    local included = variableKind ~= "faAuraDispel" or (wanted == dispelName) == equal
    if included then
      options.customDispelAssetMap[dispelName] = {asset = asset}
      options.customDispelColorMap[dispelName] = CreateColor(red, green, blue, 1)
    end
  end
  return options
end

local function AttachTexture(nativeDisplay, auraButton, edge, indicator)
  local variableKind, conditionCheck, equal = indicator.kind, indicator.check, indicator.equal
  if nativeDisplay.preview then
    local previewEntries = nativeDisplay.conditionPreview
    previewEntries[#previewEntries + 1] = {texture = edge, kind = variableKind, value = conditionCheck.value, equal = equal}
    return
  end
  if variableKind == "faAuraPandemic" and auraButton.AddPandemicRegion then
    auraButton:AddPandemicRegion(edge)
    return
  end
  if not auraButton.AddDispelTypeTexture then return end
  local options = DispelOptions(variableKind, conditionCheck, equal, indicator.asset, indicator.red, indicator.green, indicator.blue)
  auraButton:AddDispelTypeTexture(edge, options)
  local dispelTextures = nativeDisplay.conditionDispelTextures
  dispelTextures[#dispelTextures + 1] = edge
end

local function DrawIndicator(nativeDisplay, auraData, auraButton, position, variableKind, conditionCheck, highlight)
  local indicatorFrame = EnsureHost(nativeDisplay, position, auraButton)
  local edgeTextures = EnsureTextures(nativeDisplay, position, indicatorFrame)
  local highlightStyle = highlight.faAuraHighlightStyle or "border"
  if highlightStyle == "pulseBorder" then
    highlightStyle = "border"
    StartPulse(indicatorFrame, highlight)
  elseif highlightStyle == "pulseGlow" then
    highlightStyle = "glow"
    StartPulse(indicatorFrame, highlight)
  end
  local red, green, blue, alpha = ClampedColor(highlight.faAuraHighlightColor, HIGHLIGHT_COLOR):GetRGBA()
  local thickness = IndicatorSize(highlight, highlightStyle, auraData)
  local indicator = {
    kind = variableKind,
    check = conditionCheck,
    equal = conditionCheck.op == "==",
    asset = IndicatorAsset(highlightStyle, highlight),
    red = red,
    green = green,
    blue = blue,
  }
  local glowing = highlightStyle == "glow"
  for side, edge in ipairs(edgeTextures) do
    edge:ClearAllPoints()
    edge:Hide()
    if highlightStyle == "border" or side == 1 then
      edge:SetTexture(indicator.asset)
      edge:SetVertexColor(red, green, blue, 1)
      edge:SetAlpha(alpha)
      edge:SetDesaturated(glowing)
      edge:SetBlendMode(glowing and "ADD" or "BLEND")
      PlaceTexture(edge, auraButton, highlightStyle, side, thickness)
      AttachTexture(nativeDisplay, auraButton, edge, indicator)
    end
  end
end

function AuraDisplay.StyleNativeConditionIndicators(nativeDisplay, auraData)
  local auraButton = nativeDisplay.button
  ClearIndicatorState(nativeDisplay, auraData, auraButton)
  EnsureOverlay(nativeDisplay, auraButton)
  for position, conditionEntry in ipairs(auraData.conditions or {}) do
    local variableKind = AuraDisplay.NativeConditionKind(auraData, conditionEntry.check)
    local drawable = variableKind and not durationDefinitions[variableKind] and variableKind ~= "faAuraApplications"
      and not conditionEntry.linked
    if drawable then
      local highlight, configured = IndicatorSettings(conditionEntry)
      if configured and IsIndicatorValid(nativeDisplay, variableKind, conditionEntry.check) then
        DrawIndicator(nativeDisplay, auraData, auraButton, position, variableKind, conditionEntry.check, highlight)
      end
    end
  end
  if not nativeDisplay.preview then return end
  AuraDisplay.UpdateConditionPreview(nativeDisplay, auraData, 6)
end

local PREVIEW_RULES = {
  faAuraPresent = function() return true end,
  faAuraType = function(previewEntry, helpful)
    local expected = helpful and "HELPFUL" or "HARMFUL"
    return (previewEntry.value == expected) == (previewEntry.equal ~= false)
  end,
  faAuraDispel = function(previewEntry)
    return (previewEntry.value == "Magic") == (previewEntry.equal ~= false)
  end,
  faAuraNotStealable = function(_, helpful) return helpful end,
  faAuraPandemic = function(_, _, remaining) return remaining <= 1.8 and remaining > 0 end,
}

function AuraDisplay.UpdateConditionPreview(nativeDisplay, auraData, remaining)
  local triggerSettings = AuraDisplay.GetTrigger(auraData)
  local helpful = not triggerSettings or triggerSettings.debuffType ~= "HARMFUL"
  for _, previewEntry in ipairs(nativeDisplay.conditionPreview or {}) do
    local previewRule = PREVIEW_RULES[previewEntry.kind]
    local shown = previewRule and previewRule(previewEntry, helpful, remaining)
    previewEntry.texture:SetShown(shown == true)
  end
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L

-- Native conditions of the secret aura display. Two registries drive everything: the condition
-- variables (editor models, validation, threshold rules, highlights, preview) and the properties
-- (types, Missing permissions, appliers). Rendering of highlights lives at the end of the file.

local AuraDisplay = Private.BlizzardAuraDisplay

local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max

local WHITE = { 1, 1, 1, 1 }
local HIGHLIGHT_COLOR = { 1, 0.82, 0, 1 }
local GLOW_TEXTURE = "Interface\\Buttons\\UI-ActionButton-Border"
local FLAT_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local SIZE_MAX = 64
local PULSE_MIN, PULSE_MAX = 0.2, 5
local PANDEMIC_PREVIEW_SHARE = 0.3
local DISPEL_KEYS = { "None", "Magic", "Curse", "Disease", "Poison", "Bleed", "Enrage", "" }

---------------------------------------------------------------------------------------------------
-- Small helpers
---------------------------------------------------------------------------------------------------

local function Each(list)
  return ipairs(list or {})
end

local function IsTable(value)
  return type(value) == "table"
end

local function Slot(owner, field)
  local held = owner[field]
  if held == nil then
    held = {}
    owner[field] = held
  end
  return held
end

local function FirstProblem(validators, ...)
  for index = 1, #validators do
    local problem = validators[index](...)
    if problem then return problem end
  end
  return nil
end

local function ToNumber(value)
  local number = tonumber(value)
  if number ~= number then return nil end
  return number
end

local function Bounded(value, low, high, default)
  value = ToNumber(value)
  if value == nil then return default end
  return max(low, min(high, value))
end

local function ClampColor(color, fallback)
  local result = {}
  for index = 1, 4 do
    local component = type(color) == "table" and color[index]
    if type(component) ~= "number" or component ~= component then component = fallback[index] end
    result[index] = max(0, min(1, component))
  end
  return result
end

local function ParseSubPath(path)
  if type(path) ~= "string" then return nil end
  local position, key = path:match("^sub%.(%d+)%.(.+)$")
  return position and tonumber(position), key
end

local function ElementAt(data, position)
  local list = data.subRegions
  local element = type(list) == "table" and list[position]
  return type(element) == "table" and element or nil
end

local function Unescape(text)
  if type(text) ~= "string" then return text end
  return (text:gsub("%%%%", "%%"))
end

local function Detached(data, element)
  return AuraDisplay.IsDetachedElement(data, element) == true
end

local function CopyValue(value)
  if type(value) == "table" then return CopyTable(value) end
  return value
end

local function Merge(base, extra)
  for key, value in pairs(extra or {}) do base[key] = value end
  return base
end

local function SortedPoints(set)
  local list = {}
  for point in pairs(set) do list[#list + 1] = point end
  table.sort(list)
  return list
end

---------------------------------------------------------------------------------------------------
-- Messages and highlight definitions
---------------------------------------------------------------------------------------------------

local MESSAGES = {
  grouping = "Aura (Modern) conditions cannot be combined with AND, OR or Else If.",
  timeOperator = L["In Aura (Modern) conditions, time checks only accept < (less than) and >= (at least)."],
  typeOperator = L["In Aura (Modern) conditions, kind and dispel checks only accept == (is) and ~= (is not)."],
  missingRegion = "Aura Missing works on Icon, Bar, Progress Texture and Text displays.",
  missingShowOn = "Aura Missing needs the trigger's Show On set to Aura(s) Missing or Always.",
  remainingGlow = "To light a glow from the seconds left, compare with < and set the glow to on.",
  elapsedGlow = "To light a glow from the seconds elapsed, compare with < and set the glow to on.",
  pandemicGlow = "A glow driven by the pandemic window has to switch the glow on.",
  lateGlow = "Only one source may drive a given glow: either seconds left or seconds elapsed, or else the pandemic window.",
  timeBasis = "A countdown text follows one time basis only: seconds left, share left, elapsed, total, start or end.",
  property = "Choose a supported property for this Aura (Modern) condition.",
  foreignTrigger = "This check reads a trigger whose values conditions cannot use. Point it at another trigger or at a global variable.",
  borderDisplay = "Highlight border thickness",
  paddingDisplay = "Highlight padding",
  borderHint = "Thickness of the border, in interface units, capped at one quarter of the shortest side. Choose the style and the color in this same condition.",
  paddingHint = "Space kept around a glow or a custom texture, in interface units (the full overlay never uses it). Choose the style and the color in this same condition.",
}

-- Drawing recipes. A style either borrows another one (base, plus its own pulse) or describes how
-- its edges are drawn: sides = four edges, padding = the size becomes a margin, spill = extra margin.
local STYLES = {
  border = { label = "Plain border", sides = true },
  glow = { label = "Static glow", glow = true, texture = GLOW_TEXTURE, padding = true, spill = 8 },
  overlay = { label = "Full overlay" },
  texture = { label = "Custom texture", custom = true, padding = true },
  pulseBorder = { label = "Pulsing border", base = "border" },
  pulseGlow = { label = "Pulsing glow", base = "glow" },
}

local STYLE_LABELS = {}
for name, style in pairs(STYLES) do STYLE_LABELS[name] = style.label end

local HIGHLIGHT_FIELDS = {
  { property = "faAuraHighlightColor", label = "Highlight color", type = "color", default = HIGHLIGHT_COLOR },
  { property = "faAuraHighlightStyle", label = "Highlight style", type = "list", default = "border", values = STYLE_LABELS },
  { property = "faAuraHighlightPulse", label = "Highlight pulse period", type = "number", default = 1,
    min = PULSE_MIN, max = PULSE_MAX, step = 0.1 },
  { property = "faAuraHighlightSize", label = "Highlight thickness", type = "number", default = 2, min = 1, max = SIZE_MAX, step = 1 },
  { property = "faAuraHighlightTexture", label = "Highlight texture", type = "string", default = GLOW_TEXTURE },
}

local HIGHLIGHT_SET = {}
for _, field in ipairs(HIGHLIGHT_FIELDS) do HIGHLIGHT_SET[field.property] = true end

---------------------------------------------------------------------------------------------------
-- Property registry
---------------------------------------------------------------------------------------------------

local function Field(name)
  return function(native) return native[name] end
end

local function ProgressTexture(native)
  return native.progressTexture and native.progressTexture.texture
end

local function Driver(targetOf, method, spread)
  return function(native, _, value)
    local target = targetOf(native)
    if not target then return end
    if spread then target[method](target, unpack(value)) else target[method](target, value) end
  end
end

local function ResizeFont(fontString, size)
  if not fontString then return end
  local path, _, flags = fontString:GetFont()
  fontString:SetFont(path, size, flags or "")
end

local function ColorRoot(native, data, value)
  if data.regionType == "text" then
    if native.mainText then native.mainText:SetTextColor(unpack(value)) end
  elseif native.icon then
    native.icon:SetVertexColor(unpack(value))
  end
end

local function BackgroundRoot(native, _, value)
  if native.progressBackground then
    native.progressBackground:SetColor(unpack(value))
  elseif native.barBackground then
    native.barBackground:SetColorTexture(unpack(value))
  end
end

local ROOT_APPLIERS = {
  color = ColorRoot,
  foregroundColor = Driver(ProgressTexture, "SetVertexColor", true),
  desaturateForeground = Driver(ProgressTexture, "SetDesaturated"),
  backgroundColor = BackgroundRoot,
  barColor = Driver(Field("bar"), "SetStatusBarColor", true),
  desaturate = Driver(Field("icon"), "SetDesaturated"),
  icon_color = Driver(Field("icon"), "SetVertexColor", true),
  zoom = function(native, data, value) AuraDisplay.StyleIconTexCoords(native, data, value) end,
  inverse = Driver(Field("cooldown"), "SetReverse"),
  cooldownSwipe = Driver(Field("cooldown"), "SetDrawSwipe"),
  cooldownEdge = Driver(Field("cooldown"), "SetDrawEdge"),
  cooldownTextDisabled = Driver(Field("cooldown"), "SetHideCountdownNumbers"),
  fontSize = function(native, _, value) ResizeFont(native.mainText, value) end,
  displayText = function(native, _, value)
    if native.mainText then native.mainText:SetText(Unescape(value)) end
  end,
}

-- Root property types per region type, and what a Missing condition may touch on each.
local ROOT_PROPERTIES = {
  icon = { color = "color", desaturate = "bool", inverse = "bool", cooldownSwipe = "bool", cooldownEdge = "bool",
    cooldownTextDisabled = "bool", zoom = "number" },
  aurabar = { barColor = "color", backgroundColor = "color", icon_color = "color", desaturate = "bool" },
  text = { color = "color", fontSize = "number", displayText = "string" },
  progresstexture = { foregroundColor = "color", backgroundColor = "color", desaturateForeground = "bool" },
}

local MISSING_ROOT_NAMES = {
  icon = { "desaturate", "color", "zoom" },
  aurabar = { "barColor", "backgroundColor", "icon_color", "desaturate" },
  progresstexture = { "foregroundColor", "backgroundColor", "desaturateForeground" },
  text = { "color" },
}

local missingRoot = {}
for region, names in pairs(MISSING_ROOT_NAMES) do
  missingRoot[region] = {}
  for _, name in ipairs(names) do missingRoot[region][name] = true end
end
AuraDisplay.missingRootProperties = missingRoot

local ACTION_TYPES = { chat = true, sound = true, customcode = true, glowexternal = true }

function AuraDisplay.AnchorOffsetApplier(horizontal)
  return function(entry, _, _, offset)
    local text = entry and entry.text
    if not text then return end
    local point, relativeTo, relativePoint, x, y = text:GetPoint(1)
    text:ClearAllPoints()
    if offset ~= nil then
      if horizontal then x = offset else y = offset end
    end
    text:SetPoint(point, relativeTo, relativePoint, x, y)
  end
end

local function ApplyTextColor(entry, _, _, value)
  if entry.text then entry.text:SetTextColor(unpack(value)) end
end

local function ApplyTextContent(entry, _, _, value)
  if entry.text then entry.text:SetText(Unescape(value)) end
end

local function ApplyTextSize(entry, _, _, value)
  ResizeFont(entry.text, value)
end

-- Visibility and opacity share one applier: the text is hidden through its alpha, so both inputs
-- are read from the overrides first, then from the element itself.
local function ApplyTextPresence(entry, data, position, _, values)
  local text = entry.text
  if not text then return end
  local element = ElementAt(data, position) or {}
  local prefix = "sub." .. position .. "."
  local visible = values[prefix .. "text_visible"]
  if visible == nil then visible = element.text_visible ~= false end
  local opacity = values[prefix .. "text_alpha"]
  if opacity == nil then opacity = element.text_alpha end
  if opacity == nil then opacity = 1 end
  text:SetAlpha(visible and opacity or 0)
end

local function ApplyGlow(entry, _, _, value)
  local frames = entry.elementFrames
  local glow = frames and frames.glow
  if glow then glow:SetAlpha(value and 1 or 0) end
end

-- Per element type: key -> { type, apply, missing (a Missing condition may drive it), literalOnly }.
local ELEMENT_PROPERTIES = {
  subtext = {
    text_color = { type = "color", apply = ApplyTextColor, missing = true },
    text_visible = { type = "bool", apply = ApplyTextPresence, missing = true },
    text_text = { type = "string", apply = ApplyTextContent, literalOnly = true },
    text_fontSize = { type = "number", apply = ApplyTextSize },
    text_anchorXOffset = { type = "number", apply = AuraDisplay.AnchorOffsetApplier(true) },
    text_anchorYOffset = { type = "number", apply = AuraDisplay.AnchorOffsetApplier(false) },
    text_alpha = { type = "number", apply = ApplyTextPresence },
  },
  subglow = {
    glow = { type = "bool", apply = ApplyGlow, missing = true },
  },
}

local ELEMENT_APPLIERS = {}
for _, keys in pairs(ELEMENT_PROPERTIES) do
  for key, definition in pairs(keys) do ELEMENT_APPLIERS[key] = definition.apply end
end

local function DetachedType(data, element, key)
  local definition = Private.subRegionTypes and Private.subRegionTypes[element.type]
  local properties = (definition or {}).properties
  if type(properties) == "function" then properties = properties(data, element) end
  local property = type(properties) == "table" and properties[key]
  if type(property) ~= "table" or not property.type or property.valueFromBoolean or property.colorFromBoolean then
    return nil
  end
  return property.type
end

local function PropertyType(data, path)
  if path == nil then return nil end
  if ACTION_TYPES[path] then return path end
  local position, key = ParseSubPath(path)
  if not position then
    local kinds = ROOT_PROPERTIES[data.regionType]
    local kind = kinds and kinds[path]
    if path == "displayText" and AuraDisplay.TextKind(data.displayText) ~= "literal" then return nil end
    return kind
  end
  local element = ElementAt(data, position)
  if not element then return nil end
  if Detached(data, element) then return DetachedType(data, element, key) end
  local keys = ELEMENT_PROPERTIES[element.type]
  local definition = keys and keys[key]
  if not definition then return nil end
  if definition.literalOnly and AuraDisplay.TextKind(element.text_text) ~= "literal" then return nil end
  return definition.type
end

function AuraDisplay.IsNativeConditionProperty(auraData, path)
  if ACTION_TYPES[path] then return false end
  if AuraDisplay.IsDetachedProperty(auraData, path) then return false end
  return PropertyType(auraData, path) ~= nil
end

function AuraDisplay.IsGlowProperty(auraData, path)
  local position, key = ParseSubPath(path)
  if key ~= "glow" then return false end
  local element = ElementAt(auraData, position)
  return element ~= nil and element.type == "subglow" and not Detached(auraData, element)
end

---------------------------------------------------------------------------------------------------
-- Text targets
---------------------------------------------------------------------------------------------------

local ROOT_TEXT_CHANNELS = { color = "color", displayText = "text" }
local ELEMENT_TEXT_CHANNELS = { text_color = "color", text_visible = "visible", text_text = "text" }

-- The color path of the text a property belongs to, and what the property drives on it.
local function TextTarget(data, path, wantedKind)
  if path == nil then return nil end
  local position, key = ParseSubPath(path)
  if not position then
    local channel = ROOT_TEXT_CHANNELS[path]
    if channel and data.regionType == "text" and AuraDisplay.TextKind(data.displayText) == wantedKind then
      return "color", channel
    end
    return nil
  end
  local channel = ELEMENT_TEXT_CHANNELS[key]
  local element = channel and ElementAt(data, position)
  if element and element.type == "subtext" and not Detached(data, element)
    and AuraDisplay.TextKind(element.text_text) == wantedKind then
    return "sub." .. position .. ".text_color", channel
  end
  return nil
end

local function BaseTextVisible(data, path)
  local base = data.nativeConditionBaseData or data
  local position, key = ParseSubPath(path)
  if key ~= "text_color" then return true end
  local element = ElementAt(base, position)
  return not (element and element.text_visible == false)
end

---------------------------------------------------------------------------------------------------
-- Variable registry
---------------------------------------------------------------------------------------------------

local TIME_OPERATORS = { ["<"] = true, [">="] = true }
local KIND_OPERATORS = { ["=="] = true, ["~="] = true }
local STACK_OPERATORS = { ["<"] = true, [">="] = true, [">"] = true, ["<="] = true, ["=="] = true, ["~="] = true }

local function AllowsTimeText(data, path)
  local target, channel = TextTarget(data, path, "duration")
  return (target and channel ~= "text") == true
end

local function AllowsGlowOrTimeText(data, path)
  return AuraDisplay.IsGlowProperty(data, path) or AllowsTimeText(data, path)
end

local function AllowsStackText(data, path)
  return TextTarget(data, path, "stack") ~= nil
end

local function AllowsHighlight(_, path)
  return HIGHLIGHT_SET[path] == true
end

local function AllowsGlowOrHighlight(data, path)
  return AuraDisplay.IsGlowProperty(data, path) or HIGHLIGHT_SET[path] == true
end

local function AllowsMissing(data, path)
  local roots = missingRoot[data.regionType]
  if not roots then return false end
  if HIGHLIGHT_SET[path] or roots[path] then return true end
  local position, key = ParseSubPath(path)
  if not position then return false end
  local element = ElementAt(data, position)
  if not element or Detached(data, element) then return false end
  local keys = ELEMENT_PROPERTIES[element.type]
  local definition = keys and keys[key]
  return definition ~= nil and definition.missing == true
end

local function MissingHeader(data)
  if not missingRoot[data.regionType] then return MESSAGES.missingRegion end
  local showOn = AuraDisplay.ShowOn(AuraDisplay.GetTrigger(data))
  if showOn ~= "showOnMissing" and showOn ~= "showAlways" then return MESSAGES.missingShowOn end
end

local function UsesVariable(data, index, name)
  local function Scan(check)
    if not IsTable(check) then return false end
    if check.trigger == index and check.variable == name then return true end
    for _, child in Each(check.checks) do
      if Scan(child) then return true end
    end
    return false
  end
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    if Scan(condition.check) then return true end
  end
  return false
end

local function Spec(base, extra)
  return Merge(base, extra)
end

local function Duration(label, binding, extra)
  return Spec({
    family = "duration", label = label, binding = binding, divisor = 1, allows = AllowsTimeText,
    operators = TIME_OPERATORS, operatorMessage = "timeOperator",
    offered = function(variable, data, index, name)
      if not AuraDisplay.SupportsDurationColorCondition() then return false end
      if Enum.DurationTextBindingProperty[variable.binding] == nil then return false end
      return not variable.onDemand or UsesVariable(data, index, name)
    end,
  }, extra)
end

local function Plain(label, extra)
  return Spec({ family = "plain", label = label, allows = AllowsHighlight, indicator = {} }, extra)
end

local function StealableIndicator(filterName)
  return {
    configure = function(options)
      options.showWhenHarmful, options.stealableFilter =
        false, Enum.CustomAuraButtonDispelTypeStealableFilter[filterName]
    end,
  }
end

local function SameAsExpected(entry, expected)
  return (entry.value == expected) == (entry.equal ~= false)
end

local VARIABLES = {
  faAuraRemaining = Duration("Seconds left", "RemainingDuration", {
    allows = AllowsGlowOrTimeText, glow = { message = "remainingGlow", operator = "<", conflictWhenSame = false } }),
  faAuraRemainingPercent = Duration("Share of time left (%)", "RemainingPercent", { divisor = 100 }),
  faAuraElapsed = Duration("Seconds elapsed", "ElapsedDuration", {
    allows = AllowsGlowOrTimeText, glow = { message = "elapsedGlow", operator = "<", conflictWhenSame = false } }),
  faAuraElapsedPercent = Duration("Share of time elapsed (%)", "ElapsedPercent", { divisor = 100 }),
  faAuraTotal = Duration("Full duration (seconds)", "TotalDuration"),
  faAuraStart = Duration("Start time", "StartTime", { onDemand = true }),
  faAuraEnd = Duration("End time", "EndTime", { onDemand = true }),

  faAuraApplications = {
    family = "stack", label = "Stack count", divisor = 1, allows = AllowsStackText, operators = STACK_OPERATORS,
    offered = function() return not not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) end,
  },

  faAuraPandemic = Plain("Pandemic refresh window", {
    allows = AllowsGlowOrHighlight,
    glow = { message = "pandemicGlow", conflictWhenSame = true },
    preview = function(_, remaining)
      return type(remaining) == "number" and remaining > 0
        and remaining <= AuraDisplay.PREVIEW_SAMPLE_DURATION * PANDEMIC_PREVIEW_SHARE
    end,
  }),
  faAuraStealable = Plain("Aura can be stolen", { indicator = StealableIndicator("Stealable") }),
  faAuraNotStealable = Plain("Aura cannot be stolen", {
    indicator = StealableIndicator("NotStealable"),
    preview = function(_, _, isBuff) return isBuff end,
  }),
  faAuraPresent = Plain("Aura is up", { preview = function() return true end }),

  faAuraType = {
    family = "select", label = "Kind of aura", allows = AllowsHighlight,
    operators = KIND_OPERATORS, operatorMessage = "typeOperator",
    options = function() return { HELPFUL = "Helpful aura", HARMFUL = "Harmful aura" } end,
    indicator = {
      valid = function(check)
        return KIND_OPERATORS[check.op] and (check.value == "HELPFUL" or check.value == "HARMFUL")
      end,
      configure = function(options, check, equal)
        local filter = check.value
        if not equal then filter = filter == "HELPFUL" and "HARMFUL" or "HELPFUL" end
        options.showWhenHelpful = filter == "HELPFUL"
        options.showWhenHarmful = filter == "HARMFUL"
      end,
    },
    preview = function(entry, _, isBuff) return SameAsExpected(entry, isBuff and "HELPFUL" or "HARMFUL") end,
  },
  faAuraDispel = {
    family = "select", label = "Dispel school", allows = AllowsHighlight,
    operators = KIND_OPERATORS, operatorMessage = "typeOperator",
    options = function()
      local values = {}
      for _, name in ipairs({ "Magic", "Curse", "Disease", "Poison", "Bleed", "Enrage", "None" }) do values[name] = name end
      return values
    end,
    indicator = {
      valid = function(check) return KIND_OPERATORS[check.op] and type(check.value) == "string" end,
      configure = function(_, check, equal)
        local wanted = check.value == "Enrage" and "" or check.value
        return function(key) return (wanted == key) == equal end
      end,
    },
    preview = function(entry) return SameAsExpected(entry, "Magic") end,
  },

  faAuraMissing = {
    family = "missing", label = "Aura is absent", allows = AllowsMissing, header = MissingHeader,
    indicator = { valid = function(_, native) return native.preview end },
  },
}

local MODEL_FAMILIES = {
  duration = { type = "number", operatorTypes = "native_aura_duration" },
  stack = { type = "number" },
  select = { type = "select", operatorTypes = "native_aura_dispel" },
  plain = { type = "alwaystrue" },
  missing = { type = "alwaystrue" },
}

---------------------------------------------------------------------------------------------------
-- Kinds
---------------------------------------------------------------------------------------------------

function AuraDisplay.IsNativeDurationCondition(conditionCheck)
  if conditionCheck == nil then return nil end
  local variable = VARIABLES[conditionCheck.variable]
  return variable ~= nil and variable.family == "duration"
end

function AuraDisplay.NativeConditionKind(auraData, conditionCheck)
  if not conditionCheck then return nil end
  local triggers = auraData.triggers
  local slot = type(triggers) == "table" and triggers[conditionCheck.trigger] or nil
  local source = type(slot) == "table" and slot.trigger or nil
  local isSecret = type(source) == "table" and source.type == "secretAura"
  return isSecret and VARIABLES[conditionCheck.variable] and conditionCheck.variable or nil
end

function AuraDisplay.ContainsNativeCondition(auraData, conditionCheck)
  local pending = conditionCheck and { conditionCheck } or {}
  while #pending > 0 do
    local current = table.remove(pending)
    if AuraDisplay.NativeConditionKind(auraData, current) then return true end
    for _, child in ipairs(current.checks or {}) do pending[#pending + 1] = child end
  end
  return false
end

function AuraDisplay.SupportsDurationColorCondition()
  return not not (C_CurveUtil and C_CurveUtil.CreateColorCurve and CreateColor
    and Enum.LuaCurveType and Enum.LuaCurveType.Step
    and Enum.DurationTextBindingProperty and Enum.DurationTextBindingProperty.RemainingDuration)
end

function AuraDisplay.NativeConditionAllowsProperty(auraData, conditionCheck, path)
  local name = AuraDisplay.NativeConditionKind(auraData, conditionCheck)
  if not name then return HIGHLIGHT_SET[path] ~= true end
  return VARIABLES[name].allows(auraData, path)
end

local function MissingConditions(data)
  local found = {}
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    if AuraDisplay.NativeConditionKind(data, condition.check) == "faAuraMissing" then found[#found + 1] = condition end
  end
  return found
end

function AuraDisplay.MissingDesaturated(auraData)
  for _, condition in ipairs(MissingConditions(auraData)) do
    for _, change in Each(condition.changes) do
      if change.value == true and change.property == "desaturate" then return true end
    end
  end
  return false
end

---------------------------------------------------------------------------------------------------
-- Threshold rules (per aura, per target text), duration curves and stack text
---------------------------------------------------------------------------------------------------

local TESTS = {
  ["<"] = function(point, threshold) return point < threshold end,
  [">="] = function(point, threshold) return point >= threshold end,
  [">"] = function(point, threshold) return point > threshold end,
  ["<="] = function(point, threshold) return point <= threshold end,
  ["=="] = function(point, threshold) return point == threshold end,
  ["~="] = function(point, threshold) return point ~= threshold end,
}

local NO_RULES = {}
local ruleCaches = setmetatable({}, { __mode = "k" })

local function CacheFor(data)
  local cache = ruleCaches[data]
  if not cache then
    cache = { owns = {}, duration = {}, stack = {} }
    ruleCaches[data] = cache
  end
  return cache
end

function AuraDisplay.ForgetConditionRules(auraData)
  ruleCaches[auraData] = nil
end

local function CollectRules(data, path, family)
  local rules = {}
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    local check = type(condition) == "table" and not condition.linked and condition.check
    local variable = check and VARIABLES[AuraDisplay.NativeConditionKind(data, check)]
    local threshold = variable and variable.family == family and ToNumber(check.value)
    if threshold and threshold >= 0 and threshold < math.huge and variable.operators[check.op] then
      for _, change in Each(condition.changes) do
        local target, channel = TextTarget(data, change.property, family)
        if target == path and (family ~= "duration" or channel ~= "text") then
          rules[#rules + 1] = {
            threshold = threshold / variable.divisor, operator = check.op, value = change.value,
            channel = channel, variable = check.variable,
          }
        end
      end
    end
  end
  return rules
end

local function Rules(data, path, family)
  if path == nil then return NO_RULES end
  local byPath = CacheFor(data)[family]
  local rules = byPath[path]
  if not rules then
    rules = CollectRules(data, path, family)
    byPath[path] = rules
  end
  return rules
end

-- Folds every rule satisfied at a point into the state, in order (the last one wins).
local function ApplyRules(rules, point, state)
  for _, rule in Each(rules) do
    if TESTS[rule.operator](point, rule.threshold) then
      if rule.channel == "color" then
        state.color = rule.value
      elseif rule.channel == "visible" then
        state.visible = rule.value ~= false
      elseif rule.channel == "text" and type(rule.value) == "string" then
        state.text = rule.value
        state.visible = true
      end
    end
  end
  return state
end

local function CurveColor(data, path, rules, window, baseColor, point)
  local state = ApplyRules(rules, point, { color = baseColor, visible = BaseTextVisible(data, path) })
  if window and not AuraDisplay.InRemainingWindow(point, window[1], window[2]) then state.visible = false end
  local color = ClampColor(state.color, WHITE)
  if not state.visible then color[4] = 0 end
  return CreateColor(unpack(color))
end

local function NewStepCurve()
  local made = C_CurveUtil.CreateColorCurve()
  made:SetType(Enum.LuaCurveType.Step)
  return made
end

function AuraDisplay.DurationColorCondition(auraData, baseColor, path, window)
  if not AuraDisplay.SupportsDurationColorCondition() then return nil end
  local rules = Rules(auraData, path, "duration")
  if #rules == 0 and not window then return nil end
  local name = rules[1] and rules[1].variable or "faAuraRemaining"
  if window and name ~= "faAuraRemaining" then return nil end
  local binding = Enum.DurationTextBindingProperty[VARIABLES[name].binding]
  if binding == nil then return nil end

  local points = { [0] = true }
  for _, rule in Each(rules) do
    if rule.variable ~= name then return nil end
    points[rule.threshold] = true
  end
  if window then
    for _, point in ipairs(AuraDisplay.RemainingWindowPoints(window[1], window[2])) do points[point] = true end
  end

  local curve = NewStepCurve()
  for _, point in ipairs(SortedPoints(points)) do
    curve:AddPoint(point, CurveColor(auraData, path, rules, window, baseColor, point))
  end
  return { curve = curve, property = binding }
end

local function StackPoints(rules)
  local points = { [0] = true, [2] = true }
  for _, rule in Each(rules) do
    local whole = floor(rule.threshold)
    points[whole], points[ceil(rule.threshold)], points[whole + 1] = true, true, true
  end
  return SortedPoints(points)
end

local function StackFormat(data, path, rules, point)
  local state = ApplyRules(rules, point, { visible = point >= 2 and BaseTextVisible(data, path) })
  if not state.visible then return "" end
  local pattern = state.text and (state.text:gsub("%%", "%%%%")) or "%d"
  if not state.color then return pattern end
  local color = ClampColor(state.color, WHITE)
  return ("|cff%02x%02x%02x%s|r"):format(floor(color[1] * 255 + 0.5), floor(color[2] * 255 + 0.5),
    floor(color[3] * 255 + 0.5), pattern)
end

function AuraDisplay.StackTextFor(auraData, path, count)
  local rules = Rules(auraData, path, "stack")
  if #rules == 0 then return count >= 2 and tostring(count) or "" end
  local format = ""
  for _, point in ipairs(StackPoints(rules)) do
    if point <= count then format = StackFormat(auraData, path, rules, point) end
  end
  return (format:gsub("%%([%%d])", function(symbol) return symbol == "d" and tostring(count) or "%" end))
end

function AuraDisplay.StackTextCondition(auraData, path)
  if not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) then return nil end
  local rules = Rules(auraData, path, "stack")
  if #rules == 0 then return nil end
  local steps = {}
  for _, point in ipairs(StackPoints(rules)) do
    steps[#steps + 1] = { threshold = point, format = StackFormat(auraData, path, rules, point) }
  end
  local rendering = C_StringUtil.CreateNumericRuleFormatter()
  rendering:SetBreakpoints(steps)
  return rendering
end

-- True when the native display drives this color path alone (curve or formatter): applying the
-- condition value on top of it would fight the native binding.
local function OwnsColor(data, path)
  if path == nil then return false end
  local owns = CacheFor(data).owns
  local cached = owns[path]
  if cached == nil then
    local timeTarget = TextTarget(data, path, "duration")
    local stackTarget = TextTarget(data, path, "stack")
    cached = (timeTarget ~= nil and AuraDisplay.SupportsDurationColorCondition()
        and #Rules(data, timeTarget, "duration") > 0)
      or (stackTarget ~= nil and C_StringUtil ~= nil and C_StringUtil.CreateNumericRuleFormatter ~= nil
        and #Rules(data, stackTarget, "stack") > 0)
    cached = not not cached
    owns[path] = cached
  end
  return cached
end

---------------------------------------------------------------------------------------------------
-- Migration of the previous switches
---------------------------------------------------------------------------------------------------

local function FirstSecretTrigger(data)
  if type(data.triggers) ~= "table" then return nil end
  for index, entry in Each(data.triggers) do
    if type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type == "secretAura" then
      return index
    end
  end
  return nil
end

local function LegacyRemainingTarget(data)
  if data.regionType == "text" and AuraDisplay.TextKind(data.displayText) == "duration" then return "color" end
  for position, element in ipairs(data.subRegions or {}) do
    if element.type == "subtext" and element.text_visible ~= false and not Detached(data, element)
      and AuraDisplay.TextKind(element.text_text) == "duration" then
      return "sub." .. position .. ".text_color"
    end
  end
  return nil
end

local function AppendCondition(data, check, property, value)
  if not data.conditions then data.conditions = {} end
  data.conditions[#data.conditions + 1] = { check = check, changes = { { property = property, value = value } } }
end

function AuraDisplay.MigrateNativeConditions(auraData)
  local previous = auraData.blizzardAuraDisplay
  if type(previous) ~= "table" then return end
  local trigger = FirstSecretTrigger(auraData)
  if not trigger then return end

  if previous.missingDesaturate then
    AppendCondition(auraData, { trigger = trigger, variable = "faAuraMissing" }, "desaturate", true)
    previous.missingDesaturate = nil
  end
  if previous.remainingTimeColorEnabled then
    local target = LegacyRemainingTarget(auraData)
    if target then
      AppendCondition(auraData, { trigger = trigger, variable = "faAuraRemaining", op = "<",
        value = previous.remainingTimeColorThreshold or 10 }, target, previous.remainingTimeColor or { 1, 0, 0, 1 })
      previous.remainingTimeColorEnabled = nil
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Editor: highlight properties and condition models
---------------------------------------------------------------------------------------------------

function AuraDisplay.FilterConditionProperties(auraData, definitions)
  if not AuraDisplay.Enabled(auraData) then return definitions end
  for _, field in ipairs(HIGHLIGHT_FIELDS) do
    definitions[field.property] = {
      display = field.label, type = field.type, default = CopyValue(field.default), values = CopyValue(field.values),
      min = field.min, max = field.max, step = field.step,
    }
  end
  return definitions
end

local function ResolveStyle(name)
  local style = STYLES[name] or STYLES.overlay
  local pulse = false
  if style.base then
    pulse = true
    style = STYLES[style.base]
  end
  return style, pulse
end

function AuraDisplay.HighlightBorderLimit(auraData)
  local box = { AuraDisplay.Dimensions(auraData) }
  local shortest = box[1] < box[2] and box[1] or box[2]
  return max(1, (shortest - shortest % 4) / 4)
end

function AuraDisplay.HighlightPropertyOptions(auraData, condition, path, definition)
  if path ~= "faAuraHighlightSize" or not definition then return definition end
  local style = "border"
  for _, change in Each(condition and condition.changes) do
    local isStyle = change.property == "faAuraHighlightStyle"
    if isStyle then style = change.value end
  end
  local options = CopyTable(definition)
  if ResolveStyle(style).sides then
    options.display, options.description, options.max = MESSAGES.borderDisplay, MESSAGES.borderHint,
      AuraDisplay.HighlightBorderLimit(auraData)
  else
    options.display, options.description, options.max = MESSAGES.paddingDisplay, MESSAGES.paddingHint, SIZE_MAX
  end
  return options
end

local function TriggerIsSecret(data, index)
  local entry = type(data.triggers) == "table" and data.triggers[index]
  return type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type == "secretAura"
end

local function BuildModel(data, index, name, variable)
  if variable.offered and not variable.offered(variable, data, index, name) then return nil end
  local family = MODEL_FAMILIES[variable.family]
  return {
    display = variable.label, type = family.type, operator_types = family.operatorTypes,
    values = variable.options and variable.options() or nil,
  }
end

function AuraDisplay.FilterConditionTemplates(auraData, templatesByTrigger)
  if not AuraDisplay.Enabled(auraData) then return templatesByTrigger end
  for index in pairs(templatesByTrigger) do
    if TriggerIsSecret(auraData, index) then
      local models = {}
      for name, variable in pairs(VARIABLES) do models[name] = BuildModel(auraData, index, name, variable) end
      templatesByTrigger[index] = models
    end
  end
  return templatesByTrigger
end

---------------------------------------------------------------------------------------------------
-- Validation: header validators, then change validators, then the trigger check
---------------------------------------------------------------------------------------------------

local HEADER_VALIDATORS = {
  function(context)
    if not context.variable or context.condition.linked or (context.following and context.following.linked) then
      return MESSAGES.grouping
    end
  end,
  function(context)
    local variable, operator = context.variable, context.check.op
    if variable.operatorMessage and operator ~= nil and not variable.operators[operator] then
      return MESSAGES[variable.operatorMessage]
    end
  end,
  function(context)
    if context.variable.header then return context.variable.header(context.pass.data) end
  end,
}

local function LateGlowIndex(pass)
  if not pass.lateKnown then
    pass.lateKnown = true
    pass.lateIndex = select(3, AuraDisplay.LateGlowSpec(pass.data, AuraDisplay.GetTrigger(pass.data)))
  end
  return pass.lateIndex
end

local CHANGE_VALIDATORS = {
  function(context, change)
    local glow = context.variable.glow
    if not glow or not AuraDisplay.IsGlowProperty(context.pass.data, change.property) then return nil end
    if (glow.operator ~= nil and context.check.op ~= glow.operator) or change.value ~= true then
      return MESSAGES[glow.message]
    end
    local late = LateGlowIndex(context.pass)
    if late and (change.property == "sub." .. late .. ".glow") == glow.conflictWhenSame then return MESSAGES.lateGlow end
  end,
  function(context, change)
    if context.variable.family ~= "duration" then return nil end
    local target = TextTarget(context.pass.data, change.property, "duration")
    if not target then return nil end
    local seen = context.pass.bases
    if seen[target] and seen[target] ~= context.name then return MESSAGES.timeBasis end
    seen[target] = context.name
  end,
  function(context, change)
    if change.property ~= nil
      and not AuraDisplay.NativeConditionAllowsProperty(context.pass.data, context.check, change.property) then
      return MESSAGES.property
    end
  end,
}

local function CheckUsable(data, check)
  local name = check and check.variable
  if not name then return true end
  if name == "AND" or name == "OR" then
    for _, child in Each(check.checks) do
      if not CheckUsable(data, child) then return false end
    end
    return true
  end
  local slot = check.trigger
  if slot == -1 then return true end
  local entry = IsTable(data.triggers) and data.triggers[slot] or nil
  if not (IsTable(entry) and IsTable(entry.trigger)) then return false end
  return entry.trigger.type ~= "secretAura" or VARIABLES[name] ~= nil
end

local function NativeConditionProblem(pass, condition, following)
  local name = AuraDisplay.NativeConditionKind(pass.data, condition.check)
  local context = { pass = pass, condition = condition, following = following, check = condition.check,
    name = name, variable = name and VARIABLES[name] }
  local found = FirstProblem(HEADER_VALIDATORS, context)
  for _, change in Each(condition.changes) do
    if found ~= nil then break end
    found = FirstProblem(CHANGE_VALIDATORS, context, change)
  end
  return found
end

function AuraDisplay.ValidateConditions(auraData)
  local conditions = auraData.conditions
  if not IsTable(conditions) then return nil end
  local pass = { data = auraData, bases = {} }
  for index, condition in ipairs(conditions) do
    local found
    if AuraDisplay.ContainsNativeCondition(auraData, condition.check) then
      found = NativeConditionProblem(pass, condition, conditions[index + 1])
    end
    if found == nil and not CheckUsable(auraData, condition.check) then found = MESSAGES.foreignTrigger end
    if found ~= nil then return found end
  end
  return nil
end

---------------------------------------------------------------------------------------------------
-- Appearance copy: elements a condition may switch on later must exist at render time
---------------------------------------------------------------------------------------------------

local FORCED_KEYS = { glow = true, text_visible = true }

-- Copies the aura only when the first element needs forcing; each element is copied once.
local function LazyAppearanceCopy(data)
  local copy
  local forced = {}
  return {
    Force = function(position, key)
      if not copy then
        copy = Merge({}, data)
        copy.subRegions = Merge({}, data.subRegions)
        copy.nativeConditionBaseData = data
      end
      if not forced[position] then
        copy.subRegions[position] = CopyTable(copy.subRegions[position])
        forced[position] = true
      end
      copy.subRegions[position][key] = true
    end,
    Result = function() return copy or data end,
  }
end

function AuraDisplay.PrepareConditionAppearance(auraData)
  if type(auraData.conditions) ~= "table" then return auraData end
  local builder = LazyAppearanceCopy(auraData)
  for _, condition in ipairs(auraData.conditions) do
    for _, change in Each(condition.changes) do
      local position, key = ParseSubPath(change.property)
      if position and FORCED_KEYS[key] and not AuraDisplay.IsDetachedProperty(auraData, change.property)
        and PropertyType(auraData, change.property) ~= nil then
        builder.Force(position, key)
      end
    end
  end
  return builder.Result()
end

---------------------------------------------------------------------------------------------------
-- Applying property values to native buttons
---------------------------------------------------------------------------------------------------

local function ApplyProperty(native, data, path, value, values)
  if OwnsColor(data, path) then return end
  if not native.preview and WeakAuras.IsRestricted() then return end
  local position, key = ParseSubPath(path)
  if not position then
    local apply = ROOT_APPLIERS[path]
    if apply then apply(native, data, value) end
    return
  end
  local entry = native.sharedElements and native.sharedElements[position]
  local apply = entry and ELEMENT_APPLIERS[key]
  if apply then apply(entry, data, position, value, values) end
end

local function SameValue(old, new)
  if type(old) ~= "table" or type(new) ~= "table" then return old == new end
  if #old ~= #new then return false end
  for index = 1, #old do
    if Private.IsSecret(old[index], new[index]) or old[index] ~= new[index] then return false end
  end
  return true
end

local function EachNative(display, visit)
  for _, instance in ipairs(display.instances or {}) do
    for _, button in ipairs(instance.buttons or {}) do visit(button, false) end
    local missing = instance.single and instance.single.missing and instance.single.missing.native
    if missing then visit(missing, true) end
  end
end

local function KeepMissing(native, data)
  if AuraDisplay.KeepMissingDesaturated then AuraDisplay.KeepMissingDesaturated(native, data) end
end

function AuraDisplay.SetConditionProperty(auraRegion, path, ...)
  local display = auraRegion.blizzardAuraDisplay
  if not (display and display.active and display.data) then return end
  local data = display.data
  local kind = PropertyType(data, path)
  if kind == nil then return end
  local value
  if kind == "color" then value = { ... } else value = (...) end

  local values = auraRegion.secretAuraConditionValues
  if not values then
    values = {}
    auraRegion.secretAuraConditionValues = values
  end
  local previous = values[path]
  if previous ~= nil and not Private.IsSecret(previous, value) and SameValue(previous, value) then return end
  values[path] = value

  EachNative(display, function(native, isMissing)
    ApplyProperty(native, data, path, value, values)
    if isMissing then KeepMissing(native, data) end
  end)
end

function AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
  local values = {}
  for _, condition in ipairs(MissingConditions(auraData)) do
    for _, change in Each(condition.changes) do
      local property = change.property
      if property ~= nil and not HIGHLIGHT_SET[property] and change.value ~= nil
        and AuraDisplay.NativeConditionAllowsProperty(auraData, condition.check, property) then
        values[property] = change.value
      end
    end
  end
  for property, value in pairs(values) do ApplyProperty(nativeDisplay, auraData, property, value, values) end
end

-- What an element looks like before any condition acts on it.
local BASE_STATES = {
  subglow = { key = "glow", read = function(element) return element.glow == true end },
  subtext = { key = "text_visible", read = function(element) return element.text_visible ~= false end },
}

function AuraDisplay.ApplyConditionAppearance(auraButton, auraRegion, auraData)
  local values = auraRegion.secretAuraConditionValues or {}
  for position, element in ipairs(auraData.subRegions or {}) do
    local base = BASE_STATES[element.type]
    if base and not Detached(auraData, element) then
      ApplyProperty(auraButton, auraData, "sub." .. position .. "." .. base.key, base.read(element), values)
    end
  end
  for path, value in pairs(auraRegion.secretAuraConditionValues or {}) do
    ApplyProperty(auraButton, auraData, path, value, values)
  end
end

function AuraDisplay.RefreshConditionAppearance(auraRegion)
  local display = auraRegion.blizzardAuraDisplay
  if not (display and display.active and auraRegion.secretAuraConditionValues) then return end
  EachNative(display, function(native, isMissing)
    AuraDisplay.ApplyConditionAppearance(native, auraRegion, display.data)
    if isMissing then KeepMissing(native, display.data) end
  end)
end

---------------------------------------------------------------------------------------------------
-- Pandemic glow frames
---------------------------------------------------------------------------------------------------

-- Creates store[key] on first use, then hands back the stored object.
local function Cached(store, key, build)
  local item = store[key]
  if item == nil then
    item = build()
    store[key] = item
  end
  return item
end

local function PandemicDrivesGlow(data, position)
  local wanted = "sub." .. position .. ".glow"
  for _, entry in Each(IsTable(data.conditions) and data.conditions or nil) do
    if not entry.linked and AuraDisplay.NativeConditionKind(data, entry.check) == "faAuraPandemic" then
      for _, change in Each(entry.changes) do
        if change.value == true and change.property == wanted then return true end
      end
    end
  end
  return false
end

function AuraDisplay.PandemicGlowHolder(nativeDisplay, auraData, position, levelFrame)
  local element = ElementAt(auraData.nativeConditionBaseData or auraData, position)
  local eligible = element ~= nil and element.type == "subglow" and not element.glow
  if not (eligible and PandemicDrivesGlow(auraData, position)) then return nil end

  local glowFrame = Cached(Slot(nativeDisplay, "pandemicGlowFrames"), position, function()
    return CreateFrame("Frame", nil, nativeDisplay.gateClip or nativeDisplay.button)
  end)
  glowFrame:ClearAllPoints()
  glowFrame:SetAllPoints(nativeDisplay.button)
  glowFrame:SetFrameLevel(levelFrame:GetFrameLevel() + 1)
  glowFrame:Hide()
  Slot(nativeDisplay, "pandemicGlows")[position] = glowFrame
  return glowFrame
end

function AuraDisplay.ResetPandemicGlows(nativeDisplay)
  local frames = nativeDisplay.pandemicGlowFrames
  nativeDisplay.pandemicGlows = {}
  for position in pairs(frames or {}) do frames[position]:Hide() end
end

---------------------------------------------------------------------------------------------------
-- Highlight indicators
---------------------------------------------------------------------------------------------------

local BORDER_SIDES = {
  { "TOPLEFT", "TOPRIGHT", "SetHeight" },
  { "BOTTOMLEFT", "BOTTOMRIGHT", "SetHeight" },
  { "TOPLEFT", "BOTTOMLEFT", "SetWidth" },
  { "TOPRIGHT", "BOTTOMRIGHT", "SetWidth" },
}

local function LevelOf(frame)
  return frame and frame:GetFrameLevel() or 0
end

local function ReleaseHosts(native)
  for _, carrier in pairs(native.conditionHosts) do
    local owner = carrier.pulseOwner
    if owner then
      pcall(owner.RemoveAuraShownAnimation, owner, carrier.pulse)
      carrier.pulseOwner = nil
    end
    if carrier.pulse then carrier.pulse:Stop() end
    carrier:SetAlpha(1)
  end
end

local function RegisterPandemicGlows(native, data)
  local button = native.button
  for _, frame in pairs(native.pandemicGlows or {}) do
    if native.preview then
      table.insert(native.conditionPreview, { texture = frame, kind = "faAuraPandemic" })
    elseif type(button.AddPandemicRegion) == "function" then
      button:AddPandemicRegion(frame)
    end
  end
end

local function ResetIndicators(native, data)
  local owner = native.button
  local clear = owner.ClearPandemicRegions
  if clear and not native.preview then clear(owner) end
  for _, edges in pairs(Slot(native, "conditionIndicators")) do
    for index = 1, #edges do edges[index]:Hide() end
  end
  Slot(native, "conditionHosts")
  ReleaseHosts(native)
  local attached = native.conditionDispelTextures or {}
  for index = 1, #attached do owner:RemoveDispelTypeTexture(attached[index]) end
  native.conditionDispelTextures, native.conditionPreview = {}, {}
  native.conditionData = nil
  if native.preview then native.conditionData = data end
  RegisterPandemicGlows(native, data)
end

local function PlaceOverlay(native)
  local button = native.button
  local overlay = native.conditionOverlay
  if not overlay then
    overlay = CreateFrame("Frame", nil, native.gateClip or button)
    native.conditionOverlay = overlay
  end
  overlay:ClearAllPoints()
  overlay:SetAllPoints(native.button)
  local base = native.elementFrames and native.elementFrames.sharedBase or button
  overlay:SetFrameLevel(max(LevelOf(native.cooldown), LevelOf(native.bar), LevelOf(base)) + 1)
end

-- The condition's highlight settings (the last change of each property wins), or nil when the
-- condition is not drawn at all.
local function IndicatorPlan(native, data, condition)
  local check = type(condition) == "table" and not condition.linked and condition.check
  local name = check and AuraDisplay.NativeConditionKind(data, check)
  local variable = name and VARIABLES[name]
  local rule = variable and variable.indicator
  if not rule or (rule.valid and not rule.valid(check, native)) then return nil end
  local settings, found = {}, false
  for _, change in Each(condition.changes) do
    if HIGHLIGHT_SET[change.property] then
      settings[change.property] = change.value
      found = true
    end
  end
  if not found then return nil end
  return { name = name, variable = variable, check = check, settings = settings }
end

local function ResolveLook(settings, data)
  local style, pulse = ResolveStyle(settings.faAuraHighlightStyle or "border")
  local size = Bounded(settings.faAuraHighlightSize, 1, SIZE_MAX, 2)
  if style.sides then size = min(size, AuraDisplay.HighlightBorderLimit(data)) end
  local texture = style.texture or FLAT_TEXTURE
  if style.custom then
    local path = settings.faAuraHighlightTexture
    if type(path) == "string" and path ~= "" then texture = path end
  end
  return {
    sides = style.sides == true, glow = style.glow == true, pulse = pulse, size = size, texture = texture,
    inset = (style.padding and size or 0) + (style.spill or 0),
    period = Bounded(settings.faAuraHighlightPulse, PULSE_MIN, PULSE_MAX, 1),
    color = ClampColor(settings.faAuraHighlightColor, HIGHLIGHT_COLOR),
  }
end

local function HostAt(native, position)
  local host = Cached(native.conditionHosts, position, function()
    return CreateFrame("Frame", nil, native.conditionOverlay)
  end)
  host:ClearAllPoints()
  host:SetAllPoints(native.button)
  return host
end

local function EdgesAt(native, position, host)
  return Cached(native.conditionIndicators, position, function()
    local set = {}
    for slot = 1, 4 do set[slot] = host:CreateTexture(nil, "OVERLAY", nil, 7) end
    return set
  end)
end

local function StartPulse(host, button, period)
  if not host.pulse then
    local cycle = host:CreateAnimationGroup()
    cycle:SetLooping("REPEAT")
    host.fadeOut, host.fadeIn = cycle:CreateAnimation("Alpha"), cycle:CreateAnimation("Alpha")
    host.fadeOut:SetOrder(1)
    host.fadeOut:SetFromAlpha(1)
    host.fadeOut:SetToAlpha(0.2)
    host.fadeIn:SetOrder(2)
    host.fadeIn:SetFromAlpha(0.2)
    host.fadeIn:SetToAlpha(1)
    host.pulse = cycle
  end
  host.fadeOut:SetDuration(period / 2)
  host.fadeIn:SetDuration(period / 2)
  if not host.pulseOwner and button.AddAuraShownAnimation then
    button:AddAuraShownAnimation(host.pulse)
    host.pulseOwner = button
  end
  host.pulse:Play()
end

local function PaintEdge(edge, look)
  local color = look.color
  edge:SetTexture(look.texture)
  edge:SetVertexColor(color[1], color[2], color[3], 1)
  edge:SetAlpha(color[4])
  edge:SetDesaturated(look.glow)
  edge:SetBlendMode(look.glow and "ADD" or "BLEND")
end

local function PlaceEdge(edge, button, look, index)
  if look.sides then
    local first, second, setSize = unpack(BORDER_SIDES[index])
    edge:SetPoint(first, button, first)
    edge:SetPoint(second, button, second)
    edge[setSize](edge, look.size)
  else
    edge:SetPoint("TOPLEFT", button, "TOPLEFT", -look.inset, look.inset)
    edge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", look.inset, -look.inset)
  end
end

local function DispelOptions(plan, look, equal)
  local options = {
    showWhenHelpful = true, showWhenHarmful = true, showWithoutDispelType = true,
    style = Enum.CustomAuraButtonDispelTypeTextureStyle.CustomAsset,
    customDispelAssetMap = {}, customDispelColorMap = {},
  }
  local rule = plan.variable.indicator
  local includes = rule.configure and rule.configure(options, plan.check, equal)
  local color = look.color
  for _, key in ipairs(DISPEL_KEYS) do
    if not includes or includes(key) then
      options.customDispelAssetMap[key] = { asset = look.texture }
      options.customDispelColorMap[key] = CreateColor(color[1], color[2], color[3], 1)
    end
  end
  return options
end

-- How an edge joins the button, per mode: preview only records it, otherwise the native button
-- owns it (pandemic region for the pandemic variable, dispel texture for the others).
local ATTACHMENTS = {
  preview = function(native, plan, _, edge, equal)
    table.insert(native.conditionPreview,
      { texture = edge, kind = plan.name, value = plan.check.value, equal = equal })
  end,
  pandemic = function(native, _, _, edge)
    native.button:AddPandemicRegion(edge)
  end,
  dispel = function(native, plan, look, edge, equal)
    native.button:AddDispelTypeTexture(edge, DispelOptions(plan, look, equal))
    table.insert(native.conditionDispelTextures, edge)
  end,
}

local function AttachEdge(native, plan, look, edge, equal)
  local button = native.button
  local mode
  if native.preview then
    mode = "preview"
  elseif plan.name == "faAuraPandemic" and button.AddPandemicRegion then
    mode = "pandemic"
  elseif type(button.AddDispelTypeTexture) == "function" then
    mode = "dispel"
  end
  if mode then ATTACHMENTS[mode](native, plan, look, edge, equal) end
end

local function DrawIndicator(native, data, position, plan)
  local look = ResolveLook(plan.settings, data)
  local host = HostAt(native, position)
  local edges = EdgesAt(native, position, host)
  if look.pulse then StartPulse(host, native.button, look.period) end
  local equal = plan.check.op == "=="
  for index, edge in ipairs(edges) do
    edge:ClearAllPoints()
    edge:Hide()
    if look.sides or index == 1 then
      PaintEdge(edge, look)
      PlaceEdge(edge, native.button, look, index)
      AttachEdge(native, plan, look, edge, equal)
    end
  end
end

function AuraDisplay.StyleNativeConditionIndicators(nativeDisplay, auraData)
  ResetIndicators(nativeDisplay, auraData)
  PlaceOverlay(nativeDisplay)
  for position, condition in ipairs(type(auraData.conditions) == "table" and auraData.conditions or {}) do
    local plan = IndicatorPlan(nativeDisplay, auraData, condition)
    if plan then DrawIndicator(nativeDisplay, auraData, position, plan) end
  end
  if nativeDisplay.preview then AuraDisplay.UpdateConditionPreview(nativeDisplay, auraData, AuraDisplay.PREVIEW_SAMPLE_DURATION) end
end

function AuraDisplay.UpdateConditionPreview(nativeDisplay, auraData, remainingTime)
  local entries = nativeDisplay.conditionPreview
  if not entries then return end
  local source = AuraDisplay.GetTrigger(auraData)
  local isBuff = not (source and source.debuffType == "HARMFUL")
  for _, entry in ipairs(entries) do
    local variable = VARIABLES[entry.kind]
    local rule = variable and variable.preview
    entry.texture:SetShown(rule ~= nil and rule(entry, remainingTime, isBuff) == true)
  end
end

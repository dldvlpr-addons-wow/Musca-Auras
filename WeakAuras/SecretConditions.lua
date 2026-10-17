-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Conditions whose test reads a secret value cannot be evaluated by Lua.
-- For those, the generated condition function also computes each property
-- through engine side selectors (boolean colour pick, duration curves), so the
-- region receives a secret value it can still display.

local ExecEnv = Private.ExecEnv

---------------------------------------------------------------------------
-- Selectors called by the generated code
---------------------------------------------------------------------------

function ExecEnv.SetSecretAuraConditionProperty(region, property, ...)
  return Private.BlizzardAuraDisplay.SetConditionProperty(region, property, ...)
end

function ExecEnv.SecretPick(active, valueIfTrue, valueIfFalse)
  if active then
    return valueIfTrue
  end
  return valueIfFalse
end

local Pick = ExecEnv.SecretPick

-- `readableActive` is the ordinary test result, already inverted by the caller.
function ExecEnv.SecretBoolSelect(raw, inverted, readableActive, valueIfTrue, valueIfFalse)
  if not ExecEnv.IsSecret(raw) then
    return Pick(readableActive, valueIfTrue, valueIfFalse)
  end
  if inverted then
    valueIfTrue, valueIfFalse = valueIfFalse, valueIfTrue
  end
  return C_CurveUtil.EvaluateColorValueFromBoolean(raw, valueIfTrue, valueIfFalse)
end

function ExecEnv.SecretValueSelect(selector, triggerState, inverted, readableActive, valueIfTrue, valueIfFalse)
  local selected
  if inverted then
    selected = selector(triggerState, valueIfFalse, valueIfTrue)
  else
    selected = selector(triggerState, valueIfTrue, valueIfFalse)
  end
  if ExecEnv.IsSecret(selected) or selected ~= nil then
    return selected
  end
  return Pick(readableActive, valueIfTrue, valueIfFalse)
end

local timerCurves = {}

-- Step curve over the remaining time. "Greater" tests switch to valueIfTrue
-- at the threshold; "less" tests hold valueIfTrue below it, except for a
-- finished timer, which reads as not matching.
local function GetTimerCurve(op, threshold, valueIfTrue, valueIfFalse)
  local key = ("%s|%s|%s|%s"):format(op, threshold, tostring(valueIfTrue), tostring(valueIfFalse))
  local curve = timerCurves[key]
  if not curve then
    curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, valueIfFalse)
    if op == ">" or op == ">=" then
      curve:AddPoint(threshold, valueIfTrue)
    else
      curve:AddPoint(math.min(0.001, threshold / 2), valueIfTrue)
      curve:AddPoint(threshold, valueIfFalse)
    end
    timerCurves[key] = curve
  end
  return curve
end

function ExecEnv.SecretTimerSelect(triggerState, op, threshold, readableActive, valueIfTrue, valueIfFalse)
  local duration = triggerState and triggerState.durationObject
  if threshold > 0 and Private.IsDurationObject(duration) and duration:HasSecretValues()
     and not ExecEnv.IsSecret(valueIfTrue, valueIfFalse) then
    return duration:EvaluateRemainingDuration(GetTimerCurve(op, threshold, valueIfTrue, valueIfFalse))
  end
  return Pick(readableActive, valueIfTrue, valueIfFalse)
end

local mirroredOperators = { ["<"] = ">", ["<="] = ">=", [">"] = "<", [">="] = "<=" }

local function PercentThreshold(triggerState, scale, op, threshold)
  if scale == "percent" then
    return op, threshold, 1e-5
  end
  local total = triggerState.secretTotal
  if ExecEnv.IsSecret(total) or type(total) ~= "number" or total <= 0 then
    return nil
  end
  if scale == "deficit" then
    return mirroredOperators[op], (total - threshold) / total * 100, 0.5 / total
  end
  return op, threshold / total * 100, 0.5 / total
end

function ExecEnv.SecretPercentSelect(triggerState, kind, scale, op, threshold, readableActive, valueIfTrue, valueIfFalse)
  if not (triggerState and ExecEnv.IsSecret(triggerState.secretValue, triggerState.secretTotal))
     or ExecEnv.IsSecret(valueIfTrue, valueIfFalse) then
    return Pick(readableActive, valueIfTrue, valueIfFalse)
  end
  local percentOp, percent, epsilon = PercentThreshold(triggerState, scale, op, threshold)
  if not percentOp then
    return Pick(readableActive, valueIfTrue, valueIfFalse)
  end
  local greater = percentOp == ">" or percentOp == ">="
  local point = percent / 100
  if percentOp == ">" or percentOp == "<=" then
    point = point + epsilon
  end
  if point <= 0 then
    return greater and valueIfTrue or valueIfFalse
  end
  local below, above = valueIfTrue, valueIfFalse
  if greater then
    below, above = valueIfFalse, valueIfTrue
  end
  local selected = ExecEnv.UnitPercentStep(kind, triggerState.unit, triggerState.powertype, below, point, above)
  if selected == nil then
    return Pick(readableActive, valueIfTrue, valueIfFalse)
  end
  return selected
end

-- A secret timer result changes with time, not with events: while one is
-- applied, the conditions are re-run by the native refresh loop.
local function RefreshSecretConditions(region)
  if region.toShow and region.states then
    Private.RunConditions(region, region.uid, false)
  else
    Private.SetNativeRefresh(region, "secretConditions", nil)
  end
end

function ExecEnv.SetSecretConditionRefresh(region, enabled)
  Private.SetNativeRefresh(region, "secretConditions", enabled and RefreshSecretConditions or nil)
end

---------------------------------------------------------------------------
-- Code generation
---------------------------------------------------------------------------

local timerOperators = { ["<"] = true, ["<="] = true, [">"] = true, [">="] = true }

local function IsCombination(check)
  return check.variable == "AND" or check.variable == "OR"
end

-- "select", "bool", "timer" or "percent" for a test the engine can answer secretly.
local function SecretLeafKind(check, allConditionsTemplate)
  if not (check.trigger and check.variable and check.value ~= nil) then
    return nil
  end
  local templates = allConditionsTemplate[check.trigger]
  local template = templates and templates[check.variable]
  if not template then
    return nil
  end
  if template.type == "bool" then
    if template.secretSelect then
      return "select"
    elseif template.secretTest then
      return "bool"
    end
  elseif template.type == "timer" and check.variable == "expirationTime"
         and timerOperators[check.op] and tonumber(check.value) then
    return "timer"
  elseif template.type == "number" and template.secretPercent
         and timerOperators[check.op] and tonumber(check.value) then
    return "percent"
  end
end

-- Returns whether the check tree holds a secret leaf, and whether one of them
-- changes over time (timer or select).
local function ScanCheck(check, allConditionsTemplate)
  if type(check) ~= "table" then
    return false, false
  end
  if IsCombination(check) then
    local hasSecret, changesOverTime = false, false
    for _, subCheck in ipairs(check.checks or {}) do
      local subSecret, subTime = ScanCheck(subCheck, allConditionsTemplate)
      hasSecret = hasSecret or subSecret
      changesOverTime = changesOverTime or subTime
    end
    return hasSecret, changesOverTime
  end
  local kind = SecretLeafKind(check, allConditionsTemplate)
  return kind ~= nil, kind == "timer" or kind == "select"
end

function Private.SetSecretSubRegionVisible(subRegion, visible, value)
  if not visible then
    subRegion:SetVisible(true)
  end
  subRegion.secretVisibility = true
  subRegion:SetAlpha(value)
end

function Private.ClearSecretSubRegionVisible(subRegion)
  if subRegion.secretVisibility then
    subRegion.secretVisibility = nil
    subRegion:SetAlpha(1)
  end
end

local function IsSecretCapable(definition)
  if not (definition and definition.secretCapable and definition.setter) then
    return false
  end
  if definition.secretLayers then
    return true
  elseif definition.type == "bool" then
    return definition.secretSetter ~= nil
  end
  return definition.type == "number" or definition.type == "color"
end

local function ChannelCount(definition)
  return definition.type == "color" and 4 or 1
end

local function Constant(definition, value, channel)
  if definition.type == "color" then
    local component = type(value) == "table" and value[channel]
    return tostring(tonumber(component) or 1)
  elseif definition.type == "bool" then
    return value and "1" or "0"
  end
  return tostring(tonumber(value) or 0)
end

local function LastChange(condition, property)
  local found
  for _, change in ipairs(condition.changes or {}) do
    if change.property == property then
      found = change
    end
  end
  return found
end

local function RegisterHelper(uid, listName, helper)
  local helpers = ExecEnv.conditionHelpers
  helpers[uid] = helpers[uid] or {}
  local list = helpers[uid][listName] or {}
  helpers[uid][listName] = list
  list[#list + 1] = helper
  return ("Private.ExecEnv.conditionHelpers[%q].%s[%d]"):format(uid, listName, #list)
end

local SelectExpression

-- Tests without a curve come first so a timer or percent curve sits innermost.
local function CombinationExpression(generator, check, valueIfTrue, valueIfFalse)
  local ordered, timers = {}, {}
  for _, subCheck in ipairs(check.checks or {}) do
    local kind = SecretLeafKind(subCheck, generator.template)
    if kind == "timer" or kind == "percent" then
      timers[#timers + 1] = subCheck
    else
      ordered[#ordered + 1] = subCheck
    end
  end
  for _, timer in ipairs(timers) do
    ordered[#ordered + 1] = timer
  end

  local built
  for index = #ordered, 1, -1 do
    local expression
    if check.variable == "AND" then
      expression = SelectExpression(generator, ordered[index], built or valueIfTrue, valueIfFalse)
    else
      expression = SelectExpression(generator, ordered[index], valueIfTrue, built or valueIfFalse)
    end
    built = expression or built
  end
  return built
end

local function LeafExpression(generator, check, valueIfTrue, valueIfFalse)
  local kind = SecretLeafKind(check, generator.template)
  local test = generator.createTest(generator.data, check, generator.template, {})
  if not kind then
    if test == nil then
      return nil
    end
    return ("Private.ExecEnv.SecretPick((%s), %s, %s)"):format(test, valueIfTrue, valueIfFalse)
  end

  local readable = test or "false"
  local triggerState = ("state[%d]"):format(check.trigger)
  local template = generator.template[check.trigger][check.variable]
  local valueIsFalse = check.value == 0
  if kind == "bool" then
    local inverted = (template.secretInverted and true or false) ~= valueIsFalse
    local secretTest = RegisterHelper(generator.data.uid, "secretTests", template.secretTest)
    return ("Private.ExecEnv.SecretBoolSelect(%s(%s), %s, (%s), %s, %s)")
      :format(secretTest, triggerState, tostring(inverted), readable, valueIfTrue, valueIfFalse)
  elseif kind == "select" then
    local selector = RegisterHelper(generator.data.uid, "secretSelects", template.secretSelect)
    return ("Private.ExecEnv.SecretValueSelect(%s, %s, %s, (%s), %s, %s)")
      :format(selector, triggerState, tostring(valueIsFalse), readable, valueIfTrue, valueIfFalse)
  elseif kind == "percent" then
    local secretPercent = template.secretPercent
    return ("Private.ExecEnv.SecretPercentSelect(%s, %q, %q, %q, %s, (%s), %s, %s)")
      :format(triggerState, secretPercent.kind, secretPercent.scale or "percent", check.op,
        tostring(tonumber(check.value)), readable, valueIfTrue, valueIfFalse)
  end
  return ("Private.ExecEnv.SecretTimerSelect(%s, %q, %s, (%s), %s, %s)")
    :format(triggerState, check.op, tostring(tonumber(check.value)), readable, valueIfTrue, valueIfFalse)
end

-- Lua expression worth valueIfTrue when the check matches, valueIfFalse
-- otherwise, or nil when the check has nothing to express.
function SelectExpression(generator, check, valueIfTrue, valueIfFalse)
  if type(check) ~= "table" then
    return nil
  end
  if IsCombination(check) then
    return CombinationExpression(generator, check, valueIfTrue, valueIfFalse)
  end
  if not (check.trigger and check.variable) then
    return nil
  end
  return LeafExpression(generator, check, valueIfTrue, valueIfFalse)
end

local function ValueList(channels, readableBool)
  if readableBool then
    return "v1 == 1"
  end
  local names = {}
  for channel = 1, channels do
    names[channel] = "v" .. channel
  end
  return table.concat(names, ", ")
end

local function EmitPropertyBlock(ret, generator, property, changesOverTime)
  local definition = generator.properties[property]
  local channels = ChannelCount(definition)
  local base = generator.getBaseProperty(generator.data, property)

  ret[#ret + 1] = "    do\n"
  for channel = 1, channels do
    ret[#ret + 1] = ("      local v%d = %s\n"):format(channel, Constant(definition, base, channel))
  end

  for index, condition in ipairs(generator.data.conditions) do
    local change = LastChange(condition, property)
    if change and generator.secretConditions[index] then
      for channel = 1, channels do
        local expression = SelectExpression(generator, condition.check,
          Constant(definition, change.value, channel), "v" .. channel)
        if expression then
          ret[#ret + 1] = ("      v%d = %s\n"):format(channel, expression)
        end
      end
    elseif change then
      ret[#ret + 1] = ("      if newActiveConditions[%d] then\n"):format(index)
      for channel = 1, channels do
        ret[#ret + 1] = ("        v%d = %s\n"):format(channel, Constant(definition, change.value, channel))
      end
      ret[#ret + 1] = "      end\n"
    end
  end

  local subIndex = generator.parseProperty(property)
  local target = subIndex and ("region.subRegions[%d]:"):format(subIndex) or "region:"
  local arg1 = ""
  if type(definition.arg1) == "number" then
    arg1 = tostring(definition.arg1) .. ", "
  elseif type(definition.arg1) == "string" then
    arg1 = "'" .. definition.arg1 .. "', "
  end
  local isBool = definition.type == "bool"
  local key = ("region.secretConditionProperties[%q]"):format(property)

  ret[#ret + 1] = ("      if Private.ExecEnv.IsSecret(%s) then\n"):format(ValueList(channels))
  ret[#ret + 1] = "        region.secretConditionProperties = region.secretConditionProperties or {}\n"
  ret[#ret + 1] = ("        %s = true\n"):format(key)
  if changesOverTime then
    ret[#ret + 1] = "        secretTimerApplied = true\n"
  end
  ret[#ret + 1] = ("        %s%s(%s%s)\n"):format(target, definition.secretSetter or definition.setter,
    arg1, ValueList(channels))
  ret[#ret + 1] = ("      elseif region.secretConditionProperties and %s then\n"):format(key)
  ret[#ret + 1] = ("        %s = nil\n"):format(key)
  if definition.secretRestore then
    ret[#ret + 1] = ("        %s%s()\n"):format(target, definition.secretRestore)
  end
  ret[#ret + 1] = ("        %s%s(%s%s)\n"):format(target, definition.setter, arg1, ValueList(channels, isBool))
  ret[#ret + 1] = "      end\n"
  ret[#ret + 1] = "    end\n"
end

local function EmitLayerBlock(ret, generator, property, changesOverTime)
  local definition = generator.properties[property]
  local owners = { 0 }
  for index, condition in ipairs(generator.data.conditions) do
    local change = LastChange(condition, property)
    if change and type(change.value) == "string" then
      owners[#owners + 1] = index
    end
  end

  ret[#ret + 1] = "    do\n"
  local names = {}
  for layer = 1, #owners do
    for index = layer, #owners do
      local name = "a" .. (#names + 1)
      names[#names + 1] = name
      local owner = owners[index]
      local valueIfTrue, valueIfFalse = "0", "1"
      if index == layer then
        valueIfTrue, valueIfFalse = "1", "0"
      end
      if owner == 0 then
        ret[#ret + 1] = ("      local %s = 1\n"):format(name)
      elseif generator.secretConditions[owner] then
        local expression = SelectExpression(generator, generator.data.conditions[owner].check,
          valueIfTrue, valueIfFalse)
        ret[#ret + 1] = ("      local %s = %s\n"):format(name, expression or valueIfFalse)
      else
        ret[#ret + 1] = ("      local %s = newActiveConditions[%d] and %s or %s\n")
          :format(name, owner, valueIfTrue, valueIfFalse)
      end
    end
  end

  local values = table.concat(names, ", ")
  local key = ("region.secretConditionProperties[%q]"):format(property)
  ret[#ret + 1] = ("      if Private.ExecEnv.IsSecret(%s) then\n"):format(values)
  ret[#ret + 1] = "        region.secretConditionProperties = region.secretConditionProperties or {}\n"
  ret[#ret + 1] = ("        %s = true\n"):format(key)
  if changesOverTime then
    ret[#ret + 1] = "        secretTimerApplied = true\n"
  end
  ret[#ret + 1] = ("        region:%s(%s)\n"):format(definition.secretLayers, values)
  ret[#ret + 1] = ("      elseif region.secretConditionProperties and %s then\n"):format(key)
  ret[#ret + 1] = ("        %s = nil\n"):format(key)
  ret[#ret + 1] = ("        region:%s()\n"):format(definition.secretRestore)
  ret[#ret + 1] = "      end\n"
  ret[#ret + 1] = "    end\n"
end

function Private.CreateSecretConditionCode(ret, data, properties, allConditionsTemplate,
                                           createTestForCondition, parseProperty, getBaseProperty)
  local conditions = data.conditions or {}

  -- Linked conditions behave as an if/elseif chain, which the secret path
  -- cannot reproduce: they stay on the ordinary path only.
  local secretConditions, secretProperties = {}, {}
  for index, condition in ipairs(conditions) do
    local following = conditions[index + 1]
    if condition.changes and not condition.linked and not (following and following.linked) then
      local hasSecret, changesOverTime = ScanCheck(condition.check, allConditionsTemplate)
      if hasSecret then
        for _, change in ipairs(condition.changes) do
          if IsSecretCapable(properties[change.property]) then
            secretConditions[index] = true
            secretProperties[change.property] = secretProperties[change.property] or changesOverTime
          end
        end
      end
    end
  end
  if next(secretProperties) == nil then
    return
  end

  local generator = {
    data = data,
    properties = properties,
    template = allConditionsTemplate,
    createTest = createTestForCondition,
    parseProperty = parseProperty,
    getBaseProperty = getBaseProperty,
    secretConditions = secretConditions,
  }
  local names = {}
  for property in pairs(secretProperties) do
    names[#names + 1] = property
  end
  table.sort(names)

  ret[#ret + 1] = "  if not hideRegion then\n"
  ret[#ret + 1] = "    local secretTimerApplied = false\n"
  for _, property in ipairs(names) do
    if properties[property].secretLayers then
      EmitLayerBlock(ret, generator, property, secretProperties[property])
    else
      EmitPropertyBlock(ret, generator, property, secretProperties[property])
    end
  end
  ret[#ret + 1] = "    Private.ExecEnv.SetSecretConditionRefresh(region, secretTimerApplied)\n"
  ret[#ret + 1] = "  end\n"
end

-- Condition code that stays valid with secret values: Private.ExecEnv Secret* selectors and
-- Private.CreateSecretConditionCode. Only Conditions.lua uses it.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local CreateTestForCondition, ParseProperty, GetBaseProperty

function Private.ExecEnv.SetSecretAuraConditionProperty(region, property, ...)
  Private.BlizzardAuraDisplay.SetConditionProperty(region, property, ...)
end

function Private.ExecEnv.SecretPick(active, valueIfTrue, valueIfFalse)
  if active then
    return valueIfTrue
  end
  return valueIfFalse
end

function Private.ExecEnv.SecretBoolSelect(raw, inverted, readableActive, valueIfTrue, valueIfFalse)
  if Private.IsSecret(raw) then
    if inverted then
      return C_CurveUtil.EvaluateColorValueFromBoolean(raw, valueIfFalse, valueIfTrue)
    end
    return C_CurveUtil.EvaluateColorValueFromBoolean(raw, valueIfTrue, valueIfFalse)
  end
  if readableActive then
    return valueIfTrue
  end
  return valueIfFalse
end

-- The template selector returns nil when it cannot answer; the readable check decides then.
function Private.ExecEnv.SecretValueSelect(selector, triggerState, inverted, readableActive, valueIfTrue, valueIfFalse)
  local value
  if inverted then
    value = selector(triggerState, valueIfFalse, valueIfTrue)
  else
    value = selector(triggerState, valueIfTrue, valueIfFalse)
  end
  if Private.IsSecret(value) or value ~= nil then
    return value
  end
  if readableActive then
    return valueIfTrue
  end
  return valueIfFalse
end

local remainingCurves = {}
function Private.ExecEnv.SecretTimerSelect(triggerState, op, threshold, readableActive, valueIfTrue, valueIfFalse)
  local duration = triggerState and triggerState.durationObject
  if threshold > 0 and Private.IsDurationObject(duration) and duration:HasSecretValues()
     and not Private.IsSecret(valueIfTrue, valueIfFalse) then
    local key = op .. "|" .. threshold .. "|" .. valueIfTrue .. "|" .. valueIfFalse
    local curve = remainingCurves[key]
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
      remainingCurves[key] = curve
    end
    return duration:EvaluateRemainingDuration(curve)
  end
  if readableActive then
    return valueIfTrue
  end
  return valueIfFalse
end

local function RefreshSecretConditions(region)
  if region.toShow and region.states then
    Private.RunConditions(region, region.uid, false)
  else
    Private.SetNativeRefresh(region, "secretConditions", nil)
  end
end

function Private.ExecEnv.SetSecretConditionRefresh(region, enabled)
  Private.SetNativeRefresh(region, "secretConditions", enabled and RefreshSecretConditions or nil)
end

local secretTimerOperators = { ["<"] = true, ["<="] = true, [">"] = true, [">="] = true }

local function SecretLeafKind(input, allConditionsTemplate)
  local template = allConditionsTemplate[input.trigger] and allConditionsTemplate[input.trigger][input.variable]
  if not template or input.value == nil then
    return nil
  end
  if template.type == "bool" and template.secretSelect then
    return "select", template
  end
  if template.type == "bool" and template.secretTest then
    return "bool", template
  end
  if template.type == "timer" and input.variable == "expirationTime" and secretTimerOperators[input.op]
     and tonumber(input.value) then
    return "timer", template
  end
end

local function FindSecretLeaves(input, allConditionsTemplate, found)
  if not input then
    return found
  end
  if input.variable == "AND" or input.variable == "OR" then
    for _, subcheck in ipairs(input.checks or {}) do
      FindSecretLeaves(subcheck, allConditionsTemplate, found)
    end
  elseif input.trigger and input.variable then
    local kind = SecretLeafKind(input, allConditionsTemplate)
    if kind then
      found[kind] = true
    end
  end
  return found
end

local function SecretSelectExpression(data, input, allConditionsTemplate, valueIfTrue, valueIfFalse)
  if input.variable == "AND" or input.variable == "OR" then
    local isAnd = input.variable == "AND"
    local expression
    local checks = {}
    local timerChecks = {}
    for _, subcheck in ipairs(input.checks or {}) do
      if subcheck.trigger and subcheck.variable and SecretLeafKind(subcheck, allConditionsTemplate) == "timer" then
        tinsert(timerChecks, subcheck)
      else
        tinsert(checks, subcheck)
      end
    end
    for _, subcheck in ipairs(timerChecks) do
      tinsert(checks, subcheck)
    end
    for index = #checks, 1, -1 do
      local subexpression
      if isAnd then
        subexpression = SecretSelectExpression(data, checks[index], allConditionsTemplate,
                                               expression or valueIfTrue, valueIfFalse)
      else
        subexpression = SecretSelectExpression(data, checks[index], allConditionsTemplate,
                                               valueIfTrue, expression or valueIfFalse)
      end
      expression = subexpression or expression
    end
    return expression
  end
  if not (input.trigger and input.variable) then
    return nil
  end

  local check = CreateTestForCondition(data, input, allConditionsTemplate, {})
  local kind, template = SecretLeafKind(input, allConditionsTemplate)
  if kind == "bool" then
    local helpers = Private.ExecEnv.conditionHelpers[data.uid] or {}
    Private.ExecEnv.conditionHelpers[data.uid] = helpers
    helpers.secretTests = helpers.secretTests or {}
    tinsert(helpers.secretTests, template.secretTest)
    local inverted = template.secretInverted and true or false
    if input.value == 0 then
      inverted = not inverted
    end
    return string.format("Private.ExecEnv.SecretBoolSelect(Private.ExecEnv.conditionHelpers[%q].secretTests[%d](state[%d]), %s, (%s), %s, %s)",
                         data.uid, #helpers.secretTests, input.trigger, tostring(inverted), check or "false",
                         valueIfTrue, valueIfFalse)
  elseif kind == "select" then
    local helpers = Private.ExecEnv.conditionHelpers[data.uid] or {}
    Private.ExecEnv.conditionHelpers[data.uid] = helpers
    helpers.secretSelects = helpers.secretSelects or {}
    tinsert(helpers.secretSelects, template.secretSelect)
    return string.format("Private.ExecEnv.SecretValueSelect(Private.ExecEnv.conditionHelpers[%q].secretSelects[%d], state[%d], %s, (%s), %s, %s)",
                         data.uid, #helpers.secretSelects, input.trigger, tostring(input.value == 0), check or "false",
                         valueIfTrue, valueIfFalse)
  elseif kind == "timer" then
    return string.format("Private.ExecEnv.SecretTimerSelect(state[%d], %q, %s, (%s), %s, %s)",
                         input.trigger, input.op, tonumber(input.value), check or "false", valueIfTrue, valueIfFalse)
  end
  if not check then
    return nil
  end
  return string.format("Private.ExecEnv.SecretPick((%s), %s, %s)", check, valueIfTrue, valueIfFalse)
end

local function SecretCapableProperty(propertyData)
  return propertyData and propertyData.secretCapable and propertyData.setter
         and (propertyData.type == "number" or propertyData.type == "color"
              or (propertyData.type == "bool" and propertyData.secretSetter))
end

local function SecretConstant(propertyData, value, channel)
  if propertyData.type == "color" then
    return tostring(type(value) == "table" and tonumber(value[channel]) or 1)
  elseif propertyData.type == "bool" then
    return value and "1" or "0"
  end
  return tostring(tonumber(value) or 0)
end

function Private.CreateSecretConditionCode(ret, data, properties, allConditionsTemplate, createTestForCondition, parseProperty, getBaseProperty)
  CreateTestForCondition, ParseProperty, GetBaseProperty = createTestForCondition, parseProperty, getBaseProperty
  local secretConditions, secretProperties = {}, {}
  for conditionNumber, condition in ipairs(data.conditions) do
    local nextCondition = data.conditions[conditionNumber + 1]
    if condition.changes and not condition.linked and not (nextCondition and nextCondition.linked) then
      local leaves = FindSecretLeaves(condition.check, allConditionsTemplate, {})
      if next(leaves) then
        for _, change in ipairs(condition.changes) do
          if change.property and SecretCapableProperty(properties[change.property]) then
            secretConditions[conditionNumber] = true
            secretProperties[change.property] = secretProperties[change.property] or leaves.timer or leaves.select or false
          end
        end
      end
    end
  end
  if not next(secretProperties) then
    return
  end

  table.insert(ret, "  if not hideRegion then\n")
  table.insert(ret, "    local secretTimerApplied = false\n")
  for property, usesTimer in pairs(secretProperties) do
    local propertyData = properties[property]
    local channels = propertyData.type == "color" and 4 or 1
    local values = {}
    for channel = 1, channels do
      values[channel] = "v" .. channel
    end
    local valueList = table.concat(values, ", ")

    table.insert(ret, "    do\n")
    local base = GetBaseProperty(data, property)
    for channel = 1, channels do
      table.insert(ret, string.format("      local v%d = %s\n", channel, SecretConstant(propertyData, base, channel)))
    end
    for conditionNumber, condition in ipairs(data.conditions) do
      local found, changeValue = false, nil
      for _, change in ipairs(condition.changes or {}) do
        if change.property == property then
          found, changeValue = true, change.value
        end
      end
      if found then
        if secretConditions[conditionNumber] then
          for channel = 1, channels do
            local expression = SecretSelectExpression(data, condition.check, allConditionsTemplate,
                                                      SecretConstant(propertyData, changeValue, channel), "v" .. channel)
            if expression then
              table.insert(ret, string.format("      v%d = %s\n", channel, expression))
            end
          end
        else
          table.insert(ret, string.format("      if newActiveConditions[%d] then\n", conditionNumber))
          for channel = 1, channels do
            table.insert(ret, string.format("        v%d = %s\n", channel, SecretConstant(propertyData, changeValue, channel)))
          end
          table.insert(ret, "      end\n")
        end
      end
    end

    local target = "region:"
    local subIndex = ParseProperty(property)
    if subIndex then
      target = "region.subRegions[" .. subIndex .. "]:"
    end
    local arg1 = ""
    if propertyData.arg1 then
      arg1 = type(propertyData.arg1) == "number" and (tostring(propertyData.arg1) .. ", ")
             or ("'" .. propertyData.arg1 .. "', ")
    end
    local secretCall, readableCall
    if propertyData.type == "bool" then
      secretCall = target .. propertyData.secretSetter .. "(" .. arg1 .. "v1)"
      readableCall = target .. propertyData.setter .. "(" .. arg1 .. "v1 == 1)"
    else
      secretCall = target .. propertyData.setter .. "(" .. arg1 .. valueList .. ")"
      readableCall = secretCall
    end
    table.insert(ret, string.format("      if Private.ExecEnv.IsSecret(%s) then\n", valueList))
    table.insert(ret, "        region.secretConditionProperties = region.secretConditionProperties or {}\n")
    table.insert(ret, string.format("        region.secretConditionProperties[%q] = true\n", property))
    if usesTimer then
      table.insert(ret, "        secretTimerApplied = true\n")
    end
    table.insert(ret, "        " .. secretCall .. "\n")
    table.insert(ret, string.format("      elseif region.secretConditionProperties and region.secretConditionProperties[%q] then\n", property))
    table.insert(ret, string.format("        region.secretConditionProperties[%q] = nil\n", property))
    table.insert(ret, "        " .. readableCall .. "\n")
    table.insert(ret, "      end\n")
    table.insert(ret, "    end\n")
  end
  table.insert(ret, "    Private.ExecEnv.SetSecretConditionRefresh(region, secretTimerApplied)\n")
  table.insert(ret, "  end\n")
end

if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local canBindDurationText = C_DurationUtil ~= nil and C_DurationUtil.CreateDurationTextBinding ~= nil
  and C_StringUtil ~= nil and C_StringUtil.CreateNumericRuleFormatter ~= nil

local function GetDurationFormatter(subRegion)
  local timeFormat = subRegion.durationTimeFormat or 0
  return Private.GetDurationTextFormatter((timeFormat == 0 and subRegion.durationLegacyFloor) and 0 or 99,
    subRegion.durationThreshold or 60, subRegion.durationPrecision or 1, false, timeFormat)
end

local function BindDurationText(subRegion, durationObject)
  local binding = subRegion.durationTextBinding
  if not binding then
    subRegion.durationTextBinding = false
    binding = C_DurationUtil.CreateDurationTextBinding()
    binding:SetFontString(subRegion.text)
    subRegion.durationTextBinding = binding
  end
  local formatter = GetDurationFormatter(subRegion)
  if subRegion.boundDurationFormatter ~= formatter then
    binding:SetFormatter(formatter)
    subRegion.boundDurationFormatter = formatter
  end
  if subRegion.boundDurationObject ~= durationObject then
    binding:SetDuration(durationObject)
    binding:SetEnabled(true)
    subRegion.boundDurationObject = durationObject
  end
end

local function UnbindDurationText(subRegion)
  if subRegion.boundDurationObject then
    subRegion.durationTextBinding:SetEnabled(false)
    subRegion.boundDurationObject = nil
  end
end

local secretValuePlaceholders = {
  p = "value", value = "value", health = "value", power = "value",
  t = "total", total = "total", maxhealth = "total", maxpower = "total",
  percenthealth = "percent", percentpower = "percent",
}

local function UpdateNativeText(holder, parent, textStr, formatters)
  if textStr == "%p" and canBindDurationText and holder.durationTextBinding ~= false and parent.durationObject
     and pcall(BindDurationText, holder, parent.durationObject)
  then
    return true
  end
  UnbindDurationText(holder)
  local secretStacks = textStr == "%s" and parent.state and parent.state.secretStacks
  if type(secretStacks) == "string" then
    holder.text:SetText(secretStacks)
    return true
  end
  if textStr:find("%%[%w%.]") and not textStr:find("{", 1, true) then
    local values, unknown, anySecret = {}, false, false
    local formatString = textStr:gsub("%%%%", ""):gsub("%%([%w%.]+)", function(placeholder)
      local symbol = placeholder
      local state, value, total = parent.state, parent.secretValue, parent.secretTotal
      local triggerNum, key = placeholder:match("^(%d+)%.(%a+)$")
      if triggerNum then
        state = parent.states and parent.states[tonumber(triggerNum)]
        value, total = state and state.secretValue, state and state.secretTotal
        placeholder = key
      end
      local kind = secretValuePlaceholders[placeholder]
      if not kind then
        if not formatters then
          unknown = true
          return ""
        end
        values[#values + 1] = Private.ReplacePlaceHolders("%" .. symbol, parent, nil, false, formatters)
        return ""
      end
      if kind == "percent" then
        local percent = state and state.secretPercentText
        if type(percent) == "number" then
          anySecret = true
        else
          percent = state and state[placeholder]
        end
        if type(percent) ~= "number" then
          unknown = true
          return ""
        end
        values[#values + 1] = percent
        return ""
      end
      local secret, field, secretField = total, "total", "secretTotal"
      if kind == "value" then
        secret, field, secretField = value, "value", "secretValue"
      end
      if type(secret) == "number" then
        anySecret = true
      elseif state and state.progressType == "static" and state[secretField] == nil then
        secret = state[field]
      end
      if type(secret) ~= "number" then
        unknown = true
        return ""
      end
      values[#values + 1] = secret
      return ""
    end)
    if not unknown and anySecret then
      formatString = formatString:gsub("\\n", "\n")
      formatString = formatString:gsub("%%", "%%%%"):gsub("", "%%%%"):gsub("", "%%s"):gsub("", "%%.0f")
      holder.text:SetText(string.format(formatString, unpack(values)))
      return true
    end
  end
  return false
end
Private.UpdateNativeText = UpdateNativeText
Private.UnbindDurationText = UnbindDurationText

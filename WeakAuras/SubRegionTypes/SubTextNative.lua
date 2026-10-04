if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local canBindDurationText = C_DurationUtil ~= nil and C_DurationUtil.CreateDurationTextBinding ~= nil
  and C_StringUtil ~= nil and C_StringUtil.CreateSecondsFormatter ~= nil
local durationFormatters = {}

local function ConfigureDurationFormatter(formatter, timeFormat, threshold)
  if timeFormat == 1 or timeFormat == 2 then
    formatter:SetDesiredUnitCount(timeFormat)
    if Enum.SecondsFormatterAbbreviation then
      formatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
    end
  end
  if tonumber(threshold) then
    formatter:SetMillisecondsThreshold(tonumber(threshold))
  end
end

local function GetDurationFormatter(timeFormat, threshold)
  local key = tostring(timeFormat) .. ":" .. tostring(threshold)
  if not durationFormatters[key] then
    local formatter = C_StringUtil.CreateSecondsFormatter()
    if not pcall(ConfigureDurationFormatter, formatter, timeFormat, threshold) then
      formatter = C_StringUtil.CreateSecondsFormatter()
    end
    durationFormatters[key] = formatter
  end
  return durationFormatters[key]
end

local function BindDurationText(subRegion, durationObject)
  local binding = subRegion.durationTextBinding
  if not binding then
    subRegion.durationTextBinding = false
    binding = C_DurationUtil.CreateDurationTextBinding()
    binding:SetFontString(subRegion.text)
    subRegion.durationTextBinding = binding
  end
  local formatter = GetDurationFormatter(subRegion.durationTimeFormat, subRegion.durationThreshold)
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

local function UpdateNativeText(holder, parent, textStr)
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
  if type(parent.secretValue) == "number" and textStr:find("%%[%w%.]") and not textStr:find("{", 1, true) then
    local values, unknown = {}, false
    local formatString = textStr:gsub("%%%%", ""):gsub("%%([%w%.]+)", function(placeholder)
      local kind = secretValuePlaceholders[placeholder]
      if not kind then
        unknown = true
        return ""
      end
      if kind == "percent" then
        local percent = parent.state and parent.state.secretPercentText
        if type(percent) ~= "number" then
          unknown = true
          return ""
        end
        values[#values + 1] = percent
        return ""
      end
      values[#values + 1] = kind == "value" and parent.secretValue or parent.secretTotal
      return ""
    end)
    if not unknown then
      formatString = formatString:gsub("%%", "%%%%"):gsub("", "%%%%"):gsub("", "%%s"):gsub("", "%%.0f")
      holder.text:SetText(string.format(formatString, unpack(values)))
      return true
    end
  end
  return false
end
Private.UpdateNativeText = UpdateNativeText
Private.UnbindDurationText = UnbindDurationText

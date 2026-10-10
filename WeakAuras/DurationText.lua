if not WeakAuras.IsLibsOK() then return end

local _, Private = ...

local tostring = tostring
local max = math.max

local epsilon = 1e-6
local formatterCache = {}

function Private.ShouldHideDurationText(state)
  if not state or state.cdmHideGCDText ~= true or state.cdmTextPreview then
    return false
  end
  if state.cdmGCDOnly == true then
    return true
  end
  return state.cdmTextDurationRequired and not state.cdmTextDurationObject
end

function Private.GetTextDuration(state)
  return state.cdmTextDurationObject or state.durationObject
end

function Private.UsesDurationText(state)
  if not state then
    return false
  end
  if state.cdmHideGCDText and not state.cdmTextPreview then
    return Private.IsDurationObject(state.cdmTextDurationObject)
  end
  return state.progressType == "durationObject" and Private.IsDurationObject(state.durationObject) and true or false
end

local function LongStyleBreakpoints(breakpoints, minuteStart, rounding, timeFormat)
  local hourStart = max(3600, minuteStart)
  if timeFormat == 1 then
    breakpoints[#breakpoints + 1] = {
      threshold = minuteStart, step = 1, rounding = rounding, format = "%dm",
      components = { { div = 60 } },
    }
    breakpoints[#breakpoints + 1] = {
      threshold = hourStart, step = 1, rounding = rounding, format = "%dh",
      components = { { div = 3600 } },
    }
  elseif timeFormat == 2 then
    breakpoints[#breakpoints + 1] = {
      threshold = minuteStart, step = 1, rounding = rounding, format = "%dm %ds",
      components = { { div = 60 }, { mod = 60 } },
    }
    breakpoints[#breakpoints + 1] = {
      threshold = hourStart, step = 1, rounding = rounding, format = "%dh %dm",
      components = { { div = 3600 }, { div = 60, mod = 60 } },
    }
  else
    breakpoints[#breakpoints + 1] = {
      threshold = minuteStart, step = 1, rounding = rounding, format = "%d:%02d",
      components = { { div = 60 }, { mod = 60 } },
    }
  end
end

local function BuildBreakpoints(format, threshold, precision, secondsOnly, timeFormat)
  local rounding = format == 99 and Enum.NumericRuleFormatRounding.Up or Enum.NumericRuleFormatRounding.Down
  local breakpoints = { { threshold = 0, format = "" } }
  if threshold > 0 then
    breakpoints[#breakpoints + 1] = { threshold = epsilon, format = "%." .. precision .. "f" }
  end
  local minuteStart = max(60, threshold)
  local secondsStart = threshold > 0 and threshold or epsilon
  if secondsOnly or secondsStart < minuteStart then
    local suffix = (not secondsOnly and (timeFormat == 1 or timeFormat == 2)) and "s" or ""
    breakpoints[#breakpoints + 1] = { threshold = secondsStart, step = 1, rounding = rounding, format = "%d" .. suffix }
  end
  if not secondsOnly then
    LongStyleBreakpoints(breakpoints, minuteStart, rounding, timeFormat)
  end
  return breakpoints
end

function Private.GetDurationTextFormatter(format, threshold, precision, secondsOnly, timeFormat)
  secondsOnly = secondsOnly == true
  local key = tostring(format) .. "|" .. tostring(threshold) .. "|" .. tostring(precision) .. "|"
    .. tostring(secondsOnly) .. "|" .. tostring(timeFormat)
  local formatter = formatterCache[key]
  if not formatter then
    formatter = C_StringUtil.CreateNumericRuleFormatter()
    formatter:SetBreakpoints(BuildBreakpoints(format, threshold, precision, secondsOnly, timeFormat))
    formatterCache[key] = formatter
  end
  return formatter
end

function Private.FormatDurationText(duration, total, format, threshold, precision, modRate)
  local formatter = Private.GetDurationTextFormatter(format, threshold, precision)
  local modifier = modRate == false and Enum.DurationTimeModifier.BaseTime or Enum.DurationTimeModifier.RealTime
  if total then
    return duration:FormatTotalDuration(formatter, modifier)
  end
  return duration:FormatRemainingDuration(formatter, modifier)
end

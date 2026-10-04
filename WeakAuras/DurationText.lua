if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local formatterCache = {}
local MINUTE = 60
local EPSILON = 0.000001

local function IsGcdTextSuppressed(state)
  return state.cdmHideGCDText and not state.cdmTextPreview
end

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
  if IsGcdTextSuppressed(state) then
    return Private.IsDurationObject(state.cdmTextDurationObject)
  end
  return state.progressType == "durationObject" and Private.IsDurationObject(state.durationObject)
end

local function WholeSecondRule(from, direction)
  return {threshold = from, format = "%d", step = 1, rounding = direction}
end

local function BuildBreakpoints(format, threshold, precision, secondsOnly)
  local modes = Enum.NumericRuleFormatRounding
  local direction = format == 99 and modes.Up or modes.Down
  local rules = {{threshold = 0, format = ""}}

  if threshold > 0 then
    rules[2] = {threshold = EPSILON, format = "%." .. precision .. "f"}
    rules[3] = WholeSecondRule(threshold, direction)
  else
    rules[2] = WholeSecondRule(EPSILON, direction)
  end

  if not secondsOnly then
    local minuteStart = math.max(MINUTE, threshold)
    if minuteStart == threshold then
      rules[#rules] = nil
    end
    rules[#rules + 1] = {
      threshold = minuteStart,
      format = "%d:%02d",
      step = 1,
      rounding = direction,
      components = {{div = MINUTE}, {mod = MINUTE}},
    }
  end
  return rules
end

function Private.GetDurationTextFormatter(format, threshold, precision, secondsOnly)
  local cacheKey = table.concat({format, threshold, precision, tostring(secondsOnly == true)}, ":")
  local cached = formatterCache[cacheKey]
  if cached then
    return cached
  end
  cached = C_StringUtil.CreateNumericRuleFormatter()
  cached:SetBreakpoints(BuildBreakpoints(format, threshold, precision, secondsOnly))
  formatterCache[cacheKey] = cached
  return cached
end

function Private.FormatDurationText(duration, total, format, threshold, precision, modRate)
  local formatter = Private.GetDurationTextFormatter(format, threshold, precision)
  local timeBase = Enum.DurationTimeModifier
  local modifier = modRate == false and timeBase.BaseTime or timeBase.RealTime
  if total then
    return duration:FormatTotalDuration(formatter, modifier)
  end
  return duration:FormatRemainingDuration(formatter, modifier)
end

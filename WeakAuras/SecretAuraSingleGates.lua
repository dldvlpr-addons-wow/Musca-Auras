-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local AnchorsToUnitFrame = Shared.AnchorsToUnitFrame
local EDGE_MARGIN = Shared.EDGE_MARGIN
local FirstProblem = Shared.FirstProblem
local GATE_TOLERANCE = Shared.GATE_TOLERANCE
local IsTable = Shared.IsTable
local ToFinite = Shared.ToFinite
local UsesRemaining = Shared.UsesRemaining
local WINDOW_RANGES = Shared.WINDOW_RANGES
local WindowEdge = Shared.WindowEdge

local function ClientCanBind(property)
  local bindable = (Enum.DurationTextBindingProperty or {})[property]
  if bindable == nil or not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) then return false end
  return AuraDisplay.SupportsDurationColorCondition ~= nil and AuraDisplay.SupportsDurationColorCondition() and true or false
end

local TOTAL_RANGES = {
  ["="] = function(seconds) return seconds - GATE_TOLERANCE, seconds + GATE_TOLERANCE end,
  [">="] = function(seconds) return seconds - GATE_TOLERANCE end,
}

function AuraDisplay.GateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not auraTrigger then return end
  local operator, seconds = AuraDisplay.TotalFilter(auraTrigger)
  local range = operator and TOTAL_RANGES[operator]
  local lower, upper, origin
  if range then
    lower, upper = range(seconds)
    origin = "filter"
  elseif AuraDisplay.UsesApproximate(auraTrigger) then
    local learnedProfile = AuraDisplay.ApproximateProfile(auraTrigger)
    local duration = learnedProfile and learnedProfile.duration
    if type(duration) == "number" and duration > 0 then
      lower, upper, origin = duration - GATE_TOLERANCE, duration + GATE_TOLERANCE, "approximate"
    end
  end
  if not lower then return end
  local fault = FirstProblem({
    { AnchorsToUnitFrame(auraData), "Total Duration = and >= can't anchor to unit frames or nameplates." },
    { AuraDisplay.IsSingle(auraTrigger), "Total Duration = and >= only work with Show On: Aura(s) Found, without Remaining Time." },
    { not ClientCanBind("TotalDuration"), "This client can't check Total Duration = or >=." },
  })
  return math.max(EDGE_MARGIN, lower), upper, origin, fault
end

function AuraDisplay.DurationGate(auraData, auraTrigger)
  local lower, upper, _, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if lower and not fault then return lower, upper end
end

function AuraDisplay.TotalFilterProblem(auraData, auraTrigger)
  local _, _, origin, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if origin == "filter" then return fault end
end

local STACK_RULES = {
  ["="] = function(count) return "exactly", count end,
  [">="] = function(count)
    if count > 0 then return "atLeast", count end
  end,
  ["<="] = function(count)
    if count < 0 then return "never" end
    return "atMost", count
  end,
}
STACK_RULES[">"] = function(count) return STACK_RULES[">="](count + 1) end
STACK_RULES["<"] = function(count) return STACK_RULES["<="](count - 1) end

local function StackCount(auraTrigger)
  local count = ToFinite(auraTrigger.secretStacks)
  if count and count == math.floor(count) and count >= 0 and count <= AuraDisplay.STACK_LIMIT then return count end
end

function AuraDisplay.StackFilter(auraTrigger)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseStacks) then return end
  local operator = auraTrigger.secretStacksOperator or ">="
  local rule = AuraDisplay.stackOperators[operator] and STACK_RULES[operator]
  local count = StackCount(auraTrigger)
  if rule and count then return rule(count) end
end

function AuraDisplay.StackFilterProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseStacks) then return end
  if not StackCount(auraTrigger) then
    return ("Stack Count needs a whole number from 0 to %d."):format(AuraDisplay.STACK_LIMIT)
  end
  local kind = AuraDisplay.StackFilter(auraTrigger)
  if kind == nil then return end
  return FirstProblem({
    { kind == "never", "Stack Count < 0 never matches." },
    { AnchorsToUnitFrame(auraData), "Stack Count can't anchor to unit frames or nameplates." },
    { AuraDisplay.IsSingle(auraTrigger), "Stack Count only works with Show On: Aura(s) Found, without Remaining Time." },
    { AuraDisplay.GateRange(auraData, auraTrigger) ~= nil, "Stack Count can't be combined with Total Duration = or >=, or with Approximate Match." },
    { not (C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions), "This client can't check Stack Count." },
  })
end

function AuraDisplay.StackGate(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  local kind, count = AuraDisplay.StackFilter(auraTrigger)
  if (kind == "exactly" or kind == "atLeast" or kind == "atMost") and not AuraDisplay.StackFilterProblem(auraData, auraTrigger) then
    return kind, count
  end
end

function AuraDisplay.RemainingGateProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if auraData.regionType == "icon" or not UsesRemaining(auraTrigger) then return end
  return FirstProblem({
    { AuraDisplay.RemainingWindow(auraTrigger) == nil, "Remaining Time: pick a comparison and a seconds value of 0 or more." },
    { AnchorsToUnitFrame(auraData), "Remaining Time can't anchor to unit frames or nameplates." },
    { AuraDisplay.GateRange(auraData, auraTrigger) ~= nil, "On this display type, Remaining Time can't be combined with Total Duration = or >=, or with Approximate Match." },
    { not ClientCanBind("RemainingDuration"), "This client can't check Remaining Time on this display type." },
  })
end

function AuraDisplay.RemainingGateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if auraData.regionType == "icon" or not UsesRemaining(auraTrigger) or AuraDisplay.RemainingGateProblem(auraData, auraTrigger) then return end
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  return WINDOW_RANGES[operator](seconds)
end

function AuraDisplay.UsesGate(auraData)
  return AuraDisplay.DurationGate(auraData) ~= nil or AuraDisplay.RemainingGateRange(auraData) ~= nil or AuraDisplay.StackGate(auraData) ~= nil
end

local function AttachedElements(auraData, kind)
  local index = 0
  return function()
    while true do
      index = index + 1
      local element = (auraData.subRegions or {})[index]
      if element == nil then return nil end
      if (kind == nil or element.type == kind) and not AuraDisplay.IsDetachedElement(auraData, element) then return index, element end
    end
  end
end

local function ElementTextKind(element)
  local caption = element.text_text
  if type(caption) == "string" then return AuraDisplay.TextKind(caption) end
end

local function IsTextOfKind(element, kind)
  return element.text_visible ~= false and ElementTextKind(element) == kind
end

local function GlowChangeIndex(auraData, conditionEntry)
  for _, change in ipairs(conditionEntry.changes or {}) do
    if IsTable(change) and change.value == true and AuraDisplay.IsGlowProperty(auraData, change.property) then
      return tonumber(tostring(change.property):match("^sub%.(%d+)"))
    end
  end
end

function AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if auraData.regionType ~= "icon" then return end
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  if operator then
    for index, element in AttachedElements(auraData, "subglow") do
      if element.glow then
        return WindowEdge(operator, seconds), element, index, operator == ">" or operator == ">="
      end
    end
    return
  end
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    local check = IsTable(conditionEntry) and conditionEntry.check
    if IsTable(check) and not check.checks and not conditionEntry.linked and check.op == "<"
      and (check.variable == "faAuraRemaining" or check.variable == "faAuraElapsed")
      and AuraDisplay.NativeConditionKind(auraData, check) then
      local limit = tonumber(check.value)
      local index = limit and limit > 0 and GlowChangeIndex(auraData, conditionEntry)
      if index then
        return limit, (auraData.subRegions or {})[index], index, false, check.variable == "faAuraElapsed"
      end
    end
  end
end

Shared.AttachedElements = AttachedElements
Shared.ElementTextKind = ElementTextKind
Shared.IsTextOfKind = IsTextOfKind

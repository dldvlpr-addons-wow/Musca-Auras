-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local AnchorsToUnitFrame = Shared.AnchorsToUnitFrame
local IsTable = Shared.IsTable
local ToFinite = Shared.ToFinite

local function Followable(auraData, index)
  local record = IsTable(auraData.triggers) and auraData.triggers[index]
  return IsTable(record) and IsTable(record.trigger) and record.trigger.type ~= "secretAura"
end

local function PilotIndex(auraData)
  local saved = AuraDisplay.GetSavedTrigger(auraData)
  if saved == nil then return nil end
  for index, record in ipairs(auraData.triggers or {}) do
    if IsTable(record) and record.trigger == saved then return index end
  end
end

local function FollowableOthers(auraData, pilot)
  local others = {}
  for index in ipairs(auraData.triggers or {}) do
    if index ~= pilot and Followable(auraData, index) then others[#others + 1] = index end
  end
  return others
end

function AuraDisplay.FallbackChoice(auraData)
  local raw = IsTable(auraData.triggers) and auraData.triggers.secretFallback
  if raw == "none" then return "none" end
  return tonumber(raw) or "next"
end

local function CanFallBack(auraData, auraTrigger)
  if not AuraDisplay.IsSingleUnit(auraTrigger) then return false end
  if not AuraDisplay.missingTypes[auraData.regionType] then return false end
  if AuraDisplay.FlowGroup and AuraDisplay.FlowGroup(auraData) then return false end
  if AnchorsToUnitFrame(auraData) then return false end
  return not (AuraDisplay.RawShowOn(auraTrigger) == "showOnActive" and auraTrigger.secretUseRem == true)
end

function AuraDisplay.Fallback(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not IsTable(auraTrigger) or not CanFallBack(auraData, auraTrigger) then return end
  local pilot = PilotIndex(auraData)
  if not pilot then return end
  local fallbackChoice = AuraDisplay.FallbackChoice(auraData)
  if fallbackChoice == "none" then return end
  if fallbackChoice == "next" then
    if #FollowableOthers(auraData, pilot) > 0 then return "next" end
    return
  end
  if fallbackChoice ~= pilot and Followable(auraData, fallbackChoice) then return fallbackChoice end
end

function AuraDisplay.FallbackProblem(auraData)
  local fallbackChoice = AuraDisplay.FallbackChoice(auraData)
  if type(fallbackChoice) == "number" and not Followable(auraData, fallbackChoice) then
    return "Trigger Combination: the trigger picked for when the Aura (Modern) filters do not match was deleted or is itself an Aura (Modern) trigger."
  end
end

function AuraDisplay.FoundFollow(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if IsTable(auraTrigger) and AuraDisplay.RawShowOn(auraTrigger) == "showOnActive" then return AuraDisplay.Fallback(auraData, auraTrigger) end
end

function AuraDisplay.MissingSource(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if IsTable(auraTrigger) then return AuraDisplay.Fallback(auraData, auraTrigger) end
end

function AuraDisplay.TotalFilter(auraTrigger)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseTotal) then return end
  local operator = auraTrigger.secretTotalOperator or "="
  if not AuraDisplay.totalOperators[operator] then return end
  local seconds = ToFinite(auraTrigger.secretTotal)
  if seconds and seconds > 0 then return operator, seconds end
end

function AuraDisplay.UsesApproximate(auraTrigger)
  if not IsTable(auraTrigger) or auraTrigger.secretApproximate ~= true or auraTrigger.debuffType ~= "HARMFUL" then return false end
  if AuraDisplay.approximateUnits[AuraDisplay.UnitCategory(auraTrigger)] ~= true then return false end
  return (AuraDisplay.UsesSpellIDs(auraTrigger) or AuraDisplay.UsesRankSpellIDs(auraTrigger)) and true or false
end

Shared.Followable = Followable
Shared.PilotIndex = PilotIndex

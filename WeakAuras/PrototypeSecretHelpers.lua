-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Values read by the generated prototype code (unit health, power, casts,
-- totems) when the engine may hand back secret numbers in combat.

local L = WeakAuras.L
local ExecEnv = Private.ExecEnv
local IsSecret = Private.IsSecret

-- Secret operands cannot take part in arithmetic: the first secret one is
-- passed through so the display can still feed it to a secret aware widget.
function ExecEnv.PercentOrSecret(value, total)
  if IsSecret(value) then return value end
  if IsSecret(total) then return total end
  if total ~= 0 then
    return value / total * 100
  end
end

function ExecEnv.DeficitOrSecret(value, total)
  if IsSecret(value) then return value end
  if IsSecret(total) then return total end
  return total - value
end

local function ReadUnitPercent(kind, unit, powerType, curve)
  if kind == "health" then
    return pcall(UnitHealthPercent, unit, true, curve)
  end
  return pcall(UnitPowerPercent, unit, powerType, false, curve)
end

-- Percent computed by the engine when the raw value or total is secret.
function ExecEnv.SecretPercent(kind, unit, value, total, powerType, scaleTo100)
  if not (IsSecret(value, total) and CurveConstants) then
    return nil
  end
  local curve = scaleTo100 and CurveConstants.ScaleTo100 or CurveConstants.ZeroToOne
  if curve == nil then
    return nil
  end
  local ok, percent = ReadUnitPercent(kind, unit, powerType, curve)
  if ok and type(percent) == "number" then
    return percent
  end
end

function ExecEnv.GetSpellDisplayCount(spellID)
  if not (spellID and C_Spell and C_Spell.GetSpellDisplayCount) then
    return nil
  end
  local ok, text = pcall(C_Spell.GetSpellDisplayCount, spellID)
  if ok and type(text) == "string" then
    return text
  end
end

-- The answer may be false or secret; both are handed back unchanged.
function ExecEnv.IsSpellImportant(spellID)
  if not (spellID and C_Spell and C_Spell.IsSpellImportant) then
    return nil
  end
  local ok, important = pcall(C_Spell.IsSpellImportant, spellID)
  if ok then
    return important
  end
end

-- Step curves turning a unit percent (0 to 1) into one value below a
-- threshold and another from it, one per threshold and value pair.
local stepCurves, stepCurveCount = {}, 0

local function GetStepCurve(below, threshold, above)
  local key = ("%s|%s|%s"):format(tostring(below), threshold, tostring(above))
  local curve = stepCurves[key]
  if not curve then
    stepCurveCount = stepCurveCount + 1
    if stepCurveCount > 256 then
      stepCurves, stepCurveCount = {}, 1
    end
    curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, below)
    curve:AddPoint(threshold, above)
    stepCurves[key] = curve
  end
  return curve
end

function ExecEnv.UnitPercentStep(kind, unit, powerType, below, threshold, above)
  if not (C_CurveUtil and C_CurveUtil.CreateCurve and Enum and Enum.LuaCurveType) then
    return nil
  end
  local ok, value = ReadUnitPercent(kind, unit, powerType, GetStepCurve(below, threshold, above))
  if ok and type(value) == "number" then
    return value
  end
end

function ExecEnv.ThresholdAlpha(kind, unit, powerType, threshold, above)
  if not threshold or threshold <= 0 then
    return nil
  end
  return ExecEnv.UnitPercentStep(kind, unit, powerType, above and 0 or 1, threshold / 100, above and 1 or 0)
end

local function ReadDurationObject(apiFunction, ...)
  if not apiFunction then
    return nil
  end
  local ok, duration = pcall(apiFunction, ...)
  if ok and Private.IsDurationObject(duration) then
    return duration
  end
end

function ExecEnv.GetCastDurationObject(unit, castType)
  if castType == "channel" then
    return ReadDurationObject(UnitChannelDuration, unit)
  end
  return ReadDurationObject(UnitCastingDuration, unit)
end

function ExecEnv.GetTotemDurationObject(slot)
  return ReadDurationObject(GetTotemDuration, slot)
end

local function NeverSecretLevel()
  if not (Enum and Enum.SecrecyLevel) then
    return nil
  end
  return Enum.SecrecyLevel.NeverSecret
end

local function ResolveSpellID(spell)
  local spellID = tonumber(spell)
  if spellID then
    return spellID
  end
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spell)
  return info and info.spellID
end

local function IsNeverSecretSpell(spell)
  local neverSecret = NeverSecretLevel()
  local readSecrecy = C_Secrets and C_Secrets.GetSpellCastSecrecy
  if neverSecret == nil or not readSecrecy then
    return false
  end
  local spellID = ResolveSpellID(spell)
  if not spellID or IsSecret(spellID) then
    return false
  end
  local ok, secrecy = pcall(readSecrecy, spellID)
  if not ok or IsSecret(secrecy) then
    return false
  end
  return secrecy == neverSecret
end

-- A spell list stays usable in combat when every listed spell is never secret.
local function IsReadableSpellList(list)
  if type(list) ~= "table" or next(list) == nil then
    return false
  end
  for _, spell in pairs(list) do
    if not IsNeverSecretSpell(spell) then
      return false
    end
  end
  return true
end

local function WatchesPlayer(trigger)
  if type(trigger) ~= "table" then
    return true
  end
  local unit = trigger.unit or "player"
  if unit == "member" and type(trigger.specificUnit) == "string" then
    unit = trigger.specificUnit:lower()
  end
  return unit == "player"
end

-- Cast trigger options, in display order. Other units' casts hide their values
-- in combat; `readable`, when set, tells whether the option's value survives.
local combatOptions = {
  { key = "spellNames", label = "Name(s)", readable = IsReadableSpellList },
  { key = "spellIds", label = "Exact Spell ID(s)", readable = IsReadableSpellList },
  { key = "spellId", label = "Spell ID" },
  { key = "spell", label = "Spellname" },
  { key = "interruptible", label = "Interruptible" },
  { key = "remaining", label = "Remaining Time" },
  { key = "empowered", label = "Empowered" },
  { key = "stage", label = "Stage" },
  { key = "stageTotal", label = "Stage Total" },
  { key = "charged", label = "Charged" },
}

local function OptionFailsInCombat(trigger, option)
  if trigger["use_" .. option.key] == nil then
    return false
  end
  local readable = option.readable
  return not (readable and readable(trigger[option.key]))
end

-- Localized labels of the active options other units' casts defeat.
local function FailingOptionLabels(trigger)
  local labels = {}
  for index = 1, #combatOptions do
    local option = combatOptions[index]
    if OptionFailsInCombat(trigger, option) then
      labels[#labels + 1] = L[option.label]
    end
  end
  return labels
end

local function OtherUnitsMessage(failing)
  if failing[1] == nil then
    return L["|cffff9933Other units' casts: shown in combat, never filtered.|r"]
  end
  return L["|cffff2020Ignored in combat:|r %s |cffff9933(other units' casts are unreadable)|r"]:format(table.concat(failing, ", "))
end

-- Status line shown under a cast trigger in the options.
function Private.CastCombatStatus(trigger)
  if WatchesPlayer(trigger) then
    return L["|cff33ff99Fully usable in combat.|r"]
  end
  return OtherUnitsMessage(FailingOptionLabels(trigger))
end

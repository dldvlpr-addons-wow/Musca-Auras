if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local L = WeakAuras.L

local function FirstSecret(value, total)
  if Private.IsSecret(value) then
    return true, value
  elseif Private.IsSecret(total) then
    return true, total
  end
  return false
end

Private.ExecEnv.PercentOrSecret = function(value, total)
  local isSecret, secret = FirstSecret(value, total)
  if isSecret then
    return secret
  end
  return total ~= 0 and value / total * 100 or nil
end

Private.ExecEnv.DeficitOrSecret = function(value, total)
  local isSecret, secret = FirstSecret(value, total)
  if isSecret then
    return secret
  end
  return total - value
end

Private.ExecEnv.SecretPercent = function(kind, unit, value, total, powerType, scaleTo100)
  if not Private.IsSecret(value, total) or not CurveConstants then
    return nil
  end
  local curve = scaleTo100 and CurveConstants.ScaleTo100 or CurveConstants.ZeroToOne
  if not curve then
    return nil
  end
  local ok, percent
  if kind == "health" then
    ok, percent = pcall(UnitHealthPercent, unit, true, curve)
  else
    ok, percent = pcall(UnitPowerPercent, unit, powerType, false, curve)
  end
  if ok and type(percent) == "number" then
    return percent
  end
end

Private.ExecEnv.GetSpellDisplayCount = function(spellId)
  if not spellId or not C_Spell.GetSpellDisplayCount then return nil end
  local ok, text = pcall(C_Spell.GetSpellDisplayCount, spellId)
  if ok and type(text) == "string" then return text end
end

Private.ExecEnv.GetSpellCooldownDurationWithoutGCD = function(spellId)
  if not spellId or not C_Spell.GetSpellCooldownDuration then
    return nil
  end
  local ok, duration = pcall(C_Spell.GetSpellCooldownDuration, spellId, true)
  if ok and Private.IsDurationObject(duration) then
    return duration
  end
end

local thresholdCurves = {}
Private.ExecEnv.ThresholdAlpha = function(kind, unit, powerType, threshold)
  if not threshold or threshold <= 0
     or not (C_CurveUtil and C_CurveUtil.CreateCurve and Enum and Enum.LuaCurveType) then
    return nil
  end
  local curve = thresholdCurves[threshold]
  if not curve then
    curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, 1)
    curve:AddPoint(threshold / 100, 0)
    thresholdCurves[threshold] = curve
  end
  local ok, alpha
  if kind == "health" then
    ok, alpha = pcall(UnitHealthPercent, unit, true, curve)
  else
    ok, alpha = pcall(UnitPowerPercent, unit, powerType, false, curve)
  end
  if ok and type(alpha) == "number" then
    return alpha
  end
end

Private.ExecEnv.GetCastDurationObject = function(unit, castType)
  local getter = castType == "channel" and UnitChannelDuration or UnitCastingDuration
  if not getter then
    return nil
  end
  local ok, durationObject = pcall(getter, unit)
  if ok and Private.IsDurationObject(durationObject) then
    return durationObject
  end
end

Private.ExecEnv.GetTotemDurationObject = function(slot)
  if not GetTotemDuration then
    return nil
  end
  local ok, durationObject = pcall(GetTotemDuration, slot)
  if ok and Private.IsDurationObject(durationObject) then
    return durationObject
  end
end

local castReadableArgs = {
  {"spellNames", "Name(s)"}, {"spellIds", "Exact Spell ID(s)"}, {"spellId", "Spell ID"}, {"spell", "Spellname"},
  {"interruptible", "Interruptible"}, {"remaining", "Remaining Time"},
  {"empowered", "Empowered"}, {"stage", "Stage"}, {"stageTotal", "Stage Total"}, {"charged", "Charged"},
}
local castSpellArgs = {spellNames = true, spellIds = true}

local function CastSpellNeverSecret(value)
  if not (C_Secrets and C_Secrets.GetSpellCastSecrecy and Enum and Enum.SecrecyLevel) then
    return false
  end
  local id = tonumber(value)
  if not id then
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(value)
    id = info and info.spellID
  end
  if not id or Private.IsSecret(id) then
    return false
  end
  local ok, secrecy = pcall(C_Secrets.GetSpellCastSecrecy, id)
  return ok and not Private.IsSecret(secrecy) and secrecy == Enum.SecrecyLevel.NeverSecret
end

function Private.CastCombatStatus(trigger)
  trigger = type(trigger) == "table" and trigger or {}
  local unit = trigger.unit or "player"
  if unit == "member" and type(trigger.specificUnit) == "string" and trigger.specificUnit:lower() == "player" then
    unit = "player"
  end
  if unit == "player" then
    return L["|cff33ff99Works in combat.|r"]
  end
  local blocked = {}
  for _, entry in ipairs(castReadableArgs) do
    local key, label = entry[1], entry[2]
    if trigger["use_" .. key] ~= nil then
      local readable = false
      if castSpellArgs[key] and type(trigger[key]) == "table" and #trigger[key] > 0 then
        readable = true
        for _, value in ipairs(trigger[key]) do
          if not CastSpellNeverSecret(value) then
            readable = false
            break
          end
        end
      end
      if not readable then
        blocked[#blocked + 1] = L[label]
      end
    end
  end
  if #blocked > 0 then
    return L["|cffff2020Won't match in combat:|r %s. |cffff9933Casts by other units are secret in combat; only your own stay readable.|r"]:format(table.concat(blocked, ", "))
  end
  return L["|cffff9933In combat, casts by other units are secret: they still show with their bar and timer, but cannot be filtered.|r"]
end

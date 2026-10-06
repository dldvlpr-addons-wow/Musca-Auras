-- Secret value and addon restriction helpers: Private.IsSecret, Private.IsRestricted,
-- WeakAuras.IsRestricted, API availability flags. Loaded early; used by triggers, conditions and displays.
local _, Private = ...

Private.hasCombatLog = not (C_DamageMeter or issecretvalue or (C_CombatLog and C_CombatLog.SetFilteredEventsEnabled))

local issecretvalue = issecretvalue
function Private.IsSecret(...)
  if not issecretvalue then
    return false
  end
  for i = 1, select("#", ...) do
    if issecretvalue((select(i, ...))) then
      return true
    end
  end
  return false
end

local lastUnitIsUnit = {}
function Private.UnitIsUnit(unitA, unitB)
  local result = UnitIsUnit(unitA, unitB)
  local key = type(unitA) == "string" and type(unitB) == "string" and not Private.IsSecret(unitA, unitB)
    and (unitA .. "\0" .. unitB)
  if Private.IsSecret(result) then
    if key then
      return lastUnitIsUnit[key]
    end
    return nil
  end
  if key then
    lastUnitIsUnit[key] = result
  end
  return result
end

local restrictionQueries = {
  auras = "ShouldAurasBeSecret",
  cooldowns = "ShouldCooldownsBeSecret",
  spellCooldown = "ShouldSpellCooldownBeSecret",
  unitStats = "ShouldUnitStatsBeSecret",
  unitIdentity = "ShouldUnitIdentityBeSecret",
  auraInstance = "ShouldUnitAuraInstanceBeSecret",
}

function Private.IsRestricted(kind, ...)
  local query = C_Secrets and C_Secrets[restrictionQueries[kind]]
  if type(query) ~= "function" then
    return nil
  end
  local ok, result = pcall(query, ...)
  if not ok or Private.IsSecret(result) or type(result) ~= "boolean" then
    return nil
  end
  return result
end

-- A query the client has but cannot answer (error or secret result) counts as restricted.
-- A query the client lacks counts as unrestricted, so combat alone decides there.
local function IsKindRestricted(kind)
  if type(C_Secrets and C_Secrets[restrictionQueries[kind]]) ~= "function" then
    return false
  end
  return Private.IsRestricted(kind) ~= false
end

-- Single restriction predicate of the addon: combat, or auras or cooldowns turned secret.
function WeakAuras.IsRestricted()
  return InCombatLockdown() or IsKindRestricted("auras") or IsKindRestricted("cooldowns")
end

WeakAuras.IsSecretStateActive = WeakAuras.IsRestricted

do
  local restricted, aurasRestricted, cooldownsRestricted, unitStatsRestricted
  local function Update()
    local isRestricted = WeakAuras.IsRestricted()
    local auras, cooldowns = Private.IsRestricted("auras"), Private.IsRestricted("cooldowns")
    local unitStats = Private.IsRestricted("unitStats")
    if isRestricted ~= restricted or auras ~= aurasRestricted or cooldowns ~= cooldownsRestricted
       or unitStats ~= unitStatsRestricted
    then
      restricted, aurasRestricted, cooldownsRestricted, unitStatsRestricted = isRestricted, auras, cooldowns, unitStats
      Private.callbacks:Fire("RestrictionChanged", isRestricted)
    end
  end
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  for _, event in ipairs({"ADDON_RESTRICTION_STATE_CHANGED", "PLAYER_IN_COMBAT_CHANGED", "ENCOUNTER_STATE_CHANGED",
    "CHALLENGE_MODE_START", "PVP_MATCH_ACTIVE", "PVP_MATCH_INACTIVE", "PVP_MATCH_COMPLETE", "PVP_MATCH_STATE_CHANGED"})
  do
    pcall(frame.RegisterEvent, frame, event)
  end
  frame:SetScript("OnEvent", function(_, event)
    Update()
    if event ~= "PLAYER_REGEN_ENABLED" and event ~= "PLAYER_ENTERING_WORLD" then
      C_Timer.After(0, Update)
    end
  end)
end

Private.hasAuraInstanceAPI = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID and C_UnitAuras.GetAuraSlots
                             and AuraUtil and AuraUtil.ForEachAura
                             and C_TooltipInfo and C_TooltipInfo.GetUnitBuffByAuraInstanceID and true or false

function Private.IsDurationObject(value)
  if type(value) ~= "userdata" then
    return false
  end
  local ok, method = pcall(function() return value.GetRemainingDuration end)
  return ok and type(method) == "function"
end

Private.ExecEnv.IsSecret = Private.IsSecret
Private.ExecEnv.UnitIsUnit = Private.UnitIsUnit

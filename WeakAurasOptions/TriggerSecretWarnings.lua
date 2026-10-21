-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local L = WeakAuras.L

local Warnings = {}
OptionsPrivate.TriggerSecretWarnings = Warnings

Warnings.message = L["In combat, the game hides some values of this trigger. The aura can display them but cannot compare them, so some features may not work in combat."]
Warnings.text = "|cffff0000" .. Warnings.message .. "|r"
Warnings.casterText = "|cffff0000" .. L["The game hides the spells cast by units other than you or your pet, in or out of combat. This trigger cannot read them."] .. "|r"

local function IsSecret(value)
  return issecretvalue ~= nil and issecretvalue(value) == true
end

local function Probe(api, ...)
  local ok, result = pcall(api, ...)
  if ok then return result end
end

-- Asks the engine; nil means unknown: API missing, call failed, or the answer itself is secret.
local function Ask(method, ...)
  local api = C_Secrets and C_Secrets[method]
  if not api then return nil end
  local answer = Probe(api, ...)
  if not IsSecret(answer) then return answer end
end

local function Says(method, ...)
  return Ask(method, ...) == true
end

local function IsRestrictedLevel(level)
  local secrecy = Enum and Enum.SecrecyLevel
  if level == nil or not secrecy then return false end
  return level == secrecy.AlwaysSecret or level == secrecy.ContextuallySecret
end

local function RestrictionsLifted()
  return Ask("HasSecretRestrictions") == false
end

local function AsSpellNumber(raw)
  local number = tonumber(raw)
  if number and number > 0 and number < 2147483647 and number == math.floor(number) then
    return number
  end
end

local function IsSecretAura(raw)
  local id = AsSpellNumber(raw)
  return id ~= nil and (IsRestrictedLevel(Ask("GetSpellAuraSecrecy", id)) or Says("ShouldSpellAuraBeSecret", id))
end

local function AnySecretAura(list)
  for _, raw in ipairs(list or {}) do
    if IsSecretAura(raw) then return true end
  end
  return false
end

function Warnings.HasSecretAuraSpell(trigger)
  if trigger.type ~= "aura2" then return false end
  if RestrictionsLifted() then return false end
  return (trigger.useExactSpellId and AnySecretAura(trigger.auraspellids))
    or (trigger.useName and AnySecretAura(trigger.auranames))
    or false
end

local function IsEnabled(arg, trigger)
  if type(arg.enable) == "function" then return arg.enable(trigger) and true or false end
  return arg.enable ~= false
end

local function CollectConditionVariables(checks, triggernum, fields)
  for _, check in ipairs(checks) do
    if check.trigger == triggernum and type(check.variable) == "string" then
      fields[check.variable] = true
    end
    if check.checks then
      CollectConditionVariables(check.checks, triggernum, fields)
    end
  end
end

local TRISTATES = { tristate = true, tristatestring = true }

local function CheckedFieldNames(data, triggernum, trigger, prototype)
  local fields = {}
  for _, arg in ipairs(prototype and prototype.args or {}) do
    local useFlag = arg.name and trigger["use_" .. arg.name]
    if useFlag == false and not TRISTATES[arg.type] then useFlag = nil end
    if useFlag ~= nil and arg.test ~= "true" and IsEnabled(arg, trigger) then
      fields[arg.name] = true
    end
  end
  local conditionChecks = {}
  for _, condition in ipairs(data.conditions or {}) do
    conditionChecks[#conditionChecks + 1] = condition.check
  end
  CollectConditionVariables(conditionChecks, triggernum, fields)
  return fields
end

local function AnyOf(fields, names)
  for _, name in ipairs(names) do
    if fields[name] then return true end
  end
  return false
end

-- A Health or Power trigger that already filters on a number does not need the warning.
local function FiltersOnThreshold(trigger, prototype)
  for _, arg in ipairs(prototype and prototype.args or {}) do
    if arg.type == "number" and arg.name and arg.name ~= "countCharged" and IsEnabled(arg, trigger)
      and trigger["use_" .. arg.name] and trigger[arg.name] then
      return true
    end
  end
  return false
end

local function TriggerUnits(trigger, Private)
  local unit = trigger.unit or "player"
  local unitSet = Private.multiUnitUnits[unit]
  if unitSet then return unitSet end
  if type(unit) == "string" and unit ~= "none" and unit ~= "member" then
    return { [unit] = true }
  end
  return {}
end

local function FirstUnit(units, predicate)
  for unit in pairs(units) do
    local label = predicate(unit)
    if label then return label end
  end
end

local STAGGER = 99
local ALTERNATE_POWER = 10

local function PowerScope(context)
  local trigger = context.trigger
  local known
  if trigger.event == "Alternate Power" then
    known = ALTERNATE_POWER
  elseif trigger.use_powertype then
    known = trigger.powertype
  end
  if known and known ~= STAGGER and IsRestrictedLevel(Ask("GetPowerTypeSecrecy", known)) then
    return L["Power value checks and calculations:"]
  end
  return FirstUnit(context.units, function(unit)
    local current = known
    if not current then
      local ok, powerType = pcall(UnitPowerType, unit)
      -- An unreadable power type tells nothing about this unit.
      if ok and IsSecret(powerType) then return nil end
      if ok then current = powerType end
    end
    if current == STAGGER then
      if (UnitStagger and IsSecret(Probe(UnitStagger, unit))) or Says("ShouldUnitHealthMaxBeSecret", unit) then
        return L["Stagger value checks and calculations:"]
      end
    elseif IsRestrictedLevel(Ask("GetPowerTypeSecrecy", current))
      or Says("ShouldUnitPowerBeSecret", unit, current)
      or Says("ShouldUnitPowerMaxBeSecret", unit, current) then
      return L["Power value checks and calculations:"]
    end
  end)
end

local function TriggerSpellNumber(trigger)
  local id = AsSpellNumber(trigger.spellName)
  if not id and trigger.spellName ~= nil and C_Spell and C_Spell.GetSpellInfo then
    local info = Probe(C_Spell.GetSpellInfo, trigger.spellName)
    if type(info) == "table" and not IsSecret(info) then id = info.spellID end
  end
  if id ~= nil and not IsSecret(id) then return id end
end

local COOLDOWN_TIME_FIELDS = { "remaining", "duration", "expirationTime", "chargeGainTime", "chargeLostTime" }
local CHARGE_FIELDS = { "charges", "maxCharges" }

local function CooldownScope(context)
  local fields = context.fields
  local id = TriggerSpellNumber(context.trigger)
  if not id then return nil end
  if AnyOf(fields, COOLDOWN_TIME_FIELDS)
    and (IsRestrictedLevel(Ask("GetSpellCooldownSecrecy", id)) or Says("ShouldSpellCooldownBeSecret", id)) then
    return L["Cooldown time checks:"]
  end
  -- maxCharges is never secret: only the whole table or currentCharges can be.
  if AnyOf(fields, CHARGE_FIELDS) and C_Spell and C_Spell.GetSpellCharges then
    local charges = Probe(C_Spell.GetSpellCharges, id)
    if IsSecret(charges) or (type(charges) == "table" and IsSecret(charges.currentCharges)) then
      return L["Charge count checks:"]
    end
  end
  if fields.spellCount and C_Spell and C_Spell.GetSpellCastCount
    and IsSecret(Probe(C_Spell.GetSpellCastCount, id)) then
    return L["Spell count checks:"]
  end
end

local CAST_FIELDS = { "remaining", "duration", "spellId", "spell", "spellIds", "spellNames", "interruptible" }

local eventScopes = {
  ["Health"] = function() return L["Health value checks and calculations:"] end,
  ["Power"] = PowerScope,
  ["Alternate Power"] = PowerScope,
  ["Character Stats"] = function(context)
    if next(context.fields) and Says("ShouldUnitStatsBeSecret") then
      return L["Character stat checks:"]
    end
  end,
  ["Threat Situation"] = function(context)
    if context.trigger.unit == "none" then
      if Says("ShouldUnitThreatStateBeSecret", "player") then return L["Threat checks:"] end
      return nil
    end
    return FirstUnit(context.units, function(unit)
      if Says("ShouldUnitThreatStateBeSecret", "player", unit) or Says("ShouldUnitThreatValuesBeSecret", "player", unit) then
        return L["Threat checks:"]
      end
    end)
  end,
  ["Cast"] = function(context)
    if not AnyOf(context.fields, CAST_FIELDS) then return nil end
    return FirstUnit(context.units, function(unit)
      if Says("ShouldUnitSpellCastingBeSecret", unit) then return L["Cast value checks:"] end
    end)
  end,
  ["Spell Cast Succeeded"] = function(context)
    local unit = type(context.trigger.unit) == "string" and context.trigger.unit:lower()
    if unit ~= "player" and unit ~= "pet" then return L["Caster unit checks:"] end
  end,
  ["Cooldown Progress (Spell)"] = CooldownScope,
  ["Cooldown Ready (Spell)"] = CooldownScope,
  ["Charges Changed"] = CooldownScope,
  ["Action Usable"] = CooldownScope,
}

local IDENTITY_FIELDS = { "name", "namerealm", "unitname", "realm", "npcId", "guid" }

local function IdentityScope(context)
  if not AnyOf(context.fields, IDENTITY_FIELDS) then return nil end
  return FirstUnit(context.units, function(unit)
    if Says("ShouldUnitIdentityBeSecret", unit) then return L["Unit identity checks:"] end
  end)
end

local function LiveStateScope(context)
  if not next(context.fields) then return nil end
  local ok, states = pcall(WeakAuras.GetTriggerStateForTrigger, context.data.id, context.triggernum)
  if not ok or type(states) ~= "table" then return nil end
  for _, state in pairs(states) do
    if type(state) == "table" and not IsSecret(state) then
      for field in pairs(context.fields) do
        if IsSecret(state[field]) then return L["Selected value checks:"] end
      end
    end
  end
end

function Warnings.GetScope(data, triggernum)
  if RestrictionsLifted() then return nil end
  local Private = OptionsPrivate.Private
  local trigger = data.triggers[triggernum].trigger
  local event = trigger.type ~= "custom" and trigger.event or nil
  local prototype = event and Private.event_prototypes[event]

  if (event == "Health" or event == "Power") and not Private.hasCombatLog and FiltersOnThreshold(trigger, prototype) then
    return nil
  end

  local context = {
    data = data,
    triggernum = triggernum,
    trigger = trigger,
    fields = CheckedFieldNames(data, triggernum, trigger, prototype),
    units = TriggerUnits(trigger, Private),
  }
  local eventScope = event and eventScopes[event]
  return (eventScope and eventScope(context)) or IdentityScope(context) or LiveStateScope(context)
end

function Warnings.GetText(data, triggernum)
  local scope = Warnings.GetScope(data, triggernum)
  if scope == L["Caster unit checks:"] then return Warnings.casterText end
  return scope ~= nil and Warnings.text or ""
end

local function TriggerUsesSecrets(data, triggernum, trigger)
  return Warnings.HasSecretAuraSpell(trigger) or Warnings.GetScope(data, triggernum) ~= nil
end

function Warnings.UpdateAuraWarning(data)
  local Private = OptionsPrivate.Private
  if not (Private and data and data.uid and data.triggers) then return end
  local found = false
  for triggernum, triggerData in ipairs(data.triggers) do
    if type(triggerData.trigger) == "table" then
      local ok, uses = pcall(TriggerUsesSecrets, data, triggernum, triggerData.trigger)
      if ok and uses then
        found = true
        break
      end
    end
  end
  if found then
    Private.AuraWarnings.UpdateWarning(data.uid, "SecretTrigger", "warning", Warnings.message)
  else
    Private.AuraWarnings.UpdateWarning(data.uid, "SecretTrigger", nil, nil)
  end
end

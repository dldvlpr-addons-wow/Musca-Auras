if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local Warnings = {}
OptionsPrivate.TriggerSecretWarnings = Warnings
Warnings.text = "|cffff0000Secret detected. Some features may be restricted in combat.|r"

local MAX_SPELL_ID = 2147483647
local STAGGER_POWER_TYPE = 99
local ALTERNATE_POWER_TYPE = 10

local function askSecrets(method, ...)
  local api = C_Secrets and C_Secrets[method]
  if not api then return nil end
  local ok, answer = pcall(api, ...)
  if ok and not issecretvalue(answer) then
    return answer
  end
  return nil
end

local function isRestrictedLevel(level)
  local enum = Enum and Enum.SecrecyLevel
  if level == nil or not enum then return false end
  return level == enum.AlwaysSecret or level == enum.ContextuallySecret
end

local function toSpellId(raw)
  local number = tonumber(raw)
  if number and number > 0 and number < MAX_SPELL_ID and number == math.floor(number) then
    return number
  end
end

local function anyField(fields, spaceSeparated)
  for name in spaceSeparated:gmatch("%S+") do
    if fields[name] then return true end
  end
  return false
end

local function spellAuraIsSecret(raw)
  local spellId = toSpellId(raw)
  if not spellId then return false end
  if isRestrictedLevel(askSecrets("GetSpellAuraSecrecy", spellId)) then return true end
  return askSecrets("ShouldSpellAuraBeSecret", spellId) == true
end

local function anySpellAuraSecret(list)
  for _, raw in ipairs(list or {}) do
    if spellAuraIsSecret(raw) then return true end
  end
  return false
end

function Warnings.HasSecretAuraSpell(trigger)
  if trigger.type ~= "aura2" then return false end
  if askSecrets("HasSecretRestrictions") == false then return false end
  if trigger.useExactSpellId and anySpellAuraSecret(trigger.auraspellids) then
    return true
  end
  if trigger.useName and anySpellAuraSecret(trigger.auranames) then
    return true
  end
  return false
end

local function collectConditionFields(check, triggernum, into)
  if type(check) ~= "table" then return end
  if check.trigger == triggernum and type(check.variable) == "string" then
    into[check.variable] = true
  end
  for _, child in ipairs(check.checks or {}) do
    collectConditionFields(child, triggernum, into)
  end
end

local function argIsEnabled(arg, trigger)
  if arg.enable == false then return false end
  return type(arg.enable) ~= "function" or arg.enable(trigger)
end

local function argIsSelected(arg, trigger)
  local choice = arg.name and trigger["use_" .. arg.name]
  if choice == nil then return false end
  return choice ~= false or arg.type == "tristate" or arg.type == "tristatestring"
end

local function collectSelectedFields(data, triggernum, trigger)
  local fields = {}
  local prototype = trigger.type ~= "custom" and OptionsPrivate.Private.event_prototypes[trigger.event]
  for _, arg in ipairs(prototype and prototype.args or {}) do
    if argIsEnabled(arg, trigger) and arg.name and argIsSelected(arg, trigger) and arg.test ~= "true" then
      fields[arg.name] = true
    end
  end
  for _, condition in ipairs(data.conditions or {}) do
    collectConditionFields(condition.check, triggernum, fields)
  end
  return fields
end

local function unitsOf(trigger)
  local unit = trigger.unit or "player"
  local multi = OptionsPrivate.Private.multiUnitUnits[unit]
  if multi then return multi end
  if type(unit) == "string" and unit ~= "none" and unit ~= "member" then
    return { [unit] = true }
  end
  return {}
end

local function userFilteredNumbers(event, trigger)
  if OptionsPrivate.Private.hasCombatLog then return false end
  if event ~= "Health" and event ~= "Power" then return false end
  for _, arg in ipairs(OptionsPrivate.Private.event_prototypes[event].args) do
    local enabled = arg.enable == nil or arg.enable == true
                    or type(arg.enable) == "function" and arg.enable(trigger)
    if arg.type == "number" and arg.name and arg.name ~= "countCharged" and enabled
       and trigger["use_" .. arg.name] and trigger[arg.name] then
      return true
    end
  end
  return false
end

local function powerScope(event, trigger)
  local powerType
  if event == "Alternate Power" then
    powerType = ALTERNATE_POWER_TYPE
  elseif trigger.use_powertype then
    powerType = trigger.powertype
  end
  local powerMessage = "Power value checks and calculations:"
  if powerType and powerType ~= STAGGER_POWER_TYPE
     and isRestrictedLevel(askSecrets("GetPowerTypeSecrecy", powerType)) then
    return powerMessage
  end
  for unit in pairs(unitsOf(trigger)) do
    local current = powerType or UnitPowerType(unit)
    if not issecretvalue(current) then
      if current == STAGGER_POWER_TYPE then
        local staggerHidden = UnitStagger and issecretvalue(UnitStagger(unit))
        if staggerHidden or askSecrets("ShouldUnitHealthMaxBeSecret", unit) == true then
          return "Stagger value checks and calculations:"
        end
      elseif isRestrictedLevel(askSecrets("GetPowerTypeSecrecy", current))
             or askSecrets("ShouldUnitPowerBeSecret", unit, current) == true
             or askSecrets("ShouldUnitPowerMaxBeSecret", unit, current) == true then
        return powerMessage
      end
    end
  end
end

local function threatScope(_, trigger)
  if trigger.unit == "none" then
    if askSecrets("ShouldUnitThreatStateBeSecret", "player") == true then
      return "Threat checks:"
    end
    return nil
  end
  for unit in pairs(unitsOf(trigger)) do
    if askSecrets("ShouldUnitThreatStateBeSecret", "player", unit) == true
       or askSecrets("ShouldUnitThreatValuesBeSecret", "player", unit) == true then
      return "Threat checks:"
    end
  end
end

local function castScope(_, trigger, fields)
  if not anyField(fields, "remaining duration spellId spell spellIds spellNames interruptible") then return end
  for unit in pairs(unitsOf(trigger)) do
    if askSecrets("ShouldUnitSpellCastingBeSecret", unit) == true then
      return "Cast value checks:"
    end
  end
end

local function resolveSpellId(trigger)
  local direct = toSpellId(trigger.spellName)
  if direct then return direct end
  if trigger.spellName and C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(trigger.spellName)
    return info and info.spellID
  end
end

local function cooldownScope(_, trigger, fields)
  local spellId = resolveSpellId(trigger)
  if issecretvalue(spellId) or not spellId then return end
  if anyField(fields, "remaining duration expirationTime chargeGainTime chargeLostTime") then
    local hidden = isRestrictedLevel(askSecrets("GetSpellCooldownSecrecy", spellId))
                   or askSecrets("ShouldSpellCooldownBeSecret", spellId) == true
    if hidden then return "Cooldown time checks:" end
  end
  if anyField(fields, "charges maxCharges") and C_Spell and C_Spell.GetSpellCharges then
    local charges = C_Spell.GetSpellCharges(spellId)
    if issecretvalue(charges)
       or (charges and (issecretvalue(charges.currentCharges) or issecretvalue(charges.maxCharges))) then
      return "Charge count checks:"
    end
  end
  if fields.spellCount and C_Spell and C_Spell.GetSpellCastCount
     and issecretvalue(C_Spell.GetSpellCastCount(spellId)) then
    return "Spell count checks:"
  end
end

local eventScopes = {
  ["Health"] = function() return "Health value checks and calculations:" end,
  ["Power"] = powerScope,
  ["Alternate Power"] = powerScope,
  ["Character Stats"] = function(_, _, fields)
    if next(fields) and askSecrets("ShouldUnitStatsBeSecret") == true then
      return "Character stat checks:"
    end
  end,
  ["Threat Situation"] = threatScope,
  ["Cast"] = castScope,
  ["Cooldown Progress (Spell)"] = cooldownScope,
  ["Cooldown Ready (Spell)"] = cooldownScope,
  ["Charges Changed"] = cooldownScope,
  ["Action Usable"] = cooldownScope,
}

local function identityScope(trigger, fields)
  if not anyField(fields, "name namerealm unitname realm npcId guid") then return end
  for unit in pairs(unitsOf(trigger)) do
    if askSecrets("ShouldUnitIdentityBeSecret", unit) == true then
      return "Unit identity checks:"
    end
  end
end

local function liveStateScope(data, triggernum, fields)
  if not next(fields) then return end
  local ok, states = pcall(WeakAuras.GetTriggerStateForTrigger, data.id, triggernum)
  if not ok or type(states) ~= "table" then return end
  for _, state in pairs(states) do
    if not issecretvalue(state) and type(state) == "table" then
      for field in pairs(fields) do
        if issecretvalue(state[field]) then
          return "Selected value checks:"
        end
      end
    end
  end
end

function Warnings.GetScope(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  if askSecrets("HasSecretRestrictions") == false then return end
  local event = trigger.type ~= "custom" and trigger.event
  local fields = collectSelectedFields(data, triggernum, trigger)
  if userFilteredNumbers(event, trigger) then return end

  local byEvent = eventScopes[event]
  local message = byEvent and byEvent(event, trigger, fields)
  return message
    or identityScope(trigger, fields)
    or liveStateScope(data, triggernum, fields)
end

function Warnings.GetText(data, triggernum)
  if Warnings.GetScope(data, triggernum) then
    return Warnings.text
  end
  return ""
end

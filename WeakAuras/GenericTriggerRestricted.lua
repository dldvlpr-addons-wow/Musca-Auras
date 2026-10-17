-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

Private.callbacks:RegisterCallback("RestrictionChanged", function()
  Private.ScanEvents("WA_RESTRICTION_CHANGED")
  Private.ScanEvents("WA_SECRET_STATE_UPDATE")
end)

-- Option warnings for triggers that cannot work under the Forever restrictions.

local warningMessages = {
  forever_combat_log = "WoW Forever does not give the combat log to addons: combat log triggers and CLEU events never fire.",
  forever_secret_threshold = "In combat, WoW Forever can hide health and power values from addons. A threshold on them "
    .. "cannot be checked then: the aura keeps its last state, or hides for a percent or deficit threshold.",
}

local secretValueEvents = { Health = true, Power = true }
local eventIndependentCustomTypes = { status = true, stateupdate = true }

local function CustomTriggerUsesCombatLog(trigger)
  if eventIndependentCustomTypes[trigger.custom_type] and trigger.check == "update" then
    return false
  end
  for _, event in ipairs(WeakAuras.split(trigger.events)) do
    local upper = event:upper()
    if upper:find("^CLEU") or upper:find("^COMBAT_LOG_EVENT") then
      return true
    end
  end
  return false
end

local function IsArgEnabled(arg, trigger)
  if type(arg.enable) == "function" then
    return arg.enable(trigger)
  end
  return arg.enable == nil or arg.enable
end

local function HasSecretThreshold(trigger, prototype)
  if not secretValueEvents[trigger.event] then
    return false
  end
  for _, arg in ipairs(prototype.args) do
    local name = arg.name
    if arg.type == "number" and name and name ~= "countCharged"
       and trigger["use_" .. name] and trigger[name] ~= nil and IsArgEnabled(arg, trigger) then
      return true
    end
  end
  return false
end

local function SetWarning(uid, key, active)
  if active then
    Private.AuraWarnings.UpdateWarning(uid, key, "warning", warningMessages[key])
  else
    Private.AuraWarnings.UpdateWarning(uid, key)
  end
end

function Private.UpdateRestrictedTriggerWarnings(data)
  local usesCombatLog, hasSecretThreshold = false, false
  if not Private.hasCombatLog then
    for _, triggerData in ipairs(data.triggers) do
      local trigger = triggerData.trigger
      if type(trigger) == "table" then
        if trigger.type == "custom" then
          usesCombatLog = usesCombatLog or CustomTriggerUsesCombatLog(trigger)
        elseif Private.category_event_prototype[trigger.type] and Private.event_prototypes[trigger.event] then
          if trigger.event == "Combat Log" then
            usesCombatLog = true
          else
            hasSecretThreshold = hasSecretThreshold
              or HasSecretThreshold(trigger, Private.event_prototypes[trigger.event])
          end
        end
      end
    end
  end
  SetWarning(data.uid, "forever_combat_log", usesCombatLog)
  SetWarning(data.uid, "forever_secret_threshold", hasSecretThreshold)
end

-- Totem slots. GetTotemInfo may answer with secrets in combat; the identity (name, icon, spell) of a
-- slot is then taken from what was last seen there, or named after a fresh cast of a spell known to land in it.

local HINT_LIFETIME = 0.5
local TOTEM_SLOTS = 5

-- slot -> { name, icon, spellId } describing what the slot holds; nil when unknown.
local slotIdentity = {}
-- Latest player cast, used only as a hint to name a slot that reads as secret.
local castHint

local function SpellToSlotTable(create)
  local db = Private.db
  if not db then
    return nil
  end
  if create then
    db.totemSpells = db.totemSpells or {}
  end
  return db.totemSpells
end

local function HintedSpellFor(slot)
  if not castHint or not castHint.spellId or GetTime() - castHint.at > HINT_LIFETIME then
    return nil
  end
  local spellToSlot = SpellToSlotTable()
  if spellToSlot and spellToSlot[castHint.spellId] == slot then
    return castHint.spellId
  end
end

-- Single owner of slotIdentity. With keepSecret, a secret slot is left untouched.
-- Returns true when a secret slot ended up with a different identity.
local function RefreshSlot(slot, keepSecret)
  local active, name, started, duration, icon, rate, spellId = GetTotemInfo(slot)
  if not Private.IsSecret(active, name, started, duration, icon, rate, spellId) then
    local occupied = active and (started or 0) ~= 0
    slotIdentity[slot] = occupied and { name = name, icon = icon, spellId = spellId } or nil
    if occupied and type(spellId) == "number" and spellId > 0 then
      local spellToSlot = SpellToSlotTable(true)
      if spellToSlot then
        spellToSlot[spellId] = slot
      end
    end
    return false
  end
  if keepSecret then
    return false
  end
  local before = slotIdentity[slot]
  local hinted = HintedSpellFor(slot)
  slotIdentity[slot] = hinted and {
    name = Private.ExecEnv.GetSpellName(hinted),
    icon = Private.ExecEnv.GetSpellIcon(hinted),
    spellId = hinted,
  } or nil
  return hinted ~= nil or before ~= nil
end

local function PublicNumber(value)
  if not Private.IsSecret(value) and type(value) == "number" then
    return value
  end
end

local slotWatcher = CreateFrame("Frame")
slotWatcher:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
slotWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
slotWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
slotWatcher:RegisterEvent("PLAYER_TOTEM_UPDATE")
slotWatcher:SetScript("OnEvent", function(_, event, arg1, _, arg3)
  if event == "PLAYER_TOTEM_UPDATE" then
    local slot = PublicNumber(arg1)
    if slot then
      RefreshSlot(slot)
    end
    Private.ScanEvents("WA_TOTEM_UPDATE", arg1)
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
    local spellId = PublicNumber(arg3)
    local spellToSlot = spellId and SpellToSlotTable()
    castHint = { at = GetTime(), spellId = spellId }
    local slot = spellToSlot and spellToSlot[spellId]
    if slot and RefreshSlot(slot) then
      Private.ScanEvents("WA_TOTEM_UPDATE", slot)
    end
  else
    for slot = 1, TOTEM_SLOTS do
      RefreshSlot(slot, true)
    end
    Private.ScanEvents("WA_TOTEM_UPDATE")
  end
end)

function Private.ExecEnv.GetTotemSlotInfo(slot)
  local active, name, started, duration, icon, rate, spellId = GetTotemInfo(slot)
  local known = slotIdentity[slot]
  if not known or not Private.IsSecret(name, icon, spellId) then
    return active, name, started, duration, icon, rate, spellId
  end
  return active, known.name, started, duration, known.icon, rate, known.spellId
end

if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local ipairs, type = ipairs, type

Private.callbacks:RegisterCallback("RestrictionChanged", function()
  Private.ScanEvents("WA_RESTRICTION_CHANGED")
  Private.ScanEvents("WA_SECRET_STATE_UPDATE")
end)

local function HasSecretThreshold(prototype, trigger)
  if trigger.event ~= "Health" and trigger.event ~= "Power" then
    return false
  end
  for _, arg in ipairs(prototype.args) do
    local enabled = arg.enable == nil or arg.enable == true
                    or type(arg.enable) == "function" and arg.enable(trigger)
    if arg.type == "number" and arg.name and arg.name ~= "countCharged" and enabled
       and trigger["use_" .. arg.name] and trigger[arg.name] then
      return true
    end
  end
  return false
end

local function HasCombatLogEvent(trigger)
  if (trigger.custom_type == "status" or trigger.custom_type == "stateupdate") and trigger.check == "update" then
    return false
  end
  for _, event in ipairs(WeakAuras.split(trigger.events)) do
    local upperEvent = event:upper()
    if upperEvent:find("^CLEU") or upperEvent:find("^COMBAT_LOG_EVENT") then
      return true
    end
  end
  return false
end

function Private.UpdateRestrictedTriggerWarnings(data)
  local warnAboutCombatLog, warnAboutSecretThreshold = false, false
  if not Private.hasCombatLog then
    for _, triggerData in ipairs(data.triggers) do
      local trigger = triggerData.trigger
      local prototype = type(trigger) == "table" and Private.category_event_prototype[trigger.type]
                        and Private.event_prototypes[trigger.event]
      if type(trigger) == "table" and trigger.type == "custom" then
        if HasCombatLogEvent(trigger) then
          warnAboutCombatLog = true
        end
      elseif prototype then
        if trigger.event == "Combat Log" then
          warnAboutCombatLog = true
        elseif HasSecretThreshold(prototype, trigger) then
          warnAboutSecretThreshold = true
        end
      end
    end
  end

  if warnAboutCombatLog then
    Private.AuraWarnings.UpdateWarning(data.uid, "forever_combat_log", "warning",
      "WoW Forever does not give the combat log to addons: combat log triggers and CLEU events never fire.")
  else
    Private.AuraWarnings.UpdateWarning(data.uid, "forever_combat_log")
  end
  if warnAboutSecretThreshold then
    Private.AuraWarnings.UpdateWarning(data.uid, "forever_secret_threshold", "warning",
      "In combat, WoW Forever can hide health and power values from addons. A threshold on them cannot be checked "
      .. "then: the aura keeps its last state, or hides for a percent or deficit threshold.")
  else
    Private.AuraWarnings.UpdateWarning(data.uid, "forever_secret_threshold")
  end
end

do
  local totemSlots = {}
  local lastTotemCast = {time = -math.huge}
  local TOTEM_CAST_WINDOW = 0.5

  local function LearnedTotemSpells()
    if not Private.db then
      return
    end
    Private.db.totemSpells = Private.db.totemSpells or {}
    return Private.db.totemSpells
  end

  local function ReadTotemSlot(slot)
    local haveTotem, name, startTime, duration, icon, modRate, spellId = GetTotemInfo(slot)
    if Private.IsSecret(haveTotem, name, startTime, duration, icon, modRate, spellId) then
      return
    end
    if haveTotem and startTime and startTime ~= 0 then
      totemSlots[slot] = {name = name, icon = icon, spellId = spellId}
      local learned = LearnedTotemSpells()
      if learned and type(spellId) == "number" and spellId > 0 then
        learned[spellId] = slot
      end
    else
      totemSlots[slot] = nil
    end
    return true
  end

  local function UpdateSecretTotemSlot(slot)
    local learned = LearnedTotemSpells()
    local spellId = lastTotemCast.spellId
    if spellId and learned and learned[spellId] == slot and GetTime() - lastTotemCast.time <= TOTEM_CAST_WINDOW then
      totemSlots[slot] = {name = Private.ExecEnv.GetSpellName(spellId), icon = Private.ExecEnv.GetSpellIcon(spellId), spellId = spellId}
      return true
    end
    local changed = totemSlots[slot] ~= nil
    totemSlots[slot] = nil
    return changed
  end

  local totemFrame = CreateFrame("Frame")
  totemFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")
  totemFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  totemFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  totemFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  totemFrame:SetScript("OnEvent", function(_, event, arg1, _, spellId)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
      local public = not Private.IsSecret(spellId) and type(spellId) == "number"
      lastTotemCast.time, lastTotemCast.spellId = GetTime(), public and spellId or nil
      local learned = public and LearnedTotemSpells()
      local slot = learned and learned[spellId]
      if slot and not ReadTotemSlot(slot) and UpdateSecretTotemSlot(slot) then
        Private.ScanEvents("WA_TOTEM_UPDATE", slot)
      end
    elseif event == "PLAYER_TOTEM_UPDATE" then
      if type(arg1) == "number" and not Private.IsSecret(arg1) and not ReadTotemSlot(arg1) then
        UpdateSecretTotemSlot(arg1)
      end
      Private.ScanEvents("WA_TOTEM_UPDATE", arg1)
    else
      for slot = 1, 5 do
        ReadTotemSlot(slot)
      end
      Private.ScanEvents("WA_TOTEM_UPDATE")
    end
  end)

  function Private.ExecEnv.GetTotemSlotInfo(slot)
    local haveTotem, name, startTime, duration, icon, modRate, spellId = GetTotemInfo(slot)
    local totem = totemSlots[slot]
    if totem and Private.IsSecret(name, icon, spellId) then
      return haveTotem, totem.name, startTime, duration, totem.icon, modRate, totem.spellId
    end
    return haveTotem, name, startTime, duration, icon, modRate, spellId
  end
end

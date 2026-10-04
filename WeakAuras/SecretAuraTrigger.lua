if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

local ModernAura = {}
local registeredDisplays = {}
local activeDisplays = {}

local SECRET_AURA_TYPE = "secretAura"
local DISPLAY_NAME = "Aura (Modern)"

function ModernAura.Add(data)
  Display.MigrateNativeConditions(data)
  Display.MigrateFallback(data)
  local displayId = data.id
  registeredDisplays[displayId] = nil
  for _, triggerEntry in ipairs(data.triggers) do
    if triggerEntry.trigger.type == SECRET_AURA_TYPE then
      registeredDisplays[displayId] = data
      return
    end
  end
end

local unitsThatMayBeAbsent = {
  target = true,
  focus = true,
  pet = true,
  targettarget = true,
  focustarget = true,
  member = true,
}

local function IsTrackedUnitAbsent(trigger)
  if type(trigger) ~= "table" then
    return false
  end
  if not unitsThatMayBeAbsent[trigger.unit] or trigger.unitExists then
    return false
  end
  return not Display.SingleUnitExists(trigger)
end

local function SettingsAllowDisplay(data)
  return not Display.Enabled(data) or Display.Validate(data) == nil
end

local function ComputeShow(data, triggernum)
  if not SettingsAllowDisplay(data) then
    return false
  end
  local triggerEntry = data.triggers[triggernum]
  return WeakAuras.IsOptionsOpen() or not IsTrackedUnitAbsent(triggerEntry and triggerEntry.trigger)
end

function ModernAura.CreateFallbackState(data, triggernum, state)
  state.show = SettingsAllowDisplay(data)
  state.changed = true
  state.progressType = "static"
  state.value = 1
  state.total = 1
  state.name, state.icon = ModernAura.GetNameAndIcon(data, triggernum)
  if WeakAuras.IsOptionsOpen() then
    state.unit = Display.GetPreviewUnit(data) or nil
  else
    state.unit = nil
  end
  if WeakAuras.IsOptionsOpen() then
    state.progressType = "timed"
    state.duration = 6
    state.expirationTime = GetTime() + 6
    state.stacks = 3
  end
end

function ModernAura.CreateFakeStates(id, triggernum)
  local states = WeakAuras.GetTriggerStateForTrigger(id, triggernum)
  wipe(states)
  states[""] = {}
  local data = WeakAuras.GetData(id)
  ModernAura.CreateFallbackState(data, triggernum, states[""])
  states[""].show = ComputeShow(data, triggernum)
end

function ModernAura.LoadDisplays(toLoad)
  for id in pairs(toLoad) do
    local data = registeredDisplays[id]
    if data then
      activeDisplays[id] = true
      local regionInfo = Private.regions[id]
      if regionInfo then
        Display.Activate(regionInfo.region, data)
      end
      for index, triggerEntry in ipairs(data.triggers) do
        if triggerEntry.trigger.type == SECRET_AURA_TYPE then
          ModernAura.CreateFakeStates(id, index)
        end
      end
      Private.UpdatedTriggerState(id)
    end
  end
end

local unitEventAffects = {
  PLAYER_TARGET_CHANGED = {target = true, targettarget = true},
  PLAYER_FOCUS_CHANGED = {focus = true, focustarget = true},
  UNIT_TARGET = {target = {targettarget = true}, focus = {focustarget = true}},
  UNIT_PET = {player = {pet = true}},
  PLAYER_ENTERING_WORLD = {
    target = true,
    focus = true,
    pet = true,
    targettarget = true,
    focustarget = true,
    member = true,
  },
  GROUP_ROSTER_UPDATE = {member = true},
  INSTANCE_ENCOUNTER_ENGAGE_UNIT = {member = true},
  ARENA_OPPONENT_UPDATE = {member = true},
}

local function ResolveAffectedUnits(event, unit)
  local affected = unitEventAffects[event]
  if event == "UNIT_TARGET" then
    return unit and affected[unit]
  elseif event == "UNIT_PET" then
    return unit == "player" and affected.player or (unit and {member = true})
  end
  return affected
end

local function RefreshDisplayStates(id, affected)
  local data = registeredDisplays[id]
  local changed = false
  local triggerList = data and data.triggers or {}
  for index, triggerEntry in ipairs(triggerList) do
    if triggerEntry.trigger.type == SECRET_AURA_TYPE and affected[triggerEntry.trigger.unit] then
      local state = WeakAuras.GetTriggerStateForTrigger(id, index)[""]
      local show = ComputeShow(data, index)
      if not state then
        if show then
          ModernAura.CreateFakeStates(id, index)
          changed = true
        end
      elseif state.show ~= show then
        state.show = show
        state.changed = true
        changed = true
      end
    end
  end
  return changed
end

local unitWatcher = CreateFrame("Frame")
for event in pairs(unitEventAffects) do
  unitWatcher:RegisterEvent(event)
end
unitWatcher:SetScript("OnEvent", function(_, event, unit)
  if WeakAuras.IsOptionsOpen() then
    return
  end
  local affected = ResolveAffectedUnits(event, unit)
  if not affected then
    return
  end
  for id in pairs(activeDisplays) do
    if RefreshDisplayStates(id, affected) then
      Private.UpdatedTriggerState(id)
    end
  end
end)

function ModernAura.UnloadDisplays(toUnload)
  for id in pairs(toUnload) do
    activeDisplays[id] = nil
    if registeredDisplays[id] then
      local regionInfo = Private.regions[id]
      if regionInfo then
        Display.Release(regionInfo.region)
      end
    end
  end
end

function ModernAura.UnloadAll()
  ModernAura.UnloadDisplays(activeDisplays)
end

function ModernAura.Delete(id)
  ModernAura.UnloadDisplays({[id] = true})
  registeredDisplays[id] = nil
end

function ModernAura.Rename(oldid, newid)
  registeredDisplays[newid] = registeredDisplays[oldid]
  activeDisplays[newid] = activeDisplays[oldid]
  registeredDisplays[oldid] = nil
  activeDisplays[oldid] = nil
end

function ModernAura.FinishLoadUnload()
end

function ModernAura.GetName()
  return DISPLAY_NAME
end

function ModernAura.CanHaveTooltip()
  return false
end

function ModernAura.SetToolTip()
  return false
end

function ModernAura.GetOverlayInfo()
  return {}
end

function ModernAura.GetAdditionalProperties()
  return {}
end

function ModernAura.GetProgressSources(data, triggernum, values)
  table.insert(values, {
    trigger = triggernum,
    property = "value",
    type = "number",
    display = DISPLAY_NAME,
    total = "total",
  })
end

function ModernAura.GetTriggerConditions()
  return {}
end

function ModernAura.GetNameAndIcon(data, triggernum)
  local trigger = data.triggers[triggernum].trigger
  local spellId = Display.GetSpellIDs(trigger, false)[1]
  local spellInfo = spellId and C_Spell.GetSpellInfo(spellId)
  return spellInfo and spellInfo.name or "Secret Auras", spellInfo and spellInfo.iconID or 134400
end

local function DescribeSpellIDs(ids, enabled)
  if not enabled or not ids or #ids == 0 then
    return "None"
  end
  local firstIds = {}
  for position = 1, math.min(#ids, 3) do
    firstIds[#firstIds + 1] = tostring(ids[position])
  end
  local text = table.concat(firstIds, ", ")
  if #ids > #firstIds then
    text = text .. " (+" .. (#ids - #firstIds) .. " more)"
  end
  return text
end

function ModernAura.GetTriggerDescription(data, triggernum, lines)
  local trigger = data.triggers[triggernum].trigger
  local unitLabel
  if trigger.unit == "member" then
    unitLabel = Display.SpecificUnit(trigger) or "Specific Unit"
  else
    unitLabel = Display.units[trigger.unit] or trigger.unit
  end
  lines[#lines + 1] = {"Secret Auras", unitLabel}
  local showOnLabel = Display.showOnValues[Display.ShowOn(trigger)]
  local comparison, seconds = Display.RemainingWindow(trigger)
  if comparison then
    showOnLabel = showOnLabel .. ", remaining " .. comparison .. " " .. seconds .. " s"
  end
  lines[#lines + 1] = {"Show On", showOnLabel}
  lines[#lines + 1] = {"Spell IDs (All Ranks)", DescribeSpellIDs(trigger.auraRankSpellIDs, Display.UsesRankSpellIDs(trigger))}
  lines[#lines + 1] = {"Exact Spell IDs", DescribeSpellIDs(trigger.auraspellids, Display.UsesSpellIDs(trigger))}
end

WeakAuras.RegisterTriggerSystem({SECRET_AURA_TYPE}, ModernAura)

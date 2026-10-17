-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Trigger system of the "secretAura" trigger type. The auras themselves are
-- drawn by Private.BlizzardAuraDisplay; this file only gives WeakAuras the
-- load cycle and one placeholder state per trigger, shown or hidden with the
-- unit the trigger follows.

local Display = Private.BlizzardAuraDisplay

local TRIGGER_NAME = "Aura (Modern)"
local DEFAULT_NAME = "Secret Auras"
local DEFAULT_ICON = 134400
local PREVIEW_DURATION = 6
local PREVIEW_STACKS = 3

-- One record per aura id: `data` while the aura holds a secretAura trigger,
-- `loaded` while WeakAuras keeps it loaded.
local auraStates = {}

local function DropIfEmpty(id)
  local record = auraStates[id]
  if record and record.data == nil and not record.loaded then
    auraStates[id] = nil
  end
end

local OPTIONAL_UNITS = {
  target = true, focus = true, pet = true, targettarget = true, focustarget = true, member = true,
}

local function GetTrigger(data, triggernum)
  local entry = data and data.triggers and data.triggers[triggernum]
  return entry and entry.trigger
end

local function IsSecretTrigger(entry)
  return type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type == "secretAura"
end

-- Units that may be absent, unless the trigger already requires them.
local function TracksOptionalUnit(trigger)
  return type(trigger) == "table" and OPTIONAL_UNITS[trigger.unit] and not trigger.unitExists
end

local function IsUnitMissing(trigger)
  if not TracksOptionalUnit(trigger) then
    return false
  end
  local present = Display.SingleUnitExists(trigger)
  return not present
end

-- An aura without the native display, or with valid native settings.
local function IsAuraUsable(data)
  local usesNativeDisplay = Display.Enabled(data)
  if not usesNativeDisplay then
    return true
  end
  return Display.Validate(data) == nil
end

local function ShouldShow(data, triggernum)
  if not IsAuraUsable(data) then
    return false
  end
  return WeakAuras.IsOptionsOpen() or not IsUnitMissing(GetTrigger(data, triggernum))
end

local function HasSecretTrigger(data)
  local triggers = data.triggers
  if triggers == nil then
    return false
  end
  local index = 1
  while triggers[index] ~= nil do
    if IsSecretTrigger(triggers[index]) then
      return true
    end
    index = index + 1
  end
  return false
end

local system = {}

function system.Add(data)
  Display.MigrateNativeConditions(data)
  Display.MigrateFallback(data)
  local id = data.id
  if HasSecretTrigger(data) then
    local record = auraStates[id] or {}
    record.data = data
    auraStates[id] = record
  elseif auraStates[id] then
    auraStates[id].data = nil
    DropIfEmpty(id)
  end
end

function system.GetNameAndIcon(data, triggernum)
  local spellIDs = Display.GetSpellIDs(GetTrigger(data, triggernum), false)
  local spellID = spellIDs and spellIDs[1]
  local info = spellID and C_Spell.GetSpellInfo(spellID)
  if not info then
    return DEFAULT_NAME, DEFAULT_ICON
  end
  return info.name or DEFAULT_NAME, info.iconID or DEFAULT_ICON
end

function system.CreateFallbackState(data, triggernum, state)
  state.show = IsAuraUsable(data)
  state.changed = true
  state.progressType = "static"
  state.total = 1
  state.value = state.total
  state.name, state.icon = system.GetNameAndIcon(data, triggernum)
  state.unit = nil
  if WeakAuras.IsOptionsOpen() then
    state.unit = Display.GetPreviewUnit(data) or nil
    state.progressType = "timed"
    state.duration = PREVIEW_DURATION
    state.expirationTime = GetTime() + PREVIEW_DURATION
    state.stacks = PREVIEW_STACKS
  end
end

function system.CreateFakeStates(id, triggernum)
  local data = WeakAuras.GetData(id)
  local states = WeakAuras.GetTriggerStateForTrigger(id, triggernum)
  wipe(states)
  local state = {}
  system.CreateFallbackState(data, triggernum, state)
  state.show = ShouldShow(data, triggernum)
  states[""] = state
end

function system.LoadDisplays(toLoad)
  for id in pairs(toLoad) do
    local record = auraStates[id]
    local data = record and record.data
    if data then
      record.loaded = true
      local regionInfo = Private.regions[id]
      if regionInfo then
        Display.Activate(regionInfo.region, data)
      end
      for index, entry in ipairs(data.triggers) do
        if IsSecretTrigger(entry) then
          system.CreateFakeStates(id, index)
        end
      end
      Private.UpdatedTriggerState(id)
    end
  end
end

function system.UnloadDisplays(toUnload)
  for id in pairs(toUnload) do
    local record = auraStates[id]
    if record then
      record.loaded = nil
      local regionInfo = record.data and Private.regions[id]
      if regionInfo then
        Display.Release(regionInfo.region)
      end
      DropIfEmpty(id)
    end
  end
end

function system.UnloadAll()
  local loadedIds = {}
  for id, record in pairs(auraStates) do
    if record.loaded then
      loadedIds[id] = true
    end
  end
  system.UnloadDisplays(loadedIds)
end

function system.Delete(id)
  system.UnloadDisplays({ [id] = true })
  local record = auraStates[id]
  if record then
    record.data = nil
    DropIfEmpty(id)
  end
end

function system.Rename(oldid, newid)
  auraStates[newid], auraStates[oldid] = auraStates[oldid], nil
end

function system.FinishLoadUnload()
end

function system.GetName()
  return TRIGGER_NAME
end

function system.CanHaveTooltip()
  return false
end

function system.SetToolTip()
  return false
end

function system.GetOverlayInfo()
  return {}
end

function system.GetAdditionalProperties()
  return {}
end

function system.GetTriggerConditions()
  return {}
end

function system.GetProgressSources(data, triggernum, values)
  values[#values + 1] = {
    trigger = triggernum,
    property = "value",
    type = "number",
    display = TRIGGER_NAME,
    total = "total",
  }
end

local function DescribeSpellIDs(spellIDs, enabled)
  if not enabled or type(spellIDs) ~= "table" or #spellIDs == 0 then
    return "None"
  end
  local count = #spellIDs
  local text = tostring(spellIDs[1])
  for index = 2, count < 3 and count or 3 do
    text = text .. ", " .. tostring(spellIDs[index])
  end
  local hidden = count - 3
  if hidden > 0 then
    text = ("%s (+%d more)"):format(text, hidden)
  end
  return text
end

local function UnitLabel(trigger)
  if trigger.unit == "member" then
    return Display.SpecificUnit(trigger) or "Specific Unit"
  end
  return Display.units[trigger.unit] or trigger.unit
end

local function ShowOnLabel(trigger)
  local label = Display.showOnValues[Display.ShowOn(trigger)]
  local comparator, seconds = Display.RemainingWindow(trigger)
  if not (comparator and seconds) then
    return label
  end
  return ("%s, remaining %s %s s"):format(tostring(label), comparator, seconds)
end

function system.GetTriggerDescription(data, triggernum, lines)
  local trigger = GetTrigger(data, triggernum)
  lines[#lines + 1] = { DEFAULT_NAME, UnitLabel(trigger) }
  lines[#lines + 1] = { "Show On", ShowOnLabel(trigger) }
  lines[#lines + 1] = { "Spell IDs (All Ranks)", DescribeSpellIDs(trigger.auraRankSpellIDs, Display.UsesRankSpellIDs(trigger)) }
  lines[#lines + 1] = { "Exact Spell IDs", DescribeSpellIDs(trigger.auraspellids, Display.UsesSpellIDs(trigger)) }
end

WeakAuras.RegisterTriggerSystem({ "secretAura" }, system)

-- Unit appearance and disappearance: units each event may have changed.
local TARGET_UNITS = { target = true, targettarget = true }
local FOCUS_UNITS = { focus = true, focustarget = true }
local TARGET_OF_TARGET = { targettarget = true }
local TARGET_OF_FOCUS = { focustarget = true }
local PET_UNITS = { pet = true }
local MEMBER_UNITS = { member = true }

local unitsByEvent = {
  PLAYER_TARGET_CHANGED = TARGET_UNITS,
  PLAYER_FOCUS_CHANGED = FOCUS_UNITS,
  PLAYER_ENTERING_WORLD = OPTIONAL_UNITS,
  GROUP_ROSTER_UPDATE = MEMBER_UNITS,
  INSTANCE_ENCOUNTER_ENGAGE_UNIT = MEMBER_UNITS,
  ARENA_OPPONENT_UPDATE = MEMBER_UNITS,
}

local function AffectedUnits(event, unit)
  if event == "UNIT_TARGET" then
    if unit == "target" then
      return TARGET_OF_TARGET
    elseif unit == "focus" then
      return TARGET_OF_FOCUS
    end
    return nil
  elseif event == "UNIT_PET" then
    if unit == "player" then
      return PET_UNITS
    elseif unit then
      return MEMBER_UNITS
    end
    return nil
  end
  return unitsByEvent[event]
end

-- Returns true when the state had to change.
local function ApplyVisibility(state, show)
  if state.show == show then
    return false
  end
  state.show = show
  state.changed = true
  return true
end

-- Returns true when the trigger's placeholder was created or updated.
local function RefreshTrigger(id, data, index)
  local show = ShouldShow(data, index)
  local state = WeakAuras.GetTriggerStateForTrigger(id, index)[""]
  if state then
    return ApplyVisibility(state, show)
  end
  if show then
    system.CreateFakeStates(id, index)
    return true
  end
  return false
end

local function RefreshAura(id, data, units)
  local updated = false
  for index, slot in ipairs(data.triggers) do
    if IsSecretTrigger(slot) and units[slot.trigger.unit] and RefreshTrigger(id, data, index) then
      updated = true
    end
  end
  if updated then
    Private.UpdatedTriggerState(id)
  end
end

local eventFrame = CreateFrame("Frame")
for _, event in ipairs({
  "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_TARGET", "UNIT_PET", "PLAYER_ENTERING_WORLD",
  "GROUP_ROSTER_UPDATE", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "ARENA_OPPONENT_UPDATE",
}) do
  eventFrame:RegisterEvent(event)
end
-- The editor shows every placeholder, whatever the unit.
eventFrame:SetScript("OnEvent", function(_, event, unit)
  if WeakAuras.IsOptionsOpen() then
    return
  end
  local units = AffectedUnits(event, unit)
  if not units then
    return
  end
  for id, record in pairs(auraStates) do
    if record.loaded and record.data then
      RefreshAura(id, record.data, units)
    end
  end
end)

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local Events = Shared.Events
local FlushPendingSounds = Shared.FlushPendingSounds
local GrowNameplateTokens = Shared.GrowNameplateTokens
local Plates = Shared.Plates
local Queues = Shared.Queues
local SOUND_UNITS = Shared.SOUND_UNITS
local SyncSounds = Shared.SyncSounds
local Units = Shared.Units
local liveRegions = Shared.liveRegions
local nameplateTokens = Shared.nameplateTokens
local queuedApplies = Shared.queuedApplies

local knownPlates = {}

function Plates.Grow(index)
  if index <= #nameplateTokens then return false end
  return GrowNameplateTokens(index)
end

function Plates.Note(unit)
  if issecretvalue(unit) or type(unit) ~= "string" or knownPlates[unit] then return end
  local digits = unit:match("^nameplate(%d+)$")
  if not digits then return end
  knownPlates[unit] = true
  if Plates.Grow(tonumber(digits)) then
    for auraRegion in pairs(liveRegions) do
      local state = auraRegion.blizzardAuraDisplay
      local triggerConfig = Display.GetTrigger(state.data)
      if triggerConfig and triggerConfig.unit == "nameplate" then queuedApplies[auraRegion] = state.data end
    end
  end
end

function Plates.ReadShown()
  for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do Plates.Note(plate.unitToken) end
  Queues.StartApplies()
end

local function RosterEvent(event, _, triggerConfig)
  if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED" or event == "UNIT_NAME_UPDATE" then return true end
  return event == "UNIT_PET" and triggerConfig.use_includePets and true or false
end

local UnitModeRules = {
  group = RosterEvent,
  party = RosterEvent,
  raid = RosterEvent,
  member = function(event)
    return event == "GROUP_ROSTER_UPDATE" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT"
      or event == "ARENA_OPPONENT_UPDATE" or event == "UNIT_PET"
  end,
  pet = function(event, unit) return event == "UNIT_PET" and unit == "player" end,
  target = function(event) return event == "PLAYER_TARGET_CHANGED" end,
  targettarget = function(event, unit)
    return event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_TARGET" and unit == "target")
  end,
  focus = function(event) return event == "PLAYER_FOCUS_CHANGED" end,
  focustarget = function(event, unit)
    return event == "PLAYER_FOCUS_CHANGED" or (event == "UNIT_TARGET" and unit == "focus")
  end,
  mouseover = function(event) return event == "UPDATE_MOUSEOVER_UNIT" end,
  boss = function(event) return event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" end,
  arena = function(event) return event == "ARENA_OPPONENT_UPDATE" end,
}

local ModeBoundEvents = {
  GROUP_ROSTER_UPDATE = true, PLAYER_ROLES_ASSIGNED = true, PLAYER_TARGET_CHANGED = true,
  PLAYER_FOCUS_CHANGED = true, UPDATE_MOUSEOVER_UNIT = true, INSTANCE_ENCOUNTER_ENGAGE_UNIT = true,
  ARENA_OPPONENT_UPDATE = true, UNIT_NAME_UPDATE = true, UNIT_TARGET = true, UNIT_PET = true,
  PLAYER_REGEN_ENABLED = true, ADDON_RESTRICTION_STATE_CHANGED = true,
}

function Events.WantsUnitUpdate(triggerConfig, event, unit)
  if not ModeBoundEvents[event] then return true end
  local rule = UnitModeRules[triggerConfig.unit]
  return rule ~= nil and rule(event, unit, triggerConfig) and true or false
end

function Events.WantsSounds(triggerConfig, event)
  if not SOUND_UNITS[triggerConfig.unit] then return false end
  return event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED"
    or (event == "UNIT_NAME_UPDATE" and triggerConfig.useUnitNames)
    or (event == "UNIT_PET" and triggerConfig.use_includePets) and true or false
end

local plateRefreshes = {
  NAME_PLATE_UNIT_ADDED = function(auraRegion, unit) Units.Refresh(auraRegion, nil, unit) end,
  NAME_PLATE_UNIT_REMOVED = function(auraRegion, unit) Units.Refresh(auraRegion, unit, unit) end,
}

function Events.HandleRegion(auraRegion, event, unit)
  local state = auraRegion.blizzardAuraDisplay
  local triggerConfig = Display.GetTrigger(state.data)
  if not triggerConfig then return end
  local plateRefresh = plateRefreshes[event]
  if plateRefresh then
    if not Display.UsesNameplates(state.data) then return end
    if triggerConfig.unit == "nameplate" then
      plateRefresh(auraRegion, unit)
    else
      Units.Refresh(auraRegion)
    end
    return
  end
  if Events.WantsUnitUpdate(triggerConfig, event, unit) and not (queuedApplies[auraRegion] and not WeakAuras.IsRestricted()) then
    Units.Refresh(auraRegion)
  end
  if Events.WantsSounds(triggerConfig, event) then SyncSounds(auraRegion) end
end

local currentEvent, currentUnit
local function DispatchEvent()
  local event, unit = currentEvent, currentUnit
  Display.BeginFlowBatch()
  xpcall(function()
    for auraRegion in pairs(liveRegions) do Events.HandleRegion(auraRegion, event, unit) end
  end, geterrorhandler())
  Display.EndFlowBatch()
end

local beforeDispatch = {
  NAME_PLATE_UNIT_ADDED = function(unit) Plates.Note(unit) end,
  PLAYER_ENTERING_WORLD = function() C_Timer.After(0, Plates.ReadShown) end,
}
local rescaleEvents = { UI_SCALE_CHANGED = true, DISPLAY_SIZE_CHANGED = true }
local afterDispatch = {
  PLAYER_REGEN_ENABLED = function() Units.ReplayLocked() end,
}
local conditionRefreshEvents = {
  PLAYER_REGEN_ENABLED = true, ADDON_RESTRICTION_STATE_CHANGED = true, PLAYER_ENTERING_WORLD = true,
}

function Events.OnMainEvent(_, event, unit)
  local prepare = beforeDispatch[event]
  if prepare then prepare(unit) end
  if rescaleEvents[event] then
    for auraRegion in pairs(liveRegions) do Display.Apply(auraRegion, auraRegion.blizzardAuraDisplay.data) end
    return
  end
  currentEvent, currentUnit = event, unit
  DispatchEvent()
  local replay = afterDispatch[event]
  if replay then replay() end
  if WeakAuras.IsRestricted() then return end
  if conditionRefreshEvents[event] then
    for auraRegion in pairs(liveRegions) do Display.RefreshConditionAppearance(auraRegion) end
  end
  FlushPendingSounds()
  Queues.StartApplies()
end

local statusUnit
local function HandleStatusChange() Units.OnStatusChange(statusUnit) end

function Events.OnStatusEvent(_, _, unit)
  statusUnit = unit
  Display.BeginFlowBatch()
  local ok, message = xpcall(HandleStatusChange, geterrorhandler())
  Display.EndFlowBatch()
  return ok, message
end

local mainFrame = CreateFrame("Frame")
for _, event in ipairs({
  "PLAYER_REGEN_ENABLED", "ADDON_RESTRICTION_STATE_CHANGED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
  "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED",
  "UPDATE_MOUSEOVER_UNIT", "UNIT_TARGET", "UNIT_PET", "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
  "ARENA_OPPONENT_UPDATE", "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "UNIT_NAME_UPDATE",
  "PLAYER_ROLES_ASSIGNED",
}) do
  pcall(mainFrame.RegisterEvent, mainFrame, event)
end
mainFrame:SetScript("OnEvent", Events.OnMainEvent)

local statusFrame = CreateFrame("Frame")
for _, event in ipairs({ "UNIT_HEALTH", "UNIT_FLAGS", "UNIT_CONNECTION" }) do
  pcall(statusFrame.RegisterEvent, statusFrame, event)
end
statusFrame:SetScript("OnEvent", Events.OnStatusEvent)

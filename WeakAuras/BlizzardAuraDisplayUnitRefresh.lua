-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Anchor = Private.AuraAnchor
local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local AttachModes = Shared.AttachModes
local Buttons = Shared.Buttons
local GROUP_UNITS = Shared.GROUP_UNITS
local Glow = Shared.Glow
local InPreview = Shared.InPreview
local Parts = Shared.Parts
local PendingSet = Shared.PendingSet
local PlaceInstance = Shared.PlaceInstance
local ReadLevel = Shared.ReadLevel
local RefreshPreviewNotice = Shared.RefreshPreviewNotice
local Units = Shared.Units
local UsesUnitFrames = Shared.UsesUnitFrames
local liveRegions = Shared.liveRegions
local lockedRegions = Shared.lockedRegions

function Units.Status(triggerConfig, unitId)
  if unitId == nil or not GROUP_UNITS[triggerConfig.unit] then return false end
  local connectedFlag, hasConnected
  if triggerConfig.ignoreDisconnected then
    local connected = UnitIsConnected(unitId)
    if issecretvalue(connected) then
      connectedFlag, hasConnected = connected, true
    elseif not connected then
      return true
    end
  end
  if triggerConfig.ignoreDead then
    local dead = UnitIsDeadOrGhost(unitId)
    if issecretvalue(dead) then
      if hasConnected then return false, nil, connectedFlag, false, true end
      return false, dead, nil, true, false
    elseif dead then
      return true
    end
  end
  return false, nil, connectedFlag, false, hasConnected or false
end

function Display.UnitIgnored(triggerConfig, unitId)
  local isIgnored, secretDead, secretConnected = Units.Status(triggerConfig, unitId)
  return isIgnored, secretDead, secretConnected
end

function Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)
  local holder, base = unitEntry.container, unitEntry.containerAlpha or 1
  unitEntry.statusSecret = (hasDead or hasConnected) and true or false
  if hasDead then
    holder:SetAlphaFromBoolean(secretDead, 0, base)
  elseif hasConnected then
    holder:SetAlphaFromBoolean(secretConnected, base, 0)
  else
    holder:SetAlpha(base)
  end
end

function Units.RefreshPreview(auraRegion, state)
  local previewing = InPreview()
  local auraData = state.data
  state.previewHasAuras = previewing
  if previewing then
    if not (auraRegion.secretAuraSamplesActive and state.previewStyled == auraData) then
      Display.ShowPreview(auraRegion, auraData, Buttons.StyleSample)
      state.previewStyled = auraData
    end
    Display.ArrangeFlowPreview(Display.FlowGroup(auraData))
  else
    Display.RestorePreviewRegion(auraRegion)
    Display.RestoreGroupPreview(Display.FlowGroup(auraData))
    Display.HidePreview(auraRegion)
  end
  Parts.Hide(auraRegion)
  if previewing then RefreshPreviewNotice(auraRegion) end
end

function Units.RefreshInstance(auraRegion, state, position, unitEntry, units, growth, flowMode, droppedUnit)
  local auraData = state.data
  local holder = unitEntry.container
  if state.gridMember then
    unitEntry.visible = false
    unitEntry.statusHidden = nil
    holder:SetEnabled(false)
    holder:Hide()
    Display.RefreshSingle(unitEntry, nil, false)
    Display.RefreshFlowShadow(unitEntry, nil, false)
    return
  end
  local triggerConfig = Display.GetTrigger(auraData)
  local unitId = units[position]
  local unitFrameMode, plateMode = AttachModes(auraData, flowMode)
  local anchorFrame = Anchor.LocateAnchor(unitId, unitFrameMode, plateMode, droppedUnit)

  local isIgnored, secretDead, secretConnected, hasDead, hasConnected = Units.Status(triggerConfig or {}, unitId)
  unitEntry.statusHidden = isIgnored
  local isShown = (not InPreview() and unitId ~= nil and auraRegion:IsShown() and not isIgnored
    and (not (unitFrameMode or plateMode) or anchorFrame ~= nil)) and true or false

  local parent = auraRegion
  if unitFrameMode and auraData.anchorFrameParent ~= false and anchorFrame then parent = anchorFrame end
  Anchor.Rebind(unitEntry, holder, unitId, parent)

  local locked = Anchor.Locked(holder)
  if locked then lockedRegions[auraRegion] = true end
  if parent == auraRegion then
    unitEntry.containerAlpha = 1
  else
    unitEntry.containerAlpha = auraData.alpha or 1
  end
  Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)

  if not locked then
    PlaceInstance(auraRegion, unitEntry, auraData, position, parent, anchorFrame, unitFrameMode, plateMode, growth)
    unitEntry.visible = isShown
    holder:SetShown(isShown)
    holder:SetEnabled(isShown)
    if isShown then holder:UpdateAllAuras() end
  end
  Display.RefreshSingle(unitEntry, unitId, isShown)
  Display.RefreshFlowShadow(unitEntry, unitId, isShown)
  if unitEntry.unitGlow then Glow.Refresh(auraRegion, state, unitEntry, unitId, anchorFrame, unitFrameMode) end
end

function Units.Refresh(auraRegion, droppedUnit, updatedUnit)
  local state = auraRegion.blizzardAuraDisplay
  if not (state and state.active) then return end
  if state.instanceQueue and not InPreview() then Display.FlushInstanceQueue(auraRegion) end
  local auraData = state.data
  local triggerConfig = Display.GetTrigger(auraData)
  if not triggerConfig then return end
  local units = Display.UnitTokens(triggerConfig)
  local growth = Display.Growth(auraData)
  local flowMode = Display.FlowFrameMode(auraData)
  for position, unitEntry in ipairs(state.instances) do
    if not updatedUnit or units[position] == updatedUnit then
      Units.RefreshInstance(auraRegion, state, position, unitEntry, units, growth, flowMode, droppedUnit)
    end
  end
  Display.RefreshFlowUnits(Display.FlowGroup(auraData), droppedUnit)
  Display.UpdateDetachedFrameLevels(auraRegion)
  Units.RefreshPreview(auraRegion, state)
end

function Units.ReplayLocked()
  for _, auraRegion in ipairs(PendingSet(lockedRegions)) do
    lockedRegions[auraRegion] = nil
    if liveRegions[auraRegion] then Units.Refresh(auraRegion) end
  end
end

function Units.OnStatusChange(unit)
  for auraRegion in pairs(liveRegions) do
    local state = auraRegion.blizzardAuraDisplay
    local triggerConfig = Display.GetTrigger(state.data)
    if triggerConfig and (triggerConfig.ignoreDead or triggerConfig.ignoreDisconnected) then
      if state.gridMember then
        local ignored = Units.Status(triggerConfig, unit)
        local gridIgnored = state.gridIgnored
        if not gridIgnored then
          gridIgnored = {}
          state.gridIgnored = gridIgnored
        end
        if ignored ~= (gridIgnored[unit] or false) then
          gridIgnored[unit] = ignored
          Display.RefreshFlowUnits(Display.FlowGroup(state.data))
        end
      else
        for _, unitEntry in ipairs(state.instances) do
          if unitEntry.boundUnit == unit then
            local ignored, secretDead, secretConnected, hasDead, hasConnected = Units.Status(triggerConfig, unit)
            if ignored ~= unitEntry.statusHidden then
              Units.Refresh(auraRegion, nil, unit)
              break
            elseif hasDead or hasConnected or unitEntry.statusSecret then
              Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)
            end
          end
        end
      end
    end
  end
end

local framesPending = false

local function RefreshUnitFrameRegions()
  framesPending = false
  for auraRegion in pairs(liveRegions) do
    local state = auraRegion.blizzardAuraDisplay
    if UsesUnitFrames(state.data) then Units.Refresh(auraRegion) end
  end
end

function Display.UnitFramesChanged()
  if framesPending then return end
  local used = false
  for auraRegion in pairs(liveRegions) do
    if UsesUnitFrames(auraRegion.blizzardAuraDisplay.data) then
      used = true
      break
    end
  end
  if not used then return end
  framesPending = true
  C_Timer.After(0, RefreshUnitFrameRegions)
end

function Display.UpdateDetachedFrameLevels(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  if not (state and state.active) then return end
  local base = ReadLevel(auraRegion)
  if not base then return end
  for _, unitEntry in ipairs(state.instances) do
    local level = ReadLevel(unitEntry.container)
    if level and level > base then base = level end
  end
  base = base + 3 * #(state.data.subRegions or {}) + 8
  for index, subRegion in ipairs(auraRegion.subRegions or {}) do
    if subRegion.secretAuraDetached then subRegion:SetFrameLevel(base + index) end
  end
end

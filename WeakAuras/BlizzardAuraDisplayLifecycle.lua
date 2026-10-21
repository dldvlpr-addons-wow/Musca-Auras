-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local AURA_GROUP = Shared.AURA_GROUP
local Buttons = Shared.Buttons
local EDITOR_FIRST_BATCH = Shared.EDITOR_FIRST_BATCH
local ForgetClassifiedTriggers = Shared.ForgetClassifiedTriggers
local InPreview = Shared.InPreview
local Instances = Shared.Instances
local PENDING_TEXT = Shared.PENDING_TEXT
local Parts = Shared.Parts
local Queues = Shared.Queues
local RefreshPreviewNotice = Shared.RefreshPreviewNotice
local SlotCount = Shared.SlotCount
local SyncSounds = Shared.SyncSounds
local Units = Shared.Units
local Warn = Shared.Warn
local liveRegions = Shared.liveRegions
local queuedApplies = Shared.queuedApplies

local function ProgressSourceKey(auraData)
  if not Display.GetTrigger(auraData) then return 0 end
  local source = auraData.progressSource
  local key = type(source) == "table" and tonumber(source[1]) or -1
  if key < 0 then
    local mode = auraData.triggers and auraData.triggers.activeTriggerMode
    if type(mode) == "number" and mode > 0 then
      key = mode
    elseif Private.GetActiveTriggerFor then
      key = Private.GetActiveTriggerFor(auraData.id) or 1
    else
      key = 1
    end
  end
  return key
end

local function CreateState(auraRegion)
  local state = { instances = {}, generation = 0, active = false }
  auraRegion.blizzardAuraDisplay = state
  auraRegion:HookScript("OnHide", function()
    Display.HideUnitGlows(auraRegion)
    for _, unitEntry in ipairs(state.instances) do
      unitEntry.container:SetEnabled(false)
      unitEntry.container:Hide()
      Display.RefreshSingle(unitEntry, nil, false)
    end
    if state.gridMember then Display.RefreshFlowUnits(Display.FlowGroup(state.data)) end
    SyncSounds(auraRegion)
  end)
  auraRegion:HookScript("OnShow", function()
    state.unitGlowsHidden = false
    if state.active then
      Units.Refresh(auraRegion)
      SyncSounds(auraRegion)
    end
  end)
  return state
end

function Display.Apply(auraRegion, auraData)
  if Display.Enabled(auraData) and Display.InDynamicGroup(auraData) then
    Warn(auraData, "blizzard_aura_dynamicgroup", Display.dynamicGroupWarning)
  else
    Warn(auraData, "blizzard_aura_dynamicgroup")
  end
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion, true)
    Warn(auraData, "blizzard_aura_display")
    Warn(auraData, "blizzard_aura_sound")
    return
  end
  Parts.Hide(auraRegion)
  local problem = Display.Validate(auraData)
  if problem then
    Display.Release(auraRegion, true)
    Warn(auraData, "blizzard_aura_display", problem)
    return
  end

  local previewing = InPreview()
  if previewing then
    Display.ShowPreview(auraRegion, auraData, Buttons.StyleSample)
    Display.ArrangeFlowPreview(Display.FlowGroup(auraData))
    Parts.Hide(auraRegion)
  else
    Display.HidePreview(auraRegion)
    Display.RestorePreviewRegion(auraRegion)
    Display.RestoreGroupPreview(Display.FlowGroup(auraData))
  end

  if WeakAuras.IsRestricted() then
    queuedApplies[auraRegion] = auraData
    Warn(auraData, "blizzard_aura_display", PENDING_TEXT)
    return
  end
  if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
    local addonLoaded, failReason = C_AddOns.LoadAddOn("Blizzard_AuraContainer")
    if not addonLoaded then
      Warn(auraData, "blizzard_aura_display", "Cannot load Blizzard_AuraContainer: " .. tostring(failReason))
      return
    end
  end

  local state = auraRegion.blizzardAuraDisplay or CreateState(auraRegion)
  local previousMember = state.gridMember
  state.data = auraData
  state.gridMember = Display.GridMember(auraData)
  state.generation = state.generation + 1
  Display.EnsureFlowStart(auraRegion, auraData)
  state.previewStyled = previewing and auraData or nil
  if previewing then RefreshPreviewNotice(auraRegion) end
  state.unitGlowsHidden = false

  local instances = state.instances
  local flowGroup = Display.FlowGroup(auraData)
  if instances[1] and instances[1].flowContainer ~= (flowGroup ~= nil) then Instances.RemoveAll(state) end

  local count = SlotCount(Display.GetTrigger(auraData))
  Display.ClearSingleWarning(auraData)
  local created = {}
  for position = #instances + 1, count do
    local unitEntry = Instances.Create(auraRegion, auraData)
    instances[position] = unitEntry
    created[unitEntry] = true
  end
  for position = #instances, count + 1, -1 do
    Instances.Remove(instances[position])
    instances[position] = nil
  end

  state.instanceQueue = nil
  Queues.instanceRegions[auraRegion] = nil
  local immediate = count
  if previewing and count > EDITOR_FIRST_BATCH then
    immediate = EDITOR_FIRST_BATCH
    state.instanceQueue = { data = auraData, nextIndex = EDITOR_FIRST_BATCH + 1 }
    Queues.instanceRegions[auraRegion] = true
  end
  for position = 1, immediate do
    local unitEntry = instances[position]
    Instances.Configure(auraRegion, state, position, unitEntry, not created[unitEntry])
  end

  state.active = true
  state.appliedTrigger = Display.GetSavedTrigger(auraData)
  liveRegions[auraRegion] = true

  Display.EnsureFlowShadows(auraRegion, auraData)
  local missing = instances[1] and instances[1].single and instances[1].single.missing
  Display.SetFlowEnd(auraRegion, auraData, missing and missing.active and missing.presenceActive and missing.presence or nil)
  Display.RechainFlow(flowGroup or (previousMember and auraData.parent and WeakAuras.GetData(auraData.parent)) or nil)

  Units.Refresh(auraRegion)
  queuedApplies[auraRegion] = nil
  SyncSounds(auraRegion)
  Warn(auraData, "blizzard_aura_display")
  if state.instanceQueue then Queues.StartInstanceDrain() end
end

function Display.Activate(auraRegion, auraData)
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion, true)
    return
  end
  Parts.Wrap(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  local triggerConfig = Display.GetTrigger(auraData)
  if state and triggerConfig and state.data == auraData and not queuedApplies[auraRegion]
    and Display.Validate(auraData) == nil and Display.GridMember(auraData) == state.gridMember
    and #state.instances == SlotCount(triggerConfig) then
    Display.FlushInstanceQueue(auraRegion)
    Display.WatchAuraLearning(auraRegion, auraData, triggerConfig, (Display.LateGlowSpec(auraData, triggerConfig)))
    state.unitGlowsHidden = false
    state.active = true
    liveRegions[auraRegion] = true
    Display.RechainFlow(Display.FlowGroup(auraData))
    Units.Refresh(auraRegion)
    SyncSounds(auraRegion)
  else
    Display.Apply(auraRegion, auraData)
  end
end

function Display.Release(auraRegion, leaveGrid)
  Display.ReleaseAuraLearning(auraRegion)
  Display.HideUnitGlows(auraRegion)
  Display.Restore(auraRegion)
  queuedApplies[auraRegion] = nil
  Display.CancelEditorApply(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  if not state then return end
  state.active = false
  if leaveGrid then state.gridMember = nil end
  state.instanceQueue = nil
  Queues.instanceRegions[auraRegion] = nil
  for _, unitEntry in ipairs(state.instances) do
    unitEntry.container:SetEnabled(false)
    unitEntry.container:Hide()
    Display.RefreshSingle(unitEntry, nil, false)
  end
  local auraData = state.data
  if auraData then
    Warn(auraData, "blizzard_aura_single")
    Warn(auraData, "blizzard_aura_dynamicgroup")
    Warn(auraData, "blizzard_aura_grid")
  end
  liveRegions[auraRegion] = nil
  SyncSounds(auraRegion)
  if auraData then Display.RechainFlow(Display.FlowGroup(auraData)) end
end

function Display.Modify(auraRegion, auraData)
  ForgetClassifiedTriggers(auraData)
  Display.ForgetConditionRules(auraData)
  auraRegion.secretAuraProgressSourceIndex = ProgressSourceKey(auraData)
  auraRegion.secretAuraConditionValues = nil
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion, true)
    Warn(auraData, "blizzard_aura_display")
    Warn(auraData, "blizzard_aura_sound")
    return
  end
  Parts.Wrap(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  if WeakAuras.IsOptionsOpen() and state and state.active and state.data == auraData and not WeakAuras.IsRestricted() then
    Queues.editorPending[auraRegion] = auraData
    if not Queues.editorDraining then
      Queues.editorDraining = true
      C_Timer.After(0, Queues.EditorPass)
    end
    return
  end
  Queues.editorPending[auraRegion] = nil
  Display.Apply(auraRegion, auraData)
end

function Display.SyncProgressSource(auraRegion, auraData)
  if not auraData then return end
  local key = ProgressSourceKey(auraData)
  if auraRegion.secretAuraProgressSourceIndex == key then return end
  local state = auraRegion.blizzardAuraDisplay
  if state and state.data == auraData and state.appliedTrigger == Display.GetSavedTrigger(auraData) then
    auraRegion.secretAuraProgressSourceIndex = key
    if not state.active then Display.Activate(auraRegion, auraData) end
    return
  end
  Display.Modify(auraRegion, auraData)
end

function Display.ApplyFlowSort(group)
  if WeakAuras.IsRestricted() then return false end
  local targets = {}
  for _, childId in ipairs(group.controlledChildren or {}) do
    local childAura = WeakAuras.GetRegion(childId)
    local state = childAura and childAura.blizzardAuraDisplay
    local auraData = WeakAuras.GetData(childId)
    if state and auraData and state.data == auraData then
      if not state.active or state.gridMember then return false end
      local triggerConfig = Display.GetTrigger(auraData)
      if not triggerConfig or Display.IsSingle(triggerConfig, auraData) then return false end
      for _, unitEntry in ipairs(state.instances) do
        if unitEntry.unitGlow then return false end
        targets[#targets + 1] = { unitEntry.container, auraData, triggerConfig }
      end
    end
  end
  for _, target in ipairs(targets) do
    target[1]:SetAuraGroupSortMethod(AURA_GROUP, Display.SortOrder(target[2], target[3]))
  end
  return true
end

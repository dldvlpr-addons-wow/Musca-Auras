if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local job = {wanted = nil, timer = nil, reloadNeeded = nil, tries = 0}
local VIEWER_KEYS = {"Essential", "Utility", "BuffIcon", "BuffBar"}
local runStep

StaticPopupDialogs["WEAKAURAS_CDM_SETUP_RELOAD"] = {
  text = "WeakAuras has changed CDM settings. Reload to apply them.",
  button1 = RELOADUI, button2 = LATER,
  OnAccept = function() ReloadUI() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

local function backupFor(guid, enabling, hiding)
  local store = Private.db.cdmClassPackSetupBackups
  if not store then
    store = {}
    Private.db.cdmClassPackSetupBackups = store
  end
  if store[guid] then return end
  store[guid] = {
    cooldownLayout = C_CooldownViewer.GetLayoutData(),
    editLayouts = C_EditMode.GetLayouts(),
    enabled = not enabling,
    hideBlizzard = not hiding,
  }
end

local function stageVisibility()
  local state = C_EditMode.GetLayouts()
  local builtIn = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
  local merged = CopyTable(builtIn)
  for _, entry in ipairs(state.layouts) do
    table.insert(merged, CopyTable(entry))
  end
  local current = merged[state.activeLayout]
  if not current then error("The active Edit Mode layout is not ready.") end

  local indexOf = Enum.EditModeCooldownViewerSystemIndices
  local tracked = {}
  for _, viewerName in ipairs(VIEWER_KEYS) do tracked[indexOf[viewerName]] = true end
  local function isViewer(frameSystem)
    return frameSystem.system == Enum.EditModeSystem.CooldownViewer and tracked[frameSystem.systemIndex]
  end

  local edits = 0
  local found = {}
  local currentSystems = current.systems
  for _, frameSystem in ipairs(currentSystems) do
    if isViewer(frameSystem) then found[frameSystem.systemIndex] = true end
  end
  local defaultSystems = builtIn[1].systems
  for _, frameSystem in ipairs(defaultSystems) do
    if isViewer(frameSystem) and not found[frameSystem.systemIndex] then
      table.insert(current.systems, CopyTable(frameSystem))
      found[frameSystem.systemIndex] = true
      edits = edits + 1
    end
  end
  for _, viewerName in ipairs(VIEWER_KEYS) do
    if not found[indexOf[viewerName]] then error("Edit Mode has no settings for " .. viewerName .. ".") end
  end

  local visibilityId = Enum.EditModeCooldownViewerSetting.VisibleSetting
  local alwaysShown = Enum.CooldownViewerVisibleSetting.Always
  for _, frameSystem in ipairs(current.systems) do
    if isViewer(frameSystem) then
      local hasVisibility = false
      for _, option in ipairs(frameSystem.settings) do
        if option.setting == visibilityId then
          hasVisibility = true
          if option.value ~= alwaysShown then
            option.value = alwaysShown
            edits = edits + 1
          end
        end
      end
      if not hasVisibility then
        table.insert(frameSystem.settings, {setting = visibilityId, value = alwaysShown})
        edits = edits + 1
      end
    end
  end
  if edits == 0 then return end

  if current.layoutType == Enum.EditModeLayoutType.Preset then
    local usedNames = {}
    for _, entry in ipairs(merged) do usedNames[entry.layoutName] = true end
    local candidate, counter = "WeakAuras", 1
    while usedNames[candidate] do
      counter = counter + 1
      candidate = "WeakAuras " .. counter
    end
    local personal = CopyTable(current)
    personal.layoutType = Enum.EditModeLayoutType.Character
    personal.layoutName = candidate
    local activeIndex = state.activeLayout
    merged[activeIndex] = builtIn[activeIndex]
    table.insert(merged, personal)
    state.activeLayout = #merged
  end
  state.layouts = merged
  return state
end

local function moveEntries(dataProvider, fromCategory, toCategory, accepts, label)
  local count = 0
  for _, cooldownID in ipairs(C_CooldownViewer.GetCooldownViewerCategorySet(fromCategory, true)) do
    local entry = dataProvider:GetCooldownInfoForID(cooldownID)
    if entry and accepts(entry) then
      local status = dataProvider:SetCooldownToCategory(cooldownID, toCategory)
      if status ~= Enum.CooldownLayoutStatus.Success then
        error("Could not update " .. label .. " (layout status " .. tostring(status) .. ").")
      end
      count = count + 1
    end
  end
  return count
end

local function stageLayout()
  local dataProvider = CreateFromMixins(CooldownViewerSettingsDataProviderMixin)
  local layoutManager = CreateFromMixins(CooldownViewerLayoutManagerMixin)
  local layoutSerializer = CreateFromMixins(CooldownViewerDataStoreSerializationMixin)
  layoutManager.SetHasPendingChanges = function(self, flag) self.hasPendingChanges = flag end
  layoutManager.NotifyListeners = function() end
  layoutManager:Init(dataProvider, layoutSerializer)
  dataProvider:SetLayoutManager(layoutManager)
  layoutSerializer:Init(layoutManager)
  layoutManager:SwitchToBestLayoutForSpec()
  dataProvider:CheckBuildDisplayData()
  layoutManager:SetShouldCheckAddLayoutStatus(true)
  layoutManager:SetHasPendingChanges(false)

  local categories = Enum.CooldownViewerCategory
  local buffCategory = categories.TrackedBuff
  local function notBuff(entry)
    return entry.category ~= buffCategory
  end
  local buffCount = 0
  local buffSources = {"TrackedBuff", "TrackedBar", "EquipSlotTracked", "SpecAgnosticTracked"}
  for _, categoryName in ipairs(buffSources) do
    local fromCategory = categories[categoryName]
    if fromCategory then
      buffCount = buffCount + moveEntries(dataProvider, fromCategory, buffCategory, notBuff, "Tracked Buffs")
    end
  end

  local function hiddenSpell(entry)
    if entry.category ~= categories.HiddenActive then return false end
    local spellID = entry.spellID
    return type(spellID) == "number" and spellID > 0 and entry.equipSlot == nil and entry.spellCategoryID == nil
  end
  local spellCount = 0
  local spellSources = {"Essential", "Utility"}
  for _, categoryName in ipairs(spellSources) do
    local fromCategory = categories[categoryName]
    spellCount = spellCount + moveEntries(dataProvider, fromCategory, fromCategory, hiddenSpell, categoryName .. " cooldowns")
  end

  local blob = nil
  if buffCount + spellCount > 0 then blob = layoutSerializer:SerializeLayouts() or nil end
  return blob, buffCount, spellCount
end

local function applySetup()
  local settingsFrame = CooldownViewerSettings
  if not settingsFrame or not settingsFrame.GetDataProvider or not settingsFrame.GetLayoutManager then return false end
  local liveManager = settingsFrame:GetLayoutManager()
  if not liveManager or not liveManager:IsLoaded() then return false end
  if settingsFrame:IsShown() or EditModeManagerFrame:IsShown() or liveManager:HasPendingChanges() then return false end
  if not (C_EditMode and EditModePresetLayoutManager and CooldownViewerDataStoreSerializationMixin) then
    error("This client does not expose the required CDM layout APIs.")
  end

  local blob, buffCount, spellCount = stageLayout()
  local pendingLayouts = stageVisibility()
  local enabling = not C_CVar.GetCVarBool("cooldownViewerEnabled")
  local hiding = Private.db.cdmHideBlizzard ~= true
  if not (blob or pendingLayouts or enabling or hiding) then return true end

  local guid = UnitGUID("player")
  if issecretvalue(guid) or type(guid) ~= "string" then error("The character is not ready for CDM setup.") end
  backupFor(guid, enabling, hiding)
  job.reloadNeeded = true

  if blob then
    C_CooldownViewer.SetLayoutData(blob)
    local stored = C_CooldownViewer.GetLayoutData()
    if stored ~= blob then error("CDM did not save the layout.") end
  end
  if pendingLayouts then
    C_EditMode.SaveLayouts(pendingLayouts)
    C_EditMode.SetActiveLayout(pendingLayouts.activeLayout)
    if stageVisibility() then error("Edit Mode did not save CDM visibility.") end
  end
  Private.db.cdmHideBlizzard = true
  if enabling then C_CVar.SetCVar("cooldownViewerEnabled", "1") end
  Private.ApplyCDMBackground()
  print("WeakAuras: CDM setup saved. " .. buffCount .. " buffs and " .. spellCount .. " spell cooldowns added. Reload to apply.")
  StaticPopup_Show("WEAKAURAS_CDM_SETUP_RELOAD")
  return true
end

local function schedule(delay)
  job.timer = C_Timer.NewTimer(delay, runStep)
end

local function giveUp(message)
  job.wanted = nil
  print(message)
end

runStep = function()
  job.timer = nil
  if not job.wanted or job.reloadNeeded or InCombatLockdown() then return end
  job.tries = job.tries + 1
  local succeeded, outcome = pcall(applySetup)
  if succeeded then
    if outcome then
      job.wanted = nil
    elseif job.tries < 60 then
      schedule(1)
    else
      giveUp("WeakAuras: CDM setup is waiting for saved layouts. Close CDM and Edit Mode settings, then reload to retry.")
    end
    return
  end
  giveUp("WeakAuras: CDM setup stopped: " .. tostring(outcome))
  if job.reloadNeeded then StaticPopup_Show("WEAKAURAS_CDM_SETUP_RELOAD") end
end

function WeakAuras.SetupClassPackCDM(requested)
  local _, ownClass = UnitClass("player")
  if type(requested) ~= "string" or requested ~= ownClass then return false end
  if not job.reloadNeeded then
    if not job.wanted then job.tries = 0 end
    job.wanted = true
    if not job.timer then schedule(0) end
  end
  return true
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
watcher:SetScript("OnEvent", function()
  if job.wanted and not job.reloadNeeded and not job.timer then schedule(0) end
end)

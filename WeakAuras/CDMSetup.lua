-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end


local _, Private = ...

local MAX_ATTEMPTS = 60
local RETRY_DELAY = 1
local POPUP_NAME = "WEAKAURAS_CDM_SETUP_RELOAD"
local LAYOUT_NAME = "WeakAuras"
local CVAR_NAME = "cooldownViewerEnabled"
local VIEWER_KEYS = { "Essential", "Utility", "BuffIcon", "BuffBar" }
local BUFF_SOURCES = { "TrackedBuff", "TrackedBar", "EquipSlotTracked", "SpecAgnosticTracked" }
local SPELL_SOURCES = { "Essential", "Utility" }

local function DoNothing() end
local function ReloadNow() ReloadUI() end

local state = { phase = "idle", timer = nil, attempts = 0 }

StaticPopupDialogs[POPUP_NAME] = {
  text = "The Cooldown Manager configuration was updated by WeakAuras. Reload the UI to finish.",
  button1 = RELOADUI,
  button2 = LATER,
  OnAccept = ReloadNow,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

local function ShowReloadPopup()
  StaticPopup_Show(POPUP_NAME)
end

local function Shallow(source)
  local copy = {}
  for key, value in pairs(source) do copy[key] = value end
  return copy
end

local function IsLiveUIReady()
  local live = CooldownViewerSettings
  local manager = live and live.GetLayoutManager and live:GetLayoutManager()
  if not manager or manager:HasPendingChanges() then return false end
  local editMode = EditModeManagerFrame
  if (editMode and editMode:IsShown()) or live:IsShown() then return false end
  return manager:IsLoaded() and true or false
end

local function BuildDetachedLayout()
  local provider = Shallow(CooldownViewerSettingsDataProviderMixin)
  local manager = Shallow(CooldownViewerLayoutManagerMixin)
  local serializer = Shallow(CooldownViewerDataStoreSerializationMixin)
  manager.SetHasPendingChanges = function(self, pending)
    self.hasPendingChanges = pending
  end
  manager.NotifyListeners = DoNothing
  manager:Init(provider, serializer)
  serializer:Init(manager)
  provider:SetLayoutManager(manager)
  manager:SwitchToBestLayoutForSpec()
  provider:CheckBuildDisplayData()
  manager:SetShouldCheckAddLayoutStatus(true)
  manager:SetHasPendingChanges(false)
  return provider, serializer
end

local function MoveCooldown(provider, id, category)
  local result = provider:SetCooldownToCategory(id, category)
  if result == Enum.CooldownLayoutStatus.Success then return end
  error(("could not move cooldown %s to category %s (status %s)"):format(tostring(id), tostring(category), tostring(result)), 0)
end

local function ForEachCooldown(provider, categoryKeys, visit)
  for position = 1, #categoryKeys do
    local category = Enum.CooldownViewerCategory[categoryKeys[position]]
    local ids = category ~= nil and C_CooldownViewer.GetCooldownViewerCategorySet(category, true) or {}
    for slot = 1, #ids do
      local id = ids[slot]
      local info = provider:GetCooldownInfoForID(id)
      if info then visit(id, info, category) end
    end
  end
end

local function ClassifySpell(info)
  if info.equipSlot ~= nil then return "equipment" end
  if info.spellCategoryID ~= nil then return "categorized" end
  local spellID = info.spellID
  if type(spellID) ~= "number" or spellID <= 0 then return "invalid" end
  return "plain"
end

local function PrepareCooldownLayout()
  local provider, serializer = BuildDetachedLayout()
  local categories = Enum.CooldownViewerCategory
  local buffs, spells = 0, 0

  ForEachCooldown(provider, BUFF_SOURCES, function(id, info)
    if info.category == categories.TrackedBuff then return end
    MoveCooldown(provider, id, categories.TrackedBuff)
    buffs = buffs + 1
  end)

  local hiddenCategory = categories.HiddenActive
  local unhideSources = hiddenCategory ~= nil and SPELL_SOURCES or {}
  ForEachCooldown(provider, unhideSources, function(id, info, category)
    if info.category ~= hiddenCategory or ClassifySpell(info) ~= "plain" then return end
    MoveCooldown(provider, id, category)
    spells = spells + 1
  end)

  if buffs + spells == 0 then return nil, 0, 0 end
  return serializer:SerializeLayouts(), buffs, spells
end

local function FindViewerSystem(layout, systemIndex)
  for _, entry in ipairs(layout.systems or {}) do
    if entry.system == Enum.EditModeSystem.CooldownViewer and entry.systemIndex == systemIndex then
      return entry
    end
  end
end

local function UniqueLayoutName(layouts)
  local usedNumbers = {}
  for _, layout in ipairs(layouts) do
    local name = layout.layoutName
    if name == LAYOUT_NAME then
      usedNumbers[1] = true
    elseif type(name) == "string" then
      local digits = name:match("^" .. LAYOUT_NAME .. " ([1-9]%d*)$")
      local number = digits and tonumber(digits)
      if number and number >= 2 then usedNumbers[number] = true end
    end
  end
  for number = 1, #layouts + 1 do
    if not usedNumbers[number] then
      return number == 1 and LAYOUT_NAME or ("%s %d"):format(LAYOUT_NAME, number)
    end
  end
end

local function AppendCopies(destination, source)
  for _, layout in ipairs(source) do destination[#destination + 1] = CopyTable(layout) end
end

local function EnsureViewerVisible(target, templateLayout, key)
  local systemIndex = Enum.EditModeCooldownViewerSystemIndices[key]
  local visibility = Enum.EditModeCooldownViewerSetting.VisibleSetting
  local wanted = Enum.CooldownViewerVisibleSetting.Always
  local edits = 0

  local entry = FindViewerSystem(target, systemIndex)
  if not entry then
    local template = templateLayout and FindViewerSystem(templateLayout, systemIndex)
    if not template then error("Edit Mode has no settings for " .. key .. ".", 0) end
    entry = CopyTable(template)
    target.systems = target.systems or {}
    target.systems[#target.systems + 1] = entry
    edits = edits + 1
  end

  entry.settings = entry.settings or {}
  local setting
  for _, option in ipairs(entry.settings) do
    if option.setting == visibility then setting = option break end
  end
  if not setting then
    entry.settings[#entry.settings + 1] = { setting = visibility, value = wanted }
    return edits + 1
  end
  if setting.value ~= wanted then
    setting.value = wanted
    edits = edits + 1
  end
  return edits
end

local function PrepareEditMode()
  local presetLayouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
  local current = C_EditMode.GetLayouts()

  local layouts = {}
  AppendCopies(layouts, presetLayouts)
  AppendCopies(layouts, current.layouts or {})

  local active = layouts[current.activeLayout]
  if not active then error("active layout not ready", 0) end

  local startsOnPreset = active.layoutType == Enum.EditModeLayoutType.Preset
  local target = active
  if startsOnPreset then target = CopyTable(active) end

  local edits = 0
  for _, key in ipairs(VIEWER_KEYS) do
    edits = edits + EnsureViewerVisible(target, presetLayouts[1], key)
  end
  if edits == 0 then return nil end

  current.layouts = layouts
  if startsOnPreset then
    target.layoutName = UniqueLayoutName(layouts)
    target.layoutType = Enum.EditModeLayoutType.Character
    table.insert(layouts, target)
    current.activeLayout = #layouts
  end
  return current
end

local function CaptureBackup(enabledBefore, hiddenBefore)
  return {
    enabled = enabledBefore,
    hideBlizzard = hiddenBefore,
    cooldownLayout = C_CooldownViewer.GetLayoutData(),
    editLayouts = CopyTable(C_EditMode.GetLayouts()),
  }
end

local function StoreBackup(guid, enabledBefore, hiddenBefore)
  local db = Private.db
  if type(db.cdmClassPackSetupBackups) ~= "table" then db.cdmClassPackSetupBackups = {} end
  local backups = db.cdmClassPackSetupBackups
  if backups[guid] ~= nil then return end
  backups[guid] = CaptureBackup(enabledBefore, hiddenBefore)
end

local function BuildPlan()
  local apis = { C_EditMode, EditModePresetLayoutManager, CooldownViewerDataStoreSerializationMixin }
  for index = 1, 3 do
    if not apis[index] then error("this client lacks the CDM layout APIs", 0) end
  end

  local blob, buffs, spells = PrepareCooldownLayout()
  local editState = PrepareEditMode()

  local cvarOff = false
  if C_CVar and C_CVar.GetCVarBool then cvarOff = not C_CVar.GetCVarBool(CVAR_NAME) end
  local db = Private.db
  local hideWasOn = db ~= nil and db.cdmHideBlizzard == true

  local candidates = {
    {
      due = blob ~= nil,
      apply = function() C_CooldownViewer.SetLayoutData(blob) end,
      verify = function() return C_CooldownViewer.GetLayoutData() == blob end,
      failure = "the game kept a different CDM layout than the one prepared",
    },
    {
      due = editState ~= nil,
      apply = function()
        C_EditMode.SaveLayouts(editState)
        C_EditMode.SetActiveLayout(editState.activeLayout)
      end,
      verify = function() return PrepareEditMode() == nil end,
      failure = "Edit Mode still reports CDM viewers that are not always visible",
    },
    {
      due = not hideWasOn,
      always = true,
      apply = function() db.cdmHideBlizzard = true end,
    },
    {
      due = cvarOff,
      apply = function() C_CVar.SetCVar(CVAR_NAME, "1") end,
    },
    {
      always = true,
      apply = function() Private.ApplyCDMBackground() end,
    },
  }

  local steps, anyDue = {}, false
  for _, candidate in ipairs(candidates) do
    anyDue = anyDue or candidate.due == true
  end
  if not anyDue then return nil end
  for _, candidate in ipairs(candidates) do
    if candidate.due or candidate.always then steps[#steps + 1] = candidate end
  end

  return {
    steps = steps, buffs = buffs, spells = spells,
    enabledBefore = not cvarOff, hiddenBefore = hideWasOn,
  }
end

local function Configure()
  if not IsLiveUIReady() then return false end

  local plan = BuildPlan()
  if not plan then return true end

  if not Private.db then error("saved variables not ready", 0) end
  local guid = UnitGUID("player")
  if type(guid) ~= "string" or (issecretvalue and issecretvalue(guid)) then
    error("character not ready", 0)
  end

  StoreBackup(guid, plan.enabledBefore, plan.hiddenBefore)
  state.phase = "locked"

  for _, step in ipairs(plan.steps) do
    step.apply()
    if step.verify and not step.verify() then error(step.failure, 0) end
  end

  print(("WeakAuras: CDM ready after a reload, %d buffs and %d spell cooldowns added."):format(plan.buffs, plan.spells))
  ShowReloadPopup()
  return true
end

local Schedule

local function Settle(succeeded, result)
  local notReady = succeeded and not result
  if notReady and state.attempts >= MAX_ATTEMPTS then
    state.phase = "idle"
    print("WeakAuras: gave up, the CDM is still waiting for saved layouts. Close its settings and Edit Mode, then reload.")
  elseif notReady then
    Schedule(RETRY_DELAY)
  elseif succeeded then
    if state.phase == "active" then state.phase = "idle" end
  else
    print("WeakAuras: CDM setup stopped: " .. tostring(result))
    if state.phase == "locked" then ShowReloadPopup() else state.phase = "idle" end
  end
end

local function Run()
  state.timer = nil
  if state.phase ~= "active" or InCombatLockdown() then return end
  state.attempts = state.attempts + 1
  Settle(pcall(Configure))
end

Schedule = function(delay)
  state.timer = C_Timer.NewTimer(delay, Run)
end

local function WakeUp()
  if state.phase == "active" and not state.timer then Schedule(0) end
end

function WeakAuras.SetupClassPackCDM(requested)
  local ownClass = select(2, UnitClass("player"))
  if not ownClass or requested ~= ownClass then return false end

  if state.phase == "idle" then
    state.attempts = 0
    state.phase = "active"
  end
  WakeUp()
  return true
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", WakeUp)

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Advance = test.Environment.Advance
  local _, ownClass = UnitClass("player")
  local guid = UnitGUID("player")

  local Category = Enum.CooldownViewerCategory
  local Indices = Enum.EditModeCooldownViewerSystemIndices
  local visibleId = Enum.EditModeCooldownViewerSetting.VisibleSetting
  local always = Enum.CooldownViewerVisibleSetting.Always
  local presetType, characterType = Enum.EditModeLayoutType.Preset, Enum.EditModeLayoutType.Character
  local savedStatus, savedHidden = Enum.CooldownLayoutStatus, Category.HiddenActive
  Enum.CooldownLayoutStatus = { Success = 0, Failure = 1 }
  Category.HiddenActive = 9

  local realViewer, realEditMode = C_CooldownViewer, C_EditMode
  local realPrint, realPopup, realBackground = print, StaticPopup_Show, private.ApplyCDMBackground
  local layoutData, entries, sets, moves, popups, messages, backgrounds
  local editLayouts, presetViewers, saved, activeCalls

  local function Entry(category, spellID, extra)
    local entry = { category = category, spellID = spellID }
    for key, value in pairs(extra or {}) do entry[key] = value end
    return entry
  end

  local function Reset()
    layoutData = "original-layout"
    entries = {
      [10] = Entry(Category.TrackedBuff, 1), [11] = Entry(Category.TrackedBar, 2), [12] = Entry(Category.TrackedBar, 3),
      [13] = Entry(Category.EquipSlotTracked, 4), [14] = Entry(Category.SpecAgnosticTracked, 5),
      [20] = Entry(Category.HiddenActive, 100), [21] = Entry(Category.HiddenActive, 0),
      [22] = Entry(Category.HiddenActive, 101, { equipSlot = 5 }), [23] = Entry(Category.HiddenActive, 102, { spellCategoryID = 7 }),
      [30] = Entry(Category.HiddenActive, 200),
    }
    sets = {
      [Category.TrackedBuff] = { 10 }, [Category.TrackedBar] = { 11, 12 }, [Category.EquipSlotTracked] = { 13 },
      [Category.SpecAgnosticTracked] = { 14 }, [Category.Essential] = { 20, 21, 22, 23 }, [Category.Utility] = { 30 },
    }
    moves, popups, messages, backgrounds, saved, activeCalls = {}, 0, {}, 0, 0, {}
    presetViewers = { "Essential", "Utility", "BuffIcon", "BuffBar" }
    editLayouts = { activeLayout = 1, layouts = {} }
    C_CVar.SetCVar("cooldownViewerEnabled", nil)
    private.db.cdmHideBlizzard = nil
    private.db.cdmClassPackSetupBackups = nil
  end

  local function Viewer(name, settings)
    return { system = Enum.EditModeSystem.CooldownViewer, systemIndex = Indices[name], settings = settings or {} }
  end

  C_CooldownViewer = setmetatable({
    GetLayoutData = function() return layoutData end,
    SetLayoutData = function(blob) saved = saved + 1 layoutData = blob end,
    GetCooldownViewerCategorySet = function(category) return sets[category] or {} end,
  }, { __index = realViewer })
  C_EditMode = setmetatable({
    GetLayouts = function() return CopyTable(editLayouts) end,
    SaveLayouts = function(state)
      editLayouts = { activeLayout = editLayouts.activeLayout, layouts = {} }
      for _, layout in ipairs(state.layouts) do
        if layout.layoutType ~= presetType then table.insert(editLayouts.layouts, CopyTable(layout)) end
      end
    end,
    SetActiveLayout = function(index) activeCalls[#activeCalls + 1] = index editLayouts.activeLayout = index end,
  }, { __index = realEditMode })
  EditModePresetLayoutManager = {
    GetCopyOfPresetLayouts = function()
      local systems = { { system = Enum.EditModeSystem.ActionBar, systemIndex = 1, settings = {} } }
      for _, name in ipairs(presetViewers) do table.insert(systems, Viewer(name)) end
      return { { layoutName = "Modern", layoutType = presetType, systems = systems } }
    end,
  }

  local liveManager = { loaded = true, pending = false }
  function liveManager:IsLoaded() return self.loaded end
  function liveManager:HasPendingChanges() return self.pending end
  CooldownViewerSettings = {
    shown = false,
    GetDataProvider = function() end,
    GetLayoutManager = function() return liveManager end,
    IsShown = function(self) return self.shown end,
  }
  EditModeManagerFrame = { IsShown = function() return false end }

  CooldownViewerSettingsDataProviderMixin = {
    SetLayoutManager = function() end,
    CheckBuildDisplayData = function() end,
    GetCooldownInfoForID = function(_, id) return entries[id] end,
    SetCooldownToCategory = function(_, id, category)
      moves[#moves + 1] = { id, category }
      entries[id].category = category
      return Enum.CooldownLayoutStatus.Success
    end,
  }
  CooldownViewerLayoutManagerMixin = { Init = function() end, SwitchToBestLayoutForSpec = function() end, SetShouldCheckAddLayoutStatus = function() end }
  CooldownViewerDataStoreSerializationMixin = { Init = function() end, SerializeLayouts = function() return "staged-layout" end }

  print = function(text) messages[#messages + 1] = text end
  StaticPopup_Show = function(name) if name == "WEAKAURAS_CDM_SETUP_RELOAD" then popups = popups + 1 end end
  private.ApplyCDMBackground = function() backgrounds = backgrounds + 1 end

  Reset()

  assert(WeakAuras.SetupClassPackCDM(nil) == false, "nil class accepted")
  assert(WeakAuras.SetupClassPackCDM(42) == false, "number class accepted")
  assert(WeakAuras.SetupClassPackCDM({}) == false, "table class accepted")
  assert(WeakAuras.SetupClassPackCDM("MAGE") == false, "another class accepted")
  assert(WeakAuras.SetupClassPackCDM(ownClass:lower()) == false, "lower-case class accepted")
  Advance(5)
  assert(saved == 0 and #messages == 0 and popups == 0, "rejected request configured CDM")

  presetViewers = { "Essential", "Utility", "BuffIcon" }
  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "own class refused")
  Advance(5)
  assert(#messages == 1 and messages[1]:find("CDM setup stopped: .*Edit Mode has no settings for BuffBar"),
    "missing viewer not reported: " .. tostring(messages[1]))
  assert(saved == 0 and popups == 0 and #activeCalls == 0, "failed setup wrote something")
  assert(private.db.cdmHideBlizzard ~= true and private.db.cdmClassPackSetupBackups == nil, "failed setup kept state")
  Advance(10)
  assert(#messages == 1, "stopped setup kept retrying")

  presetViewers = { "Essential", "Utility", "BuffIcon", "BuffBar" }
  CooldownViewerSettings.shown = true
  messages = {}
  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "retry after stop refused")
  Advance(30)
  assert(#messages == 0 and saved == 0, "setup ran while the CDM settings were open")
  Advance(40)
  assert(#messages == 1 and messages[1]:find("waiting for saved layouts"), "no give-up message: " .. tostring(messages[1]))
  assert(saved == 0 and popups == 0, "give-up wrote something")
  Advance(10)
  assert(#messages == 1, "gave-up setup kept retrying")
  CooldownViewerSettings.shown = false


  Reset()
  C_CVar.SetCVar("cooldownViewerEnabled", "1")
  private.db.cdmHideBlizzard = true
  sets = {}
  editLayouts = { activeLayout = 2, layouts = { { layoutName = "Mine", layoutType = characterType, systems = {
    Viewer("Essential", { { setting = visibleId, value = always } }), Viewer("Utility", { { setting = visibleId, value = always } }),
    Viewer("BuffIcon", { { setting = visibleId, value = always } }), Viewer("BuffBar", { { setting = visibleId, value = always } }),
  } } } }
  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "noop request refused")
  Advance(3)
  assert(saved == 0 and #activeCalls == 0 and popups == 0 and #messages == 0 and backgrounds == 0,
    "already configured CDM was touched")
  assert(private.db.cdmClassPackSetupBackups == nil, "backup taken for nothing")
  Advance(70)
  assert(#messages == 0, "finished setup kept retrying")

  Reset()
  messages = {}
  test.Units.SetCombat(true)
  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "request in combat refused")
  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "repeated request in combat refused")
  Advance(5)
  assert(saved == 0 and #activeCalls == 0 and popups == 0, "setup ran in combat")
  liveManager.pending = true
  test.Units.SetCombat(false)
  Advance(5)
  assert(saved == 0 and popups == 0, "setup ran with pending layout changes")
  liveManager.pending = false
  Advance(2)

  assert(saved == 1, "layout saved " .. saved .. " time(s) after combat")
  assert(layoutData == "staged-layout", "staged layout not stored: " .. tostring(layoutData))
  local moved = {}
  for _, move in ipairs(moves) do moved[#moved + 1] = move[1] .. ">" .. move[2] end
  assert(table.concat(moved, " ") == table.concat({
    "11>" .. Category.TrackedBuff, "12>" .. Category.TrackedBuff, "13>" .. Category.TrackedBuff, "14>" .. Category.TrackedBuff,
    "20>" .. Category.Essential, "30>" .. Category.Utility }, " "), "unexpected moves: " .. table.concat(moved, " "))

  assert(#editLayouts.layouts == 1 and editLayouts.layouts[1].layoutName == "WeakAuras"
    and editLayouts.layouts[1].layoutType == characterType, "personal Edit Mode layout missing")
  assert(editLayouts.activeLayout == 2 and #activeCalls == 1 and activeCalls[1] == 2, "personal layout not activated")
  local visible = 0
  for _, frameSystem in ipairs(editLayouts.layouts[1].systems) do
    if frameSystem.system == Enum.EditModeSystem.CooldownViewer then
      for _, option in ipairs(frameSystem.settings) do
        if option.setting == visibleId and option.value == always then visible = visible + 1 end
      end
    end
  end
  assert(visible == 4, visible .. " viewer(s) always visible, 4 expected")

  assert(private.db.cdmHideBlizzard == true, "Blizzard CDM not hidden")
  assert(C_CVar.GetCVarBool("cooldownViewerEnabled"), "CDM not enabled")
  assert(backgrounds >= 1, "background not refreshed")
  assert(popups == 1, "reload popup shown " .. popups .. " time(s)")
  assert(#messages == 1 and messages[1]:find("4 buffs and 2 spell cooldowns added"), "unexpected message: " .. tostring(messages[1]))
  local backup = private.db.cdmClassPackSetupBackups and private.db.cdmClassPackSetupBackups[guid]
  assert(backup, "no backup for the character")
  assert(backup.cooldownLayout == "original-layout" and backup.enabled == false and backup.hideBlizzard == false
    and backup.editLayouts.activeLayout == 1, "backup does not hold the original state")

  assert(WeakAuras.SetupClassPackCDM(ownClass) == true, "request after setup refused")
  test.Units.SetCombat(true)
  test.Units.SetCombat(false)
  Advance(5)
  assert(saved == 1 and #activeCalls == 1 and popups == 1 and #messages == 1, "setup ran again while a reload is pending")

  C_CooldownViewer, C_EditMode = realViewer, realEditMode
  EditModePresetLayoutManager, CooldownViewerSettings, EditModeManagerFrame = nil, nil, nil
  CooldownViewerSettingsDataProviderMixin, CooldownViewerLayoutManagerMixin, CooldownViewerDataStoreSerializationMixin = nil, nil, nil
  print, StaticPopup_Show, private.ApplyCDMBackground = realPrint, realPopup, realBackground
  Enum.CooldownLayoutStatus, Category.HiddenActive = savedStatus, savedHidden
end

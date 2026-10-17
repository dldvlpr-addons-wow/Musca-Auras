-- OptionsFilesContract: freezes the observable contract of seven option files before they are rewritten:
-- AuraTriggerOptions, TriggerSecretWarnings, VersionCheck, GroupModernFlow, CDMDispel, CDMDispelBorder and the
-- WeakAurasColorPicker widget. Only the public exports are used (AuraEditor, SaveAuraTrigger,
-- TriggerSecretWarnings, AddModernFlowGroupOptions, CreateModernGroupIcon, registered sub-region options, the
-- registered widget constructor, the replaced WeakAuras.ToggleOptions). Spec: spec-r10-options.md.
-- Like in game (and scenarios 17 and 31), OptionsPrivate.Private is set AFTER the files are executed.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local optionsDirectory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  local function Same(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
  local function Hid(option, field) local v = option[field or "hidden"]; if type(v) == "function" then v = v() end; return not not v end
  local function Join(list) return table.concat(list, ",") end
  local function Load(file, optionsPrivate)
    local ok, message = test.Loader.RunFile(optionsDirectory .. file, "WeakAurasOptions", optionsPrivate)
    assert(ok, file .. ": " .. tostring(message))
  end
  local function Fields(option, expected, label)
    for field, value in pairs(expected) do
      Same(option[field], value, label .. "." .. field)
    end
  end

  -- Texture colors are not kept by the harness: record SetColorTexture on every texture created from now on.
  local realCreateFrame = CreateFrame
  CreateFrame = function(...)
    local frame = realCreateFrame(...)
    local createTexture = frame.CreateTexture
    rawset(frame, "CreateTexture", function(self, ...)
      local texture = createTexture(self, ...)
      rawset(texture, "SetColorTexture", function(owner, ...) rawset(owner, "colorArguments", { ... }) end)
      return texture
    end)
    return frame
  end

  -- Fake AceGUI and ColorPickerFrame: the harness has neither.
  local fired, focusCleared = {}, 0
  local widgetRegistration
  local aceGui = LibStub:NewLibrary("AceGUI-3.0", 1000)
  aceGui.GetWidgetVersion = function() return nil end
  aceGui.RegisterWidgetType = function(_, name, constructor, version) widgetRegistration = { name, constructor, version } end
  aceGui.ClearFocus = function() focusCleared = focusCleared + 1 end
  aceGui.RegisterAsWidget = function(_, widget)
    widget.frame.obj = widget
    widget.Fire = function(_, name, ...) fired[#fired + 1] = { name, ... } end
    widget.SetWidth = function(self, width) self.frame:SetWidth(width) end
    widget.SetHeight = function(self, height) self.frame:SetHeight(height) end
    local disabledCalls = {}
    widget.frame.Enable = function() disabledCalls[#disabledCalls + 1] = "Enable" end
    widget.frame.Disable = function() disabledCalls[#disabledCalls + 1] = "Disable" end
    widget.disabledCalls = disabledCalls
    widget.text.SetTextColor = function(self, r, g, b) rawset(self, "textColor", { r, g, b }) end
    return widget
  end
  local picker = { visible = false, r = 0.1, g = 0.2, b = 0.3, a = 0.4, calls = {} }
  function picker:Hide() self.visible = false; self.calls[#self.calls + 1] = "Hide" end
  function picker:IsVisible() return self.visible end
  function picker:GetColorRGB() return self.r, self.g, self.b end
  function picker:GetColorAlpha() return self.a end
  function picker:SetFrameStrata(strata) self.strata = strata end
  function picker:SetFrameLevel(level) self.level = level end
  function picker:SetClampedToScreen(value) self.clamped = value end
  function picker:SetupColorPickerAndShow(request)
    self.request = request
    self.visible = true
    self.calls[#self.calls + 1] = "Setup"
  end
  ColorPickerFrame = picker

  ---------------------------------------------------------------------------------------------------------------
  -- Load the seven files in TOC order with a bare OptionsPrivate (no Private), then set Private.
  ---------------------------------------------------------------------------------------------------------------
  local optionsPrivate = {
    commonOptions = {},
    ResetMoverSizer = function() end,
  }
  local refreshed = {}
  optionsPrivate.QueueOptionsRefresh = function(id) refreshed[#refreshed + 1] = id end

  local subRegionRegistrations = {}
  local realRegister = WeakAuras.RegisterSubRegionOptions
  WeakAuras.RegisterSubRegionOptions = function(name, create, description, getAnchors)
    subRegionRegistrations[#subRegionRegistrations + 1] = { name = name, create = create, description = description, getAnchors = getAnchors }
  end
  Load("VersionCheck.lua", optionsPrivate)
  Load("RegionOptions/GroupModernFlow.lua", optionsPrivate)
  Load("SubRegionOptions/CDMDispel.lua", optionsPrivate)
  Load("SubRegionOptions/CDMDispelBorder.lua", optionsPrivate)
  Load("TriggerSecretWarnings.lua", optionsPrivate)
  Load("AuraTriggerOptions.lua", optionsPrivate)
  Load("AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.lua", optionsPrivate)
  WeakAuras.RegisterSubRegionOptions = realRegister
  optionsPrivate.Private = private

  local Display = private.BlizzardAuraDisplay
  local addCalls = {}
  local realAdd = WeakAuras.Add
  WeakAuras.Add = function(data) addCalls[#addCalls + 1] = data end
  local function TakeAdds() local count = #addCalls; addCalls = {}; return count end
  local function TakeRefreshes() local list = refreshed; refreshed = {}; return Join(list) end

  ---------------------------------------------------------------------------------------------------------------
  -- Loading: exports and registrations
  ---------------------------------------------------------------------------------------------------------------
  assert(type(optionsPrivate.AuraEditor.Mode) == "function" and type(optionsPrivate.AuraEditor.Resolve) == "function"
    and type(optionsPrivate.AuraEditor.AddOptions) == "function", "AuraEditor members")
  assert(type(optionsPrivate.SaveAuraTrigger) == "function", "SaveAuraTrigger")
  assert(type(optionsPrivate.AddModernFlowGroupOptions) == "function" and type(optionsPrivate.CreateModernGroupIcon) == "function", "flow exports")
  assert(type(optionsPrivate.TriggerSecretWarnings) == "table", "TriggerSecretWarnings")
  Same(#subRegionRegistrations, 2, "sub region registrations")
  Same(subRegionRegistrations[1].name, "subcdmdispel", "first registration")
  Same(subRegionRegistrations[1].description, "Shows the dispel type of a Cooldown Manager buff trigger.", "dispel description")
  Same(subRegionRegistrations[1].getAnchors, nil, "dispel getAnchors")
  Same(subRegionRegistrations[2].name, "subcdmdispelborder", "second registration")
  Same(subRegionRegistrations[2].description, "Shows a resizable border coloured by dispel type.", "border description")
  Same(subRegionRegistrations[2].getAnchors, nil, "border getAnchors")
  Same(widgetRegistration[1], "WeakAurasColorPicker", "widget type")
  Same(widgetRegistration[3], 3, "widget version")

  ---------------------------------------------------------------------------------------------------------------
  -- VersionCheck: replaces ToggleOptions when the two Version metadata differ
  ---------------------------------------------------------------------------------------------------------------
  do
    local versions = { WeakAurasOptions = "1.0", WeakAuras = "1.0" }
    local realMetadata = C_AddOns.GetAddOnMetadata
    C_AddOns.GetAddOnMetadata = function(addon, field)
      assert(field == "Version", "metadata field " .. tostring(field))
      return versions[addon]
    end
    local original = function() end
    WeakAuras.ToggleOptions = original
    Load("VersionCheck.lua", {})
    Same(WeakAuras.ToggleOptions, original, "same versions leave ToggleOptions")

    versions.WeakAurasOptions, versions.WeakAuras = nil, nil
    Load("VersionCheck.lua", {})
    Same(WeakAuras.ToggleOptions, original, "two nil versions are equal")

    versions.WeakAurasOptions, versions.WeakAuras = "1.0", "2.0"
    Load("VersionCheck.lua", {})
    assert(WeakAuras.ToggleOptions ~= original, "mismatch replaces ToggleOptions")

    local printed, popups = {}, {}
    local realPrint, realPopup = WeakAuras.prettyPrint, StaticPopup_Show
    WeakAuras.prettyPrint = function(message) printed[#printed + 1] = message end
    StaticPopup_Show = function(name, text) popups[#popups + 1] = { name, text } end
    WeakAuras.ToggleOptions("ignored", private)
    WeakAuras.prettyPrint, StaticPopup_Show = realPrint, realPopup
    C_AddOns.GetAddOnMetadata = realMetadata

    Same(#printed, 1, "prettyPrint calls")
    assert(printed[1]:find("1.0", 1, true) and printed[1]:find("2.0", 1, true), "versions in message: " .. tostring(printed[1]))
    Same(#popups, 1, "popup calls")
    Same(popups[1][1], "WEAKAURAS_ACTION_BLOCKED", "popup name")
    assert(popups[1][2]:find(printed[1], 1, true) == 1, "popup starts with printed message")
    assert(popups[1][2]:find("\n\nReplace the 5 folders WeakAuras, WeakAurasArchive, WeakAurasModelPaths, WeakAurasOptions and WeakAurasTemplates with the same version, then restart the game.", 1, true), "popup english key: " .. tostring(popups[1][2]))
  end

  ---------------------------------------------------------------------------------------------------------------
  -- AuraTriggerOptions: Mode and Resolve
  ---------------------------------------------------------------------------------------------------------------
  local AuraEditor = optionsPrivate.AuraEditor
  Same(AuraEditor.Mode({ type = "secretAura" }), "native", "Mode secretAura")
  Same(AuraEditor.Mode({ type = "aura2" }), "readable", "Mode aura2")
  Same(AuraEditor.Mode({ type = "aura2", auraTracking = "native" }), "native", "Mode tracking native")
  Same(AuraEditor.Mode({ type = "secretAura", auraTracking = "readable" }), "readable", "Mode tracking readable")
  Same(AuraEditor.Mode({ type = "secretAura", auraTracking = "other" }), "native", "Mode unknown tracking")
  Same(AuraEditor.Mode({ type = "custom" }), "readable", "Mode other type")

  local migrated, usesSpellIdsTypes = {}, {}
  local realMigrate, realUses = Display.Migrate, Display.UsesSpellIDs
  Display.Migrate = function(data) migrated[#migrated + 1] = data end
  Display.UsesSpellIDs = function(trigger) usesSpellIdsTypes[#usesSpellIdsTypes + 1] = trigger.type; return "uses" end

  do
    -- readable -> native
    local data = { id = "Aura", automaticWidth = "Fixed", triggers = { { trigger = {
      type = "aura2", auraTracking = "native", onlyMaw = true, debuffType = "BOTH", useExactSpellId = true } } } }
    local trigger = data.triggers[1].trigger
    AuraEditor.Resolve(data, 1)
    Same(trigger.type, "secretAura", "converted type")
    Same(trigger.debuffType, "HELPFUL", "BOTH becomes HELPFUL")
    Same(trigger.secretUseSpellIDs, true, "secretUseSpellIDs from useExactSpellId")
    Same(trigger.auraReadableSettings.onlyMaw, true, "remembered onlyMaw")
    Same(trigger.auraReadableSettings.automaticWidth, "Fixed", "remembered automaticWidth from data")
    Same(trigger.auraReadableSettings.debuffType, "BOTH", "remembered debuffType")
    Same(#migrated, 1, "Migrate calls")
    Same(migrated[1], data, "Migrate argument")
    Same(TakeRefreshes(), "Aura", "refresh queued")
    Same(TakeAdds(), 0, "Resolve does not Add")

    -- native -> readable restores the remembered BOTH
    trigger.auraTracking = "readable"
    data.automaticWidth, trigger.onlyMaw = "Auto", false
    AuraEditor.Resolve(data, 1)
    Same(trigger.type, "aura2", "back to aura2")
    Same(trigger.debuffType, "BOTH", "BOTH restored")
    Same(trigger.onlyMaw, true, "onlyMaw restored")
    Same(data.automaticWidth, "Fixed", "automaticWidth restored")
    Same(trigger.auraReadableSettings, nil, "memory cleared")
    Same(trigger.useExactSpellId, "uses", "useExactSpellId from UsesSpellIDs")
    Same(usesSpellIdsTypes[#usesSpellIdsTypes], "secretAura", "UsesSpellIDs sees the native trigger")
    Same(TakeRefreshes(), "Aura", "refresh queued again")

    -- already consistent: nothing happens, no refresh
    AuraEditor.Resolve(data, 1)
    AuraEditor.Resolve({ id = "X", triggers = { { trigger = { type = "custom", auraTracking = "native" } } } }, 1)
    Same(TakeRefreshes(), "", "no refresh when nothing converts")
    Same(#migrated, 1, "no extra Migrate")

    -- remembered non BOTH debuffType is not restored
    local other = { id = "Other", triggers = { { trigger = { type = "secretAura", auraTracking = "readable", debuffType = "HARMFUL",
      auraReadableSettings = { debuffType = "HELPFUL" } } } } }
    AuraEditor.Resolve(other, 1)
    Same(other.triggers[1].trigger.debuffType, "HARMFUL", "debuffType kept")
    Same(other.triggers[1].trigger.type, "aura2", "other converted")
    local bare = { id = "Bare", triggers = { { trigger = { type = "secretAura", auraTracking = "readable" } } } }
    AuraEditor.Resolve(bare, 1)
    Same(bare.triggers[1].trigger.type, "aura2", "bare converted")
    Same(bare.triggers[1].trigger.auraReadableSettings, nil, "bare memory nil")
    TakeRefreshes()

    local plain = { id = "Plain", triggers = { { trigger = { type = "aura2", auraTracking = "native", debuffType = "HARMFUL" } } } }
    AuraEditor.Resolve(plain, 1)
    Same(plain.triggers[1].trigger.debuffType, "HARMFUL", "HARMFUL kept")
    Same(plain.triggers[1].trigger.secretUseSpellIDs, false, "secretUseSpellIDs false by default")
    Same(plain.triggers[1].trigger.auraReadableSettings.debuffType, "HARMFUL", "remembered HARMFUL")
    TakeRefreshes()

    -- SaveAuraTrigger: Resolve then Add
    local saved = { id = "Saved", triggers = { { trigger = { type = "aura2", auraTracking = "native" } } } }
    optionsPrivate.SaveAuraTrigger(saved, 1)
    Same(saved.triggers[1].trigger.type, "secretAura", "SaveAuraTrigger resolves")
    Same(TakeAdds(), 1, "SaveAuraTrigger adds once")
    TakeRefreshes()
    local steady = { id = "Steady", triggers = { { trigger = { type = "secretAura" } } } }
    optionsPrivate.SaveAuraTrigger(steady, 1)
    Same(TakeAdds(), 1, "steady Add")
    Same(TakeRefreshes(), "", "steady has no refresh")
  end
  Display.Migrate, Display.UsesSpellIDs = realMigrate, realUses

  ---------------------------------------------------------------------------------------------------------------
  -- AuraTriggerOptions: AddOptions tree
  ---------------------------------------------------------------------------------------------------------------
  local normal, half, double = WeakAuras.normalWidth, WeakAuras.halfWidth, WeakAuras.doubleWidth
  local function NewOptions() return { debuffType = { type = "select", order = 1 }, help = { type = "description", fontSize = "medium" } } end
  local function Build(trigger, id)
    local data = { id = id or "Tree", triggers = { { trigger = trigger } } }
    local options = NewOptions()
    AuraEditor.AddOptions(options, data, 1)
    TakeAdds(); TakeRefreshes()
    return options, data
  end

  -- readable mode
  do
    local trigger = { type = "aura2", debuffType = "BOTH", sortMethod = "UnitFrameDebuff" }
    local options = Build(trigger)
    Same(options.help.fontSize, "medium", "readable leaves help")
    Same(options.debuffType.values.HELPFUL, "Buff", "readable HELPFUL label")
    Same(options.debuffType.values.HARMFUL, "Debuff", "readable HARMFUL label")
    Same(options.debuffType.values.BOTH, "Buff or Debuff", "readable BOTH label")
    Same(Join(options.debuffType.sorting), "HELPFUL,HARMFUL,BOTH", "readable sorting")
    Fields(options.auraCapabilities, { type = "description", order = 1.3, width = "full", fontSize = "small",
      name = "Legacy Auras rarely function in combat as most are Blizzard-controlled." }, "auraCapabilities")
    Same(options.useRem, nil, "readable has no useRem")
    Same(options.secretApproximate, nil, "readable has no approximate")
    Same(options.matchesShowOn, nil, "readable has no matchesShowOn")
    Same(options.debuffType.get(), "BOTH", "readable debuffType get")
    options.debuffType.set(nil, "bogus")
    Same(TakeAdds(), 0, "invalid debuffType ignored")
    Same(trigger.debuffType, "BOTH", "invalid debuffType unchanged")
    options.debuffType.set(nil, "HARMFUL")
    Same(trigger.debuffType, "HARMFUL", "debuffType set")
    Same(trigger.sortMethod, "Default", "UnitFrameDebuff sort reset")
    Same(TakeAdds(), 1, "debuffType saved")
    Same(TakeRefreshes(), "Tree", "debuffType refresh")
    trigger.sortMethod = "Name"
    options.debuffType.set(nil, "BOTH")
    Same(trigger.sortMethod, "Name", "other sort kept")
    Same(trigger.debuffType, "BOTH", "BOTH set in readable mode")
    TakeAdds(); TakeRefreshes()
  end

  -- native mode
  local nativeTrigger = { type = "secretAura", unit = "player", sortMethod = "UnitFrameDebuff" }
  local native = Build(nativeTrigger)
  Same(native.help.fontSize, "small", "native help fontSize")
  Same(native.debuffType.values.BOTH, nil, "native has no BOTH")
  Same(native.debuffType.values.HELPFUL, "Buff", "native HELPFUL")
  Same(native.debuffType.values.HARMFUL, "Debuff", "native HARMFUL")
  Same(Join(native.debuffType.sorting), "HELPFUL,HARMFUL", "native sorting")
  Same(native.auraCapabilities, nil, "native has no auraCapabilities")
  native.debuffType.set(nil, "BOTH")
  Same(TakeAdds(), 0, "native BOTH ignored")
  Same(nativeTrigger.debuffType, nil, "native BOTH not stored")
  native.debuffType.set(nil, "HARMFUL")
  Same(nativeTrigger.sortMethod, "Default", "native sort reset")
  Same(native.debuffType.get(), "HARMFUL", "native debuffType get")
  Same(TakeAdds(), 1, "native debuffType saved")
  Same(TakeRefreshes(), "Tree", "native debuffType refresh")

  local groups = {
    { "useRem", "remOperator", "rem", "useRemSpace", "Remaining Time" },
    { "useTotal", "totalOperator", "total", "useTotalSpace", "Total Duration" },
    { "useStacks", "stacksOperator", "stacks", "useStacksSpace", "Stack Count" },
  }
  for _, group in ipairs(groups) do
    local toggleKey, operatorKey, valueKey, spaceKey, title = unpack(group)
    Fields(native[toggleKey], { type = "toggle", name = title, width = normal }, toggleKey)
    Fields(native[operatorKey], { type = "select", name = "Operator", width = half }, operatorKey)
    Fields(native[valueKey], { type = "input", name = title, width = half }, valueKey)
    Fields(native[spaceKey], { type = "description", name = "", width = normal }, spaceKey)
  end
  Same(native.useRem.order, 10.01, "useRem order"); Same(native.remOperator.order, 10.02, "remOperator order")
  Same(native.rem.order, 10.03, "rem order"); Same(native.useRemSpace.order, 10.04, "useRemSpace order")
  Same(native.useTotal.order, 10.05, "useTotal order"); Same(native.totalOperator.order, 10.06, "totalOperator order")
  Same(native.total.order, 10.07, "total order"); Same(native.useTotalSpace.order, 10.08, "useTotalSpace order")
  Same(native.useStacks.order, 10.085, "useStacks order"); Same(native.stacksOperator.order, 10.086, "stacksOperator order")
  Same(native.stacks.order, 10.087, "stacks order"); Same(native.useStacksSpace.order, 10.088, "useStacksSpace order")
  Same(native.remOperator.values, Display.remOperators, "rem operator values")
  Same(native.totalOperator.values, Display.totalOperators, "total operator values")
  Same(native.stacksOperator.values, Display.stackOperators, "stacks operator values")
  Same(Join(native.remOperator.sorting), "<,<=,>,>=", "rem sorting")
  Same(Join(native.totalOperator.sorting), "=,<=,>=", "total sorting")
  Same(Join(native.stacksOperator.sorting), "=,>=,>,<=,<", "stacks sorting")

  -- remaining time group behaviour
  do
    local trigger = { type = "secretAura", unit = "player" }
    local options = Build(trigger)
    Same(Hid(options.useRem), false, "rem toggle visible on showOnActive")
    Same(options.useRem.get(), false, "rem toggle off")
    Same(Hid(options.remOperator), true, "rem operator hidden while off")
    Same(Hid(options.rem), true, "rem value hidden while off")
    Same(Hid(options.useRemSpace), false, "rem space visible while off")
    options.useRem.set(nil, true)
    Same(trigger.secretUseRem, true, "secretUseRem")
    Same(trigger.secretRemOperator, "<", "default rem operator")
    Same(trigger.secretRem, "5", "rem prefilled")
    Same(TakeAdds(), 1, "rem toggle saved")
    Same(TakeRefreshes(), "Tree", "rem toggle refresh")
    Same(Hid(options.remOperator), false, "rem operator shown")
    Same(Hid(options.rem), false, "rem value shown")
    Same(Hid(options.useRemSpace), true, "rem space hidden when on")
    Same(options.remOperator.get(), "<", "rem operator get")
    Same(options.rem.get(), "5", "rem get")
    options.remOperator.set(nil, ">=")
    Same(trigger.secretRemOperator, ">=", "rem operator set")
    Same(TakeAdds(), 1, "rem operator saved")
    TakeRefreshes()
    Same(options.rem.validate(nil, "abc"), "Enter a number of seconds, 0 or more.", "rem invalid text")
    Same(options.rem.validate(nil, "-1"), "Enter a number of seconds, 0 or more.", "rem negative")
    Same(options.rem.validate(nil, "0"), true, "rem zero allowed")
    Same(options.rem.validate(nil, "2,5"), true, "rem comma allowed")
    options.rem.set(nil, "2,5")
    Same(trigger.secretRem, "2.5", "rem comma normalized")
    Same(options.rem.get(), "2.5", "rem get normalized")
    options.useRem.set(nil, false)
    Same(trigger.secretUseRem, nil, "rem flag cleared")
    options.useRem.set(nil, true)
    Same(trigger.secretRem, "2.5", "rem value kept when numeric")
    trigger.secretRem = "junk"
    options.useRem.set(nil, true)
    Same(trigger.secretRem, "5", "rem refilled when not numeric")
    trigger.secretRem = "junk"
    options.useRem.set(nil, false)
    Same(trigger.secretRem, "junk", "rem value untouched when disabling")
    trigger.secretRem = "5"
    options.useRem.set(nil, true)
    TakeAdds(); TakeRefreshes()
    trigger.secretShowOn = "showOnMissing"
    Same(Hid(options.useRem), true, "rem toggle blocked")
    Same(Hid(options.remOperator), true, "rem operator blocked")
    Same(Hid(options.rem), true, "rem value blocked")
    Same(Hid(options.useRemSpace), true, "rem space blocked")
  end

  -- total duration group
  do
    local trigger = { type = "secretAura", unit = "player", secretShowOn = "showOnMissing" }
    local options = Build(trigger)
    Same(options.useTotal.get(), false, "total off")
    Same(Hid(options.totalOperator), true, "total operator hidden while off")
    options.useTotal.set(nil, true)
    Same(trigger.secretUseTotal, true, "secretUseTotal")
    Same(trigger.secretTotalOperator, "=", "default total operator")
    Same(trigger.secretTotal, nil, "total not prefilled")
    Same(options.total.get(), "", "total empty")
    Same(options.total.validate(nil, "0"), "Enter a number of seconds above 0.", "total zero")
    Same(options.total.validate(nil, "-2"), "Enter a number of seconds above 0.", "total negative")
    Same(options.total.validate(nil, "x"), "Enter a number of seconds above 0.", "total text")
    Same(options.total.validate(nil, "1,5"), true, "total comma")
    options.total.set(nil, "1,5")
    Same(trigger.secretTotal, "1.5", "total normalized")
    options.totalOperator.set(nil, "<=")
    Same(trigger.secretTotalOperator, "<=", "total operator set")
    TakeAdds(); TakeRefreshes()
  end

  -- stacks group
  do
    local trigger = { type = "secretAura", unit = "player" }
    local options = Build(trigger)
    Same(Display.STACK_LIMIT, 100, "stack limit")
    local message = "Enter a whole number from 0 to " .. Display.STACK_LIMIT .. "."
    Same(options.stacks.validate(nil, "5"), true, "stacks ok")
    Same(options.stacks.validate(nil, "0"), true, "stacks zero")
    Same(options.stacks.validate(nil, "100"), true, "stacks limit")
    Same(options.stacks.validate(nil, "101"), message, "stacks too many")
    Same(options.stacks.validate(nil, "-1"), message, "stacks negative")
    Same(options.stacks.validate(nil, "2.5"), message, "stacks fraction")
    Same(options.stacks.validate(nil, "x"), message, "stacks text")
    options.useStacks.set(nil, true)
    Same(trigger.secretStacksOperator, ">=", "default stacks operator")
    options.stacks.set(nil, "7")
    Same(trigger.secretStacks, 7, "stacks stored as number")
    Same(options.stacks.get(), "7", "stacks get")
    options.stacksOperator.set(nil, "<")
    Same(trigger.secretStacksOperator, "<", "stacks operator set")
    options.useStacks.set(nil, false)
    Same(trigger.secretUseStacks, nil, "stacks flag cleared")
    TakeAdds(); TakeRefreshes()
  end

  -- remaining native entries
  Fields(native.show_settings_header, { type = "header", name = "Show and Clone Settings", order = 69.91 }, "show_settings_header")
  Fields(native.use_matchesShowOn, { type = "toggle", name = "Show On", order = 71, width = normal, disabled = true }, "use_matchesShowOn")
  Same(native.use_matchesShowOn.get(), true, "use_matchesShowOn get")
  Fields(native.matchesShowOn, { type = "select", name = "Show On", order = 71.1, width = normal, values = Display.showOnValues }, "matchesShowOn")
  Fields(native.unitExists, { type = "toggle", name = "Show If Unit Does Not Exist", order = 71.3, width = double }, "unitExists")
  Fields(native.showClones, { type = "toggle", name = "Auto-Clone (Show All Matches)", order = 72, width = "full", disabled = true }, "showClones")
  Same(native.showClones.get(), false, "showClones get")
  Fields(native.combineMode, { type = "select", name = "Preferred Match", order = 72.6, width = normal, disabled = true }, "combineMode")
  Same(native.combineMode.get(), "showLowest", "combineMode default")
  Fields(native.nativeShowNotice, { type = "description", order = 73, width = "full", fontSize = "small" }, "nativeShowNotice")
  Fields(native.secretApproximate, { type = "toggle", name = "Approximate Match", order = 4.02, width = "full" }, "secretApproximate")

  do
    local trigger = { type = "secretAura", unit = "player", combineMode = "showHighest", showClones = true, secretApproximate = true }
    local options = Build(trigger)
    Same(options.combineMode.get(), "showHighest", "combineMode get")
    Same(options.showClones.get(), true, "showClones get true")
    Same(options.secretApproximate.get(), true, "approximate get")
    options.secretApproximate.set(nil, false)
    Same(trigger.secretApproximate, nil, "approximate cleared")
    options.secretApproximate.set(nil, true)
    Same(trigger.secretApproximate, true, "approximate set")
    Same(TakeAdds(), 2, "approximate saves")
    TakeRefreshes()

    Same(options.matchesShowOn.get(), "showOnActive", "show on default")
    options.matchesShowOn.set(nil, "showOnMissing")
    Same(trigger.secretShowOn, "showOnMissing", "show on missing")
    Same(options.matchesShowOn.get(), "showOnMissing", "show on get after")
    options.matchesShowOn.set(nil, "showAlways")
    Same(trigger.secretShowOn, "showAlways", "show always")
    options.matchesShowOn.set(nil, "showOnActive")
    Same(trigger.secretShowOn, nil, "show on active clears")
    TakeAdds(); TakeRefreshes()
    options.matchesShowOn.set(nil, "bogus")
    Same(TakeAdds(), 0, "invalid show on ignored")

    options.unitExists.set(nil, true)
    Same(trigger.unitExists, true, "unitExists set")
    Same(options.unitExists.get(), true, "unitExists get")
    options.unitExists.set(nil, false)
    Same(trigger.unitExists, nil, "unitExists cleared")
    TakeAdds(); TakeRefreshes()

    local realSingle = Display.IsSingle
    Display.IsSingle = function() return false end
    Same(options.nativeShowNotice.name(), "You cannot control clones with an Aura (Modern). Use the Aura (Modern) Settings under Display.", "notice clones")
    Display.IsSingle = function() return true end
    Same(options.nativeShowNotice.name(), "One aura is shown, chosen by Sort by under Aura (Modern) Settings in Display.", "notice single")
    Display.IsSingle = realSingle
  end

  ---------------------------------------------------------------------------------------------------------------
  -- TriggerSecretWarnings
  ---------------------------------------------------------------------------------------------------------------
  local Warnings = optionsPrivate.TriggerSecretWarnings
  Same(Warnings.message, "Secret detected. Some features may be restricted in combat.", "warning message")
  Same(Warnings.text, "|cffff0000" .. Warnings.message .. "|r", "warning text")

  local realSecrets = C_Secrets
  local answers, askedWith = {}, {}
  C_Secrets = setmetatable({}, { __index = function(_, name)
    return function(...)
      askedWith[name] = { ... }
      local answer = answers[name]
      if type(answer) == "function" then return answer(...) end
      return answer
    end
  end })
  local function Ask(map) answers, askedWith = map, {} end
  local always = Enum.SecrecyLevel.AlwaysSecret
  local contextual = Enum.SecrecyLevel.ContextuallySecret
  local never = Enum.SecrecyLevel.NeverSecret

  local function Scope(trigger, extra)
    local data = { id = "Scoped", uid = "uid", triggers = { { trigger = trigger } } }
    for key, value in pairs(extra or {}) do data[key] = value end
    return (Warnings.GetScope(data, 1))
  end

  do
    local function Has(trigger) return Warnings.HasSecretAuraSpell(trigger) end
    local spell = { type = "aura2", useExactSpellId = true, auraspellids = { "5" } }
    Ask({ HasSecretRestrictions = true, GetSpellAuraSecrecy = function(id) return id == 111 and always or never end })
    Same(Has({ type = "custom", useExactSpellId = true, auraspellids = { "111" } }), false, "not aura2")
    Same(Has({ type = "aura2", useExactSpellId = true, auraspellids = { "111" } }), true, "restricted spell")
    Same(Has({ type = "aura2", useExactSpellId = true, auraspellids = { "222" } }), false, "unrestricted spell")
    Same(Has({ type = "aura2", auraspellids = { "111" } }), false, "ids ignored without useExactSpellId")
    Same(Has({ type = "aura2", useExactSpellId = true }), false, "missing list")
    Same(Has({ type = "aura2", useName = true, auranames = { "111" } }), true, "numeric name")
    Same(Has({ type = "aura2", useName = true, auranames = { "Flame Shock" } }), false, "real spell name ignored")
    Same(Has({ type = "aura2", auranames = { "111" } }), false, "names ignored without useName")
    Ask({ HasSecretRestrictions = true, GetSpellAuraSecrecy = contextual })
    Same(Has(spell), true, "contextual is restricted")
    Ask({ HasSecretRestrictions = true, GetSpellAuraSecrecy = never, ShouldSpellAuraBeSecret = true })
    Same(Has(spell), true, "ShouldSpellAuraBeSecret true")
    Ask({ HasSecretRestrictions = true, GetSpellAuraSecrecy = never, ShouldSpellAuraBeSecret = 1 })
    Same(Has(spell), false, "only exactly true counts")
    Ask({ HasSecretRestrictions = false, GetSpellAuraSecrecy = always })
    Same(Has(spell), false, "no restrictions")
    Ask({ GetSpellAuraSecrecy = function() error("boom") end, ShouldSpellAuraBeSecret = function() error("boom") end })
    Same(Has(spell), false, "errors mean unknown")
    Ask({ GetSpellAuraSecrecy = test.Secret.Wrap(always), ShouldSpellAuraBeSecret = test.Secret.Wrap(true) })
    Same(Has(spell), false, "secret answers mean unknown")
  end

  do
    local health = { type = "unit", event = "Health", unit = "player" }
    Ask({ HasSecretRestrictions = false })
    Same(Scope(health), nil, "no restrictions, no scope")
    Ask({ HasSecretRestrictions = true })
    Same(Scope(health), "Health value checks and calculations:", "health scope")
    Same(Warnings.GetText({ id = "x", triggers = { { trigger = health } } }, 1), Warnings.text, "GetText with scope")
    Same(Warnings.GetText({ id = "x", triggers = { { trigger = { type = "unit", event = "Nowhere" } } } }, 1), "", "GetText without scope")
    Same(Scope({ type = "unit", event = "Health", unit = "player", use_health = true, health = "50" }), nil, "health filtered by threshold")
    Same(Scope({ type = "unit", event = "Health", unit = "player", use_health = true }), "Health value checks and calculations:", "threshold without value")

    local power = { type = "unit", event = "Power", unit = "player", use_powertype = true, powertype = 0 }
    Ask({ HasSecretRestrictions = true, GetPowerTypeSecrecy = always })
    Same(Scope(power), "Power value checks and calculations:", "power by type secrecy")
    Same(askedWith.GetPowerTypeSecrecy[1], 0, "power secrecy asked for type")
    Ask({ HasSecretRestrictions = true, GetPowerTypeSecrecy = never })
    Same(Scope(power), nil, "power not secret")
    Ask({ HasSecretRestrictions = true, GetPowerTypeSecrecy = never, ShouldUnitPowerBeSecret = true })
    Same(Scope(power), "Power value checks and calculations:", "power by unit")
    Same(askedWith.ShouldUnitPowerBeSecret[1], "player", "unit power unit")
    Same(askedWith.ShouldUnitPowerBeSecret[2], 0, "unit power type")
    Ask({ HasSecretRestrictions = true, GetPowerTypeSecrecy = never, ShouldUnitPowerMaxBeSecret = true })
    Same(Scope(power), "Power value checks and calculations:", "power max by unit")
    Ask({ HasSecretRestrictions = true, GetPowerTypeSecrecy = always })
    Same(Scope({ type = "unit", event = "Alternate Power", unit = "player" }), "Power value checks and calculations:", "alternate power uses type 10")
    Same(askedWith.GetPowerTypeSecrecy[1], 10, "alternate power type")

    local stats = { type = "unit", event = "Character Stats", use_strength = true }
    Ask({ HasSecretRestrictions = true, ShouldUnitStatsBeSecret = true })
    Same(Scope(stats), "Character stat checks:", "stats scope")
    Same(Scope({ type = "unit", event = "Character Stats" }), nil, "stats without field")
    Ask({ HasSecretRestrictions = true, ShouldUnitStatsBeSecret = false })
    Same(Scope(stats), nil, "stats readable")

    Ask({ HasSecretRestrictions = true, ShouldUnitThreatStateBeSecret = true })
    Same(Scope({ type = "unit", event = "Threat Situation", unit = "target" }), "Threat checks:", "threat state target")
    Same(askedWith.ShouldUnitThreatStateBeSecret[1], "player", "threat state asks player")
    Same(askedWith.ShouldUnitThreatStateBeSecret[2], "target", "threat state unit")

    Ask({ HasSecretRestrictions = true, ShouldUnitSpellCastingBeSecret = true })
    Same(Scope({ type = "unit", event = "Cast", unit = "target", use_remaining = true }), "Cast value checks:", "cast scope")
    Same(askedWith.ShouldUnitSpellCastingBeSecret[1], "target", "cast unit")
    Same(Scope({ type = "unit", event = "Cast", unit = "target" }), nil, "cast without field")
    Ask({ HasSecretRestrictions = true, ShouldUnitSpellCastingBeSecret = false })
    Same(Scope({ type = "unit", event = "Cast", unit = "target", use_remaining = true }), nil, "cast readable")

    local cooldown = { type = "status", event = "Cooldown Progress (Spell)", spellName = "12345", use_remaining = true }
    Ask({ HasSecretRestrictions = true, GetSpellCooldownSecrecy = always })
    Same(Scope(cooldown), "Cooldown time checks:", "cooldown secrecy")
    Same(askedWith.GetSpellCooldownSecrecy[1], 12345, "cooldown spell id")
    Ask({ HasSecretRestrictions = true, GetSpellCooldownSecrecy = never, ShouldSpellCooldownBeSecret = true })
    Same(Scope(cooldown), "Cooldown time checks:", "cooldown should be secret")
    Ask({ HasSecretRestrictions = true, GetSpellCooldownSecrecy = never, ShouldSpellCooldownBeSecret = false })
    Same(Scope(cooldown), nil, "cooldown readable")
    Ask({ HasSecretRestrictions = true, GetSpellCooldownSecrecy = always })
    Same(Scope({ type = "status", event = "Cooldown Progress (Spell)", use_remaining = true }), nil, "cooldown without spell")

    Ask({ HasSecretRestrictions = true, ShouldUnitIdentityBeSecret = true })
    Same(Scope({ type = "unit", event = "Health", unit = "target", use_name = true, name = "x" }), "Health value checks and calculations:", "health scope wins over identity")
    local custom = { type = "custom", unit = "target" }
    Same(Scope(custom), nil, "custom without fields")
    Same(Scope(custom, { conditions = { { check = { trigger = 1, variable = "name" } } } }), "Unit identity checks:", "custom condition on name")
    Same(askedWith.ShouldUnitIdentityBeSecret[1], "target", "identity unit")
    Same(Scope(custom, { conditions = { { check = { trigger = 2, variable = "name" } } } }), nil, "condition on another trigger")
  end

  do
    local updates = {}
    local realWarnings = private.AuraWarnings
    private.AuraWarnings = { UpdateWarning = function(...) updates[#updates + 1] = { ... } end }
    local function Update(data) updates = {}; Warnings.UpdateAuraWarning(data); return updates end
    Ask({ HasSecretRestrictions = true })
    local secretData = { id = "S", uid = "u1", triggers = { { trigger = { type = "unit", event = "Health", unit = "player" } } } }
    local result = Update(secretData)
    Same(#result, 1, "one warning update")
    Same(Join({ result[1][1], result[1][2], result[1][3], result[1][4] }), "u1,SecretTrigger,warning," .. Warnings.message, "warning set")
    result = Update({ id = "S", uid = "u2", triggers = { { trigger = { type = "unit", event = "Nowhere" } } } })
    Same(#result, 1, "one clear update")
    Same(result[1][1] .. "," .. result[1][2], "u2,SecretTrigger", "clear target")
    Same(result[1][3], nil, "clear state")
    Same(result[1][4], nil, "clear message")
    Same(Update({ id = "S", triggers = secretData.triggers })[1], nil, "no uid, no update")
    Same(Update({ id = "S", uid = "u" })[1], nil, "no triggers, no update")
    optionsPrivate.Private = nil
    Same(Update(secretData)[1], nil, "no Private, no update")
    optionsPrivate.Private = private
    private.AuraWarnings = realWarnings
  end
  C_Secrets = realSecrets

  ---------------------------------------------------------------------------------------------------------------
  -- GroupModernFlow options
  ---------------------------------------------------------------------------------------------------------------
  do
    local data = { id = "Group", regionType = "group", controlledChildren = { "ChildA", "Missing", "ChildB" } }
    local children = { ChildA = { id = "ChildA" }, ChildB = { id = "ChildB" } }
    local realGetData, realClear = WeakAuras.GetData, WeakAuras.ClearAndUpdateOptions
    local order = {}
    WeakAuras.GetData = function(id) return children[id] end
    WeakAuras.Add = function(added) order[#order + 1] = "Add:" .. added.id end
    WeakAuras.ClearAndUpdateOptions = function(id) order[#order + 1] = "Clear:" .. id end
    optionsPrivate.ResetMoverSizer = function() order[#order + 1] = "Reset" end
    local function TakeOrder() local text = Join(order); order = {}; return text end

    local options = {}
    optionsPrivate.AddModernFlowGroupOptions(options, data)
    local expected = {
      blizzardFlowGrowth = { "select", 0.61, double }, blizzardFlowUseFrames = { "toggle", 0.62, normal },
      blizzardFlowFrames = { "select", 0.63, normal }, blizzardFlowSpacing = { "range", 0.64, normal },
      blizzardFlowSpacingSpace = { "description", 0.645, normal }, blizzardFlowSort = { "select", 0.65, normal },
      blizzardFlowReverse = { "toggle", 0.66, normal }, blizzardFlowUseLimit = { "toggle", 0.67, normal },
      blizzardFlowLimit = { "range", 0.68, normal }, blizzardFlowGrid = { "toggle", 0.69, normal },
      blizzardFlowGridType = { "select", 0.691, normal }, blizzardFlowPerRow = { "range", 0.692, normal },
      blizzardFlowGridSpace = { "description", 0.693, normal }, blizzardFlowRowSpace = { "range", 0.694, normal },
      blizzardFlowColumnSpace = { "range", 0.695, normal },
    }
    local count = 0
    for key, option in pairs(options) do
      count = count + 1
      local want = expected[key]
      assert(want, "unexpected flow option " .. key)
      Fields(option, { type = want[1], order = want[2], width = want[3] }, key)
      if want[1] == "range" then Same(option.control, "WeakAurasSpinBox", key .. " control") end
    end
    Same(count, 15, "flow option count")
    Same(options.blizzardFlowGrowth.values, Display.flowGrowths, "growth values")
    Same(Join(options.blizzardFlowGrowth.sorting), "RIGHT,LEFT,DOWN,UP,CENTER_HORIZONTAL,CENTER_VERTICAL", "growth sorting")
    Same(Join(options.blizzardFlowFrames.sorting), "UNITFRAME,NAMEPLATE", "frames sorting")
    Same(options.blizzardFlowGridType.values, Display.flowGridTypes, "grid types")
    Same(Join(options.blizzardFlowGridType.sorting), "RD,RU,LD,LU,DR,DL,UR,UL", "grid sorting")
    local sortValues = options.blizzardFlowSort.values()
    Same(sortValues.UnitFrameDebuff, nil, "sort values drop UnitFrameDebuff")
    assert(Display.sortMethods.UnitFrameDebuff ~= nil, "source sortMethods keep UnitFrameDebuff")
    assert(sortValues ~= Display.sortMethods, "sort values are a copy")
    Same(options.blizzardFlowSpacing.min, -20, "spacing min"); Same(options.blizzardFlowSpacing.softMax, 50, "spacing softMax")
    Same(options.blizzardFlowLimit.min, 1, "limit min"); Same(options.blizzardFlowLimit.softMax, 40, "limit softMax")
    Same(options.blizzardFlowPerRow.min, 1, "per row min"); Same(options.blizzardFlowPerRow.softMax, 20, "per row softMax")

    for key, option in pairs(options) do Same(Hid(option), true, key .. " hidden without flow") end
    data.blizzardFlow = true
    for key, option in pairs(options) do Same(Hid(option), false, key .. " visible with flow") end
    Same(Hid(options.blizzardFlowFrames, "disabled"), true, "frames disabled")
    Same(Hid(options.blizzardFlowLimit, "disabled"), true, "limit disabled")
    Same(Hid(options.blizzardFlowGridType, "disabled"), true, "grid type disabled")
    Same(Hid(options.blizzardFlowPerRow, "disabled"), true, "per row disabled")

    Same(options.blizzardFlowGrowth.get(), "RIGHT", "growth default")
    Same(options.blizzardFlowUseFrames.get(), false, "use frames default")
    Same(options.blizzardFlowSpacing.get(), 2, "spacing default")
    Same(options.blizzardFlowSort.get(), "Default", "sort default")
    Same(options.blizzardFlowReverse.get(), false, "reverse default")
    Same(options.blizzardFlowUseLimit.get(), false, "use limit default")
    Same(options.blizzardFlowLimit.get(), 5, "limit default")
    Same(options.blizzardFlowGrid.get(), false, "grid default")
    Same(options.blizzardFlowPerRow.get(), 6, "per row default")
    Same(options.blizzardFlowRowSpace.get(), 2, "row space default")
    Same(options.blizzardFlowColumnSpace.get(), 2, "column space default")
    data.blizzardFlowSpacing = 9
    Same(options.blizzardFlowRowSpace.get(), 9, "row space falls back to spacing")
    data.blizzardFlowRowSpace = 3
    Same(options.blizzardFlowRowSpace.get(), 3, "row space own value")
    data.blizzardFlowSpacing, data.blizzardFlowRowSpace = nil, nil

    data.blizzardFlowFrames = "NAMEPLATE"
    Same(Hid(options.blizzardFlowFrames, "disabled"), false, "frames enabled")
    Same(options.blizzardFlowUseFrames.get(), true, "use frames get true")
    data.blizzardFlowFrames = nil
    data.blizzardFlowUseLimit = true
    Same(Hid(options.blizzardFlowLimit, "disabled"), false, "limit enabled")
    data.blizzardFlowGrid = true
    for _, key in ipairs({ "blizzardFlowGridType", "blizzardFlowPerRow", "blizzardFlowRowSpace", "blizzardFlowColumnSpace" }) do
      Same(Hid(options[key], "disabled"), false, key .. " enabled with grid")
    end
    data.blizzardFlowUseLimit, data.blizzardFlowGrid = nil, nil

    -- coalesced saves
    TakeOrder(); TakeAdds()
    options.blizzardFlowGrowth.set(nil, "DOWN")
    options.blizzardFlowSpacing.set(nil, 7)
    options.blizzardFlowUseFrames.set(nil, true)
    Same(data.blizzardFlowGrowth, "DOWN", "growth written immediately")
    Same(data.blizzardFlowSpacing, 7, "spacing written immediately")
    Same(data.blizzardFlowFrames, "UNITFRAME", "frames UNITFRAME")
    Same(TakeOrder(), "", "nothing before the next frame")
    test.Environment.Advance(0.01)
    Same(TakeOrder(), "Add:Group,Add:ChildA,Add:ChildB,Reset,Clear:Group", "one coalesced save in order")
    options.blizzardFlowUseFrames.set(nil, false)
    Same(data.blizzardFlowFrames, nil, "frames cleared")
    test.Environment.Advance(0.01)
    TakeOrder()
    for _, key in ipairs({ "blizzardFlowReverse", "blizzardFlowUseLimit", "blizzardFlowGrid" }) do
      options[key].set(nil, true)
      Same(data[key], true, key .. " on")
      options[key].set(nil, false)
      Same(data[key], nil, key .. " off stores nil")
    end
    test.Environment.Advance(0.01)
    TakeOrder()

    -- sort variants
    local applyCalls, applyResult = 0, true
    local realApply = Display.ApplyFlowSort
    Display.ApplyFlowSort = function(applied) applyCalls = applyCalls + 1; Same(applied, data, "ApplyFlowSort data"); return applyResult end
    options.blizzardFlowSort.set(nil, "Name")
    Same(data.blizzardFlowSort, "Name", "sort stored")
    Same(applyCalls, 1, "ApplyFlowSort called")
    Same(TakeOrder(), "Add:Group", "hot sort only adds the group")
    test.Environment.Advance(0.01)
    Same(TakeOrder(), "", "hot sort defers nothing")
    applyResult = false
    options.blizzardFlowSort.set(nil, "Expiration")
    Same(TakeOrder(), "", "cold sort defers")
    test.Environment.Advance(0.01)
    Same(TakeOrder(), "Add:Group,Add:ChildA,Add:ChildB,Reset,Clear:Group", "cold sort full save")
    Display.ApplyFlowSort = realApply

    WeakAuras.GetData, WeakAuras.ClearAndUpdateOptions = realGetData, realClear
    WeakAuras.Add = function(added) addCalls[#addCalls + 1] = added end
  end

  -- icon
  do
    local icon = optionsPrivate.CreateModernGroupIcon()
    local width, height = icon:GetSize()
    Same(width .. "x" .. height, "32x32", "icon size")
    Same(Join(rawget(icon.tile1, "colorArguments")), "0.16,0.55,0.95,1", "tile1 color")
    Same(Join(rawget(icon.tile2, "colorArguments")), "0.35,0.75,1,1", "tile2 color")
    Same(Join(rawget(icon.tile3, "colorArguments")), "0.6,0.95,1,1", "tile3 color")
    local function Metrics(texture)
      local w, h = texture:GetSize()
      local _, _, _, x, y = texture:GetPoint(1)
      return string.format("%.4f,%.4f,%.4f,%.4f", w, h, x, y)
    end
    Same(Metrics(icon.tile1), "7.6800,7.6800,-9.6000,1.9200", "tile1 layout")
    Same(Metrics(icon.tile2), "7.6800,7.6800,0.0000,1.9200", "tile2 layout")
    Same(Metrics(icon.tile3), "7.6800,7.6800,9.6000,1.9200", "tile3 layout")
    icon:SetSize(100, 60)
    Same(Metrics(icon.tile1), "14.4000,14.4000,-18.0000,3.6000", "tile1 relayout min side")
    Same(Metrics(icon.tile3), "14.4000,14.4000,18.0000,3.6000", "tile3 relayout")
  end

  ---------------------------------------------------------------------------------------------------------------
  -- CDMDispel / CDMDispelBorder sub region options
  ---------------------------------------------------------------------------------------------------------------
  do
    local positionCalls, upDownCalls = {}, {}
    optionsPrivate.commonOptions.PositionOptionsForSubElement = function(data, options, start, areaAnchors, pointAnchors)
      positionCalls[#positionCalls + 1] = { data, options, start, areaAnchors, pointAnchors }
    end
    optionsPrivate.AddUpDownDeleteDuplicate = function(options, parentData, index, name)
      upDownCalls[#upDownCalls + 1] = { options, parentData, index, name }
    end
    local children = { { id = "A" }, { id = "B" } }
    local realTraverse, realAnchors = private.TraverseLeafsOrAura, private.GetAnchorsForData
    private.TraverseLeafsOrAura = function()
      local index = 0
      return function() index = index + 1; return children[index] end
    end
    private.GetAnchorsForData = function(child, kind)
      if child.id == "A" then return kind == "point" and { a = "pa", shared = "A" } or { area = "aa" } end
      return kind == "point" and { b = "pb", shared = "B" } or { area = "ab" }
    end

    for index, registration in ipairs(subRegionRegistrations) do
      positionCalls, upDownCalls = {}, {}
      local parent, data = { id = "Parent" }, { id = "Sub" }
      local options = registration.create(parent, data, 3, 2)
      Same(options.__order, 1, registration.name .. " __order")
      Same(options.dispelVisible.type, "toggle", registration.name .. " visible type")
      Same(options.dispelVisible.order, 1, registration.name .. " visible order")
      Same(options.dispelVisible.width, normal, registration.name .. " visible width")
      Same(#positionCalls, 1, registration.name .. " position calls")
      Same(positionCalls[1][1], data, "position data"); Same(positionCalls[1][2], options, "position options")
      Same(positionCalls[1][3], 10, "position start order")
      Same(positionCalls[1][4].area, "ab", "area anchors merged, last wins")
      Same(positionCalls[1][5].a, "pa", "point anchors merged A")
      Same(positionCalls[1][5].b, "pb", "point anchors merged B")
      Same(positionCalls[1][5].shared, "B", "point anchors last wins")
      Same(#upDownCalls, 1, registration.name .. " up/down calls")
      Same(upDownCalls[1][1], options, "up/down options"); Same(upDownCalls[1][2], parent, "up/down parent")
      Same(upDownCalls[1][3], 3, "up/down index"); Same(upDownCalls[1][4], registration.name, "up/down name")
      if index == 1 then
        Same(options.__title, "CDM Dispel Type Icon 2", "dispel title")
        Same(options.dispelVisible.name, "Show Icon", "dispel visible name")
        Same(options.dispelBorderSize, nil, "dispel has no thickness")
      else
        Same(options.__title, "Dispel Type Border 2", "border title")
        Same(options.dispelVisible.name, "Show Border", "border visible name")
        Fields(options.dispelBorderSize, { type = "range", control = "WeakAurasSpinBox", name = "Thickness", order = 2, step = 1,
          width = normal, min = 1, max = 32 }, "dispelBorderSize")
        Fields(options.dispelBorderOffset, { type = "range", control = "WeakAurasSpinBox", name = "Border Offset", order = 3, step = 1,
          width = normal, softMin = -16, softMax = 32 }, "dispelBorderOffset")
      end
    end
    private.TraverseLeafsOrAura, private.GetAnchorsForData = realTraverse, realAnchors
  end

  ---------------------------------------------------------------------------------------------------------------
  -- WeakAurasColorPicker widget
  ---------------------------------------------------------------------------------------------------------------
  do
    local widget = widgetRegistration[2]()
    Same(widget.type, "WeakAurasColorPicker", "widget.type")
    assert(widget.frame and widget.colorSwatch and widget.text, "widget parts")
    for _, name in ipairs({ "OnAcquire", "SetLabel", "SetColor", "SetHasAlpha", "SetDisabled" }) do
      assert(type(widget[name]) == "function", "widget method " .. name)
    end
    assert(widget.frame:GetScript("OnEnter") and widget.frame:GetScript("OnLeave") and widget.frame:GetScript("OnClick"), "scripts set")
    local swatch = widget.colorSwatch
    Same(Join({ swatch:GetSize() }), "19,19", "swatch size")
    Same(swatch:GetTexture(), 130939, "swatch texture")
    Same(Join({ swatch.background:GetSize() }), "16,16", "background size")
    Same(Join(rawget(swatch.background, "colorArguments")), "1,1,1", "background color")
    local checkers = swatch.checkers
    Same(Join({ checkers:GetSize() }), "14,14", "checkers size")
    Same(checkers:GetTexture(), 188523, "checkers texture")
    Same(Join({ checkers:GetTexCoord() }), "0.25,0,0.5,0.25", "checkers coordinates")
    Same(Join({ checkers:GetVertexColor() }), "1,1,1,0.75", "checkers tint")
    Same(checkers:IsDesaturated(), true, "checkers desaturated")

    widget:OnAcquire()
    Same(widget.disabled, nil, "not disabled")
    Same(widget.HasAlpha, false, "no alpha")
    Same(Join({ widget.r, widget.g, widget.b, widget.a }), "0,0,0,1", "default color")
    Same(Join({ widget.frame:GetSize() }), "200,24", "default size")
    Same(table.concat(widget.disabledCalls, ","), "Enable", "enabled on acquire")
    Same(Join(widget.text.textColor), "1,1,1", "label white")

    widget:SetLabel("Color")
    Same(widget.text:GetText(), "Color", "label text")
    widget:SetColor(0.5, nil, 0.25)
    Same(Join({ widget.r, widget.g, widget.b, widget.a }), "0.5,1,0.25,1", "absent components are 1")
    Same(#fired, 0, "SetColor fires nothing")
    widget:SetDisabled(true)
    Same(widget.disabled, true, "disabled")
    Same(Join(widget.text.textColor), "0.5,0.5,0.5", "label grey")
    Same(widget.disabledCalls[#widget.disabledCalls], "Disable", "frame disabled")
    widget:SetDisabled(false)
    Same(Join(widget.text.textColor), "1,1,1", "label white again")
    Same(widget.disabledCalls[#widget.disabledCalls], "Enable", "frame enabled")
    widget:SetHasAlpha(true)
    Same(widget.HasAlpha, true, "has alpha")

    widget.frame:GetScript("OnEnter")(widget.frame)
    widget.frame:GetScript("OnLeave")(widget.frame)
    Same(fired[1][1] .. "," .. fired[2][1], "OnEnter,OnLeave", "hover events")
    fired = {}

    widget:SetColor(0.2, 0.4, 0.6, 0.8)
    widget.frame:SetFrameLevel(5)
    local prepared, shown = 0, 0
    optionsPrivate.PrepareColorPalette = function(request) prepared = prepared + 1; request.prepared = true end
    optionsPrivate.ShowColorPalette = function() shown = shown + 1 end
    picker.visible = true
    local focusBefore = focusCleared
    widget.frame:GetScript("OnClick")(widget.frame)
    Same(picker.calls[1], "Hide", "picker hidden first")
    Same(picker.calls[2], "Setup", "picker shown")
    Same(picker.strata, "FULLSCREEN_DIALOG", "strata")
    Same(picker.level, 15, "frame level + 10")
    Same(picker.clamped, true, "clamped")
    local request = picker.request
    Same(Join({ request.r, request.g, request.b, request.opacity }), "0.2,0.4,0.6,0.8", "request color")
    Same(request.hasOpacity, true, "request hasOpacity")
    Same(request.prepared, true, "palette prepared the request")
    Same(prepared, 1, "PrepareColorPalette calls"); Same(shown, 1, "ShowColorPalette calls")
    Same(focusCleared - focusBefore, 1, "focus cleared")

    picker.r, picker.g, picker.b, picker.a = 0.9, 0.8, 0.7, 0.6
    request.swatchFunc()
    Same(fired[1][1], "OnValueChanged", "live change fires OnValueChanged")
    Same(Join({ select(2, unpack(fired[1])) }), "0.9,0.8,0.7,0.6", "live change values")
    request.swatchFunc()
    Same(#fired, 1, "unchanged color fires nothing")
    picker.a = 0.5
    request.opacityFunc()
    Same(fired[2][1], "OnValueChanged", "visible opacity change fires OnValueChanged")
    picker.visible = false
    picker.r = 0.1
    request.swatchFunc()
    Same(#fired, 2, "not visible, swatch change: silent")
    Same(widget.r, 0.1, "silent change still applied")
    picker.r = 0.3
    request.opacityFunc()
    Same(fired[3][1], "OnValueConfirmed", "confirmed when hidden")
    request.cancelFunc()
    Same(fired[4][1], "OnValueConfirmed", "cancel confirms")
    Same(Join({ select(2, unpack(fired[4])) }), "0.2,0.4,0.6,0.8", "cancel restores start color")

    fired = {}
    widget:SetHasAlpha(false)
    widget:SetColor(0.2, 0.4, 0.6, 1)
    picker.visible = true
    widget.frame:GetScript("OnClick")(widget.frame)
    request = picker.request
    Same(request.hasOpacity, false, "no opacity requested")
    picker.r, picker.g, picker.b, picker.a = 0.2, 0.4, 0.6, 0.3
    request.swatchFunc()
    Same(#fired, 0, "alpha ignored and color same")
    picker.r = 0.25
    request.swatchFunc()
    Same(Join({ select(2, unpack(fired[1])) }), "0.25,0.4,0.6,1", "alpha forced to 1")

    widget:SetDisabled(true)
    picker.calls = {}
    focusBefore, prepared = focusCleared, 0
    picker.visible = true
    widget.frame:GetScript("OnClick")(widget.frame)
    Same(table.concat(picker.calls, ","), "Hide", "disabled click only hides")
    Same(prepared, 0, "disabled click does not prepare")
    Same(focusCleared - focusBefore, 1, "disabled click clears focus")
  end

  CreateFrame = realCreateFrame
  WeakAuras.Add = realAdd
end

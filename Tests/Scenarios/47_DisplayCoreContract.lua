-- Contract of the core of BlizzardAuraDisplay (Apply, Release, Restore, Activate, Modify, queues, events), observed
-- through the exports of Private.BlizzardAuraDisplay, the shared fields of the display state, the effects on the
-- simulated frames, the warnings posted and the timers. Anchoring itself is covered by scenarios 44 and 46.
-- Native AuraContainer frames do not exist in the harness: a Frame with recording stubs stands in for each of them.
return function(test)
  local savedCreateFrame, savedPolicy = CreateFrame, CustomAuraContainerAuraProcessingPolicy
  local savedIsLoaded, savedLoadAddOn = C_AddOns.IsAddOnLoaded, C_AddOns.LoadAddOn
  local savedStringUtil = C_StringUtil
  local savedValidFilter = AuraUtil and AuraUtil.IsValidFilterString
  CustomAuraContainerAuraProcessingPolicy = { None = 0 }
  local containerAddonLoaded, loadCause = true, nil
  C_AddOns.IsAddOnLoaded = function(name)
    if name == "Blizzard_AuraContainer" then return containerAddonLoaded end
    return savedIsLoaded(name)
  end
  C_AddOns.LoadAddOn = function(name)
    if name == "Blizzard_AuraContainer" then return false, loadCause end
    return savedLoadAddOn(name)
  end
  C_StringUtil = C_StringUtil or {}
  C_StringUtil.CreateNumericRuleFormatter = C_StringUtil.CreateNumericRuleFormatter
    or function() return { SetBreakpoints = function() end } end
  AuraUtil = AuraUtil or {}
  AuraUtil.IsValidFilterString = function() return true end

  -- Containers: every call is recorded on the frame, in order.
  local containers = {}
  local noop = function() end
  local function NewContainer(name, parent)
    local container = savedCreateFrame("Frame", name, parent)
    containers[#containers + 1] = container
    container:SetFrameLevel(7)
    container.log, container.enabledValue, container.alphaBoolean = {}, nil, nil
    for _, method in ipairs({ "SetAuraProcessingPolicy", "SetUnit", "SetAuraSlotFilterString", "SetAuraSlotCandidateFilters",
      "SetAuraSlotSortMethod", "SetAuraGroupSortMethod", "SetAuraGroupFilterString", "SetAuraGroupCandidateFilters",
      "UpdateAllAuras", "SetAuraGroupLayout", "SetAuraGroupMaxFrameCount", "SetFlowLayoutAxis", "SetFlowLayoutAnchorPoint",
      "SetFlowLayoutGrowthDirection", "SetFlowLayoutMaximumLineSize", "SetAuraGroupEnabled" }) do
      container[method] = function(self, ...) self.log[#self.log + 1] = { name = method, ... } end
    end
    container.SetEnabled = function(self, value)
      self.enabledValue = value
      self.log[#self.log + 1] = { name = "SetEnabled", value }
    end
    container.AddAuraGroup = function(self, groupName, filter, settings)
      self.log[#self.log + 1] = { name = "AddAuraGroup", groupName, filter, settings }
    end
    container.AddAuraSlot = function(self, slotName, filter, settings)
      self.log[#self.log + 1] = { name = "AddAuraSlot", slotName, filter, settings }
      if slotName == "UnitGlow" then
        local button = savedCreateFrame("Frame", nil, self)
        button.AddAuraShownAnimation, button.RemoveAuraShownAnimation = noop, noop
        self.glowButton = button
        self.slotLevel = self:GetFrameLevel()
        button:SetFrameLevel(1)
        settings.initializeFrame(button)
      end
    end
    container.SetAlphaFromBoolean = function(self, value, whenTrue, whenFalse)
      self.alphaBoolean = { value = value, whenTrue = whenTrue, whenFalse = whenFalse }
      self.log[#self.log + 1] = { name = "SetAlphaFromBoolean", value, whenTrue, whenFalse }
    end
    return container
  end
  CreateFrame = function(frameType, name, parent, template)
    if frameType == "AuraContainer" then return NewContainer(name, parent) end
    return savedCreateFrame(frameType, name, parent, template)
  end
  local function Calls(container, name)
    local list = {}
    for _, entry in ipairs(container.log) do
      if entry.name == name then list[#list + 1] = entry end
    end
    return list
  end

  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local Secret, Units = test.Secret, test.Units
  local sortMethodsBefore, sortDirectionBefore = AuraContainerSortMethod, AuraContainerSortDirection
  AuraContainerSortMethod, AuraContainerSortDirection = setmetatable({}, { __index = function() return 0 end }),
    { Normal = 0, Reverse = 1 }

  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function Near(actual, expected, message)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-6,
      ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function Truthy(value, message) assert(value, message) end

  -- Switches.
  local restricted, optionsOpen, loginFinished = false, false, true
  local originals = {
    IsRestricted = WeakAuras.IsRestricted, IsOptionsOpen = WeakAuras.IsOptionsOpen, GetData = WeakAuras.GetData,
    IsLoginFinished = WeakAuras.IsLoginFinished, UpdateWarning = private.AuraWarnings.UpdateWarning,
    debugprofilestop = debugprofilestop, GetUnitFrame = WeakAuras.GetUnitFrame,
    GetNamePlateForUnit = C_NamePlate and C_NamePlate.GetNamePlateForUnit,
    GetNamePlates = C_NamePlate and C_NamePlate.GetNamePlates,
  }
  WeakAuras.IsRestricted = function() return restricted end
  WeakAuras.IsOptionsOpen = function() return optionsOpen end
  WeakAuras.IsLoginFinished = function() return loginFinished end
  local clockMs, clockStep = 0, 0
  debugprofilestop = function()
    clockMs = clockMs + clockStep
    return clockMs
  end
  local store = {}
  WeakAuras.GetData = function(id) return store[id] or originals.GetData(id) end
  local unitFrames, plates, plateList = {}, {}, {}
  WeakAuras.GetUnitFrame = function(unit) return unitFrames[unit] end
  C_NamePlate = C_NamePlate or {}
  C_NamePlate.GetNamePlateForUnit = function(unit) return plates[unit] end
  C_NamePlate.GetNamePlates = function() return plateList end

  -- Warnings posted through Internal.AuraWarnings.UpdateWarning: warnings[uid][key] = { severity, text } or nil.
  local warnings = {}
  private.AuraWarnings.UpdateWarning = function(uid, key, severity, text)
    warnings[uid] = warnings[uid] or {}
    warnings[uid][key] = severity and { severity = severity, text = text } or nil
  end
  local function Warning(uid, key) return warnings[uid] and warnings[uid][key] end

  -- Aura data and regions.
  local function Data(id, options)
    options = options or {}
    local data = {
      id = id, uid = id, regionType = options.regionType or "icon", width = 30, height = 30,
      anchorFrameType = options.anchorFrameType or "SCREEN", parent = options.parent,
      triggers = { { trigger = { type = "secretAura", unit = options.unit or "player", debuffType = "HELPFUL" } } },
      blizzardAuraDisplay = options.display or {},
    }
    for key, value in pairs(options.trigger or {}) do data.triggers[1].trigger[key] = value end
    for key, value in pairs(options.extra or {}) do data[key] = value end
    store[id] = data
    return data
  end
  local function NewRegion(id)
    local region = savedCreateFrame("Frame")
    region:Show()
    if id then private.regions[id] = { region = region } end
    return region
  end
  local function Mount(id, options)
    local data = Data(id, options)
    local region = NewRegion(id)
    assert(Display.Validate(data) == nil, tostring(Display.Validate(data)))
    Display.Apply(region, data)
    return region, data, region.blizzardAuraDisplay
  end
  local function Drain(seconds) test.Environment.Advance(seconds or 0.1) end
  -- Timers: held ones run one pass at a time with Pass(); otherwise the harness clock runs them.
  local originalAfter = C_Timer.After
  local held, holdTimers = {}, false
  C_Timer.After = function(delay, callback)
    if holdTimers and debug.getinfo(callback, "S").short_src:find("BlizzardAuraDisplay", 1, true) then
      held[#held + 1] = { delay = delay, callback = callback }
    else
      originalAfter(delay, callback)
    end
  end
  local function Pass()
    local list = held
    held = {}
    for _, timer in ipairs(list) do timer.callback() end
    return list
  end

  ------------------------------------------------------------------------------------------------
  -- A. Apply: parts hidden, early exits, warnings, restriction, missing extension, preview batches.
  ------------------------------------------------------------------------------------------------
  local function WithParts(region)
    region.icon, region.cooldown = savedCreateFrame("Frame"), savedCreateFrame("Frame")
    region.icon:SetAlpha(0.7)
    region.cooldown:SetAlpha(0.4)
    return region
  end
  do
    local data = Data("ApplyOk")
    local region = WithParts(NewRegion("ApplyOk"))
    local detached = savedCreateFrame("Frame")
    detached:SetAlpha(0.9)
    detached.secretAuraDetached = true
    local plain = savedCreateFrame("Frame")
    plain:SetAlpha(0.8)
    region.subRegions = { detached, plain }
    Display.Apply(region, data)
    local state = region.blizzardAuraDisplay
    assert(state and state.active == true, "valid aura not active")
    Same(state.data, data, "state data")
    Same(state.generation, 1, "first generation")
    Same(#state.instances, 1, "one instance for player")
    Same(state.appliedTrigger, data.triggers[1].trigger, "applied trigger")
    Same(Warning("ApplyOk", "blizzard_aura_display"), nil, "no display warning for a valid aura")
    Same(region.icon:GetAlpha(), 0, "icon hidden")
    Same(region.cooldown:GetAlpha(), 0, "cooldown hidden")
    Same(plain:GetAlpha(), 0, "sub region hidden")
    Same(detached:GetAlpha(), 0.9, "detached sub region kept")
    Same(region.blizzardSuppressed[region.icon], 0.7, "icon alpha remembered")
    Same(region.blizzardSuppressed[detached], nil, "detached sub region not remembered")
    Display.Apply(region, data)
    Same(state.generation, 2, "generation grows on each apply")
    Same(region.blizzardSuppressed[region.icon], 0.7, "alpha remembered once, not the hidden 0")
    Same(#state.instances, 1, "instances kept")
    Same(region.blizzardAuraDisplay, state, "state kept")
  end

  -- Not enabled: released with the grid, warnings cleared, parts untouched.
  do
    local region, data, state = Mount("ApplyOff")
    state.gridMember = true
    state.instances[1].container:Show()
    warnings.ApplyOff.blizzard_aura_display = { severity = "warning", text = "old" }
    warnings.ApplyOff.blizzard_aura_sound = { severity = "warning", text = "old" }
    local off = Data("ApplyOff", { regionType = "model" })
    Display.Apply(region, off)
    Same(state.active, false, "released state inactive")
    Same(state.gridMember, nil, "released with leaveGrid")
    Same(state.instances[1].container.enabledValue, false, "container disabled")
    Same(state.instances[1].container:IsShown(), false, "container hidden")
    Same(Warning("ApplyOff", "blizzard_aura_display"), nil, "display warning cleared")
    Same(Warning("ApplyOff", "blizzard_aura_sound"), nil, "sound warning cleared")
    Same(Warning("ApplyOff", "blizzard_aura_single"), nil, "single warning cleared")
    Same(Warning("ApplyOff", "blizzard_aura_grid"), nil, "grid warning cleared")
    -- A fresh region that is not enabled gets no state and its parts are not hidden.
    local fresh = WithParts(NewRegion())
    Display.Apply(fresh, Data("ApplyOffFresh", { regionType = "model" }))
    Same(fresh.blizzardAuraDisplay, nil, "no state for a disabled aura")
    Same(fresh.icon:GetAlpha(), 0.7, "parts untouched for a disabled aura")
  end

  -- Invalid: parts hidden first, then released with the grid and the issue posted.
  do
    local region, _, state = Mount("ApplyBad")
    state.gridMember = true
    local bad = Data("ApplyBad", { unit = "bogus" })
    WithParts(region)
    Display.Apply(region, bad)
    Same(state.active, false, "invalid aura inactive")
    Same(state.gridMember, nil, "invalid aura leaves the grid")
    local warning = Warning("ApplyBad", "blizzard_aura_display")
    assert(warning and warning.severity == "warning", "issue not posted")
    Same(warning.text, "Choose a supported unit and Buff or Debuff.", "issue text")
    Same(region.icon:GetAlpha(), 0.7, "parts given back by the release of an invalid aura")
    Same(region.blizzardSuppressed, nil, "suppressed list dropped by the release")
    Display.Apply(region, Data("ApplyBad"))
    Same(Warning("ApplyBad", "blizzard_aura_display"), nil, "issue cleared once valid")
    Same(state.active, true, "valid again")
  end

  -- Dynamic group warning.
  do
    store.DynGroup = { id = "DynGroup", uid = "DynGroup", regionType = "dynamicgroup", controlledChildren = { "InDyn" } }
    local region = NewRegion("InDyn")
    Display.Apply(region, Data("InDyn", { parent = "DynGroup" }))
    local warning = Warning("InDyn", "blizzard_aura_dynamicgroup")
    assert(warning and warning.severity == "warning", "dynamic group warning missing")
    Same(warning.text, Display.dynamicGroupWarning, "dynamic group warning text")
    Display.Apply(region, Data("InDyn"))
    Same(Warning("InDyn", "blizzard_aura_dynamicgroup"), nil, "dynamic group warning cleared")
  end

  -- Restriction: nothing built, text posted, applied once the restriction ends.
  do
    local data = Data("ApplyLater")
    local region = NewRegion("ApplyLater")
    restricted = true
    Display.Apply(region, data)
    Same(region.blizzardAuraDisplay, nil, "no state under restriction")
    local warning = Warning("ApplyLater", "blizzard_aura_display")
    assert(warning and warning.severity == "warning", "restriction warning missing")
    Same(warning.text, "Display > Aura (Modern) Settings changes will apply when the game stops hiding combat data.", "restriction text")
    Drain(1)
    Same(region.blizzardAuraDisplay, nil, "still nothing while restricted")
    restricted = false
    private.callbacks:Fire("RestrictionChanged", false)
    Drain(0.1)
    assert(region.blizzardAuraDisplay and region.blizzardAuraDisplay.active, "queued apply not run after the restriction")
    Same(Warning("ApplyLater", "blizzard_aura_display"), nil, "restriction warning cleared by the queued apply")
    -- The restriction check comes after the validation: an invalid aura shows its issue, not the restriction text.
    restricted = true
    Display.Apply(NewRegion(), Data("ApplyLaterBad", { unit = "bogus" }))
    Same(Warning("ApplyLaterBad", "blizzard_aura_display").text, "Choose a supported unit and Buff or Debuff.", "issue before restriction")
    restricted = false
  end

  -- Extension missing.
  do
    containerAddonLoaded, loadCause = false, "MISSING"
    local region = NewRegion()
    Display.Apply(region, Data("NoExtension"))
    Same(region.blizzardAuraDisplay, nil, "no state without the extension")
    Same(Warning("NoExtension", "blizzard_aura_display").text, "Cannot load Blizzard_AuraContainer: MISSING", "extension text")
    loadCause = nil
    Display.Apply(region, Data("NoExtension"))
    Same(Warning("NoExtension", "blizzard_aura_display").text, "Cannot load Blizzard_AuraContainer: nil", "extension text without cause")
    containerAddonLoaded = true
  end


  ------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------
  -- B. Release, Restore, HideUnitGlows.
  ------------------------------------------------------------------------------------------------
  do
    local region, data, state = Mount("ReleaseKeep")
    state.gridMember = true
    local instance = state.instances[1]
    warnings.ReleaseKeep.blizzard_aura_display = { severity = "warning", text = "kept" }
    for _, key in ipairs({ "blizzard_aura_single", "blizzard_aura_dynamicgroup", "blizzard_aura_grid" }) do
      warnings.ReleaseKeep[key] = { severity = "warning", text = "old" }
    end
    Display.Release(region)
    Same(state.active, false, "released state inactive")
    Same(state.gridMember, true, "grid membership kept without leaveGrid")
    Same(state.instances[1], instance, "instances kept by a release")
    Same(instance.container.enabledValue, false, "container disabled")
    Same(instance.container:IsShown(), false, "container hidden")
    Same(state.instanceQueue, nil, "instance queue dropped")
    assert(Warning("ReleaseKeep", "blizzard_aura_display"), "release must not clear the display warning")
    for _, key in ipairs({ "blizzard_aura_single", "blizzard_aura_dynamicgroup", "blizzard_aura_grid" }) do
      Same(Warning("ReleaseKeep", key), nil, key .. " cleared by a release")
    end
    Display.Release(region, true)
    Same(state.gridMember, nil, "leaveGrid forgets the membership")
    -- A region that never had a state is released without error.
    Display.Release(NewRegion())
    -- A release drops the pending apply of a restricted region.
    local data2 = Data("ReleaseQueued")
    local region2 = NewRegion("ReleaseQueued")
    restricted = true
    Display.Apply(region2, data2)
    Display.Release(region2)
    restricted = false
    private.callbacks:Fire("RestrictionChanged", false)
    Drain(0.5)
    Same(region2.blizzardAuraDisplay, nil, "released region not applied by the queue")
  end

  -- Restore: alphas, condition values, notice, and only the wrappers that are still ours.
  do
    local region, data = Mount("RestoreAll")
    region.icon = savedCreateFrame("Frame")
    region.icon:SetAlpha(0.6)
    Display.Activate(region, data)
    local state = region.blizzardAuraDisplay
    Same(region.icon:GetAlpha(), 0, "icon hidden by the activation")
    local update, preShow = region.Update, region.PreShow
    assert(type(update) == "function" and type(preShow) == "function", "wrappers not installed")
    region.secretAuraConditionValues = { a = 1 }
    region.secretAuraPreviewNotice = savedCreateFrame("Frame")
    region.secretAuraPreviewNotice:Show()
    Display.Restore(region)
    Same(region.icon:GetAlpha(), 0.6, "icon alpha given back")
    Same(region.blizzardSuppressed, nil, "suppressed list dropped")
    Same(region.secretAuraConditionValues, nil, "condition values dropped")
    Same(region.secretAuraPreviewNotice:IsShown(), false, "notice hidden")
    Same(region.blizzardOriginalUpdate, nil, "update record dropped")
    Same(region.blizzardOriginalPreShow, nil, "preshow record dropped")
    assert(region.Update ~= update, "update wrapper left installed")
    assert(region.PreShow ~= preShow, "preshow wrapper left installed")

    -- A function installed after the wrapper stays.
    Display.Activate(region, data)
    local newer = function() end
    region.Update, region.PreShow = newer, newer
    Display.Restore(region)
    Same(region.Update, newer, "newer Update kept")
    Same(region.PreShow, newer, "newer PreShow kept")
    Same(region.blizzardOriginalUpdate, nil, "update record dropped although the function is newer")
    Same(state.data, data, "restore leaves the display state alone")
  end

  -- HideUnitGlows: glow holders of every instance, flag on the state.
  do
    local frame = savedCreateFrame("Frame")
    frame:SetSize(50, 40)
    unitFrames.target = frame
    local region, data, state = Mount("GlowHidden", { unit = "target", anchorFrameType = "UNITFRAME",
      display = { unitGlow = true } })
    local glow = state.instances[1].unitGlow
    assert(glow, "unit glow not created")
    Display.HideUnitGlows(NewRegion())
    Display.HideUnitGlows(region)
    Same(state.unitGlowsHidden, true, "unitGlowsHidden flag")
    Same(glow.container.enabledValue, false, "glow container disabled")
    Same(glow.container:IsShown(), false, "glow container hidden")
    Display.Apply(region, data)
    Same(state.unitGlowsHidden, false, "apply shows the glows again")
    Same(glow.container:IsShown(), true, "glow container shown by the apply")
    Display.HideUnitGlows(region)
    Display.Release(region)
    Same(state.unitGlowsHidden, true, "release hides the glows")
    unitFrames.target = nil
  end

  -- @insert
  ------------------------------------------------------------------------------------------------
  -- E. Main event handler: scale, nameplate tokens, mode filter, replay after combat, restrictions.
  ------------------------------------------------------------------------------------------------
  local function Updates(state)
    local count = 0
    for _, instance in ipairs(state.instances) do count = count + #Calls(instance.container, "SetEnabled") end
    return count
  end

  -- Screen scale: every live display is applied again, nothing else runs.
  do
    local _, _, first = Mount("ScaleFirst")
    local _, _, second = Mount("ScaleSecond", { unit = "target" })
    for _, eventName in ipairs({ "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED" }) do
      local before = first.generation
      test.Frames.Fire(eventName)
      Same(first.generation, before + 1, eventName .. " applies the display again")
    end
    Same(second.generation, 3, "every live display is applied again")
    local updates = Updates(second)
    test.Frames.Fire("UI_SCALE_CHANGED")
    Same(second.generation, 4, "applied once per event")
    Display.Release(private.regions.ScaleFirst.region)
    local released = first.generation
    test.Frames.Fire("UI_SCALE_CHANGED")
    Same(first.generation, released, "a released display is not applied again")
  end

  -- Nameplate tokens grow by steps of 10 and rebuild only the nameplate displays.
  do
    local _, _, plate = Mount("PlateAura", { unit = "nameplate" })
    local _, _, other = Mount("PlateOther", { unit = "target" })
    Same(#plate.instances, 40, "tokens start at the floor of 40")
    local plateGeneration, otherGeneration = plate.generation, other.generation
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate25")
    Same(#plate.instances, 40, "a token inside the list does not grow it")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate40")
    Same(plate.generation, plateGeneration, "token 40 is covered by the floor of 40")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate41")
    Same(#plate.instances, 60, "token 41 grows the list to 60")
    Same(plate.generation, plateGeneration + 1, "nameplate display rebuilt once")
    Same(other.generation, otherGeneration, "other displays are not rebuilt")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate60")
    Same(#plate.instances, 60, "token 60 fits")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate61")
    Same(#plate.instances, 80, "token 61 grows the list to 80")
    local generation = plate.generation
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "target")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplatex")
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", Secret.Wrap("nameplate500"))
    Same(plate.generation, generation, "tokens that are not plates are ignored")
    -- The rebuild goes through the budgeted queue.
    holdTimers, clockStep = true, 8
    local other_plate = select(3, Mount("PlateSecond", { unit = "nameplate" }))
    local firstGeneration, secondGeneration = plate.generation, other_plate.generation
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate81")
    Same((plate.generation - firstGeneration) + (other_plate.generation - secondGeneration), 1,
      "one rebuild per pass when the budget is spent")
    while #Pass() > 0 do end
    Same(plate.generation, firstGeneration + 1, "first nameplate display rebuilt")
    Same(other_plate.generation, secondGeneration + 1, "second nameplate display rebuilt")
    holdTimers, held, clockStep = false, {}, 0
    -- A rebuild queued under restriction waits for the end of it.
    restricted = true
    local restrictedGeneration = plate.generation
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate101")
    Same(plate.generation, restrictedGeneration, "no rebuild under restriction")
    restricted = false
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(plate.generation, restrictedGeneration + 1, "rebuilt by the next event once the restriction ends")
  end

  -- After a /reload the plates already shown are read when the world is entered.
  do
    local _, _, plate = Mount("PlateReload", { unit = "nameplate" })
    local before = #plate.instances
    plateList = { { unitToken = "nameplate" .. (before + 5) }, { unitToken = "target" } }
    C_NamePlate.GetNamePlates = function() return plateList end
    test.Frames.Fire("PLAYER_ENTERING_WORLD")
    Same(#plate.instances, before, "nothing before the timer")
    Drain(0.1)
    assert(#plate.instances > before, "plates shown at login not read")
    plateList = {}
  end

  -- The unit events reach only the modes that watch them.
  do
    local function Reacts(unit, eventName, eventUnit, trigger)
      local _, _, state = Mount("Mode" .. unit .. eventName .. tostring(eventUnit), { unit = unit, trigger = trigger })
      local before = Updates(state)
      test.Frames.Fire(eventName, eventUnit)
      return Updates(state) > before
    end
    local cases = {
      { "target", "PLAYER_TARGET_CHANGED", nil, true },
      { "target", "PLAYER_FOCUS_CHANGED", nil, false },
      { "target", "GROUP_ROSTER_UPDATE", nil, false },
      { "target", "PLAYER_REGEN_ENABLED", nil, false },
      { "target", "ADDON_RESTRICTION_STATE_CHANGED", nil, false },
      { "targettarget", "PLAYER_TARGET_CHANGED", nil, true },
      { "targettarget", "UNIT_TARGET", "target", true },
      { "targettarget", "UNIT_TARGET", "focus", false },
      { "focus", "PLAYER_FOCUS_CHANGED", nil, true },
      { "focus", "PLAYER_TARGET_CHANGED", nil, false },
      { "focustarget", "PLAYER_FOCUS_CHANGED", nil, true },
      { "focustarget", "UNIT_TARGET", "focus", true },
      { "focustarget", "UNIT_TARGET", "target", false },
      { "mouseover", "UPDATE_MOUSEOVER_UNIT", nil, true },
      { "mouseover", "PLAYER_TARGET_CHANGED", nil, false },
      { "party", "GROUP_ROSTER_UPDATE", nil, true },
      { "party", "PLAYER_ROLES_ASSIGNED", nil, true },
      { "party", "UNIT_NAME_UPDATE", "party1", true },
      { "party", "PLAYER_TARGET_CHANGED", nil, false },
      { "boss", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", nil, true },
      { "boss", "GROUP_ROSTER_UPDATE", nil, false },
      { "arena", "ARENA_OPPONENT_UPDATE", "arena1", true },
      { "arena", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", nil, false },
      { "pet", "UNIT_PET", "player", true },
      { "pet", "UNIT_PET", "party1", false },
      { "party", "UNIT_PET", "party1", false },
      { "player", "GROUP_ROSTER_UPDATE", nil, false },
      { "member", "GROUP_ROSTER_UPDATE", nil, true, { specificUnit = "party1" } },
    }
    for _, case in ipairs(cases) do
      Same(Reacts(case[1], case[2], case[3], case[5]), case[4], case[1] .. " on " .. case[2] .. " " .. tostring(case[3]))
    end
    Same(Reacts("party", "UNIT_PET", "party1", { use_includePets = true }), true, "party with pets reacts to UNIT_PET")
    Same(Reacts("raid", "UNIT_PET", "raid1", { use_includePets = true }), true, "raid with pets reacts to UNIT_PET")
    Same(Reacts("boss", "UNIT_PET", "player", { use_includePets = true }), false, "boss never reacts to UNIT_PET")
  end

  -- Combat locks a protected container; the replay runs when combat ends, once.
  do
    local frame = savedCreateFrame("Frame")
    unitFrames.target = frame
    local region, _, state = Mount("LockedReplay", { unit = "target", anchorFrameType = "UNITFRAME" })
    local container = state.instances[1].container
    test.Frames.SetProtected(container, true)
    test.Units.SetCombat(true)
    local lockedAt = Updates(state)
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(Updates(state), lockedAt, "locked container not updated in combat")
    test.Frames.SetProtected(container, false)
    test.Units.SetCombat(false)
    local replayed = Updates(state)
    assert(replayed > lockedAt, "locked region not replayed when combat ends")
    test.Frames.Fire("PLAYER_REGEN_ENABLED")
    Same(Updates(state), replayed, "replayed once")
    -- A region released meanwhile is not replayed.
    test.Frames.SetProtected(container, true)
    test.Units.SetCombat(true)
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Display.Release(region)
    local released = Updates(state)
    test.Frames.SetProtected(container, false)
    test.Units.SetCombat(false)
    Same(Updates(state), released, "released region not replayed")
    Same(container.enabledValue, false, "container released in combat is disabled")
    Same(container:IsShown(), false, "container released in combat is hidden")
    test.Frames.SetProtected(container, false)
    test.Units.SetCombat(false)
    Same(container.enabledValue, false, "released container still disabled after combat")
    Same(container:IsShown(), false, "released container still hidden after combat")
    unitFrames.target = nil
  end

  -- Hiding and showing the region: glows and containers follow, in combat or not.
  do
    local frame = savedCreateFrame("Frame")
    frame:SetSize(50, 40)
    unitFrames.target = frame
    local region, _, state = Mount("HideShow", { unit = "target", anchorFrameType = "UNITFRAME",
      display = { unitGlow = true } })
    local container, glow = state.instances[1].container, state.instances[1].unitGlow
    Same(container:IsShown(), true, "container shown before the hide")
    Same(glow.container:IsShown(), true, "glow shown before the hide")
    test.Frames.SetProtected(container, true)
    test.Units.SetCombat(true)
    region:Hide()
    Same(state.unitGlowsHidden, true, "hide flags the glows")
    Same(glow.container:IsShown(), false, "glow hidden with the region")
    Same(glow.container.enabledValue, false, "glow disabled with the region")
    Same(container.enabledValue, false, "container disabled with the region, in combat")
    Same(container:IsShown(), false, "container hidden with the region, in combat")
    local hiddenAt = Updates(state)
    test.Frames.SetProtected(container, false)
    test.Units.SetCombat(false)
    Same(container.enabledValue, false, "hidden region keeps its container disabled after combat")
    Same(container:IsShown(), false, "hidden region keeps its container hidden after combat")
    region:Show()
    Same(state.unitGlowsHidden, false, "show clears the glow flag")
    assert(Updates(state) > hiddenAt, "units not refreshed when the region is shown")
    Same(container.enabledValue, true, "container enabled again by the show")
    Same(container:IsShown(), true, "container shown again by the show")
    Same(glow.container:IsShown(), true, "glow shown again by the show")
    region:Hide()
    test.Frames.SetProtected(container, true)
    test.Units.SetCombat(true)
    local shownInCombat = Updates(state)
    region:Show()
    Same(state.unitGlowsHidden, false, "show in combat clears the glow flag")
    Same(Updates(state), shownInCombat, "locked container left alone by a show in combat")
    test.Frames.SetProtected(container, false)
    test.Units.SetCombat(false)
    assert(Updates(state) > shownInCombat, "locked container not refreshed once combat ends")
    Same(container.enabledValue, true, "container enabled after the replay")
    Display.Release(region)
    region:Hide()
    local inactive = Updates(state)
    region:Show()
    Same(Updates(state), inactive, "inactive display not refreshed by a show")
    unitFrames.target = nil
  end

  -- Aura sounds: registered with the client, refreshed by roster events, flushed after a restriction.
  do
    local savedAdd, savedRemove = C_UnitAuras.AddAuraSound, C_UnitAuras.RemoveAuraSound
    local savedTriggers = Enum.UnitAuraSoundTrigger
    local added, removedSounds = {}, 0
    C_UnitAuras.AddAuraSound = function(trigger, info)
      added[#added + 1] = { trigger = trigger, info = info }
      return 500 + #added
    end
    C_UnitAuras.RemoveAuraSound = function() removedSounds = removedSounds + 1 end
    Enum.UnitAuraSoundTrigger = { Added = 1, Removed = 2 }
    local function Sounded(id, unit, sound)
      return Mount(id, { unit = unit, trigger = { auraspellids = { 1234 } },
        extra = { actions = { start = { do_sound = true, sound = sound }, finish = {} } } })
    end

    local soundRegion, data, state = Sounded("SoundParty", "party", "Sound\\First.ogg")
    assert(#added > 0, "sound not registered on apply")
    Same(added[1].trigger, 1, "start sound uses the Added trigger")
    Same(added[1].info.spellID, 1234, "sound spell")
    Same(added[1].info.soundFileName, "Sound\\First.ogg", "sound file")
    Same(added[1].info.outputChannel, "Master", "sound channel")
    Same(#state.soundIDs, #added, "every registration remembered")
    local removedByHide = removedSounds
    soundRegion:Hide()
    assert(removedSounds > removedByHide, "hiding the region does not remove its sounds")
    soundRegion:Show()

    local function Registrations(eventName, eventUnit, change)
      local before = #added
      data.actions.start.sound = change
      test.Frames.Fire(eventName, eventUnit)
      return #added - before
    end
    assert(Registrations("GROUP_ROSTER_UPDATE", nil, "Sound\\Second.ogg") > 0, "roster event does not refresh the sounds")
    assert(Registrations("PLAYER_ROLES_ASSIGNED", nil, "Sound\\Third.ogg") > 0, "roles event does not refresh the sounds")
    Same(Registrations("PLAYER_TARGET_CHANGED", nil, "Sound\\Fourth.ogg"), 0, "target event leaves the sounds alone")
    Same(Registrations("UNIT_NAME_UPDATE", "party1", "Sound\\Fifth.ogg"), 0, "name event without unit names leaves the sounds alone")
    Same(Registrations("UNIT_PET", "party1", "Sound\\Sixth.ogg"), 0, "pet event without pets leaves the sounds alone")
    data.triggers[1].trigger.use_includePets = true
    assert(Registrations("UNIT_PET", "party1", "Sound\\Seventh.ogg") > 0, "pet event with pets does not refresh the sounds")
    data.triggers[1].trigger.use_includePets = nil
    data.triggers[1].trigger.useUnitNames = true
    local savedUnitName = private.ExecEnv.UnitName
    private.ExecEnv.UnitName = function() return "Someone" end
    local removedBefore = removedSounds
    Registrations("UNIT_NAME_UPDATE", "party1", "Sound\\Eighth.ogg")
    assert(removedSounds > removedBefore, "name event with unit names does not refresh the sounds")
    data.triggers[1].trigger.useUnitNames = nil
    private.ExecEnv.UnitName = savedUnitName
    assert(removedSounds > 0, "former registrations not removed")

    local _, otherData = Sounded("SoundTarget", "target", "Sound\\Target.ogg")
    local targetBefore = #added
    otherData.actions.start.sound = "Sound\\Target2.ogg"
    test.Frames.Fire("GROUP_ROSTER_UPDATE")
    local fromTarget = 0
    for index = targetBefore + 1, #added do
      if added[index].info.soundFileName == "Sound\\Target2.ogg" then fromTarget = fromTarget + 1 end
    end
    Same(fromTarget, 0, "target display does not refresh its sounds on a roster event")

    local before = #added
    restricted = true
    data.actions.start.sound = "Sound\\Ninth.ogg"
    test.Frames.Fire("GROUP_ROSTER_UPDATE")
    restricted = false
    Same(#added, before, "no registration under restriction")
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    assert(#added > before, "queued sound synchronisation not flushed by the next event")
    local flushed = #added
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(#added, flushed, "synchronisation flushed once")

    C_UnitAuras.AddAuraSound, C_UnitAuras.RemoveAuraSound = savedAdd, savedRemove
    Enum.UnitAuraSoundTrigger = savedTriggers
  end

  -- Text style: font and outline defaults.
  do
    local function Style(settings)
      local used = {}
      local label = {
        SetFontObject = noop, SetTextColor = noop, ClearAllPoints = noop, SetPoint = noop, SetJustifyH = noop,
        SetFont = function(_, path, size, flags) used.path, used.size, used.flags = path, size, flags end,
        GetFont = function() return used.path end,
      }
      local button = savedCreateFrame("Frame")
      Display.StyleText(label, { button = button, inner = button, outer = button }, settings, "count", 12, "CENTER")
      return used
    end
    Same(Style({}).path, "Fonts\\ARIALN.TTF", "missing font")
    Same(Style({ countFont = "Friz Quadrata TT" }).path, "Fonts\\FRIZQT__.TTF", "named font")
    Same(Style({}).flags, "OUTLINE", "missing outline")
    Same(Style({ countOutline = false }).flags, "OUTLINE", "outline set to false")
    Same(Style({ countOutline = "None" }).flags, "", "outline None")
    Same(Style({ countOutline = "THICKOUTLINE" }).flags, "THICKOUTLINE", "outline kept")
    Same(Style({}).size, 12, "size from the icon")
    Same(Style({ countSize = 20 }).size, 20, "size from the settings")
  end

  -- Plate removal, instance removal, unit glow rebuild.
  do
    local plateFrame = savedCreateFrame("Frame")
    plateFrame:SetSize(40, 10)
    plates.nameplate1 = plateFrame
    local _, _, plateState = Mount("PlateRemoved", { unit = "nameplate" })
    test.Frames.Fire("NAME_PLATE_UNIT_ADDED", "nameplate1")
    Same(plateState.instances[1].container:IsShown(), true, "plate instance shown once the plate is added")
    test.Frames.Fire("NAME_PLATE_UNIT_REMOVED", "nameplate1")
    Same(plateState.instances[1].container:IsShown(), false, "plate instance hidden once the plate is removed")
    plates.nameplate1 = nil

    local shrinkRegion, shrinkData, shrinkState = Mount("Shrinking", { unit = "nameplate" })
    local dropped = shrinkState.instances[#shrinkState.instances]
    assert(#shrinkState.instances > 1, "several instances expected")
    dropped.container:SetEnabled(true)
    local droppedLogged = #dropped.container.log
    shrinkData.triggers[1].trigger.unit = "target"
    Display.Apply(shrinkRegion, shrinkData)
    Same(#shrinkState.instances, 1, "instances reduced")
    Same(dropped.container.enabledValue, false, "removed instance disabled")
    local disables = 0
    for index = droppedLogged + 1, #dropped.container.log do
      local entry = dropped.container.log[index]
      if entry.name == "SetEnabled" and entry[1] == false then disables = disables + 1 end
    end
    assert(disables >= 2, "removal and retirement each disable the container")
    Same(dropped.container:IsShown(), false, "removed instance hidden")

    local frame = savedCreateFrame("Frame")
    frame:SetSize(50, 40)
    unitFrames.target = frame
    local glowRegion, glowData, glowState = Mount("GlowRebuilt", { unit = "target", anchorFrameType = "UNITFRAME",
      display = { unitGlow = true } })
    local glow = glowState.instances[1].unitGlow
    Same(glow.overlay:GetFrameLevel(), glow.container.slotLevel + 2, "glow overlay level")
    Same(glow.button:GetFrameLevel(), glow.container.slotLevel + 1, "glow button level")
    local probeCalls = 0
    glow.button.SetDispelTypeText = function() probeCalls = probeCalls + 1 end
    local logged = #glow.container.log
    Display.Apply(glowRegion, glowData)
    Same(probeCalls, 1, "glow animations refreshed by the second apply")
    local disabled = 0
    for index = logged + 1, #glow.container.log do
      local entry = glow.container.log[index]
      if entry.name == "SetEnabled" and entry[1] == false then disabled = disabled + 1 end
    end
    assert(disabled > 0, "glow container not disabled by the second apply")
    Display.Release(glowRegion)
    unitFrames.target = nil
  end

  -- Condition appearance refresh and the queued applies replay.
  do
    local refreshed = 0
    local realRefresh = Display.RefreshConditionAppearance
    Display.RefreshConditionAppearance = function() refreshed = refreshed + 1 end
    local _, _, state = Mount("RefreshRegion", { unit = "target" })
    for _, eventName in ipairs({ "PLAYER_REGEN_ENABLED", "ADDON_RESTRICTION_STATE_CHANGED", "PLAYER_ENTERING_WORLD" }) do
      refreshed = 0
      test.Frames.Fire(eventName)
      assert(refreshed > 0, eventName .. " does not refresh the condition appearance")
    end
    refreshed = 0
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(refreshed, 0, "other events do not refresh the condition appearance")
    restricted = true
    test.Frames.Fire("PLAYER_REGEN_ENABLED")
    restricted = false
    Same(refreshed, 0, "no refresh under restriction")
    Display.RefreshConditionAppearance = realRefresh
    -- A queued apply is replayed by any event once the restriction ends.
    local region, data = Mount("EventReplay", { unit = "target" })
    restricted = true
    Display.Apply(region, data)
    local before = private.regions.EventReplay and region.blizzardAuraDisplay.generation
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(region.blizzardAuraDisplay.generation, before, "no replay under restriction")
    restricted = false
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    Same(region.blizzardAuraDisplay.generation, before + 1, "queued apply replayed by the event")
    Same(state.active, true, "other displays stay active")
    -- A display still waiting in the apply queue is not refreshed by the event itself.
    local firstRegion, firstData, firstState = Mount("QueuedFirst", { unit = "target" })
    local secondRegion, secondData, secondState = Mount("QueuedSecond", { unit = "target" })
    restricted = true
    Display.Apply(firstRegion, firstData)
    Display.Apply(secondRegion, secondData)
    restricted = false
    holdTimers, clockStep = true, 8
    local firstUpdates, secondUpdates = Updates(firstState), Updates(secondState)
    local firstGeneration, secondGeneration = firstState.generation, secondState.generation
    test.Frames.Fire("PLAYER_TARGET_CHANGED")
    local waiting = firstState.generation == firstGeneration and firstState or secondState
    local waitingUpdates = waiting == firstState and firstUpdates or secondUpdates
    Same(firstState.generation + secondState.generation, firstGeneration + secondGeneration + 1, "one queued apply ran")
    Same(Updates(waiting), waitingUpdates, "queued display not refreshed by the event")
    while #Pass() > 0 do end
    holdTimers, held, clockStep = false, {}, 0
  end

  ------------------------------------------------------------------------------------------------
  -- D. Budgeted queues: applies, unloaded auras, instances.
  ------------------------------------------------------------------------------------------------
  local savedErrorHandler = geterrorhandler
  local swallowed = {}
  geterrorhandler = function() return function(message) swallowed[#swallowed + 1] = tostring(message) end end

  local function QueueRestricted(prefix, count)
    local entries = {}
    restricted = true
    for index = 1, count do
      local id = prefix .. index
      local data = Data(id)
      local region = NewRegion(id)
      Display.Apply(region, data)
      entries[index] = { id = id, data = data, region = region }
    end
    restricted = false
    return entries
  end
  local function Built(entries)
    local count = 0
    for _, entry in ipairs(entries) do
      if entry.region.blizzardAuraDisplay and entry.region.blizzardAuraDisplay.active then count = count + 1 end
    end
    return count
  end

  -- Budget: at least one apply per pass, then until 8 ms have elapsed.
  do
    local entries = QueueRestricted("Budget", 4)
    Same(Built(entries), 0, "nothing built while restricted")
    holdTimers, clockStep = true, 8
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 1, "one apply per pass when one apply costs the whole budget")
    Same(#held, 1, "next pass scheduled")
    Same(held[1].delay, 0, "next pass delay")
    Pass()
    Same(Built(entries), 2, "second pass")
    clockStep = 5
    Pass()
    Same(Built(entries), 4, "5 ms per call: two applies reach 8 ms")
    Same(#held, 0, "no pass left once the queue is empty")
    clockStep = 0
    -- Restarted by a later restriction change.
    entries = QueueRestricted("BudgetAll", 4)
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 4, "free budget: every apply in one pass")
    Same(#held, 0, "no pass pending")
    -- RestrictionChanged to restricted does nothing.
    entries = QueueRestricted("BudgetHold", 1)
    private.callbacks:Fire("RestrictionChanged", true)
    Same(Built(entries), 0, "restricted event does not drain")
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 1, "unrestricted event drains")
    holdTimers, held = false, {}
  end

  -- The queue stops while restricted and resumes with the next unrestricted event.
  do
    local entries = QueueRestricted("Stops", 3)
    holdTimers, clockStep = true, 8
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 1, "first pass")
    restricted = true
    Pass()
    Same(Built(entries), 1, "pass under restriction applies nothing")
    Same(#held, 0, "no pass scheduled under restriction")
    restricted = false
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 2, "drain restarted")
    while #Pass() > 0 do end
    Same(Built(entries), 3, "queue finished")
    holdTimers, held, clockStep = false, {}, 0
  end

  -- Login not finished: polled every 0.2 s, nothing applied.
  do
    local entries = QueueRestricted("Login", 2)
    loginFinished, holdTimers = false, true
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 0, "nothing applied before the end of the login")
    Same(#held, 1, "poll scheduled")
    Near(held[1].delay, 0.2, "poll delay")
    Pass()
    Same(#held, 1, "still polling")
    loginFinished = true
    Pass()
    Same(Built(entries), 2, "applied once the login is over")
    holdTimers, held = false, {}
  end

  -- Stale entries are skipped, failures are isolated.
  do
    local entries = QueueRestricted("Stale", 4)
    store[entries[1].id] = Data(entries[1].id)
    private.regions[entries[2].id] = { region = NewRegion() }
    local realApply = Display.Apply
    local failing = entries[3].region
    Display.Apply = function(region, data)
      if region == failing then error("boom") end
      return realApply(region, data)
    end
    private.callbacks:Fire("RestrictionChanged", false)
    Display.Apply = realApply
    Same(Built(entries), 1, "stale data and stale region skipped, failing apply isolated")
    Truthy(entries[4].region.blizzardAuraDisplay.active, "apply after the failing one still ran")
    Same(#swallowed, 1, "failure given to the error handler")
    swallowed = {}
    -- The queue is empty: a new event applies nothing and costs nothing.
    private.callbacks:Fire("RestrictionChanged", false)
    Same(Built(entries), 1, "empty queue")
  end

  -- Unloaded auras: region created outside restrictions, then released.
  do
    local created = {}
    local realEnsure = private.EnsureRegion
    local function Unloaded(id, loadedValue, regionType)
      local data = Data(id, { regionType = regionType })
      private.loaded[id] = loadedValue
      private.regions[id] = nil
      return data
    end
    private.EnsureRegion = function(id)
      local region = NewRegion()
      local data = store[id]
      Display.Apply(region, data)
      created[#created + 1] = { id = id, region = region }
      return region
    end
    local function Add(id) private.callbacks:Fire("Add", id, id, store[id]) end
    local unloaded = Unloaded("PrepUnloaded", false)
    Add("PrepUnloaded")
    Same(#created, 1, "region created for an aura that can load later")
    Same(created[1].region.blizzardAuraDisplay.active, false, "region released after its creation")
    for _, case in ipairs({ { "PrepNever", nil, "icon" }, { "PrepLoaded", true, "icon" }, { "PrepOff", false, "model" } }) do
      Unloaded(case[1], case[2], case[3])
      Add(case[1])
    end
    Same(#created, 1, "loaded, never loaded and disabled auras are left alone")
    Unloaded("PrepHasRegion", false)
    private.regions.PrepHasRegion = { region = NewRegion() }
    Add("PrepHasRegion")
    Same(#created, 1, "aura with a region left alone")
    Unloaded("PrepEditor", false)
    optionsOpen = true
    Add("PrepEditor")
    optionsOpen = false
    Same(#created, 1, "nothing prepared with the options open")
    -- Restricted: nothing, then prepared at the end of the restriction.
    Unloaded("PrepRestricted", false)
    restricted = true
    Add("PrepRestricted")
    Same(#created, 1, "nothing prepared under restriction")
    restricted = false
    private.callbacks:Fire("RestrictionChanged", false)
    Same(#created, 2, "prepared when the restriction ends")
    -- Aura no longer unloaded once the region exists: not released.
    Unloaded("PrepFlipped", false)
    private.EnsureRegion = function(id)
      local region = NewRegion()
      Display.Apply(region, store[id])
      private.loaded[id] = true
      created[#created + 1] = { id = id, region = region }
      return region
    end
    Add("PrepFlipped")
    Same(#created, 3, "region created")
    Same(created[3].region.blizzardAuraDisplay.active, true, "loaded meanwhile: not released")
    -- Login poll and budget.
    private.EnsureRegion = function(id)
      local region = NewRegion()
      Display.Apply(region, store[id])
      created[#created + 1] = { id = id, region = region }
      return region
    end
    for index = 1, 3 do Unloaded("PrepBudget" .. index, false) end
    holdTimers, loginFinished = true, false
    local before = #created
    for index = 1, 3 do Add("PrepBudget" .. index) end
    Same(#created, before, "nothing prepared before the end of the login")
    Near(held[1].delay, 0.2, "poll delay")
    loginFinished, clockStep = true, 8
    Pass()
    Same(#created, before + 1, "one aura per pass when the budget is spent")
    while #Pass() > 0 do end
    Same(#created, before + 3, "every aura prepared")
    holdTimers, held, clockStep = false, {}, 0
    private.EnsureRegion = realEnsure
  end

  -- Instance queue under restriction and after a release.
  do
    optionsOpen, holdTimers = true, true
    local region, data, state = Mount("QueueRestricted", { unit = "group" })
    Truthy(state.instanceQueue, "queue created")
    restricted = true
    Pass()
    Same(state.instanceQueue, nil, "queue dropped under restriction")
    Same(#held, 0, "no pass scheduled")
    local generation = state.generation
    restricted = false
    private.callbacks:Fire("RestrictionChanged", false)
    Truthy(state.generation > generation, "apply queued by the dropped queue ran")
    while #Pass() > 0 do end
    -- Release drops the queue; later passes run nothing.
    local _, _, other = Mount("QueueReleased", { unit = "group" })
    Display.Release(private.regions.QueueReleased.region)
    Same(other.instanceQueue, nil, "release drops the queue")
    while #Pass() > 0 do end
    local ran = 0
    for _, instance in ipairs(other.instances) do
      if #Calls(instance.container, "SetAuraGroupSortMethod") > 0 then ran = ran + 1 end
    end
    Same(ran, 2, "only the first instances ran")
    -- FlushInstanceQueue under restriction queues the apply instead.
    local flushRegion, _, flushState = Mount("QueueFlushRestricted", { unit = "group" })
    restricted = true
    Display.FlushInstanceQueue(flushRegion)
    Same(flushState.instanceQueue, nil, "queue cleared")
    restricted = false
    local flushGeneration = flushState.generation
    private.callbacks:Fire("RestrictionChanged", false)
    Truthy(flushState.generation > flushGeneration, "flush under restriction queued an apply")
    while #Pass() > 0 do end
    optionsOpen, holdTimers, held = false, false, {}
    Drain(1)
  end

  geterrorhandler = savedErrorHandler

  ------------------------------------------------------------------------------------------------
  -- C. Activate, Modify (also deferred in the editor), SyncProgressSource, ApplyFlowSort.
  ------------------------------------------------------------------------------------------------
  do
    local region, data, state = Mount("ActivateFast")
    Display.Release(region)
    Same(state.active, false, "released before the activation")
    Display.Activate(region, data)
    Same(state.active, true, "activation reactivates")
    Same(state.generation, 1, "fast path does not apply again")
    -- Anything that differs goes through Apply.
    local other = Data("ActivateFast")
    Display.Activate(region, other)
    Same(state.generation, 2, "another data table applies")
    Same(state.data, other, "state follows the new data")
    Display.Activate(region, other)
    Same(state.generation, 2, "same data table: fast path")
    -- A queued apply forces the slow path and is consumed by it.
    restricted = true
    Display.Apply(region, other)
    restricted = false
    Same(state.generation, 2, "apply under restriction builds nothing")
    Display.Activate(region, other)
    Same(state.generation, 3, "queued apply forces Apply")
    -- Another slot count, another grid membership.
    other.triggers[1].trigger.unit = "party"
    Display.Activate(region, other)
    Same(state.generation, 4, "slot count change forces Apply")
    Same(#state.instances, 5, "instances follow the slot count")
    state.gridMember = true
    Display.Activate(region, other)
    Same(state.generation, 5, "grid membership change forces Apply")
    Same(state.gridMember, false, "grid membership recomputed")
    -- Invalid data forces Apply, which posts the issue.
    other.triggers[1].trigger.unit = "bogus"
    Display.Activate(region, other)
    Same(state.generation, 5, "invalid aura builds nothing")
    Same(state.active, false, "invalid aura released")
    assert(Warning("ActivateFast", "blizzard_aura_display"), "issue not posted")
    -- Disabled: released with the grid, no wrapper installed.
    local fresh = NewRegion()
    local freshUpdate = function() end
    fresh.Update = freshUpdate
    Display.Activate(fresh, Data("ActivateOff", { regionType = "model" }))
    Same(fresh.Update, freshUpdate, "no wrapper on a disabled aura")
    Same(fresh.blizzardOriginalUpdate, nil, "no record on a disabled aura")
  end

  -- Wrappers of Update and PreShow.
  do
    local data = Data("Wrappers")
    local region = NewRegion("Wrappers")
    region.icon = savedCreateFrame("Frame")
    local updateCalls, preShowCalls = {}, 0
    region.Update = function(self, ...) updateCalls[#updateCalls + 1] = { self, ... } end
    region.PreShow = function() preShowCalls = preShowCalls + 1 end
    Display.Activate(region, data)
    local wrapper, preWrapper = region.Update, region.PreShow
    region.icon:SetAlpha(1)
    region:Update("a", "b")
    Same(#updateCalls, 1, "original Update called")
    Same(updateCalls[1][1], region, "original Update gets the region")
    Same(updateCalls[1][2], "a", "original Update first argument")
    Same(updateCalls[1][3], "b", "original Update second argument")
    Same(region.icon:GetAlpha(), 0, "parts hidden again after Update")
    region.icon:SetAlpha(1)
    region:PreShow()
    Same(region.icon:GetAlpha(), 0, "parts hidden by PreShow")
    Same(preShowCalls, 0, "PreShow wrapper does not call the former function")
    Display.Activate(region, data)
    Same(region.Update, wrapper, "wrapper installed once")
    Same(region.PreShow, preWrapper, "preshow wrapper installed once")
    -- A newer function (region Modify) is wrapped again.
    local newerCalls = 0
    region.Update = function() newerCalls = newerCalls + 1 end
    Display.Activate(region, data)
    assert(region.Update ~= wrapper, "stale wrapper kept")
    region:Update()
    Same(newerCalls, 1, "newer Update called through the new wrapper")
    Display.Restore(region)
    Same(region.blizzardOriginalUpdate, nil, "record dropped")
  end

  -- Modify outside the editor.
  do
    local region, _, state = Mount("ModifyPlain")
    local data = Data("ModifyPlain")
    region.secretAuraConditionValues = { x = 1 }
    region.secretAuraProgressSourceIndex = 99
    Display.Modify(region, data)
    Same(state.generation, 2, "Modify applies at once")
    Same(state.data, data, "state follows the new data")
    Same(region.secretAuraProgressSourceIndex, 1, "progress source index")
    Same(region.secretAuraConditionValues, nil, "condition values dropped")
    assert(region.blizzardOriginalUpdate and region.blizzardOriginalPreShow, "Modify installs the wrappers")
    -- Disabled: released with the grid, warnings cleared.
    state.gridMember = true
    warnings.ModifyPlain.blizzard_aura_display = { severity = "warning", text = "old" }
    Display.Modify(region, Data("ModifyPlain", { regionType = "model" }))
    Same(state.active, false, "disabled aura released")
    Same(state.gridMember, nil, "disabled aura leaves the grid")
    Same(Warning("ModifyPlain", "blizzard_aura_display"), nil, "display warning cleared")
  end

  -- Modify in the editor: deferred, two applies per timer pass, stale entries skipped.
  do
    holdTimers = true
    optionsOpen = true
    local regions = {}
    for index = 1, 5 do
      local _, data, state = Mount("Editor" .. index)
      regions[index] = { region = private.regions["Editor" .. index].region, data = data, state = state }
    end
    while #Pass() > 0 do end
    for _, entry in ipairs(regions) do entry.generation = entry.state.generation end
    local function Applied()
      local count = 0
      for _, entry in ipairs(regions) do
        if entry.state.generation > entry.generation then count = count + 1 end
      end
      return count
    end
    for _, entry in ipairs(regions) do Display.Modify(entry.region, entry.data) end
    Same(Applied(), 0, "nothing applied at once in the editor")
    Same(#held, 1, "one timer for the whole queue")
    Same(held[1].delay, 0, "timer delay")
    Pass()
    Same(Applied(), 2, "two applies in the first pass")
    Same(#held, 1, "pass reschedules while aura wait")
    Pass()
    Same(Applied(), 4, "two more in the second pass")
    Pass()
    Same(Applied(), 5, "last one in the third pass")
    Same(#held, 0, "no timer left when the queue is empty")
    -- The drain starts again for a later Modify.
    Display.Modify(regions[1].region, regions[1].data)
    Same(#held, 1, "drain restarted")
    Pass()
    -- Release cancels the pending apply.
    for _, entry in ipairs(regions) do entry.generation = entry.state.generation end
    Display.Modify(regions[1].region, regions[1].data)
    Display.Release(regions[1].region)
    while #Pass() > 0 do end
    Same(Applied(), 0, "released region not applied by the editor queue")
    -- A later Modify outside the editor cancels the pending apply too.
    Display.Activate(regions[2].region, regions[2].data)
    Display.Modify(regions[2].region, regions[2].data)
    optionsOpen = false
    Display.Modify(regions[2].region, regions[2].data)
    local expected = regions[2].state.generation
    while #Pass() > 0 do end
    Same(regions[2].state.generation, expected, "pending apply cancelled by a direct Modify")
    -- Stale entries: replaced data, other region.
    optionsOpen = true
    local stale = regions[3]
    Display.Activate(stale.region, stale.data)
    stale.generation = stale.state.generation
    Display.Modify(stale.region, stale.data)
    store.Editor3 = Data("Editor3")
    while #Pass() > 0 do end
    Same(stale.state.generation, stale.generation, "replaced data not applied")
    store.Editor3 = stale.data
    Display.Modify(stale.region, stale.data)
    private.regions.Editor3 = { region = NewRegion() }
    while #Pass() > 0 do end
    Same(stale.state.generation, stale.generation, "other region not applied")
    private.regions.Editor3 = { region = stale.region }
    optionsOpen = false
    holdTimers, held = false, {}
  end

  -- Not deferred: inactive state, other data, restriction.
  do
    optionsOpen = true
    local region, data, state = Mount("EditorDirect")
    Display.Release(region)
    Display.Modify(region, data)
    Same(state.generation, 2, "inactive state applies at once")
    Display.Modify(region, Data("EditorDirect"))
    Same(state.generation, 3, "other data applies at once")
    restricted = true
    Display.Modify(region, state.data)
    Same(state.generation, 3, "restriction: apply queued")
    restricted = false
    optionsOpen = false
    Drain(0.5)
  end

  -- SyncProgressSource.
  do
    local region, data, state = Mount("Sync")
    Display.SyncProgressSource(region, nil)
    Display.SyncProgressSource(region, data)
    Same(region.secretAuraProgressSourceIndex, 1, "index recorded")
    Same(state.generation, 1, "same data: no apply")
    Display.SyncProgressSource(region, data)
    Same(state.generation, 1, "same index: nothing")
    Display.Release(region)
    region.secretAuraProgressSourceIndex = nil
    Display.SyncProgressSource(region, data)
    Same(state.active, true, "inactive state activated")
    Same(state.generation, 1, "activation without apply")
    region.secretAuraProgressSourceIndex = nil
    local other = Data("Sync")
    Display.SyncProgressSource(region, other)
    Same(state.generation, 2, "other data goes through Modify")
    Same(region.secretAuraProgressSourceIndex, 1, "index set by Modify")
  end

  -- ApplyFlowSort.
  do
    local sortValue = 10
    AuraContainerSortMethod = {}
    for name in pairs(Display.sortMethods) do
      AuraContainerSortMethod[name] = sortValue
      sortValue = sortValue + 1
    end
    local group = { id = "SortGroup", uid = "SortGroup", regionType = "group", blizzardFlow = true,
      blizzardFlowSort = "Name", blizzardFlowReverse = true, controlledChildren = {} }
    store.SortGroup = group
    local function Child(id, trigger)
      local region, data, state = Mount(id, { parent = "SortGroup", unit = "party", trigger = trigger })
      group.controlledChildren[#group.controlledChildren + 1] = id
      return region, data, state
    end
    local _, firstData, first = Child("SortA")
    local _, _, second = Child("SortB")
    for _, state in ipairs({ first, second }) do
      for _, instance in ipairs(state.instances) do instance.container.log = {} end
    end
    Same(Display.ApplyFlowSort(group), true, "sortable group")
    for _, state in ipairs({ first, second }) do
      for index, instance in ipairs(state.instances) do
        local calls = Calls(instance.container, "SetAuraGroupSortMethod")
        Same(#calls, 1, "one sort call per instance " .. index)
        Same(calls[1][1], "Auras", "sort group name")
        Same(calls[1][2], AuraContainerSortMethod.Name, "sort method from the group")
        Same(calls[1][3], AuraContainerSortDirection.Reverse, "sort direction from the group")
      end
    end
    -- A child without state is skipped; a state on other data is skipped too.
    group.controlledChildren[#group.controlledChildren + 1] = "SortNoState"
    store.SortNoState = Data("SortNoState", { parent = "SortGroup" })
    Same(Display.ApplyFlowSort(group), true, "child without state skipped")
    store.SortA = Data("SortA", { parent = "SortGroup", unit = "party" })
    Same(Display.ApplyFlowSort(group), true, "state on other data skipped")
    store.SortA = firstData
    restricted = true
    Same(Display.ApplyFlowSort(group), false, "restricted")
    restricted = false
    first.active = false
    Same(Display.ApplyFlowSort(group), false, "inactive child")
    first.active = true
    first.gridMember = true
    Same(Display.ApplyFlowSort(group), false, "grid member")
    first.gridMember = false
    firstData.triggers[1].trigger.secretShowOn = "showAlways"
    Same(Display.ApplyFlowSort(group), false, "single child")
    firstData.triggers[1].trigger.secretShowOn = "showOnActive"
    first.instances[1].unitGlow = {}
    Same(Display.ApplyFlowSort(group), false, "child with a unit glow")
    first.instances[1].unitGlow = nil
    Same(Display.ApplyFlowSort({ controlledChildren = {} }), true, "empty group")
    Same(Display.ApplyFlowSort({}), true, "group without list")
  end

  -- Preview: the first two instances run at once, the others by four per timer pass.
  do
    local function Runs(state)
      local count = 0
      for _, instance in ipairs(state.instances) do
        if #Calls(instance.container, "SetAuraGroupSortMethod") > 0 then count = count + 1 end
      end
      return count
    end
    optionsOpen, holdTimers = true, true
    local region, _, state = Mount("PreviewBatches", { unit = "group" })
    Same(#state.instances, 40, "group slot count")
    Same(Runs(state), 2, "instances run at once in the preview")
    Same(state.instanceQueue.nextIndex, 3, "queue starts after the first batch")
    Same(#Pass(), 1, "one timer pass pending")
    Same(Runs(state), 6, "four more instances per pass")
    Same(state.instanceQueue.nextIndex, 7, "queue index after one pass")
    -- Applying again replaces the queue by a fresh one.
    Display.Apply(region, state.data)
    Same(state.instanceQueue.nextIndex, 3, "queue restarted by a new apply")
    while #Pass() > 0 do end
    Same(state.instanceQueue, nil, "queue drained")
    Same(Runs(state), 40, "every instance run once drained")
    -- Few instances: no queue.
    local _, _, partyState = Mount("PreviewParty", { unit = "party" })
    Same(partyState.instanceQueue ~= nil, true, "five instances are queued in the preview")
    local _, _, singleState = Mount("PreviewSingle", { unit = "player" })
    Same(singleState.instanceQueue, nil, "one instance is not queued")
    optionsOpen = false
    -- Flush on demand: runs the remaining instances at once.
    optionsOpen = true
    local _, _, partyTwo = Mount("PreviewParty2", { unit = "party" })
    Display.FlushInstanceQueue(NewRegion())
    local partyRegion = private.regions.PreviewParty2.region
    Display.FlushInstanceQueue(partyRegion)
    Same(partyTwo.instanceQueue, nil, "queue cleared by FlushInstanceQueue")
    Same(Runs(partyTwo), 5, "every instance run by FlushInstanceQueue")
    optionsOpen, holdTimers, held = false, false, {}
  end


  ------------------------------------------------------------------------------------------------
  -- F. Ignored units and status alpha, unit frame refresh, detached levels, glow margin, candidate filters.
  ------------------------------------------------------------------------------------------------
  local savedConnected, savedDead = UnitIsConnected, UnitIsDeadOrGhost
  local connected, dead = {}, {}
  UnitIsConnected = function(unit)
    if connected[unit] == nil then return true end
    return connected[unit]
  end
  UnitIsDeadOrGhost = function(unit) return dead[unit] or false end

  do
    local ignoreDead, ignoreBoth = { unit = "party", ignoreDead = true }, { unit = "party", ignoreDead = true, ignoreDisconnected = true }
    local function Ignored(config, unit) return { Display.UnitIgnored(config, unit) } end
    local secretTrue, otherSecret = Secret.Wrap(true), Secret.Wrap(true)
    Same(Display.UnitIgnored(ignoreDead, nil), false, "no unit")
    dead.party1 = true
    Same(Display.UnitIgnored({ unit = "player", ignoreDead = true }, "party1"), false, "only group modes ignore units")
    Same(Display.UnitIgnored({ unit = "target", ignoreDead = true, ignoreDisconnected = true }, "party1"), false, "target mode")
    Same(Display.UnitIgnored(ignoreDead, "party1"), true, "dead unit ignored")
    Same(Display.UnitIgnored({ unit = "raid", ignoreDead = true }, "raid1"), false, "alive unit in raid mode")
    Same(Display.UnitIgnored({ unit = "party" }, "party1"), false, "dead unit kept without the option")
    dead.party1 = nil
    local alive = Ignored(ignoreBoth, "party1")
    Same(alive[1], false, "alive and connected")
    Same(alive[2], nil, "no secret dead flag")
    Same(alive[3], nil, "no secret connected flag")
    connected.party1 = false
    Same(Display.UnitIgnored(ignoreBoth, "party1"), true, "disconnected unit ignored")
    Same(Display.UnitIgnored(ignoreDead, "party1"), false, "disconnection ignored only with its option")
    connected.party1 = nil
    -- Secret flags are given to the alpha, never tested.
    dead.party1 = secretTrue
    local result = Ignored(ignoreDead, "party1")
    Same(result[1], false, "secret dead flag: unit kept")
    Truthy(rawequal(result[2], secretTrue), "secret dead flag returned")
    Same(result[3], nil, "no connected flag")
    connected.party1 = otherSecret
    result = Ignored(ignoreBoth, "party1")
    Same(result[1], false, "both secret: unit kept")
    Same(result[2], nil, "secret connection keeps priority over the dead flag")
    Truthy(rawequal(result[3], otherSecret), "secret connected flag returned")
    dead.party1 = true
    Same(Display.UnitIgnored(ignoreBoth, "party1"), true, "readable dead flag wins over a secret connection")
    dead.party1, connected.party1 = secretTrue, false
    Same(Display.UnitIgnored(ignoreBoth, "party1"), true, "readable disconnection wins over a secret dead flag")
    dead.party1, connected.party1 = nil, nil
  end

  -- Status events refresh the instance bound to the unit only when its state flips.
  do
    local region, data, state = Mount("StatusAura", { unit = "party", trigger = { ignoreDead = true } })
    local trigger = Display.GetTrigger(data)
    local unit = Display.UnitTokens(trigger)[1]
    local bound
    for _, instance in ipairs(state.instances) do
      if instance.boundUnit == unit then bound = instance end
    end
    assert(bound, "no instance bound to " .. tostring(unit))
    local function Count(instance) return #Calls(instance.container, "SetEnabled") end
    Same(bound.statusHidden, false, "unit shown at first")
    local before = Count(bound)
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(Count(bound), before, "no flip, no refresh")
    dead[unit] = true
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(bound.statusHidden, true, "dead unit hidden")
    Same(bound.container.enabledValue, false, "container disabled")
    Same(bound.container:IsShown(), false, "container hidden")
    local hiddenCount = Count(bound)
    test.Frames.Fire("UNIT_FLAGS", unit)
    Same(Count(bound), hiddenCount, "same state: no refresh")
    local otherCount = Count(bound)
    test.Frames.Fire("UNIT_HEALTH", "target")
    Same(Count(bound), otherCount, "another unit: no refresh")
    dead[unit] = nil
    test.Frames.Fire("UNIT_CONNECTION", unit)
    Same(bound.statusHidden, false, "unit back")
    Same(bound.container.enabledValue, true, "container enabled again")
    -- Secret flags drive the container alpha.
    local secretDead = Secret.Wrap(true)
    dead[unit] = secretDead
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(bound.statusSecret, true, "secret state recorded")
    local alphaCall = bound.container.alphaBoolean
    Truthy(alphaCall and rawequal(alphaCall.value, secretDead), "alpha follows the secret flag")
    Same(alphaCall.whenTrue, 0, "dead unit: invisible")
    Same(alphaCall.whenFalse, 1, "alive unit: container alpha")
    dead[unit] = nil
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(bound.statusSecret, false, "secret state cleared")
    Same(bound.container:GetAlpha(), 1, "plain alpha restored")
    -- Disconnection flag: inverted, and priority over the dead flag.
    local secretConnected = Secret.Wrap(true)
    local both = Mount("StatusBoth", { unit = "party", trigger = { ignoreDead = true, ignoreDisconnected = true } })
    local bothState = private.regions.StatusBoth.region.blizzardAuraDisplay
    local bothInstance
    for _, instance in ipairs(bothState.instances) do
      if instance.boundUnit == unit then bothInstance = instance end
    end
    connected[unit], dead[unit] = secretConnected, Secret.Wrap(true)
    test.Frames.Fire("UNIT_CONNECTION", unit)
    alphaCall = bothInstance.container.alphaBoolean
    Truthy(alphaCall and rawequal(alphaCall.value, secretConnected), "secret connection drives the alpha")
    Same(alphaCall.whenTrue, 1, "connected unit: container alpha")
    Same(alphaCall.whenFalse, 0, "disconnected unit: invisible")
    connected[unit], dead[unit] = nil, nil
    test.Frames.Fire("UNIT_CONNECTION", unit)
    Same(bothInstance.statusSecret, false, "secret state cleared on both")
    -- A display without the options ignores the events.
    local _, _, plain = Mount("StatusPlain", { unit = "party" })
    local plainBefore = Updates(plain)
    dead[unit] = true
    test.Frames.Fire("UNIT_HEALTH", unit)
    dead[unit] = nil
    Same(Updates(plain), plainBefore, "display without the options not refreshed")
    -- Error in one display does not stop the batch (the handler is protected).
    Display.Release(region)
    test.Frames.Fire("UNIT_HEALTH", unit)
  end

  -- Grid members: the shared grid is refreshed when the ignored state of the unit flips.
  do
    for _, id in ipairs({ "StatusAura", "StatusBoth", "StatusPlain" }) do
      if private.regions[id] then Display.Release(private.regions[id].region) end
    end
    local region, data, state = Mount("StatusGrid", { unit = "party", trigger = { ignoreDead = true, ignoreDisconnected = true } })
    state.gridMember = true
    local unit = Display.UnitTokens(Display.GetTrigger(data))[1]
    local realRefresh = Display.RefreshFlowUnits
    local refreshes = 0
    Display.RefreshFlowUnits = function() refreshes = refreshes + 1 end
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(refreshes, 0, "unit never ignored: no refresh")
    dead[unit] = true
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(refreshes, 1, "unit turned ignored: refresh")
    Same(state.gridIgnored[unit], true, "ignored state remembered")
    test.Frames.Fire("UNIT_FLAGS", unit)
    Same(refreshes, 1, "same state: no refresh")
    dead[unit] = nil
    test.Frames.Fire("UNIT_HEALTH", unit)
    Same(refreshes, 2, "unit back: refresh")
    Same(state.gridIgnored[unit], false, "state remembered")
    connected[unit] = false
    test.Frames.Fire("UNIT_CONNECTION", unit)
    Same(refreshes, 3, "disconnected: refresh")
    connected[unit] = nil
    test.Frames.Fire("UNIT_HEALTH", "target")
    Same(refreshes, 3, "another token: no refresh")
    Display.RefreshFlowUnits = realRefresh
    state.gridMember = false
  end

  UnitIsConnected, UnitIsDeadOrGhost = savedConnected, savedDead

  -- UnitFramesChanged: one refresh per pass, only for displays that use unit frames.
  do
    local plainRegion, _, plainState = Mount("FramesPlain", { unit = "target" })
    holdTimers = true
    Display.UnitFramesChanged()
    Same(#held, 0, "no unit frame display, no refresh")
    local frame = savedCreateFrame("Frame")
    frame:SetSize(50, 40)
    unitFrames.target = frame
    local _, _, state = Mount("FramesAnchored", { unit = "target", anchorFrameType = "UNITFRAME", display = { unitGlow = true } })
    local plainUpdates, updates = Updates(plainState), Updates(state)
    Display.UnitFramesChanged()
    Display.UnitFramesChanged()
    Same(#held, 1, "one timer for several calls")
    Same(held[1].delay, 0, "timer delay")
    Same(Updates(state), updates, "nothing before the timer")
    Pass()
    assert(Updates(state) > updates, "unit frame display not refreshed")
    Same(Updates(plainState), plainUpdates, "other displays not refreshed")
    Display.UnitFramesChanged()
    Same(#held, 1, "armed again after the pass")
    Pass()
    -- A size change of the anchor frame triggers it.
    updates = Updates(state)
    frame:SetSize(60, 40)
    Same(#held, 1, "size change of the target frame queues a refresh")
    Pass()
    assert(Updates(state) > updates, "refresh after the size change")
    holdTimers, held = false, {}
    unitFrames.target = nil
  end

  -- Detached sub-region levels: above the display and its containers, step by position.
  do
    local region, data, state = Mount("DetachedLevels")
    data.subRegions = { {}, {} }
    region:SetFrameLevel(50)
    local first, second, plain = savedCreateFrame("Frame"), savedCreateFrame("Frame"), savedCreateFrame("Frame")
    first.secretAuraDetached, second.secretAuraDetached = true, true
    region.subRegions = { first, plain, second }
    local base = 50
    for _, instance in ipairs(state.instances) do base = math.max(base, instance.container:GetFrameLevel()) end
    local plainLevel = plain:GetFrameLevel()
    Display.UpdateDetachedFrameLevels(region)
    Same(first:GetFrameLevel(), base + 2 * 3 + 8 + 1, "first detached sub-region")
    Same(second:GetFrameLevel(), base + 2 * 3 + 8 + 3, "third position")
    Same(plain:GetFrameLevel(), plainLevel, "attached sub-region untouched")
    -- A container above the display raises the detached levels.
    state.instances[1].container:SetFrameLevel(200)
    Display.UpdateDetachedFrameLevels(region)
    Same(first:GetFrameLevel(), 200 + 2 * 3 + 8 + 1, "container level taken")
    -- A secret container level is ignored.
    state.instances[1].container.GetFrameLevel = function() return Secret.Wrap(500) end
    Display.UpdateDetachedFrameLevels(region)
    assert(first:GetFrameLevel() ~= 500 + 2 * 3 + 8 + 1, "secret level used")
    -- Inactive display: nothing.
    Display.Release(region)
    first:SetFrameLevel(7)
    Display.UpdateDetachedFrameLevels(region)
    Same(first:GetFrameLevel(), 7, "inactive display untouched")
    Display.UpdateDetachedFrameLevels(NewRegion())
  end

  -- Unit glow: margin of 20 % around the frame, last margin kept when the size is secret.
  do
    local frame = savedCreateFrame("Frame")
    frame:SetSize(50, 40)
    unitFrames.target = frame
    local _, _, state = Mount("GlowMargin", { unit = "target", anchorFrameType = "UNITFRAME", display = { unitGlow = true } })
    local holder = state.instances[1].unitGlow.container
    local function Points()
      local list = {}
      for index = 1, holder:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = holder:GetPoint(index)
        list[point] = { relativeTo = relativeTo, relativePoint = relativePoint, x = x, y = y }
      end
      return list
    end
    local points = Points()
    Same(holder:GetNumPoints(), 2, "two anchors")
    Same(points.TOPLEFT.relativeTo, frame, "top left on the frame")
    Same(points.TOPLEFT.relativePoint, "TOPLEFT", "top left relative point")
    Near(points.TOPLEFT.x, -10, "left margin is 20 % of the width")
    Near(points.TOPLEFT.y, 8, "top margin is 20 % of the height")
    Same(points.BOTTOMRIGHT.relativePoint, "BOTTOMRIGHT", "bottom right relative point")
    Near(points.BOTTOMRIGHT.x, 10, "right margin")
    Near(points.BOTTOMRIGHT.y, -8, "bottom margin")
    -- Secret size: the last margin stays.
    frame.GetSize = function() return Secret.Wrap(500), Secret.Wrap(400) end
    Display.Apply(private.regions.GlowMargin.region, store.GlowMargin)
    points = Points()
    Near(points.TOPLEFT.x, -10, "secret size keeps the last margin")
    Near(points.BOTTOMRIGHT.y, -8, "secret size keeps the last margin below")
    frame.GetSize = nil
    frame:SetSize(100, 20)
    Display.Apply(private.regions.GlowMargin.region, store.GlowMargin)
    points = Points()
    Near(points.TOPLEFT.x, -20, "margin follows a new size")
    Near(points.TOPLEFT.y, 4, "margin follows a new height")
    -- Level of the glow holder above the frame.
    Same(holder:GetFrameLevel(), frame:GetFrameLevel() + 8, "glow level above the frame")
    Same(state.instances[1].container:GetFrameLevel(), frame:GetFrameLevel() + 8 + 3, "container above the glow")
    unitFrames.target = nil
  end

  -- Candidate filters handed to the containers.
  do
    local function Filters(trigger, unit)
      local data = Data("Filters" .. tostring(math.random(1e9)), { unit = unit, trigger = trigger })
      return Display.CandidateFilters(data)
    end
    local none = Filters({})
    Same(next(none), nil, "no filter, no candidate filter")
    Near(Filters({ secretUseTotal = true, secretTotalOperator = "<=", secretTotal = 10 }).maxDuration, 10.05, "<= adds 0.05 s")
    Near(Filters({ secretUseTotal = true, secretTotalOperator = "=", secretTotal = 10 }).maxDuration, 10.5, "= adds 0.5 s")
    Same(Filters({ secretUseTotal = true, secretTotalOperator = ">=", secretTotal = 10 }).maxDuration, nil, ">= sets no maximum")
    local spells = Filters({ auraspellids = { 100, "200" } })
    Same(spells.includeSpellIDs[100], true, "included spell")
    Same(spells.includeSpellIDs[200], true, "included spell given as text")
    Same(Filters({ secretUseSpellIDs = true }).includeSpellIDs ~= nil, true, "forced spell list, empty")
    Same(next(Filters({ secretUseSpellIDs = true }).includeSpellIDs), nil, "empty list matches nothing")
    local excluded = Filters({ excludedAuraSpellIDs = { 300 } })
    Same(excluded.excludeSpellIDs[300], true, "excluded spell")
    Same(excluded.includeSpellIDs, nil, "no include list")
    Same(Filters({ secretUseExcludedSpellIDs = true }).excludeSpellIDs, nil, "forced empty exclusion list")
    -- Boolean filters follow the aura kind and the unit.
    Same(Filters({ isFromPlayerOrPlayerPet = true }).isFromPlayerOrPlayerPet, true, "boolean filter copied")
    Same(Filters({ isFromPlayerOrPlayerPet = false }).isFromPlayerOrPlayerPet, false, "false is kept")
    Same(Filters({ isStealable = true }).isStealable, true, "stealable on buffs")
    Same(Filters({ isStealable = true, debuffType = "HARMFUL" }).isStealable, nil, "stealable ignored on debuffs")
    Same(Filters({ nameplateShowAll = true }).nameplateShowAll, nil, "plate filter ignored on other units")
    Same(Filters({ nameplateShowAll = true }, "nameplate").nameplateShowAll, true, "plate filter on nameplates")
    Same(Filters({ nameplateShowPersonal = true, debuffType = "HARMFUL" }, "nameplate").nameplateShowPersonal, true,
      "personal plate filter on nameplates")
    -- Dispel type lists are copied.
    local types = { Magic = true }
    local copy = Filters({ includeDispelTypes = types, excludeDispelTypes = { Curse = true } })
    Truthy(copy.includeDispelTypes ~= types, "include list copied")
    Same(copy.includeDispelTypes.Magic, true, "include list content")
    Same(copy.excludeDispelTypes.Curse, true, "exclude list content")
    Same(Filters({ includeDispelTypes = {} }).includeDispelTypes, nil, "empty list not given")
  end

  -- Restores.
  ------------------------------------------------------------------------------------------------
  CreateFrame = savedCreateFrame
  CustomAuraContainerAuraProcessingPolicy = savedPolicy
  C_AddOns.IsAddOnLoaded, C_AddOns.LoadAddOn = savedIsLoaded, savedLoadAddOn
  C_StringUtil = savedStringUtil
  if AuraUtil then AuraUtil.IsValidFilterString = savedValidFilter end
  AuraContainerSortMethod, AuraContainerSortDirection = sortMethodsBefore, sortDirectionBefore
  WeakAuras.IsRestricted, WeakAuras.IsOptionsOpen, WeakAuras.GetData = originals.IsRestricted, originals.IsOptionsOpen, originals.GetData
  WeakAuras.IsLoginFinished, WeakAuras.GetUnitFrame = originals.IsLoginFinished, originals.GetUnitFrame
  private.AuraWarnings.UpdateWarning = originals.UpdateWarning
  debugprofilestop = originals.debugprofilestop
  C_Timer.After = originalAfter
  if C_NamePlate then
    C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates = originals.GetNamePlateForUnit, originals.GetNamePlates
  end
end

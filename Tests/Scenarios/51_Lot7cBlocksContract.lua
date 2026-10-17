return function(test)
  local Secret, Frames = test.Secret, test.Frames
  local State = Frames.State
  local assertionCount = 0

  local function Check(condition, label)
    assertionCount = assertionCount + 1
    assert(condition, label)
  end
  local function Eq(actual, expected, label)
    Check(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Near(actual, expected, label)
    Check(type(actual) == "number" and math.abs(actual - expected) < 1e-9,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Within(actual, low, high, label)
    Check(type(actual) == "number" and actual >= low and actual <= high,
      ("%s: expected between %s and %s, got %s"):format(label, low, high, tostring(actual)))
  end

  local restores = {}
  local function Stub(owner, key, value)
    restores[#restores + 1] = {owner, key, owner[key]}
    owner[key] = value
  end
  local function Unstub()
    for index = #restores, 1, -1 do
      local saved = restores[index]
      saved[1][saved[2]] = saved[3]
      restores[index] = nil
    end
  end

  local function Aura(id, regionType, extra)
    local data = {
      id = id, uid = id, regionType = regionType, internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local displays = {
    Icon = Aura("Icon", "icon", { cooldown = true, inverse = true }),
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  local optionsDirectory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  local function Duration(remaining)
    local proxy = newproxy(true)
    getmetatable(proxy).__index = { GetRemainingDuration = function() return remaining end }
    return proxy
  end

  do
    local Display = private.CDMAuraProgress
    local calls, created, methods = {}, {}, {}
    local function Fake(kind)
      local object = { kind = kind, level = 1, visible = true, hooks = {}, slots = {}, accessible = true }
      return setmetatable(object, { __index = function(_, name)
        if not name:match("^%u") then return nil end
        if name == "CanBeAccessedInContext" and rawget(object, "noAccessCheck") then return nil end
        local specific = methods[name]
        return function(target, ...)
          calls[#calls + 1] = { target, name, ... }
          if specific then return specific(target, ...) end
        end
      end })
    end
    methods.SetEnabled = function(self, value) self.enabled = value end
    methods.GetFrameLevel = function(self) return self.level end
    methods.SetFrameLevel = function(self, value) self.level = value end
    methods.IsVisible = function(self) return self.visible end
    methods.SetAllPoints = function(self, target) self.allPoints = target end
    methods.SetAuraProcessingPolicy = function(self, policy) self.policy = policy end
    methods.EnableMouse = function(self, value) self.mouse = value end
    methods.SetUnit = function(self, unit) self.unit = unit end
    methods.SetDrawSwipe = function(self, value) self.swipe = value end
    methods.SetDrawEdge = function(self, value) self.edge = value end
    methods.SetReverse = function(self, value) self.reverse = value end
    methods.SetHideCountdownNumbers = function(self, value) self.hideNumbers = value end
    methods.HookScript = function(self, name, callback)
      self.hooks[name] = self.hooks[name] or {}
      table.insert(self.hooks[name], callback)
    end
    methods.AddAuraSlot = function(self, name, filter, options)
      self.slots[#self.slots + 1] = { name = name, filter = filter, options = options }
      options.initializeFrame(Fake("button"))
    end
    methods.CanBeAccessedInContext = function(self)
      if self.accessError then error("inaccessible") end
      return self.accessible
    end

    local mode, loadAttempts = "normal", 0
    local realCreateFrame, realAddOns = CreateFrame, C_AddOns
    local savedPolicy, savedDirections = CustomAuraContainerAuraProcessingPolicy, Enum.StatusBarTimerDirection
    CustomAuraContainerAuraProcessingPolicy = nil
    Enum.StatusBarTimerDirection = { ElapsedTime = 1, RemainingTime = 2 }
    C_AddOns = setmetatable({
      IsAddOnLoaded = function() return mode == "normal" and CustomAuraContainerAuraProcessingPolicy ~= nil end,
      LoadAddOn = function()
        loadAttempts = loadAttempts + 1
        if mode == "normal" then
          CustomAuraContainerAuraProcessingPolicy = { None = 77 }
        elseif mode == "vanish" then
          CustomAuraContainerAuraProcessingPolicy = nil
        end
        return true
      end,
    }, { __index = realAddOns })
    CreateFrame = function(frameType, name, parent, template)
      local frame = Fake(frameType)
      frame.parent, frame.template, frame.frameName = parent, template, name
      created[#created + 1] = frame
      return frame
    end

    local function Count(object, name)
      local total = 0
      for _, call in ipairs(calls) do
        if call[1] == object and call[2] == name then total = total + 1 end
      end
      return total
    end
    local function Find(object, name)
      for index, call in ipairs(calls) do
        if call[1] == object and call[2] == name then return index end
      end
    end
    local function FindLast(object, name)
      for index = #calls, 1, -1 do
        if calls[index][1] == object and calls[index][2] == name then return index end
      end
    end
    local function Containers()
      local total = 0
      for _, frame in ipairs(created) do
        if frame.kind == "AuraContainer" then total = total + 1 end
      end
      return total
    end
    local function Flush()
      test.Units.SetCombat(false)
      private.callbacks:Fire("RestrictionChanged", false)
    end
    local function Data(extra)
      local data = {
        regionType = "icon", uid = "u1", cooldown = true,
        triggers = { { trigger = { type = "cdm", event = "Blizzard CDM Buff" } } },
      }
      for key, value in pairs(extra or {}) do data[key] = value end
      return data
    end
    local function NewRegion(regionType, extra)
      local region = Fake(regionType or "region")
      region.regionType, region.level = regionType, 7
      region.icon = Fake("icon")
      region.bar = Fake("bar")
      region.bar.level = 4
      region.bar.ShowNativeBar = function(self, nativeBar)
        calls[#calls + 1] = { self, "ShowNativeBar", nativeBar }
        self.nativeBar = nativeBar
      end
      if regionType ~= "aurabar" then
        region.cooldown = Fake("cooldown")
        region.cooldown.level = 3
      end
      region.state = {
        cdmBuff = true, show = true, progressType = "static", cdmAuraRenderUnit = "target",
        cdmAuraFilter = "HARMFUL|PLAYER", cdmAuraRenderSpellIDs = { 8050 },
      }
      for key, value in pairs(extra or {}) do region[key] = value end
      return region
    end
    local function CountUpdates(region)
      region.Update = function(self) self.updateCalls = (self.updateCalls or 0) + 1 end
    end

    local data = Data()

    local preHidden, preShown = 0, 0
    local icon = NewRegion("icon")
    icon:HookScript("OnHide", function() preHidden = preHidden + 1 end)
    icon:HookScript("OnShow", function() preShown = preShown + 1 end)
    icon.cdmNativeProgress = true
    Eq(loadAttempts, 0, "nothing loaded before the first modify")
    Display.Modify(icon, data)
    Eq(loadAttempts, 1, "container addon loaded once")
    local container = icon.cdmAuraTimer
    Check(container ~= nil, "configured icon gets a container")
    Eq(icon.cdmProgressData, data, "modify stores the data table")
    Eq(icon.cdmNativeProgress, nil, "modify clears native progress")
    Eq(container.owner, icon, "container owner")
    Eq(container.wanted, nil, "container is not wanted yet")
    Eq(container.bindKey, nil, "container has no bind key")
    Eq(container.enabledKey, nil, "container has no enabled key")
    Eq(Containers(), 1, "one aura container frame")
    local frame = container.frame
    Eq(frame.kind, "AuraContainer", "frame type")
    Eq(frame.parent, icon, "frame parent is the owner")
    Eq(frame.template, "CustomAuraContainerTemplate", "frame template")
    Eq(frame.frameName, nil, "frame is anonymous")
    Eq(frame.enabled, false, "container frame starts disabled")
    Eq(frame.allPoints, icon, "container frame covers the owner")
    Eq(frame.level, 7, "container frame takes the owner level")
    Eq(frame.policy, 77, "container frame policy")
    Eq(#frame.slots, 1, "one aura slot")
    local slot = frame.slots[1]
    Eq(slot.name, "Timer", "slot name")
    Eq(slot.filter, "HELPFUL", "slot filter")
    Eq(type(slot.options.initializeFrame), "function", "slot initializer is a function")
    local includeSpellIDs = slot.options.candidateFilters.includeSpellIDs
    Eq(type(includeSpellIDs), "table", "slot admits a spell id table")
    Eq(next(includeSpellIDs), nil, "slot admits no spell by default")
    local button = container.button
    Check(button ~= nil, "container keeps its button")
    Eq(button.allPoints, frame, "button covers the container frame")
    Eq(button.level, 7, "button takes the container frame level")
    Eq(button.mouse, false, "button ignores the mouse")
    Eq(#icon.hooks.OnHide, 2, "hide hook is added, not replaced")
    Eq(#icon.hooks.OnShow, 2, "show hook is added, not replaced")
    frame:SetEnabled(true)
    for _, callback in ipairs(icon.hooks.OnHide) do callback(icon) end
    Eq(frame.enabled, false, "hiding the owner disables the container")
    Eq(preHidden, 1, "existing hide hook still runs")
    for _, callback in ipairs(icon.hooks.OnShow) do callback(icon) end
    Eq(frame.enabled, false, "showing the owner keeps an unwanted container disabled")
    Eq(preShown, 1, "existing show hook still runs")
    container.wanted = true
    for _, callback in ipairs(icon.hooks.OnShow) do callback(icon) end
    Eq(frame.enabled, true, "showing the owner enables a wanted container")
    container.wanted = nil
    frame:SetEnabled(false)

    local second = NewRegion("icon")
    Display.Modify(second, data)
    Check(second.cdmAuraTimer.frame.slots[1].options.candidateFilters.includeSpellIDs ~= includeSpellIDs,
      "each container gets its own spell id table")

    local function ModifyCase(label, regionType, regionData, extra)
      local region = NewRegion(regionType, extra)
      region.cdmNativeProgress = true
      local before = loadAttempts
      Display.Modify(region, regionData)
      Eq(region.cdmProgressData, regionData, label .. " stores the data")
      Eq(region.cdmNativeProgress, nil, label .. " clears native progress")
      return region, loadAttempts - before
    end
    local region, attempts = ModifyCase("nil data", "icon", nil)
    Eq(region.cdmAuraTimer, nil, "nil data builds nothing")
    Eq(attempts, 0, "nil data does not touch the addon")
    region, attempts = ModifyCase("unconfigured", "icon", Data({ triggers = {} }))
    Eq(region.cdmAuraTimer, nil, "unconfigured data builds nothing")
    Eq(attempts, 0, "unconfigured data does not touch the addon")
    region, attempts = ModifyCase("icon without cooldown", "icon", Data({ cooldown = false }))
    Eq(region.cdmAuraTimer, nil, "icon without cooldown builds nothing")
    Eq(attempts, 0, "icon without cooldown does not touch the addon")
    region, attempts = ModifyCase("texture", "texture", data)
    Eq(region.cdmAuraTimer, nil, "texture builds nothing")
    Eq(attempts, 0, "texture does not touch the addon")
    region, attempts = ModifyCase("region type wins", "aurabar", data)
    Check(region.cdmAuraTimer and region.cdmAuraTimer.statusBar and not region.cdmAuraTimer.cooldown,
      "region type picks the bar container")
    Eq(attempts, 0, "available addon is not loaded again")
    region, attempts = ModifyCase("data type", nil, data)
    Check(region.cdmAuraTimer and region.cdmAuraTimer.cooldown, "data type picks the icon container")
    Eq(attempts, 0, "data type build does not load again")

    mode, CustomAuraContainerAuraProcessingPolicy = "absent", nil
    region, attempts = ModifyCase("absent addon", "icon", data)
    Eq(region.cdmAuraTimer, nil, "no container without the addon")
    Eq(attempts, 1, "modify asks for the addon once")
    region, attempts = ModifyCase("absent addon unconfigured", "icon", Data({ triggers = {} }))
    Eq(attempts, 0, "unconfigured data does not ask for the missing addon")
    region, attempts = ModifyCase("absent addon texture", "texture", data)
    Eq(attempts, 0, "texture does not ask for the missing addon")
    region, attempts = ModifyCase("absent addon nil data", "icon", nil)
    Eq(attempts, 0, "nil data does not ask for the missing addon")
    mode, CustomAuraContainerAuraProcessingPolicy = "normal", { None = 77 }

    do
      local before = #created
      local attemptsBefore = loadAttempts
      container.wanted = true
      frame:SetEnabled(true)
      icon.cdmNativeProgress = true
      local newData = Data({ uid = "u2" })
      Display.Modify(icon, newData)
      Eq(icon.cdmAuraTimer, container, "existing container is kept")
      Eq(container.wanted, false, "existing container is released")
      Eq(frame.enabled, false, "existing container frame is disabled")
      Eq(icon.cdmProgressData, newData, "modify stores the new data")
      Eq(icon.cdmNativeProgress, nil, "modify clears native progress again")
      Eq(#created, before, "no new frame for an existing container")
      Eq(loadAttempts, attemptsBefore, "existing container does not touch the addon")
      container.wanted = false
      frame:SetEnabled(true)
      Display.Modify(icon, newData)
      Eq(frame.enabled, true, "releasing an unwanted container does nothing")
      frame:SetEnabled(false)
    end

    local barRegion = NewRegion("aurabar")
    Display.Modify(barRegion, data)
    local barContainer = barRegion.cdmAuraTimer
    Check(barContainer and barContainer.statusBar, "bar container has a status bar")
    Eq(barRegion.bar.nativeBar, barContainer.statusBar, "bar shows the native bar when built")
    Eq(Count(barContainer.button, "SetDurationBar"), 1, "bar direction applied once")
    barRegion.bar.nativeBar = nil
    test.Units.SetCombat(true)
    calls = {}
    Display.Modify(barRegion, data)
    Eq(barRegion.cdmAuraTimer, barContainer, "restricted modify keeps the container")
    Eq(Count(barRegion.bar, "ShowNativeBar"), 0, "restricted modify leaves the bar alone")
    Eq(barRegion.bar.nativeBar, nil, "restricted modify shows no native bar")
    Flush()
    calls = {}
    Display.Modify(barRegion, data)
    Eq(Count(barRegion.bar, "ShowNativeBar"), 1, "modify shows the native bar once")
    Eq(barRegion.bar.nativeBar, barContainer.statusBar, "modify shows the native bar")

    do
      local fresh = NewRegion("icon")
      test.Units.SetCombat(true)
      local before, attemptsBefore = #created, loadAttempts
      Display.Modify(fresh, data)
      Eq(fresh.cdmAuraTimer, nil, "no container is built in combat")
      Eq(#created, before, "no frame is created in combat")
      Eq(loadAttempts, attemptsBefore, "combat modify does not touch the addon")
      Flush()
    end

    local function PendingCase(label, regionType, regionData, withContainer, visible, expectTimer, expectUpdates)
      local pending = NewRegion(regionType)
      CountUpdates(pending)
      pending.visible = visible
      if withContainer then Display.Modify(pending, data) end
      test.Units.SetCombat(true)
      Display.Modify(pending, regionData)
      Eq(pending.cdmAuraTimer ~= nil, withContainer, label .. " in combat")
      Flush()
      Eq(pending.cdmAuraTimer ~= nil, expectTimer, label .. " after combat container")
      Eq(pending.updateCalls or 0, expectUpdates, label .. " after combat updates")
    end
    PendingCase("pending icon", "icon", data, false, true, true, 1)
    PendingCase("pending bar", "aurabar", data, false, true, true, 1)
    PendingCase("pending hidden icon", "icon", data, false, false, true, 0)
    PendingCase("unconfigured is not pending", "icon", Data({ triggers = {} }), false, true, false, 0)
    PendingCase("texture is not pending", "texture", data, false, true, false, 0)
    PendingCase("cooldownless icon is not pending", "icon", Data({ cooldown = false }), false, true, false, 0)
    PendingCase("nil data is not pending", "icon", nil, false, true, false, 0)
    PendingCase("existing container is not pending", "icon", data, true, true, true, 0)

    local style = NewRegion("icon")
    Display.Modify(style, data)
    local styleContainer = style.cdmAuraTimer
    local cooldown = styleContainer.cooldown
    Check(cooldown ~= nil, "icon container has a cooldown")
    Eq(cooldown.kind, "Cooldown", "container cooldown type")
    Eq(cooldown.parent, styleContainer.button, "container cooldown parent")
    Eq(cooldown.template, "CooldownFrameTemplate", "container cooldown template")
    Eq(cooldown.swipe, true, "construction draws the swipe")
    Eq(cooldown.edge, false, "construction hides the edge")
    Eq(cooldown.hideNumbers, false, "construction shows the numbers")
    Eq(cooldown.reverse, true, "construction reverse")
    local function Clear()
      cooldown.swipe, cooldown.edge, cooldown.reverse, cooldown.hideNumbers = nil, nil, nil, nil
    end
    local function Bool(value) return value and true or false end
    for _, case in ipairs({ { nil, true }, { true, true }, { false, false }, { 0, true } }) do
      style.cooldownSwipe = case[1]
      Clear()
      Display.Style(style)
      Eq(cooldown.swipe, case[2], "swipe for " .. tostring(case[1]))
    end
    style.cooldownSwipe = nil
    for _, case in ipairs({ { nil, false }, { false, false }, { true, true }, { 1, false } }) do
      style.cooldownEdge = case[1]
      Clear()
      Display.Style(style)
      Eq(cooldown.edge, case[2], "edge for " .. tostring(case[1]))
    end
    style.cooldownEdge = nil
    for _, case in ipairs({ { nil, false }, { false, false }, { true, true }, { 1, false } }) do
      style.cdmConfiguredHideNumbers = case[1]
      Clear()
      Display.Style(style)
      Eq(cooldown.hideNumbers, case[2], "hide numbers for " .. tostring(case[1]))
    end
    style.cdmConfiguredHideNumbers = nil
    for _, inverse in ipairs({ "nil", false, true, 1 }) do
      for _, cooldownInverse in ipairs({ "nil", false, true, "x" }) do
        style.inverseDirection = inverse ~= "nil" and inverse or nil
        style.cooldown.inverse = cooldownInverse ~= "nil" and cooldownInverse or nil
        Clear()
        Display.Style(style)
        Eq(cooldown.reverse, Bool(style.inverseDirection) == Bool(style.cooldown.inverse),
          "reverse for " .. tostring(inverse) .. " and " .. tostring(cooldownInverse))
      end
    end
    local savedCooldown = style.cooldown
    style.cooldown = nil
    for _, inverse in ipairs({ "nil", true, 1 }) do
      style.inverseDirection = inverse ~= "nil" and inverse or nil
      Clear()
      Display.Style(style)
      Eq(cooldown.reverse, inverse == "nil", "reverse without region cooldown for " .. tostring(inverse))
    end
    style.cooldown = savedCooldown
    style.inverseDirection = nil
    savedCooldown.inverse = nil

    local function NotStylable(label, setup)
      setup()
      Clear()
      styleContainer.frame.level = 99
      Display.Style(style)
      Eq(cooldown.swipe, nil, label .. " swipe untouched")
      Eq(cooldown.edge, nil, label .. " edge untouched")
      Eq(cooldown.reverse, nil, label .. " reverse untouched")
      Eq(cooldown.hideNumbers, nil, label .. " numbers untouched")
      Eq(styleContainer.frame.level, 3, label .. " levels still synchronized")
      cooldown.accessible, cooldown.accessError, cooldown.noAccessCheck = true, nil, nil
    end
    NotStylable("inaccessible", function() cooldown.accessible = false end)
    NotStylable("non boolean access", function() cooldown.accessible = 1 end)
    NotStylable("secret access", function() cooldown.accessible = Secret.Wrap(true) end)
    NotStylable("failing access", function() cooldown.accessError = true end)
    NotStylable("missing access check", function() cooldown.noAccessCheck = true end)
    Clear()
    Display.Style(style)
    Eq(cooldown.swipe, true, "accessible cooldown is styled again")

    do
      local other = { cooldown = Fake("Cooldown") }
      other.cooldown.accessible = false
      Clear()
      Display.Style(style, other)
      Eq(other.cooldown.swipe, true, "initializing container is styled without access check")
      Eq(other.cooldown.reverse, true, "initializing container reverse")
      Eq(cooldown.swipe, nil, "initializing container wins over the region container")
      local none = NewRegion("icon")
      calls = {}
      Display.Style(none)
      Eq(#calls, 0, "style without container does nothing")
    end

    barContainer.frame.level, barContainer.statusBar.level = 99, 99
    Display.Style(barRegion)
    Eq(barContainer.frame.level, 4, "style synchronizes the bar container frame level")
    Eq(barContainer.statusBar.level, 4, "style synchronizes the status bar level")

    local update = NewRegion("icon")
    Display.Modify(update, data)
    local updateContainer = update.cdmAuraTimer
    updateContainer.cooldown.swipe = nil
    calls = {}
    Display.Update(update)
    Eq(update.cdmNativeProgress, true, "update makes the icon native")
    Eq(Count(update.cooldown, "Hide"), 1, "update hides the region cooldown")
    Eq(updateContainer.cooldown.swipe, true, "update styles the native cooldown")
    Eq(updateContainer.frame.unit, "target", "update binds the unit")
    Eq(updateContainer.frame.enabled, true, "update enables the container")
    Eq(updateContainer.wanted, true, "update wants the container")
    Eq(Count(updateContainer.frame, "SetUnit"), 1, "unit bound once")
    Check(Find(update.cooldown, "Hide") < Find(updateContainer.frame, "SetUnit"), "hide before binding")
    Check(FindLast(updateContainer.cooldown, "SetHideCountdownNumbers") < Find(updateContainer.frame, "SetUnit"),
      "style before binding")
    Display.Update(update)
    Eq(Count(updateContainer.frame, "SetUnit"), 1, "repeated update does not bind again")
    Eq(update.cdmNativeProgress, true, "repeated update stays native")

    update.state.progressType = "durationObject"
    Display.Update(update)
    Eq(update.cdmNativeProgress, nil, "invalid source clears native progress")
    Eq(updateContainer.wanted, false, "invalid source releases the container")
    Eq(updateContainer.frame.enabled, false, "invalid source disables the container")
    update.state.progressType = "static"
    Display.Update(update)
    Eq(update.cdmNativeProgress, true, "valid source is native again")
    Eq(updateContainer.frame.enabled, true, "valid source enables the container again")

    local savedState = update.state
    update.state = nil
    Display.Update(update)
    Eq(update.cdmNativeProgress, nil, "missing state clears native progress")
    Eq(updateContainer.wanted, false, "missing state releases the container")
    update.state = savedState

    local savedProgressData = update.cdmProgressData
    update.cdmProgressData = nil
    Display.Update(update)
    Eq(update.cdmNativeProgress, nil, "missing data clears native progress")
    Eq(updateContainer.wanted, false, "missing data releases the container")
    update.cdmProgressData = savedProgressData
    update.regionType = "texture"
    Display.Update(update)
    Eq(update.cdmNativeProgress, nil, "region without builder is not native")
    Eq(updateContainer.wanted, false, "region without builder releases the container")
    update.regionType = nil
    Display.Update(update)
    Eq(update.cdmNativeProgress, true, "data type is used when the region has none")
    update.regionType = "icon"

    do
      local noCooldown = NewRegion("icon")
      noCooldown.cooldown = nil
      Display.Modify(noCooldown, data)
      Display.Update(noCooldown)
      Eq(noCooldown.cdmNativeProgress, true, "icon without region cooldown is native")
    end

    do
      local lazy = NewRegion("icon")
      CountUpdates(lazy)
      lazy.cdmProgressData = data
      test.Units.SetCombat(true)
      local before, attemptsBefore = #created, loadAttempts
      Display.Update(lazy)
      Eq(lazy.cdmAuraTimer, nil, "combat update builds nothing")
      Eq(lazy.cdmNativeProgress, nil, "combat update is not native")
      Eq(#created, before, "combat update creates no frame")
      Eq(loadAttempts, attemptsBefore, "combat update does not touch the addon")
      Flush()
      Check(lazy.cdmAuraTimer ~= nil, "combat update leaves the region pending")
      Eq(lazy.updateCalls, 1, "pending region is updated after combat")

      local vanishing = NewRegion("icon")
      CountUpdates(vanishing)
      vanishing.cdmProgressData = data
      mode = "vanish"
      attemptsBefore = loadAttempts
      Display.Update(vanishing)
      Eq(loadAttempts - attemptsBefore, 1, "update asks for the addon once")
      Eq(vanishing.cdmAuraTimer, nil, "no container when the addon is unavailable")
      Eq(vanishing.cdmNativeProgress, nil, "unavailable addon is not native")
      mode, CustomAuraContainerAuraProcessingPolicy = "normal", { None = 77 }
      Flush()
      Eq(vanishing.cdmAuraTimer, nil, "unavailable addon does not leave the region pending")
      Eq(vanishing.updateCalls or 0, 0, "unavailable addon region is not updated after combat")

      local building = NewRegion("icon")
      building.cdmProgressData = data
      Display.Update(building)
      Check(building.cdmAuraTimer ~= nil, "update builds a missing container")
      Eq(building.cdmNativeProgress, true, "built container is native")
      Eq(building.cdmAuraTimer.frame.unit, "target", "built container is bound")

      local idle = NewRegion("icon")
      idle.state = nil
      idle.cdmProgressData = data
      local idleBefore, idleAttempts = #created, loadAttempts
      Display.Update(idle)
      Eq(idle.cdmAuraTimer, nil, "update without source builds nothing")
      Eq(#created, idleBefore, "update without source creates no frame")
      Eq(loadAttempts, idleAttempts, "update without source does not touch the addon")
    end

    do
      local bare = NewRegion("icon")
      local bareContainer = { frame = Fake("AuraContainer"), owner = bare }
      bare.cdmAuraTimer = bareContainer
      bare.cdmProgressData = data
      Display.Update(bare)
      Eq(bare.cdmNativeProgress, nil, "uninitialized container is not native")
      Eq(bareContainer.frame.unit, "target", "uninitialized container is still bound")
      Eq(bareContainer.wanted, true, "uninitialized container is wanted")
    end

    local bar = NewRegion("aurabar")
    Display.Modify(bar, data)
    local barUpdateContainer = bar.cdmAuraTimer
    bar.bar.nativeBar = nil
    bar.cdmNativeProgress = nil
    calls = {}
    Display.Update(bar)
    Eq(bar.cdmNativeProgress, true, "update makes the bar native")
    Eq(bar.bar.nativeBar, barUpdateContainer.statusBar, "update shows the native bar")
    Eq(Count(barUpdateContainer.button, "SetDurationBar"), 0, "unchanged direction is not applied again")
    Eq(barUpdateContainer.frame.unit, "target", "bar container is bound")
    Check(Find(bar.bar, "ShowNativeBar") < Find(barUpdateContainer.frame, "SetUnit"), "bar shown before binding")
    bar.inverseDirection = true
    calls = {}
    Display.Update(bar)
    Eq(Count(barUpdateContainer.button, "SetDurationBar"), 1, "inverse direction applied")
    Eq(calls[Find(barUpdateContainer.button, "SetDurationBar")][4].direction, 1, "inverse direction value")
    bar.inverseDirection = false
    calls = {}
    Display.Update(bar)
    Eq(calls[Find(barUpdateContainer.button, "SetDurationBar")][4].direction, 2, "normal direction value")
    test.Units.SetCombat(true)
    bar.bar.nativeBar, bar.cdmNativeProgress = nil, nil
    Display.Update(bar)
    Eq(bar.cdmNativeProgress, true, "prepared bar is native in combat")
    Eq(bar.bar.nativeBar, barUpdateContainer.statusBar, "prepared bar is shown in combat")
    Flush()

    CreateFrame, C_AddOns = realCreateFrame, realAddOns
    CustomAuraContainerAuraProcessingPolicy, Enum.StatusBarTimerDirection = savedPolicy, savedDirections
  end

  do
    local icon = private.EnsureRegion("Icon")
    local cooldown = icon.cooldown
    local calls, shown, reverse = {}, false, false
    local failCooldown, failDuration = false, false
    local snapshots = {}
    local function Log(...) calls[#calls + 1] = {...} end
    local function Reset() for index = #calls, 1, -1 do calls[index] = nil end end
    local function Names()
      local names = {}
      for _, call in ipairs(calls) do names[#names + 1] = call[1] end
      return table.concat(names, ",")
    end
    local function Last(name)
      for index = #calls, 1, -1 do
        if calls[index][1] == name then return calls[index], index end
      end
    end
    local function Count(name)
      local total = 0
      for _, call in ipairs(calls) do if call[1] == name then total = total + 1 end end
      return total
    end
    local function Ending() return Names():match("[a-z]+$") end
    cooldown.Show = function() shown = true Log("show") end
    cooldown.Hide = function() shown = false Log("hide") end
    cooldown.IsShown = function() return shown end
    cooldown.Pause = function() Log("pause") end
    cooldown.Resume = function() Log("resume") end
    cooldown.GetReverse = function() return reverse end
    cooldown.SetReverse = function(_, value)
      reverse = value
      Log("reverse", value)
      snapshots[#snapshots + 1] = {
        durationObject = cooldown.durationObject, inverse = cooldown.inverse, expirationTime = cooldown.expirationTime,
        duration = cooldown.duration, shown = shown, applied = Count("cooldown") + Count("duration"),
      }
    end
    cooldown.SetCooldown = function(_, start, duration, modRate)
      Log("cooldown", start, duration, modRate)
      if failCooldown and not (start == 0 and duration == 0) then error("cooldown failed") end
    end
    local function DurationApply(_, object, clear)
      Log("duration", object, clear)
      if failDuration then error("duration failed") end
    end
    cooldown.SetCooldownFromDurationObject = DurationApply
    cooldown.SetDrawSwipeOrg = function(_, value) Log("swipe", value) end
    cooldown.SetDrawEdge = function(_, value) Log("edge", value) end
    cooldown.SetHideCountdownNumbers = function(_, value) Log("hidenumbers", value) end

    local function Fresh()
      icon.cdmNativeProgress, icon.cdmProgressState, icon.state = nil, nil, {}
      icon.cooldownSwipe, icon.cooldownEdge = true, true
      icon.cdmConfiguredHideNumbers = nil
      icon.value, icon.total, icon.duration, icon.expirationTime = nil, nil, nil, nil
      icon.modRate, icon.inverse, icon.paused, icon.durationObject = nil, nil, nil, nil
      icon.inverseDirection = true
      cooldown.expirationTime, cooldown.duration, cooldown.modRate, cooldown.durationObject = nil, nil, nil, nil
      cooldown.value, cooldown.total, cooldown.inverse, cooldown.useCooldownModRate = nil, nil, nil, nil
      cooldown.SetCooldownFromDurationObject = DurationApply
      shown, reverse, failCooldown, failDuration = false, false, false, false
      for index = #snapshots, 1, -1 do snapshots[index] = nil end
      Reset()
    end
    local function Sentinels()
      cooldown.expirationTime, cooldown.duration, cooldown.modRate = 11, 12, 13
      cooldown.durationObject = Duration(1)
      cooldown.value, cooldown.total = 14, 15
    end
    local function SentinelsKept()
      return cooldown.expirationTime == 11 and cooldown.duration == 12 and cooldown.modRate == 13
        and cooldown.durationObject ~= nil and cooldown.value == 14 and cooldown.total == 15
    end
    local function RealCooldown()
      for index = #calls, 1, -1 do
        local call = calls[index]
        if call[1] == "cooldown" and not (call[2] == 0 and call[3] == 0) then return call end
      end
    end

    Fresh()
    Eq(icon:UpdateCooldownDrawState(), false, "draw state returns false without state")
    Eq(Names(), "swipe,edge", "draw state swipe then edge")
    Eq(calls[1][2], true, "draw state swipe value")
    Eq(calls[2][2], true, "draw state edge value")
    Fresh()
    icon.cooldownSwipe, icon.cooldownEdge = nil, 1
    icon:UpdateCooldownDrawState()
    Eq(calls[1][2], false, "draw state swipe nil gives false")
    Eq(calls[2][2], false, "draw state edge 1 gives false")
    Fresh()
    icon.cooldownSwipe, icon.cooldownEdge = 1, true
    icon:UpdateCooldownDrawState()
    Eq(calls[1][2], true, "draw state swipe 1 gives true")
    Eq(calls[2][2], true, "draw state edge true")
    Fresh()
    icon.cdmProgressState = { cdmSuppressGCD = true }
    Eq(icon:UpdateCooldownDrawState(), true, "draw state suppressed result")
    Eq(calls[1][2], false, "draw state suppressed swipe")
    Eq(calls[2][2], false, "draw state suppressed edge")
    Fresh()
    icon.cdmProgressState = { cdmSuppressGCD = 1 }
    Eq(icon:UpdateCooldownDrawState(), true, "draw state truthy suppress is strict true")
    Fresh()
    icon.cdmProgressState = { cdmSuppressGCD = false }
    Eq(icon:UpdateCooldownDrawState(), false, "draw state false suppress")
    Eq(calls[1][2], true, "draw state unsuppressed swipe")
    Eq(calls[2][2], true, "draw state unsuppressed edge")
    Fresh()
    icon.cdmProgressState = {}
    Eq(icon:UpdateCooldownDrawState(), false, "draw state state without suppress field")

    for _, name in ipairs({"UpdateValue", "UpdateTime", "PreShow"}) do
      Fresh()
      icon.cdmNativeProgress = true
      Sentinels()
      icon.value, icon.total, icon.duration, icon.expirationTime = 1, 2, 5, GetTime() + 5
      icon.durationObject = Duration(3)
      shown = true
      Reset()
      icon[name](icon)
      Eq(#calls, 0, name .. " native makes no cooldown call")
      Check(SentinelsKept(), name .. " native keeps cooldown fields")
      Eq(icon.cdmConfiguredHideNumbers, nil, name .. " native keeps configured hide numbers")

      Fresh()
      icon.cdmProgressState = { cdmSuppressGCD = true }
      Sentinels()
      icon.value, icon.total, icon.duration, icon.expirationTime = 1, 2, 5, GetTime() + 5
      icon.durationObject = Duration(3)
      shown = true
      Reset()
      icon[name](icon)
      Eq(Names(), "swipe,edge,hide", name .. " suppressed draws then hides only")
      Eq(calls[1][2], false, name .. " suppressed swipe")
      Eq(calls[2][2], false, name .. " suppressed edge")
      Check(SentinelsKept(), name .. " suppressed keeps cooldown fields")
      Eq(shown, false, name .. " suppressed hides cooldown")
    end

    for _, name in ipairs({"UpdateValue", "UpdateTime"}) do
      for _, configured in ipairs({true, false}) do
        Fresh()
        icon.cdmConfiguredHideNumbers = configured
        icon.value, icon.total = 1, 2
        icon[name](icon)
        Check(Last("hidenumbers") ~= nil, name .. " sets hide numbers")
        Eq((Last("hidenumbers") or {})[2], configured, name .. " applies configured hide numbers " .. tostring(configured))
        Eq(icon.cdmConfiguredHideNumbers, configured, name .. " keeps configured hide numbers " .. tostring(configured))
      end
      Fresh()
      icon.cdmConfiguredHideNumbers = true
      icon.value, icon.total = 1, 2
      icon[name](icon)
      local _, drawIndex = Last("edge")
      local _, hideIndex = Last("hidenumbers")
      Check(drawIndex < hideIndex, name .. " draw state before hide numbers")
    end

    Fresh()
    icon.value, icon.total = 3, 10
    Sentinels()
    icon:UpdateValue()
    Eq(cooldown.expirationTime, nil, "UpdateValue clears expiration")
    Eq(cooldown.duration, nil, "UpdateValue clears duration")
    Eq(cooldown.modRate, nil, "UpdateValue clears modRate")
    Eq(cooldown.durationObject, nil, "UpdateValue clears duration object")
    Eq(cooldown.value, 3, "UpdateValue stores value")
    Eq(cooldown.total, 10, "UpdateValue stores total")
    Eq(shown, true, "UpdateValue shows cooldown")
    local applied = Last("cooldown")
    Near(applied[2], GetTime() + 3 - 10, "UpdateValue cooldown start")
    Eq(applied[3], 10, "UpdateValue cooldown duration")
    Eq(applied[4], nil, "UpdateValue passes no modRate")
    Eq(Ending(), "pause", "UpdateValue ends paused")
    Eq(Count("pause"), 1, "UpdateValue pauses once")
    Eq(Count("resume"), 0, "UpdateValue never resumes")
    local _, showIndex = Last("show")
    local _, cooldownIndex = Last("cooldown")
    Check(showIndex < cooldownIndex, "UpdateValue shows before applying")

    for _, bounds in ipairs({{0, 10, true}, {10, 10, true}, {-1, 10, false}, {11, 10, false}, {0, 0, true}}) do
      Fresh()
      icon.value, icon.total = bounds[1], bounds[2]
      icon:UpdateValue()
      Eq(shown, bounds[3], ("UpdateValue bounds %s of %s"):format(bounds[1], bounds[2]))
      Eq(Count("cooldown"), bounds[3] and 1 or 0, ("UpdateValue bounds apply %s of %s"):format(bounds[1], bounds[2]))
      if not bounds[3] then
        Eq(Ending(), "hide", ("UpdateValue out of bounds hides %s"):format(bounds[1]))
        Eq(Count("pause"), 0, "UpdateValue out of bounds no pause")
        Eq(cooldown.value, bounds[1], "UpdateValue out of bounds still stores value")
        Eq(cooldown.total, bounds[2], "UpdateValue out of bounds still stores total")
      end
    end
    for label, values in pairs({
      secretValue = {Secret.Wrap(3), 10}, secretTotal = {3, Secret.Wrap(10)}, stringValue = {"3", 10}, nilValue = {nil, 10},
    }) do
      Fresh()
      icon.value, icon.total = values[1], values[2]
      shown = true
      icon:UpdateValue()
      Eq(shown, false, "UpdateValue unreadable hides " .. label)
      Eq(Count("cooldown"), 0, "UpdateValue unreadable applies nothing " .. label)
      Eq(Count("pause"), 0, "UpdateValue unreadable no pause " .. label)
    end
    Fresh()
    icon.value, icon.total = 3, 10
    failCooldown = true
    icon:UpdateValue()
    Eq(shown, false, "UpdateValue failed apply hides")
    Eq(Count("pause"), 0, "UpdateValue failed apply does not pause")
    Eq(Ending(), "hide", "UpdateValue failed apply ends hidden")

    Fresh()
    icon.state = { cdmBuff = true, auraActive = false }
    icon.value, icon.total = 3, 10
    Sentinels()
    shown = true
    icon:UpdateValue()
    Eq(shown, false, "UpdateValue inactive hides")
    Eq(Count("cooldown"), 0, "UpdateValue inactive applies nothing")
    Eq(cooldown.value, 14, "UpdateValue inactive keeps value")
    Eq(cooldown.total, 15, "UpdateValue inactive keeps total")
    Eq(cooldown.expirationTime, nil, "UpdateValue inactive clears expiration")
    Eq(cooldown.durationObject, nil, "UpdateValue inactive clears duration object")
    Fresh()
    icon.state = { cdmBuff = true, auraActive = true }
    icon.value, icon.total = 3, 10
    icon:UpdateValue()
    Eq(shown, true, "UpdateValue active aura shows")
    Fresh()
    icon.state = { cdmBuff = false, auraActive = false }
    icon.value, icon.total = 3, 10
    icon:UpdateValue()
    Eq(shown, true, "UpdateValue non buff entry is never inactive")

    Fresh()
    Sentinels()
    icon.paused = true
    icon.duration, icon.expirationTime, icon.modRate, icon.inverse = 8, GetTime() + 8, 2, true
    icon:UpdateTime()
    Eq(cooldown.value, nil, "UpdateTime clears value")
    Eq(cooldown.total, nil, "UpdateTime clears total")
    Eq(Count("pause"), 1, "UpdateTime paused pauses")
    Eq(Count("resume"), 0, "UpdateTime paused does not resume")
    Fresh()
    icon.duration, icon.expirationTime = 8, GetTime() + 8
    icon:UpdateTime()
    Eq(Count("resume"), 1, "UpdateTime unpaused resumes")
    Eq(Count("pause"), 0, "UpdateTime unpaused does not pause")

    Fresh()
    local expiration = GetTime() + 8
    Sentinels()
    icon.duration, icon.expirationTime, icon.modRate, icon.inverse = 8, expiration, 2, true
    cooldown.useCooldownModRate = true
    icon:UpdateTime()
    Eq(shown, true, "UpdateTime numeric shows")
    Eq(cooldown.expirationTime, expiration, "UpdateTime numeric copies expiration")
    Eq(cooldown.duration, 8, "UpdateTime numeric copies duration")
    Eq(cooldown.modRate, 2, "UpdateTime numeric copies modRate")
    Eq(cooldown.inverse, true, "UpdateTime numeric copies inverse")
    Eq(cooldown.durationObject, nil, "UpdateTime numeric clears duration object")
    applied = RealCooldown()
    Near(applied[2], expiration - 8, "UpdateTime numeric start")
    Eq(applied[3], 8, "UpdateTime numeric duration")
    Eq(applied[4], 2, "UpdateTime numeric modRate when enabled")
    Check(#snapshots >= 1, "UpdateTime numeric updates direction")
    Eq(snapshots[1].inverse, true, "UpdateTime numeric inverse set before direction")
    Eq(snapshots[1].expirationTime, expiration, "UpdateTime numeric expiration set before direction")
    Eq(snapshots[1].duration, 8, "UpdateTime numeric duration set before direction")
    Eq(snapshots[1].shown, true, "UpdateTime numeric shown before direction")
    Eq(snapshots[1].applied, 0, "UpdateTime numeric applies after direction")
    Eq(reverse, true, "UpdateTime numeric direction uses the copied inverse")

    Fresh()
    icon.duration, icon.expirationTime, icon.modRate = 8, GetTime() + 8, 2
    icon:UpdateTime()
    Eq(RealCooldown()[4], nil, "UpdateTime numeric modRate withheld by default")
    Eq(cooldown.modRate, 2, "UpdateTime numeric copies modRate even when withheld")
    Fresh()
    icon.duration, icon.expirationTime = 8, GetTime() + 8
    failCooldown = true
    icon:UpdateTime()
    Eq(shown, false, "UpdateTime numeric failed apply hides")
    Eq(Ending(), "hide", "UpdateTime numeric failed apply ends hidden")

    local function NumericCase(label, duration, expirationTime, expectShown)
      Fresh()
      icon.duration, icon.expirationTime, icon.modRate = duration, expirationTime, 1.5
      shown = true
      icon:UpdateTime()
      Eq(shown, expectShown, "UpdateTime numeric " .. label .. " shown")
      Eq(RealCooldown() ~= nil, expectShown, "UpdateTime numeric " .. label .. " applied")
      if not expectShown then
        Eq(cooldown.expirationTime, expirationTime, "UpdateTime numeric " .. label .. " copies expiration")
        Eq(cooldown.duration, duration, "UpdateTime numeric " .. label .. " copies duration")
        Eq(cooldown.modRate, 1.5, "UpdateTime numeric " .. label .. " copies modRate")
        Eq(cooldown.durationObject, nil, "UpdateTime numeric " .. label .. " clears duration object")
      end
    end
    NumericCase("zero duration", 0, GetTime() + 5, false)
    NumericCase("negative duration", -1, GetTime() + 5, false)
    NumericCase("expired", 5, GetTime() - 1, false)
    NumericCase("infinite expiration", 5, math.huge, false)
    NumericCase("secret duration", Secret.Wrap(5), GetTime() + 5, false)
    NumericCase("secret expiration", 5, Secret.Wrap(GetTime() + 5), false)
    NumericCase("string duration", "5", GetTime() + 5, false)
    NumericCase("nil expiration", 5, nil, false)
    NumericCase("small positive duration", 0.001, GetTime() + 5, true)

    Fresh()
    Sentinels()
    icon.durationObject = Duration(4)
    icon.inverse = true
    icon.duration, icon.expirationTime, icon.modRate = 9, GetTime() + 9, 2
    icon:UpdateTime()
    Eq(cooldown.durationObject, icon.durationObject, "UpdateTime duration object stored")
    Eq(cooldown.inverse, true, "UpdateTime duration object copies inverse")
    Eq(cooldown.expirationTime, nil, "UpdateTime duration object clears expiration")
    Eq(cooldown.duration, nil, "UpdateTime duration object clears duration")
    Eq(cooldown.modRate, nil, "UpdateTime duration object clears modRate")
    Eq(shown, true, "UpdateTime duration object shows")
    Check(#snapshots >= 1, "UpdateTime duration object updates direction")
    Eq(snapshots[1].durationObject, icon.durationObject, "UpdateTime duration object set before direction")
    Eq(snapshots[1].inverse, true, "UpdateTime duration object inverse set before direction")
    Eq(snapshots[1].shown, true, "UpdateTime duration object shown before direction")
    Eq(snapshots[1].applied, 0, "UpdateTime duration object applies after direction")
    local durationCall = Last("duration")
    Eq(durationCall[2], icon.durationObject, "UpdateTime duration object applied")
    Eq(durationCall[3], true, "UpdateTime duration object applied with clear")
    Eq(Count("pause"), 0, "UpdateTime duration object not paused without native pause")
    Eq(Count("resume"), 1, "UpdateTime duration object resumes when unpaused")
    Eq(RealCooldown(), nil, "UpdateTime duration object ignores numbers")

    Fresh()
    icon.durationObject = Duration(4)
    icon.cdmProgressState = { cdmNativePaused = true }
    icon:UpdateTime()
    local _, pauseIndex = Last("pause")
    local _, durationIndex = Last("duration")
    Check(pauseIndex and durationIndex and pauseIndex > durationIndex, "UpdateTime native paused pauses after applying")
    Eq(Ending(), "pause", "UpdateTime native paused ends paused")
    Fresh()
    icon.durationObject = Duration(4)
    icon.cdmProgressState = { cdmNativePaused = false }
    icon:UpdateTime()
    Eq(Count("pause"), 0, "UpdateTime native not paused does not pause")

    Fresh()
    icon.durationObject = Duration(4)
    failDuration = true
    icon.cdmProgressState = { cdmNativePaused = true }
    icon:UpdateTime()
    Eq(shown, false, "UpdateTime duration object failed apply hides")
    Eq(Ending(), "hide", "UpdateTime duration object failed apply ends hidden")
    Eq(Count("pause"), 0, "UpdateTime duration object failed apply skips native pause")

    Fresh()
    icon.paused = true
    icon.durationObject = Duration(4)
    icon:UpdateTime()
    Eq(Count("pause"), 1, "UpdateTime duration object paused region pauses")
    Eq(Count("resume"), 0, "UpdateTime duration object paused region does not resume")

    Fresh()
    cooldown.SetCooldownFromDurationObject = false
    icon.durationObject = Duration(4)
    icon.duration, icon.expirationTime = 8, GetTime() + 8
    icon:UpdateTime()
    Eq(Count("duration"), 0, "UpdateTime without native duration API skips duration object")
    Eq(cooldown.durationObject, nil, "UpdateTime without native duration API clears duration object")
    Eq(shown, true, "UpdateTime without native duration API uses numbers")
    Eq(cooldown.duration, 8, "UpdateTime without native duration API copies duration")

    Fresh()
    cooldown.durationObject = Duration(6)
    shown = false
    icon:PreShow()
    Eq(shown, true, "PreShow duration object shows")
    Eq(Last("duration")[2], cooldown.durationObject, "PreShow duration object applied")
    Eq(Last("duration")[3], true, "PreShow duration object applied with clear")
    Eq(Ending(), "resume", "PreShow duration object resumes")
    Eq(Count("hide"), 0, "PreShow duration object does not hide")
    Fresh()
    cooldown.durationObject = Duration(6)
    cooldown.duration, cooldown.expirationTime = 8, GetTime() + 8
    failDuration = true
    icon:PreShow()
    Eq(shown, false, "PreShow duration object failed apply hides")
    Eq(Count("resume"), 0, "PreShow duration object failed apply does not resume")
    Eq(Count("cooldown"), 0, "PreShow duration object has priority over numbers")
    Eq(Count("hide"), 1, "PreShow duration object failed apply hides once")

    Fresh()
    cooldown.duration, cooldown.expirationTime, cooldown.modRate = 8, GetTime() + 8, 2
    cooldown.useCooldownModRate = true
    icon:PreShow()
    Eq(shown, true, "PreShow numeric shows")
    applied = Last("cooldown")
    Near(applied[2], cooldown.expirationTime - 8, "PreShow numeric start")
    Eq(applied[3], 8, "PreShow numeric duration")
    Eq(applied[4], 2, "PreShow numeric modRate when enabled")
    Eq(Ending(), "resume", "PreShow numeric resumes")
    Fresh()
    cooldown.duration, cooldown.expirationTime, cooldown.modRate = 8, GetTime() + 8, 2
    icon:PreShow()
    Eq(Last("cooldown")[4], nil, "PreShow numeric modRate withheld by default")
    Fresh()
    cooldown.duration, cooldown.expirationTime = 8, GetTime() + 8
    failCooldown = true
    icon:PreShow()
    Eq(shown, false, "PreShow numeric failed apply hides")
    Eq(Count("resume"), 0, "PreShow numeric failed apply does not resume")

    local function PreShowCase(label, duration, expirationTime, expectApplied)
      Fresh()
      cooldown.duration, cooldown.expirationTime = duration, expirationTime
      shown = true
      icon:PreShow()
      Eq(Count("cooldown"), expectApplied and 1 or 0, "PreShow " .. label .. " applied")
      if not expectApplied then
        Eq(shown, true, "PreShow " .. label .. " leaves cooldown shown")
        Eq(Count("hide"), 0, "PreShow " .. label .. " does not hide")
        Eq(Count("show"), 0, "PreShow " .. label .. " does not show")
      end
    end
    PreShowCase("tiny duration", 0.01, GetTime() + 5, false)
    PreShowCase("just above threshold", 0.011, GetTime() + 5, true)
    PreShowCase("zero duration", 0, GetTime() + 5, false)
    PreShowCase("infinite duration", math.huge, GetTime() + 5, false)
    PreShowCase("infinite expiration", 8, math.huge, false)
    PreShowCase("secret duration", Secret.Wrap(8), GetTime() + 5, false)
    PreShowCase("secret expiration", 8, Secret.Wrap(GetTime() + 5), false)
    PreShowCase("string duration", "8", GetTime() + 5, false)
    PreShowCase("past expiration", 8, GetTime() - 100, true)
    Fresh()
    icon:PreShow()
    Eq(Names(), "swipe,edge", "PreShow without data only draws")

    Fresh()
    shown = false
    icon.cdmProgressState = { cdmSuppressGCD = true }
    icon:UpdateTime()
    Eq(Count("hide"), 1, "hide is called even when already hidden")
  end

  do
    local Advance = test.Environment.Advance
    local _, ownClass = UnitClass("player")
    local Category = Enum.CooldownViewerCategory
    local Indices = Enum.EditModeCooldownViewerSystemIndices
    local visibleId = Enum.EditModeCooldownViewerSetting.VisibleSetting
    local always = Enum.CooldownViewerVisibleSetting.Always
    local presetType = Enum.EditModeLayoutType.Preset
    local savedGlobals = {}
    local function SetGlobal(owner, name, value)
      savedGlobals[#savedGlobals + 1] = {owner, name, owner[name]}
      owner[name] = value
    end
    SetGlobal(Enum, "CooldownLayoutStatus", { Success = 0, Failure = 1 })
    SetGlobal(Category, "HiddenActive", 9)

    local layoutData, entries, sets, moves, messages, editLayouts, saved
    local function Entry(category, spellID)
      return { category = category, spellID = spellID }
    end
    entries = {
      [10] = Entry(Category.TrackedBuff, 1), [11] = Entry(Category.TrackedBar, 2),
      [20] = Entry(Category.HiddenActive, 100), [30] = Entry(Category.HiddenActive, 200),
    }
    sets = {
      [Category.TrackedBuff] = { 10 }, [Category.TrackedBar] = { 11 }, [Category.Essential] = { 20 },
      [Category.Utility] = { 30 },
    }
    moves, messages, saved = {}, {}, 0
    layoutData = "original-layout"
    editLayouts = { activeLayout = 1, layouts = {} }
    local function Viewer(name)
      return { system = Enum.EditModeSystem.CooldownViewer, systemIndex = Indices[name], settings = {} }
    end

    SetGlobal(_G, "C_CooldownViewer", setmetatable({
      GetLayoutData = function() return layoutData end,
      SetLayoutData = function(blob) saved = saved + 1 layoutData = blob end,
      GetCooldownViewerCategorySet = function(category) return sets[category] or {} end,
    }, { __index = C_CooldownViewer }))
    SetGlobal(_G, "C_EditMode", setmetatable({
      GetLayouts = function() return CopyTable(editLayouts) end,
      SaveLayouts = function(state)
        editLayouts = { activeLayout = editLayouts.activeLayout, layouts = {} }
        for _, layout in ipairs(state.layouts) do
          if layout.layoutType ~= presetType then table.insert(editLayouts.layouts, CopyTable(layout)) end
        end
      end,
      SetActiveLayout = function(index) editLayouts.activeLayout = index end,
    }, { __index = C_EditMode }))
    SetGlobal(_G, "EditModePresetLayoutManager", {
      GetCopyOfPresetLayouts = function()
        local systems = {}
        for _, name in ipairs({"Essential", "Utility", "BuffIcon", "BuffBar"}) do table.insert(systems, Viewer(name)) end
        return { { layoutName = "Modern", layoutType = presetType, systems = systems } }
      end,
    })
    local liveManager = { IsLoaded = function() return true end, HasPendingChanges = function() return false end }
    SetGlobal(_G, "CooldownViewerSettings", {
      GetDataProvider = function() end,
      GetLayoutManager = function() return liveManager end,
      IsShown = function() return false end,
    })
    SetGlobal(_G, "EditModeManagerFrame", { IsShown = function() return false end })

    local captured = {}
    local steps = {}
    local liveEvents, liveNotifications = 0, 0
    local function Step(name) steps[#steps + 1] = name end
    local providerMixin = {
      SetLayoutManager = function(self, manager)
        Step("provider.SetLayoutManager")
        captured.provider = self
        self.layoutManager = manager
      end,
      CheckBuildDisplayData = function(self)
        Step("provider.CheckBuildDisplayData")
        local manager = self.layoutManager
        self.displayLayout = manager and manager.activeLayout
        self.displayManagerReady = manager ~= nil and manager.layoutsLoaded == true
      end,
      GetCooldownInfoForID = function(_, id) return entries[id] end,
      SetCooldownToCategory = function(self, id, category)
        moves[#moves + 1] = { id, category, self }
        entries[id].category = category
        return Enum.CooldownLayoutStatus.Success
      end,
    }
    local managerMixin = {
      Init = function(self, provider, serializer)
        Step("manager.Init")
        captured.manager = self
        self.layouts, self.lastActiveLayoutIDsPerSpec, self.layoutsLoaded = {}, {}, false
        self.initProvider, self.initSerializer = provider, serializer
      end,
      SwitchToBestLayoutForSpec = function(self)
        Step("manager.SwitchToBestLayoutForSpec")
        self.activeLayout = self.layouts[1]
        self:SetHasPendingChanges(true)
        self:NotifyListeners()
      end,
      SetShouldCheckAddLayoutStatus = function(self, value)
        Step("manager.SetShouldCheckAddLayoutStatus")
        self.shouldCheckAddLayoutStatus = value
      end,
      SetHasPendingChanges = function(self, pending)
        liveEvents = liveEvents + 1
        self.hasPendingChanges = pending
      end,
      NotifyListeners = function() liveNotifications = liveNotifications + 1 end,
    }
    local serializerMixin = {
      Init = function(self, manager)
        Step("serializer.Init")
        captured.serializer = self
        self.initManager = manager
        manager.layouts = { "saved-layout" }
        manager.layoutsLoaded = true
      end,
      SerializeLayouts = function(self)
        captured.serializedBy = self
        return "staged-layout"
      end,
    }
    local function KeySet(mixin)
      local keys = {}
      for key, value in pairs(mixin) do keys[key] = value end
      return keys
    end
    local providerKeys, managerKeys, serializerKeys = KeySet(providerMixin), KeySet(managerMixin), KeySet(serializerMixin)
    SetGlobal(_G, "CooldownViewerSettingsDataProviderMixin", providerMixin)
    SetGlobal(_G, "CooldownViewerLayoutManagerMixin", managerMixin)
    SetGlobal(_G, "CooldownViewerDataStoreSerializationMixin", serializerMixin)
    SetGlobal(_G, "print", function(text) messages[#messages + 1] = text end)
    SetGlobal(_G, "StaticPopup_Show", function() end)
    SetGlobal(private, "ApplyCDMBackground", function() end)
    local originalHide = private.db.cdmHideBlizzard
    private.db.cdmHideBlizzard = nil
    private.db.cdmClassPackSetupBackups = nil
    C_CVar.SetCVar("cooldownViewerEnabled", nil)

    Eq(WeakAuras.SetupClassPackCDM(ownClass), true, "layout setup accepted")
    for _ = 1, 80 do
      if saved > 0 then break end
      Advance(1)
    end
    Advance(2)
    Eq(#messages, 1, "layout setup reports once")
    Check(not tostring(messages[1]):find("stopped"), "layout setup did not stop: " .. tostring(messages[1]))
    Eq(saved, 1, "layout setup saved once")
    Eq(layoutData, "staged-layout", "layout setup stores the serialized layout")

    local provider, manager, serializer = captured.provider, captured.manager, captured.serializer
    Check(provider and manager and serializer, "three objects were built")
    Check(provider ~= providerMixin and manager ~= managerMixin and serializer ~= serializerMixin, "objects are copies of the mixins")
    Check(provider ~= manager and manager ~= serializer and provider ~= serializer, "objects are distinct")
    for key, value in pairs(providerKeys) do Eq(providerMixin[key], value, "provider mixin kept " .. key) end
    for key, value in pairs(managerKeys) do Eq(managerMixin[key], value, "manager mixin kept " .. key) end
    for key, value in pairs(serializerKeys) do Eq(serializerMixin[key], value, "serializer mixin kept " .. key) end
    for key in pairs(providerMixin) do Check(providerKeys[key] ~= nil, "provider mixin gained " .. key) end
    for key in pairs(managerMixin) do Check(managerKeys[key] ~= nil, "manager mixin gained " .. key) end
    for key in pairs(serializerMixin) do Check(serializerKeys[key] ~= nil, "serializer mixin gained " .. key) end

    Eq(provider.layoutManager, manager, "provider knows the manager")
    Eq(manager.initProvider, provider, "manager knows the provider")
    Eq(manager.initSerializer, serializer, "manager knows the serializer")
    Eq(serializer.initManager, manager, "serializer knows the manager")
    Eq(manager.layouts[1], "saved-layout", "saved layouts survive the initialization")
    Eq(manager.activeLayout, "saved-layout", "the best layout is active")
    Eq(provider.displayLayout, "saved-layout", "display data is built from the active layout")
    Eq(provider.displayManagerReady, true, "display data is built from a loaded manager")
    Eq(manager.shouldCheckAddLayoutStatus, true, "add layout status is checked")
    Eq(manager.hasPendingChanges, false, "no pending changes")
    Eq(liveEvents, 0, "live pending changes handler never runs")
    Eq(liveNotifications, 0, "live listeners are never notified")
    Check(rawget(manager, "SetHasPendingChanges") ~= nil and rawget(manager, "SetHasPendingChanges") ~= managerMixin.SetHasPendingChanges,
      "manager owns its pending changes handler")
    manager:SetHasPendingChanges(true)
    Eq(manager.hasPendingChanges, true, "pending changes handler stores the value")
    Eq(liveEvents, 0, "pending changes handler raises no event")
    Eq(manager:NotifyListeners(), nil, "notifying listeners does nothing")
    Eq(liveNotifications, 0, "notifying listeners reaches nobody")

    Eq(#moves, 3, "moves went through the provider")
    for _, move in ipairs(moves) do Eq(move[3], provider, "move " .. move[1] .. " used the built provider") end
    Eq(captured.serializedBy, serializer, "serialization used the built serializer")

    local position = {}
    for index, name in ipairs(steps) do position[name] = position[name] or index end
    Check(position["manager.Init"] < position["serializer.Init"], "manager init before serializer init")
    Check(position["serializer.Init"] < position["manager.SwitchToBestLayoutForSpec"], "serializer init before layout choice")
    Check(position["provider.SetLayoutManager"] < position["provider.CheckBuildDisplayData"], "manager linked before display data")
    Check(position["manager.SwitchToBestLayoutForSpec"] < position["provider.CheckBuildDisplayData"], "layout chosen before display data")

    for index = #savedGlobals, 1, -1 do
      local entry = savedGlobals[index]
      entry[1][entry[2]] = entry[3]
    end
    private.db.cdmHideBlizzard = originalHide
    private.db.cdmClassPackSetupBackups = nil
    C_CVar.SetCVar("cooldownViewerEnabled", nil)
  end

  do
    local Warnings = private.AuraWarnings
    local keys = {
      blizzard_aura_display = "message display",
      blizzard_aura_sound = "message sound",
      blizzard_aura_single = "message single",
      blizzard_aura_grid = "message grid",
      blizzard_aura_dynamicgroup = "message dynamic group",
      CustomCodeError = "message custom code",
      other_key = "message other",
    }
    local function Seed(uid)
      for key, message in pairs(keys) do Warnings.UpdateWarning(uid, key, "warning", message) end
    end
    local function Remaining(uid)
      local _, _, text = Warnings.FormatWarnings(uid)
      local present = {}
      for key, message in pairs(keys) do
        present[key] = text ~= nil and text:find(message, 1, true) ~= nil
      end
      return present
    end
    local function NewData(id, uid)
      return Aura(id, "icon", { uid = uid })
    end
    local enabledSeen
    local function StubEnabled(result)
      enabledSeen = {}
      Stub(private.BlizzardAuraDisplay, "Enabled", function(data)
        enabledSeen[data] = true
        return result
      end)
      for _, name in ipairs({"Modify", "Restore", "Release", "Apply", "SyncProgressSource"}) do
        Stub(private.BlizzardAuraDisplay, name, function() end)
      end
    end

    for _, scenario in ipairs({
      {label = "false", result = false, cleared = true},
      {label = "nil", result = nil, cleared = true},
      {label = "true", result = true, cleared = false},
    }) do
      for _, simple in ipairs({false, true}) do
        local uid = "pAddUid" .. scenario.label .. tostring(simple)
        local data = NewData("PAdd " .. scenario.label .. tostring(simple), uid)
        Seed(uid)
        StubEnabled(scenario.result)
        WeakAuras.Add(data, simple)
        Eq(enabledSeen[data], true, "pAdd asks Enabled about the added data " .. scenario.label .. tostring(simple))
        local remaining = Remaining(uid)
        local label = scenario.label .. " simple " .. tostring(simple)
        Eq(remaining.blizzard_aura_display, not scenario.cleared, "pAdd display warning " .. label)
        Eq(remaining.blizzard_aura_sound, not scenario.cleared, "pAdd sound warning " .. label)
        Eq(remaining.blizzard_aura_single, not scenario.cleared, "pAdd single warning " .. label)
        Eq(remaining.blizzard_aura_grid, true, "pAdd keeps grid warning " .. label)
        Eq(remaining.blizzard_aura_dynamicgroup, true, "pAdd keeps dynamic group warning " .. label)
        Eq(remaining.other_key, true, "pAdd keeps unrelated warning " .. label)
        Eq(remaining.CustomCodeError, simple, "pAdd custom code warning " .. label)
        Unstub()
      end
    end

    do
      local uid = "pAddUidReal"
      local data = NewData("PAdd real", uid)
      Seed(uid)
      WeakAuras.Add(data, true)
      local remaining = Remaining(uid)
      Eq(remaining.blizzard_aura_display, false, "pAdd real Enabled clears display for a non secret aura")
      Eq(remaining.blizzard_aura_sound, false, "pAdd real Enabled clears sound for a non secret aura")
      Eq(remaining.blizzard_aura_single, false, "pAdd real Enabled clears single for a non secret aura")
      Eq(remaining.blizzard_aura_grid, true, "pAdd real Enabled keeps grid")
    end

    do
      local updates = {}
      local originalFire = private.callbacks.Fire
      Stub(private.callbacks, "Fire", function(self, event, ...)
        if event == "AuraWarningsUpdated" then updates[#updates + 1] = ... end
        return originalFire(self, event, ...)
      end)
      StubEnabled(false)
      WeakAuras.Add(NewData("PAdd quiet", "pAddUidQuiet"), true)
      Unstub()
      Eq(#updates, 0, "pAdd without existing warnings notifies nobody")
    end

    do
      local first = NewData("PAdd owner", "pAddUidShared")
      StubEnabled(true)
      WeakAuras.Add(first, true)
      Unstub()
      Seed("pAddUidShared")
      local second = NewData("PAdd intruder", "pAddUidShared")
      StubEnabled(false)
      WeakAuras.Add(second, true)
      Unstub()
      local remaining = Remaining("pAddUidShared")
      Eq(remaining.blizzard_aura_display, false, "pAdd clears the display warning of the previous uid")
      Eq(remaining.blizzard_aura_sound, false, "pAdd clears the sound warning of the previous uid")
      Eq(remaining.blizzard_aura_single, false, "pAdd clears the single warning of the previous uid")
      Eq(remaining.blizzard_aura_grid, true, "pAdd keeps the grid warning of the previous uid")
      Check(second.uid ~= "pAddUidShared", "pAdd gives the intruder a fresh uid")
    end
  end

  do
    local L = WeakAuras.L
    local WHITE = "Interface\\Buttons\\WHITE8X8"
    local savedGlobals = {}
    local function SetGlobal(name, value)
      savedGlobals[#savedGlobals + 1] = {name, _G[name]}
      _G[name] = value
    end

    local pickerColor = {0.2, 0.4, 0.6}
    local picker = Frames.CreateFrame("Frame", "ColorPickerFrame", UIParent)
    picker.GetColorRGB = function() return pickerColor[1], pickerColor[2], pickerColor[3] end
    picker.SetColorRGB = function(_, r, g, b) pickerColor = {r, g, b} end
    SetGlobal("ColorPickerFrame", picker)
    SetGlobal("WeakAurasOptionsSaved", {})
    SetGlobal("RAID_CLASS_COLORS", {
      WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
      MAGE = {r = 0.25, g = 0.78, b = 0.92},
      PRIEST = {r = 1, g = 1, b = 1},
    })

    local clamped = {}
    local created = {}
    local realCreateFrame = CreateFrame
    SetGlobal("CreateFrame", function(frameType, name, parent, template)
      local frame = realCreateFrame(frameType, name, parent, template)
      created[#created + 1] = frame
      frame.SetClampedToScreen = function(self, value) clamped[self] = value end
      return frame
    end)
    local timerCalls = {}
    local realAfter = C_Timer.After
    C_Timer.After = function(delay, callback)
      timerCalls[#timerCalls + 1] = delay
      return realAfter(delay, callback)
    end

    local paletteFile = {}
    local loaded, loadMessage = test.Loader.RunFile(optionsDirectory .. "ColorPalette.lua", "WeakAurasOptions", paletteFile)
    SetGlobal("CreateFrame", realCreateFrame)
    assert(loaded, tostring(loadMessage))
    Eq(#created, 0, "loading the palette creates no frame")

    local info = {hasOpacity = true}
    paletteFile.PrepareColorPalette(info)
    paletteFile.ShowColorPalette()

    local panel
    for _, frame in ipairs(created) do
      if State[frame].template == "BackdropTemplate" then
        Eq(panel, nil, "a single backdrop frame is created")
        panel = frame
      end
    end
    Check(panel ~= nil, "the palette creates a backdrop frame")
    local panelState = State[panel]
    Eq(panelState.objectType, "Frame", "panel is a Frame")
    Eq(panelState.parent, picker, "panel is a child of the color picker")
    Eq(panelState.name, nil, "panel has no name")
    Within(panelState.width, 232, 250, "panel width")
    Within(panelState.height, 262, 280, "panel height")
    Eq(#panelState.points, 1, "panel has one anchor")
    local anchor = panelState.points[1]
    Eq(anchor[1], "TOPLEFT", "panel anchor point")
    Eq(anchor[2], picker, "panel anchored to the picker")
    Eq(anchor[3], "TOPRIGHT", "panel anchored to the picker right side")
    Within(anchor[4], 4, 8, "panel horizontal gap")
    Eq(anchor[5], 0, "panel vertical offset")
    Eq(clamped[panel], true, "panel is clamped to the screen")
    Eq(panelState.backdrop.bgFile, WHITE, "panel background texture")
    Eq(panelState.backdrop.edgeFile, WHITE, "panel border texture")
    Eq(panelState.backdrop.edgeSize, 1, "panel border size")
    for index = 1, 3 do Within(panelState.backdropColor[index], 0.04, 0.08, "panel background channel " .. index) end
    Within(panelState.backdropColor[4], 0.95, 1, "panel background alpha")
    for index = 1, 3 do Within(panelState.backdropBorderColor[index], 0.25, 0.40, "panel border channel " .. index) end
    Eq(panelState.backdropBorderColor[4], 1, "panel border alpha")
    Eq(panelState.shown, true, "panel is shown")

    local headers = {}
    for _, region in ipairs(panelState.regions) do
      if State[region].objectType == "FontString" and State[region].text then
        headers[State[region].text] = State[region].points[1]
      end
    end
    for text, top in pairs({[L["Class colours"]] = -12, [L["Favourites"]] = -88, [L["Recent colours"]] = -162}) do
      Check(headers[text] ~= nil, "header " .. text)
      Eq(headers[text][1], "TOPLEFT", "header anchor " .. text)
      Eq(headers[text][4], 12, "header x " .. text)
      Eq(headers[text][5], top, "header y " .. text)
    end

    local classSwatches, favouriteSwatches, recentSwatches = {}, {}, {}
    local saveButton
    local editBoxes = {}
    for _, child in ipairs(panelState.children) do
      local childState = State[child]
      if childState.template == "UIPanelButtonTemplate" then
        saveButton = child
      elseif childState.template == "InputBoxTemplate" then
        editBoxes[#editBoxes + 1] = child
      elseif childState.objectType == "Button" then
        if child.hint == L["Right-click to remove"] then
          favouriteSwatches[child.index] = child
        elseif child.hint == L["Right-click to favourite"] then
          recentSwatches[child.index] = child
        else
          classSwatches[#classSwatches + 1] = child
        end
      end
    end
    Eq(#classSwatches, 3, "one swatch per class")
    Eq(#favouriteSwatches, 16, "sixteen favourite swatches")
    Eq(#recentSwatches, 8, "eight recent swatches")
    table.sort(classSwatches, function(left, right) return left.index < right.index end)
    local function CheckGrid(swatches, top, label)
      for index, swatch in ipairs(swatches) do
        local swatchState = State[swatch]
        Eq(swatchState.width, 22, label .. " width " .. index)
        Eq(swatchState.height, 22, label .. " height " .. index)
        local point = swatchState.points[1]
        Eq(point[1], "TOPLEFT", label .. " anchor " .. index)
        Eq(point[2], panel, label .. " relative frame " .. index)
        Eq(point[4], 12 + ((index - 1) % 8) * 26, label .. " x " .. index)
        Eq(point[5], top - math.floor((index - 1) / 8) * 26, label .. " y " .. index)
      end
    end
    CheckGrid(classSwatches, -32, "class swatch")
    CheckGrid(favouriteSwatches, -108, "favourite swatch")
    CheckGrid(recentSwatches, -182, "recent swatch")

    Check(saveButton ~= nil, "save button exists")
    local saveState = State[saveButton]
    Eq(saveState.width, 116, "save button width")
    Eq(saveState.height, 24, "save button height")
    Eq(saveState.text, L["Save favourite"], "save button text")
    Eq(saveState.points[1][1], "BOTTOMRIGHT", "save button anchor")
    Eq(saveState.points[1][2], panel, "save button relative frame")
    Eq(saveState.points[1][4], -10, "save button x")
    Eq(saveState.points[1][5], 12, "save button y")
    Eq(#editBoxes, 1, "hex box is built inside the panel")
    local hexBox = editBoxes[1]
    Eq(State[hexBox].text, "336699", "hex box shows the picker color")
    local alphaBox
    for _, child in ipairs(State[picker].children) do
      if State[child].template == "InputBoxTemplate" then alphaBox = child end
    end
    Check(alphaBox ~= nil, "alpha box is built on the picker")
    Eq(State[alphaBox].shown, true, "alpha box is shown for an opacity request")

    local function Click(swatch, button)
      State[swatch].scripts.OnClick(swatch, button)
    end
    local function Favourites() return WeakAurasOptionsSaved.colorPalette.favorites end
    local function Recent() return WeakAurasOptionsSaved.colorPalette.recent end

    Eq(State[favouriteSwatches[1]].shown, false, "empty favourite swatch is hidden")
    State[saveButton].scripts.OnClick(saveButton)
    Eq(#Favourites(), 1, "save adds a favourite")
    Near(Favourites()[1][1], 0.2, "saved favourite red")
    Near(Favourites()[1][3], 0.6, "saved favourite blue")
    Eq(State[favouriteSwatches[1]].shown, true, "saved favourite swatch is shown")
    Eq(State[favouriteSwatches[2]].shown, false, "next favourite swatch stays hidden")
    State[saveButton].scripts.OnClick(saveButton)
    Eq(#Favourites(), 1, "saving the same color again does not duplicate")
    pickerColor = {1, 0, 0}
    State[saveButton].scripts.OnClick(saveButton)
    Eq(#Favourites(), 2, "saving another color adds a favourite")
    Near(Favourites()[1][1], 1, "newest favourite is first")
    Eq(State[hexBox].text, "FF0000", "redraw refreshes the hex box")

    Click(classSwatches[1], "LeftButton")
    local classColor = classSwatches[1].color
    Near(pickerColor[1], classColor[1], "class swatch click sets picker red")
    Near(pickerColor[2], classColor[2], "class swatch click sets picker green")
    Click(favouriteSwatches[2], "LeftButton")
    Near(pickerColor[1], 0.2, "favourite click sets picker red")
    Eq(#Favourites(), 2, "left click keeps the favourites")
    Click(favouriteSwatches[1], "RightButton")
    Eq(#Favourites(), 1, "right click removes a favourite")
    Near(Favourites()[1][1], 0.2, "right click removes the clicked favourite")
    Eq(State[favouriteSwatches[2]].shown, false, "removed favourite swatch is hidden")

    pickerColor = {0.9, 0.1, 0.3}
    local afterCalls = #timerCalls
    picker:Show()
    picker:Hide()
    Eq(State[panel].shown, false, "hiding the picker hides the panel")
    Eq(State[alphaBox].shown, false, "hiding the picker hides the alpha box")
    Eq(#timerCalls - afterCalls, 1, "picker hide registers the recent color once")
    test.Environment.Advance(1)
    Eq(#Recent(), 1, "closed picker pushes the color to the recent list")
    Near(Recent()[1][1], 0.9, "recent color red")

    paletteFile.PrepareColorPalette({hasOpacity = false})
    paletteFile.ShowColorPalette()
    Eq(State[panel].shown, true, "showing again shows the panel")
    Eq(State[alphaBox].shown, false, "alpha box hidden without opacity")
    local backdropFrames = 0
    for _, frame in ipairs(created) do
      if State[frame].template == "BackdropTemplate" then backdropFrames = backdropFrames + 1 end
    end
    Eq(backdropFrames, 1, "the panel is built only once")
    Eq(State[recentSwatches[1]].shown, true, "recent swatch shown")
    Click(recentSwatches[1], "RightButton")
    Eq(#Favourites(), 2, "right click on a recent color favourites it")
    Near(Favourites()[1][1], 0.9, "favourited recent color is first")
    Near(Favourites()[1][2], 0.1, "favourited recent color green")
    Near(Favourites()[1][3], 0.3, "favourited recent color blue")
    while #Favourites() < 16 do table.insert(Favourites(), {0.5, 0.5, 0.5}) end
    Click(recentSwatches[1], "RightButton")
    Eq(#Favourites(), 16, "favourites keep their sixteen slots")
    Click(recentSwatches[1], "LeftButton")
    Near(pickerColor[3], 0.3, "recent click sets the picker color")

    picker:Show()
    picker:Hide()
    Eq(#timerCalls - afterCalls, 2, "second hide registers once more")

    C_Timer.After = realAfter
    for index = #savedGlobals, 1, -1 do _G[savedGlobals[index][1]] = savedGlobals[index][2] end
  end

  do
    local order = {}
    local function Record(name, ...)
      order[#order + 1] = {name, ...}
    end
    local function Reset() for index = #order, 1, -1 do order[index] = nil end end
    local function Names()
      local names = {}
      for _, entry in ipairs(order) do names[#names + 1] = entry[1] end
      return table.concat(names, ",")
    end
    local function CountOf(name)
      local total = 0
      for _, entry in ipairs(order) do if entry[1] == name then total = total + 1 end end
      return total
    end

    local viewerPrivate = { CreateAuraSpellOptions = function(options, _, _, size, _, _, prefix)
      for index = 1, size do
        options[prefix .. "icon" .. index] = { type = "execute" }
        options[prefix .. index] = { type = "input" }
      end
    end }
    local loaded, loadMessage = test.Loader.RunFile(optionsDirectory .. "CooldownViewerOptions.lua", "WeakAurasOptions", viewerPrivate)
    viewerPrivate.Private = private
    assert(loaded, tostring(loadMessage))

    Stub(private, "CDMCatalog", function() return {} end)
    Stub(private, "CDMCategoryName", function() return "Category" end)
    Stub(private, "CDMRequestItemData", function() end)
    Stub(WeakAuras, "Add", function(...) Record("Add", ...) end)
    Stub(WeakAuras, "ClearAndUpdateOptions", function(...) Record("ClearAndUpdateOptions", ...) end)
    Stub(WeakAuras, "UpdateThumbnail", function(...) Record("UpdateThumbnail", ...) end)
    Stub(private, "ScanForLoads", function(...) Record("ScanForLoads", ...) end)
    Stub(private, "UpdateFakeStatesFor", function(...) Record("UpdateFakeStatesFor", ...) end)

    local trigger = { type = "cdm", event = "Blizzard CDM Buff" }
    local data = { id = "Viewer Aura", triggers = { { trigger = trigger } } }
    local options = {}
    viewerPrivate.AddCooldownViewerOptions(options, data, 1)
    Check(options.cdmPicker_requireTarget ~= nil, "viewer options expose the require target toggle")
    Reset()

    options.cdmPicker_requireTarget.set(nil, true)
    Eq(trigger.cdmRequireTarget, true, "viewer setter stores the value before committing")
    Eq(#order, 5, "viewer commit makes five calls")
    for _, name in ipairs({"Add", "ScanForLoads", "UpdateThumbnail", "UpdateFakeStatesFor", "ClearAndUpdateOptions"}) do
      Eq(CountOf(name), 1, "viewer commit calls " .. name .. " once")
    end
    Eq(order[1][1], "Add", "viewer commit adds the aura first")
    Eq(order[5][1], "ClearAndUpdateOptions", "viewer commit refreshes the options last")
    local byName = {}
    for _, entry in ipairs(order) do byName[entry[1]] = entry end
    Eq(byName.Add[2], data, "viewer commit adds the same data")
    Eq(byName.Add[3], nil, "viewer commit adds without extra argument")
    Eq(type(byName.ScanForLoads[2]), "table", "viewer commit scans a table")
    Eq(byName.ScanForLoads[2]["Viewer Aura"], true, "viewer commit scans the aura id")
    Eq(next(byName.ScanForLoads[2], "Viewer Aura"), nil, "viewer commit scans only the aura id")
    Eq(byName.UpdateThumbnail[2], data, "viewer commit updates the thumbnail of the data")
    Eq(byName.UpdateFakeStatesFor[2], "Viewer Aura", "viewer commit updates the fake states by id")
    Eq(byName.ClearAndUpdateOptions[2], "Viewer Aura", "viewer commit refreshes the options by id")

    Reset()
    options.cdmPicker_buffShow.set(nil, "inactive")
    Eq(trigger.cdmBuffShow, "inactive", "viewer second setter stores the value")
    Eq(#order, 5, "viewer second commit makes five calls")
    Eq(order[1][1], "Add", "viewer second commit adds first")
    Eq(order[5][1], "ClearAndUpdateOptions", "viewer second commit refreshes last")

    Reset()
    options.cdmPicker_refresh.func()
    Eq(Names(), "ClearAndUpdateOptions", "viewer refresh button only refreshes the options")
    Unstub()
  end

  do
    local order = {}
    local function Names() return table.concat(order, ",") end
    local presence = {}
    local seenOptions = {}
    local buildOptions
    local realRegister = WeakAuras.RegisterTriggerSystemOptions
    WeakAuras.RegisterTriggerSystemOptions = function(types, builder)
      buildOptions = builder
      presence.types = types
    end
    local triggerPrivate = {
      commonOptions = { AddCommonTriggerOptions = function(options, data, triggernum, flag)
        order[#order + 1] = "common"
        seenOptions.common = {options, data, triggernum, flag}
        presence.commonDebuffType = options.debuffType ~= nil
        presence.commonUnit = options.unit ~= nil
        presence.commonSpellHeader = options.spellSelectionHeader ~= nil
        options.type = {type = "select"}
      end },
      AuraEditor = { AddOptions = function(options, data, triggernum)
        order[#order + 1] = "editor"
        seenOptions.editor = {options, data, triggernum}
        presence.editorDebuffType = options.debuffType ~= nil
        presence.editorUnit = options.unit ~= nil
        presence.editorSpellHeader = options.spellSelectionHeader ~= nil
      end },
      AddTriggerMetaFunctions = function(options, data, triggernum)
        order[#order + 1] = "meta"
        seenOptions.meta = {options, data, triggernum}
      end,
      SaveAuraTrigger = function() end,
      QueueOptionsRefresh = function() end,
      CreateAuraSpellOptions = function(options, _, _, size, _, _, prefix)
        for index = 1, size do
          options[prefix .. "icon" .. index] = { type = "execute" }
          options[prefix .. index] = { type = "input" }
        end
      end,
    }
    local loaded, loadMessage = test.Loader.RunFile(optionsDirectory .. "SecretAuraTriggerOptions.lua", "WeakAurasOptions", triggerPrivate)
    triggerPrivate.Private = private
    WeakAuras.RegisterTriggerSystemOptions = realRegister
    assert(loaded, tostring(loadMessage))
    assert(buildOptions, "secretAura options not registered")
    Eq(presence.types[1], "secretAura", "secretAura builder registered for secretAura")

    for _, triggernum in ipairs({1, 2}) do
      for index = #order, 1, -1 do order[index] = nil end
      seenOptions = {}
      local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL" }
      local data = { id = "Trigger", triggers = {} }
      data.triggers[triggernum] = { trigger = trigger }
      local result = buildOptions(data, triggernum)
      local key = "trigger." .. triggernum .. ".secretAura"
      Check(type(result[key]) == "table", "result has the trigger key " .. key)
      local count = 0
      for _ in pairs(result) do count = count + 1 end
      Eq(count, 1, "result has a single key " .. triggernum)
      Eq(#order, 3, "three steps close the builder " .. triggernum)
      Eq(order[3], "meta", "meta functions come last " .. triggernum)
      Check(Names() == "common,editor,meta" or Names() == "editor,common,meta", "common and editor before meta " .. triggernum)
      Check(presence.commonDebuffType and presence.editorDebuffType, "aura type option exists before closing steps")
      Check(presence.commonUnit and presence.editorUnit, "unit options exist before closing steps")
      Check(presence.commonSpellHeader and presence.editorSpellHeader, "spell lists exist before closing steps")
      Eq(seenOptions.common[1], result[key], "common receives the returned options table")
      Eq(seenOptions.editor[1], result[key], "editor receives the returned options table")
      Eq(seenOptions.meta[1], result[key], "meta receives the returned options table")
      Eq(seenOptions.common[2], data, "common receives the data")
      Eq(seenOptions.editor[2], data, "editor receives the data")
      Eq(seenOptions.meta[2], data, "meta receives the data")
      Eq(seenOptions.common[3], triggernum, "common receives the trigger number")
      Eq(seenOptions.editor[3], triggernum, "editor receives the trigger number")
      Eq(seenOptions.meta[3], triggernum, "meta receives the trigger number")
      Eq(seenOptions.common[4], true, "common is asked for the secret flag")
      Check(result[key].type ~= nil, "options created by common survive")
    end
  end
end

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret = test.Secret
  local assertionCount = 0

  local function Check(condition, label)
    assertionCount = assertionCount + 1
    assert(condition, label)
  end
  local function Eq(actual, expected, label)
    Check(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Same(actual, expected, label)
    Check(rawequal(actual, expected), ("%s: not the same object"):format(label))
  end
  local function Near(actual, expected, label)
    Check(type(actual) == "number" and math.abs(actual - expected) < 1e-6,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
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

  local scanned = {}
  local function InstallScanRecorder()
    Stub(private, "ScanEvents", function(event, ...)
      scanned[#scanned + 1] = {event = event, count = select("#", ...)}
    end)
  end
  InstallScanRecorder()
  local function Drain()
    test.Environment.Advance(0.1)
    local refreshes, extraArguments = 0, 0
    for _, entry in ipairs(scanned) do
      if entry.event == "WA_CDM_REFRESH" then
        refreshes = refreshes + 1
        extraArguments = extraArguments + entry.count
      end
    end
    for index = #scanned, 1, -1 do scanned[index] = nil end
    return refreshes, extraArguments
  end
  Drain()

  local viewerNames = {"EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer"}
  local function ClearViewers()
    for _, name in ipairs(viewerNames) do _G[name] = nil end
  end
  ClearViewers()

  local function NewScripts(owner)
    owner.scripts = {}
    function owner:HookScript(name, handler)
      owner.scripts[name] = owner.scripts[name] or {}
      table.insert(owner.scripts[name], handler)
    end
    function owner:RunScript(name, ...)
      for _, handler in ipairs(owner.scripts[name] or {}) do handler(self, ...) end
    end
  end
  local function NewWidget(times)
    local widget = {}
    NewScripts(widget)
    for _, name in ipairs({"SetCooldownFromDurationObject", "SetCooldown", "Clear", "Pause", "Resume"}) do
      widget[name] = function() end
    end
    if times then
      widget.GetCooldownTimes = function()
        if times.fail then error("times failed") end
        return times[1], times[2]
      end
    end
    return widget
  end
  local frameMethods = {
    "ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet", "OnCooldownIDSet",
    "OnCooldownIDCleared", "ResetCooldownData", "SetAuraInstanceInfo", "OnUnitAuraRemovedEvent",
    "OnUnitAuraUpdatedEvent", "OnNewTarget", "OnActiveStateChanged", "RefreshIconColor", "RefreshData",
    "RefreshCooldownOnly",
  }
  local function NewFrame(cooldownID, spellID, kind, times)
    local frame = {cooldownID = cooldownID, spellID = spellID, Cooldown = NewWidget(times)}
    NewScripts(frame)
    function frame:GetSpellID() return self.spellID end
    for _, name in ipairs(frameMethods) do frame[name] = function() end end
    if kind == "spell" then frame.RefreshSpellCooldownInfo = function() end end
    return frame
  end
  local function NewPool(frames)
    return {EnumerateActive = function()
      local index = 0
      return function()
        index = index + 1
        return frames[index]
      end
    end}
  end
  local function NewViewer(frames)
    local viewer = {itemFramePool = NewPool(frames or {})}
    for _, name in ipairs({"OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange",
      "RefreshData", "OnAcquireItemFrame"}) do
      viewer[name] = function() end
    end
    return viewer
  end
  local function Watch(...)
    ClearViewers()
    _G.EssentialCooldownViewer = NewViewer({...})
    private.CDMFrames()
    Drain()
  end

  local exportNames = {
    "QueueCDMRefresh", "CDMRequestItemData", "CDMResetIdentities", "CDMCategoryName", "CDMIsBuff", "CDMFrames",
    "CDMGetNativeCooldown", "CDMCatalog", "CDMIdentity", "CDMApplyItem", "CDMApplyAura", "ParseCDMText",
    "IsCDMBuffText", "CopyCDMCountdownText", "GetCooldownManagerSpells", "GetCooldownManagerAuras",
    "GetCooldownManagerAuraSpellIDs",
  }
  for _, name in ipairs(exportNames) do
    Eq(type(private[name]), "function", "export " .. name)
  end

  local categories = {
    Essential = 0, Utility = 1, TrackedBuff = 2, TrackedBar = 3, GroupBuff = 4, SpecAgnosticTracked = 5,
    SpecAgnosticEssential = 6, EquipSlotTracked = 7, EquipSlotEssential = 8, Hidden = -1, Extra = 9,
  }
  local function InstallEnum()
    Stub(_G, "Enum", setmetatable({CooldownViewerCategory = categories}, {__index = Enum}))
  end
  InstallEnum()

  local labels = {
    Essential = "Essential", Utility = "Utility", TrackedBuff = "Tracked Buffs", TrackedBar = "Tracked Bars",
    GroupBuff = "Group Buffs", SpecAgnosticTracked = "Shared Buffs", SpecAgnosticEssential = "Shared Cooldowns",
    EquipSlotTracked = "Item Buffs", EquipSlotEssential = "Item Cooldowns", Hidden = "Hidden", Extra = "Extra",
  }
  for name, label in pairs(labels) do
    Eq(private.CDMCategoryName(categories[name]), label, "category label " .. name)
  end
  Eq(private.CDMCategoryName(99), "Other", "unknown category")
  Eq(private.CDMCategoryName(nil), "Other", "nil category")
  Eq(private.CDMCategoryName("Essential"), "Other", "string category")

  local buffNames = {TrackedBuff = true, TrackedBar = true, GroupBuff = true, SpecAgnosticTracked = true, EquipSlotTracked = true}
  for name, value in pairs(categories) do
    Eq(private.CDMIsBuff(value), buffNames[name] == true, "IsBuff " .. name)
  end
  Eq(private.CDMIsBuff(99), false, "IsBuff unknown")

  Eq(Drain(), 0, "no refresh at rest")
  private.QueueCDMRefresh()
  Eq(#scanned, 0, "refresh is never synchronous")
  Eq(Drain(), 1, "one refresh")
  private.QueueCDMRefresh()
  private.QueueCDMRefresh()
  private.QueueCDMRefresh("ignored", 1, 2)
  local refreshes, extraArguments = Drain()
  Eq(refreshes, 1, "calls coalesce")
  Eq(extraArguments, 0, "refresh event carries no argument")
  private.QueueCDMRefresh()
  Drain()
  private.QueueCDMRefresh()
  Eq(Drain(), 1, "queue works again after emission")
  Stub(private, "ScanEvents", function(event)
    scanned[#scanned + 1] = {event = event, count = 0}
    if event == "WA_CDM_REFRESH" and not private.reentered then
      private.reentered = true
      private.QueueCDMRefresh()
    end
  end)
  private.QueueCDMRefresh()
  Eq(Drain(), 2, "refresh queued during emission is emitted separately")
  Eq(Drain(), 0, "and nothing more")
  private.reentered = nil
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  Stub(private, "ScanEvents", nil)
  private.QueueCDMRefresh()
  Check(pcall(test.Environment.Advance, 0.1), "refresh without ScanEvents does not fail")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  private.QueueCDMRefresh()
  Eq(Drain(), 1, "queue still works after missing ScanEvents")

  local requested = {}
  local cached = {}
  Stub(C_Item, "IsItemDataCachedByID", function(itemID) return cached[itemID] == true end)
  Stub(C_Item, "RequestLoadItemDataByID", function(itemID) requested[#requested + 1] = itemID end)
  private.CDMRequestItemData(nil)
  private.CDMRequestItemData(false)
  Eq(#requested, 0, "no item no request")
  private.CDMRequestItemData(7001)
  private.CDMRequestItemData(7001)
  Eq(#requested, 1, "one request per item")
  Eq(requested[1], 7001, "requested item")
  cached[7002] = true
  private.CDMRequestItemData(7002)
  Eq(#requested, 1, "cached item not requested")
  cached[7002] = false
  private.CDMRequestItemData(7002)
  Eq(#requested, 2, "uncached item requested")
  Eq(requested[2], 7002, "second item")
  Stub(C_Item, "RequestLoadItemDataByID", nil)
  private.CDMRequestItemData(7003)
  Stub(C_Item, "RequestLoadItemDataByID", function(itemID) requested[#requested + 1] = itemID end)
  private.CDMRequestItemData(7003)
  Eq(requested[#requested], 7003, "incomplete API did not mark the item requested")
  Stub(C_Item, "IsItemDataCachedByID", nil)
  local before = #requested
  private.CDMRequestItemData(7004)
  Eq(#requested, before, "missing cache API makes no request")
  Unstub()
  InstallScanRecorder()
  InstallEnum()

  local essentialFrame = NewFrame(11, 111, "spell")
  local utilityFrame = NewFrame(12, 112, "spell")
  local buffFrame = NewFrame(13, 113)
  local barFrame = NewFrame(14, 114)
  _G.EssentialCooldownViewer = NewViewer({essentialFrame})
  _G.UtilityCooldownViewer = NewViewer({utilityFrame})
  _G.BuffIconCooldownViewer = NewViewer({buffFrame})
  _G.BuffBarCooldownViewer = NewViewer({barFrame})
  local frames = private.CDMFrames()
  Same(frames[11], essentialFrame, "essential frame by cooldown id")
  Same(frames[12], utilityFrame, "utility frame by cooldown id")
  Same(frames[13], buffFrame, "buff icon frame by cooldown id")
  Same(frames[14], barFrame, "buff bar frame by cooldown id")
  local again = private.CDMFrames()
  Check(not rawequal(again, frames), "fresh table outside a batch")
  Drain()

  local viewers = {_G.EssentialCooldownViewer, _G.UtilityCooldownViewer, _G.BuffIconCooldownViewer, _G.BuffBarCooldownViewer}
  for index, viewer in ipairs(viewers) do
    for _, method in ipairs({"OnUnitAura", "OnPlayerTargetChanged", "RefreshActiveFramesForTargetChange"}) do
      viewer[method](viewer)
      Eq(Drain(), 1, "viewer " .. index .. " " .. method .. " refreshes")
    end
  end
  viewers[1]:RefreshData()
  Eq(Drain(), 0, "essential RefreshData does not refresh")
  viewers[2]:RefreshData()
  Eq(Drain(), 0, "utility RefreshData does not refresh")
  viewers[3]:RefreshData()
  Eq(Drain(), 1, "buff icon RefreshData refreshes")
  viewers[4]:RefreshData()
  Eq(Drain(), 1, "buff bar RefreshData refreshes")

  local acquired = NewFrame(15, 115)
  viewers[1]:OnAcquireItemFrame(acquired)
  viewers[2]:OnAcquireItemFrame(acquired)
  acquired.OnNewTarget(acquired)
  Eq(Drain(), 0, "frames acquired by cooldown viewers are not observed")
  viewers[3]:OnAcquireItemFrame(nil)
  viewers[3]:OnAcquireItemFrame(acquired)
  acquired.OnNewTarget(acquired)
  Eq(Drain(), 1, "frames acquired by buff viewers are observed")
  acquired.OnNewTarget(acquired)
  Eq(Drain(), 1, "frame hooks are installed once")
  local acquiredBar = NewFrame(16, 116)
  viewers[4]:OnAcquireItemFrame(acquiredBar)
  acquiredBar.OnNewTarget(acquiredBar)
  Eq(Drain(), 1, "frames acquired by the bar viewer are observed")

  private.cdmScanBatch = {}
  local batchFrames = private.CDMFrames()
  Same(batchFrames, private.cdmScanBatch.frames, "batch remembers the frames")
  Same(private.CDMFrames(), batchFrames, "batch frames are reused")
  _G.EssentialCooldownViewer.itemFramePool = NewPool({NewFrame(21, 211)})
  Same(private.CDMFrames(), batchFrames, "batch ignores later pool changes")
  Eq(batchFrames[21], nil, "batch is a snapshot")
  private.cdmScanBatch = nil
  Check(private.CDMFrames()[21] ~= nil, "outside the batch the pool is read again")

  local secretID = NewFrame(Secret.Wrap(31), 311)
  local textID = NewFrame("32", 312)
  local noID = NewFrame(nil, 313)
  local lastWins = {NewFrame(33, 331), NewFrame(33, 332)}
  _G.EssentialCooldownViewer = NewViewer({secretID, textID, noID, lastWins[1], lastWins[2]})
  _G.UtilityCooldownViewer = {}
  _G.BuffIconCooldownViewer = {itemFramePool = {}}
  _G.BuffBarCooldownViewer = nil
  frames = private.CDMFrames()
  Eq(frames[33], lastWins[2], "last frame with the same id wins")
  local count = 0
  for _ in pairs(frames) do count = count + 1 end
  Eq(count, 1, "unreadable cooldown ids are ignored")
  secretID.OnNewTarget(secretID)
  textID.OnNewTarget(textID)
  noID.OnNewTarget(noID)
  Eq(Drain(), 0, "ignored frames are not observed")
  lastWins[1].OnNewTarget(lastWins[1])
  Eq(Drain(), 1, "every readable frame is observed")

  local order = {}
  local function OrderedViewer(name, frame)
    local viewer = NewViewer({frame})
    viewer.itemFramePool.EnumerateActive = function()
      order[#order + 1] = name
      return function() return nil end
    end
    return viewer
  end
  _G.EssentialCooldownViewer = OrderedViewer("essential", essentialFrame)
  _G.UtilityCooldownViewer = OrderedViewer("utility", utilityFrame)
  _G.BuffIconCooldownViewer = OrderedViewer("icon", buffFrame)
  _G.BuffBarCooldownViewer = OrderedViewer("bar", barFrame)
  private.CDMFrames()
  Eq(table.concat(order, ","), "essential,utility,icon,bar", "viewer order")
  ClearViewers()
  Eq(next(private.CDMFrames()), nil, "no viewer no frame")

  Stub(_G, "hooksecurefunc", nil)
  _G.EssentialCooldownViewer = NewViewer({NewFrame(41, 411)})
  Check(pcall(private.CDMFrames), "frames without hooksecurefunc")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  ClearViewers()
  Drain()

  local function NewObserved(cooldownID, spellID, kind, times, setup)
    local frame = NewFrame(cooldownID, spellID, kind, times)
    if setup then setup(frame) end
    Watch(frame)
    return frame
  end
  local function Native(frame, spellID)
    return private.CDMGetNativeCooldown(frame, spellID)
  end
  local function Revision(frame, spellID)
    local native = Native(frame, spellID)
    return native and native.revision
  end

  Eq(Native(nil, 1), nil, "native of nil frame")
  Eq(Native(NewFrame(51, 511), 511), nil, "native of unobserved frame")

  local now = GetTime()
  local spellFrame = NewObserved(61, 611, "spell", {(now - 1) * 1000, 4000}, function(frame)
    frame.cooldownModRate = 1
    frame.isOnActualCooldown = true
    frame.wasSetFromCharges = false
    frame.cooldownChargesCount = 2
    frame.isOnGCD = true
  end)
  local native = Native(spellFrame, 611)
  Eq(type(native), "table", "native cooldown for the observed frame")
  Eq(native.revision, 0, "initial revision")
  Eq(native.onCooldown, true, "onCooldown read")
  Eq(native.recharging, false, "recharging read")
  Eq(native.charges, 2, "charges read")
  Eq(native.onGCD, false, "GCD forced off while on cooldown")
  Eq(native.paused, false, "not paused")
  Eq(native.inRange, nil, "range unknown")
  Check(private.IsDurationObject(native.duration), "duration built from the widget times")
  Near(native.duration:GetRemainingDuration(), now + 3 - GetTime(), "remaining from widget times")
  Same(Native(spellFrame, 611).duration, native.duration, "converted duration is remembered")
  Eq(Native(spellFrame, 999), nil, "other spell id")
  spellFrame.spellID = 999
  Eq(Native(spellFrame, 611), nil, "frame reports another spell")
  spellFrame.spellID = 611
  spellFrame.cooldownID = 62
  Eq(Native(spellFrame, 611), nil, "cooldown id changed")
  spellFrame.cooldownID = Secret.Wrap(61)
  Eq(Native(spellFrame, 611), nil, "secret cooldown id")
  spellFrame.cooldownID = 61

  spellFrame.spellOutOfRange = true
  Eq(Native(spellFrame, 611).inRange, false, "out of range")
  spellFrame.spellOutOfRange = false
  Eq(Native(spellFrame, 611).inRange, true, "in range")
  spellFrame.spellOutOfRange = Secret.Wrap(true)
  Eq(Native(spellFrame, 611).inRange, nil, "secret range")
  spellFrame.spellOutOfRange = "yes"
  Eq(Native(spellFrame, 611).inRange, nil, "non boolean range")
  spellFrame.spellOutOfRange = nil
  Check(Native(spellFrame, 611) ~= Native(spellFrame, 611), "native table is new each call")

  local widget = spellFrame.Cooldown
  local base = Revision(spellFrame, 611)
  local durationObject = test.Units.NewDuration()
  durationObject:SetTimeFromStart(GetTime(), 10)
  widget:SetCooldownFromDurationObject(durationObject)
  Eq(Revision(spellFrame, 611), base + 1, "duration object bumps the revision")
  Same(Native(spellFrame, 611).duration, durationObject, "native keeps the duration object")
  Eq(Drain(), 1, "duration object refreshes")
  local rawStart = GetTime() - 2
  widget:SetCooldown(rawStart, 6, 1)
  Eq(Revision(spellFrame, 611), base + 2, "SetCooldown bumps the revision")
  native = Native(spellFrame, 611)
  Check(private.IsDurationObject(native.duration), "raw times are converted")
  Near(native.duration:GetRemainingDuration(), rawStart + 6 - GetTime(), "converted remaining")
  Same(Native(spellFrame, 611).duration, native.duration, "conversion is remembered")
  Eq(Drain(), 1, "SetCooldown refreshes")
  widget:Clear()
  Eq(Revision(spellFrame, 611), base + 3, "Clear bumps the revision")
  Eq(Native(spellFrame, 611).duration, nil, "Clear drops the duration")
  Eq(Drain(), 1, "Clear refreshes")
  for index, method in ipairs({"OnCooldownIDSet", "OnCooldownIDCleared", "ResetCooldownData"}) do
    spellFrame[method](spellFrame)
    Eq(Revision(spellFrame, 611), base + 3 + index, method .. " bumps the revision")
    Eq(Drain(), 1, method .. " refreshes")
  end
  base = Revision(spellFrame, 611)
  for _, method in ipairs({"ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet"}) do
    spellFrame[method](spellFrame)
    Eq(Revision(spellFrame, 611), base, method .. " on a spell frame keeps the revision")
    Eq(Drain(), 1, method .. " on a spell frame refreshes")
  end
  for _, method in ipairs({"SetAuraInstanceInfo", "OnUnitAuraRemovedEvent", "OnUnitAuraUpdatedEvent", "OnNewTarget",
    "OnActiveStateChanged", "RefreshIconColor"}) do
    spellFrame[method](spellFrame)
    Eq(Revision(spellFrame, 611), base, method .. " keeps the revision")
    Eq(Drain(), 1, method .. " refreshes")
  end
  spellFrame:RunScript("OnShow")
  Eq(Drain(), 1, "OnShow refreshes")
  spellFrame:RunScript("OnHide")
  Eq(Drain(), 1, "OnHide refreshes")
  Eq(Revision(spellFrame, 611), base, "show and hide keep the revision")

  spellFrame.isOnActualCooldown = false
  spellFrame.wasSetFromCharges = true
  spellFrame.cooldownChargesCount = 1
  spellFrame.isOnGCD = true
  spellFrame:RefreshData()
  native = Native(spellFrame, 611)
  Eq(native.onCooldown, false, "RefreshData rereads onCooldown")
  Eq(native.recharging, true, "RefreshData rereads recharging")
  Eq(native.charges, 1, "RefreshData rereads charges")
  Eq(native.onGCD, false, "GCD forced off while recharging")
  Eq(native.revision, base, "RefreshData keeps the revision")
  Eq(Drain(), 1, "RefreshData refreshes")
  spellFrame.wasSetFromCharges = false
  spellFrame.isOnGCD = true
  spellFrame:RefreshCooldownOnly()
  native = Native(spellFrame, 611)
  Eq(native.onGCD, true, "GCD kept when idle")
  Eq(native.recharging, false, "RefreshCooldownOnly rereads recharging")
  Eq(native.revision, base, "RefreshCooldownOnly keeps the revision")
  Eq(Drain(), 1, "RefreshCooldownOnly refreshes")
  spellFrame.isOnGCD = false
  spellFrame.cooldownUseAuraDisplayTime = true
  spellFrame.isOnGCD = true
  spellFrame:RefreshCooldownOnly()
  Eq(Native(spellFrame, 611).onGCD, false, "GCD forced off with aura display time")
  spellFrame.cooldownUseAuraDisplayTime = nil
  spellFrame.isOnActualCooldown = Secret.Wrap(true)
  spellFrame.isOnGCD = Secret.Wrap(true)
  spellFrame.cooldownChargesCount = Secret.Wrap(3)
  spellFrame:RefreshCooldownOnly()
  native = Native(spellFrame, 611)
  Eq(native.onCooldown, nil, "secret onCooldown is unknown")
  Eq(native.onGCD, nil, "secret GCD is unknown")
  Eq(native.charges, nil, "secret charges are unknown")
  spellFrame.isOnActualCooldown = "yes"
  spellFrame.isOnGCD = nil
  spellFrame.cooldownChargesCount = "2"
  spellFrame:RefreshCooldownOnly()
  native = Native(spellFrame, 611)
  Eq(native.onCooldown, nil, "non boolean onCooldown is unknown")
  Eq(native.charges, nil, "non number charges are unknown")
  Drain()

  widget:Pause()
  Eq(Native(spellFrame, 611).paused, true, "Pause marks the record")
  Eq(Drain(), 1, "Pause refreshes")
  widget:Resume()
  Eq(Native(spellFrame, 611).paused, false, "Resume clears the pause")
  Eq(Drain(), 1, "Resume refreshes")
  spellFrame.cooldownPaused = true
  spellFrame:RefreshCooldownOnly()
  Eq(Native(spellFrame, 611).paused, true, "frame pause is read")
  spellFrame.cooldownPaused = 1
  spellFrame:RefreshCooldownOnly()
  Eq(Native(spellFrame, 611).paused, false, "only true counts as paused")
  spellFrame.cooldownPaused = Secret.Wrap(true)
  spellFrame:RefreshCooldownOnly()
  Eq(Native(spellFrame, 611).paused, false, "secret pause is not paused")
  spellFrame.cooldownPaused = nil
  Drain()

  local auraFrame = NewObserved(71, 711)
  local auraBase = Revision(auraFrame, 711)
  Eq(auraBase, 0, "aura frame initial revision")
  for index, method in ipairs({"ClearAuraInstanceInfo", "OnAuraInstanceInfoCleared", "OnAuraInstanceInfoSet"}) do
    auraFrame[method](auraFrame)
    Eq(Revision(auraFrame, 711), auraBase + index, method .. " on an aura frame bumps the revision")
    Eq(Drain(), 1, method .. " on an aura frame refreshes")
  end

  local function TimesLeft(frame, spellID)
    local native = Native(frame, spellID)
    return native and native.duration and native.duration:GetRemainingDuration()
  end
  local at = GetTime()
  local timed = NewObserved(81, 811, nil, {(at - 1) * 1000, 5000}, function(frame) frame.cooldownModRate = 2 end)
  Near(TimesLeft(timed, 811), at - 1 + 5 - GetTime(), "widget times remaining")
  Eq(Native(timed, 811).duration:GetModRate(), 2, "widget times honor the frame mod rate")
  Check(Native(timed, 811).duration:GetTotalDuration() ~= nil, "widget times total")
  Near(Native(timed, 811).duration:GetTotalDuration(), 5, "widget times total value")

  at = GetTime()
  local failing = NewObserved(82, 821, "spell", {fail = true}, function(frame)
    frame.cooldownStartTime, frame.cooldownDuration, frame.cooldownModRate = at - 1, 6, 1
  end)
  Near(TimesLeft(failing, 821), at - 1 + 6 - GetTime(), "failed widget times fall back to the frame fields")
  local failingAura = NewObserved(83, 831, nil, {fail = true}, function(frame)
    frame.cooldownStartTime, frame.cooldownDuration = at - 1, 6
  end)
  Eq(Native(failingAura, 831).duration, nil, "failed widget times without spell info give no duration")
  local secretTimes = NewObserved(84, 841, "spell", {Secret.Wrap(1000), 2000}, function(frame)
    frame.cooldownStartTime, frame.cooldownDuration, frame.cooldownModRate = at - 1, 6, 1
  end)
  Near(TimesLeft(secretTimes, 841), at - 1 + 6 - GetTime(), "secret widget times fall back to the frame fields")
  local plainWidget = NewObserved(85, 851, "spell", nil, function(frame)
    frame.cooldownStartTime, frame.cooldownDuration, frame.cooldownModRate = at - 1, 6, 1
  end)
  Near(TimesLeft(plainWidget, 851), at - 1 + 6 - GetTime(), "widget without times falls back to the frame fields")
  local plainAura = NewObserved(86, 861)
  Eq(Native(plainAura, 861).duration, nil, "widget without times and without spell info gives no duration")

  local lowerCase = NewFrame(87, 871, nil, {(at - 1) * 1000, 3000})
  lowerCase.cooldown, lowerCase.Cooldown = lowerCase.Cooldown, nil
  Watch(lowerCase)
  Near(TimesLeft(lowerCase, 871), at - 1 + 3 - GetTime(), "lower case cooldown widget is observed")
  lowerCase.cooldown:Clear()
  Eq(Revision(lowerCase, 871), 1, "lower case cooldown widget hooks")

  local widgetless = NewFrame(88, 881)
  widgetless.Cooldown = nil
  Watch(widgetless)
  Eq(Native(widgetless, 881), nil, "frame without widget has no record before a hook")
  widgetless:RefreshData()
  Eq(type(Native(widgetless, 881)), "table", "frame without widget has a record after a hook")
  Eq(Native(widgetless, 881).duration, nil, "frame without widget has no duration")
  widgetless:OnCooldownIDSet()
  Eq(Revision(widgetless, 881), 1, "frame without widget bumps the revision")

  local realCreate = C_DurationUtil.CreateDuration
  local failures = 1
  C_DurationUtil.CreateDuration = function()
    local built = realCreate()
    return setmetatable({}, {__index = function(_, key)
      if key ~= "SetTimeFromStart" then return built[key] end
      return function(_, ...)
        if failures > 0 then
          failures = failures - 1
          error("conversion failed")
        end
        return built:SetTimeFromStart(...)
      end
    end})
  end
  local retry = NewObserved(91, 911)
  retry.Cooldown:SetCooldown(GetTime() - 1, 5, 1)
  Eq(Native(retry, 911).duration, nil, "failed conversion gives no duration")
  Check(Native(retry, 911).duration ~= nil, "failed conversion is retried")
  C_DurationUtil.CreateDuration = realCreate
  Stub(C_DurationUtil, "CreateDuration", nil)
  local noFactory = NewObserved(92, 921)
  noFactory.Cooldown:SetCooldown(GetTime() - 1, 5, 1)
  Eq(Native(noFactory, 921).duration, nil, "no duration factory gives no duration")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  Check(Native(noFactory, 921).duration ~= nil, "factory back gives a duration")
  local secretRaw = NewObserved(93, 931)
  secretRaw.Cooldown:SetCooldown(Secret.Wrap(GetTime() - 1), Secret.Wrap(5), 1)
  Check(private.IsDurationObject(Native(secretRaw, 931).duration), "secret raw times are converted")
  Eq(Native(secretRaw, 931).duration:HasSecretValues(), true, "secret raw conversion keeps secrets")

  local function Completion(setup, act)
    local frame = NewObserved(1000 + assertionCount, 5000 + assertionCount, "spell", nil, function(target)
      target.isOnActualCooldown = true
      target.isOnGCD = false
      target.cooldownUseAuraDisplayTime = false
      if setup then setup(target) end
    end)
    local spellID = frame.spellID
    act(frame)
    frame.Cooldown:RunScript("OnCooldownDone")
    Eq(Drain(), 1, "OnCooldownDone refreshes")
    frame.isOnActualCooldown = true
    frame:RefreshCooldownOnly()
    local native = Native(frame, spellID)
    return native.onCooldown == false and native.recharging == false, frame, spellID
  end
  local current = GetTime()
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 10, 5, 1) end)), true, "expired raw times complete")
  Eq((Completion(nil, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5)
  end)), true, "expired raw times without mod rate complete")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 1, 5, 1) end)), false, "running raw times do not complete")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 6, 5, 2) end)), true, "mod rate shortens raw times")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 1, 5, 2) end)), false, "mod rate raw times still running")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 8, 5, 0.5) end)), false, "slow mod rate raw times still running")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 11, 5, 0.5) end)), true, "slow mod rate raw times done")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 10, 5, 0) end)), false, "zero mod rate never completes")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 10, 5, Secret.Wrap(1)) end)), false, "secret mod rate never completes")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(Secret.Wrap(current - 10), 5, 1) end)), false, "secret start never completes")
  Eq((Completion(nil, function(frame) frame.Cooldown:SetCooldown(current - 10, Secret.Wrap(5), 1) end)), false, "secret length never completes")
  Eq((Completion(nil, function(frame) frame.Cooldown:Clear() end)), false, "cleared cooldown never completes")
  Eq((Completion(nil, function(frame)
    local expired = test.Units.NewDuration()
    expired:SetTimeFromStart(current - 10, 5)
    frame.Cooldown:SetCooldownFromDurationObject(expired)
  end)), true, "expired duration object completes")
  Eq((Completion(nil, function(frame)
    local running = test.Units.NewDuration()
    running:SetTimeFromStart(current, 50)
    frame.Cooldown:SetCooldownFromDurationObject(running)
  end)), false, "running duration object does not complete")
  Eq((Completion(nil, function(frame)
    local hidden = test.Units.NewDuration()
    hidden:SetTimeFromStart(Secret.Wrap(current - 10), 5)
    frame.Cooldown:SetCooldownFromDurationObject(hidden)
  end)), false, "secret duration object does not complete")
  Eq((Completion(nil, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
    Native(frame, frame.spellID)
  end)), true, "converted raw times complete")
  Eq((Completion(nil, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
    frame.cooldownPaused = true
  end)), false, "paused cooldown does not complete")
  Eq((Completion(nil, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
    frame.Cooldown:Pause()
    frame.Cooldown:Resume()
  end)), true, "resumed cooldown completes")
  Eq((Completion(function(frame) frame.cooldownUseAuraDisplayTime = true end, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
  end)), false, "aura display time does not complete")
  Eq((Completion(function(frame) frame.cooldownUseAuraDisplayTime = nil end, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
  end)), false, "unknown aura display time does not complete")
  Eq((Completion(function(frame) frame.cooldownUseAuraDisplayTime = Secret.Wrap(false) end, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
  end)), false, "secret aura display time does not complete")
  Eq((Completion(function(frame)
    frame.isOnActualCooldown = false
    frame.isOnGCD = true
  end, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
  end)), false, "global cooldown does not complete")
  Eq((Completion(function(frame)
    frame.isOnActualCooldown = false
    frame.isOnGCD = nil
  end, function(frame)
    frame.Cooldown:SetCooldown(current - 10, 5, 1)
  end)), false, "unknown global cooldown does not complete")

  local doneFrame = NewObserved(1500, 5500, "spell", nil, function(target)
    target.isOnActualCooldown = true
    target.isOnGCD = false
    target.cooldownUseAuraDisplayTime = false
    target.wasSetFromCharges = true
  end)
  doneFrame.Cooldown:SetCooldown(current - 10, 5, 1)
  local doneRevision = Revision(doneFrame, 5500)
  doneFrame.Cooldown:RunScript("OnCooldownDone")
  local doneNative = Native(doneFrame, 5500)
  Eq(doneNative.onCooldown, false, "completion clears onCooldown")
  Eq(doneNative.recharging, false, "completion clears recharging")
  Eq(doneNative.revision, doneRevision, "completion keeps the revision")
  doneFrame.Cooldown:SetCooldown(current - 1, 50, 1)
  doneNative = Native(doneFrame, 5500)
  Eq(doneNative.onCooldown, true, "a new cooldown is no longer completed")
  Eq(doneNative.recharging, true, "a new cooldown is no longer recharging completed")
  Eq(doneNative.revision, doneRevision + 1, "new cooldown bumps the revision")
  Drain()
  ClearViewers()

  local sets, infos, setCalls = {}, {}, {}
  local function InstallCatalogApi()
    Stub(_G, "C_CooldownViewer", {
      GetCooldownViewerCategorySet = function(category, ...)
        setCalls[#setCalls + 1] = {category = category, count = select("#", ...), flag = (...)}
        return sets[category]
      end,
      GetCooldownViewerCooldownInfo = function(cooldownID) return infos[cooldownID] end,
    })
  end
  InstallCatalogApi()
  Stub(_G, "CooldownViewerSettings", nil)
  Stub(_G, "CooldownViewerDataProvider", nil)

  sets = {[0] = {101, 102}, [1] = {103}, [2] = {104, 104}, [3] = {105}, [9] = {106}, [-1] = {199}}
  infos = {
    [101] = {spellID = 1}, [102] = {spellID = 2, isKnown = false}, [103] = {spellID = 3, isKnown = true},
    [104] = {spellID = 4, isKnown = true}, [105] = {spellID = 5}, [106] = {spellID = 6}, [199] = {spellID = 9},
  }
  local catalog = private.CDMCatalog()
  local queried = {}
  for _, call in ipairs(setCalls) do
    queried[call.category] = (queried[call.category] or 0) + 1
    Eq(call.count, 1, "category set takes one extra argument")
    Eq(call.flag, true, "category set asks for hidden entries")
  end
  Eq(queried[-1], nil, "negative categories are not queried")
  for value = 0, 9 do Eq(queried[value], 1, "category " .. value .. " queried once") end
  Eq(catalog[199], nil, "negative category entries are not listed")
  Eq(catalog[101].category, 0, "category defaults to the source category")
  Eq(catalog[101].sourceCategory, 0, "source category")
  Eq(catalog[101].displayed, nil, "displayed unknown without layout or frame")
  Eq(catalog[101].known, true, "known when isKnown is absent")
  Eq(catalog[102].known, false, "known false")
  Eq(catalog[103].known, true, "explicit known")
  Eq(catalog[104].known, true, "known true")
  Eq(catalog[104].sourceCategory, 2, "buff source category")
  Eq(catalog[106].category, 9, "extra category entry")
  Check(not rawequal(private.CDMCatalog(), catalog), "catalog is a new table")
  setCalls = {}

  infos[107] = false
  infos[Secret.Wrap(108)] = {spellID = 8}
  infos["109"] = {spellID = 9}
  sets[0] = {101, 107, Secret.Wrap(108), "109", 110}
  sets[1] = nil
  sets[2] = nil
  sets[3] = nil
  sets[9] = nil
  catalog = private.CDMCatalog()
  Eq(type(catalog[101]), "table", "readable entry kept")
  Eq(catalog[107], nil, "entry without info is omitted")
  Eq(catalog[110], nil, "unknown id is omitted")
  Eq(catalog["109"], nil, "text ids are omitted")
  local entryCount = 0
  for _ in pairs(catalog) do entryCount = entryCount + 1 end
  Eq(entryCount, 1, "only readable entries are listed")

  infos = {[201] = {spellID = 21}, [202] = {spellID = 22}, [203] = {spellID = 23}, [204] = {spellID = 24},
    [205] = {spellID = 25}, [206] = {spellID = 26}, [207] = {spellID = 27}, [208] = {spellID = 28}}
  sets = {[2] = {201, 202, 203, 204, 205, 206, 207, 208}}
  local layout = {
    [201] = {category = 0}, [202] = {category = 1}, [203] = {category = 3}, [204] = {category = 4},
    [205] = {category = 6}, [206] = {category = -1}, [207] = {category = Secret.Wrap(0)}, [208] = {},
  }
  local dirty = false
  local provider = {
    IsDirty = function() return dirty end,
    GetDisplayData = function() return {cooldownInfoByID = layout} end,
  }
  Stub(_G, "CooldownViewerSettings", {GetDataProvider = function() return provider end})
  catalog = private.CDMCatalog()
  Eq(catalog[201].displayed, true, "layout essential is displayed")
  Eq(catalog[201].category, 0, "layout essential category")
  Eq(catalog[201].sourceCategory, 2, "layout keeps the source category")
  Eq(catalog[202].displayed, true, "layout utility is displayed")
  Eq(catalog[202].category, 1, "layout utility category")
  Eq(catalog[203].displayed, true, "layout tracked bar is displayed")
  Eq(catalog[203].category, 3, "layout tracked bar category")
  Eq(catalog[204].displayed, false, "layout group buff is not displayed")
  Eq(catalog[204].category, 4, "layout group buff category")
  Eq(catalog[205].displayed, false, "layout shared essential is not displayed")
  Eq(catalog[205].category, 6, "layout shared essential category")
  Eq(catalog[206].displayed, false, "layout hidden is not displayed")
  Eq(catalog[206].category, 2, "negative layout category keeps the source category")
  Eq(catalog[207].displayed, nil, "secret layout category is unknown")
  Eq(catalog[207].category, 2, "secret layout category keeps the source category")
  Eq(catalog[208].displayed, nil, "layout entry without category is unknown")

  dirty = true
  catalog = private.CDMCatalog()
  Eq(catalog[201].displayed, nil, "dirty provider is ignored")
  Eq(catalog[201].category, 2, "dirty provider keeps the source category")
  dirty = false
  local fallbackProvider = {
    GetDisplayData = function() return {cooldownInfoByID = {[201] = {category = 1}}} end,
  }
  Stub(_G, "CooldownViewerSettings", {GetDataProvider = function() return nil end})
  Stub(_G, "CooldownViewerDataProvider", fallbackProvider)
  catalog = private.CDMCatalog()
  Eq(catalog[201].category, 1, "global provider is the fallback")
  Stub(_G, "CooldownViewerSettings", {GetDataProvider = function() return provider end})
  catalog = private.CDMCatalog()
  Eq(catalog[201].category, 0, "settings provider has priority")
  Stub(_G, "CooldownViewerSettings", {})
  Stub(_G, "CooldownViewerDataProvider", {GetDisplayData = function() return nil end})
  catalog = private.CDMCatalog()
  Eq(catalog[201].displayed, nil, "provider without display data")
  Stub(_G, "CooldownViewerDataProvider", {GetDisplayData = function() return {} end})
  catalog = private.CDMCatalog()
  Eq(catalog[201].displayed, nil, "display data without layout")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()
  Stub(_G, "CooldownViewerSettings", nil)
  Stub(_G, "CooldownViewerDataProvider", nil)

  infos = {[301] = {spellID = 31}, [302] = {spellID = 32}, [303] = {spellID = 33}, [304] = {spellID = 34},
    [305] = {spellID = 35}}
  sets = {[0] = {301, 302, 303, 304, 305}}
  local liveFrames = {NewFrame(301, 31), NewFrame(302, 32), NewFrame(303, 33), NewFrame(304, 34)}
  liveFrames[1].viewerFrame = {cooldownViewerCategory = 1}
  liveFrames[2].viewerFrame = {cooldownViewerCategory = -1}
  liveFrames[3].viewerFrame = {cooldownViewerCategory = Secret.Wrap(1)}
  liveFrames[4].viewerFrame = {cooldownViewerCategory = false}
  _G.EssentialCooldownViewer = NewViewer(liveFrames)
  catalog = private.CDMCatalog()
  Eq(catalog[301].displayed, true, "live frame is displayed")
  Eq(catalog[301].category, 1, "live frame category comes from its viewer")
  Eq(catalog[302].displayed, true, "live frame in a negative viewer is displayed")
  Eq(catalog[302].category, 0, "negative viewer category keeps the source category")
  Eq(catalog[303].category, 0, "secret viewer category keeps the source category")
  Eq(catalog[304].category, 0, "false viewer category keeps the source category")
  Eq(catalog[305].displayed, nil, "entry without frame is unknown")
  Stub(_G, "CooldownViewerSettings", {GetDataProvider = function()
    return {GetDisplayData = function() return {cooldownInfoByID = {[301] = {category = 4}}} end}
  end})
  catalog = private.CDMCatalog()
  Eq(catalog[301].displayed, false, "layout beats the live frame")
  Eq(catalog[301].category, 4, "layout category beats the viewer category")
  Eq(catalog[302].displayed, true, "entries missing from the layout use their frame")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  ClearViewers()

  local spellInfos = {}
  local itemNames, itemIcons, inventoryItems, categorySources = {}, {}, {}, {}
  local itemRequests, sourceCalls = {}, {}
  Stub(C_Spell, "GetSpellInfo", function(spellID) return spellInfos[spellID] end)
  Stub(C_Item, "GetItemNameByID", function(itemID) return itemNames[itemID] end)
  Stub(C_Item, "GetItemIconByID", function(itemID) return itemIcons[itemID] end)
  Stub(_G, "GetInventoryItemID", function(_, slot) return inventoryItems[slot] end)
  Stub(C_Spell, "GetLastCategoryCooldownSource", function(categoryID)
    sourceCalls[#sourceCalls + 1] = categoryID
    local source = categorySources[categoryID]
    if source then return source[1], source[2] end
  end)
  Stub(private, "CDMRequestItemData", function(itemID) itemRequests[#itemRequests + 1] = itemID end)
  spellInfos[41] = {name = "Alpha", iconID = 4100}
  spellInfos[42] = {name = "Beta", iconID = 4200}
  spellInfos[43] = {name = "Gamma", iconID = 4300}
  spellInfos[44] = {name = "Delta", iconID = 4400}
  spellInfos[45] = {name = "Epsilon", iconID = 4500}
  spellInfos[46] = {name = "Zeta", iconID = 4600}
  private.CDMResetIdentities()

  local function Identify(id, category, info, frame)
    return private.CDMIdentity(id, {category = category}, info, frame)
  end
  local identity = Identify(1, 0, {spellID = 46, linkedSpellID = 41}, nil)
  Eq(identity.spellID, 41, "linked spell comes first")
  Eq(identity.name, "Alpha", "name from the spell")
  Eq(identity.icon, 4100, "icon from the spell")
  Eq(identity.itemID, nil, "no item")
  Eq(identity.slot, nil, "no slot")
  identity = Identify(2, 0, {spellID = 46, linkedSpellID = Secret.Wrap(41), overrideTooltipSpellID = 42, overrideSpellID = 43}, nil)
  Eq(identity.spellID, 42, "tooltip override comes second")
  identity = Identify(3, 0, {spellID = 46, linkedSpellID = "x", overrideTooltipSpellID = Secret.Wrap(42), overrideSpellID = 43}, nil)
  Eq(identity.spellID, 43, "spell override comes third")
  identity = Identify(4, 0, {spellID = 44, linkedSpellIDs = {45}}, nil)
  Eq(identity.spellID, 44, "linked spell list is for buffs only")
  identity = Identify(5, 2, {spellID = 44, linkedSpellIDs = {Secret.Wrap(1), 0, -3, "x", 45, 41}}, nil)
  Eq(identity.spellID, 45, "buffs use the first readable positive linked spell")
  identity = Identify(6, 2, {spellID = 44, linkedSpellIDs = {0, -3}}, nil)
  Eq(identity.spellID, 44, "buff without a usable linked spell uses the base spell")
  Stub(private, "CDMIsBuff", function() return true end)
  identity = Identify(7, 0, {spellID = 44, linkedSpellIDs = {45}}, nil)
  Eq(identity.spellID, 45, "buff test goes through the exported function")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()
  Stub(C_Spell, "GetSpellInfo", function(spellID) return spellInfos[spellID] end)
  Stub(C_Item, "GetItemNameByID", function(itemID) return itemNames[itemID] end)
  Stub(C_Item, "GetItemIconByID", function(itemID) return itemIcons[itemID] end)
  Stub(_G, "GetInventoryItemID", function(_, slot) return inventoryItems[slot] end)
  Stub(C_Spell, "GetLastCategoryCooldownSource", function(categoryID)
    sourceCalls[#sourceCalls + 1] = categoryID
    local source = categorySources[categoryID]
    if source then return source[1], source[2] end
  end)
  Stub(private, "CDMRequestItemData", function(itemID) itemRequests[#itemRequests + 1] = itemID end)

  local spellFrameStub = NewFrame(8, 46)
  identity = Identify(8, 0, {spellID = 44, linkedSpellID = 41}, spellFrameStub)
  Eq(identity.spellID, 46, "the frame spell comes before everything")
  spellFrameStub.spellID = Secret.Wrap(46)
  identity = Identify(9, 0, {spellID = 44, linkedSpellID = 41}, spellFrameStub)
  Eq(identity.spellID, 41, "secret frame spell is skipped")
  spellFrameStub.spellID = "46"
  identity = Identify(10, 0, {spellID = 44}, spellFrameStub)
  Eq(identity.spellID, 44, "text frame spell is skipped")
  identity = Identify(11, 0, {spellID = 44}, {})
  Eq(identity.spellID, 44, "frame without GetSpellID")
  identity = Identify(12, 0, {spellID = Secret.Wrap(44)}, nil)
  Eq(identity.spellID, nil, "secret base spell is unknown")
  Eq(identity.name, "CDM entry 12", "unknown entry name")
  Eq(identity.icon, 134400, "unknown entry icon")
  identity = Identify(13, 0, {spellID = 0}, nil)
  Eq(identity.spellID, 0, "zero spell is kept")
  Eq(identity.name, "CDM entry 13", "zero spell has no lookup")
  identity = Identify(14, 0, {spellID = 999}, nil)
  Eq(identity.spellID, 999, "spell without info is kept")
  Eq(identity.name, "CDM entry 14", "spell without info name")

  inventoryItems[13] = 900
  itemNames[900] = "Trinket"
  itemIcons[900] = 9000
  identity = Identify(20, 0, {spellID = 41, equipSlot = 13}, nil)
  Eq(identity.slot, 13, "slot")
  Eq(identity.itemID, 900, "item from the slot")
  Eq(identity.name, "Trinket", "item name beats the spell name")
  Eq(identity.icon, 9000, "item icon beats the spell icon")
  Eq(identity.spellID, 41, "spell kept with an item")
  Eq(itemRequests[#itemRequests], 900, "item data requested through the export")
  itemNames[900] = nil
  itemIcons[900] = nil
  identity = Identify(21, 0, {spellID = 41, equipSlot = 13}, nil)
  Eq(identity.name, "Item 900", "item name fallback")
  Eq(identity.icon, 4100, "item icon falls back to the spell icon")
  inventoryItems[13] = nil
  identity = Identify(22, 0, {equipSlot = 13}, nil)
  Eq(identity.name, "Equipment slot 13", "empty slot name")
  Eq(identity.itemID, nil, "empty slot has no item")
  Eq(identity.icon, 134400, "empty slot icon")
  identity = Identify(23, 0, {spellID = 41, equipSlot = Secret.Wrap(13)}, nil)
  Eq(identity.slot, nil, "secret slot is unknown")
  inventoryItems[13] = Secret.Wrap(900)
  identity = Identify(24, 0, {equipSlot = 13}, nil)
  Eq(identity.itemID, nil, "secret slot item is unknown")
  inventoryItems[13] = nil

  local itemFrame = NewFrame(25, 46)
  itemFrame.cooldownInfo = {lastItemIDForCategory = 910}
  itemNames[910] = "Potion"
  identity = Identify(25, 0, {spellID = 41}, itemFrame)
  Eq(identity.itemID, 910, "item from the frame")
  Eq(identity.name, "Potion", "frame item name")
  itemFrame.cooldownInfo = {lastItemIDForCategory = Secret.Wrap(910)}
  identity = Identify(26, 0, {spellID = 41}, itemFrame)
  Eq(identity.itemID, nil, "secret frame item is unknown")
  inventoryItems[14] = 920
  itemFrame.cooldownInfo = {lastItemIDForCategory = 910}
  identity = Identify(27, 0, {spellID = 41, equipSlot = 14}, itemFrame)
  Eq(identity.itemID, 920, "slot item beats the frame item")
  inventoryItems[14] = nil

  categorySources[77] = {47, 930}
  spellInfos[47] = {name = "Eta", iconID = 4700}
  sourceCalls = {}
  identity = Identify(30, 0, {spellID = 41, spellCategoryID = 77}, nil)
  Eq(#sourceCalls, 0, "category source is skipped when the spell is known")
  identity = Identify(31, 0, {spellCategoryID = 77}, nil)
  Eq(sourceCalls[1], 77, "category source is asked")
  Eq(identity.spellID, 47, "spell from the category source")
  Eq(identity.itemID, 930, "item from the category source")
  inventoryItems[15] = 940
  identity = Identify(32, 0, {spellCategoryID = 77, equipSlot = 15}, nil)
  Eq(identity.itemID, 940, "category source does not replace a known item")
  Eq(identity.spellID, 47, "category source spell with a known item")
  inventoryItems[15] = nil
  categorySources[78] = {Secret.Wrap(47), Secret.Wrap(930)}
  identity = Identify(33, 0, {spellCategoryID = 78}, nil)
  Eq(identity.spellID, nil, "secret category source spell")
  Eq(identity.itemID, nil, "secret category source item")
  identity = Identify(34, 0, {spellCategoryID = Secret.Wrap(77)}, nil)
  Eq(identity.spellID, nil, "secret category id")

  private.CDMResetIdentities()
  identity = Identify(50, 0, {spellID = 41}, nil)
  Eq(identity.name, "Alpha", "memory seed")
  spellInfos[41] = nil
  identity = Identify(50, 0, {}, nil)
  Eq(identity.spellID, 41, "memory keeps the spell")
  Eq(identity.name, "Alpha", "memory keeps the name")
  Eq(identity.icon, 4100, "memory keeps the icon")
  identity.name = "Changed"
  Eq(Identify(50, 0, {}, nil).name, "Alpha", "returned table is not the memory")
  spellInfos[41] = {name = "Alpha", iconID = 4100}
  spellInfos[48] = {name = "Theta", iconID = 4800}
  identity = Identify(50, 0, {spellID = 48}, nil)
  Eq(identity.name, "Theta", "new data replaces memory")
  Eq(Identify(50, 0, {}, nil).name, "Theta", "memory follows the latest data")

  inventoryItems[16] = 950
  itemNames[950] = "Ring"
  Identify(51, 0, {spellID = 41, equipSlot = 16}, nil)
  inventoryItems[16] = nil
  identity = Identify(51, 0, {equipSlot = 16}, nil)
  Eq(identity.name, "Equipment slot 16", "slot never reuses memory")
  Eq(identity.itemID, nil, "slot never reuses the memorized item")

  spellInfos[49] = {name = "Iota", iconID = 4900}
  itemFrame.cooldownInfo = {lastItemIDForCategory = 960}
  itemNames[960] = "Gem"
  Identify(52, 0, {spellID = 49}, itemFrame)
  spellInfos[49] = nil
  itemFrame.spellID = Secret.Wrap(1)
  itemFrame.cooldownInfo = {lastItemIDForCategory = 961}
  itemNames[961] = "Stone"
  identity = Identify(52, 0, {}, itemFrame)
  Eq(identity.spellID, nil, "another item drops the memorized spell")
  Eq(identity.name, "Stone", "another item name")
  itemFrame.cooldownInfo = {lastItemIDForCategory = 961}
  identity = Identify(52, 0, {}, itemFrame)
  Eq(identity.itemID, 961, "same item keeps the item")

  Identify(53, 0, {spellID = 41}, nil)
  private.CDMResetIdentities()
  spellInfos[41] = nil
  Eq(Identify(53, 0, {}, nil).name, "CDM entry 53", "reset forgets identities")
  spellInfos[41] = {name = "Alpha", iconID = 4100}
  private.cdmScanBatch = {}
  Identify(54, 0, {spellID = 41}, nil)
  private.CDMResetIdentities()
  Eq(private.cdmScanBatch.identitiesReset, true, "reset flags the batch")
  spellInfos[41] = nil
  Eq(Identify(54, 0, {}, nil).name, "CDM entry 54", "first reset of the batch wipes")
  spellInfos[41] = {name = "Alpha", iconID = 4100}
  Identify(54, 0, {spellID = 41}, nil)
  private.CDMResetIdentities()
  spellInfos[41] = nil
  Eq(Identify(54, 0, {}, nil).name, "Alpha", "second reset of the batch is ignored")
  private.cdmScanBatch = {}
  private.CDMResetIdentities()
  Eq(Identify(54, 0, {}, nil).name, "CDM entry 54", "a new batch wipes again")
  private.cdmScanBatch = nil
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()

  local function ItemState()
    return {progressType = "static", value = 1, total = 1, onCooldown = "keep", isReady = "keep", duration = "keep"}
  end
  local itemNow = GetTime()
  local inventoryCooldown = {itemNow - 5, 30, 1}
  local bagCooldown = {itemNow - 5, 10, 1}
  local inventoryCalls = {}
  Stub(_G, "GetInventoryItemCooldown", function(unit, slot)
    inventoryCalls[#inventoryCalls + 1] = {unit, slot}
    return inventoryCooldown[1], inventoryCooldown[2], inventoryCooldown[3]
  end)
  Stub(C_Item, "GetItemCooldown", function() return bagCooldown[1], bagCooldown[2], bagCooldown[3] end)
  local state = ItemState()
  private.CDMApplyItem(state, {slot = 13, itemID = 900})
  Eq(inventoryCalls[1][1], "player", "inventory cooldown of the player")
  Eq(inventoryCalls[1][2], 13, "inventory cooldown of the slot")
  Eq(state.progressType, "timed", "item cooldown is timed")
  Near(state.duration, 30, "slot duration beats the bag item")
  Near(state.expirationTime, itemNow + 25, "item expiration")
  Eq(state.modRate, 1, "item mod rate")
  Eq(state.value, nil, "item value cleared")
  Eq(state.total, nil, "item total cleared")
  Eq(state.onCooldown, true, "item on cooldown")
  Eq(state.isReady, false, "item not ready")
  state = ItemState()
  private.CDMApplyItem(state, {itemID = 900})
  Near(state.duration, 10, "bag item duration")
  inventoryCooldown = {itemNow - 5, 0, 1}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.onCooldown, false, "zero duration is not a cooldown")
  Eq(state.isReady, true, "zero duration is ready")
  inventoryCooldown = {itemNow - 50, 30, 1}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.onCooldown, false, "expired item cooldown")
  Eq(state.isReady, true, "expired item is ready")
  inventoryCooldown = {itemNow - 50, 30, 0}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.onCooldown, false, "disabled item is not on cooldown")
  Eq(state.isReady, false, "disabled item is not ready")
  inventoryCooldown = {itemNow - 50, 30, Secret.Wrap(0)}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.isReady, true, "secret enabled flag is ignored")
  inventoryCooldown = {Secret.Wrap(itemNow), 30, 1}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.progressType, "static", "secret start leaves the state alone")
  Eq(state.onCooldown, "keep", "secret start keeps onCooldown")
  inventoryCooldown = {itemNow, Secret.Wrap(30), 1}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.progressType, "static", "secret duration leaves the state alone")
  inventoryCooldown = {nil, nil, nil}
  state = ItemState()
  private.CDMApplyItem(state, {slot = 13})
  Eq(state.progressType, "static", "missing times leave the state alone")
  state = ItemState()
  private.CDMApplyItem(state, {})
  Eq(state.progressType, "static", "no slot and no item leave the state alone")
  Stub(C_Item, "GetItemCooldown", nil)
  state = ItemState()
  private.CDMApplyItem(state, {itemID = 900})
  Eq(state.progressType, "static", "missing item cooldown API leaves the state alone")
  Stub(C_Item, "GetItemCooldown", function() return itemNow, 10, 1 end)
  state = ItemState()
  private.CDMApplyItem(state, {itemID = 900})
  Eq(state.progressType, "timed", "item cooldown API back")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()

  local spellNames, spellCalls = {}, 0
  Stub(private.ExecEnv, "GetSpellInfo", function(spellID)
    spellCalls = spellCalls + 1
    local entry = spellNames[spellID]
    if not entry then return nil end
    return entry[1] .. (entry.counter and spellCalls or ""), nil, entry[2]
  end)
  setCalls = {}
  sets = {[0] = {1, 2}, [1] = {3, 2}, [2] = {4, 5, 6}, [3] = {7, 4}}
  infos = {
    [1] = {spellID = 11}, [2] = {spellID = 12, linkedSpellIDs = {21, 22}, overrideTooltipSpellID = 23},
    [3] = {spellID = 11}, [4] = {spellID = 14, linkedSpellIDs = {24}}, [5] = {}, [7] = {spellID = 17},
  }
  spellNames = {[11] = {"Alpha", 111, counter = true}, [12] = {"Beta"}, [14] = {"Delta", 114}, [17] = {"Eta", 117}}
  local spells = private.GetCooldownManagerSpells()
  Eq(spells[11], "|T111:16|t Alpha" .. 1, "spell label with icon, first label kept")
  Eq(spells[12], "Beta", "spell label without icon")
  Eq(spells[14], nil, "buff spells are not listed")
  Eq(spells[17], nil, "bar spells are not listed")
  entryCount = 0
  for _ in pairs(spells) do entryCount = entryCount + 1 end
  Eq(entryCount, 2, "only cooldown spells are listed")
  for _, call in ipairs(setCalls) do Eq(call.count, 0, "option lists ask for the plain category set") end
  spellNames[11] = nil
  spells = private.GetCooldownManagerSpells()
  Eq(spells[11], nil, "spell without a name is not listed")

  spellNames = {[14] = {"Delta", 114}, [17] = {"Eta", 117}, [12] = {"Beta"}}
  local auras = private.GetCooldownManagerAuras()
  Eq(auras[4], "|T114:16|t Delta", "aura label with icon")
  Eq(auras[7], "|T117:16|t Eta", "bar aura label")
  Eq(auras[5], nil, "aura without spell is not listed")
  Eq(auras[6], nil, "aura without info is not listed")
  Eq(auras[1], nil, "cooldown entries are not auras")
  Eq(auras[2], nil, "cooldown entries are not aura entries")
  entryCount = 0
  for _ in pairs(auras) do entryCount = entryCount + 1 end
  Eq(entryCount, 2, "only tracked entries are listed")
  Eq(auras[4], "|T114:16|t Delta", "second pass")

  local idList = private.GetCooldownManagerAuraSpellIDs(2)
  Eq(table.concat(idList, ","), "21,22,23,12", "aura spell ids order")
  idList = private.GetCooldownManagerAuraSpellIDs(4)
  Eq(table.concat(idList, ","), "24,14", "aura spell ids without override")
  idList = private.GetCooldownManagerAuraSpellIDs(5)
  Eq(#idList, 0, "empty info gives no ids")
  idList = private.GetCooldownManagerAuraSpellIDs(404)
  Eq(#idList, 0, "unknown cooldown gives no ids")
  infos[8] = {spellID = 12, linkedSpellIDs = {12}, overrideTooltipSpellID = 12}
  Eq(table.concat(private.GetCooldownManagerAuraSpellIDs(8), ","), "12,12,12", "aura spell ids are not deduplicated")

  Stub(C_CooldownViewer, "GetCooldownViewerCategorySet", function(category)
    if category == categories.Essential then error("category failed") end
    return sets[category]
  end)
  spellNames[11] = {"Alpha", 111}
  spellNames[17] = {"Eta", 117}
  sets[1] = {8}
  infos[8] = {spellID = 17}
  spells = private.GetCooldownManagerSpells()
  Eq(spells[11], nil, "failing category is skipped")
  Eq(spells[17], "|T117:16|t Eta", "other categories survive a failing category")
  Stub(C_CooldownViewer, "GetCooldownViewerCooldownInfo", function(cooldownID)
    if cooldownID == 7 then error("info failed") end
    return infos[cooldownID]
  end)
  auras = private.GetCooldownManagerAuras()
  Eq(auras[7], nil, "failing info is skipped")
  Eq(auras[4], "|T114:16|t Delta", "other entries survive a failing info")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()
  Stub(private.ExecEnv, "GetSpellInfo", function() return "Name", nil, 1 end)
  Stub(C_CooldownViewer, "GetCooldownViewerCategorySet", nil)
  Eq(next(private.GetCooldownManagerSpells()), nil, "spells without the category API")
  Eq(next(private.GetCooldownManagerAuras()), nil, "auras without the category API")
  Stub(_G, "C_CooldownViewer", nil)
  Eq(next(private.GetCooldownManagerSpells()), nil, "spells without the viewer API")
  Eq(next(private.GetCooldownManagerAuras()), nil, "auras without the viewer API")
  Eq(#private.GetCooldownManagerAuraSpellIDs(1), 0, "aura ids without the viewer API")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  InstallCatalogApi()
  Stub(_G, "C_CooldownViewer", {GetCooldownViewerCategorySet = function() return {} end})
  Eq(#private.GetCooldownManagerAuraSpellIDs(1), 0, "aura ids without the info API")
  Unstub()
  InstallScanRecorder()
  InstallEnum()

  local nextSpell = 800000
  local Nothing = {}
  local function AuraFrame(overrides)
    nextSpell = nextSpell + 1
    local spellID = nextSpell
    local frame = NewFrame(spellID, spellID)
    frame.auraInstanceID = 5
    frame.isActive = true
    frame.auraDataUnit = "player"
    frame.auraSpellID = spellID
    frame.auraDataCached = {
      spellId = spellID, duration = 10, expirationTime = GetTime() + 10, applications = 3, timeMod = 1,
    }
    for key, value in pairs(overrides or {}) do
      if value == Nothing then value = nil end
      frame[key] = value
    end
    return frame
  end
  local function Apply(frame, exactID, buffSpellIDs, initial)
    local state = initial or {progressType = "static", value = 1, total = 1}
    private.CDMApplyAura(state, {}, {}, frame, exactID, buffSpellIDs)
    return state
  end
  local function Reset(state, label)
    Eq(state.progressType, "static", label .. " progress type")
    Eq(state.value, 1, label .. " value")
    Eq(state.total, 1, label .. " total")
    Eq(state.durationObject, nil, label .. " duration object")
    Eq(state.duration, nil, label .. " duration")
    Eq(state.expirationTime, nil, label .. " expiration")
    Eq(state.modRate, nil, label .. " mod rate")
    Eq(state.cdmCountdownSource, nil, label .. " countdown source")
    Eq(state.cdmStackSource, nil, label .. " stack source")
    Eq(state.cdmTextRecord, nil, label .. " text record")
    Eq(state.stacks, nil, label .. " stacks")
    Eq(state.cdmDispelName, nil, label .. " dispel name")
    Eq(state.debuffClass, nil, label .. " debuff class")
  end
  local function Dirty()
    return {
      progressType = "timed", value = 7, total = 8, durationObject = {}, duration = 9, expirationTime = 10,
      modRate = 11, cdmCountdownSource = {}, cdmStackSource = {}, cdmTextRecord = {}, stacks = 12,
      cdmDispelName = "Magic", debuffClass = "magic",
    }
  end
  local function NoDuration(callback)
    Stub(C_DurationUtil, "CreateDuration", nil)
    callback()
    Unstub()
    InstallScanRecorder()
    InstallEnum()
  end

  local state = Apply(nil)
  Eq(state.cdmAuraUnit, "player", "no frame unit")
  Eq(state.cdmAuraFilter, "HELPFUL", "no frame filter")
  Eq(state.cdmAuraTotem, false, "no frame totem")
  Eq(state.cdmAuraRenderUnit, nil, "no frame render unit")
  Eq(state.auraActive, nil, "no frame leaves activity unknown")
  Eq(state.progressType, "static", "no frame keeps the state")
  state = Apply(nil, 123, {1})
  Eq(state.auraActive, nil, "no frame with exact id leaves activity unknown")

  local function FilterOf(unit, harmful, friend)
    local frame = AuraFrame({auraDataUnit = unit})
    frame.auraDataCached.isHarmful = harmful
    Stub(_G, "UnitIsFriend", function() return friend end)
    local result = Apply(frame)
    Unstub()
    InstallScanRecorder()
    InstallEnum()
    return result.cdmAuraUnit, result.cdmAuraFilter
  end
  local unit, filter = FilterOf("player", true)
  Eq(unit, "player", "player unit")
  Eq(filter, "HARMFUL", "harmful player filter")
  unit, filter = FilterOf("player", false)
  Eq(filter, "HELPFUL", "helpful player filter")
  unit, filter = FilterOf("player", nil, false)
  Eq(filter, "HELPFUL", "player filter ignores friendship")
  unit, filter = FilterOf("target", true)
  Eq(unit, "target", "target unit")
  Eq(filter, "HARMFUL|PLAYER", "harmful target filter")
  unit, filter = FilterOf("target", false)
  Eq(filter, "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY", "helpful target filter")
  unit, filter = FilterOf("target", nil, true)
  Eq(filter, "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY", "friendly target without harm flag")
  unit, filter = FilterOf("target", nil, false)
  Eq(filter, "HARMFUL|PLAYER", "hostile target without harm flag")
  unit, filter = FilterOf("target", Secret.Wrap(true), true)
  Eq(filter, "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY", "secret harm flag falls back to friendship")
  unit, filter = FilterOf("target", nil, Secret.Wrap(true))
  Eq(filter, "HARMFUL|PLAYER", "secret friendship counts as hostile")
  unit, filter = FilterOf("focus", true)
  Eq(unit, "player", "other units count as the player")
  Eq(filter, "HARMFUL", "other unit filter")
  unit = FilterOf(Secret.Wrap("target"), false)
  Eq(unit, "player", "secret unit counts as the player")

  local function DispelOf(dispelName)
    local frame = AuraFrame()
    frame.auraDataCached.dispelName = dispelName
    return Apply(frame)
  end
  state = DispelOf("Magic")
  Eq(state.cdmDispelName, "Magic", "dispel name")
  Eq(state.debuffClass, "magic", "dispel class is lower case")
  state = DispelOf("")
  Eq(state.cdmDispelName, "", "empty dispel name")
  Eq(state.debuffClass, "enrage", "empty dispel name is an enrage")
  state = DispelOf(Secret.Wrap("Magic"))
  Eq(state.cdmDispelName, nil, "secret dispel name")
  Eq(state.debuffClass, nil, "secret dispel class")
  state = DispelOf(nil)
  Eq(state.cdmDispelName, nil, "missing dispel name")
  state = DispelOf(5)
  Eq(state.debuffClass, nil, "non text dispel name")

  local function TotemFrame(totemData, extra)
    local frame = AuraFrame(extra)
    frame.auraInstanceID, frame.auraDataCached, frame.isActive = nil, nil, nil
    frame.totemData = totemData
    return frame
  end
  local totemNow = GetTime()
  state = Apply(TotemFrame({duration = 10, expirationTime = totemNow + 10, modRate = 2}))
  Eq(state.cdmAuraTotem, true, "totem flag")
  Eq(state.progressType, "timed", "totem is timed")
  Eq(state.duration, 10, "totem duration")
  Eq(state.expirationTime, totemNow + 10, "totem expiration")
  Eq(state.modRate, 2, "totem mod rate")
  Eq(state.auraActive, true, "running totem is active")
  state = Apply(TotemFrame({duration = 10, expirationTime = totemNow + 10}))
  Eq(state.modRate, 1, "totem mod rate defaults to one")
  state = Apply(TotemFrame({duration = 10, expirationTime = totemNow - 1}), nil, nil, Dirty())
  Eq(state.auraActive, false, "expired totem is inactive")
  Reset(state, "expired totem")
  state = Apply(TotemFrame({duration = Secret.Wrap(10), expirationTime = totemNow + 10}))
  Eq(state.cdmAuraTotem, true, "secret totem flag")
  Eq(state.auraActive, nil, "secret totem activity is unknown")
  Eq(state.progressType, "static", "secret totem keeps the state")
  state = Apply(TotemFrame({duration = 10}))
  Eq(state.auraActive, nil, "incomplete totem activity is unknown")
  local withAura = AuraFrame()
  withAura.totemData = {duration = 10, expirationTime = totemNow + 10}
  state = Apply(withAura)
  Eq(state.cdmAuraTotem, false, "aura beats totem")
  Eq(state.auraActive, true, "aura with totem is active")

  local plain = AuraFrame()
  state = Apply(plain)
  Eq(state.auraActive, true, "readable aura is active")
  Eq(state.stacks, 3, "stacks")
  Eq(state.progressType, "durationObject", "aura timing is a duration object")
  Check(private.IsDurationObject(state.durationObject), "aura duration object")
  Near(state.durationObject:GetRemainingDuration(), plain.auraDataCached.expirationTime - GetTime(), "aura remaining")
  Eq(state.value, nil, "duration mode clears the value")
  Eq(state.total, nil, "duration mode clears the total")
  Eq(state.cdmAuraRenderUnit, "player", "render unit")
  Eq(table.concat(state.cdmAuraRenderSpellIDs, ","), tostring(plain.auraSpellID), "render spell ids")

  local secretStacks = AuraFrame()
  secretStacks.auraDataCached.applications = Secret.Wrap(4)
  state = Apply(secretStacks, nil, nil, Dirty())
  Eq(state.stacks, nil, "secret stacks are cleared")
  local noStacks = AuraFrame()
  noStacks.auraDataCached.applications = nil
  state = Apply(noStacks, nil, nil, Dirty())
  Eq(state.stacks, nil, "missing stacks are cleared")

  local timedFrame = AuraFrame()
  timedFrame.auraDataCached.timeMod = 2
  NoDuration(function()
    state = Apply(timedFrame)
    Eq(state.progressType, "timed", "timed mode without duration objects")
    Eq(state.duration, 10, "timed duration")
    Eq(state.expirationTime, timedFrame.auraDataCached.expirationTime, "timed expiration")
    Eq(state.modRate, 2, "timed mod rate")
    Eq(state.value, nil, "timed mode clears the value")
    Eq(state.total, nil, "timed mode clears the total")
    Eq(state.auraActive, true, "timed aura is active")
    local noMod = AuraFrame()
    noMod.auraDataCached.timeMod = nil
    Eq(Apply(noMod).modRate, 1, "timed mod rate defaults to one")
    local permanent = AuraFrame()
    permanent.auraDataCached.duration, permanent.auraDataCached.expirationTime = 0, 0
    Eq(Apply(permanent).auraActive, true, "permanent aura is active")
    local expired = AuraFrame()
    expired.auraDataCached.expirationTime = GetTime() - 1
    state = Apply(expired, nil, nil, Dirty())
    Eq(state.auraActive, false, "expired aura is inactive")
    Reset(state, "expired aura")
    local hiddenTimes = AuraFrame()
    hiddenTimes.auraDataCached.duration = Secret.Wrap(10)
    state = Apply(hiddenTimes)
    Eq(state.progressType, "static", "secret times without duration objects keep the state")
    Eq(state.auraActive, true, "secret times keep the aura active")
  end)

  local failingCreate = C_DurationUtil.CreateDuration
  C_DurationUtil.CreateDuration = function()
    return setmetatable({}, {__index = function() return function() error("rejected") end end})
  end
  state = Apply(AuraFrame())
  Eq(state.progressType, "timed", "rejected duration objects fall back to timed mode")
  Eq(state.duration, 10, "fallback duration")
  C_DurationUtil.CreateDuration = failingCreate

  local permanentFrame = AuraFrame()
  permanentFrame.auraDataCached.duration, permanentFrame.auraDataCached.expirationTime = 0, 0
  state = Apply(permanentFrame)
  Eq(state.auraActive, true, "permanent aura activity")
  local expiredFrame = AuraFrame()
  expiredFrame.auraDataCached.expirationTime = GetTime() - 5
  state = Apply(expiredFrame, nil, nil, Dirty())
  Eq(state.auraActive, false, "expired duration object aura is inactive")
  Reset(state, "expired duration object aura")

  local auraDurationCalls = {}
  local auraDurationObjects = {}
  Stub(C_UnitAuras, "GetAuraDuration", function(unitToken, instanceID)
    auraDurationCalls[#auraDurationCalls + 1] = {unitToken, instanceID}
    local result = auraDurationObjects[instanceID]
    if result == "error" then error("duration failed") end
    return result
  end)
  local nativeDuration = test.Units.NewDuration()
  nativeDuration:SetTimeFromStart(GetTime(), 100)
  local recordDuration = test.Units.NewDuration()
  recordDuration:SetTimeFromStart(GetTime(), 200)
  local precedence = AuraFrame({auraInstanceID = 61})
  Watch(precedence)
  precedence.Cooldown:SetCooldownFromDurationObject(recordDuration)
  Drain()
  auraDurationObjects[61] = nativeDuration
  state = Apply(precedence)
  Eq(auraDurationCalls[1][1], "player", "aura duration unit")
  Eq(auraDurationCalls[1][2], 61, "aura duration instance")
  Same(state.durationObject, nativeDuration, "native aura duration comes first")
  auraDurationObjects[61] = nil
  state = Apply(precedence)
  Same(state.durationObject, recordDuration, "native record duration comes second")
  Eq(state.progressType, "durationObject", "record duration mode")
  precedence.Cooldown:Clear()
  Drain()
  state = Apply(precedence)
  Check(state.durationObject ~= recordDuration and state.durationObject ~= nativeDuration, "aura times come third")
  Near(state.durationObject:GetRemainingDuration(), precedence.auraDataCached.expirationTime - GetTime(), "aura times remaining")
  auraDurationObjects[61] = "error"
  Check(pcall(Apply, precedence), "failing aura duration is ignored")
  auraDurationObjects[61] = {}
  state = Apply(precedence)
  Check(state.durationObject ~= auraDurationObjects[61], "non duration object is ignored")
  auraDurationObjects[61] = nativeDuration
  auraDurationCalls = {}
  local targetFrame = AuraFrame({auraInstanceID = 61, auraDataUnit = "target"})
  Apply(targetFrame)
  Eq(auraDurationCalls[1][1], "target", "aura duration of the target")
  auraDurationCalls = {}
  Apply(AuraFrame({auraInstanceID = 61, auraDataUnit = "focus"}))
  Eq(#auraDurationCalls, 0, "no aura duration for other units")
  Apply(AuraFrame({auraInstanceID = Nothing}))
  Eq(#auraDurationCalls, 0, "no aura duration without instance")
  auraDurationObjects[Secret.Wrap(62)] = nil
  Apply(AuraFrame({auraInstanceID = Secret.Wrap(62)}))
  Eq(#auraDurationCalls, 1, "secret instance asks for the aura duration")
  Apply(AuraFrame({auraInstanceID = "62"}))
  Eq(#auraDurationCalls, 1, "text instance does not ask for the aura duration")
  Unstub()
  InstallScanRecorder()
  InstallEnum()

  local pausedFrame = AuraFrame({auraInstanceID = 71})
  Watch(pausedFrame)
  state = Apply(pausedFrame)
  Eq(state.cdmNativePaused, false, "native record not paused")
  Check(type(state.cdmTextRecord) == "table", "text record of an observed frame")
  Same(Apply(pausedFrame).cdmTextRecord, state.cdmTextRecord, "text record is stable")
  pausedFrame.cooldownPaused = true
  pausedFrame:RefreshData()
  Drain()
  Eq(Apply(pausedFrame).cdmNativePaused, true, "native record paused")
  state = Apply(AuraFrame({auraInstanceID = 72}))
  Eq(state.cdmNativePaused, nil, "unobserved frame has no pause flag")
  Eq(state.cdmTextRecord, nil, "unobserved frame has no text record")

  local rawFrame = AuraFrame({auraInstanceID = 73, auraDataCached = false, auraDataUnit = "player"})
  rawFrame.auraDataCached = nil
  Watch(rawFrame)
  local firstStart = GetTime() - 1
  rawFrame.Cooldown:SetCooldown(firstStart, 5, 2)
  Drain()
  state = Apply(rawFrame)
  Eq(state.progressType, "durationObject", "raw record is converted")
  Near(state.durationObject:GetRemainingDuration(), firstStart + 5 - GetTime(), "raw record remaining")
  Eq(state.auraActive, true, "instance without data is active")
  Eq(state.cdmAuraRenderUnit, "player", "render unit without data")
  Eq(state.cdmAuraRenderSpellIDs[1], rawFrame.auraSpellID, "render id without data")
  local rawStartTime = GetTime() - 1
  C_DurationUtil.CreateDuration = function()
    return setmetatable({}, {__index = function() return function() error("rejected") end end})
  end
  rawFrame.Cooldown:SetCooldown(rawStartTime, 5, 2)
  Drain()
  state = Apply(rawFrame)
  C_DurationUtil.CreateDuration = failingCreate
  Eq(state.progressType, "timed", "unconvertible raw record is timed")
  Eq(state.duration, 5, "raw record duration")
  Near(state.expirationTime, rawStartTime + 5, "raw record expiration")
  Eq(state.modRate, 2, "raw record mod rate")
  rawFrame.Cooldown:SetCooldown(rawStartTime, 5)
  C_DurationUtil.CreateDuration = function()
    return setmetatable({}, {__index = function() return function() error("rejected") end end})
  end
  state = Apply(rawFrame)
  C_DurationUtil.CreateDuration = failingCreate
  Eq(state.modRate, 1, "raw record mod rate defaults to one")
  Drain()

  local function SourceFrame(options)
    local frame = AuraFrame()
    local countdown = options.countdown
    if countdown then
      frame.Cooldown.GetCountdownFontString = function() return countdown end
    end
    if options.bar then frame.Bar = {Duration = options.bar} end
    if options.applications then frame.Applications = options.applications end
    if options.icon then frame.Icon = options.icon end
    return frame
  end
  local function Text(text)
    return {GetText = function() return text end}
  end
  local countdownWidget, barWidget = Text("c"), Text("b")
  state = Apply(SourceFrame({countdown = countdownWidget, bar = barWidget}))
  Same(state.cdmCountdownSource, countdownWidget, "countdown source from the cooldown")
  state = Apply(SourceFrame({bar = barWidget}))
  Same(state.cdmCountdownSource, barWidget, "countdown source from the bar")
  state = Apply(SourceFrame({}), nil, nil, {progressType = "static", value = 1, total = 1, cdmCountdownSource = {}})
  Eq(state.cdmCountdownSource, nil, "countdown source is replaced by nothing")
  local inner = Text("inner")
  local outer = Text("outer")
  outer.Applications = inner
  state = Apply(SourceFrame({applications = outer}))
  Same(state.cdmStackSource, inner, "nested stack source")
  state = Apply(SourceFrame({applications = outer, icon = {Applications = Text("icon")}}))
  Same(state.cdmStackSource, inner, "stack source beats the icon")
  state = Apply(SourceFrame({applications = outer}))
  local flat = Text("flat")
  state = Apply(SourceFrame({applications = flat}))
  Same(state.cdmStackSource, flat, "flat stack source")
  local iconApplications = Text("icon")
  state = Apply(SourceFrame({applications = {}, icon = {Applications = iconApplications}}))
  Same(state.cdmStackSource, iconApplications, "icon stack source behind an empty holder")
  state = Apply(SourceFrame({icon = {Applications = iconApplications}}))
  Same(state.cdmStackSource, iconApplications, "icon stack source")
  local keptSource = {}
  state = Apply(SourceFrame({}), nil, nil, {progressType = "static", value = 1, total = 1, cdmStackSource = keptSource})
  Same(state.cdmStackSource, keptSource, "stack source is kept when none is found")

  state = Apply(AuraFrame({auraInstanceID = Nothing, auraDataCached = Nothing}), nil, nil, Dirty())
  Eq(state.auraActive, false, "frame without aura is inactive")
  Reset(state, "frame without aura")
  Eq(state.cdmAuraRenderUnit, nil, "inactive frame has no render unit")
  state = Apply(AuraFrame({auraInstanceID = 5, auraDataCached = Nothing, isActive = Nothing}))
  Eq(state.auraActive, true, "instance without data is active")
  state = Apply(AuraFrame({auraInstanceID = Secret.Wrap(5), auraDataCached = Nothing, isActive = Nothing}))
  Eq(state.auraActive, nil, "secret instance leaves activity unknown")
  state = Apply(AuraFrame({auraInstanceID = Nothing, isActive = Nothing}))
  Eq(state.auraActive, true, "cached aura without instance is active")

  state = Apply(AuraFrame({isActive = false}), nil, nil, Dirty())
  Eq(state.auraActive, false, "inactive flag")
  Reset(state, "inactive flag")
  state = Apply(AuraFrame({isActive = Secret.Wrap(true)}))
  Eq(state.auraActive, nil, "secret flag leaves activity unknown")
  state = Apply(AuraFrame({isActive = "yes"}))
  Eq(state.auraActive, true, "non boolean flag is ignored")
  state = Apply(AuraFrame({isActive = true, auraInstanceID = Nothing, auraDataCached = Nothing}))
  Eq(state.auraActive, false, "flag does not revive an absent aura")

  local exact = AuraFrame()
  state = Apply(exact, exact.auraSpellID)
  Eq(state.auraActive, true, "exact id match")
  Eq(state.cdmAuraRenderSpellIDs[1], exact.auraSpellID, "exact id render spell")
  Check(state.cdmCountdownSource == nil and state.cdmTextRecord == nil, "exact id match without widgets")
  state = Apply(exact, exact.auraSpellID + 1, nil, Dirty())
  Eq(state.auraActive, false, "exact id mismatch is inactive")
  Reset(state, "exact id mismatch")
  Eq(state.cdmAuraRenderUnit, nil, "exact id mismatch has no render unit")
  local mismatchWidgets = SourceFrame({countdown = countdownWidget})
  state = Apply(mismatchWidgets, mismatchWidgets.auraSpellID + 1)
  Eq(state.cdmCountdownSource, nil, "exact id mismatch captures no widget")
  Eq(state.stacks, nil, "exact id mismatch takes no stacks")
  local idleExact = AuraFrame({isActive = Nothing})
  state = Apply(idleExact, idleExact.auraSpellID + 1)
  Eq(state.auraActive, nil, "exact id mismatch alone leaves activity unknown")
  Eq(state.progressType, "static", "exact id mismatch alone keeps the state")
  Eq(state.stacks, nil, "exact id mismatch alone takes no aura")
  local fromAura = AuraFrame({auraSpellID = Secret.Wrap(1)})
  state = Apply(fromAura, fromAura.auraDataCached.spellId)
  Eq(state.auraActive, true, "exact id from the cached aura")
  fromAura = AuraFrame({auraSpellID = Secret.Wrap(1)})
  state = Apply(fromAura, fromAura.auraDataCached.spellId + 1)
  Eq(state.auraActive, false, "exact id mismatch from the cached aura")
  local expandedFrame = AuraFrame({auraSpellID = 324})
  expandedFrame.auraDataCached.spellId = 324
  state = Apply(expandedFrame, 324)
  Eq(table.concat(state.cdmAuraRenderSpellIDs, ","), "324", "exact id render ids are not expanded")
  state = Apply(AuraFrame({auraSpellID = 324}))
  Eq(table.concat(state.cdmAuraRenderSpellIDs, ","), "324,325,905,945,8134,10431,10432", "render ids are expanded with ranks")
  nextSpell = nextSpell + 1
  state = Apply(AuraFrame({auraSpellID = Secret.Wrap(1), auraDataCached = {spellId = 324, duration = 10, expirationTime = GetTime() + 10, applications = 1}}))
  Eq(table.concat(state.cdmAuraRenderSpellIDs, ","), "324,325,905,945,8134,10431,10432", "render ids from the cached aura")
  state = Apply(AuraFrame({auraSpellID = Secret.Wrap(1), auraDataCached = {spellId = Secret.Wrap(1), duration = 10, expirationTime = GetTime() + 10, applications = 1}}), nil, {324, 325, 700100})
  Eq(table.concat(state.cdmAuraRenderSpellIDs, ","), "324,325,905,945,8134,10431,10432,700100", "buff spell ids are expanded without duplicates")
  state = Apply(AuraFrame({auraSpellID = Secret.Wrap(1), auraDataCached = {spellId = Secret.Wrap(1), duration = 10, expirationTime = GetTime() + 10, applications = 1}}), nil, nil)
  Eq(state.cdmAuraRenderSpellIDs, nil, "no render ids without any spell")
  local anyFrame = AuraFrame({auraSpellID = Secret.Wrap(1), auraDataCached = {spellId = Secret.Wrap(1), duration = 10, expirationTime = GetTime() + 10, applications = 1}})
  anyFrame.auraDataUnit = "target"
  state = Apply(anyFrame, nil, {700101})
  Eq(state.cdmAuraRenderUnit, "target", "target render unit")
  Eq(state.cdmAuraRenderSpellIDs[1], 700101, "target render ids")
  anyFrame.auraDataUnit = "focus"
  state = Apply(anyFrame, nil, {700101})
  Eq(state.cdmAuraRenderUnit, nil, "other unit has no render unit")
  Eq(state.cdmAuraRenderSpellIDs, nil, "other unit has no render ids")

  local lookups, lookupResults = {}, {}
  Stub(C_UnitAuras, "GetPlayerAuraBySpellID", function(spellID)
    lookups[#lookups + 1] = spellID
    local result = lookupResults[spellID]
    if result == "error" then error("lookup failed") end
    return result
  end)
  local function Found(spellID, mine, applications)
    return {
      spellId = spellID, isFromPlayerOrPlayerPet = mine, duration = 20, expirationTime = GetTime() + 20,
      applications = applications or 6, timeMod = 1,
    }
  end
  local hidden = {auraSpellID = Secret.Wrap(1), auraDataCached = {spellId = Secret.Wrap(1), duration = Secret.Wrap(10),
    expirationTime = Secret.Wrap(GetTime() + 10), applications = Secret.Wrap(2), timeMod = Secret.Wrap(1)}}
  local function HiddenFrame()
    local frame = AuraFrame({auraSpellID = Secret.Wrap(1)})
    frame.auraDataCached = {spellId = Secret.Wrap(1), duration = Secret.Wrap(10),
      expirationTime = Secret.Wrap(GetTime() + 10), applications = Secret.Wrap(2), timeMod = Secret.Wrap(1)}
    return frame
  end
  nextSpell = nextSpell + 1
  local lookedUp = nextSpell
  lookupResults[lookedUp] = Found(lookedUp, true, 6)
  state = Apply(HiddenFrame(), lookedUp)
  Eq(lookups[1], lookedUp, "exact id looked up on the player")
  Eq(state.auraActive, true, "looked up aura matches")
  Eq(state.stacks, 6, "looked up aura replaces the cached one")
  lookupResults[lookedUp] = Found(lookedUp, false)
  state = Apply(HiddenFrame(), lookedUp)
  Check(state.auraActive ~= true, "aura of another source does not match")
  lookupResults[lookedUp] = "error"
  Check(pcall(Apply, HiddenFrame(), lookedUp), "failing lookup is ignored")
  state = Apply(HiddenFrame(), lookedUp)
  Check(state.auraActive ~= true, "failing lookup does not match")
  lookupResults[lookedUp] = nil
  state = Apply(HiddenFrame(), lookedUp)
  Check(state.auraActive ~= true, "missing aura does not match")
  lookups = {}
  lookupResults[lookedUp] = Found(lookedUp, true)
  local targetLookup = HiddenFrame()
  targetLookup.auraDataUnit = "target"
  state = Apply(targetLookup, lookedUp)
  Eq(#lookups, 0, "no player lookup for the target")
  Check(state.auraActive ~= true, "target aura is not matched by player lookups")
  Stub(C_UnitAuras, "GetPlayerAuraBySpellID", nil)
  Check(pcall(Apply, HiddenFrame(), lookedUp), "no lookup API")
  Stub(C_UnitAuras, "GetPlayerAuraBySpellID", function(spellID)
    lookups[#lookups + 1] = spellID
    return lookupResults[spellID]
  end)

  nextSpell = nextSpell + 1
  local ranked = nextSpell
  local rankFrame = AuraFrame({auraSpellID = ranked})
  rankFrame.auraDataCached.spellId = ranked
  Apply(rankFrame, ranked)
  rankFrame.auraSpellID = Secret.Wrap(ranked)
  rankFrame.auraDataCached = {spellId = Secret.Wrap(ranked), duration = Secret.Wrap(10),
    expirationTime = Secret.Wrap(GetTime() + 10), applications = Secret.Wrap(1), timeMod = Secret.Wrap(1)}
  lookups = {}
  lookupResults = {}
  test.Units.SetCombat(true)
  Check(WeakAuras.IsRestricted(), "restricted in combat")
  state = Apply(rankFrame, ranked)
  Eq(state.auraActive, true, "remembered spell matches in combat")
  Eq(#lookups, 0, "no player lookup in combat")
  state = Apply(rankFrame, ranked + 1)
  Check(state.auraActive ~= true, "another spell does not match in combat")
  local forgotten = AuraFrame({auraSpellID = Secret.Wrap(ranked)})
  forgotten.auraDataCached = {spellId = Secret.Wrap(ranked), duration = Secret.Wrap(10),
    expirationTime = Secret.Wrap(GetTime() + 10), applications = Secret.Wrap(1), timeMod = Secret.Wrap(1)}
  state = Apply(forgotten, ranked)
  Check(state.auraActive ~= true, "unseen frame has nothing to remember in combat")
  test.Units.SetCombat(false)
  Drain()

  nextSpell = nextSpell + 1
  local fallbackSpell = nextSpell
  lookupResults = {
    [fallbackSpell + 1] = "error", [fallbackSpell + 2] = Found(fallbackSpell + 2, false),
    [fallbackSpell + 3] = Found(fallbackSpell + 3, true, 8), [fallbackSpell + 4] = Found(fallbackSpell + 4, true, 9),
  }
  local function FallbackFrame(unitToken)
    local frame = AuraFrame({auraSpellID = Secret.Wrap(1), auraDataUnit = unitToken})
    frame.auraDataCached = nil
    frame.auraInstanceID = 5
    frame.isActive = nil
    return frame
  end
  lookups = {}
  local ids = {fallbackSpell, fallbackSpell + 1, fallbackSpell + 2, fallbackSpell + 3, fallbackSpell + 4}
  state = Apply(FallbackFrame("player"), nil, ids)
  Eq(table.concat(lookups, ","), table.concat({fallbackSpell, fallbackSpell + 1, fallbackSpell + 2, fallbackSpell + 3}, ","),
    "fallback lookups stop at the first player aura")
  Eq(state.stacks, 8, "fallback aura timing")
  Eq(state.progressType, "durationObject", "fallback aura duration")
  lookups = {}
  state = Apply(FallbackFrame("target"), nil, ids)
  Eq(#lookups, 0, "no fallback lookup for the target")
  lookups = {}
  test.Units.SetCombat(true)
  Apply(FallbackFrame("player"), nil, ids)
  Eq(#lookups, 0, "no fallback lookup in combat")
  test.Units.SetCombat(false)
  Drain()
  lookups = {}
  Stub(C_UnitAuras, "GetAuraDuration", function() return nativeDuration end)
  Apply(FallbackFrame("player"), nil, ids)
  Eq(#lookups, 0, "no fallback lookup with a native duration")
  Unstub()
  InstallScanRecorder()
  InstallEnum()
  Stub(C_UnitAuras, "GetPlayerAuraBySpellID", nil)

  local castCount = 0
  local function CastGuid()
    castCount = castCount + 1
    return "Cast-" .. castCount
  end
  local function SelfCast(spellID, target)
    local guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", target or "", guid, spellID)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, spellID)
    return guid
  end
  local function KeptFrame(spellID, total, timeMod)
    local frame = AuraFrame({auraSpellID = spellID})
    frame.auraDataCached = {
      spellId = spellID, duration = total, expirationTime = GetTime() + total, applications = 1, timeMod = timeMod or 1,
    }
    return frame
  end
  local function Restore(frame)
    frame.auraDataCached = {
      spellId = frame.auraSpellID, duration = Secret.Wrap(100), expirationTime = GetTime() + 100,
      applications = 1, timeMod = 1,
    }
    return Apply(frame)
  end

  NoDuration(function()
    local mark = KeptFrame(14323, 100, 2)
    local first = Apply(mark)
    Eq(first.progressType, "timed", "kept frame is timed")
    local firstExpiration = first.expirationTime
    local restored = Restore(mark)
    Eq(restored.progressType, "timed", "static state is restored from the kept timing")
    Eq(restored.expirationTime, firstExpiration, "restored expiration")
    Eq(restored.duration, 100, "restored duration")
    Eq(restored.modRate, 2, "restored mod rate")
    Eq(restored.value, nil, "restored value")
    Eq(restored.total, nil, "restored total")
    Eq(restored.auraActive, true, "restored aura is active")
    Drain()

    local function Untouched(label)
      Eq(Drain(), 0, label .. " does not refresh")
      Eq(Restore(mark).expirationTime, firstExpiration, label .. " keeps the timing")
    end
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", CastGuid(), 14324)
    Untouched("cast without a sent event")
    SelfCast(14324, "Somebody")
    Untouched("cast on another target")
    local guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", Secret.Wrap(""), guid, 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14324)
    Untouched("secret target")
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", Secret.Wrap("g"), 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", Secret.Wrap("g"), 14324)
    Untouched("secret cast guid")
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", nil, 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", nil, 14324)
    Untouched("missing cast guid")
    for _, ending in ipairs({"UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED"}) do
      guid = CastGuid()
      test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", guid, 14324)
      test.Units.fire(ending, "player", guid, 14324)
      test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14324)
      Untouched(ending)
    end
    guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", guid, 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, Secret.Wrap(14324))
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14324)
    Untouched("secret cast spell")
    guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", guid, 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, nil)
    Untouched("missing cast spell")
    SelfCast(17)
    Untouched("cast of an unrelated spell")
    guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "target", "", guid, 14324)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14324)
    Untouched("sent event of another unit")

    local before = GetTime()
    SelfCast(14324)
    Eq(Drain(), 1, "self cast restarts the kept timing and refreshes")
    restored = Restore(mark)
    Eq(restored.progressType, "timed", "restarted timing is timed")
    Near(restored.expirationTime, before + 100 * 2, "restart uses total duration times the mod rate")
    Eq(restored.duration, 100, "restart keeps the duration")
    Eq(restored.modRate, 2, "restart keeps the mod rate")

    test.Environment.Advance(5)
    before = GetTime()
    SelfCast(14323, UnitName("player"))
    Eq(Drain(), 1, "cast on the player name restarts")
    Near(Restore(mark).expirationTime, before + 200, "restart on the player name")

    test.Environment.Advance(5)
    before = GetTime()
    guid = CastGuid()
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", nil, guid, 14325)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14325)
    Eq(Drain(), 1, "cast without a target restarts")
    Near(Restore(mark).expirationTime, before + 200, "restart without a target")
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, 14325)
    Eq(Drain(), 0, "a cast restarts only once")

    local plainRate = KeptFrame(1130, 50, 1)
    Apply(plainRate)
    before = GetTime()
    SelfCast(1130)
    Eq(Drain(), 1, "plain rate restart refreshes")
    Near(Restore(plainRate).expirationTime, before + 50, "restart with a unit mod rate")

    local permanent = KeptFrame(1277324, 0, 1)
    permanent.auraDataCached.expirationTime = 0
    Apply(permanent)
    SelfCast(1277325)
    Eq(Drain(), 0, "permanent timing is not restarted")

    local expiring = KeptFrame(13795, 5, 1)
    Apply(expiring)
    test.Environment.Advance(6)
    local lapsed = Restore(expiring)
    Eq(lapsed.progressType, "static", "expired kept timing is not restored")
    Eq(lapsed.auraActive, true, "expired kept timing keeps the aura active")
    local otherCooldown = KeptFrame(1499, 100, 1)
    Apply(otherCooldown)
    otherCooldown.cooldownID = 424242
    Eq(Restore(otherCooldown).progressType, "static", "another cooldown id drops the kept timing")
    local inactive = KeptFrame(1495, 100, 1)
    Apply(inactive)
    inactive.isActive = false
    Apply(inactive)
    inactive.isActive = true
    Eq(Restore(inactive).progressType, "static", "inactive aura drops the kept timing")
    local onTarget = KeptFrame(14269, 100, 1)
    onTarget.auraDataUnit = "target"
    Apply(onTarget)
    Eq(Restore(onTarget).progressType, "static", "target aura keeps no timing")
    local reappearing = KeptFrame(14270, 100, 1)
    Apply(reappearing)
    Restore(reappearing)
    reappearing.auraDataCached = nil
    reappearing.auraInstanceID = nil
    local gone = Apply(reappearing, nil, nil, Dirty())
    Eq(gone.auraActive, false, "vanished aura is inactive")
    Reset(gone, "vanished aura")
    reappearing.auraInstanceID = 5
    reappearing.isActive = true
    Eq(Restore(reappearing).progressType, "static", "vanished aura loses its kept timing")
  end)

  do
    local object = KeptFrame(7328, 100, 1)
    local first = Apply(object)
    Eq(first.progressType, "durationObject", "kept frame uses a duration object")
    local original = first.durationObject
    local before = GetTime()
    SelfCast(10322)
    Eq(Drain(), 1, "duration object restart refreshes")
    NoDuration(function()
      local restored = Restore(object)
      Eq(restored.progressType, "durationObject", "restarted duration object is restored")
      Check(restored.durationObject ~= original, "restart builds a new duration object")
      Check(private.IsDurationObject(restored.durationObject), "restarted duration object")
      Near(restored.durationObject:GetRemainingDuration(), before + 100 - GetTime(), "restarted remaining")
      Near(restored.durationObject:GetTotalDuration(), 100, "restarted total")
    end)
  end

  do
    local unavailable = KeptFrame(1293241, 100, 1)
    local original = Apply(unavailable).durationObject
    Stub(C_DurationUtil, "CreateDuration", nil)
    SelfCast(1293525)
    Eq(Drain(), 0, "no duration factory gives no restart")
    Unstub()
    InstallScanRecorder()
    InstallEnum()
    NoDuration(function()
      Same(Restore(unavailable).durationObject, original, "no duration factory keeps the original object")
    end)
    local rejected = KeptFrame(14302, 100, 1)
    original = Apply(rejected).durationObject
    local factory = C_DurationUtil.CreateDuration
    C_DurationUtil.CreateDuration = function()
      return setmetatable({}, {__index = function() return function() error("rejected") end end})
    end
    SelfCast(14303)
    Eq(Drain(), 0, "rejected restart gives no refresh")
    C_DurationUtil.CreateDuration = factory
    NoDuration(function()
      Same(Restore(rejected).durationObject, original, "rejected restart keeps the original object")
    end)
  end

  local function Destination()
    local destination = {text = "unset"}
    function destination:SetText(text) self.text = text end
    return destination
  end
  local function Copy(state, kind)
    local destination = Destination()
    private.CopyCDMCountdownText(destination, state, kind)
    return destination.text
  end

  local function Kind(value)
    local kind, index = private.ParseCDMText(value)
    return tostring(kind) .. ":" .. tostring(index)
  end
  for _, token in ipairs({"bp", "bs", "p", "s", "caster", "dispel"}) do
    Eq(Kind("%" .. token), token .. ":nil", "short token " .. token)
    Eq(Kind("%{" .. token .. "}"), token .. ":nil", "braced token " .. token)
    Eq(Kind("%2." .. token), token .. ":2", "indexed token " .. token)
    Eq(Kind("%{12." .. token .. "}"), token .. ":12", "braced indexed token " .. token)
  end
  for _, value in ipairs({"p", "%x", "%", "%{}", "%{p", "p}", "%p ", " %p", "%{p}x", "%.p", "%a.p", "%2.x", "%2.", "%2p", "%{bp.1}", "%P"}) do
    Eq(Kind(value), "nil:nil", "not a token " .. value)
  end
  Eq(Kind(nil), "nil:nil", "nil is not a token")
  Eq(Kind(5), "nil:nil", "number is not a token")
  Eq(Kind({}), "nil:nil", "table is not a token")

  local function Data(types, extra)
    local data = {triggers = {}}
    for index, entry in ipairs(types) do
      data.triggers[index] = {trigger = {type = entry[1], event = entry[2]}}
    end
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local buffTrigger = {"cdm", "Blizzard CDM Buff"}
  local spellTrigger = {"cdm", "Blizzard CDM Spell"}
  local otherTrigger = {"aura2", "Blizzard CDM Buff"}
  Eq(private.IsCDMBuffText("%bp"), true, "bp is a buff text without data")
  Eq(private.IsCDMBuffText("%bs"), true, "bs is a buff text without data")
  Eq(private.IsCDMBuffText("%{bs}", Data({spellTrigger})), true, "bs is a buff text with a spell trigger")
  Eq(private.IsCDMBuffText("text"), false, "plain text is not a buff text")
  Eq(private.IsCDMBuffText(nil), false, "nil is not a buff text")
  Eq(private.IsCDMBuffText("%p"), false, "p without data")
  Eq(private.IsCDMBuffText("%p", {}), false, "p without triggers")
  Eq(private.IsCDMBuffText("%p", Data({buffTrigger})), true, "p with the single buff trigger")
  Eq(private.IsCDMBuffText("%{s}", Data({buffTrigger})), true, "s with the single buff trigger")
  Eq(private.IsCDMBuffText("%caster", Data({buffTrigger})), true, "caster with the single buff trigger")
  Eq(private.IsCDMBuffText("%dispel", Data({buffTrigger})), true, "dispel with the single buff trigger")
  Eq(private.IsCDMBuffText("%p", Data({spellTrigger})), false, "p with a spell trigger")
  Eq(private.IsCDMBuffText("%p", Data({otherTrigger})), false, "p with another trigger type")
  Eq(private.IsCDMBuffText("%p", Data({{"cdm", "Other"}})), false, "p with another cdm event")
  Eq(private.IsCDMBuffText("%p", Data({buffTrigger, spellTrigger})), false, "p with several triggers and no source")
  Eq(private.IsCDMBuffText("%1.p", Data({buffTrigger, spellTrigger})), true, "indexed p on a buff trigger")
  Eq(private.IsCDMBuffText("%2.p", Data({buffTrigger, spellTrigger})), false, "indexed p on a spell trigger")
  Eq(private.IsCDMBuffText("%3.p", Data({buffTrigger, spellTrigger})), false, "indexed p past the triggers")
  Eq(private.IsCDMBuffText("%1.p", Data({spellTrigger, buffTrigger})), false, "index decides over the order")
  Eq(private.IsCDMBuffText("%2.bp", Data({spellTrigger})), true, "bp ignores the index")
  Eq(private.IsCDMBuffText("%p", Data({spellTrigger, buffTrigger}, {progressSource = {2}})), true, "progress source picks the trigger")
  Eq(private.IsCDMBuffText("%p", Data({buffTrigger, spellTrigger}, {progressSource = {2}})), false, "progress source picks a spell trigger")
  Eq(private.IsCDMBuffText("%p", Data({buffTrigger}, {progressSource = {0}})), false, "progress source zero disables the buff text")
  Eq(private.IsCDMBuffText("%p", Data({spellTrigger, buffTrigger}, {progressSource = {-1}, triggers = nil})), false, "no triggers with a source")
  local modeData = Data({spellTrigger, buffTrigger})
  modeData.triggers.activeTriggerMode = 2
  Eq(private.IsCDMBuffText("%p", modeData), true, "active trigger mode picks the trigger")
  modeData.triggers.activeTriggerMode = 1
  Eq(private.IsCDMBuffText("%p", modeData), false, "active trigger mode picks a spell trigger")
  modeData.triggers.activeTriggerMode = -1
  Eq(private.IsCDMBuffText("%p", modeData), false, "negative trigger mode finds nothing")
  local sourceFirst = Data({buffTrigger, spellTrigger}, {progressSource = {1}})
  sourceFirst.triggers.activeTriggerMode = 2
  Eq(private.IsCDMBuffText("%p", sourceFirst), true, "progress source beats the trigger mode")
  Eq(private.IsCDMBuffText("%p", {triggers = {{trigger = "text"}}}), false, "malformed trigger")
  Eq(private.IsCDMBuffText("%p", {triggers = {{}}}), false, "trigger without data")

  Eq(Copy(nil, "caster"), "", "caster text is empty")
  Eq(Copy({show = true, cdmDispelName = "Magic"}, "dispel"), "Magic", "dispel text")
  Eq(Copy({show = false, cdmDispelName = "Magic"}, "dispel"), "", "hidden dispel text")
  Eq(Copy({show = true}, "dispel"), "", "missing dispel text")
  Eq(Copy(nil, "dispel"), "", "dispel text without state")
  Eq(Copy({show = true, cdmDispelName = ""}, "dispel"), "", "empty dispel text")

  local formatted = {}
  Stub(private, "FormatDurationText", function(...)
    formatted[#formatted + 1] = {...}
    return "FMT"
  end)
  local liveDuration = test.Units.NewDuration()
  liveDuration:SetTimeFromStart(GetTime(), 30)
  local buffState = {show = true, cdmBuff = true, durationObject = liveDuration}
  Eq(Copy(buffState, "p"), "FMT", "buff countdown is formatted from the duration object")
  Eq(#formatted, 1, "duration text formatted once")
  Same(formatted[1][1], liveDuration, "formatted duration object")
  Eq(formatted[1][2], false, "formatted total flag")
  Eq(formatted[1][3], 99, "formatted format")
  Eq(formatted[1][4], 0, "formatted threshold")
  Eq(formatted[1][5], 0, "formatted precision")
  Eq(Copy(buffState, "bp"), "FMT", "bp is formatted from the duration object")
  formatted = {}
  Check(Copy({show = true, cdmBuff = true, durationObject = liveDuration, cdmTextPreview = true}, "p") ~= "FMT", "preview is not formatted")
  Check(Copy({show = true, durationObject = liveDuration}, "p") ~= "FMT", "spell countdown is not formatted")
  Check(Copy({show = false, cdmBuff = true, durationObject = liveDuration}, "p") ~= "FMT", "hidden state is not formatted")
  Check(Copy({show = true, cdmBuff = true, durationObject = {}}, "p") ~= "FMT", "fake duration object is not formatted")
  Check(Copy(buffState, "bs") ~= "FMT", "stack text is not formatted")
  Check(Copy(buffState, "s") ~= "FMT", "s text is not formatted")
  Eq(#formatted, 0, "nothing else is formatted")
  Unstub()
  InstallScanRecorder()
  InstallEnum()

  local function Source(text, shown, forbidden)
    local source = {}
    function source:GetText() return text end
    if shown ~= nil then function source:IsShown() return shown end end
    if forbidden ~= nil then function source:IsForbidden() return forbidden end end
    return source
  end
  Eq(Copy({show = true, cdmCountdownSource = Source("12")}, "p"), "12", "countdown source text")
  Eq(Copy({show = true, cdmStackSource = Source("4")}, "bs"), "4", "stack source text")
  Eq(Copy({show = true, cdmStackSource = Source("4")}, "s"), "4", "s reads the stack source")
  Eq(Copy({show = true, cdmCountdownSource = Source("12"), cdmStackSource = Source("4")}, "bs"), "4", "bs ignores the countdown source")
  Eq(Copy({show = true, cdmCountdownSource = Source("12"), cdmStackSource = Source("4")}, "p"), "12", "p ignores the stack source")
  Eq(Copy({show = false, cdmCountdownSource = Source("12")}, "p"), "", "hidden state has no source text")
  Eq(Copy({cdmCountdownSource = Source("12")}, "p"), "", "state without show has no source text")
  Eq(Copy(nil, "p"), "", "no state")
  Eq(Copy(nil, "bs"), "", "no state for stacks")
  Eq(Copy({show = true, cdmCountdownSource = Source("12", true, true)}, "p"), "", "forbidden source")
  Eq(Copy({show = true, cdmCountdownSource = Source("12", false, false)}, "p"), "12", "hidden source of a spell countdown is read")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("12", false)}, "p"), "", "hidden buff countdown source")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("12", true)}, "p"), "12", "shown buff countdown source")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("12", Secret.Wrap(false))}, "p"), "12", "secret shown flag is ignored")
  Eq(Copy({show = true, cdmStackSource = Source("4", false)}, "bs"), "", "hidden stack source")
  Eq(Copy({show = true, cdmStackSource = Source("4", true)}, "bs"), "4", "shown stack source")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("0")}, "p"), "", "zero buff countdown is empty")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("0.0")}, "p"), "", "zero decimal buff countdown is empty")
  Eq(Copy({show = true, cdmCountdownSource = Source("0")}, "p"), "0", "zero spell countdown is kept")
  Eq(Copy({show = true, cdmBuff = true, cdmStackSource = Source("0")}, "bs"), "0", "zero stacks are kept")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("1")}, "p"), "1", "one buff countdown is kept")
  Eq(Copy({show = true, cdmBuff = true, cdmCountdownSource = Source("abc")}, "p"), "abc", "text buff countdown is kept")
  Eq(Copy({show = true, cdmCountdownSource = Source(nil)}, "p"), nil, "missing source text passes through")
  local secretText = Secret.Wrap("0")
  local secretDestination = Destination()
  private.CopyCDMCountdownText(secretDestination, {show = true, cdmBuff = true, cdmCountdownSource = Source(secretText)}, "p")
  Check(Secret.IsSecret(secretDestination.text), "secret countdown text passes through")
  Same(Secret.Reveal(secretDestination.text), "0", "secret countdown text keeps its value")

  Eq(Copy({show = true, cdmTextPreview = true}, "bs"), "3", "stack preview")
  Eq(Copy({show = true, cdmTextPreview = true}, "s"), "3", "s preview")
  Eq(Copy({show = true, cdmTextPreview = true}, "p"), "6", "countdown preview without expiration")
  Eq(Copy({show = true, cdmTextPreview = true, expirationTime = GetTime() + 4.2}, "p"), "5", "countdown preview rounds up")
  Eq(Copy({show = true, cdmTextPreview = true, expirationTime = GetTime() + 4}, "bp"), "4", "bp preview")
  Eq(Copy({show = true, cdmTextPreview = true, expirationTime = GetTime() - 3}, "p"), "0", "expired preview is zero")
  Eq(Copy({show = false, cdmTextPreview = true}, "p"), "", "hidden preview")
  Eq(Copy({show = true, cdmTextPreview = true, cdmBuff = true, durationObject = liveDuration}, "p"), "6", "buff preview skips the formatter")
  Eq(Copy({show = true, cdmTextPreview = true, cdmCountdownSource = Source("12")}, "p"), "12", "source beats the preview")
  Eq(Copy({show = true}, "p"), "", "no source and no preview")
  Eq(Copy({show = true}, "bs"), "", "no stack source and no preview")
  Eq(Copy({show = true}, "unknown"), "", "unknown kind")
  Unstub()
end

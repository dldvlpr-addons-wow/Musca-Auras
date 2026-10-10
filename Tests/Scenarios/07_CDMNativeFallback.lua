return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.CDMAuraProgress

  local realRegion = private.regionTypes.aurabar.create(CreateFrame("Frame"))
  local realBar = realRegion.bar
  local cdmBar = realBar:GetNativeBar("cdm")
  local denied = {}
  for _, name in ipairs({"SetOrientation", "SetReverseFill", "GetStatusBarTexture", "Show", "Hide", "SetMinMaxValues", "SetValue"}) do
    local original = cdmBar[name]
    cdmBar[name] = function(...)
      if WeakAuras.IsRestricted() then denied[#denied + 1] = name error("forbidden " .. name) end
      return original(...)
    end
  end

  local cdmTexture = cdmBar:GetStatusBarTexture()
  local originalSetPoint = realBar.fgMask.SetPoint
  realBar.fgMask.SetPoint = function(self, point, relative, ...)
    if relative == cdmBar or relative == cdmTexture then
      error("Anchoring disallowed as dependent object would inherit forbidden aspects: UntrustedLayoutScriptExecution")
    end
    return originalSetPoint(self, point, relative, ...)
  end

  local calls = {}
  local function Fake(kind)
    local object = {kind = kind}
    return setmetatable(object, { __index = function(_, name)
      if name == "GetStatusBarTexture" then return function() return Fake("texture") end end
      if name == "GetFrameLevel" then return function() return 1 end end
      if name == "IsVisible" then return function() return true end end
      if not name:match("^%u") then return nil end
      return function(self, ...) calls[#calls + 1] = {self.kind, name, ...} end
    end })
  end
  local function Count(kind, name)
    local count = 0
    for _, call in ipairs(calls) do
      if call[1] == kind and call[2] == name then count = count + 1 end
    end
    return count
  end

  local realCreateFrame = CreateFrame
  local savedPolicy, savedEnum = CustomAuraContainerAuraProcessingPolicy, Enum.StatusBarTimerDirection
  CustomAuraContainerAuraProcessingPolicy = nil
  local realC_AddOns = C_AddOns
  local loadCalls = 0
  C_AddOns = setmetatable({
    IsAddOnLoaded = function() return CustomAuraContainerAuraProcessingPolicy ~= nil end,
    LoadAddOn = function()
      loadCalls = loadCalls + 1
      CustomAuraContainerAuraProcessingPolicy = {None = 0}
      return true
    end,
  }, { __index = realC_AddOns })
  Enum.StatusBarTimerDirection = {ElapsedTime = 1, RemainingTime = 2}
  CreateFrame = function(frameType)
    local frame = Fake(frameType)
    if frameType == "AuraContainer" then
      frame.AddAuraSlot = function(self, _, _, options)
        options.initializeFrame(Fake("button"))
      end
    end
    return frame
  end

  local function NewRegion(regionType, data)
    local region = Fake(regionType)
    region.regionType, region.icon, region.cooldown = regionType, Fake("icon"), Fake("cooldown")
    region.bar = Fake("bar")
    region.bar.ShowNativeBar = function(self, nativeBar)
      calls[#calls + 1] = {"bar", "ShowNativeBar"}
      self.nativeBar = nativeBar
    end
    if regionType == "aurabar" then region.cooldown = nil end
    region.state = {
      cdmBuff = true, show = true, progressType = "static", cdmAuraRenderUnit = "target",
      cdmAuraFilter = "HARMFUL|PLAYER", cdmAuraRenderSpellIDs = {8050},
    }
    region.GetFrameLevel = function() return 1 end
    region.HookScript = function() end
    Display.Modify(region, data)
    return region
  end

  local data = {
    regionType = "icon", uid = "u1", cooldown = true,
    triggers = { { trigger = { type = "cdm", event = "Blizzard CDM Buff" } } },
  }

  local ownBuff = {
    cdmBuff = true, show = true, progressType = "static", cdmAuraRenderUnit = "player",
    cdmAuraFilter = "HELPFUL", cdmAuraRenderSpellIDs = {324},
  }
  assert(not Display.ResolveNativeSource(ownBuff), "own buff native source out of combat")
  assert(Display.ResolveNativeSource(ownBuff) == nil)

  local icon = NewRegion("icon", data)
  assert(loadCalls == 1, "Blizzard_AuraContainer not loaded before pre-creation")
  assert(icon.cdmAuraTimer, "icon container not prepared out of combat")
  local bar = NewRegion("aurabar", data)
  assert(bar.cdmAuraTimer and bar.bar.nativeBars and bar.bar.nativeBars.cdm, "bar container not prepared")
  assert(Count("button", "SetDurationBar") == 1, "bar not bound to the button")

  calls = {}
  Display.Update(bar)
  assert(bar.cdmNativeProgress and Count("bar", "ShowNativeBar") == 1, "bar native not shown out of combat")

  local freshBar = NewRegion("aurabar", data)
  assert(freshBar.bar.nativeBar == freshBar.cdmAuraTimer.statusBar, "bar native not shown when built out of combat")
  test.Units.SetCombat(true)
  calls = {}
  Display.Update(freshBar)
  assert(freshBar.cdmNativeProgress, "prepared bar not native in combat")
  freshBar.bar.nativeBar = nil
  Display.Update(freshBar)
  assert(freshBar.cdmNativeProgress and freshBar.bar.nativeBar == freshBar.cdmAuraTimer.statusBar,
    "bar not selected as native in combat")
  assert(Display.ResolveNativeSource(ownBuff) == "player", "own buff native source in combat")
  ownBuff.progressType = "durationObject"
  assert(not Display.ResolveNativeSource(ownBuff), "timed state must not use native")
  ownBuff.progressType = "static"

  calls = {}
  Display.Update(icon)
  assert(icon.cdmNativeProgress and Count("AuraContainer", "SetUnit") == 1, "icon native not attached in combat")
  Display.Update(bar)
  assert(bar.cdmNativeProgress, "bar native dropped in combat")

  icon.state = ownBuff
  Display.Update(icon)
  assert(icon.cdmNativeProgress, "first-cast own buff not native")

  local lazy = NewRegion("icon", data)
  lazy.cdmAuraTimer = nil
  Display.Update(lazy)
  assert(not lazy.cdmNativeProgress and not lazy.cdmAuraTimer, "container must not be created in combat")

  test.Units.SetCombat(false)
  local pool = {}
  local function Create() return NewRegion("icon", data) end
  Display.AddSpareClone(pool, "icon", data, Create)
  assert(#pool == 1 and pool[1].cdmAuraTimer, "spare clone with container not prepared out of combat")
  Display.AddSpareClone(pool, "icon", data, Create)
  assert(#pool == 1, "second spare added although one is available")
  test.Units.SetCombat(true)
  local made = 0
  Display.AddSpareClone(pool, "icon", data, function() made = made + 1 return Create() end)
  assert(made == 0, "spare created in combat")
  local noCdm = {triggers = {}}
  local plain = {}
  local busy = {cdmAuraTimer = {}, cdmProgressData = {uid = "u2", id = "a2"}}
  local idle = {cdmAuraTimer = {}, cdmProgressData = {uid = "u3", id = "a3"}}
  local loadedAuras = {a2 = true}
  assert(Display.TakeClone({plain}, data, loadedAuras) == plain, "cdm aura without container takes plain clone")
  assert(Display.TakeClone({busy, plain}, noCdm, loadedAuras) == plain, "non-cdm aura must leave the spare")
  assert(Display.TakeClone({plain, busy}, noCdm, loadedAuras) == plain, "non-cdm aura must skip the spare at the end")
  assert(Display.TakeClone({busy}, noCdm, loadedAuras) == nil, "non-cdm aura must not steal the only spare")
  assert(Display.TakeClone({busy}, data, loadedAuras) == nil, "cdm aura must not steal the spare of a loaded aura")
  assert(Display.TakeClone({busy, idle}, data, loadedAuras) == idle, "spare of an unloaded aura is available")
  local textData = {regionType = "texture", uid = "u7", triggers = data.triggers,
    subRegions = {{type = "subtext", text_text = "%p"}}}
  local textSpare = {subRegions = {{cdmAuraTimer = {}}}, cdmProgressData = {uid = "u7", id = "a7"}}
  assert(Display.TakeClone({textSpare, plain}, textData, loadedAuras) == textSpare, "own timer text spare not taken")
  assert(Display.TakeClone({textSpare, plain}, noCdm, loadedAuras) == plain, "non-cdm aura took an own timer text spare")
  assert(Display.TakeClone({plain, pool[1], busy}, data, loadedAuras) == pool[1], "spare of the same aura preferred")
  local taken = Display.TakeClone(pool, data, loadedAuras)
  assert(taken and taken.cdmAuraTimer and #pool == 0, "clone created in combat has no container")
  test.Units.SetCombat(true)
  local pooled = NewRegion("icon", data)
  assert(not pooled.cdmAuraTimer, "region modified in combat has no container yet")
  pooled.IsVisible = function() return false end
  test.Units.SetCombat(false)
  private.callbacks:Fire("RestrictionChanged", false)
  assert(pooled.cdmAuraTimer, "hidden clone created in combat gets its container after combat")
  test.Units.SetCombat(false)
  assert(pcall(realBar.ShowNativeBar, realBar, cdmBar), "ShowNativeBar anchored an addon object on the native cdm bar")
  assert(realBar.nativeBar == cdmBar and not realBar.fg:IsShown(), "region fill still drawn over the native cdm bar")
  assert(pcall(realBar.UpdateAnchors, realBar), "UpdateAnchors anchored an addon object on the native cdm bar")
  assert(pcall(realBar.StyleCdmBar, realBar), "native cdm bar not styled out of combat")
  test.Units.SetCombat(true)
  assert(pcall(realBar.StyleCdmBar, realBar), "native cdm bar styled in combat")
  assert(pcall(realBar.UpdateAnchors, realBar), "UpdateAnchors touched the denied cdm bar in combat")
  assert(pcall(realBar.AnchorMaskToNativeBar, realBar), "AnchorMaskToNativeBar touched the denied cdm bar in combat")
  assert(pcall(realBar.HideNativeBar, realBar), "HideNativeBar touched the denied cdm bar in combat")
  assert(realBar.nativeBar == nil and #denied == 0, "denied cdm bar was touched in combat")
  assert(pcall(realBar.ShowNativeBar, realBar, cdmBar), "ShowNativeBar touched the denied cdm bar in combat")
  assert(realBar.nativeBar == cdmBar and not realBar.fg:IsShown() and #denied == 0, "cdm bar not selected in combat")
  test.Units.SetCombat(false)
  assert(pcall(realBar.ShowNativeBar, realBar, cdmBar))
  local timerBar = realBar:GetNativeBar("timer")
  test.Units.SetCombat(true)
  assert(pcall(realBar.ShowNativeBar, realBar, timerBar), "ShowNativeBar hid the denied cdm bar in combat")
  assert(realBar.nativeBar == timerBar, "timer bar not shown in combat")
  test.Units.SetCombat(false)

  local spareData = {regionType = "aurabar", uid = "u9", orientation = "VERTICAL", cooldown = true,
    triggers = data.triggers}
  spareData.textureSource, spareData.texture, spareData.textureInput = "Picker", "tex", "Interface\x"
  spareData.barColor, spareData.barColor2, spareData.enableGradient = {0.1, 0.2, 0.3, 1}, {0.4, 0.5, 0.6, 1}, true
  calls = {}
  local sparePool = {}
  Display.AddSpareClone(sparePool, "aurabar", spareData, function() return NewRegion("aurabar", spareData) end)
  assert(sparePool[1] and sparePool[1].bar.orientation == "VERTICAL", "spare bar orientation not set from data")
  local spare = sparePool[1]
  assert(spare.textureInput == "Interface\x" and spare.textureSource == "Picker", "spare texture not set from data")
  assert(Count("aurabar", "UpdateStatusBarTexture") >= 1, "spare texture not applied before the native bar is styled")
  assert(spare.color_r == 0.1 and spare.enableGradient and spare.barColor2[1] == 0.4, "spare color not set from data")
  assert(Count("aurabar", "UpdateForegroundColor") >= 1, "spare color not applied before the native bar is styled")
  assert(Count("StatusBar", "SetFrameLevel") >= 1, "native bar frame level not set")

  realBar:ShowNativeBar(cdmBar)
  local styled
  local originalStatusBarColor = cdmBar.SetStatusBarColor
  cdmBar.SetStatusBarColor = function(self, r, ...) styled = r return originalStatusBarColor(self, r, ...) end
  realBar:SetForegroundGradient("HORIZONTAL", 0.5, 0.6, 0.7, 1, 0, 0, 0, 1)
  assert(styled == 0.5, "native bar not colored with the first gradient color")
  realBar:SetForegroundColor(0.9, 0.9, 0.9, 1)
  assert(styled == 0.9, "native bar not colored after gradient is dropped")
  cdmBar.SetStatusBarColor = originalStatusBarColor

  calls = {}
  test.Units.SetCombat(true)
  test.Units.SetCombat(false)
  private.callbacks:Fire("RestrictionChanged", false)
  assert(Count("bar", "StyleCdmBar") >= 1, "native bars not restyled after combat")
  CreateFrame, CustomAuraContainerAuraProcessingPolicy, Enum.StatusBarTimerDirection =
    realCreateFrame, savedPolicy, savedEnum
  C_AddOns = realC_AddOns
end

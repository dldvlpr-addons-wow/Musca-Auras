-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Native progress painting: aurabar native bars, progresstexture secret path and Aura (Modern) textures.
return function(test)
  local Frames, Secret = test.Frames, test.Secret
  local State = Frames.State
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Timer, Interpolation = Enum.StatusBarTimerDirection, Enum.StatusBarInterpolation

  local function Near(left, right) return math.abs((left or 0) - (right or 0)) < 1e-6 end
  local function AssertPoints(object, expected, message)
    local points = State[object].points
    assert(#points == #expected, message .. ": expected " .. #expected .. " points, got " .. #points)
    for index, want in ipairs(expected) do
      local got = points[index]
      assert(got[1] == want[1] and got[2] == want[2] and got[3] == want[3]
        and Near(got[4], want[4]) and Near(got[5], want[5]), message .. ": point " .. index .. " differs")
    end
  end
  local function AssertList(actual, expected, message)
    assert(actual and #actual == #expected, message .. ": size differs")
    for index, value in ipairs(expected) do
      assert(Near(actual[index], value), message .. ": entry " .. index .. " differs")
    end
  end
  local function HasMask(texture, mask)
    for _, present in ipairs(State[texture].masks or {}) do
      if present == mask then return true end
    end
    return false
  end

  local curves = {}
  local function Duration(percent, fails)
    local proxy = newproxy(true)
    getmetatable(proxy).__index = {
      GetRemainingDuration = function() return 5 end,
      EvaluateRemainingPercent = function(_, curve)
        curves[#curves + 1] = curve
        if fails then error("evaluation failed") end
        return percent
      end,
    }
    return proxy
  end
  local duration = Duration(0.4)

  -- Mask anchored on the complement of the fill: start edge of the frame to the facing edge of the fill.
  local Complement = {
    left = { "frame", "TOPLEFT", "fill", "BOTTOMLEFT" },
    right = { "fill", "TOPRIGHT", "frame", "BOTTOMRIGHT" },
    bottom = { "fill", "BOTTOMLEFT", "frame", "BOTTOMRIGHT" },
    top = { "frame", "TOPLEFT", "fill", "TOPRIGHT" },
  }
  local function ExpectedMask(edge, inverted, frame, fill, topLeftMargin, bottomRightMargin)
    local corners = inverted and Complement[edge] or { "fill", "TOPLEFT", "fill", "BOTTOMRIGHT" }
    local anchors = { frame = frame, fill = fill }
    return {
      { "TOPLEFT", anchors[corners[1]], corners[2], -topLeftMargin, topLeftMargin },
      { "BOTTOMRIGHT", anchors[corners[3]], corners[4], bottomRightMargin, -bottomRightMargin },
    }
  end

  -- AuraBar
  local region = private.regionTypes.aurabar.create(CreateFrame("Frame"))
  region.width, region.height = 200, 20
  local bar = region.bar
  bar.iconWidth, bar.iconHeight = 20, 10
  bar.orientation = "HORIZONTAL"
  bar:UpdateAnchors()

  -- 1. Duration object drawn by the timer bar.
  assert(bar:SetDurationObject(duration, false) == true, "duration object not drawn natively")
  local timer = bar.nativeBars.timer
  assert(timer and bar.nativeBar == timer and timer:IsShown(), "timer bar not active and shown")
  assert(State[timer].timerDuration == duration and State[timer].timerInterpolation == Interpolation.Immediate
    and State[timer].timerDirection == Timer.RemainingTime, "timer bar not driven with remaining time")
  AssertPoints(bar.fgMask, ExpectedMask("left", false, bar, timer:GetStatusBarTexture(), 0.05, 0.05), "mask on timer fill")
  assert(bar.fg:IsShown(), "foreground hidden over the timer bar")
  bar:SetDurationObject(duration, true)
  assert(State[timer].timerDirection == Timer.ElapsedTime, "elapsed fill not passed to the timer bar")

  -- 2. No duration object hides the timer bar.
  assert(bar:SetDurationObject(nil) == false, "nil duration object reported as drawn")
  assert(bar.nativeBar == nil and not timer:IsShown(), "timer bar still active")

  -- 3. Without the timer capability nothing is drawn natively.
  local savedTimer = Enum.StatusBarTimerDirection
  Enum.StatusBarTimerDirection = nil
  local isolated = setmetatable({}, { __index = private })
  for _, path in ipairs(test.Loader.files) do
    if type(path) == "string" and (path:match("NativeProgressPainter%.lua$") or path:match("AuraBarNative%.lua$")) then
      assert(test.Loader.RunFile(path, "WeakAuras", isolated))
    end
  end
  Enum.StatusBarTimerDirection = savedTimer
  local withoutTimer = rawget(isolated, "AuraBarNative")
  assert(withoutTimer and withoutTimer.canDrawDurationObject == false, "timer capability not computed at load")
  local plainRegion = private.regionTypes.aurabar.create(CreateFrame("Frame"))
  local plainBar = plainRegion.bar
  assert(withoutTimer.barFuncs.SetDurationObject(plainBar, duration, false) == false, "duration drawn without capability")
  assert(plainBar.nativeBar == nil, "native bar shown without capability")

  -- 4. Secret value: range, value, interpolation, then orientation and inversion.
  bar:SetSecretValue(30, 100, false, false)
  local valueBar = bar.nativeBars.value
  assert(bar.nativeBar == valueBar and valueBar:IsShown(), "value bar not active")
  assert(State[valueBar].minValue == 0 and State[valueBar].maxValue == 100 and State[valueBar].value == 30
    and State[valueBar].valueInterpolation == nil, "secret value not passed plainly")
  bar:SetSecretValue(30, 100, true, true)
  assert(State[valueBar].valueInterpolation == Interpolation.ExponentialEaseOut, "smooth value not interpolated")
  local auraBarDirections = {
    HORIZONTAL = { "HORIZONTAL", false, "left" },
    HORIZONTAL_INVERSE = { "HORIZONTAL", true, "right" },
    VERTICAL = { "VERTICAL", true, "top" },
    VERTICAL_INVERSE = { "VERTICAL", false, "bottom" },
  }
  for orientation, expected in pairs(auraBarDirections) do
    bar.orientation = orientation
    bar:UpdateAnchors()
    for _, inverted in ipairs({ false, true }) do
      bar:SetSecretValue(30, 100, inverted, false)
      local label = orientation .. (inverted and " inverted" or "")
      assert(State[valueBar].orientation == expected[1], label .. ": axis")
      assert(State[valueBar].reverseFill == (expected[2] ~= inverted), label .. ": reverse fill")
      AssertPoints(bar.fgMask, ExpectedMask(expected[3], inverted, bar, valueBar:GetStatusBarTexture(), 0.05, 0.05), label)
    end
  end
  bar.orientation = "HORIZONTAL"
  bar:UpdateAnchors()

  -- 4b. A spark set to always hidden stays hidden over the native fill, and comes back otherwise.
  bar.spark.sparkHidden = "ALWAYS"
  bar.spark:Show()
  bar:SetSecretValue(30, 100, true, false)
  bar:SetSecretValue(30, 100, false, false)
  assert(not bar.spark:IsShown(), "spark shown over the native fill despite ALWAYS")
  bar.spark.sparkHidden = "NEVER"
  bar:SetSecretValue(30, 100, true, false)
  assert(bar.spark:IsShown(), "spark not shown over the native fill")
  bar:SetSecretValue(30, 100, false, false)

  -- 5. Switching from the timer bar to the value bar.
  bar:SetDurationObject(duration, false)
  local refreshes = 0
  local originalUpdateAdditionalBars = bar.UpdateAdditionalBars
  bar.UpdateAdditionalBars = function(...) refreshes = refreshes + 1 return originalUpdateAdditionalBars(...) end
  bar:SetSecretValue(10, 100, false, false)
  bar.UpdateAdditionalBars = originalUpdateAdditionalBars
  assert(not timer:IsShown() and valueBar:IsShown() and bar.nativeBar == valueBar, "timer bar not swapped for value bar")
  assert(refreshes >= 1, "additional bars not refreshed on swap")

  -- 6. Blizzard cooldown bar out of combat.
  test.Units.SetCombat(false)
  local cooldownBar = CreateFrame("StatusBar", nil, bar)
  bar.nativeBars.cdm = cooldownBar
  bar:ShowNativeBar(cooldownBar)
  assert(cooldownBar:IsShown() and not timer:IsShown() and not valueBar:IsShown(), "cooldown bar not selected")
  AssertPoints(bar.fgMask, { { "TOPLEFT", bar, "TOPLEFT", 0, 0 }, { "BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0 } }, "mask on cooldown bar")
  assert(not bar.fg:IsShown(), "foreground drawn over the cooldown bar")
  bar:SetStatusBarTexture("Interface\\Some\\Texture")
  bar.orientation = "VERTICAL"
  bar:SetForegroundGradient("HORIZONTAL", 0.5, 0.6, 0.7, 1, 0, 0, 0, 1)
  assert(State[cooldownBar].orientation == "VERTICAL" and State[cooldownBar].reverseFill == true, "cooldown bar direction")
  assert(State[cooldownBar].statusBarColor[1] == 0.5, "cooldown bar not colored with the gradient start")
  assert(State[State[cooldownBar].statusBarTexture].texture == bar:GetStatusBarTexture(), "cooldown bar texture")
  bar:SetForegroundColor(0.9, 0.8, 0.7, 0.6)
  assert(State[cooldownBar].statusBarColor[1] == 0.9, "cooldown bar not colored with the foreground")
  local originalColor = cooldownBar.SetStatusBarColor
  cooldownBar.SetStatusBarColor = function() error("forbidden color") end
  assert(pcall(bar.StyleCdmBar, bar), "cooldown bar style error escaped")
  cooldownBar.SetStatusBarColor = originalColor
  bar:HideNativeBar()
  assert(bar.nativeBar == nil and not cooldownBar:IsShown(), "cooldown bar not hidden out of combat")
  bar.nativeBars.cdm = nil
  bar.orientation = "HORIZONTAL"
  bar:UpdateAnchors()

  -- 8 and 9. Additional bars drawn by native overlays.
  bar:SetSecretValue(30, 100, false, false)
  local barTexture = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", "Blizzard")
  bar:SetAdditionalBars({ { min = 10, max = 40 } }, { { 1, 0, 0, 1 } }, { "Blizzard" }, 0, 100, false)
  local overlay = bar.secretExtraTextures[1]
  assert(overlay and overlay:IsShown(), "overlay not created")
  local offsets = State[overlay].children
  local first, second = offsets[1], offsets[2]
  local overlayMask, overlayTexture
  for _, child in ipairs(State[overlay].regions) do
    if child:GetObjectType() == "MaskTexture" then overlayMask = child end
  end
  for _, texture in ipairs(State[bar].regions) do
    if HasMask(texture, overlayMask) then overlayTexture = texture end
  end
  assert(overlayTexture and overlayTexture:IsShown(), "overlay texture not masked by its overlay")
  assert(State[first].minValue == 0 and State[first].maxValue == 100 and State[first].value == 10
    and State[second].value == 40, "overlay offsets not set from min and max")
  AssertPoints(first, { { "TOPLEFT", bar, "TOPLEFT", 0, 0 }, { "BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0 } }, "first offset")
  AssertPoints(overlay, {
    { "TOPLEFT", first:GetStatusBarTexture(), "TOPRIGHT", 0, 0 },
    { "BOTTOMRIGHT", second:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0 },
  }, "overlay between offsets")
  AssertList(State[overlayTexture].texCoord, { -1, -1, -1, 0, 0, -1, 0, 0 }, "overlay rotation")
  AssertList(State[overlayTexture].vertexColor, { 1, 0, 0, 1 }, "overlay color")
  assert(State[overlayTexture].atlas == barTexture or State[overlayTexture].texture == barTexture, "overlay media texture")
  assert(State[overlay].value == 1, "overlay not full")
  bar:SetFrameLevel(12)
  assert(overlay:GetFrameLevel() == 12, "overlay frame level not following the bar")

  bar:SetAdditionalBars({ { direction = "forward", width = 20, offset = 5 } }, nil, nil, 0, 100, false)
  local third = State[overlay].children[3]
  assert(third and third:IsShown() and State[third].value == 5, "third offset not set")
  assert(State[first].value == 0 and State[second].value == 20, "width offsets not set")
  assert(first:GetWidth() == 180 and second:GetWidth() == 180 and third:GetWidth() == 180, "offset widths")
  AssertPoints(third, { { "TOPLEFT", bar.fgMask, "TOPRIGHT", 0, 0 }, { "BOTTOMLEFT", bar.fgMask, "BOTTOMRIGHT", 0, 0 } }, "third offset")
  AssertPoints(first, {
    { "TOPLEFT", third:GetStatusBarTexture(), "TOPRIGHT", 0, 0 },
    { "BOTTOMLEFT", third:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0 },
  }, "first offset on third")
  assert(State[overlay].reverseFill == false, "forward overlay reversed")
  bar:SetAdditionalBars({ { direction = "backward", width = 20, offset = 5 } }, nil, nil, 0, 100, false)
  assert(State[overlay].reverseFill == true and State[third].reverseFill == true, "backward overlay not reversed")

  bar:SetAdditionalBars({ { durationObject = duration, durationObjectUseRemaining = true }, { min = 1, max = 2 } },
    nil, nil, 0, 100, false)
  assert(not third:IsShown(), "third offset still shown")
  assert(State[overlay].timerDuration == duration and State[overlay].timerDirection == Timer.RemainingTime,
    "overlay timer not remaining")
  local secondOverlay = bar.secretExtraTextures[2]
  assert(secondOverlay:IsShown(), "second overlay not shown")
  bar:SetAdditionalBars({ { min = 1, max = 2 } }, nil, nil, 0, 100, false)
  assert(not secondOverlay:IsShown(), "extra overlay not hidden after shrink")

  bar:HideNativeBar()
  bar.additionalBars = { { min = 1, max = 2 } }
  assert(not bar:UsesNativeAdditionalBars(), "plain additional bars use native overlays")
  bar.additionalBars = { { width = Secret.Wrap(20) } }
  assert(bar:UsesNativeAdditionalBars(), "secret width not drawn natively")
  bar.additionalBars = { { durationObject = duration } }
  assert(bar:UsesNativeAdditionalBars(), "duration object not drawn natively")

  -- ProgressTexture
  local function NewTexture()
    local texture = private.regionTypes.progresstexture.create(CreateFrame("Frame"))
    local data = CopyTable(private.regionTypes.progresstexture.default)
    data.id, data.uid = "painting", "painting"
    data.actions, data.conditions, data.subRegions, data.load = { start = {}, finish = {} }, {}, {}, {}
    data.triggers = { activeTriggerMode = 1, { trigger = {} } }
    data.width, data.height = 64, 32
    private.regionTypes.progresstexture.modify(texture:GetParent(), texture, data)
    return texture
  end

  -- 10. Linear secret value.
  local texture = NewTexture()
  texture.progressType = "static"
  texture.secretValue, texture.secretTotal = 3, 10
  texture:UpdateValue()
  local driver = texture.nativeBar
  assert(texture.nativeLinearShown and driver:IsShown(), "linear native bar not shown")
  assert(HasMask(texture.foreground.texture, texture.nativeMask), "foreground not masked")
  assert(State[driver].maxValue == 10 and State[driver].value == 3 and texture.progress == 1, "linear value")
  local secretDirections = {
    HORIZONTAL = { "HORIZONTAL", true, "right" },
    HORIZONTAL_INVERSE = { "HORIZONTAL", false, "left" },
    VERTICAL = { "VERTICAL", false, "bottom" },
    VERTICAL_INVERSE = { "VERTICAL", true, "top" },
  }
  for orientation, expected in pairs(secretDirections) do
    texture:SetOrientation(orientation)
    for _, inverted in ipairs({ false, true }) do
      texture.progressType = "static"
      texture.secretValue, texture.secretTotal = 3, 10
      texture.inverseDirection = inverted
      texture:UpdateValue()
      local label = "texture " .. orientation .. (inverted and " inverted" or "")
      assert(State[driver].orientation == expected[1], label .. ": axis")
      assert(State[driver].reverseFill == (expected[2] ~= inverted), label .. ": reverse fill")
      AssertPoints(texture.nativeMask, ExpectedMask(expected[3], inverted, texture, driver:GetStatusBarTexture(), 0.05, 0.05), label)
    end
  end
  texture.inverseDirection = false
  texture.secretValue, texture.secretTotal = nil, nil
  texture.value, texture.total = 5, 10
  texture:UpdateValue()
  assert(not texture.nativeLinearShown and not driver:IsShown(), "linear native bar still shown")
  assert(not HasMask(texture.foreground.texture, texture.nativeMask), "foreground still masked")

  -- 11. Linear duration object.
  texture:SetOrientation("HORIZONTAL")
  texture.progressType = "timed"
  texture.duration, texture.expirationTime, texture.durationObject = 10, GetTime() + 5, duration
  for _, flags in ipairs({ { false, false, Timer.RemainingTime }, { true, false, Timer.ElapsedTime },
                           { false, true, Timer.ElapsedTime }, { true, true, Timer.RemainingTime } }) do
    texture.inverse, texture.inverseDirection = flags[1], flags[2]
    texture:UpdateTime()
    assert(driver:IsShown() and State[driver].timerDuration == duration and State[driver].timerDirection == flags[3]
      and State[driver].timerInterpolation == Interpolation.Immediate, "linear timer direction")
  end

  -- 12. Circular duration object.
  local ring = NewTexture()
  ring:SetOrientation("CLOCKWISE")
  ring.progressType = "timed"
  ring.duration, ring.expirationTime, ring.durationObject, ring.paused = 10, GetTime() + 5, duration, false
  curves = {}
  ring:UpdateTime()
  local radial = ring.nativeRadial
  assert(ring.nativeRadialShown and radial:IsShown() and Near(State[radial].radial.percent, 0.4), "radial percent")
  assert(curves[1] == CurveConstants.ZeroToOne, "remaining curve not used")
  assert(ring.FrameTick == private.ProgressTextureSecret.NativeRadialTick, "radial not ticking")
  assert(State[radial].radial.startOffset == nil and State[radial].radial.reverse == false, "default radial shape")
  ring.inverse = true
  curves = {}
  ring:UpdateTime()
  assert(curves[1] == CurveConstants.Reverse, "elapsed curve not used")
  ring.inverse = false
  ring:SetOrientation("ANTICLOCKWISE")
  ring.startAngle = 90
  ring:UpdateTime()
  assert(State[radial].radial.reverse == true, "anticlockwise not reversed")
  assert(Near(State[radial].radial.startOffset, 0.75) and Near(State[radial].radial.endOffset, 0.5), "radial offsets")
  ring.durationObject = Duration(0.4, true)
  assert(private.ProgressTextureSecret.UpdateNativeTime(ring) == false, "failing duration object drawn")
  private.ProgressTextureSecret.HideNative(ring)
  assert(ring.FrameTick ~= private.ProgressTextureSecret.NativeRadialTick and not radial:IsShown(), "radial not hidden")
  ring.durationObject, ring.paused = duration, true
  ring:UpdateTime()
  assert(ring.FrameTick ~= private.ProgressTextureSecret.NativeRadialTick, "paused radial ticking")

  -- Aura (Modern)
  local Native = private.ProgressTextureNative
  -- 13. Circular orientations.
  for orientation, circular in pairs({ HORIZONTAL = false, HORIZONTAL_INVERSE = false, VERTICAL = false,
                                       VERTICAL_INVERSE = false, CLOCKWISE = true, ANTICLOCKWISE = true }) do
    assert(Native.IsCircular(orientation) == circular, "IsCircular " .. orientation)
  end

  -- 14. Linear Aura (Modern).
  local durationBars = {}
  local function NativeDisplay()
    return { button = { SetDurationBar = function(_, statusBar, options) durationBars[#durationBars + 1] = { statusBar, options } end } }
  end
  local function AuraData(overrides)
    local auraData = {
      orientation = "HORIZONTAL", foregroundTexture = "fg", backgroundTexture = "bg", textureWrapMode = "CLAMP",
      blendMode = "ADD", desaturateForeground = false, desaturateBackground = true, auraRotation = 20, crop_x = 0.1,
      crop_y = 0.2, rotation = 30, mirror = false, user_x = 3, user_y = 4, compress = false, startAngle = 0,
      endAngle = 360, foregroundColor = { 0.1, 0.2, 0.3, 0.4 }, backgroundColor = { 0.5, 0.6, 0.7, 0.8 },
      sameTexture = false, width = 64, height = 32, backgroundOffset = 2, inverse = false,
    }
    for key, value in pairs(overrides) do auraData[key] = value end
    return auraData
  end
  local host = CreateFrame("Frame")
  local native = NativeDisplay()
  Native.StyleAura(native, AuraData({}), host)
  local widget = native.progressTexture
  local linearBackground = native.progressBackground
  assert(widget and native.bar == widget.bar and widget.bar:IsShown(), "modern foreground not created")
  assert(durationBars[1][1] == widget.bar and durationBars[1][2].direction == Timer.RemainingTime, "modern duration bar")
  assert(HasMask(widget.texture, widget.mask), "modern art not masked")
  AssertList(State[widget.bar].statusBarColor, { 1, 1, 1, 0 }, "modern bar color")
  Native.StyleAura(native, AuraData({ inverse = true, compress = true }), host)
  assert(native.progressTexture == widget and native.progressBackground == linearBackground, "modern widgets rebuilt")
  assert(durationBars[2][2].direction == Timer.ElapsedTime, "modern inverse duration bar")
  assert(not HasMask(widget.texture, widget.mask), "compressed art still masked")
  AssertPoints(widget.texture, { { "TOPLEFT", widget.mask, "TOPLEFT", 0, 0 }, { "BOTTOMRIGHT", widget.mask, "BOTTOMRIGHT", 0, 0 } }, "compressed art")

  -- 15. Ring Aura (Modern).
  local savedRenderMode = Enum.StatusBarRenderMode
  Enum.StatusBarRenderMode = nil
  local plain = NativeDisplay()
  Native.StyleAura(plain, AuraData({ orientation = "CLOCKWISE" }), host)
  assert(not plain.progressTexture.bar:IsShown() and plain.progressBackground == nil, "ring drawn without radial support")
  Enum.StatusBarRenderMode = savedRenderMode
  Native.StyleAura(native, AuraData({ orientation = "CLOCKWISE", startAngle = 90, endAngle = 0 }), host)
  assert(State[widget.bar].renderMode == Enum.StatusBarRenderMode.Radial, "ring render mode")
  local shape = State[widget.texture].radial
  assert(Near(shape.startOffset, 0.75) and Near(shape.endOffset, 0.5) and shape.feather == 0 and shape.reverse == false, "ring shape")
  local ringBackground = native.progressBackground
  assert(ringBackground ~= linearBackground and ringBackground.visible, "ring background not shown")
  assert(ringBackground.angle1 == 90 and ringBackground.angle2 == 360, "ring background progress")
  Native.StyleAura(native, AuraData({ orientation = "ANTICLOCKWISE" }), host)
  shape = State[widget.texture].radial
  assert(Near(shape.startOffset, 0.5) and Near(shape.endOffset, 0.5) and shape.reverse == true, "default ring shape")
end

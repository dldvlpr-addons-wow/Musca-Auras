if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local NativeProgress = {}
Private.ProgressTextureNative = NativeProgress

local SOLID_WHITE = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite"
local WARNING_ID = "native_progress_texture"
local NO_RADIAL_TEXT = "This client does not support circular Progress Textures with restricted values."
local NO_INVERSE_TEXT = "Inverse circular progress needs Health or Power with the full range when values are restricted."

local isRing = {CLOCKWISE = true, ANTICLOCKWISE = true}
local isUpright = {VERTICAL = true, VERTICAL_INVERSE = true}
local isBackward = {HORIZONTAL_INVERSE = true, VERTICAL_INVERSE = true}
local deficitSources = {value = true, health = true, power = true}
local customRangeFields = {"adjustedMin", "adjustedMax", "adjustedMinRelPercent", "adjustedMaxRelPercent"}

local function PostWarning(owner, text)
  local warningUid = owner.nativeProgressUID
  if warningUid and Private.AuraWarnings then
    Private.AuraWarnings.UpdateWarning(warningUid, WARNING_ID, text and "warning" or nil, text)
  end
end

function NativeProgress.IsCircular(direction)
  return isRing[direction] == true
end

function NativeProgress.Create(host)
  local statusBar = CreateFrame("StatusBar", nil, host)
  statusBar:SetAllPoints(host)
  local art = statusBar:CreateTexture(nil, "ARTWORK")
  local clipMask = statusBar:CreateMaskTexture()
  clipMask:SetTexture(SOLID_WHITE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  statusBar:SetStatusBarTexture(SOLID_WHITE)
  local widget = {
    bar = statusBar,
    texture = art,
    mask = clipMask,
    coord = Private.TextureCoords.create(art),
    linearTexture = statusBar:GetStatusBarTexture(),
  }
  statusBar:Hide()
  return widget
end

function NativeProgress.SupportsRadial(widget)
  return Enum.StatusBarRenderMode and widget.bar.SetRenderMode and widget.texture.SetRadialProgressBarPercent
end

local function ResolveColor(look)
  local red = look.color_anim_r or look.color_r or 1
  local green = look.color_anim_g or look.color_g or 1
  local blue = look.color_anim_b or look.color_b or 1
  local alpha = look.color_anim_a or look.color_a or 1
  return red, green, blue, alpha
end

local function PaintArt(widget, look, ring)
  local art = widget.texture
  art:RemoveMaskTexture(widget.mask)
  art:ClearAllPoints()
  art:SetAllPoints(widget.bar)
  Private.SetTextureOrAtlas(art, look.currentTexture, look.textureWrapMode, look.textureWrapMode)
  art:SetBlendMode(look.blendMode or "BLEND")
  art:SetDesaturated(look.desaturateForeground == true)
  art:SetRotation(math.rad(look.auraRotation or 0))

  local texCoord = widget.coord
  texCoord:SetFull()
  local mirrorX = (look.mirror and true or false) ~= (look.mirror_h and true or false)
  local shiftX, shiftY = look.user_x, look.user_y
  if ring then
    shiftX, shiftY = 0, 0
  end
  local cropX, cropY = look.crop_x or 1, look.crop_y or 1
  local turn = look.effectiveTexRotation or look.texRotation or 0
  texCoord:Transform(cropX, cropY, turn, mirrorX, look.mirror_v, shiftX, shiftY)
  texCoord:Apply()
  art:SetVertexColor(ResolveColor(look))
end

local function AngleToOffset(degrees)
  return (degrees + 180) % 360 / 360
end

local function PrepareRing(widget, look)
  local statusBar, art = widget.bar, widget.texture
  statusBar:SetRenderMode(Enum.StatusBarRenderMode.Radial)
  statusBar:SetStatusBarTexture(art)
  statusBar:SetReverseFill(false)
  statusBar:SetStatusBarColor(ResolveColor(look))
  widget.linearTexture:Hide()
  art:SetRadialProgressBarStartOffset(AngleToOffset(look.startAngle or 0))
  art:SetRadialProgressBarEndOffset(AngleToOffset(look.endAngle or 360))
  art:SetRadialProgressBarReverse(look.orientation == "ANTICLOCKWISE")
  art:SetRadialProgressBarFeather(0)
end

local function PinInvertedMask(clipMask, statusBar, fillTexture, upright, backward)
  if not upright then
    if backward then
      clipMask:SetPoint("TOPLEFT", fillTexture, "TOPRIGHT", -0.01, 0.01)
      clipMask:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
    else
      clipMask:SetPoint("TOPLEFT", statusBar, "TOPLEFT", -0.01, 0.01)
      clipMask:SetPoint("BOTTOMRIGHT", fillTexture, "BOTTOMLEFT")
    end
  elseif backward then
    clipMask:SetPoint("TOPLEFT", statusBar, "TOPLEFT", -0.01, 0.01)
    clipMask:SetPoint("BOTTOMRIGHT", fillTexture, "TOPRIGHT")
  else
    clipMask:SetPoint("TOPLEFT", fillTexture, "BOTTOMLEFT", -0.01, 0.01)
    clipMask:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
  end
end

local function PrepareStrip(widget, look, inverted)
  local statusBar, art = widget.bar, widget.texture
  local clipMask, fillTexture = widget.mask, widget.linearTexture
  if statusBar.SetRenderMode and Enum.StatusBarRenderMode then
    statusBar:SetRenderMode(Enum.StatusBarRenderMode.Linear)
  end
  if art.ClearRadialProgressBar then
    art:ClearRadialProgressBar()
  end
  statusBar:SetStatusBarTexture(fillTexture)
  statusBar:SetStatusBarColor(1, 1, 1, 0)

  local direction = look.orientation
  local upright = isUpright[direction] == true
  local backward = isBackward[direction] == true
  statusBar:SetOrientation(upright and "VERTICAL" or "HORIZONTAL")
  statusBar:SetReverseFill(backward ~= (inverted and true or false))

  clipMask:ClearAllPoints()
  if not inverted then
    clipMask:SetPoint("TOPLEFT", fillTexture, "TOPLEFT", -0.01, 0.01)
    clipMask:SetPoint("BOTTOMRIGHT", fillTexture, "BOTTOMRIGHT")
  else
    PinInvertedMask(clipMask, statusBar, fillTexture, upright, backward)
  end

  if not look.compress then
    art:AddMaskTexture(clipMask)
  else
    art:ClearAllPoints()
    art:SetAllPoints(clipMask)
  end
end

function NativeProgress.Style(widget, look, inverted)
  local ring = NativeProgress.IsCircular(look.orientation)
  if ring and not NativeProgress.SupportsRadial(widget) then
    widget.bar:Hide()
    return false
  end
  widget.circular = ring
  PaintArt(widget, look, ring)
  if not ring then
    PrepareStrip(widget, look, inverted)
  else
    PrepareRing(widget, look)
  end
  widget.texture:Show()
  return true
end

local function HideLegacyForeground(owner)
  owner.foreground:Hide()
  owner.foregroundSpinner:Hide()
  for _, extra in ipairs(owner.extraTextures) do
    extra:Hide()
  end
  for _, extraSpinner in ipairs(owner.extraSpinners) do
    extraSpinner:Hide()
  end
end

function NativeProgress.Stop(owner)
  if not owner.nativeProgressActive then
    return
  end
  owner.nativeProgressActive = nil
  owner.nativeProgressKind = nil
  owner.nativeProgress.bar:Hide()
  PostWarning(owner)
  local fallback = owner.circular and owner.foregroundSpinner or owner.foreground
  fallback:Show()
end

local function Claim(owner, mode)
  local widget = owner.nativeProgress
  if not widget then
    widget = NativeProgress.Create(owner)
    owner.nativeProgress = widget
  end
  local switching = not owner.nativeProgressActive or owner.nativeProgressKind ~= mode
  if switching then
    owner.nativeProgressDirty = true
    owner.smoothProgress:ResetSmoothedValue()
  end
  owner.nativeProgressActive = true
  owner.nativeProgressKind = mode
  if owner.FrameTick then
    owner.FrameTick = nil
    owner.subRegionEvents:RemoveSubscriber("FrameTick", owner)
  end
  HideLegacyForeground(owner)
  return widget
end

local function RestyleIfDirty(owner, widget, inverted)
  if owner.nativeProgressDirty then
    owner.nativeProgressDirty = nil
    local supported = NativeProgress.Style(widget, owner, inverted)
    widget.available = supported
    PostWarning(owner, not supported and NO_RADIAL_TEXT or nil)
  end
  return widget.available
end

local function UsesCustomRange(owner)
  for _, field in ipairs(customRangeFields) do
    if owner[field] then
      return true
    end
  end
  return false
end

local function MissingAmount(owner)
  local snapshot = owner.cdmProgressState or owner.state
  local progressSource = owner.progressSource
  local sourceKey = "value"
  if progressSource and progressSource[1] > 0 then
    sourceKey = progressSource[3] or "value"
  end
  if not snapshot or UsesCustomRange(owner) then
    return nil
  end
  local hasHealth = type(snapshot.health) == "number"
  if not hasHealth and type(snapshot.power) ~= "number" then
    return nil
  end
  if deficitSources[sourceKey] then
    return snapshot.deficit
  elseif sourceKey == "deficit" then
    return snapshot.value
  end
end

function NativeProgress.UpdateValue(owner)
  local widget = Claim(owner, "value")
  local inverted = owner.inverseDirection == true
  local ring = owner.circular
  if not RestyleIfDirty(owner, widget, inverted and not ring) then
    return
  end
  local amount = owner.value
  if inverted and ring then
    amount = MissingAmount(owner)
    if type(amount) ~= "number" then
      widget.bar:Hide()
      PostWarning(owner, NO_INVERSE_TEXT)
      return
    end
  end
  local statusBar = widget.bar
  local interpolation = Enum.StatusBarInterpolation
  local easing = owner.useSmoothProgress and interpolation.ExponentialEaseOut or interpolation.Immediate
  local low = owner.minProgress or 0
  local high = owner.maxProgress or owner.total
  statusBar:SetMinMaxValues(low, high)
  statusBar:SetValue(amount, easing)
  PostWarning(owner)
  statusBar:Show()
end

function NativeProgress.UpdateDuration(owner)
  local widget = Claim(owner, "duration")
  if not RestyleIfDirty(owner, widget, false) then
    return
  end
  local statusBar = widget.bar
  local timer = owner.durationObject
  if not Private.IsDurationObject(timer) then
    statusBar:Hide()
    return
  end
  local timerDirection = Enum.StatusBarTimerDirection
  local countUp = (owner.inverse and true or false) ~= (owner.inverseDirection and true or false)
  local mode = countUp and timerDirection.ElapsedTime or timerDirection.RemainingTime
  statusBar:SetTimerDuration(owner.durationObject, Enum.StatusBarInterpolation.Immediate, mode)
  statusBar:Show()
end

function NativeProgress.Refresh(owner)
  if not owner.nativeProgressActive then
    return
  end
  owner.nativeProgressDirty = true
  if owner.nativeProgressKind == "duration" then
    NativeProgress.UpdateDuration(owner)
  else
    NativeProgress.UpdateValue(owner)
  end
end

local function MakeAuraLook(auraData)
  local tint = auraData.foregroundColor
  return {
    orientation = auraData.orientation,
    currentTexture = auraData.foregroundTexture,
    textureWrapMode = auraData.textureWrapMode,
    blendMode = auraData.blendMode,
    desaturateForeground = auraData.desaturateForeground,
    auraRotation = auraData.auraRotation,
    crop_x = 1 + (auraData.crop_x or 0),
    crop_y = 1 + (auraData.crop_y or 0),
    texRotation = auraData.rotation,
    mirror = auraData.mirror,
    user_x = -(auraData.user_x or 0),
    user_y = auraData.user_y or 0,
    compress = auraData.compress,
    startAngle = auraData.startAngle,
    endAngle = auraData.endAngle,
    color_r = tint[1],
    color_g = tint[2],
    color_b = tint[3],
    color_a = tint[4],
  }
end

local function BackdropFor(widget, host, ring)
  local cache = widget.progressBackgrounds
  if not cache then
    cache = {}
    widget.progressBackgrounds = cache
  end
  local backdropType = ring and Private.CircularProgressTextureBase or Private.LinearProgressTextureBase
  local cacheKey = ring and "circular" or "linear"
  local backdrop = cache[cacheKey]
  if not backdrop then
    backdrop = backdropType.create(host, "BACKGROUND", 0)
    cache[cacheKey] = backdrop
  end
  return backdrop, backdropType
end

function NativeProgress.StyleAura(widget, auraData, host)
  if widget.progressBackground then
    widget.progressBackground:Hide()
  end
  local foregroundWidget = widget.progressTexture
  if not foregroundWidget then
    foregroundWidget = NativeProgress.Create(host)
    widget.progressTexture = foregroundWidget
  end
  local look = MakeAuraLook(auraData)
  if not NativeProgress.Style(foregroundWidget, look, false) then
    return
  end

  local ring = NativeProgress.IsCircular(auraData.orientation)
  local backdrop, backdropType = BackdropFor(widget, host, ring)
  widget.progressBackground = backdrop
  local backdropTexture = auraData.sameTexture and auraData.foregroundTexture or auraData.backgroundTexture
  backdropType.modify(backdrop, {
    crop_x = look.crop_x,
    crop_y = look.crop_y,
    mirror = auraData.mirror,
    texRotation = auraData.rotation or 0,
    texture = backdropTexture,
    blendMode = auraData.blendMode,
    desaturated = auraData.desaturateBackground,
    auraRotation = math.rad(auraData.auraRotation or 0),
    width = auraData.width,
    height = auraData.height,
    offset = auraData.backgroundOffset or 0,
    user_x = look.user_x,
    user_y = look.user_y,
    textureWrapMode = auraData.textureWrapMode,
  })

  if not ring then
    backdrop:SetOrientation(auraData.orientation)
    backdrop:SetValue(0, 1)
  else
    local fromAngle = (auraData.startAngle or 0) % 360
    local toAngle = (auraData.endAngle or 360) % 360
    if toAngle <= fromAngle then
      toAngle = toAngle + 360
    end
    backdrop:SetProgress(fromAngle, toAngle)
  end
  backdrop:SetColor(unpack(auraData.backgroundColor))
  backdrop:Show()

  local fgBar = foregroundWidget.bar
  widget.bar = fgBar
  local timerDirection = Enum.StatusBarTimerDirection
  local barDirection = auraData.inverse and timerDirection.ElapsedTime or timerDirection.RemainingTime
  widget.button:SetDurationBar(fgBar, {direction = barDirection})
  fgBar:Show()
end

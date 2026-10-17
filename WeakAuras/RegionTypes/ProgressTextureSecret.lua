-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Native drawing for the progress texture region when the progress is secret or a duration object.
-- Linear: the foreground is pinned full and a mask follows the fill of a hidden driver bar.
-- Circular: a separate radial texture whose percent is pushed every frame.
local Painter = Private.NativeProgressPainter

local function GetNativeBar(region)
  if not region.nativeBar then
    region.nativeBar = Painter.CreateDriverBar(region, true)
    region.nativeMask = Painter.CreateClampMask(region, "NEAREST")
  end
  return region.nativeBar
end

local NativeRadialTick

-- Moves the FrameTick subscription of a region to the given tick (nil unsubscribes).
local function SetFrameTick(region, tick)
  if region.FrameTick == tick then
    return
  end
  if region.FrameTick then
    region.subRegionEvents:RemoveSubscriber("FrameTick", region)
  end
  region.FrameTick = tick
  if tick then
    region.subRegionEvents:AddSubscriber("FrameTick", region)
  end
end

local function HideNative(region)
  if region.FrameTick == NativeRadialTick then
    SetFrameTick(region, nil)
  end
  if region.nativeLinearShown then
    region.nativeLinearShown = false
    region.foreground.texture:RemoveMaskTexture(region.nativeMask)
    region.nativeBar:Hide()
  end
  if region.nativeRadialShown then
    region.nativeRadialShown = false
    region.nativeRadial:Hide()
    region.foregroundSpinner:Show()
  end
end

local function ShowNativeLinear(region, inverse)
  local nativeBar = GetNativeBar(region)
  local direction = Painter.ProgressTextureSecretOrientation[region.orientation]
                    or Painter.ProgressTextureSecretOrientation.default
  inverse = inverse and true or false
  Painter.ApplyLinearDirection(nativeBar, direction.axis, direction.reverseFill, inverse)
  if region.nativeMaskInverse ~= inverse or region.nativeMaskOrientation ~= region.orientation then
    region.nativeMaskInverse = inverse
    region.nativeMaskOrientation = region.orientation
    Painter.AnchorMaskToFill(region.nativeMask, nativeBar:GetStatusBarTexture(), region, direction.axis,
      direction.reverseFill, inverse, Painter.DriverMaskMargins)
  end
  if not region.nativeLinearShown then
    region.nativeLinearShown = true
    region.foreground.texture:AddMaskTexture(region.nativeMask)
    nativeBar:Show()
  end
  -- The mask cuts the progress, so the foreground itself stays full.
  region.progress = 1
  if region.useSmoothProgress then
    region.smoothProgress:ResetSmoothedValue(1)
  end
  region.foreground:SetValue(0, 1)
  return nativeBar
end

-- Region settings seen as a painter look; the view reads the region live, so it is built once.
local function AnimatedOrStatic(animated, static)
  return function(region) return region[animated] or region[static] end
end
local regionLookReaders = {
  texture = "currentTexture",
  wrapMode = "textureWrapMode",
  blendMode = function(region) return region.foreground:GetBlendMode() end,
  spin = "auraRotation",
  cropX = "crop_x",
  cropY = "crop_y",
  textureRotation = AnimatedOrStatic("effectiveTexRotation", "texRotation"),
  flipX = function(region) return Painter.Either(region.mirror, region.mirror_h) end,
  flipY = "mirror_v",
  orientation = "orientation",
  startAngle = "startAngle",
  endAngle = "endAngle",
  red = AnimatedOrStatic("color_anim_r", "color_r"),
  green = AnimatedOrStatic("color_anim_g", "color_g"),
  blue = AnimatedOrStatic("color_anim_b", "color_b"),
  alpha = AnimatedOrStatic("color_anim_a", "color_a"),
}

local function RadialLook(region)
  region.nativeRadialLook = region.nativeRadialLook or Painter.LookView(region, regionLookReaders)
  return region.nativeRadialLook
end

local function ShowNativeRadial(region, percent)
  if not region.nativeRadial then
    region.nativeRadial = region:CreateTexture(nil, "ARTWORK", nil, 1)
    region.nativeRadial:SetAllPoints(region)
  end
  local radial = region.nativeRadial
  region.nativeRadialCoord = region.nativeRadialCoord or Private.TextureCoords.create(radial)
  local look = RadialLook(region)
  Painter.PaintArt(radial, region.nativeRadialCoord, look, false)
  -- Once offsets were written they are kept up to date, even back at their defaults.
  if Painter.ApplyRadialShape(radial, look, region.nativeRadialOffset) then
    region.nativeRadialOffset = true
  end
  radial:SetRadialProgressBarPercent(percent)
  if not region.nativeRadialShown then
    region.nativeRadialShown = true
    region.foregroundSpinner:Hide()
    radial:Show()
  end
end

local function FillsElapsed(region)
  return Painter.Either(region.inverse, region.inverseDirection)
end

NativeRadialTick = function(region)
  local readable, percent = Painter.EvaluateRemainingPercent(region.durationObject, FillsElapsed(region))
  if readable then
    ShowNativeRadial(region, percent)
  end
end

local function UpdateNativeValue(region)
  if region.circular then
    if not region.inverseDirection and Painter.CanDrawRadialPercent and type(region.secretPercent) == "number" then
      ShowNativeRadial(region, region.secretPercent)
      return true
    end
  elseif Painter.CanDrawDurationObject and type(region.secretValue) == "number" and type(region.secretTotal) == "number" then
    local nativeBar = ShowNativeLinear(region, region.inverseDirection)
    Painter.SetSecretProgress(nativeBar, region.secretValue, region.secretTotal, region.useSmoothProgress)
    return true
  end
  return false
end

local function UpdateNativeTime(region)
  if not region.durationObject then
    return false
  end
  if region.circular then
    -- A circle never falls back to the linear driver bar.
    if not Painter.CanDrawRadialPercent then
      return false
    end
    local readable, percent = Painter.EvaluateRemainingPercent(region.durationObject, FillsElapsed(region))
    if not readable then
      return false
    end
    ShowNativeRadial(region, percent)
    if not region.paused then
      SetFrameTick(region, NativeRadialTick)
    end
    return true
  end
  if not Painter.CanDrawDurationObject then
    return false
  end
  local nativeBar = ShowNativeLinear(region)
  Painter.SetTimer(nativeBar, region.durationObject, Painter.FillDirection(FillsElapsed(region)), "Immediate")
  return true
end

Private.ProgressTextureSecret = {
  HideNative = HideNative,
  NativeRadialTick = NativeRadialTick,
  UpdateNativeValue = UpdateNativeValue,
  UpdateNativeTime = UpdateNativeTime,
}

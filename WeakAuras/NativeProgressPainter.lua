-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Shared helpers for progress drawn by native widgets (StatusBar geometry, radial textures).
-- Callers translate their own orientation names through the tables below; the helpers only see an axis
-- and a fill direction.
local Painter = {
  WhiteTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite",
  -- Mask margins around a driver bar fill, and around an art fill.
  DriverMaskMargins = { topLeft = 0.05, bottomRight = 0.05 },
  FillMaskMargins = { topLeft = 0.01, bottomRight = 0 },
}
Private.NativeProgressPainter = Painter

local clampWrap = "CLAMPTOBLACKADDITIVE"

-- Capabilities, probed once on throwaway widgets.
local textureDrawsRadial
do
  local statusBar = CreateFrame("StatusBar")
  local texture = CreateFrame("Frame"):CreateTexture()
  textureDrawsRadial = texture.SetRadialProgressBarPercent ~= nil
  Painter.CanDrawDurationObject = Enum.StatusBarTimerDirection ~= nil and statusBar.SetTimerDuration ~= nil
  Painter.CanDrawRadialPercent = textureDrawsRadial and CurveConstants ~= nil
    and CurveConstants.ZeroToOne ~= nil and CurveConstants.Reverse ~= nil
end

-- The render mode enum can disappear at run time (tests do it), so these two are asked on demand.
function Painter.CanSwitchRenderMode(statusBar)
  return Enum.StatusBarRenderMode ~= nil and statusBar.SetRenderMode ~= nil
end

function Painter.CanRenderRadialBar(statusBar)
  return textureDrawsRadial and Painter.CanSwitchRenderMode(statusBar)
end

-- Exactly one of the two flags is set.
function Painter.Either(first, second)
  if first then
    return not second
  end
  return second and true or false
end

-- Orientation tables, one per drawing convention. Entry: native axis, reverse fill, and for the aura bar
-- whether the orientation is a mirrored one and the texture coordinates (UL, LL, UR, LR, REPEAT wrapping)
-- of its additional bar overlays.
Painter.AuraBarOrientation = {
  HORIZONTAL = { axis = "HORIZONTAL", reverseFill = false, mirrored = false,
                 overlayTexCoords = { -1, -1, -1, 0, 0, -1, 0, 0 } },
  HORIZONTAL_INVERSE = { axis = "HORIZONTAL", reverseFill = true, mirrored = true,
                         overlayTexCoords = { 1, 1, 1, 0, 0, 1, 0, 0 } },
  VERTICAL = { axis = "VERTICAL", reverseFill = true, mirrored = false,
               overlayTexCoords = { 1, -1, 0, -1, 1, 0, 0, 0 } },
  VERTICAL_INVERSE = { axis = "VERTICAL", reverseFill = false, mirrored = true,
                       overlayTexCoords = { -1, 1, 0, 1, -1, 0, 0, 0 } },
}
Painter.AuraBarOrientation.default = Painter.AuraBarOrientation.HORIZONTAL
Painter.ProgressTextureOrientation = {
  HORIZONTAL = { axis = "HORIZONTAL", reverseFill = false },
  HORIZONTAL_INVERSE = { axis = "HORIZONTAL", reverseFill = true },
  VERTICAL = { axis = "VERTICAL", reverseFill = false },
  VERTICAL_INVERSE = { axis = "VERTICAL", reverseFill = true },
}
Painter.ProgressTextureOrientation.default = Painter.ProgressTextureOrientation.HORIZONTAL
Painter.ProgressTextureSecretOrientation = {
  HORIZONTAL = { axis = "HORIZONTAL", reverseFill = true },
  HORIZONTAL_INVERSE = { axis = "HORIZONTAL", reverseFill = false },
  VERTICAL = { axis = "VERTICAL", reverseFill = false },
  VERTICAL_INVERSE = { axis = "VERTICAL", reverseFill = true },
}
Painter.ProgressTextureSecretOrientation.default = Painter.ProgressTextureSecretOrientation.HORIZONTAL_INVERSE

-- A StatusBar whose fill is invisible: it only provides geometry. With coverParent it spans the parent and
-- starts hidden; otherwise the caller places it.
function Painter.CreateDriverBar(parent, coverParent)
  local statusBar = CreateFrame("StatusBar", nil, parent)
  statusBar:SetStatusBarTexture(Painter.WhiteTexture)
  statusBar:GetStatusBarTexture():SetAlpha(0)
  if coverParent then
    statusBar:SetAllPoints(parent)
    statusBar:Hide()
  end
  return statusBar
end

-- A white mask; with a filter it also opts out of pixel snapping.
function Painter.CreateClampMask(owner, filter)
  local mask = owner:CreateMaskTexture()
  if filter then
    mask:SetTexture(Painter.WhiteTexture, clampWrap, clampWrap, filter)
    mask:SetTexelSnappingBias(0)
    mask:SetSnapToPixelGrid(false)
  else
    mask:SetTexture(Painter.WhiteTexture, clampWrap, clampWrap)
  end
  return mask
end

function Painter.ApplyLinearDirection(statusBar, axis, reverseFill, inverted)
  if inverted then
    reverseFill = not reverseFill
  end
  statusBar:SetOrientation(axis)
  statusBar:SetReverseFill(reverseFill)
end

-- When inverted the native fill grows from the far edge, so the mask covers the part it leaves empty:
-- from the start edge of the frame to the facing edge of the fill. Keyed by axis, then reverse fill.
local emptySide = {
  HORIZONTAL = {
    [false] = { topLeft = { "frame", "TOPLEFT" }, bottomRight = { "fill", "BOTTOMLEFT" } },
    [true] = { topLeft = { "fill", "TOPRIGHT" }, bottomRight = { "frame", "BOTTOMRIGHT" } },
  },
  VERTICAL = {
    [false] = { topLeft = { "fill", "BOTTOMLEFT" }, bottomRight = { "frame", "BOTTOMRIGHT" } },
    [true] = { topLeft = { "frame", "TOPLEFT" }, bottomRight = { "fill", "TOPRIGHT" } },
  },
}
local filledSide = { topLeft = { "fill", "TOPLEFT" }, bottomRight = { "fill", "BOTTOMRIGHT" } }

function Painter.AnchorMaskToFill(mask, fill, frame, axis, reverseFill, inverted, margins)
  local side = inverted and emptySide[axis][reverseFill] or filledSide
  local anchors = { fill = fill, frame = frame }
  local topLeft, bottomRight = margins.topLeft, margins.bottomRight
  mask:ClearAllPoints()
  mask:SetPoint("TOPLEFT", anchors[side.topLeft[1]], side.topLeft[2], -topLeft, topLeft)
  mask:SetPoint("BOTTOMRIGHT", anchors[side.bottomRight[1]], side.bottomRight[2], bottomRight, -bottomRight)
end

-- Value and total may be secret: they are only handed to the native setters.
function Painter.SetSecretProgress(statusBar, value, total, smooth)
  statusBar:SetMinMaxValues(0, total)
  if smooth and Enum.StatusBarInterpolation then
    statusBar:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
  else
    statusBar:SetValue(value)
  end
end

-- direction: a key of Enum.StatusBarTimerDirection or nil; interpolation: a key of Enum.StatusBarInterpolation or nil.
function Painter.SetTimer(statusBar, durationObject, direction, interpolation)
  statusBar:SetTimerDuration(durationObject,
    interpolation and Enum.StatusBarInterpolation[interpolation] or nil,
    direction and Enum.StatusBarTimerDirection[direction] or nil)
end

function Painter.FillDirection(fillElapsed)
  return fillElapsed and "ElapsedTime" or "RemainingTime"
end

-- Looks ----------------------------------------------------------------------
-- A look describes an art texture in one vocabulary:
--   texture, wrapMode, blendMode, desaturate (nil leaves it alone), spin (degrees),
--   cropX, cropY (scale), textureRotation (degrees), flipX, flipY, shiftX, shiftY,
--   red, green, blue, alpha, orientation, startAngle, endAngle, compress.
-- A look is a live view over its source: nothing is copied, every read goes through a reader.
local lookDefaults = {
  blendMode = "BLEND", spin = 0, cropX = 1, cropY = 1, textureRotation = 0, shiftX = 0, shiftY = 0,
  red = 1, green = 1, blue = 1, alpha = 1, startAngle = 0, endAngle = 360,
}

-- readers: look key -> source field name, or function(source) returning the value.
function Painter.LookView(source, readers)
  return setmetatable({}, {
    __index = function(_, key)
      local reader, value = readers[key], nil
      if type(reader) == "function" then
        value = reader(source)
      elseif reader then
        value = source[reader]
      end
      if type(value) == "nil" then
        return lookDefaults[key]
      end
      return value
    end,
  })
end

function Painter.ResolveColor(look)
  return look.red, look.green, look.blue, look.alpha
end

-- Image and tint first, then where the image sits inside the texture. shifted applies the user offset.
function Painter.PaintArt(texture, coordinates, look, shifted)
  Private.SetTextureOrAtlas(texture, look.texture, look.wrapMode, look.wrapMode)
  texture:SetBlendMode(look.blendMode)
  if look.desaturate ~= nil then
    texture:SetDesaturated(look.desaturate)
  end
  texture:SetVertexColor(Painter.ResolveColor(look))
  texture:SetRotation(math.rad(look.spin))
  coordinates:SetFull()
  coordinates:Transform(look.cropX, look.cropY, look.textureRotation, look.flipX, look.flipY,
    shifted and look.shiftX or 0, shifted and look.shiftY or 0)
  coordinates:Apply()
end

-- Native radial offsets start at the bottom; aura angles start at the top.
function Painter.RadialOffsetFromAngle(angle)
  return (angle + 180) % 360 / 360
end

-- Sets direction and angle offsets. Offsets at their defaults are skipped unless alwaysSetOffsets.
-- Returns true when the offsets were written.
function Painter.ApplyRadialShape(texture, look, alwaysSetOffsets)
  if texture.SetRadialProgressBarReverse then
    texture:SetRadialProgressBarReverse(look.orientation == "ANTICLOCKWISE")
  end
  local startAngle, endAngle = look.startAngle, look.endAngle
  if not texture.SetRadialProgressBarStartOffset
     or not (alwaysSetOffsets or startAngle ~= 0 or endAngle ~= 360) then
    return false
  end
  texture:SetRadialProgressBarStartOffset(Painter.RadialOffsetFromAngle(startAngle))
  texture:SetRadialProgressBarEndOffset(Painter.RadialOffsetFromAngle(endAngle))
  return true
end

-- Remaining (or elapsed) share of a duration object. Returns true and the percent, which may be secret,
-- or false when it cannot be read; callers test the flag, never the percent.
function Painter.EvaluateRemainingPercent(durationObject, fillElapsed)
  local curve = fillElapsed and CurveConstants.Reverse or CurveConstants.ZeroToOne
  local ok, percent = pcall(durationObject.EvaluateRemainingPercent, durationObject, curve)
  if ok and type(percent) == "number" then
    return true, percent
  end
  return false
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Progress texture of the Aura (Modern) display. A StatusBar handed to the Blizzard aura button
-- (SetDurationBar) animates the fill; this module only styles it and its backdrop.
-- Two shapes share the widget: a band (linear fill cutting the art through a mask) and a ring
-- (the art itself is the radial fill of the StatusBar).
local Painter = Private.NativeProgressPainter
local ProgressTextureNative = {}
Private.ProgressTextureNative = ProgressTextureNative

local circularOrientations = { CLOCKWISE = true, ANTICLOCKWISE = true }

function ProgressTextureNative.IsCircular(orientation)
  return circularOrientations[orientation] == true
end

-- Widget: the StatusBar, its art texture, a mask for the band, texture coordinates of the art,
-- and the plain fill texture of the StatusBar used by the band.
function ProgressTextureNative.Create(host)
  local bar = Painter.CreateDriverBar(host, true)
  local art = bar:CreateTexture(nil, "ARTWORK")
  return {
    bar = bar,
    texture = art,
    mask = Painter.CreateClampMask(bar),
    coord = Private.TextureCoords.create(art),
    linearTexture = bar:GetStatusBarTexture(),
  }
end

-- Adds or removes the band mask on the art, only when that changes.
local function MaskArt(widget, masked)
  if widget.artMasked == masked then
    return
  end
  widget.artMasked = masked
  if masked then
    widget.texture:AddMaskTexture(widget.mask)
  else
    widget.texture:RemoveMaskTexture(widget.mask)
  end
end

-- Hands a fill texture to the StatusBar in the given render mode, tinted.
local function UseFill(widget, renderMode, fill, ...)
  local bar = widget.bar
  if Painter.CanSwitchRenderMode(bar) then
    bar:SetRenderMode(Enum.StatusBarRenderMode[renderMode])
  end
  bar:SetStatusBarTexture(fill)
  bar:SetStatusBarColor(...)
end

local Band = { backdrop = Private.LinearProgressTextureBase }

function Band.Supported()
  return true
end

-- The fill stays invisible; the mask follows it. A compressed art is stretched over the mask instead.
-- Once released by the StatusBar, the art drops any radial setup left by a ring.
function Band.Draw(widget, look)
  local bar, art = widget.bar, widget.texture
  MaskArt(widget, not look.compress)
  UseFill(widget, "Linear", widget.linearTexture, 1, 1, 1, 0)
  if art.ClearRadialProgressBar then
    art:ClearRadialProgressBar()
  end
  art:ClearAllPoints()
  art:SetAllPoints(look.compress and widget.mask or bar)
  Painter.PaintArt(art, widget.coord, look, true)
  local direction = Painter.ProgressTextureOrientation[look.orientation] or Painter.ProgressTextureOrientation.default
  Painter.AnchorMaskToFill(widget.mask, widget.linearTexture, bar, direction.axis, direction.reverseFill, false,
    Painter.FillMaskMargins)
  Painter.ApplyLinearDirection(bar, direction.axis, direction.reverseFill, false)
end

function Band.FillBackdrop(backdrop, auraData)
  backdrop:SetOrientation(auraData.orientation)
  backdrop:SetValue(0, 1)
end

local Ring = { backdrop = Private.CircularProgressTextureBase }

function Ring.Supported(widget)
  return Painter.CanRenderRadialBar(widget.bar)
end

-- The art is painted and placed before it becomes the StatusBar fill; its radial shape follows.
function Ring.Draw(widget, look)
  local bar, art = widget.bar, widget.texture
  widget.linearTexture:Hide()
  bar:SetReverseFill(false)
  MaskArt(widget, false)
  Painter.PaintArt(art, widget.coord, look, false)
  art:ClearAllPoints()
  art:SetAllPoints(bar)
  UseFill(widget, "Radial", art, Painter.ResolveColor(look))
  art:SetRadialProgressBarFeather(0)
  Painter.ApplyRadialShape(art, look, true)
end

-- Backdrop progress runs from the start angle to the end angle, a full turn when they meet.
function Ring.FillBackdrop(backdrop, auraData)
  local from = (auraData.startAngle or 0) % 360
  local span = ((auraData.endAngle or 360) - from) % 360
  backdrop:SetProgress(from, from + (span == 0 and 360 or span))
end

local function ShapeOf(orientation)
  return ProgressTextureNative.IsCircular(orientation) and Ring or Band
end

-- Returns false, with the StatusBar hidden, when the shape cannot be drawn here.
function ProgressTextureNative.Style(widget, look)
  local shape = ShapeOf(look.orientation)
  local drawable = shape.Supported(widget)
  if drawable then
    shape.Draw(widget, look)
    widget.texture:Show()
  else
    widget.bar:Hide()
  end
  return drawable
end

-- Aura data seen as a painter look.
local function Channel(index)
  return function(auraData)
    local color = auraData.foregroundColor
    return color and color[index]
  end
end
local auraLookReaders = {
  orientation = "orientation",
  texture = "foregroundTexture",
  wrapMode = "textureWrapMode",
  blendMode = "blendMode",
  desaturate = function(auraData) return auraData.desaturateForeground == true end,
  spin = "auraRotation",
  cropX = function(auraData) return (auraData.crop_x or 0) + 1 end,
  cropY = function(auraData) return (auraData.crop_y or 0) + 1 end,
  textureRotation = "rotation",
  flipX = "mirror",
  -- The display offset runs opposite to the texture coordinate shift on x.
  shiftX = function(auraData) return 0 - (auraData.user_x or 0) end,
  shiftY = "user_y",
  compress = "compress",
  startAngle = "startAngle",
  endAngle = "endAngle",
  red = Channel(1), green = Channel(2), blue = Channel(3), alpha = Channel(4),
}

-- One backdrop per shape and per aura, made on first use.
local function BackdropOf(native, host, shape)
  native.backdropByShape = native.backdropByShape or {}
  local backdrop = native.backdropByShape[shape]
  if not backdrop then
    backdrop = shape.backdrop.create(host, "BACKGROUND", 0)
    native.backdropByShape[shape] = backdrop
  end
  return backdrop
end

-- Shows the backdrop of the shape; the backdrop of the other shape, if it was active, goes away.
local function StyleBackdrop(native, auraData, host, look, shape)
  local backdrop = BackdropOf(native, host, shape)
  if native.progressBackground and native.progressBackground ~= backdrop then
    native.progressBackground:Hide()
  end
  native.progressBackground = backdrop
  -- Shown before modify: a hidden texture skips the texCoord update.
  backdrop:Show()
  backdrop:SetColor(unpack(auraData.backgroundColor, 1, 4))
  shape.backdrop.modify(backdrop, {
    texture = auraData.sameTexture and auraData.foregroundTexture or auraData.backgroundTexture,
    textureWrapMode = auraData.textureWrapMode,
    blendMode = auraData.blendMode,
    desaturated = auraData.desaturateBackground,
    width = auraData.width,
    height = auraData.height,
    offset = auraData.backgroundOffset or 0,
    auraRotation = math.rad(look.spin),
    texRotation = look.textureRotation,
    mirror = auraData.mirror,
    crop_x = look.cropX,
    crop_y = look.cropY,
    user_x = look.shiftX,
    user_y = look.shiftY,
  })
  shape.FillBackdrop(backdrop, auraData)
end

function ProgressTextureNative.StyleAura(native, auraData, host)
  local widget = native.progressTexture
  if not widget then
    widget = ProgressTextureNative.Create(host)
    native.progressTexture = widget
  end
  local look = Painter.LookView(auraData, auraLookReaders)
  if not ProgressTextureNative.Style(widget, look) then
    if native.progressBackground then
      native.progressBackground:Hide()
    end
    return
  end
  native.bar = widget.bar
  widget.bar:Show()
  native.button:SetDurationBar(widget.bar, {
    direction = Enum.StatusBarTimerDirection[Painter.FillDirection(auraData.inverse)],
  })
  StyleBackdrop(native, auraData, host, look, ShapeOf(look.orientation))
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Native drawing for the aura bar region, methods mixed into region.bar by AuraBar.lua.
-- (a) Secret values and duration objects: hidden driver bars give the geometry, fgMask follows their fill.
-- (b) The Blizzard cooldown bar ("cdm", set by CDMAuraProgress.lua) is protected: it draws itself,
--     and any write to it goes through WithWritableCooldownBar.
local Painter = Private.NativeProgressPainter
local SharedMedia = LibStub("LibSharedMedia-3.0")

local barFuncs = {}

-- (b) Blizzard cooldown bar --------------------------------------------------

local function CooldownBarOf(bar)
  return bar.nativeBars and bar.nativeBars.cdm
end

local function IsCooldownBar(bar, statusBar)
  return statusBar ~= nil and statusBar == CooldownBarOf(bar)
end

-- The only place that writes to the cooldown bar.
local function WithWritableCooldownBar(bar, write, ...)
  local cooldownBar = CooldownBarOf(bar)
  if cooldownBar and not WeakAuras.IsRestricted() then
    write(cooldownBar, ...)
  end
end

local function ShowFrame(frame) frame:Show() end
local function HideFrame(frame) frame:Hide() end

local function OrientationOf(bar)
  return Painter.AuraBarOrientation[bar.orientation] or Painter.AuraBarOrientation.default
end

local function PaintCooldownBar(cooldownBar, direction, texture, red, green, blue, alpha)
  Painter.ApplyLinearDirection(cooldownBar, direction.axis, direction.reverseFill, false)
  if texture then
    cooldownBar:SetStatusBarTexture(texture)
  end
  cooldownBar:SetStatusBarColor(red, green, blue, alpha)
end

-- Copies the bar look onto the cooldown bar. Blizzard may reject a write on its bar:
-- the error is swallowed and the bar keeps its previous look.
local function StyleWritableCooldownBar(cooldownBar, bar)
  local texture = bar:GetStatusBarTexture()
  if bar.cdmColor then
    pcall(PaintCooldownBar, cooldownBar, OrientationOf(bar), texture, unpack(bar.cdmColor))
  else
    pcall(PaintCooldownBar, cooldownBar, OrientationOf(bar), texture, bar.fg:GetVertexColor())
  end
end

function barFuncs:StyleCdmBar()
  WithWritableCooldownBar(self, StyleWritableCooldownBar, self)
end

function barFuncs:NativeBarLocked()
  return IsCooldownBar(self, self.nativeBar) and WeakAuras.IsRestricted()
end

-- (a) Driver bars ------------------------------------------------------------

function barFuncs:GetNativeBar(kind)
  self.nativeBars = self.nativeBars or {}
  local statusBar = self.nativeBars[kind]
  if not statusBar then
    statusBar = Painter.CreateDriverBar(self, true)
    self.nativeBars[kind] = statusBar
  end
  return statusBar
end

function barFuncs:ReleaseNativeBar()
  local active = self.nativeBar
  if active and not IsCooldownBar(self, active) then
    active:Hide()
  end
end

function barFuncs:ShowNativeBar(statusBar)
  if self.nativeBar == statusBar then
    return
  end
  self:ReleaseNativeBar()
  self.nativeBar = statusBar
  if IsCooldownBar(self, statusBar) then
    WithWritableCooldownBar(self, ShowFrame)
  else
    statusBar:Show()
  end
  self:AnchorMaskToNativeBar()
  self:UpdateAdditionalBars()
end

function barFuncs:HideNativeBar()
  local active = self.nativeBar
  if not active then
    return
  end
  self:ReleaseNativeBar()
  if IsCooldownBar(self, active) then
    WithWritableCooldownBar(self, HideFrame)
  end
  self.nativeBar = nil
  self:UpdateAnchors()
  self:UpdateAdditionalBars()
end

function barFuncs:SetDurationObject(durationObject, fillElapsed)
  if not durationObject then
    self:HideNativeBar()
    return false
  end
  if not Painter.CanDrawDurationObject then
    return false
  end
  local timer = self:GetNativeBar("timer")
  Painter.SetTimer(timer, durationObject, Painter.FillDirection(fillElapsed), "Immediate")
  self:ShowNativeBar(timer)
  return true
end

-- value and total may be secret: they only reach the native setters.
function barFuncs:SetSecretValue(value, total, inverse, smooth)
  local valueBar = self:GetNativeBar("value")
  Painter.SetSecretProgress(valueBar, value, total, smooth)
  inverse = inverse and true or false
  local inverseChanged = inverse ~= self.nativeInverse
  self.nativeInverse = inverse
  if self.nativeBar ~= valueBar then
    self:ShowNativeBar(valueBar)
  elseif inverseChanged then
    self:AnchorMaskToNativeBar()
  end
end

function barFuncs:AnchorMaskToNativeBar()
  local active, mask = self.nativeBar, self.fgMask
  if IsCooldownBar(self, active) then
    -- The cooldown bar paints the fill itself; never anchor on a protected frame.
    mask:ClearAllPoints()
    mask:SetPoint("TOPLEFT", self, "TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.fg:Hide()
    self.spark:Hide()
    self:StyleCdmBar()
    return
  end
  -- A timer encodes its direction itself; only a value bar flips its fill.
  local inverted = self.nativeInverse and active == self.nativeBars.value
  local direction = OrientationOf(self)
  Painter.ApplyLinearDirection(active, direction.axis, direction.reverseFill, inverted)
  Painter.AnchorMaskToFill(mask, active:GetStatusBarTexture(), self, direction.axis, direction.reverseFill,
    inverted, Painter.DriverMaskMargins)
  self.fg:Show()
  self.spark:SetShown(self.spark.sparkHidden ~= "ALWAYS")
end

-- (a) Additional bars --------------------------------------------------------

local function IsSecretGeometry(additionalBar)
  return Private.IsSecret(additionalBar.min) or Private.IsSecret(additionalBar.max)
      or Private.IsSecret(additionalBar.width) or Private.IsSecret(additionalBar.offset)
end

function barFuncs:UsesNativeAdditionalBars()
  if self.nativeBar then
    return true
  end
  for _, additionalBar in ipairs(self.additionalBars) do
    if additionalBar.durationObject or IsSecretGeometry(additionalBar) then
      return true
    end
  end
  return false
end

local function DrawSublevel(index)
  return math.min(index, 7)
end

-- An overlay StatusBar spans the stretch between the fills of two marker bars; its fill masks a texture
-- painted over the whole bar. Markers 1 and 2 bound the stretch, the optional offset marker carries them.
local function CreateOverlay(bar)
  local overlay = Painter.CreateDriverBar(bar)
  overlay.markers = { Painter.CreateDriverBar(overlay), Painter.CreateDriverBar(overlay) }
  local mask = Painter.CreateClampMask(overlay, "NEAREST")
  Painter.AnchorMaskToFill(mask, overlay:GetStatusBarTexture(), bar, "HORIZONTAL", false, false, Painter.FillMaskMargins)
  local painted = bar:CreateTexture(nil, "ARTWORK")
  painted:SetAllPoints(bar)
  painted:SetSnapToPixelGrid(false)
  painted:SetTexelSnappingBias(0)
  painted:AddMaskTexture(mask)
  overlay.paintedTexture = painted
  overlay:SetFrameLevel(bar:GetFrameLevel())
  overlay:HookScript("OnShow", function() painted:Show() end)
  overlay:HookScript("OnHide", function() painted:Hide() end)
  return overlay
end

local function MirrorPoint(point, axis)
  if axis == "HORIZONTAL" then
    return (point:gsub("LEFT", "<"):gsub("RIGHT", "LEFT"):gsub("<", "RIGHT"))
  end
  return (point:gsub("TOP", "<"):gsub("BOTTOM", "TOP"):gsub("<", "BOTTOM"))
end

-- Pairs of {own point, relative point} that glue a marker bar to the end of a fill.
local trailingEdge = {
  HORIZONTAL = { { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" } },
  VERTICAL = { { "TOPLEFT", "BOTTOMLEFT" }, { "TOPRIGHT", "BOTTOMRIGHT" } },
}

local function GlueToEdge(marker, target, axis, mirrorOwn, mirrorTarget)
  for _, pair in ipairs(trailingEdge[axis]) do
    local own, relative = pair[1], pair[2]
    if mirrorOwn then own = MirrorPoint(own, axis) end
    if mirrorTarget then relative = MirrorPoint(relative, axis) end
    marker:SetPoint(own, target, relative, 0, 0)
  end
end

-- Overlay corners between marker fills, keyed by axis then reverse fill:
-- {top left point, marker index, its point}, {bottom right point, marker index, its point}.
local overlaySpan = {
  HORIZONTAL = {
    [false] = { { "TOPLEFT", 1, "TOPRIGHT" }, { "BOTTOMRIGHT", 2, "BOTTOMRIGHT" } },
    [true] = { { "TOPLEFT", 2, "TOPLEFT" }, { "BOTTOMRIGHT", 1, "BOTTOMLEFT" } },
  },
  VERTICAL = {
    [false] = { { "TOPLEFT", 2, "TOPLEFT" }, { "BOTTOMRIGHT", 1, "TOPRIGHT" } },
    [true] = { { "TOPLEFT", 1, "BOTTOMLEFT" }, { "BOTTOMRIGHT", 2, "BOTTOMRIGHT" } },
  },
}

local opaqueWhite = { 1, 1, 1, 1 }
local overlayMedia = { { "statusbar_atlas", true }, { "statusbar", false } }

local function OverlayTexture(bar, index)
  local name = bar.additionalBarsTextures and bar.additionalBarsTextures[index]
  if not name then
    return bar:GetStatusBarTexture()
  end
  for _, media in ipairs(overlayMedia) do
    local found = SharedMedia:Fetch(media[1], name, media[2])
    if found then
      return found
    end
  end
  return ""
end

-- Markers of an overlay. Each one: value (or keepValue), then either cover (a frame it spans)
-- or glueTo ("mask": end of the main fill, "offsetFill": end of the offset marker fill).
local function MarkersOf(bar, settings, orientation, backward)
  if settings.min and settings.max then
    return { { value = settings.min, cover = bar }, { value = settings.max, cover = bar } }
  end
  if not (settings.direction and settings.width) then
    return { { keepValue = true }, { keepValue = true } }
  end
  -- Markers 1 and 2 sit at 0 and width counted from the offset marker, itself counted from the main fill.
  local parent = bar:GetParent()
  local length
  if orientation.axis == "HORIZONTAL" then
    length = parent.width - bar.iconWidth
  else
    length = parent.height - bar.iconHeight
  end
  local mirrorOwn = Painter.Either(orientation.mirrored, Painter.Either(bar.additionalBarsInverse, backward))
  local function FromOffset(value)
    return { value = value, glueTo = "offsetFill", mirrorOwn = mirrorOwn, mirrorTarget = mirrorOwn, length = length }
  end
  return {
    FromOffset(0),
    FromOffset(settings.width),
    offset = { value = settings.offset or 0, glueTo = "mask", mirrorOwn = mirrorOwn,
               mirrorTarget = orientation.mirrored, length = length },
  }
end

-- Everything an overlay needs, computed from the bar and the additional bar settings; nothing is touched.
local function OverlayLayout(bar, index, settings)
  local orientation = OrientationOf(bar)
  local reverseFill = Painter.Either(orientation.reverseFill, bar.additionalBarsInverse)
  local relative = not (settings.min and settings.max) and settings.direction and settings.width
  local backward = relative and settings.direction ~= "forward"
  local timer = Painter.CanDrawDurationObject and Private.IsDurationObject(settings.durationObject)
    and settings.durationObject or nil
  return {
    axis = orientation.axis,
    reverseFill = Painter.Either(reverseFill, backward),
    minimum = bar.additionalBarsMin,
    maximum = bar.additionalBarsMax,
    sublevel = settings.underlay and -1 or DrawSublevel(index),
    texCoords = orientation.overlayTexCoords,
    color = bar.additionalBarsColors and bar.additionalBarsColors[index] or opaqueWhite,
    texture = OverlayTexture(bar, index),
    timer = timer,
    timerDirection = settings.durationObjectUseRemaining and "RemainingTime" or nil,
    markers = MarkersOf(bar, settings, orientation, backward),
  }
end

local function PlaceMarker(marker, spec, layout, glueTargets)
  marker:SetMinMaxValues(layout.minimum, layout.maximum)
  marker:ClearAllPoints()
  if spec.cover then
    marker:SetAllPoints(spec.cover)
  elseif spec.glueTo then
    GlueToEdge(marker, glueTargets[spec.glueTo], layout.axis, spec.mirrorOwn, spec.mirrorTarget)
  end
  if not spec.keepValue then
    marker:SetValue(spec.value)
  end
  if spec.length then
    if layout.axis == "HORIZONTAL" then
      marker:SetWidth(spec.length)
    else
      marker:SetHeight(spec.length)
    end
  end
end

local function ApplyOverlayLayout(bar, overlay, layout)
  overlay:Show()
  -- An atlas brings its own coordinates, so the coordinates go first.
  local painted = overlay.paintedTexture
  painted:SetTexCoord(unpack(layout.texCoords))
  Private.SetTextureOrAtlas(painted, layout.texture, "REPEAT", "REPEAT")
  painted:SetVertexColor(unpack(layout.color))
  painted:SetDrawLayer("ARTWORK", layout.sublevel)
  painted:Show()

  Painter.ApplyLinearDirection(overlay, layout.axis, layout.reverseFill, false)
  if layout.timer then
    Painter.SetTimer(overlay, layout.timer, layout.timerDirection, nil)
  else
    Painter.SetSecretProgress(overlay, 1, 1)
  end

  local markers, specs = overlay.markers, layout.markers
  local glueTargets = { mask = bar.fgMask }
  if specs.offset then
    markers[3] = markers[3] or Painter.CreateDriverBar(overlay)
    glueTargets.offsetFill = markers[3]:GetStatusBarTexture()
  end
  local function SetUpMarker(marker, spec)
    Painter.ApplyLinearDirection(marker, layout.axis, layout.reverseFill, false)
    PlaceMarker(marker, spec, layout, glueTargets)
  end
  SetUpMarker(markers[1], specs[1])
  SetUpMarker(markers[2], specs[2])
  if specs.offset then
    SetUpMarker(markers[3], specs.offset)
    markers[3]:Show()
  elseif markers[3] then
    markers[3]:Hide()
  end

  overlay:ClearAllPoints()
  for _, corner in ipairs(overlaySpan[layout.axis][layout.reverseFill]) do
    overlay:SetPoint(corner[1], markers[corner[2]]:GetStatusBarTexture(), corner[3])
  end
end

function barFuncs:UpdateNativeAdditionalBars()
  for index, settings in ipairs(self.additionalBars) do
    local overlay = self.secretExtraTextures[index]
    if not overlay then
      overlay = CreateOverlay(self)
      self.secretExtraTextures[index] = overlay
      Private.SnapLateTextures(self)
    end
    ApplyOverlayLayout(self, overlay, OverlayLayout(self, index, settings))
  end
  for index = #self.additionalBars + 1, #self.secretExtraTextures do
    self.secretExtraTextures[index]:Hide()
  end
end

local function InitBar(bar)
  bar.secretExtraTextures = {}
  hooksecurefunc(bar, "SetFrameLevel", function()
    for _, overlay in ipairs(bar.secretExtraTextures) do
      overlay:SetFrameLevel(bar:GetFrameLevel())
    end
  end)
end

Private.AuraBarNative = {
  canDrawDurationObject = Painter.CanDrawDurationObject,
  barFuncs = barFuncs,
  InitBar = InitBar,
}

if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local nativeOrientation = {
  ["HORIZONTAL_INVERSE"] = { "HORIZONTAL", false },
  ["HORIZONTAL"] = { "HORIZONTAL", true },
  ["VERTICAL"] = { "VERTICAL", false },
  ["VERTICAL_INVERSE"] = { "VERTICAL", true },
}
local canDrawDurationObject = Enum.StatusBarTimerDirection ~= nil
                              and CreateFrame("StatusBar").SetTimerDuration ~= nil
local canDrawRadialPercent = CreateFrame("Frame"):CreateTexture().SetRadialProgressBarPercent ~= nil
                             and CurveConstants ~= nil and CurveConstants.ZeroToOne ~= nil
                             and CurveConstants.Reverse ~= nil

local function GetNativeBar(self)
  if not self.nativeBar then
    local nativeBar = CreateFrame("StatusBar", nil, self)
    nativeBar:SetAllPoints(self)
    nativeBar:SetStatusBarTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite")
    nativeBar:GetStatusBarTexture():SetAlpha(0)
    nativeBar:Hide()
    local mask = self:CreateMaskTexture()
    mask:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite",
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    mask:SetTexelSnappingBias(0)
    mask:SetSnapToPixelGrid(false)
    local fill = nativeBar:GetStatusBarTexture()
    mask:SetPoint("TOPLEFT", fill, "TOPLEFT", -0.05, 0.05)
    mask:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0.05, -0.05)
    self.nativeBar = nativeBar
    self.nativeMask = mask
  end
  return self.nativeBar
end

local NativeRadialTick

local function HideNative(self)
  if self.FrameTick == NativeRadialTick then
    self.FrameTick = nil
    self.subRegionEvents:RemoveSubscriber("FrameTick", self)
  end
  if self.nativeLinearShown then
    self.nativeLinearShown = false
    self.foreground.texture:RemoveMaskTexture(self.nativeMask)
    self.nativeBar:Hide()
  end
  if self.nativeRadialShown then
    self.nativeRadialShown = false
    self.nativeRadial:Hide()
    self.foregroundSpinner:Show()
  end
end

local function ShowNativeLinear(self, inverse)
  local nativeBar = GetNativeBar(self)
  local orientation = nativeOrientation[self.orientation] or nativeOrientation.HORIZONTAL_INVERSE
  local reverse = orientation[2]
  inverse = inverse and true or false
  nativeBar:SetOrientation(orientation[1])
  nativeBar:SetReverseFill(not reverse ~= not inverse)
  if self.nativeMaskInverse ~= inverse or self.nativeMaskOrientation ~= self.orientation then
    self.nativeMaskInverse = inverse
    self.nativeMaskOrientation = self.orientation
    local mask, fill = self.nativeMask, nativeBar:GetStatusBarTexture()
    mask:ClearAllPoints()
    if not inverse then
      mask:SetPoint("TOPLEFT", fill, "TOPLEFT", -0.05, 0.05)
      mask:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0.05, -0.05)
    elseif orientation[1] == "HORIZONTAL" then
      mask:SetPoint("TOPLEFT", reverse and fill or self, reverse and "TOPRIGHT" or "TOPLEFT", -0.05, 0.05)
      mask:SetPoint("BOTTOMRIGHT", reverse and self or fill, reverse and "BOTTOMRIGHT" or "BOTTOMLEFT", 0.05, -0.05)
    else
      mask:SetPoint("TOPLEFT", reverse and self or fill, reverse and "TOPLEFT" or "BOTTOMLEFT", -0.05, 0.05)
      mask:SetPoint("BOTTOMRIGHT", reverse and fill or self, reverse and "TOPRIGHT" or "BOTTOMRIGHT", 0.05, -0.05)
    end
  end
  if not self.nativeLinearShown then
    self.nativeLinearShown = true
    self.foreground.texture:AddMaskTexture(self.nativeMask)
    nativeBar:Show()
  end
  self.progress = 1
  if self.useSmoothProgress then
    self.smoothProgress:ResetSmoothedValue(1)
  end
  self.foreground:SetValue(0, 1)
  return nativeBar
end

local function ShowNativeRadial(self, percent)
  if not self.nativeRadial then
    self.nativeRadial = self:CreateTexture(nil, "ARTWORK", nil, 1)
    self.nativeRadial:SetAllPoints(self)
  end
  local radial = self.nativeRadial
  Private.SetTextureOrAtlas(radial, self.currentTexture, self.textureWrapMode, self.textureWrapMode)
  radial:SetVertexColor(self.color_anim_r or self.color_r or 1, self.color_anim_g or self.color_g or 1,
                        self.color_anim_b or self.color_b or 1, self.color_anim_a or self.color_a or 1)
  radial:SetBlendMode(self.foreground:GetBlendMode())
  if radial.SetRadialProgressBarReverse then
    radial:SetRadialProgressBarReverse(self.orientation == "ANTICLOCKWISE")
  end
  radial:SetRotation(math.rad(self.auraRotation or 0))
  self.nativeRadialCoord = self.nativeRadialCoord or Private.TextureCoords.create(radial)
  self.nativeRadialCoord:SetFull()
  self.nativeRadialCoord:Transform(self.crop_x or 1, self.crop_y or 1, self.effectiveTexRotation or self.texRotation or 0,
                                   not self.mirror ~= not self.mirror_h, self.mirror_v, 0, 0)
  self.nativeRadialCoord:Apply()
  if radial.SetRadialProgressBarStartOffset
     and (self.nativeRadialOffset or (self.startAngle or 0) ~= 0 or (self.endAngle or 360) ~= 360) then
    radial:SetRadialProgressBarStartOffset(((self.startAngle or 0) + 180) % 360 / 360)
    radial:SetRadialProgressBarEndOffset(((self.endAngle or 360) + 180) % 360 / 360)
    self.nativeRadialOffset = true
  end
  radial:SetRadialProgressBarPercent(percent)
  if not self.nativeRadialShown then
    self.nativeRadialShown = true
    self.foregroundSpinner:Hide()
    radial:Show()
  end
end

local function EvaluateDurationPercent(self)
  local fillElapsed = not self.inverse ~= not self.inverseDirection
  local ok, percent = pcall(self.durationObject.EvaluateRemainingPercent, self.durationObject,
                            fillElapsed and CurveConstants.Reverse or CurveConstants.ZeroToOne)
  if ok and type(percent) == "number" then
    return percent
  end
end

NativeRadialTick = function(self)
  local percent = EvaluateDurationPercent(self)
  if percent then
    ShowNativeRadial(self, percent)
  end
end

local function UpdateNativeValue(self)
  if self.circular then
    if not self.inverseDirection and canDrawRadialPercent and type(self.secretPercent) == "number" then
      ShowNativeRadial(self, self.secretPercent)
      return true
    end
  elseif canDrawDurationObject and type(self.secretValue) == "number" and type(self.secretTotal) == "number" then
    local nativeBar = ShowNativeLinear(self, self.inverseDirection)
    nativeBar:SetMinMaxValues(0, self.secretTotal)
    if self.useSmoothProgress and Enum.StatusBarInterpolation then
      nativeBar:SetValue(self.secretValue, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
      nativeBar:SetValue(self.secretValue)
    end
    return true
  end
  return false
end

local function UpdateNativeTime(self)
  if not self.durationObject then
    return false
  end
  if self.circular then
    if not canDrawRadialPercent then
      return false
    end
    local percent = EvaluateDurationPercent(self)
    if not percent then
      return false
    end
    ShowNativeRadial(self, percent)
    if not self.paused and self.FrameTick ~= NativeRadialTick then
      if self.FrameTick then
        self.subRegionEvents:RemoveSubscriber("FrameTick", self)
      end
      self.FrameTick = NativeRadialTick
      self.subRegionEvents:AddSubscriber("FrameTick", self)
    end
    return true
  end
  if not canDrawDurationObject then
    return false
  end
  local nativeBar = ShowNativeLinear(self)
  local fillElapsed = not self.inverse ~= not self.inverseDirection
  nativeBar:SetTimerDuration(self.durationObject, Enum.StatusBarInterpolation.Immediate,
    fillElapsed and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime)
  return true
end

Private.ProgressTextureSecret = {
  HideNative = HideNative,
  NativeRadialTick = NativeRadialTick,
  UpdateNativeValue = UpdateNativeValue,
  UpdateNativeTime = UpdateNativeTime,
}

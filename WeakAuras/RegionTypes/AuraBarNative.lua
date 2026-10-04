if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local SharedMedia = LibStub("LibSharedMedia-3.0")

local angleCalculations = {
  [0] = {-1, -1, -1, 0, 0, -1, 0, 0},
  [90] = {1, -1, 0, -1, 1, 0, 0, 0},
  [180] = { 1, 1, 1, 0, 0, 1, 0, 0},
  [270] = {-1, 1, 0, 1, -1, 0, 0, 0},
}

local function SetCoordsByAngle(t, angle)
  if angleCalculations[angle] then
    return t:SetTexCoord(unpack(angleCalculations[angle]));
  end

  angle = math.rad(angle);
  local A, B, C, D, E, F = math.cos(angle), math.sin(angle), 1, -math.sin(angle), math.cos(angle), 1
  local det = A*E - B*D;
  local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;

  ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
  LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
  URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
  LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;

  t:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local flipPointX = {
  TOPLEFT = "TOPRIGHT",
  TOPRIGHT = "TOPLEFT",
  BOTTOMLEFT = "BOTTOMRIGHT",
  BOTTOMRIGHT = "BOTTOMLEFT"
}
local flipPointY = {
  TOPLEFT = "BOTTOMLEFT",
  TOPRIGHT = "BOTTOMRIGHT",
  BOTTOMLEFT = "TOPLEFT",
  BOTTOMRIGHT = "TOPRIGHT"
}

local whiteTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite"
local extraTextureWrapMode = "REPEAT"

local nativeOrientation = {
  ["HORIZONTAL"] = { "HORIZONTAL", false },
  ["HORIZONTAL_INVERSE"] = { "HORIZONTAL", true },
  ["VERTICAL"] = { "VERTICAL", true },
  ["VERTICAL_INVERSE"] = { "VERTICAL", false },
}
local canDrawDurationObject = Enum.StatusBarTimerDirection ~= nil
                              and CreateFrame("StatusBar").SetTimerDuration ~= nil

local barFuncs = {
  ["UsesNativeAdditionalBars"] = function(self)
    if self.nativeBar then
      return true
    end
    for _, additionalBar in ipairs(self.additionalBars) do
      if additionalBar.durationObject
         or Private.IsSecret(additionalBar.min, additionalBar.max, additionalBar.width, additionalBar.offset) then
        return true
      end
    end
    return false
  end,

  ["UpdateNativeAdditionalBars"] = function(self)
    for index, additionalBar in ipairs(self.additionalBars) do
      local abar = self.secretExtraTextures[index];
      if not abar then
        abar = CreateFrame("StatusBar", nil, self);
        abar:SetFrameLevel(self:GetFrameLevel());
        abar:SetStatusBarTexture(whiteTexture);
        abar:SetColorFill(1, 1, 1, 0);

        abar.texture = self:CreateTexture(nil, "ARTWORK");
        abar.texture:SetDrawLayer("ARTWORK", min(index, 7));
        abar:HookScript("OnShow", function() abar.texture:Show() end);
        abar:HookScript("OnHide", function() abar.texture:Hide() end);
        abar.texture:SetTexelSnappingBias(0)
        abar.texture:SetSnapToPixelGrid(false)
        abar.texture:SetAllPoints(self)

        abar.textureMask = abar:CreateMaskTexture();
        abar.textureMask:SetPoint("TOPLEFT", abar:GetStatusBarTexture(), "TOPLEFT", -0.01, 0.01);
        abar.textureMask:SetPoint("BOTTOMRIGHT", abar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
        abar.textureMask:SetTexture(whiteTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
        abar.textureMask:SetTexelSnappingBias(0)
        abar.textureMask:SetSnapToPixelGrid(false)
        abar.texture:AddMaskTexture(abar.textureMask);

        abar.offsetBar1 = CreateFrame("StatusBar", nil, abar);
        abar.offsetBar1:SetStatusBarTexture(whiteTexture);
        abar.offsetBar1:SetColorFill(1, 1, 1, 0);

        abar.offsetBar2 = CreateFrame("StatusBar", nil, abar);
        abar.offsetBar2:SetStatusBarTexture(whiteTexture);
        abar.offsetBar2:SetColorFill(1, 1, 1, 0);

        self.secretExtraTextures[index] = abar;
      end
      if abar.offsetBarAdditional then
        abar.offsetBarAdditional:Hide();
      end
      abar:Show();
      abar.texture:Show();
      abar.texture:SetDrawLayer("ARTWORK", additionalBar.underlay and -1 or min(index, 7));

      local minValue, maxValue = additionalBar.min, additionalBar.max
      local direction, width, offset = additionalBar.direction, additionalBar.width, additionalBar.offset
      local durationObject, durationObjectUseRemaining = additionalBar.durationObject, additionalBar.durationObjectUseRemaining

      abar.offsetBar1:SetMinMaxValues(self.additionalBarsMin, self.additionalBarsMax);
      abar.offsetBar2:SetMinMaxValues(self.additionalBarsMin, self.additionalBarsMax);

      local effectiveReverseFill = self.directionInverse;
      if self.additionalBarsInverse then
        effectiveReverseFill = not effectiveReverseFill;
      end

      abar.offsetBar1:ClearAllPoints();
      abar.offsetBar2:ClearAllPoints();
      if minValue and maxValue then
        abar.offsetBar1:SetAllPoints(self);
        abar.offsetBar2:SetAllPoints(self);

        abar.offsetBar1:SetValue(minValue);
        abar.offsetBar2:SetValue(maxValue);
      elseif direction and width then
        if not abar.offsetBarAdditional then
          abar.offsetBarAdditional = CreateFrame("StatusBar", nil, abar);
          abar.offsetBarAdditional:SetStatusBarTexture(whiteTexture);
          abar.offsetBarAdditional:SetColorFill(1, 1, 1, 0);
          abar.offsetBarAdditionalTexture = abar.offsetBarAdditional:GetStatusBarTexture();
        end

        abar.offsetBarAdditional:Show();
        abar.offsetBarAdditional:SetMinMaxValues(self.additionalBarsMin, self.additionalBarsMax);
        abar.offsetBarAdditional:SetValue(offset or 0);
        abar.offsetBarAdditional:ClearAllPoints();

        abar.offsetBar1:SetValue(0);
        abar.offsetBar2:SetValue(width);

        if self.horizontal then
          local barWidth = self:GetParent().width - self.iconWidth;
          abar.offsetBar1:SetWidth(barWidth);
          abar.offsetBar2:SetWidth(barWidth);
          abar.offsetBarAdditional:SetWidth(barWidth);
        else
          local barHeight = self:GetParent().height - self.iconHeight;
          abar.offsetBar1:SetHeight(barHeight);
          abar.offsetBar2:SetHeight(barHeight);
          abar.offsetBarAdditional:SetHeight(barHeight);
        end

        local maskPoint1, maskPoint2 = "TOPLEFT", "BOTTOMLEFT";
        local maskRelativePoint1, maskRelativePoint2 = "TOPRIGHT", "BOTTOMRIGHT";
        local offsetPoint1, offsetPoint2 = "TOPLEFT", "BOTTOMLEFT";
        local offsetRelativePoint1, offsetRelativePoint2 = "TOPRIGHT", "BOTTOMRIGHT";
        local flip = flipPointX
        if not self.horizontal then
          maskPoint1, maskPoint2 = "TOPLEFT", "TOPRIGHT";
          maskRelativePoint1, maskRelativePoint2 = "BOTTOMLEFT", "BOTTOMRIGHT";
          offsetPoint1, offsetPoint2 = "TOPLEFT", "TOPRIGHT";
          offsetRelativePoint1, offsetRelativePoint2 = "BOTTOMLEFT", "BOTTOMRIGHT";
          flip = flipPointY
        end
        if self.orientation == "HORIZONTAL_INVERSE" or self.orientation == "VERTICAL_INVERSE" then
          maskPoint1, maskPoint2  = flip[maskPoint1], flip[maskPoint2];
          maskRelativePoint1, maskRelativePoint2 = flip[maskRelativePoint1], flip[maskRelativePoint2];
          offsetPoint1, offsetPoint2 = flip[offsetPoint1], flip[offsetPoint2];
          offsetRelativePoint1, offsetRelativePoint2 = flip[offsetRelativePoint1], flip[offsetRelativePoint2];
        end

        if self.additionalBarsInverse then
          maskPoint1, maskPoint2  = flip[maskPoint1], flip[maskPoint2];
          offsetPoint1, offsetPoint2 = flip[offsetPoint1], flip[offsetPoint2];
          offsetRelativePoint1, offsetRelativePoint2 = flip[offsetRelativePoint1], flip[offsetRelativePoint2];
        end

        if direction ~= "forward" then
          effectiveReverseFill = not effectiveReverseFill;
          maskPoint1, maskPoint2  = flip[maskPoint1], flip[maskPoint2];
          offsetPoint1, offsetPoint2 = flip[offsetPoint1], flip[offsetPoint2];
          offsetRelativePoint1, offsetRelativePoint2 = flip[offsetRelativePoint1], flip[offsetRelativePoint2];
        end

        abar.offsetBarAdditional:SetPoint(maskPoint1, self.fgMask, maskRelativePoint1, 0, 0);
        abar.offsetBarAdditional:SetPoint(maskPoint2, self.fgMask, maskRelativePoint2, 0, 0);

        abar.offsetBar1:SetPoint(offsetPoint1, abar.offsetBarAdditionalTexture, offsetRelativePoint1, 0, 0);
        abar.offsetBar1:SetPoint(offsetPoint2, abar.offsetBarAdditionalTexture, offsetRelativePoint2, 0, 0);
        abar.offsetBar2:SetPoint(offsetPoint1, abar.offsetBarAdditionalTexture, offsetRelativePoint1, 0, 0);
        abar.offsetBar2:SetPoint(offsetPoint2, abar.offsetBarAdditionalTexture, offsetRelativePoint2, 0, 0);

        abar.offsetBarAdditional:SetReverseFill(effectiveReverseFill);
      end

      abar:ClearAllPoints();
      if self.horizontal and not effectiveReverseFill then
        abar:SetPoint("TOPLEFT", abar.offsetBar1:GetStatusBarTexture(), "TOPRIGHT");
        abar:SetPoint("BOTTOMRIGHT", abar.offsetBar2:GetStatusBarTexture(), "BOTTOMRIGHT");
      elseif self.horizontal then
        abar:SetPoint("TOPLEFT", abar.offsetBar2:GetStatusBarTexture(), "TOPLEFT");
        abar:SetPoint("BOTTOMRIGHT", abar.offsetBar1:GetStatusBarTexture(), "BOTTOMLEFT");
      elseif effectiveReverseFill then
        abar:SetPoint("TOPLEFT", abar.offsetBar1:GetStatusBarTexture(), "BOTTOMLEFT");
        abar:SetPoint("BOTTOMRIGHT", abar.offsetBar2:GetStatusBarTexture(), "BOTTOMRIGHT");
      else
        abar:SetPoint("TOPLEFT", abar.offsetBar2:GetStatusBarTexture(), "TOPLEFT");
        abar:SetPoint("BOTTOMRIGHT", abar.offsetBar1:GetStatusBarTexture(), "TOPRIGHT");
      end

      abar.offsetBar1:SetReverseFill(effectiveReverseFill);
      abar.offsetBar2:SetReverseFill(effectiveReverseFill);
      abar:SetReverseFill(effectiveReverseFill);

      local barOrientation = self.horizontal and "HORIZONTAL" or "VERTICAL"
      abar:SetOrientation(barOrientation);
      abar.offsetBar1:SetOrientation(barOrientation);
      abar.offsetBar2:SetOrientation(barOrientation);
      if abar.offsetBarAdditional then
        abar.offsetBarAdditional:SetOrientation(barOrientation);
      end

      if canDrawDurationObject and Private.IsDurationObject(durationObject) then
        local durDirection = durationObjectUseRemaining and Enum.StatusBarTimerDirection.RemainingTime or nil
        abar:SetTimerDuration(durationObject, nil, durDirection);
      else
        abar:SetMinMaxValues(0, 1);
        abar:SetValue(1);
      end

      local angle = 0;
      if self.orientation == "HORIZONTAL_INVERSE" then
        angle = 180;
      elseif self.orientation == "VERTICAL" then
        angle = 90;
      elseif self.orientation == "VERTICAL_INVERSE" then
        angle = 270;
      end
      SetCoordsByAngle(abar.texture, angle)

      local color = self.additionalBarsColors and self.additionalBarsColors[index];
      if (color) then
        abar.texture:SetVertexColor(unpack(color));
      else
        abar.texture:SetVertexColor(1, 1, 1, 1);
      end

      local texture = self.additionalBarsTextures and self.additionalBarsTextures[index];
      if texture then
        local texturePath = SharedMedia:Fetch("statusbar_atlas", texture, true) or SharedMedia:Fetch("statusbar", texture) or ""
        Private.SetTextureOrAtlas(abar.texture, texturePath, extraTextureWrapMode, extraTextureWrapMode)
      else
        Private.SetTextureOrAtlas(abar.texture, self:GetStatusBarTexture(), extraTextureWrapMode, extraTextureWrapMode)
      end
    end

    for i = #self.additionalBars + 1, #self.secretExtraTextures do
      self.secretExtraTextures[i]:Hide();
    end
  end,

  ["GetNativeBar"] = function(self, kind)
    self.nativeBars = self.nativeBars or {}
    local nativeBar = self.nativeBars[kind]
    if not nativeBar then
      nativeBar = CreateFrame("StatusBar", nil, self)
      nativeBar:SetAllPoints(self)
      nativeBar:SetStatusBarTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite")
      nativeBar:GetStatusBarTexture():SetAlpha(0)
      nativeBar:Hide()
      self.nativeBars[kind] = nativeBar
    end
    return nativeBar
  end,

  ["ShowNativeBar"] = function(self, nativeBar)
    if self.nativeBar ~= nativeBar then
      if self.nativeBar then
        self.nativeBar:Hide()
      end
      self.nativeBar = nativeBar
      nativeBar:Show()
      self:AnchorMaskToNativeBar()
      self:UpdateAdditionalBars()
    end
  end,

  ["HideNativeBar"] = function(self)
    if self.nativeBar then
      self.nativeBar:Hide()
      self.nativeBar = nil
      self:UpdateAnchors()
      self:UpdateAdditionalBars()
    end
  end,

  ["SetDurationObject"] = function(self, durationObject, fillElapsed)
    if not durationObject then
      self:HideNativeBar()
      return false
    end
    if not canDrawDurationObject then
      return false
    end
    local nativeBar = self:GetNativeBar("timer")
    nativeBar:SetTimerDuration(durationObject, Enum.StatusBarInterpolation.Immediate,
      fillElapsed and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime)
    self:ShowNativeBar(nativeBar)
    return true
  end,

  ["SetSecretValue"] = function(self, value, total, inverse, smooth)
    local nativeBar = self:GetNativeBar("value")
    nativeBar:SetMinMaxValues(0, total)
    if smooth and Enum.StatusBarInterpolation then
      nativeBar:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
      nativeBar:SetValue(value)
    end
    inverse = inverse and true or false
    local inverseChanged = self.nativeInverse ~= inverse
    self.nativeInverse = inverse
    if self.nativeBar == nativeBar then
      if inverseChanged then
        self:AnchorMaskToNativeBar()
      end
    else
      self:ShowNativeBar(nativeBar)
    end
  end,

  ["AnchorMaskToNativeBar"] = function(self)
    local orientation = nativeOrientation[self.orientation] or nativeOrientation.HORIZONTAL
    local reverse = orientation[2]
    local inverse = self.nativeInverse and self.nativeBars and self.nativeBar == self.nativeBars.value
    self.nativeBar:SetOrientation(orientation[1])
    self.nativeBar:SetReverseFill(not reverse ~= not inverse)
    local fill = self.nativeBar:GetStatusBarTexture()
    self.fgMask:ClearAllPoints()
    if not inverse then
      self.fgMask:SetPoint("TOPLEFT", fill, "TOPLEFT", -0.05, 0.05)
      self.fgMask:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0.05, -0.05)
    elseif orientation[1] == "HORIZONTAL" then
      self.fgMask:SetPoint("TOPLEFT", reverse and fill or self, reverse and "TOPRIGHT" or "TOPLEFT", -0.05, 0.05)
      self.fgMask:SetPoint("BOTTOMRIGHT", reverse and self or fill, reverse and "BOTTOMRIGHT" or "BOTTOMLEFT", 0.05, -0.05)
    else
      self.fgMask:SetPoint("TOPLEFT", reverse and self or fill, reverse and "TOPLEFT" or "BOTTOMLEFT", -0.05, 0.05)
      self.fgMask:SetPoint("BOTTOMRIGHT", reverse and fill or self, reverse and "TOPRIGHT" or "BOTTOMRIGHT", 0.05, -0.05)
    end
    self.fg:Show()
    if self.spark.sparkHidden == "ALWAYS" then
      self.spark:Hide()
    else
      self.spark:Show()
    end
  end,
}

Private.AuraBarNative = {
  canDrawDurationObject = canDrawDurationObject,
  barFuncs = barFuncs,
  InitBar = function(bar)
    bar.secretExtraTextures = {}
    hooksecurefunc(bar, "SetFrameLevel", function(self)
      for _, overlay in ipairs(self.secretExtraTextures) do
        overlay:SetFrameLevel(self:GetFrameLevel())
      end
    end)
  end,
}

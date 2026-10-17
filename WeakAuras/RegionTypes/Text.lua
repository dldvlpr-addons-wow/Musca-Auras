if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local SharedMedia = LibStub("LibSharedMedia-3.0");
local L = WeakAuras.L;
local FontStringScaleAnimationMode = Enum and Enum.FontStringScaleAnimationMode

local defaultFont = WeakAuras.defaultFont
local defaultFontSize = WeakAuras.defaultFontSize

local default = {
  displayText = "%p",
  outline = "OUTLINE",
  color = {1, 1, 1, 1},
  justify = "LEFT",
  selfPoint = "BOTTOM",
  anchorPoint = "CENTER",
  anchorFrameType = "SCREEN",
  xOffset = 0,
  yOffset = 0,
  font = defaultFont,
  fontSize = defaultFontSize,
  frameStrata = 1,
  customTextUpdate = "event",
  automaticWidth = "Auto",
  fixedWidth = 200,
  wordWrap = "WordWrap",

  shadowColor = { 0, 0, 0, 1},
  shadowXOffset = 1,
  shadowYOffset = -1
};

Private.regionPrototype.AddAlphaToDefault(default);

local properties = {
  color = {
    display = L["Color"],
    setter = "Color",
    secretCapable = true,
    type = "color",
  },
  fontSize = {
    display = L["Font Size"],
    setter = "SetTextHeight",
    type = "number",
    min = 6,
    softMax = 72,
    step = 1,
    default = 12
  },
  displayText = {
    display = L["Text"],
    setter = "ChangeText",
    secretLayers = "SetSecretTextLayers",
    secretRestore = "ClearSecretTextLayers",
    secretCapable = true,
    type = "string",
    control = "WeakAurasInputWithIndentation"
  },
}

Private.regionPrototype.AddProperties(properties, default);

--- @class TextRegion : Region
--- @field displayText string
--- @field text FontString
--- @field width number
--- @field height number
--- @field color_r number
--- @field color_g number
--- @field color_b number
--- @field color_a number
--- @field color_anim_r number
--- @field color_anim_g number
--- @field color_anim_b number
--- @field color_anim_a number
--- @field tooltipFrame Frame
--- @field ConfigureTextUpdate fun(self: TextRegion)
--- @field Update fun(self: TextRegion)
--- @field FrameTick fun(self: TextRegion)
--- @field ConfigureSubscribers fun(self: TextRegion)
--- @field Color fun(self: TextRegion, r : number, g: number, a : number)
--- @field ColorAnim fun(self: TextRegion, r : number, g: number, a : number)
--- @field GetColor fun(self: TextRegion): number, number, number, number
--- @field SetTextHeight fun(self: TextRegion, size: number)
--- @field ChangeText fun(self: TextRegion, msg: string)

local function PinTextTo(region, point)
  if region.textAnchorPoint ~= point then
    local text = region.text
    text:ClearAllPoints()
    text:SetPoint(point, region, point)
    region.textAnchorPoint = point
  end
end

local function TextPinPoint(region, data)
  if not region.automaticTextWidth then
    return data.justify
  end
  return region.anchorPoint or data.selfPoint
end

local function FollowAnchorPoint(region, point)
  if region.automaticTextWidth then
    PinTextTo(region, point)
  end
end

local fontObjectCounter = 0

local function create(parent)
  local region = CreateFrame("Frame", nil, parent);
  region.regionType = "text"
  region:SetMovable(true);

  local text = region:CreateFontString(nil, "OVERLAY");
  region.text = text;
  text:SetWordWrap(true);
  text:SetNonSpaceWrap(true);

  local fontObject = CreateFont("WeakAuras-Text-Font" .. fontObjectCounter)
  fontObjectCounter =  fontObjectCounter + 1
  region.text:SetFontObject(fontObject)
  region.fontObject = fontObject

  Private.regionPrototype.create(region);

  local prototypeSetAnchor = region.SetAnchor
  region.SetAnchor = function(self, point, ...)
    prototypeSetAnchor(self, point, ...)
    FollowAnchorPoint(self, point)
  end

  return region;
end

--- @type fun(parent: Frame, region: TextRegion, data: AuraData)
local function modify(parent, region, data)
  Private.regionPrototype.modify(parent, region, data);
  local text = region.text;
  local fontObject = region.fontObject

  local fontPath = SharedMedia:Fetch("font", data.font);
  local outline = data.outline == "None" and "" or data.outline
  local slugFont = data.outline == "SLUG" or data.outline == "OUTLINE|SLUG"
  if text.SetScaleAnimationMode and FontStringScaleAnimationMode then
    text:SetScaleAnimationMode(slugFont and FontStringScaleAnimationMode.Vertex or FontStringScaleAnimationMode.FontSize)
  end
  if text.SetSmoothScaling then
    text:SetSmoothScaling(data.smoothScaling or false) -- doesn't accept nil
  end
  fontObject:SetJustifyH(data.justify);
  Private.ApplyTextFont(text, fontObject, fontPath, data.fontSize, outline,
    data.shadowColor, data.shadowXOffset, data.shadowYOffset)
  text:SetText("000")

  text:ClearAllPoints();
  text:SetPoint("CENTER", UIParent, "CENTER");

  region.width = text:GetWidth();
  region.height = text:GetStringHeight();
  if Private.IsSecret(region.width) or region.width <= 0 then
    region.width = 200
  end
  if Private.IsSecret(region.height) or region.height <= 0 then
    region.height = 30
  end
  region:SetWidth(region.width);
  region:SetHeight(region.height);
  text:SetText("")

  local tooltipType = Private.CanHaveTooltip(data);
  if(tooltipType and data.useTooltip) then
    if not region.tooltipFrame then
      region.tooltipFrame = CreateFrame("Frame", nil, region);
      region.tooltipFrame:SetAllPoints(region);
      region.tooltipFrame:SetScript("OnEnter", function()
        Private.ShowMouseoverTooltip(region, region);
      end);
      region.tooltipFrame:SetScript("OnLeave", Private.HideTooltip);
    end
    region.tooltipFrame:EnableMouseMotion(true);
    region.tooltipFrame:SetMouseClickEnabled(false);
  elseif region.tooltipFrame then
    region.tooltipFrame:EnableMouseMotion(false);
  end

  text:SetTextHeight(data.fontSize);

  local fixedWidth = data.automaticWidth == "Fixed"
  region.automaticTextWidth = not fixedWidth
  region.textAnchorPoint = nil
  PinTextTo(region, TextPinPoint(region, data))

  local SetText;

  if (data.automaticWidth == "Fixed") then
    if (data.wordWrap == "WordWrap") then
      text:SetWordWrap(true);
      text:SetNonSpaceWrap(true);
    else
      text:SetWordWrap(false);
      text:SetNonSpaceWrap(false);
    end

    text:SetWidth(data.fixedWidth);
    region:SetWidth(data.fixedWidth);
    region.width = data.fixedWidth;
    SetText = function(textStr)
      if text:GetFont() then
        text:SetText(WeakAuras.ReplaceRaidMarkerSymbols(textStr));
      end

      local height = text:GetStringHeight();

      if not Private.IsSecret(height) and region.height ~= height then
        region.height = height
        region:SetHeight(height)
        if data.parent then
          Private.EnsureRegion(data.parent)
          if Private.regions[data.parent].region.PositionChildren then
            Private.regions[data.parent].region:PositionChildren()
          end
        end
      end
    end
  else
    text:SetWidth(0);
    text:SetWordWrap(true);
    text:SetNonSpaceWrap(true);
    SetText = function(textStr)
      if Private.IsSecret(textStr) then
        if text:GetFont() then
          text:SetText(textStr)
        end
      elseif textStr ~= text.displayText then
        if text:GetFont() then
          text:SetText(WeakAuras.ReplaceRaidMarkerSymbols(textStr));
        end
        -- If the text changes we need to figure out the text size
        -- To unset scaling we need to temporarily detach the text from
        -- the region
        text:SetParent(UIParent)
        local width = text:GetWidth();
        local height = text:GetStringHeight();
        if not Private.IsSecret(width, height) and (width ~= region.width or height ~= region.height) then
          region.width = width
          region.height = height
          region:SetWidth(region.width);
          region:SetHeight(region.height);
          if(data.parent and Private.regions[data.parent].region.PositionChildren) then
            Private.regions[data.parent].region:PositionChildren();
          end
        end
        text:SetParent(region)
      end
    end
  end

  local containsCustomText = false
  if Private.ContainsCustomPlaceHolder(data.displayText) then
    containsCustomText = true
  end

  local formatters, everyFrameFormatters
  do
    local getter = function(key, default)
      local fullKey = "displayText_format_" .. key
      if (data[fullKey] == nil) then
        data[fullKey] = default
      end
      return data[fullKey]
    end

    local texts = {}
    tinsert(texts, data.displayText)

    if type(data.conditions) == "table" then
      for _, condition in ipairs(data.conditions) do
        if type(condition.changes) == "table" then
          for _, change in ipairs(condition.changes) do
            if type(change.property) == "string"
            and change.property == "displayText"
            and type(change.value) == "string"
            and Private.ContainsAnyPlaceHolders(change.value)
            then
              if not containsCustomText and Private.ContainsCustomPlaceHolder(change.value) then
                containsCustomText = true
              end
              tinsert(texts, change.value)
            end
          end
        end
      end
    end

    formatters, everyFrameFormatters = Private.CreateFormatters(texts, getter, false, data)
  end

  local layerTexts = { data.displayText }
  local layersTick = Private.ContainsAnyPlaceHolders(data.displayText)
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    local value
    for _, change in ipairs(type(condition.changes) == "table" and condition.changes or {}) do
      if change.property == "displayText" then
        value = change.value
      end
    end
    if type(value) == "string" then
      layerTexts[#layerTexts + 1] = value
      layersTick = layersTick or Private.ContainsAnyPlaceHolders(value)
    end
  end

  local customTextFunc = nil
  if containsCustomText and data.customText and data.customText ~= "" then
    customTextFunc = WeakAuras.LoadFunction("return "..data.customText, data.id)
    region.values.customTextUpdateThrottle = data.customTextUpdateThrottle or 0
  end

  function region:ConfigureTextUpdate()
    if Private.UnbindDurationText then
      Private.UnbindDurationText(self)
    end
    local UpdateText
    if self.displayText and Private.ContainsAnyPlaceHolders(self.displayText) then
      UpdateText = function()
        if Private.UpdateNativeText and Private.UpdateNativeText(self, self, self.displayText, formatters) then
          return
        end
        local textStr = Private.ReplacePlaceHolders(self.displayText, self, nil, false, formatters);
        if not Private.IsSecret(textStr) and textStr == "" then
          textStr = " "
        end

        SetText(textStr)
      end
    end

    local Update
    if customTextFunc and self.displayText and Private.ContainsCustomPlaceHolder(self.displayText) then
      Update = function(self)
        if not self.values.customTextUpdated then
          self.values.custom = Private.RunCustomTextFunc(self, customTextFunc)
          self.values.lastCustomTextUpdate = GetTime()
          self.values.customTextUpdated = true
        end
        self:UpdateProgress()
        UpdateText()
      end
    else
      if UpdateText then
        Update = function()
          self:UpdateProgress()
          UpdateText()
        end
      else
        Update = function() self:UpdateProgress() end
      end
    end

    local FrameTick
    if Private.ContainsPlaceHolders(self.displayText, "p")
      or Private.AnyEveryFrameFormatters(self.displayText, everyFrameFormatters)
    then
      FrameTick = UpdateText
    end

    if customTextFunc and data.customTextUpdate == "update" then
      if Private.ContainsCustomPlaceHolder(self.displayText) then
        FrameTick = function()
          if not self.values.lastCustomTextUpdate
          or self.values.lastCustomTextUpdate + self.values.customTextUpdateThrottle < GetTime()
          then
            self.values.custom = Private.RunCustomTextFunc(self, customTextFunc)
            self.values.lastCustomTextUpdate = GetTime()
            self.values.customTextUpdated = true
          end
          UpdateText()
        end
      end
    end

    if self.secretTextAlphas then
      local update, tick = Update, FrameTick
      Update = function(...)
        update(...)
        self:UpdateSecretTextLayers()
      end
      if tick or layersTick then
        FrameTick = function()
          if tick then
            tick()
          end
          self:UpdateSecretTextLayers()
        end
      end
    end

    self.Update = Update
    self.FrameTick = FrameTick

    if not UpdateText then
      local textStr = self.displayText
      textStr = textStr:gsub("\\n", "\n");
      SetText(textStr)
    end
  end

  function region:ConfigureSubscribers()
    if self.FrameTick then
      self.subRegionEvents:AddSubscriber("FrameTick", self)
    else
      self.subRegionEvents:RemoveSubscriber("FrameTick", self)
    end

    if self.Update and self.state then
      self:Update()
    end
  end

  region.secretTextAlphas = nil
  for _, layer in ipairs(region.secretTextLayers or {}) do
    layer:Hide()
  end
  text:SetAlpha(1)

  function region:Color(r, g, b, a)
    region.color_r = r;
    region.color_g = g;
    region.color_b = b;
    region.color_a = a;
    if (r or g or b) then
      a = a or 1;
    end
    text:SetTextColor(region.color_anim_r or r, region.color_anim_g or g, region.color_anim_b or b, region.color_anim_a or a);
    if region.secretTextAlphas then
      region:UpdateSecretTextLayers()
    end
  end

  function region:ColorAnim(r, g, b, a)
    region.color_anim_r = r;
    region.color_anim_g = g;
    region.color_anim_b = b;
    region.color_anim_a = a;
    if (r or g or b) then
      a = a or 1;
    end
    text:SetTextColor(r or region.color_r, g or region.color_g, b or region.color_b, a or region.color_a);
    if region.secretTextAlphas then
      region:UpdateSecretTextLayers()
    end
  end

  function region:GetColor()
    return region.color_r or data.color[1], region.color_g or data.color[2],
      region.color_b or data.color[3], region.color_a or data.color[4];
  end

  region:Color(data.color[1], data.color[2], data.color[3], data.color[4]);

  function region:SetTextHeight(size)
    local fontPath = SharedMedia:Fetch("font", data.font);
    region.text:SetFont(fontPath, size, outline);
    region.text:SetTextHeight(size)
  end

  function region:ChangeText(msg)
    self.displayText = msg
    self:ConfigureTextUpdate()
    self:ConfigureSubscribers()
  end

  local function LayerText(textStr)
    if not Private.ContainsAnyPlaceHolders(textStr) then
      return WeakAuras.ReplaceRaidMarkerSymbols((textStr:gsub("\\n", "\n")))
    end
    textStr = Private.ReplacePlaceHolders(textStr, region, nil, false, formatters)
    if Private.IsSecret(textStr) then
      return textStr
    end
    return WeakAuras.ReplaceRaidMarkerSymbols(textStr)
  end

  local wordWrap = data.automaticWidth ~= "Fixed" or data.wordWrap == "WordWrap"

  function region:UpdateSecretTextLayers()
    local point = self.textAnchorPoint or "CENTER"
    local factor = 0
    for index, textStr in ipairs(layerTexts) do
      factor = factor + 1
      local layer = self.secretTextLayers[index]
      layer:SetAlpha(self.secretTextAlphas[factor])
      for depth = 1, #layerTexts - index do
        factor = factor + 1
        self.secretTextHolders[index][depth]:SetAlpha(self.secretTextAlphas[factor])
      end
      layer:SetFontObject(fontObject)
      layer:SetFont(text:GetFont())
      layer:SetTextColor(text:GetTextColor())
      layer:SetWordWrap(wordWrap)
      layer:SetNonSpaceWrap(wordWrap)
      layer:SetWidth(self.automaticTextWidth and 0 or data.fixedWidth)
      layer:ClearAllPoints()
      layer:SetPoint(point, self, point)
      layer:SetText(LayerText(textStr))
      layer:Show()
    end
  end

  function region:SetSecretTextLayers(...)
    local activate = not self.secretTextAlphas
    self.secretTextAlphas = { ... }
    self.secretTextLayers = self.secretTextLayers or {}
    self.secretTextHolders = self.secretTextHolders or {}
    for index = 1, #layerTexts do
      local holders = self.secretTextHolders[index] or {}
      self.secretTextHolders[index] = holders
      local parentFrame = self
      for depth = 1, #layerTexts - index do
        if not holders[depth] then
          holders[depth] = CreateFrame("Frame", nil, parentFrame)
          holders[depth]:SetAllPoints(self)
        end
        parentFrame = holders[depth]
      end
      self.secretTextLayers[index] = self.secretTextLayers[index] or parentFrame:CreateFontString(nil, "OVERLAY")
      self.secretTextLayers[index]:SetParent(parentFrame)
    end
    if activate then
      text:SetAlpha(0)
      self:ConfigureTextUpdate()
      self:ConfigureSubscribers()
    end
    self:UpdateSecretTextLayers()
  end

  function region:ClearSecretTextLayers()
    self.secretTextAlphas = nil
    for _, layer in ipairs(self.secretTextLayers or {}) do
      layer:Hide()
    end
    text:SetAlpha(1)
    self:ConfigureTextUpdate()
    self:ConfigureSubscribers()
  end

  region.displayText = data.displayText
  region.durationTimeFormat = data.displayText_format_p_time_format
  region.durationThreshold = data.displayText_format_p_time_dynamic_threshold
  region.durationPrecision = data.displayText_format_p_time_precision
  region.durationLegacyFloor = data.displayText_format_p_time_legacy_floor
  region:ConfigureTextUpdate()
  region:ConfigureSubscribers()
  Private.regionPrototype.modifyFinish(parent, region, data);
end

local function validate(data)
  Private.EnforceSubregionExists(data, "subbackground")
end

Private.RegisterRegionType("text", create, modify, default, properties, validate);

-- Fallback region type

local function fallbackmodify(parent, region, data)
  Private.regionPrototype.modify(parent, region, data);
  local text = region.text;
  local fontObject = region.fontObject

  fontObject:SetFont(STANDARD_TEXT_FONT, data.fontSize, data.outline and "OUTLINE" or "");
  if text:GetFont() then
    text:SetText(WeakAuras.L["Region type %s not supported"]:format(data.regionType));
  end

  text:ClearAllPoints();
  text:SetPoint("CENTER", region, "CENTER");

  region:SetWidth(text:GetWidth());
  region:SetHeight(text:GetStringHeight());

  region.Update = function() end

  Private.regionPrototype.modifyFinish(parent, region, data);
end

Private.RegisterRegionType("fallback", create, fallbackmodify, default);

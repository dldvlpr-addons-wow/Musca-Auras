if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local Type, Version = "WeakAurasColorPicker", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI then return end
if (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local UIParent, CreateFrame = UIParent, CreateFrame
local picker = ColorPickerFrame

local function readPickerColor()
  local r, g, b = picker:GetColorRGB()
  return r, g, b, picker:GetColorAlpha()
end

local function applyPickedColor(widget, r, g, b, a, confirmed)
  if not widget.HasAlpha then a = 1 end
  local unchanged = r == widget.r and g == widget.g and b == widget.b and a == widget.a
  if unchanged then return end
  widget:SetColor(r, g, b, a)
  if picker:IsVisible() then
    widget:Fire("OnValueChanged", r, g, b, a)
  elseif confirmed then
    widget:Fire("OnValueConfirmed", r, g, b, a)
  end
end

local function relay(eventName)
  return function(frame) return frame.obj:Fire(eventName) end
end

local function openPicker(frame)
  picker:Hide()
  local widget = frame.obj
  if widget.disabled then
    AceGUI:ClearFocus()
    return
  end
  picker:SetFrameStrata("FULLSCREEN_DIALOG")
  picker:SetFrameLevel(frame:GetFrameLevel() + 10)
  picker:SetClampedToScreen(true)

  local startR, startG, startB, startA = widget.r, widget.g, widget.b, widget.a or 1

  local request = { r = startR, g = startG, b = startB }
  request.opacity = startA
  request.hasOpacity = widget.HasAlpha
  request.swatchFunc = function()
    local r, g, b, a = readPickerColor()
    applyPickedColor(widget, r, g, b, a)
  end
  request.opacityFunc = function()
    local r, g, b, a = readPickerColor()
    applyPickedColor(widget, r, g, b, a, true)
  end
  request.cancelFunc = function()
    applyPickedColor(widget, startR, startG, startB, startA, true)
  end

  OptionsPrivate.PrepareColorPalette(request)
  picker:SetupColorPickerAndShow(request)
  OptionsPrivate.ShowColorPalette()
  AceGUI:ClearFocus()
end

local widgetMethods = {
  ["OnAcquire"] = function(self)
    self:SetLabel(nil)
    self:SetDisabled(nil)
    self:SetHasAlpha(false)
    self:SetColor(0, 0, 0, 1)
    self:SetWidth(200)
    self:SetHeight(24)
  end,

  ["SetLabel"] = function(self, text)
    return self.text:SetText(text)
  end,

  ["SetColor"] = function(self, r, g, b, a)
    self.r, self.g, self.b, self.a = r or 1, g or 1, b or 1, a or 1
    self.colorSwatch:SetVertexColor(self.r, self.g, self.b, self.a)
  end,

  ["SetHasAlpha"] = function(self, hasAlpha)
    self.HasAlpha = hasAlpha
  end,

  ["SetDisabled"] = function(self, disabled)
    self.disabled = disabled
    local shade = disabled and 0.5 or 1
    self.text:SetTextColor(shade, shade, shade)
    if disabled then
      self.frame:Disable()
    else
      self.frame:Enable()
    end
  end,
}

local function Constructor()
  local button = CreateFrame("Button", nil, UIParent)
  button:EnableMouse(true)
  button:Hide()

  local swatch = button:CreateTexture(nil, "OVERLAY")
  swatch:SetSize(19, 19)
  swatch:SetTexture(130939)
  swatch:SetPoint("LEFT")

  local backdrop = button:CreateTexture(nil, "BACKGROUND")
  backdrop:SetSize(16, 16)
  backdrop:SetColorTexture(1, 1, 1)
  backdrop:SetPoint("CENTER", swatch)
  backdrop:Show()
  swatch.background = backdrop

  local tiles = button:CreateTexture(nil, "BACKGROUND")
  tiles:SetSize(14, 14)
  tiles:SetTexture(188523)
  tiles:SetTexCoord(0.25, 0, 0.5, 0.25)
  tiles:SetVertexColor(1, 1, 1, 0.75)
  tiles:SetDesaturated(true)
  tiles:SetPoint("CENTER", swatch)
  tiles:Show()
  swatch.checkers = tiles

  local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetHeight(24)
  label:SetJustifyH("LEFT")
  label:SetTextColor(1, 1, 1)
  label:SetPoint("LEFT", swatch, "RIGHT", 2, 0)
  label:SetPoint("RIGHT")

  button:SetScript("OnEnter", relay("OnEnter"))
  button:SetScript("OnLeave", relay("OnLeave"))
  button:SetScript("OnClick", openPicker)

  local widget = {}
  widget.type = Type
  widget.frame = button
  widget.colorSwatch = swatch
  widget.text = label
  for name, method in pairs(widgetMethods) do
    widget[name] = method
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

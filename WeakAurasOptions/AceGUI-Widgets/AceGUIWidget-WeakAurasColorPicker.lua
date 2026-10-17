-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Based on the AceGUI-3.0 ColorPicker widget.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local Type, Version = "WeakAurasColorPicker", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Only GetColorRGB, GetColorAlpha and SetupColorPickerAndShow exist in both ColorPickerFrame families.
local function ReadPicker()
  local r, g, b = ColorPickerFrame:GetColorRGB()
  return r, g, b, ColorPickerFrame:GetColorAlpha()
end

-- A change made while the picker is open is live; once it is closed, only a confirmed change is reported.
local function ApplyPickedColor(widget, confirmed, r, g, b, a)
  if not widget.HasAlpha then a = 1 end
  if r == widget.r and g == widget.g and b == widget.b and a == widget.a then return end
  widget:SetColor(r, g, b, a)
  if ColorPickerFrame:IsVisible() then
    widget:Fire("OnValueChanged", r, g, b, a)
  elseif confirmed then
    widget:Fire("OnValueConfirmed", r, g, b, a)
  end
end

local function OpenPicker(frame)
  local widget = frame.obj
  ColorPickerFrame:Hide()
  if widget.disabled then
    AceGUI:ClearFocus()
    return
  end
  ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
  ColorPickerFrame:SetFrameLevel(frame:GetFrameLevel() + 10)
  ColorPickerFrame:SetClampedToScreen(true)

  local startR, startG, startB, startA = widget.r, widget.g, widget.b, widget.a or 1
  local request = {
    r = startR, g = startG, b = startB,
    opacity = startA,
    hasOpacity = widget.HasAlpha,
    swatchFunc = function() ApplyPickedColor(widget, false, ReadPicker()) end,
    opacityFunc = function() ApplyPickedColor(widget, true, ReadPicker()) end,
    cancelFunc = function() ApplyPickedColor(widget, true, startR, startG, startB, startA) end,
  }
  OptionsPrivate.PrepareColorPalette(request)
  ColorPickerFrame:SetupColorPickerAndShow(request)
  OptionsPrivate.ShowColorPalette()
  AceGUI:ClearFocus()
end

local methods = {}

function methods:OnAcquire()
  self:SetLabel(nil)
  self:SetDisabled(nil)
  self:SetHasAlpha(false)
  self:SetColor(0, 0, 0, 1)
  self:SetWidth(200)
  self:SetHeight(24)
end

function methods:SetLabel(text)
  self.text:SetText(text)
end

function methods:SetColor(r, g, b, a)
  self.r, self.g, self.b, self.a = r or 1, g or 1, b or 1, a or 1
  self.colorSwatch:SetVertexColor(self.r, self.g, self.b, self.a)
end

function methods:SetHasAlpha(hasAlpha)
  self.HasAlpha = hasAlpha
end

function methods:SetDisabled(disabled)
  self.disabled = disabled
  local shade = disabled and 0.5 or 1
  self.text:SetTextColor(shade, shade, shade)
  if disabled then
    self.frame:Disable()
  else
    self.frame:Enable()
  end
end

local function Constructor()
  local frame = CreateFrame("Button", nil, UIParent)
  frame:Hide()
  frame:EnableMouse(true)
  frame:SetScript("OnEnter", function(self) self.obj:Fire("OnEnter") end)
  frame:SetScript("OnLeave", function(self) self.obj:Fire("OnLeave") end)
  frame:SetScript("OnClick", OpenPicker)

  local swatch = frame:CreateTexture(nil, "OVERLAY")
  swatch:SetSize(19, 19)
  swatch:SetTexture(130939)
  swatch:SetPoint("LEFT")

  -- White square behind the swatch, then a checkerboard that shows through a translucent color.
  local background = frame:CreateTexture(nil, "BACKGROUND")
  background:SetSize(16, 16)
  background:SetColorTexture(1, 1, 1)
  background:SetPoint("CENTER", swatch)
  swatch.background = background

  local checkers = frame:CreateTexture(nil, "BACKGROUND")
  checkers:SetSize(14, 14)
  checkers:SetTexture(188523)
  checkers:SetTexCoord(0.25, 0, 0.5, 0.25)
  checkers:SetDesaturated(true)
  checkers:SetVertexColor(1, 1, 1, 0.75)
  checkers:SetPoint("CENTER", swatch)
  swatch.checkers = checkers

  local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetHeight(24)
  label:SetJustifyH("LEFT")
  label:SetTextColor(1, 1, 1)
  label:SetPoint("LEFT", swatch, "RIGHT", 2, 0)
  label:SetPoint("RIGHT")

  local widget = { type = Type, frame = frame, colorSwatch = swatch, text = label }
  for name, method in pairs(methods) do
    widget[name] = method
  end
  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

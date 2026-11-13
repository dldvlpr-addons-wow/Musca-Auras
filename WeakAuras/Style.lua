-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Look of the interface of Musca: the colors, fonts, spaces and durations of DESIGN.md, and the few controls built
-- from them. Brass on graphite, square corners, 1 pixel borders. No color is written elsewhere.

local Style = {}
Private.Style = Style

local white = "Interface\\Buttons\\WHITE8X8"
Style.white = white

Style.colors = {
  background = { 0.059, 0.055, 0.047, 0.97 },
  band = { 0.082, 0.078, 0.067, 1 },
  surface = { 0.114, 0.110, 0.094, 1 },
  raised = { 0.153, 0.145, 0.129, 1 },
  selection = { 0.184, 0.145, 0.071, 1 },
  well = { 0.031, 0.027, 0.024, 1 },
  border = { 0.196, 0.188, 0.169, 1 },
  borderHover = { 0.271, 0.259, 0.235, 1 },
  borderField = { 0.478, 0.467, 0.439, 1 },
  text = { 0.945, 0.941, 0.929, 1 },
  textSecondary = { 0.792, 0.780, 0.761, 1 },
  textQuiet = { 0.635, 0.620, 0.592, 1 },
  textDisabled = { 0.478, 0.467, 0.439, 1 },
  primary = { 0.910, 0.710, 0.263, 1 },
  primaryHover = { 0.957, 0.827, 0.573, 1 },
  primaryLow = { 0.800, 0.596, 0, 1 },
  primaryFill = { 0.667, 0.494, 0, 1 },
  onPrimary = { 0.059, 0.055, 0.047, 1 },
  accent = { 0.400, 0.792, 1, 1 },
  success = { 0.404, 0.824, 0.514, 1 },
  warning = { 0.973, 0.627, 0.322, 1 },
  error = { 0.965, 0.427, 0.404, 1 },
  focus = { 0.957, 0.827, 0.573, 1 },
  sheen = { 1, 1, 1, 0.04 },
  rule = { 0.910, 0.710, 0.263, 0.55 },
  shadow = { 0, 0, 0, 0.6 },
  -- Placement mode.
  veil = { 0.031, 0.027, 0.024, 0.40 },
  grid = { 0.945, 0.941, 0.929, 0.07 },
  gridMajor = { 0.945, 0.941, 0.929, 0.14 },
  gridAxis = { 0.910, 0.710, 0.263, 0.45 },
  barBackground = { 0.082, 0.078, 0.067, 0.96 },
  panelBackground = { 0.114, 0.110, 0.094, 0.96 },
  boxBackground = { 0.031, 0.027, 0.024, 0.30 },
  boxBorder = { 0.792, 0.780, 0.761, 0.55 },
  boxBackgroundHover = { 0.031, 0.027, 0.024, 0.45 },
  boxBorderHover = { 0.945, 0.941, 0.929, 0.90 },
  boxBackgroundSelected = { 0.176, 0.122, 0, 0.35 },
  labelBackground = { 0.059, 0.055, 0.047, 0.85 },
  snapGuide = { 0.400, 0.792, 1, 0.90 },
  snapTarget = { 0, 0.145, 0.216, 0.35 },
  link = { 0, 0.686, 0.941, 0.80 },
  linkSelected = { 0.671, 0.878, 1, 1 },
}

--- r, g, b, a of a color of the table, its alpha replaced by alpha when given.
function Style.Color(name, alpha)
  local color = Style.colors[name]
  return color[1], color[2], color[3], alpha or color[4]
end

--- Escape sequence of a color of the table for a chat line or a text: "|cffrrggbb", closed by "|r".
function Style.Hex(name)
  local r, g, b = Style.Color(name)
  return ("|cff%02x%02x%02x"):format(r * 255 + 0.5, g * 255 + 0.5, b * 255 + 0.5)
end

-- Colors written inside the translated texts, by the color of the table that replaces them when shown.
local writtenColors = {}
for name, list in pairs({
  error = "ff0000 ff2020 ffaaaa",
  success = "00ff00 33ff99 aaffaa",
  primary = "ffd200 ffd100 e0e000 ffff00 ffff99 ffff77 eda55f 00ccff",
  warning = "ffcc00 ff9900 ff9933",
  textQuiet = "b0b0b0 999999 777777",
  text = "ffffff",
  accent = "4080ff 80a0ff 00ffff 9900ff aaaaff 99ccff",
}) do
  for hex in list:gmatch("%x+") do
    writtenColors[hex] = name
  end
end

--- text with the colors written in it replaced by the colors of the table; the other colors are kept.
function Style.Markup(text)
  return (text:gsub("|c[fF][fF](%x%x%x%x%x%x)", function(hex)
    local name = writtenColors[hex:lower()]
    return name and Style.Hex(name)
  end))
end

local fonts = "Interface\\AddOns\\WeakAuras\\Media\\Fonts\\"
Style.fonts = {
  text = fonts .. "FiraSans-Medium.ttf",
  title = fonts .. "FiraSansCondensed-Heavy.ttf",
  number = fonts .. "FiraMono-Medium.ttf",
}
Style.sizes = { xs = 10, s = 12, m = 14, l = 17 }
-- Fira has no glyph for these languages: the font of the game, one size up.
local glyphsMissing = ({ zhCN = true, zhTW = true, koKR = true })[GetLocale()]

--- Font of a FontString or an EditBox: role text, title or number; size xs, s, m or l.
function Style.SetFont(region, role, size)
  local path = glyphsMissing and STANDARD_TEXT_FONT or Style.fonts[role]
  region:SetFont(path, Style.sizes[size] + (glyphsMissing and 1 or 0), "")
end

function Style.NewText(parent, role, size, color, layer)
  local text = parent:CreateFontString(nil, layer or "OVERLAY")
  Style.SetFont(text, role, size)
  text:SetTextColor(Style.Color(color or "text"))
  return text
end

Style.space = { 2, 4, 8, 12, 16, 24 }
Style.durations = { brief = 0.12, short = 0.20, medium = 0.35, long = 0.45 }

--- A flat fill and a 1 pixel border, on a frame made with BackdropTemplate.
function Style.Fill(frame, fill, border)
  frame:SetBackdrop({ bgFile = white, edgeFile = white, edgeSize = 1 })
  frame:SetBackdropColor(Style.Color(fill))
  frame:SetBackdropBorderColor(Style.Color(border or "border"))
end

-- Buttons: primary filled with brass, secondary raised with a border, quiet and danger text only. The border of the
-- secondary and the text of the quiet one turn brass under the mouse; a disabled button keeps its place, text dimmed.
local buttonText = { primary = "onPrimary", secondary = "text", quiet = "textSecondary", danger = "error" }
local function ButtonState(button)
  local kind = button.kind
  local over = button:IsEnabled() and button.over
  if kind == "primary" then
    button.fill:SetGradient("VERTICAL", CreateColor(Style.Color("primaryLow")),
      CreateColor(Style.Color(over and "primaryHover" or "primary")))
    button.fill:SetAlpha(button:IsEnabled() and 1 or 0.4)
  elseif kind == "secondary" then
    button:SetBackdropBorderColor(Style.Color(over and "primary" or "borderField"))
  end
  if not button:IsEnabled() then
    button.text:SetTextColor(Style.Color("textDisabled"))
  else
    button.text:SetTextColor(Style.Color(kind == "quiet" and over and "primary" or buttonText[kind]))
  end
end

--- A button of kind primary, secondary, quiet or danger, 22 pixels high, at least minWidth wide; button.text is its label.
function Style.NewButton(parent, text, kind, onClick, minWidth)
  local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
  button.kind = kind
  button.text = Style.NewText(button, "text", "s")
  button.text:SetPoint("CENTER")
  button.text:SetText(text)
  button.minWidth = minWidth or 0
  Style.FitButton(button)
  if kind == "primary" then
    button.fill = button:CreateTexture(nil, "BACKGROUND")
    button.fill:SetAllPoints()
    button.fill:SetTexture(white)
  elseif kind == "secondary" then
    Style.Fill(button, "raised", "borderField")
  end
  button:SetScript("OnEnter", function(self) self.over = true ButtonState(self) end)
  button:SetScript("OnLeave", function(self) self.over = nil ButtonState(self) end)
  button:SetScript("OnEnable", ButtonState)
  button:SetScript("OnDisable", ButtonState)
  button:SetScript("OnClick", onClick)
  ButtonState(button)
  return button
end

--- Width of a button made by NewButton from its text. An addon font may not be loaded when the button is made: the
--- text is measured again once shown.
function Style.FitButton(button)
  button:SetSize(math.max(button.minWidth, button.text:GetStringWidth() + 24), 22)
end

--- Text of a button made by NewButton.
function Style.SetButtonText(button, text)
  button.text:SetText(text)
  Style.FitButton(button)
end

--- A check box: a 14 pixel well, a brass square of 8 when checked, its label on the right and clickable.
function Style.NewCheck(parent, text, onClick)
  local check = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
  check:SetSize(14, 14)
  Style.Fill(check, "well", "borderField")
  local mark = check:CreateTexture(nil, "ARTWORK")
  mark:SetSize(8, 8)
  mark:SetPoint("CENTER")
  mark:SetColorTexture(Style.Color("primary"))
  check:SetCheckedTexture(mark)
  check.label = Style.NewText(check, "text", "s", "text")
  check.label:SetPoint("LEFT", check, "RIGHT", 6, 0)
  check.label:SetText(text)
  Style.FitCheck(check)
  check:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(Style.Color("primary")) end)
  check:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(Style.Color("borderField")) end)
  check:SetScript("OnClick", onClick)
  check:SetChecked(true)
  return check
end

--- Clickable width of a check box made by NewCheck, its label included; measured again once shown, like FitButton.
function Style.FitCheck(check)
  check:SetHitRectInsets(0, -(check.label:GetStringWidth() + 6), 0, 0)
end

local function PaintScrollThumb(bar)
  if bar.skinned then
    bar:GetThumbTexture():SetColorTexture(Style.Color(bar:IsMouseOver() and "borderField" or "borderHover"))
  end
end

--- Look of a Slider made with UIPanelScrollBarTemplate and anchored 4 pixels right of its scroll frame: no arrows, no
--- track, a flat thumb 6 pixels wide that brightens under the mouse. The Slider keeps its 16 pixel width to be grabbed.
function Style.SkinScrollBar(bar)
  bar.skinned = true
  bar.ScrollUpButton:Hide()
  bar.ScrollDownButton:Hide()
  local thumb = bar:GetThumbTexture()
  thumb:SetTexCoord(0, 1, 0, 1)
  thumb:SetSize(6, 32)
  for _, region in ipairs({ bar:GetRegions() }) do
    if region ~= thumb then
      region:SetAlpha(0)
    end
  end
  local scrollFrame = bar:GetParent()
  bar:ClearAllPoints()
  bar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 4, 0)
  bar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 0)
  if not bar.skinHooked then
    bar.skinHooked = true
    bar:HookScript("OnEnter", PaintScrollThumb)
    bar:HookScript("OnLeave", PaintScrollThumb)
  end
  PaintScrollThumb(bar)
end

--- The look of the game back on a Slider skinned by SkinScrollBar, for a widget of AceGUI shared with other addons.
function Style.UnskinScrollBar(bar)
  bar.skinned = nil
  bar.ScrollUpButton:Show()
  bar.ScrollDownButton:Show()
  local thumb = bar:GetThumbTexture()
  thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  thumb:SetTexCoord(0.20, 0.80, 0.125, 0.875)
  thumb:SetSize(18, 24)
  for _, region in ipairs({ bar:GetRegions() }) do
    region:SetAlpha(1)
  end
  local scrollFrame = bar:GetParent()
  bar:ClearAllPoints()
  bar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 4, -16)
  bar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 16)
end

local textures = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\"

--- Color of an icon made by NewIcon or of an eye made by NewEye: dimmed while disabled, brighter under the mouse.
function Style.PaintIcon(button)
  local color = not button:IsEnabled() and "textDisabled" or button.over and "text" or "textSecondary"
  if button.eye then
    -- visibility of the View buttons: 2 shown, 1 shown while picked, 0 hidden and crossed out.
    if button:IsEnabled() and button.visibility ~= 2 then
      color = "textQuiet"
    end
    for _, texture in ipairs(button.eye) do
      texture:SetVertexColor(Style.Color(color))
    end
    button.eye[3]:SetShown(button.visibility == 0)
  else
    button.texture:SetVertexColor(Style.Color(color))
  end
end

local function HookPaint(button)
  button:HookScript("OnEnter", function(self) self.over = true; Style.PaintIcon(self) end)
  button:HookScript("OnLeave", function(self) self.over = nil; Style.PaintIcon(self) end)
  button:HookScript("OnEnable", Style.PaintIcon)
  button:HookScript("OnDisable", Style.PaintIcon)
end

--- A flat icon of Media\Textures, size pixels square, centered on button as button.texture; set after its scripts.
function Style.NewIcon(button, file, size)
  local texture = button:CreateTexture(nil, "ARTWORK")
  texture:SetTexture(textures .. file)
  texture:SetSize(size, size)
  texture:SetPoint("CENTER")
  button.texture = texture
  HookPaint(button)
  Style.PaintIcon(button)
  return texture
end

--- An eye drawn on button: an outline and a pupil, a bar across while hidden; set after its scripts.
function Style.NewEye(button)
  local outline = button:CreateTexture(nil, "ARTWORK")
  outline:SetTexture(textures .. "circle_border5")
  outline:SetSize(14, 9)
  outline:SetPoint("CENTER")
  local pupil = button:CreateTexture(nil, "ARTWORK")
  pupil:SetTexture(textures .. "Circle_White")
  pupil:SetSize(4, 4)
  pupil:SetPoint("CENTER")
  local bar = button:CreateTexture(nil, "OVERLAY")
  bar:SetColorTexture(1, 1, 1)
  bar:SetSize(1, 16)
  bar:SetPoint("CENTER")
  bar:SetRotation(math.rad(45))
  button.eye = { outline, pupil, bar }
  HookPaint(button)
  Style.PaintIcon(button)
end

--- An EditBox drawn as a field: a well, a border turning brass while typed in, numbers in the number font.
function Style.SkinEditBox(box, role)
  Style.Fill(box, "well", "borderField")
  Style.SetFont(box, role or "number", "s")
  box:SetTextColor(Style.Color("text"))
  box:SetTextInsets(6, 6, 0, 0)
  box:HookScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(Style.Color("primary")) end)
  box:HookScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(Style.Color("borderField")) end)
end

--- Adds to group an alpha change of region from fromAlpha to toAlpha, started after delay.
function Style.AddFade(group, fromAlpha, toAlpha, duration, delay, smoothing)
  local fade = group:CreateAnimation("Alpha")
  fade:SetFromAlpha(fromAlpha)
  fade:SetToAlpha(toAlpha)
  fade:SetDuration(duration)
  fade:SetStartDelay(delay or 0)
  fade:SetSmoothing(smoothing or "NONE")
  return fade
end

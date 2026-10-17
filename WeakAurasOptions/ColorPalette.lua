-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local L = WeakAuras.L

local CreateFrame, GameTooltip, C_Timer = CreateFrame, GameTooltip, C_Timer
local floor, format, tonumber = math.floor, string.format, tonumber
local tinsert, tremove, sort = table.insert, table.remove, table.sort

local WHITE = "Interface\\Buttons\\WHITE8X8"
local CONTROL = "WeakAurasColorPicker"
local SWATCH_SIZE, SWATCH_STEP, COLUMNS, LEFT = 22, 26, 8, 12
local FAVOURITE_LIMIT, RECENT_LIMIT = 16, 8
local INVALID_COLOR = {1, 0.3, 0.3}

local picker = ColorPickerFrame
local content = picker.Content
local colorSelect = content and content.ColorPicker or picker


local function channelToByte(channel)
  local scaled = channel * 255
  local byte = floor(scaled)
  if scaled - byte >= 0.5 then byte = byte + 1 end
  return byte
end

local function toHex(...)
  local digits = {}
  for i = 1, 3 do
    digits[i] = format("%02X", channelToByte((select(i, ...))))
  end
  return table.concat(digits)
end

local function parseHex(text)
  local digits = text:match("^%s*#?(%x%x%x%x%x%x)%s*$")
  if not digits then return end
  local channels = {}
  for pair in digits:gmatch("..") do
    channels[#channels + 1] = tonumber("0x" .. pair) / 255
  end
  return unpack(channels)
end

local function parsePercent(text)
  local number = text:match("^%s*([%d%.]+)%s*%%?%s*$")
  if not number or not number:match("^%d*%.?%d+$") then return end
  local value = tonumber(number)
  if value and value >= 0 and value <= 100 then return value end
end

local function formatPercent(alpha)
  local text = format("%.4f", alpha * 100):gsub("0+$", "")
  return (text:gsub("%.$", ""))
end


local function palette()
  local saved = WeakAurasOptionsSaved.colorPalette
  if not saved then
    saved = { favorites = {}, recent = {} }
    WeakAurasOptionsSaved.colorPalette = saved
  end
  return saved
end

local function pushFront(list, limit, r, g, b)
  local hex = toHex(r, g, b)
  for i = #list, 1, -1 do
    if toHex(list[i][1], list[i][2], list[i][3]) == hex then tremove(list, i) end
  end
  tinsert(list, 1, { r, g, b })
  for i = #list, limit + 1, -1 do list[i] = nil end
end


local function pickerAlpha()
  return picker.GetColorAlpha and picker:GetColorAlpha() or 1
end

local function setPickerColor(r, g, b)
  colorSelect:SetColorRGB(r, g, b)
end

local function setPickerAlpha(alpha)
  if colorSelect.SetColorAlpha then colorSelect:SetColorAlpha(alpha) end
end


local activeRequest
local panel, hexBox, alphaBox, favouriteSwatches, recentSwatches

local function alphaEditable()
  return activeRequest ~= nil and activeRequest.hasOpacity and not activeRequest.cancelled
end

local function refreshAlpha(force)
  if not alphaBox or (not force and alphaBox:HasFocus()) then return end
  alphaBox:SetText(formatPercent(pickerAlpha()))
  alphaBox:SetTextColor(1, 1, 1)
end

local function fillSwatches(swatches, list)
  for i, swatch in ipairs(swatches) do
    local color = list[i]
    swatch.color = color
    if color then
      swatch.texture:SetColorTexture(color[1], color[2], color[3])
    end
    swatch:SetShown(color ~= nil)
  end
end

local function redraw()
  local saved = palette()
  fillSwatches(favouriteSwatches, saved.favorites)
  fillSwatches(recentSwatches, saved.recent)
  hexBox:SetText(toHex(picker:GetColorRGB()))
  refreshAlpha(false)
end


local function swatchOnClick(self, button)
  if button == "RightButton" and self.onRightClick then
    self.onRightClick(self)
  else
    setPickerColor(self.color[1], self.color[2], self.color[3])
  end
  redraw()
end

local function swatchOnEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  local text = self.label or ("#" .. toHex(self.color[1], self.color[2], self.color[3]))
  if self.hint then text = text .. "\n" .. self.hint end
  GameTooltip:SetText(text)
  GameTooltip:Show()
end

local function swatchOnLeave()
  GameTooltip:Hide()
end

local function createSwatch(index, top)
  local swatch = CreateFrame("Button", nil, panel)
  swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
  swatch:SetPoint("TOPLEFT", LEFT + ((index - 1) % COLUMNS) * SWATCH_STEP, top - floor((index - 1) / COLUMNS) * SWATCH_STEP)
  swatch.texture = swatch:CreateTexture(nil, "ARTWORK")
  swatch.texture:SetAllPoints()
  swatch.index = index
  swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  swatch:SetScript("OnClick", swatchOnClick)
  swatch:SetScript("OnEnter", swatchOnEnter)
  swatch:SetScript("OnLeave", swatchOnLeave)
  return swatch
end

local function createSwatchRow(count, top, hint, onRightClick)
  local swatches = {}
  for i = 1, count do
    local swatch = createSwatch(i, top)
    swatch.hint, swatch.onRightClick = hint, onRightClick
    swatches[i] = swatch
  end
  return swatches
end

local function createHeader(text, top)
  local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  header:SetPoint("TOPLEFT", LEFT, top)
  header:SetText(text)
end

local function createInputBox(parent, maxLetters)
  local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  box:SetAutoFocus(false)
  box:SetMaxLetters(maxLetters)
  return box
end

local function buildClassSwatches()
  local tokens = {}
  for token in pairs(RAID_CLASS_COLORS) do tokens[#tokens + 1] = token end
  sort(tokens)
  for i, token in ipairs(tokens) do
    local classColor = RAID_CLASS_COLORS[token]
    local swatch = createSwatch(i, -32)
    swatch.color = { classColor.r, classColor.g, classColor.b }
    swatch.label = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token] or token
    swatch.texture:SetColorTexture(classColor.r, classColor.g, classColor.b)
  end
end

local function buildHexBox()
  hexBox = createInputBox(panel, 7)
  hexBox:SetSize(84, 24)
  hexBox:SetPoint("BOTTOMLEFT", 18, 12)
  hexBox:SetScript("OnEnterPressed", function(self)
    local r, g, b = parseHex(self:GetText())
    if r then setPickerColor(r, g, b) end
    self:ClearFocus()
    redraw()
  end)
  hexBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    redraw()
  end)
end

local function buildAlphaBox()
  local nativeHexBox = content and content.HexBox
  alphaBox = createInputBox(content or picker, 12)
  alphaBox:SetHeight(20)
  if nativeHexBox then
    alphaBox:SetPoint("BOTTOMLEFT", nativeHexBox, "TOPLEFT", 0, 8)
    alphaBox:SetPoint("BOTTOMRIGHT", nativeHexBox, "TOPRIGHT", 0, 8)
  else
    alphaBox:SetWidth(84)
    alphaBox:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 18, -22)
  end
  local label = alphaBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("BOTTOMLEFT", alphaBox, "TOPLEFT", 0, 2)
  label:SetText(L["Alpha (%)"])
  alphaBox:Hide()

  alphaBox:SetScript("OnTextChanged", function(self, userInput)
    if not (userInput and alphaEditable()) then return end
    local value = parsePercent(self:GetText())
    if value then
      self:SetTextColor(1, 1, 1)
      setPickerAlpha(value / 100)
    else
      self:SetTextColor(INVALID_COLOR[1], INVALID_COLOR[2], INVALID_COLOR[3])
    end
  end)
  local function settle(self)
    self:ClearFocus()
    refreshAlpha(true)
  end
  alphaBox:SetScript("OnEnterPressed", settle)
  alphaBox:SetScript("OnEscapePressed", settle)
  alphaBox:SetScript("OnEditFocusLost", settle)
end

local function onPickerHide()
  local closed = activeRequest
  activeRequest = nil
  panel:Hide()
  alphaBox:Hide()
  if not closed then return end
  local r, g, b = picker:GetColorRGB()
  C_Timer.After(0, function()
    if not closed.cancelled then pushFront(palette().recent, RECENT_LIMIT, r, g, b) end
  end)
end

local function buildPanel()
  panel = CreateFrame("Frame", nil, picker, "BackdropTemplate")
  panel:SetSize(236, 270)
  panel:SetPoint("TOPLEFT", picker, "TOPRIGHT", 6, 0)
  panel:SetClampedToScreen(true)
  panel:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
  panel:SetBackdropColor(0.055, 0.055, 0.065, 0.98)
  panel:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

  createHeader(L["Class colours"], -12)
  buildClassSwatches()

  createHeader(L["Favourites"], -88)
  favouriteSwatches = createSwatchRow(FAVOURITE_LIMIT, -108, L["Right-click to remove"], function(swatch)
    tremove(palette().favorites, swatch.index)
  end)

  createHeader(L["Recent colours"], -162)
  recentSwatches = createSwatchRow(RECENT_LIMIT, -182, L["Right-click to favourite"], function(swatch)
    local color = swatch.color
    pushFront(palette().favorites, FAVOURITE_LIMIT, color[1], color[2], color[3])
  end)

  local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  saveButton:SetSize(116, 24)
  saveButton:SetPoint("BOTTOMRIGHT", -10, 12)
  saveButton:SetText(L["Save favourite"])
  saveButton:SetScript("OnClick", function()
    pushFront(palette().favorites, FAVOURITE_LIMIT, picker:GetColorRGB())
    redraw()
  end)

  buildHexBox()
  buildAlphaBox()
  picker:HookScript("OnHide", onPickerHide)
end


local function useColorPicker(option)
  if option.type == "color" and not option.control and not option.dialogControl then
    option.control = CONTROL
  end
  if option.args then
    for _, child in pairs(option.args) do useColorPicker(child) end
  end
end

function OptionsPrivate.UseColorPalette(options)
  useColorPicker(options)
end

function OptionsPrivate.PrepareColorPalette(info)
  local ticket = { hasOpacity = info.hasOpacity == true, cancelled = false }
  local originalOpacity, originalCancel = info.opacityFunc, info.cancelFunc
  info.opacityFunc = function(...)
    if originalOpacity then originalOpacity(...) end
    if activeRequest ~= ticket then return end
    refreshAlpha(false)
  end
  info.cancelFunc = function(...)
    ticket.cancelled = true
    if originalCancel then return originalCancel(...) end
  end
  activeRequest = ticket
end

function OptionsPrivate.ShowColorPalette()
  if not panel then buildPanel() end
  alphaBox:SetShown(activeRequest ~= nil and activeRequest.hasOpacity)
  alphaBox:ClearFocus()
  redraw()
  panel:Show()
end

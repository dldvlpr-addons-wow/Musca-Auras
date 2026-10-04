if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local FAVORITE_SLOTS, RECENT_SLOTS = 16, 8
local SWATCH_SIZE, SWATCH_STEP, SWATCH_COLUMNS = 22, 26, 8
local WHITE = "Interface\\Buttons\\WHITE8X8"

local ui
local activeSession

local function getStore()
  local saved = WeakAurasOptionsSaved
  if not saved.colorPalette then
    saved.colorPalette = { favorites = {}, recent = {} }
  end
  return saved.colorPalette
end

local function toHex(rgb)
  local parts = {}
  for index = 1, 3 do
    parts[index] = string.format("%02X", math.floor(rgb[index] * 255 + 0.5))
  end
  return table.concat(parts)
end

local function pushFront(list, rgb, capacity)
  local wanted = toHex(rgb)
  for position = #list, 1, -1 do
    if toHex(list[position]) == wanted then
      table.remove(list, position)
    end
  end
  table.insert(list, 1, { rgb[1], rgb[2], rgb[3] })
  while #list > capacity do
    table.remove(list)
  end
end

local function parseOpacity(text)
  local digits = text:match("^%s*(.-)%s*%%?%s*$")
  if not digits or not digits:match("^%d*%.?%d+$") then return nil end
  local percent = tonumber(digits)
  if percent and percent >= 0 and percent <= 100 then
    return percent / 100
  end
end

local function syncOpacityBox(force)
  if not ui or not activeSession or not activeSession.hasOpacity then return end
  local box = ui.alpha
  if not force and box:HasFocus() then return end
  local percent = (ColorPickerFrame:GetColorAlpha() or 1) * 100
  local formatted = string.format("%.4f", percent):gsub("0+$", ""):gsub("%.$", "")
  box:SetText(formatted)
  box:SetTextColor(1, 1, 1)
end

local function applyColor(rgb)
  ColorPickerFrame.Content.ColorPicker:SetColorRGB(rgb[1], rgb[2], rgb[3])
end

local function redraw()
  local store = getStore()
  for _, listName in ipairs({ "favorites", "recent" }) do
    local saved = store[listName]
    for slot, button in ipairs(ui[listName]) do
      local rgb = saved[slot]
      button.color = rgb
      if rgb then
        button.texture:SetColorTexture(unpack(rgb))
        button:Show()
      else
        button:Hide()
      end
    end
  end
  ui.hex:SetText(toHex({ ColorPickerFrame:GetColorRGB() }))
  syncOpacityBox()
end

local function addCaption(parent, text, offsetY)
  local caption = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  caption:SetPoint("TOPLEFT", 12, offsetY)
  caption:SetText(text)
  return caption
end

local tooltipHints = {
  favorites = "\nRight-click to remove",
  recent = "\nRight-click to favourite",
}

local function addSwatch(parent, slot, offsetY, listName)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(SWATCH_SIZE, SWATCH_SIZE)
  local column = (slot - 1) % SWATCH_COLUMNS
  local row = math.floor((slot - 1) / SWATCH_COLUMNS)
  button:SetPoint("TOPLEFT", 12 + column * SWATCH_STEP, offsetY - row * SWATCH_STEP)
  button.texture = button:CreateTexture(nil, "ARTWORK")
  button.texture:SetAllPoints()
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:SetScript("OnClick", function(_, mouseButton)
    local rightClick = mouseButton == "RightButton"
    if rightClick and listName == "favorites" then
      table.remove(getStore().favorites, slot)
    elseif rightClick and listName == "recent" then
      pushFront(getStore().favorites, button.color, FAVORITE_SLOTS)
    else
      applyColor(button.color)
    end
    redraw()
  end)
  button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(button, "ANCHOR_TOP")
    local heading = button.title or ("#" .. toHex(button.color))
    GameTooltip:SetText(heading .. (tooltipHints[listName] or ""))
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return button
end

local function buildClassRow(parent)
  local names = {}
  for token in pairs(RAID_CLASS_COLORS) do
    names[#names + 1] = token
  end
  table.sort(names)
  for slot, token in ipairs(names) do
    local source = RAID_CLASS_COLORS[token]
    local button = addSwatch(parent, slot, -32)
    button.color = { source.r, source.g, source.b }
    button.title = LOCALIZED_CLASS_NAMES_MALE[token] or token
    button.texture:SetColorTexture(unpack(button.color))
  end
end

local function buildHexEntry(parent)
  local entry = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  entry:SetSize(84, 24)
  entry:SetPoint("BOTTOMLEFT", 18, 12)
  entry:SetAutoFocus(false)
  entry:SetMaxLetters(7)
  entry:SetScript("OnEnterPressed", function(self)
    local code = self:GetText():gsub("#", "")
    if #code == 6 and code:match("^%x+$") then
      local rgb = {}
      for index = 1, 3 do
        rgb[index] = tonumber(code:sub(index * 2 - 1, index * 2), 16) / 255
      end
      applyColor(rgb)
    end
    self:ClearFocus()
    redraw()
  end)
  entry:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    redraw()
  end)
  return entry
end

local function buildOpacityEntry()
  local content = ColorPickerFrame.Content
  local entry = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
  entry:SetHeight(20)
  entry:SetPoint("BOTTOMLEFT", content.HexBox, "TOPLEFT", 0, 8)
  entry:SetPoint("BOTTOMRIGHT", content.HexBox, "TOPRIGHT", 0, 8)
  entry:SetAutoFocus(false)
  entry:SetMaxLetters(12)
  entry:SetScript("OnTextChanged", function(self, fromUser)
    if not fromUser or not activeSession then return end
    if activeSession.cancelled or not activeSession.hasOpacity then return end
    local value = parseOpacity(self:GetText())
    local channel = value and 1 or 0.3
    self:SetTextColor(1, channel, channel)
    if value then
      ColorPickerFrame.Content.ColorPicker:SetColorAlpha(value)
    end
  end)
  entry:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    syncOpacityBox(true)
  end)
  entry:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    syncOpacityBox(true)
  end)
  entry:SetScript("OnEditFocusLost", function() syncOpacityBox(true) end)
  local caption = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  caption:SetPoint("BOTTOMLEFT", entry, "TOPLEFT", 0, 2)
  caption:SetText("Alpha (%)")
  return entry, caption
end

local function onPickerHidden()
  local finished = activeSession
  activeSession = nil
  ui:Hide()
  ui.alpha:Hide()
  ui.alphaLabel:Hide()
  if not finished then return end
  local final = { ColorPickerFrame:GetColorRGB() }
  C_Timer.After(0, function()
    if not finished.cancelled then
      pushFront(getStore().recent, final, RECENT_SLOTS)
    end
  end)
end

local function buildPalette()
  local frame = CreateFrame("Frame", nil, ColorPickerFrame, "BackdropTemplate")
  ui = frame
  frame:SetSize(236, 270)
  frame:SetPoint("TOPLEFT", ColorPickerFrame, "TOPRIGHT", 6, 0)
  frame:SetClampedToScreen(true)
  frame:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
  frame:SetBackdropColor(0.055, 0.055, 0.065, 0.98)
  frame:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

  addCaption(frame, "Class colours", -12)
  buildClassRow(frame)
  addCaption(frame, "Favourites", -88)
  addCaption(frame, "Recent colours", -162)

  frame.favorites, frame.recent = {}, {}
  for slot = 1, FAVORITE_SLOTS do
    frame.favorites[slot] = addSwatch(frame, slot, -108, "favorites")
  end
  for slot = 1, RECENT_SLOTS do
    frame.recent[slot] = addSwatch(frame, slot, -182, "recent")
  end

  local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  saveButton:SetSize(116, 24)
  saveButton:SetPoint("BOTTOMRIGHT", -10, 12)
  saveButton:SetText("Save favourite")
  saveButton:SetScript("OnClick", function()
    pushFront(getStore().favorites, { ColorPickerFrame:GetColorRGB() }, FAVORITE_SLOTS)
    redraw()
  end)

  frame.hex = buildHexEntry(frame)
  frame.alpha, frame.alphaLabel = buildOpacityEntry()
  ColorPickerFrame:HookScript("OnHide", onPickerHidden)
end

function OptionsPrivate.UseColorPalette(options)
  local unset = not options.control and not options.dialogControl
  if options.type == "color" and unset then
    options.control = "WeakAurasColorPicker"
  end
  for _, child in pairs(options.args or {}) do
    OptionsPrivate.UseColorPalette(child)
  end
end

function OptionsPrivate.PrepareColorPalette(info)
  local mine = { cancelled = false, hasOpacity = info.hasOpacity == true }
  activeSession = mine
  local originalCancel, originalOpacity = info.cancelFunc, info.opacityFunc
  info.cancelFunc = function(...)
    mine.cancelled = true
    if originalCancel then originalCancel(...) end
  end
  info.opacityFunc = function(...)
    if originalOpacity then originalOpacity(...) end
    if activeSession == mine then syncOpacityBox() end
  end
end

function OptionsPrivate.ShowColorPalette()
  if not ui then buildPalette() end
  local withOpacity = activeSession and activeSession.hasOpacity or false
  ui.alpha:SetShown(withOpacity)
  ui.alphaLabel:SetShown(withOpacity)
  ui.alpha:ClearFocus()
  redraw()
  ui:Show()
end

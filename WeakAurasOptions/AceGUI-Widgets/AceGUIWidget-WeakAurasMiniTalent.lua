-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local Type, Version = "WeakAurasMiniTalent", 4
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local pairs, ipairs, type, sort, floor, ceil, select = pairs, ipairs, type, table.sort, math.floor, math.ceil, select
local CreateFrame, CreateObjectPool, GameTooltip, UIParent = CreateFrame, CreateObjectPool, GameTooltip, UIParent
local L = WeakAuras.L

local FRAME_WIDTH = 440
local BOX_MARGIN = 45
local ICON_SIZE = 32
local BACKGROUND_INDEX, OFFSET_INDEX = 999, 1000

local acquiredWidgets = {}
local reopenByKey = {}

local function OptionKey(widget)
  local path = widget:GetUserData("path")
  return path and path[#path]
end

local function PaintTalent(button)
  local value = button.value
  local icon = button.icon
  button.halo:SetShown(value ~= nil)
  button.crossA:SetShown(value == false)
  button.crossB:SetShown(value == false)
  if value == true then
    button.halo:SetVertexColor(1, 1, 0, 1)
    icon:SetVertexColor(1, 1, 1)
  elseif value == false then
    button.halo:SetVertexColor(1, 0, 0, 1)
    icon:SetVertexColor(1, 0, 0)
  else
    icon:SetVertexColor(0.3, 0.3, 0.3)
  end
end

local function PlaceTalent(button, point, x, y, scale, size, haloSize, clickable)
  button:SetScale(scale)
  button:SetSize(size, size)
  button:ClearAllPoints()
  button:SetPoint(point, button:GetParent(), "TOPLEFT", x, y)
  button.halo:SetPoint("TOPLEFT", -haloSize, haloSize)
  button.halo:SetPoint("BOTTOMRIGHT", haloSize, -haloSize)
  button:SetEnabled(clickable)
  button:SetMouseClickEnabled(clickable)
  PaintTalent(button)
  button:Show()
end

local function Talent_OnClick(button)
  local widget = button.widget
  if not widget.open then return end
  -- nil -> true -> false -> nil
  if button.value == nil then
    button.value = true
  elseif button.value then
    button.value = false
  else
    button.value = nil
  end
  PaintTalent(button)
  widget:Fire("OnValueChanged", button.index, button.value)
end

local function Talent_OnEnter(button)
  if not button.spellId then return end
  GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
  GameTooltip:SetSpellByID(button.spellId, false, false, true)
  GameTooltip:Show()
end

local function Talent_OnLeave()
  GameTooltip:Hide()
end

local CROSS_INSET = 3

local function CreateCrossLine(button, fromPoint, fromX, toPoint, toX)
  local line = button:CreateLine(nil, "OVERLAY")
  line:SetColorTexture(1, 0, 0, 1)
  line:SetThickness(2)
  line:SetBlendMode("ADD")
  line:SetStartPoint(fromPoint, button, fromX * CROSS_INSET, -CROSS_INSET)
  line:SetEndPoint(toPoint, button, toX * CROSS_INSET, CROSS_INSET)
  return line
end

local function CreateTalentButton(widget)
  local button = CreateFrame("Button", nil, widget.frame)
  button.widget = widget
  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetAllPoints()
  button:SetNormalTexture(button.icon)
  button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
  button.halo = button:CreateTexture(nil, "OVERLAY")
  button.halo:SetTexture("interface/buttons/checkbuttonglow")
  button.halo:SetBlendMode("ADD")
  button.halo:SetIgnoreParentScale(true)
  button.crossA = CreateCrossLine(button, "TOPLEFT", 1, "BOTTOMRIGHT", -1)
  button.crossB = CreateCrossLine(button, "TOPRIGHT", -1, "BOTTOMLEFT", 1)
  button:SetMotionScriptsWhileDisabled(true)
  button:SetScript("OnClick", Talent_OnClick)
  button:SetScript("OnEnter", Talent_OnEnter)
  button:SetScript("OnLeave", Talent_OnLeave)
  return button
end

local function ResetRegion(_, region)
  region:Hide()
  region:ClearAllPoints()
end

-- position = { x, y (tenths of a pixel), rank, rankCount, subTree }
-- Choice nodes sit side by side: the first is anchored by its right edge, the others by their left edge.
local function FillTalent(button, index, entry, offset)
  local position = type(entry[3]) == "table" and entry[3] or {}
  button.index = index
  button.talentId = entry[1]
  button.spellId = entry[2]
  button.targets = entry[4]
  button.value = nil
  button.x = position[1] and (position[1] - offset[1]) / 10
  button.y = position[2] and (position[2] - offset[2]) / 10
  button.anchor = "CENTER"
  if (position[4] or 1) > 1 then
    button.anchor = position[3] == 1 and "RIGHT" or "LEFT"
  end
  button.subTreeSide = position[5] and (position[5] == 1 and "left" or "right")
  local icon = button.spellId and select(8, OptionsPrivate.Private.ExecEnv.GetSpellInfo(button.spellId))
  button.icon:SetTexture(icon)
end

local function LayoutClosed(self)
  local shown = 0
  for _, button in ipairs(self.talents) do
    if button.value ~= nil and not self.disabled then
      PlaceTalent(button, "TOPLEFT", 7 + (shown % 9) * 49, -(7 + floor(shown / 9) * 49), 1, ICON_SIZE, 10, false)
      shown = shown + 1
    else
      button:Hide()
    end
  end
  self:SetHeight(shown > 0 and 50 * ceil(shown / 11) or 1)
end

local function LayoutOpen(self)
  local minX, minY, maxX, maxY
  for _, button in ipairs(self.talents) do
    if button.x and button.y then
      minX, maxX = math.min(minX or button.x, button.x), math.max(maxX or button.x, button.x)
      minY, maxY = math.min(minY or button.y, button.y), math.max(maxY or button.y, button.y)
    end
  end
  if not minX then
    for _, button in ipairs(self.talents) do button:Hide() end
    self:SetHeight(100)
    return
  end

  local scale = FRAME_WIDTH / (maxX - minX + 2 * BOX_MARGIN)
  for _, button in ipairs(self.talents) do
    if button.x and button.y then
      PlaceTalent(button, button.anchor, button.x - minX + BOX_MARGIN, -(button.y - minY + BOX_MARGIN),
        scale, ICON_SIZE / scale * 0.5, 5, true)
    else
      button:Hide()
    end
  end
  self:SetHeight((maxY - minY + 2 * BOX_MARGIN) * scale)

  for _, source in ipairs(self.talents) do
    if source.x and source.anchor ~= "LEFT" and type(source.targets) == "table" then
      for _, talentId in ipairs(source.targets) do
        local target = self.talentsById[talentId]
        if target and target.x then
          local line = self.linePool:Acquire()
          line:SetColorTexture(1, 1, 1, 0.2)
          line:SetThickness(1)
          line:SetStartPoint(source.anchor, source)
          line:SetEndPoint("CENTER", target)
          line:Show()
        end
      end
    end
  end
end

local methods = {
  OnAcquire = function(self)
    acquiredWidgets[self] = true
    self.open = false
    self:SetWidth(FRAME_WIDTH)
    self:SetDisabled(false)
  end,

  OnRelease = function(self)
    acquiredWidgets[self] = nil
    self:SetDisabled(true)
    self:SetList(nil)
  end,

  Layout = function(self)
    self.linePool:ReleaseAll()
    if self.open and not self.disabled then
      LayoutOpen(self)
    else
      LayoutClosed(self)
    end
  end,

  SetOpen = function(self, open)
    self.open = open
    self:Layout()
    if self.parent then
      self.parent:DoLayout()
    end
  end,

  SetDisabled = function(self, disabled)
    self.disabled = disabled
    self.open = false
    self.toggle.frame:SetShown(not disabled)
    self.frame:SetShown(not disabled)
    self:Layout()
  end,

  SetList = function(self, list)
    self.talentPool:ReleaseAll()
    self.talents, self.talentsById, self.talentsByIndex = {}, {}, {}
    list = list or {}
    local offset = type(list[OFFSET_INDEX]) == "table" and list[OFFSET_INDEX] or {}
    offset = { offset[1] or 0, offset[2] or 0 }
    for index, entry in pairs(list) do
      if type(index) == "number" and index < BACKGROUND_INDEX and type(entry) == "table" then
        local button = self.talentPool:Acquire()
        FillTalent(button, index, entry, offset)
        self.talents[#self.talents + 1] = button
        self.talentsByIndex[index] = button
        if button.talentId then
          self.talentsById[button.talentId] = button
        end
      end
    end
    sort(self.talents, function(a, b) return a.index < b.index end)
    self:Layout()
  end,

  SetItemValue = function(self, index, value)
    local button = self.talentsByIndex[index]
    if not button then return end
    button.value = value
    self:Layout()
  end,

  SetValue = function() end,
  SetLabel = function() end,
  SetMultiselect = function() end,
}

local function Constructor()
  local frame = CreateFrame("Button", "AceGUI30" .. Type .. AceGUI:GetNextWidgetNum(Type), UIParent)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:Hide()

  local widget = {
    frame = frame,
    type = Type,
    talents = {},
    talentsById = {},
    talentsByIndex = {},
  }
  for name, method in pairs(methods) do
    widget[name] = method
  end

  widget.talentPool = CreateObjectPool(function() return CreateTalentButton(widget) end, ResetRegion)
  widget.linePool = CreateObjectPool(function() return frame:CreateLine(nil, "ARTWORK") end, ResetRegion)

  local toggle = AceGUI:Create("WeakAurasToolbarButton")
  toggle.frame:SetParent(frame)
  toggle.frame:ClearAllPoints()
  toggle.frame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 2)
  toggle:SetText(L["Select Talent"])
  toggle:SetTexture("Interface\\Buttons\\UI-MicroButton-Talents-Up")
  toggle.icon:ClearAllPoints()
  toggle.icon:SetSize(28, 58)
  toggle.icon:SetScale(0.6)
  toggle.icon:SetPoint("LEFT", toggle.frame, "LEFT", 0, 10)
  toggle.text:SetVertexColor(1, 1, 1)
  toggle:SetCallback("OnClick", function() widget:SetOpen(not widget.open) end)
  widget.toggle = toggle

  frame:SetScript("OnClick", function() widget:SetOpen(not widget.open) end)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

OptionsPrivate.registerRegions = OptionsPrivate.registerRegions or {}
table.insert(OptionsPrivate.registerRegions, function()
  OptionsPrivate.Private.callbacks:RegisterCallback("BeforeReload", function()
    for widget in pairs(acquiredWidgets) do
      local key = OptionKey(widget)
      if key then
        reopenByKey[key] = widget.open or nil
      end
    end
  end)

  OptionsPrivate.Private.callbacks:RegisterCallback("AfterReload", function()
    for widget in pairs(acquiredWidgets) do
      local key = OptionKey(widget)
      if key and reopenByKey[key] then
        reopenByKey[key] = nil
        widget:SetOpen(true)
      end
    end
  end)
end)

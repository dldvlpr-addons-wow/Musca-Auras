if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local openStateByPathKey = {}

local WIDGET_TYPE, WIDGET_VERSION = "WeakAurasMiniTalent", 4
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(WIDGET_TYPE) or 0) >= WIDGET_VERSION then
  return
end
local L = WeakAuras.L

local ICON_SIZE = 32
local CELL_SIZE = 45
local GRID_STEP = CELL_SIZE + 4
local FRAME_WIDTH = 440
local BACKGROUND_KEY = 999
local OFFSET_KEY = 1000

local anchorForOffset = { left = "RIGHT", right = "LEFT" }

local function anchorOf(offset)
  return anchorForOffset[offset] or "CENTER"
end

local function placeCover(talent, inset)
  local cover = talent.cover
  cover:ClearAllPoints()
  cover:SetPoint("TOPLEFT", talent, "TOPLEFT", -inset, inset)
  cover:SetPoint("BOTTOMRIGHT", talent, "BOTTOMRIGHT", inset, -inset)
end

local function tintIcon(talent, r, g, b)
  local icon = talent:GetNormalTexture()
  if icon then
    icon:SetVertexColor(r, g, b, 1)
  end
end

local function hideCross(talent)
  if talent.line1 then
    talent.line1:Hide()
    talent.line2:Hide()
  end
end

local function newCrossLine(talent, fromPoint, fromX, fromY, toPoint, toX, toY)
  local line = talent:CreateLine()
  line:SetColorTexture(1, 0, 0, 1)
  line:SetStartPoint(fromPoint, fromX, fromY)
  line:SetEndPoint(toPoint, toX, toY)
  line:SetBlendMode("ADD")
  line:SetThickness(2)
  return line
end

local function showSelected(talent)
  talent.cover:Show()
  talent.cover:SetVertexColor(1, 1, 0, 1)
  tintIcon(talent, 1, 1, 1)
  hideCross(talent)
end

local function showExcluded(talent)
  talent.cover:Show()
  talent.cover:SetVertexColor(1, 0, 0, 1)
  tintIcon(talent, 1, 0, 0)
  if not talent.line1 then
    local first = newCrossLine(talent, "TOPLEFT", 3, -3, "BOTTOMRIGHT", -3, 3)
    local second = newCrossLine(talent, "TOPRIGHT", -3, -3, "BOTTOMLEFT", 3, 3)
    talent.line1 = first
    talent.line2 = second
  end
  talent.line1:Show()
  talent.line2:Show()
end

local function showUnset(talent)
  talent.cover:Hide()
  tintIcon(talent, 0.3, 0.3, 0.3)
  hideCross(talent)
end

local function refreshLook(talent)
  local state = talent.state
  if state == nil then
    talent:Clear()
  elseif state == true then
    talent:Yellow()
  elseif state == false then
    talent:Red()
  end
end

local function storeState(talent, state)
  talent.state = state
  talent:UpdateTexture()
end

local function lineAnchor(talent)
  if talent.offset == nil then
    return "CENTER"
  end
  return anchorForOffset[talent.offset]
end

local nextState = { [true] = false, [false] = nil }

local function cycleState(talent)
  local state = talent.state
  if state == true or state == false then
    talent:SetValue(nextState[state])
  else
    talent:SetValue(true)
  end
  talent.obj.obj:Fire("OnValueChanged", talent.index, talent.state)
end

local function showSpellTooltip(talent)
  if talent.spellId then
    GameTooltip:SetOwner(talent, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(talent.spellId, false, false, true)
  end
end

local function hideSpellTooltip()
  GameTooltip:Hide()
end

local function buildTalentButton()
  local talent = CreateFrame("Button")
  talent:SetSize(ICON_SIZE, ICON_SIZE)

  local cover = talent:CreateTexture(nil, "OVERLAY")
  cover:SetTexture("interface/buttons/checkbuttonglow")
  cover:SetIgnoreParentScale(true)
  cover:SetPoint("TOPLEFT", talent, "TOPLEFT", -10, 10)
  cover:SetPoint("BOTTOMRIGHT", talent, "BOTTOMRIGHT", 10, -10)
  cover:SetBlendMode("ADD")
  cover:Hide()
  talent.cover = cover
  talent:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")

  talent.Yellow = showSelected
  talent.Red = showExcluded
  talent.Clear = showUnset
  talent.UpdateTexture = refreshLook
  talent.SetValue = storeState
  talent.LineGetPoint = lineAnchor

  talent:SetScript("OnClick", cycleState)
  talent:Clear()
  talent:SetScript("OnEnter", showSpellTooltip)
  talent:SetScript("OnLeave", hideSpellTooltip)
  talent:SetMotionScriptsWhileDisabled(true)
  return talent
end

local function resetLine(_, line)
  line:Hide()
  line:ClearAllPoints()
end

local function drawLinks(widget, talent)
  local byTalentId = widget.talentIdToButton
  for _, targetId in pairs(talent.targets) do
    local target = byTalentId[targetId]
    if target ~= nil and talent.offset ~= "right" then
      local line = widget.linePool:Acquire()
      line:SetStartPoint(talent:LineGetPoint(), talent)
      line:SetEndPoint(target:LineGetPoint(), target)
      line:SetColorTexture(1, 1, 1, 0.2)
      line:SetThickness(1)
      line:Show()
    end
  end
end

local function layoutOpen(widget, talent)
  local x, y, anchor = talent.posX, -talent.posY, anchorOf(talent.offset)
  talent:ClearAllPoints()
  talent:SetPoint(anchor, talent.obj, "TOPLEFT", x, y)
  talent:SetEnabled(true)
  talent:SetMouseClickEnabled(true)
  local side = ICON_SIZE / widget.scale * 0.5
  talent:SetSize(side, side)
  talent:SetScale(widget.scale)
  placeCover(talent, 5)
  talent:Show()
  drawLinks(widget, talent)
end

local function layoutCollapsed(talent, slot)
  local column = (slot - 1) % 9
  local row = ceil(slot / 9) - 1
  talent:ClearAllPoints()
  talent:SetPoint("TOPLEFT", talent.obj, "TOPLEFT", 7 + column * GRID_STEP, -7 - row * GRID_STEP)
  talent:SetEnabled(false)
  talent:SetMouseClickEnabled(false)
  talent:SetSize(ICON_SIZE, ICON_SIZE)
  talent:SetScale(1)
  placeCover(talent, 10)
  talent:Show()
end

local function refreshTalentFrame(widget)
  local shown = 0
  widget.linePool:ReleaseAll()
  if widget.list then
    for _, talent in ipairs(widget.buttons) do
      if widget.open then
        layoutOpen(widget, talent)
      elseif talent.state ~= nil then
        shown = shown + 1
        layoutCollapsed(talent, shown)
      else
        talent:Hide()
      end
    end
  end
  if widget.open then
    widget.frame:SetHeight(widget.saveSize.fullHeight)
    widget.background:Show()
    return
  end
  local rows = ceil(shown / 11)
  widget.frame:SetHeight(rows > 0 and widget.saveSize.collapsedRowHeight * rows or 1)
  widget.background:Hide()
end

local function addTalent(widget, index, entry, shift)
  local talent = widget.buttonPool:Acquire()
  talent.index = index
  talent:SetParent(widget.frame)
  talent.obj = widget.frame
  local talentId, spellId, position, targets = entry[1], entry[2], entry[3], entry[4]
  talent.talentId = talentId
  widget.talentIdToButton[talentId] = talent
  talent.spellId = spellId
  local icon = select(8, OptionsPrivate.Private.ExecEnv.GetSpellInfo(spellId))
  if icon then
    talent:SetNormalTexture(icon)
  end
  local x, y, rank, rankCount, subTree = unpack(position)
  talent.posX = x / 10 - (shift and shift.offsetX or 0)
  talent.posY = y / 10 - (shift and shift.offsetY or 0)
  if rankCount > 1 then
    talent.offset = rank == 1 and "left" or "right"
  else
    talent.offset = nil
  end
  if subTree then
    talent.side = subTree == 1 and "left" or "right"
  end
  talent.targets = targets
  talent:UpdateTexture()
  talent:ClearAllPoints()
  tinsert(widget.buttons, talent)
end

local function lowest(current, value)
  return current and math.min(current, value) or value
end

local function highest(current, value)
  return current and math.max(current, value) or value
end

local function fitToFrame(widget)
  local left, top, right, bottom
  for _, talent in ipairs(widget.buttons) do
    left = lowest(left, talent.posX)
    top = lowest(top, talent.posY)
    right = highest(right, talent.posX)
    bottom = highest(bottom, talent.posY)
  end
  local width = left and right - left + 2 * CELL_SIZE or FRAME_WIDTH
  local height = top and bottom - top + 2 * CELL_SIZE or 100
  for _, talent in ipairs(widget.buttons) do
    talent.posX = talent.posX - left + CELL_SIZE
    talent.posY = talent.posY - top + CELL_SIZE
  end
  widget.scale = widget.saveSize.fullWidth / width
  widget.saveSize.fullHeight = height * widget.scale
end

local methods = {}

function methods:OnAcquire()
  self:SetDisabled(false)
  self.acquired = true
end

function methods:OnRelease()
  self:SetDisabled(true)
  self:SetMultiselect(false)
  self.buttonPool:ReleaseAll()
  self.linePool:ReleaseAll()
  self.value = nil
  self.list = nil
  self.acquired = false
end

function methods:SetList(list)
  self.list = list or {}
  self.buttonPool:ReleaseAll()
  self.linePool:ReleaseAll()
  self.buttons = {}
  self.talentIdToButton = {}
  local shift = self.list[OFFSET_KEY]
  for index, entry in pairs(self.list) do
    if index < BACKGROUND_KEY then
      addTalent(self, index, entry, shift)
    end
  end
  fitToFrame(self)
  self.background:Hide()
  refreshTalentFrame(self)
end

function methods:SetDisabled(disabled)
  if not disabled then
    self.open = nil
    refreshTalentFrame(self)
    self.toggle.frame:Show()
    self.frame:Show()
    return
  end
  for _, talent in pairs(self.buttons) do
    talent:Hide()
  end
  self.background:Hide()
  self.open = nil
  self.toggle.frame:Hide()
  self.frame:Hide()
end

function methods:SetItemValue(item, value)
  local talent = self.buttons[item]
  if talent then
    talent:SetValue(value)
    refreshTalentFrame(self)
  end
end

function methods:SetValue() end
function methods:SetLabel() end
function methods:SetMultiselect() end

function methods:ToggleView(force)
  if force == nil then
    force = not self.open or nil
  end
  self.open = force
  refreshTalentFrame(self)
  self.parent:DoLayout()
end

local function onFrameClick(frame)
  frame.obj:ToggleView()
end

local function onToggleClick(toggle)
  toggle.frame:GetParent().obj:ToggleView()
end

local function buildToggle(owner)
  local toggle = AceGUI:Create("WeakAurasToolbarButton")
  toggle:SetText(L["Select Talent"])
  toggle:SetTexture("interface/buttons/ui-microbutton-talents-up")
  local icon = toggle.icon
  icon:ClearAllPoints()
  icon:SetPoint("LEFT", toggle.frame, "LEFT", 0, 10)
  icon:SetSize(28, 58)
  icon:SetScale(0.6)
  local frame = toggle.frame
  frame:SetPoint("BOTTOMRIGHT", owner, "TOPRIGHT", 0, 2)
  frame:SetParent(owner)
  frame.obj.text:SetVertexColor(1, 1, 1, 1)
  frame:Show()
  toggle:SetCallback("OnClick", onToggleClick)
  return toggle
end

local function optionPathOf(widget)
  if widget.acquired then
    local user = widget:GetUserDataTable()
    return user and user.path
  end
end

local function Constructor()
  local frame = CreateFrame("Button", WIDGET_TYPE .. AceGUI:GetNextWidgetNum(WIDGET_TYPE), UIParent)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetWidth(FRAME_WIDTH)
  frame:SetScript("OnClick", onFrameClick)
  local background = frame:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints(frame)

  local widget = {
    frame = frame,
    type = WIDGET_TYPE,
    buttons = {},
    toggle = buildToggle(frame),
    background = background,
    saveSize = {
      fullWidth = FRAME_WIDTH,
      fullHeight = 0,
      collapsedRowHeight = CELL_SIZE + 5,
    },
  }
  widget.linePool = CreateObjectPool(function() return frame:CreateLine() end, resetLine)
  widget.buttonPool = CreateObjectPool(buildTalentButton)
  for name, method in pairs(methods) do
    widget[name] = method
  end
  frame.obj = widget

  OptionsPrivate.Private.callbacks:RegisterCallback("BeforeReload", function()
    local path = optionPathOf(widget)
    if path then
      openStateByPathKey[path[#path]] = widget.open
    end
  end)
  OptionsPrivate.Private.callbacks:RegisterCallback("AfterReload", function()
    local path = optionPathOf(widget)
    if path and openStateByPathKey[path[#path]] then
      widget:ToggleView(true)
      openStateByPathKey[path[#path]] = nil
    end
  end)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)

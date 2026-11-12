-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

-- Panel of the placement mode (/wa unlock): the placement of the selected aura, typed in. Offsets, size, the aura it
-- follows, and for a dynamic group its grow, align and space. Each change goes through WeakAuras.Add, watched by the
-- time machine and kept for Revert, as a drag of its box.

local panelWidth = 220
local rowHeight = 22
-- Grow types the panel cycles through; CUSTOM needs code, it stays in /wa.
local growOrder = { "LEFT", "RIGHT", "UP", "DOWN", "HORIZONTAL", "VERTICAL", "CIRCLE", "COUNTERCIRCLE", "GRID" }
-- As the options of a dynamic group: align for the lines, space for the lines and the circles spaced by it.
local alignedGrow = { LEFT = true, RIGHT = true, UP = true, DOWN = true, HORIZONTAL = true, VERTICAL = true }
local circleGrow = { CIRCLE = true, COUNTERCIRCLE = true }
-- Fields that cannot be zero or below.
local positiveFields = { width = true, height = true }
local alignOrder = { "LEFT", "CENTER", "RIGHT" }

local panel
local currentId
local Style

local function Next(list, value)
  for index, item in ipairs(list) do
    if item == value then
      return list[index % #list + 1]
    end
  end
  return list[1]
end

local Refresh

local function Apply(field, value)
  local data = currentId and WeakAuras.GetData(currentId)
  -- A number typed in: finite, above zero for a size; the same value changes nothing.
  local valid = value ~= nil and (type(value) ~= "number"
    or (value == value and value > -math.huge and value < math.huge and (not positiveFields[field] or value > 0)))
  if not (data and valid) or data[field] == value then
    Refresh()
    return
  end
  local Private = OptionsPrivate.Private
  Private.PlacementBoxes.Remember(data)
  Private.TimeMachine:Watch(data)
  data[field] = value
  if field == "grow" or field == "align" then
    data.selfPoint = OptionsPrivate.DynamicGroupSelfPoint(data) or data.selfPoint
  end
  -- The Add rebuilds the boxes, and the panel through the selection.
  WeakAuras.Add(data)
  Private.AddParents(data)
  WeakAuras.UpdateThumbnail(data)
  Refresh()
end

local function NewLabel(parent, text)
  local label = Style.NewText(parent, "text", "s", "textSecondary")
  label:SetText(text)
  label:SetJustifyH("LEFT")
  return label
end

-- A row with a label and a number typed in: Enter applies, Escape puts the saved value back.
local function NewNumberRow(text, field)
  local row = CreateFrame("Frame", nil, panel)
  row:SetSize(panelWidth - 24, rowHeight)
  row.label = NewLabel(row, text)
  row.label:SetPoint("LEFT")
  local box = CreateFrame("EditBox", nil, row, "BackdropTemplate")
  Style.SkinEditBox(box)
  box:SetSize(80, rowHeight)
  box:SetPoint("RIGHT")
  box:SetAutoFocus(false)
  box:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    Apply(field, tonumber(self:GetText()))
  end)
  box:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    Refresh()
  end)
  row.box = box
  row.field = field
  return row
end

-- A row with a label and a button that goes to the next value.
local function NewCycleRow(text, onClick)
  local row = CreateFrame("Frame", nil, panel)
  row:SetSize(panelWidth - 24, rowHeight)
  row.label = NewLabel(row, text)
  row.label:SetPoint("LEFT")
  row.button = Style.NewButton(row, "", "secondary", onClick, 100)
  row.button:SetPoint("RIGHT")
  return row
end

local function CreatePanel()
  Style = OptionsPrivate.Private.Style
  panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  panel:SetFrameStrata("FULLSCREEN")
  panel:SetWidth(panelWidth)
  panel:SetPoint("RIGHT", UIParent, "RIGHT", -16, 0)
  Style.Fill(panel, "panelBackground", "border")
  panel:EnableMouse(true)
  panel:SetClampedToScreen(true)

  panel.title = Style.NewText(panel, "title", "m")
  panel.title:SetPoint("TOPLEFT", 12, -12)
  panel.title:SetPoint("TOPRIGHT", -12, -12)
  panel.title:SetJustifyH("LEFT")
  panel.title:SetWordWrap(false)

  panel.x = NewNumberRow(L["X Offset"], "xOffset")
  panel.y = NewNumberRow(L["Y Offset"], "yOffset")
  panel.width = NewNumberRow(L["Width"], "width")
  panel.height = NewNumberRow(L["Height"], "height")
  panel.grow = NewCycleRow(L["Grow"], function()
    local data = WeakAuras.GetData(currentId)
    Apply("grow", Next(growOrder, data and data.grow))
  end)
  panel.align = NewCycleRow(L["Align"], function()
    local data = WeakAuras.GetData(currentId)
    Apply("align", Next(alignOrder, data and data.align))
  end)
  panel.space = NewNumberRow(L["Space"], "space")

  panel.anchor = CreateFrame("Frame", nil, panel)
  panel.anchor:SetSize(panelWidth - 24, 50)
  panel.anchor.text = NewLabel(panel.anchor, "")
  panel.anchor.text:SetTextColor(Style.Color("accent"))
  panel.anchor.text:SetPoint("TOPLEFT")
  panel.anchor.text:SetPoint("TOPRIGHT")
  panel.anchor.text:SetWordWrap(false)
  panel.anchor.link = Style.NewButton(panel.anchor, L["Anchor to..."], "secondary", function()
    OptionsPrivate.Private.PlacementBoxes.StartLink(currentId)
  end)
  panel.anchor.link:SetPoint("BOTTOMLEFT")
  panel.anchor.unlink = Style.NewButton(panel.anchor, L["Remove Anchor"], "danger", function()
    OptionsPrivate.Private.PlacementBoxes.Unlink(currentId)
  end)
  panel.anchor.unlink:SetPoint("BOTTOMRIGHT")

  -- The groups of the selected aura, from the top one down, each indented one step more: a click selects it.
  panel.path = CreateFrame("Frame", nil, panel)
  panel.path:SetWidth(panelWidth - 24)
  panel.path.label = NewLabel(panel.path, L["Its groups"])
  panel.path.label:SetPoint("TOPLEFT")
  panel.path.buttons = {}
  -- For a group with boxes in it: what a drag and a click inside it do.
  panel.hint = CreateFrame("Frame", nil, panel)
  -- Three lines of 12 px: the French text wraps on three.
  panel.hint:SetSize(panelWidth - 24, 42)
  panel.hint.text = NewLabel(panel.hint, L["Drag: moves the whole group. Click inside: selects one level lower."])
  panel.hint.text:SetTextColor(Style.Color("textQuiet"))
  panel.hint.text:SetAllPoints()
  panel.hint.text:SetJustifyV("TOP")
  panel.hint.text:SetWordWrap(true)

  panel.rows = { panel.path, panel.hint, panel.x, panel.y, panel.width, panel.height, panel.grow, panel.align,
    panel.space, panel.anchor }
end

-- The groups of the aura that have a box, from the top one down to its own group.
local function Groups(data)
  local Private = OptionsPrivate.Private
  local groups = {}
  local parent = data.parent
  while parent and Private.GetPlacementBox(parent) do
    table.insert(groups, 1, parent)
    local parentData = WeakAuras.GetData(parent)
    parent = parentData and parentData.parent
  end
  return groups
end

local function ShowPath(groups)
  local buttons = panel.path.buttons
  for index, groupId in ipairs(groups) do
    local button = buttons[index]
    if not button then
      button = Style.NewButton(panel.path, "", "quiet", function(self)
        OptionsPrivate.Private.PlacementBoxes.Select(self.auraId)
      end)
      -- A long name is cut at the right edge of the panel, as the title.
      button.text:ClearAllPoints()
      button.text:SetPoint("LEFT", 12, 0)
      button.text:SetPoint("RIGHT", -12, 0)
      button.text:SetWordWrap(false)
      buttons[index] = button
    end
    button.auraId = groupId
    -- The text is held between the edges of the button: its width is measured unbounded.
    button.text:SetText(groupId)
    button:SetSize(math.min(button.text:GetUnboundedStringWidth() + 24, panelWidth - 24 - (index - 1) * 12), 22)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", panel.path, "TOPLEFT", (index - 1) * 12, -16 - (index - 1) * 22)
    button:Show()
  end
  for index = #groups + 1, #buttons do
    buttons[index]:Hide()
  end
  panel.path:SetHeight(16 + #groups * 22)
  panel.path:SetShown(#groups > 0)
end

local growNames, alignNames, rotatedAlignNames
-- Shows the rows of the selected aura, one under the other; a row being typed in keeps its text.
function Refresh()
  local data = currentId and WeakAuras.GetData(currentId)
  if not data then
    panel:Hide()
    return
  end
  local Private = OptionsPrivate.Private
  growNames, alignNames, rotatedAlignNames = Private.grow_types, Private.align_types, Private.rotated_align_types
  local isGroup = Private.IsGroupType(data)
  local dynamic = data.regionType == "dynamicgroup"
  panel.title:SetText(currentId)
  ShowPath(Groups(data))
  local holdsBoxes = false
  for _, childId in ipairs(data.controlledChildren or {}) do
    holdsBoxes = holdsBoxes or Private.GetPlacementBox(childId) ~= nil
  end
  panel.hint:SetShown(holdsBoxes)
  Style.FitButton(panel.anchor.link)
  Style.FitButton(panel.anchor.unlink)
  panel.width:SetShown(data.width ~= nil and not isGroup)
  panel.height:SetShown(data.height ~= nil and not isGroup)
  panel.grow:SetShown(dynamic and data.grow ~= "CUSTOM")
  panel.align:SetShown(dynamic and alignedGrow[data.grow] or false)
  panel.space:SetShown(dynamic and (alignedGrow[data.grow] or circleGrow[data.grow] and data.constantFactor == "SPACING")
    or false)

  for _, row in ipairs({ panel.x, panel.y, panel.width, panel.height, panel.space }) do
    if row:IsShown() and not row.box:HasFocus() then
      local value = tonumber(data[row.field]) or 0
      row.box:SetText(("%g"):format(math.floor(value * 100 + 0.5) / 100))
      row.box:SetCursorPosition(0)
    end
  end
  if dynamic then
    Style.SetButtonText(panel.grow.button, growNames[data.grow] or data.grow or "")
    -- Left, right and horizontal grow lay the children in a row: align is then top, center or bottom.
    local names = (data.grow == "LEFT" or data.grow == "RIGHT" or data.grow == "HORIZONTAL") and rotatedAlignNames
      or alignNames
    Style.SetButtonText(panel.align.button, names[data.align] or data.align or "")
  end
  local targetId = Private.AnchorLinks.TargetAura(data)
  if targetId then
    panel.anchor.text:SetText(L["Follows: %s"]:format(targetId))
  elseif data.anchorFrameType == "SCREEN" or data.anchorFrameType == "UIPARENT" or not data.anchorFrameType then
    panel.anchor.text:SetText(data.parent and L["Follows: its group"] or L["Follows: the screen"])
  else
    panel.anchor.text:SetText(L["Follows: %s"]:format(tostring(data.anchorFrameFrame or data.anchorFrameType)))
  end
  panel.anchor.unlink:SetEnabled(targetId ~= nil)

  local previous
  local height = 40
  for _, row in ipairs(panel.rows) do
    if row:IsShown() then
      row:ClearAllPoints()
      if previous then
        row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -4)
      else
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -36)
      end
      height = height + row:GetHeight() + 4
      previous = row
    end
  end
  panel:SetHeight(height + 8)
  panel:Show()
end

OptionsPrivate.PlacementPanel = {
  --- Shows the placement of the aura id, hides the panel with nil.
  Show = function(id)
    if not panel then
      CreatePanel()
    end
    currentId = id
    Refresh()
  end,
  Hide = function()
    currentId = nil
    if panel then
      panel:Hide()
    end
  end,
}

if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local createCenterLines = true -- Creates only the middle lines
local showNormalLines = false -- Show all alignment lines all the time
local highlightColor = { 1, 1, 0 } -- The color of lines that are we are currently aligned too
local gridHighlightColor = { 0.3, 1, 0.3}
local normalColor = { 0.3, 0.3, 0.6, } -- The color of lines if they aren't matched if showNormalLines is enabled
local gridColor = { 0.3, 0.6, 0.3 } -- The color of grid lines, if they aren't matched and enabled

-- Lua APIs
local pairs = pairs

-- WoW APIs
local IsShiftKeyDown, CreateFrame = IsShiftKeyDown, CreateFrame

---@class WeakAuras
local WeakAuras = WeakAuras
local L = WeakAuras.L

local moversizer
local mover

-- Shared with the Edit Mode. Read on call: OptionsPrivate.Private is only set on the first /wa.
local function SnapDistance()
  return OptionsPrivate.Private.PlacementSnap.snapDistance
end

local function distance(num1, num2)
  return abs(num2 - num1)
end

local function EnsureTexture(self, texture)
  if texture then
    return texture
  else
    local ret = self:CreateTexture()
    ret:SetTexture("Interface\\GLUES\\CharacterSelect\\Glues-AddOn-Icons.blp")
    ret:SetWidth(16)
    ret:SetHeight(16)
    ret:SetTexCoord(0, 0.25, 0, 1)
    ret:SetVertexColor(1, 1, 1, 0.25)
    return ret
  end
end

-- Arrow buttons and keys. True when an aura moved; nothing moves with Lock Positions.
local function moveBy(deltaX, deltaY)
  if mover and mover.moving and not mover.isMoving and not WeakAurasOptionsSaved.lockPositions then
    local data = mover.moving.data
    local parentData = data and data.parent and WeakAuras.GetData(data.parent)
    -- A dynamic group places its children: their offsets are not used.
    if data and not (parentData and parentData.regionType == "dynamicgroup") then
      -- Whole units: a physical pixel is under half a unit on large screens and would round to no move.
      -- The axis not moved keeps its value.
      if deltaX ~= 0 then
        data.xOffset = Round(data.xOffset) + deltaX
      end
      if deltaY ~= 0 then
        data.yOffset = Round(data.yOffset) + deltaY
      end
      WeakAuras.Add(data, true)
      WeakAuras.UpdateThumbnail(data)
      OptionsPrivate.ResetMoverSizer()
      OptionsPrivate.Private.AddParents(data)
      WeakAuras.FillOptions()
      return true
    end
  end
  return false
end

local function ConstructMover(frame)
  local topAndBottom = CreateFrame("Frame", nil, frame)
  topAndBottom:SetClampedToScreen(true)
  topAndBottom:SetSize(25, 45)
  topAndBottom:SetPoint("LEFT", frame, "RIGHT", 1, 0)
  local top = CreateFrame("Button", nil, topAndBottom)
  top:SetSize(25, 25)
  top:SetPoint("TOP", topAndBottom)
  top:SetFrameStrata("BACKGROUND")
  local bottom = CreateFrame("Button", nil, topAndBottom)
  bottom:SetSize(25, 25)
  bottom:SetPoint("BOTTOM", topAndBottom)
  bottom:SetFrameStrata("BACKGROUND")

  local leftAndRight = CreateFrame("Frame", nil, frame)
  leftAndRight:SetClampedToScreen(true)
  leftAndRight:SetSize(45, 25)
  leftAndRight:SetPoint("TOP", frame, "BOTTOM", 0, 1)
  local left = CreateFrame("Button", nil, leftAndRight)
  left:SetSize(25, 25)
  left:SetPoint("LEFT", leftAndRight)
  left:SetFrameStrata("BACKGROUND")
  local right = CreateFrame("Button", nil, leftAndRight)
  right:SetSize(25, 25)
  right:SetPoint("RIGHT", leftAndRight)
  right:SetFrameStrata("BACKGROUND")

  top:SetNormalTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-up.blp")
  top:SetHighlightTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-highlight.blp")
  top:SetPushedTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-down.blp")
  top:SetScript("OnClick", function() moveBy(0, 1) end)

  bottom:SetNormalTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-up.blp")
  bottom:GetNormalTexture():SetTexCoord(0, 1, 1, 0)
  bottom:SetHighlightTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-highlight.blp")
  bottom:GetHighlightTexture():SetTexCoord(0, 1, 1, 0)
  bottom:SetPushedTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-down.blp")
  bottom:GetPushedTexture():SetTexCoord(0, 1, 1, 0)
  bottom:SetScript("OnClick", function() moveBy(0, -1) end)

  left:SetNormalTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-up.blp")
  left:GetNormalTexture():SetRotation(math.pi/2)
  left:SetHighlightTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-highlight.blp")
  left:GetHighlightTexture():SetRotation(math.pi/2)
  left:SetPushedTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-down.blp")
  left:GetPushedTexture():SetRotation(math.pi/2)
  left:SetScript("OnClick", function() moveBy(-1, 0) end)

  right:SetNormalTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-up.blp")
  right:GetNormalTexture():SetRotation(-math.pi/2)
  right:SetHighlightTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-highlight.blp")
  right:GetHighlightTexture():SetRotation(-math.pi/2)
  right:SetPushedTexture("interface\\buttons\\ui-scrollbar-scrollupbutton-down.blp")
  right:GetPushedTexture():SetRotation(-math.pi/2)
  right:SetScript("OnClick", function() moveBy(1, 0) end)

  local arrow = CreateFrame("Frame", nil, frame)
  arrow:SetClampedToScreen(true)
  arrow:SetSize(196, 196)
  arrow:SetPoint("CENTER", frame, "CENTER")
  arrow:SetFrameStrata("HIGH")
  local arrowTexture = arrow:CreateTexture()
  arrowTexture:SetTexture("Interface\\Addons\\WeakAuras\\Media\\Textures\\offscreen.tga")
  arrowTexture:SetSize(128, 128)
  arrowTexture:SetPoint("CENTER", arrow, "CENTER")
  arrowTexture:SetVertexColor(0.8, 0.8, 0.2)
  arrowTexture:Hide()
  local offscreenText = arrow:CreateFontString(nil, "OVERLAY")
  offscreenText:SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE");
  offscreenText:SetText(L["Aura is\nOff Screen"])
  offscreenText:Hide()
  offscreenText:SetPoint("CENTER", arrow, "CENTER")

  return arrowTexture, offscreenText
end

local function ConstructSizer(frame)
  -- topright, bottomright, bottomleft, topleft

  local topright = CreateFrame("Frame", nil, frame)
  topright:EnableMouse()
  topright:SetWidth(16)
  topright:SetHeight(16)
  topright:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

  local texTR1 = topright:CreateTexture(nil, "OVERLAY")
  texTR1:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texTR1:SetBlendMode("ADD")
  texTR1:SetTexCoord(0.5, 0, 0, 0, 0.5, 1, 0, 1)
  texTR1:SetPoint("TOPRIGHT", topright, "TOPRIGHT", -3, -3)
  texTR1:SetPoint("BOTTOMLEFT", topright, "BOTTOM")

  local texTR2 = topright:CreateTexture(nil, "OVERLAY")
  texTR2:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texTR2:SetBlendMode("ADD")
  texTR2:SetTexCoord(0, 0, 0, 1, 0.5, 0, 0.5, 1)
  texTR2:SetPoint("TOPRIGHT", texTR1, "TOPLEFT")
  texTR2:SetPoint("BOTTOMLEFT", topright, "LEFT")

  topright.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texTR1:Show()
    texTR2:Show()
  end
  topright.Clear = function()
    texTR1:Hide()
    texTR2:Hide()
  end

  local bottomright = CreateFrame("Frame", nil, frame)
  bottomright:EnableMouse()
  bottomright:SetWidth(16)
  bottomright:SetHeight(16)
  bottomright:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

  local texBR1 = bottomright:CreateTexture(nil, "OVERLAY")
  texBR1:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texBR1:SetBlendMode("ADD")
  texBR1:SetTexCoord(1, 0, 0.5, 0, 1, 1, 0.5, 1)
  texBR1:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMRIGHT", -3, 3)
  texBR1:SetPoint("TOPLEFT", bottomright, "TOP")

  local texBR2 = bottomright:CreateTexture(nil, "OVERLAY")
  texBR2:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texBR2:SetBlendMode("ADD")
  texBR2:SetTexCoord(0, 0, 0, 1, 0.5, 0, 0.5, 1)
  texBR2:SetPoint("BOTTOMRIGHT", texBR1, "BOTTOMLEFT")
  texBR2:SetPoint("TOPLEFT", bottomright, "LEFT")

  bottomright.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texBR1:Show()
    texBR2:Show()
  end
  bottomright.Clear = function()
    texBR1:Hide()
    texBR2:Hide()
  end

  local bottomleft = CreateFrame("Frame", nil, frame)
  bottomleft:EnableMouse()
  bottomleft:SetSize(16, 16)
  bottomleft:SetHeight(16)
  bottomleft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")

  local texBL1 = bottomleft:CreateTexture(nil, "OVERLAY")
  texBL1:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texBL1:SetBlendMode("ADD")
  texBL1:SetTexCoord(1, 0, 0.5, 0, 1, 1, 0.5, 1)
  texBL1:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMLEFT", 3, 3)
  texBL1:SetPoint("TOPRIGHT", bottomleft, "TOP")

  local texBL2 = bottomleft:CreateTexture(nil, "OVERLAY")
  texBL2:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texBL2:SetBlendMode("ADD")
  texBL2:SetTexCoord(0.5, 0, 0.5, 1, 1, 0, 1, 1)
  texBL2:SetPoint("BOTTOMLEFT", texBL1, "BOTTOMRIGHT")
  texBL2:SetPoint("TOPRIGHT", bottomleft, "RIGHT")

  bottomleft.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texBL1:Show()
    texBL2:Show()
  end
  bottomleft.Clear = function()
    texBL1:Hide()
    texBL2:Hide()
  end

  local topleft = CreateFrame("Frame", nil, frame)
  topleft:EnableMouse()
  topleft:SetWidth(16)
  topleft:SetHeight(16)
  topleft:SetPoint("TOPLEFT", frame, "TOPLEFT")

  local texTL1 = topleft:CreateTexture(nil, "OVERLAY")
  texTL1:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texTL1:SetBlendMode("ADD")
  texTL1:SetTexCoord(0.5, 0, 0, 0, 0.5, 1, 0, 1)
  texTL1:SetPoint("TOPLEFT", topleft, "TOPLEFT", 3, -3)
  texTL1:SetPoint("BOTTOMRIGHT", topleft, "BOTTOM")

  local texTL2 = topleft:CreateTexture(nil, "OVERLAY")
  texTL2:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texTL2:SetBlendMode("ADD")
  texTL2:SetTexCoord(0.5, 0, 0.5, 1, 1, 0, 1, 1)
  texTL2:SetPoint("TOPLEFT", texTL1, "TOPRIGHT")
  texTL2:SetPoint("BOTTOMRIGHT", topleft, "RIGHT")

  topleft.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texTL1:Show()
    texTL2:Show()
  end
  topleft.Clear = function()
    texTL1:Hide()
    texTL2:Hide()
  end

  -- top, right, bottom, left

  local top = CreateFrame("Frame", nil, frame)
  top:EnableMouse()
  top:SetHeight(8)
  top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
  top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")

  local texT = top:CreateTexture(nil, "OVERLAY")
  texT:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texT:SetBlendMode("ADD")
  texT:SetPoint("TOPRIGHT", topright, "TOPRIGHT", -3, -3)
  texT:SetPoint("BOTTOMLEFT", topleft, "LEFT", 3, 0)

  top.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texT:Show()
  end
  top.Clear = function()
    texT:Hide()
  end

  local right = CreateFrame("Frame", nil, frame)
  right:EnableMouse()
  right:SetWidth(8)
  right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
  right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")

  local texR = right:CreateTexture(nil, "OVERLAY")
  texR:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texR:SetBlendMode("ADD")
  texR:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMRIGHT", -3, 3)
  texR:SetPoint("TOPLEFT", topright, "TOP", 0, -3)

  right.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texR:Show()
  end
  right.Clear = function()
    texR:Hide()
  end

  local bottom = CreateFrame("Frame", nil, frame)
  bottom:EnableMouse()
  bottom:SetHeight(8)
  bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
  bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")

  local texB = bottom:CreateTexture(nil, "OVERLAY")
  texB:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texB:SetBlendMode("ADD")
  texB:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
  texB:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMLEFT", 3, 3)
  texB:SetPoint("TOPRIGHT", bottomright, "RIGHT", -3, 0)

  bottom.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texB:Show()
  end
  bottom.Clear = function()
    texB:Hide()
  end

  local left = CreateFrame("Frame", nil, frame)
  left:EnableMouse()
  left:SetWidth(8)
  left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
  left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")

  local texL = left:CreateTexture(nil, "OVERLAY")
  texL:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
  texL:SetBlendMode("ADD")
  texL:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
  texL:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMLEFT", 3, 3)
  texL:SetPoint("TOPRIGHT", topleft, "TOP", 0, -3)

  left.Highlight = function()
    if WeakAurasOptionsSaved.lockPositions then
      return
    end
    texL:Show()
  end
  left.Clear = function()
    texL:Hide()
  end

  -- return in cw order
  return top, topright, right, bottomright, bottom, bottomleft, left, topleft
end

--- @class AlignmentLineReference
--- @field id auraId
--- @field side "LEFT"|"RIGHT"|"TOP"|"BOTTOM"|"CENTERX"|"CENTERY" The side the reference
--- @field pos1 number The bottom position for vertical or the left position for horizontal lines
--- @field pos2 number The top position for vertical or the right position for horizontal lines

--- @class AlignmentLine
--- @field SetStartPoint fun(self: AlignmentLine, relativePoint: AnchorPoint, relativeTo: Region, offsetX: number?, offsetY: number?)
--- @field SetEndPoint fun(self: AlignmentLine, relativePoint: AnchorPoint, relativeTo: Region, offsetX: number?, offsetY: number?)
--- @field SetThickness fun(self: AlignmentLine, thickness: number)
--- @field SetHighlighted fun(self: AlignmentLine, highlight: boolean)

--- @class LineObjectPool
--- @field Acquire fun(self: LineObjectPool): AlignmentLine
--- @field Release fun(self: LineObjectPool, line: AlignmentLine)

--- @class LineInformation
--- @field position number
--- @field delta number
--- @field gridLine boolean
--- @field references AlignmentLineReference[]
--- @field highlightTextures Texture[]
--- @field line AlignmentLine?
--- @field SetStartPoint fun(self: LineInformation, relativePoint: AnchorPoint, relativeTo: Region, offsetX: number?, offsetY: number?)
--- @field SetEndPoint fun(self: LineInformation, relativePoint: AnchorPoint, relativeTo: Region, offsetX: number?, offsetY: number?)
--- @field SetThickness fun(self: LineInformation, thickness: number)
--- @field SetHighlighted fun(self: LineInformation, highlight: boolean)
--- @field Hide fun(self: LineInformation)
--- @field Show fun(self: LineInformation)
--- @field UpdateColor fun(self: LineInformation)
--- @field UpdateHighlight fun(self: LineInformation)
--- @field AcquireLine fun(self: LineInformation)
--- @field ReleaseLine fun(self: LineInformation)
--- @field Release fun(self: LineInformation)
--- @field Score fun(self: LineInformation, positions: table<"LEFT"|"RIGHT"|"TOP"|"BOTTOM"|"CENTERX"|"CENTERY", number>): number

--- @class AlignmentLines
local AlignmentLines = CreateFrame("Frame", nil, UIParent) --[[@as AlignmentLines]]
AlignmentLines:SetAllPoints(UIParent)
AlignmentLines:SetFrameStrata("BACKGROUND")

local HighlightFrame = CreateFrame("Frame", nil, UIParent)
HighlightFrame:SetAllPoints(UIParent)
HighlightFrame:SetFrameStrata("TOOLTIP")

--- @type LineObjectPool
AlignmentLines.linePool = CreateObjectPool(
  function(self)
    return AlignmentLines:CreateLine()
  end,
  function(self, line)
    line:Hide()
  end)

HighlightFrame.texturePool = CreateObjectPool(
  function(self)
    local tex = HighlightFrame:CreateTexture()
    tex:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp")
    tex:SetVertexColor(1, 1, 1, 0.3)
    return tex
  end,
  function(self, texture)
    texture:Hide()
    texture:ClearAllPoints()
  end)

--- @class LineInformation
local LineInformationFuncs = {
  SetStartPoint = function(self, relativePoint, relativeTo, offsetX, offsetY)
    self.startPoint = {relativePoint, relativeTo, offsetX, offsetY}
    if self.line then
      self.line:SetStartPoint(relativePoint, relativeTo, offsetX, offsetY)
    end
  end,
  SetEndPoint = function(self, relativePoint, relativeTo, offsetX, offsetY)
    self.endPoint = {relativePoint, relativeTo, offsetX, offsetY}
    if self.line then
      self.line:SetEndPoint(relativePoint, relativeTo, offsetX, offsetY)
    end
  end,
  SetThickness = function(self, thickness)
    self.thickness = thickness
    if self.line then
      self.line:SetThickness(thickness)
    end
  end,
  Show = function(self)
    if not self.line then
      self:AcquireLine()
    end
    self:UpdateColor()
    self.line:SetStartPoint(unpack(self.startPoint))
    self.line:SetEndPoint(unpack(self.endPoint))
    self.line:SetThickness(self.thickness)
    self.line:Show()
  end,
  SetHighlighted = function(self, highlight)
    if self.highlight == highlight then
      return
    end

    local needLine = highlight or showNormalLines
    self.highlight = highlight

    if needLine and not self.line then
      self:Show()
    elseif not needLine and self.line then
      self:ReleaseLine()
    end
    self:UpdateColor()
    self:UpdateHighlight()
  end,
  UpdateColor = function(self)
    if not self.line then
      return
    end

    if self.highlight then
      if self.gridLine then
        self.line:SetColorTexture(unpack(gridHighlightColor))
      else
        self.line:SetColorTexture(unpack(highlightColor))
      end
    else
      if self.gridLine then
        self.line:SetColorTexture(unpack(gridColor))
      else
        self.line:SetColorTexture(unpack(normalColor))
      end
    end
  end,
  UpdateHighlight = function(self)
    if self.highlight then
      for _, data in ipairs(self.references) do
        local region = WeakAuras.GetRegion(data.id)
        local texture = HighlightFrame.texturePool:Acquire()
        texture:SetAllPoints(region)
        texture:SetDrawLayer("ARTWORK", 7)
        texture:Show()
        tinsert(self.highlightTextures, texture)
      end
    else
      for _, texture in ipairs(self.highlightTextures) do
        HighlightFrame.texturePool:Release(texture)
      end
      wipe(self.highlightTextures)
    end
  end,
  AcquireLine = function(self)
    if not self.line then
      self.line = AlignmentLines.linePool:Acquire()
    end
  end,
  ReleaseLine = function(self)
    if self.line then
      AlignmentLines.linePool:Release(self.line)
      self.line = nil
    end
  end,
  Release = function(self)
    -- Clears any aura highlights
    self:SetHighlighted(false)
    self:ReleaseLine()
  end,
  --- @type fun(self: LineInformation, positions: table<"LEFT"|"RIGHT"|"BOTTOM"|"TOP"|"CENTERX"|"CENTERY", number>) : number
  Score = function(self, positions)
    return OptionsPrivate.Private.PlacementSnap.Score(self, positions, SnapDistance())
  end,

}

--- @type fun(position: number, gridLine: boolean): LineInformation
local function CreateLineInformation(position, gridLine)
  local line = OptionsPrivate.Private.PlacementSnap.NewLine(position, gridLine)
  for k, f in pairs(LineInformationFuncs) do
    line[k] = f
  end
  line.highlightTextures = {}
  line.highlight = nil
  return line
end

--- @type table<number, LineInformation>
AlignmentLines.horizontalLines = {}
--- @type table<number, LineInformation>
AlignmentLines.verticalLines = {}

--- @type fun(input: number): number
local function RoundSmallDifference(input)
  local r = Round(input)
  if (abs(r - input) < 0.1) then
    return r
  end
  return input
end

--- @type fun(input: number): number
local function AlignToPixelX(virX)
  local physicalWidth, physicalHeight = GetPhysicalScreenSize();
  local virtualWidth = GetScreenWidth()
  local phyX = virX * physicalWidth / virtualWidth
  return Round(10 * Round(phyX) * virtualWidth / physicalWidth) / 10
end

--- @type fun(input: number): number
local function AlignToPixelY(virY)
  local physicalWidth, physicalHeight = GetPhysicalScreenSize();
  local virtualHeight = GetScreenHeight()
  local phyY = virY * physicalHeight / virtualHeight
  return Round(10 * Round(phyY) * virtualHeight / physicalHeight) / 10
end

---@param self AlignmentLines
---@param sizerPoint AnchorPoint?
AlignmentLines.CreateMiddleLines = function(self, sizerPoint)
  if not createCenterLines then
    return
  end

  local midX, midY = UIParent:GetCenter()
  midX = RoundSmallDifference(midX)
  midY = RoundSmallDifference(midY)
  if not sizerPoint or sizerPoint:find("LEFT", 1) or sizerPoint:find("RIGHT", 1) then
    local line = CreateLineInformation(midX, true)
    line:SetStartPoint("TOPLEFT", UIParent, midX, 0)
    line:SetEndPoint("BOTTOMLEFT", UIParent, midX, 0)
    line:SetThickness(2)
    self.verticalLines[midX] = line
  end

  if not sizerPoint or sizerPoint:find("BOTTOM") or sizerPoint:find("TOP") then
    local line = CreateLineInformation(midY, true)
    line:SetStartPoint("BOTTOMLEFT", UIParent, 0, midY)
    line:SetEndPoint("BOTTOMRIGHT", UIParent, 0, midY)
    line:SetThickness(2)
    self.horizontalLines[midY] = line
  end
end

local function AddScreenLine(lines, position, vertical)
  if lines[position] then
    return
  end
  local line = CreateLineInformation(position, true)
  if vertical then
    line:SetStartPoint("TOPLEFT", UIParent, position, 0)
    line:SetEndPoint("BOTTOMLEFT", UIParent, position, 0)
  else
    line:SetStartPoint("BOTTOMLEFT", UIParent, 0, position)
    line:SetEndPoint("BOTTOMRIGHT", UIParent, 0, position)
  end
  line:SetThickness(2)
  lines[position] = line
end

-- Pitch of the /wa grid in UIParent units, set by the slider of the Grid button.
local function GridSpacing()
  -- Bounded like the slider: a zero or tiny pitch from an edited saved file would loop without end.
  local spacing = tonumber(WeakAurasOptionsSaved.gridSpacing)
  if not spacing or spacing ~= spacing then
    return 64
  end
  return math.min(math.max(Round(spacing), 8), 128)
end
OptionsPrivate.GridSpacing = GridSpacing

-- The grid drawn while the options are open with the Grid option: the same lines as the snap, the middle ones stronger.
local PlacementGrid = CreateFrame("Frame", nil, UIParent)
PlacementGrid:SetAllPoints(UIParent)
PlacementGrid:SetFrameStrata("BACKGROUND")
PlacementGrid:Hide()
PlacementGrid.lines = {}
OptionsPrivate.PlacementGrid = PlacementGrid

local function DrawGrid()
  for _, line in ipairs(PlacementGrid.lines) do
    line:Hide()
  end
  local count = 0
  local function Add(position, middle, vertical)
    count = count + 1
    local line = PlacementGrid.lines[count] or PlacementGrid:CreateLine(nil, "BACKGROUND")
    PlacementGrid.lines[count] = line
    if vertical then
      line:SetStartPoint("TOPLEFT", UIParent, position, 0)
      line:SetEndPoint("BOTTOMLEFT", UIParent, position, 0)
    else
      line:SetStartPoint("BOTTOMLEFT", UIParent, 0, position)
      line:SetEndPoint("BOTTOMRIGHT", UIParent, 0, position)
    end
    local color = middle and gridHighlightColor or gridColor
    line:SetColorTexture(color[1], color[2], color[3], middle and 0.6 or 0.3)
    -- In whole pixels, as the Edit Mode grid: a thickness under one pixel hides some lines and merges their cells.
    local thickness = middle and 2 or 1.2
    if PixelUtil and PixelUtil.GetNearestPixelSize then
      thickness = PixelUtil.GetNearestPixelSize(thickness, line:GetEffectiveScale(), thickness)
    end
    line:SetThickness(thickness)
    line:Show()
  end
  local spacing = GridSpacing()
  local midX, midY = UIParent:GetCenter()
  for _, position in ipairs(OptionsPrivate.Private.PlacementSnap.ScreenLines(UIParent:GetWidth(), midX, spacing)) do
    Add(position, position == midX, true)
  end
  for _, position in ipairs(OptionsPrivate.Private.PlacementSnap.ScreenLines(UIParent:GetHeight(), midY, spacing)) do
    Add(position, position == midY, false)
  end
end
PlacementGrid:SetScript("OnShow", DrawGrid)
PlacementGrid:SetScript("OnSizeChanged", function()
  if PlacementGrid:IsShown() then
    DrawGrid()
  end
end)

-- Shown with the Grid option while the options frame is open, drawn again when the pitch changes.
-- Hidden in Edit Mode, which snaps to the Blizzard grid.
local optionsFrame
function OptionsPrivate.UpdatePlacementGrid()
  local editMode = EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive()
  if WeakAurasOptionsSaved.gridAlign and optionsFrame and optionsFrame:IsShown() and not editMode then
    if PlacementGrid:IsShown() then
      DrawGrid()
    else
      PlacementGrid:Show()
    end
  else
    PlacementGrid:Hide()
  end
end

-- The screen edges, and with the Grid option the lines of the /wa grid, centered on the screen.
---@param self AlignmentLines
---@param sizerPoint AnchorPoint?
AlignmentLines.CreateScreenLines = function(self, sizerPoint)
  local width, height = UIParent:GetWidth(), UIParent:GetHeight()
  local addVertical = not sizerPoint or sizerPoint:find("LEFT", 1) or sizerPoint:find("RIGHT", 1)
  local addHorizontal = not sizerPoint or sizerPoint:find("BOTTOM", 1) or sizerPoint:find("TOP", 1)
  -- Only the grid on screen snaps: none while Edit Mode hides it.
  local spacing = WeakAurasOptionsSaved.gridAlign and PlacementGrid:IsShown() and GridSpacing() or nil
  local midX, midY = UIParent:GetCenter()
  if addVertical then
    for _, position in ipairs(OptionsPrivate.Private.PlacementSnap.ScreenLines(width, midX, spacing)) do
      AddScreenLine(self.verticalLines, RoundSmallDifference(position), true)
    end
  end
  if addHorizontal then
    for _, position in ipairs(OptionsPrivate.Private.PlacementSnap.ScreenLines(height, midY, spacing)) do
      AddScreenLine(self.horizontalLines, RoundSmallDifference(position), false)
    end
  end
end

--- @type fun(self: AlignmentLines, data: auraData, sizerPoint: AnchorPoint?): LineInformation, LineInformation
AlignmentLines.CreateLineInformation = function(self, data, sizerPoint)
  local addVertical = not sizerPoint or sizerPoint:find("LEFT", 1) or sizerPoint:find("RIGHT", 1)
  local addHorizontal = not sizerPoint or sizerPoint:find("BOTTOM", 1) or sizerPoint:find("TOP", 1)

  --- @type LineInformation, LineInformation
  local horizontalLines, verticalLines = {}, {}
  --- @type table<auraId, boolean>
  local skipIds = {}
  for child in OptionsPrivate.Private.TraverseAll(data) do
    skipIds[child.id] = true
  end

  for id, v in pairs(OptionsPrivate.displayButtons) do
    local region = WeakAuras.GetRegion(v.data.id)
    if not skipIds[id]
       and v.view.visibility >= 1
       and region and not region:IsAnchoringRestricted()
       and v.data.regionType ~= "group"
       and v.data.regionType ~= "dynamicgroup"
    then
      local scale = region:GetEffectiveScale() / UIParent:GetEffectiveScale()
      local left = region:GetLeft()
      left = left and AlignToPixelX(left * scale) or nil
      local right = region:GetRight()
      right = right and AlignToPixelX(right * scale) or nil
      local top = region:GetTop()
      top = top and AlignToPixelY(top * scale) or nil
      local bottom = region:GetBottom()
      bottom = bottom and AlignToPixelY(bottom * scale) or nil
      local centerX, centerY = region:GetCenter()
      centerX = centerX and AlignToPixelX(centerX * scale) or nil
      centerY = centerY and AlignToPixelY(centerY * scale) or nil

      OptionsPrivate.Private.PlacementSnap.AddAuraLines(verticalLines, horizontalLines, id,
        { left, bottom, right, top, centerX, centerY }, IsControlKeyDown(), addVertical, addHorizontal,
        CreateLineInformation)
    end
  end

  local Merge = OptionsPrivate.Private.PlacementSnap.MergeLines
  return Merge(verticalLines), Merge(horizontalLines)
end

---@param self AlignmentLines
AlignmentLines.CleanUpLines = function(self)
  for _, line in pairs(self.horizontalLines) do
    line:Release()
  end

  for _, line in pairs(self.verticalLines) do
    line:Release()
  end

  wipe(self.horizontalLines)
  wipe(self.verticalLines)
end

---@param self AlignmentLines
---@param data auraData
---@param sizerPoint AnchorPoint?
AlignmentLines.CreateLines = function(self, data, sizerPoint)
  self:CleanUpLines()

  local align = (WeakAurasOptionsSaved.magnetAlign and not IsShiftKeyDown())
                    or (not WeakAurasOptionsSaved.magnetAlign and IsShiftKeyDown())
  if align then
    self:CreateMiddleLines(sizerPoint)

    local auraVerticalLinesInfo, auraHorizontalLinesInfo = self:CreateLineInformation(data, sizerPoint)

    for _, lineInfo in ipairs(auraVerticalLinesInfo) do
      local x = lineInfo.position
      if self.verticalLines[floor(x)] or self.verticalLines[ceil(x)] then
        -- Grid lines are always on integer values
        -- Ignore a grid line that is close enough is already there
      else
        lineInfo:SetStartPoint("TOPLEFT", UIParent, x, 0)
        lineInfo:SetEndPoint("BOTTOMLEFT", UIParent, x, 0)
        lineInfo:SetThickness(2)
        self.verticalLines[x] = lineInfo
      end
    end

    for _, lineInfo in ipairs(auraHorizontalLinesInfo) do
      local y = lineInfo.position
      if self.horizontalLines[floor(y)] or self.horizontalLines[ceil(y)] then
        -- Grid lines are always on integer values
        -- Ignore a grid line that is close enough is already there
      else
        lineInfo:SetStartPoint("BOTTOMLEFT", UIParent, 0, y)
        lineInfo:SetEndPoint("BOTTOMRIGHT", UIParent, 0, y)
        lineInfo:SetThickness(2)
        self.horizontalLines[y] = lineInfo
      end
    end

    -- After the aura lines: an aura line is not dropped for a grid or edge line under one unit away.
    self:CreateScreenLines(sizerPoint)
  end
end

---@param lines AlignmentLine[]
---@param positions table<"LEFT"|"RIGHT"|"TOP"|"BOTTOM"|"CENTERX"|"CENTERY", number>
---       The positions of the aura, that are used to score lines
---@param auraSize number?
---       The size of the aura, this is used to highlight additional lines that exactly
---       auraSize away
---@return number? -- The delta
local function SelectLines(lines, positions, auraSize)
  if #lines == 0 then
    -- Nothing to do
  elseif #lines == 1 then
    lines[1]:SetHighlighted(true)
    return lines[1].delta
  else
    local bestLine = OptionsPrivate.Private.PlacementSnap.Best(lines, positions, SnapDistance())
    for _, line in ipairs(lines) do
      if line == bestLine then
        line:SetHighlighted(true)
      elseif bestLine then
        local diffBetweenLines = distance(line.position, bestLine.position)
        if auraSize and distance(diffBetweenLines, auraSize) < 1 then
          -- Other line is the as far away as the aura is wide
          line:SetHighlighted(true)
        else
          line:SetHighlighted(false)
        end
      else
        line:SetHighlighted(false)
      end
    end
    return bestLine and bestLine.delta
  end
end

AlignmentLines.ShowLinesFor = function(self, ctrlKey, region, sizePoint)
  local align = (WeakAurasOptionsSaved.magnetAlign and not IsShiftKeyDown())
                    or (not WeakAurasOptionsSaved.magnetAlign and IsShiftKeyDown())
  if not align then
    return
  end

  local scale = region:GetEffectiveScale() / UIParent:GetScale()

  local centerX, centerY = region:GetCenter()
  -- No rect yet, as on the frame a move starts: the lines wait for the next update, the snap of a previous move dropped.
  if not centerX then
    mover.verticalDelta, mover.horizontalDelta = nil, nil
    return
  end
  centerX, centerY = centerX * scale, centerY * scale
  local left, right = region:GetLeft() * scale, region:GetRight() * scale
  local top, bottom = region:GetTop() * scale, region:GetBottom() * scale

  if region.regionType == "group" then
    left = left + region.blx * scale
    right = right + region.trx * scale
    bottom = bottom + region.bly * scale
    top = top + region.try * scale
    centerX = (left + right) / 2
    centerY = (bottom + top) / 2
  end

  local positions = {
    LEFT = left,
    RIGHT = right,
    TOP = top,
    BOTTOM = bottom,
    CENTERX = centerX,
    CENTERY = centerY
  }

  -- The edges that snap: the dragged corner, the centers with Ctrl, or the four edges. With the four edges, the
  -- center sticks to the screen and grid lines too, never to the edge of an aura, as in the Edit Mode.
  local verticalEdges, horizontalEdges, auraWidth, auraHeight, screenCenterX, screenCenterY
  if sizePoint then
    verticalEdges = { sizePoint:find("LEFT", 1) and left or right }
    horizontalEdges = { sizePoint:find("TOP", 1) and top or bottom }
  elseif ctrlKey then
    verticalEdges, horizontalEdges = { centerX }, { centerY }
  else
    verticalEdges, horizontalEdges = { left, right }, { bottom, top }
    auraWidth, auraHeight = right - left, top - bottom
    screenCenterX, screenCenterY = centerX, centerY
  end
  local function Potentials(lines, edges, center)
    local Candidates = OptionsPrivate.Private.PlacementSnap.Candidates
    local auraLines, screenLines = {}, {}
    for _, line in pairs(lines) do
      local list = line.gridLine and screenLines or auraLines
      list[#list + 1] = line
    end
    local potentials, isPotential = Candidates(auraLines, SnapDistance(), unpack(edges))
    local screenPotentials, isScreenPotential = Candidates(screenLines, SnapDistance(), center, unpack(edges))
    for _, line in ipairs(screenPotentials) do
      potentials[#potentials + 1] = line
    end
    for _, line in pairs(lines) do
      if not (isPotential[line] or isScreenPotential[line]) then
        line:SetHighlighted(false)
      end
    end
    return potentials
  end
  mover.verticalDelta = SelectLines(Potentials(self.verticalLines, verticalEdges, screenCenterX), positions,
    auraWidth)
  mover.horizontalDelta = SelectLines(Potentials(self.horizontalLines, horizontalEdges, screenCenterY), positions,
    auraHeight)
end

local function ConstructMoverSizer(parent)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  frame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
  })
  frame:EnableMouse()

  frame.top, frame.topright, frame.right, frame.bottomright, frame.bottom, frame.bottomleft, frame.left, frame.topleft
  = ConstructSizer(frame)

  frame.arrowTexture, frame.offscreenText = ConstructMover(frame)
  -- Shown only with an aura selected in /wa. A focused edit box of the options gets its keys first.
  -- Lock Positions leaves the keys to the game, like the drag and the resize.
  -- With several auras picked, the mover stays on the first one: the keys go to the game.
  OptionsPrivate.Private.MoveWithArrowKeys(frame, function(deltaX, deltaY)
    return not WeakAurasOptionsSaved.lockPositions and type(parent.pickedDisplay) == "string" and moveBy(deltaX, deltaY)
  end)

  frame.top.Clear()
  frame.topright.Clear()
  frame.right.Clear()
  frame.bottomright.Clear()
  frame.bottom.Clear()
  frame.bottomleft.Clear()
  frame.left.Clear()
  frame.topleft.Clear()

  local mover = CreateFrame("Frame", nil, frame)
  mover:EnableMouse()
  mover.moving = {}
  mover.interims = {}
  mover.selfPointIcon = mover:CreateTexture()
  mover.selfPointIcon:SetTexture("Interface\\GLUES\\CharacterSelect\\Glues-AddOn-Icons.blp")
  mover.selfPointIcon:SetWidth(16)
  mover.selfPointIcon:SetHeight(16)
  mover.selfPointIcon:SetTexCoord(0, 0.25, 0, 1)
  mover.anchorPointIcon = mover:CreateTexture()
  mover.anchorPointIcon:SetTexture("Interface\\GLUES\\CharacterSelect\\Glues-AddOn-Icons.blp")
  mover.anchorPointIcon:SetWidth(16)
  mover.anchorPointIcon:SetHeight(16)
  mover.anchorPointIcon:SetTexCoord(0, 0.25, 0, 1)

  local moverText = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  mover.text = moverText
  moverText:Hide()

  local sizerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.text = sizerText
  sizerText:Hide()

  frame.ScaleCorners = function(self, width, height)
    local limit = math.min(width, height) + 16
    local size = 16
    if limit <= 40 then
      size = limit * (2/5)
    end
    frame.bottomleft:SetWidth(size)
    frame.bottomleft:SetHeight(size)
    frame.bottomright:SetWidth(size)
    frame.bottomright:SetHeight(size)
    frame.topright:SetWidth(size)
    frame.topright:SetHeight(size)
    frame.topleft:SetWidth(size)
    frame.topleft:SetHeight(size)
  end

  frame.ReAnchor = function(self)
    if mover.moving.region then
      self:AnchorPoints(mover.moving.region, mover.moving.data)
    end
  end

  frame.AnchorPoints = function(self, region, data)
    local scale = region:GetEffectiveScale() / UIParent:GetEffectiveScale()
    if data.regionType == "group" then
      mover:SetWidth((region.trx - region.blx) * scale)
      mover:SetHeight((region.try - region.bly) * scale)
    else
      mover:SetWidth(region:GetWidth() * scale)
      mover:SetHeight(region:GetHeight() * scale)
    end
  end

  frame.GetCurrentId = function(self)
    return self.currentId
  end

  frame.SizingSetData = function(self, data, width, height, alignDeltaX, alignDeltaY, scale)
    alignDeltaX = alignDeltaX or 0
    alignDeltaY = alignDeltaY or 0

    local deltaWidth = width - data.width
    local deltaHeight = height - data.height

    local auraSelfPoint = data.selfPoint
    local moverSizePoint = mover.sizePoint

    local parent = data.parent
    if parent then
      local parentData = WeakAuras.GetData(parent)
      if parentData and parentData.regionType == "dynamicgroup" then
        -- If the aura is in a dynamic group then we don't want to set xOffset/yOffset at all.
        -- These settings ensure that
        -- The fixed corner is the one opposite the dragged edge, so that the alignment delta keeps its sign.
        local top = moverSizePoint:find("TOP", 1)
        local left = moverSizePoint:find("LEFT", 1)
        auraSelfPoint = (top and "BOTTOM" or "TOP") .. (left and "RIGHT" or "LEFT")
        moverSizePoint = (top and "TOP" or "BOTTOM") .. (left and "LEFT" or "RIGHT")
      end
    end

    if auraSelfPoint:find("LEFT", 1) then
      if moverSizePoint:find("LEFT", 1) then
        data.xOffset = data.xOffset - deltaWidth + alignDeltaX / scale
        data.width = width - alignDeltaX / scale
      elseif moverSizePoint:find("RIGHT", 1) then
        data.width = width + alignDeltaX / scale
      end
    elseif auraSelfPoint:find("RIGHT", 1) then
      if moverSizePoint:find("LEFT", 1) then
        data.width = width - alignDeltaX / scale
      elseif moverSizePoint:find("RIGHT", 1) then
        data.xOffset = data.xOffset + deltaWidth + alignDeltaX / scale
        data.width = width + alignDeltaX / scale
      end
    else -- CENTER
      if moverSizePoint:find("LEFT", 1) then
        data.xOffset = data.xOffset - deltaWidth / 2 + alignDeltaX / 2 / scale
        data.width = width - alignDeltaX / scale
      else
        data.xOffset = data.xOffset + deltaWidth / 2 + alignDeltaX / 2 / scale
        data.width = width + alignDeltaX / scale
      end
    end

    if auraSelfPoint:find("BOTTOM", 1) then
      if moverSizePoint:find("BOTTOM", 1) then
        data.yOffset = data.yOffset - deltaHeight + alignDeltaY / scale
        data.height = height - alignDeltaY / scale
      elseif moverSizePoint:find("TOP", 1) then
        data.height = height + alignDeltaY / scale
      end
    elseif auraSelfPoint:find("TOP", 1) then
      if moverSizePoint:find("BOTTOM", 1) then
        data.height = height - alignDeltaY / scale
      elseif moverSizePoint:find("TOP", 1) then
        data.yOffset = data.yOffset + deltaHeight + alignDeltaY / scale
        data.height = height + alignDeltaY / scale
      end
    else -- CENTER
      if moverSizePoint:find("BOTTOM", 1) then
        data.yOffset = data.yOffset - deltaHeight / 2 + alignDeltaY / 2 / scale
        data.height = height - alignDeltaY / scale
      else
        data.yOffset = data.yOffset + deltaHeight / 2 + alignDeltaY / 2 / scale
        data.height = height + alignDeltaY / scale
      end
    end
  end

  frame.SetToRegion = function(self, region, data)
    frame.currentId = data.id
    local scale = region:GetEffectiveScale() / UIParent:GetEffectiveScale()
    mover.moving.region = region
    mover.moving.data = data
    mover.onUpdate(mover, 0)
    local ok, selfPoint, anchor, anchorPoint, xOff, yOff = pcall(region.GetPoint, region, 1)
    if not ok then
      return
    end
    self:Show()

    mover.selfPoint, mover.anchor, mover.anchorPoint = selfPoint, anchor, anchorPoint

    xOff = xOff or 0
    yOff = yOff or 0
    mover:ClearAllPoints()
    frame:ClearAllPoints()
    if data.regionType == "group" then
      local blx, bly, trx, try = region:GetBoundingRect()
      mover:SetWidth((trx - blx) * scale)
      mover:SetHeight((try - bly) * scale)

      mover:SetPoint("BOTTOMLEFT", mover.anchor or UIParent, mover.anchorPoint or "CENTER",
                     (xOff + region.blx) * scale, (yOff + region.bly) * scale)
    else
      mover:SetWidth(region:GetWidth() * scale)
      mover:SetHeight(region:GetHeight() * scale)
      mover:SetPoint(mover.selfPoint or "CENTER", mover.anchor or UIParent, mover.anchorPoint or "CENTER",
                     xOff * scale, yOff * scale)
    end
    frame:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", -8, -8)
    frame:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 8, 8)
    frame:ScaleCorners(region:GetWidth(), region:GetHeight())
    local regionStrata = region:GetFrameStrata()
    if regionStrata then
      local strata = math.min(tIndexOf(OptionsPrivate.Private.frame_strata_types, regionStrata) + 1, 9)
      frame:SetFrameStrata(OptionsPrivate.Private.frame_strata_types[strata])
      mover:SetFrameStrata(OptionsPrivate.Private.frame_strata_types[strata])
      frame:SetFrameLevel(region:GetFrameLevel() + 1)
      mover:SetFrameLevel(region:GetFrameLevel() + 1)
    end

    local db = OptionsPrivate.savedVars.db
    mover.startMoving = function()
      if WeakAurasOptionsSaved.lockPositions then
        return
      end
      OptionsPrivate.Private.CancelAnimation(region, true, true, true, true, true)
      -- The reset above re-anchors the region: the client would start the move from a rect not laid out yet, at the
      -- bottom left of the screen. GetLeft lays it out first; a region still without a rect does not move.
      if not region:GetLeft() then
        OptionsPrivate.Private.Animate("display", data.uid, "main", data.animation.main, region, false, nil, true)
        return
      end
      mover:ClearAllPoints()
      if data.regionType == "group" then
        mover:SetPoint("BOTTOMLEFT", region, mover.anchorPoint, region.blx * scale, region.bly * scale)
      else
        mover:SetPoint(mover.selfPoint, region, mover.selfPoint)
      end
      region:StartMoving()
      mover.isMoving = true
      mover.onUpdate(mover, 0)
      mover.text:Show()
      -- build list of alignment coordinates
      AlignmentLines:CreateLines(mover.moving.data)
      AlignmentLines:Show()
      HighlightFrame:Show()
    end

    mover.doneMoving = function(self, event, key)
      if event == "MODIFIER_STATE_CHANGED" then
        if key == "LCTRL" or key == "RCTRL" or key == "LSHIFT" or key == "RSHIFT" then
          AlignmentLines:CleanUpLines()
          AlignmentLines:CreateLines(mover.moving.data, mover.sizePoint)
          AlignmentLines:Show()
          HighlightFrame:Show()
        end
        return
      end

      if not mover.isMoving then
        return
      end
      region:StopMovingOrSizing()
      mover.isMoving = false
      mover.text:Hide()
      AlignmentLines:CleanUpLines()
      AlignmentLines:Hide()
      HighlightFrame:Hide()

      local align = (WeakAurasOptionsSaved.magnetAlign and not IsShiftKeyDown())
                    or (not WeakAurasOptionsSaved.magnetAlign and IsShiftKeyDown())

      local xDelta = 0
      local yDelta = 0
      if align then
        xDelta = mover.verticalDelta or 0
        yDelta = mover.horizontalDelta or 0
      end

      if data.xOffset and data.yOffset then
        local selfX, selfY = mover.selfPointIcon:GetCenter()
        local anchorX, anchorY = mover.anchorPointIcon:GetCenter()
        local dX = selfX - anchorX
        local dY = selfY - anchorY
        data.xOffset = dX / scale + xDelta / scale
        data.yOffset = dY / scale + yDelta / scale
        -- Whole units: readable X/Y in the options. An axis stuck to an alignment line keeps its exact value.
        if not (align and mover.verticalDelta) then
          data.xOffset = Round(data.xOffset)
        end
        if not (align and mover.horizontalDelta) then
          data.yOffset = Round(data.yOffset)
        end
      end
      region:ResetPosition()
      WeakAuras.Add(data)
      OptionsPrivate.Private.AddParents(data)
      WeakAuras.UpdateThumbnail(data)

      local xOff, yOff
      mover.selfPoint, mover.anchor, mover.anchorPoint, xOff, yOff = region:GetPoint(1)
      xOff = xOff or 0
      yOff = yOff or 0
      mover:ClearAllPoints()
      if data.regionType == "group" then
        mover:SetWidth((region.trx - region.blx) * scale)
        mover:SetHeight((region.try - region.bly) * scale)
        mover:SetPoint("BOTTOMLEFT", mover.anchor, mover.anchorPoint,
                       (xOff + region.blx) * scale, (yOff + region.bly) * scale)
      else
        mover:SetWidth(region:GetWidth() * scale)
        mover:SetHeight(region:GetHeight() * scale)
        mover:SetPoint(mover.selfPoint, mover.anchor, mover.anchorPoint, xOff * scale, yOff * scale)
      end
      frame.text:Hide()
      frame:SetScript("OnUpdate", nil)

      WeakAuras.FillOptions()
      OptionsPrivate.Private.Animate("display", data.uid, "main", data.animation.main,
                                     OptionsPrivate.Private.EnsureRegion(data.id), false, nil, true)
    end

    if data.parent and db.displays[data.parent] and db.displays[data.parent].regionType == "dynamicgroup" then
      mover:SetScript("OnMouseDown", nil)
      mover:SetScript("OnMouseUp", nil)
      mover:SetScript("OnEvent", nil)
      mover:SetScript("OnHide", nil)
    else
      mover:SetScript("OnMouseDown", mover.startMoving)
      mover:SetScript("OnMouseUp", mover.doneMoving)
      mover:SetScript("OnEvent", mover.doneMoving)
      mover:SetScript("OnHide", mover.doneMoving)
    end

    if region:IsResizable() then
      frame.startSizing = function(point)
        if WeakAurasOptionsSaved.lockPositions then
          return
        end
        OptionsPrivate.Private.CancelAnimation(region, true, true, true, true, true)
        -- As startMoving: a region without a rect after the reset would be sized from the bottom left of the screen.
        if not region:GetLeft() then
          OptionsPrivate.Private.Animate("display", data.uid, "main", data.animation.main, region, false, nil, true)
          return
        end
        mover.isMoving = true
        -- Offsets before any OnUpdate: doneSizing rounds only those the sizing changed.
        mover.sizingStartX, mover.sizingStartY = data.xOffset, data.yOffset
        region:StartSizing(point)
        frame.text:ClearAllPoints()
        frame.text:SetPoint("CENTER", frame, "CENTER", 0, -15)
        frame.text:Show()
        mover:ClearAllPoints()
        mover:SetAllPoints(region)
        frame:SetScript("OnUpdate", function()
          frame.text:SetText(("(%.2f, %.2f)"):format(region:GetWidth(), region:GetHeight()))
          if data.width and data.height then
            frame:SizingSetData(data, region:GetWidth(), region:GetHeight(), 0, 0, scale)
          end
          region:ResetPosition()
          WeakAuras.Add(data, true)
          frame:ScaleCorners(region:GetWidth(), region:GetHeight())
          WeakAuras.FillOptions()
        end)

        AlignmentLines:CreateLines(mover.moving.data, point)
        AlignmentLines:Show()
        HighlightFrame:Show()
        mover.sizePoint = point
      end

      frame.doneSizing = function()
        if not mover.sizePoint then
          return
        end
        mover.isMoving = false
        region:StopMovingOrSizing()

        AlignmentLines:CleanUpLines()
        AlignmentLines:Hide()
        HighlightFrame:Hide()

        local width = region:GetWidth()
        local height = region:GetHeight()

        local align = (WeakAurasOptionsSaved.magnetAlign and not IsShiftKeyDown())
                      or (not WeakAurasOptionsSaved.magnetAlign and IsShiftKeyDown())

        local deltaX = 0
        local deltaY = 0
        if align then
          deltaX = mover.verticalDelta or 0
          deltaY = mover.horizontalDelta or 0
        end

        local xOffset, yOffset = mover.sizingStartX, mover.sizingStartY
        frame:SizingSetData(data, width, height, deltaX, deltaY, scale)
        -- Whole units, as at the drop of a move, on the axes the dragged point moves. An axis stuck to an
        -- alignment line keeps its exact values. Offsets left untouched by the sizing (child of a dynamic group)
        -- stay as they are.
        local point = mover.sizePoint
        if (point:find("LEFT") or point:find("RIGHT")) and not (align and mover.verticalDelta) then
          data.width = Round(data.width)
          if data.xOffset ~= xOffset then
            data.xOffset = Round(data.xOffset)
          end
        end
        if (point:find("TOP") or point:find("BOTTOM")) and not (align and mover.horizontalDelta) then
          data.height = Round(data.height)
          if data.yOffset ~= yOffset then
            data.yOffset = Round(data.yOffset)
          end
        end

        region:ResetPosition()
        WeakAuras.Add(data, true)
        OptionsPrivate.Private.AddParents(data)
        WeakAuras.UpdateThumbnail(data)

        frame:ScaleCorners(region:GetWidth(), region:GetHeight())
        local xOff, yOff
        mover.selfPoint, mover.anchor, mover.anchorPoint, xOff, yOff = region:GetPoint(1)
        xOff = xOff or 0
        yOff = yOff or 0
        mover:ClearAllPoints()
        if data.regionType == "group" then
          mover:SetWidth((region.trx - region.blx) * scale)
          mover:SetHeight((region.try - region.bly) * scale)
          mover:SetPoint("BOTTOMLEFT", mover.anchor, mover.anchorPoint,
                         (xOff + region.blx) * scale,
                         (yOff + region.bly) * scale)
        else
          mover:SetWidth(region:GetWidth() * scale)
          mover:SetHeight(region:GetHeight() * scale)
          mover:SetPoint(mover.selfPoint, mover.anchor, mover.anchorPoint, xOff * scale, yOff * scale)
        end
        frame.text:Hide()
        frame:SetScript("OnUpdate", nil)
        WeakAuras.FillOptions()
        OptionsPrivate.Private.Animate("display", data.uid, "main", data.animation.main,
                                       OptionsPrivate.Private.EnsureRegion(data.id), false, nil, true)
        mover.sizePoint = nil
      end

      frame.bottomleft:SetScript("OnMouseDown", function() frame.startSizing("BOTTOMLEFT") end)
      frame.bottomleft:SetScript("OnMouseUp", function() frame.doneSizing("BOTTOMLEFT") end)
      frame.bottomleft:SetScript("OnEnter", frame.bottomleft.Highlight)
      frame.bottomleft:SetScript("OnLeave", frame.bottomleft.Clear)
      frame.bottom:SetScript("OnMouseDown", function() frame.startSizing("BOTTOM") end)
      frame.bottom:SetScript("OnMouseUp", function() frame.doneSizing("BOTTOM") end)
      frame.bottom:SetScript("OnEnter", frame.bottom.Highlight)
      frame.bottom:SetScript("OnLeave", frame.bottom.Clear)
      frame.bottomright:SetScript("OnMouseDown", function() frame.startSizing("BOTTOMRIGHT") end)
      frame.bottomright:SetScript("OnMouseUp", function() frame.doneSizing("BOTTOMRIGHT") end)
      frame.bottomright:SetScript("OnEnter", frame.bottomright.Highlight)
      frame.bottomright:SetScript("OnLeave", frame.bottomright.Clear)
      frame.right:SetScript("OnMouseDown", function() frame.startSizing("RIGHT") end)
      frame.right:SetScript("OnMouseUp", function() frame.doneSizing("RIGHT") end)
      frame.right:SetScript("OnEnter", frame.right.Highlight)
      frame.right:SetScript("OnLeave", frame.right.Clear)
      frame.topright:SetScript("OnMouseDown", function() frame.startSizing("TOPRIGHT") end)
      frame.topright:SetScript("OnMouseUp", function() frame.doneSizing("TOPRIGHT") end)
      frame.topright:SetScript("OnEnter", frame.topright.Highlight)
      frame.topright:SetScript("OnLeave", frame.topright.Clear)
      frame.top:SetScript("OnMouseDown", function() frame.startSizing("TOP") end)
      frame.top:SetScript("OnMouseUp", function() frame.doneSizing("TOP") end)
      frame.top:SetScript("OnEnter", frame.top.Highlight)
      frame.top:SetScript("OnLeave", frame.top.Clear)
      frame.topleft:SetScript("OnMouseDown", function() frame.startSizing("TOPLEFT") end)
      frame.topleft:SetScript("OnMouseUp", function() frame.doneSizing("TOPLEFT") end)
      frame.topleft:SetScript("OnEnter", frame.topleft.Highlight)
      frame.topleft:SetScript("OnLeave", frame.topleft.Clear)
      frame.left:SetScript("OnMouseDown", function() frame.startSizing("LEFT") end)
      frame.left:SetScript("OnMouseUp", function() frame.doneSizing("LEFT") end)
      frame.left:SetScript("OnEnter", frame.left.Highlight)
      frame.left:SetScript("OnLeave", frame.left.Clear)

      frame.bottomleft:Show()
      frame.bottom:Show()
      frame.bottomright:Show()
      frame.right:Show()
      frame.topright:Show()
      frame.top:Show()
      frame.topleft:Show()
      frame.left:Show()
    else
      frame.bottomleft:Hide()
      frame.bottom:Hide()
      frame.bottomright:Hide()
      frame.right:Hide()
      frame.topright:Hide()
      frame.top:Hide()
      frame.topleft:Hide()
      frame.left:Hide()
    end
    frame:Show()
  end

  mover.onUpdate = function(self, elaps)
    if not IsShiftKeyDown() then
      self.goalAlpha = 1
    else
      self.goalAlpha = 0.1
    end

    if self.currentAlpha ~= self.goalAlpha then
      self.currentAlpha = self.currentAlpha or self:GetAlpha()
      local newAlpha = (self.currentAlpha < self.goalAlpha) and self.currentAlpha + (elaps * 4) or self.currentAlpha - (elaps * 4)
      newAlpha = (newAlpha > 1 and 1) or (newAlpha < 0.1 and 0.1) or newAlpha
      mover:SetAlpha(newAlpha)
      frame:SetAlpha(newAlpha)
      self.currentAlpha = newAlpha
    end

    local db = OptionsPrivate.savedVars.db
    local region = self.moving.region
    local data = self.moving.data
    if not self.isMoving then
      local ok, selfPoint, anchor, anchorPoint = pcall(region.GetPoint, region, 1)
      if not ok then
        self:Hide()
        return
      end
      self.selfPoint, self.anchor, self.anchorPoint = selfPoint, anchor, anchorPoint
    end
    self.selfPointIcon:ClearAllPoints()
    self.selfPointIcon:SetPoint("CENTER", region, self.selfPoint)
    local selfX, selfY = self.selfPointIcon:GetCenter()
    selfX, selfY = selfX or 0, selfY or 0
    self.anchorPointIcon:ClearAllPoints()
    self.anchorPointIcon:SetPoint("CENTER", self.anchor, self.anchorPoint)
    local anchorX, anchorY = self.anchorPointIcon:GetCenter()
    anchorX, anchorY = anchorX or 0, anchorY or 0
    if data.parent and db.displays[data.parent] and db.displays[data.parent].regionType == "dynamicgroup" then
      self.selfPointIcon:Hide()
      self.anchorPointIcon:Hide()
    else
      self.selfPointIcon:Show()
      self.anchorPointIcon:Show()
    end

    local dX = selfX - anchorX
    local dY = selfY - anchorY
    local distance = sqrt(dX^2 + dY^2)
    local angle = atan2(dY, dX)

    local numInterim = floor(distance/40)

    for _, texture in pairs(self.interims) do
      texture:Hide()
    end
    for i = 1, numInterim  do
      local x = (distance - (i * 40)) * cos(angle)
      local y = (distance - (i * 40)) * sin(angle)
      self.interims[i] = EnsureTexture(self, self.interims[i])
      self.interims[i]:ClearAllPoints()
      self.interims[i]:SetPoint("CENTER", self.anchorPointIcon, "CENTER", x, y)
      self.interims[i]:Show()
    end

    frame.arrowTexture:Hide()
    frame.offscreenText:Hide()

    -- Check if the center is offscreen
    -- How many pixels of the aura need to be visible
    local margin = 30
    local x, y = mover:GetCenter()
    if x and y then
      if mover:GetRight() < margin or mover:GetLeft() + margin > GetScreenWidth() or mover:GetTop() < 20 or mover:GetBottom() + margin > GetScreenHeight() then
        local arrowX, arrowY = frame.arrowTexture:GetCenter()
        local arrowAngle = atan2(y - arrowY, x - arrowX)
        frame.offscreenText:Show()
        frame.arrowTexture:Show()
        frame.arrowTexture:SetRotation( (arrowAngle - 90) / 180 * math.pi)
      end
    end

    local regionScale = self.moving.region:GetScale()
    self.text:SetText(("(%.2f, %.2f)"):format(dX*1/regionScale, dY*1/regionScale))
    local midX = (distance / 2) * cos(angle)
    local midY = (distance / 2) * sin(angle)
    self.text:SetPoint("CENTER", self.anchorPointIcon, "CENTER", midX, midY)
    local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
    if (midX > 0 and (self.text:GetRight() or 0) > (left or 0))
    or (midX < 0 and (self.text:GetLeft() or 0) < (right or 0))
    then
      if midY > 0 and (self.text:GetTop() or 0) > (top or 0) then
        midY = midY - ((self.text:GetTop() or 0) - (bottom or 0))
      elseif midY < 0 and (self.text:GetBottom() or 0) < (top or 0) then
        midY = midY + ((top or 0) - (self.text:GetBottom() or 0))
      end
    end
    self.text:SetPoint("CENTER", self.anchorPointIcon, "CENTER", midX, midY)
    if self.isMoving then
      AlignmentLines:ShowLinesFor(IsControlKeyDown(), region, mover.sizePoint)
    end
  end

  frame.OptionsOpened = function()
    mover:Show()
    mover:RegisterEvent("MODIFIER_STATE_CHANGED")
    mover:SetScript("OnUpdate", mover.onUpdate)
    AlignmentLines:Show()
    HighlightFrame:Show()
  end

  frame.OptionsClosed = function()
    if frame.doneSizing then
      frame.doneSizing()
    end
    if mover.doneMoving then
      mover.doneMoving()
    end
    mover:UnregisterEvent("MODIFIER_STATE_CHANGED")
    mover:SetScript("OnUpdate", nil)
    mover:Hide()
    AlignmentLines:Hide()
    HighlightFrame:Hide()
  end

  -- Absent where a test loads this file alone.
  if OptionsPrivate.AnchorLinker then
    OptionsPrivate.AnchorLinker(frame, mover, parent)
  end
  return frame, mover
end

function OptionsPrivate.MoverSizer(parent)
  if not moversizer or not mover then
    moversizer, mover = ConstructMoverSizer(parent)
    optionsFrame = parent
    parent:HookScript("OnShow", OptionsPrivate.UpdatePlacementGrid)
    parent:HookScript("OnHide", OptionsPrivate.UpdatePlacementGrid)
    EventRegistry:RegisterCallback("EditMode.Enter", OptionsPrivate.UpdatePlacementGrid, PlacementGrid)
    EventRegistry:RegisterCallback("EditMode.Exit", OptionsPrivate.UpdatePlacementGrid, PlacementGrid)
  end
  return moversizer, mover
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Links between an aura and a frame: an aura anchored by one of its 9 points to one of the 9 points of another aura,
-- group or frame of the game, stored as anchorFrameType SELECTFRAME. The game then moves the aura with its target.
-- Functions on rectangles and aura data, and the anchor menu shared by the Edit Mode and the /wa mover.

local AnchorLinks = {}
Private.AnchorLinks = AnchorLinks
local Style = Private.Style

-- Fractions of the width and the height of each point, from the bottom left corner.
AnchorLinks.points = {
  TOPLEFT = { 0, 1 }, TOP = { 0.5, 1 }, TOPRIGHT = { 1, 1 },
  LEFT = { 0, 0.5 }, CENTER = { 0.5, 0.5 }, RIGHT = { 1, 0.5 },
  BOTTOMLEFT = { 0, 0 }, BOTTOM = { 0.5, 0 }, BOTTOMRIGHT = { 1, 0 },
}

--- Position of the point on the rectangle left, bottom, width, height.
function AnchorLinks.PointPosition(left, bottom, width, height, point)
  local fraction = AnchorLinks.points[point] or AnchorLinks.points.CENTER
  return left + width * fraction[1], bottom + height * fraction[2]
end

-- Rows of the anchor menu: the aura sits on that side of its target, or on that side with the named edges flush.
AnchorLinks.sides = {
  { label = "Anchor to Left", selfPoint = "RIGHT", anchorPoint = "LEFT" },
  { label = "Anchor to Right", selfPoint = "LEFT", anchorPoint = "RIGHT" },
  { label = "Anchor to Top", selfPoint = "BOTTOM", anchorPoint = "TOP" },
  { label = "Anchor to Bottom", selfPoint = "TOP", anchorPoint = "BOTTOM" },
  { label = "Anchor to Top Left", selfPoint = "BOTTOMLEFT", anchorPoint = "TOPLEFT" },
  { label = "Anchor to Top Right", selfPoint = "BOTTOMRIGHT", anchorPoint = "TOPRIGHT" },
  { label = "Anchor to Bottom Left", selfPoint = "TOPLEFT", anchorPoint = "BOTTOMLEFT" },
  { label = "Anchor to Bottom Right", selfPoint = "TOPRIGHT", anchorPoint = "BOTTOMRIGHT" },
}

--- selfPoint and anchorPoint of the side. A group keeps its selfPoint: it places its children from it.
function AnchorLinks.SidePoints(data, side)
  if data.regionType == "group" or data.regionType == "dynamicgroup" then
    return data.selfPoint or "CENTER", side.anchorPoint
  end
  return side.selfPoint, side.anchorPoint
end

--- Offsets that keep the source where it is once its selfPoint is anchored to the anchorPoint of the target. Each
--- rectangle { left, bottom, width, height } is in the units of its frame, scale its effective scale; the offsets
--- are in the units of the source, as SetPoint takes them.
function AnchorLinks.Offsets(source, sourceScale, selfPoint, target, targetScale, anchorPoint)
  local sourceX, sourceY = AnchorLinks.PointPosition(source[1], source[2], source[3], source[4], selfPoint)
  local targetX, targetY = AnchorLinks.PointPosition(target[1], target[2], target[3], target[4], anchorPoint)
  return (sourceX * sourceScale - targetX * targetScale) / sourceScale,
    (sourceY * sourceScale - targetY * targetScale) / sourceScale
end

--- The aura id the aura is linked to, nil when it is not linked to an aura.
function AnchorLinks.TargetAura(data)
  local frame = data and data.anchorFrameType == "SELECTFRAME" and data.anchorFrameFrame
  if type(frame) == "string" and frame:sub(1, 10) == "WeakAuras:" then
    return frame:sub(11)
  end
end

--- Whether the position of the aura targetId depends on the aura sourceId: through its links, its groups, or as one
--- of its children. Linking sourceId to targetId would then make a loop.
function AnchorLinks.DependsOn(targetId, sourceId)
  local visited = {}
  local function Depends(id)
    if id == sourceId then
      return true
    end
    if visited[id] then
      return false
    end
    visited[id] = true
    local data = WeakAuras.GetData(id)
    if not data then
      return false
    end
    local linked = AnchorLinks.TargetAura(data)
    return (linked and Depends(linked)) or (data.parent and Depends(data.parent)) or false
  end
  return Depends(targetId)
end

--- Anchors the aura by selfPoint to the anchorPoint of the frame named frameName, by position only: the aura keeps
--- its own visibility and scale.
function AnchorLinks.Link(data, frameName, selfPoint, anchorPoint, xOffset, yOffset)
  data.anchorFrameType = "SELECTFRAME"
  data.anchorFrameFrame = frameName
  data.anchorFrameParent = false
  data.selfPoint, data.anchorPoint = selfPoint, anchorPoint
  data.xOffset, data.yOffset = xOffset, yOffset
end

--- Anchors the aura back to its group, or to the screen (WeakAurasFrame) at the top level, at the given offsets.
function AnchorLinks.Unlink(data, xOffset, yOffset)
  data.anchorFrameType = "SCREEN"
  data.anchorFrameFrame = nil
  data.anchorFrameParent = nil
  if data.parent then
    data.anchorPoint = "CENTER"
  end
  data.xOffset, data.yOffset = xOffset, yOffset
end

local function Readable(...)
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    if value == nil or (issecretvalue and issecretvalue(value)) then
      return false
    end
  end
  return true
end

--- left, bottom, width, height in the units of the frame, and its effective scale; nil when the game refuses them.
function AnchorLinks.FrameRect(frame)
  local ok, left, bottom, width, height = pcall(frame.GetRect, frame)
  if not ok or not Readable(left, bottom, width, height) then
    return
  end
  local okScale, scale = pcall(frame.GetEffectiveScale, frame)
  if not okScale or not Readable(scale) then
    return
  end
  return { left, bottom, width, height }, scale
end

--- The rectangle and the scale of the aura once linked or unlinked: its parent is then its group or WeakAurasFrame,
--- not the frame it may be parented to now, so its rectangle is converted to that scale. Then that parent.
function AnchorLinks.SourceRect(region, data)
  local rect, scale = AnchorLinks.FrameRect(region)
  local reference = data.parent and Private.regions[data.parent] and Private.regions[data.parent].region
    or WeakAurasFrame
  local okScale, referenceScale = pcall(reference.GetEffectiveScale, reference)
  if not rect or not okScale or not Readable(referenceScale) then
    return
  end
  local future = referenceScale * region:GetScale()
  local factor = scale / future
  return { rect[1] * factor, rect[2] * factor, rect[3] * factor, rect[4] * factor }, future, reference
end

--- Links the aura, shown by region, to the frame named frameName on the side, in place. false when the game refuses
--- the rectangles: nothing changed.
function AnchorLinks.LinkInPlace(data, region, frame, frameName, side)
  local source, sourceScale = AnchorLinks.SourceRect(region, data)
  local target, targetScale = AnchorLinks.FrameRect(frame)
  if not (source and target) then
    return false
  end
  Private.TimeMachine:Watch(data)
  local selfPoint, anchorPoint = AnchorLinks.SidePoints(data, side)
  local xOffset, yOffset = AnchorLinks.Offsets(source, sourceScale, selfPoint, target, targetScale, anchorPoint)
  AnchorLinks.Link(data, frameName, selfPoint, anchorPoint, xOffset, yOffset)
  return true
end

--- Unlinks the aura in place: back to its group, or to the screen on the point of its target. false when refused.
function AnchorLinks.UnlinkInPlace(data, region)
  local source, sourceScale, reference = AnchorLinks.SourceRect(region, data)
  local target, targetScale
  if source then
    target, targetScale = AnchorLinks.FrameRect(reference)
  end
  if not target then
    return false
  end
  Private.TimeMachine:Watch(data)
  local anchorPoint = data.parent and "CENTER" or data.anchorPoint
  local xOffset, yOffset = AnchorLinks.Offsets(source, sourceScale, data.selfPoint, target, targetScale, anchorPoint)
  data.anchorPoint = anchorPoint
  AnchorLinks.Unlink(data, xOffset, yOffset)
  return true
end

local menu
local menuRowHeight, menuWidth = 24, 160

local function MenuRow(index)
  local row = menu.rows[index]
  if not row then
    row = CreateFrame("Button", nil, menu.panel)
    row:SetSize(menuWidth - 2, menuRowHeight)
    row:SetPoint("TOPLEFT", menu.panel, "TOPLEFT", 1, -1 - (index - 1) * menuRowHeight)
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(Style.Color("raised"))
    row.label = Style.NewText(row, "text", "s")
    row.label:SetPoint("LEFT", 10, 0)
    menu.rows[index] = row
  end
  return row
end

--- Shows a menu at the cursor, one row per choice: { text, color, onPick }, color a name of Style.colors. A click
--- outside the menu closes it, picking nothing.
function AnchorLinks.ShowChoices(choices)
  if not menu then
    menu = CreateFrame("Frame", nil, UIParent)
    menu:SetAllPoints(UIParent)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:EnableMouse(true)
    menu:SetScript("OnMouseDown", menu.Hide)
    menu.panel = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    Style.Fill(menu.panel, "panelBackground", "border")
    menu.panel:SetWidth(menuWidth)
    menu.panel:SetClampedToScreen(true)
    menu.panel:EnableMouse(true)
    menu.rows = {}
  end
  local count = #choices
  for index = 1, math.max(count, #menu.rows) do
    local row = MenuRow(index)
    local choice = choices[index]
    row:SetShown(choice ~= nil)
    if choice then
      row.label:SetText(choice.text)
      row.label:SetTextColor(Style.Color(choice.color or "text"))
      row:SetScript("OnClick", function()
        menu:Hide()
        choice.onPick()
      end)
    end
  end
  menu.panel:SetHeight(count * menuRowHeight + 2)
  local x, y = GetCursorPosition()
  local scale = menu.panel:GetEffectiveScale()
  menu.panel:ClearAllPoints()
  menu.panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
  menu:Show()
end

--- Shows the anchor menu at the cursor: one row per side, then "Remove Anchor" in red when removable. onPick gets
--- the side picked, nil for the removal.
function AnchorLinks.ShowMenu(removable, onPick)
  local L = WeakAuras.L
  local choices = {}
  for _, side in ipairs(AnchorLinks.sides) do
    choices[#choices + 1] = { text = L[side.label], onPick = function() onPick(side) end }
  end
  if removable then
    choices[#choices + 1] = { text = L["Remove Anchor"], color = "error", onPick = function() onPick(nil) end }
  end
  AnchorLinks.ShowChoices(choices)
end

--- Whether the anchor menu is open.
function AnchorLinks.MenuShown()
  return menu ~= nil and menu:IsShown()
end

--- Marker of a link: a frost frame around the followed frame, a dot on its anchor point and a dot on the point of
--- the aura that follows it.
function AnchorLinks.CreateMarker(parent)
  local marker = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  marker:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
  marker:SetBackdropBorderColor(Style.Color("link"))
  marker.targetDot = marker:CreateTexture(nil, "OVERLAY")
  marker.sourceDot = marker:CreateTexture(nil, "OVERLAY")
  for _, dot in ipairs({ marker.targetDot, marker.sourceDot }) do
    dot:SetSize(8, 8)
    dot:SetColorTexture(Style.Color("linkSelected"))
  end
  marker:Hide()
  return marker
end

--- Shows the marker: border around frame, dots on the anchor point of anchorFrame and the self point of source.
function AnchorLinks.ShowMarker(marker, source, frame, anchorFrame, data)
  marker:ClearAllPoints()
  marker:SetAllPoints(frame)
  marker.targetDot:ClearAllPoints()
  marker.targetDot:SetPoint("CENTER", anchorFrame, data.anchorPoint or "CENTER")
  marker.sourceDot:ClearAllPoints()
  marker.sourceDot:SetPoint("CENTER", source, data.selfPoint or "CENTER")
  marker:Show()
end

--- Closes the anchor menu without a pick, when the Edit Mode or the options close.
function AnchorLinks.HideMenu()
  if menu then
    menu:Hide()
  end
end

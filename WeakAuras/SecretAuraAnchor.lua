-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Anchoring of native aura containers, shared by the display (BlizzardAuraDisplay) and the modern
-- group flow (SecretAuraFlow*). A growth is an object defined by its two signs; every anchor point,
-- offset and layout setting of a growth is computed from them. Frames are only touched when they
-- are not locked (protected in combat), and a refused anchor never raises.
-- This module reads nothing from the display, so it loads first.

local Anchor = {}
Private.AuraAnchor = Anchor

local UNITFRAME, NAMEPLATE = "UNITFRAME", "NAMEPLATE"

-----------------------------------------------------------------------------------------------
-- Growths

local Growth = {}
Growth.__index = Growth

local function Horizontal(sign) return sign > 0 and "LEFT" or "RIGHT" end
local function Vertical(sign) return sign < 0 and "TOP" or "BOTTOM" end

local function WordOf(point, first, second)
  point = point or ""
  if point:find(first, 1, true) then return first end
  if point:find(second, 1, true) then return second end
  return ""
end

local function NewGrowth(key, signX, signY)
  local growth = setmetatable({ key = key, signX = signX, signY = signY }, Growth)
  growth.visible = growth
  return growth
end

function Growth:IsHorizontal() return self.signX ~= 0 end

function Growth:StartPoint()
  if self:IsHorizontal() then return "TOP" .. Horizontal(self.signX) end
  return Vertical(self.signY) .. "LEFT"
end

function Growth:FrontPoint()
  if self:IsHorizontal() then return "TOP" .. Horizontal(0 - self.signX) end
  return Vertical(0 - self.signY) .. "LEFT"
end

-- Point of an element whose free axis follows selfPoint; the growth axis takes the start or front side.
function Growth:Aligned(selfPoint, atFront)
  local point = atFront and self:FrontPoint() or self:StartPoint()
  if self:IsHorizontal() then
    return WordOf(selfPoint, "TOP", "BOTTOM") .. WordOf(point, "LEFT", "RIGHT")
  end
  return WordOf(point, "TOP", "BOTTOM") .. WordOf(selfPoint, "LEFT", "RIGHT")
end

function Growth:Overlap() return 0 - self.signX, 0 - self.signY end

function Growth:Step(sizeX, sizeY) return self.signX * sizeX, self.signY * (sizeY or sizeX) end

function Growth:Axis()
  local axes = AnchorUtil.FlowLayoutAxis
  return self:IsHorizontal() and axes.Horizontal or axes.Vertical
end

function Growth:Directions()
  local directions = AnchorUtil.FlowDirection
  return self.signX < 0 and directions.Left or directions.Right, self.signY > 0 and directions.Up or directions.Down
end

function Growth:GridType()
  local head = self.signX > 0 and "R" or self.signX < 0 and "L" or self.signY < 0 and "D" or "U"
  return head .. (self:IsHorizontal() and "D" or "R")
end

function Growth:Pin() return self end

local RIGHT, LEFT = NewGrowth("RIGHT", 1, 0), NewGrowth("LEFT", -1, 0)
local DOWN, UP = NewGrowth("DOWN", 0, -1), NewGrowth("UP", 0, 1)

-- A centered growth is drawn as its visible side, plus a shadow growing the other way.
local function NewCentered(key, visible, shadow, centerPoint, pins)
  local growth = setmetatable({ key = key, visible = visible, shadow = shadow, centerPoint = centerPoint, pins = pins },
    { __index = visible })
  function growth:Pin(selfPoint)
    selfPoint = selfPoint or ""
    if selfPoint:find(pins[1], 1, true) then return visible end
    if selfPoint:find(pins[2], 1, true) then return shadow end
    return self
  end
  return growth
end

Anchor.Growths = {
  RIGHT = RIGHT, LEFT = LEFT, DOWN = DOWN, UP = UP,
  CENTER_HORIZONTAL = NewCentered("CENTER_HORIZONTAL", RIGHT, LEFT, "TOP", { "LEFT", "RIGHT" }),
  CENTER_VERTICAL = NewCentered("CENTER_VERTICAL", DOWN, UP, "LEFT", { "TOP", "BOTTOM" }),
}

function Anchor.GrowthFor(key) return Anchor.Growths[key] or RIGHT end

-----------------------------------------------------------------------------------------------
-- Frames

function Anchor.Find(mode, unit, droppedUnit)
  local hostFrame
  if mode == UNITFRAME then
    hostFrame = WeakAuras.GetUnitFrame(unit)
  elseif mode == NAMEPLATE and not (droppedUnit ~= nil and unit == droppedUnit) then
    hostFrame = C_NamePlate.GetNamePlateForUnit(unit)
  end
  if hostFrame and hostFrame.IsForbidden and hostFrame:IsForbidden() then return nil end
  return hostFrame
end

function Anchor.UnitAnchor(mode, unit) return Anchor.Find(mode, unit) end

function Anchor.LocateAnchor(unit, unitFrameMap, plateMap, droppedUnit)
  if not unit then return nil end
  return Anchor.Find(unitFrameMap and UNITFRAME or plateMap and NAMEPLATE or nil, unit, droppedUnit)
end

function Anchor.Locked(hostFrame)
  return (InCombatLockdown() and hostFrame:IsProtected()) and true or false
end

-- "locked" (frame untouched), "ok", "fallback" (anchored on region) or "failed".
function Anchor.Attach(hostFrame, point, relativeTo, relativePoint, x, y, childRegion, fallbackPoint)
  if Anchor.Locked(hostFrame) then return "locked" end
  x, y = x or 0, y or 0
  hostFrame:ClearAllPoints()
  if pcall(hostFrame.SetPoint, hostFrame, point, relativeTo, relativePoint, x, y) then return "ok" end
  if not childRegion then return "failed" end
  hostFrame:ClearAllPoints()
  if fallbackPoint then
    pcall(hostFrame.SetPoint, hostFrame, fallbackPoint, childRegion, fallbackPoint, 0, 0)
  else
    pcall(hostFrame.SetPoint, hostFrame, point, childRegion, relativePoint, x, y)
  end
  return "fallback"
end

-- Puts frame right after anchorFrame, in the direction of growth.
function Anchor.Behind(hostFrame, growth, anchorFrame, sizeX, sizeY, childRegion)
  local x, y = growth:Step(sizeX, sizeY)
  return Anchor.Attach(hostFrame, growth:FrontPoint(), anchorFrame, growth:StartPoint(), x, y, childRegion, "TOPLEFT") == "ok"
end

-----------------------------------------------------------------------------------------------
-- Memory of the last anchor of a container

local remembered = setmetatable({}, { __mode = "k" })

function Anchor.Holds(hostFrame, point, relativeTo, relativePoint, x, y)
  local last = remembered[hostFrame]
  return last ~= nil and last[1] == point and last[2] == relativeTo and last[3] == relativePoint
    and last[4] == x and last[5] == y
end

-- An anchor set in combat may have been blocked, so only anchors set out of combat are kept.
function Anchor.Remember(hostFrame, point, relativeTo, relativePoint, x, y)
  remembered[hostFrame] = not InCombatLockdown() and { point, relativeTo, relativePoint, x, y } or nil
end

function Anchor.Forget(hostFrame) remembered[hostFrame] = nil end

-----------------------------------------------------------------------------------------------
-- Parent and unit of a container

-- holder carries boundUnit. matchLevels copies the strata and level of the new parent, when readable.
function Anchor.Rebind(holder, auraContainer, unit, parentGroup, matchLevels)
  local reparent = auraContainer:GetParent() ~= parentGroup
  if reparent and Anchor.Locked(auraContainer) then return false end
  if holder.boundUnit ~= unit or reparent then
    auraContainer:SetEnabled(false)
    if unit then auraContainer:SetUnit(unit) end
    holder.boundUnit = unit
    if reparent and not pcall(auraContainer.SetParent, auraContainer, parentGroup) then return false end
  end
  if matchLevels then
    local strata, level = parentGroup:GetFrameStrata(), parentGroup:GetFrameLevel()
    if not issecretvalue(strata) then auraContainer:SetFrameStrata(strata) end
    if not issecretvalue(level) then auraContainer:SetFrameLevel(level + 1) end
  end
  return true
end

function Anchor.GroupPosition(groupData, defaultSelf, defaultAnchor)
  return groupData.selfPoint or defaultSelf or "CENTER", groupData.anchorPoint or defaultAnchor or "CENTER",
    tonumber(groupData.xOffset) or 0, tonumber(groupData.yOffset) or 0
end

local hiddenParent

function Anchor.Retire(hostFrame)
  if not hostFrame then return end
  if not hiddenParent then
    hiddenParent = CreateFrame("Frame")
    hiddenParent:Hide()
  end
  if hostFrame.SetEnabled then hostFrame:SetEnabled(false) end
  hostFrame:Hide()
  hostFrame:ClearAllPoints()
  Anchor.Forget(hostFrame)
  hostFrame:SetParent(hiddenParent)
end

if not WeakAuras.IsLibsOK() then return end
---@class Private
local Private = select(2, ...)

local L = WeakAuras.L

local genericTexture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White"

local atlasByClass = {
  magic = "RaidFrame-Icon-DebuffMagic",
  curse = "RaidFrame-Icon-DebuffCurse",
  disease = "RaidFrame-Icon-DebuffDisease",
  poison = "RaidFrame-Icon-DebuffPoison",
  bleed = "RaidFrame-Icon-DebuffBleed",
}

local function default(parentType)
  return {
    dispelIconVisible = true,
    anchor_mode = "point",
    anchor_area = parentType == "aurabar" and "bar" or "ALL",
    self_point = "TOPRIGHT",
    anchor_point = "TOPRIGHT",
    width = 16,
    height = 16,
    xOffset = 0,
    yOffset = 0,
  }
end

local properties = {
  dispelIconVisible = {
    display = L["Visibility"],
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true,
  },
}

local methods = {}

function methods:SetVisible(visible)
  if visible then
    self:Show()
  else
    self:Hide()
  end
end

function methods:ShowTinted(r, g, b, a)
  self.texture:SetTexCoord(0, 1, 0, 1)
  self.texture:SetTexture(genericTexture)
  self.texture:SetVertexColor(r, g, b, a)
  self.texture:Show()
end

function methods:Update(state)
  local texture = self.texture
  local debuffClass = Private.ReadableDebuffClass(state)
  if debuffClass then
    local atlas = atlasByClass[debuffClass]
    local color = Private.dispelColors[debuffClass]
    if atlas and C_Texture and C_Texture.GetAtlasInfo(atlas) then
      texture:SetAtlas(atlas)
      texture:SetVertexColor(1, 1, 1, 1)
      texture:Show()
    elseif color then
      self:ShowTinted(color[1], color[2], color[3], 1)
    else
      texture:Hide()
    end
    return
  end
  if state and state.unit and state.auraInstanceID and self.dispelCurve then
    local ok, r, g, b, a = pcall(Private.ReadDispelColor, state.unit, state.auraInstanceID, self.dispelCurve)
    if ok then
      self:ShowTinted(r, g, b, a)
      return
    end
  end
  texture:Hide()
end

local function create()
  local region = CreateFrame("Frame", nil, UIParent)
  for name, method in pairs(methods) do
    region[name] = method
  end
  region.texture = region:CreateTexture(nil, "OVERLAY")
  region.texture:SetAllPoints(region)
  return region
end

local function onAcquire(subRegion)
  subRegion:Show()
end

local function onRelease(subRegion)
  subRegion:Hide()
end

local function modify(parent, region, parentData, data, first)
  region:SetParent(parent)
  region.dispelCurve = region.dispelCurve or Private.CreateDispelCurve({1, 1, 1, 0})

  local pointMode = data.anchor_mode == "point"
  region.Anchor = function()
    region:ClearAllPoints()
    parent:AnchorSubRegion(region, data.anchor_mode,
                           pointMode and data.anchor_point or data.anchor_area,
                           pointMode and data.self_point or nil,
                           data.xOffset, data.yOffset)
  end

  if pointMode then
    region:SetSize(data.width or 16, data.height or 16)
  end

  region:SetVisible(data.dispelIconVisible)
  parent.subRegionEvents:AddSubscriber("Update", region)
  region:Update(parent.state)
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "text"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("subdispelicon", L["Dispel Type Icon"], supports, create, modify, onAcquire,
                                onRelease, default, nil, properties)

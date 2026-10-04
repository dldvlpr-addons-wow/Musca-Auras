if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local SUBSCRIBED_EVENTS = {"Update", "UpdateProgress"}

local function getDefaults(parentType)
  return {
    dispelVisible = true,
    dispelBorderSize = 2,
    dispelBorderOffset = 0,
    anchor_mode = "area",
    anchor_area = parentType == "aurabar" and "bar" or "ALL",
    anchor_point = "CENTER",
    self_point = "CENTER",
    width = 32,
    height = 32,
    xOffset = 0,
    yOffset = 0,
  }
end

local function isSupported(parentType)
  return parentType == "icon" or parentType == "aurabar" or parentType == "progresstexture"
end

local function createRegion()
  local region = CreateFrame("Frame", nil, UIParent)
  region.dispelEdges = Private.DispelTypeDisplay.CreateEdges(region)

  function region:SetVisible(isVisible)
    self.visible = isVisible
    self:SetShown(isVisible)
    if self.Update then self:Update() end
  end

  return region
end

local function modifyRegion(parent, region, parentData, data)
  region:SetParent(parent)
  region.parent = parent

  function region.Anchor()
    local mode = data.anchor_mode or "area"
    local isArea = mode == "area"
    region:ClearAllPoints()
    if mode == "point" then
      region:SetSize(data.width or 32, data.height or 32)
    end
    local scale = isArea and 0.5 or 1
    local target = isArea and data.anchor_area or data.anchor_point
    local ownPoint = mode == "point" and data.self_point or nil
    parent:AnchorSubRegion(region, mode, target, ownPoint,
      (data.xOffset or 0) * scale, (data.yOffset or 0) * scale)
    Private.DispelTypeDisplay.Layout(region.dispelEdges, region, data)
  end
  region:Anchor()

  region.Update = function()
    Private.CDMAuraProgress.UpdateIndicator(parent, region, data)
  end
  region.UpdateProgress = region.Update
  for _, eventName in ipairs(SUBSCRIBED_EVENTS) do
    parent.subRegionEvents:AddSubscriber(eventName, region)
  end

  region:SetVisible(data.dispelVisible ~= false)
end

local function releaseRegion(region)
  local parent = region.parent
  if parent then
    for _, eventName in ipairs(SUBSCRIBED_EVENTS) do
      parent.subRegionEvents:RemoveSubscriber(eventName, region)
    end
  end
  Private.DispelTypeDisplay.Hide(region.dispelEdges)
  region:Hide()
end

local function showRegion(region)
  region:Show()
end

local properties = {
  dispelVisible = {
    display = "Visibility",
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true,
  },
}

WeakAuras.RegisterSubRegionType("subcdmdispelborder", "Dispel Type Border", isSupported,
  createRegion, modifyRegion, showRegion, releaseRegion, getDefaults, nil, properties)

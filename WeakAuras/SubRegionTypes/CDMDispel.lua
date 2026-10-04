if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local SUBSCRIBED_EVENTS = {"Update", "UpdateProgress"}

local function getDefaults()
  return {
    dispelVisible = true,
    dispelStyle = "Icon",
    anchor_mode = "point",
    anchor_point = "TOPLEFT",
    self_point = "TOPLEFT",
    anchor_area = "ALL",
    width = 16,
    height = 16,
    xOffset = -3,
    yOffset = 3,
  }
end

local function isSupported(parentType)
  return parentType == "icon" or parentType == "aurabar" or parentType == "progresstexture"
end

local function createRegion()
  local region = CreateFrame("Frame", nil, UIParent)
  local preview = region:CreateTexture(nil, "OVERLAY", nil, 1)
  preview:SetAllPoints(region)
  preview:Hide()
  region.preview = preview

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
    local mode = data.anchor_mode or "point"
    region:ClearAllPoints()
    if data.anchor_mode == "point" then
      region:SetSize(data.width or 24, data.height or 24)
    end
    local target = mode == "area" and data.anchor_area or data.anchor_point
    local ownPoint = data.anchor_mode == "point" and data.self_point or nil
    parent:AnchorSubRegion(region, mode, target, ownPoint, data.xOffset or 0, data.yOffset or 0)
  end
  region:Anchor()

  region.Update = function()
    Private.CDMAuraProgress.UpdateIndicator(parent, region, data)
  end
  region.UpdateProgress = region.Update
  for _, eventName in ipairs(SUBSCRIBED_EVENTS) do
    parent.subRegionEvents:AddSubscriber(eventName, region)
  end

  Private.CDMAuraProgress.ModifyIndicator(parent, region, parentData, data)
  region:SetVisible(data.dispelVisible ~= false)
end

local function releaseRegion(region)
  local parent = region.parent
  if parent then
    for _, eventName in ipairs(SUBSCRIBED_EVENTS) do
      parent.subRegionEvents:RemoveSubscriber(eventName, region)
    end
  end
  Private.CDMAuraProgress.ReleaseIndicator(region, true)
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

WeakAuras.RegisterSubRegionType("subcdmdispel", "CDM Dispel Type Icon", isSupported,
  createRegion, modifyRegion, showRegion, releaseRegion, getDefaults, nil, properties)

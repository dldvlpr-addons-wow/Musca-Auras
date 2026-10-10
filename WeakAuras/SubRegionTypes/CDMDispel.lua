if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local supportedParents = {
  icon = true,
  aurabar = true,
  progresstexture = true,
}

local trackedEvents = { "Update", "UpdateProgress" }

local function supports(parentType)
  return supportedParents[parentType] == true
end

local function setVisible(self, isVisible)
  self.visible = isVisible
  self:SetShown(isVisible and true or false)
  if self.Update then
    self.Update()
  end
end

local function create()
  local region = CreateFrame("Frame", nil, UIParent)
  local preview = region:CreateTexture(nil, "OVERLAY", nil, 1)
  preview:SetAllPoints(region)
  preview:Hide()
  region.preview = preview
  region.SetVisible = setVisible
  return region
end

local function modify(parent, region, parentData, data)
  region:SetParent(parent)
  region.parent = parent

  region.Anchor = function()
    region:ClearAllPoints()
    local xOffset = data.xOffset or 0
    local yOffset = data.yOffset or 0
    local mode = data.anchor_mode or "point"
    if data.anchor_mode == "point" then
      region:SetSize(data.width or 24, data.height or 24)
      parent:AnchorSubRegion(region, "point", data.anchor_point, data.self_point, xOffset, yOffset)
    elseif mode == "area" then
      parent:AnchorSubRegion(region, "area", data.anchor_area or data.anchor_point, nil, xOffset, yOffset)
    else
      parent:AnchorSubRegion(region, mode, data.anchor_point, nil, xOffset, yOffset)
    end
  end
  region.Anchor()

  local refresh = function()
    Private.CDMAuraProgress.UpdateIndicator(parent, region, data)
  end
  region.Update = refresh
  region.UpdateProgress = refresh

  for _, eventName in ipairs(trackedEvents) do
    parent.subRegionEvents:AddSubscriber(eventName, region)
  end

  Private.CDMAuraProgress.ModifyIndicator(parent, region, parentData, data)
  region:SetVisible(data.dispelVisible ~= false)
end

local function onAcquire(region)
  region:Show()
end

local function onRelease(region)
  local parent = region.parent
  if parent then
    for _, eventName in ipairs(trackedEvents) do
      parent.subRegionEvents:RemoveSubscriber(eventName, region)
    end
  end
  Private.CDMAuraProgress.ReleaseIndicator(region, true)
  region:Hide()
end

local function default()
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

local properties = {
  dispelVisible = {
    display = "Visibility",
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true,
  },
}

WeakAuras.RegisterSubRegionType("subcdmdispel", "CDM Dispel Type Icon", supports, create, modify,
  onAcquire, onRelease, default, nil, properties)

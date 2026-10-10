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
  region.dispelEdges = Private.DispelTypeDisplay.CreateEdges(region)
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
    local mode = data.anchor_mode or "area"
    if mode == "point" then
      region:SetSize(data.width or 32, data.height or 32)
      parent:AnchorSubRegion(region, "point", data.anchor_point, data.self_point, xOffset, yOffset)
    elseif mode == "area" then
      parent:AnchorSubRegion(region, "area", data.anchor_area or data.anchor_point, nil, xOffset * 0.5, yOffset * 0.5)
    else
      parent:AnchorSubRegion(region, mode, data.anchor_point, nil, xOffset, yOffset)
    end
    Private.DispelTypeDisplay.Layout(region.dispelEdges, region, data)
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
  Private.DispelTypeDisplay.Hide(region.dispelEdges)
  region:Hide()
end

local function default(parentType)
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

local properties = {
  dispelVisible = {
    display = "Visibility",
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true,
  },
}

WeakAuras.RegisterSubRegionType("subcdmdispelborder", "Dispel Type Border", supports, create, modify,
  onAcquire, onRelease, default, nil, properties)

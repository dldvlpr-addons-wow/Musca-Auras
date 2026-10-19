if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local SharedMedia = LibStub("LibSharedMedia-3.0");

-- Default settings
local default = {
  controlledChildren = {},
  anchorPoint = "CENTER",
  anchorFrameType = "SCREEN",
  xOffset = 0,
  yOffset = 0,
  frameStrata = 1,
  border = false,
  borderColor = { 0, 0, 0, 1 },
  backdropColor = { 1, 1, 1, 0.5 },
  borderEdge = "Square Full White",
  borderOffset = 4,
  borderInset = 1,
  borderSize = 2,
  borderBackdrop = "Blizzard Tooltip",
  scale = 1,
  blizzardFlow = false,
  blizzardFlowGrowth = "RIGHT",
  blizzardFlowSpacing = 2,
  blizzardFlowSort = "Default",
  blizzardFlowReverse = false,
  blizzardFlowUseLimit = false,
  blizzardFlowLimit = 5,
};

Private.regionPrototype.AddAlphaToDefault(default);

-- Called when first creating a new region/display
local function create(parent)
  -- Main region
  local region = CreateFrame("Frame", nil, parent);
  region.regionType = "group"
  region:SetMovable(true);
  region:SetWidth(2);
  region:SetHeight(2);

  -- Border region
  local border = CreateFrame("Frame", nil, region, "BackdropTemplate")
  region.border = border;

  Private.regionPrototype.create(region);

  local oldSetFrameLevel = region.SetFrameLevel
  region.SetFrameLevel = function(self, level)
    oldSetFrameLevel(self, level)
    self.border:SetFrameLevel(level)
  end

  return region;
end

-- Calculate bounding box
local function getRect(data, region)
  -- Temp variables
  local blx, bly, trx, try;
  blx, bly = data.xOffset or 0, data.yOffset or 0;

  -- A dynamic group has no size of its own, it grows with its shown children.
  local width = data.width or (region and (region.width or region.currentWidth))
  local height = data.height or (region and (region.height or region.currentHeight))

  if width == nil or height == nil then
    return blx, bly, blx, bly;
  end

  -- Calc bounding box
  if(data.selfPoint:find("LEFT")) then
    trx = blx + width;
  elseif(data.selfPoint:find("RIGHT")) then
    trx = blx;
    blx = blx - width;
  else
    blx = blx - (width/2);
    trx = blx + width;
  end
  if(data.selfPoint:find("BOTTOM")) then
    try = bly + height;
  elseif(data.selfPoint:find("TOP")) then
    try = bly;
    bly = bly - height;
  else
    bly = bly - (height/2);
    try = bly + height;
  end

  -- Return data
  return blx, bly, trx, try;
end

local function FlowSelfPoint(data)
  if not (data.blizzardFlow and data.blizzardFlowFrames) then
    return nil
  end
  if data.selfPoint ~= nil then
    return data.selfPoint
  end
  return "CENTER"
end

local function RechainFlowGroup(data)
  local display = Private.BlizzardAuraDisplay
  local rechain = display and display.RechainFlow
  if not rechain then
    return
  end
  rechain(data)
  if WeakAuras.IsOptionsOpen() then
    display.ArrangeFlowPreview(data)
  end
end

-- Bounding box of the children of a group, in its own coordinates, as left, bottom, right, top. A sub group is drawn at
-- its scale, its offsets included.
local function groupRect(data)
  local leftest, rightest, lowest, highest = 0, 0, 0, 0
  for _, childId in ipairs(data.controlledChildren) do
    local child = WeakAuras.GetData(childId)
    if child then
      local blx, bly, trx, try
      if child.regionType == "group" then
        local scale = child.scale and child.scale > 0 and child.scale <= 10 and child.scale or 1
        local x, y = child.xOffset or 0, child.yOffset or 0
        blx, bly, trx, try = groupRect(child)
        blx, bly, trx, try = (x + blx) * scale, (y + bly) * scale, (x + trx) * scale, (y + try) * scale
      else
        blx, bly, trx, try = getRect(child, WeakAuras.GetRegion(childId))
      end
      leftest = math.min(leftest, blx)
      rightest = math.max(rightest, trx)
      lowest = math.min(lowest, bly)
      highest = math.max(highest, try)
    end
  end
  return leftest, lowest, rightest, highest
end

-- Modify a given region/display
local function modify(parent, region, data)
  local flowSelfPoint = FlowSelfPoint(data)
  if flowSelfPoint then
    data.selfPoint = flowSelfPoint
  elseif data.information.groupOffset then
    data.selfPoint = "BOTTOMLEFT";
  else
    data.selfPoint = "CENTER";
  end
  Private.regionPrototype.modify(parent, region, data);
  -- Localize
  local border = region.border;

  -- Scale
  region:SetScale(data.scale and data.scale > 0 and data.scale <= 10 and data.scale or 1)

  region.GetBoundingRect = function(self)
    if not self.boundingRect then
      local leftest, lowest, rightest, highest = groupRect(data)
      self.blx = leftest
      self.bly = lowest
      self.trx = rightest
      self.try = highest
      self.boundingRect = true
    end
    return self.blx, self.bly, self.trx, self.try
  end
  region.boundingRect = false

  -- Adjust frame-level sorting
  Private.FixGroupChildrenOrderForGroup(data);

  local hasDynamicSubGroups = false
  for index, childId in pairs(data.controlledChildren) do
    local childData = WeakAuras.GetData(childId);
    if childData.regionType == "dynamicgroup" then
      hasDynamicSubGroups = true
      break;
    end
  end

  if not hasDynamicSubGroups then
    -- Control children (does not happen with "group")
    function region:UpdateBorder(childRegion)
      local border = region.border;
      -- Apply border settings
      if data.border then
        -- Initial visibility (of child that originated UpdateBorder(...))
        local childVisible = childRegion and childRegion.toShow or false;

        -- Scan children for visibility
        if not childVisible then
          for child in Private.TraverseLeafs(data) do
            local childRegion = Private.regions[child.id] and Private.regions[child.id].region;
            if childRegion and childRegion.toShow then
              childVisible = true;
              break;
            end
          end
        end

        -- Show border if child is visible
        if childVisible then
          local blx, bly, trx, try = self:GetBoundingRect()

          border:SetBackdrop({
            edgeFile = data.borderEdge ~= "None" and SharedMedia:Fetch("border", data.borderEdge) or "",
            edgeSize = data.borderSize,
            bgFile = data.borderBackdrop ~= "None" and SharedMedia:Fetch("background", data.borderBackdrop) or "",
            insets = {
              left     = data.borderInset,
              right     = data.borderInset,
              top     = data.borderInset,
              bottom     = data.borderInset,
            },
          });
          border:SetBackdropBorderColor(data.borderColor[1], data.borderColor[2], data.borderColor[3], data.borderColor[4]);
          border:SetBackdropColor(data.backdropColor[1], data.backdropColor[2], data.backdropColor[3], data.backdropColor[4]);

          border:ClearAllPoints();
          border:SetPoint("bottomleft", region, "bottomleft", blx - data.borderOffset, bly - data.borderOffset);
          border:SetPoint("topright",   region, "topright",   trx + data.borderOffset, try + data.borderOffset);
          border:Show();
        else
          border:Hide();
        end
      else
        border:Hide();
      end
    end
    region:UpdateBorder()
  else
    region.UpdateBorder = function() end
    region.border:Hide()
  end

  Private.regionPrototype.modifyFinish(parent, region, data);
  if data.blizzardFlow then
    RechainFlowGroup(data)
  end
end

-- Register new region type with WeakAuras
Private.RegisterRegionType("group", create, modify, default, Private.regionPrototype.GroupProperties(default));

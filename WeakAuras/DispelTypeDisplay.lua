if not WeakAuras.IsLibsOK() then return end
local Private = select(2, ...)

local EDGE_COUNT = 4
local EDGE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local DEFAULT_THICKNESS = 2
local MAX_THICKNESS = 32
local MIN_THICKNESS = 1

local DispelTypeDisplay = {}
Private.DispelTypeDisplay = DispelTypeDisplay

local EDGE_CORNERS = {
  { { "TOPLEFT", -1, 1 }, { "TOPRIGHT", 1, 1 }, "SetHeight" },
  { { "BOTTOMLEFT", -1, -1 }, { "BOTTOMRIGHT", 1, -1 }, "SetHeight" },
  { { "TOPLEFT", -1, 1 }, { "BOTTOMLEFT", -1, -1 }, "SetWidth" },
  { { "TOPRIGHT", 1, 1 }, { "BOTTOMRIGHT", 1, -1 }, "SetWidth" },
}

function DispelTypeDisplay.CreateEdges(owner)
  local edges = {}
  for index = 1, EDGE_COUNT do
    local texture = owner:CreateTexture(nil, "OVERLAY", nil, 0)
    texture:SetTexture(EDGE_TEXTURE)
    texture:Hide()
    edges[index] = texture
  end
  return edges
end

function DispelTypeDisplay.Layout(edges, target, data)
  local thickness = tonumber(data.dispelBorderSize) or DEFAULT_THICKNESS
  thickness = math.max(MIN_THICKNESS, math.min(MAX_THICKNESS, thickness))
  local spread = tonumber(data.dispelBorderOffset) or 0

  for _, texture in ipairs(edges) do
    texture:ClearAllPoints()
  end

  for index = 1, EDGE_COUNT do
    local texture = edges[index]
    local layout = EDGE_CORNERS[index]
    for pointIndex = 1, 2 do
      local corner = layout[pointIndex]
      texture:SetPoint(corner[1], target, corner[1], corner[2] * spread, corner[3] * spread)
    end
    texture[layout[3]](texture, thickness)
  end
end

function DispelTypeDisplay.Hide(edges)
  if not edges then return end
  for _, texture in ipairs(edges) do
    texture:Hide()
  end
end

function DispelTypeDisplay.Bind(button, edges)
  local styles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
  local preserveAsset = styles and styles.PreserveAsset
  if preserveAsset == nil then return end
  for _, texture in ipairs(edges) do
    button:AddDispelTypeTexture(texture, {
      showWhenHelpful = true,
      showWhenHarmful = true,
      style = preserveAsset,
    })
  end
end

local function convertToBorder(subRegion, data)
  subRegion.type = "subcdmdispelborder"
  subRegion.dispelStyle = nil
  subRegion.dispelBorderSize = subRegion.dispelBorderSize or DEFAULT_THICKNESS
  subRegion.dispelBorderOffset = subRegion.dispelBorderOffset or 0
  if subRegion.anchor_mode ~= "area" then
    subRegion.xOffset = 0
    subRegion.yOffset = 0
  end
  subRegion.anchor_mode = "area"
  subRegion.anchor_area = subRegion.anchor_area or (data.regionType == "aurabar" and "bar" or "ALL")
end

local function duplicateConditionChanges(conditions, fromIndex, toIndex)
  if not conditions then return end
  local fromProperty = "sub." .. fromIndex .. ".dispelVisible"
  local toProperty = "sub." .. toIndex .. ".dispelVisible"
  for _, condition in ipairs(conditions) do
    local changes = condition.changes
    if changes then
      for changeIndex = 1, #changes do
        local change = changes[changeIndex]
        if change.property == fromProperty then
          local duplicate = CopyTable(change)
          duplicate.property = toProperty
          changes[#changes + 1] = duplicate
        end
      end
    end
  end
end

function DispelTypeDisplay.Migrate(data)
  local subRegions = data.subRegions
  if not subRegions then return end
  for index = 1, #subRegions do
    local subRegion = subRegions[index]
    if subRegion.type == "subcdmdispel" then
      local style = subRegion.dispelStyle
      if style == "Border" then
        convertToBorder(subRegion, data)
      elseif style == "BorderWithIcon" then
        local borderCopy = CopyTable(subRegion)
        convertToBorder(borderCopy, data)
        subRegions[#subRegions + 1] = borderCopy
        subRegion.dispelStyle = "Icon"
        duplicateConditionChanges(data.conditions, index, #subRegions)
      end
    end
  end
end

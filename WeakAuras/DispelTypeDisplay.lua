if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local EDGE_COUNT = 4
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"

local EDGE_LAYOUT = {
  {points = {{"TOPLEFT", -1, 1}, {"TOPRIGHT", 1, 1}}, resize = "SetHeight"},
  {points = {{"BOTTOMLEFT", -1, -1}, {"BOTTOMRIGHT", 1, -1}}, resize = "SetHeight"},
  {points = {{"TOPLEFT", -1, 1}, {"BOTTOMLEFT", -1, -1}}, resize = "SetWidth"},
  {points = {{"TOPRIGHT", 1, 1}, {"BOTTOMRIGHT", 1, -1}}, resize = "SetWidth"},
}

local DispelTypeDisplay = {}
Private.DispelTypeDisplay = DispelTypeDisplay

function DispelTypeDisplay.CreateEdges(owner)
  local created = {}
  for slot = 1, EDGE_COUNT do
    local texture = owner:CreateTexture(nil, "OVERLAY", nil, 0)
    texture:SetTexture(WHITE_TEXTURE)
    texture:Hide()
    created[slot] = texture
  end
  return created
end

function DispelTypeDisplay.Layout(edges, target, data)
  local thickness = math.min(32, tonumber(data.dispelBorderSize) or 2)
  thickness = math.max(1, thickness)
  local spread = tonumber(data.dispelBorderOffset) or 0
  for _, texture in ipairs(edges) do
    texture:ClearAllPoints()
  end
  for slot, layout in ipairs(EDGE_LAYOUT) do
    local texture = edges[slot]
    for _, anchor in ipairs(layout.points) do
      local point, signX, signY = anchor[1], anchor[2], anchor[3]
      texture:SetPoint(point, target, point, signX * spread, signY * spread)
    end
    texture[layout.resize](texture, thickness)
  end
end

function DispelTypeDisplay.Hide(edges)
  if not edges then return end
  for _, texture in ipairs(edges) do
    texture:Hide()
  end
end

function DispelTypeDisplay.Bind(button, edges)
  local textureStyle = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset
  if textureStyle == nil then return end
  local options = {showWhenHelpful = true, showWhenHarmful = true, style = textureStyle}
  for _, texture in ipairs(edges) do
    button:AddDispelTypeTexture(texture, options)
  end
end

local function legacyStyleOf(element)
  if element.type ~= "subcdmdispel" then return nil end
  local style = element.dispelStyle
  if style == "Border" or style == "BorderWithIcon" then return style end
  return nil
end

local function convertToBorder(border, data)
  border.type = "subcdmdispelborder"
  border.dispelStyle = nil
  border.dispelBorderSize = border.dispelBorderSize or 2
  border.dispelBorderOffset = border.dispelBorderOffset or 0
  if border.anchor_mode ~= "area" then
    border.xOffset = 0
    border.yOffset = 0
  end
  border.anchor_mode = "area"
  local defaultArea = data.regionType == "aurabar" and "bar" or "ALL"
  border.anchor_area = border.anchor_area or defaultArea
end

local function duplicateConditionChanges(data, fromProperty, toProperty)
  for _, condition in ipairs(data.conditions or {}) do
    local changes = condition.changes or {}
    local known = #changes
    for position = 1, known do
      local change = changes[position]
      if change.property == fromProperty then
        local clone = CopyTable(change)
        clone.property = toProperty
        changes[#changes + 1] = clone
      end
    end
  end
end

function DispelTypeDisplay.Migrate(data)
  local list = data.subRegions or {}
  local original = #list
  for position = 1, original do
    local element = list[position]
    local style = legacyStyleOf(element)
    if style == "Border" then
      convertToBorder(element, data)
    elseif style == "BorderWithIcon" then
      local border = CopyTable(element)
      convertToBorder(border, data)
      element.dispelStyle = "Icon"
      list[#list + 1] = border
      duplicateConditionChanges(data,
        "sub." .. position .. ".dispelVisible",
        "sub." .. #list .. ".dispelVisible")
    end
  end
end

-- Glow effects (pixel, ants, alert, socket) on native aura element buttons.
-- Fills Private.BlizzardAuraDisplay; only SecretAuraAppearance.lua calls it.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

local TEXTURE_SOLID = "Interface\\Buttons\\WHITE8X8"
local TEXTURE_ANTS = "Interface\\SpellActivationOverlay\\IconAlertAnts"
local TEXTURE_ALERT = "Interface\\SpellActivationOverlay\\IconAlert"
local COORDS_ALERT = {0.00781250, 0.50781250, 0.27734375, 0.52734375}
local TEXTURE_SOCKET = "Interface\\ItemSocketingFrame\\UI-ItemSockets"
local COORDS_SOCKET = {0.3984375, 0.4453125, 0.40234375, 0.44921875}
local COLOR_PIXEL = {0.95, 0.95, 0.32, 1}
local SETTING_NAMES = {
  "glowType", "glowLines", "glowFrequency", "glowLength", "glowThickness", "glowXOffset",
  "glowYOffset", "glowScale", "glowBorder", "glowDuration", "useGlowColor",
}

local function Clamp(raw, default, minimum, maximum)
  local value = tonumber(raw)
  if not value or value ~= value then
    return default
  end
  return math.max(minimum, math.min(maximum, value))
end

function Display.ClearElementGlow(entry)
  local current = entry and entry.nativeGlow
  if not current then
    return
  end
  local owner = current.button
  for _, animationGroup in ipairs(current.groups) do
    if owner and owner.RemoveAuraShownAnimation then
      pcall(owner.RemoveAuraShownAnimation, owner, animationGroup)
    end
    animationGroup:Stop()
  end
  for _, texture in ipairs(current.textures) do
    texture:Hide()
  end
  for _, frame in ipairs(current.frames) do
    frame:Hide()
  end
  if current.holder then
    current.holder:Hide()
  end
  entry.nativeGlow = nil
  entry.keptGlow = current
end

local function BuildCacheKey(button, parent, anchor, element, width, height)
  local parts = {tostring(button), tostring(parent), tostring(anchor), width, height}
  for _, name in ipairs(SETTING_NAMES) do
    parts[#parts + 1] = tostring(element[name])
  end
  local color = element.glowColor
  if type(color) == "table" then
    for channel = 1, 4 do
      parts[#parts + 1] = tostring(color[channel])
    end
  end
  return table.concat(parts, "|")
end

local function AddTexture(glow, parent, layer)
  local texture = parent:CreateTexture(nil, layer or "OVERLAY")
  texture:SetBlendMode("ADD")
  table.insert(glow.textures, texture)
  return texture
end

local function AddAnimationGroup(glow, texture)
  local animationGroup = texture:CreateAnimationGroup()
  animationGroup:SetLooping("REPEAT")
  table.insert(glow.groups, animationGroup)
  return animationGroup
end

local function ApplyColor(texture, element, fallbackColor)
  if element.useGlowColor and type(element.glowColor) == "table" then
    texture:SetDesaturated(true)
    texture:SetVertexColor(unpack(element.glowColor))
    return
  end
  if fallbackColor then
    texture:SetVertexColor(unpack(fallbackColor))
    return
  end
  texture:SetDesaturated(false)
  texture:SetVertexColor(1, 1, 1, 1)
end

local function AddFlipBook(glow, texture, rows, columns, frameCount, duration, frameSize)
  local animationGroup = AddAnimationGroup(glow, texture)
  local flipBook = animationGroup:CreateAnimation("FlipBook")
  flipBook:SetDuration(duration)
  flipBook:SetFlipBookRows(rows)
  flipBook:SetFlipBookColumns(columns)
  flipBook:SetFlipBookFrames(frameCount)
  flipBook:SetFlipBookFrameWidth(frameSize or 0)
  flipBook:SetFlipBookFrameHeight(frameSize or 0)
  return animationGroup
end

local function PerimeterPosition(distance, width, height)
  local total = 2 * (width + height)
  distance = distance % total
  if distance < width then
    return distance, 0
  end
  distance = distance - width
  if distance < height then
    return width, distance
  end
  distance = distance - height
  if distance < width then
    return width - distance, height
  end
  return 0, height - (distance - width)
end

local function AddPerimeterPath(glow, texture, holder, width, height, duration, phase, reverse)
  local total = 2 * (width + height)
  local origin = phase * total
  local startX, startY = PerimeterPosition(origin, width, height)
  texture:ClearAllPoints()
  texture:SetPoint("CENTER", holder, "BOTTOMLEFT", startX, startY)
  local offsets = {total}
  local known = {[total] = true}
  local function Record(distance)
    if distance > 0 and distance < total and not known[distance] then
      offsets[#offsets + 1] = distance
      known[distance] = true
    end
  end
  for step = 1, 15 do
    Record(total * step / 16)
  end
  local corners = {0, width, width + height, 2 * width + height}
  for _, corner in ipairs(corners) do
    if reverse then
      Record((origin - corner) % total)
    else
      Record((corner - origin) % total)
    end
  end
  table.sort(offsets)
  local animationGroup = AddAnimationGroup(glow, texture)
  local path = animationGroup:CreateAnimation("Path")
  path:SetDuration(duration)
  path:SetCurveType("NONE")
  for order, distance in ipairs(offsets) do
    local x, y = PerimeterPosition(origin + (reverse and -distance or distance), width, height)
    local controlPoint = path:CreateControlPoint(nil, nil, order)
    controlPoint:SetOffset(x - startX, y - startY)
  end
  return animationGroup
end

local function BuildProcGlow(glow, holder, element, width, height)
  local scale = Clamp(element.glowScale, 1, 0.25, 4)
  local texture = AddTexture(glow, holder)
  texture:SetPoint("CENTER", holder, "CENTER")
  texture:SetSize(width * 1.4 * scale, height * 1.4 * scale)
  texture:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
  ApplyColor(texture, element)
  AddFlipBook(glow, texture, 6, 5, 30, Clamp(element.glowDuration, 1, 0.1, 10))
end

local function BuildButtonOverlayGlow(glow, holder, element, width, height, frequency)
  local frame = AddTexture(glow, holder)
  frame:SetPoint("CENTER", holder, "CENTER")
  frame:SetSize(width * 1.4, height * 1.4)
  frame:SetTexture(TEXTURE_ALERT)
  frame:SetTexCoord(unpack(COORDS_ALERT))
  ApplyColor(frame, element)
  local marching = AddTexture(glow, holder)
  marching:SetPoint("CENTER", holder, "CENTER")
  marching:SetSize(width * 1.2, height * 1.2)
  marching:SetTexture(TEXTURE_ANTS)
  ApplyColor(marching, element)
  AddFlipBook(glow, marching, 5, 5, 22, 0.055 / math.max(0.01, math.abs(frequency)), 48)
end

local function BuildPixelGlow(glow, holder, element, width, height, count, duration, reverse)
  local thickness = Clamp(element.glowThickness, 2, 0.5, 12)
  local length = Clamp(element.glowLength, 0, 0, math.min(width, height))
  if length == 0 then
    length = math.max(thickness, (width + height) * (2 / count - 0.1))
  end
  local side = math.max(thickness, length) / math.sqrt(2)
  local edges = {}
  for index, point in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
    local edge = CreateFrame("Frame", nil, holder)
    table.insert(glow.frames, edge)
    edge:SetClipsChildren(true)
    edge:SetPoint(point, holder, point)
    if index <= 2 then
      edge:SetSize(width, thickness)
    else
      edge:SetSize(thickness, height)
    end
    edges[index] = edge
    if element.glowBorder then
      local backdrop = AddTexture(glow, edge, "BACKGROUND")
      backdrop:SetBlendMode("BLEND")
      backdrop:SetAllPoints(edge)
      backdrop:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    end
  end
  for line = 1, count do
    for _, edge in ipairs(edges) do
      local dot = AddTexture(glow, edge)
      dot:SetTexture(TEXTURE_SOLID)
      dot:SetSize(side, side)
      dot:SetRotation(math.pi / 4)
      ApplyColor(dot, element, COLOR_PIXEL)
      AddPerimeterPath(glow, dot, holder, width, height, duration, (line - 1) / count, reverse)
    end
  end
end

local function BuildShineGlow(glow, holder, element, width, height, count, duration, reverse)
  local size = 8 * Clamp(element.glowScale, 1, 0.25, 4)
  for spark = 1, count do
    local texture = AddTexture(glow, holder)
    texture:SetTexture(TEXTURE_SOCKET)
    texture:SetTexCoord(unpack(COORDS_SOCKET))
    texture:SetSize(size, size)
    ApplyColor(texture, element)
    local animationGroup = AddPerimeterPath(glow, texture, holder, width, height, duration, (spark - 1) / count, reverse)
    for half = 1, 2 do
      local fade = animationGroup:CreateAnimation("Alpha")
      fade:SetOrder(1)
      fade:SetStartDelay(half == 1 and 0 or duration / 2)
      fade:SetDuration(duration / 2)
      fade:SetFromAlpha(half == 1 and 0.2 or 1)
      fade:SetToAlpha(half == 1 and 1 or 0.2)
    end
  end
end

local function RestoreKeptGlow(entry, kept, button)
  entry.nativeGlow = kept
  entry.keptGlow = nil
  if kept.holder then
    kept.holder:Show()
  end
  for _, frame in ipairs(kept.frames) do
    frame:Show()
  end
  for _, texture in ipairs(kept.textures) do
    texture:Show()
  end
  for _, animationGroup in ipairs(kept.groups) do
    button:AddAuraShownAnimation(animationGroup)
    animationGroup:Play()
  end
end

local function AcquireHolder(entry, parent)
  entry.glowHolders = entry.glowHolders or {}
  local holder = entry.glowHolders[parent]
  if not holder then
    holder = CreateFrame("Frame", nil, parent)
    entry.glowHolders[parent] = holder
  end
  return holder
end

function Display.StyleElementGlow(entry, button, parent, anchor, element, w, h)
  Display.ClearElementGlow(entry)
  if not element.glow then
    return
  end
  local cacheKey = BuildCacheKey(button, parent, anchor, element, w, h)
  local kept = entry.keptGlow
  if kept and kept.key == cacheKey then
    RestoreKeptGlow(entry, kept, button)
    return
  end
  entry.keptGlow = nil
  local glow = {button = button, groups = {}, textures = {}, frames = {}, key = cacheKey}
  entry.nativeGlow = glow
  local xOffset = Clamp(element.glowXOffset, 0, -200, 200)
  local yOffset = Clamp(element.glowYOffset, 0, -200, 200)
  local holder = AcquireHolder(entry, parent)
  glow.holder = holder
  holder:ClearAllPoints()
  holder:SetPoint("CENTER", anchor, "CENTER")
  local width = math.max(2, w + xOffset * 2)
  local height = math.max(2, h + yOffset * 2)
  holder:SetSize(width, height)
  holder:Show()
  local kind = element.glowType or "Proc"
  local frequency = Clamp(element.glowFrequency, 0.25, -10, 10)
  if kind == "Proc" then
    BuildProcGlow(glow, holder, element, width, height)
  elseif kind == "buttonOverlay" then
    BuildButtonOverlayGlow(glow, holder, element, width, height, frequency)
  else
    local isPixel = kind == "Pixel"
    local count = math.floor(Clamp(element.glowLines, isPixel and 8 or 4, 1, 32))
    local duration = frequency == 0 and 4 or math.max(0.1, math.abs(1 / frequency))
    local reverse = frequency < 0
    if isPixel then
      BuildPixelGlow(glow, holder, element, width, height, count, duration, reverse)
    else
      BuildShineGlow(glow, holder, element, width, height, count, duration, reverse)
    end
  end
  for _, animationGroup in ipairs(glow.groups) do
    button:AddAuraShownAnimation(animationGroup)
    animationGroup:Play()
  end
end

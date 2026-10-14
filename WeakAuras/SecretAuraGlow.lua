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
local PERIMETER_MOVES = 5
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

local pendingGlows = {}
local isDrainScheduled = false
local DRAIN_BUDGET_MS = 8

function Display.ClearElementGlow(entry)
  if entry then
    pendingGlows[entry] = nil
  end
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

local function TakePart(glow, kind, parent, create)
  local pool = glow.pool[kind]
  if not pool then
    pool = {}
    glow.pool[kind] = pool
  end
  local index = (glow.used[kind] or 0) + 1
  glow.used[kind] = index
  local part = pool[index]
  if not part then
    part = create(parent)
    pool[index] = part
  end
  return part
end

local function NewTexturePart(parent)
  return {texture = parent:CreateTexture(nil, "OVERLAY")}
end

local function NewEdgePart(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetClipsChildren(true)
  return {frame = frame}
end

local function AddTexture(glow, parent, layer, kind)
  local part = TakePart(glow, kind or "still", parent, NewTexturePart)
  local texture = part.texture
  if texture:GetParent() ~= parent then
    texture:SetParent(parent)
  end
  texture:SetDrawLayer(layer or "OVERLAY")
  texture:ClearAllPoints()
  texture:SetBlendMode("ADD")
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetRotation(0)
  texture:SetVertexColor(1, 1, 1, 1)
  texture:SetDesaturated(false)
  texture:Show()
  table.insert(glow.textures, texture)
  return texture, part
end

local function PartGroup(glow, part, field)
  local animationGroup = part[field]
  if not animationGroup then
    animationGroup = part.texture:CreateAnimationGroup()
    animationGroup:SetLooping("REPEAT")
    part[field] = animationGroup
  end
  table.insert(glow.groups, animationGroup)
  return animationGroup
end

local function ApplyColor(texture, element, fallbackColor)
  if element.useGlowColor and type(element.glowColor) == "table" then
    texture:SetDesaturated(true)
    texture:SetVertexColor(unpack(element.glowColor))
    return
  end
  texture:SetDesaturated(false)
  if fallbackColor then
    texture:SetVertexColor(unpack(fallbackColor))
    return
  end
  texture:SetVertexColor(1, 1, 1, 1)
end

local function AddFlipBook(glow, part, rows, columns, frameCount, duration, frameSize)
  local animationGroup = PartGroup(glow, part, "group")
  part.flipBook = part.flipBook or animationGroup:CreateAnimation("FlipBook")
  local flipBook = part.flipBook
  flipBook:SetDuration(duration)
  flipBook:SetFlipBookRows(rows)
  flipBook:SetFlipBookColumns(columns)
  flipBook:SetFlipBookFrames(frameCount)
  flipBook:SetFlipBookFrameWidth(frameSize or 0)
  flipBook:SetFlipBookFrameHeight(frameSize or 0)
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

local function AddPerimeterMoves(glow, part, holder, width, height, duration, phase, reverse)
  local total = 2 * (width + height)
  local origin = phase * total
  local startX, startY = PerimeterPosition(origin, width, height)
  part.texture:SetPoint("CENTER", holder, "BOTTOMLEFT", startX, startY)
  local animationGroup = PartGroup(glow, part, "group")
  if not part.moves then
    part.moves = {}
    for order = 1, PERIMETER_MOVES do
      local move = animationGroup:CreateAnimation("Translation")
      move:SetOrder(order)
      part.moves[order] = move
    end
  end
  local stops = {}
  for _, corner in ipairs({0, width, width + height, 2 * width + height}) do
    local distance = reverse and (origin - corner) % total or (corner - origin) % total
    if distance > 0 then
      stops[#stops + 1] = distance
    end
  end
  table.sort(stops)
  stops[#stops + 1] = total
  local travelled, lastX, lastY = 0, startX, startY
  for index, move in ipairs(part.moves) do
    local distance = stops[index] or travelled
    local x, y = PerimeterPosition(origin + (reverse and -distance or distance), width, height)
    move:SetOffset(x - lastX, y - lastY)
    move:SetDuration(duration * (distance - travelled) / total)
    travelled, lastX, lastY = distance, x, y
  end
end

local function BuildProcGlow(glow, holder, element, width, height)
  local scale = Clamp(element.glowScale, 1, 0.25, 4)
  local texture, part = AddTexture(glow, holder, nil, "flip")
  texture:SetPoint("CENTER", holder, "CENTER")
  texture:SetSize(width * 1.4 * scale, height * 1.4 * scale)
  texture:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
  ApplyColor(texture, element)
  AddFlipBook(glow, part, 6, 5, 30, Clamp(element.glowDuration, 1, 0.1, 10))
end

local function BuildButtonOverlayGlow(glow, holder, element, width, height, frequency)
  local frame = AddTexture(glow, holder)
  frame:SetPoint("CENTER", holder, "CENTER")
  frame:SetSize(width * 1.4, height * 1.4)
  frame:SetTexture(TEXTURE_ALERT)
  frame:SetTexCoord(unpack(COORDS_ALERT))
  ApplyColor(frame, element)
  local marching, part = AddTexture(glow, holder, nil, "ants")
  marching:SetPoint("CENTER", holder, "CENTER")
  marching:SetSize(width * 1.2, height * 1.2)
  marching:SetTexture(TEXTURE_ANTS)
  ApplyColor(marching, element)
  AddFlipBook(glow, part, 5, 5, 22, 0.055 / math.max(0.01, math.abs(frequency)), 48)
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
    local edge = TakePart(glow, "edge", holder, NewEdgePart).frame
    table.insert(glow.frames, edge)
    if edge:GetParent() ~= holder then
      edge:SetParent(holder)
    end
    edge:ClearAllPoints()
    edge:SetPoint(point, holder, point)
    if index <= 2 then
      edge:SetSize(width, thickness)
    else
      edge:SetSize(thickness, height)
    end
    edge:Show()
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
      local dot, part = AddTexture(glow, edge, nil, "dot")
      dot:SetTexture(TEXTURE_SOLID)
      dot:SetSize(side, side)
      dot:SetRotation(math.pi / 4)
      ApplyColor(dot, element, COLOR_PIXEL)
      AddPerimeterMoves(glow, part, holder, width, height, duration, (line - 1) / count, reverse)
    end
  end
end

local function BuildShineGlow(glow, holder, element, width, height, count, duration, reverse)
  local size = 8 * Clamp(element.glowScale, 1, 0.25, 4)
  for spark = 1, count do
    local texture, part = AddTexture(glow, holder, nil, "spark")
    texture:SetTexture(TEXTURE_SOCKET)
    texture:SetTexCoord(unpack(COORDS_SOCKET))
    texture:SetSize(size, size)
    ApplyColor(texture, element)
    AddPerimeterMoves(glow, part, holder, width, height, duration, (spark - 1) / count, reverse)
    local fadeGroup = PartGroup(glow, part, "fadeGroup")
    if not part.fades then
      part.fades = {}
      for order = 1, 2 do
        local fade = fadeGroup:CreateAnimation("Alpha")
        fade:SetOrder(order)
        fade:SetFromAlpha(order == 1 and 0.2 or 1)
        fade:SetToAlpha(order == 1 and 1 or 0.2)
        part.fades[order] = fade
      end
    end
    for _, fade in ipairs(part.fades) do
      fade:SetDuration(duration / 2)
    end
  end
end

local function ShowGlowParts(glow)
  if glow.holder then
    glow.holder:Show()
  end
  for _, frame in ipairs(glow.frames) do
    frame:Show()
  end
  for _, texture in ipairs(glow.textures) do
    texture:Show()
  end
  for _, animationGroup in ipairs(glow.groups) do
    animationGroup:Play()
  end
end

local function RestoreKeptGlow(entry, kept, button)
  entry.nativeGlow = kept
  entry.keptGlow = nil
  for _, animationGroup in ipairs(kept.groups) do
    button:AddAuraShownAnimation(animationGroup)
  end
  ShowGlowParts(kept)
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

local BuildGlow, DrainPendingGlows

local function ScheduleGlowDrain()
  if isDrainScheduled then
    return
  end
  isDrainScheduled = true
  C_Timer.After(0, DrainPendingGlows)
end

function DrainPendingGlows()
  isDrainScheduled = false
  if WeakAuras.IsRestricted() then
    isDrainScheduled = true
    C_Timer.After(1, DrainPendingGlows)
    return
  end
  local start = debugprofilestop()
  local built = {}
  for entry, pending in pairs(pendingGlows) do
    pendingGlows[entry] = nil
    if entry.native then
      built[entry.native] = true
    end
    xpcall(BuildGlow, geterrorhandler(), entry, pending.button, pending.parent, pending.anchor, pending.element, pending.w, pending.h, pending.key)
    if debugprofilestop() - start > DRAIN_BUDGET_MS then
      break
    end
  end
  for native in pairs(built) do
    Display.RefreshShownAnimations(native)
  end
  if next(pendingGlows) then
    ScheduleGlowDrain()
  end
end

function Display.StyleElementGlow(entry, button, parent, anchor, element, w, h)
  entry.glowStale = nil
  local cacheKey = element.glow and BuildCacheKey(button, parent, anchor, element, w, h)
  local current = entry.nativeGlow
  if current and current.key == cacheKey then
    ShowGlowParts(current)
    return
  end
  Display.ClearElementGlow(entry)
  if not cacheKey then
    return
  end
  local kept = entry.keptGlow
  if kept and kept.key == cacheKey then
    RestoreKeptGlow(entry, kept, button)
    return
  end
  if not kept and button and (not button.bindings or WeakAuras.IsOptionsOpen()) and not WeakAuras.IsRestricted() then
    pendingGlows[entry] = {button = button, parent = parent, anchor = anchor, element = element, w = w, h = h, key = cacheKey}
    ScheduleGlowDrain()
    return
  end
  BuildGlow(entry, button, parent, anchor, element, w, h, cacheKey)
end

function BuildGlow(entry, button, parent, anchor, element, w, h, cacheKey)
  entry.keptGlow = nil
  local holder = AcquireHolder(entry, parent)
  entry.glowPool = entry.glowPool or {}
  entry.glowPool[holder] = entry.glowPool[holder] or {}
  local glow = {button = button, holder = holder, groups = {}, textures = {}, frames = {}, key = cacheKey, pool = entry.glowPool[holder], used = {}}
  entry.nativeGlow = glow
  local xOffset = Clamp(element.glowXOffset, 0, -200, 200)
  local yOffset = Clamp(element.glowYOffset, 0, -200, 200)
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

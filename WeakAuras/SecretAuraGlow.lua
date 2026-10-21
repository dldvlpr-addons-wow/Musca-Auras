-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay

local abs, max, min, floor, sqrt, pi = math.abs, math.max, math.min, math.floor, math.sqrt, math.pi

local BUDGET_MS = 8
local RESTRICTED_RETRY = 1
local WHITE = { 1, 1, 1, 1 }
local PIXEL_YELLOW = { 0.95, 0.95, 0.32, 1 }
local PROC_ATLAS = "UI-HUD-ActionBar-Proc-Loop-Flipbook"
local ALERT_TEXTURE = "Interface\\SpellActivationOverlay\\IconAlert"
local ANTS_TEXTURE = "Interface\\SpellActivationOverlay\\IconAlertAnts"
local SPARK_TEXTURE = "Interface\\ItemSocketingFrame\\UI-ItemSockets"
local EDGES = { "TOP", "BOTTOM", "LEFT", "RIGHT" }
local KEY_FIELDS = {
  "glowType", "glowLines", "glowFrequency", "glowLength", "glowThickness", "glowXOffset", "glowYOffset",
  "glowScale", "glowBorder", "glowDuration", "useGlowColor",
}

local function Clamp(value, low, high, fallback)
  local number = tonumber(value)
  if not number or number ~= number then return fallback end
  if number < low then return low end
  if number > high then return high end
  return number
end

local function Unreadable(value)
  return value == nil or (issecretvalue ~= nil and issecretvalue(value) == true)
end

local function BuildKey(request, element)
  local key = {
    request.button, request.parent, request.anchor, request.width or false, request.height or false,
    request.shiftX, request.shiftY,
  }
  local count = 7
  for _, field in ipairs(KEY_FIELDS) do
    count = count + 1
    key[count] = element[field]
  end
  local color = element.glowColor
  if type(color) == "table" then
    for channel = 1, 4 do
      count = count + 1
      key[count] = color[channel]
    end
  end
  key.count = count
  return key
end

local function KeysMatch(left, right)
  if not left or not right or left.count ~= right.count then return false end
  for index = 1, left.count do
    if left[index] ~= right[index] then return false end
  end
  return true
end

local function Normalize(element, width, height)
  local frequency = Clamp(element.glowFrequency, -10, 10, 0.25)
  local settings = {
    kind = element.glowType,
    frequency = frequency,
    reverse = frequency < 0,
    period = frequency == 0 and 4 or max(0.1, abs(1 / frequency)),
    scale = Clamp(element.glowScale, 0.25, 4, 1),
    duration = Clamp(element.glowDuration, 0.1, tonumber(element.glowDurationMax) or 10, 1),
    thickness = Clamp(element.glowThickness, 0.5, 12, 2),
    padX = Clamp(element.glowXOffset, -200, 200, 0),
    padY = Clamp(element.glowYOffset, -200, 200, 0),
    border = element.glowBorder,
    lines = element.glowLines,
  }
  if element.useGlowColor and type(element.glowColor) == "table" then
    settings.color = element.glowColor
  end
  if width and height then
    settings.width = max(2, width + 2 * settings.padX)
    settings.height = max(2, height + 2 * settings.padY)
    settings.length = Clamp(element.glowLength, 0, min(settings.width, settings.height), 0)
  end
  return settings
end

local function HolderOf(entry, parent)
  entry.glowHolders = entry.glowHolders or {}
  local holder = entry.glowHolders[parent]
  if not holder then
    holder = CreateFrame("Frame", nil, parent)
    entry.glowHolders[parent] = holder
  end
  return holder
end

local function PoolOf(entry, holder)
  entry.glowPools = entry.glowPools or {}
  local pool = entry.glowPools[holder]
  if not pool then
    pool = { holder = holder, textures = {}, edges = { used = 0 }, groups = {} }
    entry.glowPools[holder] = pool
  end
  return pool
end

local function Rewind(pool)
  for _, list in pairs(pool.textures) do list.used = 0 end
  pool.edges.used = 0
end

local function TakeTexture(glow, pool, owner)
  local list = pool.textures[owner]
  if not list then
    list = { used = 0 }
    pool.textures[owner] = list
  end
  list.used = list.used + 1
  local texture = list[list.used]
  if not texture then
    texture = owner:CreateTexture()
    list[list.used] = texture
  end
  texture:ClearAllPoints()
  texture:SetDrawLayer("OVERLAY")
  texture:SetBlendMode("ADD")
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetRotation(0)
  texture:SetVertexColor(1, 1, 1, 1)
  texture:SetDesaturated(false)
  texture:Show()
  glow.textures[#glow.textures + 1] = texture
  return texture
end

local function TakeEdge(glow, pool)
  local list = pool.edges
  list.used = list.used + 1
  local frame = list[list.used]
  if not frame then
    frame = CreateFrame("Frame", nil, pool.holder)
    frame:SetClipsChildren(true)
    list[list.used] = frame
  end
  frame:ClearAllPoints()
  frame:Show()
  glow.frames[#glow.frames + 1] = frame
  return frame
end

local function TakeGroup(glow, pool, texture, shape, count, animationType)
  local byShape = pool.groups[texture]
  if not byShape then
    byShape = {}
    pool.groups[texture] = byShape
  end
  local group = byShape[shape]
  if not group then
    group = texture:CreateAnimationGroup()
    group:SetLooping("REPEAT")
    for order = 1, count do
      group:CreateAnimation(animationType):SetOrder(order)
    end
    byShape[shape] = group
  end
  glow.groups[#glow.groups + 1] = group
  return group, { group:GetAnimations() }
end

local function Tint(texture, color, fallback)
  local source = color or fallback
  texture:SetDesaturated(color ~= nil)
  texture:SetVertexColor(source[1], source[2], source[3], source[4])
end

local function Cover(texture, holder, settings, factor)
  if settings.width then
    texture:SetPoint("CENTER", holder, "CENTER")
    texture:SetSize(settings.width * factor, settings.height * factor)
  else
    texture:SetAllPoints(holder)
  end
end

local function FlipBook(glow, pool, texture, duration, rows, columns, frames, frameSize)
  local _, animations = TakeGroup(glow, pool, texture, "flipBook", 1, "FlipBook")
  local flip = animations[1]
  flip:SetDuration(duration)
  flip:SetFlipBookRows(rows)
  flip:SetFlipBookColumns(columns)
  flip:SetFlipBookFrames(frames)
  flip:SetFlipBookFrameWidth(frameSize)
  flip:SetFlipBookFrameHeight(frameSize)
end

local function Fade(glow, pool, texture, low, period)
  local _, animations = TakeGroup(glow, pool, texture, "fade", 2, "Alpha")
  animations[1]:SetFromAlpha(low)
  animations[1]:SetToAlpha(1)
  animations[1]:SetDuration(period / 2)
  animations[2]:SetFromAlpha(1)
  animations[2]:SetToAlpha(low)
  animations[2]:SetDuration(period / 2)
end

local function Route(glow, pool, texture, settings, start)
  local width, height = settings.width, settings.height
  local corners
  if settings.reverse then
    corners = { { 0, 0 }, { 0, height }, { width, height }, { width, 0 } }
  else
    corners = { { 0, 0 }, { width, 0 }, { width, height }, { 0, height } }
  end
  local function Corner(index) return corners[(index - 1) % 4 + 1] end
  local function Span(index)
    local from, to = Corner(index), Corner(index + 1)
    return abs(to[1] - from[1]) + abs(to[2] - from[2])
  end
  local perimeter = 2 * (width + height)
  local travelled = start * perimeter
  local side = 1
  while side < 4 and travelled >= Span(side) do
    travelled = travelled - Span(side)
    side = side + 1
  end
  local from, to = Corner(side), Corner(side + 1)
  local fraction = travelled / Span(side)
  local originX = from[1] + (to[1] - from[1]) * fraction
  local originY = from[2] + (to[2] - from[2]) * fraction
  texture:SetPoint("CENTER", glow.holder, "BOTTOMLEFT", originX, originY)
  local _, moves = TakeGroup(glow, pool, texture, "route", 5, "Translation")
  local x, y = originX, originY
  for step = 1, 5 do
    local targetX, targetY = originX, originY
    if step < 5 then
      local corner = Corner(side + step)
      targetX, targetY = corner[1], corner[2]
    end
    local dx, dy = targetX - x, targetY - y
    moves[step]:SetOffset(dx, dy)
    moves[step]:SetDuration(settings.period * (abs(dx) + abs(dy)) / perimeter)
    x, y = targetX, targetY
  end
end

local function Halo(glow, pool, settings, factor)
  local halo = TakeTexture(glow, pool, glow.holder)
  halo:SetTexture(ALERT_TEXTURE)
  halo:SetTexCoord(0.0078125, 0.5078125, 0.27734375, 0.52734375)
  Cover(halo, glow.holder, settings, factor)
  Tint(halo, settings.color, WHITE)
  return halo
end

local function DrawProc(glow, pool, settings)
  local texture = TakeTexture(glow, pool, glow.holder)
  texture:SetAtlas(PROC_ATLAS)
  Cover(texture, glow.holder, settings, 1.4 * settings.scale)
  Tint(texture, settings.color, WHITE)
  FlipBook(glow, pool, texture, settings.duration, 6, 5, 30, 0)
end

local function DrawOverlay(glow, pool, settings)
  Halo(glow, pool, settings, 1.4)
  local ants = TakeTexture(glow, pool, glow.holder)
  ants:SetTexture(ANTS_TEXTURE)
  Cover(ants, glow.holder, settings, 1.2)
  Tint(ants, settings.color, WHITE)
  FlipBook(glow, pool, ants, 0.055 / max(0.01, abs(settings.frequency)), 5, 5, 22, 48)
end

local function DrawPulse(glow, pool, settings)
  local halo = Halo(glow, pool, settings, 1.4 * settings.scale)
  Fade(glow, pool, halo, 0.25, settings.duration)
end

local function DrawPixel(glow, pool, settings)
  if not settings.width then return end
  local width, height, thickness = settings.width, settings.height, settings.thickness
  local lines = floor(Clamp(settings.lines, 1, 32, 8))
  local length = settings.length
  if length == 0 then
    length = max(thickness, (width + height) * (2 / lines - 0.1))
  end
  local side = max(thickness, length) / sqrt(2)
  for _, edge in ipairs(EDGES) do
    local frame = TakeEdge(glow, pool)
    frame:SetPoint(edge, glow.holder, edge)
    if edge == "TOP" or edge == "BOTTOM" then
      frame:SetSize(width, thickness)
    else
      frame:SetSize(thickness, height)
    end
    if settings.border then
      local backdrop = TakeTexture(glow, pool, frame)
      backdrop:SetDrawLayer("BACKGROUND")
      backdrop:SetBlendMode("BLEND")
      backdrop:SetColorTexture(0.1, 0.1, 0.1, 0.8)
      backdrop:SetAllPoints(frame)
    end
    for line = 1, lines do
      local dot = TakeTexture(glow, pool, frame)
      dot:SetColorTexture(1, 1, 1, 1)
      dot:SetSize(side, side)
      dot:SetRotation(pi / 4)
      Tint(dot, settings.color, PIXEL_YELLOW)
      Route(glow, pool, dot, settings, (line - 1) / lines)
    end
  end
end

local function DrawShine(glow, pool, settings)
  if not settings.width then return end
  local sparks = floor(Clamp(settings.lines, 1, 32, 4))
  local size = 8 * settings.scale
  for spark = 1, sparks do
    local texture = TakeTexture(glow, pool, glow.holder)
    texture:SetTexture(SPARK_TEXTURE)
    texture:SetTexCoord(0.3984375, 0.4453125, 0.40234375, 0.44921875)
    texture:SetSize(size, size)
    Tint(texture, settings.color, WHITE)
    Route(glow, pool, texture, settings, (spark - 1) / sparks)
    Fade(glow, pool, texture, 0.2, settings.period)
  end
end

local DRAWERS = { Proc = DrawProc, buttonOverlay = DrawOverlay, pulse = DrawPulse, Pixel = DrawPixel }

local function Place(holder, request)
  local settings, anchor = request.settings, request.anchor
  local shiftX, shiftY = request.shiftX or 0, request.shiftY or 0
  holder:ClearAllPoints()
  if settings.width then
    holder:SetPoint("CENTER", anchor, "CENTER", shiftX, shiftY)
    holder:SetSize(settings.width, settings.height)
  else
    holder:SetPoint("TOPLEFT", anchor, "TOPLEFT", shiftX - settings.padX, shiftY + settings.padY)
    holder:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", shiftX + settings.padX, shiftY - settings.padY)
  end
end

local function Resume(glow, handToButton)
  local button = glow.button
  for _, group in ipairs(glow.groups) do
    if handToButton and button then button:AddAuraShownAnimation(group) end
    group:Play()
  end
  glow.holder:Show()
  for _, frame in ipairs(glow.frames) do frame:Show() end
  for _, texture in ipairs(glow.textures) do texture:Show() end
end

local function Build(entry, request)
  entry.keptGlow = nil
  local holder = HolderOf(entry, request.parent)
  local pool = PoolOf(entry, holder)
  Rewind(pool)
  local glow = { button = request.button, holder = holder, key = request.key, groups = {}, textures = {}, frames = {} }
  entry.nativeGlow = glow
  Place(holder, request)
  local kind = request.settings.kind
  local draw = kind == nil and DrawProc or DRAWERS[kind] or DrawShine
  draw(glow, pool, request.settings)
  Resume(glow, true)
end

local pending = setmetatable({}, { __mode = "k" })
local waiting = {}
local queued = {}
local scheduled = false
local Drain

local function Schedule(delay)
  if scheduled then return end
  scheduled = true
  C_Timer.After(delay, Drain)
end

Drain = function()
  scheduled = false
  if WeakAuras.IsRestricted() then
    Schedule(RESTRICTED_RETRY)
    return
  end
  local started = debugprofilestop()
  local natives, seen = {}, {}
  while #waiting > 0 do
    local entry = table.remove(waiting, 1)
    queued[entry] = nil
    local request = pending[entry]
    if request then
      pending[entry] = nil
      local ok, problem = pcall(Build, entry, request)
      if not ok then
        geterrorhandler()(problem)
      elseif entry.native and not seen[entry.native] then
        seen[entry.native] = true
        natives[#natives + 1] = entry.native
      end
      if debugprofilestop() - started >= BUDGET_MS then break end
    end
  end
  if #waiting > 0 then Schedule(0) end
  for _, native in ipairs(natives) do Display.RefreshShownAnimations(native) end
end

local function Enqueue(entry, request)
  pending[entry] = request
  if not queued[entry] then
    queued[entry] = true
    waiting[#waiting + 1] = entry
  end
  Schedule(0)
end

local function ClearGlow(entry)
  pending[entry] = nil
  local glow = entry.nativeGlow
  if not glow then return end
  local button = glow.button
  for _, group in ipairs(glow.groups) do
    if button and button.RemoveAuraShownAnimation then
      pcall(button.RemoveAuraShownAnimation, button, group)
    end
    group:Stop()
  end
  for _, texture in ipairs(glow.textures) do texture:Hide() end
  for _, frame in ipairs(glow.frames) do frame:Hide() end
  glow.holder:Hide()
  entry.nativeGlow = nil
  entry.keptGlow = glow
end

function Display.ClearElementGlow(entry)
  if entry then ClearGlow(entry) end
end

function Display.StyleElementGlow(entry, button, parent, anchor, element, width, height, shiftX, shiftY)
  entry.glowStale = nil
  if not element.glow then
    ClearGlow(entry)
    return
  end
  if Unreadable(width) or Unreadable(height) then
    width, height = nil, nil
  end
  local request = {
    button = button, parent = parent, anchor = anchor, width = width, height = height,
    shiftX = shiftX, shiftY = shiftY, settings = Normalize(element, width, height),
  }
  request.key = BuildKey(request, element)

  local active = entry.nativeGlow
  if active and KeysMatch(active.key, request.key) then
    Resume(active, false)
    return
  end
  ClearGlow(entry)

  local kept = entry.keptGlow
  if kept and KeysMatch(kept.key, request.key) then
    entry.nativeGlow, entry.keptGlow = kept, nil
    Resume(kept, true)
    return
  end
  if not kept and button ~= nil and (button.bindings == nil or WeakAuras.IsOptionsOpen())
    and not WeakAuras.IsRestricted() then
    Enqueue(entry, request)
    return
  end
  Build(entry, request)
end

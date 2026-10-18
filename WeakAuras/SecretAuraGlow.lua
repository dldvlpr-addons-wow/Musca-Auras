-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Glow of the subglow elements on the native display. Only Blizzard knows whether the aura is
-- present, so every animation group is handed to the button (AddAuraShownAnimation), which plays
-- it while the aura shows. Parts are pooled per holder; a cleared glow is kept for a cheap restore.
-- Without a readable size (absent or secret), the holder is stretched over its anchor instead:
-- textures fill it, and the types that need a size (Pixel, Shine) draw nothing.

local Display = Private.BlizzardAuraDisplay

local BUILD_BUDGET_MS = 8
local RESTRICTED_RETRY_SECONDS = 1
local WHITE = { 1, 1, 1, 1 }
local PIXEL_YELLOW = { 0.95, 0.95, 0.32, 1 }
local PROC_ATLAS = "UI-HUD-ActionBar-Proc-Loop-Flipbook"
local ALERT_FILE = "Interface\\SpellActivationOverlay\\IconAlert"
local ANTS_FILE = "Interface\\SpellActivationOverlay\\IconAlertAnts"
local SPARK_FILE = "Interface\\ItemSocketingFrame\\UI-ItemSockets"

local function Clamp(value, low, high, default)
  value = tonumber(value)
  if not value or value ~= value then return default end
  return math.max(low, math.min(high, value))
end

-- Identity of a glow: what it is drawn on and every setting that changes its parts.
local KEY_SETTINGS = {
  "glowType", "glowLines", "glowFrequency", "glowLength", "glowThickness", "glowXOffset",
  "glowYOffset", "glowScale", "glowBorder", "glowDuration", "useGlowColor",
}
local KEY_SIZE = 7 + #KEY_SETTINGS + 4

local function GlowKey(button, parent, anchor, element, width, height, shiftX, shiftY)
  local key = { button, parent, anchor, width or false, height or false, shiftX, shiftY }
  for index, field in ipairs(KEY_SETTINGS) do key[7 + index] = element[field] end
  local color = element.glowColor
  if type(color) == "table" then
    for channel = 1, 4 do key[7 + #KEY_SETTINGS + channel] = color[channel] end
  end
  return key
end

local function SameKey(left, right)
  for index = 1, KEY_SIZE do
    if left[index] ~= right[index] then return false end
  end
  return true
end

local function ReadSettings(element, width, height)
  local frequency = Clamp(element.glowFrequency, -10, 10, 0.25)
  local settings = {
    frequency = frequency,
    scale = Clamp(element.glowScale, 0.25, 4, 1),
    duration = Clamp(element.glowDuration, 0.1, element.glowDurationMax or 10, 1),
    thickness = Clamp(element.glowThickness, 0.5, 12, 2),
    border = element.glowBorder,
    lines = element.glowLines,
    loop = frequency == 0 and 4 or math.max(0.1, math.abs(1 / frequency)),
    reverse = frequency < 0,
  }
  if element.useGlowColor and type(element.glowColor) == "table" then settings.color = element.glowColor end
  settings.padX = Clamp(element.glowXOffset, -200, 200, 0)
  settings.padY = Clamp(element.glowYOffset, -200, 200, 0)
  if not width then
    settings.stretched = true
    return settings
  end
  settings.width = math.max(2, width + 2 * settings.padX)
  settings.height = math.max(2, height + 2 * settings.padY)
  settings.length = Clamp(element.glowLength, 0, math.min(settings.width, settings.height), 0)
  return settings
end

-- Parts already created on a holder, handed out again in the same order at each build.
local PartPool = {}
PartPool.__index = PartPool

local GROUP_SHAPES = {
  flipBook = { "FlipBook" },
  route = { "Translation", "Translation", "Translation", "Translation", "Translation" },
  fade = { "Alpha", "Alpha" },
}

local function NewPool()
  return setmetatable({ shelves = {}, taken = {}, groups = {} }, PartPool)
end

function PartPool:Rewind()
  self.taken = {}
end

function PartPool:Take(shelfKey, create)
  local shelf = self.shelves[shelfKey] or {}
  self.shelves[shelfKey] = shelf
  local index = (self.taken[shelfKey] or 0) + 1
  self.taken[shelfKey] = index
  shelf[index] = shelf[index] or create()
  return shelf[index]
end

function PartPool:Group(texture, shape)
  local byShape = self.groups[texture] or {}
  self.groups[texture] = byShape
  if not byShape[shape] then
    local group = texture:CreateAnimationGroup()
    group:SetLooping("REPEAT")
    local animations = {}
    for order, kind in ipairs(GROUP_SHAPES[shape]) do
      animations[order] = group:CreateAnimation(kind)
      animations[order]:SetOrder(order)
    end
    byShape[shape] = { group = group, animations = animations }
  end
  return byShape[shape]
end

-- One build: takes parts from the pool and records them on the glow.
local Builder = {}
Builder.__index = Builder

function Builder:Texture(parent)
  local texture = self.pool:Take(parent, function() return parent:CreateTexture() end)
  texture:ClearAllPoints()
  texture:SetDrawLayer("OVERLAY")
  texture:SetBlendMode("ADD")
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetRotation(0)
  texture:SetVertexColor(1, 1, 1, 1)
  texture:SetDesaturated(false)
  texture:Show()
  table.insert(self.glow.textures, texture)
  return texture
end

function Builder:Centered(texture, factor)
  if self.settings.stretched then
    texture:SetAllPoints(self.glow.holder)
    return
  end
  texture:SetPoint("CENTER", self.glow.holder, "CENTER")
  texture:SetSize(factor * self.settings.width, factor * self.settings.height)
end

function Builder:Paint(texture, fallback)
  local color = self.settings.color
  texture:SetDesaturated(color ~= nil)
  local r, g, b, a = unpack(color or fallback or WHITE)
  texture:SetVertexColor(r, g, b, a)
end

function Builder:Animate(texture, shape)
  local set = self.pool:Group(texture, shape)
  table.insert(self.glow.groups, set.group)
  return set.animations
end

function Builder:FlipBook(texture, duration, rows, columns, frames, frameSize)
  local flipBook = self:Animate(texture, "flipBook")[1]
  flipBook:SetDuration(duration)
  flipBook:SetFlipBookRows(rows)
  flipBook:SetFlipBookColumns(columns)
  flipBook:SetFlipBookFrames(frames)
  flipBook:SetFlipBookFrameWidth(frameSize)
  flipBook:SetFlipBookFrameHeight(frameSize)
end

-- Alpha goes from low to 1 and back, once per period.
function Builder:Fade(texture, low, period)
  local rise, fall = unpack(self:Animate(texture, "fade"))
  rise:SetFromAlpha(low)
  rise:SetToAlpha(1)
  rise:SetDuration(period / 2)
  fall:SetFromAlpha(1)
  fall:SetToAlpha(low)
  fall:SetDuration(period / 2)
end

-- The square halo of the action button alert, centered on the holder.
function Builder:Alert(factor)
  local texture = self:Texture(self.glow.holder)
  texture:SetTexture(ALERT_FILE)
  texture:SetTexCoord(0.0078125, 0.5078125, 0.27734375, 0.52734375)
  self:Centered(texture, factor)
  self:Paint(texture)
  return texture
end

function Builder:Lines(default)
  return math.floor(Clamp(self.settings.lines, 1, 32, default))
end

-- Sends the texture once around the holder per loop at constant speed. The path starts at the
-- bottom left corner (rightwards, or upwards in reverse); start is the fraction of the perimeter
-- where this texture begins. Five moves: to the next corner, three edges, back to the start.
function Builder:Route(texture, start)
  local settings = self.settings
  local width, height = settings.width, settings.height
  local corners
  if settings.reverse then
    corners = { { 0, 0 }, { 0, height }, { width, height }, { width, 0 } }
  else
    corners = { { 0, 0 }, { width, 0 }, { width, height }, { 0, height } }
  end
  local function Corner(index) return corners[(index - 1) % 4 + 1] end
  local function Distance(from, to) return math.abs(to[1] - from[1]) + math.abs(to[2] - from[2]) end

  local perimeter = 2 * (width + height)
  local travelled = start * perimeter
  local edge = 1
  while edge < 4 and travelled >= Distance(Corner(edge), Corner(edge + 1)) do
    travelled = travelled - Distance(Corner(edge), Corner(edge + 1))
    edge = edge + 1
  end
  local from, to = Corner(edge), Corner(edge + 1)
  local along = travelled / Distance(from, to)
  local origin = { from[1] + (to[1] - from[1]) * along, from[2] + (to[2] - from[2]) * along }
  texture:SetPoint("CENTER", self.glow.holder, "BOTTOMLEFT", origin[1], origin[2])

  local waypoints = { Corner(edge + 1), Corner(edge + 2), Corner(edge + 3), Corner(edge + 4), origin }
  local position = origin
  for index, move in ipairs(self:Animate(texture, "route")) do
    local target = waypoints[index]
    move:SetOffset(target[1] - position[1], target[2] - position[2])
    move:SetDuration(settings.loop * Distance(position, target) / perimeter)
    position = target
  end
end

local PIXEL_EDGES = {
  { point = "TOP", horizontal = true },
  { point = "BOTTOM", horizontal = true },
  { point = "LEFT" },
  { point = "RIGHT" },
}

local GLOW_TYPES = {
  Proc = function(build)
    local texture = build:Texture(build.glow.holder)
    texture:SetAtlas(PROC_ATLAS)
    build:Centered(texture, 1.4 * build.settings.scale)
    build:Paint(texture)
    build:FlipBook(texture, build.settings.duration, 6, 5, 30, 0)
  end,

  buttonOverlay = function(build)
    build:Alert(1.4)
    local ants = build:Texture(build.glow.holder)
    ants:SetTexture(ANTS_FILE)
    build:Centered(ants, 1.2)
    build:Paint(ants)
    build:FlipBook(ants, 0.055 / math.max(0.01, math.abs(build.settings.frequency)), 5, 5, 22, 48)
  end,

  pulse = function(build)
    build:Fade(build:Alert(1.4 * build.settings.scale), 0.25, build.settings.duration)
  end,

  Pixel = function(build)
    if build.settings.stretched then return end
    local settings, holder = build.settings, build.glow.holder
    local lines, thickness = build:Lines(8), settings.thickness
    local length = settings.length
    if length == 0 then
      length = math.max(thickness, (settings.width + settings.height) * (2 / lines - 0.1))
    end
    local side = math.max(thickness, length) / math.sqrt(2)
    for _, layout in ipairs(PIXEL_EDGES) do
      local edge = build.pool:Take("edges", function()
        local frame = CreateFrame("Frame", nil, holder)
        frame:SetClipsChildren(true)
        return frame
      end)
      edge:ClearAllPoints()
      edge:SetPoint(layout.point, holder, layout.point)
      if layout.horizontal then
        edge:SetSize(settings.width, thickness)
      else
        edge:SetSize(thickness, settings.height)
      end
      edge:Show()
      table.insert(build.glow.frames, edge)
      if settings.border then
        local background = build:Texture(edge)
        background:SetDrawLayer("BACKGROUND")
        background:SetBlendMode("BLEND")
        background:SetColorTexture(0.1, 0.1, 0.1, 0.8)
        background:SetAllPoints(edge)
      end
      for line = 1, lines do
        local dot = build:Texture(edge)
        dot:SetColorTexture(1, 1, 1, 1)
        dot:SetSize(side, side)
        dot:SetRotation(math.pi / 4)
        build:Paint(dot, PIXEL_YELLOW)
        build:Route(dot, (line - 1) / lines)
      end
    end
  end,

  Shine = function(build)
    local settings = build.settings
    if settings.stretched then return end
    local sparks, size = build:Lines(4), 8 * settings.scale
    for spark = 1, sparks do
      local texture = build:Texture(build.glow.holder)
      texture:SetTexture(SPARK_FILE)
      texture:SetTexCoord(0.3984375, 0.4453125, 0.40234375, 0.44921875)
      texture:SetSize(size, size)
      build:Paint(texture)
      build:Route(texture, (spark - 1) / sparks)
      build:Fade(texture, 0.2, settings.loop)
    end
  end,
}

local function Resume(glow, handToButton)
  glow.holder:Show()
  for _, frame in ipairs(glow.frames) do frame:Show() end
  for _, texture in ipairs(glow.textures) do texture:Show() end
  for _, group in ipairs(glow.groups) do
    if handToButton then glow.button:AddAuraShownAnimation(group) end
    group:Play()
  end
end

local function Build(entry, request)
  entry.keptGlow = nil
  local parent = request.parent
  entry.glowHolders = entry.glowHolders or {}
  local holder = entry.glowHolders[parent] or CreateFrame("Frame", nil, parent)
  entry.glowHolders[parent] = holder
  entry.glowPool = entry.glowPool or {}
  local pool = entry.glowPool[holder] or NewPool()
  entry.glowPool[holder] = pool
  pool:Rewind()

  local glow = { button = request.button, holder = holder, key = request.key, groups = {}, textures = {}, frames = {} }
  entry.nativeGlow = glow
  local settings = ReadSettings(request.element, request.width, request.height)
  holder:ClearAllPoints()
  local shiftX, shiftY = request.shiftX or 0, request.shiftY or 0
  if settings.stretched then
    holder:SetPoint("TOPLEFT", request.anchor, "TOPLEFT", shiftX - settings.padX, shiftY + settings.padY)
    holder:SetPoint("BOTTOMRIGHT", request.anchor, "BOTTOMRIGHT", shiftX + settings.padX, shiftY - settings.padY)
  else
    holder:SetPoint("CENTER", request.anchor, "CENTER", shiftX, shiftY)
    holder:SetSize(settings.width, settings.height)
  end

  local glowType = request.element.glowType or "Proc"
  local draw = GLOW_TYPES[glowType] or GLOW_TYPES.Shine
  draw(setmetatable({ glow = glow, pool = pool, settings = settings }, Builder))
  Resume(glow, true)
end

-- Builds waiting for the next frame, one request per entry, within a time budget per frame.
local BuildQueue = { order = {}, requests = {}, scheduled = false }

function BuildQueue:Schedule(delay)
  if self.scheduled then return end
  self.scheduled = true
  C_Timer.After(delay, function() self:Drain() end)
end

function BuildQueue:Add(entry, request)
  if not self.requests[entry] then table.insert(self.order, entry) end
  self.requests[entry] = request
  self:Schedule(0)
end

function BuildQueue:Remove(entry)
  if not self.requests[entry] then return end
  self.requests[entry] = nil
  for index, queued in ipairs(self.order) do
    if queued == entry then
      table.remove(self.order, index)
      return
    end
  end
end

function BuildQueue:Drain()
  self.scheduled = false
  if WeakAuras.IsRestricted() then
    self:Schedule(RESTRICTED_RETRY_SECONDS)
    return
  end
  local started = debugprofilestop()
  local builtNatives = {}
  while self.order[1] do
    local entry = table.remove(self.order, 1)
    local request = self.requests[entry]
    self.requests[entry] = nil
    local ok, message = pcall(Build, entry, request)
    if not ok then
      geterrorhandler()(message)
    elseif entry.native then
      builtNatives[entry.native] = true
    end
    if debugprofilestop() - started >= BUILD_BUDGET_MS then break end
  end
  for native in pairs(builtNatives) do Display.RefreshShownAnimations(native) end
  if self.order[1] then self:Schedule(0) end
end

local function ClearGlow(entry)
  if not entry then return end
  BuildQueue:Remove(entry)
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
  entry.nativeGlow, entry.keptGlow = nil, glow
end
Display.ClearElementGlow = ClearGlow

-- width and height may be nil or secret: the glow is then stretched over its anchor.
-- shiftX and shiftY move the holder off its anchor; both are optional.
function Display.StyleElementGlow(entry, button, parent, anchor, element, width, height, shiftX, shiftY)
  entry.glowStale = nil
  if not element.glow then
    ClearGlow(entry)
    return
  end
  if issecretvalue(width) or issecretvalue(height) or not width or not height then
    width, height = nil, nil
  end
  local request = {
    button = button, parent = parent, anchor = anchor, element = element, width = width, height = height,
    shiftX = shiftX, shiftY = shiftY, key = GlowKey(button, parent, anchor, element, width, height, shiftX, shiftY),
  }
  local current = entry.nativeGlow
  if current and SameKey(current.key, request.key) then
    Resume(current, false)
    return
  end
  ClearGlow(entry)
  local kept = entry.keptGlow
  if kept then
    if SameKey(kept.key, request.key) then
      entry.nativeGlow, entry.keptGlow = kept, nil
      Resume(kept, true)
      return
    end
  elseif button and (not button.bindings or WeakAuras.IsOptionsOpen()) and not WeakAuras.IsRestricted() then
    -- Live buttons and the options preview build in bulk: spread them over the next frames.
    BuildQueue:Add(entry, request)
    return
  end
  Build(entry, request)
end

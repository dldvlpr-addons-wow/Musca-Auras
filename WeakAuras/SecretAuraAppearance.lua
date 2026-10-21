-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L
local Display = Private.BlizzardAuraDisplay

local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local SMALLEST_SIZE = 4
local WHITE = {1, 1, 1, 1}
local SWIPE = {0, 0, 0, 0.8}
local BAR_RED = {1, 0, 0, 1}
local BAR_BACKGROUND = {0, 0, 0, 0.5}

local DUPLICATE_KEY = "Aura (Modern) supports one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text."
local UNSUPPORTED_KEY = "This sub element is not supported by Aura (Modern). Use Text, Texture or Glow."
local CODES_MESSAGE = "You can only use %p, %s, %n or hardcoded text. Put each code in its own text element. Custom text (%c) is not supported."
local DETACHED_MESSAGE = "Detached Text uses hardcoded text. Use other triggers and Conditions to control when it appears."
local GLOW_MESSAGE = "Choose Action Button Glow, Pixel Glow, Autocast Shine or Proc Glow."

local CODE_KINDS = {["%p"] = "duration", ["%s"] = "stack", ["%n"] = "name"}
local GLOW_TYPES = {Proc = true, buttonOverlay = true, Pixel = true, ACShine = true}
local BUTTON_CLEARERS = {
  "ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon",
}
local PLACEMENTS = {
  subtexture = {mode = "area", point = "CENTER", size = 32},
  subcdmdispelborder = {mode = "area", point = "CENTER", size = 32},
  subcdmdispel = {mode = "point", point = "TOPLEFT", size = 16},
}
local LEGACY_TEXT_FIELDS = {
  {"Font", "text_font"}, {"Size", "text_fontSize"}, {"Color", "text_color"}, {"Outline", "text_fontType"},
  {"Justify", "text_justify"}, {"ShadowColor", "text_shadowColor"}, {"ShadowX", "text_shadowXOffset"},
  {"ShadowY", "text_shadowYOffset"}, {"Anchor", "anchor_point"}, {"SelfPoint", "text_selfPoint"},
  {"X", "anchorXOffset"}, {"Y", "anchorYOffset"},
}

Display.supportedElements = {
  subbackground = true, subforeground = true, subtext = true, subborder = true,
  subglow = true, subtexture = true, subcdmdispel = true, subcdmdispelborder = true,
}

local function IsSecret(value)
  return issecretvalue ~= nil and issecretvalue(value) and true or false
end

local function Copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, inner in pairs(value) do result[Copy(key)] = Copy(inner) end
  return result
end

local function ColorValues(color, fallback)
  if type(color) ~= "table" then color = fallback end
  return color[1], color[2], color[3], color[4] or 1
end

local function Round(value)
  return math.floor(value + 0.5)
end

local function Hide(object)
  if object then object:Hide() end
end

local function ReadLevel(frame)
  local level = frame.GetFrameLevel and frame:GetFrameLevel()
  if IsSecret(level) or type(level) ~= "number" then return 0 end
  return level
end

local function FetchMedia(kind, name)
  local media = LibStub and LibStub("LibSharedMedia-3.0", true)
  if not media or name == nil then return nil end
  return media:Fetch(kind, name)
end

local function PixelFactor()
  if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then return PixelUtil.GetPixelToUIUnitFactor() end
  return 1
end

local function FillOn(region, target)
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", target, "TOPLEFT")
  region:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT")
end

function Display.Dimensions(data)
  local settings = type(data.blizzardAuraDisplay) == "table" and data.blizzardAuraDisplay or nil
  if data.regionType == "text" then
    local height = settings and settings.textHeight or 1.2 * (data.fontSize or 18)
    return math.max(SMALLEST_SIZE, data.fixedWidth or 200), math.max(SMALLEST_SIZE, height)
  end
  return math.max(SMALLEST_SIZE, data.width or 64), math.max(SMALLEST_SIZE, data.height or 64)
end

function Display.IconTexCoords(data, zoom)
  if zoom == nil then zoom = data.zoom or 0 end
  if data.regionType ~= "icon" then
    local margin = math.min(0.45, math.max(0, zoom / 2))
    return margin, 1 - margin, margin, 1 - margin
  end
  local spanX = 1 - zoom / 2
  local spanY = spanX
  if data.keepAspectRatio then
    local width, height = Display.Dimensions(data)
    local ratio = width / height
    if ratio > 1 then
      spanY = spanY / ratio
    else
      spanX = spanX * ratio
    end
  end
  local centerX = 0.5 - (data.texXOffset or 0)
  local centerY = 0.5 + (data.texYOffset or 0)
  return centerX - spanX / 2, centerX + spanX / 2, centerY - spanY / 2, centerY + spanY / 2
end

local function SkinCorners(native, data)
  local skin = native.masqueCoords
  if data.regionType ~= "icon" or type(skin) ~= "table" or #skin ~= 8 then return nil end
  for index = 1, 8 do
    if type(skin[index]) ~= "number" then return nil end
  end
  return skin
end

function Display.StyleIconTexCoords(native, data, zoom)
  local left, right, top, bottom = Display.IconTexCoords(data, zoom)
  local skin = SkinCorners(native, data)
  if not skin then
    native.icon:SetTexCoord(left, right, top, bottom)
    return
  end
  local mapped = {}
  for index = 1, 8, 2 do
    mapped[index] = left + skin[index] * (right - left)
    mapped[index + 1] = top + skin[index + 1] * (bottom - top)
  end
  native.icon:SetTexCoord(unpack(mapped, 1, 8))
end

function Private.MasquePinSize(button, width, height)
  if button == nil or width == nil or height == nil then return end
  local config = button._MSQ_CFG
  if not config then return end
  config.FrameWidth, config.FrameHeight = width, height
  local owner = config.SetFrameSize and config or button
  local original = owner.SetFrameSize
  if not original or owner.waPinnedSetFrameSize then return end
  owner.waPinnedSetFrameSize = original
  owner.SetFrameSize = function(self, frameWidth, frameHeight, ...)
    if frameWidth == nil then
      frameWidth, frameHeight = config.FrameWidth, config.FrameHeight
    else
      config.FrameWidth, config.FrameHeight = frameWidth, frameHeight
    end
    return original(self, frameWidth, frameHeight, ...)
  end
end

function Display.IsDetachedElement(data, element)
  local enabled = Display.Enabled(data)
  if not enabled then return enabled end
  if element == nil then return nil end
  if element.secretAuraDetached ~= true then return false end
  return element.type == "subtext" or element.type == "subtexture"
end

function Display.IsDetachedProperty(data, property)
  local index = tostring(property):match("^sub%.(%d+)%..+$")
  if not index or not data.subRegions then return false end
  return Display.IsDetachedElement(data, data.subRegions[tonumber(index)]) == true
end

function Display.CanAddElement(data, kind)
  if kind == "subcdmdispel" or kind == "subcdmdispelborder" then
    if Display.Enabled(data) then return true end
    local progress = Private.CDMAuraProgress
    return (progress and progress.IsConfigured and progress.IsConfigured(data)) and true or false
  end
  if not Display.Enabled(data) then return true end
  if not Display.supportedElements[kind] then return false end
  if kind == "subborder" then
    for _, element in ipairs(data.subRegions or {}) do
      if element.type == "subborder" then return false end
    end
  end
  return true
end

function Display.TextKind(text)
  if text == nil or text == "" then return "literal" end
  text = tostring(text)
  if CODE_KINDS[text] then return CODE_KINDS[text] end
  local remaining = text:gsub("%%%%", "")
  if remaining:find("%", 1, true) then return nil end
  return "literal"
end

function Display.TextSettings(element)
  local x = element.text_anchorXOffset
  if x == nil then x = element.anchorXOffset end
  local y = element.text_anchorYOffset
  if y == nil then y = element.anchorYOffset end
  return {
    textFont = element.text_font,
    textSize = element.text_fontSize,
    textColor = element.text_color,
    textOutline = element.text_fontType,
    textJustify = element.text_justify,
    textShadowColor = element.text_shadowColor,
    textShadowX = element.text_shadowXOffset,
    textShadowY = element.text_shadowYOffset,
    textSelfPoint = element.text_selfPoint,
    textAnchor = element.anchor_point,
    textX = x,
    textY = y,
  }
end

function Display.SplitAnchorTarget(native, button, point)
  if type(point) == "string" then
    local prefix = point:sub(1, 6)
    if prefix == "INNER_" then return native.inner, point:sub(7) end
    if prefix == "OUTER_" then return native.outer, point:sub(7) end
  end
  return button, point
end

function Display.ValidateAppearance(data)
  local claimed = {}
  local function CheckShown(text)
    local kind = Display.TextKind(text)
    if kind == nil then return CODES_MESSAGE end
    if kind == "literal" then return nil end
    if claimed[kind] then return L[DUPLICATE_KEY] end
    claimed[kind] = true
  end
  if data.regionType == "text" then
    local problem = CheckShown(data.displayText)
    if problem then return problem end
  end
  for _, element in ipairs(data.subRegions or {}) do
    local kind = element.type
    if kind == nil or not Display.supportedElements[kind] then return L[UNSUPPORTED_KEY] end
    if kind == "subtext" then
      if Display.IsDetachedElement(data, element) then
        if Display.TextKind(element.text_text) ~= "literal" then return DETACHED_MESSAGE end
      elseif element.text_visible ~= false then
        local problem = CheckShown(element.text_text)
        if problem then return problem end
      end
    elseif kind == "subglow" and element.glow == true and not GLOW_TYPES[element.glowType or "Proc"] then
      return GLOW_MESSAGE
    end
  end
end

local function SubtextBase(regionType)
  local types = Private.subRegionTypes
  local default = types and types.subtext and types.subtext.default
  if type(default) == "function" then default = default(regionType) end
  local base = type(default) == "table" and Copy(default) or {}
  base.type = "subtext"
  return base
end

local function LegacyTextFallback(legacy, key, suffix)
  if suffix == "Size" then return key == "stack" and 14 or legacy.fontSize or 18 end
  if suffix == "ShadowColor" then return {0, 0, 0, 0} end
  if suffix == "Anchor" or suffix == "SelfPoint" then
    if key == "stack" then return "BOTTOMRIGHT" end
    if key == "label" then return "BOTTOM" end
    return "CENTER"
  end
  if suffix == "X" then return key == "stack" and -3 or 0 end
  if suffix == "Y" then return (key == "stack" or key == "label") and 3 or 0 end
end

local function ConvertText(legacy, key, regionType)
  local element = SubtextBase(regionType)
  local shown = true
  if key == "duration" then
    element.text_text = "%p"
    shown = legacy.duration ~= false
  elseif key == "stack" then
    element.text_text = "%s"
    shown = legacy.stacks ~= false
  else
    element.text_text = (tostring(legacy[key] or ""):gsub("%%", "%%%%"))
  end
  element.text_visible = shown and legacy[key .. "Visible"] ~= false
  for _, field in ipairs(LEGACY_TEXT_FIELDS) do
    local suffix, target = field[1], field[2]
    local value = legacy[key .. suffix]
    if value == nil then value = LegacyTextFallback(legacy, key, suffix) end
    if value ~= nil then element[target] = Copy(value) end
  end
  if key == "duration" then
    local format = legacy.durationFormat
    element.text_text_format_p_format = "timed"
    element.text_text_format_p_time_format = format == "clock" and 0 or format == "seconds" and -2 or -1
    element.text_text_format_p_time_precision = legacy.durationPrecision or 1
    element.text_text_format_p_time_dynamic_threshold = legacy.durationDecimalThreshold or 3
    element.text_text_format_p_time_legacy_floor = legacy.durationRoundUp == false
  end
  return element
end

local function ConvertLegacyElement(legacy, name, regionType)
  if name == "glow" then
    return {
      type = "subglow",
      glow = legacy.glow == true,
      glowType = legacy.glowType == "pulse" and "buttonOverlay" or "Proc",
      glowColor = legacy.glowColor ~= nil and Copy(legacy.glowColor) or {1, 0.82, 0, 1},
      useGlowColor = legacy.useGlowColor ~= false,
      glowScale = legacy.glowScale or 1,
      glowDuration = legacy.glowDuration or 1,
      glowXOffset = legacy.glowX or 0,
      glowYOffset = legacy.glowY or 0,
    }
  end
  if name == "background" then
    return {
      type = "subtexture",
      textureTexture = WHITE_TEXTURE,
      textureVisible = true,
      textureBlendMode = "BLEND",
      textureColor = legacy.backgroundColor ~= nil and Copy(legacy.backgroundColor) or {0, 0, 0, 0.5},
      anchor_mode = "area",
      anchor_area = "ALL",
    }
  end
  if name == "duration" or name == "stack" or name == "label" or tostring(name):match("^text%d+$") then
    return ConvertText(legacy, name, regionType)
  end
end

function Display.MigrateAppearance(data, legacy)
  if data.regionType == "text" then data.automaticWidth = "Fixed" end
  data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
  local settings = data.blizzardAuraDisplay
  if settings.sharedDisplay then return end
  if type(legacy) == "table" then
    local elements = {{type = "subbackground"}}
    for _, name in ipairs(Display.Elements(legacy)) do
      local converted = ConvertLegacyElement(legacy, name, data.regionType)
      if converted then elements[#elements + 1] = converted end
    end
    data.subRegions = elements
    data.inverse = legacy.reverse ~= false
  elseif data.regionType == "icon" then
    data.inverse = true
  end
  settings.sharedDisplay = true
end

local groupMembers = setmetatable({}, {__mode = "k"})
local memberSequence = 0

local function MasqueLibrary()
  return LibStub and LibStub("Masque", true)
end

local function ReadSkinCorners(icon)
  local function Gather(...)
    return select("#", ...), {...}
  end
  local count, values = Gather(icon:GetTexCoord())
  if count ~= 8 then return nil end
  for index = 1, 8 do
    local value = values[index]
    if IsSecret(value) or type(value) ~= "number" then return nil end
  end
  return values
end

local function SyncMasque(native, group, data)
  local base = native.elementFrames.sharedBase
  local icon = native.icon
  local width, height = Display.Dimensions(data)
  Private.MasquePinSize(base, width, height)
  if group.SetFrameSize then pcall(group.SetFrameSize, group, width, height, base) end
  icon:SetTexCoord(0, 1, 0, 1)
  pcall(group.ReSkin, group, base)
  if group.db and group.db.Disabled then
    native.masqueCoords = nil
    FillOn(icon, base)
  else
    native.masqueCoords = ReadSkinCorners(icon)
  end
  Display.StyleIconTexCoords(native, data)
end

local function ResyncGroup(group)
  local members = groupMembers[group]
  if not members then return end
  local ordered = {}
  for member in pairs(members) do ordered[#ordered + 1] = member end
  table.sort(ordered, function(first, second) return members[first] < members[second] end)
  for _, member in ipairs(ordered) do
    if member.masqueGroup == group and member.masqueData then
      pcall(SyncMasque, member, group, member.masqueData)
    end
  end
end

local function WatchGroup(group)
  if groupMembers[group] then return end
  groupMembers[group] = setmetatable({}, {__mode = "k"})
  local function OnGroupChanged()
    C_Timer.After(0, function() ResyncGroup(group) end)
  end
  pcall(group.RegisterCallback, group, OnGroupChanged)
end

local function DetachMasque(native)
  local group = native.masqueGroup
  if type(group) == "table" then
    local base = native.elementFrames and native.elementFrames.sharedBase
    if base and group.RemoveButton then pcall(group.RemoveButton, group, base) end
    local members = groupMembers[group]
    if members then members[native] = nil end
  end
  native.masqueGroup, native.masqueKey, native.masqueCoords, native.masqueData = nil, nil, nil, nil
end

local function AttachMasque(masque, native, data, key, base)
  local group
  local attached = pcall(function()
    group = masque:Group("WeakAuras", key, data.uid)
    if type(group) ~= "table" then error("Masque group unavailable") end
    group:SetName(tostring(data.id or ""))
    group:AddButton(base, {Icon = native.icon, Cooldown = native.cooldown}, "WA_Aura", true)
  end)
  if not attached then
    if type(group) == "table" and group.RemoveButton then pcall(group.RemoveButton, group, base) end
    return nil
  end
  native.masqueGroup, native.masqueKey = group, key
  WatchGroup(group)
  return group
end

function Display.StyleMasque(native, data)
  local masque = MasqueLibrary()
  if not masque then return end
  local base = native.elementFrames and native.elementFrames.sharedBase
  if not base or data.regionType ~= "icon" or native.remainingHidesIcon then
    DetachMasque(native)
    Display.StyleIconTexCoords(native, data)
    return
  end
  local key = tostring(data.id or ""):lower():gsub(" ", "_")
  if key ~= native.masqueKey or not native.masqueGroup then
    DetachMasque(native)
    if not AttachMasque(masque, native, data, key, base) then
      Display.StyleIconTexCoords(native, data)
      return
    end
  end
  local group = native.masqueGroup
  native.masqueData = data
  local members = groupMembers[group]
  if members and not members[native] then
    memberSequence = memberSequence + 1
    members[native] = memberSequence
  end
  SyncMasque(native, group, data)
end

local function LayoutText(text, mode, fixedWidth, wrap)
  text:SetWidth(mode == "Fixed" and (fixedWidth or 200) or 0)
  local wraps = wrap ~= "Elide"
  text:SetWordWrap(wraps)
  text:SetNonSpaceWrap(wraps)
end

local function BindDuration(pass, text, source, prefix, property, baseColor)
  local data, button = pass.data, pass.button
  local timeFormat = source[prefix .. "time_format"]
  local formatter
  if timeFormat ~= nil and timeFormat ~= -1 and Private.GetDurationTextFormatter then
    formatter = Private.GetDurationTextFormatter(
      source[prefix .. "time_legacy_floor"] and 0 or 99,
      source[prefix .. "time_dynamic_threshold"] or 3,
      source[prefix .. "time_precision"] or 1,
      timeFormat == -2,
      timeFormat
    )
  end
  local window
  if data.regionType == "icon" and Display.RemainingWindow then
    local operator, seconds = Display.RemainingWindow(Display.GetTrigger(data))
    if operator ~= nil then window = {operator, seconds} end
  end
  local color
  if Display.DurationColorCondition then
    color = Display.DurationColorCondition(data, baseColor or {1, 1, 1, 1}, property, window)
  end
  if window and color == nil then return end
  local bound = pcall(button.SetDurationText, button, text, {textFormatter = formatter, textColor = color})
  if not bound and not window then
    button:SetDurationText(text, {textFormatter = formatter})
  end
end

local function BindText(pass, text, content, source, prefix, property, baseColor)
  text:SetText("")
  local kind = Display.TextKind(content)
  local button = pass.button
  if kind == "literal" then
    text:SetText((tostring(content or ""):gsub("%%%%", "%%")))
  elseif kind == "stack" then
    local formatter = Display.StackTextCondition and Display.StackTextCondition(pass.data, property)
    if not (formatter and pcall(button.SetApplicationCount, button, text, {formatter = formatter})) then
      button:SetApplicationCount(text)
    end
  elseif kind == "name" then
    button:SetSpellName(text)
  elseif kind == "duration" then
    BindDuration(pass, text, source, prefix, property, baseColor)
  end
end

local function ReferenceArea(pass, element)
  local native, data = pass.native, pass.data
  if data.regionType == "aurabar" then
    if element.anchor_area == "bar" and native.bar then return native.bar, native.barWidth, native.barHeight end
    if element.anchor_area == "icon" and data.icon == true then return native.icon, native.iconSize, native.iconSize end
  end
  return native.button, pass.width, pass.height
end

local function Place(pass, region, element)
  local defaults = PLACEMENTS[element.type]
  local x, y = element.xOffset or 0, element.yOffset or 0
  region:ClearAllPoints()
  if (element.anchor_mode or defaults.mode) == "area" then
    local zone = ReferenceArea(pass, element)
    region:SetPoint("TOPLEFT", zone, "TOPLEFT", -x / 2, y / 2)
    region:SetPoint("BOTTOMRIGHT", zone, "BOTTOMRIGHT", x / 2, -y / 2)
    return
  end
  local target, point = Display.SplitAnchorTarget(pass.native, pass.native.button, element.anchor_point or defaults.point)
  region:SetPoint(element.self_point or defaults.point, target, point, x, y)
  region:SetSize(element.width or defaults.size, element.height or defaults.size)
end

local function StyleIcon(pass)
  local native, data = pass.native, pass.data
  local icon = native.icon
  FillOn(icon, pass.base)
  icon:SetDesaturated(data.desaturate == true)
  Display.StyleIconTexCoords(native, data)
  local color = data.color
  if data.regionType == "aurabar" then color = data.icon_color end
  icon:SetVertexColor(ColorValues(color, WHITE))
  local custom = data.displayIcon
  if data.iconSource == 0 and custom ~= nil and custom ~= "" then
    icon:SetTexture(custom)
  else
    pass.button:SetIcon(icon)
  end
  icon:Show()
end

local function StyleCooldown(pass)
  local data = pass.data
  local cooldown = pass.native.cooldown
  local settings = type(data.blizzardAuraDisplay) == "table" and data.blizzardAuraDisplay or nil
  cooldown:SetFrameLevel(pass.baseLevel + 1)
  cooldown:SetDrawSwipe(data.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(data.cooldownEdge == true)
  cooldown:SetReverse(data.inverse == true)
  cooldown:SetHideCountdownNumbers(data.cooldownTextDisabled ~= false)
  cooldown:SetSwipeColor(ColorValues(settings and settings.swipeColor, SWIPE))
  cooldown:Show()
  pass.button:SetDurationCooldown(cooldown)
end

local function BarDirection(inverse)
  local directions = Enum and Enum.StatusBarTimerDirection
  if not directions then return nil end
  if inverse then return directions.ElapsedTime end
  return directions.RemainingTime
end

local function StyleBar(pass)
  local native, data, base = pass.native, pass.data, pass.base
  local bar = native.auraBar
  if not bar then
    bar = CreateFrame("StatusBar", nil, base)
    native.auraBar = bar
  end
  bar:SetFrameLevel(pass.baseLevel + 1)
  local file
  if data.textureSource == "LSM" then
    file = FetchMedia("statusbar", data.texture or "Blizzard")
  else
    file = data.textureInput
  end
  if file == nil or file == "" then file = WHITE_TEXTURE end
  bar:SetStatusBarTexture(file)
  bar:SetStatusBarColor(ColorValues(data.barColor, BAR_RED))
  local orientation = tostring(data.orientation or "HORIZONTAL")
  local vertical = orientation:find("VERTICAL", 1, true) ~= nil
  bar:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
  bar:SetReverseFill(orientation:find("INVERSE", 1, true) ~= nil)

  local width, height = pass.width, pass.height
  local withIcon = data.icon == true
  local side, barWidth, barHeight = 0, width, height
  if withIcon and vertical then
    side = width
    barHeight = math.max(SMALLEST_SIZE, height - side)
  elseif withIcon then
    side = height
    barWidth = math.max(SMALLEST_SIZE, width - side)
  end
  native.iconSize, native.barWidth, native.barHeight = side, barWidth, barHeight
  bar:SetSize(barWidth, barHeight)
  bar:ClearAllPoints()
  if withIcon then
    local iconPoint, barPoint
    if data.icon_side == "LEFT" then
      iconPoint, barPoint = vertical and "BOTTOM" or "LEFT", vertical and "TOP" or "RIGHT"
    else
      iconPoint, barPoint = vertical and "TOP" or "RIGHT", vertical and "BOTTOM" or "LEFT"
    end
    local icon = native.icon
    icon:ClearAllPoints()
    icon:SetSize(side, side)
    icon:SetPoint(iconPoint, base, iconPoint)
    bar:SetPoint(barPoint, base, barPoint)
  else
    bar:SetPoint("CENTER", base, "CENTER")
  end

  local background = native.barBackground
  if not background then
    background = base:CreateTexture(nil, "BACKGROUND")
    native.barBackground = background
  end
  FillOn(background, bar)
  background:SetColorTexture(ColorValues(data.backgroundColor, BAR_BACKGROUND))
  pass.button:SetDurationBar(bar, {direction = BarDirection(data.inverse)})
  native.bar = bar
  bar:Show()
  background:Show()
end

local function StyleMainText(pass)
  local native, data = pass.native, pass.data
  local text = native.mainText
  if not text then
    text = pass.base:CreateFontString(nil, "OVERLAY")
    native.mainText = text
  end
  local settings = {
    textFont = data.font,
    textSize = data.fontSize,
    textColor = data.color,
    textOutline = data.outline,
    textJustify = data.justify,
    textShadowColor = data.shadowColor,
    textShadowX = data.shadowXOffset,
    textShadowY = data.shadowYOffset,
  }
  pass.styleText(text, native, settings, "text", 18, "CENTER", 0, 0)
  LayoutText(text, data.automaticWidth, data.fixedWidth, data.wordWrap)
  text:Show()
  BindText(pass, text, data.displayText, data, "displayText_format_p_", "color", data.color)
end

local BORDER_LAYOUT = {
  {cell = 4, corner = "TOPLEFT"},
  {cell = 5, corner = "TOPRIGHT"},
  {cell = 6, corner = "BOTTOMLEFT"},
  {cell = 7, corner = "BOTTOMRIGHT"},
  {cell = 0, side = "LEFT"},
  {cell = 1, side = "RIGHT"},
  {cell = 2, side = "TOP"},
  {cell = 3, side = "BOTTOM"},
}

local function BorderPieces(entry, border)
  if entry.borderPieces then return entry.borderPieces end
  local pieces, biases = {}, {}
  for index = 1, #BORDER_LAYOUT do
    local piece = border:CreateTexture(nil, "BORDER")
    pieces[index] = piece
    biases[index] = piece:GetTexelSnappingBias()
  end
  entry.borderPieces, entry.borderBiases = pieces, biases
  return pieces
end

local function LayoutBorderPiece(piece, layout, border, thickness, repeatX, repeatY)
  local left = layout.cell * 0.125 + 1 / 128
  local right = (layout.cell + 1) * 0.125 - 1 / 128
  piece:ClearAllPoints()
  if layout.corner then
    piece:SetSize(thickness, thickness)
    piece:SetPoint(layout.corner, border, layout.corner)
    piece:SetTexCoord(left, right, 1 / 16, 15 / 16)
  elseif layout.side == "LEFT" or layout.side == "RIGHT" then
    local top, bottom = "TOP" .. layout.side, "BOTTOM" .. layout.side
    piece:SetWidth(thickness)
    piece:SetPoint(top, border, top, 0, -thickness)
    piece:SetPoint(bottom, border, bottom, 0, thickness)
    piece:SetTexCoord(left, right, 1 / 16, repeatY)
  else
    local first, second = layout.side .. "LEFT", layout.side .. "RIGHT"
    piece:SetHeight(thickness)
    piece:SetPoint(first, border, first, thickness, 0)
    piece:SetPoint(second, border, second, -thickness, 0)
    piece:SetTexCoord(left, repeatX, right, repeatX, left, 1 / 16, right, 1 / 16)
  end
end

local function DrawBorder(pass, entry, element)
  local file = FetchMedia("border", element.border_edge or "Square Full White")
  if not file then return end
  local zone, zoneWidth, zoneHeight = ReferenceArea(pass, element)
  local pixelPerfect = element.border_ppscale == true
  local rawOffset = element.border_offset or 0
  local offset, thickness = rawOffset, element.border_size or 2
  if pixelPerfect then
    offset = Round(rawOffset)
    thickness = math.max(1, Round(thickness))
  end
  local areaWidth = math.max(1, zoneWidth + 2 * offset)
  local areaHeight = math.max(1, zoneHeight + 2 * offset)
  if not pixelPerfect then
    thickness = math.min(math.max(thickness, 0.1), areaWidth / 2, areaHeight / 2)
  end

  local border = entry.border
  if not border then
    border = CreateFrame("Frame", nil, entry.frame)
    entry.border = border
  end
  border:ClearAllPoints()
  if pixelPerfect then
    border:SetIgnoreParentScale(true)
    border:SetScale(PixelFactor())
    border:SetPoint("TOPLEFT", zone, "TOPLEFT", -offset, offset)
    border:SetPoint("BOTTOMRIGHT", zone, "BOTTOMRIGHT", offset, -offset)
    border:SetRoundLayoutToNearestPixel(true)
  else
    border:SetIgnoreParentScale(false)
    border:SetScale(1)
    border:SetSize(areaWidth, areaHeight)
    border:SetPoint("CENTER", zone, "CENTER")
    border:SetRoundLayoutToNearestPixel(false)
  end
  border:SetAlpha(element.border_alpha or 1)

  local repeatX = math.max(0, (zoneWidth + 2 * rawOffset) / thickness - 2 - 1 / 16)
  local repeatY = math.max(0, (zoneHeight + 2 * rawOffset) / thickness - 2 - 1 / 16)
  local red, green, blue, alpha = ColorValues(element.border_color, WHITE)
  local pieces = BorderPieces(entry, border)
  for index, piece in ipairs(pieces) do
    piece:SetTexture(file, "REPEAT", "REPEAT")
    piece:SetVertexColor(red, green, blue, alpha)
    piece:SetSnapToPixelGrid(not pixelPerfect)
    piece:SetTexelSnappingBias(pixelPerfect and 0 or entry.borderBiases[index])
    piece:SetRoundLayoutToNearestPixel(pixelPerfect)
    LayoutBorderPiece(piece, BORDER_LAYOUT[index], border, thickness, repeatX, repeatY)
    piece:Show()
  end
  border:Show()
end

local function EntryTexture(entry, layer, subLevel)
  local texture = entry.texture
  if not texture then
    texture = entry.frame:CreateTexture()
    entry.texture = texture
  end
  texture:SetDrawLayer(layer, subLevel)
  return texture
end

local ELEMENT_STYLERS = {}

function ELEMENT_STYLERS.subbackground(pass)
  local native = pass.native
  pass.base:SetFrameLevel(pass.level)
  if native.bar then native.bar:SetFrameLevel(pass.level + 1) end
  if native.cooldown then native.cooldown:SetFrameLevel(pass.level + 1) end
end

function ELEMENT_STYLERS.subforeground(pass)
  if pass.native.bar then pass.native.bar:SetFrameLevel(pass.level) end
end

function ELEMENT_STYLERS.subtext(pass, entry, element, index)
  if element.text_visible == false then return end
  local text = entry.text
  if not text then
    text = entry.frame:CreateFontString(nil, "OVERLAY")
    entry.text = text
  end
  pass.styleText(text, pass.native, Display.TextSettings(element), "text", 18, "CENTER", 0, 0)
  LayoutText(text, element.text_automaticWidth, element.text_fixedWidth, element.text_wordWrap)
  text:SetAlpha(element.text_alpha or 1)
  text:Show()
  BindText(pass, text, element.text_text, element, "text_text_format_p_", "sub." .. index .. ".text_color", element.text_color)
end

function ELEMENT_STYLERS.subborder(pass, entry, element)
  if pass.borderDrawn then return end
  pass.borderDrawn = true
  if element.border_visible == false then return end
  DrawBorder(pass, entry, element)
end

function ELEMENT_STYLERS.subglow(pass, entry, element, index)
  local native, data = pass.native, pass.data
  local anchor, width, height = ReferenceArea(pass, element)
  entry.glowAnchor, entry.glowWidth, entry.glowHeight = anchor, width, height
  local holder
  if Display.TimedGlowHolder then holder = Display.TimedGlowHolder(native, data, index, entry.frame) end
  if holder == nil and Display.PandemicGlowHolder then holder = Display.PandemicGlowHolder(native, data, index, entry.frame) end
  if holder == false then return end
  entry.elementFrames = {glow = entry.frame}
  if holder then
    local forced = Copy(element)
    forced.glow = true
    Display.StyleElementGlow(entry, pass.button, holder, anchor, forced, width, height)
  else
    Display.StyleElementGlow(entry, pass.button, entry.frame, anchor, element, width, height)
  end
end

function ELEMENT_STYLERS.subtexture(pass, entry, element)
  if element.textureVisible == false then return end
  local texture = EntryTexture(entry, "ARTWORK", 0)
  Place(pass, texture, element)
  texture:SetTexture(element.textureTexture)
  texture:SetVertexColor(ColorValues(element.textureColor, WHITE))
  texture:SetDesaturated(element.textureDesaturate == true)
  texture:SetBlendMode(element.textureBlendMode or "BLEND")
  if element.textureMirror then
    texture:SetTexCoord(1, 0, 0, 1)
  else
    texture:SetTexCoord(0, 1, 0, 1)
  end
  texture:SetRotation(math.rad(element.textureRotation or 0))
  texture:SetAlpha(element.texture_alpha or 1)
  texture:Show()
end

function ELEMENT_STYLERS.subcdmdispel(pass, entry, element)
  if element.dispelVisible == false then return end
  local texture = EntryTexture(entry, "OVERLAY", 1)
  Place(pass, texture, element)
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetRotation(0)
  texture:Show()
  local button = pass.button
  if button.AddDispelTypeTexture then
    local styles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
    button:AddDispelTypeTexture(texture, {
      showWhenHelpful = element.showWhenHelpful ~= false,
      showWhenHarmful = element.showWhenHarmful ~= false,
      style = styles and styles.Icon or nil,
    })
  end
end

function ELEMENT_STYLERS.subcdmdispelborder(pass, entry, element)
  if element.dispelVisible == false then return end
  local anchor = entry.dispelAnchor
  if not anchor then
    anchor = CreateFrame("Frame", nil, entry.frame)
    entry.dispelAnchor = anchor
  end
  anchor:Show()
  Place(pass, anchor, element)
  local dispelDisplay = Private.DispelTypeDisplay
  if not entry.dispelEdges then entry.dispelEdges = dispelDisplay.CreateEdges(anchor) end
  dispelDisplay.Layout(entry.dispelEdges, anchor, element)
  if pass.button.AddDispelTypeTexture then dispelDisplay.Bind(pass.button, entry.dispelEdges) end
end

local function ClearEntryContent(entry)
  Hide(entry.text)
  Hide(entry.texture)
  Hide(entry.border)
  Hide(entry.dispelAnchor)
  if entry.borderPieces then
    for _, piece in ipairs(entry.borderPieces) do piece:Hide() end
  end
  local dispelDisplay = Private.DispelTypeDisplay
  if entry.dispelEdges and dispelDisplay and dispelDisplay.Hide then dispelDisplay.Hide(entry.dispelEdges) end
  entry.elementFrames = nil
end

local function ResetNative(native, width, height)
  local button = native.button
  button:SetSize(width, height)
  native.inner:SetSize(width * 0.8, height * 0.8)
  native.outer:SetSize(width * 1.1, height * 1.1)
  for _, name in ipairs(BUTTON_CLEARERS) do
    if button[name] then button[name](button) end
  end
  if not native.preview and button.ClearDispelTypeTextures then button:ClearDispelTypeTextures() end

  for _, frame in pairs(native.elementFrames) do frame:Hide() end
  Hide(native.border)
  Hide(native.icon)
  Hide(native.cooldown)
  Hide(native.bar)
  Hide(native.auraBar)
  Hide(native.barBackground)
  if native.progressTexture then Hide(native.progressTexture.bar) end
  Hide(native.progressBackground)
  Hide(native.mainText)
  native.bar = nil

  native.sharedElements = native.sharedElements or {}
  for _, entry in pairs(native.sharedElements) do
    if entry.glowStale then Display.ClearElementGlow(entry) end
    entry.glowStale = true
  end
  if native.lateGlow then Hide(native.lateGlow.clip) end
  if Display.ResetPandemicGlows then Display.ResetPandemicGlows(native) end
end

local function StyleRegion(pass)
  local data = pass.data
  local regionType = data.regionType
  if regionType == "progresstexture" then
    Private.ProgressTextureNative.StyleAura(pass.native, data, pass.base)
    return
  end
  if regionType == "icon" or (regionType == "aurabar" and data.icon == true) then StyleIcon(pass) end
  if regionType == "icon" and data.cooldown ~= false then StyleCooldown(pass) end
  if regionType == "aurabar" then StyleBar(pass) end
  if regionType == "text" then StyleMainText(pass) end
end

local function StyleElements(pass, resolveElement)
  local native, data = pass.native, pass.data
  local buttonLevel = ReadLevel(pass.button)
  for index, element in ipairs(data.subRegions or {}) do
    local styler = ELEMENT_STYLERS[element.type]
    if styler and not Display.IsDetachedElement(data, element) then
      local level = buttonLevel + 3 * index + 3
      local frame = resolveElement(native, "shared" .. index)
      frame:SetFrameLevel(level)
      frame:SetAlpha(1)
      frame:Show()
      local entry = native.sharedElements[index] or {}
      native.sharedElements[index] = entry
      entry.frame, entry.button, entry.native = frame, pass.button, native
      ClearEntryContent(entry)
      pass.level = level
      styler(pass, entry, element, index)
    end
  end
end

function Display.StyleAppearance(native, data, resolveElement, styleText)
  local width, height = Display.Dimensions(data)
  ResetNative(native, width, height)

  local button = native.button
  local base = resolveElement(native, "sharedBase")
  base:Show()
  base:SetFrameLevel(ReadLevel(button) + 1)

  local pass = {
    native = native, data = data, button = button, base = base, baseLevel = ReadLevel(base),
    width = width, height = height, styleText = styleText,
  }
  StyleRegion(pass)
  StyleElements(pass, resolveElement)

  for _, entry in pairs(native.sharedElements) do
    if entry.glowStale then
      Display.ClearElementGlow(entry)
      entry.glowStale = nil
    end
  end
  Display.StyleNativeConditionIndicators(native, data)
  if Display.StyleRemainingList then Display.StyleRemainingList(native, data) end
  Display.StyleMasque(native, data)
  if Display.StyleDurationGate then Display.StyleDurationGate(native, data) end
end

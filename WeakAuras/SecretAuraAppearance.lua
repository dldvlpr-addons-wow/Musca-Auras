-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local MINIMUM_SIZE = 4

local TEXT_KIND_BY_CODE = {["%p"] = "duration", ["%s"] = "stack", ["%n"] = "name"}

local SUPPORTED_ELEMENTS = {
  subbackground = true, subforeground = true, subtext = true, subborder = true,
  subglow = true, subtexture = true, subcdmdispel = true, subcdmdispelborder = true,
}
Display.supportedElements = SUPPORTED_ELEMENTS

local VALID_GLOW_TYPES = {Proc = true, buttonOverlay = true, Pixel = true, ACShine = true}

local PROBLEMS = {
  codes = "You can only use %p, %s, %n or hardcoded text. Put each code in its own text element. Custom text (%c) is not supported.",
  duplicate = "Secret auras support one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text.",
  unsupported = "This sub element is not supported by Secret Auras. Use Text, Texture or Glow.",
  detached = "Detached Text uses hardcoded text. Use other triggers and Conditions to control when it appears.",
  glow = "Choose Action Button Glow, Pixel Glow, Autocast Shine or Proc Glow.",
}

local NATIVE_BINDINGS_TO_CLEAR = {
  "ClearDurationText", "ClearApplicationCount", "ClearSpellName",
  "ClearDurationBar", "ClearDurationCooldown", "ClearIcon",
}

local TEXT_SETTING_SOURCES = {
  textFont = "text_font", textSize = "text_fontSize", textColor = "text_color", textOutline = "text_fontType",
  textJustify = "text_justify", textShadowColor = "text_shadowColor", textShadowX = "text_shadowXOffset",
  textShadowY = "text_shadowYOffset", textSelfPoint = "text_selfPoint", textAnchor = "anchor_point",
}

local PLACEMENT_DEFAULTS = {
  subtexture = {mode = "area", point = "CENTER", size = 32},
  subcdmdispelborder = {mode = "area", point = "CENTER", size = 32},
  subcdmdispel = {mode = "point", point = "TOPLEFT", size = 16},
}

local DEFAULT_SWIPE_COLOR = {0, 0, 0, 0.8}
local DEFAULT_BAR_COLOR = {1, 0, 0, 1}
local DEFAULT_BAR_BACKGROUND_COLOR = {0, 0, 0, 0.5}
local DEFAULT_BORDER_THICKNESS = 2
local DEFAULT_BORDER_NAME = "Square Full White"

local BORDER_CELL_WIDTH = 0.125
local BORDER_CELL_INSET = 1 / 128
local BORDER_CELL_MARGIN = 1 / 16

local BORDER_PIECES = {
  {cell = 4, shape = "corner", fixed = "both", anchors = {{"TOPLEFT", 0, 0}}},
  {cell = 5, shape = "corner", fixed = "both", anchors = {{"TOPRIGHT", 0, 0}}},
  {cell = 6, shape = "corner", fixed = "both", anchors = {{"BOTTOMLEFT", 0, 0}}},
  {cell = 7, shape = "corner", fixed = "both", anchors = {{"BOTTOMRIGHT", 0, 0}}},
  {cell = 0, shape = "vertical", fixed = "width", anchors = {{"TOPLEFT", 0, -1}, {"BOTTOMLEFT", 0, 1}}},
  {cell = 1, shape = "vertical", fixed = "width", anchors = {{"TOPRIGHT", 0, -1}, {"BOTTOMRIGHT", 0, 1}}},
  {cell = 2, shape = "horizontal", fixed = "height", anchors = {{"TOPLEFT", 1, 0}, {"TOPRIGHT", -1, 0}}},
  {cell = 3, shape = "horizontal", fixed = "height", anchors = {{"BOTTOMLEFT", 1, 0}, {"BOTTOMRIGHT", -1, 0}}},
}

local LEGACY_TEXT_FIELDS = {
  {"Font", "text_font"}, {"Size", "text_fontSize"}, {"Color", "text_color"}, {"Outline", "text_fontType"},
  {"Justify", "text_justify"}, {"ShadowColor", "text_shadowColor"}, {"ShadowX", "text_shadowXOffset"},
  {"ShadowY", "text_shadowYOffset"}, {"Anchor", "anchor_point"}, {"SelfPoint", "text_selfPoint"},
  {"X", "anchorXOffset"}, {"Y", "anchorYOffset"},
}

local masqueGroupMembers = setmetatable({}, {__mode = "k"})
local masqueGroupsWithCallback = setmetatable({}, {__mode = "k"})

local function IsSecret(value)
  return issecretvalue ~= nil and issecretvalue(value) == true
end

local function FrameLevelOf(frame)
  local level = frame:GetFrameLevel()
  if IsSecret(level) or type(level) ~= "number" then return 0 end
  return level
end

local function DeepCopy(value)
  if type(value) ~= "table" then return value end
  local copy = {}
  for key, inner in pairs(value) do copy[key] = DeepCopy(inner) end
  return copy
end

local function RoundToInteger(value)
  return math.floor(value + 0.5)
end

local function PackValues(...)
  return {...}, select("#", ...)
end

local function FindSharedMediaFile(mediaType, name)
  local sharedMedia = LibStub and LibStub("LibSharedMedia-3.0", true)
  if not sharedMedia then return nil end
  return sharedMedia:Fetch(mediaType, name)
end

local function ComputeDimensions(data)
  if data.regionType == "text" then
    local settings = data.blizzardAuraDisplay
    local textHeight = settings and settings.textHeight or 1.2 * (data.fontSize or 18)
    return math.max(MINIMUM_SIZE, data.fixedWidth or 200), math.max(MINIMUM_SIZE, textHeight)
  end
  return math.max(MINIMUM_SIZE, data.width or 64), math.max(MINIMUM_SIZE, data.height or 64)
end
Display.Dimensions = ComputeDimensions

local function ComputeIconTexCoords(data, zoom)
  zoom = zoom or data.zoom or 0
  if data.regionType ~= "icon" then
    local margin = math.min(math.max(zoom / 2, 0), 0.45)
    return margin, 1 - margin, margin, 1 - margin
  end
  local spanX = 1 - zoom / 2
  local spanY = spanX
  if data.keepAspectRatio then
    local width, height = ComputeDimensions(data)
    if width > 0 and height > 0 then
      local ratio = width / height
      if ratio > 1 then
        spanY = spanY / ratio
      else
        spanX = spanX * ratio
      end
    end
  end
  local centerX = 0.5 - (data.texXOffset or 0)
  local centerY = 0.5 + (data.texYOffset or 0)
  return centerX - spanX / 2, centerX + spanX / 2, centerY - spanY / 2, centerY + spanY / 2
end
Display.IconTexCoords = ComputeIconTexCoords

local function ApplyIconTexCoords(native, data, zoom)
  local left, right, top, bottom = ComputeIconTexCoords(data, zoom)
  local skin = native.masqueCoords
  if data.regionType == "icon" and type(skin) == "table" then
    local mapped = {}
    for pair = 1, 4 do
      mapped[pair * 2 - 1] = left + skin[pair * 2 - 1] * (right - left)
      mapped[pair * 2] = top + skin[pair * 2] * (bottom - top)
    end
    native.icon:SetTexCoord(mapped[1], mapped[2], mapped[3], mapped[4], mapped[5], mapped[6], mapped[7], mapped[8])
  else
    native.icon:SetTexCoord(left, right, top, bottom)
  end
end
Display.StyleIconTexCoords = ApplyIconTexCoords

function Private.MasquePinSize(button, width, height)
  if not button then return end
  local config = button._MSQ_CFG
  if not config or width == nil or height == nil then return end
  config.FrameWidth = width
  config.FrameHeight = height
  local owner = config.SetFrameSize and config or button
  if not owner.SetFrameSize or owner.waPinnedSetFrameSize then return end
  local original = owner.SetFrameSize
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

local function IsDetached(data, element)
  local enabled = Display.Enabled(data)
  if not enabled then return enabled end
  if element == nil then return nil end
  if element.secretAuraDetached ~= true then return false end
  return element.type == "subtext" or element.type == "subtexture"
end
Display.IsDetachedElement = IsDetached

function Display.IsDetachedProperty(data, property)
  local index = tostring(property):match("^sub%.(%d+)%..+$")
  if not index or not data.subRegions then return false end
  return IsDetached(data, data.subRegions[tonumber(index)]) == true
end

function Display.CanAddElement(data, kind)
  local enabled = Display.Enabled(data)
  if kind == "subcdmdispel" or kind == "subcdmdispelborder" then
    if enabled then return true end
    local progress = Private.CDMAuraProgress
    return not not (progress and progress.IsConfigured(data))
  end
  if not enabled then return true end
  if not SUPPORTED_ELEMENTS[kind] then return false end
  if kind == "subborder" then
    for _, element in ipairs(data.subRegions or {}) do
      if element.type == "subborder" then return false end
    end
  end
  return true
end

local function ClassifyText(text)
  if text == nil or text == "" then return "literal" end
  if TEXT_KIND_BY_CODE[text] then return TEXT_KIND_BY_CODE[text] end
  local remainder = text:gsub("%%%%", "")
  if remainder:find("%", 1, true) then return nil end
  return "literal"
end
Display.TextKind = ClassifyText

function Display.TextSettings(element)
  local settings = {}
  for settingName, sourceName in pairs(TEXT_SETTING_SOURCES) do
    settings[settingName] = element[sourceName]
  end
  settings.textX = element.text_anchorXOffset
  if settings.textX == nil then settings.textX = element.anchorXOffset end
  settings.textY = element.text_anchorYOffset
  if settings.textY == nil then settings.textY = element.anchorYOffset end
  return settings
end

local function SplitAnchor(native, button, point)
  local prefix = point:sub(1, 6)
  if prefix == "INNER_" then return native.inner, point:sub(7) end
  if prefix == "OUTER_" then return native.outer, point:sub(7) end
  return button, point
end
Display.SplitAnchorTarget = SplitAnchor

function Display.ValidateAppearance(data)
  local reservedKinds = {}

  local function CheckDisplayedText(text)
    local kind = ClassifyText(text)
    if kind == nil then return PROBLEMS.codes end
    if kind == "literal" then return nil end
    if reservedKinds[kind] then return PROBLEMS.duplicate end
    reservedKinds[kind] = true
    return nil
  end

  if data.regionType == "text" then
    local problem = CheckDisplayedText(data.displayText)
    if problem then return problem end
  end

  for _, element in ipairs(data.subRegions or {}) do
    local kind = element.type
    local problem
    if not SUPPORTED_ELEMENTS[kind] then
      problem = PROBLEMS.unsupported
    elseif kind == "subtext" then
      if IsDetached(data, element) then
        if ClassifyText(element.text_text) ~= "literal" then problem = PROBLEMS.detached end
      elseif element.text_visible ~= false then
        problem = CheckDisplayedText(element.text_text)
      end
    elseif kind == "subglow" and element.glow == true then
      if not VALID_GLOW_TYPES[element.glowType or "Proc"] then problem = PROBLEMS.glow end
    end
    if problem then return problem end
  end
  return nil
end

local function BuildLegacyGlow(legacy)
  return {
    type = "subglow",
    glow = legacy.glow == true,
    glowType = legacy.glowType == "pulse" and "buttonOverlay" or "Proc",
    glowColor = DeepCopy(legacy.glowColor) or {1, 0.82, 0, 1},
    useGlowColor = legacy.useGlowColor ~= false,
    glowScale = legacy.glowScale or 1,
    glowDuration = legacy.glowDuration or 1,
    glowXOffset = legacy.glowX or 0,
    glowYOffset = legacy.glowY or 0,
  }
end

local function BuildLegacyBackground(legacy)
  return {
    type = "subtexture",
    textureTexture = WHITE_TEXTURE,
    textureVisible = true,
    textureBlendMode = "BLEND",
    textureColor = DeepCopy(legacy.backgroundColor) or {0, 0, 0, 0.5},
    anchor_mode = "area",
    anchor_area = "ALL",
  }
end

local function BuildLegacyText(legacy, key, regionType)
  local isStack = key == "stack"
  local isLabel = key == "label"
  local anchorPoint = isStack and "BOTTOMRIGHT" or isLabel and "BOTTOM" or "CENTER"
  local fallbacks = {
    Size = isStack and 14 or legacy.fontSize or 18,
    ShadowColor = {0, 0, 0, 0},
    Anchor = anchorPoint,
    SelfPoint = anchorPoint,
    X = isStack and -3 or 0,
    Y = (isStack or isLabel) and 3 or 0,
  }

  local baseSettings = Private.subRegionTypes and Private.subRegionTypes.subtext and Private.subRegionTypes.subtext.default
  if type(baseSettings) == "function" then baseSettings = baseSettings(regionType) end
  local element = DeepCopy(type(baseSettings) == "table" and baseSettings or {})
  element.type = "subtext"

  if key == "duration" then
    element.text_text = "%p"
  elseif isStack then
    element.text_text = "%s"
  else
    element.text_text = (tostring(legacy[key] or ""):gsub("%%", "%%%%"))
  end

  local shown = true
  if key == "duration" then
    shown = legacy.duration ~= false
  elseif isStack then
    shown = legacy.stacks ~= false
  end
  element.text_visible = shown and legacy[key .. "Visible"] ~= false

  for _, field in ipairs(LEGACY_TEXT_FIELDS) do
    local value = legacy[key .. field[1]]
    if value == nil then value = fallbacks[field[1]] end
    if value ~= nil then element[field[2]] = DeepCopy(value) end
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

local function BuildLegacyElement(legacy, name, regionType)
  if name == "glow" then return BuildLegacyGlow(legacy) end
  if name == "background" then return BuildLegacyBackground(legacy) end
  if name == "duration" or name == "stack" or name == "label" or name:match("^text%d+$") then
    return BuildLegacyText(legacy, name, regionType)
  end
  return nil
end

function Display.MigrateAppearance(data, legacy)
  if data.regionType == "text" then data.automaticWidth = "Fixed" end
  data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
  if data.blizzardAuraDisplay.sharedDisplay then return end

  if type(legacy) == "table" then
    local list = {{type = "subbackground"}}
    for _, name in ipairs(Display.Elements(legacy)) do
      local element = BuildLegacyElement(legacy, name, data.regionType)
      if element then list[#list + 1] = element end
    end
    data.subRegions = list
    data.inverse = legacy.reverse ~= false
  elseif data.regionType == "icon" then
    data.inverse = true
  end
  data.blizzardAuraDisplay.sharedDisplay = true
end

local function DetachFromMasque(native)
  local group = native.masqueGroup
  if group then
    local base = native.elementFrames and native.elementFrames.sharedBase
    if base then pcall(group.RemoveButton, group, base) end
    local members = masqueGroupMembers[group]
    if members then members[native] = nil end
  end
  native.masqueGroup = nil
  native.masqueKey = nil
  native.masqueCoords = nil
  native.masqueData = nil
end

local function SynchronizeWithMasque(native, group, data)
  local base = native.elementFrames.sharedBase
  local width, height = ComputeDimensions(data)
  Private.MasquePinSize(base, width, height)
  if group.SetFrameSize then pcall(group.SetFrameSize, group, width, height, base) end
  native.icon:SetTexCoord(0, 1, 0, 1)
  pcall(group.ReSkin, group, base)

  if group.db and group.db.Disabled then
    native.masqueCoords = nil
    native.icon:ClearAllPoints()
    native.icon:SetAllPoints(base)
  else
    local values, count = PackValues(native.icon:GetTexCoord())
    local usable = count == 8
    for index = 1, count do
      if IsSecret(values[index]) then usable = false end
    end
    native.masqueCoords = usable and values or nil
  end
  ApplyIconTexCoords(native, data)
end

local function SynchronizeMasqueGroup(group)
  local members = masqueGroupMembers[group]
  if not members then return end
  for native in pairs(members) do
    if native.masqueGroup == group and native.masqueData then
      pcall(SynchronizeWithMasque, native, group, native.masqueData)
    end
  end
end

local function WatchMasqueGroup(group)
  if masqueGroupsWithCallback[group] then return end
  masqueGroupsWithCallback[group] = true
  pcall(group.RegisterCallback, group, function()
    C_Timer.After(0, function() SynchronizeMasqueGroup(group) end)
  end)
end

function Display.StyleMasque(native, data)
  local masque = LibStub and LibStub("Masque", true)
  if not masque then return end

  local base = native.elementFrames and native.elementFrames.sharedBase
  if not base or data.regionType ~= "icon" or native.remainingHidesIcon then
    DetachFromMasque(native)
    ApplyIconTexCoords(native, data)
    return
  end

  local key = tostring(data.id or ""):lower():gsub(" ", "_")
  if native.masqueKey ~= key then
    DetachFromMasque(native)
    local created, group = pcall(masque.Group, masque, "WeakAuras", key, data.uid)
    local attached = created and type(group) == "table"
    if attached then
      attached = pcall(group.SetName, group, tostring(data.id or ""))
        and pcall(group.AddButton, group, base, {Icon = native.icon, Cooldown = native.cooldown}, "WA_Aura", true)
    end
    if not attached then
      if created and type(group) == "table" then pcall(group.RemoveButton, group, base) end
      ApplyIconTexCoords(native, data)
      return
    end
    native.masqueGroup = group
    native.masqueKey = key
    WatchMasqueGroup(group)
  end

  local group = native.masqueGroup
  native.masqueData = data
  masqueGroupMembers[group] = masqueGroupMembers[group] or setmetatable({}, {__mode = "k"})
  masqueGroupMembers[group][native] = true
  SynchronizeWithMasque(native, group, data)
end

local function EnsureEntry(native, index)
  local entry = native.sharedElements[index]
  if not entry then
    entry = {}
    native.sharedElements[index] = entry
  end
  return entry
end

local function HideIfPresent(region)
  if region then region:Hide() end
end

local function HidePreviousEntryContent(entry)
  HideIfPresent(entry.text)
  HideIfPresent(entry.texture)
  HideIfPresent(entry.border)
  HideIfPresent(entry.dispelAnchor)
  for _, piece in ipairs(entry.borderPieces or {}) do piece:Hide() end
  local dispelDisplay = Private.DispelTypeDisplay
  if entry.dispelEdges and dispelDisplay and dispelDisplay.Hide then dispelDisplay.Hide(entry.dispelEdges) end
  entry.elementFrames = nil
end

local function ResolveElementZone(native, data, element)
  if data.regionType == "aurabar" then
    if element.anchor_area == "bar" and native.bar then
      return native.bar, native.barWidth, native.barHeight
    end
    if element.anchor_area == "icon" and data.icon == true then
      return native.icon, native.iconSize, native.iconSize
    end
  end
  local width, height = ComputeDimensions(data)
  return native.button, width, height
end

local function ApplyTextLayout(fontString, automaticWidth, fixedWidth, wordWrap)
  fontString:SetWidth(automaticWidth == "Fixed" and (fixedWidth or 200) or 0)
  local wraps = wordWrap ~= "Elide"
  fontString:SetWordWrap(wraps)
  fontString:SetNonSpaceWrap(wraps)
end

local function BindDurationText(native, fontString, data, formatSource, formatPrefix, property, baseColor)
  local timeFormat = formatSource[formatPrefix .. "time_format"]
  local formatter
  if timeFormat ~= nil and timeFormat ~= -1 and Private.GetDurationTextFormatter then
    local rounding = formatSource[formatPrefix .. "time_legacy_floor"] and 0 or 99
    formatter = Private.GetDurationTextFormatter(
      rounding,
      formatSource[formatPrefix .. "time_dynamic_threshold"] or 3,
      formatSource[formatPrefix .. "time_precision"] or 1,
      timeFormat == -2,
      timeFormat)
  end

  local window
  if data.regionType == "icon" and Display.RemainingWindow then
    local operator, seconds = Display.RemainingWindow(Display.GetTrigger(data))
    if operator then window = {operator, seconds} end
  end

  local color = Display.DurationColorCondition and Display.DurationColorCondition(data, baseColor, property, window)
  if window and not color then return end

  local button = native.button
  local bound = pcall(button.SetDurationText, button, fontString, {textFormatter = formatter, textColor = color})
  if not bound and not window then
    button:SetDurationText(fontString, {textFormatter = formatter})
  end
end

local function BindTextContent(native, fontString, text, data, formatSource, formatPrefix, property, textColor)
  local button = native.button
  fontString:SetText("")
  local kind = ClassifyText(text)
  if kind == "literal" then
    fontString:SetText((tostring(text or ""):gsub("%%%%", "%%")))
  elseif kind == "duration" then
    BindDurationText(native, fontString, data, formatSource, formatPrefix, property, textColor or {1, 1, 1, 1})
  elseif kind == "stack" then
    local formatter = Display.StackTextCondition and Display.StackTextCondition(data, property)
    local bound = false
    if formatter then
      bound = pcall(button.SetApplicationCount, button, fontString, {formatter = formatter})
    end
    if not bound then button:SetApplicationCount(fontString) end
  elseif kind == "name" then
    button:SetSpellName(fontString)
  end
end

local function ResetNative(native, width, height)
  local button = native.button
  button:SetSize(width, height)
  native.inner:SetSize(0.8 * width, 0.8 * height)
  native.outer:SetSize(1.1 * width, 1.1 * height)

  for _, methodName in ipairs(NATIVE_BINDINGS_TO_CLEAR) do button[methodName](button) end
  if not native.preview and button.ClearDispelTypeTextures then button:ClearDispelTypeTextures() end

  for _, frame in pairs(native.elementFrames) do frame:Hide() end
  HideIfPresent(native.border)
  HideIfPresent(native.icon)
  HideIfPresent(native.cooldown)
  HideIfPresent(native.bar)
  HideIfPresent(native.auraBar)
  HideIfPresent(native.barBackground)
  HideIfPresent(native.progressTexture and native.progressTexture.bar)
  HideIfPresent(native.progressBackground)
  HideIfPresent(native.mainText)
  native.bar = nil

  native.sharedElements = native.sharedElements or {}
  for _, entry in pairs(native.sharedElements) do
    if entry.glowStale then Display.ClearElementGlow(entry) end
    entry.glowStale = true
  end

  if native.lateGlow then HideIfPresent(native.lateGlow.clip) end
  if Display.ResetPandemicGlows then Display.ResetPandemicGlows(native) end
end

local function StyleIconRegion(native, data, base)
  local icon = native.icon
  icon:ClearAllPoints()
  icon:SetAllPoints(base)
  icon:SetDesaturated(data.desaturate == true)
  ApplyIconTexCoords(native, data)
  local color = (data.regionType == "aurabar" and data.icon_color or data.color) or {1, 1, 1, 1}
  icon:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
  if data.iconSource == 0 and data.displayIcon ~= nil and data.displayIcon ~= "" then
    icon:SetTexture(data.displayIcon)
  else
    native.button:SetIcon(icon)
  end
  icon:Show()
end

local function StyleCooldownRegion(native, data, baseLevel)
  local cooldown = native.cooldown
  local settings = data.blizzardAuraDisplay
  local swipe = settings and settings.swipeColor or DEFAULT_SWIPE_COLOR
  cooldown:SetFrameLevel(baseLevel + 1)
  cooldown:SetDrawSwipe(data.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(data.cooldownEdge == true)
  cooldown:SetReverse(data.inverse == true)
  cooldown:SetHideCountdownNumbers(data.cooldownTextDisabled ~= false)
  cooldown:SetSwipeColor(swipe[1], swipe[2], swipe[3], swipe[4] or 1)
  cooldown:Show()
  native.button:SetDurationCooldown(cooldown)
end

local function StyleAuraBar(native, data, base, width, height, baseLevel)
  local bar = native.auraBar
  if not bar then
    bar = CreateFrame("StatusBar", nil, base)
    native.auraBar = bar
  end
  bar:SetFrameLevel(baseLevel + 1)

  local texturePath
  if data.textureSource == "LSM" then
    texturePath = FindSharedMediaFile("statusbar", data.texture or "Blizzard")
  else
    texturePath = data.textureInput
  end
  bar:SetStatusBarTexture(texturePath or WHITE_TEXTURE)
  local color = data.barColor or DEFAULT_BAR_COLOR
  bar:SetStatusBarColor(color[1], color[2], color[3], color[4] or 1)

  local orientation = data.orientation or "HORIZONTAL"
  local vertical = orientation:find("VERTICAL", 1, true) ~= nil
  bar:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
  bar:SetReverseFill(orientation:find("INVERSE", 1, true) ~= nil)

  local hasIcon = data.icon == true
  local iconSide = 0
  if hasIcon then iconSide = vertical and width or height end
  local barWidth = vertical and width or math.max(MINIMUM_SIZE, width - iconSide)
  local barHeight = vertical and math.max(MINIMUM_SIZE, height - iconSide) or height
  native.iconSize, native.barWidth, native.barHeight = iconSide, barWidth, barHeight

  bar:ClearAllPoints()
  bar:SetSize(barWidth, barHeight)
  if hasIcon then
    local icon = native.icon
    local iconFirst = data.icon_side == "LEFT"
    icon:ClearAllPoints()
    icon:SetSize(iconSide, iconSide)
    if vertical then
      icon:SetPoint(iconFirst and "BOTTOM" or "TOP", base, iconFirst and "BOTTOM" or "TOP")
      bar:SetPoint(iconFirst and "TOP" or "BOTTOM", base, iconFirst and "TOP" or "BOTTOM")
    else
      icon:SetPoint(iconFirst and "LEFT" or "RIGHT", base, iconFirst and "LEFT" or "RIGHT")
      bar:SetPoint(iconFirst and "RIGHT" or "LEFT", base, iconFirst and "RIGHT" or "LEFT")
    end
  else
    bar:SetPoint("CENTER", base, "CENTER")
  end

  local background = native.barBackground
  if not background then
    background = base:CreateTexture(nil, "BACKGROUND")
    native.barBackground = background
  end
  local backgroundColor = data.backgroundColor or DEFAULT_BAR_BACKGROUND_COLOR
  background:ClearAllPoints()
  background:SetAllPoints(bar)
  background:SetColorTexture(backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4] or 1)

  local directions = Enum and Enum.StatusBarTimerDirection or {}
  native.button:SetDurationBar(bar, {direction = data.inverse and directions.ElapsedTime or directions.RemainingTime})
  native.bar = bar
  bar:Show()
  background:Show()
end

local function StyleMainText(native, data, base)
  local text = native.mainText
  if not text then
    text = base:CreateFontString(nil, "OVERLAY")
    native.mainText = text
  end
  local settings = {
    textFont = data.font, textSize = data.fontSize, textColor = data.color, textOutline = data.outline,
    textJustify = data.justify, textShadowColor = data.shadowColor, textShadowX = data.shadowXOffset,
    textShadowY = data.shadowYOffset,
  }
  return text, settings
end

local function PlaceRegion(region, native, element, kind, zone)
  local defaults = PLACEMENT_DEFAULTS[kind]
  local offsetX, offsetY = element.xOffset or 0, element.yOffset or 0
  region:ClearAllPoints()
  if (element.anchor_mode or defaults.mode) == "area" then
    region:SetPoint("TOPLEFT", zone, "TOPLEFT", -offsetX / 2, offsetY / 2)
    region:SetPoint("BOTTOMRIGHT", zone, "BOTTOMRIGHT", offsetX / 2, -offsetY / 2)
  else
    local target, targetPoint = SplitAnchor(native, native.button, element.anchor_point or defaults.point)
    region:SetPoint(element.self_point or defaults.point, target, targetPoint, offsetX, offsetY)
    region:SetSize(element.width or defaults.size, element.height or defaults.size)
  end
end

local function EnsureTexture(entry, layer, subLevel)
  if not entry.texture then
    entry.texture = entry.frame:CreateTexture(nil, layer)
  end
  entry.texture:SetDrawLayer(layer, subLevel)
  return entry.texture
end

local function ComputeBorderCoordinates(piece, repeatAlongX, repeatAlongY)
  local left = piece.cell * BORDER_CELL_WIDTH + BORDER_CELL_INSET
  local right = (piece.cell + 1) * BORDER_CELL_WIDTH - BORDER_CELL_INSET
  local edge = BORDER_CELL_MARGIN
  if piece.shape == "vertical" then
    return left, edge, left, repeatAlongY, right, edge, right, repeatAlongY
  elseif piece.shape == "horizontal" then
    return left, repeatAlongX, right, repeatAlongX, left, edge, right, edge
  end
  return left, edge, left, 1 - edge, right, edge, right, 1 - edge
end

local function StyleBorderElement(entry, element, zone, zoneWidth, zoneHeight)
  local file = FindSharedMediaFile("border", element.border_edge or DEFAULT_BORDER_NAME)
  if not file then return end

  local pixelPerfect = element.border_ppscale == true
  local rawOffset = element.border_offset or 0
  local offset = rawOffset
  local thickness = element.border_size or DEFAULT_BORDER_THICKNESS
  if pixelPerfect then
    offset = RoundToInteger(offset)
    thickness = math.max(1, RoundToInteger(thickness))
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
  border:SetIgnoreParentScale(pixelPerfect)
  border:SetRoundLayoutToNearestPixel(pixelPerfect)
  if pixelPerfect then
    border:SetScale(PixelUtil.GetPixelToUIUnitFactor())
    border:SetPoint("TOPLEFT", zone, "TOPLEFT", -offset, offset)
    border:SetPoint("BOTTOMRIGHT", zone, "BOTTOMRIGHT", offset, -offset)
  else
    border:SetScale(1)
    border:SetSize(areaWidth, areaHeight)
    border:SetPoint("CENTER", zone, "CENTER")
  end
  border:SetAlpha(element.border_alpha or 1)

  entry.borderPieces = entry.borderPieces or {}
  entry.borderBiases = entry.borderBiases or {}
  local color = element.border_color or {1, 1, 1, 1}
  local repeatAlongX = math.max(0, (zoneWidth + 2 * rawOffset) / thickness - 2 - BORDER_CELL_MARGIN)
  local repeatAlongY = math.max(0, (zoneHeight + 2 * rawOffset) / thickness - 2 - BORDER_CELL_MARGIN)

  for index, piece in ipairs(BORDER_PIECES) do
    local texture = entry.borderPieces[index]
    if not texture then
      texture = border:CreateTexture(nil, "BORDER")
      entry.borderPieces[index] = texture
      entry.borderBiases[index] = texture:GetTexelSnappingBias()
    end
    texture:SetTexture(file, "REPEAT", "REPEAT")
    texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    texture:SetSnapToPixelGrid(not pixelPerfect)
    texture:SetTexelSnappingBias(pixelPerfect and 0 or entry.borderBiases[index])
    texture:SetRoundLayoutToNearestPixel(pixelPerfect)
    texture:SetTexCoord(ComputeBorderCoordinates(piece, repeatAlongX, repeatAlongY))
    texture:ClearAllPoints()
    for _, anchor in ipairs(piece.anchors) do
      texture:SetPoint(anchor[1], border, anchor[1], anchor[2] * thickness, anchor[3] * thickness)
    end
    if piece.fixed == "width" or piece.fixed == "both" then texture:SetWidth(thickness) end
    if piece.fixed == "height" or piece.fixed == "both" then texture:SetHeight(thickness) end
    texture:Show()
  end
  border:Show()
end

local ELEMENT_STYLERS = {}

ELEMENT_STYLERS.subbackground = function(pass, _, _, _, level)
  pass.base:SetFrameLevel(level)
  if pass.native.bar then pass.native.bar:SetFrameLevel(level + 1) end
  if pass.native.cooldown then pass.native.cooldown:SetFrameLevel(level + 1) end
end

ELEMENT_STYLERS.subforeground = function(pass, _, _, _, level)
  if pass.native.bar then pass.native.bar:SetFrameLevel(level) end
end

ELEMENT_STYLERS.subtext = function(pass, entry, element, index)
  if element.text_visible == false then return end
  local native, data = pass.native, pass.data
  local fontString = entry.text
  if not fontString then
    fontString = entry.frame:CreateFontString(nil, "OVERLAY")
    entry.text = fontString
  end
  pass.styleText(fontString, native, Display.TextSettings(element), "text", 18, "CENTER", 0, 0)
  ApplyTextLayout(fontString, element.text_automaticWidth, element.text_fixedWidth, element.text_wordWrap)
  fontString:SetAlpha(element.text_alpha or 1)
  fontString:Show()
  BindTextContent(native, fontString, element.text_text, data, element, "text_text_format_p_",
    "sub." .. index .. ".text_color", element.text_color)
end

ELEMENT_STYLERS.subborder = function(pass, entry, element)
  if pass.borderHandled then return end
  pass.borderHandled = true
  if element.border_visible == false then return end
  local zone, zoneWidth, zoneHeight = ResolveElementZone(pass.native, pass.data, element)
  StyleBorderElement(entry, element, zone, zoneWidth, zoneHeight)
end

ELEMENT_STYLERS.subglow = function(pass, entry, element, index)
  local native, data = pass.native, pass.data
  entry.glowAnchor, entry.glowWidth, entry.glowHeight = ResolveElementZone(native, data, element)

  local support
  if Display.TimedGlowHolder then support = Display.TimedGlowHolder(native, data, index, entry.frame) end
  if support == nil and Display.PandemicGlowHolder then
    support = Display.PandemicGlowHolder(native, data, index, entry.frame)
  end
  if support == false then return end

  entry.elementFrames = {glow = entry.frame}
  if support then
    local forcedGlow = DeepCopy(element)
    forcedGlow.glow = true
    Display.StyleElementGlow(entry, native.button, support, entry.glowAnchor, forcedGlow, entry.glowWidth, entry.glowHeight)
  else
    Display.StyleElementGlow(entry, native.button, entry.frame, entry.glowAnchor, element, entry.glowWidth, entry.glowHeight)
  end
end

ELEMENT_STYLERS.subtexture = function(pass, entry, element)
  if element.textureVisible == false then return end
  local native = pass.native
  local texture = EnsureTexture(entry, "ARTWORK", 0)
  local zone = ResolveElementZone(native, pass.data, element)
  local color = element.textureColor or {1, 1, 1, 1}
  PlaceRegion(texture, native, element, "subtexture", zone)
  texture:SetTexture(element.textureTexture)
  texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
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

ELEMENT_STYLERS.subcdmdispel = function(pass, entry, element)
  if element.dispelVisible == false then return end
  local native = pass.native
  local texture = EnsureTexture(entry, "OVERLAY", 1)
  local zone = ResolveElementZone(native, pass.data, element)
  PlaceRegion(texture, native, element, "subcdmdispel", zone)
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetRotation(0)
  texture:Show()
  if native.button.AddDispelTypeTexture then
    local styles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
    native.button:AddDispelTypeTexture(texture, {
      showWhenHelpful = element.showWhenHelpful ~= false,
      showWhenHarmful = element.showWhenHarmful ~= false,
      style = styles and styles.Icon,
    })
  end
end

ELEMENT_STYLERS.subcdmdispelborder = function(pass, entry, element)
  if element.dispelVisible == false then return end
  local native = pass.native
  local anchor = entry.dispelAnchor
  if not anchor then
    anchor = CreateFrame("Frame", nil, entry.frame)
    entry.dispelAnchor = anchor
  end
  anchor:Show()
  local zone = ResolveElementZone(native, pass.data, element)
  PlaceRegion(anchor, native, element, "subcdmdispelborder", zone)
  local dispelDisplay = Private.DispelTypeDisplay
  entry.dispelEdges = entry.dispelEdges or dispelDisplay.CreateEdges(anchor)
  dispelDisplay.Layout(entry.dispelEdges, anchor, element)
  if native.button.AddDispelTypeTexture then dispelDisplay.Bind(native.button, entry.dispelEdges) end
end

local function StyleSubElements(pass)
  local native, data = pass.native, pass.data
  local buttonLevel = FrameLevelOf(native.button)
  for index, element in ipairs(data.subRegions or {}) do
    local styler = ELEMENT_STYLERS[element.type]
    if styler and not IsDetached(data, element) then
      local level = buttonLevel + 3 * index + 3
      local frame = pass.resolveElement(native, "shared" .. index)
      frame:SetFrameLevel(level)
      frame:SetAlpha(1)
      frame:Show()
      local entry = EnsureEntry(native, index)
      entry.frame, entry.button, entry.native = frame, native.button, native
      HidePreviousEntryContent(entry)
      styler(pass, entry, element, index, level)
    end
  end
end

function Display.StyleAppearance(native, data, resolveElement, styleText)
  local width, height = ComputeDimensions(data)
  ResetNative(native, width, height)

  local regionType = data.regionType
  local base = resolveElement(native, "sharedBase")
  local baseLevel = FrameLevelOf(native.button) + 1
  base:Show()
  base:SetFrameLevel(baseLevel)
  baseLevel = FrameLevelOf(base)

  local pass = {
    native = native, data = data, base = base,
    resolveElement = resolveElement, styleText = styleText, borderHandled = false,
  }

  if regionType == "icon" or (regionType == "aurabar" and data.icon == true) then
    StyleIconRegion(native, data, base)
  end
  if regionType == "icon" and data.cooldown ~= false then
    StyleCooldownRegion(native, data, baseLevel)
  end
  if regionType == "progresstexture" then
    Private.ProgressTextureNative.StyleAura(native, data, base)
  elseif regionType == "aurabar" then
    StyleAuraBar(native, data, base, width, height, baseLevel)
  elseif regionType == "text" then
    local text, settings = StyleMainText(native, data, base)
    styleText(text, native, settings, "text", 18, "CENTER", 0, 0)
    ApplyTextLayout(text, data.automaticWidth, data.fixedWidth, data.wordWrap)
    text:Show()
    BindTextContent(native, text, data.displayText, data, data, "displayText_format_p_", "color", data.color)
  end

  StyleSubElements(pass)

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

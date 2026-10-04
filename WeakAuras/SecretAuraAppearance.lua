if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay
local SharedMedia = LibStub("LibSharedMedia-3.0")

local ANCHOR_INNER = "INNER_"
local ANCHOR_OUTER = "OUTER_"
local ANCHOR_PREFIX_LENGTH = 6

function Display.IconTexCoords(data, zoom)
  zoom = zoom or data.zoom or 0
  if data.regionType ~= "icon" then
    local inset = math.min(0.45, math.max(0, zoom / 2))
    return inset, 1 - inset, inset, 1 - inset
  end
  local width, height = Display.Dimensions(data)
  local ratio = 1
  if data.keepAspectRatio and width > 0 and height > 0 then
    ratio = width / height
  end
  local visible = 1 - 0.5 * zoom
  local spanX = visible * (ratio < 1 and ratio or 1)
  local spanY = visible * (ratio > 1 and 1 / ratio or 1)
  local shiftX = data.texXOffset or 0
  local shiftY = data.texYOffset or 0
  return 0.5 - spanX / 2 - shiftX, 0.5 + spanX / 2 - shiftX, 0.5 - spanY / 2 + shiftY, 0.5 + spanY / 2 + shiftY
end

function Display.StyleIconTexCoords(native, data, zoom)
  local skinCoords = data.regionType == "icon" and native.masqueCoords
  if not skinCoords then
    native.icon:SetTexCoord(Display.IconTexCoords(data, zoom))
    return
  end
  local left, right, top, bottom = Display.IconTexCoords(data, zoom)
  local spanX, spanY = right - left, bottom - top
  local midX, midY = (left + right) / 2, (top + bottom) / 2
  local mapped = {}
  for pair = 1, 4 do
    mapped[pair * 2 - 1] = (skinCoords[pair * 2 - 1] - 0.5) * spanX + midX
    mapped[pair * 2] = (skinCoords[pair * 2] - 0.5) * spanY + midY
  end
  native.icon:SetTexCoord(unpack(mapped, 1, 8))
end

local Masque = LibStub("Masque", true)
local membersByGroup = setmetatable({}, {__mode = "k"})

local function HasSecretCoords(coords)
  for slot = 1, 8 do
    if issecretvalue(coords[slot]) then
      return true
    end
  end
  return false
end

local function SyncMasqueCrop(native, group)
  local baseFrame = native.elementFrames.sharedBase
  if group.db and not group.db.Disabled then
    native.masqueCoords = native.masqueCoords or {}
    local coords = native.masqueCoords
    local fresh = {native.icon:GetTexCoord()}
    for slot = 1, 8 do
      coords[slot] = fresh[slot]
    end
    if HasSecretCoords(coords) then
      native.masqueCoords = nil
    end
  else
    native.masqueCoords = nil
    native.icon:ClearAllPoints()
    native.icon:SetAllPoints(baseFrame)
  end
  Display.StyleIconTexCoords(native, native.masqueData)
end

local function OnMasqueGroupChanged(group)
  C_Timer.After(0, function()
    for native in pairs(membersByGroup[group] or {}) do
      if native.masqueGroup == group then
        pcall(SyncMasqueCrop, native, group)
      end
    end
  end)
end

local function DetachFromMasque(native)
  local group = native.masqueGroup
  if not group then
    return
  end
  group:RemoveButton(native.elementFrames.sharedBase)
  if membersByGroup[group] then
    membersByGroup[group][native] = nil
  end
  native.masqueGroup = nil
  native.masqueCoords = nil
  native.masqueData = nil
end

local function AttachToMasque(native, data, baseFrame)
  local groupKey = data.id:lower():gsub(" ", "_")
  local group = Masque:Group("WeakAuras", groupKey, data.uid)
  if native.masqueGroup ~= group then
    DetachFromMasque(native)
    group:SetName(data.id)
    group:AddButton(baseFrame, {Icon = native.icon, Cooldown = native.cooldown}, "WA_Aura", true)
    native.masqueGroup = group
    if not membersByGroup[group] then
      membersByGroup[group] = setmetatable({}, {__mode = "k"})
      group:RegisterCallback(OnMasqueGroupChanged)
    end
    membersByGroup[group][native] = true
  end
  native.masqueData = data
  local width, height = Display.Dimensions(data)
  if group.SetFrameSize then
    group:SetFrameSize(width, height, baseFrame)
  end
  group:ReSkin(baseFrame)
  SyncMasqueCrop(native, group)
end

function Display.StyleMasque(native, data)
  if not Masque then
    return
  end
  local baseFrame = native.elementFrames and native.elementFrames.sharedBase
  local drawsIcon = data.regionType == "icon" and not native.remainingHidesIcon
  if baseFrame and drawsIcon and pcall(AttachToMasque, native, data, baseFrame) then
    return
  end
  if baseFrame then
    pcall(DetachFromMasque, native)
    native.masqueGroup = nil
    native.masqueCoords = nil
    native.masqueData = nil
    Display.StyleIconTexCoords(native, data)
  end
end

Display.supportedElements = {
  subbackground = true,
  subforeground = true,
  subtext = true,
  subborder = true,
  subglow = true,
  subtexture = true,
  subcdmdispel = true,
  subcdmdispelborder = true,
}

function Display.IsDetachedElement(data, element)
  local enabled = Display.Enabled(data)
  if not enabled then
    return enabled
  end
  if not element then
    return element
  end
  if element.secretAuraDetached ~= true then
    return false
  end
  return element.type == "subtext" or element.type == "subtexture"
end

function Display.IsDetachedProperty(data, property)
  local position = property:match("^sub%.(%d+)%.")
  if not position then
    return false
  end
  local subRegions = data.subRegions
  return Display.IsDetachedElement(data, subRegions and subRegions[tonumber(position)]) or false
end

function Display.CanAddElement(data, kind)
  if kind == "subcdmdispel" or kind == "subcdmdispelborder" then
    return Display.Enabled(data) or Private.CDMAuraProgress.IsConfigured(data)
  end
  if not Display.Enabled(data) then
    return true
  end
  if not Display.supportedElements[kind] then
    return false
  end
  if kind == "subborder" then
    for _, existing in ipairs(data.subRegions or {}) do
      if existing.type == "subborder" then
        return false
      end
    end
  end
  return true
end

local function NewTextElement(regionType)
  local template = Private.subRegionTypes.subtext.default
  local element
  if type(template) == "function" then
    element = template(regionType)
  else
    element = CopyTable(template)
  end
  element.type = "subtext"
  return element
end

local LEGACY_TEXT_FIELDS = {
  Font = "text_font",
  Size = "text_fontSize",
  Color = "text_color",
  Outline = "text_fontType",
  Justify = "text_justify",
  ShadowColor = "text_shadowColor",
  ShadowX = "text_shadowXOffset",
  ShadowY = "text_shadowYOffset",
  SelfPoint = "text_selfPoint",
  Anchor = "anchor_point",
  X = "anchorXOffset",
  Y = "anchorYOffset",
}

local function ConvertLegacyText(data, legacy, key)
  local element = NewTextElement(data.regionType)
  local isDuration = key == "duration"
  local isStack = key == "stack"
  element.text_text = isDuration and "%p" or isStack and "%s" or legacy[key] or ""
  if not isDuration and not isStack then
    element.text_text = element.text_text:gsub("%%", "%%%%")
  end
  element.text_visible = (not isDuration or legacy.duration ~= false)
    and (not isStack or legacy.stacks ~= false)
    and legacy[key .. "Visible"] ~= false
  for suffix, field in pairs(LEGACY_TEXT_FIELDS) do
    local value = legacy[key .. suffix]
    if value ~= nil then
      if type(value) == "table" then
        element[field] = CopyTable(value)
      else
        element[field] = value
      end
    end
  end
  local defaultAnchor = isStack and "BOTTOMRIGHT" or key == "label" and "BOTTOM" or "CENTER"
  element.anchor_point = legacy[key .. "Anchor"] or defaultAnchor
  element.text_selfPoint = legacy[key .. "SelfPoint"] or defaultAnchor
  element.anchorXOffset = legacy[key .. "X"] or (isStack and -3 or 0)
  element.anchorYOffset = legacy[key .. "Y"] or ((isStack or key == "label") and 3 or 0)
  element.text_fontSize = legacy[key .. "Size"] or (isStack and 14 or legacy.fontSize or 18)
  element.text_shadowColor = CopyTable(legacy[key .. "ShadowColor"] or {0, 0, 0, 0})
  if isDuration then
    local format = legacy.durationFormat
    element.text_text_format_p_format = "timed"
    element.text_text_format_p_time_format = format == "clock" and 0 or format == "seconds" and -2 or -1
    element.text_text_format_p_time_precision = legacy.durationPrecision or 1
    element.text_text_format_p_time_dynamic_threshold = legacy.durationDecimalThreshold or 3
    element.text_text_format_p_time_legacy_floor = legacy.durationRoundUp == false
  end
  return element
end

local function ConvertLegacyGlow(legacy)
  return {
    type = "subglow",
    glow = legacy.glow == true,
    glowType = legacy.glowType == "pulse" and "buttonOverlay" or "Proc",
    glowColor = CopyTable(legacy.glowColor or {1, 0.82, 0, 1}),
    useGlowColor = legacy.useGlowColor ~= false,
    glowScale = legacy.glowScale or 1,
    glowDuration = legacy.glowDuration or 1,
    glowXOffset = legacy.glowX or 0,
    glowYOffset = legacy.glowY or 0,
  }
end

local function ConvertLegacyBackground(legacy)
  return {
    type = "subtexture",
    textureVisible = true,
    textureTexture = "Interface\\Buttons\\WHITE8X8",
    textureColor = CopyTable(legacy.backgroundColor or {0, 0, 0, 0.5}),
    textureBlendMode = "BLEND",
    anchor_mode = "area",
    anchor_area = "ALL",
  }
end

local function ConvertLegacyElement(data, legacy, key)
  if key == "duration" or key == "stack" or key == "label" or key:match("^text%d+$") then
    return ConvertLegacyText(data, legacy, key)
  elseif key == "glow" then
    return ConvertLegacyGlow(legacy)
  elseif key == "background" then
    return ConvertLegacyBackground(legacy)
  end
end

function Display.MigrateAppearance(data, legacy)
  local settings = data.blizzardAuraDisplay
  if data.regionType == "text" then
    data.automaticWidth = "Fixed"
  end
  if settings.sharedDisplay then
    return
  end
  if legacy then
    local converted = {{type = "subbackground"}}
    for _, key in ipairs(Display.Elements(legacy)) do
      local element = ConvertLegacyElement(data, legacy, key)
      if element then
        converted[#converted + 1] = element
      end
    end
    data.subRegions = converted
    data.inverse = legacy.reverse ~= false
  elseif data.regionType == "icon" then
    data.inverse = true
  end
  settings.sharedDisplay = true
end

function Display.Dimensions(data)
  if data.regionType == "text" then
    local textWidth = math.max(4, data.fixedWidth or 200)
    local textHeight = math.max(4, data.blizzardAuraDisplay.textHeight or (data.fontSize or 18) * 1.2)
    return textWidth, textHeight
  end
  return math.max(4, data.width or 64), math.max(4, data.height or 64)
end

local TEXT_CODE_KINDS = {["%p"] = "duration", ["%s"] = "stack", ["%n"] = "name"}

function Display.TextKind(value)
  local known = TEXT_CODE_KINDS[value]
  if known then
    return known
  end
  local stripped = (value or ""):gsub("%%%%", "")
  if not stripped:find("%%") then
    return "literal"
  end
end

local MESSAGE_TEXT_CODES = "You can only use %p, %s, %n or hardcoded text. Put each code in its own text element. Custom text (%c) is not supported."
local MESSAGE_TEXT_DUPLICATE = "Secret auras support one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text."
local MESSAGE_ELEMENT_UNSUPPORTED = "This sub element is not supported by Secret Auras. Use Text, Texture or Glow."
local MESSAGE_DETACHED_TEXT = "Detached Text uses hardcoded text. Use other triggers and Conditions to control when it appears."
local MESSAGE_GLOW_TYPE = "Choose Action Button Glow, Pixel Glow, Autocast Shine or Proc Glow."
local VALID_GLOW_TYPES = {Proc = true, buttonOverlay = true, Pixel = true, ACShine = true}

local function CheckTextCode(claimed, value, visible)
  if visible == false then
    return
  end
  local kind = Display.TextKind(value)
  if not kind then
    return MESSAGE_TEXT_CODES
  end
  if kind ~= "literal" and claimed[kind] then
    return MESSAGE_TEXT_DUPLICATE
  end
  claimed[kind] = true
end

function Display.ValidateAppearance(data)
  local claimed = {}
  if data.regionType == "text" then
    local problem = CheckTextCode(claimed, data.displayText)
    if problem then
      return problem
    end
  end
  for _, element in ipairs(data.subRegions or {}) do
    local elementType = element.type
    if elementType ~= "subborder" and not Display.supportedElements[elementType] then
      return MESSAGE_ELEMENT_UNSUPPORTED
    end
    if Display.IsDetachedElement(data, element) then
      if elementType == "subtext" and Display.TextKind(element.text_text) ~= "literal" then
        return MESSAGE_DETACHED_TEXT
      end
    elseif elementType == "subtext" then
      local problem = CheckTextCode(claimed, element.text_text, element.text_visible)
      if problem then
        return problem
      end
    elseif elementType == "subglow" and element.glow and not VALID_GLOW_TYPES[element.glowType or "Proc"] then
      return MESSAGE_GLOW_TYPE
    end
  end
end

local function TextSettings(element)
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
    textX = element.text_anchorXOffset or element.anchorXOffset,
    textY = element.text_anchorYOffset or element.anchorYOffset,
  }
end

Display.TextSettings = TextSettings

local function BindDurationText(button, text, config, prefix, data, baseColor, property, window)
  local format = config[prefix .. "p_time_format"]
  local options
  if format ~= nil and format ~= -1 then
    local floorMode = config[prefix .. "p_time_legacy_floor"] and 0 or 99
    local threshold = config[prefix .. "p_time_dynamic_threshold"] or 3
    local precision = config[prefix .. "p_time_precision"] or 1
    options = {textFormatter = Private.GetDurationTextFormatter(floorMode, threshold, precision, format == -2)}
  end
  local color = Display.DurationColorCondition(data, baseColor, property, window)
  if color then
    options = options or {}
    options.textColor = color
    if pcall(button.SetDurationText, button, text, options) then
      return
    end
    options.textColor = nil
  end
  if window then
    return
  end
  button:SetDurationText(text, options)
end

local function BindStackText(button, text, data, property)
  local formatter = Display.StackTextCondition(data, property)
  if formatter and pcall(button.SetApplicationCount, button, text, {formatter = formatter}) then
    return
  end
  button:SetApplicationCount(text)
end

local function BindText(button, text, value, config, prefix, data, baseColor, property, window)
  local kind = Display.TextKind(value)
  if not window and kind == "duration" and data.regionType == "icon" and Display.RemainingWindow then
    local comparison, seconds = Display.RemainingWindow(Display.GetTrigger(data))
    if comparison then
      window = {comparison, seconds}
    end
  end
  if kind == "duration" then
    BindDurationText(button, text, config, prefix, data, baseColor, property, window)
  elseif kind == "stack" then
    BindStackText(button, text, data, property)
  elseif kind == "name" then
    button:SetSpellName(text)
  else
    text:SetText((value or ""):gsub("%%%%", "%%"))
  end
end

local function ApplyTextLayout(text, widthMode, fixedWidth, wrapMode)
  text:SetWidth(widthMode == "Fixed" and (fixedWidth or 200) or 0)
  text:SetWordWrap(wrapMode ~= "Elide")
  text:SetNonSpaceWrap(wrapMode ~= "Elide")
end

local function ResolveArea(native, data, areaName)
  if data.regionType == "aurabar" and areaName == "bar" then
    return native.bar, native.barWidth, native.barHeight
  end
  if data.regionType == "aurabar" and data.icon and areaName == "icon" then
    return native.icon, native.iconSize, native.iconSize
  end
  local width, height = Display.Dimensions(data)
  return native.button, width, height
end

local BORDER_PIECE_NAMES = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "BOTTOM"}

local function EnsureBorderFrame(entry, parent)
  if entry.border then
    return
  end
  entry.border = CreateFrame("Frame", nil, parent)
  entry.borderPieces = {}
  for _, pieceName in ipairs(BORDER_PIECE_NAMES) do
    local piece = entry.border:CreateTexture(nil, "ARTWORK")
    entry.borderPieces[pieceName] = piece
    piece.originalSnappingBias = piece:GetTexelSnappingBias()
  end
end

local function PositionBorderFrame(frame, target, width, height, offset, pixelPerfect)
  frame:SetIgnoreParentScale(pixelPerfect)
  frame:SetScale(pixelPerfect and PixelUtil.GetPixelToUIUnitFactor() or 1)
  if frame.SetRoundLayoutToNearestPixel then
    frame:SetRoundLayoutToNearestPixel(pixelPerfect)
  end
  frame:ClearAllPoints()
  if pixelPerfect then
    frame:SetPoint("TOPLEFT", target, "TOPLEFT", -offset, offset)
    frame:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", offset, -offset)
  else
    frame:SetPoint("CENTER", target, "CENTER")
    frame:SetSize(width, height)
  end
end

local function PaintBorderPieces(pieces, element, pixelPerfect)
  local file = SharedMedia:Fetch("border", element.border_edge or "Square Full White")
  for _, piece in pairs(pieces) do
    piece:ClearAllPoints()
    piece:SetTexture(file, "REPEAT", "REPEAT")
    piece:SetVertexColor(unpack(element.border_color or {1, 1, 1, 1}))
    piece:SetSnapToPixelGrid(not pixelPerfect)
    piece:SetTexelSnappingBias(pixelPerfect and 0 or piece.originalSnappingBias or 0)
    if piece.SetRoundLayoutToNearestPixel then
      piece:SetRoundLayoutToNearestPixel(pixelPerfect)
    end
  end
end

local function LayoutBorderPieces(frame, pieces, width, height, size)
  for index, corner in ipairs({"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}) do
    local piece = pieces[corner]
    piece:SetPoint(corner, frame, corner)
    piece:SetSize(size, size)
    local start = 0.5078125 + (index - 1) * 0.125
    piece:SetTexCoord(start, start + 0.109375, 0.0625, 0.9375)
  end
  local tileX = math.max(0, width / size - 2 - 0.0625)
  local tileY = math.max(0, height / size - 2 - 0.0625)
  for _, side in ipairs({"LEFT", "RIGHT"}) do
    local piece = pieces[side]
    piece:SetWidth(size)
    piece:SetPoint("TOP" .. side, pieces["TOP" .. side], "BOTTOM" .. side)
    piece:SetPoint("BOTTOM" .. side, pieces["BOTTOM" .. side], "TOP" .. side)
    local start = side == "LEFT" and 0.0078125 or 0.1328125
    piece:SetTexCoord(start, start + 0.109375, 0.0625, tileY)
  end
  for _, side in ipairs({"TOP", "BOTTOM"}) do
    local piece = pieces[side]
    piece:SetHeight(size)
    piece:SetPoint(side .. "LEFT", pieces[side .. "LEFT"], side .. "RIGHT")
    piece:SetPoint(side .. "RIGHT", pieces[side .. "RIGHT"], side .. "LEFT")
    local start = side == "TOP" and 0.2578125 or 0.3828125
    piece:SetTexCoord(start, tileX, start + 0.109375, tileX, start, 0.0625, start + 0.109375, 0.0625)
  end
end

local function StyleBorder(entry, parent, target, width, height, element)
  EnsureBorderFrame(entry, parent)
  local frame, pieces = entry.border, entry.borderPieces
  local offset = element.border_offset or 0
  width = math.max(1, width + offset * 2)
  height = math.max(1, height + offset * 2)
  local size = math.min(math.max(0.1, element.border_size or 2), width / 2, height / 2)
  local pixelPerfect = element.border_ppscale == true
  if pixelPerfect then
    size = math.max(1, math.floor((element.border_size or 2) + 0.5))
    offset = math.floor(offset + 0.5)
  end
  PositionBorderFrame(frame, target, width, height, offset, pixelPerfect)
  PaintBorderPieces(pieces, element, pixelPerfect)
  LayoutBorderPieces(frame, pieces, width, height, size)
  frame:SetAlpha(element.border_alpha or 1)
  frame:Show()
end

local function SplitAnchorTarget(native, button, point)
  local prefix = point:sub(1, ANCHOR_PREFIX_LENGTH)
  if prefix == ANCHOR_INNER then
    return native.inner, point:sub(ANCHOR_PREFIX_LENGTH + 1)
  elseif prefix == ANCHOR_OUTER then
    return native.outer, point:sub(ANCHOR_PREFIX_LENGTH + 1)
  end
  return button, point
end

local function PlaceAtPoint(region, native, button, element, defaults)
  local target, point = SplitAnchorTarget(native, button, element.anchor_point or defaults.point)
  region:SetSize(element.width or defaults.size, element.height or defaults.size)
  region:SetPoint(element.self_point or defaults.selfPoint, target, point, element.xOffset or 0, element.yOffset or 0)
end

local function StretchOverArea(region, target, element)
  local extraX = element.xOffset or 0
  local extraY = element.yOffset or 0
  region:SetPoint("TOPLEFT", target, "TOPLEFT", -extraX / 2, extraY / 2)
  region:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", extraX / 2, -extraY / 2)
end

local POINT_DEFAULTS_BORDER = {point = "CENTER", size = 32, selfPoint = "CENTER"}
local POINT_DEFAULTS_DISPEL = {point = "TOPLEFT", size = 16, selfPoint = "TOPLEFT"}
local POINT_DEFAULTS_TEXTURE = {point = "CENTER", size = 32, selfPoint = "CENTER"}

local function ResetNative(native, button, width, height, StyleGlow)
  button:SetSize(width, height)
  native.inner:SetSize(width * 0.8, height * 0.8)
  native.outer:SetSize(width * 1.1, height * 1.1)
  button:ClearDurationText()
  button:ClearApplicationCount()
  button:ClearSpellName()
  button:ClearDurationBar()
  button:ClearDurationCooldown()
  button:ClearIcon()
  if not native.preview then
    button:ClearDispelTypeTextures()
  end
  for _, frame in pairs(native.elementFrames or {}) do
    frame:Hide()
  end
  native.border:Hide()
  native.icon:Hide()
  native.cooldown:Hide()
  if native.bar then
    native.bar:Hide()
  end
  if native.progressBackground then
    native.progressBackground:Hide()
  end
  if native.mainText then
    native.mainText:Hide()
  end
  for _, shared in pairs(native.sharedElements or {}) do
    if shared.glow then
      StyleGlow(shared, {blizzardAuraDisplay = {glow = false}})
    end
    Display.ClearElementGlow(shared)
  end
  if native.lateGlow then
    native.lateGlow.clip:Hide()
  end
  Display.ResetPandemicGlows(native)
  native.sharedElements = native.sharedElements or {}
end

local function StyleCooldownSwipe(native, data, button, baseFrame)
  local cooldown = native.cooldown
  cooldown:SetFrameLevel(baseFrame:GetFrameLevel() + 1)
  cooldown:SetDrawSwipe(data.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(data.cooldownEdge == true)
  cooldown:SetReverse(data.inverse == true)
  cooldown:SetHideCountdownNumbers(data.cooldownTextDisabled ~= false)
  cooldown:SetSwipeColor(unpack(data.blizzardAuraDisplay.swipeColor or {0, 0, 0, 0.8}))
  button:SetDurationCooldown(cooldown)
end

local function StyleAuraBar(native, data, button, baseFrame, width, height)
  local progressBar = native.progressTexture and native.progressTexture.bar
  if not native.bar or (native.progressTexture and native.bar == progressBar) then
    native.bar = CreateFrame("StatusBar", nil, baseFrame)
  end
  local bar = native.bar
  bar:ClearAllPoints()
  bar:SetAllPoints(button)
  local texturePath = data.textureSource == "LSM" and SharedMedia:Fetch("statusbar", data.texture or "Blizzard")
    or data.textureInput
    or "Interface\\Buttons\\WHITE8X8"
  bar:SetStatusBarTexture(texturePath)
  bar:SetStatusBarColor(unpack(data.barColor or {1, 0, 0, 1}))
  local vertical = (data.orientation or "HORIZONTAL"):find("VERTICAL", 1, true) ~= nil
  native.barWidth = math.max(4, width - (data.icon and not vertical and height or 0))
  native.barHeight = math.max(4, height - (data.icon and vertical and width or 0))
  native.iconSize = vertical and width or height
  bar:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
  bar:SetReverseFill((data.orientation or ""):find("INVERSE", 1, true) ~= nil)
  if not native.barBackground then
    native.barBackground = baseFrame:CreateTexture(nil, "BACKGROUND")
  end
  native.barBackground:SetAllPoints(bar)
  native.barBackground:SetColorTexture(unpack(data.backgroundColor or {0, 0, 0, 0.5}))
  native.barBackground:Show()
  if data.icon then
    local iconFirst = data.icon_side == "LEFT"
    local side
    if vertical then
      side = iconFirst and "BOTTOM" or "TOP"
    else
      side = iconFirst and "LEFT" or "RIGHT"
    end
    local iconSize = vertical and width or height
    native.icon:ClearAllPoints()
    native.icon:SetSize(iconSize, iconSize)
    native.icon:SetPoint(side, button, side)
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", button, "TOPLEFT", side == "LEFT" and iconSize or 0, side == "TOP" and -iconSize or 0)
    bar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", side == "RIGHT" and -iconSize or 0, side == "BOTTOM" and iconSize or 0)
  end
  local directions = Enum.StatusBarTimerDirection
  button:SetDurationBar(bar, {direction = data.inverse and directions.ElapsedTime or directions.RemainingTime})
  bar:Show()
end

local function StyleMainText(native, data, button, baseFrame, StyleText)
  native.mainText = native.mainText or baseFrame:CreateFontString(nil, "OVERLAY")
  StyleText(native.mainText, native, {
    textFont = data.font,
    textSize = data.fontSize,
    textColor = data.color,
    textOutline = data.outline,
    textJustify = data.justify,
    textShadowColor = data.shadowColor,
    textShadowX = data.shadowXOffset,
    textShadowY = data.shadowYOffset,
  }, "text", 18, "CENTER", 0, 0)
  native.mainText:Show()
  ApplyTextLayout(native.mainText, data.automaticWidth, data.fixedWidth, data.wordWrap)
  BindText(button, native.mainText, data.displayText, data, "displayText_format_", data, data.color, "color")
end

local function StyleBaseIcon(native, data, button, baseFrame)
  local icon = native.icon
  icon:ClearAllPoints()
  icon:SetAllPoints(button)
  icon:SetDesaturated(data.desaturate == true)
  Display.StyleIconTexCoords(native, data)
  icon:SetVertexColor(unpack(data.regionType == "aurabar" and data.icon_color or data.color or {1, 1, 1, 1}))
  if data.regionType == "icon" or (data.regionType == "aurabar" and data.icon) then
    if data.iconSource == 0 and data.displayIcon then
      icon:SetTexture(data.displayIcon)
    else
      button:SetIcon(icon)
    end
    icon:Show()
  end
end

local elementStylers = {}

function elementStylers.subbackground(context, entry, frame)
  local native, baseFrame = context.native, context.baseFrame
  baseFrame:SetFrameLevel(frame:GetFrameLevel())
  if native.bar then
    native.bar:SetFrameLevel(baseFrame:GetFrameLevel() + 1)
  end
  native.cooldown:SetFrameLevel(baseFrame:GetFrameLevel() + 1)
end

function elementStylers.subforeground(context, entry, frame)
  if context.native.bar then
    context.native.bar:SetFrameLevel(frame:GetFrameLevel())
  end
end

function elementStylers.subtext(context, entry, frame, element, index)
  if element.text_visible == false then
    return
  end
  local native, button = context.native, context.button
  entry.text = entry.text or frame:CreateFontString(nil, "OVERLAY")
  context.StyleText(entry.text, native, TextSettings(element), "text", 18, "CENTER", 0, 0)
  entry.text:SetAlpha(element.text_alpha or 1)
  ApplyTextLayout(entry.text, element.text_automaticWidth, element.text_fixedWidth, element.text_wordWrap)
  entry.text:Show()
  BindText(button, entry.text, element.text_text, element, "text_text_format_", context.data, element.text_color, "sub." .. index .. ".text_color")
end

function elementStylers.subborder(context, entry, frame, element)
  if not context.borderSeen and element.border_visible ~= false then
    local target, borderWidth, borderHeight = ResolveArea(context.native, context.data, element.anchor_area)
    StyleBorder(entry, frame, target, borderWidth, borderHeight, element)
  end
  context.borderSeen = true
end

function elementStylers.subglow(context, entry, frame, element, index)
  local native, data = context.native, context.data
  entry.glowAnchor, entry.glowWidth, entry.glowHeight = ResolveArea(native, data, element.anchor_area)
  local holder = Display.TimedGlowHolder(native, data, index, frame)
  if holder == nil then
    holder = Display.PandemicGlowHolder(native, data, index, frame)
  end
  if holder == nil then
    Display.StyleElementGlow(entry, context.button, frame, entry.glowAnchor, element, entry.glowWidth, entry.glowHeight)
  elseif holder then
    local forced = setmetatable({glow = true}, {__index = element})
    Display.StyleElementGlow(entry, context.button, holder, entry.glowAnchor, forced, entry.glowWidth, entry.glowHeight)
  end
end

function elementStylers.subcdmdispelborder(context, entry, frame, element)
  if element.dispelVisible == false then
    return
  end
  local native, button = context.native, context.button
  entry.dispelAnchor = entry.dispelAnchor or CreateFrame("Frame", nil, frame)
  local anchor = entry.dispelAnchor
  anchor:ClearAllPoints()
  anchor:Show()
  if element.anchor_mode == "point" then
    PlaceAtPoint(anchor, native, button, element, POINT_DEFAULTS_BORDER)
  else
    local target = ResolveArea(native, context.data, element.anchor_area)
    StretchOverArea(anchor, target, element)
  end
  entry.dispelEdges = entry.dispelEdges or Private.DispelTypeDisplay.CreateEdges(frame)
  Private.DispelTypeDisplay.Layout(entry.dispelEdges, anchor, element)
  Private.DispelTypeDisplay.Bind(button, entry.dispelEdges)
end

function elementStylers.subcdmdispel(context, entry, frame, element)
  if element.dispelVisible == false then
    return
  end
  local native, button = context.native, context.button
  entry.texture = entry.texture or frame:CreateTexture(nil, "OVERLAY", nil, 1)
  local texture = entry.texture
  texture:ClearAllPoints()
  if element.anchor_mode == "area" then
    local target = ResolveArea(native, context.data, element.anchor_area)
    StretchOverArea(texture, target, element)
  else
    PlaceAtPoint(texture, native, button, element, POINT_DEFAULTS_DISPEL)
  end
  button:AddDispelTypeTexture(texture, {
    showWhenHelpful = true,
    showWhenHarmful = true,
    style = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
  })
end

function elementStylers.subtexture(context, entry, frame, element)
  if element.textureVisible == false then
    return
  end
  local native, button = context.native, context.button
  entry.texture = entry.texture or frame:CreateTexture(nil, "ARTWORK")
  local texture = entry.texture
  texture:ClearAllPoints()
  if element.anchor_mode == "point" then
    PlaceAtPoint(texture, native, button, element, POINT_DEFAULTS_TEXTURE)
  else
    local target = ResolveArea(native, context.data, element.anchor_area)
    StretchOverArea(texture, target, element)
  end
  texture:SetTexture(element.textureTexture)
  texture:SetVertexColor(unpack(element.textureColor or {1, 1, 1, 1}))
  texture:SetDesaturated(element.textureDesaturate == true)
  texture:SetBlendMode(element.textureBlendMode or "BLEND")
  texture:SetTexCoord(element.textureMirror and 1 or 0, element.textureMirror and 0 or 1, 0, 1)
  texture:SetRotation(math.rad(element.textureRotation or 0))
  texture:SetAlpha(element.texture_alpha or 1)
  texture:Show()
end

local function HideElementLeftovers(entry)
  if entry.text then
    entry.text:Hide()
  end
  if entry.border then
    entry.border:Hide()
  end
  if entry.texture then
    entry.texture:Hide()
  end
  if entry.dispelBorder then
    entry.dispelBorder:Hide()
  end
  if entry.dispelEdges then
    Private.DispelTypeDisplay.Hide(entry.dispelEdges)
  end
end

local function StyleSubElements(context)
  local native, data, button = context.native, context.data, context.button
  for index, element in ipairs(data.subRegions or {}) do
    if not Display.IsDetachedElement(data, element) then
      local frame = context.ElementFrame(native, "shared" .. index)
      frame:SetFrameLevel(button:GetFrameLevel() + index * 3 + 3)
      frame:SetAlpha(1)
      frame:Show()
      local entry = native.sharedElements[index]
      if not entry then
        entry = {button = button, elementFrames = {glow = frame}}
        native.sharedElements[index] = entry
      end
      HideElementLeftovers(entry)
      local styler = elementStylers[element.type]
      if styler then
        styler(context, entry, frame, element, index)
      end
    end
  end
end

function Display.StyleAppearance(native, data, ElementFrame, StyleText, StyleGlow)
  local button = native.button
  local width, height = Display.Dimensions(data)
  ResetNative(native, button, width, height, StyleGlow)
  local baseFrame = ElementFrame(native, "sharedBase")
  baseFrame:SetFrameLevel(button:GetFrameLevel() + 1)
  baseFrame:Show()
  StyleBaseIcon(native, data, button, baseFrame)
  local regionType = data.regionType
  if regionType == "icon" and data.cooldown ~= false then
    StyleCooldownSwipe(native, data, button, baseFrame)
  elseif regionType == "progresstexture" then
    Private.ProgressTextureNative.StyleAura(native, data, baseFrame)
  elseif regionType == "aurabar" then
    StyleAuraBar(native, data, button, baseFrame, width, height)
  end
  if data.regionType ~= "aurabar" and native.barBackground then
    native.barBackground:Hide()
  end
  if data.regionType == "text" then
    StyleMainText(native, data, button, baseFrame, StyleText)
  end
  StyleSubElements({
    native = native,
    data = data,
    button = button,
    baseFrame = baseFrame,
    ElementFrame = ElementFrame,
    StyleText = StyleText,
  })
  Display.StyleNativeConditionIndicators(native, data)
  if Display.StyleRemainingList then
    Display.StyleRemainingList(native, data)
  end
  Display.StyleMasque(native, data)
  if Display.StyleDurationGate then
    Display.StyleDurationGate(native, data)
  end
end

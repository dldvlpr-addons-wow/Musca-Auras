return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local State = test.Frames.State
  local assertionCount = 0

  local function Check(condition, label)
    assertionCount = assertionCount + 1
    assert(condition, label)
  end
  local function Eq(actual, expected, label)
    Check(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Near(actual, expected, label)
    Check(type(actual) == "number" and math.abs(actual - expected) < 1e-9,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function NearAll(label, expected, ...)
    local values = {...}
    Eq(#values, #expected, label .. " value count")
    for index, value in ipairs(expected) do Near(values[index], value, label .. " #" .. index) end
  end
  local function Within(actual, low, high, label)
    Check(type(actual) == "number" and actual >= low and actual <= high,
      ("%s: expected between %s and %s, got %s"):format(label, low, high, tostring(actual)))
  end
  local function SecretData(extra)
    local data = {
      regionType = "icon", id = "Test Aura", uid = "uid",
      triggers = {{trigger = {type = "secretAura", unit = "player"}}},
      blizzardAuraDisplay = {},
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end

  local restores = {}
  local function Stub(owner, key, value)
    restores[#restores + 1] = {owner, key, owner[key]}
    owner[key] = value
  end
  local function Unstub()
    for index = #restores, 1, -1 do
      local saved = restores[index]
      saved[1][saved[2]] = saved[3]
      restores[index] = nil
    end
  end

  NearAll("non icon ignores offsets and aspect ratio", {0, 1, 0, 1}, Display.IconTexCoords({
    regionType = "aurabar", width = 100, height = 50, keepAspectRatio = true, texXOffset = 0.3, texYOffset = 0.2,
  }))
  NearAll("icon horizontal offset only", {-0.1, 0.9, 0, 1}, Display.IconTexCoords({regionType = "icon", texXOffset = 0.1}))
  NearAll("icon vertical offset only", {0, 1, 0.2, 1.2}, Display.IconTexCoords({regionType = "icon", texYOffset = 0.2}))
  NearAll("zero zoom argument beats data zoom", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "icon", zoom = 0.5}, 0))
  NearAll("non icon zero zoom argument", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "text", zoom = 0.5}, 0))
  NearAll("icon zoom above one", {0.5, 0.5, 0.5, 0.5}, Display.IconTexCoords({regionType = "icon"}, 2))

  local width, height = Display.Dimensions({regionType = "text"})
  Near(width, 200, "text width without settings table")
  Near(height, 21.6, "text height without settings table")
  width, height = Display.Dimensions({regionType = "icon"})
  Eq(width, 64, "icon width without settings table")
  Eq(height, 64, "icon height without settings table")
  width, height = Display.Dimensions({regionType = "progresstexture", width = 30, height = 31})
  Eq(width, 30, "progress texture width")
  Eq(height, 31, "progress texture height")
  width, height = Display.Dimensions({regionType = "icon", width = 3.5, height = 70})
  Eq(width, 4, "fractional width below floor")
  Eq(height, 70, "height kept")

  local plain = {regionType = "icon"}
  local secret = SecretData()
  secret.subRegions = {}
  for index = 1, 10 do secret.subRegions[index] = {type = "subtext"} end
  secret.subRegions[10].secretAuraDetached = true
  Eq(Display.IsDetachedProperty(secret, "sub.10.text_color"), true, "two digit index")
  Eq(Display.IsDetachedProperty(secret, "sub.1.text_color"), false, "first of ten")
  Eq(Display.IsDetachedProperty(secret, "sub.1."), false, "empty suffix")
  Eq(Display.IsDetachedProperty(secret, "sub.x.y"), false, "non numeric index")
  Eq(Display.IsDetachedProperty(secret, 10), false, "numeric property")
  Eq(Display.IsDetachedProperty(secret, "sub.10.a.b"), true, "dotted suffix")
  Eq(Display.IsDetachedProperty(secret, "xsub.10.text_color"), false, "prefix before sub")
  Eq(Display.IsDetachedProperty(secret, "sub.11.text_color"), false, "index past the end")

  Eq(Display.TextKind("%%%%"), "literal", "two escaped percents")
  Eq(Display.TextKind("a%%b"), "literal", "escaped percent inside text")
  Eq(Display.TextKind("%%%p"), nil, "escaped percent then code")
  Eq(Display.TextKind("%%%%%"), nil, "odd percent run")
  Eq(Display.TextKind("%s%s"), nil, "two codes")
  Eq(Display.TextKind("%S"), nil, "upper case stack code")
  Eq(Display.TextKind("%N"), nil, "upper case name code")
  Eq(Display.TextKind("%"), nil, "lone percent")
  Eq(Display.TextKind("%n"), "name", "name code")

  local native = {inner = {}, outer = {}}
  local button = {}
  local target, point = Display.SplitAnchorTarget(native, button, "INNER_")
  Eq(target, native.inner, "bare inner prefix target")
  Eq(point, "", "bare inner prefix point")
  target, point = Display.SplitAnchorTarget(native, button, "OUTER_TOPLEFT")
  Eq(target, native.outer, "outer target")
  Eq(point, "TOPLEFT", "outer point")
  target, point = Display.SplitAnchorTarget(native, button, "INNER_BOTTOMRIGHT")
  Eq(target, native.inner, "inner target")
  Eq(point, "BOTTOMRIGHT", "inner point")
  target, point = Display.SplitAnchorTarget(native, button, "inner_TOP")
  Eq(target, button, "lower case prefix target")
  Eq(point, "inner_TOP", "lower case prefix point")
  target, point = Display.SplitAnchorTarget(native, button, "INNER")
  Eq(target, button, "prefix without underscore target")
  Eq(point, "INNER", "prefix without underscore point")
  target, point = Display.SplitAnchorTarget(native, button, "TOP")
  Eq(target, button, "plain target")
  Eq(point, "TOP", "plain point")

  Eq(Display.CanAddElement(plain, "subborder"), true, "non secret border")
  Eq(Display.CanAddElement({regionType = "icon", subRegions = {{type = "subborder"}}}, "subborder"), true, "non secret second border")
  Stub(private, "CDMAuraProgress", {IsConfigured = function() return "yes" end})
  Eq(Display.CanAddElement(plain, "subcdmdispel"), true, "configured progress, dispel, strict boolean")
  Eq(Display.CanAddElement(plain, "subcdmdispelborder"), true, "configured progress, dispel border")
  Eq(Display.CanAddElement(plain, "subtext"), true, "configured progress, text")
  Stub(private, "CDMAuraProgress", {IsConfigured = function() return false end})
  Eq(Display.CanAddElement(plain, "subcdmdispel"), false, "unconfigured progress")
  Eq(Display.CanAddElement(SecretData(), "subcdmdispel"), true, "secret aura wins over unconfigured progress")
  Stub(private, "CDMAuraProgress", nil)
  Eq(Display.CanAddElement(plain, "subcdmdispel"), false, "no progress module")
  Eq(Display.CanAddElement(SecretData(), "subcdmdispelborder"), true, "secret aura without progress module")
  Eq(Display.CanAddElement(SecretData({subRegions = {}}), "subborder"), true, "secret, empty list, border")
  Unstub()

  local MESSAGE_CODES = "You can only use %p, %s, %n or hardcoded text. Put each code in its own text element. Custom text (%c) is not supported."
  local MESSAGE_DUPLICATE = "Secret auras support one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text."
  local MESSAGE_UNSUPPORTED = "This sub element is not supported by Secret Auras. Use Text, Texture or Glow."
  local MESSAGE_DETACHED = "Detached Text uses hardcoded text. Use other triggers and Conditions to control when it appears."
  local function Validate(elements, extra)
    local data = SecretData(extra)
    data.subRegions = elements
    return Display.ValidateAppearance(data)
  end
  for _, kind in ipairs({"subbackground", "subforeground", "subborder", "subtexture", "subcdmdispel", "subcdmdispelborder", "subglow"}) do
    Eq(Validate({{type = kind}}), nil, "element without rule " .. kind)
  end
  Eq(Validate({{}}), MESSAGE_UNSUPPORTED, "element without type")
  Eq(Validate({{type = "subtext", text_text = "%p", text_visible = false, secretAuraDetached = true}}), MESSAGE_DETACHED,
    "detached text ignores its visible flag")
  Eq(Validate({{type = "subtext", text_text = "%p", secretAuraDetached = true}, {type = "subtext", text_text = "%p"}}, {regionType = "text", displayText = "%s"}),
    MESSAGE_DETACHED, "detached text reported after a valid main text")
  Eq(Validate({{type = "subtext", text_text = "%s"}, {type = "subtext", text_text = "%n"}}, {regionType = "text", displayText = "%p"}), nil,
    "main text and two other kinds")
  Eq(Validate({{type = "subtext", text_text = "%n"}}, {regionType = "text", displayText = "%n"}), MESSAGE_DUPLICATE, "main text name claim")
  Eq(Validate({{type = "subtext", text_text = "%s"}}, {regionType = "text", displayText = "%s"}), MESSAGE_DUPLICATE, "main text stack claim")
  Eq(Validate({}, {regionType = "text"}), nil, "main text without displayText")
  Eq(Validate(nil, {regionType = "text", displayText = "%p"}), nil, "text region without sub regions")
  Eq(Validate(nil, {regionType = "text", displayText = "%c"}), MESSAGE_CODES, "text region without sub regions, bad code")
  local nonSecret = {regionType = "icon", subRegions = {
    {type = "subtext", text_text = "%p", secretAuraDetached = true}, {type = "subtext", text_text = "%p"},
  }}
  Eq(Display.ValidateAppearance(nonSecret), MESSAGE_DUPLICATE, "non secret aura treats a detached marker as shown text")
  nonSecret.subRegions = {{type = "subtext", text_text = "%c", secretAuraDetached = true}}
  Eq(Display.ValidateAppearance(nonSecret), MESSAGE_CODES, "non secret aura, marked text with bad code")
  Eq(Display.ValidateAppearance({regionType = "icon"}), nil, "non secret aura without sub regions")
  Eq(Validate({{type = "subtext", text_text = "%%p"}, {type = "subtext", text_text = "%%p"}}), nil, "escaped codes do not claim")
  Eq(Validate({{type = "subtext", text_text = "%p"}, {type = "subtext", text_text = "%s", text_visible = false}, {type = "subtext", text_text = "%s"}}), nil,
    "hidden text does not claim")

  Eq(Validate({{type = "subglow", glow = true, glowType = "Pixel"}}), nil, "pixel glow accepted")
  Eq(Validate({{type = "subglow", glow = true, glowType = "Bogus"}}), "Choose Action Button Glow, Pixel Glow, Autocast Shine or Proc Glow.", "bad glow type")
  Eq(Display.CanAddElement(SecretData(), "subcustom"), false, "secret aura, unsupported kind")
  Eq(Display.CanAddElement(SecretData({subRegions = {{type = "subborder"}}}), "subborder"), false, "secret aura, second border")

  local function Migrate(data, legacy)
    Display.MigrateAppearance(data, legacy)
    return data
  end
  local function Kinds(data)
    local kinds = {}
    for index, element in ipairs(data.subRegions) do kinds[index] = element.type end
    return table.concat(kinds, ",")
  end

  local settingsTable = {}
  local subject = {regionType = "icon", blizzardAuraDisplay = settingsTable}
  Migrate(subject, {})
  Eq(subject.blizzardAuraDisplay, settingsTable, "settings table identity kept")
  Eq(settingsTable.sharedDisplay, true, "marked migrated")
  subject = Migrate({regionType = "icon"}, {})
  Check(type(subject.blizzardAuraDisplay) == "table" and subject.blizzardAuraDisplay.sharedDisplay == true, "settings table created")
  Eq(Kinds(subject), "subbackground,subtext,subtext", "empty legacy gives background, duration and stack")
  Eq(subject.inverse, true, "empty legacy inverse")

  local existingElements = {{type = "subglow"}}
  subject = Migrate({regionType = "icon", subRegions = existingElements}, nil)
  Eq(subject.subRegions, existingElements, "no legacy keeps sub regions identity")
  Eq(subject.inverse, true, "no legacy icon inverse")
  subject = Migrate({regionType = "aurabar", inverse = false}, nil)
  Eq(subject.inverse, false, "no legacy bar keeps inverse")
  subject = Migrate({regionType = "icon", inverse = false}, nil)
  Eq(subject.inverse, true, "no legacy icon forces inverse")
  subject = Migrate({regionType = "aurabar", inverse = false, blizzardAuraDisplay = {sharedDisplay = true}}, {})
  Eq(subject.inverse, false, "migrated aura untouched")
  Eq(subject.subRegions, nil, "migrated aura gets no elements")

  subject = Migrate({regionType = "icon"}, {reverse = true})
  Eq(subject.inverse, true, "reverse true")
  subject = Migrate({regionType = "icon"}, {reverse = false})
  Eq(subject.inverse, false, "reverse false")
  subject = Migrate({regionType = "icon"}, {reverse = nil})
  Eq(subject.inverse, true, "reverse nil")

  local glowColor, backgroundColor, textColor, shadowColor = {0.4, 0.5, 0.6, 0.7}, {0.1, 0.2, 0.3, 0.4}, {0.9, 0.8, 0.7, 0.6}, {0.2, 0.2, 0.2, 0.2}
  subject = Migrate({regionType = "icon"}, {
    elements = {"glow", "background", "duration"},
    glowColor = glowColor, backgroundColor = backgroundColor,
    durationColor = textColor, durationShadowColor = shadowColor, durationOutline = "THICKOUTLINE", durationJustify = "RIGHT",
    durationShadowX = 3, durationShadowY = -4, durationSelfPoint = "TOPLEFT",
  })
  Eq(Kinds(subject), "subbackground,subglow,subtexture,subtext", "element order")
  local glowElement, textureElement, durationElement = subject.subRegions[2], subject.subRegions[3], subject.subRegions[4]
  Check(glowElement.glowColor ~= glowColor, "glow color is a copy")
  NearAll("glow color values", {0.4, 0.5, 0.6, 0.7}, unpack(glowElement.glowColor))
  Check(textureElement.textureColor ~= backgroundColor, "background color is a copy")
  NearAll("background color values", {0.1, 0.2, 0.3, 0.4}, unpack(textureElement.textureColor))
  Check(durationElement.text_color ~= textColor, "text color is a copy")
  NearAll("text color values", {0.9, 0.8, 0.7, 0.6}, unpack(durationElement.text_color))
  Check(durationElement.text_shadowColor ~= shadowColor, "shadow color is a copy")
  NearAll("shadow color values", {0.2, 0.2, 0.2, 0.2}, unpack(durationElement.text_shadowColor))
  Eq(durationElement.text_fontType, "THICKOUTLINE", "outline")
  Eq(durationElement.text_justify, "RIGHT", "justify")
  Eq(durationElement.text_shadowXOffset, 3, "shadow x")
  Eq(durationElement.text_shadowYOffset, -4, "shadow y")
  Eq(durationElement.text_selfPoint, "TOPLEFT", "self point")
  glowColor[1], textColor[1] = 0, 0
  Near(glowElement.glowColor[1], 0.4, "glow color independent of the source")
  Near(durationElement.text_color[1], 0.9, "text color independent of the source")

  subject = Migrate({regionType = "icon"}, {
    elements = {"text12", "text", "textA", "label", "stack", "duration", "text3"},
    text12 = 42, text3 = "", label = "", labelVisible = false, durationVisible = false, stackVisible = false,
  })
  Eq(Kinds(subject), "subbackground,subtext,subtext,subtext,subtext,subtext", "only valid text names make elements")
  Eq(subject.subRegions[2].text_text, "42", "numeric text")
  Eq(subject.subRegions[3].text_text, "", "empty label")
  Eq(subject.subRegions[3].text_visible, false, "label hidden")
  Eq(subject.subRegions[4].text_text, "%s", "stack code")
  Eq(subject.subRegions[4].text_visible, false, "stackVisible hides")
  Eq(subject.subRegions[5].text_visible, false, "durationVisible hides")
  Eq(subject.subRegions[6].text_text, "", "empty numbered text")
  Eq(subject.subRegions[6].text_visible, true, "numbered text shown")

  subject = Migrate({regionType = "icon"}, {elements = {"duration", "stack", "label"}, duration = false, stacks = false, durationVisible = true})
  Eq(subject.subRegions[2].text_visible, false, "duration flag hides")
  Eq(subject.subRegions[3].text_visible, false, "stacks flag hides")
  Eq(subject.subRegions[4].text_visible, true, "label shown by default")

  local subtextDefaultArguments
  local sharedBase = {text_font = "Base Font", text_fontSize = 11, text_color = {1, 1, 0, 1}, type = "wrong", extraField = "kept"}
  Stub(private.subRegionTypes.subtext, "default", function(regionType)
    subtextDefaultArguments = regionType
    return sharedBase
  end)
  subject = Migrate({regionType = "aurabar"}, {elements = {"label"}})
  Eq(subtextDefaultArguments, "aurabar", "default built for the region type")
  local labelElement = subject.subRegions[2]
  Eq(labelElement.type, "subtext", "type overwritten")
  Eq(labelElement.text_font, "Base Font", "base font kept")
  Eq(labelElement.extraField, "kept", "base field kept")
  Eq(labelElement.text_fontSize, 18, "legacy default size wins over the base")
  Eq(sharedBase.type, "wrong", "base table untouched")
  Check(labelElement ~= sharedBase and labelElement.text_color ~= sharedBase.text_color, "base copied deeply")
  local second = Migrate({regionType = "aurabar"}, {elements = {"label"}}).subRegions[2]
  Check(second ~= labelElement and second.text_color ~= labelElement.text_color, "fresh tables on every call")
  Unstub()
  Stub(private.subRegionTypes.subtext, "default", {text_font = "Table Font", text_wordWrap = "Elide"})
  labelElement = Migrate({regionType = "icon"}, {elements = {"label"}}).subRegions[2]
  Eq(labelElement.text_font, "Table Font", "table base font")
  Eq(labelElement.text_wordWrap, "Elide", "table base field")
  Unstub()
  Stub(private.subRegionTypes.subtext, "default", nil)
  labelElement = Migrate({regionType = "icon"}, {elements = {"label"}, fontSize = 25}).subRegions[2]
  Eq(labelElement.type, "subtext", "absent base default")
  Eq(labelElement.text_fontSize, 25, "legacy font size")
  Eq(labelElement.text_font, nil, "no font without a base")
  Eq(Migrate({regionType = "icon"}, {elements = {"label"}}).subRegions[2].text_fontSize, 18, "fallback text size")
  Unstub()
  Stub(private, "subRegionTypes", nil)
  labelElement = Migrate({regionType = "icon"}, {elements = {"label"}}).subRegions[2]
  Eq(labelElement.text_fontSize, 18, "no sub region types")
  Unstub()

  local meta = getmetatable(CreateFrame("Frame"))
  local callLog = {}
  local spiedNames = {
    SetDrawSwipe = true, SetDrawEdge = true, SetReverse = true, SetHideCountdownNumbers = true, SetSwipeColor = true,
    SetWordWrap = true, SetNonSpaceWrap = true, SetIgnoreParentScale = true, SetRoundLayoutToNearestPixel = true,
    GetWidth = true, GetHeight = true, GetSize = true, SetSnapToPixelGrid = true,
  }
  local originalIndex = meta.__index
  local function Original(self, key)
    if type(originalIndex) == "function" then return originalIndex(self, key) end
    return originalIndex[key]
  end
  local biasOverride
  meta.__index = (function(self, key)
    if spiedNames[key] then
      local method = Original(self, key)
      return function(object, ...)
        callLog[#callLog + 1] = {object = object, name = key, ...}
        if method then return method(object, ...) end
      end
    end
    if key == "GetTexelSnappingBias" and biasOverride then
      return function() return biasOverride() end
    end
    return Original(self, key)
  end)
  local function Calls(object, name)
    local found = {}
    for _, call in ipairs(callLog) do
      if call.object == object and call.name == name then found[#found + 1] = call end
    end
    return found
  end
  local function LastCall(object, name)
    local found = Calls(object, name)
    return found[#found]
  end
  local function ResetCalls()
    for index = #callLog, 1, -1 do callLog[index] = nil end
  end

  local BUTTON_METHODS = {
    "ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon",
    "ClearDispelTypeTextures", "SetIcon", "SetDurationText", "SetApplicationCount", "SetSpellName", "SetDurationCooldown",
    "SetDurationBar", "AddDispelTypeTexture",
  }
  local function NewNative(options)
    options = options or {}
    local button = CreateFrame("Frame")
    button:SetFrameLevel(options.level or 10)
    local native = {
      button = button, inner = CreateFrame("Frame", nil, button), outer = CreateFrame("Frame", nil, button),
      border = CreateFrame("Frame", nil, button), icon = button:CreateTexture(), cooldown = CreateFrame("Cooldown", nil, button),
      elementFrames = {}, buttonCalls = {}, behaviors = {},
    }
    for _, name in ipairs(BUTTON_METHODS) do
      if not (options.without and options.without[name]) then
        button[name] = function(_, ...)
          native.buttonCalls[#native.buttonCalls + 1] = {name = name, ...}
          local behavior = native.behaviors[name]
          if behavior then return behavior(...) end
        end
      end
    end
    native.preview = options.preview
    return native
  end
  local function ButtonCalls(native, name)
    local found = {}
    for _, call in ipairs(native.buttonCalls) do
      if call.name == name then found[#found + 1] = call end
    end
    return found
  end
  local function ResolveElement(native, key)
    native.elementFrames[key] = native.elementFrames[key] or CreateFrame("Frame", nil, native.button)
    return native.elementFrames[key]
  end
  local styledTexts
  local function StyleText(text, owner, settings, ...)
    styledTexts[#styledTexts + 1] = {text = text, native = owner, settings = settings, arguments = {...}}
  end
  local function Pass(native, data)
    styledTexts = {}
    native.buttonCalls = {}
    Display.StyleAppearance(native, data, ResolveElement, StyleText)
  end
  local function Level(frame)
    return State[frame].frameLevel
  end

  local function PointOf(object, index)
    return State[object].points[index or 1]
  end
  local function ColorOf(values, expected, label)
    Check(type(values) == "table", label .. ": missing color")
    NearAll(label, expected, unpack(values, 1, 4))
  end

  local richBar = SecretData({
    regionType = "aurabar", width = 120, height = 20, icon = true, barColor = {0.2, 0.4, 0.6, 1},
    subRegions = {
      {type = "subtext", text_text = "label"}, {type = "subborder"}, {type = "subtexture", textureTexture = "Interface\\Foo"},
    },
  })
  local native = NewNative()
  native.mainText = native.button:CreateFontString()
  native.mainText:Show()
  native.lateGlow = {clip = CreateFrame("Frame", nil, native.button)}
  native.lateGlow.clip:Show()
  local pandemicResets = {}
  Stub(Display, "ResetPandemicGlows", function(argument) pandemicResets[#pandemicResets + 1] = argument end)
  Pass(native, richBar)
  Check(native.bar ~= nil and State[native.auraBar].shown == true, "bar styled for the bar region")
  Check(State[native.border].shown ~= true, "legacy border hidden")
  local firstShownBar = native.auraBar
  Eq(#pandemicResets, 1, "pandemic glows reset once")
  Eq(pandemicResets[1], native, "pandemic reset target")

  pandemicResets = {}
  local iconData = SecretData({width = 50, height = 30, color = {0.1, 0.2, 0.3, 1}, desaturate = true})
  Pass(native, iconData)
  Eq(native.bar, nil, "native bar cleared on a non bar region")
  Eq(State[native.auraBar].shown, false, "bar frame hidden")
  Eq(State[native.barBackground].shown, false, "bar background hidden")
  Eq(State[native.mainText].shown, false, "main text hidden")
  Eq(State[native.border].shown, false, "border hidden")
  Eq(State[native.lateGlow.clip].shown, false, "late glow clip hidden")
  Eq(#pandemicResets, 1, "pandemic glows reset again")
  Eq(State[native.button].width, 50, "button width")
  Eq(State[native.button].height, 30, "button height")
  Near(State[native.inner].width, 40, "inner width")
  Near(State[native.inner].height, 24, "inner height")
  Near(State[native.outer].width, 55, "outer width")
  Near(State[native.outer].height, 33, "outer height")
  for _, name in ipairs({"ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon", "ClearDispelTypeTextures"}) do
    Eq(#ButtonCalls(native, name), 1, name .. " called once")
  end
  Eq(State[native.elementFrames.shared1].shown, false, "unused element frame hidden")
  Eq(State[native.elementFrames.shared3].shown, false, "unused third element frame hidden")
  Eq(State[native.elementFrames.sharedBase].shown, true, "base shown")
  Stub(Display, "ResetPandemicGlows", nil)
  Pass(native, iconData)
  Unstub()

  native = NewNative({preview = true})
  Pass(native, iconData)
  Eq(#ButtonCalls(native, "ClearDispelTypeTextures"), 0, "preview keeps dispel textures")
  Eq(#ButtonCalls(native, "ClearIcon"), 1, "preview still clears the icon binding")
  native = NewNative({without = {ClearDispelTypeTextures = true}})
  Pass(native, iconData)
  Eq(#ButtonCalls(native, "ClearIcon"), 1, "pass completes without the dispel clear method")

  native = NewNative()
  Pass(native, iconData)
  local base = native.elementFrames.sharedBase
  Eq(Level(base), 11, "base level above the button")
  Eq(Level(native.cooldown), 12, "cooldown level above the base")
  Stub(Display, "StyleNativeConditionIndicators", function() end)
  native.button.GetFrameLevel = function() return secretwrap(40) end
  Pass(native, iconData)
  Eq(Level(base), 1, "secret button level counts as zero")
  Eq(Level(native.cooldown), 2, "cooldown level above a zero base")
  native.button.GetFrameLevel = function() return "high" end
  Pass(native, iconData)
  Eq(Level(base), 1, "non numeric button level counts as zero")
  native.button.GetFrameLevel = nil
  base.GetFrameLevel = function() return secretwrap(9) end
  Pass(native, iconData)
  Eq(Level(native.cooldown), 1, "secret base level counts as zero for the cooldown")
  base.GetFrameLevel = nil
  Unstub()

  native = NewNative()
  Pass(native, SecretData({subRegions = {{type = "subbackground"}, {type = "subforeground"}, {type = "subbackground"}}}))
  Eq(Level(native.elementFrames.shared1), 16, "first element frame level")
  Eq(Level(native.elementFrames.shared2), 19, "second element frame level")
  Eq(Level(native.elementFrames.shared3), 22, "third element frame level")
  Eq(Level(native.elementFrames.sharedBase), 22, "last background sets the base level")
  Eq(Level(native.cooldown), 23, "last background sets the cooldown level")
  Eq(State[native.elementFrames.shared1].alpha, 1, "element frame alpha")
  Eq(State[native.elementFrames.shared1].shown, true, "element frame shown")

  native = NewNative()
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, subRegions = {{type = "subbackground"}, {type = "subforeground"}}}))
  Eq(Level(native.auraBar), 19, "foreground puts the bar at its own frame level")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, subRegions = {{type = "subforeground"}, {type = "subbackground"}}}))
  Eq(Level(native.auraBar), 20, "background after foreground puts the bar above its frame")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20}))
  Eq(Level(native.auraBar), 12, "bar level above the base")

  native = NewNative()
  Pass(native, iconData)
  Eq(State[native.icon].shown, true, "icon shown")
  ColorOf(State[native.icon].vertexColor, {0.1, 0.2, 0.3, 1}, "icon color from the aura color")
  Eq(State[native.icon].desaturated, true, "desaturated")
  Eq(PointOf(native.icon, 1)[2], native.elementFrames.sharedBase, "icon fills the base")
  Eq(#State[native.icon].points, 2, "icon has two points")
  Eq(#ButtonCalls(native, "SetIcon"), 1, "icon bound")
  Eq(ButtonCalls(native, "SetIcon")[1][1], native.icon, "bound icon is the native icon")
  NearAll("icon crop without zoom", {0, 1, 0, 1}, unpack(State[native.icon].texCoord))
  Pass(native, SecretData({color = nil, desaturate = "yes", zoom = 0.1}))
  ColorOf(State[native.icon].vertexColor, {1, 1, 1, 1}, "icon default color")
  Eq(State[native.icon].desaturated, false, "desaturate needs true")
  NearAll("icon crop with zoom", {0.025, 0.975, 0.025, 0.975}, unpack(State[native.icon].texCoord))
  Pass(native, SecretData({iconSource = 0, displayIcon = "Interface\\Icons\\Custom"}))
  Eq(State[native.icon].texture, "Interface\\Icons\\Custom", "custom icon texture")
  Eq(#ButtonCalls(native, "SetIcon"), 0, "custom icon not bound")
  Pass(native, SecretData({iconSource = 0, displayIcon = ""}))
  Eq(#ButtonCalls(native, "SetIcon"), 1, "empty custom icon falls back to the binding")
  Pass(native, SecretData({iconSource = 0}))
  Eq(#ButtonCalls(native, "SetIcon"), 1, "missing custom icon falls back to the binding")
  Pass(native, SecretData({iconSource = 1, displayIcon = "Interface\\Icons\\Custom"}))
  Eq(#ButtonCalls(native, "SetIcon"), 1, "other icon source uses the binding")

  native = NewNative()
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, icon = true, icon_color = {0.5, 0.6, 0.7, 0.8}, color = {1, 0, 0, 1}}))
  ColorOf(State[native.icon].vertexColor, {0.5, 0.6, 0.7, 0.8}, "bar icon color")
  Eq(State[native.icon].shown, true, "bar icon shown")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, icon = true}))
  ColorOf(State[native.icon].vertexColor, {1, 1, 1, 1}, "bar icon default color")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, icon = false}))
  Eq(State[native.icon].shown, false, "icon hidden on a bar without icon")
  Eq(#ButtonCalls(native, "SetIcon"), 0, "no icon binding on a bar without icon")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20}))
  Eq(State[native.icon].shown, false, "icon hidden on a bar with no icon setting")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, icon = "yes"}))
  Eq(State[native.icon].shown, false, "bar icon needs true")

  native = NewNative()
  local progressCalls = {}
  Stub(private.ProgressTextureNative, "StyleAura", function(...) progressCalls[#progressCalls + 1] = {...} end)
  local progressData = SecretData({regionType = "progresstexture", width = 30, height = 31})
  Pass(native, progressData)
  Eq(#progressCalls, 1, "progress texture styled once")
  Eq(progressCalls[1][1], native, "progress texture native")
  Eq(progressCalls[1][2], progressData, "progress texture data")
  Eq(progressCalls[1][3], native.elementFrames.sharedBase, "progress texture base")
  Eq(State[native.icon].shown, false, "progress texture hides the icon")
  Eq(State[native.cooldown].shown, false, "progress texture hides the cooldown")
  Eq(#ButtonCalls(native, "SetIcon"), 0, "progress texture binds no icon")
  Eq(#ButtonCalls(native, "SetDurationCooldown"), 0, "progress texture binds no cooldown")
  Eq(State[native.button].width, 30, "progress texture width")
  Eq(State[native.button].height, 31, "progress texture height")
  Unstub()

  native = NewNative()
  Pass(native, SecretData())
  local cooldown = native.cooldown
  Eq(LastCall(cooldown, "SetDrawSwipe")[1], true, "swipe on by default")
  Eq(LastCall(cooldown, "SetDrawEdge")[1], false, "edge off by default")
  Eq(LastCall(cooldown, "SetReverse")[1], false, "not reversed by default")
  Eq(LastCall(cooldown, "SetHideCountdownNumbers")[1], true, "numbers hidden by default")
  local swipe = LastCall(cooldown, "SetSwipeColor")
  NearAll("default swipe color rgb", {0, 0, 0}, swipe[1], swipe[2], swipe[3])
  Within(swipe[4], 0.6, 0.9, "default swipe alpha")
  Eq(State[cooldown].shown, true, "cooldown shown")
  Eq(#ButtonCalls(native, "SetDurationCooldown"), 1, "cooldown bound")
  Eq(ButtonCalls(native, "SetDurationCooldown")[1][1], cooldown, "bound cooldown")
  ResetCalls()
  Pass(native, SecretData({
    cooldownSwipe = false, cooldownEdge = true, inverse = true, cooldownTextDisabled = false,
    blizzardAuraDisplay = {swipeColor = {0.1, 0.2, 0.3, 0.4}},
  }))
  Eq(LastCall(cooldown, "SetDrawSwipe")[1], false, "swipe off")
  Eq(LastCall(cooldown, "SetDrawEdge")[1], true, "edge on")
  Eq(LastCall(cooldown, "SetReverse")[1], true, "reversed")
  Eq(LastCall(cooldown, "SetHideCountdownNumbers")[1], false, "numbers shown")
  swipe = LastCall(cooldown, "SetSwipeColor")
  NearAll("configured swipe color", {0.1, 0.2, 0.3, 0.4}, swipe[1], swipe[2], swipe[3], swipe[4])
  Pass(native, SecretData({cooldownEdge = "yes", inverse = 1}))
  Eq(LastCall(cooldown, "SetDrawEdge")[1], false, "edge needs true")
  Eq(LastCall(cooldown, "SetReverse")[1], false, "reverse needs true")
  Pass(native, SecretData({blizzardAuraDisplay = false}))
  Check(LastCall(cooldown, "SetSwipeColor") ~= nil, "cooldown styled without display settings")
  local noSettings = SecretData()
  noSettings.blizzardAuraDisplay = nil
  Pass(native, noSettings)
  swipe = LastCall(cooldown, "SetSwipeColor")
  Within(swipe[4], 0.6, 0.9, "swipe alpha without display settings")

  ResetCalls()
  Pass(native, SecretData({cooldown = false}))
  Eq(State[cooldown].shown, false, "cooldown hidden when turned off")
  Eq(#ButtonCalls(native, "SetDurationCooldown"), 0, "cooldown not bound when turned off")
  Eq(#Calls(cooldown, "SetDrawSwipe"), 0, "cooldown not styled when turned off")
  Eq(#ButtonCalls(native, "SetIcon"), 1, "icon still bound with the cooldown off")
  Pass(native, SecretData({regionType = "aurabar", width = 100, height = 20, icon = true}))
  Eq(State[cooldown].shown, false, "cooldown hidden on a bar")
  Eq(#ButtonCalls(native, "SetDurationCooldown"), 0, "cooldown not bound on a bar")
  Eq(#Calls(cooldown, "SetDrawSwipe"), 0, "cooldown not styled on a bar")

  local function BarData(extra)
    local data = SecretData({regionType = "aurabar", width = 120, height = 20, icon = true})
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function BarTextureOf(native)
    return State[State[native.auraBar].statusBarTexture].texture
  end
  local function CheckPoint(point, expectedPoint, expectedRelative, expectedRelativePoint, label)
    Check(point ~= nil, label .. ": missing point")
    Eq(point[1], expectedPoint, label .. " point")
    Eq(point[2], expectedRelative, label .. " relative frame")
    Eq(point[3], expectedRelativePoint, label .. " relative point")
  end

  native = NewNative()
  Pass(native, BarData())
  base = native.elementFrames.sharedBase
  local bar = native.auraBar
  Eq(native.bar, bar, "native bar is the aura bar")
  Eq(State[bar].objectType, "StatusBar", "aura bar type")
  Eq(State[bar].parent, base, "aura bar parent")
  Eq(State[bar].shown, true, "aura bar shown")
  ColorOf(State[bar].statusBarColor, {1, 0, 0, 1}, "default bar color is opaque red")
  Eq(BarTextureOf(native), "Interface\\Buttons\\WHITE8X8", "default bar texture")
  Eq(State[bar].orientation, "HORIZONTAL", "default orientation")
  Eq(State[bar].reverseFill, false, "default fill direction")
  Eq(native.iconSize, 20, "icon size from the height")
  Eq(native.barWidth, 100, "bar width beside the icon")
  Eq(native.barHeight, 20, "bar height")
  Eq(State[bar].width, 100, "bar frame width")
  Eq(State[bar].height, 20, "bar frame height")
  Eq(State[native.icon].width, 20, "icon width")
  Eq(State[native.icon].height, 20, "icon height")
  CheckPoint(PointOf(native.icon), "RIGHT", base, "RIGHT", "icon on the default side")
  CheckPoint(PointOf(bar), "LEFT", base, "LEFT", "bar opposite the icon")
  Eq(#State[bar].points, 1, "bar has one point")
  local background = native.barBackground
  Eq(State[background].objectType, "Texture", "background is a texture")
  Eq(State[background].parent, base, "background parent")
  Eq(State[background].shown, true, "background shown")
  Eq(PointOf(background, 1)[2], bar, "background covers the bar")
  Eq(#State[background].points, 2, "background has two points")
  local backgroundColor = State[background].colorTexture
  NearAll("background color rgb", {0, 0, 0}, backgroundColor[1], backgroundColor[2], backgroundColor[3])
  Within(backgroundColor[4], 0.4, 0.6, "default background alpha")
  local directionCall = ButtonCalls(native, "SetDurationBar")[1]
  Eq(#ButtonCalls(native, "SetDurationBar"), 1, "bar bound once")
  Eq(directionCall[1], bar, "bound bar")
  Eq(directionCall[2].direction, Enum.StatusBarTimerDirection.RemainingTime, "remaining time by default")
  Check(Enum.StatusBarTimerDirection.RemainingTime ~= Enum.StatusBarTimerDirection.ElapsedTime, "directions differ")
  Eq(Level(bar), 12, "bar level")

  Pass(native, BarData({inverse = true, barColor = {0.3, 0.4, 0.5, 0.6}, backgroundColor = {0.9, 0.8, 0.7, 0.1}}))
  Eq(ButtonCalls(native, "SetDurationBar")[1][2].direction, Enum.StatusBarTimerDirection.ElapsedTime, "elapsed time when inverse")
  ColorOf(State[bar].statusBarColor, {0.3, 0.4, 0.5, 0.6}, "configured bar color")
  ColorOf(State[background].colorTexture, {0.9, 0.8, 0.7, 0.1}, "configured background color")
  Eq(native.auraBar, bar, "aura bar reused")
  Eq(native.barBackground, background, "background reused")
  Pass(native, BarData({inverse = false}))
  Eq(ButtonCalls(native, "SetDurationBar")[1][2].direction, Enum.StatusBarTimerDirection.RemainingTime, "remaining time when not inverse")

  Pass(native, BarData({icon_side = "LEFT"}))
  CheckPoint(PointOf(native.icon), "LEFT", base, "LEFT", "icon on the left")
  CheckPoint(PointOf(bar), "RIGHT", base, "RIGHT", "bar on the right")
  Pass(native, BarData({icon_side = "TOP"}))
  CheckPoint(PointOf(native.icon), "RIGHT", base, "RIGHT", "unknown side behaves as right, icon")
  CheckPoint(PointOf(bar), "LEFT", base, "LEFT", "unknown side behaves as right, bar")

  Pass(native, BarData({orientation = "HORIZONTAL_INVERSE"}))
  Eq(State[bar].orientation, "HORIZONTAL", "inverse horizontal orientation")
  Eq(State[bar].reverseFill, true, "inverse horizontal fill")
  Pass(native, BarData({orientation = "VERTICAL", width = 40, height = 100, icon_side = "LEFT"}))
  Eq(State[bar].orientation, "VERTICAL", "vertical orientation")
  Eq(State[bar].reverseFill, false, "vertical fill")
  Eq(native.iconSize, 40, "vertical icon size from the width")
  Eq(native.barWidth, 40, "vertical bar width")
  Eq(native.barHeight, 60, "vertical bar height")
  CheckPoint(PointOf(native.icon), "BOTTOM", base, "BOTTOM", "vertical icon on the left side")
  CheckPoint(PointOf(bar), "TOP", base, "TOP", "vertical bar on the left side")
  Pass(native, BarData({orientation = "VERTICAL_INVERSE", width = 40, height = 100, icon_side = "RIGHT"}))
  Eq(State[bar].orientation, "VERTICAL", "inverse vertical orientation")
  Eq(State[bar].reverseFill, true, "inverse vertical fill")
  CheckPoint(PointOf(native.icon), "TOP", base, "TOP", "vertical icon on the right side")
  CheckPoint(PointOf(bar), "BOTTOM", base, "BOTTOM", "vertical bar on the right side")
  Pass(native, BarData({orientation = "VERTICAL", width = 40, height = 30}))
  Eq(native.barHeight, 4, "vertical bar floor")
  Pass(native, BarData({width = 15, height = 20}))
  Eq(native.barWidth, 4, "horizontal bar floor")

  Pass(native, BarData({icon = false}))
  Eq(native.iconSize, 0, "no icon size")
  Eq(native.barWidth, 120, "bar takes the full width")
  Eq(native.barHeight, 20, "bar takes the full height")
  CheckPoint(PointOf(bar), "CENTER", base, "CENTER", "bar centered without icon")
  Eq(#State[bar].points, 1, "centered bar has one point")
  Eq(State[native.icon].shown, false, "icon hidden without the icon setting")
  Pass(native, BarData({icon = false, orientation = "VERTICAL", width = 40, height = 100}))
  Eq(native.barWidth, 40, "vertical bar full width")
  Eq(native.barHeight, 100, "vertical bar full height")

  local fetches = {}
  local fakeMedia = {Fetch = function(_, kind, name)
    fetches[#fetches + 1] = {kind, name}
    if name == "Missing" then return nil end
    return "Media\\" .. kind .. "\\" .. name
  end}
  Stub(LibStub.libs, "LibSharedMedia-3.0", fakeMedia)
  Pass(native, BarData({textureSource = "LSM", texture = "Smooth"}))
  Eq(BarTextureOf(native), "Media\\statusbar\\Smooth", "media texture")
  Eq(fetches[#fetches][1], "statusbar", "media kind")
  Pass(native, BarData({textureSource = "LSM"}))
  Eq(BarTextureOf(native), "Media\\statusbar\\Blizzard", "default media texture")
  Pass(native, BarData({textureSource = "LSM", texture = "Missing"}))
  Eq(BarTextureOf(native), "Interface\\Buttons\\WHITE8X8", "missing media falls back to white")
  Pass(native, BarData({textureInput = "Interface\\Custom\\Bar"}))
  Eq(BarTextureOf(native), "Interface\\Custom\\Bar", "typed texture")
  Pass(native, BarData({textureSource = "LSM", texture = "Smooth", textureInput = "Interface\\Custom\\Bar"}))
  Eq(BarTextureOf(native), "Media\\statusbar\\Smooth", "media source ignores the typed texture")
  Pass(native, BarData({textureSource = "typed", texture = "Smooth", textureInput = "Interface\\Custom\\Bar"}))
  Eq(BarTextureOf(native), "Interface\\Custom\\Bar", "other source uses the typed texture")
  Unstub()

  ResetCalls()
  local richElements = BarData({subRegions = {
    {type = "subborder", border_size = 3, border_offset = 2},
    {type = "subglow", glow = false},
    {type = "subtexture", textureTexture = "Interface\\Foo", anchor_area = "bar"},
    {type = "subtext", text_text = "%p"},
  }})
  Pass(native, richElements)
  Eq(#Calls(native.auraBar, "GetWidth") + #Calls(native.auraBar, "GetHeight") + #Calls(native.auraBar, "GetSize"), 0, "no size read on the bar")
  for _, call in ipairs(callLog) do
    Check(call.name ~= "GetWidth" and call.name ~= "GetHeight" and call.name ~= "GetSize", "no size read during a bar pass: " .. tostring(call.name))
  end

  local countBefore = #test.Frames.all
  Pass(native, richElements)
  Eq(#test.Frames.all, countBefore, "second identical pass creates nothing")

  styledTexts = nil
  native = NewNative()
  local textData = SecretData({
    regionType = "text", displayText = "label", font = "F", fontSize = 20, color = {1, 0.5, 0, 1}, outline = "OUTLINE", justify = "LEFT",
    shadowColor = {0, 0, 0, 1}, shadowXOffset = 1, shadowYOffset = -1, automaticWidth = "Fixed", fixedWidth = 150, wordWrap = "Elide",
  })
  Pass(native, textData)
  Eq(#styledTexts, 1, "main text styled once")
  local mainText = native.mainText
  Eq(State[mainText].objectType, "FontString", "main text type")
  Eq(State[mainText].parent, native.elementFrames.sharedBase, "main text parent")
  Eq(styledTexts[1].text, mainText, "style target")
  Eq(styledTexts[1].native, native, "native passed to the style function")
  local settings = styledTexts[1].settings
  Eq(settings.textFont, "F", "main font")
  Eq(settings.textSize, 20, "main size")
  Eq(settings.textColor, textData.color, "main color")
  Eq(settings.textOutline, "OUTLINE", "main outline")
  Eq(settings.textJustify, "LEFT", "main justify")
  Eq(settings.textShadowColor, textData.shadowColor, "main shadow color")
  Eq(settings.textShadowX, 1, "main shadow x")
  Eq(settings.textShadowY, -1, "main shadow y")
  Eq(settings.textAnchor, nil, "main text has no anchor setting")
  Eq(table.concat(styledTexts[1].arguments, ","), "text,18,CENTER,0,0", "style arguments")
  Eq(State[mainText].width, 150, "fixed width")
  Eq(LastCall(mainText, "SetWordWrap")[1], false, "elide stops wrapping")
  Eq(LastCall(mainText, "SetNonSpaceWrap")[1], false, "elide stops non space wrapping")
  Eq(State[mainText].shown, true, "main text shown")
  Eq(State[mainText].text, "label", "literal main text")
  Eq(State[native.button].width, 150, "button width from the fixed width")
  Eq(State[native.icon].shown, false, "text region has no icon")
  Eq(State[native.cooldown].shown, false, "text region has no cooldown")
  Eq(#ButtonCalls(native, "SetIcon"), 0, "text region binds no icon")
  Pass(native, SecretData({regionType = "text", displayText = "x", automaticWidth = "Fixed"}))
  Eq(State[native.mainText].width, 200, "fixed width defaults to 200")
  Eq(LastCall(native.mainText, "SetWordWrap")[1], true, "wrap by default")
  Eq(LastCall(native.mainText, "SetNonSpaceWrap")[1], true, "non space wrap by default")
  Pass(native, SecretData({regionType = "text", displayText = "x", automaticWidth = "Auto", fixedWidth = 150, wordWrap = "WordWrap"}))
  Eq(State[native.mainText].width, 0, "automatic width")
  Eq(LastCall(native.mainText, "SetWordWrap")[1], true, "word wrap kept")
  Eq(mainText, native.mainText, "main text reused")
  Pass(native, SecretData({regionType = "text", displayText = "x"}))
  Eq(State[native.mainText].width, 0, "width without a mode")
  Eq(styledTexts[1].arguments[2], 18, "default text size")

  local function TextData(text, extra)
    local data = SecretData({regionType = "text", displayText = text, color = {0.3, 0.4, 0.5, 1}})
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function Joined(arguments)
    local parts = {}
    for index = 1, 5 do parts[index] = tostring(arguments[index]) end
    return table.concat(parts, ",")
  end
  local formatterArguments, formatterCalls = nil, 0
  local formatterToken = {}
  Stub(private, "GetDurationTextFormatter", function(...)
    formatterArguments = {n = select("#", ...), ...}
    formatterCalls = formatterCalls + 1
    return formatterToken
  end)
  local colorArguments
  local colorToken = {}
  local colorResult = colorToken
  Stub(Display, "DurationColorCondition", function(...)
    colorArguments = {n = select("#", ...), ...}
    return colorResult
  end)

  native = NewNative()
  local durationData = TextData("%p")
  Pass(native, durationData)
  local bound = ButtonCalls(native, "SetDurationText")
  Eq(#bound, 1, "duration bound once")
  Eq(bound[1][1], native.mainText, "duration bound to the main text")
  Eq(bound[1][2].textFormatter, nil, "no format gives no formatter")
  Eq(bound[1][2].textColor, colorToken, "color condition passed")
  Eq(formatterCalls, 0, "formatter not asked without a format")
  Eq(colorArguments[1], durationData, "color condition data")
  Eq(colorArguments[2], durationData.color, "color condition base color")
  Eq(colorArguments[3], "color", "color condition property")
  Eq(colorArguments[4], nil, "no window on a text region")
  Eq(State[native.mainText].text, "", "bound text starts empty")
  Eq(#ButtonCalls(native, "SetApplicationCount") + #ButtonCalls(native, "SetSpellName"), 0, "only the duration is bound")

  Pass(native, TextData("%p", {displayText_format_p_time_format = -1}))
  Eq(ButtonCalls(native, "SetDurationText")[1][2].textFormatter, nil, "format -1 gives no formatter")
  Eq(formatterCalls, 0, "format -1 asks nothing")
  Pass(native, TextData("%p", {displayText_format_p_time_format = 2}))
  Eq(ButtonCalls(native, "SetDurationText")[1][2].textFormatter, formatterToken, "formatter passed")
  Eq(Joined(formatterArguments), "99,3,1,false,2", "formatter defaults")
  Pass(native, TextData("%p", {
    displayText_format_p_time_format = -2, displayText_format_p_time_legacy_floor = true,
    displayText_format_p_time_dynamic_threshold = 7, displayText_format_p_time_precision = 2,
  }))
  Eq(Joined(formatterArguments), "0,7,2,true,-2", "formatter options")
  Pass(native, SecretData({regionType = "text", displayText = "%p"}))
  NearAll("white base color without a color", {1, 1, 1, 1}, unpack(colorArguments[2], 1, 4))
  colorResult = nil
  Pass(native, TextData("%p"))
  bound = ButtonCalls(native, "SetDurationText")
  Eq(#bound, 1, "bound without a color curve")
  Eq(bound[1][2].textColor, nil, "no color curve")
  colorResult = colorToken

  native.behaviors.SetDurationText = function(_, options)
    if options.textColor then error("refused") end
  end
  Pass(native, TextData("%p", {displayText_format_p_time_format = 2}))
  bound = ButtonCalls(native, "SetDurationText")
  Eq(#bound, 2, "retry without the color")
  Eq(bound[2][2].textColor, nil, "retry drops the color")
  Eq(bound[2][2].textFormatter, formatterToken, "retry keeps the formatter")
  native.behaviors.SetDurationText = function() error("refused") end
  Check(not pcall(Pass, native, TextData("%p")), "second failure propagates")
  native.behaviors.SetDurationText = nil

  local stackToken = {}
  local stackArguments
  local stackResult = stackToken
  Stub(Display, "StackTextCondition", function(...)
    stackArguments = {n = select("#", ...), ...}
    return stackResult
  end)
  native = NewNative()
  local stackData = TextData("%s")
  Pass(native, stackData)
  local stackBound = ButtonCalls(native, "SetApplicationCount")
  Eq(#stackBound, 1, "stack bound once")
  Eq(stackBound[1][1], native.mainText, "stack bound to the main text")
  Eq(stackBound[1][2].formatter, stackToken, "stack formatter passed")
  Eq(stackArguments[1], stackData, "stack condition data")
  Eq(stackArguments[2], "color", "stack condition property")
  Eq(#ButtonCalls(native, "SetDurationText") + #ButtonCalls(native, "SetSpellName"), 0, "only the stack is bound")
  stackResult = nil
  Pass(native, TextData("%s"))
  stackBound = ButtonCalls(native, "SetApplicationCount")
  Eq(#stackBound, 1, "stack bound without a formatter")
  Eq(stackBound[1][2], nil, "plain stack binding")
  stackResult = stackToken
  native.behaviors.SetApplicationCount = function(_, options)
    if options then error("refused") end
  end
  Pass(native, TextData("%s"))
  stackBound = ButtonCalls(native, "SetApplicationCount")
  Eq(#stackBound, 2, "stack retry")
  Eq(stackBound[2][2], nil, "stack retry is plain")
  native.behaviors.SetApplicationCount = nil

  native = NewNative()
  Pass(native, TextData("%n"))
  local nameBound = ButtonCalls(native, "SetSpellName")
  Eq(#nameBound, 1, "name bound once")
  Eq(nameBound[1][1], native.mainText, "name bound to the main text")
  Eq(#ButtonCalls(native, "SetDurationText") + #ButtonCalls(native, "SetApplicationCount"), 0, "only the name is bound")

  Pass(native, TextData("%x"))
  Eq(State[native.mainText].text, "", "unknown code shows nothing")
  Eq(#ButtonCalls(native, "SetDurationText") + #ButtonCalls(native, "SetApplicationCount") + #ButtonCalls(native, "SetSpellName"), 0, "unknown code binds nothing")
  Pass(native, TextData("50%% done"))
  Eq(State[native.mainText].text, "50% done", "escaped percent")
  Pass(native, TextData("%p %s"))
  Eq(State[native.mainText].text, "", "two codes in one text show nothing")
  Pass(native, TextData(nil))
  Eq(State[native.mainText].text, "", "absent text")

  local windowResult, windowArguments = ">", nil
  Stub(Display, "RemainingWindow", function(...)
    windowArguments = {n = select("#", ...), ...}
    return windowResult, 10
  end)
  Stub(Display, "StyleRemainingList", nil)
  native = NewNative()
  local windowData = SecretData({subRegions = {
    {type = "subtext", text_text = "%p", text_color = {0.7, 0.6, 0.5, 1}, text_text_format_p_time_format = 3},
    {type = "subtext", text_text = "%s"},
  }})
  Pass(native, windowData)
  bound = ButtonCalls(native, "SetDurationText")
  Eq(#bound, 1, "element duration bound")
  Eq(bound[1][2].textColor, colorToken, "element color curve")
  Eq(bound[1][2].textFormatter, formatterToken, "element formatter")
  Eq(Joined(formatterArguments), "99,3,1,false,3", "element formatter arguments")
  Eq(colorArguments[2], windowData.subRegions[1].text_color, "element base color")
  Eq(colorArguments[3], "sub.1.text_color", "element color property")
  Eq(colorArguments[4][1], ">", "window operator")
  Eq(colorArguments[4][2], 10, "window seconds")
  Eq(stackArguments[2], "sub.2.text_color", "element stack property")
  Eq(#ButtonCalls(native, "SetApplicationCount"), 1, "element stack bound")

  colorResult = nil
  Pass(native, windowData)
  Eq(#ButtonCalls(native, "SetDurationText"), 0, "window without a color binds nothing")
  colorResult = colorToken
  native.behaviors.SetDurationText = function() error("refused") end
  Pass(native, windowData)
  Eq(#ButtonCalls(native, "SetDurationText"), 1, "no retry inside a window")
  native.behaviors.SetDurationText = nil

  windowResult = nil
  Pass(native, windowData)
  Eq(colorArguments[4], nil, "no window when the list gives no operator")
  windowArguments = nil
  Pass(native, SecretData({regionType = "aurabar", subRegions = windowData.subRegions}))
  Eq(colorArguments[4], nil, "no window on a bar")
  Eq(windowArguments, nil, "window not asked on a bar")
  Unstub()

  Stub(LibStub.libs, "LibSharedMedia-3.0", {Fetch = function(_, kind, name)
    if name == "Missing" then return nil end
    return "Media\\" .. kind .. "\\" .. name
  end})
  local function IconData(elements, extra)
    local data = SecretData({width = 50, height = 30, subRegions = elements})
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function NoSizeRead(label)
    for _, call in ipairs(callLog) do
      Check(call.name ~= "GetWidth" and call.name ~= "GetHeight" and call.name ~= "GetSize", label .. ": " .. tostring(call.name))
    end
  end

  native = NewNative()
  local textElement = {
    type = "subtext", text_text = "hello", text_font = "F2", text_fontSize = 14, text_color = {1, 0, 0, 1}, text_fontType = "OUTLINE",
    text_justify = "RIGHT", text_shadowColor = {0, 0, 1, 1}, text_shadowXOffset = 2, text_shadowYOffset = -2, text_selfPoint = "TOPLEFT",
    anchor_point = "INNER_BOTTOM", text_anchorXOffset = 5, anchorYOffset = 6, text_automaticWidth = "Fixed", text_fixedWidth = 90,
    text_wordWrap = "Elide", text_alpha = 0.4,
  }
  Pass(native, IconData({textElement}))
  Eq(#styledTexts, 1, "element text styled once")
  local textEntry = native.sharedElements[1]
  local elementText = textEntry.text
  Eq(State[elementText].objectType, "FontString", "element text type")
  Eq(State[elementText].parent, native.elementFrames.shared1, "element text parent")
  Eq(State[elementText].layer, "OVERLAY", "element text layer")
  Eq(styledTexts[1].text, elementText, "element text style target")
  Eq(styledTexts[1].native, native, "element text native")
  local elementSettings = styledTexts[1].settings
  Eq(elementSettings.textFont, "F2", "element font")
  Eq(elementSettings.textSize, 14, "element size")
  Eq(elementSettings.textColor, textElement.text_color, "element color")
  Eq(elementSettings.textOutline, "OUTLINE", "element outline")
  Eq(elementSettings.textJustify, "RIGHT", "element justify")
  Eq(elementSettings.textShadowColor, textElement.text_shadowColor, "element shadow color")
  Eq(elementSettings.textShadowX, 2, "element shadow x")
  Eq(elementSettings.textShadowY, -2, "element shadow y")
  Eq(elementSettings.textSelfPoint, "TOPLEFT", "element self point")
  Eq(elementSettings.textAnchor, "INNER_BOTTOM", "element anchor")
  Eq(elementSettings.textX, 5, "element x from the text offset")
  Eq(elementSettings.textY, 6, "element y falls back to the shared offset")
  Eq(table.concat(styledTexts[1].arguments, ","), "text,18,CENTER,0,0", "element style arguments")
  Eq(State[elementText].width, 90, "element fixed width")
  Eq(LastCall(elementText, "SetWordWrap")[1], false, "element elide")
  Eq(LastCall(elementText, "SetNonSpaceWrap")[1], false, "element elide non space")
  Near(State[elementText].alpha, 0.4, "element text alpha")
  Eq(State[elementText].shown, true, "element text shown")
  Eq(State[elementText].text, "hello", "element literal text")
  Eq(textEntry.frame, native.elementFrames.shared1, "entry frame")
  Eq(textEntry.button, native.button, "entry button")
  Eq(textEntry.native, native, "entry native")
  Eq(State[native.elementFrames.shared1].shown, true, "element frame shown")
  Eq(State[native.elementFrames.shared1].alpha, 1, "element frame opaque")

  Pass(native, IconData({{type = "subtext", text_text = "x"}}))
  Eq(native.sharedElements[1], textEntry, "entry reused")
  Eq(native.sharedElements[1].text, elementText, "element text reused")
  Eq(State[elementText].width, 0, "element width without a mode")
  Eq(State[elementText].alpha, 1, "element alpha default")
  Eq(styledTexts[1].settings.textFont, nil, "no font setting")

  Pass(native, IconData({{type = "subtext", text_text = "x", text_visible = false}}))
  Eq(#styledTexts, 0, "hidden element text not styled")
  Eq(State[elementText].shown, false, "hidden element text hidden")
  local hiddenNative = NewNative()
  Pass(hiddenNative, IconData({{type = "subtext", text_text = "x", text_visible = false}}))
  Eq(hiddenNative.sharedElements[1].text, nil, "hidden element text never created")

  Pass(native, IconData({textElement}))
  Eq(State[elementText].shown, true, "element text shown again")
  Pass(native, IconData({{type = "subtexture", textureTexture = "Interface\\Foo"}}))
  Eq(State[elementText].shown, false, "text hidden after a type change")
  local changedTexture = native.sharedElements[1].texture
  Eq(State[changedTexture].shown, true, "texture shown after the change")
  Pass(native, IconData({{type = "subborder"}}))
  Eq(State[changedTexture].shown, false, "texture hidden after a type change")
  local changedBorder = native.sharedElements[1].border
  Eq(State[changedBorder].shown, true, "border shown after the change")
  Pass(native, IconData({{type = "subtext", text_text = "x"}}))
  Eq(State[changedBorder].shown, false, "border hidden after a type change")

  native = NewNative()
  Pass(native, IconData({
    {type = "subtext", text_text = "x", secretAuraDetached = true},
    {type = "subtexture", textureTexture = "Interface\\Foo", secretAuraDetached = true},
    {type = "subcustom"},
    {type = "subborder", secretAuraDetached = true},
  }))
  Eq(#styledTexts, 0, "detached text not styled")
  Eq(native.sharedElements[1], nil, "detached text has no entry")
  Eq(native.elementFrames.shared1, nil, "detached text has no frame")
  Eq(native.sharedElements[2], nil, "detached texture has no entry")
  Eq(native.elementFrames.shared2, nil, "detached texture has no frame")
  Eq(native.sharedElements[3], nil, "unsupported kind has no entry")
  Eq(native.elementFrames.shared3, nil, "unsupported kind has no frame")
  Check(native.sharedElements[4] ~= nil and native.sharedElements[4].border ~= nil, "border is not detachable")
  Eq(Level(native.elementFrames.shared4), 10 + 3 * 4 + 3, "level counts skipped elements")

  biasOverride = function() return 0.25 end
  native = NewNative()
  local borderElement = {type = "subborder", border_size = 3, border_color = {1, 0, 0, 0.8}, border_alpha = 0.5, border_offset = 4}
  ResetCalls()
  Pass(native, IconData({borderElement}))
  NoSizeRead("border pass")
  local borderEntry = native.sharedElements[1]
  local border = borderEntry.border
  Eq(State[border].parent, native.elementFrames.shared1, "border parent")
  Eq(State[border].objectType, "Frame", "border type")
  Eq(State[border].width, 58, "border width with offset")
  Eq(State[border].height, 38, "border height with offset")
  Eq(State[border].scale, 1, "border scale")
  Near(State[border].alpha, 0.5, "border alpha")
  Eq(State[border].shown, true, "border shown")
  CheckPoint(PointOf(border), "CENTER", native.button, "CENTER", "border centered on the button")
  Eq(#State[border].points, 1, "border single point")
  Eq(LastCall(border, "SetIgnoreParentScale")[1], false, "border follows the parent scale")
  Eq(#borderEntry.borderPieces, 8, "eight border pieces")
  for index, piece in ipairs(borderEntry.borderPieces) do
    Eq(State[piece].parent, border, "piece parent " .. index)
    Eq(State[piece].layer, "BORDER", "piece layer " .. index)
    Eq(State[piece].texture, "Media\\border\\Square Full White", "piece texture " .. index)
    Eq(State[piece].wrapHorizontal, "REPEAT", "piece horizontal wrap " .. index)
    Eq(State[piece].wrapVertical, "REPEAT", "piece vertical wrap " .. index)
    ColorOf(State[piece].vertexColor, {1, 0, 0, 0.8}, "piece color " .. index)
    Eq(State[piece].shown, true, "piece shown " .. index)
    Eq(State[piece].snapToPixelGrid, true, "piece snapped " .. index)
    Eq(State[piece].texelSnappingBias, 0.25, "piece bias " .. index)
    Eq(LastCall(piece, "SetRoundLayoutToNearestPixel")[1], false, "piece not rounded " .. index)
  end
  Eq(State[borderEntry.borderPieces[1]].width, 3, "corner width")
  Eq(State[borderEntry.borderPieces[1]].height, 3, "corner height")
  Eq(State[borderEntry.borderPieces[4]].width, 3, "last corner width")

  local firstPieces = {}
  for index, piece in ipairs(borderEntry.borderPieces) do firstPieces[index] = piece end
  local objectCount = #test.Frames.all
  Pass(native, IconData({borderElement}))
  Eq(#test.Frames.all, objectCount, "second border pass creates nothing")
  for index, piece in ipairs(borderEntry.borderPieces) do Eq(piece, firstPieces[index], "piece reused " .. index) end

  Pass(native, IconData({{type = "subborder", border_size = 100}}))
  Eq(State[borderEntry.borderPieces[1]].width, 15, "thickness limited to half the smaller side")
  Pass(native, IconData({{type = "subborder", border_size = 0}}))
  Eq(State[borderEntry.borderPieces[1]].width, 0.1, "thickness at least a tenth")
  Eq(State[border].width, 50, "border width without an offset")
  Eq(State[border].height, 30, "border height without an offset")
  ColorOf(State[borderEntry.borderPieces[1]].vertexColor, {1, 1, 1, 1}, "default border color")
  Near(State[border].alpha, 1, "default border alpha")
  Pass(native, IconData({{type = "subborder", border_size = 2, border_offset = -100}}))
  Eq(State[border].width, 1, "border width at least one")
  Eq(State[border].height, 1, "border height at least one")

  ResetCalls()
  Pass(native, IconData({{type = "subborder", border_ppscale = true, border_size = 2.4, border_offset = 1.6, border_color = {0, 1, 0, 1}, border_alpha = 0.7}}))
  NoSizeRead("pixel border pass")
  Eq(LastCall(border, "SetIgnoreParentScale")[1], true, "pixel border ignores the parent scale")
  Near(State[border].scale, PixelUtil.GetPixelToUIUnitFactor(), "pixel border scale")
  Eq(#State[border].points, 2, "pixel border two points")
  CheckPoint(PointOf(border, 1), "TOPLEFT", native.button, "TOPLEFT", "pixel border top left")
  CheckPoint(PointOf(border, 2), "BOTTOMRIGHT", native.button, "BOTTOMRIGHT", "pixel border bottom right")
  Eq(PointOf(border, 1)[4], -2, "pixel border left offset rounded")
  Eq(PointOf(border, 1)[5], 2, "pixel border top offset rounded")
  Eq(PointOf(border, 2)[4], 2, "pixel border right offset rounded")
  Eq(PointOf(border, 2)[5], -2, "pixel border bottom offset rounded")
  Eq(LastCall(border, "SetRoundLayoutToNearestPixel")[1], true, "pixel border rounded")
  Near(State[border].alpha, 0.7, "pixel border alpha")
  Eq(State[borderEntry.borderPieces[1]].width, 2, "pixel thickness rounded")
  for index, piece in ipairs(borderEntry.borderPieces) do
    Eq(State[piece].snapToPixelGrid, false, "pixel piece unsnapped " .. index)
    Eq(State[piece].texelSnappingBias, 0, "pixel piece bias " .. index)
    Eq(LastCall(piece, "SetRoundLayoutToNearestPixel")[1], true, "pixel piece rounded " .. index)
    ColorOf(State[piece].vertexColor, {0, 1, 0, 1}, "pixel piece color " .. index)
  end
  Pass(native, IconData({{type = "subborder", border_ppscale = true, border_size = 0}}))
  Eq(State[borderEntry.borderPieces[1]].width, 1, "pixel thickness at least one")

  biasOverride = function() return 0.9 end
  Pass(native, IconData({borderElement}))
  Eq(State[border].scale, 1, "scale back to one")
  Eq(#State[border].points, 1, "single point back")
  CheckPoint(PointOf(border), "CENTER", native.button, "CENTER", "border centered again")
  for index, piece in ipairs(borderEntry.borderPieces) do
    Eq(State[piece].snapToPixelGrid, true, "piece snapped again " .. index)
    Eq(State[piece].texelSnappingBias, 0.25, "creation bias restored " .. index)
    Eq(LastCall(piece, "SetRoundLayoutToNearestPixel")[1], false, "piece unrounded " .. index)
  end
  biasOverride = nil

  native = NewNative()
  Pass(native, IconData({{type = "subborder", border_visible = false}, {type = "subborder", border_size = 3}}))
  Eq(native.sharedElements[1].border, nil, "hidden first border draws nothing")
  Eq(native.sharedElements[2].border, nil, "second border ignored after a hidden first one")
  Pass(native, IconData({{type = "subborder"}, {type = "subborder", border_size = 3}}))
  Check(native.sharedElements[1].border ~= nil, "first border drawn")
  Eq(native.sharedElements[2].border, nil, "second border ignored")
  local firstBorder = native.sharedElements[1].border
  Pass(native, IconData({{type = "subborder", border_visible = false}}))
  Eq(State[firstBorder].shown, false, "border hidden when turned off")
  native = NewNative()
  Pass(native, IconData({{type = "subborder", border_edge = "Missing"}, {type = "subborder"}}))
  Eq(native.sharedElements[1].border, nil, "unknown border file draws nothing")
  Eq(native.sharedElements[2].border, nil, "unknown first border still counts")
  Pass(native, IconData({{type = "subborder", border_edge = "Custom"}}))
  Eq(State[native.sharedElements[1].borderPieces[1]].texture, "Media\\border\\Custom", "named border file")

  native = NewNative()
  local barBorder = {type = "subborder", border_size = 2, border_offset = 3, anchor_area = "bar"}
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = true, subRegions = {barBorder}}))
  border = native.sharedElements[1].border
  CheckPoint(PointOf(border), "CENTER", native.bar, "CENTER", "border on the bar")
  Eq(State[border].width, native.barWidth + 6, "border width from the bar")
  Eq(State[border].height, native.barHeight + 6, "border height from the bar")
  barBorder.anchor_area = "icon"
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = true, subRegions = {barBorder}}))
  CheckPoint(PointOf(border), "CENTER", native.icon, "CENTER", "border on the icon")
  Eq(State[border].width, native.iconSize + 6, "border width from the icon")
  Eq(State[border].height, native.iconSize + 6, "border height from the icon")
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = false, subRegions = {barBorder}}))
  CheckPoint(PointOf(border), "CENTER", native.button, "CENTER", "border on the button without an icon")
  Eq(State[border].width, 126, "border width from the button")
  Eq(State[border].height, 26, "border height from the button")
  barBorder.anchor_area = "bar"
  Pass(native, IconData({barBorder}))
  CheckPoint(PointOf(border), "CENTER", native.button, "CENTER", "bar area ignored on an icon region")
  Unstub()

  local glowEvents = {}
  local timedResult, pandemicResult
  local timedArguments, pandemicArguments
  Stub(Display, "ResetPandemicGlows", function() end)
  Stub(Display, "StyleElementGlow", function(entry, button, support, anchor, element, glowWidth, glowHeight)
    glowEvents[#glowEvents + 1] = {
      name = "style", entry = entry, button = button, support = support, anchor = anchor, element = element,
      width = glowWidth, height = glowHeight,
    }
    entry.glowStale = nil
  end)
  Stub(Display, "ClearElementGlow", function(entry)
    glowEvents[#glowEvents + 1] = {name = "clear", entry = entry}
  end)
  Stub(Display, "TimedGlowHolder", function(...)
    timedArguments = {n = select("#", ...), ...}
    return timedResult
  end)
  Stub(Display, "PandemicGlowHolder", function(...)
    pandemicArguments = {n = select("#", ...), ...}
    return pandemicResult
  end)
  local function GlowEventsNamed(name)
    local found = {}
    for _, event in ipairs(glowEvents) do
      if event.name == name then found[#found + 1] = event end
    end
    return found
  end
  local function ClearedFor(entry)
    local found = {}
    for _, event in ipairs(glowEvents) do
      if event.name == "clear" and event.entry == entry then found[#found + 1] = event end
    end
    return found
  end
  local function ResetGlowEvents()
    glowEvents = {}
    timedArguments, pandemicArguments = nil, nil
  end

  native = NewNative()
  local plainGlow = {type = "subglow", glow = true, glowType = "Pixel", glowColor = {1, 0.5, 0, 1}}
  timedResult, pandemicResult = nil, nil
  Pass(native, IconData({plainGlow}))
  local glowEntry = native.sharedElements[1]
  local styled = GlowEventsNamed("style")
  Eq(#styled, 1, "glow styled once")
  Eq(styled[1].entry, glowEntry, "glow entry")
  Eq(styled[1].button, native.button, "glow button")
  Eq(styled[1].support, native.elementFrames.shared1, "glow on the element frame without a holder")
  Eq(styled[1].anchor, native.button, "glow anchor")
  Eq(styled[1].element, plainGlow, "glow element as configured")
  Eq(styled[1].width, 50, "glow width")
  Eq(styled[1].height, 30, "glow height")
  Eq(glowEntry.glowAnchor, native.button, "entry glow anchor")
  Eq(glowEntry.glowWidth, 50, "entry glow width")
  Eq(glowEntry.glowHeight, 30, "entry glow height")
  Eq(glowEntry.elementFrames.glow, native.elementFrames.shared1, "entry glow frame")
  Eq(#GlowEventsNamed("clear"), 0, "nothing cleared for a fresh glow")
  Eq(timedArguments[1], native, "timed holder native")
  Eq(timedArguments[2].id, "Test Aura", "timed holder data")
  Eq(timedArguments[3], 1, "timed holder index")
  Eq(timedArguments[4], native.elementFrames.shared1, "timed holder frame")
  Eq(pandemicArguments[3], 1, "pandemic holder index")

  ResetGlowEvents()
  local holder = CreateFrame("Frame")
  timedResult = holder
  local conditionalGlow = {type = "subglow", glow = false, glowType = "Pixel", glowColor = {0.1, 0.2, 0.3, 1}}
  Pass(native, IconData({{type = "subbackground"}, conditionalGlow}))
  styled = GlowEventsNamed("style")
  Eq(#styled, 1, "holder glow styled once")
  Eq(styled[1].support, holder, "glow on the timed holder")
  Check(styled[1].element ~= conditionalGlow, "holder glow works on a copy")
  Eq(styled[1].element.glow, true, "holder glow forced on")
  Eq(conditionalGlow.glow, false, "configured glow untouched")
  Check(styled[1].element.glowColor ~= conditionalGlow.glowColor, "copy is deep")
  NearAll("copied glow color", {0.1, 0.2, 0.3, 1}, unpack(styled[1].element.glowColor))
  Eq(styled[1].element.glowType, "Pixel", "copy keeps the glow type")
  Eq(timedArguments[3], 2, "timed holder index of the second element")
  Eq(pandemicArguments, nil, "pandemic holder not asked after a timed holder")
  Eq(native.sharedElements[2].elementFrames.glow, native.elementFrames.shared2, "glow frame kept with a holder")

  ResetGlowEvents()
  local pandemicHolder = CreateFrame("Frame")
  timedResult, pandemicResult = nil, pandemicHolder
  Pass(native, IconData({{type = "subbackground"}, conditionalGlow}))
  styled = GlowEventsNamed("style")
  Eq(#styled, 1, "pandemic glow styled once")
  Eq(styled[1].support, pandemicHolder, "glow on the pandemic holder")
  Eq(styled[1].element.glow, true, "pandemic glow forced on")
  Eq(pandemicArguments[1], native, "pandemic holder native")
  Eq(pandemicArguments[3], 2, "pandemic holder index")
  Eq(pandemicArguments[4], native.elementFrames.shared2, "pandemic holder frame")

  ResetGlowEvents()
  timedResult, pandemicResult = false, pandemicHolder
  Pass(native, IconData({{type = "subbackground"}, conditionalGlow}))
  Eq(#GlowEventsNamed("style"), 0, "no glow styled when the holder is false")
  Eq(native.sharedElements[2].elementFrames, nil, "no glow frames when the holder is false")
  Eq(pandemicArguments, nil, "pandemic holder not asked after false")
  Eq(#ClearedFor(native.sharedElements[2]), 1, "stale glow cleared at the end of the pass")
  Eq(native.sharedElements[2].glowStale, nil, "stale mark removed")
  Eq(native.sharedElements[2].glowAnchor, native.button, "glow anchor kept when the holder is false")

  ResetGlowEvents()
  timedResult, pandemicResult = nil, false
  Pass(native, IconData({{type = "subbackground"}, conditionalGlow}))
  Eq(#GlowEventsNamed("style"), 0, "no glow styled when the pandemic holder is false")
  Eq(#ClearedFor(native.sharedElements[2]), 1, "glow cleared when the pandemic holder is false")

  ResetGlowEvents()
  timedResult, pandemicResult = nil, nil
  native.sharedElements[2].glowStale = true
  Pass(native, IconData({{type = "subbackground"}, plainGlow}))
  local staleEntry = native.sharedElements[2]
  local clearPosition, stylePosition
  for position, event in ipairs(glowEvents) do
    if event.entry == staleEntry and event.name == "clear" then clearPosition = clearPosition or position end
    if event.entry == staleEntry and event.name == "style" then stylePosition = stylePosition or position end
  end
  Check(clearPosition and stylePosition and clearPosition < stylePosition, "stale glow cleared before the restyle")
  Eq(#ClearedFor(staleEntry), 1, "stale glow cleared once")

  ResetGlowEvents()
  Pass(native, IconData({}))
  Eq(#ClearedFor(native.sharedElements[2]), 1, "glow of a removed element cleared")
  Eq(native.sharedElements[2].glowStale, nil, "removed element no longer stale")
  Eq(State[native.elementFrames.shared2].shown, false, "removed element frame hidden")

  ResetGlowEvents()
  native = NewNative()
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = true, subRegions = {
    {type = "subglow", glow = true, anchor_area = "bar"}, {type = "subglow", glow = true, anchor_area = "icon"}, {type = "subglow", glow = true},
  }}))
  styled = GlowEventsNamed("style")
  Eq(styled[1].anchor, native.bar, "glow around the bar")
  Eq(styled[1].width, native.barWidth, "glow bar width")
  Eq(styled[1].height, native.barHeight, "glow bar height")
  Eq(styled[2].anchor, native.icon, "glow around the icon")
  Eq(styled[2].width, native.iconSize, "glow icon width")
  Eq(styled[2].height, native.iconSize, "glow icon height")
  Eq(styled[3].anchor, native.button, "glow around the button")
  Eq(styled[3].width, 120, "glow button width")
  Eq(styled[3].height, 20, "glow button height")
  Unstub()

  Stub(LibStub.libs, "LibSharedMedia-3.0", {Fetch = function(_, kind, name) return "Media\\" .. kind .. "\\" .. name end})
  native = NewNative()
  local textureElement = {
    type = "subtexture", textureTexture = "Interface\\Foo", textureColor = {0.2, 0.4, 0.6, 0.8}, textureDesaturate = true,
    textureBlendMode = "ADD", textureMirror = true, textureRotation = 90, texture_alpha = 0.3, xOffset = 10, yOffset = 6,
  }
  Pass(native, IconData({textureElement}))
  local textureEntry = native.sharedElements[1]
  local texture = textureEntry.texture
  Eq(State[texture].objectType, "Texture", "element texture type")
  Eq(State[texture].parent, native.elementFrames.shared1, "element texture parent")
  Eq(State[texture].layer, "ARTWORK", "element texture layer")
  Eq(State[texture].subLevel, 0, "element texture sublevel")
  Eq(State[texture].texture, "Interface\\Foo", "element texture file")
  ColorOf(State[texture].vertexColor, {0.2, 0.4, 0.6, 0.8}, "element texture color")
  Eq(State[texture].desaturated, true, "element texture desaturated")
  Eq(State[texture].blendMode, "ADD", "element texture blend")
  NearAll("mirrored coordinates", {1, 0, 0, 1}, unpack(State[texture].texCoord, 1, 4))
  Near(State[texture].rotation, math.pi / 2, "element texture rotation")
  Near(State[texture].alpha, 0.3, "element texture alpha")
  Eq(State[texture].shown, true, "element texture shown")
  Eq(#State[texture].points, 2, "area placement uses two points")
  CheckPoint(PointOf(texture, 1), "TOPLEFT", native.button, "TOPLEFT", "area top left")
  CheckPoint(PointOf(texture, 2), "BOTTOMRIGHT", native.button, "BOTTOMRIGHT", "area bottom right")
  Near(PointOf(texture, 1)[4], -5, "area left offset")
  Near(PointOf(texture, 1)[5], 3, "area top offset")
  Near(PointOf(texture, 2)[4], 5, "area right offset")
  Near(PointOf(texture, 2)[5], -3, "area bottom offset")
  Eq(State[texture].width, 0, "area placement sets no width")
  Eq(State[texture].height, 0, "area placement sets no height")

  Pass(native, IconData({{type = "subtexture"}}))
  Eq(textureEntry.texture, texture, "element texture reused")
  Eq(State[texture].texture, nil, "no file")
  ColorOf(State[texture].vertexColor, {1, 1, 1, 1}, "default element texture color")
  Eq(State[texture].desaturated, false, "default element texture saturation")
  Eq(State[texture].blendMode, "BLEND", "default element texture blend")
  NearAll("default coordinates", {0, 1, 0, 1}, unpack(State[texture].texCoord, 1, 4))
  Near(State[texture].rotation, 0, "default element texture rotation")
  Near(State[texture].alpha, 1, "default element texture alpha")
  CheckPoint(PointOf(texture, 1), "TOPLEFT", native.button, "TOPLEFT", "default area top left")
  Near(PointOf(texture, 1)[4], 0, "default area offset")

  Pass(native, IconData({{
    type = "subtexture", textureTexture = "Interface\\Foo", anchor_mode = "point", self_point = "BOTTOM", anchor_point = "INNER_TOP",
    xOffset = 4, yOffset = 2, width = 20, height = 10,
  }}))
  Eq(#State[texture].points, 1, "point placement uses one point")
  CheckPoint(PointOf(texture), "BOTTOM", native.inner, "TOP", "point placement")
  Eq(PointOf(texture)[4], 4, "point placement x")
  Eq(PointOf(texture)[5], 2, "point placement y")
  Eq(State[texture].width, 20, "point placement width")
  Eq(State[texture].height, 10, "point placement height")
  Pass(native, IconData({{type = "subtexture", textureTexture = "Interface\\Foo", anchor_mode = "point", anchor_point = "OUTER_RIGHT"}}))
  CheckPoint(PointOf(texture), "CENTER", native.outer, "RIGHT", "outer point placement")
  Eq(State[texture].width, 32, "default point width")
  Eq(State[texture].height, 32, "default point height")
  Pass(native, IconData({{type = "subtexture", textureTexture = "Interface\\Foo", anchor_mode = "point"}}))
  CheckPoint(PointOf(texture), "CENTER", native.button, "CENTER", "default point placement")

  native = NewNative()
  local barTexture = {type = "subtexture", textureTexture = "Interface\\Foo", anchor_area = "bar", xOffset = 4}
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = true, subRegions = {barTexture}}))
  texture = native.sharedElements[1].texture
  CheckPoint(PointOf(texture, 1), "TOPLEFT", native.bar, "TOPLEFT", "texture area on the bar")
  CheckPoint(PointOf(texture, 2), "BOTTOMRIGHT", native.bar, "BOTTOMRIGHT", "texture area on the bar corner")
  barTexture.anchor_area = "icon"
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = true, subRegions = {barTexture}}))
  CheckPoint(PointOf(texture, 1), "TOPLEFT", native.icon, "TOPLEFT", "texture area on the icon")
  Pass(native, SecretData({regionType = "aurabar", width = 120, height = 20, icon = false, subRegions = {barTexture}}))
  CheckPoint(PointOf(texture, 1), "TOPLEFT", native.button, "TOPLEFT", "texture area without an icon")

  Pass(native, IconData({{type = "subtexture", textureTexture = "Interface\\Foo", textureVisible = false}}))
  Eq(State[texture].shown, false, "invisible texture hidden")
  local invisibleNative = NewNative()
  Pass(invisibleNative, IconData({{type = "subtexture", textureTexture = "Interface\\Foo", textureVisible = false}}))
  Eq(invisibleNative.sharedElements[1].texture, nil, "invisible texture never created")

  local styleEnumeration = {Icon = "IconStyle"}
  Stub(Enum, "CustomAuraButtonDispelTypeTextureStyle", styleEnumeration)
  native = NewNative()
  Pass(native, IconData({{type = "subcdmdispel"}}))
  local dispelTexture = native.sharedElements[1].texture
  Eq(State[dispelTexture].parent, native.elementFrames.shared1, "dispel texture parent")
  Eq(State[dispelTexture].layer, "OVERLAY", "dispel texture layer")
  Eq(State[dispelTexture].subLevel, 1, "dispel texture sublevel")
  Eq(State[dispelTexture].shown, true, "dispel texture shown")
  NearAll("dispel coordinates", {0, 1, 0, 1}, unpack(State[dispelTexture].texCoord, 1, 4))
  Near(State[dispelTexture].rotation, 0, "dispel rotation")
  CheckPoint(PointOf(dispelTexture), "TOPLEFT", native.button, "TOPLEFT", "dispel default placement")
  Eq(State[dispelTexture].width, 16, "dispel default width")
  Eq(State[dispelTexture].height, 16, "dispel default height")
  local dispelCalls = ButtonCalls(native, "AddDispelTypeTexture")
  Eq(#dispelCalls, 1, "dispel texture registered once")
  Eq(dispelCalls[1][1], dispelTexture, "dispel registered texture")
  Eq(dispelCalls[1][2].showWhenHelpful, true, "dispel helpful default")
  Eq(dispelCalls[1][2].showWhenHarmful, true, "dispel harmful default")
  Eq(dispelCalls[1][2].style, "IconStyle", "dispel style")
  Pass(native, IconData({{type = "subcdmdispel", showWhenHelpful = false, showWhenHarmful = false, anchor_point = "OUTER_BOTTOMRIGHT", self_point = "BOTTOMRIGHT", width = 9, height = 7}}))
  dispelCalls = ButtonCalls(native, "AddDispelTypeTexture")
  Eq(dispelCalls[1][2].showWhenHelpful, false, "dispel helpful off")
  Eq(dispelCalls[1][2].showWhenHarmful, false, "dispel harmful off")
  CheckPoint(PointOf(dispelTexture), "BOTTOMRIGHT", native.outer, "BOTTOMRIGHT", "dispel custom placement")
  Eq(State[dispelTexture].width, 9, "dispel custom width")
  Eq(State[dispelTexture].height, 7, "dispel custom height")
  Pass(native, IconData({{type = "subcdmdispel", anchor_mode = "area", xOffset = 2}}))
  Eq(#State[dispelTexture].points, 2, "dispel area placement")
  CheckPoint(PointOf(dispelTexture, 1), "TOPLEFT", native.button, "TOPLEFT", "dispel area top left")
  Pass(native, IconData({{type = "subcdmdispel", dispelVisible = false}}))
  Eq(State[dispelTexture].shown, false, "invisible dispel hidden")
  Eq(#ButtonCalls(native, "AddDispelTypeTexture"), 0, "invisible dispel not registered")
  Stub(Enum, "CustomAuraButtonDispelTypeTextureStyle", nil)
  Pass(native, IconData({{type = "subcdmdispel"}}))
  Eq(ButtonCalls(native, "AddDispelTypeTexture")[1][2].style, nil, "no style without the enumeration")
  Unstub()
  native = NewNative({without = {AddDispelTypeTexture = true}})
  Pass(native, IconData({{type = "subcdmdispel"}}))
  Eq(State[native.sharedElements[1].texture].shown, true, "dispel texture drawn without the button method")
  Eq(#ButtonCalls(native, "AddDispelTypeTexture"), 0, "nothing registered without the button method")

  local dispelEvents = {}
  local edgeToken = {}
  local edgeCreations = 0
  local dispelDisplay = private.DispelTypeDisplay
  Stub(dispelDisplay, "CreateEdges", function(anchor)
    edgeCreations = edgeCreations + 1
    dispelEvents[#dispelEvents + 1] = {name = "create", anchor = anchor}
    return edgeToken
  end)
  Stub(dispelDisplay, "Layout", function(edges, anchor, element)
    dispelEvents[#dispelEvents + 1] = {name = "layout", edges = edges, anchor = anchor, element = element}
  end)
  Stub(dispelDisplay, "Bind", function(button, edges)
    dispelEvents[#dispelEvents + 1] = {name = "bind", button = button, edges = edges}
  end)
  Stub(dispelDisplay, "Hide", function(edges)
    dispelEvents[#dispelEvents + 1] = {name = "hide", edges = edges}
  end)
  local function DispelEventsNamed(name)
    local found = {}
    for _, event in ipairs(dispelEvents) do
      if event.name == name then found[#found + 1] = event end
    end
    return found
  end
  native = NewNative()
  local borderlessDispel = {type = "subcdmdispelborder", xOffset = 6, yOffset = 4}
  Pass(native, IconData({borderlessDispel}))
  local dispelEntry = native.sharedElements[1]
  local dispelAnchor = dispelEntry.dispelAnchor
  Eq(State[dispelAnchor].objectType, "Frame", "dispel border anchor type")
  Eq(State[dispelAnchor].parent, native.elementFrames.shared1, "dispel border anchor parent")
  Eq(State[dispelAnchor].shown, true, "dispel border anchor shown")
  Eq(#State[dispelAnchor].points, 2, "dispel border anchored by area")
  CheckPoint(PointOf(dispelAnchor, 1), "TOPLEFT", native.button, "TOPLEFT", "dispel border top left")
  Near(PointOf(dispelAnchor, 1)[4], -3, "dispel border left offset")
  Near(PointOf(dispelAnchor, 1)[5], 2, "dispel border top offset")
  Eq(edgeCreations, 1, "edges created once")
  Eq(dispelEntry.dispelEdges, edgeToken, "edges stored")
  Eq(DispelEventsNamed("create")[1].anchor, dispelAnchor, "edges created on the anchor")
  local layouts = DispelEventsNamed("layout")
  Eq(#layouts, 1, "edges laid out")
  Eq(layouts[1].edges, edgeToken, "layout edges")
  Eq(layouts[1].anchor, dispelAnchor, "layout anchor")
  Eq(layouts[1].element, borderlessDispel, "layout element")
  local binds = DispelEventsNamed("bind")
  Eq(#binds, 1, "edges bound")
  Eq(binds[1].button, native.button, "bind button")
  Eq(binds[1].edges, edgeToken, "bind edges")
  Pass(native, IconData({borderlessDispel}))
  Eq(edgeCreations, 1, "edges not created twice")
  Eq(dispelEntry.dispelAnchor, dispelAnchor, "dispel anchor reused")
  Eq(dispelEvents[#dispelEvents].name, "bind", "edges end bound")
  dispelEvents = {}
  Pass(native, IconData({{type = "subtext", text_text = "x"}}))
  Eq(State[dispelAnchor].shown, false, "dispel border anchor hidden by a type change")
  Eq(#DispelEventsNamed("hide"), 1, "edges hidden by a type change")
  Eq(DispelEventsNamed("hide")[1].edges, edgeToken, "hidden edges")
  Eq(#DispelEventsNamed("layout") + #DispelEventsNamed("bind"), 0, "no edges drawn for a text")
  dispelEvents = {}
  Pass(native, IconData({{type = "subcdmdispelborder", dispelVisible = false}}))
  Eq(State[dispelAnchor].shown, false, "invisible dispel border hidden")
  Eq(#DispelEventsNamed("layout") + #DispelEventsNamed("bind"), 0, "invisible dispel border not drawn")
  Eq(dispelEvents[#dispelEvents].name, "hide", "invisible dispel border ends hidden")
  native = NewNative({without = {AddDispelTypeTexture = true}})
  dispelEvents = {}
  Pass(native, IconData({borderlessDispel}))
  Eq(#DispelEventsNamed("layout"), 1, "edges laid out without the button method")
  Eq(#DispelEventsNamed("bind"), 0, "edges not bound without the button method")
  Unstub()

  local masqueGroups
  local masqueOptions
  local masqueCalls
  local function NewGroup(key)
    local group = {key = key, db = {}, callbacks = {}, calls = {}}
    local function Record(name, ...)
      group.calls[#group.calls + 1] = {name = name, ...}
    end
    function group.SetName(self, ...)
      Record("SetName", ...)
      if masqueOptions.setNameError then error("refused") end
    end
    function group.AddButton(self, button, regions, kind, strict)
      Record("AddButton", button, regions, kind, strict)
      if masqueOptions.addButtonError then error("refused") end
      button._MSQ_CFG = button._MSQ_CFG or {
        FrameWidth = 1, FrameHeight = 1,
        SetFrameSize = function(config, frameWidth, frameHeight) config.AppliedWidth, config.AppliedHeight = frameWidth, frameHeight end,
      }
    end
    function group.RemoveButton(self, button)
      Record("RemoveButton", button)
    end
    function group.ReSkin(self, button)
      Record("ReSkin", button)
      if masqueOptions.reSkinError then error("refused") end
      if masqueOptions.skinCoords then
        local regions = group.skinned
        regions.Icon:SetTexCoord(unpack(masqueOptions.skinCoords, 1, #masqueOptions.skinCoords))
      end
    end
    function group.RegisterCallback(self, ...)
      Record("RegisterCallback", ...)
      if masqueOptions.callbackError then error("refused") end
      group.callbacks[#group.callbacks + 1] = select(2, ...) or select(1, ...)
    end
    if not masqueOptions.withoutFrameSize then
      function group.SetFrameSize(self, ...)
        Record("SetFrameSize", ...)
      end
    end
    return group
  end
  local function InstallMasque(options)
    masqueOptions = options or {}
    masqueGroups = {}
    masqueCalls = {}
    local masque = {}
    function masque.Group(self, addon, key, uid)
      masqueCalls[#masqueCalls + 1] = {self = self, addon = addon, key = key, uid = uid}
      if masqueOptions.groupError then error("refused") end
      if masqueOptions.groupValue ~= nil then return masqueOptions.groupValue end
      masqueGroups[key] = masqueGroups[key] or NewGroup(key)
      return masqueGroups[key]
    end
    LibStub.libs.Masque = masque
    return masque
  end
  local function GroupCalls(group, name)
    local found = {}
    for _, call in ipairs(group.calls) do
      if call.name == name then found[#found + 1] = call end
    end
    return found
  end
  local function MasqueNative(options)
    local created = NewNative(options)
    ResolveElement(created, "sharedBase")
    return created
  end
  local function MasqueData(extra)
    local data = {regionType = "icon", id = "My Aura", uid = "uid-1", width = 50, height = 30}
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function Skin(group, native)
    group.skinned = {Icon = native.icon, Cooldown = native.cooldown}
  end

  local savedMasque = LibStub.libs.Masque
  LibStub.libs.Masque = nil
  native = MasqueNative()
  Display.StyleMasque(native, MasqueData())
  Eq(native.masqueGroup, nil, "no Masque, no group")
  Eq(State[native.icon].texCoord, nil, "no Masque, crop untouched")
  Stub(_G, "LibStub", nil)
  Display.StyleMasque(native, MasqueData())
  Eq(State[native.icon].texCoord, nil, "no LibStub, crop untouched")
  Unstub()

  local masque = InstallMasque()
  native = MasqueNative()
  local base = native.elementFrames.sharedBase
  Display.StyleMasque(native, MasqueData({zoom = 0.2}))
  Eq(#masqueCalls, 1, "group requested once")
  Eq(masqueCalls[1].self, masque, "group requested from Masque")
  Eq(masqueCalls[1].addon, "WeakAuras", "group addon")
  Eq(masqueCalls[1].key, "my_aura", "group key from the aura name")
  Eq(masqueCalls[1].uid, "uid-1", "group identifier")
  local group = masqueGroups.my_aura
  Eq(native.masqueGroup, group, "native attached")
  Eq(native.masqueKey, "my_aura", "native key")
  local added = GroupCalls(group, "AddButton")
  Eq(#added, 1, "button added once")
  Eq(added[1][1], base, "base frame added")
  Eq(added[1][2].Icon, native.icon, "icon region")
  Eq(added[1][2].Cooldown, native.cooldown, "cooldown region")
  Eq(added[1][3], "WA_Aura", "button type")
  Eq(added[1][4], true, "strict skinning")
  Eq(GroupCalls(group, "SetName")[1][1], "My Aura", "group named after the aura")
  Eq(#GroupCalls(group, "RegisterCallback"), 1, "callback registered once")
  Eq(#GroupCalls(group, "ReSkin"), 1, "skin applied once")
  Eq(GroupCalls(group, "ReSkin")[1][1], base, "skin applied to the base")
  local sized = GroupCalls(group, "SetFrameSize")
  Eq(#sized, 1, "group size set")
  Eq(sized[1][1], 50, "group width")
  Eq(sized[1][2], 30, "group height")
  Eq(sized[1][3], base, "group size button")
  Eq(base._MSQ_CFG.FrameWidth, 50, "pinned width")
  Eq(base._MSQ_CFG.FrameHeight, 30, "pinned height")
  base._MSQ_CFG:SetFrameSize(nil, nil)
  Eq(base._MSQ_CFG.AppliedWidth, 50, "pinned width reused")
  Eq(base._MSQ_CFG.AppliedHeight, 30, "pinned height reused")
  local plainLeft, plainRight, plainTop, plainBottom = Display.IconTexCoords(MasqueData({zoom = 0.2}))
  NearAll("crop without skin coordinates", {plainLeft, plainRight, plainTop, plainBottom}, unpack(State[native.icon].texCoord, 1, 4))
  Eq(native.masqueCoords, nil, "no skin coordinates")
  Eq(native.masqueData.id, "My Aura", "data remembered")

  Display.StyleMasque(native, MasqueData({zoom = 0.2}))
  Eq(#masqueCalls, 1, "group not requested twice")
  Eq(#GroupCalls(group, "AddButton"), 1, "button not added twice")
  Eq(#GroupCalls(group, "RegisterCallback"), 1, "callback not registered twice")
  Eq(#GroupCalls(group, "ReSkin"), 2, "skin applied again")

  masqueOptions.skinCoords = {0.25, 0, 0.25, 1, 0.75, 0, 0.75, 1}
  Skin(group, native)
  local zoomed = MasqueData({zoom = 0.2})
  Display.StyleMasque(native, zoomed)
  local left, right, top, bottom = Display.IconTexCoords(zoomed)
  Check(native.masqueCoords ~= nil, "skin coordinates kept")
  local expected = {}
  for index = 1, 8, 2 do
    expected[index] = left + masqueOptions.skinCoords[index] * (right - left)
    expected[index + 1] = top + masqueOptions.skinCoords[index + 1] * (bottom - top)
  end
  NearAll("skin coordinates mapped into the crop", expected, unpack(State[native.icon].texCoord, 1, 8))
  Display.StyleMasque(native, MasqueData())
  expected = {0.25, 0, 0.25, 1, 0.75, 0, 0.75, 1}
  NearAll("skin coordinates over the full art", expected, unpack(State[native.icon].texCoord, 1, 8))

  masqueOptions.skinCoords = {0.1, 0.9, 0.1, 0.9}
  Display.StyleMasque(native, MasqueData())
  Eq(native.masqueCoords, nil, "four skin values are not corners")
  NearAll("plain crop for four skin values", {0, 1, 0, 1}, unpack(State[native.icon].texCoord, 1, 4))
  masqueOptions.skinCoords = {0.25, 0, 0.25, 1, secretwrap(0.75), 0, 0.75, 1}
  Display.StyleMasque(native, MasqueData())
  Eq(native.masqueCoords, nil, "a secret skin value drops the corners")
  masqueOptions.skinCoords = nil

  group.db.Disabled = true
  masqueOptions.skinCoords = {0.25, 0, 0.25, 1, 0.75, 0, 0.75, 1}
  Display.StyleMasque(native, MasqueData())
  Eq(native.masqueCoords, nil, "disabled skin gives no corners")
  Eq(#State[native.icon].points, 2, "disabled skin anchors the icon on two points")
  CheckPoint(PointOf(native.icon, 1), "TOPLEFT", base, "TOPLEFT", "disabled skin icon top left")
  CheckPoint(PointOf(native.icon, 2), "BOTTOMRIGHT", base, "BOTTOMRIGHT", "disabled skin icon bottom right")
  NearAll("disabled skin plain crop", {0, 1, 0, 1}, unpack(State[native.icon].texCoord, 1, 4))
  group.db.Disabled = nil
  masqueOptions.skinCoords = nil

  local otherNative = MasqueNative()
  Display.StyleMasque(otherNative, MasqueData())
  Eq(otherNative.masqueGroup, group, "same name shares the group")
  Eq(#GroupCalls(group, "RegisterCallback"), 1, "shared group watched once")
  Eq(#GroupCalls(group, "AddButton"), 2, "second button added")

  local function ResyncCount(target)
    return #GroupCalls(target, "ReSkin")
  end
  Skin(group, native)
  local beforeCallback = ResyncCount(group)
  local callback = group.callbacks[1]
  Check(type(callback) == "function", "callback is a function")
  callback("unused", 42, {})
  Eq(ResyncCount(group), beforeCallback, "resync waits one frame")
  test.Environment.Advance(1)
  Eq(ResyncCount(group), beforeCallback + 2, "both natives resynced after the frame")

  Display.StyleMasque(native, MasqueData({width = 80, height = 60}))
  beforeCallback = ResyncCount(group)
  local sizeCalls = #GroupCalls(group, "SetFrameSize")
  callback()
  test.Environment.Advance(1)
  Eq(ResyncCount(group), beforeCallback + 2, "resync again")
  local lastSize = GroupCalls(group, "SetFrameSize")
  Eq(lastSize[#lastSize - 1][1], 80, "resync uses the last data width")
  Eq(lastSize[#lastSize - 1][2], 60, "resync uses the last data height")

  Display.StyleMasque(otherNative, MasqueData({regionType = "aurabar"}))
  Eq(otherNative.masqueGroup, nil, "bar detached from the group")
  beforeCallback = ResyncCount(group)
  callback()
  test.Environment.Advance(1)
  Eq(ResyncCount(group), beforeCallback + 1, "detached native not resynced")

  masqueOptions.reSkinError = true
  callback()
  Check(pcall(test.Environment.Advance, 1), "failing skin does not raise in the callback")
  masqueOptions.reSkinError = nil

  local removals = #GroupCalls(group, "RemoveButton")
  Display.StyleMasque(native, MasqueData({id = "Other Aura"}))
  Eq(#GroupCalls(group, "RemoveButton"), removals + 1, "old group released on a key change")
  Eq(GroupCalls(group, "RemoveButton")[removals + 1][1], base, "released base")
  Eq(native.masqueKey, "other_aura", "new key")
  Eq(native.masqueGroup, masqueGroups.other_aura, "new group")
  Eq(masqueCalls[#masqueCalls].key, "other_aura", "new group requested")
  beforeCallback = ResyncCount(group)
  callback()
  test.Environment.Advance(1)
  Eq(ResyncCount(group), beforeCallback, "native no longer follows its old group")

  native.masqueCoords = {1, 2, 3, 4, 5, 6, 7, 8}
  removals = #GroupCalls(masqueGroups.other_aura, "RemoveButton")
  Display.StyleMasque(native, MasqueData({regionType = "aurabar"}))
  Eq(#GroupCalls(masqueGroups.other_aura, "RemoveButton"), removals + 1, "bar releases the button")
  Eq(native.masqueGroup, nil, "bar group cleared")
  Eq(native.masqueKey, nil, "bar key cleared")
  Eq(native.masqueCoords, nil, "bar coordinates cleared")
  Eq(native.masqueData, nil, "bar data cleared")
  NearAll("bar crop", {0, 1, 0, 1}, unpack(State[native.icon].texCoord, 1, 4))
  Display.StyleMasque(native, MasqueData())
  Eq(native.masqueGroup, masqueGroups.my_aura, "attached again")
  native.remainingHidesIcon = true
  removals = #GroupCalls(masqueGroups.my_aura, "RemoveButton")
  Display.StyleMasque(native, MasqueData())
  Eq(#GroupCalls(masqueGroups.my_aura, "RemoveButton"), removals + 1, "hidden icon releases the button")
  Eq(native.masqueGroup, nil, "hidden icon group cleared")
  native.remainingHidesIcon = nil
  local baseless = NewNative()
  baseless.masqueGroup, baseless.masqueKey = masqueGroups.my_aura, "my_aura"
  removals = #GroupCalls(masqueGroups.my_aura, "RemoveButton")
  Display.StyleMasque(baseless, MasqueData())
  Eq(baseless.masqueGroup, nil, "native without a base detached")
  Eq(#GroupCalls(masqueGroups.my_aura, "RemoveButton"), removals, "no release without a base")

  masque = InstallMasque({setNameError = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "failing group name does not raise")
  Eq(native.masqueGroup, nil, "failing group name attaches nothing")
  Eq(#GroupCalls(masqueGroups.my_aura, "RemoveButton"), 1, "failed attach releases the button")
  Eq(GroupCalls(masqueGroups.my_aura, "RemoveButton")[1][1], native.elementFrames.sharedBase, "failed attach released base")
  NearAll("failed attach crop", {0, 1, 0, 1}, unpack(State[native.icon].texCoord, 1, 4))
  masque = InstallMasque({addButtonError = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "failing add does not raise")
  Eq(native.masqueGroup, nil, "failing add attaches nothing")
  Eq(#GroupCalls(masqueGroups.my_aura, "RemoveButton"), 1, "failing add releases the button")
  masque = InstallMasque({groupError = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "failing group does not raise")
  Eq(native.masqueGroup, nil, "failing group attaches nothing")
  NearAll("failing group crop", {0, 1, 0, 1}, unpack(State[native.icon].texCoord, 1, 4))
  masque = InstallMasque({groupValue = "not a table"})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "group of the wrong kind does not raise")
  Eq(native.masqueGroup, nil, "group of the wrong kind attaches nothing")
  masque = InstallMasque({reSkinError = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "failing skin does not raise")
  Eq(native.masqueGroup, masqueGroups.my_aura, "failing skin keeps the group")
  masque = InstallMasque({callbackError = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "failing callback registration does not raise")
  Eq(native.masqueGroup, masqueGroups.my_aura, "failing callback registration keeps the group")
  masque = InstallMasque({withoutFrameSize = true})
  native = MasqueNative()
  Check(pcall(Display.StyleMasque, native, MasqueData()), "group without a size method does not raise")
  Eq(native.masqueGroup, masqueGroups.my_aura, "group without a size method attached")

  InstallMasque()
  local indicatorCalls, gateCalls, remainingCalls = {}, {}, {}
  Stub(Display, "StyleNativeConditionIndicators", function(...) indicatorCalls[#indicatorCalls + 1] = {...} end)
  Stub(Display, "StyleDurationGate", function(...) gateCalls[#gateCalls + 1] = {...} end)
  local hideIcon = false
  Stub(Display, "StyleRemainingList", function(...)
    remainingCalls[#remainingCalls + 1] = {...}
    if hideIcon then (...).remainingHidesIcon = true end
  end)
  native = NewNative()
  local passData = SecretData({width = 50, height = 30, id = "Pass Aura"})
  Pass(native, passData)
  Eq(#indicatorCalls, 1, "condition indicators styled once")
  Eq(indicatorCalls[1][1], native, "condition indicators native")
  Eq(indicatorCalls[1][2], passData, "condition indicators data")
  Eq(#remainingCalls, 1, "remaining list styled once")
  Eq(remainingCalls[1][1], native, "remaining list native")
  Eq(remainingCalls[1][2], passData, "remaining list data")
  Eq(#gateCalls, 1, "duration gate styled once")
  Eq(gateCalls[1][1], native, "duration gate native")
  Eq(gateCalls[1][2], passData, "duration gate data")
  Eq(native.masqueKey, "pass_aura", "pass attaches Masque")
  hideIcon = true
  removals = #GroupCalls(masqueGroups.pass_aura, "RemoveButton")
  Pass(native, passData)
  Eq(native.masqueGroup, nil, "hidden icon detached from Masque at the end of the pass")
  Eq(#GroupCalls(masqueGroups.pass_aura, "RemoveButton"), removals + 1, "hidden icon released")
  hideIcon = false
  native.remainingHidesIcon = nil
  Stub(Display, "StyleRemainingList", nil)
  Stub(Display, "StyleDurationGate", nil)
  native = NewNative()
  Check(pcall(Pass, native, passData), "pass without the optional styles")
  Eq(native.masqueKey, "pass_aura", "pass without the optional styles attaches Masque")
  Unstub()
  LibStub.libs.Masque = savedMasque
  meta.__index = originalIndex
end

-- SecretAuraAppearance exports: icon crop, Masque pin, detached and supported elements, legacy migration, dimensions,
-- text codes, validation messages, text settings, and a style pass on a fake native button (step order, reset).
-- Not covered here: unit glow, the injected StyleGlow parameter, Masque groups (no Masque in the harness), borders, bars.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local function Near(actual, expected, label)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9,
      ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function NearAll(label, expected, ...)
    local values = {...}
    assert(#values == #expected, label .. ": value count " .. #values)
    for index, value in ipairs(expected) do Near(values[index], value, label .. " #" .. index) end
  end
  local function Secret(extra)
    local data = {
      regionType = "icon", id = "Test Aura", uid = "uid",
      triggers = {{trigger = {type = "secretAura", unit = "player"}}},
      blizzardAuraDisplay = {},
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end

  -- IconTexCoords
  NearAll("non icon default", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "aurabar"}))
  NearAll("non icon zoom", {0.1, 0.9, 0.1, 0.9}, Display.IconTexCoords({regionType = "aurabar", zoom = 0.2}))
  NearAll("non icon zoom argument wins", {0.25, 0.75, 0.25, 0.75}, Display.IconTexCoords({regionType = "text", zoom = 0.2}, 0.5))
  NearAll("non icon margin bounded", {0.45, 0.55, 0.45, 0.55}, Display.IconTexCoords({regionType = "text", zoom = 5}))
  NearAll("non icon negative zoom", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "text", zoom = -1}))
  NearAll("icon default", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "icon"}))
  NearAll("icon zoom", {0.025, 0.975, 0.025, 0.975}, Display.IconTexCoords({regionType = "icon", zoom = 0.1}))
  NearAll("icon zoom argument wins", {0.25, 0.75, 0.25, 0.75}, Display.IconTexCoords({regionType = "icon", zoom = 0.1}, 1))
  NearAll("icon wide without keepAspectRatio", {0, 1, 0, 1}, Display.IconTexCoords({regionType = "icon", width = 100, height = 50}))
  NearAll("icon wide keepAspectRatio", {0, 1, 0.25, 0.75},
    Display.IconTexCoords({regionType = "icon", width = 100, height = 50, keepAspectRatio = true}))
  NearAll("icon tall keepAspectRatio", {0.25, 0.75, 0, 1},
    Display.IconTexCoords({regionType = "icon", width = 50, height = 100, keepAspectRatio = true}))
  NearAll("icon zoom ratio and offsets", {-0.05, 0.85, 0.325, 0.775}, Display.IconTexCoords({
    regionType = "icon", width = 100, height = 50, keepAspectRatio = true, zoom = 0.2, texXOffset = 0.1, texYOffset = 0.05,
  }))

  -- StyleIconTexCoords
  local function FakeIcon()
    local icon = {}
    function icon:SetTexCoord(...) self.coords = {...} end
    return icon
  end
  local native = {icon = FakeIcon()}
  Display.StyleIconTexCoords(native, {regionType = "icon", zoom = 0.1})
  NearAll("style coords without skin", {0.025, 0.975, 0.025, 0.975}, unpack(native.icon.coords))
  native = {icon = FakeIcon(), masqueCoords = {0.1, 0.1, 0.1, 0.9, 0.9, 0.1, 0.9, 0.9}}
  Display.StyleIconTexCoords(native, {regionType = "aurabar"})
  NearAll("skin coords ignored outside icon", {0, 1, 0, 1}, unpack(native.icon.coords))
  Display.StyleIconTexCoords(native, {regionType = "icon"})
  assert(#native.icon.coords == 8, "skin coords not applied as 8 values")
  NearAll("skin coords on full window", {0.1, 0.1, 0.1, 0.9, 0.9, 0.1, 0.9, 0.9}, unpack(native.icon.coords))
  Display.StyleIconTexCoords(native, {regionType = "icon", zoom = 0.2})
  NearAll("skin coords remapped in the zoomed window", {0.14, 0.14, 0.14, 0.86, 0.86, 0.14, 0.86, 0.86}, unpack(native.icon.coords))
  Display.StyleIconTexCoords(native, {regionType = "icon"}, 0.2)
  NearAll("skin coords zoom argument", {0.14, 0.14, 0.14, 0.86, 0.86, 0.14, 0.86, 0.86}, unpack(native.icon.coords))

  -- MasquePinSize
  private.MasquePinSize(nil, 10, 10)
  private.MasquePinSize({}, 10, 10)
  local calls = {}
  local config = {}
  function config:SetFrameSize(width, height, ...) calls[#calls + 1] = {width, height, ...} end
  local masqueButton = {_MSQ_CFG = config}
  private.MasquePinSize(masqueButton, nil, 10)
  private.MasquePinSize(masqueButton, 10, nil)
  assert(config.FrameWidth == nil and config.waPinnedSetFrameSize == nil, "pin applied with a missing dimension")
  private.MasquePinSize(masqueButton, 40, 30)
  assert(config.FrameWidth == 40 and config.FrameHeight == 30, "pinned size not stored")
  local original = config.waPinnedSetFrameSize
  assert(type(original) == "function", "original size function not marked")
  assert(masqueButton.waPinnedSetFrameSize == nil, "marker placed on the button")
  local wrapper = config.SetFrameSize
  assert(wrapper ~= original, "size function not wrapped")
  private.MasquePinSize(masqueButton, 50, 20)
  assert(config.SetFrameSize == wrapper and config.waPinnedSetFrameSize == original, "wrapped twice")
  assert(config.FrameWidth == 50 and config.FrameHeight == 20, "pinned size not updated")
  config:SetFrameSize(nil, nil, "extra")
  assert(calls[1][1] == 50 and calls[1][2] == 20 and calls[1][3] == "extra", "call without width did not reuse the pinned size")
  config:SetFrameSize(16, 12)
  assert(calls[2][1] == 16 and calls[2][2] == 12, "call with width altered")
  assert(config.FrameWidth == 16 and config.FrameHeight == 12, "call with width not remembered")
  config:SetFrameSize(nil, nil)
  assert(calls[3][1] == 16 and calls[3][2] == 12, "remembered size not reused")
  local buttonOwned = {_MSQ_CFG = {}}
  function buttonOwned:SetFrameSize(width, height) self.last = {width, height} end
  private.MasquePinSize(buttonOwned, 8, 9)
  assert(buttonOwned.waPinnedSetFrameSize and buttonOwned._MSQ_CFG.waPinnedSetFrameSize == nil, "marker not on the button")
  buttonOwned:SetFrameSize(nil, nil)
  assert(buttonOwned.last[1] == 8 and buttonOwned.last[2] == 9, "button size function not pinned")

  -- supportedElements
  local supported = {"subbackground", "subforeground", "subtext", "subborder", "subglow", "subtexture", "subcdmdispel", "subcdmdispelborder"}
  local count = 0
  for _ in pairs(Display.supportedElements) do count = count + 1 end
  assert(count == #supported, "supportedElements count " .. count)
  for _, kind in ipairs(supported) do assert(Display.supportedElements[kind] == true, kind) end

  -- IsDetachedElement
  local plain = {regionType = "icon"}
  assert(Display.IsDetachedElement(plain, {type = "subtext", secretAuraDetached = true}) == false, "non secret aura reported detached")
  assert(Display.IsDetachedElement(plain, nil) == false, "non secret aura, no element")
  local secret = Secret()
  assert(Display.IsDetachedElement(secret, nil) == nil, "nil element")
  assert(Display.IsDetachedElement(secret, {type = "subtext"}) == false, "unmarked text detached")
  assert(Display.IsDetachedElement(secret, {type = "subtext", secretAuraDetached = false}) == false, "false marker")
  assert(Display.IsDetachedElement(secret, {type = "subtext", secretAuraDetached = true}) == true, "detached text")
  assert(Display.IsDetachedElement(secret, {type = "subtexture", secretAuraDetached = true}) == true, "detached texture")
  assert(Display.IsDetachedElement(secret, {type = "subglow", secretAuraDetached = true}) == false, "detached glow")
  assert(Display.IsDetachedElement(secret, {type = "subborder", secretAuraDetached = true}) == false, "detached border")

  -- IsDetachedProperty
  secret.subRegions = {{type = "subtext"}, {type = "subtext", secretAuraDetached = true}, {type = "subglow", secretAuraDetached = true}}
  assert(Display.IsDetachedProperty(secret, "sub.1.text_color") == false, "attached property")
  assert(Display.IsDetachedProperty(secret, "sub.2.text_color") == true, "detached property")
  assert(Display.IsDetachedProperty(secret, "sub.3.glowColor") == false, "detached glow property")
  assert(Display.IsDetachedProperty(secret, "sub.9.text_color") == false, "missing element property")
  assert(Display.IsDetachedProperty(secret, "color") == false, "root property")
  assert(Display.IsDetachedProperty(secret, "sub.2") == false, "property without field")
  assert(Display.IsDetachedProperty(Secret(), "sub.1.text_color") == false, "no subRegions")
  assert(Display.IsDetachedProperty(plain, "sub.1.text_color") == false, "non secret aura")

  -- CanAddElement
  assert(Display.CanAddElement(plain, "subtext") == true, "non secret, text")
  assert(Display.CanAddElement(plain, "subcustom") == true, "non secret, unknown type")
  assert(Display.CanAddElement(plain, "subcdmdispel") == false, "non secret, dispel without CDM progress")
  assert(Display.CanAddElement(plain, "subcdmdispelborder") == false, "non secret, dispel border without CDM progress")
  assert(Display.CanAddElement(Secret(), "subcdmdispel") == true, "secret, dispel")
  assert(Display.CanAddElement(Secret(), "subcdmdispelborder") == true, "secret, dispel border")
  for _, kind in ipairs(supported) do
    assert(Display.CanAddElement(Secret(), kind) == true, "secret, " .. kind)
  end
  assert(Display.CanAddElement(Secret(), "subcustom") == false, "secret, unknown type")
  assert(Display.CanAddElement(Secret({subRegions = {{type = "subtext"}}}), "subborder") == true, "first border refused")
  assert(Display.CanAddElement(Secret({subRegions = {{type = "subtext"}, {type = "subborder"}}}), "subborder") == false, "second border allowed")
  assert(Display.CanAddElement(Secret({subRegions = {{type = "subborder"}}}), "subtext") == true, "text refused next to a border")

  -- Dimensions
  local width, height = Display.Dimensions({regionType = "icon", blizzardAuraDisplay = {}})
  assert(width == 64 and height == 64, "default icon size")
  width, height = Display.Dimensions({regionType = "aurabar", width = 120, height = 20, blizzardAuraDisplay = {}})
  assert(width == 120 and height == 20, "bar size")
  width, height = Display.Dimensions({regionType = "icon", width = 2, height = 0, blizzardAuraDisplay = {}})
  assert(width == 4 and height == 4, "icon size floor")
  width, height = Display.Dimensions({regionType = "text", blizzardAuraDisplay = {}})
  Near(width, 200, "default text width")
  Near(height, 21.6, "default text height")
  width, height = Display.Dimensions({regionType = "text", fixedWidth = 300, fontSize = 10, blizzardAuraDisplay = {}})
  Near(width, 300, "fixed text width")
  Near(height, 12, "text height from font size")
  width, height = Display.Dimensions({regionType = "text", fixedWidth = 1, fontSize = 1, blizzardAuraDisplay = {}})
  assert(width == 4 and height == 4, "text size floor")
  width, height = Display.Dimensions({regionType = "text", fontSize = 40, width = 999, height = 999, blizzardAuraDisplay = {textHeight = 33}})
  assert(width == 200 and height == 33, "text height setting, width and height ignored")
  _, height = Display.Dimensions({regionType = "text", blizzardAuraDisplay = {textHeight = 1}})
  assert(height == 4, "text height floor")

  -- TextKind
  assert(Display.TextKind("%p") == "duration" and Display.TextKind("%s") == "stack" and Display.TextKind("%n") == "name", "exact codes")
  assert(Display.TextKind(nil) == "literal" and Display.TextKind("") == "literal", "empty is literal")
  assert(Display.TextKind("hello") == "literal", "plain text")
  assert(Display.TextKind("100%%") == "literal" and Display.TextKind("%%p") == "literal", "escaped percent")
  assert(Display.TextKind("%c") == nil and Display.TextKind("%P") == nil, "unknown code")
  assert(Display.TextKind("%p s") == nil and Display.TextKind(" %p") == nil, "code with other text")
  assert(Display.TextKind("%%%c") == nil and Display.TextKind("50%") == nil, "lone percent")

  -- TextSettings
  local settings = Display.TextSettings({
    text_font = "F", text_fontSize = 12, text_color = {1, 0, 0, 1}, text_fontType = "OUTLINE", text_justify = "LEFT",
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 1, text_shadowYOffset = -1, text_selfPoint = "TOP",
    anchor_point = "BOTTOM", anchorXOffset = 5, anchorYOffset = 6,
  })
  assert(settings.textFont == "F" and settings.textSize == 12 and settings.textOutline == "OUTLINE" and settings.textJustify == "LEFT", "text fields")
  assert(settings.textColor[1] == 1 and settings.textShadowColor[4] == 1, "text colors")
  assert(settings.textShadowX == 1 and settings.textShadowY == -1 and settings.textSelfPoint == "TOP" and settings.textAnchor == "BOTTOM", "text placement")
  assert(settings.textX == 5 and settings.textY == 6, "unprefixed offsets")
  settings = Display.TextSettings({text_anchorXOffset = 7, anchorXOffset = 5, text_anchorYOffset = 0, anchorYOffset = 6})
  assert(settings.textX == 7 and settings.textY == 0, "prefixed offsets win")
  settings = Display.TextSettings({})
  assert(settings.textFont == nil and settings.textSize == nil and settings.textX == nil and settings.textAnchor == nil, "empty element")

  -- ValidateAppearance
  local MESSAGE_CODES = "You can only use %p, %s, %n or hardcoded text. Put each code in its own text element. Custom text (%c) is not supported."
  local MESSAGE_DUPLICATE = "Secret auras support one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text."
  local MESSAGE_UNSUPPORTED = "This sub element is not supported by Secret Auras. Use Text, Texture or Glow."
  local MESSAGE_DETACHED = "Detached Text uses hardcoded text. Use other triggers and Conditions to control when it appears."
  local MESSAGE_GLOW = "Choose Action Button Glow, Pixel Glow, Autocast Shine or Proc Glow."
  local function Validate(elements, extra)
    return Display.ValidateAppearance(Secret((function()
      extra = extra or {}
      extra.subRegions = elements
      return extra
    end)()))
  end
  assert(Validate({}) == nil and Validate(nil) == nil, "empty appearance")
  assert(Validate({{type = "subtext", text_text = "%p"}, {type = "subtext", text_text = "%s"}, {type = "subtext", text_text = "%n"},
    {type = "subtext", text_text = "label"}, {type = "subtext", text_text = "other"}}) == nil, "one of each kind and literals")
  assert(Validate({{type = "subtext", text_text = "%c"}}) == MESSAGE_CODES, "unknown code")
  assert(Validate({{type = "subtext", text_text = "%c", text_visible = false}}) == nil, "hidden unknown code")
  assert(Validate({{type = "subtext"}}) == nil, "text without text field")
  assert(Validate({{type = "subtext", text_text = "%p"}, {type = "subtext", text_text = "%p"}}) == MESSAGE_DUPLICATE, "duplicate duration")
  assert(Validate({{type = "subtext", text_text = "%s"}, {type = "subtext", text_text = "%s"}}) == MESSAGE_DUPLICATE, "duplicate stack")
  assert(Validate({{type = "subtext", text_text = "%n"}, {type = "subtext", text_text = "%n"}}) == MESSAGE_DUPLICATE, "duplicate name")
  assert(Validate({{type = "subtext", text_text = "%p"}, {type = "subtext", text_text = "%p", text_visible = false}}) == nil, "hidden duplicate")
  assert(Validate({{type = "subtext", text_text = "hi"}, {type = "subtext", text_text = "hi"}}) == nil, "duplicate literal")
  assert(Validate({{type = "subcustom"}}) == MESSAGE_UNSUPPORTED, "unsupported element")
  assert(Validate({{type = "subborder"}, {type = "subborder"}}) == nil, "borders")
  assert(Validate({{type = "subtext", text_text = "label", secretAuraDetached = true}}) == nil, "detached literal text")
  assert(Validate({{type = "subtext", text_text = "%p", secretAuraDetached = true}}) == MESSAGE_DETACHED, "detached duration text")
  assert(Validate({{type = "subtext", text_text = "%c", secretAuraDetached = true}}) == MESSAGE_DETACHED, "detached unknown code")
  assert(Validate({{type = "subtext", text_text = "%p", secretAuraDetached = true}, {type = "subtext", text_text = "%p"}}) == MESSAGE_DETACHED, "detached text first")
  assert(Validate({{type = "subtext", text_text = "label", secretAuraDetached = true}, {type = "subtext", text_text = "%p"}}) == nil,
    "detached text does not claim a kind")
  assert(Validate({{type = "subtexture", secretAuraDetached = true}}) == nil, "detached texture")
  assert(Validate({{type = "subglow", glow = true}}) == nil, "glow without type is Proc")
  for _, glowType in ipairs({"Proc", "buttonOverlay", "Pixel", "ACShine"}) do
    assert(Validate({{type = "subglow", glow = true, glowType = glowType}}) == nil, "glow " .. glowType)
  end
  assert(Validate({{type = "subglow", glow = true, glowType = "Other"}}) == MESSAGE_GLOW, "unknown glow type")
  assert(Validate({{type = "subglow", glow = false, glowType = "Other"}}) == nil, "disabled glow with unknown type")
  assert(Validate({{type = "subglow", glowType = "Other"}}) == nil, "glow without enabled flag")
  -- order: element order, main text first
  assert(Validate({{type = "subtext", text_text = "%c"}, {type = "subcustom"}}) == MESSAGE_CODES, "first problem wins (text)")
  assert(Validate({{type = "subcustom"}, {type = "subtext", text_text = "%c"}}) == MESSAGE_UNSUPPORTED, "first problem wins (element)")
  assert(Validate({{type = "subglow", glow = true, glowType = "Other"}, {type = "subtext", text_text = "%c"}}) == MESSAGE_GLOW, "first problem wins (glow)")
  assert(Validate({{type = "subcustom"}}, {regionType = "text", displayText = "%c"}) == MESSAGE_CODES, "main text checked before elements")
  assert(Validate({}, {regionType = "text", displayText = "%p"}) == nil, "main text duration")
  assert(Validate({}, {regionType = "text", displayText = "plain"}) == nil, "main text literal")
  assert(Validate({{type = "subtext", text_text = "%p"}}, {regionType = "text", displayText = "%p"}) == MESSAGE_DUPLICATE, "main text claims its kind")
  assert(Validate({{type = "subtext", text_text = "%s"}}, {regionType = "text", displayText = "%p"}) == nil, "main text and other kind")
  assert(Validate({}, {regionType = "icon", displayText = "%c"}) == nil, "displayText ignored outside text regions")

  -- MigrateAppearance: text region and already migrated
  local textData = Secret({regionType = "text", automaticWidth = "Auto"})
  textData.blizzardAuraDisplay.sharedDisplay = true
  Display.MigrateAppearance(textData, {})
  assert(textData.automaticWidth == "Fixed", "text region width not fixed after migration")
  assert(textData.subRegions == nil and textData.inverse == nil, "migrated aura changed")
  local migrated = Secret({subRegions = {{type = "subtext"}}, inverse = false})
  migrated.blizzardAuraDisplay.sharedDisplay = true
  Display.MigrateAppearance(migrated, {glow = true})
  assert(#migrated.subRegions == 1 and migrated.inverse == false, "migrated icon rewritten")
  assert(migrated.automaticWidth == nil, "icon width touched")

  -- MigrateAppearance: no legacy
  local fresh = Secret()
  Display.MigrateAppearance(fresh, nil)
  assert(fresh.inverse == true and fresh.blizzardAuraDisplay.sharedDisplay == true and fresh.subRegions == nil, "icon without legacy")
  fresh = Secret({regionType = "aurabar"})
  Display.MigrateAppearance(fresh, nil)
  assert(fresh.inverse == nil and fresh.blizzardAuraDisplay.sharedDisplay == true, "bar without legacy")
  fresh = Secret({regionType = "text"})
  Display.MigrateAppearance(fresh, nil)
  assert(fresh.automaticWidth == "Fixed" and fresh.blizzardAuraDisplay.sharedDisplay == true, "text without legacy")

  -- MigrateAppearance: legacy
  local legacy = {
    glow = true, glowType = "pulse", glowColor = {0.1, 0.2, 0.3, 0.4}, useGlowColor = false, glowScale = 2, glowDuration = 3, glowX = 4, glowY = 5,
    durationFormat = "clock", durationPrecision = 2, durationDecimalThreshold = 5, durationRoundUp = false,
    label = "100%", labelSize = 22, backgroundColor = {1, 1, 1, 1}, reverse = false,
    durationFont = "Fonts\\X.ttf", durationSize = 30, durationAnchor = "TOP", durationX = 7, durationY = 8,
  }
  local data = Secret({subRegions = {{type = "subglow"}, {type = "subglow"}, {type = "subglow"}}})
  Display.MigrateAppearance(data, legacy)
  local list = data.subRegions
  local kinds = {}
  for index, element in ipairs(list) do kinds[index] = element.type end
  assert(table.concat(kinds, ",") == "subbackground,subglow,subtext,subtext,subtext", "converted elements: " .. table.concat(kinds, ","))
  assert(data.inverse == false and data.blizzardAuraDisplay.sharedDisplay == true, "inverse from reverse = false")
  assert(#legacy.elements == 5 and legacy.elements[1] == "border", "Display.Elements list not written")
  local glow = list[2]
  assert(glow.glow == true and glow.glowType == "buttonOverlay", "pulse is not buttonOverlay")
  assert(glow.glowColor[1] == 0.1 and glow.glowColor ~= legacy.glowColor, "glow color not copied")
  assert(glow.useGlowColor == false and glow.glowScale == 2 and glow.glowDuration == 3, "glow settings")
  assert(glow.glowXOffset == 4 and glow.glowYOffset == 5, "glow offsets")
  local duration = list[3]
  assert(duration.text_text == "%p" and duration.text_visible == true, "duration text")
  assert(duration.text_text_format_p_format == "timed" and duration.text_text_format_p_time_format == 0, "clock format")
  assert(duration.text_text_format_p_time_precision == 2 and duration.text_text_format_p_time_dynamic_threshold == 5, "precision and threshold")
  assert(duration.text_text_format_p_time_legacy_floor == true, "round up false means floor")
  assert(duration.text_font == "Fonts\\X.ttf" and duration.text_fontSize == 30, "duration font")
  assert(duration.anchor_point == "TOP" and duration.text_selfPoint == "CENTER", "duration anchor, own point defaults apart")
  assert(duration.anchorXOffset == 7 and duration.anchorYOffset == 8, "duration offsets")
  local stack = list[4]
  assert(stack.text_text == "%s" and stack.text_visible == true, "stack text")
  assert(stack.anchor_point == "BOTTOMRIGHT" and stack.text_selfPoint == "BOTTOMRIGHT", "stack default anchor")
  assert(stack.anchorXOffset == -3 and stack.anchorYOffset == 3 and stack.text_fontSize == 14, "stack defaults")
  assert(stack.text_shadowColor[1] == 0 and stack.text_shadowColor[4] == 0, "default shadow")
  assert(stack.text_text_format_p_format == nil, "stack got duration format")
  local label = list[5]
  assert(label.text_text == "100%%" and label.text_visible == true, "label text percent doubled: " .. tostring(label.text_text))
  assert(label.anchor_point == "BOTTOM" and label.text_selfPoint == "BOTTOM", "label default anchor")
  assert(label.anchorXOffset == 0 and label.anchorYOffset == 3 and label.text_fontSize == 22, "label defaults")
  assert(list[1].type == "subbackground" and next(list[1], next(list[1])) == nil, "background element not bare")

  -- MigrateAppearance: defaults, formats, hidden texts, custom elements, background
  data = Secret()
  legacy = {elements = {"border", "glow", "duration", "stack", "background", "text1", "unknown"}, glow = false, duration = false, stacks = false,
    reverse = true, fontSize = 25, text1 = "a%b", text1Visible = false, durationFormat = "seconds", durationVisible = true}
  Display.MigrateAppearance(data, legacy)
  list = data.subRegions
  kinds = {}
  for index, element in ipairs(list) do kinds[index] = element.type end
  assert(table.concat(kinds, ",") == "subbackground,subglow,subtext,subtext,subtexture,subtext", "preset elements: " .. table.concat(kinds, ","))
  assert(data.inverse == true, "inverse from reverse = true")
  glow = list[2]
  assert(glow.glow == false and glow.glowType == "Proc" and glow.useGlowColor == true, "glow defaults")
  assert(glow.glowColor[1] == 1 and glow.glowColor[2] == 0.82 and glow.glowColor[3] == 0 and glow.glowColor[4] == 1, "default glow color")
  assert(glow.glowScale == 1 and glow.glowDuration == 1 and glow.glowXOffset == 0 and glow.glowYOffset == 0, "glow default numbers")
  duration = list[3]
  assert(duration.text_visible == false, "duration disabled but visible")
  assert(duration.text_text_format_p_time_format == -2 and duration.text_text_format_p_time_precision == 1
    and duration.text_text_format_p_time_dynamic_threshold == 3 and duration.text_text_format_p_time_legacy_floor == false, "duration defaults")
  assert(duration.text_fontSize == 25 and duration.anchor_point == "CENTER" and duration.anchorXOffset == 0 and duration.anchorYOffset == 0, "duration defaults 2")
  assert(list[4].text_visible == false, "stack disabled but visible")
  local background = list[5]
  assert(background.textureTexture == "Interface\\Buttons\\WHITE8X8" and background.textureVisible == true, "background texture")
  assert(background.textureColor[4] == 0.5 and background.anchor_area == "ALL" and background.anchor_mode == "area", "background defaults")
  assert(list[6].text_text == "a%%b" and list[6].text_visible == false, "custom text element")
  fresh = Secret()
  Display.MigrateAppearance(fresh, {elements = {"duration"}, durationFormat = "x"})
  assert(fresh.subRegions[2].text_text_format_p_time_format == -1, "unknown duration format")
  fresh = Secret()
  Display.MigrateAppearance(fresh, {reverse = nil})
  assert(fresh.inverse == true and #fresh.subRegions == 3 and fresh.subRegions[2].text_text == "%p" and fresh.subRegions[3].text_text == "%s", "default legacy elements")

  -- StyleAppearance on a fake native button
  local log = {}
  local function Recorder(frame, names)
    for _, name in ipairs(names) do
      frame[name] = function(_, ...) log[#log + 1] = {frame = frame.tag, call = name, ...} end
    end
  end
  local function Tagged(tag)
    local frame = CreateFrame("Frame")
    frame.tag = tag
    return frame
  end
  local buttonFrame = Tagged("button")
  Recorder(buttonFrame, {"ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon",
    "ClearDispelTypeTextures", "SetIcon", "SetDurationText", "SetApplicationCount", "SetSpellName", "SetDurationCooldown"})
  local sizeCalls = {}
  local nativeButton = {
    button = buttonFrame, inner = CreateFrame("Frame"), outer = CreateFrame("Frame"), border = CreateFrame("Frame"),
    icon = CreateFrame("Frame"), cooldown = CreateFrame("Cooldown"), elementFrames = {},
  }
  nativeButton.icon.SetTexture = function(self, file) log[#log + 1] = {frame = "icon", call = "SetTexture", file} end
  nativeButton.icon.SetDesaturated = function(self, value) log[#log + 1] = {frame = "icon", call = "SetDesaturated", value} end
  nativeButton.icon.SetVertexColor = function(self, ...) log[#log + 1] = {frame = "icon", call = "SetVertexColor", ...} end
  nativeButton.icon.SetTexCoord = function(self, ...) log[#log + 1] = {frame = "icon", call = "SetTexCoord", ...} end
  nativeButton.inner.SetSize = function(_, w, h) sizeCalls.inner = {w, h} end
  nativeButton.outer.SetSize = function(_, w, h) sizeCalls.outer = {w, h} end
  buttonFrame.SetSize = function(_, w, h) log[#log + 1] = {frame = "button", call = "SetSize", w, h} end
  local function ElementFrame(owner, key)
    owner.elementFrames[key] = owner.elementFrames[key] or CreateFrame("Frame", nil, buttonFrame)
    return owner.elementFrames[key]
  end
  local styledTexts = {}
  local function StyleText(text, owner, config, ...)
    styledTexts[#styledTexts + 1] = {text = text, config = config}
  end
  local function Index(call)
    for position, entry in ipairs(log) do
      if entry.call == call then return position end
    end
  end
  local function Count(call)
    local total = 0
    for _, entry in ipairs(log) do if entry.call == call then total = total + 1 end end
    return total
  end

  local styleData = Secret({
    width = 50, height = 30, desaturate = true, color = {0.1, 0.2, 0.3, 1}, cooldownSwipe = false, cooldownEdge = true, inverse = true,
    subRegions = {{type = "subbackground"}, {type = "subtext", text_text = "label", text_alpha = 0.5},
      {type = "subtext", text_text = "%n"}, {type = "subtext", text_text = "gone", text_visible = false},
      {type = "subtext", text_text = "detached", secretAuraDetached = true}},
  })
  Display.StyleAppearance(nativeButton, styleData, ElementFrame, StyleText)
  assert(sizeCalls.inner[1] == 40 and sizeCalls.inner[2] == 24, "inner size 0.8x")
  assert(math.abs(sizeCalls.outer[1] - 55) < 1e-9 and math.abs(sizeCalls.outer[2] - 33) < 1e-9, "outer size 1.1x")
  assert(log[1].call == "SetSize" and log[1][1] == 50 and log[1][2] == 30, "button size is the first step")
  local lastClear = 0
  for _, call in ipairs({"ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon", "ClearDispelTypeTextures"}) do
    assert(Count(call) == 1, call .. " not called once")
    assert(Index(call) < Index("SetIcon"), call .. " after the icon binding")
    lastClear = math.max(lastClear, Index(call))
  end
  assert(Index("SetSize") < Index("ClearDurationText"), "size before native bindings reset")
  assert(Index("SetIcon") and Index("SetDurationCooldown") and Index("SetIcon") < Index("SetDurationCooldown"), "icon then cooldown binding")
  assert(Index("SetSpellName") > Index("SetDurationCooldown"), "sub elements before cooldown")
  assert(nativeButton.elementFrames.sharedBase:IsShown(), "base frame hidden")
  assert(nativeButton.elementFrames.sharedBase:GetFrameLevel() == buttonFrame:GetFrameLevel() + 1 or nativeButton.elementFrames.shared1 ~= nil, "base frame level")
  local cooldown = nativeButton.cooldown
  assert(cooldown:IsShown() and nativeButton.icon:IsShown(), "icon and cooldown hidden")
  assert(nativeButton.border:IsShown() == false, "border shown for an aura without one")
  for _, entry in ipairs(log) do
    if entry.call == "SetDesaturated" then assert(entry[1] == true, "desaturate") end
    if entry.call == "SetVertexColor" then assert(entry[1] == 0.1 and entry[3] == 0.3, "icon color") end
  end
  assert(Count("SetDesaturated") == 1 and Count("SetVertexColor") == 1, "base icon styled once")
  assert(#styledTexts == 2, "text elements styled: " .. #styledTexts)
  assert(styledTexts[1].text == nativeButton.sharedElements[2].text and styledTexts[2].text == nativeButton.sharedElements[3].text, "texts not on entries 2 and 3")
  assert(nativeButton.sharedElements[1] and nativeButton.sharedElements[2] and nativeButton.sharedElements[3] and nativeButton.sharedElements[4], "entries")
  assert(nativeButton.sharedElements[5] == nil, "detached element styled")
  assert(nativeButton.sharedElements[4].text == nil, "hidden text created")
  assert(nativeButton.sharedElements[2].text:GetAlpha() == 0.5, "text alpha")
  assert(nativeButton.sharedElements[2].text:IsShown() and nativeButton.sharedElements[3].text:IsShown(), "texts hidden")
  assert(nativeButton.elementFrames.shared1:GetFrameLevel() == buttonFrame:GetFrameLevel() + 6, "element frame level 3i + 3")
  assert(nativeButton.elementFrames.shared2:GetFrameLevel() == buttonFrame:GetFrameLevel() + 9, "element frame level, second")
  assert(nativeButton.elementFrames.shared1:IsShown() and nativeButton.elementFrames.shared5 == nil, "element frames")
  assert(nativeButton.sharedElements[2].text:GetText() == "label", "literal text")
  assert(nativeButton.sharedElements[1].glowStale == nil and nativeButton.sharedElements[2].glowStale == nil, "stale mark left after the pass")
  assert(Count("SetSpellName") == 1, "name text not bound once")

  -- second pass: removed element is hidden, first entries reused, bindings cleared again
  local firstText = nativeButton.sharedElements[2].text
  local entryBefore = nativeButton.sharedElements[2]
  log = {}
  styleData.subRegions = {{type = "subbackground"}}
  Display.StyleAppearance(nativeButton, styleData, ElementFrame, StyleText)
  assert(nativeButton.sharedElements[2] == entryBefore and entryBefore.text == firstText, "entry not kept")
  assert(not nativeButton.elementFrames.shared2:IsShown(), "frame of a removed element still shown")
  assert(Count("ClearDurationText") == 1 and Count("SetIcon") == 1, "second pass did not reset and rebind")

  -- non icon: no icon binding, no cooldown
  log = {}
  local textNative = {
    button = Tagged("button"), inner = CreateFrame("Frame"), outer = CreateFrame("Frame"), border = CreateFrame("Frame"),
    icon = CreateFrame("Frame"), cooldown = CreateFrame("Cooldown"), elementFrames = {},
  }
  Recorder(textNative.button, {"ClearDurationText", "ClearApplicationCount", "ClearSpellName", "ClearDurationBar", "ClearDurationCooldown", "ClearIcon",
    "ClearDispelTypeTextures", "SetIcon", "SetDurationText", "SetApplicationCount", "SetSpellName", "SetDurationCooldown"})
  textNative.button.SetSize = function() end
  local function ElementFrameFor(owner, key)
    owner.elementFrames[key] = owner.elementFrames[key] or CreateFrame("Frame", nil, owner.button)
    return owner.elementFrames[key]
  end
  local mainTextData = Secret({regionType = "text", displayText = "%n", fontSize = 20, color = {1, 1, 1, 1}})
  Display.StyleAppearance(textNative, mainTextData, ElementFrameFor, StyleText)
  assert(Count("SetIcon") == 0 and Count("SetDurationCooldown") == 0, "text region bound an icon")
  assert(textNative.mainText and textNative.mainText:IsShown() and Count("SetSpellName") == 1, "main text not bound to the name")
  assert(textNative.icon:IsShown() == false and textNative.cooldown:IsShown() == false, "icon shown for a text region")
  mainTextData.displayText = "plain"
  Display.StyleAppearance(textNative, mainTextData, ElementFrameFor, StyleText)
  assert(textNative.mainText:GetText() == "plain", "literal main text")
  mainTextData.displayText = "100%%"
  Display.StyleAppearance(textNative, mainTextData, ElementFrameFor, StyleText)
  assert(textNative.mainText:GetText() == "100%", "escaped percent in main text")
  local iconNative = textNative
  iconNative.mainText:Show()
  Display.StyleAppearance(iconNative, Secret(), ElementFrameFor, StyleText)
  assert(iconNative.mainText:IsShown() == false, "main text kept after switching to an icon")
end

local function PowerTrigger()
  return { trigger = { type = "unit", event = "Power", unit = "player", use_unit = true,
    use_powertype = true, powertype = 0, debuffType = "HELPFUL", names = {}, spellIds = {} }, untrigger = {} }
end

local function CooldownTrigger()
  return { trigger = { type = "spell", event = "Cooldown Progress (Spell)", spellName = 6673, use_ignoreSpellKnown = true,
    use_genericShowOn = true, genericShowOn = "showAlways", debuffType = "HELPFUL", names = {}, spellIds = {} },
    untrigger = {} }
end

local function Aura(id, regionType, subRegions, conditions)
  local data = {
    id = id, uid = id, regionType = regionType, internalVersion = 91,
    triggers = { PowerTrigger(), activeTriggerMode = -10 }, conditions = conditions,
    load = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = subRegions, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
    anchorFrameType = "SCREEN",
  }
  if regionType == "text" then
    data.displayText = "base"
  end
  return data
end

local function Below(percent, changes)
  return { check = { trigger = 1, variable = "percentpower", op = "<", value = tostring(percent) }, changes = changes }
end

local function Change(property, value)
  return { property = property, value = value }
end

local RED = { 1, 0, 0, 1 }

local function LayeredConditions(thresholds)
  local conditions = {}
  for _, threshold in ipairs(thresholds) do
    conditions[#conditions + 1] = Below(threshold[1], { Change("displayText", threshold[2]) })
  end
  return conditions
end

return function(test)
  local Secret, Units, State = test.Secret, test.Units, test.Frames.State

  local usable = true
  IsUsableSpell = nil
  C_Spell.IsSpellUsable = function()
    if InCombatLockdown() then
      return Secret.Wrap(usable), Secret.Wrap(not usable)
    end
    return usable, not usable
  end

  local stacked = Aura("Stacked", "icon", { { type = "subbackground" }, { type = "subtext", text_text = "stacked" } }, {
    Below(20, { Change("sub.2.text_visible", false) }),
    { check = { trigger = 2, variable = "spellUsable", value = 0 }, changes = { Change("sub.2.text_visible", true) } },
  })
  stacked.triggers = { PowerTrigger(), CooldownTrigger(), activeTriggerMode = 1, disjunctive = "any" }

  local saved = { displays = {
    SubIcon = Aura("SubIcon", "icon", {
      { type = "subbackground" },
      { type = "subtext", text_text = "sub" },
      { type = "subborder", border_visible = true, border_edge = "Square Full White", border_size = 2,
        border_color = { 1, 1, 1, 1 } },
      { type = "subglow", glow = false, glowType = "Pixel", useGlowColor = true, glowColor = { 1, 1, 1, 1 } },
      { type = "subtexture", textureVisible = true, textureDesaturate = false },
    }, { Below(20, {
      Change("sub.2.text_visible", false),
      Change("sub.3.border_color", RED),
      Change("sub.4.glow", true),
      Change("sub.5.textureVisible", false),
      Change("sub.5.textureDesaturate", true),
    }) }),
    SubBar = Aura("SubBar", "aurabar", {
      { type = "subforeground" },
      { type = "subbackground" },
      { type = "subtick", use_texture = true, tick_desaturate = false },
      { type = "subcirculartexture", circularTextureVisible = true, circularTextureDesaturate = false },
      { type = "sublineartexture", linearTextureVisible = true, linearTextureDesaturate = false },
      { type = "substopmotion", stopmotionVisible = true, stopmotionDesaturate = false },
      { type = "subglow", glow = false, glowType = "buttonOverlay", useGlowColor = true, glowColor = { 1, 1, 1, 1 } },
    }, { Below(20, {
      Change("sub.3.tick_visible", false),
      Change("sub.3.tick_color", RED),
      Change("sub.3.tick_desaturate", true),
      Change("sub.4.circularTextureVisible", false),
      Change("sub.4.circularTextureColor", RED),
      Change("sub.4.circularTextureDesaturate", true),
      Change("sub.5.linearTextureVisible", false),
      Change("sub.5.linearTextureColor", RED),
      Change("sub.5.linearTextureDesaturate", true),
      Change("sub.6.stopmotionVisible", false),
      Change("sub.6.stopmotionColor", RED),
      Change("sub.6.stopmotionDesaturate", true),
      Change("sub.7.glow", true),
      Change("sub.7.glowColor", { 1, 0, 0, 0.5 }),
      Change("icon_color", RED),
      Change("backgroundColor", RED),
      Change("sparkColor", RED),
      Change("barColor", RED),
      Change("desaturate", true),
    }) }),
    LayeredText = Aura("LayeredText", "text", {}, LayeredConditions({ { 50, "half" }, { 20, "low" } })),
    Stacked = stacked,
  } }
  local barColors = saved.displays.SubBar
  barColors.icon_color, barColors.backgroundColor, barColors.sparkColor = { 1, 1, 1, 1 }, { 1, 1, 1, 1 }, { 1, 1, 1, 1 }
  barColors.barColor, barColors.desaturate = { 1, 1, 1, 1 }, false
  barColors.enableGradient, barColors.barColor2, barColors.gradientOrientation = true, { 0, 0, 1, 1 }, "HORIZONTAL"

  Units.DefineUnit("player", { class = "WARLOCK", powerType = 0, power = 1000, powerMax = 1000,
    health = 1000, healthMax = 1000 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)

  local function SetPower(power)
    Units.Get("player").power = power
    test.Frames.Fire("UNIT_POWER_FREQUENT", "player", "MANA")
    test.Frames.Fire("SPELL_UPDATE_USABLE")
    test.Environment.Advance(0.2)
  end
  local function Expect(value, expected, label, readable)
    assert(readable or Secret.IsSecret(value), label .. " not secret")
    assert(not readable or not Secret.IsSecret(value), label .. " still secret")
    value = Secret.Reveal(value)
    assert(value == expected, ("%s is %s, expected %s"):format(label, tostring(value), tostring(expected)))
  end
  local function ExpectColor(texture, red, green, label)
    local color = State[texture].vertexColor
    Expect(color[1], red, label .. " red")
    Expect(color[2], green, label .. " green")
  end

  local icon = WeakAuras.GetRegion("SubIcon")
  local _, subText, border, glow, texture = unpack(icon.subRegions)
  local bar = WeakAuras.GetRegion("SubBar")
  local _, _, tick, circular, linear, stopMotion, buttonGlow = unpack(bar.subRegions)
  State[buttonGlow].width, State[buttonGlow].height = 64, 64
  local buttonGlowColor
  local buttonGlowStart = buttonGlow.glowStart
  buttonGlow.glowStart = function(frame, color, ...)
    buttonGlowColor = color
    return buttonGlowStart(frame, color, ...)
  end
  local stackedText = WeakAuras.GetRegion("Stacked").subRegions[2]
  local text = WeakAuras.GetRegion("LayeredText")
  local function Layers(alphas, label)
    Expect(State[text.text].alpha, 0, "main text alpha " .. label, true)
    for index, expected in ipairs(alphas) do
      local alpha = Secret.Reveal(State[text.secretTextLayers[index]].alpha)
      for depth = 1, #alphas - index do
        alpha = alpha * Secret.Reveal(State[text.secretTextHolders[index][depth]].alpha)
      end
      Expect(Secret.Wrap(alpha), expected, "text layer " .. index .. " " .. label)
    end
    for index = #alphas + 1, #text.secretTextLayers do
      assert(not text.secretTextLayers[index]:IsShown(), "text layer " .. index .. " shown " .. label)
    end
  end
  local function BarElements(full, label)
    local value, green = full and 1 or 0, full and 1 or 0
    for name, subRegion in pairs({ tick = tick, circular = circular, linear = linear, stopMotion = stopMotion }) do
      Expect(State[subRegion].alpha, value, name .. " alpha " .. label)
    end
    Expect(State[buttonGlow].alpha, 1 - value, "button glow alpha " .. label)
    assert(buttonGlow.glow, "button glow not started " .. label)
    Expect(buttonGlowColor[4], 1, "button glow color alpha " .. label, true)
    Expect(buttonGlowColor[2], green, "button glow color green " .. label)
    ExpectColor(tick.ticks[1], 1, green, "tick " .. label)
    Expect(State[tick.ticks[1]].desaturation, 1 - value, "tick desaturation " .. label)
    ExpectColor(circular.circularTexture.textures[1], 1, green, "circular " .. label)
    Expect(State[circular.circularTexture.textures[1]].desaturation, 1 - value, "circular desaturation " .. label)
    ExpectColor(linear.linearTexture.texture, 1, green, "linear " .. label)
    Expect(State[linear.linearTexture.texture].desaturation, 1 - value, "linear desaturation " .. label)
    ExpectColor(stopMotion.stopMotion.texture, 1, green, "stop motion " .. label)
    Expect(State[stopMotion.stopMotion.texture].desaturation, 1 - value, "stop motion desaturation " .. label)
    ExpectColor(bar.icon, 1, green, "bar icon " .. label)
    ExpectColor(bar.bar.bg, 1, green, "bar background " .. label)
    ExpectColor(bar.bar.spark, 1, green, "bar spark " .. label)
    ExpectColor(bar.bar.fg, 1, green, "bar foreground " .. label)
    Expect(State[bar.icon].desaturation, 1 - value, "bar icon desaturation " .. label)
  end

  for _, inCombat in ipairs({ false, true }) do
    local label = inCombat and "in combat" or "out of combat"
    Units.SetCombat(inCombat)
    usable = true
    SetPower(1000)
    Expect(State[subText].alpha, 1, "sub text alpha full mana " .. label)
    Expect(State[border].backdropBorderColor[2], 1, "border green full mana " .. label)
    Expect(State[glow].alpha, 0, "glow alpha full mana " .. label)
    assert(glow.glow, "glow not started under a secret condition " .. label)
    Expect(State[texture].alpha, 1, "texture alpha full mana " .. label)
    Expect(State[texture.texture.texture].desaturation, 0, "texture desaturation full mana " .. label)
    BarElements(true, "full mana " .. label)
    Expect(State[stackedText].alpha, 1, "stacked text full mana " .. label)
    Layers({ 1, 0, 0 }, "full mana " .. label)

    SetPower(300)
    Layers({ 0, 1, 0 }, "30% mana " .. label)

    SetPower(100)
    Expect(State[subText].alpha, 0, "sub text alpha low mana " .. label)
    Expect(State[border].backdropBorderColor[1], 1, "border red low mana " .. label)
    Expect(State[border].backdropBorderColor[2], 0, "border green low mana " .. label)
    Expect(State[glow].alpha, 1, "glow alpha low mana " .. label)
    Expect(State[texture].alpha, 0, "texture alpha low mana " .. label)
    Expect(State[texture.texture.texture].desaturation, 1, "texture desaturation low mana " .. label)
    BarElements(false, "low mana " .. label)
    Expect(State[stackedText].alpha, 0, "stacked text low mana usable " .. label)
    Layers({ 0, 0, 1 }, "low mana " .. label)
    assert(text.secretTextLayers[3]:GetText() == "low", "low layer text " .. label)

    usable = false
    SetPower(100)
    Expect(State[stackedText].alpha, 1, "bool condition stacked on the curve " .. label, not inCombat)
  end

  text:Color(0, 0, 1, 1)
  local layerColor = { text.secretTextLayers[3]:GetTextColor() }
  assert(layerColor[1] == 0 and layerColor[3] == 1, "text layers keep the old color after Color")
  text:Color(1, 1, 1, 1)

  local barData = CopyTable(WeakAuras.GetData("SubBar"))
  local barConditions = barData.conditions
  barData.conditions = {}
  WeakAuras.Add(barData)
  test.Environment.Advance(0.2)
  for name, subRegion in pairs({ tick = tick, circular = circular, linear = linear, stopMotion = stopMotion }) do
    Expect(State[subRegion].alpha, 1, name .. " alpha after release", true)
    assert(not subRegion.secretVisibility, name .. " secret visibility kept after release")
  end
  barData.conditions = barConditions
  WeakAuras.Add(barData)

  local textData = CopyTable(WeakAuras.GetData("LayeredText"))
  textData.conditions = LayeredConditions({ { 50, "half" }, { 20, "low" }, { 10, "crit" } })
  WeakAuras.Add(textData)
  SetPower(50)
  Layers({ 0, 0, 0, 1 }, "four layers")
  assert(text.secretTextLayers[4]:GetText() == "crit", "crit layer text")
  textData.conditions = LayeredConditions({ { 50, "half" } })
  WeakAuras.Add(CopyTable(textData))
  SetPower(300)
  Layers({ 0, 1 }, "two layers")
  textData.conditions = LayeredConditions({ { 50, "half" }, { 20, "low" } })
  WeakAuras.Add(textData)
  Units.SetCombat(false)

  local secretPower = UnitPower
  UnitPower = function(...) return Secret.Reveal(secretPower(...)) end
  SetPower(100)
  Expect(State[subText].alpha, 1, "sub text alpha restored", true)
  assert(not subText:IsShown(), "sub text not hidden by the readable condition")
  Expect(State[glow].alpha, 1, "glow alpha restored", true)
  assert(glow.glow, "glow not shown by the readable condition")
  Expect(State[texture].alpha, 1, "texture alpha restored", true)
  assert(not texture.visible, "texture not hidden by the readable condition")
  Expect(State[texture.texture.texture].desaturation, 1, "texture desaturation restored", true)
  Expect(State[text.text].alpha, 1, "main text alpha restored", true)
  Expect(State[bar.icon].desaturation, 1, "bar icon desaturation restored", true)
  local gradient = State[bar.bar.fg].gradient
  assert(gradient and gradient[2].r == 1 and gradient[2].g == 0 and gradient[3].b == 1, "bar gradient not red")
  assert(not text.secretTextLayers[1]:IsShown(), "text layers still shown")
  assert(State[text.text].text == "low", "main text not switched to the readable condition text")
  SetPower(1000)
  assert(not glow.glow, "glow not stopped by the readable condition")
  Expect(State[texture.texture.texture].desaturation, 0, "texture desaturation back", true)
  Expect(State[bar.icon].desaturation, 0, "bar icon desaturation back", true)
  gradient = State[bar.bar.fg].gradient
  assert(gradient[2].g == 1 and gradient[3].b == 1, "bar gradient not back to white")
  assert(State[text.text].text == "base", "main text not back to the base text")
  UnitPower = secretPower
end

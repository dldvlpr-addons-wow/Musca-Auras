-- "Show Absorb" on a Health trigger draws the absorb as an overlay after the health fill,
-- with a secret amount too.

local function Aura(id, regionType, showAbsorb, unit)
  return {
    id = id, uid = id, regionType = regionType, internalVersion = 91,
    triggers = { { trigger = { type = "unit", event = "Health", unit = unit or "player", use_unit = true,
      debuffType = "HELPFUL", names = {}, spellIds = {}, use_showAbsorb = showAbsorb }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, conditions = {}, width = 200, height = 20,
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local Secret, Units = test.Secret, test.Units
  local State = test.Frames.State
  local saved = { displays = {
    AbsorbBar = Aura("AbsorbBar", "aurabar", true),
    PlainBar = Aura("PlainBar", "aurabar", nil),
    AbsorbTexture = Aura("AbsorbTexture", "progresstexture", true),
    TargetBar = Aura("TargetBar", "aurabar", true, "target"),
  } }

  Units.DefineUnit("player", { class = "PRIEST", powerType = 0, power = 1000, powerMax = 1000,
    health = 600, healthMax = 1000 })
  -- A unit no player controls: its health total is secret.
  Units.DefineUnit("target", { isPlayerControlled = false, canAttack = true, health = 900, healthMax = 2000 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)

  local function Reveal(value)
    if Secret.IsSecret(value) then
      return Secret.Reveal(value)
    end
    return value
  end

  for _, inCombat in ipairs({ false, true }) do
    local label = inCombat and "in combat" or "out of combat"
    Units.SetCombat(inCombat)
    Units.Get("player").absorb = 250
    test.Frames.Fire("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    test.Frames.Fire("UNIT_HEALTH", "player")
    test.Environment.Advance(0.2)

    local region = WeakAuras.GetRegion("AbsorbBar")
    assert(region and region:IsShown(), "AbsorbBar hidden " .. label)
    local additionalBar = region.bar.additionalBars and region.bar.additionalBars[1]
    assert(additionalBar, "no absorb overlay " .. label)
    assert(additionalBar.direction == "forward", "absorb overlay not placed after the health fill " .. label)
    assert(Reveal(additionalBar.width) == 250,
      ("absorb overlay width %s, expected 250 %s"):format(tostring(Reveal(additionalBar.width)), label))
    assert(Reveal(region.bar.additionalBarsMax) == 1000,
      ("absorb overlay scaled on %s, expected 1000 %s"):format(tostring(Reveal(region.bar.additionalBarsMax)), label))
    assert(not inCombat or Secret.IsSecret(additionalBar.width), "absorb readable in combat: secret path not covered")
    if Secret.IsSecret(additionalBar.width) then
      local overlay = region.bar.secretExtraTextures[1]
      assert(overlay and overlay:IsShown(), "secret absorb overlay not drawn " .. label)
      assert(Reveal(State[overlay.markers[2]].value) == 250, "secret absorb not passed to the overlay marker " .. label)
      assert(Reveal(State[overlay.markers[2]].maxValue) == 1000, "overlay marker not scaled on the health total " .. label)
    end

    local plain = WeakAuras.GetRegion("PlainBar")
    assert(plain and plain:IsShown(), "PlainBar hidden " .. label)
    assert(not (plain.bar.additionalBars and plain.bar.additionalBars[1]),
      "absorb overlay drawn while Show Absorb is off " .. label)

    local texture = WeakAuras.GetRegion("AbsorbTexture")
    assert(texture and texture:IsShown(), "AbsorbTexture hidden " .. label)
  end
  Units.SetCombat(false)

  Units.Get("target").absorb = 400
  test.Frames.Fire("PLAYER_TARGET_CHANGED")
  test.Frames.Fire("UNIT_ABSORB_AMOUNT_CHANGED", "target")
  test.Frames.Fire("UNIT_HEALTH", "target")
  test.Environment.Advance(0.2)
  local targetRegion = WeakAuras.GetRegion("TargetBar")
  assert(targetRegion and targetRegion:IsShown(), "TargetBar hidden")
  local targetBar = targetRegion.bar
  assert(Secret.IsSecret(targetBar.additionalBarsMax), "secret health total not passed to the overlays")
  local targetOverlay = targetBar.secretExtraTextures[1]
  assert(targetOverlay and targetOverlay:IsShown(), "absorb overlay not drawn on a secret health total")
  assert(Reveal(State[targetOverlay.markers[2]].maxValue) == 2000, "overlay marker not scaled on the secret total")
  -- The native bar hides while the secret scale is still on the bar: readable overlays must not do arithmetic on it.
  targetBar.additionalBars = { { direction = "forward", width = 10 } }
  targetBar:SetDurationObject(nil)
  assert(targetBar:UsesNativeAdditionalBars(), "secret overlay scale sent to the plain path")
end

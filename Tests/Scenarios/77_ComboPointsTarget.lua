return function(test)
  local Units = test.Units
  local comboByTarget = { first = 3, second = 0 }
  local currentTarget = "first"
  _G.GetComboPoints = function() return comboByTarget[currentTarget] end

  local trigger = { type = "unit", event = "Power", unit = "player", use_unit = true,
    use_powertype = true, powertype = 4, names = {}, spellIds = {} }
  local pipTrigger = { type = "unit", event = "Power", unit = "player", use_unit = true,
    use_powertype = true, powertype = 4, use_nativeThreshold = true, nativeThreshold = "50",
    use_nativeThresholdAbove = true, names = {}, spellIds = {} }
  local saved = { displays = {
    ComboText = {
      id = "ComboText", uid = "ComboText", regionType = "text", internalVersion = 91,
      triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
      load = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", displayText = "%power", conditions = {},
    },
    ComboPip = {
      id = "ComboPip", uid = "ComboPip", regionType = "texture", internalVersion = 91,
      triggers = { { trigger = pipTrigger, untrigger = {} }, activeTriggerMode = -10 },
      load = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 10, height = 6, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", texture = "Interface\\Buttons\\WHITE8X8", conditions = {},
    },
  } }

  Units.DefineUnit("player", { class = "ROGUE", powerType = 3, power = 100, powerMax = 5,
    health = 1000, healthMax = 1000, isPlayerControlled = true })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)

  local function Text()
    local region = WeakAuras.GetRegion("ComboText")
    assert(region and region:IsShown(), "ComboText hidden")
    return test.Secret.Reveal(region.text:GetText())
  end
  local function PipAlpha()
    return test.Secret.Reveal(WeakAuras.GetRegion("ComboPip").alpha)
  end
  assert(Text() == "3", "combo points on the first target, got " .. tostring(Text()))
  assert(PipAlpha() == 1, "third pip off with 3 combo points, alpha " .. tostring(PipAlpha()))

  currentTarget = "second"
  test.Frames.Fire("PLAYER_TARGET_CHANGED")
  test.Environment.Advance(0.2)
  assert(Text() == "0", "combo points kept after a target change, got " .. tostring(Text()))
  assert(PipAlpha() == 0, "third pip kept lit after a target change, alpha " .. tostring(PipAlpha()))

  comboByTarget.second = 2
  test.Frames.Fire("COMBO_TARGET_CHANGED")
  test.Environment.Advance(0.2)
  assert(Text() == "2", "combo points not refreshed on COMBO_TARGET_CHANGED, got " .. tostring(Text()))
  assert(PipAlpha() == 0, "third pip lit with 2 combo points, alpha " .. tostring(PipAlpha()))

  _G.GetComboPoints = nil
end

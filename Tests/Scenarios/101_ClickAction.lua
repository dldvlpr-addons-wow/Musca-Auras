-- Click action sub element: the secure button and its key binding change out of combat only.
return function(test)
  local function Aura(id, combatMode)
    return {
      id = id, uid = id, regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = { {
        type = "subclickaction",
        clickLeftType = "spell", clickLeftValue = "6673", clickLeftUnit = "",
        clickRightType = "target", clickRightValue = "", clickRightUnit = "focus",
        clickMiddleType = "none", clickMiddleValue = "", clickMiddleUnit = "",
        clickBinding = "F", clickCombatMode = combatMode, clickCombatCondition = "[combat] show; hide",
      } },
      width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    }
  end

  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { Shout = Aura("Shout", "visible") } })
  test.Environment.Advance(1)
  local overrides = test.WowApi.overrideBindings
  local function Forbidden(step)
    assert(#test.Environment.forbidden == 0, step .. ": " .. tostring(test.Environment.forbidden[1]))
  end

  -- Aura loaded but hidden: button created with its actions, hidden, no binding.
  local button = _G.MuscaAurasClick1
  assert(button, "click button not created")
  assert(button:GetAttribute("*type1") == "spell" and button:GetAttribute("*spell1") == 6673, "left click action not set")
  assert(button:GetAttribute("*type2") == "target" and button:GetAttribute("*unit2") == "focus", "right click action not set")
  assert(button:GetAttribute("*type3") == nil, "middle click set while none")
  assert(not button:IsShown(), "button shown while the aura is hidden")
  assert(overrides.F == nil, "binding set while the aura is hidden")

  -- Aura shown out of combat: button placed over it and binding set.
  local buff = test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  local region = WeakAuras.GetRegion("Shout")
  assert(region:IsVisible(), "aura not shown")
  assert(button:IsShown(), "button not shown with the aura")
  assert(button:GetWidth() == region:GetWidth(), "button not sized as the aura")
  assert(overrides.F and overrides.F.action == "CLICK MuscaAurasClick1:LeftButton", "binding not set")

  -- Aura laid out again without show or hide (dynamic group sort): the button follows it out of combat.
  -- The harness ignores offsets, so the change is on the size, which an icon does not report.
  region:SetSize(80, 80)
  test.Environment.Advance(0.5)
  assert(button:GetWidth() == 80 and button:GetLeft() == region:GetLeft(), "button did not follow the aura")

  -- In combat nothing changes, even when the aura hides.
  test.Units.SetCombat(true)
  test.Units.RemoveAura("player", buff)
  test.Environment.Advance(0.5)
  Forbidden("aura hidden in combat")
  assert(not region:IsVisible(), "aura still shown")
  assert(button:IsShown(), "button changed in combat")
  assert(overrides.F, "binding changed in combat")

  -- After combat the button follows the aura again.
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  Forbidden("after combat")
  assert(not button:IsShown(), "button not hidden after combat")
  assert(overrides.F == nil, "binding not removed after combat")

  -- Deleted in combat: reset after combat only, then reused.
  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  assert(overrides.F, "binding not set again")
  test.Units.SetCombat(true)
  WeakAuras.Delete(WeakAuras.GetData("Shout"))
  test.Environment.Advance(0.5)
  Forbidden("deleted in combat")
  assert(overrides.F, "binding removed in combat")
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  Forbidden("deleted, after combat")
  assert(overrides.F == nil, "binding kept after delete")
  assert(not button:IsShown(), "button shown after delete")
  assert(button:GetAttribute("*type1") == nil, "actions kept after delete")

  -- Mode macro: visibility handed to a state driver, binding kept while loaded.
  WeakAuras.Add(Aura("Driven", "macro"))
  test.Environment.Advance(0.5)
  Forbidden("macro mode")
  assert(test.WowApi.stateDrivers[button], "state driver not set: free button not reused")
  assert(overrides.F, "binding not set in macro mode")

  -- Display type changed: the options replace the region without releasing its sub elements (Private.Convert,
  -- which needs the options in this harness). The button of the former region must not stay.
  local entry = private.regions.Driven
  local formerRegion = entry.region
  entry.region = CreateFrame("Frame")
  private.SyncClickButtons()
  Forbidden("display type changed")
  assert(next(test.WowApi.stateDrivers) == nil, "state driver kept on the former region")
  assert(overrides.F == nil, "binding kept on the former region")
  entry.region = formerRegion

  -- Cancel buff by an unknown spell ID: no action rather than the ID as a name.
  local cancel = Aura("Cancel", "visible")
  cancel.subRegions[1].clickLeftType, cancel.subRegions[1].clickLeftValue = "cancelaura", "999999999"
  cancel.subRegions[1].clickRightType, cancel.subRegions[1].clickBinding = "none", ""
  WeakAuras.Add(cancel)
  test.Environment.Advance(0.5)
  Forbidden("cancel buff by unknown ID")
  local cancelButton
  for index = 1, 3 do
    local clickButton = _G["MuscaAurasClick" .. index]
    if clickButton and clickButton.owner and clickButton.owner.parent.id == "Cancel" then cancelButton = clickButton end
  end
  assert(cancelButton, "no button for the cancel buff aura")
  assert(cancelButton:GetAttribute("*spell1") == nil, "unknown spell ID passed as a buff name")
end

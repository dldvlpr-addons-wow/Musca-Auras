-- Click action sub-region: a secure button over the aura, changed out of combat only.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Shield = {
      id = "Shield", uid = "Shield", regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = { {
        type = "subclickaction", left_action = "spell", left_value = "Lightning Shield", left_unit = "default",
        right_action = "item", right_value = "6948", right_unit = "default",
        middle_action = "macro", middle_value = "", middle_macro = "/sit", middle_unit = "default",
        keybind = "F", combat_mode = "visible", macro_condition = "",
      } },
      width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
  } })
  test.Environment.Advance(1)

  local region = WeakAuras.GetRegion("Shield")
  assert(region, "region not created")
  local button = private.ClickButtons.GetButton(region)
  assert(button, "no button for the click action")
  assert(test.Frames.IsSecure(button), "button not secure")
  -- Looked up as the game does on a click, without modifier then with Shift held.
  for _, prefix in ipairs({ "", "shift-", "alt-ctrl-shift-" }) do
    local function Attribute(name, suffix) return button:GetAttribute(prefix, name, suffix) end
    assert(Attribute("type", "1") == "spell" and Attribute("spell", "1") == "Lightning Shield", "left click " .. prefix)
    assert(Attribute("type", "2") == "item" and Attribute("item", "2") == "item:6948", "right click " .. prefix)
    assert(Attribute("type", "3") == "macro" and Attribute("macrotext", "3") == "/sit", "middle click " .. prefix)
  end
  assert(not button:IsShown(), "button shown while the aura is hidden")
  assert(test.WowApi.overrideBindings.F == nil, "key bound while the aura is hidden")

  local buff = test.Units.ApplyAura("player", { name = "Lightning Shield", spellId = 324, duration = 600 })
  test.Environment.Advance(0.5)
  assert(region:IsShown(), "aura hidden with its buff")
  assert(button:IsShown(), "button hidden while the aura shows")
  local binding = test.WowApi.overrideBindings.F
  assert(binding and binding.owner == button and binding.button == button:GetName(), "key not bound to the button")

  -- In combat the button keeps its state; the change waits for the combat end.
  test.Units.SetCombat(true)
  test.Units.RemoveAura("player", buff)
  test.Environment.Advance(0.5)
  assert(not region:IsShown(), "aura still shown without its buff")
  assert(#test.Environment.forbidden == 0, "secure button changed in combat: " .. tostring(test.Environment.forbidden[1]))
  assert((test.WowApi.blockedCalls or 0) == 0, "protected call made in combat")
  assert(button:IsShown(), "button changed in combat")

  -- Checked before any follow tick: PLAYER_REGEN_ENABLED alone applies the change.
  test.Units.SetCombat(false)
  assert(not button:IsShown(), "button not hidden after the combat")
  assert(test.WowApi.overrideBindings.F == nil, "key still bound after the combat")

  -- "Whole combat" mode: the aura hidden at the combat start, its button still shows for the whole combat.
  local data = WeakAuras.GetData("Shield")
  -- The icon gets a background sub-region in front of the click action.
  for _, subRegion in ipairs(data.subRegions) do
    if subRegion.type == "subclickaction" then
      subRegion.combat_mode = "combat"
    end
  end
  WeakAuras.Add(data)
  test.Environment.Advance(0.5)
  assert(not button:IsShown(), "combat mode: button shown out of combat while the aura is hidden")
  -- The game fires PLAYER_REGEN_DISABLED before the lockdown; the harness fires it after, so it is sent here first.
  test.Units.fire("PLAYER_REGEN_DISABLED")
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(button:IsShown(), "combat mode: button hidden in combat")
  assert(test.WowApi.overrideBindings.F, "combat mode: key not bound in combat")
  assert((test.WowApi.blockedCalls or 0) == 0, "combat mode: protected call made in combat")
  test.Units.SetCombat(false)
  assert(not button:IsShown(), "combat mode: button not hidden after the combat")
  assert(test.WowApi.overrideBindings.F == nil, "combat mode: key still bound after the combat")

  local function SetMode(mode, condition)
    for _, subRegion in ipairs(data.subRegions) do
      if subRegion.type == "subclickaction" then
        subRegion.combat_mode, subRegion.macro_condition = mode, condition or ""
      end
    end
    WeakAuras.Add(data)
    test.Environment.Advance(0.5)
  end
  local function NoProtectedCall(where)
    assert(#test.Environment.forbidden == 0, where .. ": " .. tostring(test.Environment.forbidden[1]))
    assert((test.WowApi.blockedCalls or 0) == 0, where .. ": protected call made in combat")
  end

  -- "Always": clickable while the aura is hidden.
  SetMode("always")
  assert(not region:IsShown(), "always mode: aura shown without its buff")
  assert(button:IsShown(), "always mode: button hidden")
  assert(test.WowApi.overrideBindings.F and test.WowApi.overrideBindings.F.owner == button, "always mode: key not bound")

  -- Options open: no click, no key; back at the next follow tick once closed.
  local isOptionsOpen = WeakAuras.IsOptionsOpen
  WeakAuras.IsOptionsOpen = function() return true end
  test.Environment.Advance(0.3)
  assert(not button:IsShown(), "options open: button shown")
  assert(test.WowApi.overrideBindings.F == nil, "options open: key bound")
  WeakAuras.IsOptionsOpen = isOptionsOpen
  test.Environment.Advance(0.3)
  assert(button:IsShown() and test.WowApi.overrideBindings.F, "options closed: button not back")

  -- Macro condition: the state driver of the game shows the button, no key is bound.
  SetMode("macro", "[combat] show; hide")
  assert(test.WowApi.stateDrivers[button] and test.WowApi.stateDrivers[button].visibility == "[combat] show; hide",
    "macro mode: no state driver")
  assert(test.WowApi.overrideBindings.F == nil, "macro mode: key bound")
  test.Units.SetCombat(true)
  test.Frames.DriverSetShown(button, true)
  test.Environment.Advance(0.5)
  NoProtectedCall("macro mode in combat")
  assert(button:IsShown(), "macro mode: driver show lost in combat")
  test.Units.SetCombat(false)
  -- Changed in place, without WeakAuras.Add, which frees the button and gives it back clean: the follow tick applies
  -- the change to a button that still has its driver.
  local function Live(mode, condition)
    for _, subRegion in ipairs(data.subRegions) do
      if subRegion.type == "subclickaction" then
        subRegion.combat_mode, subRegion.macro_condition = mode, condition
      end
    end
    test.Environment.Advance(0.3)
  end
  Live("macro", "[mod:shift] show; hide")
  assert(test.WowApi.stateDrivers[button].visibility == "[mod:shift] show; hide", "macro mode: condition not changed")
  test.Frames.DriverSetShown(button, true)
  WeakAuras.IsOptionsOpen = function() return true end
  test.Environment.Advance(0.3)
  assert(test.WowApi.stateDrivers[button].visibility == nil and not button:IsShown(), "macro mode: driver kept in options")
  WeakAuras.IsOptionsOpen = isOptionsOpen
  test.Environment.Advance(0.3)
  assert(test.WowApi.stateDrivers[button].visibility == "[mod:shift] show; hide", "macro mode: driver not back")
  test.Frames.DriverSetShown(button, true)
  Live("macro", "")
  assert(test.WowApi.stateDrivers[button].visibility == nil and not button:IsShown(), "macro mode: empty condition")
  Live("macro", "[combat] show; hide")
  test.Frames.DriverSetShown(button, true)
  Live("always", "")
  assert(test.WowApi.stateDrivers[button].visibility == nil, "always mode: macro driver kept")
  assert(button:IsShown() and test.WowApi.overrideBindings.F, "always mode after macro: button or key missing")
  NoProtectedCall("modes")

  -- The aura type changed: the aura drops its region without releasing the sub-regions; the old button is freed.
  data.regionType = "texture"
  WeakAuras.Add(data)
  test.Environment.Advance(0.5)
  local newRegion = WeakAuras.GetRegion("Shield")
  assert(newRegion and newRegion ~= region, "type change kept the region")
  assert(private.ClickButtons.GetButton(region) == nil, "button of the dropped region kept")
  assert(private.ClickButtons.GetButton(newRegion), "no button for the new region")
  assert(not button:IsShown(), "button of the dropped region still shown")
  region = newRegion
  button = private.ClickButtons.GetButton(region)
  assert(not button:GetName():find(":", 1, true), "button name with a colon breaks the CLICK binding")
  assert(test.WowApi.overrideBindings.F and test.WowApi.overrideBindings.F.owner == button, "key not moved to the new button")

  -- The click action removed: the button is freed with its key.
  data.subRegions = {}
  WeakAuras.Add(data)
  test.Environment.Advance(0.5)
  assert(private.ClickButtons.GetButton(region) == nil, "button kept after the click action was removed")
  for _, suffix in ipairs({ "1", "2", "3" }) do
    for _, name in ipairs({ "type", "spell", "item", "macrotext" }) do
      assert(button:GetAttribute("", name, suffix) == nil, "freed button keeps its action: " .. name .. suffix)
    end
  end
  assert(test.WowApi.overrideBindings.F == nil, "freed button keeps its key")
  assert(not button:IsShown(), "freed button still shown")
  assert(#test.Environment.forbidden == 0, "forbidden call: " .. tostring(test.Environment.forbidden[1]))

  -- Key clash warning of the options: other auras by sorted id, one per aura, the aura itself and the macro mode left out.
  local function Click(key, mode) return { type = "subclickaction", keybind = key, combat_mode = mode or "visible" } end
  WeakAurasSaved.displays.Zed = { id = "Zed", subRegions = { Click("F"), Click("F") } }
  WeakAurasSaved.displays.Other = { id = "Other", subRegions = { Click("F") } }
  WeakAurasSaved.displays.Pine = { id = "Pine", subRegions = { Click("F") } }
  WeakAurasSaved.displays.ByMacro = { id = "ByMacro", subRegions = { Click("F", "macro") } }
  WeakAurasSaved.displays.Self = { id = "Self", subRegions = { Click("F") } }
  assert(table.concat(private.ClickButtons.AurasBindingKey("F", "Self"), ",") == "Other,Pine,Zed", "auras binding F")
  assert(#private.ClickButtons.AurasBindingKey("", "Self") == 0, "empty key matched")
  -- Enough ids for the order of pairs to differ from the sorted order.
  local expected = {}
  for index = 1, 12 do
    local id = ("Key%02d"):format(index)
    expected[index] = id
    WeakAurasSaved.displays[id] = { id = id, subRegions = { Click("G") } }
  end
  assert(table.concat(private.ClickButtons.AurasBindingKey("G"), ",") == table.concat(expected, ","), "ids not sorted")
  for _, id in ipairs(expected) do WeakAurasSaved.displays[id] = nil end

  local createOptions
  local register = WeakAuras.RegisterSubRegionOptions
  WeakAuras.RegisterSubRegionOptions = function(name, create) if name == "subclickaction" then createOptions = create end end
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")
  local optionsPrivate = { AddUpDownDeleteDuplicate = function() end }
  local ok, message = test.Loader.RunFile(directory .. "SubRegionOptions/ClickAction.lua", "WeakAurasOptions", optionsPrivate)
  WeakAuras.RegisterSubRegionOptions = register
  assert(ok and createOptions, "ClickAction options: " .. tostring(message))
  optionsPrivate.Private = private
  local clickData = Click("F")
  local warning = createOptions({ id = "Self" }, clickData, 1, 1).keybindWarning
  test.WowApi.gameBindings.F = "JUMP"
  local text = warning.name()
  assert(text:find("This key is already bound by the game: JUMP", 1, true), "game binding not warned: " .. text)
  assert(text:find("This key is already bound by the aura: Other, Pine, Zed", 1, true), "aura binding not warned: " .. text)
  assert(warning.hidden() == false, "warning hidden")
  test.WowApi.gameBindings.F = nil
  WeakAurasSaved.displays.Zed, WeakAurasSaved.displays.Other, WeakAurasSaved.displays.Pine = nil, nil, nil
  assert(warning.name() == "" and warning.hidden() == true, "warning without clash")
  WeakAurasSaved.displays.Other = { id = "Other", subRegions = { Click("F") } }
  clickData.combat_mode = "macro"
  assert(warning.hidden() == true, "warning shown in macro mode")
  clickData.combat_mode, clickData.keybind = "visible", ""
  assert(warning.name() == "" and warning.hidden() == true, "warning shown without key")
end

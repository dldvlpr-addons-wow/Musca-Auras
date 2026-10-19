-- Modernize: a few version migrations and the Musca migrations that run at every version.
return function(test)
  local formsByPosition = {}
  GetNumShapeshiftForms = function() return #formsByPosition end
  GetShapeshiftFormInfo = function(index) return nil, nil, nil, formsByPosition[index] end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local current = WeakAuras.InternalVersion()

  local function Modernize(data)
    data.id = data.id or "Test"
    data.triggers = data.triggers or {}
    data.information = data.information or {}
    private.Modernize(data)
    assert(data.internalVersion == current, "internalVersion not raised: " .. tostring(data.internalVersion))
    return data
  end

  local bar = Modernize({ regionType = "aurabar", internalVersion = 88 })
  assert(bar.toolTipArea == "ICON", "v90 aurabar tooltip area")
  assert(bar.information.showNilIsFalse == true, "v89 showNilIsFalse")
  assert(Modernize({ regionType = "icon", internalVersion = 89 }).toolTipArea == nil, "v90 on an icon")
  assert(Modernize({ regionType = "icon", internalVersion = 89 }).information.showNilIsFalse == nil, "v89 applied twice")

  local renamed = Modernize({ regionType = "icon", internalVersion = 86,
    conditions = { { changes = { { property = "icon_visible" } } } } })
  assert(renamed.conditions[1].changes[1].property == "icon", "v87 icon_visible rename")

  local clipped = Modernize({ regionType = "aurabar", internalVersion = 85,
    subRegions = { { type = "submodel", bar_model_clip = true }, { type = "submodel" } } })
  local first, second = clipped.subRegions[1], clipped.subRegions[2]
  assert(first.bar_model_attach == true and first.bar_model_stretch == true and first.bar_model_clip == nil, "v86 clipped model")
  assert(not second.bar_model_stretch, "v86 stretch without clip")

  -- The v49 repair runs on data saved by v49 only.
  local function SavedBy(version)
    return Modernize({ regionType = "icon", internalVersion = version, actions = { start = {}, finish = {} }, load = {},
      subRegions = { { type = "subbackground" }, { type = "subtext" } },
      conditions = { { changes = { { property = "sub.1.text_visible" } } } } })
  end
  assert(SavedBy(49).conditions[1].changes[1].property == "sub.2.text_visible", "v49 condition not repaired")
  assert(SavedBy(50).conditions[1].changes[1].property == "sub.1.text_visible", "v49 repair ran on v50 data")

  local cdm = Modernize({ regionType = "icon", internalVersion = current, triggers = {
    { trigger = { type = "spell", event = "Blizzard Cooldown Manager", cdmSource = "buff" } },
    { trigger = { type = "spell", event = "Blizzard Cooldown Manager", cdmSource = "cooldown" } },
    { trigger = { type = "cdm", event = "Blizzard CDM Utility" } },
  } })
  local buff, cooldown, utility = cdm.triggers[1].trigger, cdm.triggers[2].trigger, cdm.triggers[3].trigger
  assert(buff.type == "cdm" and buff.event == "Blizzard CDM Buff", "CDM buff trigger")
  assert(cooldown.type == "cdm" and cooldown.event == "Blizzard Cooldown Manager", "CDM cooldown trigger")
  assert(utility.event == "Blizzard Cooldown Manager" and utility.cdmSource == "cooldown", "CDM utility trigger")

  local swing = Modernize({ regionType = "icon", internalVersion = current, triggers = {
    { trigger = { event = "Swing Timer", use_inRange = true } },
    { trigger = { event = "Swing Timer", use_inRange = false } },
    { trigger = { event = "Swing Timer", use_inRange = true, inRange = "outOfRange" } },
  } })
  assert(swing.triggers[1].trigger.inRange == "inRange" and swing.triggers[1].trigger.use_inRange == true, "swing in range")
  assert(swing.triggers[2].trigger.inRange == "outOfRange" and swing.triggers[2].trigger.use_inRange == true, "swing out of range")
  assert(swing.triggers[3].trigger.inRange == "outOfRange", "swing range already migrated")

  local function PackIcon(uid, text, point)
    return Modernize({ regionType = "icon", internalVersion = current, cooldownTextDisabled = false, uid = uid,
      subRegions = { { type = "subtext", text_text = text, anchor_point = point } } })
  end
  assert(PackIcon("mcxV1a", "%p", "CENTER").cooldownTextDisabled == true, "class pack icon keeps cooldown text")
  assert(PackIcon("other1", "%p", "CENTER").cooldownTextDisabled == false, "foreign icon changed")
  assert(PackIcon("mcxV1a", "%s", "CENTER").cooldownTextDisabled == false, "pack icon without %p changed")
  assert(PackIcon("mcxV1a", "%p", "TOP").cooldownTextDisabled == false, "pack icon with off-centre text changed")

  local realUnitClass, realLoginFinished = UnitClass, WeakAuras.IsLoginFinished
  WeakAuras.IsLoginFinished = function() return false end
  formsByPosition = { 9634, 768, 783 }
  UnitClass = function() return "Druid", "DRUID", 11 end
  local function FormAura(load, form, conditionValue)
    return Modernize({ regionType = "icon", internalVersion = 91, load = load,
      triggers = { { trigger = { event = "Stance/Form/Aura", use_form = false, form = form } } },
      conditions = { { check = { trigger = -2, checks = {
        { trigger = 1, variable = "form", op = "==", value = conditionValue },
      } } } } })
  end
  local druid = { use_class = true, class = { single = "DRUID" } }
  local converted = FormAura(druid, { multi = { [0] = true, [1] = true, [3] = false } }, 2)
  local trigger = converted.triggers[1].trigger
  assert(trigger.use_formByPosition == nil and trigger.formPositionToConvert == nil, "v92 flags left after conversion")
  assert(trigger.form.multi[0] == true and trigger.form.multi[5487] == true and trigger.form.multi[783] == false, "v92 form keys")
  assert(trigger.form.multi[1] == nil, "v92 position key left")
  assert(converted.conditions[1].check.checks[1].value == 768, "v92 condition value")

  local warrior = FormAura({ use_class = true, class = { single = "WARRIOR" } }, { multi = { [1] = true } }, 1)
  trigger = warrior.triggers[1].trigger
  assert(trigger.use_formByPosition == true and trigger.formPositionToConvert == true and trigger.form.multi[1], "v92 other class converted")
  local multiClass = FormAura({ use_class = false, class = { multi = { DRUID = true, WARRIOR = true } } }, { multi = { [1] = true } }, 1)
  assert(multiClass.triggers[1].trigger.formPositionToConvert == true, "v92 multi class converted")
  local unknown = FormAura(druid, { multi = { [1] = true, [4] = true } }, 1)
  assert(unknown.triggers[1].trigger.form.multi[4] and unknown.conditions[1].check.checks[1].value == 1, "v92 partial conversion")
  local bySpec = FormAura({ use_forever_spec = false, forever_spec = { multi = { DRUID_BALANCE = true, DRUID_RESTORATION = true } } },
    { multi = { [2] = true } }, nil)
  assert(bySpec.triggers[1].trigger.form.multi[768], "v92 aura loaded by druid specializations")
  local mixedSpec = FormAura({ use_forever_spec = false, forever_spec = { multi = { DRUID_BALANCE = true, WARRIOR_ARMS = true } } },
    { multi = { [2] = true } }, nil)
  assert(mixedSpec.triggers[1].trigger.formPositionToConvert, "v92 aura loaded by two classes converted")
  local spellMode = Modernize({ regionType = "icon", internalVersion = 91, triggers = {
    { trigger = { event = "Stance/Form/Aura", use_formByPosition = false, use_form = true, form = { single = 768 } } } } })
  assert(spellMode.triggers[1].trigger.use_formByPosition == false, "v92 marks a spell form trigger")
  local residual = FormAura(druid, { single = 4, multi = { [2] = true } }, nil)
  assert(residual.triggers[1].trigger.form.multi[768] and residual.triggers[1].trigger.form.single == nil, "v92 unused single dropped")
  WeakAuras.IsLoginFinished = function() return true end
  local afterLogin = FormAura(druid, { multi = { [1] = true } }, 1)
  assert(afterLogin.triggers[1].trigger.form.multi[1] and afterLogin.triggers[1].trigger.formPositionToConvert, "v92 converted after login")
  WeakAuras.IsLoginFinished = function() return false end

  UnitClass = function() return "Warrior", "WARRIOR", 1 end
  formsByPosition = { 2457, 71 }
  private.Modernize(warrior)
  trigger = warrior.triggers[1].trigger
  assert(trigger.use_formByPosition == nil and trigger.form.multi[2457] and warrior.conditions[1].check.checks[1].value == 2457, "v92 converted on the right class")
  local chosen = Modernize({ regionType = "icon", internalVersion = current, load = { use_class = true, class = { single = "WARRIOR" } },
    triggers = { { trigger = { event = "Stance/Form/Aura", use_formByPosition = true, use_form = true, form = { single = 1 } } } } })
  assert(chosen.triggers[1].trigger.form.single == 1 and chosen.triggers[1].trigger.use_formByPosition, "position chosen by the user converted")

  UnitClass, WeakAuras.IsLoginFinished = realUnitClass, realLoginFinished

  local realForm = GetShapeshiftForm
  GetShapeshiftForm = function() return 0 end
  assert(private.ExecEnv.ShapeshiftFormSpell() == 0, "humanoid form spell")
  formsByPosition = { 9634, 1785 }
  GetShapeshiftForm = function() return 2 end
  assert(private.ExecEnv.ShapeshiftFormSpell() == 1784, "stealth rank alias")
  formsByPosition = { 10293 }
  GetShapeshiftForm = function() return 1 end
  assert(private.ExecEnv.ShapeshiftFormSpell() == 465, "paladin aura rank alias")
  local realSpellName = private.ExecEnv.GetSpellName
  private.ExecEnv.GetSpellName = function(id) return "Spell " .. id end
  assert(private.event_prototypes["Stance/Form/Aura"].nameFunc({}) == "Spell 465", "form name")
  private.ExecEnv.GetSpellName = realSpellName
  GetShapeshiftForm = function() return 0 end
  assert(private.event_prototypes["Stance/Form/Aura"].nameFunc({}) == "Humanoid", "humanoid name")
  GetShapeshiftForm = realForm
  local prototype = private.event_prototypes["Stance/Form/Aura"]
  assert(prototype.init({ use_form = true, form = { single = 5487 } }):find("ShapeshiftFormSpell", 1, true), "form spell init")
  assert(prototype.init({ use_formByPosition = true, use_form = true, form = { single = 1 } }):find("GetShapeshiftForm()", 1, true), "form position init")
  local formArg
  for _, arg in ipairs(prototype.args) do
    if arg.name == "form" then formArg = arg end
  end
  assert(formArg.values({}) == private.form_spell_types and formArg.values({ use_formByPosition = true }) == private.form_types, "form values")
end

-- Modernize: a few version migrations and the Musca migrations that run at every version.
return function(test)
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
end

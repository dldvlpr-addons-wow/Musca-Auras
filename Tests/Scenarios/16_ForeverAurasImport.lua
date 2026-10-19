-- ForeverAurasImport: detection and conversion of imported aura tables.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local convert = private.ConvertForeverAurasImport
  assert(convert, "ConvertForeverAurasImport missing")

  local printed = {}
  local realPrint = WeakAuras.prettyPrint
  WeakAuras.prettyPrint = function(message) printed[#printed + 1] = tostring(message) end
  local function Printed(text)
    for _, line in ipairs(printed) do
      if line:find(text, 1, true) then return true end
    end
    return false
  end
  local function Aura(id, trigger, extra)
    local data = { id = id, internalVersion = 91, triggers = { { trigger = trigger, untrigger = {} } } }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end

  -- plain aura: untouched
  local plain = Aura("Plain", { type = "aura2", unit = "player" })
  assert(convert(plain) == false and plain.information == nil and #printed == 0, "plain aura converted")
  assert(convert(nil) == false and convert("text") == false and convert({}) == false, "invalid input")

  -- unsupported event
  local timeline = Aura("Timeline", { type = "event", event = "TimelineParser Timer" })
  assert(convert(timeline) == true, "unsupported event not detected")
  assert(timeline.information.showNilIsFalse == true, "showNilIsFalse not set")
  assert(Printed("TimelineParser Timer trigger has no equivalent"), "no warning for the unsupported event")
  assert(Printed("Converted from ForeverAuras"), "no conversion notice")
  assert(timeline.internalVersion == 91, "internal version of a recent aura: " .. tostring(timeline.internalVersion))
  local old = Aura("Old", { type = "event", event = "TimelineParser Stage" }, { internalVersion = 80 })
  assert(convert(old) and old.internalVersion == 89, "old internal version: " .. tostring(old.internalVersion))

  -- swing timer hand, tracking, role, durability, ammo
  printed = {}
  local swing = Aura("Swing", { type = "event", event = "Swing Timer", swingType = 2 })
  assert(convert(swing) and swing.triggers[1].trigger.hand == "ranged" and swing.triggers[1].trigger.use_hand, "swing hand")
  local tracking = Aura("Tracking", { type = "event", event = "Tracking", trackingType = "2580", trackingShow = "inactive" })
  assert(convert(tracking), "tracking not converted")
  local trigger = tracking.triggers[1].trigger
  assert(trigger.use_trackingSpell and trigger.trackingSpell[1] == 2580 and trigger.use_inverse, "tracking fields")
  local ammo = Aura("Ammo", { type = "event", event = "Ammo", ammoItemIDs = "2512, 2516" })
  assert(convert(ammo) and ammo.triggers[1].trigger.ammoItem[1] == 2512, "ammo item")
  assert(Printed("Ammo item list now filters"), "ammo warning")
  local role = Aura("Role", { type = "event", event = "Role", role = "TANK", swingType = 0 })
  assert(convert(role) and role.triggers[1].trigger.use_role == true, "role")
  local durability = Aura("Durability", { type = "event", event = "Equipment Durability", durabilitySlot = "3", trackingType = "" })
  assert(convert(durability) and durability.triggers[1].trigger.durabilitySlot == 3, "durability slot")

  -- form filter by form ID
  printed = {}
  local form = Aura("Form", { type = "unit", event = "Stance/Form/Aura", use_formID = false,
    formID = { single = 1, multi = { [8] = true, [18] = true, [99] = true } } })
  form.conditions = { { check = { trigger = 1, variable = "formID", op = "==", value = 3 } },
    { check = { checks = { { trigger = 1, variable = "form", value = 2 } } } } }
  assert(convert(form), "form ID not converted")
  trigger = form.triggers[1].trigger
  assert(trigger.use_form == false and trigger.form.single == nil, "form single")
  assert(trigger.form.multi[5487] and trigger.form.multi[71] and trigger.use_formByPosition == false, "form multi")
  assert(trigger.use_formID == nil and trigger.formID == nil, "form ID fields kept")
  assert(Printed("Form ID 99 has no equivalent"), "unknown form ID warning")
  assert(form.conditions[1].check.variable == "form" and form.conditions[1].check.value == 783, "form ID condition")
  assert(Printed("Condition on form by position"), "form position condition warning")
  printed = {}
  local single = Aura("Form single", { type = "unit", event = "Stance/Form/Aura", use_formID = true, formID = { single = 2 },
    use_form = true, form = { single = 1 } })
  assert(convert(single), "single form ID not converted")
  assert(single.triggers[1].trigger.use_form == nil, "unknown single form kept")
  assert(Printed("Form ID 2 has no equivalent") and Printed("Form filter by position replaced"), "single form warnings")

  -- references to the ForeverAuras addon and API
  local references = Aura("References", { type = "custom", custom_type = "stateupdate",
    custom = "function() return ForeverAuras.GetSomething() end" }, {
    actions = { init = { do_custom = true, custom = "local x = ForeverAuras:Get()" } },
    icon = [[Interface\AddOns\ForeverAuras\Media\icon.tga]],
  })
  assert(convert(references), "references not converted")
  assert(references.triggers[1].trigger.custom:find("WeakAuras.GetSomething", 1, true), "custom code reference")
  assert(references.actions.init.custom:find("WeakAuras:Get", 1, true), "init code reference")
  assert(references.icon == [[Interface\AddOns\WeakAuras\Media\icon.tga]], "texture path " .. references.icon)
  local text = Aura("Text", { type = "aura2" }, { displayText = "ForeverAuras.Name" })
  assert(convert(text) == false, "non code text with the API name converted")

  -- anchors and glow frames on another ForeverAuras aura
  local anchored = Aura("Anchored", { type = "aura2" }, {
    anchorFrameType = "SELECTFRAME", anchorFrameFrame = "ForeverAuras:Parent",
    actions = { start = { do_glow = true, glow_frame = "ForeverAuras:Other" } },
  })
  assert(convert(anchored), "frame reference not detected")
  assert(anchored.anchorFrameFrame == "WeakAuras:Parent", "anchor " .. anchored.anchorFrameFrame)
  assert(anchored.actions.start.glow_frame == "WeakAuras:Other", "glow frame " .. anchored.actions.start.glow_frame)
  local named = Aura("Named", { type = "aura2" }, { anchorFrameFrame = "MyForeverAuras:Frame" })
  assert(convert(named) == false and named.anchorFrameFrame == "MyForeverAuras:Frame", "frame name without the prefix converted")

  -- global alias, only when ForeverAuras is not loaded
  assert(ForeverAuras == WeakAuras, "ForeverAuras alias missing")
  local sandboxed = WeakAuras.LoadFunction("return function() return ForeverAuras, WeakAuras end")
  local aliasInCode, fakeInCode = sandboxed()
  assert(aliasInCode == fakeInCode and aliasInCode ~= WeakAuras, "custom code reaches the real WeakAuras table")

  -- group: children converted, warnings carry the child id
  printed = {}
  local group = { id = "Group", internalVersion = 91 }
  local child = Aura("ChildBag", { type = "event", event = "Bag Space", use_totalSlots = true },
    { conditions = { { check = { trigger = 1, variable = "freePercent", op = ">", value = "5" }, changes = {} } } })
  assert(convert(group, { plain, child }) == true, "group not converted")
  assert(Printed("ChildBag: Bag Space total slots"), "bag space warning")
  assert(Printed("ChildBag: Condition on Bag Space freePercent"), "bag space condition warning")
  assert(plain.information == nil, "plain child converted")
  assert(group.information == nil, "plain group converted")

  WeakAuras.prettyPrint = realPrint
end

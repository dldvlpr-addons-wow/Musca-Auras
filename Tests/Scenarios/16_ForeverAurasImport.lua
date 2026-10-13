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
  assert(timeline.internalVersion == WeakAuras.InternalVersion(), "internal version of a recent aura: " .. tostring(timeline.internalVersion))
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

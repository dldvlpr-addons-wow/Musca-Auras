-- RestrictedTriggersContract: freezes GenericTriggerRestricted, ClassicEraTriggers, TextStyle and the code of
-- PlayerSpecialization through their public exports (Private.* and Private.ExecEnv.*).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Frames = test.Secret, test.Frames
  local ExecEnv = private.ExecEnv

  local saved = {}
  local function SetGlobal(name, value)
    if saved[name] == nil then saved[name] = { rawget(_G, name) } end
    rawset(_G, name, value)
  end
  local function RestoreGlobals()
    for name, old in pairs(saved) do rawset(_G, name, old[1]) end
    saved = {}
  end
  local function Join(list) return table.concat(list, ",") end

  -- Broadcasts recorded while still reaching the real ScanEvents.
  local scans = {}
  local realScanEvents = private.ScanEvents
  private.ScanEvents = function(event, ...)
    scans[#scans + 1] = { event = event, count = select("#", ...), arg = (...) }
    return realScanEvents(event, ...)
  end
  local function Scans(event)
    local list = {}
    for _, scan in ipairs(scans) do
      if scan.event == event then list[#list + 1] = scan end
    end
    return list
  end

  -- 1. RestrictionChanged relay: RESTRICTION_CHANGED then SECRET_STATE_UPDATE, no argument, whatever the argument.
  for _, argument in ipairs({ true, false }) do
    scans = {}
    private.callbacks:Fire("RestrictionChanged", argument)
    local order = {}
    for _, scan in ipairs(scans) do
      if scan.event == "WA_RESTRICTION_CHANGED" or scan.event == "WA_SECRET_STATE_UPDATE" then
        order[#order + 1] = scan.event
        assert(scan.count == 0, scan.event .. " carries an argument")
      end
    end
    assert(Join(order) == "WA_RESTRICTION_CHANGED,WA_SECRET_STATE_UPDATE", "relay order: " .. Join(order))
  end

  -- 2. Totems.
  local totems = {}
  SetGlobal("GetTotemInfo", function(slot)
    local t = totems[slot]
    if not t then return false, "", 0, 0, 0, 1, nil end
    return t[1], t[2], t[3], t[4], t[5], t[6], t[7]
  end)
  local function SecretTotem() return { Secret.Wrap(true), Secret.Wrap("x"), Secret.Wrap(5), Secret.Wrap(30), Secret.Wrap(9), Secret.Wrap(1), Secret.Wrap(5394) } end
  local expectedName, expectedIcon = ExecEnv.GetSpellName(5394), ExecEnv.GetSpellIcon(5394)

  totems[2] = { true, "Searing Totem", 900, 60, 135825, 1, 5394 }
  scans = {}
  Frames.Fire("PLAYER_REGEN_ENABLED")
  local totemScans = Scans("WA_TOTEM_UPDATE")
  assert(#totemScans == 1 and totemScans[1].count == 0, "regen rescan must broadcast WA_TOTEM_UPDATE without slot")
  assert(private.db and private.db.totemSpells and private.db.totemSpells[5394] == 2, "totem spell not learned")
  local have, name, start, duration, icon, modRate, spellId = ExecEnv.GetTotemSlotInfo(2)
  assert(have == true and name == "Searing Totem" and start == 900 and duration == 60 and icon == 135825
    and modRate == 1 and spellId == 5394, "raw readable result altered")

  totems[2] = SecretTotem()
  have, name, start, duration, icon, modRate, spellId = ExecEnv.GetTotemSlotInfo(2)
  assert(name == "Searing Totem" and icon == 135825 and spellId == 5394, "secret fields not replaced by memory")
  assert(Secret.IsSecret(have) and Secret.IsSecret(start) and Secret.IsSecret(duration) and Secret.IsSecret(modRate),
    "have/start/duration/modRate must stay raw (secret)")
  totems[3] = SecretTotem()
  _, name, _, _, icon, _, spellId = ExecEnv.GetTotemSlotInfo(3)
  assert(Secret.IsSecret(name) and Secret.IsSecret(icon) and Secret.IsSecret(spellId), "no memory: raw secrets expected")

  -- Unreadable slot with no recent cast: memory dropped, slot broadcast.
  scans = {}
  Frames.Fire("PLAYER_TOTEM_UPDATE", 2)
  totemScans = Scans("WA_TOTEM_UPDATE")
  assert(#totemScans == 1 and totemScans[1].arg == 2, "PLAYER_TOTEM_UPDATE must broadcast the slot")
  _, name = ExecEnv.GetTotemSlotInfo(2)
  assert(Secret.IsSecret(name), "memory must be cleared without a recent cast")

  -- Cast of the learned spell: memory rebuilt from spell name/icon and slot broadcast.
  scans = {}
  Frames.Fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 5394)
  totemScans = Scans("WA_TOTEM_UPDATE")
  assert(#totemScans == 1 and totemScans[1].arg == 2, "cast of a learned totem spell must broadcast its slot")
  _, name, _, _, icon, _, spellId = ExecEnv.GetTotemSlotInfo(2)
  assert(name == expectedName and icon == expectedIcon and spellId == 5394, "memory not rebuilt from the spell")

  -- 0.5 s window: kept at 0.4 s, dropped at 0.6 s.
  test.Environment.Advance(0.4)
  Frames.Fire("PLAYER_TOTEM_UPDATE", 2)
  _, name, _, _, _, _, spellId = ExecEnv.GetTotemSlotInfo(2)
  assert(spellId == 5394 and name == expectedName, "memory lost inside the 0.5 s window")
  test.Environment.Advance(0.2)
  Frames.Fire("PLAYER_TOTEM_UPDATE", 2)
  _, name = ExecEnv.GetTotemSlotInfo(2)
  assert(Secret.IsSecret(name), "memory kept past the 0.5 s window")

  -- Casts that must not broadcast: secret spell, unknown spell, other unit.
  scans = {}
  Frames.Fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", Secret.Wrap(5394))
  Frames.Fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 123)
  Frames.Fire("UNIT_SPELLCAST_SUCCEEDED", "target", "guid", 5394)
  assert(#Scans("WA_TOTEM_UPDATE") == 0, "unexpected WA_TOTEM_UPDATE")
  -- A learned cast on a readable slot does not rebuild anything either.
  totems[2] = { true, "Searing Totem", 900, 60, 135825, 1, 5394 }
  Frames.Fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 5394)
  assert(#Scans("WA_TOTEM_UPDATE") == 0, "readable slot must not broadcast on cast")

  -- Secret slot argument is forwarded as is.
  scans = {}
  Frames.Fire("PLAYER_TOTEM_UPDATE", Secret.Wrap(2))
  totemScans = Scans("WA_TOTEM_UPDATE")
  assert(#totemScans == 1 and Secret.IsSecret(totemScans[1].arg), "secret slot must be forwarded")

  -- Entering the world rescans the five slots.
  totems = { [4] = { true, "Grounding Totem", 800, 45, 136039, 1, 8177 } }
  scans = {}
  Frames.Fire("PLAYER_ENTERING_WORLD", false, false)
  assert(private.db.totemSpells[8177] == 4, "slot 4 not learned on entering world")
  assert(#Scans("WA_TOTEM_UPDATE") >= 1, "entering world must broadcast")

  -- Empty slot (startTime 0) clears memory.
  totems[4][3] = 0
  Frames.Fire("PLAYER_REGEN_ENABLED")
  totems[4] = SecretTotem()
  _, name = ExecEnv.GetTotemSlotInfo(4)
  assert(Secret.IsSecret(name), "emptied slot kept its memory")

  -- No database: memory per slot still works, nothing is created.
  local savedDb = private.db
  private.db = nil
  totems = { [1] = { true, "Tremor Totem", 700, 120, 136108, 1, 8143 } }
  Frames.Fire("PLAYER_REGEN_ENABLED")
  totems[1] = SecretTotem()
  _, name, _, _, _, _, spellId = ExecEnv.GetTotemSlotInfo(1)
  assert(name == "Tremor Totem" and spellId == 8143, "slot memory without database")
  assert(private.db == nil, "database created")
  private.db = savedDb
  assert(savedDb.totemSpells[8143] == nil, "learned without database")
  totems = {}
  Frames.Fire("PLAYER_REGEN_ENABLED")
  RestoreGlobals()

  -- 3. Restricted trigger warnings.
  local warnings = {}
  local updateCalls = 0
  local realUpdateWarning = private.AuraWarnings.UpdateWarning
  private.AuraWarnings.UpdateWarning = function(uid, key, severity, message)
    updateCalls = updateCalls + 1
    warnings[key] = severity and { severity = severity, message = message } or nil
  end
  local COMBAT_LOG = "WoW Forever does not give the combat log to addons: combat log triggers and CLEU events never fire."
  local THRESHOLD = "In combat, WoW Forever can hide health and power values from addons. A threshold on them cannot be "
    .. "checked then: the aura keeps its last state, or hides for a percent or deficit threshold."
  local function Check(triggers)
    warnings, updateCalls = {}, 0
    local data = { uid = "restricted-uid", triggers = {} }
    for index, trigger in ipairs(triggers) do data.triggers[index] = { trigger = trigger } end
    private.UpdateRestrictedTriggerWarnings(data)
    assert(updateCalls == 2, "both warnings must be refreshed on each call: " .. updateCalls)
    return (warnings.forever_combat_log and "L" or "-") .. (warnings.forever_secret_threshold and "T" or "-")
  end
  local function Custom(events, customType, check)
    return { type = "custom", events = events, custom_type = customType, check = check }
  end

  assert(private.hasCombatLog == false, "harness has no combat log")
  assert(Check({ Custom("CLEU:SPELL_DAMAGE", "event") }) == "L-", "CLEU custom event")
  assert(warnings.forever_combat_log.severity == "warning" and warnings.forever_combat_log.message == COMBAT_LOG,
    "combat log warning text")
  assert(Check({ Custom("UNIT_AURA combat_log_event_unfiltered", "event") }) == "L-", "case-insensitive combat log event")
  assert(Check({ Custom("UNIT_AURA, CLEU", "status", "event") }) == "L-", "status with check event counts")
  assert(Check({ Custom("CLEU:SPELL_DAMAGE", "status", "update") }) == "--", "status + update exempt")
  assert(Check({ Custom("CLEU:SPELL_DAMAGE", "stateupdate", "update") }) == "--", "stateupdate + update exempt")
  assert(Check({ Custom("UNIT_AURA PLAYER_CLEU", "event") }) == "--", "event must start with CLEU")
  assert(Check({ Custom(nil, "event") }) == "--", "custom trigger without events")
  assert(Check({ "not a table", Custom("CLEU", "event") }) == "L-", "non-table trigger ignored")
  assert(Check({ { type = "combatlog", event = "Combat Log" } }) == "L-", "Combat Log prototype")
  assert(Check({ { type = "aura2", event = "Health", use_health = true, health = "5" } }) == "--", "aura trigger ignored")
  assert(Check({ { type = "unit", event = "Cast" } }) == "--", "prototype without threshold")
  assert(Check({ { type = "unit", event = "NoSuchEvent" } }) == "--", "unknown event")
  assert(Check({ { type = "nosuchcategory", event = "Health", use_health = true, health = "5" } }) == "--", "unknown category")
  assert(Check({ { type = "unit", event = "Health", use_health = true, health = "5" } }) == "-T", "health threshold")
  assert(warnings.forever_secret_threshold.severity == "warning" and warnings.forever_secret_threshold.message == THRESHOLD,
    "threshold warning text")
  assert(Check({ { type = "unit", event = "Health", use_percenthealth = true, percenthealth = "50" } }) == "-T", "percent health")
  assert(Check({ { type = "unit", event = "Health", use_deficit = true, deficit = "50" } }) == "-T", "deficit")
  assert(Check({ { type = "unit", event = "Health", use_health = true } }) == "--", "option checked without value")
  assert(Check({ { type = "unit", event = "Health", health = "5" } }) == "--", "value without option checked")
  assert(Check({ { type = "unit", event = "Power", use_power = true, power = "5" } }) == "-T", "power threshold")
  assert(Check({ { type = "unit", event = "Power", use_countCharged = true, countCharged = "1" } }) == "--",
    "countCharged excluded")
  assert(Check({ Custom("CLEU", "event"), { type = "unit", event = "Health", use_health = true, health = "5" } }) == "LT",
    "both warnings")
  assert(Check({}) == "--", "no trigger")
  private.hasCombatLog = true
  assert(Check({ Custom("CLEU", "event"), { type = "unit", event = "Health", use_health = true, health = "5" } }) == "--",
    "combat log client examines nothing")
  private.hasCombatLog = false
  private.AuraWarnings.UpdateWarning = realUpdateWarning

  -- 4. TextStyle.
  local function Recorder()
    local object, log = {}, {}
    function object:SetFont(...) log[#log + 1] = "font:" .. Join({ tostring((...)), select(2, ...) }) end
    function object:SetShadowColor(...) log[#log + 1] = "color:" .. Join({ ... }) end
    function object:SetShadowOffset(...) log[#log + 1] = "offset:" .. Join({ ... }) end
    return object, log
  end
  local standard = STANDARD_TEXT_FONT
  local shadow = { 0.1, 0.2, 0.3, 0.4 }
  local textFrame = CreateFrame("Frame")
  local function Apply(flags, shadowX, shadowY)
    local object, log = Recorder()
    local text = textFrame:CreateFontString(nil, "OVERLAY")
    private.ApplyTextFont(text, object, "Fonts\\Custom.ttf", 14, flags, shadow, shadowX, shadowY)
    assert(text:GetFontObject() == object, "text not bound to the given font object")
    local path, size, appliedFlags = text:GetFont()
    assert(path == "Fonts\\Custom.ttf" and size == 14 and appliedFlags == flags, "text font " .. tostring(path))
    return log
  end
  local expectedBase = "font:" .. standard .. ",14,"
  for flags, offset in pairs({ ["OUTLINE|SLUG"] = "0,0", ["THICKOUTLINE|SLUG"] = "0,0", ["OUTLINE"] = "1,-1",
    [""] = "1,-1", ["MONOCHROME|OUTLINE"] = "1,-1", ["SLUG|OUTLINE"] = "1,-1", ["OUTLINE|SLUG|MONOCHROME"] = "1,-1" }) do
    local log = Apply(flags, 1, -1)
    assert(Join(log) == expectedBase .. flags .. ",color:0.1,0.2,0.3,0.4,offset:" .. offset, flags .. ": " .. Join(log))
  end

  local first, second = textFrame:CreateFontString(nil, "OVERLAY"), textFrame:CreateFontString(nil, "OVERLAY")
  private.ApplyTextFont(first, nil, "Fonts\\Custom.ttf", 12, "OUTLINE", shadow, 1, -1)
  local createdObject = first:GetFontObject()
  local number = tonumber(tostring(Frames.State[createdObject].name):match("^WeakAuras%-NativeText%-Font(%d+)$"))
  assert(number, "created font name: " .. tostring(Frames.State[createdObject].name))
  private.ApplyTextFont(first, nil, "Fonts\\Custom.ttf", 16, "OUTLINE", shadow, 1, -1)
  assert(first:GetFontObject() == createdObject, "font object not reused for the same text")
  private.ApplyTextFont(second, nil, "Fonts\\Custom.ttf", 12, "OUTLINE", shadow, 1, -1)
  assert(second:GetFontObject() ~= createdObject, "font object shared between texts")
  assert(Frames.State[second:GetFontObject()].name == "WeakAuras-NativeText-Font" .. (number + 1), "counter not incremental")

  local function Fake(usable)
    local log, text, objectSets = {}, {}, 0
    function text:SetFontObject() log[#log + 1] = "object"; objectSets = objectSets + 1 end
    function text:SetFont(path, size, flags) log[#log + 1] = "text:" .. tostring(path) end
    function text:GetFont() return usable(objectSets, log) and "Fonts\\Some.ttf" or nil end
    return text, log
  end
  local object, objectLog = Recorder()
  local text, textLog = Fake(function() return true end)
  private.ApplyTextFont(text, object, "bad", 10, "", shadow, 1, 1)
  assert(Join(textLog) == "object,text:bad", "valid font: " .. Join(textLog))
  object, objectLog = Recorder()
  text, textLog = Fake(function(sets) return sets >= 2 end)
  private.ApplyTextFont(text, object, "bad", 10, "", shadow, 1, 1)
  assert(Join(textLog) == "object,text:bad,object", "object retry: " .. Join(textLog))
  assert(Join(objectLog) == "font:" .. standard .. ",10,,color:0.1,0.2,0.3,0.4,offset:1,1,font:bad,10,", "object log: " .. Join(objectLog))
  object, objectLog = Recorder()
  text, textLog = Fake(function() return false end)
  private.ApplyTextFont(text, object, "bad", 10, "", shadow, 1, 1)
  assert(Join(textLog) == "object,text:bad,object,text:" .. standard, "standard fallback: " .. Join(textLog))
  object, objectLog = Recorder()
  text, textLog = Fake(function() return false end)
  private.ApplyTextFont(text, object, nil, 10, "", shadow, 1, 1)
  assert(Join(textLog) == "object,text:nil,text:" .. standard, "nil path fallback: " .. Join(textLog))
  assert(#objectLog == 3, "nil path must not reconfigure the object")

  -- 5. Classic Era functions (the harness reports Classic Era).
  assert(WeakAuras.IsClassicEra(), "harness flavor changed: update the absent-function checks")
  for category, events in pairs({ item = { "Ammo", "Bag Space", "Equipment Durability" }, unit = { "Role", "Tracking" } }) do
    for _, event in ipairs(events) do
      assert(private.category_event_prototype[category][event] == WeakAuras.L[event], "category entry " .. event)
    end
  end

  SetGlobal("NUM_BAG_SLOTS", 1)
  SetGlobal("C_Item", { GetItemInfoInstant = function(id) return id, "t", "s", 0, "i", id >= 100 and 6 or 2 end })
  local bagItems = { [0] = { [1] = { itemID = 100, stackCount = 20 }, [2] = { itemID = 5, stackCount = 7 }, [3] = {} },
    [1] = { [1] = { itemID = 101 }, [2] = { itemID = 102, stackCount = 5 } } }
  SetGlobal("C_Container", {
    GetContainerNumSlots = function(bag) return bag == 0 and 3 or 2 end,
    GetContainerItemInfo = function(bag, slot) return bagItems[bag][slot] end,
  })
  assert(ExecEnv.GetCarriedAmmoCount() == 25, "ammo count: " .. tostring(ExecEnv.GetCarriedAmmoCount()))
  SetGlobal("C_Container", nil)
  assert(ExecEnv.GetCarriedAmmoCount() == 0, "ammo without container API")

  SetGlobal("NUM_BAG_SLOTS", 2)
  local bags = { [0] = { 5, 0, 16 }, [1] = { 3, 8, 10 }, [2] = { 2, 0, 12 } }
  local secretBag
  SetGlobal("C_Container", {
    GetContainerNumFreeSlots = function(bag)
      if bag == secretBag then return Secret.Wrap(1), 0 end
      return bags[bag][1], bags[bag][2]
    end,
    GetContainerNumSlots = function(bag) return bags[bag][3] end,
  })
  local free, total = ExecEnv.GetBagSpace(false)
  assert(free == 7 and total == 28, "general bags: " .. tostring(free) .. "/" .. tostring(total))
  free, total = ExecEnv.GetBagSpace(true)
  assert(free == 10 and total == 38, "all bags: " .. tostring(free) .. "/" .. tostring(total))
  secretBag = 1
  free, total = ExecEnv.GetBagSpace(true)
  assert(free == nil and total == nil, "secret bag must give nil, nil")
  SetGlobal("C_Container", nil)
  free, total = ExecEnv.GetBagSpace(true)
  assert(free == 0 and total == 0, "bag space without container API")

  SetGlobal("INVSLOT_FIRST_EQUIPPED", 1)
  SetGlobal("INVSLOT_LAST_EQUIPPED", 19)
  local durability, secretSlot = { [1] = { 50, 100 }, [2] = { 0, 100 }, [3] = { 100, 100 }, [4] = { nil, nil }, [5] = { 5, 0 } }, nil
  SetGlobal("GetInventoryItemDurability", function(slot)
    if slot == secretSlot then return Secret.Wrap(1), 2 end
    local entry = durability[slot]
    if entry then return entry[1], entry[2] end
  end)
  local lowest, overall, broken = ExecEnv.GetEquipmentDurability()
  assert(lowest == 0 and overall == 50 and broken == 1, "durability: " .. Join({ tostring(lowest), tostring(overall), tostring(broken) }))
  lowest, overall, broken = ExecEnv.GetEquipmentDurability(1)
  assert(lowest == 50 and overall == 50 and broken == 0, "durability slot 1")
  lowest, overall, broken = ExecEnv.GetEquipmentDurability(0)
  assert(lowest == 0 and overall == 50 and broken == 1, "slot below first equipped means all slots")
  lowest, overall, broken = ExecEnv.GetEquipmentDurability(7)
  assert(lowest == 100 and overall == 100 and broken == 0, "empty slot")
  secretSlot = 6
  lowest, overall, broken = ExecEnv.GetEquipmentDurability()
  assert(lowest == nil and overall == nil and broken == nil, "secret durability gives nil x3")
  lowest, overall, broken = ExecEnv.GetEquipmentDurability(1)
  assert(lowest == 50, "secret in another slot must not matter for a single slot")
  SetGlobal("GetInventoryItemDurability", nil)
  lowest, overall, broken = ExecEnv.GetEquipmentDurability(3)
  assert(lowest == 100 and overall == 100 and broken == 0, "durability without API")

  SetGlobal("tIndexOf", function(list, value) for index, entry in ipairs(list) do if entry == value then return index end end end)
  local tracking = { { spellID = 1, active = false, name = "a", texture = "ta" }, { spellID = 2, active = true, name = "b", texture = "tb" },
    { spellID = 3, active = true, name = "c", texture = "tc" } }
  SetGlobal("C_Minimap", { GetNumTrackingTypes = function() return #tracking end, GetTrackingInfo = function(index) return tracking[index] end })
  local function Track(list) return Join({ tostring((ExecEnv.GetActiveTracking(list))), select(2, ExecEnv.GetActiveTracking(list)) }) end
  assert(Track({}) == "true,2,b,tb", "any tracking: " .. Track({}))
  assert(Track({ 3 }) == "true,3,c,tc", "listed tracking: " .. Track({ 3 }))
  assert(select("#", ExecEnv.GetActiveTracking({ 1 })) == 1 and ExecEnv.GetActiveTracking({ 1 }) == false, "inactive listed tracking")
  tracking[2].active, tracking[3].active = false, false
  assert(ExecEnv.GetActiveTracking({}) == false, "no active tracking")
  SetGlobal("C_Minimap", nil)
  assert(ExecEnv.GetActiveTracking({}) == false, "tracking without API")

  -- Prototype structure.
  local function ArgNames(prototype)
    local names = {}
    for index, arg in ipairs(prototype.args) do names[index] = arg.name or "?" end
    return Join(names)
  end
  local prototypes = private.event_prototypes
  local expected = {
    Ammo = { "item", "count,carried,ammoItem,stacks,value,total,progressType,itemId,name,icon", "UNIT_INVENTORY_CHANGED", "static" },
    ["Bag Space"] = { "item", "includeSpecialty,free,used,stacks,value,name,icon,total,progressType", "BAG_UPDATE_DELAYED", "static" },
    ["Equipment Durability"] = { "item", "durabilitySlot,durabilityProgress,lowest,overall,broken,value,name,icon,total,progressType",
      "UPDATE_INVENTORY_DURABILITY", "static" },
    Role = { "unit", "role,?", "PLAYER_ROLES_ASSIGNED", "none" },
    Tracking = { "unit", "trackingSpell,inverse,?,spellId,name,icon", "MINIMAP_UPDATE_TRACKING", "none" },
  }
  for event, row in pairs(expected) do
    local prototype = prototypes[event]
    assert(prototype.type == row[1], event .. " type")
    assert(ArgNames(prototype) == row[2], event .. " args: " .. ArgNames(prototype))
    assert(prototype.force_events == row[3], event .. " force_events")
    assert(prototype.progressType == row[4], event .. " progressType")
    assert(prototype.statesParameter == "one" and prototype.automaticrequired == true, event .. " common fields")
    assert(Join(prototype.internal_events) == "WA_DELAYED_PLAYER_ENTERING_WORLD", event .. " internal_events")
    assert(prototype.name == WeakAuras.L[event], event .. " name")
  end
  assert(Join(prototypes.Ammo.events.events) == "BAG_UPDATE_DELAYED,PLAYER_EQUIPMENT_CHANGED"
    and Join(prototypes.Ammo.events.unit_events.player) == "UNIT_INVENTORY_CHANGED" and prototypes.Ammo.hasItemID, "Ammo events")
  assert(Join(prototypes["Equipment Durability"].events.events) == "UPDATE_INVENTORY_DURABILITY,PLAYER_EQUIPMENT_CHANGED", "durability events")
  assert(Join(prototypes.Role.events.events) == "PLAYER_ROLES_ASSIGNED,ROLE_CHANGED_INFORM,GROUP_ROSTER_UPDATE", "role events")
  assert(prototypes.Role.GetNameAndIcon == nil, "Role has no GetNameAndIcon")
  assert(prototypes.Role.init({}):find('UnitGroupRolesAssigned("player")', 1, true), "Role init")
  assert(prototypes["Bag Space"].init({ use_includeSpecialty = true }):find("GetBagSpace(true)", 1, true), "bag init true")
  assert(prototypes["Bag Space"].init({}):find("GetBagSpace(false)", 1, true), "bag init false")
  local durabilityInit = prototypes["Equipment Durability"].init({ use_durabilitySlot = true, durabilitySlot = "16", durabilityProgress = "lowest" })
  assert(durabilityInit:find("GetEquipmentDurability(16)", 1, true) and durabilityInit:find("local progress = lowest", 1, true), "durability init")
  durabilityInit = prototypes["Equipment Durability"].init({ durabilitySlot = "16" })
  assert(durabilityInit:find("GetEquipmentDurability(nil)", 1, true) and durabilityInit:find("local progress = overall", 1, true), "durability init default")
  local trackingInit = prototypes.Tracking.init({ use_trackingSpell = true, trackingSpell = { "1", "x", 3 }, use_inverse = true })
  assert(trackingInit:find("GetActiveTracking({1, 3})", 1, true) and trackingInit:find("local inverse = true", 1, true), "tracking init")
  trackingInit = prototypes.Tracking.init({ use_trackingSpell = true, trackingSpell = "7" })
  assert(trackingInit:find("GetActiveTracking({7})", 1, true) and trackingInit:find("local inverse = false", 1, true), "tracking scalar init")
  assert(prototypes.Tracking.init({ trackingSpell = { 5 } }):find("GetActiveTracking({})", 1, true), "tracking without option")
  local trackName, trackIcon = prototypes.Tracking.GetNameAndIcon({ use_trackingSpell = true, trackingSpell = { "2580" } })
  assert(trackName == ExecEnv.GetSpellName(2580) and trackIcon == ExecEnv.GetSpellIcon(2580), "tracking name and icon")
  trackName, trackIcon = prototypes.Tracking.GetNameAndIcon({ trackingSpell = { "2580" } })
  assert(trackName == WeakAuras.L["Tracking"] and trackIcon == "Interface\\Minimap\\Tracking\\None", "tracking default name")
  trackName, trackIcon = prototypes.Tracking.GetNameAndIcon({ use_trackingSpell = true, trackingSpell = { "x" } })
  assert(trackName == WeakAuras.L["Tracking"], "tracking non numeric spell")
  local bagName, bagIcon = prototypes["Bag Space"].GetNameAndIcon({})
  assert(bagName == WeakAuras.L["Bag Space"] and bagIcon == "Interface\\Icons\\INV_Misc_Bag_08", "bag name and icon")
  local durName, durIcon = prototypes["Equipment Durability"].GetNameAndIcon({})
  assert(durName == WeakAuras.L["Equipment Durability"] and durIcon == "Interface\\Icons\\Trade_BlackSmithing", "durability name and icon")
  SetGlobal("INVSLOT_AMMO", 0)
  SetGlobal("GetInventoryItemTexture", function(unit, slot) return unit == "player" and slot == 0 and "ammoTexture" or nil end)
  local ammoName, ammoIcon = prototypes.Ammo.GetNameAndIcon({})
  assert(ammoName == WeakAuras.L["Ammo"] and ammoIcon == "ammoTexture", "ammo name and icon")
  RestoreGlobals()

  -- 6. IsForeverSpecialization cases the specialization scenario does not cover.
  local IsSpec = ExecEnv.IsForeverSpecialization
  local spent, known = { 0, 0, 0 }, {}
  SetGlobal("C_SpecializationInfo", { GetActiveSpecGroup = function() return 1 end, GetCombatConfigIDForSpecGroup = function() return 42 end })
  SetGlobal("C_Traits", {
    GetConfigInfo = function() return { treeIDs = { 7 } } end,
    GetGroupDisplayInfoByTreeID = function() return { { groupID = 100, orderIndex = 0 }, { groupID = 101, orderIndex = 1 }, { groupID = 102, orderIndex = 2 } } end,
    GetGroupCurrencyInfo = function()
      local result = {}
      for index = 1, 3 do result[index] = { traitNodeGroupID = 99 + index, currencyInfos = { { spent = spent[index] } } } end
      return result
    end,
  })
  SetGlobal("C_SpellBook", { IsSpellKnown = function(id) return known[id] end })
  local function Matches()
    local list = {}
    for _, key in ipairs({ "WARRIOR_ARMS", "WARRIOR_FURY", "WARRIOR_PROTECTION" }) do
      if IsSpec(key) then list[#list + 1] = key end
    end
    return Join(list)
  end
  assert(IsSpec("NO_SUCH_KEY") == false and IsSpec(nil) == false, "unknown key")
  assert(IsSpec("MAGE_FIRE") == false, "other class")
  known[11129] = true
  assert(IsSpec("MAGE_FIRE") == false, "other class with a known spell")
  known[11129] = nil
  assert(Matches() == "", "zero points, no spell")
  known[23881] = true
  assert(Matches() == "WARRIOR_FURY", "zero points, signature spell known: " .. Matches())
  spent = { 5, 0, 0 }
  assert(Matches() == "WARRIOR_ARMS", "points decide over the known spell: " .. Matches())
  spent = { 0, 0, 0 }
  C_Traits.GetGroupCurrencyInfo = function() error("blocked") end
  assert(Matches() == "WARRIOR_FURY", "unreadable points fall back on spells: " .. Matches())
  C_Traits.GetGroupCurrencyInfo = nil
  assert(Matches() == "WARRIOR_FURY", "missing currency API falls back on spells")
  C_Traits.GetGroupCurrencyInfo = function() return {} end
  assert(Matches() == "WARRIOR_FURY", "empty currency result falls back on spells (all groups read as zero)")
  known[23881] = nil
  SetGlobal("C_SpecializationInfo", nil)
  known[12294] = true
  assert(Matches() == "WARRIOR_ARMS", "no C_SpecializationInfo")
  -- Spell APIs: first available wins, strict true only.
  known[12294] = 1
  assert(Matches() == "", "non-true result refused")
  known[12294] = Secret.Wrap(true)
  assert(Matches() == "", "secret result refused")
  known[12294] = nil
  C_SpellBook.IsSpellKnown = nil
  SetGlobal("IsPlayerSpell", function(id) return id == 23881 end)
  assert(Matches() == "WARRIOR_FURY", "IsPlayerSpell used when C_SpellBook.IsSpellKnown is absent")
  SetGlobal("IsPlayerSpell", nil)
  SetGlobal("IsSpellKnown", function(id) return id == 23922 end)
  assert(Matches() == "WARRIOR_PROTECTION", "IsSpellKnown used last")
  SetGlobal("IsSpellKnown", function() error("boom") end)
  assert(Matches() == "", "erroring spell API")
  SetGlobal("IsSpellKnown", nil)
  assert(Matches() == "", "no spell API")
  SetGlobal("C_SpellBook", nil)
  SetGlobal("IsSpellKnown", function(id) return id == 23922 end)
  assert(Matches() == "WARRIOR_PROTECTION", "no C_SpellBook table")
  RestoreGlobals()
  SetGlobal("UnitClass", function() return "Warrior", Secret.Wrap("WARRIOR"), 1 end)
  assert(IsSpec("WARRIOR_ARMS") == false, "secret class")
  RestoreGlobals()

  -- Labels and order.
  local keys = { "WARRIOR_ARMS", "WARRIOR_FURY", "WARRIOR_PROTECTION", "PALADIN_HOLY", "PALADIN_PROTECTION", "PALADIN_RETRIBUTION",
    "HUNTER_BEAST_MASTERY", "HUNTER_MARKSMANSHIP", "HUNTER_SURVIVAL", "ROGUE_ASSASSINATION", "ROGUE_COMBAT", "ROGUE_SUBTLETY",
    "PRIEST_DISCIPLINE", "PRIEST_HOLY", "PRIEST_SHADOW", "SHAMAN_ELEMENTAL", "SHAMAN_ENHANCEMENT", "SHAMAN_RESTORATION",
    "MAGE_ARCANE", "MAGE_FIRE", "MAGE_FROST", "WARLOCK_AFFLICTION", "WARLOCK_DEMONOLOGY", "WARLOCK_DESTRUCTION",
    "DRUID_BALANCE", "DRUID_FERAL_COMBAT", "DRUID_RESTORATION" }
  assert(Join(private.forever_specs_sorted) == Join(keys), "forever_specs_sorted: " .. Join(private.forever_specs_sorted))
  local count = 0
  for _ in pairs(private.forever_spec_types) do count = count + 1 end
  assert(count == 27, "forever_spec_types size " .. count)
  local labels = {
    WARRIOR_ARMS = "|TInterface\\Icons\\ability_rogue_eviscerate:0|t Warrior - Arms",
    HUNTER_BEAST_MASTERY = "|TInterface\\Icons\\ability_hunter_beasttaming:0|t Hunter - Beast Mastery",
    DRUID_FERAL_COMBAT = "|TInterface\\Icons\\ability_racial_bearform:0|t Druid - Feral Combat",
    MAGE_FIRE = "|TInterface\\Icons\\spell_fire_firebolt02:0|t Mage - Fire",
    ROGUE_COMBAT = "|TInterface\\Icons\\ability_backstab:0|t Rogue - Combat",
  }
  for key, label in pairs(labels) do
    assert(private.forever_spec_types[key] == label, key .. ": " .. tostring(private.forever_spec_types[key]))
  end
  for _, key in ipairs(keys) do
    local label = private.forever_spec_types[key]
    assert(label and label:find("^|TInterface\\Icons\\[%w_]+:0|t %u%l+ %- "), key .. " label shape: " .. tostring(label))
  end
end

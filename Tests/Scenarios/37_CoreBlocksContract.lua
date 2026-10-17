return function(test)
  local function Aura(id, triggers, extra)
    local data = {
      id = id, uid = id, regionType = "icon", internalVersion = 91, cooldown = true,
      triggers = triggers,
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    }
    for k, v in pairs(extra or {}) do data[k] = v end
    return data
  end
  local function Buff(spellId)
    return { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useExactSpellId = true,
      auraspellids = { tostring(spellId) }, matchesShowOn = "showOnActive" }, untrigger = {} }
  end
  local displays = {
    Duo = Aura("Duo", { Buff(111), Buff(222), activeTriggerMode = -10 }),
    Fixed = Aura("Fixed", { Buff(111), Buff(222), activeTriggerMode = 2 }),
    Anc = Aura("Anc", { Buff(333), activeTriggerMode = -10 }),
    Grp = Aura("Grp", {}, { regionType = "group", controlledChildren = {} }),
    BossLoad = Aura("BossLoad", { Buff(111), activeTriggerMode = -10 },
      { load = { use_enabledBossModID = true, enabledBossModID = "6, 99" } }),
    Show = Aura("Show", { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showAlways" }, untrigger = {} }, activeTriggerMode = -10 }),
  }
  local function Pattern(id, trigger)
    trigger.type, trigger.unit, trigger.debuffType, trigger.matchesShowOn = "aura2", "player", "HELPFUL", "showOnActive"
    return Aura(id, { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 })
  end
  local patterns = {
    PatEqual = Pattern("PatEqual", { useNamePattern = true, namePattern_name = "Battle Shout" }),
    PatEqualExplicit = Pattern("PatEqualExplicit", { useNamePattern = true, namePattern_name = "Battle Shout",
      namePattern_operator = "==" }),
    PatEqualPartial = Pattern("PatEqualPartial", { useNamePattern = true, namePattern_name = "Battle" }),
    PatFind = Pattern("PatFind", { useNamePattern = true, namePattern_name = "ttle S", namePattern_operator = "find('%s')" }),
    PatFindLiteral = Pattern("PatFindLiteral", { useNamePattern = true, namePattern_name = "^Battle",
      namePattern_operator = "find('%s')" }),
    PatMatch = Pattern("PatMatch", { useNamePattern = true, namePattern_name = "^Battle%s%a+$",
      namePattern_operator = "match('%s')" }),
    PatMatchOther = Pattern("PatMatchOther", { useNamePattern = true, namePattern_name = "^Arcane",
      namePattern_operator = "match('%s')" }),
    PatQuoted = Pattern("PatQuoted", { useNamePattern = true, namePattern_name = 'He said "hi" [x]%' }),
    PatUnchecked = Pattern("PatUnchecked", { namePattern_name = "Nothing at all" }),
    PatEmpty = Pattern("PatEmpty", { useNamePattern = true, namePattern_name = "" }),
    PatNoName = Pattern("PatNoName", { useNamePattern = true }),
  }
  for id, data in pairs(patterns) do displays[id] = data end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  local Secret, Units = test.Secret, test.Units
  local function Is(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
  local function Replace(table_, key, value)
    local old = table_[key]
    table_[key] = value
    return function() table_[key] = old end
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Private.UnitIsUnit: readable results pass through and are remembered per ordered pair; a secret result gives
  -- back the last readable one for an identifiable pair, nil otherwise.
  ---------------------------------------------------------------------------------------------------------------
  local nextResult
  local restore = Replace(_G, "UnitIsUnit", function() return nextResult end)
  nextResult = true
  Is(private.UnitIsUnit("uA", "uB"), true, "readable true")
  nextResult = Secret.Wrap(false)
  Is(private.UnitIsUnit("uA", "uB"), true, "secret gives the cached readable result")
  Is(private.UnitIsUnit("uB", "uA"), nil, "reverse pair has its own cache")
  Is(private.UnitIsUnit("uC", "uD"), nil, "unknown pair gives nil")
  nextResult = false
  Is(private.UnitIsUnit("uA", "uB"), false, "readable false replaces the cache")
  nextResult = Secret.Wrap(true)
  Is(private.UnitIsUnit("uA", "uB"), false, "cache follows the last readable result")
  Is(private.UnitIsUnit(Secret.Wrap("uA"), "uB"), nil, "secret argument: no cache read")
  Is(private.UnitIsUnit("uA", nil), nil, "nil argument: no cache read")
  Is(private.UnitIsUnit(1, 2), nil, "non-string arguments: no cache read")
  nextResult = true
  Is(private.UnitIsUnit(Secret.Wrap("uE"), "uF"), true, "readable result with a secret argument is returned")
  nextResult = Secret.Wrap(false)
  Is(private.UnitIsUnit(Secret.Wrap("uE"), "uF"), nil, "secret argument: nothing was cached")
  Is(private.UnitIsUnit("uE", "uF"), nil, "secret argument: pair still unknown")
  nextResult = true
  Is(private.UnitIsUnit(nil, nil), true, "nil arguments pass the readable result")
  nextResult = Secret.Wrap(false)
  Is(private.UnitIsUnit(nil, nil), nil, "nil arguments are not cached")
  restore()

  ---------------------------------------------------------------------------------------------------------------
  -- Private.GetActiveTriggerFor
  ---------------------------------------------------------------------------------------------------------------
  Is(private.GetActiveTriggerFor("Duo"), nil, "no active trigger")
  Is(private.GetActiveTriggerFor("Fixed"), 2, "positive activeTriggerMode wins")
  Is(private.GetActiveTriggerFor("UnknownAura"), nil, "unknown id")
  Units.ApplyAura("player", { name = "Second", spellId = 222, duration = 60 })
  test.Environment.Advance(0.5)
  Is(private.GetActiveTriggerFor("Duo"), 2, "only second trigger active")
  Units.ApplyAura("player", { name = "First", spellId = 111, duration = 60 })
  test.Environment.Advance(0.5)
  Is(private.GetActiveTriggerFor("Duo"), 1, "first active index")
  Is(private.GetActiveTriggerFor("Fixed"), 2, "positive mode ignores active triggers")

  ---------------------------------------------------------------------------------------------------------------
  -- IsSpellInRange / GetRange / CheckRange / GetEffectiveAttackPower
  ---------------------------------------------------------------------------------------------------------------
  local rangeResult
  restore = Replace(C_Spell, "IsSpellInRange", function()
    if rangeResult == "error" then error("boom") end
    return rangeResult
  end)
  rangeResult = true
  Is(WeakAuras.IsSpellInRange(1, "target"), 1, "in range")
  rangeResult = false
  Is(WeakAuras.IsSpellInRange(1, "target"), 0, "out of range")
  rangeResult = nil
  Is(WeakAuras.IsSpellInRange(1, "target"), nil, "unknown range")
  rangeResult = Secret.Wrap(true)
  Is(WeakAuras.IsSpellInRange(1, "target"), nil, "secret range")
  rangeResult = "error"
  Is(WeakAuras.IsSpellInRange(1, "target"), nil, "error")
  restore()

  local LibRangeCheck = LibStub("LibRangeCheck-3.0")
  local rangeMin, rangeMax, rangeCall
  restore = Replace(LibRangeCheck, "GetRange", function(self, unit, checkVisible)
    rangeCall = { self, unit, checkVisible }
    if rangeMin == "error" then error("boom") end
    return rangeMin, rangeMax
  end)
  rangeMin, rangeMax = 5, 10
  local a, b = WeakAuras.GetRange("target", true)
  assert(a == 5 and b == 10, "GetRange values")
  assert(rangeCall[1] == LibRangeCheck and rangeCall[2] == "target" and rangeCall[3] == true, "GetRange arguments")
  WeakAuras.GetRange("target")
  Is(rangeCall[3], nil, "GetRange passes checkVisible as given")
  rangeMin, rangeMax = Secret.Wrap(5), 10
  Is(WeakAuras.GetRange("target"), nil, "secret min")
  rangeMin, rangeMax = 5, Secret.Wrap(10)
  Is(WeakAuras.GetRange("target"), nil, "secret max")
  rangeMin = "error"
  Is(WeakAuras.GetRange("target"), nil, "GetRange error")

  rangeMin, rangeMax = 5, 10
  Is(WeakAuras.CheckRange("target", 10, "<="), true, "max <= range")
  Is(WeakAuras.CheckRange("target", 9, "<="), false, "max > range")
  Is(WeakAuras.CheckRange("target", 5, ">="), true, "min >= range")
  Is(WeakAuras.CheckRange("target", 6, ">="), false, "min < range")
  Is(WeakAuras.CheckRange("target", "10", "<="), true, "string range converted")
  Is(WeakAuras.CheckRange("target", "x", "<="), nil, "unconvertible range")
  Is(WeakAuras.CheckRange("target", 5, "anything"), true, "other operator behaves as >=")
  Is(WeakAuras.CheckRange("target", 6, nil), false, "nil operator behaves as >=")
  assert(rangeCall[3] == true, "CheckRange asks for visible units")
  rangeMin, rangeMax = nil, nil
  Is(WeakAuras.CheckRange("target", 999, "<="), true, "nil max counts as 999")
  Is(WeakAuras.CheckRange("target", 998, "<="), false, "nil max counts as 999 (above)")
  Is(WeakAuras.CheckRange("target", 0, ">="), true, "nil min counts as 0")
  Is(WeakAuras.CheckRange("target", 1, ">="), false, "nil min counts as 0 (below)")
  rangeMin, rangeMax = Secret.Wrap(5), 10
  Is(WeakAuras.CheckRange("target", 10, "<="), nil, "CheckRange secret")
  rangeMin = "error"
  Is(WeakAuras.CheckRange("target", 10, "<="), nil, "CheckRange error")
  restore()

  local power = { 100, 20, -5 }
  local restoreMelee = Replace(_G, "UnitAttackPower", function() return power[1], power[2], power[3] end)
  local restoreRanged = Replace(_G, "UnitRangedAttackPower", function() return 7, 3, 1 end)
  Is(WeakAuras.GetEffectiveAttackPower(false), 115, "melee attack power")
  Is(WeakAuras.GetEffectiveAttackPower(true), 11, "ranged attack power")
  power = { 100, Secret.Wrap(20), -5 }
  Is(WeakAuras.GetEffectiveAttackPower(false), nil, "secret attack power")
  restoreRanged()
  restoreRanged = Replace(_G, "UnitRangedAttackPower", nil)
  Is(WeakAuras.GetEffectiveAttackPower(true), nil, "no ranged API")
  restoreRanged()
  restoreMelee()

  ---------------------------------------------------------------------------------------------------------------
  -- Prototype "Spell in Range"
  ---------------------------------------------------------------------------------------------------------------
  local proto = private.event_prototypes["Spell in Range"]
  assert(proto, "prototype missing")
  Is(proto.type, "spell", "type")
  Is(proto.name, WeakAuras.L["Spell in Range"], "name")
  Is(proto.statesParameter, "one", "statesParameter")
  Is(proto.progressType, "none", "progressType")
  Is(proto.automaticrequired, true, "automaticrequired")
  Is(#proto.events.events, 1, "event count")
  Is(proto.events.events[1], "FRAME_UPDATE", "event")

  local args = {}
  for _, arg in ipairs(proto.args) do
    if arg.name then args[arg.name] = arg end
  end
  Is(args.spellName.type, "spell", "spellName type")
  Is(args.spellName.required, true, "spellName required")
  Is(args.spellName.showExactOption, true, "spellName exact option")
  Is(args.unit.values, "unit_types_range_check", "unit values")
  Is(args.unit.store, true, "unit stored")
  Is(args.inverse.display, WeakAuras.L["Inverse"], "inverse display")
  Is(args.inverse.desc, WeakAuras.L["Show while the unit is out of the spell's range instead."], "inverse desc")
  Is(args.inverse.type, "toggle", "inverse type")
  Is(args.name.hidden, true, "name hidden")
  Is(args.name.store, true, "name stored")
  Is(args.icon.hidden, true, "icon hidden")
  Is(args.icon.store, true, "icon stored")
  Is(args.unit.required, true, "unit required")
  Is(args.name.display, WeakAuras.L["Name"], "name display (Name condition and %name)")
  Is(args.name.conditionType, "string", "name conditionType")

  local unitExists = true
  local queriedSpell
  local function RunSpellInRange(trigger, spellRange)
    local code = proto.init(trigger)
    local environment = setmetatable({ Private = private, UnitExists = function() return unitExists end },
      { __index = _G })
    local chunk = assert(loadstring(code .. "\nreturn active, unit, spell", "spell-in-range"))
    setfenv(chunk, environment)
    queriedSpell = nil
    local restoreRange = Replace(C_Spell, "IsSpellInRange", function(spellArg)
      queriedSpell = spellArg
      return spellRange
    end)
    local ok, active, unit, spell = pcall(chunk)
    restoreRange()
    assert(ok, tostring(active))
    return active, unit, spell
  end

  local trigger = { spellName = "Fireball" }
  local active, unit, spell = RunSpellInRange(trigger, true)
  Is(trigger.unit, "target", "init sets the default unit")
  Is(unit, "target", "unit")
  Is(spell, "Fireball", "spell by name")
  Is(active, true, "in range is active")
  Is((RunSpellInRange({ spellName = "Fireball" }, false)), false, "out of range is inactive")
  Is((RunSpellInRange({ spellName = "Fireball" }, nil)), false, "unknown range is inactive")
  Is((RunSpellInRange({ spellName = "Fireball", use_inverse = true }, false)), true, "inverse: out of range active")
  Is((RunSpellInRange({ spellName = "Fireball", use_inverse = true }, true)), false, "inverse: in range inactive")
  Is((RunSpellInRange({ spellName = "Fireball", use_inverse = true }, nil)), false, "inverse: unknown inactive")
  _, unit = RunSpellInRange({ spellName = "Fireball", unit = "focus" }, true)
  Is(unit, "focus", "explicit unit")
  _, _, spell = RunSpellInRange({ spellName = "133", use_exact_spellName = true }, true)
  Is(spell, 133, "exact option: numeric spell id")
  _, _, spell = RunSpellInRange({ spellName = "abc", use_exact_spellName = true }, true)
  Is(spell, 0, "exact option: non numeric gives 0")
  -- Without the exact option the options may still save an id: it is checked by name, so every rank counts.
  local idName = "Fireball"
  local restoreName = Replace(private.ExecEnv, "GetSpellName", function(id)
    if id == 133 then return idName end
  end)
  active, _, spell = RunSpellInRange({ spellName = 133 }, true)
  restoreName()
  Is(spell, idName, "non exact numeric id becomes the spell name")
  Is(queriedSpell, idName, "IsSpellInRange receives the name for a non exact id")
  Is(active, true, "non exact numeric id in range")
  restoreName = Replace(private.ExecEnv, "GetSpellName", function() end)
  _, _, spell = RunSpellInRange({ spellName = 133 }, true)
  Is(spell, 133, "non exact id without a known name falls back to the id")
  restoreName()
  restoreName = Replace(private.ExecEnv, "GetSpellName", function(id)
    if id == 133 then return "Fireball" end
  end)
  local shownSpells = {}
  local restoreInfo = Replace(private.ExecEnv, "GetSpellInfo", function(spellRef)
    shownSpells.info = spellRef
    return "Info", nil, "InfoIcon"
  end)
  local restoreIcon = Replace(private.ExecEnv, "GetSpellIcon", function(spellRef)
    shownSpells.icon = spellRef
    return "Icon"
  end)
  local shownName, shownIcon = proto.GetNameAndIcon({ spellName = 133 })
  Is(shownName .. "/" .. shownIcon, "Info/InfoIcon", "GetNameAndIcon result")
  Is(shownSpells.info, 133, "GetNameAndIcon looks up a saved id by id")
  Is(proto.iconFunc({ spellName = 133 }), "Icon", "iconFunc result")
  Is(shownSpells.icon, 133, "iconFunc looks up a saved id by id")
  proto.GetNameAndIcon({ spellName = "133", use_exact_spellName = true })
  Is(shownSpells.info, 133, "GetNameAndIcon exact id string")
  proto.iconFunc({ spellName = "Fireball" })
  Is(shownSpells.icon, "Fireball", "iconFunc by name")
  restoreIcon()
  restoreInfo()
  restoreName()
  unitExists = false
  Is((RunSpellInRange({ spellName = "Fireball" }, true)), false, "missing unit is inactive")
  Is((RunSpellInRange({ spellName = "Fireball", use_inverse = true }, false)), false, "missing unit inactive when inverse")
  unitExists = true
  local name, icon = proto.GetNameAndIcon({ spellName = "Fireball" })
  local expectedName, _, expectedIcon = private.ExecEnv.GetSpellInfo("Fireball")
  Is(name, expectedName, "GetNameAndIcon name")
  Is(icon, expectedIcon, "GetNameAndIcon icon")
  Is(proto.iconFunc({ spellName = "Fireball" }), private.ExecEnv.GetSpellIcon("Fireball"), "iconFunc")
  Is(proto.iconFunc({}), nil, "iconFunc without spell")
  Is(proto.iconFunc({ spellName = "Fireball", use_exact_spellName = true }), nil, "iconFunc exact mode with a name")
  Is((proto.GetNameAndIcon({ spellName = "Fireball", use_exact_spellName = true })), nil, "GetNameAndIcon exact mode with a name")

  ---------------------------------------------------------------------------------------------------------------
  -- Character Stats, the 5 Classic entries
  ---------------------------------------------------------------------------------------------------------------
  local stats = {}
  for _, arg in ipairs(private.event_prototypes["Character Stats"].args) do
    if arg.name then stats[arg.name] = arg end
  end
  local expected = {
    bonushealing = "Bonus Healing", rangedattackpower = "Ranged Attack Power",
    spellhastepercent = "Spell Haste (%)", rangedhastepercent = "Ranged Haste (%)", expertisepercent = "Expertise (%)",
  }
  for key, label in pairs(expected) do
    local arg = assert(stats[key], key .. " missing")
    Is(arg.display, WeakAuras.L[label], key .. " display")
    Is(arg.type, "number", key .. " type")
    Is(arg.store, true, key .. " store")
    Is(arg.conditionType, "number", key .. " conditionType")
    Is(arg.multiEntry.operator, "and", key .. " multiEntry operator")
    Is(arg.multiEntry.limit, 2, key .. " multiEntry limit")
    Is(arg.enable, WeakAuras.IsClassic(), key .. " enable")
    Is(arg.hidden, not WeakAuras.IsClassic(), key .. " hidden")
    Is(arg.formatter, key:find("percent") and "Number" or nil, key .. " formatter")
  end

  local function StatValue(key, secret)
    local chunk = assert(loadstring("local statsAreSecret = ...\nreturn " .. stats[key].init, key))
    setfenv(chunk, setmetatable({ Private = private, WeakAuras = WeakAuras }, { __index = _G }))
    return chunk(secret)
  end
  local globals = {
    GetSpellBonusHealing = function() return 321 end,
    UnitSpellHaste = function() return 12.5 end,
    GetRangedHaste = function() return 10, 5 end,
    GetExpertise = function() return -3 end,
    UnitRangedAttackPower = function() return 7, 3, 1 end,
  }
  local restores = {}
  for key, value in pairs(globals) do restores[#restores + 1] = Replace(_G, key, value) end
  Is(StatValue("bonushealing", false), 321, "bonus healing")
  Is(StatValue("rangedattackpower", false), 11, "ranged attack power")
  Is(StatValue("spellhastepercent", false), 12.5, "spell haste")
  Is(StatValue("rangedhastepercent", false), 15, "ranged haste")
  Is(StatValue("expertisepercent", false), 0, "expertise floors at 0")
  for key in pairs(expected) do
    Is(StatValue(key, true), nil, key .. " nil when stats are secret")
  end
  restores[#restores + 1] = Replace(_G, "GetExpertise", function() return 4.5 end)
  Is(StatValue("expertisepercent", false), 4.5, "expertise value")
  restores[#restores + 1] = Replace(_G, "GetExpertise", function() return 2, 1, 6.5 end)
  Is(StatValue("expertisepercent", false), 6.5, "expertise takes the largest of main hand, off hand, ranged")
  restores[#restores + 1] = Replace(_G, "GetExpertise", function() return -2, -1, -4 end)
  Is(StatValue("expertisepercent", false), 0, "expertise floors at 0 over every value")
  for _, api in ipairs({ "GetSpellBonusHealing", "UnitSpellHaste", "GetExpertise" }) do
    restores[#restores + 1] = Replace(_G, api, nil)
  end
  Is(StatValue("bonushealing", false), nil, "bonus healing without its API")
  Is(StatValue("spellhastepercent", false), nil, "spell haste without its API")
  Is(StatValue("expertisepercent", false), nil, "expertise without its API")
  local unitArgs = {}
  for _, arg in ipairs(private.event_prototypes["Unit Characteristics"].args) do
    if arg.name then unitArgs[arg.name] = arg end
  end
  Is(unitArgs.ignoreInvisible.desc, WeakAuras.L["Ignores group members the game has not loaded (UnitIsVisible), about 100 yards away. Updated when a member comes in or goes out of that range."], "ignoreInvisible desc")
  for index = #restores, 1, -1 do restores[index]() end

  ---------------------------------------------------------------------------------------------------------------
  -- Boss mods
  ---------------------------------------------------------------------------------------------------------------
  Is(WeakAuras.IsBossModEnabled({ [1] = true }), nil, "no boss mod addon: nothing")
  local wanted = private.ExecEnv.EncounterIdSet("12, abc 345;6x7\n8")
  local ids = {}
  for id, value in pairs(wanted) do
    Is(value, true, "encounter flag")
    ids[#ids + 1] = id
  end
  table.sort(ids)
  Is(table.concat(ids, ","), "6,7,8,12,345", "parsed encounter ids")
  Is(next(private.ExecEnv.EncounterIdSet(nil)), nil, "nil input")
  Is(next(private.ExecEnv.EncounterIdSet("")), nil, "empty input")
  Is(WeakAuras.IsBossModEnabled(wanted), nil, "parsed ids without boss mod")
  Is(WeakAuras.IsAuraLoaded("BossLoad"), false, "boss mod load option: not loaded without boss mod")
  local askedEncounters
  local restoreBossMod = Replace(WeakAuras, "IsBossModEnabled", function(set)
    askedEncounters = set
    return set[6]
  end)
  private.callbacks:Fire("WA_BIGWIGS_ENCOUNTER_MODULES_CHANGED")
  test.Environment.Advance(0.5)
  Is(WeakAuras.IsAuraLoaded("BossLoad"), true, "boss mod load option: loaded once the module is enabled")
  Is(askedEncounters and askedEncounters[99], true, "boss mod load option: every typed id is asked")
  restoreBossMod()
  private.callbacks:Fire("WA_BIGWIGS_ENCOUNTER_MODULES_CHANGED")
  test.Environment.Advance(0.5)
  Is(WeakAuras.IsAuraLoaded("BossLoad"), false, "boss mod load option: unloaded when the module goes away")

  ---------------------------------------------------------------------------------------------------------------
  -- pAdd: cdmDispelIndicator migration (through WeakAuras.Add)
  ---------------------------------------------------------------------------------------------------------------
  local function AddAura(id, regionType, extra)
    local data = Aura(id, {}, { regionType = regionType })
    data.triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Nothing" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 }
    for key, value in pairs(extra or {}) do data[key] = value end
    WeakAuras.Add(data)
    return data
  end
  local function DispelItems(data)
    local items = {}
    for _, subRegion in ipairs(data.subRegions or {}) do
      if subRegion.type == "subcdmdispel" or subRegion.type == "subcdmdispelborder" then items[#items + 1] = subRegion end
    end
    return items
  end

  local dispel = private.DispelTypeDisplay
  local restoreMigrate = Replace(dispel, "Migrate", function() end)
  local raw = AddAura("DispelRaw", "icon", { cdmDispelIndicator = true, subRegions = false })
  restoreMigrate()
  local item = DispelItems(raw)[1]
  Is(#DispelItems(raw), 1, "dispel sub element added once")
  Is(raw.cdmDispelIndicator, nil, "flag removed")
  Is(item.dispelVisible, true, "dispelVisible")
  Is(item.dispelStyle, "Border", "dispelStyle")
  Is(item.anchor_mode, "area", "anchor_mode")
  Is(item.anchor_area, "ALL", "anchor_area on an icon")
  Is(item.self_point, "CENTER", "self_point")
  Is(item.anchor_point, "CENTER", "anchor_point")
  Is(item.width, 32, "width")
  Is(item.height, 32, "height")
  Is(item.xOffset, 0, "xOffset")
  Is(item.yOffset, 0, "yOffset")


  local plain = AddAura("DispelIcon", "icon", { cdmDispelIndicator = true, subRegions = false })
  Is(#DispelItems(plain), 1, "dispel sub element added once (full flow)")
  Is(plain.cdmDispelIndicator, nil, "flag removed (full flow)")
  Is(DispelItems(plain)[1].type, "subcdmdispelborder", "Border style is then migrated")
  Is(DispelItems(plain)[1].dispelStyle, nil, "migrated element has no style")
  Is(DispelItems(plain)[1].anchor_area, "ALL", "migrated element area")
  WeakAuras.Add(plain)
  Is(#DispelItems(plain), 1, "second Add does not add again")

  local existing = AddAura("DispelBar", "aurabar", { cdmDispelIndicator = true,
    subRegions = { { type = "subbackground" } } })
  local barItems = DispelItems(existing)
  Is(#barItems, 1, "dispel sub element added on a bar")
  Is(barItems[1].anchor_area, "bar", "anchor_area on a bar")
  local kinds = {}
  for _, subRegion in ipairs(existing.subRegions) do kinds[#kinds + 1] = subRegion.type end
  Is(kinds[#kinds], "subcdmdispelborder", "dispel sub element is appended last")
  assert(table.concat(kinds, ","):find("subbackground", 1, true), "existing sub elements are kept")

  local without = AddAura("NoDispel", "icon", { cdmDispelIndicator = false })
  Is(#DispelItems(without), 0, "false flag adds nothing")
  Is(without.cdmDispelIndicator, false, "false flag untouched")

  ---------------------------------------------------------------------------------------------------------------
  -- PerformActions with the Blizzard native display
  ---------------------------------------------------------------------------------------------------------------
  local display = private.BlizzardAuraDisplay
  local iconData = WeakAuras.GetData("DispelIcon")
  iconData.actions = { start = {}, finish = {} }
  local iconRegion = WeakAuras.GetRegion("DispelIcon") or private.EnsureRegion("DispelIcon")
  assert(iconRegion, "icon region missing")
  local glowCalls, chatCalls, soundCalls, native = {}, 0, 0, false
  local restoreGlow = Replace(display, "HideUnitGlows", function(region) glowCalls[#glowCalls + 1] = region end)
  local restoreEnabled = Replace(display, "Enabled", function() return native end)
  local restoreChat = Replace(private, "HandleChatAction", function() chatCalls = chatCalls + 1 end)
  local restoreSound = Replace(iconRegion, "SoundPlay", function() soundCalls = soundCalls + 1 end)
  local function Perform(when, finish, start)
    iconData.actions = { start = start or {}, finish = finish or {} }
    glowCalls, chatCalls, soundCalls = {}, 0, 0
    private.PerformActions(iconData, when, iconRegion)
  end
  local message = { do_message = true, message_type = "PRINT", message = "hello", do_sound = true, sound = "x" }

  native = false
  Perform("finish", { hide_all_glows = true })
  Is(#glowCalls, 1, "finish hides glows")
  Is(glowCalls[1], iconRegion, "HideUnitGlows receives the region")
  Perform("start", {}, { hide_all_glows = true })
  Is(#glowCalls, 0, "start does not hide glows")
  Perform("finish", {})
  Is(#glowCalls, 0, "no hide_all_glows flag")
  Perform("finish", message)
  Is(chatCalls, 1, "non native: chat message sent")
  Is(soundCalls, 1, "non native: sound played")
  native = true
  Perform("finish", { hide_all_glows = true, do_message = true, message_type = "PRINT", message = "hello",
    do_sound = true, sound = "x" })
  Is(#glowCalls, 1, "native: glows still hidden")
  Is(chatCalls, 0, "native: no chat message")
  Is(soundCalls, 0, "native: no other actions")
  native = false
  local optionsOpen = Replace(WeakAuras, "IsOptionsOpen", function() return true end)
  Perform("finish", { hide_all_glows = true, do_message = true, message_type = "PRINT", message = "hello" })
  Is(#glowCalls, 1, "options open: glows hidden before the early exit")
  Is(chatCalls, 0, "options open: nothing else happens")
  optionsOpen()
  restoreSound()
  restoreChat()

  ---------------------------------------------------------------------------------------------------------------
  -- AnchorFrame with the Blizzard native display
  ---------------------------------------------------------------------------------------------------------------
  local anchored = private.EnsureRegion("Anc")
  assert(anchored, "anchor region missing")
  local anchorData = WeakAuras.GetData("Anc")
  local parentFrame = CreateFrame("Frame", nil, UIParent)
  local unitFrame = CreateFrame("Frame", nil, UIParent)
  local anchorTarget, unitQueried
  local restoreAnchor = Replace(anchored, "SetAnchor", function(_, _, frame) anchorTarget = frame end)
  local previewUnit = "party2"
  local restorePreview = Replace(display, "GetPreviewUnit", function() return previewUnit end)
  local unitFrames = { party1 = unitFrame, party2 = unitFrame }
  local restoreUnitFrame = Replace(WeakAuras, "GetUnitFrame", function(unit)
    unitQueried = unit
    return unitFrames[unit]
  end)
  anchored.state = { unit = "party1" }
  local function Anchor(anchorFrameType, parent)
    anchorData.anchorFrameType = anchorFrameType
    anchorTarget, unitQueried = nil, nil
    private.AnchorFrame(anchorData, anchored, parent)
    return anchorTarget
  end

  native = false
  Is(Anchor("UNITFRAME", parentFrame), unitFrame, "non native unit frame")
  Is(unitQueried, "party1", "non native: state unit")
  unitFrames.party1 = nil
  Is(Anchor("UNITFRAME", parentFrame), WeakAuras.HiddenFrames, "non native: no unit frame gives HiddenFrames")
  unitFrames.party1 = unitFrame

  native = true
  Is(Anchor("UNITFRAME", parentFrame), parentFrame, "native: parent")
  Is(unitQueried, nil, "native: unit frame not looked up")
  Is(anchored:GetParent(), parentFrame, "native: region parented to the parent")
  Is(Anchor("NAMEPLATE", parentFrame), parentFrame, "native nameplate: parent")
  Is(Anchor("UNITFRAME", nil), UIParent, "native: UIParent without a parent")
  Is(anchored:GetParent(), WeakAurasFrame, "native: WeakAurasFrame as region parent without parent")

  local open = Replace(WeakAuras, "IsOptionsOpen", function() return true end)
  Is(Anchor("UNITFRAME", parentFrame), unitFrame, "options open: preview unit frame")
  Is(unitQueried, "party2", "options open: preview unit")
  unitFrames.party2 = nil
  Is(Anchor("UNITFRAME", parentFrame), parentFrame, "options open, no frame: parent")
  Is(Anchor("UNITFRAME", nil), UIParent, "options open, no frame, no parent: UIParent")
  unitFrames.party2 = unitFrame
  Units.SetCombat(true)
  Is(Anchor("UNITFRAME", parentFrame), parentFrame, "options open in combat: early exit")
  Is(unitQueried, nil, "options open in combat: no lookup")
  Units.SetCombat(false)
  open()
  restoreUnitFrame()
  restorePreview()

  ---------------------------------------------------------------------------------------------------------------
  -- AnchorFrame, flow preview of a group
  ---------------------------------------------------------------------------------------------------------------
  native = false
  local group = private.EnsureRegion("Grp")
  assert(group, "group region missing")
  local groupData = WeakAuras.GetData("Grp")
  groupData.anchorFrameType = "SCREEN"
  local previewFrame = CreateFrame("Frame", nil, UIParent)
  local flowArgument
  local restoreFlow = Replace(display, "FlowPreviewFrame", function(data)
    flowArgument = data
    return previewFrame
  end)
  local groupAnchor, groupSelf, groupPoint
  local restoreGroupAnchor = Replace(group, "SetAnchor", function(_, selfPoint, frame, point)
    groupSelf, groupAnchor, groupPoint = selfPoint, frame, point
  end)
  parentFrame:SetFrameStrata("HIGH")
  groupData.selfPoint, groupData.anchorPoint = "TOPLEFT", "BOTTOMRIGHT"
  groupData.frameStrata = 1
  private.AnchorFrame(groupData, group, parentFrame)
  Is(flowArgument, groupData, "FlowPreviewFrame receives the data")
  Is(groupAnchor, previewFrame, "flow preview: anchored to the preview frame")
  Is(groupSelf, "TOPLEFT", "flow preview: self point")
  Is(groupPoint, "BOTTOMRIGHT", "flow preview: anchor point")
  Is(group:GetParent(), parentFrame, "flow preview: parent")
  Is(group:GetFrameStrata(), "HIGH", "flow preview: strata of the parent")
  groupData.frameStrata = 3
  private.AnchorFrame(groupData, group, nil)
  Is(group:GetParent(), WeakAurasFrame, "flow preview: WeakAurasFrame without a parent")
  Is(group:GetFrameStrata(), private.frame_strata_types[3], "flow preview: configured strata")
  groupAnchor = nil
  local restoreProtected = Replace(group, "IsProtected", function() return true end)
  Units.SetCombat(true)
  private.AnchorFrame(groupData, group, parentFrame)
  Is(groupAnchor, nil, "protected region in combat is postponed before the preview")
  Units.SetCombat(false)
  restoreProtected()
  restoreFlow()
  local restoreNoFlow = Replace(display, "FlowPreviewFrame", function() return nil end)
  private.AnchorFrame(groupData, group, parentFrame)
  assert(groupAnchor ~= previewFrame, "no preview frame: normal anchoring")
  restoreNoFlow()
  groupData.frameStrata = 1
  local restoreRegionType = Replace(groupData, "regionType", "icon")
  restoreFlow = Replace(display, "FlowPreviewFrame", function() return previewFrame end)
  groupAnchor = nil
  private.AnchorFrame(groupData, group, parentFrame)
  assert(groupAnchor ~= previewFrame, "preview only applies to groups")
  restoreRegionType()
  restoreFlow()
  restoreGroupAnchor()
  restoreAnchor()
  restoreEnabled()
  restoreGlow()

  ---------------------------------------------------------------------------------------------------------------
  -- Modernize: Cooldown Manager triggers
  ---------------------------------------------------------------------------------------------------------------
  local function Modernize(triggers)
    local data = { id = "Mod", regionType = "icon", internalVersion = WeakAuras.InternalVersion(),
      triggers = triggers, information = {} }
    private.Modernize(data)
    return data
  end
  local migrated = Modernize({
    { trigger = { type = "spell", event = "Blizzard Cooldown Manager", cdmSource = "buff" } },
    { trigger = { type = "spell", event = "Blizzard Cooldown Manager", cdmSource = "cooldown" } },
    { trigger = { type = "spell", event = "Blizzard Cooldown Manager" } },
    { trigger = { type = "spell", event = "Other", cdmSource = "buff" } },
    { trigger = { type = "aura2", event = "Blizzard Cooldown Manager", cdmSource = "buff" } },
  })
  local list = migrated.triggers
  Is(list[1].trigger.type, "cdm", "buff: type")
  Is(list[1].trigger.event, "Blizzard CDM Buff", "buff: event")
  Is(list[2].trigger.type, "cdm", "cooldown: type")
  Is(list[2].trigger.event, "Blizzard Cooldown Manager", "cooldown: event")
  Is(list[3].trigger.type, "cdm", "no source: type")
  Is(list[3].trigger.event, "Blizzard Cooldown Manager", "no source: event")
  Is(list[4].trigger.type, "spell", "other event untouched")
  Is(list[4].trigger.event, "Other", "other event name")
  Is(list[5].trigger.type, "aura2", "other type untouched")
  Is(list[5].trigger.event, "Blizzard Cooldown Manager", "other type event untouched")
  assert(Modernize(nil), "missing triggers tolerated")
  local migrateCalls = 0
  local restoreMigrate = Replace(private, "MigrateCDMCooldownTrigger", function() migrateCalls = migrateCalls + 1 end)
  Modernize({ { trigger = { type = "aura2" } }, { trigger = { type = "spell", event = "Blizzard Cooldown Manager" } } })
  Is(migrateCalls, 2, "cooldown migration called for every trigger")
  restoreMigrate()

  ---------------------------------------------------------------------------------------------------------------
  -- BuffTrigger2: namePattern filter
  ---------------------------------------------------------------------------------------------------------------
  local function Shown(id)
    local region = WeakAuras.GetRegion(id)
    return region ~= nil and region:IsShown()
  end
  local function Shows(names)
    local list = {}
    for id in pairs(patterns) do
      if Shown(id) then list[#list + 1] = id end
    end
    table.sort(list)
    return table.concat(list, ",")
  end
  Is(Shows(), "PatEmpty,PatNoName,PatUnchecked", "name pattern: unset or empty pattern never filters")
  local shout = Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  Is(Shows(), "PatEmpty,PatEqual,PatEqualExplicit,PatFind,PatMatch,PatNoName,PatUnchecked", "name pattern: Battle Shout")
  Units.RemoveAura("player", shout)
  local arcane = Units.ApplyAura("player", { name = "Arcane Intellect", spellId = 1459, duration = 120 })
  test.Environment.Advance(0.5)
  Is(Shows(), "PatEmpty,PatMatchOther,PatNoName,PatUnchecked", "name pattern: Arcane Intellect")
  Units.RemoveAura("player", arcane)
  test.Environment.Advance(0.5)
  Is(Shows(), "PatEmpty,PatNoName,PatUnchecked", "name pattern: no matching aura")
  local quoted = Units.ApplyAura("player", { name = 'He said "hi" [x]%', spellId = 5, duration = 120 })
  test.Environment.Advance(0.5)
  Is(Shows(), "PatEmpty,PatNoName,PatQuoted,PatUnchecked", "name pattern: quoting of special characters")
  local w = Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  local states = WeakAuras.GetTriggerStateForTrigger("Show", 1)
  Is(states[""].active, true, "fallback aura: active state")
  states[""].durationObject = { marker = true }
  Units.RemoveAura("player", w)
  test.Environment.Advance(0.5)
  Is(states[""].active, false, "fallback aura: state became a fallback")
  Is(states[""].durationObject, nil, "fallback state drops the duration object")

  ---------------------------------------------------------------------------------------------------------------
  -- Conditions: generated change code and the secret condition hook
  ---------------------------------------------------------------------------------------------------------------
  local conditionData = WeakAuras.GetData("Anc")
  conditionData.conditions = { { check = { trigger = -1, variable = "alwaystrue", value = 1 },
    changes = { { property = "alpha", value = 0.5 } } } }
  local source
  local restoreLoad = Replace(private, "LoadFunction", function(code) source = code end)
  local secretCalls = {}
  local restoreSecret = Replace(private, "CreateSecretConditionCode", function(...)
    secretCalls[#secretCalls + 1] = { n = select("#", ...), ... }
  end)
  local restoreCurve = Replace(C_CurveUtil, "EvaluateColorValueFromBoolean", function() end)
  local nativeProperty = false
  local restoreNativeProperty = Replace(display, "IsNativeConditionProperty", function() return nativeProperty end)
  local restoreValidate = Replace(display, "ValidateConditions", function() return false end)
  restoreEnabled = Replace(display, "Enabled", function() return native end)
  native = false
  local function Generate()
    source, secretCalls = nil, {}
    private.LoadConditionFunction(conditionData)
    return source
  end
  local function Has(code, fragment, label)
    assert(code and code:find(fragment, 1, true), label .. ": missing " .. fragment)
  end
  local function Lacks(code, fragment, label)
    assert(code and not code:find(fragment, 1, true), label .. ": unexpected " .. fragment)
  end

  local code = Generate()
  Has(code, "region:SetRegionAlpha(propertyChanges['alpha'])", "classic setter")
  Lacks(code, "SetSecretAuraConditionProperty", "classic setter")
  Is(#secretCalls, 1, "non native aura: secret condition hook called once")
  local call = secretCalls[1]
  Is(call.n, 7, "secret condition hook: argument count")
  Is(type(call[1]), "table", "secret condition hook: code buffer")
  Is(call[2], conditionData, "secret condition hook: data")
  Is(type(call[3]), "table", "secret condition hook: properties")
  assert(call[3].alpha, "secret condition hook: properties contain alpha")
  Is(type(call[4]), "table", "secret condition hook: template")
  for index = 5, 7 do Is(type(call[index]), "function", "secret condition hook: helper " .. index) end

  restoreCurve()
  restoreCurve = Replace(C_CurveUtil, "EvaluateColorValueFromBoolean", nil)
  Generate()
  Is(#secretCalls, 0, "no curve API: secret condition hook not called")
  restoreCurve()

  native = true
  nativeProperty = false
  restoreCurve = Replace(C_CurveUtil, "EvaluateColorValueFromBoolean", function() end)
  code = Generate()
  Has(code, "region:SetRegionAlpha(propertyChanges['alpha'])", "native aura, other property")
  Is(#secretCalls, 0, "native aura: secret condition hook not called")
  nativeProperty = true
  code = Generate()
  Has(code, 'Private.ExecEnv.SetSecretAuraConditionProperty(region, "alpha", propertyChanges[\'alpha\'])', "native property")
  Lacks(code, "region:SetRegionAlpha", "native property")
  native = false
  code = Generate()
  Has(code, "region:SetRegionAlpha(propertyChanges['alpha'])", "native property on a non native aura")
  Lacks(code, "SetSecretAuraConditionProperty", "non native aura")
  restoreCurve()
  restoreValidate()
  restoreEnabled()
  restoreNativeProperty()
  restoreSecret()
  restoreLoad()

  ---------------------------------------------------------------------------------------------------------------
  -- Boss mods with BigWigs present (the file is run again with the loader defined)
  ---------------------------------------------------------------------------------------------------------------
  local bossModsPath = test.tocPath:gsub("WeakAuras%.toc$", "BossMods.lua")
  local registered, listeners = {}, {}
  _G.BigWigsLoader = { RegisterMessage = function(listener, event, handler)
    registered[event] = handler
    listeners[#listeners + 1] = listener
  end }
  local ok, message = test.Loader.RunFile(bossModsPath, "WeakAuras", private)
  assert(ok, tostring(message))
  local events = {}
  for event in pairs(registered) do events[#events + 1] = event end
  table.sort(events)
  Is(table.concat(events, ","), "BigWigs_CoreDisabled,BigWigs_CoreEnabled,BigWigs_OnBossDisable,BigWigs_OnBossEnable",
    "BigWigs messages registered")
  for index = 2, #listeners do Is(listeners[index], listeners[1], "one listener object") end
  assert(listeners[1] ~= private and listeners[1] ~= _G, "dedicated listener object")

  local fired = 0
  private.callbacks:RegisterCallback("WA_BIGWIGS_ENCOUNTER_MODULES_CHANGED", function() fired = fired + 1 end)
  registered.BigWigs_OnBossEnable(nil, { engageId = 1 })
  Is(fired, 1, "boss enable with an engage id")
  registered.BigWigs_OnBossDisable(nil, { engageId = 1 })
  Is(fired, 2, "boss disable with an engage id")
  registered.BigWigs_OnBossEnable(nil, {})
  registered.BigWigs_OnBossDisable(nil, {})
  Is(fired, 2, "boss without an engage id is ignored")
  registered.BigWigs_CoreEnabled()
  registered.BigWigs_CoreDisabled()
  Is(fired, 4, "core messages always fire")

  Is(WeakAuras.IsBossModEnabled({ [5] = true }), nil, "BigWigs absent: nil")
  local coreEnabled = true
  local modules = {
    { IsEnabled = function() return false end, engageId = 5 },
    { IsEnabled = function() return true end },
    { IsEnabled = function() return true end, engageId = 6 },
  }
  _G.BigWigs = { IsEnabled = function() return coreEnabled end,
    IterateBossModules = function() return next, modules end }
  Is(WeakAuras.IsBossModEnabled({ [5] = true }), nil, "disabled module")
  Is(WeakAuras.IsBossModEnabled({ [6] = false }), nil, "encounter flag false")
  Is(WeakAuras.IsBossModEnabled({ [7] = true }), nil, "other encounter")
  Is(WeakAuras.IsBossModEnabled({ [6] = true }), true, "enabled module of a listed encounter")
  coreEnabled = false
  Is(WeakAuras.IsBossModEnabled({ [6] = true }), nil, "BigWigs disabled")
  _G.BigWigs = nil
  Is(WeakAuras.IsBossModEnabled({ [6] = true }), nil, "BigWigs object missing")

  _G.BigWigsLoader = nil
  ok, message = test.Loader.RunFile(bossModsPath, "WeakAuras", private)
  assert(ok, tostring(message))
  Is(WeakAuras.IsBossModEnabled({ [6] = true }), nil, "default function after reload")
end

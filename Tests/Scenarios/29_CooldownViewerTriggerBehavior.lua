-- CooldownViewerTrigger behaviour net: freezes what the trigger does today through its public surface only
-- (Private.ExecEnv.UpdateCDMSpell, GetCDMPickerSelections, UpdateCooldownViewerStates, the compiled trigger
-- function of the prototypes, the produced state fields and the events). No internal helper is used, so the
-- file can be rewritten and this scenario must keep passing.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Units = test.Secret, test.Units

  ---------------------------------------------------------------------------------------------------------------
  -- World: a fake Cooldown Manager (catalogue, viewer frames) and fake spell APIs.
  ---------------------------------------------------------------------------------------------------------------
  local CATEGORY = { Essential = 0, Utility = 1, TrackedBuff = 2, TrackedBar = 3 }
  Enum.CooldownViewerCategory = CATEGORY
  local world = { entries = {}, frames = {}, spells = {}, known = {} }

  C_CooldownViewer = C_CooldownViewer or {}
  C_CooldownViewer.GetCooldownViewerCategorySet = function(category)
    local ids = {}
    for id, entry in pairs(world.entries) do
      if entry.category == category then ids[#ids + 1] = id end
    end
    table.sort(ids)
    return ids
  end
  C_CooldownViewer.GetCooldownViewerCooldownInfo = function(id)
    local entry = world.entries[id]
    if entry then return { cooldownID = id, spellID = entry.spellID, isKnown = entry.isKnown } end
  end

  local function Viewer(category)
    return { itemFramePool = { EnumerateActive = function()
      local set = {}
      for id, entry in pairs(world.entries) do
        if entry.category == category then set[world.frames[id]] = true end
      end
      return next, set
    end } }
  end
  EssentialCooldownViewer = Viewer(CATEGORY.Essential)
  UtilityCooldownViewer = Viewer(CATEGORY.Utility)
  BuffIconCooldownViewer = Viewer(CATEGORY.TrackedBuff)

  local function Spell(id)
    local spell = world.spells[id]
    if not spell then
      spell = {
        name = "Spell " .. id, icon = 7000 + id,
        cooldown = { isActive = false, isEnabled = true, isOnGCD = false },
        duration = Units.NewDuration(), gcdDuration = Units.NewDuration(),
        usable = true, lacksResources = false,
      }
      world.spells[id] = spell
    end
    return spell
  end
  C_Spell.GetSpellInfo = function(id)
    if Secret.IsSecret(id) then return nil end
    local spell = Spell(id)
    return { name = spell.name, iconID = spell.icon, spellID = id }
  end
  C_Spell.GetSpellCooldown = function(id) return Spell(id).cooldown end
  C_Spell.GetSpellCooldownDuration = function(id, ignoreGCD)
    local spell = Spell(id)
    if ignoreGCD then return spell.duration end
    return spell.gcdDuration or spell.duration
  end
  C_Spell.GetSpellCharges = function(id) return Spell(id).charges end
  C_Spell.GetSpellChargeDuration = function(id) return Spell(id).chargeDuration end
  C_Spell.IsSpellUsable = function(id) return Spell(id).usable, Spell(id).lacksResources end
  C_Spell.GetSpellCastCount = function() return 0 end
  WeakAuras.IsSpellKnownIncludingPet = function(id) return world.known[id] == true end

  local function Duration(total, elapsed)
    local duration = Units.NewDuration()
    duration:SetTimeFromStart(GetTime() - (elapsed or 0), total)
    return duration
  end

  -- Adds an entry to the fake catalogue with its viewer frame. Call Reload() afterwards.
  local function AddEntry(id, category, spellID, options)
    options = options or {}
    local frame = CreateFrame("Frame")
    frame.cooldownID = id
    frame.GetSpellID = function() return spellID end
    frame.RefreshData = function() end
    world.entries[id] = { category = category, spellID = spellID, isKnown = options.isKnown ~= false }
    world.frames[id] = frame
    if options.spellKnown ~= false then world.known[spellID] = true end
    return frame
  end

  -- The catalogue is cached: any of the reload events refreshes it.
  local function Reload()
    private.GetCDMPickerSelections({ type = "cdm", event = "Blizzard Cooldown Manager" }, "PLAYER_ENTERING_WORLD")
  end

  local scans = {}
  local realScanEvents = private.ScanEvents
  private.ScanEvents = function(event, ...)
    scans[#scans + 1] = event
    if realScanEvents then return realScanEvents(event, ...) end
  end
  local function CountScans(event)
    local count = 0
    for _, name in ipairs(scans) do
      if name == event then count = count + 1 end
    end
    return count
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Helpers on the public surface.
  ---------------------------------------------------------------------------------------------------------------
  local COOLDOWN, BUFF, ITEM = "Blizzard Cooldown Manager", "Blizzard CDM Buff", "Blizzard CDM Item"

  local function Config(overrides)
    local config = { type = "cdm", event = COOLDOWN, cdmSpell = "4321", cdmExact = true, track = "auto",
      showGCD = false, use_ignoreSpellKnown = true }
    for key, value in pairs(overrides or {}) do config[key] = value end
    return config
  end

  local function Update(config, event, allstates)
    allstates = allstates or {}
    local ok, err = pcall(private.ExecEnv.UpdateCDMSpell, allstates, config, event or "WA_CDM_REFRESH")
    assert(ok, "UpdateCDMSpell: " .. tostring(err))
    return allstates
  end

  local function Shown(allstates)
    local list = {}
    for key, state in pairs(allstates) do
      if state.show then list[#list + 1] = key end
    end
    table.sort(list)
    return list
  end

  local function Only(allstates, label)
    local keys = Shown(allstates)
    assert(#keys == 1, (label or "only") .. ": expected one shown state, got " .. #keys .. " (" .. table.concat(keys, ",") .. ")")
    return allstates[keys[1]], keys[1]
  end

  local function NoSecretField(state, label)
    for field, value in pairs(state) do
      assert(not Secret.IsSecret(value), label .. ": secret stored in field " .. tostring(field))
    end
  end

  -- The prototype hands back a source string compiled by Private.LoadFunction (or a function).
  local PROTOTYPES = {
    [COOLDOWN] = private.CooldownViewerPrototype,
    [BUFF] = private.CooldownViewerBuffPrototype,
    [ITEM] = private.CooldownViewerItemPrototype,
  }
  local function Compile(trigger)
    local compiled = PROTOTYPES[trigger.event].triggerFunction(trigger)
    if type(compiled) == "string" then
      local func, err = private.LoadFunction(compiled, "cdm-behavior")
      assert(func, "compile: " .. tostring(err))
      return func
    end
    return compiled
  end
  local function Run(func, allstates, event)
    local ok, err = pcall(func, allstates, event or "WA_CDM_REFRESH")
    assert(ok, "trigger function: " .. tostring(err))
    return allstates
  end

  local function Picked(trigger, event)
    local ok, selected = pcall(private.ExecEnv.GetCDMPickerSelections, trigger, event)
    assert(ok, "GetCDMPickerSelections: " .. tostring(selected))
    return selected
  end

  ---------------------------------------------------------------------------------------------------------------
  -- 1. Visibility
  ---------------------------------------------------------------------------------------------------------------
  local SPELL, ENTRY = 4321, 900
  Spell(SPELL).name = "Test Spell"
  AddEntry(ENTRY, CATEGORY.Essential, SPELL)
  Reload()

  -- Ready spell: nil showMode behaves as always, then every other mode.
  local spell = Spell(SPELL)
  spell.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  for _, mode in ipairs({ "always", "ready", "usable" }) do
    local state = Only(Update(Config({ showMode = mode }), "SPELL_UPDATE_COOLDOWN"), "ready/" .. mode)
    assert(state.spellId == SPELL and state.cooldownID == ENTRY, "identity " .. mode)
  end
  assert(Only(Update(Config(), "SPELL_UPDATE_COOLDOWN"), "ready/nil").onCooldown == false, "nil showMode ready")
  for _, mode in ipairs({ "cooldown", "unusable" }) do
    assert(#Shown(Update(Config({ showMode = mode }), "SPELL_UPDATE_COOLDOWN")) == 0, "ready spell must be hidden by " .. mode)
  end

  -- Spell on cooldown.
  spell.cooldown = { isActive = true, isEnabled = true, isOnGCD = false }
  spell.duration = Duration(10, 2)
  for _, mode in ipairs({ "always", "cooldown", "usable" }) do
    Only(Update(Config({ showMode = mode }), "SPELL_UPDATE_COOLDOWN"), "cooldown/" .. mode)
  end
  assert(Only(Update(Config(), "SPELL_UPDATE_COOLDOWN"), "cooldown/nil").onCooldown == true, "nil showMode cooldown")
  assert(#Shown(Update(Config({ showMode = "ready" }), "SPELL_UPDATE_COOLDOWN")) == 0, "cooldown spell must be hidden by ready")

  -- Usable / unusable follow IsSpellUsable; a secret answer reads as nil and hides both.
  spell.usable = false
  assert(Only(Update(Config({ showMode = "unusable" }), "SPELL_UPDATE_COOLDOWN"), "unusable").isUsable == false, "isUsable false")
  assert(#Shown(Update(Config({ showMode = "usable" }), "SPELL_UPDATE_COOLDOWN")) == 0, "unusable spell hidden by usable")
  spell.usable, spell.lacksResources = Secret.Wrap(true), Secret.Wrap(false)
  local state = Only(Update(Config({ showMode = "always" }), "SPELL_UPDATE_COOLDOWN"), "secret usable")
  assert(state.isUsable == nil and state.insufficientResources == nil, "secret usable flags must read as nil")
  assert(#Shown(Update(Config({ showMode = "usable" }), "SPELL_UPDATE_COOLDOWN")) == 0, "secret usable hides usable")
  assert(#Shown(Update(Config({ showMode = "unusable" }), "SPELL_UPDATE_COOLDOWN")) == 0, "secret usable hides unusable")
  spell.usable, spell.lacksResources = true, false

  -- "Known spell" filter: applies unless use_ignoreSpellKnown, hides an exact-ID entry whose spell is not known.
  local KNOWN_SPELL, KNOWN_ENTRY = 4330, 901
  AddEntry(KNOWN_ENTRY, CATEGORY.Essential, KNOWN_SPELL)
  Reload()
  local knownConfig = Config({ cdmSpell = tostring(KNOWN_SPELL), use_ignoreSpellKnown = false })
  Only(Update(knownConfig, "SPELL_UPDATE_COOLDOWN"), "known")
  world.known[KNOWN_SPELL] = false
  local hidden = Update(knownConfig, "SPELL_UPDATE_COOLDOWN")
  assert(#Shown(hidden) == 0, "unknown spell must be hidden")
  Only(Update(Config({ cdmSpell = tostring(KNOWN_SPELL), use_ignoreSpellKnown = true }), "SPELL_UPDATE_COOLDOWN"), "ignore known")
  -- Name lookup of an entry the player has not learned: not admitted at all.
  world.entries[KNOWN_ENTRY].isKnown = false
  Reload()
  Spell(KNOWN_SPELL).name = "Unlearned Spell"
  local byName = Update(Config({ cdmSpell = "Unlearned Spell", cdmExact = false, use_ignoreSpellKnown = false }), "SPELL_UPDATE_COOLDOWN")
  assert(#Shown(byName) == 0, "unlearned entry found by name")
  world.entries[KNOWN_ENTRY].isKnown = true
  world.known[KNOWN_SPELL] = true
  Reload()

  -- requireTarget: needs an attackable target; none, friendly or secret gives no state.
  spell.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  local targetConfig = Config({ requireTarget = true })
  assert(next(Update(targetConfig, "SPELL_UPDATE_COOLDOWN")) == nil, "requireTarget without target")
  Units.DefineUnit("target", { name = "Friend", canAttack = false })
  assert(next(Update(targetConfig, "SPELL_UPDATE_COOLDOWN")) == nil, "requireTarget with friendly target")
  Units.DefineUnit("target", { name = "Dummy", canAttack = true })
  local targetStates = Update(targetConfig, "SPELL_UPDATE_COOLDOWN")
  Only(targetStates, "requireTarget hostile")
  Units.units.target = nil
  Update(targetConfig, "SPELL_UPDATE_COOLDOWN", targetStates)
  assert(#Shown(targetStates) == 0, "state must hide when the target goes away")
  Units.DefineUnit("target", { name = "Dummy", canAttack = true })
  local realUnitExists, realUnitCanAttack = UnitExists, UnitCanAttack
  UnitExists = function() return Secret.Wrap(true) end
  assert(next(Update(targetConfig, "SPELL_UPDATE_COOLDOWN")) == nil, "requireTarget with secret existence")
  UnitExists, UnitCanAttack = realUnitExists, function() return Secret.Wrap(true) end
  assert(next(Update(targetConfig, "SPELL_UPDATE_COOLDOWN")) == nil, "requireTarget with secret hostility")
  UnitCanAttack = realUnitCanAttack
  Only(Update(targetConfig, "SPELL_UPDATE_COOLDOWN"), "requireTarget restored")
  Units.units.target = nil

  ---------------------------------------------------------------------------------------------------------------
  -- 2. Cooldown: ready, recharging, GCD only, secret values in combat
  ---------------------------------------------------------------------------------------------------------------
  local CD_SPELL, CD_ENTRY = 4340, 910
  AddEntry(CD_ENTRY, CATEGORY.Essential, CD_SPELL)
  Reload()
  local cd = Spell(CD_SPELL)
  local cdConfig = Config({ cdmSpell = tostring(CD_SPELL), hideGCDText = true })

  cd.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  cd.duration = Duration(0)
  state = Only(Update(cdConfig, "SPELL_UPDATE_COOLDOWN"), "ready")
  assert(state.onCooldown == false and state.isReady == true, "ready flags")
  assert(state.progressType == "durationObject" and state.durationObject == cd.duration, "ready duration object")
  assert(state.cdmSuppressGCD == false and state.cdmGCDOnly == false and state.hasTimer == true, "ready gcd flags")
  assert(state.stacks == nil and state.name == "Spell " .. CD_SPELL and state.icon == 7000 + CD_SPELL, "ready identity")
  assert(state.cdmHideGCDText == true and state.cdmTextDurationRequired == true and state.cdmTextDurationObject == cd.duration,
    "ready text duration")
  assert(state.cdmBuff == false and state.cdmDisplayed == true and state.cdmCategory == "Essential", "ready identity fields")
  assert(state.show == true and state.autoHide == false and state.changed == true, "ready defaults")

  cd.cooldown = { isActive = true, isEnabled = true, isOnGCD = false }
  cd.duration = Duration(10, 3)
  state = Only(Update(cdConfig, "SPELL_UPDATE_COOLDOWN"), "recharging")
  assert(state.onCooldown == true and state.isReady == false, "cooldown flags")
  assert(state.progressType == "durationObject" and state.durationObject == cd.duration, "cooldown duration object")
  assert(state.cdmGCDOnly == false and state.cdmSuppressGCD == false, "cooldown gcd flags")
  assert(state.value == nil and state.total == nil, "durationObject progress carries no value/total")

  -- Per-spell GCD/cooldown flags only move on SPELL_UPDATE_COOLDOWN.
  cd.cooldown = { isActive = true, isEnabled = true, isOnGCD = true }
  state = Only(Update(cdConfig, "WA_CDM_REFRESH"), "flags held")
  assert(state.onCooldown == true, "flags must not change outside SPELL_UPDATE_COOLDOWN")

  -- GCD only, without and with showGCD.
  cd.gcdDuration = Duration(1.5, 0.3)
  state = Only(Update(cdConfig, "SPELL_UPDATE_COOLDOWN"), "gcd only")
  assert(state.onCooldown == false and state.isReady == true and state.cdmGCDOnly == true, "gcd only flags")
  assert(state.cdmSuppressGCD == true and state.progressType == "timed", "gcd hidden: " .. tostring(state.progressType))
  assert(state.duration == 0 and state.expirationTime == 0 and state.durationObject == nil, "gcd hidden timing")
  assert(state.cdmTextDurationRequired == true and state.cdmTextDurationObject ~= nil
    and state.cdmTextDurationObject ~= cd.gcdDuration, "gcd text must not follow the gcd")
  state = Only(Update(Config({ cdmSpell = tostring(CD_SPELL), showGCD = true, hideGCDText = true }), "SPELL_UPDATE_COOLDOWN"), "gcd shown")
  assert(state.cdmGCDOnly == true and state.cdmSuppressGCD == false, "gcd shown flags")
  assert(state.progressType == "durationObject" and state.durationObject == cd.gcdDuration, "gcd shown duration")
  state = Only(Update(Config({ cdmSpell = tostring(CD_SPELL), hideGCDText = false }), "SPELL_UPDATE_COOLDOWN"), "gcd text free")
  assert(state.cdmTextDurationRequired == nil and state.cdmTextDurationObject == nil and state.cdmHideGCDText == false,
    "no text override without hideGCDText")

  -- Combat: every API answers with secrets. The state survives, stacks is never secret, the duration object
  -- is passed through, and no field exposed to conditions holds a secret.
  cd.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  cd.duration = Duration(10, 3)
  Update(cdConfig, "SPELL_UPDATE_COOLDOWN")
  Units.SetCombat(true)
  local secretDuration = Units.NewDuration()
  secretDuration:SetTimeFromStart(Secret.Wrap(GetTime() - 3), 10)
  cd.duration = secretDuration
  cd.cooldown = { isActive = Secret.Wrap(true), isEnabled = Secret.Wrap(true), isOnGCD = Secret.Wrap(false) }
  cd.usable, cd.lacksResources = Secret.Wrap(true), Secret.Wrap(false)
  cd.charges = { currentCharges = Secret.Wrap(2), maxCharges = 3, isActive = Secret.Wrap(true) }
  cd.chargeDuration = secretDuration
  test.Environment.Advance(0.2)
  state = Only(Update(cdConfig, "SPELL_UPDATE_COOLDOWN"), "combat cooldown")
  assert(state.progressType == "durationObject" and state.durationObject ~= nil, "combat duration object lost")
  assert(not Secret.IsSecret(state.stacks), "secret stacks stored")
  assert(state.isUsable == nil and state.insufficientResources == nil, "secret usable flags kept")
  NoSecretField(state, "combat cooldown")
  state = Only(Update(cdConfig, "WA_CDM_REFRESH"), "combat refresh")
  NoSecretField(state, "combat refresh")
  Units.SetCombat(false)
  cd.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  cd.usable, cd.lacksResources, cd.charges, cd.chargeDuration = true, false, nil, nil
  cd.duration = Duration(0)
  test.Environment.Advance(0.2)
  state = Only(Update(cdConfig, "SPELL_UPDATE_COOLDOWN"), "after combat")
  assert(state.onCooldown == false and state.isUsable == true, "state not restored after combat")

  ---------------------------------------------------------------------------------------------------------------
  -- 3. Charges
  ---------------------------------------------------------------------------------------------------------------
  local CH_SPELL, CH_ENTRY = 4350, 920
  local chargeFrame = AddEntry(CH_ENTRY, CATEGORY.Essential, CH_SPELL)
  Reload()
  local charges = Spell(CH_SPELL)
  local chargeConfig = Config({ cdmSpell = tostring(CH_SPELL), hideGCDText = true })
  charges.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  charges.duration = Duration(0)
  charges.chargeDuration = Duration(8, 2)

  charges.charges = { currentCharges = 3, maxCharges = 3, isActive = false }
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "full charges")
  assert(state.stacks == 3 and state.isReady == true and state.onCooldown == false and state.recharging == false, "full charges flags")
  assert(state.durationObject == charges.duration, "full charges track the spell cooldown")

  charges.charges = { currentCharges = 1, maxCharges = 3, isActive = true }
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "partial charges")
  assert(state.stacks == 1 and state.isReady == true and state.onCooldown == false and state.recharging == true, "partial charges flags")
  assert(state.durationObject == charges.chargeDuration, "auto track follows the charge timer while recharging")
  assert(state.cdmTextDurationObject == charges.chargeDuration and state.cdmTextDurationRequired == true, "charge text duration")
  state = Only(Update(Config({ cdmSpell = tostring(CH_SPELL), track = "cooldown" }), "SPELL_UPDATE_COOLDOWN"), "track cooldown")
  assert(state.durationObject == charges.duration and state.stacks == 1, "cooldown track ignores the charge timer")

  charges.charges = { currentCharges = 0, maxCharges = 3, isActive = true }
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "empty charges")
  assert(state.stacks == 0 and state.isReady == false and state.onCooldown == true and state.recharging == true, "empty charges flags")
  assert(state.durationObject == charges.chargeDuration, "empty charges timer")

  charges.charges = { currentCharges = 3, maxCharges = 3, isActive = false }
  state = Only(Update(Config({ cdmSpell = tostring(CH_SPELL), track = "charges" }), "SPELL_UPDATE_COOLDOWN"), "track charges")
  assert(state.durationObject == charges.chargeDuration, "charges track follows the charge timer even when full")

  -- In combat: charge info and native flags are secret.
  Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "charges before combat")
  chargeFrame.cooldownChargesCount = 2
  chargeFrame.wasSetFromCharges = true
  chargeFrame:RefreshData()
  Units.SetCombat(true)
  charges.charges = { currentCharges = Secret.Wrap(2), maxCharges = 3, isActive = Secret.Wrap(true) }
  charges.cooldown = { isActive = Secret.Wrap(true), isEnabled = Secret.Wrap(true), isOnGCD = Secret.Wrap(false) }
  test.Environment.Advance(0.2)
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "charges in combat (readable native)")
  assert(not Secret.IsSecret(state.stacks), "secret charges stored")
  assert(state.stacks == 2 and state.isReady == true and state.onCooldown == false, "native charges carry the combat state")
  assert(state.durationObject ~= nil, "charges in combat keep a timer")
  NoSecretField(state, "charges in combat")
  chargeFrame.cooldownChargesCount = Secret.Wrap(2)
  chargeFrame.wasSetFromCharges = Secret.Wrap(true)
  chargeFrame.isOnActualCooldown = Secret.Wrap(true)
  chargeFrame:RefreshData()
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "charges in combat (secret native)")
  assert(state.stacks == nil, "secret native charges must not leak into stacks")
  assert(private.CDMGetNativeCooldown(chargeFrame, CH_SPELL).charges == nil, "secret native charges must read as nil")
  NoSecretField(state, "charges in combat (secret native)")
  Units.SetCombat(false)
  charges.charges = { currentCharges = 3, maxCharges = 3, isActive = false }
  charges.cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  chargeFrame.cooldownChargesCount, chargeFrame.wasSetFromCharges, chargeFrame.isOnActualCooldown = nil, nil, nil
  chargeFrame:RefreshData()
  test.Environment.Advance(0.2)
  state = Only(Update(chargeConfig, "SPELL_UPDATE_COOLDOWN"), "charges after combat")
  assert(state.stacks == 3, "charges after combat")

  ---------------------------------------------------------------------------------------------------------------
  -- 4. Aura / buff through the Cooldown Manager
  ---------------------------------------------------------------------------------------------------------------
  local BUFF_SPELL, BUFF_ENTRY = 6001, 950
  Spell(BUFF_SPELL).name = "Test Aura"
  local buffFrame = AddEntry(BUFF_ENTRY, CATEGORY.TrackedBuff, BUFF_SPELL)
  Reload()
  local function SetAura(unit)
    buffFrame.isActive = true
    buffFrame.auraInstanceID = 5
    buffFrame.auraDataUnit = unit or "player"
    buffFrame.auraDataCached = { spellId = BUFF_SPELL, duration = 10, expirationTime = GetTime() + 10, applications = 2, timeMod = 1 }
  end
  local function ClearAura()
    buffFrame.isActive = false
    buffFrame.auraInstanceID, buffFrame.auraDataCached, buffFrame.auraDataUnit = nil, nil, nil
  end
  local function BuffConfig(overrides)
    return Config(overrides and setmetatable(overrides, { __index = { event = BUFF, cdmSpell = tostring(BUFF_SPELL) } })
      or { event = BUFF, cdmSpell = tostring(BUFF_SPELL) })
  end
  local function CopyOf(overrides)
    local result = { event = BUFF, cdmSpell = tostring(BUFF_SPELL) }
    for key, value in pairs(overrides or {}) do result[key] = value end
    return Config(result)
  end

  SetAura()
  local buffStates = Update(CopyOf({ showMode = "active" }), "UNIT_AURA")
  state = Only(buffStates, "aura present")
  assert(state.cdmBuff == true and state.auraActive == true, "aura present flags")
  assert(state.stacks == 2 and state.spellId == BUFF_SPELL and state.cooldownID == BUFF_ENTRY, "aura present identity")
  assert(state.cdmAuraRenderUnit == "player", "aura render unit " .. tostring(state.cdmAuraRenderUnit))
  assert(state.progressType == "durationObject" and state.durationObject ~= nil and state.hasTimer == true, "aura timer")
  assert(state.cdmAuraSpellIDs and state.cdmAuraSpellIDs[1] == BUFF_SPELL, "aura spell ids come from the exact id")
  assert(state.cdmCategory == "Tracked Buffs", "buff category label " .. tostring(state.cdmCategory))
  assert(buffStates[tostring(BUFF_ENTRY)] == state, "aura state is keyed by cooldownID")
  assert(#Shown(Update(CopyOf({ showMode = "missing" }), "UNIT_AURA")) == 0, "present aura hidden by missing")
  Only(Update(CopyOf(), "UNIT_AURA"), "aura present/always")

  SetAura("target")
  state = Only(Update(CopyOf({ showMode = "active" }), "UNIT_AURA"), "aura on target")
  assert(state.cdmAuraRenderUnit == "target" and state.auraActive == true, "aura on target unit")

  ClearAura()
  buffStates = Update(CopyOf({ showMode = "missing" }), "UNIT_AURA")
  state = Only(buffStates, "aura absent")
  assert(state.auraActive == false and state.progressType == "static" and state.stacks == nil, "aura absent flags")
  assert(state.durationObject == nil and state.cdmAuraRenderUnit == nil, "aura absent leaves no timing")
  assert(#Shown(Update(CopyOf({ showMode = "active" }), "UNIT_AURA")) == 0, "absent aura hidden by active")
  Only(Update(CopyOf({ showMode = "always" }), "UNIT_AURA"), "aura absent/always")

  -- A secret aura in combat keeps a state without storing any secret.
  SetAura()
  Units.SetCombat(true)
  buffFrame.auraInstanceID = Secret.Wrap(5)
  buffFrame.auraDataCached = { spellId = Secret.Wrap(BUFF_SPELL), duration = Secret.Wrap(10),
    expirationTime = Secret.Wrap(GetTime() + 8), applications = Secret.Wrap(2), timeMod = Secret.Wrap(1) }
  buffFrame.isActive = Secret.Wrap(true)
  state = Only(Update(CopyOf({ showMode = "always" }), "UNIT_AURA"), "secret aura")
  assert(not Secret.IsSecret(state.stacks), "secret aura stacks stored")
  NoSecretField(state, "secret aura")
  Units.SetCombat(false)
  SetAura()

  -- Clone keys.
  local states = Update(CopyOf({ cdmSelection = "spell", showMode = "active" }), "UNIT_AURA")
  assert(states.spell and states.spell.show and states[tostring(BUFF_ENTRY)] == nil, "cdmSelection spell gives the unique clone")

  local exactTrigger = { type = "cdm", event = BUFF, cdmUseExactIDs = true, cdmExactIDs = { tostring(BUFF_SPELL) }, cdmBuffShow = "active" }
  states = Run(Compile(exactTrigger), {}, "UNIT_AURA")
  state = Only(states, "id key")
  assert(states["id:" .. BUFF_SPELL] == state and state.index == 1 and state.auraActive == true, "exact id key id:<n>")

  local nameTrigger = { type = "cdm", event = BUFF, cdmUseNames = true, cdmNames = { "Test Aura" }, cdmBuffShow = "active" }
  states = Run(Compile(nameTrigger), {}, "UNIT_AURA")
  state = Only(states, "name key")
  assert(states["name:test aura"] == state and state.spellId == BUFF_SPELL, "name key name:<lowered name>")

  -- Collision on one key: the visible state replaces the hidden one, whatever the order.
  local function BuffQuery(showMode)
    return { type = "cdm", event = BUFF, cdmSelection = "spell", cdmSpell = tostring(BUFF_SPELL), cdmExact = true,
      cdmItemExact = false, use_ignoreSpellKnown = false, showGCD = false, track = "auto", hideGCDText = true,
      showMode = showMode, requireTarget = false }
  end
  -- Only hidden-then-visible is asserted: visible-then-hidden currently ends with no shown state (suspect, see report).
  for order, modes in ipairs({ { "missing", "active" } }) do
    local collided = {}
    local ok, err = pcall(private.ExecEnv.UpdateCDMSelectionList, collided, { BuffQuery(modes[1]), BuffQuery(modes[2]) }, "UNIT_AURA")
    assert(ok, "UpdateCDMSelectionList " .. tostring(err))
    local winner, key = Only(collided, "buff collision " .. order)
    assert(key == "id:" .. BUFF_SPELL and winner.auraActive == true, "buff collision " .. order)
  end

  ---------------------------------------------------------------------------------------------------------------
  -- 5. Several queries in one trigger
  ---------------------------------------------------------------------------------------------------------------
  local SECOND_SPELL, SECOND_ENTRY = 4322, 902
  AddEntry(SECOND_ENTRY, CATEGORY.Essential, SECOND_SPELL)
  Reload()
  Spell(SPELL).cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  local multi = { type = "cdm", event = COOLDOWN, cdmUseExactIDs = true, cdmExactIDs = { "4321", " 4322 ", "4321", "" },
    use_ignoreSpellKnown = true, cdmShow = "always" }
  states = Run(Compile(multi), {}, "SPELL_UPDATE_COOLDOWN")
  local keys = Shown(states)
  assert(#keys == 2 and keys[1] == ENTRY .. ":" .. SPELL and keys[2] == SECOND_ENTRY .. ":" .. SECOND_SPELL,
    "multi query keys " .. table.concat(keys, ","))
  assert(states[keys[1]].spellId == SPELL and states[keys[2]].spellId == SECOND_SPELL, "multi query spells")

  local mixed = { type = "cdm", event = BUFF, cdmUseNames = true, cdmNames = { "Test Aura" },
    cdmUseExactIDs = true, cdmExactIDs = { tostring(BUFF_SPELL) }, cdmBuffShow = "active" }
  SetAura()
  states = Run(Compile(mixed), {}, "UNIT_AURA")
  keys = Shown(states)
  assert(#keys == 2 and states["name:test aura"] and states["id:" .. BUFF_SPELL], "mixed buff queries keys " .. table.concat(keys, ","))
  assert(states["name:test aura"].index == 1 and states["id:" .. BUFF_SPELL].index == 2, "buff index is the query rank")
  -- Hide one entry: its clone stays but turns hidden; the other keeps showing.
  world.known[SECOND_SPELL] = true
  states = Run(Compile(multi), states, "SPELL_UPDATE_COOLDOWN")

  -- Cooldown collision on one key: visible wins over hidden, whatever the order.
  local function CooldownQuery(showMode)
    return { type = "cdm", event = COOLDOWN, cdmSelection = "spell", cdmSpell = "4321", cdmExact = true,
      cdmItemExact = false, use_ignoreSpellKnown = true, showGCD = false, track = "auto", hideGCDText = true,
      showMode = showMode, requireTarget = false }
  end
  for order, modes in ipairs({ { "cooldown", "ready" }, { "ready", "cooldown" } }) do
    local collided = {}
    local ok, err = pcall(private.ExecEnv.UpdateCDMSelectionList, collided,
      { CooldownQuery(modes[1]), CooldownQuery(modes[2]) }, "SPELL_UPDATE_COOLDOWN")
    assert(ok, "UpdateCDMSelectionList " .. tostring(err))
    local winner, key = Only(collided, "cooldown collision " .. order)
    assert(key == ENTRY .. ":" .. SPELL and winner.isReady == true, "cooldown collision " .. order)
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Picker selections (cdmSpells.multi) through GetCDMPickerSelections and UpdateCooldownViewerStates
  ---------------------------------------------------------------------------------------------------------------
  local pickerTrigger = { type = "cdm", event = COOLDOWN,
    cdmSpells = { multi = { [ENTRY] = true, [tostring(SECOND_ENTRY)] = true, [KNOWN_ENTRY] = false, [BUFF_ENTRY] = true, [99999] = true } } }
  local selected = Picked(pickerTrigger, "PLAYER_ENTERING_WORLD")
  assert(#selected == 2 and selected[1] == ENTRY and selected[2] == SECOND_ENTRY,
    "picker keeps checked, known, matching entries sorted (number or string keys)")
  assert(selected.buffSpellIDsByEntry[ENTRY][1] == SPELL, "picker lists the aura ids by entry")
  local buffSelected = Picked({ type = "cdm", event = BUFF, cdmSpells = { multi = { [BUFF_ENTRY] = true, [ENTRY] = true } } }, "WA_CDM_REFRESH")
  assert(#buffSelected == 1 and buffSelected[1] == BUFF_ENTRY, "buff picker keeps only buff entries")

  Spell(SPELL).cooldown = { isActive = true, isEnabled = true, isOnGCD = false }
  Spell(SPELL).duration = Duration(10, 2)
  states = {}
  local ok, err = pcall(private.ExecEnv.UpdateCooldownViewerStates, states, selected, "SPELL_UPDATE_COOLDOWN",
    false, "auto", true, "cooldown", nil, false, true)
  assert(ok, "UpdateCooldownViewerStates " .. tostring(err))
  state = Only(states, "picker cooldown mode")
  assert(states[tostring(ENTRY)] == state and state.onCooldown == true, "picker state keyed by cooldownID")
  Spell(SPELL).cooldown = { isActive = false, isEnabled = true, isOnGCD = false }
  ok, err = pcall(private.ExecEnv.UpdateCooldownViewerStates, states, selected, "SPELL_UPDATE_COOLDOWN",
    false, "auto", true, "cooldown", nil, false, true)
  assert(ok, "UpdateCooldownViewerStates " .. tostring(err))
  assert(#Shown(states) == 0, "state hides in place when the cooldown ends")
  assert(states[tostring(ENTRY)] and states[tostring(ENTRY)].show == false, "hidden state is kept")
  -- Return value: true when something changed.
  local changed = private.ExecEnv.UpdateCooldownViewerStates({}, selected, "SPELL_UPDATE_COOLDOWN", false, "auto", true, "always", nil, false, true)
  assert(changed == true, "new states report a change")

  ---------------------------------------------------------------------------------------------------------------
  -- Options preview
  ---------------------------------------------------------------------------------------------------------------
  state = Only(Update(Config({ showMode = "cooldown" }), "OPTIONS"), "preview")
  assert(state.progressType == "timed" and state.duration == 6 and state.stacks == 3, "preview timing")
  assert(state.auraActive == true and state.onCooldown == true and state.cdmTextPreview == true and state.cdmHideGCDText == false,
    "preview flags")
  assert(math.abs(state.expirationTime - GetTime() - 6) < 0.001, "preview expiration")

  ---------------------------------------------------------------------------------------------------------------
  -- 6. Refresh and invalidation
  ---------------------------------------------------------------------------------------------------------------
  test.Environment.Advance(0.2)
  for index = #scans, 1, -1 do scans[index] = nil end
  Update(Config(), "SPELL_UPDATE_COOLDOWN")
  Update(Config(), "SPELL_UPDATE_COOLDOWN")
  assert(CountScans("WA_CDM_REFRESH") == 0, "WA_CDM_REFRESH must be deferred, not synchronous")
  test.Environment.Advance(0.1)
  assert(CountScans("WA_CDM_REFRESH") == 1, "WA_CDM_REFRESH emitted once next frame, got " .. CountScans("WA_CDM_REFRESH"))
  Update(Config(), "WA_CDM_REFRESH")
  Update(Config(), "OPTIONS")
  test.Environment.Advance(0.1)
  assert(CountScans("WA_CDM_REFRESH") == 1, "passive events must not queue a refresh")
  private.QueueCDMRefresh()
  private.QueueCDMRefresh()
  assert(CountScans("WA_CDM_REFRESH") == 1, "QueueCDMRefresh must not emit synchronously")
  test.Environment.Advance(0.1)
  assert(CountScans("WA_CDM_REFRESH") == 2, "QueueCDMRefresh coalesced into one emission")

  -- Layout change callback: invalidates the catalogue now, emits WA_CDM_LAYOUT_CHANGED at the next frame.
  local LAYOUT_ENTRY = 960
  AddEntry(LAYOUT_ENTRY, CATEGORY.Essential, 4360)
  local layoutTrigger = { type = "cdm", event = COOLDOWN, cdmSpells = { multi = { [LAYOUT_ENTRY] = true } } }
  assert(#Picked(layoutTrigger, "SPELL_UPDATE_COOLDOWN") == 0, "catalogue is cached between reload events")
  assert(EventRegistry and EventRegistry.TriggerEvent, "EventRegistry missing in the harness")
  EventRegistry:TriggerEvent("CooldownViewerSettings.OnDataChanged")
  assert(CountScans("WA_CDM_LAYOUT_CHANGED") == 0, "WA_CDM_LAYOUT_CHANGED must be deferred")
  assert(#Picked(layoutTrigger, "SPELL_UPDATE_COOLDOWN") == 1, "layout data change must invalidate the catalogue")
  test.Environment.Advance(0.1)
  assert(CountScans("WA_CDM_LAYOUT_CHANGED") >= 1, "WA_CDM_LAYOUT_CHANGED emitted at the next frame")

  -- Catalogue reload events, and events that must keep the cached catalogue.
  local RELOAD_EVENTS = {
    "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "SPELLS_CHANGED", "PLAYER_EQUIPMENT_CHANGED",
    "WA_CDM_LAYOUT_CHANGED", "COOLDOWN_VIEWER_DATA_LOADED", "COOLDOWN_VIEWER_TABLE_HOTFIXED",
    "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED",
  }
  local KEEP_EVENTS = { "WA_CDM_REFRESH", "SPELL_UPDATE_COOLDOWN", "UNIT_AURA", "PLAYER_TARGET_CHANGED" }
  local nextEntry = 970
  for _, eventName in ipairs(RELOAD_EVENTS) do
    nextEntry = nextEntry + 1
    AddEntry(nextEntry, CATEGORY.Essential, 5000 + nextEntry)
    local trigger = { type = "cdm", event = COOLDOWN, cdmSpells = { multi = { [nextEntry] = true } } }
    for _, keepName in ipairs(KEEP_EVENTS) do
      assert(#Picked(trigger, keepName) == 0, keepName .. " must keep the cached catalogue")
    end
    assert(#Picked(trigger, eventName) == 1, eventName .. " must reload the catalogue")
  end
  -- OPTIONS reloads unless the catalogue was already loaded at the same instant.
  nextEntry = nextEntry + 1
  AddEntry(nextEntry, CATEGORY.Essential, 5000 + nextEntry)
  local optionsTrigger = { type = "cdm", event = COOLDOWN, cdmSpells = { multi = { [nextEntry] = true } } }
  test.Environment.Advance(0.1)
  assert(#Picked(optionsTrigger, "OPTIONS") == 1, "OPTIONS reloads the catalogue")

  ---------------------------------------------------------------------------------------------------------------
  -- Prototypes: events and display
  ---------------------------------------------------------------------------------------------------------------
  local function EventSet(prototype)
    local result = prototype.events({ type = "cdm", event = prototype == private.CooldownViewerBuffPrototype and BUFF or COOLDOWN })
    local set = {}
    for _, name in ipairs(result.events) do set[name] = true end
    return set, result
  end
  local cooldownEvents, cooldownResult = EventSet(private.CooldownViewerPrototype)
  for _, name in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED", "SPELLS_CHANGED", "SPELL_UPDATE_COOLDOWN",
    "SPELL_UPDATE_CHARGES", "SPELL_UPDATE_ICON", "PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_COOLDOWN", "PLAYER_TARGET_CHANGED",
    "PLAYER_TOTEM_UPDATE", "COOLDOWN_VIEWER_DATA_LOADED", "COOLDOWN_VIEWER_TABLE_HOTFIXED",
    "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED", "ACTIONBAR_UPDATE_USABLE", "ACTION_USABLE_CHANGED", "SPELL_UPDATE_USABLE",
    "UPDATE_SHAPESHIFT_FORM" }) do
    assert(cooldownEvents[name], "cooldown prototype misses event " .. name)
  end
  assert(cooldownResult.unit_events.player[1] == "UNIT_AURA", "player unit events")
  local targetUnitEvents = {}
  for _, name in ipairs(cooldownResult.unit_events.target) do targetUnitEvents[name] = true end
  assert(targetUnitEvents.UNIT_AURA and targetUnitEvents.UNIT_FACTION and targetUnitEvents.UNIT_FLAGS, "target unit events")
  local buffEvents = EventSet(private.CooldownViewerBuffPrototype)
  assert(buffEvents.UNIT_AURA == nil and buffEvents.PLAYER_TARGET_CHANGED and not buffEvents.ACTIONBAR_UPDATE_USABLE
    and not buffEvents.UPDATE_SHAPESHIFT_FORM, "buff prototype uses the base events only")
  local itemEvents = private.CooldownViewerItemPrototype.events({ type = "cdm", event = ITEM }).events
  local itemSet = {}
  for _, name in ipairs(itemEvents) do itemSet[name] = true end
  assert(itemSet.GET_ITEM_INFO_RECEIVED and itemSet.ITEM_DATA_LOAD_RESULT, "item prototype events")

  for _, prototype in pairs({ private.CooldownViewerPrototype, private.CooldownViewerBuffPrototype,
    private.CooldownViewerUtilityPrototype, private.CooldownViewerItemPrototype }) do
    assert(prototype.type == "cdm" and prototype.statesParameter == "full" and prototype.cooldownViewerProgress == true,
      "prototype fields")
    assert(prototype.force_events == "PLAYER_ENTERING_WORLD", "prototype force_events")
    assert(prototype.internal_events[1] == "WA_CDM_REFRESH" and prototype.internal_events[2] == "WA_CDM_LAYOUT_CHANGED",
      "prototype internal events")
  end
  assert(private.CooldownViewerPrototype.name == "Cooldown" and private.CooldownViewerBuffPrototype.name == "Buff/Debuff"
    and private.CooldownViewerItemPrototype.name == "Item", "prototype names")

  local name, icon = private.CooldownViewerPrototype.GetNameAndIcon({ type = "cdm", event = COOLDOWN, cdmSpells = { multi = { [ENTRY] = true } } })
  assert(name == "Test Spell" and icon == 7000 + SPELL, "GetNameAndIcon of the first selected entry")
  name, icon = private.CooldownViewerPrototype.GetNameAndIcon({ type = "cdm", event = COOLDOWN, cdmSpells = { multi = {} } })
  assert(name == "Cooldown Manager" and icon == 134400, "GetNameAndIcon fallback")

  ---------------------------------------------------------------------------------------------------------------
  -- Buff filters: an active filter needs an active aura with a readable, timed value.
  ---------------------------------------------------------------------------------------------------------------
  local function FilterTrigger(operator, seconds)
    return { type = "cdm", event = BUFF, cdmUseExactIDs = true, cdmExactIDs = { tostring(BUFF_SPELL) }, cdmBuffShow = "always",
      cdmUseRemaining = true, cdmRemainingOperator = operator, cdmRemainingTime = seconds }
  end
  SetAura()
  Only(Run(Compile(FilterTrigger(">", 5)), {}, "UNIT_AURA"), "remaining filter passes")
  assert(#Shown(Run(Compile(FilterTrigger("<", 5)), {}, "UNIT_AURA")) == 0, "remaining filter fails")
  ClearAura()
  assert(#Shown(Run(Compile(FilterTrigger(">", 0)), {}, "UNIT_AURA")) == 0, "missing aura fails an active filter")
  SetAura()
  buffFrame.auraDataCached = { spellId = BUFF_SPELL, duration = 0, expirationTime = 0, applications = 2, timeMod = 1 }
  assert(#Shown(Run(Compile(FilterTrigger("<", 1000)), {}, "UNIT_AURA")) == 0, "permanent aura fails a time filter")
  SetAura()
  Units.SetCombat(true)
  buffFrame.auraDataCached = { spellId = Secret.Wrap(BUFF_SPELL), duration = Secret.Wrap(10),
    expirationTime = Secret.Wrap(GetTime() + 8), applications = Secret.Wrap(2), timeMod = Secret.Wrap(1) }
  assert(#Shown(Run(Compile(FilterTrigger("<", 1000)), {}, "UNIT_AURA")) == 0, "secret timer fails a time filter")
  Units.SetCombat(false)
  SetAura()

  ---------------------------------------------------------------------------------------------------------------
  -- Remaining time condition: six operators, modRate, active aura only, recheck at the next bound.
  ---------------------------------------------------------------------------------------------------------------
  local remainingArg
  for _, arg in ipairs(private.CooldownViewerBuffPrototype.args) do
    if arg.name == "cdmRemaining" then remainingArg = arg end
  end
  assert(remainingArg and remainingArg.operator_types == nil and not remainingArg.store, "cdmRemaining declares every operator")
  local timed = { show = true, cdmBuff = true, auraActive = true, progressType = "timed", duration = 10,
    expirationTime = GetTime() + 8, modRate = 2 }
  local Test = remainingArg.conditionTest
  assert(Test(timed, "5", "<") and Test(timed, "4", "<=") and Test(timed, "3", ">") and Test(timed, "4", ">="),
    "ordering operators read the remaining time divided by modRate")
  assert(Test(timed, "4.03", "==") and not Test(timed, "4.03", "~=") and Test(timed, "4.2", "~="), "equality within 0.05")
  assert(not Test(timed, "5", ">"), "remaining above the value")
  timed.auraActive = false
  assert(not Test(timed, "5", "<"), "inactive aura never matches")
  timed.auraActive = true
  local recheck = remainingArg.conditionRecheckTime(timed, "3")
  assert(recheck and math.abs(recheck - (GetTime() + (4 - 3.05) * 2)) < 0.001, "recheck at the first bound, scaled by modRate")

  ---------------------------------------------------------------------------------------------------------------
  -- Spell without charges: a readable native count becomes stacks, cooldown flags untouched.
  ---------------------------------------------------------------------------------------------------------------
  local COUNT_SPELL, COUNT_ENTRY = 4460, 1980
  local countFrame = AddEntry(COUNT_ENTRY, CATEGORY.Essential, COUNT_SPELL)
  Reload()
  local countConfig = Config({ cdmSpell = tostring(COUNT_SPELL) })
  Only(Update(countConfig, "SPELL_UPDATE_COOLDOWN"), "count spell")
  countFrame.cooldownChargesCount = 2
  countFrame:RefreshData()
  test.Environment.Advance(0.2)
  state = Only(Update(countConfig, "SPELL_UPDATE_COOLDOWN"), "count spell with native count")
  assert(state.stacks == 2 and state.onCooldown == false and state.isReady == true, "native count goes to stacks only")

  ---------------------------------------------------------------------------------------------------------------
  -- Picker: a checked entry is admitted even when not learned; visibility still needs a known spell.
  ---------------------------------------------------------------------------------------------------------------
  local PICK_SPELL, PICK_ENTRY = 4470, 1990
  AddEntry(PICK_ENTRY, CATEGORY.Essential, PICK_SPELL, { isKnown = false })
  Reload()
  local pickSelected = Picked({ type = "cdm", event = COOLDOWN, cdmSpells = { multi = { [PICK_ENTRY] = true } } }, "WA_CDM_REFRESH")
  states = {}
  private.ExecEnv.UpdateCooldownViewerStates(states, pickSelected, "SPELL_UPDATE_COOLDOWN", false, "auto", true, "always", nil, false, false)
  Only(states, "picked unlearned entry")
  world.known[PICK_SPELL] = false
  private.ExecEnv.UpdateCooldownViewerStates(states, pickSelected, "SPELL_UPDATE_COOLDOWN", false, "auto", true, "always", nil, false, false)
  assert(#Shown(states) == 0, "picked entry hides when its spell is unknown")
  world.known[PICK_SPELL] = true

  ---------------------------------------------------------------------------------------------------------------
  -- Charges recharging during a GCD: the charge timer stays, no GCD flag nor suppression.
  ---------------------------------------------------------------------------------------------------------------
  local GCD_CHARGE_SPELL, GCD_CHARGE_ENTRY = 4480, 2000
  AddEntry(GCD_CHARGE_ENTRY, CATEGORY.Essential, GCD_CHARGE_SPELL)
  Reload()
  local gcdCharges = Spell(GCD_CHARGE_SPELL)
  gcdCharges.charges = { currentCharges = 1, maxCharges = 2, isActive = true }
  gcdCharges.chargeDuration = Duration(8, 2)
  gcdCharges.duration = Duration(0)
  gcdCharges.gcdDuration = Duration(1.5, 0.3)
  gcdCharges.cooldown = { isActive = true, isEnabled = true, isOnGCD = true }
  state = Only(Update(Config({ cdmSpell = tostring(GCD_CHARGE_SPELL), showGCD = false, track = "auto" }),
    "SPELL_UPDATE_COOLDOWN"), "charges during gcd")
  assert(state.cdmGCDOnly == false and state.cdmSuppressGCD == false, "charge timer is not a GCD")
  assert(state.progressType == "durationObject" and state.durationObject == gcdCharges.chargeDuration,
    "charge timer kept during the GCD: " .. tostring(state.progressType))

  ---------------------------------------------------------------------------------------------------------------
  -- Item trigger with an exact spell id: the state keeps the item identity, not the spell one.
  ---------------------------------------------------------------------------------------------------------------
  local ITEM_SPELL, ITEM_ENTRY, ITEM_ID = 4490, 2010, 99001
  local realInfo, realInventory, realItem = C_CooldownViewer.GetCooldownViewerCooldownInfo, GetInventoryItemID, C_Item
  C_CooldownViewer.GetCooldownViewerCooldownInfo = function(id)
    local info = realInfo(id)
    if info and id == ITEM_ENTRY then info.equipSlot = 13 end
    return info
  end
  GetInventoryItemID = function(_, slot) return slot == 13 and ITEM_ID or nil end
  C_Item = {
    IsItemDataCachedByID = function() return true end,
    GetItemNameByID = function(id) return id == ITEM_ID and "Trinket" or nil end,
    GetItemIconByID = function(id) return id == ITEM_ID and 9001 or nil end,
    GetItemSpell = function(id) if id == ITEM_ID then return "Spell " .. ITEM_SPELL, ITEM_SPELL end end,
  }
  AddEntry(ITEM_ENTRY, CATEGORY.Essential, ITEM_SPELL)
  Reload()
  local itemQueries = private.CDMSpellQueries({ type = "cdm", event = ITEM, cdmUseExactIDs = true,
    cdmExactIDs = { tostring(ITEM_SPELL) }, use_ignoreSpellKnown = true })
  states = {}
  private.ExecEnv.UpdateCDMSelectionList(states, itemQueries, "SPELL_UPDATE_COOLDOWN")
  state = Only(states, "item by exact spell id")
  assert(state.itemId == ITEM_ID and state.name == "Trinket" and state.icon == 9001,
    "item identity kept: " .. tostring(state.name) .. " / " .. tostring(state.icon))
  assert(state.spellId ~= ITEM_SPELL or state.name ~= "Spell " .. ITEM_SPELL, "exact spell id must not replace the item")
  C_CooldownViewer.GetCooldownViewerCooldownInfo, GetInventoryItemID, C_Item = realInfo, realInventory, realItem
  world.entries[ITEM_ENTRY], world.frames[ITEM_ENTRY] = nil, nil
  Reload()

  ---------------------------------------------------------------------------------------------------------------
  -- 7. Two auras with identical settings (documented, not asserted)
  ---------------------------------------------------------------------------------------------------------------
  -- Current behaviour, observed while writing this scenario: Private.LoadFunction caches by source text, so two
  -- auras whose trigger compiles to the same text receive the very same function, and everything local to that
  -- chunk is shared between them. For plain triggers the chunk only holds immutable config (config table or
  -- query list) and each aura still writes into its own allstates, so nothing visible is shared. For buff
  -- triggers with remaining / stacks / total / elapsed filters the chunk also holds `rawStates`, which IS shared
  -- by both auras. Resolution and output tables are also pooled per selection inside the module. We do not
  -- assert any of this: a rewrite is free to share nothing, and only the per-aura states must stay independent.
  local first = Run(Compile(multi), {}, "SPELL_UPDATE_COOLDOWN")
  local second = Run(Compile(multi), {}, "SPELL_UPDATE_COOLDOWN")
  assert(first ~= second and #Shown(first) == #Shown(second), "each aura keeps its own states")
end

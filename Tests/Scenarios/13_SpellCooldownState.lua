-- SpellCooldownState: spell cooldown read readable out of combat, then secret in combat.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Units = test.Secret, test.Units
  local State = private.SpellCooldownState
  assert(State, "SpellCooldownState missing")

  local SPELL = 1234
  local info = { isActive = true, isEnabled = true, isOnGCD = false }
  local cooldownDuration, chargeDuration
  local charges = { currentCharges = 2, maxCharges = 3 }
  local function Timer(remaining, total, secret)
    local duration = Units.NewDuration()
    local start = GetTime() + remaining - total
    duration:SetTimeFromStart(secret and Secret.Wrap(start) or start, total)
    return duration
  end

  C_Spell.GetSpellCooldown = function() return info end
  C_Spell.GetSpellCooldownDuration = function() return cooldownDuration end
  C_Spell.GetSpellChargeDuration = function() return chargeDuration end
  C_Spell.GetSpellCharges = function() return charges end
  C_Spell.GetSpellCastCount = function() return 4 end
  C_Spell.GetSpellLossOfControlCooldownInfo = nil
  C_Spell.GetSpellLossOfControlCooldownDuration = nil

  -- readable
  assert(State.IsCooldownSecret(SPELL) == false, "predicate out of combat")
  local current, maximum, count = State.ReadCharges(SPELL)
  assert(current == 2 and maximum == 3 and count == 4, "readable charges")

  cooldownDuration = Timer(8, 10)
  assert(State.IsDuration(cooldownDuration) and not State.IsDuration(5) and not State.IsDuration(nil), "IsDuration")
  assert(math.abs(State.ReadableRemaining(cooldownDuration) - 8) < 0.01, "readable remaining")
  assert(State.GetCooldownDurationWithoutGCD(SPELL) == cooldownDuration, "own cooldown replaced")
  assert(State.IsGCDOnly(SPELL) == false, "running cooldown flagged GCD only")
  assert(State.SelectSpell(SPELL, 1, 0) == 1, "running cooldown selector")
  local shown, withoutGCD = State.GetDisplayDurations(SPELL, false, false, false)
  assert(shown == cooldownDuration and withoutGCD == cooldownDuration, "display durations")
  chargeDuration = Timer(3, 5)
  assert(State.GetDisplayDurations(SPELL, true, false, false) == chargeDuration, "charge duration")

  cooldownDuration = Timer(0, 0)
  info.isActive = true
  assert(State.IsGCDOnly(SPELL) == true, "empty timer on an active cooldown is the GCD")
  assert(State.SelectSpell(SPELL, 1, 0) == 0, "GCD only counts as ready")
  info.isActive = false
  assert(State.IsGCDOnly(SPELL) == false, "inactive cooldown flagged GCD only")

  -- combat: everything secret
  Units.SetCombat(true)
  assert(WeakAuras.IsRestricted(), "combat not restricted")
  assert(State.IsCooldownSecret(SPELL) == true, "predicate in combat")
  info = { isActive = Secret.Wrap(true), isEnabled = true, isOnGCD = Secret.Wrap(false) }
  charges = { currentCharges = Secret.Wrap(2), maxCharges = 3 }
  C_Spell.GetSpellCastCount = function() return Secret.Wrap(4) end
  cooldownDuration = Timer(8, 10, true)
  chargeDuration = Timer(3, 5, true)

  local function NoError(label, step, ...)
    local results = { pcall(step, ...) }
    assert(results[1], label .. ": " .. tostring(results[2]))
    return unpack(results, 2, 5)
  end

  current, maximum, count = NoError("secret charges", State.ReadCharges, SPELL)
  assert(current == nil and maximum == 3 and count == nil, "secret charges must read as nil, max kept")
  assert(NoError("secret remaining", State.ReadableRemaining, cooldownDuration) == nil, "secret remaining readable")
  assert(NoError("IsGCDOnly", State.IsGCDOnly, SPELL) == false, "secret info flagged GCD only")

  State.UpdateGCDFlag(SPELL)
  assert(State.GetGCDFlag(SPELL) == nil, "secret isOnGCD stored")
  info = { isActive = true, isEnabled = true, isOnGCD = true }
  State.UpdateGCDFlag(SPELL)
  assert(State.GetGCDFlag(SPELL) == true, "readable isOnGCD ignored")
  State.ClearGCDFlags()
  assert(State.GetGCDFlag(SPELL) == nil, "flags not cleared")

  local selected = NoError("secret selector", State.SelectDuration, cooldownDuration, 1, 0)
  assert(Secret.IsSecret(selected), "secret duration selector must return a secret value")
  selected = NoError("secret spell selector", State.SelectSpell, SPELL, 1, 0)
  assert(Secret.IsSecret(selected) or selected ~= nil, "secret spell selector returned nothing")
  assert(NoError("selector without duration", State.SelectDuration, nil, 1, 0) == nil, "nil duration answered")

  local a, b = NoError("secret display durations", State.GetDisplayDurations, SPELL, false, true, false)
  assert(a and b, "no duration to display in combat")
  assert(NoError("secret charge display", State.GetDisplayDurations, SPELL, true, false, false) == chargeDuration,
    "secret charge duration lost")

  NoError("secret cast", State.NotePlayerCast, Secret.Wrap(5019))
  NoError("secret cooldown event", State.NoteCooldownEvent, Secret.Wrap(5019), Secret.Wrap(1))
  NoError("readable shoot cast", State.NotePlayerCast, State.SHOOT_SPELL_ID)
  assert(State.IsWandHeld(SPELL) == true, "wand hold not started")
  local held = NoError("wand hold with secret timer", State.GetCooldownDurationWithoutGCD, SPELL)
  assert(held ~= nil, "wand hold lost the timer")
  State.ClearWandHold()
  assert(State.IsWandHeld(SPELL) == false, "wand hold not cleared")

  Units.SetCombat(false)
  assert(State.IsCooldownSecret(SPELL) == false, "predicate after combat")
end

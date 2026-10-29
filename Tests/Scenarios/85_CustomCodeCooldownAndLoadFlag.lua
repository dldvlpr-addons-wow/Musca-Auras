-- Custom code helpers: IsSpellReady, GetSpellCooldownDurationNoGCD and SetSpellCooldownState read a watched spell
-- cooldown; SetLoadFlag keeps another aura unloaded until custom code gives it back to its load options.
return function(test)
  local function Icon(id)
    return {
      id = id, uid = id, regionType = "icon", internalVersion = 91,
      triggers = { { trigger = { type = "custom", custom_type = "status", check = "update", events = "",
        custom = "function() return true end" }, untrigger = {} }, activeTriggerMode = -10 },
      load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
    }
  end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { Wand = Icon("Wand") } })
  test.Environment.Advance(2)
  local Units = test.Units

  -- SetLoadFlag
  assert(private.loaded["Wand"] == true, "aura not loaded at start")
  WeakAuras.SetLoadFlag("Wand", false)
  assert(private.loaded["Wand"] == true, "load flag scanned before the next frame")
  test.Environment.Advance(0.1)
  assert(not private.loaded["Wand"], "load flag off did not unload the aura")
  private.ScanForLoads({ Wand = true })
  test.Environment.Advance(0.1)
  assert(not private.loaded["Wand"], "a later scan loaded the aura again")
  WeakAuras.SetLoadFlag("Wand", true)
  test.Environment.Advance(0.1)
  assert(private.loaded["Wand"] == true, "load flag on did not load the aura again")
  WeakAuras.SetLoadFlag("Missing aura", false)
  WeakAuras.SetLoadFlag(42, false)
  test.Environment.Advance(0.1)

  -- Cooldown helpers on a watched spell
  local SPELL, UNKNOWN = 20572, 20554
  local cooldown = { startTime = 0, duration = 0, isEnabled = true, modRate = 1, isActive = false, isOnGCD = false }
  local cooldownDuration
  WeakAuras.IsSpellKnown = function(spell) return spell == SPELL end
  local idle = { startTime = 0, duration = 0, isEnabled = true, modRate = 1, isActive = false, isOnGCD = false }
  C_Spell.GetSpellCooldown = function(spell) return spell == SPELL and cooldown or idle end
  C_Spell.GetSpellCharges = function() return nil end
  C_Spell.GetSpellCooldownDuration = function() return cooldownDuration end
  C_Spell.GetSpellLossOfControlCooldownInfo = nil

  WeakAuras.WatchSpellCooldown(SPELL)
  WeakAuras.WatchSpellCooldown(UNKNOWN)
  assert(WeakAuras.IsSpellReady(SPELL) == true, "spell off cooldown not ready")
  assert(WeakAuras.IsSpellReady(UNKNOWN) == nil, "unknown spell answered")
  assert(WeakAuras.IsSpellReady(12345) == nil, "spell not watched answered")
  assert(WeakAuras.GetSpellCooldownDurationNoGCD(UNKNOWN) == nil, "unknown spell duration")

  cooldown = { startTime = GetTime() - 10, duration = 120, isEnabled = true, modRate = 1, isActive = true,
    isOnGCD = false }
  cooldownDuration = Units.NewDuration()
  cooldownDuration:SetTimeFromStart(cooldown.startTime, cooldown.duration)
  test.Frames.Fire("SPELL_UPDATE_COOLDOWN")
  test.Environment.Advance(0.1)
  assert(WeakAuras.IsSpellReady(SPELL) == false, "spell on cooldown read as ready")
  assert(WeakAuras.GetSpellCooldownDurationNoGCD(SPELL) == cooldownDuration, "cooldown duration without the GCD")

  local state = {}
  WeakAuras.SetSpellCooldownState(state, SPELL, true)
  assert(state.progressType == "durationObject" and state.durationObject == cooldownDuration, "state duration")
  assert(state.onCooldown == true and state.changed == true, "state flag")
  state.changed = nil
  WeakAuras.SetSpellCooldownState(state, SPELL, true)
  assert(state.changed == nil, "unchanged state marked changed")

  local unknownState = {}
  WeakAuras.SetSpellCooldownState(unknownState, UNKNOWN, true)
  assert(unknownState.durationObject == nil and unknownState.onCooldown == false, "unknown spell state")

  -- Another rank of the watched spell finds it by name.
  local OTHER_RANK = 20573
  local GetEffectiveSpellId = private.ExecEnv.GetEffectiveSpellId
  private.ExecEnv.GetEffectiveSpellId = function(spell, ...)
    if spell == OTHER_RANK then return SPELL end
    return GetEffectiveSpellId(spell, ...)
  end
  assert(WeakAuras.IsSpellReady(OTHER_RANK) == false, "other rank not found by name")
  assert(WeakAuras.GetSpellCooldownDurationNoGCD(OTHER_RANK) == cooldownDuration, "other rank duration")
  private.ExecEnv.GetEffectiveSpellId = GetEffectiveSpellId

  -- Custom code reaches the helpers through ForeverAuras, as imported packs call them.
  local func = assert(WeakAuras.LoadFunction("return function(spell) local state = {} "
    .. "ForeverAuras.SetSpellCooldownState(state, spell, true) ForeverAuras.SetLoadFlag('Wand', false) "
    .. "return ForeverAuras.IsSpellReady(spell), ForeverAuras.GetSpellCooldownDurationNoGCD(spell), state.onCooldown end",
    "custom-code-helpers"), "custom code not compiled")
  local ready, duration, onCooldown = func(SPELL)
  assert(ready == false and duration == cooldownDuration and onCooldown == true, "helpers from custom code")
  test.Environment.Advance(0.1)
  assert(not private.loaded["Wand"], "SetLoadFlag from custom code")

  -- A secret cooldown the game does not settle reads as unknown, not as ready.
  local Secret = test.Secret
  cooldown = { startTime = Secret.Wrap(GetTime()), duration = Secret.Wrap(120), isEnabled = true, modRate = 1,
    isActive = Secret.Wrap(true) }
  test.Frames.Fire("SPELL_UPDATE_COOLDOWN")
  test.Environment.Advance(0.1)
  assert(WeakAuras.IsSpellReady(SPELL) == nil, "unsettled secret cooldown answered")
end

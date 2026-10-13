-- CooldownViewerTrigger: spell state from a native viewer frame, readable then secret in combat.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Units = test.Secret, test.Units

  local SPELL, COOLDOWN_ID = 4321, 900
  Enum.CooldownViewerCategory = { Essential = 0, Utility = 1, TrackedBuff = 2, TrackedBar = 3 }
  C_CooldownViewer = C_CooldownViewer or {}
  C_CooldownViewer.GetCooldownViewerCategorySet = function(category)
    if category == 0 then return { COOLDOWN_ID } end
    return {}
  end
  C_CooldownViewer.GetCooldownViewerCooldownInfo = function(id)
    if id == COOLDOWN_ID then return { cooldownID = id, spellID = SPELL, isKnown = true } end
  end

  local frame = CreateFrame("Frame")
  frame.cooldownID = COOLDOWN_ID
  frame.GetSpellID = function() return SPELL end
  frame.RefreshData = function() end
  frame.isOnActualCooldown, frame.wasSetFromCharges, frame.isOnGCD = true, false, false
  frame.cooldownChargesCount = 2
  EssentialCooldownViewer = { itemFramePool = { EnumerateActive = function() return next, { [frame] = true } end } }

  local chargeInfo = { currentCharges = 2, maxCharges = 3, isActive = false }
  local remaining = Units.NewDuration()
  C_Spell.GetSpellInfo = function(id) return { name = "Test Spell", iconID = 134400, spellID = id } end
  C_Spell.GetSpellCooldownDuration = function() return remaining end
  C_Spell.GetSpellChargeDuration = function() return remaining end
  C_Spell.GetSpellCharges = function() return chargeInfo end
  C_Spell.GetSpellCooldown = function() return { isActive = true, isEnabled = true, isOnGCD = false } end
  C_Spell.IsSpellUsable = function() return true, false end
  C_Spell.GetSpellCastCount = function() return 0 end

  local config = { type = "cdm", event = "Blizzard CDM Spell", cdmSpell = tostring(SPELL), cdmExact = true,
    track = "auto", showGCD = false, use_ignoreSpellKnown = true }
  local allstates = {}
  local function Update(label, event)
    local ok, err = pcall(private.ExecEnv.UpdateCDMSpell, allstates, config, event or "WA_CDM_REFRESH")
    assert(ok, label .. ": " .. tostring(err))
    local state
    for _, candidate in pairs(allstates) do
      if candidate.show then state = candidate end
    end
    return state
  end

  remaining:SetTimeFromStart(GetTime() - 2, 10)
  Update("observe frame", "PLAYER_ENTERING_WORLD")
  frame:RefreshData()
  local state = Update("readable pass")
  assert(state, "no state out of combat")
  assert(state.spellId == SPELL, "spell id " .. tostring(state.spellId))
  assert(state.stacks == 2, "readable charges " .. tostring(state.stacks))
  local native = private.CDMGetNativeCooldown(frame, SPELL)
  assert(native and native.charges == 2, "native record missing or charges unread")
  assert(state.progressType == "durationObject", "progress " .. tostring(state.progressType))

  -- combat: native charges, charge info and timer all secret
  Units.SetCombat(true)
  frame.cooldownChargesCount = Secret.Wrap(2)
  chargeInfo = { currentCharges = Secret.Wrap(2), maxCharges = 3, isActive = Secret.Wrap(true) }
  remaining = Units.NewDuration()
  remaining:SetTimeFromStart(Secret.Wrap(GetTime() - 2), 10)
  frame:RefreshData()
  test.Environment.Advance(0.2)
  state = Update("secret pass")
  assert(state, "state lost in combat")
  assert(not Secret.IsSecret(state.stacks), "secret charges stored as stacks")
  assert(private.CDMGetNativeCooldown(frame, SPELL).charges == nil, "secret native charges kept")
  assert(state.progressType == "durationObject" and state.durationObject, "timing lost in combat")

  -- secret flags on the native frame
  frame.isOnActualCooldown, frame.wasSetFromCharges, frame.isOnGCD =
    Secret.Wrap(true), Secret.Wrap(false), Secret.Wrap(false)
  frame.cooldownModRate = Secret.Wrap(1)
  frame:RefreshData()
  assert(Update("secret flags"), "state lost with secret flags")
  native = private.CDMGetNativeCooldown(frame, SPELL)
  assert(native and native.charges == nil and native.onCooldown == nil, "secret native fields must read as nil")

  Units.SetCombat(false)
  state = Update("after combat")
  assert(state, "state lost after combat")
end

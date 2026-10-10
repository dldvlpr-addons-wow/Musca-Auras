return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret = test.Secret

  local frame = {
    cooldownID = 100, auraInstanceID = 5, isActive = true, auraDataUnit = "player",
    auraDataCached = { spellId = 200311, duration = 10, expirationTime = GetTime() + 10, applications = 1, timeMod = 1 },
  }
  local function Apply()
    local state = { progressType = "static", value = 1, total = 1 }
    private.CDMApplyAura(state, {}, {}, frame, nil, nil)
    return state
  end

  local out = Apply()
  assert(out.progressType == "durationObject", "readable pass " .. tostring(out.progressType))

  local realCreate = C_DurationUtil.CreateDuration
  C_DurationUtil.CreateDuration = function()
    local built = realCreate()
    return setmetatable({}, { __index = function(_, key)
      if key ~= "SetTimeFromEnd" then return built[key] end
      return function(_, endTime, total, modRate)
        if Secret.IsSecret(endTime) or Secret.IsSecret(total) then error("secret while tainted") end
        return built:SetTimeFromEnd(endTime, total, modRate)
      end
    end })
  end
  frame.auraInstanceID = Secret.Wrap(5)
  frame.auraDataCached = {
    spellId = Secret.Wrap(200311), duration = Secret.Wrap(10), expirationTime = Secret.Wrap(GetTime() + 8),
    applications = Secret.Wrap(1), timeMod = Secret.Wrap(1),
  }
  test.Environment.Advance(2)
  out = Apply()
  assert(out.progressType == "durationObject" and out.durationObject, "secret pass lost timing " .. tostring(out.progressType))

  local before = out.durationObject:GetRemainingDuration()
  assert(before < 8.5, "remaining before recast " .. before)
  local function Cast(target, guid, spellID)
    test.Units.fire("UNIT_SPELLCAST_SENT", "player", target, guid, spellID)
    test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, spellID)
    test.Environment.Advance(0.1)
    return Apply().durationObject:GetRemainingDuration()
  end
  assert(Cast("Somebody", "guid1", 200311) < 8.5, "cast on another target restarted")
  assert(Cast("", "guid2", 999) < 8.5, "other spell restarted")
  test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid3", 200311)
  test.Environment.Advance(0.1)
  assert(Apply().durationObject:GetRemainingDuration() < 8.5, "cast without SENT restarted")
  test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", "guid5", 200311)
  test.Units.fire("UNIT_SPELLCAST_INTERRUPTED", "player", "guid5", 200311)
  test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid5", 200311)
  test.Environment.Advance(0.1)
  assert(Apply().durationObject:GetRemainingDuration() < 8.5, "interrupted cast restarted")
  test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", "guid4", 200311)
  test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid4", 200311)
  test.Environment.Advance(0.5)
  out = Apply()
  local after = out.durationObject:GetRemainingDuration()
  assert(out.progressType == "durationObject" and after > 9, "recast did not restart " .. tostring(after))

  test.Environment.Advance(20)
  out = Apply()
  assert(out.progressType == "static", "expired timing kept " .. tostring(out.progressType))

  frame.auraInstanceID = 5
  frame.auraDataCached = { spellId = 324, duration = 10, expirationTime = GetTime() + 10, applications = 1, timeMod = 1 }
  Apply()
  frame.auraInstanceID = Secret.Wrap(5)
  frame.auraDataCached = {
    spellId = Secret.Wrap(324), duration = Secret.Wrap(10), expirationTime = Secret.Wrap(GetTime() + 8),
    applications = Secret.Wrap(1), timeMod = Secret.Wrap(1),
  }
  test.Environment.Advance(2)
  assert(Apply().durationObject:GetRemainingDuration() < 8.5, "rank setup")
  assert(Cast("", "guid6", 8134) > 9, "sibling rank did not restart")

  frame.isActive = false
  frame.auraInstanceID, frame.auraDataCached = nil, nil
  out = Apply()
  assert(out.auraActive == false and out.progressType == "static", "inactive pass")
  C_DurationUtil.CreateDuration = realCreate

  local stale = {
    cooldownID = 101, auraInstanceID = 9, isActive = true, auraDataUnit = "player", auraSpellID = Secret.Wrap(52127),
    auraDataCached = { spellId = Secret.Wrap(52127), duration = Secret.Wrap(600), expirationTime = Secret.Wrap(1),
      applications = Secret.Wrap(1), timeMod = Secret.Wrap(1) },
  }
  test.Units.ApplyAura("player", { name = "Water Shield", spellId = 52127, duration = 600 })
  local exact = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(exact, {}, {}, stale, 52127, nil)
  assert(exact.progressType == "durationObject" and exact.auraActive == true,
    "exact-ID trigger with a secret aura spell ID lost timing " .. tostring(exact.progressType))

  local shield = {
    cooldownID = 102, auraInstanceID = 11, isActive = true, auraDataUnit = "player", auraSpellID = 324,
    auraDataCached = { spellId = 324, duration = 600, expirationTime = GetTime() + 600, applications = 3, timeMod = 1 },
  }
  local before = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(before, {}, {}, shield, 324, nil)
  assert(before.auraActive == true, "exact-ID readable pass")
  test.Units.SetCombat(true)
  assert(WeakAuras.IsRestricted(), "combat not restricted")
  shield.auraSpellID, shield.auraInstanceID = Secret.Wrap(324), Secret.Wrap(12)
  shield.auraDataCached = { spellId = Secret.Wrap(324), duration = Secret.Wrap(600),
    expirationTime = Secret.Wrap(GetTime() + 600), applications = Secret.Wrap(3), timeMod = Secret.Wrap(1) }
  local inCombat = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(inCombat, {}, {}, shield, 324, nil)
  assert(inCombat.auraActive == true, "exact-ID aura hidden in combat " .. tostring(inCombat.auraActive))
  local other = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(other, {}, {}, shield, 325, nil)
  assert(other.auraActive ~= true, "exact-ID matched another rank in combat")
  test.Units.fire("UNIT_SPELLCAST_SENT", "player", "", "guid7", 325)
  test.Units.fire("UNIT_SPELLCAST_SUCCEEDED", "player", "guid7", 325)
  local afterRank = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(afterRank, {}, {}, shield, 324, nil)
  assert(afterRank.auraActive ~= true, "exact-ID kept old rank after a rank cast in combat")
  local newRank = { progressType = "static", value = 1, total = 1 }
  private.CDMApplyAura(newRank, {}, {}, shield, 325, nil)
  assert(newRank.auraActive == true, "exact-ID missed the new rank in combat")
  test.Units.SetCombat(false)
end

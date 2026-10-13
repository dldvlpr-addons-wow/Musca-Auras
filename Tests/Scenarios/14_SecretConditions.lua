-- SecretConditions: the Private.ExecEnv selectors with readable then secret inputs.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Secret, Units = test.Secret, test.Units
  local env = private.ExecEnv
  local function NoError(label, step, ...)
    local results = { pcall(step, ...) }
    assert(results[1], label .. ": " .. tostring(results[2]))
    return results[2]
  end
  local function Timer(remaining, total, secret)
    local duration = Units.NewDuration()
    local start = GetTime() + remaining - total
    duration:SetTimeFromStart(secret and Secret.Wrap(start) or start, total)
    return duration
  end

  -- readable values
  assert(env.SecretPick(true, 1, 0) == 1 and env.SecretPick(false, 1, 0) == 0, "SecretPick")
  assert(env.SecretBoolSelect(true, false, true, 1, 0) == 1, "bool readable active")
  assert(env.SecretBoolSelect(false, false, false, 1, 0) == 0, "bool readable inactive")
  assert(env.SecretBoolSelect(true, true, true, 1, 0) == 1, "bool readable follows readableActive")
  assert(env.SecretValueSelect(function() return nil end, {}, false, true, 1, 0) == 1, "nil selector, active")
  assert(env.SecretValueSelect(function() return nil end, {}, false, false, 1, 0) == 0, "nil selector, inactive")
  assert(env.SecretValueSelect(function(_, yes) return yes end, {}, false, false, 1, 0) == 1, "selector true value")
  assert(env.SecretValueSelect(function(_, yes) return yes end, {}, true, false, 1, 0) == 0, "selector inverted")
  local readableState = { durationObject = Timer(8, 10) }
  assert(env.SecretTimerSelect(readableState, ">", 5, true, 1, 0) == 1, "timer readable active")
  assert(env.SecretTimerSelect(readableState, ">", 5, false, 1, 0) == 0, "timer readable inactive")
  assert(env.SecretTimerSelect(nil, ">", 5, true, 1, 0) == 1, "timer without state")
  assert(env.SecretTimerSelect({}, "<", 0, false, 1, 0) == 0, "timer threshold zero")

  -- secret values
  Units.SetCombat(true)
  local secretTrue = Secret.Wrap(true)
  local result = NoError("bool secret", env.SecretBoolSelect, secretTrue, false, false, 1, 0)
  assert(Secret.IsSecret(result) and Secret.Reveal(result) == 1, "bool secret true")
  result = NoError("bool secret inverted", env.SecretBoolSelect, secretTrue, true, false, 1, 0)
  assert(Secret.IsSecret(result) and Secret.Reveal(result) == 0, "bool secret inverted")
  result = NoError("bool secret false", env.SecretBoolSelect, Secret.Wrap(false), false, true, 1, 0)
  assert(Secret.IsSecret(result) and Secret.Reveal(result) == 0, "bool secret false")

  result = NoError("value secret", env.SecretValueSelect, function(_, yes) return Secret.Wrap(yes) end, {}, false, false, 1, 0)
  assert(Secret.IsSecret(result), "secret selector value dropped")
  assert(NoError("value nil, secret ignored", env.SecretValueSelect, function() end, {}, false, true, 1, 0) == 1, "fallback")

  local secretState = { durationObject = Timer(8, 10, true) }
  assert(secretState.durationObject:HasSecretValues(), "setup: duration not secret")
  for _, op in ipairs({ ">", ">=", "<", "<=" }) do
    result = NoError("timer secret " .. op, env.SecretTimerSelect, secretState, op, 5, false, 1, 0)
    assert(Secret.IsSecret(result), "timer " .. op .. " must stay secret")
  end
  assert(Secret.Reveal(env.SecretTimerSelect(secretState, ">", 5, false, 1, 0)) == 1, "timer > 5 with 8 left")
  assert(Secret.Reveal(env.SecretTimerSelect(secretState, "<", 5, false, 1, 0)) == 0, "timer < 5 with 8 left")
  result = NoError("timer secret outputs", env.SecretTimerSelect, secretState, ">", 5, true, Secret.Wrap(1), 0)
  assert(result == 1 or Secret.IsSecret(result), "secret outputs not handled")

  -- refresh toggling on a region without a toShow state
  local region = CreateFrame("Frame")
  NoError("refresh on", env.SetSecretConditionRefresh, region, true)
  NoError("refresh off", env.SetSecretConditionRefresh, region, false)

  Units.SetCombat(false)
end

-- A custom duration function that returns secret values (aura.duration, aura.expirationTime under restriction):
-- ActivateEvent shows the aura without a timer instead of comparing the secrets and breaking the event pass.
return function(test)
  local Secret = test.Secret
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {} })
  test.Environment.Advance(2)

  local function Activate(durationFunc)
    local state = {}
    private.ActivateEvent("SecretDuration", 1, { durationFunc = durationFunc, trigger = {} }, state, geterrorhandler())
    return state
  end

  local state = Activate(function() return Secret.Wrap(10), Secret.Wrap(1000) end)
  assert(state.progressType == "timed", "progressType: " .. tostring(state.progressType))
  assert(state.duration == 0, "duration: " .. tostring(state.duration))
  assert(state.expirationTime == math.huge, "expirationTime: " .. tostring(state.expirationTime))

  -- A secret static flag or inverse is not tested either.
  state = Activate(function() return 5, 10, Secret.Wrap(true), Secret.Wrap(true) end)
  assert(state.progressType == "timed" and state.expirationTime == math.huge, "secret static flag tested")
  assert(state.inverse == nil, "secret inverse kept")

  -- Readable values keep their usual path.
  state = Activate(function() return 5, 10, true end)
  assert(state.progressType == "static" and state.value == 5 and state.total == 10, "static progress lost")
end

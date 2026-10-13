-- Secret helpers of SecretRestrictions.lua, then the icon cooldown with secret timing.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { SecretIcon = {
    id = "SecretIcon", uid = "SecretIcon", regionType = "icon", internalVersion = 91, cooldown = true,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  } } })
  test.Environment.Advance(1)
  local Secret = test.Secret
  local secretFive = Secret.Wrap(5)

  assert(private.ReadableOrNil(4) == 4 and private.ReadableOrNil("x") == "x", "readable value lost")
  assert(private.ReadableOrNil(nil) == nil and private.ReadableOrNil(false) == false, "nil or false changed")
  assert(private.ReadableOrNil(secretFive) == nil, "secret not dropped")

  assert(private.IsReadableNumber(1, 2.5, 0), "readable numbers refused")
  assert(private.IsReadableNumber(), "empty list refused")
  assert(not private.IsReadableNumber(1, secretFive), "secret number accepted")
  assert(not private.IsReadableNumber(1, "2"), "string accepted")
  assert(not private.IsReadableNumber(nil), "nil accepted")

  local calls = {}
  local fake = { SetCooldown = function(_, start, duration, modRate) calls[#calls + 1] = { start, duration, modRate } end }
  assert(private.ApplyCooldown(fake, 110, 10, 2) == true, "readable apply refused")
  assert(#calls == 1 and calls[1][1] == 100 and calls[1][2] == 10 and calls[1][3] == 2, "SetCooldown arguments")
  for _, args in ipairs({ { secretFive, 10 }, { 110, secretFive }, { "110", 10 }, { 110, nil } }) do
    assert(private.ApplyCooldown(fake, args[1], args[2]) == false, "unreadable apply accepted")
  end
  assert(#calls == 1, "SetCooldown called with unreadable value")
  assert(private.ApplyCooldown({ SetCooldown = function() error("boom") end }, 110, 10) == false, "error not caught")

  local given
  local durationFake = { SetCooldownFromDurationObject = function(_, object, clear) given = { object, clear } end }
  assert(private.ApplyCooldownDuration(durationFake, "obj") == true and given[1] == "obj" and given[2] == true,
    "duration apply")
  assert(private.ApplyCooldownDuration({ SetCooldownFromDurationObject = function() error("boom") end }, "obj") == false,
    "duration error not caught")

  -- Icon region, secret timing in combat.
  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  local region = WeakAuras.GetRegion("SecretIcon")
  assert(region and region.UpdateTime, "icon region missing")
  local cooldown = region.cooldown

  local function Run(label, step)
    local ok, err = pcall(step)
    assert(ok, label .. ": " .. tostring(err))
  end

  region.duration, region.expirationTime, region.modRate = 10, GetTime() + 8, 1
  Run("readable time", function() region:UpdateTime() end)
  assert(cooldown:IsShown(), "readable cooldown hidden")
  region.value, region.total = 3, 10
  Run("readable value", function() region:UpdateValue() end)
  assert(cooldown:IsShown(), "readable value cooldown hidden")

  test.Units.SetCombat(true)
  for _, case in ipairs({
    { Secret.Wrap(10), GetTime() + 8 }, { 10, Secret.Wrap(GetTime() + 8) },
    { Secret.Wrap(10), Secret.Wrap(GetTime() + 8) },
  }) do
    region.duration, region.expirationTime = case[1], case[2]
    cooldown:Show()
    Run("UpdateTime secret", function() region:UpdateTime() end)
    assert(not cooldown:IsShown(), "cooldown shown with a secret duration or expiration")
    Run("PreShow secret", function() region:PreShow() end)
    assert(not cooldown:IsShown(), "PreShow showed a secret cooldown")
    Run("UpdateEffectiveInverse secret", function() region:UpdateEffectiveInverse() end)
  end

  region.value, region.total = Secret.Wrap(3), 10
  cooldown:Show()
  Run("UpdateValue secret", function() region:UpdateValue() end)
  assert(not cooldown:IsShown(), "cooldown shown with a secret value")
  region.value, region.total = 3, Secret.Wrap(10)
  cooldown:Show()
  Run("UpdateValue secret total", function() region:UpdateValue() end)
  assert(not cooldown:IsShown(), "cooldown shown with a secret total")
  test.Units.SetCombat(false)
end

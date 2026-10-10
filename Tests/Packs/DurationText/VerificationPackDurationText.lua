return function(test)
  local transmit = dofile("Tests/Packs/DurationText/VerificationDurationText.lua")
  local displays = { [transmit.d.id] = transmit.d }
  for _, child in ipairs(transmit.c) do displays[child.id] = child end
  test.Units.DefineUnit("player", { name = "Tester", class = "SHAMAN", level = 17 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  AuraUtil.IsValidFilterString = function(filter) return filter == "HELPFUL|PLAYER" or filter == "HARMFUL|PLAYER" end
  local display = test.Loader.private.BlizzardAuraDisplay
  local checked = 0
  for _, child in ipairs(transmit.c) do
    local trigger = child.triggers[1].trigger
    if trigger.type == "secretAura" then
      local issue = display.Validate(WeakAuras.GetData(child.id))
      assert(issue == nil, child.id .. ": " .. tostring(issue))
      checked = checked + 1
    end
  end
  assert(checked == 7, "secretAura count " .. checked)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
end

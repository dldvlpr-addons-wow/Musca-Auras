return function(test)
  local transmit = dofile("Tests/Packs/CDMCombatFixes/PackCDMCombatFixes.lua")
  local displays = { [transmit.d.id] = transmit.d }
  for _, child in ipairs(transmit.c) do displays[child.id] = child end
  test.Units.DefineUnit("player", { name = "Tester", class = "SHAMAN", level = 17 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  for _, child in ipairs(transmit.c) do
    local data = WeakAuras.GetData(child.id)
    assert(data, child.id .. " not loaded")
    assert(data.triggers[1].trigger.type == "cdm", child.id .. " trigger")
  end
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(1.5)
  assert(#test.Environment.forbidden == 0, "forbidden call: " .. tostring(test.Environment.forbidden[1]))
end

return function(test)
  local transmit = dofile("Tests/Packs/CDMDispel/VerificationCDMProgress.lua")
  local displays = { [transmit.d.id] = transmit.d }
  for _, child in ipairs(transmit.c) do displays[child.id] = child end
  test.Units.DefineUnit("player", { name = "Tester", class = "SHAMAN", level = 17 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  for _, child in ipairs(transmit.c) do
    local data = WeakAuras.GetData(child.id)
    assert(data, child.id .. " not loaded")
    local trigger = data.triggers[1].trigger
    assert(trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff", child.id .. " trigger")
    assert(trigger.cdmSpells.multi[200311], child.id .. " cooldownID")
  end
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
end

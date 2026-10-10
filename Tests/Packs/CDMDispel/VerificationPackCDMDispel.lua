return function(test)
  local transmit = dofile("Tests/Packs/CDMDispel/VerificationCDMDispel.lua")
  local displays = { [transmit.d.id] = transmit.d }
  for _, child in ipairs(transmit.c) do displays[child.id] = child end
  test.Units.DefineUnit("player", { name = "Tester", class = "SHAMAN", level = 17 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)
  for _, child in ipairs(transmit.c) do
    local data = WeakAuras.GetData(child.id)
    assert(data, child.id .. " not loaded")
    assert(data.triggers[1].trigger.type == "cdm", child.id .. " trigger")
    local kinds = {}
    for _, sub in ipairs(data.subRegions) do kinds[sub.type] = true end
    assert(kinds.subcdmdispel or kinds.subcdmdispelborder, child.id .. " sub-regions")
  end
  local subs = WeakAuras.GetData(transmit.c[1].id).subRegions
  local found = {}
  for _, sub in ipairs(subs) do found[#found + 1] = sub.type end
  assert(table.concat(found, ",") == "subbackground,subcdmdispelborder,subcdmdispel,subtext", table.concat(found, ","))
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
end

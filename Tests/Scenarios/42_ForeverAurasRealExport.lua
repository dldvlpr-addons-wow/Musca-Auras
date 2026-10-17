-- A real ForeverAuras export (Simonize Forever Rogue Auras, ForeverAuras 0.44.0-BETA.1): decoded, converted,
-- logged in and played through a combat without any Lua error.
return function(test)
  local file = assert(io.open((test.tocPath:gsub("WeakAuras/WeakAuras%.toc$", "Tests/Fixtures/ForeverAurasExport1.txt"))))
  local exported = file:read("*l")
  file:close()

  -- Decoded and converted before the login, so the pack is the saved aura list of that login,
  -- as after an import then a reload. The player is a Forever rogue (specialization 1488).
  local saved = { displays = {} }
  local count
  test.Units.DefineUnit("player", { class = "ROGUE", powerType = 3 })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(private)
    private.ExecEnv.GetSpecialization = function() return 1 end
    private.ExecEnv.GetSpecializationInfo = function() return 1488 end
    local received = private.StringToTable(exported, true)
    assert(type(received) == "table" and received.m == "d", "export not decoded: " .. tostring(received))
    assert(received.s ~= WeakAuras.versionString, "the fixture is not a foreign export")
    local data, children = received.d, received.c
    assert(private.ConvertForeverAurasImport(data, children), "nothing converted")
    saved.displays[data.id] = data
    for _, child in ipairs(children) do
      saved.displays[child.id] = child
    end
    count = 1 + #children
    -- What ADDON_LOADED runs on the saved auras, here before they were in place.
    private.SyncParentChildRelationships()
    private.ValidateUniqueDataIds(true)
  end)
  assert(count == 37, "expected 37 auras, got " .. tostring(count))

  test.Environment.Advance(5)
  assert(WeakAuras.IsLoginFinished(), "login did not finish")
  for id in pairs(saved.displays) do
    assert(WeakAuras.IsAuraLoaded(id), id .. " not loaded for a rogue")
  end

  -- A combat with a buff from the pack, then back out. The pack's buffs use secretAura, drawn by the
  -- Blizzard aura containers, so only the absence of errors is checked for them.
  test.Units.SetCombat(true)
  test.Environment.Advance(1)
  local energy = WeakAuras.GetRegion("Simonize Rogue Energy")
  assert(energy and energy:IsShown(), "energy bar hidden in combat")
  local sprint = test.Units.ApplyAura("player", { name = "Sprint", spellId = 2983, duration = 15 })
  test.Environment.Advance(2)
  test.Units.RemoveAura("player", sprint)
  test.Environment.Advance(1)
  test.Units.SetCombat(false)
  test.Environment.Advance(2)
end

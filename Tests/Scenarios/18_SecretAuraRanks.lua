-- SecretAuraRanks: rank families, lookup by any rank, catalog consistency.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local battleShout = private.GetAuraSpellRanks(6673)
  assert(table.concat(battleShout, ",") == "6673,5242,6192,11549,11550,11551,25289", "Battle Shout ranks: " .. table.concat(battleShout, ","))
  assert(private.GetAuraSpellRanks(11551) == battleShout, "a higher rank does not give the same family")
  assert(private.AuraSpellRankSupported(6673) and private.AuraSpellRankSupported(25289), "known rank not supported")

  local unknown = private.GetAuraSpellRanks(999999999)
  assert(#unknown == 1 and unknown[1] == 999999999, "unknown ID not returned alone")
  assert(private.GetAuraSpellRanks(999999999) ~= unknown, "unknown ID table shared between calls")
  assert(not private.AuraSpellRankSupported(999999999) and not private.AuraSpellRankSupported(nil), "unknown ID supported")

  local total, owner = 0, {}
  for index, family in ipairs(private.AuraSpellFamilies) do
    assert(#family > 0, "empty family " .. index)
    for _, id in ipairs(family) do
      assert(type(id) == "number" and id > 0 and id == math.floor(id), "bad ID in family " .. index)
      assert(not owner[id], ("ID %d in families %d and %d"):format(id, owner[id] or 0, index))
      owner[id] = index
      assert(private.GetAuraSpellRanks(id) == family, "ID " .. id .. " not mapped to its family")
      total = total + 1
    end
  end

  local catalog = private.AuraSpellCatalogIDs
  assert(#catalog == total, ("catalog has %d IDs, families %d"):format(#catalog, total))
  for index = 2, #catalog do
    assert(catalog[index - 1] < catalog[index], "catalog not sorted at " .. index)
  end
end

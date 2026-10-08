return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  assert(WeakAuras, "WeakAuras global missing")
  assert(type(WeakAurasSaved) == "table", "WeakAurasSaved missing")
  test.Environment.Advance(2)
  assert(private.IsSecret, "Private.IsSecret missing")
end

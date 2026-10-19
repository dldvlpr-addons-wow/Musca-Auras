-- /wa demo: opens the options, then shows every loaded aura, or the named one, with sample states.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local open, opened, shown = false, 0, {}
  WeakAuras.IsOptionsOpen = function() return open end
  WeakAuras.OpenOptions = function() opened = opened + 1; open = true end
  WeakAuras.GetData = function(id) return id == "My Aura" and { id = id } or nil end
  private.ShowDemo = function(id) shown[#shown + 1] = id or "all" end

  SlashCmdList.WEAKAURAS("demo")
  assert(opened == 1 and shown[1] == "all", "demo did not show every loaded aura")

  SlashCmdList.WEAKAURAS("DEMO My Aura ")
  assert(opened == 1, "demo toggled options that were already open")
  assert(shown[2] == "My Aura", "aura name lost its case: " .. tostring(shown[2]))

  local printed = test.WowApi.printed
  local before = #printed
  SlashCmdList.WEAKAURAS("demo Missing")
  assert(#shown == 2 and printed[before + 1]:find("No aura named \"Missing\""), "unknown aura not reported")

  -- Combat: the options stay closed, so nothing is shown and the player is told.
  open = false
  WeakAuras.OpenOptions = function() end
  test.WowApi.inCombat = true
  before = #printed
  SlashCmdList.WEAKAURAS("demo")
  assert(#shown == 2, "demo shown with the options closed")
  assert(printed[before + 1] and printed[before + 1]:find("after combat"), "demo dropped in combat without a message")
end

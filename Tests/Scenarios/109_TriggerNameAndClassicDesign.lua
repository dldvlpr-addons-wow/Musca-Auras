-- Trigger names (Private.TriggerName, Private.TriggerLabel) and the classic design of the options (Style.UseClassic).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {} })
  local Same = test.Assertions.Same

  local data = { triggers = { { trigger = {}, name = "Focus kick" }, { trigger = {}, name = "  " }, { trigger = {} } } }
  Same(private.TriggerName(data, 1), "Focus kick", "named trigger")
  Same(private.TriggerName(data, 2), nil, "blank name: no name")
  Same(private.TriggerName(data, 3), nil, "no name")
  Same(private.TriggerName(data, 9), nil, "missing trigger")
  Same(private.TriggerLabel(data, 1), "Focus kick", "label of a named trigger")
  Same(private.TriggerLabel(data, 3), "Trigger 3", "label keeps the number without a name")

  local Style = private.Style
  local musca = Style.colors.primary
  local brand = Style.colors.link
  Style.UseClassic()
  Same(Style.classic, true, "classic flag")
  -- The fixes run at ADDON_LOADED before the database is set up: one error would stop the addon.
  for index, fix in ipairs(private.classicDesignFixes) do
    local ok, err = pcall(fix)
    Same(ok, true, "classic design fix " .. index .. " runs: " .. tostring(err))
  end
  Same(Style.colors.primary ~= musca, true, "gold of the game replaces the brass")
  Same(Style.colors.link, brand, "colors without a classic value are kept")
  Same(Style.fonts.text, "Fonts\\FRIZQT__.TTF", "font of the game")
end

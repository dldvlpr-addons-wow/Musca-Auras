-- Options preview: a trigger with a fixed duration (Ready Flash) still gets the name and icon of its spell.
return function(test)
  local saved = {
    displays = {
      Flash = {
        id = "Flash", uid = "Flash", regionType = "icon", internalVersion = 91, iconSource = -1,
        triggers = { { trigger = { type = "spell", event = "Cooldown Ready (Spell)", spellName = 1719,
          use_exact_spellName = false, duration = "1.5" }, untrigger = {} }, activeTriggerMode = -10 },
        load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
        animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
        subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
      },
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  C_Spell.GetSpellInfo = function(spellID)
    if spellID == 1719 then return { name = "Recklessness", iconID = 132109, spellID = 1719 } end
  end
  WeakAuras.IsOptionsOpen = function() return true end
  WeakAuras.GetMoverSizerId = function() end
  WeakAuras.ClearAndUpdateOptions = function() end

  private.SetFakeStates()
  private.FakeStatesFor("Flash", true)
  local state = assert(WeakAuras.GetTriggerStateForTrigger("Flash", 1)[""], "no sample state")
  assert(state.duration == 1.5, "fixed duration lost: " .. tostring(state.duration))
  assert(state.icon == 132109, "sample icon: " .. tostring(state.icon))
  assert(state.name == "Recklessness", "sample name: " .. tostring(state.name))
  private.ClearFakeStates()
end

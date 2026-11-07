-- Spell Cast Succeeded with an exact spell ID: the Forever payload of UNIT_SPELLCAST_SUCCEEDED is
-- unitTarget, castGUID, spellID, castBarID, and the trigger filters on spellID, not on castBarID.
-- The trigger function receives the unit before the payload (GenericTrigger.lua, statesParameter "unit"): the first
-- empty arg takes the payload unit, the second the castGUID.
return function(test)
  local data = {
    id = "CastSucceeded", uid = "CastSucceeded", regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "event", event = "Spell Cast Succeeded", unit = "player", use_unit = true,
      use_spellId = true, spellId = { "1464" }, duration = "5" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  test.Units.DefineUnit("player", { class = "WARRIOR" })
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { CastSucceeded = data } })
  test.Environment.Advance(2)

  local function State()
    return WeakAuras.GetTriggerStateForTrigger("CastSucceeded", 1)[""]
  end
  -- Another spell, whose castBarID happens to be the filtered ID: no match.
  WeakAuras.ScanUnitEvents("UNIT_SPELLCAST_SUCCEEDED", "player", "Cast-1", 78, 1464)
  test.Environment.Advance(0.1)
  assert(not State(), "matched on castBarID")
  -- The filtered spell, with any castBarID: match, and the state keeps the spell ID.
  WeakAuras.ScanUnitEvents("UNIT_SPELLCAST_SUCCEEDED", "player", "Cast-2", 1464, 7)
  test.Environment.Advance(0.1)
  local state = State()
  assert(state, "Slam cast not matched")
  assert(state.spellId == 1464, "spellId: " .. tostring(state.spellId))
end

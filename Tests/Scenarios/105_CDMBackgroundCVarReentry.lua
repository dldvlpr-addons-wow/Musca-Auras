-- Hiding Blizzard's CDM with the viewer CVar off writes the CVar once: the CVAR_UPDATE
-- delivered inside SetCVar must not write it again (C stack overflow in game).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local realSetCVar = C_CVar.SetCVar
  local writes = 0
  C_CVar.SetCVar = function(name, value)
    writes = writes + 1
    assert(writes < 10, "SetCVar re-entered from CVAR_UPDATE")
    return realSetCVar(name, value)
  end

  realSetCVar("cooldownViewerEnabled", nil)
  private.db.cdmHideBlizzard = true
  writes = 0
  private.ApplyCDMBackground()

  C_CVar.SetCVar = realSetCVar
  private.db.cdmHideBlizzard = nil

  assert(writes == 1, "expected 1 SetCVar, got " .. writes)
  assert(C_CVar.GetCVarBool("cooldownViewerEnabled"), "viewer CVar not enabled")
end

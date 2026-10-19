-- The player movement watcher runs its OnUpdate only while a loaded aura listens to movement.
local function MovingAura(id)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "unit", event = "Conditions", unit = "player", use_ismoving = true },
      untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { Moving = MovingAura("Moving") } })
  test.Environment.Advance(1)

  assert(WeakAuras.IsAuraLoaded("Moving"), "moving aura not loaded")
  local watcher = private.frames["Player Moving Frame"]
  assert(watcher and watcher:GetScript("OnUpdate"), "movement watcher not running while an aura listens")

  private.UnloadDisplays({ Moving = true })
  test.Environment.Advance(1)
  assert(not watcher:GetScript("OnUpdate"), "movement watcher still running after the last listener unloaded")

  private.LoadDisplays({ Moving = true })
  test.Environment.Advance(1)
  assert(watcher:GetScript("OnUpdate"), "movement watcher not restarted when the aura loads again")
end

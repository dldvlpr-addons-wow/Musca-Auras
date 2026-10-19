-- The load function takes its values by position: a missing load argument shifts every value after it.
local function LoadedAura(id, load)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = load, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Human = LoadedAura("Human", { use_race = true, race = { single = "Human" } }),
    Dwarf = LoadedAura("Dwarf", { use_race = true, race = { single = "Dwarf" } }),
    AnyLevel = LoadedAura("AnyLevel", { use_level = true, level = { "0" }, level_operator = { ">=" } }),
  } })
  test.Environment.Advance(1)

  assert(WeakAuras.IsAuraLoaded("Human"), "race Human aura not loaded")
  assert(not WeakAuras.IsAuraLoaded("Dwarf"), "race Dwarf aura loaded")
  assert(WeakAuras.IsAuraLoaded("AnyLevel"), "level >= 0 aura not loaded")
end

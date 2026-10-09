local function CountedAura(id, load)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = load or {}, conditions = {},
    actions = { start = {}, finish = {}, init = {
      do_custom_load = true, customOnLoad = "LoadCount[aura_env.id] = (LoadCount[aura_env.id] or 0) + 1",
      do_custom_unload = true, customOnUnload = "UnloadCount[aura_env.id] = (UnloadCount[aura_env.id] or 0) + 1",
    } },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  LoadCount, UnloadCount = {}, {}
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Shout = CountedAura("Shout"),
    Never = CountedAura("Never", { use_never = true }),
  } })
  test.Environment.Advance(1)

  local function Counts(id)
    return (LoadCount[id] or 0) .. "/" .. (UnloadCount[id] or 0)
  end
  assert(Counts("Shout") == "1/0", "initial load " .. Counts("Shout"))
  assert(Counts("Never") == "0/0", "never initial " .. Counts("Never"))

  WeakAuras.Add(CopyTable(WeakAuras.GetData("Shout")))
  test.Environment.Advance(0.5)
  assert(Counts("Shout") == "2/1", "full Add on loaded aura " .. Counts("Shout"))
  assert(WeakAuras.IsAuraLoaded("Shout"), "not loaded after full Add")

  WeakAuras.Add(CopyTable(WeakAuras.GetData("Shout")), true)
  test.Environment.Advance(0.5)
  assert(Counts("Shout") == "2/1", "simple Add reloaded " .. Counts("Shout"))

  WeakAuras.Add(CopyTable(WeakAuras.GetData("Never")))
  test.Environment.Advance(0.5)
  assert(Counts("Never") == "0/0", "full Add on unloaded aura " .. Counts("Never"))

  local data = CopyTable(WeakAuras.GetData("Shout"))
  data.load.use_never = true
  WeakAuras.Add(data)
  test.Environment.Advance(0.5)
  assert(Counts("Shout") == "2/2", "full Add to load never " .. Counts("Shout"))
  assert(not WeakAuras.IsAuraLoaded("Shout"), "still loaded after load never")
end

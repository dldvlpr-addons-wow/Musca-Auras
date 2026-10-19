local function Aura(id, triggerType, extra)
  local data = {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = triggerType, unit = "player", debuffType = "HELPFUL", event = "Combat Log",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnAlways" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  for key, value in pairs(extra or {}) do
    data[key] = value
  end
  return data
end

-- Frozen value marker: a padlock on an aura with an Aura trigger while the restriction lasts, unless turned off.
return function(test)
  local saved = { displays = {
    Buff = Aura("Buff", "aura2"),
    Quiet = Aura("Quiet", "aura2", { hideFrozenMarker = true }),
    Small = Aura("Small", "aura2", { width = 20, height = 20 }),
    Other = Aura("Other", "event"),
    Native = Aura("Native", "aura2"),
    Blank = Aura("Blank", "aura2", { regionType = "empty" }),
    Pack = { id = "Pack", uid = "Pack", regionType = "group", internalVersion = 91, controlledChildren = { "Buff" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0 },
  } }
  saved.displays.Buff.parent = "Pack"
  -- Native filters only: the trigger still reads the secret auras, nothing freezes.
  local native = saved.displays.Native.triggers[1].trigger
  native.auraspellids, native.useExactSpellId = nil, nil
  native.useNativeFilter, native.nativeFilter, native.matchesShowOn = true, { PLAYER = true }, "showOnActive"
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Marked(id)
    local marker = WeakAuras.GetRegion(id).frozenMarker
    return marker ~= nil and marker:IsShown()
  end

  assert(WeakAuras.GetRegion("Buff").frozenMarker and not Marked("Buff"), "no padlock out of combat")

  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(Marked("Buff"), "padlock in combat")
  assert(WeakAuras.GetRegion("Buff").frozenMarker:GetWidth() == 14, "full padlock on a 64 wide icon")
  assert(WeakAuras.GetRegion("Small").frozenMarker:GetWidth() == 8, "small padlock on a 20 wide icon")
  assert(not Marked("Quiet") and not Marked("Other"), "no padlock when turned off or without an Aura trigger")
  assert(not Marked("Native"), "no padlock on native filters only")
  assert(not Marked("Blank"), "no padlock on an empty region")
  assert(WeakAuras.GetRegion("Pack").frozenMarker == nil, "no padlock on a group")

  saved.displays.Buff.hideFrozenMarker = true
  WeakAuras.Add(saved.displays.Buff)
  assert(not Marked("Buff"), "padlock hidden at once when turned off in combat")
  test.Units.SetCombat(false)
  test.Units.SetCombat(true)
  test.Environment.Advance(0.5)
  assert(not Marked("Buff"), "turned off padlock stays hidden in the next combat")
  saved.displays.Buff.hideFrozenMarker = nil
  WeakAuras.Add(saved.displays.Buff)

  saved.displays.Quiet.hideFrozenMarker = nil
  WeakAuras.Add(saved.displays.Quiet)
  assert(Marked("Quiet"), "padlock shown at once when turned back on in combat")

  test.Units.SetCombat(false)
  test.Environment.Advance(0.5)
  assert(not Marked("Buff") and not Marked("Quiet"), "padlock gone after combat")
  assert(private.CanFreeze(saved.displays.Buff) and not private.CanFreeze(saved.displays.Other), "option shown for Aura triggers only")
  local fallback = saved.displays.Buff.triggers[1]
  assert(not private.CanFreeze({ id = "Modern", triggers = { { trigger = { type = "secretAura" } }, fallback } }),
    "Modern aura with an Aura fallback follows the Blizzard display")
  assert(not private.CanFreeze({ id = "Viewer", triggers = { { trigger = { type = "cdm" } }, fallback } }),
    "Cooldown Manager aura follows its viewer")
end

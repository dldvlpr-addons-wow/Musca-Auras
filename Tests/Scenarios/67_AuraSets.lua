local function Icon(id, tags, parent)
  return {
    id = id, uid = id, parent = parent, tags = tags, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Group(id, tags, children)
  return {
    id = id, uid = id, tags = tags, regionType = "group", internalVersion = 91, controlledChildren = children,
    load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
end

-- Aura sets: a character with a chosen tag loads only the auras with this tag, themselves or through their group.
-- The choice is kept per "Name-Realm" and read at login.
return function(test)
  local characterKey = UnitName("player") .. "-" .. GetRealmName()
  local saved = {
    displays = {
      Tank = Icon("Tank", "Raid, Tank"),
      Arena = Group("Arena", " PvP ", { "Burst" }),
      Burst = Icon("Burst", nil, "Arena"),
      Plain = Icon("Plain", nil),
      Outer = Group("Outer", "pvp", { "Inner" }),
      Inner = Group("Inner", nil, { "Deep" }),
      Deep = Icon("Deep", nil, "Inner"),
    },
    characterAuraSets = { [characterKey] = "pvp", ["Other-TestRealm"] = "tank" },
  }
  saved.displays.Inner.parent = "Outer"
  -- The name of the player is secret at login: no key, every aura loads until the name is readable.
  local realUnitName = UnitName
  _G.UnitName = function(unit)
    if unit == "player" then
      return test.Secret.Wrap(realUnitName(unit))
    end
    return realUnitName(unit)
  end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Loaded(id)
    return WeakAuras.IsAuraLoaded(id) == true
  end

  assert(private.GetCharacterAuraSet() == nil and Loaded("Plain"), "secret name: every aura loads")
  _G.UnitName = realUnitName
  assert(private.GetCharacterAuraSet() == "pvp", "choice of this character read once the name is readable")
  test.Environment.Advance(0.5)
  assert(Loaded("Burst") and not Loaded("Tank") and not Loaded("Plain"), "only the auras of the set load, by group")
  assert(Loaded("Deep"), "tag of a group two levels up")

  assert(private.SetCharacterAuraSet(" TANK "), "set changed")
  test.Environment.Advance(0.5)
  assert(saved.characterAuraSets[characterKey] == "tank", "tag trimmed and lowered")
  assert(Loaded("Tank") and not Loaded("Burst") and not Loaded("Plain"), "own tag among several")

  assert(private.SetCharacterAuraSet(" #PvP") and saved.characterAuraSets[characterKey] == "pvp", "search syntax accepted")
  test.Environment.Advance(0.5)
  assert(Loaded("Burst") and not Loaded("Tank"), "#tag names the same tag")

  assert(private.SetCharacterAuraSet(""), "set cleared")
  test.Environment.Advance(0.5)
  assert(saved.characterAuraSets[characterKey] == nil and saved.characterAuraSets["Other-TestRealm"] == "tank",
    "cleared for this character only")
  assert(Loaded("Tank") and Loaded("Burst") and Loaded("Plain"), "no set: every aura loads")
end

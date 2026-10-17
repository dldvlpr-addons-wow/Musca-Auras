local function Icon(id, extra)
  local data = {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  for key, value in pairs(extra or {}) do
    data[key] = value
  end
  return data
end

local function Group(id, children)
  local data = Icon(id)
  data.regionType, data.controlledChildren, data.triggers = "group", children, nil
  return data
end

local function Same(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then
    return a == b
  end
  for key, value in pairs(a) do
    if not Same(value, b[key]) then
      return false
    end
  end
  for key in pairs(b) do
    if a[key] == nil then
      return false
    end
  end
  return true
end

-- A realistic WeakAurasSaved: a group with children, an aura from an old version that goes through
-- migrations, and an aura with corrupt data that makes its migration throw.
return function(test)
  local saved = { displays = {
    HUD = Group("HUD", { "Rage", "Shout" }),
    Rage = Icon("Rage", { parent = "HUD" }),
    Shout = Icon("Shout", { parent = "HUD" }),
    Old = Icon("Old", { internalVersion = 80 }),
    Corrupt = Icon("Corrupt", { triggers = "corrupt" }),
  } }
  local expected = {}
  for id, data in pairs(saved.displays) do
    expected[id] = data.uid
  end

  -- Break a step that runs after AddMany, so the login thread dies mid-login.
  local private, injected
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate)
    private = addonPrivate
    private.RegisterLoadEvents = function()
      injected = true
      error("login step failed")
    end
  end)
  test.Environment.Advance(5)
  assert(injected, "the injected login error never ran")
  assert(not WeakAuras.IsLoginFinished(), "login was expected to stop on the injected error")

  -- A failed migration may leave the aura half rewritten; the rollback snapshot keeps the original.
  -- Read it before logout: Archivist closes its stores on PLAYER_LOGOUT.
  local snapshot = private.GetMigrationSnapshot("Corrupt")
  assert(snapshot and snapshot.triggers == "corrupt", "no rollback snapshot of the corrupt aura")
  assert(#private.ListBackups() == 0, "a login that died took a daily copy")

  local beforeLogout = CopyTable(saved.displays)
  test.Frames.Fire("PLAYER_LOGOUT")

  assert(rawget(_G, "WeakAurasSaved") == saved, "WeakAurasSaved replaced by another table")
  assert(type(saved.displays) == "table", "displays table lost")
  for id, uid in pairs(expected) do
    local data = saved.displays[id]
    assert(data, "aura lost on logout: " .. id)
    assert(data.id == id and data.uid == uid, "aura identity changed: " .. id)
  end
  for id in pairs(saved.displays) do
    assert(expected[id], "unexpected aura in saved displays: " .. tostring(id))
  end
  assert(saved.displays.HUD.controlledChildren[1] == "Rage" and saved.displays.HUD.controlledChildren[2] == "Shout",
    "group children changed")
  local rage = saved.displays.Rage
  assert(rage.triggers[1].trigger.auraspellids[1] == "6673" and rage.width == 64, "aura settings lost during login")
  assert(Same(beforeLogout, saved.displays), "aura content changed on logout")

  -- The errors provoked above are expected; any other error stays a failure.
  local expectedErrors = { "login step failed", "Aura 'Corrupt': Modernize" }
  local remaining = {}
  for _, message in ipairs(test.Environment.errors) do
    local known = false
    for _, pattern in ipairs(expectedErrors) do
      known = known or message:find(pattern, 1, true) ~= nil
    end
    if not known then
      remaining[#remaining + 1] = message
    end
  end
  test.Environment.errors = remaining
end

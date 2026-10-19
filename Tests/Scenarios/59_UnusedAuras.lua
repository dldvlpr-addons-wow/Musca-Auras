local function Icon(id, parent, load)
  return {
    id = id, uid = id, parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = load or { use_never = true }, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Group(id, children)
  return {
    id = id, uid = id, regionType = "group", internalVersion = 91, controlledChildren = children,
    load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
end

local DAY = 86400

-- Unused auras: no load on the account for 30 days, a whole unused group in place of its auras, empty groups.
-- Deleted auras go to the archive and can be imported again.
return function(test)
  local now = time()
  local saved = {
    loadTrackingSince = now - 60 * DAY,
    lastLoadedDate = { Old = now - 40 * DAY, Recent = now - 5 * DAY, DeadA = now - 40 * DAY, DeadB = now - 40 * DAY,
      MixedOld = now - 40 * DAY },
    displays = {
      Shout = Icon("Shout", nil, {}),
      Old = Icon("Old"),
      Recent = Icon("Recent"),
      Untracked = Icon("Untracked"),
      Dead = Group("Dead", { "DeadA", "DeadB" }),
      DeadA = Icon("DeadA", "Dead"),
      DeadB = Icon("DeadB", "Dead"),
      Mixed = Group("Mixed", { "MixedOld", "MixedLive" }),
      MixedOld = Icon("MixedOld", "Mixed"),
      MixedLive = Icon("MixedLive", "Mixed", {}),
      Empty = Group("Empty", {}),
    },
  }
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate)
    private = addonPrivate
  end)
  test.Environment.Advance(5)
  assert(WeakAuras.IsAuraLoaded("Shout"), "Shout not loaded")
  assert(saved.lastLoadedDate.Shout and saved.lastLoadedDate.Shout >= now, "load date not written")

  local ids, since = private.FindUnusedAuras(30)
  assert(since == saved.loadTrackingSince, "tracking start")
  -- An aura without a load date counts as loaded when it is added, as a new or imported aura.
  assert(saved.lastLoadedDate.Untracked and saved.lastLoadedDate.Untracked >= now, "added aura without a date")
  local found = table.concat(ids, ",")
  assert(found == "Dead,Empty,MixedOld,Old", found)

  -- A deleted aura is archived, listed by the slash command and imported again on request.
  assert(private.ArchiveDeletedAura("Dead"), "archive failed")
  WeakAuras.Delete(WeakAuras.GetData("Old"))
  assert(saved.lastLoadedDate.Old == nil, "load date kept after delete")
  local list = private.ListDeletedAuras()
  assert(#list == 1 and list[1].id == "Dead" and list[1].key:find("^Dead%-%d+$"), "deleted aura not listed")

  local printed = test.WowApi.printed
  local before = #printed
  SlashCmdList.WEAKAURAS("deleted")
  assert(printed[before + 1]:find("^1%. Dead, "), "deleted auras not listed in the chat")
  local imported
  WeakAuras.Import = function(text) imported = text end
  SlashCmdList.WEAKAURAS("undelete 2")
  assert(not imported, "imported an aura that does not exist")
  SlashCmdList.WEAKAURAS("undelete 1")
  assert(type(imported) == "string" and imported:find("^!WA:2!"), "undelete did not import the export string")
  local decoded = private.StringToTable(imported, true)
  assert(type(decoded) == "table" and decoded.d.id == "Dead" and #decoded.c == 2, "export string lost the group")

  -- The same aura deleted again, after an import that kept its uid, gets a second copy.
  local realTime = _G.time
  _G.time = function() return now + 5 end
  -- Tags are not exported: the archive keeps them and the undelete puts them back.
  WeakAuras.GetData("Dead").tags = "raid"
  WeakAuras.GetData("DeadA").tags = "tank"
  assert(private.ArchiveDeletedAura("Dead"), "second archive failed")
  _G.time = realTime
  assert(#private.ListDeletedAuras() == 2, "second archive replaced the first one")
  imported = nil
  SlashCmdList.WEAKAURAS("undelete 1")
  assert(type(imported) == "table" and imported.d.tags == "raid", "undelete lost the tags of the group")
  local childTags = {}
  for _, child in ipairs(imported.c) do childTags[child.id] = child.tags or false end
  assert(childTags.DeadA == "tank" and childTags.DeadB == false, "undelete lost the tags of the members")

  -- Entries older than 30 days are dropped.
  _G.time = function() return now + 31 * DAY end
  assert(#private.ListDeletedAuras() == 0, "old deleted aura kept")
  _G.time = realTime
end

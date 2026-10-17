local function Icon(id)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local DAY = 86400

-- Daily copies of the saved auras: taken after login, one per day, three kept, restored on request.
return function(test)
  local saved = { displays = { Rage = Icon("Rage"), Shout = Icon("Shout") } }
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate)
    private = addonPrivate
  end)
  test.Environment.Advance(5)
  assert(WeakAuras.IsLoginFinished(), "login did not finish")

  local list = private.ListBackups()
  assert(#list == 1 and list[1].auraCount == 2, "no copy after login")
  local firstKey = list[1].key
  local repo = WeakAuras.LoadFromArchive("Repository", "backups")
  local copy = repo:GetData(firstKey)
  assert(copy.Rage.width == 64 and copy.Shout.triggers[1].trigger.auraspellids[1] == "6673", "copy content differs")
  repo:Get(firstKey):Close()

  -- The copy is frozen: a later edit of the aura does not reach it.
  saved.displays.Rage.width = 99
  assert(repo:GetData(firstKey).Rage.width == 64, "the copy follows the live auras")
  repo:Get(firstKey):Close()

  private.BackupDisplays(saved.displays)
  assert(#private.ListBackups() == 1, "second copy on the same day")

  local now, realTime = time(), _G.time
  for day = 1, 3 do
    _G.time = function() return now + day * DAY end
    private.BackupDisplays(saved.displays)
  end
  list = private.ListBackups()
  assert(#list == 3, "expected three copies, got " .. #list)
  assert(list[1].key == date("%Y-%m-%d", now + 3 * DAY), "newest copy is not first")
  for _, backup in ipairs(list) do
    assert(backup.key ~= firstKey, "the oldest copy was kept")
  end

  -- An empty aura list never pushes a good copy out.
  _G.time = function() return now + 4 * DAY end
  private.BackupDisplays({})
  assert(#private.ListBackups() == 3 and private.ListBackups()[1].key == list[1].key, "an empty list was copied")

  -- A copy that fails half-way leaves no entry behind, and the error still shows.
  local realSet = repo.Set
  repo.Set = function(self, id) self.stores[id] = {}; error("archive full") end
  local ok, err = pcall(private.BackupDisplays, saved.displays)
  repo.Set = realSet
  assert(not ok and err:find("archive full"), "the failed copy was silent")
  assert(#private.ListBackups() == 3 and not repo.stores[date("%Y-%m-%d", now + 4 * DAY)], "a half-made copy was kept")
  _G.time = realTime

  -- The slash commands list the copies and ask before a restore.
  local printed = test.WowApi.printed
  local before = #printed
  SlashCmdList.WEAKAURAS("backups")
  assert(#printed - before >= 3 and printed[before + 1]:find("^1%. .*, 2 auras$"), "backups not listed")
  local popup
  _G.StaticPopup_Show = function(which, _, count, key) popup = { which = which, count = count, key = key } end
  SlashCmdList.WEAKAURAS("restore 9")
  assert(not popup, "restore asked for a copy that does not exist")
  SlashCmdList.WEAKAURAS("restore 2")
  assert(popup and popup.which == "WEAKAURAS_CONFIRM_RESTORE" and popup.key == list[2].key and popup.count == 2,
    "restore did not ask for the second copy")

  local reloaded = false
  _G.ReloadUI = function() reloaded = true end
  local oldDisplays = saved.displays
  assert(not private.RestoreBackup("missing", saved), "restored an unknown copy")
  assert(not reloaded and saved.displays == oldDisplays, "a failed restore changed the auras")
  assert(private.RestoreBackup(list[3].key, saved), "restore failed")
  assert(reloaded, "the UI did not reload after a restore")
  assert(saved.displays ~= oldDisplays and saved.displays.Rage.width == 99 and saved.displays.Shout,
    "restored auras differ from the copy")
end

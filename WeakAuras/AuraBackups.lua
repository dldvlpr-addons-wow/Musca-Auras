-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Daily copies of the saved auras in WeakAurasArchive, taken after a login that went to the end.
-- An empty aura list is never copied, so it can't push the good copies out.

local KEEP = 3
local repo

-- nil and the reason when the archive addon can't load (disabled by the user).
local function Backups()
  if not repo then
    local ok, loaded = pcall(WeakAuras.LoadFromArchive, "Repository", "backups")
    if not ok then
      return nil, loaded
    end
    repo = loaded
  end
  return repo
end

-- Newest first.
function Private.ListBackups()
  local backups, reason = Backups()
  if not backups then
    return nil, reason
  end
  local list = {}
  for key, subStore in pairs(backups.stores) do
    list[#list + 1] = { key = key, timestamp = subStore.timestamp, auraCount = subStore.auraCount or 0 }
  end
  table.sort(list, function(a, b) return a.timestamp > b.timestamp end)
  return list
end

-- ponytail: the archive serializes the whole aura list in one go, once a day; split it if big saves stutter.
function Private.BackupDisplays(displays)
  local count = 0
  for _ in pairs(displays) do
    count = count + 1
  end
  local backups = Backups()
  local key = date("%Y-%m-%d", time())
  if count == 0 or not backups or backups.stores[key] then
    return
  end
  local ok, copy = pcall(backups.Set, backups, key, displays)
  if not ok then
    -- The half-made entry has no archive id, it would break the list until the next login.
    backups.stores[key] = nil
    error(copy, 0)
  end
  copy.auraCount = count
  -- Closed at once: the open store is the live aura list, a later read must come from the archive.
  copy:Close()
  local list = Private.ListBackups()
  for index = KEEP + 1, #list do
    backups:Drop(list[index].key)
  end
end

-- The UI reloads at once, so the copy becomes the aura list of the next login.
function Private.RestoreBackup(key, db)
  local backups = Backups()
  local displays = backups and backups:GetData(key)
  if type(displays) ~= "table" then
    return false
  end
  -- Saved custom data goes back into the old auras now, so the logout of the reload can't write it into the copy.
  for id in pairs(db.displays) do
    Private.ClearAuraEnvironment(id)
  end
  db.displays = CopyTable(displays)
  ReloadUI()
  return true
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Daily copies of the saved auras in WeakAurasArchive, taken after a login that went to the end.
-- An empty aura list is never copied, so it can't push the good copies out.

local KEEP = 3
local DELETED_DAYS = 30
local repositories = {}

-- nil and the reason when the archive addon can't load (disabled by the user).
local function OpenRepository(storeID)
  if not repositories[storeID] then
    local ok, loaded = pcall(WeakAuras.LoadFromArchive, "Repository", storeID)
    if not ok then
      return nil, loaded
    end
    repositories[storeID] = loaded
  end
  return repositories[storeID]
end

local function Backups()
  return OpenRepository("backups")
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

-- Deleted auras stay in the archive as export strings for DELETED_DAYS, to be imported again.
-- nil and the reason when the archive addon can't load.
local function DeletedAuras()
  local deleted, reason = OpenRepository("deleted")
  if deleted then
    deleted:Clean(time() - DELETED_DAYS * 86400)
  end
  return deleted, reason
end

-- Called before the deletion, with a group the export string holds its auras.
-- false when it could not be kept, nil without the archive addon.
function Private.ArchiveDeletedAura(id)
  local deleted = DeletedAuras()
  if not deleted then
    return nil
  end
  local ok, export = pcall(Private.DisplayToString, id, true)
  if not ok or type(export) ~= "string" or export == "" then
    return false
  end
  -- An import keeps the uid, the same aura deleted twice gets two copies
  local key = WeakAuras.GetData(id).uid .. "-" .. time()
  -- Tags are not exported (non_transmissable_fields): kept beside the export, by uid.
  local tags
  for child in Private.TraverseAll(WeakAuras.GetData(id)) do
    if child.tags then
      tags = tags or {}
      tags[child.uid] = child.tags
    end
  end
  local copy
  ok, copy = pcall(deleted.Set, deleted, key, { id = id, export = export, tags = tags })
  if not ok then
    deleted.stores[key] = nil
    return false
  end
  copy.auraId = id
  copy:Close()
  return true
end

-- Newest first.
function Private.ListDeletedAuras()
  local deleted, reason = DeletedAuras()
  if not deleted then
    return nil, reason
  end
  local list = {}
  for key, subStore in pairs(deleted.stores) do
    list[#list + 1] = { key = key, timestamp = subStore.timestamp, id = subStore.auraId }
  end
  table.sort(list, function(a, b) return a.timestamp > b.timestamp or a.timestamp == b.timestamp and a.key < b.key end)
  return list, DELETED_DAYS
end

-- Opens the import window on the deleted aura.
function Private.RestoreDeletedAura(key)
  local deleted = DeletedAuras()
  local copy = deleted and deleted:GetData(key)
  if type(copy) ~= "table" or type(copy.export) ~= "string" then
    return false
  end
  local received = type(copy.tags) == "table" and Private.StringToTable(copy.export, true)
  if type(received) == "table" and type(received.d) == "table" then
    received.d.tags = copy.tags[received.d.uid]
    for _, child in ipairs(received.c or {}) do
      child.tags = copy.tags[child.uid]
    end
    WeakAuras.Import(received)
  else
    WeakAuras.Import(copy.export)
  end
  return true
end

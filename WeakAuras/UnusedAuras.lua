-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Auras that no character of the account loaded for a number of days, and empty groups.
-- db.lastLoadedDate holds the date of the last load of each aura by uid, written by LoadDisplays.
-- An aura never loaded since db.loadTrackingSince counts from that date.

-- A group is unused when all its auras are, an empty group too.
local function IsUnused(data, cutoff)
  if data.controlledChildren then
    for _, childId in ipairs(data.controlledChildren) do
      local child = WeakAuras.GetData(childId)
      if child and not IsUnused(child, cutoff) then
        return false
      end
    end
    return true
  end
  local db = Private.db
  return Private.loaded[data.id] ~= true and (db.lastLoadedDate[data.uid] or db.loadTrackingSince) < cutoff
end

local function Collect(data, cutoff, ids)
  if IsUnused(data, cutoff) then
    tinsert(ids, data.id)
  elseif data.controlledChildren then
    for _, childId in ipairs(data.controlledChildren) do
      local child = WeakAuras.GetData(childId)
      if child then
        Collect(child, cutoff, ids)
      end
    end
  end
end

-- Ids of the unused auras, a group in place of its auras when the whole group is unused, then the tracking start.
function Private.FindUnusedAuras(days)
  local cutoff = time() - days * 86400
  local ids = {}
  for _, data in pairs(Private.db.displays) do
    if not data.parent then
      Collect(data, cutoff, ids)
    end
  end
  table.sort(ids, function(a, b) return a:lower() < b:lower() end)
  return ids, Private.db.loadTrackingSince
end

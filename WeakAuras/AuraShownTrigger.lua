-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L

-- Trigger "Aura Shown": active while another aura is shown. The watched aura is stored by uid, so a rename keeps the
-- link. GenericTrigger wakes the watchers through the event "WA_AURA_SHOWN:<uid>" one frame after the watched aura
-- shows or hides. An aura caught in a loop of these triggers (A watches B, B watches A) never activates: it would
-- flip every frame.

local eventName = "Aura Shown"

-- Whether the aura with this uid watches, directly or through other "Aura Shown" triggers, the aura with targetUid.
local function Watches(uid, targetUid, visited)
  if visited[uid] then
    return false
  end
  visited[uid] = true
  local data = Private.GetDataByUID(uid)
  for _, triggerData in ipairs(data and data.triggers or {}) do
    local trigger = triggerData.trigger
    if trigger and trigger.type == "event" and trigger.event == eventName and type(trigger.auraUid) == "string"
      and (trigger.auraUid == targetUid or Watches(trigger.auraUid, targetUid, visited)) then
      return true
    end
  end
  return false
end

--- Whether the watched aura is shown, nil when no aura is chosen or when it watches back the watcher: the two would
--- flip every frame.
function Private.ExecEnv.IsWatchedAuraShown(watchedUid, watcherId)
  if watchedUid == "" then
    return nil
  end
  local watcher = watcherId and WeakAuras.GetData(watcherId)
  if watcher and watcher.uid and (watchedUid == watcher.uid or Watches(watchedUid, watcher.uid, {})) then
    return nil
  end
  return Private.IsAuraActive(watchedUid) and true or false
end

--- Points the "Aura Shown" triggers of this aura at the new uids of the auras that got one, from newUids[oldUid].
--- Returns whether a trigger changed.
function Private.RemapWatchedAuras(data, newUids)
  local changed = false
  for _, triggerData in ipairs(data.triggers or {}) do
    local trigger = triggerData.trigger
    if trigger and trigger.type == "event" and trigger.event == eventName and newUids[trigger.auraUid] then
      trigger.auraUid = newUids[trigger.auraUid]
      changed = true
    end
  end
  return changed
end

-- Any other value than a uid, from a broken import, watches nothing.
local function WatchedUid(trigger)
  return type(trigger.auraUid) == "string" and trigger.auraUid or ""
end

local function AuraChoices()
  local choices = {}
  for _, data in pairs(WeakAurasSaved.displays) do
    if data.uid and not data.controlledChildren then
      choices[data.uid] = data.id
    end
  end
  return choices
end

Private.event_prototypes[eventName] = {
  type = "event",
  events = {},
  internal_events = function(trigger)
    return { "WA_AURA_SHOWN:" .. WatchedUid(trigger) }
  end,
  force_events = "WA_AURA_SHOWN",
  name = L["Aura Shown"],
  statesParameter = "one",
  init = function(trigger)
    return ("local shown = Private.ExecEnv.IsWatchedAuraShown(%q, aura_env and aura_env.id)\n"
      .. "local active = shown ~= nil and shown ~= %s\n")
      :format(WatchedUid(trigger), trigger.use_inverse and "true" or "false")
  end,
  args = {
    {
      name = "auraUid",
      display = L["Aura"],
      type = "select",
      values = AuraChoices,
      sorted = true,
      required = true,
      test = "true",
    },
    {
      name = "inverse",
      display = L["Inverse"],
      type = "toggle",
      test = "true",
    },
    {
      name = "note",
      type = "description",
      display = "",
      text = L["Follows the chosen aura one frame later. Auras that watch each other in a loop never show."],
    },
    {
      hidden = true,
      test = "active",
    },
  },
  automaticrequired = true,
  progressType = "none",
}
Private.category_event_prototype.event[eventName] = L["Aura Shown"]

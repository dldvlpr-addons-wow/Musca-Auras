-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Chat reports of /wa modern and /wa cdm <aura>: what an aura tracks and shows right now.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local L = WeakAuras.L
local prettyPrint = WeakAuras.prettyPrint

local function Readable(value)
  if Private.IsSecret(value) then
    return "secret"
  end
  return tostring(value)
end

local function TriggersOfType(data, triggerType)
  local found = {}
  for index, entry in ipairs(data.triggers or {}) do
    if type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type == triggerType then
      found[#found + 1] = index
    end
  end
  return found
end

local function IsShown(id)
  local entry = Private.regions[id]
  return entry and entry.region and entry.region:IsShown() == true
end

-- One line per active state of a loaded aura's trigger.
local function PrintStates(id, index, fields)
  if not Private.loaded[id] then
    return
  end
  local states = WeakAuras.GetTriggerStateForTrigger(id, index)
  local count = 0
  for cloneId, state in pairs(states) do
    if state.show then
      count = count + 1
      local parts = { "  " .. Readable(cloneId ~= "" and cloneId or "-") .. ":" }
      for _, field in ipairs(fields) do
        if state[field] ~= nil then
          parts[#parts + 1] = field .. "=" .. Readable(state[field])
        end
      end
      print(table.concat(parts, " "))
    end
  end
  print("  " .. L["Active states: %d"]:format(count))
end

local function Status(id)
  if not Private.loaded[id] then
    return L["not loaded"]
  end
  return IsShown(id) and L["shown"] or L["hidden"]
end

local MODERN_FIELDS = { "unit", "spellId", "name", "stacks", "duration", "expirationTime" }

function Private.PrintModernStatus(id)
  if id then
    local data = WeakAuras.GetData(id)
    local triggers = data and TriggersOfType(data, "secretAura") or {}
    if #triggers == 0 then
      prettyPrint(L["%q has no Aura Modern trigger."]:format(id))
      return
    end
    prettyPrint(("%s: %s"):format(id, Status(id)))
    for _, index in ipairs(triggers) do
      local trigger = data.triggers[index].trigger
      print(L["Trigger %d: unit %s"]:format(index, tostring(trigger.unit)))
      PrintStates(id, index, MODERN_FIELDS)
    end
    return
  end
  local ids = {}
  for auraId, data in pairs(Private.db.displays) do
    if #TriggersOfType(data, "secretAura") > 0 then
      ids[#ids + 1] = auraId
    end
  end
  table.sort(ids)
  prettyPrint(L["Auras with an Aura Modern trigger: %d"]:format(#ids))
  for _, auraId in ipairs(ids) do
    print(("  %s: %s"):format(auraId, Status(auraId)))
  end
end

local CDM_FIELDS = { "spellId", "itemId", "auraActive", "stacks", "duration", "expirationTime" }

function Private.PrintCooldownManagerTriggerStatus(id)
  local data = WeakAuras.GetData(id)
  local triggers = data and TriggersOfType(data, "cdm") or {}
  if #triggers == 0 then
    prettyPrint(L["%q has no Cooldown Manager trigger."]:format(id))
    return
  end
  prettyPrint(("%s: %s"):format(id, Status(id)))
  for _, index in ipairs(triggers) do
    local trigger = data.triggers[index].trigger
    print(L["Trigger %d: %s"]:format(index, tostring(trigger.event)))
    PrintStates(id, index, CDM_FIELDS)
  end
end

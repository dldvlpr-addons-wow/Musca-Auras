-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local IsSecretAuraTrigger = Shared.IsSecretAuraTrigger
local Listed = Shared.Listed
local TriggerEntries = Shared.TriggerEntries
local classificationFlags = Shared.classificationFlags

local function SpellListEnabled(forced, list)
  if forced == false then return false end
  return forced == true or (type(list) == "table" and next(list) ~= nil)
end

Display.UsesSpellIDs = function(trigger)
  return SpellListEnabled(trigger.secretUseSpellIDs, trigger.auraspellids)
end

Display.UsesExcludedSpellIDs = function(trigger)
  return SpellListEnabled(trigger.secretUseExcludedSpellIDs, trigger.excludedAuraSpellIDs)
end

Display.UsesRankSpellIDs = function(trigger)
  return true == trigger.secretUseRankSpellIDs
end

local SPELL_ID_CEILING = 2147483647

Display.GetSpellIDs = function(trigger, withRanks)
  local ids, seen = {}, {}
  local function Take(value)
    local id = tonumber(value)
    if not id or id <= 0 or id >= SPELL_ID_CEILING or id ~= math.floor(id) then return end
    if not seen[id] then
      seen[id] = true
      ids[#ids + 1] = id
    end
    return id
  end
  local usesRanks, usesIDs = Display.UsesRankSpellIDs(trigger), Display.UsesSpellIDs(trigger)
  if usesRanks then
    for _, value in ipairs(Listed(trigger.auraRankSpellIDs)) do
      local id = Take(value)
      if id and withRanks then
        for _, rankID in ipairs(Private.GetAuraSpellRanks(id) or {}) do Take(rankID) end
      end
    end
  end
  if usesIDs then
    for _, value in ipairs(trigger.auraspellids or {}) do Take(value) end
  end
  return ids
end

local HELPFUL_FILTERS = { CANCELABLE = true, EXTERNAL_DEFENSIVE = true, BIG_DEFENSIVE = true, IMPORTANT = true, isStealable = true }
local HARMFUL_FILTERS = { CROWD_CONTROL = true, isPriorityAura = true, isBossAura = true, isRoleAura = true, isBossOrRoleAura = true }

Display.FilterApplies = function(key, trigger)
  if HELPFUL_FILTERS[key] then return trigger.debuffType == "HELPFUL" end
  if HARMFUL_FILTERS[key] then return trigger.debuffType == "HARMFUL" end
  return true
end

Display.FilterString = function(trigger)
  local segments = { trigger.debuffType }
  local chosen = Listed(trigger.nativeFilters)
  for _, row in ipairs(Display.nativeFilters) do
    local key = row[1]
    local value = chosen[key]
    if value ~= nil and Display.FilterApplies(key, trigger) then
      segments[#segments + 1] = value and key or "!" .. key
    end
  end
  if trigger.includeNameplateOnly and trigger.unit == "nameplate" then
    segments[#segments + 1] = "INCLUDE_NAME_PLATE_ONLY"
  end
  return table.concat(segments, "|")
end

local function WithoutClassification(saved, dropFlags)
  local copy = CopyTable(saved)
  copy.processedAuraType = nil
  if copy.sortMethod == "UnitFrameDebuff" then copy.sortMethod = "Default" end
  if dropFlags then
    for _, flag in ipairs(classificationFlags) do copy[flag[1]] = nil end
  end
  return copy
end

local unclassifiedCopies = setmetatable({}, { __mode = "k" })

local function ForgetClassifiedTriggers(data)
  for _, entry in ipairs(TriggerEntries(data)) do
    if type(entry) == "table" and entry.trigger then unclassifiedCopies[entry.trigger] = nil end
  end
end

Display.GetSavedTrigger = function(data)
  local triggerList = data and data.triggers
  if type(triggerList) ~= "table" then return end
  local position = data.progressSource and data.progressSource[1] or -1
  if position == 0 then return end
  if position < 0 then
    position = triggerList.activeTriggerMode or -1
    if position < 0 then
      position = Private.GetActiveTriggerFor and Private.GetActiveTriggerFor(data.id) or 1
    end
  end
  local entry = triggerList[position]
  if IsSecretAuraTrigger(entry) then return entry.trigger end
end

Display.GetTrigger = function(data, forValidation)
  local source = Display.GetSavedTrigger(data)
  if not source then return end
  if forValidation then return WithoutClassification(source, true) end
  if not (source.processedAuraType or source.sortMethod == "UnitFrameDebuff") then return source end
  local copy = unclassifiedCopies[source]
  if not copy then
    copy = WithoutClassification(source)
    unclassifiedCopies[source] = copy
  end
  return copy
end

Display.HasTrigger = function(data)
  for _, entry in ipairs(TriggerEntries(data)) do
    if IsSecretAuraTrigger(entry) then return true end
  end
  return false
end

local REGION_TYPES = { icon = true, aurabar = true, text = true, progresstexture = true }

Display.SupportsRegionType = function(regionType)
  return REGION_TYPES[regionType] == true
end

Display.Eligible = function(data)
  return data and Display.SupportsRegionType(data.regionType) and Display.GetTrigger(data) ~= nil
end

Display.Enabled = function(data)
  return not not Display.Eligible(data)
end

Display.UsesNameplates = function(data)
  if data.anchorFrameType == "NAMEPLATE" then return true end
  local current = Display.GetTrigger(data)
  return current ~= nil and current.unit == "nameplate"
end

Display.Elements = function(displayOptions)
  if not displayOptions.elements then
    local names = { "border" }
    if displayOptions.glow then names[#names + 1] = "glow" end
    if displayOptions.duration ~= false then names[#names + 1] = "duration" end
    if displayOptions.stacks ~= false then names[#names + 1] = "stack" end
    if displayOptions.label and displayOptions.label ~= "" then names[#names + 1] = "label" end
    displayOptions.elements = names
  end
  return displayOptions.elements
end

Shared.ForgetClassifiedTriggers = ForgetClassifiedTriggers

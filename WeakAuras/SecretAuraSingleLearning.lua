-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local Clear = Shared.Clear
local FRIENDLY_CATEGORIES = Shared.FRIENDLY_CATEGORIES
local GATE_TOLERANCE = Shared.GATE_TOLERANCE
local HOSTILE_CATEGORIES = Shared.HOSTILE_CATEGORIES
local IsSecret = Shared.IsSecret
local IsTable = Shared.IsTable
local PROFILE_FLAGS = Shared.PROFILE_FLAGS
local ReadableNumber = Shared.ReadableNumber
local SCAN_SLOTS = Shared.SCAN_SLOTS
local SavedTable = Shared.SavedTable
local Tenth = Shared.Tenth

local neverSecretVerdicts = {}

local function IsNeverSecret(spellId)
  local cached = neverSecretVerdicts[spellId]
  if cached ~= nil then return cached end
  local frameLevel = Enum.SecrecyLevel and Enum.SecrecyLevel.NeverSecret
  if frameLevel == nil or not (C_Secrets and C_Secrets.GetSpellAuraSecrecy) then return false end
  local ok, result = pcall(C_Secrets.GetSpellAuraSecrecy, spellId)
  local verdict = ok and not IsSecret(result) and result == frameLevel
  neverSecretVerdicts[spellId] = verdict
  return verdict
end

local function FilterNoteIDs(auraTrigger)
  local ids = {}
  for _, spellId in ipairs(AuraDisplay.GetSpellIDs(auraTrigger, true)) do ids[#ids + 1] = spellId end
  if AuraDisplay.UsesExcludedSpellIDs(auraTrigger) then
    for _, spellId in ipairs(auraTrigger.excludedAuraSpellIDs or {}) do
      local number = tonumber(spellId)
      if number then ids[#ids + 1] = number end
    end
  end
  return ids
end

local function AllNeverSecret(ids)
  if #ids == 0 then return false end
  for _, spellId in ipairs(ids) do
    if not IsNeverSecret(spellId) then return false end
  end
  return true
end

function AuraDisplay.SpellIDFilterNote(auraTrigger)
  if not (AuraDisplay.UsesSpellIDs(auraTrigger) or AuraDisplay.UsesRankSpellIDs(auraTrigger) or AuraDisplay.UsesExcludedSpellIDs(auraTrigger)) then return end
  if AuraDisplay.UsesApproximate(auraTrigger) then return end
  if AllNeverSecret(FilterNoteIDs(auraTrigger)) then return end
  local debuff = auraTrigger.debuffType == "HARMFUL"
  local unitCategory = AuraDisplay.UnitCategory(auraTrigger)
  local friendly, hostile = FRIENDLY_CATEGORIES[unitCategory], HOSTILE_CATEGORIES[unitCategory]
  local noun = debuff and "debuffs" or "buffs"
  if (debuff and friendly) or (not debuff and hostile) then
    local label = auraTrigger.unit == "member" and AuraDisplay.SpecificUnit(auraTrigger) or AuraDisplay.units[auraTrigger.unit] or auraTrigger.unit
    local message = ("In combat Blizzard keeps %s on %s out of spell ID filters."):format(noun, tostring(label))
    if debuff and AuraDisplay.approximateUnits[unitCategory] then message = message .. " Try Approximate Match." end
    return "error", message
  end
  if not (friendly or hostile) then
    return "note", ("%s picked by spell ID only match %s units."):format(debuff and "Debuffs" or "Buffs", debuff and "hostile" or "friendly")
  end
end

local function ProfilesFor(ids)
  local profiles = SavedTable("auraProfiles")
  if not profiles then return nil end
  local mergedDurations
  for _, spellId in ipairs(ids) do
    local learnedProfile = profiles[spellId]
    if IsTable(learnedProfile) then
      if not mergedDurations then
        mergedDurations = {}
        for slotKey, value in pairs(learnedProfile) do mergedDurations[slotKey] = value end
      else
        mergedDurations.duration = math.max(mergedDurations.duration or 0, learnedProfile.duration or 0)
        if mergedDurations.dispel ~= learnedProfile.dispel then mergedDurations.dispel = nil end
        for _, flag in ipairs(PROFILE_FLAGS) do
          if mergedDurations[flag] ~= learnedProfile[flag] then mergedDurations[flag] = nil end
        end
      end
    end
  end
  return mergedDurations
end

local durationMatchers
local describedDurations, describedPending, describedRequested = {}, {}, {}

local DURATION_UNITS = {
  { multiplier = 1, english = { "%d sec", "%d secs", "%d second", "%d seconds" },
    globals = { "INT_SPELL_DURATION_SEC", "SPELL_DURATION_SEC", "SECONDS_ABBR", "SECOND_ONELETTER_ABBR", "D_SECONDS" } },
  { multiplier = 60, english = { "%d min", "%d mins", "%d minute", "%d minutes" },
    globals = { "INT_SPELL_DURATION_MIN", "SPELL_DURATION_MIN", "MINUTES_ABBR", "MINUTE_ONELETTER_ABBR", "D_MINUTES" } },
  { multiplier = 3600, english = { "%d hour", "%d hours", "%d hr", "%d hrs" },
    globals = { "INT_SPELL_DURATION_HOURS", "SPELL_DURATION_HOURS", "HOURS_ABBR", "HOUR_ONELETTER_ABBR", "D_HOURS" } },
}

local function ExpandPlurals(template, out)
  local first, last, options = template:find("|4([^;]*);")
  if not first then
    out[#out + 1] = template
    return
  end
  for option in (options .. ":"):gmatch("([^:]*):") do
    ExpandPlurals(template:sub(1, first - 1) .. option .. template:sub(last + 1), out)
  end
end

local function EscapePart(part)
  return (part:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"):gsub("[ \194\160]+", " ?"))
end

local function PatternOf(template)
  local caption = template:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
  local first, last = caption:find("%%[%d%.%$]*[dfg]")
  if not first then return nil end
  local prefix, suffix = caption:sub(1, first - 1), caption:sub(last + 1)
  if prefix == "" and suffix == "" then return nil end
  local pattern = EscapePart(prefix) .. "(%d+[%.,]?%d*)" .. EscapePart(suffix)
  if suffix:find("%a$") then pattern = pattern .. "%f[%A]" end
  return pattern
end

local function DurationMatchers()
  if durationMatchers then return durationMatchers end
  durationMatchers = {}
  local seen = {}
  for _, unitToken in ipairs(DURATION_UNITS) do
    local templates = {}
    for _, name in ipairs(unitToken.globals) do
      local value = _G[name]
      if type(value) == "string" then ExpandPlurals(value, templates) end
    end
    for _, english in ipairs(unitToken.english) do templates[#templates + 1] = english end
    for _, template in ipairs(templates) do
      local pattern = PatternOf(template)
      if pattern and not seen[pattern] then
        seen[pattern] = true
        durationMatchers[#durationMatchers + 1] = { pattern = pattern, multiplier = unitToken.multiplier }
      end
    end
  end
  return durationMatchers
end

local function SpellText(spellId)
  local parts, loaded = {}, false
  if C_Spell and C_Spell.GetSpellDescription then
    local ok, description = pcall(C_Spell.GetSpellDescription, spellId)
    if ok and type(description) == "string" and not IsSecret(description) and description ~= "" then
      parts[1], loaded = description, true
    end
  end
  local readTooltip = C_TooltipInfo and C_TooltipInfo.GetSpellByID
  if readTooltip then
    local ok, info = pcall(readTooltip, spellId)
    if ok and IsTable(info) and IsTable(info.lines) then
      for _, line in ipairs(info.lines) do
        for _, side in ipairs({ "leftText", "rightText" }) do
          local caption = IsTable(line) and line[side]
          if type(caption) == "string" and not IsSecret(caption) then parts[#parts + 1] = caption end
        end
      end
    end
  end
  return table.concat(parts, "\n"):lower(), loaded
end

local function LongestDuration(caption)
  local longest
  for _, rule in ipairs(DurationMatchers()) do
    for capture in caption:gmatch(rule.pattern) do
      local number = tonumber((capture:gsub(",", ".")))
      if number then
        local seconds = number * rule.multiplier
        if seconds > 0 and (not longest or seconds > longest) then longest = seconds end
      end
    end
  end
  return longest
end

local function DescribedDuration(spellId)
  local cached = describedDurations[spellId]
  if cached ~= nil then return cached or nil end
  if describedPending[spellId] then return nil end
  local caption, loaded = SpellText(spellId)
  if not loaded and not describedRequested[spellId] and C_Spell and C_Spell.RequestLoadSpellData then
    describedPending[spellId], describedRequested[spellId] = true, true
    if pcall(C_Spell.RequestLoadSpellData, spellId) then return nil end
    describedPending[spellId] = nil
  end
  local found = LongestDuration(caption)
  if found then
    describedDurations[spellId] = found
  elseif loaded or describedRequested[spellId] then
    describedDurations[spellId] = false
  end
  return found
end

local function LongestDescribed(ids)
  local longest
  for _, spellId in ipairs(ids) do
    local seconds = DescribedDuration(spellId)
    if seconds and (not longest or seconds > longest) then longest = seconds end
  end
  return longest
end

local function SpellIDsOf(auraTrigger)
  return AuraDisplay.GetSpellIDs(IsTable(auraTrigger) and auraTrigger or {}, true)
end

function AuraDisplay.LateGlowTotal(auraTrigger)
  local operator, seconds = AuraDisplay.TotalFilter(auraTrigger)
  if operator == "=" then return seconds, "manual" end
  local ids = SpellIDsOf(auraTrigger)
  local learned = SavedTable("auraDurations")
  local longest
  for _, spellId in ipairs(ids) do
    local value = learned and tonumber(learned[spellId])
    if value and value > 0 and (not longest or value > longest) then longest = value end
  end
  if longest then return longest, "seen" end
  longest = LongestDescribed(ids)
  if longest then return longest, "described" end
end

function AuraDisplay.ApproximateProfile(auraTrigger)
  local ids = SpellIDsOf(auraTrigger)
  local mergedDurations = ProfilesFor(ids)
  local operator, seconds = AuraDisplay.TotalFilter(auraTrigger)
  if operator then
    mergedDurations = mergedDurations or {}
    mergedDurations.duration = operator == "=" and seconds or nil
    return mergedDurations, "manual"
  end
  if mergedDurations then return mergedDurations, "seen" end
  local described = LongestDescribed(ids)
  if described then return { duration = described }, "duration" end
end

function AuraDisplay.ApproximateFilters(auraTrigger, filterTable)
  if not AuraDisplay.UsesApproximate(auraTrigger) then return filterTable end
  local learnedProfile = AuraDisplay.ApproximateProfile(auraTrigger)
  if not learnedProfile then
    filterTable.includeSpellIDs = {}
    return filterTable
  end
  filterTable.includeSpellIDs, filterTable.excludeSpellIDs = nil, nil
  if type(learnedProfile.duration) == "number" and learnedProfile.duration > 0 then
    filterTable.maxDuration = math.min(filterTable.maxDuration or math.huge, learnedProfile.duration + GATE_TOLERANCE)
  end
  if type(learnedProfile.dispel) == "string" then filterTable.includeDispelTypes = { [learnedProfile.dispel] = true } end
  for _, flag in ipairs(PROFILE_FLAGS) do
    if filterTable[flag] == nil and type(learnedProfile[flag]) == "boolean" then filterTable[flag] = learnedProfile[flag] end
  end
  return filterTable
end

local watchedGlowIds, watchedProfileIds = {}, {}
local learners = setmetatable({}, { __mode = "k" })
local pendingRegions = setmetatable({}, { __mode = "k" })
local deferredIds, changedIds = {}, {}
local groupLearning = false

local function RebuildWatches()
  Clear(watchedGlowIds)
  Clear(watchedProfileIds)
  groupLearning = false
  for _, record in pairs(learners) do
    if record.approximate and record.group then groupLearning = true end
    for _, spellId in ipairs(record.ids) do
      if record.approximate then watchedProfileIds[spellId] = true end
      if record.glow then watchedGlowIds[spellId] = true end
    end
  end
end

local function Reapply(only)
  local pending = {}
  for auraRegion, auraData in pairs(pendingRegions) do
    local concerned = only == nil
    local record = learners[auraRegion]
    if not concerned and record then
      for _, spellId in ipairs(record.ids) do
        if only[spellId] then concerned = true break end
      end
    end
    if concerned then pending[#pending + 1] = { region = auraRegion, data = auraData } end
  end
  for _, item in ipairs(pending) do
    if WeakAuras.GetData(item.data.id) ~= item.data then
      AuraDisplay.ReleaseAuraLearning(item.region)
    else
      AuraDisplay.Apply(item.region, item.data)
    end
  end
end

function AuraDisplay.WatchAuraLearning(auraRegion, auraData, auraTrigger, glow)
  local approximate = AuraDisplay.UsesApproximate(auraTrigger)
  if not approximate and not glow then
    AuraDisplay.ReleaseAuraLearning(auraRegion)
    return
  end
  local ids = AuraDisplay.GetSpellIDs(auraTrigger, true)
  local slotKey = table.concat(ids, ",") .. tostring(approximate) .. tostring(glow and true or false) .. tostring(auraTrigger.unit)
  local record = learners[auraRegion]
  if not record or record.key ~= slotKey then
    local unitCategory = AuraDisplay.UnitCategory(auraTrigger)
    learners[auraRegion] = {
      ids = ids, key = slotKey, approximate = approximate, glow = glow,
      group = unitCategory == "group" or unitCategory == "party" or unitCategory == "raid",
    }
    RebuildWatches()
  end
  pendingRegions[auraRegion] = auraData
end

function AuraDisplay.ReleaseAuraLearning(auraRegion)
  pendingRegions[auraRegion] = nil
  if not learners[auraRegion] then return end
  learners[auraRegion] = nil
  RebuildWatches()
end

local function IsFriendlyToken(unitToken)
  if type(unitToken) ~= "string" then return true end
  return unitToken == "player" or unitToken == "pet" or unitToken:find("^party%d") ~= nil or unitToken:find("^raid%d") ~= nil
end

local function SameProfile(left, right)
  for slotKey, value in pairs(left) do
    if right[slotKey] ~= value then return false end
  end
  for slotKey, value in pairs(right) do
    if left[slotKey] ~= value then return false end
  end
  return true
end

local function LearnDuration(aura, spellId)
  local duration = aura.duration
  if IsSecret(duration) or not watchedGlowIds[spellId] or not ReadableNumber(duration) or duration <= 0 then return end
  local learned = SavedTable("auraDurations", true)
  local rounded = Tenth(duration)
  if learned[spellId] ~= rounded then
    learned[spellId] = rounded
    changedIds[spellId] = true
  end
end

local function LearnProfile(aura, spellId, unitToken, harmful)
  if not (ReadableNumber(spellId) and watchedProfileIds[spellId] and harmful and ReadableNumber(aura.duration)) then return end
  local profiles = SavedTable("auraProfiles", true)
  local friendly = IsFriendlyToken(unitToken)
  local old = profiles[spellId]
  if not friendly and IsTable(old) and old.friendly then return end
  local fresh = { duration = Tenth(aura.duration), friendly = friendly or nil }
  local dispelType = aura.dispelName
  if type(dispelType) == "string" and not IsSecret(dispelType) then fresh.dispel = dispelType end
  if friendly then
    for _, flag in ipairs(PROFILE_FLAGS) do
      local flagValue = aura[flag]
      if type(flagValue) == "boolean" and not IsSecret(flagValue) then fresh[flag] = flagValue end
    end
  end
  if not (IsTable(old) and SameProfile(old, fresh)) then
    profiles[spellId] = fresh
    changedIds[spellId] = true
  end
end

local function LearnAura(aura, unitToken, harmful)
  local spellId = aura.spellId
  if IsSecret(spellId) then return end
  LearnDuration(aura, spellId)
  LearnProfile(aura, spellId, unitToken, harmful)
end

local function ScanUnit(unitToken, filterTable)
  for _, filterString in ipairs(filterTable) do
    for auraIndex = 1, SCAN_SLOTS do
      local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unitToken, auraIndex, filterString)
      if not ok or not IsTable(aura) then break end
      LearnAura(aura, unitToken, filterString == "HARMFUL")
    end
  end
end

local function ScanOwnUnits(filterTable)
  for _, unitToken in ipairs({ "player", "target", "focus", "pet" }) do ScanUnit(unitToken, filterTable) end
  if not groupLearning then return end
  if IsInRaid() then
    for index = 1, GetNumGroupMembers() do ScanUnit("raid" .. index, filterTable) end
  else
    for index = 1, GetNumSubgroupMembers() do ScanUnit("party" .. index, filterTable) end
  end
end

local function LearnFromUpdate(unitToken, info, filterTable)
  if not IsTable(info) or info.isFullUpdate then
    ScanUnit(unitToken, filterTable)
    return
  end
  for _, aura in ipairs(info.addedAuras or {}) do
    if IsTable(aura) and not IsSecret(aura.isHarmful) then LearnAura(aura, unitToken, aura.isHarmful == true) end
  end
  for _, instanceId in ipairs(info.updatedAuraInstanceIDs or {}) do
    local ok, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unitToken, instanceId)
    if ok and IsTable(aura) and not IsSecret(aura.isHarmful) then LearnAura(aura, unitToken, aura.isHarmful == true) end
  end
end

local function OnLearningEvent(_, incomingEvent, unitToken, info)
  if incomingEvent == "SPELL_DATA_LOAD_RESULT" then
    local spellId = unitToken
    if not describedPending[spellId] then return end
    describedPending[spellId], describedDurations[spellId], describedRequested[spellId] = nil, nil, true
    if InCombatLockdown() then
      deferredIds[spellId] = true
    else
      Reapply({ [spellId] = true })
    end
    return
  end
  if incomingEvent == "PLAYER_REGEN_ENABLED" and next(deferredIds) then
    local ready = {}
    for spellId in pairs(deferredIds) do ready[spellId] = true end
    Clear(deferredIds)
    Reapply(ready)
  end
  if not (next(watchedGlowIds) or next(watchedProfileIds)) or WeakAuras.IsRestricted() then return end
  if not IsTable(WeakAurasSaved) then return end
  Clear(changedIds)
  local filterTable = next(watchedGlowIds) and { "HELPFUL", "HARMFUL" } or { "HARMFUL" }
  if incomingEvent == "UNIT_AURA" then
    if unitToken == "target" or unitToken == "focus" or IsFriendlyToken(unitToken) then LearnFromUpdate(unitToken, info, filterTable) end
  elseif incomingEvent == "PLAYER_TARGET_CHANGED" then
    ScanUnit("target", filterTable)
  else
    ScanOwnUnits(filterTable)
  end
  if next(changedIds) then Reapply(changedIds) end
end

local learningFrame = CreateFrame("Frame")
for _, eventName in ipairs({ "UNIT_AURA", "PLAYER_TARGET_CHANGED", "PLAYER_REGEN_ENABLED", "SPELL_DATA_LOAD_RESULT" }) do
  pcall(learningFrame.RegisterEvent, learningFrame, eventName)
end
learningFrame:SetScript("OnEvent", OnLearningEvent)

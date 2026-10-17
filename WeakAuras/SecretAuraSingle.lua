-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Single-element mode of the native aura display: trigger predicates, duration and stack gates, learned
-- durations and profiles, and the native frames drawing a missing aura, a Remaining Time window or a followed trigger.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local AuraDisplay = Private.BlizzardAuraDisplay

local EDGE_MARGIN = 0.001
local GATE_TOLERANCE = 0.5
local TEXCOORD_SCALE = 1024
local GLOW_SPEED, GLOW_BUDGET = 2000, 200000
local FOLLOW_TICK = 0.1
local SCAN_SLOTS = 40
local DEFAULT_ICON = 134400
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local CLIP_TEMPLATE = "DisableUntrustedLayoutScriptsTemplate"
local WARNING_KEY = "blizzard_aura_single"
local MISSING_GROUP, PRESENCE_GROUP = "MuscaMissing", "MuscaPresence"
local SLOT_ICON, SLOT_GATE = "MuscaRemainIcon", "MuscaRemainGate"
local LIST_GROUP = "Auras"
local GOOD, CAUTION, BAD = "|cff33ff99", "|cffff9933", "|cffff2020"
local FOLLOWER_KEYS = { "presence", "flowShadow" }
local COUNTDOWN_FORMAT_PREFIX = "text_text_format_p_time_"
local PROFILE_FLAGS = { "canApplyAura", "isStealable", "isBossAura", "isFromPlayerOrPlayerPet", "nameplateShowAll", "nameplateShowPersonal" }
local OFFSET_KEYS = { "anchorXOffset", "anchorYOffset", "text_anchorXOffset", "text_anchorYOffset", "glowXOffset", "glowYOffset", "xOffset", "yOffset" }
local KEEP_WHEN_LIMITED = { subglow = true, subbackground = true }
local DISPEL_ELEMENTS = { subcdmdispel = true, subcdmdispelborder = true }

local function KeySet(list, identity)
  local set = {}
  for _, slotKey in ipairs(list) do set[slotKey] = identity and slotKey or true end
  return set
end

local FRIENDLY_CATEGORIES = KeySet({ "player", "pet", "group", "party", "raid" })
local HOSTILE_CATEGORIES = KeySet({ "boss", "arena" })

local function IsTable(value) return type(value) == "table" end
local function IsSecret(value) return issecretvalue ~= nil and issecretvalue(value) == true end
local function ReadableNumber(value) return type(value) == "number" and not IsSecret(value) end
local function Paint(color, caption) return color .. caption .. "|r" end
local function Clear(list) for slotKey in pairs(list) do list[slotKey] = nil end end
local function Round(value) return math.floor(value + 0.5) end
local function Tenth(value) return Round(value * 10) / 10 end

local function ToFinite(value)
  if IsSecret(value) then return nil end
  value = tonumber(value)
  if value and value == value and value ~= math.huge and value ~= -math.huge then return value end
end

local function SavedTable(name, create)
  if not IsTable(WeakAurasSaved) then return nil end
  local list = WeakAurasSaved[name]
  if not IsTable(list) and create then
    list = {}
    WeakAurasSaved[name] = list
  end
  return IsTable(list) and list or nil
end

local function AnchorsToUnitFrame(auraData)
  local frameType = AuraDisplay.FrameAnchorType(auraData)
  return frameType == "UNITFRAME" or frameType == "NAMEPLATE"
end

local function FindCondition(auraData, accepts)
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    if IsTable(conditionEntry) and IsTable(conditionEntry.check) and accepts(conditionEntry.check, conditionEntry) then return conditionEntry end
  end
end

local function FirstProblem(checks)
  for _, check in ipairs(checks) do
    if check[1] then return check[2] end
  end
end

local function ReportProblem(auraData, message)
  local warnings = Private.AuraWarnings
  if warnings and warnings.UpdateWarning then warnings.UpdateWarning(auraData.uid, WARNING_KEY, "warning", message) end
end

function AuraDisplay.ClearSingleWarning(auraData)
  local warnings = Private.AuraWarnings
  if warnings and warnings.UpdateWarning then warnings.UpdateWarning(auraData.uid, WARNING_KEY, nil, nil) end
end

AuraDisplay.singleUnits = KeySet({ "player", "target", "focus", "pet", "targettarget", "focustarget" })
AuraDisplay.approximateUnits = KeySet({ "player", "pet", "group", "party", "raid" })
AuraDisplay.missingTypes = KeySet({ "icon", "aurabar", "progresstexture", "text" })
AuraDisplay.remOperators = KeySet({ "<", "<=", ">", ">=" }, true)
AuraDisplay.totalOperators = KeySet({ "=", "<=", ">=" }, true)
AuraDisplay.stackOperators = KeySet({ "=", ">=", ">", "<=", "<" }, true)
AuraDisplay.STACK_LIMIT = 100
AuraDisplay.showOnValues = {
  showOnActive = "Aura(s) Found",
  showOnMissing = "Aura(s) Missing",
  showAlways = "Always",
}

function AuraDisplay.IsSingleUnit(auraTrigger)
  if not IsTable(auraTrigger) then return false end
  if auraTrigger.unit == "member" then return AuraDisplay.SpecificUnit(auraTrigger) ~= nil end
  return AuraDisplay.singleUnits[auraTrigger.unit] == true
end

function AuraDisplay.RawShowOn(auraTrigger)
  local value = IsTable(auraTrigger) and auraTrigger.secretShowOn
  return AuraDisplay.showOnValues[value] and value or "showOnActive"
end
AuraDisplay.ShowOn = AuraDisplay.RawShowOn

local function WantsMissing(auraTrigger)
  local showMode = AuraDisplay.RawShowOn(auraTrigger)
  return showMode == "showOnMissing" or showMode == "showAlways"
end

local function UsesRemaining(auraTrigger)
  return IsTable(auraTrigger) and auraTrigger.secretUseRem == true and AuraDisplay.RawShowOn(auraTrigger) == "showOnActive"
end

function AuraDisplay.RemainingWindow(auraTrigger)
  if not UsesRemaining(auraTrigger) then return end
  local operator = auraTrigger.secretRemOperator or "<"
  if not AuraDisplay.remOperators[operator] then return end
  local seconds = ToFinite(auraTrigger.secretRem)
  if seconds and seconds >= 0 then return operator, seconds end
end

local function HasWindow(auraData)
  return AuraDisplay.RemainingWindow(AuraDisplay.GetTrigger(auraData)) ~= nil
end

function AuraDisplay.IsSingle(auraTrigger, auraData)
  if AuraDisplay.RawShowOn(auraTrigger) ~= "showOnActive" then return true end
  if not UsesRemaining(auraTrigger) then return false end
  return auraData == nil or auraData.regionType == "icon"
end

local WINDOW_TESTS = {
  ["<"] = function(value, limit) return value < limit end,
  ["<="] = function(value, limit) return value <= limit end,
  [">"] = function(value, limit) return value > limit end,
}

function AuraDisplay.InRemainingWindow(value, operator, limit)
  local test = WINDOW_TESTS[operator]
  if test then return test(value, limit) end
  return value >= limit
end

function AuraDisplay.RemainingWindowPoints(_, limit)
  return { limit, limit + EDGE_MARGIN }
end

local WINDOW_RANGES = {
  ["<"] = function(seconds) return 0, seconds - EDGE_MARGIN end,
  ["<="] = function(seconds) return 0, seconds end,
  [">"] = function(seconds) return seconds + EDGE_MARGIN end,
  [">="] = function(seconds) return seconds end,
}

local function WindowEdge(operator, seconds)
  if operator == "<=" or operator == ">" then return seconds + EDGE_MARGIN end
  return seconds
end

function AuraDisplay.DrawsOne(auraData)
  return AuraDisplay.IsSingle(AuraDisplay.GetTrigger(auraData), auraData)
end

function AuraDisplay.Growth(auraData)
  local flowGrowth = AuraDisplay.FlowGrowth and AuraDisplay.FlowGrowth(auraData)
  if flowGrowth then return AuraDisplay.VisibleGrowth(flowGrowth) end
  if AuraDisplay.DrawsOne(auraData) then return "RIGHT" end
  return (auraData.blizzardAuraDisplay or {}).growth or "RIGHT"
end

function AuraDisplay.MaxAuras(auraData)
  if AuraDisplay.UsesGate(auraData) then return 10 end
  if AuraDisplay.DrawsOne(auraData) then return 1 end
  local flowLimit = AuraDisplay.FlowLimit and AuraDisplay.FlowLimit(auraData)
  if flowLimit then return flowLimit end
  return (auraData.blizzardAuraDisplay or {}).maxIcons or 10
end

function AuraDisplay.PreviewShowsMissing(auraData)
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local singleState = AuraDisplay.IsSingle(auraTrigger)
  if not singleState then return singleState end
  return AuraDisplay.RawShowOn(auraTrigger) == "showOnMissing"
end

function AuraDisplay.SingleIcon(auraData)
  if auraData.iconSource == 0 and auraData.displayIcon ~= nil and auraData.displayIcon ~= "" then return auraData.displayIcon end
  local spellId = AuraDisplay.GetSpellIDs(AuraDisplay.GetTrigger(auraData) or {}, false)[1]
  if spellId and C_Spell and C_Spell.GetSpellTexture then
    local texture = C_Spell.GetSpellTexture(spellId)
    if texture ~= nil and not IsSecret(texture) then return texture end
  end
  return DEFAULT_ICON
end

function AuraDisplay.SingleUnitExists(auraTrigger)
  local unitToken = IsTable(auraTrigger) and auraTrigger.unit or "player"
  if unitToken == "player" then return true end
  if unitToken == "member" then
    unitToken = AuraDisplay.SpecificUnit(auraTrigger)
    if not unitToken then return false end
  end
  local ok, exists = pcall(UnitExists, unitToken)
  if ok and not IsSecret(exists) then return exists == true end
  return true
end

function AuraDisplay.InDynamicGroup(auraData)
  local parentId = auraData.parent
  for _ = 1, 50 do
    if not parentId then return false end
    local parentRegion = WeakAuras.GetData(parentId)
    if not parentRegion then return false end
    if parentRegion.regionType == "dynamicgroup" then return true end
    parentId = parentRegion.parent
  end
  return false
end

function AuraDisplay.MigrateSingle(auraData, auraTrigger)
  local tracking = auraTrigger.secretTracking
  if tracking == nil then return end
  if tracking == "single" then
    local legacy = auraTrigger.matchesShowOn
    if auraTrigger.secretShowOn == nil and legacy ~= "showOnActive" and AuraDisplay.showOnValues[legacy] then
      auraTrigger.secretShowOn = legacy
    end
    if auraTrigger.secretUseRem == nil and auraTrigger.useRem then
      auraTrigger.secretUseRem, auraTrigger.secretRemOperator, auraTrigger.secretRem = true, auraTrigger.remOperator, auraTrigger.rem
    end
    auraData.blizzardAuraDisplay = auraData.blizzardAuraDisplay or {}
    auraData.blizzardAuraDisplay.maxIcons = 1
  end
  auraTrigger.secretTracking = nil
end

function AuraDisplay.MigrateTotal(auraTrigger)
  if auraTrigger.secretUseTotal == nil then
    if auraTrigger.secretExactDuration and tonumber(auraTrigger.secretDuration) then
      auraTrigger.secretUseTotal, auraTrigger.secretTotalOperator = true, "="
      auraTrigger.secretTotal = tostring(auraTrigger.secretDuration)
    elseif type(auraTrigger.maxDuration) == "number" then
      auraTrigger.secretUseTotal, auraTrigger.secretTotalOperator = true, "<="
      auraTrigger.secretTotal = tostring(auraTrigger.maxDuration)
    end
  end
  auraTrigger.maxDuration, auraTrigger.secretExactDuration, auraTrigger.secretDuration = nil, nil, nil
end

function AuraDisplay.MigrateFallback(auraData)
  if not IsTable(auraData.triggers) then return end
  for _, record in ipairs(auraData.triggers) do
    local auraTrigger = IsTable(record) and record.trigger
    if IsTable(auraTrigger) and auraTrigger.secretMissingSource ~= nil then
      local number = tonumber(auraTrigger.secretMissingSource)
      if number and auraData.triggers.secretFallback == nil then auraData.triggers.secretFallback = number end
      auraTrigger.secretMissingSource = nil
    end
  end
end

local function Followable(auraData, index)
  local record = IsTable(auraData.triggers) and auraData.triggers[index]
  return IsTable(record) and IsTable(record.trigger) and record.trigger.type ~= "secretAura"
end

local function PilotIndex(auraData)
  local saved = AuraDisplay.GetSavedTrigger(auraData)
  if saved == nil then return nil end
  for index, record in ipairs(auraData.triggers or {}) do
    if IsTable(record) and record.trigger == saved then return index end
  end
end

local function FollowableOthers(auraData, pilot)
  local others = {}
  for index in ipairs(auraData.triggers or {}) do
    if index ~= pilot and Followable(auraData, index) then others[#others + 1] = index end
  end
  return others
end

function AuraDisplay.FallbackChoice(auraData)
  local raw = IsTable(auraData.triggers) and auraData.triggers.secretFallback
  if raw == "none" then return "none" end
  return tonumber(raw) or "next"
end

local function CanFallBack(auraData, auraTrigger)
  if not AuraDisplay.IsSingleUnit(auraTrigger) then return false end
  if not AuraDisplay.missingTypes[auraData.regionType] then return false end
  if AuraDisplay.FlowGroup and AuraDisplay.FlowGroup(auraData) then return false end
  if AnchorsToUnitFrame(auraData) then return false end
  return not (AuraDisplay.RawShowOn(auraTrigger) == "showOnActive" and auraTrigger.secretUseRem == true)
end

function AuraDisplay.Fallback(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not IsTable(auraTrigger) or not CanFallBack(auraData, auraTrigger) then return end
  local pilot = PilotIndex(auraData)
  if not pilot then return end
  local fallbackChoice = AuraDisplay.FallbackChoice(auraData)
  if fallbackChoice == "none" then return end
  if fallbackChoice == "next" then
    if #FollowableOthers(auraData, pilot) > 0 then return "next" end
    return
  end
  if fallbackChoice ~= pilot and Followable(auraData, fallbackChoice) then return fallbackChoice end
end

function AuraDisplay.FallbackProblem(auraData)
  local fallbackChoice = AuraDisplay.FallbackChoice(auraData)
  if type(fallbackChoice) == "number" and not Followable(auraData, fallbackChoice) then
    return "Trigger Combination: the trigger picked for when the Aura (Modern) filters do not match was deleted or is itself an Aura (Modern) trigger."
  end
end

function AuraDisplay.FoundFollow(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if IsTable(auraTrigger) and AuraDisplay.RawShowOn(auraTrigger) == "showOnActive" then return AuraDisplay.Fallback(auraData, auraTrigger) end
end

function AuraDisplay.MissingSource(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if IsTable(auraTrigger) then return AuraDisplay.Fallback(auraData, auraTrigger) end
end

function AuraDisplay.TotalFilter(auraTrigger)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseTotal) then return end
  local operator = auraTrigger.secretTotalOperator or "="
  if not AuraDisplay.totalOperators[operator] then return end
  local seconds = ToFinite(auraTrigger.secretTotal)
  if seconds and seconds > 0 then return operator, seconds end
end

function AuraDisplay.UsesApproximate(auraTrigger)
  if not IsTable(auraTrigger) or auraTrigger.secretApproximate ~= true or auraTrigger.debuffType ~= "HARMFUL" then return false end
  if AuraDisplay.approximateUnits[AuraDisplay.UnitCategory(auraTrigger)] ~= true then return false end
  return (AuraDisplay.UsesSpellIDs(auraTrigger) or AuraDisplay.UsesRankSpellIDs(auraTrigger)) and true or false
end

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
        if not longest or seconds > longest then longest = seconds end
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

local function ClientCanBind(property)
  local bindable = (Enum.DurationTextBindingProperty or {})[property]
  if bindable == nil or not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) then return false end
  return AuraDisplay.SupportsDurationColorCondition ~= nil and AuraDisplay.SupportsDurationColorCondition() and true or false
end

local TOTAL_RANGES = {
  ["="] = function(seconds) return seconds - GATE_TOLERANCE, seconds + GATE_TOLERANCE end,
  [">="] = function(seconds) return seconds - GATE_TOLERANCE end,
}

function AuraDisplay.GateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not auraTrigger then return end
  local operator, seconds = AuraDisplay.TotalFilter(auraTrigger)
  local range = operator and TOTAL_RANGES[operator]
  local lower, upper, origin
  if range then
    lower, upper = range(seconds)
    origin = "filter"
  elseif AuraDisplay.UsesApproximate(auraTrigger) then
    local learnedProfile = AuraDisplay.ApproximateProfile(auraTrigger)
    local duration = learnedProfile and learnedProfile.duration
    if type(duration) == "number" and duration > 0 then
      lower, upper, origin = duration - GATE_TOLERANCE, duration + GATE_TOLERANCE, "approximate"
    end
  end
  if not lower then return end
  local fault = FirstProblem({
    { AnchorsToUnitFrame(auraData), "Total Duration = and >= can't anchor to unit frames or nameplates." },
    { AuraDisplay.IsSingle(auraTrigger), "Total Duration = and >= only work with Show On: Aura(s) Found, without Remaining Time." },
    { not ClientCanBind("TotalDuration"), "This client can't check Total Duration = or >=." },
  })
  return math.max(EDGE_MARGIN, lower), upper, origin, fault
end

function AuraDisplay.DurationGate(auraData, auraTrigger)
  local lower, upper, _, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if lower and not fault then return lower, upper end
end

function AuraDisplay.TotalFilterProblem(auraData, auraTrigger)
  local _, _, origin, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if origin == "filter" then return fault end
end

local STACK_RULES = {
  ["="] = function(count) return "exactly", count end,
  [">="] = function(count)
    if count > 0 then return "atLeast", count end
  end,
  ["<="] = function(count)
    if count < 0 then return "never" end
    return "atMost", count
  end,
}
STACK_RULES[">"] = function(count) return STACK_RULES[">="](count + 1) end
STACK_RULES["<"] = function(count) return STACK_RULES["<="](count - 1) end

local function StackCount(auraTrigger)
  local count = ToFinite(auraTrigger.secretStacks)
  if count and count == math.floor(count) and count >= 0 and count <= AuraDisplay.STACK_LIMIT then return count end
end

function AuraDisplay.StackFilter(auraTrigger)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseStacks) then return end
  local operator = auraTrigger.secretStacksOperator or ">="
  local rule = AuraDisplay.stackOperators[operator] and STACK_RULES[operator]
  local count = StackCount(auraTrigger)
  if rule and count then return rule(count) end
end

function AuraDisplay.StackFilterProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if not (IsTable(auraTrigger) and auraTrigger.secretUseStacks) then return end
  if not StackCount(auraTrigger) then
    return ("Stack Count needs a whole number from 0 to %d."):format(AuraDisplay.STACK_LIMIT)
  end
  local kind = AuraDisplay.StackFilter(auraTrigger)
  if kind == nil then return end
  return FirstProblem({
    { kind == "never", "Stack Count < 0 never matches." },
    { AnchorsToUnitFrame(auraData), "Stack Count can't anchor to unit frames or nameplates." },
    { AuraDisplay.IsSingle(auraTrigger), "Stack Count only works with Show On: Aura(s) Found, without Remaining Time." },
    { AuraDisplay.GateRange(auraData, auraTrigger) ~= nil, "Stack Count can't be combined with Total Duration = or >=, or with Approximate Match." },
    { not (C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions), "This client can't check Stack Count." },
  })
end

function AuraDisplay.StackGate(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  local kind, count = AuraDisplay.StackFilter(auraTrigger)
  if (kind == "exactly" or kind == "atLeast" or kind == "atMost") and not AuraDisplay.StackFilterProblem(auraData, auraTrigger) then
    return kind, count
  end
end

function AuraDisplay.RemainingGateProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if auraData.regionType == "icon" or not UsesRemaining(auraTrigger) then return end
  return FirstProblem({
    { AuraDisplay.RemainingWindow(auraTrigger) == nil, "Remaining Time: pick a comparison and a seconds value of 0 or more." },
    { AnchorsToUnitFrame(auraData), "Remaining Time can't anchor to unit frames or nameplates." },
    { AuraDisplay.GateRange(auraData, auraTrigger) ~= nil, "On this display type, Remaining Time can't be combined with Total Duration = or >=, or with Approximate Match." },
    { not ClientCanBind("RemainingDuration"), "This client can't check Remaining Time on this display type." },
  })
end

function AuraDisplay.RemainingGateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or AuraDisplay.GetTrigger(auraData)
  if auraData.regionType == "icon" or not UsesRemaining(auraTrigger) or AuraDisplay.RemainingGateProblem(auraData, auraTrigger) then return end
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  return WINDOW_RANGES[operator](seconds)
end

function AuraDisplay.UsesGate(auraData)
  return AuraDisplay.DurationGate(auraData) ~= nil or AuraDisplay.RemainingGateRange(auraData) ~= nil or AuraDisplay.StackGate(auraData) ~= nil
end

local function AttachedElements(auraData, kind)
  local index = 0
  return function()
    while true do
      index = index + 1
      local element = (auraData.subRegions or {})[index]
      if element == nil then return nil end
      if (kind == nil or element.type == kind) and not AuraDisplay.IsDetachedElement(auraData, element) then return index, element end
    end
  end
end

local function ElementTextKind(element)
  local caption = element.text_text
  if type(caption) == "string" then return AuraDisplay.TextKind(caption) end
end

local function IsTextOfKind(element, kind)
  return element.text_visible ~= false and ElementTextKind(element) == kind
end

local function GlowChangeIndex(auraData, conditionEntry)
  for _, change in ipairs(conditionEntry.changes or {}) do
    if IsTable(change) and change.value == true and AuraDisplay.IsGlowProperty(auraData, change.property) then
      return tonumber(tostring(change.property):match("^sub%.(%d+)"))
    end
  end
end

function AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if auraData.regionType ~= "icon" then return end
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  if operator then
    for index, element in AttachedElements(auraData, "subglow") do
      if element.glow then
        return WindowEdge(operator, seconds), element, index, operator == ">" or operator == ">="
      end
    end
    return
  end
  for _, conditionEntry in ipairs(auraData.conditions or {}) do
    local check = IsTable(conditionEntry) and conditionEntry.check
    if IsTable(check) and not check.checks and not conditionEntry.linked and check.op == "<"
      and (check.variable == "faAuraRemaining" or check.variable == "faAuraElapsed")
      and AuraDisplay.NativeConditionKind(auraData, check) then
      local limit = tonumber(check.value)
      local index = limit and limit > 0 and GlowChangeIndex(auraData, conditionEntry)
      if index then
        return limit, (auraData.subRegions or {})[index], index, false, check.variable == "faAuraElapsed"
      end
    end
  end
end

local function InvisibleBar(parentRegion)
  local fillBar = CreateFrame("StatusBar", nil, parentRegion)
  fillBar:SetStatusBarTexture(WHITE_TEXTURE)
  fillBar:SetStatusBarColor(0, 0, 0, 0)
  return fillBar
end

local function SpanClip(clip, startFrame, startPoint, startX, endFrame, endPoint, endX)
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", startFrame, startPoint, startX, 0)
  clip:SetPoint("BOTTOMRIGHT", endFrame, endPoint, endX or 0, 0)
  clip:SetClipsChildren(true)
end

local function GlowMargin(element, iconWidth, iconHeight)
  local scale = element.glowScale or 1
  local offset = math.max(math.abs(element.glowXOffset or 0), math.abs(element.glowYOffset or 0))
  return math.ceil(math.max(iconWidth, iconHeight) * 0.5 * scale) + offset + 4
end

function AuraDisplay.TimedGlowHolder(nativeDisplay, auraData, index, hostFrame)
  if nativeDisplay.preview then return end
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local edge, element, glowIndex, above, elapsed = AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if not edge or glowIndex ~= index then return end
  local lateTotal = AuraDisplay.LateGlowTotal(auraTrigger)
  if not lateTotal then return false end
  if elapsed then
    edge, above = lateTotal - math.min(edge, lateTotal), true
  elseif lateTotal <= edge then
    return false
  end
  local auraButton = nativeDisplay.button
  local glow = nativeDisplay.lateGlow
  if not glow then
    local clip = CreateFrame("Frame", nil, nativeDisplay.gateClip or auraButton, CLIP_TEMPLATE)
    local holder = CreateFrame("Frame", nil, clip)
    holder:SetAllPoints(auraButton)
    glow = { bar = InvisibleBar(auraButton), clip = clip, holder = holder }
    nativeDisplay.lateGlow = glow
  end
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local scale = math.min(GLOW_SPEED, GLOW_BUDGET / lateTotal)
  local margin = GlowMargin(element or {}, iconWidth, iconHeight)
  local fillBar, clip = glow.bar, glow.clip
  fillBar:SetSize(lateTotal * scale, iconHeight + 2 * margin)
  pcall(function()
    auraButton:SetDurationBar(fillBar, { direction = Enum.StatusBarTimerDirection.RemainingTime })
  end)
  fillBar:ClearAllPoints()
  local texture = fillBar:GetStatusBarTexture()
  local shift = edge * scale
  if above then
    fillBar:SetPoint("LEFT", auraButton, "LEFT", -margin - shift, 0)
    SpanClip(clip, fillBar, "TOPLEFT", shift, texture, "BOTTOMRIGHT")
  else
    fillBar:SetPoint("LEFT", auraButton, "RIGHT", margin - shift, 0)
    SpanClip(clip, texture, "TOPRIGHT", 0, fillBar, "BOTTOMLEFT", shift)
  end
  fillBar:Show()
  clip:SetFrameLevel(hostFrame:GetFrameLevel() + 1)
  clip:Show()
  return glow.holder
end

local function GateFill(iconWidth, iconHeight)
  local largest = math.max(iconWidth, iconHeight)
  local margin = math.ceil(largest * 0.5) + 8
  local fontSize = math.min(250, math.ceil(largest + 2 * margin))
  local line = ("W"):rep(math.ceil((iconWidth + 2 * margin) / (fontSize / 2)) + 1)
  local lines = {}
  for row = 1, math.max(1, math.ceil((iconHeight + 2 * margin) / fontSize)) do lines[row] = line end
  return table.concat(lines, "\n"), fontSize, margin
end

local formatterCache = {}

local function RangeFormatter(lower, upper, fill)
  local slotKey = lower .. "|" .. tostring(upper) .. "|" .. fill
  if formatterCache[slotKey] then return formatterCache[slotKey] end
  local breakpoints
  if upper and upper < lower then
    breakpoints = { { threshold = 0, format = "" } }
  elseif lower <= 0 then
    breakpoints = { { threshold = 0, format = fill } }
  else
    breakpoints = { { threshold = 0, format = "" }, { threshold = lower, format = fill } }
  end
  if upper and upper >= lower then breakpoints[#breakpoints + 1] = { threshold = upper + EDGE_MARGIN, format = "" } end
  local ok, formatter = pcall(function()
    local created = C_StringUtil.CreateNumericRuleFormatter()
    created:SetBreakpoints(breakpoints)
    return created
  end)
  if not ok then return nil, formatter end
  formatterCache[slotKey] = formatter
  return formatter
end

local clearCurve

local function InvisibleCurve()
  if not clearCurve then
    clearCurve = C_CurveUtil.CreateColorCurve()
    clearCurve:SetType(Enum.LuaCurveType.Step)
    clearCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
  end
  return clearCurve
end

local function LayGateText(auraButton, caption, fontSize, margin)
  caption:SetFont(STANDARD_TEXT_FONT, fontSize, "")
  caption:SetWidth(0)
  caption:SetJustifyH("LEFT")
  caption:ClearAllPoints()
  caption:SetPoint("LEFT", auraButton, "LEFT", -margin - 2, 0)
  caption:SetWordWrap(false)
end

local function BindGateText(auraButton, caption, property, formatter)
  local bound = Enum.DurationTextBindingProperty[property]
  return pcall(auraButton.SetDurationText, auraButton, caption, {
    textFormat = { formatString = "{}", components = { { property = bound, formatter = formatter } } },
    textColor = { property = bound, curve = InvisibleCurve() },
  })
end

local function StyleCountdown(sweepCooldown, nativeDisplay, element)
  if sweepCooldown.GetCountdownFontString then
    local label = sweepCooldown:GetCountdownFontString()
    if label then AuraDisplay.StyleText(label, nativeDisplay, AuraDisplay.TextSettings(element), "text", 18, "CENTER", 0, 0) end
  end
  sweepCooldown:SetCountdownFormatter(nil)
  local format = element[COUNTDOWN_FORMAT_PREFIX .. "format"]
  if format == nil or format == -1 then return end
  local ok, formatter = pcall(Private.GetDurationTextFormatter,
    element[COUNTDOWN_FORMAT_PREFIX .. "legacy_floor"] and 0 or 99,
    element[COUNTDOWN_FORMAT_PREFIX .. "dynamic_threshold"] or 3,
    element[COUNTDOWN_FORMAT_PREFIX .. "precision"] or 1,
    format == -2, format)
  if ok and formatter then sweepCooldown:SetCountdownFormatter(formatter) end
end

local function WarnStack(auraData, refusal)
  ReportProblem(auraData, "Blizzard refused the Stack Count check: " .. tostring(refusal))
end

local function FillStackTexts(nativeDisplay, auraData, count)
  for index, element in AttachedElements(auraData, "subtext") do
    local shared = (nativeDisplay.sharedElements or {})[index]
    if shared and shared.text and IsTextOfKind(element, "stack") then
      shared.text:SetText(AuraDisplay.StackTextFor(auraData, "sub." .. index .. ".text_color", count))
    end
  end
  if auraData.regionType == "text" and nativeDisplay.mainText and AuraDisplay.TextKind(auraData.displayText or "") == "stack" then
    nativeDisplay.mainText:SetText(AuraDisplay.StackTextFor(auraData, "color", count))
  end
end

local function BindExactStack(nativeDisplay, auraData, count)
  local auraButton = nativeDisplay.button
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local formatter, refusal = RangeFormatter(count, count, fill)
  if not formatter then
    WarnStack(auraData, refusal)
    return false
  end
  local caption = nativeDisplay.stackGateText
  if not caption then
    caption = auraButton:CreateFontString(nil, "OVERLAY")
    nativeDisplay.stackGateText = caption
  end
  LayGateText(auraButton, caption, fontSize, margin)
  local ok
  ok, refusal = pcall(auraButton.SetApplicationCount, auraButton, caption, { formatter = formatter })
  if not ok then
    caption:Hide()
    WarnStack(auraData, refusal)
    return false
  end
  caption:Show()
  SpanClip(nativeDisplay.gateClip, caption, "TOPLEFT", 0, caption, "BOTTOMRIGHT")
  FillStackTexts(nativeDisplay, auraData, count)
  caption:SetAlpha(0)
  return true
end

local function BindStackBar(nativeDisplay, auraData, kind, count)
  local auraButton = nativeDisplay.button
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local margin = math.ceil(math.max(iconWidth, iconHeight) * 0.5) + 8
  local step = iconWidth + 2 * margin
  local capacity = kind == "atLeast" and count or count + 1
  local fillBar = nativeDisplay.stackGate
  if not fillBar then
    fillBar = InvisibleBar(auraButton)
    nativeDisplay.stackGate = fillBar
  end
  fillBar:SetSize(capacity * step, iconHeight + 2 * margin)
  fillBar:ClearAllPoints()
  local texture = fillBar:GetStatusBarTexture()
  if kind == "atLeast" then
    fillBar:SetPoint("LEFT", auraButton, "LEFT", -margin - (count - 1) * step, 0)
    SpanClip(nativeDisplay.gateClip, fillBar, "TOPLEFT", (count - 1) * step, texture, "BOTTOMRIGHT")
  else
    fillBar:SetPoint("RIGHT", auraButton, "RIGHT", margin, 0)
    SpanClip(nativeDisplay.gateClip, texture, "TOPRIGHT", 0, fillBar, "BOTTOMRIGHT")
  end
  fillBar:Show()
  local ok, refusal = pcall(auraButton.SetApplicationBar, auraButton, fillBar, { maxApplications = capacity })
  if not ok then
    fillBar:Hide()
    WarnStack(auraData, refusal)
    return false
  end
  return true
end

local function StyleStackGate(nativeDisplay, auraData, suppressed)
  local kind, count
  if not suppressed then kind, count = AuraDisplay.StackGate(auraData) end
  if kind ~= "exactly" and nativeDisplay.stackGateText then nativeDisplay.stackGateText:Hide() end
  if (kind == nil or kind == "exactly") and nativeDisplay.stackGate then
    nativeDisplay.button:ClearApplicationBar()
    nativeDisplay.stackGate:Hide()
  end
  if kind == nil then return false end
  if kind == "exactly" then return BindExactStack(nativeDisplay, auraData, count) end
  return BindStackBar(nativeDisplay, auraData, kind, count)
end

local function PickDurationGate(auraData)
  local lower, upper = AuraDisplay.DurationGate(auraData)
  if lower then return lower, upper, "TotalDuration", "Total Duration" end
  lower, upper = AuraDisplay.RemainingGateRange(auraData)
  if lower then return lower, upper, "RemainingDuration", "Remaining Time" end
end

local function HideDurationTexts(nativeDisplay, auraData)
  local countdown
  if auraData.regionType == "text" and nativeDisplay.mainText and AuraDisplay.TextKind(auraData.displayText or "") == "duration" then
    nativeDisplay.mainText:Hide()
  end
  for index, element in AttachedElements(auraData, "subtext") do
    if IsTextOfKind(element, "duration") then
      local shared = (nativeDisplay.sharedElements or {})[index]
      if shared and shared.text then shared.text:Hide() end
      countdown = countdown or element
    end
  end
  return countdown
end

local function StyleGateCountdown(nativeDisplay, auraData, element, lower)
  local sweepCooldown, auraButton = nativeDisplay.cooldown, nativeDisplay.button
  sweepCooldown:Show()
  if auraData.cooldown == false then
    sweepCooldown:SetDrawSwipe(false)
    sweepCooldown:SetDrawEdge(false)
  end
  sweepCooldown:SetHideCountdownNumbers(false)
  sweepCooldown:SetUseAuraDisplayTime(true)
  sweepCooldown:SetMinimumCountdownDuration(lower * 1000)
  StyleCountdown(sweepCooldown, nativeDisplay, element)
  auraButton:SetDurationCooldown(sweepCooldown)
end

function AuraDisplay.StyleDurationGate(nativeDisplay, auraData)
  if nativeDisplay.preview or not nativeDisplay.gateClip then return end
  local lower, upper, property, label = PickDurationGate(auraData)
  local gateText = nativeDisplay.gateText
  if not lower then
    if gateText then gateText:Hide() end
    if nativeDisplay.cooldown then
      nativeDisplay.cooldown:SetCountdownFormatter(nil)
      nativeDisplay.cooldown:SetMinimumCountdownDuration(0)
    end
    if StyleStackGate(nativeDisplay, auraData) then return end
    nativeDisplay.gateClip:SetClipsChildren(false)
    nativeDisplay.gateClip:SetAllPoints(nativeDisplay.button)
    return
  end
  StyleStackGate(nativeDisplay, auraData, true)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local formatter, refusal = RangeFormatter(lower, upper, fill)
  if formatter then
    LayGateText(nativeDisplay.button, gateText, fontSize, margin)
    local ok
    ok, refusal = BindGateText(nativeDisplay.button, gateText, property, formatter)
    if not ok then formatter = nil end
  end
  if not formatter then
    ReportProblem(auraData, ("Blizzard refused the %s check: %s"):format(label, tostring(refusal)))
    return
  end
  gateText:Show()
  SpanClip(nativeDisplay.gateClip, gateText, "TOPLEFT", 0, gateText, "BOTTOMRIGHT")
  local countdown = HideDurationTexts(nativeDisplay, auraData)
  if countdown and auraData.regionType == "icon" and property == "TotalDuration" and nativeDisplay.cooldown then
    StyleGateCountdown(nativeDisplay, auraData, countdown, lower)
  end
end

local function NeedsIconForGlow(auraData)
  if auraData.regionType == "icon" then return end
  local conditionEntry = FindCondition(auraData, function(check, owner)
    if check.variable ~= "faAuraRemaining" and check.variable ~= "faAuraElapsed" then return false end
    if not AuraDisplay.NativeConditionKind(auraData, check) then return false end
    for _, change in ipairs(owner.changes or {}) do
      if IsTable(change) and AuraDisplay.IsGlowProperty(auraData, change.property) then return true end
    end
    return false
  end)
  if conditionEntry then return "A Remaining Time or Elapsed Time glow needs an Icon display." end
end

local function WrongCountdownCondition(auraData)
  local conditionEntry = FindCondition(auraData, function(check)
    return AuraDisplay.NativeConditionKind(auraData, check) and AuraDisplay.IsNativeDurationCondition(check)
      and check.variable ~= "faAuraRemaining"
  end)
  return conditionEntry ~= nil
end

local function PlacementProblem(auraData, auraTrigger, window)
  local label = window and "Remaining Time" or ("Show On: " .. AuraDisplay.showOnValues[AuraDisplay.RawShowOn(auraTrigger)])
  return FirstProblem({
    { window and auraData.regionType ~= "icon", label .. " is available for Icon displays. Use Show On: Aura(s) Found for other display types." },
    { not window and not AuraDisplay.missingTypes[auraData.regionType], label .. " is available for Icon, Bar, Progress Texture and Text displays." },
    { AnchorsToUnitFrame(auraData), label .. " cannot anchor to unit frames or nameplates. Anchor the aura to the screen or a frame." },
  })
end

local function SingleUnitProblem(auraData, auraTrigger)
  if not AuraDisplay.IsSingleUnit(auraTrigger) then
    return "Aura(s) Missing, Always and Remaining Time watch one unit: choose Player, Target, Focus, Pet, Target of Target, Target of Focus or a Specific Unit."
  end
  local window = AuraDisplay.RemainingWindow(auraTrigger) ~= nil
  if UsesRemaining(auraTrigger) and not window then
    return "Remaining Time: pick a comparison and a seconds value of 0 or more."
  end
  if WantsMissing(auraTrigger) or window then
    local fault = PlacementProblem(auraData, auraTrigger, window)
    if fault then return fault end
  end
  if WantsMissing(auraTrigger) and auraTrigger.debuffType == "HARMFUL" and (auraTrigger.unit == "player" or auraTrigger.unit == "pet")
    and (AuraDisplay.UsesSpellIDs(auraTrigger) or AuraDisplay.UsesRankSpellIDs(auraTrigger)) and not AuraDisplay.UsesApproximate(auraTrigger) then
    return "In combat, the client hides your own and your pet's debuffs from spell ID lookup. Enable Approximate Match."
  end
  if window then
    if not (AuraDisplay.SupportsDurationColorCondition and AuraDisplay.SupportsDurationColorCondition()) then
      return "Remaining Time filtering is not available on this client."
    end
    if WrongCountdownCondition(auraData) then
      return "Countdown conditions used with Remaining Time must compare Remaining Time in seconds."
    end
  end
end

local VALIDATION_STEPS = {
  function(auraData, auraTrigger) return AuraDisplay.TotalFilterProblem(auraData, auraTrigger) end,
  function(auraData, auraTrigger) return AuraDisplay.StackFilterProblem(auraData, auraTrigger) end,
  function(auraData, auraTrigger) return AuraDisplay.RemainingGateProblem(auraData, auraTrigger) end,
  function(auraData) return AuraDisplay.FallbackProblem(auraData) end,
  function(auraData) return NeedsIconForGlow(auraData) end,
  function(auraData, auraTrigger)
    if AuraDisplay.IsSingle(auraTrigger, auraData) then return SingleUnitProblem(auraData, auraTrigger) end
  end,
}

function AuraDisplay.ValidateSingle(auraData, auraTrigger)
  for _, step in ipairs(VALIDATION_STEPS) do
    local fault = step(auraData, auraTrigger)
    if fault then return fault end
  end
end

local function Failure(message)
  return Paint(BAD, "Won't work:") .. " " .. message
end

local function ApproximateNote(auraData, auraTrigger)
  local _, _, origin, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if origin and not fault then return "Approximate match, may not be exact." end
  return "Approximate match: shorter debuffs can match too."
end

local function GlowNote(auraData, auraTrigger)
  local edge, _, _, _, elapsed = AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if not edge then return end
  local lateTotal = AuraDisplay.LateGlowTotal(auraTrigger)
  if not (lateTotal and (elapsed or lateTotal > edge)) then return "Glow starts once the aura's duration is known." end
end

function AuraDisplay.TriggerStatus(auraData, auraTrigger)
  local fault = AuraDisplay.Validate(auraData)
  if fault then return Failure(fault) end
  local severity, reason = AuraDisplay.SpellIDFilterNote(auraTrigger)
  if severity == "error" then return Failure(reason) .. " " .. Paint(CAUTION, "Sounds in Actions still play.") end
  local notes = {}
  if AuraDisplay.UsesApproximate(auraTrigger) then
    if not AuraDisplay.ApproximateProfile(auraTrigger) then
      return Failure("the duration of this debuff is not known yet. Add a Total Duration filter.")
    end
    notes[#notes + 1] = ApproximateNote(auraData, auraTrigger)
  end
  if severity == "note" then
    notes[#notes + 1] = auraTrigger.debuffType == "HARMFUL" and "Hostile units only." or "Friendly units only."
  end
  if AuraDisplay.InDynamicGroup(auraData) then
    notes[#notes + 1] = "In a Dynamic Group this display keeps a fixed position. A Modern Aura Group lays it out properly."
  end
  notes[#notes + 1] = GlowNote(auraData, auraTrigger)
  local caption = Paint(GOOD, "Fully usable in combat.")
  for _, note in ipairs(notes) do caption = caption .. " " .. Paint(CAUTION, note) end
  return caption
end

function AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData)
  local auraContainer = nativeDisplay.container
  local gateText = auraContainer and auraContainer.remainingGateText
  local clip
  if gateText and not nativeDisplay.preview then
    clip = nativeDisplay.remainingClip
    if not clip then
      clip = CreateFrame("Frame", nil, nativeDisplay.button, CLIP_TEMPLATE)
      nativeDisplay.remainingClip = clip
    end
    SpanClip(clip, gateText, "TOPLEFT", 0, gateText, "BOTTOMRIGHT")
    clip:Show()
  end
  local limited = not nativeDisplay.preview and auraData.regionType == "icon" and HasWindow(auraData)
  local base = nativeDisplay.gateClip or nativeDisplay.button
  for index, element in AttachedElements(auraData) do
    local hostFrame = (nativeDisplay.elementFrames or {})["shared" .. index]
    if hostFrame then
      local keep = KEEP_WHEN_LIMITED[element.type] or (element.type == "subtext" and ElementTextKind(element) == "duration")
      local target = base
      if limited and not keep then target = clip end
      if not target then
        hostFrame:Hide()
      elseif hostFrame:GetParent() ~= target then
        local frameLevel = hostFrame:GetFrameLevel()
        hostFrame:SetParent(target)
        hostFrame:SetFrameLevel(frameLevel)
        if target == clip then hostFrame:Show() end
      end
    end
  end
end

function AuraDisplay.StyleRemainingList(nativeDisplay, auraData)
  nativeDisplay.remainingHidesIcon = nil
  AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData)
  if nativeDisplay.preview then return end
  local limited = auraData.regionType == "icon" and HasWindow(auraData)
  local overlay = nativeDisplay.conditionOverlay
  if overlay then
    if limited then overlay:Hide() else overlay:Show() end
  end
  if not limited then return end
  nativeDisplay.remainingHidesIcon = true
  if nativeDisplay.icon then
    nativeDisplay.button:ClearIcon()
    nativeDisplay.icon:Hide()
  end
  if nativeDisplay.cooldown then
    nativeDisplay.button:ClearDurationCooldown()
    nativeDisplay.cooldown:Hide()
  end
  if nativeDisplay.border then nativeDisplay.border:Hide() end
end

function AuraDisplay.StyleMissingIcon(nativeDisplay, auraData)
  if nativeDisplay.icon then nativeDisplay.icon:SetDesaturated(auraData.desaturate == true) end
  for _, record in ipairs(nativeDisplay.conditionPreview or {}) do
    if record.kind == "faAuraMissing" then record.texture:Show() else record.texture:Hide() end
  end
  AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
  if nativeDisplay.cooldown then nativeDisplay.cooldown:Hide() end
  for index, element in ipairs(auraData.subRegions or {}) do
    local record = DISPEL_ELEMENTS[element.type] and (nativeDisplay.sharedElements or {})[index]
    if record then
      if record.texture then record.texture:Hide() end
      Private.DispelTypeDisplay.Hide(record.dispelEdges)
    end
  end
end

function AuraDisplay.KeepMissingDesaturated(nativeDisplay, auraData)
  AuraDisplay.ApplyMissingConditions(nativeDisplay, auraData)
end

local function Bound(auraButton, name)
  local bindings = auraButton.bindings
  local list = IsTable(bindings) and bindings[name]
  return IsTable(list) and list or {}
end

local emptyDuration

local function ResetBars(auraButton)
  if not emptyDuration and C_DurationUtil and C_DurationUtil.CreateDuration then
    emptyDuration = C_DurationUtil.CreateDuration()
  end
  for _, binding in ipairs(Bound(auraButton, "DurationBar")) do
    local fillBar = binding.widget
    if emptyDuration then pcall(fillBar.SetTimerDuration, fillBar, emptyDuration) end
    fillBar:SetMinMaxValues(0, 6)
    fillBar:SetValue(0)
  end
  for _, binding in ipairs(Bound(auraButton, "DurationText")) do binding.widget:SetText("") end
end

local function ResetCooldown(nativeDisplay, auraData)
  nativeDisplay.cooldown:Clear()
  nativeDisplay.cooldown:Hide()
  for index, element in AttachedElements(auraData, "subtext") do
    local shared = (nativeDisplay.sharedElements or {})[index]
    if shared and shared.text and IsTextOfKind(element, "duration") then shared.text:Show() end
  end
end

local function ProgressApplied(sweepCooldown, triggerState)
  if triggerState.progressType == "durationObject" and triggerState.durationObject and sweepCooldown.SetCooldownFromDurationObject then
    return (pcall(sweepCooldown.SetCooldownFromDurationObject, sweepCooldown, triggerState.durationObject))
  end
  local duration, expiration = triggerState.duration, triggerState.expirationTime
  if triggerState.progressType == "timed" and ReadableNumber(duration) and ReadableNumber(expiration)
    and duration > 0 and expiration ~= math.huge then
    return (pcall(sweepCooldown.SetCooldown, sweepCooldown, expiration - duration, duration))
  end
  return false
end

local function ShowStateIcon(nativeDisplay, auraData, triggerState)
  local icon = triggerState.icon
  if icon == nil then icon = AuraDisplay.SingleIcon(auraData) end
  if not pcall(nativeDisplay.icon.SetTexture, nativeDisplay.icon, icon) then
    nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
  end
end

local function FollowIcon(missingState, auraData, triggerState)
  local nativeDisplay = missingState.native
  if not triggerState then
    if missingState.following then
      missingState.following = nil
      nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
      ResetCooldown(nativeDisplay, auraData)
    end
    return
  end
  missingState.following = true
  ShowStateIcon(nativeDisplay, auraData, triggerState)
  local sweepCooldown = nativeDisplay.cooldown
  if not ProgressApplied(sweepCooldown, triggerState) then
    ResetCooldown(nativeDisplay, auraData)
    return
  end
  local drawsCooldown = auraData.cooldown ~= false
  sweepCooldown:SetDrawSwipe(drawsCooldown and auraData.cooldownSwipe ~= false)
  sweepCooldown:SetDrawEdge(drawsCooldown and auraData.cooldownEdge == true)
  sweepCooldown:SetReverse(auraData.inverse == true)
  local countdown = HideDurationTexts(nativeDisplay, auraData)
  local hidden = Private.ShouldHideDurationText and Private.ShouldHideDurationText(triggerState) and true or false
  if countdown then
    sweepCooldown:SetHideCountdownNumbers(hidden)
    StyleCountdown(sweepCooldown, nativeDisplay, countdown)
  else
    sweepCooldown:SetHideCountdownNumbers(hidden or auraData.cooldownTextDisabled ~= false)
  end
  sweepCooldown:Show()
end

local function DurationObjectOf(missingState, triggerState)
  if triggerState.progressType == "durationObject" then return triggerState.durationObject end
  local duration, expiration = triggerState.duration, triggerState.expirationTime
  if triggerState.progressType == "timed" and ReadableNumber(duration) and ReadableNumber(expiration)
    and duration > 0 and expiration ~= math.huge then
    local object = missingState.followDuration
    if not object then
      object = C_DurationUtil.CreateDuration()
      missingState.followDuration = object
    end
    if pcall(object.SetTimeFromStart, object, expiration - duration, duration) then return object end
  end
end

local function FollowTicker(auraButton, duration)
  local elapsed = 0
  return function(_, delta)
    elapsed = elapsed + delta
    if elapsed < FOLLOW_TICK then return end
    elapsed = 0
    for _, binding in ipairs(Bound(auraButton, "DurationText")) do
      local formatter = binding.options and binding.options.textFormatter
      if not formatter then
        local made, fallback = pcall(Private.GetDurationTextFormatter, 99, 0, 0)
        formatter = made and fallback or nil
      end
      local ok, caption = pcall(duration.FormatRemainingDuration, duration, formatter, Enum.DurationTimeModifier.RealTime)
      binding.widget:SetText(ok and caption or "")
    end
  end
end

local function FollowTimer(missingState, auraData, triggerState)
  local nativeDisplay = missingState.native
  local auraButton = nativeDisplay.button
  local duration = triggerState and DurationObjectOf(missingState, triggerState)
  if not duration then
    if missingState.following then
      missingState.following = nil
      auraButton:SetScript("OnUpdate", nil)
      ResetBars(auraButton)
      nativeDisplay.icon:SetTexture(AuraDisplay.SingleIcon(auraData))
    end
    return
  end
  missingState.following = true
  ShowStateIcon(nativeDisplay, auraData, triggerState)
  local direction = auraData.inverse and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime
  for _, binding in ipairs(Bound(auraButton, "DurationBar")) do
    pcall(binding.widget.SetTimerDuration, binding.widget, duration, Enum.StatusBarInterpolation.Immediate, direction)
  end
  if #Bound(auraButton, "DurationText") == 0 then
    auraButton:SetScript("OnUpdate", nil)
  else
    auraButton:SetScript("OnUpdate", FollowTicker(auraButton, duration))
  end
end

local function ResolveSource(auraRegion, auraData, origin)
  if origin ~= "next" then return origin end
  local pilot = PilotIndex(auraData)
  for index in ipairs(auraData.triggers or {}) do
    local triggerState = auraRegion.states and auraRegion.states[index]
    if index ~= pilot and Followable(auraData, index) and IsTable(triggerState) and triggerState.show then return index end
  end
end

local function ApplySource(auraRegion, auraData, missingState, origin)
  local resolved = ResolveSource(auraRegion, auraData, origin)
  local triggerState = resolved and auraRegion.states and auraRegion.states[resolved]
  if not (IsTable(triggerState) and triggerState.show) then triggerState = nil end
  if auraData.regionType == "icon" then FollowIcon(missingState, auraData, triggerState) else FollowTimer(missingState, auraData, triggerState) end
  missingState.native.button:SetAlpha((not missingState.foundMode or missingState.following) and 1 or 0)
end

function AuraDisplay.UpdateMissingSource(auraRegion)
  local nativeDisplay = auraRegion.blizzardAuraDisplay
  if not (nativeDisplay and nativeDisplay.active) then return end
  local origin = AuraDisplay.MissingSource(nativeDisplay.data)
  for _, instance in ipairs(nativeDisplay.instances or {}) do
    local missingState = instance.single and instance.single.missing
    if missingState and missingState.active and (origin or missingState.following) then
      ApplySource(auraRegion, nativeDisplay.data, missingState, origin)
    end
  end
end

local function MissingMargin(auraData, iconWidth, iconHeight)
  local largest = math.ceil(math.max(iconWidth, iconHeight))
  local margin = 2 * largest + 64
  for _, element in ipairs(auraData.subRegions or {}) do
    local reach = 0
    for _, slotKey in ipairs(OFFSET_KEYS) do reach = math.max(reach, math.abs(tonumber(element[slotKey]) or 0)) end
    local extra = largest + reach + 64
    if element.type == "subglow" then extra = extra + math.ceil(math.max(iconWidth, iconHeight) * (element.glowScale or 1)) end
    margin = math.max(margin, extra)
  end
  return margin
end

local function CreateGroupContainer(auraRegion, auraData, slotKey, filterString, options)
  local auraContainer = AuraDisplay.CreateAuraContainer(auraRegion, auraData)
  auraContainer:SetEnabled(false)
  auraContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  auraContainer:SetPoint("TOPLEFT", auraRegion, "TOPLEFT")
  local ok, refusal = pcall(auraContainer.AddAuraGroup, auraContainer, slotKey, filterString, options)
  if not ok then auraContainer:Hide() end
  return auraContainer, ok, refusal
end

local function UpdateGroup(auraContainer, slotKey, filterString, candidateList, layout)
  auraContainer:SetAuraGroupFilterString(slotKey, filterString)
  auraContainer:SetAuraGroupCandidateFilters(slotKey, candidateList)
  auraContainer:SetAuraGroupLayout(slotKey, layout)
  auraContainer:SetAuraGroupEnabled(slotKey, true)
end

local function SilenceFollower(owner, slotKey)
  local trailer = owner[slotKey]
  if trailer then
    trailer:SetEnabled(false)
    trailer:Hide()
  end
end

local function EnsurePresence(missingState, auraRegion, auraData, filterString, candidateList)
  missingState.presenceActive = false
  if not (AuraDisplay.FlowGroup and AuraDisplay.FlowGroup(auraData)) then
    SilenceFollower(missingState, "presence")
    return
  end
  if missingState.presenceFailed then return end
  local layout = AuraDisplay.FlowPresenceSize(auraData)
  if missingState.presence then
    UpdateGroup(missingState.presence, PRESENCE_GROUP, filterString, candidateList, layout)
  else
    local auraContainer, ok, refusal = CreateGroupContainer(auraRegion, auraData, PRESENCE_GROUP, filterString, {
      maxFrameCount = 1,
      candidateFilters = candidateList,
      layout = layout,
      initializeFrame = function(auraButton)
        auraButton:EnableMouse(false)
        auraButton:SetAlpha(0)
        auraButton:SetSize(layout.elementWidth, layout.elementHeight)
      end,
    })
    if not ok then
      missingState.presenceFailed = true
      ReportProblem(auraData, "Blizzard could not create the Modern Aura Group spacing: " .. tostring(refusal))
      return
    end
    missingState.presence = auraContainer
  end
  missingState.presenceBoundUnit = nil
  if AuraDisplay.AnchorFlowPresence(auraRegion, auraData, missingState.presence) then
    missingState.presenceActive = true
    return
  end
  SilenceFollower(missingState, "presence")
  ReportProblem(auraData, "Blizzard refused the Modern Aura Group spacing; this display keeps a fixed space.")
end

local function SpellName(auraTrigger)
  local spellId = AuraDisplay.GetSpellIDs(auraTrigger, false)[1]
  local info = spellId and C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
  return IsTable(info) and info.name or ""
end

local function StyleMissingButton(missingState, auraRegion, auraData, auraTrigger)
  local nativeDisplay = missingState.native
  AuraDisplay.StyleNative(nativeDisplay, auraData, auraRegion)
  nativeDisplay.button:ClearAllPoints()
  nativeDisplay.button:SetPoint("TOPLEFT", AuraDisplay.ContentAnchor(auraRegion), "TOPLEFT")
  AuraDisplay.FillSampleBindings(nativeDisplay.button, AuraDisplay.SingleIcon(auraData), SpellName(auraTrigger), auraData, false)
  AuraDisplay.StyleMissingIcon(nativeDisplay, auraData)
end

local function BuildMissing(singleState, auraRegion, auraData, filterString, candidateList, layout)
  local missingState = singleState.missing
  local iconHeight = layout.elementHeight
  local auraContainer, ok, refusal = CreateGroupContainer(auraRegion, auraData, MISSING_GROUP, filterString, {
    maxFrameCount = 1,
    candidateFilters = candidateList,
    layout = layout,
    initializeFrame = function(auraButton)
      auraButton:SetSize(layout.elementWidth, iconHeight)
      auraButton:EnableMouse(false)
    end,
  })
  if not ok then
    singleState.missingFailed = "Blizzard could not create the Aura(s) Missing display: " .. tostring(refusal)
    ReportProblem(auraData, singleState.missingFailed)
    return false
  end
  local clip = CreateFrame("Frame", nil, auraRegion, CLIP_TEMPLATE)
  clip:EnableMouse(false)
  clip:SetClipsChildren(true)
  missingState.container, missingState.clip = auraContainer, clip
  missingState.native = AuraDisplay.CreateSampleNative(clip)
  return true
end

local function PlaceMissing(missingState, auraRegion, margin)
  local auraContainer, clip = missingState.container, missingState.clip
  local reference = auraRegion
  if AuraDisplay.AnchorToContent(auraContainer, "TOPLEFT", auraRegion, "TOPLEFT", 0, 0) then
    reference = AuraDisplay.ContentAnchor(auraRegion)
  end
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", auraContainer, "TOPRIGHT", -1 - margin, margin)
  clip:SetPoint("BOTTOMRIGHT", reference, "BOTTOMRIGHT", margin, -margin)
end

local function EnsureMissing(instance, auraRegion, auraData, auraTrigger)
  local singleState = instance.single
  if singleState.missingFailed then
    ReportProblem(auraData, singleState.missingFailed)
    return
  end
  singleState.missing = singleState.missing or {}
  local missingState = singleState.missing
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local margin = MissingMargin(auraData, iconWidth, iconHeight)
  local layout = { elementWidth = iconWidth + 1 + 2 * margin, elementHeight = iconHeight }
  local filterString, candidateList = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData)
  if missingState.container then
    UpdateGroup(missingState.container, MISSING_GROUP, filterString, candidateList, layout)
  elseif not BuildMissing(singleState, auraRegion, auraData, filterString, candidateList, layout) then
    return
  end
  PlaceMissing(missingState, auraRegion, margin)
  EnsurePresence(missingState, auraRegion, auraData, filterString, candidateList)
  local frameLevel = auraRegion:GetFrameLevel() + 1
  missingState.clip:SetFrameLevel(frameLevel)
  missingState.container:SetFrameLevel(frameLevel)
  StyleMissingButton(missingState, auraRegion, auraData, auraTrigger)
  missingState.active = true
  local auraButton = missingState.native.button
  auraButton:SetScript("OnUpdate", nil)
  if missingState.following then ResetBars(auraButton) end
  missingState.following = nil
  missingState.foundMode = singleState.foundMode
  auraButton:SetAlpha(1)
  local origin = AuraDisplay.MissingSource(auraData, auraTrigger)
  if origin or missingState.foundMode then ApplySource(auraRegion, auraData, missingState, origin) end
end

local function DisableMissing(singleState)
  local missingState = singleState.missing
  if not (missingState and missingState.active) then return end
  missingState.active = false
  for _, slotKey in ipairs(FOLLOWER_KEYS) do SilenceFollower(missingState, slotKey) end
  SilenceFollower(missingState, "container")
  pcall(missingState.container.SetAuraGroupEnabled, missingState.container, MISSING_GROUP, false)
  missingState.clip:Hide()
  if missingState.native then AuraDisplay.StopSampleAnimations(missingState.native) end
  missingState.boundUnit = nil
end

local function RemainingColorCurve(auraData, operator, seconds)
  local color = IsTable(auraData.color) and auraData.color or {}
  local red, green, blue = color[1] or 1, color[2] or 1, color[3] or 1
  local before = CreateColor(red, green, blue, color[4] or 1)
  local after = CreateColor(red, green, blue, 0)
  if operator == ">" or operator == ">=" then before, after = after, before end
  local edge = WindowEdge(operator, seconds)
  local stepCurve = C_CurveUtil.CreateColorCurve()
  stepCurve:SetType(Enum.LuaCurveType.Step)
  if edge > 0 then stepCurve:AddPoint(0, before) end
  stepCurve:AddPoint(edge, after)
  return stepCurve
end

local function IconTag(auraData)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local left, right, top, bottom = AuraDisplay.IconTexCoords(auraData)
  local function scaled(value) return Round(value * TEXCOORD_SCALE) end
  return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(tostring(AuraDisplay.SingleIcon(auraData)), iconHeight, iconWidth,
    TEXCOORD_SCALE, TEXCOORD_SCALE, scaled(left), scaled(right), scaled(top), scaled(bottom))
end

local function AcquireSlot(instance, auraRegion, auraData, auraTrigger, slotKey)
  local singleState, auraContainer = instance.single, instance.container
  local filterString, candidateList = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData)
  local remainSlot = singleState.slots[slotKey]
  if not remainSlot then
    local captured
    local ok, refusal = pcall(auraContainer.AddAuraSlot, auraContainer, slotKey, filterString, {
      candidateFilters = candidateList,
      initializeFrame = function(auraButton)
        auraButton:EnableMouse(false)
        captured = auraButton
      end,
    })
    if not ok or not captured then
      ReportProblem(auraData, "Blizzard could not create the Remaining Time display: " .. tostring(ok and "no slot" or refusal))
      return nil
    end
    remainSlot = { button = captured }
    singleState.slots[slotKey] = remainSlot
  end
  auraContainer:SetAuraSlotEnabled(slotKey, false)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  remainSlot.button:SetSize(iconWidth, iconHeight)
  remainSlot.button:ClearAllPoints()
  remainSlot.button:SetPoint("TOPLEFT", AuraDisplay.ContentAnchor(auraRegion), "TOPLEFT")
  auraContainer:SetAuraSlotFilterString(slotKey, filterString)
  auraContainer:SetAuraSlotCandidateFilters(slotKey, candidateList)
  auraContainer:SetAuraSlotSortMethod(slotKey, AuraDisplay.SortOrder(auraData, auraTrigger))
  remainSlot.used = true
  return remainSlot
end

local function SlotText(remainSlot, centered)
  if not remainSlot.text then
    remainSlot.text = remainSlot.button:CreateFontString()
    if centered then
      remainSlot.text:SetFont(STANDARD_TEXT_FONT, 12, "")
      remainSlot.text:SetPoint("CENTER")
    end
  end
  return remainSlot.text
end

local function BindRemainingIcon(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  local remainSlot = AcquireSlot(instance, auraRegion, auraData, auraTrigger, SLOT_ICON)
  if not remainSlot then return false end
  local caption = SlotText(remainSlot, true)
  remainSlot.button:ClearDurationText()
  local ok, refusal = pcall(remainSlot.button.SetDurationText, remainSlot.button, caption, {
    textFormat = { formatString = IconTag(auraData), components = {} },
    textColor = {
      property = Enum.DurationTextBindingProperty.RemainingDuration,
      curve = RemainingColorCurve(auraData, operator, seconds),
    },
  })
  if not ok then
    ReportProblem(auraData, "Blizzard refused the Remaining Time icon: " .. tostring(refusal))
    return false
  end
  local iconHost = instance.container
  iconHost:SetAuraSlotEnabled(SLOT_ICON, true)
  return true
end

local function BindRemainingGate(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  local remainSlot = AcquireSlot(instance, auraRegion, auraData, auraTrigger, SLOT_GATE)
  if not remainSlot then return end
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local lower, upper = WINDOW_RANGES[operator](seconds)
  local formatter, refusal = RangeFormatter(lower, upper, fill)
  local caption = SlotText(remainSlot)
  if formatter then
    LayGateText(remainSlot.button, caption, fontSize, margin)
    local ok
    ok, refusal = BindGateText(remainSlot.button, caption, "RemainingDuration", formatter)
    if not ok then formatter = nil end
  end
  if not formatter then
    ReportProblem(auraData, "Blizzard refused the Remaining Time check: " .. tostring(refusal))
    return
  end
  caption:Show()
  instance.container.remainingGateText = caption
  instance.container:SetAuraSlotEnabled(SLOT_GATE, true)
end

local function ConfigureRemainingSlots(instance, auraRegion, auraData, auraTrigger)
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  if BindRemainingIcon(instance, auraRegion, auraData, auraTrigger, operator, seconds) then
    BindRemainingGate(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  end
end

function AuraDisplay.ConfigureSingle(instance, auraRegion, auraData, index)
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local valid = index == 1 and AuraDisplay.ValidateSingle(auraData, auraTrigger) == nil
  local unique = valid and AuraDisplay.IsSingle(auraTrigger, auraData)
  if valid then
    AuraDisplay.WatchAuraLearning(auraRegion, auraData, auraTrigger, (AuraDisplay.LateGlowSpec(auraData, auraTrigger)))
  elseif index == 1 then
    AuraDisplay.ReleaseAuraLearning(auraRegion)
  end
  local followsFound = valid and not unique and AuraDisplay.FoundFollow(auraData, auraTrigger) ~= nil
  if not unique and not followsFound and not instance.single then return end
  local singleState = instance.single or {}
  instance.single = singleState
  singleState.slots = singleState.slots or {}
  for _, remainSlot in pairs(singleState.slots) do remainSlot.used = false end
  singleState.foundMode = followsFound
  if (unique and WantsMissing(auraTrigger)) or followsFound then
    EnsureMissing(instance, auraRegion, auraData, auraTrigger)
  else
    DisableMissing(singleState)
  end
  local auraContainer = instance.container
  auraContainer.remainingGateText = nil
  if unique and AuraDisplay.RemainingWindow(auraTrigger) then ConfigureRemainingSlots(instance, auraRegion, auraData, auraTrigger) end
  for _, nativeDisplay in ipairs(instance.buttons) do AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData) end
  for slotKey, remainSlot in pairs(singleState.slots) do
    if not remainSlot.used then pcall(auraContainer.SetAuraSlotEnabled, auraContainer, slotKey, false) end
  end
  local draws = not unique or AuraDisplay.RawShowOn(auraTrigger) ~= "showOnMissing"
  singleState.listDisabled = not draws
  auraContainer:SetAuraGroupEnabled(LIST_GROUP, draws)
  for _, nativeDisplay in ipairs(instance.buttons) do nativeDisplay.button:SetAlpha(draws and 1 or 0) end
end

local function BindUnit(owner, slotKey, unitToken)
  local bound = slotKey == "container" and "boundUnit" or slotKey .. "BoundUnit"
  if unitToken ~= nil and unitToken ~= owner[bound] then
    owner[slotKey]:SetEnabled(false)
    owner[slotKey]:SetUnit(unitToken)
    owner[bound] = unitToken
  end
end

function AuraDisplay.RefreshSingle(instance, unitToken, shown)
  local singleState = instance.single
  if not singleState then return end
  if shown and singleState.listDisabled then
    pcall(instance.container.SetAuraGroupEnabled, instance.container, LIST_GROUP, false)
  end
  local missingState = singleState.missing
  if not (missingState and missingState.active) then return end
  BindUnit(missingState, "container", unitToken)
  shown = (shown and unitToken ~= nil) and true or false
  missingState.container:SetShown(shown)
  missingState.container:SetEnabled(shown)
  for _, slotKey in ipairs(FOLLOWER_KEYS) do
    local trailer = missingState[slotKey]
    if trailer and missingState[slotKey .. "Active"] then
      BindUnit(missingState, slotKey, unitToken)
      trailer:SetShown(shown)
      trailer:SetEnabled(shown)
      if shown then trailer:UpdateAllAuras() end
    end
  end
  missingState.clip:SetShown(shown)
  local auraTrigger = instance.data and AuraDisplay.GetTrigger(instance.data)
  local present = (IsTable(auraTrigger) and auraTrigger.unitExists) or AuraDisplay.SingleUnitExists({ unit = unitToken })
  missingState.clip:SetAlpha(present and 1 or 0)
  if shown then missingState.container:UpdateAllAuras() end
end

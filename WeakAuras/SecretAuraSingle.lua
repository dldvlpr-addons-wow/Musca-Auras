-- Single-aura mode of the native display: remaining window, fallback and missing states, learned
-- durations and profiles. Fills Private.BlizzardAuraDisplay; called by BlizzardAuraDisplay.lua,
-- SecretAuraTrigger.lua, SecretAuraAppearance.lua, SecretAuraPreview.lua and TriggerOptions.lua.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Disp = Private.BlizzardAuraDisplay

local MISSING_GROUP_NAME = "MuscaMissing"
local PRESENCE_GROUP_NAME = "MuscaPresence"
local REMAINING_ICON_SLOT = "MuscaRemainIcon"
local REMAINING_GATE_SLOT = "MuscaRemainGate"
local EDGE_EPSILON = 0.001
local TEXCOORD_SCALE = 1024
local GATE_TOLERANCE = 0.5
local LATE_K, LATE_MAX_WIDTH = 2000, 200000
local FOLLOW_TEXT_INTERVAL = 0.1
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local COUNTDOWN_PREFIX = "text_text_format_p_time_"
local GREEN, ORANGE, RED = "|cff33ff99", "|cffff9933", "|cffff2020"
local FOLLOWER_KEYS = {"presence", "flowShadow"}
local DISPEL_ELEMENT_TYPES = {subcdmdispel = true, subcdmdispelborder = true}
local MISSING_MODES = {showOnMissing = true, showAlways = true}
local PROBLEM_CHECKS = {"TotalFilterProblem", "StackFilterProblem", "RemainingGateProblem"}
local STACK_SHIFTS = {[">"] = {">=", 1}, ["<"] = {"<=", -1}}
local FINGERPRINT_FLAGS = {"canApplyAura", "isStealable", "isBossAura", "isFromPlayerOrPlayerPet", "nameplateShowAll", "nameplateShowPersonal"}
local FRIENDLY_CATEGORIES = {player = true, pet = true, group = true, party = true, raid = true}
local HOSTILE_CATEGORIES = {boss = true, arena = true}
local GROUP_UNIT_CATEGORIES = {group = true, party = true, raid = true}
local BOTH_FILTERS, DEBUFF_FILTER = {"HELPFUL", "HARMFUL"}, {"HARMFUL"}
local FIXED_UNITS = {"player", "target", "focus", "pet"}

Disp.singleUnits = {player = true, target = true, focus = true, pet = true, targettarget = true, focustarget = true}
Disp.showOnValues = {showOnActive = "Aura(s) Found", showOnMissing = "Aura(s) Missing", showAlways = "Always"}
Disp.remOperators = {["<"] = "<", ["<="] = "<=", [">"] = ">", [">="] = ">="}
Disp.totalOperators = {["="] = "=", ["<="] = "<=", [">="] = ">="}
Disp.stackOperators = {["="] = "=", [">="] = ">=", [">"] = ">", ["<="] = "<=", ["<"] = "<"}
Disp.approximateUnits = {player = true, pet = true, group = true, party = true, raid = true}
Disp.STACK_LIMIT = 100
local missingTypes = {icon = true, aurabar = true, progresstexture = true, text = true}
Disp.missingTypes = missingTypes

local windowTests = {
  ["<"] = function(value, limit) return value < limit end,
  ["<="] = function(value, limit) return value <= limit end,
  [">"] = function(value, limit) return value > limit end,
}

local function Warn(auraData, message)
  Private.AuraWarnings.UpdateWarning(auraData.uid, "blizzard_aura_single", message and "warning" or nil, message)
end
Disp.ClearSingleWarning = function(auraData) Warn(auraData) end

local function AnchoredToUnitOrPlate(auraData)
  return Disp.FrameAnchorType(auraData) == "UNITFRAME" or Disp.FrameAnchorType(auraData) == "NAMEPLATE"
end

function Disp.IsSingleUnit(auraTrigger)
  if type(auraTrigger) ~= "table" then return false end
  if auraTrigger.unit ~= "member" then return Disp.singleUnits[auraTrigger.unit] == true end
  return Disp.SpecificUnit(auraTrigger) ~= nil
end

function Disp.RawShowOn(auraTrigger)
  local mode = type(auraTrigger) == "table" and auraTrigger.secretShowOn
  if Disp.showOnValues[mode] then return mode end
  return "showOnActive"
end
Disp.ShowOn = Disp.RawShowOn

local function remainingEnabled(auraTrigger)
  if type(auraTrigger) ~= "table" or auraTrigger.secretUseRem ~= true then return false end
  return Disp.ShowOn(auraTrigger) == "showOnActive"
end

function Disp.IsSingle(auraTrigger, auraData)
  if Disp.ShowOn(auraTrigger) ~= "showOnActive" then return true end
  if not remainingEnabled(auraTrigger) then return false end
  local otherDisplay = auraData and auraData.regionType ~= "icon"
  return not otherDisplay
end

function Disp.RemainingWindow(auraTrigger)
  if not remainingEnabled(auraTrigger) then return end
  local operator, seconds = auraTrigger.secretRemOperator or "<", tonumber(auraTrigger.secretRem)
  if not Disp.remOperators[operator] or not seconds or seconds ~= seconds or seconds < 0 or seconds == math.huge then return end
  return operator, seconds
end

function Disp.InRemainingWindow(value, operator, limit)
  local test = windowTests[operator]
  if test then return test(value, limit) end
  return value >= limit
end

function Disp.RemainingWindowPoints(_, limit)
  local upper = limit + EDGE_EPSILON
  return {limit, upper}
end

local function wantsMissing(auraTrigger)
  return MISSING_MODES[Disp.ShowOn(auraTrigger)] == true
end

local function drawsOne(auraData)
  return Disp.IsSingle(Disp.GetTrigger(auraData), auraData)
end
Disp.DrawsOne = drawsOne

function Disp.Growth(auraData)
  local flowGrowth = Disp.FlowGrowth(auraData)
  if flowGrowth then return Disp.VisibleGrowth(flowGrowth) end
  if drawsOne(auraData) then return "RIGHT" end
  local settings = auraData.blizzardAuraDisplay
  return settings and settings.growth or "RIGHT"
end

function Disp.MaxAuras(auraData)
  if Disp.UsesGate(auraData) then return 10 end
  if drawsOne(auraData) then return 1 end
  local flowLimit = Disp.FlowLimit(auraData)
  if flowLimit then return flowLimit end
  local settings = auraData.blizzardAuraDisplay
  return settings and settings.maxIcons or 10
end

function Disp.PreviewShowsMissing(auraData)
  local auraTrigger = Disp.GetTrigger(auraData)
  local singleState = Disp.IsSingle(auraTrigger)
  if not singleState then return singleState end
  return Disp.ShowOn(auraTrigger) == "showOnMissing"
end

function Disp.SingleIcon(auraData)
  local manualIcon = auraData.displayIcon
  if auraData.iconSource == 0 and manualIcon and manualIcon ~= "" then return manualIcon end
  local spellId = Disp.GetSpellIDs(Disp.GetTrigger(auraData) or {}, false)[1]
  local texture = spellId and C_Spell.GetSpellTexture(spellId)
  if texture and not issecretvalue(texture) then return texture end
  return 134400
end

function Disp.SingleUnitExists(auraTrigger)
  local unit = auraTrigger and auraTrigger.unit or "player"
  if unit == "player" then return true end
  if unit == "member" then
    unit = Disp.SpecificUnit(auraTrigger)
    if not unit then return false end
  end
  local succeeded, exists = pcall(UnitExists, unit)
  if succeeded and not issecretvalue(exists) then return exists == true end
  return true
end

local function hasRemainingPercentConditions(auraData)
  for _, condition in ipairs(auraData.conditions or {}) do
    local check = condition.check
    if check and Disp.NativeConditionKind(auraData, check) and Disp.IsNativeDurationCondition(check)
      and check.variable ~= "faAuraRemaining" then
      return true
    end
  end
  return false
end

function Disp.FitsOneSlot(auraData, auraTrigger)
  if not auraTrigger or not Disp.IsSingleUnit(auraTrigger) then return false end
  local anchorType = auraData.anchorFrameType
  return anchorType ~= "UNITFRAME" and anchorType ~= "NAMEPLATE"
end

local function parentOf(node)
  return node and node.parent and WeakAuras.GetData(node.parent)
end

function Disp.InDynamicGroup(auraData)
  local ancestor = parentOf(auraData)
  while ancestor do
    if ancestor.regionType == "dynamicgroup" then return true end
    ancestor = parentOf(ancestor)
  end
  return false
end

function Disp.MigrateSingle(auraData, auraTrigger)
  local tracking = auraTrigger.secretTracking
  if tracking == nil then return end
  if tracking == "single" then
    local legacyMode = auraTrigger.matchesShowOn
    if auraTrigger.secretShowOn == nil and Disp.showOnValues[legacyMode] and legacyMode ~= "showOnActive" then
      auraTrigger.secretShowOn = legacyMode
    end
    if auraTrigger.secretUseRem == nil and auraTrigger.useRem then
      auraTrigger.secretUseRem = true
      auraTrigger.secretRemOperator = auraTrigger.remOperator
      auraTrigger.secretRem = auraTrigger.rem
    end
    local settings = auraData.blizzardAuraDisplay or {}
    auraData.blizzardAuraDisplay = settings
    settings.maxIcons = 1
  end
  auraTrigger.secretTracking = nil
end

local secrecyCache = {}
local function allNeverSecret(ids)
  if #ids == 0 then return false end
  if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy and Enum.SecrecyLevel) then return false end
  for _, spellId in ipairs(ids) do
    local verdict = secrecyCache[spellId]
    if verdict == nil then
      local succeeded, level = pcall(C_Secrets.GetSpellAuraSecrecy, spellId)
      verdict = succeeded and not issecretvalue(level) and level == Enum.SecrecyLevel.NeverSecret
      secrecyCache[spellId] = verdict
    end
    if not verdict then return false end
  end
  return true
end

function Disp.SpellIDFilterNote(auraTrigger)
  if not (Disp.UsesSpellIDs(auraTrigger) or Disp.UsesRankSpellIDs(auraTrigger) or Disp.UsesExcludedSpellIDs(auraTrigger)) then return end
  if Disp.UsesApproximate(auraTrigger) then return end
  local ids = Disp.GetSpellIDs(auraTrigger, true)
  if Disp.UsesExcludedSpellIDs(auraTrigger) then
    for _, excluded in ipairs(auraTrigger.excludedAuraSpellIDs or {}) do
      local numeric = tonumber(excluded)
      if numeric then ids[#ids + 1] = numeric end
    end
  end
  if allNeverSecret(ids) then return end
  local debuff = auraTrigger.debuffType == "HARMFUL"
  local category = Disp.UnitCategory(auraTrigger)
  local unitLabel = auraTrigger.unit == "member" and Disp.SpecificUnit(auraTrigger) or Disp.units[auraTrigger.unit] or auraTrigger.unit
  local friendly, hostile = FRIENDLY_CATEGORIES[category], HOSTILE_CATEGORIES[category]
  if (debuff and friendly) or (not debuff and hostile) then
    if debuff and Disp.approximateUnits[category] then
      return "error", string.format("Blizzard hides debuffs on %s from spell ID filters in combat. Try Approximate Match.", unitLabel)
    end
    return "error", string.format("Blizzard hides %s on %s from spell ID filters in combat.", debuff and "debuffs" or "buffs", unitLabel)
  end
  if not friendly and not hostile then
    return "note", string.format("%s selected by spell ID only match while the unit is %s.",
      debuff and "Debuffs" or "Buffs", debuff and "hostile" or "friendly")
  end
end

function Disp.TriggerStatus(auraData, auraTrigger)
  local problem = Disp.Validate(auraData)
  if problem then return RED .. "Won't work:|r " .. problem end
  local severity, reason = Disp.SpellIDFilterNote(auraTrigger)
  if severity == "error" then
    return RED .. "Won't work:|r " .. reason .. " " .. ORANGE .. "Sounds in Actions still play.|r"
  end
  local notes = {}
  if Disp.UsesApproximate(auraTrigger) then
    if not Disp.ApproximateProfile(auraTrigger) then
      return RED .. "Won't work:|r This debuff's duration isn't known. Add a Total Duration filter."
    end
    local _, _, source, gateProblem = Disp.GateRange(auraData, auraTrigger)
    if source and not gateProblem then
      notes[#notes + 1] = "Approximate match, may not be exact."
    else
      notes[#notes + 1] = "Approximate match: shorter debuffs can match too."
    end
  end
  if severity == "note" then
    notes[#notes + 1] = auraTrigger.debuffType == "HARMFUL" and "Hostile units only." or "Friendly units only."
  end
  if Disp.InDynamicGroup(auraData) then
    notes[#notes + 1] = "In a Dynamic Group it keeps a fixed position; a Modern Aura Group is recommended."
  end
  local lateEdge = Disp.LateGlowSpec(auraData, auraTrigger)
  if lateEdge then
    local total = Disp.LateGlowTotal(auraTrigger)
    if not (total and total > lateEdge) then notes[#notes + 1] = "Glow starts once the aura's duration is known." end
  end
  local text = GREEN .. "Works in combat.|r"
  for _, note in ipairs(notes) do text = text .. " " .. ORANGE .. note .. "|r" end
  return text
end

local function needsIconForGlow(auraData)
  for _, condition in ipairs(auraData.conditions or {}) do
    local check = condition.check
    if check and check.variable == "faAuraRemaining" and Disp.NativeConditionKind(auraData, check) then
      for _, change in ipairs(condition.changes or {}) do
        if Disp.IsGlowProperty(auraData, change.property) then return true end
      end
    end
  end
  return false
end

function Disp.ValidateSingle(auraData, auraTrigger)
  for _, checkName in ipairs(PROBLEM_CHECKS) do
    local issue = Disp[checkName](auraData, auraTrigger)
    if issue then return issue end
  end
  local fallbackIssue = Disp.FallbackProblem(auraData)
  if fallbackIssue then return fallbackIssue end
  if auraData.regionType ~= "icon" and needsIconForGlow(auraData) then return "A Remaining Time glow needs an Icon display." end
  if not Disp.IsSingle(auraTrigger, auraData) then return end
  if not Disp.IsSingleUnit(auraTrigger) then
    return "Aura(s) Missing, Always and Remaining Time watch one unit: choose Player, Target, Focus, Pet, Target of Target, Target of Focus or a Specific Unit."
  end
  local showOn = Disp.ShowOn(auraTrigger)
  local operator = Disp.RemainingWindow(auraTrigger)
  if remainingEnabled(auraTrigger) and not operator then
    return "Remaining Time needs a comparison and a number of seconds of 0 or more."
  end
  if wantsMissing(auraTrigger) or operator then
    local label = operator and "Remaining Time" or ("Show On: " .. Disp.showOnValues[showOn])
    if operator and auraData.regionType ~= "icon" then
      return label .. " is available for Icon displays. Use Show On: Aura(s) Found for other display types."
    end
    if not operator and not missingTypes[auraData.regionType] then
      return label .. " is available for Icon, Bar, Progress Texture and Text displays."
    end
    if AnchoredToUnitOrPlate(auraData) then
      return label .. " cannot anchor to unit frames or nameplates. Anchor the aura to the screen or a frame."
    end
  end
  if wantsMissing(auraTrigger) and auraTrigger.debuffType == "HARMFUL" and (auraTrigger.unit == "player" or auraTrigger.unit == "pet")
    and (Disp.UsesSpellIDs(auraTrigger) or Disp.UsesRankSpellIDs(auraTrigger)) and not Disp.UsesApproximate(auraTrigger) then
    return "Debuffs on you or your pet can't be found by spell ID in combat. Tick Approximate Match."
  end
  if operator then
    if not Disp.SupportsDurationColorCondition() then return "This client cannot limit auras by Remaining Time." end
    if hasRemainingPercentConditions(auraData) then
      return "With Remaining Time, countdown conditions must use Remaining Time in seconds."
    end
  end
end

function Disp.MigrateTotal(auraTrigger)
  if auraTrigger.secretUseTotal == nil then
    if auraTrigger.secretExactDuration and tonumber(auraTrigger.secretDuration) then
      auraTrigger.secretUseTotal = true
      auraTrigger.secretTotalOperator = "="
      auraTrigger.secretTotal = tostring(auraTrigger.secretDuration)
      auraTrigger.secretDuration = nil
    elseif type(auraTrigger.maxDuration) == "number" then
      auraTrigger.secretUseTotal = true
      auraTrigger.secretTotalOperator = "<="
      auraTrigger.secretTotal = tostring(auraTrigger.maxDuration)
    end
  end
  auraTrigger.maxDuration = nil
  auraTrigger.secretExactDuration = nil
  auraTrigger.secretDuration = nil
end

local function followable(auraData, index)
  local entry = auraData.triggers and auraData.triggers[index]
  return type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type ~= "secretAura"
end

local function drivingIndex(auraData)
  local saved = Disp.GetSavedTrigger(auraData)
  for position, entry in ipairs(auraData.triggers or {}) do
    if type(entry) == "table" and entry.trigger == saved then return position end
  end
end

local function fallbackPossible(auraData, auraTrigger)
  if not Disp.IsSingleUnit(auraTrigger) or not missingTypes[auraData.regionType] then return false end
  if Disp.FlowGroup and Disp.FlowGroup(auraData) then return false end
  if AnchoredToUnitOrPlate(auraData) then return false end
  return not (Disp.RawShowOn(auraTrigger) == "showOnActive" and auraTrigger.secretUseRem == true)
end

function Disp.FallbackChoice(auraData)
  local configured = auraData.triggers and auraData.triggers.secretFallback
  if configured == "none" then return "none" end
  return tonumber(configured) or "next"
end

function Disp.Fallback(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if type(auraTrigger) ~= "table" or not fallbackPossible(auraData, auraTrigger) then return end
  local driver = drivingIndex(auraData)
  if not driver then return end
  local choice = Disp.FallbackChoice(auraData)
  if choice == "none" then return end
  if choice ~= "next" then
    if choice == driver or not followable(auraData, choice) then return nil end
    return choice
  end
  for position in ipairs(auraData.triggers) do
    if position ~= driver and followable(auraData, position) then return "next" end
  end
end

function Disp.MigrateFallback(auraData)
  local entries = type(auraData.triggers) == "table" and auraData.triggers or {}
  for _, entry in ipairs(entries) do
    local auraTrigger = type(entry) == "table" and entry.trigger
    if type(auraTrigger) == "table" and auraTrigger.secretMissingSource ~= nil then
      local position = tonumber(auraTrigger.secretMissingSource)
      if position and auraData.triggers.secretFallback == nil then auraData.triggers.secretFallback = position end
      auraTrigger.secretMissingSource = nil
    end
  end
end

function Disp.FallbackProblem(auraData)
  local choice = Disp.FallbackChoice(auraData)
  if type(choice) == "number" and not followable(auraData, choice) then
    return "Trigger Combination: the trigger chosen for when Aura (Modern) filters are not met no longer exists or is an Aura (Modern) trigger."
  end
end

function Disp.FoundFollow(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if type(auraTrigger) ~= "table" or Disp.RawShowOn(auraTrigger) ~= "showOnActive" then return end
  return Disp.Fallback(auraData, auraTrigger)
end

function Disp.MissingSource(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if type(auraTrigger) ~= "table" then return end
  if Disp.RawShowOn(auraTrigger) ~= "showOnActive" and not wantsMissing(auraTrigger) then return end
  return Disp.Fallback(auraData, auraTrigger)
end

local function durationPatternsFor(template)
  local variants = {}
  local pluralChoice = template:match("|4([^;]*);")
  if pluralChoice then
    for option in (pluralChoice .. ":"):gmatch("([^:]*):") do
      variants[#variants + 1] = (template:gsub("|4[^;]*;", option, 1))
    end
  else
    variants[1] = template
  end
  local function escapeAffix(text)
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return (text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"):gsub("%s+", "%%s*"):gsub("\194\160", "%%s*"))
  end
  local patterns = {}
  for _, variant in ipairs(variants) do
    variant = variant:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    local head, tail = variant:match("^(.-)%%[%d%$]*[%.%d]*[dfsi](.*)$")
    if head then
      head, tail = escapeAffix(head), escapeAffix(tail)
      if head ~= "" or tail ~= "" then
        local boundary = tail:match("[a-z]$") and "%f[%A]" or ""
        patterns[#patterns + 1] = head .. "%s*" .. "(%d+[%.,]?%d*)" .. "%s*" .. tail .. boundary
      end
    end
  end
  return patterns
end

local GLOBAL_DURATION_FORMATS = {
  {1, {"INT_SPELL_DURATION_SEC", "SPELL_DURATION_SEC", "SECONDS_ABBR", "SECOND_ONELETTER_ABBR", "D_SECONDS"}},
  {60, {"INT_SPELL_DURATION_MIN", "SPELL_DURATION_MIN", "MINUTES_ABBR", "MINUTE_ONELETTER_ABBR", "D_MINUTES"}},
  {3600, {"INT_SPELL_DURATION_HOURS", "SPELL_DURATION_HOURS", "HOURS_ABBR", "HOUR_ONELETTER_ABBR", "D_HOURS"}},
}
local ENGLISH_FORMATS = {
  {1, "%d sec"}, {1, "%d secs"}, {1, "%d second"}, {1, "%d seconds"},
  {60, "%d min"}, {60, "%d mins"}, {60, "%d minute"}, {60, "%d minutes"},
  {3600, "%d hour"}, {3600, "%d hours"}, {3600, "%d hr"}, {3600, "%d hrs"},
}
local cachedPatterns
local function allDurationPatterns()
  if cachedPatterns then return cachedPatterns end
  cachedPatterns = {}
  local known = {}
  local function register(multiplier, template)
    if type(template) ~= "string" then return end
    for _, pattern in ipairs(durationPatternsFor(template)) do
      if not known[pattern] then
        known[pattern] = true
        cachedPatterns[#cachedPatterns + 1] = {pattern, multiplier}
      end
    end
  end
  for _, group in ipairs(GLOBAL_DURATION_FORMATS) do
    for _, globalName in ipairs(group[2]) do register(group[1], _G[globalName]) end
  end
  for _, english in ipairs(ENGLISH_FORMATS) do register(english[1], english[2]) end
  return cachedPatterns
end

local describedDurations = {}
local pendingSpellData = {}
local loadAttempted = {}

local function spellDescriptionText(spellId)
  local chunks = {}
  local succeeded, description = pcall(C_Spell.GetSpellDescription, spellId)
  local loaded = succeeded and type(description) == "string" and not issecretvalue(description) and description ~= ""
  if loaded then chunks[#chunks + 1] = description end
  if C_TooltipInfo and C_TooltipInfo.GetSpellByID then
    local okTooltip, info = pcall(C_TooltipInfo.GetSpellByID, spellId)
    local lines = okTooltip and type(info) == "table" and info.lines or {}
    for _, line in ipairs(lines) do
      for _, side in ipairs({"leftText", "rightText"}) do
        local sideText = line[side]
        if not issecretvalue(sideText) and type(sideText) == "string" then chunks[#chunks + 1] = sideText end
      end
    end
  end
  return table.concat(chunks, "\n"):lower(), loaded
end

local function describedDuration(spellId)
  local cached = describedDurations[spellId]
  if cached ~= nil then return cached or nil end
  if pendingSpellData[spellId] then return end
  local text, loaded = spellDescriptionText(spellId)
  if not loaded then
    if not loadAttempted[spellId] and C_Spell.RequestLoadSpellData then
      pendingSpellData[spellId], loadAttempted[spellId] = true, true
      local requested = pcall(C_Spell.RequestLoadSpellData, spellId)
      if not requested then pendingSpellData[spellId] = nil end
      loaded = not requested
    else
      loaded = loadAttempted[spellId] == true
    end
  end
  local longest
  for _, entry in ipairs(allDurationPatterns()) do
    for number in text:gmatch(entry[1]) do
      local seconds = tonumber((number:gsub(",", ".")))
      seconds = seconds and seconds * entry[2]
      if seconds and seconds > (longest or 0) then longest = seconds end
    end
  end
  if longest or loaded then describedDurations[spellId] = longest or false end
  return longest
end

local function longestDescribed(ids)
  local longest
  for _, spellId in ipairs(ids) do
    local seconds = describedDuration(spellId)
    if seconds and seconds > (longest or 0) then longest = seconds end
  end
  return longest
end

local function learnedDurations()
  if type(WeakAurasSaved) ~= "table" then return end
  WeakAurasSaved.auraDurations = WeakAurasSaved.auraDurations or {}
  return WeakAurasSaved.auraDurations
end

local function learnedProfiles()
  if type(WeakAurasSaved) ~= "table" then return end
  WeakAurasSaved.auraProfiles = WeakAurasSaved.auraProfiles or {}
  return WeakAurasSaved.auraProfiles
end

function Disp.TotalFilter(auraTrigger)
  if type(auraTrigger) ~= "table" or not auraTrigger.secretUseTotal then return end
  local operator, seconds = auraTrigger.secretTotalOperator or "=", tonumber(auraTrigger.secretTotal)
  if not Disp.totalOperators[operator] or not seconds or seconds <= 0 or seconds ~= seconds or seconds == math.huge then return end
  return operator, seconds
end

function Disp.UsesApproximate(auraTrigger)
  return type(auraTrigger) == "table" and auraTrigger.secretApproximate == true and Disp.approximateUnits[Disp.UnitCategory(auraTrigger)]
    and auraTrigger.debuffType == "HARMFUL" and (Disp.UsesSpellIDs(auraTrigger) or Disp.UsesRankSpellIDs(auraTrigger)) or false
end

function Disp.LateGlowTotal(auraTrigger)
  local operator, manual = Disp.TotalFilter(auraTrigger)
  if operator == "=" then return manual, "manual" end
  local ids = Disp.GetSpellIDs(auraTrigger, true)
  local seenDurations, longest = learnedDurations(), nil
  for _, spellId in ipairs(ids) do
    local seconds = seenDurations and tonumber(seenDurations[spellId])
    if seconds and seconds > (longest or 0) then longest = seconds end
  end
  if longest then return longest, "seen" end
  longest = longestDescribed(ids)
  if longest then return longest, "described" end
end

function Disp.ApproximateProfile(auraTrigger)
  local stored = learnedProfiles()
  if not stored then return end
  local merged
  for _, spellId in ipairs(Disp.GetSpellIDs(auraTrigger, true)) do
    local profile = stored[spellId]
    if type(profile) == "table" then
      if merged then
        merged.duration = math.max(merged.duration or 0, profile.duration or 0)
        if merged.dispel ~= profile.dispel then merged.dispel = nil end
        for _, flag in ipairs(FINGERPRINT_FLAGS) do
          if merged[flag] ~= profile[flag] then merged[flag] = nil end
        end
      else
        merged = CopyTable(profile)
      end
    end
  end
  local operator, manual = Disp.TotalFilter(auraTrigger)
  if operator then
    merged = merged or {}
    merged.duration = operator == "=" and manual or nil
    return merged, "manual"
  end
  if merged then return merged, "seen" end
  local longest = longestDescribed(Disp.GetSpellIDs(auraTrigger, true))
  if longest then return {duration = longest}, "duration" end
end

function Disp.ApproximateFilters(auraTrigger, filters)
  if not Disp.UsesApproximate(auraTrigger) then return filters end
  local profile = Disp.ApproximateProfile(auraTrigger)
  if not profile then
    filters.includeSpellIDs = {}
    return filters
  end
  filters.includeSpellIDs, filters.excludeSpellIDs = nil, nil
  if (profile.duration or 0) > 0 then
    filters.maxDuration = math.min(filters.maxDuration or math.huge, profile.duration + 0.5)
  end
  if type(profile.dispel) == "string" then filters.includeDispelTypes = {[profile.dispel] = true} end
  for _, flag in ipairs(FINGERPRINT_FLAGS) do
    if filters[flag] == nil and type(profile[flag]) == "boolean" then filters[flag] = profile[flag] end
  end
  return filters
end

local function gateProblem(auraData, auraTrigger)
  if AnchoredToUnitOrPlate(auraData) then
    return "Total Duration = and >= can't anchor to unit frames or nameplates."
  end
  if Disp.IsSingle(auraTrigger) then
    return "Total Duration = and >= only work with Show On: Aura(s) Found, without Remaining Time."
  end
  local bindings = Enum.DurationTextBindingProperty
  if not (bindings and bindings.TotalDuration ~= nil
    and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Disp.SupportsDurationColorCondition()) then
    return "This client can't check Total Duration = or >=."
  end
end

function Disp.GateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if not auraTrigger then return end
  local operator, seconds = Disp.TotalFilter(auraTrigger)
  local lower, upper, source
  if operator == "=" then
    lower, upper, source = seconds - GATE_TOLERANCE, seconds + GATE_TOLERANCE, "filter"
  elseif operator == ">=" then
    lower, source = seconds - GATE_TOLERANCE, "filter"
  elseif Disp.UsesApproximate(auraTrigger) then
    local profile = Disp.ApproximateProfile(auraTrigger)
    local duration = profile and tonumber(profile.duration)
    if duration and duration > 0 then
      lower, upper, source = duration - GATE_TOLERANCE, duration + GATE_TOLERANCE, "approximate"
    end
  end
  if not source then return end
  return math.max(0.001, lower), upper, source, gateProblem(auraData, auraTrigger)
end

function Disp.DurationGate(auraData, auraTrigger)
  local lower, upper, _, problem = Disp.GateRange(auraData, auraTrigger)
  if lower and not problem then return lower, upper end
end

function Disp.TotalFilterProblem(auraData, auraTrigger)
  local _, _, source, problem = Disp.GateRange(auraData, auraTrigger)
  if source == "filter" and problem then return problem end
end

function Disp.StackFilter(auraTrigger)
  if type(auraTrigger) ~= "table" or not auraTrigger.secretUseStacks then return end
  local operator, count = auraTrigger.secretStacksOperator or ">=", tonumber(auraTrigger.secretStacks)
  if not Disp.stackOperators[operator] or not count or count ~= math.floor(count) or count < 0 or count > Disp.STACK_LIMIT then return end
  if operator == "=" then return "exactly", count end
  local shift = STACK_SHIFTS[operator]
  if shift then operator, count = shift[1], count + shift[2] end
  if operator == ">=" then
    if count <= 0 then return end
    return "atLeast", count
  end
  if count < 0 then return "never" end
  return "atMost", count
end

function Disp.StackFilterProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if type(auraTrigger) ~= "table" or not auraTrigger.secretUseStacks then return end
  local count = tonumber(auraTrigger.secretStacks)
  if not count or count ~= math.floor(count) or count < 0 or count > Disp.STACK_LIMIT then
    return "Stack Count needs a whole number from 0 to " .. Disp.STACK_LIMIT .. "."
  end
  local kind = Disp.StackFilter(auraTrigger)
  if kind == "never" then return "Stack Count < 0 never matches." end
  if not kind then return end
  if AnchoredToUnitOrPlate(auraData) then return "Stack Count can't anchor to unit frames or nameplates." end
  if Disp.IsSingle(auraTrigger) then return "Stack Count only works with Show On: Aura(s) Found, without Remaining Time." end
  if Disp.GateRange(auraData, auraTrigger) then
    return "Stack Count can't be combined with Total Duration = or >=, or with Approximate Match."
  end
  if not (C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions) then
    return "This client can't check Stack Count."
  end
end

function Disp.StackGate(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  local kind, count = Disp.StackFilter(auraTrigger)
  if (kind == "exactly" or kind == "atLeast" or kind == "atMost") and not Disp.StackFilterProblem(auraData, auraTrigger) then
    return kind, count
  end
end

function Disp.RemainingGateProblem(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if auraData.regionType == "icon" or not remainingEnabled(auraTrigger) then return end
  if not Disp.RemainingWindow(auraTrigger) then
    return "Remaining Time needs a comparison and a number of seconds of 0 or more."
  end
  if AnchoredToUnitOrPlate(auraData) then return "Remaining Time can't anchor to unit frames or nameplates." end
  if Disp.GateRange(auraData, auraTrigger) then
    return "On this display type, Remaining Time can't be combined with Total Duration = or >=, or with Approximate Match."
  end
  local bindings = Enum.DurationTextBindingProperty
  if not (bindings and bindings.RemainingDuration ~= nil
    and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Disp.SupportsDurationColorCondition()) then
    return "This client can't check Remaining Time on this display type."
  end
end

local function remainingRange(operator, seconds)
  if operator == "<" then return 0, seconds - EDGE_EPSILON end
  if operator == "<=" then return 0, seconds end
  if operator == ">" then return seconds + EDGE_EPSILON end
  return seconds
end

function Disp.RemainingGateRange(auraData, auraTrigger)
  auraTrigger = auraTrigger or Disp.GetTrigger(auraData)
  if auraData.regionType == "icon" or not remainingEnabled(auraTrigger) or Disp.RemainingGateProblem(auraData, auraTrigger) then return end
  return remainingRange(Disp.RemainingWindow(auraTrigger))
end

function Disp.UsesGate(auraData)
  return Disp.DurationGate(auraData) ~= nil or Disp.RemainingGateRange(auraData) ~= nil or Disp.StackGate(auraData) ~= nil
end

local watchedIDs = {}
local watchedProfiles = {}
local waitingRegions = setmetatable({}, {__mode = "k"})
local learningRegions = setmetatable({}, {__mode = "k"})
local learnsFromGroup = false
local reapplyAfterCombat = {}

local function rebuildWatches()
  wipe(watchedProfiles)
  wipe(watchedIDs)
  learnsFromGroup = false
  for _, entry in pairs(learningRegions) do
    if entry.approximate and entry.group then learnsFromGroup = true end
    for _, spellId in ipairs(entry.ids) do
      if entry.approximate then watchedProfiles[spellId] = true end
      if entry.glow then watchedIDs[spellId] = true end
    end
  end
end

function Disp.ReleaseAuraLearning(ownerRegion)
  waitingRegions[ownerRegion] = nil
  if not learningRegions[ownerRegion] then return end
  learningRegions[ownerRegion] = nil
  rebuildWatches()
end

function Disp.WatchAuraLearning(ownerRegion, auraData, auraTrigger, glow)
  local approximate = Disp.UsesApproximate(auraTrigger)
  if not approximate and not glow then
    Disp.ReleaseAuraLearning(ownerRegion)
    return
  end
  local ids = Disp.GetSpellIDs(auraTrigger, true)
  local key = table.concat(ids, ",") .. tostring(approximate) .. tostring(not not glow) .. tostring(auraTrigger.unit)
  local current = learningRegions[ownerRegion]
  if not current or current.key ~= key then
    learningRegions[ownerRegion] = {
      ids = ids, key = key, approximate = approximate, glow = glow,
      group = GROUP_UNIT_CATEGORIES[Disp.UnitCategory(auraTrigger)],
    }
    rebuildWatches()
  end
  waitingRegions[ownerRegion] = auraData
end

local function isFriendlyToken(token)
  if token == "player" or token == "pet" then return true end
  if type(token) ~= "string" then return true end
  return (token:match("^party%d$") or token:match("^raid%d+$")) ~= nil
end

local function reapplyWaiting(changed)
  local refresh = {}
  for ownerRegion, auraData in pairs(waitingRegions) do
    local entry = learningRegions[ownerRegion]
    for _, spellId in ipairs(entry and entry.ids or {}) do
      if not changed or changed[spellId] then
        refresh[ownerRegion] = auraData
        break
      end
    end
  end
  for ownerRegion, auraData in pairs(refresh) do
    if WeakAuras.GetData(auraData.id) == auraData then
      Disp.Apply(ownerRegion, auraData)
    else
      Disp.ReleaseAuraLearning(ownerRegion)
    end
  end
end

local function roundTenth(value)
  return math.floor(value * 10 + 0.5) / 10
end

local function sameProfile(old, fresh)
  if type(old) ~= "table" then return false end
  for key, value in pairs(fresh) do
    if old[key] ~= value then return false end
  end
  for key in pairs(old) do
    if fresh[key] == nil then return false end
  end
  return true
end

local function learnSeenDuration(seenDurations, changed, spellId, duration)
  if issecretvalue(spellId) or issecretvalue(duration) then return end
  if not watchedIDs[spellId] or type(duration) ~= "number" or not (duration > 0) then return end
  local tenths = roundTenth(duration)
  if seenDurations[spellId] ~= tenths then
    seenDurations[spellId] = tenths
    changed[spellId] = true
  end
end

local function learnProfile(profiles, changed, token, aura, harmful, spellId, duration)
  if type(spellId) ~= "number" or issecretvalue(spellId) or not watchedProfiles[spellId] or not harmful then return end
  if type(duration) ~= "number" or issecretvalue(duration) then return end
  local friendly = isFriendlyToken(token)
  local old = profiles[spellId]
  if not friendly and type(old) == "table" and old.friendly then return end
  local fresh = {duration = roundTenth(duration), friendly = friendly or nil}
  local dispel = aura.dispelName
  if type(dispel) == "string" and not issecretvalue(dispel) then fresh.dispel = dispel end
  if friendly then
    for _, flag in ipairs(FINGERPRINT_FLAGS) do
      local flagValue = aura[flag]
      if type(flagValue) == "boolean" and not issecretvalue(flagValue) then fresh[flag] = flagValue end
    end
  end
  if not sameProfile(old, fresh) then
    profiles[spellId] = fresh
    changed[spellId] = true
  end
end

-- Reused across UNIT_AURA events instead of fresh closures and tables per event.
local learnTargets = {changed = {}}

local function learnAura(token, aura, harmful)
  local spellId, duration = aura.spellId, aura.duration
  learnSeenDuration(learnTargets.seenDurations, learnTargets.changed, spellId, duration)
  learnProfile(learnTargets.profiles, learnTargets.changed, token, aura, harmful, spellId, duration)
end

local function scanUnit(unit, filters)
  for _, filter in ipairs(filters) do
    for slot = 1, 40 do
      local succeeded, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, slot, filter)
      if not succeeded or type(aura) ~= "table" then break end
      learnAura(unit, aura, filter == "HARMFUL")
    end
  end
end

local function scanGroupMembers(filters)
  for member = 1, (IsInRaid() and GetNumGroupMembers() or 0) do scanUnit("raid" .. member, filters) end
  for member = 1, (not IsInRaid() and GetNumSubgroupMembers() or 0) do scanUnit("party" .. member, filters) end
end

local function onSpellDataLoaded(spellId)
  if not pendingSpellData[spellId] then return end
  pendingSpellData[spellId], describedDurations[spellId] = nil, nil
  loadAttempted[spellId] = true
  if InCombatLockdown() then
    reapplyAfterCombat[spellId] = true
  else
    reapplyWaiting({[spellId] = true})
  end
end

local function onAurasChanged(event, unit, updateInfo)
  if event == "UNIT_AURA" and unit ~= "target" and unit ~= "focus" and not isFriendlyToken(unit) then return end
  local seenDurations, profiles = learnedDurations(), learnedProfiles()
  if not seenDurations or not profiles then return end
  local changed = learnTargets.changed
  wipe(changed)
  learnTargets.seenDurations, learnTargets.profiles = seenDurations, profiles
  local filters = next(watchedIDs) and BOTH_FILTERS or DEBUFF_FILTER
  if event == "UNIT_AURA" then
    if type(updateInfo) == "table" and not updateInfo.isFullUpdate then
      if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
          local harmful = aura.isHarmful
          if not issecretvalue(harmful) then learnAura(unit, aura, harmful == true) end
        end
      end
      if updateInfo.updatedAuraInstanceIDs then
        for _, instanceId in ipairs(updateInfo.updatedAuraInstanceIDs) do
          local succeeded, aura = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, instanceId)
          if succeeded and type(aura) == "table" and not issecretvalue(aura.isHarmful) then
            learnAura(unit, aura, aura.isHarmful == true)
          end
        end
      end
    else
      scanUnit(unit, filters)
    end
  elseif event == "PLAYER_TARGET_CHANGED" then
    scanUnit("target", filters)
  else
    for _, token in ipairs(FIXED_UNITS) do scanUnit(token, filters) end
    if learnsFromGroup then scanGroupMembers(filters) end
  end
  if next(changed) then reapplyWaiting(changed) end
end

local learnEvents = CreateFrame("Frame")
learnEvents:RegisterEvent("UNIT_AURA")
learnEvents:RegisterEvent("PLAYER_TARGET_CHANGED")
learnEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
learnEvents:RegisterEvent("SPELL_DATA_LOAD_RESULT")
learnEvents:SetScript("OnEvent", function(_, event, unit, updateInfo)
  if event == "SPELL_DATA_LOAD_RESULT" then return onSpellDataLoaded(unit) end
  if event == "PLAYER_REGEN_ENABLED" and next(reapplyAfterCombat) then
    local deferred = reapplyAfterCombat
    reapplyAfterCombat = {}
    reapplyWaiting(deferred)
  end
  if (not next(watchedIDs) and not next(watchedProfiles)) or WeakAuras.IsRestricted() then return end
  onAurasChanged(event, unit, updateInfo)
end)

local function firstElement(auraData, matches)
  for index, subElement in ipairs(auraData.subRegions or {}) do
    if not Disp.IsDetachedElement(auraData, subElement) and matches(subElement) then return subElement, index end
  end
end

function Disp.LateGlowSpec(auraData, auraTrigger)
  if auraData.regionType ~= "icon" then return end
  local operator, seconds = Disp.RemainingWindow(auraTrigger)
  if operator then
    local subElement, index = firstElement(auraData, function(candidate) return candidate.type == "subglow" and candidate.glow end)
    if not subElement then return end
    local edge = (operator == "<=" or operator == ">") and seconds + EDGE_EPSILON or seconds
    return edge, subElement, index, operator == ">" or operator == ">="
  end
  for _, condition in ipairs(auraData.conditions or {}) do
    local check = condition.check
    if not condition.linked and check and check.variable == "faAuraRemaining" and check.op == "<"
      and Disp.NativeConditionKind(auraData, check) and tonumber(check.value) and tonumber(check.value) > 0 then
      for _, change in ipairs(condition.changes or {}) do
        if change.value == true and Disp.IsGlowProperty(auraData, change.property) then
          local index = tonumber(change.property:match("^sub%.(%d+)%."))
          return tonumber(check.value), auraData.subRegions[index], index, false
        end
      end
    end
  end
end

local function glowMargin(width, height, subElement)
  local offset = math.max(math.abs(tonumber(subElement.glowXOffset) or 0), math.abs(tonumber(subElement.glowYOffset) or 0))
  return math.ceil(math.max(width, height) * 0.5 * (tonumber(subElement.glowScale) or 1)) + offset + 4
end

function Disp.TimedGlowHolder(nativeView, auraData, index, frame)
  if nativeView.preview then return end
  local auraTrigger = Disp.GetTrigger(auraData)
  local edge, subElement, glowIndex, above = Disp.LateGlowSpec(auraData, auraTrigger)
  if not edge or glowIndex ~= index then return end
  local total = Disp.LateGlowTotal(auraTrigger)
  if not total or total <= edge then return false end
  local late = nativeView.lateGlow
  if not late then
    late = {}
    late.bar = CreateFrame("StatusBar", nil, nativeView.button)
    late.bar:SetStatusBarTexture(WHITE_TEXTURE)
    late.bar:SetStatusBarColor(0, 0, 0, 0)
    late.bar:SetAlpha(0)
    late.clip = CreateFrame("Frame", nil, nativeView.gateClip or nativeView.button, "DisableUntrustedLayoutScriptsTemplate")
    late.clip:SetClipsChildren(true)
    late.holder = CreateFrame("Frame", nil, late.clip)
    late.holder:SetAllPoints(nativeView.button)
    nativeView.lateGlow = late
  end
  local width, height = Disp.Dimensions(auraData)
  local margin = glowMargin(width, height, subElement)
  local scale = math.min(LATE_K, LATE_MAX_WIDTH / total)
  late.bar:ClearAllPoints()
  late.bar:SetSize(total * scale, height + 2 * margin)
  late.clip:ClearAllPoints()
  if above then
    late.bar:SetPoint("LEFT", nativeView.button, "LEFT", -margin - edge * scale, 0)
    late.clip:SetPoint("TOPLEFT", late.bar, "TOPLEFT", edge * scale, 0)
    late.clip:SetPoint("BOTTOMRIGHT", late.bar:GetStatusBarTexture(), "BOTTOMRIGHT")
  else
    late.bar:SetPoint("LEFT", nativeView.button, "RIGHT", margin - edge * scale, 0)
    late.clip:SetPoint("TOPLEFT", late.bar:GetStatusBarTexture(), "TOPRIGHT")
    late.clip:SetPoint("BOTTOMRIGHT", late.bar, "BOTTOMLEFT", edge * scale, 0)
  end
  nativeView.button:SetDurationBar(late.bar, {direction = Enum.StatusBarTimerDirection.RemainingTime})
  late.clip:SetFrameLevel(frame:GetFrameLevel() + 1)
  late.clip:Show()
  return late.holder
end

local function moveHolder(holder, parent)
  if holder:GetParent() == parent then return end
  local level = holder:GetFrameLevel()
  holder:SetParent(parent)
  holder:SetFrameLevel(level)
end

function Disp.AttachRemainingHolders(nativeView, auraData)
  local gateText = nativeView.container and nativeView.container.remainingGateText
  local clip
  if gateText and not nativeView.preview then
    clip = nativeView.remainingClip or CreateFrame("Frame", nil, nativeView.button, "DisableUntrustedLayoutScriptsTemplate")
    nativeView.remainingClip = clip
    clip:SetClipsChildren(true)
    clip:ClearAllPoints()
    clip:SetPoint("TOPLEFT", gateText, "TOPLEFT")
    clip:SetPoint("BOTTOMRIGHT", gateText, "BOTTOMRIGHT")
    clip:Show()
  end
  local limited = not nativeView.preview and auraData.regionType == "icon"
    and Disp.RemainingWindow(Disp.GetTrigger(auraData)) ~= nil
  for index, subElement in ipairs(auraData.subRegions or {}) do
    local holder = nativeView.elementFrames and nativeView.elementFrames["shared" .. index]
    if holder and not Disp.IsDetachedElement(auraData, subElement) then
      local kind = subElement.type
      local keep = kind == "subglow" or kind == "subbackground"
        or (kind == "subtext" and Disp.TextKind(subElement.text_text) == "duration")
      if not limited or keep then
        moveHolder(holder, nativeView.gateClip or nativeView.button)
      elseif clip then
        moveHolder(holder, clip)
        holder:Show()
      else
        holder:Hide()
      end
    end
  end
end

function Disp.StyleRemainingList(nativeView, auraData)
  nativeView.remainingHidesIcon = nil
  Disp.AttachRemainingHolders(nativeView, auraData)
  if nativeView.preview then return end
  local limited = auraData.regionType == "icon" and Disp.RemainingWindow(Disp.GetTrigger(auraData)) ~= nil
  if nativeView.conditionOverlay then nativeView.conditionOverlay:SetShown(not limited) end
  if not limited then return end
  nativeView.remainingHidesIcon = true
  nativeView.button:ClearIcon()
  nativeView.icon:Hide()
  nativeView.button:ClearDurationCooldown()
  nativeView.cooldown:Hide()
  nativeView.border:Hide()
end

local function missingMargin(auraData, width, height)
  local largest = math.max(width, height)
  local margin = math.ceil(largest) * 2 + 64
  for _, subElement in ipairs(auraData.subRegions or {}) do
    local offsets = {}
    for position, field in ipairs({"anchorXOffset", "anchorYOffset", "text_anchorXOffset", "text_anchorYOffset",
      "glowXOffset", "glowYOffset", "xOffset", "yOffset"}) do
      offsets[position] = math.abs(tonumber(subElement[field]) or 0)
    end
    local reach = math.max(unpack(offsets))
    if subElement.type == "subglow" then reach = reach + math.ceil(largest * (tonumber(subElement.glowScale) or 1)) end
    margin = math.max(margin, math.ceil(largest) + reach + 64)
  end
  return margin
end

local function missingLayout(width, height, margin)
  return {elementWidth = width + 1 + 2 * margin, elementHeight = height}
end

function Disp.StyleMissingIcon(nativeView, auraData)
  if nativeView.icon then nativeView.icon:SetDesaturated(auraData.desaturate == true) end
  for _, preview in ipairs(nativeView.conditionPreview or {}) do preview.texture:SetShown(preview.kind == "faAuraMissing") end
  Disp.ApplyMissingConditions(nativeView, auraData)
  if nativeView.cooldown then nativeView.cooldown:Hide() end
  for index, subElement in ipairs(auraData.subRegions or {}) do
    local shared = nativeView.sharedElements and nativeView.sharedElements[index]
    if shared and DISPEL_ELEMENT_TYPES[subElement.type] then
      if shared.texture then shared.texture:Hide() end
      if shared.dispelEdges then Private.DispelTypeDisplay.Hide(shared.dispelEdges) end
    end
  end
end

function Disp.KeepMissingDesaturated(nativeView, auraData)
  Disp.ApplyMissingConditions(nativeView, auraData)
end

local function styleMissing(missingDisplay, ownerRegion, auraData)
  local nativeView = missingDisplay.native
  Disp.StyleNative(nativeView, auraData, ownerRegion)
  nativeView.button:ClearAllPoints()
  nativeView.button:SetPoint("TOPLEFT", Disp.ContentAnchor(ownerRegion), "TOPLEFT")
  local spellId = Disp.GetSpellIDs(Disp.GetTrigger(auraData), false)[1]
  local info = spellId and C_Spell.GetSpellInfo(spellId)
  Disp.FillSampleBindings(nativeView.button, Disp.SingleIcon(auraData), info and info.name or "", auraData, false)
  Disp.StyleMissingIcon(nativeView, auraData)
end

local function resolveSource(ownerRegion, auraData, source)
  if source ~= "next" then return source end
  local driver = drivingIndex(auraData)
  for position in ipairs(auraData.triggers or {}) do
    local auraState = ownerRegion.states and ownerRegion.states[position]
    if position ~= driver and followable(auraData, position) and type(auraState) == "table" and auraState.show then return position end
  end
end

local function countdownElement(nativeView, auraData, hide)
  local found
  for index, subElement in ipairs(auraData.subRegions or {}) do
    if subElement.type == "subtext" and Disp.TextKind(subElement.text_text) == "duration" then
      local shared = nativeView.sharedElements and nativeView.sharedElements[index]
      if shared and shared.text then shared.text:SetShown(not hide and subElement.text_visible ~= false) end
      if subElement.text_visible ~= false and not found then found = subElement end
    end
  end
  return found
end

local function styleCountdownNumbers(cooldown, nativeView, countdown)
  local numbers = cooldown:GetCountdownFontString()
  if numbers then Disp.StyleText(numbers, nativeView, Disp.TextSettings(countdown), "text", 18, "CENTER", 0, 0) end
  local format = countdown[COUNTDOWN_PREFIX .. "format"]
  cooldown:SetCountdownFormatter(nil)
  if format ~= nil and format ~= -1 and Private.GetDurationTextFormatter then
    pcall(cooldown.SetCountdownFormatter, cooldown, Private.GetDurationTextFormatter(
      countdown[COUNTDOWN_PREFIX .. "legacy_floor"] and 0 or 99,
      countdown[COUNTDOWN_PREFIX .. "dynamic_threshold"] or 3,
      countdown[COUNTDOWN_PREFIX .. "precision"] or 1,
      format == -2, format))
  end
end

local function resetFollowCooldown(nativeView, auraData)
  nativeView.cooldown:Clear()
  nativeView.cooldown:Hide()
  countdownElement(nativeView, auraData, false)
end

local function showFollowedIcon(nativeView, auraData, auraState)
  if auraState.icon == nil or not pcall(nativeView.icon.SetTexture, nativeView.icon, auraState.icon) then
    nativeView.icon:SetTexture(Disp.SingleIcon(auraData))
  end
end

local function applyIconSource(ownerRegion, missingDisplay, auraData, source)
  local nativeView = missingDisplay.native
  local cooldown = nativeView.cooldown
  local auraState = source and ownerRegion.states and ownerRegion.states[source]
  if not (type(auraState) == "table" and auraState.show) then
    if missingDisplay.following then
      missingDisplay.following = nil
      nativeView.icon:SetTexture(Disp.SingleIcon(auraData))
      resetFollowCooldown(nativeView, auraData)
    end
    return
  end
  missingDisplay.following = true
  showFollowedIcon(nativeView, auraData, auraState)
  local applied = false
  if auraState.progressType == "durationObject" and auraState.durationObject and cooldown.SetCooldownFromDurationObject then
    applied = pcall(cooldown.SetCooldownFromDurationObject, cooldown, auraState.durationObject, true)
  elseif auraState.progressType == "timed" then
    local duration, expiration = auraState.duration, auraState.expirationTime
    if type(duration) == "number" and type(expiration) == "number" and not issecretvalue(duration)
      and not issecretvalue(expiration) and duration > 0 and expiration ~= math.huge then
      applied = pcall(cooldown.SetCooldown, cooldown, expiration - duration, duration)
    end
  end
  if not applied then
    resetFollowCooldown(nativeView, auraData)
    return
  end
  cooldown:SetDrawSwipe(auraData.cooldown ~= false and auraData.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(auraData.cooldown ~= false and auraData.cooldownEdge == true)
  cooldown:SetReverse(auraData.inverse == true)
  local countdown = countdownElement(nativeView, auraData, true)
  if not countdown then
    cooldown:SetHideCountdownNumbers(auraData.cooldownTextDisabled ~= false)
  else
    cooldown:SetHideCountdownNumbers(false)
    styleCountdownNumbers(cooldown, nativeView, countdown)
  end
  cooldown:Show()
end

local function followDuration(missingDisplay, auraState)
  if auraState.progressType == "durationObject" and auraState.durationObject then return auraState.durationObject end
  if auraState.progressType ~= "timed" or not (C_DurationUtil and C_DurationUtil.CreateDuration) then return end
  local duration, expiration = auraState.duration, auraState.expirationTime
  if type(duration) ~= "number" or type(expiration) ~= "number" or issecretvalue(duration) or issecretvalue(expiration)
    or duration <= 0 or expiration == math.huge then return end
  missingDisplay.followDuration = missingDisplay.followDuration or C_DurationUtil.CreateDuration()
  if pcall(missingDisplay.followDuration.SetTimeFromStart, missingDisplay.followDuration, expiration - duration, duration) then
    return missingDisplay.followDuration
  end
end

local zeroDuration
local function clearFollowBars(nativeView)
  if not zeroDuration and C_DurationUtil and C_DurationUtil.CreateDuration then zeroDuration = C_DurationUtil.CreateDuration() end
  for _, entry in ipairs(nativeView.button.bindings.DurationBar or {}) do
    local bar = entry.widget
    if zeroDuration and bar.SetTimerDuration then
      pcall(bar.SetTimerDuration, bar, zeroDuration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.RemainingTime)
    end
    bar:SetMinMaxValues(0, 6)
    bar:SetValue(0)
  end
end

local function applyTimerSource(ownerRegion, missingDisplay, auraData, source)
  local nativeView = missingDisplay.native
  local auraButton = nativeView.button
  local auraState = source and ownerRegion.states and ownerRegion.states[source]
  local duration = type(auraState) == "table" and auraState.show and followDuration(missingDisplay, auraState)
  if not duration then
    if missingDisplay.following then
      missingDisplay.following = nil
      auraButton:SetScript("OnUpdate", nil)
      clearFollowBars(nativeView)
      for _, entry in ipairs(auraButton.bindings.DurationText or {}) do entry.widget:SetText("") end
      nativeView.icon:SetTexture(Disp.SingleIcon(auraData))
    end
    return
  end
  missingDisplay.following = true
  showFollowedIcon(nativeView, auraData, auraState)
  local direction = auraData.inverse and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime
  for _, entry in ipairs(auraButton.bindings.DurationBar or {}) do
    local bar = entry.widget
    if bar.SetTimerDuration then pcall(bar.SetTimerDuration, bar, duration, Enum.StatusBarInterpolation.Immediate, direction) end
  end
  local texts = auraButton.bindings.DurationText or {}
  if #texts == 0 then
    auraButton:SetScript("OnUpdate", nil)
    return
  end
  local modifier = Enum.DurationTimeModifier and Enum.DurationTimeModifier.RealTime
  local fallback = Private.GetDurationTextFormatter and Private.GetDurationTextFormatter(99, 0, 0)
  local elapsed = FOLLOW_TEXT_INTERVAL
  auraButton:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < FOLLOW_TEXT_INTERVAL then return end
    elapsed = 0
    for _, entry in ipairs(texts) do
      local formatter = entry.options and entry.options.textFormatter or fallback
      local succeeded, text = pcall(duration.FormatRemainingDuration, duration, formatter, modifier)
      entry.widget:SetText(succeeded and text or "")
    end
  end)
end

local function applyMissingSource(ownerRegion, missingDisplay, auraData, source)
  source = resolveSource(ownerRegion, auraData, source)
  if auraData.regionType == "icon" then
    applyIconSource(ownerRegion, missingDisplay, auraData, source)
  else
    applyTimerSource(ownerRegion, missingDisplay, auraData, source)
  end
  missingDisplay.native.button:SetAlpha((not missingDisplay.foundMode or missingDisplay.following) and 1 or 0)
end

function Disp.UpdateMissingSource(ownerRegion)
  local nativeView = ownerRegion.blizzardAuraDisplay
  if not nativeView or not nativeView.active then return end
  local auraData = nativeView.data
  local source = Disp.MissingSource(auraData)
  for _, displayInstance in ipairs(nativeView.instances or {}) do
    local missingDisplay = displayInstance.single and displayInstance.single.missing
    if missingDisplay and missingDisplay.active and (source or missingDisplay.following) then
      applyMissingSource(ownerRegion, missingDisplay, auraData, source)
    end
  end
end

local function ensurePresence(missingDisplay, ownerRegion, auraData, filter, candidates)
  missingDisplay.presenceActive = false
  if not Disp.FlowGroup(auraData) then
    if missingDisplay.presence then
      missingDisplay.presence:SetEnabled(false)
      missingDisplay.presence:Hide()
    end
    return
  end
  if missingDisplay.presenceFailed then return end
  local presence = missingDisplay.presence
  if presence then
    local layout = Disp.FlowPresenceSize(auraData)
    presence:SetAuraGroupFilterString(PRESENCE_GROUP_NAME, filter)
    presence:SetAuraGroupCandidateFilters(PRESENCE_GROUP_NAME, candidates)
    presence:SetAuraGroupLayout(PRESENCE_GROUP_NAME, layout)
    presence:SetAuraGroupEnabled(PRESENCE_GROUP_NAME, true)
  else
    presence = Disp.CreateAuraContainer(ownerRegion, auraData)
    presence:SetEnabled(false)
    presence:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    presence:SetPoint("TOPLEFT", ownerRegion, "TOPLEFT")
    local layout = Disp.FlowPresenceSize(auraData)
    local succeeded, failureMessage = pcall(presence.AddAuraGroup, presence, PRESENCE_GROUP_NAME, filter, {
      candidateFilters = candidates,
      maxFrameCount = 1,
      layout = layout,
      initializeFrame = function(auraButton)
        auraButton:SetSize(layout.elementWidth, layout.elementHeight)
        auraButton:SetAlpha(0)
        auraButton:EnableMouse(false)
      end,
    })
    if not succeeded then
      presence:Hide()
      missingDisplay.presenceFailed = true
      Warn(auraData, "Blizzard could not create the Modern Aura Group spacing: " .. tostring(failureMessage))
      return
    end
    missingDisplay.presence = presence
  end
  missingDisplay.presenceBoundUnit = nil
  if not Disp.AnchorFlowPresence(ownerRegion, auraData, presence) then
    presence:SetEnabled(false)
    presence:Hide()
    Warn(auraData, "Blizzard refused the Modern Aura Group spacing; this display keeps a fixed space.")
    return
  end
  missingDisplay.presenceActive = true
end

local function ensureMissing(singleState, ownerRegion, auraData, auraTrigger)
  local width, height = Disp.Dimensions(auraData)
  local margin = missingMargin(auraData, width, height)
  local filter, candidates = Disp.FilterString(auraTrigger), Disp.CandidateFilters(auraData)
  if singleState.missingFailed then
    Warn(auraData, singleState.missingFailed)
    return
  end
  local missingDisplay = singleState.missing
  if missingDisplay then
    local auraContainer = missingDisplay.container
    auraContainer:SetAuraGroupFilterString(MISSING_GROUP_NAME, filter)
    auraContainer:SetAuraGroupCandidateFilters(MISSING_GROUP_NAME, candidates)
    auraContainer:SetAuraGroupLayout(MISSING_GROUP_NAME, missingLayout(width, height, margin))
    auraContainer:SetAuraGroupEnabled(MISSING_GROUP_NAME, true)
  else
    missingDisplay = {}
    local auraContainer = Disp.CreateAuraContainer(ownerRegion, auraData)
    auraContainer:SetEnabled(false)
    auraContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    auraContainer:SetPoint("TOPLEFT", ownerRegion, "TOPLEFT")
    local succeeded, failureMessage = pcall(auraContainer.AddAuraGroup, auraContainer, MISSING_GROUP_NAME, filter, {
      candidateFilters = candidates,
      maxFrameCount = 1,
      layout = missingLayout(width, height, margin),
      initializeFrame = function(auraButton)
        auraButton:SetSize(width + 1 + 2 * margin, height)
        auraButton:EnableMouse(false)
      end,
    })
    if not succeeded then
      auraContainer:Hide()
      singleState.missingFailed = "Blizzard could not create the Aura(s) Missing display: " .. tostring(failureMessage)
      Warn(auraData, singleState.missingFailed)
      return
    end
    local newClip = CreateFrame("Frame", nil, ownerRegion, "DisableUntrustedLayoutScriptsTemplate")
    newClip:SetClipsChildren(true)
    newClip:EnableMouse(false)
    missingDisplay.container, missingDisplay.clip = auraContainer, newClip
    missingDisplay.native = Disp.CreateSampleNative(newClip)
    singleState.missing = missingDisplay
  end
  local anchor = Disp.ContentAnchor(ownerRegion)
  missingDisplay.container:ClearAllPoints()
  if not Disp.AnchorToContent(missingDisplay.container, "TOPLEFT", ownerRegion, "TOPLEFT") then anchor = ownerRegion end
  local clipFrame = missingDisplay.clip
  clipFrame:ClearAllPoints()
  clipFrame:SetPoint("TOPLEFT", missingDisplay.container, "TOPRIGHT", -1 - margin, margin)
  clipFrame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", margin, -margin)
  ensurePresence(missingDisplay, ownerRegion, auraData, filter, candidates)
  clipFrame:SetFrameLevel(ownerRegion:GetFrameLevel() + 1)
  missingDisplay.container:SetFrameLevel(ownerRegion:GetFrameLevel() + 1)
  styleMissing(missingDisplay, ownerRegion, auraData)
  missingDisplay.active = true
  missingDisplay.native.button:SetScript("OnUpdate", nil)
  if missingDisplay.following then clearFollowBars(missingDisplay.native) end
  missingDisplay.following = nil
  missingDisplay.foundMode = singleState.foundMode == true
  missingDisplay.native.button:SetAlpha(1)
  local source = Disp.MissingSource(auraData, auraTrigger)
  if source or missingDisplay.foundMode then applyMissingSource(ownerRegion, missingDisplay, auraData, source) end
end

local function disableMissing(singleState)
  local missingDisplay = singleState.missing
  if not missingDisplay or not missingDisplay.active then return end
  missingDisplay.active = false
  for _, key in ipairs(FOLLOWER_KEYS) do
    local follower = missingDisplay[key]
    if follower then
      follower:SetEnabled(false)
      follower:Hide()
    end
  end
  missingDisplay.container:SetEnabled(false)
  missingDisplay.container:Hide()
  pcall(missingDisplay.container.SetAuraGroupEnabled, missingDisplay.container, MISSING_GROUP_NAME, false)
  missingDisplay.clip:Hide()
  missingDisplay.boundUnit = nil
end

local function remainingCurve(operator, seconds, red, green, blue, alpha)
  local curve = C_CurveUtil.CreateColorCurve()
  curve:SetType(Enum.LuaCurveType.Step)
  local below = operator == "<" or operator == "<="
  local edge = (operator == "<=" or operator == ">") and seconds + EDGE_EPSILON or seconds
  local visible, hidden = CreateColor(red, green, blue, alpha), CreateColor(red, green, blue, 0)
  if edge > 0 then curve:AddPoint(0, below and visible or hidden) end
  curve:AddPoint(edge, below and hidden or visible)
  return curve
end

local function texcoordUnits(fraction)
  return math.floor((tonumber(fraction) or 0) * TEXCOORD_SCALE + 0.5)
end

local function textureMarkup(texture, width, height, left, right, top, bottom)
  return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(tostring(texture), height, width,
    TEXCOORD_SCALE, TEXCOORD_SCALE, texcoordUnits(left), texcoordUnits(right), texcoordUnits(top), texcoordUnits(bottom))
end

local function ensureSlot(singleState, displayInstance, ownerRegion, key, auraTrigger, auraData)
  local auraContainer = displayInstance.container
  local filter, candidates = Disp.FilterString(auraTrigger), Disp.CandidateFilters(auraData)
  singleState.slots = singleState.slots or {}
  local slot = singleState.slots[key]
  if not slot then
    slot = {}
    local succeeded, failureMessage = pcall(auraContainer.AddAuraSlot, auraContainer, key, filter, {
      candidateFilters = candidates,
      initializeFrame = function(auraButton)
        slot.button = auraButton
        auraButton:EnableMouse(false)
        auraButton:SetAllPoints(ownerRegion)
      end,
    })
    if not succeeded or not slot.button then
      Warn(auraData, "Blizzard could not create the Remaining Time display: " .. tostring(failureMessage))
      return
    end
    singleState.slots[key] = slot
  end
  auraContainer:SetAuraSlotEnabled(key, false)
  local width, height = Disp.Dimensions(auraData)
  slot.button:ClearAllPoints()
  slot.button:SetSize(width, height)
  slot.button:SetPoint("TOPLEFT", ownerRegion, "TOPLEFT")
  auraContainer:SetAuraSlotFilterString(key, filter)
  auraContainer:SetAuraSlotCandidateFilters(key, candidates)
  auraContainer:SetAuraSlotSortMethod(key, Disp.SortOrder(auraData, auraTrigger))
  slot.used = true
  return slot
end

local function ensureRemaining(singleState, displayInstance, ownerRegion, auraData, auraTrigger, operator, seconds)
  local icon = ensureSlot(singleState, displayInstance, ownerRegion, REMAINING_ICON_SLOT, auraTrigger, auraData)
  if not icon then return false end
  local width, height = Disp.Dimensions(auraData)
  local color = auraData.color or {1, 1, 1, 1}
  local left, right, top, bottom = Disp.IconTexCoords(auraData)
  icon.text = icon.text or icon.button:CreateFontString(nil, "ARTWORK")
  icon.text:SetWordWrap(false)
  icon.text:SetFont(STANDARD_TEXT_FONT, 12, "")
  icon.text:ClearAllPoints()
  icon.text:SetPoint("CENTER", icon.button, "CENTER")
  icon.button:ClearDurationText()
  local applied, failure = pcall(icon.button.SetDurationText, icon.button, icon.text, {
    textFormat = {formatString = textureMarkup(Disp.SingleIcon(auraData), width, height, left, right, top, bottom), components = {}},
    textColor = {curve = remainingCurve(operator, seconds, color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1),
      property = Enum.DurationTextBindingProperty.RemainingDuration},
  })
  if not applied then
    Warn(auraData, "Blizzard refused the Remaining Time icon: " .. tostring(failure))
    return false
  end
  icon.text:Show()
  displayInstance.container:SetAuraSlotEnabled(REMAINING_ICON_SLOT, true)
  return true
end

local invisibleCurve
local gateFormatters = {}
local function gateFormatter(lower, upper, fill)
  local cacheKey = table.concat({lower, tostring(upper), fill}, "|")
  if gateFormatters[cacheKey] then return gateFormatters[cacheKey] end
  local points
  if upper and upper < lower then
    points = {{threshold = 0, format = ""}}
  elseif lower <= 0 then
    points = {{threshold = 0, format = fill}}
  else
    points = {{threshold = 0, format = ""}, {threshold = lower, format = fill}}
  end
  if upper and upper >= lower then points[#points + 1] = {threshold = upper + EDGE_EPSILON, format = ""} end
  local formatter = C_StringUtil.CreateNumericRuleFormatter()
  local succeeded, failureMessage = pcall(formatter.SetBreakpoints, formatter, points)
  if not succeeded then return nil, failureMessage end
  gateFormatters[cacheKey] = formatter
  return formatter
end

local function gateMargin(width, height)
  return math.ceil(math.max(width, height) * 0.5) + 8
end

local function gateFill(width, height)
  local margin = gateMargin(width, height)
  local size = math.min(250, math.ceil(math.max(width, height) + 2 * margin))
  local fill = string.rep("W", math.ceil((width + 2 * margin) / (size / 2)) + 1)
  local lines = math.ceil((height + 2 * margin) / size)
  if lines > 1 then
    local rows = {}
    for row = 1, lines do rows[row] = fill end
    fill = table.concat(rows, "\n")
  end
  return size, fill, margin
end

local function placeGateText(text, auraButton, margin)
  text:ClearAllPoints()
  text:SetJustifyH("LEFT")
  text:SetPoint("LEFT", auraButton, "LEFT", -margin - 2, 0)
end

local function styleExactStackGate(nativeView, auraData, count)
  local auraButton, clipFrame = nativeView.button, nativeView.gateClip
  local width, height = Disp.Dimensions(auraData)
  local size, fill, margin = gateFill(width, height)
  local formatter, failureMessage = gateFormatter(count, count, fill)
  local text = nativeView.stackGateText
  if not text then
    text = auraButton:CreateFontString(nil, "BACKGROUND")
    nativeView.stackGateText = text
  end
  local succeeded = formatter ~= nil
  if succeeded then
    text:SetFont(STANDARD_TEXT_FONT, size, "")
    text:SetWordWrap(false)
    text:SetWidth(0)
    placeGateText(text, auraButton, margin)
    text:SetTextColor(0, 0, 0, 0)
    text:SetAlpha(0)
    succeeded, failureMessage = pcall(auraButton.SetApplicationCount, auraButton, text, {formatter = formatter})
  end
  if not succeeded then
    Warn(auraData, "Blizzard refused the Stack Count check: " .. tostring(failureMessage))
    text:Hide()
    return false
  end
  text:Show()
  clipFrame:SetClipsChildren(true)
  clipFrame:ClearAllPoints()
  clipFrame:SetPoint("TOPLEFT", text, "TOPLEFT")
  clipFrame:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT")
  for index, subElement in ipairs(auraData.subRegions or {}) do
    if subElement.type == "subtext" and Disp.TextKind(subElement.text_text) == "stack" then
      local shared = nativeView.sharedElements and nativeView.sharedElements[index]
      if shared and shared.text then shared.text:SetText(Disp.StackTextFor(auraData, "sub." .. index .. ".text_color", count)) end
    end
  end
  if nativeView.mainText and auraData.regionType == "text" and Disp.TextKind(auraData.displayText) == "stack" then
    nativeView.mainText:SetText(Disp.StackTextFor(auraData, "color", count))
  end
  return true
end

local function styleStackGate(nativeView, auraData, auraTrigger)
  local auraButton, clipFrame = nativeView.button, nativeView.gateClip
  local kind, count = Disp.StackGate(auraData, auraTrigger)
  local bar = nativeView.stackGate
  if kind ~= "exactly" and nativeView.stackGateText then nativeView.stackGateText:Hide() end
  if (not kind or kind == "exactly") and bar then
    auraButton:ClearApplicationBar()
    bar:Hide()
  end
  if not kind then return false end
  if kind == "exactly" then return styleExactStackGate(nativeView, auraData, count) end
  if not bar then
    bar = CreateFrame("StatusBar", nil, auraButton)
    bar:SetStatusBarTexture(WHITE_TEXTURE)
    bar:SetStatusBarColor(0, 0, 0, 0)
    bar:SetAlpha(0)
    nativeView.stackGate = bar
  end
  local width, height = Disp.Dimensions(auraData)
  local margin = gateMargin(width, height)
  local step = width + 2 * margin
  local capacity = kind == "atLeast" and count or count + 1
  bar:ClearAllPoints()
  bar:SetSize(capacity * step, height + 2 * margin)
  clipFrame:SetClipsChildren(true)
  clipFrame:ClearAllPoints()
  if kind == "atLeast" then
    bar:SetPoint("LEFT", auraButton, "LEFT", -margin - (count - 1) * step, 0)
    clipFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", (count - 1) * step, 0)
    clipFrame:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT")
  else
    bar:SetPoint("RIGHT", auraButton, "RIGHT", margin, 0)
    clipFrame:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT")
    clipFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
  end
  bar:Show()
  local succeeded, failureMessage = pcall(auraButton.SetApplicationBar, auraButton, bar, {maxApplications = capacity})
  if not succeeded then
    Warn(auraData, "Blizzard refused the Stack Count check: " .. tostring(failureMessage))
    bar:Hide()
    return false
  end
  return true
end

function Disp.StyleDurationGate(nativeView, auraData)
  if nativeView.preview or not nativeView.gateClip then return end
  local clipFrame, gate, auraButton = nativeView.gateClip, nativeView.gateText, nativeView.button
  local auraTrigger = Disp.GetTrigger(auraData)
  local width, height = Disp.Dimensions(auraData)
  local lower, upper = Disp.DurationGate(auraData, auraTrigger)
  local property, label = "TotalDuration", "Total Duration"
  if not lower then
    local remainingLower, remainingUpper = Disp.RemainingGateRange(auraData, auraTrigger)
    if remainingLower then lower, upper, property, label = remainingLower, remainingUpper, "RemainingDuration", "Remaining Time" end
  end
  if not lower then
    gate:Hide()
    nativeView.cooldown:SetMinimumCountdownDuration(0)
    nativeView.cooldown:SetCountdownFormatter(nil)
    if styleStackGate(nativeView, auraData, auraTrigger) then return end
    clipFrame:SetClipsChildren(false)
    clipFrame:ClearAllPoints()
    clipFrame:SetAllPoints(auraButton)
    return
  end
  styleStackGate(nativeView, auraData, nil)
  local size, fill, margin = gateFill(width, height)
  local formatter, failureMessage = gateFormatter(lower, upper, fill)
  local succeeded = formatter ~= nil
  if succeeded then
    gate:SetFont(STANDARD_TEXT_FONT, size, "")
    gate:SetWordWrap(false)
    gate:SetWidth(0)
    placeGateText(gate, auraButton, margin)
    if not invisibleCurve then
      invisibleCurve = C_CurveUtil.CreateColorCurve()
      invisibleCurve:SetType(Enum.LuaCurveType.Step)
      invisibleCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
    end
    local bindingProperty = Enum.DurationTextBindingProperty[property]
    succeeded, failureMessage = pcall(auraButton.SetDurationText, auraButton, gate, {
      textFormat = {formatString = "{}", components = {{property = bindingProperty, formatter = formatter}}},
      textColor = {curve = invisibleCurve, property = bindingProperty},
    })
  end
  if not succeeded then
    Warn(auraData, "Blizzard refused the " .. label .. " check: " .. tostring(failureMessage))
    return
  end
  gate:Show()
  clipFrame:SetClipsChildren(true)
  clipFrame:ClearAllPoints()
  clipFrame:SetPoint("TOPLEFT", gate, "TOPLEFT")
  clipFrame:SetPoint("BOTTOMRIGHT", gate, "BOTTOMRIGHT")
  if nativeView.mainText and auraData.regionType == "text" and Disp.TextKind(auraData.displayText) == "duration" then
    nativeView.mainText:Hide()
  end
  local countdown
  for index, subElement in ipairs(auraData.subRegions or {}) do
    if subElement.type == "subtext" and Disp.TextKind(subElement.text_text) == "duration" then
      local shared = nativeView.sharedElements and nativeView.sharedElements[index]
      if shared and shared.text then shared.text:Hide() end
      if subElement.text_visible ~= false and not countdown then countdown = subElement end
    end
  end
  if countdown and auraData.regionType == "icon" and property == "TotalDuration" then
    local cooldown = nativeView.cooldown
    cooldown:Show()
    if auraData.cooldown == false then
      cooldown:SetDrawSwipe(false)
      cooldown:SetDrawEdge(false)
    end
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetUseAuraDisplayTime(true)
    cooldown:SetMinimumCountdownDuration(lower * 1000)
    styleCountdownNumbers(cooldown, nativeView, countdown)
    auraButton:SetDurationCooldown(cooldown)
  end
end

local function ensureRemainingGate(singleState, displayInstance, ownerRegion, auraData, auraTrigger, operator, seconds)
  local auraContainer = displayInstance.container
  local gate = ensureSlot(singleState, displayInstance, ownerRegion, REMAINING_GATE_SLOT, auraTrigger, auraData)
  if not gate then return end
  local width, height = Disp.Dimensions(auraData)
  local size, fill, margin = gateFill(width, height)
  local lower, upper = remainingRange(operator, seconds)
  local formatter, failureMessage = gateFormatter(lower, upper, fill)
  gate.text = gate.text or gate.button:CreateFontString(nil, "BACKGROUND")
  local succeeded = formatter ~= nil
  if succeeded then
    gate.text:SetFont(STANDARD_TEXT_FONT, size, "")
    gate.text:SetWordWrap(false)
    gate.text:SetWidth(0)
    placeGateText(gate.text, gate.button, margin)
    if not invisibleCurve then
      invisibleCurve = C_CurveUtil.CreateColorCurve()
      invisibleCurve:SetType(Enum.LuaCurveType.Step)
      invisibleCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
    end
    local bindingProperty = Enum.DurationTextBindingProperty.RemainingDuration
    gate.button:ClearDurationText()
    succeeded, failureMessage = pcall(gate.button.SetDurationText, gate.button, gate.text, {
      textFormat = {formatString = "{}", components = {{property = bindingProperty, formatter = formatter}}},
      textColor = {curve = invisibleCurve, property = bindingProperty},
    })
  end
  if not succeeded then
    Warn(auraData, "Blizzard refused the Remaining Time check: " .. tostring(failureMessage))
    return
  end
  gate.text:Show()
  auraContainer.remainingGateText = gate.text
  auraContainer:SetAuraSlotEnabled(REMAINING_GATE_SLOT, true)
end

function Disp.ConfigureSingle(displayInstance, ownerRegion, auraData, index)
  local auraTrigger = Disp.GetTrigger(auraData)
  local valid = index == 1 and Disp.ValidateSingle(auraData, auraTrigger) == nil
  local isSingle = valid and Disp.IsSingle(auraTrigger, auraData)
  if valid then
    Disp.WatchAuraLearning(ownerRegion, auraData, auraTrigger, (Disp.LateGlowSpec(auraData, auraTrigger)))
  elseif index == 1 then
    Disp.ReleaseAuraLearning(ownerRegion)
  end
  local foundFollow = valid and not isSingle and Disp.FoundFollow(auraData, auraTrigger) ~= nil
  if not isSingle and not foundFollow and not displayInstance.single then return end
  local singleState = displayInstance.single or {}
  displayInstance.single = singleState
  for _, slot in pairs(singleState.slots or {}) do slot.used = false end
  singleState.foundMode = foundFollow
  if (isSingle and wantsMissing(auraTrigger)) or foundFollow then
    ensureMissing(singleState, ownerRegion, auraData, auraTrigger)
  else
    disableMissing(singleState)
  end
  local operator, seconds = Disp.RemainingWindow(auraTrigger)
  displayInstance.container.remainingGateText = nil
  if isSingle and operator and ensureRemaining(singleState, displayInstance, ownerRegion, auraData, auraTrigger, operator, seconds) then
    ensureRemainingGate(singleState, displayInstance, ownerRegion, auraData, auraTrigger, operator, seconds)
  end
  for _, entry in ipairs(displayInstance.buttons or {}) do Disp.AttachRemainingHolders(entry, auraData) end
  for key, slot in pairs(singleState.slots or {}) do
    if not slot.used then pcall(displayInstance.container.SetAuraSlotEnabled, displayInstance.container, key, false) end
  end
  local listDraws = not isSingle or Disp.ShowOn(auraTrigger) ~= "showOnMissing"
  singleState.listDisabled = not listDraws
  displayInstance.container:SetAuraGroupEnabled("Auras", listDraws)
  for _, entry in ipairs(displayInstance.buttons or {}) do entry.button:SetAlpha(listDraws and 1 or 0) end
end

function Disp.RefreshSingle(displayInstance, unit, shown)
  local singleState = displayInstance.single
  if shown and singleState and singleState.listDisabled then
    pcall(displayInstance.container.SetAuraGroupEnabled, displayInstance.container, "Auras", false)
  end
  local missingDisplay = displayInstance.single and displayInstance.single.missing
  if not missingDisplay or not missingDisplay.active then return end
  local auraContainer = missingDisplay.container
  if unit and missingDisplay.boundUnit ~= unit then
    auraContainer:SetEnabled(false)
    auraContainer:SetUnit(unit)
    missingDisplay.boundUnit = unit
  end
  shown = shown and unit ~= nil
  auraContainer:SetShown(shown)
  auraContainer:SetEnabled(shown)
  for _, key in ipairs(FOLLOWER_KEYS) do
    local follower = missingDisplay[key]
    if follower and missingDisplay[key .. "Active"] then
      if unit and missingDisplay[key .. "BoundUnit"] ~= unit then
        follower:SetEnabled(false)
        follower:SetUnit(unit)
        missingDisplay[key .. "BoundUnit"] = unit
      end
      follower:SetShown(shown)
      follower:SetEnabled(shown)
      if shown then follower:UpdateAllAuras() end
    end
  end
  missingDisplay.clip:SetShown(shown)
  local auraTrigger = displayInstance.data and Disp.GetTrigger(displayInstance.data)
  local keepWithoutUnit = auraTrigger and auraTrigger.unitExists
  missingDisplay.clip:SetAlpha((keepWithoutUnit or Disp.SingleUnitExists({unit = unit})) and 1 or 0)
  if shown then auraContainer:UpdateAllAuras() end
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Single-element mode of the native aura display: trigger predicates, duration and stack gates, learned
-- durations and profiles, and the native frames drawing a missing aura, a Remaining Time window or a followed trigger.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = {}
Private.AuraSingleShared = Shared

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

Shared.AnchorsToUnitFrame = AnchorsToUnitFrame
Shared.BAD = BAD
Shared.CAUTION = CAUTION
Shared.CLIP_TEMPLATE = CLIP_TEMPLATE
Shared.COUNTDOWN_FORMAT_PREFIX = COUNTDOWN_FORMAT_PREFIX
Shared.Clear = Clear
Shared.DISPEL_ELEMENTS = DISPEL_ELEMENTS
Shared.EDGE_MARGIN = EDGE_MARGIN
Shared.FOLLOWER_KEYS = FOLLOWER_KEYS
Shared.FOLLOW_TICK = FOLLOW_TICK
Shared.FRIENDLY_CATEGORIES = FRIENDLY_CATEGORIES
Shared.FindCondition = FindCondition
Shared.FirstProblem = FirstProblem
Shared.GATE_TOLERANCE = GATE_TOLERANCE
Shared.GLOW_BUDGET = GLOW_BUDGET
Shared.GLOW_SPEED = GLOW_SPEED
Shared.GOOD = GOOD
Shared.HOSTILE_CATEGORIES = HOSTILE_CATEGORIES
Shared.HasWindow = HasWindow
Shared.IsSecret = IsSecret
Shared.IsTable = IsTable
Shared.KEEP_WHEN_LIMITED = KEEP_WHEN_LIMITED
Shared.LIST_GROUP = LIST_GROUP
Shared.MISSING_GROUP = MISSING_GROUP
Shared.OFFSET_KEYS = OFFSET_KEYS
Shared.PRESENCE_GROUP = PRESENCE_GROUP
Shared.PROFILE_FLAGS = PROFILE_FLAGS
Shared.Paint = Paint
Shared.ReadableNumber = ReadableNumber
Shared.ReportProblem = ReportProblem
Shared.SCAN_SLOTS = SCAN_SLOTS
Shared.SLOT_GATE = SLOT_GATE
Shared.SLOT_ICON = SLOT_ICON
Shared.SavedTable = SavedTable
Shared.TEXCOORD_SCALE = TEXCOORD_SCALE
Shared.Tenth = Tenth
Shared.ToFinite = ToFinite
Shared.UsesRemaining = UsesRemaining
Shared.WHITE_TEXTURE = WHITE_TEXTURE
Shared.WINDOW_RANGES = WINDOW_RANGES
Shared.WantsMissing = WantsMissing
Shared.WindowEdge = WindowEdge

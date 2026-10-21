-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local Listed = Shared.Listed
local nativeFilterKeys = Shared.nativeFilterKeys

local GLOW_FRAME_LEVEL_STEP = 8

local MESSAGE_NOT_ELIGIBLE = "Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text."
local MESSAGE_BAD_UNIT = "Choose a supported unit and Buff or Debuff."
local MESSAGE_BAD_FILTER_STRING = "This client does not support the selected Blizzard aura filters."

local function MissingSpellLists(_, trigger)
  if Display.UsesSpellIDs(trigger) and not (trigger.auraspellids and next(trigger.auraspellids)) then
    return "Type an exact spell ID, or untick Exact Spell IDs to match every aura."
  end
  if Display.UsesRankSpellIDs(trigger) and not (trigger.auraRankSpellIDs and next(trigger.auraRankSpellIDs)) then
    return "Type a spell ID, or untick Spell ID(s) (All Ranks)."
  end
  if Display.UsesExcludedSpellIDs(trigger) and not (trigger.excludedAuraSpellIDs and next(trigger.excludedAuraSpellIDs)) then
    return "Type an ignored spell ID, or untick Ignored Exact Spell IDs."
  end
end

local function UnsupportedUnit(_, trigger)
  local harmfulOrHelpful = trigger.debuffType == "HELPFUL" or trigger.debuffType == "HARMFUL"
  if not (Display.units[trigger.unit] and harmfulOrHelpful) then
    return MESSAGE_BAD_UNIT
  end
  if trigger.unit == "member" and Display.SpecificUnit(trigger) == nil then
    return "Type a Specific Unit such as party1, raid5, boss1 or arena2."
  end
  if trigger.unit == "nameplate" and not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
    return "Nameplate frames are not available on this client."
  end
end

local function MalformedSpellIDs(_, trigger)
  for _, listName in ipairs({ "auraspellids", "auraRankSpellIDs", "excludedAuraSpellIDs" }) do
    for _, value in ipairs(trigger[listName] or {}) do
      local id = tonumber(value)
      if not (id and id > 0 and id < math.huge and id == math.floor(id)) then
        return "Spell IDs must be positive whole numbers."
      end
    end
  end
end

local function MalformedFlags(_, trigger)
  for _, row in ipairs(Display.booleanFilters) do
    local value = trigger[row[1]]
    if value ~= nil and type(value) ~= "boolean" then
      return "Filter '" .. row[2] .. "' must be on, off or left unset."
    end
  end
end

local function BadDurationOrSort(_, trigger)
  local limit = trigger.maxDuration
  if limit ~= nil and (type(limit) ~= "number" or limit <= 0 or limit == math.huge or limit ~= limit) then
    return "Maximum total duration must be a number above zero."
  end
  if trigger.sortMethod ~= nil and not Display.sortMethods[trigger.sortMethod] then
    return "Pick one of the available sort orders."
  end
end

local DISPEL_FIELDS = { "includeDispelTypes", "excludeDispelTypes" }

local function BadNativeFilters(_, trigger)
  for key, value in pairs(Listed(trigger.nativeFilters)) do
    if not nativeFilterKeys[key] or type(value) ~= "boolean" then
      return "Pick only Blizzard aura filters from the list."
    end
  end
  if AuraUtil and AuraUtil.IsValidFilterString and not AuraUtil.IsValidFilterString(Display.FilterString(trigger)) then
    return MESSAGE_BAD_FILTER_STRING
  end
  for _, field in ipairs(DISPEL_FIELDS) do
    for dispelType, value in pairs(trigger[field] or {}) do
      if Display.dispelTypes[dispelType] == nil or value ~= true then
        return "Pick only dispel types from the list."
      end
    end
  end
end

local function ReportedElsewhere(data, trigger)
  return Display.ValidateSingle(data, trigger) or Display.FlowProblem(data, trigger) or Display.ValidateConditions(data)
end

local function UnsupportedActionsOrAnimations(data)
  local timings = {}
  for timing in pairs(data.actions or {}) do
    if timing ~= "init" then timings[#timings + 1] = timing end
  end
  table.sort(timings)
  for _, timing in ipairs(timings) do
    local action = data.actions[timing]
    for fieldName, enabled in pairs(action) do
      if type(fieldName) == "string" and fieldName:find("^do_") and fieldName ~= "do_sound" and fieldName ~= "do_message" and enabled then
        return L["Only Chat Message, Play Sound and Hide Glows can run in On Show/On Hide for an Aura (Modern) trigger. Custom Init is available."]
      end
    end
    local usesSoundKit = action.do_sound and action.sound == " KitID"
    if usesSoundKit or action.stop_sound then
      return L["Aura (Modern) sounds accept sound files only, not Sound Kit IDs or Stop Sound."]
    end
  end
  for _, animation in pairs(Listed(data.animation)) do
    if animation.type ~= nil and animation.type ~= "none" then
      return L["Animations are not available on an Aura (Modern) trigger."]
    end
  end
end

local VALIDATION_CHECKS = {
  MissingSpellLists, UnsupportedUnit, MalformedSpellIDs, MalformedFlags,
  BadDurationOrSort, BadNativeFilters, ReportedElsewhere, UnsupportedActionsOrAnimations,
}

Display.Validate = function(data)
  if not Display.Eligible(data) then return MESSAGE_NOT_ELIGIBLE end
  if data.regionType == "progresstexture" and Private.ProgressTextureNative.IsCircular(data.orientation)
    and not Enum.StatusBarRenderMode then
    return L["This client cannot draw circular Progress Textures this way."]
  end
  local checked = Display.GetTrigger(data, true)
  local prepared = Display.PrepareConditionAppearance(data)
  local appearanceMessage = Display.ValidateAppearance(prepared)
  if appearanceMessage then return appearanceMessage end
  for _, check in ipairs(VALIDATION_CHECKS) do
    local message = check(data, checked)
    if message then return message end
  end
end

Shared.GLOW_FRAME_LEVEL_STEP = GLOW_FRAME_LEVEL_STEP

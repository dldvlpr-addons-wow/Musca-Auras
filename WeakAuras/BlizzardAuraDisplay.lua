if not WeakAuras.IsLibsOK() then return end
local _, Internal = ...
local MediaLibrary = LibStub("LibSharedMedia-3.0")

local Display = {}
Internal.BlizzardAuraDisplay = Display

local queuedApplies = setmetatable({}, {__mode = "k"})
local queuedSoundSyncs = {}
local liveRegions = {}
local GLOW_FRAME_LEVEL_STEP = 8
local retiredParent

local function MakeFilterRow(fieldKey, caption, tooltip)
  return {fieldKey, caption, tooltip}
end

Display.units = {
  player = "Player",
  target = "Target",
  focus = "Focus",
  pet = "Pet",
  mouseover = "Mouseover",
  targettarget = "Target of Target",
  focustarget = "Target of Focus",
  group = "Smart Group",
  party = "Party",
  raid = "Raid",
  boss = "Boss",
  arena = "Arena",
  nameplate = "Nameplate",
  member = "Specific Unit",
}

Display.booleanFilters = {
  MakeFilterRow("isFromPlayerOrPlayerPet", "Cast by a Player",
    "Auras cast by any player or player pet, not only yours. For your own auras, use Own Only."),
  MakeFilterRow("canApplyAura", "Can Apply Aura", "Auras Blizzard says your character can apply."),
  MakeFilterRow("isStealable", "Is Stealable", "Buffs that can be stolen with abilities such as Spellsteal."),
  MakeFilterRow("isBossAura", "Is Boss Aura", "Auras Blizzard identifies as boss auras."),
  MakeFilterRow("isRoleAura", "Role aura", "Auras Blizzard marks as relevant to your role."),
  MakeFilterRow("isBossOrRoleAura", "Boss or role aura",
    "Auras Blizzard identifies as boss auras or marks as relevant to your role."),
  MakeFilterRow("isPriorityAura", "Priority debuff", "Debuffs Blizzard marks as high priority."),
  MakeFilterRow("nameplateShowAll", "Marked for all nameplates", "Auras Blizzard marks for display on all nameplates."),
  MakeFilterRow("nameplateShowPersonal", "Marked for personal debuff display",
    "Auras Blizzard marks for its personal-debuff display on nameplates."),
}

Display.dispelTypes = {
  Magic = "Magic",
  Curse = "Curse",
  Disease = "Disease",
  Poison = "Poison",
  Bleed = "Bleed",
  [""] = "Enrage",
}

Display.nativeFilters = {
  MakeFilterRow("PLAYER", "Own Only", "Auras cast by you, your pet or your vehicle."),
  MakeFilterRow("RAID", "Can apply / dispel", "Buffs you can apply, or debuffs you can dispel."),
  MakeFilterRow("CANCELABLE", "Cancelable", "Auras that the player can cancel."),
  MakeFilterRow("EXTERNAL_DEFENSIVE", "External defensive", "Auras Blizzard classifies as external defensives."),
  MakeFilterRow("CROWD_CONTROL", "Crowd control", "Auras with a crowd-control effect, such as a stun or fear."),
  MakeFilterRow("RAID_IN_COMBAT", "Shown on raid frames in combat",
    "Auras flagged by Blizzard for raid-frame display in combat."),
  MakeFilterRow("RAID_PLAYER_DISPELLABLE", "Dispellable by someone in your raid", "Includes helpful enrages on enemies."),
  MakeFilterRow("BIG_DEFENSIVE", "Big defensive", "Auras Blizzard classifies as big defensives."),
  MakeFilterRow("IMPORTANT", "Important aura",
    "Blizzard's important-aura flag, including non-stealable enemy buffs shown on nameplates."),
  MakeFilterRow("DISPELLABLE", "Dispellable", "Dispellable regardless of your or your raid's current abilities."),
}

Display.sortMethods = {
  Default = "Blizzard default",
  BigDefensive = "Big defensives",
  UnitFrameDebuff = "Unit-frame debuffs",
  ImportantOnly = "Importance only",
  Expiration = "Remaining time (Blizzard priority)",
  ExpirationOnly = "Remaining time",
  Name = "Name (Blizzard priority)",
  NameOnly = "Name",
  AuraInstanceIDOnly = "Aura instance ID",
}

Display.processedTypes = {
  any = "Any (no classification)",
  Buff = "Buff",
  Debuff = "Debuff",
  Dispel = "Dispellable raid debuff",
}

Display.processingOptions = {
  MakeFilterRow("displayOnlyDispellableDebuffs", "Use dispellable-debuff classification"),
  MakeFilterRow("ignoreBuffs", "Ignore buff classification"),
  MakeFilterRow("ignoreDebuffs", "Ignore debuff classification"),
  MakeFilterRow("ignoreDispelDebuffs", "Ignore dispel classification"),
}

Display.dynamicGroupWarning = "Aura (Modern) in a Dynamic Group: It keeps its position even when no aura is shown. Use a Modern Aura Group with other Modern Aura triggers to keep dynamic behaviour."

local SUPPORTED_REGION_TYPES = {icon = true, aurabar = true, text = true, progresstexture = true}
local HELPFUL_ONLY_FILTERS = {CANCELABLE = true, EXTERNAL_DEFENSIVE = true, BIG_DEFENSIVE = true, IMPORTANT = true, isStealable = true}
local HARMFUL_ONLY_FILTERS = {CROWD_CONTROL = true, isPriorityAura = true, isBossAura = true, isRoleAura = true, isBossOrRoleAura = true}
local UNIT_SLOT_COUNTS = {group = 40, raid = 40, nameplate = 40, party = 5, arena = 5, boss = 10}
local MEMBER_UNIT_PATTERNS = {
  {pattern = "^party[1-4]$", category = "party"},
  {pattern = "^partypet[1-4]$", category = "party"},
  {pattern = "^raid(%d+)$", category = "raid", limit = 40},
  {pattern = "^raidpet(%d+)$", category = "raid", limit = 40},
  {pattern = "^boss[1-8]$", category = "boss"},
  {pattern = "^arena[1-5]$", category = "arena"},
}
local HIDDEN_REGION_FIELDS = {"icon", "cooldown", "button", "bar", "secretBar", "text", "background"}
local VALID_SOUND_CHANNELS = {Master = true, SFX = true, Music = true, Ambience = true, Dialog = true}
local EDITOR_FIRST_BATCH, EDITOR_BATCH_SIZE = 2, 4
local EDITOR_APPLY_BATCH = 2
local APPLY_BATCH_SIZE = 3

local function IsPlateFilter(fieldKey)
  return fieldKey == "nameplateShowAll" or fieldKey == "nameplateShowPersonal"
end

function Display.SpecificUnit(triggerConfig)
  local labelText = type(triggerConfig) == "table" and type(triggerConfig.specificUnit) == "string"
    and triggerConfig.specificUnit:lower():match("^%s*(%S+)%s*$")
  if not labelText then return end
  for _, unitRule in ipairs(MEMBER_UNIT_PATTERNS) do
    local capturedValue = labelText:match(unitRule.pattern)
    if capturedValue then
      local position = tonumber(capturedValue)
      if not unitRule.limit or (position and position >= 1 and position <= unitRule.limit) then
        return labelText, unitRule.category
      end
    end
  end
end

function Display.UnitCategory(triggerConfig)
  if type(triggerConfig) ~= "table" then return end
  if triggerConfig.unit == "member" then
    return select(2, Display.SpecificUnit(triggerConfig))
  end
  return triggerConfig.unit
end

function Display.GetSavedTrigger(auraData)
  if not auraData or type(auraData.triggers) ~= "table" then return end
  local position = auraData.progressSource and auraData.progressSource[1] or -1
  if position == 0 then return end
  if position < 0 then position = auraData.triggers.activeTriggerMode or -1 end
  if position < 0 then
    position = (Internal.GetActiveTriggerFor and Internal.GetActiveTriggerFor(auraData.id)) or 1
  end
  local listEntry = auraData.triggers[position]
  local triggerConfig = type(listEntry) == "table" and listEntry.trigger
  if triggerConfig and triggerConfig.type == "secretAura" then
    return triggerConfig
  end
end

local function DropClassification(triggerConfig)
  triggerConfig.processedAuraType = nil
  if triggerConfig.sortMethod == "UnitFrameDebuff" then triggerConfig.sortMethod = "Default" end
end

function Display.GetTrigger(auraData, shownFilters)
  local savedTrigger = Display.GetSavedTrigger(auraData)
  if not savedTrigger then return end
  if shownFilters then
    local clone = CopyTable(savedTrigger)
    DropClassification(clone)
    for _, optionEntry in ipairs(Display.processingOptions) do
      clone[optionEntry[1]] = nil
    end
    return clone
  end
  if savedTrigger.processedAuraType or savedTrigger.sortMethod == "UnitFrameDebuff" then
    local clone = CopyTable(savedTrigger)
    DropClassification(clone)
    return clone
  end
  return savedTrigger
end

function Display.HasTrigger(auraData)
  for _, listEntry in ipairs(auraData and auraData.triggers or {}) do
    if type(listEntry) == "table" and listEntry.trigger and listEntry.trigger.type == "secretAura" then
      return true
    end
  end
  return false
end

function Display.UsesNameplates(auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  return (triggerConfig and triggerConfig.unit == "nameplate") or auraData.anchorFrameType == "NAMEPLATE"
end

function Display.Eligible(auraData)
  return auraData and (SUPPORTED_REGION_TYPES[auraData.regionType] == true) and Display.GetTrigger(auraData) ~= nil
end

function Display.Enabled(auraData)
  return Display.Eligible(auraData)
end

function Display.UsesSpellIDs(triggerConfig)
  local isForced = triggerConfig.secretUseSpellIDs
  return isForced ~= false and (#(triggerConfig.auraspellids or {}) > 0 or isForced == true)
end

function Display.UsesRankSpellIDs(triggerConfig)
  return triggerConfig.secretUseRankSpellIDs == true
end

function Display.UsesExcludedSpellIDs(triggerConfig)
  local isForced = triggerConfig.secretUseExcludedSpellIDs
  return isForced ~= false and (#(triggerConfig.excludedAuraSpellIDs or {}) > 0 or isForced == true)
end

local function IsValidSpellId(auraId)
  return auraId and auraId > 0 and auraId < 2147483647 and auraId == math.floor(auraId)
end

function Display.GetSpellIDs(triggerConfig, withRanks)
  local idList, visited = {}, {}
  local function Gather(fieldValue)
    local auraId = tonumber(fieldValue)
    if IsValidSpellId(auraId) and not visited[auraId] then
      visited[auraId] = true
      idList[#idList + 1] = auraId
    end
  end
  if Display.UsesRankSpellIDs(triggerConfig) then
    for _, fieldValue in ipairs(triggerConfig.auraRankSpellIDs or {}) do
      local auraId = tonumber(fieldValue)
      if IsValidSpellId(auraId) then
        Gather(auraId)
        if withRanks then
          for _, rankId in ipairs(Internal.GetAuraSpellRanks(auraId) or {}) do Gather(rankId) end
        end
      end
    end
  end
  if Display.UsesSpellIDs(triggerConfig) then
    for _, fieldValue in ipairs(triggerConfig.auraspellids or {}) do Gather(fieldValue) end
  end
  return idList
end

function Display.FilterApplies(fieldKey, triggerConfig)
  if HELPFUL_ONLY_FILTERS[fieldKey] and triggerConfig.debuffType ~= "HELPFUL" then return false end
  if HARMFUL_ONLY_FILTERS[fieldKey] and triggerConfig.debuffType ~= "HARMFUL" then return false end
  return true
end

function Display.HasAdditionalFilters(triggerConfig)
  if next(triggerConfig.nativeFilters or {}) then return true end
  if Display.UsesExcludedSpellIDs(triggerConfig) then return true end
  if next(triggerConfig.includeDispelTypes or {}) or next(triggerConfig.excludeDispelTypes or {}) then return true end
  if Display.TotalFilter(triggerConfig) ~= nil then return true end
  if triggerConfig.processedAuraType and triggerConfig.processedAuraType ~= "any" then return true end
  for _, filterRow in ipairs(Display.booleanFilters) do
    local fieldKey = filterRow[1]
    if triggerConfig[fieldKey] ~= nil and (not IsPlateFilter(fieldKey) or triggerConfig.unit == "nameplate") then return true end
  end
  return false
end

local function JoinFilters(triggerConfig)
  local pieces = {triggerConfig.debuffType}
  for _, filterRow in ipairs(Display.nativeFilters) do
    local fieldKey = filterRow[1]
    local fieldValue = (triggerConfig.nativeFilters or {})[fieldKey]
    if fieldValue ~= nil and Display.FilterApplies(fieldKey, triggerConfig) then
      pieces[#pieces + 1] = (fieldValue and "" or "!") .. fieldKey
    end
  end
  if triggerConfig.includeNameplateOnly and triggerConfig.unit == "nameplate" then
    pieces[#pieces + 1] = "INCLUDE_NAME_PLATE_ONLY"
  end
  return table.concat(pieces, "|")
end
Display.FilterString = JoinFilters

local function IsRestricted()
  return InCombatLockdown() or (C_Secrets and C_Secrets.ShouldAurasBeSecret())
end

local function InPreview()
  return WeakAuras.IsOptionsOpen() and not InCombatLockdown()
end

local function MakeWarningPoster(warningName)
  return function(auraData, warningText)
    Internal.AuraWarnings.UpdateWarning(auraData.uid, warningName, warningText and "warning" or nil, warningText)
  end
end
local PostWarning = MakeWarningPoster("blizzard_aura_display")
local PostSoundWarning = MakeWarningPoster("blizzard_aura_sound")

local PET_GROUP_UNITS = {group = true, party = true, raid = true}

local function SlotCount(triggerConfig)
  if Display.ShowOn and Display.ShowOn(triggerConfig) ~= "showOnActive" then return 1 end
  local slotCount = UNIT_SLOT_COUNTS[triggerConfig.unit] or 1
  if triggerConfig.use_includePets and triggerConfig.includePets == "PlayersAndPets" and PET_GROUP_UNITS[triggerConfig.unit] then
    slotCount = slotCount * 2
  end
  return slotCount
end

local function UnitNameMatches(triggerConfig, unitId)
  if not triggerConfig.useUnitNames then return true end
  local unitName = Internal.ExecEnv.UnitName(unitId)
  if issecretvalue(unitName) or not unitName then return false end
  unitName = strlower(unitName)
  for _, isWanted in ipairs(triggerConfig.unitNames or {}) do
    if unitName == strlower(isWanted) then return true end
  end
  return false
end

local function SequenceTokens(tokenPrefix, amount)
  local unitList = {}
  for numeric = 1, amount do unitList[numeric] = tokenPrefix .. numeric end
  return unitList
end

local function ExpandBaseUnits(triggerConfig)
  local unitId = triggerConfig.unit
  if unitId == "group" then unitId = IsInRaid() and "raid" or "party" end
  if unitId == "party" then
    local unitList = {"player"}
    for numeric = 1, GetNumSubgroupMembers() do unitList[#unitList + 1] = "party" .. numeric end
    return unitList
  elseif unitId == "raid" then
    if IsInRaid() then return SequenceTokens("raid", GetNumGroupMembers()) end
    return {}
  elseif unitId == "boss" or unitId == "arena" or unitId == "nameplate" then
    return SequenceTokens(unitId, SlotCount(triggerConfig))
  end
  return {unitId}
end

local function PetToken(unitId)
  if unitId == "player" then return "pet" end
  local prefix, number = unitId:match("^(%a+)(%d+)$")
  if prefix == "party" or prefix == "raid" then return prefix .. "pet" .. number end
end

local function WithPets(triggerConfig, unitList)
  local petMode = triggerConfig.use_includePets and triggerConfig.includePets
  if petMode ~= "PlayersAndPets" and petMode ~= "PetsOnly" then return unitList end
  local petList = {}
  for _, tokenName in ipairs(unitList) do
    if petMode == "PlayersAndPets" then petList[#petList + 1] = tokenName end
    local petToken = PetToken(tokenName)
    if petToken and UnitExists(petToken) then petList[#petList + 1] = petToken end
  end
  return petList
end

local function ExpandUnits(triggerConfig)
  if triggerConfig.unit == "member" then
    return {(Display.SpecificUnit(triggerConfig))}
  end
  local unitList = ExpandBaseUnits(triggerConfig)
  local isFilterable = triggerConfig.unit == "group" or triggerConfig.unit == "party" or triggerConfig.unit == "raid"
  if (triggerConfig.useUnitNames or triggerConfig.useUnitRoles) and isFilterable then
    local keptList = {}
    for _, tokenName in ipairs(unitList) do
      local roleName = triggerConfig.useUnitRoles and UnitGroupRolesAssigned(tokenName)
      if UnitNameMatches(triggerConfig, tokenName) and (not triggerConfig.useUnitRoles
        or (not issecretvalue(roleName) and (triggerConfig.unitRoles or {})[roleName])) then
        keptList[#keptList + 1] = tokenName
      end
    end
    return WithPets(triggerConfig, keptList)
  end
  if isFilterable then return WithPets(triggerConfig, unitList) end
  return unitList
end
Display.UnitTokens = ExpandUnits

function Display.GetPreviewUnit(auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  if not triggerConfig then return "player" end
  for _, unitId in ipairs(ExpandUnits(triggerConfig)) do
    if UnitExists(unitId) and (auraData.anchorFrameType ~= "UNITFRAME" or WeakAuras.GetUnitFrame(unitId)) then
      return unitId
    end
  end
  return "player"
end

local function ValidateRequiredSpells(_, triggerConfig)
  if Display.UsesSpellIDs(triggerConfig) and #(triggerConfig.auraspellids or {}) == 0 then
    return "Enter an exact spell ID, or untick Exact Spell IDs to show all matching auras."
  end
  if Display.UsesRankSpellIDs(triggerConfig) and #(triggerConfig.auraRankSpellIDs or {}) == 0 then
    return "Enter a spell ID, or untick Spell ID(s) (All Ranks)."
  end
  if Display.UsesExcludedSpellIDs(triggerConfig) and #(triggerConfig.excludedAuraSpellIDs or {}) == 0 then
    return "Enter an ignored spell ID, or untick Ignored Exact Spell IDs."
  end
end

local function ValidateUnit(_, triggerConfig)
  if not Display.units[triggerConfig.unit] or (triggerConfig.debuffType ~= "HELPFUL" and triggerConfig.debuffType ~= "HARMFUL") then
    return "Choose a supported unit and Buff or Debuff."
  end
  if triggerConfig.unit == "member" and not Display.SpecificUnit(triggerConfig) then
    return "Enter a Specific Unit such as party1, raid5, boss1 or arena2."
  end
  if triggerConfig.unit == "nameplate" and (not C_NamePlate or not C_NamePlate.GetNamePlateForUnit) then
    return "This client does not expose nameplate frames."
  end
end

local function ValidateSpellValues(_, triggerConfig)
  local listSet = {triggerConfig.auraspellids or {}, triggerConfig.auraRankSpellIDs or {}, triggerConfig.excludedAuraSpellIDs or {}}
  for _, entries in ipairs(listSet) do
    for _, fieldValue in ipairs(entries) do
      local auraId = tonumber(fieldValue)
      if not auraId or auraId <= 0 or auraId == math.huge or auraId ~= math.floor(auraId) then
        return "Each aura spell ID must be a positive whole number."
      end
    end
  end
end

local function ValidateFlags(_, triggerConfig)
  for _, filterRow in ipairs(Display.booleanFilters) do
    local fieldValue = triggerConfig[filterRow[1]]
    if fieldValue ~= nil and type(fieldValue) ~= "boolean" then return "Invalid aura filter: " .. filterRow[2] end
  end
  for _, filterRow in ipairs(Display.processingOptions) do
    local fieldValue = triggerConfig[filterRow[1]]
    if fieldValue ~= nil and type(fieldValue) ~= "boolean" then return "Invalid classification option: " .. filterRow[2] end
  end
end

local function ValidateSorting(_, triggerConfig)
  local maxCount = triggerConfig.maxDuration
  if maxCount ~= nil and (type(maxCount) ~= "number" or maxCount <= 0 or maxCount == math.huge or maxCount ~= maxCount) then
    return "Maximum total duration must be a positive number."
  end
  if triggerConfig.sortMethod and not Display.sortMethods[triggerConfig.sortMethod] then
    return "Choose a supported sort order."
  end
  local classificationValue = triggerConfig.processedAuraType
  if triggerConfig.sortMethod == "UnitFrameDebuff" and classificationValue ~= "Debuff" and classificationValue ~= "Dispel" then
    return "Unit-frame debuff sorting requires the Debuff or Dispellable raid debuff classification."
  end
  if classificationValue and not Display.processedTypes[classificationValue] then
    return "Choose a supported Blizzard classification."
  end
end

local function ValidateNativeFilters(_, triggerConfig)
  local knownSet = {}
  for _, filterRow in ipairs(Display.nativeFilters) do knownSet[filterRow[1]] = true end
  for fieldKey, fieldValue in pairs(triggerConfig.nativeFilters or {}) do
    if not knownSet[fieldKey] or type(fieldValue) ~= "boolean" then return "Choose supported Blizzard aura filters." end
  end
  if AuraUtil and AuraUtil.IsValidFilterString and not AuraUtil.IsValidFilterString(JoinFilters(triggerConfig)) then
    return "This client does not support the selected Blizzard aura filters."
  end
  for _, listKey in ipairs({"includeDispelTypes", "excludeDispelTypes"}) do
    for unitName, fieldValue in pairs(triggerConfig[listKey] or {}) do
      if not Display.dispelTypes[unitName] or fieldValue ~= true then return "Choose supported dispel types." end
    end
  end
end

local function ValidateDelegates(auraData, triggerConfig)
  local issue = Display.ValidateSingle(auraData, triggerConfig)
  if issue then return issue end
  issue = Display.FlowProblem(auraData, triggerConfig)
  if issue then return issue end
  issue = Display.ValidateConditions(auraData)
  if issue then return issue end
end

local function ValidateActions(auraData)
  for timing, actionEntry in pairs(auraData.actions or {}) do
    if timing ~= "init" then
      for fieldKey, fieldValue in pairs(actionEntry) do
        if fieldKey:match("^do_") and fieldKey ~= "do_sound" and fieldKey ~= "do_message" and fieldValue then
          return "Secret Aura trigger detected. Only Chat Message, Play Sound and Hide Glows are supported in On Show/On Hide. Custom Init is available."
        end
      end
      if actionEntry.stop_sound or (actionEntry.do_sound and actionEntry.sound == " KitID") then
        return "Secret aura sounds support sound files, not Sound Kit IDs or Stop Sound."
      end
    end
  end
  for _, animationEntry in pairs(auraData.animation or {}) do
    if animationEntry.type and animationEntry.type ~= "none" then
      return "Secret Aura trigger detected. You cannot use Animations on this aura."
    end
  end
end

local VALIDATION_STEPS = {
  ValidateRequiredSpells,
  ValidateUnit,
  ValidateSpellValues,
  ValidateFlags,
  ValidateSorting,
  ValidateNativeFilters,
  ValidateDelegates,
  ValidateActions,
}

function Display.Validate(auraData)
  if not Display.Eligible(auraData) then
    return "Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text."
  end
  if auraData.regionType == "progresstexture" and Internal.ProgressTextureNative.IsCircular(auraData.orientation)
    and not Enum.StatusBarRenderMode then
    return "This client does not support native circular Progress Textures."
  end
  local issue = Display.ValidateAppearance(Display.PrepareConditionAppearance(auraData))
  if issue then return issue end
  local triggerConfig = Display.GetTrigger(auraData, true)
  for _, checker in ipairs(VALIDATION_STEPS) do
    issue = checker(auraData, triggerConfig)
    if issue then return issue end
  end
end

function Display.Elements(displayOptions)
  if not displayOptions.elements then
    local entries = {"border"}
    displayOptions.elements = entries
    if displayOptions.glow then entries[#entries + 1] = "glow" end
    if displayOptions.duration ~= false then entries[#entries + 1] = "duration" end
    if displayOptions.stacks ~= false then entries[#entries + 1] = "stack" end
    if displayOptions.label and displayOptions.label ~= "" then entries[#entries + 1] = "label" end
  end
  return displayOptions.elements
end

local function UpgradeLegacyTrigger(auraData)
  local legacyConfig = auraData.blizzardAuraDisplay
  if legacyConfig and legacyConfig.enabled and auraData.triggers and #auraData.triggers == 1
    and auraData.triggers[1].trigger.type == "aura2" then
    auraData.triggers[1].trigger.type = "secretAura"
    auraData.blizzardAuraDisplay.enabled = nil
  end
end

local function CleanSecretTrigger(auraData, triggerConfig)
  triggerConfig.unit = triggerConfig.unit or "player"
  triggerConfig.debuffType = triggerConfig.debuffType or "HELPFUL"
  triggerConfig.auraspellids = triggerConfig.auraspellids or {}
  triggerConfig.useExactSpellId = true
  triggerConfig.onlyMaw = nil
  Display.MigrateSingle(auraData, triggerConfig)
  Display.MigrateTotal(triggerConfig)
  auraData.blizzardAuraDisplay = auraData.blizzardAuraDisplay or {}
  auraData.blizzardAuraDisplay.enabled = nil
end

local function SubtextOffsetDefaults(elementFrame)
  if elementFrame.text_alpha == nil then elementFrame.text_alpha = 1 end
  if elementFrame.text_anchorXOffset == nil then elementFrame.text_anchorXOffset = elementFrame.anchorXOffset or 0 end
  if elementFrame.text_anchorYOffset == nil then elementFrame.text_anchorYOffset = elementFrame.anchorYOffset or 0 end
end

local function PickSoundChannel()
  local soundChannel = FojjiCore and FojjiCoreDB and FojjiCoreDB.ttsSoundChannel
  if soundChannel == "Sound Effects" then soundChannel = "SFX" end
  if VALID_SOUND_CHANNELS[soundChannel] then return soundChannel end
  return "Master"
end

function Display.MigrateSounds(auraData)
  local displayOptions = auraData.blizzardAuraDisplay
  if displayOptions.actionSounds then return end
  auraData.actions = auraData.actions or {}
  local modeName = displayOptions.soundMode
  for _, eventName in ipairs({"Added", "Removed"}) do
    local timing = eventName == "Added" and "start" or "finish"
    auraData.actions[timing] = auraData.actions[timing] or {}
    local actionEntry = auraData.actions[timing]
    local fieldValue = displayOptions["sound" .. eventName]
    if modeName == "file" then fieldValue = displayOptions["sound" .. eventName .. "File"] or fieldValue end
    if not actionEntry.do_sound and modeName and modeName ~= "none" and fieldValue and fieldValue ~= "" and fieldValue ~= 1 then
      actionEntry.do_sound = true
      actionEntry.sound_channel = PickSoundChannel()
      if modeName == "fojji" then
        actionEntry.sound = " Fojji"
        actionEntry.sound_fojji = fieldValue
      else
        actionEntry.sound = " custom"
        actionEntry.sound_path = tostring(fieldValue)
      end
    end
  end
  displayOptions.soundMode, displayOptions.soundAdded, displayOptions.soundRemoved = nil, nil, nil
  displayOptions.soundAddedFile, displayOptions.soundRemovedFile = nil, nil
  displayOptions.actionSounds = true
end

function Display.Migrate(auraData)
  local legacyConfig = auraData.blizzardAuraDisplay
  UpgradeLegacyTrigger(auraData)
  for _, listEntry in ipairs(auraData.triggers or {}) do
    if type(listEntry) == "table" and listEntry.trigger and listEntry.trigger.type == "secretAura" then
      CleanSecretTrigger(auraData, listEntry.trigger)
    end
  end
  if not Display.HasTrigger(auraData) then return end
  Display.MigrateAppearance(auraData, legacyConfig)
  for _, elementFrame in ipairs(auraData.subRegions or {}) do
    if elementFrame.type == "subtext" then SubtextOffsetDefaults(elementFrame) end
  end
  Display.MigrateSounds(auraData)
  auraData.blizzardAuraDisplay.soundSpellIDs = nil
  auraData.blizzardAuraDisplay.soundIgnoreDisplayFilters = nil
end

function Internal.ResolveFojjiRecordedSound(fieldValue)
  local database = FojjiCoreDB
  if not FojjiCore or not database then return nil, "FojjiCore is not loaded." end
  if database.disableTTS then return nil, "Speech is disabled in FojjiCore." end
  if database.ttsVoiceType ~= "custom" or database.ttsRandomFavorites then
    return nil, "Select one recorded voice pack in FojjiCore. Recorded sounds cannot use synthesized TTS or random favorites."
  end
  local packed = FojjiCore.voicePacks and FojjiCore.voicePacks[database.ttsVoicePack]
  local soundFile = packed and packed[fieldValue]
  if not soundFile then
    return nil, "No recording for '" .. fieldValue .. "' in the selected FojjiCore voice pack."
  end
  return soundFile
end

local function SoundActionKey(actionEntry)
  return table.concat({
    tostring(actionEntry.do_sound), tostring(actionEntry.sound), tostring(actionEntry.sound_path),
    tostring(actionEntry.sound_fojji), tostring(actionEntry.sound_channel),
  }, ",")
end

local function MakeSoundSignature(displayState)
  local triggerConfig = Display.GetTrigger(displayState.data)
  local actionList = displayState.data.actions or {}
  local pieces = {}
  for _, soundPhase in ipairs({"start", "finish"}) do
    pieces[#pieces + 1] = SoundActionKey(actionList[soundPhase] or {})
  end
  pieces[#pieces + 1] = table.concat(ExpandUnits(triggerConfig), ",")
  pieces[#pieces + 1] = table.concat(Display.GetSpellIDs(triggerConfig, true), ",")
  pieces[#pieces + 1] = table.concat(triggerConfig.excludedAuraSpellIDs or {}, ",")
  return table.concat(pieces, "|")
end

local function GatherSoundSpells(triggerConfig)
  local spellIdList = {}
  for _, fieldValue in ipairs(Display.GetSpellIDs(triggerConfig, true)) do
    local auraId = tonumber(fieldValue)
    if auraId and auraId > 0 and auraId < math.huge and auraId == math.floor(auraId) then spellIdList[auraId] = true end
  end
  if Display.UsesExcludedSpellIDs(triggerConfig) then
    for _, fieldValue in ipairs(triggerConfig.excludedAuraSpellIDs or {}) do
      local auraId = tonumber(fieldValue)
      if auraId then spellIdList[auraId] = nil end
    end
  end
  return spellIdList
end

local function ActionSoundFile(actionEntry)
  local soundFile, warningText
  if actionEntry.sound == " Fojji" then
    soundFile, warningText = Internal.ResolveFojjiRecordedSound(actionEntry.sound_fojji or "")
  elseif actionEntry.sound == " custom" then
    soundFile = tonumber(actionEntry.sound_path) or actionEntry.sound_path
  elseif actionEntry.sound ~= " KitID" then
    soundFile = actionEntry.sound
  end
  if not soundFile or soundFile == "" or soundFile == 1 then
    return nil, warningText or "Choose a sound file in Actions."
  end
  return soundFile, warningText
end

local function BindNativeSounds(displayState, actionList, triggerConfig, spellIdList)
  local failureText
  local unitSet = ExpandUnits(triggerConfig)
  for _, eventName in ipairs({"Added", "Removed"}) do
    local actionEntry = actionList[eventName == "Added" and "start" or "finish"] or {}
    if actionEntry.do_sound then
      local soundFile, warningText = ActionSoundFile(actionEntry)
      if soundFile then
        for _, unitId in ipairs(unitSet) do
          for spellId in pairs(spellIdList) do
            local succeeded, auraId = pcall(C_UnitAuras.AddAuraSound, Enum.UnitAuraSoundTrigger[eventName], {
              unitToken = unitId,
              spellID = spellId,
              soundFileName = type(soundFile) == "string" and soundFile or nil,
              soundFileID = type(soundFile) == "number" and soundFile or nil,
              outputChannel = actionEntry.sound_channel or "Master",
            })
            if succeeded and auraId then
              displayState.soundIDs[#displayState.soundIDs + 1] = auraId
            else
              failureText = "Blizzard could not register the " .. eventName:lower() .. " sound for spell " .. spellId .. "."
            end
          end
        end
      else
        failureText = warningText
      end
    end
  end
  return failureText
end

local function UpdateSounds(auraRegion)
  if IsRestricted() then
    queuedSoundSyncs[auraRegion] = true
    return
  end
  queuedSoundSyncs[auraRegion] = nil
  local displayState = auraRegion.blizzardAuraDisplay
  if not displayState then return end
  local soundFingerprint
  if displayState.active and auraRegion:IsShown() and not InPreview() then
    soundFingerprint = MakeSoundSignature(displayState)
    if soundFingerprint == displayState.soundSignature then return end
  end
  displayState.soundSignature = soundFingerprint
  for _, auraId in ipairs(displayState.soundIDs or {}) do C_UnitAuras.RemoveAuraSound(auraId) end
  displayState.soundIDs = {}
  local auraData = displayState.data
  PostSoundWarning(auraData)
  if not displayState.active or not auraRegion:IsShown() or InPreview() then return end
  local actionList = auraData.actions or {}
  if not ((actionList.start or {}).do_sound or (actionList.finish or {}).do_sound) then return end
  if not C_UnitAuras or not C_UnitAuras.AddAuraSound or not C_UnitAuras.RemoveAuraSound
    or not Enum.UnitAuraSoundTrigger then
    PostSoundWarning(auraData, "This client does not provide native aura sound registration.")
    return
  end
  local triggerConfig = Display.GetTrigger(auraData)
  local spellIdList = GatherSoundSpells(triggerConfig)
  if not next(spellIdList) then
    PostSoundWarning(auraData, "Enable Spell ID(s) or Exact Spell ID(s) in Trigger and enter an ID that is not ignored to use aura sounds.")
    return
  end
  PostSoundWarning(auraData, BindNativeSounds(displayState, actionList, triggerConfig, spellIdList))
end

local function RefreshPreviewNotice(auraRegion)
  local auraData = auraRegion.blizzardAuraDisplay and auraRegion.blizzardAuraDisplay.data
  local triggerConfig = Display.GetTrigger(auraData)
  local warningEntry
  if triggerConfig and Display.SpellIDFilterNote(triggerConfig) == "error" then
    warningEntry = "Preview only: these auras will not display in combat with spell ID filters.\nConfigured sounds in Actions can still play."
  end
  if warningEntry then
    local noticeText = auraRegion.secretAuraPreviewNotice
    if not noticeText then
      noticeText = auraRegion:CreateFontString(nil, "OVERLAY")
      noticeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
      noticeText:SetPoint("TOP", auraRegion, "BOTTOM", 0, -6)
      noticeText:SetWidth(300)
      noticeText:SetTextColor(1, 0.8, 0.2)
      auraRegion.secretAuraPreviewNotice = noticeText
    end
    noticeText:SetText(warningEntry)
    noticeText:Show()
  elseif auraRegion.secretAuraPreviewNotice then
    auraRegion.secretAuraPreviewNotice:Hide()
  end
end

local function HideAndRemember(savedTrigger, targetFrame)
  if savedTrigger[targetFrame] == nil then savedTrigger[targetFrame] = targetFrame:GetAlpha() end
  targetFrame:SetAlpha(0)
end

local function HideProgressLayers(auraRegion, savedTrigger)
  HideAndRemember(savedTrigger, auraRegion.foreground.texture)
  HideAndRemember(savedTrigger, auraRegion.background.texture)
  for _, spinnerFrame in ipairs({auraRegion.foregroundSpinner, auraRegion.backgroundSpinner}) do
    for _, textureLayer in ipairs(spinnerFrame.textures) do HideAndRemember(savedTrigger, textureLayer) end
  end
  for _, extraValue in ipairs(auraRegion.extraTextures) do HideAndRemember(savedTrigger, extraValue.texture) end
  for _, spinnerFrame in ipairs(auraRegion.extraSpinners) do
    for _, textureLayer in ipairs(spinnerFrame.textures) do HideAndRemember(savedTrigger, textureLayer) end
  end
  if auraRegion.nativeProgress then HideAndRemember(savedTrigger, auraRegion.nativeProgress.bar) end
end

local function HideRegionParts(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  if InPreview() and not auraRegion.secretAuraSamplesActive and not (displayState and displayState.previewHasAuras) then
    for targetFrame, opacity in pairs(auraRegion.blizzardSuppressed or {}) do targetFrame:SetAlpha(opacity) end
    auraRegion.blizzardSuppressed = nil
    RefreshPreviewNotice(auraRegion)
    return
  end
  if auraRegion.secretAuraPreviewNotice then auraRegion.secretAuraPreviewNotice:Hide() end
  auraRegion.blizzardSuppressed = auraRegion.blizzardSuppressed or {}
  local savedTrigger = auraRegion.blizzardSuppressed
  for _, fieldKey in ipairs(HIDDEN_REGION_FIELDS) do
    local targetFrame = auraRegion[fieldKey]
    if targetFrame and targetFrame.SetAlpha then HideAndRemember(savedTrigger, targetFrame) end
  end
  if auraRegion.regionType == "progresstexture" then HideProgressLayers(auraRegion, savedTrigger) end
  local backgroundBar = auraRegion.bar and auraRegion.bar.bg
  if backgroundBar then HideAndRemember(savedTrigger, backgroundBar) end
  for _, childRegion in ipairs(auraRegion.subRegions or {}) do
    if childRegion.SetAlpha and not childRegion.secretAuraDetached then HideAndRemember(savedTrigger, childRegion) end
  end
end

function Display.Restore(auraRegion)
  if Display.HidePreview then Display.HidePreview(auraRegion) end
  if Display.RestorePreviewRegion then Display.RestorePreviewRegion(auraRegion) end
  if auraRegion.secretAuraPreviewNotice then auraRegion.secretAuraPreviewNotice:Hide() end
  auraRegion.secretAuraConditionValues = nil
  for targetFrame, opacity in pairs(auraRegion.blizzardSuppressed or {}) do targetFrame:SetAlpha(opacity) end
  auraRegion.blizzardSuppressed = nil
  if auraRegion.blizzardOriginalUpdate then
    auraRegion.Update = auraRegion.blizzardOriginalUpdate.func
    auraRegion.blizzardOriginalUpdate = nil
  end
  if auraRegion.blizzardOriginalPreShow then
    auraRegion.PreShow = auraRegion.blizzardOriginalPreShow.func
    auraRegion.blizzardOriginalPreShow = nil
  end
end

function Display.HideUnitGlows(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  if not displayState then return end
  displayState.unitGlowsHidden = true
  for _, displayInstance in ipairs(displayState.instances) do
    local glowFrame = displayInstance.unitGlow
    if glowFrame then
      glowFrame.container:SetEnabled(false)
      glowFrame.container:Hide()
    end
  end
end

function Display.Release(auraRegion)
  Display.ReleaseAuraLearning(auraRegion)
  Display.HideUnitGlows(auraRegion)
  Display.Restore(auraRegion)
  queuedApplies[auraRegion] = nil
  if Display.CancelEditorApply then Display.CancelEditorApply(auraRegion) end
  local displayState = auraRegion.blizzardAuraDisplay
  if not displayState then return end
  displayState.active = false
  displayState.instanceQueue = nil
  for _, displayInstance in ipairs(displayState.instances) do
    displayInstance.container:SetEnabled(false)
    displayInstance.container:Hide()
    Display.RefreshSingle(displayInstance, nil, false)
  end
  Internal.AuraWarnings.UpdateWarning(displayState.data.uid, "blizzard_aura_single", nil)
  Internal.AuraWarnings.UpdateWarning(displayState.data.uid, "blizzard_aura_dynamicgroup", nil)
  liveRegions[auraRegion] = nil
  UpdateSounds(auraRegion)
  Display.RechainFlow(Display.FlowGroup(displayState.data))
end

function Display.RetireFrame(targetFrame)
  if not targetFrame then return end
  retiredParent = retiredParent or CreateFrame("Frame")
  retiredParent:Hide()
  if targetFrame.SetEnabled then targetFrame:SetEnabled(false) end
  targetFrame:Hide()
  targetFrame:ClearAllPoints()
  targetFrame:SetParent(retiredParent)
end

local function ResolveElement(displayState, fieldKey)
  displayState.elementFrames = displayState.elementFrames or {}
  local frameList = displayState.elementFrames
  if not frameList[fieldKey] then
    local targetFrame = CreateFrame("Frame", nil, displayState.gateClip or displayState.button)
    targetFrame:SetAllPoints(displayState.button)
    targetFrame:EnableMouse(false)
    frameList[fieldKey] = targetFrame
  end
  return frameList[fieldKey]
end

local function ApplyTextStyle(labelText, displayState, displayOptions, fieldKey, iconSize, anchorRef, defaultX, defaultY)
  local fontPath = displayOptions[fieldKey .. "Font"]
  local outlineMode = displayOptions[fieldKey .. "Outline"]
  Internal.ApplyTextFont(labelText, nil, fontPath and MediaLibrary:Fetch("font", fontPath) or "Fonts\\ARIALN.TTF",
    displayOptions[fieldKey .. "Size"] or iconSize, (outlineMode == "None" and "" or outlineMode) or "OUTLINE",
    displayOptions[fieldKey .. "ShadowColor"] or {0, 0, 0, 0}, displayOptions[fieldKey .. "ShadowX"] or 1, displayOptions[fieldKey .. "ShadowY"] or -1)
  labelText:SetTextColor(unpack(displayOptions[fieldKey .. "Color"] or {1, 1, 1, 1}))
  local anchorSpot = displayOptions[fieldKey .. "Anchor"] or anchorRef
  local ownPoint = displayOptions[fieldKey .. "SelfPoint"]
  local targetValue = displayState.button
  local areaFrame = anchorSpot:sub(1, 6)
  local innerFrame, outerFrame = areaFrame == "INNER_", areaFrame == "OUTER_"
  if innerFrame or outerFrame then
    targetValue = innerFrame and displayState.inner or displayState.outer
    anchorSpot = anchorSpot:sub(7)
  end
  ownPoint = ownPoint or ((innerFrame or outerFrame) and "AUTO" or anchorSpot)
  if ownPoint == "AUTO" then
    ownPoint = innerFrame and anchorSpot or outerFrame and Internal.inverse_point_types[anchorSpot] or "CENTER"
  end
  labelText:ClearAllPoints()
  labelText:SetPoint(ownPoint, targetValue, anchorSpot, displayOptions[fieldKey .. "X"] or defaultX, displayOptions[fieldKey .. "Y"] or defaultY)
  labelText:SetJustifyH(displayOptions[fieldKey .. "Justify"] or "CENTER")
end
Display.StyleText = ApplyTextStyle

local function MakeProcLayers(listEntry, textureLayer, groupName)
  textureLayer:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
  local fadeOptions = groupName:CreateAnimation("Alpha")
  fadeOptions:SetTarget(textureLayer)
  fadeOptions:SetOrder(1)
  fadeOptions:SetFromAlpha(1)
  fadeOptions:SetToAlpha(1)
  fadeOptions:SetDuration(0.001)
  local flipbookTexture = groupName:CreateAnimation("FlipBook")
  flipbookTexture:SetTarget(textureLayer)
  flipbookTexture:SetOrder(1)
  flipbookTexture:SetFlipBookRows(6)
  flipbookTexture:SetFlipBookColumns(5)
  flipbookTexture:SetFlipBookFrames(30)
  flipbookTexture:SetFlipBookFrameWidth(0)
  flipbookTexture:SetFlipBookFrameHeight(0)
  listEntry.animations[1] = flipbookTexture
end

local function MakePulseLayers(listEntry, textureLayer, groupName)
  textureLayer:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
  textureLayer:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
  for stepSize = 1, 2 do
    local fadeOptions = groupName:CreateAnimation("Alpha")
    fadeOptions:SetTarget(textureLayer)
    fadeOptions:SetOrder(stepSize)
    fadeOptions:SetFromAlpha(stepSize == 1 and 0.25 or 1)
    fadeOptions:SetToAlpha(stepSize == 1 and 1 or 0.25)
    listEntry.animations[stepSize] = fadeOptions
  end
end

local function MakeGlow(displayState, unitGlowFrame)
  local glowFrame = {}
  for _, variant in ipairs({"proc", "pulse"}) do
    local parentFrame = unitGlowFrame and displayState.overlay or ResolveElement(displayState, "glow")
    local textureLayer = parentFrame:CreateTexture(nil, "OVERLAY", nil, -1)
    textureLayer:SetBlendMode("ADD")
    textureLayer:SetDesaturated(true)
    textureLayer:Hide()
    local groupName = textureLayer:CreateAnimationGroup()
    groupName:SetLooping("REPEAT")
    groupName:SetToFinalAlpha(true)
    local listEntry = {texture = textureLayer, group = groupName, animations = {}}
    glowFrame[variant] = listEntry
    if variant == "proc" then
      MakeProcLayers(listEntry, textureLayer, groupName)
    else
      MakePulseLayers(listEntry, textureLayer, groupName)
    end
  end
  displayState.glow = glowFrame
  return glowFrame
end

local function UnitGlowOptions(displayOptions)
  return {
    glow = displayOptions.unitGlow,
    glowType = displayOptions.unitGlowType,
    glowColor = displayOptions.unitGlowColor,
    glowDuration = displayOptions.unitGlowDuration,
    glowX = displayOptions.unitGlowX,
    glowY = displayOptions.unitGlowY,
    useGlowColor = displayOptions.unitUseGlowColor,
    padding = displayOptions.unitGlowPadding or 0,
  }
end

local function ApplyGlowStyle(displayState, auraData, unitGlowFrame)
  local displayOptions = auraData.blizzardAuraDisplay
  if unitGlowFrame then displayOptions = UnitGlowOptions(displayOptions) end
  local glowFrame = displayState.glow
  if not glowFrame and not displayOptions.glow then return end
  glowFrame = glowFrame or MakeGlow(displayState, unitGlowFrame)
  if glowFrame.registered then
    displayState.button:RemoveAuraShownAnimation(glowFrame.registered)
    glowFrame.registered = nil
  end
  for _, variant in ipairs({"proc", "pulse"}) do
    glowFrame[variant].group:Stop()
    glowFrame[variant].texture:Hide()
  end
  if not displayOptions.glow then return end
  local listEntry = glowFrame[displayOptions.glowType or "proc"] or glowFrame.proc
  local textureLayer = listEntry.texture
  local scaleFactor = math.max(0.5, displayOptions.glowScale or 1)
  local seconds = math.max(0.1, displayOptions.glowDuration or 1)
  local shiftX, shiftY = displayOptions.glowX or 0, displayOptions.glowY or 0
  textureLayer:ClearAllPoints()
  if unitGlowFrame then
    local innerPadding = displayOptions.padding
    textureLayer:SetPoint("TOPLEFT", displayState.button, "TOPLEFT", shiftX - innerPadding, shiftY + innerPadding)
    textureLayer:SetPoint("BOTTOMRIGHT", displayState.button, "BOTTOMRIGHT", shiftX + innerPadding, shiftY - innerPadding)
  else
    textureLayer:SetPoint("CENTER", displayState.glowAnchor or displayState.button, "CENTER", shiftX, shiftY)
    local frameWidth = math.max(4, displayState.glowWidth or auraData.width or auraData.fixedWidth or 200)
    local frameHeight = math.max(4, displayState.glowHeight or auraData.height or auraData.fontSize or 18)
    textureLayer:SetSize(frameWidth * 1.4 * scaleFactor, frameHeight * 1.4 * scaleFactor)
  end
  textureLayer:SetVertexColor(unpack(displayOptions.useGlowColor ~= false and displayOptions.glowColor or {1, 0.82, 0, 1}))
  textureLayer:SetAlpha(listEntry == glowFrame.pulse and 0.25 or 0)
  for _, animationEntry in ipairs(listEntry.animations) do animationEntry:SetDuration(seconds / #listEntry.animations) end
  textureLayer:Show()
  displayState.button:AddAuraShownAnimation(listEntry.group)
  listEntry.group:Play()
  glowFrame.registered = listEntry.group
end

local function ApplyNativeStyle(displayState, auraData, auraRegion)
  Display.StyleAppearance(displayState, Display.PrepareConditionAppearance(auraData), ResolveElement, ApplyTextStyle, ApplyGlowStyle)
  Display.ApplyConditionAppearance(displayState, auraRegion, auraData)
end
Display.StyleNative = ApplyNativeStyle

local function ApplySampleStyle(sampleFrame, auraData)
  Display.StyleAppearance(sampleFrame, Display.PrepareConditionAppearance(auraData), ResolveElement, ApplyTextStyle, ApplyGlowStyle)
end

local function SpellIdLookup(valueList)
  local lookup = {}
  for _, fieldValue in ipairs(valueList or {}) do lookup[tonumber(fieldValue)] = true end
  return next(lookup) and lookup or nil
end

local function FilterCandidates(auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  local totalComparison, totalValue = Display.TotalFilter(triggerConfig)
  local filterList = {maxDuration = totalComparison == "<=" and totalValue + 0.05 or totalComparison == "=" and totalValue + 0.5 or nil}
  if Display.UsesSpellIDs(triggerConfig) or Display.UsesRankSpellIDs(triggerConfig) then
    filterList.includeSpellIDs = SpellIdLookup(Display.GetSpellIDs(triggerConfig, true)) or {}
  end
  if Display.UsesExcludedSpellIDs(triggerConfig) then
    filterList.excludeSpellIDs = SpellIdLookup(triggerConfig.excludedAuraSpellIDs)
  end
  for _, filterRow in ipairs(Display.booleanFilters) do
    local fieldKey = filterRow[1]
    if Display.FilterApplies(fieldKey, triggerConfig) and (not IsPlateFilter(fieldKey) or triggerConfig.unit == "nameplate") then
      filterList[fieldKey] = triggerConfig[fieldKey]
    end
  end
  for _, listKey in ipairs({"includeDispelTypes", "excludeDispelTypes"}) do
    if next(triggerConfig[listKey] or {}) then
      local clone = {}
      filterList[listKey] = clone
      for unitName, fieldValue in pairs(triggerConfig[listKey]) do clone[unitName] = fieldValue end
    end
  end
  return Display.ApproximateFilters(triggerConfig, filterList)
end
Display.CandidateFilters = FilterCandidates

local function SetupProcessing(auraContainer, triggerConfig)
  auraContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
end

local function UpdatePreview(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  displayState.previewHasAuras = InPreview()
  if displayState.previewHasAuras then
    if not (auraRegion.secretAuraSamplesActive and displayState.previewStyled == displayState.data) then
      Display.ShowPreview(auraRegion, displayState.data, ApplySampleStyle)
      displayState.previewStyled = displayState.data
    end
    Display.ArrangeFlowPreview(Display.FlowGroup(displayState.data))
  else
    Display.RestorePreviewRegion(auraRegion)
    Display.RestoreGroupPreview(Display.FlowGroup(displayState.data))
    Display.HidePreview(auraRegion)
  end
  HideRegionParts(auraRegion)
  if InPreview() then RefreshPreviewNotice(auraRegion) end
end

local function SetupGlowButton(glowState, auraData, auraButton)
  glowState.button = auraButton
  auraButton:SetFrameLevel(glowState.container:GetFrameLevel() + 1)
  auraButton:SetAllPoints(glowState.container)
  auraButton:EnableMouse(false)
  glowState.overlay = CreateFrame("Frame", nil, auraButton)
  glowState.overlay:SetAllPoints(auraButton)
  glowState.overlay:SetFrameLevel(glowState.container:GetFrameLevel() + 2)
  ApplyGlowStyle(glowState, auraData, true)
end

local function SetupUnitGlow(displayInstance, auraRegion, auraData)
  local glowState = displayInstance.unitGlow
  if auraData.anchorFrameType ~= "UNITFRAME" or not auraData.blizzardAuraDisplay.unitGlow then
    if glowState then
      glowState.container:SetEnabled(false)
      glowState.container:Hide()
    end
    return
  end
  local triggerConfig = Display.GetTrigger(auraData)
  if glowState then
    glowState.container:SetEnabled(false)
    ApplyGlowStyle(glowState, auraData, true)
  else
    glowState = {container = CreateFrame("AuraContainer", nil, auraRegion, "CustomAuraContainerTemplate")}
    displayInstance.unitGlow = glowState
    glowState.container:SetEnabled(false)
    SetupProcessing(glowState.container, triggerConfig)
    glowState.container:AddAuraSlot("UnitGlow", JoinFilters(triggerConfig), {
      candidateFilters = FilterCandidates(auraData),
      initializeFrame = function(auraButton) SetupGlowButton(glowState, auraData, auraButton) end,
    })
  end
  local auraContainer = glowState.container
  SetupProcessing(auraContainer, triggerConfig)
  auraContainer:SetAuraSlotSortMethod("UnitGlow", Display.SortOrder(auraData, triggerConfig))
  auraContainer:SetAuraSlotFilterString("UnitGlow", JoinFilters(triggerConfig))
  auraContainer:SetAuraSlotCandidateFilters("UnitGlow", FilterCandidates(auraData))
end

local function PackUnits(auraData)
  if Display.FlowGroup(auraData) and not Display.FlowFrameMode(auraData) then
    return SlotCount(Display.GetTrigger(auraData)) > 1
  end
  return auraData.anchorFrameType ~= "UNITFRAME" and not Display.UsesNameplates(auraData)
    and SlotCount(Display.GetTrigger(auraData)) > 1
end

local function AnchorForGrowth(flowDirection)
  return flowDirection == "LEFT" and "TOPRIGHT" or flowDirection == "UP" and "BOTTOMLEFT" or "TOPLEFT"
end

local function GrowsVertically(flowDirection)
  return flowDirection == "UP" or flowDirection == "DOWN" or flowDirection == "CENTER_VERTICAL"
end

local function ApplyLayout(displayInstance, auraRegion, auraData)
  local frameWidth, frameHeight = Display.Dimensions(auraData)
  local displayOptions = auraData.blizzardAuraDisplay
  local flowDirection = Display.Growth(auraData)
  local isVertical = GrowsVertically(flowDirection)
  local anchorRef = AnchorForGrowth(flowDirection)
  local auraContainer = displayInstance.container
  auraContainer:ClearAllPoints()
  local isCentered = flowDirection == "CENTER_HORIZONTAL" or flowDirection == "CENTER_VERTICAL"
  if isCentered then
    auraContainer:SetPoint("CENTER", auraRegion, "CENTER")
  else
    Display.AnchorToContent(auraContainer, anchorRef, auraRegion, anchorRef)
  end
  auraContainer:SetFlowLayoutAxis(isVertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
  auraContainer:SetFlowLayoutAnchorPoint(anchorRef)
  auraContainer:SetFlowLayoutGrowthDirection(
    flowDirection == "LEFT" and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
    flowDirection == "UP" and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down)
  local _, flowGap = Display.FlowGrowth(auraData)
  local gap = flowGap or displayOptions.spacing or 6
  local compactList = not isCentered and (PackUnits(auraData) or flowGap ~= nil)
  if Display.UsesGate(auraData) then gap = -(isVertical and frameHeight or frameWidth) end
  auraContainer:SetAuraGroupLayout("Auras", {
    elementWidth = frameWidth + (compactList and not isVertical and gap + 1 or 0),
    elementHeight = frameHeight + (compactList and isVertical and gap + 1 or 0),
    elementSpacing = compactList and -1 or gap,
  })
  auraContainer:SetAuraGroupMaxFrameCount("Auras", Display.MaxAuras(auraData))
end

local function SetupAuraButton(displayKind, auraRegion, auraContainer, auraButton)
  local displayState = {container = auraContainer}
  displayState.button = auraButton
  auraButton:EnableMouse(false)
  displayState.gateClip = CreateFrame("Frame", nil, auraButton, "DisableUntrustedLayoutScriptsTemplate")
  displayState.gateClip:SetClipsChildren(true)
  displayState.gateClip:SetAllPoints(auraButton)
  displayState.gateText = auraButton:CreateFontString(nil, "BACKGROUND")
  for _, areaFrame in ipairs({"inner", "outer"}) do
    local targetFrame = CreateFrame("Frame", nil, auraButton)
    displayState[areaFrame] = targetFrame
    targetFrame:SetPoint("CENTER", auraButton, "CENTER")
    targetFrame:EnableMouse(false)
  end
  displayState.border = (displayState.gateClip or auraButton):CreateTexture(nil, "BACKGROUND")
  displayState.border:SetAllPoints(auraButton)
  local baseValue = ResolveElement(displayState, "sharedBase")
  displayState.icon = baseValue:CreateTexture(nil, "ARTWORK")
  auraButton:SetIcon(displayState.icon)
  displayState.cooldown = CreateFrame("Cooldown", nil, baseValue, "CooldownFrameTemplate")
  displayState.cooldown:SetAllPoints(displayState.icon)
  displayState.cooldown:SetDrawBling(false)
  displayState.cooldown:SetHideCountdownNumbers(true)
  auraButton:SetDurationCooldown(displayState.cooldown)
  displayState.overlay = CreateFrame("Frame", nil, displayState.gateClip or auraButton)
  displayState.overlay:SetAllPoints(auraButton)
  displayState.overlay:SetFrameLevel(displayState.cooldown:GetFrameLevel() + 1)
  ApplyNativeStyle(displayState, displayKind.data, auraRegion)
  displayKind.buttons[#displayKind.buttons + 1] = displayState
end

local function MakeInstance(auraRegion, auraData)
  local displayKind = {buttons = {}, data = auraData}
  local auraContainer, isInFlow = Display.CreateAuraContainer(auraRegion, auraData)
  displayKind.container = auraContainer
  displayKind.flowContainer = isInFlow
  auraContainer:SetEnabled(false)
  SetupProcessing(auraContainer, Display.GetTrigger(auraData))
  auraContainer:SetPoint("TOPLEFT", auraRegion, "TOPLEFT")
  auraContainer:AddAuraGroup("Auras", JoinFilters(Display.GetTrigger(auraData)), {
    maxFrameCount = Display.MaxAuras(auraData),
    candidateFilters = FilterCandidates(auraData),
    initializeFrame = function(auraButton) SetupAuraButton(displayKind, auraRegion, auraContainer, auraButton) end,
  })
  return displayKind
end

local function HasChanged(currentValue, isWanted)
  return issecretvalue(currentValue) or currentValue ~= isWanted
end

local glowSizeByFrame = setmetatable({}, {__mode = "k"})

local function PlaceUnitGlow(auraContainer, targetFrame)
  local iconSize = glowSizeByFrame[targetFrame]
  if not iconSize then
    iconSize = {x = 0, y = 0}
    glowSizeByFrame[targetFrame] = iconSize
    targetFrame:HookScript("OnSizeChanged", function() Display.UnitFramesChanged() end)
  end
  local frameWidth, frameHeight = targetFrame:GetSize()
  if not issecretvalue(frameWidth) and not issecretvalue(frameHeight) then
    iconSize.x, iconSize.y = frameWidth * 0.2, frameHeight * 0.2
  end
  auraContainer:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", -iconSize.x, iconSize.y)
  auraContainer:SetPoint("BOTTOMRIGHT", targetFrame, "BOTTOMRIGHT", iconSize.x, -iconSize.y)
end

function Display.UpdateDetachedFrameLevels(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  if not displayState or not displayState.active then return end
  local frameLevel = auraRegion:GetFrameLevel()
  for _, displayInstance in ipairs(displayState.instances) do
    local holderLevel = displayInstance.container:GetFrameLevel()
    if not issecretvalue(holderLevel) then frameLevel = math.max(frameLevel, holderLevel) end
  end
  frameLevel = frameLevel + #(displayState.data.subRegions or {}) * 3 + 8
  for position, elementFrame in ipairs(auraRegion.subRegions or {}) do
    if elementFrame.secretAuraDetached then elementFrame:SetFrameLevel(frameLevel + position) end
  end
end

local function AttachModes(auraData, attachMode)
  if Display.FlowGroup(auraData) then
    return attachMode == "UNITFRAME", attachMode == "NAMEPLATE"
  end
  local unitFrameMap = auraData.anchorFrameType == "UNITFRAME"
  return unitFrameMap, not unitFrameMap and Display.UsesNameplates(auraData)
end

local function LocateAnchor(unitId, unitFrameMap, plateMap, droppedUnit)
  local targetFrame
  if unitId then
    if unitFrameMap then
      targetFrame = WeakAuras.GetUnitFrame(unitId)
    elseif plateMap and unitId ~= droppedUnit then
      targetFrame = C_NamePlate.GetNamePlateForUnit(unitId)
    end
  end
  if targetFrame and targetFrame:IsForbidden() then targetFrame = nil end
  return targetFrame
end

local function AttachContainer(holderFrame, auraContainer, unitId, parentFrame)
  if holderFrame.boundUnit ~= unitId or auraContainer:GetParent() ~= parentFrame then
    auraContainer:SetEnabled(false)
    if unitId then auraContainer:SetUnit(unitId) end
    holderFrame.boundUnit = unitId
    if auraContainer:GetParent() ~= parentFrame then auraContainer:SetParent(parentFrame) end
  end
end

local function AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  local frameLevel = anchorTarget and displayOptions.unitGlow and anchorTarget:GetFrameLevel() + GLOW_FRAME_LEVEL_STEP + 3
    or parentFrame:GetFrameLevel() + 1
  if HasChanged(auraContainer:GetFrameLevel(), frameLevel) then auraContainer:SetFrameLevel(frameLevel) end
  if not attachMode then
    auraContainer:ClearAllPoints()
    auraContainer:SetPoint(auraData.selfPoint or "CENTER", anchorTarget or auraRegion, auraData.anchorPoint or "CENTER",
      auraData.xOffset or 0, auraData.yOffset or 0)
  end
end

local function AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
  auraContainer:ClearAllPoints()
  if auraData.anchorFrameType == "NAMEPLATE" then
    auraContainer:SetPoint(auraData.selfPoint or "BOTTOM", anchorTarget or auraRegion, auraData.anchorPoint or "TOP",
      auraData.xOffset or 0, auraData.yOffset or 0)
  else
    auraContainer:SetPoint("BOTTOM", anchorTarget or auraRegion, "TOP", displayOptions.nameplateX or 0, displayOptions.nameplateY or 8)
  end
end

local function AttachToList(displayState, position, auraContainer, auraRegion, auraData, growthDirection)
  local isVertical = GrowsVertically(growthDirection)
  local anchorRef = AnchorForGrowth(growthDirection)
  auraContainer:ClearAllPoints()
  if growthDirection == "CENTER_HORIZONTAL" or growthDirection == "CENTER_VERTICAL" then
    auraContainer:SetPoint("CENTER", auraRegion, "CENTER")
  elseif PackUnits(auraData) and position > 1 then
    local previousFrame = displayState.instances[position - 1].container
    local edgePoint = growthDirection == "LEFT" and "TOPLEFT" or growthDirection == "UP" and "TOPLEFT"
      or growthDirection == "DOWN" and "BOTTOMLEFT" or "TOPRIGHT"
    auraContainer:SetPoint(anchorRef, previousFrame, edgePoint,
      isVertical and 0 or (growthDirection == "LEFT" and 1 or -1),
      isVertical and (growthDirection == "UP" and -1 or 1) or 0)
  else
    Display.AnchorToContent(auraContainer, anchorRef, auraRegion, anchorRef)
  end
end

local function UpdateUnitGlow(displayInstance, displayState, auraRegion, displayOptions, unitId, unitFrameMap, anchorTarget)
  local glowHolder = displayInstance.unitGlow.container
  local targetFrame = unitFrameMap and unitId and displayOptions.unitGlow and anchorTarget
  if targetFrame and targetFrame:IsForbidden() then targetFrame = nil end
  local isShown = not InPreview() and targetFrame ~= nil and targetFrame ~= false and auraRegion:IsShown()
    and not displayState.unitGlowsHidden and displayOptions.unitGlow == true
  local glowHost = targetFrame or auraRegion
  AttachContainer(displayInstance.unitGlow, glowHolder, unitId, glowHost)
  glowHolder:ClearAllPoints()
  if targetFrame then
    PlaceUnitGlow(glowHolder, targetFrame)
  else
    glowHolder:SetAllPoints(glowHost)
  end
  if HasChanged(glowHolder:GetFrameStrata(), glowHost:GetFrameStrata()) then
    glowHolder:SetFrameStrata(glowHost:GetFrameStrata())
  end
  local glowFrameLevel = glowHost:GetFrameLevel() + GLOW_FRAME_LEVEL_STEP
  if HasChanged(glowHolder:GetFrameLevel(), glowFrameLevel) then glowHolder:SetFrameLevel(glowFrameLevel) end
  glowHolder:SetShown(isShown)
  glowHolder:SetEnabled(isShown)
  if isShown then glowHolder:UpdateAllAuras() end
end

local function UpdateInstance(auraRegion, displayState, position, displayInstance, unitSet, growthDirection, attachMode, droppedUnit)
  local auraData = displayState.data
  local displayOptions = auraData.blizzardAuraDisplay
  local auraContainer = displayInstance.container
  local unitId = unitSet[position]
  local unitFrameMap, plateMap = AttachModes(auraData, attachMode)
  local anchorTarget = LocateAnchor(unitId, unitFrameMap, plateMap, droppedUnit)
  local isShown = not InPreview() and unitId ~= nil and auraRegion:IsShown()
    and (not (unitFrameMap or plateMap) or anchorTarget ~= nil)
  local parentFrame = unitFrameMap and auraData.anchorFrameParent ~= false and anchorTarget or auraRegion
  AttachContainer(displayInstance, auraContainer, unitId, parentFrame)
  auraContainer:SetAlpha(parentFrame == auraRegion and 1 or auraData.alpha or 1)
  local strataName = (auraData.frameStrata == nil or auraData.frameStrata == 1) and parentFrame:GetFrameStrata() or auraRegion:GetFrameStrata()
  if HasChanged(auraContainer:GetFrameStrata(), strataName) then auraContainer:SetFrameStrata(strataName) end
  if unitFrameMap then
    AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  elseif not attachMode then
    if plateMap then
      AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
    else
      AttachToList(displayState, position, auraContainer, auraRegion, auraData, growthDirection)
    end
  end
  displayInstance.visible = isShown
  auraContainer:SetShown(isShown)
  auraContainer:SetEnabled(isShown)
  if isShown then auraContainer:UpdateAllAuras() end
  Display.RefreshSingle(displayInstance, unitId, isShown)
  Display.RefreshFlowShadow(displayInstance, unitId, isShown)
  if displayInstance.unitGlow then
    UpdateUnitGlow(displayInstance, displayState, auraRegion, displayOptions, unitId, unitFrameMap, anchorTarget)
  end
end

local function UpdateUnits(auraRegion, droppedUnit, updatedUnit)
  local displayState = auraRegion.blizzardAuraDisplay
  if not displayState or not displayState.active then return end
  if displayState.instanceQueue and not InPreview() and Display.FlushInstanceQueue then
    Display.FlushInstanceQueue(auraRegion)
  end
  local auraData = displayState.data
  local triggerConfig = Display.GetTrigger(auraData)
  if not triggerConfig then return end
  local unitSet = ExpandUnits(triggerConfig)
  local growthDirection = Display.Growth(auraData)
  local attachMode = Display.FlowFrameMode(auraData)
  for position, displayInstance in ipairs(displayState.instances) do
    if not updatedUnit or unitSet[position] == updatedUnit then
      UpdateInstance(auraRegion, displayState, position, displayInstance, unitSet, growthDirection, attachMode, droppedUnit)
    end
  end
  if attachMode then Display.RelinkFlowUnits(Display.FlowGroup(auraData)) end
  Display.UpdateDetachedFrameLevels(auraRegion)
  UpdatePreview(auraRegion)
end

local function UsesUnitFrames(auraData)
  return auraData.anchorFrameType == "UNITFRAME" or Display.FlowFrameMode(auraData) == "UNITFRAME"
end

local unitRefreshQueued
function Display.UnitFramesChanged()
  if unitRefreshQueued then return end
  local isNeeded
  for auraRegion in pairs(liveRegions) do
    if UsesUnitFrames(auraRegion.blizzardAuraDisplay.data) then
      isNeeded = true
      break
    end
  end
  if not isNeeded then return end
  unitRefreshQueued = true
  C_Timer.After(0, function()
    unitRefreshQueued = nil
    for auraRegion in pairs(liveRegions) do
      if UsesUnitFrames(auraRegion.blizzardAuraDisplay.data) then UpdateUnits(auraRegion) end
    end
  end)
end

local function GroupLayoutWarning(auraData)
  local isGrouped = Display.Enabled(auraData) and Display.InDynamicGroup(auraData)
  Internal.AuraWarnings.UpdateWarning(auraData.uid, "blizzard_aura_dynamicgroup", isGrouped and "warning" or nil,
    isGrouped and Display.dynamicGroupWarning or nil)
end

local function RunInstance(auraRegion, auraData, position, displayInstance)
  displayInstance.data = auraData
  displayInstance.container:SetEnabled(false)
  for _, auraButton in ipairs(displayInstance.buttons) do ApplyNativeStyle(auraButton, auraData, auraRegion) end
  ApplyLayout(displayInstance, auraRegion, auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  SetupProcessing(displayInstance.container, triggerConfig)
  displayInstance.container:SetAuraGroupSortMethod("Auras", Display.SortOrder(auraData, triggerConfig))
  displayInstance.container:SetAuraGroupFilterString("Auras", JoinFilters(triggerConfig))
  displayInstance.container:SetAuraGroupCandidateFilters("Auras", FilterCandidates(auraData))
  SetupUnitGlow(displayInstance, auraRegion, auraData)
  Display.ConfigureSingle(displayInstance, auraRegion, auraData, position)
end

local queuedInstances = {}
local isDrainingInstances = false

local function QueueInstanceDrain(drainNow)
  if isDrainingInstances then return end
  isDrainingInstances = true
  C_Timer.After(0, drainNow)
end

local function FlushInstances()
  isDrainingInstances = false
  local hasMore = false
  for auraRegion in pairs(queuedInstances) do
    local displayState = auraRegion.blizzardAuraDisplay
    local pendingQueue = displayState and displayState.instanceQueue
    if not pendingQueue or not displayState.active or displayState.data ~= pendingQueue.data then
      queuedInstances[auraRegion] = nil
    elseif IsRestricted() then
      displayState.instanceQueue, queuedInstances[auraRegion] = nil, nil
      queuedApplies[auraRegion] = pendingQueue.data
    else
      local lastEntry = math.min(pendingQueue.nextIndex + EDITOR_BATCH_SIZE - 1, #displayState.instances)
      for position = pendingQueue.nextIndex, lastEntry do
        RunInstance(auraRegion, pendingQueue.data, position, displayState.instances[position])
      end
      pendingQueue.nextIndex = lastEntry + 1
      if pendingQueue.nextIndex > #displayState.instances then
        displayState.instanceQueue, queuedInstances[auraRegion] = nil, nil
        UpdateUnits(auraRegion)
      else
        hasMore = true
      end
    end
  end
  if hasMore then QueueInstanceDrain(FlushInstances) end
end

function Display.FlushInstanceQueue(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  local pendingQueue = displayState and displayState.instanceQueue
  if not pendingQueue then return end
  displayState.instanceQueue, queuedInstances[auraRegion] = nil, nil
  if IsRestricted() then
    queuedApplies[auraRegion] = pendingQueue.data
    return
  end
  if displayState.data ~= pendingQueue.data then return end
  for position = pendingQueue.nextIndex, #displayState.instances do
    RunInstance(auraRegion, pendingQueue.data, position, displayState.instances[position])
  end
end

local function MakeDisplayState(auraRegion, auraData)
  local displayState = {instances = {}, data = auraData}
  auraRegion.blizzardAuraDisplay = displayState
  auraRegion:HookScript("OnHide", function()
    Display.HideUnitGlows(auraRegion)
    for _, displayInstance in ipairs(displayState.instances) do
      displayInstance.container:SetEnabled(false)
      displayInstance.container:Hide()
      Display.RefreshSingle(displayInstance, nil, false)
    end
    UpdateSounds(auraRegion)
  end)
  auraRegion:HookScript("OnShow", function()
    displayState.unitGlowsHidden = false
    if displayState.active then
      UpdateUnits(auraRegion)
      UpdateSounds(auraRegion)
    end
  end)
  return displayState
end

local function DropInstances(displayState)
  for _, displayInstance in ipairs(displayState.instances) do
    displayInstance.container:SetEnabled(false)
    displayInstance.container:Hide()
    Display.RefreshSingle(displayInstance, nil, false)
    if displayInstance.single and displayInstance.single.missing then displayInstance.single.missing.active = false end
    Display.RetireFrame(displayInstance.container)
    if displayInstance.flowShadow then Display.RetireFrame(displayInstance.flowShadow) end
    if displayInstance.unitGlow then Display.RetireFrame(displayInstance.unitGlow.container) end
  end
  displayState.instances = {}
end

function Display.Apply(auraRegion, auraData)
  GroupLayoutWarning(auraData)
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion)
    PostWarning(auraData)
    PostSoundWarning(auraData)
    return
  end
  HideRegionParts(auraRegion)
  local issue = Display.Validate(auraData)
  if issue then
    Display.Release(auraRegion)
    PostWarning(auraData, issue)
    return
  end
  if InPreview() then
    Display.ShowPreview(auraRegion, auraData, ApplySampleStyle)
    Display.ArrangeFlowPreview(Display.FlowGroup(auraData))
    HideRegionParts(auraRegion)
  else
    Display.HidePreview(auraRegion)
    Display.RestorePreviewRegion(auraRegion)
    Display.RestoreGroupPreview(Display.FlowGroup(auraData))
  end
  if IsRestricted() then
    queuedApplies[auraRegion] = auraData
    PostWarning(auraData, "Display > Secret Aura Settings changes will apply when aura restrictions end.")
    return
  end
  if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
    local isLoaded, cause = C_AddOns.LoadAddOn("Blizzard_AuraContainer")
    if not isLoaded then
      PostWarning(auraData, "Cannot load Blizzard_AuraContainer: " .. tostring(cause))
      return
    end
  end
  local displayState = auraRegion.blizzardAuraDisplay or MakeDisplayState(auraRegion, auraData)
  displayState.data = auraData
  Display.EnsureFlowStart(auraRegion, auraData)
  displayState.previewStyled = InPreview() and auraData or nil
  if InPreview() then RefreshPreviewNotice(auraRegion) end
  displayState.unitGlowsHidden = false
  local needsFlow = Display.FlowGroup(auraData) ~= nil
  if displayState.instances[1] and displayState.instances[1].flowContainer ~= needsFlow then DropInstances(displayState) end
  for position = 1, SlotCount(Display.GetTrigger(auraData)) do
    if not displayState.instances[position] then displayState.instances[position] = MakeInstance(auraRegion, auraData) end
  end
  Display.ClearSingleWarning(auraData)
  displayState.instanceQueue, queuedInstances[auraRegion] = nil, nil
  local runNow = #displayState.instances
  if InPreview() and runNow > EDITOR_FIRST_BATCH then
    runNow = EDITOR_FIRST_BATCH
    displayState.instanceQueue = {data = auraData, nextIndex = runNow + 1}
    queuedInstances[auraRegion] = true
  end
  for position = 1, runNow do RunInstance(auraRegion, auraData, position, displayState.instances[position]) end
  displayState.active = true
  displayState.appliedTrigger = Display.GetSavedTrigger(auraData)
  liveRegions[auraRegion] = true
  local singleConfig = displayState.instances[1] and displayState.instances[1].single
  Display.EnsureFlowShadows(auraRegion, auraData)
  Display.SetFlowEnd(auraRegion, auraData,
    singleConfig and singleConfig.missing and singleConfig.missing.active and singleConfig.missing.presenceActive and singleConfig.missing.presence)
  Display.RechainFlow(Display.FlowGroup(auraData))
  UpdateUnits(auraRegion)
  queuedApplies[auraRegion] = nil
  UpdateSounds(auraRegion)
  PostWarning(auraData)
  if displayState.instanceQueue then QueueInstanceDrain(FlushInstances) end
end

local function SetupHooks(auraRegion)
  if not auraRegion.blizzardOriginalUpdate then
    local originalValue = auraRegion.Update
    auraRegion.blizzardOriginalUpdate = {func = originalValue}
    auraRegion.Update = function(self, ...)
      if originalValue then originalValue(self, ...) end
      HideRegionParts(self)
      if Display.UpdateMissingSource then Display.UpdateMissingSource(self) end
    end
  end
  if not auraRegion.blizzardOriginalPreShow then
    auraRegion.blizzardOriginalPreShow = {func = auraRegion.PreShow}
    auraRegion.PreShow = function(self) HideRegionParts(self) end
  end
  HideRegionParts(auraRegion)
end

function Display.Activate(auraRegion, auraData)
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion)
    return
  end
  SetupHooks(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  if not (displayState and displayState.data == auraData and not queuedApplies[auraRegion] and Display.Validate(auraData) == nil) then
    Display.Apply(auraRegion, auraData)
    return
  end
  Display.FlushInstanceQueue(auraRegion)
  local triggerConfig = Display.GetTrigger(auraData)
  Display.WatchAuraLearning(auraRegion, auraData, triggerConfig, Display.LateGlowSpec(auraData, triggerConfig))
  displayState.unitGlowsHidden = false
  displayState.active = true
  liveRegions[auraRegion] = true
  Display.RechainFlow(Display.FlowGroup(auraData))
  UpdateUnits(auraRegion)
  UpdateSounds(auraRegion)
end

local function ProgressKey(auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  local fieldKey = triggerConfig and (auraData.progressSource and auraData.progressSource[1] or -1) or 0
  if fieldKey < 0 then
    local modeName = auraData.triggers.activeTriggerMode
    fieldKey = (modeName and modeName > 0 and modeName) or (Internal.GetActiveTriggerFor and Internal.GetActiveTriggerFor(auraData.id)) or 1
  end
  return fieldKey
end

function Display.SyncProgressSource(auraRegion, auraData)
  if not auraData then return end
  local fieldKey = ProgressKey(auraData)
  if auraRegion.secretAuraProgressSourceIndex == fieldKey then return end
  local displayState = auraRegion.blizzardAuraDisplay
  if displayState and displayState.data == auraData and displayState.appliedTrigger
    and displayState.appliedTrigger == Display.GetSavedTrigger(auraData) then
    auraRegion.secretAuraProgressSourceIndex = fieldKey
    if not displayState.active then Display.Activate(auraRegion, auraData) end
    return
  end
  Display.Modify(auraRegion, auraData)
end

local editorPending = {}
local isDrainingEditor = false

local function FlushEditor()
  local isWaiting = {}
  for auraRegion in pairs(editorPending) do isWaiting[#isWaiting + 1] = auraRegion end
  local wasApplied = 0
  for _, auraRegion in ipairs(isWaiting) do
    if wasApplied >= EDITOR_APPLY_BATCH then break end
    local auraData = editorPending[auraRegion]
    editorPending[auraRegion] = nil
    local listEntry = Internal.regions[auraData.id]
    if listEntry and listEntry.region == auraRegion and (WeakAuras.GetData(auraData.id) or auraData) == auraData
      and Display.Enabled(auraData) then
      Display.Apply(auraRegion, auraData)
      wasApplied = wasApplied + 1
    end
  end
  if next(editorPending) then
    C_Timer.After(0, FlushEditor)
  else
    isDrainingEditor = false
  end
end

function Display.CancelEditorApply(auraRegion)
  editorPending[auraRegion] = nil
end

function Display.Modify(auraRegion, auraData)
  auraRegion.secretAuraProgressSourceIndex = ProgressKey(auraData)
  auraRegion.secretAuraConditionValues = nil
  if not Display.Enabled(auraData) then
    Display.Release(auraRegion)
    PostWarning(auraData)
    PostSoundWarning(auraData)
    return
  end
  SetupHooks(auraRegion)
  local displayState = auraRegion.blizzardAuraDisplay
  if WeakAuras.IsOptionsOpen() and displayState and displayState.active and displayState.data == auraData and not IsRestricted() then
    editorPending[auraRegion] = auraData
    if not isDrainingEditor then
      isDrainingEditor = true
      C_Timer.After(0, FlushEditor)
    end
    return
  end
  editorPending[auraRegion] = nil
  Display.Apply(auraRegion, auraData)
end

local UNIT_EVENT_ATTACH = {
  GROUP_ROSTER_UPDATE = {group = true, party = true, raid = true, member = true},
  PLAYER_ROLES_ASSIGNED = {group = true, party = true, raid = true},
  PLAYER_TARGET_CHANGED = {target = true, targettarget = true},
  PLAYER_FOCUS_CHANGED = {focus = true, focustarget = true},
  UPDATE_MOUSEOVER_UNIT = {mouseover = true},
  INSTANCE_ENCOUNTER_ENGAGE_UNIT = {boss = true, member = true},
  ARENA_OPPONENT_UPDATE = {arena = true, member = true},
  UNIT_NAME_UPDATE = {group = true, party = true, raid = true},
  PLAYER_REGEN_ENABLED = {},
  ADDON_RESTRICTION_STATE_CHANGED = {},
}

local LISTENED_EVENTS = {
  "PLAYER_REGEN_ENABLED", "ADDON_RESTRICTION_STATE_CHANGED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
  "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED",
  "UPDATE_MOUSEOVER_UNIT", "UNIT_TARGET", "UNIT_PET", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "ARENA_OPPONENT_UPDATE",
  "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "UNIT_NAME_UPDATE", "PLAYER_ROLES_ASSIGNED",
}

local function WantsUnitUpdate(modeName, eventName, unitId, includePets)
  if eventName == "UNIT_TARGET" then
    return (modeName == "targettarget" and unitId == "target") or (modeName == "focustarget" and unitId == "focus")
  elseif eventName == "UNIT_PET" then
    return (modeName == "pet" and unitId == "player") or modeName == "member"
      or (includePets and PET_GROUP_UNITS[modeName] == true)
  end
  local modeSet = UNIT_EVENT_ATTACH[eventName]
  return modeSet == nil or modeSet[modeName] == true
end

local isDrainingApplies = false

local function FlushApplies()
  if IsRestricted() then
    isDrainingApplies = false
    return
  end
  local wasApplied = 0
  for auraRegion, auraData in pairs(queuedApplies) do
    queuedApplies[auraRegion] = nil
    if WeakAuras.GetData(auraData.id) == auraData and Internal.regions[auraData.id] and Internal.regions[auraData.id].region == auraRegion then
      Display.Apply(auraRegion, auraData)
      wasApplied = wasApplied + 1
      if wasApplied >= APPLY_BATCH_SIZE then break end
    end
  end
  if next(queuedApplies) then
    C_Timer.After(0, FlushApplies)
  else
    isDrainingApplies = false
  end
end

local function OnNameplateEvent(auraRegion, modeName, eventName, unitId)
  if not Display.UsesNameplates(auraRegion.blizzardAuraDisplay.data) then return end
  if modeName == "nameplate" then
    UpdateUnits(auraRegion, eventName == "NAME_PLATE_UNIT_REMOVED" and unitId or nil, unitId)
  else
    UpdateUnits(auraRegion)
  end
end

local function OnRegionEvent(auraRegion, eventName, unitId)
  local triggerConfig = Display.GetTrigger(auraRegion.blizzardAuraDisplay.data)
  local modeName = triggerConfig and triggerConfig.unit
  if eventName == "NAME_PLATE_UNIT_ADDED" or eventName == "NAME_PLATE_UNIT_REMOVED" then
    OnNameplateEvent(auraRegion, modeName, eventName, unitId)
  elseif not (queuedApplies[auraRegion] and not IsRestricted()) and WantsUnitUpdate(modeName, eventName, unitId, triggerConfig and triggerConfig.use_includePets) then
    UpdateUnits(auraRegion)
  end
  if triggerConfig and (eventName == "GROUP_ROSTER_UPDATE" or eventName == "PLAYER_ROLES_ASSIGNED"
    or (eventName == "UNIT_NAME_UPDATE" and triggerConfig.useUnitNames)
    or (eventName == "UNIT_PET" and triggerConfig.use_includePets)) and UNIT_EVENT_ATTACH.GROUP_ROSTER_UPDATE[modeName] then
    UpdateSounds(auraRegion)
  end
end

local listenerFrame = CreateFrame("Frame")
for _, eventName in ipairs(LISTENED_EVENTS) do listenerFrame:RegisterEvent(eventName) end

listenerFrame:SetScript("OnEvent", function(_, eventName, unitId)
  if eventName == "UI_SCALE_CHANGED" or eventName == "DISPLAY_SIZE_CHANGED" then
    for auraRegion in pairs(liveRegions) do Display.Apply(auraRegion, auraRegion.blizzardAuraDisplay.data) end
    return
  end
  Display.BeginFlowBatch()
  for auraRegion in pairs(liveRegions) do OnRegionEvent(auraRegion, eventName, unitId) end
  Display.EndFlowBatch()
  if IsRestricted() then return end
  if eventName == "PLAYER_REGEN_ENABLED" or eventName == "ADDON_RESTRICTION_STATE_CHANGED" or eventName == "PLAYER_ENTERING_WORLD" then
    for auraRegion in pairs(liveRegions) do Display.RefreshConditionAppearance(auraRegion) end
  end
  for auraRegion in pairs(queuedSoundSyncs) do UpdateSounds(auraRegion) end
  if next(queuedApplies) and not isDrainingApplies then
    isDrainingApplies = true
    FlushApplies()
  end
end)

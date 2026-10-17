-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Internal = ...

local Display = {}
Internal.BlizzardAuraDisplay = Display
local Anchor = Internal.AuraAnchor

local function ParsePairs(text)
  local keys, captions = {}, {}
  for key, caption in text:gmatch("(%w*)=([^;]+);") do
    keys[#keys + 1] = key
    captions[key] = caption
  end
  return keys, captions
end

local function CatalogRows(order, details)
  local rows = {}
  for position, key in ipairs(order) do
    local detail = details[key]
    rows[position] = { key, detail.caption, detail.tooltip }
  end
  return rows
end

local _, unitCaptions = ParsePairs("player=Player;target=Target;focus=Focus;pet=Pet;mouseover=Mouseover;"
  .. "targettarget=Target of Target;focustarget=Target of Focus;group=Smart Group;party=Party;raid=Raid;"
  .. "boss=Boss;arena=Arena;nameplate=Nameplate;member=Specific Unit;")
Display.units = unitCaptions

Display.booleanFilters = CatalogRows({
  "isFromPlayerOrPlayerPet", "canApplyAura", "isStealable", "isBossAura", "isRoleAura",
  "isBossOrRoleAura", "isPriorityAura", "nameplateShowAll", "nameplateShowPersonal",
}, {
  isFromPlayerOrPlayerPet = {
    caption = "Cast by a Player",
    tooltip = "Auras cast by any player or player pet, not only yours. For your own auras, use Own Only.",
  },
  canApplyAura = {
    caption = "Can Apply Aura",
    tooltip = "Auras Blizzard says your character can apply.",
  },
  isStealable = {
    caption = "Is Stealable",
    tooltip = "Buffs that can be stolen with abilities such as Spellsteal.",
  },
  isBossAura = {
    caption = "Is Boss Aura",
    tooltip = "Auras Blizzard identifies as boss auras.",
  },
  isRoleAura = {
    caption = "Role aura",
    tooltip = "Auras Blizzard marks as relevant to your role.",
  },
  isBossOrRoleAura = {
    caption = "Boss or role aura",
    tooltip = "Auras Blizzard identifies as boss auras or marks as relevant to your role.",
  },
  isPriorityAura = {
    caption = "Priority debuff",
    tooltip = "Debuffs Blizzard marks as high priority.",
  },
  nameplateShowAll = {
    caption = "Marked for all nameplates",
    tooltip = "Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. "
      .. "It does not change where the icon appears or who cast the aura.",
  },
  nameplateShowPersonal = {
    caption = "Marked for personal debuff display",
    tooltip = "Only match auras marked for Blizzard's personal-debuff display on nameplates. "
      .. "This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. "
      .. "It does not change where the icon appears or who cast the aura.",
  },
})

Display.nativeFilters = CatalogRows({
  "PLAYER", "RAID", "CANCELABLE", "EXTERNAL_DEFENSIVE", "CROWD_CONTROL",
  "RAID_IN_COMBAT", "RAID_PLAYER_DISPELLABLE", "BIG_DEFENSIVE", "IMPORTANT", "DISPELLABLE",
}, {
  PLAYER = { caption = "Own Only", tooltip = "Auras cast by you, your pet or your vehicle." },
  RAID = { caption = "Can apply / dispel", tooltip = "Buffs you can apply, or debuffs you can dispel." },
  CANCELABLE = { caption = "Cancelable", tooltip = "Auras that the player can cancel." },
  EXTERNAL_DEFENSIVE = {
    caption = "External defensive",
    tooltip = "Auras Blizzard classifies as external defensives.",
  },
  CROWD_CONTROL = {
    caption = "Crowd control",
    tooltip = "Auras with a crowd-control effect, such as a stun or fear.",
  },
  RAID_IN_COMBAT = {
    caption = "Shown on raid frames in combat",
    tooltip = "Auras flagged by Blizzard for raid-frame display in combat.",
  },
  RAID_PLAYER_DISPELLABLE = {
    caption = "Dispellable by someone in your raid",
    tooltip = "Includes helpful enrages on enemies.",
  },
  BIG_DEFENSIVE = { caption = "Big defensive", tooltip = "Auras Blizzard classifies as big defensives." },
  IMPORTANT = {
    caption = "Important aura",
    tooltip = "Blizzard's important-aura flag, including non-stealable enemy buffs shown on nameplates.",
  },
  DISPELLABLE = {
    caption = "Dispellable",
    tooltip = "Dispellable regardless of your or your raid's current abilities.",
  },
})

local _, dispelCaptions = ParsePairs("Magic=Magic;Curse=Curse;Disease=Disease;Poison=Poison;Bleed=Bleed;=Enrage;")
Display.dispelTypes = dispelCaptions

local _, sortCaptions = ParsePairs("Name=Name (Blizzard priority);NameOnly=Name;Default=Blizzard default;"
  .. "AuraInstanceIDOnly=Aura instance ID;BigDefensive=Big defensives;UnitFrameDebuff=Unit-frame debuffs;"
  .. "ImportantOnly=Importance only;Expiration=Remaining time (Blizzard priority);ExpirationOnly=Remaining time;")
Display.sortMethods = sortCaptions

local _, classificationCaptions = ParsePairs("any=Any (no classification);Buff=Buff;Debuff=Debuff;"
  .. "Dispel=Dispellable raid debuff;")
Display.processedTypes = classificationCaptions

local flagOrder, flagCaptions = ParsePairs("displayOnlyDispellableDebuffs=Use dispellable-debuff classification;"
  .. "ignoreBuffs=Ignore buff classification;ignoreDebuffs=Ignore debuff classification;"
  .. "ignoreDispelDebuffs=Ignore dispel classification;")
local classificationFlags = {}
for position, key in ipairs(flagOrder) do classificationFlags[position] = { key, flagCaptions[key] } end
Display.processingOptions = classificationFlags

Display.dynamicGroupWarning = "Aura (Modern) in a Dynamic Group: It keeps its position even when no aura is shown. Use a Modern Aura Group with other Modern Aura triggers to keep dynamic behaviour."

local nativeFilterKeys = {}
for _, row in ipairs(Display.nativeFilters) do nativeFilterKeys[row[1]] = true end

local function InPreview()
  if InCombatLockdown() then return false end
  return WeakAuras.IsOptionsOpen()
end

local function Listed(value)
  return type(value) == "table" and value or {}
end

local function Join(list)
  local pieces = {}
  for index, value in ipairs(list) do pieces[index] = tostring(value) end
  return table.concat(pieces, ",")
end

local function TriggerEntries(data)
  return data and type(data.triggers) == "table" and data.triggers or {}
end

local function IsSecretAuraTrigger(entry)
  return type(entry) == "table" and type(entry.trigger) == "table" and entry.trigger.type == "secretAura"
end

local UNIT_RULES = {
  { "^party[1-4]$", "party" },
  { "^partypet[1-4]$", "party" },
  { "^raid(%d+)$", "raid", 40 },
  { "^raidpet(%d+)$", "raid", 40 },
  { "^boss[1-8]$", "boss" },
  { "^arena[1-5]$", "arena" },
}

Display.SpecificUnit = function(trigger)
  if type(trigger) ~= "table" or type(trigger.specificUnit) ~= "string" then return end
  local word = trigger.specificUnit:lower():match("^%s*(%S+)%s*$")
  if not word then return end
  for _, rule in ipairs(UNIT_RULES) do
    local found = word:match(rule[1])
    if found and (not rule[3] or (tonumber(found) >= 1 and tonumber(found) <= rule[3])) then
      return word, rule[2]
    end
  end
end

Display.UnitCategory = function(trigger)
  if type(trigger) ~= "table" then return nil end
  if trigger.unit ~= "member" then return trigger.unit end
  local _, category = Display.SpecificUnit(trigger)
  return category
end

local nameplateTokens = {}

local function GrowNameplateTokens(highestIndex)
  local wanted = (math.ceil(highestIndex / 10) + 1) * 10
  if wanted <= #nameplateTokens then return false end
  for index = #nameplateTokens + 1, wanted do nameplateTokens[index] = "nameplate" .. index end
  return true
end
GrowNameplateTokens(30)

local FIXED_SLOTS = { group = 40, raid = 40, party = 5, arena = 5, boss = 10 }
local PET_UNITS = { group = true, party = true, raid = true }

local function SlotCount(trigger)
  if not trigger or (Display.ShowOn and Display.ShowOn(trigger) ~= "showOnActive") then return 1 end
  local unit = trigger.unit
  local count = unit == "nameplate" and #nameplateTokens or FIXED_SLOTS[unit] or 1
  if trigger.use_includePets and trigger.includePets == "PlayersAndPets" and PET_UNITS[unit] then
    count = count * 2
  end
  return count
end

local function NumberedTokens(prefix, last)
  local tokens = {}
  for index = 1, last do tokens[index] = prefix .. index end
  return tokens
end

local function BaseTokens(trigger)
  local unit = trigger.unit
  if unit == "group" then
    if IsInRaid() then unit = "raid" else unit = "party" end
  end
  if unit == "boss" or unit == "arena" then
    return NumberedTokens(unit, SlotCount(trigger))
  end
  if unit == "nameplate" then
    local slots = SlotCount(trigger)
    return slots > 1 and nameplateTokens or NumberedTokens("nameplate", slots)
  end
  if unit == "party" then
    local tokens = NumberedTokens("party", GetNumSubgroupMembers())
    table.insert(tokens, 1, "player")
    return tokens
  end
  if unit == "raid" then
    return IsInRaid() and NumberedTokens("raid", GetNumGroupMembers()) or {}
  end
  return { unit }
end

local function PassesMemberFilters(trigger, token)
  if trigger.useUnitNames then
    local name = Internal.ExecEnv.UnitName(token)
    if issecretvalue(name) or type(name) ~= "string" then return false end
    local lowered, listed = name:lower(), false
    for _, wanted in ipairs(Listed(trigger.unitNames)) do
      if lowered == tostring(wanted):lower() then listed = true break end
    end
    if not listed then return false end
  end
  if trigger.useUnitRoles then
    local role = UnitGroupRolesAssigned(token)
    if issecretvalue(role) or not (trigger.unitRoles or {})[role] then return false end
  end
  return true
end

local function PetOf(token)
  local prefix, number = token:match("^(%a+)(%d+)$")
  if prefix == "party" or prefix == "raid" then return prefix .. "pet" .. number end
  return token == "player" and "pet" or nil
end

Display.UnitTokens = function(trigger)
  local isMember = trigger.unit == "member"
  if isMember then return { (Display.SpecificUnit(trigger)) } end
  local tokens = BaseTokens(trigger)
  if not PET_UNITS[trigger.unit] then return tokens end
  if trigger.useUnitNames or trigger.useUnitRoles then
    local kept = {}
    for _, token in ipairs(tokens) do
      if PassesMemberFilters(trigger, token) then kept[#kept + 1] = token end
    end
    tokens = kept
  end
  local petMode = trigger.use_includePets and trigger.includePets
  if petMode ~= "PlayersAndPets" and petMode ~= "PetsOnly" then return tokens end
  local withPets = {}
  for _, token in ipairs(tokens) do
    if petMode == "PlayersAndPets" then withPets[#withPets + 1] = token end
    local pet = PetOf(token)
    if pet and UnitExists(pet) then withPets[#withPets + 1] = pet end
  end
  return withPets
end

Display.GetPreviewUnit = function(data)
  local shown = Display.GetTrigger(data)
  if shown then
    local needsFrame = data.anchorFrameType == "UNITFRAME"
    for _, unit in ipairs(Display.UnitTokens(shown)) do
      if UnitExists(unit) and (not needsFrame or WeakAuras.GetUnitFrame(unit)) then return unit end
    end
  end
  return "player"
end

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
        for _, rankID in ipairs(Internal.GetAuraSpellRanks(id) or {}) do Take(rankID) end
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
      position = Internal.GetActiveTriggerFor and Internal.GetActiveTriggerFor(data.id) or 1
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

local SOUND_CHANNELS = { Master = true, SFX = true, Music = true, Ambience = true, Dialog = true }

local function PreferredSoundChannel()
  local settings = FojjiCore and FojjiCoreDB
  local channel = settings and settings.ttsSoundChannel
  channel = channel == "Sound Effects" and "SFX" or channel
  return SOUND_CHANNELS[channel] and channel or "Master"
end

local LEGACY_SOUND_FIELDS = { "soundMode", "soundAdded", "soundRemoved", "soundAddedFile", "soundRemovedFile" }
local LEGACY_SOUND_SLOTS = { { "Added", "start" }, { "Removed", "finish" } }

Display.MigrateSounds = function(data)
  local previous = data.blizzardAuraDisplay
  if previous.actionSounds then return end
  if not data.actions then data.actions = {} end
  local mode = previous.soundMode
  for _, slot in ipairs(LEGACY_SOUND_SLOTS) do
    local suffix, timing = slot[1], slot[2]
    local action = data.actions[timing]
    if not action then
      action = {}
      data.actions[timing] = action
    end
    local value = previous["sound" .. suffix]
    if mode == "file" then value = previous["sound" .. suffix .. "File"] or value end
    if not action.do_sound and mode and mode ~= "none" and value ~= nil and value ~= "" and value ~= 1 then
      action.do_sound = true
      action.sound_channel = PreferredSoundChannel()
      if mode == "fojji" then
        action.sound, action.sound_fojji = " Fojji", value
      else
        action.sound, action.sound_path = " custom", tostring(value)
      end
    end
  end
  for _, field in ipairs(LEGACY_SOUND_FIELDS) do previous[field] = nil end
  previous.actionSounds = true
end

Display.Migrate = function(data)
  local previous = data.blizzardAuraDisplay
  local entries = TriggerEntries(data)
  if previous and previous.enabled and #entries == 1 and type(entries[1].trigger) == "table"
    and entries[1].trigger.type == "aura2" then
    entries[1].trigger.type = "secretAura"
    previous.enabled = nil
  end
  local defaults = { unit = "player", debuffType = "HELPFUL" }
  for _, candidate in ipairs(entries) do
    if IsSecretAuraTrigger(candidate) then
      local saved = candidate.trigger
      for key, fallback in pairs(defaults) do
        if not saved[key] then saved[key] = fallback end
      end
      if not saved.auraspellids then saved.auraspellids = {} end
      saved.useExactSpellId = tonumber("1") == 1
      rawset(saved, "onlyMaw", nil)
      Display.MigrateSingle(data, saved)
      Display.MigrateTotal(saved)
      local display = data.blizzardAuraDisplay
      if not display then
        display = {}
        data.blizzardAuraDisplay = display
      end
      display.enabled = nil
    end
  end
  if not Display.HasTrigger(data) then return end
  Display.MigrateAppearance(data, previous)
  for _, subRegion in ipairs(data.subRegions or {}) do
    if subRegion.type == "subtext" then
      if subRegion.text_alpha == nil then subRegion.text_alpha = 1 end
      if subRegion.text_anchorXOffset == nil then subRegion.text_anchorXOffset = subRegion.anchorXOffset or 0 end
      if subRegion.text_anchorYOffset == nil then subRegion.text_anchorYOffset = subRegion.anchorYOffset or 0 end
    end
  end
  local migrateSounds = Display.MigrateSounds
  migrateSounds(data)
  for _, field in ipairs({ "soundSpellIDs", "soundIgnoreDisplayFilters" }) do
    data.blizzardAuraDisplay[field] = nil
  end
end

local function ResolveFojjiRecordedSound(phrase)
  if not (FojjiCore and FojjiCoreDB) then return nil, "The FojjiCore addon is not available." end
  if FojjiCoreDB.disableTTS then return nil, "FojjiCore has speech turned off." end
  if FojjiCoreDB.ttsVoiceType ~= "custom" or FojjiCoreDB.ttsRandomFavorites then
    return nil, "Pick a single recorded voice pack in FojjiCore. Recorded sounds work with neither synthesized speech nor random favorites."
  end
  local pack = FojjiCore.voicePacks and FojjiCore.voicePacks[FojjiCoreDB.ttsVoicePack]
  local file = pack and pack[phrase]
  if not file then
    return nil, "The selected FojjiCore voice pack has no recording named '" .. phrase .. "'."
  end
  return file
end

local function SoundFileOf(action)
  local kind, file, problem = action.sound, nil, nil
  if kind == " Fojji" then
    file, problem = ResolveFojjiRecordedSound(action.sound_fojji or "")
  elseif kind == " custom" then
    file = action.sound_path
    if tonumber(file) then file = tonumber(file) end
  elseif kind ~= " KitID" then
    file = kind
  end
  if file == nil or file == "" or file == 1 then
    return nil, problem or "Pick a sound file in the Actions tab."
  end
  return file
end

local SOUND_FIELDS = { "do_sound", "sound", "sound_path", "sound_fojji", "sound_channel" }
local SOUND_SLOTS = { { "start", "Added", "added" }, { "finish", "Removed", "removed" } }

local function ActionFingerprint(action)
  local pieces = {}
  for index, field in ipairs(SOUND_FIELDS) do pieces[index] = tostring(action[field]) end
  return table.concat(pieces, ",")
end

local function SoundFingerprint(trigger, actions)
  return table.concat({
    ActionFingerprint(actions.start or {}),
    ActionFingerprint(actions.finish or {}),
    Join(Display.UnitTokens(trigger)),
    Join(Display.GetSpellIDs(trigger, true)),
    Join(Listed(trigger.excludedAuraSpellIDs)),
  }, "|")
end

local function SoundSpellList(trigger)
  local blocked = {}
  local hasIgnored = Display.UsesExcludedSpellIDs(trigger)
  if hasIgnored then
    for _, value in ipairs(Listed(trigger.excludedAuraSpellIDs)) do
      local id = tonumber(value)
      if id then blocked[id] = true end
    end
  end
  local list = {}
  local every = Display.GetSpellIDs(trigger, true)
  for position = 1, #every do
    if not blocked[every[position]] then list[#list + 1] = every[position] end
  end
  table.sort(list)
  return list
end

local function PostSoundWarning(uid, text)
  if text then
    Internal.AuraWarnings.UpdateWarning(uid, "blizzard_aura_sound", "warning", text)
  else
    Internal.AuraWarnings.UpdateWarning(uid, "blizzard_aura_sound")
  end
end

local function SoundRegistrationAvailable()
  return C_UnitAuras and C_UnitAuras.AddAuraSound and C_UnitAuras.RemoveAuraSound
    and Enum.UnitAuraSoundTrigger
end

local queuedSoundSyncs = {}

local function UpdateSounds(region)
  if WeakAuras.IsRestricted() then
    queuedSoundSyncs[region] = true
    return
  end
  queuedSoundSyncs[region] = nil
  local state = region.blizzardAuraDisplay
  if not state then return end

  local data = state.data
  local current = Display.GetTrigger(data)
  local actions = data and data.actions or {}
  local live = current ~= nil and state.active and region:IsShown() and not InPreview()
  local fingerprint = live and SoundFingerprint(current, actions) or nil
  if fingerprint and fingerprint == state.soundSignature then return end
  state.soundSignature = fingerprint

  for _, soundID in ipairs(state.soundIDs or {}) do C_UnitAuras.RemoveAuraSound(soundID) end
  state.soundIDs = {}
  PostSoundWarning(data and data.uid)
  if not live then return end

  local startAction, finishAction = actions.start, actions.finish
  if not ((startAction and startAction.do_sound) or (finishAction and finishAction.do_sound)) then return end
  if not SoundRegistrationAvailable() then
    return PostSoundWarning(data and data.uid, "This client does not provide native aura sound registration.")
  end
  local spells = SoundSpellList(current)
  if #spells == 0 then
    return PostSoundWarning(data and data.uid, "Enable Spell ID(s) or Exact Spell ID(s) in Trigger and enter an ID that is not ignored to use aura sounds.")
  end

  local tokens, failure = Display.UnitTokens(current), nil
  for _, slot in ipairs(SOUND_SLOTS) do
    local action = actions[slot[1]]
    if action and action.do_sound then
      local file, problem = SoundFileOf(action)
      if not file then
        failure = problem
      else
        local kind = Enum.UnitAuraSoundTrigger[slot[2]]
        for _, token in ipairs(tokens) do
          for _, spellID in ipairs(spells) do
            local info = { unitToken = token, spellID = spellID, outputChannel = action.sound_channel or "Master" }
            if type(file) == "string" then info.soundFileName = file end
            if type(file) == "number" then info.soundFileID = file end
            local ok, soundID = pcall(C_UnitAuras.AddAuraSound, kind, info)
            if ok and soundID then
              state.soundIDs[#state.soundIDs + 1] = soundID
            else
              failure = "The client refused the " .. slot[3] .. " sound for spell " .. spellID .. "."
            end
          end
        end
      end
    end
  end
  PostSoundWarning(data and data.uid, failure)
end

local PREVIEW_NOTICE = "Preview only: spell ID filters hide these auras in combat.\nSounds configured in Actions can still play."

local function RefreshPreviewNotice(region)
  local state = region.blizzardAuraDisplay
  local trigger = Display.GetTrigger(state and state.data)
  local notice = region.secretAuraPreviewNotice
  local noteLevel = trigger and Display.SpellIDFilterNote(trigger)
  if noteLevel == "error" then
    if not notice then
      notice = region:CreateFontString(nil, "OVERLAY")
      notice:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
      notice:SetPoint("TOP", region, "BOTTOM", 0, -6)
      notice:SetWidth(300)
      notice:SetTextColor(1, 0.8, 0.2)
      region.secretAuraPreviewNotice = notice
    end
    notice:SetText(PREVIEW_NOTICE)
    notice:Show()
  elseif notice then
    notice:Hide()
  end
end

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
        return "Only Chat Message, Play Sound and Hide Glows can run in On Show/On Hide for a Secret Aura trigger. Custom Init is available."
      end
    end
    local usesSoundKit = action.do_sound and action.sound == " KitID"
    if usesSoundKit or action.stop_sound then
      return "Secret aura sounds accept sound files only, not Sound Kit IDs or Stop Sound."
    end
  end
  for _, animation in pairs(Listed(data.animation)) do
    if animation.type ~= nil and animation.type ~= "none" then
      return "Animations are not available on a Secret Aura trigger."
    end
  end
end

local VALIDATION_CHECKS = {
  MissingSpellLists, UnsupportedUnit, MalformedSpellIDs, MalformedFlags,
  BadDurationOrSort, BadNativeFilters, ReportedElsewhere, UnsupportedActionsOrAnimations,
}

Display.Validate = function(data)
  if not Display.Eligible(data) then return MESSAGE_NOT_ELIGIBLE end
  if data.regionType == "progresstexture" and Internal.ProgressTextureNative.IsCircular(data.orientation)
    and not Enum.StatusBarRenderMode then
    return "This client cannot draw native circular Progress Textures."
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

local Private = Internal
local SyncSounds = UpdateSounds

local function FlushPendingSounds()
  for auraRegion in pairs(queuedSoundSyncs) do UpdateSounds(auraRegion) end
end

Display.RetireFrame = Anchor.Retire
Display.LocateAnchor = Anchor.LocateAnchor
local lockedRegions = setmetatable({}, { __mode = "k" })

local function HasChanged(currentValue, isWanted)
  return issecretvalue(currentValue) or currentValue ~= isWanted
end

local function PackUnits(auraData)
  if Display.FlowGroup(auraData) and not Display.FlowFrameMode(auraData) then
    return SlotCount(Display.GetTrigger(auraData)) > 1
  end
  return auraData.anchorFrameType ~= "UNITFRAME" and not Display.UsesNameplates(auraData)
    and SlotCount(Display.GetTrigger(auraData)) > 1
end

local function LayoutInstance(displayInstance, auraRegion, auraData)
  local frameWidth, frameHeight = Display.Dimensions(auraData)
  local displayOptions = auraData.blizzardAuraDisplay
  local growth = Anchor.GrowthFor(Display.Growth(auraData))
  local drawn = growth.visible
  local isVertical = not drawn:IsHorizontal()
  local startPoint = drawn:StartPoint()
  local auraContainer = displayInstance.container
  auraContainer:ClearAllPoints()
  Anchor.Forget(auraContainer)
  if growth.centerPoint then
    auraContainer:SetPoint("CENTER", auraRegion, "CENTER")
  else
    Display.AnchorToContent(auraContainer, startPoint, auraRegion, startPoint)
  end
  auraContainer:SetFlowLayoutAxis(drawn:Axis())
  auraContainer:SetFlowLayoutAnchorPoint(startPoint)
  auraContainer:SetFlowLayoutGrowthDirection(drawn:Directions())
  local _, flowGap = Display.FlowGrowth(auraData)
  local gap = flowGap or displayOptions.spacing or 6
  local compactList = not growth.centerPoint and (PackUnits(auraData) or flowGap ~= nil)
  if Display.UsesGate(auraData) then gap = -(isVertical and frameHeight or frameWidth) end
  auraContainer:SetAuraGroupLayout("Auras", {
    elementWidth = frameWidth + (compactList and not isVertical and gap + 1 or 0),
    elementHeight = frameHeight + (compactList and isVertical and gap + 1 or 0),
    elementSpacing = compactList and -1 or gap,
  })
  auraContainer:SetAuraGroupMaxFrameCount("Auras", Display.MaxAuras(auraData))
end

local function AttachModes(auraData, attachMode)
  if Display.FlowGroup(auraData) then
    return attachMode == "UNITFRAME", attachMode == "NAMEPLATE"
  end
  local unitFrameMap = auraData.anchorFrameType == "UNITFRAME"
  return unitFrameMap, not unitFrameMap and Display.UsesNameplates(auraData)
end


local function Settle(auraContainer, isPlaced, ...)
  if isPlaced then Anchor.Remember(auraContainer, ...) else Anchor.Forget(auraContainer) end
end

local function AnchorContainer(auraContainer, point, relativeTo, relativePoint, x, y)
  if Anchor.Holds(auraContainer, point, relativeTo, relativePoint, x, y) then return end
  local status = Anchor.Attach(auraContainer, point, relativeTo, relativePoint, x, y)
  if status ~= "locked" then Settle(auraContainer, status == "ok", point, relativeTo, relativePoint, x, y) end
end

local function AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  local frameLevel = anchorTarget and displayOptions.unitGlow and anchorTarget:GetFrameLevel() + GLOW_FRAME_LEVEL_STEP + 3
    or parentFrame:GetFrameLevel() + 1
  if HasChanged(auraContainer:GetFrameLevel(), frameLevel) then auraContainer:SetFrameLevel(frameLevel) end
  if not attachMode then
    local point, relativePoint, x, y = Anchor.GroupPosition(auraData)
    AnchorContainer(auraContainer, point, anchorTarget or auraRegion, relativePoint, x, y)
  end
end

local function AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
  local point, relativePoint, x, y = "BOTTOM", "TOP", displayOptions.nameplateX or 0, displayOptions.nameplateY or 8
  if auraData.anchorFrameType == "NAMEPLATE" then
    point, relativePoint, x, y = Anchor.GroupPosition(auraData, "BOTTOM", "TOP")
  end
  AnchorContainer(auraContainer, point, anchorTarget or auraRegion, relativePoint, x, y)
end

local function AttachToList(displayState, position, auraContainer, auraRegion, auraData, growthDirection)
  local growth = Anchor.GrowthFor(growthDirection)
  local start = growth.visible:StartPoint()
  local point, relativeTo, relativePoint, x, y = start, Display.ContentAnchor(auraRegion), start, 0, 0
  local followsContent = true
  if growth.centerPoint then
    point, relativeTo, relativePoint, followsContent = "CENTER", auraRegion, "CENTER", false
  elseif PackUnits(auraData) and position > 1 then
    relativeTo = displayState.instances[position - 1].container
    relativePoint = growth:FrontPoint()
    x, y = growth:Overlap()
    followsContent = false
  end
  if Anchor.Holds(auraContainer, point, relativeTo, relativePoint, x, y) then return end
  local isPlaced
  if followsContent then
    isPlaced = Display.AnchorToContent(auraContainer, start, auraRegion, start)
  else
    isPlaced = Anchor.Attach(auraContainer, point, relativeTo, relativePoint, x, y) == "ok"
  end
  Settle(auraContainer, isPlaced, point, relativeTo, relativePoint, x, y)
end

local function PlaceInstance(auraRegion, displayInstance, auraData, position, parentFrame, anchorTarget, unitFrameMap, plateMap, growthDirection)
  local auraContainer = displayInstance.container
  local displayOptions = auraData.blizzardAuraDisplay
  local attachMode = Display.FlowFrameMode(auraData)
  local strataName = (auraData.frameStrata == nil or auraData.frameStrata == 1) and parentFrame:GetFrameStrata() or auraRegion:GetFrameStrata()
  if HasChanged(auraContainer:GetFrameStrata(), strataName) then auraContainer:SetFrameStrata(strataName) end
  if unitFrameMap then
    AttachToUnitFrame(auraContainer, auraRegion, auraData, displayOptions, anchorTarget, parentFrame, attachMode)
  elseif not attachMode then
    if plateMap then
      AttachToNameplate(auraContainer, auraRegion, auraData, displayOptions, anchorTarget)
    else
      AttachToList(auraRegion.blizzardAuraDisplay, position, auraContainer, auraRegion, auraData, growthDirection)
    end
  end
end

do

  local AURA_GROUP = "Auras"
  local GLOW_SLOT = "UnitGlow"
  local APPLY_BUDGET_MS = 8
  local LOGIN_POLL_SECONDS = 0.2
  local EDITOR_FIRST_BATCH = 2
  local EDITOR_BATCH_SIZE = 4
  local EDITOR_APPLY_BATCH = 2
  local GLOW_MARGIN_RATIO = 0.2
  local DEFAULT_GLOW_COLOR = { 1, 0.82, 0, 1 }
  local PENDING_TEXT = "Display > Secret Aura Settings changes will apply when aura restrictions end."
  local FALLBACK_FONT = "Fonts\\ARIALN.TTF"
  local HIDDEN_FIELDS = { "icon", "cooldown", "button", "bar", "secretBar", "text", "background" }
  local GROUP_UNITS = { group = true, party = true, raid = true }
  local SOUND_UNITS = { group = true, party = true, raid = true, member = true }

  local Parts, Buttons, Glow, Instances, Units, Queues, Plates, Events = {}, {}, {}, {}, {}, {}, {}, {}
  local liveRegions = {}
  local queuedApplies = setmetatable({}, { __mode = "k" })

  local function Warn(auraData, name, text)
    if text then
      Private.AuraWarnings.UpdateWarning(auraData.uid, name, "warning", text)
    else
      Private.AuraWarnings.UpdateWarning(auraData.uid, name)
    end
  end

  local function ReadLevel(frame)
    local level = frame:GetFrameLevel()
    if issecretvalue(level) then return nil end
    return level
  end

  local function PendingSet(set)
    local list = {}
    for key in pairs(set) do list[#list + 1] = key end
    return list
  end

  local runRegion, runData
  local function RunApply() Display.Apply(runRegion, runData) end
  local function ApplyIsolated(auraRegion, auraData)
    runRegion, runData = auraRegion, auraData
    xpcall(RunApply, geterrorhandler())
  end

  local function UsesUnitFrames(auraData)
    return auraData.anchorFrameType == "UNITFRAME" or Display.FlowFrameMode(auraData) == "UNITFRAME"
  end

  function Parts.Targets(auraRegion)
    local targets = {}
    local function Take(target)
      if target and target.SetAlpha then targets[#targets + 1] = target end
    end
    local function TakeAll(list)
      for _, target in ipairs(list or {}) do Take(target) end
    end
    for _, fieldName in ipairs(HIDDEN_FIELDS) do Take(auraRegion[fieldName]) end
    if auraRegion.regionType == "progresstexture" then
      Take(auraRegion.foreground and auraRegion.foreground.texture)
      Take(auraRegion.background and auraRegion.background.texture)
      TakeAll(auraRegion.foregroundSpinner and auraRegion.foregroundSpinner.textures)
      TakeAll(auraRegion.backgroundSpinner and auraRegion.backgroundSpinner.textures)
      for _, extra in ipairs(auraRegion.extraTextures or {}) do Take(extra.texture) end
      for _, spinner in ipairs(auraRegion.extraSpinners or {}) do TakeAll(spinner.textures) end
    end
    Take(auraRegion.bar and auraRegion.bar.bg)
    for _, subRegion in ipairs(auraRegion.subRegions or {}) do
      if not subRegion.secretAuraDetached then Take(subRegion) end
    end
    return targets
  end

  function Parts.ReturnAlphas(auraRegion)
    local remembered = auraRegion.blizzardSuppressed
    if remembered then
      for target, alpha in pairs(remembered) do target:SetAlpha(alpha) end
    end
    auraRegion.blizzardSuppressed = nil
  end

  function Parts.HideNotice(auraRegion)
    local notice = auraRegion.secretAuraPreviewNotice
    if notice then notice:Hide() end
  end

  function Parts.Hide(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    if InPreview() and not auraRegion.secretAuraSamplesActive and not (state and state.previewHasAuras) then
      Parts.ReturnAlphas(auraRegion)
      RefreshPreviewNotice(auraRegion)
      return
    end
    Parts.HideNotice(auraRegion)
    local remembered = auraRegion.blizzardSuppressed
    if not remembered then
      remembered = {}
      auraRegion.blizzardSuppressed = remembered
    end
    for _, target in ipairs(Parts.Targets(auraRegion)) do
      if remembered[target] == nil then remembered[target] = target:GetAlpha() end
      target:SetAlpha(0)
    end
  end

  function Parts.Wrap(auraRegion)
    local update = auraRegion.blizzardOriginalUpdate
    if not (update and auraRegion.Update == update.outer) then
      local inner = auraRegion.Update
      local outer = function(...)
        if inner then inner(...) end
        Parts.Hide(auraRegion)
        if Display.UpdateMissingSource then Display.UpdateMissingSource(auraRegion) end
      end
      auraRegion.blizzardOriginalUpdate = { inner = inner, outer = outer }
      auraRegion.Update = outer
    end
    local preShow = auraRegion.blizzardOriginalPreShow
    if not (preShow and auraRegion.PreShow == preShow.outer) then
      local outer = function() Parts.Hide(auraRegion) end
      auraRegion.blizzardOriginalPreShow = { inner = auraRegion.PreShow, outer = outer }
      auraRegion.PreShow = outer
    end
    Parts.Hide(auraRegion)
  end

  function Parts.Unwrap(auraRegion, method, recordField)
    local record = auraRegion[recordField]
    if not record then return end
    if auraRegion[method] == record.outer then auraRegion[method] = record.inner end
    auraRegion[recordField] = nil
  end

  function Display.Restore(auraRegion)
    if Display.HidePreview then Display.HidePreview(auraRegion) end
    if Display.RestorePreviewRegion then Display.RestorePreviewRegion(auraRegion) end
    Parts.HideNotice(auraRegion)
    auraRegion.secretAuraConditionValues = nil
    Parts.ReturnAlphas(auraRegion)
    Parts.Unwrap(auraRegion, "Update", "blizzardOriginalUpdate")
    Parts.Unwrap(auraRegion, "PreShow", "blizzardOriginalPreShow")
  end

  function Buttons.ElementFrame(buttonState, key)
    local frames = buttonState.elementFrames
    if not frames then
      frames = {}
      buttonState.elementFrames = frames
    end
    local frame = frames[key]
    if not frame then
      frame = CreateFrame("Frame", nil, buttonState.gateClip or buttonState.button)
      frame:SetAllPoints(buttonState.button)
      frame:EnableMouse(false)
      frames[key] = frame
    end
    return frame
  end

  function Buttons.StyleSample(sample, auraData)
    Display.StyleAppearance(sample, Display.PrepareConditionAppearance(auraData), Buttons.ElementFrame, Display.StyleText)
  end

  function Display.StyleText(label, buttonState, settings, fieldKey, iconSize, anchorRef, defaultX, defaultY)
    local mediaLib = LibStub("LibSharedMedia-3.0")
    local outline = settings[fieldKey .. "Outline"]
    if outline == "None" then
      outline = ""
    elseif not outline then
      outline = "OUTLINE"
    end
    local fontName = settings[fieldKey .. "Font"]
    Private.ApplyTextFont(label, nil,
      fontName and mediaLib:Fetch("font", fontName) or FALLBACK_FONT,
      settings[fieldKey .. "Size"] or iconSize,
      outline,
      settings[fieldKey .. "ShadowColor"] or { 0, 0, 0, 0 },
      settings[fieldKey .. "ShadowX"] or 1,
      settings[fieldKey .. "ShadowY"] or -1)
    local color = settings[fieldKey .. "Color"] or { 1, 1, 1, 1 }
    label:SetTextColor(color[1], color[2], color[3], color[4] or 1)

    local anchor = settings[fieldKey .. "Anchor"] or anchorRef
    local target, relative, ring = buttonState.button, anchor, nil
    local prefix = anchor:sub(1, 6)
    if prefix == "INNER_" then
      target, relative, ring = buttonState.inner, anchor:sub(7), "inner"
    elseif prefix == "OUTER_" then
      target, relative, ring = buttonState.outer, anchor:sub(7), "outer"
    end
    local selfPoint = settings[fieldKey .. "SelfPoint"] or (ring and "AUTO" or anchor)
    if selfPoint == "AUTO" then
      if ring == "inner" then
        selfPoint = relative
      elseif ring == "outer" then
        selfPoint = Private.inverse_point_types[relative] or "CENTER"
      else
        selfPoint = "CENTER"
      end
    end
    label:ClearAllPoints()
    label:SetPoint(selfPoint, target, relative, settings[fieldKey .. "X"] or defaultX or 0, settings[fieldKey .. "Y"] or defaultY or 0)
    label:SetJustifyH(settings[fieldKey .. "Justify"] or "CENTER")
  end

  function Display.RefreshShownAnimations(nativeState)
    local button = nativeState.button
    if nativeState.preview or not button or not button.SetDispelTypeText then return end
    local probe = nativeState.updateProbe
    if not probe then
      probe = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      nativeState.updateProbe = probe
    end
    probe:SetAlpha(0)
    button:SetDispelTypeText(probe, { showWhenHarmful = false })
  end

  function Display.StyleNative(buttonState, auraData, auraRegion)
    Display.StyleAppearance(buttonState, Display.PrepareConditionAppearance(auraData), Buttons.ElementFrame, Display.StyleText)
    Display.ApplyConditionAppearance(buttonState, auraRegion, auraData)
    Display.RefreshShownAnimations(buttonState)
  end

  function Display.SetupAuraButton(kind, auraRegion, holder, button)
    local gateClip = CreateFrame("Frame", nil, button, "DisableUntrustedLayoutScriptsTemplate")
    local rings = {}
    for _, ringName in ipairs({ "inner", "outer" }) do
      local ring = CreateFrame("Frame", nil, button)
      ring:SetPoint("CENTER", button, "CENTER")
      ring:EnableMouse(false)
      rings[ringName] = ring
    end
    local border = gateClip:CreateTexture(nil, "BACKGROUND")
    local overlayFrame = CreateFrame("Frame", nil, gateClip)

    gateClip:SetClipsChildren(true)
    for _, filler in ipairs({ gateClip, border, overlayFrame }) do filler:SetAllPoints(button) end
    button:EnableMouse(false)

    local buttonState = {
      container = holder, button = button, gateClip = gateClip, gateText = button:CreateFontString(nil, "BACKGROUND"),
      inner = rings.inner, outer = rings.outer, border = border, overlay = overlayFrame,
    }
    local sharedBase = Buttons.ElementFrame(buttonState, "sharedBase")
    local icon = sharedBase:CreateTexture(nil, "ARTWORK")
    local sweepFrame = CreateFrame("Cooldown", nil, sharedBase, "CooldownFrameTemplate")
    sweepFrame:SetAllPoints(icon)
    sweepFrame:SetDrawBling(false)
    sweepFrame:SetHideCountdownNumbers(true)
    button:SetIcon(icon)
    button:SetDurationCooldown(sweepFrame)

    local cooldownLevel = ReadLevel(sweepFrame)
    if cooldownLevel then overlayFrame:SetFrameLevel(cooldownLevel + 1) end

    buttonState.icon, buttonState.cooldown = icon, sweepFrame
    Display.StyleNative(buttonState, kind.data, auraRegion)
    kind.buttons[#kind.buttons + 1] = buttonState
  end

  local function IdSet(list)
    local set, count = {}, 0
    for _, id in ipairs(list or {}) do
      local number = tonumber(id)
      if number then
        set[number] = true
        count = count + 1
      end
    end
    return set, count
  end

  function Display.CandidateFilters(auraData)
    local triggerConfig = Display.GetTrigger(auraData)
    local candidateList = {}

    local operator, seconds = Display.TotalFilter(triggerConfig)
    if operator == "<=" then
      candidateList.maxDuration = seconds + 0.05
    elseif operator == "=" then
      candidateList.maxDuration = seconds + 0.5
    end

    if Display.UsesSpellIDs(triggerConfig) or Display.UsesRankSpellIDs(triggerConfig) then
      candidateList.includeSpellIDs = IdSet(Display.GetSpellIDs(triggerConfig, true))
    end
    if Display.UsesExcludedSpellIDs(triggerConfig) then
      local excluded, count = IdSet(triggerConfig.excludedAuraSpellIDs)
      if count > 0 then candidateList.excludeSpellIDs = excluded end
    end

    for _, row in ipairs(Display.booleanFilters) do
      local key = type(row) == "table" and (row.key or row[1]) or row
      if Display.FilterApplies(key, triggerConfig)
        and ((key ~= "nameplateShowAll" and key ~= "nameplateShowPersonal") or triggerConfig.unit == "nameplate") then
        candidateList[key] = triggerConfig[key]
      end
    end

    for _, fieldName in ipairs({ "includeDispelTypes", "excludeDispelTypes" }) do
      local source = triggerConfig[fieldName]
      if type(source) == "table" and next(source) ~= nil then
        local copy = {}
        for key, value in pairs(source) do copy[key] = value end
        candidateList[fieldName] = copy
      end
    end
    return Display.ApproximateFilters(triggerConfig, candidateList)
  end

  local glowMargins = setmetatable({}, { __mode = "k" })

  local function NotifyUnitFrames() Display.UnitFramesChanged() end

  function Glow.Surround(holder, target)
    local margin = glowMargins[target]
    if not margin then
      margin = { 0, 0 }
      glowMargins[target] = margin
      pcall(target.HookScript, target, "OnSizeChanged", NotifyUnitFrames)
    end
    local width, height = target:GetSize()
    if not (issecretvalue(width) or issecretvalue(height)) then
      margin[1], margin[2] = width * GLOW_MARGIN_RATIO, height * GLOW_MARGIN_RATIO
    end
    holder:SetPoint("TOPLEFT", target, "TOPLEFT", 0 - margin[1], margin[2])
    holder:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", margin[1], 0 - margin[2])
  end

  function Glow.StyleHalo(unitEntry)
    local glow = unitEntry.unitGlow
    local settings = unitEntry.data.blizzardAuraDisplay or {}
    glow.glowEntry = glow.glowEntry or { native = glow }
    local color = DEFAULT_GLOW_COLOR
    if settings.unitUseGlowColor ~= false and settings.unitGlowColor then color = settings.unitGlowColor end
    local padding = settings.unitGlowPadding or 0
    Display.StyleElementGlow(glow.glowEntry, glow.button, glow.overlay, glow.button, {
      glow = settings.unitGlow and true or false,
      glowType = settings.unitGlowType == "pulse" and "pulse" or "Proc",
      useGlowColor = true,
      glowColor = color,
      glowDuration = settings.unitGlowDuration,
      glowDurationMax = math.huge,
      glowXOffset = padding,
      glowYOffset = padding,
    }, nil, nil, settings.unitGlowX, settings.unitGlowY)
  end

  function Glow.SetupButton(unitEntry, button)
    local glow = unitEntry.unitGlow
    local overlayFrame = CreateFrame("Frame", nil, button)
    glow.button, glow.overlay = button, overlayFrame
    button:EnableMouse(false)
    button:SetAllPoints(glow.container)
    overlayFrame:SetAllPoints(button)
    local level = ReadLevel(glow.container)
    if level then
      for offset, frame in ipairs({ button, overlayFrame }) do frame:SetFrameLevel(level + offset) end
    end
    Glow.StyleHalo(unitEntry)
  end

  function Glow.Configure(unitEntry, auraData, triggerConfig)
    local settings = auraData.blizzardAuraDisplay or {}
    local glow = unitEntry.unitGlow
    if auraData.anchorFrameType ~= "UNITFRAME" or not settings.unitGlow then
      if glow then
        Display.ClearElementGlow(glow.glowEntry)
        glow.container:SetEnabled(false)
        glow.container:Hide()
      end
      return
    end
    local created = glow == nil
    if created then
      glow = { container = CreateFrame("AuraContainer", nil, unitEntry.region, "CustomAuraContainerTemplate") }
      unitEntry.unitGlow = glow
    end
    local holder = glow.container
    local filterString = Display.FilterString(triggerConfig)
    local candidateList = Display.CandidateFilters(auraData)

    holder:SetEnabled(false)
    holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    if created then
      holder:AddAuraSlot(GLOW_SLOT, filterString, {
        candidateFilters = candidateList,
        initializeFrame = function(button) Glow.SetupButton(unitEntry, button) end,
      })
    else
      if glow.button then Glow.StyleHalo(unitEntry) end
      Display.RefreshShownAnimations(glow)
    end
    holder:SetAuraSlotFilterString(GLOW_SLOT, filterString)
    holder:SetAuraSlotCandidateFilters(GLOW_SLOT, candidateList)
    holder:SetAuraSlotSortMethod(GLOW_SLOT, Display.SortOrder(auraData, triggerConfig))
  end

  function Glow.Refresh(auraRegion, state, unitEntry, unitId, anchorFrame, unitFrameMode)
    local glow = unitEntry.unitGlow
    local holder = glow.container
    local settings = state.data.blizzardAuraDisplay or {}
    local target
    if unitFrameMode and unitId ~= nil and settings.unitGlow and anchorFrame then
      local forbidden = anchorFrame.IsForbidden and anchorFrame:IsForbidden()
      if not issecretvalue(forbidden) and not forbidden then target = anchorFrame end
    end
    local visible = not InPreview() and target ~= nil and auraRegion:IsShown() and not state.unitGlowsHidden
      and settings.unitGlow == true and not unitEntry.statusHidden
    local host = target or auraRegion
    Anchor.Rebind(glow, holder, unitId, host)
    holder:ClearAllPoints()
    if target then
      Glow.Surround(holder, target)
    else
      holder:SetAllPoints(host)
    end

    local strata, currentStrata = host:GetFrameStrata(), holder:GetFrameStrata()
    if issecretvalue(strata) or issecretvalue(currentStrata) or strata ~= currentStrata then
      pcall(holder.SetFrameStrata, holder, strata)
    end
    local hostLevel = ReadLevel(host)
    if hostLevel then
      local wanted, current = hostLevel + GLOW_FRAME_LEVEL_STEP, holder:GetFrameLevel()
      if issecretvalue(current) or current ~= wanted then holder:SetFrameLevel(wanted) end
    end

    holder:SetShown(visible)
    holder:SetEnabled(visible)
    if visible then holder:UpdateAllAuras() end
  end

  function Display.HideUnitGlows(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    if not state then return end
    state.unitGlowsHidden = true
    for _, unitEntry in ipairs(state.instances) do
      local glow = unitEntry.unitGlow
      if glow then
        glow.container:SetEnabled(false)
        glow.container:Hide()
      end
    end
  end

  function Instances.Create(auraRegion, auraData)
    local holder, isFlowContainer = Display.CreateAuraContainer(auraRegion, auraData)
    local unitEntry = { container = holder, region = auraRegion, flowContainer = isFlowContainer and true or false, buttons = {}, data = auraData }
    local triggerConfig = Display.GetTrigger(auraData)
    local sortMethod, sortDirection = Display.SortOrder(auraData, triggerConfig)
    holder:SetEnabled(false)
    holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    holder:SetPoint("TOPLEFT", auraRegion, "TOPLEFT")
    holder:AddAuraGroup(AURA_GROUP, Display.FilterString(triggerConfig), {
      maxFrameCount = Display.MaxAuras(auraData),
      candidateFilters = Display.CandidateFilters(auraData),
      sortMethod = sortMethod,
      sortDirection = sortDirection,
      initializeFrame = function(button) Display.SetupAuraButton(unitEntry, auraRegion, holder, button) end,
    })
    return unitEntry
  end

  function Instances.Configure(auraRegion, state, position, unitEntry, restyle)
    local auraData = state.data
    local holder = unitEntry.container
    local triggerConfig = Display.GetTrigger(auraData)
    unitEntry.data = auraData

    holder:SetEnabled(false)
    holder:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    holder:SetAuraGroupFilterString(AURA_GROUP, Display.FilterString(triggerConfig))
    holder:SetAuraGroupCandidateFilters(AURA_GROUP, Display.CandidateFilters(auraData))
    holder:SetAuraGroupSortMethod(AURA_GROUP, Display.SortOrder(auraData, triggerConfig))

    if restyle then
      for _, buttonState in ipairs(unitEntry.buttons) do Display.StyleNative(buttonState, auraData, auraRegion) end
    end
    LayoutInstance(unitEntry, auraRegion, auraData, position)
    Glow.Configure(unitEntry, auraData, triggerConfig)
    Display.ConfigureSingle(unitEntry, auraRegion, auraData, position)
  end

  function Instances.Remove(unitEntry)
    for _, buttonState in ipairs(unitEntry.buttons) do
      for _, entry in pairs(buttonState.sharedElements or {}) do Display.ClearElementGlow(entry) end
    end
    local glow = unitEntry.unitGlow
    Display.ClearElementGlow(glow and glow.glowEntry)
    unitEntry.container:SetEnabled(false)
    unitEntry.container:Hide()
    Display.RefreshSingle(unitEntry, nil, false)
    local missing = unitEntry.single and unitEntry.single.missing
    if missing then missing.active = false end
    Display.RetireFrame(unitEntry.container)
    Display.RetireFrame(unitEntry.flowShadow)
    if glow then Display.RetireFrame(glow.container) end
  end

  function Instances.RemoveAll(state)
    local list = state.instances
    for position = #list, 1, -1 do
      Instances.Remove(list[position])
      list[position] = nil
    end
  end

  function Display.FlushInstanceQueue(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    local queue = state and state.instanceQueue
    if not queue then return end
    state.instanceQueue = nil
    Queues.instanceRegions[auraRegion] = nil
    if WeakAuras.IsRestricted() then
      queuedApplies[auraRegion] = queue.data
      return
    end
    if state.data ~= queue.data then return end
    for position = queue.nextIndex, #state.instances do
      Instances.Configure(auraRegion, state, position, state.instances[position], true)
    end
  end

  function Units.Status(triggerConfig, unitId)
    if unitId == nil or not GROUP_UNITS[triggerConfig.unit] then return false end
    local connectedFlag, hasConnected
    if triggerConfig.ignoreDisconnected then
      local connected = UnitIsConnected(unitId)
      if issecretvalue(connected) then
        connectedFlag, hasConnected = connected, true
      elseif not connected then
        return true
      end
    end
    if triggerConfig.ignoreDead then
      local dead = UnitIsDeadOrGhost(unitId)
      if issecretvalue(dead) then
        if hasConnected then return false, nil, connectedFlag, false, true end
        return false, dead, nil, true, false
      elseif dead then
        return true
      end
    end
    return false, nil, connectedFlag, false, hasConnected or false
  end

  function Display.UnitIgnored(triggerConfig, unitId)
    local isIgnored, secretDead, secretConnected = Units.Status(triggerConfig, unitId)
    return isIgnored, secretDead, secretConnected
  end

  function Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)
    local holder, base = unitEntry.container, unitEntry.containerAlpha or 1
    unitEntry.statusSecret = (hasDead or hasConnected) and true or false
    if hasDead then
      holder:SetAlphaFromBoolean(secretDead, 0, base)
    elseif hasConnected then
      holder:SetAlphaFromBoolean(secretConnected, base, 0)
    else
      holder:SetAlpha(base)
    end
  end

  function Units.RefreshPreview(auraRegion, state)
    local previewing = InPreview()
    local auraData = state.data
    state.previewHasAuras = previewing
    if previewing then
      if not (auraRegion.secretAuraSamplesActive and state.previewStyled == auraData) then
        Display.ShowPreview(auraRegion, auraData, Buttons.StyleSample)
        state.previewStyled = auraData
      end
      Display.ArrangeFlowPreview(Display.FlowGroup(auraData))
    else
      Display.RestorePreviewRegion(auraRegion)
      Display.RestoreGroupPreview(Display.FlowGroup(auraData))
      Display.HidePreview(auraRegion)
    end
    Parts.Hide(auraRegion)
    if previewing then RefreshPreviewNotice(auraRegion) end
  end

  function Units.RefreshInstance(auraRegion, state, position, unitEntry, units, growth, flowMode, droppedUnit)
    local auraData = state.data
    local holder = unitEntry.container
    if state.gridMember then
      unitEntry.visible = false
      unitEntry.statusHidden = nil
      holder:SetEnabled(false)
      holder:Hide()
      Display.RefreshSingle(unitEntry, nil, false)
      Display.RefreshFlowShadow(unitEntry, nil, false)
      return
    end
    local triggerConfig = Display.GetTrigger(auraData)
    local unitId = units[position]
    local unitFrameMode, plateMode = AttachModes(auraData, flowMode)
    local anchorFrame = Anchor.LocateAnchor(unitId, unitFrameMode, plateMode, droppedUnit)

    local isIgnored, secretDead, secretConnected, hasDead, hasConnected = Units.Status(triggerConfig or {}, unitId)
    unitEntry.statusHidden = isIgnored
    local isShown = (not InPreview() and unitId ~= nil and auraRegion:IsShown() and not isIgnored
      and (not (unitFrameMode or plateMode) or anchorFrame ~= nil)) and true or false

    local parent = auraRegion
    if unitFrameMode and auraData.anchorFrameParent ~= false and anchorFrame then parent = anchorFrame end
    Anchor.Rebind(unitEntry, holder, unitId, parent)

    local locked = Anchor.Locked(holder)
    if locked then lockedRegions[auraRegion] = true end
    if parent == auraRegion then
      unitEntry.containerAlpha = 1
    else
      unitEntry.containerAlpha = auraData.alpha or 1
    end
    Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)

    if not locked then
      PlaceInstance(auraRegion, unitEntry, auraData, position, parent, anchorFrame, unitFrameMode, plateMode, growth)
      unitEntry.visible = isShown
      holder:SetShown(isShown)
      holder:SetEnabled(isShown)
      if isShown then holder:UpdateAllAuras() end
    end
    Display.RefreshSingle(unitEntry, unitId, isShown)
    Display.RefreshFlowShadow(unitEntry, unitId, isShown)
    if unitEntry.unitGlow then Glow.Refresh(auraRegion, state, unitEntry, unitId, anchorFrame, unitFrameMode) end
  end

  function Units.Refresh(auraRegion, droppedUnit, updatedUnit)
    local state = auraRegion.blizzardAuraDisplay
    if not (state and state.active) then return end
    if state.instanceQueue and not InPreview() then Display.FlushInstanceQueue(auraRegion) end
    local auraData = state.data
    local triggerConfig = Display.GetTrigger(auraData)
    if not triggerConfig then return end
    local units = Display.UnitTokens(triggerConfig)
    local growth = Display.Growth(auraData)
    local flowMode = Display.FlowFrameMode(auraData)
    for position, unitEntry in ipairs(state.instances) do
      if not updatedUnit or units[position] == updatedUnit then
        Units.RefreshInstance(auraRegion, state, position, unitEntry, units, growth, flowMode, droppedUnit)
      end
    end
    Display.RefreshFlowUnits(Display.FlowGroup(auraData), droppedUnit)
    Display.UpdateDetachedFrameLevels(auraRegion)
    Units.RefreshPreview(auraRegion, state)
  end

  function Units.ReplayLocked()
    for _, auraRegion in ipairs(PendingSet(lockedRegions)) do
      lockedRegions[auraRegion] = nil
      if liveRegions[auraRegion] then Units.Refresh(auraRegion) end
    end
  end

  function Units.OnStatusChange(unit)
    for auraRegion in pairs(liveRegions) do
      local state = auraRegion.blizzardAuraDisplay
      local triggerConfig = Display.GetTrigger(state.data)
      if triggerConfig and (triggerConfig.ignoreDead or triggerConfig.ignoreDisconnected) then
        if state.gridMember then
          local ignored = Units.Status(triggerConfig, unit)
          local gridIgnored = state.gridIgnored
          if not gridIgnored then
            gridIgnored = {}
            state.gridIgnored = gridIgnored
          end
          if ignored ~= (gridIgnored[unit] or false) then
            gridIgnored[unit] = ignored
            Display.RefreshFlowUnits(Display.FlowGroup(state.data))
          end
        else
          for _, unitEntry in ipairs(state.instances) do
            if unitEntry.boundUnit == unit then
              local ignored, secretDead, secretConnected, hasDead, hasConnected = Units.Status(triggerConfig, unit)
              if ignored ~= unitEntry.statusHidden then
                Units.Refresh(auraRegion, nil, unit)
                break
              elseif hasDead or hasConnected or unitEntry.statusSecret then
                Units.ApplyStatusAlpha(unitEntry, secretDead, secretConnected, hasDead, hasConnected)
              end
            end
          end
        end
      end
    end
  end

  local framesPending = false

  local function RefreshUnitFrameRegions()
    framesPending = false
    for auraRegion in pairs(liveRegions) do
      local state = auraRegion.blizzardAuraDisplay
      if UsesUnitFrames(state.data) then Units.Refresh(auraRegion) end
    end
  end

  function Display.UnitFramesChanged()
    if framesPending then return end
    local used = false
    for auraRegion in pairs(liveRegions) do
      if UsesUnitFrames(auraRegion.blizzardAuraDisplay.data) then
        used = true
        break
      end
    end
    if not used then return end
    framesPending = true
    C_Timer.After(0, RefreshUnitFrameRegions)
  end

  function Display.UpdateDetachedFrameLevels(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    if not (state and state.active) then return end
    local base = ReadLevel(auraRegion)
    if not base then return end
    for _, unitEntry in ipairs(state.instances) do
      local level = ReadLevel(unitEntry.container)
      if level and level > base then base = level end
    end
    base = base + 3 * #(state.data.subRegions or {}) + 8
    for index, subRegion in ipairs(auraRegion.subRegions or {}) do
      if subRegion.secretAuraDetached then subRegion:SetFrameLevel(base + index) end
    end
  end

  Queues.instanceRegions = {}
  Queues.unprepared = {}
  Queues.editorPending = setmetatable({}, { __mode = "k" })

  function Queues.ApplyPass()
    if WeakAuras.IsRestricted() then
      Queues.applying = false
      return
    end
    if not WeakAuras.IsLoginFinished() then
      C_Timer.After(LOGIN_POLL_SECONDS, Queues.ApplyPass)
      return
    end
    local startedAt = debugprofilestop()
    while true do
      local auraRegion, auraData = next(queuedApplies)
      if auraRegion == nil then break end
      queuedApplies[auraRegion] = nil
      local entry = Private.regions[auraData.id]
      if WeakAuras.GetData(auraData.id) == auraData and entry and entry.region == auraRegion then
        ApplyIsolated(auraRegion, auraData)
        if debugprofilestop() - startedAt >= APPLY_BUDGET_MS then break end
      end
    end
    if next(queuedApplies) ~= nil then
      C_Timer.After(0, Queues.ApplyPass)
    else
      Queues.applying = false
    end
  end

  function Queues.StartApplies()
    if Queues.applying or next(queuedApplies) == nil then return end
    Queues.applying = true
    Queues.ApplyPass()
  end

  local prepareId
  local function EnsureAndRelease()
    local auraRegion = Private.EnsureRegion(prepareId)
    if auraRegion and Private.loaded[prepareId] == false then Display.Release(auraRegion) end
  end

  function Queues.PreparePass()
    if WeakAuras.IsRestricted() then
      Queues.preparing = false
      return
    end
    if not WeakAuras.IsLoginFinished() then
      C_Timer.After(LOGIN_POLL_SECONDS, Queues.PreparePass)
      return
    end
    local startedAt = debugprofilestop()
    local pending = Queues.unprepared
    while true do
      local id = next(pending)
      if id == nil then break end
      pending[id] = nil
      local auraData = WeakAuras.GetData(id)
      if auraData and Display.Enabled(auraData) and Private.loaded[id] == false
        and not WeakAuras.GetRegion(id) and not WeakAuras.IsOptionsOpen() then
        prepareId = id
        xpcall(EnsureAndRelease, geterrorhandler())
        if debugprofilestop() - startedAt >= APPLY_BUDGET_MS then break end
      end
    end
    if next(pending) ~= nil then
      C_Timer.After(0, Queues.PreparePass)
    else
      Queues.preparing = false
    end
  end

  function Queues.StartPreparing()
    if Queues.preparing or next(Queues.unprepared) == nil then return end
    Queues.preparing = true
    Queues.PreparePass()
  end

  function Queues.EditorPass()
    local pending = Queues.editorPending
    local applied = 0
    for _, auraRegion in ipairs(PendingSet(pending)) do
      if applied >= EDITOR_APPLY_BATCH then break end
      local auraData = pending[auraRegion]
      pending[auraRegion] = nil
      local entry = auraData and Private.regions[auraData.id]
      if entry and entry.region == auraRegion and (WeakAuras.GetData(auraData.id) or auraData) == auraData and Display.Enabled(auraData) then
        applied = applied + 1
        ApplyIsolated(auraRegion, auraData)
      end
    end
    if next(pending) ~= nil then
      C_Timer.After(0, Queues.EditorPass)
    else
      Queues.editorDraining = false
    end
  end

  function Queues.InstancePass()
    local pending = Queues.instanceRegions
    for _, auraRegion in ipairs(PendingSet(pending)) do
      local state = auraRegion.blizzardAuraDisplay
      local queue = state and state.instanceQueue
      if not queue or not state.active or state.data ~= queue.data then
        pending[auraRegion] = nil
      elseif WeakAuras.IsRestricted() then
        state.instanceQueue = nil
        pending[auraRegion] = nil
        queuedApplies[auraRegion] = queue.data
      else
        local total = #state.instances
        local last = math.min(queue.nextIndex + EDITOR_BATCH_SIZE - 1, total)
        for position = queue.nextIndex, last do
          Instances.Configure(auraRegion, state, position, state.instances[position], true)
        end
        if last >= total then
          state.instanceQueue = nil
          pending[auraRegion] = nil
          Units.Refresh(auraRegion)
        else
          queue.nextIndex = last + 1
        end
      end
    end
    if next(pending) ~= nil then
      C_Timer.After(0, Queues.InstancePass)
    else
      Queues.instanceDraining = false
    end
  end

  function Queues.StartInstanceDrain()
    if Queues.instanceDraining then return end
    Queues.instanceDraining = true
    C_Timer.After(0, Queues.InstancePass)
  end

  function Display.CancelEditorApply(auraRegion)
    Queues.editorPending[auraRegion] = nil
  end

  Private.callbacks:RegisterCallback("Add", function(_, _, id, auraData)
    if Display.Enabled(auraData) then
      Queues.unprepared[id] = true
      Queues.StartPreparing()
    end
  end)

  Private.callbacks:RegisterCallback("RestrictionChanged", function(_, isRestricted)
    if not isRestricted then
      Queues.StartApplies()
      Queues.StartPreparing()
    end
  end)

  local function ProgressSourceKey(auraData)
    if not Display.GetTrigger(auraData) then return 0 end
    local source = auraData.progressSource
    local key = type(source) == "table" and tonumber(source[1]) or -1
    if key < 0 then
      local mode = auraData.triggers and auraData.triggers.activeTriggerMode
      if type(mode) == "number" and mode > 0 then
        key = mode
      elseif Private.GetActiveTriggerFor then
        key = Private.GetActiveTriggerFor(auraData.id) or 1
      else
        key = 1
      end
    end
    return key
  end

  local function CreateState(auraRegion)
    local state = { instances = {}, generation = 0, active = false }
    auraRegion.blizzardAuraDisplay = state
    auraRegion:HookScript("OnHide", function()
      Display.HideUnitGlows(auraRegion)
      for _, unitEntry in ipairs(state.instances) do
        unitEntry.container:SetEnabled(false)
        unitEntry.container:Hide()
        Display.RefreshSingle(unitEntry, nil, false)
      end
      if state.gridMember then Display.RefreshFlowUnits(Display.FlowGroup(state.data)) end
      SyncSounds(auraRegion)
    end)
    auraRegion:HookScript("OnShow", function()
      state.unitGlowsHidden = false
      if state.active then
        Units.Refresh(auraRegion)
        SyncSounds(auraRegion)
      end
    end)
    return state
  end

  function Display.Apply(auraRegion, auraData)
    if Display.Enabled(auraData) and Display.InDynamicGroup(auraData) then
      Warn(auraData, "blizzard_aura_dynamicgroup", Display.dynamicGroupWarning)
    else
      Warn(auraData, "blizzard_aura_dynamicgroup")
    end
    if not Display.Enabled(auraData) then
      Display.Release(auraRegion, true)
      Warn(auraData, "blizzard_aura_display")
      Warn(auraData, "blizzard_aura_sound")
      return
    end
    Parts.Hide(auraRegion)
    local problem = Display.Validate(auraData)
    if problem then
      Display.Release(auraRegion, true)
      Warn(auraData, "blizzard_aura_display", problem)
      return
    end

    local previewing = InPreview()
    if previewing then
      Display.ShowPreview(auraRegion, auraData, Buttons.StyleSample)
      Display.ArrangeFlowPreview(Display.FlowGroup(auraData))
      Parts.Hide(auraRegion)
    else
      Display.HidePreview(auraRegion)
      Display.RestorePreviewRegion(auraRegion)
      Display.RestoreGroupPreview(Display.FlowGroup(auraData))
    end

    if WeakAuras.IsRestricted() then
      queuedApplies[auraRegion] = auraData
      Warn(auraData, "blizzard_aura_display", PENDING_TEXT)
      return
    end
    if not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
      local addonLoaded, failReason = C_AddOns.LoadAddOn("Blizzard_AuraContainer")
      if not addonLoaded then
        Warn(auraData, "blizzard_aura_display", "Cannot load Blizzard_AuraContainer: " .. tostring(failReason))
        return
      end
    end

    local state = auraRegion.blizzardAuraDisplay or CreateState(auraRegion)
    local previousMember = state.gridMember
    state.data = auraData
    state.gridMember = Display.GridMember(auraData)
    state.generation = state.generation + 1
    Display.EnsureFlowStart(auraRegion, auraData)
    state.previewStyled = previewing and auraData or nil
    if previewing then RefreshPreviewNotice(auraRegion) end
    state.unitGlowsHidden = false

    local instances = state.instances
    local flowGroup = Display.FlowGroup(auraData)
    if instances[1] and instances[1].flowContainer ~= (flowGroup ~= nil) then Instances.RemoveAll(state) end

    local count = SlotCount(Display.GetTrigger(auraData))
    Display.ClearSingleWarning(auraData)
    local created = {}
    for position = #instances + 1, count do
      local unitEntry = Instances.Create(auraRegion, auraData)
      instances[position] = unitEntry
      created[unitEntry] = true
    end
    for position = #instances, count + 1, -1 do
      Instances.Remove(instances[position])
      instances[position] = nil
    end

    state.instanceQueue = nil
    Queues.instanceRegions[auraRegion] = nil
    local immediate = count
    if previewing and count > EDITOR_FIRST_BATCH then
      immediate = EDITOR_FIRST_BATCH
      state.instanceQueue = { data = auraData, nextIndex = EDITOR_FIRST_BATCH + 1 }
      Queues.instanceRegions[auraRegion] = true
    end
    for position = 1, immediate do
      local unitEntry = instances[position]
      Instances.Configure(auraRegion, state, position, unitEntry, not created[unitEntry])
    end

    state.active = true
    state.appliedTrigger = Display.GetSavedTrigger(auraData)
    liveRegions[auraRegion] = true

    Display.EnsureFlowShadows(auraRegion, auraData)
    local missing = instances[1] and instances[1].single and instances[1].single.missing
    Display.SetFlowEnd(auraRegion, auraData, missing and missing.active and missing.presenceActive and missing.presence or nil)
    Display.RechainFlow(flowGroup or (previousMember and auraData.parent and WeakAuras.GetData(auraData.parent)) or nil)

    Units.Refresh(auraRegion)
    queuedApplies[auraRegion] = nil
    SyncSounds(auraRegion)
    Warn(auraData, "blizzard_aura_display")
    if state.instanceQueue then Queues.StartInstanceDrain() end
  end

  function Display.Activate(auraRegion, auraData)
    if not Display.Enabled(auraData) then
      Display.Release(auraRegion, true)
      return
    end
    Parts.Wrap(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    local triggerConfig = Display.GetTrigger(auraData)
    if state and triggerConfig and state.data == auraData and not queuedApplies[auraRegion]
      and Display.Validate(auraData) == nil and Display.GridMember(auraData) == state.gridMember
      and #state.instances == SlotCount(triggerConfig) then
      Display.FlushInstanceQueue(auraRegion)
      Display.WatchAuraLearning(auraRegion, auraData, triggerConfig, (Display.LateGlowSpec(auraData, triggerConfig)))
      state.unitGlowsHidden = false
      state.active = true
      liveRegions[auraRegion] = true
      Display.RechainFlow(Display.FlowGroup(auraData))
      Units.Refresh(auraRegion)
      SyncSounds(auraRegion)
    else
      Display.Apply(auraRegion, auraData)
    end
  end

  function Display.Release(auraRegion, leaveGrid)
    Display.ReleaseAuraLearning(auraRegion)
    Display.HideUnitGlows(auraRegion)
    Display.Restore(auraRegion)
    queuedApplies[auraRegion] = nil
    Display.CancelEditorApply(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    if not state then return end
    state.active = false
    if leaveGrid then state.gridMember = nil end
    state.instanceQueue = nil
    Queues.instanceRegions[auraRegion] = nil
    for _, unitEntry in ipairs(state.instances) do
      unitEntry.container:SetEnabled(false)
      unitEntry.container:Hide()
      Display.RefreshSingle(unitEntry, nil, false)
    end
    local auraData = state.data
    if auraData then
      Warn(auraData, "blizzard_aura_single")
      Warn(auraData, "blizzard_aura_dynamicgroup")
      Warn(auraData, "blizzard_aura_grid")
    end
    liveRegions[auraRegion] = nil
    SyncSounds(auraRegion)
    if auraData then Display.RechainFlow(Display.FlowGroup(auraData)) end
  end

  function Display.Modify(auraRegion, auraData)
    ForgetClassifiedTriggers(auraData)
    Display.ForgetConditionRules(auraData)
    auraRegion.secretAuraProgressSourceIndex = ProgressSourceKey(auraData)
    auraRegion.secretAuraConditionValues = nil
    if not Display.Enabled(auraData) then
      Display.Release(auraRegion, true)
      Warn(auraData, "blizzard_aura_display")
      Warn(auraData, "blizzard_aura_sound")
      return
    end
    Parts.Wrap(auraRegion)
    local state = auraRegion.blizzardAuraDisplay
    if WeakAuras.IsOptionsOpen() and state and state.active and state.data == auraData and not WeakAuras.IsRestricted() then
      Queues.editorPending[auraRegion] = auraData
      if not Queues.editorDraining then
        Queues.editorDraining = true
        C_Timer.After(0, Queues.EditorPass)
      end
      return
    end
    Queues.editorPending[auraRegion] = nil
    Display.Apply(auraRegion, auraData)
  end

  function Display.SyncProgressSource(auraRegion, auraData)
    if not auraData then return end
    local key = ProgressSourceKey(auraData)
    if auraRegion.secretAuraProgressSourceIndex == key then return end
    local state = auraRegion.blizzardAuraDisplay
    if state and state.data == auraData and state.appliedTrigger == Display.GetSavedTrigger(auraData) then
      auraRegion.secretAuraProgressSourceIndex = key
      if not state.active then Display.Activate(auraRegion, auraData) end
      return
    end
    Display.Modify(auraRegion, auraData)
  end

  function Display.ApplyFlowSort(group)
    if WeakAuras.IsRestricted() then return false end
    local targets = {}
    for _, childId in ipairs(group.controlledChildren or {}) do
      local childAura = WeakAuras.GetRegion(childId)
      local state = childAura and childAura.blizzardAuraDisplay
      local auraData = WeakAuras.GetData(childId)
      if state and auraData and state.data == auraData then
        if not state.active or state.gridMember then return false end
        local triggerConfig = Display.GetTrigger(auraData)
        if not triggerConfig or Display.IsSingle(triggerConfig, auraData) then return false end
        for _, unitEntry in ipairs(state.instances) do
          if unitEntry.unitGlow then return false end
          targets[#targets + 1] = { unitEntry.container, auraData, triggerConfig }
        end
      end
    end
    for _, target in ipairs(targets) do
      target[1]:SetAuraGroupSortMethod(AURA_GROUP, Display.SortOrder(target[2], target[3]))
    end
    return true
  end

  local knownPlates = {}

  function Plates.Grow(index)
    if index <= #nameplateTokens then return false end
    return GrowNameplateTokens(index)
  end

  function Plates.Note(unit)
    if issecretvalue(unit) or type(unit) ~= "string" or knownPlates[unit] then return end
    local digits = unit:match("^nameplate(%d+)$")
    if not digits then return end
    knownPlates[unit] = true
    if Plates.Grow(tonumber(digits)) then
      for auraRegion in pairs(liveRegions) do
        local state = auraRegion.blizzardAuraDisplay
        local triggerConfig = Display.GetTrigger(state.data)
        if triggerConfig and triggerConfig.unit == "nameplate" then queuedApplies[auraRegion] = state.data end
      end
    end
  end

  function Plates.ReadShown()
    for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do Plates.Note(plate.unitToken) end
    Queues.StartApplies()
  end

  local function RosterEvent(event, _, triggerConfig)
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED" or event == "UNIT_NAME_UPDATE" then return true end
    return event == "UNIT_PET" and triggerConfig.use_includePets and true or false
  end

  local UnitModeRules = {
    group = RosterEvent,
    party = RosterEvent,
    raid = RosterEvent,
    member = function(event)
      return event == "GROUP_ROSTER_UPDATE" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT"
        or event == "ARENA_OPPONENT_UPDATE" or event == "UNIT_PET"
    end,
    pet = function(event, unit) return event == "UNIT_PET" and unit == "player" end,
    target = function(event) return event == "PLAYER_TARGET_CHANGED" end,
    targettarget = function(event, unit)
      return event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_TARGET" and unit == "target")
    end,
    focus = function(event) return event == "PLAYER_FOCUS_CHANGED" end,
    focustarget = function(event, unit)
      return event == "PLAYER_FOCUS_CHANGED" or (event == "UNIT_TARGET" and unit == "focus")
    end,
    mouseover = function(event) return event == "UPDATE_MOUSEOVER_UNIT" end,
    boss = function(event) return event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" end,
    arena = function(event) return event == "ARENA_OPPONENT_UPDATE" end,
  }

  local ModeBoundEvents = {
    GROUP_ROSTER_UPDATE = true, PLAYER_ROLES_ASSIGNED = true, PLAYER_TARGET_CHANGED = true,
    PLAYER_FOCUS_CHANGED = true, UPDATE_MOUSEOVER_UNIT = true, INSTANCE_ENCOUNTER_ENGAGE_UNIT = true,
    ARENA_OPPONENT_UPDATE = true, UNIT_NAME_UPDATE = true, UNIT_TARGET = true, UNIT_PET = true,
    PLAYER_REGEN_ENABLED = true, ADDON_RESTRICTION_STATE_CHANGED = true,
  }

  function Events.WantsUnitUpdate(triggerConfig, event, unit)
    if not ModeBoundEvents[event] then return true end
    local rule = UnitModeRules[triggerConfig.unit]
    return rule ~= nil and rule(event, unit, triggerConfig) and true or false
  end

  function Events.WantsSounds(triggerConfig, event)
    if not SOUND_UNITS[triggerConfig.unit] then return false end
    return event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ROLES_ASSIGNED"
      or (event == "UNIT_NAME_UPDATE" and triggerConfig.useUnitNames)
      or (event == "UNIT_PET" and triggerConfig.use_includePets) and true or false
  end

  local plateRefreshes = {
    NAME_PLATE_UNIT_ADDED = function(auraRegion, unit) Units.Refresh(auraRegion, nil, unit) end,
    NAME_PLATE_UNIT_REMOVED = function(auraRegion, unit) Units.Refresh(auraRegion, unit, unit) end,
  }

  function Events.HandleRegion(auraRegion, event, unit)
    local state = auraRegion.blizzardAuraDisplay
    local triggerConfig = Display.GetTrigger(state.data)
    if not triggerConfig then return end
    local plateRefresh = plateRefreshes[event]
    if plateRefresh then
      if not Display.UsesNameplates(state.data) then return end
      if triggerConfig.unit == "nameplate" then
        plateRefresh(auraRegion, unit)
      else
        Units.Refresh(auraRegion)
      end
      return
    end
    if Events.WantsUnitUpdate(triggerConfig, event, unit) and not (queuedApplies[auraRegion] and not WeakAuras.IsRestricted()) then
      Units.Refresh(auraRegion)
    end
    if Events.WantsSounds(triggerConfig, event) then SyncSounds(auraRegion) end
  end

  local currentEvent, currentUnit
  local function DispatchEvent()
    local event, unit = currentEvent, currentUnit
    Display.BeginFlowBatch()
    xpcall(function()
      for auraRegion in pairs(liveRegions) do Events.HandleRegion(auraRegion, event, unit) end
    end, geterrorhandler())
    Display.EndFlowBatch()
  end

  local beforeDispatch = {
    NAME_PLATE_UNIT_ADDED = function(unit) Plates.Note(unit) end,
    PLAYER_ENTERING_WORLD = function() C_Timer.After(0, Plates.ReadShown) end,
  }
  local rescaleEvents = { UI_SCALE_CHANGED = true, DISPLAY_SIZE_CHANGED = true }
  local afterDispatch = {
    PLAYER_REGEN_ENABLED = function() Units.ReplayLocked() end,
  }
  local conditionRefreshEvents = {
    PLAYER_REGEN_ENABLED = true, ADDON_RESTRICTION_STATE_CHANGED = true, PLAYER_ENTERING_WORLD = true,
  }

  function Events.OnMainEvent(_, event, unit)
    local prepare = beforeDispatch[event]
    if prepare then prepare(unit) end
    if rescaleEvents[event] then
      for auraRegion in pairs(liveRegions) do Display.Apply(auraRegion, auraRegion.blizzardAuraDisplay.data) end
      return
    end
    currentEvent, currentUnit = event, unit
    DispatchEvent()
    local replay = afterDispatch[event]
    if replay then replay() end
    if WeakAuras.IsRestricted() then return end
    if conditionRefreshEvents[event] then
      for auraRegion in pairs(liveRegions) do Display.RefreshConditionAppearance(auraRegion) end
    end
    FlushPendingSounds()
    Queues.StartApplies()
  end

  local statusUnit
  local function HandleStatusChange() Units.OnStatusChange(statusUnit) end

  function Events.OnStatusEvent(_, _, unit)
    statusUnit = unit
    Display.BeginFlowBatch()
    local ok, message = xpcall(HandleStatusChange, geterrorhandler())
    Display.EndFlowBatch()
    return ok, message
  end

  local mainFrame = CreateFrame("Frame")
  for _, event in ipairs({
    "PLAYER_REGEN_ENABLED", "ADDON_RESTRICTION_STATE_CHANGED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
    "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED",
    "UPDATE_MOUSEOVER_UNIT", "UNIT_TARGET", "UNIT_PET", "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
    "ARENA_OPPONENT_UPDATE", "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "UNIT_NAME_UPDATE",
    "PLAYER_ROLES_ASSIGNED",
  }) do
    pcall(mainFrame.RegisterEvent, mainFrame, event)
  end
  mainFrame:SetScript("OnEvent", Events.OnMainEvent)

  local statusFrame = CreateFrame("Frame")
  for _, event in ipairs({ "UNIT_HEALTH", "UNIT_FLAGS", "UNIT_CONNECTION" }) do
    pcall(statusFrame.RegisterEvent, statusFrame, event)
  end
  statusFrame:SetScript("OnEvent", Events.OnStatusEvent)
end

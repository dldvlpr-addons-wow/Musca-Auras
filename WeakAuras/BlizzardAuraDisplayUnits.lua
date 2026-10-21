-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared

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
    local name = Private.ExecEnv.UnitName(token)
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

Shared.GrowNameplateTokens = GrowNameplateTokens
Shared.InPreview = InPreview
Shared.IsSecretAuraTrigger = IsSecretAuraTrigger
Shared.Join = Join
Shared.Listed = Listed
Shared.SlotCount = SlotCount
Shared.TriggerEntries = TriggerEntries
Shared.nameplateTokens = nameplateTokens

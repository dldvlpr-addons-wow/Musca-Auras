-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Talent tree data from talentsforever.com (https://talentsforever.com/data.json, generated 2026-10-13),
-- licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Changed: final talent of each of the
-- 27 trees and its beta spell IDs only. See SpecializationData-LICENSE.txt.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local specializations = {
  {"WARRIOR_ARMS", "WARRIOR", "Arms", "ability_rogue_eviscerate", {12294, 21551, 21552, 21553}},
  {"WARRIOR_FURY", "WARRIOR", "Fury", "ability_warrior_innerrage", {23881, 23892, 23893, 23894}},
  {"WARRIOR_PROTECTION", "WARRIOR", "Protection", "inv_shield_06", {23922, 23923, 23924, 23925}},
  {"PALADIN_HOLY", "PALADIN", "Holy", "spell_holy_holybolt", {1310911, 1311590, 1311595}},
  {"PALADIN_PROTECTION", "PALADIN", "Protection", "spell_holy_devotionaura", {20925, 20927, 20928}},
  {"PALADIN_RETRIBUTION", "PALADIN", "Retribution", "spell_holy_auraoflight", {1310735}},
  {"HUNTER_BEAST_MASTERY", "HUNTER", "Beast Mastery", "ability_hunter_beasttaming", {19574}},
  {"HUNTER_MARKSMANSHIP", "HUNTER", "Marksmanship", "ability_marksmanship", {1310687, 1310785, 1310786}},
  {"HUNTER_SURVIVAL", "HUNTER", "Survival", "ability_hunter_swiftstrike", {1310533}},
  {"ROGUE_ASSASSINATION", "ROGUE", "Assassination", "ability_rogue_eviscerate", {1310703}},
  {"ROGUE_COMBAT", "ROGUE", "Combat", "ability_backstab", {13750}},
  {"ROGUE_SUBTLETY", "ROGUE", "Subtlety", "ability_stealth", {1310721}},
  {"PRIEST_DISCIPLINE", "PRIEST", "Discipline", "spell_holy_wordfortitude", {10060}},
  {"PRIEST_HOLY", "PRIEST", "Holy", "spell_holy_guardianspirit", {401859, 1240826, 1240827}},
  {"PRIEST_SHADOW", "PRIEST", "Shadow", "spell_shadow_shadowwordpain", {15473}},
  {"SHAMAN_ELEMENTAL", "SHAMAN", "Elemental", "spell_nature_lightning", {408490, 1238299, 1238300}},
  {"SHAMAN_ENHANCEMENT", "SHAMAN", "Enhancement", "spell_nature_lightningshield", {425336}},
  {"SHAMAN_RESTORATION", "SHAMAN", "Restoration", "spell_nature_magicimmunity", {408521, 1239242, 1239243}},
  {"MAGE_ARCANE", "MAGE", "Arcane", "spell_holy_magicalsentry", {12042}},
  {"MAGE_FIRE", "MAGE", "Fire", "spell_fire_firebolt02", {11129}},
  {"MAGE_FROST", "MAGE", "Frost", "spell_frost_frostbolt02", {11426, 13031, 13032, 13033}},
  {"WARLOCK_AFFLICTION", "WARLOCK", "Affliction", "spell_shadow_deathcoil", {1316697}},
  {"WARLOCK_DEMONOLOGY", "WARLOCK", "Demonology", "spell_shadow_metamorphosis", {425464}},
  {"WARLOCK_DESTRUCTION", "WARLOCK", "Destruction", "spell_shadow_rainoffire", {412758, 1293812, 1293813}},
  {"DRUID_BALANCE", "DRUID", "Balance", "spell_nature_starfall", {24858}},
  {"DRUID_FERAL_COMBAT", "DRUID", "Feral Combat", "ability_racial_bearform", {417141}},
  {"DRUID_RESTORATION", "DRUID", "Restoration", "spell_nature_healingtouch", {408120, 1238214, 1238215}},
}

local specByKey = {}

local function DisplayClassName(classToken)
  local names = LOCALIZED_CLASS_NAMES_MALE
  return names ~= nil and names[classToken] or classToken
end
Private.forever_spec_types = {}
Private.forever_specs_sorted = {}

do
  local treesSeen = {}
  for _, entry in ipairs(specializations) do
    local key, class, treeName, icon, spellIDs = unpack(entry)
    local className = DisplayClassName(class)
    -- Tree order inside a class matches the game's orderIndex (0, 1, 2).
    local treeIndex = treesSeen[class] or 0
    treesSeen[class] = treeIndex + 1
    specByKey[key] = { class = class, treeIndex = treeIndex, spellIDs = spellIDs }
    Private.forever_spec_types[key] = string.format("|TInterface\\Icons\\%s:0|t %s - %s", icon, className, treeName)
    table.insert(Private.forever_specs_sorted, key)
  end
end

-- First spell-known API present, in order of preference.
local function SpellKnownApi()
  local candidates = { C_SpellBook and C_SpellBook.IsSpellKnown, IsPlayerSpell, IsSpellKnown }
  for index = 1, 3 do
    if candidates[index] then
      return candidates[index]
    end
  end
end

-- Only a readable, strict true counts; errors and secrets count as unknown.
local function KnowsAnySpell(spellIDs)
  local api = SpellKnownApi()
  for _, spellID in ipairs(api and spellIDs or {}) do
    local ok, answer = pcall(api, spellID)
    if ok and not Private.IsSecret(answer) and answer == true then
      return true
    end
  end
  return false
end

local function ReadTreePoints()
  local configID = C_SpecializationInfo.GetCombatConfigIDForSpecGroup(C_SpecializationInfo.GetActiveSpecGroup())
  if not configID then
    return
  end
  local treeIDs = (C_Traits.GetConfigInfo(configID) or {}).treeIDs
  local treeID = treeIDs and treeIDs[1]
  if not treeID then
    return
  end
  local pointsByTree, treeByGroup, groupIDs = {}, {}, {}
  for _, group in ipairs(C_Traits.GetGroupDisplayInfoByTreeID(treeID) or {}) do
    if Private.IsSecret(group.orderIndex) then
      return
    end
    treeByGroup[group.groupID] = group.orderIndex
    pointsByTree[group.orderIndex] = 0
    table.insert(groupIDs, group.groupID)
  end
  for _, currency in ipairs(C_Traits.GetGroupCurrencyInfo(configID, groupIDs) or {}) do
    local tree = treeByGroup[currency.traitNodeGroupID]
    local spent = tree and currency.currencyInfos and currency.currencyInfos[1] and currency.currencyInfos[1].spent
    if Private.IsSecret(spent) then
      return
    end
    if spent then
      pointsByTree[tree] = spent
    end
  end
  return next(pointsByTree) and pointsByTree
end

-- Forever only: these talent APIs do not exist on retail.
local function TreePoints()
  if not (C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup
          and C_Traits and C_Traits.GetGroupDisplayInfoByTreeID and C_Traits.GetGroupCurrencyInfo) then
    return
  end
  local ok, points = pcall(ReadTreePoints)
  return ok and points or nil
end

function Private.ExecEnv.IsForeverSpecialization(key)
  local spec = key and specByKey[key]
  if not spec then
    return false
  end
  local _, playerClass = UnitClass("player")
  if Private.IsSecret(playerClass) or playerClass ~= spec.class then
    return false
  end
  local points = TreePoints()
  local mostSpent = 0
  for _, spent in pairs(points or {}) do
    mostSpent = math.max(mostSpent, spent)
  end
  if mostSpent > 0 then
    return points[spec.treeIndex] == mostSpent
  end
  return KnowsAnySpell(spec.spellIDs)
end

-- Talent tree data from talentsforever.com (https://talentsforever.com/data.json, generated 2026-10-13),
-- licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Changed: final talent of each of the
-- 27 trees and its beta spell IDs only. See SpecializationData-LICENSE.txt.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

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

Private.forever_spec_types = {}
Private.forever_specs_sorted = {}
local byKey = {}
local treeOrder = {}
local treesPerClass = {}
for _, entry in ipairs(specializations) do
  local key, class, name, icon = entry[1], entry[2], entry[3], entry[4]
  byKey[key] = entry
  treeOrder[key] = treesPerClass[class] or 0
  treesPerClass[class] = treeOrder[key] + 1
  local className = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class] or class
  Private.forever_spec_types[key] = "|TInterface\\Icons\\" .. icon .. ":0|t " .. className .. " - " .. name
  Private.forever_specs_sorted[#Private.forever_specs_sorted + 1] = key
end

local function KnownByPlayer(spellID)
  local api = C_SpellBook and C_SpellBook.IsSpellKnown or IsPlayerSpell or IsSpellKnown
  if not api then
    return false
  end
  local ok, known = pcall(api, spellID)
  if not ok or Private.IsSecret(known) then
    return false
  end
  return known == true
end

local function ReadPointsByTree()
  local specInfo = C_SpecializationInfo
  local configID = specInfo.GetCombatConfigIDForSpecGroup(specInfo.GetActiveSpecGroup())
  local config = configID and C_Traits.GetConfigInfo(configID)
  local treeID = config and config.treeIDs and config.treeIDs[1]
  if not treeID then
    return nil
  end
  local groups = C_Traits.GetGroupDisplayInfoByTreeID(treeID) or {}
  local groupIDs = {}
  for index, group in ipairs(groups) do
    groupIDs[index] = group.groupID
  end
  local spentByGroup = {}
  for _, currency in ipairs(C_Traits.GetGroupCurrencyInfo(configID, groupIDs) or {}) do
    local info = currency.currencyInfos and currency.currencyInfos[1]
    if info then
      spentByGroup[currency.traitNodeGroupID] = info.spent
    end
  end
  local points = {}
  for _, group in ipairs(groups) do
    local spent = spentByGroup[group.groupID] or 0
    if Private.IsSecret(spent) or Private.IsSecret(group.orderIndex) then
      return nil
    end
    points[group.orderIndex] = spent
  end
  return next(points) and points or nil
end

local function PointsByTree()
  if not (C_Traits and C_Traits.GetGroupCurrencyInfo and C_Traits.GetGroupDisplayInfoByTreeID
          and C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup) then
    return nil
  end
  local ok, points = pcall(ReadPointsByTree)
  return ok and points or nil
end

function Private.ExecEnv.IsForeverSpecialization(key)
  local entry = byKey[key]
  if not entry then
    return false
  end
  local _, class = UnitClass("player")
  if Private.IsSecret(class) or class ~= entry[2] then
    return false
  end
  local points = PointsByTree()
  if points then
    local most = 0
    for _, spent in pairs(points) do
      most = math.max(most, spent)
    end
    if most > 0 then
      return points[treeOrder[key]] == most
    end
  end
  for _, spellID in ipairs(entry[5]) do
    if KnownByPlayer(spellID) then
      return true
    end
  end
  return false
end

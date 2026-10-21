-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = {}
Private.BlizzardAuraDisplay = Display
local Anchor = Private.AuraAnchor
local Shared = {}
Private.AuraDisplayShared = Shared

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

Shared.classificationFlags = classificationFlags
Shared.nativeFilterKeys = nativeFilterKeys

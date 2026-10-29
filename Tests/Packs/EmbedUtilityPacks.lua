-- usage: lua Tests/Packs/EmbedUtilityPacks.lua > WeakAurasOptions/UtilityPacks.lua
-- Shown in this order on the Packs page, under a title each time the category changes; name, description and
-- category are locale keys.
local packs = {
  { "ReadyFlash", "Ready Flash", "Flashes a cooldown, a racial or a trinket the moment it is ready",
    "Interface\\Icons\\INV_Misc_PocketWatch_01", "Combat" },
  { "CombatText", "Combat Text",
    "Hits and heals you take stack up beside you; turns on the game's damage numbers for the damage you deal",
    "Interface\\Icons\\Ability_Warrior_BattleShout", "Combat" },
  { "CombatItems", "Combat Items", "Potions, stones and explosives in your bags with their cooldown, in combat",
    "Interface\\Icons\\INV_Potion_54", "Combat" },
  { "EngineeringItems", "Engineering Items", "Cloaking device and rocket boots while equipped, grey on cooldown",
    "Interface\\Icons\\INV_Gizmo_RocketBoot_01", "Combat" },
  { "ShieldMeter", "Shield Meter", "Damage shields on you with their remaining time",
    "Interface\\Icons\\Spell_Holy_PowerWordShield", "Combat" },
  { "CenterMark", "Center Mark", "A dot at the center of the screen in combat",
    "Interface\\Icons\\Spell_Holy_MindVision", "Combat" },
  { "BuffCheck", "Buff Check", "Group buffs on you out of combat, missing ones in grey",
    "Interface\\Icons\\Spell_Holy_WordFortitude", "Group and Buffs" },
  { "RaidCoverage", "Raid Coverage", "How many group members carry each raid buff, out of combat",
    "Interface\\Icons\\Spell_Holy_PrayerOfFortitude", "Group and Buffs" },
  { "PrePullCheck", "Pre-Pull Check", "Flask and food missing or fading before the pull",
    "Interface\\Icons\\INV_Potion_62", "Group and Buffs" },
  { "ConjuredSupplies", "Conjured Supplies",
    "Mage only: conjured water and food in your bags with their count, out of combat",
    "Interface\\Icons\\INV_Drink_18", "Group and Buffs" },
  { "Announcements", "Announcements",
    "Tells your group about your battle rez, soulstone and summon, and whispers the rezzed player",
    "Interface\\Icons\\Spell_Nature_Reincarnation", "Group and Buffs" },
  { "TargetDebuffs", "Target Debuffs", "Raid debuffs on your target in combat, missing ones in grey",
    "Interface\\Icons\\Ability_Warrior_Sunder", "Target and Enemies" },
  { "NameplateAggro", "Nameplate Aggro", "Your threat percent above each enemy nameplate",
    "Interface\\Icons\\Spell_Nature_Reincarnation", "Target and Enemies" },
  { "CrowdControl", "Crowd Control", "Crowd control on each enemy nameplate with its countdown",
    "Interface\\Icons\\Spell_Nature_Polymorph", "Target and Enemies" },
  { "ArmorShred", "Armor Shred", "Sunder Armor and Expose Armor under each enemy nameplate",
    "Interface\\Icons\\Ability_Warrior_Riposte", "Target and Enemies" },
  { "EnemyTargets", "Enemy Targets", "The target of each enemy above its nameplate, in combat",
    "Interface\\Icons\\Ability_Hunter_SniperShot", "Target and Enemies" },
  { "LevelProgress", "Level Progress", "Experience bar with rested experience below level 60",
    "Interface\\Icons\\INV_Misc_Book_11", "Character" },
  { "CharacterStats", "Character Stats",
    "Strength, agility, stamina, intellect, spirit, attack and spell power, crit, dodge and armor, out of combat",
    "Interface\\Icons\\INV_Misc_Note_01", "Character" },
  { "GroupExperience", "Group Experience",
    "Level and experience of the group members who also run this pack",
    "Interface\\Icons\\INV_Misc_Book_09", "Character" },
  { "EquipmentSets", "Equipment Sets", "One icon per equipment set, grey when not worn; click to equip, out of combat",
    "Interface\\Icons\\INV_Chest_Chain_04", "Character" },
  { "WorldReminders", "World Reminders",
    "Leyline zone buffs missing or fading, and herb or mineral tracking off, out of combat",
    "Interface\\Icons\\Spell_Nature_Earthquake", "World" },
  { "Campfire", "Campfire",
    "Tells you to sit by a campfire while its buff is missing or fading, click to sit, with a sound when it comes in",
    "Interface\\Icons\\Spell_Fire_Fire", "World" },
  { "GuildCampfires", "Guild Campfires",
    "Shows where a guild member who runs this pack just placed a campfire on your map, and sends yours",
    "Interface\\Icons\\INV_Misc_Map_01", "World" },
  { "ObjectHighlight", "Object Highlight",
    "Turns on the game's interaction icons over herbs, veins and chests; they stay on after removing the pack",
    "Interface\\Icons\\INV_Misc_Spyglass_02", "World" },
}
io.write("if not WeakAuras.IsLibsOK() then return end\n")
io.write("---@class OptionsPrivate\nlocal OptionsPrivate = select(2, ...)\n\n")
io.write("OptionsPrivate.utilityPacks = {\n")
for _, pack in ipairs(packs) do
  local folder = pack[1]
  local file = assert(io.open("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".txt", "rb"))
  local text = file:read("*a"):gsub("%s+$", "")
  file:close()
  io.write(("  { name = %q, description = %q, category = %q,\n    icon = %q,\n    data = %q },\n")
    :format(pack[2], pack[3], pack[5], pack[4], text))
end
io.write("}\n")

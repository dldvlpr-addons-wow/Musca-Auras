local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- How many group members carry each raid buff, out of combat, in a group: "members with it/members". Auras read
-- clearly out of combat, so the classic group trigger counts the members.
local BUFFS = {
  { "Fortitude", "Spell_Holy_WordFortitude", { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 } },
  { "Mark of the Wild", "Spell_Nature_Regeneration", { 1126, 5232, 6756, 5234, 8907, 9884, 9885, 21849, 21850 } },
  { "Arcane Intellect", "Spell_Holy_MagicalSentry", { 1459, 1460, 1461, 10156, 10157, 23028 } },
  { "Divine Spirit", "Spell_Holy_DivineSpirit", { 14752, 14818, 14819, 27841, 27681 } },
  { "Shadow Protection", "Spell_Shadow_AntiShadow", { 976, 10957, 10958, 27683 } },
}

local pack = Utility.New("Raid Coverage", "muUtilRaidCoverageV1", { yOffset = 250 })

for _, buff in ipairs(BUFFS) do
  local trigger = { type = "aura2", unit = "group", debuffType = "HELPFUL", useExactSpellId = true,
    auraspellids = Parts.Ids(buff[3]), useGroup_count = true, group_count = "0", group_countOperator = ">=",
    matchesShowOn = "showAlways" }
  local data = pack.Icon(buff[1], { trigger }, { size = { 30, 30 }, outOfCombat = true, inGroup = true,
    texture = "Interface\\Icons\\" .. buff[2], subRegions = { Parts.Text("%unitCount/%maxUnitCount", "BOTTOM", 10) } })
  -- The buff icon stays shown when nobody carries the buff.
  data.iconSource = 0
end

return pack.Finish()

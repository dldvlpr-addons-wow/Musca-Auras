local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Group raid buffs on the player, out of combat: a missing buff stays grey, so the whole list reads at a glance.
-- Each list holds every rank and the group version of the buff.
local BUFFS = {
  { "Fortitude", { 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 } },
  { "Mark of the Wild", { 1126, 5232, 6756, 5234, 8907, 9884, 9885, 21849, 21850 } },
  { "Arcane Intellect", { 1459, 1460, 1461, 10156, 10157, 23028 } },
  { "Divine Spirit", { 14752, 14818, 14819, 27841, 27681 } },
  { "Shadow Protection", { 976, 10957, 10958, 27683 } },
  { "Blessing of Kings", { 20217, 25898 } },
  { "Blessing of Might", { 19740, 19834, 19835, 19836, 19837, 19838, 25291, 25782, 25916 } },
  { "Blessing of Wisdom", { 19742, 19850, 19852, 19853, 19854, 25290, 25894, 25918 } },
  { "Blessing of Salvation", { 1038, 25895 } },
  { "Blessing of Light", { 25890 } },
}

local pack = Utility.New("Buff Check", "muUtilBuffCheckV1", { grow = "GRID", gridType = "HD", gridWidth = 5,
  rowSpace = 2, columnSpace = 2, selfPoint = "TOP", useLimit = false, yOffset = 200 })

for _, buff in ipairs(BUFFS) do
  pack.Icon(buff[1], { Utility.AnyCaster(buff[2], "showAlways") },
    { size = { 30, 30 }, missing = true, countdown = true, outOfCombat = true, inGroup = true })
end

return pack.Finish()

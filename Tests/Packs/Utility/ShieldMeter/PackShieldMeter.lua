local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Damage shields on the player, from any caster, with their countdown. The absorb amount always reads secret: the
-- icons show which shields hold and for how long, not how much they still absorb.
local SHIELDS = {
  { "Power Word: Shield", { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 } },
  { "Ice Barrier", { 11426, 13031, 13032, 13033 } },
  { "Mana Shield", { 1463, 8494, 8495, 10191, 10192, 10193 } },
  { "Fire Ward", { 543, 8457, 8458, 10223, 10225 } },
  { "Frost Ward", { 6143, 8461, 8462, 10177, 28609 } },
  { "Shadow Ward", { 6229, 11739, 11740, 28610 } },
  { "Sacrifice", { 7812, 19438, 19440, 19441, 19442, 19443 } },
}

local pack = Utility.New("Shield Meter", "muUtilShieldMeterV1", { flow = "CENTER_HORIZONTAL", xOffset = -120,
  yOffset = -120 })

for _, shield in ipairs(SHIELDS) do
  pack.Icon(shield[1], { Utility.AnyCaster(shield[2], "showOnActive") }, { size = { 36, 36 }, countdown = true })
end

return pack.Finish()

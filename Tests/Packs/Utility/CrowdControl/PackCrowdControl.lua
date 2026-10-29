local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Crowd control on each enemy nameplate, from any caster, with its countdown: one icon per kind of control. The
-- group is framed on the default Blizzard nameplates.
local CONTROLS = {
  { "Stun", { 1833, 408, 8643, 853, 5588, 5589, 10308, 5211, 6798, 8983, 9005, 9823, 9827, 24394, 12809, 7922,
    20253, 20614, 20615, 20549, 5530, 19410, 12355, 15269 } },
  { "Incapacitate", { 118, 12824, 12825, 12826, 28270, 28271, 28272, 6770, 2070, 11297, 1776, 1777, 8629, 11285,
    11286, 2094, 2637, 18657, 18658, 3355, 14308, 14309, 19503, 19386, 24132, 24133, 20066, 9484, 9485, 10955, 710,
    18647, 6358 } },
  { "Fear", { 5782, 6213, 6215, 5484, 17928, 8122, 8124, 10888, 10890, 5246, 20511, 2878, 5627, 10326, 6789, 17925,
    17926 } },
  { "Root", { 339, 1062, 5195, 5196, 9852, 9853, 122, 865, 6131, 10230, 12494 } },
  { "Silence", { 15487, 18469 } },
}

local pack = Utility.New("Crowd Control", "muUtilCrowdControlV1", { flow = "CENTER_HORIZONTAL",
  blizzardFlowFrames = "NAMEPLATE", blizzardFlowUseLimit = true, blizzardFlowLimit = 3, anchorPoint = "TOP",
  selfPoint = "BOTTOM", yOffset = 18 })

for _, control in ipairs(CONTROLS) do
  pack.Icon(control[1], { Utility.AnyCaster(control[2], "showOnActive", "nameplate", "HARMFUL") },
    { size = { 24, 24 }, countdown = true })
end

return pack.Finish()

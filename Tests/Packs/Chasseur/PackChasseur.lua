local Pack = dofile("Tests/Packs/PackBuilder.lua")

local aspectOfTheHawk = { 13165, 14318, 14319, 14320, 14321, 14322, 25296 }
local trueshotAura = { 1299346, 1299348, 19506, 20905, 20906 }
local aspects = {
  13165, 14318, 14319, 14320, 14321, 14322, 25296, 13163, 5118, 13159,
  13161, 1299445, 1299446, 1299447, 20043, 20190, 415423, 469145,
}

return Pack.Build({
  class = "HUNTER", name = "Hunter", prefix = "mcHuntV1",
  rotation = {
    { name = "Aimed Shot", spell = 19434 },
    { name = "Multi-Shot", spell = 2643 },
    { name = "Arcane Shot", spell = 3044 },
    { name = "Concussive Shot", spell = 5116 },
    { name = "Sniper Shot", spell = 1310687 },
  },
  procs = {
    { name = "Raptor Strike", queued = 2973 },
    { name = "Mongoose Bite", usable = 1495, sound = true },
    { name = "Counterattack", usable = 19306, sound = true },
  },
  cooldowns = {
    { name = "Rapid Fire", spell = 3045 },
    { name = "Bestial Wrath", spell = 19574 },
    { name = "Intimidation", spell = 19577 },
    { name = "Feign Death", spell = 5384 },
    { name = "Freezing Trap", spell = 1499 },
    { name = "Frost Trap", spell = 13809 },
    { name = "Immolation Trap", spell = 13795 },
    { name = "Explosive Trap", spell = 13813 },
    { name = "Scatter Shot", spell = 19503 },
    { name = "Disengage", spell = 781 },
    { name = "Deterrence", spell = 19263 },
    { name = "Flare", spell = 1543 },
    { name = "Tranquilizing Shot", spell = 19801 },
    { name = "Distracting Shot", spell = 20736 },
    { name = "Strider Kick", spell = 1317257 },
    { name = "Summon Hawk", spell = 1293527 },
  },
  -- Deterrence up is in the Defensives icon, its cooldown above.
  defensives = { 19263 },
  buffs = {
    { name = "Rapid Fire (active)", aura = { 3045 } },
    { name = "Quick Shots", aura = { 6150 } },
    { name = "Aspect of the Hawk", aura = aspectOfTheHawk },
    { name = "Bestial Wrath (pet)", aura = { 19574 }, unit = "pet", known = 19574 },
    -- From any hunter's pet, not only the player's.
    { name = "Frenzy (pet)", aura = { 19615 }, unit = "pet", known = 19621, anyCaster = true },
  },
  debuffs = {
    { name = "Serpent Sting", aura = { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 }, dot = true },
    { name = "Hunter's Mark", aura = { 1130, 14323, 14324, 14325 } },
    { name = "Black Arrow", aura = { 3674, 14296 }, known = 3674 },
    { name = "Wing Clip", aura = { 2974, 14267, 14268 } },
    { name = "Concussive Shot", aura = { 5116 } },
    { name = "Scorpid Sting", aura = { 3043 } },
    { name = "Viper Sting", aura = { 3034, 14279, 14280 } },
    { name = "Freezing Trap", aura = { 3355, 14308, 14309 }, known = 1499 },
    { name = "Frost Trap", aura = { 13810 }, known = 13809 },
    { name = "Scatter Shot", aura = { 19503 }, known = 19503 },
    { name = "Intimidation", aura = { 24394 }, known = 19577 },
    { name = "Scare Beast", aura = { 1513, 14326, 14327 }, known = 1513 },
    { name = "Counterattack", aura = { 19306, 1242634, 20909, 20910 }, known = 19306 },
  },
  power = { { label = "Mana", type = 0 } },
  swing = { "ranged" },
  pet = true,
  fiveSecondRule = { 3044, 2643, 19434, 1978, 1130 },
  castBar = true,
  meleeRange = { { name = "Raptor Strike", spell = 2973, inside = true } },
  reminders = {
    { name = "Aspect", aura = aspects, known = 415423 },
    { name = "Pet", pet = true, known = 883 },
    { name = "Trueshot Aura", aura = trueshotAura, known = 1299346 },
    { name = "Ammo", ammo = true, below = 200, known = 75 },
    { name = "LOW MANA", lowPower = 0, below = 20 },
  },
})

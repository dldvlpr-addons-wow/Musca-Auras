local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- By a campfire, out of combat: sit down while its buff is missing or fading, see it warm up while seated, and a
-- sound when the buff comes in.
local NEAR, SEATED, WARMTH = 1283391, 1229739, 1229741
local FADING = 900
-- The buff lasts an hour: just gained means less than three seconds gone.
local JUST_GAINED = 3597
local SOUND = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\Empowered.ogg"

local pack = Utility.New("Campfire", "muUtilCampfireV1", { yOffset = 200 })

local function Options(text)
  return { size = { 40, 40 }, outOfCombat = true, all = true, subRegions = { Parts.Text(text, "BOTTOM", 10) } }
end

local function Warmth(operator)
  local trigger = Utility.AnyCaster({ WARMTH }, "showOnActive")
  trigger.secretUseRem, trigger.secretRemOperator, trigger.secretRem = true, operator, operator == "<" and FADING or JUST_GAINED
  return trigger
end

-- A second secret aura trigger stays shown whatever the aura: the extra requirements read the aura out of combat.
local function Guard(id, showOn)
  return { type = "aura2", unit = "player", debuffType = "HELPFUL", useExactSpellId = true,
    auraspellids = Parts.Ids({ id }), matchesShowOn = showOn }
end

-- Read out of combat, not as a secret aura: a click on it sits down, and a secret aura display runs no custom action.
local sitDown = pack.Icon("Sit Down", { Guard(NEAR, "showOnActive"), Guard(SEATED, "showOnMissing"),
  Guard(WARMTH, "showOnMissing") }, Options("Sit down"))
sitDown.actions.start = { do_custom = true, custom = [[aura_env.region:EnableMouse(true)
aura_env.region:SetScript("OnMouseUp", function()
  if not InCombatLockdown() then C_ChatInfo.PerformEmote("SIT") end
end)]] }
sitDown.actions.finish = { do_custom = true, custom = [[aura_env.region:EnableMouse(false)
aura_env.region:SetScript("OnMouseUp", nil)]] }
-- The remaining time filter of the buff needs it as the first trigger.
pack.Icon("Sit Down (Fading)", { Warmth("<"), Guard(NEAR, "showOnActive"), Guard(SEATED, "showOnMissing") },
  Options("Sit down"))
pack.Icon("Warming Up", { Utility.AnyCaster({ SEATED }, "showOnActive"), Guard(WARMTH, "showOnMissing") },
  Options("Warming up"))
local gained = pack.Icon("Buff Gained", { Warmth(">=") }, Options("Buff gained"))
gained.actions.start = { do_sound = true, sound = SOUND, sound_channel = "Master" }

return pack.Finish()

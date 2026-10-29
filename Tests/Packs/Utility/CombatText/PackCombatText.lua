local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Hits and heals you take, stacked up for 1.5 seconds: damage in red, heals in green, misses and dodges as a word.
-- Damage you deal goes to the game's own combat text, turned on out of combat when the pack loads.
local pack = Utility.New("Combat Text", "muUtilCombatTextV1", { grow = "UP", xOffset = 150, yOffset = 0 })

local UPDATE = [[function(allstates, event, unit, action, flagText, amount)
  local IsSecret = issecretvalue or function() return false end
  if event ~= "UNIT_COMBAT" or IsSecret(action) or IsSecret(amount) or IsSecret(flagText) then return false end
  if action == "ENERGIZE" then return false end
  local text
  if action == "WOUND" and amount and amount > 0 then
    text = "|cffff3030-" .. amount .. "|r"
  elseif action == "HEAL" and amount and amount > 0 then
    text = "|cff30ff30+" .. amount .. "|r"
  elseif action and action ~= "WOUND" and action ~= "HEAL" then
    text = action:sub(1, 1) .. action:sub(2):lower()
  end
  if not text then return false end
  if flagText == "CRITICAL" then text = text .. "!" end
  aura_env.count = (aura_env.count or 0) + 1
  allstates[aura_env.count] = { show = true, changed = true, name = text, progressType = "timed", duration = 1.5,
    expirationTime = GetTime() + 1.5, autoHide = true }
  return true
end]]

local trigger = { type = "custom", custom_type = "stateupdate", check = "event", events = "UNIT_COMBAT:player",
  custom = UPDATE }
local data = pack.Text("Incoming", { trigger }, "%n", { fontSize = 18 })
data.actions.init = { do_custom = true, custom = [[if not InCombatLockdown() then
  C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", "1")
end]] }

return pack.Finish()

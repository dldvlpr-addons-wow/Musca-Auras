local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Hits and heals you take, stacked up for 1.5 seconds: damage in red, heals in green, misses and dodges as a word.
-- Damage you deal goes to the game's own combat text, turned on out of combat when the pack loads.
local pack = Utility.New("Combat Text", "muUtilCombatTextV1", { grow = "UP", xOffset = 150, yOffset = 0 })

local UPDATE = [[function(allstates, event, unit, action, flagText, amount)
  local IsSecret = issecretvalue or function() return false end
  if event ~= "UNIT_COMBAT" or IsSecret(action) or IsSecret(flagText) then return false end
  if action == "ENERGIZE" then return false end
  local crit = flagText == "CRITICAL" and "!" or ""
  local text, secretText
  if action == "WOUND" and (flagText == "ABSORB" or flagText == "BLOCK" or flagText == "RESIST") then
    -- A hit fully absorbed, blocked or resisted: the game's own feedback shows the word, not the amount.
    text = flagText:sub(1, 1) .. flagText:sub(2):lower()
  elseif action == "WOUND" or action == "HEAL" then
    local prefix = action == "WOUND" and "|cffff3030-" or "|cff30ff30+"
    if IsSecret(amount) then
      -- The game keeps the amount secret: concatenation gives a secret string, %n shows it through secretName.
      secretText = prefix .. amount .. "|r" .. crit
    elseif amount and amount > 0 then
      text = prefix .. amount .. "|r" .. crit
    end
  elseif action then
    text = action:sub(1, 1) .. action:sub(2):lower() .. crit
  end
  if not text and not secretText then return false end
  aura_env.count = (aura_env.count or 0) + 1
  allstates[aura_env.count] = { show = true, changed = true, name = text, secretName = secretText,
    progressType = "timed", duration = 1.5, expirationTime = GetTime() + 1.5, autoHide = true }
  return true
end]]

local trigger = { type = "custom", custom_type = "stateupdate", check = "event", events = "UNIT_COMBAT:player",
  custom = UPDATE }
local data = pack.Text("Incoming", { trigger }, "%n", { fontSize = 18 })
data.actions.init = { do_custom = true, custom = [[if not InCombatLockdown() then
  C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", "1")
end]] }

return pack.Finish()

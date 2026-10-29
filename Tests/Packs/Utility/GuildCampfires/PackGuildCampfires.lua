local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- A guild member who places a campfire on your map shows where for 15 seconds; your own campfires are sent to the
-- guild. The message is "P;map;x;y;spell", read only when nothing in it is secret.
local pack = Utility.New("Guild Campfires", "muUtilGuildCampfiresV1", { yOffset = 260 })

local CAMPFIRE = [[function(event, ...)
  local IsSecret = issecretvalue or function() return false end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    local _, _, spellID = ...
    if IsSecret(spellID) or not aura_env.spells[spellID] or not IsInGuild() then return false end
    local map = C_Map.GetBestMapForUnit("player")
    local position = map and C_Map.GetPlayerMapPosition(map, "player")
    if not position then return false end
    local x, y = position:GetXY()
    if IsSecret(map) or IsSecret(x) or IsSecret(y) then return false end
    C_ChatInfo.SendAddonMessage(aura_env.prefix, ("P;%d;%.4f;%.4f;%d"):format(map, x, y, spellID), "GUILD")
    return false
  end
  local prefix, text, channel, sender = ...
  if IsSecret(prefix) or IsSecret(text) or IsSecret(channel) or IsSecret(sender) then return false end
  if prefix ~= aura_env.prefix or channel ~= "GUILD" or not sender then return false end
  local name = Ambiguate(sender, "none")
  if name == UnitName("player") then return false end
  local map, x, y, spellID = text:match("^P;(%d+);([%d.]+);([%d.]+);(%d+)$")
  map, x, y, spellID = tonumber(map), tonumber(x), tonumber(y), tonumber(spellID)
  if not spellID or not aura_env.spells[spellID] or map ~= C_Map.GetBestMapForUnit("player") then return false end
  local spell = C_Spell.GetSpellInfo(spellID)
  aura_env.text = ("%s placed %s at %.0f, %.0f"):format(name, spell and spell.name or "a campfire", x * 100, y * 100)
  aura_env.icon = spell and spell.iconID
  return true
end]]

local trigger = { type = "custom", custom_type = "event", custom_hide = "timed", duration = "15",
  events = "UNIT_SPELLCAST_SUCCEEDED:player CHAT_MSG_ADDON", custom = CAMPFIRE,
  customName = "function() return aura_env.text end", customIcon = "function() return aura_env.icon end" }
local data = pack.Text("Placed", { trigger }, "%n", { fontSize = 14, color = {1, 0.82, 0, 1} })
data.actions.init = { do_custom = true, custom = [[aura_env.prefix = "MuscaCamp"
C_ChatInfo.RegisterAddonMessagePrefix(aura_env.prefix)
aura_env.spells = { [279982] = true, [279974] = true, [279961] = true, [279981] = true }]] }

return pack.Finish()

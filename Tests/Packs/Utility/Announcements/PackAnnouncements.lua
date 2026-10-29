local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Tells the group when a battle rez, a soulstone or a summon goes out, and whispers the rezzed player. Nothing is
-- shown: each aura only carries the chat message. The target named at the cast start is kept by cast GUID, with
-- the current target as a fallback; a secret value or a chat lockdown skips the message.
local pack = Utility.New("Announcements", "muUtilAnnouncementsV1", {})

local CAST = [[function(event, unit, ...)
  local IsSecret = issecretvalue or function() return false end
  if event == "UNIT_SPELLCAST_SENT" then
    local target, castGUID, spellID = ...
    if IsSecret(target) or IsSecret(castGUID) or IsSecret(spellID) or not aura_env.spells[spellID] then return false end
    aura_env.targets[castGUID] = target
    return false
  end
  local castGUID, spellID = ...
  if IsSecret(castGUID) or IsSecret(spellID) or not aura_env.spells[spellID] then return false end
  local target = aura_env.targets[castGUID]
  aura_env.targets[castGUID] = nil
  if not target or target == "" then target = UnitName("target") end
  if not target or IsSecret(target) then return false end
  if C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then return false end
  if aura_env.notSelf and target == UnitName("player") then return false end
  aura_env.target = target
  return true
end]]

local function Announce(label, class, ids, message, whisper)
  local trigger = { type = "custom", custom_type = "event", custom_hide = "timed", duration = "1",
    events = "UNIT_SPELLCAST_SENT:player UNIT_SPELLCAST_SUCCEEDED:player", custom = CAST,
    customName = "function() return aura_env.target end" }
  local data = pack.Text(label, { trigger }, "", { class = class, inGroup = true })
  data.actions.init = { do_custom = true, custom = ("aura_env.spells = { [%s] = true }\naura_env.targets = {}%s")
    :format(table.concat(ids, "] = true, ["), whisper and "\naura_env.notSelf = true" or "") }
  data.actions.start = whisper and { do_message = true, message_type = "WHISPER", message_dest = "%n", message = message }
    or { do_message = true, message_type = "SMARTRAID", message = message }
end

local REBIRTH, SOULSTONE, SUMMON = { 20484, 20739, 20742, 20747, 20748 }, { 20707, 20762, 20763, 20764, 20765 }, { 698 }
Announce("Rebirth", "DRUID", REBIRTH, "%n battle rezzed!")
Announce("Rebirth Whisper", "DRUID", REBIRTH, "You have been battle rezzed!", true)
Announce("Soulstone", "WARLOCK", SOULSTONE, "%n is Soulstoned!")
Announce("Summon", "WARLOCK", SUMMON, "Summoning %n")

return pack.Finish()

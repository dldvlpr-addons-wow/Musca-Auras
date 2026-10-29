local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")

-- Level and experience of each group member who runs this pack, "?" for the others. Each member sends
-- "X;level;xp;max" to the group, at most every 2 seconds, and asks the others with "Q" when the group changes.
local pack = Utility.New("Group Experience", "muUtilGroupExperienceV1", { anchorPoint = "LEFT", selfPoint = "LEFT",
  xOffset = 20, yOffset = 100 })

local INIT = [[local env = aura_env
env.prefix = "MuscaXP"
C_ChatInfo.RegisterAddonMessagePrefix(env.prefix)
env.members, env.last = {}, 0
env.Send = function(text)
  local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID"
    or IsInGroup() and "PARTY"
  if channel then C_ChatInfo.SendAddonMessage(env.prefix, text, channel) end
end
env.SendMine = function()
  if env.pending then return end
  local wait = env.last + 2 - GetTime()
  if wait > 0 then
    env.pending = true
    C_Timer.After(wait, function() env.pending = nil env.SendMine() end)
    return
  end
  env.last = GetTime()
  env.Send(("X;%d;%d;%d"):format(UnitLevel("player"), UnitXP("player"), UnitXPMax("player")))
end]]

local UPDATE = [[function(allstates, event, ...)
  local env = aura_env
  local IsSecret = issecretvalue or function() return false end
  if event == "CHAT_MSG_ADDON" then
    local prefix, text, _, sender = ...
    if IsSecret(prefix) or IsSecret(text) or IsSecret(sender) or prefix ~= env.prefix or not sender then return false end
    if text == "Q" then
      env.SendMine()
      return false
    end
    local level, xp, max = text:match("^X;(%d+);(%d+);(%d+)$")
    if not level then return false end
    -- Keyed like UnitName(unit), which drops the realm.
    env.members[Ambiguate(sender, "short")] = { tonumber(level), tonumber(xp), tonumber(max) }
  elseif event == "GROUP_ROSTER_UPDATE" then
    -- The roster event comes in bursts while a raid forms: one query every 2 seconds at most.
    if GetTime() - (env.lastQuery or 0) >= 2 then
      env.lastQuery = GetTime()
      env.Send("Q")
    end
    env.SendMine()
  elseif event ~= "OPTIONS" then
    env.SendMine()
  end
  local units = { "player" }
  local raid = IsInRaid()
  for index = 1, raid and 40 or 4 do units[#units + 1] = (raid and "raid" or "party") .. index end
  local lines, mine = {}, UnitName("player")
  for _, unit in ipairs(units) do
    local name = UnitExists(unit) and UnitName(unit)
    if name and not IsSecret(name) and (unit == "player" or name ~= mine) then
      local entry = unit == "player" and { UnitLevel("player"), UnitXP("player"), UnitXPMax("player") }
        or env.members[name]
      if entry and entry[3] > 0 then
        local xp, max = entry[2], entry[3]
        lines[#lines + 1] = ("%s %d  %.1fk/%.1fk (%d%%)"):format(name, entry[1], xp / 1000, max / 1000,
          math.floor(xp / max * 100))
      else
        lines[#lines + 1] = name .. " ?"
      end
    end
  end
  allstates[""] = { show = true, changed = true, name = table.concat(lines, "\n") }
  return true
end]]

local trigger = { type = "custom", custom_type = "stateupdate", check = "event", custom = UPDATE,
  events = "PLAYER_XP_UPDATE PLAYER_LEVEL_UP GROUP_ROSTER_UPDATE PLAYER_ENTERING_WORLD CHAT_MSG_ADDON" }
local data = pack.Text("Members", { trigger }, "%n", { inGroup = true, fontSize = 12 })
data.justify = "LEFT"
data.actions.init = { do_custom = true, custom = INIT }

return pack.Finish()

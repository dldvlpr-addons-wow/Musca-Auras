-- The utility packs of the Packs page: each pack imports cleanly (unique uids and ids across every pack,
-- parents present, secret auras accepted by the native checks), the embedded strings match the encoded packs, and
-- every name, description and category shown on the page has an enUS and a frFR string.
local folders = { "ReadyFlash", "CombatText", "CombatItems", "EngineeringItems", "ShieldMeter", "CenterMark",
  "BuffCheck", "RaidCoverage", "PrePullCheck", "ConjuredSupplies", "Announcements", "TargetDebuffs", "NameplateAggro",
  "CrowdControl", "ArmorShred", "EnemyTargets", "LevelProgress", "CharacterStats", "GroupExperience", "EquipmentSets",
  "WorldReminders", "Campfire", "GuildCampfires", "ObjectHighlight" }

local function ReadFile(path)
  local file = assert(io.open(path, "rb"))
  local text = file:read("*a")
  file:close()
  return text
end

return function(test)
  -- Every pack installed at once: the bench reports any Lua error they raise while loading and running.
  local saved = { displays = {} }
  for _, folder in ipairs(folders) do
    local pack = dofile("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".lua")
    for _, data in ipairs({ pack.d, unpack(pack.c) }) do saved.displays[data.id] = data end
  end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  for id in pairs(saved.displays) do assert(WeakAuras.GetData(id), id .. " not installed") end
  -- The rested experience overlay is wired to the Level Progress trigger.
  local experience = WeakAuras.GetData("Level Progress - Experience").triggers[1].trigger
  assert(experience.use_showRested, "Level Progress: rested overlay off")
  -- Combat Text: a hit taken shows a red line, an energize shows nothing.
  WeakAuras.ScanUnitEvents("UNIT_COMBAT", "player", "WOUND", "CRITICAL", 120, 1)
  WeakAuras.ScanUnitEvents("UNIT_COMBAT", "player", "ENERGIZE", "", 10, 1)
  test.Environment.Advance(1)
  local lines = {}
  for _, state in pairs(WeakAuras.GetTriggerStateForTrigger("Combat Text - Incoming", 1)) do
    if state.show then lines[#lines + 1] = state.name end
  end
  assert(#lines == 1 and lines[1] == "|cffff3030-120|r!", "Combat Text: " .. table.concat(lines, ", "))
  local Display = private.BlizzardAuraDisplay
  -- The bench client has no filter parser: accept the filter strings the game takes, as VerificationPack.lua does.
  local savedValidFilter = AuraUtil.IsValidFilterString
  AuraUtil.IsValidFilterString = function(filter)
    return filter == "HELPFUL" or filter == "HARMFUL" or filter == "HELPFUL|PLAYER" or filter == "HARMFUL|PLAYER"
  end
  local problems, uids, ids, checked = {}, {}, {}, 0
  local function Problem(text) problems[#problems + 1] = text end

  for _, folder in ipairs(folders) do
    local pack = dofile("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".lua")
    local inPack = { [pack.d.id] = true }
    for _, data in ipairs({ pack.d, unpack(pack.c) }) do
      if uids[data.uid] then Problem(folder .. ": uid " .. data.uid .. " already used by " .. uids[data.uid]) end
      if ids[data.id] then Problem(folder .. ": id " .. data.id .. " already used") end
      uids[data.uid], ids[data.id], inPack[data.id] = data.id, true, true
    end
    for _, child in ipairs(pack.c) do
      if not inPack[child.parent] then Problem(child.id .. ": parent " .. tostring(child.parent) .. " missing") end
      local trigger = child.triggers[1].trigger
      if trigger.type == "secretAura" then
        checked = checked + 1
        -- Display.Validate is the check the game runs on the installed aura.
        local problem = Display.Validate(WeakAuras.GetData(child.id)) or Display.ValidateSingle(child, trigger)
          or Display.FlowProblem(child, trigger) or Display.ValidateConditions(child)
        if problem then Problem(child.id .. ": " .. problem) end
      end
      -- Only the first secret aura trigger is tested: a later one would never hide the aura.
      for index = 2, #child.triggers do
        if child.triggers[index].trigger.type == "secretAura" then
          Problem(child.id .. ": trigger " .. index .. " is a secret aura")
        end
      end
    end
  end
  AuraUtil.IsValidFilterString = savedValidFilter
  assert(checked > 0, "no secret aura checked")

  local env = { WeakAuras = { IsLibsOK = function() return true end }, select = select }
  local OptionsPrivate = {}
  local chunk = assert(loadfile("WeakAurasOptions/UtilityPacks.lua"))
  setfenv(chunk, env)(nil, OptionsPrivate)
  local embedded = assert(OptionsPrivate.utilityPacks, "OptionsPrivate.utilityPacks missing")
  assert(#embedded == #folders, #embedded .. " embedded packs, " .. #folders .. " expected")
  local enUS = ReadFile("WeakAurasOptions/Locales/enUS.lua")
  local frFR = ReadFile("WeakAurasOptions/Locales/frFR.lua")
  for index, folder in ipairs(folders) do
    local entry = embedded[index]
    local text = ReadFile("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".txt"):gsub("%s+$", "")
    if entry.data ~= text then Problem(folder .. ": UtilityPacks.lua is out of date, rerun EmbedUtilityPacks.lua") end
    assert(entry.category, folder .. ": category missing")
    for _, key in ipairs({ "Utility Packs", entry.name, entry.description, entry.category }) do
      local pattern = 'L["' .. key .. '"] = '
      if not enUS:find(pattern, 1, true) then Problem("enUS: missing " .. key) end
      if not frFR:find(pattern, 1, true) then Problem("frFR: missing " .. key) end
    end
  end
  assert(#problems == 0, #problems .. " utility pack problem(s):\n" .. table.concat(problems, "\n"))
end

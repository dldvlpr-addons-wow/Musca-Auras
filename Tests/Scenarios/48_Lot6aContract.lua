-- Contract of three parts rewritten in lot 6a, frozen against the previous code: the rank families of
-- SecretAuraRanks (part 1), the talent reader of Prototypes (part 2) and the head of BlizzardAuraDisplay (part 3).
-- Scenario 18 already covers Battle Shout, the identity of the families and the catalog order: not repeated here.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function Joined(list) return table.concat(list, ",") end

  ---------------------------------------------------------------------------------------------------------------
  -- Part 1: SecretAuraRanks
  ---------------------------------------------------------------------------------------------------------------
  do
    local families, catalog = private.AuraSpellFamilies, private.AuraSpellCatalogIDs
    for _, name in ipairs({ "AuraSpellFamilies", "AuraSpellCatalogIDs", "AuraSpellRankSupported", "GetAuraSpellRanks" }) do
      assert(private[name] ~= nil, "missing export " .. name)
    end
    Same(type(private.AuraSpellRankSupported), "function", "AuraSpellRankSupported type")
    Same(type(private.GetAuraSpellRanks), "function", "GetAuraSpellRanks type")
    Same(#families, 524, "family count")
    Same(#catalog, 1880, "catalog size")
    Same(catalog[1], 10, "smallest catalog ID")
    Same(catalog[#catalog], 1322605, "largest catalog ID")

    -- The whole content: rank order inside a family is checked, the order of the families is free.
    local hash, notAscending, firstNotSmallest, sized30, sized95 = 0, 0, 0, 0, 0
    for _, family in ipairs(families) do
      local ascending, smallest, familyHash = true, family[1], 0
      if #family == 30 then sized30 = sized30 + 1 end
      if #family == 95 then sized95 = sized95 + 1 end
      for index, id in ipairs(family) do
        familyHash = (familyHash * 31 + id) % 2147483629
        if index > 1 and id < family[index - 1] then ascending = false end
        if id < smallest then smallest = id end
      end
      hash = (hash + familyHash) % 2147483629
      if not ascending then notAscending = notAscending + 1 end
      if family[1] ~= smallest then firstNotSmallest = firstNotSmallest + 1 end
    end
    Same(hash, 1200180319, "checksum of the families (content, rank order)")
    Same(sized30, 1, "one family of 30 IDs (Drink)")
    Same(sized95, 1, "one family of 95 IDs (Food)")
    Same(notAscending, 24, "families not ascending")
    Same(firstNotSmallest, 19, "families whose first ID is not the smallest")

    -- Families whose order is the order of the ranks, not of the IDs.
    Same(Joined(private.GetAuraSpellRanks(1464)), "1240193,1464,8820,11604,11605", "Slam")
    Same(Joined(private.GetAuraSpellRanks(779)), "779,780,769,9754,9908", "family 53")
    Same(Joined(private.GetAuraSpellRanks(16827)), "16827,16828,16829,16830,16831,16832,3010,3009", "family 76")
    Same(Joined(private.GetAuraSpellRanks(20736)), "20736,14274,15629,15630,15631,15632", "family 86")
    Same(Joined(private.GetAuraSpellRanks(24604)), "24604,24605,24603,24597", "family 100")
    Same(Joined(private.GetAuraSpellRanks(8050)), "8050,8052,8053,10447,10448,29228", "Flame Shock")
    Same(private.GetAuraSpellRanks(5242), private.GetAuraSpellRanks(6673), "Battle Shout rank 2 shares the family")

    -- Families of one ID exist and are returned as such.
    local single = 0
    for _, family in ipairs(families) do if #family == 1 then single = single + 1 end end
    Same(single, 208, "families of one ID")

    -- Unknown IDs: a new {id} each call, never stored, whatever the value.
    for _, value in ipairs({ 0, -5, 1.5, 999999999, "abc" }) do
      local first, second = private.GetAuraSpellRanks(value), private.GetAuraSpellRanks(value)
      Same(#first, 1, "unknown " .. tostring(value) .. " length")
      Same(first[1], value, "unknown " .. tostring(value) .. " content")
      assert(first ~= second, "unknown table shared for " .. tostring(value))
      assert(not private.AuraSpellRankSupported(value), "unknown supported: " .. tostring(value))
    end
    Same(next(private.GetAuraSpellRanks(nil)), nil, "nil gives an empty table")
    assert(private.GetAuraSpellRanks(nil) ~= private.GetAuraSpellRanks(nil), "nil table shared")
    local appended = private.GetAuraSpellRanks(999999998)
    appended[2] = 1
    Same(#private.GetAuraSpellRanks(999999998), 1, "mutating an unknown result leaks")

    -- The membership test is a boolean, and strict.
    Same(private.AuraSpellRankSupported(8050), true, "supported is true")
    Same(private.AuraSpellRankSupported(999999999), false, "unsupported is false")
    Same(private.AuraSpellRankSupported(nil), false, "nil is false")

    -- The catalog holds exactly the IDs of the families.
    local seen = {}
    for _, id in ipairs(catalog) do seen[id] = true end
    for _, family in ipairs(families) do
      for _, id in ipairs(family) do assert(seen[id], "ID missing from the catalog: " .. id) end
    end
    -- Nothing else is published by the file.
    assert(WeakAuras.AuraSpellFamilies == nil and WeakAuras.GetAuraSpellRanks == nil, "ranks leaked to WeakAuras")
    assert(rawget(_G, "GetAuraSpellRanks") == nil, "ranks leaked to _G")
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Part 2: talent reader of TalentReader.lua (GetTalentConfigID, GetTalentData, CheckTalentsForLoad, talent frame).
  -- The harness already enables Private.traitTalents (Classic Era flavor with specializations and C_Traits), so the
  -- block is defined at load. The scenario only replaces the API tables after the load, which the code reads at
  -- call time: C_Traits, C_SpecializationInfo and the aliases of Private.ExecEnv.
  ---------------------------------------------------------------------------------------------------------------
  do
    Same(private.traitTalents, true, "traitTalents enabled by the harness")
    assert(type(private.GetTalentData) == "function" and type(private.GetTalentConfigID) == "function"
      and type(private.CheckTalentsForLoad) == "function", "talent functions missing")
    assert(type(WeakAuras.CheckTalentId) == "function" and type(WeakAuras.GetTalentById) == "function", "talent lookups missing")

    C_Traits = C_Traits or {}
    C_SpecializationInfo = C_SpecializationInfo or {}
    local saved = {
      traits = {}, specialization = {},
      execSpec = private.ExecEnv.GetSpecialization, execSpecInfo = private.ExecEnv.GetSpecializationInfo,
      getSpellInfo = private.ExecEnv.GetSpellInfo,
      scanForLoads = private.ScanForLoads, scanEvents = private.ScanEvents,
      startProfile = private.StartProfileSystem, stopProfile = private.StopProfileSystem,
    }
    local traitFunctions = { "GetConfigInfo", "GetTreeNodes", "GetNodeInfo", "GetEntryInfo", "GetDefinitionInfo", "GetSubTreeInfo" }
    for _, name in ipairs(traitFunctions) do saved.traits[name] = C_Traits[name] end
    for _, name in ipairs({ "GetActiveSpecGroup", "GetCombatConfigIDForSpecGroup", "GetSpecialization", "GetSpecializationInfo" }) do
      saved.specialization[name] = C_SpecializationInfo[name]
    end

    -- Simulated player: specialization index 2, id 1002, active group 3, combat config 77.
    local activeConfig, specIndex, specId, group = 77, 2, 1002, 3
    local configGroupAsked
    C_SpecializationInfo.GetActiveSpecGroup = function() return group end
    C_SpecializationInfo.GetCombatConfigIDForSpecGroup = function(asked)
      configGroupAsked = asked
      return activeConfig
    end
    local function GetSpecialization() return specIndex end
    local function GetSpecializationInfo(index) if index == specIndex then return specId end end
    C_SpecializationInfo.GetSpecialization, C_SpecializationInfo.GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
    private.ExecEnv.GetSpecialization, private.ExecEnv.GetSpecializationInfo = GetSpecialization, GetSpecializationInfo

    -- Simulated trees.
    local trees = { [7] = { 10, 11, 12, 0, 13, 14, 15, 99, 17, 20, 21, 23 }, [8] = { 30, 31 } }
    local nodes = {
      [10] = { ID = 10, entryIDs = { 100 }, visibleEdges = { { targetNode = 11 }, { targetNode = 12 }, { targetNode = 999 }, { targetNode = 17 } },
        posX = 2000, posY = 1000, maxRanks = 3, activeRank = 2 },
      [11] = { ID = 11, entryIDs = { 111, 110 }, visibleEdges = {}, posX = 1000, posY = 1000, maxRanks = 1, activeRank = 1,
        activeEntry = { entryID = 111, rank = 1 } },
      [12] = { ID = 12, entryIDs = { 120 }, visibleEdges = { { targetNode = 10 } }, posX = 1000, posY = 500, maxRanks = 1, activeRank = 0 },
      [0] = { ID = 0, entryIDs = { 900 }, visibleEdges = {}, posX = 1, posY = 1, maxRanks = 1, activeRank = 1 },
      [13] = { ID = 13, entryIDs = { 130 }, visibleEdges = {}, posX = 5, posY = 5, maxRanks = 1, activeRank = 1 },
      [14] = { ID = 14, entryIDs = { 140 }, visibleEdges = {}, posX = 6, posY = 6, maxRanks = 1, activeRank = 1 },
      [15] = { ID = 15, entryIDs = { 150 }, visibleEdges = {}, posX = 7, posY = 7, maxRanks = 1, activeRank = 1 },
      [17] = { ID = 17, entryIDs = {}, visibleEdges = {}, posX = 8, posY = 8, maxRanks = 1, activeRank = 0 },
      [20] = { ID = 20, entryIDs = { 200 }, visibleEdges = {}, posX = 3000, posY = 2000, maxRanks = 1, activeRank = 1, subTreeID = 701 },
      [21] = { ID = 21, entryIDs = { 210 }, visibleEdges = {}, posX = 3000, posY = 2500, maxRanks = 2, activeRank = 1, subTreeID = 702 },
      [23] = { ID = 23, entryIDs = { 230, 231 }, visibleEdges = {}, posX = 3500, posY = 2000, maxRanks = 1, activeRank = 1, subTreeID = 701,
        activeEntry = { entryID = 230, rank = 1 } },
      [30] = { ID = 30, entryIDs = { 300 }, visibleEdges = { { targetNode = 31 } }, posX = 100, posY = 100, maxRanks = 2, activeRank = 2 },
      [31] = { ID = 31, entryIDs = { 310 }, visibleEdges = {}, posX = 100, posY = 100, maxRanks = 1, activeRank = 0 },
    }
    local entries = {
      [100] = { definitionID = 1000 }, [110] = { definitionID = 1100 }, [111] = { definitionID = 1110 }, [120] = { definitionID = 1200 },
      [900] = { definitionID = 9000 }, [130] = {}, [140] = { definitionID = 1400 }, [200] = { definitionID = 2000 },
      [210] = { definitionID = 2100 }, [230] = { definitionID = 2300 }, [231] = { definitionID = 2310 },
      [300] = { definitionID = 3000 }, [310] = { definitionID = 3100 },
    }
    local definitions = {
      [1000] = { spellID = 5001 }, [1100] = { spellID = 5002 }, [1110] = { spellID = 5003 }, [1200] = { spellID = 5004 },
      [9000] = { spellID = 5900 }, [1400] = {}, [2000] = { spellID = 5020 }, [2100] = { spellID = 5021 },
      [2300] = { spellID = 5023 }, [2310] = { spellID = 5024 }, [3000] = { spellID = 5030 }, [3100] = { spellID = 5031 },
    }
    local subTrees = { [701] = { isActive = false }, [702] = { isActive = true } }
    local traitCalls = 0
    local function Counted(func)
      return function(...)
        traitCalls = traitCalls + 1
        return func(...)
      end
    end
    local function ConfigInfo(configId) if configId == 77 then return { treeIDs = { 7, 8 } } end end
    C_Traits.GetConfigInfo = Counted(ConfigInfo)
    C_Traits.GetTreeNodes = Counted(function(treeId) return trees[treeId] end)
    C_Traits.GetNodeInfo = Counted(function(configId, nodeId)
      assert(configId == 77, "config " .. tostring(configId))
      return nodes[nodeId]
    end)
    C_Traits.GetEntryInfo = Counted(function(configId, entryId)
      assert(configId == 77, "config " .. tostring(configId))
      return entries[entryId]
    end)
    C_Traits.GetDefinitionInfo = Counted(function(definitionId) return definitions[definitionId] end)
    C_Traits.GetSubTreeInfo = Counted(function(configId, subTreeId)
      assert(configId == 77, "config " .. tostring(configId))
      return subTrees[subTreeId]
    end)

    -- GetTalentConfigID: the combat config of the active specialization group.
    Same(private.GetTalentConfigID(), 77, "config ID")
    Same(configGroupAsked, 3, "config asked for the active group")
    activeConfig = nil
    Same(private.GetTalentConfigID(), nil, "no config")
    activeConfig = 77

    -- GetTalentData for the specialization of the player.
    local talents, hero, byNode = private.GetTalentData(1002)
    Same(type(talents), "table", "talents type")
    Same(next(hero), nil, "hero is empty")
    -- Sorted by posY, then posX, then entry ID. Entries without definition or spell are not returned.
    local order = {}
    for _, talent in ipairs(talents) do order[#order + 1] = talent[1] end
    Same(table.concat(order, ","), "300,310,120,110,111,100,200,230,231,210", "talent order")
    for key in pairs(talents) do assert(type(key) == "number" and key >= 1 and key <= 10, "extra key in talents: " .. tostring(key)) end
    local function Shape(talent)
      assert(#talent == 5, "talent has " .. #talent .. " fields")
      assert(#talent[3] == 4, "position has " .. #talent[3] .. " fields")
      return ("%s|%s|%s,%s,%s,%s|%s|%s"):format(talent[1], talent[2], talent[3][1], talent[3][2], talent[3][3], talent[3][4],
        table.concat(talent[4], ","), tostring(talent[5]))
    end
    Same(Shape(talents[1]), "300|5030|100,100,1,1|310|2", "talent 300")
    Same(Shape(talents[2]), "310|5031|100,100,1,1||1", "talent 310")
    Same(Shape(talents[3]), "120|5004|1000,500,1,1|100|1", "talent 120")
    -- A choice node: the entries share the position, the index is the position in the node.
    Same(Shape(talents[4]), "110|5002|1000,1000,2,2||1", "talent 110")
    Same(Shape(talents[5]), "111|5003|1000,1000,1,2||1", "talent 111")
    -- Edges: targets without node or without entry are ignored, the first entry of each target is listed.
    Same(Shape(talents[6]), "100|5001|2000,1000,1,1|111,120|3", "talent 100")
    Same(Shape(talents[7]), "200|5020|3000,2000,1,1||1", "talent 200 (inactive sub tree stays listed)")
    Same(Shape(talents[8]), "230|5023|3500,2000,1,2||1", "talent 230")
    Same(Shape(talents[9]), "231|5024|3500,2000,2,2||1", "talent 231")
    Same(Shape(talents[10]), "210|5021|3000,2500,1,1||2", "talent 210")
    -- byNode: node ID, then position in the node, the same table as in the list.
    Same(byNode[11][1], talents[5], "byNode node 11 index 1")
    Same(byNode[11][2], talents[4], "byNode node 11 index 2")
    Same(byNode[10][1], talents[6], "byNode node 10")
    Same(byNode[30][1], talents[1], "byNode node 30")
    for _, absent in ipairs({ 0, 13, 14, 15, 17, 99, 999, 1000 }) do
      Same(byNode[absent], nil, "byNode has no key for node " .. absent)
    end
    -- No cache: fresh tables at each call.
    local again, againHero, againByNode = private.GetTalentData(1002)
    assert(again ~= talents and againHero ~= hero and againByNode ~= byNode, "tables reused between calls")
    assert(again[1] ~= talents[1], "entries reused between calls")
    Same(Shape(again[6]), Shape(talents[6]), "stable result")

    -- Another specialization, or none: three empty tables, no query to C_Traits.
    local function AssertEmpty(label, a, b, c)
      assert(type(a) == "table" and type(b) == "table" and type(c) == "table", label .. ": tables expected")
      assert(next(a) == nil and next(b) == nil and next(c) == nil, label .. ": not empty")
      assert(a ~= b and b ~= c and a ~= c, label .. ": tables shared")
    end
    for _, asked in ipairs({ 1001, 0, "1002" }) do
      local before = traitCalls
      AssertEmpty("foreign spec " .. tostring(asked), private.GetTalentData(asked))
      Same(traitCalls, before, "foreign spec " .. tostring(asked) .. " queried C_Traits")
    end
    do
      local before = traitCalls
      AssertEmpty("nil spec", private.GetTalentData(nil))
      Same(traitCalls, before, "nil spec queried C_Traits")
    end
    specIndex = nil
    AssertEmpty("no specialization", private.GetTalentData(1002))
    specIndex = 2

    -- No config: three empty tables.
    activeConfig = nil
    AssertEmpty("no config", private.GetTalentData(1002))
    activeConfig = 77
    C_Traits.GetConfigInfo = Counted(function() return nil end)
    AssertEmpty("config info nil", private.GetTalentData(1002))
    C_Traits.GetConfigInfo = Counted(ConfigInfo)

    -- Sorting ties: same position order by entry ID, whatever the order of the entries in the node.
    nodes[11].entryIDs = { 110, 111 }
    do
      local sorted = private.GetTalentData(1002)
      local ids = {}
      for _, talent in ipairs(sorted) do ids[#ids + 1] = talent[1] end
      Same(table.concat(ids, ","), "300,310,120,110,111,100,200,230,231,210", "tie order does not depend on the node order")
    end
    nodes[11].entryIDs = { 111, 110 }

    -- The frame, its events and the chosen talents.
    local frame = private.frames["WeakAuras talentCheckFrame"]
    assert(frame, "talent frame missing")
    for _, event in ipairs({ "TRAIT_CONFIG_CREATED", "TRAIT_CONFIG_UPDATED", "PLAYER_TALENT_UPDATE", "PLAYER_SPECIALIZATION_CHANGED",
      "PLAYER_LOGIN", "ACTIVE_TALENT_GROUP_CHANGED", "ACTIVE_COMBAT_CONFIG_CHANGED" }) do
      assert(frame:IsEventRegistered(event), "talent frame does not listen to " .. event)
    end
    assert(not frame:IsEventRegistered("TRAIT_NODE_CHANGED") and not frame:IsEventRegistered("PLAYER_ENTERING_WORLD"),
      "talent frame listens to more")
    assert(type(frame:GetScript("OnEvent")) == "function", "talent frame has no handler")

    local CheckTalentId, GetTalentById = WeakAuras.CheckTalentId, WeakAuras.GetTalentById
    local log, profile = {}, {}
    private.ScanForLoads = function(...)
      log[#log + 1] = { "ScanForLoads", select("#", ...), (select(1, ...)), (select(2, ...)), CheckTalentId(100) }
    end
    private.ScanEvents = function(...)
      log[#log + 1] = { "ScanEvents", select("#", ...), (select(1, ...)), CheckTalentId(100) }
    end
    private.StartProfileSystem = function(name) profile[#profile + 1] = "start " .. tostring(name) end
    private.StopProfileSystem = function(name) profile[#profile + 1] = "stop " .. tostring(name) end
    private.ExecEnv.GetSpellInfo = function(spellId)
      return "Spell" .. tostring(spellId), nil, "icon" .. tostring(spellId)
    end

    local function Fire(event)
      log, profile = {}, {}
      frame:GetScript("OnEvent")(frame, event)
    end
    Fire("TRAIT_CONFIG_UPDATED")
    Same(#log, 2, "messages after an event")
    Same(log[1][1], "ScanForLoads", "first message")
    Same(log[1][3], nil, "ScanForLoads first argument")
    Same(log[1][4], "WA_TALENT_UPDATE", "ScanForLoads event")
    Same(log[1][5], true, "ScanForLoads sees the new talents")
    Same(log[2][1], "ScanEvents", "second message")
    Same(log[2][3], "WA_TALENT_UPDATE", "ScanEvents event")
    Same(log[2][4], true, "ScanEvents sees the new talents")
    Same(table.concat(profile, ","), "start talent,stop talent", "profiling")

    Same(CheckTalentId(100), true, "rank 2 node")
    do
      local name, icon, spellId, rank = GetTalentById(100)
      Same(name, "Spell5001", "GetTalentById name")
      Same(icon, "icon5001", "GetTalentById icon")
      Same(spellId, 5001, "GetTalentById spell")
      Same(rank, 2, "GetTalentById rank")
    end
    Same(CheckTalentId(120), false, "rank 0 node")
    Same(select(4, GetTalentById(120)), 0, "rank 0 reported")
    -- Choice node: only the active entry keeps the rank.
    Same(CheckTalentId(111), true, "active entry of a choice node")
    Same(select(4, GetTalentById(111)), 1, "active entry rank")
    Same(CheckTalentId(110), false, "other entry of a choice node")
    Same(select(4, GetTalentById(110)), 0, "other entry rank")
    -- Entry without definition, node of ID 0, missing node, entry info nil: absent.
    Same(CheckTalentId(130), nil, "entry without definition")
    Same(GetTalentById(130), nil, "entry without definition (name)")
    Same(CheckTalentId(900), nil, "node 0")
    Same(CheckTalentId(150), nil, "entry info nil")
    Same(CheckTalentId(424242), nil, "unknown talent")
    Same(GetTalentById(424242), nil, "unknown talent (name)")
    -- Definition without spell: kept (unlike GetTalentData).
    Same(CheckTalentId(140), true, "definition without spell is kept")
    -- Sub trees: an inactive sub tree zeroes the rank, even for the active entry of a choice node.
    Same(CheckTalentId(200), false, "inactive sub tree")
    Same(select(4, GetTalentById(200)), 0, "inactive sub tree rank")
    Same(select(3, GetTalentById(200)), 5020, "inactive sub tree spell")
    Same(CheckTalentId(230), false, "active entry of an inactive sub tree")
    Same(CheckTalentId(231), false, "other entry of an inactive sub tree")
    Same(CheckTalentId(210), true, "active sub tree")
    Same(select(4, GetTalentById(210)), 1, "active sub tree rank")
    subTrees[702] = nil
    Fire("TRAIT_CONFIG_UPDATED")
    Same(CheckTalentId(210), false, "sub tree without info is inactive")
    Same(select(4, GetTalentById(210)), 0, "sub tree without info rank")
    subTrees[702] = { isActive = true }
    Fire("TRAIT_CONFIG_UPDATED")
    Same(CheckTalentId(210), true, "sub tree info back")
    -- Second tree.
    Same(CheckTalentId(300), true, "second tree")
    Same(CheckTalentId(310), false, "second tree rank 0")

    -- The table is replaced in full, not merged.
    local node10 = nodes[10]
    nodes[10] = nil
    nodes[30].activeRank = 0
    Fire("PLAYER_SPECIALIZATION_CHANGED")
    Same(CheckTalentId(100), nil, "removed node forgotten")
    Same(log[1][5], nil, "the messages see the replaced table")
    Same(CheckTalentId(300), false, "rank updated")
    nodes[10] = node10
    nodes[10].activeRank = 3
    nodes[30].activeRank = 2

    -- Every one of the seven events does the same work.
    for _, event in ipairs({ "TRAIT_CONFIG_CREATED", "TRAIT_CONFIG_UPDATED", "PLAYER_TALENT_UPDATE", "PLAYER_SPECIALIZATION_CHANGED",
      "PLAYER_LOGIN", "ACTIVE_TALENT_GROUP_CHANGED", "ACTIVE_COMBAT_CONFIG_CHANGED" }) do
      Fire(event)
      Same(#log, 2, "messages for " .. event)
      Same(log[1][4], "WA_TALENT_UPDATE", "ScanForLoads for " .. event)
      Same(log[2][3], "WA_TALENT_UPDATE", "ScanEvents for " .. event)
      Same(select(4, GetTalentById(100)), 3, "rank read for " .. event)
      Same(table.concat(profile, ","), "start talent,stop talent", "profiling for " .. event)
    end

    -- No config: empty table, messages still sent. Config without info: same.
    activeConfig = nil
    Fire("PLAYER_TALENT_UPDATE")
    Same(#log, 2, "messages without config")
    Same(log[1][5], nil, "no talent known without config")
    Same(CheckTalentId(300), nil, "table emptied without config")
    Same(table.concat(profile, ","), "start talent,stop talent", "profiling without config")
    activeConfig = 77
    Fire("PLAYER_TALENT_UPDATE")
    Same(CheckTalentId(300), true, "table rebuilt")
    C_Traits.GetConfigInfo = Counted(function() return nil end)
    Fire("PLAYER_TALENT_UPDATE")
    Same(#log, 2, "messages without config info")
    Same(CheckTalentId(300), nil, "table emptied without config info")
    C_Traits.GetConfigInfo = Counted(ConfigInfo)

    -- Through the dispatch of the frame: one talent message.
    log = {}
    test.Frames.Fire("PLAYER_TALENT_UPDATE")
    local talentMessages = 0
    for _, entry in ipairs(log) do
      if entry[1] == "ScanForLoads" and entry[4] == "WA_TALENT_UPDATE" then talentMessages = talentMessages + 1 end
    end
    Same(talentMessages, 1, "frame dispatch gives one talent message")
    Same(CheckTalentId(300), true, "table rebuilt by the dispatch")

    -- Direct call, as after the delayed login: same messages, and nothing changes the table one second later.
    log, profile = {}, {}
    private.CheckTalentsForLoad()
    Same(#log, 2, "messages for the delayed call")
    Same(table.concat(profile, ","), "start talent,stop talent", "profiling for the delayed call")
    Same(CheckTalentId(300), true, "table rebuilt by the delayed call")
    test.Environment.Advance(1.5)
    Same(CheckTalentId(300), true, "table intact after the delay")

    -- Restore.
    for name, value in pairs(saved.traits) do C_Traits[name] = value end
    for name, value in pairs(saved.specialization) do C_SpecializationInfo[name] = value end
    private.ExecEnv.GetSpecialization, private.ExecEnv.GetSpecializationInfo = saved.execSpec, saved.execSpecInfo
    private.ExecEnv.GetSpellInfo = saved.getSpellInfo
    private.ScanForLoads, private.ScanEvents = saved.scanForLoads, saved.scanEvents
    private.StartProfileSystem, private.StopProfileSystem = saved.startProfile, saved.stopProfile
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Part 3: head of BlizzardAuraDisplay (tables, units, triggers, validation, migration, sounds, preview notice)
  ---------------------------------------------------------------------------------------------------------------
  do
    local Display = private.BlizzardAuraDisplay
    local Secret = test.Secret
    local function Keys(row) return row[1] end
    local function FirstColumn(rows)
      local list = {}
      for index, row in ipairs(rows) do list[index] = Keys(row) end
      return Joined(list)
    end
    local function SortedKeys(map)
      local list = {}
      for key in pairs(map) do list[#list + 1] = tostring(key) end
      table.sort(list)
      return Joined(list)
    end

    -- Exports.
    for _, name in ipairs({ "units", "booleanFilters", "dispelTypes", "nativeFilters", "sortMethods", "processedTypes",
      "processingOptions", "dynamicGroupWarning", "SpecificUnit", "UnitCategory", "GetSavedTrigger", "GetTrigger",
      "HasTrigger", "UsesNameplates", "SupportsRegionType", "Eligible", "Enabled", "UsesSpellIDs", "UsesRankSpellIDs",
      "UsesExcludedSpellIDs", "GetSpellIDs", "FilterApplies", "FilterString", "UnitTokens", "GetPreviewUnit", "Validate",
      "Elements", "Migrate", "MigrateSounds" }) do
      assert(Display[name] ~= nil, "missing Display." .. name)
    end

    -- Static tables: keys and order, not captions.
    Same(SortedKeys(Display.units), "arena,boss,focus,focustarget,group,member,mouseover,nameplate,party,pet,player,raid,target,targettarget", "unit keys")
    Same(FirstColumn(Display.booleanFilters),
      "isFromPlayerOrPlayerPet,canApplyAura,isStealable,isBossAura,isRoleAura,isBossOrRoleAura,isPriorityAura,nameplateShowAll,nameplateShowPersonal",
      "boolean filter rows")
    Same(FirstColumn(Display.nativeFilters),
      "PLAYER,RAID,CANCELABLE,EXTERNAL_DEFENSIVE,CROWD_CONTROL,RAID_IN_COMBAT,RAID_PLAYER_DISPELLABLE,BIG_DEFENSIVE,IMPORTANT,DISPELLABLE",
      "native filter rows")
    Same(FirstColumn(Display.processingOptions),
      "displayOnlyDispellableDebuffs,ignoreBuffs,ignoreDebuffs,ignoreDispelDebuffs", "processing option rows")
    Same(SortedKeys(Display.dispelTypes), ",Bleed,Curse,Disease,Magic,Poison", "dispel type keys (empty key is Enrage)")
    Same(SortedKeys(Display.sortMethods),
      "AuraInstanceIDOnly,BigDefensive,Default,Expiration,ExpirationOnly,ImportantOnly,Name,NameOnly,UnitFrameDebuff", "sort methods")
    Same(SortedKeys(Display.processedTypes), "Buff,Debuff,Dispel,any", "processed types")
    Same(type(Display.dynamicGroupWarning), "string", "dynamic group warning")

    -- SpecificUnit and UnitCategory.
    local function Specific(value)
      local label, category = Display.SpecificUnit({ specificUnit = value })
      return tostring(label) .. "/" .. tostring(category)
    end
    Same(Specific("party1"), "party1/party", "party1")
    Same(Specific("party4"), "party4/party", "party4")
    Same(Specific("party5"), "nil/nil", "party5 rejected")
    Same(Specific("party0"), "nil/nil", "party0 rejected")
    Same(Specific("party1 party2"), "nil/nil", "two words rejected")
    Same(Specific("  Party2  "), "party2/party", "trimmed and lowered")
    Same(Specific("partypet3"), "partypet3/party", "partypet3")
    Same(Specific("partypet5"), "nil/nil", "partypet5 rejected")
    Same(Specific("raid1"), "raid1/raid", "raid1")
    Same(Specific("raid40"), "raid40/raid", "raid40")
    Same(Specific("raid0"), "nil/nil", "raid0 rejected")
    Same(Specific("raid41"), "nil/nil", "raid41 rejected")
    Same(Specific("raid01"), "raid01/raid", "raid01 accepted")
    Same(Specific("raidpet12"), "raidpet12/raid", "raidpet12")
    Same(Specific("raidpet41"), "nil/nil", "raidpet41 rejected")
    Same(Specific("boss8"), "boss8/boss", "boss8")
    Same(Specific("boss9"), "nil/nil", "boss9 rejected")
    Same(Specific("arena5"), "arena5/arena", "arena5")
    Same(Specific("arena6"), "nil/nil", "arena6 rejected")
    Same(Specific("  Party2  "), "party2/party", "trimmed and lower-cased")
    Same(Specific("BOSS1"), "boss1/boss", "upper case")
    Same(Specific("party 1"), "nil/nil", "internal space")
    Same(Specific(""), "nil/nil", "empty")
    Same(Specific("   "), "nil/nil", "blank")
    Same(Specific("player"), "nil/nil", "player is not a specific unit")
    Same(Specific("party1x"), "nil/nil", "trailing characters")
    Same(Specific(12), "nil/nil", "number")
    Same(Display.SpecificUnit(nil), nil, "nil trigger")
    Same(Display.SpecificUnit("party1"), nil, "string trigger")
    Same(Display.UnitCategory({ unit = "member", specificUnit = "raid3" }), "raid", "member category")
    Same(Display.UnitCategory({ unit = "member", specificUnit = "nope" }), nil, "member without a valid unit")
    Same(Display.UnitCategory({ unit = "target", specificUnit = "raid3" }), "target", "other unit category")
    Same(Display.UnitCategory({ unit = "nameplate" }), "nameplate", "nameplate category")
    Same(Display.UnitCategory(nil), nil, "nil category")

    -- GetSavedTrigger, GetTrigger, HasTrigger, UsesNameplates, SupportsRegionType, Eligible.
    local function Secret1(extra)
      local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL" }
      for key, value in pairs(extra or {}) do trigger[key] = value end
      return trigger
    end
    local function AuraTable(triggerList, extra)
      local list = {}
      for index, trigger in ipairs(triggerList) do list[index] = { trigger = trigger } end
      local data = { id = "T", uid = "T", regionType = "icon", triggers = list }
      for key, value in pairs(extra or {}) do data[key] = value end
      return data
    end
    do
      local first, second = Secret1(), Secret1({ unit = "target" })
      local data = AuraTable({ first, second })
      Same(Display.GetSavedTrigger(data), first, "default position uses trigger 1")
      data.progressSource = { 2 }
      Same(Display.GetSavedTrigger(data), second, "progress source position")
      data.progressSource = { 0 }
      Same(Display.GetSavedTrigger(data), nil, "progress source 0 gives nothing")
      data.progressSource = { 3 }
      Same(Display.GetSavedTrigger(data), nil, "position without trigger")
      data.progressSource = { -1 }
      data.triggers.activeTriggerMode = 2
      Same(Display.GetSavedTrigger(data), second, "negative position falls back to activeTriggerMode")
      data.triggers.activeTriggerMode = nil
      local savedActive = private.GetActiveTriggerFor
      private.GetActiveTriggerFor = function() return 2 end
      Same(Display.GetSavedTrigger(data), second, "then to GetActiveTriggerFor")
      private.GetActiveTriggerFor = function() return nil end
      Same(Display.GetSavedTrigger(data), first, "then to trigger 1")
      private.GetActiveTriggerFor = savedActive
      data.progressSource = nil
      data.triggers[1].trigger.type = "aura2"
      Same(Display.GetSavedTrigger(data), nil, "other trigger type")
      Same(Display.GetSavedTrigger(nil), nil, "nil data")
      Same(Display.GetSavedTrigger({ triggers = "x" }), nil, "triggers not a table")
      Same(Display.GetSavedTrigger({ triggers = { "x" } }), nil, "list entry not a table")

      Same(Display.HasTrigger(data), true, "HasTrigger on the second trigger")
      Same(Display.HasTrigger(AuraTable({ Secret1({ type = "aura2" }) })), false, "HasTrigger without secretAura")
      Same(Display.HasTrigger(nil), false, "HasTrigger nil")
      Same(Display.HasTrigger({}), false, "HasTrigger without triggers")

      local plain = AuraTable({ Secret1() })
      Same(Display.GetTrigger(plain), plain.triggers[1].trigger, "plain trigger returned as is")
      Same(Display.GetTrigger(plain, true) == plain.triggers[1].trigger, false, "shownFilters returns a copy")
      Same(Display.GetTrigger(plain, true).unit, "player", "copy keeps the fields")
      Same(Display.GetTrigger(plain, true) == Display.GetTrigger(plain, true), false, "fresh copy each time")
      Same(Display.GetTrigger(AuraTable({ Secret1({ type = "aura2" }) })), nil, "no secretAura trigger")

      local classified = AuraTable({ Secret1({ processedAuraType = "Debuff", sortMethod = "UnitFrameDebuff", ignoreBuffs = true,
        displayOnlyDispellableDebuffs = true, ignoreDebuffs = false, ignoreDispelDebuffs = true, nativeFilters = { PLAYER = true } }) })
      local saved = classified.triggers[1].trigger
      local view = Display.GetTrigger(classified)
      Same(view == saved, false, "classified trigger is copied")
      Same(view.processedAuraType, nil, "classification dropped")
      Same(view.sortMethod, "Default", "UnitFrameDebuff sort becomes Default")
      Same(view.ignoreBuffs, true, "processing options kept without shownFilters")
      Same(view.displayOnlyDispellableDebuffs, true, "processing options kept (2)")
      Same(view.ignoreDebuffs, false, "processing options kept (3)")
      Same(view.ignoreDispelDebuffs, true, "processing options kept (4)")
      Same(Display.GetTrigger(classified), view, "copy cached per saved trigger")
      Same(saved.processedAuraType, "Debuff", "saved trigger untouched")
      Same(saved.sortMethod, "UnitFrameDebuff", "saved sort untouched")
      local shown = Display.GetTrigger(classified, true)
      Same(shown == view, false, "shownFilters copy differs from the cached copy")
      Same(shown.processedAuraType, nil, "shown copy without classification")
      Same(shown.sortMethod, "Default", "shown copy sort")
      for _, key in ipairs({ "ignoreBuffs", "displayOnlyDispellableDebuffs", "ignoreDebuffs", "ignoreDispelDebuffs" }) do
        Same(shown[key], nil, "shown copy drops " .. key)
      end
      Same(shown.nativeFilters.PLAYER, true, "shown copy keeps native filters")
      Same(shown.nativeFilters == saved.nativeFilters, false, "shown copy is deep")
      local sortedOnly = AuraTable({ Secret1({ sortMethod = "UnitFrameDebuff" }) })
      Same(Display.GetTrigger(sortedOnly).sortMethod, "Default", "UnitFrameDebuff alone is copied")
      local other = AuraTable({ Secret1({ sortMethod = "Name", processedAuraType = "any" }) })
      Same(Display.GetTrigger(other).sortMethod, "Name", "other sort kept")
      Same(Display.GetTrigger(other).processedAuraType, nil, "any is also a classification")
      Same(Display.GetTrigger(AuraTable({ Secret1({ sortMethod = "Name" }) })).sortMethod, "Name", "no classification: saved trigger")

      Same(Display.UsesNameplates(AuraTable({ Secret1({ unit = "nameplate" }) })), true, "nameplate unit")
      Same(Display.UsesNameplates(AuraTable({ Secret1() }, { anchorFrameType = "NAMEPLATE" })), true, "nameplate anchor")
      Same(Display.UsesNameplates(AuraTable({ Secret1() }, { anchorFrameType = "SCREEN" })) and true or false, false, "no nameplate")

      for _, regionType in ipairs({ "icon", "aurabar", "text", "progresstexture" }) do
        Same(Display.SupportsRegionType(regionType), true, "supports " .. regionType)
      end
      for _, regionType in ipairs({ "model", "texture", "group", "dynamicgroup", "stopmotion", "", "ICON" }) do
        Same(Display.SupportsRegionType(regionType), false, "does not support " .. regionType)
      end
      Same(Display.SupportsRegionType(nil), false, "nil region type")
      Same(Display.Eligible(plain) == true, true, "eligible")
      Same(Display.Enabled(plain) == true, true, "enabled")
      Same(Display.Eligible(AuraTable({ Secret1() }, { regionType = "model" })) == true, false, "model not eligible")
      Same(Display.Eligible(AuraTable({ Secret1({ type = "aura2" }) })) == true, false, "no secretAura not eligible")
      Same(Display.Eligible(nil) and true or false, false, "nil not eligible")
      Same(Display.Enabled(nil) and true or false, false, "nil not enabled")
    end

    -- Spell ID rules.
    do
      Same(Display.UsesSpellIDs({}), false, "no IDs, not forced")
      Same(Display.UsesSpellIDs({ auraspellids = { 1 } }), true, "IDs listed")
      Same(Display.UsesSpellIDs({ auraspellids = { 1 }, secretUseSpellIDs = false }), false, "forced off")
      Same(Display.UsesSpellIDs({ secretUseSpellIDs = true }), true, "forced on without IDs")
      Same(Display.UsesSpellIDs({ auraspellids = {}, secretUseSpellIDs = nil }), false, "empty list")
      Same(Display.UsesExcludedSpellIDs({}), false, "no excluded IDs")
      Same(Display.UsesExcludedSpellIDs({ excludedAuraSpellIDs = { 1 } }), true, "excluded IDs listed")
      Same(Display.UsesExcludedSpellIDs({ excludedAuraSpellIDs = { 1 }, secretUseExcludedSpellIDs = false }), false, "excluded forced off")
      Same(Display.UsesExcludedSpellIDs({ secretUseExcludedSpellIDs = true }), true, "excluded forced on")
      Same(Display.UsesRankSpellIDs({}), false, "rank IDs unset")
      Same(Display.UsesRankSpellIDs({ secretUseRankSpellIDs = true }), true, "rank IDs on")
      Same(Display.UsesRankSpellIDs({ secretUseRankSpellIDs = 1 }), false, "rank IDs strictly true")
      Same(Display.UsesRankSpellIDs({ auraRankSpellIDs = { 1 } }), false, "rank IDs need the flag")

      Same(Joined(Display.GetSpellIDs({})), "", "no IDs")
      Same(Joined(Display.GetSpellIDs({ auraspellids = { 5, 3, 5, "7", "x", 0, -1, 1.5, 2147483647, 2147483646 } })), "5,3,7,2147483646",
        "plain IDs: order, dedupe, tonumber, bounds")
      Same(Joined(Display.GetSpellIDs({ auraspellids = { 5 }, secretUseSpellIDs = false })), "", "IDs ignored when forced off")
      Same(Joined(Display.GetSpellIDs({ auraRankSpellIDs = { 1464 }, auraspellids = { 99 } })), "99", "ranks ignored without the flag")
      Same(Joined(Display.GetSpellIDs({ secretUseRankSpellIDs = true, auraRankSpellIDs = { 1464 }, auraspellids = { 99 } })),
        "1464,99", "rank base only without withRanks")
      Same(Joined(Display.GetSpellIDs({ secretUseRankSpellIDs = true, auraRankSpellIDs = { 1464 }, auraspellids = { 99, 8820 } }, true)),
        "1464,1240193,8820,11604,11605,99", "rank family after its base, then plain IDs, deduped")
      Same(Joined(Display.GetSpellIDs({ secretUseRankSpellIDs = true, auraRankSpellIDs = { 1464, "779", 1464, 0, "x" } }, true)),
        "1464,1240193,8820,11604,11605,779,780,769,9754,9908", "several bases")
      Same(Joined(Display.GetSpellIDs({ secretUseRankSpellIDs = true, auraRankSpellIDs = { 4242424 } }, true)), "4242424", "unknown base")
      Same(Joined(Display.GetSpellIDs({ secretUseRankSpellIDs = true, secretUseSpellIDs = false, auraRankSpellIDs = { 4242424 },
        auraspellids = { 1 } }, true)), "4242424", "rank IDs independent of the plain flag")
      Same(Joined(Display.GetSpellIDs({ secretUseSpellIDs = true, auraspellids = {} })), "", "forced on and empty")
    end

    -- FilterApplies and FilterString.
    do
      for _, key in ipairs({ "CANCELABLE", "EXTERNAL_DEFENSIVE", "BIG_DEFENSIVE", "IMPORTANT", "isStealable" }) do
        Same(Display.FilterApplies(key, { debuffType = "HELPFUL" }), true, key .. " on buffs")
        Same(Display.FilterApplies(key, { debuffType = "HARMFUL" }), false, key .. " on debuffs")
      end
      for _, key in ipairs({ "CROWD_CONTROL", "isPriorityAura", "isBossAura", "isRoleAura", "isBossOrRoleAura" }) do
        Same(Display.FilterApplies(key, { debuffType = "HARMFUL" }), true, key .. " on debuffs")
        Same(Display.FilterApplies(key, { debuffType = "HELPFUL" }), false, key .. " on buffs")
      end
      for _, key in ipairs({ "PLAYER", "RAID", "RAID_IN_COMBAT", "RAID_PLAYER_DISPELLABLE", "DISPELLABLE", "canApplyAura", "nameplateShowAll" }) do
        Same(Display.FilterApplies(key, { debuffType = "HELPFUL" }), true, key .. " on buffs")
        Same(Display.FilterApplies(key, { debuffType = "HARMFUL" }), true, key .. " on debuffs")
      end
      Same(Display.FilterString({ debuffType = "HELPFUL" }), "HELPFUL", "bare filter string")
      Same(Display.FilterString({ debuffType = "HARMFUL", nativeFilters = { PLAYER = true, RAID = false } }), "HARMFUL|PLAYER|!RAID",
        "own and not raid")
      Same(Display.FilterString({ debuffType = "HELPFUL", nativeFilters = { CANCELABLE = false, CROWD_CONTROL = true, PLAYER = true } }),
        "HELPFUL|PLAYER|!CANCELABLE", "filters follow the row order and skip the ones that do not apply")
      Same(Display.FilterString({ debuffType = "HELPFUL", nativeFilters = { DISPELLABLE = true, PLAYER = true, IMPORTANT = true } }),
        "HELPFUL|PLAYER|IMPORTANT|DISPELLABLE", "row order")
      Same(Display.FilterString({ debuffType = "HELPFUL", unit = "nameplate", includeNameplateOnly = true }),
        "HELPFUL|INCLUDE_NAME_PLATE_ONLY", "nameplate only")
      Same(Display.FilterString({ debuffType = "HELPFUL", unit = "target", includeNameplateOnly = true }), "HELPFUL",
        "nameplate only needs the nameplate unit")
      Same(Display.FilterString({ debuffType = "HELPFUL", unit = "nameplate", nativeFilters = { PLAYER = true }, includeNameplateOnly = true }),
        "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY", "nameplate only comes last")
    end

    -- UnitTokens and GetPreviewUnit.
    do
      local saved = {}
      local function Override(name, value) saved[name] = saved[name] or { _G[name] }; _G[name] = value end
      local inRaid, subgroupCount, groupCount = false, 2, 5
      local existing = {}
      local roles = {}
      local names = {}
      Override("IsInRaid", function() return inRaid end)
      Override("GetNumSubgroupMembers", function() return subgroupCount end)
      Override("GetNumGroupMembers", function() return groupCount end)
      Override("UnitExists", function(unit) return existing[unit] == true end)
      Override("UnitGroupRolesAssigned", function(unit) return roles[unit] end)
      local savedUnitName = private.ExecEnv.UnitName
      private.ExecEnv.UnitName = function(unit) return names[unit] end
      local function Tokens(trigger) return Joined(Display.UnitTokens(trigger)) end

      Same(Tokens({ unit = "player" }), "player", "player")
      Same(Tokens({ unit = "target" }), "target", "target")
      Same(Tokens({ unit = "targettarget" }), "targettarget", "targettarget")
      Same(Tokens({ unit = "pet" }), "pet", "pet")
      Same(Tokens({ unit = "member", specificUnit = "Boss3" }), "boss3", "member")
      Same(Tokens({ unit = "member", specificUnit = "nope" }), "", "member without a valid unit")
      Same(#Display.UnitTokens({ unit = "member", specificUnit = "nope" }), 0, "member without a valid unit is empty")
      Same(Tokens({ unit = "party" }), "player,party1,party2", "party")
      subgroupCount = 0
      Same(Tokens({ unit = "party" }), "player", "empty party")
      subgroupCount = 4
      Same(Tokens({ unit = "party" }), "player,party1,party2,party3,party4", "full party")
      subgroupCount = 2
      Same(Tokens({ unit = "group" }), "player,party1,party2", "group outside a raid is the party")
      Same(Tokens({ unit = "raid" }), "", "raid outside a raid")
      inRaid = true
      Same(Tokens({ unit = "raid" }), "raid1,raid2,raid3,raid4,raid5", "raid")
      Same(Tokens({ unit = "group" }), "raid1,raid2,raid3,raid4,raid5", "group in a raid is the raid")
      Same(Tokens({ unit = "party" }), "player,party1,party2", "party inside a raid")
      inRaid = false
      Same(#Display.UnitTokens({ unit = "boss" }), 10, "boss slots")
      Same(Display.UnitTokens({ unit = "boss" })[10], "boss10", "last boss token")
      Same(#Display.UnitTokens({ unit = "arena" }), 5, "arena slots")
      Same(Display.UnitTokens({ unit = "arena" })[5], "arena5", "last arena token")
      Same(Display.UnitTokens({ unit = "boss", secretShowOn = "showAlways" })[1], "boss1", "boss when always shown")
      Same(#Display.UnitTokens({ unit = "boss", secretShowOn = "showAlways" }), 1, "one boss slot when not showing on active")
      Same(#Display.UnitTokens({ unit = "arena", secretShowOn = "showOnMissing" }), 1, "one arena slot when showing missing")
      local plates = Display.UnitTokens({ unit = "nameplate" })
      assert(#plates >= 40, "nameplate floor of 40")
      Same(plates[1], "nameplate1", "first nameplate token")
      Same(plates[#plates], "nameplate" .. #plates, "last nameplate token")
      Same(Display.UnitTokens({ unit = "nameplate" }), plates, "nameplate tokens are shared")
      Same(Display.UnitTokens({ unit = "nameplate", useUnitNames = true }), plates, "nameplate tokens are not filtered")
      Same(Display.UnitTokens({ unit = "nameplate", use_includePets = true, includePets = "PetsOnly" }), plates, "nameplate has no pets")
      Same(Tokens({ unit = "nameplate", secretShowOn = "showAlways" }), "nameplate1", "one nameplate token when not showing on active")
      Same(Tokens({ unit = "boss", use_includePets = true, includePets = "PlayersAndPets" }), Tokens({ unit = "boss" }), "boss has no pets")

      -- Pets.
      existing = { pet = true, partypet1 = true, raidpet2 = true }
      local both = { unit = "party", use_includePets = true, includePets = "PlayersAndPets" }
      Same(Tokens(both), "player,pet,party1,partypet1,party2", "party with pets")
      Same(Tokens({ unit = "party", use_includePets = true, includePets = "PetsOnly" }), "pet,partypet1", "party pets only")
      Same(Tokens({ unit = "party", includePets = "PetsOnly" }), "player,party1,party2", "pets need the use flag")
      Same(Tokens({ unit = "party", use_includePets = true, includePets = "PlayersOnly" }), "player,party1,party2", "other pet mode")
      Same(Tokens({ unit = "party", use_includePets = true }), "player,party1,party2", "pet mode unset")
      inRaid, groupCount = true, 3
      Same(Tokens({ unit = "raid", use_includePets = true, includePets = "PlayersAndPets" }), "raid1,raid2,raidpet2,raid3", "raid with pets")
      Same(Tokens({ unit = "group", use_includePets = true, includePets = "PetsOnly" }), "raidpet2", "group pets only in a raid")
      inRaid = false
      Same(Tokens({ unit = "player", use_includePets = true, includePets = "PlayersAndPets" }), "player", "player is not a pet group")
      existing = {}
      Same(Tokens(both), "player,party1,party2", "missing pets skipped")
      Same(Tokens({ unit = "party", use_includePets = true, includePets = "PetsOnly" }), "", "no pet at all")

      -- Names and roles.
      existing = {}
      names = { player = "Alice", party1 = "bob", party2 = "Carol" }
      roles = { player = "TANK", party1 = "HEALER", party2 = "DAMAGER" }
      Same(Tokens({ unit = "party", useUnitNames = true, unitNames = { "ALICE", "carol" } }), "player,party2", "names, case-insensitive")
      Same(Tokens({ unit = "party", useUnitNames = true, unitNames = {} }), "", "no wanted name")
      Same(Tokens({ unit = "party", useUnitNames = true }), "", "names flag without a list")
      Same(Tokens({ unit = "party", unitNames = { "alice" } }), "player,party1,party2", "list ignored without the flag")
      Same(Tokens({ unit = "party", useUnitRoles = true, unitRoles = { TANK = true, HEALER = true } }), "player,party1", "roles")
      Same(Tokens({ unit = "party", useUnitRoles = true, unitRoles = { DAMAGER = false } }), "", "role set to false")
      Same(Tokens({ unit = "party", useUnitRoles = true }), "", "roles flag without a set")
      Same(Tokens({ unit = "party", useUnitRoles = true, useUnitNames = true, unitRoles = { TANK = true, DAMAGER = true },
        unitNames = { "alice", "bob" } }), "player", "names and roles together")
      names.party1 = Secret.Wrap("bob")
      Same(Tokens({ unit = "party", useUnitNames = true, unitNames = { "bob", "alice" } }), "player", "secret name refused")
      names.party1 = nil
      Same(Tokens({ unit = "party", useUnitNames = true, unitNames = { "bob", "alice" } }), "player", "missing name refused")
      roles.party1 = Secret.Wrap("HEALER")
      Same(Tokens({ unit = "party", useUnitRoles = true, unitRoles = { HEALER = true, TANK = true } }), "player", "secret role refused")
      names = { raid1 = "Alice", raid2 = "Bob" }
      roles = { raid1 = "TANK", raid2 = "TANK" }
      inRaid, groupCount = true, 2
      Same(Tokens({ unit = "raid", useUnitNames = true, unitNames = { "bob" } }), "raid2", "names in a raid")
      existing = { partypet1 = true, raidpet2 = true }
      Same(Tokens({ unit = "group", useUnitNames = true, unitNames = { "bob" }, use_includePets = true, includePets = "PlayersAndPets" }),
        "raid2,raidpet2", "pets follow the filter")
      inRaid = false
      Same(Tokens({ unit = "target", useUnitNames = true, unitNames = { "nobody" } }), "target", "no filter on a plain unit")
      Same(Tokens({ unit = "boss", useUnitRoles = true }), Tokens({ unit = "boss" }), "no filter on boss")

      -- GetPreviewUnit.
      existing = {}
      local frames = {}
      local savedGetUnitFrame = WeakAuras.GetUnitFrame
      WeakAuras.GetUnitFrame = function(unit) return frames[unit] end
      local function PreviewAura(unit, extra) return AuraTable({ Secret1({ unit = unit }) }, extra) end
      Same(Display.GetPreviewUnit(nil), "player", "preview without data")
      Same(Display.GetPreviewUnit({ triggers = {} }), "player", "preview without trigger")
      Same(Display.GetPreviewUnit(PreviewAura("target")), "player", "no existing unit")
      existing = { target = true }
      Same(Display.GetPreviewUnit(PreviewAura("target")), "target", "existing unit")
      existing = { party2 = true, party1 = true }
      Same(Display.GetPreviewUnit(PreviewAura("party")), "party1", "first existing token")
      Same(Display.GetPreviewUnit(PreviewAura("party", { anchorFrameType = "UNITFRAME" })), "player", "unit frame anchor needs a frame")
      frames.party2 = {}
      Same(Display.GetPreviewUnit(PreviewAura("party", { anchorFrameType = "UNITFRAME" })), "party2", "first token with a frame")
      Same(Display.GetPreviewUnit(PreviewAura("party", { anchorFrameType = "SCREEN" })), "party1", "frame ignored for other anchors")
      WeakAuras.GetUnitFrame = savedGetUnitFrame

      for name, value in pairs(saved) do _G[name] = value[1] end
      private.ExecEnv.UnitName = savedUnitName
    end

    -- Elements.
    do
      Same(Joined(Display.Elements({})), "border,duration,stack", "default elements")
      Same(Joined(Display.Elements({ glow = true })), "border,glow,duration,stack", "glow")
      Same(Joined(Display.Elements({ glow = false })), "border,duration,stack", "glow false")
      Same(Joined(Display.Elements({ duration = false })), "border,stack", "no duration")
      Same(Joined(Display.Elements({ stacks = false })), "border,duration", "no stack")
      Same(Joined(Display.Elements({ label = "x" })), "border,duration,stack,label", "label")
      Same(Joined(Display.Elements({ label = "" })), "border,duration,stack", "empty label")
      Same(Joined(Display.Elements({ glow = true, duration = false, stacks = false, label = "L" })), "border,glow,label", "everything")
      local options = {}
      local first = Display.Elements(options)
      Same(options.elements, first, "stored in displayOptions")
      Same(Display.Elements(options), first, "same table afterwards")
      options.duration = false
      Same(Joined(Display.Elements(options)), "border,duration,stack", "not computed twice")
      local preset = { "glow" }
      Same(Display.Elements({ elements = preset }), preset, "existing elements kept")
    end

    -- Validate: which checks fire, in which order, not the texts.
    do
      local harnessValidFilter = AuraUtil.IsValidFilterString
      AuraUtil.IsValidFilterString = function() return true end
      local function Valid(extraTrigger, extraData)
        local data = AuraTable({ Secret1(extraTrigger) }, extraData)
        data.blizzardAuraDisplay = {}
        return data
      end
      local function Issue(extraTrigger, extraData)
        return Display.Validate(Valid(extraTrigger, extraData))
      end
      local function Rejected(message, extraTrigger, extraData)
        local issue = Issue(extraTrigger, extraData)
        assert(type(issue) == "string" and issue ~= "", message .. ": expected an issue, got " .. tostring(issue))
      end
      local function Accepted(message, extraTrigger, extraData)
        local issue = Issue(extraTrigger, extraData)
        assert(issue == nil, message .. ": unexpected issue " .. tostring(issue))
      end

      Accepted("plain aura")
      for _, regionType in ipairs({ "icon", "aurabar", "text" }) do
        Accepted(regionType, nil, { regionType = regionType })
      end
      Rejected("region type without support", nil, { regionType = "model" })
      Rejected("no secretAura trigger", { type = "aura2" })
      Same(Display.Validate({ id = "x", regionType = "icon", triggers = {} }) ~= nil, true, "no trigger")
      Same(Display.Validate({ id = "x", regionType = "icon" }) ~= nil, true, "no trigger table")

      -- Required spells.
      Rejected("exact IDs forced without IDs", { secretUseSpellIDs = true })
      Accepted("exact IDs listed", { auraspellids = { 1234 } })
      Rejected("rank IDs forced without IDs", { secretUseRankSpellIDs = true })
      Accepted("rank IDs listed", { secretUseRankSpellIDs = true, auraRankSpellIDs = { 1464 } })
      Rejected("excluded IDs forced without IDs", { secretUseExcludedSpellIDs = true })
      Accepted("excluded IDs listed", { secretUseExcludedSpellIDs = true, excludedAuraSpellIDs = { 1234 } })

      -- Unit and aura kind.
      Same(Issue({ unit = "bogus" }), "Choose a supported unit and Buff or Debuff.", "unknown unit")
      Same(Issue({ debuffType = "BOTH" }), "Choose a supported unit and Buff or Debuff.", "unknown aura kind")
      Same(Issue({ debuffType = false }), "Choose a supported unit and Buff or Debuff.", "no aura kind")
      Accepted("debuffs", { debuffType = "HARMFUL" })
      for unit in pairs(Display.units) do
        if unit ~= "member" then Accepted("unit " .. unit, { unit = unit }) end
      end
      Rejected("member without a unit", { unit = "member" })
      Rejected("member with a bad unit", { unit = "member", specificUnit = "party9" })
      Accepted("member with a unit", { unit = "member", specificUnit = "party1" })
      Accepted("member with a raid unit", { unit = "member", specificUnit = " RAID12 " })
      do
        local savedPlates = C_NamePlate
        C_NamePlate = nil
        Rejected("nameplate without C_NamePlate", { unit = "nameplate" })
        Accepted("other units without C_NamePlate", { unit = "target" })
        C_NamePlate = {}
        Rejected("nameplate without GetNamePlateForUnit", { unit = "nameplate" })
        C_NamePlate = { GetNamePlateForUnit = function() end }
        Accepted("nameplate with GetNamePlateForUnit", { unit = "nameplate" })
        C_NamePlate = savedPlates
      end

      -- Spell values.
      Accepted("whole numbers as strings", { auraspellids = { "12", 13 } })
      Rejected("text ID", { auraspellids = { "abc" } })
      Rejected("zero ID", { auraspellids = { 0 } })
      Rejected("negative ID", { auraspellids = { -3 } })
      Rejected("fractional ID", { auraspellids = { 1.5 } })
      Rejected("infinite ID", { auraspellids = { math.huge } })
      Rejected("bad rank ID", { secretUseRankSpellIDs = true, auraRankSpellIDs = { 0 } })
      Rejected("bad rank ID without the flag", { auraRankSpellIDs = { 0 } })
      Rejected("bad excluded ID", { secretUseExcludedSpellIDs = true, excludedAuraSpellIDs = { 2.5 } })
      Rejected("bad excluded ID without the flag", { excludedAuraSpellIDs = { "x" } })
      Rejected("bad ID after good ones", { auraspellids = { 1, 2, "z" } })

      -- Flags.
      for _, row in ipairs(Display.booleanFilters) do
        Accepted("flag " .. row[1] .. " true", { [row[1]] = true })
        Accepted("flag " .. row[1] .. " false", { [row[1]] = false })
        Rejected("flag " .. row[1] .. " not a boolean", { [row[1]] = "yes" })
        Rejected("flag " .. row[1] .. " number", { [row[1]] = 1 })
      end

      -- Maximum duration and sort.
      Accepted("duration", { maxDuration = 10 })
      Accepted("fractional duration", { maxDuration = 0.5 })
      Rejected("duration zero", { maxDuration = 0 })
      Rejected("duration negative", { maxDuration = -1 })
      Rejected("duration text", { maxDuration = "5" })
      Rejected("duration infinite", { maxDuration = math.huge })
      Rejected("duration NaN", { maxDuration = 0 / 0 })
      Rejected("duration boolean", { maxDuration = true })
      for method in pairs(Display.sortMethods) do
        if method ~= "UnitFrameDebuff" then Accepted("sort " .. method, { sortMethod = method }) end
      end
      Rejected("unknown sort", { sortMethod = "Bogus" })

      -- Native filters and dispel types.
      Accepted("native filters", { nativeFilters = { PLAYER = true, RAID = false } })
      Rejected("unknown native filter", { nativeFilters = { BOGUS = true } })
      Rejected("native filter not a boolean", { nativeFilters = { PLAYER = "yes" } })
      Rejected("native filter number", { nativeFilters = { PLAYER = 1 } })
      do
        local savedValid = AuraUtil.IsValidFilterString
        local filterSeen
        AuraUtil.IsValidFilterString = function(text) filterSeen = text; return false end
        Rejected("filter string refused by the client", { nativeFilters = { PLAYER = true } })
        Same(filterSeen, "HELPFUL|PLAYER", "filter string sent to the client")
        AuraUtil.IsValidFilterString = function() return true end
        Accepted("filter string accepted by the client", { nativeFilters = { PLAYER = true } })
        local savedAuraUtil = AuraUtil
        AuraUtil = nil
        Accepted("no AuraUtil", { nativeFilters = { PLAYER = true } })
        AuraUtil = {}
        Accepted("no IsValidFilterString", { nativeFilters = { PLAYER = true } })
        AuraUtil = savedAuraUtil
        AuraUtil.IsValidFilterString = savedValid
      end
      for _, listKey in ipairs({ "includeDispelTypes", "excludeDispelTypes" }) do
        Accepted(listKey, { [listKey] = { Magic = true, Curse = true, Disease = true, Poison = true, Bleed = true } })
        Accepted(listKey .. " enrage", { [listKey] = { [""] = true } })
        Rejected(listKey .. " unknown type", { [listKey] = { Fire = true } })
        Rejected(listKey .. " false", { [listKey] = { Magic = false } })
        Rejected(listKey .. " not true", { [listKey] = { Magic = 1 } })
      end

      -- The classification is dropped before the checks: the saved trigger can carry any value.
      Accepted("classification dropped", { processedAuraType = "Debuff", sortMethod = "UnitFrameDebuff" })
      Accepted("processing options dropped", { ignoreBuffs = "x", ignoreDebuffs = 3 })

      -- Actions and animations come from the aura data.
      Accepted("sound and message on show", nil, { actions = { start = { do_sound = true, sound = "a.ogg", do_message = true, do_glow = false } } })
      Rejected("glow on show", nil, { actions = { start = { do_glow = true } } })
      Rejected("custom code on hide", nil, { actions = { finish = { do_custom = true } } })
      Rejected("any other action on show", nil, { actions = { start = { do_cooldown = true } } })
      Accepted("init actions are free", nil, { actions = { init = { do_custom = true, stop_sound = true } } })
      Rejected("stop sound", nil, { actions = { start = { stop_sound = true } } })
      Accepted("stop sound off", nil, { actions = { start = { stop_sound = false } } })
      Rejected("sound kit ID", nil, { actions = { finish = { do_sound = true, sound = " KitID" } } })
      Accepted("sound kit ID without the sound action", nil, { actions = { finish = { sound = " KitID" } } })
      Accepted("custom sound", nil, { actions = { start = { do_sound = true, sound = " custom", sound_path = "12" } } })
      Rejected("animation", nil, { animation = { start = { type = "preset" } } })
      Rejected("animation on the main part", nil, { animation = { main = { type = "custom" } } })
      Accepted("animation none", nil, { animation = { start = { type = "none" }, main = { type = "none" }, finish = {} } })

      -- Delegates: asked after the checks above, in this order, with the unclassified trigger.
      local original = {
        ValidateSingle = Display.ValidateSingle, FlowProblem = Display.FlowProblem, ValidateConditions = Display.ValidateConditions,
        ValidateAppearance = Display.ValidateAppearance, PrepareConditionAppearance = Display.PrepareConditionAppearance,
      }
      local calls, answers = {}, {}
      local function Replace(name)
        Display[name] = function(...)
          calls[#calls + 1] = { name = name, ... }
          return answers[name]
        end
      end
      for name in pairs(original) do Replace(name) end
      local function Run(extraTrigger, extraData)
        calls = {}
        local data = Valid(extraTrigger, extraData)
        return Display.Validate(data), data
      end
      local function Order() local list = {} for index, call in ipairs(calls) do list[index] = call.name end return Joined(list) end

      local issue, data = Run()
      Same(issue, nil, "delegates silent")
      Same(Order(), "PrepareConditionAppearance,ValidateAppearance,ValidateSingle,FlowProblem,ValidateConditions", "delegate order")
      Same(calls[3][1], data, "ValidateSingle receives the aura")
      Same(calls[3][2].unit, "player", "ValidateSingle receives a trigger")
      Same(calls[3][2] == data.triggers[1].trigger, false, "ValidateSingle receives a copy")
      Same(calls[4][1], data, "FlowProblem receives the aura")
      Same(calls[4][2], calls[3][2], "FlowProblem receives the same copy")
      Same(calls[5][1], data, "ValidateConditions receives the aura")
      Same(calls[5][2], nil, "ValidateConditions receives the aura only")
      Same(calls[1][1], data, "PrepareConditionAppearance receives the aura")
      do
        local sentinel = { "appearance" }
        Display.PrepareConditionAppearance = function() return sentinel end
        calls = {}
        Display.ValidateAppearance = function(...) calls[#calls + 1] = { ... }; return nil end
        Display.Validate(Valid())
        Same(calls[1][1], sentinel, "ValidateAppearance receives the prepared appearance")
        Replace("PrepareConditionAppearance")
        Replace("ValidateAppearance")
      end

      answers.ValidateSingle, answers.FlowProblem, answers.ValidateConditions = "single", "flow", "conditions"
      Same((Run()), "single", "single first")
      Same(Order(), "PrepareConditionAppearance,ValidateAppearance,ValidateSingle", "stop at the first issue")
      answers.ValidateSingle = nil
      Same((Run()), "flow", "flow second")
      Same(Order(), "PrepareConditionAppearance,ValidateAppearance,ValidateSingle,FlowProblem", "stop after flow")
      answers.FlowProblem = nil
      Same((Run()), "conditions", "conditions third")
      answers.ValidateConditions = nil
      Same((Run({ unit = "bogus" })), "Choose a supported unit and Buff or Debuff.", "unit before delegates")
      Same(Order(), "PrepareConditionAppearance,ValidateAppearance", "delegates not asked after a bad unit")
      answers.ValidateSingle = "single"
      Same((Run(nil, { actions = { start = { do_glow = true } } })), "single", "delegates before actions")
      answers.ValidateSingle = nil
      answers.ValidateAppearance = "appearance"
      Same((Run({ unit = "bogus" })), "appearance", "appearance before the other checks")
      Same(Order(), "PrepareConditionAppearance,ValidateAppearance", "nothing after an appearance issue")
      answers.ValidateAppearance = nil
      Same((Run({ type = "aura2" })) ~= nil, true, "not eligible")
      Same(Order(), "", "no delegate for a non eligible aura")
      for name, fn in pairs(original) do Display[name] = fn end
      AuraUtil.IsValidFilterString = harnessValidFilter
    end

    -- MigrateSounds and Migrate.
    do
      local savedFojjiCore, savedFojjiDB = FojjiCore, FojjiCoreDB
      FojjiCore, FojjiCoreDB = nil, nil
      local function Migrated(options, actions)
        local data = { blizzardAuraDisplay = options, actions = actions }
        Display.MigrateSounds(data)
        return data
      end

      local data = Migrated({ soundMode = "fojji", soundAdded = "clap", soundRemoved = "boom" })
      local start, finish = data.actions.start, data.actions.finish
      Same(start.do_sound, true, "fojji start sound")
      Same(start.sound, " Fojji", "fojji start kind")
      Same(start.sound_fojji, "clap", "fojji start word")
      Same(start.sound_channel, "Master", "default channel")
      Same(start.sound_path, nil, "no path for fojji")
      Same(finish.do_sound, true, "fojji finish sound")
      Same(finish.sound_fojji, "boom", "fojji finish word")
      local options = data.blizzardAuraDisplay
      Same(options.actionSounds, true, "migration flag")
      for _, key in ipairs({ "soundMode", "soundAdded", "soundRemoved", "soundAddedFile", "soundRemovedFile" }) do
        Same(options[key], nil, key .. " cleared")
      end

      data = Migrated({ soundMode = "file", soundAdded = "old", soundAddedFile = "added.ogg", soundRemoved = "removed.ogg" })
      Same(data.actions.start.sound, " custom", "file start kind")
      Same(data.actions.start.sound_path, "added.ogg", "file start prefers the file field")
      Same(data.actions.finish.sound_path, "removed.ogg", "file finish falls back to the plain field")
      Same(data.actions.start.sound_fojji, nil, "no fojji word for files")
      data = Migrated({ soundMode = "custom", soundAdded = 567, soundAddedFile = "ignored.ogg" })
      Same(data.actions.start.sound, " custom", "other mode kind")
      Same(data.actions.start.sound_path, "567", "path is a string")
      Same(data.actions.finish.do_sound, nil, "no sound for a missing value")
      data = Migrated({ soundMode = "fojji", soundAdded = "x", soundAddedFile = "ignored.ogg" })
      Same(data.actions.start.sound_fojji, "x", "file field only used in file mode")

      for _, mode in ipairs({ "none" }) do
        data = Migrated({ soundMode = mode, soundAdded = "x", soundRemoved = "y" })
        Same(data.actions.start.do_sound, nil, "mode " .. mode .. " start")
        Same(data.actions.finish.do_sound, nil, "mode " .. mode .. " finish")
      end
      data = Migrated({ soundAdded = "x", soundRemoved = "y" })
      Same(data.actions.start.do_sound, nil, "no mode")
      Same(type(data.actions.start), "table", "start action created anyway")
      Same(type(data.actions.finish), "table", "finish action created anyway")
      Same(data.blizzardAuraDisplay.actionSounds, true, "flag set without mode")
      for _, value in ipairs({ "", 1 }) do
        data = Migrated({ soundMode = "fojji", soundAdded = value, soundRemoved = "y" })
        Same(data.actions.start.do_sound, nil, "value " .. tostring(value) .. " skipped")
        Same(data.actions.finish.do_sound, true, "other event still migrated")
      end
      data = Migrated({ soundMode = "fojji", soundAdded = "x", soundRemoved = "y" },
        { start = { do_sound = true, sound = "mine.ogg" }, finish = { do_glow = true } })
      Same(data.actions.start.sound, "mine.ogg", "existing sound kept")
      Same(data.actions.start.sound_fojji, nil, "existing sound untouched")
      Same(data.actions.finish.do_glow, true, "existing finish action kept")
      Same(data.actions.finish.do_sound, true, "finish sound added beside it")
      data = Migrated({ actionSounds = true, soundMode = "fojji", soundAdded = "x", soundRemoved = "y" })
      Same(data.actions, nil, "already migrated: no actions")
      Same(data.blizzardAuraDisplay.soundMode, "fojji", "already migrated: fields kept")
      Same(data.blizzardAuraDisplay.soundAdded, "x", "already migrated: values kept")

      -- Channel.
      FojjiCore, FojjiCoreDB = {}, {}
      local function Channel(value)
        FojjiCoreDB.ttsSoundChannel = value
        return Migrated({ soundMode = "fojji", soundAdded = "x" }).actions.start.sound_channel
      end
      Same(Channel("Sound Effects"), "SFX", "Sound Effects channel")
      for _, name in ipairs({ "Master", "SFX", "Music", "Ambience", "Dialog" }) do Same(Channel(name), name, name .. " channel") end
      Same(Channel("Bogus"), "Master", "unknown channel")
      Same(Channel(nil), "Master", "no channel")
      Same(Channel("sfx"), "Master", "channel names are case-sensitive")
      FojjiCore, FojjiCoreDB = nil, { ttsSoundChannel = "Music" }
      Same(Migrated({ soundMode = "fojji", soundAdded = "x" }).actions.start.sound_channel, "Master", "channel needs FojjiCore")
      FojjiCore, FojjiCoreDB = {}, nil
      Same(Migrated({ soundMode = "fojji", soundAdded = "x" }).actions.start.sound_channel, "Master", "channel needs FojjiCoreDB")
      FojjiCore, FojjiCoreDB = nil, nil

      -- Migrate.
      local migrateCalls = {}
      local originals = { MigrateAppearance = Display.MigrateAppearance, MigrateSingle = Display.MigrateSingle, MigrateTotal = Display.MigrateTotal }
      for name, fn in pairs(originals) do
        Display[name] = function(...)
          migrateCalls[#migrateCalls + 1] = { name = name, ... }
          return fn(...)
        end
      end
      local function MigrateOrder() local list = {} for index, call in ipairs(migrateCalls) do list[index] = call.name end return Joined(list) end

      local legacy = { id = "L", regionType = "icon", blizzardAuraDisplay = { enabled = true, soundSpellIDs = { 1 }, soundIgnoreDisplayFilters = true },
        triggers = { { trigger = { type = "aura2", unit = "target" } } } }
      Display.Migrate(legacy)
      local trigger = legacy.triggers[1].trigger
      Same(trigger.type, "secretAura", "legacy trigger upgraded")
      Same(legacy.blizzardAuraDisplay.enabled, nil, "legacy flag cleared")
      Same(trigger.unit, "target", "existing unit kept")
      Same(trigger.debuffType, "HELPFUL", "default aura kind")
      Same(type(trigger.auraspellids), "table", "default ID list")
      Same(trigger.useExactSpellId, true, "exact IDs flag forced")
      Same(trigger.onlyMaw, nil, "onlyMaw cleared")
      Same(legacy.blizzardAuraDisplay.soundSpellIDs, nil, "soundSpellIDs cleared")
      Same(legacy.blizzardAuraDisplay.soundIgnoreDisplayFilters, nil, "soundIgnoreDisplayFilters cleared")
      Same(legacy.blizzardAuraDisplay.actionSounds, true, "sounds migrated")
      Same(MigrateOrder(), "MigrateSingle,MigrateTotal,MigrateAppearance", "migration steps")
      Same(migrateCalls[1][1], legacy, "MigrateSingle receives the aura")
      Same(migrateCalls[1][2], trigger, "MigrateSingle receives the trigger")
      Same(migrateCalls[2][1], trigger, "MigrateTotal receives the trigger")
      Same(migrateCalls[3][1], legacy, "MigrateAppearance receives the aura")
      Same(type(migrateCalls[3][2]), "table", "MigrateAppearance receives the former options")

      local secret = { id = "S", regionType = "icon", triggers = { { trigger = { type = "secretAura", unit = "party", debuffType = "HARMFUL",
        auraspellids = { 5 }, onlyMaw = true } }, { trigger = { type = "secretAura" } }, { trigger = { type = "aura2" } } } }
      migrateCalls = {}
      Display.Migrate(secret)
      Same(secret.triggers[1].trigger.debuffType, "HARMFUL", "aura kind kept")
      Same(secret.triggers[1].trigger.auraspellids[1], 5, "IDs kept")
      Same(secret.triggers[1].trigger.onlyMaw, nil, "onlyMaw cleared on every trigger")
      Same(secret.triggers[2].trigger.unit, "player", "second trigger defaults")
      Same(secret.triggers[3].trigger.type, "aura2", "other trigger untouched")
      Same(secret.triggers[3].trigger.unit, nil, "other trigger without defaults")
      Same(MigrateOrder(), "MigrateSingle,MigrateTotal,MigrateSingle,MigrateTotal,MigrateAppearance", "one pass per secretAura trigger")
      Same(type(secret.blizzardAuraDisplay), "table", "display options created")

      local twoLegacy = { id = "L2", regionType = "icon", blizzardAuraDisplay = { enabled = true },
        triggers = { { trigger = { type = "aura2" } }, { trigger = { type = "aura2" } } } }
      migrateCalls = {}
      Display.Migrate(twoLegacy)
      Same(twoLegacy.triggers[1].trigger.type, "aura2", "legacy upgrade needs a single trigger")
      Same(twoLegacy.blizzardAuraDisplay.enabled, true, "legacy options untouched")
      Same(#migrateCalls, 0, "nothing migrated without a secretAura trigger")
      local notEnabled = { id = "L3", regionType = "icon", blizzardAuraDisplay = {}, triggers = { { trigger = { type = "aura2" } } } }
      Display.Migrate(notEnabled)
      Same(notEnabled.triggers[1].trigger.type, "aura2", "legacy upgrade needs the enabled flag")
      local plain = { id = "P", regionType = "icon" }
      Display.Migrate(plain)
      Same(plain.blizzardAuraDisplay, nil, "no options created without a secretAura trigger")
      Same(#migrateCalls, 0, "nothing migrated for a plain aura")

      local subtexts = { id = "ST", regionType = "icon", triggers = { { trigger = { type = "secretAura" } } }, subRegions = {
        { type = "subtext", anchorXOffset = 4, anchorYOffset = -3 },
        { type = "subtext", text_alpha = 0.5, text_anchorXOffset = 0, text_anchorYOffset = false },
        { type = "subtext" },
        { type = "subborder", anchorXOffset = 9 },
      } }
      Display.Migrate(subtexts)
      local subs = subtexts.subRegions
      Same(subs[1].text_alpha, 1, "text alpha default")
      Same(subs[1].text_anchorXOffset, 4, "text X offset from the anchor")
      Same(subs[1].text_anchorYOffset, -3, "text Y offset from the anchor")
      Same(subs[2].text_alpha, 0.5, "text alpha kept")
      Same(subs[2].text_anchorXOffset, 0, "text X offset kept")
      Same(subs[2].text_anchorYOffset, false, "text Y offset kept even when false")
      Same(subs[3].text_anchorXOffset, 0, "text offset default")
      Same(subs[3].text_anchorYOffset, 0, "text offset default (Y)")
      Same(subs[4].text_alpha, nil, "other sub regions untouched")

      local sounds = { id = "SS", regionType = "icon", triggers = { { trigger = { type = "secretAura" } } },
        blizzardAuraDisplay = { soundMode = "fojji", soundAdded = "x" } }
      Display.Migrate(sounds)
      Same(sounds.actions.start.sound_fojji, "x", "Migrate migrates the sounds")
      local snapshot = sounds.actions.start.sound_fojji .. tostring(sounds.blizzardAuraDisplay.actionSounds)
      Display.Migrate(sounds)
      Same(sounds.actions.start.sound_fojji .. tostring(sounds.blizzardAuraDisplay.actionSounds), snapshot, "second pass changes nothing")
      for name, fn in pairs(originals) do Display[name] = fn end
      FojjiCore, FojjiCoreDB = savedFojjiCore, savedFojjiDB
    end

    -- Sounds and preview notice, driven through Apply with stand-in native containers.
    do
      local savedCreateFrame, savedPolicy = CreateFrame, CustomAuraContainerAuraProcessingPolicy
      local savedIsLoaded = C_AddOns.IsAddOnLoaded
      local savedStringUtil, savedValidFilter = C_StringUtil, AuraUtil and AuraUtil.IsValidFilterString
      local savedSortMethod, savedSortDirection = AuraContainerSortMethod, AuraContainerSortDirection
      CustomAuraContainerAuraProcessingPolicy = { None = 0 }
      C_AddOns.IsAddOnLoaded = function(name)
        if name == "Blizzard_AuraContainer" then return true end
        return savedIsLoaded(name)
      end
      C_StringUtil = C_StringUtil or {}
      C_StringUtil.CreateNumericRuleFormatter = C_StringUtil.CreateNumericRuleFormatter
        or function() return { SetBreakpoints = function() end } end
      AuraUtil = AuraUtil or {}
      AuraUtil.IsValidFilterString = function() return true end
      AuraContainerSortMethod = setmetatable({}, { __index = function() return 0 end })
      AuraContainerSortDirection = { Normal = 0, Reverse = 1 }
      local noop = function() end
      local function NewContainer(name, parent)
        local container = savedCreateFrame("Frame", name, parent)
        container:SetFrameLevel(7)
        for _, method in ipairs({ "SetAuraProcessingPolicy", "SetUnit", "SetAuraSlotFilterString", "SetAuraSlotCandidateFilters",
          "SetAuraSlotSortMethod", "SetAuraGroupSortMethod", "SetAuraGroupFilterString", "SetAuraGroupCandidateFilters",
          "UpdateAllAuras", "SetAuraGroupLayout", "SetAuraGroupMaxFrameCount", "SetFlowLayoutAxis", "SetFlowLayoutAnchorPoint",
          "SetFlowLayoutGrowthDirection", "SetFlowLayoutMaximumLineSize", "SetAuraGroupEnabled", "SetEnabled", "AddAuraGroup",
          "SetAlphaFromBoolean" }) do
          container[method] = noop
        end
        container.AddAuraSlot = function(self, slotName, _, settings)
          if slotName == "UnitGlow" then
            local button = savedCreateFrame("Frame", nil, self)
            button.AddAuraShownAnimation, button.RemoveAuraShownAnimation = noop, noop
            settings.initializeFrame(button)
          end
        end
        return container
      end
      CreateFrame = function(frameType, name, parent, template)
        if frameType == "AuraContainer" then return NewContainer(name, parent) end
        return savedCreateFrame(frameType, name, parent, template)
      end

      local savedSubgroup = GetNumSubgroupMembers
      GetNumSubgroupMembers = function() return 1 end
      local restricted, optionsOpen = false, false
      local originals = {
        IsRestricted = WeakAuras.IsRestricted, IsOptionsOpen = WeakAuras.IsOptionsOpen, GetData = WeakAuras.GetData,
        UpdateWarning = private.AuraWarnings.UpdateWarning,
      }
      WeakAuras.IsRestricted = function() return restricted end
      WeakAuras.IsOptionsOpen = function() return optionsOpen end
      local store = {}
      WeakAuras.GetData = function(id) return store[id] or originals.GetData(id) end
      local warnings = {}
      private.AuraWarnings.UpdateWarning = function(uid, key, severity, text)
        warnings[uid] = warnings[uid] or {}
        warnings[uid][key] = severity and { severity = severity, text = text } or nil
      end
      local function SoundWarning(uid) return warnings[uid] and warnings[uid].blizzard_aura_sound end
      local savedAdd, savedRemove, savedTriggers = C_UnitAuras.AddAuraSound, C_UnitAuras.RemoveAuraSound, Enum.UnitAuraSoundTrigger
      local added, removed, addResult = {}, {}, nil
      C_UnitAuras.AddAuraSound = function(trigger, info)
        added[#added + 1] = { trigger = trigger, info = info }
        if addResult == "error" then error("refused") end
        if addResult == "none" then return nil end
        return 500 + #added
      end
      C_UnitAuras.RemoveAuraSound = function(id) removed[#removed + 1] = id end
      Enum.UnitAuraSoundTrigger = { Added = 1, Removed = 2 }

      local function Mounted(id, trigger, actions, extra)
        local data = AuraTable({ Secret1(trigger) }, extra)
        data.id, data.uid, data.blizzardAuraDisplay, data.actions = id, id, {}, actions
        data.width, data.height, data.anchorFrameType = 30, 30, "SCREEN"
        store[id] = data
        local region = savedCreateFrame("Frame")
        region:Show()
        private.regions[id] = { region = region }
        Display.Apply(region, data)
        return region, data, region.blizzardAuraDisplay
      end
      local function Resync(data)
        test.Frames.Fire("GROUP_ROSTER_UPDATE")
        return data
      end
      local function Count(list, field)
        local total = 0
        for _, entry in ipairs(list) do if entry.info[field] ~= nil then total = total + 1 end end
        return total
      end
      local function Reset() added, removed, addResult = {}, {}, nil end

      -- Registration: arguments.
      local region, data, state = Mounted("SoundBasic", { unit = "party", auraspellids = { 1234 } },
        { start = { do_sound = true, sound = "Sound\\Start.ogg", sound_channel = "SFX" },
          finish = { do_sound = true, sound = " custom", sound_path = "567" } })
      Same(#added, 4, "two sounds on the two party tokens")
      Same(#state.soundIDs, 4, "every registration remembered")
      Same(state.soundIDs[1], 501, "registration IDs remembered in order")
      Same(added[1].trigger, 1, "start uses the Added trigger")
      Same(added[1].info.unitToken, "player", "first token")
      Same(added[1].info.spellID, 1234, "spell")
      Same(added[1].info.soundFileName, "Sound\\Start.ogg", "file name")
      Same(added[1].info.soundFileID, nil, "no file ID for a name")
      Same(added[1].info.outputChannel, "SFX", "channel from the action")
      Same(added[2].info.unitToken, "party1", "second token")
      Same(added[3].trigger, 2, "finish uses the Removed trigger")
      Same(added[3].info.soundFileID, 567, "numeric custom path becomes a file ID")
      Same(added[3].info.soundFileName, nil, "no file name for a number")
      Same(added[3].info.outputChannel, "Master", "default channel")
      Same(SoundWarning("SoundBasic"), nil, "no warning when everything registered")
      local registered = #added
      Resync(data)
      Same(#added, registered, "same signature: no re-registration")
      Same(#removed, 0, "same signature: nothing removed")
      data.actions.start.sound = "Sound\\Other.ogg"
      Resync(data)
      Same(#added, registered + 4, "changed action: registered again")
      Same(#removed, 4, "changed action: former IDs removed")
      Same(added[registered + 1].info.soundFileName, "Sound\\Other.ogg", "changed action: new file")
      Same(#state.soundIDs, 4, "changed action: only the new IDs remembered")
      data.triggers[1].trigger.auraspellids = { 1234, 99 }
      registered = #added
      Resync(data)
      Same(#added - registered, 8, "changed spells: registered again")
      data.triggers[1].trigger.unit = "party"
      Resync(data)
      region:Hide()
      Same(#state.soundIDs, 0, "hiding the region forgets the IDs")
      assert(#removed >= 12, "hiding the region removes the sounds")
      Same(SoundWarning("SoundBasic"), nil, "hidden region: no warning")
      local afterHide = #added
      region:Show()
      assert(#added > afterHide, "showing the region registers the sounds again")

      -- Preview, restriction and inactive display.
      Reset()
      region, data, state = Mounted("SoundPreview", { unit = "party", auraspellids = { 1234 } },
        { start = { do_sound = true, sound = "a.ogg" } })
      local live = #added
      assert(live > 0, "registered outside the preview")
      local mine = {}
      for index, id in ipairs(state.soundIDs) do mine[index] = id end
      optionsOpen = true
      Resync(data)
      for _, id in ipairs(mine) do
        local found = false
        for _, gone in ipairs(removed) do if gone == id then found = true end end
        assert(found, "preview removes the sound " .. id)
      end
      Same(#state.soundIDs, 0, "preview forgets the IDs")
      local previewAdds = #added
      Resync(data)
      Same(#added, previewAdds, "preview registers nothing")
      optionsOpen = false
      Resync(data)
      assert(#added > previewAdds, "leaving the preview registers again")
      Reset()
      restricted = true
      data.actions.start.sound = "b.ogg"
      Resync(data)
      Same(#added, 0, "restricted: nothing registered")
      Same(#removed, 0, "restricted: nothing removed")
      restricted = false
      test.Frames.Fire("PLAYER_TARGET_CHANGED")
      assert(#added > 0, "restricted sync replayed by the next event")
      Reset()
      Resync(data)
      Same(#added, 0, "replayed once")

      -- Warnings.
      Reset()
      region, data, state = Mounted("SoundNone", { unit = "party", auraspellids = { 1234 } }, {})
      Same(#added, 0, "no sound action: nothing registered")
      Same(SoundWarning("SoundNone"), nil, "no sound action: no warning")
      region, data, state = Mounted("SoundNoSpell", { unit = "party" }, { start = { do_sound = true, sound = "a.ogg" } })
      Same(#added, 0, "no spell: nothing registered")
      assert(SoundWarning("SoundNoSpell"), "no spell: warning")
      Same(SoundWarning("SoundNoSpell").severity, "warning", "warning severity")
      assert(SoundWarning("SoundNoSpell").text ~= "", "warning text")
      data.triggers[1].trigger.auraspellids = { 7 }
      Resync(data)
      Same(#added > 0, true, "spell added: registered")
      Same(SoundWarning("SoundNoSpell"), nil, "spell added: warning cleared")
      Reset()
      region, data = Mounted("SoundExcluded", { unit = "player", auraspellids = { 1, 2 }, secretUseExcludedSpellIDs = true, excludedAuraSpellIDs = { 2 } },
        { start = { do_sound = true, sound = "a.ogg" } })
      Same(#added, 1, "excluded: one spell left")
      Same(added[1].info.spellID, 1, "excluded: the other spell")
      region, data = Mounted("SoundExcludedOnly", { unit = "player", auraspellids = { 2 }, secretUseExcludedSpellIDs = true, excludedAuraSpellIDs = { 2 } },
        { start = { do_sound = true, sound = "a.ogg" } })
      assert(SoundWarning("SoundExcludedOnly"), "every spell excluded: warning")
      Reset()
      region, data = Mounted("SoundRanks", { unit = "player", secretUseRankSpellIDs = true, auraRankSpellIDs = { 1464 } },
        { start = { do_sound = true, sound = "a.ogg" } })
      local rankIds = {}
      for _, entry in ipairs(added) do rankIds[#rankIds + 1] = entry.info.spellID end
      table.sort(rankIds)
      Same(Joined(rankIds), "1464,8820,11604,11605,1240193", "rank family registered")
      Reset()
      for _, kind in ipairs({ { sound = " KitID" }, { sound = "" }, { sound = 1 }, { sound = " custom", sound_path = "" }, { sound = " custom" } }) do
        local id = "SoundBad" .. tostring(kind.sound) .. tostring(kind.sound_path)
        kind.do_sound = true
        region, data = Mounted(id, { unit = "party", auraspellids = { 1234 } }, { start = { do_sound = true, sound = "a.ogg" } })
        Reset()
        data.actions.start = kind
        Resync(data)
        Same(#added, 0, id .. ": nothing registered")
        assert(SoundWarning(id), id .. ": warning")
      end
      region, data = Mounted("SoundHalf", { unit = "party", auraspellids = { 1234 } },
        { start = { do_sound = true, sound = "a.ogg" }, finish = { do_sound = true, sound = "b.ogg" } })
      Reset()
      data.actions.finish.sound = " KitID"
      Resync(data)
      Same(#added, 2, "the valid sound is registered")
      assert(SoundWarning("SoundHalf"), "the invalid one warns")
      Reset()
      addResult = "none"
      region, data, state = Mounted("SoundRefused", { unit = "player", auraspellids = { 1234 } }, { start = { do_sound = true, sound = "a.ogg" } })
      assert(SoundWarning("SoundRefused"), "refused registration: warning")
      Same(#state.soundIDs, 0, "refused registration: nothing remembered")
      addResult = "error"
      region, data, state = Mounted("SoundError", { unit = "player", auraspellids = { 1234 } }, { start = { do_sound = true, sound = "a.ogg" } })
      assert(SoundWarning("SoundError"), "failing registration: warning")
      addResult = nil
      local savedAddFunction = C_UnitAuras.AddAuraSound
      C_UnitAuras.AddAuraSound = nil
      region, data = Mounted("SoundNoApi", { unit = "player", auraspellids = { 1234 } }, { start = { do_sound = true, sound = "a.ogg" } })
      assert(SoundWarning("SoundNoApi"), "missing API: warning")
      C_UnitAuras.AddAuraSound = savedAddFunction
      local savedTrigger = Enum.UnitAuraSoundTrigger
      Enum.UnitAuraSoundTrigger = nil
      region, data = Mounted("SoundNoEnum", { unit = "player", auraspellids = { 1234 } }, { start = { do_sound = true, sound = "a.ogg" } })
      assert(SoundWarning("SoundNoEnum"), "missing trigger enum: warning")
      Enum.UnitAuraSoundTrigger = savedTrigger

      -- Recorded Fojji sounds.
      local savedFojjiCore, savedFojjiDB = FojjiCore, FojjiCoreDB
      local function Fojji(id)
        Reset()
        region, data = Mounted(id, { unit = "player", auraspellids = { 1234 } },
          { start = { do_sound = true, sound = " Fojji", sound_fojji = "clap", sound_channel = "Music" } })
        return SoundWarning(id)
      end
      FojjiCore, FojjiCoreDB = nil, nil
      assert(Fojji("FojjiMissing"), "FojjiCore not loaded: warning")
      Same(#added, 0, "FojjiCore not loaded: nothing registered")
      FojjiCore, FojjiCoreDB = { voicePacks = { Pack = { clap = "Sound\\Clap.ogg", number = 4242 } } }, { ttsVoiceType = "custom", ttsVoicePack = "Pack" }
      Same(Fojji("FojjiOk"), nil, "recording found: no warning")
      Same(#added, 1, "recording found: registered")
      Same(added[1].info.soundFileName, "Sound\\Clap.ogg", "recording file")
      Same(added[1].info.outputChannel, "Music", "recording channel")
      FojjiCoreDB.ttsRandomFavorites = true
      assert(Fojji("FojjiRandom"), "random favorites: warning")
      Same(#added, 0, "random favorites: nothing registered")
      FojjiCoreDB.ttsRandomFavorites = nil
      FojjiCoreDB.ttsVoiceType = "synth"
      assert(Fojji("FojjiSynth"), "synthesized voice: warning")
      FojjiCoreDB.ttsVoiceType = "custom"
      FojjiCoreDB.disableTTS = true
      assert(Fojji("FojjiDisabled"), "speech disabled: warning")
      FojjiCoreDB.disableTTS = nil
      FojjiCoreDB.ttsVoicePack = "Absent"
      assert(Fojji("FojjiNoPack"), "missing pack: warning")
      FojjiCoreDB.ttsVoicePack = "Pack"
      FojjiCore.voicePacks.Pack.clap = nil
      assert(Fojji("FojjiNoRecording"), "missing recording: warning")
      FojjiCore.voicePacks.Pack.clap = 4242
      Same(Fojji("FojjiNumber"), nil, "numeric recording: no warning")
      Same(added[1].info.soundFileID, 4242, "numeric recording becomes a file ID")
      Same(added[1].info.soundFileName, nil, "numeric recording has no name")
      FojjiCore, FojjiCoreDB = savedFojjiCore, savedFojjiDB

      -- Preview notice.
      local function NoticeAura(id, trigger)
        local aura = AuraTable({ Secret1(trigger) })
        aura.id, aura.uid, aura.blizzardAuraDisplay, aura.width, aura.height, aura.anchorFrameType = id, id, {}, 30, 30, "SCREEN"
        store[id] = aura
        local noticeRegion = savedCreateFrame("Frame")
        noticeRegion:Show()
        private.regions[id] = { region = noticeRegion }
        local created = {}
        local createFontString = noticeRegion.CreateFontString
        noticeRegion.CreateFontString = function(self, ...)
          local text = createFontString(self, ...)
          created[#created + 1] = text
          local log = { }
          text.log = log
          for _, method in ipairs({ "SetFont", "SetPoint", "SetWidth", "SetTextColor", "SetText", "Show", "Hide" }) do
            local inner = text[method]
            text[method] = function(fontString, ...)
              log[#log + 1] = { method, ... }
              return inner(fontString, ...)
            end
          end
          return text
        end
        return noticeRegion, aura, created
      end
      local function LogOf(text, method)
        for _, entry in ipairs(text.log) do if entry[1] == method then return entry end end
      end
      optionsOpen = true
      local noticeRegion, aura, created = NoticeAura("NoticeError", { unit = "boss", auraspellids = { 1234 } })
      Same(Display.SpellIDFilterNote(aura.triggers[1].trigger), "error", "setup: the filter note is an error")
      Display.Apply(noticeRegion, aura)
      Same(#created, 1, "one notice created")
      local notice = noticeRegion.secretAuraPreviewNotice
      Same(notice, created[1], "notice stored on the region")
      local font = LogOf(notice, "SetFont")
      Same(font[2] .. "|" .. font[3] .. "|" .. font[4], "Fonts\\FRIZQT__.TTF|12|OUTLINE", "notice font")
      local point = LogOf(notice, "SetPoint")
      Same(point[2] .. "|" .. tostring(point[3] == noticeRegion) .. "|" .. point[4] .. "|" .. point[5] .. "|" .. point[6], "TOP|true|BOTTOM|0|-6", "notice anchor")
      Same(LogOf(notice, "SetWidth")[2], 300, "notice width")
      local color = LogOf(notice, "SetTextColor")
      Same(color[2] .. "," .. color[3] .. "," .. color[4], "1,0.8,0.2", "notice color")
      Same(type(LogOf(notice, "SetText")[2]), "string", "notice text")
      Same(LogOf(notice, "Show") ~= nil, true, "notice shown")
      Same(notice:IsShown(), true, "notice visible")
      Display.Apply(noticeRegion, aura)
      Same(#created, 1, "notice created once")
      Same(noticeRegion.secretAuraPreviewNotice, notice, "notice reused")
      local function CountOf(text, method) local count = 0 for _, entry in ipairs(text.log) do if entry[1] == method then count = count + 1 end end return count end
      local textsBefore = CountOf(notice, "SetText")
      aura.triggers[1].trigger.unit = "player"
      Display.Apply(noticeRegion, aura)
      Same(CountOf(notice, "SetText"), textsBefore, "hiding the notice leaves its text alone")
      Same(notice:IsShown(), false, "notice hidden once the note is gone")
      Same(#(function() local hides = {} for _, entry in ipairs(notice.log) do if entry[1] == "Hide" then hides[#hides + 1] = entry end end return hides end)() > 0 and 1 or 0, 1, "notice hidden through Hide")
      Same(#created, 1, "no new notice when hiding")
      aura.triggers[1].trigger.unit = "boss"
      Display.Apply(noticeRegion, aura)
      Same(notice:IsShown(), true, "notice shown again")
      Same(#created, 1, "still one notice")
      Display.Activate(noticeRegion, aura)
      Same(notice:IsShown(), true, "notice kept on activation")
      Display.HidePreview(noticeRegion)
      noticeRegion.blizzardAuraDisplay.previewHasAuras = false
      aura.triggers[1].trigger.unit = "player"
      noticeRegion:PreShow()
      Same(notice:IsShown(), false, "notice hidden by a show outside the samples")
      aura.triggers[1].trigger.unit = "boss"
      Display.Apply(noticeRegion, aura)
      Same(notice:IsShown(), true, "notice shown after the samples come back")
      local quietRegion, quietAura, quietCreated = NoticeAura("NoticeQuiet", { unit = "player", auraspellids = { 1234 } })
      Display.Apply(quietRegion, quietAura)
      Same(#quietCreated, 0, "nothing created when there is nothing to show")
      Same(quietRegion.secretAuraPreviewNotice, nil, "no notice on a quiet aura")
      optionsOpen = false
      local liveRegion, liveAura, liveCreated = NoticeAura("NoticeLive", { unit = "boss", auraspellids = { 1234 } })
      Display.Apply(liveRegion, liveAura)
      Same(#liveCreated, 0, "no notice outside the preview")

      local function SlotsOf(id, trigger)
        local slotRegion, slotAura = NoticeAura(id, trigger)
        Display.Apply(slotRegion, slotAura)
        return #slotRegion.blizzardAuraDisplay.instances
      end
      Same(SlotsOf("SlotsParty", { unit = "party", auraspellids = { 1234 } }), 5, "party slots")
      Same(SlotsOf("SlotsPartyPets", { unit = "party", auraspellids = { 1234 }, use_includePets = true, includePets = "PlayersAndPets" }), 10, "party slots doubled with pets")
      Same(SlotsOf("SlotsPartyPetsOnly", { unit = "party", auraspellids = { 1234 }, use_includePets = true, includePets = "PetsOnly" }), 5, "pets only do not double")
      Same(SlotsOf("SlotsBossPets", { unit = "boss", auraspellids = { 1234 }, use_includePets = true, includePets = "PlayersAndPets" }), 10, "boss never doubled")

      -- Restore.
      optionsOpen = false
      GetNumSubgroupMembers = savedSubgroup
      for name, value in pairs(originals) do
        if name == "UpdateWarning" then private.AuraWarnings.UpdateWarning = value else WeakAuras[name] = value end
      end
      C_UnitAuras.AddAuraSound, C_UnitAuras.RemoveAuraSound, Enum.UnitAuraSoundTrigger = savedAdd, savedRemove, savedTriggers
      CreateFrame, CustomAuraContainerAuraProcessingPolicy = savedCreateFrame, savedPolicy
      C_AddOns.IsAddOnLoaded, C_StringUtil = savedIsLoaded, savedStringUtil
      AuraUtil.IsValidFilterString = savedValidFilter
      AuraContainerSortMethod, AuraContainerSortDirection = savedSortMethod, savedSortDirection
    end
  end
end

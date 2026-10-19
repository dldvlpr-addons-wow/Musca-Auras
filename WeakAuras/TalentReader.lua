-- Musca Auras, GPL-2.0. Talent data reader by dldvlpr; the talent check frame, WeakAuras.GetTalentById and
-- WeakAuras.CheckTalentId come from WeakAuras (The WeakAuras Team, GPL-2.0). See CHANGES.md.
-- Talent reader: the talents of the active configuration, for the talent load option and the talent trigger.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

if not Private.traitTalents then return end

Private.GetTalentConfigID = function()
  return C_SpecializationInfo.GetCombatConfigIDForSpecGroup(C_SpecializationInfo.GetActiveSpecGroup())
end

local function VisitTraitNodes(configId, visit)
  local configInfo = configId and C_Traits.GetConfigInfo(configId)
  if not configInfo then
    return false
  end
  for _, treeId in ipairs(configInfo.treeIDs or {}) do
    for _, nodeId in ipairs(C_Traits.GetTreeNodes(treeId) or {}) do
      local node = C_Traits.GetNodeInfo(configId, nodeId)
      if node and node.ID ~= 0 then
        visit(node)
      end
    end
  end
  return true
end

local function CompareTalentLayout(left, right)
  local a, b = left[3], right[3]
  local sameRow, sameColumn = a[2] == b[2], a[1] == b[1]
  if sameRow and sameColumn then
    return left[1] < right[1]
  end
  if sameRow then
    return a[1] < b[1]
  end
  return a[2] < b[2]
end

local function ListEdgeTargets(configId, node)
  local linkedEntries = {}
  for _, edge in ipairs(node.visibleEdges or {}) do
    local targetNode = C_Traits.GetNodeInfo(configId, edge.targetNode)
    local firstEntry = targetNode and targetNode.entryIDs and targetNode.entryIDs[1]
    if firstEntry then
      linkedEntries[#linkedEntries + 1] = firstEntry
    end
  end
  return linkedEntries
end

function Private.GetTalentData(specId)
  local list, entriesPerNode = {}, {}
  local playerSpec = Private.ExecEnv.GetSpecialization()
  if not playerSpec or specId ~= Private.ExecEnv.GetSpecializationInfo(playerSpec) then
    return list, {}, entriesPerNode
  end

  local activeConfig = Private.GetTalentConfigID()
  VisitTraitNodes(activeConfig, function(node)
    local configId = activeConfig
    local entryIds = node.entryIDs or {}
    local linkedEntries
    for index, entryId in ipairs(entryIds) do
      local entryInfo = C_Traits.GetEntryInfo(configId, entryId)
      local definitionId = entryInfo and entryInfo.definitionID
      local traitDefinition = definitionId and C_Traits.GetDefinitionInfo(definitionId)
      local spellId = traitDefinition and traitDefinition.spellID
      if spellId then
        linkedEntries = linkedEntries or ListEdgeTargets(configId, node)
        local record = {
          entryId,
          spellId,
          {node.posX, node.posY, index, #entryIds},
          linkedEntries,
          node.maxRanks
        }
        list[#list + 1] = record
        local siblings = entriesPerNode[node.ID]
        if not siblings then
          siblings = {}
          entriesPerNode[node.ID] = siblings
        end
        siblings[index] = record
      end
    end
  end)

  table.sort(list, CompareTalentLayout)
  return list, {}, entriesPerNode
end

local talentWatcher = CreateFrame("Frame")
Private.frames["WeakAuras talentCheckFrame"] = talentWatcher
for _, eventName in ipairs({
  "PLAYER_LOGIN",
  "PLAYER_SPECIALIZATION_CHANGED",
  "PLAYER_TALENT_UPDATE",
  "ACTIVE_TALENT_GROUP_CHANGED",
  "TRAIT_CONFIG_UPDATED",
  "TRAIT_CONFIG_CREATED",
  "ACTIVE_COMBAT_CONFIG_CHANGED"
}) do
  talentWatcher:RegisterEvent(eventName)
end

local selectedTalentsById = {}

function Private.CheckTalentsForLoad()
  Private.StartProfileSystem("talent")
  local chosen = {}
  local configId = Private.GetTalentConfigID()

  VisitTraitNodes(configId, function(node)
    local choice = node.activeEntry
    local subTreeInactive = false
    if node.subTreeID then
      local subTreeInfo = C_Traits.GetSubTreeInfo(configId, node.subTreeID)
      subTreeInactive = not (subTreeInfo and subTreeInfo.isActive)
    end
    for _, entryId in ipairs(node.entryIDs or {}) do
      local entryInfo = C_Traits.GetEntryInfo(configId, entryId)
      local definitionId = entryInfo and entryInfo.definitionID
      if definitionId then
        local traitDefinition = C_Traits.GetDefinitionInfo(definitionId)
        local rank = node.activeRank
        if choice then
          rank = entryId == choice.entryID and choice.rank or 0
        end
        if subTreeInactive then
          rank = 0
        end
        chosen[entryId] = {rank = rank, spellId = traitDefinition and traitDefinition.spellID}
      end
    end
  end)

  selectedTalentsById = chosen
  Private.ScanForLoads(nil, "WA_TALENT_UPDATE")
  Private.ScanEvents("WA_TALENT_UPDATE")
  Private.StopProfileSystem("talent")
end

talentWatcher:SetScript("OnEvent", Private.CheckTalentsForLoad)

---@param talentId integer
---@return string? spellName
---@return number? icon
---@return number? spellId
---@return number? rank
function WeakAuras.GetTalentById(talentId)
  if selectedTalentsById[talentId] then
    local spellName, _, icon = Private.ExecEnv.GetSpellInfo(selectedTalentsById[talentId].spellId)
    return spellName, icon, selectedTalentsById[talentId].spellId, selectedTalentsById[talentId].rank
  end
end

---@param talentId integer
---@return boolean hasTalent
function WeakAuras.CheckTalentId(talentId)
  return selectedTalentsById[talentId] and selectedTalentsById[talentId].rank > 0
end

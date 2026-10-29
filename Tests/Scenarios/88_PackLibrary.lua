-- The class HUD blocks of the Packs page: each block of each class pack has an enUS and a frFR title and description,
-- and the import of one block carries the installed HUD as it is installed (the update import deletes the auras it
-- does not carry and changes the ones that differ) and moves a block whose anchor block is missing to its own
-- position on screen.
local classes = {
  WARRIOR = "Guerrier", PALADIN = "Paladin", HUNTER = "Chasseur", ROGUE = "Voleur", PRIEST = "Pretre",
  SHAMAN = "Chaman", MAGE = "Mage", WARLOCK = "Demoniste", DRUID = "Druide",
}

local function ReadFile(path)
  local file = assert(io.open(path, "rb"))
  local text = file:read("*a")
  file:close()
  return text
end

local function DeepCopy(value)
  if type(value) ~= "table" then return value end
  local copy = {}
  for key, inner in pairs(value) do copy[key] = DeepCopy(inner) end
  return copy
end

local function LoadOptionsFile(path, env, OptionsPrivate)
  local chunk = assert(loadfile(path))
  setfenv(chunk, env)(nil, OptionsPrivate)
end

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {} })
  local installed, installedIds = {}, {}
  local OptionsPrivate = {
    Private = setmetatable({ GetDataByUID = function(uid) return installed[uid] end }, { __index = private }),
  }
  local env = {
    WeakAuras = {
      IsLibsOK = function() return true end, GetData = function(id) return installedIds[id] end,
      versionString = "test version",
    },
    select = select, type = type, ipairs = ipairs, pairs = pairs, tinsert = table.insert, CopyTable = DeepCopy,
  }
  -- Installs copies of pack auras; the root keeps only the installed blocks among its children.
  local function Install(list)
    installed, installedIds = {}, {}
    for _, data in ipairs(list) do
      data = DeepCopy(data)
      installed[data.uid] = data
      installedIds[data.id] = data
    end
    for _, data in pairs(installedIds) do
      if data.controlledChildren then
        local kept = {}
        for _, id in ipairs(data.controlledChildren) do
          if installedIds[id] and installedIds[id].parent == data.id then kept[#kept + 1] = id end
        end
        data.controlledChildren = kept
      end
    end
  end
  LoadOptionsFile("WeakAurasOptions/ClassPacks.lua", env, OptionsPrivate)
  LoadOptionsFile("WeakAurasOptions/PackLibrary.lua", env, OptionsPrivate)
  local enUS = ReadFile("WeakAurasOptions/Locales/enUS.lua")
  local frFR = ReadFile("WeakAurasOptions/Locales/frFR.lua")
  local problems = {}
  local function Problem(text) problems[#problems + 1] = text end
  for _, key in ipairs({ "Packs", "Class HUD", "Whole HUD",
    "Whole HUD updates every block to the pack settings. A single block leaves the other installed blocks as they are." }) do
    if not enUS:find('L["' .. key .. '"] = ', 1, true) then Problem("enUS: missing " .. key) end
    if not frFR:find('L["' .. key .. '"] = ', 1, true) then Problem("frFR: missing " .. key) end
  end

  for class, folder in pairs(classes) do
    local classPack = assert(OptionsPrivate.classPacks[class], class)
    local pack = dofile("Tests/Packs/" .. folder .. "/Pack" .. folder .. ".lua")
    local expected = {}
    for _, child in ipairs(pack.c) do
      if child.parent == pack.d.id then expected[#expected + 1] = child end
    end
    local blocks = OptionsPrivate.GetClassPackBlocks(classPack)
    if #blocks ~= #expected then Problem(class .. ": " .. #blocks .. " blocks, " .. #expected .. " expected") end
    for index, block in ipairs(blocks) do
      if block.data.id ~= (expected[index] and expected[index].id) then Problem(class .. ": block " .. block.data.id) end
      if #block.members ~= #block.data.controlledChildren then Problem(block.data.id .. ": members missing") end
      local texts = OptionsPrivate.classPackBlockTexts[block.label]
      if not texts then
        Problem(block.data.id .. ": no title for " .. block.label)
      else
        for _, key in ipairs(texts) do
          if not enUS:find('L["' .. key .. '"] = ', 1, true) then Problem("enUS: missing " .. key) end
          if not frFR:find('L["' .. key .. '"] = ', 1, true) then Problem("frFR: missing " .. key) end
        end
      end
    end

    local function Import(label)
      local data = OptionsPrivate.BuildClassPackBlockImport(classPack, label)
      local byId = { [data.d.id] = data.d }
      for _, child in ipairs(data.c) do
        byId[child.id] = child
        if not (child.parent == data.d.id or byId[child.parent]) then
          Problem(child.id .. ": parent " .. tostring(child.parent) .. " not imported before it")
        end
      end
      for _, holder in ipairs({ data.d, unpack(data.c) }) do
        local listed = {}
        for _, id in ipairs(holder.controlledChildren or {}) do
          listed[id] = true
          if not byId[id] then Problem(holder.id .. ": child " .. id .. " not imported") end
        end
        for _, child in ipairs(data.c) do
          if child.parent == holder.id and not listed[child.id] then
            Problem(holder.id .. ": child " .. child.id .. " missing from controlledChildren")
          end
        end
      end
      return data, byId
    end

    local prefix = assert(pack.d.id:match("^(.-) %(Musca%)$"), pack.d.id)
    local resourceId, mainId, barsId = prefix .. " - Resource", prefix .. " - Main", prefix .. " - Bars"
    local function PackAuras(blockIds)
      local list = { pack.d }
      for _, child in ipairs(pack.c) do
        if blockIds[child.id] or blockIds[child.parent] then
          list[#list + 1] = child
          blockIds[child.id] = true
        end
      end
      return list
    end

    -- Nothing installed: only the block, placed on its own.
    Install({})
    local data, byId = Import("Bars")
    if #data.d.controlledChildren ~= 1 or data.d.controlledChildren[1] ~= barsId then
      Problem(class .. ": a fresh Bars import carries " .. #data.d.controlledChildren .. " block(s)")
    end
    local bars = byId[barsId]
    if bars.anchorFrameType ~= "SCREEN" or bars.anchorFrameFrame or bars.selfPoint ~= "CENTER" or bars.yOffset ~= -96 then
      Problem(class .. ": Bars alone not at its own position")
    end
    data, byId = Import("Main")
    if byId[mainId].selfPoint ~= "TOP" or byId[mainId].yOffset ~= 4 or byId[mainId].anchorFrameType ~= "SCREEN" then
      Problem(class .. ": Main alone not at its own position")
    end

    -- Resource installed: the Main import brings it along and Main stays below it.
    Install(PackAuras({ [resourceId] = true }))
    data, byId = Import("Main")
    if not byId[resourceId] then Problem(class .. ": installed Resource dropped from the Main import") end
    if byId[mainId].anchorFrameFrame ~= "WeakAuras:" .. resourceId then
      Problem(class .. ": Main not anchored below the installed Resource")
    end
    if byId[barsId] then Problem(class .. ": Bars imported without being picked or installed") end
    if data.s ~= env.WeakAuras.versionString then Problem(class .. ": installed auras sent for ForeverAuras conversion") end

    -- Resource renamed by the user: Main anchors below the installed id.
    Install(PackAuras({ [resourceId] = true }))
    local renamed = installedIds[resourceId]
    installedIds[resourceId], installedIds["Renamed " .. class] = nil, renamed
    renamed.id = "Renamed " .. class
    installed[pack.d.uid].controlledChildren = { renamed.id }
    for _, member in pairs(installed) do
      if member.parent == resourceId then member.parent = renamed.id end
    end
    data, byId = Import("Main")
    if byId[mainId].anchorFrameFrame ~= "WeakAuras:" .. renamed.id then
      Problem(class .. ": Main anchored to " .. tostring(byId[mainId].anchorFrameFrame) .. " instead of the renamed Resource")
    end

    -- Resource installed outside the HUD group: not counted, Main goes to its own position.
    Install(PackAuras({ [resourceId] = true }))
    installedIds[resourceId].parent = nil
    installed[pack.d.uid].controlledChildren = {}
    data, byId = Import("Main")
    if byId[resourceId] then Problem(class .. ": Resource outside the HUD imported into it") end
    if byId[mainId].anchorFrameType ~= "SCREEN" then Problem(class .. ": Main anchored to a Resource outside the HUD") end

    -- Whole HUD installed: a block import carries every block with its pack anchors, in pack order.
    Install(PackAuras((function() local all = {} for _, block in ipairs(expected) do all[block.id] = true end return all end)()))
    data, byId = Import("Main")
    if #data.c ~= #pack.c then Problem(class .. ": " .. #data.c .. " auras imported, " .. #pack.c .. " in the pack") end
    for index, original in ipairs(expected) do
      local copy = byId[original.id]
      if copy.anchorFrameFrame ~= original.anchorFrameFrame or copy.yOffset ~= original.yOffset then
        Problem(original.id .. ": anchor changed although its anchor block is installed")
      end
      if data.d.controlledChildren[index] ~= original.id then Problem(original.id .. ": block moved in the HUD") end
    end

    -- Installed changes survive the import of another block, and the update preference is not sent.
    local root = installed[pack.d.uid]
    local resource = installedIds[resourceId]
    resource.yOffset = 123
    local userAura = { id = "User aura " .. class, uid = "user-" .. class, parent = resourceId, regionType = "text" }
    installed[userAura.uid], installedIds[userAura.id] = userAura, userAura
    tinsert(resource.controlledChildren, userAura.id)
    OptionsPrivate.PreferClassPackUpdate(classPack)
    if root.preferToUpdate ~= true then Problem(class .. ": installed HUD not set to update") end
    data, byId = Import("Main")
    if byId[resourceId].yOffset ~= 123 then Problem(class .. ": installed Resource position replaced by the pack") end
    if not byId[userAura.id] then Problem(class .. ": aura added by the user dropped") end
    if data.d.preferToUpdate ~= nil then Problem(class .. ": preferToUpdate sent in the import") end
    if root.preferToUpdate ~= true then Problem(class .. ": import data built on the installed root") end

    -- A Main aura moved by the user under Resource: the Main import sends it once, back in Main.
    Install(PackAuras((function() local all = {} for _, block in ipairs(expected) do all[block.id] = true end return all end)()))
    local mainBlock = installedIds[mainId]
    local movedId = table.remove(mainBlock.controlledChildren, 1)
    installedIds[movedId].parent = resourceId
    tinsert(installedIds[resourceId].controlledChildren, movedId)
    data, byId = Import("Main")
    local seen = {}
    for _, child in ipairs(data.c) do
      if seen[child.id] then Problem(class .. ": " .. child.id .. " sent twice") end
      seen[child.id] = true
    end
    if byId[movedId].parent ~= mainId then Problem(class .. ": moved aura not back in Main") end
    for _, id in ipairs(byId[resourceId].controlledChildren) do
      if id == movedId then Problem(class .. ": moved aura still listed under Resource") end
    end

    -- An aura the user put in Main survives the Main import, inside Main.
    Install(PackAuras((function() local all = {} for _, block in ipairs(expected) do all[block.id] = true end return all end)()))
    local mainAura = { id = "User Main aura " .. class, uid = "user-main-" .. class, parent = mainId, regionType = "text" }
    installed[mainAura.uid], installedIds[mainAura.id] = mainAura, mainAura
    tinsert(installedIds[mainId].controlledChildren, mainAura.id)
    data, byId = Import("Main")
    if not byId[mainAura.id] then Problem(class .. ": aura added by the user in Main dropped")
    elseif byId[mainAura.id].parent ~= mainId then Problem(class .. ": user aura moved out of Main") end

    -- A pack aura of an older version, no longer in the pack, is not kept by the Main import.
    local packPrefix = pack.d.uid:sub(1, -9)
    local oldAura = { id = "Old pack aura " .. class, uid = packPrefix .. "00000000", parent = mainId, regionType = "text" }
    installed[oldAura.uid], installedIds[oldAura.id] = oldAura, oldAura
    tinsert(installedIds[mainId].controlledChildren, oldAura.id)
    data, byId = Import("Main")
    if byId[oldAura.id] then Problem(class .. ": pack aura dropped by the pack kept in Main") end
    if not byId[mainAura.id] then Problem(class .. ": user aura dropped next to an old pack aura") end
  end
  -- The cached pack is not touched by the anchor fix: a later fresh import still finds the pack anchors.
  Install({})
  local again = OptionsPrivate.GetClassPackBlocks(OptionsPrivate.classPacks.MAGE)
  for _, block in ipairs(again) do
    if block.label == "Bars" and block.data.anchorFrameType ~= "SELECTFRAME" then Problem("MAGE: cached Bars modified") end
  end
  assert(#problems == 0, #problems .. " pack library problem(s):\n" .. table.concat(problems, "\n"))
end

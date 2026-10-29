if not WeakAuras.IsLibsOK() then return end
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

-- Title and description of each class HUD block on the Packs page, by the label after " - " in the block id.
OptionsPrivate.classPackBlockTexts = {
  Reminders = { "Reminders", "Warns when a class buff is missing or fading, or when your resource runs low" },
  Range = { "Melee Range", "Red text when your target is out of melee range, in combat" },
  Procs = { "Procs", "Lights up when a proc or a reactive ability can be used" },
  Effects = { "Buffs and Debuffs", "Your buffs, and your debuffs on the target, with their time left" },
  Segments = { "Stack Segments", "One segment per stack of a key buff" },
  Points = { "Combo Points", "Combo points as pips above the resource bar" },
  Resource = { "Resource Bars", "Mana, rage or energy bar, plus the form bar for druids" },
  Main = { "Rotation", "Rotation spells with their cooldown, in a grid" },
  Utility = { "Cooldowns", "Utility and defensive cooldowns, trinkets and racials" },
  Bars = { "Timer Bars", "Cast bar and target cast, plus the swing timer, pet health or five second rule of your class" },
  Upkeep = { "Upkeep", "Long buffs and weapon enchants to keep up" },
  Totems = { "Totems", "Your four totem slots with their time left and their buffs" },
}

-- Position of a block imported without the block it is anchored below.
-- shortcut: mirrors the Group() positions of Tests/Packs/PackBuilder.lua, update both together.
local standalonePositions = {
  Main = { "TOP", 4 }, Utility = { "TOP", -30 }, Bars = { "CENTER", -96 },
  Upkeep = { "CENTER", -176 }, Totems = { "CENTER", -204 },
}

local decodedPacks = {}

local function LabelOf(id)
  return id:match(" %- (.+)$")
end

-- The decoded class pack and its blocks in export order: { label, data, members }.
local function Decode(classPack)
  if decodedPacks[classPack] then
    return decodedPacks[classPack]
  end
  local received = OptionsPrivate.Private.StringToTable(classPack, true)
  if type(received) ~= "table" or type(received.d) ~= "table" then
    return nil
  end
  local pack = { received = received, blocks = {} }
  local blockOf = {}
  for _, child in ipairs(received.c or {}) do
    if child.parent == received.d.id then
      local block = { label = LabelOf(child.id) or child.id, data = child, members = {} }
      tinsert(pack.blocks, block)
      blockOf[child.id] = block
    elseif blockOf[child.parent] then
      blockOf[child.id] = blockOf[child.parent]
      tinsert(blockOf[child.parent].members, child)
    end
  end
  decodedPacks[classPack] = pack
  return pack
end

function OptionsPrivate.GetClassPackBlocks(classPack)
  local pack = Decode(classPack)
  return pack and pack.blocks or {}
end

-- Copy of installed data as an export carries it.
local function StripNonTransmissable(data, fields)
  for key, value in pairs(fields) do
    if type(value) == "table" and type(data[key]) == "table" then
      StripNonTransmissable(data[key], value)
    elseif value == true then
      data[key] = nil
    end
  end
end

local function CopyInstalled(data)
  local copy = CopyTable(data)
  StripNonTransmissable(copy, OptionsPrivate.Private.non_transmissable_fields_v2000)
  return copy
end

local function IsSkipped(id, skipUids)
  local data = WeakAuras.GetData(id)
  return data and skipUids[data.uid]
end

-- Installed children of a group, parents before their children. The skipped auras come from the pack: an installed
-- copy outside its block, moved by the user or by an older pack, would send the same id twice. A holder takes the
-- direct children in place of data.
local function AddInstalledChildren(children, data, skipUids, holder)
  for _, id in ipairs(data.controlledChildren or {}) do
    local child = WeakAuras.GetData(id)
    if child and not skipUids[child.uid] then
      local copy = CopyInstalled(child)
      if holder then
        copy.parent = holder.id
        tinsert(holder.controlledChildren, copy.id)
      end
      if copy.controlledChildren then
        local kept = {}
        for _, childId in ipairs(copy.controlledChildren) do
          if not IsSkipped(childId, skipUids) then
            tinsert(kept, childId)
          end
        end
        copy.controlledChildren = kept
      end
      tinsert(children, copy)
      AddInstalledChildren(children, child, skipUids)
    end
  end
end

-- Import data for one block of a class pack. An installed HUD comes along as it is installed: the update import
-- removes the installed auras missing from the import, and changes the ones that differ from it.
function OptionsPrivate.BuildClassPackBlockImport(classPack, label)
  local pack = Decode(classPack)
  if not pack then
    return nil
  end
  local picked
  for _, block in ipairs(pack.blocks) do
    if block.label == label then
      picked = block
    end
  end
  if not picked then
    return nil
  end
  local installedRoot = OptionsPrivate.Private.GetDataByUID(pack.received.d.uid)
  local root = installedRoot and CopyInstalled(installedRoot) or CopyTable(pack.received.d)
  local children = {}
  local skipUids = { [picked.data.uid] = true }
  for _, member in ipairs(picked.members) do
    skipUids[member.uid] = true
  end
  if installedRoot then
    AddInstalledChildren(children, installedRoot, skipUids)
  end
  -- Pack ids of the blocks in the import, with their installed id, for the anchors of the picked block.
  local included = { [picked.data.id] = picked.data.id }
  for _, block in ipairs(pack.blocks) do
    local installed = installedRoot and OptionsPrivate.Private.GetDataByUID(block.data.uid)
    if installed and installed.parent == installedRoot.id then
      included[block.data.id] = installed.id
    end
  end

  local block = CopyTable(picked.data)
  local found = OptionsPrivate.Private.GetDataByUID(block.uid)
  local installedBlock = found and installedRoot and found.parent == installedRoot.id and found or nil
  if installedBlock then
    block.id = installedBlock.id
  end
  block.parent = root.id
  local target = block.anchorFrameType == "SELECTFRAME" and block.anchorFrameFrame
    and block.anchorFrameFrame:match("^WeakAuras:(.+)$")
  local position = target and not included[target] and standalonePositions[picked.label]
  if target and included[target] then
    block.anchorFrameFrame = "WeakAuras:" .. included[target]
  elseif position then
    block.anchorFrameType = "SCREEN"
    block.anchorFrameFrame = nil
    block.anchorFrameParent = nil
    block.anchorPoint = "CENTER"
    block.selfPoint = position[1]
    block.yOffset = position[2]
  end
  local members = {}
  for _, member in ipairs(picked.members) do
    member = CopyTable(member)
    if member.parent == picked.data.id then
      member.parent = block.id
    end
    tinsert(members, member)
  end
  -- Only the pack auras go through the ForeverAuras conversion: it would rerun migrations on installed auras.
  local senderVersion = pack.received.s
  if installedRoot then
    OptionsPrivate.Private.ConvertForeverAurasImport(block, members)
    senderVersion = WeakAuras.versionString
  end
  tinsert(children, block)
  for _, member in ipairs(members) do
    tinsert(children, member)
  end
  -- Auras the user put in the picked block stay in it, after the pack auras. A pack aura that this pack version no
  -- longer has goes away, as in a whole HUD update: every pack uid is the pack prefix and 8 hex digits.
  if installedBlock then
    local packUids, packPrefix = {}, pack.received.d.uid:sub(1, -9)
    for _, aura in ipairs(pack.received.c or {}) do
      packUids[aura.uid] = true
    end
    for _, id in ipairs(installedBlock.controlledChildren or {}) do
      local child = WeakAuras.GetData(id)
      if child and child.uid and not packUids[child.uid] and child.uid:sub(1, -9) == packPrefix then
        skipUids[child.uid] = true
      end
    end
    AddInstalledChildren(children, installedBlock, skipUids, block)
  end

  -- The picked block keeps its place in an installed HUD, or comes last.
  local controlledChildren, placed = {}, false
  for _, id in ipairs(installedRoot and installedRoot.controlledChildren or {}) do
    local child = WeakAuras.GetData(id)
    if child and child.uid == block.uid then
      tinsert(controlledChildren, block.id)
      placed = true
    elseif child and not skipUids[child.uid] then
      tinsert(controlledChildren, id)
    end
  end
  if not placed then
    tinsert(controlledChildren, block.id)
  end
  root.controlledChildren = controlledChildren
  return { m = "d", d = root, c = children, v = pack.received.v, s = senderVersion }
end

-- The update dialog offers to update an installed HUD, as the class pack popups do, instead of a copy.
function OptionsPrivate.PreferClassPackUpdate(classPack)
  local pack = Decode(classPack)
  local installedRoot = pack and OptionsPrivate.Private.GetDataByUID(pack.received.d.uid)
  if installedRoot then
    installedRoot.preferToUpdate = true
  end
end

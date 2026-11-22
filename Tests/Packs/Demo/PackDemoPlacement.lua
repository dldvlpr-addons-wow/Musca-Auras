-- Demo for the placement mode (/wa unlock): the warrior HUD in the middle and the utility packs around the screen,
-- as copies under their own names, so the installed packs stay untouched. One pack of each corner is placed on the
-- screen, the others follow it through anchor links.
local ROOT = "Musca Demo - Full Screen"
local PREFIX = "Demo "

local children, roots = {}, {}

local function Renamed(value, names)
  if type(value) == "string" then
    if names[value] then return names[value] end
    local target = value:match("^WeakAuras:(.+)$")
    return target and names[target] and "WeakAuras:" .. names[target] or value
  elseif type(value) == "table" then
    for key, item in pairs(value) do value[key] = Renamed(item, names) end
  end
  return value
end

-- Adds the pack of the file as a sub group; every aura id and every link to one get the prefix.
local function Add(path)
  local pack = dofile(path)
  local names = { [pack.d.id] = PREFIX .. pack.d.id }
  for _, child in ipairs(pack.c) do names[child.id] = PREFIX .. child.id end
  local group = Renamed(pack.d, names)
  group.parent, group.uid = ROOT, "demo" .. group.uid
  children[#children + 1], roots[#roots + 1] = group, group.id
  for _, child in ipairs(pack.c) do
    child = Renamed(child, names)
    child.uid = "demo" .. child.uid
    children[#children + 1] = child
  end
  return group
end

local function Utility(folder)
  return Add("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".lua")
end

-- In a group, SCREEN is the parent group: UIPARENT anchors to the real screen edges.
local function Screen(group, point, selfPoint, x, y)
  group.anchorFrameType, group.anchorFrameFrame, group.anchorFrameParent = "UIPARENT", nil, nil
  group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset = point, selfPoint, x, y
  return group
end

-- The link the placement mode stores: selfPoint of the group on the anchorPoint of the target.
local function Link(group, target, selfPoint, anchorPoint, x, y)
  group.anchorFrameType, group.anchorFrameFrame, group.anchorFrameParent = "SELECTFRAME", "WeakAuras:" .. target.id, false
  group.selfPoint, group.anchorPoint, group.xOffset, group.yOffset = selfPoint, anchorPoint, x, y
  return group
end

-- Middle: the class HUD at its own place, the flash of ready cooldowns and the center dot.
Add("Tests/Packs/Guerrier/PackGuerrier.lua")
Utility("ReadyFlash")
Utility("CenterMark")
Utility("CombatText")

-- Top: experience bar on the screen edge, the buff rows hang under it one after the other.
local level = Screen(Utility("LevelProgress"), "TOP", "TOP", 0, -8)
local buffs = Link(Utility("BuffCheck"), level, "TOP", "BOTTOM", 0, -10)
local raid = Link(Utility("RaidCoverage"), buffs, "TOP", "BOTTOM", 0, -8)
Link(Utility("PrePullCheck"), raid, "TOP", "BOTTOM", 0, -8)

-- Top left corner.
local world = Screen(Utility("WorldReminders"), "TOPLEFT", "TOPLEFT", 30, -30)
Link(Utility("Campfire"), world, "TOPLEFT", "BOTTOMLEFT", 0, -10)

-- Left edge: texts and the equipment sets in a column.
local stats = Screen(Utility("CharacterStats"), "LEFT", "LEFT", 20, 60)
local experience = Link(Utility("GroupExperience"), stats, "TOPLEFT", "BOTTOMLEFT", 0, -14)
Link(Utility("EquipmentSets"), experience, "TOPLEFT", "BOTTOMLEFT", 0, -14)

-- Right edge: debuffs of the target, the shields under them.
local debuffs = Screen(Utility("TargetDebuffs"), "RIGHT", "TOP", -150, 140)
Link(Utility("ShieldMeter"), debuffs, "TOP", "BOTTOM", 0, -40)

-- Bottom corners: supplies on the left, combat items on the right with the engineering items above.
Screen(Utility("ConjuredSupplies"), "BOTTOMLEFT", "BOTTOMLEFT", 30, 40)
local items = Screen(Utility("CombatItems"), "BOTTOMRIGHT", "TOP", -200, 150)
Link(Utility("EngineeringItems"), items, "BOTTOM", "TOP", 0, 10)

local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
local root = {
  id = ROOT, uid = "mcDemoFullScreen00", regionType = "group", internalVersion = 91, tocversion = 16001,
  triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, untrigger = {} },
    activeTriggerMode = -10 },
  load = { use_class = true, class = { single = "WARRIOR", multi = {} }, size = { multi = {} }, spec = { multi = {} },
    talent = { multi = {} } },
  conditions = {}, config = {}, authorOptions = {},
  actions = { start = {}, finish = {}, init = {} }, animation = { start = step, main = step, finish = step },
  subRegions = {}, information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = 0, yOffset = 0,
  controlledChildren = roots,
}

return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }

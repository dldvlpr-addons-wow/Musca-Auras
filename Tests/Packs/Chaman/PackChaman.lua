local ROOT = "Chaman (Forever)"
local ROTATION = "Chaman - Rotation"
local BUFFS = "Chaman - Buffs"

local RED = {1, 0.3, 0.3, 1}

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 14, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
end

local function Animation()
  local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
  return { start = step, main = step, finish = step }
end

local function Load(options)
  local load = { use_class = true, class = { single = "SHAMAN", multi = {} },
    size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } }
  if options.outOfCombat then load.use_combat = false end
  if options.known then load.use_spellknown = true load.spellknown = options.known end
  return load
end

local function Base(id, uid, parent, regionType, trigger, options)
  return {
    id = id, uid = uid, parent = parent, regionType = regionType, internalVersion = 91, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = Load(options), conditions = options.conditions or {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(),
    subRegions = options.subRegions or {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  }
end

local function Icon(id, uid, parent, trigger, options)
  options = options or {}
  local data = Base(id, uid, parent, "icon", trigger, options)
  data.width, data.height = options.size or 44, options.size or 44
  data.iconSource, data.displayIcon = -1, options.icon
  data.cooldown, data.cooldownTextDisabled = true, false
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  return data
end

local function Ids(ids)
  local list = {}
  for index, spellId in ipairs(ids) do list[index] = tostring(spellId) end
  return list
end

local function Buff(ids, showOn, unit, kind)
  return { type = "secretAura", unit = unit or "player", debuffType = kind or "HELPFUL",
    useExactSpellId = true, auraspellids = Ids(ids), secretUseSpellIDs = true,
    nativeFilters = { PLAYER = true }, secretShowOn = showOn }
end

local function Cooldown(spellId)
  return { type = "spell", event = "Cooldown Progress (Spell)", spellName = spellId,
    use_exact_spellName = false, genericShowOn = "showAlways", use_genericShowOn = true,
    use_desaturateOnCooldown = true, desaturateOnCooldown = true,
    unit = "player", names = {}, spellIds = {}, subeventPrefix = "SPELL", subeventSuffix = "_CAST_START",
    debuffType = "HELPFUL" }
end

local function Totem(slot)
  return { type = "spell", event = "Totem", use_totemType = true, totemType = slot,
    unit = "player", names = {}, spellIds = {}, subeventPrefix = "SPELL", subeventSuffix = "_CAST_START",
    debuffType = "HELPFUL" }
end

local function WeaponEnchant(showOn)
  return { type = "item", event = "Weapon Enchant", weapon = "main", use_weapon = true,
    showOn = showOn, use_showOn = true,
    unit = "player", names = {}, spellIds = {}, subeventPrefix = "SPELL", subeventSuffix = "_CAST_START",
    debuffType = "HELPFUL" }
end

local function Mana(threshold)
  local trigger = { type = "unit", event = "Power", unit = "player", use_unit = true,
    use_powertype = true, powertype = 0,
    names = {}, spellIds = {}, subeventPrefix = "SPELL", subeventSuffix = "_CAST_START", debuffType = "HELPFUL" }
  if threshold then trigger.use_nativeThreshold = true trigger.nativeThreshold = tostring(threshold) end
  return trigger
end

local function Condition(variable, value, property, change, op)
  return { check = { trigger = 1, variable = variable, value = value, op = op },
    changes = { { property = property, value = change } } }
end

local outOfRange = Condition("spellInRange", 0, "color", RED)
local noMana = Condition("insufficientResources", 1, "color", {0.4, 0.5, 1, 1})

local function Spell(id, uid, spellId, icon, known)
  return Icon(id, uid, ROTATION, Cooldown(spellId),
    { icon = icon, known = known, conditions = { noMana, outOfRange } })
end

local lightningShield = { 324, 325, 905, 945, 8134, 10431, 10432 }
local flameShock = { 8050, 8052, 8053, 10447, 10448, 29228 }
local flurry = { 16257, 12966, 17687 }
local timer = Text("%p", "CENTER", 14)
local missing = Text("!", "CENTER", 22)

local rotation = {
  Icon("Horion de flammes (cible)", "mcShamPkFlameSh", ROTATION, Buff(flameShock, "showOnActive", "target", "HARMFUL"),
    { icon = 135813, subRegions = { timer },
      conditions = { Condition("faAuraRemaining", 4, "sub.1.text_color", RED, "<") } }),
  Spell("Horion de terre", "mcShamPkEShock", 8042, 136026),
  Spell("Frappe-tempête", "mcShamPkStorm", 17364, 135963, 17364),
  Spell("Chaîne d'éclairs", "mcShamPkChain", 421, 136015, 421),
  Spell("Nova de feu", "mcShamPkNova", 408341, 135824, 408341),
  Spell("Totem de glèbe", "mcShamPkGround", 8177, 136039, 8177),
  Spell("Rapidité de la nature", "mcShamPkNSwift", 16188, 136076, 16188),
  Spell("Totem de vague de mana", "mcShamPkManaTide", 16190, 135861, 16190),
  Icon("Idées claires", "mcShamPkClear", ROTATION, Buff({ 16246 }, "showOnActive"), { icon = 136170 }),
  Icon("Rafale", "mcShamPkFlurry", ROTATION, Buff(flurry, "showOnActive"),
    { icon = 132152, subRegions = { Text("%s", "INNER_BOTTOMRIGHT", 13) } }),
}

local buffs = {
  Icon("Bouclier de foudre", "mcShamPkLShield", BUFFS, Buff(lightningShield, "showOnActive"),
    { size = 34, subRegions = { Text("%s", "INNER_BOTTOMRIGHT", 12), timer },
      conditions = { Condition("faAuraRemaining", 60, "sub.2.text_color", RED, "<") } }),
  Icon("Manque : Bouclier de foudre", "mcShamPkLSMiss", BUFFS, Buff(lightningShield, "showOnMissing"),
    { size = 34, icon = 136051, outOfCombat = true, subRegions = { missing } }),
  Icon("Arme enchantée", "mcShamPkWeapon", BUFFS, WeaponEnchant("showOnActive"), { size = 34 }),
  Icon("Manque : enchantement d'arme", "mcShamPkWeapMiss", BUFFS, WeaponEnchant("showOnMissing"),
    { size = 34, icon = 136086, outOfCombat = true, subRegions = { missing } }),
  Icon("Totem de feu", "mcShamPkFireTot", BUFFS, Totem(1), { size = 34, subRegions = { timer } }),
  Icon("Totem de terre", "mcShamPkEarthTot", BUFFS, Totem(2), { size = 34, subRegions = { timer } }),
  Icon("Totem d'eau", "mcShamPkWaterTot", BUFFS, Totem(3), { size = 34, subRegions = { timer } }),
  Icon("Totem d'air", "mcShamPkAirTot", BUFFS, Totem(4), { size = 34, subRegions = { timer } }),
}

local manaBar = Base("Chaman - Mana", "mcShamPkManaBar", ROOT, "aurabar", Mana(), {
  subRegions = { { type = "subbackground" }, { type = "subforeground" }, Text("%p", "INNER_RIGHT", 12) },
})
manaBar.width, manaBar.height = 280, 14
manaBar.barColor, manaBar.backgroundColor = {0, 0.44, 0.87, 1}, {0, 0, 0, 0.5}
manaBar.texture, manaBar.orientation, manaBar.icon = "Blizzard", "HORIZONTAL", false
manaBar.xOffset, manaBar.yOffset, manaBar.anchorPoint, manaBar.selfPoint = 0, 30, "CENTER", "CENTER"

local lowMana = Base("Chaman - Mana bas", "mcShamPkLowMana", ROOT, "text", Mana(20), {})
lowMana.displayText, lowMana.font, lowMana.fontSize, lowMana.outline = "MANA BAS", "Friz Quadrata TT", 20, "OUTLINE"
lowMana.color, lowMana.justify = {0.4, 0.6, 1, 1}, "CENTER"
lowMana.xOffset, lowMana.yOffset, lowMana.anchorPoint, lowMana.selfPoint = 0, 60, "CENTER", "CENTER"

local function DynamicGroup(id, uid, children, yOffset)
  local names = {}
  for index, child in ipairs(children) do names[index] = child.id end
  local data = Base(id, uid, ROOT, "dynamicgroup",
    { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, {})
  data.controlledChildren, data.grow, data.align, data.space, data.stagger, data.sort =
    names, "RIGHT", "CENTER", 4, 0, "none"
  data.anchorPoint, data.selfPoint, data.xOffset, data.yOffset = "CENTER", "CENTER", 0, yOffset
  return data
end

local rotationGroup = DynamicGroup(ROTATION, "mcShamPkRotation", rotation, 0)
local buffsGroup = DynamicGroup(BUFFS, "mcShamPkBuffs", buffs, -44)

local root = Base(ROOT, "mcShamPkRoot0001", nil, "group",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, {})
root.controlledChildren = { ROTATION, BUFFS, manaBar.id, lowMana.id }
root.anchorFrameType, root.anchorPoint, root.selfPoint, root.xOffset, root.yOffset =
  "SCREEN", "CENTER", "CENTER", 0, -180

local children = { rotationGroup }
for _, child in ipairs(rotation) do children[#children + 1] = child end
children[#children + 1] = buffsGroup
for _, child in ipairs(buffs) do children[#children + 1] = child end
children[#children + 1] = manaBar
children[#children + 1] = lowMana

return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }

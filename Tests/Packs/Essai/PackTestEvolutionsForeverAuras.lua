-- Test auras for the ForeverAuras 0.92.6 evolutions: a level 10 warrior and a level 17 shaman on WoW Forever.
local ROOT = "Musca Test - Evolutions FA"
local PREFIX = "mcTestEvo"

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 10, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
end

local function Animation()
  local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
  return { start = step, main = step, finish = step }
end

local function Generic(fields)
  fields.names, fields.spellIds, fields.debuffType = {}, {}, "HELPFUL"
  fields.subeventPrefix, fields.subeventSuffix = "SPELL", "_CAST_START"
  fields.unit = fields.unit or "player"
  return fields
end

local function Load(class, spec)
  local load = { size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} }, class = { multi = {} } }
  if class then load.use_class, load.class.single = true, class end
  if spec then load.use_forever_spec, load.forever_spec = true, { single = spec, multi = {} } end
  return load
end

local children = {}

local function Icon(label, trigger, x, y, load, icon)
  local data = {
    id = ROOT .. " - " .. label, uid = string.format("%s%02d", PREFIX, #children + 1), parent = ROOT,
    regionType = "icon", internalVersion = 92, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = load or Load(), conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(),
    subRegions = { Text(label, "OUTER_BOTTOM", 9) },
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
    anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = x, yOffset = y,
    width = 40, height = 40, keepAspectRatio = true, iconSource = icon and 0 or -1, displayIcon = icon and "Interface\\Icons\\" .. icon,
    cooldown = false, desaturate = false, color = {1, 1, 1, 1}, zoom = 0.1,
  }
  children[#children + 1] = data
  return data
end

local function Stance(fields)
  local trigger = Generic({ type = "unit", event = "Stance/Form/Aura" })
  for key, value in pairs(fields) do trigger[key] = value end
  return trigger
end

local function Always()
  return Generic({ type = "unit", event = "Conditions", use_alwaystrue = true })
end

local function Recolor(check)
  return { check = check, changes = { { property = "color", value = {0.2, 1, 0.2, 1} } } }
end

-- Row 1, warrior: form chosen by spell ID.
local battle = Icon("1a Posture de combat (2457)", Stance({ use_formByPosition = false, use_form = true,
  form = { single = 2457, multi = {} } }), -250, 200, Load("WARRIOR"))
battle.subRegions[#battle.subRegions + 1] = Text("%form", "CENTER", 11)
Icon("1a Posture defensive (71)", Stance({ use_formByPosition = false, use_form = true,
  form = { single = 71, multi = {} } }), -190, 200, Load("WARRIOR"))
local byPosition = Icon("1d Position 1, converti au /reload", Stance({ use_form = true,
  form = { single = 1, multi = {} } }), -130, 200, Load("WARRIOR"))
byPosition.internalVersion = 91
local condition = Icon("1c Condition Combat = vert", Stance({ use_formByPosition = false }), -70, 200, Load("WARRIOR"))
condition.conditions[1] = Recolor({ trigger = 1, variable = "form", op = "==", value = 2457 })
condition.subRegions[#condition.subRegions + 1] = Text("%form", "CENTER", 11)

-- Row 2, specializations (live change of the talent point, no /reload).
local specs = {
  { "WARRIOR", "WARRIOR_ARMS", "2 Guerrier Armes", "Ability_Rogue_Eviscerate" }, { "WARRIOR", "WARRIOR_FURY", "2 Guerrier Fureur", "Ability_Warrior_InnerRage" },
  { "WARRIOR", "WARRIOR_PROTECTION", "2 Guerrier Protection", "INV_Shield_06" }, { "SHAMAN", "SHAMAN_ELEMENTAL", "2 Chaman Elementaire", "Spell_Nature_Lightning" },
  { "SHAMAN", "SHAMAN_ENHANCEMENT", "2 Chaman Amelioration", "Spell_Nature_LightningShield" }, { "SHAMAN", "SHAMAN_RESTORATION", "2 Chaman Restauration", "Spell_Nature_MagicImmunity" },
}
for index, spec in ipairs(specs) do
  Icon(spec[3], Always(), -250 + (index - 1) * 60, 130, Load(spec[1], spec[2]), spec[4])
end
Icon("5 Spe guerrier, jamais sur chaman", Always(), 110, 130, Load(nil, "WARRIOR_ARMS"), "Ability_Rogue_Eviscerate")

-- Row 3, any class: Caster Unit warning (options only), on player and on target.
Icon("3 Caster Unit target (alerte)", Generic({ type = "unit", event = "Spell Cast Succeeded", unit = "target" }),
  -250, 60)
Icon("3 Caster Unit player (sans alerte)", Generic({ type = "unit", event = "Spell Cast Succeeded", unit = "player" }),
  -190, 60)

-- Row 4, ForeverAuras import: anchor, global alias, incompatible condition, form ID filter and condition.
local anchorTarget = Icon("6 Cible de l'ancre", Always(), -250, -10, nil, "Spell_Holy_SealOfMight")
local anchored = Icon("6 Ancre sur la cible (dessous)", Always(), 0, -40, nil, "Spell_Holy_SealOfWisdom")
anchored.anchorFrameType, anchored.anchorFrameFrame = "SELECTFRAME", "ForeverAuras:" .. anchorTarget.id
anchored.anchorPoint, anchored.selfPoint = "BOTTOM", "TOP"
local alias = Icon("7 Alias global ForeverAuras", Always(), -130, -10, nil, "INV_Misc_Book_09")
alias.subRegions[#alias.subRegions + 1] = Text("%c", "CENTER", 9)
alias.customText = "function() local name = 'Forever' .. 'Auras' return _G[name] and 'alias OK' or 'alias KO' end"
alias.customTextUpdate = "update"
local incompatible = Icon("8 Condition incompatible", Always(), -70, -10, nil, "Spell_Shadow_Teleport")
incompatible.conditions[1] = Recolor({ trigger = 1, variable = "notAVariable", op = "==", value = 1 })
local formID = Icon("9 Import FA posture combat", Stance({ use_formID = true, formID = { single = 17, multi = {} } }),
  -10, -10, Load("WARRIOR"))
formID.internalVersion = 91
local formIDCondition = Icon("9 Import FA condition Defensive = vert", Stance({ use_formID = false,
  formID = { multi = {} } }), 50, -10, Load("WARRIOR"))
formIDCondition.internalVersion = 91
formIDCondition.conditions[1] = Recolor({ trigger = 1, variable = "formID", op = "==", value = 18 })

local root = {
  id = ROOT, uid = PREFIX .. "00", regionType = "group", internalVersion = 92, tocversion = 16001,
  triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, untrigger = {} },
    activeTriggerMode = -10 },
  load = Load(), conditions = {}, config = {}, authorOptions = {},
  actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
  information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = 0, yOffset = 100,
  controlledChildren = {},
}
for _, child in ipairs(children) do root.controlledChildren[#root.controlledChildren + 1] = child.id end

return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }

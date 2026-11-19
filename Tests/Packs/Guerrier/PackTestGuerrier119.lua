-- Test auras of the 1.19 for a warrior on WoW Forever: step 15 of SUIVI-BUGS-ET-TESTS.md, one aura per check.
local ROOT = "Musca Test - Guerrier 1.19"
local PREFIX = "mcTestW119"

local BATTLE_SHOUT = { "6673", "5242", "6192", "11549", "11550", "11551", "25289" }
-- French client: a rank 1 spell ID did not cast in game, the localized name does.
local BLOODRAGE_AURA = { "29131" }
local HEARTHSTONE = 6948
local HEALING_POTION = 929

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 9, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
end

-- Unset mouse buttons do nothing; the fields given replace the defaults of the element.
local function Click(fields)
  local element = {
    type = "subclickaction", left_action = "none", left_value = "", left_macro = "", left_unit = "default",
    right_action = "none", right_value = "", right_macro = "", right_unit = "default",
    middle_action = "none", middle_value = "", middle_macro = "", middle_unit = "default",
    keybind = "", combat_mode = "visible", macro_condition = "[combat] show; hide",
  }
  for key, value in pairs(fields) do element[key] = value end
  return element
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

local function Modern(ids, extra)
  local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL", secretUseRankSpellIDs = false,
    secretUseSpellIDs = true, auraspellids = ids, nativeFilters = {}, secretShowOn = "showOnActive" }
  for key, value in pairs(extra or {}) do trigger[key] = value end
  return trigger
end

-- Aura (Modern) refuses the Click Action element: the clickable buff icons use the Aura (Legacy) trigger.
local function Legacy(ids, showOn)
  return { type = "aura2", unit = "player", debuffType = "HELPFUL", useExactSpellId = true, auraspellids = ids,
    matchesShowOn = showOn or "showOnActive" }
end

local function SpellCooldown(spell, showOn)
  return Generic({ type = "spell", event = "Cooldown Progress (Spell)", spellName = spell,
    use_exact_spellName = false, genericShowOn = showOn or "showAlways", use_genericShowOn = true })
end

local function Rage()
  return Generic({ type = "unit", event = "Power", use_unit = true, use_powertype = true, powertype = 1 })
end

local function Load()
  return { use_class = true, class = { single = "WARRIOR", multi = {} },
    size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } }
end

local children = {}

local function Base(label, regionType, trigger, x, y)
  local data = {
    id = ROOT .. " - " .. label, uid = string.format("%s%02d", PREFIX, #children + 1), parent = ROOT,
    regionType = regionType, internalVersion = 91, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = Load(), conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
    anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = x, yOffset = y,
  }
  children[#children + 1] = data
  return data
end

local function Icon(label, trigger, x, y, click)
  local data = Base(label, "icon", trigger, x, y)
  data.width, data.height, data.keepAspectRatio = 40, 40, true
  data.iconSource = -1
  data.cooldown, data.cooldownSwipe, data.cooldownEdge, data.cooldownTextDisabled = true, true, false, false
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  data.subRegions = { Text(label, "OUTER_BOTTOM"), click }
  return data
end

local function Bar(label, trigger, x, y, click)
  local data = Base(label, "aurabar", trigger, x, y)
  data.width, data.height = 180, 20
  data.barColor, data.backgroundColor = {0.8, 0.2, 0.1, 1}, {0, 0, 0, 0.5}
  data.texture, data.orientation, data.icon, data.icon_side, data.inverse = "Blizzard", "HORIZONTAL", false, "LEFT", false
  data.subRegions = { { type = "subbackground" }, { type = "subforeground" }, Text(label, "OUTER_BOTTOM"), click }
  return data
end

-- Row 1 (15.2, 15.3): Click Action on an icon, one combat mode per aura.
Icon("3 Battle Shout G sort D retrait M macro Ctrl F9", Legacy(BATTLE_SHOUT), -300, 200, Click({
  left_action = "spell", left_value = "Cri de guerre", right_action = "cancelaura", right_value = "Cri de guerre",
  middle_action = "macro", middle_macro = "/say test", keybind = "CTRL-F9" }))
Icon("12 Battle Shout manquant tout le combat", Legacy(BATTLE_SHOUT, "showOnMissing"), -180, 200,
  Click({ left_action = "spell", left_value = "Cri de guerre", combat_mode = "combat" }))
-- Hidden while Bloodrage is ready: the click has to work on the hidden aura.
Icon("13 Bloodrage toujours F10", SpellCooldown(2687, "showOnCooldown"), -60, 200,
  Click({ left_action = "spell", left_value = "2687", combat_mode = "always", keybind = "F10" }))
Icon("14 Bloodrage macro combat Maj", SpellCooldown(2687), 60, 200,
  Click({ left_action = "spell", left_value = "2687", combat_mode = "macro",
    macro_condition = "[combat,mod:shift] show; hide" }))

-- Row 2 (15.2): items and the target action.
Icon("4 Pierre de foyer G objet D cibler soi", Generic({ type = "item", event = "Cooldown Progress (Item)",
  itemName = HEARTHSTONE, genericShowOn = "showAlways", use_genericShowOn = true }), -300, 120,
  Click({ left_action = "item", left_value = tostring(HEARTHSTONE), right_action = "target", right_unit = "player" }))
local potion = Icon("4 Potion de soins G objet", Generic({ type = "item", event = "Cooldown Progress (Item)",
  itemName = HEALING_POTION, genericShowOn = "showAlways", use_genericShowOn = true }), -180, 120,
  Click({ left_action = "item", left_value = tostring(HEALING_POTION), combat_mode = "combat" }))
-- Shown only while the potion is in the bags.
potion.triggers[2] = { trigger = Generic({ type = "item", event = "Item Count", itemName = HEALING_POTION,
  use_exact_itemName = true, use_count = true, count = "0", count_operator = ">" }), untrigger = {} }
potion.triggers.disjunctive = "all"

-- Row 3 (15.2, test 9): Click Action on the other displays.
Bar("9 Barre Rage G Bloodrage", Rage(), -220, 50, Click({ left_action = "spell", left_value = "2687" }))
local text = Base("9 Texte G Battle Shout", "text", Rage(), 0, 50)
text.displayText, text.font, text.fontSize, text.outline = "CLIC TEXTE", "Friz Quadrata TT", 14, "OUTLINE"
text.color, text.justify, text.automaticWidth, text.fixedWidth, text.wordWrap =
  {1, 1, 1, 1}, "CENTER", "Auto", 200, "WordWrap"
text.subRegions = { Click({ left_action = "spell", left_value = "Cri de guerre" }) }
local ring = Base("9 Anneau G Battle Shout", "progresstexture", Rage(), 130, 50)
ring.width, ring.height = 48, 48
ring.foregroundTexture = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura3"
ring.backgroundTexture, ring.sameTexture = ring.foregroundTexture, true
ring.foregroundColor, ring.backgroundColor = {1, 0.6, 0.1, 1}, {0.2, 0.2, 0.2, 0.6}
ring.orientation, ring.startAngle, ring.endAngle, ring.inverse, ring.compress = "CLOCKWISE", 0, 360, false, false
ring.subRegions = { Text("9 Anneau G Battle Shout", "OUTER_BOTTOM"),
  Click({ left_action = "spell", left_value = "Cri de guerre" }) }
local texture = Base("9 Texture G Battle Shout", "texture", Rage(), 220, 50)
texture.width, texture.height = 48, 48
texture.subRegions = { Text("9 Texture G Battle Shout", "OUTER_BOTTOM"),
  Click({ left_action = "spell", left_value = "Cri de guerre" }) }
local empty = Base("9 Empty G Battle Shout", "empty", Rage(), 310, 50)
empty.width, empty.height = 48, 48
empty.subRegions = { Text("9 Empty ici", "CENTER"), Click({ left_action = "spell", left_value = "Cri de guerre" }) }

-- Row 4 (15.4, 15.5, 15.6, 15.7).
local switch = Icon("27 Load Switch test", SpellCooldown(6673), -300, -30, nil)
switch.load.use_loadSwitch, switch.load.loadSwitch = true, "test"
Icon("28 Spell Set test", Modern(BLOODRAGE_AURA, { secretSpellSet = "test" }), -180, -30, nil)
Icon("19 New Aura 3 s Battle Shout", Modern(BATTLE_SHOUT, { secretNewAura = true, secretNewAuraSeconds = 3 }),
  -60, -30, nil)
Icon("32 Crowd Controlled", Generic({ type = "unit", event = "Crowd Controlled" }), 60, -30, nil)
Bar("36 Vie avec absorption", Generic({ type = "unit", event = "Health", use_unit = true, use_showAbsorb = true }),
  -220, -100, nil)

-- Row 5 (15.6, test 30): one aura per display type on the nameplate of the target, a frame with a secret geometry
-- in combat.
for index, regionType in ipairs({ "icon", "text", "progresstexture", "stopmotion", "model" }) do
  local data = Base("30 Barre de nom " .. regionType, regionType,
    Generic({ type = "unit", event = "Health", use_unit = true, unit = "target" }), (index - 3) * 40, 40)
  data.anchorFrameType, data.anchorPoint, data.selfPoint = "NAMEPLATE", "TOP", "BOTTOM"
  data.width, data.height = 32, 32
  if regionType == "text" then data.displayText = "T30" end
end

-- Rows 6 to 8: the checks of step 15 that had no aura yet.
local SUNDER_ARMOR, REND = { "7386" }, { "772" }
local function Ranks(ids, extra)
  local fields = { secretUseSpellIDs = false, secretUseRankSpellIDs = true, auraRankSpellIDs = ids, auraspellids = {} }
  for key, value in pairs(extra or {}) do fields[key] = value end
  return Modern({}, fields)
end
-- A custom action: the code fields of this pack, listed to the player at import.
local function Code(data, code)
  data.actions.start = { do_custom = true, custom = code }
end
local function Custom(code)
  return { type = "custom", custom_type = "status", check = "update", events = "", custom = code,
    customDuration = "", customName = "", customIcon = "", customTexture = "", customStacks = "" }
end
local function TargetHealth(extra)
  local trigger = Generic({ type = "unit", event = "Health", use_unit = true, unit = "target" })
  for key, value in pairs(extra or {}) do trigger[key] = value end
  return trigger
end

-- Row 6 (15.4).
local stackSound = Icon("18 Son Sunder Armor charge", Ranks(SUNDER_ARMOR, { unit = "target", debuffType = "HARMFUL" }),
  -300, -170, nil)
stackSound.actions.increase = { do_sound = true, sound = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\BikeHorn.ogg", sound_channel = "Master" }
Icon("20 Classe Guerrier", Modern(BATTLE_SHOUT, { unit = "group", useMemberClasses = true,
  memberClasses = { WARRIOR = true } }), -200, -170, nil)
Icon("20 Groupe sans moi", Modern(BATTLE_SHOUT, { unit = "group", ignoreSelf = true }), -100, -170, nil)
Icon("20 Groupe a portee", Modern(BATTLE_SHOUT, { unit = "group", ignoreInvisible = true }), 0, -170, nil)
local modernTexture = Base("21 Texture Battle Shout", "texture", Modern(BATTLE_SHOUT), 100, -170)
modernTexture.width, modernTexture.height = 48, 48
local loadedInCombat = Icon("22 Modern Load Switch combat", Modern(BATTLE_SHOUT), 200, -170, nil)
loadedInCombat.load.use_loadSwitch, loadedInCombat.load.loadSwitch = true, "combat"
Icon("24 Modern Battle Shout manquant", Modern(BATTLE_SHOUT, { secretShowOn = "showOnMissing" }), 300, -170, nil)

-- Row 7 (15.4, 15.6, 15.7).
local nameplate = Icon("25 Rend barre de nom", Ranks(REND, { unit = "nameplate", debuffType = "HARMFUL",
  nativeFilters = { PLAYER = true } }), 0, 0, nil)
nameplate.anchorFrameType, nameplate.anchorPoint, nameplate.selfPoint = "NAMEPLATE", "TOP", "BOTTOM"
nameplate.width, nameplate.height = 24, 24
-- %n gets a name and %unit a unit token: the class color is checked on both.
local className = Text("n=[%n] unit=[%unit]", "CENTER", 12)
className.text_text_format_n_format, className.text_text_format_n_color = "Unit", "class"
className.text_text_format_unit_format, className.text_text_format_unit_color = "Unit", "class"
local named = Base("31 Nom de la cible couleur de classe", "empty", TargetHealth(), -300, -250)
named.width, named.height = 220, 20
named.subRegions = { className }
Icon("32 Stun", Generic({ type = "unit", event = "Crowd Controlled", use_controlType = true,
  controlType = "STUN" }), -180, -250, nil)
Icon("32 Stun inverse", Generic({ type = "unit", event = "Crowd Controlled", use_controlType = true,
  controlType = "STUN", use_inverse = true }), -80, -250, nil)
local hiddenGcd = Icon("34 Battle Shout sans texte de GCD", SpellCooldown(6673), 20, -250, nil)
hiddenGcd.triggers[1].trigger.use_showgcd, hiddenGcd.triggers[1].trigger.use_hidegcdtext = true, true
hiddenGcd.cooldownTextDisabled = true
hiddenGcd.subRegions = { Text("%p", "CENTER", 12) }
local absorbRing = Base("37 Anneau vie absorption", "progresstexture",
  Generic({ type = "unit", event = "Health", use_unit = true, use_showAbsorb = true }), 120, -250)
absorbRing.width, absorbRing.height = 48, 48
absorbRing.foregroundTexture = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura3"
absorbRing.backgroundTexture, absorbRing.sameTexture = absorbRing.foregroundTexture, true
absorbRing.orientation, absorbRing.startAngle, absorbRing.endAngle = "CLOCKWISE", 0, 360
local dungeon = Icon("45 Donjon a 5 seulement", SpellCooldown(2687), 220, -250, nil)
dungeon.load.use_size, dungeon.load.size = true, { single = "party", multi = { party = true } }

-- Row 8 (15.5, 15.6, 15.8): custom code.
local slot = Base("29 Slot Battle Shout", "empty", Rage(), -300, -330)
slot.width, slot.height = 40, 40
slot.subRegions = { Text("29 Slot", "OUTER_BOTTOM") }
Code(slot, [[if not aura_env.slot then
  local slot, problem = WeakAuras.CreateAuraSlot(WeakAuras.GetRegion(aura_env.id),
    { helpful = { 6673, 5242, 6192, 11549, 11550, 11551, 25289 }, unit = "player" })
  aura_env.slot = slot
  if not slot then print("Musca test 29: " .. tostring(problem)) end
end]])
local secret = Icon("35 Code vie max de la cible", Custom([[function()
  return UnitExists("target") and UnitHealthMax("target") > 0
end]]), -180, -330, nil)
secret.displayIcon = 132092
local items = Base("40 Code GetItemInfo", "empty", Rage(), -60, -330)
items.width, items.height = 40, 40
items.subRegions = { Text("40 Code objets", "CENTER") }
Code(items, [[print("Musca test 40:", GetItemInfo(6948), GetItemCount(6948), IsAddOnLoaded("WeakAuras"))]])

local root = {
  id = ROOT, uid = PREFIX .. "00", regionType = "group", internalVersion = 91, tocversion = 16001,
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

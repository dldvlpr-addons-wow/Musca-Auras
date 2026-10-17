-- Test auras for a level 10 warrior on WoW Forever: one aura per in-game check that a warrior can trigger.
local ROOT = "Musca Test - Guerrier 10"
local PREFIX = "mcTestW10"

local function Ids(list)
  local result = {}
  for index, value in ipairs(list) do result[index] = tostring(value) end
  return result
end

local BATTLE_SHOUT = { 6673 }
local REND = { 772 }
local THUNDER_CLAP = { 6343 }
local HAMSTRING = { 1715 }
local SUNDER_ARMOR = { 7386 }
local BLOODRAGE_AURA = { 29131 }

local function Text(text, point, size, extra)
  local element = {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 10, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
  for key, value in pairs(extra or {}) do element[key] = value end
  return element
end

local function Timed(point, size)
  return Text("%p", point, size or 13, { text_text_format_p_format = "timed", text_text_format_p_time_format = 0,
    text_text_format_p_time_legacy_floor = false, text_text_format_p_time_dynamic_threshold = 3,
    text_text_format_p_time_precision = 1 })
end

local function Glow(glowType)
  return { type = "subglow", glow = true, glowType = glowType, useGlowColor = true, glowColor = {1, 0.8, 0.2, 1},
    glowLines = 8, glowFrequency = 0.25, glowDuration = 1, glowLength = 10, glowThickness = 2,
    glowScale = 1, glowBorder = false, glowXOffset = 0, glowYOffset = 0 }
end

local function Border(edge, size, offset, pixelPerfect)
  return { type = "subborder", border_visible = true, border_edge = edge, border_size = size,
    border_offset = offset, border_color = {1, 0.8, 0.2, 1}, border_alpha = 1, border_ppscale = pixelPerfect,
    border_dispelColor = false, anchor_area = "ALL" }
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

local function Modern(unit, kind, ids, extra)
  local trigger = { type = "secretAura", unit = unit, debuffType = kind, secretUseRankSpellIDs = true,
    auraRankSpellIDs = Ids(ids), nativeFilters = { PLAYER = true }, secretShowOn = "showOnActive" }
  for key, value in pairs(extra or {}) do trigger[key] = value end
  return trigger
end

local function Cdm(event, spell, extra)
  local trigger = { type = "cdm", event = event, cdmSelection = "spell", cdmSpell = spell, cdmExact = false }
  for key, value in pairs(extra or {}) do trigger[key] = value end
  return trigger
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

local function Icon(label, trigger, x, y, icon)
  local data = Base(label, "icon", trigger, x, y)
  data.width, data.height, data.keepAspectRatio = 40, 40, true
  data.iconSource, data.displayIcon = -1, icon
  data.cooldown, data.cooldownSwipe, data.cooldownEdge, data.cooldownTextDisabled = true, true, false, true
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  data.subRegions = { Text(label, "OUTER_BOTTOM", 9) }
  return data
end

local function Bar(label, trigger, x, y, orientation, width, height)
  local data = Base(label, "aurabar", trigger, x, y)
  data.width, data.height = width, height
  data.barColor, data.backgroundColor = {0.8, 0.2, 0.1, 1}, {0, 0, 0, 0.5}
  data.texture, data.orientation, data.icon, data.icon_side = "Blizzard", orientation, true, "LEFT"
  data.inverse = false
  data.subRegions = { { type = "subbackground" }, { type = "subforeground" }, Timed("INNER_CENTER", 11),
    Text(label, "OUTER_BOTTOM", 9) }
  return data
end

local function Ring(label, trigger, x, y, orientation, startAngle, compress)
  local data = Base(label, "progresstexture", trigger, x, y)
  data.width, data.height = 64, 64
  data.foregroundTexture = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura3"
  data.backgroundTexture = data.foregroundTexture
  data.sameTexture, data.foregroundColor, data.backgroundColor = true, {1, 0.6, 0.1, 1}, {0.2, 0.2, 0.2, 0.6}
  data.orientation, data.startAngle, data.endAngle, data.inverse, data.compress =
    orientation, startAngle, 360, false, compress
  data.subRegions = { Text(label, "OUTER_BOTTOM", 9) }
  return data
end

-- Row 1: Aura (Modern) icons, borders, picked icon, swipe, the four native glows.
local shout = Icon("L7 Battle Shout bordure LSM", Modern("player", "HELPFUL", BATTLE_SHOUT), -250, 200)
shout.iconSource, shout.displayIcon = 0, 132333
table.insert(shout.subRegions, 1, Border("Blizzard Tooltip", 12, 2, false))
shout.subRegions[#shout.subRegions + 1] = Timed("CENTER")
local bloodrage = Icon("L7 Bloodrage pixel parfait 1.4", Modern("player", "HELPFUL", BLOODRAGE_AURA,
  { secretUseRankSpellIDs = false, secretUseSpellIDs = true, auraspellids = Ids(BLOODRAGE_AURA) }), -190, 200)
table.insert(bloodrage.subRegions, 1, Border("Square Full White", 1.4, 1.4, true))
bloodrage.subRegions[#bloodrage.subRegions + 1] = Timed("CENTER")
local glows = {
  { "Proc", "R3 Rend glow Proc", REND },
  { "buttonOverlay", "R3 Thunder Clap glow buttonOverlay", THUNDER_CLAP },
  { "Pixel", "R3 Hamstring glow Pixel", HAMSTRING },
  { "ACShine", "R3 Sunder Armor glow Shine", SUNDER_ARMOR },
}
for index, glow in ipairs(glows) do
  local data = Icon(glow[2], Modern("target", "HARMFUL", glow[3]), -130 + (index - 1) * 60, 200)
  data.subRegions[#data.subRegions + 1] = Timed("CENTER")
  data.subRegions[#data.subRegions + 1] = Glow(glow[1])
end
children[#children].subRegions[#children[#children].subRegions + 1] = Text("%s", "BOTTOMRIGHT", 12)
children[#children].subRegions[#children[#children].subRegions + 1] = Border("Square Full White", 1, 0, true)
local remaining = Icon("R3 Rend moins de 5 s", Modern("target", "HARMFUL", REND,
  { secretUseRem = true, secretRemOperator = "<", secretRem = "5" }), 110, 200)
remaining.subRegions[#remaining.subRegions + 1] = Timed("CENTER")
Icon("Battle Shout manquant", Modern("player", "HELPFUL", BATTLE_SHOUT,
  { secretShowOn = "showOnMissing", nativeFilters = {} }), 170, 200)

-- Row 2: classic triggers.
local chargeCooldown = Icon("R10 Charge cooldown", Generic({ type = "spell", event = "Cooldown Progress (Spell)", spellName = 100,
  use_exact_spellName = false, genericShowOn = "showAlways", use_genericShowOn = true, use_showgcd = true,
  use_hidegcdtext = true }), -250, 130)
chargeCooldown.cooldownTextDisabled = false
Icon("R10 Heroic Strike en file", Generic({ type = "spell", event = "Queued Action", spellName = 78,
  use_exact_spellName = false }), -190, 130)
Icon("R10 Portee rang inconnu 285", Generic({ type = "spell", event = "Spell in Range", spellName = 285,
  use_exact_spellName = false, unit = "target" }), -130, 130)
Icon("R10 Portee sans sort (rien)", Generic({ type = "spell", event = "Spell in Range", unit = "target" }), -70, 130)
Icon("R10 Portee exact nom (rien)", Generic({ type = "spell", event = "Spell in Range", spellName = "Rend",
  use_exact_spellName = true, unit = "target" }), -10, 130)
Icon("Posture de combat", Generic({ type = "unit", event = "Stance/Form/Aura", use_form = true,
  form = { single = 1, multi = {} } }), 50, 130)
Icon("Posture defensive", Generic({ type = "unit", event = "Stance/Form/Aura", use_form = true,
  form = { single = 2, multi = {} } }), 110, 130)
Ring("R6 Anneau secret ANTICLOCKWISE 90", Generic({ type = "spell", event = "Cooldown Progress (Spell)",
  spellName = 100, use_exact_spellName = false, genericShowOn = "showAlways", use_genericShowOn = true }),
  240, 130, "ANTICLOCKWISE", 90, false)

-- Row 3: Cooldown Viewer (needs cooldownViewerEnabled 1 and the spells in the Blizzard CDM).
local cdmCharge = Icon("R4 CDM Charge", Cdm("Blizzard Cooldown Manager", "Charge", { cdmShow = "always", cdmTrack = "auto" }), -250, 60)
cdmCharge.cooldownTextDisabled = false
local cdmHamstring = Icon("R4 CDM Hamstring GCD", Cdm("Blizzard Cooldown Manager", "Hamstring",
  { cdmShow = "always", cdmTrack = "auto", use_cdmShowGCD = true, cdmHideGCDText = true }), -190, 60)
cdmHamstring.cooldownTextDisabled = false
Icon("R4 CDM Battle Shout buff", Cdm("Blizzard CDM Buff", "Battle Shout", { cdmBuffShow = "active" }), -130, 60)
Icon("R4 CDM Rend cible requise", Cdm("Blizzard CDM Buff", "Rend",
  { cdmBuffShow = "active", cdmRequireTarget = true }), -70, 60)
local cdmBar = Bar("L7 CDM Bloodrage barre", Cdm("Blizzard Cooldown Manager", "Bloodrage",
  { cdmShow = "always", cdmTrack = "auto" }), 60, 60, "HORIZONTAL", 160, 20)
cdmBar.subRegions[#cdmBar.subRegions + 1] = Text("%s", "INNER_RIGHT", 10)

-- Row 4: Aura (Modern) bars in the four orientations, rings.
Bar("R6 Barre HORIZONTAL", Modern("player", "HELPFUL", BATTLE_SHOUT), -200, -10, "HORIZONTAL", 180, 20)
local inverse = Bar("R6 Barre HORIZONTAL inversee", Modern("player", "HELPFUL", BATTLE_SHOUT), -200, -45,
  "HORIZONTAL", 180, 20)
inverse.inverse = true
local reverse = Bar("R6 Barre HORIZONTAL_INVERSE icone droite", Modern("player", "HELPFUL", BATTLE_SHOUT), -200, -80,
  "HORIZONTAL_INVERSE", 180, 20)
reverse.icon_side = "RIGHT"
Bar("R6 Barre VERTICAL icone gauche", Modern("target", "HARMFUL", REND), -40, -60, "VERTICAL", 24, 140)
local verticalRight = Bar("R6 Barre VERTICAL_INVERSE icone droite", Modern("target", "HARMFUL", REND), 0, -60,
  "VERTICAL_INVERSE", 24, 140)
verticalRight.icon_side = "RIGHT"
Ring("R6 Anneau ANTICLOCKWISE 90", Modern("player", "HELPFUL", BATTLE_SHOUT), 80, -40, "ANTICLOCKWISE", 90, false)
Ring("R6 Anneau CLOCKWISE", Modern("player", "HELPFUL", BATTLE_SHOUT), 160, -40, "CLOCKWISE", 0, false)
Ring("R6 Bande compress", Modern("target", "HARMFUL", REND), 240, -40, "HORIZONTAL", 0, true)

-- Row 5: rage and swing.
local rage = Bar("Rage", Generic({ type = "unit", event = "Power", unit = "player", use_unit = true,
  use_powertype = true, powertype = 1 }), -150, -150, "HORIZONTAL", 200, 18)
rage.barColor, rage.subRegions[3].text_text = {0.78, 0.25, 0.25, 1}, "%p"
rage.subRegions[3].text_text_format_p_format = "none"
Bar("Swing main droite", Generic({ type = "unit", event = "Swing Timer", hand = "main", use_hand = true }),
  80, -150, "HORIZONTAL", 200, 18)

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

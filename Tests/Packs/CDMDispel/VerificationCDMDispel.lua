local ROOT = "Test - Type de dispel CDM"

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
end

local function Animation()
  local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
  return { start = step, main = step, finish = step }
end

local function Base(id, uid, parent, regionType, trigger)
  return {
    id = id, uid = uid, parent = parent, regionType = regionType, internalVersion = 91, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = { use_class = true, class = { single = "SHAMAN", multi = {} },
      size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } },
    conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  }
end

local function FlameShock()
  return { type = "cdm", event = "Blizzard CDM Buff", cdmSelection = "spell", cdmSpell = "Flame Shock",
    cdmExact = false, cdmBuffShow = "active", cdmRequireTarget = true }
end

local function DispelIcon()
  return { type = "subcdmdispel", dispelVisible = true, dispelStyle = "Icon", anchor_mode = "point",
    anchor_point = "TOPLEFT", self_point = "TOPLEFT", anchor_area = "ALL", width = 24, height = 24,
    xOffset = -8, yOffset = 8 }
end

local function DispelBorder(area)
  return { type = "subcdmdispelborder", dispelVisible = true, dispelBorderSize = 4, dispelBorderOffset = 0,
    anchor_mode = "area", anchor_area = area, anchor_point = "CENTER", self_point = "CENTER",
    width = 32, height = 32, xOffset = 0, yOffset = 0 }
end

local icon = Base("Dispel CDM : icône", "mcCdmDispelIcon01", ROOT, "icon", FlameShock())
icon.width, icon.height = 64, 64
icon.iconSource, icon.displayIcon = -1, 135813
icon.cooldown, icon.cooldownTextDisabled = true, false
icon.desaturate, icon.color, icon.zoom = false, {1, 1, 1, 1}, 0.1
icon.subRegions = { DispelBorder("ALL"), DispelIcon(), Text("Icône + bordure", "OUTER_BOTTOM", 10) }

local bar = Base("Dispel CDM : barre", "mcCdmDispelBar001", ROOT, "aurabar", FlameShock())
bar.width, bar.height = 220, 26
bar.barColor, bar.backgroundColor = {1, 0.5, 0, 1}, {0, 0, 0, 0.5}
bar.texture, bar.orientation, bar.icon = "Blizzard", "HORIZONTAL", true
bar.subRegions = { { type = "subbackground" }, { type = "subforeground" }, DispelBorder("bar"),
  Text("Barre + bordure", "INNER_LEFT", 11) }

local names = { icon.id, bar.id }
local group = Base(ROOT, "mcCdmDispelGroup1", nil, "dynamicgroup",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
group.controlledChildren, group.grow, group.align, group.space, group.stagger, group.sort =
  names, "DOWN", "CENTER", 20, 0, "none"
group.anchorFrameType, group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset =
  "SCREEN", "CENTER", "CENTER", 0, 100

return { m = "d", s = "5.22.0", v = 2000, d = group, c = { icon, bar } }

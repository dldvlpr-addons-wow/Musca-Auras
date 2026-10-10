local ROOT = "Test - Progression CDM"

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

local function LightningShield()
  return { type = "cdm", event = "Blizzard CDM Buff", cdmSpells = { multi = { [200311] = true } },
    cdmBuffShow = "active" }
end

local icon = Base("Progression CDM : icône", "mcCdmProgIcon0001", ROOT, "icon", LightningShield())
icon.width, icon.height = 64, 64
icon.iconSource, icon.displayIcon = -1, 136051
icon.cooldown, icon.cooldownTextDisabled = true, false
icon.desaturate, icon.color, icon.zoom = false, {1, 1, 1, 1}, 0.1
icon.subRegions = { Text("%p", "CENTER", 16), Text("Icône : balayage", "OUTER_BOTTOM", 10) }

local bar = Base("Progression CDM : barre", "mcCdmProgBar00001", ROOT, "aurabar", LightningShield())
bar.width, bar.height = 220, 26
bar.barColor, bar.backgroundColor = {0.3, 0.6, 1, 1}, {0, 0, 0, 0.5}
bar.texture, bar.orientation, bar.icon = "Blizzard", "HORIZONTAL", true
bar.subRegions = { { type = "subbackground" }, { type = "subforeground" }, Text("%p", "INNER_RIGHT", 12),
  Text("Barre : vidage", "INNER_LEFT", 11) }

local group = Base(ROOT, "mcCdmProgGroup01", nil, "dynamicgroup",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
group.controlledChildren, group.grow, group.align, group.space, group.stagger, group.sort =
  { icon.id, bar.id }, "DOWN", "CENTER", 20, 0, "none"
group.anchorFrameType, group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset =
  "SCREEN", "CENTER", "CENTER", 0, -100

return { m = "d", s = "5.22.0", v = 2000, d = group, c = { icon, bar } }

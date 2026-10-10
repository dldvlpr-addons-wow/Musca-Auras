local ROOT = "Test - Clones CDM"

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
    anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = 0, yOffset = 0,
  }
end

local icon = Base("Clones CDM : icône", "mcCdmClonesIcon1", ROOT, "icon",
  { type = "cdm", event = "Blizzard CDM Buff", cdmSpells = { multi = { [200311] = true, [200329] = true } }, cdmBuffShow = "active" })
icon.width, icon.height = 48, 48
icon.iconSource, icon.displayIcon = -1, 136051
icon.cooldown, icon.cooldownTextDisabled = true, false
icon.desaturate, icon.color, icon.zoom = false, {1, 1, 1, 1}, 0.1
icon.subRegions = { Text("%p", "CENTER", 14), Text("%n", "OUTER_BOTTOM", 9) }

local group = Base(ROOT, "mcCdmClonesGroup", nil, "dynamicgroup",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
group.controlledChildren = { icon.id }
group.grow, group.align, group.space, group.stagger, group.sort = "RIGHT", "CENTER", 4, 0, "none"
group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset = "CENTER", "CENTER", 0, -150

return { m = "d", s = "5.22.0", v = 2000, d = group, c = { icon } }

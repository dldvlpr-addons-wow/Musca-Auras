local ROOT = "Test - Texte de durée"

local function Text(text, point, size, format)
  local element = {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
  if format then
    element.text_text_format_p_format = "timed"
    element.text_text_format_p_time_format = format.timeFormat
    element.text_text_format_p_time_legacy_floor = format.floor == true
    element.text_text_format_p_time_dynamic_threshold = format.threshold
    element.text_text_format_p_time_precision = format.precision
  end
  return element
end

local function Animation()
  local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
  return { start = step, main = step, finish = step }
end

local function Base(id, uid, parent, regionType, trigger)
  return {
    id = id, uid = uid, parent = parent, regionType = regionType, internalVersion = 91, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = { size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} }, class = { multi = {} } },
    conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  }
end

local function LightningShield(totalGate)
  local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL",
    useExactSpellId = true, auraspellids = { "324", "325", "905", "945", "8134", "10431", "10432" },
    secretUseSpellIDs = true, nativeFilters = { PLAYER = true }, secretShowOn = "showOnActive" }
  if totalGate then
    trigger.secretUseTotal, trigger.secretTotalOperator, trigger.secretTotal = true, ">=", "1"
  end
  return trigger
end

local function Icon(index, label, format, totalGate)
  local data = Base("Durée " .. index .. " : " .. label, "mcDurTxtIcon" .. index, ROOT, "icon", LightningShield(totalGate))
  data.width, data.height = 40, 40
  data.iconSource, data.displayIcon = -1, 136051
  data.cooldown, data.cooldownTextDisabled = true, true
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  data.subRegions = { Text("%p", "CENTER", 13, format), Text(label, "OUTER_BOTTOM", 9) }
  return data
end

local icons = {
  Icon(1, "99 / M:SS", { timeFormat = 0, threshold = 0, precision = 1 }),
  Icon(2, "0 / M:SS", { timeFormat = 0, threshold = 0, precision = 1, floor = true }),
  Icon(3, "99 / Nm", { timeFormat = 1, threshold = 0, precision = 1 }),
  Icon(4, "99 / Nm Ns", { timeFormat = 2, threshold = 0, precision = 1 }),
  Icon(5, "99 / secondes", { timeFormat = -2, threshold = 0, precision = 1 }),
  Icon(6, "99 / M:SS <3 .1", { timeFormat = 0, threshold = 3, precision = 1 }),
  Icon(7, "Total>=1 99 / M:SS <3 .1", { timeFormat = 0, threshold = 3, precision = 1 }, true),
}

local names = {}
for index, icon in ipairs(icons) do names[index] = icon.id end

local group = Base(ROOT, "mcDurTxtGroup001", nil, "dynamicgroup",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
group.controlledChildren, group.grow, group.align, group.space, group.stagger, group.sort =
  names, "RIGHT", "CENTER", 34, 0, "none"
group.anchorFrameType, group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset =
  "SCREEN", "CENTER", "CENTER", 0, 120

return { m = "d", s = "5.22.0", v = 2000, d = group, c = icons }

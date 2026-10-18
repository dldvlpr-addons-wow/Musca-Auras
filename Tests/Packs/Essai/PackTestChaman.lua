-- Test auras for the features of 2026-10-18 (1.11.0), on a Shaman: trigger expression, condition copy and paste,
-- CPU warning, secret value text, greyed out options and classic mode, partial import, search on the description.
-- The root is a plain group holding plain sub-groups, so the last aura can anchor on an aura of another sub-group.
local ROOT = "Musca Test - 1.11 Shaman"
local PREFIX = "mcTest111"

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 12, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
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

local count = 0
local function Base(id, parent, regionType, triggers, x, y)
  count = count + 1
  local list = { activeTriggerMode = -10 }
  for index, trigger in ipairs(triggers) do list[index] = { trigger = trigger, untrigger = {} } end
  return {
    id = id, uid = string.format("%s%02d", PREFIX, count), parent = parent,
    regionType = regionType, internalVersion = 91, tocversion = 16001, triggers = list,
    load = { use_class = true, class = { single = "SHAMAN", multi = {} },
      size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } },
    conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
    anchorFrameType = "SCREEN", anchorPoint = "CENTER", selfPoint = "CENTER", xOffset = x or 0, yOffset = y or 0,
  }
end

local function Icon(label, parent, triggers, icon, x, y)
  local data = Base("Musca Test - " .. label, parent, "icon", triggers, x, y)
  data.width, data.height, data.keepAspectRatio = 40, 40, true
  data.iconSource, data.displayIcon = -1, icon
  data.cooldown, data.cooldownTextDisabled = true, false
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  data.subRegions = { Text(label, "OUTER_TOP", 10) }
  return data
end

local function Label(label, parent, triggers, x, y)
  local data = Base("Musca Test - " .. label, parent, "text", triggers, x, y)
  data.displayText = label .. ": %c"
  data.customTextUpdate = "update"
  data.font, data.fontSize, data.outline = "Friz Quadrata TT", 14, "OUTLINE"
  data.color, data.justify = {1, 0.82, 0, 1}, "LEFT"
  data.automaticWidth, data.fixedWidth, data.wordWrap = "Auto", 200, "WordWrap"
  return data
end

local function Group(label, x, y)
  local group = Base(ROOT .. " - " .. label, ROOT, "group",
    { { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} } }, x, y)
  group.controlledChildren = {}
  return group
end

local LIGHTNING_SHIELD = { "324", "325", "905", "945", "8134", "10431", "10432" }
local FLAME_SHOCK = { "8050", "8052", "8053", "10447", "10448", "29228" }

local function Modern(ids, unit, kind)
  return { type = "secretAura", unit = unit, debuffType = kind, useExactSpellId = true, auraspellids = ids,
    secretUseSpellIDs = true, nativeFilters = { PLAYER = true }, secretShowOn = "showOnActive" }
end

local inCombat = Generic({ type = "unit", event = "Conditions", use_incombat = true })
local always = { type = "custom", custom_type = "status", check = "update", custom = "function() return true end",
  events = "", unit = "player", names = {}, spellIds = {}, debuffType = "HELPFUL" }

-- Sub-group 1: trigger expression. Lightning Shield (Aura) up and out of combat.
local expression = Group("1 Expression", -200, 150)
local shieldOutOfCombat = Icon("Expression: shield and not combat", expression.id, {
  { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true, auranames = { "Lightning Shield" },
    matchesShowOn = "showOnActive" },
  inCombat,
}, 136051)
shieldOutOfCombat.triggers.disjunctive, shieldOutOfCombat.triggers.triggerExpression = "expression", "1 and not 2"
shieldOutOfCombat.desc = "musca search probe"

-- Sub-group 2: Modern icons. The stack text turns red under 3 charges; the Flame Shock icon has no condition and
-- takes the pasted one.
local modern = Group("2 Modern", 0, 150)
local shield = Icon("Modern: Lightning Shield", modern.id, { Modern(LIGHTNING_SHIELD, "player", "HELPFUL") },
  136051, -30, 0)
shield.subRegions[2] = Text("%s", "INNER_BOTTOMRIGHT", 14)
shield.conditions[1] = { check = { trigger = 1, variable = "faAuraApplications", value = "3", op = "<" },
  changes = { { property = "sub.2.text_color", value = {1, 0, 0, 1} } } }
local flameShock = Icon("Modern: Flame Shock", modern.id, { Modern(FLAME_SHOCK, "target", "HARMFUL") },
  135813, 30, 0)
flameShock.subRegions[2] = Text("%s", "INNER_BOTTOMRIGHT", 14)

-- Sub-group 3: CPU. A custom trigger and a custom text run on each frame without a throttle.
local cpu = Group("3 CPU", 200, 150)
local everyFrame = Label("CPU every frame", cpu.id, { always })
everyFrame.customText = "function() return string.format(\"%.1f\", GetTime()) end"

-- Sub-group 4: secret text. Target health, abbreviated, and an aura anchored on the Modern Lightning Shield icon.
local secret = Group("4 Secret text", 0, -150)
local health = Base("Musca Test - Target health", secret.id, "aurabar",
  { Generic({ type = "unit", event = "Health", unit = "target", use_unit = true }) })
health.width, health.height = 220, 22
health.barColor, health.backgroundColor = {0.2, 0.8, 0.2, 1}, {0, 0, 0, 0.5}
health.texture, health.orientation, health.icon = "Blizzard", "HORIZONTAL", false
local values = Text("%value / %total", "INNER_RIGHT", 12)
values.text_text_format_value_format, values.text_text_format_total_format = "BigNumber", "BigNumber"
health.subRegions = { { type = "subbackground" }, { type = "subforeground" }, values, Text("%n", "INNER_LEFT", 12) }
local anchored = Label("Anchored on Modern shield", secret.id, { always })
anchored.customText, anchored.customTextUpdate = "function() return \"anchor\" end", "event"
anchored.anchorFrameType, anchored.anchorFrameFrame = "SELECTFRAME", "WeakAuras:" .. shield.id
anchored.anchorFrameParent = false
anchored.anchorPoint, anchored.selfPoint, anchored.yOffset = "BOTTOM", "TOP", -60

local children = {}
local function Add(group, members)
  children[#children + 1] = group
  for _, member in ipairs(members) do
    group.controlledChildren[#group.controlledChildren + 1] = member.id
    children[#children + 1] = member
  end
end
Add(expression, { shieldOutOfCombat })
Add(modern, { shield, flameShock })
Add(cpu, { everyFrame })
Add(secret, { health, anchored })

local root = Base(ROOT, nil, "group", { { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} } }, 0, 0)
root.controlledChildren = { expression.id, modern.id, cpu.id, secret.id }

return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }

-- Test auras for the first pass of 2026-10-13 (Phase 1, steps 2 to 14). PACK_PART=import builds the second string,
-- which is only there to show the compatibility report of step 13: its auras never load.
local IMPORT = os.getenv("PACK_PART") == "import"
local ROOT = IMPORT and "Musca Test - Import report" or "Musca Test - Phase 1"
local PREFIX = IMPORT and "mcTestImp" or "mcTestP1"

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
local function Base(label, regionType, trigger)
  count = count + 1
  local load = { size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} }, class = { multi = {} } }
  if IMPORT then load.use_never = true end
  return {
    id = ROOT .. " - " .. label, uid = string.format("%s%02d", PREFIX, count), parent = ROOT,
    regionType = regionType, internalVersion = 91, tocversion = 16001,
    triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
    load = load, conditions = {}, config = {}, authorOptions = {},
    actions = { start = {}, finish = {}, init = {} }, animation = Animation(), subRegions = {},
    information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
  }
end

local function Icon(label, trigger, icon, text)
  local data = Base(label, "icon", trigger)
  data.width, data.height, data.keepAspectRatio = 36, 36, true
  data.iconSource, data.displayIcon = -1, icon
  data.cooldown, data.cooldownTextDisabled = true, false
  data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.1
  data.subRegions = { Text(label, "OUTER_RIGHT", 11) }
  if text then data.subRegions[2] = Text(text, "CENTER", 13) end
  return data
end

local ALWAYS = { type = "custom", custom_type = "status", check = "update", custom = "function() return true end",
  events = "", unit = "player", names = {}, spellIds = {}, debuffType = "HELPFUL" }

local function Label(label, trigger, customText)
  local data = Base(label, "text", trigger)
  data.displayText = customText and label .. ": %c" or label
  data.customText, data.customTextUpdate = customText, "update"
  data.font, data.fontSize, data.outline = "Friz Quadrata TT", 14, "OUTLINE"
  data.color, data.justify = {1, 0.82, 0, 1}, "LEFT"
  data.automaticWidth, data.fixedWidth, data.wordWrap = "Auto", 200, "WordWrap"
  return data
end

local function Copy(t)
  local copy = {}
  for key, value in pairs(t) do copy[key] = value end
  return copy
end

local LIGHTNING_SHIELD = { "324", "325", "905", "945", "8134", "10431", "10432" }

local children
if IMPORT then
  local combatLog = Generic({ type = "combatlog", event = "Combat Log", subeventSuffix = "_DAMAGE",
    use_sourceUnit = true, sourceUnit = "player" })
  local unitBuff = Copy(ALWAYS)
  unitBuff.custom = "function() return UnitBuff(\"player\", 1) ~= nil end"
  children = {
    Icon("Combat log", combatLog, 136048),
    Icon("UnitBuff in custom code", unitBuff, 136051),
    Icon("Aura on target", { type = "aura2", unit = "target", debuffType = "HARMFUL", ownOnly = true,
      useName = true, auranames = { "Flame Shock" }, matchesShowOn = "showOnActive" }, 135813),
  }
else
  local sandbox = [[function()
  local parts = {}
  parts[#parts + 1] = "getmetatable " .. (getmetatable("") == nil and "blocked" or "OPEN")
  parts[#parts + 1] = "debug " .. (debug.traceback == nil and "blocked" or "OPEN")
  parts[#parts + 1] = "C_GuildInfo " .. (C_GuildInfo.GuildRoster == nil and "blocked" or "OPEN")
  parts[#parts + 1] = "collectgarbage " .. (collectgarbage("count") and "count ok" or "count KO")
  parts[#parts + 1] = "SetCVar " .. (SetCVar and "ok" or "MISSING")
  return table.concat(parts, ", ")
end]]
  children = {
    Icon("T02 Earth Shock cooldown", Generic({ type = "spell", event = "Cooldown Progress (Spell)", spellName = 8042,
      use_exact_spellName = false, genericShowOn = "showAlways", use_genericShowOn = true }), 136026),
    Icon("T02 Weapon enchant", Generic({ type = "item", event = "Weapon Enchant", weapon = "main", use_weapon = true,
      showOn = "showAlways", use_showOn = true }), 136086, "%p"),
    Icon("T02 Target range", Generic({ type = "unit", event = "Range Check", unit = "target", use_unit = true }),
      132212, "%maxRange"),
    Icon("T04 Lightning Shield (Aura)", { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Lightning Shield" }, matchesShowOn = "showOnActive" }, 136051, "%p"),
    Icon("T09 Flame Shock on target (Aura)", { type = "aura2", unit = "target", debuffType = "HARMFUL", ownOnly = true,
      useName = true, auranames = { "Flame Shock" }, matchesShowOn = "showOnActive" }, 135813, "%p"),
    Icon("T10 T14 Lightning Shield (Modern)", { type = "secretAura", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = LIGHTNING_SHIELD, secretUseSpellIDs = true,
      nativeFilters = { PLAYER = true }, secretShowOn = "showOnActive" }, 136051, "%p"),
    Label("T05 Sandbox", Copy(ALWAYS), sandbox),
    Label("T07 Custom error", Copy(ALWAYS), "function() error(\"Musca test: custom code error\") end"),
  }
  children[#children].customTextUpdate = "event"
end

local root = Base("root", "dynamicgroup", { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
root.id, root.parent = ROOT, nil
root.controlledChildren = {}
for _, child in ipairs(children) do root.controlledChildren[#root.controlledChildren + 1] = child.id end
root.grow, root.align, root.space, root.stagger, root.sort = "DOWN", "LEFT", 4, 0, "none"
root.anchorFrameType, root.anchorPoint, root.selfPoint, root.xOffset, root.yOffset =
  "SCREEN", "CENTER", "TOPLEFT", -450, 250
root.load = { size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} }, class = { multi = {} } }

return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }

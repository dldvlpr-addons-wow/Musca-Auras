local ROOT = "Test - Correctifs CDM"

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

local texture = Base("Correctifs CDM : texture %p", "mcCdmFixTexture1", ROOT, "texture",
  { type = "cdm", event = "Blizzard CDM Buff", cdmSpells = { multi = { [200311] = true } }, cdmBuffShow = "active" })
texture.texture, texture.width, texture.height = "Interface\\Icons\\Spell_Nature_LightningShield", 64, 64
texture.color, texture.desaturate, texture.blendMode = {1, 1, 1, 1}, false, "BLEND"
texture.textureWrapMode, texture.rotation, texture.mirror, texture.rotate = "CLAMPTOBLACKADDITIVE", 0, false, false
texture.anchorPoint, texture.selfPoint, texture.xOffset, texture.yOffset = "TOP", "TOP", 100, -50
texture.subRegions = { Text("%p", "CENTER", 16), Text("Texture", "BOTTOM", 10) }

local exact = Base("Correctifs CDM : ID exact 324", "mcCdmFixExact001", ROOT, "icon",
  { type = "cdm", event = "Blizzard CDM Buff", cdmUseExactIDs = true, cdmExactIDs = { "324" },
    cdmBuffShow = "active" })
exact.width, exact.height, exact.xOffset, exact.yOffset = 64, 64, -100, -50
exact.anchorPoint, exact.selfPoint = "TOP", "TOP"
exact.iconSource, exact.displayIcon = -1, 136051
exact.cooldown, exact.cooldownTextDisabled = true, false
exact.desaturate, exact.color, exact.zoom = false, {1, 1, 1, 1}, 0.1
exact.subRegions = { Text("%p", "CENTER", 16), Text("ID exact 324", "OUTER_BOTTOM", 10) }

local group = Base(ROOT, "mcCdmFixGroup001", nil, "group",
  { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} })
group.controlledChildren = { texture.id, exact.id }
group.anchorPoint, group.selfPoint, group.xOffset, group.yOffset = "CENTER", "CENTER", 0, 150

return { m = "d", s = "5.22.0", v = 2000, d = group, c = { texture, exact } }

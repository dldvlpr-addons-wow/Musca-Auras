local Pack = {}

local RED = {1, 0.3, 0.3, 1}
local BLUE = {0.4, 0.5, 1, 1}
local POWER_COLORS = {
  [0] = {0, 0.44, 0.87, 1}, [1] = {0.78, 0.25, 0.25, 1}, [2] = {1, 0.5, 0.25, 1},
  [3] = {1, 0.96, 0.41, 1}, [4] = {1, 0.82, 0, 1},
}
local SEGMENT_COLORS = {
  {1, 1, 0.2, 1}, {1, 0.8, 0.1, 1}, {1, 0.6, 0.1, 1}, {1, 0.4, 0.1, 1}, {1, 0.15, 0.1, 1},
}

local BORDER = { type = "subborder", border_visible = true, border_size = 1, border_color = {0, 0, 0, 1},
  border_edge = "Square Full White", border_offset = 0 }
local GLOW = { type = "subglow", glow = true, glowType = "Pixel", useGlowColor = false, glowColor = {1, 1, 1, 1},
  glowLines = 8, glowFrequency = 0.25, glowDuration = 1, glowLength = 10, glowThickness = 1, glowScale = 1,
  glowBorder = false, glowXOffset = 0, glowYOffset = 0 }

local TOTEM_ICONS = {
  "Interface\\Icons\\Spell_Fire_SearingTotem", "Interface\\Icons\\Spell_Nature_StoneSkinTotem",
  "Interface\\Icons\\INV_Spear_04", "Interface\\Icons\\Spell_Nature_Windfury",
}

local function Text(text, point, size)
  return {
    type = "subtext", text_text = text, text_color = {1, 1, 1, 1}, text_font = "Friz Quadrata TT",
    text_fontSize = size or 14, text_fontType = "OUTLINE", text_visible = true, text_justify = "CENTER",
    text_selfPoint = "AUTO", anchor_point = point, anchorXOffset = 0, anchorYOffset = 0,
    text_shadowColor = {0, 0, 0, 1}, text_shadowXOffset = 0, text_shadowYOffset = 0, rotateText = "NONE",
    text_automaticWidth = "Auto", text_fixedWidth = 64, text_wordWrap = "WordWrap",
  }
end

local function Animation()
  local step = { duration_type = "seconds", easeStrength = 3, easeType = "none", type = "none" }
  return { start = step, main = step, finish = step }
end

local function Ids(ids)
  local list = {}
  for index, spellId in ipairs(ids) do list[index] = tostring(spellId) end
  return list
end

local function Condition(variable, value, property, change, op)
  return { check = { trigger = 1, variable = variable, value = value, op = op },
    changes = { { property = property, value = change } } }
end

local function Generic(fields)
  fields.names, fields.spellIds, fields.debuffType = {}, {}, "HELPFUL"
  fields.subeventPrefix, fields.subeventSuffix = "SPELL", "_CAST_START"
  fields.unit = fields.unit or "player"
  return fields
end

local function CooldownTrigger(spellId)
  return Generic({ type = "spell", event = "Cooldown Progress (Spell)", spellName = spellId,
    use_exact_spellName = false, genericShowOn = "showAlways", use_genericShowOn = true,
    use_desaturateOnCooldown = true, desaturateOnCooldown = true })
end

local function AuraTrigger(ids, showOn, unit, kind)
  return { type = "secretAura", unit = unit or "player", debuffType = kind or "HELPFUL",
    useExactSpellId = true, auraspellids = Ids(ids), secretUseSpellIDs = true,
    nativeFilters = { PLAYER = true }, secretShowOn = showOn }
end

local function PowerTrigger(powerType, threshold, above, unit)
  local trigger = Generic({ type = "unit", event = "Power", unit = unit or "player", use_unit = true,
    use_powertype = true, powertype = powerType })
  if threshold then
    trigger.use_nativeThreshold, trigger.nativeThreshold = true, tostring(threshold)
    if above then trigger.use_nativeThresholdAbove = true end
  end
  return trigger
end

local function GateTrigger(powerType)
  local trigger = PowerTrigger(powerType)
  trigger.use_requirePowerType = true
  return trigger
end

local function FormTrigger(form)
  return Generic({ type = "unit", event = "Stance/Form/Aura", use_form = true, form = { single = form, multi = {} } })
end

local function OffhandTrigger()
  local weapons = {}
  for subclass = 0, 20 do
    if not ({ [9] = 1, [11] = 1, [12] = 1, [14] = 1, [17] = 1 })[subclass] then weapons[2 * 256 + subclass] = true end
  end
  return Generic({ type = "item", event = "Item Type Equipped", use_itemSlot = true, itemSlot = 17,
    use_itemTypeName = false, itemTypeName = { multi = weapons } })
end

local function TotemTrigger(fields)
  fields.type, fields.event = "spell", "Totem"
  return Generic(fields)
end

function Pack.Build(spec)
  local name, prefix = spec.name, spec.prefix
  local root = name .. " (Musca)"
  local counter = 0
  local children, groups = {}, {}

  local function Uid()
    counter = counter + 1
    return string.format("%s%03d", prefix, counter)
  end

  local function Load(options)
    local load = { use_class = true, class = { single = spec.class, multi = {} },
      size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } }
    if options.outOfCombat then load.use_combat = false end
    if options.known then load.use_spellknown = true load.spellknown = options.known end
    if options.unknown then load.use_not_spellknown = true load.not_spellknown = options.unknown end
    if options.level then load.use_level, load.level, load.level_operator = true, { tostring(options.level) }, { ">=" } end
    return load
  end

  local function Base(id, parent, regionType, trigger, options)
    local triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 }
    local required = {}
    if options.gate then required[#required + 1] = GateTrigger(options.gate) end
    if options.form then required[#required + 1] = FormTrigger(options.form) end
    if options.notResting then required[#required + 1] = Generic({ type = "unit", event = "Conditions", use_resting = false }) end
    if options.offhand then required[#required + 1] = OffhandTrigger() end
    assert(not (#required > 0 and options.fallback), id .. ": gate, form, rest or offhand and fallback cannot be combined")
    if options.fallback then
      triggers[2] = { trigger = options.fallback, untrigger = {} }
      triggers.disjunctive, triggers.activeTriggerMode = "any", 1
    end
    for index, extra in ipairs(required) do triggers[index + 1] = { trigger = extra, untrigger = {} } end
    if #required > 0 then triggers.disjunctive, triggers.activeTriggerMode = "all", 1 end
    if trigger.type == "secretAura" and #required > 0 then triggers.secretFallback = "none" end
    return {
      id = id, uid = Uid(), parent = parent, regionType = regionType, internalVersion = 91, tocversion = 16001,
      triggers = triggers, load = Load(options), conditions = options.conditions or {}, config = {},
      authorOptions = {}, actions = { start = {}, finish = {}, init = {} }, animation = Animation(),
      subRegions = options.subRegions or {},
      information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
    }
  end

  local function Group(label, regionType, yOffset, grow)
    local group = Base(name .. " - " .. label, root, regionType,
      { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, {})
    group.controlledChildren, group.anchorPoint, group.selfPoint = {}, "CENTER", "CENTER"
    group.xOffset, group.yOffset = 0, yOffset
    if grow == "GRID" then
      group.grow, group.gridType, group.gridWidth, group.rowSpace, group.columnSpace = "GRID", "HD", 8, 4, 4
      group.selfPoint, group.sort, group.useLimit = "TOP", "none", false
    elseif regionType == "dynamicgroup" then
      group.grow, group.align, group.space, group.stagger, group.sort = grow or "RIGHT", "CENTER", 4, 0, "none"
    elseif grow ~= "FIXED" then
      group.blizzardFlow, group.blizzardFlowGrowth, group.blizzardFlowSpacing = true, grow or "RIGHT", 2
    end
    groups[#groups + 1] = { group = group, members = {} }
    return groups[#groups]
  end

  local function Add(holder, data)
    data.parent = holder.group.id
    holder.group.controlledChildren[#holder.group.controlledChildren + 1] = data.id
    holder.members[#holder.members + 1] = data
    return data
  end

  local timer = Text("%p", "CENTER", 13)
  local outOfRange = Condition("spellInRange", 0, "color", RED)
  local noMana = Condition("insufficientResources", 1, "color", BLUE)
  local idle = { check = { trigger = -2, variable = "AND", checks = {
      { trigger = -1, variable = "incombat", value = 0 }, { trigger = -1, variable = "hastarget", value = 0 } } },
    changes = { { property = "alpha", value = 0.4 } } }

  local function Requirements(entry, options)
    options.known = options.known or entry.known or entry.spell
    options.unknown, options.form, options.level, options.warn = entry.unknown, entry.form, entry.level, entry.warn
    options.gate, options.offhand, options.flash = options.gate or entry.gate, entry.offhand, entry.flash
    options.texture = entry.texture
    return options
  end

  local function Icon(holder, label, trigger, options)
    local subRegions, conditions = {}, {}
    for index, subRegion in ipairs(options.subRegions or {}) do subRegions[index] = subRegion end
    for index, condition in ipairs(options.conditions or {}) do conditions[index] = condition end
    subRegions[#subRegions + 1] = BORDER
    if options.missing then
      local missing = Condition("faAuraMissing", nil, "desaturate", true)
      missing.changes[2] = { property = "color", value = {1, 1, 1, 0.5} }
      conditions[#conditions + 1] = missing
    end
    if trigger.type == "secretAura" and trigger.secretShowOn ~= "showOnMissing" then
      if options.glow ~= false or options.flash then
        subRegions[#subRegions + 1] = GLOW
        if options.flash then
          conditions[#conditions + 1] = Condition("faAuraElapsed", options.flash, "sub." .. #subRegions .. ".glow", true, "<")
        end
        if options.fallback or options.missing then
          conditions[#conditions + 1] = Condition("faAuraMissing", nil, "sub." .. #subRegions .. ".glow", false)
        end
      end
      if options.warn then
        conditions[#conditions + 1] = Condition("faAuraRemaining", options.warn, "sub.1.text_color", RED, "<")
      end
    end
    if options.idle then conditions[#conditions + 1] = idle end
    options.subRegions, options.conditions = subRegions, conditions
    local data = Base(name .. " - " .. label, nil, "icon", trigger, options)
    data.width, data.height = options.size, options.size
    data.iconSource, data.displayIcon = -1, options.texture
    data.cooldown, data.cooldownTextDisabled = true, false
    data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.3
    return Add(holder, data)
  end

  local function SpellIcon(holder, entry, size)
    if entry.aura then
      local unit = entry.unit or "player"
      assert(({ player = 1, target = 1, focus = 1, pet = 1, targettarget = 1, focustarget = 1 })[unit],
        entry.name .. ": unit without fallback")
      assert(not (entry.kind == "HARMFUL" and (unit == "player" or unit == "pet")), entry.name .. ": debuff on self")
      return Icon(holder, entry.name, AuraTrigger(entry.aura, "showAlways", entry.unit, entry.kind),
        Requirements(entry, { size = size, fallback = CooldownTrigger(entry.spell), subRegions = { timer }, idle = true }))
    end
    return Icon(holder, entry.name, CooldownTrigger(entry.spell),
      Requirements(entry, { size = size, conditions = { noMana, outOfRange }, idle = true }))
  end

  local function AuraIcon(holder, label, entry, unit, kind, warn, noGlow)
    local subRegions = { timer }
    if entry.stacks then subRegions[2] = Text("%s", "INNER_BOTTOMRIGHT", 12) end
    local options = Requirements(entry, { size = 32, subRegions = subRegions, missing = entry.missing,
      glow = not noGlow and entry.glow })
    options.warn = options.warn or warn
    if entry.totem then
      local data = Icon(holder, label, TotemTrigger({ use_totemType = true, totemType = entry.slot,
        use_totemName = true, totemName = tostring(entry.totem) }), options)
      data.xOffset = -36
      return data
    end
    return Icon(holder, label, AuraTrigger(entry.aura, entry.missing and "showAlways" or "showOnActive", unit, kind),
      options)
  end

  local function TotemIcon(holder, slot)
    local data = Icon(holder, "Totem " .. slot, TotemTrigger({ use_totemType = true, totemType = slot }),
      { size = 32, subRegions = { timer } })
    data.triggers[2] = { trigger = TotemTrigger({ use_totemType = true, totemType = slot, use_inverse = true }),
      untrigger = {} }
    data.triggers.disjunctive, data.triggers.activeTriggerMode = "any", 1
    data.displayIcon = TOTEM_ICONS[slot]
    data.conditions[#data.conditions + 1] = { check = { trigger = 2, variable = "show", value = 1 },
      changes = { { property = "desaturate", value = true }, { property = "alpha", value = 0.5 } } }
    return data
  end

  local function Bar(holder, label, trigger, options, color, text, height)
    local data = Base(name .. " - " .. label, nil, "aurabar", trigger, {
      gate = options.gate, known = options.known, offhand = options.offhand, conditions = options.conditions,
      subRegions = { { type = "subbackground" }, { type = "subforeground" },
        Text(text or "%p", "INNER_RIGHT", 11), Text(options.title or label, "INNER_LEFT", 11) },
    })
    data.width, data.height = 390, height
    data.barColor, data.backgroundColor = color, {0, 0, 0, 0.5}
    data.texture, data.orientation, data.icon = "Blizzard", "HORIZONTAL", false
    return Add(holder, data)
  end

  local function Label(holder, label, trigger, text, color, options)
    local data = Base(name .. " - " .. label, nil, "text", trigger, options)
    data.displayText, data.font, data.fontSize, data.outline = text, "Friz Quadrata TT", 16, "OUTLINE"
    data.color, data.justify = color or {1, 0.82, 0, 1}, "CENTER"
    return Add(holder, data)
  end

  local reminders = Group("Reminders", "dynamicgroup", 150, "UP")
  for _, entry in ipairs(spec.reminders or {}) do
    local options = Requirements(entry, { size = 32, outOfCombat = not entry.lowPower, notResting = not entry.lowPower })
    local label, trigger, text, color = "Missing " .. entry.name, nil, "Missing: " .. entry.name, nil
    if entry.aura then
      trigger = AuraTrigger(entry.aura, "showOnMissing")
      trigger.nativeFilters = nil
    elseif entry.enchant then
      trigger = Generic({ type = "item", event = "Weapon Enchant", weapon = entry.enchant, use_weapon = true,
        showOn = "showOnMissing", use_showOn = true })
    elseif entry.item then
      label, text = "Low " .. entry.name, entry.name .. ": %s"
      trigger = Generic({ type = "item", event = "Item Count", itemName = entry.item, use_itemName = true,
        use_count = true, count = tostring(entry.below), count_operator = "<" })
      if entry.icon then options.subRegions = { Text("%s", "INNER_BOTTOMRIGHT", 12) } end
    elseif entry.lowPower then
      label, text, color = entry.name, entry.name, BLUE
      trigger = PowerTrigger(entry.lowPower, entry.below)
    end
    if entry.icon then Icon(reminders, label, trigger, options) else Label(reminders, label, trigger, text, color, options) end
  end

  local procs = Group("Procs", "dynamicgroup", 96)
  for _, entry in ipairs(spec.procs or {}) do
    if entry.usable then
      Icon(procs, entry.name, Generic({ type = "spell", event = "Action Usable", spellName = entry.usable,
        use_exact_spellName = false }), Requirements(entry, { size = 32, known = entry.usable }))
    elseif entry.queued then
      Icon(procs, entry.name, Generic({ type = "spell", event = "Queued Action", spellName = entry.queued,
        use_exact_spellName = false }), Requirements(entry, { size = 32, known = entry.queued }))
    end
  end

  local effects = Group("Effects", "group", 60)
  for _, entry in ipairs(spec.debuffs or {}) do
    AuraIcon(effects, entry.name .. " (target)", entry, "target", "HARMFUL", 3)
  end
  for _, entry in ipairs(spec.buffs or {}) do
    AuraIcon(effects, entry.name, entry, entry.unit, entry.kind)
  end

  local segments = Group("Segments", "group", 32)
  if spec.segments then
    for count = 1, spec.segments.count do
      local trigger = AuraTrigger(spec.segments.aura, "showOnActive")
      trigger.secretUseStacks, trigger.secretStacksOperator, trigger.secretStacks = true, ">=", count
      Icon(segments, spec.segments.name .. " " .. count, trigger,
        Requirements(spec.segments, { size = 16, glow = false }))
    end
  end

  local main = Group("Main", "dynamicgroup", 22, "GRID")
  for _, entry in ipairs(spec.rotation or {}) do
    SpellIcon(main, entry, 44)
  end

  local points = Group("Points", "group", -84, "FIXED")
  local resource = Group("Bars", "dynamicgroup", -98, "DOWN")
  for _, power in ipairs(spec.power or {}) do
    for point = 1, power.segments or 0 do
      local data = Base(name .. " - " .. power.label .. " " .. point, nil, "texture",
        PowerTrigger(power.type, (point - 0.5) * 100 / power.segments, true), { gate = power.gate })
      data.texture, data.color, data.blendMode = "Interface\\Buttons\\WHITE8X8", SEGMENT_COLORS[point], "BLEND"
      data.width, data.height, data.yOffset = 74, 10, 0
      data.xOffset = (point - (power.segments + 1) / 2) * 79
      Add(points, data)
    end
    if not power.segments then
      Bar(resource, power.label, PowerTrigger(power.type, nil, nil, power.unit), { gate = power.gate },
        POWER_COLORS[power.type] or POWER_COLORS[0], "%p", 18)
    end
  end
  if spec.energyTick then
    Bar(resource, "Energy tick", Generic({ type = "unit", event = "Energy Tick" }), { gate = 3, title = "" },
      POWER_COLORS[3], "", 6)
  end
  if spec.castBar then
    Bar(resource, "Cast", Generic({ type = "unit", event = "Cast", unit = "player", use_unit = true }),
      { title = "%n", conditions = { Condition("interruptible", 0, "barColor", {0.5, 0.5, 0.5, 1}) } },
      RED, "%p", 16)
  end

  local secondary = resource
  if spec.pet then
    Bar(secondary, "Pet", Generic({ type = "unit", event = "Health", unit = "pet", use_unit = true }), {},
      {0.2, 0.8, 0.2, 1}, "%p", 10)
  end
  for _, hand in ipairs(spec.swing or {}) do
    Bar(secondary, "Swing " .. hand, Generic({ type = "unit", event = "Swing Timer", hand = hand, use_hand = true }),
      { known = spec.swingKnown, offhand = hand == "off" }, {0.8, 0.8, 0.8, 1}, "%p", 10)
  end
  if spec.fiveSecondRule then
    local trigger = Generic({ type = "event", event = "Spell Cast Succeeded", use_unit = true,
      use_spellNames = true, spellNames = Ids(spec.fiveSecondRule), duration = "5" })
    Bar(secondary, "5 sec rule", trigger, {}, {0.6, 0.6, 1, 1}, "%p", 10)
  end

  local utility = Group("Utility", "dynamicgroup", -190)
  for _, entry in ipairs(spec.cooldowns or {}) do
    SpellIcon(utility, entry, 32)
  end

  local totems = Group("Totems", "group", -270, "FIXED")
  for slot = 1, spec.totems and 4 or 0 do
    TotemIcon(totems, slot).xOffset = (slot - 2.5) * 36
    local buffs = spec.totemBuffs and spec.totemBuffs[slot]
    if buffs then
      local trigger = AuraTrigger(buffs, "showOnActive")
      trigger.nativeFilters = nil
      local glow = Icon(totems, "Totem " .. slot .. " buff", trigger, { size = 32 })
      table.remove(glow.subRegions, 1)
      glow.blizzardAuraDisplay = { maxIcons = 1 }
      glow.xOffset, glow.color, glow.cooldown = (slot - 2.5) * 36, {1, 1, 1, 0}, false
    end
  end

  local upkeep = Group("Upkeep", "dynamicgroup", -230)
  for _, entry in ipairs(spec.upkeep or {}) do
    AuraIcon(upkeep, entry.name, entry, entry.unit, entry.kind, nil, true)
  end
  for _, weapon in ipairs(spec.enchants or {}) do
    Icon(upkeep, "Enchant " .. weapon, Generic({ type = "item", event = "Weapon Enchant", weapon = weapon,
      use_weapon = true, showOn = "showOnActive", use_showOn = true }),
      { size = 32, subRegions = { timer }, offhand = weapon == "off" })
  end

  local rootData = Base(root, nil, "group", { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} }, {})
  rootData.controlledChildren = {}
  rootData.anchorFrameType, rootData.anchorPoint, rootData.selfPoint, rootData.xOffset, rootData.yOffset =
    "SCREEN", "CENTER", "CENTER", 0, -180

  for _, holder in ipairs(groups) do
    if #holder.members > 0 then
      rootData.controlledChildren[#rootData.controlledChildren + 1] = holder.group.id
      children[#children + 1] = holder.group
      for _, member in ipairs(holder.members) do children[#children + 1] = member end
    end
  end

  return { m = "d", s = "5.22.0", v = 2000, d = rootData, c = children }
end

return Pack

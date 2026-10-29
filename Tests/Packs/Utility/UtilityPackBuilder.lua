local Parts = dofile("Tests/Packs/PackBuilder.lua").Parts
local Utility = {}

Utility.Parts = Parts

-- A utility pack is one dynamic group of auras, for every class: name is the group id, prefix starts every uid,
-- layout holds the group fields (grow, anchor, offsets).
function Utility.New(name, prefix, layout)
  local children, uids = {}, {}

  -- Derived from the aura id, as in the class packs: a reimport updates the auras already installed.
  local function Uid(id)
    local hash = 5381
    for index = 1, #id do hash = (hash * 33 + id:byte(index)) % 2147483647 end
    local uid = string.format("%s%08x", prefix, hash)
    assert(not uids[uid], id .. ": uid collides with " .. tostring(uids[uid]))
    uids[uid] = id
    return uid
  end

  local function Load(options)
    local load = { class = { multi = {} }, size = { multi = {} }, spec = { multi = {} }, talent = { multi = {} } }
    if options.class then load.use_class, load.class.single = true, options.class end
    if options.outOfCombat then load.use_combat = false end
    if options.inCombat then load.use_combat = true end
    if options.inGroup then load.use_ingroup, load.ingroup = false, { multi = { group = true, raid = true } } end
    if options.zone then load.use_zoneIds, load.zoneIds = true, options.zone end
    if options.known then load.use_spellknown, load.spellknown = true, options.known end
    return load
  end

  -- A list of triggers shows the aura on any of them, or on all of them with options.all (the first one drives the
  -- display; a secret aura trigger after the first one is always shown, so the other ones must not be secret auras);
  -- notResting adds a requirement on top.
  local function Triggers(list, options)
    local triggers = { activeTriggerMode = -10 }
    for index, trigger in ipairs(list) do triggers[index] = { trigger = trigger, untrigger = {} } end
    if #list > 1 then triggers.disjunctive = options.all and "all" or "any" end
    if options.all then triggers.activeTriggerMode = 1 end
    if options.notResting then
      assert(#list == 1, "a rest requirement needs a single trigger")
      triggers[2] = { trigger = Parts.Generic({ type = "unit", event = "Conditions", use_resting = false }), untrigger = {} }
      triggers.disjunctive, triggers.activeTriggerMode = "all", 1
      if list[1].type == "secretAura" then triggers.secretFallback = "none" end
    end
    return triggers
  end

  local function Base(id, regionType, list, options)
    return {
      id = id, uid = Uid(id), regionType = regionType, internalVersion = 91, tocversion = 16001,
      triggers = Triggers(list, options), load = Load(options), conditions = options.conditions or {}, config = {},
      authorOptions = {}, actions = { start = {}, finish = {}, init = {} }, animation = Parts.Animation(),
      subRegions = options.subRegions or {},
      information = { forceEvents = true, ignoreOptionsEventErrors = true, showNilIsFalse = true },
    }
  end

  local root = Base(name, "dynamicgroup", { { type = "aura2", unit = "player", debuffType = "HELPFUL", names = {} } }, {})
  root.controlledChildren, root.anchorFrameType = {}, "SCREEN"
  root.anchorPoint, root.selfPoint, root.xOffset, root.yOffset = "CENTER", "CENTER", 0, 0
  root.grow, root.align, root.space, root.stagger, root.sort = "HORIZONTAL", "CENTER", 3, 0, "none"
  for key, value in pairs(layout or {}) do root[key] = value end
  -- A dynamic group keeps a fixed slot for each shown-on-demand secret aura: those packs use a Modern Aura Group.
  if root.flow then
    root.regionType, root.blizzardFlow, root.blizzardFlowGrowth, root.blizzardFlowSpacing = "group", true, root.flow, 3
    root.flow, root.grow, root.align, root.space, root.stagger, root.sort = nil, nil, nil, nil, nil, nil
  end

  local pack = {}

  function pack.Add(label, regionType, list, options)
    local data = Base(name .. " - " .. label, regionType, list, options)
    data.parent = root.id
    root.controlledChildren[#root.controlledChildren + 1] = data.id
    children[#children + 1] = data
    return data
  end

  -- options: size, subRegions, conditions, missing (desaturated when the aura is missing), countdown, load fields
  -- (class, inCombat, outOfCombat, inGroup, zone, known).
  function pack.Icon(label, list, options)
    local subRegions, conditions = {}, {}
    for index, subRegion in ipairs(options.subRegions or {}) do subRegions[index] = subRegion end
    for index, condition in ipairs(options.conditions or {}) do conditions[index] = condition end
    subRegions[#subRegions + 1] = Parts.BORDER
    if options.missing then
      local missing = Parts.Condition("faAuraMissing", nil, "desaturate", true)
      missing.changes[2] = { property = "color", value = {1, 1, 1, 0.5} }
      conditions[#conditions + 1] = missing
    end
    options.subRegions, options.conditions = subRegions, conditions
    local data = pack.Add(label, "icon", list, options)
    data.width, data.height, data.keepAspectRatio = options.size[1], options.size[2], true
    data.iconSource, data.displayIcon = -1, options.texture
    data.cooldown, data.cooldownTextDisabled = true, not options.countdown
    data.desaturate, data.color, data.zoom = false, {1, 1, 1, 1}, 0.3
    return data
  end

  function pack.Text(label, list, text, options)
    local data = pack.Add(label, "text", list, options)
    data.displayText, data.font, data.fontSize, data.outline = text, "Friz Quadrata TT", options.fontSize or 14, "OUTLINE"
    data.color, data.justify = options.color or {1, 1, 1, 1}, "CENTER"
    return data
  end

  function pack.Finish()
    return { m = "d", s = "5.22.0", v = 2000, d = root, c = children }
  end

  return pack
end

-- Secret aura on any caster: raid buffs and debuffs come from other players.
function Utility.AnyCaster(ids, showOn, unit, kind)
  local trigger = Parts.AuraTrigger(ids, showOn, unit, kind)
  trigger.nativeFilters = nil
  return trigger
end

return Utility

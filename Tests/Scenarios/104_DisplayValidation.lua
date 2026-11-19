-- Display.Validate, one valid and one invalid case for each rule, in the order the rules run. The delegated
-- checks (appearance, single aura, flow, conditions) have their own contracts: one case each here proves the call.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local L = WeakAuras.L

  local savedValidFilter = AuraUtil and AuraUtil.IsValidFilterString
  AuraUtil = AuraUtil or {}
  local filterValid = true
  AuraUtil.IsValidFilterString = function() return filterValid end

  local function Aura(trigger, extra)
    local data = {
      id = "Checked", uid = "Checked", regionType = "icon", width = 30, height = 30, anchorFrameType = "SCREEN",
      triggers = { { trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL" } } },
      blizzardAuraDisplay = {},
    }
    for key, value in pairs(trigger or {}) do data.triggers[1].trigger[key] = value end
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function Expect(label, expected, trigger, extra)
    local actual = Display.Validate(Aura(trigger, extra))
    assert(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
  end
  local function Valid(label, trigger, extra) Expect(label, nil, trigger, extra) end

  Valid("base aura")

  -- Eligible: an Aura (Modern) trigger on a supported region.
  Expect("no Aura (Modern) trigger", "Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar,"
    .. " Progress Texture or Text.", nil, { triggers = { { trigger = { type = "aura2" } } } })
  Expect("unsupported region", "Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar,"
    .. " Progress Texture or Text.", nil, { regionType = "model" })

  -- Circular progress texture: needs the render mode enum.
  local circular = { regionType = "progresstexture", orientation = "CLOCKWISE" }
  local savedRenderMode = Enum.StatusBarRenderMode
  Enum.StatusBarRenderMode = savedRenderMode or { Default = 0 }
  Valid("circular texture with render mode", nil, circular)
  Enum.StatusBarRenderMode = nil
  Expect("circular texture without render mode", L["This client cannot draw circular Progress Textures this way."],
    nil, circular)
  Valid("linear texture without render mode", nil, { regionType = "progresstexture", orientation = "HORIZONTAL" })
  Enum.StatusBarRenderMode = savedRenderMode

  -- Appearance.
  Valid("supported sub element", nil, { subRegions = { { type = "subglow" } } })
  Expect("unsupported sub element", "This sub element is not supported by Aura (Modern). Use Text, Texture or Glow.",
    nil, { subRegions = { {} } })

  -- Spell lists turned on need at least one ID.
  Valid("exact IDs", { secretUseSpellIDs = true, auraspellids = { "6673" } })
  Expect("exact IDs empty", "Type an exact spell ID, or untick Exact Spell IDs to match every aura.",
    { secretUseSpellIDs = true, auraspellids = {} })
  Valid("rank IDs", { secretUseRankSpellIDs = true, auraRankSpellIDs = { "6673" } })
  Expect("rank IDs empty", "Type a spell ID, or untick Spell ID(s) (All Ranks).", { secretUseRankSpellIDs = true })
  Valid("ignored IDs", { secretUseExcludedSpellIDs = true, excludedAuraSpellIDs = { "774" } })
  Expect("ignored IDs empty", "Type an ignored spell ID, or untick Ignored Exact Spell IDs.",
    { secretUseExcludedSpellIDs = true })

  -- Unit and aura type.
  local MESSAGE_BAD_UNIT = "Choose a supported unit and Buff or Debuff."
  Valid("target debuff", { unit = "target", debuffType = "HARMFUL" })
  Expect("unknown unit", MESSAGE_BAD_UNIT, { unit = "vehicle" })
  Expect("both aura types", MESSAGE_BAD_UNIT, { debuffType = "BOTH" })
  Valid("specific unit", { unit = "member", specificUnit = "party1" })
  Expect("specific unit missing", "Type a Specific Unit such as party1, raid5, boss1 or arena2.", { unit = "member" })
  Expect("specific unit malformed", "Type a Specific Unit such as party1, raid5, boss1 or arena2.",
    { unit = "member", specificUnit = "party9" })
  local savedNamePlate = C_NamePlate
  C_NamePlate = { GetNamePlateForUnit = function() end }
  Valid("nameplate", { unit = "nameplate" })
  C_NamePlate = nil
  Expect("nameplate without frames", "Nameplate frames are not available on this client.", { unit = "nameplate" })
  C_NamePlate = savedNamePlate

  -- Spell IDs: positive whole numbers.
  local MESSAGE_IDS = "Spell IDs must be positive whole numbers."
  Valid("whole ID", { auraspellids = { "6673", 774 } })
  for _, bad in ipairs({ "0", "-5", "1.5", "abc", "inf" }) do
    Expect("spell ID " .. bad, MESSAGE_IDS, { auraspellids = { bad } })
  end
  Expect("bad rank ID", MESSAGE_IDS, { auraRankSpellIDs = { "x" } })
  Expect("bad ignored ID", MESSAGE_IDS, { excludedAuraSpellIDs = { "0" } })

  -- Boolean filters.
  Valid("filter on", { isBossAura = true })
  Valid("filter off", { isBossAura = false })
  local flagMessage = Display.Validate(Aura({ isBossAura = "yes" }))
  assert(type(flagMessage) == "string" and flagMessage:find("^Filter '.+' must be on, off or left unset%.$"),
    "non boolean filter: " .. tostring(flagMessage))

  -- Duration limit and sort order.
  local MESSAGE_DURATION = "Maximum total duration must be a number above zero."
  Valid("duration limit", { maxDuration = 10 })
  for label, bad in pairs({ zero = 0, negative = -1, infinite = math.huge, nan = 0 / 0, text = "5" }) do
    Expect("duration " .. label, MESSAGE_DURATION, { maxDuration = bad })
  end
  Valid("sort order", { sortMethod = "Name" })
  Expect("unknown sort order", "Pick one of the available sort orders.", { sortMethod = "Bogus" })

  -- Blizzard filters, filter string and dispel types.
  local MESSAGE_NATIVE = "Pick only Blizzard aura filters from the list."
  local MESSAGE_DISPEL = "Pick only dispel types from the list."
  Valid("native filter", { nativeFilters = { PLAYER = true, RAID = false } })
  Expect("unknown native filter", MESSAGE_NATIVE, { nativeFilters = { BOGUS = true } })
  Expect("non boolean native filter", MESSAGE_NATIVE, { nativeFilters = { PLAYER = "yes" } })
  filterValid = false
  Expect("filter string refused", "This client does not support the selected Blizzard aura filters.")
  filterValid = true
  Valid("dispel types", { includeDispelTypes = { Magic = true }, excludeDispelTypes = { Poison = true } })
  Expect("unknown dispel type", MESSAGE_DISPEL, { includeDispelTypes = { Shadow = true } })
  Expect("dispel type not true", MESSAGE_DISPEL, { excludeDispelTypes = { Magic = 1 } })

  -- Delegated checks: single aura settings, flow group child, a condition on a missing trigger.
  local brokenSingle = { secretShowOn = "showOnMissing", secretUseStacks = true, secretStacks = 3 }
  local singleData = Aura(brokenSingle)
  local singleMessage = Display.ValidateSingle(singleData, singleData.triggers[1].trigger)
  assert(singleMessage, "single aura contract: no message for stacks on a missing aura")
  Expect("stacks on a missing aura", singleMessage, brokenSingle)
  local getData = WeakAuras.GetData
  WeakAuras.GetData = function(id)
    if id == "Flow" then return { id = "Flow", regionType = "group", blizzardFlow = true } end
    return getData(id)
  end
  local flowText = { parent = "Flow", regionType = "text" }
  local flowData = Aura(nil, flowText)
  local flowMessage = Display.FlowProblem(flowData, flowData.triggers[1].trigger)
  assert(flowMessage, "flow contract: no message for a text child")
  Expect("text in a flow group", flowMessage, nil, flowText)
  Valid("icon in a flow group", nil, { parent = "Flow" })
  WeakAuras.GetData = getData
  local brokenConditions = { conditions = { { check = { trigger = 7, variable = "x" } } } }
  local conditionMessage = Display.ValidateConditions(Aura(nil, brokenConditions))
  assert(conditionMessage, "conditions contract: no message for a missing trigger")
  Expect("condition on a missing trigger", conditionMessage, nil, brokenConditions)
  Valid("global condition", nil, { conditions = { { check = { trigger = -1, variable = "x" } } } })

  -- Actions and animations.
  local MESSAGE_ACTIONS = L["Only Chat Message, Play Sound and Hide Glows can run in On Show/On Hide for an Aura (Modern)"
    .. " trigger. Custom Init is available."]
  local MESSAGE_SOUNDS = L["Aura (Modern) sounds accept sound files only, not Sound Kit IDs or Stop Sound."]
  Valid("sound, message and custom init", nil, { actions = {
    start = { do_sound = true, sound = " custom", sound_path = "a.ogg" }, finish = { do_message = true },
    init = { do_custom = true },
  }, animation = { start = { type = "none" } } })
  Expect("glow action", MESSAGE_ACTIONS, nil, { actions = { start = { do_glow = true } } })
  Valid("glow action turned off", nil, { actions = { start = { do_glow = false } } })
  Expect("sound kit", MESSAGE_SOUNDS, nil, { actions = { finish = { do_sound = true, sound = " KitID" } } })
  Expect("stop sound", MESSAGE_SOUNDS, nil, { actions = { start = { stop_sound = true } } })
  Expect("animation", L["Animations are not available on an Aura (Modern) trigger."], nil,
    { animation = { main = { type = "preset" } } })

  AuraUtil.IsValidFilterString = savedValidFilter
end

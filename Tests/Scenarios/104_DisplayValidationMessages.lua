-- Texts of Display.Validate, the warning a player reads on an Aura (Modern) trigger: one valid case and the exact
-- message of each rule. Scenario 48 already covers which checks fire and in which order, not the texts.
-- Texts of the delegates: ValidateAppearance in 39 and 50, ValidateSingle in 45, FlowProblem in 27 and 44, ValidateConditions in 43.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local savedValidFilter = AuraUtil and AuraUtil.IsValidFilterString
  AuraUtil = AuraUtil or {}
  AuraUtil.IsValidFilterString = function() return true end

  local function Aura(extraTrigger, extraData)
    local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL" }
    for key, value in pairs(extraTrigger or {}) do trigger[key] = value end
    local data = { id = "V", uid = "V", regionType = "icon", triggers = { { trigger = trigger } }, blizzardAuraDisplay = {} }
    for key, value in pairs(extraData or {}) do data[key] = value end
    return data
  end
  local function Says(expected, extraTrigger, extraData)
    local issue = Display.Validate(Aura(extraTrigger, extraData))
    assert(issue == expected, ("expected %q, got %q"):format(tostring(expected), tostring(issue)))
  end

  Says(nil)

  -- Before the rules.
  Says("Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text.",
    { type = "aura2" })
  local savedRenderMode = Enum.StatusBarRenderMode
  Enum.StatusBarRenderMode = nil
  Says("This client cannot draw circular Progress Textures this way.", nil,
    { regionType = "progresstexture", orientation = "CLOCKWISE" })
  Enum.StatusBarRenderMode = savedRenderMode or {}
  Says(nil, nil, { regionType = "progresstexture", orientation = "CLOCKWISE" })
  Enum.StatusBarRenderMode = savedRenderMode

  -- Spell lists.
  Says("Type an exact spell ID, or untick Exact Spell IDs to match every aura.", { secretUseSpellIDs = true })
  Says("Type a spell ID, or untick Spell ID(s) (All Ranks).", { secretUseRankSpellIDs = true })
  Says("Type an ignored spell ID, or untick Ignored Exact Spell IDs.", { secretUseExcludedSpellIDs = true })

  -- Unit.
  Says("Choose a supported unit and Buff or Debuff.", { unit = "bogus" })
  Says("Type a Specific Unit such as party1, raid5, boss1 or arena2.", { unit = "member" })
  local savedPlates = C_NamePlate
  C_NamePlate = nil
  Says("Nameplate frames are not available on this client.", { unit = "nameplate" })
  C_NamePlate = savedPlates

  -- Values.
  Says("Spell IDs must be positive whole numbers.", { auraspellids = { 0 } })
  local flag = Display.booleanFilters[1]
  Says("Filter '" .. flag[2] .. "' must be on, off or left unset.", { [flag[1]] = "yes" })
  Says("Maximum total duration must be a number above zero.", { maxDuration = 0 })
  Says("Pick one of the available sort orders.", { sortMethod = "Bogus" })

  -- Blizzard filters and dispel types.
  Says("Pick only Blizzard aura filters from the list.", { nativeFilters = { BOGUS = true } })
  AuraUtil.IsValidFilterString = function() return false end
  Says("This client does not support the selected Blizzard aura filters.", { nativeFilters = { PLAYER = true } })
  AuraUtil.IsValidFilterString = function() return true end
  Says("Pick only dispel types from the list.", { includeDispelTypes = { Fire = true } })

  -- Actions and animations.
  Says("Only Chat Message, Play Sound and Hide Glows can run in On Show/On Hide for an Aura (Modern) trigger. "
    .. "Custom Init is available.", nil, { actions = { start = { do_glow = true } } })
  Says("Aura (Modern) sounds accept sound files only, not Sound Kit IDs or Stop Sound.", nil,
    { actions = { finish = { do_sound = true, sound = " KitID" } } })
  Says("Aura (Modern) sounds accept sound files only, not Sound Kit IDs or Stop Sound.", nil,
    { actions = { start = { stop_sound = true } } })
  Says("Animations are not available on an Aura (Modern) trigger.", nil, { animation = { start = { type = "preset" } } })

  AuraUtil.IsValidFilterString = savedValidFilter
end

-- OptionsContract: freezes the public contract of the three option builders (AuraDisplayOptions,
-- SecretAuraTriggerOptions, CooldownViewerOptions) before they are rewritten: option tree (key, type, order,
-- name, values, hidden/disabled evaluated...), values read by get, fields written by set, and the callbacks
-- they trigger (Add, refresh, thumbnail...). Only what the builders publish is used; no local function.
-- The EXPECTED block below is generated from the current code (set OPTIONS_CONTRACT_OUT=<file> to dump it).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local optionsDirectory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  ---------------------------------------------------------------------------------------------------------------
  -- Serialisation helpers
  ---------------------------------------------------------------------------------------------------------------
  local function Fmt(value, depth)
    local kind = type(value)
    if kind == "number" then
      if value == math.floor(value) then return string.format("%d", value) end
      return string.format("%.9f", value)
    elseif kind == "string" then
      return (string.format("%q", value):gsub("\\\n", "\\n"))
    elseif kind == "table" then
      if (depth or 0) > 4 then return "{...}" end
      local entries = {}
      for key, item in pairs(value) do
        entries[#entries + 1] = { Fmt(key), Fmt(item, (depth or 0) + 1) }
      end
      table.sort(entries, function(left, right) return left[1] < right[1] end)
      local parts = {}
      for _, entry in ipairs(entries) do parts[#parts + 1] = entry[1] .. "=" .. entry[2] end
      return "{" .. table.concat(parts, ",") .. "}"
    elseif kind == "function" then
      return "<fn>"
    end
    return tostring(value)
  end

  local ACTIONS = { get = true, set = true, validate = true, func = true }
  local function Evaluate(fn)
    local results = { pcall(fn) }
    if not results[1] then return "ERR" end
    local parts = {}
    for index = 2, #results do parts[#parts + 1] = Fmt(results[index]) end
    if #parts == 0 then return "nil" end
    return "fn:" .. table.concat(parts, ",")
  end

  local function DumpOption(option)
    local fields = {}
    for field, value in pairs(option) do fields[#fields + 1] = field end
    table.sort(fields)
    local parts = {}
    for _, field in ipairs(fields) do
      local value = option[field]
      if type(value) == "function" then
        parts[#parts + 1] = field .. "=" .. (ACTIONS[field] and "<fn>" or Evaluate(value))
      else
        parts[#parts + 1] = field .. "=" .. Fmt(value)
      end
    end
    return table.concat(parts, " ")
  end

  local function DumpTree(lines, tree)
    local keys = {}
    for key in pairs(tree) do keys[#keys + 1] = key end
    table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)
    for _, key in ipairs(keys) do
      local option = tree[key]
      if type(option) == "table" and option.type then
        lines[#lines + 1] = key .. " | " .. DumpOption(option)
      elseif type(option) == "table" then
        lines[#lines + 1] = key .. " = " .. Fmt(option)
      else
        lines[#lines + 1] = key .. " = " .. Fmt(option)
      end
    end
  end

  ---------------------------------------------------------------------------------------------------------------
  -- Call counters on the collaborators the builders reach
  ---------------------------------------------------------------------------------------------------------------
  local counts = {}
  local function Counter(name)
    return function() counts[name] = (counts[name] or 0) + 1 end
  end
  local function TakeCounts()
    local names = {}
    for name in pairs(counts) do names[#names + 1] = name end
    table.sort(names)
    local parts = {}
    for _, name in ipairs(names) do parts[#parts + 1] = name .. "=" .. counts[name] end
    counts = {}
    return "calls: " .. (#parts > 0 and table.concat(parts, " ") or "none")
  end

  local saved = {}
  local function Replace(owner, key, value)
    saved[#saved + 1] = { owner, key, owner[key] }
    owner[key] = value
  end
  Replace(WeakAuras, "Add", Counter("Add"))
  Replace(WeakAuras, "ClearAndUpdateOptions", Counter("ClearAndUpdateOptions"))
  Replace(WeakAuras, "FillOptions", Counter("FillOptions"))
  Replace(WeakAuras, "UpdateThumbnail", Counter("UpdateThumbnail"))
  Replace(private, "ScanForLoads", Counter("ScanForLoads"))
  Replace(private, "UpdateFakeStatesFor", Counter("UpdateFakeStatesFor"))

  local cases, order = {}, {}
  local function Case(name, body)
    local lines = {}
    local ok, message = xpcall(function() body(lines) end, debug.traceback)
    if not ok then lines[#lines + 1] = "ERROR " .. tostring(message) end
    cases[name] = table.concat(lines, "\n")
    order[#order + 1] = name
  end

  local function Probe(lines, label, fn)
    TakeCounts()
    local results = { pcall(fn) }
    local parts = {}
    for index = 2, #results do parts[#parts + 1] = Fmt(results[index]) end
    lines[#lines + 1] = label .. " -> " .. (results[1] and table.concat(parts, ",") or "ERR") .. " | " .. TakeCounts()
  end

  ---------------------------------------------------------------------------------------------------------------
  -- AuraDisplayOptions
  ---------------------------------------------------------------------------------------------------------------
  -- Option files load without Private: in game, WeakAuras.ToggleOptions sets it after LoadAddOn.
  local displayPrivate = {}
  local ok, message = test.Loader.RunFile(optionsDirectory .. "AuraDisplayOptions.lua", "WeakAurasOptions", displayPrivate)
  displayPrivate.Private = private
  assert(ok, tostring(message))

  local function SecretIconData(extra)
    local data = {
      id = "Display", regionType = "icon", cooldown = true,
      triggers = { { trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL", auraspellids = { "1" } } } },
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end

  Case("display.settings.new", function(lines)
    local data = SecretIconData()
    local args = displayPrivate.GetSecretAuraSettings(data)
    DumpTree(lines, args)
    Probe(lines, "growth.get", function() return args.growth.get() end)
    Probe(lines, "spacing.get", function() return args.spacing.get() end)
    Probe(lines, "maxIcons.get", function() return args.maxIcons.get() end)
    Probe(lines, "sortMethod.get", function() return args.sortMethod.get() end)
    Probe(lines, "sortReverse.get", function() return args.sortReverse.get() end)
    Probe(lines, "growth.set", function() args.growth.set(nil, "UP") end)
    test.Environment.Advance(1)
    lines[#lines + 1] = "after growth.set: " .. Fmt(data.blizzardAuraDisplay) .. " | " .. TakeCounts()
    Probe(lines, "spacing.set", function() args.spacing.set(nil, 12) end)
    test.Environment.Advance(1)
    lines[#lines + 1] = "after spacing.set: " .. Fmt(data.blizzardAuraDisplay) .. " | " .. TakeCounts()
    Probe(lines, "maxIcons.set", function() args.maxIcons.set(nil, 25) end)
    Probe(lines, "sortMethod.set UnitFrameDebuff", function() args.sortMethod.set(nil, "UnitFrameDebuff") end)
    test.Environment.Advance(1)
    lines[#lines + 1] = "after sortMethod.set: " .. Fmt(data.triggers[1].trigger) .. " | " .. TakeCounts()
    Probe(lines, "sortMethod.get after", function() return args.sortMethod.get() end)
    Probe(lines, "sortReverse.set", function() args.sortReverse.set(nil, true) end)
    test.Environment.Advance(1)
    lines[#lines + 1] = "after sortReverse.set: " .. Fmt(data.triggers[1].trigger.sortReverse) .. " | " .. TakeCounts()
    Probe(lines, "sortReverse.get after", function() return args.sortReverse.get() end)
    Probe(lines, "textHeight.get", function() return args.textHeight.get() end)
    Probe(lines, "textHeight.set", function() args.textHeight.set(nil, 30) end)
    lines[#lines + 1] = "data: " .. Fmt(data.blizzardAuraDisplay)
  end)

  Case("display.settings.existing", function(lines)
    local data = SecretIconData({
      regionType = "text", fontSize = 20, id = "DisplayText",
      blizzardAuraDisplay = { growth = "CENTER_HORIZONTAL", spacing = 3, maxIcons = 5, textHeight = 33 },
    })
    data.triggers[1].trigger.sortMethod = "Expiration"
    data.triggers[1].trigger.sortReverse = true
    local args = displayPrivate.GetSecretAuraSettings(data)
    DumpTree(lines, args)
    Probe(lines, "growth.get", function() return args.growth.get() end)
    Probe(lines, "spacing.get", function() return args.spacing.get() end)
    Probe(lines, "maxIcons.get", function() return args.maxIcons.get() end)
    Probe(lines, "sortMethod.get", function() return args.sortMethod.get() end)
    Probe(lines, "sortReverse.get", function() return args.sortReverse.get() end)
    Probe(lines, "textHeight.get", function() return args.textHeight.get() end)
    Probe(lines, "sortMethod.set Name", function() args.sortMethod.set(nil, "Name") end)
    test.Environment.Advance(1)
    lines[#lines + 1] = "trigger: " .. Fmt(data.triggers[1].trigger) .. " | " .. TakeCounts()
    data.blizzardAuraDisplay = nil
    Probe(lines, "textHeight.get default", function()
      data.fontSize = nil
      return args.textHeight.get()
    end)
    Probe(lines, "no trigger sortMethod.get", function()
      data.triggers[1].trigger.type = "aura2"
      return args.sortMethod.get(), args.sortReverse.get()
    end)
  end)

  local function DisplayGroups()
    return {
      icon = {
        __title = "Icon", __order = 1,
        iconSource = { type = "select", name = "Icon Source", order = 1, values = { [-1] = "Automatic", [0] = "Manual", [1] = "Trigger" } },
        useTooltip = { type = "toggle", name = "Tooltip on Mouseover", order = 2 },
        iconInset = { type = "range", name = "Icon Inset", order = 3 },
        spark = { type = "toggle", name = "Spark", order = 4 },
        notAnOption = "text",
      },
      ["sub.1.subtext"] = {
        __title = "Text", __order = 2,
        text_text = { type = "input", name = "Text", order = 1, desc = "original" },
        text_text_pChoose = { type = "toggle", name = "Choose", order = 2 },
        text_text_format_p_format = { type = "select", name = "Format", order = 3, values = { timed = "Time Format", other = "Other" } },
        text_text_format_p_time_format = { type = "select", name = "Time", order = 4, values = { [0] = "x" } },
        text_text_format_p_time_precision = { type = "select", name = "Precision", order = 5 },
        text_text_format_s_big_number = { type = "toggle", name = "Big", order = 6 },
        text_text_format_footer = { type = "toggle", name = "Footer", order = 7 },
        text_text_format_header = { type = "description", name = "Header", order = 8 },
        text_text_format_n_title = { type = "execute", name = "Action", order = 9 },
        automaticWidth = { type = "select", name = "Width", order = 10, values = { Auto = "Auto", Fixed = "Fixed" } },
        text_customTextUpdate = { type = "select", name = "Update", order = 11 },
        anchor_area = { type = "select", name = "Area", order = 12, values = { ALL = "All", bar = "Bar" } },
        anchor_point = { type = "select", name = "Point", order = 13, values = { TOPLEFT = "Top Left", ["FRAME.x"] = "Frame", lower = "lower", CENTER = "Center" } },
      },
      ["sub.2.subborder"] = {
        __title = "Border", __order = 3, __duplicate = true,
        border_ppscale = { type = "toggle", name = "Pixel Scale", order = 1, disabled = true },
        border_offset = { type = "range", name = "Offset", order = 2 },
        slanted = { type = "toggle", name = "Slanted", order = 3 },
      },
      ["sub.3.subglow"] = {
        __title = "Glow", __order = 4,
        glowType = { type = "select", name = "Glow Type", order = 1, values = { buttonOverlay = "A", Pixel = "B", Other = "C" } },
        glowStartAnim = { type = "toggle", name = "Start Anim", order = 2 },
        glowColor = { type = "color", name = "Color", order = 3.5 },
      },
      ["sub.4.subtext"] = {
        __title = "Detached Candidate", __order = 5,
        text_text = { type = "input", name = "Text", order = 1, desc = "original" },
        text_text_pChoose = { type = "toggle", name = "Choose", order = 2 },
        text_text_format_s_big_number = { type = "toggle", name = "Big", order = 3 },
      },
      position = {
        __title = "Position", __order = 9,
        anchor_point = { type = "select", name = "Point", order = 1, values = { TOPLEFT = "x", ["a.b"] = "y" } },
        useTooltip = { type = "toggle", name = "Tooltip", order = 2 },
      },
      progressOptions = { __title = "Progress", __order = 5 },
      secretAura = { __title = "Old Secret" },
    }
  end

  local function DumpGroups(lines, groups)
    local names = {}
    for name in pairs(groups) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
      lines[#lines + 1] = "[" .. name .. "]"
      DumpTree(lines, groups[name])
    end
  end

  Case("display.prepare.icon", function(lines)
    local data = SecretIconData({
      subRegions = { { type = "subtext" }, { type = "subborder" }, { type = "subglow" }, { type = "subtext", secretAuraDetached = true } },
    })
    local groups = DisplayGroups()
    displayPrivate.PrepareSecretDisplayOptions(data, groups)
    DumpGroups(lines, groups)
    local swipe = groups.icon.secretSwipeColor
    Probe(lines, "swipe.get default", function() return swipe.get() end)
    Probe(lines, "swipe.set", function() swipe.set(nil, 0.1, 0.2, 0.3, 0.4) end)
    lines[#lines + 1] = "data: " .. Fmt(data.blizzardAuraDisplay)
    Probe(lines, "swipe.get saved", function() return swipe.get() end)
    local auraEditor = { Private = private, QueueOptionsRefresh = Counter("QueueOptionsRefresh") }
    assert(test.Loader.RunFile(optionsDirectory .. "AuraTriggerOptions.lua", "WeakAurasOptions", auraEditor))
    Replace(displayPrivate, "AuraEditor", auraEditor.AuraEditor)
    Probe(lines, "switchToClassic.func", function() groups.icon.secretSwitchToClassic.func() end)
    lines[#lines + 1] = "trigger: " .. Fmt(data.triggers[1].trigger) .. " enabled=" .. Fmt(data.blizzardAuraDisplay.enabled)
  end)

  Case("display.prepare.group-flow-and-disabled", function(lines)
    local flowData = SecretIconData({ id = "FlowChild", parent = "FlowParent" })
    local realGetData = WeakAuras.GetData
    Replace(WeakAuras, "GetData", function(id)
      if id == "FlowParent" then return { id = "FlowParent", regionType = "group", blizzardFlow = true } end
      return realGetData(id)
    end)
    local groups = DisplayGroups()
    displayPrivate.PrepareSecretDisplayOptions(flowData, groups)
    lines[#lines + 1] = "flow: secretAura=" .. Fmt(groups.secretAura) .. " progressOptions=" .. Fmt(groups.progressOptions)
      .. " icon.swipe=" .. tostring(groups.icon.secretSwipeColor ~= nil)
    DumpGroups(lines, groups)

    local plain = { id = "Plain", regionType = "icon", triggers = { { trigger = { type = "aura2", unit = "player" } } } }
    local untouched = DisplayGroups()
    displayPrivate.PrepareSecretDisplayOptions(plain, untouched)
    local reference = DisplayGroups()
    lines[#lines + 1] = "not enabled leaves groups untouched: " .. tostring(Fmt(untouched.secretAura) == Fmt(reference.secretAura)
      and untouched.icon.secretSwipeColor == nil and untouched.progressOptions ~= nil)

    local barData = SecretIconData({ id = "Bar", regionType = "aurabar", subRegions = {} })
    local barGroups = DisplayGroups()
    displayPrivate.PrepareSecretDisplayOptions(barData, barGroups)
    lines[#lines + 1] = "aurabar anchor_area: " .. Fmt(barGroups["sub.1.subtext"].anchor_area.values)
      .. " swipe=" .. tostring(barGroups.icon.secretSwipeColor ~= nil)
  end)

  local function ActionArgs()
    return {
      args = {
        start_header = { type = "header", name = "On Show", order = 1 },
        start_do_message = { type = "toggle", name = "Chat Message", order = 2 },
        start_message_type = { type = "select", name = "Message Type", order = 3 },
        start_do_sound = { type = "toggle", name = "Play Sound", order = 4 },
        start_sound = { type = "select", name = "Sound", order = 5, values = { x = "x" } },
        start_sound_channel = { type = "select", name = "Channel", order = 5.5 },
        start_stop_sound = { type = "execute", name = "Stop sound", order = 6 },
        start_do_sound_fade = { type = "toggle", name = "Fade", order = 7 },
        start_stop_sound_fade = { type = "range", name = "Fade time", order = 8 },
        start_do_custom = { type = "toggle", name = "Custom", order = 9 },
        start_custom = { type = "input", name = "Code", order = 10 },
        start_do_glow = { type = "toggle", name = "Glow", order = 11 },
        start_glow_action = { type = "select", name = "Action", order = 12 },
        start_choose_glow_frame = { type = "toggle", name = "Frame", order = 13 },
        start_use_glow_color = { type = "toggle", name = "Use color", order = 14 },
        start_glow_type = { type = "select", name = "Type", order = 15, values = { Pixel = "Pixel", Proc = "Proc" } },
        start_glow_color = { type = "color", name = "Color", order = 16 },
        start_glow_duration = { type = "range", name = "Duration", order = 17 },
        start_glow_XOffset = { type = "range", name = "X", order = 18 },
        start_glow_YOffset = { type = "range", name = "Y", order = 19 },
        start_glow_padding = { type = "range", name = "Old padding", order = 20 },
        finish_header = { type = "header", name = "On Hide", order = 30 },
        finish_do_message = { type = "toggle", name = "Chat Message", order = 31 },
        finish_do_sound = { type = "toggle", name = "Play Sound", order = 32 },
        finish_sound = { type = "select", name = "Sound", order = 33 },
        finish_do_custom = { type = "toggle", name = "Custom", order = 34 },
        init_do_custom = { type = "toggle", name = "Init", order = 40 },
        other = { type = "toggle", name = "Other", order = 41 },
      },
    }
  end

  local function ActionData(extra)
    local data = SecretIconData({ id = "Action", actions = { start = {}, finish = {} }, anchorFrameType = "SCREEN" })
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end

  Case("display.action.new", function(lines)
    local data = ActionData({ blizzardAuraDisplay = {} })
    data.actions.start.do_custom = true
    local action = ActionArgs()
    displayPrivate.PrepareSecretActionOptions(data, action)
    DumpTree(lines, action.args)
    local args = action.args
    Probe(lines, "do_glow.get", function() return args.start_do_glow.get() end)
    Probe(lines, "glow_type.get", function() return args.start_glow_type.get() end)
    Probe(lines, "glow_color.get", function() return args.start_glow_color.get() end)
    Probe(lines, "glow_duration.get", function() return args.start_glow_duration.get() end)
    Probe(lines, "glow_padding.get", function() return args.start_glow_padding.get() end)
    Probe(lines, "do_glow.set true", function() args.start_do_glow.set(nil, true) end)
    lines[#lines + 1] = "data: " .. Fmt(data.blizzardAuraDisplay) .. " do_glow=" .. Fmt(data.actions.start.do_glow)
    Probe(lines, "glow_type.set buttonOverlay", function() args.start_glow_type.set(nil, "buttonOverlay") end)
    Probe(lines, "glow_type.get after", function() return args.start_glow_type.get() end)
    Probe(lines, "glow_color.set", function() args.start_glow_color.set(nil, 0.1, 0.2, 0.3, 0.4) end)
    Probe(lines, "glow_color.get after", function() return args.start_glow_color.get() end)
    Probe(lines, "use_glow_color.set false", function() args.start_use_glow_color.set(nil, false) end)
    Probe(lines, "glow_duration.set", function() args.start_glow_duration.set(nil, 2) end)
    Probe(lines, "glow_XOffset.set", function() args.start_glow_XOffset.set(nil, 4) end)
    Probe(lines, "glow_YOffset.set", function() args.start_glow_YOffset.set(nil, -4) end)
    Probe(lines, "glow_padding.set", function() args.start_glow_padding.set(nil, 7) end)
    lines[#lines + 1] = "data: " .. Fmt(data.blizzardAuraDisplay)
    data.anchorFrameType = "UNITFRAME"
    lines[#lines + 1] = "unitframe: glow_type.hidden=" .. Fmt(args.start_glow_type.hidden())
      .. " disabled=" .. Fmt(args.start_glow_type.disabled())
      .. " color.disabled=" .. Fmt(args.start_glow_color.disabled())
      .. " do_glow.disabled=" .. Fmt(args.start_do_glow.disabled())
    lines[#lines + 1] = "custom disabled: " .. Fmt(args.start_custom.disabled == nil) .. " do_custom=" .. Evaluate(args.start_do_custom.disabled)

  end)

  Case("display.action.existing", function(lines)
    local data = ActionData({
      anchorFrameType = "UNITFRAME",
      blizzardAuraDisplay = {
        unitGlow = true, unitGlowType = "pulse", unitUseGlowColor = false, unitGlowColor = { 0.5, 0.5, 0.5, 1 },
        unitGlowDuration = 3, unitGlowX = 2, unitGlowY = 5, unitGlowPadding = 4,
      },
    })
    data.actions.start.do_sound = true
    local action = ActionArgs()
    displayPrivate.PrepareSecretActionOptions(data, action)
    DumpTree(lines, action.args)
    local args = action.args
    Probe(lines, "do_glow.get", function() return args.start_do_glow.get() end)
    Probe(lines, "glow_type.get", function() return args.start_glow_type.get() end)
    Probe(lines, "glow_color.get", function() return args.start_glow_color.get() end)
    Probe(lines, "use_glow_color.get", function() return args.start_use_glow_color.get() end)
    Probe(lines, "glow_duration.get", function() return args.start_glow_duration.get() end)
    Probe(lines, "glow_XOffset.get", function() return args.start_glow_XOffset.get() end)
    Probe(lines, "glow_YOffset.get", function() return args.start_glow_YOffset.get() end)
    Probe(lines, "glow_padding.get", function() return args.start_glow_padding.get() end)
    Probe(lines, "do_glow.set false", function() args.start_do_glow.set(nil, false) end)
    lines[#lines + 1] = "data: " .. Fmt(data.blizzardAuraDisplay) .. " do_glow=" .. Fmt(data.actions.start.do_glow)
  end)

  Case("display.action.group", function(lines)
    local child = SecretIconData({ id = "Child" })
    local plainChild = { id = "PlainChild", regionType = "icon", triggers = { { trigger = { type = "aura2", unit = "player" } } } }
    local group = { id = "Group", regionType = "group", controlledChildren = { "Child", "PlainChild" } }
    local children = { Child = child, PlainChild = plainChild }
    Replace(private, "TraverseLeafs", function(data)
      local index = 0
      return function()
        index = index + 1
        local id = data.controlledChildren[index]
        return id and children[id]
      end
    end)
    local action = ActionArgs()
    displayPrivate.PrepareSecretActionOptions(group, action)
    DumpTree(lines, action.args)
    local onlyPlain = { id = "Group2", regionType = "group", controlledChildren = { "PlainChild" } }
    local untouched = ActionArgs()
    displayPrivate.PrepareSecretActionOptions(onlyPlain, untouched)
    lines[#lines + 1] = "plain children: glow_type.values=" .. Fmt(untouched.args.start_glow_type.values)
      .. " padding=" .. Fmt(untouched.args.start_glow_padding.name) .. " notice=" .. Fmt(untouched.args.secretSoundNotice)
    local notEnabled = ActionData({ id = "Plain", triggers = { { trigger = { type = "aura2", unit = "player" } } } })
    local plainActions = ActionArgs()
    displayPrivate.PrepareSecretActionOptions(notEnabled, plainActions)
    lines[#lines + 1] = "not enabled: notice=" .. Fmt(plainActions.args.secretSoundNotice)
      .. " message.disabled=" .. Fmt(plainActions.args.start_do_message.disabled)
  end)

  ---------------------------------------------------------------------------------------------------------------
  -- SecretAuraTriggerOptions
  ---------------------------------------------------------------------------------------------------------------
  local triggerPrivate
  local buildOptions
  do
    local realRegister = WeakAuras.RegisterTriggerSystemOptions
    WeakAuras.RegisterTriggerSystemOptions = function(types, builder)
      buildOptions = builder
      Case("trigger.registration", function(registered) registered[#registered + 1] = Fmt(types) end)
    end
    triggerPrivate = {
      commonOptions = { AddCommonTriggerOptions = function(_, _, _, flag) Counter("AddCommonTriggerOptions" .. tostring(flag))() end },
      AuraEditor = { AddOptions = Counter("AuraEditor.AddOptions") },
      AddTriggerMetaFunctions = Counter("AddTriggerMetaFunctions"),
      SaveAuraTrigger = Counter("SaveAuraTrigger"),
      QueueOptionsRefresh = Counter("QueueOptionsRefresh"),
      CreateAuraSpellOptions = function(options, data, triggernum, size, _, _, prefix, baseOrder, flag, storage, label, _, _, enabled, onChanged)
        local trigger = data.triggers[triggernum].trigger
        for index = 1, size do
          local hiddenUnlessEntered = function()
            return not (enabled() and (index == 1 or trigger[storage] and trigger[storage][index - 1]))
          end
          options[prefix .. "icon" .. index] = {
            type = "execute", width = 0.2, order = baseOrder + index / 100 + 0.0002, hidden = hiddenUnlessEntered,
            control = "WeakAurasIcon", name = "",
          }
          options[prefix .. index] = {
            type = "input", name = label, order = baseOrder + index / 100 + 0.0003,
            hidden = function()
              return not (enabled() and (index == 1 or trigger[storage] and trigger[storage][index - 1]))
            end,
            get = function() return trigger[storage] and trigger[storage][index] or "" end,
            set = function(_, value)
              trigger[storage] = trigger[storage] or {}
              trigger[storage][index] = value
              if onChanged then onChanged() end
            end,
          }
        end
      end,
    }
    local loaded, loadMessage = test.Loader.RunFile(optionsDirectory .. "SecretAuraTriggerOptions.lua", "WeakAurasOptions", triggerPrivate)
    triggerPrivate.Private = private
    WeakAuras.RegisterTriggerSystemOptions = realRegister
    assert(loaded, tostring(loadMessage))
    assert(buildOptions, "secretAura options not registered")
  end

  local function TriggerOptions(trigger, triggernum)
    local data = { id = "Trigger", triggers = {} }
    triggernum = triggernum or 1
    data.triggers[triggernum] = { trigger = trigger }
    local result = buildOptions(data, triggernum)
    local keys = {}
    for key in pairs(result) do keys[#keys + 1] = key end
    return data, result["trigger." .. triggernum .. ".secretAura"], keys
  end

  local function TriggerProbe(lines, label, fn)
    Probe(lines, label, fn)
  end

  Case("trigger.new", function(lines)
    local trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL" }
    local data, options, keys = TriggerOptions(trigger)
    lines[#lines + 1] = "result keys: " .. Fmt(keys) .. " | " .. TakeCounts()
    DumpTree(lines, options)
    TriggerProbe(lines, "unit.get", function() return options.unit.get() end)
    TriggerProbe(lines, "unit.set raid", function() options.unit.set(nil, "raid") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "debuffType.get", function() return options.debuffType.get() end)
    TriggerProbe(lines, "debuffType.set Dispel", function() options.debuffType.set(nil, "Dispel") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "debuffType.get after", function() return options.debuffType.get() end)
    TriggerProbe(lines, "debuffType.values after", function() return options.debuffType.values() end)
    trigger.sortMethod = "UnitFrameDebuff"
    TriggerProbe(lines, "debuffType.set Buff", function() options.debuffType.set(nil, "Buff") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "debuffType.set invalid", function() options.debuffType.set(nil, "Nope") end)
    TriggerProbe(lines, "debuffType.set HARMFUL", function() options.debuffType.set(nil, "HARMFUL") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "useRankSpellIDs.get", function() return options.useRankSpellIDs.get() end)
    TriggerProbe(lines, "useSpellIDs.set true", function() options.useSpellIDs.set(nil, true) end)
    TriggerProbe(lines, "spellid1.validate abc", function() return options.spellid1.validate(nil, "abc") end)
    TriggerProbe(lines, "spellid1.validate empty", function() return options.spellid1.validate(nil, "") end)
    TriggerProbe(lines, "spellid1.validate -5", function() return options.spellid1.validate(nil, "-5") end)
    TriggerProbe(lines, "spellid1.validate 123", function() return options.spellid1.validate(nil, "123") end)
    TriggerProbe(lines, "spellid1.set 123", function() options.spellid1.set(nil, "123") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "rankspellid1.set 5", function() options.rankspellid1.set(nil, "5") end)
    TriggerProbe(lines, "ignorespellid1.set 6", function() options.ignorespellid1.set(nil, "6") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "help.name", function() return options.help.name() end)
  end)

  Case("trigger.group", function(lines)
    local trigger = {
      type = "secretAura", unit = "group", debuffType = "HARMFUL", processedAuraType = "Debuff",
      useUnitNames = true, unitNames = { "Alpha Beta", "Gamma Delta" }, useUnitRoles = true, unitRoles = { TANK = true },
      use_includePets = true, includePets = "PetsOnly", ignoreDead = true,
      auraRankSpellIDs = { "8050" }, auraspellids = { "1", "2" }, secretUseSpellIDs = true,
      excludedAuraSpellIDs = { "9" }, includeDispelTypes = { Magic = true },
      nativeFilters = { RAID = true },
    }
    local data, options = TriggerOptions(trigger, 2)
    DumpTree(lines, options)
    TriggerProbe(lines, "unitNames.get", function() return options.unitNames.get() end)
    TriggerProbe(lines, "unitNames.set", function() options.unitNames.set(nil, " Foo Bar , ,Baz Qux,") end)
    lines[#lines + 1] = "unitNames: " .. Fmt(trigger.unitNames)
    TriggerProbe(lines, "unitRoles.get TANK", function() return options.unitRoles.get(nil, "TANK") end)
    TriggerProbe(lines, "unitRoles.get HEALER", function() return options.unitRoles.get(nil, "HEALER") end)
    TriggerProbe(lines, "unitRoles.set HEALER", function() options.unitRoles.set(nil, "HEALER", true) end)
    TriggerProbe(lines, "unitRoles.set TANK false", function() options.unitRoles.set(nil, "TANK", false) end)
    lines[#lines + 1] = "unitRoles: " .. Fmt(trigger.unitRoles)
    TriggerProbe(lines, "useIncludePets.set false", function() options.useIncludePets.set(nil, false) end)
    lines[#lines + 1] = "pets: " .. Fmt(trigger.use_includePets) .. " " .. Fmt(trigger.includePets)
    trigger.use_includePets = nil
    trigger.includePets = nil
    TriggerProbe(lines, "useIncludePets.set true", function() options.useIncludePets.set(nil, true) end)
    lines[#lines + 1] = "pets: " .. Fmt(trigger.use_includePets) .. " " .. Fmt(trigger.includePets)
    TriggerProbe(lines, "includePets.get", function() return options.includePets.get() end)
    TriggerProbe(lines, "ignoreDead.set false", function() options.ignoreDead.set(nil, false) end)
    TriggerProbe(lines, "ignoreDisconnected.set true", function() options.ignoreDisconnected.set(nil, true) end)
    lines[#lines + 1] = "ignore: " .. Fmt(trigger.ignoreDead) .. " " .. Fmt(trigger.ignoreDisconnected)
    TriggerProbe(lines, "includeDispelTypes.get Magic", function() return options.includeDispelTypes.get(nil, "Magic") end)
    TriggerProbe(lines, "includeDispelTypes.get Curse", function() return options.includeDispelTypes.get(nil, "Curse") end)
    TriggerProbe(lines, "includeDispelTypes.set Curse", function() options.includeDispelTypes.set(nil, "Curse", true) end)
    TriggerProbe(lines, "includeDispelTypes.set Magic false", function() options.includeDispelTypes.set(nil, "Magic", false) end)
    TriggerProbe(lines, "includeDispelTypes.set Curse false", function() options.includeDispelTypes.set(nil, "Curse", false) end)
    lines[#lines + 1] = "includeDispelTypes: " .. Fmt(trigger.includeDispelTypes)
    TriggerProbe(lines, "excludeDispelTypes.set Poison", function() options.excludeDispelTypes.set(nil, "Poison", true) end)
    lines[#lines + 1] = "excludeDispelTypes: " .. Fmt(trigger.excludeDispelTypes)
    TriggerProbe(lines, "spellid2.get", function() return options.spellid2.get() end)
    TriggerProbe(lines, "spellid3.set empty", function() options.spellid3.set(nil, "") end)
    TriggerProbe(lines, "rankspellid1.get", function() return options.rankspellid1.get() end)
    TriggerProbe(lines, "ignorespellid1.get", function() return options.ignorespellid1.get() end)
    TriggerProbe(lines, "rankCoverage.name", function() return options.rankCoverage.name() end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    lines[#lines + 1] = "data: " .. Fmt(#data.triggers)
  end)

  Case("trigger.nameplate", function(lines)
    local trigger = {
      type = "secretAura", unit = "nameplate", debuffType = "HELPFUL", processedAuraType = "Buff",
      includeNameplateOnly = true, nativeFilters = { PLAYER = true },
    }
    local data, options = TriggerOptions(trigger)
    DumpTree(lines, options)
    local filterKeys = {}
    for key, option in pairs(options) do
      if option.type == "toggle" and option.width == "full" and option.name and key ~= "includeNameplateOnly" then
        filterKeys[#filterKeys + 1] = key
      end
    end
    table.sort(filterKeys)
    lines[#lines + 1] = "tri-state keys: " .. Fmt(filterKeys)
    TriggerProbe(lines, "includeNameplateOnly.get", function() return options.includeNameplateOnly.get() end)
    TriggerProbe(lines, "includeNameplateOnly.set", function() options.includeNameplateOnly.set(nil, false) end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "nativePLAYER.get", function() return options.nativePLAYER.get() end)
    TriggerProbe(lines, "nativePLAYER.name", function() return options.nativePLAYER.name() end)
    TriggerProbe(lines, "nativePLAYER.set false", function() options.nativePLAYER.set(nil, false) end)
    lines[#lines + 1] = "nativeFilters: " .. Fmt(trigger.nativeFilters)
    TriggerProbe(lines, "nativePLAYER.get false", function() return options.nativePLAYER.get() end)
    TriggerProbe(lines, "nativePLAYER.name false", function() return options.nativePLAYER.name() end)
    TriggerProbe(lines, "nativePLAYER.set false again", function() options.nativePLAYER.set(nil, false) end)
    lines[#lines + 1] = "nativeFilters: " .. Fmt(trigger.nativeFilters)
    TriggerProbe(lines, "nativePLAYER.set true", function() options.nativePLAYER.set(nil, true) end)
    lines[#lines + 1] = "nativeFilters: " .. Fmt(trigger.nativeFilters)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.get", function() return options.isFromPlayerOrPlayerPet.get() end)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.set true", function() options.isFromPlayerOrPlayerPet.set(nil, true) end)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.get true", function() return options.isFromPlayerOrPlayerPet.get() end)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.name true", function() return options.isFromPlayerOrPlayerPet.name() end)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.set false", function() options.isFromPlayerOrPlayerPet.set(nil, false) end)
    TriggerProbe(lines, "isFromPlayerOrPlayerPet.name false", function() return options.isFromPlayerOrPlayerPet.name() end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    trigger.unit = "member"
    trigger.specificUnit = "party1"
    TriggerProbe(lines, "specificUnit.get", function() return options.specificUnit.get() end)
    TriggerProbe(lines, "specificUnit.validate bad", function() return options.specificUnit.validate(nil, "nobody") end)
    TriggerProbe(lines, "specificUnit.validate party2", function() return options.specificUnit.validate(nil, "party2") end)
    TriggerProbe(lines, "specificUnit.set", function() options.specificUnit.set(nil, "  Raid5 ") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    lines[#lines + 1] = "member: specificUnit.hidden=" .. Evaluate(options.specificUnit.hidden)
      .. " nameplateOnly.hidden=" .. Evaluate(options.includeNameplateOnly.hidden)
  end)

  ---------------------------------------------------------------------------------------------------------------
  -- CooldownViewerOptions
  ---------------------------------------------------------------------------------------------------------------
  local viewerPrivate = {
    CreateAuraSpellOptions = triggerPrivate.CreateAuraSpellOptions,
  }
  local loaded, loadMessage = test.Loader.RunFile(optionsDirectory .. "CooldownViewerOptions.lua", "WeakAurasOptions", viewerPrivate)
  viewerPrivate.Private = private
  assert(loaded, tostring(loadMessage))

  Replace(private, "CDMCatalog", function()
    return {
      [101] = { known = true, category = 2 },
      [102] = { known = false, category = 0 },
      [103] = { known = true, category = 1 },
      [104] = { known = true, category = 0 },
    }
  end)
  Replace(private, "CDMEntryMatches", function() return true end)
  -- identity.spellID differs from info.spellID (as with linked or override spells): the shown ID must be info.spellID.
  Replace(private, "CDMIdentity", function(id)
    return { spellID = id * 10 + 5, name = "Entry " .. id, icon = 5000 + id, itemID = id * 100 }
  end)
  Replace(private, "CDMCategoryName", function(category) return "Category" .. tostring(category) end)
  Replace(private, "CDMRequestItemData", Counter("CDMRequestItemData"))
  Replace(private, "ResolveCDMSpell", function() return { 104 } end)
  C_CooldownViewer = C_CooldownViewer or {}
  Replace(C_CooldownViewer, "GetCooldownViewerCooldownInfo", function(id)
    if id == 104 then return { spellID = 1040, equipSlot = 13 } end
    return { spellID = id * 10 }
  end)
  local spellNames = { [1010] = "Alpha", [1020] = "Beta", [1030] = "Beta", [1040] = "Gamma" }
  Replace(C_Spell, "GetSpellInfo", function(id) return { name = spellNames[id] or ("Spell" .. id), iconID = 9000 + id } end)
  Replace(C_Spell, "GetSpellSubtext", function(id)
    if id == 1020 then return "Rank 1" end
    if id == 1030 then return "Rank 2" end
    return ""
  end)
  Replace(C_Item, "GetItemNameByID", function(id) return id == 4242 and "Test Item" or nil end)
  Replace(C_Item, "GetItemIconByID", function(id) return id == 4242 and 133 or nil end)

  local function ViewerOptions(trigger, existing)
    local data = { id = "Viewer", triggers = { { trigger = trigger } } }
    local options = existing or {}
    viewerPrivate.AddCooldownViewerOptions(options, data, 1)
    return data, options
  end

  Case("viewer.buff.new", function(lines)
    local trigger = { type = "cdm", event = "Blizzard CDM Buff" }
    local data, options = ViewerOptions(trigger, { cdmSpellsOld = { type = "toggle" }, cdmShowGCDOld = { type = "toggle" }, unrelated = { type = "toggle" } })
    DumpTree(lines, options)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger) .. " | " .. TakeCounts()
    TriggerProbe(lines, "buffShow.get", function() return options.cdmPicker_buffShow.get() end)
    TriggerProbe(lines, "buffShow.set missing", function() options.cdmPicker_buffShow.set(nil, "missing") end)
    TriggerProbe(lines, "requireTarget.get", function() return options.cdmPicker_requireTarget.get() end)
    TriggerProbe(lines, "requireTarget.set", function() options.cdmPicker_requireTarget.set(nil, true) end)
    TriggerProbe(lines, "remainingEnabled.set", function() options.cdmPicker_remainingEnabled.set(nil, true) end)
    TriggerProbe(lines, "remainingOperator.get", function() return options.cdmPicker_remainingOperator.get() end)
    TriggerProbe(lines, "remainingOperator.set", function() options.cdmPicker_remainingOperator.set(nil, ">=") end)
    TriggerProbe(lines, "remainingSeconds.get", function() return options.cdmPicker_remainingSeconds.get() end)
    TriggerProbe(lines, "remainingSeconds.set 5.5", function() options.cdmPicker_remainingSeconds.set(nil, "5.5") end)
    TriggerProbe(lines, "remainingSeconds.get after", function() return options.cdmPicker_remainingSeconds.get() end)
    TriggerProbe(lines, "remainingSeconds.validate -1", function() return options.cdmPicker_remainingSeconds.validate(nil, "-1") end)
    TriggerProbe(lines, "remainingSeconds.validate abc", function() return options.cdmPicker_remainingSeconds.validate(nil, "abc") end)
    TriggerProbe(lines, "remainingSeconds.validate 0", function() return options.cdmPicker_remainingSeconds.validate(nil, "0") end)
    TriggerProbe(lines, "stacksCount.get", function() return options.cdmPicker_stacksCount.get() end)
    TriggerProbe(lines, "stacksCount.validate 1.5", function() return options.cdmPicker_stacksCount.validate(nil, "1.5") end)
    TriggerProbe(lines, "stacksCount.validate 3", function() return options.cdmPicker_stacksCount.validate(nil, "3") end)
    TriggerProbe(lines, "stacksOperator.set", function() options.cdmPicker_stacksOperator.set(nil, "==") end)
    TriggerProbe(lines, "stacksCount.set", function() options.cdmPicker_stacksCount.set(nil, "4") end)
    TriggerProbe(lines, "elapsedEnabled.set", function() options.cdmPicker_elapsedEnabled.set(nil, true) end)
    TriggerProbe(lines, "totalEnabled.set", function() options.cdmPicker_totalEnabled.set(nil, true) end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    lines[#lines + 1] = "hidden after enabling: remainingOperator=" .. Evaluate(options.cdmPicker_remainingOperator.hidden)
      .. " remainingSeconds=" .. Evaluate(options.cdmPicker_remainingSeconds.hidden)
      .. " elapsedSeconds=" .. Evaluate(options.cdmPicker_elapsedSeconds.hidden)
    TriggerProbe(lines, "nameToggle.set", function() options.cdmPicker_nameToggle.set(nil, true) end)
    TriggerProbe(lines, "name1.set", function() options.cdmPicker_name1.set(nil, "Some Aura") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
    TriggerProbe(lines, "entry101.get", function() return options.cdmPicker_entry101.get() end)
    TriggerProbe(lines, "entry101.set true", function() options.cdmPicker_entry101.set(nil, true) end)
    lines[#lines + 1] = "cdmSpells: " .. Fmt(trigger.cdmSpells)
    TriggerProbe(lines, "entry101.get after", function() return options.cdmPicker_entry101.get() end)
    TriggerProbe(lines, "entry101.set false", function() options.cdmPicker_entry101.set(nil, false) end)
    lines[#lines + 1] = "cdmSpells: " .. Fmt(trigger.cdmSpells)
    TriggerProbe(lines, "refresh.func", function() options.cdmPicker_refresh.func() end)
    TriggerProbe(lines, "search.set", function() options.cdmPicker_search.set(nil, "entry 1") end)
    TriggerProbe(lines, "available.set", function() options.cdmPicker_available.set(nil, true) end)
    TriggerProbe(lines, "maxRank.set", function() options.cdmPicker_maxRank.set(nil, true) end)
    local rebuilt = select(2, ViewerOptions(trigger))
    local keys = {}
    for key in pairs(rebuilt) do
      if key:match("^cdmPicker_entry") then keys[#keys + 1] = key end
    end
    table.sort(keys)
    lines[#lines + 1] = "rebuilt with view state: entries=" .. Fmt(keys) .. " search=" .. Evaluate(rebuilt.cdmPicker_search.get)
      .. " available=" .. Evaluate(rebuilt.cdmPicker_available.get) .. " maxRank=" .. Evaluate(rebuilt.cdmPicker_maxRank.get)
  end)

  Case("viewer.cooldown.existing", function(lines)
    local trigger = {
      type = "cdm", event = "Blizzard Cooldown Manager", cdmShow = "usable", cdmTrack = "charges",
      cdmUseNames = true, cdmNames = { "Fireball", "Frostbolt" }, cdmUseExactIDs = true, cdmExactIDs = { "133" },
      use_cdmShowGCD = true, cdmHideGCDText = false, cdmSpells = { multi = { [102] = true, ["103"] = true } },
      cdmUseRemaining = true, cdmRemainingOperator = "<=", cdmRemainingTime = 3,
    }
    local data, options = ViewerOptions(trigger)
    DumpTree(lines, options)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger) .. " | " .. TakeCounts()
    TriggerProbe(lines, "show.get", function() return options.cdmPicker_show.get() end)
    TriggerProbe(lines, "show.set ready", function() options.cdmPicker_show.set(nil, "ready") end)
    TriggerProbe(lines, "track.get", function() return options.cdmPicker_track.get() end)
    TriggerProbe(lines, "track.set cooldown", function() options.cdmPicker_track.set(nil, "cooldown") end)
    TriggerProbe(lines, "includeGCD.get", function() return options.cdmPicker_includeGCD.get() end)
    TriggerProbe(lines, "hideGCDText.get", function() return options.cdmPicker_hideGCDText.get() end)
    TriggerProbe(lines, "hideGCDText.set true", function() options.cdmPicker_hideGCDText.set(nil, true) end)
    TriggerProbe(lines, "ignoreSpellKnown.set", function() options.cdmPicker_ignoreSpellKnown.set(nil, true) end)
    lines[#lines + 1] = "extra before: hidden=" .. Evaluate(options.cdmPicker_track.hidden) .. " name=" .. Evaluate(options.cdmPicker_extra.name)
      .. " image=" .. Evaluate(options.cdmPicker_extra.image)
    TriggerProbe(lines, "extra.func", function() options.cdmPicker_extra.func() end)
    lines[#lines + 1] = "extra after: hidden=" .. Evaluate(options.cdmPicker_track.hidden) .. " name=" .. Evaluate(options.cdmPicker_extra.name)
      .. " image=" .. Evaluate(options.cdmPicker_extra.image)
    TriggerProbe(lines, "nameToggle.get", function() return options.cdmPicker_nameToggle.get() end)
    TriggerProbe(lines, "nameToggle.set false", function() options.cdmPicker_nameToggle.set(nil, false) end)
    TriggerProbe(lines, "name1.get", function() return options.cdmPicker_name1.get() end)
    TriggerProbe(lines, "name3.set", function() options.cdmPicker_name3.set(nil, "Pyroblast") end)
    TriggerProbe(lines, "spellid1.validate", function() return options.cdmPicker_spellid1.validate(nil, "x"), options.cdmPicker_spellid1.validate(nil, "5"), options.cdmPicker_spellid1.validate(nil, "") end)
    TriggerProbe(lines, "spellid2.set", function() options.cdmPicker_spellid2.set(nil, "134") end)
    TriggerProbe(lines, "entry102.get", function() return options.cdmPicker_entry102.get() end)
    TriggerProbe(lines, "entry103.get", function() return options.cdmPicker_entry103.get() end)
    TriggerProbe(lines, "entry103.set false", function() options.cdmPicker_entry103.set(nil, false) end)
    lines[#lines + 1] = "cdmSpells: " .. Fmt(trigger.cdmSpells)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)
  end)

  Case("viewer.item.migration", function(lines)
    test.Environment.Advance(1)
    TakeCounts()
    local trigger = {
      type = "cdm", event = "Blizzard Cooldown Manager", cdmSpell = "Legacy", cdmUseItemIDs = true, cdmItemIDs = { "4242" },
    }
    local data, options = ViewerOptions(trigger)
    lines[#lines + 1] = "trigger after build: " .. Fmt(trigger) .. " | " .. TakeCounts()
    test.Environment.Advance(1)
    lines[#lines + 1] = "after timer: " .. TakeCounts()
    DumpTree(lines, options)
    TriggerProbe(lines, "itemid1.get", function() return options.cdmPicker_itemid1.get() end)
    TriggerProbe(lines, "itemid2.get", function() return options.cdmPicker_itemid2.get() end)
    TriggerProbe(lines, "itemid1.validate", function() return options.cdmPicker_itemid1.validate(nil, "x"), options.cdmPicker_itemid1.validate(nil, "4242") end)
    TriggerProbe(lines, "itemid2.set", function() options.cdmPicker_itemid2.set(nil, "77") end)
    lines[#lines + 1] = "trigger: " .. Fmt(trigger)

    local exact = { type = "cdm", event = "Blizzard Cooldown Manager", cdmSpell = " 55 ", cdmExact = true, cdmSelection = "spell" }
    ViewerOptions(exact)
    lines[#lines + 1] = "exact legacy: " .. Fmt(exact)
    local utility = { type = "cdm", event = "Blizzard CDM Utility" }
    ViewerOptions(utility)
    lines[#lines + 1] = "utility: " .. Fmt(utility)
  end)

  ---------------------------------------------------------------------------------------------------------------
  -- Comparison
  ---------------------------------------------------------------------------------------------------------------
  for index = #saved, 1, -1 do
    local entry = saved[index]
    entry[1][entry[2]] = entry[3]
  end

  local outputPath = os.getenv("OPTIONS_CONTRACT_OUT")
  if outputPath then
    local file = assert(io.open(outputPath, "wb"))
    file:write("  local EXPECTED = {\n")
    for _, name in ipairs(order) do
      file:write(string.format("    [%q] = [==[\n%s\n]==],\n", name, cases[name]))
    end
    file:write("  }\n")
    file:close()
    return
  end

  -- EXPECTED-BEGIN
  local EXPECTED = {
    ["display.settings.new"] = [==[
__collapsed = true
__order = 8
__title = "Aura (Modern) Settings"
growth | disabled=fn:false get=<fn> name="Aura growth direction" order=3 set=<fn> type="select" values={"CENTER_HORIZONTAL"="Centered Horizontal","CENTER_VERTICAL"="Centered Vertical","DOWN"="Down","LEFT"="Left","RIGHT"="Right","UP"="Up"} width=1.300000000
maxIcons | desc="Maximum auras per unit. Drag up to 40, or type a larger number." disabled=fn:false get=<fn> min=1 name="Maximum auras" order=5 set=<fn> softMax=40 step=1 type="range" width=1.300000000
singleNotice | fontSize="small" hidden=fn:true name=fn:"The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match." order=2 type="description" width="full"
sortMethod | desc="Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras." disabled=fn:false get=<fn> name="Sort by" order=6 set=<fn> sorting={1="Default",2="ExpirationOnly",3="Expiration",4="NameOnly",5="Name",6="ImportantOnly",7="BigDefensive",8="UnitFrameDebuff",9="AuraInstanceIDOnly"} type="select" values={"AuraInstanceIDOnly"="Aura instance ID","BigDefensive"="Big defensives","Default"="Blizzard default","Expiration"="Remaining time (Blizzard priority)","ExpirationOnly"="Remaining time","ImportantOnly"="Importance only","Name"="Name (Blizzard priority)","NameOnly"="Name","UnitFrameDebuff"="Unit-frame debuffs"} width=1.300000000
sortReverse | desc="Reverse the selected order. For Remaining time, later expirations and permanent auras come first." disabled=fn:false get=<fn> name="Reverse Sort" order=7 set=<fn> type="toggle" width=1.300000000
spacing | disabled=fn:false get=<fn> max=40 min=0 name="Aura spacing" order=4 set=<fn> step=1 type="range" width=1.300000000
status | hidden=fn:false name=fn:"This client does not support the selected Blizzard aura filters." order=1 type="description" width="full"
textHeight | desc="Space reserved for each aura's text. Set its width in Font Flags." get=<fn> hidden=fn:true min=4 name="Text Area Height" order=8 set=<fn> softMax=300 step=1 type="range" width=1.300000000
growth.get -> "RIGHT" | calls: none
spacing.get -> 6 | calls: none
maxIcons.get -> 10 | calls: none
sortMethod.get -> "Default" | calls: none
sortReverse.get -> false | calls: none
growth.set ->  | calls: Add=1
after growth.set: {"growth"="UP"} | calls: ClearAndUpdateOptions=1 FillOptions=1
spacing.set ->  | calls: Add=1
after spacing.set: {"growth"="UP","spacing"=12} | calls: none
maxIcons.set ->  | calls: Add=1
sortMethod.set UnitFrameDebuff ->  | calls: Add=1
after sortMethod.set: {"auraspellids"={1="1"},"debuffType"="HELPFUL","processedAuraType"="Debuff","sortMethod"="UnitFrameDebuff","type"="secretAura","unit"="player"} | calls: ClearAndUpdateOptions=1 FillOptions=1
sortMethod.get after -> "UnitFrameDebuff" | calls: none
sortReverse.set ->  | calls: Add=1
after sortReverse.set: true | calls: ClearAndUpdateOptions=1 FillOptions=1
sortReverse.get after -> true | calls: none
textHeight.get -> 21.600000000 | calls: none
textHeight.set ->  | calls: Add=1
data: {"growth"="UP","maxIcons"=25,"spacing"=12,"textHeight"=30}
]==],
    ["display.settings.existing"] = [==[
__collapsed = true
__order = 8
__title = "Aura (Modern) Settings"
growth | disabled=fn:false get=<fn> name="Aura growth direction" order=3 set=<fn> type="select" values={"CENTER_HORIZONTAL"="Centered Horizontal","CENTER_VERTICAL"="Centered Vertical","DOWN"="Down","LEFT"="Left","RIGHT"="Right","UP"="Up"} width=1.300000000
maxIcons | desc="Maximum auras per unit. Drag up to 40, or type a larger number." disabled=fn:false get=<fn> min=1 name="Maximum auras" order=5 set=<fn> softMax=40 step=1 type="range" width=1.300000000
singleNotice | fontSize="small" hidden=fn:true name=fn:"The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match." order=2 type="description" width="full"
sortMethod | desc="Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras." disabled=fn:false get=<fn> name="Sort by" order=6 set=<fn> sorting={1="Default",2="ExpirationOnly",3="Expiration",4="NameOnly",5="Name",6="ImportantOnly",7="BigDefensive",8="UnitFrameDebuff",9="AuraInstanceIDOnly"} type="select" values={"AuraInstanceIDOnly"="Aura instance ID","BigDefensive"="Big defensives","Default"="Blizzard default","Expiration"="Remaining time (Blizzard priority)","ExpirationOnly"="Remaining time","ImportantOnly"="Importance only","Name"="Name (Blizzard priority)","NameOnly"="Name","UnitFrameDebuff"="Unit-frame debuffs"} width=1.300000000
sortReverse | desc="Reverse the selected order. For Remaining time, later expirations and permanent auras come first." disabled=fn:false get=<fn> name="Reverse Sort" order=7 set=<fn> type="toggle" width=1.300000000
spacing | disabled=fn:false get=<fn> max=40 min=0 name="Aura spacing" order=4 set=<fn> step=1 type="range" width=1.300000000
status | hidden=fn:false name=fn:"This client does not support the selected Blizzard aura filters." order=1 type="description" width="full"
textHeight | desc="Space reserved for each aura's text. Set its width in Font Flags." get=<fn> hidden=fn:false min=4 name="Text Area Height" order=8 set=<fn> softMax=300 step=1 type="range" width=1.300000000
growth.get -> "CENTER_HORIZONTAL" | calls: none
spacing.get -> 3 | calls: none
maxIcons.get -> 5 | calls: none
sortMethod.get -> "Expiration" | calls: none
sortReverse.get -> true | calls: none
textHeight.get -> 33 | calls: none
sortMethod.set Name ->  | calls: Add=1
trigger: {"auraspellids"={1="1"},"debuffType"="HELPFUL","sortMethod"="Name","sortReverse"=true,"type"="secretAura","unit"="player"} | calls: ClearAndUpdateOptions=1 FillOptions=1
textHeight.get default -> 21.600000000 | calls: none
no trigger sortMethod.get -> "Default",false | calls: none
]==],
    ["display.prepare.icon"] = [==[
[icon]
__order = 1
__title = "Icon"
iconInset | desc="Aura (Modern) does not apply this effect." disabled=true name="Icon Inset" order=3 type="range"
iconSource | name="Icon Source" order=1 type="select" values={-1="Automatic",0="Manual"}
notAnOption = "text"
secretSwipeColor | get=<fn> hasAlpha=true hidden=fn:false name="Swipe Color" order=11.900000000 set=<fn> type="color" width=1.300000000
secretSwitchToClassic | confirm=true confirmText="The aura stops updating in combat once the game hides it. Switch to classic mode?" desc="Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options." func=<fn> name="Switch to classic mode" order=13.900000000 type="execute" width=1.300000000
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=12.900000000 type="description" width=2.600000000
spark | desc="Aura (Modern) does not apply this effect." disabled=true name="Spark" order=4 type="toggle"
useTooltip | desc="The Aura (Modern) display ignores the mouse, so it shows no tooltip." disabled=true name="Tooltip on Mouseover" order=2 type="toggle"
[position]
__order = 9
__title = "Position"
anchor_point | name="Point" order=1 type="select" values={"TOPLEFT"="x","a.b"="y"}
useTooltip | name="Tooltip" order=2 type="toggle"
[secretAura]
__collapsed = true
__order = 8
__title = "Aura (Modern) Settings"
growth | disabled=fn:false get=<fn> name="Aura growth direction" order=3 set=<fn> type="select" values={"CENTER_HORIZONTAL"="Centered Horizontal","CENTER_VERTICAL"="Centered Vertical","DOWN"="Down","LEFT"="Left","RIGHT"="Right","UP"="Up"} width=1.300000000
maxIcons | desc="Maximum auras per unit. Drag up to 40, or type a larger number." disabled=fn:false get=<fn> min=1 name="Maximum auras" order=5 set=<fn> softMax=40 step=1 type="range" width=1.300000000
singleNotice | fontSize="small" hidden=fn:true name=fn:"The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match." order=2 type="description" width="full"
sortMethod | desc="Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras." disabled=fn:false get=<fn> name="Sort by" order=6 set=<fn> sorting={1="Default",2="ExpirationOnly",3="Expiration",4="NameOnly",5="Name",6="ImportantOnly",7="BigDefensive",8="UnitFrameDebuff",9="AuraInstanceIDOnly"} type="select" values={"AuraInstanceIDOnly"="Aura instance ID","BigDefensive"="Big defensives","Default"="Blizzard default","Expiration"="Remaining time (Blizzard priority)","ExpirationOnly"="Remaining time","ImportantOnly"="Importance only","Name"="Name (Blizzard priority)","NameOnly"="Name","UnitFrameDebuff"="Unit-frame debuffs"} width=1.300000000
sortReverse | desc="Reverse the selected order. For Remaining time, later expirations and permanent auras come first." disabled=fn:false get=<fn> name="Reverse Sort" order=7 set=<fn> type="toggle" width=1.300000000
spacing | disabled=fn:false get=<fn> max=40 min=0 name="Aura spacing" order=4 set=<fn> step=1 type="range" width=1.300000000
status | hidden=fn:false name=fn:"This client does not support the selected Blizzard aura filters." order=1 type="description" width="full"
textHeight | desc="Space reserved for each aura's text. Set its width in Font Flags." get=<fn> hidden=fn:true min=4 name="Text Area Height" order=8 set=<fn> softMax=300 step=1 type="range" width=1.300000000
[sub.1.subtext]
__order = 2
__title = "Text"
anchor_area | name="Area" order=12 type="select" values={"ALL"="Whole Area"}
anchor_point | name="Point" order=13 type="select" values={"CENTER"="Center","TOPLEFT"="Top Left"}
automaticWidth | desc="The game's own aura layout uses a fixed text area." name="Width" order=10 type="select" values={"Fixed"="Fixed"}
secretSwitchToClassic | confirm=true confirmText="The aura stops updating in combat once the game hides it. Switch to classic mode?" desc="Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options." func=<fn> name="Switch to classic mode" order=15 type="execute" width=1.300000000
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=14 type="description" width=2.600000000
text_customTextUpdate | desc="The game writes this text itself: custom code cannot run on it." disabled=true name="Update" order=11 type="select"
text_text | desc="Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported." name="Text" order=1 type="input"
text_text_format_footer | name="Footer" order=7 type="toggle"
text_text_format_header | name="Header" order=8 type="description"
text_text_format_n_title | name="Action" order=9 type="execute"
text_text_format_p_format | name="Format" order=3 type="select" values={"timed"="Time Format"}
text_text_format_p_time_format | name="Time" order=4 type="select" values={-1="Blizzard Default",-2="Seconds",0="Minutes and seconds"}
text_text_format_p_time_precision | name="Precision" order=5 type="select"
text_text_format_s_big_number | desc="The game writes this value itself: only the time format applies." disabled=true name="Big" order=6 type="toggle"
text_text_pChoose | name="Choose" order=2 type="toggle"
[sub.2.subborder]
__order = 3
__title = "Border"
border_offset | name="Offset" order=2 type="range"
border_ppscale | desc="Keep border thickness and offset in screen pixels, regardless of UI or parent scale. Use a size of 1 for a one-pixel border." disabled=false name="Pixel Scale" order=1 type="toggle"
secretSwitchToClassic | confirm=true confirmText="The aura stops updating in combat once the game hides it. Switch to classic mode?" desc="Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options." func=<fn> name="Switch to classic mode" order=5 type="execute" width=1.300000000
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=4 type="description" width=2.600000000
slanted | desc="The game fills the bar or the swipe itself and hides the progress from addons: this effect needs to read the progress." disabled=true name="Slanted" order=3 type="toggle"
[sub.3.subglow]
__order = 4
__title = "Glow"
glowColor | name="Color" order=3.500000000 type="color"
glowStartAnim | desc="The game starts this glow itself, without the start animation." disabled=true name="Start Anim" order=2 type="toggle"
glowType | name="Glow Type" order=1 type="select" values={"ACShine"="Autocast Shine","Pixel"="Pixel Glow","Proc"="Proc Glow","buttonOverlay"="Action Button Glow"}
secretSwitchToClassic | confirm=true confirmText="The aura stops updating in combat once the game hides it. Switch to classic mode?" desc="Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options." func=<fn> name="Switch to classic mode" order=5.500000000 type="execute" width=1.300000000
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=4.500000000 type="description" width=2.600000000
[sub.4.subtext]
__order = 5
__title = "Detached Detached Candidate"
text_text | desc="Hardcoded text. Use Conditions from other triggers to show, hide or change this message." name="Text" order=1 type="input"
text_text_format_s_big_number | name="Big" order=3 type="toggle"
text_text_pChoose | disabled=true name="Choose" order=2 type="toggle"
swipe.get default -> 0,0,0,0.800000000 | calls: none
swipe.set ->  | calls: Add=1
data: {"swipeColor"={1=0.100000000,2=0.200000000,3=0.300000000,4=0.400000000}}
swipe.get saved -> 0.100000000,0.200000000,0.300000000,0.400000000 | calls: none
switchToClassic.func ->  | calls: Add=1 QueueOptionsRefresh=1 UpdateThumbnail=1
trigger: {"auraTracking"="readable","auraspellids"={1="1"},"debuffType"="HELPFUL","type"="aura2","unit"="player","useExactSpellId"=true} enabled=nil
]==],
    ["display.prepare.group-flow-and-disabled"] = [==[
flow: secretAura=nil progressOptions=nil icon.swipe=true
[icon]
__order = 1
__title = "Icon"
iconInset | desc="Aura (Modern) does not apply this effect." disabled=true name="Icon Inset" order=3 type="range"
iconSource | name="Icon Source" order=1 type="select" values={-1="Automatic",0="Manual"}
notAnOption = "text"
secretSwipeColor | get=<fn> hasAlpha=true hidden=fn:false name="Swipe Color" order=11.900000000 set=<fn> type="color" width=1.300000000
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=12.900000000 type="description" width=2.600000000
spark | desc="Aura (Modern) does not apply this effect." disabled=true name="Spark" order=4 type="toggle"
useTooltip | desc="The Aura (Modern) display ignores the mouse, so it shows no tooltip." disabled=true name="Tooltip on Mouseover" order=2 type="toggle"
[position]
__order = 9
__title = "Position"
anchor_point | name="Point" order=1 type="select" values={"TOPLEFT"="x","a.b"="y"}
useTooltip | name="Tooltip" order=2 type="toggle"
[sub.1.subtext]
__order = 2
__title = "Text"
anchor_area | name="Area" order=12 type="select" values={"ALL"="Whole Area"}
anchor_point | name="Point" order=13 type="select" values={"CENTER"="Center","TOPLEFT"="Top Left"}
automaticWidth | desc="The game's own aura layout uses a fixed text area." name="Width" order=10 type="select" values={"Fixed"="Fixed"}
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=14 type="description" width=2.600000000
text_customTextUpdate | desc="The game writes this text itself: custom code cannot run on it." disabled=true name="Update" order=11 type="select"
text_text | desc="Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported." name="Text" order=1 type="input"
text_text_format_footer | name="Footer" order=7 type="toggle"
text_text_format_header | name="Header" order=8 type="description"
text_text_format_n_title | name="Action" order=9 type="execute"
text_text_format_p_format | name="Format" order=3 type="select" values={"timed"="Time Format"}
text_text_format_p_time_format | name="Time" order=4 type="select" values={-1="Blizzard Default",-2="Seconds",0="Minutes and seconds"}
text_text_format_p_time_precision | name="Precision" order=5 type="select"
text_text_format_s_big_number | desc="The game writes this value itself: only the time format applies." disabled=true name="Big" order=6 type="toggle"
text_text_pChoose | name="Choose" order=2 type="toggle"
[sub.2.subborder]
__order = 3
__title = "Border"
border_offset | name="Offset" order=2 type="range"
border_ppscale | desc="Keep border thickness and offset in screen pixels, regardless of UI or parent scale. Use a size of 1 for a one-pixel border." disabled=false name="Pixel Scale" order=1 type="toggle"
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=4 type="description" width=2.600000000
slanted | desc="The game fills the bar or the swipe itself and hides the progress from addons: this effect needs to read the progress." disabled=true name="Slanted" order=3 type="toggle"
[sub.3.subglow]
__order = 4
__title = "Glow"
glowColor | name="Color" order=3.500000000 type="color"
glowStartAnim | desc="The game starts this glow itself, without the start animation." disabled=true name="Start Anim" order=2 type="toggle"
glowType | name="Glow Type" order=1 type="select" values={"ACShine"="Autocast Shine","Pixel"="Pixel Glow","Proc"="Proc Glow","buttonOverlay"="Action Button Glow"}
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=4.500000000 type="description" width=2.600000000
[sub.4.subtext]
__order = 5
__title = "Detached Candidate"
secretUnavailableNote | fontSize="medium" name="|cff999999Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why.|r" order=4 type="description" width=2.600000000
text_text | desc="Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported." name="Text" order=1 type="input"
text_text_format_s_big_number | desc="The game writes this value itself: only the time format applies." disabled=true name="Big" order=3 type="toggle"
text_text_pChoose | name="Choose" order=2 type="toggle"
not enabled leaves groups untouched: true
aurabar anchor_area: {"ALL"="Whole Area","bar"="Bar","icon"="Icon"} swipe=false
]==],
    ["display.action.new"] = [==[
finish_do_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true name="Custom" order=34 type="toggle"
finish_do_message | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Chat Message" order=31 type="toggle"
finish_do_sound | desc="Play when one of the trigger's exact spell IDs is removed. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds." name="Play Sound" order=32 type="toggle"
finish_header | name="On Hide" order=30 type="header"
finish_sound | name="Sound" order=33 sorting={1=" custom",2=" Fojji",3=554003,4=1} type="select" values={" Fojji"="FojjiCore recorded voice"," custom"=" Custom",1="None",554003="Lich King Apocalypse"}
init_do_custom | name="Init" order=40 type="toggle"
other | name="Other" order=41 type="toggle"
secretSoundNotice | name="|cffff2020Blizzard-controlled aura display: only supported actions are available.|r" order=0 type="description" width="full"
start_choose_glow_frame | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true hidden=true name="Frame" order=13 type="toggle"
start_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true name="Code" order=10 type="input"
start_do_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:false name="Custom" order=9 type="toggle"
start_do_glow | desc="Use Unit Frames anchoring in Display. The frame glows while any aura matches your filters and stops automatically. Exact Spell IDs are not required." disabled=fn:true get=<fn> name="Glow Anchored Unit Frame" order=11 set=<fn> type="toggle"
start_do_message | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Chat Message" order=2 type="toggle"
start_do_sound | desc="Play when one of the trigger's exact spell IDs is added. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds." name="Play Sound" order=4 type="toggle"
start_do_sound_fade | hidden=true name="Fade" order=7 type="toggle"
start_glow_XOffset | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="X" order=18 set=<fn> type="range"
start_glow_YOffset | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="Y" order=19 set=<fn> type="range"
start_glow_action | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true hidden=true name="Action" order=12 type="select"
start_glow_color | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="Color" order=16 set=<fn> type="color"
start_glow_duration | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="Animation Duration" order=17 set=<fn> type="range"
start_glow_padding | control="WeakAurasSpinBox" desc="Extra space around the unit frame. Zero follows its edges." disabled=fn:true get=<fn> hidden=fn:true max=40 min=0 name="Padding" order=10.865000000 set=<fn> step=1 type="range" width=1.300000000
start_glow_type | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="Type" order=15 set=<fn> type="select" values={"Proc"="Proc Glow","buttonOverlay"="Pulse Glow"}
start_header | name="On Show" order=1 type="header"
start_message_type | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Message Type" order=3 type="select"
start_sound | name="Sound" order=5 sorting={1=" custom",2=" Fojji",3=554003,4=1} type="select" values={" Fojji"="FojjiCore recorded voice"," custom"=" Custom",1="None",554003="Lich King Apocalypse"}
start_sound_channel | name="Channel" order=5.500000000 type="select"
start_stop_sound | hidden=true name="Stop sound" order=6 type="execute"
start_stop_sound_fade | hidden=true name="Fade time" order=8 type="range"
start_use_glow_color | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:true name="Use color" order=14 set=<fn> type="toggle"
do_glow.get -> false | calls: none
glow_type.get -> "Proc" | calls: none
glow_color.get -> 1,0.820000000,0,1 | calls: none
glow_duration.get -> 1 | calls: none
glow_padding.get -> 0 | calls: none
do_glow.set true ->  | calls: Add=1
data: {"unitGlow"=true} do_glow=nil
glow_type.set buttonOverlay ->  | calls: Add=1
glow_type.get after -> "buttonOverlay" | calls: none
glow_color.set ->  | calls: Add=1
glow_color.get after -> 0.100000000,0.200000000,0.300000000,0.400000000 | calls: none
use_glow_color.set false ->  | calls: Add=1
glow_duration.set ->  | calls: Add=1
glow_XOffset.set ->  | calls: Add=1
glow_YOffset.set ->  | calls: Add=1
glow_padding.set ->  | calls: Add=1
data: {"unitGlow"=true,"unitGlowColor"={1=0.100000000,2=0.200000000,3=0.300000000,4=0.400000000},"unitGlowDuration"=2,"unitGlowPadding"=7,"unitGlowType"="pulse","unitGlowX"=4,"unitGlowY"=-4,"unitUseGlowColor"=false}
unitframe: glow_type.hidden=false disabled=false color.disabled=true do_glow.disabled=false
custom disabled: false do_custom=fn:false
]==],
    ["display.action.existing"] = [==[
finish_do_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true name="Custom" order=34 type="toggle"
finish_do_message | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Chat Message" order=31 type="toggle"
finish_do_sound | desc="Play when one of the trigger's exact spell IDs is removed. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds." name="Play Sound" order=32 type="toggle"
finish_header | name="On Hide" order=30 type="header"
finish_sound | name="Sound" order=33 sorting={1=" custom",2=" Fojji",3=554003,4=1} type="select" values={" Fojji"="FojjiCore recorded voice"," custom"=" Custom",1="None",554003="Lich King Apocalypse"}
init_do_custom | name="Init" order=40 type="toggle"
other | name="Other" order=41 type="toggle"
secretSoundNotice | name="|cffff2020Blizzard-controlled aura display: only supported actions are available.|r" order=0 type="description" width="full"
start_choose_glow_frame | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true hidden=true name="Frame" order=13 type="toggle"
start_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true name="Code" order=10 type="input"
start_do_custom | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true name="Custom" order=9 type="toggle"
start_do_glow | desc="Use Unit Frames anchoring in Display. The frame glows while any aura matches your filters and stops automatically. Exact Spell IDs are not required." disabled=fn:false get=<fn> name="Glow Anchored Unit Frame" order=11 set=<fn> type="toggle"
start_do_message | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Chat Message" order=2 type="toggle"
start_do_sound | desc="Play when one of the trigger's exact spell IDs is added. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds." name="Play Sound" order=4 type="toggle"
start_do_sound_fade | hidden=true name="Fade" order=7 type="toggle"
start_glow_XOffset | desc="Style the glow on the anchored unit frame." disabled=fn:false get=<fn> hidden=fn:false name="X" order=18 set=<fn> type="range"
start_glow_YOffset | desc="Style the glow on the anchored unit frame." disabled=fn:false get=<fn> hidden=fn:false name="Y" order=19 set=<fn> type="range"
start_glow_action | desc="Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not." disabled=fn:true hidden=true name="Action" order=12 type="select"
start_glow_color | desc="Style the glow on the anchored unit frame." disabled=fn:true get=<fn> hidden=fn:false name="Color" order=16 set=<fn> type="color"
start_glow_duration | desc="Style the glow on the anchored unit frame." disabled=fn:false get=<fn> hidden=fn:false name="Animation Duration" order=17 set=<fn> type="range"
start_glow_padding | control="WeakAurasSpinBox" desc="Extra space around the unit frame. Zero follows its edges." disabled=fn:false get=<fn> hidden=fn:false max=40 min=0 name="Padding" order=10.865000000 set=<fn> step=1 type="range" width=1.300000000
start_glow_type | desc="Style the glow on the anchored unit frame." disabled=fn:false get=<fn> hidden=fn:false name="Type" order=15 set=<fn> type="select" values={"Proc"="Proc Glow","buttonOverlay"="Pulse Glow"}
start_header | name="On Show" order=1 type="header"
start_message_type | desc="Blizzard controls aura visibility. Use a condition from another trigger to send chat messages." disabled=true name="Message Type" order=3 type="select"
start_sound | name="Sound" order=5 sorting={1=" custom",2=" Fojji",3=554003,4=1} type="select" values={" Fojji"="FojjiCore recorded voice"," custom"=" Custom",1="None",554003="Lich King Apocalypse"}
start_sound_channel | name="Channel" order=5.500000000 type="select"
start_stop_sound | hidden=true name="Stop sound" order=6 type="execute"
start_stop_sound_fade | hidden=true name="Fade time" order=8 type="range"
start_use_glow_color | desc="Style the glow on the anchored unit frame." disabled=fn:false get=<fn> hidden=fn:false name="Use color" order=14 set=<fn> type="toggle"
do_glow.get -> true | calls: none
glow_type.get -> "buttonOverlay" | calls: none
glow_color.get -> 0.500000000,0.500000000,0.500000000,1 | calls: none
use_glow_color.get -> false | calls: none
glow_duration.get -> 3 | calls: none
glow_XOffset.get -> 2 | calls: none
glow_YOffset.get -> 5 | calls: none
glow_padding.get -> 4 | calls: none
do_glow.set false ->  | calls: Add=1
data: {"unitGlow"=false,"unitGlowColor"={1=0.500000000,2=0.500000000,3=0.500000000,4=1},"unitGlowDuration"=3,"unitGlowPadding"=4,"unitGlowType"="pulse","unitGlowX"=2,"unitGlowY"=5,"unitUseGlowColor"=false} do_glow=nil
]==],
    ["display.action.group"] = [==[
finish_do_custom | name="Custom" order=34 type="toggle"
finish_do_message | name="Chat Message" order=31 type="toggle"
finish_do_sound | name="Play Sound" order=32 type="toggle"
finish_header | name="On Hide" order=30 type="header"
finish_sound | name="Sound" order=33 type="select"
init_do_custom | name="Init" order=40 type="toggle"
other | name="Other" order=41 type="toggle"
start_choose_glow_frame | name="Frame" order=13 type="toggle"
start_custom | name="Code" order=10 type="input"
start_do_custom | name="Custom" order=9 type="toggle"
start_do_glow | name="Glow" order=11 type="toggle"
start_do_message | name="Chat Message" order=2 type="toggle"
start_do_sound | name="Play Sound" order=4 type="toggle"
start_do_sound_fade | name="Fade" order=7 type="toggle"
start_glow_XOffset | name="X" order=18 type="range"
start_glow_YOffset | name="Y" order=19 type="range"
start_glow_action | name="Action" order=12 type="select"
start_glow_color | name="Color" order=16 type="color"
start_glow_duration | name="Duration" order=17 type="range"
start_glow_padding | name="Old padding" order=20 type="range"
start_glow_type | name="Type" order=15 type="select" values={"Proc"="Proc Glow","buttonOverlay"="Pulse Glow"}
start_header | name="On Show" order=1 type="header"
start_message_type | name="Message Type" order=3 type="select"
start_sound | name="Sound" order=5 type="select" values={"x"="x"}
start_sound_channel | name="Channel" order=5.500000000 type="select"
start_stop_sound | name="Stop sound" order=6 type="execute"
start_stop_sound_fade | name="Fade time" order=8 type="range"
start_use_glow_color | name="Use color" order=14 type="toggle"
plain children: glow_type.values={"Pixel"="Pixel","Proc"="Proc"} padding="Old padding" notice=nil
not enabled: notice=nil message.disabled=nil
]==],
    ["trigger.registration"] = [==[
{1="secretAura"}
]==],
    ["trigger.new"] = [==[
result keys: {1="trigger.1.secretAura"} | calls: AddCommonTriggerOptionstrue=1 AddTriggerMetaFunctions=1 AuraEditor.AddOptions=1
alwaysActive | fontSize="medium" name="|cffffffffNote: Trigger Always Active|r" order=1.950000000 type="description" width="full"
auraTypeLabel | disabled=true get=<fn> name="Aura Type" order=4 type="toggle" width=1.300000000
canApplyAura | desc="Auras Blizzard says your character can apply." get=<fn> hidden=fn:false name=fn:"Can Apply Aura" order=12 set=<fn> type="toggle" width="full"
debuffType | desc="Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden." get=<fn> name="Aura Type" order=4.010000000 set=<fn> sorting=fn:{1="HELPFUL",2="HARMFUL",3="Buff",4="Debuff",5="Dispel"} type="select" values=fn:{"Buff"="Blizzard: Buff","Debuff"="Blizzard: Debuff","Dispel"="Blizzard: Dispellable","HARMFUL"="Debuff","HELPFUL"="Buff"} width=1.300000000
excludeDispelTypes | get=<fn> name="Exclude dispel types" order=25 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
filtersHeader | name="Aura Filters" order=10 type="header"
help | fontSize="small" name=fn:"|cffff2020Won't work:|r Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text." order=2 type="description" width="full"
ignoreDead | desc="Hide this member's auras while it is dead or a ghost." get=<fn> hidden=fn:true name="Ignore Dead" order=4.410000000 set=<fn> type="toggle" width=1.300000000
ignoreDisconnected | desc="Hide this member's auras while it is offline." get=<fn> hidden=fn:true name="Ignore Disconnected" order=4.420000000 set=<fn> type="toggle" width=1.300000000
ignorespellid1 | get=<fn> hidden=fn:true name="Ignored Spell ID or Name" order=7.010300000 set=<fn> type="input" validate=<fn>
ignorespellidDisabledSpace | hidden=fn:false name="" order=7.001000000 type="description" width=1.500000000
ignorespellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=7.010200000 type="execute" width=0.200000000
includeDispelTypes | get=<fn> name="Include dispel types" order=24 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
includeNameplateOnly | desc="Also allows auras normally returned only for nameplate displays. Other filters still apply." get=<fn> hidden=fn:true name="Include nameplate-only auras" order=21 set=<fn> type="toggle" width="full"
includePets | get=<fn> hidden=fn:true name="Include Pets" order=4.600000000 set=<fn> type="select" values={"PetsOnly"="Pets only","PlayersAndPets"="Players and Pets"} width=1.300000000
isBossAura | desc="Auras Blizzard identifies as boss auras." get=<fn> hidden=fn:true name=fn:"Is Boss Aura" order=14 set=<fn> type="toggle" width="full"
isBossOrRoleAura | desc="Auras Blizzard identifies as boss auras or marks as relevant to your role." get=<fn> hidden=fn:true name=fn:"Boss or role aura" order=16 set=<fn> type="toggle" width="full"
isFromPlayerOrPlayerPet | desc="Auras cast by any player or player pet, not only yours. For your own auras, use Own Only." get=<fn> hidden=fn:false name=fn:"Cast by a Player" order=11.010000000 set=<fn> type="toggle" width=1.300000000
isPriorityAura | desc="Debuffs Blizzard marks as high priority." get=<fn> hidden=fn:true name=fn:"Priority debuff" order=17 set=<fn> type="toggle" width="full"
isRoleAura | desc="Auras Blizzard marks as relevant to your role." get=<fn> hidden=fn:true name=fn:"Role aura" order=15 set=<fn> type="toggle" width="full"
isStealable | desc="Buffs that can be stolen with abilities such as Spellsteal." get=<fn> hidden=fn:false name=fn:"Is Stealable" order=13 set=<fn> type="toggle" width="full"
nameplateShowAll | desc="Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:true name=fn:"Marked for all nameplates" order=18 set=<fn> type="toggle" width="full"
nameplateShowPersonal | desc="Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:true name=fn:"Marked for personal debuff display" order=19 set=<fn> type="toggle" width="full"
nativeBIG_DEFENSIVE | desc="Auras Blizzard classifies as big defensives." get=<fn> hidden=fn:false name=fn:"Big defensive" order=20.400000000 set=<fn> type="toggle" width="full"
nativeCANCELABLE | desc="Auras that the player can cancel." get=<fn> hidden=fn:false name=fn:"Cancelable" order=20.150000000 set=<fn> type="toggle" width="full"
nativeCROWD_CONTROL | desc="Auras with a crowd-control effect, such as a stun or fear." get=<fn> hidden=fn:true name=fn:"Crowd control" order=20.250000000 set=<fn> type="toggle" width="full"
nativeDISPELLABLE | desc="Dispellable regardless of your or your raid's current abilities." get=<fn> hidden=fn:false name=fn:"Dispellable" order=20.500000000 set=<fn> type="toggle" width="full"
nativeEXTERNAL_DEFENSIVE | desc="Auras Blizzard classifies as external defensives." get=<fn> hidden=fn:false name=fn:"External defensive" order=20.200000000 set=<fn> type="toggle" width="full"
nativeIMPORTANT | desc="Blizzard's important-aura flag, including non-stealable enemy buffs shown on nameplates." get=<fn> hidden=fn:false name=fn:"Important aura" order=20.450000000 set=<fn> type="toggle" width="full"
nativePLAYER | desc="Auras cast by you, your pet or your vehicle." get=<fn> hidden=fn:false name=fn:"Own Only" order=11 set=<fn> type="toggle" width=1.300000000
nativeRAID | desc="Buffs you can apply, or debuffs you can dispel." get=<fn> hidden=fn:false name=fn:"Can apply / dispel" order=20.100000000 set=<fn> type="toggle" width="full"
nativeRAID_IN_COMBAT | desc="Auras flagged by Blizzard for raid-frame display in combat." get=<fn> hidden=fn:false name=fn:"Shown on raid frames in combat" order=20.300000000 set=<fn> type="toggle" width="full"
nativeRAID_PLAYER_DISPELLABLE | desc="Includes helpful enrages on enemies." get=<fn> hidden=fn:false name=fn:"Dispellable by someone in your raid" order=20.350000000 set=<fn> type="toggle" width="full"
rankCoverage | fontSize="small" hidden=fn:true name=fn:"Other ranks could not be found for: . Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)." order=5.900000000 type="description" width="full"
rankspellid1 | get=<fn> hidden=fn:true name="Spell ID or Name" order=4.960300000 set=<fn> type="input" validate=<fn>
rankspellidDisabledSpace | hidden=fn:false name="" order=4.951000000 type="description" width=1.500000000
rankspellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=4.960200000 type="execute" width=0.200000000
specificUnit | desc="party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5." get=<fn> hidden=fn:true name="Specific Unit" order=3.030000000 set=<fn> type="input" validate=<fn> width=1.300000000
specificUnitSpace | hidden=fn:true name="" order=3.020000000 type="description" width=1.300000000
spellSelectionHeader | name="Spell Selection Filters" order=4.700000000 type="header"
spellid1 | get=<fn> hidden=fn:true name="Exact Spell ID or Name" order=6.010300000 set=<fn> type="input" validate=<fn>
spellidDisabledSpace | hidden=fn:false name="" order=6.001000000 type="description" width=1.500000000
spellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=6.010200000 type="execute" width=0.200000000
unit | get=<fn> name="Unit" order=3.010000000 set=<fn> type="select" values={"arena"="Arena","boss"="Boss","focus"="Focus","focustarget"="Target of Focus","group"="Smart Group","member"="Specific Unit","mouseover"="Mouseover","nameplate"="Nameplate","party"="Party","pet"="Pet","player"="Player","raid"="Raid","target"="Target","targettarget"="Target of Target"} width=1.300000000
unitLabel | disabled=true get=<fn> name="Unit" order=3 type="toggle" width=1.300000000
unitNames | desc="Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match." get=<fn> hidden=fn:true name="Player Names" order=4.200000000 set=<fn> type="input" width="full"
unitRoles | desc="Uses Blizzard's assigned group role. Members without a role assigned match Unassigned." get=<fn> hidden=fn:true name="Group Roles" order=4.400000000 set=<fn> type="multiselect" values={"DAMAGER"="Damage","HEALER"="Healer","NONE"="Unassigned","TANK"="Tank"} width="full"
useExcludedSpellIDs | get=<fn> name="Ignored Exact Spell ID(s)" order=7 set=<fn> type="toggle" width=1.100000000
useIncludePets | desc="Also track the pets of the group members." get=<fn> hidden=fn:true name="Include Pets" order=4.500000000 set=<fn> type="toggle" width=1.300000000
useRankSpellIDs | desc="Enter a Spell ID or a spell name to track all ranks of that spell. A name is replaced by the IDs of all its ranks." get=<fn> name="Spell ID(s) (All Ranks)" order=4.950000000 set=<fn> type="toggle" width=1.100000000
useSpellIDs | get=<fn> name="Exact Spell ID(s)" order=6 set=<fn> type="toggle" width=1.100000000
useUnitNames | desc="Only track these group members. This also limits which units can play configured aura sounds." get=<fn> hidden=fn:true name="Player Name(s)" order=4.100000000 set=<fn> type="toggle" width=1.300000000
useUnitRoles | desc="Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled." get=<fn> hidden=fn:true name="Group Role" order=4.300000000 set=<fn> type="toggle" width=1.300000000
unit.get -> "player" | calls: none
unit.set raid ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HELPFUL","type"="secretAura","unit"="raid"}
debuffType.get -> "HELPFUL" | calls: none
debuffType.set Dispel ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HARMFUL","processedAuraType"="Dispel","type"="secretAura","unit"="raid"}
debuffType.get after -> "Dispel" | calls: none
debuffType.values after -> {"Buff"="Blizzard: Buff","Debuff"="Blizzard: Debuff","Dispel"="Blizzard: Dispellable","HARMFUL"="Debuff","HELPFUL"="Buff"} | calls: none
debuffType.set Buff ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HELPFUL","processedAuraType"="Buff","sortMethod"="Default","type"="secretAura","unit"="raid"}
debuffType.set invalid ->  | calls: none
debuffType.set HARMFUL ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HARMFUL","processedAuraType"="any","sortMethod"="Default","type"="secretAura","unit"="raid"}
useRankSpellIDs.get -> false | calls: none
useSpellIDs.set true ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
spellid1.validate abc -> true | calls: none
spellid1.validate empty -> true | calls: none
spellid1.validate -5 -> "Enter a positive whole-number Spell ID." | calls: none
spellid1.validate 123 -> true | calls: none
spellid1.set 123 ->  | calls: none
trigger: {"auraspellids"={1="123"},"debuffType"="HARMFUL","processedAuraType"="any","secretUseSpellIDs"=true,"sortMethod"="Default","type"="secretAura","unit"="raid"}
rankspellid1.set 5 ->  | calls: none
ignorespellid1.set 6 ->  | calls: none
trigger: {"auraRankSpellIDs"={1="5"},"auraspellids"={1="123"},"debuffType"="HARMFUL","excludedAuraSpellIDs"={1="6"},"processedAuraType"="any","secretUseSpellIDs"=true,"sortMethod"="Default","type"="secretAura","unit"="raid"}
help.name -> "|cffff2020Won't work:|r Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text." | calls: none
]==],
    ["trigger.group"] = [==[
alwaysActive | fontSize="medium" name="|cffffffffNote: Trigger Always Active|r" order=1.950000000 type="description" width="full"
auraTypeLabel | disabled=true get=<fn> name="Aura Type" order=4 type="toggle" width=1.300000000
canApplyAura | desc="Auras Blizzard says your character can apply." get=<fn> hidden=fn:false name=fn:"Can Apply Aura" order=12 set=<fn> type="toggle" width="full"
debuffType | desc="Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden." get=<fn> name="Aura Type" order=4.010000000 set=<fn> sorting=fn:{1="HELPFUL",2="HARMFUL",3="Buff",4="Debuff",5="Dispel"} type="select" values=fn:{"Buff"="Blizzard: Buff","Debuff"="Blizzard: Debuff","Dispel"="Blizzard: Dispellable","HARMFUL"="Debuff","HELPFUL"="Buff"} width=1.300000000
excludeDispelTypes | get=<fn> name="Exclude dispel types" order=25 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
filtersHeader | name="Aura Filters" order=10 type="header"
help | fontSize="small" name=fn:"|cffff2020Won't work:|r Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text." order=2 type="description" width="full"
ignoreDead | desc="Hide this member's auras while it is dead or a ghost." get=<fn> hidden=fn:false name="Ignore Dead" order=4.410000000 set=<fn> type="toggle" width=1.300000000
ignoreDisconnected | desc="Hide this member's auras while it is offline." get=<fn> hidden=fn:false name="Ignore Disconnected" order=4.420000000 set=<fn> type="toggle" width=1.300000000
ignorespellid1 | get=<fn> hidden=fn:false name="Ignored Spell ID or Name" order=7.010300000 set=<fn> type="input" validate=<fn>
ignorespellid2 | get=<fn> hidden=fn:false name="Ignored Spell ID or Name" order=7.020300000 set=<fn> type="input" validate=<fn>
ignorespellidDisabledSpace | hidden=fn:true name="" order=7.001000000 type="description" width=1.500000000
ignorespellidicon1 | control="WeakAurasIcon" hidden=fn:false name="" order=7.010200000 type="execute" width=0.200000000
ignorespellidicon2 | control="WeakAurasIcon" hidden=fn:false name="" order=7.020200000 type="execute" width=0.200000000
includeDispelTypes | get=<fn> name="Include dispel types" order=24 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
includeNameplateOnly | desc="Also allows auras normally returned only for nameplate displays. Other filters still apply." get=<fn> hidden=fn:true name="Include nameplate-only auras" order=21 set=<fn> type="toggle" width="full"
includePets | get=<fn> hidden=fn:false name="Include Pets" order=4.600000000 set=<fn> type="select" values={"PetsOnly"="Pets only","PlayersAndPets"="Players and Pets"} width=1.300000000
isBossAura | desc="Auras Blizzard identifies as boss auras." get=<fn> hidden=fn:false name=fn:"Is Boss Aura" order=14 set=<fn> type="toggle" width="full"
isBossOrRoleAura | desc="Auras Blizzard identifies as boss auras or marks as relevant to your role." get=<fn> hidden=fn:false name=fn:"Boss or role aura" order=16 set=<fn> type="toggle" width="full"
isFromPlayerOrPlayerPet | desc="Auras cast by any player or player pet, not only yours. For your own auras, use Own Only." get=<fn> hidden=fn:false name=fn:"Cast by a Player" order=11.010000000 set=<fn> type="toggle" width=1.300000000
isPriorityAura | desc="Debuffs Blizzard marks as high priority." get=<fn> hidden=fn:false name=fn:"Priority debuff" order=17 set=<fn> type="toggle" width="full"
isRoleAura | desc="Auras Blizzard marks as relevant to your role." get=<fn> hidden=fn:false name=fn:"Role aura" order=15 set=<fn> type="toggle" width="full"
isStealable | desc="Buffs that can be stolen with abilities such as Spellsteal." get=<fn> hidden=fn:true name=fn:"Is Stealable" order=13 set=<fn> type="toggle" width="full"
nameplateShowAll | desc="Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:true name=fn:"Marked for all nameplates" order=18 set=<fn> type="toggle" width="full"
nameplateShowPersonal | desc="Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:true name=fn:"Marked for personal debuff display" order=19 set=<fn> type="toggle" width="full"
nativeBIG_DEFENSIVE | desc="Auras Blizzard classifies as big defensives." get=<fn> hidden=fn:true name=fn:"Big defensive" order=20.400000000 set=<fn> type="toggle" width="full"
nativeCANCELABLE | desc="Auras that the player can cancel." get=<fn> hidden=fn:true name=fn:"Cancelable" order=20.150000000 set=<fn> type="toggle" width="full"
nativeCROWD_CONTROL | desc="Auras with a crowd-control effect, such as a stun or fear." get=<fn> hidden=fn:false name=fn:"Crowd control" order=20.250000000 set=<fn> type="toggle" width="full"
nativeDISPELLABLE | desc="Dispellable regardless of your or your raid's current abilities." get=<fn> hidden=fn:false name=fn:"Dispellable" order=20.500000000 set=<fn> type="toggle" width="full"
nativeEXTERNAL_DEFENSIVE | desc="Auras Blizzard classifies as external defensives." get=<fn> hidden=fn:true name=fn:"External defensive" order=20.200000000 set=<fn> type="toggle" width="full"
nativeIMPORTANT | desc="Blizzard's important-aura flag, including non-stealable enemy buffs shown on nameplates." get=<fn> hidden=fn:true name=fn:"Important aura" order=20.450000000 set=<fn> type="toggle" width="full"
nativePLAYER | desc="Auras cast by you, your pet or your vehicle." get=<fn> hidden=fn:false name=fn:"Own Only" order=11 set=<fn> type="toggle" width=1.300000000
nativeRAID | desc="Buffs you can apply, or debuffs you can dispel." get=<fn> hidden=fn:false name=fn:"|cFF00FF00Can apply / dispel|r" order=20.100000000 set=<fn> type="toggle" width="full"
nativeRAID_IN_COMBAT | desc="Auras flagged by Blizzard for raid-frame display in combat." get=<fn> hidden=fn:false name=fn:"Shown on raid frames in combat" order=20.300000000 set=<fn> type="toggle" width="full"
nativeRAID_PLAYER_DISPELLABLE | desc="Includes helpful enrages on enemies." get=<fn> hidden=fn:false name=fn:"Dispellable by someone in your raid" order=20.350000000 set=<fn> type="toggle" width="full"
rankCoverage | fontSize="small" hidden=fn:true name=fn:"Other ranks could not be found for: . Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)." order=5.900000000 type="description" width="full"
rankspellid1 | get=<fn> hidden=fn:true name="Spell ID or Name" order=4.960300000 set=<fn> type="input" validate=<fn>
rankspellid2 | get=<fn> hidden=fn:true name="Spell ID or Name" order=4.970300000 set=<fn> type="input" validate=<fn>
rankspellidDisabledSpace | hidden=fn:false name="" order=4.951000000 type="description" width=1.500000000
rankspellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=4.960200000 type="execute" width=0.200000000
rankspellidicon2 | control="WeakAurasIcon" hidden=fn:true name="" order=4.970200000 type="execute" width=0.200000000
specificUnit | desc="party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5." get=<fn> hidden=fn:true name="Specific Unit" order=3.030000000 set=<fn> type="input" validate=<fn> width=1.300000000
specificUnitSpace | hidden=fn:true name="" order=3.020000000 type="description" width=1.300000000
spellSelectionHeader | name="Spell Selection Filters" order=4.700000000 type="header"
spellid1 | get=<fn> hidden=fn:false name="Exact Spell ID or Name" order=6.010300000 set=<fn> type="input" validate=<fn>
spellid2 | get=<fn> hidden=fn:false name="Exact Spell ID or Name" order=6.020300000 set=<fn> type="input" validate=<fn>
spellid3 | get=<fn> hidden=fn:false name="Exact Spell ID or Name" order=6.030300000 set=<fn> type="input" validate=<fn>
spellidDisabledSpace | hidden=fn:true name="" order=6.001000000 type="description" width=1.500000000
spellidicon1 | control="WeakAurasIcon" hidden=fn:false name="" order=6.010200000 type="execute" width=0.200000000
spellidicon2 | control="WeakAurasIcon" hidden=fn:false name="" order=6.020200000 type="execute" width=0.200000000
spellidicon3 | control="WeakAurasIcon" hidden=fn:false name="" order=6.030200000 type="execute" width=0.200000000
unit | get=<fn> name="Unit" order=3.010000000 set=<fn> type="select" values={"arena"="Arena","boss"="Boss","focus"="Focus","focustarget"="Target of Focus","group"="Smart Group","member"="Specific Unit","mouseover"="Mouseover","nameplate"="Nameplate","party"="Party","pet"="Pet","player"="Player","raid"="Raid","target"="Target","targettarget"="Target of Target"} width=1.300000000
unitLabel | disabled=true get=<fn> name="Unit" order=3 type="toggle" width=1.300000000
unitNames | desc="Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match." get=<fn> hidden=fn:false name="Player Names" order=4.200000000 set=<fn> type="input" width="full"
unitRoles | desc="Uses Blizzard's assigned group role. Members without a role assigned match Unassigned." get=<fn> hidden=fn:false name="Group Roles" order=4.400000000 set=<fn> type="multiselect" values={"DAMAGER"="Damage","HEALER"="Healer","NONE"="Unassigned","TANK"="Tank"} width="full"
useExcludedSpellIDs | get=<fn> name="Ignored Exact Spell ID(s)" order=7 set=<fn> type="toggle" width=1.100000000
useIncludePets | desc="Also track the pets of the group members." get=<fn> hidden=fn:false name="Include Pets" order=4.500000000 set=<fn> type="toggle" width=1.300000000
useRankSpellIDs | desc="Enter a Spell ID or a spell name to track all ranks of that spell. A name is replaced by the IDs of all its ranks." get=<fn> name="Spell ID(s) (All Ranks)" order=4.950000000 set=<fn> type="toggle" width=1.100000000
useSpellIDs | get=<fn> name="Exact Spell ID(s)" order=6 set=<fn> type="toggle" width=1.100000000
useUnitNames | desc="Only track these group members. This also limits which units can play configured aura sounds." get=<fn> hidden=fn:false name="Player Name(s)" order=4.100000000 set=<fn> type="toggle" width=1.300000000
useUnitRoles | desc="Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled." get=<fn> hidden=fn:false name="Group Role" order=4.300000000 set=<fn> type="toggle" width=1.300000000
unitNames.get -> "Alpha Beta, Gamma Delta" | calls: none
unitNames.set ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
unitNames: {1="Foo Bar",2="Baz Qux"}
unitRoles.get TANK -> true | calls: none
unitRoles.get HEALER -> false | calls: none
unitRoles.set HEALER ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
unitRoles.set TANK false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
unitRoles: {"HEALER"=true}
useIncludePets.set false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
pets: false "PetsOnly"
useIncludePets.set true ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
pets: true "PlayersAndPets"
includePets.get -> "PlayersAndPets" | calls: none
ignoreDead.set false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
ignoreDisconnected.set true ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
ignore: nil true
includeDispelTypes.get Magic -> true | calls: none
includeDispelTypes.get Curse -> false | calls: none
includeDispelTypes.set Curse ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
includeDispelTypes.set Magic false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
includeDispelTypes.set Curse false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
includeDispelTypes: nil
excludeDispelTypes.set Poison ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
excludeDispelTypes: {"Poison"=true}
spellid2.get -> "2" | calls: none
spellid3.set empty ->  | calls: none
rankspellid1.get -> "8050" | calls: none
ignorespellid1.get -> "9" | calls: none
rankCoverage.name -> "Other ranks could not be found for: . Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)." | calls: none
trigger: {"auraRankSpellIDs"={1="8050"},"auraspellids"={1="1",2="2",3=""},"debuffType"="HARMFUL","excludeDispelTypes"={"Poison"=true},"excludedAuraSpellIDs"={1="9"},"ignoreDisconnected"=true,"includePets"="PlayersAndPets","nativeFilters"={"RAID"=true},"processedAuraType"="Debuff","secretUseSpellIDs"=true,"type"="secretAura","unit"="group","unitNames"={1="Foo Bar",2="Baz Qux"},"unitRoles"={"HEALER"=true},"useUnitNames"=true,"useUnitRoles"=true,"use_includePets"=true}
data: 0
]==],
    ["trigger.nameplate"] = [==[
alwaysActive | fontSize="medium" name="|cffffffffNote: Trigger Always Active|r" order=1.950000000 type="description" width="full"
auraTypeLabel | disabled=true get=<fn> name="Aura Type" order=4 type="toggle" width=1.300000000
canApplyAura | desc="Auras Blizzard says your character can apply." get=<fn> hidden=fn:false name=fn:"Can Apply Aura" order=12 set=<fn> type="toggle" width="full"
debuffType | desc="Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden." get=<fn> name="Aura Type" order=4.010000000 set=<fn> sorting=fn:{1="HELPFUL",2="HARMFUL",3="Buff",4="Debuff",5="Dispel"} type="select" values=fn:{"Buff"="Blizzard: Buff","Debuff"="Blizzard: Debuff","Dispel"="Blizzard: Dispellable","HARMFUL"="Debuff","HELPFUL"="Buff"} width=1.300000000
excludeDispelTypes | get=<fn> name="Exclude dispel types" order=25 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
filtersHeader | name="Aura Filters" order=10 type="header"
help | fontSize="small" name=fn:"|cffff2020Won't work:|r Select an Aura (Modern) trigger as the progress source of an Icon, Progress Bar, Progress Texture or Text." order=2 type="description" width="full"
ignoreDead | desc="Hide this member's auras while it is dead or a ghost." get=<fn> hidden=fn:true name="Ignore Dead" order=4.410000000 set=<fn> type="toggle" width=1.300000000
ignoreDisconnected | desc="Hide this member's auras while it is offline." get=<fn> hidden=fn:true name="Ignore Disconnected" order=4.420000000 set=<fn> type="toggle" width=1.300000000
ignorespellid1 | get=<fn> hidden=fn:true name="Ignored Spell ID or Name" order=7.010300000 set=<fn> type="input" validate=<fn>
ignorespellidDisabledSpace | hidden=fn:false name="" order=7.001000000 type="description" width=1.500000000
ignorespellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=7.010200000 type="execute" width=0.200000000
includeDispelTypes | get=<fn> name="Include dispel types" order=24 set=<fn> type="multiselect" values={""="Enrage","Bleed"="Bleed","Curse"="Curse","Disease"="Disease","Magic"="Magic","Poison"="Poison"} width="full"
includeNameplateOnly | desc="Also allows auras normally returned only for nameplate displays. Other filters still apply." get=<fn> hidden=fn:false name="Include nameplate-only auras" order=21 set=<fn> type="toggle" width="full"
includePets | get=<fn> hidden=fn:true name="Include Pets" order=4.600000000 set=<fn> type="select" values={"PetsOnly"="Pets only","PlayersAndPets"="Players and Pets"} width=1.300000000
isBossAura | desc="Auras Blizzard identifies as boss auras." get=<fn> hidden=fn:true name=fn:"Is Boss Aura" order=14 set=<fn> type="toggle" width="full"
isBossOrRoleAura | desc="Auras Blizzard identifies as boss auras or marks as relevant to your role." get=<fn> hidden=fn:true name=fn:"Boss or role aura" order=16 set=<fn> type="toggle" width="full"
isFromPlayerOrPlayerPet | desc="Auras cast by any player or player pet, not only yours. For your own auras, use Own Only." get=<fn> hidden=fn:false name=fn:"Cast by a Player" order=11.010000000 set=<fn> type="toggle" width=1.300000000
isPriorityAura | desc="Debuffs Blizzard marks as high priority." get=<fn> hidden=fn:true name=fn:"Priority debuff" order=17 set=<fn> type="toggle" width="full"
isRoleAura | desc="Auras Blizzard marks as relevant to your role." get=<fn> hidden=fn:true name=fn:"Role aura" order=15 set=<fn> type="toggle" width="full"
isStealable | desc="Buffs that can be stolen with abilities such as Spellsteal." get=<fn> hidden=fn:false name=fn:"Is Stealable" order=13 set=<fn> type="toggle" width="full"
nameplateShowAll | desc="Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:false name=fn:"Marked for all nameplates" order=18 set=<fn> type="toggle" width="full"
nameplateShowPersonal | desc="Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura." get=<fn> hidden=fn:false name=fn:"Marked for personal debuff display" order=19 set=<fn> type="toggle" width="full"
nativeBIG_DEFENSIVE | desc="Auras Blizzard classifies as big defensives." get=<fn> hidden=fn:false name=fn:"Big defensive" order=20.400000000 set=<fn> type="toggle" width="full"
nativeCANCELABLE | desc="Auras that the player can cancel." get=<fn> hidden=fn:false name=fn:"Cancelable" order=20.150000000 set=<fn> type="toggle" width="full"
nativeCROWD_CONTROL | desc="Auras with a crowd-control effect, such as a stun or fear." get=<fn> hidden=fn:true name=fn:"Crowd control" order=20.250000000 set=<fn> type="toggle" width="full"
nativeDISPELLABLE | desc="Dispellable regardless of your or your raid's current abilities." get=<fn> hidden=fn:false name=fn:"Dispellable" order=20.500000000 set=<fn> type="toggle" width="full"
nativeEXTERNAL_DEFENSIVE | desc="Auras Blizzard classifies as external defensives." get=<fn> hidden=fn:false name=fn:"External defensive" order=20.200000000 set=<fn> type="toggle" width="full"
nativeIMPORTANT | desc="Blizzard's important-aura flag, including non-stealable enemy buffs shown on nameplates." get=<fn> hidden=fn:false name=fn:"Important aura" order=20.450000000 set=<fn> type="toggle" width="full"
nativePLAYER | desc="Auras cast by you, your pet or your vehicle." get=<fn> hidden=fn:false name=fn:"|cFF00FF00Own Only|r" order=11 set=<fn> type="toggle" width=1.300000000
nativeRAID | desc="Buffs you can apply, or debuffs you can dispel." get=<fn> hidden=fn:false name=fn:"Can apply / dispel" order=20.100000000 set=<fn> type="toggle" width="full"
nativeRAID_IN_COMBAT | desc="Auras flagged by Blizzard for raid-frame display in combat." get=<fn> hidden=fn:false name=fn:"Shown on raid frames in combat" order=20.300000000 set=<fn> type="toggle" width="full"
nativeRAID_PLAYER_DISPELLABLE | desc="Includes helpful enrages on enemies." get=<fn> hidden=fn:false name=fn:"Dispellable by someone in your raid" order=20.350000000 set=<fn> type="toggle" width="full"
rankCoverage | fontSize="small" hidden=fn:true name=fn:"Other ranks could not be found for: . Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)." order=5.900000000 type="description" width="full"
rankspellid1 | get=<fn> hidden=fn:true name="Spell ID or Name" order=4.960300000 set=<fn> type="input" validate=<fn>
rankspellidDisabledSpace | hidden=fn:false name="" order=4.951000000 type="description" width=1.500000000
rankspellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=4.960200000 type="execute" width=0.200000000
specificUnit | desc="party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5." get=<fn> hidden=fn:true name="Specific Unit" order=3.030000000 set=<fn> type="input" validate=<fn> width=1.300000000
specificUnitSpace | hidden=fn:true name="" order=3.020000000 type="description" width=1.300000000
spellSelectionHeader | name="Spell Selection Filters" order=4.700000000 type="header"
spellid1 | get=<fn> hidden=fn:true name="Exact Spell ID or Name" order=6.010300000 set=<fn> type="input" validate=<fn>
spellidDisabledSpace | hidden=fn:false name="" order=6.001000000 type="description" width=1.500000000
spellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=6.010200000 type="execute" width=0.200000000
unit | get=<fn> name="Unit" order=3.010000000 set=<fn> type="select" values={"arena"="Arena","boss"="Boss","focus"="Focus","focustarget"="Target of Focus","group"="Smart Group","member"="Specific Unit","mouseover"="Mouseover","nameplate"="Nameplate","party"="Party","pet"="Pet","player"="Player","raid"="Raid","target"="Target","targettarget"="Target of Target"} width=1.300000000
unitLabel | disabled=true get=<fn> name="Unit" order=3 type="toggle" width=1.300000000
unitNames | desc="Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match." get=<fn> hidden=fn:true name="Player Names" order=4.200000000 set=<fn> type="input" width="full"
unitRoles | desc="Uses Blizzard's assigned group role. Members without a role assigned match Unassigned." get=<fn> hidden=fn:true name="Group Roles" order=4.400000000 set=<fn> type="multiselect" values={"DAMAGER"="Damage","HEALER"="Healer","NONE"="Unassigned","TANK"="Tank"} width="full"
useExcludedSpellIDs | get=<fn> name="Ignored Exact Spell ID(s)" order=7 set=<fn> type="toggle" width=1.100000000
useIncludePets | desc="Also track the pets of the group members." get=<fn> hidden=fn:true name="Include Pets" order=4.500000000 set=<fn> type="toggle" width=1.300000000
useRankSpellIDs | desc="Enter a Spell ID or a spell name to track all ranks of that spell. A name is replaced by the IDs of all its ranks." get=<fn> name="Spell ID(s) (All Ranks)" order=4.950000000 set=<fn> type="toggle" width=1.100000000
useSpellIDs | get=<fn> name="Exact Spell ID(s)" order=6 set=<fn> type="toggle" width=1.100000000
useUnitNames | desc="Only track these group members. This also limits which units can play configured aura sounds." get=<fn> hidden=fn:true name="Player Name(s)" order=4.100000000 set=<fn> type="toggle" width=1.300000000
useUnitRoles | desc="Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled." get=<fn> hidden=fn:true name="Group Role" order=4.300000000 set=<fn> type="toggle" width=1.300000000
tri-state keys: {1="canApplyAura",10="nativeCANCELABLE",11="nativeCROWD_CONTROL",12="nativeDISPELLABLE",13="nativeEXTERNAL_DEFENSIVE",14="nativeIMPORTANT",15="nativeRAID",16="nativeRAID_IN_COMBAT",17="nativeRAID_PLAYER_DISPELLABLE",2="isBossAura",3="isBossOrRoleAura",4="isPriorityAura",5="isRoleAura",6="isStealable",7="nameplateShowAll",8="nameplateShowPersonal",9="nativeBIG_DEFENSIVE"}
includeNameplateOnly.get -> true | calls: none
includeNameplateOnly.set ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HELPFUL","includeNameplateOnly"=false,"nativeFilters"={"PLAYER"=true},"processedAuraType"="Buff","type"="secretAura","unit"="nameplate"}
nativePLAYER.get -> "true" | calls: none
nativePLAYER.name -> "|cFF00FF00Own Only|r" | calls: none
nativePLAYER.set false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
nativeFilters: {"PLAYER"=false}
nativePLAYER.get false -> "false" | calls: none
nativePLAYER.name false -> "|cFFFF0000Not Own Only|r" | calls: none
nativePLAYER.set false again ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
nativeFilters: nil
nativePLAYER.set true ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
nativeFilters: {"PLAYER"=true}
isFromPlayerOrPlayerPet.get -> false | calls: none
isFromPlayerOrPlayerPet.set true ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
isFromPlayerOrPlayerPet.get true -> "true" | calls: none
isFromPlayerOrPlayerPet.name true -> "|cFF00FF00Cast by a Player|r" | calls: none
isFromPlayerOrPlayerPet.set false ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
isFromPlayerOrPlayerPet.name false -> "|cFFFF0000Not Cast by a Player|r" | calls: none
trigger: {"debuffType"="HELPFUL","includeNameplateOnly"=false,"isFromPlayerOrPlayerPet"=false,"nativeFilters"={"PLAYER"=true},"processedAuraType"="Buff","type"="secretAura","unit"="nameplate"}
specificUnit.get -> "party1" | calls: none
specificUnit.validate bad -> "Enter a unit such as party1, raid5, boss1 or arena2." | calls: none
specificUnit.validate party2 -> true | calls: none
specificUnit.set ->  | calls: QueueOptionsRefresh=1 SaveAuraTrigger=1
trigger: {"debuffType"="HELPFUL","includeNameplateOnly"=false,"isFromPlayerOrPlayerPet"=false,"nativeFilters"={"PLAYER"=true},"processedAuraType"="Buff","specificUnit"="raid5","type"="secretAura","unit"="member"}
member: specificUnit.hidden=fn:false nameplateOnly.hidden=fn:true
]==],
    ["viewer.buff.new"] = [==[
cdmPicker_available | get=<fn> name="Show only available" order=35.002000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_buffShow | get=<fn> hidden=fn:false name="Show" order=10.016000000 set=<fn> type="select" values={"active"="Aura Active","always"="Always","missing"="Aura Missing"} width=1.300000000
cdmPicker_display | hidden=fn:false name="Display" order=10.014000000 type="header"
cdmPicker_elapsedEnabled | desc="Filters active, timed auras using readable CDM elapsed time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:false name="Elapsed Time" order=10.024000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_elapsedOperator | get=<fn> hidden=fn:true name="" order=10.025000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_elapsedSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.026000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_entries | name="Blizzard CDM Entries" order=35.004000000 type="header"
cdmPicker_entry101 | desc="Category2" get=<fn> image=10010 imageHeight=18 imageWidth=18 name="Alpha [1010]" order=35.005000000 set=<fn> type="toggle" width="full"
cdmPicker_entry102 | desc="Category0" get=<fn> image=10020 imageHeight=18 imageWidth=18 name="Beta (Rank 1) [1020]" order=35.007000000 set=<fn> type="toggle" width="full"
cdmPicker_entry103 | desc="Category1" get=<fn> image=10030 imageHeight=18 imageWidth=18 name="Beta (Rank 2) [1030]" order=35.006000000 set=<fn> type="toggle" width="full"
cdmPicker_entry104 | desc="Category0" get=<fn> image=10040 imageHeight=18 imageWidth=18 name="Gamma [1040]" order=35.008000000 set=<fn> type="toggle" width="full"
cdmPicker_extra | control="WeakAurasExpandSmall" func=<fn> hidden=fn:true image=fn:"collapsed" imageHeight=15 imageWidth=15 name=fn:"|cFFffcc00Extra Options:|r Hide GCD text" order=10.030000000 type="execute" width="full"
cdmPicker_filters | name="Blizzard CDM Filters" order=35 type="header"
cdmPicker_help | name="Spells must be active in the CDM to be displayed. Type /cdm and add them." order=10.011000000 type="description" width="full"
cdmPicker_hideGCDText | desc="Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown." get=<fn> hidden=fn:true name="Hide global cooldown text" order=10.034000000 set=<fn> type="toggle" width="full"
cdmPicker_ignoreSpellKnown | get=<fn> hidden=fn:true name="Disable Spell Known Check" order=10.035000000 set=<fn> type="toggle" width="full"
cdmPicker_includeGCD | get=<fn> hidden=fn:true name="Show global cooldown" order=10.033000000 set=<fn> type="toggle" width="full"
cdmPicker_maxRank | get=<fn> name="Show only max rank" order=35.003000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_name1 | get=<fn> hidden=fn:true name="Aura Name" order=21.010300000 set=<fn> type="input"
cdmPicker_nameDisabledSpace | hidden=fn:false name="" order=21.001000000 type="description" width=1.500000000
cdmPicker_nameToggle | get=<fn> name="Name(s)" order=21 set=<fn> type="toggle" width=1.100000000
cdmPicker_nameicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=21.010200000 type="execute" width=0.200000000
cdmPicker_open | disabled=fn:false func=<fn> name="Open CDM" order=10.012000000 type="execute" width=1.300000000
cdmPicker_refresh | func=<fn> name="Refresh from Blizzard CDM" order=10.013000000 type="execute" width=1.300000000
cdmPicker_remainingEnabled | desc="Filters active, timed auras using readable CDM remaining time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:false name="Remaining Time" order=10.018000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_remainingOperator | get=<fn> hidden=fn:true name="" order=10.019000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_remainingSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.020000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_requireTarget | desc="Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes." get=<fn> hidden=fn:false name="Require attackable target" order=10.017000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_search | get=<fn> name="Search" order=35.001000000 set=<fn> type="input" width="full"
cdmPicker_show | desc="Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches." get=<fn> hidden=fn:true name="Show" order=10.015000000 set=<fn> type="select" values={"always"="Always","cooldown"="On Cooldown","ready"="Not on Cooldown","unusable"="Not Usable","usable"="Usable"} width=1.300000000
cdmPicker_spellSelection | name="Spell Selection Filters" order=20 type="header"
cdmPicker_spellid1 | get=<fn> hidden=fn:true name="Spell ID" order=25.010300000 set=<fn> type="input" validate=<fn>
cdmPicker_spellidDisabledSpace | hidden=fn:false name="" order=25.001000000 type="description" width=1.500000000
cdmPicker_spellidToggle | get=<fn> name="Exact Spell ID(s)" order=25 set=<fn> type="toggle" width=1.100000000
cdmPicker_spellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=25.010200000 type="execute" width=0.200000000
cdmPicker_stacksCount | get=<fn> hidden=fn:true name="Stacks" order=10.029000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_stacksEnabled | desc="Filters active auras using readable CDM stack counts. Missing stack counts, or counts the game hides, do not match. All enabled filters must match." get=<fn> hidden=fn:false name="Stack Count" order=10.027000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_stacksOperator | get=<fn> hidden=fn:true name="" order=10.028000000 set=<fn> type="select" values={"<"="<","<="="<=","=="="=",">"=">",">="=">=","~="="!="} width=0.500000000
cdmPicker_totalEnabled | desc="Filters active, timed auras using readable CDM total time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:false name="Total Duration" order=10.021000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_totalOperator | get=<fn> hidden=fn:true name="" order=10.022000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_totalSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.023000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_track | get=<fn> hidden=fn:true name="Track cooldowns" order=10.031000000 set=<fn> type="select" values={"auto"="Auto","charges"="Charge recharge","cooldown"="Cooldown"} width=1.300000000
cdmPicker_trackSpacer | hidden=fn:true name="" order=10.032000000 type="description" width=1.300000000
cdmPicker_typeSpacer | name=" " order=10.010000000 type="description" width="full"
unrelated | type="toggle"
trigger: {"cdmSource"="buff","cdmSpells"={"multi"={}},"event"="Blizzard CDM Buff","type"="cdm"} | calls: none
buffShow.get -> "active" | calls: none
buffShow.set missing ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
requireTarget.get -> false | calls: none
requireTarget.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
remainingEnabled.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
remainingOperator.get -> "<" | calls: none
remainingOperator.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
remainingSeconds.get -> "10" | calls: none
remainingSeconds.set 5.5 ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
remainingSeconds.get after -> "5.5" | calls: none
remainingSeconds.validate -1 -> "Enter a non-negative number of seconds." | calls: none
remainingSeconds.validate abc -> "Enter a non-negative number of seconds." | calls: none
remainingSeconds.validate 0 -> true | calls: none
stacksCount.get -> "1" | calls: none
stacksCount.validate 1.5 -> "Enter a non-negative whole number." | calls: none
stacksCount.validate 3 -> true | calls: none
stacksOperator.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
stacksCount.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
elapsedEnabled.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
totalEnabled.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
trigger: {"cdmBuffShow"="missing","cdmRemainingOperator"=">=","cdmRemainingTime"=5.500000000,"cdmRequireTarget"=true,"cdmSource"="buff","cdmSpells"={"multi"={}},"cdmStackCount"=4,"cdmStackOperator"="==","cdmUseElapsed"=true,"cdmUseRemaining"=true,"cdmUseTotal"=true,"event"="Blizzard CDM Buff","type"="cdm"}
hidden after enabling: remainingOperator=fn:false remainingSeconds=fn:false elapsedSeconds=fn:false
nameToggle.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
name1.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
trigger: {"cdmBuffShow"="missing","cdmNames"={1="Some Aura"},"cdmRemainingOperator"=">=","cdmRemainingTime"=5.500000000,"cdmRequireTarget"=true,"cdmSource"="buff","cdmSpells"={"multi"={}},"cdmStackCount"=4,"cdmStackOperator"="==","cdmUseElapsed"=true,"cdmUseNames"=true,"cdmUseRemaining"=true,"cdmUseTotal"=true,"event"="Blizzard CDM Buff","type"="cdm"}
entry101.get -> false | calls: none
entry101.set true ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
cdmSpells: {"multi"={"101"=true}}
entry101.get after -> true | calls: none
entry101.set false ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
cdmSpells: {"multi"={}}
refresh.func ->  | calls: ClearAndUpdateOptions=1
search.set ->  | calls: ClearAndUpdateOptions=1
available.set ->  | calls: ClearAndUpdateOptions=1
maxRank.set ->  | calls: ClearAndUpdateOptions=1
rebuilt with view state: entries={1="cdmPicker_entry101",2="cdmPicker_entry102",3="cdmPicker_entry103",4="cdmPicker_entry104"} search=fn:"" available=fn:false maxRank=fn:false
]==],
    ["viewer.cooldown.existing"] = [==[
cdmPicker_available | get=<fn> name="Show only available" order=35.002000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_buffShow | get=<fn> hidden=fn:true name="Show" order=10.016000000 set=<fn> type="select" values={"active"="Aura Active","always"="Always","missing"="Aura Missing"} width=1.300000000
cdmPicker_display | hidden=fn:false name="Display" order=10.014000000 type="header"
cdmPicker_elapsedEnabled | desc="Filters active, timed auras using readable CDM elapsed time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Elapsed Time" order=10.024000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_elapsedOperator | get=<fn> hidden=fn:true name="" order=10.025000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_elapsedSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.026000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_entries | name="Blizzard CDM Entries" order=35.004000000 type="header"
cdmPicker_entry101 | desc="Category2" get=<fn> image=10010 imageHeight=18 imageWidth=18 name="Alpha [1010]" order=35.005000000 set=<fn> type="toggle" width="full"
cdmPicker_entry102 | desc="Category0" get=<fn> image=10020 imageHeight=18 imageWidth=18 name="Beta (Rank 1) [1020]" order=35.007000000 set=<fn> type="toggle" width="full"
cdmPicker_entry103 | desc="Category1" get=<fn> image=10030 imageHeight=18 imageWidth=18 name="Beta (Rank 2) [1030]" order=35.006000000 set=<fn> type="toggle" width="full"
cdmPicker_entry104 | desc="Category0" get=<fn> image=10040 imageHeight=18 imageWidth=18 name="Gamma [1040]" order=35.008000000 set=<fn> type="toggle" width="full"
cdmPicker_extra | control="WeakAurasExpandSmall" func=<fn> hidden=fn:false image=fn:"collapsed" imageHeight=15 imageWidth=15 name=fn:"|cFFffcc00Extra Options:|r Charge recharge; Show GCD" order=10.030000000 type="execute" width="full"
cdmPicker_filters | name="Blizzard CDM Filters" order=35 type="header"
cdmPicker_help | name="Spells must be active in the CDM to be displayed. Type /cdm and add them." order=10.011000000 type="description" width="full"
cdmPicker_hideGCDText | desc="Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown." get=<fn> hidden=fn:true name="Hide global cooldown text" order=10.034000000 set=<fn> type="toggle" width="full"
cdmPicker_ignoreSpellKnown | get=<fn> hidden=fn:true name="Disable Spell Known Check" order=10.035000000 set=<fn> type="toggle" width="full"
cdmPicker_includeGCD | get=<fn> hidden=fn:true name="Show global cooldown" order=10.033000000 set=<fn> type="toggle" width="full"
cdmPicker_maxRank | get=<fn> name="Show only max rank" order=35.003000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_name1 | get=<fn> hidden=fn:false name="Spell Name" order=21.010300000 set=<fn> type="input"
cdmPicker_name2 | get=<fn> hidden=fn:false name="Spell Name" order=21.020300000 set=<fn> type="input"
cdmPicker_name3 | get=<fn> hidden=fn:false name="Spell Name" order=21.030300000 set=<fn> type="input"
cdmPicker_nameDisabledSpace | hidden=fn:true name="" order=21.001000000 type="description" width=1.500000000
cdmPicker_nameToggle | get=<fn> name="Name(s)" order=21 set=<fn> type="toggle" width=1.100000000
cdmPicker_nameicon1 | control="WeakAurasIcon" hidden=fn:false name="" order=21.010200000 type="execute" width=0.200000000
cdmPicker_nameicon2 | control="WeakAurasIcon" hidden=fn:false name="" order=21.020200000 type="execute" width=0.200000000
cdmPicker_nameicon3 | control="WeakAurasIcon" hidden=fn:false name="" order=21.030200000 type="execute" width=0.200000000
cdmPicker_open | disabled=fn:false func=<fn> name="Open CDM" order=10.012000000 type="execute" width=1.300000000
cdmPicker_refresh | func=<fn> name="Refresh from Blizzard CDM" order=10.013000000 type="execute" width=1.300000000
cdmPicker_remainingEnabled | desc="Filters active, timed auras using readable CDM remaining time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Remaining Time" order=10.018000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_remainingOperator | get=<fn> hidden=fn:true name="" order=10.019000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_remainingSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.020000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_requireTarget | desc="Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes." get=<fn> hidden=fn:true name="Require attackable target" order=10.017000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_search | get=<fn> name="Search" order=35.001000000 set=<fn> type="input" width="full"
cdmPicker_show | desc="Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches." get=<fn> hidden=fn:false name="Show" order=10.015000000 set=<fn> type="select" values={"always"="Always","cooldown"="On Cooldown","ready"="Not on Cooldown","unusable"="Not Usable","usable"="Usable"} width=1.300000000
cdmPicker_spellSelection | name="Spell Selection Filters" order=20 type="header"
cdmPicker_spellid1 | get=<fn> hidden=fn:false name="Spell ID" order=25.010300000 set=<fn> type="input" validate=<fn>
cdmPicker_spellid2 | get=<fn> hidden=fn:false name="Spell ID" order=25.020300000 set=<fn> type="input" validate=<fn>
cdmPicker_spellidDisabledSpace | hidden=fn:true name="" order=25.001000000 type="description" width=1.500000000
cdmPicker_spellidToggle | get=<fn> name="Exact Spell ID(s)" order=25 set=<fn> type="toggle" width=1.100000000
cdmPicker_spellidicon1 | control="WeakAurasIcon" hidden=fn:false name="" order=25.010200000 type="execute" width=0.200000000
cdmPicker_spellidicon2 | control="WeakAurasIcon" hidden=fn:false name="" order=25.020200000 type="execute" width=0.200000000
cdmPicker_stacksCount | get=<fn> hidden=fn:true name="Stacks" order=10.029000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_stacksEnabled | desc="Filters active auras using readable CDM stack counts. Missing stack counts, or counts the game hides, do not match. All enabled filters must match." get=<fn> hidden=fn:true name="Stack Count" order=10.027000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_stacksOperator | get=<fn> hidden=fn:true name="" order=10.028000000 set=<fn> type="select" values={"<"="<","<="="<=","=="="=",">"=">",">="=">=","~="="!="} width=0.500000000
cdmPicker_totalEnabled | desc="Filters active, timed auras using readable CDM total time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Total Duration" order=10.021000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_totalOperator | get=<fn> hidden=fn:true name="" order=10.022000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_totalSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.023000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_track | get=<fn> hidden=fn:true name="Track cooldowns" order=10.031000000 set=<fn> type="select" values={"auto"="Auto","charges"="Charge recharge","cooldown"="Cooldown"} width=1.300000000
cdmPicker_trackSpacer | hidden=fn:true name="" order=10.032000000 type="description" width=1.300000000
cdmPicker_typeSpacer | name=" " order=10.010000000 type="description" width="full"
trigger: {"cdmExactIDs"={1="133"},"cdmHideGCDText"=false,"cdmNames"={1="Fireball",2="Frostbolt"},"cdmRemainingOperator"="<=","cdmRemainingTime"=3,"cdmShow"="usable","cdmSource"="cooldown","cdmSpells"={"multi"={"103"=true,102=true}},"cdmTrack"="charges","cdmUseExactIDs"=true,"cdmUseNames"=true,"cdmUseRemaining"=true,"event"="Blizzard Cooldown Manager","type"="cdm","use_cdmShowGCD"=true} | calls: none
show.get -> "usable" | calls: none
show.set ready ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
track.get -> "charges" | calls: none
track.set cooldown ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
includeGCD.get -> true | calls: none
hideGCDText.get -> false | calls: none
hideGCDText.set true ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
ignoreSpellKnown.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
extra before: hidden=fn:true name=fn:"|cFFffcc00Extra Options:|r Cooldown; Disable Spell Known Check; Show GCD; Hide GCD text" image=fn:"collapsed"
extra.func ->  | calls: ClearAndUpdateOptions=1
extra after: hidden=fn:false name=fn:"|cFFffcc00Extra Options:|r Cooldown; Disable Spell Known Check; Show GCD; Hide GCD text" image=fn:"expanded"
nameToggle.get -> true | calls: none
nameToggle.set false ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
name1.get -> "Fireball" | calls: none
name3.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
spellid1.validate -> "Enter a positive whole-number Spell ID.",true,true | calls: none
spellid2.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
entry102.get -> true | calls: none
entry103.get -> true | calls: none
entry103.set false ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
cdmSpells: {"multi"={102=true}}
trigger: {"cdmExactIDs"={1="133",2="134"},"cdmHideGCDText"=true,"cdmNames"={1="Fireball",2="Frostbolt",3="Pyroblast"},"cdmRemainingOperator"="<=","cdmRemainingTime"=3,"cdmShow"="ready","cdmSource"="cooldown","cdmSpells"={"multi"={102=true}},"cdmTrack"="cooldown","cdmUseExactIDs"=true,"cdmUseNames"=false,"cdmUseRemaining"=true,"event"="Blizzard Cooldown Manager","type"="cdm","use_cdmShowGCD"=true,"use_ignoreSpellKnown"=true}
]==],
    ["viewer.item.migration"] = [==[
trigger after build: {"cdmItemIDs"={1="4242"},"cdmNames"={1="Legacy"},"cdmSource"="cooldown","cdmSpells"={"multi"={}},"cdmUseItemIDs"=true,"cdmUseNames"=true,"event"="Blizzard CDM Item","type"="cdm"} | calls: none
after timer: calls: Add=1 UpdateFakeStatesFor=1
cdmPicker_available | get=<fn> name="Show only available" order=35.002000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_buffShow | get=<fn> hidden=fn:true name="Show" order=10.016000000 set=<fn> type="select" values={"active"="Aura Active","always"="Always","missing"="Aura Missing"} width=1.300000000
cdmPicker_display | hidden=fn:true name="Display" order=10.014000000 type="header"
cdmPicker_elapsedEnabled | desc="Filters active, timed auras using readable CDM elapsed time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Elapsed Time" order=10.024000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_elapsedOperator | get=<fn> hidden=fn:true name="" order=10.025000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_elapsedSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.026000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_entries | name="Blizzard CDM Entries" order=35.004000000 type="header"
cdmPicker_entry101 | desc="Category2" get=<fn> image=5101 imageHeight=18 imageWidth=18 name="Entry 101 [10100]" order=35.005000000 set=<fn> type="toggle" width="full"
cdmPicker_entry102 | desc="Category0" get=<fn> image=5102 imageHeight=18 imageWidth=18 name="Entry 102 [10200]" order=35.006000000 set=<fn> type="toggle" width="full"
cdmPicker_entry103 | desc="Category1" get=<fn> image=5103 imageHeight=18 imageWidth=18 name="Entry 103 [10300]" order=35.007000000 set=<fn> type="toggle" width="full"
cdmPicker_entry104 | desc="Category0" get=<fn> image=5104 imageHeight=18 imageWidth=18 name="Entry 104 [10400]" order=35.008000000 set=<fn> type="toggle" width="full"
cdmPicker_extra | control="WeakAurasExpandSmall" func=<fn> hidden=fn:true image=fn:"collapsed" imageHeight=15 imageWidth=15 name=fn:"|cFFffcc00Extra Options:|r Hide GCD text" order=10.030000000 type="execute" width="full"
cdmPicker_filters | name="Blizzard CDM Filters" order=35 type="header"
cdmPicker_help | name="Spells must be active in the CDM to be displayed. Type /cdm and add them." order=10.011000000 type="description" width="full"
cdmPicker_hideGCDText | desc="Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown." get=<fn> hidden=fn:true name="Hide global cooldown text" order=10.034000000 set=<fn> type="toggle" width="full"
cdmPicker_ignoreSpellKnown | get=<fn> hidden=fn:true name="Disable Spell Known Check" order=10.035000000 set=<fn> type="toggle" width="full"
cdmPicker_includeGCD | get=<fn> hidden=fn:true name="Show global cooldown" order=10.033000000 set=<fn> type="toggle" width="full"
cdmPicker_itemid1 | get=<fn> hidden=fn:false name="Item ID" order=29.010300000 set=<fn> type="input" validate=<fn>
cdmPicker_itemid2 | get=<fn> hidden=fn:false name="Item ID" order=29.020300000 set=<fn> type="input" validate=<fn>
cdmPicker_itemidDisabledSpace | hidden=fn:true name="" order=29.001000000 type="description" width=1.500000000
cdmPicker_itemidToggle | get=<fn> name="Exact Item ID(s)" order=29 set=<fn> type="toggle" width=1.100000000
cdmPicker_itemidicon1 | control="WeakAurasIcon" disabled=fn:false hidden=fn:false image=fn:"133",18,18 name=fn:"Test Item" order=29.010200000 type="execute" width=0.200000000
cdmPicker_itemidicon2 | control="WeakAurasIcon" disabled=fn:true hidden=fn:false image=fn:"",18,18 name=fn:"" order=29.020200000 type="execute" width=0.200000000
cdmPicker_maxRank | get=<fn> name="Show only max rank" order=35.003000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_name1 | get=<fn> hidden=fn:false name="Spell Name" order=21.010300000 set=<fn> type="input"
cdmPicker_name2 | get=<fn> hidden=fn:false name="Spell Name" order=21.020300000 set=<fn> type="input"
cdmPicker_nameDisabledSpace | hidden=fn:true name="" order=21.001000000 type="description" width=1.500000000
cdmPicker_nameToggle | get=<fn> name="Name(s)" order=21 set=<fn> type="toggle" width=1.100000000
cdmPicker_nameicon1 | control="WeakAurasIcon" hidden=fn:false name="" order=21.010200000 type="execute" width=0.200000000
cdmPicker_nameicon2 | control="WeakAurasIcon" hidden=fn:false name="" order=21.020200000 type="execute" width=0.200000000
cdmPicker_open | disabled=fn:false func=<fn> name="Open CDM" order=10.012000000 type="execute" width=1.300000000
cdmPicker_refresh | func=<fn> name="Refresh from Blizzard CDM" order=10.013000000 type="execute" width=1.300000000
cdmPicker_remainingEnabled | desc="Filters active, timed auras using readable CDM remaining time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Remaining Time" order=10.018000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_remainingOperator | get=<fn> hidden=fn:true name="" order=10.019000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_remainingSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.020000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_requireTarget | desc="Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes." get=<fn> hidden=fn:true name="Require attackable target" order=10.017000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_search | get=<fn> name="Search" order=35.001000000 set=<fn> type="input" width="full"
cdmPicker_show | desc="Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches." get=<fn> hidden=fn:true name="Show" order=10.015000000 set=<fn> type="select" values={"always"="Always","cooldown"="On Cooldown","ready"="Not on Cooldown","unusable"="Not Usable","usable"="Usable"} width=1.300000000
cdmPicker_spellSelection | name="Spell Selection Filters" order=20 type="header"
cdmPicker_spellid1 | get=<fn> hidden=fn:true name="Spell ID" order=25.010300000 set=<fn> type="input" validate=<fn>
cdmPicker_spellidDisabledSpace | hidden=fn:false name="" order=25.001000000 type="description" width=1.500000000
cdmPicker_spellidToggle | get=<fn> name="Exact Spell ID(s)" order=25 set=<fn> type="toggle" width=1.100000000
cdmPicker_spellidicon1 | control="WeakAurasIcon" hidden=fn:true name="" order=25.010200000 type="execute" width=0.200000000
cdmPicker_stacksCount | get=<fn> hidden=fn:true name="Stacks" order=10.029000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_stacksEnabled | desc="Filters active auras using readable CDM stack counts. Missing stack counts, or counts the game hides, do not match. All enabled filters must match." get=<fn> hidden=fn:true name="Stack Count" order=10.027000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_stacksOperator | get=<fn> hidden=fn:true name="" order=10.028000000 set=<fn> type="select" values={"<"="<","<="="<=","=="="=",">"=">",">="=">=","~="="!="} width=0.500000000
cdmPicker_totalEnabled | desc="Filters active, timed auras using readable CDM total time. Missing and permanent timers, or timers the game hides, do not match." get=<fn> hidden=fn:true name="Total Duration" order=10.021000000 set=<fn> type="toggle" width=1.300000000
cdmPicker_totalOperator | get=<fn> hidden=fn:true name="" order=10.022000000 set=<fn> type="select" values={"<"="<","<="="<=",">"=">",">="=">="} width=0.500000000
cdmPicker_totalSeconds | get=<fn> hidden=fn:true name="Seconds" order=10.023000000 set=<fn> type="input" validate=<fn> width=0.800000000
cdmPicker_track | get=<fn> hidden=fn:true name="Track cooldowns" order=10.031000000 set=<fn> type="select" values={"auto"="Auto","charges"="Charge recharge","cooldown"="Cooldown"} width=1.300000000
cdmPicker_trackSpacer | hidden=fn:true name="" order=10.032000000 type="description" width=1.300000000
cdmPicker_typeSpacer | name=" " order=10.010000000 type="description" width="full"
itemid1.get -> "4242 (Test Item)\0004242" | calls: CDMRequestItemData=1
itemid2.get -> "" | calls: none
itemid1.validate -> "Enter a positive whole-number Item ID.",true | calls: none
itemid2.set ->  | calls: Add=1 ClearAndUpdateOptions=1 ScanForLoads=1 UpdateFakeStatesFor=1 UpdateThumbnail=1
trigger: {"cdmItemIDs"={1="4242",2="77"},"cdmNames"={1="Legacy"},"cdmSource"="cooldown","cdmSpells"={"multi"={}},"cdmUseItemIDs"=true,"cdmUseNames"=true,"event"="Blizzard CDM Item","type"="cdm"}
exact legacy: {"cdmExactIDs"={1=" 55 "},"cdmSelection"="spell","cdmSource"="cooldown","cdmSpells"={"multi"={}},"cdmUseExactIDs"=true,"event"="Blizzard Cooldown Manager","type"="cdm"}
utility: {"cdmSource"="cooldown","cdmSpells"={"multi"={}},"event"="Blizzard Cooldown Manager","type"="cdm"}
]==],
  }
  -- EXPECTED-END

  for _, name in ipairs(order) do
    local expected = EXPECTED[name]
    assert(expected, "no expected block for " .. name)
    expected = (expected:gsub("^\n", ""):gsub("\n$", ""))
    local actualLines, expectedLines = {}, {}
    for line in (cases[name] .. "\n"):gmatch("(.-)\n") do actualLines[#actualLines + 1] = line end
    for line in (expected .. "\n"):gmatch("(.-)\n") do expectedLines[#expectedLines + 1] = line end
    for position = 1, math.max(#actualLines, #expectedLines) do
      assert(actualLines[position] == expectedLines[position],
        string.format("%s line %d\n  expected: %s\n  actual:   %s", name, position,
          tostring(expectedLines[position]), tostring(actualLines[position])))
    end
  end
  for name in pairs(EXPECTED) do
    assert(cases[name], "expected block without case " .. name)
  end
end

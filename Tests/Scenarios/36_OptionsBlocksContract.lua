-- OptionsBlocksContract: freezes the behaviour of option blocks in WeakAurasOptions/ that are about to be rewritten
-- (ActionOptions, TriggerOptions, BuffTrigger2, SubRegionCommon, RegionOptions/Group, CommonOptions, DisplayOptions,
-- ConditionOptions). Only public exports of the files are used.
-- Like in game (and scenarios 17, 31 and 34), OptionsPrivate.Private is set AFTER the files are executed.
-- Not covered: DisplayButton, OptionsFrame and WeakAurasOptions.lua (they need the full AceGUI widget stack).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  local function Same(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
  local function Near(actual, expected, label)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
  -- Sorted "key=value;" list of a table, used to compare value tables.
  local function Dump(t)
    local list = {}
    for k, v in pairs(t) do list[#list + 1] = tostring(k) .. "=" .. tostring(v) end
    table.sort(list)
    return table.concat(list, ";")
  end

  -- Option keys that embed a table address ("condition1" .. tostring(path) .. "_op"): the address is replaced by T.
  local function Find(args, pattern)
    for key, option in pairs(args) do
      if key:gsub("table: [%xx]+", "T"):find(pattern) then return option, key end
    end
  end

  -- Recorder for the calls that options make on WeakAuras / OptionsPrivate. Take() returns them sorted and clears them.
  local calls = {}
  local function Record(name)
    return function(first)
      calls[#calls + 1] = name .. ":" .. tostring(type(first) == "table" and first.id or first)
    end
  end
  local function Take()
    table.sort(calls)
    local text = table.concat(calls, ",")
    calls = {}
    return text
  end
  local realAdd, realUpdateThumbnail, realClearAndUpdate, realGetData = WeakAuras.Add, WeakAuras.UpdateThumbnail, WeakAuras.ClearAndUpdateOptions, WeakAuras.GetData
  WeakAuras.Add, WeakAuras.UpdateThumbnail, WeakAuras.ClearAndUpdateOptions = Record("add"), Record("thumb"), Record("update")

  AceGUIWidgetLSMlists = AceGUIWidgetLSMlists or { border = {}, background = {} }
  local optionsPrivate = {
    IsCollapsed = function() return false end,
    SetCollapsed = function() end,
    AddTextFormatOption = function() end,
    AddModernFlowGroupOptions = function() end,
    QueueOptionsRefresh = Record("queue"),
    ClearOptions = Record("clear"),
    ResetMoverSizer = function() end,
  }
  for _, file in ipairs({ "CommonOptions.lua", "TriggerOptions.lua", "ActionOptions.lua", "TriggerSecretWarnings.lua", "BuffTrigger2.lua",
    "SubRegionOptions/SubRegionCommon.lua", "RegionOptions/Group.lua", "AuraDisplayOptions.lua", "DisplayOptions.lua", "ConditionOptions.lua" }) do
    local ok, message = test.Loader.RunFile(directory .. file, "WeakAurasOptions", optionsPrivate)
    assert(ok, file .. ": " .. tostring(message))
  end
  optionsPrivate.Private = private
  -- AuraDisplayOptions.lua defines the real (deferred) QueueOptionsRefresh: record the calls instead.
  optionsPrivate.QueueOptionsRefresh = Record("queue")
  optionsPrivate.AuraEditor = { Resolve = function(_, triggernum) calls[#calls + 1] = "resolve:" .. triggernum end }
  optionsPrivate.SaveAuraTrigger = function(_, triggernum) calls[#calls + 1] = "save:" .. triggernum end

  ---------------------------------------------------------------------------------------------------------------
  -- ActionOptions: the " Fojji" recorded-voice phrase input exists before PrepareSecretActionOptions runs.
  ---------------------------------------------------------------------------------------------------------------
  local keysSeenByPrepare
  local realPrepare = optionsPrivate.PrepareSecretActionOptions
  assert(type(realPrepare) == "function", "PrepareSecretActionOptions export")
  optionsPrivate.PrepareSecretActionOptions = function(data, action)
    keysSeenByPrepare = {}
    for key in pairs(action.args) do keysSeenByPrepare[key] = true end
    return realPrepare(data, action)
  end
  local actionData = { id = "S", uid = "S", regionType = "icon", cooldown = true, anchorFrameType = "SCREEN",
    actions = { start = {}, finish = {}, init = {} }, conditions = {},
    triggers = { { trigger = { type = "secretAura", unit = "player", debuffType = "HELPFUL", auraspellids = { "1" } } } } }
  local actionOptions = optionsPrivate.GetActionOptions(actionData)
  assert(keysSeenByPrepare and keysSeenByPrepare.start_sound_fojji and keysSeenByPrepare.finish_sound_fojji,
    "sound_fojji inputs must exist before PrepareSecretActionOptions")
  for _, when in ipairs({ "start", "finish" }) do
    local phrase, sound = actionOptions.args[when .. "_sound_fojji"], actionOptions.args[when .. "_sound"]
    Same(phrase.type, "input", when .. " fojji type")
    Same(phrase.name, "Recorded phrase", when .. " fojji name")
    Same(phrase.width, "full", when .. " fojji width")
    Near(phrase.order - sound.order, 0.01, when .. " fojji order")
    Same(phrase.hidden(), true, when .. " fojji hidden without Fojji sound")
    Same(phrase.disabled(), true, when .. " fojji disabled without do_sound")
    actionData.actions[when].sound = " Fojji"
    Same(phrase.hidden(), false, when .. " fojji hidden with Fojji sound")
    actionData.actions[when].do_sound = true
    Same(phrase.disabled(), false, when .. " fojji disabled with do_sound")
    Same(sound.values[" Fojji"], "FojjiCore recorded voice", when .. " Fojji sound choice")
  end

  ---------------------------------------------------------------------------------------------------------------
  -- TriggerOptions: "When Aura (Modern) Filters Are Not Met, Use" (triggers.secretFallback).
  ---------------------------------------------------------------------------------------------------------------
  private.triggerTypesOptions = private.triggerTypesOptions or {}
  local realSecretTriggerOptions, realCustomTriggerOptions = private.triggerTypesOptions.secretAura, private.triggerTypesOptions.custom
  private.triggerTypesOptions.secretAura = function() return {} end
  private.triggerTypesOptions.custom = function() return {} end
  optionsPrivate.AddTriggerMetaFunctions = function() end
  local triggerData = { id = "T", triggers = { { trigger = { type = "secretAura", unit = "player", auraspellids = { "1" } } },
    { trigger = { type = "custom" } }, { trigger = { type = "secretAura" } }, activeTriggerMode = -10 } }
  local fallback = optionsPrivate.GetTriggerOptions(triggerData).args["global.secretFallback"]
  assert(fallback, "secretFallback option")
  Same(fallback.type, "select", "secretFallback type")
  Same(fallback.name, "When Aura (Modern) Filters Are Not Met, Use", "secretFallback name")
  Same(fallback.width, WeakAuras.doubleWidth, "secretFallback width")
  Same(fallback.hidden(), false, "secretFallback visible with a secret and a non secret trigger")
  Same(fallback.get(), "next", "secretFallback default")
  Same(Dump(fallback.values()), "2=Trigger 2;next=Next Active Trigger;none=None", "secretFallback values")
  assert(not fallback.desc():find("Ignored: Dynamic Information", 1, true), "secretFallback desc without warning")
  Take()
  fallback.set(nil, 2)
  Same(triggerData.triggers.secretFallback, 2, "secretFallback set trigger")
  Same(Take(), "add:T", "secretFallback set saves")
  Same(fallback.get(), 2, "secretFallback get trigger")
  fallback.set(nil, "next")
  Same(triggerData.triggers.secretFallback, nil, "secretFallback next clears")
  fallback.set(nil, "none")
  Same(triggerData.triggers.secretFallback, "none", "secretFallback none")
  Same(fallback.get(), "none", "secretFallback get none")
  Take()
  Same(optionsPrivate.GetTriggerOptions({ id = "O", triggers = { { trigger = { type = "secretAura" } } } }).args["global.secretFallback"].hidden(),
    true, "secretFallback hidden with one trigger")
  local withoutSecret = optionsPrivate.GetTriggerOptions({ id = "O", triggers = { { trigger = { type = "custom" } }, { trigger = { type = "custom" } } } }).args["global.secretFallback"]
  Same(withoutSecret.hidden(), true, "secretFallback hidden without secret trigger")
  assert(withoutSecret.desc():find("Ignored while the progress source is not an Aura (Modern) trigger.", 1, true),
    "secretFallback warning without secret trigger")
  private.triggerTypesOptions.secretAura, private.triggerTypesOptions.custom = realSecretTriggerOptions, realCustomTriggerOptions

  ---------------------------------------------------------------------------------------------------------------
  -- BuffTrigger2: CreateAuraSpellOptions(options, data, triggernum, size, isExact, isIgnore, prefix, baseOrder, useKey,
  -- optionKey, name, desc, inverse, enabled, onChanged).
  ---------------------------------------------------------------------------------------------------------------
  local spellData = { id = "B", triggers = { { trigger = { type = "aura2", unit = "player", useExactSpellId = true } } } }
  local spellTrigger = spellData.triggers[1].trigger
  local spellOptions = {}
  optionsPrivate.CreateAuraSpellOptions(spellOptions, spellData, 1, 3, true, false, "spellid", 10, "useExactSpellId", "auraspellids", "NAME", "DESC")
  local first = spellOptions.spellid1
  Same(first.type, "input", "spellid1 type")
  Same(first.width, 1.3, "spellid1 width")
  Same(first.name, "NAME", "spellid1 name")
  Same(first.desc, "DESC", "spellid1 desc")
  Near(first.order, 10.0103, "spellid1 order")
  Same(first.control, "WeakAurasInputFocus", "spellid1 control")
  Same(first.validate, WeakAuras.ValidateNumeric, "spellid1 validate when exact")
  Same(spellOptions.spellidspace2.name, "or", "space name")
  Near(spellOptions.spellidspace2.order, 10.0201, "space order")
  Near(spellOptions.spellidicon2.order, 10.0202, "icon order")
  Same(spellOptions.spellidicon1.control, "WeakAurasIcon", "icon control")
  Same(spellOptions.spellidicon1.width, 0.2, "icon width")
  assert(spellOptions.spellid3 and spellOptions.spellidicon3 and spellOptions.spellidspace3, "size 3 keys")
  Same(spellOptions.spellidspace1, nil, "no space before the first entry")
  Same(first.hidden(), false, "spellid1 visible when exact")
  Same(spellOptions.spellid2.hidden(), true, "spellid2 hidden while 1 empty")
  Take()
  first.set(nil, "123")
  Same(spellTrigger.auraspellids[1], "123", "spellid1 stored")
  Same(Take(), "add:B,thumb:B,update:B", "spellid1 set saves")
  Same(spellOptions.spellid2.hidden(), false, "spellid2 visible after 1 filled")
  Same(spellOptions.spellid3.hidden(), true, "spellid3 hidden while 2 empty")
  Same(first.get(), "123 (Unknown Spell)" .. "\0" .. "123", "spellid1 get")
  spellOptions.spellid2.set(nil, "456")
  Same(table.concat(spellTrigger.auraspellids, ","), "123,456", "spellid2 stored")
  first.set(nil, "")
  Same(table.concat(spellTrigger.auraspellids, ","), "456", "empty value shifts the list")
  Take()
  spellTrigger.useExactSpellId = false
  Same(first.hidden(), true, "hidden when useExactSpellId is false")
  spellTrigger.useExactSpellId = true
  spellTrigger.type = "custom"
  Same(first.hidden(), true, "hidden when not aura2")
  spellTrigger.type = "aura2"

  local enabled = true
  local enabledOptions = {}
  optionsPrivate.CreateAuraSpellOptions(enabledOptions, spellData, 1, 2, true, true, "x", 5, "useExactSpellId", "auraspellids", "n", "d", true, function() return enabled end)
  Same(enabledOptions.xspace2.name, "and", "inverse space name")
  Same(enabledOptions.x1.hidden(), false, "enabled shows 1")
  Same(enabledOptions.x2.hidden(), false, "enabled shows 2")
  enabled = false
  Same(enabledOptions.x1.hidden(), true, "disabled hides 1")

  local changed = 0
  local changedOptions = {}
  optionsPrivate.CreateAuraSpellOptions(changedOptions, spellData, 1, 2, true, false, "y", 5, "useExactSpellId", "auraspellids", "n", "d", false, nil, function() changed = changed + 1 end)
  Same(changedOptions.yspace2.name, "or", "non inverse space name")
  Take()
  changedOptions.y1.set(nil, "77")
  Same(changed, 1, "onChanged called")
  Same(Take(), "", "onChanged replaces Add/UpdateThumbnail/ClearAndUpdateOptions")
  Same(spellTrigger.auraspellids[1], "77", "onChanged value stored")

  ---------------------------------------------------------------------------------------------------------------
  -- SubRegionCommon: AddUpDownDeleteDuplicate(options, parentData, index, subType).
  ---------------------------------------------------------------------------------------------------------------
  local function SubData(triggerType)
    return { id = "P", uid = "P", regionType = "icon", triggers = { { trigger = { type = triggerType, unit = "player" } } },
      subRegions = { { type = "subbackground" }, { type = "subtext", tag = "A" }, { type = "subtext", tag = "B" }, { type = "subtext", tag = "C" } },
      conditions = { { check = {}, changes = { { property = "sub.2.text_color" } } } } }
  end
  local function Tags(data)
    local list = {}
    for i, sub in ipairs(data.subRegions) do list[i] = sub.tag or sub.type end
    return table.concat(list, ",")
  end
  local function Actions(parent, index)
    local actions = {}
    optionsPrivate.AddUpDownDeleteDuplicate(actions, parent, index, "subtext")
    return actions
  end
  local readable = SubData("aura2")
  Actions(readable, 2).__up()
  Same(Tags(readable), "A,subbackground,B,C", "__up moves the sub region")
  Same(readable.conditions[1].changes[1].property, "sub.1.text_color", "__up rewrites the condition property")
  Same(Take(), "add:P,clear:P,update:P", "__up on a readable aura")
  local readableDown = SubData("aura2")
  Actions(readableDown, 2).__down()
  Same(Tags(readableDown), "subbackground,B,A,C", "__down moves the sub region")
  Same(readableDown.conditions[1].changes[1].property, "sub.3.text_color", "__down rewrites the condition property")
  Take()
  local readableDuplicate = SubData("aura2")
  Actions(readableDuplicate, 2).__duplicate()
  Same(Tags(readableDuplicate), "subbackground,A,A,B,C", "__duplicate inserts a copy")
  Take()
  local readableDelete = SubData("aura2")
  Actions(readableDelete, 2).__delete()
  Same(Tags(readableDelete), "subbackground,B,C", "__delete removes the sub region")
  Take()
  local secretParent = SubData("secretAura")
  Actions(secretParent, 2).__up()
  Same(Tags(secretParent), "A,subbackground,B,C", "__up on a secret aura")
  Same(Take(), "add:P,clear:P,queue:P", "__up on a secret aura queues a refresh instead of rebuilding")

  ---------------------------------------------------------------------------------------------------------------
  -- RegionOptions/Group: Modern Aura Group (blizzardFlow) settings.
  ---------------------------------------------------------------------------------------------------------------
  for _, register in ipairs(optionsPrivate.registerRegions or {}) do register() end
  local function GroupOptions(fields)
    local data = { id = "G", uid = "G", regionType = "group", controlledChildren = {} }
    for key, value in pairs(fields or {}) do data[key] = value end
    return private.regionOptions.group.create("G", data)
  end
  local modern = GroupOptions({ blizzardFlow = true, blizzardFlowFrames = "x" })
  Same(modern.group.__title, "Modern Aura Group Settings", "modern group title")
  for _, key in ipairs({ "align_h", "align_v", "distribute_h", "distribute_v", "space_h", "space_v" }) do
    Same(modern.group[key], nil, "modern group has no " .. key)
  end
  Same(modern.position.selfPoint.disabled(), false, "selfPoint enabled with blizzardFlowFrames")
  Same(GroupOptions({ blizzardFlow = true }).position.selfPoint.disabled(), true, "selfPoint disabled without blizzardFlowFrames")
  Same(GroupOptions().group.__title, "Group Settings", "plain group title")
  local plain = GroupOptions()
  for _, key in ipairs({ "align_h", "align_v", "distribute_h", "distribute_v", "space_h", "space_v" }) do
    assert(plain.group[key], "plain group has " .. key)
  end
  assert(plain.group.borderEdge, "plain group has border options")
  local children = { subGroup = { id = "subGroup", controlledChildren = {} }, dynamic = { id = "dynamic", regionType = "dynamicgroup" } }
  WeakAuras.GetData = function(id) return children[id] end
  local withSubGroup = GroupOptions({ controlledChildren = { "subGroup" } })
  Same(withSubGroup.group.align_h, nil, "no align options with a sub group")
  assert(withSubGroup.group.borderEdge, "border options kept with a sub group")
  local withDynamic = GroupOptions({ controlledChildren = { "dynamic" } })
  assert(withDynamic.group.align_h, "align options kept with a dynamic sub group")
  Same(withDynamic.group.borderEdge, nil, "no border options with a dynamic sub group")
  WeakAuras.GetData = realGetData

  ---------------------------------------------------------------------------------------------------------------
  -- CommonOptions: trigger type switch between Aura / Aura (Modern) / custom, and PositionOptions anchors.
  ---------------------------------------------------------------------------------------------------------------
  local typeData = { id = "C", uid = "C", regionType = "icon", triggers = { { trigger = { type = "aura2", unit = "player" } } } }
  local typeOptions = {}
  optionsPrivate.commonOptions.AddCommonTriggerOptions(typeOptions, typeData, 1, true)
  local typeSelect = typeOptions.type
  Same(typeSelect.type, "select", "trigger type select")
  Same(typeSelect.name, "Type", "trigger type name")
  Near(typeSelect.order, 1.1, "trigger type order")
  Same(typeSelect.width, WeakAuras.doubleWidth, "trigger type width")
  Same(typeSelect.get(), "aura2", "trigger type get")
  Near(typeOptions.auraTypeChoice.order, 1.12, "aura choice order")
  Same(typeOptions.auraTypeChoice.hidden(), false, "aura choice visible for aura2")
  local typeTrigger = typeData.triggers[1].trigger
  local function SwitchTo(value)
    Take()
    typeSelect.set(nil, value)
    return Take()
  end
  Same(SwitchTo("secretAura"), "queue:C,resolve:1,save:1,thumb:C", "aura2 to secretAura")
  Same(typeTrigger.auraTracking, "native", "secretAura tracking")
  Same(typeOptions.auraTypeChoice.hidden(), false, "aura choice visible for secretAura")
  Same(SwitchTo("aura2"), "queue:C,resolve:1,save:1,thumb:C", "secretAura to aura2")
  Same(typeTrigger.auraTracking, "readable", "aura2 tracking")
  Same(SwitchTo("custom"), "save:1,thumb:C,update:C", "aura2 to custom")
  Same(typeTrigger.auraTracking, nil, "custom has no tracking")
  Same(typeOptions.auraTypeChoice.hidden(), true, "aura choice hidden for custom")
  Same(SwitchTo("secretAura"), "queue:C,save:1,thumb:C", "custom to secretAura")
  Same(typeTrigger.auraTracking, "native", "secretAura tracking from custom")
  Same(SwitchTo("custom"), "queue:C,save:1,thumb:C", "secretAura to custom")

  local function AnchorHidden(fields, group)
    local data = { id = "A", uid = "A", regionType = fields.regionType or "icon", controlledChildren = fields.controlledChildren,
      anchorFrameType = fields.anchorFrameType or "SCREEN", blizzardFlow = fields.blizzardFlow, blizzardFlowFrames = fields.blizzardFlowFrames,
      useAnchorPerUnit = fields.useAnchorPerUnit, triggers = { { trigger = { type = "aura2" } } } }
    local position = optionsPrivate.commonOptions.PositionOptions("A", data, nil, false, nil, group)
    return position.anchorFrameType.hidden(), position.anchorFrameParent.hidden(), position.anchorFrameSpaceOne.hidden()
  end
  local frameType, frameParent, spaceOne = AnchorHidden({ regionType = "group", controlledChildren = {}, blizzardFlow = true, blizzardFlowFrames = "x" }, true)
  Same(frameType, true, "modern group with frames: anchor type hidden")
  Same(frameParent, false, "modern group with frames: anchor parent visible")
  frameType, frameParent = AnchorHidden({ regionType = "group", controlledChildren = {}, blizzardFlow = true }, true)
  Same(frameType, false, "modern group without frames: anchor type visible")
  Same(frameParent, true, "modern group without frames: anchor parent hidden")
  frameType, frameParent = AnchorHidden({ regionType = "dynamicgroup", controlledChildren = {}, useAnchorPerUnit = true }, true)
  Same(frameType, true, "dynamic group per unit: anchor type hidden")
  Same(frameParent, false, "dynamic group per unit: anchor parent visible")
  frameType, frameParent, spaceOne = AnchorHidden({}, false)
  Same(frameType, false, "icon: anchor type visible")
  Same(frameParent, true, "icon: anchor parent hidden")
  Same(spaceOne, false, "icon: anchor space visible")
  frameType, frameParent, spaceOne = AnchorHidden({ anchorFrameType = "SELECTFRAME" }, false)
  Same(frameType, false, "icon on a frame: anchor type visible")
  Same(not frameParent, true, "icon on a frame: anchor parent visible")
  Same(spaceOne, true, "icon on a frame: anchor space hidden")

  ---------------------------------------------------------------------------------------------------------------
  -- DisplayOptions: "Add Detached Text / Texture" for Aura (Modern) and the swipe color of a group of icons.
  ---------------------------------------------------------------------------------------------------------------
  local realRegionOptions, realSubRegionOptions = private.regionOptions, private.subRegionOptions
  private.regionOptions = { icon = { create = function() return { icon = { __order = 1 } } end } }
  private.subRegionOptions = {}
  optionsPrivate.GetSecretAuraSettings = function() return { marker = { type = "description", name = "marker", order = 1 }, __order = 2 } end
  optionsPrivate.PrepareSecretDisplayOptions = function() end
  local function DisplayData(triggerType, id)
    return { id = id or "D", uid = id or "D", regionType = "icon", subRegions = {}, anchorFrameType = "SCREEN", cooldown = true,
      triggers = { { trigger = { type = triggerType, unit = "player", auraspellids = { "1" } } } } }
  end
  local secretDisplay = DisplayData("secretAura")
  local display = optionsPrivate.GetDisplayOptions(secretDisplay)
  Same(display.type, "group", "display type")
  Same(display.name, "Display", "display name")
  Same(display.order, 10, "display order")
  local detachedText = display.args["sub.subtextDetached"]
  Same(detachedText.type, "execute", "detached text type")
  Same(detachedText.name, "Add Detached Text", "detached text name")
  Same(display.args["sub.subtextureDetached"].name, "Add Detached Texture", "detached texture name")
  Same(display.args["sub.subtext"].name, "Add Text", "add text name")
  Same(display.args["sub.subglow"].name, "Add Glow", "add glow name")
  Take()
  detachedText.func()
  Same(Take(), "add:D,clear:D,queue:D", "detached text click")
  Same(#secretDisplay.subRegions, 1, "detached text added")
  Same(secretDisplay.subRegions[1].type, "subtext", "detached text type")
  Same(secretDisplay.subRegions[1].secretAuraDetached, true, "detached text flag")
  Same(secretDisplay.subRegions[1].text_text, "Text", "detached text default text")
  Same(display.get({ "sub.1.subtext.text_text", type = "input" }), "Text", "display get on an existing sub region")
  table.remove(secretDisplay.subRegions, 1)
  local okGet, valueGet = pcall(display.get, { "sub.1.subtext.text_text", type = "input" })
  assert(okGet, "display get after the sub region is removed: " .. tostring(valueGet))
  Same(valueGet, nil, "display get after the sub region is removed")
  local okColor, red, green, blue, alpha = pcall(display.get, { "sub.1.subtext.text_color", type = "color" })
  assert(okColor, "display color get after the sub region is removed: " .. tostring(red))
  Same(red .. green .. blue .. alpha, "1111", "display color get falls back to 1")
  local glowDisplay = DisplayData("secretAura")
  optionsPrivate.GetDisplayOptions(glowDisplay).args["sub.subglow"].func()
  Same(glowDisplay.subRegions[1].type, "subglow", "glow type")
  Same(glowDisplay.subRegions[1].glowType, "Proc", "glow type on Aura (Modern)")
  Same(glowDisplay.subRegions[1].secretAuraDetached, nil, "glow is not detached")
  Take()
  local readableDisplay = DisplayData("aura2")
  local readableArgs = optionsPrivate.GetDisplayOptions(readableDisplay).args
  Same(readableArgs["sub.subtextDetached"], nil, "no detached text on a readable aura")
  Same(readableArgs["sub.subtextureDetached"], nil, "no detached texture on a readable aura")
  readableArgs["sub.subtexture"].func()
  Same(Take(), "add:D,clear:D,update:D", "texture click on a readable aura")

  local realGetDataForGroup = WeakAuras.GetData
  local groupChildren = { C1 = DisplayData("secretAura", "C1"), C2 = DisplayData("secretAura", "C2") }
  WeakAuras.GetData = function(id) return groupChildren[id] or realGetDataForGroup(id) end
  local groupDisplay = optionsPrivate.GetDisplayOptions({ id = "GG", uid = "GG", regionType = "group", controlledChildren = { "C1", "C2" } })
  assert(groupDisplay.args["secretAura.marker"], "group of secret icons shows the secret aura settings")
  local swipe = groupDisplay.args["icon.secretSwipeColor"]
  assert(swipe, "group of secret icons has a swipe color")
  Same(swipe.type, "color", "swipe type")
  Same(swipe.hasAlpha, true, "swipe alpha")
  Same(swipe.width, 1.3, "swipe width")
  WeakAuras.GetData = realGetDataForGroup
  private.regionOptions, private.subRegionOptions = realRegionOptions, realSubRegionOptions

  ---------------------------------------------------------------------------------------------------------------
  -- ConditionOptions: native Aura (Modern) duration / dispel operators and the "if" select.
  ---------------------------------------------------------------------------------------------------------------
  local realGetTriggerConditions = private.GetTriggerConditions
  private.GetTriggerConditions = function()
    return { [1] = {
      faAuraRemaining = { display = "Remaining Time", type = "number", operator_types = "native_aura_duration" },
      faAuraDispel = { display = "Dispel Type", type = "select", operator_types = "native_aura_dispel", values = { Magic = "Magic", Curse = "Curse" } },
      faAuraApplications = { display = "Stack Count", type = "number" },
      faAuraHighlightStyle = { display = "Style", type = "select", values = { border = "Border" } },
    } }
  end
  local function ConditionData(triggerType)
    return { id = "CD", uid = "CD", regionType = "icon", cooldown = true, width = 64, height = 64, anchorFrameType = "SCREEN",
      actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      triggers = { { trigger = { type = triggerType, unit = "player", debuffType = "HELPFUL", auraspellids = { "1" } }, untrigger = {} } },
      conditions = {
        { check = { trigger = 1, variable = "faAuraRemaining", op = "<", value = "5" }, changes = { { property = "faAuraHighlightStyle", value = "border" } } },
        { check = { trigger = 1, variable = "faAuraDispel", op = "==", value = "Magic" }, changes = {} },
      } }
  end
  local conditionData = ConditionData("secretAura")
  local conditionArgs = optionsPrivate.GetConditionOptions(conditionData).args
  local durationOperator = Find(conditionArgs, "^condition1T_op$")
  local dispelOperator = Find(conditionArgs, "^condition2T_op$")
  Same(durationOperator.type, "select", "duration operator type")
  Same(Dump(durationOperator.values), "<=<;>==>=", "duration operator values")
  Same(durationOperator.get(), "<", "duration operator get")
  Same(durationOperator.width, 0.65, "duration operator width")
  Same(dispelOperator.type, "select", "dispel operator type")
  Same(Dump(dispelOperator.values), "====;~==!=", "dispel operator values")
  Same(dispelOperator.get(), "==", "dispel operator get")
  Same(dispelOperator.width, 1.3, "dispel operator width")
  Same(Find(conditionArgs, "^condition2_else$"), nil, "no else for a native condition")
  Same(Find(conditionArgs, "^condition1_else$"), nil, "no else on condition 1")
  local ifSelect = Find(conditionArgs, "^condition1Tif$")
  Same(ifSelect.values and true, true, "if select values")
  local function IfIndex(label)
    for index, text in pairs(ifSelect.values) do
      if text:find(label, 1, true) then return index end
    end
  end
  Same(ifSelect.values[IfIndex("Trigger 1: Aura (Modern)")], "Trigger 1: Aura (Modern)", "if select trigger label")
  assert(IfIndex("Dispel Type") and IfIndex("Remaining Time") and IfIndex("Stack Count") and IfIndex("Style"), "if select variables")
  local function SetIf(label)
    local data = ConditionData("secretAura")
    data.conditions[1].linked = true
    data.conditions[2].linked = true
    local args = optionsPrivate.GetConditionOptions(data).args
    local select = Find(args, "^condition1Tif$")
    local index
    for i, text in pairs(select.values) do
      if text:find(label, 1, true) then index = i end
    end
    select.set(nil, index)
    return data
  end
  local dispel = SetIf("Dispel Type")
  Same(dispel.conditions[1].check.variable, "faAuraDispel", "if dispel variable")
  Same(dispel.conditions[1].check.op, "==", "if dispel op")
  Same(dispel.conditions[1].linked, false, "if dispel unlinks")
  Same(dispel.conditions[1].changes[1].property, "faAuraHighlightStyle", "if dispel keeps the change")
  local remaining = SetIf("Remaining Time")
  Same(remaining.conditions[1].check.variable, "faAuraRemaining", "if remaining variable")
  Same(remaining.conditions[1].check.op, "<", "if remaining op")
  Same(remaining.conditions[1].linked, false, "if remaining unlinks condition 1")
  Same(remaining.conditions[2].linked, false, "if remaining unlinks condition 2")
  Same(remaining.conditions[1].changes[1].property, nil, "if remaining clears the change property")
  local stack = SetIf("Stack Count")
  Same(stack.conditions[1].check.variable, "faAuraApplications", "if stack variable")
  Same(stack.conditions[1].changes[1].property, nil, "if stack clears the change property")
  Same(stack.conditions[1].linked, false, "if stack unlinks")
  local customArgs = optionsPrivate.GetConditionOptions(ConditionData("custom")).args
  assert(Find(customArgs, "^condition2_else$"), "else shown for a custom trigger condition")
  Same(Find(customArgs, "^condition1_else$"), nil, "no else on condition 1 with a custom trigger")
  private.GetTriggerConditions = realGetTriggerConditions

  ---------------------------------------------------------------------------------------------------------------
  -- ConditionOptions: a group shows its own conditions above the merged ones of its children.
  ---------------------------------------------------------------------------------------------------------------
  local child = ConditionData("custom")
  child.parent = "G"
  local group = { id = "G", uid = "G", regionType = "group", controlledChildren = { "CD" }, triggers = {},
    actions = { start = {}, finish = {}, init = {} }, subRegions = {}, alpha = 1,
    conditions = { { check = { trigger = -1, variable = "incombat", value = 1 }, changes = { { property = "alpha", value = 0.3 } } } } }
  local realGetDataForConditions = WeakAuras.GetData
  WeakAuras.GetData = function(id) return id == "CD" and child or realGetDataForConditions(id) end
  local groupArgs = optionsPrivate.GetConditionOptions(group).args
  assert(groupArgs.groupConditionsTitle and groupArgs.childrenConditionsTitle, "group and children headers")
  assert(groupArgs.groupConditionsTitle.order < groupArgs.groupaddCondition.order
    and groupArgs.groupaddCondition.order < groupArgs.childrenConditionsTitle.order
    and groupArgs.childrenConditionsTitle.order < groupArgs.addCondition.order, "group section above the children")
  assert(Find(groupArgs, "^groupcondition1"), "own condition of the group")
  assert(Find(groupArgs, "^condition2"), "merged conditions of the children")
  Take()
  groupArgs.groupaddCondition.func()
  Same(#group.conditions, 2, "condition added to the group")
  Same(#child.conditions, 2, "child conditions untouched")
  Same(Take(), "add:G,clear:G,update:G", "add on the group only")
  WeakAuras.GetData = realGetDataForConditions

  WeakAuras.Add, WeakAuras.UpdateThumbnail, WeakAuras.ClearAndUpdateOptions = realAdd, realUpdateThumbnail, realClearAndUpdate
end

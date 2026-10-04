if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local pendingRefresh

local function flushPendingRefresh()
  local requests = pendingRefresh
  pendingRefresh = nil
  for auraId in pairs(requests) do
    WeakAuras.ClearAndUpdateOptions(auraId)
  end
  WeakAuras.FillOptions()
end

OptionsPrivate.QueueOptionsRefresh = function(id)
  local queue = pendingRefresh
  if not queue then
    queue = {}
    pendingRefresh = queue
    C_Timer.After(0, flushPendingRefresh)
  end
  queue[id] = true
end

local SINGLE_AURA_NOTICE = "The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match."

local function readSettings(data)
  return data.blizzardAuraDisplay or {}
end

local function writeSetting(data, key, value, quiet)
  data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
  data.blizzardAuraDisplay[key] = value
  WeakAuras.Add(data)
  if not quiet then
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
end

local function writeTriggerSetting(data, display, mutate)
  local trigger = display.GetSavedTrigger(data)
  if not trigger then return end
  mutate(trigger)
  WeakAuras.Add(data)
  OptionsPrivate.QueueOptionsRefresh(data.id)
end

local function describeSortOptions(data, display)
  local function inactive() return not display.Enabled(data) end
  return {
    sortMethod = {
      type = "select", name = "Sort by", disabled = inactive, values = display.sortMethods,
      sorting = {
        "Default", "ExpirationOnly", "Expiration", "NameOnly", "Name",
        "ImportantOnly", "BigDefensive", "UnitFrameDebuff", "AuraInstanceIDOnly",
      },
      desc = "Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras.",
      get = function()
        local trigger = display.GetSavedTrigger(data)
        return trigger and trigger.sortMethod or "Default"
      end,
      set = function(_, value)
        writeTriggerSetting(data, display, function(trigger)
          local classification = trigger.processedAuraType
          if value == "UnitFrameDebuff" and classification ~= "Debuff" and classification ~= "Dispel" then
            trigger.processedAuraType = "Debuff"
          end
          trigger.sortMethod = value
        end)
      end,
    },
    sortReverse = {
      type = "toggle", name = "Reverse Sort", disabled = inactive,
      desc = "Reverse the selected order. For Remaining time, later expirations and permanent auras come first.",
      get = function()
        local trigger = display.GetSavedTrigger(data)
        return trigger and trigger.sortReverse or false
      end,
      set = function(_, value)
        writeTriggerSetting(data, display, function(trigger) trigger.sortReverse = value end)
      end,
    },
  }
end

local function describeLayoutOptions(data, display)
  local function unavailable()
    if display.DrawsOne(data) then return true end
    return not display.Enabled(data)
  end
  return {
    growth = {
      type = "select", name = "Aura growth direction", disabled = unavailable,
      values = {
        RIGHT = "Right", LEFT = "Left", UP = "Up", DOWN = "Down",
        CENTER_HORIZONTAL = "Centered Horizontal", CENTER_VERTICAL = "Centered Vertical",
      },
      get = function() return readSettings(data).growth or "RIGHT" end,
      set = function(_, value) writeSetting(data, "growth", value) end,
    },
    spacing = {
      type = "range", name = "Aura spacing", min = 0, max = 40, step = 1, disabled = unavailable,
      get = function() return readSettings(data).spacing or 6 end,
      set = function(_, value) writeSetting(data, "spacing", value, true) end,
    },
    maxIcons = {
      type = "range", name = "Maximum auras", min = 1, softMax = 40, step = 1, disabled = unavailable,
      desc = "Maximum auras per unit. Drag up to 40, or type a larger number.",
      get = function() return readSettings(data).maxIcons or 10 end,
      set = function(_, value) writeSetting(data, "maxIcons", value, true) end,
    },
  }
end

OptionsPrivate.GetSecretAuraSettings = function(data)
  local display = OptionsPrivate.Private.BlizzardAuraDisplay
  local sorting = describeSortOptions(data, display)
  local layout = describeLayoutOptions(data, display)
  local entries = {
    status = {
      type = "description", width = "full",
      name = function() return display.Validate(data) or "" end,
      hidden = function() return display.Validate(data) == nil end,
    },
    singleNotice = {
      type = "description", width = "full", fontSize = "small",
      name = function()
        if display.InDynamicGroup(data) then return display.dynamicGroupWarning end
        return SINGLE_AURA_NOTICE
      end,
      hidden = function() return not (display.DrawsOne(data) or display.InDynamicGroup(data)) end,
    },
    growth = layout.growth,
    spacing = layout.spacing,
    maxIcons = layout.maxIcons,
    sortMethod = sorting.sortMethod,
    sortReverse = sorting.sortReverse,
    textHeight = {
      type = "range", name = "Text Area Height", min = 4, softMax = 300, step = 1,
      desc = "Space reserved for each aura's text. Set its width in Font Flags.",
      hidden = function() return data.regionType ~= "text" end,
      get = function() return readSettings(data).textHeight or (data.fontSize or 18) * 1.2 end,
      set = function(_, value) writeSetting(data, "textHeight", value, true) end,
    },
  }
  local args = {__title = "Aura (Modern) Settings", __order = 8, __collapsed = true}
  local sequence = {"status", "singleNotice", "growth", "spacing", "maxIcons", "sortMethod", "sortReverse", "textHeight"}
  for position, key in ipairs(sequence) do
    local entry = entries[key]
    entry.order = position
    entry.width = entry.width or WeakAuras.normalWidth
    args[key] = entry
  end
  return args
end

local UNSUPPORTED_DISPLAY_KEYS = {}
for key in ([[useTooltip toolTipArea useCooldownModRate iconInset useMasque smoothProgress enableGradient
gradientOrientation barColor2 spark sparkTexture sparkChooseTexture sparkDesaturate sparkColor sparkBlendMode
sparkWidth sparkHeight sparkOffsetX sparkOffsetY sparkRotationMode sparkRotation sparkMirror sparkHidden
customTextUpdate text_customTextUpdate text_customTextUpdateThrottle text_smoothScaling smoothScaling rotateText
glowStartAnim slanted slant slantFirst slantMode]]):gmatch("%S+") do
  UNSUPPORTED_DISPLAY_KEYS[key] = true
end

local SUPPORTED_TIME_FIELDS = {
  p_format = true, p_time_format = true, p_time_precision = true,
  p_time_dynamic_threshold = true, p_time_legacy_floor = true,
}

local function addSwipeColorOption(data, iconGroup)
  iconGroup.secretSwipeColor = {
    type = "color", name = "Swipe Color", hasAlpha = true, order = 11.9, width = WeakAuras.normalWidth,
    hidden = function() return not data.cooldown end,
    get = function()
      local saved = (data.blizzardAuraDisplay or {}).swipeColor
      return unpack(saved or {0, 0, 0, 0.8})
    end,
    set = function(_, red, green, blue, alpha)
      data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
      data.blizzardAuraDisplay.swipeColor = {red, green, blue, alpha}
      WeakAuras.Add(data)
    end,
  }
end

local function filterAnchorPoints(option)
  local kept = {}
  for point, title in pairs(option.values) do
    if not point:find("%.") and (point:match("^[A-Z_]+$")) then
      kept[point] = title
    end
  end
  option.values = kept
end

local DISPLAY_KEY_HANDLERS = {
  iconSource = function(option)
    option.values = {[-1] = "Automatic", [0] = "Manual"}
  end,
  automaticWidth = function(option)
    option.values = {Fixed = "Fixed"}
    option.desc = "Native aura layout uses a fixed text area."
  end,
  glowType = function(option)
    option.values = {
      buttonOverlay = "Action Button Glow", Pixel = "Pixel Glow", ACShine = "Autocast Shine", Proc = "Proc Glow",
    }
  end,
  anchor_area = function(option, data)
    if data.regionType == "aurabar" then
      option.values = {ALL = "Whole Area", bar = "Bar", icon = "Icon"}
    else
      option.values = {ALL = "Whole Area"}
    end
  end,
  anchor_point = function(option)
    if type(option.values) == "table" then filterAnchorPoints(option) end
  end,
  text_text = function(option)
    option.desc = "Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported."
  end,
}
DISPLAY_KEY_HANDLERS.displayText = DISPLAY_KEY_HANDLERS.text_text

local function restrictTextFormat(key, option)
  local formatKey = key:match("^text_text_format_(.+)$") or key:match("^displayText_format_(.+)$")
  if not formatKey then return end
  if not SUPPORTED_TIME_FIELDS[formatKey] and not formatKey:match("^footer") then
    if option.type ~= "execute" and option.type ~= "description" then
      option.disabled = true
      option.desc = "Not supported by native aura text."
    end
  elseif formatKey == "p_format" then
    option.values = {timed = "Time Format"}
  elseif formatKey == "p_time_format" then
    option.values = {[-1] = "Blizzard Default", [0] = "Minutes and seconds", [-2] = "Seconds"}
  end
end

local function restrictDisplayOption(data, isBorderGroup, key, option)
  if isBorderGroup and key == "border_ppscale" then
    option.disabled = false
    option.desc = "Keep border thickness and offset in screen pixels, regardless of UI or parent scale. Use a size of 1 for a one-pixel border."
  elseif UNSUPPORTED_DISPLAY_KEYS[key] then
    option.disabled = true
    option.desc = "Not supported by Blizzard's native aura display."
  else
    local handler = DISPLAY_KEY_HANDLERS[key]
    if handler then handler(option, data) end
  end
  restrictTextFormat(key, option)
end

local function markDetachedGroup(group)
  group.__title = "Detached " .. group.__title
  if group.text_text then
    group.text_text.desc = "Hardcoded text. Use Conditions from other triggers to show, hide or change this message."
  end
  if group.text_text_pChoose then
    group.text_text_pChoose.disabled = true
  end
end

local function restrictDisplayGroup(data, display, groupKey, group)
  local index = tonumber(groupKey:match("^sub%.(%d+)%."))
  local detached = index and display.IsDetachedElement(data, data.subRegions and data.subRegions[index])
  if detached then
    markDetachedGroup(group)
  end
  local isBorderGroup = groupKey:match("%.subborder$")
  if isBorderGroup then
    group.__duplicate = nil
  end
  if detached or groupKey == "secretAura" or groupKey == "position" then return end
  for key, option in pairs(group) do
    if type(option) == "table" and option.type then
      restrictDisplayOption(data, isBorderGroup, key, option)
    end
  end
end

OptionsPrivate.PrepareSecretDisplayOptions = function(data, groups)
  local display = OptionsPrivate.Private.BlizzardAuraDisplay
  if not display.Enabled(data) then return end
  if display.FlowGroup(data) then
    groups.secretAura = nil
  else
    groups.secretAura = OptionsPrivate.GetSecretAuraSettings(data) or nil
  end
  if groups.icon and data.regionType == "icon" then
    addSwipeColorOption(data, groups.icon)
  end
  groups.progressOptions = nil
  for groupKey, group in pairs(groups) do
    restrictDisplayGroup(data, display, groupKey, group)
  end
end

local SUPPORTED_ACTION_FIELDS = {
  header = true, do_sound = true, sound = true, sound_channel = true,
  sound_path = true, sound_fojji = true, hide_all_glows = true,
}

local function restrictActionOption(data, when, field, option)
  if field == "do_message" or field:match("^message") then
    option.disabled = true
    option.desc = "Blizzard controls aura visibility. Use a condition from another trigger to send chat messages."
  elseif field == "stop_sound" or field == "do_sound_fade" or field:match("^stop_sound_fade") then
    option.hidden = true
  elseif not SUPPORTED_ACTION_FIELDS[field] then
    option.disabled = function()
      return option.type ~= "toggle" or not (data.actions[when] or {})[field]
    end
    option.desc = "Not available for secret aura On Show/On Hide. Sound files are supported; live TTS and custom callbacks are not."
  elseif field == "sound" then
    local choices = {}
    for value, title in pairs(OptionsPrivate.Private.sound_types) do
      if value ~= " KitID" then choices[value] = title end
    end
    choices[" Fojji"] = "FojjiCore recorded voice"
    option.values = choices
    option.sorting = OptionsPrivate.Private.SortOrderForValues(choices)
  end
end

local function makeGlowPaddingOption(extra)
  local option = {
    type = "range", control = "WeakAurasSpinBox", name = "Padding", order = 10.865,
    min = 0, max = 40, step = 1, width = WeakAuras.normalWidth,
  }
  if extra then
    for key, value in pairs(extra) do option[key] = value end
  end
  return option
end

local function prepareGroupActionOptions(data, action)
  local display = OptionsPrivate.Private.BlizzardAuraDisplay
  for child in OptionsPrivate.Private.TraverseLeafs(data) do
    if display.Enabled(child) then
      action.args.start_glow_type.values = {Proc = "Proc Glow", buttonOverlay = "Pulse Glow"}
      action.args.start_glow_padding = action.args.start_glow_padding or makeGlowPaddingOption()
      break
    end
  end
end

local UNIT_GLOW_FIELDS = {
  glow_type = {
    key = "unitGlowType", default = "proc",
    read = function(value) return value == "pulse" and "buttonOverlay" or "Proc" end,
    write = function(value) return value == "buttonOverlay" and "pulse" or "proc" end,
  },
  use_glow_color = {key = "unitUseGlowColor", default = true},
  glow_color = {
    key = "unitGlowColor", default = {1, 0.82, 0, 1}, usesColor = true,
    read = function(value) return unpack(value) end,
    write = function(red, green, blue, alpha) return {red, green, blue, alpha} end,
  },
  glow_duration = {key = "unitGlowDuration", default = 1},
  glow_XOffset = {key = "unitGlowX", default = 0},
  glow_YOffset = {key = "unitGlowY", default = 0},
}

local function prepareUnitGlowOptions(data, args, settings)
  local function saveGlow(key, value)
    settings[key] = value
    WeakAuras.Add(data)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
  local function glowHidden()
    return data.anchorFrameType ~= "UNITFRAME" or not settings.unitGlow
  end

  for key, option in pairs(args) do
    if key:match("^start_glow_") or key == "start_choose_glow_frame" or key == "start_use_glow_color" then
      option.hidden = true
    end
  end

  local toggle = args.start_do_glow
  toggle.name = "Glow Anchored Unit Frame"
  toggle.desc = "Use Unit Frames anchoring in Display. The frame glows while any aura matches your filters and stops automatically. Exact Spell IDs are not required."
  toggle.disabled = function()
    return data.anchorFrameType ~= "UNITFRAME" and not data.actions.start.do_glow
  end
  toggle.get = function() return settings.unitGlow or data.actions.start.do_glow or false end
  toggle.set = function(_, value)
    data.actions.start.do_glow = nil
    saveGlow("unitGlow", value)
  end

  for field, spec in pairs(UNIT_GLOW_FIELDS) do
    local option = args["start_" .. field]
    local key, default, read, write = spec.key, spec.default, spec.read, spec.write
    local usesColor = spec.usesColor == true
    option.hidden = glowHidden
    option.disabled = function()
      return not settings.unitGlow or (usesColor and settings.unitUseGlowColor == false)
    end
    option.desc = "Style the glow on the anchored unit frame."
    option.get = function()
      local value = settings[key]
      if value == nil then value = default end
      if read then return read(value) end
      return value
    end
    option.set = function(_, value, green, blue, alpha)
      if write then value = write(value, green, blue, alpha) end
      saveGlow(key, value)
    end
  end

  args.start_glow_type.values = {Proc = "Proc Glow", buttonOverlay = "Pulse Glow"}
  args.start_glow_duration.name = "Animation Duration"
  args.start_glow_padding = makeGlowPaddingOption({
    desc = "Extra space around the unit frame. Zero follows its edges.",
    hidden = glowHidden,
    disabled = function() return not settings.unitGlow end,
    get = function() return settings.unitGlowPadding or 0 end,
    set = function(_, value) saveGlow("unitGlowPadding", value) end,
  })
end

OptionsPrivate.PrepareSecretActionOptions = function(data, action)
  if data.controlledChildren then
    prepareGroupActionOptions(data, action)
    return
  end
  local display = OptionsPrivate.Private.BlizzardAuraDisplay
  if not display.Enabled(data) then return end

  for key, option in pairs(action.args) do
    local when, field = key:match("^(%a+)_(.+)$")
    if (when == "start" or when == "finish") and option.type ~= "header" then
      restrictActionOption(data, when, field, option)
    end
  end

  local soundDescriptions = {start = "added", finish = "removed"}
  for _, when in ipairs({"start", "finish"}) do
    action.args[when .. "_do_sound"].desc = "Play when one of the trigger's exact spell IDs is " .. soundDescriptions[when] .. ". Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds."
  end

  prepareUnitGlowOptions(data, action.args, data.blizzardAuraDisplay)

  action.args.secretSoundNotice = {
    type = "description", order = 0, width = "full",
    name = "|cffff2020Blizzard-controlled aura display: only supported actions are available.|r",
  }
end

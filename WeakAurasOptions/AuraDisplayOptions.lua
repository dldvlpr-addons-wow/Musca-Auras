-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

-- OptionsPrivate.Private is only set once the options addon is opened, so resolve it per call.
local function Display()
  return OptionsPrivate.Private.BlizzardAuraDisplay
end

local function Identity(value)
  return value
end

local function BuildSet(keys)
  local set = {}
  for _, key in ipairs(keys) do set[key] = true end
  return set
end

--------------------------------------------------------------------------------
-- Deferred options refresh
--------------------------------------------------------------------------------

-- Ids awaiting a refresh, in request order, with a lookup to skip duplicates.
local refreshQueue, refreshQueued = {}, {}

local function FlushOptionsRefresh()
  local batch = refreshQueue
  refreshQueue, refreshQueued = {}, {}
  for _, id in ipairs(batch) do
    WeakAuras.ClearAndUpdateOptions(id)
  end
  WeakAuras.FillOptions()
end

function OptionsPrivate.QueueOptionsRefresh(id)
  if refreshQueued[id] then return end
  if #refreshQueue == 0 then
    C_Timer.After(0, FlushOptionsRefresh)
  end
  refreshQueued[id] = true
  refreshQueue[#refreshQueue + 1] = id
end

--------------------------------------------------------------------------------
-- Saved display settings (data.blizzardAuraDisplay), re-read on every access
--------------------------------------------------------------------------------

local noSettings = {}

local function ReadSettings(data)
  return data.blizzardAuraDisplay or noSettings
end

local function SettingValue(data, key, default)
  local value = ReadSettings(data)[key]
  if value == nil then return default end
  return value
end

local function WriteSetting(data, key, value, refresh)
  data.blizzardAuraDisplay = data.blizzardAuraDisplay or {}
  data.blizzardAuraDisplay[key] = value
  WeakAuras.Add(data)
  if refresh then
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
end

local colorCodec = {
  decode = unpack,
  encode = function(r, g, b, a) return { r, g, b, a } end,
}

-- Adds get/set bound to one saved setting; the codec converts between saved and displayed values.
local function BindSetting(option, data, key, default, refresh, codec)
  local decode = codec and codec.decode or Identity
  local encode = codec and codec.encode or Identity
  option.get = function() return decode(SettingValue(data, key, default)) end
  option.set = function(_, ...) WriteSetting(data, key, encode(...), refresh) end
  return option
end

-- Sort settings live on the saved secretAura trigger, not on the display settings.
local function BindTriggerSetting(option, data, key, default)
  option.get = function()
    local trigger = Display().GetSavedTrigger(data)
    local value = trigger and trigger[key]
    if value == nil then return default end
    return value
  end
  option.set = function(_, value)
    local trigger = Display().GetSavedTrigger(data)
    if not trigger then return end
    if key == "sortMethod" and value == "UnitFrameDebuff"
      and trigger.processedAuraType ~= "Debuff" and trigger.processedAuraType ~= "Dispel" then
      trigger.processedAuraType = "Debuff"
    end
    trigger[key] = value
    WeakAuras.Add(data)
    OptionsPrivate.QueueOptionsRefresh(data.id)
  end
  return option
end

--------------------------------------------------------------------------------
-- "Aura (Modern) Settings" panel
--------------------------------------------------------------------------------

local growthValues = {
  RIGHT = L["Right"],
  LEFT = L["Left"],
  UP = L["Up"],
  DOWN = L["Down"],
  CENTER_HORIZONTAL = L["Centered Horizontal"],
  CENTER_VERTICAL = L["Centered Vertical"],
}

local sortMethodOrder = {
  "Default", "ExpirationOnly", "Expiration", "NameOnly", "Name",
  "ImportantOnly", "BigDefensive", "UnitFrameDebuff", "AuraInstanceIDOnly",
}

local singleAuraNotice = L["The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match."]

function OptionsPrivate.GetSecretAuraSettings(data)
  local function Inactive()
    return not Display().Enabled(data)
  end
  local function Unavailable()
    return Display().DrawsOne(data) or Inactive()
  end

  local entries = {
    { "status", {
      type = "description",
      width = "full",
      name = function() return Display().Validate(data) or "" end,
      hidden = function() return Display().Validate(data) == nil end,
    } },
    { "singleNotice", {
      type = "description",
      width = "full",
      fontSize = "small",
      name = function()
        return Display().InDynamicGroup(data) and Display().dynamicGroupWarning or singleAuraNotice
      end,
      hidden = function() return not (Display().DrawsOne(data) or Display().InDynamicGroup(data)) end,
    } },
    { "growth", BindSetting({
      type = "select",
      name = L["Aura growth direction"],
      values = growthValues,
      disabled = Unavailable,
    }, data, "growth", "RIGHT", true) },
    { "spacing", BindSetting({
      type = "range",
      name = L["Aura spacing"],
      min = 0,
      max = 40,
      step = 1,
      disabled = Unavailable,
    }, data, "spacing", 6, false) },
    { "maxIcons", BindSetting({
      type = "range",
      name = L["Maximum auras"],
      desc = L["Maximum auras per unit. Drag up to 40, or type a larger number."],
      min = 1,
      softMax = 40,
      step = 1,
      disabled = Unavailable,
    }, data, "maxIcons", 10, false) },
    { "sortMethod", BindTriggerSetting({
      type = "select",
      name = L["Sort by"],
      desc = L["Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras."],
      values = Display().sortMethods,
      sorting = sortMethodOrder,
      disabled = Inactive,
    }, data, "sortMethod", "Default") },
    { "sortReverse", BindTriggerSetting({
      type = "toggle",
      name = L["Reverse Sort"],
      desc = L["Reverse the selected order. For Remaining time, later expirations and permanent auras come first."],
      disabled = Inactive,
    }, data, "sortReverse", false) },
    { "textHeight", BindSetting({
      type = "range",
      name = L["Text Area Height"],
      desc = L["Space reserved for each aura's text. Set its width in Font Flags."],
      min = 4,
      softMax = 300,
      step = 1,
      hidden = function() return data.regionType ~= "text" end,
    }, data, "textHeight", nil, false, {
      decode = function(value) return value or (data.fontSize or 18) * 1.2 end,
    }) },
  }

  local args = { __title = L["Aura (Modern) Settings"], __order = 8, __collapsed = true }
  for order, entry in ipairs(entries) do
    local option = entry[2]
    option.order = order
    option.width = option.width or WeakAuras.normalWidth
    args[entry[1]] = option
  end
  return args
end

--------------------------------------------------------------------------------
-- Display options restricted to what Blizzard's native aura display draws
--------------------------------------------------------------------------------

-- Why each option is greyed out, shown in its tooltip.
local progressReason = L["The game fills the bar or the swipe itself and hides the progress from addons: this effect needs to read the progress."]
local customTextReason = L["The game writes this text itself: custom code cannot run on it."]
local notAppliedReason = L["Aura (Modern) does not apply this effect."]
local tooltipReason = L["The Aura (Modern) display ignores the mouse, so it shows no tooltip."]
local unsupportedDisplayReasons = {
  useTooltip = tooltipReason,
  toolTipArea = tooltipReason,
  glowStartAnim = L["The game starts this glow itself, without the start animation."],
  customTextUpdate = customTextReason,
  text_customTextUpdate = customTextReason,
  text_customTextUpdateThrottle = customTextReason,
}
for _, key in ipairs({ "sparkHidden", "slanted", "slant", "slantFirst", "slantMode" }) do
  unsupportedDisplayReasons[key] = progressReason
end
for _, key in ipairs({
  "useCooldownModRate", "iconInset", "smoothProgress", "enableGradient", "gradientOrientation", "barColor2",
  "spark", "sparkTexture", "sparkChooseTexture", "sparkDesaturate", "sparkColor", "sparkBlendMode", "sparkWidth",
  "sparkHeight", "sparkOffsetX", "sparkOffsetY", "sparkRotationMode", "sparkRotation", "sparkMirror", "rotateText",
  "smoothScaling", "text_smoothScaling",
}) do
  unsupportedDisplayReasons[key] = notAppliedReason
end

local supportedFormatSuffixes = BuildSet({
  "p_format", "p_time_format", "p_time_precision", "p_time_dynamic_threshold", "p_time_legacy_floor",
})

local unavailableNoteText = "|cff999999" .. L["Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why."] .. "|r"

local textCodesDesc = L["Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported."]

local function SetTextCodesDesc(option)
  option.desc = textCodesDesc
end

local displayOptionAdjustments = {
  iconSource = function(option)
    option.values = { [-1] = L["Automatic"], [0] = L["Manual"] }
  end,
  automaticWidth = function(option)
    option.values = { Fixed = L["Fixed"] }
    option.desc = L["The game's own aura layout uses a fixed text area."]
  end,
  glowType = function(option)
    option.values = {
      buttonOverlay = L["Action Button Glow"], Pixel = L["Pixel Glow"], ACShine = L["Autocast Shine"], Proc = L["Proc Glow"],
    }
  end,
  anchor_area = function(option, data)
    if data.regionType == "aurabar" then
      option.values = { ALL = L["Whole Area"], bar = L["Bar"], icon = L["Icon"] }
    else
      option.values = { ALL = L["Whole Area"] }
    end
  end,
  anchor_point = function(option)
    if type(option.values) ~= "table" then return end
    local points = {}
    for point, label in pairs(option.values) do
      if type(point) == "string" and point:find("^[A-Z_]+$") then
        points[point] = label
      end
    end
    option.values = points
  end,
  text_text = SetTextCodesDesc,
  displayText = SetTextCodesDesc,
}

local function RestrictTextFormat(suffix, option)
  if suffix == "p_format" then
    option.values = { timed = L["Time Format"] }
  elseif suffix == "p_time_format" then
    option.values = { [-1] = L["Blizzard Default"], [0] = L["Minutes and seconds"], [-2] = L["Seconds"] }
  elseif not supportedFormatSuffixes[suffix] and not suffix:find("^footer")
    and option.type ~= "execute" and option.type ~= "description" then
    option.disabled = true
    option.desc = L["The game writes this value itself: only the time format applies."]
  end
end

local function RestrictDisplayOption(key, option, data, isBorderGroup)
  if isBorderGroup and key == "border_ppscale" then
    option.disabled = false
    option.desc = L["Keep border thickness and offset in screen pixels, regardless of UI or parent scale. Use a size of 1 for a one-pixel border."]
  elseif unsupportedDisplayReasons[key] then
    option.disabled = true
    option.desc = unsupportedDisplayReasons[key]
  elseif displayOptionAdjustments[key] then
    displayOptionAdjustments[key](option, data)
  end
  local formatSuffix = key:match("^text_text_format_(.+)$") or key:match("^displayText_format_(.+)$")
  if formatSuffix then
    RestrictTextFormat(formatSuffix, option)
  end
end

local function DetachedSubRegion(groupKey, data)
  local index = tonumber(groupKey:match("^sub%.(%d+)%."))
  local subRegion = index and data.subRegions and data.subRegions[index]
  return subRegion and Display().IsDetachedElement(data, subRegion)
end

local function MarkDetached(group)
  group.__title = L["Detached %s"]:format(tostring(group.__title))
  if group.text_text then
    group.text_text.desc = L["Hardcoded text. Use Conditions from other triggers to show, hide or change this message."]
  end
  if group.text_text_pChoose then
    group.text_text_pChoose.disabled = true
  end
end

local function SwitchToClassic(data)
  for triggernum, entry in ipairs(data.triggers) do
    if entry.trigger.type == "secretAura" then
      entry.trigger.auraTracking = "readable"
      OptionsPrivate.AuraEditor.Resolve(data, triggernum)
    end
  end
  if data.blizzardAuraDisplay then
    data.blizzardAuraDisplay.enabled = nil
  end
  WeakAuras.Add(data)
  WeakAuras.UpdateThumbnail(data)
end

local function RestrictGroup(groupKey, group, data)
  if DetachedSubRegion(groupKey, data) then
    MarkDetached(group)
    return
  end
  local isBorderGroup = groupKey:find("%.subborder$") ~= nil
  if isBorderGroup then
    group.__duplicate = nil
  end
  local hasGreyedOut, highestOrder = false, nil
  for key, option in pairs(group) do
    if type(option) == "table" and option.type then
      RestrictDisplayOption(key, option, data, isBorderGroup)
      hasGreyedOut = hasGreyedOut or option.disabled == true
      if type(option.order) == "number" and (not highestOrder or option.order > highestOrder) then
        highestOrder = option.order
      end
    end
  end
  if hasGreyedOut then
    group.secretUnavailableNote = {
      type = "description",
      width = WeakAuras.doubleWidth,
      fontSize = "medium",
      order = (highestOrder or 0) + 1,
      name = unavailableNoteText,
    }
    -- A Flow group arranges Modern auras only, its members keep their trigger type
    if not Display().FlowGroup(data) then
      group.secretSwitchToClassic = {
        type = "execute",
        width = WeakAuras.normalWidth,
        order = (highestOrder or 0) + 2,
        name = L["Switch to classic mode"],
        desc = L["Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options."],
        confirm = true,
        confirmText = L["The aura stops updating in combat once the game hides it. Switch to classic mode?"],
        func = function() SwitchToClassic(data) end,
      }
    end
  end
end

local unrestrictedGroups = { secretAura = true, position = true }

function OptionsPrivate.PrepareSecretDisplayOptions(data, groups)
  if not Display().Enabled(data) then return end

  if Display().FlowGroup(data) then
    groups.secretAura = nil
  else
    groups.secretAura = OptionsPrivate.GetSecretAuraSettings(data)
  end

  if groups.icon and data.regionType == "icon" then
    groups.icon.secretSwipeColor = BindSetting({
      type = "color",
      hasAlpha = true,
      name = L["Swipe Color"],
      order = 11.9,
      width = WeakAuras.normalWidth,
      hidden = function() return not data.cooldown end,
    }, data, "swipeColor", { 0, 0, 0, 0.8 }, false, colorCodec)
  end

  groups.progressOptions = nil

  for groupKey, group in pairs(groups) do
    if not unrestrictedGroups[groupKey] and type(group) == "table" then
      RestrictGroup(groupKey, group, data)
    end
  end
end

--------------------------------------------------------------------------------
-- Actions tab
--------------------------------------------------------------------------------

local supportedActionFields = BuildSet({
  "header", "do_sound", "sound", "sound_channel", "sound_path", "sound_fojji", "hide_all_glows",
})

local unitGlowTypeValues = { Proc = L["Proc Glow"], buttonOverlay = L["Pulse Glow"] }

local soundEventVerbs = { start = L["added"], finish = L["removed"] }

local function ActionValues(data, when)
  return data.actions and data.actions[when] or noSettings
end

local function SoundValues()
  local values = {}
  for key, label in pairs(OptionsPrivate.Private.sound_types) do
    if key ~= " KitID" then values[key] = label end
  end
  values[" Fojji"] = L["FojjiCore recorded voice"]
  return values, OptionsPrivate.Private.SortOrderForValues(values)
end

local function UnitGlowPaddingOption()
  return {
    type = "range",
    control = "WeakAurasSpinBox",
    name = L["Padding"],
    order = 10.865,
    min = 0,
    max = 40,
    step = 1,
    width = WeakAuras.normalWidth,
  }
end

local function RestrictActionOption(data, when, field, option, soundValues, soundSorting)
  if field == "do_message" or field:find("^message") then
    option.disabled = true
    option.desc = L["Blizzard controls aura visibility. Use a condition from another trigger to send chat messages."]
  elseif field == "stop_sound" or field == "do_sound_fade" or field:find("^stop_sound_fade") then
    option.hidden = true
  elseif not supportedActionFields[field] then
    -- A toggle that is still on stays clickable so an inherited setting can be turned off.
    option.disabled = function()
      return not (option.type == "toggle" and ActionValues(data, when)[field])
    end
    option.desc = L["Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not."]
  elseif field == "sound" then
    option.values = soundValues
    option.sorting = soundSorting
  elseif field == "do_sound" then
    option.desc = L["Play when one of the trigger's exact spell IDs is %s. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds."]:format(soundEventVerbs[when])
  end
  if when == "start" and (field:find("^glow_") or field == "choose_glow_frame" or field == "use_glow_color") then
    option.hidden = true
  end
end

local glowTypeCodec = {
  decode = function(value) return value == "pulse" and "buttonOverlay" or "Proc" end,
  encode = function(value) return value == "buttonOverlay" and "pulse" or "proc" end,
}

local unitGlowStyleOptions = {
  { key = "start_glow_type", setting = "unitGlowType", default = "proc", codec = glowTypeCodec,
    values = unitGlowTypeValues },
  { key = "start_use_glow_color", setting = "unitUseGlowColor", default = true },
  { key = "start_glow_color", setting = "unitGlowColor", default = { 1, 0.82, 0, 1 }, codec = colorCodec,
    needsGlowColor = true },
  { key = "start_glow_duration", setting = "unitGlowDuration", default = 1, name = L["Animation Duration"] },
  { key = "start_glow_XOffset", setting = "unitGlowX", default = 0 },
  { key = "start_glow_YOffset", setting = "unitGlowY", default = 0 },
  { key = "start_glow_padding", setting = "unitGlowPadding", default = 0, create = UnitGlowPaddingOption,
    desc = L["Extra space around the unit frame. Zero follows its edges."] },
}

local function BindUnitGlow(args, data)
  local doGlow = args.start_do_glow
  if doGlow then
    doGlow.name = L["Glow Anchored Unit Frame"]
    doGlow.desc = L["Use Unit Frames anchoring in Display. The frame glows while any aura matches your filters and stops automatically. Exact Spell IDs are not required."]
    doGlow.disabled = function()
      return data.anchorFrameType ~= "UNITFRAME" and not ActionValues(data, "start").do_glow
    end
    doGlow.get = function()
      return ReadSettings(data).unitGlow or ActionValues(data, "start").do_glow or false
    end
    doGlow.set = function(_, value)
      local start = data.actions and data.actions.start
      if start then start.do_glow = nil end
      WriteSetting(data, "unitGlow", value, true)
    end
  end

  local function Hidden()
    return data.anchorFrameType ~= "UNITFRAME" or not ReadSettings(data).unitGlow
  end
  for _, style in ipairs(unitGlowStyleOptions) do
    if style.create then
      args[style.key] = style.create()
    end
    local option = args[style.key]
    if option then
      option.desc = style.desc or L["Style the glow on the anchored unit frame."]
      option.name = style.name or option.name
      option.values = style.values or option.values
      option.hidden = Hidden
      option.disabled = function()
        local settings = ReadSettings(data)
        if not settings.unitGlow then return true end
        return style.needsGlowColor and settings.unitUseGlowColor == false or false
      end
      BindSetting(option, data, style.setting, style.default, true, style.codec)
    end
  end
end

local function PrepareGroupActions(data, args)
  for child in OptionsPrivate.Private.TraverseLeafs(data) do
    if Display().Enabled(child) then
      if args.start_glow_type then
        args.start_glow_type.values = unitGlowTypeValues
      end
      args.start_glow_padding = args.start_glow_padding or UnitGlowPaddingOption()
      return
    end
  end
end

function OptionsPrivate.PrepareSecretActionOptions(data, action)
  local args = action.args
  if data.controlledChildren then
    PrepareGroupActions(data, args)
    return
  end
  if not Display().Enabled(data) then return end

  local soundValues, soundSorting = SoundValues()
  for key, option in pairs(args) do
    local when, field = key:match("^(%a+)_(.+)$")
    if (when == "start" or when == "finish") and type(option) == "table" and option.type ~= "header" then
      RestrictActionOption(data, when, field, option, soundValues, soundSorting)
    end
  end

  BindUnitGlow(args, data)

  args.secretSoundNotice = {
    type = "description",
    order = 0,
    width = "full",
    name = "|cffff2020" .. L["Blizzard-controlled aura display: only supported actions are available."] .. "|r",
  }
end

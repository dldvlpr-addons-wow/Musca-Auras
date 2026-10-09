if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = {}
Private.CDMAuraProgress = Display

local linkedTexts = setmetatable({}, {__mode = "k"})
local waitingForCombatEnd = setmetatable({}, {__mode = "k"})

local IsSecret = Private.IsSecret

local function IsCdmBuffEntry(entry)
  local trigger = type(entry) == "table" and entry.trigger
  return trigger and trigger.type == "cdm" and trigger.event == "Blizzard CDM Buff" or false
end

local function ResolveState(owner, explicitIndex)
  local index = explicitIndex or (owner.progressSource and owner.progressSource[1]) or -1
  if index > 0 then
    return owner.states and owner.states[index]
  elseif index == -1 then
    return owner.state
  end
end

local function ResolveNativeSource(state)
  if not CustomAuraContainerAuraProcessingPolicy or not state then return end
  if not state.cdmBuff or not state.show or state.cdmTextPreview or state.cdmAuraTotem then return end
  if state.auraActive == false or state.progressType ~= "static" then return end
  local unit, filter = state.cdmAuraRenderUnit, state.cdmAuraFilter
  if unit ~= "target" or filter ~= "HARMFUL|PLAYER" then return end
  local spellIDs = state.cdmAuraRenderSpellIDs
  if type(spellIDs) ~= "table" or not next(spellIDs) then return end
  return unit, filter or "HELPFUL", spellIDs
end

local function WidgetIsStylable(widget, initializing)
  if initializing then return true end
  if type(widget.CanBeAccessedInContext) ~= "function" then return false end
  local ok, allowed = pcall(widget.CanBeAccessedInContext, widget)
  return ok and not IsSecret(allowed) and allowed == true
end

local function NewNativeContainer(owner, onSlotReady)
  local native = {owner = owner}
  local container = CreateFrame("AuraContainer", nil, owner, "CustomAuraContainerTemplate")
  native.container = container
  container:SetEnabled(false)
  container:SetAllPoints(owner)
  container:SetFrameLevel(owner:GetFrameLevel())
  container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  container:AddAuraSlot("Timer", "HELPFUL", {
    candidateFilters = {includeSpellIDs = {}},
    initializeFrame = function(button)
      native.button = button
      button:SetAllPoints(container)
      button:SetFrameLevel(container:GetFrameLevel())
      button:EnableMouse(false)
      onSlotReady(native, button)
    end,
  })
  owner:HookScript("OnHide", function() container:SetEnabled(false) end)
  owner:HookScript("OnShow", function() container:SetEnabled(native.wanted == true) end)
  return native
end

local function ReleaseNative(native)
  if not (native and native.wanted) then return end
  native.wanted = false
  native.container:SetEnabled(false)
end

local function CollectSpellIDs(spellIDs)
  local seen, sorted = {}, {}
  for _, spellID in ipairs(spellIDs) do
    if not IsSecret(spellID) and type(spellID) == "number" and spellID > 0 and not seen[spellID] then
      seen[spellID] = true
      sorted[#sorted + 1] = spellID
    end
  end
  table.sort(sorted)
  return seen, sorted
end

local function AttachNative(native, unit, filter, spellIDs)
  local container = native.container
  local seen, sorted = CollectSpellIDs(spellIDs)
  local signature = unit .. ":" .. filter .. ":" .. table.concat(sorted, ",")
  if native.key ~= signature then
    container:SetEnabled(false)
    container:SetUnit(unit)
    container:SetAuraSlotFilterString("Timer", filter)
    container:SetAuraSlotCandidateFilters("Timer", {includeSpellIDs = seen})
    native.key = signature
  end
  if native.key == native.enabledKey and native.wanted then return end
  native.wanted = true
  native.enabledKey = native.key
  container:SetEnabled(native.owner:IsVisible())
end

local function DurationFormatSignature(config, index)
  local prefix = "text_text_format_" .. index .. ".p_"
  local timeFormat = config[prefix .. "time_format"]
  if timeFormat == nil or timeFormat == -1 then return "default" end
  local floorValue = config[prefix .. "time_legacy_floor"] and 0 or 99
  local threshold = config[prefix .. "time_dynamic_threshold"] or 3
  local precision = config[prefix .. "time_precision"] or 1
  local dynamic = timeFormat == -2
  local formatter = Private.GetDurationTextFormatter(floorValue, threshold, precision, dynamic, timeFormat)
  return floorValue .. ":" .. threshold .. ":" .. precision .. ":" .. tostring(dynamic) .. ":" .. timeFormat,
    {textFormatter = formatter}
end

local function AttachLinkedTextSource(native, kind, config, index)
  if kind == "s" then
    native.button:SetApplicationCount(native.text)
    native.format = "count"
    return
  end
  local signature, options = DurationFormatSignature(config, index)
  native.button:SetDurationText(native.text, options)
  native.format = signature
end

local function NewLinkedText(sub, config, kind, index)
  return NewNativeContainer(sub, function(native, button)
    native.text = button:CreateFontString(nil, "OVERLAY")
    native.text:SetFont(sub.text:GetFont())
    Display.StyleText(sub, native)
    AttachLinkedTextSource(native, kind, config, index)
  end)
end

local function ReleaseLinkedTexts(sub)
  for _, native in pairs(sub.linkedAuraTexts or {}) do
    ReleaseNative(native)
  end
  linkedTexts[sub] = nil
  waitingForCombatEnd[sub] = nil
end

local function LinkedTrigger(parentData, index)
  local entry = index and parentData and parentData.triggers and parentData.triggers[index]
  local trigger = type(entry) == "table" and entry.trigger
  if not trigger or trigger.type ~= "secretAura" then return end
  local auraDisplay = Private.BlizzardAuraDisplay
  if auraDisplay.Enabled(parentData) or not auraDisplay.IsSingleUnit(trigger) then return end
  return parentData, trigger
end

local function FindLinkedTrigger(parent, index)
  return LinkedTrigger(parent.id and WeakAuras.GetData(parent.id), index)
end

-- Builds the linked text container while unrestricted, so the first restricted show has a source.
local function PrepareLinkedText(sub, parentData, config)
  local kind, index = Private.ParseCDMText(config.text_text)
  if (kind ~= "p" and kind ~= "s") or WeakAuras.IsRestricted() or not sub.text:GetFont() then return end
  if not LinkedTrigger(parentData, index) then return end
  sub.linkedAuraTexts = sub.linkedAuraTexts or {}
  sub.linkedAuraTexts[kind] = sub.linkedAuraTexts[kind] or NewLinkedText(sub, config, kind, index)
end

local function ShowLinkedText(parent, sub, config, kind, index)
  if kind ~= "p" and kind ~= "s" then return false end
  local parentData, trigger = FindLinkedTrigger(parent, index)
  if not parentData or WeakAuras.IsOptionsOpen() then return false end
  local auraDisplay = Private.BlizzardAuraDisplay
  local unit = trigger.unit == "member" and auraDisplay.SpecificUnit(trigger) or trigger.unit
  if not unit then return false end
  sub.cdmTextConfig = config
  sub.linkedAuraTexts = sub.linkedAuraTexts or {}
  local byKind = sub.linkedAuraTexts
  local native = byKind[kind]
  if not native then
    if WeakAuras.IsRestricted() then
      waitingForCombatEnd[sub] = true
      sub.text:SetText("")
      return true
    end
    native = NewLinkedText(sub, config, kind, index)
    byKind[kind] = native
  end
  for otherKind, other in pairs(byKind) do
    if otherKind ~= kind then ReleaseNative(other) end
  end
  if native.stylePending and not InCombatLockdown() and WidgetIsStylable(native.text) then
    Display.StyleText(sub, native)
    if kind == "p" then
      local signature = DurationFormatSignature(config, index)
      if signature ~= native.format then
        AttachLinkedTextSource(native, kind, config, index)
      end
    end
  end
  local container = native.container
  if native.boundUnit ~= unit or native.boundData ~= parentData or native.boundIndex ~= index then
    local proxy = setmetatable({progressSource = {index, ""}}, {__index = parentData})
    container:SetEnabled(false)
    container:SetUnit(unit)
    container:SetAuraSlotFilterString("Timer", auraDisplay.FilterString(trigger))
    container:SetAuraSlotCandidateFilters("Timer", auraDisplay.CandidateFilters(proxy))
    container:SetAuraSlotSortMethod("Timer", auraDisplay.SortOrder(proxy, trigger))
    native.boundUnit, native.boundData, native.boundIndex = unit, parentData, index
  end
  container:SetFrameLevel(sub:GetFrameLevel())
  native.wanted = true
  container:SetEnabled(sub:IsVisible())
  sub.text:SetText("")
  linkedTexts[sub] = native
  waitingForCombatEnd[sub] = nil
  return true
end

-- Returns false when the container cannot be created yet (restricted); the caller then waits.
local function ShowOwnTimerText(sub, config, unit, filter, spellIDs)
  sub.cdmTextConfig = config
  if not sub.cdmAuraTimer then
    if WeakAuras.IsRestricted() then return false end
    sub.cdmAuraTimer = NewNativeContainer(sub, function(native, button)
      native.text = button:CreateFontString(nil, "OVERLAY")
      native.text:SetFont(sub.text:GetFont())
      Display.StyleText(sub, native)
      button:SetDurationText(native.text, {
        textFormatter = Private.GetDurationTextFormatter(99, 0, 0),
      })
    end)
  end
  local native = sub.cdmAuraTimer
  if native.stylePending then Display.StyleText(sub) end
  native.container:SetFrameLevel(sub:GetFrameLevel())
  sub.cdmNativeText = true
  sub.text:SetText("")
  AttachNative(native, unit, filter, spellIDs)
  return true
end

local watcher = CreateFrame("Frame")
for _, eventName in ipairs({"PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_PET", "UNIT_TARGET",
  "PLAYER_ENTERING_WORLD"}) do
  watcher:RegisterEvent(eventName)
end
watcher:SetScript("OnEvent", function()
  for _, native in pairs(linkedTexts) do
    if native.wanted then native.container:UpdateAllAuras() end
  end
end)

-- Containers skipped under restrictions are created once they end.
Private.callbacks:RegisterCallback("RestrictionChanged", function(_, isRestricted)
  if isRestricted then return end
  for owner in pairs(waitingForCombatEnd) do
    waitingForCombatEnd[owner] = nil
    -- A hidden owner has no state; its next show runs Update again.
    if owner.Update and owner:IsVisible() then xpcall(owner.Update, geterrorhandler(), owner) end
  end
end)

function Display.IsConfigured(data)
  if not data or type(data.triggers) ~= "table" then return false end
  local index = data.progressSource and data.progressSource[1] or -1
  if index == 0 then return false end
  if index < 0 then index = data.triggers.activeTriggerMode or -1 end
  if index < 0 and #data.triggers == 1 then index = 1 end
  return IsCdmBuffEntry(data.triggers[index])
end

function Display.IsInactive(region)
  local state = ResolveState(region)
  return state and state.cdmBuff and state.auraActive == false or false
end

function Display.Modify(region, data)
  ReleaseNative(region.cdmAuraTimer)
  region.cdmProgressData = data
  region.cdmNativeProgress = nil
end

function Display.SyncFrameLevels(region)
  local native = region.cdmAuraTimer
  if native then native.container:SetFrameLevel(region.cooldown:GetFrameLevel()) end
end

function Display.Style(region, initializing)
  local native = initializing or region.cdmAuraTimer
  if not native then return end
  Display.SyncFrameLevels(region)
  if not WidgetIsStylable(native.cooldown, initializing) then return end
  local cooldown = native.cooldown
  cooldown:SetDrawSwipe(region.cooldownSwipe ~= false)
  cooldown:SetDrawEdge(region.cooldownEdge == true)
  cooldown:SetReverse(region.inverseDirection == true)
  cooldown:SetHideCountdownNumbers(region.cdmConfiguredHideNumbers == true)
end

function Display.Update(region)
  region.cdmNativeProgress = nil
  local unit, filter, spellIDs = ResolveNativeSource(ResolveState(region))
  local progressData = region.cdmProgressData
  if not unit or region.regionType ~= "icon" or not progressData or not progressData.cooldown then
    ReleaseNative(region.cdmAuraTimer)
    return
  end
  if not region.cdmAuraTimer and WeakAuras.IsRestricted() then
    waitingForCombatEnd[region] = true
    return
  end
  region.cdmAuraTimer = region.cdmAuraTimer or NewNativeContainer(region, function(native, button)
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    native.cooldown = cooldown
    cooldown:SetAllPoints(region.icon)
    cooldown:SetDrawBling(false)
    cooldown:SetFrameLevel(button:GetFrameLevel())
    Display.Style(region, native)
    button:SetDurationCooldown(cooldown)
  end)
  region.cdmNativeProgress = true
  region.cooldown:Hide()
  Display.Style(region)
  AttachNative(region.cdmAuraTimer, unit, filter, spellIDs)
end

function Display.StyleText(sub, initializing)
  local native = initializing or sub.cdmAuraTimer
  local config = sub.cdmTextConfig
  if not native or not config then return end
  native.stylePending = true
  if not WidgetIsStylable(native.text, initializing) then return end
  local font, size, flags = sub.text:GetFont()
  if not font then return end
  local text = native.text
  Private.ApplyTextFont(text, nil, font, size, flags,
    config.text_shadowColor, config.text_shadowXOffset, config.text_shadowYOffset)
  text:SetTextColor(sub.color_anim_r or sub.color_r or 1, sub.color_anim_g or sub.color_g or 1,
    sub.color_anim_b or sub.color_b or 1, sub.color_anim_a or sub.color_a or 1)
  text:SetJustifyH(config.text_justify or "CENTER")
  local fixed = config.text_automaticWidth == "Fixed"
  text:SetWidth(fixed and config.text_fixedWidth or 0)
  local wrapping = not fixed or config.text_wordWrap == "WordWrap"
  text:SetWordWrap(wrapping)
  text:SetNonSpaceWrap(wrapping)
  if sub.AnchorNativeText then sub:AnchorNativeText(text) end
  native.stylePending = nil
end

function Display.ModifyText(parent, sub, parentData, config)
  sub.cdmTextConfig = config
  Display.StyleText(sub)
  for _, native in pairs(sub.linkedAuraTexts or {}) do
    native.boundData, native.stylePending = nil, true
  end
  PrepareLinkedText(sub, parentData, config)
end

function Display.HideText(sub)
  ReleaseNative(sub.cdmAuraTimer)
  ReleaseLinkedTexts(sub)
  sub.cdmNativeText = nil
end

function Display.UpdateText(parent, sub, config, kind, explicitTrigger)
  if not kind then
    Display.HideText(sub)
    return false
  end
  local state = ResolveState(parent, explicitTrigger)
  if not state or not state.cdmBuff then
    ReleaseNative(sub.cdmAuraTimer)
    sub.cdmNativeText = nil
    if sub.text:GetFont() and ShowLinkedText(parent, sub, config, kind, explicitTrigger) then return true end
    ReleaseLinkedTexts(sub)
    return false
  end
  ReleaseLinkedTexts(sub)
  if not sub.text:GetFont() then return true end
  local unit, filter, spellIDs = ResolveNativeSource(state)
  local wantsOwnTimer = unit and (kind == "p" or kind == "bp")
  if wantsOwnTimer and ShowOwnTimerText(sub, config, unit, filter, spellIDs) then
    return true
  end
  Display.HideText(sub)
  if wantsOwnTimer then waitingForCombatEnd[sub] = true end
  Private.CopyCDMCountdownText(sub.text, state, kind)
  if sub.UpdateAnchorOnTextChange then sub:UpdateAnchorOnTextChange() end
  return true
end

function Display.ReleaseIndicator(sub)
  if sub.preview then sub.preview:Hide() end
  if sub.dispelBorder then sub.dispelBorder:Hide() end
  if sub.dispelEdges then Private.DispelTypeDisplay.Hide(sub.dispelEdges) end
end

function Display.ModifyIndicator(parent, sub)
  Display.ReleaseIndicator(sub)
end

function Display.UpdateIndicator(parent, sub)
  local state = ResolveState(parent)
  local dispel
  if sub.visible and state and state.show and state.cdmBuff then
    dispel = state.cdmTextPreview and "Magic" or state.cdmDispelName
  end
  Display.ReleaseIndicator(sub)
  if IsSecret(dispel) or type(dispel) ~= "string" or dispel == "" then return end
  if sub.dispelEdges then
    for _, edge in ipairs(sub.dispelEdges) do
      AuraUtil.SetAuraBorderColor(edge, dispel)
      edge:Show()
    end
  elseif sub.preview then
    AuraUtil.SetAuraDispelTypeIcon(sub.preview, dispel)
    sub.preview:SetVertexColor(1, 1, 1, 1)
    sub.preview:Show()
  end
end

-- Options preview of the native aura display: sample native buttons with fake bindings.
-- Fills Private.BlizzardAuraDisplay; called by BlizzardAuraDisplay.lua, SecretAuraSingle.lua and SecretAuraConditions.lua.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local Display = Private.BlizzardAuraDisplay

local SAMPLE_DURATION = 6
Display.PREVIEW_SAMPLE_DURATION = SAMPLE_DURATION
local BINDING_KINDS = {"Icon", "DurationText", "ApplicationCount", "SpellName", "DurationBar", "DurationCooldown"}

local function AttachBindingMethods(button)
  for _, kind in ipairs(BINDING_KINDS) do
    button["Clear" .. kind] = function(self)
      self.bindings[kind] = {}
    end
    button["Set" .. kind] = function(self, widget, options)
      local list = self.bindings[kind] or {}
      self.bindings[kind] = list
      list[#list + 1] = {widget = widget, options = options}
    end
  end
end

local function AttachDispelAndAnimationMethods(button)
  function button:AddAuraShownAnimation(animation)
    animation:Play()
  end
  function button:RemoveAuraShownAnimation(animation)
    animation:Stop()
  end
  function button:AddDispelTypeTexture(texture, options)
    local styles = Enum.CustomAuraButtonDispelTypeTextureStyle
    if options.style == styles.PreserveAsset then
      AuraUtil.SetAuraBorderColor(texture, "Magic")
      texture:Show()
      return
    end
    if options.style == styles.Border then
      AuraUtil.SetAuraBorderAtlas(texture, "Magic", false)
    else
      AuraUtil.SetAuraDispelTypeIcon(texture, "Magic")
    end
    texture:SetVertexColor(1, 1, 1, 1)
    texture:Show()
  end
end

function Display.CreateSampleNative(parent)
  local button = CreateFrame("Frame", nil, parent)
  button:EnableMouse(false)
  button.bindings = {}
  AttachBindingMethods(button)
  AttachDispelAndAnimationMethods(button)
  local native = {button = button, preview = true}
  native.inner = CreateFrame("Frame", nil, button)
  native.inner:SetPoint("CENTER", button, "CENTER")
  native.outer = CreateFrame("Frame", nil, button)
  native.outer:SetPoint("CENTER", button, "CENTER")
  native.border = button:CreateTexture(nil, "BACKGROUND")
  native.border:SetAllPoints(button)
  local baseFrame = CreateFrame("Frame", nil, button)
  baseFrame:SetAllPoints(button)
  native.elementFrames = {sharedBase = baseFrame}
  native.icon = baseFrame:CreateTexture(nil, "ARTWORK")
  native.cooldown = CreateFrame("Cooldown", nil, baseFrame, "CooldownFrameTemplate")
  native.cooldown:SetAllPoints(native.icon)
  native.cooldown:SetDrawBling(false)
  native.overlay = CreateFrame("Frame", nil, button)
  native.overlay:SetAllPoints(button)
  return native
end

local bindingFillers = {
  Icon = function(widget, fill)
    widget:SetTexture(fill.iconID)
  end,
  SpellName = function(widget, fill)
    widget:SetText(fill.name)
  end,
  ApplicationCount = function(widget, fill)
    widget:SetText(fill.timed and "3" or "")
  end,
  DurationText = function(widget, fill)
    widget:SetText(fill.timed and "6" or "")
  end,
  DurationBar = function(widget, fill)
    widget:SetMinMaxValues(0, SAMPLE_DURATION)
    local value = 0
    if fill.timed then
      value = fill.data.inverse and 0 or SAMPLE_DURATION
    end
    widget:SetValue(value)
  end,
  DurationCooldown = function(widget, fill)
    if fill.timed then
      widget:SetCooldown(GetTime(), SAMPLE_DURATION)
      widget:Show()
    else
      widget:Clear()
      widget:Hide()
    end
  end,
}

function Display.FillSampleBindings(button, iconID, name, data, timed)
  local fill = {iconID = iconID, name = name, data = data, timed = timed}
  for kind, entries in pairs(button.bindings) do
    local apply = bindingFillers[kind]
    for _, entry in ipairs(entries) do
      if apply then
        apply(entry.widget, fill)
      end
    end
  end
end

local function TickSample(button, native, elapsed)
  button.elapsed = (button.elapsed or 0) + elapsed
  if button.elapsed < 0.05 then
    return
  end
  button.elapsed = 0
  local now = GetTime()
  if not button.expires or button.expires <= now then
    button.expires = now + SAMPLE_DURATION
    for _, entry in ipairs(button.bindings.DurationCooldown or {}) do
      entry.widget:SetCooldown(now, SAMPLE_DURATION)
    end
  end
  local remaining = math.max(0, button.expires - now)
  if native.conditionData then
    Display.UpdateConditionPreview(native, native.conditionData, remaining)
  end
  local label
  if remaining < 3 then
    label = string.format("%.1f", remaining)
  else
    label = tostring(math.ceil(remaining))
  end
  for _, entry in ipairs(button.bindings.DurationText or {}) do
    entry.widget:SetText(label)
  end
  for _, entry in ipairs(button.bindings.DurationBar or {}) do
    entry.widget:SetValue(button.inverse and SAMPLE_DURATION - remaining or remaining)
  end
end

local function CreateSample(region)
  local native = Display.CreateSampleNative(region)
  native.button:SetScript("OnUpdate", function(self, elapsed)
    if not WeakAuras.IsOptionsOpen() then
      Display.HidePreview(region)
      if Display.FlushInstanceQueue then
        Display.FlushInstanceQueue(region)
      end
      return
    end
    if self.staticSample then
      return
    end
    TickSample(self, native, elapsed)
  end)
  return native
end

function Display.HidePreview(region)
  region.secretAuraSamplesActive = false
  local samples = region.secretAuraSamples or {}
  for _, sample in ipairs(samples) do
    sample.button:Hide()
  end
end

local function LayoutOffsets(growth, offset)
  local x, y = 0, 0
  if growth == "UP" or growth == "DOWN" or growth == "CENTER_VERTICAL" then
    y = growth == "UP" and offset or -offset
  else
    x = growth == "LEFT" and -offset or offset
  end
  return x, y
end

function Display.ShowPreview(region, data, StyleSample)
  local spellIds = Display.GetSpellIDs(Display.GetTrigger(data), false)
  if #spellIds == 0 then
    spellIds[1] = false
  end
  local settings = data.blizzardAuraDisplay
  local count = math.min(#spellIds, Display.MaxAuras(data))
  local width, height = Display.Dimensions(data)
  local growth, spacing = Display.Growth(data), settings.spacing or 6
  local showsMissing = Display.PreviewShowsMissing(data)
  local vertical = growth == "UP" or growth == "DOWN" or growth == "CENTER_VERTICAL"
  local centered = growth == "CENTER_HORIZONTAL" or growth == "CENTER_VERTICAL"
  local cornerPoint = "TOPLEFT"
  if growth == "LEFT" then
    cornerPoint = "TOPRIGHT"
  elseif growth == "UP" then
    cornerPoint = "BOTTOMLEFT"
  end
  region.secretAuraSamples = region.secretAuraSamples or {}
  Display.RestorePreviewRegion(region)
  Display.HidePreview(region)
  region.secretAuraSamplesActive = true
  local unitList = Display.FlowPreviewUnits and Display.FlowPreviewUnits(data) or {false}
  for slot = 1, count * #unitList do
    local position = (slot - 1) % count + 1
    local sample = region.secretAuraSamples[slot] or CreateSample(region)
    region.secretAuraSamples[slot] = sample
    sample.previewUnit = unitList[math.floor((slot - 1) / count) + 1]
    local button = sample.button
    button.expires = GetTime() + SAMPLE_DURATION
    button.inverse = data.inverse == true
    local spellInfo = spellIds[position] and C_Spell.GetSpellInfo(spellIds[position])
    sample.name = spellInfo and spellInfo.name or "Aura"
    sample.iconID = spellInfo and spellInfo.iconID or 134400
    StyleSample(sample, data)
    local centerShift = centered and (count - 1) / 2 or 0
    local step = (vertical and height or width) + spacing
    local x, y = LayoutOffsets(growth, (position - 1 - centerShift) * step)
    button:ClearAllPoints()
    local point = centered and "CENTER" or cornerPoint
    button:SetPoint(point, region, point, x, y)
    button.staticSample = showsMissing
    local iconID = showsMissing and Display.SingleIcon(data) or sample.iconID
    Display.FillSampleBindings(button, iconID, sample.name, data, not showsMissing)
    if showsMissing then
      Display.StyleMissingIcon(sample, data)
    end
    button:Show()
  end
end

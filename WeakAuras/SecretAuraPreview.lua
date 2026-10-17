-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Options preview of the native display: fake aura buttons ("samples") that mimic the Blizzard
-- button interface, laid out by growth and running a looping countdown while the options are open.
-- Display members of files loaded later are looked up at call time.

local Display = Private.BlizzardAuraDisplay

local SAMPLE_DURATION = 6
local TICK_SECONDS = 0.05
local FALLBACK_NAME, FALLBACK_ICON = "Aura", 134400
local DEFAULT_SPACING = 6

Display.PREVIEW_SAMPLE_DURATION = SAMPLE_DURATION

local function TimedText(timed, text)
  return timed and text or ""
end

-- Example value per binding kind; the keys are also the kinds of the Set/Clear button methods.
local BINDING_FILLERS = {
  Icon = function(widget, iconID) widget:SetTexture(iconID) end,
  SpellName = function(widget, _, name) widget:SetText(name) end,
  ApplicationCount = function(widget, _, _, _, timed) widget:SetText(TimedText(timed, "3")) end,
  DurationText = function(widget, _, _, _, timed) widget:SetText(TimedText(timed, tostring(SAMPLE_DURATION))) end,
  DurationBar = function(widget, _, _, data, timed)
    widget:SetMinMaxValues(0, SAMPLE_DURATION)
    widget:SetValue((timed and not data.inverse) and SAMPLE_DURATION or 0)
  end,
  DurationCooldown = function(widget, _, _, _, timed)
    if timed then
      widget:SetCooldown(GetTime(), SAMPLE_DURATION)
      widget:Show()
    else
      widget:Clear()
      widget:Hide()
    end
  end,
}

local function EachBound(button, kind, action)
  for _, binding in ipairs(button.bindings[kind] or {}) do action(binding.widget) end
end

local SampleButton = {}

for kind in pairs(BINDING_FILLERS) do
  SampleButton["Set" .. kind] = function(self, widget, options)
    local list = self.bindings[kind] or {}
    self.bindings[kind] = list
    list[#list + 1] = { widget = widget, options = options }
  end
  SampleButton["Clear" .. kind] = function(self)
    self.bindings[kind] = {}
  end
end

-- A sample is always "present": shown animations play at once.
function SampleButton:AddAuraShownAnimation(group) group:Play() end
function SampleButton:RemoveAuraShownAnimation(group) group:Stop() end

function SampleButton:AddDispelTypeTexture(texture, options)
  local styles = Enum.CustomAuraButtonDispelTypeTextureStyle
  local style = options and options.style
  if style == styles.PreserveAsset then
    AuraUtil.SetAuraBorderColor(texture, "Magic")
  else
    if style == styles.Border then
      AuraUtil.SetAuraBorderAtlas(texture, "Magic", false)
    else
      AuraUtil.SetAuraDispelTypeIcon(texture, "Magic")
    end
    texture:SetVertexColor(1, 1, 1, 1)
  end
  texture:Show()
end

function Display.CreateSampleNative(parent)
  local button = CreateFrame("Frame", nil, parent)
  button:EnableMouse(false)
  button.bindings = {}
  for name, method in pairs(SampleButton) do button[name] = method end

  local function CenteredFrame()
    local frame = CreateFrame("Frame", nil, button)
    frame:SetPoint("CENTER", button, "CENTER")
    return frame
  end
  local function FilledFrame()
    local frame = CreateFrame("Frame", nil, button)
    frame:SetAllPoints(button)
    return frame
  end

  local border = button:CreateTexture(nil, "BACKGROUND")
  border:SetAllPoints(button)
  local sharedBase = FilledFrame()
  local icon = sharedBase:CreateTexture(nil, "ARTWORK")
  local cooldown = CreateFrame("Cooldown", nil, sharedBase, "CooldownFrameTemplate")
  cooldown:SetAllPoints(icon)
  cooldown:SetDrawBling(false)

  return {
    button = button,
    preview = true,
    inner = CenteredFrame(),
    outer = CenteredFrame(),
    border = border,
    elementFrames = { sharedBase = sharedBase },
    icon = icon,
    cooldown = cooldown,
    overlay = FilledFrame(),
  }
end

function Display.FillSampleBindings(button, iconID, name, data, timed)
  for kind, fill in pairs(BINDING_FILLERS) do
    EachBound(button, kind, function(widget) fill(widget, iconID, name, data, timed) end)
  end
end

function Display.StopSampleAnimations(sample)
  for _, entry in pairs(sample.sharedElements or {}) do Display.ClearElementGlow(entry) end
  for _, host in pairs(sample.conditionHosts or {}) do
    if host.pulse then host.pulse:Stop() end
  end
end

function Display.HidePreview(region)
  region.secretAuraSamplesActive = false
  for _, sample in ipairs(region.secretAuraSamples or {}) do
    sample.button:Hide()
    Display.StopSampleAnimations(sample)
  end
end

local function TickSample(region, sample, elapsed)
  if not WeakAuras.IsOptionsOpen() then
    Display.HidePreview(region)
    if Display.FlushInstanceQueue then Display.FlushInstanceQueue(region) end
    return
  end
  local button = sample.button
  if button.staticSample then return end
  button.elapsed = (button.elapsed or 0) + elapsed
  if button.elapsed < TICK_SECONDS then return end
  button.elapsed = 0

  local now = GetTime()
  if not button.expires or button.expires <= now then
    button.expires = now + SAMPLE_DURATION
    EachBound(button, "DurationCooldown", function(cooldown) cooldown:SetCooldown(now, SAMPLE_DURATION) end)
  end
  local remaining = math.max(0, button.expires - now)
  if sample.conditionData then Display.UpdateConditionPreview(sample, sample.conditionData, remaining) end
  local label = remaining < 3 and string.format("%.1f", remaining) or string.format("%d", math.ceil(remaining))
  EachBound(button, "DurationText", function(text) text:SetText(label) end)
  local barValue = button.inverse and SAMPLE_DURATION - remaining or remaining
  EachBound(button, "DurationBar", function(bar) bar:SetValue(barValue) end)
end

local function NewAnimatedSample(region)
  local sample = Display.CreateSampleNative(region)
  sample.button:Hide()
  sample.button:SetScript("OnUpdate", function(_, elapsed) TickSample(region, sample, elapsed) end)
  return sample
end

-- Anchor point (same on the sample and the region) and direction of each growth.
local GROWTH_LAYOUTS = {
  RIGHT = { point = "TOPLEFT", x = 1 },
  LEFT = { point = "TOPRIGHT", x = -1 },
  DOWN = { point = "TOPLEFT", y = -1 },
  UP = { point = "BOTTOMLEFT", y = 1 },
  CENTER_HORIZONTAL = { point = "CENTER", x = 1, centered = true },
  CENTER_VERTICAL = { point = "CENTER", y = -1, centered = true },
}

local function SlotOffset(layout, position, count, width, height, spacing)
  local shift = layout.centered and (count - 1) / 2 or 0
  local steps = position - 1 - shift
  if layout.y then return 0, layout.y * steps * (height + spacing) end
  return layout.x * steps * (width + spacing), 0
end

local function SpellLook(spellID)
  local info = spellID and C_Spell.GetSpellInfo(spellID)
  return info and info.name or FALLBACK_NAME, info and info.iconID or FALLBACK_ICON
end

function Display.ShowPreview(region, data, StyleSample)
  local spellIDs = Display.GetSpellIDs(Display.GetTrigger(data), false)
  local perUnit = math.min(math.max(#spellIDs, 1), Display.MaxAuras(data))
  local width, height = Display.Dimensions(data)
  local layout = GROWTH_LAYOUTS[Display.Growth(data)] or GROWTH_LAYOUTS.RIGHT
  local spacing = data.blizzardAuraDisplay.spacing or DEFAULT_SPACING
  local missing = Display.PreviewShowsMissing(data) and true or false

  Display.RestorePreviewRegion(region)
  Display.HidePreview(region)
  region.secretAuraSamplesActive = true

  local units = Display.FlowPreviewUnits and Display.FlowPreviewUnits(data) or { false }
  region.secretAuraSamples = region.secretAuraSamples or {}
  local samples = region.secretAuraSamples
  for slot = 1, perUnit * #units do
    local position = (slot - 1) % perUnit + 1
    local sample = samples[slot] or NewAnimatedSample(region)
    samples[slot] = sample
    local button = sample.button

    sample.previewUnit = units[math.floor((slot - 1) / perUnit) + 1]
    button.expires = GetTime() + SAMPLE_DURATION
    button.inverse = data.inverse == true
    sample.name, sample.iconID = SpellLook(spellIDs[position])
    StyleSample(sample, data)

    local x, y = SlotOffset(layout, position, perUnit, width, height, spacing)
    button:ClearAllPoints()
    button:SetPoint(layout.point, region, layout.point, x, y)
    button.staticSample = missing
    Display.FillSampleBindings(button, missing and Display.SingleIcon(data) or sample.iconID, sample.name, data, not missing)
    if missing then Display.StyleMissingIcon(sample, data) end
    button:Show()
  end
end

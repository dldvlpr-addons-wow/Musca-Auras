-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay

local SAMPLE_DURATION = 6
local FALLBACK_NAME = "Aura"
local FALLBACK_ICON = 134400
local SAMPLE_DISPEL_TYPE = "Magic"
local TICK_INTERVAL = 0.05
local KINDS = { "Icon", "SpellName", "ApplicationCount", "DurationText", "DurationBar", "DurationCooldown" }

Display.PREVIEW_SAMPLE_DURATION = SAMPLE_DURATION

local GROWTHS = {
  RIGHT = { point = "TOPLEFT", x = 1, y = 0 },
  LEFT = { point = "TOPRIGHT", x = -1, y = 0 },
  DOWN = { point = "TOPLEFT", x = 0, y = -1 },
  UP = { point = "BOTTOMLEFT", x = 0, y = 1 },
  CENTER_HORIZONTAL = { point = "CENTER", x = 1, y = 0, centered = true },
  CENTER_VERTICAL = { point = "CENTER", x = 0, y = -1, centered = true },
}

local sampleMethods = {}

for _, kind in ipairs(KINDS) do
  sampleMethods["Set" .. kind] = function(self, widget, options)
    local list = self.bindings[kind]
    if not list then
      list = {}
      self.bindings[kind] = list
    end
    list[#list + 1] = { widget = widget, options = options }
  end
  sampleMethods["Clear" .. kind] = function(self)
    self.bindings[kind] = {}
  end
end

function sampleMethods:AddAuraShownAnimation(group)
  group:Play()
end

function sampleMethods:RemoveAuraShownAnimation(group)
  group:Stop()
end

function sampleMethods:AddDispelTypeTexture(texture, options)
  local styles = Enum.CustomAuraButtonDispelTypeTextureStyle or {}
  local style = options and options.style
  if style == styles.PreserveAsset and style ~= nil then
    AuraUtil.SetAuraBorderColor(texture, SAMPLE_DISPEL_TYPE)
  else
    if style == styles.Border and style ~= nil then
      AuraUtil.SetAuraBorderAtlas(texture, SAMPLE_DISPEL_TYPE, false)
    else
      AuraUtil.SetAuraDispelTypeIcon(texture, SAMPLE_DISPEL_TYPE)
    end
    texture:SetVertexColor(1, 1, 1, 1)
  end
  texture:Show()
end

function Display.CreateSampleNative(parent)
  local button = CreateFrame("Frame", nil, parent)
  button:EnableMouse(false)
  button.bindings = {}
  for name, method in pairs(sampleMethods) do button[name] = method end

  local border = button:CreateTexture(nil, "BACKGROUND")
  border:SetAllPoints(button)

  local sharedBase = CreateFrame("Frame", nil, button)
  sharedBase:SetAllPoints(button)
  local icon = sharedBase:CreateTexture(nil, "ARTWORK")
  local cooldown = CreateFrame("Cooldown", nil, sharedBase, "CooldownFrameTemplate")
  cooldown:SetAllPoints(icon)
  cooldown:SetDrawBling(false)

  local inner = CreateFrame("Frame", nil, button)
  inner:SetPoint("CENTER", button, "CENTER")
  local outer = CreateFrame("Frame", nil, button)
  outer:SetPoint("CENTER", button, "CENTER")
  local overlay = CreateFrame("Frame", nil, button)
  overlay:SetAllPoints(button)

  return {
    button = button, preview = true, inner = inner, outer = outer, border = border,
    elementFrames = { sharedBase = sharedBase }, icon = icon, cooldown = cooldown, overlay = overlay,
  }
end

local function EachBound(button, kind, callback)
  local list = button.bindings and button.bindings[kind]
  if not list then return end
  for _, binding in ipairs(list) do callback(binding.widget) end
end

function Display.FillSampleBindings(button, iconID, name, data, timed)
  EachBound(button, "Icon", function(widget) widget:SetTexture(iconID) end)
  EachBound(button, "SpellName", function(widget) widget:SetText(name) end)
  EachBound(button, "ApplicationCount", function(widget) widget:SetText(timed and "3" or "") end)
  EachBound(button, "DurationText", function(widget) widget:SetText(timed and tostring(SAMPLE_DURATION) or "") end)
  EachBound(button, "DurationBar", function(widget)
    widget:SetMinMaxValues(0, SAMPLE_DURATION)
    widget:SetValue((timed and not data.inverse) and SAMPLE_DURATION or 0)
  end)
  EachBound(button, "DurationCooldown", function(widget)
    if timed then
      widget:SetCooldown(GetTime(), SAMPLE_DURATION)
      widget:Show()
    else
      widget:Clear()
      widget:Hide()
    end
  end)
end

function Display.StopSampleAnimations(sample)
  for _, entry in pairs(sample.sharedElements or {}) do
    Display.ClearElementGlow(entry)
  end
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

local function Tick(region, sample, button, elapsed)
  if not WeakAuras.IsOptionsOpen() then
    Display.HidePreview(region)
    if Display.FlushInstanceQueue then Display.FlushInstanceQueue(region) end
    return
  end
  if button.staticSample then return end
  button.elapsed = (button.elapsed or 0) + elapsed
  if button.elapsed < TICK_INTERVAL then return end
  button.elapsed = 0

  local now = GetTime()
  if not button.expires or button.expires <= now then
    button.expires = now + SAMPLE_DURATION
    EachBound(button, "DurationCooldown", function(widget) widget:SetCooldown(now, SAMPLE_DURATION) end)
  end
  local remaining = math.max(0, button.expires - now)
  if sample.conditionData then
    Display.UpdateConditionPreview(sample, sample.conditionData, remaining)
  end
  local label
  if remaining < 3 then
    label = string.format("%.1f", remaining)
  else
    label = string.format("%d", math.ceil(remaining))
  end
  EachBound(button, "DurationText", function(widget) widget:SetText(label) end)
  local barValue = button.inverse and (SAMPLE_DURATION - remaining) or remaining
  EachBound(button, "DurationBar", function(widget) widget:SetValue(barValue) end)
end

local function SampleAt(region, slot)
  region.secretAuraSamples = region.secretAuraSamples or {}
  local sample = region.secretAuraSamples[slot]
  if not sample then
    sample = Display.CreateSampleNative(region)
    sample.button:Hide()
    sample.button:SetScript("OnUpdate", function(button, elapsed) Tick(region, sample, button, elapsed) end)
    region.secretAuraSamples[slot] = sample
  end
  return sample
end

local function SpellLook(spellID)
  local info = spellID and C_Spell.GetSpellInfo(spellID)
  if not info then return FALLBACK_NAME, FALLBACK_ICON end
  return info.name or FALLBACK_NAME, info.iconID or FALLBACK_ICON
end

function Display.ShowPreview(region, data, StyleSample)
  local spellIDs = Display.GetSpellIDs(Display.GetTrigger(data), false) or {}
  local perUnit = math.min(math.max(#spellIDs, 1), Display.MaxAuras(data))
  local width, height = Display.Dimensions(data)
  local growth = GROWTHS[Display.Growth(data)] or GROWTHS.RIGHT
  local settings = data.blizzardAuraDisplay
  local spacing = settings and settings.spacing or 6
  local missing = Display.PreviewShowsMissing(data) and true or false

  Display.RestorePreviewRegion(region)
  Display.HidePreview(region)
  region.secretAuraSamplesActive = true

  local units = Display.FlowPreviewUnits and Display.FlowPreviewUnits(data) or { false }
  local center = growth.centered and (perUnit - 1) / 2 or 0
  for slot = 1, perUnit * #units do
    local position = (slot - 1) % perUnit + 1
    local sample = SampleAt(region, slot)
    local button = sample.button
    sample.previewUnit = units[math.floor((slot - 1) / perUnit) + 1]
    button.expires = GetTime() + SAMPLE_DURATION
    button.inverse = data.inverse == true
    sample.name, sample.iconID = SpellLook(spellIDs[position])
    StyleSample(sample, data)

    local step = position - 1 - center
    button:ClearAllPoints()
    button:SetPoint(growth.point, region, growth.point,
      growth.x * step * (width + spacing), growth.y * step * (height + spacing))
    button.staticSample = missing
    Display.FillSampleBindings(button, missing and Display.SingleIcon(data) or sample.iconID, sample.name, data, not missing)
    if missing then Display.StyleMissingIcon(sample, data) end
    button:Show()
  end
end

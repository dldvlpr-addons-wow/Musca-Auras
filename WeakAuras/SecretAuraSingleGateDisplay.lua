-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local AttachedElements = Shared.AttachedElements
local CLIP_TEMPLATE = Shared.CLIP_TEMPLATE
local COUNTDOWN_FORMAT_PREFIX = Shared.COUNTDOWN_FORMAT_PREFIX
local EDGE_MARGIN = Shared.EDGE_MARGIN
local GLOW_BUDGET = Shared.GLOW_BUDGET
local GLOW_SPEED = Shared.GLOW_SPEED
local IsTextOfKind = Shared.IsTextOfKind
local ReportProblem = Shared.ReportProblem
local WHITE_TEXTURE = Shared.WHITE_TEXTURE

local function InvisibleBar(parentRegion)
  local fillBar = CreateFrame("StatusBar", nil, parentRegion)
  fillBar:SetStatusBarTexture(WHITE_TEXTURE)
  fillBar:SetStatusBarColor(0, 0, 0, 0)
  return fillBar
end

local function SpanClip(clip, startFrame, startPoint, startX, endFrame, endPoint, endX)
  clip:ClearAllPoints()
  clip:SetPoint("TOPLEFT", startFrame, startPoint, startX, 0)
  clip:SetPoint("BOTTOMRIGHT", endFrame, endPoint, endX or 0, 0)
  clip:SetClipsChildren(true)
end

local function GlowMargin(element, iconWidth, iconHeight)
  local scale = element.glowScale or 1
  local offset = math.max(math.abs(element.glowXOffset or 0), math.abs(element.glowYOffset or 0))
  return math.ceil(math.max(iconWidth, iconHeight) * 0.5 * scale) + offset + 4
end

function AuraDisplay.TimedGlowHolder(nativeDisplay, auraData, index, hostFrame)
  if nativeDisplay.preview then return end
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local edge, element, glowIndex, above, elapsed = AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if not edge or glowIndex ~= index then return end
  local lateTotal = AuraDisplay.LateGlowTotal(auraTrigger)
  if not lateTotal then return false end
  if elapsed then
    edge, above = lateTotal - math.min(edge, lateTotal), true
  elseif lateTotal <= edge then
    return false
  end
  local auraButton = nativeDisplay.button
  local glow = nativeDisplay.lateGlow
  if not glow then
    local clip = CreateFrame("Frame", nil, nativeDisplay.gateClip or auraButton, CLIP_TEMPLATE)
    local holder = CreateFrame("Frame", nil, clip)
    holder:SetAllPoints(auraButton)
    glow = { bar = InvisibleBar(auraButton), clip = clip, holder = holder }
    nativeDisplay.lateGlow = glow
  end
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local scale = math.min(GLOW_SPEED, GLOW_BUDGET / lateTotal)
  local margin = GlowMargin(element or {}, iconWidth, iconHeight)
  local fillBar, clip = glow.bar, glow.clip
  fillBar:SetSize(lateTotal * scale, iconHeight + 2 * margin)
  pcall(function()
    auraButton:SetDurationBar(fillBar, { direction = Enum.StatusBarTimerDirection.RemainingTime })
  end)
  fillBar:ClearAllPoints()
  local texture = fillBar:GetStatusBarTexture()
  local shift = edge * scale
  if above then
    fillBar:SetPoint("LEFT", auraButton, "LEFT", -margin - shift, 0)
    SpanClip(clip, fillBar, "TOPLEFT", shift, texture, "BOTTOMRIGHT")
  else
    fillBar:SetPoint("LEFT", auraButton, "RIGHT", margin - shift, 0)
    SpanClip(clip, texture, "TOPRIGHT", 0, fillBar, "BOTTOMLEFT", shift)
  end
  fillBar:Show()
  clip:SetFrameLevel(hostFrame:GetFrameLevel() + 1)
  clip:Show()
  return glow.holder
end

local function GateFill(iconWidth, iconHeight)
  local largest = math.max(iconWidth, iconHeight)
  local margin = math.ceil(largest * 0.5) + 8
  local fontSize = math.min(250, math.ceil(largest + 2 * margin))
  local line = ("W"):rep(math.ceil((iconWidth + 2 * margin) / (fontSize / 2)) + 1)
  local lines = {}
  for row = 1, math.max(1, math.ceil((iconHeight + 2 * margin) / fontSize)) do lines[row] = line end
  return table.concat(lines, "\n"), fontSize, margin
end

local formatterCache = {}

local function RangeFormatter(lower, upper, fill)
  local slotKey = lower .. "|" .. tostring(upper) .. "|" .. fill
  if formatterCache[slotKey] then return formatterCache[slotKey] end
  local breakpoints
  if upper and upper < lower then
    breakpoints = { { threshold = 0, format = "" } }
  elseif lower <= 0 then
    breakpoints = { { threshold = 0, format = fill } }
  else
    breakpoints = { { threshold = 0, format = "" }, { threshold = lower, format = fill } }
  end
  if upper and upper >= lower then breakpoints[#breakpoints + 1] = { threshold = upper + EDGE_MARGIN, format = "" } end
  local ok, formatter = pcall(function()
    local created = C_StringUtil.CreateNumericRuleFormatter()
    created:SetBreakpoints(breakpoints)
    return created
  end)
  if not ok then return nil, formatter end
  formatterCache[slotKey] = formatter
  return formatter
end

local clearCurve

local function InvisibleCurve()
  if not clearCurve then
    clearCurve = C_CurveUtil.CreateColorCurve()
    clearCurve:SetType(Enum.LuaCurveType.Step)
    clearCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
  end
  return clearCurve
end

local function LayGateText(auraButton, caption, fontSize, margin)
  caption:SetFont(STANDARD_TEXT_FONT, fontSize, "")
  caption:SetWidth(0)
  caption:SetJustifyH("LEFT")
  caption:ClearAllPoints()
  caption:SetPoint("LEFT", auraButton, "LEFT", -margin - 2, 0)
  caption:SetWordWrap(false)
end

local function BindGateText(auraButton, caption, property, formatter)
  local bound = Enum.DurationTextBindingProperty[property]
  return pcall(auraButton.SetDurationText, auraButton, caption, {
    textFormat = { formatString = "{}", components = { { property = bound, formatter = formatter } } },
    textColor = { property = bound, curve = InvisibleCurve() },
  })
end

local function StyleCountdown(sweepCooldown, nativeDisplay, element)
  if sweepCooldown.GetCountdownFontString then
    local label = sweepCooldown:GetCountdownFontString()
    if label then AuraDisplay.StyleText(label, nativeDisplay, AuraDisplay.TextSettings(element), "text", 18, "CENTER", 0, 0) end
  end
  sweepCooldown:SetCountdownFormatter(nil)
  local format = element[COUNTDOWN_FORMAT_PREFIX .. "format"]
  if format == nil or format == -1 then return end
  local ok, formatter = pcall(Private.GetDurationTextFormatter,
    element[COUNTDOWN_FORMAT_PREFIX .. "legacy_floor"] and 0 or 99,
    element[COUNTDOWN_FORMAT_PREFIX .. "dynamic_threshold"] or 3,
    element[COUNTDOWN_FORMAT_PREFIX .. "precision"] or 1,
    format == -2, format)
  if ok and formatter then sweepCooldown:SetCountdownFormatter(formatter) end
end

local function WarnStack(auraData, refusal)
  ReportProblem(auraData, "Blizzard refused the Stack Count check: " .. tostring(refusal))
end

local function FillStackTexts(nativeDisplay, auraData, count)
  for index, element in AttachedElements(auraData, "subtext") do
    local shared = (nativeDisplay.sharedElements or {})[index]
    if shared and shared.text and IsTextOfKind(element, "stack") then
      shared.text:SetText(AuraDisplay.StackTextFor(auraData, "sub." .. index .. ".text_color", count))
    end
  end
  if auraData.regionType == "text" and nativeDisplay.mainText and AuraDisplay.TextKind(auraData.displayText or "") == "stack" then
    nativeDisplay.mainText:SetText(AuraDisplay.StackTextFor(auraData, "color", count))
  end
end

local function BindExactStack(nativeDisplay, auraData, count)
  local auraButton = nativeDisplay.button
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local formatter, refusal = RangeFormatter(count, count, fill)
  if not formatter then
    WarnStack(auraData, refusal)
    return false
  end
  local caption = nativeDisplay.stackGateText
  if not caption then
    caption = auraButton:CreateFontString(nil, "OVERLAY")
    nativeDisplay.stackGateText = caption
  end
  LayGateText(auraButton, caption, fontSize, margin)
  local ok
  ok, refusal = pcall(auraButton.SetApplicationCount, auraButton, caption, { formatter = formatter })
  if not ok then
    caption:Hide()
    WarnStack(auraData, refusal)
    return false
  end
  caption:Show()
  SpanClip(nativeDisplay.gateClip, caption, "TOPLEFT", 0, caption, "BOTTOMRIGHT")
  FillStackTexts(nativeDisplay, auraData, count)
  caption:SetAlpha(0)
  return true
end

local function BindStackBar(nativeDisplay, auraData, kind, count)
  local auraButton = nativeDisplay.button
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local margin = math.ceil(math.max(iconWidth, iconHeight) * 0.5) + 8
  local step = iconWidth + 2 * margin
  local capacity = kind == "atLeast" and count or count + 1
  local fillBar = nativeDisplay.stackGate
  if not fillBar then
    fillBar = InvisibleBar(auraButton)
    nativeDisplay.stackGate = fillBar
  end
  fillBar:SetSize(capacity * step, iconHeight + 2 * margin)
  fillBar:ClearAllPoints()
  local texture = fillBar:GetStatusBarTexture()
  if kind == "atLeast" then
    fillBar:SetPoint("LEFT", auraButton, "LEFT", -margin - (count - 1) * step, 0)
    SpanClip(nativeDisplay.gateClip, fillBar, "TOPLEFT", (count - 1) * step, texture, "BOTTOMRIGHT")
  else
    fillBar:SetPoint("RIGHT", auraButton, "RIGHT", margin, 0)
    SpanClip(nativeDisplay.gateClip, texture, "TOPRIGHT", 0, fillBar, "BOTTOMRIGHT")
  end
  fillBar:Show()
  local ok, refusal = pcall(auraButton.SetApplicationBar, auraButton, fillBar, { maxApplications = capacity })
  if not ok then
    fillBar:Hide()
    WarnStack(auraData, refusal)
    return false
  end
  return true
end

local function StyleStackGate(nativeDisplay, auraData, suppressed)
  local kind, count
  if not suppressed then kind, count = AuraDisplay.StackGate(auraData) end
  if kind ~= "exactly" and nativeDisplay.stackGateText then nativeDisplay.stackGateText:Hide() end
  if (kind == nil or kind == "exactly") and nativeDisplay.stackGate then
    nativeDisplay.button:ClearApplicationBar()
    nativeDisplay.stackGate:Hide()
  end
  if kind == nil then return false end
  if kind == "exactly" then return BindExactStack(nativeDisplay, auraData, count) end
  return BindStackBar(nativeDisplay, auraData, kind, count)
end

local function PickDurationGate(auraData)
  local lower, upper = AuraDisplay.DurationGate(auraData)
  if lower then return lower, upper, "TotalDuration", "Total Duration" end
  lower, upper = AuraDisplay.RemainingGateRange(auraData)
  if lower then return lower, upper, "RemainingDuration", "Remaining Time" end
end

local function HideDurationTexts(nativeDisplay, auraData)
  local countdown
  if auraData.regionType == "text" and nativeDisplay.mainText and AuraDisplay.TextKind(auraData.displayText or "") == "duration" then
    nativeDisplay.mainText:Hide()
  end
  for index, element in AttachedElements(auraData, "subtext") do
    if IsTextOfKind(element, "duration") then
      local shared = (nativeDisplay.sharedElements or {})[index]
      if shared and shared.text then shared.text:Hide() end
      countdown = countdown or element
    end
  end
  return countdown
end

local function StyleGateCountdown(nativeDisplay, auraData, element, lower)
  local sweepCooldown, auraButton = nativeDisplay.cooldown, nativeDisplay.button
  sweepCooldown:Show()
  if auraData.cooldown == false then
    sweepCooldown:SetDrawSwipe(false)
    sweepCooldown:SetDrawEdge(false)
  end
  sweepCooldown:SetHideCountdownNumbers(false)
  sweepCooldown:SetUseAuraDisplayTime(true)
  sweepCooldown:SetMinimumCountdownDuration(lower * 1000)
  StyleCountdown(sweepCooldown, nativeDisplay, element)
  auraButton:SetDurationCooldown(sweepCooldown)
end

function AuraDisplay.StyleDurationGate(nativeDisplay, auraData)
  if nativeDisplay.preview or not nativeDisplay.gateClip then return end
  local lower, upper, property, label = PickDurationGate(auraData)
  local gateText = nativeDisplay.gateText
  if not lower then
    if gateText then gateText:Hide() end
    if nativeDisplay.cooldown then
      nativeDisplay.cooldown:SetCountdownFormatter(nil)
      nativeDisplay.cooldown:SetMinimumCountdownDuration(0)
    end
    if StyleStackGate(nativeDisplay, auraData) then return end
    nativeDisplay.gateClip:SetClipsChildren(false)
    nativeDisplay.gateClip:SetAllPoints(nativeDisplay.button)
    return
  end
  StyleStackGate(nativeDisplay, auraData, true)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local formatter, refusal = RangeFormatter(lower, upper, fill)
  if formatter then
    LayGateText(nativeDisplay.button, gateText, fontSize, margin)
    local ok
    ok, refusal = BindGateText(nativeDisplay.button, gateText, property, formatter)
    if not ok then formatter = nil end
  end
  if not formatter then
    ReportProblem(auraData, ("Blizzard refused the %s check: %s"):format(label, tostring(refusal)))
    return
  end
  gateText:Show()
  SpanClip(nativeDisplay.gateClip, gateText, "TOPLEFT", 0, gateText, "BOTTOMRIGHT")
  local countdown = HideDurationTexts(nativeDisplay, auraData)
  if countdown and auraData.regionType == "icon" and property == "TotalDuration" and nativeDisplay.cooldown then
    StyleGateCountdown(nativeDisplay, auraData, countdown, lower)
  end
end

Shared.BindGateText = BindGateText
Shared.GateFill = GateFill
Shared.HideDurationTexts = HideDurationTexts
Shared.LayGateText = LayGateText
Shared.RangeFormatter = RangeFormatter
Shared.SpanClip = SpanClip
Shared.StyleCountdown = StyleCountdown

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local InPreview = Shared.InPreview
local RefreshPreviewNotice = Shared.RefreshPreviewNotice

local AURA_GROUP = "Auras"
local GLOW_SLOT = "UnitGlow"
local APPLY_BUDGET_MS = 8
local LOGIN_POLL_SECONDS = 0.2
local EDITOR_FIRST_BATCH = 2
local EDITOR_BATCH_SIZE = 4
local EDITOR_APPLY_BATCH = 2
local GLOW_MARGIN_RATIO = 0.2
local DEFAULT_GLOW_COLOR = { 1, 0.82, 0, 1 }
local PENDING_TEXT = L["Display > Aura (Modern) Settings changes will apply when the game stops hiding combat data."]
local FALLBACK_FONT = "Fonts\\ARIALN.TTF"
local HIDDEN_FIELDS = { "icon", "cooldown", "button", "bar", "secretBar", "text", "background" }
local GROUP_UNITS = { group = true, party = true, raid = true }
local SOUND_UNITS = { group = true, party = true, raid = true, member = true }

local Parts, Buttons, Glow, Instances, Units, Queues, Plates, Events = {}, {}, {}, {}, {}, {}, {}, {}
local liveRegions = {}
local queuedApplies = setmetatable({}, { __mode = "k" })

local function Warn(auraData, name, text)
  if text then
    Private.AuraWarnings.UpdateWarning(auraData.uid, name, "warning", text)
  else
    Private.AuraWarnings.UpdateWarning(auraData.uid, name)
  end
end

local function ReadLevel(frame)
  local level = frame:GetFrameLevel()
  if issecretvalue(level) then return nil end
  return level
end

local function PendingSet(set)
  local list = {}
  for key in pairs(set) do list[#list + 1] = key end
  return list
end

local runRegion, runData
local function RunApply() Display.Apply(runRegion, runData) end
local function ApplyIsolated(auraRegion, auraData)
  runRegion, runData = auraRegion, auraData
  xpcall(RunApply, geterrorhandler())
end

local function UsesUnitFrames(auraData)
  return auraData.anchorFrameType == "UNITFRAME" or Display.FlowFrameMode(auraData) == "UNITFRAME"
end

function Parts.Targets(auraRegion)
  local targets = {}
  local function Take(target)
    if target and target.SetAlpha then targets[#targets + 1] = target end
  end
  local function TakeAll(list)
    for _, target in ipairs(list or {}) do Take(target) end
  end
  for _, fieldName in ipairs(HIDDEN_FIELDS) do Take(auraRegion[fieldName]) end
  if auraRegion.regionType == "progresstexture" then
    Take(auraRegion.foreground and auraRegion.foreground.texture)
    Take(auraRegion.background and auraRegion.background.texture)
    TakeAll(auraRegion.foregroundSpinner and auraRegion.foregroundSpinner.textures)
    TakeAll(auraRegion.backgroundSpinner and auraRegion.backgroundSpinner.textures)
    for _, extra in ipairs(auraRegion.extraTextures or {}) do Take(extra.texture) end
    for _, spinner in ipairs(auraRegion.extraSpinners or {}) do TakeAll(spinner.textures) end
  end
  Take(auraRegion.bar and auraRegion.bar.bg)
  for _, subRegion in ipairs(auraRegion.subRegions or {}) do
    if not subRegion.secretAuraDetached then Take(subRegion) end
  end
  return targets
end

function Parts.ReturnAlphas(auraRegion)
  local remembered = auraRegion.blizzardSuppressed
  if remembered then
    for target, alpha in pairs(remembered) do target:SetAlpha(alpha) end
  end
  auraRegion.blizzardSuppressed = nil
end

function Parts.HideNotice(auraRegion)
  local notice = auraRegion.secretAuraPreviewNotice
  if notice then notice:Hide() end
end

function Parts.Hide(auraRegion)
  local state = auraRegion.blizzardAuraDisplay
  if InPreview() and not auraRegion.secretAuraSamplesActive and not (state and state.previewHasAuras) then
    Parts.ReturnAlphas(auraRegion)
    RefreshPreviewNotice(auraRegion)
    return
  end
  Parts.HideNotice(auraRegion)
  local remembered = auraRegion.blizzardSuppressed
  if not remembered then
    remembered = {}
    auraRegion.blizzardSuppressed = remembered
  end
  for _, target in ipairs(Parts.Targets(auraRegion)) do
    if remembered[target] == nil then remembered[target] = target:GetAlpha() end
    target:SetAlpha(0)
  end
end

function Parts.Wrap(auraRegion)
  local update = auraRegion.blizzardOriginalUpdate
  if not (update and auraRegion.Update == update.outer) then
    local inner = auraRegion.Update
    local outer = function(...)
      if inner then inner(...) end
      Parts.Hide(auraRegion)
      if Display.UpdateMissingSource then Display.UpdateMissingSource(auraRegion) end
    end
    auraRegion.blizzardOriginalUpdate = { inner = inner, outer = outer }
    auraRegion.Update = outer
  end
  local preShow = auraRegion.blizzardOriginalPreShow
  if not (preShow and auraRegion.PreShow == preShow.outer) then
    local outer = function() Parts.Hide(auraRegion) end
    auraRegion.blizzardOriginalPreShow = { inner = auraRegion.PreShow, outer = outer }
    auraRegion.PreShow = outer
  end
  Parts.Hide(auraRegion)
end

function Parts.Unwrap(auraRegion, method, recordField)
  local record = auraRegion[recordField]
  if not record then return end
  if auraRegion[method] == record.outer then auraRegion[method] = record.inner end
  auraRegion[recordField] = nil
end

function Display.Restore(auraRegion)
  if Display.HidePreview then Display.HidePreview(auraRegion) end
  if Display.RestorePreviewRegion then Display.RestorePreviewRegion(auraRegion) end
  Parts.HideNotice(auraRegion)
  auraRegion.secretAuraConditionValues = nil
  Parts.ReturnAlphas(auraRegion)
  Parts.Unwrap(auraRegion, "Update", "blizzardOriginalUpdate")
  Parts.Unwrap(auraRegion, "PreShow", "blizzardOriginalPreShow")
end

function Buttons.ElementFrame(buttonState, key)
  local frames = buttonState.elementFrames
  if not frames then
    frames = {}
    buttonState.elementFrames = frames
  end
  local frame = frames[key]
  if not frame then
    frame = CreateFrame("Frame", nil, buttonState.gateClip or buttonState.button)
    frame:SetAllPoints(buttonState.button)
    frame:EnableMouse(false)
    frames[key] = frame
  end
  return frame
end

function Buttons.StyleSample(sample, auraData)
  Display.StyleAppearance(sample, Display.PrepareConditionAppearance(auraData), Buttons.ElementFrame, Display.StyleText)
end

function Display.StyleText(label, buttonState, settings, fieldKey, iconSize, anchorRef, defaultX, defaultY)
  local mediaLib = LibStub("LibSharedMedia-3.0")
  local outline = settings[fieldKey .. "Outline"]
  if outline == "None" then
    outline = ""
  elseif not outline then
    outline = "OUTLINE"
  end
  local fontName = settings[fieldKey .. "Font"]
  Private.ApplyTextFont(label, nil,
    fontName and mediaLib:Fetch("font", fontName) or FALLBACK_FONT,
    settings[fieldKey .. "Size"] or iconSize,
    outline,
    settings[fieldKey .. "ShadowColor"] or { 0, 0, 0, 0 },
    settings[fieldKey .. "ShadowX"] or 1,
    settings[fieldKey .. "ShadowY"] or -1)
  local color = settings[fieldKey .. "Color"] or { 1, 1, 1, 1 }
  label:SetTextColor(color[1], color[2], color[3], color[4] or 1)

  local anchor = settings[fieldKey .. "Anchor"] or anchorRef
  local target, relative, ring = buttonState.button, anchor, nil
  local prefix = anchor:sub(1, 6)
  if prefix == "INNER_" then
    target, relative, ring = buttonState.inner, anchor:sub(7), "inner"
  elseif prefix == "OUTER_" then
    target, relative, ring = buttonState.outer, anchor:sub(7), "outer"
  end
  local selfPoint = settings[fieldKey .. "SelfPoint"] or (ring and "AUTO" or anchor)
  if selfPoint == "AUTO" then
    if ring == "inner" then
      selfPoint = relative
    elseif ring == "outer" then
      selfPoint = Private.inverse_point_types[relative] or "CENTER"
    else
      selfPoint = "CENTER"
    end
  end
  label:ClearAllPoints()
  label:SetPoint(selfPoint, target, relative, settings[fieldKey .. "X"] or defaultX or 0, settings[fieldKey .. "Y"] or defaultY or 0)
  label:SetJustifyH(settings[fieldKey .. "Justify"] or "CENTER")
end

function Display.RefreshShownAnimations(nativeState)
  local button = nativeState.button
  if nativeState.preview or not button or not button.SetDispelTypeText then return end
  local probe = nativeState.updateProbe
  if not probe then
    probe = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nativeState.updateProbe = probe
  end
  probe:SetAlpha(0)
  button:SetDispelTypeText(probe, { showWhenHarmful = false })
end

function Display.StyleNative(buttonState, auraData, auraRegion)
  Display.StyleAppearance(buttonState, Display.PrepareConditionAppearance(auraData), Buttons.ElementFrame, Display.StyleText)
  Display.ApplyConditionAppearance(buttonState, auraRegion, auraData)
  Display.RefreshShownAnimations(buttonState)
end

function Display.SetupAuraButton(kind, auraRegion, holder, button)
  local gateClip = CreateFrame("Frame", nil, button, "DisableUntrustedLayoutScriptsTemplate")
  local rings = {}
  for _, ringName in ipairs({ "inner", "outer" }) do
    local ring = CreateFrame("Frame", nil, button)
    ring:SetPoint("CENTER", button, "CENTER")
    ring:EnableMouse(false)
    rings[ringName] = ring
  end
  local border = gateClip:CreateTexture(nil, "BACKGROUND")
  local overlayFrame = CreateFrame("Frame", nil, gateClip)

  gateClip:SetClipsChildren(true)
  for _, filler in ipairs({ gateClip, border, overlayFrame }) do filler:SetAllPoints(button) end
  button:EnableMouse(false)

  local buttonState = {
    container = holder, button = button, gateClip = gateClip, gateText = button:CreateFontString(nil, "BACKGROUND"),
    inner = rings.inner, outer = rings.outer, border = border, overlay = overlayFrame,
  }
  local sharedBase = Buttons.ElementFrame(buttonState, "sharedBase")
  local icon = sharedBase:CreateTexture(nil, "ARTWORK")
  local sweepFrame = CreateFrame("Cooldown", nil, sharedBase, "CooldownFrameTemplate")
  sweepFrame:SetAllPoints(icon)
  sweepFrame:SetDrawBling(false)
  sweepFrame:SetHideCountdownNumbers(true)
  button:SetIcon(icon)
  button:SetDurationCooldown(sweepFrame)

  local cooldownLevel = ReadLevel(sweepFrame)
  if cooldownLevel then overlayFrame:SetFrameLevel(cooldownLevel + 1) end

  buttonState.icon, buttonState.cooldown = icon, sweepFrame
  Display.StyleNative(buttonState, kind.data, auraRegion)
  kind.buttons[#kind.buttons + 1] = buttonState
end

local function IdSet(list)
  local set, count = {}, 0
  for _, id in ipairs(list or {}) do
    local number = tonumber(id)
    if number then
      set[number] = true
      count = count + 1
    end
  end
  return set, count
end

function Display.CandidateFilters(auraData)
  local triggerConfig = Display.GetTrigger(auraData)
  local candidateList = {}

  local operator, seconds = Display.TotalFilter(triggerConfig)
  if operator == "<=" then
    candidateList.maxDuration = seconds + 0.05
  elseif operator == "=" then
    candidateList.maxDuration = seconds + 0.5
  end

  if Display.UsesSpellIDs(triggerConfig) or Display.UsesRankSpellIDs(triggerConfig) then
    candidateList.includeSpellIDs = IdSet(Display.GetSpellIDs(triggerConfig, true))
  end
  if Display.UsesExcludedSpellIDs(triggerConfig) then
    local excluded, count = IdSet(triggerConfig.excludedAuraSpellIDs)
    if count > 0 then candidateList.excludeSpellIDs = excluded end
  end

  for _, row in ipairs(Display.booleanFilters) do
    local key = type(row) == "table" and (row.key or row[1]) or row
    if Display.FilterApplies(key, triggerConfig)
      and ((key ~= "nameplateShowAll" and key ~= "nameplateShowPersonal") or triggerConfig.unit == "nameplate") then
      candidateList[key] = triggerConfig[key]
    end
  end

  for _, fieldName in ipairs({ "includeDispelTypes", "excludeDispelTypes" }) do
    local source = triggerConfig[fieldName]
    if type(source) == "table" and next(source) ~= nil then
      local copy = {}
      for key, value in pairs(source) do copy[key] = value end
      candidateList[fieldName] = copy
    end
  end
  return Display.ApproximateFilters(triggerConfig, candidateList)
end

Shared.APPLY_BUDGET_MS = APPLY_BUDGET_MS
Shared.AURA_GROUP = AURA_GROUP
Shared.ApplyIsolated = ApplyIsolated
Shared.Buttons = Buttons
Shared.DEFAULT_GLOW_COLOR = DEFAULT_GLOW_COLOR
Shared.EDITOR_APPLY_BATCH = EDITOR_APPLY_BATCH
Shared.EDITOR_BATCH_SIZE = EDITOR_BATCH_SIZE
Shared.EDITOR_FIRST_BATCH = EDITOR_FIRST_BATCH
Shared.Events = Events
Shared.GLOW_MARGIN_RATIO = GLOW_MARGIN_RATIO
Shared.GLOW_SLOT = GLOW_SLOT
Shared.GROUP_UNITS = GROUP_UNITS
Shared.Glow = Glow
Shared.Instances = Instances
Shared.LOGIN_POLL_SECONDS = LOGIN_POLL_SECONDS
Shared.PENDING_TEXT = PENDING_TEXT
Shared.Parts = Parts
Shared.PendingSet = PendingSet
Shared.Plates = Plates
Shared.Queues = Queues
Shared.ReadLevel = ReadLevel
Shared.SOUND_UNITS = SOUND_UNITS
Shared.Units = Units
Shared.UsesUnitFrames = UsesUnitFrames
Shared.Warn = Warn
Shared.liveRegions = liveRegions
Shared.queuedApplies = queuedApplies

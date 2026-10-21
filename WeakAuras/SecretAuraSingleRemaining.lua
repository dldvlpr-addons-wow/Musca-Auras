-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local BindGateText = Shared.BindGateText
local DisableMissing = Shared.DisableMissing
local EnsureMissing = Shared.EnsureMissing
local FOLLOWER_KEYS = Shared.FOLLOWER_KEYS
local GateFill = Shared.GateFill
local IsTable = Shared.IsTable
local LIST_GROUP = Shared.LIST_GROUP
local LayGateText = Shared.LayGateText
local RangeFormatter = Shared.RangeFormatter
local ReportProblem = Shared.ReportProblem
local SLOT_GATE = Shared.SLOT_GATE
local SLOT_ICON = Shared.SLOT_ICON
local TEXCOORD_SCALE = Shared.TEXCOORD_SCALE
local WINDOW_RANGES = Shared.WINDOW_RANGES
local WantsMissing = Shared.WantsMissing
local WindowEdge = Shared.WindowEdge

local function RemainingColorCurve(auraData, operator, seconds)
  local color = IsTable(auraData.color) and auraData.color or {}
  local red, green, blue = color[1] or 1, color[2] or 1, color[3] or 1
  local before = CreateColor(red, green, blue, color[4] or 1)
  local after = CreateColor(red, green, blue, 0)
  if operator == ">" or operator == ">=" then before, after = after, before end
  local edge = WindowEdge(operator, seconds)
  local stepCurve = C_CurveUtil.CreateColorCurve()
  stepCurve:SetType(Enum.LuaCurveType.Step)
  if edge > 0 then stepCurve:AddPoint(0, before) end
  stepCurve:AddPoint(edge, after)
  return stepCurve
end

local function IconTag(auraData)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local left, right, top, bottom = AuraDisplay.IconTexCoords(auraData)
  local function scaled(value) return Round(value * TEXCOORD_SCALE) end
  return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(tostring(AuraDisplay.SingleIcon(auraData)), iconHeight, iconWidth,
    TEXCOORD_SCALE, TEXCOORD_SCALE, scaled(left), scaled(right), scaled(top), scaled(bottom))
end

local function AcquireSlot(instance, auraRegion, auraData, auraTrigger, slotKey)
  local singleState, auraContainer = instance.single, instance.container
  local filterString, candidateList = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData)
  local remainSlot = singleState.slots[slotKey]
  if not remainSlot then
    local captured
    local ok, refusal = pcall(auraContainer.AddAuraSlot, auraContainer, slotKey, filterString, {
      candidateFilters = candidateList,
      initializeFrame = function(auraButton)
        auraButton:EnableMouse(false)
        captured = auraButton
      end,
    })
    if not ok or not captured then
      ReportProblem(auraData, "Blizzard could not create the Remaining Time display: " .. tostring(ok and "no slot" or refusal))
      return nil
    end
    remainSlot = { button = captured }
    singleState.slots[slotKey] = remainSlot
  end
  auraContainer:SetAuraSlotEnabled(slotKey, false)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  remainSlot.button:SetSize(iconWidth, iconHeight)
  remainSlot.button:ClearAllPoints()
  remainSlot.button:SetPoint("TOPLEFT", AuraDisplay.ContentAnchor(auraRegion), "TOPLEFT")
  auraContainer:SetAuraSlotFilterString(slotKey, filterString)
  auraContainer:SetAuraSlotCandidateFilters(slotKey, candidateList)
  auraContainer:SetAuraSlotSortMethod(slotKey, AuraDisplay.SortOrder(auraData, auraTrigger))
  remainSlot.used = true
  return remainSlot
end

local function SlotText(remainSlot, centered)
  if not remainSlot.text then
    remainSlot.text = remainSlot.button:CreateFontString()
    if centered then
      remainSlot.text:SetFont(STANDARD_TEXT_FONT, 12, "")
      remainSlot.text:SetPoint("CENTER")
    end
  end
  return remainSlot.text
end

local function BindRemainingIcon(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  local remainSlot = AcquireSlot(instance, auraRegion, auraData, auraTrigger, SLOT_ICON)
  if not remainSlot then return false end
  local caption = SlotText(remainSlot, true)
  remainSlot.button:ClearDurationText()
  local ok, refusal = pcall(remainSlot.button.SetDurationText, remainSlot.button, caption, {
    textFormat = { formatString = IconTag(auraData), components = {} },
    textColor = {
      property = Enum.DurationTextBindingProperty.RemainingDuration,
      curve = RemainingColorCurve(auraData, operator, seconds),
    },
  })
  if not ok then
    ReportProblem(auraData, "Blizzard refused the Remaining Time icon: " .. tostring(refusal))
    return false
  end
  local iconHost = instance.container
  iconHost:SetAuraSlotEnabled(SLOT_ICON, true)
  return true
end

local function BindRemainingGate(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  local remainSlot = AcquireSlot(instance, auraRegion, auraData, auraTrigger, SLOT_GATE)
  if not remainSlot then return end
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local fill, fontSize, margin = GateFill(iconWidth, iconHeight)
  local lower, upper = WINDOW_RANGES[operator](seconds)
  local formatter, refusal = RangeFormatter(lower, upper, fill)
  local caption = SlotText(remainSlot)
  if formatter then
    LayGateText(remainSlot.button, caption, fontSize, margin)
    local ok
    ok, refusal = BindGateText(remainSlot.button, caption, "RemainingDuration", formatter)
    if not ok then formatter = nil end
  end
  if not formatter then
    ReportProblem(auraData, "Blizzard refused the Remaining Time check: " .. tostring(refusal))
    return
  end
  caption:Show()
  instance.container.remainingGateText = caption
  instance.container:SetAuraSlotEnabled(SLOT_GATE, true)
end

local function ConfigureRemainingSlots(instance, auraRegion, auraData, auraTrigger)
  local operator, seconds = AuraDisplay.RemainingWindow(auraTrigger)
  if BindRemainingIcon(instance, auraRegion, auraData, auraTrigger, operator, seconds) then
    BindRemainingGate(instance, auraRegion, auraData, auraTrigger, operator, seconds)
  end
end

function AuraDisplay.ConfigureSingle(instance, auraRegion, auraData, index)
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local valid = index == 1 and AuraDisplay.ValidateSingle(auraData, auraTrigger) == nil
  local unique = valid and AuraDisplay.IsSingle(auraTrigger, auraData)
  if valid then
    AuraDisplay.WatchAuraLearning(auraRegion, auraData, auraTrigger, (AuraDisplay.LateGlowSpec(auraData, auraTrigger)))
  elseif index == 1 then
    AuraDisplay.ReleaseAuraLearning(auraRegion)
  end
  local followsFound = valid and not unique and AuraDisplay.FoundFollow(auraData, auraTrigger) ~= nil
  if not unique and not followsFound and not instance.single then return end
  local singleState = instance.single or {}
  instance.single = singleState
  singleState.slots = singleState.slots or {}
  for _, remainSlot in pairs(singleState.slots) do remainSlot.used = false end
  singleState.foundMode = followsFound
  if (unique and WantsMissing(auraTrigger)) or followsFound then
    EnsureMissing(instance, auraRegion, auraData, auraTrigger)
  else
    DisableMissing(singleState)
  end
  local auraContainer = instance.container
  auraContainer.remainingGateText = nil
  if unique and AuraDisplay.RemainingWindow(auraTrigger) then ConfigureRemainingSlots(instance, auraRegion, auraData, auraTrigger) end
  for _, nativeDisplay in ipairs(instance.buttons) do AuraDisplay.AttachRemainingHolders(nativeDisplay, auraData) end
  for slotKey, remainSlot in pairs(singleState.slots) do
    if not remainSlot.used then pcall(auraContainer.SetAuraSlotEnabled, auraContainer, slotKey, false) end
  end
  local draws = not unique or AuraDisplay.RawShowOn(auraTrigger) ~= "showOnMissing"
  singleState.listDisabled = not draws
  auraContainer:SetAuraGroupEnabled(LIST_GROUP, draws)
  for _, nativeDisplay in ipairs(instance.buttons) do nativeDisplay.button:SetAlpha(draws and 1 or 0) end
end

local function BindUnit(owner, slotKey, unitToken)
  local bound = slotKey == "container" and "boundUnit" or slotKey .. "BoundUnit"
  if unitToken ~= nil and unitToken ~= owner[bound] then
    owner[slotKey]:SetEnabled(false)
    owner[slotKey]:SetUnit(unitToken)
    owner[bound] = unitToken
  end
end

function AuraDisplay.RefreshSingle(instance, unitToken, shown)
  local singleState = instance.single
  if not singleState then return end
  if shown and singleState.listDisabled then
    pcall(instance.container.SetAuraGroupEnabled, instance.container, LIST_GROUP, false)
  end
  local missingState = singleState.missing
  if not (missingState and missingState.active) then return end
  BindUnit(missingState, "container", unitToken)
  shown = (shown and unitToken ~= nil) and true or false
  missingState.container:SetShown(shown)
  missingState.container:SetEnabled(shown)
  for _, slotKey in ipairs(FOLLOWER_KEYS) do
    local trailer = missingState[slotKey]
    if trailer and missingState[slotKey .. "Active"] then
      BindUnit(missingState, slotKey, unitToken)
      trailer:SetShown(shown)
      trailer:SetEnabled(shown)
      if shown then trailer:UpdateAllAuras() end
    end
  end
  missingState.clip:SetShown(shown)
  local auraTrigger = instance.data and AuraDisplay.GetTrigger(instance.data)
  local present = (IsTable(auraTrigger) and auraTrigger.unitExists) or AuraDisplay.SingleUnitExists({ unit = unitToken })
  missingState.clip:SetAlpha(present and 1 or 0)
  if shown then missingState.container:UpdateAllAuras() end
end

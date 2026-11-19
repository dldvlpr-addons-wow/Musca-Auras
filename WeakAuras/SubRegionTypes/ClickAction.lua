-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- Click action sub element: a secure action button laid over the aura, and an optional key binding.
-- The button is a child of UIParent and is never anchored to the aura, nor the aura to it, so the aura
-- does not become protected. Its attributes, position, size, visibility and binding are copied from the
-- aura out of combat only, and stay as they are during combat.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local L = WeakAuras.L

-- Mouse button suffixes of the secure attributes: *type1, *spell2, *macrotext3... The "*" prefix
-- matches the click with or without Shift, Ctrl or Alt, so a modified key binding works too.
local mouseButtons = { Left = 1, Right = 2, Middle = 3 }
local attributeKeys = { "type", "spell", "item", "macrotext", "unit" }

local active = {}    -- click sub element => its data, while the sub element is acquired
local released = {}  -- buttons of released sub elements, reset after combat
local freeButtons = {}
local buttonCount = 0

local function AcquireButton()
  local button = tremove(freeButtons)
  if button then
    return button
  end
  buttonCount = buttonCount + 1
  button = CreateFrame("Button", "MuscaAurasClick" .. buttonCount, UIParent, "SecureActionButtonTemplate")
  button:RegisterForClicks("AnyDown", "AnyUp")
  button:Hide()
  -- The tooltip of the aura, when it has one, is shown from the button the mouse is over.
  local function ForwardTooltip(self, scriptName)
    local region = self.owner and self.owner.parent
    local tooltipFrame = region and region.tooltipFrame
    local script = tooltipFrame and tooltipFrame:GetScript(scriptName)
    -- The aura keeps its script when its tooltip is turned off: only mouse motion tells it is on.
    if script and tooltipFrame:IsMouseMotionEnabled() then script(tooltipFrame) end
  end
  button:SetScript("OnEnter", function(self) ForwardTooltip(self, "OnEnter") end)
  button:SetScript("OnLeave", function(self) ForwardTooltip(self, "OnLeave") end)
  return button
end

local function SetBinding(button, key)
  if button.binding == key then
    return
  end
  ClearOverrideBindings(button)
  if key then
    SetOverrideBindingClick(button, false, key, button:GetName(), "LeftButton")
  end
  button.binding = key
end

local function SetDriver(button, condition)
  if button.driver == condition then
    return
  end
  if button.driver then
    UnregisterStateDriver(button, "visibility")
  end
  if condition then
    RegisterStateDriver(button, "visibility", condition)
  end
  button.driver = condition
end

-- Sets the secure attributes of the three mouse buttons. Returns true when at least one click does something:
-- an action without its spell, item, macro text or unit does nothing in the game and is skipped.
local function SetActions(button, data)
  local hasAction = false
  for name, index in pairs(mouseButtons) do
    for _, key in ipairs(attributeKeys) do
      button:SetAttribute("*" .. key .. index, nil)
    end
    local actionType = data["click" .. name .. "Type"]
    local value = strtrim(data["click" .. name .. "Value"] or "")
    local unit = data["click" .. name .. "Unit"] or ""
    local attribute, attributeValue
    if actionType == "spell" then
      attribute, attributeValue = "spell", tonumber(value) or value
    elseif actionType == "cancelaura" then
      -- The game cancels a buff by its name only: an unknown spell ID gives no action.
      attribute = "spell"
      if tonumber(value) then
        attributeValue = C_Spell.GetSpellName(tonumber(value))
      else
        attributeValue = value
      end
    elseif actionType == "item" then
      attribute, attributeValue = "item", tonumber(value) and ("item:" .. value) or value
    elseif actionType == "macro" then
      attribute, attributeValue = "macrotext", value
    elseif actionType == "target" then
      attribute, attributeValue = "unit", unit
    end
    if attribute and attributeValue and attributeValue ~= "" then
      hasAction = true
      button:SetAttribute("*type" .. index, actionType)
      button:SetAttribute("*" .. attribute .. index, attributeValue)
      if unit ~= "" and (actionType == "spell" or actionType == "item") then
        button:SetAttribute("*unit" .. index, unit)
      end
    end
  end
  return hasAction
end

local function ResetButton(button)
  SetBinding(button, nil)
  SetDriver(button, nil)
  SetActions(button, {})
  button:Hide()
  -- Cleared after Hide, so a tooltip shown from the button still gets its OnLeave.
  button.owner = nil
  button.placed = nil
  button.rect = nil
  tinsert(freeButtons, button)
end

-- Copies the rectangle of the aura on the button. Returns false when the rectangle cannot be read: anchored
-- to a nameplate or a protected frame, not laid out, or secret.
local function Place(button, region)
  if region:IsAnchoringRestricted() then
    return false
  end
  local left, bottom, width, height = region:GetLeft(), region:GetBottom(), region:GetWidth(), region:GetHeight()
  local scale = region:GetEffectiveScale()
  if not (left and bottom and width and height and scale) or Private.IsSecret(left, bottom, width, height, scale) then
    return false
  end
  local ratio = scale / UIParent:GetEffectiveScale()
  local strata, level = region:GetFrameStrata(), region:GetFrameLevel() + 10
  local rect = table.concat({ left * ratio, bottom * ratio, width * ratio, height * ratio, strata, level }, " ")
  if button.rect == rect then
    return true
  end
  button.rect = rect
  button:ClearAllPoints()
  button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left * ratio, bottom * ratio)
  button:SetSize(width * ratio, height * ratio)
  button:SetFrameStrata(strata)
  button:SetFrameLevel(level)
  button.placed = true
  return true
end

local function IsShownOnScreen(region)
  local visible = region:IsVisible()
  return not Private.IsSecret(visible) and visible
end

local function Update(subRegion, data, optionsOpen)
  local region = subRegion.parent
  local button = subRegion.button
  if optionsOpen or not (region and Private.loaded[region.id]) then
    if button then
      subRegion.button = nil
      ResetButton(button)
    end
    return
  end
  if not button then
    button = AcquireButton()
    button.owner = subRegion
    subRegion.button = button
  end
  local hasAction = SetActions(button, data)

  local shown = IsShownOnScreen(region)
  local mode = data.clickCombatMode
  -- A clone is only clickable while it is shown: released clones wait in a pool, still loaded.
  local isClone = region.cloneId ~= nil and region.cloneId ~= ""
  local clickableHidden = (mode == "always" or mode == "macro") and not isClone
  local placed = false
  if shown or clickableHidden then
    placed = Place(button, region)
    -- A hidden aura can have no rectangle: the button stays where the aura was last seen.
    if not placed and not shown then
      placed = button.placed
    end
  end
  local key = data.clickBinding ~= "" and data.clickBinding or nil
  if not (placed and hasAction) then
    SetDriver(button, nil)
    button:Hide()
    SetBinding(button, nil)
  elseif mode == "macro" and not isClone then
    SetDriver(button, data.clickCombatCondition ~= "" and data.clickCombatCondition or "hide")
    SetBinding(button, key)
  else
    SetDriver(button, nil)
    local show = shown or clickableHidden
    button:SetShown(show)
    SetBinding(button, show and key or nil)
  end
end

-- Changing the display type replaces the region of the aura without releasing its sub elements.
local function IsOrphan(region)
  if region.cloneId ~= nil and region.cloneId ~= "" then
    return false
  end
  local entry = Private.regions[region.id]
  return not (entry and entry.region == region)
end

local function Sync()
  if InCombatLockdown() then
    return
  end
  for index = #released, 1, -1 do
    ResetButton(released[index])
    released[index] = nil
  end
  local optionsOpen = WeakAuras.IsOptionsOpen()
  for subRegion, data in pairs(active) do
    if subRegion.parent and IsOrphan(subRegion.parent) then
      active[subRegion] = nil
      if subRegion.button then
        ResetButton(subRegion.button)
        subRegion.button = nil
      end
    else
      -- One broken aura must not keep the others from being updated.
      xpcall(function() Update(subRegion, data, optionsOpen) end, geterrorhandler())
    end
  end
end

-- One sync per frame at most: the aura has its final position one frame after it is shown.
local syncPending = false
local function ScheduleSync()
  if syncPending then
    return
  end
  syncPending = true
  C_Timer.After(0, function()
    syncPending = false
    Sync()
  end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", ScheduleSync)
Private.callbacks:RegisterCallback("ScanForLoads", ScheduleSync)
-- A deleted aura keeps its sub elements without releasing them: its buttons are freed here.
Private.callbacks:RegisterCallback("Delete", function(_, _, id)
  for subRegion in pairs(active) do
    if subRegion.parent and subRegion.parent.id == id then
      active[subRegion] = nil
      if subRegion.button then
        tinsert(released, subRegion.button)
        subRegion.button = nil
      end
    end
  end
  ScheduleSync()
end)
-- A dynamic group sorts and moves its children without showing or hiding them, and its animations move
-- them over several frames: the buttons of shown auras follow their aura out of combat.
-- ponytail: polling every 0.25 s, hook the group positioning if it shows in profiling.
C_Timer.NewTicker(0.25, function()
  if InCombatLockdown() or WeakAuras.IsOptionsOpen() then
    return
  end
  for subRegion in pairs(active) do
    local button = subRegion.button
    if button and button.placed and subRegion.parent and IsShownOnScreen(subRegion.parent) then
      Place(button, subRegion.parent)
    end
  end
end)
-- Opening the options or the placement mode makes every aura unclickable.
hooksecurefunc(Private, "Pause", ScheduleSync)
hooksecurefunc(Private, "StartPlacementMode", ScheduleSync)

-- Test harness entry point.
Private.SyncClickButtons = Sync

local function noop() end

local function create()
  return {
    SetFrameLevel = noop,
    PreShow = ScheduleSync,
    PreHide = ScheduleSync,
    OnRegionSizeChanged = ScheduleSync,
  }
end

local function onAcquire()
end

local function onRelease(subRegion)
  active[subRegion] = nil
  if subRegion.button then
    tinsert(released, subRegion.button)
    subRegion.button = nil
  end
  ScheduleSync()
end

local function modify(parent, subRegion, parentData, data)
  subRegion.parent = parent
  active[subRegion] = data
  parent.subRegionEvents:AddSubscriber("PreShow", subRegion)
  parent.subRegionEvents:AddSubscriber("PreHide", subRegion)
  parent.subRegionEvents:AddSubscriber("OnRegionSizeChanged", subRegion)
  ScheduleSync()
end

local function default()
  return {
    clickLeftType = "spell",
    clickLeftValue = "",
    clickLeftUnit = "",
    clickRightType = "none",
    clickRightValue = "",
    clickRightUnit = "",
    clickMiddleType = "none",
    clickMiddleValue = "",
    clickMiddleUnit = "",
    clickBinding = "",
    clickCombatMode = "visible",
    clickCombatCondition = "[combat] show; hide",
  }
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "text"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("subclickaction", L["Click Action"], supports, create, modify, onAcquire, onRelease,
                                default, nil, {})

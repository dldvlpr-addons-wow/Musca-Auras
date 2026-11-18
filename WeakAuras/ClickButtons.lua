if not WeakAuras.IsLibsOK() then return end
---@class Private
local Private = select(2, ...)

-- Secure buttons laid over the auras that have a click action. A button is a child of UIParent, never anchored to the
-- aura nor the aura to it: a region anchored to a protected frame becomes protected and could no longer be shown in
-- combat. Every change to a button (attributes, position, size, visibility, key binding) is made out of combat only;
-- a change asked in combat waits for PLAYER_REGEN_ENABLED, and the button keeps its state of the combat start.

local ClickButtons = {}
Private.ClickButtons = ClickButtons

local mouseButtons = { { index = 1, prefix = "left" }, { index = 2, prefix = "right" }, { index = 3, prefix = "middle" } }
local valueAttributes = { "spell", "item", "macrotext", "unit" }
local followInterval = 0.2

local owners = {}   -- region -> the click action sub-region that drives its button
local buttons = {}  -- region -> its secure button
local pending = {}  -- region -> true, synced after the combat
local freeButtons = {}
local created = 0
-- True from PLAYER_REGEN_DISABLED to PLAYER_REGEN_ENABLED: the auras also update on the combat start, and their sync
-- before the lockdown must keep the "combat" mode buttons shown.
local combatStarted = false

local eventFrame = CreateFrame("Frame")

local function Readable(...)
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    -- The secret test comes first: a secret may not be compared, even to nil.
    if (issecretvalue and issecretvalue(value)) or value == nil then
      return false
    end
  end
  return true
end

local function TakeButton()
  local button = tremove(freeButtons)
  if button then
    return button
  end
  created = created + 1
  -- No ":" in the name: a CLICK binding reads the button name up to the first ":".
  button = CreateFrame("Button", "MuscaAurasClickButton" .. created, UIParent, "SecureActionButtonTemplate")
  button:RegisterForClicks("AnyDown", "AnyUp")
  button:Hide()
  return button
end

local function FreeButton(button)
  if button.boundKey then
    ClearOverrideBindings(button)
    button.boundKey = nil
  end
  if button.driver then
    UnregisterStateDriver(button, "visibility")
    button.driver = nil
  end
  button:Hide()
  button:ClearAllPoints()
  for _, mouse in ipairs(mouseButtons) do
    button:SetAttribute("*type" .. mouse.index, nil)
    for _, name in ipairs(valueAttributes) do
      button:SetAttribute("*" .. name .. mouse.index, nil)
    end
  end
  button.rect = nil
  freeButtons[#freeButtons + 1] = button
end

--- The attribute value of a spell, item or buff typed by the player: a number is a spell or item ID.
local function ActionValue(kind, value)
  value = strtrim(tostring(value or ""))
  if value == "" then
    return nil
  end
  local id = tonumber(value)
  if kind == "item" and id then
    return "item:" .. id
  elseif kind == "cancelaura" and id then
    -- CancelSpellByName takes a name only.
    return C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id) or nil
  elseif kind == "spell" and id then
    return id
  end
  return value
end
ClickButtons.ActionValue = ActionValue

--- Sets the click attributes. Returns true when at least one mouse button does something, and true as second value
--- when a buff ID has no name yet.
--- The "*" prefix makes an attribute answer with any modifier held: a plain "type1" is ignored while Shift is down,
--- the case of a "[mod:shift]" macro condition or a key bound with a modifier.
local function Configure(button, data)
  local hasAction, unresolved = false, false
  for _, mouse in ipairs(mouseButtons) do
    local index = mouse.index
    for _, name in ipairs(valueAttributes) do
      button:SetAttribute("*" .. name .. index, nil)
    end
    local kind = data[mouse.prefix .. "_action"]
    local unit = data[mouse.prefix .. "_unit"]
    if unit == "default" or unit == "" then
      unit = nil
    end
    local typed = data[mouse.prefix .. (kind == "macro" and "_macro" or "_value")]
    local value = ActionValue(kind, typed)
    if kind == "cancelaura" and not value and tonumber(typed) then
      unresolved = true
    end
    if kind == "spell" and value then
      button:SetAttribute("*spell" .. index, value)
    elseif kind == "item" and value then
      button:SetAttribute("*item" .. index, value)
    elseif kind == "macro" and value then
      button:SetAttribute("*macrotext" .. index, value)
    elseif kind == "cancelaura" and value then
      button:SetAttribute("*spell" .. index, value)
      unit = nil
    elseif kind == "target" then
      unit = unit or "focus"
    else
      kind = nil
    end
    button:SetAttribute("*type" .. index, kind)
    if kind then
      button:SetAttribute("*unit" .. index, unit)
      hasAction = true
    end
  end
  return hasAction, unresolved
end

--- False once the aura dropped region: its type changed, it was deleted, or the clone went back to the pool.
local function IsCurrent(region)
  return region.id ~= nil and WeakAuras.GetRegion(region.id, region.cloneId) == region
end

--- Lays the button over the region, in the units of UIParent. Keeps the last place when the game refuses the rect.
local function Place(button, region)
  local okRect, left, bottom, width, height = pcall(region.GetRect, region)
  if not okRect or not Readable(left, bottom, width, height) then
    return
  end
  local okScale, scale = pcall(region.GetEffectiveScale, region)
  local uiScale = UIParent:GetEffectiveScale()
  if not okScale or not Readable(scale) or not uiScale or uiScale == 0 then
    return
  end
  local factor = scale / uiScale
  left, bottom, width, height = left * factor, bottom * factor, width * factor, height * factor
  local rect = button.rect
  if not rect or rect[1] ~= left or rect[2] ~= bottom or rect[3] ~= width or rect[4] ~= height then
    button:ClearAllPoints()
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
    button:SetSize(width, height)
    button.rect = { left, bottom, width, height }
  end
  local strata = region:GetFrameStrata()
  if strata and button:GetFrameStrata() ~= strata then
    button:SetFrameStrata(strata)
  end
  local level = (region:GetFrameLevel() or 0) + 20
  if button:GetFrameLevel() ~= level then
    button:SetFrameLevel(level)
  end
end

--- Shows the button and binds its key when the aura asks for it; the macro condition mode leaves the showing to the
--- state driver of the game.
local function Apply(button, owner, region)
  local data = owner.data
  local mode = data.combat_mode
  -- The options pick an aura by a click on it: the button must not take that click. An unloaded aura is only hidden,
  -- its region and sub-regions stay: the load state is read here.
  -- A button without action or never placed would only eat the clicks and the key.
  local active = not WeakAuras.IsOptionsOpen() and IsCurrent(region) and WeakAuras.IsAuraLoaded(region.id)
                 and button.hasAction and button.rect ~= nil
  local wanted
  if mode == "macro" then
    local condition = active and data.macro_condition or nil
    if condition == "" then
      condition = nil
    end
    if button.driver ~= condition then
      if button.driver then
        UnregisterStateDriver(button, "visibility")
      end
      if condition then
        RegisterStateDriver(button, "visibility", condition)
      else
        button:Hide()
      end
      button.driver = condition
    end
    wanted = condition ~= nil
  else
    if button.driver then
      UnregisterStateDriver(button, "visibility")
      button.driver = nil
    end
    -- "combat": the button cannot follow the aura in combat, so it stays clickable from the combat start to its end.
    wanted = active and (mode == "always" or owner.shown == true or (mode == "combat" and combatStarted))
    if wanted then
      button:Show()
    else
      button:Hide()
    end
  end

  -- The state driver only shows and hides the button; a key bound to it would click it even while hidden.
  local key = wanted and mode ~= "macro" and data.keybind or nil
  if key == "" then
    key = nil
  end
  if button.boundKey ~= key then
    if button.boundKey then
      ClearOverrideBindings(button)
    end
    if key then
      SetOverrideBindingClick(button, true, key, button:GetName(), "LeftButton")
    end
    button.boundKey = key
  end
end

local function Sync(region)
  pending[region] = nil
  local owner, button = owners[region], buttons[region]
  if not owner then
    if button then
      buttons[region] = nil
      FreeButton(button)
    end
    return
  end
  if not button then
    button = TakeButton()
    buttons[region] = button
  end
  button.hasAction, button.unresolved = Configure(button, owner.data)
  Place(button, region)
  Apply(button, owner, region)
end

local function Request(region)
  if InCombatLockdown() then
    pending[region] = true
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end
  Sync(region)
  if next(buttons) then
    eventFrame:Show()
  end
end

eventFrame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_REGEN_DISABLED" then
    combatStarted = true
    -- Even without pending change, the combat end must clear combatStarted.
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- Fired before the lockdown: the last moment to lay the buttons for the whole combat.
    if InCombatLockdown() then
      return
    end
    for region in pairs(buttons) do
      Sync(region)
    end
  elseif event == "PLAYER_REGEN_ENABLED" then
    combatStarted = false
    -- All the buttons: a "combat" mode button shown for the combat has no pending change.
    for region in pairs(buttons) do
      pending[region] = true
    end
    for region in pairs(pending) do
      Sync(region)
    end
    -- Unregistered after the loop: an error in one Sync leaves the others pending for the next combat end.
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if next(buttons) then
      self:Show()
    end
  end
end)

-- Out of combat, the buttons follow their aura: moves, resizes, dynamic groups, the options opened or closed.
local elapsedSinceFollow = 0
eventFrame:SetScript("OnUpdate", function(self, elapsed)
  elapsedSinceFollow = elapsedSinceFollow + elapsed
  if elapsedSinceFollow < followInterval then
    return
  end
  elapsedSinceFollow = 0
  if not next(buttons) then
    self:Hide()
    return
  end
  if InCombatLockdown() then
    return
  end
  for region, button in pairs(buttons) do
    local owner = owners[region]
    if owner and not IsCurrent(region) then
      -- No sub-region release comes for a dropped region: free its button here.
      owners[region] = nil
      Sync(region)
    elseif owner then
      if not button.hasAction or button.unresolved then
        -- A buff ID resolves to a name only once the game has loaded the spell data.
        button.hasAction, button.unresolved = Configure(button, owner.data)
      end
      Place(button, region)
      Apply(button, owner, region)
    end
  end
end)
eventFrame:Hide()
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

--- The click action sub-region owner now drives the button of region.
function ClickButtons.Set(region, owner)
  owners[region] = owner
  Request(region)
end

--- The click action sub-region owner leaves region; its button is freed, after the combat if need be.
function ClickButtons.Clear(region, owner)
  if owners[region] ~= owner then
    return
  end
  owners[region] = nil
  Request(region)
end

--- The aura of region was shown or hidden.
function ClickButtons.Update(region)
  if owners[region] then
    Request(region)
  end
end

--- The button laid over region, nil when it has none yet.
function ClickButtons.GetButton(region)
  return buttons[region]
end

--- The other auras that bind key, by id, to warn of a clash in the options.
function ClickButtons.AurasBindingKey(key, exceptId)
  local ids = {}
  if not key or key == "" then
    return ids
  end
  for id, data in pairs(WeakAurasSaved and WeakAurasSaved.displays or {}) do
    if id ~= exceptId and data.subRegions then
      for _, subRegion in ipairs(data.subRegions) do
        -- The macro condition mode binds no key.
        if subRegion.type == "subclickaction" and subRegion.keybind == key and subRegion.combat_mode ~= "macro" then
          ids[#ids + 1] = id
          break
        end
      end
    end
  end
  table.sort(ids)
  return ids
end

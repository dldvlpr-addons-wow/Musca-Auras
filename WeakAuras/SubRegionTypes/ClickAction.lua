if not WeakAuras.IsLibsOK() then return end
---@class Private
local Private = select(2, ...)

local L = WeakAuras.L

-- Makes the aura clickable: the sub-region draws nothing, it tells ClickButtons where the aura is and when it shows.
-- The secure button itself lives in ClickButtons, keyed by the aura region, because the sub-regions are released and
-- acquired again on every change of the aura.

local function default()
  return {
    left_action = "spell",
    left_value = "",
    left_macro = "",
    left_unit = "default",
    right_action = "none",
    right_value = "",
    right_macro = "",
    right_unit = "default",
    middle_action = "none",
    middle_value = "",
    middle_macro = "",
    middle_unit = "default",
    keybind = "",
    combat_mode = "visible",
    macro_condition = "[combat] show; hide",
  }
end

local methods = {}

function methods:PreShow()
  self.shown = true
  Private.ClickButtons.Update(self.parent)
end

function methods:PreHide()
  self.shown = false
  Private.ClickButtons.Update(self.parent)
end

local function create()
  local subRegion = CreateFrame("Frame", nil, UIParent)
  for name, method in pairs(methods) do
    subRegion[name] = method
  end
  return subRegion
end

local function onAcquire()
end

local function onRelease(subRegion)
  if subRegion.parent then
    Private.ClickButtons.Clear(subRegion.parent, subRegion)
  end
  subRegion.parent, subRegion.data, subRegion.shown = nil, nil, nil
end

local function modify(parent, subRegion, parentData, data)
  subRegion:SetParent(parent)
  subRegion.parent = parent
  subRegion.data = data
  subRegion.shown = parent.toShow == true
  parent.subRegionEvents:AddSubscriber("PreShow", subRegion)
  parent.subRegionEvents:AddSubscriber("PreHide", subRegion)
  Private.ClickButtons.Set(parent, subRegion)
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

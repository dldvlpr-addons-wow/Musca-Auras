-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Frozen value marker: under the combat restriction an Aura trigger cannot read the auras applied meanwhile, so what
-- the aura shows may be out of date. A small padlock on the aura says so while the restriction lasts. Each
-- aura can turn it off with data.hideFrozenMarker.
-- Health and power triggers never freeze: without a threshold they pass the secret values to the display, with one
-- they turn inactive while the restriction lasts.

local markers = setmetatable({}, { __mode = "k" })

--- Whether this aura has an Aura trigger that keeps its last state under the restriction. Groups, empty regions and
--- auras fed by the Blizzard aura display or the Cooldown Manager follow the secret auras, they never freeze.
function Private.CanFreeze(data)
  if data.controlledChildren or data.regionType == "empty" or Private.BlizzardAuraDisplay.HasTrigger(data) then
    return false
  end
  local freezes = false
  for triggernum, triggerData in ipairs(data.triggers or {}) do
    local triggerType = triggerData.trigger and triggerData.trigger.type
    if triggerType == "cdm" then
      return false
    end
    freezes = freezes or (triggerType == "aura2" and Private.AuraTriggerFreezes(data.id, triggernum))
  end
  return freezes
end

local function NewMarker(region)
  -- A frame, not a texture of the region: the cooldown swirl and the sub elements are frames drawn over the region.
  local marker = CreateFrame("Frame", nil, region)
  marker:SetPoint("TOPRIGHT", region, "TOPRIGHT", 2, 2)
  local padlock = marker:CreateTexture(nil, "OVERLAY")
  padlock:SetAllPoints()
  padlock:SetAtlas("QuestSharing-QuestLog-Padlock")
  return marker
end

--- Shows the frozen value marker on a region of this aura while the restriction lasts, when the aura can freeze.
function Private.UpdateFrozenMarker(region, data)
  local marker = region.frozenMarker
  if data.hideFrozenMarker or not Private.CanFreeze(data) then
    if marker then
      markers[marker] = nil
      marker:Hide()
    end
    return
  end
  if not marker then
    marker = NewMarker(region)
    region.frozenMarker = marker
  end
  -- 14 on a big aura, down to 8 on a small icon so the padlock does not hide it.
  local shortSide = math.min(data.width or region:GetWidth(), data.height or region:GetHeight())
  local size = math.min(14, math.max(8, 0.4 * shortSide))
  marker:SetSize(size, size)
  marker:SetFrameLevel(region:GetFrameLevel() + 10)
  markers[marker] = true
  marker:SetShown(WeakAuras.IsRestricted())
end

Private.callbacks:RegisterCallback("RestrictionChanged", function(_, isRestricted)
  for marker in pairs(markers) do
    marker:SetShown(isRestricted)
  end
end)

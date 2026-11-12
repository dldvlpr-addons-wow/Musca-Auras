-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

-- Link tool of the /wa mover: the Link button picks another aura, group or frame of the game, then a side or a corner
-- of it in a menu; the aura is then anchored there by position only and follows it. The aura keeps its place: the
-- offsets are captured. Unlink anchors it back to its group or to the screen, in place too. An orange line joins the
-- aura to the aura it follows while the mover is hovered or dragged.

-- Frames of the game an aura can follow. They move through the Edit Mode of the game, not through Musca.
-- ChatFrame1 is left out: the auras cannot reach it (AuraEnvironment blockedTables).
local gameFrames = {
  "PlayerFrame", "TargetFrame", "TargetFrameToT", "FocusFrame", "PetFrame", "PartyFrame", "CompactRaidFrameContainer",
  "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight", "MultiBar5",
  "MultiBar6", "MultiBar7", "StanceBar", "PetActionBar", "PossessActionBar", "ExtraActionBarFrame", "ZoneAbilityFrame",
  "MinimapCluster", "BuffFrame", "DebuffFrame", "ObjectiveTrackerFrame", "PlayerCastingBarFrame", "MicroMenuContainer",
  "BagsBar", "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer",
  "PlayerPowerBarAlt", "EncounterBar", "DurabilityFrame", "VehicleSeatIndicator", "TotemFrame",
  "MainStatusTrackingBarContainer", "DamageMeter",
}

--- The rectangle of the frame in UIParent units; for a group, the rectangle around its children.
local function ScreenRect(frame, data)
  local rect, scale = OptionsPrivate.Private.AnchorLinks.FrameRect(frame)
  if not rect then
    return
  end
  local factor = scale / UIParent:GetEffectiveScale()
  if data and data.regionType == "group" and frame.GetBoundingRect then
    -- The group frame is 2x2: its children are drawn around its anchored point, as the mover draws it.
    local blx, bly, trx, try = frame:GetBoundingRect()
    local x, y = OptionsPrivate.Private.AnchorLinks.PointPosition(rect[1], rect[2], rect[3], rect[4],
      data.selfPoint or "CENTER")
    return { (x + blx) * factor, (y + bly) * factor, (trx - blx) * factor, (try - bly) * factor }
  end
  return { rect[1] * factor, rect[2] * factor, rect[3] * factor, rect[4] * factor }
end

local catcher, box, hint, sourceId, sourceRegion, candidates, hovered, wheelLevel, lastBase, refresh

local function Cancel()
  if catcher and catcher:IsShown() then
    catcher:Hide()
  end
end

-- The menu of the sides and corners of the candidate; the aura is linked there in place.
local function Finish(candidate)
  local id, region = sourceId, sourceRegion
  Cancel()
  OptionsPrivate.Private.AnchorLinks.ShowMenu(false, function(side)
    local data = WeakAuras.GetData(id)
    if data and side
    and OptionsPrivate.Private.AnchorLinks.LinkInPlace(data, region, candidate.frame, candidate.frameName, side) then
      refresh(data)
    end
  end)
end

local function Unlink(data, region)
  if OptionsPrivate.Private.AnchorLinks.UnlinkInPlace(data, region) then
    refresh(data)
  end
end

-- The auras and groups shown, and the frames of the game shown, with their rectangle on the screen.
local function Candidates()
  local Private = OptionsPrivate.Private
  local list = {}
  for id, entry in pairs(Private.regions) do
    local region = entry.region
    local data = WeakAuras.GetData(id)
    if data and region and region:IsVisible() then
      local rect = ScreenRect(region, data)
      if rect then
        list[#list + 1] = {
          id = id, frame = region, frameName = "WeakAuras:" .. id, label = id, rect = rect,
          refused = id == sourceId or Private.AnchorLinks.DependsOn(id, sourceId),
        }
      end
    end
  end
  for _, name in ipairs(gameFrames) do
    local frame = _G[name]
    if type(frame) == "table" and frame.IsVisible and frame:IsVisible() then
      local rect = ScreenRect(frame)
      if rect then
        list[#list + 1] = { frame = frame, frameName = name, label = name, rect = rect }
      end
    end
  end
  return list
end

local function Contains(rect, x, y)
  return x >= rect[1] and x <= rect[1] + rect[3] and y >= rect[2] and y <= rect[2] + rect[4]
end

-- The smallest candidate under the cursor, then wheelLevel groups up from it.
local function Hovered(x, y)
  local best
  for _, candidate in ipairs(candidates) do
    if Contains(candidate.rect, x, y)
    and (not best or candidate.rect[3] * candidate.rect[4] < best.rect[3] * best.rect[4]) then
      best = candidate
    end
  end
  if best ~= lastBase then
    lastBase, wheelLevel = best, 0
  end
  for level = 1, wheelLevel do
    local data = best and best.id and WeakAuras.GetData(best.id)
    local parent
    for _, candidate in ipairs(candidates) do
      if data and candidate.id == data.parent then
        parent = candidate
      end
    end
    if not parent then
      wheelLevel = level - 1
      break
    end
    best = parent
  end
  return best
end

local function Cursor()
  local x, y = GetCursorPosition()
  local scale = UIParent:GetEffectiveScale()
  return x / scale, y / scale
end

local function Draw(rect, refused)
  box:ClearAllPoints()
  box:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", rect[1], rect[2])
  box:SetSize(math.max(rect[3], 1), math.max(rect[4], 1))
  box:SetBackdropBorderColor(OptionsPrivate.Private.Style.Color(refused and "error" or "primary"))
  box:Show()
end

local function OnUpdate()
  local candidate = Hovered(Cursor())
  hovered = candidate
  if not candidate then
    box:Hide()
    hint:SetText(L["Click the aura, group or game frame to follow. Right click or Escape: cancel."])
    return
  end
  Draw(candidate.rect, candidate.refused)
  if candidate.refused then
    hint:SetText(L["%s follows %s: linking it would make a loop."]:format(candidate.label, sourceId))
  else
    hint:SetText(L["%s. Mouse wheel: parent group. Right click or Escape: cancel."]:format(candidate.label))
  end
end

local function OnMouseUp(_, button)
  if button ~= "LeftButton" then
    Cancel()
    return
  end
  if hovered and not hovered.refused then
    Finish(hovered)
  end
end

local function Construct()
  catcher = CreateFrame("Frame", nil, UIParent)
  catcher:SetAllPoints(UIParent)
  catcher:SetFrameStrata("FULLSCREEN_DIALOG")
  catcher:EnableMouse(true)
  catcher:EnableMouseWheel(true)
  catcher:Hide()
  local Style = OptionsPrivate.Private.Style
  local shade = catcher:CreateTexture(nil, "BACKGROUND")
  shade:SetAllPoints()
  shade:SetColorTexture(Style.Color("veil", 0.25))

  box = CreateFrame("Frame", nil, catcher, "BackdropTemplate")
  box:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })

  hint = Style.NewText(catcher, "title", "l")
  hint:SetShadowOffset(1, -1)
  hint:SetShadowColor(0, 0, 0, 0.9)
  hint:SetPoint("TOP", catcher, "TOP", 0, -80)

  catcher:SetScript("OnUpdate", OnUpdate)
  catcher:SetScript("OnMouseUp", OnMouseUp)
  catcher:SetScript("OnMouseWheel", function(_, delta)
    wheelLevel = math.max(0, (wheelLevel or 0) + (delta > 0 and 1 or -1))
  end)
  catcher:SetScript("OnKeyDown", function(self, key)
    if InCombatLockdown() then
      return
    end
    self:SetPropagateKeyboardInput(key ~= "ESCAPE")
    if key == "ESCAPE" then
      Cancel()
    end
  end)
  catcher:SetScript("OnHide", function(self)
    candidates, hovered, sourceRegion = nil, nil, nil
    box:Hide()
    if not InCombatLockdown() then
      self:EnableKeyboard(false)
    end
  end)
end

local function Start(region, data)
  if not catcher then
    Construct()
  end
  sourceId, sourceRegion, hovered, wheelLevel, lastBase = data.id, region, nil, 0, nil
  candidates = Candidates()
  if not InCombatLockdown() then
    catcher:EnableKeyboard(true)
    catcher:SetPropagateKeyboardInput(true)
  end
  catcher:Show()
end

--- Adds the Link / Unlink button to the mover of /wa.
function OptionsPrivate.AnchorLinker(moversizer, mover, optionsFrame)
  local button = CreateFrame("Button", nil, moversizer, "UIPanelButtonTemplate")
  button:SetSize(80, 20)
  button:SetPoint("TOPLEFT", moversizer, "BOTTOMLEFT", 4, 2)

  refresh = function(data)
    WeakAuras.Add(data)
    OptionsPrivate.Private.AddParents(data)
    WeakAuras.UpdateThumbnail(data)
    WeakAuras.FillOptions()
    OptionsPrivate.ResetMoverSizer()
  end

  local function Linked(data)
    return data.anchorFrameType == "SELECTFRAME" and type(data.anchorFrameFrame) == "string"
  end

  -- As the anchor options: hidden for a child of a dynamic or flow group, and for a group placed by frame.
  local function Shown(data)
    local parentData = data.parent and WeakAuras.GetData(data.parent)
    return type(optionsFrame.pickedDisplay) == "string" and not WeakAurasOptionsSaved.lockPositions
      and not (parentData and (parentData.regionType == "dynamicgroup" or parentData.blizzardFlow))
      and not (data.regionType == "group" and data.blizzardFlow and data.blizzardFlowFrames ~= nil)
      and not (data.regionType == "dynamicgroup" and data.useAnchorPerUnit)
  end

  button:SetScript("OnClick", function()
    local region, data = mover.moving.region, mover.moving.data
    if not region or not data or not Shown(data) then
      return
    end
    if Linked(data) then
      Unlink(data, region)
    else
      Start(region, data)
    end
  end)
  button:SetScript("OnEnter", function(self)
    local data = mover.moving.data
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if data and Linked(data) then
      GameTooltip:SetText(L["Linked to %s"]:format(data.anchorFrameFrame), 1, 1, 1)
      GameTooltip:AddLine(L["Unlink: the aura stays in place and follows its group or the screen again."], nil, nil,
        nil, true)
    else
      GameTooltip:SetText(L["Link"], 1, 1, 1)
      GameTooltip:AddLine(L["Anchors this aura to a side of another aura, group or game frame: the aura then follows it, by position only. It stays in place."],
        nil, nil, nil, true)
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", GameTooltip_Hide)

  -- Link marker: the aura it follows framed, the two points of the link shown, while the mover is hovered or dragged.
  -- Own frame: the mover sets and clears its OnUpdate while it moves or sizes.
  local marker = OptionsPrivate.Private.AnchorLinks.CreateMarker(moversizer)
  local ticker = CreateFrame("Frame", nil, moversizer)
  ticker:SetScript("OnUpdate", function()
    local data = mover.moving.data
    local targetId = data and OptionsPrivate.Private.AnchorLinks.TargetAura(data)
    local entry = targetId and OptionsPrivate.Private.regions[targetId]
    if entry and entry.region and (mover.isMoving or moversizer:IsMouseOver()) then
      OptionsPrivate.Private.AnchorLinks.ShowMarker(marker, mover, entry.region, entry.region, data)
    else
      marker:Hide()
    end
  end)

  local SetToRegion = moversizer.SetToRegion
  moversizer.SetToRegion = function(self, region, data)
    SetToRegion(self, region, data)
    button:SetText(Linked(data) and L["Unlink"] or L["Link"])
    button:SetShown(Shown(data))
  end

  local OptionsClosed = moversizer.OptionsClosed
  moversizer.OptionsClosed = function()
    Cancel()
    OptionsPrivate.Private.AnchorLinks.HideMenu()
    OptionsClosed()
  end
end

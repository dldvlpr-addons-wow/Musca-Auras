-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end

-- Hides Blizzard's Cooldown Manager viewers by forcing their alpha to 0 while they stay
-- shown, so their data keeps feeding the tracking code. Restores the original alpha when
-- the option is off. Callers: OptionsFrame checkbox, Private.ToggleCooldownManager.
-- Reads Private.db.cdmHideBlizzard, never writes it. Emits WA_CDM_REFRESH after each pass.

local _, Private = ...

local VIEWER_NAMES = {
  "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer",
}
local CVAR_NAME = "cooldownViewerEnabled"

-- Weak keys: per-frame memory must not keep frames alive.
local originalAlpha = setmetatable({}, { __mode = "k" })
local hooked = setmetatable({}, { __mode = "k" })
local enforcing = false

local function IsHidingEnabled()
  local db = Private.db
  return db ~= nil and db.cdmHideBlizzard == true
end

local IsSecret = Private.IsSecret

local function IsForbidden(frame)
  return frame.IsForbidden ~= nil and frame:IsForbidden() and true or false
end

-- SetAlpha re-enters the post-hook, hence the guard.
local function WantedAlpha(frame)
  if IsHidingEnabled() then return 0 end
  return originalAlpha[frame]
end

local function EnforceAlpha(frame)
  if enforcing then return end
  enforcing = true
  local ok, err = pcall(frame.SetAlpha, frame, WantedAlpha(frame))
  enforcing = false
  if not ok then error(err, 0) end
end

local function IsReadableNumber(value)
  return type(value) == "number" and not IsSecret(value)
end

local function OnExternalSetAlpha(frame, alpha)
  local isTracked = originalAlpha[frame] ~= nil
  if enforcing or not isTracked then return end
  if IsForbidden(frame) then return end
  if IsReadableNumber(alpha) then originalAlpha[frame] = alpha end
  EnforceAlpha(frame)
end

local function Track(frame)
  if originalAlpha[frame] == nil then
    local alpha = frame:GetAlpha()
    originalAlpha[frame] = IsReadableNumber(alpha) and alpha or 1
  end
  if not hooked[frame] then
    hooked[frame] = true
    hooksecurefunc(frame, "SetAlpha", OnExternalSetAlpha)
  end
end

local function EnsureViewerEnabled()
  local readBool = C_CVar and C_CVar.GetCVarBool
  if not readBool then return end
  if readBool(CVAR_NAME) then return end
  C_CVar.SetCVar(CVAR_NAME, "1")
end

local function RefreshViewers()
  local hide = IsHidingEnabled()
  if hide then EnsureViewerEnabled() end

  for _, name in ipairs(VIEWER_NAMES) do
    local frame = _G[name]
    local managed = frame ~= nil and (hide or originalAlpha[frame] ~= nil)
    if managed and not IsForbidden(frame) then
      Track(frame)
      EnforceAlpha(frame)
    end
  end

  if Private.ScanEvents then
    Private.ScanEvents("WA_CDM_REFRESH")
  end
end

function Private.ApplyCDMBackground()
  if InCombatLockdown() then return end
  RefreshViewers()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("COOLDOWN_VIEWER_DATA_LOADED")
eventFrame:RegisterEvent("CVAR_UPDATE")
local eventHandlers = {
  CVAR_UPDATE = function(cvarName)
    if cvarName == CVAR_NAME then Private.ApplyCDMBackground() end
  end,
}
eventFrame:SetScript("OnEvent", function(_, event, cvarName)
  local handler = eventHandlers[event]
  if handler then handler(cvarName) else Private.ApplyCDMBackground() end
end)

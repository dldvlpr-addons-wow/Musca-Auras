if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local VIEWER_GLOBALS = {
  "EssentialCooldownViewer",
  "UtilityCooldownViewer",
  "BuffIconCooldownViewer",
  "BuffBarCooldownViewer",
}
local WATCHED_EVENTS = {
  "PLAYER_ENTERING_WORLD",
  "PLAYER_REGEN_ENABLED",
  "COOLDOWN_VIEWER_DATA_LOADED",
  "CVAR_UPDATE",
}

local remembered = setmetatable({}, {__mode = "k"})
local enforcing = false

local function isSecret(value)
  return issecretvalue ~= nil and issecretvalue(value)
end

local function shouldHide()
  local db = Private.db
  return db ~= nil and db.cdmHideBlizzard == true
end

local function isUsable(frame)
  local forbidden = frame.IsForbidden
  return forbidden == nil or not forbidden(frame)
end

local function enforceAlpha(frame, requested)
  if enforcing or not isUsable(frame) then return end
  local entry = remembered[frame]
  if entry == nil then return end
  if requested ~= nil and not isSecret(requested) then
    entry.alpha = requested
  end
  enforcing = true
  frame:SetAlpha(shouldHide() and 0 or entry.alpha)
  enforcing = false
end

local function adopt(viewer)
  local current = viewer:GetAlpha()
  remembered[viewer] = {alpha = isSecret(current) and 1 or current}
  hooksecurefunc(viewer, "SetAlpha", enforceAlpha)
end

local function ensureViewerEnabled()
  if shouldHide() and C_CVar and C_CVar.GetCVarBool
    and not C_CVar.GetCVarBool("cooldownViewerEnabled") then
    C_CVar.SetCVar("cooldownViewerEnabled", "1")
  end
end

function Private.ApplyCDMBackground()
  if InCombatLockdown() then return end
  ensureViewerEnabled()
  for i = 1, #VIEWER_GLOBALS do
    local viewer = _G[VIEWER_GLOBALS[i]]
    if viewer and isUsable(viewer) and (shouldHide() or remembered[viewer]) then
      if remembered[viewer] == nil then adopt(viewer) end
      enforceAlpha(viewer)
    end
  end
  if Private.ScanEvents then Private.ScanEvents("WA_CDM_REFRESH") end
end

local watcher = CreateFrame("Frame")
for i = 1, #WATCHED_EVENTS do
  watcher:RegisterEvent(WATCHED_EVENTS[i])
end
watcher:SetScript("OnEvent", function(_, event, cvarName)
  if event == "CVAR_UPDATE" and cvarName ~= "cooldownViewerEnabled" then
    return
  end
  Private.ApplyCDMBackground()
end)

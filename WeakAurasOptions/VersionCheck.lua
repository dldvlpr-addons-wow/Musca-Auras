local optionsVersion = C_AddOns.GetAddOnMetadata("WeakAurasOptions", "Version")
local coreVersion = C_AddOns.GetAddOnMetadata("WeakAuras", "Version")
if optionsVersion == coreVersion then return end

local L = WeakAuras.L

WeakAuras.ToggleOptions = function()
  local mismatch = L["The WeakAuras Options Addon version %s doesn't match the WeakAuras version %s. If you updated the addon while the game was running, try restarting World of Warcraft. Otherwise try reinstalling WeakAuras"]
    :format(tostring(optionsVersion), tostring(coreVersion))
  local repair = L["Replace the 5 folders WeakAuras, WeakAurasArchive, WeakAurasModelPaths, WeakAurasOptions and WeakAurasTemplates with the same version, then restart the game."]
  WeakAuras.prettyPrint(mismatch)
  StaticPopup_Show("WEAKAURAS_ACTION_BLOCKED", mismatch .. "\n\n" .. repair)
end

local L = WeakAuras.L

local function addonVersion(name)
  return C_AddOns.GetAddOnMetadata(name, "Version")
end

local optionsVersion = addonVersion("WeakAurasOptions")
local coreVersion = addonVersion("WeakAuras")

if optionsVersion ~= coreVersion then
  local template = L["The WeakAuras Options Addon version %s doesn't match the WeakAuras version %s. If you updated the addon while the game was running, try restarting World of Warcraft. Otherwise try reinstalling WeakAuras"]
  local warning = template:format(tostring(optionsVersion), tostring(coreVersion))
  WeakAuras.IsLibsOk = function()
    return false
  end
  WeakAuras.ToggleOptions = function()
    WeakAuras.prettyPrint(warning)
  end
end

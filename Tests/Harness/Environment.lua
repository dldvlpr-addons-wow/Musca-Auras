local Secret = require("Secret")
local Clock = require("Clock")
local DocumentedApi = require("DocumentedApi")
local Frames = require("Frames")
local WowApi = require("WowApi")
local Units = require("Units")

local Environment = {
  errors = {},
  forbidden = {},
  missingGlobals = {},
}

local sourceRoot = os.getenv("WOW_UI_SOURCE") or "C:/Users/ludov/wow-ui-source/forever"
local addOnsRoot = sourceRoot .. "/Interface/AddOns"

local blizzardAddOns = {
  "Blizzard_SharedXMLBase",
  "Blizzard_Colors",
  "Blizzard_ProjectConstants",
  "Blizzard_SharedXML",
  "Blizzard_SharedXMLGame",
  "Blizzard_FrameXMLBase",
  "Blizzard_FrameXMLUtil",
  "Blizzard_ObjectAPI",
  "Blizzard_DeprecatedActionBar",
  "Blizzard_DeprecatedAuraFilters",
  "Blizzard_DeprecatedChatInfo",
  "Blizzard_DeprecatedGuildScript",
  "Blizzard_DeprecatedInstanceEncounter",
  "Blizzard_DeprecatedPartyInfo",
  "Blizzard_DeprecatedSpellBook",
  "Blizzard_DeprecatedSpellScript",
  "Blizzard_DeprecatedUnitScript",
}

local function RecordError(message)
  Environment.errors[#Environment.errors + 1] = tostring(message)
end

function Environment.Protect(func, ...)
  local count = select("#", ...)
  local arguments = { ... }
  local results = { xpcall(function() return func(unpack(arguments, 1, count)) end, debug.traceback) }
  if not results[1] then
    RecordError(results[2])
    return
  end
  return unpack(results, 2, table.maxn(results))
end


-- ponytail: GlobalStrings is client-side only; an upper-case name stands for its own text, minus known addon globals
local addonGlobals = { DBM = true, GTFO = true, BIGWIGS = true, LUI = true, KUI = true }
function Environment.IsGlobalStringName(key)
  return type(key) == "string" and key:find("^[A-Z][A-Z0-9_]+$") ~= nil and not addonGlobals[key]
    and not key:find("^WOW_PROJECT") and not key:find("^LE_") and not key:find("^MAX_")
    and not key:find("^NUM_") and not key:find("^BOOKTYPE")
end

function Environment.Setup()
  DocumentedApi.Load(sourceRoot, (os.getenv("TEMP") or "/tmp") .. "/MuscaForeverApi.lua")

  local nativeXpcall = xpcall
  _G.xpcall = function(func, handler, ...)
    local count, arguments = select("#", ...), { ... }
    return nativeXpcall(function() return func(unpack(arguments, 1, count)) end, handler)
  end

  WowApi.protect = Environment.Protect
  WowApi.errorHandler = function(message)
    RecordError(debug.traceback(tostring(message), 2))
  end
  WowApi.Install(_G)
  Frames.Install(_G, Environment.Protect, function(message)
    WowApi.printed[#WowApi.printed + 1] = tostring(Secret.Reveal(message))
  end, function(message)
    Environment.forbidden[#Environment.forbidden + 1] = message
  end)
  Units.Install(_G, Frames.Fire, WowApi)
  _G.C_ClassColor = { GetClassColor = function(className)
    local color = _G.RAID_CLASS_COLORS and rawget(_G.RAID_CLASS_COLORS, className)
    return color or _G.CreateColor(0.78, 0.61, 0.43)
  end }
  _G.C_ColorOverrides = { GetColorForQuality = function() return _G.CreateColor(1, 1, 1) end }
  Units.DefineUnit("player", { name = "Tester", class = "WARRIOR" })

  _G.C_Timer = Clock.CreateTimerApi(Environment.Protect)
  Clock.onTick = Units.ExpireAuras
  _G.GetTime = Clock.GetTime
  _G.GetServerTime = function() return os.time() end
  _G.time, _G.date = os.time, os.date
  _G.C_AddOns = {
    GetAddOnMetadata = function(addon, field)
      if addon == "WeakAuras" then
        return ({ Version = "5.22.0", ["X-Flavor"] = "Vanilla", Title = "Musca Auras" })[field]
      end
    end,
    IsAddOnLoaded = function(addon) return addon == "WeakAuras" or addon == "WeakAurasArchive" and rawget(_G, "WeakAurasArchive") ~= nil end,
    LoadAddOn = function(addon)
      if addon == "WeakAurasArchive" then
        rawset(_G, "WeakAurasArchive", rawget(_G, "WeakAurasArchive") or {})
        return true
      end
      return false, "MISSING"
    end,
    GetNumAddOns = function() return 1 end,
    DoesAddOnExist = function(addon) return addon == "WeakAuras" end,
  }

  DocumentedApi.Install(_G)
  _G.Constants.InventoryConstants.NumBagSlots = _G.Constants.InventoryConstants.NumBagSlots or 4
  _G.Constants.InventoryConstants.NumReagentBagSlots = _G.Constants.InventoryConstants.NumReagentBagSlots or 0

  local Loader = require("Loader")
  Loader.LoadBlizzard(addOnsRoot, blizzardAddOns)
  for _, message in ipairs(Environment.errors) do
    Loader.blizzardErrors[#Loader.blizzardErrors + 1] = message
  end
  Environment.errors = {}

  setmetatable(_G, {
    __index = function(_, key)
      Environment.missingGlobals[key] = (Environment.missingGlobals[key] or 0) + 1
      if Environment.IsGlobalStringName(key) then
        return key
      end
    end,
  })
end

Environment.Advance = Clock.Advance

return Environment

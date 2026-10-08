local Secret = require("Secret")
local Bit = require("Bit")

local WowApi = { printed = {} }
local rawToNumber, rawToStringValue = tonumber, tostring

local function SecretAwareFormat(original)
  return function(formatString, ...)
    if Secret.IsSecret(formatString) then
      return Secret.Wrap(original(Secret.Reveal(formatString), ...))
    end
    local count = select("#", ...)
    local hasSecret = false
    for index = 1, count do
      if Secret.IsSecret((select(index, ...))) then
        hasSecret = true
      end
    end
    if not hasSecret then
      return original(formatString, ...)
    end
    local arguments = { ... }
    local index = 0
    for flags, conversion in formatString:gmatch("%%([-+ #0]*%d*%.?%d*)(%a)") do
      index = index + 1
      local value = arguments[index]
      if Secret.IsSecret(value) then
        if conversion == "d" or conversion == "i" or conversion == "x" or conversion == "X" or conversion == "c" then
          error("bad argument #" .. (index + 1) .. " to 'format' (number expected, got secret)", 2)
        end
        arguments[index] = Secret.Reveal(value)
      end
    end
    return Secret.Wrap(original(formatString, unpack(arguments, 1, count)))
  end
end

local function Split(delimiter, text, pieces)
  local results = {}
  local start = 1
  while true do
    if pieces and #results == pieces - 1 then
      break
    end
    local first, last = text:find("[" .. delimiter:gsub("[%]%^%-%%]", "%%%0") .. "]", start)
    if not first then
      break
    end
    results[#results + 1] = text:sub(start, first - 1)
    start = last + 1
  end
  results[#results + 1] = text:sub(start)
  return unpack(results)
end

local function Trim(text, characters)
  characters = characters and ("[" .. characters:gsub("[%]%^%-%%]", "%%%0") .. "]") or "%s"
  return (text:gsub("^" .. characters .. "+", ""):gsub(characters .. "+$", ""))
end

local function Join(delimiter, ...)
  return table.concat({ ... }, delimiter)
end

function WowApi.Install(target)
  local format = SecretAwareFormat(string.format)
  string.format = format
  string.split = function(text, delimiter, pieces) return Split(delimiter, text, pieces) end
  string.trim = Trim
  string.join = Join
  table.wipe = function(t)
    for key in pairs(t) do
      t[key] = nil
    end
    return t
  end

  target.bit = Bit
  target.format = format
  target.strsplit = Split
  target.strtrim = Trim
  target.strjoin = Join
  target.strconcat = function(...) return table.concat({ ... }) end
  target.strsub, target.strlen, target.strlower, target.strupper = string.sub, string.len, string.lower, string.upper
  target.strfind, target.strmatch, target.strrep, target.strbyte, target.strchar = string.find, string.match,
    string.rep, string.byte, string.char
  target.strrev = string.reverse
  target.gsub, target.gmatch = string.gsub, string.gmatch
  target.tinsert, target.tremove, target.sort, target.wipe = table.insert, table.remove, table.sort, table.wipe
  target.tconcat = table.concat
  target.floor, target.ceil, target.abs, target.max, target.min = math.floor, math.ceil, math.abs, math.max, math.min
  target.sqrt, target.sin, target.cos, target.tan, target.rad, target.deg = math.sqrt, math.sin, math.cos, math.tan,
    math.rad, math.deg
  target.atan2, target.exp, target.log, target.log10 = math.atan2, math.exp, math.log, math.log10
  target.mod = math.fmod
  target.fastrandom = math.random
  target.random = math.random
  target.strcmputf8i = function(a, b)
    a, b = a:lower(), b:lower()
    if a == b then return 0 end
    return a < b and -1 or 1
  end
  target.strlenutf8 = function(text) return #text:gsub("[\128-\191]", "") end
  target.debugprofilestop = function() return os.clock() * 1000 end
  target.debugprofilestart = function() end
  target.debugstack = function() return debug.traceback() end
  target.securecall = function(func, ...)
    if type(func) == "string" then func = target[func] end
    return WowApi.protect(func, ...)
  end
  target.securecallfunction = target.securecall
  target.secureexecuterange = function(tbl, func, ...)
    for key, value in pairs(tbl) do
      WowApi.protect(func, key, value, ...)
    end
  end
  target.issecure = function() return false end
  target.issecurevariable = function() return false, "WeakAuras" end
  target.forceinsecure = function() end
  target.hooksecurefunc = function(tableOrName, nameOrHook, hook)
    local owner, name = tableOrName, nameOrHook
    if type(tableOrName) == "string" then
      owner, name, hook = target, tableOrName, nameOrHook
    end
    local original = owner[name]
    if type(original) ~= "function" then
      error("hooksecurefunc(): " .. tostring(name) .. " is not a function", 2)
    end
    owner[name] = function(...)
      local results = { original(...) }
      hook(...)
      return unpack(results)
    end
  end
  target.geterrorhandler = function() return WowApi.errorHandler end
  target.seterrorhandler = function(handler) WowApi.errorHandler = handler end
  target.print = function(...)
    local parts = {}
    for index = 1, select("#", ...) do
      parts[#parts + 1] = rawToStringValue(Secret.Reveal((select(index, ...))))
    end
    WowApi.printed[#WowApi.printed + 1] = table.concat(parts, " ")
  end

  local rawType, rawToString = type, tostring
  target.type = function(value)
    if Secret.IsSecret(value) then
      return rawType(Secret.Reveal(value))
    end
    return rawType(value)
  end
  target.tostring = function(value)
    if Secret.IsSecret(value) then
      return Secret.Wrap(rawToString(Secret.Reveal(value)))
    end
    return rawToString(value)
  end
  target.tonumber = function(value, base)
    if Secret.IsSecret(value) then
      error("bad argument #1 to 'tonumber' (secret value)", 2)
    end
    return rawToNumber(value, base)
  end
  target.issecretvalue = Secret.IsSecret
  target.secretwrap = function(...)
    local values = { ... }
    for index = 1, select("#", ...) do
      values[index] = Secret.Wrap(values[index])
    end
    return unpack(values, 1, select("#", ...))
  end
  target.canaccessvalue = function(value) return not Secret.IsSecret(value) end
  target.canaccesssecrets = function() return false end
  target.hasanysecretvalues = function(...)
    for index = 1, select("#", ...) do
      if Secret.IsSecret((select(index, ...))) then return true end
    end
    return false
  end
  target.canaccessallvalues = function(...) return not target.hasanysecretvalues(...) end
  target.issecrettable = function() return false end
  target.canaccesstable = function() return true end
  target.scrubsecretvalues = function(...)
    local values = { ... }
    for index = 1, select("#", ...) do
      if Secret.IsSecret(values[index]) then values[index] = nil end
    end
    return unpack(values, 1, select("#", ...))
  end

  target.Mixin = function(object, ...)
    for index = 1, select("#", ...) do
      for key, value in pairs((select(index, ...))) do
        object[key] = value
      end
    end
    return object
  end
  target.CreateFromMixins = function(...) return target.Mixin({}, ...) end
  target.GetCurrentEnvironment = function() return target end
  target.GetInventoryItemLink = function() return nil end
  target.GetRaidRosterInfo = function() return nil end
  target.SendChatMessage = function() end
  target.CreateSecureDelegate = function(func)
    return function(...) return WowApi.protect(func, ...) end
  end
  target.GetInventorySlotInfo = function(slotName)
    local slots = { HeadSlot = 1, NeckSlot = 2, ShoulderSlot = 3, ShirtSlot = 4, ChestSlot = 5, WaistSlot = 6,
      LegsSlot = 7, FeetSlot = 8, WristSlot = 9, HandsSlot = 10, Finger0Slot = 11, Finger1Slot = 12,
      Trinket0Slot = 13, Trinket1Slot = 14, BackSlot = 15, MainHandSlot = 16, SecondaryHandSlot = 17,
      RangedSlot = 18, TabardSlot = 19 }
    return slots[slotName], 136516
  end
  target.SetItemRef = function() end
  target.GetGuildInfo = function() return nil end
  target.RegisterStaticConstants = function() end
  target.BNFeaturesEnabledAndConnected = function() return false end
  target.GetAutoCompleteRealms = function() return {} end
  target.LocalizedClassList = function()
    local list = {}
    for _, token in ipairs({ "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }) do
      list[token] = token:sub(1, 1) .. token:sub(2):lower()
    end
    return list
  end
  target.LOCALIZED_CLASS_NAMES_MALE, target.LOCALIZED_CLASS_NAMES_FEMALE = target.LocalizedClassList(), target.LocalizedClassList()
  target.GetInventoryItemTexture = function() return nil end
  target.GetInventoryItemID = function() return nil end
  target.ChatFrame_AddMessageEventFilter = function() end
  target.ChatFrame_RemoveMessageEventFilter = function() end
  target.GetNumShapeshiftForms = function() return 0 end
  target.GetShapeshiftForm = function() return 0 end
  target.GetShapeshiftFormInfo = function() return nil end
  target.SecureButton_GetUnit = function(button) return button and button.unit end

  target.GetLocale = function() return "enUS" end
  target.GetCurrentRegion = function() return 3 end
  target.GetRealmName = function() return "TestRealm" end
  target.GetBuildInfo = function() return "1.60.1", "70124", "Sep 30 2026", 16001, "", "", 16001 end
  target.InCombatLockdown = function() return WowApi.inCombat == true end
  target.IsLoggedIn = function() return WowApi.loggedIn == true end
  target.GetFramerate = function() return 60 end
  target.GetScreenWidth = function() return 1920 end
  target.GetScreenHeight = function() return 1080 end
  target.GetPhysicalScreenSize = function() return 1920, 1080 end
  target.GetCursorPosition = function() return 0, 0 end
  target.IsShiftKeyDown = function() return false end
  target.IsControlKeyDown = function() return false end
  target.IsAltKeyDown = function() return false end
  target.IsModifierKeyDown = function() return false end
  target.PlaySound = function() return true end
  target.PlaySoundFile = function() return true end
  target.StopSound = function() end
  -- ponytail: loadDeprecationFallbacks default on Forever unverified, assumed "1" since WeakAuras calls HasOverrideActionBar unguarded
  WowApi.cvars = { loadDeprecationFallbacks = "1" }
  target.GetCVar = function(name) return WowApi.cvars[name] end
  target.GetCVarBool = function(name) return WowApi.cvars[name] == "1" end
  target.C_CVar = {
    GetCVar = target.GetCVar,
    GetCVarBool = target.GetCVarBool,
    GetCVarDefault = target.GetCVar,
    SetCVar = function(name, value) WowApi.cvars[name] = value ~= nil and tostring(value) or nil return true end,
    RegisterCVar = function(name, value) WowApi.cvars[name] = WowApi.cvars[name] or (value ~= nil and tostring(value) or nil) end,
  }
  target.SetCVar = function() return true end

  target.SlashCmdList = {}
  target.StaticPopupDialogs = {}
  target.UISpecialFrames = {}
  target.StaticPopup_Show = function() end
  target.StaticPopup_Hide = function() end
end

return WowApi

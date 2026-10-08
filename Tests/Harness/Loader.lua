local Frames = require("Frames")
local WowApi = require("WowApi")

local Loader = { loadErrors = {}, blizzardErrors = {}, files = {} }

local gameTypes = { "camelot", "mainline" }
local substitutions = { Family = "Mainline", Game = "Camelot" }

local function Normalize(path)
  return (path:gsub("\\", "/"):gsub("%[(%a+)%]", substitutions))
end

local function Directory(path)
  return path:match("^(.*)/[^/]*$") or "."
end

local function IsConditionAllowed(condition)
  local kind, values = condition:match("^(%a+)%s+(.*)$")
  local padded = " " .. (values or ""):gsub(",", " ") .. " "
  local listed = false
  for _, gameType in ipairs(gameTypes) do
    listed = listed or padded:find(" " .. gameType .. " ", 1, true) ~= nil
  end
  if kind == "AllowLoadGameType" then
    return listed
  elseif kind == "ExcludeLoadGameType" then
    return not listed
  end
  return true
end

local function SplitEntry(line)
  local conditions = {}
  local entry = line:gsub("%s*%[(%a+%s[^%]]*)%]", function(condition)
    conditions[#conditions + 1] = condition
    return ""
  end)
  for _, condition in ipairs(conditions) do
    if not IsConditionAllowed(condition) then
      return nil
    end
  end
  return entry
end

function Loader.RunFile(path, ...)
  local chunk, loadError
  if type(path) == "table" then
    chunk, loadError = loadstring(path.code, "@" .. path.name .. " <Script>")
  else
    local file = io.open(path, "rb")
    if not file then
      return false, "missing file " .. path
    end
    local code = file:read("*a"):gsub("^\239\187\191", "")
    file:close()
    chunk, loadError = loadstring(code, "@" .. path)
  end
  if not chunk then
    return false, loadError
  end
  local arguments, count = { ... }, select("#", ...)
  return xpcall(function() return chunk(unpack(arguments, 1, count)) end, debug.traceback)
end

local function ExpandXml(path, files, errors)
  local file = io.open(path, "r")
  if not file then
    errors[#errors + 1] = "missing xml " .. path
    return
  end
  local content = file:read("*a"):gsub("<!%-%-.-%-%->", "")
  file:close()
  local directory = Directory(path)
  local position = 1
  while true do
    local first, last, tag, attributes, selfClosing = content:find("<(%a+)([^>]-)(/?)>", position)
    if not first then
      break
    end
    position = last + 1
    if tag == "Script" or tag == "Include" then
      local target = attributes:match("file%s*=%s*\"([^\"]+)\"")
      if target then
        local fullPath = directory .. "/" .. Normalize(target)
        if fullPath:find("%.xml$") then
          ExpandXml(fullPath, files, errors)
        else
          files[#files + 1] = fullPath
        end
      elseif tag == "Script" and selfClosing == "" then
        local closing = content:find("</Script>", position, true)
        if closing then
          files[#files + 1] = { code = content:sub(position, closing - 1), name = path }
          position = closing
        end
      end
    end
  end
end

function Loader.ReadToc(tocPath, errors)
  local files = {}
  local directory = Directory(tocPath)
  for line in io.lines(tocPath) do
    line = line:gsub("%s+$", "")
    if line ~= "" and not line:find("^#") then
      local entry = SplitEntry(line)
      if entry then
        local fullPath = directory .. "/" .. Normalize(entry)
        if fullPath:find("%.xml$") then
          ExpandXml(fullPath, files, errors)
        else
          files[#files + 1] = fullPath
        end
      end
    end
  end
  return files
end

function Loader.LoadBlizzard(addOnsRoot, names)
  for _, name in ipairs(names) do
    local tocPath = addOnsRoot .. "/" .. name .. "/" .. name .. ".toc"
    if io.open(tocPath, "r") then
      for _, path in ipairs(Loader.ReadToc(tocPath, Loader.blizzardErrors)) do
        local ok, message = Loader.RunFile(path, name, {})
        if not ok then
          Loader.blizzardErrors[#Loader.blizzardErrors + 1] = tostring(type(path) == "table" and path.name or path):sub(#addOnsRoot + 2) .. ": " .. tostring(message)
        end
      end
    else
      Loader.blizzardErrors[#Loader.blizzardErrors + 1] = "missing toc " .. tocPath
    end
  end
end

function Loader.LoadAddon(tocPath, addonName, savedVariables)
  local private = {}
  Loader.private = private
  Loader.files = Loader.ReadToc(tocPath, Loader.loadErrors)
  for _, path in ipairs(Loader.files) do
    local ok, message = Loader.RunFile(path, addonName, private)
    if not ok then
      Loader.loadErrors[#Loader.loadErrors + 1] = tostring(type(path) == "table" and path.name or path) .. ": " .. tostring(message)
    end
  end
  _G.WeakAurasSaved = savedVariables
  Frames.Fire("ADDON_LOADED", addonName)
  WowApi.loggedIn = true
  Frames.Fire("PLAYER_LOGIN")
  Frames.Fire("PLAYER_ENTERING_WORLD", true, false)
  Frames.Fire("LOADING_SCREEN_DISABLED")
  return private
end

return Loader

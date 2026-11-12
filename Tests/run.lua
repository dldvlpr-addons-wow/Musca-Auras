local print, tostring, type = print, tostring, type
local testsDirectory = (arg[0]:gsub("\\", "/"):match("^(.*)/[^/]*$")) or "."
local repositoryRoot = testsDirectory .. "/.."
package.path = testsDirectory .. "/Harness/?.lua;" .. package.path

local isWindows = package.config:sub(1, 1) == "\\"
local verbose = false
local mode, scenarioPath, filter

for _, value in ipairs(arg) do
  if value == "--verbose" then
    verbose = true
  elseif value == "--scenario" then
    mode = "single"
  elseif mode == "single" then
    scenarioPath = value
  elseif value:find("%.lua$") then
    scenarioPath = scenarioPath or value
  else
    -- Number ("68") or part of the file name ("EditMode"): runs the matching scenarios only, without the packs.
    filter = filter or value:lower()
  end
end

local function SortedCounts(counts, limit)
  local list = {}
  for key, count in pairs(counts) do
    list[#list + 1] = { key = tostring(key), count = count }
  end
  table.sort(list, function(a, b)
    if a.count == b.count then return a.key < b.key end
    return a.count > b.count
  end)
  local lines = {}
  for index = 1, math.min(limit, #list) do
    lines[#lines + 1] = string.format("    %s (%d)", list[index].key, list[index].count)
  end
  return lines, #list
end

local function RunSingle(path)
  local Environment = require("Environment")
  Environment.Setup()
  local Loader = require("Loader")
  local context = {
    Environment = Environment,
    Loader = Loader,
    Units = require("Units"),
    Frames = require("Frames"),
    WowApi = require("WowApi"),
    Clock = require("Clock"),
    Secret = require("Secret"),
    DocumentedApi = require("DocumentedApi"),
    Assertions = require("Assertions"),
    tocPath = repositoryRoot .. "/WeakAuras/WeakAuras.toc",
  }

  local failures = {}
  local scenario, loadError = loadfile(path)
  if not scenario then
    failures[#failures + 1] = "scenario load: " .. tostring(loadError)
  else
    local ok, message = xpcall(function() scenario()(context) end, debug.traceback)
    if not ok then
      failures[#failures + 1] = "assertion: " .. tostring(message)
    end
  end

  local function Section(title, items)
    if #items > 0 then
      print("  " .. title .. " (" .. #items .. "):")
      for _, item in ipairs(items) do
        print("    " .. tostring(item):gsub("\n", "\n      "))
      end
    end
  end

  local violations = context.Secret.violations
  local blocking = #failures + #Environment.errors + #Loader.loadErrors + #Environment.forbidden + #violations
  local pack = os.getenv("PACK")
  print((blocking == 0 and "OK  " or "KO  ") .. path .. (pack and " " .. pack or ""))
  Section("scenario failures", failures)
  Section("load errors", Loader.loadErrors)
  Section("runtime errors", Environment.errors)
  Section("forbidden actions", Environment.forbidden)
  Section("secret violations", violations)
  if verbose then
    Section("blizzard file errors", Loader.blizzardErrors)
    local lines, total = SortedCounts(Environment.missingGlobals, 400)
    if total > 0 then
      print("  missing globals (" .. total .. "):")
      print(table.concat(lines, "\n"))
    end
    lines, total = SortedCounts(context.DocumentedApi.stubCalls, 40)
    if total > 0 then
      print("  stub calls (" .. total .. "):")
      print(table.concat(lines, "\n"))
    end
    lines, total = SortedCounts(context.Frames.missingMethods, 40)
    if total > 0 then
      print("  missing widget methods (" .. total .. "):")
      print(table.concat(lines, "\n"))
    end
  end
  os.exit(blocking == 0 and 0 or 1)
end

local function ListScenarios()
  local directory = testsDirectory .. "/Scenarios"
  local command = isWindows and ('dir /b "' .. directory:gsub("/", "\\") .. '\\*.lua"') or ('ls "' .. directory .. '"')
  local list = {}
  local handle = io.popen(command)
  for name in handle:lines() do
    local lowerName = name:lower()
    local matches
    if not filter then
      matches = true
    elseif filter:find("^%d+$") then
      matches = lowerName:find("^0*" .. tonumber(filter) .. "_")
    else
      matches = lowerName:find(filter, 1, true)
    end
    if name:find("%.lua$") and matches then
      list[#list + 1] = directory .. "/" .. name
    end
  end
  handle:close()
  table.sort(list)
  return list
end

if mode == "single" then
  RunSingle(scenarioPath)
end

local interpreter = arg[-1] or "lua"
local scenarios = scenarioPath and { scenarioPath } or ListScenarios()
if filter and #scenarios == 0 then
  print("no scenario matches " .. filter)
  os.exit(1)
end
if not scenarioPath and not filter then
  -- Every shipped pack also loads in the addon: Tests/Packs/VerificationPack.lua, once per pack.
  local folders = dofile(testsDirectory .. "/Packs/PackFolders.lua")
  local packs = {}
  for _, folder in pairs(folders.class) do
    packs[#packs + 1] = testsDirectory .. "/Packs/" .. folder .. "/Pack" .. folder .. ".lua"
  end
  for _, pack in ipairs(folders.utility) do
    packs[#packs + 1] = testsDirectory .. "/Packs/Utility/" .. pack[1] .. "/Pack" .. pack[1] .. ".lua"
  end
  table.sort(packs)
  for _, pack in ipairs(packs) do
    scenarios[#scenarios + 1] = { path = testsDirectory .. "/Packs/VerificationPack.lua", pack = pack }
  end
end
local failed = 0
for _, entry in ipairs(scenarios) do
  local path = type(entry) == "table" and entry.path or entry
  local command = string.format('"%s" "%s" --scenario "%s"%s', interpreter, arg[0], path, verbose and " --verbose" or "")
  if type(entry) == "table" then
    command = (isWindows and 'set "PACK=%s" && %s' or 'PACK="%s" %s'):format(entry.pack, command)
  end
  if isWindows then
    command = '"' .. command .. '"'
  end
  local handle = io.popen(command .. " 2>&1")
  local output = handle:read("*a")
  handle:close()
  io.write(output)
  if not (output:find("^OK  ") or output:find("\nOK  ")) then
    failed = failed + 1
  end
end
print(string.format("%d scenario(s), %d failed", #scenarios, failed))
os.exit(failed == 0 and 0 or 1)

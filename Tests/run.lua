local print, tostring, type = print, tostring, type
local testsDirectory = (arg[0]:gsub("\\", "/"):match("^(.*)/[^/]*$")) or "."
local repositoryRoot = testsDirectory .. "/.."
package.path = testsDirectory .. "/Harness/?.lua;" .. package.path

local isWindows = package.config:sub(1, 1) == "\\"
local verbose = false
local mode, scenarioPath

for _, value in ipairs(arg) do
  if value == "--verbose" then
    verbose = true
  elseif value == "--scenario" then
    mode = "single"
  elseif mode == "single" then
    scenarioPath = value
  elseif not scenarioPath then
    scenarioPath = value
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
  print((blocking == 0 and "OK  " or "KO  ") .. path)
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
    if name:find("%.lua$") then
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
local failed = 0
for _, path in ipairs(scenarios) do
  local command = string.format('"%s" "%s" --scenario "%s"%s', interpreter, arg[0], path, verbose and " --verbose" or "")
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

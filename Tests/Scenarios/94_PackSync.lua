-- Every embedded pack matches its source: each class pack rebuilt by PackBuilder.lua (Musca Auras and ForeverAuras
-- targets) and each utility pack equals its encoded .txt, and ClassPacks.lua carries the class .txt.
-- Tables are compared decoded, so key order in the encoding does not matter. Fix: lua5.1 Tests/Packs/Regenerate.lua
local function ReadFile(path)
  local file = assert(io.open(path, "rb"))
  local text = file:read("*a")
  file:close()
  return text
end

local function Difference(expected, actual, path)
  if type(expected) ~= "table" or type(actual) ~= "table" then
    if expected ~= actual then return path .. ": " .. tostring(expected) .. " in the source, " .. tostring(actual) end
    return nil
  end
  for key, value in pairs(expected) do
    local problem = Difference(value, actual[key], path .. "." .. tostring(key))
    if problem then return problem end
  end
  for key, value in pairs(actual) do
    if expected[key] == nil then return path .. "." .. tostring(key) .. ": " .. tostring(value) .. " not in the source" end
  end
  return nil
end

return function(test)
  local Tool = dofile("Tests/Packs/AuraTool.lua")
  local folders = dofile("Tests/Packs/PackFolders.lua")
  local getenv = os.getenv
  local problems = {}

  local function Check(source, encodedPath, target)
    os.getenv = function(name)
      if name == "PACK_TARGET" then return target end
      return getenv(name)
    end
    local ok, built = pcall(dofile, source)
    os.getenv = getenv
    assert(ok, built)
    local problem = Difference(built, Tool.Decode(ReadFile(encodedPath)), encodedPath)
    if problem then problems[#problems + 1] = problem end
  end

  local env = { WeakAuras = { IsLibsOK = function() return true end }, select = select }
  local OptionsPrivate = {}
  setfenv(assert(loadfile("WeakAurasOptions/ClassPacks.lua")), env)(nil, OptionsPrivate)
  for class, folder in pairs(folders.class) do
    local base = "Tests/Packs/" .. folder .. "/Pack" .. folder
    Check(base .. ".lua", base .. ".txt")
    Check(base .. ".lua", base .. "ForeverAuras.txt", "ForeverAuras")
    if OptionsPrivate.classPacks[class] ~= ReadFile(base .. ".txt"):gsub("%s+$", "") then
      problems[#problems + 1] = class .. ": ClassPacks.lua differs from Pack" .. folder .. ".txt"
    end
  end
  for _, pack in ipairs(folders.utility) do
    local base = "Tests/Packs/Utility/" .. pack[1] .. "/Pack" .. pack[1]
    Check(base .. ".lua", base .. ".txt")
  end
  assert(#problems == 0, #problems .. " pack(s) out of date, run lua5.1 Tests/Packs/Regenerate.lua:\n"
    .. table.concat(problems, "\n"))
end

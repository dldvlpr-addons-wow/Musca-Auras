-- usage: lua5.1 Tests/Packs/Regenerate.lua (from the repository root)
-- Rebuilds every embedded pack in order: Pack<X>.txt and Pack<X>ForeverAuras.txt of the class packs,
-- Pack<X>.txt of the utility packs, then WeakAurasOptions/ClassPacks.lua and UtilityPacks.lua.
-- Scenario 94 fails when one of these files no longer matches its source.
local Tool = dofile("Tests/Packs/AuraTool.lua")
local folders = dofile("Tests/Packs/PackFolders.lua")
local getenv = os.getenv

local function Write(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

-- PackBuilder.lua reads PACK_TARGET at each load: answer it here instead of the shell.
local function Build(source, target)
  os.getenv = function(name)
    if name == "PACK_TARGET" then return target end
    return getenv(name)
  end
  local ok, transmit = pcall(dofile, source)
  os.getenv = getenv
  assert(ok, transmit)
  return Tool.Encode(transmit)
end

local classes = {}
for _, folder in pairs(folders.class) do classes[#classes + 1] = folder end
table.sort(classes)
for _, folder in ipairs(classes) do
  local base = "Tests/Packs/" .. folder .. "/Pack" .. folder
  Write(base .. ".txt", Build(base .. ".lua") .. "\n")
  Write(base .. "ForeverAuras.txt", Build(base .. ".lua", "ForeverAuras") .. "\n")
end
for _, pack in ipairs(folders.utility) do
  local base = "Tests/Packs/Utility/" .. pack[1] .. "/Pack" .. pack[1]
  Write(base .. ".txt", Build(base .. ".lua") .. "\n")
end

-- The Embed scripts write to the current output: point it at the options file.
for name, output in pairs({ Class = "WeakAurasOptions/ClassPacks.lua", Utility = "WeakAurasOptions/UtilityPacks.lua" }) do
  io.output(output)
  dofile("Tests/Packs/Embed" .. name .. "Packs.lua")
  io.output():close()
  io.output(io.stdout)
end
print(("%d class packs (two targets each) and %d utility packs regenerated"):format(#classes, #folders.utility))

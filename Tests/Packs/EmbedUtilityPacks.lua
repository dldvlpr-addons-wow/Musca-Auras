-- usage: lua Tests/Packs/EmbedUtilityPacks.lua > WeakAurasOptions/UtilityPacks.lua
-- The pack list, in display order, is in PackFolders.lua.
local packs = dofile("Tests/Packs/PackFolders.lua").utility
io.write("if not WeakAuras.IsLibsOK() then return end\n")
io.write("---@class OptionsPrivate\nlocal OptionsPrivate = select(2, ...)\n\n")
io.write("OptionsPrivate.utilityPacks = {\n")
for _, pack in ipairs(packs) do
  local folder = pack[1]
  local file = assert(io.open("Tests/Packs/Utility/" .. folder .. "/Pack" .. folder .. ".txt", "rb"))
  local text = file:read("*a"):gsub("%s+$", "")
  file:close()
  io.write(("  { name = %q, description = %q, category = %q,\n    icon = %q,\n    data = %q },\n")
    :format(pack[2], pack[3], pack[5], pack[4], text))
end
io.write("}\n")

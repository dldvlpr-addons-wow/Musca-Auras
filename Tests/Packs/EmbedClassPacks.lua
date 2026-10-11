-- usage: lua Tests/Packs/EmbedClassPacks.lua > WeakAurasOptions/ClassPacks.lua
local folders = {
  WARRIOR = "Guerrier", PALADIN = "Paladin", HUNTER = "Chasseur", ROGUE = "Voleur", PRIEST = "Pretre",
  SHAMAN = "Chaman", MAGE = "Mage", WARLOCK = "Demoniste", DRUID = "Druide",
}
local classes = {}
for class in pairs(folders) do classes[#classes + 1] = class end
table.sort(classes)
io.write("if not WeakAuras.IsLibsOK() then return end\n")
io.write("---@class OptionsPrivate\nlocal OptionsPrivate = select(2, ...)\n\n")
io.write("OptionsPrivate.classPacks = {\n")
for _, class in ipairs(classes) do
  local folder = folders[class]
  local file = assert(io.open("Tests/Packs/" .. folder .. "/Pack" .. folder .. ".txt", "rb"))
  local text = file:read("*a"):gsub("%s+$", "")
  file:close()
  io.write(("  %s = %q,\n"):format(class, text))
end
io.write("}\n")

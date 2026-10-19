-- AuraTags: the tags of an aura and of its groups are found by the search of the aura list as "#tag", and they
-- are neither exported nor changed by an update (non_transmissable_fields).
-- AuraSearchText is a local of WeakAurasOptions/WeakAurasOptions.lua: its block is cut from the source.
local function Aura(id, parent, tags, controlledChildren)
  return { id = id, uid = id, parent = parent, tags = tags, controlledChildren = controlledChildren,
    regionType = controlledChildren and "group" or "icon", triggers = {}, subRegions = {} }
end

return function(test)
  local saved = {
    displays = {
      Raid = Aura("Raid", nil, " Raid , boss ", { "Shield" }),
      Shield = Aura("Shield", "Raid", "tank, ,defensive"),
      Plain = Aura("Plain", nil, nil),
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/WeakAurasOptions.lua")
  local file = assert(io.open(path, "rb"))
  local source = file:read("*a"):gsub("\r\n", "\n")
  file:close()

  local block = assert(source:match("\n(local searchSpellNames.-\nlocal function AuraSearchText.-\nend)\n"),
    "AuraSearchText block")
  local AuraSearchText = assert(loadstring("local OptionsPrivate = ...\n" .. block .. "\nreturn AuraSearchText",
    "AuraSearchText"))({ Private = private })

  local shield = AuraSearchText(WeakAuras.GetData("Shield"))
  assert(shield:find("#tank", 1, true) and shield:find("#defensive", 1, true), "own tags, empty tag skipped")
  assert(shield:find("#raid", 1, true) and shield:find("#boss", 1, true), "tags of the group, trimmed and lowered")
  assert(not shield:find("#\n", 1, true), "no empty tag")
  local raid = AuraSearchText(WeakAuras.GetData("Raid"))
  assert(raid:find("#raid", 1, true) and not raid:find("#tank", 1, true), "a group does not take the tags of a member")
  assert(not AuraSearchText(WeakAuras.GetData("Plain")):find("#", 1, true), "no tags")

  assert(private.non_transmissable_fields.tags and private.non_transmissable_fields_v2000.tags,
    "tags are not exported and not part of an update diff")
end

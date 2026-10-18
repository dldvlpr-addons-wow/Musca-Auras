-- Partial import: the children unchecked on the import screen leave the uid map with their own children,
-- and the parents written in phase 2 no longer list them.
-- BuildUidMap and RemoveExcludedChildren are locals of WeakAurasOptions/OptionsFrames/Update.lua: their block
-- is cut from the source and run alone.
return function(test)
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/OptionsFrames/Update.lua")
  local file = assert(io.open(path, "rb"))
  local source = file:read("*a"):gsub("\r\n", "\n")
  file:close()

  local block = assert(source:match("\n(local function BuildUidMap.-\nlocal function RemoveExcludedChildren.-\nend)\n"),
    "uid map block")
  -- tDeleteItem is a Blizzard global the harness does not have
  local function tDeleteItem(list, item)
    for index = #list, 1, -1 do
      if list[index] == item then
        table.remove(list, index)
      end
    end
  end
  local BuildUidMap, RemoveExcludedChildren = assert(loadstring("local tDeleteItem = ...\n" .. block
    .. "\nreturn BuildUidMap, RemoveExcludedChildren", "Update.lua uid map"))(tDeleteItem)

  local function Aura(id, parent, controlledChildren)
    return { id = id, uid = id .. "Uid", parent = parent, controlledChildren = controlledChildren, regionType = "icon" }
  end
  local root = Aura("Pack", nil, { "A", "Sub", "D" })
  root.regionType = "group"
  local a, sub, b, c, d = Aura("A", "Pack"), Aura("Sub", "Pack", { "B", "C" }), Aura("B", "Sub"), Aura("C", "Sub"),
    Aura("D", "Pack")
  sub.regionType = "group"
  d.anchorFrameType, d.anchorFrameFrame = "SELECTFRAME", "WeakAuras:B"
  local children = { a, sub, b, c, d }

  local uidMap = BuildUidMap(root, children, "new")
  RemoveExcludedChildren(uidMap, { [sub] = true, [b] = true, [a] = true })

  assert(uidMap:GetTotalCount() == 2, "Pack and D left: " .. uidMap:GetTotalCount())
  for _, removed in ipairs({ a, sub, b, c }) do
    assert(not uidMap:Contains(removed.uid), removed.id .. " removed")
  end
  local rootData = uidMap:GetPhase2Data(root.uid)
  assert(#rootData.controlledChildren == 1 and rootData.controlledChildren[1] == "D", "Pack lists D only")
  assert(uidMap:GetPhase2Data(d.uid).anchorFrameFrame == nil, "anchor on a removed aura dropped")

  local full = BuildUidMap(root, children, "new")
  RemoveExcludedChildren(full, {})
  assert(full:GetTotalCount() == 6, "nothing excluded, nothing removed")
end

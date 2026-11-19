-- A deleted group restored from the archive: the real import runs (decode, conversion, PreAdd) up to the update
-- window, which the harness cannot open. The data it receives must match the deleted aura: uid, parent, children
-- in order, tags and settings.
local function Icon(id, parent, spellId)
  return {
    id = id, uid = id .. "-uid", parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { spellId }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 48, height = 40, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Same(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for key, value in pairs(a) do
    if not Same(value, b[key]) then return false end
  end
  for key in pairs(b) do
    if a[key] == nil then return false end
  end
  return true
end

return function(test)
  local saved = { displays = {
    Pack = {
      id = "Pack", uid = "Pack-uid", regionType = "group", internalVersion = 91, controlledChildren = { "PackB", "PackA" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 12, yOffset = -7,
      tags = "raid",
    },
    PackA = Icon("PackA", "Pack", "6673"),
    PackB = Icon("PackB", "Pack", "774"),
  } }
  saved.displays.PackB.tags = "healer"
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate) private = addonPrivate end)
  test.Environment.Advance(1)

  local before = {}
  for _, id in ipairs({ "Pack", "PackA", "PackB" }) do before[id] = CopyTable(WeakAuras.GetData(id)) end

  assert(private.ArchiveDeletedAura("Pack"), "archive failed")
  for _, id in ipairs({ "PackA", "PackB", "Pack" }) do WeakAuras.Delete(WeakAuras.GetData(id)) end
  assert(WeakAuras.GetData("Pack") == nil and WeakAuras.GetData("PackA") == nil, "group not deleted")
  -- The update window keeps the uids only when no live aura holds them any more.
  assert(private.GetDataByUID("Pack-uid") == nil and private.GetDataByUID("PackB-uid") == nil, "uids not freed")
  local list = private.ListDeletedAuras()
  assert(#list == 1 and list[1].id == "Pack", "deleted group not listed")

  -- The import stops at the update window: the data it would show is captured there.
  local received
  private.LoadOptions = function() return true end
  WeakAuras.OpenOptions = function() end
  private.OpenUpdate = function(data, children) received = { data = data, children = children } end
  assert(private.RestoreDeletedAura(list[1].key), "restore refused")
  assert(received, "import did not reach the update window")
  local restored = received
  received = nil
  assert(private.RestoreDeletedAura("missing-key") == false, "restored a key that does not exist")
  assert(received == nil, "import opened for a key that does not exist")
  received = restored

  local group, children = received.data, received.children or {}
  assert(group.id == "Pack" and group.uid == "Pack-uid", "group id or uid changed")
  assert(group.parent == nil, "group got a parent")
  assert(group.tags == "raid", "group tags lost")
  assert(group.xOffset == 12 and group.yOffset == -7, "group position lost")
  assert(table.concat(group.controlledChildren, ",") == "PackB,PackA", "children order lost: "
    .. table.concat(group.controlledChildren, ","))
  assert(#children == 2, "expected 2 children, got " .. #children)
  for position, child in ipairs(children) do
    local original = before[group.controlledChildren[position]]
    assert(child.id == original.id and child.uid == original.uid, "child " .. position .. ": id or uid changed")
    assert(child.parent == "Pack", child.id .. ": parent lost")
    assert(child.tags == original.tags, child.id .. ": tags " .. tostring(child.tags))
    -- Every other saved setting comes back as it was.
    for key, value in pairs(original) do
      if key ~= "tags" then
        assert(Same(child[key], value), child.id .. ": " .. key .. " changed")
      end
    end
  end
  for key, value in pairs(before.Pack) do
    if key ~= "tags" then assert(Same(group[key], value), "Pack: " .. key .. " changed") end
  end

  -- An aura without any tag is archived without them: the raw export is imported.
  WeakAuras.Add(Icon("Lone", nil, "2048"))
  local lone = CopyTable(WeakAuras.GetData("Lone"))
  assert(private.ArchiveDeletedAura("Lone"), "archive of an untagged aura failed")
  WeakAuras.Delete(WeakAuras.GetData("Lone"))
  local loneKey
  for _, entry in ipairs(private.ListDeletedAuras()) do
    if entry.id == "Lone" then loneKey = entry.key end
  end
  received = nil
  assert(loneKey and private.RestoreDeletedAura(loneKey), "untagged aura not restored")
  assert(received and received.data.uid == lone.uid and received.data.parent == nil and received.data.tags == nil,
    "untagged aura: uid, parent or tags changed")
  for key, value in pairs(lone) do
    assert(Same(received.data[key], value), "Lone: " .. key .. " changed")
  end
end

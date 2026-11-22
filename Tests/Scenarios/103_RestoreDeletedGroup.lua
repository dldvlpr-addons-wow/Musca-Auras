local function Icon(id, parent)
  return {
    id = id, uid = id .. "-uid", parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local function Group(id, children, parent)
  return {
    id = id, uid = id .. "-uid", parent = parent, regionType = "group", internalVersion = 91,
    controlledChildren = children,
    load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
    anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
end

-- A deleted group, restored from the archive, reaches the import window with the uid, the parent and the order
-- of the children of the original, for a flat group (export without links) and a nested one (export with links).
return function(test)
  local saved = {
    displays = {
      Flat = Group("Flat", { "FlatB", "FlatA" }),
      FlatA = Icon("FlatA", "Flat"),
      FlatB = Icon("FlatB", "Flat"),
      Flat2 = Group("Flat2", { "Flat2B", "Flat2A" }),
      Flat2A = Icon("Flat2A", "Flat2"),
      Flat2B = Icon("Flat2B", "Flat2"),
      Outer = Group("Outer", { "Inner", "OuterIcon" }),
      Inner = Group("Inner", { "InnerB", "InnerA" }, "Outer"),
      InnerA = Icon("InnerA", "Inner"),
      InnerB = Icon("InnerB", "Inner"),
      OuterIcon = Icon("OuterIcon", "Outer"),
    },
  }
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate)
    private = addonPrivate
  end)
  test.Environment.Advance(2)

  -- The real WeakAuras.Import runs; only the import window is replaced.
  local opened
  private.LoadOptions = function() return true end
  private.OpenUpdate = function(data, children) opened = { data = data, children = children or {} } end

  local function Snapshot(id)
    local shot = {}
    for aura in private.TraverseAll(WeakAuras.GetData(id)) do
      shot[aura.id] = { uid = aura.uid, parent = aura.parent,
        children = aura.controlledChildren and table.concat(aura.controlledChildren, ",") }
    end
    return shot
  end

  local function Check(id, original, where)
    local restored = { [opened.data.id] = opened.data }
    for _, child in ipairs(opened.children) do restored[child.id] = child end
    local count = 0
    for auraId, expected in pairs(original) do
      count = count + 1
      local aura = restored[auraId]
      assert(aura, where .. ": " .. auraId .. " missing")
      assert(aura.uid == expected.uid, where .. ": uid of " .. auraId)
      assert(aura.parent == expected.parent, where .. ": parent of " .. auraId .. " is " .. tostring(aura.parent))
      local children = aura.controlledChildren and table.concat(aura.controlledChildren, ",")
      assert(children == expected.children, where .. ": children of " .. auraId .. " are " .. tostring(children))
    end
    assert(opened.data.id == id and #opened.children + 1 == count, where .. ": wrong auras restored")
  end

  local function DeleteAndRestore(id, tags)
    local original = Snapshot(id)
    for auraId, auraTags in pairs(tags or {}) do WeakAuras.GetData(auraId).tags = auraTags end
    assert(private.ArchiveDeletedAura(id), id .. ": archive failed")
    WeakAuras.Delete(WeakAuras.GetData(id))
    assert(WeakAuras.GetData(id) == nil, id .. ": not deleted")
    local key
    for _, entry in ipairs(private.ListDeletedAuras()) do
      if entry.id == id then key = entry.key end
    end
    opened = nil
    -- Options open only for the restore: Delete would refresh them.
    local isOptionsOpen, optionsFrame = WeakAuras.IsOptionsOpen, private.OptionsFrame
    WeakAuras.IsOptionsOpen = function() return true end
    private.OptionsFrame = function() return { IsVisible = function() return true end } end
    local restoredOk = private.RestoreDeletedAura(key)
    WeakAuras.IsOptionsOpen, private.OptionsFrame = isOptionsOpen, optionsFrame
    assert(restoredOk, id .. ": restore failed")
    assert(opened, id .. ": import window not opened")
    Check(id, original, id .. (tags and " with tags" or ""))
    local restoredTags = { [opened.data.id] = opened.data.tags }
    for _, child in ipairs(opened.children) do restoredTags[child.id] = child.tags end
    for auraId, auraTags in pairs(tags or {}) do
      assert(restoredTags[auraId] == auraTags, id .. ": tags of " .. auraId .. " lost")
    end
  end

  -- Without tags the archive imports the export string, with tags the decoded table.
  DeleteAndRestore("Flat")
  DeleteAndRestore("Outer", { Outer = "raid", InnerA = "tank" })
  -- The decoded table of a flat group: the import rebuilds the links itself.
  DeleteAndRestore("Flat2", { Flat2B = "heal" })

  local before = opened
  assert(private.RestoreDeletedAura("unknown-key") == false, "unknown key restored")
  assert(opened == before, "import window opened for an unknown key")
end

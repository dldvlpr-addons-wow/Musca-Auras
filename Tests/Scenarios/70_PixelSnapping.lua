local function Icon(id, extra)
  local data = {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useExactSpellId = true,
      auraspellids = { "6673" }, matchesShowOn = "showOnAlways" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
  for key, value in pairs(extra or {}) do
    data[key] = value
  end
  return data
end

-- Pixel perfect option: the textures of the aura snap to the pixel grid, and get their own snapping back when off.
return function(test)
  local saved = { displays = {
    Sharp = Icon("Sharp", { pixelPerfect = true }),
    Smooth = Icon("Smooth"),
  } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local function Snapped(id)
    local icon = WeakAuras.GetRegion(id).icon
    return icon:IsSnappingToPixelGrid(), icon:GetTexelSnappingBias()
  end

  assert(Snapped("Sharp") == true, "icon of a pixel perfect aura snaps")
  assert(Snapped("Smooth") == false, "icon keeps the smooth default")

  local clone = private.EnsureRegion("Sharp", "c1")
  assert(clone.icon:IsSnappingToPixelGrid() == true, "clone of a pixel perfect aura snaps")
  -- The released clone goes back to the pool; the next clone of a smooth aura takes it and must not stay snapped.
  private.ReleaseClone("Sharp", "c1", "icon")
  local reused = private.EnsureRegion("Smooth", "c1")
  assert(reused == clone, "clone taken back from the pool")
  assert(reused.icon:IsSnappingToPixelGrid() == false, "reused clone gets its own snapping back")

  -- A frame made after the aura was loaded, like an extra bar or a Blizzard aura button.
  local function LateTexture(id)
    local late = CreateFrame("Frame", nil, CreateFrame("Frame", nil, WeakAuras.GetRegion(id)))
    local texture = late:CreateTexture()
    texture:SetSnapToPixelGrid(false)
    private.SnapLateTextures(late)
    return texture:IsSnappingToPixelGrid()
  end
  assert(LateTexture("Sharp") == true, "late texture of a pixel perfect aura snaps")
  assert(LateTexture("Smooth") == false, "late texture of a smooth aura is left alone")

  saved.displays.Sharp.pixelPerfect = nil
  WeakAuras.Add(saved.displays.Sharp)
  assert(Snapped("Sharp") == false, "snapping given back when the option is off")
end

-- Secret geometry (region anchored to a frame with secret size) and secret unit identity (secret GUID).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = { GeometryIcon = {
    id = "GeometryIcon", uid = "GeometryIcon", regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 50, height = 40, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  } } })
  test.Environment.Advance(1)
  local Secret = test.Secret

  -- Icon inner and outer anchors: a secret icon size falls back to the configured size.
  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, duration = 120 })
  test.Environment.Advance(0.5)
  local region = WeakAuras.GetRegion("GeometryIcon")
  assert(region and region.UpdateInnerOuterSize, "icon region missing")
  region.inner = CreateFrame("Frame", nil, region)
  region.GetWidth = function() return Secret.Wrap(50) end
  region.GetHeight = function() return Secret.Wrap(40) end
  local ok, err = pcall(region.UpdateInnerOuterSize)
  assert(ok, "secret icon size: " .. tostring(err))
  local innerWidth, innerHeight = region.inner:GetSize()
  assert(math.abs(innerWidth - 40) < 0.001 and math.abs(innerHeight - 32) < 0.001,
    "inner size not taken from the configuration")

  -- Icon modify: the width copy is skipped when the size read back is secret.
  local function RefuseSecretSize(frame)
    local setWidth, setHeight = frame.SetWidth, frame.SetHeight
    frame.SetWidth = function(self, value)
      assert(not Secret.IsSecret(value), "secret width passed to SetWidth")
      return setWidth(self, value)
    end
    frame.SetHeight = function(self, value)
      assert(not Secret.IsSecret(value), "secret height passed to SetHeight")
      return setHeight(self, value)
    end
  end
  RefuseSecretSize(region)
  ok, err = pcall(private.regionTypes.icon.modify, region:GetParent(), region, WeakAuras.GetData("GeometryIcon"))
  assert(ok, "icon modify with secret size: " .. tostring(err))

  -- Fallback region (unsupported type): a secret text size does not resize the region.
  local fallbackData = {
    id = "GeometryFallback", uid = "GeometryFallback", regionType = "unknownType", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL" }, untrigger = {} } },
    load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 50, height = 40, fontSize = 12, anchorPoint = "CENTER", selfPoint = "CENTER",
    anchorFrameType = "SCREEN",
  }
  WeakAuras.Add(fallbackData)
  local fallback = WeakAuras.GetRegion("GeometryFallback")
  assert(fallback and fallback.text, "fallback region missing")
  fallback.text.GetWidth = function() return Secret.Wrap(80) end
  fallback.text.GetStringHeight = function() return Secret.Wrap(12) end
  RefuseSecretSize(fallback)
  ok, err = pcall(private.regionTypes.fallback.modify, fallback:GetParent(), fallback, fallbackData)
  assert(ok, "fallback modify with secret text size: " .. tostring(err))

  -- Progress textures: a secret sub-region size falls back to the configured size.
  for name, field in pairs({ subcirculartexture = "circularTexture", sublineartexture = "linearTexture" }) do
    local subRegion = private.subRegionTypes[name].acquire()
    subRegion.configuredWidth, subRegion.configuredHeight = 50, 40
    subRegion.GetSize = function() return Secret.Wrap(10), Secret.Wrap(10) end
    ok, err = pcall(subRegion.OnSizeChanged, subRegion)
    assert(ok, name .. " secret size: " .. tostring(err))
    assert(subRegion[field].width == 50 and subRegion[field].height == 40, name .. " not sized from the configuration")
  end

  -- Model: a secret size does not keep a stale "too small" hidden state.
  local model = private.subRegionTypes.submodel.acquire()
  model.toosmall = true
  model.GetWidth = function() return Secret.Wrap(0) end
  model.GetHeight = function() return Secret.Wrap(0) end
  ok, err = pcall(model.OnSizeChanged, model)
  assert(ok, "model secret size: " .. tostring(err))
  assert(model.toosmall == false, "model kept hidden as too small")

  -- Class colour: a secret GUID falls back to UnitIsPlayer.
  test.Units.DefineUnit("target", { guid = Secret.Wrap("Player-0000-target"), isPlayerControlled = true })
  ok, err = pcall(private.UnitPlayerControlledFixed, "target")
  assert(ok, "secret GUID: " .. tostring(err))
  assert(err == true, "player not recognised behind a secret GUID")
  test.Units.DefineUnit("focus", { guid = Secret.Wrap("Creature-0-0"), isPlayerControlled = false })
  assert(private.UnitPlayerControlledFixed("focus") == false, "creature taken as a player")
  test.Units.DefineUnit("mouseover", { guid = "Player-0000-mouseover" })
  assert(private.UnitPlayerControlledFixed("mouseover") == true, "readable GUID path broken")

  -- %n with class colour: a secret class gives the name without colour.
  local formatter = private.format_types.Unit.CreateFormatter("n", function(key, default)
    if key == "n_color" then return "class" end
    return default
  end)
  local unitClass = UnitClass
  UnitClass = function() return Secret.Wrap("Warrior"), Secret.Wrap("WARRIOR"), 1 end
  ok, err = pcall(formatter, "target")
  UnitClass = unitClass
  assert(ok, "secret class: " .. tostring(err))
  assert(err == WeakAuras.UnitName("target"), "secret class changed the name")
  local readable = formatter("mouseover")
  assert(readable ~= WeakAuras.UnitName("mouseover"), "readable class colour lost")
end

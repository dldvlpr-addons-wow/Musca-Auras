-- Contract of the unit glow (BlizzardAuraDisplay UnitGlowElement/SetupUnitGlow/RetireInstance) and of
-- SecretAuraGlow.StyleElementGlow without a readable size: stretched holder, shift, cache key, parts.
return function(test)
  local savedCreateFrame, savedPolicy = CreateFrame, CustomAuraContainerAuraProcessingPolicy
  local savedIsLoaded, savedStringUtil = C_AddOns.IsAddOnLoaded, C_StringUtil
  local savedFormatter = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
  CustomAuraContainerAuraProcessingPolicy = { None = 0 }
  C_AddOns.IsAddOnLoaded = function(name) return name == "Blizzard_AuraContainer" or savedIsLoaded(name) end
  C_StringUtil = C_StringUtil or {}
  C_StringUtil.CreateNumericRuleFormatter = function() return { SetBreakpoints = function() end } end

  -- Native containers: the unit glow slot hands its button to initializeFrame at once.
  local noop = function() end
  -- Like the client: adding a group already handed to the button raises.
  local function ShownAdd(button, group)
    assert(not button.shown[group], "AddAuraShownAnimation: group already added")
    button.shown[group] = true
    button.added = button.added + 1
  end
  local function ShownRemove(button, group) button.shown[group] = nil end
  AuraUtil = AuraUtil or {}
  local savedValidFilter = AuraUtil.IsValidFilterString
  AuraUtil.IsValidFilterString = function() return true end
  local glowContainers = {}
  CreateFrame = function(frameType, name, parent, template)
    if frameType ~= "AuraContainer" then return savedCreateFrame(frameType, name, parent, template) end
    local container = savedCreateFrame("Frame", name, parent)
    for _, method in ipairs({ "SetEnabled", "SetAuraProcessingPolicy", "SetUnit", "SetAuraSlotFilterString",
      "SetAuraSlotCandidateFilters", "SetAuraSlotSortMethod", "SetAuraGroupSortMethod", "SetAuraGroupFilterString",
      "SetAuraGroupCandidateFilters", "UpdateAllAuras", "AddAuraGroup", "SetAuraGroupLayout",
      "SetAuraGroupMaxFrameCount", "SetFlowLayoutAxis", "SetFlowLayoutAnchorPoint", "SetFlowLayoutGrowthDirection" }) do
      container[method] = noop
    end
    container.AddAuraSlot = function(self, slotName, _, options)
      if slotName ~= "UnitGlow" then return end
      glowContainers[#glowContainers + 1] = self
      local button = savedCreateFrame("Frame", nil, self)
      button.added, button.shown = 0, {}
      button.AddAuraShownAnimation = ShownAdd
      button.RemoveAuraShownAnimation = ShownRemove
      self.glowButton = button
      options.initializeFrame(button)
    end
    return container
  end

  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local sortMethodsBefore, sortDirectionBefore = AuraContainerSortMethod, AuraContainerSortDirection
  AuraContainerSortMethod, AuraContainerSortDirection = setmetatable({}, { __index = function() return 0 end }), { Normal = 0, Reverse = 1 }
  local Secret = test.Secret
  local Methods = test.Frames.Methods

  local function Near(actual, expected, message)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-6,
      ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end

  local restricted = false
  local originals = {
    IsRestricted = WeakAuras.IsRestricted, After = C_Timer.After, CreateAnimation = Methods.CreateAnimation,
    Refresh = Display.RefreshShownAnimations,
  }
  WeakAuras.IsRestricted = function() return restricted end
  local timers = {}
  C_Timer.After = function(delay, callback) timers[#timers + 1] = { delay = delay, callback = callback } end
  local function Drain()
    local count = #timers
    for _ = 1, count do table.remove(timers, 1).callback() end
  end
  local refreshed = {}
  Display.RefreshShownAnimations = function(native) refreshed[native] = (refreshed[native] or 0) + 1 end

  local animations = setmetatable({}, { __mode = "k" })
  Methods.CreateAnimation = function(self, kind, name)
    local animation = originals.CreateAnimation(self, kind, name)
    local record = { kind = kind }
    animations[animation] = record
    rawset(animation, "SetDuration", function(_, value) record.duration = value end)
    rawset(animation, "SetFromAlpha", function(_, value) record.from = value end)
    rawset(animation, "SetToAlpha", function(_, value) record.to = value end)
    return animation
  end
  local function Fades(glow)
    local list = {}
    for _, group in ipairs(glow.groups) do
      for _, animation in ipairs({ group:GetAnimations() }) do
        if animations[animation].kind == "Alpha" then list[#list + 1] = animations[animation] end
      end
    end
    return list
  end

  local function PointOf(frame, name)
    for index = 1, frame:GetNumPoints() do
      local point, relativeTo, relativePoint, x, y = frame:GetPoint(index)
      if point == name then return relativeTo, relativePoint, x, y end
    end
  end
  local function AssertPoint(frame, name, anchor, x, y, message)
    local relativeTo, relativePoint, actualX, actualY = PointOf(frame, name)
    assert(relativeTo == anchor, message .. ": " .. name .. " not on the anchor")
    Same(relativePoint, name, message .. " relative point")
    Near(actualX, x, message .. " " .. name .. " x")
    Near(actualY, y, message .. " " .. name .. " y")
  end
  local function AllPointsOn(texture, holder)
    local points = texture:GetNumPoints()
    for index = 1, points do
      local _, relativeTo = texture:GetPoint(index)
      if relativeTo ~= holder then return false end
    end
    return points > 0
  end

  local parent = CreateFrame("Frame")
  local anchor = CreateFrame("Frame")
  local function NewButton()
    return { added = 0, shown = {}, AddAuraShownAnimation = ShownAdd, RemoveAuraShownAnimation = ShownRemove }
  end
  local function Style(entry, element, button, width, height, shiftX, shiftY)
    Display.StyleElementGlow(entry, button or NewButton(), parent, anchor, element, width, height, shiftX, shiftY)
    return entry.nativeGlow
  end
  -- Restricted: built at once, without the queue.
  local function Build(element, width, height, shiftX, shiftY)
    restricted = true
    local glow = Style({}, element, nil, width, height, shiftX, shiftY)
    restricted = false
    return glow
  end

  -- Stretched mode: width or height nil or secret.
  do
    local element = { glow = true, glowXOffset = 3, glowYOffset = 5 }
    local cases = {
      ["nil size"] = {}, ["nil height"] = { 40 }, ["nil width"] = { nil, 40 },
      ["secret width"] = { Secret.Wrap(40), 40 }, ["secret height"] = { 40, Secret.Wrap(40) },
      ["both secret"] = { Secret.Wrap(40), Secret.Wrap(40) },
    }
    for label, size in pairs(cases) do
      local glow = Build(element, size[1], size[2], 7, -2)
      AssertPoint(glow.holder, "TOPLEFT", anchor, 7 - 3, -2 + 5, label)
      AssertPoint(glow.holder, "BOTTOMRIGHT", anchor, 7 + 3, -2 - 5, label)
      Same(PointOf(glow.holder, "CENTER"), nil, label .. " has a CENTER point")
    end
    -- Without shift.
    local glow = Build(element)
    AssertPoint(glow.holder, "TOPLEFT", anchor, -3, 5, "no shift")
    AssertPoint(glow.holder, "BOTTOMRIGHT", anchor, 3, -5, "no shift")

    -- Known size: shift on CENTER, size grown by the offsets.
    glow = Build(element, 40, 30, 7, -2)
    AssertPoint(glow.holder, "CENTER", anchor, 7, -2, "known size")
    Same(PointOf(glow.holder, "TOPLEFT"), nil, "known size keeps a TOPLEFT point")
    Near(glow.holder:GetWidth(), 46, "known width")
    Near(glow.holder:GetHeight(), 40, "known height")

    -- Textures follow the holder in stretched mode; Pixel and Shine draw nothing.
    for _, kind in ipairs({ "Proc", "buttonOverlay", "pulse" }) do
      glow = Build({ glow = true, glowType = kind })
      assert(#glow.textures >= 1, kind .. " without texture")
      for index, texture in ipairs(glow.textures) do
        assert(AllPointsOn(texture, glow.holder), kind .. " texture " .. index .. " not SetAllPoints on the holder")
      end
    end
    Same(#Build({ glow = true, glowType = "buttonOverlay" }).textures, 2, "buttonOverlay texture count")
    for _, kind in ipairs({ "Pixel", "Shine" }) do
      glow = Build({ glow = true, glowType = kind })
      assert(#glow.textures == 0 and #glow.groups == 0 and #glow.frames == 0, kind .. " draws in stretched mode")
    end
    glow = Build({ glow = true, glowType = "Pixel" }, 40, 40)
    assert(#glow.frames == 4 and #glow.textures > 0, "Pixel does not draw with a known size")

    -- Pulse: IconAlert texture, two Alpha animations of glowDuration / 2.
    glow = Build({ glow = true, glowType = "pulse", glowDuration = 3 })
    Same(glow.textures[1]:GetTexture(), "Interface\\SpellActivationOverlay\\IconAlert", "pulse texture")
    local fades = Fades(glow)
    Same(#fades, 2, "pulse animation count")
    Near(fades[1].from, 0.25, "rise from") Near(fades[1].to, 1, "rise to") Near(fades[1].duration, 1.5, "rise duration")
    Near(fades[2].from, 1, "fall from") Near(fades[2].to, 0.25, "fall to") Near(fades[2].duration, 1.5, "fall duration")
  end

  -- Cache key with a nil size.
  do
    local button, entry = NewButton(), {}
    local element = { glow = true, glowXOffset = 2, glowYOffset = 2 }
    restricted = true
    local first = Style(entry, element, button, nil, nil, 1, 1)
    Same(Style(entry, { glow = true, glowXOffset = 2, glowYOffset = 2 }, button, nil, nil, 1, 1), first, "same nil-size glow rebuilt")
    Same(Style(entry, element, button, Secret.Wrap(40), Secret.Wrap(40), 1, 1), first, "secret size not seen as nil")
    local shifted = Style(entry, element, button, nil, nil, 2, 1)
    assert(shifted ~= first, "shiftX change did not rebuild")
    local shiftedY = Style(entry, element, button, nil, nil, 2, 3)
    assert(shiftedY ~= shifted, "shiftY change did not rebuild")
    AssertPoint(shiftedY.holder, "TOPLEFT", anchor, 2 - 2, 3 + 2, "rebuilt glow")
    local sized = Style(entry, element, button, 40, 40, 2, 3)
    assert(sized ~= shiftedY, "known size reused the stretched glow")
    restricted = false
  end

  -- Display path: Aura (Modern) region on a unit frame.
  local function Data(options)
    return {
      id = "UnitGlowAura", uid = "UnitGlowAura", regionType = "icon", width = 30, height = 30,
      anchorFrameType = options.anchorFrameType or "UNITFRAME",
      triggers = { { trigger = { type = "secretAura", unit = options.unit or "target", debuffType = "HELPFUL" } } },
      blizzardAuraDisplay = options.display,
    }
  end
  local function Mount(options)
    local region = CreateFrame("Frame")
    local data = Data(options)
    assert(Display.Validate(data) == nil, tostring(Display.Validate(data)))
    Display.Apply(region, data)
    return region, region.blizzardAuraDisplay.instances[1].unitGlow
  end
  local function Reapply(region, options)
    Display.Apply(region, Data(options))
  end
  local function GlowOf(state) return state.glowEntry and state.glowEntry.nativeGlow end

  -- Pulse, own color, padding as offsets, shifts, deferred first build.
  do
    local region, state = Mount({ display = {
      unitGlow = true, unitGlowType = "pulse", unitUseGlowColor = true, unitGlowColor = { 0.1, 0.2, 0.3, 0.4 },
      unitGlowDuration = 2, unitGlowPadding = 6, unitGlowX = 4, unitGlowY = -3,
    } })
    assert(state, "unit glow not created")
    Same(state.button, state.container.glowButton, "glow button")
    Same(state.glowEntry.native, state, "glow entry native")
    Same(GlowOf(state), nil, "glow built before the drain")
    assert(#timers >= 1, "first build not deferred")
    Drain()
    local glow = GlowOf(state)
    assert(glow, "glow not built after the drain")
    Same(refreshed[state], 1, "RefreshShownAnimations not given the glow state at the drain")
    AssertPoint(glow.holder, "TOPLEFT", state.button, 4 - 6, -3 + 6, "unit glow")
    AssertPoint(glow.holder, "BOTTOMRIGHT", state.button, 4 + 6, -3 - 6, "unit glow")
    Same(glow.holder:GetParent(), state.overlay, "holder parent")
    Same(glow.textures[1]:GetTexture(), "Interface\\SpellActivationOverlay\\IconAlert", "pulse type")
    Near(Fades(glow)[1].duration, 1, "pulse duration from unitGlowDuration")
    local r, g, b, a = glow.textures[1]:GetVertexColor()
    Near(r, 0.1, "own color r") Near(g, 0.2, "own color g") Near(b, 0.3, "own color b") Near(a, 0.4, "own color a")

    -- Disabled: the glow is cleared.
    Reapply(region, { display = { unitGlow = false } })
    Same(GlowOf(state), nil, "glow kept after disabling")
    assert(not glow.holder:IsShown(), "holder shown after disabling")

    -- Enabled again with another padding: rebuilt at once (a cleared glow exists); a non unit frame anchor clears it.
    Reapply(region, { display = { unitGlow = true, unitGlowPadding = 1 } })
    local rebuilt = GlowOf(state)
    assert(rebuilt and rebuilt ~= glow, "glow not rebuilt")
    AssertPoint(rebuilt.holder, "TOPLEFT", state.button, -1, 1, "rebuilt")
    Reapply(region, { anchorFrameType = "SCREEN", display = { unitGlow = true } })
    Same(GlowOf(state), nil, "glow kept on a non unit frame anchor")
  end

  -- Any other type is Proc; unitUseGlowColor false is gold whatever unitGlowColor holds.
  do
    local _, state = Mount({ display = { unitGlow = true, unitGlowType = "bogus", unitUseGlowColor = false,
      unitGlowColor = { 0.5, 0.5, 0.5, 1 }, unitGlowPadding = 2 } })
    Drain()
    local glow = GlowOf(state)
    assert(glow, "default glow not built")
    Same(glow.textures[1]:GetAtlas(), "UI-HUD-ActionBar-Proc-Loop-Flipbook", "other type is Proc")
    local r, g, b, a = glow.textures[1]:GetVertexColor()
    Near(r, 1, "gold r") Near(g, 0.82, "gold g") Near(b, 0, "gold b") Near(a, 1, "gold a")
    AssertPoint(glow.holder, "TOPLEFT", state.button, -2, 2, "no shift")
    AssertPoint(glow.holder, "BOTTOMRIGHT", state.button, 2, -2, "no shift")
  end

  -- Retire: instances beyond the new slot count lose their glow, the first keeps it.
  do
    local region = CreateFrame("Frame")
    local display = { unitGlow = true }
    Display.Apply(region, Data({ unit = "party", display = display }))
    local instances = region.blizzardAuraDisplay.instances
    Same(#instances, 5, "party slot count")
    Drain()
    local retired = {}
    for position = 1, 5 do
      retired[position] = instances[position].unitGlow
      assert(GlowOf(retired[position]), "glow " .. position .. " not built")
    end
    Display.Apply(region, Data({ unit = "target", display = display }))
    Same(#region.blizzardAuraDisplay.instances, 1, "slot count after the change")
    assert(GlowOf(retired[1]), "first glow lost")
    for position = 2, 5 do
      Same(GlowOf(retired[position]), nil, "glow " .. position .. " kept after retire")
      assert(not retired[position].container:IsShown(), "container " .. position .. " shown after retire")
    end
  end

  -- Restore.
  AuraUtil.IsValidFilterString = savedValidFilter
  AuraContainerSortMethod, AuraContainerSortDirection = sortMethodsBefore, sortDirectionBefore
  CreateFrame, CustomAuraContainerAuraProcessingPolicy = savedCreateFrame, savedPolicy
  C_AddOns.IsAddOnLoaded, C_StringUtil = savedIsLoaded, savedStringUtil
  if savedStringUtil then savedStringUtil.CreateNumericRuleFormatter = savedFormatter end
  WeakAuras.IsRestricted, C_Timer.After, Methods.CreateAnimation = originals.IsRestricted, originals.After, originals.CreateAnimation
  Display.RefreshShownAnimations = originals.Refresh
  Same(#timers, 0, "timers left scheduled")
end

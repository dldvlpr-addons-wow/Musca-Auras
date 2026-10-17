-- Contract of SecretAuraGlow, SecretAuraPreview and the fork guard of SubRegionTypes/Glow:
-- exports and observable widget calls only (complements scenarios 20 and 28).
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay
  local Secret = test.Secret
  local Methods = test.Frames.Methods

  local function Near(actual, expected, message)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-6,
      ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local function Same(actual, expected, message)
    assert(actual == expected, ("%s: expected %s, got %s"):format(message, tostring(expected), tostring(actual)))
  end
  local nan = 0 / 0

  -- Shared stubs, all restored at the end.
  local restricted, optionsOpen = false, false
  local originals = {
    IsRestricted = WeakAuras.IsRestricted, IsOptionsOpen = WeakAuras.IsOptionsOpen,
    After = C_Timer.After, profile = debugprofilestop, CreateAnimation = Methods.CreateAnimation,
    Refresh = Display.RefreshShownAnimations, handler = geterrorhandler(),
  }
  WeakAuras.IsRestricted = function() return restricted end
  WeakAuras.IsOptionsOpen = function() return optionsOpen end

  local timers = {}
  C_Timer.After = function(delay, callback) timers[#timers + 1] = { delay = delay, callback = callback } end
  local function Pop()
    local timer = assert(table.remove(timers, 1), "no timer scheduled")
    timer.callback()
    return timer
  end

  local refreshed = {}
  Display.RefreshShownAnimations = function(native) refreshed[native] = (refreshed[native] or 0) + 1 end
  local function RefreshTotal()
    local total = 0
    for _, count in pairs(refreshed) do total = total + count end
    return total
  end

  -- Records durations and offsets of animations (the harness keeps no state for them).
  local animations = setmetatable({}, { __mode = "k" })
  Methods.CreateAnimation = function(self, kind, name)
    local animation = originals.CreateAnimation(self, kind, name)
    local record = { kind = kind }
    animations[animation] = record
    rawset(animation, "SetDuration", function(_, value) record.duration = value end)
    rawset(animation, "SetOffset", function(_, x, y) record.x, record.y = x, y end)
    return animation
  end
  local function Animations(group, kind)
    local list = {}
    for _, animation in ipairs({ group:GetAnimations() }) do
      if animations[animation].kind == kind then list[#list + 1] = animations[animation] end
    end
    return list
  end
  local function GroupWith(glow, kind)
    for _, group in ipairs(glow.groups) do
      if #Animations(group, kind) > 0 then return group end
    end
    error("no group with " .. kind)
  end
  local function MoveTotal(glow)
    local total = 0
    for _, move in ipairs(Animations(GroupWith(glow, "Translation"), "Translation")) do total = total + (move.duration or 0) end
    return total
  end

  local function NewButton()
    local button = { added = 0 }
    function button:AddAuraShownAnimation(group) self.added = self.added + 1 end
    function button:RemoveAuraShownAnimation(group) end
    return button
  end
  local parent = CreateFrame("Frame")
  local function Style(entry, element, button, atParent, anchor, w, h)
    atParent = atParent or parent
    Display.StyleElementGlow(entry, button or NewButton(), atParent, anchor or atParent, element, w or 40, h or 40)
    return entry.nativeGlow
  end
  -- Restricted: a glow is built at once, which makes the settings observable without draining.
  local function Build(element, w, h)
    restricted = true
    local glow = Style({}, element, nil, nil, nil, w, h)
    restricted = false
    return glow
  end
  local function Dots(glow)
    local dots = {}
    for _, texture in ipairs(glow.textures) do
      if math.abs(texture:GetRotation() - math.pi / 4) < 1e-9 then dots[#dots + 1] = texture end
    end
    return dots
  end

  -- glowStale and nil tolerance.
  do
    local entry = { glowStale = true }
    Display.StyleElementGlow(entry, NewButton(), parent, parent, { glow = false }, 40, 40)
    Same(entry.glowStale, nil, "glowStale kept when the glow is off")
    entry.glowStale = true
    restricted = true
    Style(entry, { glow = true })
    Same(entry.glowStale, nil, "glowStale kept when the glow is built")
    entry.glowStale = true
    Style(entry, { glow = true })
    Same(entry.glowStale, nil, "glowStale kept when the glow is reused")
    restricted = false
    Display.ClearElementGlow(nil)
    Display.ClearElementGlow({})
    -- A button without RemoveAuraShownAnimation, or one whose removal raises, still gets its groups stopped.
    for _, mode in ipairs({ "absent", "raises" }) do
      local button = { AddAuraShownAnimation = function() end }
      if mode == "raises" then button.RemoveAuraShownAnimation = function() error("boom") end end
      local glow = Build({ glow = true })
      local owner = {}
      restricted = true
      local clearEntry = {}
      Display.StyleElementGlow(clearEntry, button, parent, parent, { glow = true }, 40, 40)
      restricted = false
      local built = clearEntry.nativeGlow
      assert(built.groups[1]:IsPlaying(), "group not playing before clear")
      Display.ClearElementGlow(clearEntry)
      assert(not built.groups[1]:IsPlaying(), "group still playing after clear (" .. mode .. ")")
    end
  end

  -- Cache key: what rebuilds and what does not.
  do
    restricted = true
    local button, entry = NewButton(), {}
    local base = { glow = true, useGlowColor = false, glowColor = { 1, 1, 1, 1 } }
    local first = Style(entry, base, button)
    Same(Style(entry, { glow = true, useGlowColor = false, glowColor = { 1, 1, 1, 1 } }, button), first, "equal settings rebuilt")
    local added = button.added
    Same(Style(entry, { glow = true, useGlowColor = false, glowColor = { 1, 1, 1, 1 }, glowStartAnim = true }, button), first, "glowStartAnim rebuilt the glow")
    Same(button.added, added, "glowStartAnim added the groups again")
    local recolored = Style(entry, { glow = true, useGlowColor = false, glowColor = { 0.5, 1, 1, 1 } }, button)
    assert(recolored ~= first, "glowColor change (useGlowColor false) did not rebuild")
    local unset = Style(entry, { glow = true, glowColor = { 0.5, 1, 1, 1 } }, button)
    assert(unset ~= recolored, "useGlowColor nil and false share a key")
    local other = CreateFrame("Frame")
    local moved = Style(entry, { glow = true, glowColor = { 0.5, 1, 1, 1 } }, button, other)
    assert(moved ~= unset and moved.holder:GetParent() == other, "parent change did not rebuild")
    local anchor = CreateFrame("Frame")
    local anchored = Style(entry, { glow = true, glowColor = { 0.5, 1, 1, 1 } }, button, other, anchor)
    assert(anchored ~= moved, "anchor change did not rebuild")
    local _, relativeTo = anchored.holder:GetPoint(1)
    Same(relativeTo, anchor, "holder not centered on the new anchor")
    local resized = Style(entry, { glow = true, glowColor = { 0.5, 1, 1, 1 } }, button, other, anchor, 41, 40)
    assert(resized ~= anchored, "width change did not rebuild")
    assert(Style(entry, { glow = true, glowColor = { 0.5, 1, 1, 1 } }, NewButton(), other, anchor, 41, 40) ~= resized, "button change did not rebuild")
    assert(Style(entry, { glow = true, glowScale = 2 }, button) ~= first, "setting change did not rebuild")
    restricted = false
  end

  -- Normalization, seen through the widget calls.
  do
    -- Proc: offsets (support size), scale (texture size), duration (flip book).
    local function HolderWidth(xOffset) return Build({ glow = true, glowXOffset = xOffset }).holder:GetWidth() end
    Same(HolderWidth(5), 50, "offset 5")
    Same(HolderWidth("12"), 64, "numeric string offset")
    Same(HolderWidth("x"), 40, "non numeric offset")
    Same(HolderWidth(nan), 40, "NaN offset")
    Same(HolderWidth(500), 440, "offset above bounds")
    Same(HolderWidth(-500), 2, "offset below bounds (support minimum 2)")
    Same(Build({ glow = true, glowYOffset = 500 }).holder:GetHeight(), 440, "Y offset above bounds")

    local function ProcWidth(scale) return (Build({ glow = true, glowScale = scale }).textures[1]:GetSize()) end
    Near(ProcWidth(nil), 56, "scale default")
    Near(ProcWidth(2), 112, "scale 2")
    Near(ProcWidth("x"), 56, "scale non numeric")
    Near(ProcWidth(nan), 56, "scale NaN")
    Near(ProcWidth(99), 224, "scale above bounds")
    Near(ProcWidth(0), 14, "scale below bounds")

    local function ProcDuration(duration)
      local glow = Build({ glow = true, glowDuration = duration })
      return Animations(glow.groups[1], "FlipBook")[1].duration
    end
    Near(ProcDuration(nil), 1, "duration default")
    Near(ProcDuration(3), 3, "duration 3")
    Near(ProcDuration("x"), 1, "duration non numeric")
    Near(ProcDuration(nan), 1, "duration NaN")
    Near(ProcDuration(99), 10, "duration above bounds")
    Near(ProcDuration(0), 0.1, "duration below bounds")

    -- Types: nil is Proc, unknown is Shine.
    local proc = Build({ glow = true })
    Same(proc.textures[1]:GetAtlas(), "UI-HUD-ActionBar-Proc-Loop-Flipbook", "nil type is Proc")
    Same(Build({ glow = true, glowType = "Proc" }).textures[1]:GetAtlas(), "UI-HUD-ActionBar-Proc-Loop-Flipbook", "Proc atlas")
    for _, kind in ipairs({ "bogus", "ACShine", "Shine" }) do
      local shine = Build({ glow = true, glowType = kind })
      assert(#shine.textures == 4 and #shine.groups == 8 and #shine.frames == 0, kind .. " is not Shine")
    end

    -- Lines, Shine (default 4) and Pixel (default 8, 4 textures per line).
    local function Lines(kind, lines) return #Build({ glow = true, glowType = kind, glowLines = lines }).textures end
    Same(Lines("Shine", 6), 6, "Shine 6 lines")
    Same(Lines("Shine", "x"), 4, "Shine non numeric lines")
    Same(Lines("Shine", nan), 4, "Shine NaN lines")
    Same(Lines("Shine", 0), 1, "Shine lines below bounds")
    Same(Lines("Shine", 100), 32, "Shine lines above bounds")
    Same(Lines("Shine", 2.9), 2, "Shine lines rounded down")
    Same(Lines("Pixel", nil), 32, "Pixel default lines")
    Same(Lines("Pixel", 2), 8, "Pixel 2 lines")
    Same(Lines("Pixel", 0), 4, "Pixel lines below bounds")
    Same(Lines("Pixel", 100), 128, "Pixel lines above bounds")
    local bordered = Build({ glow = true, glowType = "Pixel", glowLines = 2, glowBorder = true })
    Same(#bordered.textures, 12, "glowBorder adds 4 textures")
    local backgrounds = 0
    for _, texture in ipairs(bordered.textures) do
      if texture:GetDrawLayer() == "BACKGROUND" then backgrounds = backgrounds + 1 end
    end
    Same(backgrounds, 4, "glowBorder backgrounds")

    -- Pixel thickness and computed length.
    local function Thickness(value) return select(2, Build({ glow = true, glowType = "Pixel", glowThickness = value }).frames[1]:GetSize()) end
    Same(Thickness(nil), 2, "thickness default")
    Same(Thickness(5), 5, "thickness 5")
    Same(Thickness("x"), 2, "thickness non numeric")
    Same(Thickness(nan), 2, "thickness NaN")
    Same(Thickness(100), 12, "thickness above bounds")
    Same(Thickness(0), 0.5, "thickness below bounds")
    local top, bottom, left = bordered.frames[1], bordered.frames[2], bordered.frames[3]
    Same(top:GetWidth(), 40, "top edge width")
    Same(left:GetHeight(), 40, "left edge height")
    local function Side(settings)
      settings.glow, settings.glowType = true, "Pixel"
      return Dots(Build(settings))[1]:GetSize()
    end
    Near(Side({}), 12 / math.sqrt(2), "length 0 computed (8 lines)")
    Near(Side({ glowLines = 4 }), 32 / math.sqrt(2), "length 0 computed (4 lines)")
    Near(Side({ glowLength = "x", glowLines = 4 }), 32 / math.sqrt(2), "non numeric length")
    Near(Side({ glowLength = -5, glowLines = 4 }), 32 / math.sqrt(2), "length below bounds")
    Near(Side({ glowLength = 10 }), 10 / math.sqrt(2), "explicit length")
    Near(Side({ glowLength = 999 }), 40 / math.sqrt(2), "length above the support size")
    Near(Side({ glowLength = 1, glowThickness = 3 }), 3 / math.sqrt(2), "length under the thickness")

    -- Colors.
    local yellow = Dots(Build({ glow = true, glowType = "Pixel" }))[1]
    local r, g, b, a = yellow:GetVertexColor()
    assert(r == 0.95 and g == 0.95 and b == 0.32 and a == 1 and not yellow:IsDesaturated(), "Pixel fallback color")
    local tinted = Dots(Build({ glow = true, glowType = "Pixel", useGlowColor = true, glowColor = { 0.1, 0.2, 0.3, 1 } }))[1]
    r, g, b = tinted:GetVertexColor()
    assert(tinted:IsDesaturated() and r == 0.1 and g == 0.2 and b == 0.3, "Pixel glow color")
    local plain = Build({ glow = true, useGlowColor = true, glowColor = "red" }).textures[1]
    r, g, b = plain:GetVertexColor()
    assert(not plain:IsDesaturated() and r == 1 and g == 1 and b == 1, "non table glowColor")

    -- Frequency: loop duration and direction (Shine, one spark, 40 x 40 support).
    local function Loop(frequency)
      local glow = Build({ glow = true, glowType = "Shine", glowLines = 1, glowFrequency = frequency })
      local first = Animations(GroupWith(glow, "Translation"), "Translation")[1]
      local fades = Animations(GroupWith(glow, "Alpha"), "Alpha")
      Near(fades[1].duration, MoveTotal(glow) / 2, "fade duration")
      return MoveTotal(glow), first.x, first.y
    end
    local total, x, y = Loop(nil)
    Near(total, 4, "default frequency loop")
    Same(x, 40, "forward first move x") Same(y, 0, "forward first move y")
    Near((Loop(0)), 4, "zero frequency loop")
    Near((Loop(0.5)), 2, "frequency 0.5 loop")
    Near((Loop("x")), 4, "non numeric frequency loop")
    Near((Loop(nan)), 4, "NaN frequency loop")
    Near((Loop(50)), 0.1, "frequency above bounds loop")
    total, x, y = Loop(-0.5)
    Near(total, 2, "negative frequency loop")
    Same(x, 0, "reverse first move x") Same(y, 40, "reverse first move y")

    local function Ants(frequency)
      local glow = Build({ glow = true, glowType = "buttonOverlay", glowFrequency = frequency })
      Same(#glow.textures, 2, "buttonOverlay textures")
      return Animations(glow.groups[1], "FlipBook")[1].duration
    end
    Near(Ants(nil), 0.22, "ants default")
    Near(Ants(0), 5.5, "ants zero frequency")
    Near(Ants(-0.5), 0.11, "ants negative frequency")
    Near(Ants(50), 0.0055, "ants frequency above bounds")

    -- Halo of the action button alert: 1.4 times the icon, ants 1.2 times; pulse follows the scale.
    local overlay = Build({ glow = true, glowType = "buttonOverlay" })
    Near((overlay.textures[1]:GetSize()), 56, "buttonOverlay halo size")
    Near((overlay.textures[2]:GetSize()), 48, "buttonOverlay ants size")
    Near((Build({ glow = true, glowType = "pulse" }).textures[1]:GetSize()), 56, "pulse halo size")
    Near((Build({ glow = true, glowType = "pulse", glowScale = 2 }).textures[1]:GetSize()), 112, "pulse halo scale 2")
  end

  -- Deferred construction.
  do
    local function Pending(native, element)
      local entry = { native = native }
      Display.StyleElementGlow(entry, NewButton(), parent, parent, element or { glow = true }, 40, 40)
      return entry
    end
    local native1, native2 = {}, {}

    -- One drain for all requests, one refresh per native.
    local entries = { Pending(native1), Pending(native1), Pending(native2) }
    for _, entry in ipairs(entries) do Same(entry.nativeGlow, nil, "live button glow built at once") end
    Same(#timers, 1, "one drain scheduled") Same(timers[1].delay, 0, "drain delay")
    Pop()
    for _, entry in ipairs(entries) do assert(entry.nativeGlow, "request not built") end
    Same(refreshed[native1], 1, "refresh of the first native") Same(refreshed[native2], 1, "refresh of the second native")
    Same(#timers, 0, "drain rescheduled with nothing left")

    -- The last request of an entry wins.
    refreshed = {}
    local entry = Pending(native1, { glow = true, glowXOffset = 0 })
    Display.StyleElementGlow(entry, NewButton(), parent, parent, { glow = true, glowXOffset = 7 }, 40, 40)
    Same(#timers, 1, "second request scheduled another drain")
    Pop()
    Same(entry.nativeGlow.holder:GetWidth(), 54, "last request not used")
    Same(refreshed[native1], 1, "refresh after replaced request")

    -- Restriction at drain time: nothing built, retry in 1 s until it ends.
    refreshed = {}
    entry = Pending(native1)
    restricted = true
    Same(Pop().delay, 0, "first drain delay")
    Same(entry.nativeGlow, nil, "built under restriction")
    Same(#timers, 1, "no retry scheduled") Same(timers[1].delay, 1, "retry delay")
    Pop()
    Same(entry.nativeGlow, nil, "built under restriction (retry)") Same(timers[1].delay, 1, "second retry delay")
    Same(RefreshTotal(), 0, "refresh under restriction")
    restricted = false
    Pop()
    assert(entry.nativeGlow, "not built once the restriction ended")
    Same(RefreshTotal(), 1, "refresh after restriction")
    Same(#timers, 0, "drain left scheduled")

    -- Budget: one build per drain when the clock jumps, the rest at the next drain.
    refreshed = {}
    local ticks = 0
    debugprofilestop = function() ticks = ticks + 1 return ticks * 10 end
    entries = { Pending(native1), Pending(native1), Pending(native2) }
    local function BuiltCount()
      local count = 0
      for _, each in ipairs(entries) do if each.nativeGlow then count = count + 1 end end
      return count
    end
    for expected = 1, 3 do
      local timer = Pop()
      Same(BuiltCount(), expected, "built after drain " .. expected)
      Same(#timers, expected < 3 and 1 or 0, "drains left after drain " .. expected)
      if expected < 3 then Same(timers[1].delay, 0, "next drain delay") end
      ticks = 0
    end
    Same(RefreshTotal(), 3, "refresh per drain")
    debugprofilestop = originals.profile

    -- A failing construction goes to the error handler and does not stop the others.
    refreshed = {}
    local errors = {}
    seterrorhandler(function(message) errors[#errors + 1] = message end)
    local bad = { native = native2 }
    Display.StyleElementGlow(bad, {}, parent, parent, { glow = true }, 40, 40)
    local good1, good2 = Pending(native1), Pending(native1)
    Pop()
    Same(#errors, 1, "construction error not reported once")
    assert(good1.nativeGlow and good2.nativeGlow, "entries after a failure not built")
    Same(refreshed[native1], 1, "refresh after a failure")
    Same(#timers, 0, "failure rescheduled a drain")
    seterrorhandler(originals.handler)
  end

  -- Immediate construction.
  do
    local entry = {}
    pcall(Display.StyleElementGlow, entry, nil, parent, parent, { glow = true }, 40, 40)
    assert(entry.nativeGlow and #entry.nativeGlow.textures == 1, "nil button: glow not built at once")
    Same(#timers, 0, "nil button queued")

    local sample = Display.CreateSampleNative(parent)
    optionsOpen = false
    entry = {}
    Display.StyleElementGlow(entry, sample.button, parent, parent, { glow = true }, 40, 40)
    assert(entry.nativeGlow and entry.nativeGlow.groups[1]:IsPlaying(), "sample with options closed not built and played at once")
    Same(#timers, 0, "sample queued with options closed")

    optionsOpen = true
    entry = {}
    Display.StyleElementGlow(entry, sample.button, parent, parent, { glow = true }, 40, 40)
    Same(entry.nativeGlow, nil, "sample with options open built at once")
    Pop()
    assert(entry.nativeGlow, "sample with options open never built")
    optionsOpen = false

    restricted = true
    entry = {}
    Style(entry, { glow = true })
    assert(entry.nativeGlow, "restricted: not built at once")
    Same(#timers, 0, "restricted: queued")
    restricted = false

    -- A kept glow of other settings means no queue: restyle builds at once.
    entry = { native = {} }
    Style(entry, { glow = true }) Pop()
    Style(entry, { glow = true, glowXOffset = 3 })
    assert(entry.nativeGlow and entry.nativeGlow.holder:GetWidth() == 46, "restyle with a kept glow not built at once")
    Same(#timers, 0, "restyle with a kept glow queued")
  end

  -- Fork guard of the classic glow (SubRegionTypes/Glow.lua).
  do
    local subRegion = private.subRegionTypes.subglow
    local anchored = CreateFrame("Frame")
    rawset(anchored, "AnchorSubRegion", function() end)
    local region = CreateFrame("Frame", nil, parent)
    local created = subRegion.acquire()
    for _, candidate in ipairs({ created }) do region = candidate end
    local starts, stops = 0, 0
    local function Prepare(glowType)
      subRegion.modify(anchored, region, { regionType = "icon" },
        { glow = false, glowType = glowType, glowFrequency = 0.25, glowLines = 8, glowLength = 10, glowThickness = 1,
          glowScale = 1, glowXOffset = 0, glowYOffset = 0, glowDuration = 1 })
      starts, stops = 0, 0
      region.glowStart = function() starts = starts + 1 end
      region.glowStop = function() stops = stops + 1 end
    end
    local function Size(width, height)
      rawset(region, "GetWidth", function() return width end)
      rawset(region, "GetHeight", function() return height end)
    end
    local violations = #Secret.violations
    for _, glowType in ipairs({ "buttonOverlay", "Pixel", "ACShine", "Proc" }) do
      Prepare(glowType)
      for name, size in pairs({
        ["secret width"] = { Secret.Wrap(30), 30 }, ["secret height"] = { 30, Secret.Wrap(30) },
        ["both secret"] = { Secret.Wrap(30), Secret.Wrap(30) }, ["width < 1"] = { 0.5, 30 }, ["height < 1"] = { 30, 0 },
        ["zero size"] = { 0, 0 },
      }) do
        starts, stops = 0, 0
        Size(size[1], size[2])
        region:SetVisible(true)
        assert(starts == 0 and stops == 1, ("%s %s: starts %d stops %d"):format(glowType, name, starts, stops))
      end
      starts, stops = 0, 0
      Size(30, 20)
      region:SetVisible(true)
      assert(starts == 1 and stops == 0, ("%s readable size: starts %d stops %d"):format(glowType, starts, stops))
      Size(1, 1)
      starts, stops = 0, 0
      region:SetVisible(true)
      assert(starts == 1 and stops == 0, glowType .. " size 1 must start")
    end
    -- A setter on a visible glow goes through the same guard; no retry afterwards.
    Prepare("buttonOverlay")
    Size(30, 20)
    region:SetVisible(true)
    starts, stops = 0, 0
    Size(Secret.Wrap(30), 20)
    region:SetGlowFrequency(1)
    assert(starts == 0 and stops == 1, "setter on a secret size started the glow")
    test.Environment.Advance(2)
    assert(starts == 0, "glow restarted on its own")
    Size(30, 20)
    region:SetGlowFrequency(2)
    assert(starts == 1, "glow not restarted by the next setting change")
    Same(#Secret.violations, violations, "secret value compared")
    region.glow = false
  end

  -- Preview.
  local function Data(settings, trigger, extra)
    trigger = trigger or {}
    trigger.type, trigger.unit, trigger.debuffType = "secretAura", "player", "HELPFUL"
    local data = { id = "PreviewContract", regionType = "icon", width = 30, height = 20,
      triggers = { { trigger = trigger } }, blizzardAuraDisplay = settings }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local function Style() end
  local spells = { auraspellids = { 6673, 1459, 21562 } }
  Same(Display.PREVIEW_SAMPLE_DURATION, 6, "sample duration")

  -- CreateSampleNative fields.
  do
    local host = CreateFrame("Frame")
    local native = Display.CreateSampleNative(host)
    local button = native.button
    assert(native.preview == true, "preview flag")
    Same(button:GetParent(), host, "button parent")
    assert(not button:IsMouseEnabled(), "mouse enabled")
    assert(next(button.bindings) == nil, "bindings not empty")
    Same(button:GetNumPoints(), 0, "button anchored") Same(button:GetWidth(), 0, "button sized")
    Same(button:GetScript("OnUpdate"), nil, "sample native with an OnUpdate")
    for _, name in ipairs({ "inner", "outer" }) do
      Same(native[name]:GetParent(), button, name .. " parent")
      local point, relativeTo, relativePoint = native[name]:GetPoint(1)
      assert(point == "CENTER" and relativeTo == button and relativePoint == "CENTER", name .. " anchor")
      Same(native[name]:GetNumPoints(), 1, name .. " points")
    end
    local function AllPoints(object, target, label)
      Same(object:GetNumPoints(), 2, label .. " points")
      local point, relativeTo = object:GetPoint(1)
      assert(point == "TOPLEFT" and relativeTo == target, label .. " first anchor")
      point, relativeTo = object:GetPoint(2)
      assert(point == "BOTTOMRIGHT" and relativeTo == target, label .. " second anchor")
    end
    Same(native.border:GetParent(), button, "border parent")
    Same((native.border:GetDrawLayer()), "BACKGROUND", "border layer")
    AllPoints(native.border, button, "border")
    local count = 0
    for _ in pairs(native.elementFrames) do count = count + 1 end
    Same(count, 1, "elementFrames keys")
    local base = native.elementFrames.sharedBase
    Same(base:GetParent(), button, "sharedBase parent")
    AllPoints(base, button, "sharedBase")
    Same(native.icon:GetParent(), base, "icon parent")
    Same((native.icon:GetDrawLayer()), "ARTWORK", "icon layer")
    Same(native.icon:GetNumPoints(), 0, "icon anchored")
    Same(native.cooldown:GetObjectType(), "Cooldown", "cooldown type")
    Same(native.cooldown:GetParent(), base, "cooldown parent")
    AllPoints(native.cooldown, native.icon, "cooldown")
    Same(native.overlay:GetParent(), button, "overlay parent")
    AllPoints(native.overlay, button, "overlay")
  end

  -- AddDispelTypeTexture and AddAuraShownAnimation.
  do
    local button = Display.CreateSampleNative(CreateFrame("Frame")).button
    local styles = Enum.CustomAuraButtonDispelTypeTextureStyle
    local calls = {}
    local saved = {}
    AuraUtil = AuraUtil or {}
    for _, name in ipairs({ "SetAuraBorderColor", "SetAuraBorderAtlas", "SetAuraDispelTypeIcon" }) do
      saved[name] = AuraUtil[name]
      AuraUtil[name] = function(texture, ...) calls[#calls + 1] = { name, texture, ... } end
    end
    local function Apply(style)
      local texture = button:CreateTexture()
      texture:Hide()
      texture:SetVertexColor(0.3, 0.3, 0.3, 0.3)
      calls = {}
      button:AddDispelTypeTexture(texture, { style = style })
      return texture
    end
    local texture = Apply(styles.PreserveAsset)
    assert(#calls == 1 and calls[1][1] == "SetAuraBorderColor" and calls[1][2] == texture and calls[1][3] == "Magic", "PreserveAsset call")
    local r, _, _, a = texture:GetVertexColor()
    assert(texture:IsShown() and r == 0.3 and a == 0.3, "PreserveAsset touched the vertex color or left the texture hidden")
    texture = Apply(styles.Border)
    assert(#calls == 1 and calls[1][1] == "SetAuraBorderAtlas" and calls[1][3] == "Magic" and calls[1][4] == false, "Border call")
    r, _, _, a = texture:GetVertexColor()
    assert(texture:IsShown() and r == 1 and a == 1, "Border vertex color or visibility")
    for _, style in ipairs({ "other", 12345 }) do
      texture = Apply(style)
      assert(#calls == 1 and calls[1][1] == "SetAuraDispelTypeIcon" and calls[1][3] == "Magic", "icon style call")
      r, _, _, a = texture:GetVertexColor()
      assert(texture:IsShown() and r == 1 and a == 1, "icon style vertex color or visibility")
    end
    for name, original in pairs(saved) do AuraUtil[name] = original end

    local group = button:CreateAnimationGroup()
    button:AddAuraShownAnimation(group)
    assert(group:IsPlaying(), "shown animation not played at once")
    button:RemoveAuraShownAnimation(group)
    assert(not group:IsPlaying(), "removed animation still playing")
  end

  -- FillSampleBindings: unknown kinds, inverse bar.
  do
    local button = Display.CreateSampleNative(CreateFrame("Frame")).button
    local bar = CreateFrame("StatusBar", nil, button)
    button:SetDurationBar(bar, {})
    button.bindings.Mystery = { { widget = {}, options = {} } }
    Display.FillSampleBindings(button, 1, "n", { inverse = true }, true)
    Same(bar:GetValue(), 0, "inverse timed bar")
    Display.FillSampleBindings(button, 1, "n", { inverse = true }, false)
    Same(bar:GetValue(), 0, "inverse untimed bar")
    Display.FillSampleBindings(button, 1, "n", {}, true)
    Same(bar:GetValue(), 6, "timed bar")
  end

  -- StopSampleAnimations.
  do
    local sample = Display.CreateSampleNative(CreateFrame("Frame"))
    restricted = true
    local sharedA, sharedB = {}, {}
    Display.StyleElementGlow(sharedA, sample.button, parent, parent, { glow = true }, 40, 40)
    restricted = false
    assert(sharedA.nativeGlow, "glow not built")
    local pulse = sample.button:CreateAnimationGroup()
    pulse:Play()
    local idle = sample.button:CreateAnimationGroup()
    idle:Play()
    sample.sharedElements = { sharedA, sharedB }
    sample.conditionHosts = { { pulse = pulse }, {}, { other = idle } }
    Display.StopSampleAnimations(sample)
    assert(sharedA.nativeGlow == nil and sharedA.keptGlow, "shared glow not cleared")
    assert(not pulse:IsPlaying(), "host pulse not stopped")
    assert(idle:IsPlaying(), "a group outside pulse was stopped")
    Display.StopSampleAnimations({})
    Display.StopSampleAnimations({ sharedElements = {}, conditionHosts = {} })
  end

  -- ShowPreview: order, flow units, fields.
  local flowUnits, flush = Display.FlowPreviewUnits, Display.FlushInstanceQueue
  local restore, hide = Display.RestorePreviewRegion, Display.HidePreview
  do
    local region = CreateFrame("Frame")
    local data = Data({ growth = "RIGHT", spacing = 4 }, spells)
    Display.ShowPreview(region, data, Style)

    -- Order: restore, then hide (old samples still shown at restore time), then active.
    local log = {}
    Display.RestorePreviewRegion = function(restoredRegion)
      log[#log + 1] = "restore"
      assert(restoredRegion == region and region.secretAuraSamples[1].button:IsShown(), "restore after the hide")
      return restore(restoredRegion)
    end
    Display.HidePreview = function(hidden)
      log[#log + 1] = "hide"
      assert(hidden == region, "hide on another region")
      return hide(hidden)
    end
    Display.ShowPreview(region, data, function(sample)
      log[#log + 1] = "style"
      assert(region.secretAuraSamplesActive == true, "active flag after the hide")
      assert(not sample.button:IsShown(), "reused sample shown before the end")
    end)
    Display.RestorePreviewRegion, Display.HidePreview = restore, hide
    Same(table.concat(log, ","), "restore,hide,style,style,style", "ShowPreview order")
    for slot = 1, 3 do assert(region.secretAuraSamples[slot].button:IsShown(), "sample " .. slot .. " not shown last") end

    -- Without FlowPreviewUnits: one unit, previewUnit false.
    Display.FlowPreviewUnits, Display.FlushInstanceQueue = nil, nil
    local fresh = CreateFrame("Frame")
    Display.ShowPreview(fresh, data, Style)
    Same(#fresh.secretAuraSamples, 3, "samples without flow units")
    for slot = 1, 3 do Same(fresh.secretAuraSamples[slot].previewUnit, false, "previewUnit without flow") end
    optionsOpen = false
    fresh.secretAuraSamples[1].button:GetScript("OnUpdate")(fresh.secretAuraSamples[1].button, 0.1)
    assert(fresh.secretAuraSamplesActive == false and not fresh.secretAuraSamples[1].button:IsShown(), "no hide without FlushInstanceQueue")
    optionsOpen = true

    -- Several flow units: every unit repeats the same positions.
    Display.FlowPreviewUnits = function() return { "alpha", "beta" } end
    local flowRegion = CreateFrame("Frame")
    Display.ShowPreview(flowRegion, data, Style)
    Same(#flowRegion.secretAuraSamples, 6, "flow slots")
    local expectedUnits = { "alpha", "alpha", "alpha", "beta", "beta", "beta" }
    for slot = 1, 6 do
      local sample = flowRegion.secretAuraSamples[slot]
      Same(sample.previewUnit, expectedUnits[slot], "previewUnit " .. slot)
      local point, relativeTo, _, x, y = sample.button:GetPoint(1)
      assert(point == "TOPLEFT" and relativeTo == flowRegion and x == ((slot - 1) % 3) * 34 and y == 0, "flow slot " .. slot .. " position")
      assert(sample.button:IsShown(), "flow slot " .. slot .. " hidden")
    end
    Display.FlowPreviewUnits = flowUnits
    local limited = Data({ growth = "RIGHT", maxIcons = 2 }, spells)
    Display.FlowPreviewUnits = function() return { "alpha", "beta", "gamma" } end
    Display.ShowPreview(flowRegion, limited, Style)
    Same(#flowRegion.secretAuraSamples, 6, "slots kept")
    for slot = 1, 6 do
      Same(flowRegion.secretAuraSamples[slot].button:IsShown(), true, "limited flow slot " .. slot)
    end
    Display.FlowPreviewUnits, Display.FlushInstanceQueue = flowUnits, flush
  end

  -- ShowPreview: per sample fields, missing mode fill.
  do
    local region = CreateFrame("Frame")
    local ticks = {}
    local function Bind(sample)
      local icon, text = sample.button:CreateTexture(), sample.button:CreateFontString()
      sample.button:SetIcon(icon, {})
      sample.button:SetDurationText(text, {})
      return icon, text
    end
    local data = Data({ growth = "RIGHT" }, spells, { inverse = true })
    local icons, texts = {}, {}
    Display.ShowPreview(region, data, function(sample) icons[sample], texts[sample] = Bind(sample) end)
    local sample = region.secretAuraSamples[1]
    Near(sample.button.expires, GetTime() + 6, "expires")
    Same(sample.button.inverse, true, "inverse flag")
    Same(icons[sample]:GetTexture(), sample.iconID, "icon fill") Same(texts[sample]:GetText(), "6", "timed fill")
    Display.ShowPreview(region, Data({ growth = "RIGHT" }, spells, { inverse = 1 }), Style)
    Same(sample.button.inverse, false, "inverse is strict")

    local missing = Data({ growth = "RIGHT" }, { auraspellids = { 6673, 1459 }, secretShowOn = "showOnMissing", unit = "player" })
    missing.displayIcon, missing.iconSource = 136000, 0
    local styledMissing, shownAtStyle = {}, nil
    local original = Display.StyleMissingIcon
    Display.StyleMissingIcon = function(styledSample, styledData)
      styledMissing[#styledMissing + 1] = styledSample
      shownAtStyle = { icons[styledSample]:GetTexture(), texts[styledSample]:GetText(), styledSample.button:IsShown(), styledData == missing }
      return original(styledSample, styledData)
    end
    local missingRegion = CreateFrame("Frame")
    Display.ShowPreview(missingRegion, missing, function(styledSample) icons[styledSample], texts[styledSample] = Bind(styledSample) end)
    Display.ShowPreview(missingRegion, missing, function(styledSample) icons[styledSample], texts[styledSample] = Bind(styledSample) end)
    Display.StyleMissingIcon = original
    Same(#styledMissing, 2, "StyleMissingIcon calls (one per preview)")
    Same(shownAtStyle[1], Display.SingleIcon(missing), "missing icon filled before StyleMissingIcon")
    Same(shownAtStyle[2], "", "missing sample has no duration text")
    Same(shownAtStyle[3], false, "missing sample shown before the end")
    Same(shownAtStyle[4], true, "StyleMissingIcon data")
    assert(missingRegion.secretAuraSamples[1].button:IsShown(), "missing sample hidden")
  end

  -- Tick: condition preview, cooldown restart, close order.
  do
    local region = CreateFrame("Frame")
    local cooldown
    Display.ShowPreview(region, Data({ growth = "RIGHT" }, spells), function(sample)
      cooldown = cooldown or CreateFrame("Cooldown", nil, sample.button, "CooldownFrameTemplate")
      if not sample.bound then sample.button:SetDurationCooldown(cooldown, {}) sample.bound = true end
    end)
    local sample = region.secretAuraSamples[1]
    local button = sample.button
    local updates = {}
    local original = Display.UpdateConditionPreview
    Display.UpdateConditionPreview = function(native, conditionData, remaining) updates[#updates + 1] = { native, conditionData, remaining } end
    optionsOpen = true
    button.elapsed, button.expires = 1, GetTime() + 5
    button:GetScript("OnUpdate")(button, 0.1)
    Same(#updates, 0, "UpdateConditionPreview without conditionData")
    local conditionData = {}
    sample.conditionData = conditionData
    button.elapsed, button.expires = 0, GetTime() + 5
    button:GetScript("OnUpdate")(button, 0.01)
    Same(#updates, 0, "UpdateConditionPreview during the throttle")
    button:GetScript("OnUpdate")(button, 0.1)
    Same(#updates, 1, "UpdateConditionPreview calls")
    assert(updates[1][1] == sample and updates[1][2] == conditionData, "UpdateConditionPreview arguments")
    Near(updates[1][3], 5, "UpdateConditionPreview remaining")
    button.elapsed, button.expires = 1, GetTime() - 2
    button:GetScript("OnUpdate")(button, 0.1)
    Near(updates[2][3], 6, "remaining after the restart")
    local start, duration = cooldown:GetCooldownTimes()
    Near(start, GetTime() * 1000, "cooldown restart start") Near(duration, 6000, "cooldown restart duration")
    button.staticSample = true
    button.elapsed = 1
    button:GetScript("OnUpdate")(button, 0.1)
    Same(#updates, 2, "static sample updated the condition preview")
    button.staticSample = false
    Display.UpdateConditionPreview = original

    -- Closing: hidden before the queue is flushed, once.
    local flushes, shownAtFlush = 0, nil
    Display.FlushInstanceQueue = function(flushed)
      flushes = flushes + 1
      shownAtFlush = {}
      for slot, each in ipairs(region.secretAuraSamples) do shownAtFlush[slot] = each.button:IsShown() end
      assert(flushed == region, "flush on another region")
    end
    optionsOpen = false
    button:GetScript("OnUpdate")(button, 0.1)
    Same(flushes, 1, "flushes on close")
    for slot, wasShown in ipairs(shownAtFlush) do assert(not wasShown, "sample " .. slot .. " still shown at flush time") end
    Display.FlushInstanceQueue = flush
    optionsOpen = true
  end

  -- Restore.
  WeakAuras.IsRestricted, WeakAuras.IsOptionsOpen = originals.IsRestricted, originals.IsOptionsOpen
  C_Timer.After, debugprofilestop, Methods.CreateAnimation = originals.After, originals.profile, originals.CreateAnimation
  Display.RefreshShownAnimations = originals.Refresh
  Same(#timers, 0, "timers left scheduled")
end

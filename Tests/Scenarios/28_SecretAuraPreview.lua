-- SecretAuraPreview: sample buttons per spell, layout by growth, bindings filled and ticking, hide on close, missing mode.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local optionsOpen = true
  local originalIsOptionsOpen = WeakAuras.IsOptionsOpen
  WeakAuras.IsOptionsOpen = function() return optionsOpen end

  local function Data(settings, trigger)
    trigger = trigger or {}
    trigger.type, trigger.unit, trigger.debuffType = "secretAura", "player", "HELPFUL"
    return {
      id = "PreviewAura", regionType = "icon", width = 30, height = 20,
      triggers = { { trigger = trigger } },
      blizzardAuraDisplay = settings,
    }
  end

  local styled = {}
  local function StyleSample(sample, data) styled[#styled + 1] = sample end

  local function Sample(region, slot) return region.secretAuraSamples[slot] end

  local function Bind(sample, kind)
    local widget
    if kind == "Cooldown" then widget = CreateFrame("Cooldown", nil, sample.button, "CooldownFrameTemplate")
    elseif kind == "Bar" then widget = CreateFrame("StatusBar", nil, sample.button)
    elseif kind == "Texture" then widget = sample.button:CreateTexture()
    else widget = sample.button:CreateFontString() end
    return widget
  end

  local originalGetSpellInfo = C_Spell.GetSpellInfo
  C_Spell.GetSpellInfo = function(spellID)
    if spellID == 6673 then return { name = "Battle Shout", iconID = 132333 } end
    return originalGetSpellInfo(spellID)
  end

  local region = CreateFrame("Frame")
  local data = Data({ growth = "RIGHT", spacing = 4, maxIcons = 10 }, { auraspellids = { 6673, 1459, 21562 } })

  Display.ShowPreview(region, data, StyleSample)
  assert(region.secretAuraSamplesActive == true, "preview not flagged active")
  assert(#region.secretAuraSamples == 3 and #styled == 3, ("%d samples, %d styled"):format(#region.secretAuraSamples, #styled))
  assert(Sample(region, 1).name == "Battle Shout" and Sample(region, 1).iconID == 132333, "spell name or icon not used")
  for slot = 1, 3 do
    local sample = Sample(region, slot)
    assert(sample.button:IsShown(), "sample " .. slot .. " hidden")
    assert(sample.name and sample.name ~= "" and sample.iconID, "sample " .. slot .. " without name or icon")
    assert(styled[slot] == sample, "sample " .. slot .. " not styled")
    assert(sample.button.staticSample == false, "sample " .. slot .. " static outside missing mode")
    local point, relativeTo, _, x, y = sample.button:GetPoint(1)
    assert(point == "TOPLEFT" and relativeTo == region, "sample " .. slot .. " anchor " .. tostring(point))
    assert(x == (slot - 1) * 34 and y == 0, ("sample %d offset %s,%s"):format(slot, tostring(x), tostring(y)))
  end

  local firstSample = Sample(region, 1)
  Display.ShowPreview(region, data, StyleSample)
  assert(#region.secretAuraSamples == 3 and Sample(region, 1) == firstSample, "samples not reused on a second preview")

  local shorter = Data({ growth = "RIGHT", maxIcons = 2 }, { auraspellids = { 6673, 1459, 21562 } })
  Display.ShowPreview(region, shorter, StyleSample)
  assert(Sample(region, 1).button:IsShown() and Sample(region, 2).button:IsShown(), "limited samples hidden")
  assert(not Sample(region, 3).button:IsShown(), "sample beyond the limit shown")
  local _, _, _, x = Sample(region, 2).button:GetPoint(1)
  assert(x == 36, "default spacing 6 not used: " .. tostring(x))

  for growth, expected in pairs({
    LEFT = { "TOPRIGHT", -34, 0 },
    UP = { "BOTTOMLEFT", 0, 24 },
    DOWN = { "TOPLEFT", 0, -24 },
    CENTER_HORIZONTAL = { "CENTER", 17, 0 },
    CENTER_VERTICAL = { "CENTER", 0, -12 },
  }) do
    local grown = Data({ growth = growth, spacing = 4 }, { auraspellids = { 6673, 1459 } })
    Display.ShowPreview(region, grown, StyleSample)
    local point, _, _, offsetX, offsetY = Sample(region, 2).button:GetPoint(1)
    assert(point == expected[1] and offsetX == expected[2] and offsetY == expected[3],
      ("%s: second sample %s %s,%s"):format(growth, tostring(point), tostring(offsetX), tostring(offsetY)))
  end

  local empty = Data({ growth = "RIGHT" }, {})
  Display.ShowPreview(region, empty, StyleSample)
  assert(Sample(region, 1).name == "Aura" and Sample(region, 1).iconID == 134400, "fallback sample name or icon")

  Display.ShowPreview(region, data, StyleSample)
  local sample = Sample(region, 1)
  local button = sample.button
  local duration, bar, cooldown, name, count, icon = Bind(sample, "Text"), Bind(sample, "Bar"), Bind(sample, "Cooldown"), Bind(sample, "Text"), Bind(sample, "Text"), Bind(sample, "Texture")
  button:SetDurationText(duration, {})
  button:SetDurationBar(bar, {})
  button:SetDurationCooldown(cooldown, {})
  button:SetSpellName(name, {})
  button:SetApplicationCount(count, {})
  button:SetIcon(icon, {})
  button:ClearIcon()
  assert(#button.bindings.Icon == 0, "Clear did not empty the bindings")
  button:SetIcon(icon, {})
  Display.FillSampleBindings(button, 134400, "Shout", data, true)
  assert(name:GetText() == "Shout" and duration:GetText() == "6" and count:GetText() == "3", "timed fill texts")
  assert(icon:GetTexture() == 134400, "icon fill")
  local low, high = bar:GetMinMaxValues()
  assert(low == 0 and high == Display.PREVIEW_SAMPLE_DURATION and bar:GetValue() == high, "timed bar fill")
  assert(cooldown:IsShown(), "timed cooldown hidden")

  Display.FillSampleBindings(button, 134400, "Shout", data, false)
  assert(duration:GetText() == "" and count:GetText() == "" and bar:GetValue() == 0, "untimed fill not empty")
  assert(not cooldown:IsShown(), "untimed cooldown shown")

  button.expires = GetTime() + 5
  button.elapsed = 1
  button.inverse = false
  button:GetScript("OnUpdate")(button, 0.1)
  assert(duration:GetText() == "5", "tick label above 3s: " .. tostring(duration:GetText()))
  assert(bar:GetValue() == 5, "tick bar value " .. tostring(bar:GetValue()))
  button.expires = GetTime() + 2
  button.inverse = true
  button.elapsed = 1
  button:GetScript("OnUpdate")(button, 0.1)
  assert(duration:GetText() == "2.0", "tick label under 3s: " .. tostring(duration:GetText()))
  assert(bar:GetValue() == Display.PREVIEW_SAMPLE_DURATION - 2, "inverse bar value " .. tostring(bar:GetValue()))
  duration:SetText("keep")
  button.elapsed = 0
  button:GetScript("OnUpdate")(button, 0.01)
  assert(duration:GetText() == "keep", "tick under 0.05s not throttled")

  button.expires = GetTime() - 1
  button.elapsed = 1
  button:GetScript("OnUpdate")(button, 0.1)
  assert(button.expires > GetTime() + Display.PREVIEW_SAMPLE_DURATION - 1, "expired sample not restarted")

  button.staticSample = true
  button.expires = GetTime() - 1
  button.elapsed = 1
  button:GetScript("OnUpdate")(button, 0.1)
  assert(button.expires < GetTime(), "static sample ticked")
  button.staticSample = false

  local stopped = 0
  local plainStop = Display.StopSampleAnimations
  Display.StopSampleAnimations = function(stoppedSample)
    stopped = stopped + 1
    return plainStop(stoppedSample)
  end
  Display.HidePreview(region)
  assert(region.secretAuraSamplesActive == false, "preview still flagged active")
  assert(stopped == #region.secretAuraSamples, "animations not stopped on every sample: " .. stopped)
  for slot, hidden in ipairs(region.secretAuraSamples) do
    assert(not hidden.button:IsShown(), "sample " .. slot .. " shown after hide")
  end
  Display.StopSampleAnimations = plainStop
  Display.HidePreview(CreateFrame("Frame"))

  Display.ShowPreview(region, data, StyleSample)
  assert(Sample(region, 1).button:IsShown(), "preview not shown again")
  local flushed
  local originalFlush = Display.FlushInstanceQueue
  Display.FlushInstanceQueue = function(flushedRegion) flushed = flushedRegion end
  optionsOpen = false
  Sample(region, 1).button:GetScript("OnUpdate")(Sample(region, 1).button, 0.1)
  assert(region.secretAuraSamplesActive == false and not Sample(region, 1).button:IsShown(), "preview kept after options closed")
  assert(flushed == region, "instance queue not flushed when options closed")
  Display.FlushInstanceQueue = originalFlush
  optionsOpen = true

  local missing = Data({ growth = "RIGHT" }, { auraspellids = { 6673, 1459 }, secretShowOn = "showOnMissing", unit = "player" })
  missing.displayIcon, missing.iconSource = 136000, 0
  assert(Display.PreviewShowsMissing(missing) == true, "showOnMissing not detected")
  styled = {}
  Display.ShowPreview(region, missing, StyleSample)
  assert(#styled == 1, "missing preview samples: " .. #styled)
  assert(Sample(region, 1).button.staticSample == true, "missing sample not static")
  assert(not Sample(region, 2).button:IsShown(), "extra sample shown in missing mode")

  WeakAuras.IsOptionsOpen = originalIsOptionsOpen
  C_Spell.GetSpellInfo = originalGetSpellInfo
end

-- Hide GCD Text applies to a %p text like to the countdown numbers:
-- empty while only the GCD runs, bound to the cooldown without the GCD otherwise.
return function(test)
  local bound
  local binding = {
    SetFontString = function(_, _) end, SetFormatter = function(_, _) end,
    SetDuration = function(_, duration) bound = duration end, SetEnabled = function(_, _) end,
  }
  _G.C_DurationUtil = _G.C_DurationUtil or {}
  _G.C_DurationUtil.CreateDurationTextBinding = function() return binding end
  _G.C_StringUtil = _G.C_StringUtil or {}
  _G.C_StringUtil.CreateNumericRuleFormatter = _G.C_StringUtil.CreateNumericRuleFormatter
    or function() return { SetBreakpoints = function() end } end
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local withGCD, withoutGCD = { name = "withGCD" }, { name = "withoutGCD" }
  local function Show(state)
    local shown
    local holder = { text = { SetText = function(_, value) shown = value end } }
    bound = nil
    local parent = { state = state, durationObject = withGCD }
    assert(private.UpdateNativeText(holder, parent, "%p", nil), "%p not painted natively")
    return shown, bound
  end
  local function Eq(got, want, message) assert(got == want, message .. ": " .. tostring(type(got) == "table" and got.name or got)) end

  local shown, duration = Show({ cdmHideGCDText = true, cdmGCDOnly = true, cdmTextDurationObject = withoutGCD })
  Eq(shown, "", "GCD only: empty text")
  Eq(duration, nil, "GCD only: nothing bound")
  _, duration = Show({ cdmHideGCDText = true, cdmGCDOnly = false, cdmTextDurationObject = withoutGCD })
  Eq(duration, withoutGCD, "hide GCD text: cooldown without GCD")
  _, duration = Show({ cdmHideGCDText = true, cdmTextDurationRequired = true })
  Eq(duration, nil, "required object missing: nothing bound")
  _, duration = Show({ cdmHideGCDText = true, cdmGCDOnly = false })
  Eq(duration, withGCD, "no GCD-free object: region duration")
  _, duration = Show({ cdmGCDOnly = true, cdmTextDurationObject = withoutGCD })
  Eq(duration, withGCD, "option off: GCD shown")
  _, duration = Show({ cdmHideGCDText = true, cdmTextPreview = true, cdmTextDurationObject = withoutGCD })
  Eq(duration, withGCD, "preview: region duration")

  -- Two triggers: the progress source, not the active trigger, decides.
  local function ShowSplit(active, progress)
    local painted
    local holder = { text = { SetText = function(_, value) painted = value end } }
    bound = nil
    local parent = { state = active, cdmProgressState = progress, durationObject = withGCD }
    assert(private.UpdateNativeText(holder, parent, "%p", nil), "%p not painted natively")
    return painted, bound
  end
  shown = ShowSplit({}, { cdmHideGCDText = true, cdmGCDOnly = true, cdmTextDurationObject = withoutGCD })
  Eq(shown, "", "progress source on GCD only: empty text")
  _, duration = ShowSplit({}, { cdmHideGCDText = true, cdmTextDurationObject = withoutGCD })
  Eq(duration, withoutGCD, "progress source: cooldown without GCD")
  _, duration = ShowSplit({ cdmHideGCDText = true, cdmTextDurationObject = withoutGCD }, {})
  Eq(duration, withGCD, "active trigger option ignored when another trigger feeds the duration")

  -- Composite texts ("%p s", "%1.p") go through dynamic_texts.p.
  local p = private.dynamic_texts.p
  local now = GetTime()
  local function Timed(fields)
    fields.progressType, fields.expirationTime, fields.duration = "timed", now + 1.5, 1.5
    return fields
  end
  Eq(p.func(p.get(Timed({ cdmHideGCDText = true, cdmGCDOnly = true })), Timed({})), "", "composite: GCD only empty")
  Eq(p.get(Timed({ cdmHideGCDText = true, cdmTextDurationRequired = true })), nil, "composite: required object missing")
  assert(p.get(Timed({ cdmGCDOnly = true })), "composite: option off keeps the GCD")
  assert(p.get(Timed({ cdmHideGCDText = true, cdmGCDOnly = false })), "composite: real cooldown kept")
  assert(p.get(Timed({ cdmHideGCDText = true, cdmGCDOnly = true, cdmTextPreview = true })), "composite: preview kept")

  -- %t follows the same rule.
  local t = private.dynamic_texts.t
  Eq(t.func(t.get(Timed({ cdmHideGCDText = true, cdmGCDOnly = true })), Timed({})), "", "%t: GCD only empty")
  Eq(t.get(Timed({ cdmGCDOnly = true })), 1.5, "%t: option off keeps the GCD")
  Eq(t.get(Timed({ cdmHideGCDText = true, cdmGCDOnly = false })), 1.5, "%t: real cooldown kept")
end

-- Region blocks net: freezes what the icon countdown alpha, UpdateEffectiveInverse, cooldown draw state, the
-- subtext CDM tokens, the dynamic group deferred layout and control point size, the text anchor, the duration
-- object progress branch and the group flow anchor do today. Public surface only (region creation, modify,
-- states, methods installed on the regions), so the blocks can be rewritten and this scenario must keep passing.
return function(test)
  local Secret, Frames, Units = test.Secret, test.Frames, test.Units
  local State = Frames.State
  local function Eq(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end

  local function Aura(id, regionType, extra)
    local data = {
      id = id, uid = id, regionType = regionType, internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
      anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    }
    for key, value in pairs(extra or {}) do data[key] = value end
    return data
  end
  local displays = {
    Icon = Aura("Icon", "icon", { cooldown = true, inverse = true }),
    BuffText = Aura("BuffText", "icon", { subRegions = {
      { type = "subtext", text_text = "%bp", text_selfPoint = "CENTER", anchor_point = "CENTER", rotateText = "LEFT" },
      { type = "subtext", text_text = "%bs" },
      { type = "subtext", text_text = "%s", text_selfPoint = "CENTER" },
      { type = "subtext", text_text = "%p" },
      { type = "subtext", text_text = "plain" },
      { type = "subtext", text_text = "%n", text_selfPoint = "CENTER", anchor_point = "CENTER", rotateText = "LEFT" },
      { type = "subtext", text_text = "%s", text_selfPoint = "TOPLEFT", anchor_point = "BOTTOMRIGHT" },
    } }),
    Txt = Aura("Txt", "text", { displayText = "hello", automaticWidth = "Auto", justify = "LEFT", fontSize = 12 }),
    Grp = Aura("Grp", "group", { controlledChildren = {} }),
    Dyn = Aura("Dyn", "dynamicgroup", { controlledChildren = { "KidIcon", "KidText" }, load = {}, triggers = {} }),
    KidIcon = Aura("KidIcon", "icon", { parent = "Dyn", width = 40, height = 30 }),
    KidText = Aura("KidText", "text", { parent = "Dyn", displayText = "abc", fontSize = 12, automaticWidth = "Auto",
      justify = "LEFT" }),
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(1)

  local function Duration(remaining)
    local proxy = newproxy(true)
    local object = { remaining = remaining }
    getmetatable(proxy).__index = {
      GetRemainingDuration = function() return object.remaining end,
      EvaluateRemainingDuration = function(_, curve) return curve:Evaluate(object.remaining) end,
      Set = function(_, value) object.remaining = value end,
      FormatRemainingDuration = function() return "dur" end,
    }
    return proxy
  end

  ---------------------------------------------------------------- Icon
  local icon = private.EnsureRegion("Icon")
  assert(icon and icon.cooldown, "icon region missing")

  -- I2: modify applies the "Inverse" option.
  Eq(icon.inverseDirection, true, "I2 modify inverse true")
  local iconData = CopyTable(WeakAuras.GetData("Icon"))
  iconData.inverse = false
  WeakAuras.Add(iconData)
  icon = private.EnsureRegion("Icon")
  Eq(icon.inverseDirection, false, "I2 modify inverse false")
  local cooldown = icon.cooldown
  local calls = {}
  local reverse
  local shown = true
  local function Reset() for k in pairs(calls) do calls[k] = nil end end
  local function Log(name, ...) calls[#calls + 1] = { name, ... } end
  cooldown.SetReverse = function(_, value) reverse = value Log("reverse", value) end
  cooldown.GetReverse = function() return reverse end
  cooldown.SetCooldown = function(_, start, duration, modRate) Log("cooldown", start, duration, modRate) end
  cooldown.SetCooldownFromDurationObject = function(_, object, clear) Log("duration", object, clear) end
  cooldown.SetDrawSwipeOrg = function(_, value) Log("swipe", value) end
  cooldown.SetDrawEdge = function(_, value) Log("edge", value) end
  cooldown.SetHideCountdownNumbers = function(_, value) Log("hide", value) end
  cooldown.IsShown = function() return shown end

  -- I3: cooldown draw state (swipe and edge, suppressed while the GCD is hidden).
  Reset()
  icon.cdmProgressState = nil
  icon.cooldownSwipe, icon.cooldownEdge = true, true
  Eq(icon:UpdateCooldownDrawState(), false, "I3 suppressed")
  Eq(#calls, 2, "I3 call count")
  Eq(calls[1][1] .. tostring(calls[1][2]) .. calls[2][1] .. tostring(calls[2][2]), "swipetrueedgetrue", "I3 draw")
  icon.cooldownSwipe, icon.cooldownEdge = nil, 1
  Reset()
  icon:UpdateCooldownDrawState()
  Eq(calls[1][2], false, "I3 swipe nil")
  Eq(calls[2][2], false, "I3 edge must be true")
  icon.cdmProgressState = { cdmSuppressGCD = true }
  icon.cooldownSwipe, icon.cooldownEdge = true, true
  Reset()
  Eq(icon:UpdateCooldownDrawState(), true, "I3 suppress GCD result")
  Eq(calls[1][2], false, "I3 suppress swipe")
  Eq(calls[2][2], false, "I3 suppress edge")
  icon.cdmProgressState = { cdmSuppressGCD = false }
  Reset()
  Eq(icon:UpdateCooldownDrawState(), false, "I3 no suppress result")
  Eq(calls[1][2], true, "I3 no suppress swipe")
  Eq(calls[2][2], true, "I3 no suppress edge")
  icon.cdmProgressState = nil
  Reset()
  icon:SetCooldownSwipe(false)
  Eq(icon.cooldownSwipe, false, "I3 SetCooldownSwipe field")
  Eq(#calls, 2, "I3 SetCooldownSwipe calls")
  Eq(calls[1][2], false, "I3 SetCooldownSwipe swipe")
  Eq(calls[2][2], true, "I3 SetCooldownSwipe edge")
  Reset()
  icon:SetCooldownEdge(true)
  Eq(icon.cooldownEdge, true, "I3 SetCooldownEdge field")
  Eq(#calls, 2, "I3 SetCooldownEdge calls")

  -- I2: effective cooldown direction.
  local function Reverse(inverseDirection, cooldownInverse, progressState)
    icon.inverseDirection = inverseDirection
    cooldown.inverse = cooldownInverse
    icon.cdmProgressState = progressState
    cooldown.durationObject, cooldown.expirationTime, cooldown.duration = nil, nil, nil
    Reset()
    icon:UpdateEffectiveInverse()
    return reverse
  end
  Eq(Reverse(nil, nil), true, "I2 nil nil")
  Eq(Reverse(true, nil), false, "I2 icon inverse")
  Eq(Reverse(nil, true), false, "I2 cooldown inverse")
  Eq(Reverse(true, true), true, "I2 both inverse")
  Eq(Reverse(false, false), true, "I2 both false")
  Eq(Reverse(true, true, { cooldownID = 1, cdmBuff = false }), true, "I2 cdm spell both")
  Eq(Reverse(nil, nil, { cooldownID = 1 }), false, "I2 cdm spell none")
  Eq(Reverse(nil, true, { cooldownID = 1, cdmBuff = false }), false, "I2 cdm spell cooldown inverse")
  Eq(Reverse(true, nil, { cooldownID = 1, cdmBuff = true }), false, "I2 cdm buff default formula")
  Eq(Reverse(true, nil, { cdmBuff = false }), false, "I2 cdm without cooldownID")

  icon.cdmProgressState, icon.inverseDirection, cooldown.inverse = nil, nil, nil
  reverse = true
  local object = Duration(5)
  cooldown.durationObject = object
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 1, "I2 duration object unchanged direction")
  icon.inverseDirection = true
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 3, "I2 duration object changed direction")
  Eq(calls[1][1] .. tostring(calls[1][2]), "reversefalse", "I2 duration object reverse")
  Eq(calls[2][1] .. calls[2][2] .. calls[2][3], "cooldown00", "I2 duration object clear")
  Eq(calls[3][1] .. tostring(calls[3][2] == object) .. tostring(calls[3][3]), "durationtruetrue", "I2 duration object apply")
  icon.inverseDirection = nil
  shown = false
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 1, "I2 duration object hidden cooldown")
  shown = true
  cooldown.durationObject = nil
  cooldown.expirationTime, cooldown.duration = 110, 10
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 3, "I2 number mode calls")
  Eq(calls[2][1] .. calls[2][2] .. calls[2][3], "cooldown00", "I2 number mode clear")
  Eq(calls[3][1] .. calls[3][2] .. calls[3][3] .. tostring(calls[3][4]), "cooldown10010nil", "I2 number mode start")
  cooldown.useCooldownModRate, cooldown.modRate = true, 2
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(calls[3][4], 2, "I2 number mode mod rate")
  cooldown.expirationTime = Secret.Wrap(110)
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 1, "I2 secret expiration time")
  shown = false
  cooldown.expirationTime = 110
  Reset()
  icon:UpdateEffectiveInverse()
  Eq(#calls, 1, "I2 number mode hidden cooldown")
  shown = true
  cooldown.useCooldownModRate, cooldown.modRate = nil, nil

  -- I1: countdown numbers (hide flag, alpha driven by the tracked duration object).
  local countdown = cooldown:GetCountdownFontString()
  local function Alpha() return State[countdown].alpha end
  local function LastHide() return calls[#calls][2] end
  icon.cdmProgressState, icon.state = nil, nil
  Reset()
  icon:SetHideCountdownNumbers(nil)
  Eq(icon.cdmConfiguredHideNumbers, nil, "I1 configured nil")
  Eq(LastHide(), false, "I1 hide nil")
  Eq(Alpha(), 1, "I1 alpha default")
  Eq(icon.countdownTextDuration, nil, "I1 no tracked object")
  icon:SetHideCountdownNumbers(true)
  Eq(icon.cdmConfiguredHideNumbers, true, "I1 configured true")
  Eq(LastHide(), true, "I1 hide true")
  icon:SetHideCountdownNumbers(false)
  Eq(icon.cdmConfiguredHideNumbers, false, "I1 configured false")
  Eq(LastHide(), false, "I1 hide false")
  local tracked = Duration(0)
  icon.state = { cdmHideGCDText = true, cdmTextDurationObject = tracked }
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 0, "I1 tracked 0")
  Eq(icon.countdownTextDuration, tracked, "I1 tracked object kept")
  Eq(LastHide(), false, "I1 tracked does not hide")
  tracked:Set(0.0005)
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 0.5, "I1 tracked half")
  tracked:Set(0.001)
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 1, "I1 tracked full")
  icon.state = { cdmHideGCDText = true }
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 1, "I1 untracked alpha")
  Eq(icon.countdownTextDuration, nil, "I1 untracked object")
  icon.state = { cdmHideGCDText = true, cdmGCDOnly = true }
  icon:SetHideCountdownNumbers(nil)
  Eq(LastHide(), true, "I1 GCD only hides")
  icon.state = { cdmHideGCDText = true, cdmTextDurationRequired = true }
  icon:SetHideCountdownNumbers(nil)
  Eq(LastHide(), true, "I1 duration required without object hides")
  icon.state = { cdmHideGCDText = false, cdmTextDurationObject = tracked }
  icon:SetHideCountdownNumbers(nil)
  Eq(icon.countdownTextDuration, nil, "I1 not GCD text ignores object")
  icon.state = nil
  icon.cdmProgressState = { cdmHideGCDText = true, cdmTextDurationObject = tracked }
  tracked:Set(0)
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 0, "I1 progress state source")
  Eq(icon.countdownTextDuration, tracked, "I1 progress state object")
  icon.state = { cdmHideGCDText = false }
  icon:SetHideCountdownNumbers(nil)
  Eq(icon.countdownTextDuration, tracked, "I1 progress state wins over state")
  icon.cdmProgressState, icon.state = nil, nil
  icon:SetHideCountdownNumbers(nil)
  Eq(Alpha(), 1, "I1 released alpha")

  -- I1: the native refresher keeps the alpha in sync while the icon is visible, and stops once released.
  icon:Show()
  tracked:Set(0.0005)
  icon.state = { cdmHideGCDText = true, cdmTextDurationObject = tracked }
  icon:SetHideCountdownNumbers(nil)
  tracked:Set(0)
  test.Environment.Advance(0.3)
  Eq(Alpha(), 0, "I1 refresher follows tracked 0")
  tracked:Set(0.001)
  test.Environment.Advance(0.3)
  Eq(Alpha(), 1, "I1 refresher follows tracked full")
  icon.state = nil
  icon:SetHideCountdownNumbers(nil)
  tracked:Set(0)
  test.Environment.Advance(0.3)
  Eq(Alpha(), 1, "I1 refresher stops after release")

  -- P2 and P1: progress taken from a duration object source.
  local fake = { UpdateTime = function(self) self.updated = (self.updated or 0) + 1 end,
    SetAdditionalProgress = function(self, ...) self.additional = { n = select("#", ...), ... } end }
  local durationObject = Duration(5)
  local source = { 1, "durationObject", nil, nil, nil, "inv", nil, nil, true }
  local state = { durationObject = durationObject, additionalProgress = "extra", inv = true }
  private.UpdateProgressFrom(fake, source, { adjustedMin = 0.2, adjustedMax = 0.8 }, nil, { state })
  Eq(fake.minProgress, 0.2, "P2 min")
  Eq(fake.maxProgress, 0.8, "P2 max")
  Eq(fake.progressType, "timed", "P2 progress type")
  Eq(fake.duration, 0, "P2 duration")
  Eq(fake.expirationTime, math.huge, "P2 expiration time")
  Eq(fake.remaining, nil, "P2 remaining")
  Eq(fake.modRate, nil, "P2 mod rate")
  Eq(fake.inverse, true, "P2 inverse")
  Eq(fake.paused, false, "P2 paused")
  Eq(fake.durationObject, durationObject, "P2 duration object")
  Eq(fake.updated, 1, "P2 UpdateTime")
  Eq(fake.additional.n, 4, "P2 additional argument count")
  Eq(fake.additional[1] .. fake.additional[2] .. fake.additional[3] .. tostring(fake.additional[4]), "extra01false", "P2 additional")
  Eq(fake.cdmProgressState, state, "P2 progress state")
  private.UpdateProgressFrom(fake, source, { adjustedMinRelPercent = 0.1, adjustedMaxRelPercent = 0.9 }, nil, { state })
  Eq(fake.minProgress .. "/" .. fake.maxProgress, "0.1/0.9", "P2 relative percents")
  private.UpdateProgressFrom(fake, { 1, "durationObject" }, {}, nil, { { durationObject = durationObject } })
  Eq(fake.minProgress .. "/" .. fake.maxProgress, "0/1", "P2 default range")
  Eq(fake.inverse, nil, "P2 no inverse property")
  Eq(fake.additional.n, 1, "P2 additional without property")
  local bare = {}
  private.UpdateProgressFrom(bare, source, {}, nil, { { durationObject = durationObject } })
  Eq(bare.durationObject, durationObject, "P2 region without UpdateTime")
  local timerSource = { 1, "timer", "expirationTime", "duration", "modRate", "inverse", "paused", "remaining", true }
  local function Timer(progressType, candidate)
    private.UpdateProgressFrom(fake, timerSource, {}, nil, { { progressType = progressType, durationObject = candidate,
      expirationTime = 500, duration = 10, inverse = false } })
  end
  Timer("durationObject", durationObject)
  Eq(fake.progressType, "timed", "P1 promoted progress type")
  Eq(fake.duration, 0, "P1 promoted duration")
  Eq(fake.expirationTime, math.huge, "P1 promoted expiration time")
  Eq(fake.durationObject, durationObject, "P1 promoted object")
  Eq(fake.minProgress .. "/" .. fake.maxProgress, "0/1", "P1 promoted range")
  Timer("timed", durationObject)
  Eq(fake.duration .. "/" .. fake.expirationTime .. "/" .. fake.maxProgress, "10/500/10", "P1 timed stays timer")
  Timer("durationObject", 5)
  Eq(fake.duration .. "/" .. fake.expirationTime, "10/500", "P1 non object stays timer")

  -- G1 and G2: group flow anchor and flow rechain.
  local grpData = WeakAuras.GetData("Grp")
  local grp = private.EnsureRegion("Grp")
  local display = private.BlizzardAuraDisplay
  local rechained, arranged = {}, {}
  local savedRechain, savedArrange = display.RechainFlow, display.ArrangeFlowPreview
  display.RechainFlow = function(data) rechained[#rechained + 1] = data end
  display.ArrangeFlowPreview = function(data) arranged[#arranged + 1] = data end
  local savedOptions = WeakAuras.IsOptionsOpen
  local function Modify(extra)
    grpData.blizzardFlow, grpData.blizzardFlowFrames, grpData.selfPoint = nil, nil, nil
    for key, value in pairs(extra) do grpData[key] = value end
    rechained, arranged = {}, {}
    private.regionTypes.group.modify(WeakAurasFrame, grp, grpData)
    return grpData.selfPoint
  end
  Eq(Modify({ blizzardFlow = true, blizzardFlowFrames = {}, selfPoint = "TOP" }), "TOP", "G1 flow keeps self point")
  Eq(Modify({ blizzardFlow = true, blizzardFlowFrames = {} }), "CENTER", "G1 flow without self point")
  Eq(Modify({ blizzardFlow = true, selfPoint = "TOP" }), "CENTER", "G1 flow without frames")
  Eq(Modify({ selfPoint = "TOP", blizzardFlowFrames = {} }), "CENTER", "G1 frames without flow")
  Eq(Modify({}), "CENTER", "G1 plain")
  grpData.information = grpData.information or {}
  grpData.information.groupOffset = true
  Eq(Modify({}), "BOTTOMLEFT", "G1 group offset plain")
  Eq(Modify({ blizzardFlow = true, blizzardFlowFrames = {}, selfPoint = "TOP" }), "TOP", "G1 group offset flow")
  Eq(Modify({ blizzardFlow = true }), "BOTTOMLEFT", "G1 group offset flow without frames")
  grpData.information.groupOffset = nil
  Modify({ blizzardFlow = true })
  Eq(#rechained, 1, "G2 rechain count")
  Eq(rechained[1], grpData, "G2 rechain data")
  Eq(#arranged, 0, "G2 no preview with options closed")
  WeakAuras.IsOptionsOpen = function() return true end
  Modify({ blizzardFlow = true })
  Eq(#rechained, 1, "G2 rechain with options")
  Eq(#arranged, 1, "G2 preview with options")
  Eq(arranged[1], grpData, "G2 preview data")
  Modify({})
  Eq(#rechained + #arranged, 0, "G2 no flow")
  WeakAuras.IsOptionsOpen = savedOptions
  display.RechainFlow = nil
  Eq(pcall(Modify, { blizzardFlow = true }), true, "G2 missing RechainFlow")
  display.RechainFlow, display.ArrangeFlowPreview = savedRechain, savedArrange

  -- T1: text anchor follows SetAnchor in automatic width, and the justify in fixed width.
  local txt = private.EnsureRegion("Txt")
  local txtData = WeakAuras.GetData("Txt")
  local function TextPoints()
    local out = {}
    for _, point in ipairs(State[txt.text].points) do
      out[#out + 1] = point[1] .. ">" .. point[3] .. (point[2] == txt and "@region" or "@other")
    end
    return table.concat(out, ",")
  end
  Eq(txt.automaticTextWidth, true, "T1 automatic width")
  Eq(txt.textAnchorPoint .. " " .. TextPoints(), "CENTER CENTER>CENTER@region", "T1 default anchor")
  txt:SetAnchor("TOPRIGHT", UIParent, "TOPRIGHT")
  Eq(txt.textAnchorPoint .. " " .. TextPoints(), "TOPRIGHT TOPRIGHT>TOPRIGHT@region", "T1 SetAnchor automatic")
  txtData.automaticWidth, txtData.justify = "Fixed", "RIGHT"
  private.regionTypes.text.modify(WeakAurasFrame, txt, txtData)
  Eq(txt.automaticTextWidth, false, "T1 fixed width")
  Eq(txt.textAnchorPoint .. " " .. TextPoints(), "RIGHT RIGHT>RIGHT@region", "T1 fixed anchor from justify")
  txt:SetAnchor("BOTTOM", UIParent, "BOTTOM")
  Eq(txt.textAnchorPoint .. " " .. TextPoints(), "RIGHT RIGHT>RIGHT@region", "T1 SetAnchor ignored in fixed width")
  txtData.automaticWidth, txtData.selfPoint, txt.anchorPoint = nil, "LEFT", nil
  private.regionTypes.text.modify(WeakAurasFrame, txt, txtData)
  Eq(txt.automaticTextWidth, true, "T1 nil width is automatic")
  Eq(txt.textAnchorPoint .. " " .. TextPoints(), "LEFT LEFT>LEFT@region", "T1 fallback to self point")
  txt:SetAnchor("LEFT", UIParent, "LEFT")
  local pointCount = #State[txt.text].points
  txt:SetAnchor("LEFT", UIParent, "RIGHT")
  Eq(#State[txt.text].points, pointCount, "T1 same anchor point adds no text point")

  -- D2: control point size of the shown children (icon: data size, text: region size).
  local dyn = private.EnsureRegion("Dyn")
  local kidIcon, kidText = private.EnsureRegion("KidIcon"), private.EnsureRegion("KidText")
  kidIcon.toShow, kidText.toShow = true, true
  kidText.width, kidText.height = 33, 17
  dyn:ReloadControlledChildren()
  Eq(#dyn.sortedChildren, 2, "D2 shown children")
  local sizes = {}
  for _, regionData in ipairs(dyn.sortedChildren) do
    sizes[regionData.id] = regionData.controlPoint:GetWidth() .. "x" .. regionData.controlPoint:GetHeight()
  end
  Eq(sizes.KidIcon, "40x30", "D2 icon size")
  Eq(sizes.KidText, "33x17", "D2 text size")

  -- D1: layout calls refused for a protected group in combat run once when combat ends.
  local reloads = 0
  local originalReload = dyn.ReloadControlledChildren
  dyn.ReloadControlledChildren = function(self, ...) reloads = reloads + 1 return originalReload(self, ...) end
  Units.SetCombat(true)
  dyn:PositionChildren()
  Eq(reloads, 0, "D1 unprotected group not deferred")
  Frames.SetProtected(dyn, true)
  dyn:PositionChildren()
  dyn:PositionChildren()
  dyn:Resize()
  dyn:AddChild("KidIcon", "zz")
  dyn:RemoveChild("KidIcon", "zz")
  dyn:ReloadControlledChildren()
  Eq(reloads, 1, "D1 only the explicit reload while in combat")
  Frames.Fire("PLAYER_REGEN_ENABLED")
  Eq(reloads, 1, "D1 no reload while still in combat")
  Units.SetCombat(false)
  Eq(reloads, 2, "D1 one deferred reload after combat")
  Frames.Fire("PLAYER_REGEN_ENABLED")
  Eq(reloads, 2, "D1 deferred reload is not repeated")
  Frames.SetProtected(dyn, false)
  Units.SetCombat(true)
  dyn.sortedChildren[1].controlPoint.IsProtected = function() return true end
  reloads = 0
  dyn:RemoveChild("KidIcon", "")
  Eq(reloads, 0, "D1 protected control point deferred in combat")
  Units.SetCombat(false)
  Eq(reloads, 1, "D1 protected control point reload after combat")
  dyn.ReloadControlledChildren = originalReload

  -- S1 to S4: subtext tokens on an icon.
  local buffText = private.EnsureRegion("BuffText")
  local subs = {}
  for _, sub in ipairs(buffText.subRegions) do if sub.text_text then subs[#subs + 1] = sub end end
  Eq(#subs, 7, "S subtext count")
  local function Source(text, isShown) return { GetText = function() return text end, IsShown = function() return isShown end } end
  local function Ticks()
    local out = {}
    for index, sub in ipairs(subs) do out[index] = sub.FrameTick ~= nil and "T" or "-" end
    return table.concat(out)
  end
  Eq(Ticks(), "TT-T---", "S2 frame ticks with aura trigger")
  Eq(subs[1].FrameTick, subs[1].Update, "S1 %bp tick is update")
  Eq(subs[2].FrameTick, subs[2].Update, "S1 %bs tick is update")
  buffText.state = { show = true, cdmCountdownSource = Source("12", true), cdmStackSource = Source("4", true) }
  subs[1].Update() subs[2].Update() subs[3].Update()
  Eq(subs[1].text:GetText(), "12", "S1 %bp copies the countdown")
  Eq(subs[2].text:GetText(), "4", "S1 %bs copies the stack")
  assert(subs[3].text:GetText() ~= "12", "S1 %s without cdmBuff renders classic")
  buffText.state = { show = true, cdmBuff = true, cdmCountdownSource = Source("0", true), cdmStackSource = Source("4", false) }
  subs[1].Update() subs[2].Update()
  Eq(subs[1].text:GetText(), "", "S1 countdown 0 is blank for a buff")
  Eq(subs[2].text:GetText(), "", "S1 hidden stack source is blank")
  buffText.state = { show = true, cdmBuff = true, durationObject = Duration(5) }
  subs[1].FrameTick()
  Eq(subs[1].text:GetText(), "dur", "S1 buff duration object formatted")
  buffText.state = nil
  Eq(pcall(subs[1].Update), true, "S1 nil state tolerated")
  buffText.state = { show = true, cdmTextPreview = true }
  subs[1].Update() subs[2].Update()
  Eq(subs[1].text:GetText() .. subs[2].text:GetText(), "63", "S1 preview texts")
  local buffTextData = WeakAuras.GetData("BuffText")
  buffTextData.triggers[1].trigger = { type = "cdm", event = "Blizzard CDM Buff" }
  for _, sub in ipairs(subs) do sub:ConfigureTextUpdate() end
  Eq(Ticks(), "TTTT--T", "S2 frame ticks with CDM buff trigger")
  local nativeText = { calls = {}, ClearAllPoints = function(self) self.calls[#self.calls + 1] = "clear" end,
    SetPoint = function(self, ...) self.calls[#self.calls + 1] = "point" self.args = { ... } end }
  subs[3]:AnchorNativeText(nativeText)
  Eq(table.concat(nativeText.calls, ","), "clear,point", "S3 call order")
  Eq(nativeText.args[1] .. tostring(nativeText.args[2] == subs[3].text) .. nativeText.args[3], "CENTERtrueCENTER", "S3 anchor center")
  subs[7]:AnchorNativeText(nativeText)
  Eq(nativeText.args[1] .. nativeText.args[3], "TOPLEFTTOPLEFT", "S3 anchor self point")
  local function Offsets(sub)
    local point = State[sub.text].points[1]
    return point[4] .. ":" .. point[5]
  end
  subs[1]:Anchor() subs[5]:Anchor() subs[6]:Anchor()
  Eq(Offsets(subs[1]), Offsets(subs[5]), "S4 CDM text ignores rotation")
  assert(Offsets(subs[6]) ~= Offsets(subs[5]), "S4 rotated text gets an offset")
end

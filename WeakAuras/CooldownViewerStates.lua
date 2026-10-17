-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end

-- Cooldown Manager trigger, part 2 of 3: from a selection to clone states.
-- Every pass builds fresh state tables, so no field survives from one entry or one pass to the
-- next. A request object carries the display settings of the pass; one filler per entry kind
-- (spell, item, buff) writes the kind-specific fields; visibility is decided last, and only the
-- visible states are produced. CommitStates writes them into allstates and hides the clones that
-- were not produced again; out of combat it only flags the states whose readable values moved.
--
-- Spell flags are merged in one place with an explicit priority: the native record of the CDM frame
-- first, then the readable Blizzard API, then the GCD flags of Private.SpellCooldownState. Timers
-- always come from Private.SpellCooldownState (the native duration may follow an aura instead).
-- Secret values are never compared nor stored; duration objects are passed through untouched.

local _, Private = ...

local CooldownViewer = Private.CooldownViewer
local Catalog = CooldownViewer.Catalog
local ReadableOrNil, IsReadableNumber = Private.ReadableOrNil, Private.IsReadableNumber

local PREVIEW_DURATION = 6
local PREVIEW_STACKS = 3
local WAKE_MARGIN = 0.05
local NO_NATIVE = {}

-- Visibility test of each show mode; a nil field never shows.
local SHOW_MODES = {
  always = function(_) return true end,
  cooldown = function(state) return state.onCooldown == true end,
  ready = function(state) return state.onCooldown == false end,
  usable = function(state) return state.isUsable == true end,
  unusable = function(state) return state.isUsable == false end,
  active = function(state) return state.auraActive == true end,
  missing = function(state) return state.auraActive == false end,
}

-- Preference between buff entries tried for one selection: active, then unknown, then inactive.
local AURA_PREFERENCE = { [true] = 3, [false] = 1 }

-- Fields of a buff state that belong to its own catalogue entry, kept when another entry lends its aura.
local ENTRY_FIELDS = { "cooldownID", "cdmCategory", "cdmDisplayed", "index" }

-- Comparison operators of the buff filters and of the remaining time condition.
local OPERATORS = {
  ["<"] = function(a, b) return a < b end,
  ["<="] = function(a, b) return a <= b end,
  [">"] = function(a, b) return a > b end,
  [">="] = function(a, b) return a >= b end,
  ["=="] = function(a, b) return a == b end,
  ["~="] = function(a, b) return a ~= b end,
}
CooldownViewer.OPERATORS = OPERATORS

---------------------------------------------------------------------------------------------------
-- Request
---------------------------------------------------------------------------------------------------

-- Display settings of one composition pass.
local function NewRequest(event, showGCD, track, hideGCDText, showMode, exactID, requireTarget, ignoreSpellKnown)
  return {
    event = event,
    preview = event == "OPTIONS",
    showGCD = showGCD == true,
    track = track or "auto",
    hideGCDText = hideGCDText == true,
    showMode = showMode or "always",
    exactID = exactID,
    requireTarget = requireTarget == true,
    ignoreSpellKnown = ignoreSpellKnown == true,
  }
end

-- Request described by a query or a legacy config table.
local function RequestFromQuery(query, event)
  -- An item trigger matches its exact spell id but keeps the item identity.
  local imposesSpell = query.cdmExact and CooldownViewer.KindOf(query.event) ~= "item"
  local exactID = imposesSpell and tonumber(CooldownViewer.Trim(query.cdmSpell)) or nil
  return NewRequest(event, query.showGCD, query.track, query.hideGCDText, query.showMode, exactID,
    query.requireTarget, query.use_ignoreSpellKnown)
end
CooldownViewer.RequestFromQuery = RequestFromQuery

---------------------------------------------------------------------------------------------------
-- Readers shared with the conditions
---------------------------------------------------------------------------------------------------

-- Readable number returned by a method of a duration object, or nil.
local function ReadDuration(durationObject, method)
  local ok, value = pcall(durationObject[method], durationObject)
  return ok and IsReadableNumber(value) and value or nil
end

-- Real seconds per second of timer: the readable modRate of a timed state, else 1.
-- Duration objects already account for it.
function CooldownViewer.TimeScale(state)
  local rate = state.modRate
  if state.progressType == "timed" and IsReadableNumber(rate) and rate > 0 then
    return rate
  end
  return 1
end

-- Readable total duration of a state, or nil when missing, permanent or secret.
function CooldownViewer.ReadTotal(state)
  local total
  if state.progressType == "durationObject" and state.durationObject then
    total = ReadDuration(state.durationObject, "GetTotalDuration")
  elseif state.progressType == "timed" and IsReadableNumber(state.duration) then
    total = state.duration / CooldownViewer.TimeScale(state)
  end
  return total and total > 0 and total or nil
end

-- Readable remaining time of a state, or nil when missing, permanent or secret.
function CooldownViewer.ReadRemaining(state)
  if not CooldownViewer.ReadTotal(state) then
    return nil
  elseif state.progressType == "durationObject" then
    return ReadDuration(state.durationObject, "GetRemainingDuration")
  elseif IsReadableNumber(state.expirationTime) then
    return math.max((state.expirationTime - GetTime()) / CooldownViewer.TimeScale(state), 0)
  end
end

---------------------------------------------------------------------------------------------------
-- Fillers, one per entry kind
---------------------------------------------------------------------------------------------------

-- Progress without any timer.
local function SetZeroTimer(state)
  state.progressType = "timed"
  state.duration = 0
  state.expirationTime = 0
  state.value, state.total = nil, nil
end

-- Progress following a native duration object.
local function SetDurationObject(state, durationObject)
  state.progressType = "durationObject"
  state.durationObject = durationObject
  state.value, state.total = nil, nil
end

local Fillers = {}

-- Spell cooldown, charges, GCD, usability and range of an entry.
function Fillers.spell(state, candidate, request)
  local cooldowns = Private.SpellCooldownState
  local spellID = CooldownViewer.DisplayedSpell(state.spellId)
  if not spellID then
    return
  end
  local native = Private.CDMGetNativeCooldown(candidate.frame, candidate.identity.spellID) or NO_NATIVE

  if request.event == "SPELL_UPDATE_COOLDOWN" then
    cooldowns.UpdateGCDFlag(spellID)
  end
  local gcdOnly = native.onGCD
  if gcdOnly == nil then
    gcdOnly = cooldowns.GetGCDFlag(spellID) == true
  end

  local onCooldown = native.onCooldown
  if onCooldown == nil then
    local cooldown = C_Spell.GetSpellCooldown(spellID)
    if gcdOnly then
      onCooldown = false
    elseif cooldown then
      onCooldown = ReadableOrNil(cooldown.isActive)
    end
  end

  local chargeInfo = C_Spell.GetSpellCharges and C_Spell.GetSpellCharges(spellID)
  local maxCharges = chargeInfo and ReadableOrNil(chargeInfo.maxCharges)
  -- The native count is a cast count for spells without charges, so only maxCharges decides.
  local hasCharges = type(maxCharges) == "number" and maxCharges > 1
  local recharging
  if hasCharges then
    recharging = native.recharging
    if recharging == nil and chargeInfo then
      recharging = ReadableOrNil(chargeInfo.isActive)
    end
    local charges = native.charges
    if charges == nil and chargeInfo then
      charges = ReadableOrNil(chargeInfo.currentCharges)
    end
    state.stacks = charges
    state.recharging = recharging
    if charges ~= nil then
      onCooldown = charges == 0
    elseif native.recharging == true then
      onCooldown = false
    end
  elseif IsReadableNumber(native.charges) and native.charges > 0 then
    -- Without charges the native count is a cast count: shown as stacks, never a cooldown flag.
    state.stacks = native.charges
  end
  local useCharges = hasCharges and (request.track == "charges" or (request.track == "auto" and recharging == true))
  local display, withoutGCD = cooldowns.GetDisplayDurations(spellID, useCharges, request.showGCD, false)
  local wandHeld = not hasCharges and cooldowns.IsWandHeld(spellID)
  if wandHeld then
    -- Other spells report the Shoot timer while a wand fires: trust the held timer instead.
    display = withoutGCD or display
    local remaining = withoutGCD and cooldowns.ReadableRemaining(withoutGCD)
    if remaining then
      onCooldown = remaining > 0
    end
  end
  -- A charge timer or a held wand timer is a real timer: the GCD neither hides it nor flags it.
  local realTimer = useCharges or wandHeld
  state.onCooldown = onCooldown
  if onCooldown ~= nil then
    state.isReady = not onCooldown
  end
  state.cdmGCDOnly = gcdOnly and not realTimer
  if state.cdmGCDOnly and not request.showGCD then
    state.cdmSuppressGCD = true
    SetZeroTimer(state)
  elseif display then
    SetDurationObject(state, display)
  else
    SetZeroTimer(state)
  end
  if request.hideGCDText then
    state.cdmTextDurationObject = withoutGCD
    state.cdmTextDurationRequired = true
  end

  local usable, noResources = C_Spell.IsSpellUsable(spellID)
  state.isUsable = ReadableOrNil(usable)
  state.insufficientResources = ReadableOrNil(noResources)
  state.inRange = native.inRange
  state.cdmNativePaused = native.paused == true and not realTimer
  state.cdmNativeRevision = native.revision
end

-- Item cooldown, read by the catalogue.
function Fillers.item(state, candidate, _, _)
  Private.CDMApplyItem(state, candidate.identity)
end

-- Aura timing and render fields, read by the catalogue.
function Fillers.buff(state, candidate, request, selection)
  Private.CDMApplyAura(state, candidate.identity, candidate.info, candidate.frame, request.exactID, selection.buffSpellIDs)
  local byEntry = selection.buffSpellIDsByEntry
  local entryAuras = byEntry and byEntry[candidate.id] or Private.CDMAuraSpellIDs(candidate.info)
  if entryAuras[1] then
    state.cdmAuraSpellIDs = entryAuras
  elseif request.exactID then
    state.cdmAuraSpellIDs = { request.exactID }
  else
    state.cdmAuraSpellIDs = selection.buffSpellIDs or { state.spellId }
  end
end

-- Fixed sample shown while the options are open.
local function FillPreview(state)
  state.progressType = "timed"
  state.duration = PREVIEW_DURATION
  state.expirationTime = GetTime() + PREVIEW_DURATION
  state.modRate = 1
  state.value, state.total = nil, nil
  state.stacks = PREVIEW_STACKS
  state.auraActive = true
  state.onCooldown = true
  state.isReady = false
end

---------------------------------------------------------------------------------------------------
-- Composition
---------------------------------------------------------------------------------------------------

-- Everything known about one catalogue entry, or nil when the entry vanished.
local function Candidate(id, catalog, frames)
  local entry = catalog[id]
  local info = entry and Catalog:Info(id)
  if not info then
    return nil
  end
  return {
    id = id,
    entry = entry,
    info = info,
    frame = frames[id],
    identity = Private.CDMIdentity(id, entry, info, frames[id]),
    kind = CooldownViewer.EntryKind(entry, info),
  }
end

-- New state of a candidate with every field at its default and the identity fields set.
local function NewState(candidate, index, selection, request)
  local identity, entry = candidate.identity, candidate.entry
  local state = {
    show = true, changed = true, autoHide = false,
    progressType = "static", value = 1, total = 1,
    cdmSuppressGCD = false, cdmNativePaused = false, cdmGCDOnly = false,
    index = index,
    cooldownID = candidate.id,
    spellId = identity.spellID,
    itemId = identity.itemID,
    name = identity.name,
    icon = identity.icon,
    cdmDisplayed = entry.displayed == true,
    cdmCategory = Private.CDMCategoryName(entry.category),
    cdmBuff = candidate.kind == "buff",
    cdmTextPreview = request.preview,
    cdmHideGCDText = request.hideGCDText and not request.preview,
  }
  local imposedID = request.exactID or selection.buffResolvedSpellID
  if imposedID then
    state.spellId = imposedID
    local info = C_Spell.GetSpellInfo(imposedID)
    if info then
      state.name, state.icon = info.name, info.iconID
    end
  end
  return state
end

-- Whether the player or the pet knows a spell, by id or else by its name.
local function IsSpellKnown(spellID)
  if WeakAuras.IsSpellKnownIncludingPet(spellID) then
    return true
  end
  local info = C_Spell.GetSpellInfo(spellID)
  local name = info and ReadableOrNil(info.name)
  return type(name) == "string" and WeakAuras.IsSpellKnownIncludingPet(name) == true
end

-- Whether one of the spells behind a spell entry is known.
local function IsEntrySpellKnown(candidate)
  local own = { candidate.identity.spellID, candidate.info.spellID }
  for index = 1, 2 do
    local spellID = CooldownViewer.SpellIDOrNil(own[index])
    if spellID and IsSpellKnown(spellID) then
      return true
    end
  end
  for _, spellID in ipairs(CooldownViewer.RelatedSpells(candidate.info)) do
    if IsSpellKnown(spellID) then
      return true
    end
  end
  return false
end

-- Final visibility of a filled state outside the options.
local function IsVisible(state, candidate, request)
  if candidate.kind == "spell" and not request.ignoreSpellKnown and not IsEntrySpellKnown(candidate) then
    return false
  end
  return (SHOW_MODES[request.showMode] or SHOW_MODES.always)(state)
end

-- Whether a hostile target exists; secret answers count as no.
local function HasAttackableTarget()
  return ReadableOrNil(UnitExists("target")) == true and ReadableOrNil(UnitCanAttack("player", "target")) == true
end

-- Filled state of one candidate.
local function BuildState(candidate, index, selection, request)
  local state = NewState(candidate, index, selection, request)
  if request.preview then
    FillPreview(state)
  else
    Fillers[candidate.kind](state, candidate, request, selection)
  end
  state.hasTimer = state.progressType ~= "static"
  return state
end

-- Aura of the best buff entry matching the name of a selection, worn by the state of its own entry.
local function BorrowBestAura(own, id, index, selection, request, catalog, frames)
  local best, bestScore = own, AURA_PREFERENCE[own.auraActive] or 2
  for _, otherID in ipairs(selection.buffEntryIDs) do
    local other = bestScore < 3 and otherID ~= id and Candidate(otherID, catalog, frames)
    if other and other.kind == "buff" then
      local state = BuildState(other, index, selection, request)
      local score = AURA_PREFERENCE[state.auraActive] or 2
      if score > bestScore then
        best, bestScore = state, score
      end
    end
  end
  for _, field in ipairs(ENTRY_FIELDS) do
    best[field] = own[field]
  end
  return best
end

-- State of a selected entry; a buff found by name may wear the aura of another matching entry.
local function ComposeEntry(id, index, selection, request, catalog, frames)
  local candidate = Candidate(id, catalog, frames)
  if not candidate then
    return nil
  end
  local admitted = request.preview or selection.picked or candidate.entry.known or request.exactID
    or request.ignoreSpellKnown or candidate.kind == "buff"
  if not admitted then
    return nil
  end

  local best = BuildState(candidate, index, selection, request)
  if candidate.kind == "buff" and selection.buffEntryIDs and not request.preview then
    best = BorrowBestAura(best, id, index, selection, request, catalog, frames)
  end

  if not request.preview and not IsVisible(best, candidate, request) then
    return nil
  end
  return best
end

-- Stand-in state of a query that matched nothing while the options are open.
local function PreviewOnlyState(previewSpell)
  local state = {
    show = true, changed = true, autoHide = false,
    index = 1, name = previewSpell.name, icon = previewSpell.iconID, spellId = previewSpell.spellID,
    cdmDisplayed = false, cdmCategory = Private.CDMCategoryName(nil), cdmBuff = false,
    cdmTextPreview = true, cdmHideGCDText = false,
    cdmSuppressGCD = false, cdmNativePaused = false, cdmGCDOnly = false,
  }
  FillPreview(state)
  state.hasTimer = true
  return state
end

-- Visible states of a selection, keyed by clone id; the first state of a key wins.
local function ComposeStates(selection, request)
  if request.event == "SPELL_UPDATE_COOLDOWN" then
    Private.QueueCDMRefresh()
  end
  local produced = {}
  if request.requireTarget and not request.preview and not HasAttackableTarget() then
    return produced
  end
  local catalog = Catalog:Get(request.event)
  local frames = Private.CDMFrames()
  for index, id in ipairs(selection) do
    local key = selection.singleClone and "spell" or tostring(id)
    if not produced[key] then
      produced[key] = ComposeEntry(id, index, selection, request, catalog, frames)
    end
  end
  if request.preview and not selection[1] and selection.previewSpell then
    produced[selection.singleClone and "spell" or "preview"] = PreviewOnlyState(selection.previewSpell)
  end
  return produced
end
CooldownViewer.ComposeStates = ComposeStates

-- Visible states of one query or legacy config.
local function ComposeQuery(query, event)
  return ComposeStates(Private.ResolveCDMSpell(query, event), RequestFromQuery(query, event))
end
CooldownViewer.ComposeQuery = ComposeQuery

-- Whether two field values are known to be equal: secrets never are, plain tables compare by content,
-- other tables (duration objects) by identity.
local function SameValue(a, b)
  if a == nil or b == nil then
    return a == b
  elseif Private.IsSecret(a) or Private.IsSecret(b) then
    return false
  elseif type(a) == "table" and type(b) == "table" and not getmetatable(a) and not getmetatable(b) then
    for field, value in pairs(a) do
      if not SameValue(value, b[field]) then
        return false
      end
    end
    for field in pairs(b) do
      if a[field] == nil then
        return false
      end
    end
    return true
  end
  return a == b
end

-- Whether a produced state carries the same readable values as the stored one.
local function SameState(stored, state)
  if not stored then
    return false
  end
  for field, value in pairs(state) do
    if field ~= "changed" and not SameValue(stored[field], value) then
      return false
    end
  end
  for field in pairs(stored) do
    if field ~= "changed" and state[field] == nil then
      return false
    end
  end
  return true
end

-- Writes produced states into allstates and hides the shown clones that were not produced again.
-- Out of combat a state equal to the stored one is left alone; in combat values may hide behind
-- secrets, so every produced state counts as changed.
local function CommitStates(allstates, produced)
  local changed = false
  for key, state in pairs(allstates) do
    if not produced[key] and state.show then
      state.show = false
      state.changed = true
      changed = true
    end
  end
  local inCombat = InCombatLockdown() == true
  for key, state in pairs(produced) do
    if inCombat or not SameState(allstates[key], state) then
      allstates[key] = state
      changed = true
    end
  end
  return changed
end
CooldownViewer.CommitStates = CommitStates

---------------------------------------------------------------------------------------------------
-- Several queries in one trigger
---------------------------------------------------------------------------------------------------

-- Clone key of a state produced by a query of a list.
local function MergeKey(query, state, selection)
  if CooldownViewer.KindOf(query.event) == "buff" then
    if query.cdmExact then
      return "id:" .. CooldownViewer.Trim(query.cdmSpell)
    end
    local name = type(selection.buffName) == "string" and selection.buffName or query.cdmSpell
    return "name:" .. name:lower()
  end
  return tostring(state.cooldownID or "preview") .. ":" .. tostring(state.spellId or query.cdmSpell)
end

-- Visible states of a query list; index is the rank of the query, the first state of a key wins.
local function MergeQueries(queries, event)
  local merged = {}
  for rank, query in ipairs(queries) do
    local selection = Private.ResolveCDMSpell(query, event)
    for _, state in pairs(ComposeStates(selection, RequestFromQuery(query, event))) do
      local key = MergeKey(query, state, selection)
      if not merged[key] then
        state.index = rank
        merged[key] = state
      end
    end
  end
  return merged
end
CooldownViewer.MergeQueries = MergeQueries

---------------------------------------------------------------------------------------------------
-- Buff filters
---------------------------------------------------------------------------------------------------

-- Pending wake-up timer per allstates, so a threshold crossed later refreshes the trigger.
local wakeTimers = setmetatable({}, { __mode = "k" })

-- Replaces the wake-up timer of allstates; no delay cancels it.
local function ScheduleWake(allstates, delay)
  local previous = wakeTimers[allstates]
  if previous and previous.Cancel then
    previous:Cancel()
  end
  wakeTimers[allstates] = nil
  if not delay then
    return
  end
  if C_Timer.NewTimer then
    wakeTimers[allstates] = C_Timer.NewTimer(delay + WAKE_MARGIN, Private.QueueCDMRefresh)
  else
    local token = {}
    wakeTimers[allstates] = token
    C_Timer.After(delay + WAKE_MARGIN, function()
      if wakeTimers[allstates] == token then
        Private.QueueCDMRefresh()
      end
    end)
  end
end

-- Readable value of a filtered field of a state.
local FILTER_READERS = {
  remaining = CooldownViewer.ReadRemaining,
  total = CooldownViewer.ReadTotal,
  stacks = function(state) return IsReadableNumber(state.stacks) and state.stacks or nil end,
  elapsed = function(state)
    local total, remaining = CooldownViewer.ReadTotal(state), CooldownViewer.ReadRemaining(state)
    return total and remaining and total - remaining or nil
  end,
}

-- Real seconds until a time filter changes its answer, or nil.
local function SecondsToThreshold(field, value, threshold, state)
  local delay
  if field == "remaining" then
    delay = value - threshold
  elseif field == "elapsed" then
    delay = threshold - value
  end
  return delay and delay > 0 and delay * CooldownViewer.TimeScale(state) or nil
end

-- Keeps the raw states of an active aura whose values pass every active filter. A missing,
-- permanent or secret value fails its filter.
function Private.ExecEnv.UpdateCDMBuffFilters(allstates, rawStates, event, remaining, op, stacks, stackOp, total,
                                              totalOp, elapsed, elapsedOp)
  if event == "OPTIONS" then
    ScheduleWake(allstates, nil)
    return CommitStates(allstates, rawStates)
  end
  local filters, invalid = {}, false
  for field, setting in pairs({
    remaining = { remaining, op }, stacks = { stacks, stackOp }, total = { total, totalOp }, elapsed = { elapsed, elapsedOp },
  }) do
    -- An enabled filter carries a value; without a usable value or operator it matches nothing.
    local threshold, compare = tonumber(setting[1]), OPERATORS[setting[2]]
    if threshold and compare then
      filters[#filters + 1] = { field = field, threshold = threshold, compare = compare }
    elseif setting[1] ~= nil and setting[1] ~= "" then
      invalid = true
    end
  end

  if invalid then
    ScheduleWake(allstates, nil)
    return CommitStates(allstates, {})
  end
  local kept, wake = {}, nil
  for key, state in pairs(rawStates) do
    local passes = state.auraActive == true or not filters[1]
    for _, filter in ipairs(filters) do
      local value = FILTER_READERS[filter.field](state)
      passes = passes and value ~= nil and filter.compare(value, filter.threshold)
      if value ~= nil then
        local delay = SecondsToThreshold(filter.field, value, filter.threshold, state)
        if delay and (not wake or delay < wake) then
          wake = delay
        end
      end
    end
    if passes then
      kept[key] = state
    end
  end
  ScheduleWake(allstates, wake)
  return CommitStates(allstates, kept)
end

---------------------------------------------------------------------------------------------------
-- Public composition entry points
---------------------------------------------------------------------------------------------------

-- States of a selection with positional display settings.
function Private.UpdateCooldownViewerStates(allstates, selected, event, showGCD, track, hideGCDText, showMode, exactID,
                                            requireTarget, ignoreSpellKnown)
  local request = NewRequest(event, showGCD, track, hideGCDText, showMode, exactID, requireTarget, ignoreSpellKnown)
  return CommitStates(allstates, ComposeStates(selected, request))
end
Private.ExecEnv.UpdateCooldownViewerStates = Private.UpdateCooldownViewerStates

-- States of one free-text spell config.
function Private.ExecEnv.UpdateCDMSpell(allstates, config, event)
  return CommitStates(allstates, ComposeQuery(config, event))
end

-- States of a query list merged into one set of clones.
function Private.ExecEnv.UpdateCDMSelectionList(allstates, queries, event)
  return CommitStates(allstates, MergeQueries(queries, event))
end

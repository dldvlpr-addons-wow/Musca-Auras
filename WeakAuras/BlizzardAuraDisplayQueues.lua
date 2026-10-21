-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local APPLY_BUDGET_MS = Shared.APPLY_BUDGET_MS
local ApplyIsolated = Shared.ApplyIsolated
local EDITOR_APPLY_BATCH = Shared.EDITOR_APPLY_BATCH
local EDITOR_BATCH_SIZE = Shared.EDITOR_BATCH_SIZE
local Instances = Shared.Instances
local LOGIN_POLL_SECONDS = Shared.LOGIN_POLL_SECONDS
local PendingSet = Shared.PendingSet
local Queues = Shared.Queues
local Units = Shared.Units
local queuedApplies = Shared.queuedApplies

Queues.instanceRegions = {}
Queues.unprepared = {}
Queues.editorPending = setmetatable({}, { __mode = "k" })

function Queues.ApplyPass()
  if WeakAuras.IsRestricted() then
    Queues.applying = false
    return
  end
  if not WeakAuras.IsLoginFinished() then
    C_Timer.After(LOGIN_POLL_SECONDS, Queues.ApplyPass)
    return
  end
  local startedAt = debugprofilestop()
  while true do
    local auraRegion, auraData = next(queuedApplies)
    if auraRegion == nil then break end
    queuedApplies[auraRegion] = nil
    local entry = Private.regions[auraData.id]
    if WeakAuras.GetData(auraData.id) == auraData and entry and entry.region == auraRegion then
      ApplyIsolated(auraRegion, auraData)
      if debugprofilestop() - startedAt >= APPLY_BUDGET_MS then break end
    end
  end
  if next(queuedApplies) ~= nil then
    C_Timer.After(0, Queues.ApplyPass)
  else
    Queues.applying = false
  end
end

function Queues.StartApplies()
  if Queues.applying or next(queuedApplies) == nil then return end
  Queues.applying = true
  Queues.ApplyPass()
end

local prepareId
local function EnsureAndRelease()
  local auraRegion = Private.EnsureRegion(prepareId)
  if auraRegion and Private.loaded[prepareId] == false then Display.Release(auraRegion) end
end

function Queues.PreparePass()
  if WeakAuras.IsRestricted() then
    Queues.preparing = false
    return
  end
  if not WeakAuras.IsLoginFinished() then
    C_Timer.After(LOGIN_POLL_SECONDS, Queues.PreparePass)
    return
  end
  local startedAt = debugprofilestop()
  local pending = Queues.unprepared
  while true do
    local id = next(pending)
    if id == nil then break end
    pending[id] = nil
    local auraData = WeakAuras.GetData(id)
    if auraData and Display.Enabled(auraData) and Private.loaded[id] == false
      and not WeakAuras.GetRegion(id) and not WeakAuras.IsOptionsOpen() then
      prepareId = id
      xpcall(EnsureAndRelease, geterrorhandler())
      if debugprofilestop() - startedAt >= APPLY_BUDGET_MS then break end
    end
  end
  if next(pending) ~= nil then
    C_Timer.After(0, Queues.PreparePass)
  else
    Queues.preparing = false
  end
end

function Queues.StartPreparing()
  if Queues.preparing or next(Queues.unprepared) == nil then return end
  Queues.preparing = true
  Queues.PreparePass()
end

function Queues.EditorPass()
  local pending = Queues.editorPending
  local applied = 0
  for _, auraRegion in ipairs(PendingSet(pending)) do
    if applied >= EDITOR_APPLY_BATCH then break end
    local auraData = pending[auraRegion]
    pending[auraRegion] = nil
    local entry = auraData and Private.regions[auraData.id]
    if entry and entry.region == auraRegion and (WeakAuras.GetData(auraData.id) or auraData) == auraData and Display.Enabled(auraData) then
      applied = applied + 1
      ApplyIsolated(auraRegion, auraData)
    end
  end
  if next(pending) ~= nil then
    C_Timer.After(0, Queues.EditorPass)
  else
    Queues.editorDraining = false
  end
end

function Queues.InstancePass()
  local pending = Queues.instanceRegions
  for _, auraRegion in ipairs(PendingSet(pending)) do
    local state = auraRegion.blizzardAuraDisplay
    local queue = state and state.instanceQueue
    if not queue or not state.active or state.data ~= queue.data then
      pending[auraRegion] = nil
    elseif WeakAuras.IsRestricted() then
      state.instanceQueue = nil
      pending[auraRegion] = nil
      queuedApplies[auraRegion] = queue.data
    else
      local total = #state.instances
      local last = math.min(queue.nextIndex + EDITOR_BATCH_SIZE - 1, total)
      for position = queue.nextIndex, last do
        Instances.Configure(auraRegion, state, position, state.instances[position], true)
      end
      if last >= total then
        state.instanceQueue = nil
        pending[auraRegion] = nil
        Units.Refresh(auraRegion)
      else
        queue.nextIndex = last + 1
      end
    end
  end
  if next(pending) ~= nil then
    C_Timer.After(0, Queues.InstancePass)
  else
    Queues.instanceDraining = false
  end
end

function Queues.StartInstanceDrain()
  if Queues.instanceDraining then return end
  Queues.instanceDraining = true
  C_Timer.After(0, Queues.InstancePass)
end

function Display.CancelEditorApply(auraRegion)
  Queues.editorPending[auraRegion] = nil
end

Private.callbacks:RegisterCallback("Add", function(_, _, id, auraData)
  if Display.Enabled(auraData) then
    Queues.unprepared[id] = true
    Queues.StartPreparing()
  end
end)

Private.callbacks:RegisterCallback("RestrictionChanged", function(_, isRestricted)
  if not isRestricted then
    Queues.StartApplies()
    Queues.StartPreparing()
  end
end)

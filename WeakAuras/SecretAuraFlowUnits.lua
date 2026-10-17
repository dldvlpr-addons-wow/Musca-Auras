-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Anchoring of the containers of a framed modern group (unit frames or nameplates). For every
-- unit, the shadows are chained first, then the containers: the first one hangs on the last shadow
-- or on the frame of the unit, each next one on the previous container of the same unit.
-- A container that combat locks, or that the client refuses, defers the whole group.

local AuraDisplay = Private.BlizzardAuraDisplay
local Anchor = Private.AuraAnchor
local Flow = Private.AuraFlow

-- Tries each target in turn: { relativeTo, relativePoint, x, y }. True once one is accepted, false
-- when every one was refused, nil when there was nothing to anchor on.
local function AnchorOnFirst(hostFrame, point, targets)
  for _, target in ipairs(targets) do
    local status = Anchor.Attach(hostFrame, point, target[1], target[2], target[3], target[4])
    if status == "ok" then return true end
  end
  if #targets > 0 then return false end
  return nil
end

local function VisibleInstances(groupData)
  local instances = {}
  for _, child in ipairs(Flow.ActiveChildren(groupData)) do
    for _, instance in ipairs(child.native.instances or {}) do
      if instance.visible and instance.boundUnit then instances[#instances + 1] = instance end
    end
  end
  return instances
end

function AuraDisplay.RelinkFlowUnits(groupData)
  if not groupData then return end
  local modern = Flow.Describe(groupData)
  if not modern.mode then return end
  if Flow.batch then return Flow.NoteBatch(groupData) end

  local drawn, shadowGrowth = modern.growth.visible, modern.growth.shadow
  local selfPoint, anchorPoint, x, y = Anchor.GroupPosition(groupData)
  local isDeferred = false
  local instances = VisibleInstances(groupData)
  local previousShadow, previous = {}, {}

  local function Anchored(hostFrame, point, targets)
    if Anchor.Locked(hostFrame) then
      isDeferred = true
      return
    end
    hostFrame:ClearAllPoints()
    if AnchorOnFirst(hostFrame, point, targets) == false then isDeferred = true end
  end

  if shadowGrowth then
    local startPoint, frontPoint = shadowGrowth:Aligned(selfPoint, false), shadowGrowth:Aligned(selfPoint, true)
    local overlapX, overlapY = shadowGrowth:Overlap()
    for _, instance in ipairs(instances) do
      local shadow, unit = instance.flowShadow, instance.boundUnit
      if instance.flowShadowActive and shadow then
        local targets = {}
        if previousShadow[unit] then
          targets[1] = { previousShadow[unit], frontPoint, overlapX, overlapY }
        end
        local hostFrame = Anchor.Find(modern.mode, unit)
        if hostFrame then targets[#targets + 1] = { hostFrame, anchorPoint, x, y } end
        Anchored(shadow, startPoint, targets)
        previousShadow[unit] = shadow
      end
    end
  end

  local startPoint, frontPoint = drawn:Aligned(selfPoint, false), drawn:Aligned(selfPoint, true)
  local overlapX, overlapY = drawn:Overlap()
  for _, instance in ipairs(instances) do
    local auraContainer, unit = instance.container, instance.boundUnit
    local targets = {}
    if previous[unit] then
      targets[1] = { previous[unit], frontPoint, overlapX, overlapY }
    end
    if previousShadow[unit] then
      local shadowX, shadowY = shadowGrowth:Overlap()
      local stepX, stepY = drawn:Step(modern.spacing / 2)
      targets[#targets + 1] = { previousShadow[unit], shadowGrowth:Aligned(selfPoint, true), shadowX + stepX, shadowY + stepY }
    end
    local hostFrame = Anchor.Find(modern.mode, unit)
    if hostFrame then targets[#targets + 1] = { hostFrame, anchorPoint, x, y } end
    Anchored(auraContainer, startPoint, targets)
    previous[unit] = auraContainer
  end
  if isDeferred then Flow.Defer(groupData) end
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Modern aura groups: the settings of a group read once into a descriptor (growth, spacing, frame
-- mode, limit), the native containers of a region (container, start and end of its flow), and the
-- single scheduler that chains the regions of a group and replays what combat refused.
-- The shadows, per-unit anchoring, grid and editor preview live in SecretAuraFlow{Shadow,Units,
-- Grid,Preview}.lua and register in Private.AuraFlow, which this file creates.

local AuraDisplay = Private.BlizzardAuraDisplay
local Anchor = Private.AuraAnchor
local Flow = {}
Private.AuraFlow = Flow

local FRAMED_MODES = { UNITFRAME = true, NAMEPLATE = true }
local DEFAULT_SPACING = 2
local DEFAULT_LIMIT = 20
local DEFAULT_LIMIT_WHEN_ENABLED = 5
local BASE_TEMPLATE = "CustomAuraContainerTemplate"
local LOCKED_TEMPLATE = BASE_TEMPLATE .. ", DisableUntrustedLayoutScriptsTemplate"
local ANCHOR_TEMPLATE = "DisableUntrustedLayoutScriptsTemplate"

AuraDisplay.flowGrowths = {
  RIGHT = "Right",
  LEFT = "Left",
  DOWN = "Down",
  UP = "Up",
  CENTER_HORIZONTAL = "Centered Horizontal",
  CENTER_VERTICAL = "Centered Vertical",
}

do
  local names = { R = "Right", L = "Left", D = "Down", U = "Up" }
  AuraDisplay.flowGridTypes = {}
  for head in ("RLDU"):gmatch(".") do
    local seconds = (head == "R" or head == "L") and "DU" or "RL"
    for second in seconds:gmatch(".") do
      AuraDisplay.flowGridTypes[head .. second] = names[head] .. ", then " .. names[second]
    end
  end
end

AuraDisplay.UnitAnchor = Anchor.UnitAnchor

-----------------------------------------------------------------------------------------------
-- Scheduler: ordered queues without duplicates

local Queue = {}
Queue.__index = Queue

function Queue.New() return setmetatable({ order = {}, seen = {} }, Queue) end

function Queue:Push(key)
  if self.seen[key] then return false end
  self.seen[key] = true
  self.order[#self.order + 1] = key
  return true
end

function Queue:Drain()
  local order = self.order
  self.order, self.seen = {}, {}
  return order
end

Flow.Queue = Queue

local burst, burstPending = Queue.New(), false
local deferred = Queue.New()
local retired = Queue.New()
local staleChildren, staleOwners, stalePending = Queue.New(), {}, false

local function Report(callback)
  xpcall(callback, geterrorhandler())
end

local function GroupFor(key)
  if type(key) == "table" then return key end
  return WeakAuras.GetData(key)
end

-- A group the combat lockdown refused to lay out is chained again when the lockdown ends.
function Flow.Defer(groupData)
  deferred:Push(groupData.id or groupData)
end

function Flow.RetireLater(hostFrame)
  retired:Push(hostFrame)
end

local function IsInCombat()
  return InCombatLockdown() and true or false
end

local function ReplayDeferred()
  if IsInCombat() then return end
  for _, key in ipairs(deferred:Drain()) do
    local groupData = GroupFor(key)
    if groupData then Report(function() Flow.Chain(groupData) end) end
  end
end

-----------------------------------------------------------------------------------------------
-- Group settings

local Modern = {}
Modern.__index = Modern

function Modern:Limit()
  local groupData = self.group
  if not groupData.blizzardFlowUseLimit then return DEFAULT_LIMIT end
  local limit = tonumber(groupData.blizzardFlowLimit)
  return limit and math.max(1, math.floor(limit)) or DEFAULT_LIMIT_WHEN_ENABLED
end

function Flow.Describe(groupData)
  local mode = FRAMED_MODES[groupData.blizzardFlowFrames] and groupData.blizzardFlowFrames or nil
  local growth = Anchor.GrowthFor(groupData.blizzardFlowGrowth)
  if mode then growth = growth:Pin(groupData.selfPoint or "CENTER") end
  return setmetatable({
    group = groupData,
    mode = mode,
    growth = growth,
    spacing = tonumber(groupData.blizzardFlowSpacing) or DEFAULT_SPACING,
  }, Modern)
end

local function GroupOf(auraData)
  local parentGroup = auraData and auraData.parent and WeakAuras.GetData(auraData.parent)
  if parentGroup and parentGroup.blizzardFlow and parentGroup.regionType == "group" then
    return parentGroup
  end
end
AuraDisplay.FlowGroup = GroupOf

function Flow.Modern(auraData)
  local groupData = GroupOf(auraData)
  return groupData and Flow.Describe(groupData) or nil
end

function AuraDisplay.FlowFrameMode(auraData)
  local modern = Flow.Modern(auraData)
  return modern and modern.mode or nil
end

function AuraDisplay.FlowGrowth(auraData)
  local modern = Flow.Modern(auraData)
  if modern then return modern.growth.key, modern.spacing end
end

function AuraDisplay.VisibleGrowth(key)
  local growth = Anchor.Growths[key]
  return growth and growth.visible.key or key
end

function AuraDisplay.FlowLimit(auraData)
  local modern = Flow.Modern(auraData)
  return modern and modern:Limit() or nil
end

function AuraDisplay.FrameAnchorType(auraData)
  local modern = Flow.Modern(auraData)
  if modern then return modern.mode or "SCREEN" end
  return auraData.anchorFrameType
end

function AuraDisplay.SortOrder(auraData, auraTrigger)
  local groupData = GroupOf(auraData)
  local source = groupData and { groupData.blizzardFlowSort, groupData.blizzardFlowReverse }
    or { auraTrigger and auraTrigger.sortMethod, auraTrigger and auraTrigger.sortReverse }
  local method = source[1]
  if not (method and AuraDisplay.sortMethods[method]) or method == "UnitFrameDebuff" then method = "Default" end
  local direction = source[2] and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal
  return AuraContainerSortMethod[method], direction
end

-----------------------------------------------------------------------------------------------
-- Why a display cannot live in a modern group

local PROBLEMS = {
  notIcon = "Modern aura groups only hold Icon or Progress Bar displays.",
  remaining = "Remaining Time is not available yet inside a modern aura group.",
  single = "A group framed on unit frames or nameplates cannot show \"Always\" or \"Missing\": use \"Aura(s) Found\".",
  nameplate = "Framed on nameplates: choose the Nameplate unit in the trigger.",
  unitFrame = "Framed on unit frames: choose a unit other than Nameplate in the trigger.",
  grid = "This aura cannot be drawn in the group grid, so it keeps its own container outside it.",
}
Flow.problems = PROBLEMS

-- Checked in order. A rule answers a problem key, false to stop looking, or nothing to go on.
local PROBLEM_RULES = {
  function(auraData)
    if auraData.regionType ~= "icon" and auraData.regionType ~= "aurabar" then return "notIcon" end
  end,
  function(_, auraTrigger)
    if AuraDisplay.RemainingWindow(auraTrigger) then return "remaining" end
  end,
  function(_, _, modern)
    if not modern.mode then return false end
  end,
  function(_, auraTrigger)
    if AuraDisplay.IsSingle(auraTrigger) then return "single" end
  end,
  function(_, auraTrigger, modern)
    if modern.mode == "NAMEPLATE" and auraTrigger.unit ~= "nameplate" then return "nameplate" end
  end,
  function(_, auraTrigger, modern)
    if modern.mode == "UNITFRAME" and auraTrigger.unit == "nameplate" then return "unitFrame" end
  end,
}

function AuraDisplay.FlowProblem(auraData, auraTrigger)
  local modern = Flow.Modern(auraData)
  if not modern then return nil end
  for _, rule in ipairs(PROBLEM_RULES) do
    local verdict = rule(auraData, auraTrigger, modern)
    if verdict == false then return nil end
    if verdict then return PROBLEMS[verdict] end
  end
  return nil
end

-----------------------------------------------------------------------------------------------
-- Containers and the start and end of a region's flow

function AuraDisplay.CreateAuraContainer(parentGroup, auraData)
  if Flow.Modern(auraData) then
    local isCreated, auraContainer = pcall(CreateFrame, "AuraContainer", nil, parentGroup, LOCKED_TEMPLATE)
    if isCreated then return auraContainer, true end
  end
  return CreateFrame("AuraContainer", nil, parentGroup, BASE_TEMPLATE), false
end

function AuraDisplay.ContentAnchor(childRegion)
  local nativeDisplay = childRegion.blizzardAuraDisplay
  return nativeDisplay and nativeDisplay.flow and nativeDisplay.flow.start or childRegion
end

function AuraDisplay.AnchorToContent(auraContainer, point, childRegion, relativePoint, x, y)
  local content = AuraDisplay.ContentAnchor(childRegion)
  local status = Anchor.Attach(auraContainer, point, content, relativePoint, x, y, childRegion)
  return status == "ok" or (status == "fallback" and content == childRegion)
end

function AuraDisplay.EnsureFlowStart(childRegion, auraData)
  local nativeDisplay = childRegion.blizzardAuraDisplay
  local modern = Flow.Modern(auraData)
  local flow = nativeDisplay.flow
  if not modern then
    if flow and flow.start then flow.start:Hide() end
    nativeDisplay.flow = nil
    return
  end
  if not flow then
    flow = {}
    nativeDisplay.flow = flow
  end
  local startFrame = flow.start
  if not startFrame then
    startFrame = CreateFrame("Frame", nil, childRegion, ANCHOR_TEMPLATE)
    startFrame:EnableMouse(false)
    flow.start = startFrame
  end
  startFrame:SetSize(AuraDisplay.Dimensions(auraData))
  startFrame:Show()
  flow.growth = modern.growth
  local point = modern.growth:StartPoint()
  startFrame:ClearAllPoints()
  startFrame:SetPoint(point, childRegion, point)
end

local function SetEnd(flow, hostFrame, point, x, y)
  flow.endFrame, flow.endPoint, flow.x, flow.y = hostFrame, point, x, y
end

-- Where the next region of the group starts: behind the absence marker, behind the last
-- container of a found aura, or one element further than the start of an empty region.
function AuraDisplay.SetFlowEnd(childRegion, auraData, presence)
  local nativeDisplay = childRegion.blizzardAuraDisplay
  local flow = nativeDisplay.flow
  local modern = Flow.Modern(auraData)
  if not (flow and modern) then return end
  local growth = modern.growth
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local instances = nativeDisplay.instances or {}
  local showOn = auraTrigger and AuraDisplay.ShowOn(auraTrigger)
  local isFound = showOn == "showOnActive"
  local isAbsent = showOn == "showOnMissing" or showOn == "showAlways"
  if presence and isAbsent then
    SetEnd(flow, presence, growth:StartPoint(), 0, 0)
  elseif isFound and not AuraDisplay.UsesGate(auraData) and #instances > 0 then
    SetEnd(flow, instances[#instances].container, growth:FrontPoint(), growth:Overlap())
  else
    local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
    SetEnd(flow, flow.start, growth:StartPoint(), growth:Step(iconWidth + modern.spacing, iconHeight + modern.spacing))
  end
end

function AuraDisplay.FlowPresenceSize(auraData)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local modern = Flow.Modern(auraData)
  if modern then
    if modern.growth:IsHorizontal() then iconWidth = iconWidth + modern.spacing + 1 else iconHeight = iconHeight + modern.spacing + 1 end
  end
  return { elementWidth = iconWidth, elementHeight = iconHeight }
end

function AuraDisplay.AnchorFlowPresence(childRegion, auraData, auraContainer)
  local flow = childRegion.blizzardAuraDisplay and childRegion.blizzardAuraDisplay.flow
  local modern = Flow.Modern(auraData)
  if not (flow and modern) then return false end
  local size = AuraDisplay.FlowPresenceSize(auraData)
  return Anchor.Behind(auraContainer, modern.growth, flow.start, size.elementWidth, size.elementHeight, childRegion)
end

-----------------------------------------------------------------------------------------------
-- Children of a group

-- Active native regions of the group, in the order of the group.
function Flow.ActiveChildren(groupData)
  local children = {}
  for _, id in ipairs(groupData.controlledChildren or {}) do
    local registration = Private.regions[id]
    local childRegion = registration and registration.region
    local nativeDisplay = childRegion and childRegion.blizzardAuraDisplay
    if nativeDisplay and nativeDisplay.active then
      children[#children + 1] = { id = id, region = childRegion, native = nativeDisplay }
    end
  end
  return children
end

-----------------------------------------------------------------------------------------------
-- Chaining

-- A region whose growth is not the one of the group anymore is built again, once, on the next tick.
local function RebuildStale()
  stalePending = false
  for _, childId in ipairs(staleChildren:Drain()) do
    local owner = staleOwners[childId]
    staleOwners[childId] = nil
    if InCombatLockdown() then
      if owner then Flow.Defer(owner) end
    else
      local auraData = WeakAuras.GetData(childId)
      local modern = auraData and Flow.Modern(auraData)
      local registration = modern and Private.regions[childId]
      local flow = registration and registration.region and registration.region.blizzardAuraDisplay
      flow = flow and flow.flow
      if flow and flow.growth ~= modern.growth then Report(function() WeakAuras.Add(auraData) end) end
    end
  end
end

local function ScheduleStale(groupData, modern)
  if IsInCombat() then return end
  for _, child in ipairs(Flow.ActiveChildren(groupData)) do
    local flow = child.native.flow
    if flow and flow.growth ~= modern.growth and staleChildren:Push(child.id) then
      staleOwners[child.id] = groupData
      if not stalePending then
        stalePending = true
        C_Timer.After(0, RebuildStale)
      end
    end
  end
end

-- Where the shadow of a region ends: the frame, its point, and the offset of the next element.
local function ShadowEnd(flow, shadowGrowth)
  local shadows = flow.shadowKind == "list" and flow.shadowList
  if shadows and #shadows > 0 then
    local overlapX, overlapY = shadowGrowth:Overlap()
    return shadows[#shadows], shadowGrowth:FrontPoint(), overlapX, overlapY
  end
  if flow.shadowKind == "missing" then
    local first = flow.native.instances and flow.native.instances[1]
    local absent = first and first.single and first.single.missing
    if absent and absent.flowShadow then
      return absent.flowShadow, shadowGrowth:StartPoint(), 0, 0
    end
  end
  return flow.shadowStart, shadowGrowth:StartPoint(), shadowGrowth:Step(flow.half or 0)
end

-- Starts the shadows at the center of the first region and puts every next one behind the shadow
-- before it. Returns the end of the last shadow.
local function ChainShadows(flows, growth)
  local shadowGrowth = growth.shadow
  local point, front = shadowGrowth:StartPoint(), shadowGrowth:FrontPoint()
  local overlapX, overlapY = shadowGrowth:Overlap()
  local last
  for _, link in ipairs(flows) do
    if link.shadowStart then
      if last then
        local hostFrame, endPoint, x, y = ShadowEnd(last, shadowGrowth)
        Anchor.Attach(link.shadowStart, point, hostFrame, endPoint, x, y, link.region, point)
      else
        Anchor.Attach(link.shadowStart, point, link.region, growth.centerPoint, 0, 0, link.region, point)
      end
      if link.shadowKind == "list" then
        local before = link.shadowStart
        for slot, shadow in ipairs(link.shadowList or {}) do
          if slot == 1 then
            Anchor.Attach(shadow, point, before, point, 0, 0, link.region, point)
          else
            Anchor.Attach(shadow, point, before, front, overlapX, overlapY, link.region, point)
          end
          before = shadow
        end
      end
      last = link
    end
  end
  if last then return ShadowEnd(last, shadowGrowth) end
end

local function ChainRegions(groupData, modern)
  local flows = {}
  for _, child in ipairs(Flow.ActiveChildren(groupData)) do
    local flow = child.native.flow
    if not child.native.gridMember and flow and flow.endFrame and flow.growth == modern.growth then
      flow.region, flow.native = child.region, child.native
      flows[#flows + 1] = flow
    end
  end
  local shadowFrame, shadowPoint, shadowX, shadowY
  if modern.growth.shadow then
    shadowFrame, shadowPoint, shadowX, shadowY = ChainShadows(flows, modern.growth)
  end
  local point = modern.growth:StartPoint()
  for slot, flow in ipairs(flows) do
    local previous = flows[slot - 1]
    if previous then
      Anchor.Attach(flow.start, point, previous.endFrame, previous.endPoint, previous.x, previous.y, flow.region, point)
    elseif shadowFrame then
      local stepX, stepY = modern.growth:Step(modern.spacing / 2)
      Anchor.Attach(flow.start, point, shadowFrame, shadowPoint, shadowX + stepX, shadowY + stepY, flow.region, point)
    else
      Anchor.Attach(flow.start, point, flow.region, point, 0, 0, flow.region, point)
    end
  end
end

function Flow.Chain(groupData)
  Flow.UpdateGrid(groupData, true)
  if InCombatLockdown() then Flow.Defer(groupData) end
  local modern = Flow.Describe(groupData)
  if modern.mode then
    ScheduleStale(groupData, modern)
    AuraDisplay.RelinkFlowUnits(groupData)
    return
  end
  if IsInCombat() then return end
  ChainRegions(groupData, modern)
end

local function RunBurst()
  burstPending = false
  for _, id in ipairs(burst:Drain()) do
    local groupData = WeakAuras.GetData(id)
    if groupData then Report(function() Flow.Chain(groupData) end) end
  end
end

function AuraDisplay.RechainFlow(groupData)
  if not groupData then return end
  if not groupData.id then return Flow.Chain(groupData) end
  burst:Push(groupData.id)
  if not burstPending then
    burstPending = true
    C_Timer.After(0, RunBurst)
  end
end

-----------------------------------------------------------------------------------------------
-- Batches: the units of a group are linked once when a run of changes ends

function AuraDisplay.BeginFlowBatch()
  if Flow.batch then return end
  Flow.batch = { groups = Queue.New(), dropped = {} }
end

function Flow.NoteBatch(groupData, droppedUnit)
  local batch = Flow.batch
  batch.groups:Push(groupData)
  batch.dropped[groupData] = droppedUnit or batch.dropped[groupData] or true
end

function AuraDisplay.EndFlowBatch()
  local batch = Flow.batch
  if not batch then return end
  Flow.batch = nil
  for _, groupData in ipairs(batch.groups:Drain()) do
    local droppedUnit = batch.dropped[groupData]
    AuraDisplay.RefreshFlowUnits(groupData, droppedUnit ~= true and droppedUnit or nil)
  end
end

function AuraDisplay.RefreshFlowUnits(groupData, droppedUnit)
  if not groupData then return end
  if Flow.batch then return Flow.NoteBatch(groupData, droppedUnit) end
  AuraDisplay.RelinkFlowUnits(groupData)
  Flow.UpdateGrid(groupData, false, droppedUnit)
end

-----------------------------------------------------------------------------------------------
-- End of combat

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
watcher:SetScript("OnEvent", function()
  for _, hostFrame in ipairs(retired:Drain()) do AuraDisplay.RetireFrame(hostFrame) end
  ReplayDeferred()
end)

Private.callbacks:RegisterCallback("RestrictionChanged", ReplayDeferred)

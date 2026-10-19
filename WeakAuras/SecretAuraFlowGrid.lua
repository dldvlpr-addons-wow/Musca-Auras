-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Grid of a modern group. The eligible children of the group share one native container per unit,
-- and the container wraps its lines by itself. A grid is built once for a signature (members, units,
-- type, spacing, anchor), then only refreshed, which is also allowed in combat.
-- Registers in Private.AuraFlow and Display.

local AuraDisplay = Private.BlizzardAuraDisplay
local Anchor = Private.AuraAnchor
local Flow = Private.AuraFlow

local KEY_PREFIX = "MuscaGrid"
local WARNING_KEY = "blizzard_aura_grid"
local DEFAULT_PER_ROW = 6
local LINE_MARGIN = 0.5
local LETTER_GROWTH = { R = "RIGHT", L = "LEFT", D = "DOWN", U = "UP" }

local grids = {}

local function IsRestricted()
  return WeakAuras.IsRestricted() or InCombatLockdown()
end

local function IsPreview()
  return not InCombatLockdown() and WeakAuras.IsOptionsOpen()
end

-----------------------------------------------------------------------------------------------
-- Type and membership

function AuraDisplay.GridType(groupData)
  local explicit = groupData.blizzardFlowGridType
  if explicit and AuraDisplay.flowGridTypes[explicit] then return explicit end
  return Anchor.GrowthFor(groupData.blizzardFlowGrowth):GridType()
end

-- Why a display cannot be drawn in the grid, nil when it can.
local function Exclusion(auraData, auraTrigger)
  if not auraTrigger or AuraDisplay.IsSingle(auraTrigger, auraData) or AuraDisplay.UsesGate(auraData)
    or AuraDisplay.RemainingWindow(auraTrigger) then
    return true
  end
  local options = auraData.blizzardAuraDisplay
  return (options and options.unitGlow) and true or false
end

function AuraDisplay.GridMember(auraData)
  local groupData = AuraDisplay.FlowGroup(auraData)
  local function Report(severity, message)
    Private.AuraWarnings.UpdateWarning(auraData.uid, WARNING_KEY, severity, message)
  end
  if not (groupData and groupData.blizzardFlowGrid) then
    Report(nil, nil)
    return false
  end
  if Exclusion(auraData, AuraDisplay.GetTrigger(auraData)) then
    Report("warning", Flow.problems.grid)
    return false
  end
  Report(nil, nil)
  return true
end

-----------------------------------------------------------------------------------------------
-- Shape of the grid

-- X is the direction of a line, Y the direction in which new lines are added.
local function Shape(gridType)
  local line = Anchor.Growths[LETTER_GROWTH[gridType:sub(1, 1)]]
  local row = Anchor.Growths[LETTER_GROWTH[gridType:sub(2, 2)]]
  local signX = line.signX ~= 0 and line.signX or row.signX
  local signY = line.signY ~= 0 and line.signY or row.signY
  local directions = AnchorUtil.FlowDirection
  return {
    line = line,
    row = row,
    corner = (signY < 0 and "TOP" or "BOTTOM") .. (signX > 0 and "LEFT" or "RIGHT"),
    horizontal = signX < 0 and directions.Left or directions.Right,
    vertical = signY > 0 and directions.Up or directions.Down,
  }
end

local function PerRow(groupData)
  local count = tonumber(groupData.blizzardFlowPerRow)
  return count and math.max(1, math.floor(count)) or DEFAULT_PER_ROW
end

-- Column space is the horizontal gap and row space the vertical one, whatever way the lines run.
-- Returns the gap between the elements of a line, then the gap between two lines.
local function Spacings(groupData, modern, shape)
  local columnSpace = tonumber(groupData.blizzardFlowColumnSpace) or modern.spacing
  local rowSpace = tonumber(groupData.blizzardFlowRowSpace) or modern.spacing
  if shape.line:IsHorizontal() then return columnSpace, rowSpace end
  return rowSpace, columnSpace
end

-- Read by the editor preview, which draws the same grid with sample buttons.
Flow.Grid = { Shape = Shape, PerRow = PerRow, Spacings = Spacings }

-----------------------------------------------------------------------------------------------
-- Members and signature

local function UnitsOf(member)
  local units = {}
  local auraTrigger = member.data and AuraDisplay.GetTrigger(member.data)
  for _, unit in ipairs(auraTrigger and AuraDisplay.UnitTokens(auraTrigger) or {}) do
    if type(unit) == "string" then units[#units + 1] = unit end
  end
  return units
end

-- A child that is not loaded keeps its place in a grid that already knew it.
local function Members(groupData, state)
  local members = {}
  if not (groupData.blizzardFlow and groupData.blizzardFlowGrid) then return members end
  for _, id in ipairs(groupData.controlledChildren or {}) do
    local registration = Private.regions[id]
    local childRegion = registration and registration.region
    local nativeDisplay = childRegion and childRegion.blizzardAuraDisplay
    if nativeDisplay then
      if nativeDisplay.gridMember then
        members[#members + 1] = { id = id, region = childRegion, native = nativeDisplay, data = nativeDisplay.data }
      end
    elseif state and state.memberIds[id] then
      members[#members + 1] = { id = id }
    end
  end
  for _, member in ipairs(members) do member.units = UnitsOf(member) end
  return members
end

local function Plan(groupData, modern, members)
  local gridType = AuraDisplay.GridType(groupData)
  local shape = Shape(gridType)
  local alongSpace, betweenSpace = Spacings(groupData, modern, shape)
  local selfPoint, anchorPoint, x, y = Anchor.GroupPosition(groupData)
  local parts = { groupData.id, modern.mode or "", gridType, PerRow(groupData), alongSpace, betweenSpace,
    selfPoint, anchorPoint, x, y }
  for slot, member in ipairs(members) do
    parts[#parts + 1] = slot .. ":" .. member.id .. ":" .. (member.native and member.native.generation or 0)
      .. ":" .. table.concat(member.units, ",")
  end
  return {
    shape = shape,
    perRow = PerRow(groupData),
    alongSpace = alongSpace,
    betweenSpace = betweenSpace,
    signature = table.concat(parts, "|"),
  }
end

-----------------------------------------------------------------------------------------------
-- Containers

local function SetGroupEnabled(unitState, key, isEnabled)
  local auraContainer = unitState.container
  if auraContainer.SetAuraGroupEnabled then pcall(auraContainer.SetAuraGroupEnabled, auraContainer, key, isEnabled) end
end

-- The buttons of a grid are also listed on the instance of the display, which styles them.
local function Share(kind)
  local shared = kind.instance and kind.instance.buttons
  if not shared then return end
  local listed = {}
  for _, auraButton in ipairs(shared) do listed[auraButton] = true end
  for _, auraButton in ipairs(kind.buttons) do
    if not listed[auraButton] then shared[#shared + 1] = auraButton end
  end
end

local function Detach(unitState)
  for _, kind in pairs(unitState.kinds) do
    local shared = kind.instance and kind.instance.buttons
    if shared then
      local own = {}
      for _, auraButton in ipairs(kind.buttons) do own[auraButton] = true end
      for slot = #shared, 1, -1 do
        if own[shared[slot]] then table.remove(shared, slot) end
      end
    end
    kind.buttons = {}
  end
end

local function Dispose(auraContainer)
  auraContainer:SetEnabled(false)
  auraContainer:Hide()
  if InCombatLockdown() then
    Flow.RetireLater(auraContainer)
  else
    AuraDisplay.RetireFrame(auraContainer)
  end
end

local function Park(state, unitState)
  for _, kind in pairs(unitState.kinds) do
    for _, buttonState in ipairs(kind.buttons) do
      local shown = buttonState.button
      if shown then
        shown:ClearAllPoints()
        shown:Hide()
      end
    end
  end
  for key in pairs(unitState.groups) do SetGroupEnabled(unitState, key, false) end
  unitState.anchored = nil
  Dispose(unitState.container)
  state.units[unitState.unit] = nil
  state.reserve[unitState.unit] = unitState
end

local function Purge(key)
  local state = grids[key]
  if not state then return end
  grids[key] = nil
  for _, unitState in pairs(state.units) do
    Detach(unitState)
    Dispose(unitState.container)
  end
  for _, unitState in pairs(state.reserve) do Detach(unitState) end
end

local function Acquire(state, unit, parentGroup, auraData)
  local unitState = state.units[unit]
  if unitState then return unitState end
  unitState = state.reserve[unit]
  state.reserve[unit] = nil
  if unitState and not pcall(unitState.container.SetParent, unitState.container, parentGroup) then
    Detach(unitState)
    unitState = nil
  end
  if not unitState then
    local auraContainer = AuraDisplay.CreateAuraContainer(parentGroup, auraData)
    auraContainer:SetEnabled(false)
    auraContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
    auraContainer:SetUnit(unit)
    unitState = { unit = unit, container = auraContainer, groups = {}, kinds = {}, live = {} }
  end
  state.units[unit] = unitState
  return unitState
end

local function ConfigureFlow(auraContainer, plan, lineSize)
  local shape = plan.shape
  auraContainer:SetFlowLayoutAxis(shape.line:Axis())
  auraContainer:SetFlowLayoutAnchorPoint(shape.corner)
  auraContainer:SetFlowLayoutGrowthDirection(shape.horizontal, shape.vertical)
  auraContainer:SetFlowLayoutMaximumLineSize(lineSize)
end

local function LineSize(plan, members)
  local isHorizontal = plan.shape.line:IsHorizontal()
  local size = 0
  for _, member in ipairs(members) do
    if member.data then
      local iconWidth, iconHeight = AuraDisplay.Dimensions(member.data)
      size = math.max(size, isHorizontal and iconWidth or iconHeight)
    end
  end
  return math.max(size, plan.perRow * size + (plan.perRow - 1) * plan.alongSpace) + LINE_MARGIN
end

-- Adds the aura group of member to the container of a unit, or updates the one it already has.
local function SetUpGroup(unitState, member, slot, position, plan)
  local auraContainer, auraData = unitState.container, member.data
  local auraTrigger = AuraDisplay.GetTrigger(auraData)
  local key = KEY_PREFIX .. (auraData.uid or member.id)
  local iconWidth, iconHeight = AuraDisplay.Dimensions(auraData)
  local layout = {
    elementWidth = iconWidth,
    elementHeight = iconHeight,
    elementSpacing = plan.alongSpace,
    lineSpacing = plan.betweenSpace,
    layoutIndex = slot,
  }
  local filter, candidateList, limit = AuraDisplay.FilterString(auraTrigger), AuraDisplay.CandidateFilters(auraData), AuraDisplay.MaxAuras(auraData)
  local method, direction = AuraDisplay.SortOrder(auraData, auraTrigger)

  local instance = member.native.instances and member.native.instances[position]
  if instance and not instance.buttons then instance.buttons = {} end
  local kind = unitState.kinds[member.id] or {}
  unitState.kinds[member.id] = kind
  kind.instance, kind.region, kind.native, kind.data = instance, member.region, member.native, auraData
  kind.buttons = kind.buttons or {}
  kind.wanted = kind.wanted or false
  Share(kind)

  if unitState.groups[key] then
    for _, buttonState in ipairs(kind.buttons) do AuraDisplay.StyleNative(buttonState, auraData, kind.region) end
    auraContainer:SetAuraGroupFilterString(key, filter)
    auraContainer:SetAuraGroupCandidateFilters(key, candidateList)
    auraContainer:SetAuraGroupMaxFrameCount(key, limit)
    auraContainer:SetAuraGroupLayout(key, layout)
    auraContainer:SetAuraGroupSortMethod(key, method, direction)
  else
    local isAdded = pcall(auraContainer.AddAuraGroup, auraContainer, key, filter, {
      maxFrameCount = limit,
      candidateFilters = candidateList,
      sortMethod = method,
      sortDirection = direction,
      layout = layout,
      initializeFrame = function(auraButton)
        AuraDisplay.SetupAuraButton(kind, kind.region, auraContainer, auraButton)
        Private.SnapLateTextures(auraButton, kind.region)
        Share(kind)
      end,
    })
    if not isAdded then return end
    unitState.groups[key] = true
  end
  unitState.live[member.id] = { key = key, kind = kind }
end

-- Without a frame to hang on, the containers of the units are stacked where new lines are added.
local function StackUnits(groupData, childRegion, plan, order)
  local shape = plan.shape
  local previous
  for _, unitState in ipairs(order) do
    local status
    if previous then
      local x, y = shape.row:Step(plan.betweenSpace)
      status = Anchor.Attach(unitState.container, shape.row:Aligned(shape.corner, false), previous.container,
        shape.row:Aligned(shape.corner, true), x, y)
    else
      status = Anchor.Attach(unitState.container, shape.corner, childRegion, shape.corner, 0, 0)
    end
    if status ~= "ok" then Flow.Defer(groupData) end
    previous = unitState
  end
end

local function Build(groupData, modern, members, plan, state)
  if not state then
    state = { units = {}, reserve = {}, memberIds = {} }
    grids[groupData.uid or groupData.id] = state
  end
  state.signature = plan.signature
  state.memberIds = {}
  local registration = Private.regions[groupData.id]
  local parentGroup, lineSize = registration and registration.region, LineSize(plan, members)
  local anchorRegion
  for _, member in ipairs(members) do
    if member.region then
      anchorRegion = member.region
      break
    end
  end
  local order, seen = {}, {}
  for _, member in ipairs(members) do
    state.memberIds[member.id] = true
    parentGroup = parentGroup or member.region
    if member.data then
      for _, unit in ipairs(member.units) do
        if not seen[unit] then
          seen[unit] = true
          order[#order + 1] = unit
        end
      end
    end
  end
  for unit, unitState in pairs(state.units) do
    if not seen[unit] then Park(state, unitState) end
  end

  local stack = {}
  for _, unit in ipairs(order) do
    local firstData
    for _, member in ipairs(members) do
      if member.data and not firstData then
        for _, memberUnit in ipairs(member.units) do
          if memberUnit == unit then firstData = member.data end
        end
      end
    end
    local unitState = Acquire(state, unit, parentGroup, firstData)
    for key in pairs(unitState.groups) do SetGroupEnabled(unitState, key, false) end
    unitState.live, unitState.anchored = {}, nil
    ConfigureFlow(unitState.container, plan, lineSize)
    for slot, member in ipairs(members) do
      if member.data then
        for position, memberUnit in ipairs(member.units) do
          if memberUnit == unit then SetUpGroup(unitState, member, slot, position, plan) end
        end
      end
    end
    stack[#stack + 1] = unitState
  end
  if not modern.mode and anchorRegion then StackUnits(groupData, anchorRegion, plan, stack) end
  return state
end

-----------------------------------------------------------------------------------------------
-- Refresh

local function AnchorTo(groupData, modern, unitState, hostFrame)
  local auraContainer = unitState.container
  if Anchor.Locked(auraContainer) then return Flow.Defer(groupData) end
  if modern.mode == "UNITFRAME" then Anchor.Rebind(unitState, auraContainer, unitState.unit, hostFrame, false) end
  local strata, level = hostFrame:GetFrameStrata(), hostFrame:GetFrameLevel()
  if not issecretvalue(strata) then auraContainer:SetFrameStrata(strata) end
  if not issecretvalue(level) then auraContainer:SetFrameLevel(level + 1) end
  local _, anchorPoint, x, y = Anchor.GroupPosition(groupData)
  local corner = Shape(AuraDisplay.GridType(groupData)).corner
  if Anchor.Attach(auraContainer, corner, hostFrame, anchorPoint, x, y) == "ok" then
    unitState.anchored = hostFrame
  else
    Flow.Defer(groupData)
  end
end

local function Refresh(groupData, modern, state, droppedUnit)
  for unit, unitState in pairs(state.units) do
    local isWanted = false
    for _, live in pairs(unitState.live) do
      local kind = live.kind
      local isActive = kind.native.active and kind.region:IsShown()
        and not AuraDisplay.UnitIgnored(AuraDisplay.GetTrigger(kind.data) or {}, unit)
      kind.wanted = isActive and true or false
      SetGroupEnabled(unitState, live.key, kind.wanted)
      isWanted = isWanted or kind.wanted
    end

    local hostFrame
    if modern.mode then
      if unit ~= droppedUnit then hostFrame = Anchor.Find(modern.mode, unit) end
      if not hostFrame then
        unitState.anchored = nil
      elseif hostFrame ~= unitState.anchored then
        AnchorTo(groupData, modern, unitState, hostFrame)
      end
    end
    local auraContainer = unitState.container
    local isVisible = isWanted and not IsPreview() and UnitExists(unit)
      and (not modern.mode or (hostFrame ~= nil and unitState.anchored == hostFrame))
    auraContainer:SetShown(isVisible)
    auraContainer:SetEnabled(isVisible)
    if isVisible then auraContainer:UpdateAllAuras() end
  end
end

-- Builds the grid again when its signature changed and the client allows it, then refreshes it.
function Flow.UpdateGrid(groupData, mayRebuild, droppedUnit)
  local key = groupData.uid or groupData.id
  if not key then return end
  local state = grids[key]
  local members = Members(groupData, state)
  if #members == 0 then
    if state then
      if IsRestricted() then
        Flow.Defer(groupData)
        Refresh(groupData, Flow.Describe(groupData), state, droppedUnit)
      else
        Purge(key)
      end
    end
    return
  end
  local modern = Flow.Describe(groupData)
  local plan = Plan(groupData, modern, members)
  if not state or state.signature ~= plan.signature then
    if not mayRebuild then
      AuraDisplay.RechainFlow(groupData)
    elseif IsRestricted() then
      Flow.Defer(groupData)
    else
      state = Build(groupData, modern, members, plan, state)
    end
  end
  if state then Refresh(groupData, modern, state, droppedUnit) end
end

Private.callbacks:RegisterCallback("Delete", function(_, uid, id) Purge(uid or id) end)

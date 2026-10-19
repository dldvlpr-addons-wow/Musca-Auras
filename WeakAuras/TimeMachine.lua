---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

Private.Features:Register({
  id = "undo",
  autoEnable = {"dev", "pr", "alpha", "beta", "release"},
  enabled = true,
  persist = true,
})

---@class TimeMachine
local TimeMachine = {
  ---@type change
  next = {
    forward = {},
    backward = {}
  },
  transaction = false,
  ---@type change[]
  changes = {},
  ---@type table<actionType, Action>
  actions = {},
  ---@type table<string, {idempotent: boolean, func: function}>
  effects = {},
  index = 0,
  sub = Private.CreateSubscribableObject(),
}

Private.TimeMachine = TimeMachine

---@alias keyPath key | (key)[]
---@alias Actor fun(data: table, path: keyPath, payload: any)
---@alias Inverter fun(data: table, path: keyPath, payload?: any): actionType, keyPath, any
---@alias actionType string
---@alias effectType string

---@class Action
---@field actor Actor
---@field inverter Inverter
---@field autoEffects? effectType[]

---@class actionRecord
---@field uid uid
---@field actionType actionType
---@field path keyPath
---@field payload any
---@field effects? effectType[]
---@field suppressAutoEffects? table<effectType, boolean>

---@class change
---@field forward actionRecord[]
---@field backward actionRecord[]

---@param data table
---@param path keyPath
---@return table, key
local function resolveKey(data, path)
  if type(path) ~= 'table' then
    return data, path
  end
  local tbl = data
  local i = 1
  while i < #path do
    if tbl[path[i]] == nil then
      tbl[path[i]] = {}
    elseif type(tbl[path[i]]) ~= 'table' then
      error("Path is not valid: " .. table.concat(path, '.') .. " at " .. path[i])
    end
    tbl = tbl[path[i]]
    i = i + 1
  end
  return tbl, path[#path]
end

local function copy(tbl, key)
  if type(tbl[key]) == "table" then
    return CopyTable(tbl[key])
  else
    return tbl[key]
  end
end

---@type fun(self: self, tag: effectType, func: fun(uid:uid, data: auraData), idempotent?: boolean)
function TimeMachine:RegisterEffect(tag, func, idempotent)
  if self.effects[tag] then
    error("Effect already registered: " .. tag)
  end
  self.effects[tag] = {
    idempotent = idempotent,
    func = func
  }
end

TimeMachine:RegisterEffect("add", function(uid, data)
  Private.Add(data)
end, true)

TimeMachine:RegisterEffect("options_cu", function(uid, data)
  if WeakAuras.IsOptionsOpen() then
    WeakAuras.ClearOptions(data.id)
  end
end, true)

TimeMachine.sub:AddSubscriber("Step", {
  Step = function()
    if WeakAuras.IsOptionsOpen() then
      WeakAuras.ClearAndUpdateOptions()
    end
  end
  })

---@type fun(self: self, actionType: actionType, action: Actor<any>, inverter: Inverter<any, any>, autoEffects?: effectType[])
function TimeMachine:RegisterAction(actionType, actor, inverter, autoEffects)
  if self.actions[actionType] then
    error("Action already registered: " .. actionType)
  end
  self.actions[actionType] = {
    actor = actor,
    inverter = inverter,
    autoEffects = autoEffects,
  }
end
TimeMachine:RegisterAction("none",
  function(_data, _path)
  end,
  function(_data, path)
    return 'none', path, nil
  end
)

TimeMachine:RegisterAction("set",
  function(data, path, value)
    local tbl, key = resolveKey(data, path)
    tbl[key] = value
  end,
  function(data, path)
    local tbl, key = resolveKey(data, path)
    return 'set', path, copy(tbl, key)
  end,
  {"add", "options_cu"}
)

TimeMachine:RegisterAction("setmany",
  function(data, path, values)
    local tbl, key = resolveKey(data, path)
    for k, v in pairs(values) do
      tbl[key][k] = v
    end
  end,
  function(data, path, values)
    local tbl, key = resolveKey(data, path)
    local inverse = {}
    for k, v in pairs(values) do
      inverse[k] = copy(tbl[key], k)
    end
    return 'setmany', path, inverse
  end,
  {"add", "options_cu"}
)

TimeMachine:RegisterAction("insert",
  function(data, path, payload)
    local tbl, key = resolveKey(data, path)
    if payload.index == nil then
      table.insert(tbl[key], payload.value)
    else
      table.insert(tbl[key], payload.index, payload.value)
    end
  end,
  function(data, path, payload)
    return 'remove', path, payload.index
  end,
  {"add", "options_cu"}
)

TimeMachine:RegisterAction("remove",
  function(data, path, payload)
    local tbl, key = resolveKey(data, path)
    if payload == nil then
      table.remove(tbl[key])
    else
      table.remove(tbl[key], payload)
    end
  end,
  function(data, path, payload)
    local tbl, key = resolveKey(data, path)
    return 'insert', path, {index = payload, value = copy(tbl[key], payload or #tbl[key])}
  end,
  {"add", "options_cu"}
)

TimeMachine:RegisterAction("swap",
  function(data, path, payload)
    local tbl, key = resolveKey(data, path)
    tbl[key][payload[1]], tbl[key][payload[2]] = tbl[key][payload[2]], tbl[key][payload[1]]
  end,
  function(data, path, payload)
    return 'swap', path, {payload[2], payload[1]}
  end,
  {"add", "options_cu"}
)

TimeMachine:RegisterAction("move",
  function(data, path, payload)
    local tbl, key = resolveKey(data, path)
    local value = table.remove(tbl, payload[1])
    table.insert(tbl[key], payload[2], value)
  end,
  function(data, path, payload)
    return 'move', path, {payload[2], payload[1]}
  end,
  {"add", "options_cu"}
)

-- Most option panels write the aura themselves and then call WeakAuras.Add. Those edits are recorded as whole copies
-- of the aura: the options watch the picked auras, and WeakAuras.Add compares each watched aura with its last copy.
-- The id and the group links stay out of the copy, so an undo never renames an aura nor moves it between groups.
local structureKeys = { id = true, uid = true, parent = true, controlledChildren = true }
local maxChanges = 50
-- Edits closer than this, a slider drag or a multi-selection, are one step of the history.
local mergeDelay = 1

local function copyContent(data)
  local content = {}
  for key, value in pairs(data) do
    if not structureKeys[key] then
      content[key] = type(value) == "table" and CopyTable(value) or value
    end
  end
  return content
end

local function sameContent(content, data)
  for key, value in pairs(data) do
    if not structureKeys[key] then
      local other = content[key]
      if type(value) == "table" then
        if type(other) ~= "table" or not tCompare(value, other, math.huge) then
          return false
        end
      elseif value ~= other then
        return false
      end
    end
  end
  for key in pairs(content) do
    if data[key] == nil then
      return false
    end
  end
  return true
end

TimeMachine:RegisterAction("restore",
  function(data, _path, content)
    for key in pairs(data) do
      if not structureKeys[key] then
        data[key] = nil
      end
    end
    for key, value in pairs(content) do
      data[key] = type(value) == "table" and CopyTable(value) or value
    end
  end,
  function(data, path)
    return "restore", path, copyContent(data)
  end,
  {"add", "options_cu"}
)

-- Name, group and children of an aura: a change of them is a rename or a move, which a restore cannot undo.
local function placeOf(data)
  return table.concat({ data.id, data.parent or "", table.concat(data.controlledChildren or {}, ",") }, "|")
end

---@type table<uid, table>
TimeMachine.copies = {}
---@type table<uid, string>
TimeMachine.places = {}

function TimeMachine:Remember(data)
  self.copies[data.uid] = copyContent(data)
  self.places[data.uid] = placeOf(data)
end

--- Watches the aura, its children and its groups, so that their next WeakAuras.Add is recorded.
---@param data auraData
function TimeMachine:Watch(data)
  if not self.copiesFollowAdd then
    -- Every add, by an undo or by any other path, keeps the copy of a watched aura current.
    Private.callbacks:RegisterCallback("Add", function(_, uid, _, addedData)
      if self.copies[uid] then
        self:Remember(addedData)
      end
    end)
    self.copiesFollowAdd = true
  end
  for watched in Private.TraverseAll(data) do
    if not self.copies[watched.uid] then
      self:Remember(watched)
    end
  end
  for parent in Private.TraverseParents(data) do
    if not self.copies[parent.uid] then
      self:Remember(parent)
    end
  end
end

function TimeMachine:ForgetWatched()
  self.copies = {}
  self.places = {}
end

--- Called by WeakAuras.Add before the aura is added again. An edit that cannot be undone clears the history, since
--- the steps before it would no longer match the auras: an edit of an aura that is not watched, a rename, a move, an
--- import. The other auras added in the same frame belong to that operation and are not recorded either.
---@param data auraData
function TimeMachine:RecordEdit(data)
  local now = GetTime()
  local before = self.copies[data.uid]
  if not before or self.transaction or WeakAuras.IsImporting() or self.clearedAt == now
    or self.places[data.uid] ~= placeOf(data) then
    self.clearedAt = now
    self:DestroyTheUniverse(data.id)
    return
  end
  if sameContent(before, data) then
    return
  end
  local change = self.changes[self.index]
  if not (change and change.editedAt and self.index == #self.changes and now - change.editedAt < mergeDelay) then
    while self.index < #self.changes do
      table.remove(self.changes)
    end
    change = { forward = {}, backward = {}, edited = {} }
    table.insert(self.changes, change)
    while #self.changes > maxChanges do
      table.remove(self.changes, 1)
    end
    self.index = #self.changes
  end
  change.editedAt = now
  local after = { uid = data.uid, actionType = "restore", payload = copyContent(data) }
  if change.edited[data.uid] then
    change.forward[change.edited[data.uid]] = after
  else
    table.insert(change.forward, after)
    change.edited[data.uid] = #change.forward
    table.insert(change.backward, 1, { uid = data.uid, actionType = "restore", payload = before })
  end
  if self.sub:HasSubscribers("Record") then
    self.sub:Notify("Record", self.index)
  end
end

---@param path keyPath
local function keyPathToString(path)
  if type(path) == 'table' then
    return table.concat(path, '.')
  else
    return path
  end
end

---@param effects effectType[]
local function invertEffects(effects)
  local inverted = {}
  for i = #effects, 1, -1 do
    table.insert(inverted, effects[i])
  end
  return inverted
end

function TimeMachine:StartTransaction()
  if self.transaction then
    WeakAuras.prettyPrint("If you're reading this, a time machine transaction was started, but there was already one in  progress. That's not supposed to happen. Please report this to the WeakAuras developers, thanks!")
    self:Reject()
  end
  self.transaction = true
end

local function FormatPayload(payload)
  if type(payload) == "table" then
    local result = {}
    for k, v in pairs(payload) do
      if type(v) == "table" then
        tinsert(result, k .. ": (table)")
      else
        tinsert(result, k .. ":" .. tostring(v))
      end
    end
    return table.concat(result, ", ")
  end
  return payload
end

---@param record actionRecord
function TimeMachine:Append(record)
  local action = self.actions[record.actionType]
  Private.DebugPrint("Forward action", record.actionType, "for", record.uid, "at", keyPathToString(record.path), "with", FormatPayload(record.payload))
  if not action then
    error("No action for actionType: " .. record.actionType)
  end
  local inverter = action.inverter
  if not inverter then
    error("No inverter for action: " .. record.actionType)
  end
  local actionType, path, payload = inverter(Private.GetDataByUID(record.uid), record.path, record.payload)
  ---@type actionRecord
  local inverseRecord = {
    uid = record.uid,
    actionType = actionType,
    path = path,
    payload = payload,
    suppressAutoEffects = record.suppressAutoEffects and CopyTable(record.suppressAutoEffects) or nil,
    effects = record.effects and invertEffects(record.effects) or nil,
  }
  Private.DebugPrint("Backward action", actionType, "for", record.uid, "at", keyPathToString(path), "with", FormatPayload(payload))
  table.insert(self.next.forward, record)
  table.insert(self.next.backward, 1, inverseRecord)
  if not self.transaction then
    self:Commit(true)
  end
end

---@param records actionRecord[]
function TimeMachine:AppendMany(records)
  local commit = false
  if not self.transaction then
    self:StartTransaction()
    commit = true
  end
  for _, record in ipairs(records) do
    self:Append(record)
  end
  if commit then
    self:Commit()
  end
end

function TimeMachine:Reject()
  self.next = {
    forward = {},
    backward = {}
  }
  self.transaction = false
end

---@param instant? boolean
function TimeMachine:Commit(instant)
  if not self.transaction and not instant then
    WeakAuras.prettyPrint("If you're reading this, a time machine transaction was committed, but there was no transaction in progress. That's not supposed to happen. Please report this to the WeakAuras developers, thanks!")
    return
  end

  if next(self.next.forward) == nil then
    -- No actual changes, probably because of old code
    self.transaction = false
    return
  end

  while self.index < #self.changes do
    table.remove(self.changes)
  end
  table.insert(self.changes, self.next)
  self.next = {
    forward = {},
    backward = {}
  }
  self.transaction = false
  return self:StepForward()
end

---@param records actionRecord[]
---@param delayedEffects? table<uid, table<effectType, boolean>>
---@return {uid: uid, effect: effectType}[]?
function TimeMachine:Apply(records, delayedEffects)
  for _, record in ipairs(records) do
    local action = self.actions[record.actionType]
    if not action then
      error("No action for actionType: " .. record.actionType)
    end
    local data = Private.GetDataByUID(record.uid)
    action.actor(data, record.path, record.payload)
    if action.autoEffects or record.effects then
      ---@type effectType[]
      local effects = {}
      if action.autoEffects then
        for _, effect in ipairs(action.autoEffects) do
          if not record.suppressAutoEffects or not record.suppressAutoEffects[effect] then
            table.insert(effects, effect)
          end
        end
      end
      if record.effects then
        for _, effect in ipairs(record.effects) do
          table.insert(effects, effect)
        end
      end
      for _, effectType in ipairs(effects) do
        local effect = self.effects[effectType]
        if not effect then
          error("No effect for effectType: " .. effect)
        end
        if not delayedEffects or not effect.idempotent then
          if not record.effects or record.suppressAutoEffects then
            effect.func(record.uid, data)
          end
        else
          delayedEffects[record.uid] = delayedEffects[record.uid] or {}
          delayedEffects[record.uid][effectType] = true
        end
      end
    end
  end
  return delayedEffects
end

function TimeMachine:StepForward()
  if self.index < #self.changes then
    self.index = self.index + 1
    self:Apply(self.changes[self.index].forward)
    if self.sub:HasSubscribers("Step") then
      self.sub:Notify("Step", self.index)
    end
  end
end

function TimeMachine:StepBackward()
  if self.index > 0 then
    self:Apply(self.changes[self.index].backward)
    self.index = self.index - 1
    if self.sub:HasSubscribers("Step") then
      self.sub:Notify("Step", self.index)
    end
  end
end

--- much safer than the name suggests!
---@param id string
function TimeMachine:DestroyTheUniverse(id)
  if self.transaction then
    WeakAuras.prettyPrint("If you're reading this, a time machine transaction was destroyed, but there was one in progress. That's not supposed to happen. Please report this to the WeakAuras developers, thanks!")
    self:Reject()
  end
  if #self.changes > 0 then
    Private.DebugPrint(string.format("Destroying the universe where %i change(s) happpened, because an unexpected change happened to %q.", #self.changes, id))
  end
  self.changes = {}
  self.index = 0
  if self.sub:HasSubscribers("Step") then
    self.sub:Notify("Step", self.index)
  end
end

function TimeMachine:DescribeNext()
  return self.changes[self.index + 1] and self.changes[self.index + 1].forward
end

function TimeMachine:DescribePrevious()
  return self.changes[self.index] and self.changes[self.index].backward
end

local Clock = {
  now = 1000,
  timers = {},
  nextTimerId = 0,
  updateFrames = {},
}

local function Schedule(delay, callback, iterations, owner)
  Clock.nextTimerId = Clock.nextTimerId + 1
  local timer = {
    id = Clock.nextTimerId,
    due = Clock.now + math.max(delay, 0),
    delay = delay,
    callback = callback,
    iterations = iterations,
    owner = owner,
  }
  Clock.timers[#Clock.timers + 1] = timer
  return timer
end

local TimerHandle = {}
TimerHandle.__index = TimerHandle

function TimerHandle:Cancel()
  self.timer.cancelled = true
end

function TimerHandle:IsCancelled()
  return self.timer.cancelled == true
end

function Clock.CreateTimerApi(protect)
  local api = {}
  function api.After(delay, callback)
    Schedule(delay, callback, 1)
  end
  function api.NewTimer(delay, callback)
    local handle = setmetatable({}, TimerHandle)
    handle.timer = Schedule(delay, function() callback(handle) end, 1)
    return handle
  end
  function api.NewTicker(delay, callback, iterations)
    local handle = setmetatable({}, TimerHandle)
    handle.timer = Schedule(delay, function() callback(handle) end, iterations or math.huge)
    return handle
  end
  Clock.protect = protect
  return api
end

local function RunDueTimers()
  local ran = true
  while ran do
    ran = false
    table.sort(Clock.timers, function(a, b)
      if a.due == b.due then
        return a.id < b.id
      end
      return a.due < b.due
    end)
    local timer = Clock.timers[1]
    if timer and timer.due <= Clock.now then
      table.remove(Clock.timers, 1)
      if not timer.cancelled then
        timer.iterations = timer.iterations - 1
        if timer.iterations > 0 then
          timer.due = timer.due + math.max(timer.delay, 0.001)
          Clock.timers[#Clock.timers + 1] = timer
        end
        Clock.protect(timer.callback)
      end
      ran = true
    end
  end
end

function Clock.Advance(seconds, step)
  step = step or 0.05
  local target = Clock.now + seconds
  repeat
    local delta = math.min(step, target - Clock.now)
    Clock.now = Clock.now + delta
    if Clock.onTick then
      Clock.protect(Clock.onTick)
    end
    RunDueTimers()
    for frame in pairs(Clock.updateFrames) do
      local handler = frame:GetScript("OnUpdate")
      if handler and frame:IsVisible() then
        Clock.protect(handler, frame, delta)
      end
    end
  until Clock.now >= target - 1e-9
  RunDueTimers()
end

function Clock.GetTime()
  return Clock.now
end

return Clock

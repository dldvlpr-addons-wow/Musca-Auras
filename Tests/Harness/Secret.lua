local type, tostring = type, tostring
local Secret = { violations = {} }

local values = setmetatable({}, { __mode = "k" })
local metatable

local function Fail(action)
  local message = "attempt to " .. action .. " a secret value"
  Secret.violations[#Secret.violations + 1] = debug.traceback(message, 3)
  error("attempt to " .. action .. " a secret value", 3)
end

function Secret.Wrap(value)
  if value == nil then
    return nil
  end
  local proxy = newproxy(true)
  local proxyMetatable = getmetatable(proxy)
  for key, handler in pairs(metatable) do
    proxyMetatable[key] = handler
  end
  values[proxy] = { value = value }
  return proxy
end

function Secret.IsSecret(value)
  return type(value) == "userdata" and values[value] ~= nil
end

function Secret.Reveal(value)
  if Secret.IsSecret(value) then
    return values[value].value
  end
  return value
end

local function Concat(left, right)
  return Secret.Wrap(tostring(Secret.Reveal(left)) .. tostring(Secret.Reveal(right)))
end

metatable = {
  __index = function() Fail("index") end,
  __newindex = function() Fail("index") end,
  __call = function() Fail("call") end,
  __add = function() Fail("perform arithmetic on") end,
  __sub = function() Fail("perform arithmetic on") end,
  __mul = function() Fail("perform arithmetic on") end,
  __div = function() Fail("perform arithmetic on") end,
  __mod = function() Fail("perform arithmetic on") end,
  __pow = function() Fail("perform arithmetic on") end,
  __unm = function() Fail("perform arithmetic on") end,
  __len = function() Fail("get length of") end,
  __eq = function() Fail("compare") end,
  __lt = function() Fail("compare") end,
  __le = function() Fail("compare") end,
  __concat = Concat,
  __tostring = function() return "<secret>" end,
}

return Secret

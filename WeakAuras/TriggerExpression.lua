-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Trigger combination written as an expression, such as "1 and (2 or not 3)".
-- The expression is compiled into closures, without Lua code: trigger numbers,
-- "and", "or", "not" and parentheses only.

local L = WeakAuras.L

local function Tokenize(text)
  local tokens = {}
  local position = 1
  while true do
    position = text:find("%S", position)
    if not position then
      return tokens
    end
    local token = text:match("^%d+", position) or text:match("^%a+", position)
      or text:match("^[\192-\255][\128-\191]*", position) or text:sub(position, position)
    tinsert(tokens, token:lower())
    position = position + #token
  end
end

-- Rewrites each trigger number of the expression through Renumber(number), which returns the new number.
function Private.RenumberTriggerExpression(text, Renumber)
  if type(text) ~= "string" then
    return text
  end
  return (text:gsub("%d+", function(number)
    return tostring(Renumber(tonumber(number)))
  end))
end

-- Returns a function(triggers) giving the state of the combination, or nil and an error message.
-- triggers holds the state of each trigger by number.
function Private.CompileTriggerExpression(text, numTriggers)
  local tokens = Tokenize(type(text) == "string" and text or "")
  local index = 1
  local Expression

  local function Fail(message)
    error({ message = message }, 0)
  end

  local function Peek()
    return tokens[index]
  end

  local function Next()
    local token = tokens[index]
    if not token then
      Fail(L["Incomplete expression"])
    end
    index = index + 1
    return token
  end

  local function Factor()
    local token = Next()
    if token == "not" then
      local operand = Factor()
      return function(triggers) return not operand(triggers) end
    elseif token == "(" then
      local inner = Expression()
      local closing = Peek()
      if not closing then
        Fail(L["Missing closing parenthesis"])
      elseif closing ~= ")" then
        Fail(L["Unexpected \"%s\""]:format(closing))
      end
      index = index + 1
      return inner
    end
    local triggernum = token:find("^%d+$") and tonumber(token)
    if not triggernum then
      Fail(L["Unexpected \"%s\""]:format(token))
    end
    if triggernum < 1 or triggernum > numTriggers then
      Fail(L["Trigger %s does not exist"]:format(token))
    end
    return function(triggers) return triggers[triggernum] and true or false end
  end

  local function Term()
    local left = Factor()
    while Peek() == "and" do
      index = index + 1
      local first, second = left, Factor()
      left = function(triggers) return first(triggers) and second(triggers) end
    end
    return left
  end

  Expression = function()
    local left = Term()
    while Peek() == "or" do
      index = index + 1
      local first, second = left, Term()
      left = function(triggers) return first(triggers) or second(triggers) end
    end
    return left
  end

  local ok, result = pcall(function()
    local compiled = Expression()
    if Peek() then
      Fail(L["Unexpected \"%s\""]:format(Peek()))
    end
    return compiled
  end)
  if ok then
    return result
  end
  -- A string error is a stack overflow on a deeply nested expression
  return nil, type(result) == "table" and result.message or tostring(result)
end

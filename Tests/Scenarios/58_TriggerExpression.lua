-- TriggerExpression: a trigger combination written as "1 and (2 or not 3)" is compiled without Lua code,
-- and a wrong expression gives an error message instead of a function.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  local Compile = assert(private.CompileTriggerExpression, "CompileTriggerExpression")

  local combination = assert(Compile("1 and (2 or NOT 3)", 3))
  assert(combination({ true, true, true }) == true, "1 and 2")
  assert(combination({ true, false, false }) == true, "1 and not 3")
  assert(combination({ true, false, true }) == false, "1 without 2 or not 3")
  assert(combination({ false, true, false }) == false, "without 1")
  assert(combination({}) == false, "no trigger active")

  local precedence = assert(Compile("1 or 2 and 3", 3))
  assert(precedence({ true }) == true, "and before or")
  assert(precedence({ false, true }) == false, "2 alone")

  assert(Compile("not not 1", 1)({ true }) == true, "double not")

  local function Error(text, numTriggers)
    local compiled, message = Compile(text, numTriggers)
    assert(compiled == nil and type(message) == "string", text)
    return message
  end
  Error("", 2)
  Error("1 and", 2)
  Error("(1 or 2", 2)
  Error("1 2", 2)
  Error("1 xor 2", 2)
  Error("1 & 2", 2)
  Error("0", 2)
  Error("3", 2)
  Error(")", 2)
  Error("1 or not nan", 2)
  Error(12, 2)
  Error(string.rep("(", 20000) .. "1", 2)
  local missing, unexpected = Error("(1 and 2", 2), Error("(1 2)", 2)
  assert(missing ~= unexpected and unexpected:find("2", 1, true), "closing parenthesis messages")
  assert(Error("1 é", 2):find("é", 1, true), "whole UTF-8 character in the message")

  local Renumber = assert(private.RenumberTriggerExpression, "RenumberTriggerExpression")
  local swapped = Renumber("1 and (2 or not 3)", function(number)
    return number == 2 and 3 or number == 3 and 2 or number
  end)
  assert(swapped == "1 and (3 or not 2)", swapped)
  assert(Renumber(nil, tostring) == nil, "no expression")
end

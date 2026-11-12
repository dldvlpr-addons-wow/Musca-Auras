-- Assertion helpers shared by the scenarios: local helpers that were identical in several scenarios.
local Assertions = {}

function Assertions.Same(actual, expected, label)
  assert(actual == expected, ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
end

function Assertions.Near(actual, expected, label, tolerance)
  assert(type(actual) == "number" and math.abs(actual - expected) < (tolerance or 1e-9),
    ("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)))
end

return Assertions

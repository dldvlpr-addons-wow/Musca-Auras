local Bit = {}

local function ToUnsigned(value)
  value = math.floor(value) % 4294967296
  return value
end

local function Combine(a, b, rule)
  a, b = ToUnsigned(a), ToUnsigned(b)
  local result, place = 0, 1
  for _ = 1, 32 do
    local bitA, bitB = a % 2, b % 2
    if rule(bitA, bitB) then
      result = result + place
    end
    a, b, place = (a - bitA) / 2, (b - bitB) / 2, place * 2
  end
  return result
end

local function Fold(rule)
  return function(first, ...)
    local result = ToUnsigned(first)
    for i = 1, select("#", ...) do
      result = Combine(result, (select(i, ...)), rule)
    end
    return result
  end
end

Bit.band = Fold(function(a, b) return a == 1 and b == 1 end)
Bit.bor = Fold(function(a, b) return a == 1 or b == 1 end)
Bit.bxor = Fold(function(a, b) return a ~= b end)

function Bit.bnot(value)
  return 4294967295 - ToUnsigned(value)
end

function Bit.lshift(value, count)
  return ToUnsigned(ToUnsigned(value) * 2 ^ count)
end

function Bit.rshift(value, count)
  return math.floor(ToUnsigned(value) / 2 ^ count)
end

function Bit.arshift(value, count)
  value = ToUnsigned(value)
  if value >= 2147483648 then
    return ToUnsigned(math.floor((value - 4294967296) / 2 ^ count))
  end
  return math.floor(value / 2 ^ count)
end

function Bit.tobit(value)
  value = ToUnsigned(value)
  if value >= 2147483648 then
    return value - 4294967296
  end
  return value
end

return Bit

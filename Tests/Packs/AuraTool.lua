-- usage: lua aura_tool.lua <repo> decode <file> | encode <luafile returning transmit table>
local repo, mode, path = arg[1], arg[2], arg[3]
strmatch = string.match
dofile(repo .. "/WeakAuras/Libs/LibStub/LibStub.lua")
dofile(repo .. "/WeakAuras/Libs/LibDeflate/LibDeflate.lua")
dofile(repo .. "/WeakAuras/Libs/LibSerialize/LibSerialize.lua")
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local P, M = {12059, 27709, 6807, 24097, 18149, 3301, 30011, 9479}, 2147483647
local function decrypt(data)
  local nonce = data:sub(1, 4)
  local seed = #P
  for i, p in ipairs(P) do seed = (seed * 131 + p * i + nonce:byte((i - 1) % 4 + 1)) % M end
  local state, prev, out = seed == 0 and 1 or seed, 0, {}
  for i = 5, #data do
    state = state * 16807 % M
    local b = data:byte(i)
    out[#out + 1] = string.char((b - math.floor(state / 256) % 256 - prev) % 256)
    prev = b
  end
  return table.concat(out)
end

local function dump(v, indent)
  indent = indent or ""
  if type(v) ~= "table" then return type(v) == "string" and string.format("%q", v) or tostring(v) end
  local keys = {}
  for k in pairs(v) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  local lines = {"{"}
  for _, k in ipairs(keys) do
    local key = type(k) == "string" and k:match("^[%a_][%w_]*$") and k or "[" .. dump(k) .. "]"
    lines[#lines + 1] = indent .. "  " .. key .. " = " .. dump(v[k], indent .. "  ") .. ","
  end
  lines[#lines + 1] = indent .. "}"
  return table.concat(lines, "\n")
end

if mode == "decode" then
  local s = io.open(path):read("*a"):gsub("%s", "")
  local decoded = LibDeflate:DecodeForPrint(s:match("^!WA:2!(.+)$"))
  local raw = LibDeflate:DecompressDeflate(decrypt(decoded)) or LibDeflate:DecompressDeflate(decoded)
  local ok, t = LibSerialize:Deserialize(raw)
  assert(ok, t)
  print("return " .. dump(t))
else
  local t = dofile(path)
  local s = LibSerialize:SerializeEx({errorOnUnserializableType = false}, t)
  local encoded = "!WA:2!" .. LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(s, {level = 9}))
  local ok, back = LibSerialize:Deserialize(LibDeflate:DecompressDeflate(LibDeflate:DecodeForPrint(encoded:sub(7))))
  assert(ok and back.d.id == t.d.id, "round trip failed")
  print(encoded)
end

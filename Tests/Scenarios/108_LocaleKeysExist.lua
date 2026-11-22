-- Every literal L["..."] used by the code exists in enUS. The locale tables have no fallback: a missing key is nil,
-- and L[key]:format(...) or a concatenation raises an error in game.
local function ReadFile(path)
  local file = assert(io.open(path, "rb"), "cannot open " .. path)
  local text = file:read("*a")
  file:close()
  return (text:gsub("\r", ""))
end

-- Lua files listed in a TOC, in load order. Libs and locales are loaded through embeds.xml and locales.xml.
local function TocLuaFiles(addon)
  local files = {}
  for line in ReadFile(addon .. "/" .. addon .. ".toc"):gmatch("[^\r\n]+") do
    local file = line:match("^%s*([^#%s][^#]-%.lua)%s*$")
    if file then
      files[#files + 1] = addon .. "/" .. file:gsub("\\", "/")
    end
  end
  assert(#files > 0, "no Lua file found in the TOC of " .. addon)
  return files
end

-- Calls visit(key, line) for each L["..."] of the text, comments left out.
local function EachLiteralKey(text, visit)
  local lineNumber = 0
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    lineNumber = lineNumber + 1
    local code = line:match("^%s*%-%-") and "" or line
    local position = 1
    while true do
      local start, quote = code:find('L%["', position)
      if not start then break end
      local previous = start > 1 and code:sub(start - 1, start - 1) or ""
      local cursor = quote + 1
      while cursor <= #code and code:sub(cursor, cursor) ~= '"' do
        cursor = cursor + (code:sub(cursor, cursor) == "\\" and 2 or 1)
      end
      if not previous:match("[%w_]") and code:sub(cursor + 1, cursor + 1) == "]" then
        local key = assert(loadstring("return " .. code:sub(quote, cursor)))()
        visit(key, lineNumber)
      end
      position = cursor + 1
    end
  end
end

local function EnglishKeys(path, keys)
  local text = ReadFile(path)
  EachLiteralKey(text, function(key) keys[key] = true end)
  -- Multi-line keys: L[ [=[...]=] ] = ...
  for key in text:gmatch("L%[ %[=%[(.-)%]=%] %]") do
    keys[key] = true
  end
  return keys
end

return function()
  local coreKeys = EnglishKeys("WeakAuras/Locales/enUS.lua", {})
  -- The options addon shares WeakAuras.L: its code may use a key of either file.
  local optionsKeys = EnglishKeys("WeakAurasOptions/Locales/enUS.lua", {})
  for key in pairs(coreKeys) do optionsKeys[key] = true end

  local missing = {}
  for _, addon in ipairs({ { name = "WeakAuras", keys = coreKeys }, { name = "WeakAurasOptions", keys = optionsKeys } }) do
    for _, path in ipairs(TocLuaFiles(addon.name)) do
      EachLiteralKey(ReadFile(path), function(key, line)
        if not addon.keys[key] then
          missing[#missing + 1] = ("%s:%d: L[%q]"):format(path, line, key)
        end
      end)
    end
  end
  assert(#missing == 0, #missing .. " locale key(s) missing from enUS:\n" .. table.concat(missing, "\n"))
end

local DocumentedApi = {
  functions = {},
  namespaces = {},
  widgetMethods = {},
  events = {},
  enums = {},
  constants = {},
  stubCalls = {},
}

local function AutoTable()
  local auto
  auto = setmetatable({}, {
    __index = function(self, key)
      local child = AutoTable()
      rawset(self, key, child)
      return child
    end,
  })
  return auto
end

local function ReadTocFiles(folder, tocName)
  local files = {}
  local toc = assert(io.open(folder .. "/" .. tocName, "r"))
  for line in toc:lines() do
    line = line:gsub("\r", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if line ~= "" and not line:find("^#") and line:find("%.lua$") then
      files[#files + 1] = folder .. "/" .. line:gsub("\\", "/")
    end
  end
  toc:close()
  return files
end

local function Serialize(value, out)
  if type(value) == "table" then
    out[#out + 1] = "{"
    for key, child in pairs(value) do
      out[#out + 1] = "[" .. (type(key) == "number" and tostring(key) or string.format("%q", key)) .. "]="
      Serialize(child, out)
      out[#out + 1] = ","
    end
    out[#out + 1] = "}"
  elseif type(value) == "string" then
    out[#out + 1] = string.format("%q", value)
  else
    out[#out + 1] = tostring(value)
  end
end

local function Parse(sourceRoot)
  local folder = sourceRoot .. "/Interface/AddOns/Blizzard_APIDocumentationGenerated"
  local tables = {}
  local sandbox = {
    Enum = AutoTable(),
    Constants = AutoTable(),
    APIDocumentation = {
      AddDocumentationTable = function(_, documentation)
        tables[#tables + 1] = documentation
      end,
    },
  }
  setmetatable(sandbox, { __index = function(_, key) return AutoTable() end })
  for _, path in ipairs(ReadTocFiles(folder, "Blizzard_APIDocumentationGenerated.toc")) do
    local chunk = loadfile(path)
    if chunk then
      setfenv(chunk, sandbox)
      pcall(chunk)
    end
  end

  local tableKinds = {}
  for _, documentation in ipairs(tables) do
    for _, tableDefinition in ipairs(documentation.Tables or {}) do
      tableKinds[tableDefinition.Name] = tableDefinition.Type == "Structure" and "table" or "number"
    end
  end
  local stringTypes = { string = true, cstring = true, WOWGUID = true, kstringClubId = true, textureAtlas = true }
  local function ReturnKinds(definition)
    local kinds = {}
    for index, returned in ipairs(definition.Returns or {}) do
      local kind = "number"
      if returned.Nilable then
        kind = "nil"
      elseif returned.Type == "bool" then
        kind = "bool"
      elseif returned.Type == "table" or tableKinds[returned.Type] == "table" then
        kind = "table"
      elseif stringTypes[returned.Type] then
        kind = "string"
      end
      kinds[index] = kind
    end
    return kinds
  end

  for _, documentation in ipairs(tables) do
    for _, definition in ipairs(documentation.Functions or {}) do
      if documentation.Type == "ScriptObject" then
        DocumentedApi.widgetMethods[definition.Name] = true
      elseif documentation.Namespace then
        local namespace = DocumentedApi.namespaces[documentation.Namespace] or {}
        DocumentedApi.namespaces[documentation.Namespace] = namespace
        namespace[definition.Name] = ReturnKinds(definition)
      else
        DocumentedApi.functions[definition.Name] = ReturnKinds(definition)
      end
    end
    for _, event in ipairs(documentation.Events or {}) do
      DocumentedApi.events[event.LiteralName] = true
    end
    for _, tableDefinition in ipairs(documentation.Tables or {}) do
      if tableDefinition.Type == "Enumeration" and tableDefinition.Fields then
        local enum = {}
        for _, field in ipairs(tableDefinition.Fields) do
          enum[field.Name] = field.EnumValue
        end
        DocumentedApi.enums[tableDefinition.Name] = enum
        DocumentedApi.enums[tableDefinition.Name .. "Meta"] = { MinValue = tableDefinition.MinValue,
          MaxValue = tableDefinition.MaxValue, NumValues = tableDefinition.NumValues }
      elseif tableDefinition.Type == "Constants" and tableDefinition.Values then
        local constants = {}
        for _, value in ipairs(tableDefinition.Values) do
          if type(value.Value) ~= "table" then
            constants[value.Name] = value.Value
          end
        end
        DocumentedApi.constants[tableDefinition.Name] = constants
      end
    end
  end
end

function DocumentedApi.Load(sourceRoot, cachePath)
  local cached = cachePath and loadfile(cachePath)
  if cached then
    local data = cached()
    for _, key in ipairs({ "functions", "namespaces", "widgetMethods", "events", "enums", "constants" }) do
      DocumentedApi[key] = data[key]
    end
    return
  end
  Parse(sourceRoot)
  if cachePath then
    local out = { "return " }
    Serialize({
      functions = DocumentedApi.functions,
      namespaces = DocumentedApi.namespaces,
      widgetMethods = DocumentedApi.widgetMethods,
      events = DocumentedApi.events,
      enums = DocumentedApi.enums,
      constants = DocumentedApi.constants,
    }, out)
    local file = assert(io.open(cachePath, "w"))
    file:write(table.concat(out))
    file:close()
  end
end

local defaults = { bool = function() return false end, table = function() return {} end,
  string = function() return "" end, number = function() return 0 end, ["nil"] = function() return nil end }

local function Stub(qualifiedName, kinds)
  return function()
    DocumentedApi.stubCalls[qualifiedName] = (DocumentedApi.stubCalls[qualifiedName] or 0) + 1
    local values = {}
    for index, kind in ipairs(kinds) do
      values[index] = defaults[kind]()
    end
    return unpack(values, 1, #kinds)
  end
end

function DocumentedApi.Install(target)
  target.Constants = target.Constants or {}
  for name, constants in pairs(DocumentedApi.constants) do
    if target.Constants[name] == nil then
      target.Constants[name] = constants
    end
  end
  target.Enum = target.Enum or {}
  for name, enum in pairs(DocumentedApi.enums) do
    if target.Enum[name] == nil then
      target.Enum[name] = enum
    end
  end
  for name, kinds in pairs(DocumentedApi.functions) do
    if target[name] == nil then
      target[name] = Stub(name, kinds)
    end
  end
  for namespaceName, functions in pairs(DocumentedApi.namespaces) do
    local namespace = target[namespaceName] or {}
    target[namespaceName] = namespace
    for name, kinds in pairs(functions) do
      if namespace[name] == nil then
        namespace[name] = Stub(namespaceName .. "." .. name, kinds)
      end
    end
  end
end

function DocumentedApi.IsKnownEvent(event)
  return DocumentedApi.events[event] ~= nil
end

return DocumentedApi

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Find and replace of a spell, a texture, a font or a sound in many auras at once.
-- A value matches when it equals the searched text under a key of the chosen kind, or in a list held by such a key
-- (auraspellids, auranames). The replacement is one step of the undo history.

local kindWords = {
  spell = { "spell", "aura", "cdmexactids", "cdmnames" },
  texture = { "texture", "icon" },
  font = { "font" },
  sound = { "sound" },
}
-- Keys that hold a setting of the kind rather than the kind itself: text_fontSize, iconSource, sound_repeat...
local settingWords = { "size", "color", "angle", "rotat", "crop", "offset", "inset", "source", "side", "mode",
  "type", "repeat", "channel", "power", "pen", "blend", "wrap", "count", "school", "_x", "_y" }

local function Contains(text, words)
  for _, word in ipairs(words) do
    if text:find(word, 1, true) then
      return true
    end
  end
  return false
end

local function IsKindKey(key, kind)
  if type(key) ~= "string" then
    return false
  end
  key = key:lower()
  return Contains(key, kindWords[kind]) and not Contains(key, settingWords)
end

local function Collect(tbl, path, isKindList, search, occurrences)
  for key, value in pairs(tbl) do
    local valueType = type(value)
    if valueType == "table" then
      path[#path + 1] = key
      Collect(value, path, IsKindKey(key, search.kind), search, occurrences)
      path[#path] = nil
    elseif (valueType == "string" or valueType == "number") and tostring(value) == search.find
      and (isKindList and type(key) == "number" or IsKindKey(key, search.kind)) then
      -- A number stays a number: a replacement that is not one cannot take its place.
      local newValue = search.replacement
      if valueType == "number" then
        newValue = tonumber(newValue)
      end
      if newValue == nil then
        search.skipped = search.skipped + 1
      else
        local valuePath = CopyTable(path)
        valuePath[#valuePath + 1] = key
        tinsert(occurrences, { uid = search.uid, path = valuePath, old = value, new = newValue })
      end
    end
  end
end

--- Occurrences of the value in the auras, each {uid, id, path, pathText, old, new}, sorted by aura id then path,
--- and the count of numbers left out because the replacement is not a number.
---@param datas auraData[]
---@param kind "spell"|"texture"|"font"|"sound"
---@param find string
---@param replacement string
function Private.FindValueOccurrences(datas, kind, find, replacement)
  local occurrences = {}
  local search = { kind = kind, find = find, replacement = replacement, skipped = 0 }
  for _, data in ipairs(datas) do
    -- The auras were picked when the dialog opened: one deleted or restored since then is read again by its uid.
    local current = Private.GetDataByUID(data.uid)
    if current then
      search.uid = data.uid
      Collect(current, {}, false, search, occurrences)
    end
  end
  for _, occurrence in ipairs(occurrences) do
    occurrence.id = Private.UIDtoID(occurrence.uid)
    occurrence.pathText = table.concat(occurrence.path, ".")
  end
  table.sort(occurrences, function(a, b)
    if a.id:lower() ~= b.id:lower() then
      return a.id:lower() < b.id:lower()
    elseif a.id ~= b.id then
      return a.id < b.id
    end
    return a.pathText < b.pathText
  end)
  return occurrences, search.skipped
end

local function ValueAt(data, path)
  local value = data
  for _, key in ipairs(path) do
    if type(value) ~= "table" then
      return nil
    end
    value = value[key]
  end
  return value
end

--- Writes the occurrences as one step of the history, that Undo reverts. An occurrence whose aura is gone or whose
--- value changed since the preview is left out. Returns the count written.
function Private.ReplaceValueOccurrences(occurrences)
  local records = {}
  for _, occurrence in ipairs(occurrences) do
    local data = Private.GetDataByUID(occurrence.uid)
    if data and ValueAt(data, occurrence.path) == occurrence.old and occurrence.old ~= occurrence.new then
      tinsert(records, { uid = occurrence.uid, actionType = "set", path = occurrence.path, payload = occurrence.new })
    end
  end
  if #records > 0 then
    Private.TimeMachine:AppendMany(records)
  end
  return #records
end

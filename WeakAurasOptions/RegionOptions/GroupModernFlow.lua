-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local L = WeakAuras.L

local GROWTH_SORTING = { "RIGHT", "LEFT", "DOWN", "UP", "CENTER_HORIZONTAL", "CENTER_VERTICAL" }
local FRAME_VALUES = { UNITFRAME = L["Unit Frames"], NAMEPLATE = L["Nameplates"] }
local FRAME_SORTING = { "UNITFRAME", "NAMEPLATE" }
local SORT_SORTING = { "Default", "ExpirationOnly", "Expiration", "NameOnly", "Name", "ImportantOnly", "BigDefensive", "AuraInstanceIDOnly" }
local GRID_SORTING = { "RD", "RU", "LD", "LU", "DR", "DL", "UR", "UL" }

local function OrNil(value) return value or nil end

function OptionsPrivate.AddModernFlowGroupOptions(options, data)
  local Display = OptionsPrivate.Private.BlizzardAuraDisplay

  -- Re-adding the group and every child is costly: a burst of edits is saved once, on the next frame.
  local savePending = false
  local function SaveGroup()
    savePending = false
    WeakAuras.Add(data)
    for _, childId in ipairs(data.controlledChildren or {}) do
      local child = WeakAuras.GetData(childId)
      if child then WeakAuras.Add(child) end
    end
    OptionsPrivate.ResetMoverSizer()
    WeakAuras.ClearAndUpdateOptions(data.id)
  end
  local function SaveSoon()
    if savePending then return end
    savePending = true
    C_Timer.After(0, SaveGroup)
  end
  -- A new sort order can often be applied to the live displays without rebuilding the children.
  local function SaveSort()
    if savePending or not Display.ApplyFlowSort(data) then
      SaveSoon()
    else
      WeakAuras.Add(data)
    end
  end

  local function Read(field, fallback)
    return function() return data[field] or fallback end
  end
  local function Write(field, save, convert)
    return function(_, value)
      if convert then value = convert(value) end
      data[field] = value
      save()
    end
  end
  local function Unless(field)
    return function() return not data[field] end
  end
  local spacing = function() return data.blizzardFlowSpacing or 2 end

  local entries = {
    blizzardFlowGrowth = {
      type = "select", order = 0.61, width = WeakAuras.doubleWidth, name = L["Grow"],
      values = Display.flowGrowths, sorting = GROWTH_SORTING,
      get = Read("blizzardFlowGrowth", "RIGHT"), set = Write("blizzardFlowGrowth", SaveSoon),
    },
    blizzardFlowUseFrames = {
      type = "toggle", order = 0.62, name = L["Group by Frame"],
      desc = L["Show the auras on each unit's frame or nameplate. The Position and Size settings place them on the frame."],
      get = function() return data.blizzardFlowFrames ~= nil end,
      set = Write("blizzardFlowFrames", SaveSoon, function(enabled) return enabled and "UNITFRAME" or nil end),
    },
    blizzardFlowFrames = {
      type = "select", order = 0.63, name = L["Group by Frame"], values = FRAME_VALUES, sorting = FRAME_SORTING,
      disabled = function() return data.blizzardFlowFrames == nil end,
      get = Read("blizzardFlowFrames"), set = Write("blizzardFlowFrames", SaveSoon),
    },
    blizzardFlowSpacing = {
      type = "range", order = 0.64, name = L["Space"], min = -20, softMax = 50,
      get = spacing, set = Write("blizzardFlowSpacing", SaveSoon),
    },
    blizzardFlowSpacingSpace = { type = "description", order = 0.645, name = "" },
    blizzardFlowSort = {
      type = "select", order = 0.65, name = L["Sort"], desc = L["The order of the auras inside each display."],
      -- The unit frame debuff order only exists for single displays.
      values = function()
        local methods = CopyTable(Display.sortMethods)
        methods.UnitFrameDebuff = nil
        return methods
      end,
      sorting = SORT_SORTING,
      get = Read("blizzardFlowSort", "Default"), set = Write("blizzardFlowSort", SaveSort),
    },
    blizzardFlowReverse = {
      type = "toggle", order = 0.66, name = L["Reverse Sort"],
      get = Read("blizzardFlowReverse", false), set = Write("blizzardFlowReverse", SaveSort, OrNil),
    },
    blizzardFlowUseLimit = {
      type = "toggle", order = 0.67, name = L["Limit"], desc = L["The most auras each display shows."],
      get = Read("blizzardFlowUseLimit", false), set = Write("blizzardFlowUseLimit", SaveSoon, OrNil),
    },
    blizzardFlowLimit = {
      type = "range", order = 0.68, name = L["Limit"], min = 1, softMax = 40, disabled = Unless("blizzardFlowUseLimit"),
      get = Read("blizzardFlowLimit", 5), set = Write("blizzardFlowLimit", SaveSoon),
    },
    blizzardFlowGrid = {
      type = "toggle", order = 0.69, name = L["Grid"],
      desc = L["Share one display per unit between the auras of this group, and start a new line after a set number of auras."],
      get = Read("blizzardFlowGrid", false), set = Write("blizzardFlowGrid", SaveSoon, OrNil),
    },
    blizzardFlowGridType = {
      type = "select", order = 0.691, name = L["Grid direction"], values = Display.flowGridTypes, sorting = GRID_SORTING,
      disabled = Unless("blizzardFlowGrid"),
      -- Without a stored direction, the grid follows the growth direction.
      get = function() return Display.GridType(data) end, set = Write("blizzardFlowGridType", SaveSoon),
    },
    blizzardFlowPerRow = {
      type = "range", order = 0.692, min = 1, softMax = 20, desc = L["The number of auras on each line."],
      name = function()
        local lead = Display.GridType(data):sub(1, 1)
        return (lead == "R" or lead == "L") and L["Row Width"] or L["Column Height"]
      end,
      disabled = Unless("blizzardFlowGrid"),
      get = Read("blizzardFlowPerRow", 6), set = Write("blizzardFlowPerRow", SaveSoon),
    },
    blizzardFlowGridSpace = { type = "description", order = 0.693, name = "" },
    blizzardFlowRowSpace = {
      type = "range", order = 0.694, name = L["Row Space"], min = -20, softMax = 50, disabled = Unless("blizzardFlowGrid"),
      get = function() return data.blizzardFlowRowSpace or spacing() end, set = Write("blizzardFlowRowSpace", SaveSoon),
    },
    blizzardFlowColumnSpace = {
      type = "range", order = 0.695, name = L["Column Space"], min = -20, softMax = 50, disabled = Unless("blizzardFlowGrid"),
      get = function() return data.blizzardFlowColumnSpace or spacing() end, set = Write("blizzardFlowColumnSpace", SaveSoon),
    },
  }

  local hidden = Unless("blizzardFlow")
  for key, entry in pairs(entries) do
    entry.hidden = hidden
    entry.width = entry.width or WeakAuras.normalWidth
    if entry.type == "range" then
      entry.control = "WeakAurasSpinBox"
      entry.step = 1
    end
    options[key] = entry
  end
end

-- Icon pieces, sized and placed as fractions of the icon side. A piece without a width fills the icon.
-- The picture: three tiles above an underline, in plain colors so it scales to any button size.
local ICON_PIECES = {
  { layer = "ARTWORK", color = { 0.35, 0.75, 1, 0.9 }, width = 0.72, height = 0.05, minHeight = 1, x = 0, y = -0.24 },
  { key = "tile1", layer = "ARTWORK", color = { 0.16, 0.55, 0.95, 1 }, width = 0.24, height = 0.24, x = -0.3, y = 0.06 },
  { key = "tile2", layer = "ARTWORK", color = { 0.35, 0.75, 1, 1 }, width = 0.24, height = 0.24, x = 0, y = 0.06 },
  { key = "tile3", layer = "ARTWORK", color = { 0.6, 0.95, 1, 1 }, width = 0.24, height = 0.24, x = 0.3, y = 0.06 },
  { layer = "BACKGROUND", color = { 0.07, 0.09, 0.13, 1 } },
}

local function PlacePieces(icon, placed)
  local side = math.min(icon:GetWidth(), icon:GetHeight())
  if side <= 0 then return end
  for texture, piece in pairs(placed) do
    texture:ClearAllPoints()
    texture:SetSize(piece.width * side, math.max(piece.minHeight or 0, piece.height * side))
    texture:SetPoint("CENTER", icon, "CENTER", piece.x * side, piece.y * side)
  end
end

function OptionsPrivate.CreateModernGroupIcon()
  local icon = CreateFrame("Frame", nil, UIParent)
  local placed = {}
  for _, piece in ipairs(ICON_PIECES) do
    local texture = icon:CreateTexture(nil, piece.layer)
    texture:SetColorTexture(unpack(piece.color))
    if piece.key then icon[piece.key] = texture end
    if piece.width then
      placed[texture] = piece
    else
      texture:SetAllPoints()
    end
  end
  icon:SetScript("OnSizeChanged", function() PlacePieces(icon, placed) end)
  icon:SetSize(32, 32)
  PlacePieces(icon, placed)
  return icon
end

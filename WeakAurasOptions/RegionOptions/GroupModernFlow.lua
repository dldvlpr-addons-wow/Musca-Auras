if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local L = WeakAuras.L

function OptionsPrivate.AddModernFlowGroupOptions(options, data)
  local Display = OptionsPrivate.Private.BlizzardAuraDisplay
  local pendingFlowSave
  local function SaveFlow(key, value)
    data[key] = value
    if pendingFlowSave then return end
    pendingFlowSave = true
    C_Timer.After(0, function()
      pendingFlowSave = nil
      WeakAuras.Add(data)
      for _, childId in ipairs(data.controlledChildren) do
        local childData = WeakAuras.GetData(childId)
        if childData then WeakAuras.Add(childData) end
      end
      OptionsPrivate.ResetMoverSizer()
      WeakAuras.ClearAndUpdateOptions(data.id)
    end)
  end
  local function FlowOff() return not data.blizzardFlow end
  options.blizzardFlowGrowth = {
    type = "select", width = WeakAuras.doubleWidth, order = 0.61, name = L["Grow"],
    values = Display.flowGrowths, sorting = {"RIGHT", "LEFT", "DOWN", "UP", "CENTER_HORIZONTAL", "CENTER_VERTICAL"}, hidden = FlowOff,
    get = function() return data.blizzardFlowGrowth or "RIGHT" end,
    set = function(_, v) SaveFlow("blizzardFlowGrowth", v) end,
  }
  options.blizzardFlowUseFrames = {
    type = "toggle", width = WeakAuras.normalWidth, order = 0.62, name = L["Group by Frame"], hidden = FlowOff,
    desc = "Show the auras on each unit's frame or nameplate. The Position and Size settings place them on the frame.",
    get = function() return data.blizzardFlowFrames ~= nil end,
    set = function(_, v) SaveFlow("blizzardFlowFrames", v and "UNITFRAME" or nil) end,
  }
  options.blizzardFlowFrames = {
    type = "select", width = WeakAuras.normalWidth, order = 0.63, name = L["Group by Frame"], hidden = FlowOff,
    values = {UNITFRAME = "Unit Frames", NAMEPLATE = "Nameplates"}, sorting = {"UNITFRAME", "NAMEPLATE"},
    disabled = function() return data.blizzardFlowFrames == nil end,
    get = function() return data.blizzardFlowFrames end,
    set = function(_, v) SaveFlow("blizzardFlowFrames", v) end,
  }
  options.blizzardFlowSpacing = {
    type = "range", control = "WeakAurasSpinBox", width = WeakAuras.normalWidth, order = 0.64, name = L["Space"],
    min = -20, softMax = 50, step = 1, hidden = FlowOff,
    get = function() return data.blizzardFlowSpacing or 2 end,
    set = function(_, v) SaveFlow("blizzardFlowSpacing", v) end,
  }
  options.blizzardFlowSpacingSpace = {type = "description", name = "", order = 0.645, width = WeakAuras.normalWidth, hidden = FlowOff}
  options.blizzardFlowSort = {
    type = "select", width = WeakAuras.normalWidth, order = 0.65, name = L["Sort"], hidden = FlowOff,
    values = function()
      local values = CopyTable(Display.sortMethods)
      values.UnitFrameDebuff = nil
      return values
    end,
    sorting = {"Default", "ExpirationOnly", "Expiration", "NameOnly", "Name", "ImportantOnly", "BigDefensive", "AuraInstanceIDOnly"},
    desc = "The order of the auras inside each display.",
    get = function() return data.blizzardFlowSort or "Default" end,
    set = function(_, v) SaveFlow("blizzardFlowSort", v) end,
  }
  options.blizzardFlowReverse = {
    type = "toggle", width = WeakAuras.normalWidth, order = 0.66, name = "Reverse Sort", hidden = FlowOff,
    get = function() return data.blizzardFlowReverse or false end,
    set = function(_, v) SaveFlow("blizzardFlowReverse", v or nil) end,
  }
  options.blizzardFlowUseLimit = {
    type = "toggle", width = WeakAuras.normalWidth, order = 0.67, name = L["Limit"], hidden = FlowOff,
    desc = "The most auras each display shows.",
    get = function() return data.blizzardFlowUseLimit or false end,
    set = function(_, v) SaveFlow("blizzardFlowUseLimit", v or nil) end,
  }
  options.blizzardFlowLimit = {
    type = "range", control = "WeakAurasSpinBox", width = WeakAuras.normalWidth, order = 0.68, name = L["Limit"],
    min = 1, softMax = 40, step = 1, hidden = FlowOff,
    disabled = function() return not data.blizzardFlowUseLimit end,
    get = function() return data.blizzardFlowLimit or 5 end,
    set = function(_, v) SaveFlow("blizzardFlowLimit", v) end,
  }
end

function OptionsPrivate.CreateModernGroupIcon()
  local icon = CreateFrame("Frame", nil, UIParent)
  icon:SetSize(32, 32)
  local background = icon:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints(icon)
  background:SetColorTexture(0.07, 0.09, 0.13, 1)
  local colors = {{0.16, 0.55, 0.95}, {0.35, 0.75, 1}, {0.6, 0.95, 1}}
  for index, color in ipairs(colors) do
    local tile = icon:CreateTexture(nil, "ARTWORK")
    tile:SetColorTexture(color[1], color[2], color[3], 1)
    icon["tile" .. index] = tile
  end
  local accent = icon:CreateTexture(nil, "ARTWORK")
  accent:SetColorTexture(0.35, 0.75, 1, 0.9)
  local function Layout(self)
    local size = math.min(self:GetWidth() or 0, self:GetHeight() or 0)
    if size <= 0 then return end
    local tile, gap = size * 0.24, size * 0.06
    for index = 1, 3 do
      local t = self["tile" .. index]
      t:ClearAllPoints()
      t:SetSize(tile, tile)
      t:SetPoint("CENTER", self, "CENTER", (index - 2) * (tile + gap), size * 0.06)
    end
    accent:ClearAllPoints()
    accent:SetSize(size * 0.72, math.max(1, size * 0.05))
    accent:SetPoint("CENTER", self, "CENTER", 0, -size * 0.24)
  end
  icon:SetScript("OnSizeChanged", Layout)
  Layout(icon)
  return icon
end

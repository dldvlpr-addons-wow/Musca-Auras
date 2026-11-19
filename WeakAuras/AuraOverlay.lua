-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
-- WeakAuras.CreateAuraSlot(frame, options): a native aura slot drawn over any frame, for custom code. The client
-- fills it while one of the listed spell IDs is on the unit and runs its timer, so no aura value is read in Lua.
--   helpful, harmful (spell ID lists), unit ("player"), filter ("HELPFUL", for the helpful list), icon, texture,
--   texCoord, timer, swipe, reverse, timerText, timerFont, timerFontSize, timerFontFlags, timerPoint, timerX, timerY,
--   timerColor, stacks, stackFontSize, border, borderSize, levelAbove (5), enabled.
-- Methods: SetSpells(helpful, harmful), SetUnit, SetEnabled, SetBorderColor, SetTexture, GetSlotButton, Release.
-- SetSpells and SetUnit return false and the error when the client refuses the change; call them again later.
-- Returns nil and a message when the client has no aura containers or refuses the slot (for example in combat).
if not WeakAuras.IsLibsOK() then return end

local DEFAULT_BORDER = { 1, 0.85, 0, 1 }
local EDGES = { "TOP", "BOTTOM", "LEFT", "RIGHT" }

local Slot = {}
Slot.__index = Slot

-- includeSpellIDs = {} matches nothing, which is what an empty list means here.
local function CandidateFilters(list)
  local included = {}
  for _, value in ipairs(type(list) == "table" and list or {}) do
    local spellID = tonumber(value)
    if spellID then included[spellID] = true end
  end
  return { includeSpellIDs = included }
end

local function AddTimerText(cooldown, button, options)
  local numbers = cooldown:GetCountdownFontString()
  if not numbers then return end
  numbers:SetFont(options.timerFont or STANDARD_TEXT_FONT, tonumber(options.timerFontSize) or 12,
    options.timerFontFlags or "OUTLINE")
  local point = options.timerPoint or "CENTER"
  numbers:ClearAllPoints()
  numbers:SetPoint(point, button, point, tonumber(options.timerX) or 0, tonumber(options.timerY) or 0)
  local color = options.timerColor
  if type(color) == "table" then
    numbers:SetTextColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
  end
end

-- Look of one slot button, built once; the client shows and hides it.
local function Decorate(look, button, container, options)
  look.button = button
  button:SetAllPoints(container)
  button:EnableMouse(false)
  if options.texture then
    look.texture = button:CreateTexture(nil, "BACKGROUND")
    look.texture:SetAllPoints(button)
    look.texture:SetTexture(options.texture)
    if type(options.texCoord) == "table" then look.texture:SetTexCoord(unpack(options.texCoord)) end
  end
  if options.icon then
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button:SetIcon(icon)
  end
  if options.timer ~= false then
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawSwipe(options.swipe ~= false)
    cooldown:SetReverse(options.reverse == true)
    cooldown:SetHideCountdownNumbers(options.timerText == false)
    cooldown:SetUseAuraDisplayTime(true)
    button:SetDurationCooldown(cooldown)
    if options.timerText ~= false then AddTimerText(cooldown, button, options) end
  end
  if options.stacks then
    local text = button:CreateFontString(nil, "OVERLAY")
    text:SetFont(STANDARD_TEXT_FONT, tonumber(options.stackFontSize) or 12, "OUTLINE")
    text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button:SetApplicationCount(text)
  end
  look.edges = {}
  if options.border ~= false then
    local size = tonumber(options.borderSize) or 2
    local color = type(options.border) == "table" and options.border or DEFAULT_BORDER
    for _, side in ipairs(EDGES) do
      local edge = button:CreateTexture(nil, "OVERLAY")
      edge:SetColorTexture(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
      if side == "TOP" or side == "BOTTOM" then
        edge:SetPoint(side .. "LEFT")
        edge:SetPoint(side .. "RIGHT")
        edge:SetHeight(size)
      else
        edge:SetPoint("TOP" .. side)
        edge:SetPoint("BOTTOM" .. side)
        edge:SetWidth(size)
      end
      look.edges[#look.edges + 1] = edge
    end
  end
end

-- Runs a container change with the container off, as the client wants, then restores the wanted state.
function Slot:Change(change)
  self.container:SetEnabled(false)
  local ok, err = pcall(change, self.container)
  self.container:SetEnabled(self.enabled)
  return ok, err
end

-- One container slot per list: the helpful list uses options.filter, the harmful list "HARMFUL". Added when needed.
function Slot:Fill(name, filter, list)
  if self.looks[name] then
    return self:Change(function(container) container:SetAuraSlotCandidateFilters(name, CandidateFilters(list)) end)
  end
  local look = {}
  local ok, err = self:Change(function(container)
    container:AddAuraSlot(name, filter, {
      candidateFilters = CandidateFilters(list),
      initializeFrame = function(button) Decorate(look, button, self.container, self.options) end,
    })
  end)
  if ok then self.looks[name] = look end
  return ok, err
end

function Slot:SetSpells(helpful, harmful)
  if self.released then return false, "released" end
  local ok, err = self:Fill("Helpful", self.filter, helpful)
  if ok and (self.looks.Harmful or (type(harmful) == "table" and #harmful > 0)) then
    ok, err = self:Fill("Harmful", "HARMFUL", harmful)
  end
  return ok, err
end

function Slot:SetUnit(unit)
  if self.released then return false, "released" end
  if unit == self.unit then return true end
  local ok, err = self:Change(function(container) container:SetUnit(unit) end)
  if ok then self.unit = unit end
  return ok, err
end

function Slot:SetEnabled(enabled)
  if self.released then return end
  self.enabled = enabled ~= false
  self.container:SetEnabled(self.enabled)
end

function Slot:SetBorderColor(r, g, b, a)
  for _, look in pairs(self.looks) do
    for _, edge in ipairs(look.edges or {}) do edge:SetColorTexture(r, g, b, a or 1) end
  end
end

function Slot:SetTexture(texture, texCoord)
  for _, look in pairs(self.looks) do
    if look.texture then
      look.texture:SetTexture(texture)
      if type(texCoord) == "table" then look.texture:SetTexCoord(unpack(texCoord)) end
    end
  end
end

function Slot:GetSlotButton()
  return self.looks.Helpful and self.looks.Helpful.button
end

function Slot:Release()
  if self.released then return end
  self.released = true
  self.container:SetEnabled(false)
  self.container:Hide()
end

function WeakAuras.CreateAuraSlot(parent, options)
  options = type(options) == "table" and options or {}
  if type(parent) ~= "table" or type(parent.GetFrameLevel) ~= "function" then
    return nil, "CreateAuraSlot needs a frame to draw over."
  end
  if CustomAuraContainerAuraProcessingPolicy == nil then
    return nil, "This client has no aura containers."
  end
  local container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
  container:SetEnabled(false)
  container:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.None)
  container:SetAllPoints(parent)
  container:SetFrameLevel(parent:GetFrameLevel() + (tonumber(options.levelAbove) or 5))
  -- The slot never takes clicks from the frame under it.
  pcall(container.EnableMouse, container, false)
  local slot = setmetatable({
    container = container, options = options, looks = {}, unit = options.unit or "player",
    filter = options.filter or "HELPFUL", enabled = false,
  }, Slot)
  local ok, err = slot:Fill("Helpful", slot.filter, options.helpful)
  if ok and type(options.harmful) == "table" and #options.harmful > 0 then
    ok, err = slot:Fill("Harmful", "HARMFUL", options.harmful)
  end
  if not ok then
    container:Hide()
    return nil, "The client refused the aura slot: " .. tostring(err)
  end
  container:SetUnit(slot.unit)
  slot:SetEnabled(options.enabled)
  return slot
end

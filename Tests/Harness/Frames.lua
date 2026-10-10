local Clock = require("Clock")
local Secret = require("Secret")
local DocumentedApi = require("DocumentedApi")

local Frames = {
  all = {},
  eventFrames = {},
  missingMethods = {},
  forbiddenEvents = {},
  unknownEvents = {},
}

local Methods = {}
local metatable = {}
local State = setmetatable({}, { __mode = "k" })
Frames.State = State

local frameTypes = {
  Frame = true, Button = true, CheckButton = true, StatusBar = true, Cooldown = true, EditBox = true,
  ScrollFrame = true, Slider = true, Model = true, PlayerModel = true, ModelScene = true, MessageFrame = true,
  ScrollingMessageFrame = true, GameTooltip = true, SimpleHTML = true, ColorSelect = true, DressUpModel = true,
  CinematicModel = true, Minimap = true, MovieFrame = true, Browser = true, Checkout = true,
}

local function Protect(handler, ...)
  return Frames.protect(handler, ...)
end

local function NewObject(objectType, name, parent)
  local object = setmetatable({}, metatable)
  State[object] = {
    objectType = objectType,
    name = name,
    parent = parent,
    shown = true,
    alpha = 1,
    scale = 1,
    width = 0,
    height = 0,
    points = {},
    scripts = {},
    hooks = {},
    events = {},
    unitEvents = {},
    children = {},
    regions = {},
    frameLevel = parent and State[parent].frameLevel + 1 or 0,
    strata = "MEDIUM",
    vertexColor = { 1, 1, 1, 1 },
  }
  Frames.all[#Frames.all + 1] = object
  if parent then
    if frameTypes[objectType] then
      State[parent].children[#State[parent].children + 1] = object
    else
      State[parent].regions[#State[parent].regions + 1] = object
    end
  end
  if name and name ~= "" then
    if parent and name:find("$parent", 1, true) then
      name = name:gsub("%$parent", parent:GetName() or "")
      State[object].name = name
    end
    _G[name] = object
  end
  return object
end

metatable.__index = function(object, key)
  local method = Methods[key]
  if method then
    return method
  end
  if DocumentedApi.widgetMethods[key] then
    return function()
      Frames.missingMethods[key] = (Frames.missingMethods[key] or 0) + 1
    end
  end
  return nil
end

function Frames.CreateFrame(frameType, name, parent, template)
  if parent == nil and frameType ~= "GameTooltip" then
    parent = nil
  end
  local frame = NewObject(frameType or "Frame", name, parent)
  State[frame].template = template
  return frame
end

function Frames.Fire(event, ...)
  if DocumentedApi.events and next(DocumentedApi.events) and not DocumentedApi.IsKnownEvent(event) then
    error("Frames.Fire: unknown event " .. tostring(event), 2)
  end
  local listeners = {}
  for _, frame in ipairs(Frames.eventFrames) do
    if State[frame].events[event] then
      local units = State[frame].unitEvents[event]
      local unit = ...
      if not units or units[unit] then
        listeners[#listeners + 1] = frame
      end
    end
  end
  for _, frame in ipairs(listeners) do
    if State[frame].events[event] then
      local handler = State[frame].scripts.OnEvent
      if handler then
        Protect(handler, frame, event, ...)
      end
    end
  end
end

local function RunScript(object, scriptName, ...)
  local handler = State[object].scripts[scriptName]
  if handler then
    Protect(handler, object, ...)
  end
end

function Methods:GetObjectType() return State[self].objectType end
function Methods:IsObjectType(objectType)
  return State[self].objectType == objectType or objectType == "Region" or objectType == "Object"
    or (objectType == "Frame" and frameTypes[State[self].objectType] == true)
end
function Methods:GetName() return State[self].name end
function Methods:GetDebugName() return State[self].name or tostring(self) end
function Methods:GetParent() return State[self].parent end
local function Blocked(object, method)
  if not (rawget(_G, "InCombatLockdown") and _G.InCombatLockdown() and object:IsProtected()) then return false end
  Frames.onForbidden("ADDON_ACTION_BLOCKED: Frame:" .. method .. "()")
  return true
end

function Frames.SetProtected(object, protected)
  State[object].protected = protected
end

function Methods:SetParent(parent)
  if Blocked(self, "SetParent") then return end
  if State[self].parent then
    for _, list in ipairs({ State[State[self].parent].children or {}, State[State[self].parent].regions or {} }) do
      for index = #list, 1, -1 do
        if list[index] == self then
          table.remove(list, index)
        end
      end
    end
  end
  State[self].parent = parent
  if parent then
    if frameTypes[State[self].objectType] then
      State[parent].children[#State[parent].children + 1] = self
    else
      State[parent].regions[#State[parent].regions + 1] = self
    end
  end
end
function Methods:GetChildren() return unpack(State[self].children) end
function Methods:GetNumChildren() return #State[self].children end
function Methods:GetRegions() return unpack(State[self].regions) end
function Methods:GetNumRegions() return #State[self].regions end

function Methods:Show()
  if not State[self].shown then
    State[self].shown = true
    if self:IsVisible() then
      RunScript(self, "OnShow")
    end
  end
end
function Methods:Hide()
  if State[self].shown then
    local wasVisible = self:IsVisible()
    State[self].shown = false
    if wasVisible then
      RunScript(self, "OnHide")
    end
  end
end
function Methods:SetShown(shown)
  if shown then self:Show() else self:Hide() end
end
function Methods:IsShown() return State[self].shown end
function Methods:IsVisible()
  local object = self
  while object do
    if not State[object].shown then
      return false
    end
    object = State[object].parent
  end
  return true
end

function Methods:SetScript(scriptName, handler)
  State[self].scripts[scriptName] = handler
  if scriptName == "OnUpdate" then
    Clock.updateFrames[self] = handler and true or nil
  end
end
function Methods:GetScript(scriptName) return State[self].scripts[scriptName] end
function Methods:HasScript() return true end
function Methods:HookScript(scriptName, hook)
  local previous = State[self].scripts[scriptName]
  self:SetScript(scriptName, function(...)
    if previous then previous(...) end
    hook(...)
  end)
end

local function TrackEvents(frame)
  for _, registered in ipairs(Frames.eventFrames) do
    if registered == frame then
      return
    end
  end
  Frames.eventFrames[#Frames.eventFrames + 1] = frame
end

function Methods:RegisterEvent(event)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
    Frames.forbiddenEvents[#Frames.forbiddenEvents + 1] = event
    Frames.onForbidden("ADDON_ACTION_FORBIDDEN: RegisterEvent(" .. event .. ")")
    return
  end
  if next(DocumentedApi.events) and not DocumentedApi.IsKnownEvent(event) then
    Frames.unknownEvents[event] = true
    error("Attempt to register unknown event \"" .. tostring(event) .. "\"", 2)
  end
  State[self].events[event] = true
  State[self].unitEvents[event] = nil
  TrackEvents(self)
  return true
end
function Methods:RegisterUnitEvent(event, ...)
  self:RegisterEvent(event)
  if State[self].events[event] and select("#", ...) > 0 then
    local units = {}
    for index = 1, select("#", ...) do
      local unit = select(index, ...)
      if unit then units[unit] = true end
    end
    State[self].unitEvents[event] = units
  end
  return true
end
function Methods:UnregisterEvent(event)
  State[self].events[event] = nil
  State[self].unitEvents[event] = nil
end
function Methods:UnregisterAllEvents()
  State[self].events = {}
  State[self].unitEvents = {}
end
function Methods:IsEventRegistered(event) return State[self].events[event] == true end

function Methods:CreateTexture(name, layer)
  local texture = NewObject("Texture", name, self)
  State[texture].layer = layer
  return texture
end
function Methods:CreateMaskTexture(name, layer)
  return NewObject("MaskTexture", name, self)
end
function Methods:CreateLine(name, layer)
  return NewObject("Line", name, self)
end
function Methods:CreateFontString(name, layer, fontObject)
  local fontString = NewObject("FontString", name, self)
  State[fontString].layer = layer
  return fontString
end
function Methods:CreateAnimationGroup(name)
  local group = NewObject("AnimationGroup", name, self)
  State[group].animations = {}
  return group
end
function Methods:CreateAnimation(animationType, name)
  local animation = NewObject(animationType or "Animation", name, self)
  State[self].animations = State[self].animations or {}
  State[self].animations[#State[self].animations + 1] = animation
  return animation
end
function Methods:GetAnimations() return unpack(State[self].animations or {}) end
function Methods:Play()
  State[self].playing = true
  RunScript(self, "OnPlay")
end
function Methods:Stop()
  if State[self].playing then
    State[self].playing = false
    RunScript(self, "OnStop")
  end
end
function Methods:Pause() State[self].playing = false end
function Methods:Finish() self:Stop() end
function Methods:IsPlaying() return State[self].playing == true end
function Methods:IsPaused() return false end

function Methods:SetText(text)
  if text ~= nil and not Secret.IsSecret(text) and type(text) ~= "string" and type(text) ~= "number" then
    error("Usage: FontString:SetText(text) got " .. type(text), 2)
  end
  State[self].text = text
end
function Methods:GetText() return State[self].text end
function Methods:SetFormattedText(formatString, ...)
  State[self].text = string.format(formatString, ...)
end
function Methods:GetStringWidth()
  local text = State[self].text
  if Secret.IsSecret(text) then
    return Secret.Wrap(#tostring(Secret.Reveal(text)) * 7)
  end
  return text and #tostring(text) * 7 or 0
end
function Methods:GetUnboundedStringWidth() return self:GetStringWidth() end
function Methods:GetStringHeight() return 12 end
function Methods:SetFont(path, size, flags)
  if flags == nil then
    error("Usage: FontString:SetFont(path, size, flags) flags must not be nil", 2)
  end
  State[self].font = { path, size, flags }
  return true
end
function Methods:GetFont()
  if State[self].font then
    return unpack(State[self].font)
  end
  return "Fonts\\FRIZQT__.TTF", 12, ""
end
function Methods:SetFontObject(fontObject) State[self].fontObject = fontObject end
function Methods:GetFontObject() return State[self].fontObject end
function Methods:CopyFontObject(fontObject) State[self].fontObject = fontObject end

function Methods:SetTexture(texture)
  State[self].texture = texture
  return true
end
function Methods:GetTexture() return State[self].texture end
function Methods:GetTextureFileID() return type(State[self].texture) == "number" and State[self].texture or nil end
function Methods:SetAtlas(atlas) State[self].atlas = atlas return true end
function Methods:GetAtlas() return State[self].atlas end
function Methods:SetColorTexture(r, g, b, a) State[self].colorTexture = { r, g, b, a } end
function Methods:SetVertexColor(r, g, b, a) State[self].vertexColor = { r, g, b, a or 1 } end
function Methods:GetVertexColor() return unpack(State[self].vertexColor) end
function Methods:SetDesaturated(value) State[self].desaturated = value end
function Methods:IsDesaturated() return State[self].desaturated end
function Methods:SetTexCoord(...) State[self].texCoord = { ... } end
function Methods:GetTexCoord()
  if State[self].texCoord then return unpack(State[self].texCoord) end
  return 0, 0, 0, 1, 1, 0, 1, 1
end

function Methods:SetPoint(point, relativeTo, relativePoint, x, y)
  if Blocked(self, "SetPoint") then return end
  if type(relativeTo) == "number" then
    relativeTo, relativePoint, x, y = nil, nil, relativeTo, relativePoint
  end
  State[self].points[#State[self].points + 1] = { point, relativeTo or State[self].parent, relativePoint or point, x or 0, y or 0 }
end
function Methods:SetAllPoints(relativeTo)
  if Blocked(self, "SetAllPoints") then return end
  State[self].points = {
    { "TOPLEFT", relativeTo or State[self].parent, "TOPLEFT", 0, 0 },
    { "BOTTOMRIGHT", relativeTo or State[self].parent, "BOTTOMRIGHT", 0, 0 },
  }
end
function Methods:ClearAllPoints()
  if Blocked(self, "ClearAllPoints") then return end
  State[self].points = {}
end
function Methods:ClearPoint(point)
  for index = #State[self].points, 1, -1 do
    if State[self].points[index][1] == point then table.remove(State[self].points, index) end
  end
end
function Methods:GetNumPoints() return #State[self].points end
function Methods:GetPoint(index)
  local point = State[self].points[index or 1]
  if point then return unpack(point) end
end
function Methods:GetPointByName(name)
  for _, point in ipairs(State[self].points) do
    if point[1] == name then return unpack(point) end
  end
end
function Methods:SetSize(width, height)
  State[self].width, State[self].height = width, height or width
  RunScript(self, "OnSizeChanged", State[self].width, State[self].height)
end
function Methods:SetWidth(width) self:SetSize(width, State[self].height) end
function Methods:SetHeight(height) self:SetSize(State[self].width, height) end
function Methods:GetWidth() return State[self].width end
function Methods:GetHeight() return State[self].height end
function Methods:GetSize() return State[self].width, State[self].height end
function Methods:GetRect() return 0, 0, State[self].width, State[self].height end
function Methods:GetCenter() return 500, 400 end
function Methods:GetLeft() return 500 - State[self].width / 2 end
function Methods:GetRight() return 500 + State[self].width / 2 end
function Methods:GetTop() return 400 + State[self].height / 2 end
function Methods:GetBottom() return 400 - State[self].height / 2 end
function Methods:SetAlpha(alpha) State[self].alpha = alpha end
function Methods:GetAlpha() return State[self].alpha end
function Methods:GetEffectiveAlpha() return State[self].alpha end
function Methods:SetScale(scale) State[self].scale = scale end
function Methods:GetScale() return State[self].scale end
function Methods:GetEffectiveScale() return State[self].scale end
function Methods:SetFrameLevel(level) State[self].frameLevel = level end
function Methods:GetFrameLevel() return State[self].frameLevel end
function Methods:SetFrameStrata(strata) State[self].strata = strata end
function Methods:GetFrameStrata() return State[self].strata end
function Methods:SetDrawLayer(layer, subLevel) State[self].layer, State[self].subLevel = layer, subLevel end
function Methods:GetDrawLayer() return State[self].layer or "ARTWORK", State[self].subLevel or 0 end
function Methods:IsForbidden() return false end
function Methods:IsProtected()
  if State[self].protected then return true end
  for _, child in ipairs(State[self].children or {}) do
    if child:IsProtected() then return true end
  end
  return false
end
function Methods:GetID() return State[self].id or 0 end
function Methods:SetID(id) State[self].id = id end
function Methods:IsMouseOver() return false end
function Methods:IsMouseEnabled() return State[self].mouseEnabled end
function Methods:EnableMouse(enabled) State[self].mouseEnabled = enabled end

function Methods:SetMinMaxValues(minValue, maxValue) State[self].minValue, State[self].maxValue = minValue, maxValue end
function Methods:GetMinMaxValues() return State[self].minValue or 0, State[self].maxValue or 1 end
function Methods:SetValue(value) State[self].value = value end
function Methods:GetValue() return State[self].value or 0 end
function Methods:SetStatusBarTexture(texture)
  if type(texture) == "table" then
    State[self].statusBarTexture = texture
  else
    State[self].statusBarTexture = State[self].statusBarTexture or NewObject("Texture", nil, self)
    State[State[self].statusBarTexture].texture = texture
  end
end
function Methods:GetStatusBarTexture()
  State[self].statusBarTexture = State[self].statusBarTexture or NewObject("Texture", nil, self)
  return State[self].statusBarTexture
end
function Methods:SetTimerDuration(duration) State[self].timerDuration = duration end

function Methods:SetCooldown(start, duration)
  State[self].cooldown = { start = start, duration = duration }
end
function Methods:SetCooldownFromDurationObject(duration) State[self].cooldown = { durationObject = duration } end
function Methods:GetCountdownFontString()
  State[self].countdown = State[self].countdown or self:CreateFontString(nil, "OVERLAY")
  return State[self].countdown
end
function Methods:GetCooldownTimes()
  if State[self].cooldown and State[self].cooldown.start then
    return State[self].cooldown.start * 1000, State[self].cooldown.duration * 1000
  end
  return 0, 0
end
function Methods:Clear() State[self].cooldown = nil end

function Methods:SetAttribute(key, value)
  State[self].attributes = State[self].attributes or {}
  State[self].attributes[key] = value
  local handler = State[self].scripts.OnAttributeChanged
  if handler then
    handler(self, key, value)
  end
end
function Methods:GetAttribute(key) return State[self].attributes and State[self].attributes[key] end

function Methods:AddMessage(message)
  Frames.onPrint(message)
end

function Frames.CreateFont(name)
  local font = NewObject("Font", name)
  return font
end

function Frames.Install(target, protect, onPrint, onForbidden)
  Frames.protect = protect
  Frames.onPrint = onPrint
  Frames.onForbidden = onForbidden
  target.CreateFrame = Frames.CreateFrame
  target.CreateFont = Frames.CreateFont
  target.UIParent = Frames.CreateFrame("Frame", "UIParent")
  State[target.UIParent].width, State[target.UIParent].height = 1920, 1080
  target.WorldFrame = Frames.CreateFrame("Frame", "WorldFrame")
  target.GameTooltip = Frames.CreateFrame("GameTooltip", "GameTooltip", target.UIParent)
  target.ItemRefTooltip = Frames.CreateFrame("GameTooltip", "ItemRefTooltip", target.UIParent)
  target.DEFAULT_CHAT_FRAME = Frames.CreateFrame("ScrollingMessageFrame", "ChatFrame1", target.UIParent)
  target.UIErrorsFrame = Frames.CreateFrame("MessageFrame", "UIErrorsFrame", target.UIParent)
  target.Minimap = Frames.CreateFrame("Minimap", "Minimap", target.UIParent)
  for _, fontName in ipairs({ "GameFontNormal", "GameFontHighlight", "GameFontHighlightLarge", "GameFontNormalHuge",
    "GameFontNormalLarge", "GameFontNormalSmall", "GameFontNormalSmall2", "GameFontHighlightSmall",
    "GameFontDisable", "GameFontDisableSmall", "ChatFontNormal", "NumberFontNormal", "SystemFont_Shadow_Med1" })
  do
    target[fontName] = Frames.CreateFont(fontName)
  end
end

return Frames

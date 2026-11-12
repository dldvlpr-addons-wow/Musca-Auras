if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...
--[[-----------------------------------------------------------------------------
ToolbarButton Widget, based on AceGUI Button
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "WeakAurasToolbarButton", 9
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

-- Look of DESIGN.md: no fill, icon and text in the secondary text color, the raised fill and the text color under
-- the mouse, a brass icon and a 2 pixel brass line under it while a toggle is on, 45 % alpha when disabled.
local function Paint(self)
	local Style = OptionsPrivate.Private.Style
	local over = self.over and not self.disabled
	-- The links of the footer only change color under the mouse.
	self.background:SetShown(over and not self.smallFont)
	self.underline:SetShown(self.active == true)
	local base = self.smallFont and "textQuiet" or "textSecondary"
	-- A button that deletes turns red under the mouse.
	local iconColor = self.active and "primary" or over and (self.danger and "error" or "text") or base
	if self.tinted then
		self.icon:SetVertexColor(Style.Color(iconColor))
	end
	for _, part in ipairs(self.glyph) do
		part:SetVertexColor(Style.Color(iconColor))
	end
	self.text:SetTextColor(Style.Color((over or self.active) and "text" or base))
	self.frame:SetAlpha(self.disabled and 0.45 or 1)
end

-- An addon font may not be loaded when the button is made: the text is measured again once shown.
local function Fit(self)
	local text = self.text:GetText()
	if text and text ~= "" then
		self:SetWidth(self.text:GetStringWidth() + 24 + 2 * self.pad)
	else
		self:SetWidth(16 + 2 * self.pad)
	end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame, ...)
	AceGUI:ClearFocus()
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
	frame.obj:Fire("OnClick", ...)
end

local function Control_OnEnter(frame)
	frame.obj.over = true
	Paint(frame.obj)
	if frame.tooltip then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(frame, "ANCHOR_NONE");
		GameTooltip:SetPoint("BOTTOM", frame, "TOP", 0, 5);
		GameTooltip:AddLine(frame.tooltip)
		GameTooltip:Show()
	end
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj.over = nil
	Paint(frame.obj)
	GameTooltip:Hide()
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self.active = nil
		self.over = nil
		self.icon:SetSize(16, 16)
		self.icon:SetTexCoord(0, 1, 0, 1)
		self.icon:Show()
		self.iconOffset = 0
		for _, part in ipairs(self.glyph) do
			part:Hide()
			table.insert(self.spareGlyph, part)
		end
		self.glyph = {}
		self.danger = nil
		self:SetHeight(16)
		self:SetWidth(16)
		self:SetSmallFont(false)
		self:SetDisabled(false)
		self:SetText()
	end,

	-- ["OnRelease"] = nil,

	-- The 16 pixel icon stays centered vertically: a 24 pixel button gets 4 pixels around it.
	["OnHeightSet"] = function(self, height)
		self.pad = math.max(0, (height - 16) / 2)
		self.icon:ClearAllPoints()
		self.icon:SetPoint("LEFT", self.frame, "LEFT", self.pad + self.iconOffset, 0)
		self.text:ClearAllPoints()
		self.text:SetPoint("TOPLEFT", 20 + self.pad, -1)
		self.text:SetPoint("BOTTOMRIGHT", -4 - self.pad, 1)
	end,

	["SetText"] = function(self, text)
		self.text:SetText(text)
		Fit(self)
	end,

	["SetTooltip"] = function(self, text)
		self.frame.tooltip = text
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
		Paint(self)
	end,

	-- The icons of the addon are tinted with the text colors; another texture keeps its own colors.
	["SetTexture"] = function(self, path)
		self.icon:SetTexture(path)
		self.tinted = type(path) == "string" and path:find("^Interface[\\/]AddOns[\\/]WeakAuras[\\/]") ~= nil
		self.icon:SetDesaturated(self.tinted)
		if not self.tinted then
			self.icon:SetVertexColor(1, 1, 1)
		end
		Paint(self)
	end,
	-- Only the drawn part of the texture, width x height pixels: a small drawing in a large texture stays readable.
	["SetIconCoords"] = function(self, left, right, top, bottom, width, height)
		self.icon:SetTexCoord(left, right, top, bottom)
		self.icon:SetSize(width, height)
		-- Centered in the 16 pixel place of the icon.
		self.iconOffset = (16 - width) / 2
		self.icon:SetPoint("LEFT", self.frame, "LEFT", self.pad + self.iconOffset, 0)
	end,
	-- An icon drawn with flat bars instead of a texture, each { width, height, x, y, rotation } from the center of
	-- the icon, tinted as the icon.
	["SetGlyph"] = function(self, bars)
		self.icon:Hide()
		for _, part in ipairs(self.glyph) do
			part:Hide()
			table.insert(self.spareGlyph, part)
		end
		self.glyph = {}
		for _, bar in ipairs(bars) do
			local part = table.remove(self.spareGlyph) or self.frame:CreateTexture(nil, "ARTWORK")
			part:SetTexture("Interface\\Buttons\\WHITE8X8")
			part:SetSize(bar[1], bar[2])
			part:ClearAllPoints()
			part:SetPoint("CENTER", self.icon, "CENTER", bar[3], bar[4])
			part:SetRotation(math.rad(bar[5] or 0))
			part:Show()
			table.insert(self.glyph, part)
		end
		Paint(self)
	end,
	["SetDanger"] = function(self, danger)
		self.danger = danger
		Paint(self)
	end,
	["LockHighlight"] = function(self)
		self.active = true
		Paint(self)
	end,
	["UnlockHighlight"] = function(self)
		self.active = nil
		Paint(self)
	end,
	-- Kept for the callers: an active toggle is drawn by LockHighlight.
	["SetStrongHighlight"] = function(self, enable)
	end,
	["SetSmallFont"] = function(self, small)
		self.smallFont = small
		OptionsPrivate.Private.Style.SetFont(self.text, "text", small and "xs" or "s")
		Paint(self)
	end

}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local Style = OptionsPrivate.Private.Style
	local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnShow", function(self) Fit(self.obj) end)
	frame:SetScript("OnHide", function(self)
		self.obj.over = nil
		Paint(self.obj)
	end)

	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetColorTexture(Style.Color("raised"))
	background:SetAllPoints()
	background:Hide()

	local underline = frame:CreateTexture(nil, "ARTWORK")
	underline:SetColorTexture(Style.Color("primary"))
	underline:SetHeight(2)
	underline:SetPoint("BOTTOMLEFT")
	underline:SetPoint("BOTTOMRIGHT")
	underline:Hide()

	local icon = frame:CreateTexture()
	icon:SetTexture("aaa")
	icon:SetPoint("LEFT", frame, "LEFT")
	icon:SetSize(16, 16)

	local text = frame:CreateFontString()
	Style.SetFont(text, "text", "s")
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 20, -1)
	text:SetPoint("BOTTOMRIGHT", -4, 1)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("MIDDLE")

	local pTex = frame:CreateTexture()
	pTex:SetColorTexture(Style.Color("text", 0.08))
	pTex:SetAllPoints()
	frame:SetPushedTexture(pTex)


  --- @type table<string, any>
	local widget = {
		text  = text,
		icon = icon,
		frame = frame,
		type  = Type,
		background = background,
		underline = underline,
		glyph = {},
		spareGlyph = {},
		pad = 0,
		iconOffset = 0,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

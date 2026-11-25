if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local Type, Version = "WeakAurasNewButton", 29
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Hide_Tooltip()
  GameTooltip:Hide();
end

local function Show_Tooltip(owner, line1, line2)
  GameTooltip:SetOwner(owner, "ANCHOR_NONE");
  GameTooltip:SetPoint("LEFT", owner, "RIGHT");
  GameTooltip:ClearLines();
  GameTooltip:AddLine(line1);
  GameTooltip:AddLine(line2, 1, 1, 1, 1);
  GameTooltip:Show();
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  ["OnAcquire"] = function(self)
    self:SetWidth(570);
    self:SetHeight(40);
  end,
  ["SetTitle"] = function(self, title)
    self.title:SetText(title);
  end,
  ["GetTitle"] = function(self)
    return self.title:GetText();
  end,
  ["SetDescription"] = function(self, desc)
    self.frame.description = desc;
    self.description:SetText(desc);
  end,
  ["SetClick"] = function(self, func)
    self.frame:SetScript("OnClick", func);
  end,
  ["SetIcon"] = function(self, icon)
    if(type(icon) == "string" or type(icon) == "number") then
      self.icon:SetTexture(icon);
      self.icon:Show();
      if(self.iconRegion and self.iconRegion.Hide) then
        self.iconRegion:Hide();
      end
      self.iconRegion = nil
    else
      self.iconRegion = icon;
      icon:SetAllPoints(self.icon);
      icon:SetParent(self.frame);
      icon:Show()
      self.icon:Hide();
    end
  end,
  ["SetThumbnail"] = function(self, regionType, data)
    local regionData = OptionsPrivate.Private.regionOptions[regionType]
    if regionData and regionData.acquireThumbnail then
      local thumbnail = regionData.acquireThumbnail(self.frame, data)
      self:SetIcon(thumbnail)
      self.thumbnail = thumbnail
      self.thumbnailType = regionType
    end
  end,
  ["ReleaseThumbnail"] = function(self)
    if self.thumbnail then
      local regionData = OptionsPrivate.Private.regionOptions[self.thumbnailType]
      if regionData and regionData.releaseThumbnail then
        regionData.releaseThumbnail(self.thumbnail)
      end
    end
    self.thumbnail = nil
    self.thumbnailType = nil
  end,
  ["OnRelease"] = function(self)
    self:ReleaseThumbnail()
    if(self.iconRegion and self.iconRegion.Hide) then
      self.iconRegion:Hide();
    end
    self.iconRegion = nil
    self.icon:Hide();
    self.frame:UnlockHighlight();
  end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
  local name = "WeakAurasNewButton"..AceGUI:GetNextWidgetNum(Type);
  local button = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate");
  button:SetHeight(40);
  button:SetWidth(380);
  button.dgroup = nil;

  -- Row of DESIGN.md: no fill, a light veil under the mouse (the HIGHLIGHT layer is drawn over the text), a 32 pixel icon in a 1 pixel dark frame, the title
  -- in the text color and the description quiet under it.
  -- The classic design keeps the row of the game: a faint fill, a 40 pixel icon and the fonts of the game.
  local Style = OptionsPrivate.Private.Style
  local classic = Style.classic
  local background
  if classic then
    background = button:CreateTexture(nil, "BACKGROUND");
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp");
    background:SetBlendMode("ADD");
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25);
    background:SetAllPoints(button);
  else
    background = button:CreateTexture(nil, "HIGHLIGHT");
    background:SetColorTexture(Style.Color("text", 0.06));
    background:SetAllPoints(button);
    button:SetHighlightTexture(background);
  end
  button.background = background;

  local iconFrame = button:CreateTexture(nil, "BORDER");
  if classic then
    iconFrame:SetSize(40, 40);
    iconFrame:SetPoint("LEFT", button, "LEFT");
  else
    iconFrame:SetColorTexture(Style.Color("background"));
    iconFrame:SetSize(34, 34);
    iconFrame:SetPoint("LEFT", button, "LEFT", 3, 0);
  end

  local icon = button:CreateTexture(nil, "OVERLAY");
  button.icon = icon;
  icon:SetWidth(classic and 40 or 32);
  icon:SetHeight(classic and 40 or 32);
  icon:SetPoint("CENTER", iconFrame, "CENTER");

  local title = classic and button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    or Style.NewText(button, "text", "s", "text");
  button.title = title;
  title:SetHeight(14);
  title:SetJustifyH("LEFT");
  title:SetPoint("TOP", button, "TOP", 0, -5);
  title:SetPoint("LEFT", iconFrame, "RIGHT", classic and 2 or 8, 0);
  title:SetPoint("RIGHT", button, "RIGHT");

  local description = classic and button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    or Style.NewText(button, "text", "xs", "textQuiet");
  button.description = description;
  description:SetHeight(14);
  description:SetJustifyH("LEFT");
  description:SetPoint("BOTTOM", button, "BOTTOM", 0, classic and 2 or 4);
  description:SetPoint("LEFT", iconFrame, "RIGHT", classic and 2 or 8, 0);
  description:SetPoint("RIGHT", button, "RIGHT");


  button.description = "";

  button:SetScript("OnEnter", function() Show_Tooltip(button, title:GetText(), button.description) end);
  button:SetScript("OnLeave", Hide_Tooltip);


  local widget = {
    frame = button,
    title = title,
    icon = icon,
    description = description,
    background = background,
    type = Type
  }
  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

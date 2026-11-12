if not WeakAuras.IsLibsOK() then return end
local OptionsPrivate = select(2, ...)

local Type, Version = "WeakAurasLoadedHeaderButton", 24
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local L = WeakAuras.L

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
    self:SetWidth(1000);
    self:SetHeight(22);
  end,
  ["SetText"] = function(self, text)
    -- string.upper only knows ASCII: capitals in English only, where no letter is left out.
    self.frame:SetText(" "..(GetLocale():find("^en") and text:upper() or text));
  end,
  ["SetClick"] = function(self, func)
    self.frame:SetScript("OnClick", func);
  end,
  ["Disable"] = function(self)
    self.frame:Disable();
  end,
  ["Enable"] = function(self)
    self.frame:Enable();
  end,
  ["Pick"] = function(self)
    self.frame:LockHighlight();
  end,
  ["ClearPick"] = function(self)
    self.frame:UnlockHighlight();
  end,
  ["Expand"] = function(self, reloadTooltip)
    self.expand:Enable();
    self.expanded = true;
    self.expand.texture:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\collapse")
    self.expand.title = L["Collapse"];
    self.expand.desc = self.expand.collapsedesc;
    self.expand:SetScript("OnClick", function() self:Collapse(true) end);
    self.expand.func();
    if(reloadTooltip) then
      Hide_Tooltip();
      Show_Tooltip(self.frame, self.expand.title, self.expand.desc);
    end
  end,
  ["Collapse"] = function(self, reloadTooltip)
    self.expand:Enable();
    self.expanded = false;
    self.expand.texture:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\expand")
    self.expand.title = L["Expand"];
    self.expand.desc = self.expand.expanddesc;
    self.expand:SetScript("OnClick", function() self:Expand(true) end);
    self.expand.func();
    if(reloadTooltip) then
      Hide_Tooltip();
      Show_Tooltip(self.frame, self.expand.title, self.expand.desc);
    end
  end,
  ["SetOnExpandCollapse"] = function(self, func)
    self.expand.func = func;
  end,
  ["GetExpanded"] = function(self)
    return self.expanded;
  end,
  ["DisableExpand"] = function(self)
    self.expand:Disable();
    self.expand.disabled = true;
    self.expand.expanded = false;
    self.expand.texture:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\expand")
  end,
  ["EnableExpand"] = function(self)
    self.expand.disabled = false;
    if(self:GetExpanded()) then
      self:Expand();
    else
      self:Collapse();
    end
  end,
  ["SetViewClick"] = function(self, func)
    self.view:SetScript("OnClick", func);
  end,
  ["PriorityShow"] = function(self, priority)
    if (not WeakAuras.IsOptionsOpen()) then
      return;
    end
    if(priority >= self.view.visibility and self.view.visibility ~= priority) then
      self.view.visibility = priority;
      self:UpdateViewTexture()
    end
  end,
  ["PriorityHide"] = function(self, priority)
    if (not WeakAuras.IsOptionsOpen()) then
      return;
    end
    if(priority >= self.view.visibility and self.view.visibility ~= 0) then
      self.view.visibility = 0;
      self:UpdateViewTexture()
    end
  end,
  ["UpdateViewTexture"] = function(self)
    OptionsPrivate.Private.Style.PaintIcon(self.view)
  end,
  -- Number of auras of the section, at the right of the header.
  ["SetCount"] = function(self, count)
    self.count:SetText(count)
  end,
  ["SetViewDescription"] = function(self, desc)
    self.view.desc = desc;
  end,
  ["SetExpandDescription"] = function(self, desc)
    self.expand.expanddesc = desc;
  end,
  ["SetCollapseDescription"] = function(self, desc)
    self.expand.collapsedesc = desc;
    self.expand.desc = desc;
  end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
  local name = Type..AceGUI:GetNextWidgetNum(Type)
  local button = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate");
  local Style = OptionsPrivate.Private.Style
  button:SetHeight(22);
  button:SetWidth(1000);
  -- Section header of DESIGN.md: the band, the title font in capitals, the raised fill under the mouse.
  local font = _G.WeakAurasLoadedHeaderFont
  if not font then
    font = CreateFont("WeakAurasLoadedHeaderFont")
    Style.SetFont(font, "title", "xs")
    font:SetTextColor(Style.Color("textSecondary"))
  end
  button:SetNormalFontObject(font)
  button:SetHighlightFontObject(font)
  button:SetDisabledFontObject(font)

  local background = button:CreateTexture(nil, "BACKGROUND");
  button.background = background;
  background:SetColorTexture(Style.Color("band"));
  background:SetAllPoints(button);
  local hover = button:CreateTexture(nil, "HIGHLIGHT")
  hover:SetColorTexture(Style.Color("text", 0.06))
  hover:SetAllPoints(button)
  button:SetHighlightTexture(hover)

  local expand = CreateFrame("Button", nil, button);
  button.expand = expand;
  expand.expanded = true;
  expand.disabled = true;
  expand.func = function() end;
  expand:Disable();
  expand:SetWidth(16);
  expand:SetHeight(16);
  expand:SetPoint("RIGHT", button, "RIGHT");
  expand.title = L["Disabled"];
  expand.desc = L["Expansion is disabled because this group has no children"];
  expand.expanddesc = "";
  expand.collapsedesc = "";
  expand:SetScript("OnEnter", function() Show_Tooltip(button, expand.title, expand.desc) end);
  expand:SetScript("OnLeave", Hide_Tooltip);
  Style.NewIcon(expand, "expand", 10)

  local view = CreateFrame("Button", nil, button);
  button.view = view;
  view:SetWidth(16);
  view:SetHeight(16);
  view:SetPoint("RIGHT", button, "RIGHT", -16, 0);
  view.desc = "";
  view:SetScript("OnEnter", function() Show_Tooltip(button, L["View"], view.desc) end);
  view:SetScript("OnLeave", Hide_Tooltip);
  view.visibility = 0;
  Style.NewEye(view)

  local count = Style.NewText(button, "number", "xs", "textQuiet")
  count:SetPoint("RIGHT", view, "LEFT", -4, 0)

  local widget = {
    frame = button,
    expand = expand,
    view = view,
    count = count,
    type = Type
  }
  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

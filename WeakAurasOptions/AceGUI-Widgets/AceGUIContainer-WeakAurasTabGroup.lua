-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md. Based on the TabGroup container of AceGUI-3.0.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

-- Tabs of the options of an aura, drawn after DESIGN.md: a row of text tabs on the band, the selected one on the
-- surface with a 2 pixel brass line under its text, the pane under the row filled with the surface, 8 pixel margins.
-- Own type rather than a skin of TabGroup: the AceGUI widgets are pooled with the other addons.
local Type, Version = "WeakAurasTabGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local pairs, ipairs, assert, type = pairs, ipairs, assert, type
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

local tabHeight = 26
local margin = 8

local function PaintTab(tab)
  local Style = OptionsPrivate.Private.Style
  tab.background:SetShown(tab.selected == true)
  tab.underline:SetShown(tab.selected == true)
  local color = "textSecondary"
  if tab.disabled then
    color = "textDisabled"
  elseif tab.selected or tab.over then
    color = "text"
  end
  tab.label:SetTextColor(Style.Color(color))
end

local function Tab_SetText(tab, text)
  tab.label:SetText(text)
  tab:SetWidth(tab.label:GetStringWidth() + 24)
end

local function Tab_SetSelected(tab, selected)
  tab.selected = selected
  PaintTab(tab)
end

local function Tab_SetDisabled(tab, disabled)
  tab.disabled = disabled
  tab:SetEnabled(not disabled)
  PaintTab(tab)
end

local function Tab_OnClick(tab)
  if not (tab.selected or tab.disabled) then
    PlaySound(841) -- SOUNDKIT.IG_CHARACTER_INFO_TAB
    tab.obj:SelectTab(tab.value)
  end
end

local function Tab_OnEnter(tab)
  tab.over = true
  PaintTab(tab)
  tab.obj:Fire("OnTabEnter", tab.obj.tabs[tab.id].value, tab)
end

local function Tab_OnLeave(tab)
  tab.over = nil
  PaintTab(tab)
  tab.obj:Fire("OnTabLeave", tab.obj.tabs[tab.id].value, tab)
end

local function BuildTabsOnUpdate(frame)
  frame.obj:BuildTabs()
  frame:SetScript("OnUpdate", nil)
end

local methods = {
  ["OnAcquire"] = function(self)
    self:SetTitle()
  end,

  ["OnRelease"] = function(self)
    self.status = nil
    for k in pairs(self.localstatus) do
      self.localstatus[k] = nil
    end
    self.tablist = nil
    for _, tab in pairs(self.tabs) do
      tab:Hide()
    end
  end,

  ["CreateTab"] = function(self, id)
    local Style = OptionsPrivate.Private.Style
    local tab = CreateFrame("Button", nil, self.frame)
    tab:SetHeight(tabHeight)
    tab.background = tab:CreateTexture(nil, "BACKGROUND")
    tab.background:SetColorTexture(Style.Color("surface"))
    tab.background:SetAllPoints()
    tab.label = Style.NewText(tab, "text", "s", "textSecondary")
    tab.label:SetPoint("CENTER")
    tab.underline = tab:CreateTexture(nil, "ARTWORK")
    tab.underline:SetColorTexture(Style.Color("primary"))
    tab.underline:SetHeight(2)
    tab.underline:SetPoint("BOTTOMLEFT", tab.label, "BOTTOMLEFT", 0, -5)
    tab.underline:SetPoint("BOTTOMRIGHT", tab.label, "BOTTOMRIGHT", 0, -5)
    tab.obj = self
    tab.id = id
    tab:SetScript("OnClick", Tab_OnClick)
    tab:SetScript("OnEnter", Tab_OnEnter)
    tab:SetScript("OnLeave", Tab_OnLeave)
    -- An addon font may not be loaded when the tab is made: measured again once shown.
    tab:SetScript("OnShow", function(frame) Tab_SetText(frame, frame.label:GetText()) end)
    tab.SetText = Tab_SetText
    tab.SetSelected = Tab_SetSelected
    tab.SetDisabled = Tab_SetDisabled
    return tab
  end,

  ["SetTitle"] = function(self, text)
    self.titletext:SetText(text or "")
    if text and text ~= "" then
      self.alignoffset = 25
    else
      self.alignoffset = 18
    end
    self:BuildTabs()
  end,

  ["SetStatusTable"] = function(self, status)
    assert(type(status) == "table")
    self.status = status
  end,

  ["SelectTab"] = function(self, value)
    local status = self.status or self.localstatus
    local found
    for _, tab in ipairs(self.tabs) do
      if tab.value == value then
        tab:SetSelected(true)
        found = true
      else
        tab:SetSelected(false)
      end
    end
    status.selected = value
    if found then
      self:Fire("OnGroupSelected", value)
    end
  end,

  ["SetTabs"] = function(self, tabs)
    self.tablist = tabs
    self:BuildTabs()
  end,

  -- Tabs side by side from the left, a new row when the next one does not fit.
  ["BuildTabs"] = function(self)
    local tablist = self.tablist
    if not tablist then return end
    local top = (self.titletext:GetText() or "") ~= "" and 18 or 0
    local width = self.frame.width or self.frame:GetWidth() or 0
    local tabs = self.tabs
    local row, used = 0, 0
    for i, entry in ipairs(tablist) do
      local tab = tabs[i]
      if not tab then
        tab = self:CreateTab(i)
        tabs[i] = tab
      end
      tab:Show()
      tab:SetText(entry.text)
      tab:SetDisabled(entry.disabled)
      tab.value = entry.value
      tab:ClearAllPoints()
      if used > 0 and used + tab:GetWidth() > width then
        row, used = row + 1, 0
      end
      tab:SetPoint("TOPLEFT", self.frame, "TOPLEFT", used, -top - row * tabHeight)
      used = used + tab:GetWidth()
    end
    for i = #tablist + 1, #tabs do
      tabs[i]:Hide()
    end
    self.borderoffset = top + (row + 1) * tabHeight
    self.band:SetPoint("TOPLEFT", 0, -top)
    self.band:SetHeight((row + 1) * tabHeight)
    self.border:SetPoint("TOPLEFT", 0, -self.borderoffset)
  end,

  ["OnWidthSet"] = function(self, width)
    local contentwidth = math.max(0, width - 2 * margin)
    self.content:SetWidth(contentwidth)
    self.content.width = contentwidth
    self:BuildTabs()
    self.frame:SetScript("OnUpdate", BuildTabsOnUpdate)
  end,

  ["OnHeightSet"] = function(self, height)
    local contentheight = math.max(0, height - (self.borderoffset + 2 * margin))
    self.content:SetHeight(contentheight)
    self.content.height = contentheight
  end,

  ["LayoutFinished"] = function(self, width, height)
    if self.noAutoHeight then return end
    self:SetHeight((height or 0) + self.borderoffset + 2 * margin)
  end
}

local function Constructor()
  local Style = OptionsPrivate.Private.Style
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(100)
  frame:SetWidth(100)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")

  local titletext = Style.NewText(frame, "text", "s", "textSecondary")
  titletext:SetPoint("TOPLEFT", margin, 0)
  titletext:SetPoint("TOPRIGHT", -margin, 0)
  titletext:SetJustifyH("LEFT")
  titletext:SetHeight(18)
  titletext:SetText("")

  local band = frame:CreateTexture(nil, "BACKGROUND")
  band:SetColorTexture(Style.Color("band"))
  band:SetPoint("TOPLEFT")
  band:SetPoint("RIGHT")
  band:SetHeight(tabHeight)

  local border = CreateFrame("Frame", nil, frame)
  border:SetPoint("TOPLEFT", 0, -tabHeight)
  border:SetPoint("BOTTOMRIGHT")
  local fill = border:CreateTexture(nil, "BACKGROUND")
  fill:SetColorTexture(Style.Color("surface"))
  fill:SetAllPoints()

  local content = CreateFrame("Frame", nil, border)
  content:SetPoint("TOPLEFT", margin, -margin)
  content:SetPoint("BOTTOMRIGHT", -margin, margin)

  local widget = {
    frame        = frame,
    localstatus  = {},
    alignoffset  = 18,
    titletext    = titletext,
    band         = band,
    border       = border,
    borderoffset = tabHeight,
    tabs         = {},
    content      = content,
    type         = Type
  }
  for method, func in pairs(methods) do
    widget[method] = func
  end
  return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

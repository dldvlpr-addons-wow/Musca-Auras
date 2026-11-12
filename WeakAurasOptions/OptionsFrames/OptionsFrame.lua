if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

-- Lua APIs
local tinsert, tremove, wipe = table.insert, table.remove, wipe
local pairs, type = pairs, type
local _G = _G

-- WoW APIs
local GetScreenWidth, GetScreenHeight, CreateFrame
  = GetScreenWidth, GetScreenHeight, CreateFrame

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

---@class WeakAuras
local WeakAuras = WeakAuras
local L = WeakAuras.L

local displayButtons = OptionsPrivate.displayButtons
local tempGroup = OptionsPrivate.tempGroup
local aceOptions = {}

-- Grip of the bottom right corner: three diagonals of 1 pixel, brass under the mouse.
local function CreateFrameSizer(frame, callback)
  local Style = OptionsPrivate.Private.Style
  local handle = CreateFrame("Button", nil, frame)
  handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  handle:SetSize(16, 16)
  handle:SetFrameLevel(frame:GetFrameLevel() + 20)
  local lines = {}
  for _, length in ipairs({ 12, 8, 4 }) do
    local line = handle:CreateTexture(nil, "OVERLAY")
    line:SetTexture(Style.white)
    line:SetSize(length * math.sqrt(2), 1)
    line:SetPoint("CENTER", handle, "BOTTOMRIGHT", -2 - length / 2, 2 + length / 2)
    line:SetRotation(math.rad(45))
    tinsert(lines, line)
  end
  local function Paint(color)
    for _, line in ipairs(lines) do
      line:SetVertexColor(Style.Color(color))
    end
  end
  Paint("borderField")
  handle:SetScript("OnEnter", function() Paint("primary") end)
  handle:SetScript("OnLeave", function() Paint("borderField") end)
  handle:SetScript("OnMouseDown", function()
    frame:StartSizing("BOTTOMRIGHT")
  end)
  handle:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    callback()
  end)
  return handle
end

local defaultWidth = 830
local defaultHeight = 665
local minWidth = 750
local minHeight = 240



function OptionsPrivate.CreateFrame()
  LibDD:Create_UIDropDownMenu("WeakAuras_DropDownMenu", nil)
  local frame
  local db = OptionsPrivate.savedVars.db
  local odb = OptionsPrivate.savedVars.odb

  local Style = OptionsPrivate.Private.Style
  frame = CreateFrame("Frame", "WeakAurasOptions", UIParent, "BackdropTemplate")
  Style.Fill(frame, "background")

  -- Drop shadow, 4 pixels down and right, under the window.
  local shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, 12)
  shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 20, -20)
  shadow:SetBackdrop({ edgeFile = [[Interface\AddOns\WeakAuras\Media\Textures\Border_DropShadow]], edgeSize = 16 })
  shadow:SetBackdropBorderColor(Style.Color("shadow"))

  -- Title bar: band, sheen on top, brass rule below; the whole bar drags the window.
  local titleBar = CreateFrame("Frame", nil, frame)
  titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  titleBar:SetHeight(28)
  titleBar:EnableMouse(true)
  local titleBand = titleBar:CreateTexture(nil, "BACKGROUND")
  titleBand:SetAllPoints()
  titleBand:SetColorTexture(Style.Color("band"))
  local titleSheen = titleBar:CreateTexture(nil, "BORDER")
  titleSheen:SetColorTexture(Style.Color("sheen"))
  titleSheen:SetHeight(1)
  titleSheen:SetPoint("TOPLEFT")
  titleSheen:SetPoint("TOPRIGHT")
  -- The rule fades in from the left edge to the middle and out to the right edge.
  local ruleLeft = titleBar:CreateTexture(nil, "BORDER")
  ruleLeft:SetTexture(Style.white)
  ruleLeft:SetHeight(1)
  ruleLeft:SetPoint("BOTTOMLEFT")
  ruleLeft:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOM")
  ruleLeft:SetGradient("HORIZONTAL", CreateColor(Style.Color("rule", 0)), CreateColor(Style.Color("rule")))
  local ruleRight = titleBar:CreateTexture(nil, "BORDER")
  ruleRight:SetTexture(Style.white)
  ruleRight:SetHeight(1)
  ruleRight:SetPoint("BOTTOMLEFT", titleBar, "BOTTOM")
  ruleRight:SetPoint("BOTTOMRIGHT")
  ruleRight:SetGradient("HORIZONTAL", CreateColor(Style.Color("rule")), CreateColor(Style.Color("rule", 0)))
  local logo = titleBar:CreateTexture(nil, "ARTWORK")
  logo:SetTexture([[Interface\AddOns\WeakAuras\Media\Textures\logo_musca_round.tga]])
  logo:SetSize(18, 18)
  logo:SetPoint("LEFT", titleBar, "LEFT", 8, 0)
  -- Name, version and the name of the mounted window, hidden while the window is reduced.
  local titleLabels = CreateFrame("Frame", nil, titleBar)
  titleLabels:SetAllPoints()
  local titleText = Style.NewText(titleLabels, "title", "m")
  titleText:SetPoint("LEFT", logo, "RIGHT", 6, 0)
  titleText:SetText("Musca Auras")
  local versionText = Style.NewText(titleLabels, "number", "xs", "textQuiet")
  versionText:SetPoint("LEFT", titleText, "RIGHT", 6, 0)
  versionText:SetText(OptionsPrivate.changelog.versionString)
  local subtitleText = Style.NewText(titleLabels, "text", "s", "textSecondary")
  subtitleText:SetPoint("LEFT", versionText, "RIGHT", 8, 0)
  frame.TitleContainer = titleBar
  frame.titleLabels = titleLabels

  function OptionsPrivate.SetTitle(title)
    subtitleText:SetText(title or "")
  end

  tinsert(UISpecialFrames, frame:GetName())
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:SetResizeBounds(minWidth, minHeight)
  frame:SetFrameStrata("DIALOG")
  shadow:SetFrameLevel(math.max(frame:GetFrameLevel() - 1, 0))

  -- Opening: from 8 pixels lower and transparent, brief; closing is instant.
  local entrance = frame:CreateAnimationGroup()
  local drop = entrance:CreateAnimation("Translation")
  drop:SetOffset(0, -8)
  drop:SetDuration(0)
  drop:SetOrder(1)
  Style.AddFade(entrance, 0, 0, 0):SetOrder(1)
  local rise = entrance:CreateAnimation("Translation")
  rise:SetOffset(0, 8)
  rise:SetDuration(Style.durations.brief)
  rise:SetSmoothing("OUT")
  rise:SetOrder(2)
  Style.AddFade(entrance, 0, 1, Style.durations.brief, 0, "OUT"):SetOrder(2)
  frame:HookScript("OnShow", function()
    entrance:Play()
  end)

  frame.window = "default"

  local xOffset, yOffset

  if db.frame then
    -- Convert from old settings to new
    odb.frame = db.frame
    if odb.frame.xOffset and odb.frame.yOffset then
      odb.frame.xOffset = odb.frame.xOffset + GetScreenWidth() - (odb.frame.width or defaultWidth) / 2
      odb.frame.yOffset = odb.frame.yOffset + GetScreenHeight()
    end
    db.frame = nil
  end

  if odb.frame then
    xOffset, yOffset = odb.frame.xOffset, odb.frame.yOffset
  end

  if not (xOffset and yOffset) then
    xOffset = GetScreenWidth() / 2
    yOffset = GetScreenHeight() - defaultHeight / 2
  end

  frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", xOffset, yOffset)
  frame:Hide()

  frame:SetScript("OnHide", function()
    OptionsPrivate.Private.TimeMachine:ForgetWatched()
    local suspended = OptionsPrivate.Private.PauseAllDynamicGroups()

    OptionsPrivate.Private.ClearFakeStates()

    for id, data in pairs(OptionsPrivate.Private.regions) do
      if data.region then
        data.region:Collapse()
        data.region:OptionsClosed()
        if OptionsPrivate.Private.clones[id] then
          for _, cloneRegion in pairs(OptionsPrivate.Private.clones[id]) do
            cloneRegion:Collapse()
            cloneRegion:OptionsClosed()
          end
        end
      end
    end

    OptionsPrivate.Private.ResumeAllDynamicGroups(suspended)
    OptionsPrivate.Private.Resume()

    if OptionsPrivate.Private.mouseFrame then
      OptionsPrivate.Private.mouseFrame:OptionsClosed()
    end

    if OptionsPrivate.Private.personalRessourceDisplayFrame then
      OptionsPrivate.Private.personalRessourceDisplayFrame:OptionsClosed()
    end

    if frame.dynamicTextCodesFrame then
      frame.dynamicTextCodesFrame:Hide()
    end

    if frame.moversizer then
      frame.moversizer:OptionsClosed()
    end
  end)

  local width, height

  if odb.frame then
    width, height = odb.frame.width, odb.frame.height
  end

  if not (width and height) then
    width, height = defaultWidth, defaultHeight
  end

  width = max(width, minWidth)
  height = max(height, minHeight)
  frame:SetWidth(width)
  frame:SetHeight(height)


  OptionsPrivate.SetTitle()

  local function commitWindowChanges()
    if not frame.minimized then
      local xOffset = frame:GetRight()-(frame:GetWidth()/2)
      local yOffset = frame:GetTop()
      odb.frame = odb.frame or {}
      odb.frame.xOffset = xOffset
      odb.frame.yOffset = yOffset
      odb.frame.width = frame:GetWidth()
      odb.frame.height = frame:GetHeight()
    end
  end

  frame.TitleContainer:SetScript("OnMouseDown", function()
    frame:StartMoving()
  end)
  frame.TitleContainer:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    commitWindowChanges()
  end)


  frame.bottomRightResizer = CreateFrameSizer(frame, commitWindowChanges)

  frame.UpdateFrameVisible = function(self)
    self.tipPopup:Hide()
    self.guideButton:SetShown(not self.minimized)
    if self.minimized then
      self.titleLabels:Hide()
      self.buttonsContainer.frame:Hide()
      for _, fn in ipairs({"TexturePicker", "IconPicker", "ModelPicker", "ImportExport", "TextEditor", "CodeReview", "UpdateFrame", "DebugLog"}) do
        local obj = OptionsPrivate[fn](self, true)
        if obj then
          obj.frame:Hide()
        end
      end
      if self.newView then
        self.newView.frame:Hide()
      end
      self.container.frame:Hide()

      self.loadProgress:Hide()
      self.toolbarContainer:Hide()
      self.filterInput:Hide();
      self.tipFrame:Hide()
      self:HideTip()
      self.bottomRightResizer:Hide()
      self.dynamicTextCodesFrame:Hide()
    else
      self.titleLabels:Show()
      self.bottomRightResizer:Show()
      if self.window == "default" then
        OptionsPrivate.SetTitle()
        self.buttonsContainer.frame:Show()
        self.container.frame:Show()
        self:ShowTip()
      else
        self.buttonsContainer.frame:Hide()
        self.container.frame:Hide()
        self.dynamicTextCodesFrame:Hide()
        self:HideTip()
      end
      local widgets = {
        { window = "texture",      title = L["Texture Picker"],       fn = "TexturePicker" },
        { window = "icon",         title = L["Icon Picker"],          fn = "IconPicker" },
        { window = "model",        title = L["Model Picker"],         fn = "ModelPicker" },
        { window = "importexport", title = L["Import / Export"],      fn = "ImportExport" },
        { window = "texteditor",   title = L["Code Editor"],          fn = "TextEditor" },
        { window = "codereview",   title = L["Custom Code Viewer"],   fn = "CodeReview" },
        { window = "debuglog",     title = L["Debug Log"],            fn = "DebugLog" },
        { window = "update",       title = L["Update"],               fn = "UpdateFrame" },
      }

      for _, widget in ipairs(widgets) do
        local obj = OptionsPrivate[widget.fn](self, true)
        if self.window == widget.window then
          OptionsPrivate.SetTitle(widget.title)
          if obj then
            obj.frame:Show()
          end
        else
          if obj then
            obj.frame:Hide()
          end
        end
      end

      if self.window == "newView" then
        OptionsPrivate.SetTitle(L["New Template"])
        self.newView.frame:Show()
      else
        if self.newView then
          self.newView.frame:Hide()
        end
      end
      if self.window == "default" then
        if self.loadProgessVisible then
          self.loadProgress:Show()
          self.toolbarContainer:Hide()
          self.filterInput:Hide();
        else
          self.loadProgress:Hide()
          self.toolbarContainer:Show()
          self.filterInput:Show();
          --self.filterInputClear:Show();
        end
      else
        self.loadProgress:Hide()
        self.toolbarContainer:Hide()
        self.filterInput:Hide();
      end
    end
  end



  -- Buttons of the title bar, 28 pixels: raised under the mouse, their drawing painted by Paint(over).
  local function TitleButton(onClick)
    local button = CreateFrame("Button", nil, frame.TitleContainer)
    button:SetSize(28, 28)
    button.hover = button:CreateTexture(nil, "BACKGROUND")
    button.hover:SetAllPoints()
    button.hover:SetColorTexture(Style.Color("raised"))
    button.hover:Hide()
    button:SetScript("OnEnter", function(self)
      self.hover:Show()
      self:Paint(true)
    end)
    button:SetScript("OnLeave", function(self)
      self.hover:Hide()
      self:Paint(false)
    end)
    button:SetScript("OnClick", onClick)
    return button
  end

  -- Close: a cross of two bars turned by 45 degrees.
  local closeButton = TitleButton(function()
    frame:Hide()
  end)
  closeButton:SetPoint("TOPRIGHT")
  local crossBars = {}
  for _, angle in ipairs({ 45, -45 }) do
    local bar = closeButton:CreateTexture(nil, "ARTWORK")
    bar:SetTexture(Style.white)
    bar:SetSize(1.5, 12)
    bar:SetPoint("CENTER")
    bar:SetRotation(math.rad(angle))
    tinsert(crossBars, bar)
  end
  function closeButton:Paint(over)
    for _, bar in ipairs(crossBars) do
      bar:SetVertexColor(Style.Color(over and "error" or "textSecondary"))
    end
  end
  closeButton:Paint(false)
  frame.CloseButton = closeButton

  -- Reduce and restore: one square while reduced, two offset squares while the window is full size.
  local minimizebutton = TitleButton()
  minimizebutton:SetPoint("RIGHT", closeButton, "LEFT")
  local function Square(size, x, y)
    local square = CreateFrame("Frame", nil, minimizebutton, "BackdropTemplate")
    square:SetSize(size, size)
    square:SetPoint("CENTER", x, y)
    square:SetBackdrop({ bgFile = Style.white, edgeFile = Style.white, edgeSize = 1 })
    return square
  end
  local backSquare = Square(8, 2, 2)
  local frontSquare = Square(8, -1, -1)
  frontSquare:SetFrameLevel(backSquare:GetFrameLevel() + 1)
  function minimizebutton:Paint(over)
    local line = over and "text" or "textSecondary"
    local fill = over and "raised" or "band"
    frontSquare:SetSize(frame.minimized and 10 or 8, frame.minimized and 10 or 8)
    frontSquare:SetPoint("CENTER", frame.minimized and 0 or -1, frame.minimized and 0 or -1)
    backSquare:SetShown(not frame.minimized)
    for _, square in ipairs({ backSquare, frontSquare }) do
      square:SetBackdropColor(Style.Color(fill))
      square:SetBackdropBorderColor(Style.Color(line))
    end
  end
  minimizebutton:Paint(false)

  local function Maximize()
    frame.minimized = false
    local right, top = frame:GetRight(), frame:GetTop()
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", right, top)
    frame:SetHeight(odb.frame and odb.frame.height or defaultHeight)
    frame:SetWidth(odb.frame and odb.frame.width or defaultWidth)
    frame.buttonsScroll:DoLayout()
    frame:UpdateFrameVisible()
  end
  local function Minimize()
    commitWindowChanges()
    frame.minimized = true
    local right, top = frame:GetRight(), frame:GetTop()
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", right, top)
    frame:SetHeight(75)
    frame:SetWidth(160)
    frame:UpdateFrameVisible()
  end
  minimizebutton:SetScript("OnClick", function(self)
    if frame.minimized then
      Maximize()
    else
      Minimize()
    end
    self:Paint(self:IsMouseOver())
  end)

  local guideButton = Style.NewButton(frame.TitleContainer, L["Guide:"] .. " " .. L["learn WeakAuras"], "secondary",
    function()
      OptionsPrivate.Private.ShowForeverTutorial()
    end)
  guideButton:SetPoint("RIGHT", minimizebutton, "LEFT", -4, 0)
  guideButton:HookScript("OnShow", Style.FitButton)
  guideButton:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(L["Musca Auras Guide"])
    GameTooltip:AddLine(L["Learn everything about WeakAuras on WoW Forever: how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import."], 1, 1, 1, true)
    GameTooltip:Show()
  end)
  guideButton:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  frame.guideButton = guideButton

  local tipFrame = CreateFrame("Frame", nil, frame)
  tipFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 17, 19)
  tipFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -17, 3)
  tipFrame:Hide()
  frame.tipFrame = tipFrame
  -- Footer: band with a border on top, shown with the links.
  local footerBand = tipFrame:CreateTexture(nil, "BACKGROUND")
  footerBand:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  footerBand:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -1, 22)
  footerBand:SetColorTexture(Style.Color("band"))
  local footerLine = tipFrame:CreateTexture(nil, "BORDER")
  footerLine:SetHeight(1)
  footerLine:SetPoint("BOTTOMLEFT", footerBand, "TOPLEFT")
  footerLine:SetPoint("BOTTOMRIGHT", footerBand, "TOPRIGHT")
  footerLine:SetColorTexture(Style.Color("border"))

  local tipPopup = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  tipPopup:SetFrameStrata("FULLSCREEN")
  Style.Fill(tipPopup, "raised", "borderHover")
  local tipPopupMark = tipPopup:CreateTexture(nil, "ARTWORK")
  tipPopupMark:SetHeight(2)
  tipPopupMark:SetPoint("TOPLEFT", 1, -1)
  tipPopupMark:SetPoint("TOPRIGHT", -1, -1)
  tipPopupMark:SetColorTexture(Style.Color("primary"))
  tipPopup:Hide()
  frame.tipPopup = tipPopup

  local tipPopupTitle = Style.NewText(tipPopup, "title", "m", "text", "BACKGROUND")
  tipPopupTitle:SetPoint("TOPLEFT", tipPopup, "TOPLEFT", 10, -10)
  tipPopupTitle:SetPoint("TOPRIGHT", tipPopup, "TOPRIGHT", -10, -10)
  tipPopupTitle:SetJustifyH("LEFT")
  tipPopupTitle:SetJustifyV("TOP")

  local tipPopupLabel = Style.NewText(tipPopup, "text", "s", "text", "BACKGROUND")
  tipPopupLabel:SetPoint("TOPLEFT", tipPopupTitle, "BOTTOMLEFT", 0, -6)
  tipPopupLabel:SetPoint("TOPRIGHT", tipPopupTitle, "BOTTOMRIGHT", 0, -6)
  tipPopupLabel:SetJustifyH("LEFT")
  tipPopupLabel:SetJustifyV("TOP")

  local tipPopupLabelCJ = tipPopup:CreateFontString(nil, "BACKGROUND", "GameFontWhite")
  tipPopupLabelCJ:SetFont("Fonts\\ARKai_T.ttf", 12, "")
  tipPopupLabelCJ:SetTextColor(Style.Color("text"))
  tipPopupLabelCJ:SetPoint("TOPLEFT", tipPopupLabel, "BOTTOMLEFT", 0, 0)
  tipPopupLabelCJ:SetPoint("TOPRIGHT", tipPopupLabel, "BOTTOMRIGHT", 0, 0)
  tipPopupLabelCJ:SetJustifyH("LEFT")
  tipPopupLabelCJ:SetJustifyV("TOP")

  local tipPopupLabelK = tipPopup:CreateFontString(nil, "BACKGROUND", "GameFontWhite")
  tipPopupLabelK:SetFont("Fonts\\K_Pagetext.TTF", 12, "")
  tipPopupLabelK:SetTextColor(Style.Color("text"))
  tipPopupLabelK:SetPoint("TOPLEFT", tipPopupLabelCJ, "BOTTOMLEFT", 0, 0)
  tipPopupLabelK:SetPoint("TOPRIGHT", tipPopupLabelCJ, "BOTTOMRIGHT", 0, 0)
  tipPopupLabelK:SetJustifyH("LEFT")
  tipPopupLabelK:SetJustifyV("TOP")

  local urlWidget = CreateFrame("EditBox", nil, tipPopup, "BackdropTemplate")
  urlWidget:SetAutoFocus(false)
  Style.SkinEditBox(urlWidget, "text")
  urlWidget:HookScript("OnEditFocusGained", urlWidget.HighlightText)
  urlWidget:SetPoint("TOPLEFT", tipPopupLabelK, "BOTTOMLEFT", 0, -6)
  urlWidget:SetPoint("TOPRIGHT", tipPopupLabelK, "BOTTOMRIGHT", 0, -6)
  urlWidget:SetScript("OnChar", function() urlWidget:SetText(urlWidget.text); urlWidget:HighlightText(); end);
  urlWidget:SetScript("OnMouseUp", function() urlWidget:HighlightText(); end);
  urlWidget:SetScript("OnEscapePressed", function() tipPopup:Hide() end)
  urlWidget:SetHeight(22)

  local tipPopupCtrlC = Style.NewText(tipPopup, "text", "xs", "textQuiet", "BACKGROUND")
  tipPopupCtrlC:SetPoint("TOPLEFT", urlWidget, "BOTTOMLEFT", 0, -6)
  tipPopupCtrlC:SetPoint("TOPRIGHT", urlWidget, "BOTTOMRIGHT", 0, -6)
  tipPopupCtrlC:SetJustifyH("LEFT")
  tipPopupCtrlC:SetJustifyV("TOP")
  tipPopupCtrlC:SetText(L["Press Ctrl+C to copy the URL"])

  --- @type fun(referenceWidget: frame, title: string, texture: string, url: string, description: string, descriptionCJ: string?, descriptionK: string?, rightAligned: boolean?, width: number?)
  local function ToggleTip(referenceWidget, url, title, description, descriptionCJ, descriptionK, rightAligned, width)
    width = width or 400
    if tipPopup:IsVisible() and urlWidget.text == url then
      tipPopup:Hide()
      return
    end
    urlWidget.text = url
    urlWidget:SetText(url)
    tipPopupTitle:SetText(title)
    tipPopupLabel:SetText(description)
    tipPopupLabelCJ:SetText(descriptionCJ)
    tipPopupLabelK:SetText(descriptionK)
    urlWidget:HighlightText()

    tipPopup:ClearAllPoints();
    if rightAligned then
      tipPopup:SetPoint("BOTTOMRIGHT", referenceWidget, "TOPRIGHT", 6, 4)
    else
      tipPopup:SetPoint("BOTTOMLEFT", referenceWidget, "TOPLEFT", -6, 4)
    end

    tipPopup:SetWidth(width)
    tipPopup:Show()
    tipPopup:SetHeight(38 + tipPopupTitle:GetHeight() + tipPopupLabel:GetHeight() + tipPopupLabelCJ:GetHeight() + tipPopupLabelK:GetHeight()
                       + urlWidget:GetHeight() + tipPopupCtrlC:GetHeight())
    -- This does somehow fix an issue where the first popup after a game restart doesn't show up.
    -- This isn't reproducable after a simple ui reload, so no idea what goes wrong, but with this line here,
    -- it seems to work.
    tipPopupLabel:GetRect()
    tipPopupLabelCJ:GetRect()
    tipPopupLabelK:GetRect()
  end

  OptionsPrivate.ToggleTip = ToggleTip

  --- @type fun(title: string, texture: string, url: string, description: string, descriptionCJ: string?, descriptionK: string?, rightAligned: boolean?, width: number?)
  local addFooter = function(title, texture, url, description, descriptionCJ, descriptionK, rightAligned, width)
    local button = AceGUI:Create("WeakAurasToolbarButton")
    button:SetSmallFont(true)
    button.icon:SetSize(14, 14)
    button:SetText(title)
    button:SetTexture(texture)
    button:SetCallback("OnClick", function()
      ToggleTip(button.frame, url, title, description, descriptionCJ, descriptionK, rightAligned, width)
    end)
    button.frame:Show()
    return button.frame
  end

  local function lineWrapDiscordList(list)
    local patreonLines = {}
    local lineLength = 0
    local currentLine = {}
    for _, patreon in ipairs(list) do
      if lineLength + #patreon + 2 > 130 then
        tinsert(patreonLines, table.concat(currentLine, ", ") .. ", ")
        currentLine = {}
        tinsert(currentLine, patreon)
        lineLength = #patreon + 2
      else
        lineLength = lineLength + #patreon + 2
        tinsert(currentLine, patreon)
      end
    end
    if #currentLine > 0 then
      tinsert(patreonLines, table.concat(currentLine, ", "))
    end
    return table.concat(patreonLines, "\n")
  end

  local thanksList = L["Musca Auras: WoW Forever 1.60 port by dldvlpr, based on WeakAuras by The WeakAuras Team."] .. "\n\n"
                     .. L["We thank"] .. "\n"
                     .. L["All maintainers of the libraries we use, especially:"] .. "\n"
                     .. "• " .. L["Ace: Funkeh, Nevcairiel"] .. "\n"
                     .. "• " .. L["LibCompress: Galmok"]  .. "\n"
                     .. "• " .. L["LibCustomGlow: Dooez"] .. "\n"
                     .. "• " .. L["LibDeflate: Yoursafety"] .. "\n"
                     .. "• " .. L["LibSerialize: Sanjo"] .. "\n"
                     .. "• " .. L["Our translators (too many to name)"] .. "\n"
                     .. "• " .. L["And our Patreons, Discord Regulars and Subscribers, and Friends of the Addon:"] .. "\n"

  thanksList = thanksList .. lineWrapDiscordList(OptionsPrivate.Private.DiscordList)

  local footerSpacing = 4
  local thanksListCJ = lineWrapDiscordList(OptionsPrivate.Private.DiscordListCJ)
  local thanksListK = lineWrapDiscordList(OptionsPrivate.Private.DiscordListK)

  local discordButton = addFooter(L["Discord"], [[Interface\AddOns\WeakAuras\Media\Textures\discord.tga]], "https://discord.gg/EyYpyMq2km",
            L["Join the Musca Auras Discord server."])
  discordButton:SetParent(tipFrame)
  discordButton:SetPoint("LEFT", tipFrame, "LEFT")

  local documentationButton = addFooter(L["Documentation"], [[Interface\AddOns\WeakAuras\Media\Textures\GitHub.tga]], "https://github.com/dldvlpr-addons-wow/Musca-Auras",
            L["Check out our wiki for a large collection of examples and snippets."])
  documentationButton:SetParent(tipFrame)
  documentationButton:SetPoint("LEFT", discordButton, "RIGHT", footerSpacing, 0)

  local thanksButton = addFooter(L["Thanks"], [[Interface\AddOns\WeakAuras\Media\Textures\waheart.tga]],
                                 "https://www.patreon.com/WeakAuras", thanksList, thanksListCJ, thanksListK, nil, 800)
  thanksButton:SetParent(tipFrame)
  thanksButton:SetPoint("LEFT", documentationButton, "RIGHT", footerSpacing, 0)

  if OptionsPrivate.changelog then
    local changelog
    if OptionsPrivate.changelog.highlightText then
      changelog = L["Highlights"] .. "\n" .. OptionsPrivate.changelog.highlightText
    else
      changelog = OptionsPrivate.changelog.commitText
    end

    local changelogButton = addFooter(L["Changelog"], "", OptionsPrivate.changelog.fullChangeLogUrl,
                                      changelog, nil, nil, false, 800)
    changelogButton:SetParent(tipFrame)
    changelogButton:SetPoint("LEFT", thanksButton, "RIGHT", footerSpacing, 0)
  end

  local reportbugButton = addFooter(L["Found a Bug?"], [[Interface\AddOns\WeakAuras\Media\Textures\bug_report.tga]], "https://github.com/dldvlpr-addons-wow/Musca-Auras/issues/new",
            L["Report bugs on our issue tracker."], nil, nil, true)
  reportbugButton:SetParent(tipFrame)
  reportbugButton:SetPoint("RIGHT", tipFrame, "RIGHT")

  local wagoButton = addFooter(L["Find Auras"], [[Interface\AddOns\WeakAuras\Media\Textures\wago.tga]], "https://wago.io",
            L["Browse Wago, the largest collection of auras."], nil, nil, true)
  wagoButton:SetParent(tipFrame)
  wagoButton:SetPoint("RIGHT", reportbugButton, "LEFT", -footerSpacing, 0)

  local companionButton
  if not OptionsPrivate.Private.CompanionData.slugs then
    companionButton = addFooter(L["Update Auras"], [[Interface\AddOns\WeakAuras\Media\Textures\wagoupdate_refresh.tga]], "https://weakauras.wtf",
            L["Keep your Wago imports up to date with the Companion App."])
    companionButton:SetParent(tipFrame)
    companionButton:SetPoint("RIGHT", wagoButton, "LEFT", -footerSpacing, 0)
  end

  frame.ShowTip = function(self)
    self.tipFrame:Show()
    self.buttonsContainer.frame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 17, 24)
    self.container.frame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -17, 22)
  end

  frame.HideTip = function(self)
    self.tipFrame:Hide()
    self.buttonsContainer.frame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 17, 12)
    self.container.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -17, 10)
  end

  -- Section title of the New Aura panel, as the section headers of DESIGN.md: the title font, in capitals in English.
  local function PaintSectionTitle(label, text)
    -- Through the font object of the Label, which OnAcquire drops: the pool of Label is shared with other addons.
    label:SetFont(STANDARD_TEXT_FONT, 10, "")
    Style.SetFont(label.fontObject, "title", "xs")
    label:SetColor(Style.Color("textSecondary"))
    label:SetText(GetLocale():find("^en") and text:upper() or text)
    label:SetFullWidth(true)
  end

  -- The thin scroll bar of DESIGN.md on a ScrollFrame of AceGUI; its pool is shared with other addons, so the bar
  -- gets the look of the game back when the widget is released.
  local function SkinScrollFrame(scroll)
    Style.SkinScrollBar(scroll.scrollbar)
    scroll:SetCallback("OnRelease", function(widget) Style.UnskinScrollBar(widget.scrollbar) end)
  end

  -- An InlineGroup of AceGUI drawn as a block of DESIGN.md; its own look is given back when the pool takes it again.
  local function PaintInlineGroup(group, fill)
    local box = group.content:GetParent()
    local backdrop = box:GetBackdrop()
    local color, borderColor = { box:GetBackdropColor() }, { box:GetBackdropBorderColor() }
    Style.Fill(box, fill)
    local release = group.OnRelease
    group.OnRelease = function(self)
      box:SetBackdrop(backdrop)
      if backdrop then
        box:SetBackdropColor(unpack(color))
        box:SetBackdropBorderColor(unpack(borderColor))
      end
      self.OnRelease = release
      if release then release(self) end
    end
  end

  -- Right Side Container
  local container = AceGUI:Create("InlineGroup")
  container.frame:SetParent(frame)
  container.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -17, 10)
  container.frame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -63 - WeakAuras.normalWidth * 340, 0)
  container.frame:Show()
  container.frame:SetClipsChildren(true)
  container.titletext:Hide()
  -- Hide the border
  container.content:GetParent():SetBackdrop(nil)
  container.content:SetPoint("TOPLEFT", 0, -28)
  container.content:SetPoint("BOTTOMRIGHT", 0, 0)
  frame.container = container
  frame.moversizer, frame.mover = OptionsPrivate.MoverSizer(frame)

  -- filter line: a well with a drawn magnifier, a hint while empty, a cross to clear it.
  local filterInput = CreateFrame("EditBox", "WeakAurasFilterInput", frame, "BackdropTemplate")
  filterInput:SetAutoFocus(false)
  Style.SkinEditBox(filterInput, "text")
  filterInput:SetTextInsets(20, 20, 0, 0)
  local lensRing = filterInput:CreateTexture(nil, "ARTWORK")
  lensRing:SetTexture([[Interface\AddOns\WeakAuras\Media\Textures\Circle_White_Border.tga]])
  lensRing:SetVertexColor(Style.Color("textQuiet"))
  lensRing:SetSize(8, 8)
  lensRing:SetPoint("LEFT", filterInput, "LEFT", 6, 1)
  local lensHandle = filterInput:CreateTexture(nil, "ARTWORK")
  lensHandle:SetTexture(Style.white)
  lensHandle:SetVertexColor(Style.Color("textQuiet"))
  lensHandle:SetSize(1.5, 4)
  lensHandle:SetPoint("CENTER", lensRing, "BOTTOMRIGHT", 0, 0)
  lensHandle:SetRotation(math.rad(45))
  local filterHint = Style.NewText(filterInput, "text", "s", "textDisabled")
  filterHint:SetPoint("LEFT", filterInput, "LEFT", 20, 0)
  filterHint:SetText(L["Search"])
  local filterClear = CreateFrame("Button", nil, filterInput)
  filterClear:SetSize(16, 16)
  filterClear:SetPoint("RIGHT", filterInput, "RIGHT", -2, 0)
  local clearText = Style.NewText(filterClear, "text", "s", "textQuiet")
  clearText:SetPoint("CENTER")
  clearText:SetText("×")
  filterClear:SetScript("OnEnter", function() clearText:SetTextColor(Style.Color("text")) end)
  filterClear:SetScript("OnLeave", function() clearText:SetTextColor(Style.Color("textQuiet")) end)
  filterClear:SetScript("OnClick", function()
    filterInput:SetText("")
    filterInput:ClearFocus()
  end)
  filterClear:Hide()
  filterInput:SetScript("OnTextChanged", function(self)
    local empty = self:GetText() == ""
    filterHint:SetShown(empty)
    filterClear:SetShown(not empty)
    OptionsPrivate.SortDisplayButtons(filterInput:GetText())
  end)
  filterInput:SetScript("OnEscapePressed", filterInput.ClearFocus)
  filterInput:SetScript("OnEnterPressed", filterInput.ClearFocus)
  filterInput:SetHeight(18)
  filterInput:SetPoint("TOP", frame, "TOP", 0, -70)
  filterInput:SetPoint("LEFT", frame, "LEFT", 24, 0)
  filterInput:SetPoint("RIGHT", container.frame, "LEFT", -2, 0)
  frame.filterInput = filterInput
  filterInput:Hide()

  -- Left Side Container
  local buttonsContainer = AceGUI:Create("InlineGroup")
  buttonsContainer:SetWidth(170)
  PaintInlineGroup(buttonsContainer, "surface")
  buttonsContainer.frame:SetParent(frame)
  buttonsContainer.frame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 17, 12)
  buttonsContainer.frame:SetPoint("TOP", frame, "TOP", 0, -67)
  buttonsContainer.frame:SetPoint("RIGHT", container.frame, "LEFT", -17)
  buttonsContainer.frame:Show()
  frame.buttonsContainer = buttonsContainer

  -- Toolbar
  local toolbarContainer = CreateFrame("Frame", nil, buttonsContainer.frame)
  toolbarContainer:SetParent(buttonsContainer.frame)
  -- toolbarContainer:Hide()
  toolbarContainer:SetPoint("TOPLEFT", buttonsContainer.frame, "TOPLEFT", 30, 30)
  toolbarContainer:SetPoint("BOTTOMRIGHT", buttonsContainer.frame, "TOPRIGHT", 0, 0)
  -- Band of the toolbar, from the left edge of the window, a border below.
  local toolbarBand = toolbarContainer:CreateTexture(nil, "BACKGROUND")
  toolbarBand:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -29)
  toolbarBand:SetPoint("BOTTOM", toolbarContainer, "BOTTOM")
  toolbarBand:SetPoint("RIGHT", toolbarContainer, "RIGHT")
  toolbarBand:SetColorTexture(Style.Color("band"))
  local toolbarLine = toolbarContainer:CreateTexture(nil, "BORDER")
  toolbarLine:SetHeight(1)
  toolbarLine:SetPoint("BOTTOMLEFT", toolbarBand, "BOTTOMLEFT")
  toolbarLine:SetPoint("BOTTOMRIGHT", toolbarBand, "BOTTOMRIGHT")
  toolbarLine:SetColorTexture(Style.Color("border"))

  -- A restored aura may have moved or resized: its group, thumbnail and mover follow, as after a setter.
  local function RefreshRestored(records)
    for _, record in ipairs(records or {}) do
      local data = OptionsPrivate.Private.GetDataByUID(record.uid)
      if data then
        if record.actionType == "restore" then
          OptionsPrivate.Private.AddParents(data)
        end
        WeakAuras.UpdateThumbnail(data)
      end
    end
    OptionsPrivate.ResetMoverSizer()
  end

  -- Toolbar of DESIGN.md: 24 pixel buttons in groups (history, creation, toggles, tools) split by a 1 pixel rule.
  local function SizeToolbarButton(button, text)
    button:SetHeight(24)
    button:SetText(text)
  end
  local function NewToolbarSeparator(anchor)
    local separator = CreateFrame("Frame", nil, toolbarContainer)
    separator:SetSize(17, 14)
    separator:SetPoint("LEFT", anchor, "RIGHT", 0, 0)
    local line = separator:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(Style.Color("border"))
    line:SetSize(1, 14)
    line:SetPoint("CENTER")
    return separator
  end

  local undo = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(undo)
  undo:SetTooltip(L["Undo"])
  undo:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\upleft")
  -- The arrow fills half of its texture: only the drawn part, 14 pixels wide.
  undo:SetIconCoords(8/32, 24/32, 6/32, 24/32, 14, 16)
  undo:SetCallback("OnClick", function()
    local records = OptionsPrivate.Private.TimeMachine:DescribePrevious()
    OptionsPrivate.Private.TimeMachine:StepBackward()
    RefreshRestored(records)
    frame:FillOptions()
  end)
  undo.frame:SetParent(toolbarContainer)
  undo.frame:SetShown(OptionsPrivate.Private.Features:Enabled("undo"))
  undo:SetPoint("LEFT")
  undo.frame:SetCollapsesLayout(true)

  local redo = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(redo)
  redo:SetTooltip(L["Redo"])
  redo:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\upright")
  redo:SetIconCoords(7/32, 23/32, 6/32, 24/32, 14, 16)
  redo:SetCallback("OnClick", function()
    local records = OptionsPrivate.Private.TimeMachine:DescribeNext()
    OptionsPrivate.Private.TimeMachine:StepForward()
    RefreshRestored(records)
    frame:FillOptions()
  end)
  redo.frame:SetParent(toolbarContainer)
  redo.frame:SetShown(OptionsPrivate.Private.Features:Enabled("undo"))
  redo:SetPoint("LEFT", undo.frame, "RIGHT", 4, 0)
  redo.frame:SetEnabled(OptionsPrivate.Private.TimeMachine:DescribeNext() ~= nil)
  redo.frame:SetCollapsesLayout(true)
  local historySeparator = NewToolbarSeparator(redo.frame)
  historySeparator:SetShown(OptionsPrivate.Private.Features:Enabled("undo"))
  historySeparator:SetCollapsesLayout(true)
  OptionsPrivate.Private.Features:Subscribe("undo",
    function()
      undo.frame:Show()
      redo.frame:Show()
      historySeparator:Show()
    end,
    function()
      undo.frame:Hide()
      redo.frame:Hide()
      historySeparator:Hide()
    end
  )

  local tmControls = {
    undo = undo,
    redo = redo,
  }

  function tmControls:Step()
    -- slightly annoying workaround
    -- Buttons behave in a strange way if they are disabled inside of the OnClick handler
    -- where the pushed texture refuses to vanish until the button is enabled & user clicks it again
    -- so, just disable the button after next frame draw, so it's imperceptible to the user but we're not in the OnClick handler
    C_Timer.After(0, function()
      self.undo:SetDisabled(OptionsPrivate.Private.TimeMachine:DescribePrevious() == nil)
      self.redo:SetDisabled(OptionsPrivate.Private.TimeMachine:DescribeNext() == nil)
    end)
  end
  tmControls.Record = tmControls.Step
  tmControls:Step()
  OptionsPrivate.Private.TimeMachine.sub:AddSubscriber("Step", tmControls)
  OptionsPrivate.Private.TimeMachine.sub:AddSubscriber("Record", tmControls)

  local newButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(newButton, L["New Aura"])
  newButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\newaura")
  newButton.frame:SetParent(toolbarContainer)
  newButton.frame:Show()
  newButton:SetPoint("LEFT", historySeparator, "RIGHT", 0, 0)
  frame.toolbarContainer = toolbarContainer

  newButton:SetCallback("OnClick", function()
    frame:NewAura()
  end)

  local importButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(importButton, L["Import"])
  importButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\importsmall")
  importButton:SetCallback("OnClick", OptionsPrivate.ImportFromString)
  importButton.frame:SetParent(toolbarContainer)
  importButton.frame:Show()
  importButton:SetPoint("LEFT", newButton.frame, "RIGHT", 4, 0)

  local creationSeparator = NewToolbarSeparator(importButton.frame)

  -- /wa unlock from the toolbar, the primary button of the window: the placement mode closes the options itself.
  local unlockButton = Style.NewButton(toolbarContainer, L["Unlock"], "primary", function()
    OptionsPrivate.Private.StartPlacementMode()
  end)
  -- A crosshair of flat bars on the left of the text: four arms around a center square.
  for _, bar in ipairs({ { 2, 2, 0, 0 }, { 2, 4, 0, 5 }, { 2, 4, 0, -5 }, { 4, 2, -5, 0 }, { 4, 2, 5, 0 } }) do
    local part = unlockButton:CreateTexture(nil, "ARTWORK")
    part:SetColorTexture(Style.Color("onPrimary"))
    part:SetSize(bar[1], bar[2])
    part:SetPoint("CENTER", unlockButton, "LEFT", 14 + bar[3], bar[4])
  end
  unlockButton.text:ClearAllPoints()
  unlockButton.text:SetPoint("LEFT", 28, 0)
  local function FitUnlockButton()
    unlockButton:SetSize(unlockButton.text:GetStringWidth() + 40, 22)
  end
  FitUnlockButton()
  unlockButton:HookScript("OnShow", FitUnlockButton)
  unlockButton:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
    GameTooltip:SetText(L["Unlock"])
    GameTooltip:AddLine(L["Opens the placement mode (/wa unlock): move, size and anchor the auras on the screen."], 1, 1, 1, true)
    GameTooltip:Show()
  end)
  unlockButton:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  unlockButton:SetPoint("LEFT", creationSeparator, "RIGHT", 0, 0)

  local lockButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(lockButton)
  lockButton:SetTooltip(L["Lock Positions"])
  lockButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\lockPosition")
  lockButton:SetIconCoords(5/32, 27/32, 2/32, 32/32, 12, 16)
  lockButton:SetCallback("OnClick", function(self)
    if WeakAurasOptionsSaved.lockPositions then
      lockButton:SetStrongHighlight(false)
      lockButton:UnlockHighlight()
      WeakAurasOptionsSaved.lockPositions = false
    else
      lockButton:SetStrongHighlight(true)
      lockButton:LockHighlight()
      WeakAurasOptionsSaved.lockPositions = true
    end
  end)
  if WeakAurasOptionsSaved.lockPositions then
    lockButton:LockHighlight()
  end
  lockButton.frame:SetParent(toolbarContainer)
  lockButton.frame:Show()
  lockButton:SetPoint("LEFT", unlockButton, "RIGHT", 4, 0)

  local magnetButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(magnetButton)
  magnetButton:SetTooltip(L["Magnetically Align"])
  magnetButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\magnetic")
  magnetButton:SetCallback("OnClick", function(self)
    if WeakAurasOptionsSaved.magnetAlign then
      magnetButton:SetStrongHighlight(false)
      magnetButton:UnlockHighlight()
      WeakAurasOptionsSaved.magnetAlign = false
    else
      magnetButton:SetStrongHighlight(true)
      magnetButton:LockHighlight()
      WeakAurasOptionsSaved.magnetAlign = true
    end
  end)

  if WeakAurasOptionsSaved.magnetAlign then
    magnetButton:LockHighlight()
  end
  magnetButton.frame:SetParent(toolbarContainer)
  magnetButton.frame:Show()
  magnetButton:SetPoint("LEFT", lockButton.frame, "RIGHT", 4, 0)

  local gridButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(gridButton)
  -- A 13 pixel grid of 4 pixel cells, drawn with flat bars: the bordered square texture was too faint.
  gridButton:SetGlyph({
    { 13, 1, 0, 6 }, { 13, 1, 0, 2 }, { 13, 1, 0, -2 }, { 13, 1, 0, -6 },
    { 1, 13, -6, 0 }, { 1, 13, -2, 0 }, { 1, 13, 2, 0 }, { 1, 13, 6, 0 },
  })
  gridButton:SetTooltip(L["Grid"] .. "\n" .. L["Shows a grid while the options are open. With Magnetically Align, the auras snap to its lines.\nRight-click: grid spacing."])

  -- Pitch of the grid, opened by a right click on the Grid button.
  local gridSpacingSlider = AceGUI:Create("Slider")
  gridSpacingSlider:SetLabel(L["Grid Spacing"])
  gridSpacingSlider:SetSliderValues(8, 128, 1)
  gridSpacingSlider:SetWidth(180)
  gridSpacingSlider:SetCallback("OnValueChanged", function(_, _, value)
    WeakAurasOptionsSaved.gridSpacing = value
    OptionsPrivate.UpdatePlacementGrid()
  end)
  local gridSpacingBackground = gridSpacingSlider.frame:CreateTexture(nil, "BACKGROUND")
  gridSpacingBackground:SetColorTexture(Style.Color("raised"))
  gridSpacingBackground:SetPoint("TOPLEFT", -6, 6)
  gridSpacingBackground:SetPoint("BOTTOMRIGHT", 6, -6)
  gridSpacingSlider.frame:SetParent(toolbarContainer)
  gridSpacingSlider.frame:SetFrameLevel(toolbarContainer:GetFrameLevel() + 100)
  gridSpacingSlider.frame:Hide()
  toolbarContainer:HookScript("OnHide", function()
    gridSpacingSlider.frame:Hide()
  end)

  gridButton.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  gridButton:SetCallback("OnClick", function(self, _, mouseButton)
    if mouseButton == "RightButton" then
      gridSpacingSlider:SetValue(OptionsPrivate.GridSpacing())
      gridSpacingSlider.frame:SetShown(not gridSpacingSlider.frame:IsShown())
      return
    end
    WeakAurasOptionsSaved.gridAlign = not WeakAurasOptionsSaved.gridAlign
    gridButton:SetStrongHighlight(WeakAurasOptionsSaved.gridAlign)
    if WeakAurasOptionsSaved.gridAlign then
      gridButton:LockHighlight()
    else
      gridButton:UnlockHighlight()
    end
    OptionsPrivate.UpdatePlacementGrid()
  end)
  if WeakAurasOptionsSaved.gridAlign then
    gridButton:LockHighlight()
  end
  gridButton.frame:SetParent(toolbarContainer)
  gridButton.frame:Show()
  gridButton:SetPoint("LEFT", magnetButton.frame, "RIGHT", 4, 0)
  local toggleSeparator = NewToolbarSeparator(gridButton.frame)
  gridSpacingSlider:SetPoint("TOP", gridButton.frame, "BOTTOM", 0, -10)

  local unusedButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(unusedButton)
  -- A cross of two flat bars, red under the mouse: the button deletes.
  unusedButton:SetGlyph({ { 1.5, 12, 0, 0, 45 }, { 1.5, 12, 0, 0, -45 } })
  unusedButton:SetDanger(true)
  unusedButton:SetCallback("OnClick", OptionsPrivate.ConfirmDeleteUnused)
  unusedButton:SetTooltip(L["Unused Auras"] .. "\n" .. L["Deletes the auras no character of the account loaded for 30 days, and the empty groups.\nThe list is shown in the chat before the confirmation."])
  unusedButton.frame:SetParent(toolbarContainer)
  unusedButton.frame:Show()
  unusedButton:SetPoint("LEFT", toggleSeparator, "RIGHT", 0, 0)

  local replaceButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(replaceButton)
  replaceButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\edit")
  replaceButton:SetIconCoords(7/32, 28/32, 5/32, 26/32, 14, 14)
  replaceButton:SetCallback("OnClick", OptionsPrivate.AskReplace)
  replaceButton:SetTooltip(L["Replace"] .. "\n" .. L["Replaces a spell, a texture, a font or a sound in the selected auras, or in all auras when none is selected.\nThe changes are shown in the chat before the confirmation, and Undo reverts them."])
  replaceButton.frame:SetParent(toolbarContainer)
  replaceButton.frame:Show()
  replaceButton:SetPoint("LEFT", unusedButton.frame, "RIGHT", 4, 0)

  local auraSetButton = AceGUI:Create("WeakAurasToolbarButton")
  SizeToolbarButton(auraSetButton)
  auraSetButton:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\browse")
  auraSetButton:SetCallback("OnClick", OptionsPrivate.AskAuraSet)
  auraSetButton:SetTooltip(L["Aura Set"] .. "\n" .. L["Chooses a tag for this character: it then loads only the auras with this tag, or whose group has it.\nThe other characters keep their own choice."])
  auraSetButton.frame:SetParent(toolbarContainer)
  auraSetButton.frame:Show()
  auraSetButton:SetPoint("LEFT", replaceButton.frame, "RIGHT", 4, 0)

  if C_CooldownViewer then
    local hideCDMLabel = L["Hide Blizzard's CDM"]
    -- The toolbar has no room for the whole name: the acronym, the name in the tooltip.
    local hideCDMToggle = Style.NewCheck(toolbarContainer, "CDM", function(check)
      OptionsPrivate.Private.db.cdmHideBlizzard = check:GetChecked() == true
      OptionsPrivate.Private.ApplyCDMBackground()
    end)
    local function ReadHideCDM()
      hideCDMToggle:SetChecked(OptionsPrivate.Private.db.cdmHideBlizzard == true)
    end
    hideCDMToggle:SetPoint("LEFT", auraSetButton.frame, "RIGHT", 4, 0)
    ReadHideCDM()
    hideCDMToggle:HookScript("OnShow", function(check)
      ReadHideCDM()
      Style.FitCheck(check)
    end)
    hideCDMToggle:HookScript("OnEnter", function(check)
      GameTooltip:SetOwner(check, "ANCHOR_RIGHT")
      GameTooltip:SetText(hideCDMLabel)
      GameTooltip:AddLine(L["Sets the Cooldown Manager viewers to zero opacity. They stay shown, so aura tracking is unaffected."], 1, 1, 1, true)
      GameTooltip:AddLine(L["Applied out of combat; unchecking restores the original opacity."], 1, 1, 1, true)
      GameTooltip:Show()
    end)
    hideCDMToggle:HookScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end

  local loadProgress = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  loadProgress:SetPoint("TOP", buttonsContainer.frame, "TOP", 0, -4)
  loadProgress:SetText(L["Creating options: "].."0/0")
  frame.loadProgress = loadProgress

  frame.SetLoadProgressVisible = function(self, visible)
    self.loadProgessVisible = visible
    self:UpdateFrameVisible()
  end

  local buttonsScroll = AceGUI:Create("ScrollFrame")
  SkinScrollFrame(buttonsScroll)
  buttonsScroll:SetLayout("ButtonsScrollLayout")
  buttonsScroll.width = "fill"
  buttonsScroll.height = "fill"
  buttonsContainer:SetLayout("fill")
  buttonsContainer:AddChild(buttonsScroll)
  buttonsScroll.DeleteChild = function(self, delete)
    for index, widget in ipairs(buttonsScroll.children) do
      if widget == delete then
        tremove(buttonsScroll.children, index)
      end
    end
    delete:OnRelease()
    buttonsScroll:DoLayout()
  end
  frame.buttonsScroll = buttonsScroll

  function buttonsScroll:GetScrollPos()
    local status = self.status or self.localstatus
    return status.offset, status.offset + self.scrollframe:GetHeight()
  end

  -- override SetScroll to make children visible as needed
  local oldSetScroll = buttonsScroll.SetScroll
  buttonsScroll.SetScroll = function(self, value)
    oldSetScroll(self, value)
    self.LayoutFunc(self.content, self.children, true)
  end

  function buttonsScroll:SetScrollPos(top, bottom)
    local status = self.status or self.localstatus
    local viewheight = self.scrollframe:GetHeight()
    local height = self.content:GetHeight()
    local move

    local viewtop = -1 * status.offset
    local viewbottom = -1 * (status.offset + viewheight)
    if top > viewtop then
      move = top - viewtop
    elseif bottom < viewbottom then
      move = bottom - viewbottom
    else
      move = 0
    end

    status.offset = status.offset - move

    self.content:ClearAllPoints()
    self.content:SetPoint("TOPLEFT", 0, status.offset)
    self.content:SetPoint("TOPRIGHT", 0, status.offset)

    status.scrollvalue = status.offset / ((height - viewheight) / 1000.0)
  end

  -- Ready to Install section
  local pendingInstallButton = AceGUI:Create("WeakAurasLoadedHeaderButton")
  pendingInstallButton:SetText(L["Ready for Install"])
  pendingInstallButton:Disable()
  pendingInstallButton:EnableExpand()
  pendingInstallButton.frame.view:Hide()
  if odb.pendingImportCollapse then
    pendingInstallButton:Collapse()
  else
    pendingInstallButton:Expand()
  end
  pendingInstallButton:SetOnExpandCollapse(function()
    if pendingInstallButton:GetExpanded() then
      odb.pendingImportCollapse = nil
    else
      odb.pendingImportCollapse = true
    end
    OptionsPrivate.SortDisplayButtons()
  end)
  pendingInstallButton:SetExpandDescription(L["Expand all pending Import"])
  pendingInstallButton:SetCollapseDescription(L["Collapse all pending Import"])
  frame.pendingInstallButton = pendingInstallButton

  -- Ready for update section
  local pendingUpdateButton = AceGUI:Create("WeakAurasLoadedHeaderButton")
  pendingUpdateButton:SetText(L["Ready for Update"])
  pendingUpdateButton:Disable()
  pendingUpdateButton:EnableExpand()
  pendingUpdateButton.frame.view:Hide()
  if odb.pendingUpdateCollapse then
    pendingUpdateButton:Collapse()
  else
    pendingUpdateButton:Expand()
  end
  pendingUpdateButton:SetOnExpandCollapse(function()
    if pendingUpdateButton:GetExpanded() then
      odb.pendingUpdateCollapse = nil
    else
      odb.pendingUpdateCollapse = true
    end
    OptionsPrivate.SortDisplayButtons()
  end)
  pendingUpdateButton:SetExpandDescription(L["Expand all pending Import"])
  pendingUpdateButton:SetCollapseDescription(L["Collapse all pending Import"])
  frame.pendingUpdateButton = pendingUpdateButton

  -- Loaded section
  local loadedButton = AceGUI:Create("WeakAurasLoadedHeaderButton")
  loadedButton:SetText(L["Loaded/Standby"])
  loadedButton:Disable()
  loadedButton:EnableExpand()
  if odb.loadedCollapse then
    loadedButton:Collapse()
  else
    loadedButton:Expand()
  end
  loadedButton:SetOnExpandCollapse(function()
    if loadedButton:GetExpanded() then
      odb.loadedCollapse = nil
    else
      odb.loadedCollapse = true
    end
    OptionsPrivate.SortDisplayButtons()
  end)
  loadedButton:SetExpandDescription(L["Expand all loaded displays"])
  loadedButton:SetCollapseDescription(L["Collapse all loaded displays"])
  loadedButton:SetViewClick(function()
    local suspended = OptionsPrivate.Private.PauseAllDynamicGroups()

    if loadedButton.view.visibility == 2 then
      for _, child in ipairs(loadedButton.childButtons) do
        if child:IsLoaded() then
          child:PriorityHide(2)
        end
      end
      loadedButton:PriorityHide(2)
    else
      for _, child in ipairs(loadedButton.childButtons) do
        if child:IsLoaded() then
          child:PriorityShow(2)
        end
      end
      loadedButton:PriorityShow(2)
    end
    OptionsPrivate.Private.ResumeAllDynamicGroups(suspended)
  end)
  loadedButton.RecheckVisibility = function(self)
    local none, all = true, true
    for _, child in ipairs(loadedButton.childButtons) do
      if child:GetVisibility() ~= 2 then
        all = false
      end
      if child:GetVisibility() ~= 0 then
        none = false
      end
    end
    local newVisibility
    if all then
      newVisibility = 2
    elseif none then
      newVisibility = 0
    else
      newVisibility = 1
    end
    if newVisibility ~= self.view.visibility then
      self.view.visibility = newVisibility
      self:UpdateViewTexture()
    end
  end
  loadedButton:SetViewDescription(L["Toggle the visibility of all loaded displays"])
  loadedButton.childButtons = {}
  frame.loadedButton = loadedButton

  -- Not Loaded section
  local unloadedButton = AceGUI:Create("WeakAurasLoadedHeaderButton")
  unloadedButton:SetText(L["Not Loaded"])
  unloadedButton:Disable()
  unloadedButton:EnableExpand()
  if odb.unloadedCollapse then
    unloadedButton:Collapse()
  else
    unloadedButton:Expand()
  end
  unloadedButton:SetOnExpandCollapse(function()
    if unloadedButton:GetExpanded() then
      odb.unloadedCollapse = nil
    else
      odb.unloadedCollapse = true
    end
    OptionsPrivate.SortDisplayButtons()
  end)
  unloadedButton:SetExpandDescription(L["Expand all non-loaded displays"])
  unloadedButton:SetCollapseDescription(L["Collapse all non-loaded displays"])
  unloadedButton:SetViewClick(function()
    local suspended = OptionsPrivate.Private.PauseAllDynamicGroups()
    if unloadedButton.view.visibility == 2 then
      for _, child in ipairs(unloadedButton.childButtons) do
        child:PriorityHide(2)
      end
      unloadedButton:PriorityHide(2)
    else
      for _, child in ipairs(unloadedButton.childButtons) do
        child:PriorityShow(2)
      end
      unloadedButton:PriorityShow(2)
    end
    OptionsPrivate.Private.ResumeAllDynamicGroups(suspended)
  end)
  unloadedButton.RecheckVisibility = function(self)
    local none, all = true, true
    for _, child in ipairs(unloadedButton.childButtons) do
      if child:GetVisibility() ~= 2 then
        all = false
      end
      if child:GetVisibility() ~= 0 then
        none = false
      end
    end
    local newVisibility
    if all then
      newVisibility = 2
    elseif none then
      newVisibility = 0
    else
      newVisibility = 1
    end
    if newVisibility ~= self.view.visibility then
      self.view.visibility = newVisibility
      self:UpdateViewTexture()
    end
  end
  unloadedButton:SetViewDescription(L["Toggle the visibility of all non-loaded displays"])
  unloadedButton.childButtons = {}
  frame.unloadedButton = unloadedButton

  -- Sidebar used for Dynamic Text Replacements
  local sidegroup = AceGUI:Create("WeakAurasInlineGroup")
  sidegroup.frame:SetParent(frame)
  sidegroup.frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -63);
  sidegroup.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -17, 46);
  sidegroup.frame:Show()
  sidegroup:SetLayout("flow")

  local dynamicTextCodesFrame = CreateFrame("Frame", "WeakAurasTextReplacements", sidegroup.frame, "PortraitFrameTemplate")
  dynamicTextCodesFrame.Bg:SetColorTexture(Style.Color("background"))
  ButtonFrameTemplate_HidePortrait(dynamicTextCodesFrame)
  dynamicTextCodesFrame:SetPoint("TOPLEFT", sidegroup.frame, "TOPRIGHT", 20, 0)
  dynamicTextCodesFrame:SetPoint("BOTTOMLEFT", sidegroup.frame, "BOTTOMRIGHT", 20, 0)
  dynamicTextCodesFrame:SetWidth(250)
  dynamicTextCodesFrame:SetScript("OnHide", function()
    OptionsPrivate.currentDynamicTextInput = nil
  end)
  frame.dynamicTextCodesFrame = dynamicTextCodesFrame

  local dynamicTextCodesFrameTitle
  if dynamicTextCodesFrame.TitleContainer and dynamicTextCodesFrame.TitleContainer.TitleText then
    dynamicTextCodesFrameTitle = dynamicTextCodesFrame.TitleContainer.TitleText
  elseif dynamicTextCodesFrame.TitleText then
    dynamicTextCodesFrameTitle = dynamicTextCodesFrame.TitleText
  end
  if dynamicTextCodesFrameTitle then
    dynamicTextCodesFrameTitle:SetText("Dynamic Text Replacements")
    dynamicTextCodesFrameTitle:SetJustifyH("CENTER")
    dynamicTextCodesFrameTitle:SetPoint("LEFT", dynamicTextCodesFrame, "TOPLEFT")
    dynamicTextCodesFrameTitle:SetPoint("RIGHT", dynamicTextCodesFrame, "TOPRIGHT", -10, 0)
  end

  local dynamicTextCodesLabel = AceGUI:Create("Label")
  dynamicTextCodesLabel:SetText(L["Insert text replacement codes to make text dynamic."])
  dynamicTextCodesLabel:SetFontObject(GameFontNormal)
  dynamicTextCodesLabel:SetPoint("TOP", dynamicTextCodesFrame, "TOP", 0, -35)
  dynamicTextCodesLabel:SetFontObject(GameFontNormalSmall2)
  dynamicTextCodesLabel.frame:SetParent(dynamicTextCodesFrame)
  dynamicTextCodesLabel.frame:Show()

  local dynamicTextCodesScrollContainer = AceGUI:Create("SimpleGroup")
  dynamicTextCodesScrollContainer.frame:SetParent(dynamicTextCodesFrame)
  dynamicTextCodesScrollContainer.frame:SetPoint("TOP", dynamicTextCodesLabel.frame, "BOTTOM", 0, -15)
  dynamicTextCodesScrollContainer.frame:SetPoint("LEFT", dynamicTextCodesFrame, "LEFT", 15, 0)
  dynamicTextCodesScrollContainer.frame:SetPoint("BOTTOMRIGHT", dynamicTextCodesFrame, "BOTTOMRIGHT", -15, 5)
  dynamicTextCodesScrollContainer:SetFullWidth(true)
  dynamicTextCodesScrollContainer:SetFullHeight(true)
  dynamicTextCodesScrollContainer:SetLayout("Fill")


  local dynamicTextCodesScrollList = AceGUI:Create("ScrollFrame")
  dynamicTextCodesScrollList:SetLayout("List")
  dynamicTextCodesScrollList:SetPoint("TOPLEFT", dynamicTextCodesScrollContainer.frame, "TOPLEFT")
  dynamicTextCodesScrollList:SetPoint("BOTTOMRIGHT", dynamicTextCodesScrollContainer.frame, "BOTTOMRIGHT")
  dynamicTextCodesScrollList.frame:SetParent(dynamicTextCodesFrame)
  dynamicTextCodesScrollList:FixScroll()
  dynamicTextCodesScrollList.scrollframe:SetScript(
    "OnScrollRangeChanged",
    function(frame)
      frame.obj:DoLayout()
    end
  )

  dynamicTextCodesScrollList.scrollframe:SetScript(
    "OnSizeChanged",
    function(frame)
      if frame.obj.scrollBarShown then
        frame.obj.content.width = frame.obj.content.original_width - 10
        frame.obj.scrollframe:SetPoint("BOTTOMRIGHT", -10, 0)
      end
    end
  )


  dynamicTextCodesFrame.scrollList = dynamicTextCodesScrollList
  dynamicTextCodesFrame.label = dynamicTextCodesLabel
  dynamicTextCodesFrame:Hide()

  function OptionsPrivate.ToggleTextReplacements(data, widget, event)
    -- If the text edit has focus when the user clicks on the button, we'll get two events:
    -- a) The OnEditFocusLost
    -- b) The ToggleButton OnClick event
    -- Since we want to hide the text replacement window in that case,
    -- ignore the ToggleButton if it is directly after the  OnEditFocusLost
    local currentTime = GetTime()
    if event == "ToggleButton"
      and dynamicTextCodesFrame.lastCaller
      and dynamicTextCodesFrame.lastCaller.event == "OnEditFocusLost"
      and currentTime - dynamicTextCodesFrame.lastCaller.time < 0.2
    then
      return
    end

    dynamicTextCodesFrame.lastCaller = {
      event = event,
      time = currentTime,
    }

    if event == "OnEnterPressed" then
      dynamicTextCodesFrame:Hide()
    elseif event == "OnEditFocusGained" or not dynamicTextCodesFrame:IsShown() then
      dynamicTextCodesFrame:Show()
      if OptionsPrivate.currentDynamicTextInput ~= widget then
        OptionsPrivate.UpdateTextReplacements(dynamicTextCodesFrame, data)
      end
      OptionsPrivate.currentDynamicTextInput = widget
    elseif not dynamicTextCodesFrame:IsMouseOver() then -- Prevents hiding when clicking inside the frame
      dynamicTextCodesFrame:Hide()
    end
  end

  frame.ClearOptions = function(self, id)
    aceOptions[id] = nil
    OptionsPrivate.commonOptionsCache:Clear()
    if type(id) == "string" then
      local data = WeakAuras.GetData(id)
      if data and data.parent then
        frame:ClearOptions(data.parent)
      end
      for child in OptionsPrivate.Private.TraverseAllChildren(tempGroup) do
        if (id == child.id) then
          frame:ClearOptions(tempGroup.id)
        end
      end
    end
  end

  frame.ReloadOptions = function(self)
    if self.pickedDisplay then
      self:ClearAndUpdateOptions(self.pickedDisplay, true)
      self:FillOptions()
    end
  end

  frame.ClearAndUpdateOptions = function(self, id, clearChildren)
    if not id then
      if type(self.pickedDisplay) == "table" then
        id = tempGroup.id
      else
        id = self.pickedDisplay
      end
      if not id then
        return
      end
    end

    frame:ClearOptions(id)

    if clearChildren then
      local data
      if type(id) == "string" then
        data = WeakAuras.GetData(id)
      elseif self.pickedDisplay then
        data = tempGroup
      end

      for child in OptionsPrivate.Private.TraverseAllChildren(data) do
        frame:ClearOptions(child.id)
      end
    end
    if (type(self.pickedDisplay) == "string" and self.pickedDisplay == id)
       or (type(self.pickedDisplay) == "table" and id == tempGroup.id)
    then
      frame:UpdateOptions()
    end
  end

  frame.UpdateOptions = function(self)
    if not self.pickedDisplay then
      return
    end
    OptionsPrivate.commonOptionsCache:Clear()
    self.selectedTab = self.selectedTab or "region"
    local data
    if type(self.pickedDisplay) == "string" then
      data = WeakAuras.GetData(frame.pickedDisplay)
    elseif self.pickedDisplay then
      data = tempGroup
    end

    if not data.controlledChildren or data == tempGroup then
      if self.selectedTab == "group" then
        self.selectedTab = "region"
      end
    end

    local optionTable = self:EnsureOptions(data, self.selectedTab)
    if optionTable then
      OptionsPrivate.UseColorPalette(optionTable)
      AceConfigRegistry:RegisterOptionsTable("WeakAuras", optionTable, true)
    end
  end

  frame.EnsureOptions = function(self, data, tab)
    local id = data.id
    aceOptions[id] = aceOptions[id] or {}
    if not aceOptions[id][tab] then
      local optionsGenerator =
      {
        group = OptionsPrivate.GetGroupOptions,
        region =  OptionsPrivate.GetDisplayOptions,
        trigger = OptionsPrivate.GetTriggerOptions,
        conditions = OptionsPrivate.GetConditionOptions,
        load = OptionsPrivate.GetLoadOptions,
        action = OptionsPrivate.GetActionOptions,
        animation = OptionsPrivate.GetAnimationOptions,
        authorOptions = OptionsPrivate.GetAuthorOptions,
        information = OptionsPrivate.GetInformationOptions,
      }
      if optionsGenerator[tab] then
        aceOptions[id][tab] = optionsGenerator[tab](data)
      end
    end
    return aceOptions[id][tab]
  end

  -- This function refills the options pane
  -- This is ONLY necessary if AceOptions doesn't know that it should do
  -- that automatically. That is any change that goes through the AceOptions
  -- doesn't need to call this
  -- Any changes to the options that go around that, e.g. drag/drop, group,
  -- texture pick, etc should call this
  frame.FillOptions = function(self)
    if not self.pickedDisplay then
      return
    end

    OptionsPrivate.commonOptionsCache:Clear()

    frame:UpdateOptions()

    local data
    if type(self.pickedDisplay) == "string" then
      data = WeakAuras.GetData(frame.pickedDisplay)
      OptionsPrivate.Private.TimeMachine:Watch(data)
    elseif self.pickedDisplay then
      data = tempGroup
      for _, childId in ipairs(tempGroup.controlledChildren) do
        OptionsPrivate.Private.TimeMachine:Watch(WeakAuras.GetData(childId))
      end
    end

    local tabsWidget

    -- 8 pixels between the toolbar and the tabs.
    container.frame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -63 - WeakAuras.normalWidth * 340, -18)
    container:ReleaseChildren()
    container:SetLayout("Fill")
    tabsWidget = AceGUI:Create("WeakAurasTabGroup")

    local tabs = {
      { value = "region", text = L["Display"]},
      { value = "trigger", text = L["Trigger"]},
      { value = "conditions", text = L["Conditions"]},
      { value = "action", text = L["Actions"]},
      { value = "animation", text = L["Animations"]},
      { value = "load", text = L["Load"]},
      { value = "authorOptions", text = L["Custom Options"]},
      { value = "information", text = L["Information"]},
    }
    -- Check if group and not the temp group
    if data.controlledChildren and type(data.id) == "string" then
      tinsert(tabs, 1, { value = "group", text = L["Group"]})
    end

    tabsWidget:SetTabs(tabs)
    tabsWidget:SelectTab(self.selectedTab)
    tabsWidget:SetLayout("Fill")
    container:AddChild(tabsWidget)

    local group = AceGUI:Create("WeakAurasInlineGroup")
    tabsWidget:AddChild(group)

    tabsWidget:SetCallback("OnGroupSelected", function(self, event, tab)
        frame.selectedTab = tab
        frame:FillOptions()
      end)

    AceConfigDialog:Open("WeakAuras", group)
    tabsWidget:SetTitle("")

    if data.controlledChildren and #data.controlledChildren == 0 then
      WeakAurasOptions:NewAura()
    end

    if frame.dynamicTextCodesFrame then
      frame.dynamicTextCodesFrame:Hide()
    end
  end

  frame.ClearPick = function(self, id)
    local index = nil
    for i, childId in pairs(tempGroup.controlledChildren) do
      if childId == id then
        index = i
        break
      end
    end

    tremove(tempGroup.controlledChildren, index)
    displayButtons[id]:ClearPick()

    -- Clear trigger expand state
    OptionsPrivate.ClearTriggerExpandState()

    self:ClearOptions(tempGroup.id)
    self:FillOptions()
  end

  frame.OnRename = function(self, uid, oldid, newid)
    if type(frame.pickedDisplay) == "string" and frame.pickedDisplay == oldid then
      frame.pickedDisplay = newid
    else
      for i, childId in pairs(tempGroup.controlledChildren) do
        if (childId == newid) then
          tempGroup.controlledChildren[i] = newid
        end
      end
    end
  end

  frame.ClearPicks = function(self, noHide)
    local suspended = OptionsPrivate.Private.PauseAllDynamicGroups()
    for id, button in pairs(displayButtons) do
      button:ClearPick(true)
      if not noHide then
        button:PriorityHide(1)
      end
    end
    if not noHide then
      for id, button in pairs(displayButtons) do
        if button.data.controlledChildren then
          button:RecheckVisibility()
        end
      end
    end

    frame.pickedDisplay = nil
    frame.pickedOption = nil
    wipe(tempGroup.controlledChildren)
    loadedButton:ClearPick(noHide)
    unloadedButton:ClearPick(noHide)
    container:ReleaseChildren()
    self.moversizer:Hide()

    OptionsPrivate.Private.ResumeAllDynamicGroups(suspended)

    -- Clear trigger expand state
    OptionsPrivate.ClearTriggerExpandState()
  end

  frame.GetTargetAura = function(self)
    if self.pickedDisplay then
      if type(self.pickedDisplay) == "table" and tempGroup.controlledChildren and tempGroup.controlledChildren[1] then
        return tempGroup.controlledChildren[1]
      elseif type(self.pickedDisplay) == "string" then
        return self.pickedDisplay
      end
    end
    return nil
  end

  frame.OpenPacks = function(self)
    self:ClearPicks()
    self.dynamicTextCodesFrame:Hide()
    self.pickedOption = "Packs"

    container.frame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -63 - WeakAuras.normalWidth * 340, 0)
    container:SetLayout("fill")
    local border = AceGUI:Create("InlineGroup")
    PaintInlineGroup(border, "raised")
    border:SetLayout("Fill")
    container:AddChild(border)

    local containerScroll = AceGUI:Create("ScrollFrame")
    SkinScrollFrame(containerScroll)
    containerScroll:SetLayout("flow")
    border:AddChild(containerScroll)

    local function AddTitle(text)
      local label = AceGUI:Create("Label")
      PaintSectionTitle(label, text)
      containerScroll:AddChild(label)
    end

    local function AddPackButton(title, description, icon, onClick)
      local button = AceGUI:Create("WeakAurasNewButton")
      button:SetTitle(title)
      button:SetDescription(description)
      button:SetIcon(icon)
      button:SetClick(onClick)
      containerScroll:AddChild(button)
    end

    local playerClass = select(2, UnitClass("player"))
    local classPack = OptionsPrivate.classPacks[playerClass]
    if classPack then
      local classIcon = "Interface\\Icons\\ClassIcon_" .. playerClass
      AddTitle(L["Class HUD"])
      local intro = AceGUI:Create("Label")
      intro:SetText(L["Whole HUD updates every block to the pack settings. A single block leaves the other installed blocks as they are."])
      intro:SetFullWidth(true)
      containerScroll:AddChild(intro)
      AddPackButton(L["Whole HUD"], L["Full UI pack for your class: rotation, cooldowns, buffs and resources, ready to play"],
        classIcon, function()
          OptionsPrivate.PreferClassPackUpdate(classPack)
          WeakAuras.Import(classPack)
        end)
      for _, block in ipairs(OptionsPrivate.GetClassPackBlocks(classPack)) do
        local texts = OptionsPrivate.classPackBlockTexts[block.label]
        AddPackButton(texts and L[texts[1]] or block.label, texts and L[texts[2]] or "", classIcon, function()
          local importData = OptionsPrivate.BuildClassPackBlockImport(classPack, block.label)
          if importData then
            OptionsPrivate.PreferClassPackUpdate(classPack)
            WeakAuras.Import(importData)
          end
        end)
      end
    end

    AddTitle(L["Utility Packs"])
    local category
    for _, utilityPack in ipairs(OptionsPrivate.utilityPacks) do
      if utilityPack.category ~= category then
        category = utilityPack.category
        AddTitle(L[category])
      end
      AddPackButton(L[utilityPack.name], L[utilityPack.description], utilityPack.icon, function()
        WeakAuras.Import(utilityPack.data)
      end)
    end
  end

  frame.NewAura = function(self)
    local targetId
    local targetIsDynamicGroup

    if self.pickedDisplay then
      if type(self.pickedDisplay) == "table" and tempGroup.controlledChildren and tempGroup.controlledChildren[1] then
        targetId = tempGroup.controlledChildren[1]
        WeakAuras.PickDisplay(targetId)
      elseif type(self.pickedDisplay) == "string" then
        targetId = self.pickedDisplay
      else
        self:ClearPicks()
      end
    end

    if targetId then
      local pickedButton = OptionsPrivate.GetDisplayButton(targetId)
      if pickedButton.data.controlledChildren then
        targetIsDynamicGroup = pickedButton.data.regionType == "dynamicgroup"
      else
        local parent = pickedButton.data.parent
        local parentData = parent and WeakAuras.GetData(parent)
        targetIsDynamicGroup = parentData and parentData.regionType == "dynamicgroup"
      end
    end
    self.dynamicTextCodesFrame:Hide()
    self.moversizer:Hide()
    self.pickedOption = "New"

    container:ReleaseChildren()
    container.frame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -63 - WeakAuras.normalWidth * 340, 0)
    container:SetLayout("fill")
    local border = AceGUI:Create("InlineGroup")
    PaintInlineGroup(border, "raised")
    border:SetLayout("Fill")
    container:AddChild(border)

    local containerScroll = AceGUI:Create("ScrollFrame")
    SkinScrollFrame(containerScroll)
    containerScroll:SetLayout("flow")
    border:AddChild(containerScroll)

    local simpleLabel = AceGUI:Create("Label")
    PaintSectionTitle(simpleLabel, L["Simple"])
    containerScroll:AddChild(simpleLabel)

    local packsButton = AceGUI:Create("WeakAurasNewButton")
    packsButton:SetTitle(L["Packs"])
    packsButton:SetDescription(L["Ready-made auras for your class, and utility packs"])
    packsButton:SetIcon("Interface\\Icons\\INV_Misc_Bag_08")
    packsButton:SetClick(function()
      self:OpenPacks()
    end)
    containerScroll:AddChild(packsButton)

    if C_AddOns.GetAddOnEnableState("WeakAurasTemplates") ~= Enum.AddOnEnableState.None then
      local button = AceGUI:Create("WeakAurasNewButton")
      button:SetTitle(L["Premade Auras"])
      button:SetDescription(L["Offer a guided way to create auras for your character"])
      button:SetIcon("Interface\\Icons\\Inv_misc_book_09")
      button:SetClick(function()
        OptionsPrivate.OpenTriggerTemplate(nil, self:GetTargetAura())
      end)
      containerScroll:AddChild(button)
    end

    local spacer1Label = AceGUI:Create("Label")
    spacer1Label:SetText("")
    containerScroll:AddChild(spacer1Label)

    local advancedLabel = AceGUI:Create("Label")
    PaintSectionTitle(advancedLabel, L["Advanced"])
    containerScroll:AddChild(advancedLabel)

    local regionTypesSorted = {}
    for regionType, regionData in pairs(OptionsPrivate.Private.regionOptions) do
      tinsert(regionTypesSorted, regionType)
    end

    -- Sort group + dynamic group first, then the others alphabetically
    table.sort(regionTypesSorted, function(a, b)
      if (a == "group") then
        return true
      end

      if (b == "group") then
        return false
      end

      if (a == "dynamicgroup") then
        return true
      end
      if (b == "dynamicgroup") then
        return false
      end

      return OptionsPrivate.Private.regionOptions[a].displayName < OptionsPrivate.Private.regionOptions[b].displayName
    end)

    if not targetIsDynamicGroup then
      frame.modernGroupIcon = frame.modernGroupIcon or OptionsPrivate.CreateModernGroupIcon()
      local modernGroupButton = AceGUI:Create("WeakAurasNewButton")
      modernGroupButton:SetTitle(L["Modern Aura Group"])
      modernGroupButton:SetIcon(frame.modernGroupIcon)
      modernGroupButton:SetDescription(L["New group for Aura (Modern) displays: laid out left to right, 2 pixels apart, with the layout kept in combat."])
      modernGroupButton:SetClick(function()
        local flowSettings = { blizzardFlow = true, blizzardFlowGrowth = "RIGHT", blizzardFlowSpacing = 2 }
        WeakAuras.NewAura(flowSettings, "group", self:GetTargetAura())
      end)
      containerScroll:AddChild(modernGroupButton)
    end

    for index, regionType in ipairs(regionTypesSorted) do
      if (targetIsDynamicGroup and (regionType == "group" or regionType == "dynamicgroup")) then
        -- Dynamic groups can't contain group/dynamic groups
      else
        local regionData = OptionsPrivate.Private.regionOptions[regionType]
        local button = AceGUI:Create("WeakAurasNewButton")
        button:SetTitle(regionData.displayName)
        if(type(regionData.icon) == "string" or type(regionData.icon) == "table") then
          button:SetIcon(regionData.icon)
        end
        button:SetDescription(regionData.description)
        button:SetClick(function()
          WeakAuras.NewAura(nil, regionType, self:GetTargetAura())
        end)
        containerScroll:AddChild(button)
      end
    end

    local spacer2Label = AceGUI:Create("Label")
    spacer2Label:SetText("")
    containerScroll:AddChild(spacer2Label)

    local externalLabel = AceGUI:Create("Label")
    PaintSectionTitle(externalLabel, L["External"])
    containerScroll:AddChild(externalLabel)

    local spacer3Label = AceGUI:Create("Label")
    spacer3Label:SetText("")
    containerScroll:AddChild(spacer3Label)

    -- Import
    local importButton = AceGUI:Create("WeakAurasNewButton")
    importButton:SetTitle(L["Import"])

    local data = {
      outline = false,
      color = {1, 1, 1, 1},
      justify = "CENTER",
      font = "Friz Quadrata TT",
      fontSize = 8,
      displayText = [[
        b4vmErLxtfM
        xu5fDEn1CEn
        vmUmJyZ4hyY
        DtnEnvBEnfz
        EnfzErLxtjx
        zNL2BUrvEWv
        MxtfwDYfMyH
        jNxtLgzEnLt
        LDNx051u25L
        tXmdmY4fDE5
      ]]
    }

    if not frame.importThumbnail then
      local thumbnail = OptionsPrivate.Private.regionOptions["text"].createThumbnail(UIParent)
      OptionsPrivate.Private.regionOptions["text"].modifyThumbnail(UIParent, thumbnail, data)
      thumbnail.mask:SetPoint("BOTTOMLEFT", thumbnail, "BOTTOMLEFT", 3, 3)
      thumbnail.mask:SetPoint("TOPRIGHT", thumbnail, "TOPRIGHT", -3, -3)
      frame.importThumbnail = thumbnail
    end

    importButton:SetIcon(frame.importThumbnail)
    importButton:SetDescription(L["Import a display from an encoded string"])
    importButton:SetClick(OptionsPrivate.ImportFromString)
    containerScroll:AddChild(importButton)
  end

  local function ExpandParents(data)
    if data.parent then
      if not displayButtons[data.parent]:GetExpanded() then
        displayButtons[data.parent]:Expand()
      end
      local parentData = WeakAuras.GetData(data.parent)
      ExpandParents(parentData)
    end
  end

  frame.PickDisplay = function(self, id, tab, noHide)
    local data = WeakAuras.GetData(id)

    -- Always expand even if already picked
    ExpandParents(data)

    if OptionsPrivate.Private.loaded[id] ~= nil then
      -- Under loaded
      if not loadedButton:GetExpanded() then
        loadedButton:Expand()
      end
    else
      -- Under Unloaded
      if not unloadedButton:GetExpanded() then
        unloadedButton:Expand()
      end
    end

    if self.pickedDisplay == id and (self.pickedDisplay == tab or tab == nil) then
      return
    end

    local suspended = OptionsPrivate.Private.PauseAllDynamicGroups()

    self:ClearPicks(noHide)

    displayButtons[id]:Pick()
    self.pickedDisplay = id


    if tab then
      self.selectedTab = tab
    end
    self:FillOptions()
    WeakAuras.SetMoverSizer(id)

    local _, _, _, _, yOffset = displayButtons[id].frame:GetPoint(1)
    if not yOffset then
      yOffset = displayButtons[id].frame.yOffset
    end
    if yOffset then
      self.buttonsScroll:SetScrollPos(yOffset, yOffset - 32)
    end

    for child in OptionsPrivate.Private.TraverseAllChildren(data) do
      displayButtons[child.id]:PriorityShow(1)
    end
    displayButtons[data.id]:RecheckParentVisibility()

    OptionsPrivate.Private.ResumeAllDynamicGroups(suspended)
  end

  frame.CenterOnPicked = function(self)
    if self.pickedDisplay then
      local centerId = type(self.pickedDisplay) == "string" and self.pickedDisplay or self.pickedDisplay.controlledChildren[1]

      if displayButtons[centerId] then
        local _, _, _, _, yOffset = displayButtons[centerId].frame:GetPoint(1)
        if not yOffset then
          yOffset = displayButtons[centerId].frame.yOffset
        end
        if yOffset then
          self.buttonsScroll:SetScrollPos(yOffset, yOffset - 32)
        end
      end
    end
  end

  frame.PickDisplayMultiple = function(self, id)
    if not self.pickedDisplay then
      self:PickDisplay(id)
    else
      local wasGroup = false
      if type(self.pickedDisplay) == "string" then
        if WeakAuras.GetData(self.pickedDisplay).controlledChildren or WeakAuras.GetData(id).controlledChildren then
          wasGroup = true
        elseif not OptionsPrivate.IsDisplayPicked(id) then
          tinsert(tempGroup.controlledChildren, self.pickedDisplay)
        end
      end
      if wasGroup then
        self:PickDisplay(id)
      elseif not OptionsPrivate.IsDisplayPicked(id) then
        self.pickedDisplay = tempGroup
        displayButtons[id]:Pick()
        tinsert(tempGroup.controlledChildren, id)
        OptionsPrivate.ClearOptions(tempGroup.id)
        self:FillOptions()
      end
    end
  end

  frame.PickDisplayBatch = function(self, batchSelection)
    local alreadySelected = {}
    for child in OptionsPrivate.Private.TraverseAllChildren(tempGroup) do
      alreadySelected[child.id] = true
    end

    for _, id in ipairs(batchSelection) do
      if not alreadySelected[id] then
        displayButtons[id]:Pick()
        tinsert(tempGroup.controlledChildren, id)
      end
    end
    frame:ClearOptions(tempGroup.id)
    self.pickedDisplay = tempGroup
    self:FillOptions()
  end

  frame.GetPickedDisplay = function(self)
    if type(self.pickedDisplay) == "string" then
      return WeakAuras.GetData(self.pickedDisplay)
    end
    return self.pickedDisplay
  end

  frame:SetClampedToScreen(true)
  local w, h = frame:GetSize()
  local left, right, top, bottom = w/2,-w/2, 0, h-25
  frame:SetClampRectInsets(left, right, top, bottom)

  return frame
end

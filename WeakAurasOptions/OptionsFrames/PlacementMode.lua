-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

-- Placement mode of Musca (/wa unlock): the screen darkened under a grid, every aura this character can load shown
-- with a box, as with the options open. A box is dragged, resized, anchored to another; the panel takes typed values.
-- The bar on top turns the grid and the snap on or off, reverts the changes, quits. Escape closes one layer at a time.
-- Combat suspends the mode, which comes back after it with its changes.

local gridSpacing = 32
-- A stronger line every 4 lines, 128 pixels.
local majorEvery = 4
local logo = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\logo_musca_round.tga"

local Private, Style
local active, suspended = false, false
local overlay, bar, intro, events
local host
-- Animation groups of the entrance, stopped at once when the mode hides.
local entrance = {}

local function Boxes()
  return Private.PlacementBoxes
end

local roleLabels = {
  group = L["Group"],
  child = L["In group"],
  anchored = L["Anchored"],
  other = L["Alone"],
}

local function ReadPicker()
  local r, g, b = ColorPickerFrame:GetColorRGB()
  return { r, g, b, ColorPickerFrame:GetColorAlpha() }
end

-- The request of the color picker opened by a swatch, while it may still be open.
local pickerRequest
-- Cancels and hides the color picker when a swatch opened it: true when it was open.
local function ClosePicker()
  local request = pickerRequest
  pickerRequest = nil
  if request and ColorPickerFrame:IsShown() and ColorPickerFrame.swatchFunc == request.swatchFunc then
    request.cancelFunc()
    ColorPickerFrame:Hide()
    return true
  end
  return false
end

-- A square of the border color of one kind of box: click opens the color picker, right-click restores the default.
local function NewRoleSwatch(parent, role)
  local swatch = CreateFrame("Button", nil, parent, "BackdropTemplate")
  swatch:SetSize(22, 14)
  Style.Fill(swatch, "well", "borderField")
  -- A checkerboard that shows through a translucent color, as in the color option of the aura panels.
  local checkers = swatch:CreateTexture(nil, "BORDER")
  checkers:SetTexture(188523)
  checkers:SetTexCoord(0.25, 0, 0.5, 0.25)
  checkers:SetDesaturated(true)
  checkers:SetVertexColor(1, 1, 1, 0.75)
  checkers:SetPoint("TOPLEFT", 2, -2)
  checkers:SetPoint("BOTTOMRIGHT", -2, 2)
  swatch.color = swatch:CreateTexture(nil, "ARTWORK")
  swatch.color:SetAllPoints(checkers)
  swatch.label = Style.NewText(swatch, "text", "s", "text")
  swatch.label:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
  swatch.label:SetText(roleLabels[role])
  function swatch.Paint()
    local r, g, b, a = Boxes().RoleColor(role)
    swatch.color:SetColorTexture(r, g, b, a)
  end
  swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  swatch:SetScript("OnClick", function(_, button)
    ClosePicker()
    ColorPickerFrame:Hide()
    if button == "RightButton" then
      Boxes().SetRoleColor(role, nil)
      swatch.Paint()
      return
    end
    -- before: the picked table restored by Cancel, nil for the default border.
    local r, g, b, a, before = Boxes().RoleColor(role)
    -- The default border of the classic design is transparent: a color picked from there would stay unseen.
    if not before and a == 0 then
      a = 1
    end
    -- The picker calls swatchFunc while it opens, before it sets the opacity: ignored until it is shown.
    local ready = false
    local function Apply(color)
      Boxes().SetRoleColor(role, color)
      swatch.Paint()
    end
    local function ApplyPicked()
      if ready then
        Apply(ReadPicker())
      end
    end
    local request = {
      r = r, g = g, b = b,
      opacity = a,
      hasOpacity = true,
      swatchFunc = ApplyPicked,
      opacityFunc = ApplyPicked,
      cancelFunc = function() Apply(before) end,
    }
    ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    ColorPickerFrame:SetClampedToScreen(true)
    OptionsPrivate.PrepareColorPalette(request)
    ColorPickerFrame:SetupColorPickerAndShow(request)
    OptionsPrivate.ShowColorPalette()
    ready = true
    pickerRequest = request
  end)
  swatch:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(Style.Color("primary"))
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(roleLabels[role])
    GameTooltip:AddLine(L["Border of these boxes. Click: pick a color. Right-click: default color."], 1, 1, 1, true)
    GameTooltip:Show()
  end)
  swatch:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(Style.Color("borderField"))
    GameTooltip:Hide()
  end)
  return swatch
end

-- The Edit Mode stays active, hidden, while the settings of the game or the quick keybind mode are open.
local function EditModeOpen()
  local manager = EditModeManagerFrame
  return manager and (manager:IsShown() or (manager.IsEditModeActive and manager:IsEditModeActive())) or false
end

-- Lines every gridSpacing from the center of the screen, made once per screen size.
local function DrawGrid()
  local width, height = overlay:GetSize()
  if overlay.gridWidth == width and overlay.gridHeight == height then
    return
  end
  overlay.gridWidth, overlay.gridHeight = width, height
  for _, line in ipairs(overlay.lines) do
    line:Hide()
  end
  local used = 0
  local function Line()
    used = used + 1
    local line = overlay.lines[used]
    if not line then
      line = overlay.grid:CreateTexture(nil, "BACKGROUND", nil, 1)
      overlay.lines[used] = line
    end
    line:ClearAllPoints()
    line:Show()
    return line
  end
  local function Color(step)
    return Style.Color(step == 0 and "gridAxis" or step % majorEvery == 0 and "gridMajor" or "grid")
  end
  local centerX, centerY = width / 2, height / 2
  for step = -math.floor(centerX / gridSpacing), math.floor(centerX / gridSpacing) do
    local line = Line()
    line:SetColorTexture(Color(step))
    line:SetPoint("TOP", overlay, "TOPLEFT", centerX + step * gridSpacing, 0)
    line:SetPoint("BOTTOM", overlay, "BOTTOMLEFT", centerX + step * gridSpacing, 0)
    line:SetWidth(1)
  end
  for step = -math.floor(centerY / gridSpacing), math.floor(centerY / gridSpacing) do
    local line = Line()
    line:SetColorTexture(Color(step))
    line:SetPoint("LEFT", overlay, "BOTTOMLEFT", 0, centerY + step * gridSpacing)
    line:SetPoint("RIGHT", overlay, "BOTTOMRIGHT", 0, centerY + step * gridSpacing)
    line:SetHeight(1)
  end
end

local function StopEntrance()
  for _, group in ipairs(entrance) do
    group:Stop()
  end
  intro:Hide()
end

-- animated: the entrance plays, 1.15 s; the mode answers from its first frame. Back from a combat: shown at once.
local function ShowInterface(animated)
  StopEntrance()
  overlay:Show()
  DrawGrid()
  overlay.grid:SetShown(bar.grid:GetChecked())
  bar.Fit()
  bar:Show()
  if animated then
    intro:Show()
    for _, group in ipairs(entrance) do
      group:Play()
    end
  end
end

local function HideInterface()
  ClosePicker()
  StopEntrance()
  overlay:Hide()
  bar:Hide()
  OptionsPrivate.PlacementPanel.Hide()
  StaticPopup_Hide("WEAKAURAS_PLACEMENT_LEAVE")
end

local function Start(keepChanges)
  OptionsPrivate.StartPlacementPreview(Private, host.Ids())
  active, suspended = true, false
  ShowInterface(not keepChanges)
  Boxes().Show(host, keepChanges)
  events:RegisterEvent("PLAYER_REGEN_DISABLED")
end

local function Stop()
  active, suspended = false, false
  events:UnregisterAllEvents()
  Boxes().Hide()
  OptionsPrivate.StopPlacementPreview()
  HideInterface()
end

local function SaveAndQuit()
  Boxes().Forget()
  Stop()
end

local function Quit()
  if Boxes().HasChanges() then
    StaticPopup_Show("WEAKAURAS_PLACEMENT_LEAVE")
  else
    Stop()
  end
end

StaticPopupDialogs["WEAKAURAS_PLACEMENT_LEAVE"] = {
  text = L["Keep the changes made to the placement of your auras?"],
  button1 = L["Save and quit"],
  button2 = L["Cancel"],
  button3 = L["Discard"],
  OnAccept = SaveAndQuit,
  OnAlt = function()
    Boxes().Revert()
    Stop()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

local function OnEscape()
  if ClosePicker() then
    return
  elseif StaticPopup_Visible("WEAKAURAS_PLACEMENT_LEAVE") then
    StaticPopup_Hide("WEAKAURAS_PLACEMENT_LEAVE")
  elseif not Boxes().Escape() then
    Quit()
  end
end

-- An animation group on region, kept to be played by the entrance.
local function NewEntrance(region)
  local group = region:CreateAnimationGroup()
  group:SetToFinalAlpha(true)
  entrance[#entrance + 1] = group
  return group
end

local function AddMove(group, x, y, duration, delay)
  local move = group:CreateAnimation("Translation")
  move:SetOffset(x, y)
  move:SetDuration(duration)
  move:SetStartDelay(delay)
  move:SetSmoothing("OUT")
end

-- Entrance "Focus": the screen darkens, the emblem of Musca comes into focus inside four brass marks closing on it,
-- the grid then the bar come in, the emblem fades. Each part a group of its own, none left running after 1.15 s.
local function CreateEntrance()
  Style.AddFade(NewEntrance(overlay.shade), 0, 1, 0.30, 0)
  local grid = NewEntrance(overlay.grid)
  Style.AddFade(grid, 0, 0, 0.40, 0)
  Style.AddFade(grid, 0, 1, 0.30, 0.40, "OUT")
  local slide = NewEntrance(bar)
  Style.AddFade(slide, 0, 0, 0.50, 0)
  Style.AddFade(slide, 0, 1, 0.25, 0.50, "OUT")
  AddMove(slide, 0, 40, 0.01, 0)
  AddMove(slide, 0, -40, 0.25, 0.50)

  intro = CreateFrame("Frame", nil, UIParent)
  intro:SetFrameStrata("FULLSCREEN")
  intro:SetAllPoints(UIParent)
  -- Its fade starts after 0.05 s: invisible until then, also after a Stop that left no final alpha.
  intro:SetAlpha(0)
  intro:Hide()
  local fade = NewEntrance(intro)
  Style.AddFade(fade, 0, 1, 0.20, 0.05)
  Style.AddFade(fade, 1, 0, 0.45, 0.70, "IN")
  fade:SetScript("OnFinished", function() intro:Hide() end)
  local emblem = intro:CreateTexture(nil, "ARTWORK")
  emblem:SetTexture(logo)
  emblem:SetSize(112, 112)
  emblem:SetPoint("CENTER")
  local scale = NewEntrance(emblem):CreateAnimation("Scale")
  scale:SetScaleFrom(1.15, 1.15)
  scale:SetScaleTo(1, 1)
  scale:SetDuration(0.35)
  scale:SetStartDelay(0.05)
  scale:SetSmoothing("OUT")
  -- Marks from 120 to 64 pixels of the center, held there until the emblem has faded.
  for _, side in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
    local mark = intro:CreateTexture(nil, "ARTWORK")
    mark:SetColorTexture(Style.Color("primary"))
    mark:SetSize(side[1] == 0 and 1 or 20, side[1] == 0 and 20 or 1)
    mark:SetPoint("CENTER", side[1] * 120, side[2] * 120)
    local close = NewEntrance(mark)
    AddMove(close, -side[1] * 56, -side[2] * 56, 0.35, 0.05)
    Style.AddFade(close, 1, 1, 0.75, 0.40)
  end
end

local function CreateInterface()
  Style = Private.Style
  -- Under the auras: the dark screen and the grid. A click on it leaves the selection.
  overlay = CreateFrame("Frame", nil, UIParent)
  overlay:SetAllPoints(UIParent)
  overlay:SetFrameStrata("BACKGROUND")
  overlay:EnableMouse(true)
  overlay:SetScript("OnMouseDown", function()
    -- Closes every layer: the anchor menu, the link being picked, the selection.
    while Boxes().Escape() do end
  end)
  overlay.shade = overlay:CreateTexture(nil, "BACKGROUND")
  overlay.shade:SetAllPoints()
  overlay.shade:SetColorTexture(Style.Color("veil"))
  overlay.grid = CreateFrame("Frame", nil, overlay)
  overlay.grid:SetAllPoints()
  overlay.lines = {}
  overlay:SetScript("OnSizeChanged", function()
    if overlay:IsShown() then
      DrawGrid()
    end
  end)
  overlay:Hide()

  bar = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  bar:SetFrameStrata("FULLSCREEN")
  bar:SetPoint("TOP", UIParent, "TOP", 0, -16)
  bar:SetHeight(40)
  Style.Fill(bar, "barBackground", "border")
  local rule = bar:CreateTexture(nil, "ARTWORK")
  rule:SetColorTexture(Style.Color("rule"))
  rule:SetHeight(1)
  rule:SetPoint("BOTTOMLEFT", 1, 1)
  rule:SetPoint("BOTTOMRIGHT", -1, 1)
  bar:EnableMouse(true)
  bar:EnableKeyboard(true)
  bar:SetScript("OnKeyDown", function(self, key)
    if InCombatLockdown() then
      return
    end
    self:SetPropagateKeyboardInput(key ~= "ESCAPE")
    if key == "ESCAPE" then
      OnEscape()
    end
  end)

  local emblem = bar:CreateTexture(nil, "ARTWORK")
  emblem:SetTexture(logo)
  emblem:SetSize(20, 20)
  emblem:SetPoint("LEFT", 12, 0)
  local title = Style.NewText(bar, "title", "m")
  title:SetText("Musca Auras")
  title:SetPoint("LEFT", emblem, "RIGHT", 8, 0)
  local subtitle = Style.NewText(bar, "text", "s", "textQuiet")
  subtitle:SetText(L["Placement"])
  subtitle:SetPoint("LEFT", title, "RIGHT", 8, 0)
  bar.grid = Style.NewCheck(bar, L["Grid"], function()
    overlay.grid:SetShown(bar.grid:GetChecked())
  end)
  bar.grid:SetPoint("LEFT", subtitle, "RIGHT", 24, 0)
  bar.snap = Style.NewCheck(bar, L["Snap"], function() end)
  bar.snap:SetPoint("LEFT", bar.grid.label, "RIGHT", 16, 0)
  bar.swatches = {}
  local previous = bar.snap.label
  for _, role in ipairs(Boxes().roles) do
    local swatch = NewRoleSwatch(bar, role)
    swatch:SetPoint("LEFT", previous, "RIGHT", #bar.swatches == 0 and 24 or 12, 0)
    tinsert(bar.swatches, swatch)
    previous = swatch.label
  end
  local revert = Style.NewButton(bar, L["Revert"], "quiet", function()
    Boxes().Revert()
  end)
  revert:SetPoint("LEFT", previous, "RIGHT", 24, 0)
  local quit = Style.NewButton(bar, L["Quit"], "secondary", Quit, 72)
  quit:SetPoint("LEFT", revert, "RIGHT", 8, 0)
  local save = Style.NewButton(bar, L["Save and quit"], "primary", SaveAndQuit, 72)
  save:SetPoint("LEFT", quit, "RIGHT", 8, 0)
  -- Measured at each show: the Fira fonts may not be loaded yet when the bar is made, the widths then too small.
  function bar.Fit()
    for _, button in ipairs({ revert, quit, save }) do
      Style.FitButton(button)
    end
    Style.FitCheck(bar.grid)
    Style.FitCheck(bar.snap)
    local swatchesWidth = 0
    for index, swatch in ipairs(bar.swatches) do
      swatch.Paint()
      swatchesWidth = swatchesWidth + (index == 1 and 24 or 12) + 22 + 6 + swatch.label:GetStringWidth()
    end
    bar:SetWidth(swatchesWidth + 12 + 20 + 8 + title:GetStringWidth() + 8 + subtitle:GetStringWidth() + 24 + 14 + 6
      + bar.grid.label:GetStringWidth() + 16 + 14 + 6 + bar.snap.label:GetStringWidth() + 24 + revert:GetWidth() + 8
      + quit:GetWidth() + 8 + save:GetWidth() + 12)
  end
  bar:Hide()
  CreateEntrance()

  -- The frames above are not protected: combat only suspends the mode, the keyboard of the bar being let go.
  events = CreateFrame("Frame")
  events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" and active then
      active, suspended = false, true
      Boxes().Hide(true)
      OptionsPrivate.StopPlacementPreview()
      HideInterface()
      events:RegisterEvent("PLAYER_REGEN_ENABLED")
      WeakAuras.prettyPrint(L["Placement mode suspended during combat."])
    elseif event == "PLAYER_REGEN_ENABLED" and suspended then
      events:UnregisterEvent("PLAYER_REGEN_ENABLED")
      Start(true)
    end
  end)

  host = {
    strata = "HIGH",
    level = 100,
    backgroundAlpha = Style.colors.boxBackground[4],
    SnapEnabled = function() return bar.snap:GetChecked() end,
    Grid = function()
      if bar.grid:GetChecked() then
        local centerX, centerY = UIParent:GetCenter()
        return gridSpacing, centerX, centerY
      end
    end,
    -- The auras this character can load (in combat only too), and those disabled since the last save to enable them
    -- again: not those of another class or character.
    Ids = function()
      return Boxes().Ids()
    end,
    OnChange = function()
      if active then
        OptionsPrivate.PlacementPanel.Show(Boxes().Selected())
      end
    end,
    OnSelect = function(id)
      if active then
        OptionsPrivate.PlacementPanel.Show(id)
      end
    end,
    -- The Edit Mode of Blizzard opens, in combat too: the mode ends, suspended or not, its changes kept.
    Leave = function()
      if active or suspended then
        SaveAndQuit()
      end
    end,
  }
end

--- /wa closes the mode first, the changes kept.
function OptionsPrivate.LeavePlacementMode()
  if active or suspended then
    SaveAndQuit()
  end
end

---@type fun(Private: Private)
function WeakAuras.TogglePlacementMode(privateTable)
  Private = privateTable
  if active then
    Quit()
    return
  end
  if EditModeOpen() then
    WeakAuras.prettyPrint(L["Close the Edit Mode first."])
    return
  end
  if not overlay then
    CreateInterface()
  end
  Start(false)
end

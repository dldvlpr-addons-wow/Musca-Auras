-- PlacementMode: /wa unlock. Every aura gets a box, loaded or not, except the children of a dynamic group; the panel
-- types in the placement of the selected aura; Escape closes one layer at a time, then asks to keep the changes;
-- Discard puts every change back, grow of a dynamic group included; combat suspends the mode with its changes.
local function Icon(id, load, parent)
  return {
    id = id, uid = id, parent = parent, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = load or {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
    anchorFrameType = "SCREEN", xOffset = 10, yOffset = -5,
  }
end

return function(test)
  local saved = { displays = {
    Free = Icon("Free"),
    Never = Icon("Never", { use_never = true }),
    Dyn = {
      id = "Dyn", uid = "Dyn", regionType = "dynamicgroup", internalVersion = 91, controlledChildren = { "DynKid" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "TOP", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
      grow = "UP", align = "CENTER", space = 2,
    },
    DynKid = Icon("DynKid", nil, "Dyn"),
    Top = {
      id = "Top", uid = "Top", regionType = "group", internalVersion = 91, controlledChildren = { "Mid" },
      load = {}, triggers = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
    Mid = {
      id = "Mid", uid = "Mid", parent = "Top", regionType = "group", internalVersion = 91,
      controlledChildren = { "Low" }, load = {}, triggers = {}, conditions = {},
      actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
    Low = Icon("Low", nil, "Mid"),
  } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  WeakAuras.UpdateThumbnail = function() end

  -- The harness has no font string on a button and no check state: both played here. Frames kept to find them.
  local created = {}
  local realCreateFrame = CreateFrame
  CreateFrame = function(frameType, ...)
    local frame = realCreateFrame(frameType, ...)
    created[#created + 1] = frame
    if frameType == "Button" then
      rawset(frame, "GetFontString", function() return { GetStringWidth = function() return 40 end } end)
    elseif frameType == "CheckButton" then
      rawset(frame, "SetChecked", function(self, checked) rawset(self, "checked", checked) end)
      rawset(frame, "GetChecked", function(self) return rawget(self, "checked") end)
    end
    return frame
  end
  local popups = {}
  StaticPopup_Show = function(name) popups[name] = true end
  StaticPopup_Hide = function(name) popups[name] = nil end
  StaticPopup_Visible = function(name) return popups[name] end

  local previews = 0
  local optionsPrivate
  optionsPrivate = {
    StartPlacementPreview = function(privateTable) optionsPrivate.Private = privateTable; previews = previews + 1 end,
    -- As the real one: nothing to put back once put back.
    StopPlacementPreview = function() previews = math.max(previews - 1, 0) end,
    DynamicGroupSelfPoint = function(data) return data.grow == "DOWN" and "TOP" or "BOTTOM" end,
  }
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/OptionsFrames/")
  for _, file in ipairs({ "PlacementPanel.lua", "PlacementMode.lua" }) do
    local ok, message = test.Loader.RunFile(directory .. file, "WeakAurasOptions", optionsPrivate)
    assert(ok, file .. ": " .. tostring(message))
  end
  local Box = private.GetPlacementBox

  WeakAuras.TogglePlacementMode(private)
  assert(previews == 1, "auras shown as in the options")
  assert(Box("Free") and Box("Dyn"), "boxes for the auras")
  assert(Box("Never"), "box for an aura not loaded")
  assert(not Box("DynKid"), "no box for a child of a dynamic group")
  assert(Box("Free"):GetFrameStrata() == "HIGH", "boxes over the dark screen of the mode")

  local bar
  for _, frame in ipairs(created) do
    if frame:GetScript("OnKeyDown") and frame:GetFrameStrata() == "FULLSCREEN" then
      bar = frame
    end
  end
  assert(bar and bar:IsShown(), "bar of the mode shown")
  local function Escape()
    bar:GetScript("OnKeyDown")(bar, "ESCAPE")
  end

  -- The panel follows the selection: the X typed in moves the aura.
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "LeftButton")
  local editBoxes = {}
  for _, frame in ipairs(created) do
    if frame:GetObjectType() == "EditBox" then
      editBoxes[#editBoxes + 1] = frame
    end
  end
  local xBox, spaceBox = editBoxes[1], editBoxes[5]
  assert(xBox and xBox:GetText() == "10", "X of the selected aura in the panel, got " .. tostring(xBox and xBox:GetText()))
  xBox:GetScript("OnEnterPressed")(xBox)
  assert(not private.PlacementBoxes.HasChanges(), "Enter on the same value changes nothing")
  xBox:SetText("inf")
  xBox:GetScript("OnEnterPressed")(xBox)
  assert(WeakAuras.GetData("Free").xOffset == 10 and xBox:GetText() == "10", "a value not finite refused")
  xBox:SetText("25")
  xBox:GetScript("OnEnterPressed")(xBox)
  assert(WeakAuras.GetData("Free").xOffset == 25, "X typed in moves the aura")
  assert(private.PlacementBoxes.HasChanges(), "the move is kept to revert")

  -- A dynamic group: grow goes to the next type with its self point, space typed in.
  Box("Dyn"):GetScript("OnMouseDown")(Box("Dyn"), "LeftButton")
  local growButton
  for _, frame in ipairs(created) do
    local label = frame:GetParent() and frame:GetParent().label
    if frame:GetObjectType() == "Button" and label and label:GetText() == WeakAuras.L["Grow"] then
      growButton = frame
    end
  end
  assert(growButton, "grow row in the panel")
  growButton:GetScript("OnClick")(growButton)
  local dyn = WeakAuras.GetData("Dyn")
  assert(dyn.grow == "DOWN" and dyn.selfPoint == "TOP", "grow and self point changed, got " .. tostring(dyn.grow))
  growButton:GetScript("OnClick")(growButton)
  assert(dyn.grow == "HORIZONTAL" and spaceBox:GetParent():IsShown(), "space set for a horizontal group too")
  spaceBox:SetText("6")
  spaceBox:GetScript("OnEnterPressed")(spaceBox)
  assert(WeakAuras.GetData("Dyn").space == 6, "space typed in")

  -- Nested groups: the panel lists the groups of the selected aura, from the top one; a click on one selects it.
  -- The hint of a drag and a click inside shows for a group with boxes in it only.
  Box("Low"):GetScript("OnMouseDown")(Box("Low"), "LeftButton")
  local pathButtons = {}
  for _, frame in ipairs(created) do
    local label = frame:GetParent() and frame:GetParent().label
    if frame:GetObjectType() == "Button" and frame:IsShown() and label
      and label:GetText() == WeakAuras.L["Its groups"] then
      pathButtons[#pathButtons + 1] = frame
    end
  end
  assert(#pathButtons == 2 and pathButtons[1].auraId == "Top" and pathButtons[2].auraId == "Mid",
    "groups of the selected aura listed from the top, got " .. #pathButtons)
  local hint = pathButtons[1]:GetParent():GetParent().hint
  assert(not hint:IsShown(), "no hint for an aura")
  pathButtons[2]:GetScript("OnClick")(pathButtons[2])
  assert(private.PlacementBoxes.Selected() == "Mid" and hint:IsShown(), "group picked in the panel, with the hint")
  assert(pathButtons[1]:IsShown() and not pathButtons[2]:IsShown(), "path of the group picked: its own group only")
  private.PlacementBoxes.Select(nil)

  -- Right click: the menu of the aura, when it shows and whether it loads, kept to revert.
  local choices
  local realShowChoices = private.AnchorLinks.ShowChoices
  private.AnchorLinks.ShowChoices = function(list) choices = list end
  local function Pick(text)
    for _, choice in ipairs(choices) do
      if choice.text == WeakAuras.L[text] then
        return choice.onPick()
      end
    end
    error("no choice " .. text)
  end
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "RightButton")
  assert(choices and private.PlacementBoxes.Selected() == "Free", "right click selects and opens the menu")
  Pick("Disable")
  assert(WeakAuras.GetData("Free").load.use_never == true, "Disable sets load Never")
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "RightButton")
  assert(choices[4].text == WeakAuras.L["Enable"], "a disabled aura offers Enable")
  Pick("Show in combat")
  assert(WeakAuras.GetData("Free").load.use_combat == true, "Show in combat sets load In Combat")
  Box("Never"):GetScript("OnMouseDown")(Box("Never"), "RightButton")
  Pick("Enable")
  assert(not WeakAuras.GetData("Never").load.use_never, "Enable clears load Never")
  private.AnchorLinks.ShowChoices = realShowChoices

  -- Escape: the link being picked, then the selection, then the question.
  private.PlacementBoxes.StartLink("Free")
  Escape()
  assert(private.PlacementBoxes.Selected() == "Free", "first Escape cancels the link only")
  Escape()
  assert(private.PlacementBoxes.Selected() == nil, "second Escape leaves the selection")
  Escape()
  assert(popups.WEAKAURAS_PLACEMENT_LEAVE, "third Escape asks to keep the changes")
  Escape()
  assert(not popups.WEAKAURAS_PLACEMENT_LEAVE and Box("Free"), "Escape closes the question, the mode stays")

  -- Discard: every change put back.
  StaticPopupDialogs.WEAKAURAS_PLACEMENT_LEAVE.OnAlt()
  dyn = WeakAuras.GetData("Dyn")
  assert(WeakAuras.GetData("Free").xOffset == 10, "Discard puts the aura back")
  assert(not WeakAuras.GetData("Free").load.use_never and WeakAuras.GetData("Free").load.use_combat == nil
    and WeakAuras.GetData("Never").load.use_never == true, "Discard puts the load fields back")
  assert(dyn.grow == "UP" and dyn.selfPoint == "TOP" and dyn.space == 2, "Discard puts the group back")
  assert(not Box("Free") and not bar:IsShown() and previews == 0, "mode closed")

  -- Combat suspends the mode with its changes, and brings it back after.
  WeakAuras.TogglePlacementMode(private)
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "LeftButton")
  xBox:SetText("30")
  xBox:GetScript("OnEnterPressed")(xBox)
  test.WowApi.inCombat = true
  test.Frames.Fire("PLAYER_REGEN_DISABLED")
  assert(not Box("Free") and not bar:IsShown() and previews == 0, "mode suspended in combat")
  test.WowApi.inCombat = false
  test.Frames.Fire("PLAYER_REGEN_ENABLED")
  assert(Box("Free") and bar:IsShown() and previews == 1, "mode back after the combat")
  assert(private.PlacementBoxes.HasChanges(), "changes kept through the combat")

  -- Save and quit keeps the move, nothing left to revert.
  optionsPrivate.LeavePlacementMode()
  assert(WeakAuras.GetData("Free").xOffset == 30 and not private.PlacementBoxes.HasChanges(), "changes saved")
  assert(not Box("Free") and previews == 0, "mode closed by /wa")

  -- The Edit Mode opened during the combat ends the suspended mode, its changes kept; the combat end starts nothing.
  _G.EditModeManagerFrame = CreateFrame("Frame", nil, UIParent)
  EditModeManagerFrame:Hide()
  WeakAuras.TogglePlacementMode(private)
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "LeftButton")
  xBox:SetText("35")
  xBox:GetScript("OnEnterPressed")(xBox)
  test.WowApi.inCombat = true
  test.Frames.Fire("PLAYER_REGEN_DISABLED")
  EditModeManagerFrame:Show()
  EventRegistry:TriggerEvent("EditMode.Enter")
  assert(Box("Free") and Box("Free"):GetFrameStrata() == "MEDIUM", "boxes of the Edit Mode")
  test.WowApi.inCombat = false
  test.Frames.Fire("PLAYER_REGEN_ENABLED")
  assert(not bar:IsShown() and previews == 0, "mode not back over the Edit Mode")
  assert(WeakAuras.GetData("Free").xOffset == 35, "changes kept")
  -- Disabled from the menu in the Edit Mode: unloaded, its box stays to enable it again.
  private.AnchorLinks.ShowChoices = function(list) choices = list end
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "RightButton")
  Pick("Disable")
  assert(Box("Free"), "box of a disabled aura kept in the Edit Mode")
  Box("Free"):GetScript("OnMouseDown")(Box("Free"), "RightButton")
  Pick("Enable")
  assert(not WeakAuras.GetData("Free").load.use_never and Box("Free"), "enabled again from its box")
  private.AnchorLinks.ShowChoices = realShowChoices
  EventRegistry:TriggerEvent("EditMode.Exit")

  -- The Edit Mode hidden by the settings of the game stays active: /wa unlock refused.
  EditModeManagerFrame:Hide()
  EditModeManagerFrame.IsEditModeActive = function() return true end
  WeakAuras.TogglePlacementMode(private)
  assert(not bar:IsShown() and not Box("Free"), "refused while the Edit Mode is active")
  EditModeManagerFrame.IsEditModeActive = function() return false end
  CreateFrame = realCreateFrame
end

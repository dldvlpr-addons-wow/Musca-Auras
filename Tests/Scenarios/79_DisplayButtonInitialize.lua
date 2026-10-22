-- DisplayButtonInitialize: freezes the behaviour of WeakAurasDisplayButton:Initialize and of the callbacks it installs
-- (menu entries, grouping, delete, duplicate, rename, drag). AceGUI is faked, OptionsPrivate is a recorder: every
-- call made on it is logged as "name:firstArgument".
return function(test)
  local function Aura(id, parent)
    return {
      id = id, uid = id .. "Uid", regionType = "icon", internalVersion = 91, parent = parent,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
        auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
    }
  end
  local saved = { displays = { Solo = Aura("Solo"), First = Aura("First", "Box"), Second = Aura("Second", "Box"),
    Box = Aura("Box") } }
  saved.displays.Box.regionType = "group"
  saved.displays.Box.controlledChildren = { "First", "Second" }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  -- Fake AceGUI: the harness has none.
  local widgetRegistration
  local aceGui = LibStub:NewLibrary("AceGUI-3.0", 1000)
  aceGui.GetWidgetVersion = function() return nil end
  aceGui.GetNextWidgetNum = function() return 1 end
  aceGui.RegisterWidgetType = function(_, name, constructor) widgetRegistration = { name, constructor } end
  aceGui.RegisterAsWidget = function(_, widget)
    widget.frame.obj = widget
    widget.Fire = function() end
    return widget
  end

  private.regionOptions = { icon = { displayName = "Icon" }, text = { displayName = "Text" }, group = {}, dynamicgroup = {} }
  for _, name in ipairs({ "FillOptions", "UpdateGroupOrders", "ClearAndUpdateOptions", "PickDisplay" }) do WeakAuras[name] = WeakAuras[name] or function() end end
  GameTooltip = setmetatable({}, { __index = function() return function() end end })
  WeakAuras.spellCache = { GetIcon = function() end }
  local dropDown = LibStub:NewLibrary("LibUIDropDownMenu-4.0", 1)
  dropDown.EasyMenu = function() end
  dropDown.CloseDropDownMenus = function() end

  -- OptionsPrivate recorder: unknown members are recording functions, so any callback can run.
  local calls = {}
  local function Take()
    local text = table.concat(calls, ",")
    calls = {}
    return text
  end
  local buttons = {}
  local optionsPrivate = setmetatable({
    IsDisplayPicked = function() return false end,
    IsPickedMultiple = function() return false end,
    GetDisplayButton = function(id) return buttons[id] end,
    DuplicateAura = function(data, parentId, _, index)
      calls[#calls + 1] = "duplicate:" .. data.id .. ">" .. tostring(parentId) .. "@" .. tostring(index)
      local copyId = data.id .. "Copy"
      buttons[copyId] = { callbacks = { UpdateExpandButton = function() end }, UpdateParentWarning = function() end }
      return { id = copyId, uid = copyId .. "Uid" }
    end,
    ConfirmDelete = function(toDelete, parents)
      local ids, parentIds = {}, {}
      for _, data in ipairs(toDelete) do ids[#ids + 1] = data.id end
      for id in pairs(parents) do parentIds[#parentIds + 1] = id end
      table.sort(parentIds)
      calls[#calls + 1] = "delete:" .. table.concat(ids, "+") .. "/" .. table.concat(parentIds, "+")
    end,
  }, { __index = function(_, name)
    return function(first)
      calls[#calls + 1] = name .. ":" .. tostring(type(first) == "table" and first.id or first)
    end
  end })
  optionsPrivate.Private = private
  local ok, message = test.Loader.RunFile(directory .. "AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua",
    "WeakAurasOptions", optionsPrivate)
  assert(ok, tostring(message))
  assert(widgetRegistration and widgetRegistration[1] == "WeakAurasDisplayButton", "widget registered")

  local function Build(id)
    local widget = widgetRegistration[2]()
    widget.data = WeakAuras.GetData(id)
    widget.frame.id = id
    buttons[id] = widget
    widget:Initialize()
    return widget
  end

  local function Texts(menu)
    local list = {}
    for _, entry in ipairs(menu) do list[#list + 1] = entry.text end
    return list
  end
  local function Has(list, text)
    for _, entry in ipairs(list) do if entry == text then return true end end
    return false
  end

  -- Aura: Rename, Copy, Convert, Duplicate, Delete, Close; no group-only entry.
  local solo = Build("Solo")
  local texts = Texts(solo.menu)
  assert(Has(texts, "Rename") and Has(texts, "Duplicate") and Has(texts, "Delete") and Has(texts, "Close"),
    "aura menu entries: " .. table.concat(texts, "|"))
  assert(Has(texts, "Convert to...") and Has(texts, "Copy settings..."), "aura menu convert and copy")
  assert(not Has(texts, "Delete children and group"), "aura menu has no group delete")
  assert(solo.menu[1].func == solo.callbacks.OnRenameClick, "rename entry wired")
  assert(#solo.menu[2].menuList == 10, "copy submenu size " .. #solo.menu[2].menuList)
  local convert
  for _, entry in ipairs(solo.menu) do
    if entry.text == "Convert to..." then convert = entry end
    if entry.text == "Duplicate" then assert(entry.func == solo.callbacks.OnDuplicateClick, "duplicate wired") end
    if entry.text == "Delete" then assert(entry.func == solo.callbacks.OnDeleteClick, "delete wired") end
  end
  assert(#convert.menuList > 0, "convert submenu filled")
  for _, entry in ipairs(convert.menuList) do
    assert(entry.text ~= "Icon", "convert menu leaves out the own region type")
  end
  calls = {}
  convert.menuList[1].func()
  assert(Take():find("^ConvertDisplay:Solo"), "convert entry converts the aura")
  assert(solo.frame:GetScript("OnClick") == solo.callbacks.OnClickNormal, "click script wired")
  assert(solo.frame:GetScript("OnDragStart") == solo.callbacks.OnDragStart, "drag start wired")
  assert(solo.frame:GetScript("OnDragStop") == solo.callbacks.OnDragStop, "drag stop wired")
  assert(solo.frame:GetScript("OnKeyDown") == solo.callbacks.OnKeyDown, "key script wired")
  assert(solo.group:GetScript("OnClick") == solo.callbacks.OnGroupClick, "group button wired")
  assert(solo.ungroup:GetScript("OnClick") == solo.callbacks.OnUngroupClick, "ungroup button wired")
  assert(solo.upgroup:GetScript("OnClick") == solo.callbacks.OnUpGroupClick, "up button wired")
  assert(solo.downgroup:GetScript("OnClick") == solo.callbacks.OnDownGroupClick, "down button wired")
  assert(solo.view:GetScript("OnClick") == solo.callbacks.OnViewClick, "view button wired")
  assert(not solo.frame:IsShown(), "frame hidden after Initialize")

  -- Group: group delete entry, no plain delete, no convert, expand button visible.
  local box = Build("Box")
  local groupTexts = Texts(box.menu)
  assert(Has(groupTexts, "Delete children and group") and not Has(groupTexts, "Delete")
    and not Has(groupTexts, "Convert to..."), "group menu entries: " .. table.concat(groupTexts, "|"))
  assert(box.expand:IsShown(), "group shows the expand button")
  assert(not solo.expand:IsShown(), "aura hides the expand button")

  local first, second = Build("First"), Build("Second")

  -- Delete.
  calls = {}
  solo.callbacks.OnDeleteClick()
  assert(Take() == "delete:Solo/", "delete aura")
  first.callbacks.OnDeleteClick()
  assert(Take() == "delete:First/Box", "delete child lists its parent")
  box.callbacks.OnDeleteAllClick()
  assert(Take() == "delete:First+Second+Box/", "delete group and children")

  -- Grouping: the selected aura joins the group, the group button starts and the self click stops grouping.
  box.grouping = { "Solo" }
  box.callbacks.OnClickGrouping()
  Take()
  assert(WeakAuras.GetData("Solo").parent == "Box", "grouped aura has the parent")
  assert(box.data.controlledChildren[3] == "Solo", "group controls the aura")
  box.callbacks.OnGroupClick()
  assert(Take() == "StartGrouping:Box", "group click starts grouping")
  box.callbacks.OnClickGroupingSelf()
  assert(Take():find("^StopGrouping:nil"), "grouping self stops grouping")

  -- Rename.
  second.frame:Show()
  second.callbacks.OnRenameClick()
  assert(second.renamebox:IsShown() and not second.title:IsShown(), "rename shows the edit box")
  second.frame:Show()
  second.callbacks.OnRenameClick()
  assert(not second.renamebox:IsShown() and second.title:IsShown(), "rename click again restores the title")
  local renamed
  local realRename = WeakAuras.Rename
  WeakAuras.Rename = function(data, newid) renamed = data.id .. ">" .. newid end
  second.callbacks.OnRenameAction("Second")
  assert(renamed == nil, "same name renames nothing")
  second.callbacks.OnRenameAction("Third")
  assert(renamed == "Second>Third", "rename action")
  WeakAuras.Rename = realRename

  -- Move up and down inside the group.
  local function Order() return table.concat(WeakAuras.GetData("Box").controlledChildren, ",") end
  assert(Order() == "First,Second,Solo", "group order before move: " .. Order())
  second.callbacks.OnUpGroupClick()
  assert(Order() == "Second,First,Solo", "move up: " .. Order())
  assert(not pcall(second.callbacks.OnUpGroupClick), "the first child cannot move up")
  second.callbacks.OnDownGroupClick()
  assert(Order() == "First,Second,Solo", "move down: " .. Order())
  assert(not pcall(buttons.Solo.callbacks.OnDownGroupClick), "the last child cannot move down")

  -- Drag.
  calls = {}
  first.callbacks.OnDragStart()
  assert(Take():find("StartDrag:First"), "drag start")
  first.callbacks.OnKeyDown(nil, "ESCAPE")
  assert(Take() == "DragReset:nil", "escape resets drag")

  -- Duplicate of a plain aura.
  calls = {}
  first.callbacks.OnDuplicateClick()
  local duplicated = Take()
  assert(duplicated:find("^duplicate:First>nil@nil,"), "duplicate aura: " .. duplicated)
  assert(duplicated:find("PickAndEditDisplay:FirstCopy", 1, true), "duplicate picks the copy: " .. duplicated)

  -- Duplicate of a group: the skeleton first, then each child under the new group, in order.
  calls = {}
  box.callbacks.OnDuplicateClick()
  duplicated = Take()
  assert(duplicated:find("^duplicate:Box>nil@nil,duplicate:First>BoxCopy@1,duplicate:Second>BoxCopy@2,"),
    "duplicate group: " .. duplicated)
  assert(duplicated:find("PickAndEditDisplay:BoxCopy", 1, true), "duplicate group picks the copy: " .. duplicated)
end

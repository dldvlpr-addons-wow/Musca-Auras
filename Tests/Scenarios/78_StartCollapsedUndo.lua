-- "Start Collapsed" on an option group: the undo and the redo set the collapsed state on screen back, not only the
-- saved value. Like in game, OptionsPrivate.Private is set AFTER AuthorOptions.lua is executed.
return function(test)
  local saved = {
    displays = {
      Shout = {
        id = "Shout", uid = "Shout", regionType = "icon", internalVersion = 91, authorMode = true,
        triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
          useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
          activeTriggerMode = -10 },
        load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
        animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
        subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
        authorOptions = {
          { type = "group", key = "group", name = "Group", groupType = "simple", useCollapse = true, collapse = false,
            width = 1, subOptions = {} },
        },
        config = {},
      },
    },
  }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")

  local collapsed = {}
  AceGUIWidgetLSMlists = AceGUIWidgetLSMlists or { border = {}, background = {} }
  local optionsPrivate = {
    IsCollapsed = function() return false end,
    SetCollapsed = function(id, namespace, path, value)
      collapsed[#collapsed + 1] = id .. ":" .. namespace .. ":" .. table.concat(path, ".") .. "=" .. tostring(value)
    end,
    ResetCollapsed = function() end,
  }
  local ok, message = test.Loader.RunFile(directory .. "AuthorOptions.lua", "WeakAurasOptions", optionsPrivate)
  assert(ok, "AuthorOptions.lua: " .. tostring(message))
  optionsPrivate.Private = private

  local shout = WeakAuras.GetData("Shout")
  local args = optionsPrivate.GetAuthorOptions(shout).args
  local option
  for key, value in pairs(args) do
    if key:find("collapseDefault$") then option = value end
  end
  assert(option, "no Start Collapsed option")

  local TimeMachine = private.TimeMachine
  option.set(nil, true)
  assert(shout.authorOptions[1].collapse == true, "value set")
  assert(table.concat(collapsed, ",") == "Shout:config:1=true", "collapsed on set: " .. table.concat(collapsed, ","))

  collapsed = {}
  TimeMachine:StepBackward()
  assert(shout.authorOptions[1].collapse == false, "value undone")
  assert(table.concat(collapsed, ",") == "Shout:config:1=false", "expanded on undo: " .. table.concat(collapsed, ","))

  collapsed = {}
  TimeMachine:StepForward()
  assert(shout.authorOptions[1].collapse == true, "value redone")
  assert(table.concat(collapsed, ",") == "Shout:config:1=true", "collapsed on redo: " .. table.concat(collapsed, ","))

  -- A second options session registers nothing twice.
  option.set(nil, false)
  assert(shout.authorOptions[1].collapse == false, "second set")
end

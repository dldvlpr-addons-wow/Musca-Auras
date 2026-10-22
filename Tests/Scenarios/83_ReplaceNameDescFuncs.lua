-- ReplaceNameDescFuncs: freezes what the options of a multi-selection show for names and descriptions
-- (OptionsPrivate.commonOptions.replaceNameDescFuncs): the plain name when all children agree, the blue name and
-- the per-child description when their values differ, for every option type the description knows about.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local directory = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/")
  local L = WeakAuras.L

  local function Same(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end

  local optionsPrivate = {}
  local ok, message = test.Loader.RunFile(directory .. "CommonOptions.lua", "WeakAurasOptions", optionsPrivate)
  assert(ok, tostring(message))
  local replaceNameDescFuncs = optionsPrivate.commonOptions.replaceNameDescFuncs
  assert(type(replaceNameDescFuncs) == "function", "replaceNameDescFuncs export")

  -- Children are plain tables { id, regionType, options }, walked in order.
  optionsPrivate.Private = {
    regionOptions = { icon = true },
    TraverseLeafs = function(data)
      local index = 0
      return function()
        index = index + 1
        return data.children[index]
      end
    end,
  }
  optionsPrivate.EnsureOptions = function(child) return child.options end

  local function Child(id, regionType, args)
    return { id = id, regionType = regionType, options = { args = args } }
  end
  -- Builds the multi-selection options (the table that gets replaced) for the given template option, runs the
  -- replacement and returns the replaced option.
  local function Replace(key, template, firstArgs, secondArgs, firstRegionType, secondRegionType)
    optionsPrivate.commonOptionsCache:Clear()
    local data = { children = { Child("A", firstRegionType or "icon", firstArgs), Child("B", secondRegionType or "icon", secondArgs) } }
    local intable = { args = { [key] = template } }
    replaceNameDescFuncs(intable, data, "region")
    return intable.args[key]
  end
  local function Info(key) return { key } end

  -- toggle with a plain name: Enabled / Disabled per child, blue name when they differ
  local option = Replace("toggle", { type = "toggle", name = "Toggle" },
    { toggle = { type = "toggle", name = "Toggle", get = function() return true end } },
    { toggle = { type = "toggle", name = "Toggle", get = function() return false end } })
  Same(option.name(Info("toggle")), "|cFF4080FFToggle|r", "toggle name when values differ")
  Same(option.desc(Info("toggle")), "|cFFE0E000A: |r|cFF00FF00" .. L["Enabled"] .. "|r\n|cFFE0E000B: |r|cFFFF0000" .. L["Disabled"] .. "|r", "toggle desc")

  -- toggle with a function name (tri-state): the name or Ignored
  option = Replace("tristate", { type = "toggle", name = "Tri" },
    { tristate = { type = "toggle", name = function() return "Tri A" end, get = function() return true end } },
    { tristate = { type = "toggle", name = function() return "Tri B" end, get = function() return false end } })
  Same(option.name(Info("tristate")), "|cFF4080FFTri A / Tri B|r", "tristate combined name")
  Same(option.desc(Info("tristate")), "|cFFE0E000A: |rTri A\n|cFFE0E000B: |r" .. L["Ignored"], "tristate desc")

  -- same values: plain name and the common description
  option = Replace("same", { type = "toggle", name = "Same" },
    { same = { type = "toggle", name = "Same", desc = "Common", get = function() return true end } },
    { same = { type = "toggle", name = "Same", desc = "Common", get = function() return true end } })
  Same(option.name(Info("same")), "Same", "name when values agree")
  Same(option.desc(Info("same")), "Common", "desc when values agree")

  -- same values, different descriptions
  option = Replace("otherdesc", { type = "toggle", name = "Other" },
    { otherdesc = { type = "toggle", name = "Other", desc = "One", get = function() return true end } },
    { otherdesc = { type = "toggle", name = "Other", desc = "Two", get = function() return true end } })
  Same(option.desc(Info("otherdesc")), L["Not all children have the same value for this option"], "desc differs")

  -- description type options join their names with a blank line, others with a slash
  option = Replace("info", { type = "description", name = "Info" },
    { info = { type = "description", name = function() return "First" end, get = function() return 1 end } },
    { info = { type = "description", name = function() return "Second" end, get = function() return 1 end } })
  Same(option.name(Info("info")), "First\n\nSecond", "description names joined")

  -- color
  option = Replace("color", { type = "color", name = "Color" },
    { color = { type = "color", name = "Color", get = function() return 1, 0, 0 end } },
    { color = { type = "color", name = "Color", get = function() return 0, 1 end } })
  Same(option.desc(Info("color")), "|cFFff2323A|r\n|cFF23ffffB|r", "color desc, missing components default to 1")

  -- select with a values table (strings and pairs of strings) and with a font control
  local selectValues = { one = "First", two = { "Left", "Right" } }
  option = Replace("select", { type = "select", name = "Select", values = selectValues },
    { select = { type = "select", name = "Select", get = function() return "one" end } },
    { select = { type = "select", name = "Select", get = function() return "two" end } })
  Same(option.desc(Info("select")), "|cFFE0E000A: |rFirst\n|cFFE0E000B: |rLeft/Right", "select desc")
  option = Replace("none", { type = "select", name = "None", values = function() return selectValues end },
    { none = { type = "select", name = "None", get = function() return "one" end } },
    { none = { type = "select", name = "None", get = function() return nil end } })
  Same(option.desc(Info("none")), "|cFFE0E000A: |rFirst\n|cFFE0E000B: |r" .. L["None"], "select desc, nil key and function values")
  option = Replace("font", { type = "select", name = "Font", values = { f = "F" }, dialogControl = "LSM30_Font" },
    { font = { type = "select", name = "Font", get = function() return "f1" end } },
    { font = { type = "select", name = "Font", get = function() return "f2" end } })
  Same(option.desc(Info("font")), "|cFFE0E000A: |rf1\n|cFFE0E000B: |rf2", "font select desc")

  -- multiselect: the selected values of each child, the keys being merged over the children
  option = Replace("multi", { type = "multiselect", name = "Multi" },
    { multi = { type = "multiselect", name = "Multi", values = { a = "Alpha" }, get = function(_, k) return k == "a" end } },
    { multi = { type = "multiselect", name = "Multi", values = function() return { a = "Alpha" } end, get = function() return false end } })
  Same(option.desc(Info("multi")), "|cFFE0E000A: |rAlpha\n|cFFE0E000B: |r", "multiselect desc")
  Same(option.name(Info("multi")), "|cFF4080FFMulti|r", "multiselect name when values differ")

  -- other types: numbers rounded, strings cut at a null byte and at 50 characters, nil shown as None
  option = Replace("number", { type = "range", name = "Number" },
    { number = { type = "range", name = "Number", get = function() return 1.23456 end } },
    { number = { type = "range", name = "Number", get = function() return nil end } })
  Same(option.desc(Info("number")), "|cFFE0E000A: |r1.23\n|cFFE0E000B: |r" .. L["None"], "number desc")
  option = Replace("text", { type = "input", name = "Text" },
    { text = { type = "input", name = "Text", get = function() return "short\0hidden" end } },
    { text = { type = "input", name = "Text", get = function() return string.rep("x", 60) end } })
  Same(option.desc(Info("text")), "|cFFE0E000A: |rshort\n|cFFE0E000B: |r" .. string.rep("x", 50) .. "...", "text desc")

  -- options prefixed by a region type only compare the children of that type
  option = Replace("icon.width", { type = "range", name = "Width" },
    { ["icon.width"] = { type = "range", name = "Width", get = function() return 1 end } },
    { ["icon.width"] = { type = "range", name = "Width", get = function() return 2 end } }, "icon", "text")
  Same(option.name(Info("icon.width")), "Width", "prefixed option ignores the other region type")

  -- a hidden child option gives no value to the description
  option = Replace("hidden", { type = "toggle", name = "Hidden" },
    { hidden = { type = "toggle", name = "Hidden", get = function() return true end } },
    { hidden = { type = "toggle", name = "Hidden", hidden = true, get = function() return false end } })
  Same(option.desc(Info("hidden")), "|cFFE0E000A: |r|cFF00FF00" .. L["Enabled"] .. "|r", "hidden child skipped")

  -- nested groups are walked, and the "values" tables are left alone
  local group = { type = "group", args = { inner = { type = "toggle", name = "Inner" } }, values = { name = "kept" } }
  optionsPrivate.commonOptionsCache:Clear()
  replaceNameDescFuncs({ args = { group = group } }, { children = {} }, "region")
  Same(type(group.args.inner.name), "function", "nested name replaced")
  Same(group.values.name, "kept", "values table untouched")
end

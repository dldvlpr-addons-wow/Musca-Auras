-- UpdateFontCategory: the "Fonts & Text Style" update category takes the font fields of the aura and of the
-- entries of subRegions, the rest of subRegions stays in display.
-- The diff functions are locals of WeakAurasOptions/OptionsFrames/Update.lua: their block (from "local deleted"
-- to recurseUpdate, plus GetCategories) is cut from the source and run against the loaded update_categories.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/OptionsFrames/Update.lua")
  local file = assert(io.open(path, "rb"))
  local source = file:read("*a"):gsub("\r\n", "\n")
  file:close()

  local diffBlock = assert(source:match("\n(local deleted = {}.-)\nlocal function recurseUpdate"), "diff block")
  local categoriesBlock = assert(source:match("\n(local function GetCategories.-\nend)\n"), "GetCategories")
  local chunk = assert(loadstring("local OptionsPrivate = ...\n" .. diffBlock .. "\n" .. categoriesBlock
    .. "\nreturn GetCategories, FilterDiff, deleted", "Update.lua diff"))
  local GetCategories, FilterDiff, deleted = chunk({ Private = private })

  local function Diff()
    return {
      font = "B",
      xOffset = 3,
      subRegions = {
        [1] = { text_font = "A", text_color = { 1, 0, 0, 1 } },
        [2] = { text_fontSize = 20 },
        [3] = { type = "subglow", text_font = "C" },
        [4] = deleted,
      },
    }
  end

  local categories = GetCategories(Diff(), true)
  assert(categories.font and categories.display and categories.anchor, "categories of the diff")

  local displayOnly = Diff()
  FilterDiff(displayOnly, { display = true }, true)
  assert(displayOnly.font == nil and displayOnly.xOffset == nil, "display only: root font and anchor fields dropped")
  local entries = displayOnly.subRegions
  assert(entries[1].text_font == nil and entries[1].text_color, "display only: entry 1 keeps its color only")
  assert(entries[2] == nil, "display only: font-only entry dropped")
  assert(entries[3] and entries[4] == deleted, "display only: added and removed entries kept")

  local fontOnly = Diff()
  FilterDiff(fontOnly, { font = true }, true)
  assert(fontOnly.font == "B", "font only: root font kept")
  entries = fontOnly.subRegions
  assert(entries[1].text_font == "A" and entries[1].text_color == nil, "font only: entry 1 keeps its font only")
  assert(entries[2].text_fontSize == 20, "font only: font size kept")
  assert(entries[3] == nil and entries[4] == nil, "font only: added and removed entries dropped")

  local fontChangeOnly = { subRegions = { [1] = { text_font = "A" } } }
  FilterDiff(fontChangeOnly, { display = true }, true)
  assert(fontChangeOnly.subRegions == nil, "empty subRegions diff dropped")

  local removedSubRegions = { subRegions = deleted }
  FilterDiff(removedSubRegions, { display = true }, true)
  assert(removedSubRegions.subRegions == deleted, "removed subRegions stays display")
end

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local blocks = private.ForeverTutorialBlocks
  assert(type(blocks) == "table" and #blocks > 0, "the in-game tutorial exposes no blocks")

  local gameTitles, imports = {}, {}
  for _, block in ipairs(blocks) do
    if block.title or block.subtitle then
      gameTitles[#gameTitles + 1] = block.title or block.subtitle
    elseif block.import then
      imports[#imports + 1] = block.import
    end
  end

  local directory = test.tocPath:gsub("\\", "/"):match("^(.*)/[^/]*/[^/]*$") or "."
  local file = assert(io.open(directory .. "/TUTORIAL.md", "rb"), "TUTORIAL.md not found")
  local markdown = file:read("*a")
  file:close()

  local markdownTitles, inFence = {}, false
  for line in (markdown .. "\n"):gmatch("(.-)\r?\n") do
    if line:match("^```") then
      inFence = not inFence
    elseif not inFence then
      local title = line:match("^###? (.+)$")
      if title then
        markdownTitles[#markdownTitles + 1] = title
      end
    end
  end

  assert(#gameTitles == #markdownTitles,
    ("tutorial steps differ: %d in game, %d in TUTORIAL.md"):format(#gameTitles, #markdownTitles))
  for index, title in ipairs(gameTitles) do
    assert(title == markdownTitles[index],
      ("tutorial step %d differs: in game %q, TUTORIAL.md %q"):format(index, title, markdownTitles[index]))
  end

  assert(#imports > 0, "the in-game tutorial has no import string")
  for index, import in ipairs(imports) do
    assert(markdown:find(import, 1, true), "import string " .. index .. " of the tutorial is missing from TUTORIAL.md")
  end
end

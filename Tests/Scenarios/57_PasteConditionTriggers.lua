-- PasteConditionTriggers: a pasted condition keeps its trigger numbers, a number past the triggers of the target
-- aura is cleared, in the sub-checks too.
-- ClearMissingTriggers is a local of WeakAurasOptions/ConditionOptions.lua: its source is cut and run alone.
return function(test)
  local path = test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/ConditionOptions.lua")
  local file = assert(io.open(path, "rb"))
  local source = file:read("*a"):gsub("\r\n", "\n")
  file:close()

  local block = assert(source:match("\n(local function ClearMissingTriggers.-\nend)\n"), "ClearMissingTriggers")
  local ClearMissingTriggers = assert(loadstring(block .. "\nreturn ClearMissingTriggers", "ClearMissingTriggers"))()

  local check = {
    trigger = -2,
    checks = {
      { trigger = 1 },
      { trigger = 3 },
      { trigger = -1 },
      { trigger = -2, checks = { { trigger = 2 }, { trigger = 4 } } },
    },
  }
  ClearMissingTriggers(check, 2)
  assert(check.trigger == -2, "combination kept")
  assert(check.checks[1].trigger == 1, "existing trigger kept")
  assert(check.checks[2].trigger == nil, "missing trigger cleared")
  assert(check.checks[3].trigger == -1, "global condition kept")
  assert(check.checks[4].checks[1].trigger == 2 and check.checks[4].checks[2].trigger == nil, "nested sub-checks")

  local single = { trigger = 3 }
  ClearMissingTriggers(single, 3)
  assert(single.trigger == 3, "last trigger kept")
end

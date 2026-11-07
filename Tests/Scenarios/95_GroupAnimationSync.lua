-- Two siblings of a group with the same Main animation and duration run in step: the second one starts
-- at the progress of the first instead of 0 (Animations.lua, sibling sync through the parent's controlledChildren).
local function Child(id)
  return {
    id = id, uid = id, parent = "Group", regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL", useName = true,
      auranames = { "Battle Shout" }, matchesShowOn = "showOnActive" }, untrigger = {} }, activeTriggerMode = -10 },
    load = {}, actions = { start = {}, finish = {}, init = {} }, conditions = {},
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local saved = { displays = {
    Group = { id = "Group", uid = "Group", regionType = "group", internalVersion = 91, controlledChildren = { "First", "Second" },
      triggers = { { trigger = {}, untrigger = {} } }, load = {}, actions = { start = {}, finish = {}, init = {} },
      conditions = {}, animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = {}, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN" },
    First = Child("First"),
    Second = Child("Second"),
  } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(1)

  local animations
  for index = 1, 60 do
    local name, value = debug.getupvalue(private.Animate, index)
    if name == "animations" then animations = value break end
    if not name then break end
  end
  assert(animations, "animations table not found")

  local main = { type = "custom", duration_type = "seconds", duration = "2", use_alpha = true, alpha = 0, alphaType = "alphaPulse" }
  local first, second = WeakAuras.GetRegion("First"), WeakAuras.GetRegion("Second")
  first:Show() second:Show()
  private.Animate("display", "First", "main", main, first, false, nil, true)
  test.Environment.Advance(0.5)
  local progress = animations[tostring(first)] and animations[tostring(first)].progress
  assert(progress and progress > 0, "First main animation did not advance: " .. tostring(progress))
  private.Animate("display", "Second", "main", main, second, false, nil, true)
  local secondProgress = animations[tostring(second)] and animations[tostring(second)].progress
  assert(secondProgress == animations[tostring(first)].progress,
    "Second not synced: " .. tostring(secondProgress) .. " vs " .. tostring(animations[tostring(first)].progress))

  -- Loop restarts keep both siblings in step and the animation keeps looping (no resync to a finished sibling).
  local previous, looped = animations[tostring(first)].progress, false
  for _ = 1, 60 do
    test.Environment.Advance(0.1)
    local firstProgress = animations[tostring(first)].progress
    assert(animations[tostring(second)].progress == firstProgress,
      "Siblings out of step: " .. tostring(animations[tostring(second)].progress) .. " vs " .. tostring(firstProgress))
    if firstProgress < previous then looped = true end
    previous = firstProgress
  end
  assert(looped, "Main animation never looped")
end

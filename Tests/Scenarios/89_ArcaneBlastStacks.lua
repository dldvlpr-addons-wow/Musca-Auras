-- Mage pack: the Arcane Blast segments count the player's casts. Each Arcane Blast adds a stack up to 4 and restarts
-- the 15 s, other spells leave them, and a cast after the 15 s starts again at one.
return function(test)
  local pack = dofile("Tests/Packs/Mage/PackMage.lua")
  local displays, segments = {}, {}
  for _, data in ipairs(pack.c) do
    local trigger = data.triggers[1].trigger
    if trigger.type == "custom" and data.id:find("Arcane Blast %d$") then
      local index = tonumber(data.id:match("(%d)$"))
      segments[index] = data.id
      displays[data.id] = {
        id = data.id, uid = data.uid, regionType = "icon", internalVersion = data.internalVersion,
        triggers = { { trigger = trigger, untrigger = {} }, activeTriggerMode = -10 },
        load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
        animation = data.animation, subRegions = {}, width = 20, height = 6, anchorPoint = "CENTER",
        selfPoint = "CENTER", anchorFrameType = "SCREEN",
      }
    end
  end
  assert(#segments == 4, "Arcane Blast segments: " .. #segments)
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = displays })
  test.Environment.Advance(2)

  local function Cast(spellID)
    WeakAuras.ScanUnitEvents("UNIT_SPELLCAST_SUCCEEDED", "player", "Cast-" .. spellID, spellID)
    test.Environment.Advance(0.1)
  end
  local function Shown()
    local shown = 0
    for index, id in ipairs(segments) do
      local state = WeakAuras.GetTriggerStateForTrigger(id, 1)[""]
      if state and state.show then
        assert(index == shown + 1, "segment " .. index .. " shown before segment " .. (shown + 1))
        shown = index
      end
    end
    return shown
  end

  assert(Shown() == 0, "segments shown before any cast")
  Cast(400574)
  assert(Shown() == 1, "one Arcane Blast: " .. Shown())
  for _ = 1, 4 do Cast(1239700) end
  assert(Shown() == 4, "five Arcane Blasts, capped at 4: " .. Shown())
  Cast(116)
  Cast(10211)
  assert(Shown() == 4, "Frostbolt or Arcane Missiles changed the stacks: " .. Shown())
  test.Environment.Advance(15.5)
  assert(Shown() == 0, "stacks still shown after 15 s: " .. Shown())
  Cast(400574)
  Cast(400574)
  test.Environment.Advance(14)
  Cast(400574)
  assert(Shown() == 3, "a cast within 15 s did not stack: " .. Shown())
  test.Environment.Advance(15.5)
  assert(Shown() == 0, "stacks still shown after 15 s: " .. Shown())
  Cast(400574)
  assert(Shown() == 1, "a cast after 15 s did not start again at one: " .. Shown())
end

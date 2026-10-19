local function Icon(id, spell)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { spell }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
    displayIcon = 136000, desc = spell, texture = "Blizzard",
    subRegions = { { type = "subtext", text_font = "Friz Quadrata TT", text_fontSize = tonumber(spell) } },
  }
end

-- Find and replace: only the values equal to the searched text under a key of the chosen kind change, not the
-- settings of that kind (text_fontSize), a number stays a number, a value changed since the preview is left out, and
-- the whole replacement is one step that Undo reverts.
return function(test)
  local saved = { displays = { Shout = Icon("Shout", "6673"), Shield = Icon("Shield", "6673"), Other = Icon("Other", "2048") } }
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved)
  test.Environment.Advance(2)
  local shout, shield, other = WeakAuras.GetData("Shout"), WeakAuras.GetData("Shield"), WeakAuras.GetData("Other")
  local function auraSpell(data)
    return data.triggers[1].trigger.auraspellids[1]
  end

  local occurrences = private.FindValueOccurrences({ shout, shield, other }, "spell", "6673", "2048")
  assert(#occurrences == 2, "occurrences: " .. #occurrences)
  assert(occurrences[1].id == "Shield" and occurrences[2].id == "Shout", "sorted by aura id")
  assert(occurrences[1].pathText == "triggers.1.trigger.auraspellids.1", "path: " .. occurrences[1].pathText)
  assert(#private.FindValueOccurrences({ other }, "spell", "2048", "17") == 1, "a font size is not a spell")
  assert(#private.FindValueOccurrences({ other }, "spell", "Blizzard", "Frost") == 0, "a texture is not a spell")
  assert(#private.FindValueOccurrences({ other }, "texture", "Blizzard", "Flat") == 1, "texture")
  assert(#private.FindValueOccurrences({ other }, "font", "Friz Quadrata TT", "Arial") == 1, "font")
  local icons, skipped = private.FindValueOccurrences({ shout }, "texture", "136000", "flat")
  assert(#icons == 0 and skipped == 1, "a number is not replaced by a text")
  icons = private.FindValueOccurrences({ shout }, "texture", "136000", "135000")
  assert(#icons == 1 and icons[1].new == 135000, "a number stays a number")
  other.cdmExactIDs = { "6673" }
  assert(#private.FindValueOccurrences({ other }, "spell", "6673", "1") == 1, "exact IDs of the Cooldown Manager")
  local gone = Icon("Gone", "6673")
  assert(#private.FindValueOccurrences({ gone }, "spell", "6673", "1") == 0, "a deleted aura is left out")

  local stale = private.FindValueOccurrences({ other }, "font", "Friz Quadrata TT", "Arial")
  other.subRegions[stale[1].path[2]].text_font = "Morpheus"
  assert(private.ReplaceValueOccurrences(stale) == 0 and private.TimeMachine.index == 0, "a changed value is left out")

  private.ReplaceValueOccurrences(occurrences)
  assert(auraSpell(shout) == "2048" and auraSpell(shield) == "2048", "replaced")
  assert(shout.desc == "6673" and auraSpell(other) == "2048", "other keys and auras unchanged")
  assert(private.TimeMachine.index == 1, "one step")
  private.TimeMachine:StepBackward()
  assert(auraSpell(shout) == "6673" and auraSpell(shield) == "6673", "undo restores")
  private.TimeMachine:StepForward()
  assert(auraSpell(shout) == "2048", "redo")
end

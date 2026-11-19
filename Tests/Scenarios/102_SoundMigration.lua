-- Sound data saved by release 1.14.0, migrated on load: with and without an Aura (Modern) trigger, legacy recorded
-- voice kind or a kind picked since. No obsolete sound_ field stays in the saved data nor in the export.
local function Aura(id, triggerType, actions, display)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = triggerType, unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, conditions = {}, actions = actions, blizzardAuraDisplay = display,
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

local ACTION_SOUND_FIELDS = {
  sound_channel = true, sound_fade = true, sound_kit_id = true, sound_path = true, sound_repeat = true,
  sound_type = true,
}

return function(test)
  local saved = { displays = {
    -- Aura (Modern), legacy voice kind on start, custom kind picked since on finish.
    SecretVoice = Aura("SecretVoice", "secretAura", {
      start = { do_sound = true, sound = " Voice", sound_voicePhrase = "clap", sound_channel = "Music" },
      finish = { do_sound = true, sound = " custom", sound_path = "a.ogg", sound_voicePhrase = "old" },
      init = {},
    }, { actionSounds = true }),
    -- 1.14.0 display switch on an aura2 trigger, with the sounds of the display (file mode).
    LegacyDisplay = Aura("LegacyDisplay", "aura2", { start = {}, finish = {}, init = {} },
      { enabled = true, soundMode = "file", soundAdded = 1, soundAddedFile = "added.ogg", soundSpellIDs = "6673",
        soundIgnoreDisplayFilters = true }),
    -- No Aura (Modern) trigger: the legacy kind and fields go all the same.
    PlainVoice = Aura("PlainVoice", "aura2", {
      start = {}, finish = { do_sound = true, sound = " Voice", sound_voicePhrase = "boom" }, init = {},
    }),
    PlainCustom = Aura("PlainCustom", "aura2", {
      start = { do_sound = true, sound = " custom", sound_path = "b.ogg", sound_voicePhrase = "old" },
      finish = {}, init = {},
    }),
    -- Sound Kit ID kind, kept with its own field.
    PlainKit = Aura("PlainKit", "aura2", {
      start = { do_sound = true, sound = " KitID", sound_kit_id = "8959", sound_voicePhrase = "old" },
      finish = {}, init = {},
    }),
    -- 1.14.0 display switch in recorded voice mode: no file to play, the sound goes.
    LegacyVoice = Aura("LegacyVoice", "aura2", { start = {}, finish = {}, init = {} },
      { enabled = true, soundMode = "voice", soundAdded = 5 }),
  } }
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate) private = addonPrivate end)
  test.Environment.Advance(1)

  local function NoLegacyField(label, actions)
    for _, timing in ipairs({ "start", "finish" }) do
      for key in pairs(actions and actions[timing] or {}) do
        assert(not (type(key) == "string" and key:find("^sound_") and not ACTION_SOUND_FIELDS[key]),
          label .. " " .. timing .. ": obsolete field " .. tostring(key) .. " kept")
      end
    end
  end
  local function Check(id, expectations)
    local data = WeakAuras.GetData(id)
    assert(data, id .. " not loaded")
    NoLegacyField(id, data.actions)
    -- The export carries the same actions: decoded, it has no obsolete field either.
    local decoded = private.StringToTable(private.DisplayToString(id, true), true)
    assert(type(decoded) == "table" and decoded.d.id == id, id .. ": export not decoded")
    assert(type(decoded.d.actions) == "table", id .. ": export lost its actions")
    NoLegacyField(id .. " export", decoded.d.actions)
    for _, expected in ipairs(expectations) do
      local timing, key, value = expected[1], expected[2], expected[3]
      local actual = data.actions[timing][key]
      assert(actual == value, ("%s %s.%s: expected %s, got %s"):format(id, timing, key, tostring(value), tostring(actual)))
    end
    return data
  end

  Check("SecretVoice", {
    { "start", "do_sound", nil }, { "start", "sound", nil }, { "start", "sound_channel", "Music" },
    { "finish", "do_sound", true }, { "finish", "sound", " custom" }, { "finish", "sound_path", "a.ogg" },
  })
  local legacy = Check("LegacyDisplay", {
    { "start", "do_sound", true }, { "start", "sound", " custom" }, { "start", "sound_path", "added.ogg" },
    { "start", "sound_channel", "Master" }, { "finish", "do_sound", nil },
  })
  assert(legacy.triggers[1].trigger.type == "secretAura", "display switch not turned into an Aura (Modern) trigger")
  local display = legacy.blizzardAuraDisplay
  assert(display.actionSounds == true and display.enabled == nil, "display sounds not marked as migrated")
  for _, field in ipairs({ "soundMode", "soundAdded", "soundAddedFile", "soundSpellIDs", "soundIgnoreDisplayFilters" }) do
    assert(display[field] == nil, "legacy display field kept: " .. field)
  end
  Check("PlainVoice", { { "finish", "do_sound", nil }, { "finish", "sound", nil } })
  Check("PlainCustom", { { "start", "do_sound", true }, { "start", "sound", " custom" }, { "start", "sound_path", "b.ogg" } })
  Check("PlainKit", { { "start", "do_sound", true }, { "start", "sound", " KitID" }, { "start", "sound_kit_id", "8959" } })
  local voice = Check("LegacyVoice", { { "start", "do_sound", nil }, { "finish", "do_sound", nil } })
  assert(voice.blizzardAuraDisplay.soundMode == nil and voice.blizzardAuraDisplay.soundAdded == nil,
    "legacy voice fields kept")
end

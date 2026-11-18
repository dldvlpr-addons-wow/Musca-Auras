-- Sounds saved by release 1.14.0, loaded from the SavedVariables: the recorded voice kind loses its sound, and no
-- obsolete sound_ field stays in the saved aura or in its export, with or without an Aura (Modern) trigger.
-- Fields of a sound file action, kept by the migration.
local KEPT = { sound_path = "a.ogg", sound_channel = "Master", sound_fade = 2, sound_repeat = 3, sound_kit_id = 4,
  sound_type = "Loop" }

local function Icon(id, triggerType)
  return {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = triggerType, unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "6673" }, matchesShowOn = "showOnActive" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = {}, information = {}, conditions = {},
    actions = {
      -- Kind of 1.14.0, still the recorded voice.
      start = { do_sound = true, sound = " Older", sound_older = "clap", sound_channel = "Music" },
      -- Kind switched to a sound file since, the phrase field of 1.14.0 left behind.
      finish = { do_sound = true, sound = " custom", sound_path = "a.ogg", sound_channel = "Master", sound_fade = 2,
        sound_repeat = 3, sound_kit_id = 4, sound_type = "Loop", sound_older = "boom" },
      init = {},
    },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN",
  }
end

return function(test)
  local saved = { displays = { Modern = Icon("Modern", "secretAura"), Plain = Icon("Plain", "aura2") } }
  local private
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", saved, function(addonPrivate)
    private = addonPrivate
  end)
  test.Environment.Advance(2)

  local function CheckActions(actions, where)
    assert(actions.start.sound_older == nil and actions.finish.sound_older == nil, where .. ": obsolete field kept")
    assert(actions.start.do_sound == nil and actions.start.sound == nil, where .. ": voice sound kept")
    assert(actions.start.sound_channel == "Music", where .. ": channel lost")
    assert(actions.finish.do_sound == true and actions.finish.sound == " custom", where .. ": sound file lost")
    for key, value in pairs(KEPT) do
      assert(actions.finish[key] == value, where .. ": " .. key .. " lost")
    end
  end

  for _, id in ipairs({ "Modern", "Plain" }) do
    CheckActions(saved.displays[id].actions, id .. " saved")
    local export = private.DisplayToString(id, true)
    local decoded = private.StringToTable(export, true)
    assert(type(decoded) == "table" and type(decoded.d) == "table", id .. ": export not readable")
    CheckActions(decoded.d.actions, id .. " export")
  end
end

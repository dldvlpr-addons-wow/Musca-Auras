-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local IsSecretAuraTrigger = Shared.IsSecretAuraTrigger
local TriggerEntries = Shared.TriggerEntries

local LEGACY_SOUND_FIELDS = { "soundMode", "soundAdded", "soundRemoved", "soundAddedFile", "soundRemovedFile" }
local LEGACY_SOUND_SLOTS = { { "Added", "start" }, { "Removed", "finish" } }

Display.MigrateSounds = function(data)
  local previous = data.blizzardAuraDisplay
  if previous.actionSounds then return end
  if not data.actions then data.actions = {} end
  local mode = previous.soundMode
  for _, slot in ipairs(LEGACY_SOUND_SLOTS) do
    local suffix, timing = slot[1], slot[2]
    local action = data.actions[timing]
    if not action then
      action = {}
      data.actions[timing] = action
    end
    local value = previous["sound" .. suffix]
    if mode == "file" then value = previous["sound" .. suffix .. "File"] or value end
    -- The legacy recorded voice mode has no file of its own to play: its sounds are dropped.
    if not action.do_sound and (mode == "file" or mode == "custom") and value ~= nil and value ~= "" and value ~= 1 then
      action.do_sound = true
      action.sound_channel = "Master"
      action.sound, action.sound_path = " custom", tostring(value)
    end
  end
  for _, field in ipairs(LEGACY_SOUND_FIELDS) do previous[field] = nil end
  previous.actionSounds = true
end

local ACTION_SOUND_FIELDS = {
  sound_channel = true, sound_fade = true, sound_kit_id = true, sound_path = true, sound_repeat = true,
  sound_type = true,
}

-- Release 1.14.0 stored the recorded voice under a leading-space kind and its own phrase field. The recorded voice
-- is gone: that kind loses its sound, and any other sound_ field is dropped even when another kind was picked since.
local function DropLegacySoundFields(action)
  local legacy = {}
  for key in pairs(action) do
    if type(key) == "string" and key:find("^sound_") and not ACTION_SOUND_FIELDS[key] then legacy[#legacy + 1] = key end
  end
  for _, key in ipairs(legacy) do action[key] = nil end
end

local function DropVoiceSound(action)
  local kind = action.sound
  if type(kind) == "string" and kind:sub(1, 1) == " " and not Private.sound_types[kind] then
    action.do_sound, action.sound = nil, nil
  end
  DropLegacySoundFields(action)
end

Display.Migrate = function(data)
  local previous = data.blizzardAuraDisplay
  local entries = TriggerEntries(data)
  if previous and previous.enabled and #entries == 1 and type(entries[1].trigger) == "table"
    and entries[1].trigger.type == "aura2" then
    entries[1].trigger.type = "secretAura"
    previous.enabled = nil
  end
  local defaults = { unit = "player", debuffType = "HELPFUL" }
  for _, candidate in ipairs(entries) do
    if IsSecretAuraTrigger(candidate) then
      local saved = candidate.trigger
      for key, fallback in pairs(defaults) do
        if not saved[key] then saved[key] = fallback end
      end
      if not saved.auraspellids then saved.auraspellids = {} end
      saved.useExactSpellId = tonumber("1") == 1
      rawset(saved, "onlyMaw", nil)
      Display.MigrateSingle(data, saved)
      Display.MigrateTotal(saved)
      local display = data.blizzardAuraDisplay
      if not display then
        display = {}
        data.blizzardAuraDisplay = display
      end
      display.enabled = nil
    end
  end
  local actions = data.actions or {}
  if not Display.HasTrigger(data) then
    -- An aura whose secret trigger was removed can still hold a recorded voice sound.
    if actions.start then DropVoiceSound(actions.start) end
    if actions.finish then DropVoiceSound(actions.finish) end
    return
  end
  Display.MigrateAppearance(data, previous)
  for _, subRegion in ipairs(data.subRegions or {}) do
    if subRegion.type == "subtext" then
      if subRegion.text_alpha == nil then subRegion.text_alpha = 1 end
      if subRegion.text_anchorXOffset == nil then subRegion.text_anchorXOffset = subRegion.anchorXOffset or 0 end
      if subRegion.text_anchorYOffset == nil then subRegion.text_anchorYOffset = subRegion.anchorYOffset or 0 end
    end
  end
  local migrateSounds = Display.MigrateSounds
  migrateSounds(data)
  actions = data.actions or {}
  if actions.start then DropVoiceSound(actions.start) end
  if actions.finish then DropVoiceSound(actions.finish) end
  for _, field in ipairs({ "soundSpellIDs", "soundIgnoreDisplayFilters" }) do
    data.blizzardAuraDisplay[field] = nil
  end
end

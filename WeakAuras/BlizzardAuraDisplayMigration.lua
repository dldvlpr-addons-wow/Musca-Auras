-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local IsSecretAuraTrigger = Shared.IsSecretAuraTrigger
local TriggerEntries = Shared.TriggerEntries

local SOUND_CHANNELS = { Master = true, SFX = true, Music = true, Ambience = true, Dialog = true }

local function PreferredSoundChannel()
  local settings = FojjiCore and FojjiCoreDB
  local channel = settings and settings.ttsSoundChannel
  channel = channel == "Sound Effects" and "SFX" or channel
  return SOUND_CHANNELS[channel] and channel or "Master"
end

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
    if not action.do_sound and mode and mode ~= "none" and value ~= nil and value ~= "" and value ~= 1 then
      action.do_sound = true
      action.sound_channel = PreferredSoundChannel()
      if mode == "fojji" then
        action.sound, action.sound_fojji = " Fojji", value
      else
        action.sound, action.sound_path = " custom", tostring(value)
      end
    end
  end
  for _, field in ipairs(LEGACY_SOUND_FIELDS) do previous[field] = nil end
  previous.actionSounds = true
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
  if not Display.HasTrigger(data) then return end
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
  for _, field in ipairs({ "soundSpellIDs", "soundIgnoreDisplayFilters" }) do
    data.blizzardAuraDisplay[field] = nil
  end
end

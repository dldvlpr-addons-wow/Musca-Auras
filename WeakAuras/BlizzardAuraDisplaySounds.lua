-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...
local L = WeakAuras.L

local Display = Private.BlizzardAuraDisplay
local Shared = Private.AuraDisplayShared
local InPreview = Shared.InPreview
local Join = Shared.Join
local Listed = Shared.Listed

local function SoundFileOf(action)
  local kind, file = action.sound, nil
  if kind == " custom" then
    file = action.sound_path
    if tonumber(file) then file = tonumber(file) end
  elseif kind ~= " KitID" then
    file = kind
  end
  if file == nil or file == "" or file == 1 then
    return nil, "Pick a sound file in the Actions tab."
  end
  return file
end

local SOUND_FIELDS = { "do_sound", "sound", "sound_path", "sound_channel" }
local SOUND_SLOTS = {
  { "start", "Added", "added" },
  { "finish", "Removed", "removed" },
  { "increase", "ApplicationsIncreased", "stack increase" },
}
-- Same sound from several units or spells within this delay plays once: no burst on a group-wide buff.
local SOUND_THROTTLE_SECONDS = 0.5

local function ActionFingerprint(action)
  local pieces = {}
  for index, field in ipairs(SOUND_FIELDS) do pieces[index] = tostring(action[field]) end
  return table.concat(pieces, ",")
end

local function SoundFingerprint(trigger, actions)
  return table.concat({
    ActionFingerprint(actions.start or {}),
    ActionFingerprint(actions.finish or {}),
    ActionFingerprint(actions.increase or {}),
    Join(Display.UnitTokens(trigger)),
    Join(Display.GetSpellIDs(trigger, true)),
    Join(Listed(trigger.excludedAuraSpellIDs)),
  }, "|")
end

local function SoundSpellList(trigger)
  local blocked = {}
  local hasIgnored = Display.UsesExcludedSpellIDs(trigger)
  if hasIgnored then
    for _, value in ipairs(Listed(trigger.excludedAuraSpellIDs)) do
      local id = tonumber(value)
      if id then blocked[id] = true end
    end
  end
  local list = {}
  local every = Display.GetSpellIDs(trigger, true)
  for position = 1, #every do
    if not blocked[every[position]] then list[#list + 1] = every[position] end
  end
  table.sort(list)
  return list
end

local function PostSoundWarning(uid, text)
  if text then
    Private.AuraWarnings.UpdateWarning(uid, "blizzard_aura_sound", "warning", text)
  else
    Private.AuraWarnings.UpdateWarning(uid, "blizzard_aura_sound")
  end
end

local function SoundRegistrationAvailable()
  return C_UnitAuras and C_UnitAuras.AddAuraSound and C_UnitAuras.RemoveAuraSound
    and Enum.UnitAuraSoundTrigger
end

local queuedSoundSyncs = {}

-- The client may refuse sound changes while restricted: a refused call keeps the region queued for the end of
-- the restriction. A secret sound ID is never kept.
local function RemoveSound(soundID)
  return pcall(C_UnitAuras.RemoveAuraSound, soundID)
end

local function UpdateSounds(region)
  queuedSoundSyncs[region] = nil
  local state = region.blizzardAuraDisplay
  if not state then return end

  local data = state.data
  local current = Display.GetTrigger(data)
  local actions = data and data.actions or {}
  local live = current ~= nil and state.active and region:IsShown() and not InPreview() and not Private.db.soundsMuted
  local fingerprint = live and SoundFingerprint(current, actions) or nil
  if fingerprint and fingerprint == state.soundSignature then return end
  state.soundSignature = fingerprint

  local kept = {}
  for _, soundID in ipairs(state.soundIDs or {}) do
    if not RemoveSound(soundID) then kept[#kept + 1] = soundID end
  end
  state.soundIDs = kept
  if #kept > 0 then
    -- Removal refused (restricted): try again at the end of the restriction.
    state.soundSignature = nil
    queuedSoundSyncs[region] = true
    return
  end
  PostSoundWarning(data and data.uid)
  if not live then return end

  local startAction, finishAction = actions.start, actions.finish
  local stackAction = actions.increase
  if not ((startAction and startAction.do_sound) or (finishAction and finishAction.do_sound)
    or (stackAction and stackAction.do_sound)) then return end
  if not SoundRegistrationAvailable() then
    return PostSoundWarning(data and data.uid, L["This client does not provide aura sound registration."])
  end
  local spells = SoundSpellList(current)
  if #spells == 0 then
    return PostSoundWarning(data and data.uid, "Enable Spell ID(s) or Exact Spell ID(s) in Trigger and enter an ID that is not ignored to use aura sounds.")
  end

  local tokens, failure, refused = Display.UnitTokens(current), nil, false
  for _, slot in ipairs(SOUND_SLOTS) do
    local action = actions[slot[1]]
    local kind = Enum.UnitAuraSoundTrigger[slot[2]]
    if action and action.do_sound and not kind then
      failure = L["This client has no sound trigger for stacks gained."]
    elseif action and action.do_sound then
      local file, problem = SoundFileOf(action)
      if not file then
        failure = problem
      else
        for _, token in ipairs(tokens) do
          for _, spellID in ipairs(spells) do
            local info = { unitToken = token, spellID = spellID, outputChannel = action.sound_channel or "Master",
              throttleSeconds = SOUND_THROTTLE_SECONDS }
            if type(file) == "string" then info.soundFileName = file end
            if type(file) == "number" then info.soundFileID = file end
            local ok, soundID = pcall(C_UnitAuras.AddAuraSound, kind, info)
            if ok and soundID and not Private.IsSecret(soundID) then
              state.soundIDs[#state.soundIDs + 1] = soundID
            elseif WeakAuras.IsRestricted() then
              refused = true
            else
              failure = "The client refused the " .. slot[3] .. " sound for spell " .. spellID .. "."
              if not ok then failure = failure .. " " .. tostring(soundID) end
            end
          end
        end
      end
    end
  end
  if refused then
    -- Registration refused while restricted: registered again at the end of the restriction.
    state.soundSignature = nil
    queuedSoundSyncs[region] = true
  end
  PostSoundWarning(data and data.uid, failure)
end

local PREVIEW_NOTICE = "Preview only: spell ID filters hide these auras in combat.\nSounds configured in Actions can still play."

local function RefreshPreviewNotice(region)
  local state = region.blizzardAuraDisplay
  local trigger = Display.GetTrigger(state and state.data)
  local notice = region.secretAuraPreviewNotice
  local noteLevel = trigger and Display.SpellIDFilterNote(trigger)
  if noteLevel == "error" then
    if not notice then
      notice = region:CreateFontString(nil, "OVERLAY")
      notice:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
      notice:SetPoint("TOP", region, "BOTTOM", 0, -6)
      notice:SetWidth(300)
      notice:SetTextColor(1, 0.8, 0.2)
      region.secretAuraPreviewNotice = notice
    end
    notice:SetText(PREVIEW_NOTICE)
    notice:Show()
  elseif notice then
    notice:Hide()
  end
end

local SyncSounds = UpdateSounds

local function FlushPendingSounds()
  -- UpdateSounds may queue a region again, so walk a copy of the queue.
  local regions = {}
  for auraRegion in pairs(queuedSoundSyncs) do regions[#regions + 1] = auraRegion end
  for _, auraRegion in ipairs(regions) do UpdateSounds(auraRegion) end
end

-- /wa mute: the sounds registered with the game are removed, and registered again when the mute ends.
function Private.SyncAuraSoundsWithMute()
  local refused = false
  for _, regionData in pairs(Private.regions) do
    local region = regionData.region
    if region and region.blizzardAuraDisplay then
      UpdateSounds(region)
      refused = refused or queuedSoundSyncs[region] == true
    end
  end
  -- True when the game refused one of these changes (restricted): it is done at the end of the restriction.
  return refused
end

Shared.FlushPendingSounds = FlushPendingSounds
Shared.RefreshPreviewNotice = RefreshPreviewNotice
Shared.SyncSounds = SyncSounds

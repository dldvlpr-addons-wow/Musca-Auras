local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- Flashes a cooldown the moment it comes back. The spells are the utility row of each class pack, so the two stay in
-- step; the racials of every pack share one icon.
local FOLDERS = { "Guerrier", "Paladin", "Chasseur", "Voleur", "Pretre", "Chaman", "Mage", "Demoniste", "Druide" }
local RACIALS = { 20600, 20594, 20580, 20589, 20572, 7744, 20577, 20549, 26297 }
local SOUND = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\WaterDrop.ogg"

local pack = Utility.New("Ready Flash", "muUtilReadyFlashV1", { yOffset = 120 })

local function ReadyTrigger(spell)
  return Parts.Generic({ type = "spell", event = "Cooldown Ready (Spell)", spellName = spell,
    use_exact_spellName = false, duration = "1.5" })
end

local function Flash(label, list, options)
  options.size = { 56, 56 }
  local data = pack.Icon(label, list, options)
  data.cooldown = false
  data.animation.start = { type = "preset", preset = "grow", duration_type = "seconds", duration = "0.2" }
  data.animation.main = { type = "preset", preset = "pulse", duration_type = "seconds" }
  data.animation.finish = { type = "preset", preset = "fade", duration_type = "seconds", duration = "0.3" }
  data.actions.start = { do_sound = true, sound = SOUND, sound_channel = "Master" }
  return data
end

local racial = {}
for _, spell in ipairs(RACIALS) do racial[spell] = true end

for _, folder in ipairs(FOLDERS) do
  local classPack = dofile("Tests/Packs/" .. folder .. "/Pack" .. folder .. ".lua")
  local className = (classPack.d.id:gsub(" %(Musca%)$", ""))
  local utilityGroup = className .. " - Utility"
  local list, seen = {}, {}
  for _, child in ipairs(classPack.c) do
    if child.parent == utilityGroup then
      for _, slot in ipairs(child.triggers) do
        local spell = slot.trigger.event == "Cooldown Progress (Spell)" and slot.trigger.spellName
        if spell and not racial[spell] and not seen[spell] then
          seen[spell] = true
          list[#list + 1] = ReadyTrigger(spell)
        end
      end
    end
  end
  assert(#list > 0, folder .. ": no utility cooldown")
  Flash(className, list, { class = classPack.d.load.class.single })
end

local racials = {}
for index, spell in ipairs(RACIALS) do racials[index] = ReadyTrigger(spell) end
Flash("Racials", racials, {})

for _, slot in ipairs({ 13, 14 }) do
  Flash("Trinket " .. slot, { Parts.Generic({ type = "item", event = "Cooldown Ready (Equipment Slot)", itemSlot = slot,
    use_itemSlot = true, duration = "1.5" }) }, {})
end

return pack.Finish()

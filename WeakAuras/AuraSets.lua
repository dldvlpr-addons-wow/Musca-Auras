-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Aura set of a character: a tag chosen per character. While a character has one, it loads only the auras that carry
-- this tag, themselves or through one of their groups. The choice is kept in WeakAurasSaved.characterAuraSets, by
-- "Name-Realm", so one account keeps one HUD per character without copies of the auras.

local characterKey
local keyWasUnreadable = false

-- Read once: the name of the player can be secret in a restricted map, it is not a usable key then. Every aura loaded
-- meanwhile, so once the name is readable the next frame rescans them all against the set of this character.
local function CharacterKey()
  if not characterKey then
    local name, realm = UnitName("player"), GetRealmName()
    if name and realm and not Private.IsSecret(name, realm) then
      characterKey = name .. "-" .. realm
      if keyWasUnreadable then
        C_Timer.After(0, function() Private.ScanForLoads(nil, "SCAN_ALL") end)
      end
    else
      keyWasUnreadable = true
    end
  end
  return characterKey
end

-- "#pvp" is how the search box writes a tag, it names the same tag as "pvp".
local function NormalizeTag(tag)
  tag = strtrim(tag or ""):gsub("^#", ""):lower()
  return tag ~= "" and tag or nil
end

--- The tag of the aura set of this character, lowered, or nil when the character loads all auras.
function Private.GetCharacterAuraSet()
  local key = CharacterKey()
  local sets = WeakAurasSaved.characterAuraSets
  return key and sets and sets[key]
end

--- Sets the aura set of this character, an empty tag clears it, then loads and unloads the auras to match.
function Private.SetCharacterAuraSet(tag)
  local key = CharacterKey()
  if not key then
    return false
  end
  WeakAurasSaved.characterAuraSets = WeakAurasSaved.characterAuraSets or {}
  WeakAurasSaved.characterAuraSets[key] = NormalizeTag(tag)
  Private.ScanForLoads(nil, "SCAN_ALL")
  return true
end

-- Tags of each tags string, normalized once: the load scan asks for every aura at every scan.
local tagsOf = {}

local function HasTag(tags, wanted)
  if type(tags) ~= "string" then
    return false
  end
  local set = tagsOf[tags]
  if not set then
    set = {}
    for tag in tags:gmatch("[^,]+") do
      local normalized = NormalizeTag(tag)
      if normalized then
        set[normalized] = true
      end
    end
    tagsOf[tags] = set
  end
  return set[wanted] == true
end

--- Whether the aura belongs to the given aura set; every aura does when there is none.
function Private.IsInAuraSet(data, auraSet)
  while data do
    if not auraSet or HasTag(data.tags, auraSet) then
      return true
    end
    data = data.parent and WeakAuras.GetData(data.parent)
  end
  return false
end

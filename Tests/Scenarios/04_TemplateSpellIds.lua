-- Every class template spell ID, after the Forever fixes, must appear in Classes/<Class>.md.
-- ponytail: any number in the class file counts as known, so an ID equal to a cost or another
-- number of the file passes; parse the Spell ID columns if that ever hides a missing ID.
-- Sections "Écarts avec le DB2 client" and "Points non vérifiés" do not count, nor text lines
-- (outside tables) that list spells "absents de Forever".
-- Not checked: the stance and form loops of TriggerTemplatesDataClassicEra.lua, which skip
-- IDs the client does not know (if title then).
local classFiles = {
  WARRIOR = "Warrior", PALADIN = "Paladin", HUNTER = "Hunter", ROGUE = "Rogue", PRIEST = "Priest",
  SHAMAN = "Shaman", MAGE = "Mage", WARLOCK = "Warlock", DRUID = "Druid",
}

-- Aura IDs absent from Classes/*.md (the files list cast spells). Checked in the 1.60.1.70245
-- SpellName DB2 (wago.tools CSV); templates match them by name.
local unverified = {
  [25816] = true, -- PRIEST "Hex of Weakness", same name as 9035
  [3600] = true, -- SHAMAN "Earthbind", debuff of Earthbind Totem 2484
  [20707] = true, -- WARLOCK "Soulstone Resurrection"
}

-- IDs listed in Classes/*.md (talent tables) but not castable on Forever: SkillLineAbility AcquireMethod 3.
local neverLearned = {
  [5217] = true, -- DRUID Tiger's Fury
  [16979] = true, -- DRUID Feral Charge (Bear) talent, cast spell is 1238122
}

local function KnownIds(path)
  local file = assert(io.open(path, "r"), "missing " .. path)
  local known, contested = {}, false
  for line in file:lines() do
    if line:find("^#") then
      contested = line:find("Écarts", 1, true) ~= nil or line:find("non vérifiés", 1, true) ~= nil
    elseif not contested and (line:find("^|") or not line:find("absents? de Forever")) then
      for number in line:gmatch("%d+") do
        known[tonumber(number)] = true
      end
    end
  end
  file:close()
  return known
end

return function(test)
  test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  local templatesDirectory = test.tocPath:gsub("WeakAuras/WeakAuras%.toc$", "WeakAurasTemplates/")
  local classesDirectory = test.tocPath:gsub("WeakAuras/WeakAuras%.toc$", "Classes/")
  local templatePrivate = {}
  for _, name in ipairs({ "TriggerTemplatesDataForever.lua", "TriggerTemplatesDataClassicEra.lua" }) do
    local ok, message = test.Loader.RunFile(templatesDirectory .. name, "WeakAurasTemplates", templatePrivate)
    assert(ok, message)
  end
  local templates = assert(templatePrivate.triggerTemplates, "triggerTemplates missing")

  local missing, checked = {}, 0
  for className, fileName in pairs(classFiles) do
    local known = KnownIds(classesDirectory .. fileName .. ".md")
    for _, spec in pairs(assert(templates.class[className], "no templates for " .. className)) do
      for _, section in pairs(spec) do
        for _, item in ipairs(section.args or {}) do
          if type(item.spell) == "number" then
            checked = checked + 1
            if neverLearned[item.spell] or (not known[item.spell] and not unverified[item.spell]) then
              missing[#missing + 1] = string.format("%s %d (%s)", className, item.spell, tostring(section.title))
            end
          end
        end
      end
    end
  end
  table.sort(missing)
  assert(checked > 0, "no template spell checked")
  assert(#missing == 0, #missing .. " template spell ID(s) missing from Classes/*.md:\n" .. table.concat(missing, "\n"))
end

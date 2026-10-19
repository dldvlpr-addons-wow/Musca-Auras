-- Every class template spell ID, after the Forever fixes, must appear in Classes/<Class>.md.
-- ponytail: any number in the class file counts as known, so an ID equal to a cost or another
-- number of the file passes; parse the Spell ID columns if that ever hides a missing ID.
-- Sections "Écarts avec le DB2 client" and "Points non vérifiés" do not count, nor text lines
-- (outside tables) that list spells "absents de Forever".
-- The stance and form loops of TriggerTemplatesDataClassicEra.lua skip IDs the client does not
-- know (if title then), so their ID lists are read from the file text.
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
  local formsByPosition = { 9634, 1066, 2457, 768 }
  GetNumShapeshiftForms = function() return #formsByPosition end
  GetShapeshiftFormInfo = function(index) return nil, nil, nil, formsByPosition[index] end
  C_Spell.GetSpellInfo = function(id) return { name = "Spell " .. id, iconID = 134400, spellID = id } end
  for _, name in ipairs({ "TriggerTemplatesDataForever.lua", "TriggerTemplatesDataClassicEra.lua" }) do
    local ok, message = test.Loader.RunFile(templatesDirectory .. name, "WeakAurasTemplates", templatePrivate)
    assert(ok, message)
  end
  local templates = assert(templatePrivate.triggerTemplates, "triggerTemplates missing")

  local forms = {}
  for _, item in ipairs(templates.class.DRUID[1][8].args) do
    local trigger = item.triggers and item.triggers[1].trigger
    if trigger and trigger.use_form then
      forms[#forms + 1] = trigger.form.single .. "=" .. item.title
    end
  end
  forms = table.concat(forms, ",")
  assert(forms == "5487=Spell 9634,1066=Spell 1066,768=Spell 768", "Druid form templates: " .. forms)

  local file = assert(io.open(templatesDirectory .. "TriggerTemplatesDataClassicEra.lua", "r"))
  local source = file:read("*a")
  file:close()
  local loops = {}
  for ids, className in source:gmatch("ipairs%(%{([%d,%s]+)%}%) do.-templates%.class%.(%u+)") do
    loops[#loops + 1] = { className = className, ids = ids }
  end
  assert(#loops == 2, #loops .. " stance or form loop(s) found, 2 expected")

  local missing, checked = {}, 0
  for className, fileName in pairs(classFiles) do
    local known = KnownIds(classesDirectory .. fileName .. ".md")
    for _, loop in ipairs(loops) do
      if loop.className == className then
        for id in loop.ids:gmatch("%d+") do
          id = tonumber(id)
          checked = checked + 1
          if neverLearned[id] or not known[id] then
            missing[#missing + 1] = string.format("%s %d (stance or form loop)", className, id)
          end
        end
      end
    end
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

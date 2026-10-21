local AddonName, TemplatePrivate = ...
local WeakAuras = WeakAuras
local L = WeakAuras.L

local BUFFS, DEBUFFS, ABILITIES = 1, 2, 3

local function Ability(spell, fields)
  local entry = fields or {}
  entry.spell = spell
  entry.type = "ability"
  return entry
end

local function Aura(spell, auraType, unit)
  return { spell = spell, type = auraType, unit = unit }
end

local fixes = {
  WARRIOR = {
    replace = { [DEBUFFS] = { [7384] = 7386 } },
    add = {
      [ABILITIES] = {
        Ability(1310222, { requiresTarget = true }),
        Ability(402927, { requiresTarget = true, usable = true }),
      },
    },
  },
  PALADIN = {
    add = {
      [ABILITIES] = {
        Ability(1311606),
        Ability(407632, { requiresTarget = true }),
        Ability(1310911),
      },
    },
  },
  HUNTER = {
    remove = { [ABILITIES] = { [19386] = true } },
    add = {
      [BUFFS] = {
        Aura(415423, "buff", "player"),
        Aura(469145, "buff", "player"),
        Aura(409580, "buff", "player"),
      },
      [ABILITIES] = {
        Ability(415423, { buff = true }),
        Ability(469145, { buff = true }),
        Ability(1310687, { requiresTarget = true }),
        Ability(1221404),
        Ability(1293241),
        Ability(1317257),
      },
    },
  },
  ROGUE = {
    replace = {
      [DEBUFFS] = { [17348] = 16511 },
      [ABILITIES] = { [14271] = 14278 },
    },
    remove = { [BUFFS] = { [14149] = true } },
    add = {
      [ABILITIES] = {
        Ability(1310707, { requiresTarget = true }),
        Ability(1310703, { requiresTarget = true }),
        Ability(1310709, { requiresTarget = true }),
        Ability(438040),
      },
    },
  },
  PRIEST = {
    replace = {
      [BUFFS] = { [19293] = 2651 },
      [ABILITIES] = { [10947] = 15407 },
    },
    add = {
      [ABILITIES] = {
        Ability(401977),
        Ability(401937),
        Ability(1277331, { titleSuffix = L["(Dwarf)"] }),
        Ability(1277370, { titleSuffix = L["(Human)"] }),
        Ability(1277324, { titleSuffix = L["(Undead)"] }),
      },
    },
  },
  SHAMAN = {
    replace = { [ABILITIES] = { [8142] = 8042, [8143] = 8056, [8514] = 8512 } },
    remove = { [ABILITIES] = { [1535] = true, [25908] = true } },
    add = {
      [ABILITIES] = {
        Ability(408341),
        Ability(408490, { requiresTarget = true }),
        Ability(408521),
        Ability(437009),
      },
    },
  },
  MAGE = {
    remove = { [ABILITIES] = { [2855] = true } },
    add = {
      [DEBUFFS] = { Aura(401502, "debuff", "target") },
      [ABILITIES] = {
        Ability(401502, { requiresTarget = true, debuff = true }),
        Ability(24530),
      },
    },
  },
  WARLOCK = {
    replace = {
      [DEBUFFS] = { [1490] = 440892 },
      [ABILITIES] = { [18877] = 17877 },
    },
    remove = { [DEBUFFS] = { [17862] = true } },
    add = {
      [DEBUFFS] = { Aura(1225228, "debuff", "target") },
      [ABILITIES] = {
        Ability(1225228, { requiresTarget = true, debuff = true }),
        Ability(412758, { requiresTarget = true }),
        Ability(1316697, { requiresTarget = true }),
      },
    },
  },
  DRUID = {
    remove = { [ABILITIES] = { [5217] = true, [16979] = true } },
    add = {
      [ABILITIES] = {
        Ability(1238122, { requiresTarget = true, usable = true }),
        Ability(407995, { requiresTarget = true, form = 1 }),
        Ability(1322605),
        Ability(437138),
      },
    },
  },
}

local function ReplaceFirstMatches(args, mapping)
  local pending = CopyTable(mapping)
  for _, entry in ipairs(args) do
    local newSpell = pending[entry.spell]
    if newSpell then
      pending[entry.spell] = nil
      entry.spell = newSpell
    end
  end
end

local function RemoveAllMatches(args, spells)
  for index = #args, 1, -1 do
    if spells[args[index].spell] then
      tremove(args, index)
    end
  end
end

local function AppendKnown(args, entries)
  for _, entry in ipairs(entries) do
    entry.known = true
    tinsert(args, entry)
  end
end

function TemplatePrivate.ApplyForeverFixes(templates)
  for className, classFixes in pairs(fixes) do
    local spec = templates.class[className][1]
    for section, mapping in pairs(classFixes.replace or {}) do
      ReplaceFirstMatches(spec[section].args, mapping)
    end
    for section, spells in pairs(classFixes.remove or {}) do
      RemoveAllMatches(spec[section].args, spells)
    end
    for section, entries in pairs(classFixes.add or {}) do
      AppendKnown(spec[section].args, entries)
    end
  end
end

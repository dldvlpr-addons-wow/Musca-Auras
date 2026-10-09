local AddonName, TemplatePrivate = ...
---@class WeakAuras
local WeakAuras = WeakAuras
if not WeakAuras.IsClassicEra() then return end
local L = WeakAuras.L

-- WoW Forever corrections to the Classic Era class templates.
-- Spell IDs checked against the 1.60.1.70245 client DB2 (SpellName, SkillLineAbility); see Classes/*.md.
-- Sections: [1] Buffs, [2] Debuffs, [3] Abilities.
-- replace: old ID -> new ID, applied to the first entry with that ID in the section only
--          (Shaman 8143 is both "Frost Shock" and "Tremor Totem").
-- remove:  IDs missing from the Forever client.
-- add:     Forever spells, loaded only when known.

local fixes = {
  WARRIOR = {
    replace = {
      [2] = { [7384] = 7386 }, -- Overpower -> Sunder Armor debuff
    },
    add = {
      [3] = {
        { spell = 1310222, type = "ability", requiresTarget = true }, -- Spearing Strike
        { spell = 402927, type = "ability", requiresTarget = true, usable = true }, -- Victory Rush
      },
    },
  },
  PALADIN = {
    add = {
      [3] = {
        { spell = 1311606, type = "ability" }, -- Holy Shock
        { spell = 407632, type = "ability", requiresTarget = true }, -- Hammer of the Righteous
        { spell = 1310911, type = "ability" }, -- Light's Vigil
      },
    },
  },
  HUNTER = {
    remove = {
      [3] = { [19386] = true }, -- Wyvern Sting
    },
    add = {
      [1] = {
        { spell = 415423, type = "buff", unit = "player" }, -- Aspect of the Viper
        { spell = 469145, type = "buff", unit = "player" }, -- Aspect of the Falcon
        { spell = 409580, type = "buff", unit = "player" }, -- Heart of the Lion
      },
      [3] = {
        { spell = 415423, type = "ability", buff = true }, -- Aspect of the Viper
        { spell = 469145, type = "ability", buff = true }, -- Aspect of the Falcon
        { spell = 1310687, type = "ability", requiresTarget = true }, -- Sniper Shot
        { spell = 1221404, type = "ability" }, -- Enchanted Flare
        { spell = 1293241, type = "ability" }, -- Summon Hawk
        { spell = 1317257, type = "ability" }, -- Strider Kick
      },
    },
  },
  ROGUE = {
    replace = {
      [2] = { [17348] = 16511 }, -- Hemorrhage
      [3] = { [14271] = 14278 }, -- Mongoose Bite -> Ghostly Strike
    },
    remove = {
      [1] = { [14149] = true }, -- Remorseless
    },
    add = {
      [3] = {
        { spell = 1310707, type = "ability", requiresTarget = true }, -- Mutilate
        { spell = 1310703, type = "ability", requiresTarget = true }, -- Venom
        { spell = 1310709, type = "ability", requiresTarget = true }, -- Coup de Grace
        { spell = 438040, type = "ability" }, -- Redirect
      },
    },
  },
  PRIEST = {
    replace = {
      [1] = { [19293] = 2651 }, -- Elune's Grace
      [3] = { [10947] = 15407 }, -- Mind Blast -> Mind Flay
    },
    add = {
      [3] = {
        { spell = 401977, type = "ability" }, -- Shadowfiend
        { spell = 401937, type = "ability" }, -- Binding Heal
        { spell = 1277331, type = "ability", titleSuffix = L["(Dwarf)"] }, -- Chastise
        { spell = 1277370, type = "ability", titleSuffix = L["(Human)"] }, -- Divine Grace
        { spell = 1277324, type = "ability", titleSuffix = L["(Undead)"] }, -- Dark Sacrifice
      },
    },
  },
  SHAMAN = {
    replace = {
      [3] = {
        [8142] = 8042, -- Grasping Vines -> Earth Shock
        [8143] = 8056, -- Tremor Totem -> Frost Shock (first entry only)
        [8514] = 8512, -- Windfury Totem
      },
    },
    remove = {
      [3] = {
        [1535] = true, -- Fire Nova Totem, replaced by Fire Nova
        [25908] = true, -- Tranquil Air Totem
      },
    },
    add = {
      [3] = {
        { spell = 408341, type = "ability" }, -- Fire Nova
        { spell = 408490, type = "ability", requiresTarget = true }, -- Lava Burst
        { spell = 408521, type = "ability" }, -- Riptide
        { spell = 437009, type = "ability" }, -- Totemic Projection
      },
    },
  },
  MAGE = {
    remove = {
      [3] = { [2855] = true }, -- Detect Magic
    },
    add = {
      [2] = {
        { spell = 401502, type = "debuff", unit = "target" }, -- Frostfire Bolt
      },
      [3] = {
        { spell = 401502, type = "ability", requiresTarget = true, debuff = true }, -- Frostfire Bolt
        { spell = 24530, type = "ability" }, -- Felfire
      },
    },
  },
  WARLOCK = {
    replace = {
      [2] = { [1490] = 440892 }, -- Curse of the Elements
      [3] = { [18877] = 17877 }, -- Shadowburn
    },
    remove = {
      [2] = { [17862] = true }, -- Curse of Shadow
    },
    add = {
      [2] = {
        { spell = 1225228, type = "debuff", unit = "target" }, -- Bane of Havoc
      },
      [3] = {
        { spell = 1225228, type = "ability", requiresTarget = true, debuff = true }, -- Bane of Havoc
        { spell = 412758, type = "ability", requiresTarget = true }, -- Incinerate
        { spell = 1316697, type = "ability", requiresTarget = true }, -- Wrack
      },
    },
  },
  DRUID = {
    remove = {
      [3] = {
        [5217] = true, -- Tiger's Fury, SkillLineAbility AcquireMethod 3 (never learned)
        [16979] = true, -- Feral Charge (Bear) talent, AcquireMethod 3; replaced by 1238122
      },
    },
    add = {
      [3] = {
        { spell = 1238122, type = "ability", requiresTarget = true, usable = true }, -- Feral Charge (Bear and Cat Form per web guides)
        { spell = 407995, type = "ability", requiresTarget = true, form = 1 }, -- Primal Bite
        { spell = 1322605, type = "ability" }, -- Shifting Power
        { spell = 437138, type = "ability" }, -- Revive
      },
    },
  },
}

-- Called by TriggerTemplatesDataClassicEra.lua before enrichDatabase, so added entries get titles and load conditions.
function TemplatePrivate.ApplyForeverFixes(templates)
  for className, classFixes in pairs(fixes) do
    local spec = templates.class[className][1]
    for sectionIndex, pending in pairs(classFixes.replace or {}) do
      pending = CopyTable(pending)
      for _, item in ipairs(spec[sectionIndex].args) do
        local newSpell = pending[item.spell]
        if newSpell then
          pending[item.spell] = nil
          item.spell = newSpell
        end
      end
    end
    for sectionIndex, removed in pairs(classFixes.remove or {}) do
      local args = spec[sectionIndex].args
      for i = #args, 1, -1 do
        if removed[args[i].spell] then
          tremove(args, i)
        end
      end
    end
    for sectionIndex, added in pairs(classFixes.add or {}) do
      for _, item in ipairs(added) do
        item.known = true
        tinsert(spec[sectionIndex].args, item)
      end
    end
  end
end

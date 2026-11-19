if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

---@class WeakAuras
local WeakAuras = WeakAuras;
local L = WeakAuras.L;

local encounter_list = ""
function Private.InitializeEncounterAndZoneLists()
  if encounter_list ~= "" then
    return
  end
  local raids = {
    {
      L["World Bosses"],
      {
        { L["Kazzak"], 3026 },
        { L["Azuregos"], 3027 },
        { L["Onyxia"], 1084 }
      }
    },
    {
      L["Molten Core"],
      {
        { L["Lucifron"], 663 },
        { L["Magmadar"], 664 },
        { L["Gehennas"], 665 },
        { L["Garr"], 666 },
        { L["Shazzrah"], 667 },
        { L["Baron Geddon"], 668 },
        { L["Sulfuron Harbinger"], 669 },
        { L["Golemagg the Incinerator"], 670 },
        { L["Majordomo Executus"], 671 },
        { L["Ragnaros"], 672 }
      }
    },
    {
      L["Black Wing Lair"],
      {
          { L["Razorgore the Untamed"], 610 },
          { L["Vaelastrasz the Corrupt"], 611 },
          { L["Broodlord Lashlayer"], 612 },
          { L["Firemaw"], 613 },
          { L["Ebonroc"], 614 },
          { L["Flamegor"], 615 },
          { L["Chromaggus"], 616 },
          { L["Nefarian"], 617 }
      }
    },
    {
      L["Ahn'Qiraj"],
      {
        { L["The Prophet Skeram"], 709 },
        { L["Silithid Royalty"], 710 },
        { L["Battleguard Sartura"], 711 },
        { L["Fankriss the Unyielding"], 712 },
        { L["Viscidus"], 713 },
        { L["Princess Huhuran"], 714 },
        { L["Twin Emperors"], 715 },
        { L["Ouro"], 716 },
        { L["C'thun"], 717 }
      }
    },
    {
      L["Ruins of Ahn'Qiraj"],
      {
        { L["Kurinnaxx"], 718 },
        { L["General Rajaxx"], 719 },
        { L["Moam"], 720 },
        { L["Buru the Gorger"], 721 },
        { L["Ayamiss the Hunter"], 722 },
        { L["Ossirian the Unscarred"], 723 }
      }
    },
    {
      L["Zul'Gurub"],
      {
        { L["High Priest Venoxis"], 784 },
        { L["High Priestess Jeklik"], 785 },
        { L["High Priestess Mar'li"], 786 },
        { L["Bloodlord Mandokir"], 787 },
        { L["Edge of Madness"], 788 },
        { L["High Priest Thekal"], 789 },
        { L["Gahz'ranka"], 790 },
        { L["High Priestess Arlokk"], 791 },
        { L["Jin'do the Hexxer"], 792 },
        { L["Hakkar"], 793 }
      }
    },
    {
      L["Naxxramas"],
      {
        -- The Arachnid Quarter
        { L["Anub'Rekhan"], 1107 },
        { L["Grand Widow Faerlina"], 1110 },
        { L["Maexxna"], 1116 },
        -- The Plague Quarter
        { L["Noth the Plaguebringer"], 1117 },
        { L["Heigan the Unclean"], 1112 },
        { L["Loatheb"], 1115 },
        -- The Military Quarter
        { L["Instructor Razuvious"], 1113 },
        { L["Gothik the Harvester"], 1109 },
        { L["The Four Horsemen"], 1121 },
        -- The Construct Quarter
        { L["Patchwerk"], 1118 },
        { L["Grobbulus"], 1111 },
        { L["Gluth"], 1108 },
        { L["Thaddius"], 1120 },
        -- Frostwyrm Lair
        { L["Sapphiron"], 1119 },
        { L["Kel'Thuzad"], 1114 }
      }
    },
    {
      L["Scarlet Enclave"],
      {
        { L["Balnazzar"], 3185 },
        { L["Beatrix"], 3187 },
        { L["Solistrasza"], 3186 },
        { L["Mason"], 3197 },
        { L["Beastmaster"], 3196 },
        { L["Reborn Council"], 3188 },
        { L["Lillian Voss"], 3190 },
        { L["Caldoran"], 3189 },
      }
    }
  }

  -- Forever dungeons, from the client's DungeonEncounter table. A boss listed with two IDs has two encounters.
  -- The dungeon name comes from the client, in the player's language.
  local dungeons = {
    { 389, -- Ragefire Chasm
      {
        { "Oggleflint", 2732 },
        { "Taragaman the Hungerer", 2733 },
        { "Jergosh the Invoker", 2734 },
        { "Bazzalan", 2735 },
      }
    },
    { 36, -- Deadmines
      {
        { "Rhahk'Zor", 2741 },
        { "Sneed", 2742 },
        { "Miner Johnson", 3676 },
        { "Gilnid", 2743 },
        { "Captain Greenskin", 2744 },
        { "Mr. Smite", 2745 },
        { "Cookie", 2746 },
        { "Edwin VanCleef", 2747 },
      }
    },
    { 43, -- Wailing Caverns
      {
        { "Lady Anacondra", 585 },
        { "Lord Cobrahn", 586 },
        { "Kresh", 587 },
        { "Lord Pythas", 588 },
        { "Skum", 589 },
        { "Lord Serpentis", 590 },
        { "Verdan the Everliving", 591 },
        { "Mutanus the Devourer", 592 },
      }
    },
    { 33, -- Shadowfang Keep
      {
        { "Rethilgore", 2748 },
        { "Razorclaw the Butcher", 2749 },
        { "Baron Silverlaine", 2750 },
        { "Commander Springvale", 2751 },
        { "Odo the Blindwatcher", 2752 },
        { "Fenrus the Devourer", 2753 },
        { "Wolf Master Nandos", 2754 },
        { "Archmage Arugal", 2755 },
      }
    },
    { 34, -- Stormwind Stockade
      {
        { "Targorr the Dread", 2756 },
        { "Kam Deepfury", 2757 },
        { "Hamhock", 2758 },
        { "Dextren Ward", 2759 },
        { "Bazil Thredd", 2760 },
      }
    },
    { 48, -- Blackfathom Deeps
      {
        { "Ghamoo-ra", 2761, 2916 },
        { "Lady Sarevess", 2762, 2915 },
        { "Geilhast", 2763, 2914 },
        { "Lorgus Jett", 2764, 2913 },
        { "Old Serra'kis", 2765, 2912 },
        { "Twilight Lord Kelris", 2766, 2911 },
        { "Aku'mai", 2767, 2910 },
      }
    },
    { 90, -- Gnomeregan
      {
        { "Grubbis", 2768 },
        { "Viscous Fallout", 2769 },
        { "Electrocutioner 6000", 2770 },
        { "Crowd Pummeler 9-60", 2771 },
        { "Mekgineer Thermaplugg", 2772 },
      }
    },
    { 47, -- Razorfen Kraul
      {
        { "Roogug", 2773 },
        { "Aggem Thorncurse", 2774 },
        { "Death Speaker Jargba", 2775 },
        { "Overlord Ramtusk", 2776 },
        { "Agathelos the Raging", 2777 },
        { "Charlga Razorflank", 2778 },
      }
    },
    { 189, -- Scarlet Monastery
      {
        { "Interrogator Vishas", 444 },
        { "Bloodmage Thalnos", 2779 },
        { "Houndmaster Loksey", 446 },
        { "Arcanist Doan", 447 },
        { "Herod", 448 },
        { "High Inquisitor Fairbanks", 449 },
        { "High Inquisitor Whitemane", 450 },
      }
    },
    { 129, -- Razorfen Downs
      {
        { "Tuten'kash", 2780 },
        { "Plaguemaw the Rotting", 2781 },
        { "Mordresh Fire Eye", 2782 },
        { "Ragglesnout", 2783 },
        { "Glutton", 2784 },
        { "Amnennar the Coldbringer", 2785 },
      }
    },
    { 70, -- Uldaman
      {
        { "Revelosh", 547 },
        { "The Lost Dwarves", 548 },
        { "Ironaya", 549 },
        { "Obsidian Sentinel", 1887 },
        { "Ancient Stone Keeper", 551 },
        { "Galgann Firehammer", 552 },
        { "Grimlok", 553 },
        { "Archaedas", 554 },
      }
    },
    { 209, -- Zul'Farrak
      {
        { "Hydromancer Velratha", 593 },
        { "Gahz'rilla", 594 },
        { "Antu'sul", 595 },
        { "Theka the Martyr", 596 },
        { "Witch Doctor Zum'rah", 597 },
        { "Nekrum Gutchewer", 598 },
        { "Shadowpriest Sezz'ziz", 599 },
        { "Chief Ukorz Sandscalp", 600 },
      }
    },
    { 349, -- Maraudon
      {
        { "Noxxion", 422 },
        { "Razorlash", 423 },
        { "Tinkerer Gizlock", 427 },
        { "Lord Vyletongue", 424 },
        { "Celebras the Cursed", 425 },
        { "Landslide", 426 },
        { "Rotgrip", 428 },
        { "Princess Theradras", 429 },
      }
    },
    { 109, -- Sunken Temple
      {
        { "Avatar of Hakkar", 492, 3583 },
        { "Atal'alarion", 2814, 3582 },
        { "Jammal'an the Prophet", 488, 3589 },
        { "Dreamscythe", 486, 3588 },
        { "Weaver", 487, 3587 },
        { "Shade of Eranikus", 493, 3584 },
        { "Hazzas", 491, 3585 },
        { "Morphaz", 490, 3586 },
      }
    },
    { 230, -- Blackrock Depths
      {
        { "High Interrogator Gerstahn", 227 },
        { "Lord Roccor", 228 },
        { "Houndmaster Grebmar", 229 },
        { "Ring of Law", 230 },
        { "Pyromancer Loregrain", 231 },
        { "Lord Incendius", 232 },
        { "Warder Stilgiss", 233 },
        { "Fineous Darkvire", 234 },
        { "Bael'Gar", 235 },
        { "General Angerforge", 236 },
        { "Golem Lord Argelmach", 237 },
        { "Hurley Blackbreath", 238 },
        { "Phalanx", 239 },
        { "Ribbly Screwspigot", 240 },
        { "Plugger Spazzring", 241 },
        { "The Vault", 2791 },
        { "Ambassador Flamelash", 242 },
        { "The Seven", 243 },
        { "Magmus", 244 },
        { "Princess Moira Bronzebeard", 2789 },
        { "Emperor Dagran Thaurissan", 2790 },
      }
    },
    { 229, -- Blackrock Spire
      {
        { "Highlord Omokk", 267 },
        { "Shadow Hunter Vosh'gajin", 268 },
        { "War Master Voone", 269 },
        { "Mother Smolderweb", 270 },
        { "Urok Doomhowl", 271 },
        { "Quartermaster Zigris", 272 },
        { "Halycon", 274 },
        { "Gizrul the Slavener", 273 },
        { "Overlord Wyrmthalak", 275 },
        { "Pyroguard Emberseer", 3062 },
        { "Warchief Rend Blackhand", 3063 },
        { "The Beast", 3068 },
        { "General Drakkisath", 3069 },
        { "Lord Valthalak", 3070 },
      }
    },
    { 429, -- Dire Maul
      {
        { "Zevrim Thornhoof", 343 },
        { "Hydrospawn", 344 },
        { "Lethtendris", 345 },
        { "Pusillin", 2792 },
        { "Alzzin the Wildshaper", 346 },
        { "Tendris Warpwood", 350 },
        { "Illyanna Ravenoak", 347 },
        { "Magister Kalendris", 348 },
        { "Immol'thar", 349 },
        { "Prince Tortheldrin", 361 },
        { "Guard Mol'dar", 362 },
        { "Stomper Kreeg", 363 },
        { "Guard Fengus", 364 },
        { "Guard Slip'kik", 365 },
        { "Captain Kromcrush", 366 },
        { "Cho'Rush the Observer", 367 },
        { "King Gordok", 368 },
        { "Lord Hel'nurath", 2793 },
        { "Tsu'zee", 2794 },
      }
    },
    { 289, -- Scholomance
      {
        { "Kirtonos", 2805 },
        { "Jandice Barov", 2804 },
        { "Rattlegore", 2811 },
        { "Marduk Blackpool", 2809 },
        { "Vectus", 2813 },
        { "Kormok", 3055 },
        { "Ras Frostwhisperer", 2810 },
        { "Instructor Malicia", 2803 },
        { "Doctor Theolen Krastinov", 2802 },
        { "Lorekeeper Polkelt", 2808 },
        { "The Ravenian", 2812 },
        { "Lord Alexei Barov", 2807 },
        { "Lady Illucia Barov", 2806 },
        { "Darkmaster Gandling", 2801 },
      }
    },
    { 329, -- Stratholme
      {
        { "Hearthsinger Forresten", 473 },
        { "Timmy the Cruel", 474 },
        { "Malor the Zealous", 476 },
        { "Cannon Master Willey", 475 },
        { "Archivist Galford", 477 },
        { "Balnazzar", 478 },
        { "The Unforgiven", 472 },
        { "Baroness Anastari", 479 },
        { "Nerub'enkan", 480 },
        { "Maleki the Pallid", 481 },
        { "Magistrate Barthilas", 482 },
        { "Ramstein the Gorger", 483 },
        { "Baron Rivendare", 484 },
        { "Black Guard Swordsmith", 2795 },
        { "Crimson Hammersmith", 2796 },
        { "Ezra Grimm", 2797 },
        { "Postmaster Malown", 2798 },
        { "Skul", 2799 },
        { "Stonespine", 2800 },
      }
    },
    { 2959, -- City of Dalaran
      {
        { "Arcane Anomaly", 3298 },
        { "Fel Ancient", 3299 },
        { "Mana Devourer", 3300 },
        { "Mana Elemental", 3301 },
        { "Unstable Sentinel", 3302 },
        { "Shade of the Archmage", 3303 },
        { "Lyn the Ignored", 3310 },
        { "Atrexis the Grave Knight", 3311 },
        { "Mana Wraith", 3312 },
      }
    },
    { 2998, -- Excavation Site: Wetlands
      {
        { "Saltspine", 3480 },
        { "Shadetooth", 3481 },
        { "Highland Horror", 3644 },
        { "Relic Guardian", 3482 },
      }
    },
    { 2999, -- Ruins of Lordaeron
      {
        { "Witherfang", 3353 },
        { "The Abandoned", 3357 },
        { "The Butcher", 3355 },
        { "Rath'mael", 3354 },
        { "Lordaeron Captain", 3408 },
        { "Viktor the Vile", 3411 },
        { "Bjork", 3412 },
      }
    },
    { 3065, -- The Hall of Thanes
      {
        { "Faldrim Anvilmar", 3493 },
        { "Infurnus", 3495 },
        { "Plunder", 3494 },
        { "Durgen Dirgehammer", 3496 },
      }
    },
  }

  local function AddInstance(name, bosses)
    encounter_list = ("%s" .. Private.Style.Hex("primary") .. "%s|r\n"):format(encounter_list, name)
    for _, boss in ipairs(bosses) do
      encounter_list = ("%s%s: %s\n"):format(encounter_list, boss[1], table.concat(boss, ", ", 2))
    end
    encounter_list = encounter_list .. "\n"
  end
  for _, raid in ipairs(raids) do
    AddInstance(raid[1], raid[2])
  end
  for _, dungeon in ipairs(dungeons) do
    AddInstance(GetRealZoneText(dungeon[1]), dungeon[2])
  end

  encounter_list = encounter_list:sub(1, -3) .. "\n\n" .. L["Supports multiple entries, separated by commas\n"]
end

function Private.get_encounters_list()
  return encounter_list
end

function Private.get_zoneId_list()
  -- The zone ID option already lists the current zone, parent zone and instance (Prototypes.lua).
  return ""
end

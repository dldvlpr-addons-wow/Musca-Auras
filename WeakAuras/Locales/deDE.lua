if (GAME_LOCALE or GetLocale()) ~= "deDE" then
  return
end

local L = WeakAuras.L

-- WeakAuras
L[ [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=] ] = "Filter format:  'Name', 'Name-Realm', '-Realm'. Unterstützt mehrfacheinträge welche durch Kommas getrennt werden. Verwende \\ um - zu escapen."
L["%s Overlay Color"] = "%s Overlay Farbe"
L["* Suffix"] = "* Suffix"
L["/wa help - Show this message"] = "/wa help - Zeige diese Nachricht"
L["/wa minimap - Toggle the minimap icon"] = "/wa minimap - Anzeige des Minimap-Icons umschalten"
L["/wa pprint - Show the results from the most recent profiling"] = "/wa pprint - Zeigt das Ergebnis des aktuellsten Profilings an"
L["/wa pstart - Start profiling. Optionally include a duration in seconds after which profiling automatically stops. To profile the next combat/encounter, pass a \"combat\" or \"encounter\" argument."] = "/wa pstart - Startet das Profiling. Optional kann eine Dauer in Sekunden angegeben werden, nachdem das Profiling automatisch gestoppt wird. Um den nächsten Kampf zu loggen, füge combat oder encounter hinzu, also z.B. \"/wa pstart combat\""
L["/wa pstop - Finish profiling"] = "/wa pstop - beendet das Pofiling"
L["/wa repair - Repair tool"] = "/wa repair - Reparierwerkzeug"
L["|cffeda55fLeft-Click|r to toggle showing the main window."] = "|cffeda55fLink-Klick|r um das Anzeigen des Hauptfensters umzuschalten."
L["|cffeda55fMiddle-Click|r to toggle the minimap icon on or off."] = "|cffeda55fMittlere Maustaste|r um das Minimapsymbol an oder auszuschalten."
--[[Translation missing --]]
L["|cffeda55fRight-Click|r to toggle performance profiling window."] = "|cffeda55fRight-Click|r to toggle performance profiling window."
--[[Translation missing --]]
L["|cffeda55fShift-Click|r to pause addon execution."] = "|cffeda55fShift-Click|r to pause addon execution."
--[[Translation missing --]]
L["|cffff0000deprecated|r"] = "|cffff0000deprecated|r"
--[[Translation missing --]]
L["|cFFFF0000Not|r Item Bonus Id Equipped"] = "|cFFFF0000Not|r Item Bonus Id Equipped"
--[[Translation missing --]]
L["|cFFFF0000Not|r Item Equipped"] = "|cFFFF0000Not|r Item Equipped"
--[[Translation missing --]]
L["|cFFFF0000Not|r Player Name/Realm"] = "|cFFFF0000Not|r Player Name/Realm"
--[[Translation missing --]]
L["|cFFFF0000Not|r Spell Known"] = "|cFFFF0000Not|r Spell Known"
--[[Translation missing --]]
L[ [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=] ] = [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=]
--[[Translation missing --]]
L["|cFFffcc00Extra Options:|r %s"] = "|cFFffcc00Extra Options:|r %s"
--[[Translation missing --]]
L["|cFFffcc00Extra Options:|r None"] = "|cFFffcc00Extra Options:|r None"
--[[Translation missing --]]
L[ [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=] ] = [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=]
--[[Translation missing --]]
L["1. Profession 1. Accessory"] = "1. Profession 1. Accessory"
--[[Translation missing --]]
L["1. Profession 2. Accessory"] = "1. Profession 2. Accessory"
--[[Translation missing --]]
L["1. Professsion Tool"] = "1. Professsion Tool"
L["10 Man Raid"] = "10-Mann-Schlachtzug"
--[[Translation missing --]]
L["10 Player Raid"] = "10 Player Raid"
L["10 Player Raid (Heroic)"] = "10 Spieler Schlachtzug (Heroisch)"
L["10 Player Raid (Normal)"] = "10 Spieler Schlachtzug (Normal)"
--[[Translation missing --]]
L["2. Profession 1. Accessory"] = "2. Profession 1. Accessory"
--[[Translation missing --]]
L["2. Profession 2. Accessory"] = "2. Profession 2. Accessory"
--[[Translation missing --]]
L["2. Professsion Tool"] = "2. Professsion Tool"
L["20 Man Raid"] = "20-Mann-Schlachtzug"
--[[Translation missing --]]
L["20 Player Raid"] = "20 Player Raid"
L["25 Man Raid"] = "25-Mann-Schlachtzug"
L["25 Player Raid"] = "25 Spieler Schlachtzug"
L["25 Player Raid (Heroic)"] = "25 Spieler Schlachtzug (Heroisch)"
L["25 Player Raid (Normal)"] = "25 Spieler Schlachtzug (Normal)"
--[[Translation missing --]]
L["25 Player Raid (Titan Reforged)"] = "25 Player Raid (Titan Reforged)"
L["40 Man Raid"] = "40-Mann-Schlachtzug"
L["40 Player Raid"] = "40 Spieler Schlachtzug"
L["5 Man Dungeon"] = "5-Mann-Dungeon"
--[[Translation missing --]]
L[ [=[A detailed overview of your auras and Musca Auras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=] ] = [=[A detailed overview of your auras and Musca Auras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=]
--[[Translation missing --]]
L["A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."] = "A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."
--[[Translation missing --]]
L["Abbreviate"] = "Abbreviate"
--[[Translation missing --]]
L["AbbreviateLargeNumbers (Blizzard)"] = "AbbreviateLargeNumbers (Blizzard)"
--[[Translation missing --]]
L["AbbreviateNumbers (Blizzard)"] = "AbbreviateNumbers (Blizzard)"
L["Absorb"] = "Absorbieren"
--[[Translation missing --]]
L["Absorb and Healing"] = "Absorb and Healing"
L["Absorbed"] = "Absorbiert"
--[[Translation missing --]]
L["Action Button Glow"] = "Action Button Glow"
L["Actions"] = "Aktionen"
L["Active"] = "Aktiv"
--[[Translation missing --]]
L[ [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L[ [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
L["Add"] = "Hinzufügen"
L["Add Missing Auras"] = "Fehlende Auren hinzufügen"
--[[Translation missing --]]
L["Advanced Caster's Target Check"] = "Advanced Caster's Target Check"
L["Affected"] = "Betroffen"
L["Affected Unit Count"] = "Anzahl betroffener Einheiten"
L["Afk"] = "Afk"
L["Aggro"] = "Aggro (Bedrohung)"
L["Agility"] = "Beweglichkeit"
L["Ahn'Qiraj"] = "Ahn'Qiraj"
--[[Translation missing --]]
L["Alert Type"] = "Warnungstyp"
L["Alive"] = "am Leben"
L["All"] = "Alle"
--[[Translation missing --]]
L["All children of this aura will also not be loaded, to minimize the chance of further corruption."] = "All children of this aura will also not be loaded, to minimize the chance of further corruption."
--[[Translation missing --]]
L["All States table contains a non table at key: '%s'."] = "All States table contains a non table at key: '%s'."
L["All Triggers"] = "Alle Auslöser (UND)"
L["Alliance"] = "Allianz"
L["Alpha"] = "Alpha"
L["Always"] = "Immer"
L["Always active trigger"] = "Immer aktiver Auslöser"
L["Always include realm"] = "Immer Realm einschließen"
L["Always True"] = "Immer Richtig"
L["Amount"] = "Anzahl"
--[[Translation missing --]]
L["Anchoring"] = "Anchoring"
L["And Talent"] = "Und Talent"
--[[Translation missing --]]
L["Angle and Radius"] = "Angle and Radius"
L["Animations"] = "Animationen"
L["Anticlockwise"] = "Im Gegenuhrzeigersinn"
--[[Translation missing --]]
L["Anub'Rekhan"] = "Anub'Rekhan"
--[[Translation missing --]]
L["Any"] = "Any"
L["Any Triggers"] = "Ein Auslöser (ODER)"
--[[Translation missing --]]
L["AOE"] = "AOE"
--[[Translation missing --]]
L["Arcane Resistance"] = "Arcane Resistance"
--[[Translation missing --]]
L[ [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=] ] = [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=]
L["Arena"] = "Arena"
--[[Translation missing --]]
L["Armor Rating"] = "Armor Rating"
--[[Translation missing --]]
L["Array"] = "Array"
L["Ascending"] = "Aufsteigend"
L["Assigned Role"] = "Zugewiesene Rolle"
--[[Translation missing --]]
L["Assigned Role Icon"] = "Assigned Role Icon"
--[[Translation missing --]]
L["Assist"] = "Assist"
L["At Least One Enemy"] = "Zumindest ein Feind"
L["At missing Value"] = "Bei fehlendem Wert"
L["At Percent"] = "Bei Prozent"
L["At Value"] = "Bei Wert"
--[[Translation missing --]]
L["At War"] = "At War"
L["Attach to End"] = "am Ende befestigen"
--[[Translation missing --]]
L["Attach to End, backwards"] = "Attach to End, backwards"
--[[Translation missing --]]
L["Attach to Point"] = "Attach to Point"
L["Attach to Start"] = "am Anfang befestigen"
L["Attack Power"] = "Angriffskraft"
L["Attackable"] = "Angreifbar"
L["Attackable Target"] = "Angreifbares Ziel"
--[[Translation missing --]]
L["Aura"] = "Aura (Buff/Debuff)"
--[[Translation missing --]]
L["Aura '%s': %s"] = "Aura '%s': %s"
L["Aura Applied"] = "Aura angewandt (AURA_APPLIED)"
L["Aura Applied Dose"] = "Aura angewandt, Stapel erhöht (AURA_APPLIED_DOSE)"
L["Aura Broken"] = "Aura gebrochen, Nahkampf (AURA_BROKEN)"
L["Aura Broken Spell"] = "Aura gebrochen, Zauber (AURA_BROKEN_SPELL)"
--[[Translation missing --]]
L["Aura is using deprecated SetDurationInfo"] = "Aura is using deprecated SetDurationInfo"
--[[Translation missing --]]
L["Aura loaded"] = "Aura loaded"
L["Aura Name"] = "Auraname oder -ID"
L["Aura Names"] = "Aura Namen"
L["Aura Refresh"] = "Aura erneuert (AURA_REFRESH)"
L["Aura Removed"] = "Aura entfernt (AURA_REMOVED)"
L["Aura Removed Dose"] = "Aura entfernt, Stack verringert (AURA_REMOVED_DOSE)"
L["Aura Stack"] = "Aurastapel"
L["Aura Type"] = "Auratyp"
--[[Translation missing --]]
L["Aura Version: %s"] = "Aura Version: %s"
L["Aura(s) Found"] = "Auren gefunden"
L["Aura(s) Missing"] = "Auren fehlend"
L["Aura:"] = "Aura:"
--[[Translation missing --]]
L["Auras"] = "Auras"
L["Auras:"] = "Auren:"
--[[Translation missing --]]
L["Author Options"] = "Author Options"
--[[Translation missing --]]
L["Auto"] = "Auto"
--[[Translation missing --]]
L["Autocast Shine"] = "Autocast Shine"
L["Automatic"] = "Automatisch"
--[[Translation missing --]]
L["Automatic Length"] = "Automatic Length"
L["Automatic Rotation"] = "Automatische Rotation"
--[[Translation missing --]]
L["Available features: %s"] = "Available features: %s"
--[[Translation missing --]]
L["Ayamiss the Hunter"] = "Ayamiss the Hunter"
--[[Translation missing --]]
L["Azuregos"] = "Azuregos"
L["Back and Forth"] = "Vor und zurück"
L["Background"] = "Hintergrund"
L["Background Color"] = "Hintergrundfarbe"
--[[Translation missing --]]
L["Balnazzar"] = "Balnazzar"
--[[Translation missing --]]
L["Bar"] = "Bar"
--[[Translation missing --]]
L["Bar and Icon"] = "Bar and Icon"
--[[Translation missing --]]
L["Bar Color/Gradient Start"] = "Bar Color/Gradient Start"
--[[Translation missing --]]
L["Bar enabled in BigWigs settings"] = "Bar enabled in BigWigs settings"
--[[Translation missing --]]
L["Bar enabled in Boss Mod addon settings"] = "Bar enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Bar enabled in DBM settings"] = "Bar enabled in DBM settings"
--[[Translation missing --]]
L["Bar Texture"] = "Bar Texture"
--[[Translation missing --]]
L["Bar Type"] = "Bar Type"
--[[Translation missing --]]
L["Baron Geddon"] = "Baron Geddon"
--[[Translation missing --]]
L["Battle for Azeroth"] = "Battle for Azeroth"
L["Battle.net Whisper"] = "Battle.net-Flüster"
L["Battleground"] = "Schlachtfeld"
--[[Translation missing --]]
L["Battleguard Sartura"] = "Battleguard Sartura"
--[[Translation missing --]]
L["Beastmaster"] = "Beastmaster"
--[[Translation missing --]]
L["Beatrix"] = "Beatrix"
--[[Translation missing --]]
L["BG>Raid>Party>Say"] = "BG>Raid>Party>Say"
L["BG-System Alliance"] = "BG-System Allianz"
L["BG-System Horde"] = "BG-System Horde"
L["BG-System Neutral"] = "BG-System Neutral"
--[[Translation missing --]]
L["Big Number"] = "Big Number"
L["BigWigs Addon"] = "BigWigs-Addon"
L["BigWigs Message"] = "BigWigs-Nachricht"
--[[Translation missing --]]
L["BigWigs Stage"] = "BigWigs Stage"
L["BigWigs Timer"] = "BigWigs-Timer"
--[[Translation missing --]]
L["Black Wing Lair"] = "Pechschwingenhort"
--[[Translation missing --]]
L["Bleed"] = "Bleed"
L["Blizzard Combat Text"] = "Kampflog"
--[[Translation missing --]]
L["Blizzard Cooldown Reduction"] = "Blizzard Cooldown Reduction"
L["Block"] = "Blocken"
--[[Translation missing --]]
L["Block (%)"] = "Block (%)"
--[[Translation missing --]]
L["Block Value"] = "Block Value"
L["Blocked"] = "Geblockt"
--[[Translation missing --]]
L["Bloodlord Mandokir"] = "Bloodlord Mandokir"
L["Border"] = "Rahmen"
L["Boss"] = "Boss"
L["Boss Emote"] = "Bossemote"
--[[Translation missing --]]
L["Boss Mod Announce"] = "Boss Mod Announce"
--[[Translation missing --]]
L["Boss Mod Stage"] = "Boss Mod Stage"
--[[Translation missing --]]
L["Boss Mod Stage (Event)"] = "Boss Mod Stage (Event)"
--[[Translation missing --]]
L["Boss Mod Timer"] = "Boss Mod Timer"
L["Boss Whisper"] = "Bossflüstern"
L["Bottom"] = "Unten"
L["Bottom Left"] = "Unten Links"
L["Bottom Right"] = "Unten Rechts"
L["Bottom to Top"] = "Unten -> Oben"
L["Bounce"] = "Hüpfen"
L["Bounce with Decay"] = "Abklingendes Hüpfen"
--[[Translation missing --]]
L["Break"] = "Break"
--[[Translation missing --]]
L["BreakUpLargeNumbers (Blizzard)"] = "BreakUpLargeNumbers (Blizzard)"
--[[Translation missing --]]
L["Broodlord Lashlayer"] = "Broodlord Lashlayer"
--[[Translation missing --]]
L["Buff"] = "Buff"
L["Buff/Debuff"] = "Stärkungs-/Schwächungszauber"
L["Buffed/Debuffed"] = "Buffed/Debuffed"
L["Burning Crusade"] = "Burning Crusade"
--[[Translation missing --]]
L["Buru the Gorger"] = "Buru the Gorger"
--[[Translation missing --]]
L["Caldoran"] = "Caldoran"
--[[Translation missing --]]
L["Callback function"] = "Callback function"
L["Can be used for e.g. checking if \"boss1target\" is the same as \"player\"."] = "Kann genutzt werden um z.B zu checken ob \"Ziel\" dieselbe Einheit ist wie \"Spieler\""
L["Cancel"] = "Abbrechen"
--[[Translation missing --]]
L[ [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."] = "Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."
--[[Translation missing --]]
L["Capped"] = "Capped"
L["Cast"] = "Zauberwirken"
L["Cast Bar"] = "Zauberleiste"
L["Cast Failed"] = "Zauber fehlgeschlagen (CAST_FAILED)"
L["Cast Start"] = "Zauber gestartet (CAST_START)"
L["Cast Success"] = "Zauber gelungen (CAST_SUCCESS)"
L["Cast Type"] = "Zaubertyp"
L["Caster"] = "Zauberwirker"
--[[Translation missing --]]
L["Caster Name"] = "Caster Name"
--[[Translation missing --]]
L["Caster Realm"] = "Caster Realm"
--[[Translation missing --]]
L["Caster Unit"] = "Caster Unit"
--[[Translation missing --]]
L["Casters Name/Realm"] = "Casters Name/Realm"
--[[Translation missing --]]
L["Caster's Target"] = "Caster's Target"
--[[Translation missing --]]
L["Cataclysm"] = "Cataclysm"
--[[Translation missing --]]
L["Ceil"] = "Ceil"
L["Center"] = "Mitte"
--[[Translation missing --]]
L["Center, then alternating bottom and top"] = "Center, then alternating bottom and top"
--[[Translation missing --]]
L["Center, then alternating left and right"] = "Center, then alternating left and right"
--[[Translation missing --]]
L["Center, then alternating right and left"] = "Center, then alternating right and left"
--[[Translation missing --]]
L["Center, then alternating top and bottom"] = "Center, then alternating top and bottom"
L["Centered Horizontal"] = "Horizontal-Zentriert"
--[[Translation missing --]]
L["Centered Horizontal, then Centered Vertical"] = "Centered Horizontal, then Centered Vertical"
--[[Translation missing --]]
L["Centered Horizontal, then Down"] = "Centered Horizontal, then Down"
--[[Translation missing --]]
L["Centered Horizontal, then Up"] = "Centered Horizontal, then Up"
L["Centered Vertical"] = "Vertikal zentriert"
--[[Translation missing --]]
L["Centered Vertical, then Centered Horizontal"] = "Centered Vertical, then Centered Horizontal"
--[[Translation missing --]]
L["Centered Vertical, then Left"] = "Centered Vertical, then Left"
--[[Translation missing --]]
L["Centered Vertical, then Right"] = "Centered Vertical, then Right"
L["Changed"] = "Verändert"
L["Channel"] = "Chatkanal"
L["Channel (Spell)"] = "Kanalisieren (Zauber)"
L["Character Stats"] = "Charakterwerte"
L["Character Type"] = "Charaktertyp"
L["Charge gained/lost"] = "Aufladung erhalten/verloren"
L["Charges"] = "Aufladungen"
--[[Translation missing --]]
L["Charges Changed Event"] = "Charges Changed Event"
L["Chat Frame"] = "Chatfenster"
L["Chat Message"] = "Chatnachricht"
--[[Translation missing --]]
L["Check if a single talent match a Rank"] = "Check if a single talent match a Rank"
--[[Translation missing --]]
L["Check nameplate's target every 0.2s"] = "Check nameplate's target every 0.2s"
--[[Translation missing --]]
L["Chromaggus"] = "Chromaggus"
L["Circle"] = "Kreis"
--[[Translation missing --]]
L["Circular Texture"] = "Circular Texture"
--[[Translation missing --]]
L["Clamp"] = "Clamp"
L["Class"] = "Klasse"
L["Class and Specialization"] = "Klasse und Spezialisierung"
--[[Translation missing --]]
L["Classic"] = "Classic"
L["Classification"] = "Klassifizierung"
L["Clockwise"] = "Im Uhrzeigersinn"
L["Clone per Event"] = "Klonen pro Event"
L["Clone per Match"] = "Klonen pro Treffer"
--[[Translation missing --]]
L["Coin Precision"] = "Coin Precision"
L["Color"] = "Farbe"
--[[Translation missing --]]
L["Color Animation"] = "Color Animation"
L["Combat Log"] = "Kampflog"
--[[Translation missing --]]
L["Communities"] = "Communities"
--[[Translation missing --]]
L["Condition Custom Test"] = "Condition Custom Test"
L["Conditions"] = "Bedingungen"
L["Contains"] = "Enthält"
--[[Translation missing --]]
L["Continuously update Movement Speed"] = "Continuously update Movement Speed"
L["Cooldown"] = "Abklingzeit"
--[[Translation missing --]]
L["Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"] = "Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"
L["Cooldown Progress (Item)"] = "Abklingzeit (Gegenstand)"
--[[Translation missing --]]
L["Cooldown Progress (Slot)"] = "Cooldown Progress (Slot)"
--[[Translation missing --]]
L["Cooldown Ready Event"] = "Cooldown Ready Event"
--[[Translation missing --]]
L["Cooldown Ready Event (Item)"] = "Cooldown Ready Event (Item)"
--[[Translation missing --]]
L["Cooldown Ready Event (Slot)"] = "Cooldown Ready Event (Slot)"
--[[Translation missing --]]
L["Cooldown Reduction changes the duration of seconds instead of showing the real time seconds."] = "Cooldown Reduction changes the duration of seconds instead of showing the real time seconds."
--[[Translation missing --]]
L["Cooldown/Charges/Count"] = "Cooldown/Charges/Count"
--[[Translation missing --]]
L["Copper"] = "Copper"
--[[Translation missing --]]
L["Could not load Musca Auras Archive, the addon is %s"] = "Could not load Musca Auras Archive, the addon is %s"
L["Count"] = "Anzahl"
L["Counter Clockwise"] = "Gegen den Uhrzeigersinn"
L["Create"] = "Erstellen"
L["Critical"] = "Kritisch"
--[[Translation missing --]]
L["Critical (%)"] = "Critical (%)"
--[[Translation missing --]]
L["Crop X"] = "Crop X"
--[[Translation missing --]]
L["Crop Y"] = "Crop Y"
L["Crowd Controlled"] = "Kontrollverlust"
L["Crushing"] = "Zerschmettern"
--[[Translation missing --]]
L["C'thun"] = "C'thun"
--[[Translation missing --]]
L["Cumulated time used during profiling"] = "Cumulated time used during profiling"
--[[Translation missing --]]
L["Current Experience"] = "Current Experience"
--[[Translation missing --]]
L["Current Instance"] = "Current Instance"
--[[Translation missing --]]
L["Current Movement Speed (%)"] = "Current Movement Speed (%)"
--[[Translation missing --]]
L["Current Zone"] = "Current Zone"
--[[Translation missing --]]
L["Current Zone Group"] = "Current Zone Group"
L["Curse"] = "Fluch"
L["Custom"] = "Benutzerdefiniert"
--[[Translation missing --]]
L["Custom Action"] = "Custom Action"
--[[Translation missing --]]
L["Custom Anchor"] = "Custom Anchor"
--[[Translation missing --]]
L["Custom Check"] = "Custom Check"
--[[Translation missing --]]
L["Custom Color"] = "Custom Color"
--[[Translation missing --]]
L["Custom Condition Code"] = "Custom Condition Code"
--[[Translation missing --]]
L["Custom Configuration"] = "Custom Configuration"
--[[Translation missing --]]
L["Custom Fade Animation"] = "Custom Fade Animation"
L["Custom Function"] = "Benutzerdefiniert"
--[[Translation missing --]]
L["Custom Grow"] = "Custom Grow"
--[[Translation missing --]]
L["Custom Sort"] = "Custom Sort"
--[[Translation missing --]]
L["Custom Text Function"] = "Custom Text Function"
--[[Translation missing --]]
L["Custom Trigger Combination"] = "Custom Trigger Combination"
--[[Translation missing --]]
L["Custom Variables"] = "Custom Variables"
L["Damage"] = "Schaden (DAMAGE)"
L["Damage Shield"] = "Schadensschild (DAMAGE_SHIELD)"
L["Damage Shield Missed"] = "Schadensschild verfehlt (DAMAGE_SHIELD_MISSED)"
L["Damage Split"] = "Schadensteilung (DAMAGE_SPLIT)"
L["DBM Announce"] = "DBM Meldung"
--[[Translation missing --]]
L["DBM Stage"] = "DBM Stage"
L["DBM Timer"] = "DBM-Timer"
--[[Translation missing --]]
L["Dead"] = "Dead"
L["Debuff"] = "Debuff"
L["Debuff Class"] = "Schwächungszauber Klasse"
L["Debuff Class Icon"] = "Schwächungszauber Klassensymbol"
L["Debuff Type"] = "Schwächungszaubertyp"
--[[Translation missing --]]
L["Debug Log contains more than 1000 entries"] = "Debug Log contains more than 1000 entries"
--[[Translation missing --]]
L["Debug Logging enabled"] = "Debug Logging enabled"
--[[Translation missing --]]
L["Debug Logging enabled for '%s'"] = "Debug Logging enabled for '%s'"
--[[Translation missing --]]
L["Defensive Stats"] = "Defensive Stats"
L["Deflect"] = "Umlenken"
--[[Translation missing --]]
L["Delve"] = "Delve"
L["Desaturate"] = "Entsättigen"
L["Desaturate Background"] = "Hintergrund entsättigen"
L["Desaturate Foreground"] = "Vordergrund entsättigen"
L["Descending"] = "Absteigend"
L["Description"] = "Beschreibung"
L["Dest Raid Mark"] = "Zielmarkierung"
--[[Translation missing --]]
L["Destination Affiliation"] = "Destination Affiliation"
--[[Translation missing --]]
L["Destination GUID"] = "Destination GUID"
--[[Translation missing --]]
L["Destination Info"] = "Destination Info"
L["Destination Name"] = "Zielname"
--[[Translation missing --]]
L["Destination NPC Id"] = "Destination NPC Id"
--[[Translation missing --]]
L["Destination Object Type"] = "Destination Object Type"
--[[Translation missing --]]
L["Destination Reaction"] = "Destination Reaction"
L["Destination Unit"] = "Zieleinheit"
--[[Translation missing --]]
L["Destination unit's raid mark index"] = "Destination unit's raid mark index"
--[[Translation missing --]]
L["Destination unit's raid mark texture"] = "Destination unit's raid mark texture"
L["Difficulty"] = "Schwierigkeit"
--[[Translation missing --]]
L["Disable Spell Known Check"] = "Disable Spell Known Check"
--[[Translation missing --]]
L["Disabled"] = "Disabled"
--[[Translation missing --]]
L["Disabled feature %q"] = "Disabled feature %q"
--[[Translation missing --]]
L["Disabled Spell Known Check"] = "Disabled Spell Known Check"
L["Disease"] = "Krankheit"
L["Dispel"] = "Bannen (DISPEL)"
L["Dispel Failed"] = "Bannen fehlgeschlagen (DISPEL_FAILED)"
L["Display"] = "Anzeige"
L["Distance"] = "Distanz"
L["Do Not Disturb"] = "Bitte nicht stören"
L["Dodge"] = "Ausweichen (DODGE)"
L["Dodge (%)"] = "Ausweichen (%)"
--[[Translation missing --]]
L["Down"] = "Runter"
--[[Translation missing --]]
L["Down, then Centered Horizontal"] = "Down, then Centered Horizontal"
L["Down, then Left"] = "Runter, dann links"
L["Down, then Right"] = "Runter, dann rechts"
L["Dragonflight"] = "Dragonflight"
L["Drain"] = "Saugen (DRAIN)"
L["Dropdown Menu"] = "Auswahlmenü"
--[[Translation missing --]]
L["Dumping table"] = "Dumping table"
L["Dungeon (Heroic)"] = "Dungeon (Heroisch)"
--[[Translation missing --]]
L["Dungeon (Mythic)"] = "Dungeon (Mythic)"
--[[Translation missing --]]
L["Dungeon (Mythic+)"] = "Dungeon (Mythic+)"
L["Dungeon (Normal)"] = "Dungeon (Normal)"
L["Dungeon (Timewalking)"] = "Dungeon (Zeitwanderung)"
L["Durability Damage"] = "Haltbarkeitsschaden (DURABILITY_DAMAGE)"
L["Durability Damage All"] = "Haltbarkeitsschaden, Alle (DURABILITY_DAMAGE_ALL)"
--[[Translation missing --]]
L["Duration"] = "Duration"
--[[Translation missing --]]
L["Duration Function"] = "Duration Function"
--[[Translation missing --]]
L["Duration Function (fallback state)"] = "Duration Function (fallback state)"
--[[Translation missing --]]
L["Ease In"] = "Ease In"
--[[Translation missing --]]
L["Ease In and Out"] = "Ease In and Out"
--[[Translation missing --]]
L["Ease Out"] = "Ease Out"
--[[Translation missing --]]
L["Ebonroc"] = "Ebonroc"
L["Edge"] = "Ecke"
--[[Translation missing --]]
L["Edge of Madness"] = "Edge of Madness"
--[[Translation missing --]]
L["Effective Spell Id"] = "Effective Spell Id"
--[[Translation missing --]]
L["Elide"] = "Elide"
L["Elite"] = "Elite"
--[[Translation missing --]]
L["Emote"] = "Emote"
--[[Translation missing --]]
L["Empower Cast End"] = "Empower Cast End"
--[[Translation missing --]]
L["Empower Cast Interrupt"] = "Empower Cast Interrupt"
--[[Translation missing --]]
L["Empower Cast Start"] = "Empower Cast Start"
--[[Translation missing --]]
L["Empowered"] = "Empowered"
L["Empty"] = "Leer"
--[[Translation missing --]]
L["Enabled feature %q"] = "Enabled feature %q"
--[[Translation missing --]]
L["Enables (incorrect) round down of seconds, which was the previous default behavior."] = "Enables (incorrect) round down of seconds, which was the previous default behavior."
--[[Translation missing --]]
L["Enchant Applied"] = "Enchant Applied"
--[[Translation missing --]]
L["Enchant Found"] = "Enchant Found"
--[[Translation missing --]]
L["Enchant ID"] = "Enchant ID"
--[[Translation missing --]]
L["Enchant Missing"] = "Enchant Missing"
--[[Translation missing --]]
L["Enchant Name or ID"] = "Enchant Name or ID"
--[[Translation missing --]]
L["Enchant Removed"] = "Enchant Removed"
--[[Translation missing --]]
L["Enchanted"] = "Enchanted"
--[[Translation missing --]]
L["Encounter ID(s)"] = "Encounter ID(s)"
L["Energize"] = "Aufladen (ENERGIZE)"
L["Enrage"] = "Wut"
--[[Translation missing --]]
L["Enter a name or a spellId"] = "Enter a name or a spellId"
L["Entering"] = "Betreten"
L["Entering/Leaving Combat"] = "Kampf Betreten/Verlassen"
--[[Translation missing --]]
L["Entering/Leaving Encounter"] = "Entering/Leaving Encounter"
L["Entry Order"] = "Eintragsreihenfolge"
L["Environment Type"] = "Umgebungstyp"
L["Environmental"] = "Umgebung (ENVIRONMENTAL)"
--[[Translation missing --]]
L["Equipment"] = "Equipment"
L["Equipment Slot"] = "Ausrüstungsplatz"
L["Equipped"] = "Angelegt"
--[[Translation missing --]]
L["Error"] = "Fehler"
--[[Translation missing --]]
L[ [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Error decoding."] = "Error decoding."
--[[Translation missing --]]
L["Error decompressing"] = "Error decompressing"
--[[Translation missing --]]
L["Error decompressing. This doesn't look like a Musca Auras import."] = "Error decompressing. This doesn't look like a Musca Auras import."
--[[Translation missing --]]
L["Error deserializing"] = "Error deserializing"
L["Error Frame"] = "Fehlerfenster"
--[[Translation missing --]]
L["ERROR in '%s' unknown or incompatible sub element type '%s'"] = "ERROR in '%s' unknown or incompatible sub element type '%s'"
--[[Translation missing --]]
L["Error in Aura '%s'"] = "Error in Aura '%s'"
--[[Translation missing --]]
L["Error not receiving display information from %s"] = "Error not receiving display information from %s"
L["Evade"] = "Entkommen (EVADE)"
L["Event"] = "Ereignis"
L["Event(s)"] = "Ereignis(se)"
L["Every Frame"] = "Bei jedem OnUpdate"
--[[Translation missing --]]
L["Every Frame (High CPU usage)"] = "Every Frame (High CPU usage)"
--[[Translation missing --]]
L["Exact Spell ID(s)"] = "Exact Spell ID(s)"
--[[Translation missing --]]
L["Execute Conditions"] = "Execute Conditions"
--[[Translation missing --]]
L["Experience (%)"] = "Experience (%)"
--[[Translation missing --]]
L["Extend Outside"] = "Extend Outside"
L["Extra Amount"] = "Extrabetrag"
L["Extra Attacks"] = "Extraangriffe (EXTRA_ATTACKS)"
--[[Translation missing --]]
L["Extra Spell Id"] = "Extra Spell Id"
L["Extra Spell Name"] = "Extra-Zaubername"
L["Faction"] = "Fraktion"
--[[Translation missing --]]
L["Faction Name"] = "Fraktionsname"
L["Faction Reputation"] = "Fraktionsruf"
--[[Translation missing --]]
L["Fade Animation"] = "Fade Animation"
L["Fade In"] = "Einblenden"
L["Fade Out"] = "Ausblenden"
L["Fail Alert"] = "Warnung für Fehlschlag"
L["False"] = "Nicht Zutrifft"
--[[Translation missing --]]
L["Fankriss the Unyielding"] = "Fankriss the Unyielding"
--[[Translation missing --]]
L["Feature %q is already disabled"] = "Feature %q is already disabled"
--[[Translation missing --]]
L["Feature %q is already enabled"] = "Feature %q is already enabled"
--[[Translation missing --]]
L["Fill Area"] = "Fill Area"
--[[Translation missing --]]
L["Filter messages with format <message>"] = "Filter messages with format <message>"
L["Fire Resistance"] = "Feuerwiderstand"
--[[Translation missing --]]
L["Firemaw"] = "Firemaw"
--[[Translation missing --]]
L["First"] = "First"
--[[Translation missing --]]
L["First Value of Tooltip Text"] = "First Value of Tooltip Text"
L["Fixed"] = "Fixiert"
--[[Translation missing --]]
L["Fixed Names"] = "Fixed Names"
L["Fixed Size"] = "Feste Größe"
--[[Translation missing --]]
L["Flamegor"] = "Flamegor"
L["Flash"] = "Aufblitzen"
L["Flex Raid"] = "Flexibler Schlachtzug"
L["Flip"] = "Umdrehen"
L["Floor"] = "Flur"
--[[Translation missing --]]
L["Follower Dungeon"] = "Follower Dungeon"
--[[Translation missing --]]
L["Font"] = "Font"
L["Font Size"] = "Schriftgröße"
--[[Translation missing --]]
L["Forbidden function or table: %s"] = "Forbidden function or table: %s"
L["Foreground"] = "Vordergrund"
L["Foreground Color"] = "Vordergrundfarbe"
L["Form"] = "Form"
--[[Translation missing --]]
L["Format"] = "Format"
--[[Translation missing --]]
L["Format Gold"] = "Format Gold"
--[[Translation missing --]]
L["Formats |cFFFFCC00%unit|r"] = "Formats |cFFFFCC00%unit|r"
--[[Translation missing --]]
L["Formats Player's |cFFFFCC00%guid|r"] = "Formats Player's |cFFFFCC00%guid|r"
L["Forward"] = "Vorwärts"
--[[Translation missing --]]
L["Forward, Reverse Loop"] = "Forward, Reverse Loop"
--[[Translation missing --]]
L["Fourth Value of Tooltip Text"] = "Fourth Value of Tooltip Text"
--[[Translation missing --]]
L["Frame Selector"] = "Frame Selector"
L["Frequency"] = "Häufigkeit"
L["Friendly"] = "Freundlich"
L["Friendly Fire"] = "Eigenbeschuss"
--[[Translation missing --]]
L["Frost"] = "Frost"
L["Frost Resistance"] = "Frostwiderstand"
L["Full"] = "Voll"
--[[Translation missing --]]
L["Full Region"] = "Full Region"
L["Full/Empty"] = "Voll/Leer"
--[[Translation missing --]]
L["Gahz'ranka"] = "Gahz'ranka"
L["Gained"] = "Erhalten "
--[[Translation missing --]]
L["Garr"] = "Garr"
--[[Translation missing --]]
L["Gehennas"] = "Gehennas"
--[[Translation missing --]]
L["General"] = "General"
--[[Translation missing --]]
L["General Rajaxx"] = "General Rajaxx"
--[[Translation missing --]]
L["GetNameAndIcon Function (fallback state)"] = "GetNameAndIcon Function (fallback state)"
L["Glancing"] = "Gestreift (GLANCING)"
L["Global Cooldown"] = "Globale Abklingzeit"
L["Glow"] = "Leuchten"
--[[Translation missing --]]
L["Glow External Element"] = "Glow External Element"
--[[Translation missing --]]
L["Gluth"] = "Gluth"
--[[Translation missing --]]
L["Gold"] = "Gold"
--[[Translation missing --]]
L["Golemagg the Incinerator"] = "Golemagg the Incinerator"
--[[Translation missing --]]
L["Gothik the Harvester"] = "Gothik the Harvester"
L["Gradient"] = "Gradient"
--[[Translation missing --]]
L["Gradient Enabled"] = "Gradient Enabled"
--[[Translation missing --]]
L["Gradient End"] = "Gradient End"
--[[Translation missing --]]
L["Gradient Orientation"] = "Gradient Orientation"
L["Gradient Pulse"] = "Gradient Pulse"
--[[Translation missing --]]
L["Grand Widow Faerlina"] = "Grand Widow Faerlina"
--[[Translation missing --]]
L["Grid"] = "Grid"
--[[Translation missing --]]
L["Grobbulus"] = "Grobbulus"
L["Group"] = "Gruppe"
L["Group Arrangement"] = "Gruppenanordnung"
--[[Translation missing --]]
L["Group Leader/Assist"] = "Group Leader/Assist"
--[[Translation missing --]]
L["Group Size"] = "Group Size"
--[[Translation missing --]]
L["Group Type"] = "Group Type"
L["Grow"] = "Wachsen"
--[[Translation missing --]]
L["GTFO Alert"] = "GTFO-Warnung"
L["Guardian"] = "Wächter"
L["Guild"] = "Gilde"
--[[Translation missing --]]
L["Hakkar"] = "Hakkar"
--[[Translation missing --]]
L["Hardcore"] = "Hardcore"
L["Has Target"] = "Hat Ziel"
L["HasPet"] = "mit aktivem Begleiter"
L["Haste (%)"] = "Tempo (%)"
L["Heal"] = "Heilen"
--[[Translation missing --]]
L["Heal Absorbed"] = "Heal Absorbed"
L["Health"] = "Lebenspunkte"
L["Health (%)"] = "Lebenspunkte (%)"
--[[Translation missing --]]
L["Health Deficit"] = "Health Deficit"
--[[Translation missing --]]
L["Heigan the Unclean"] = "Heigan the Unclean"
L["Height"] = "Höhe"
--[[Translation missing --]]
L["Heroic Party"] = "Heroic Party"
--[[Translation missing --]]
L["Hide"] = "Verbergen"
--[[Translation missing --]]
L["Hide 0 cooldowns"] = "Hide 0 cooldowns"
--[[Translation missing --]]
L["Hide Timer Text"] = "Hide Timer Text"
--[[Translation missing --]]
L["High Damage"] = "Hoher Schaden"
--[[Translation missing --]]
L["High Priest Thekal"] = "High Priest Thekal"
--[[Translation missing --]]
L["High Priest Venoxis"] = "High Priest Venoxis"
--[[Translation missing --]]
L["High Priestess Arlokk"] = "High Priestess Arlokk"
--[[Translation missing --]]
L["High Priestess Jeklik"] = "High Priestess Jeklik"
--[[Translation missing --]]
L["High Priestess Mar'li"] = "High Priestess Mar'li"
--[[Translation missing --]]
L["Higher Than Tank"] = "Höher als der Tank"
--[[Translation missing --]]
L["Highest Spell Id"] = "Highest Spell Id"
L["Holy Resistance"] = "Heiligwiderstand"
L["Horde"] = "Horde"
--[[Translation missing --]]
L["Horizontal"] = "Horizontal"
L["Hostile"] = "Feindlich"
L["Hostility"] = "Gesinnung"
L["Humanoid"] = "Humanoid"
--[[Translation missing --]]
L["Hybrid"] = "Hybrid"
--[[Translation missing --]]
L["Icon"] = "Symbol"
--[[Translation missing --]]
L["Icon Function"] = "Icon Function"
--[[Translation missing --]]
L["Icon Function (fallback state)"] = "Icon Function (fallback state)"
--[[Translation missing --]]
L["Id"] = "Id"
--[[Translation missing --]]
L["ID"] = "ID"
--[[Translation missing --]]
L["If you require additional assistance, please open a ticket on GitHub or visit our Discord at https://discord.gg/weakauras!"] = "If you require additional assistance, please open a ticket on GitHub or visit our Discord at https://discord.gg/weakauras!"
--[[Translation missing --]]
L["Ignore Dead"] = "Ignore Dead"
--[[Translation missing --]]
L["Ignore Disconnected"] = "Ignore Disconnected"
L["Ignore Rune CD"] = "Runen-CD ignorieren"
--[[Translation missing --]]
L["Ignore Rune CDs"] = "Ignore Rune CDs"
--[[Translation missing --]]
L["Ignore Self"] = "Ignore Self"
--[[Translation missing --]]
L["Ignore Spell Cooldown/Charges"] = "Ignore Spell Cooldown/Charges"
--[[Translation missing --]]
L["Ignore Spell Override"] = "Ignore Spell Override"
--[[Translation missing --]]
L["Immune"] = "Immun (IMMUNE)"
L["Important"] = "Wichtig"
--[[Translation missing --]]
L["Importing will start after combat ends."] = "Importing will start after combat ends."
L["In Combat"] = "im Kampf"
L["In Encounter"] = "im Bosskampf"
L["In Group"] = "In Gruppe"
--[[Translation missing --]]
L["In Party"] = "In Party"
L["In Raid"] = "Im Schlachtzug"
--[[Translation missing --]]
L["In Range"] = "In Range"
L["Include Bank"] = "Bank einbeziehen"
L["Include Charges"] = "Aufladungen einbeziehen"
--[[Translation missing --]]
L["Include Pets"] = "Include Pets"
L["Incoming Heal"] = "Eingehende Heilung"
--[[Translation missing --]]
L["Increase Precision Below"] = "Increase Precision Below"
--[[Translation missing --]]
L["Increases by one per stage or intermission."] = "Increases by one per stage or intermission."
--[[Translation missing --]]
L["Information"] = "Information"
L["Inherited"] = "Vererbt"
L["Instakill"] = "Sofortiger Tod (INSTAKILL)"
--[[Translation missing --]]
L["Install the addons BugSack and BugGrabber for detailed error logs."] = "Install the addons BugSack and BugGrabber for detailed error logs."
L["Instance"] = "Instanz"
--[[Translation missing --]]
L["Instance Id"] = "Instance Id"
--[[Translation missing --]]
L["Instance ID"] = "Instance ID"
--[[Translation missing --]]
L["Instance Info"] = "Instance Info"
--[[Translation missing --]]
L["Instance Name"] = "Instance Name"
--[[Translation missing --]]
L["Instance Size Type"] = "Instance Size Type"
L["Instance Type"] = "Instanztyp"
--[[Translation missing --]]
L["Instructor Razuvious"] = "Instructor Razuvious"
--[[Translation missing --]]
L["Insufficient Resources"] = "Insufficient Resources"
L["Intellect"] = "Intelligenz"
L["Interrupt"] = "Unterbrechen (INTERRUPT)"
--[[Translation missing --]]
L["Interrupt School"] = "Interrupt School"
--[[Translation missing --]]
L["Interrupted School Text"] = "Interrupted School Text"
L["Interruptible"] = "Unterbrechbar"
L["Inverse"] = "Invertieren"
--[[Translation missing --]]
L["Inverse Pet Behavior"] = "Inverse Pet Behavior"
--[[Translation missing --]]
L["Is Away from Keyboard"] = "Is Away from Keyboard"
L["Is Exactly"] = "Strikter Vergleich"
L["Is Moving"] = "am Bewegen"
L["Is Off Hand"] = "Ist Schildhand"
--[[Translation missing --]]
L["Is Paused"] = "Is Paused"
L["is useable"] = "benutzbar"
--[[Translation missing --]]
L["Island Expedition (Heroic)"] = "Island Expedition (Heroic)"
--[[Translation missing --]]
L["Island Expedition (Mythic)"] = "Island Expedition (Mythic)"
--[[Translation missing --]]
L["Island Expedition (Normal)"] = "Island Expedition (Normal)"
--[[Translation missing --]]
L["Island Expeditions (PvP)"] = "Island Expeditions (PvP)"
L["Item"] = "Gegenstand"
--[[Translation missing --]]
L["Item Bonus Id"] = "Item Bonus Id"
--[[Translation missing --]]
L["Item Bonus Id Equipped"] = "Item Bonus Id Equipped"
L["Item Count"] = "Gegenstandsanzahl"
L["Item Equipped"] = "Gegenstand angelegt"
--[[Translation missing --]]
L["Item Id"] = "Item Id"
--[[Translation missing --]]
L["Item in Range"] = "Item in Range"
--[[Translation missing --]]
L["Item Name"] = "Item Name"
L["Item Set Equipped"] = "Gegenstandsset angelegt"
--[[Translation missing --]]
L["Item Set Id"] = "Item Set Id"
--[[Translation missing --]]
L["Item Slot"] = "Item Slot"
--[[Translation missing --]]
L["Item Slot String"] = "Item Slot String"
--[[Translation missing --]]
L["Item Type"] = "Item Type"
--[[Translation missing --]]
L["Item Type Equipped"] = "Item Type Equipped"
--[[Translation missing --]]
L["ItemId"] = "ItemId"
--[[Translation missing --]]
L["Jin'do the Hexxer"] = "Jin'do the Hexxer"
--[[Translation missing --]]
L["Journal Stage"] = "Journal Stage"
--[[Translation missing --]]
L["Kazzak"] = "Kazzak"
--[[Translation missing --]]
L["Keep Inside"] = "Keep Inside"
--[[Translation missing --]]
L["Kel'Thuzad"] = "Kel'Thuzad"
--[[Translation missing --]]
L["Kurinnaxx"] = "Kurinnaxx"
--[[Translation missing --]]
L["Large"] = "Large"
--[[Translation missing --]]
L["Latency"] = "Latency"
--[[Translation missing --]]
L["Leader"] = "Leader"
--[[Translation missing --]]
L["Least remaining time"] = "Least remaining time"
L["Leaving"] = "Verlassen"
L["Leech"] = "Saugen (LEECH)"
L["Left"] = "Links"
L["Left to Right"] = "Links -> Rechts"
--[[Translation missing --]]
L["Left, then Centered Vertical"] = "Left, then Centered Vertical"
L["Left, then Down"] = "Links, dann runter"
L["Left, then Up"] = "Links, dann hoch"
--[[Translation missing --]]
L["Legacy Looking for Raid"] = "Legacy Looking for Raid"
--[[Translation missing --]]
L["Legacy RGB Gradient"] = "Legacy RGB Gradient"
--[[Translation missing --]]
L["Legacy RGB Gradient Pulse"] = "Legacy RGB Gradient Pulse"
--[[Translation missing --]]
L["Legion"] = "Legion"
L["Length"] = "Länge"
--[[Translation missing --]]
L["Level"] = "Stufe"
--[[Translation missing --]]
L["LibSharedMedia"] = "LibSharedMedia"
--[[Translation missing --]]
L["Lillian Voss"] = "Lillian Voss"
--[[Translation missing --]]
L["Limited"] = "Limited"
--[[Translation missing --]]
L["Linear Texture"] = "Linear Texture"
--[[Translation missing --]]
L["Lines & Particles"] = "Lines & Particles"
L["Load Conditions"] = "Ladebedingungen"
--[[Translation missing --]]
L["Loatheb"] = "Loatheb"
--[[Translation missing --]]
L["Location"] = "Location"
--[[Translation missing --]]
L["Looking for Raid"] = "Looking for Raid"
L["Loop"] = "Schleife"
--[[Translation missing --]]
L["Loot"] = "Loot"
--[[Translation missing --]]
L["Lorewalking"] = "Lorewalking"
L["Lost"] = "Verloren"
L["Low Damage"] = "Niedriger Schaden"
L["Lower Than Tank"] = "Niedriger als der Tank"
--[[Translation missing --]]
L["Lowest Spell Id"] = "Lowest Spell Id"
--[[Translation missing --]]
L["Lua error"] = "Lua error"
--[[Translation missing --]]
L["Lua error in Aura '%s': %s"] = "Lua error in Aura '%s': %s"
--[[Translation missing --]]
L["Lucifron"] = "Lucifron"
--[[Translation missing --]]
L["Maexxna"] = "Maexxna"
L["Magic"] = "Magie"
--[[Translation missing --]]
L["Magmadar"] = "Magmadar"
--[[Translation missing --]]
L["Majordomo Executus"] = "Majordomo Executus"
--[[Translation missing --]]
L["Malformed Musca Auras link"] = "Malformed Musca Auras link"
--[[Translation missing --]]
L["Manual"] = "Manual"
--[[Translation missing --]]
L["Manual Icon"] = "Manual Icon"
L["Manual Rotation"] = "Manuelle Rotation"
L["Marked First"] = "Zuerst markiert"
L["Marked Last"] = "Zuletzt markiert"
--[[Translation missing --]]
L["Mason"] = "Mason"
L["Master"] = "Master"
--[[Translation missing --]]
L["Match Count"] = "Match Count"
--[[Translation missing --]]
L["Match Count per Unit"] = "Match Count per Unit"
L["Matches (Pattern)"] = "Abgleichen (Muster)"
--[[Translation missing --]]
L[ [=[Matches stage number of encounter journal.
Intermissions are .5
E.g. 1;2;1;2;2.5;3]=] ] = [=[Matches stage number of encounter journal.
Intermissions are .5
E.g. 1;2;1;2;2.5;3]=]
--[[Translation missing --]]
L["Max Char "] = "Max Char "
--[[Translation missing --]]
L["Max Char"] = "Max Char"
--[[Translation missing --]]
L["Max Charges"] = "Max Charges"
--[[Translation missing --]]
L["Max Health"] = "Max Health"
--[[Translation missing --]]
L["Max Power"] = "Max Power"
--[[Translation missing --]]
L["Maximum Estimate"] = "Maximum Estimate"
--[[Translation missing --]]
L["Maximum Progress"] = "Maximum Progress"
--[[Translation missing --]]
L["Maximum time used on a single frame"] = "Maximum time used on a single frame"
--[[Translation missing --]]
L["Media"] = "Media"
--[[Translation missing --]]
L["Medium"] = "Medium"
--[[Translation missing --]]
L["Melee"] = "Melee"
L["Message"] = "Nachricht"
L["Message Type"] = "Nachrichtentyp"
L["Message type:"] = "Nachrichtentyp:"
--[[Translation missing --]]
L["Meta Data"] = "Meta Data"
--[[Translation missing --]]
L["Mine"] = "Mine"
--[[Translation missing --]]
L["Minimum Estimate"] = "Minimum Estimate"
--[[Translation missing --]]
L["Minimum Progress"] = "Minimum Progress"
--[[Translation missing --]]
L["Minus (Small Nameplate)"] = "Minus (Small Nameplate)"
L["Mirror"] = "Spiegel"
--[[Translation missing --]]
L["Miscellaneous"] = "Miscellaneous"
L["Miss"] = "Verfehlen"
L["Miss Type"] = "Verfehlengrund"
L["Missed"] = "Verfehlt (MISSED)"
L["Missing"] = "Fehlend"
--[[Translation missing --]]
L["Mists of Pandaria"] = "Mists of Pandaria"
--[[Translation missing --]]
L["Moam"] = "Moam"
--[[Translation missing --]]
L["Model"] = "Model"
--[[Translation missing --]]
L["Modern Blizzard (1h 3m | 3m 7s | 10s | 2.4)"] = "Modern Blizzard (1h 3m | 3m 7s | 10s | 2.4)"
--[[Translation missing --]]
L["Modernize"] = "Modernize"
L["Molten Core"] = "Geschmolzener Kern"
--[[Translation missing --]]
L["Money"] = "Money"
L["Monochrome"] = "Einfarbig"
L["Monochrome Outline"] = "Graustufenkontur"
L["Monochrome Thick Outline"] = "Einfarbige dicke Kontur"
L["Monster Emote"] = "Monster-Emote"
--[[Translation missing --]]
L["Monster Party"] = "Monster Party"
L["Monster Say"] = "Monster Sagen"
L["Monster Whisper"] = "Monster Flüstern"
L["Monster Yell"] = "NPC-Schrei"
--[[Translation missing --]]
L["Most remaining time"] = "Most remaining time"
--[[Translation missing --]]
L["Mounted"] = "am Reiten"
L["Mouse Cursor"] = "Mauszeiger"
L["Multi-target"] = "Mehrfachziel"
--[[Translation missing --]]
L["Mythic Keystone"] = "Mythic Keystone"
--[[Translation missing --]]
L["Name"] = "Name"
--[[Translation missing --]]
L["Name Function"] = "Name Function"
--[[Translation missing --]]
L["Name Function (fallback state)"] = "Name Function (fallback state)"
--[[Translation missing --]]
L["Name of Caster's Target"] = "Name of Caster's Target"
--[[Translation missing --]]
L["Name of the (sub-)zone currently shown above the minimap."] = "Name of the (sub-)zone currently shown above the minimap."
--[[Translation missing --]]
L["Name(s)"] = "Name(s)"
--[[Translation missing --]]
L["Name/Realm of Caster's Target"] = "Name/Realm of Caster's Target"
--[[Translation missing --]]
L["Nameplate"] = "Nameplate"
--[[Translation missing --]]
L["Nameplates"] = "Nameplates"
--[[Translation missing --]]
L["Names of affected Players"] = "Names of affected Players"
--[[Translation missing --]]
L["Names of unaffected Players"] = "Names of unaffected Players"
L["Nature Resistance"] = "Naturwiderstand"
--[[Translation missing --]]
L["Naxxramas"] = "Naxxramas"
--[[Translation missing --]]
L["Nefarian"] = "Nefarian"
--[[Translation missing --]]
L["Neutral"] = "Neutral"
L["Never"] = "Nie"
L["Next Combat"] = "Nächster Kampf"
L["Next Encounter"] = "Nächstes Gefecht"
--[[Translation missing --]]
L[ [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L["No Extend"] = "No Extend"
L["No Instance"] = "Keine Instanz"
--[[Translation missing --]]
L["No Profiling information saved."] = "No Profiling information saved."
--[[Translation missing --]]
L["No Progress Information available."] = "No Progress Information available."
L["None"] = "Keine(r)"
L["Non-player Character"] = "Nicht-Spieler-Charakter (NPC)"
L["Normal"] = "Normal"
--[[Translation missing --]]
L["Normal Party"] = "Normal Party"
--[[Translation missing --]]
L["Not in Group"] = "In keiner Gruppe"
--[[Translation missing --]]
L["Not in Smart Group"] = "Not in Smart Group"
L["Not on Cooldown"] = "Nicht auf Abklingzeit"
L["Not On Threat Table"] = "Nicht bedroht"
--[[Translation missing --]]
L["Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."] = "Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."
--[[Translation missing --]]
L["Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."] = "Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."
--[[Translation missing --]]
L["Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"] = "Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"
--[[Translation missing --]]
L["Noth the Plaguebringer"] = "Noth the Plaguebringer"
L["NPC"] = "NSC"
L["Npc ID"] = "Nsc ID"
L["Number"] = "Nummer"
L["Number Affected"] = "Betroffene Anzahl"
L["Object"] = "Objekt"
--[[Translation missing --]]
L[ [=[Occurrence of the event
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Works only if Boss Mod addon show counter]=] ] = [=[Occurrence of the event
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Works only if Boss Mod addon show counter]=]
--[[Translation missing --]]
L[ [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if BigWigs shows it on it's bar]=] ] = [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if BigWigs shows it on it's bar]=]
--[[Translation missing --]]
L[ [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if DBM shows it on it's bar]=] ] = [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if DBM shows it on it's bar]=]
L["Officer"] = "Offizier"
--[[Translation missing --]]
L["Offset from progress"] = "Offset from progress"
--[[Translation missing --]]
L["Offset Timer"] = "Offset Timer"
--[[Translation missing --]]
L["Old Blizzard (2h | 3m | 10s | 2.4)"] = "Old Blizzard (2h | 3m | 10s | 2.4)"
L["On Cooldown"] = "Auf Abklingzeit"
--[[Translation missing --]]
L["On Taxi"] = "On Taxi"
--[[Translation missing --]]
L["Only if on a different realm"] = "Only if on a different realm"
L["Only if Primary"] = "Nur falls Primär"
L["Onyxia"] = "Onyxia"
L["Opaque"] = "Deckend"
--[[Translation missing --]]
L["Option Group"] = "Option Group"
--[[Translation missing --]]
L["Options could not be loaded, the addon is %s"] = "Options could not be loaded, the addon is %s"
--[[Translation missing --]]
L["Options will finish loading after combat ends."] = "Options will finish loading after combat ends."
--[[Translation missing --]]
L["Options will open after the login process has completed."] = "Options will open after the login process has completed."
--[[Translation missing --]]
L["Or Talent"] = "Or Talent"
L["Orbit"] = "Orbit"
L["Orientation"] = "Ausrichtung"
--[[Translation missing --]]
L["Ossirian the Unscarred"] = "Ossirian the Unscarred"
--[[Translation missing --]]
L["Other"] = "Other"
--[[Translation missing --]]
L["Other Addons"] = "Other Addons"
--[[Translation missing --]]
L["Other Events"] = "Other Events"
--[[Translation missing --]]
L["Ouro"] = "Ouro"
L["Outline"] = "Kontur"
--[[Translation missing --]]
L["Over Energize"] = "Over Energize"
L["Overhealing"] = "Überheilung"
L["Overkill"] = "Overkill"
--[[Translation missing --]]
L["Overlay %s"] = "Overlay %s"
--[[Translation missing --]]
L["Overlay Cost of Casts"] = "Overlay Cost of Casts"
--[[Translation missing --]]
L["Overlay Latency"] = "Overlay Latency"
--[[Translation missing --]]
L["Pad"] = "Pad"
--[[Translation missing --]]
L["Pad Mode"] = "Pad Mode"
--[[Translation missing --]]
L["Pad to"] = "Pad to"
--[[Translation missing --]]
L["Parent Frame"] = "Parent Frame"
--[[Translation missing --]]
L["Parent Zone"] = "Parent Zone"
L["Parry"] = "Parieren"
L["Parry (%)"] = "Parieren (%)"
L["Party"] = "Gruppe"
L["Party Kill"] = "Gruppen Tod (PARTY_KILL)"
--[[Translation missing --]]
L["Patchwerk"] = "Patchwerk"
--[[Translation missing --]]
L["Path of Ascension: Courage"] = "Path of Ascension: Courage"
--[[Translation missing --]]
L["Path of Ascension: Humility"] = "Path of Ascension: Humility"
--[[Translation missing --]]
L["Path of Ascension: Loyalty"] = "Path of Ascension: Loyalty"
--[[Translation missing --]]
L["Path of Ascension: Wisdom"] = "Path of Ascension: Wisdom"
L["Paused"] = "Pausiert"
L["Periodic Spell"] = "Periodischer Zauber (PERIODIC_SPELL)"
L["Personal Resource Display"] = "Persönliche Ressourcenanzeige"
L["Pet"] = "Begleiter"
L["Pet Behavior"] = "Begleiterverhalten"
--[[Translation missing --]]
L["Pet Specialization"] = "Pet Specialization"
L["Pet Spell"] = "Begleiterzauber"
--[[Translation missing --]]
L["Pets only"] = "Pets only"
L["Phase"] = "Phase"
--[[Translation missing --]]
L["Pixel Glow"] = "Pixel Glow"
--[[Translation missing --]]
L["Placement"] = "Placement"
--[[Translation missing --]]
L["Placement %i"] = "Placement %i"
--[[Translation missing --]]
L["Placement Mode"] = "Placement Mode"
L["Play"] = "Abspielen"
L["Player"] = "Spieler (Selbst)"
L["Player Character"] = "Spieler-Charakter (PC)"
L["Player Class"] = "Spielerklasse"
--[[Translation missing --]]
L["Player Experience"] = "Player Experience"
L["Player Faction"] = "Spielerfraktion"
L["Player Level"] = "Spielerstufe"
--[[Translation missing --]]
L["Player Location ID(s)"] = "Player Location ID(s)"
--[[Translation missing --]]
L["Player Money"] = "Player Money"
--[[Translation missing --]]
L["Player Name/Realm"] = "Player Name/Realm"
L["Player Race"] = "Spielervolk"
L["Player(s) Affected"] = "Betroffene Spieler"
L["Player(s) Not Affected"] = "Nicht betroffene Spieler"
--[[Translation missing --]]
L["Player/Unit Info"] = "Player/Unit Info"
--[[Translation missing --]]
L["Players and Pets"] = "Players and Pets"
L["Poison"] = "Gift"
L["Power"] = "Ressource"
L["Power (%)"] = "Ressource (%)"
--[[Translation missing --]]
L["Power Deficit"] = "Power Deficit"
L["Power Type"] = "Ressourcentyp"
--[[Translation missing --]]
L["Precision"] = "Precision"
L["Preset"] = "Standard"
--[[Translation missing --]]
L["Primary Stats"] = "Primary Stats"
--[[Translation missing --]]
L["Princess Huhuran"] = "Princess Huhuran"
--[[Translation missing --]]
L["Print Profiling Results"] = "Print Profiling Results"
--[[Translation missing --]]
L["Proc Glow"] = "Proc Glow"
--[[Translation missing --]]
L["Profiling already started."] = "Profiling already started."
--[[Translation missing --]]
L["Profiling automatically started."] = "Profiling automatically started."
--[[Translation missing --]]
L["Profiling not running."] = "Profiling not running."
--[[Translation missing --]]
L["Profiling started."] = "Profiling started."
--[[Translation missing --]]
L["Profiling started. It will end automatically in %d seconds"] = "Profiling started. It will end automatically in %d seconds"
--[[Translation missing --]]
L["Profiling still running, stop before trying to print."] = "Profiling still running, stop before trying to print."
--[[Translation missing --]]
L["Profiling stopped."] = "Profiling stopped."
--[[Translation missing --]]
L["Progress"] = "Progress"
--[[Translation missing --]]
L["Progress Source"] = "Progress Source"
L["Progress Total"] = "Totaler Fortschritt"
L["Progress Value"] = "Fortschrittswert"
--[[Translation missing --]]
L["Pull"] = "Pull"
L["Pulse"] = "Pulsieren"
L["PvP Flagged"] = "PvP aktiv"
--[[Translation missing --]]
L["PvP Mode Active"] = "PvP Mode Active"
--[[Translation missing --]]
L["Quest Party"] = "Quest Party"
--[[Translation missing --]]
L["Queued Action"] = "Queued Action"
L["Radius"] = "Radius"
--[[Translation missing --]]
L["Ragnaros"] = "Ragnaros"
L["Raid"] = "Schlachtzug"
--[[Translation missing --]]
L["Raid (Heroic)"] = "Raid (Heroic)"
--[[Translation missing --]]
L["Raid (Mythic)"] = "Raid (Mythic)"
--[[Translation missing --]]
L["Raid (Normal)"] = "Raid (Normal)"
--[[Translation missing --]]
L["Raid (Timewalking)"] = "Raid (Timewalking)"
--[[Translation missing --]]
L["Raid Mark"] = "Raid Mark"
--[[Translation missing --]]
L["Raid Mark Icon"] = "Raid Mark Icon"
--[[Translation missing --]]
L["Raid Role"] = "Raid Role"
L["Raid Warning"] = "Schlachtzugswarnung"
L["Range"] = "Reichweite"
L["Range Check"] = "Reichweitencheck"
--[[Translation missing --]]
L["Ranged"] = "Ranged"
--[[Translation missing --]]
L["Rank"] = "Rank"
--[[Translation missing --]]
L["Rare"] = "Rare"
--[[Translation missing --]]
L["Rare Elite"] = "Rare Elite"
--[[Translation missing --]]
L["Rated Arena"] = "Rated Arena"
--[[Translation missing --]]
L["Rated Battleground"] = "Rated Battleground"
--[[Translation missing --]]
L["Raw Threat Percent"] = "Raw Threat Percent"
--[[Translation missing --]]
L["Razorgore the Untamed"] = "Razorgore the Untamed"
L["Ready Check"] = "Bereitschaftscheck"
L["Realm"] = "Realm"
--[[Translation missing --]]
L["Realm Name"] = "Realm Name"
--[[Translation missing --]]
L["Realm of Caster's Target"] = "Realm of Caster's Target"
--[[Translation missing --]]
L["Reborn Council"] = "Reborn Council"
--[[Translation missing --]]
L["Receiving %s Bytes"] = "Receiving %s Bytes"
L["Receiving display information"] = "Erhalte Anzeigeinformationen von %s"
L["Reflect"] = "Reflektieren (REFLECT)"
L["Region type %s not supported"] = "Regiontyp %s wird nicht unterstützt"
L["Relative"] = "Relativ"
--[[Translation missing --]]
L["Relative X-Offset"] = "Relative X-Offset"
--[[Translation missing --]]
L["Relative Y-Offset"] = "Relative Y-Offset"
--[[Translation missing --]]
L["Remaining Duration"] = "Verbleibende Dauer"
L["Remaining Time"] = "Verbleibende Zeit"
--[[Translation missing --]]
L["Remove Obsolete Auras"] = "Remove Obsolete Auras"
L["Repair"] = "Reparieren"
L["Repeat"] = "Wiederhole"
--[[Translation missing --]]
L["Report Summary"] = "Report Summary"
--[[Translation missing --]]
L["Reputation"] = "Reputation"
--[[Translation missing --]]
L["Reputation (%)"] = "Reputation (%)"
L["Requested display does not exist"] = "Angeforderte Anzeige existiert nicht"
L["Requested display not authorized"] = "Angeforderte Anzeige ist nicht autorisiert"
--[[Translation missing --]]
L["Requesting display information from %s ..."] = "Requesting display information from %s ..."
L["Require Valid Target"] = "Erfordert gültiges Ziel"
L["Resist"] = "Widerstehen"
--[[Translation missing --]]
L["Resistances"] = "Resistances"
L["Resisted"] = "Widerstanden (RESISTED)"
--[[Translation missing --]]
L["Rested"] = "Rested"
--[[Translation missing --]]
L["Rested Experience"] = "Rested Experience"
--[[Translation missing --]]
L["Rested Experience (%)"] = "Rested Experience (%)"
L["Resting"] = "am Erholen"
L["Resurrect"] = "Wiederbeleben"
--[[Translation missing --]]
L["Resurrect Pending"] = "Resurrect Pending"
L["Right"] = "Rechts"
L["Right to Left"] = "Rechts -> Links"
--[[Translation missing --]]
L["Right, then Centered Vertical"] = "Right, then Centered Vertical"
L["Right, then Down"] = "Rechts, dann runter"
L["Right, then Up"] = "Rechts, dann hoch"
L["Role"] = "Rolle"
--[[Translation missing --]]
L["Rollback snapshot is complete. Thank you for your patience!"] = "Rollback snapshot is complete. Thank you for your patience!"
--[[Translation missing --]]
L["Rotate Animation"] = "Rotate Animation"
L["Rotate Left"] = "Nach links rotieren"
L["Rotate Right"] = "Nach rechts rotieren"
--[[Translation missing --]]
L["Rotation"] = "Rotation"
--[[Translation missing --]]
L["Round"] = "Round"
--[[Translation missing --]]
L["Round Mode"] = "Round Mode"
L["Ruins of Ahn'Qiraj"] = "Ruinen von Ahn'Qiraj"
L["Run Custom Code"] = "Code ausführen"
--[[Translation missing --]]
L["Run Speed (%)"] = "Run Speed (%)"
--[[Translation missing --]]
L["Sapphiron"] = "Sapphiron"
--[[Translation missing --]]
L["Say"] = "Sagen"
--[[Translation missing --]]
L["Scale"] = "Scale"
--[[Translation missing --]]
L["Scarlet Enclave"] = "Scarlet Enclave"
L["Scenario"] = "Szenario"
--[[Translation missing --]]
L["Scenario (Heroic)"] = "Scenario (Heroic)"
--[[Translation missing --]]
L["Scenario (Normal)"] = "Scenario (Normal)"
--[[Translation missing --]]
L["Screen"] = "Screen"
L["Screen/Parent Group"] = "Bildschirm/Elterngruppe"
--[[Translation missing --]]
L["Season of Discovery"] = "Season of Discovery"
--[[Translation missing --]]
L["Second"] = "Second"
--[[Translation missing --]]
L["Second Value of Tooltip Text"] = "Second Value of Tooltip Text"
--[[Translation missing --]]
L["Secondary Stats"] = "Secondary Stats"
L["Seconds"] = "Sekunden"
--[[Translation missing --]]
L[ [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
L["Select Frame"] = "Frame auswählen"
--[[Translation missing --]]
L["Select the type of timer to filter"] = "Select the type of timer to filter"
--[[Translation missing --]]
L["Selection Mode"] = "Selection Mode"
--[[Translation missing --]]
L["Separator"] = "Separator"
--[[Translation missing --]]
L["Set IDs can be found on websites such as wowhead.com/classic/item-sets"] = "Set IDs can be found on websites such as wowhead.com/classic/item-sets"
--[[Translation missing --]]
L["Shadow Resistance"] = "Schattenwiderstand"
--[[Translation missing --]]
L["Shadowlands"] = "Shadowlands"
--[[Translation missing --]]
L["Shake"] = "Beben"
--[[Translation missing --]]
L["Shazzrah"] = "Shazzrah"
--[[Translation missing --]]
L["Shift-Click to resume addon execution."] = "Shift-Click to resume addon execution."
L["Show"] = "Zeigen"
--[[Translation missing --]]
L["Show CD of Charge"] = "Show CD of Charge"
L["Show GCD"] = "GCD anzeigen"
L["Show Global Cooldown"] = "Globale Abklingzeit anzeigen"
L["Show Incoming Heal"] = "Eingehende Heilung zeigen"
--[[Translation missing --]]
L["Show Loss of Control"] = "Show Loss of Control"
--[[Translation missing --]]
L["Show On"] = "Show On"
--[[Translation missing --]]
L["Show Rested Overlay"] = "Show Rested Overlay"
L["Shrink"] = "Schrumpfen"
--[[Translation missing --]]
L["Silithid Royalty"] = "Silithid Royalty"
--[[Translation missing --]]
L["Silver"] = "Silver"
L["Simple"] = "Einfach"
--[[Translation missing --]]
L["Since Active"] = "Since Active"
--[[Translation missing --]]
L["Since Apply"] = "Since Apply"
--[[Translation missing --]]
L["Since Apply/Refresh"] = "Since Apply/Refresh"
--[[Translation missing --]]
L["Since Charge Gain"] = "Since Charge Gain"
--[[Translation missing --]]
L["Since Charge Lost"] = "Since Charge Lost"
--[[Translation missing --]]
L["Since Ready"] = "Since Ready"
--[[Translation missing --]]
L["Since Stack Gain"] = "Since Stack Gain"
--[[Translation missing --]]
L["Since Stack Lost"] = "Since Stack Lost"
L["Size & Position"] = "Größe & Position"
--[[Translation missing --]]
L["Slide Animation"] = "Slide Animation"
L["Slide from Bottom"] = "Von unten eingleiten"
L["Slide from Left"] = "Von links eingleiten"
L["Slide from Right"] = "Von rechts eingleiten"
L["Slide from Top"] = "Von oben eingleiten"
L["Slide to Bottom"] = "Nach unten entgleiten"
L["Slide to Left"] = "Nach links entgleiten"
L["Slide to Right"] = "Nach rechts entgleiten"
L["Slide to Top"] = "Nach oben entgleiten"
--[[Translation missing --]]
L["Slider"] = "Slider"
--[[Translation missing --]]
L["Slug"] = "Slug"
--[[Translation missing --]]
L["Slug Outline"] = "Slug Outline"
L["Small"] = "Klein"
--[[Translation missing --]]
L["Smart Group"] = "Smart Group"
--[[Translation missing --]]
L["Soft Enemy"] = "Soft Enemy"
--[[Translation missing --]]
L["Soft Friend"] = "Soft Friend"
--[[Translation missing --]]
L["Solistrasza"] = "Solistrasza"
L["Sound"] = "Ton"
--[[Translation missing --]]
L["Sound by Kit ID"] = "Sound by Kit ID"
--[[Translation missing --]]
L["Source"] = "Source"
--[[Translation missing --]]
L["Source Affiliation"] = "Source Affiliation"
--[[Translation missing --]]
L["Source GUID"] = "Source GUID"
--[[Translation missing --]]
L["Source Info"] = "Source Info"
L["Source Name"] = "Quellname"
--[[Translation missing --]]
L["Source NPC Id"] = "Source NPC Id"
--[[Translation missing --]]
L["Source Object Type"] = "Source Object Type"
L["Source Raid Mark"] = "Quellmarkierung"
--[[Translation missing --]]
L["Source Reaction"] = "Source Reaction"
L["Source Unit"] = "Quelleinheit"
--[[Translation missing --]]
L["Source Unit Name/Realm"] = "Source Unit Name/Realm"
--[[Translation missing --]]
L["Source unit's raid mark index"] = "Source unit's raid mark index"
--[[Translation missing --]]
L["Source unit's raid mark texture"] = "Source unit's raid mark texture"
--[[Translation missing --]]
L["Space"] = "Space"
L["Spacing"] = "Abstand"
--[[Translation missing --]]
L["Spark"] = "Spark"
--[[Translation missing --]]
L["Specialization"] = "Specialization"
--[[Translation missing --]]
L["Specific Type"] = "Specific Type"
L["Specific Unit"] = "Konkrete Einheit"
L["Spell"] = "Zauber"
L["Spell (Building)"] = "Zauber, Gebäude (SPELL_BUILDING)"
--[[Translation missing --]]
L["Spell Cast Succeeded"] = "Spell Cast Succeeded"
L["Spell Cost"] = "Zauberkosten"
--[[Translation missing --]]
L["Spell Count"] = "Spell Count"
L["Spell ID"] = "Zauber-ID"
L["Spell Id"] = "Zauber-ID"
L["Spell ID:"] = "Zauber ID:"
L["Spell IDs:"] = "Zauber IDs:"
--[[Translation missing --]]
L["Spell in Range"] = "Spell in Range"
L["Spell Known"] = "Zauber erlernt"
L["Spell Name"] = "Zaubername"
--[[Translation missing --]]
L["Spell Power"] = "Spell Power"
--[[Translation missing --]]
L["Spell School"] = "Spell School"
L["Spell Usable"] = "Zauber benutzbar"
--[[Translation missing --]]
L["Spellname"] = "Spellname"
--[[Translation missing --]]
L["Spike"] = "Spike"
L["Spin"] = "Drehen"
L["Spiral"] = "Winden"
L["Spiral In And Out"] = "Ein- und Auswinden"
--[[Translation missing --]]
L["Spirit"] = "Spirit"
--[[Translation missing --]]
L["Stack Count"] = "Stack Count"
--[[Translation missing --]]
L["Stack trace:"] = "Stack trace:"
L["Stacks"] = "Stapel"
--[[Translation missing --]]
L["Stacks Function"] = "Stacks Function"
--[[Translation missing --]]
L["Stacks Function (fallback state)"] = "Stacks Function (fallback state)"
--[[Translation missing --]]
L["Stage"] = "Stage"
--[[Translation missing --]]
L["Stage Counter"] = "Stage Counter"
--[[Translation missing --]]
L["Stagger"] = "Stagger"
--[[Translation missing --]]
L["Stagger Scale"] = "Stagger Scale"
L["Stamina"] = "Ausdauer"
L["Stance/Form/Aura"] = "Haltung/Form/Aura"
--[[Translation missing --]]
L["Standing"] = "Standing"
--[[Translation missing --]]
L["Star Shake"] = "Star Shake"
--[[Translation missing --]]
L["Start Animation"] = "Start Animation"
--[[Translation missing --]]
L["Start Now"] = "Start Now"
--[[Translation missing --]]
L["Start Profiling"] = "Start Profiling"
L["Status"] = "Status"
--[[Translation missing --]]
L["Status Bar"] = "Status Bar"
L["Stolen"] = "Gestohlen (STOLEN)"
L["Stop"] = "Stopp"
--[[Translation missing --]]
L["Stop Motion"] = "Stop Motion"
--[[Translation missing --]]
L["Story Raid"] = "Story Raid"
L["Strength"] = "Stärke"
--[[Translation missing --]]
L["String"] = "String"
--[[Translation missing --]]
L["Subevent Info"] = "Subevent Info"
--[[Translation missing --]]
L["Subtract Cast"] = "Subtract Cast"
--[[Translation missing --]]
L["Subtract Channel"] = "Subtract Channel"
--[[Translation missing --]]
L["Subtract GCD"] = "Subtract GCD"
--[[Translation missing --]]
L["Subzone Name"] = "Subzone Name"
--[[Translation missing --]]
L["Success"] = "Success"
--[[Translation missing --]]
L["Sulfuron Harbinger"] = "Sulfuron Harbinger"
L["Summon"] = "Herbeirufen (SUMMON)"
--[[Translation missing --]]
L["Supports multiple entries, separated by commas"] = "Supports multiple entries, separated by commas"
--[[Translation missing --]]
L[ [=[Supports multiple entries, separated by commas
]=] ] = [=[Supports multiple entries, separated by commas
]=]
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Escape ',' with \\. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Escape ',' with \\. Prefix with '-' for negation."
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Escape with \\. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Escape with \\. Prefix with '-' for negation."
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Prefix with '-' for negation."
--[[Translation missing --]]
L[ [=[Supports multiple entries, separated by commas. To include child zone ids, prefix with 'c', e.g. 'c2022'.
Group Zone IDs must be prefixed with 'g', e.g. 'g277'. 
Supports Area IDs from https://wago.tools/db2/AreaTable prefixed with 'a'. 
Supports Instance IDs prefixed with 'i'.
Entries can be prefixed with '-' to negate.]=] ] = [=[Supports multiple entries, separated by commas. To include child zone ids, prefix with 'c', e.g. 'c2022'.
Group Zone IDs must be prefixed with 'g', e.g. 'g277'. 
Supports Area IDs from https://wago.tools/db2/AreaTable prefixed with 'a'. 
Supports Instance IDs prefixed with 'i'.
Entries can be prefixed with '-' to negate.]=]
--[[Translation missing --]]
L["Swing"] = "Schwingen (SWING)"
L["Swing Timer"] = "Schlagtimer"
--[[Translation missing --]]
L["Swipe"] = "Swipe"
--[[Translation missing --]]
L["Syntax /wa feature <toggle|on|enable|disable|off> <feature>"] = "Syntax /wa feature <toggle|on|enable|disable|off> <feature>"
L["System"] = "System"
--[[Translation missing --]]
L["Systems"] = "Systems"
--[[Translation missing --]]
L["Tab "] = "Tab "
--[[Translation missing --]]
L["Talent"] = "Talent"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Known"] = "Talent |cFFFF0000Not|r Known"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Selected"] = "Talent |cFFFF0000Not|r Selected"
--[[Translation missing --]]
L["Talent Known"] = "Talent Known"
L["Talent Selected"] = "Talent gewählt"
L["Talent Specialization"] = "Talentspezialisierung"
L["Tanking And Highest"] = "Höchster und Aggro"
L["Tanking But Not Highest"] = "Aggro aber nicht höchste"
L["Target"] = "Ziel"
L["Targeted"] = "Anvisiert"
--[[Translation missing --]]
L["Tertiary Stats"] = "Tertiary Stats"
--[[Translation missing --]]
L["Test if bar is enabled in BigWigs settings"] = "Test if bar is enabled in BigWigs settings"
--[[Translation missing --]]
L["Test if bar is enabled in Boss Mod addon settings"] = "Test if bar is enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Test if bar is enabled in DBM settings"] = "Test if bar is enabled in DBM settings"
L["Text"] = "Text"
--[[Translation missing --]]
L["Text To Speech"] = "Text To Speech"
--[[Translation missing --]]
L["Text-to-speech"] = "Text-to-speech"
--[[Translation missing --]]
L["Texture"] = "Texture"
--[[Translation missing --]]
L["Texture Function"] = "Texture Function"
--[[Translation missing --]]
L["Texture Function (fallback state)"] = "Texture Function (fallback state)"
--[[Translation missing --]]
L["Texture Picker"] = "Texture Picker"
--[[Translation missing --]]
L["Texture Rotation"] = "Texture Rotation"
--[[Translation missing --]]
L["Thaddius"] = "Thaddius"
--[[Translation missing --]]
L["The aura has overwritten the global '%s', this might affect other auras."] = "The aura has overwritten the global '%s', this might affect other auras."
--[[Translation missing --]]
L["The aura tried to overwrite the aura_env global, which is not allowed."] = "The aura tried to overwrite the aura_env global, which is not allowed."
--[[Translation missing --]]
L["The Four Horsemen"] = "The Four Horsemen"
--[[Translation missing --]]
L["The 'ID' value can be found in the BigWigs options of a specific spell"] = "The 'ID' value can be found in the BigWigs options of a specific spell"
--[[Translation missing --]]
L["The Prophet Skeram"] = "The Prophet Skeram"
--[[Translation missing --]]
L["The War Within"] = "The War Within"
--[[Translation missing --]]
L["There are %i updates to your auras ready to be installed!"] = "There are %i updates to your auras ready to be installed!"
L["Thick Outline"] = "Dicke Kontur"
--[[Translation missing --]]
L["Thickness"] = "Thickness"
--[[Translation missing --]]
L["Third"] = "Third"
--[[Translation missing --]]
L["Third Value of Tooltip Text"] = "Third Value of Tooltip Text"
--[[Translation missing --]]
L["This aura calls GetData a lot, which is a slow function."] = "This aura calls GetData a lot, which is a slow function."
--[[Translation missing --]]
L["This aura has caused a Lua error."] = "This aura has caused a Lua error."
--[[Translation missing --]]
L["This aura is saving %s KB of data"] = "This aura is saving %s KB of data"
--[[Translation missing --]]
L["This aura is setting show to nil. This is deprecated and the behavior will change in the future."] = "This aura is setting show to nil. This is deprecated and the behavior will change in the future."
--[[Translation missing --]]
L["This aura plays a sound via a condition."] = "This aura plays a sound via a condition."
--[[Translation missing --]]
L["This aura plays a sound via an action."] = "This aura plays a sound via an action."
--[[Translation missing --]]
L["This aura plays a Text To Speech via a condition."] = "This aura plays a Text To Speech via a condition."
--[[Translation missing --]]
L["This aura plays a Text To Speech via an action."] = "This aura plays a Text To Speech via an action."
--[[Translation missing --]]
L["This filter has been moved to the Location trigger. Change your aura to use the new Location trigger or join the WeakAuras Discord server for help."] = "This filter has been moved to the Location trigger. Change your aura to use the new Location trigger or join the WeakAuras Discord server for help."
--[[Translation missing --]]
L["Threat Percent"] = "Threat Percent"
L["Threat Situation"] = "Bedrohungssituation"
--[[Translation missing --]]
L["Threat Value"] = "Threat Value"
--[[Translation missing --]]
L["Tick"] = "Tick"
--[[Translation missing --]]
L["Time"] = "Time"
--[[Translation missing --]]
L["Time Format"] = "Time Format"
--[[Translation missing --]]
L["Time in GCDs"] = "Time in GCDs"
--[[Translation missing --]]
L["Time since initial application"] = "Time since initial application"
--[[Translation missing --]]
L["Time since last refresh"] = "Time since last refresh"
--[[Translation missing --]]
L["Time since stack gain"] = "Time since stack gain"
--[[Translation missing --]]
L["Time since stack lost"] = "Time since stack lost"
L["Timed"] = "Zeitgesteuert"
--[[Translation missing --]]
L["Timed Progress"] = "Timed Progress"
--[[Translation missing --]]
L["Timer"] = "Timer"
--[[Translation missing --]]
L["Timer Id"] = "Timer Id"
L["Toggle"] = "Umschalten"
--[[Translation missing --]]
L["Toggle List"] = "Toggle List"
--[[Translation missing --]]
L["Toggle Options Window"] = "Toggle Options Window"
--[[Translation missing --]]
L["Toggle Performance Profiling Window"] = "Toggle Performance Profiling Window"
L["Tooltip"] = "Tooltip"
--[[Translation missing --]]
L["Tooltip 1"] = "Tooltip 1"
--[[Translation missing --]]
L["Tooltip 2"] = "Tooltip 2"
--[[Translation missing --]]
L["Tooltip 3"] = "Tooltip 3"
L["Tooltip Value 1"] = "Tooltip Wert 1"
L["Tooltip Value 2"] = "Tooltip Wert 2"
L["Tooltip Value 3"] = "Tooltip Wert 3"
--[[Translation missing --]]
L["Tooltip Value 4"] = "Tooltip Value 4"
L["Top"] = "Oben"
L["Top Left"] = "Oben Links"
L["Top Right"] = "Oben Rechts"
L["Top to Bottom"] = "Oben -> Unten"
--[[Translation missing --]]
L["Torghast"] = "Torghast"
L["Total Duration"] = "Gesamtdauer"
--[[Translation missing --]]
L["Total Experience"] = "Total Experience"
--[[Translation missing --]]
L["Total Match Count"] = "Total Match Count"
--[[Translation missing --]]
L["Total Reputation"] = "Total Reputation"
--[[Translation missing --]]
L["Total Stacks"] = "Total Stacks"
--[[Translation missing --]]
L["Total stacks over all matches"] = "Total stacks over all matches"
--[[Translation missing --]]
L["Total Unit Count"] = "Total Unit Count"
--[[Translation missing --]]
L["Total Units"] = "Total Units"
L["Totem"] = "Totem"
L["Totem #%i"] = "Totem #%i"
--[[Translation missing --]]
L["Totem Icon"] = "Totem Icon"
L["Totem Name"] = "Totemname"
--[[Translation missing --]]
L["Totem Name Pattern Match"] = "Totem Name Pattern Match"
L["Totem Number"] = "Totemnummer"
--[[Translation missing --]]
L["Track Cooldowns"] = "Track Cooldowns"
--[[Translation missing --]]
L["Tracking Charge %i"] = "Tracking Charge %i"
--[[Translation missing --]]
L["Tracking Charge CDs"] = "Tracking Charge CDs"
--[[Translation missing --]]
L["Tracking Only Cooldown"] = "Tracking Only Cooldown"
L["Transmission error"] = "Übertragungsfehler"
--[[Translation missing --]]
L["Trigger"] = "Auslöser"
--[[Translation missing --]]
L["Trigger %i"] = "Trigger %i"
--[[Translation missing --]]
L["Trigger %s"] = "Trigger %s"
L["Trigger 1"] = "Auslöser 1"
--[[Translation missing --]]
L["Trigger State Updater (Advanced)"] = "Trigger State Updater (Advanced)"
L["Trigger Update"] = "Auslöseraktualisierung"
L["Trigger:"] = "Auslöser:"
--[[Translation missing --]]
L["Trivial (Low Level)"] = "Trivial (Low Level)"
L["True"] = "Zutrifft"
--[[Translation missing --]]
L["Trying to repair broken conditions in %s likely caused by a Musca Auras bug."] = "Trying to repair broken conditions in %s likely caused by a Musca Auras bug."
L["Twin Emperors"] = "Zwillingsimperatoren"
L["Type"] = "Typ"
--[[Translation missing --]]
L["Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."] = "Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."
--[[Translation missing --]]
L["Unaffected"] = "Unaffected"
L["Undefined"] = "Undefiniert"
L["Unit"] = "Einheit"
L["Unit Characteristics"] = "Einheitencharakterisierung"
L["Unit Destroyed"] = "Einheit zerstört"
L["Unit Died"] = "Einheit gestorben"
--[[Translation missing --]]
L["Unit Dissipates"] = "Unit Dissipates"
--[[Translation missing --]]
L["Unit Frame"] = "Unit Frame"
--[[Translation missing --]]
L["Unit Frames"] = "Unit Frames"
L["Unit is Unit"] = "Vergleicht Einheit mit"
--[[Translation missing --]]
L["Unit Name"] = "Unit Name"
--[[Translation missing --]]
L["Unit Name/Realm"] = "Unit Name/Realm"
--[[Translation missing --]]
L["Units Affected"] = "Units Affected"
--[[Translation missing --]]
L["Units of affected Players in a table format"] = "Units of affected Players in a table format"
--[[Translation missing --]]
L["Units of unaffected Players in a table format"] = "Units of unaffected Players in a table format"
--[[Translation missing --]]
L["Unknown action %q"] = "Unknown action %q"
--[[Translation missing --]]
L["Unknown feature %q"] = "Unknown feature %q"
--[[Translation missing --]]
L["unknown location"] = "unknown location"
L["Unlimited"] = "Unbegrenzt"
--[[Translation missing --]]
L["Untrigger %s"] = "Untrigger %s"
L["Up"] = "Hoch"
--[[Translation missing --]]
L["Up, then Centered Horizontal"] = "Up, then Centered Horizontal"
L["Up, then Left"] = "Hoch, dann links"
L["Up, then Right"] = "Hoch, dann rechts"
--[[Translation missing --]]
L["Update Position"] = "Update Position"
L["Usage:"] = "Benutzung:"
--[[Translation missing --]]
L["Use /wa minimap to show the minimap icon again."] = "Use /wa minimap to show the minimap icon again."
L["Use Custom Color"] = "Benutzerdefinierte Farbe benutzen"
--[[Translation missing --]]
L["Use Legacy floor rounding"] = "Use Legacy floor rounding"
--[[Translation missing --]]
L["Use Texture"] = "Use Texture"
--[[Translation missing --]]
L["Use Watched Faction"] = "Use Watched Faction"
--[[Translation missing --]]
L["Using WeakAuras.clones is deprecated. Use WeakAuras.GetRegion(id, cloneId) instead."] = "Using WeakAuras.clones is deprecated. Use WeakAuras.GetRegion(id, cloneId) instead."
--[[Translation missing --]]
L["Using WeakAuras.regions is deprecated. Use WeakAuras.GetRegion(id) instead."] = "Using WeakAuras.regions is deprecated. Use WeakAuras.GetRegion(id) instead."
--[[Translation missing --]]
L["Vaelastrasz the Corrupt"] = "Vaelastrasz the Corrupt"
--[[Translation missing --]]
L["Vertical"] = "Vertical"
--[[Translation missing --]]
L["Viscidus"] = "Viscidus"
L["Visibility"] = "Sichtbarkeit"
--[[Translation missing --]]
L["Visions of N'Zoth"] = "Visions of N'Zoth"
--[[Translation missing --]]
L["Warfront (Heroic)"] = "Warfront (Heroic)"
--[[Translation missing --]]
L["Warfront (Normal)"] = "Warfront (Normal)"
--[[Translation missing --]]
L["Warlords of Draenor"] = "Warlords of Draenor"
--[[Translation missing --]]
L["Warning"] = "Warning"
--[[Translation missing --]]
L["Warning for unknown aura:"] = "Warning for unknown aura:"
--[[Translation missing --]]
L["Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"] = "Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"
--[[Translation missing --]]
L["Musca Auras Built-In (63:42 | 3:07 | 10 | 2.4)"] = "Musca Auras Built-In (63:42 | 3:07 | 10 | 2.4)"
--[[Translation missing --]]
L["Musca Auras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."] = "Musca Auras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."
--[[Translation missing --]]
L[ [=[Musca Auras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=] ] = [=[Musca Auras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=]
--[[Translation missing --]]
L["Musca Auras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."] = "Musca Auras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."
--[[Translation missing --]]
L["Musca Auras Profiling"] = "Musca Auras Profiling"
--[[Translation missing --]]
L["Musca Auras Profiling Report"] = "Musca Auras Profiling Report"
--[[Translation missing --]]
L["Weapon"] = "Waffen"
L["Weapon Enchant"] = "Waffenverzauberung"
L["Whisper"] = "Flüstern"
L["Width"] = "Breite"
L["Wobble"] = "Wackeln"
L["World Boss"] = "Weltboss"
--[[Translation missing --]]
L["World Bosses"] = "World Bosses"
--[[Translation missing --]]
L["Wrap"] = "Wrap"
--[[Translation missing --]]
L["Wrath of the Lich King"] = "Wrath of the Lich King"
--[[Translation missing --]]
L["Writing to the WeakAuras table is not allowed."] = "Writing to the WeakAuras table is not allowed."
L["X-Offset"] = "X-Versatz"
L["Yell"] = "Schreien"
L["Y-Offset"] = "Y-Versatz"
--[[Translation missing --]]
L["You have new auras ready to be installed!"] = "You have new auras ready to be installed!"
--[[Translation missing --]]
L["Your next encounter will automatically be profiled."] = "Your next encounter will automatically be profiled."
--[[Translation missing --]]
L["Your next instance of combat will automatically be profiled."] = "Your next instance of combat will automatically be profiled."
--[[Translation missing --]]
L["Your scheduled automatic profile has been cancelled."] = "Your scheduled automatic profile has been cancelled."
--[[Translation missing --]]
L["Your threat as a percentage of the tank's current threat."] = "Your threat as a percentage of the tank's current threat."
L["Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."] = "Ihre Bedrohung für den Mob als Prozentsatz der Menge, der zum Ziehen von Aggro erforderlich ist. Wird bei 100 Aggro ziehen."
L["Your total threat on the mob."] = "Ihre gesamte Bedrohung für den Mob."
--[[Translation missing --]]
L["Zone Group ID"] = "Zone Group ID"
--[[Translation missing --]]
L["Zone ID"] = "Zone ID"
L["Zone Name"] = "Gebietsname"
L["Zoom"] = "Zoom"
--[[Translation missing --]]
L["Zoom Animation"] = "Zoom Animation"
--[[Translation missing --]]
L["Zul'Gurub"] = "Zul'Gurub"
L["New name, new look: the addon now shows its own name, Musca Auras."] = "Neuer Name, neues Aussehen: Das Addon zeigt jetzt seinen eigenen Namen, Musca Auras."
L["- New colors and a new icon, in the |cffffd100/wa|r window, the Guide, the chat and the minimap."] = "- Neue Farben und ein neues Symbol im Fenster |cffffd100/wa|r, im Leitfaden, im Chat und an der Minikarte."
L["- Two more ways to open it: the addon menu of the minimap, and a page in Options > AddOns."] = "- Zwei weitere Wege, es zu öffnen: das Addon-Menü der Minikarte und eine Seite unter Optionen > AddOns."
L["Nothing else changes: |cffffd100/wa|r, your auras, their positions and the Wago imports work as before."] = "Sonst ändert sich nichts: |cffffd100/wa|r, eure Auren, ihre Positionen und die Wago-Importe funktionieren wie bisher."
L["Open Musca Auras"] = "Musca Auras öffnen"
L["You can also type |cffffd100/wa|r in the chat, or click the icon of the minimap."] = "Ihr könnt auch |cffffd100/wa|r im Chat eingeben oder auf das Symbol an der Minikarte klicken."
L["The Cooldown Manager configuration was updated by Musca Auras. Reload the UI to finish."] = "Die Konfiguration des Abklingzeitmanagers wurde von Musca Auras aktualisiert. Ladet das Interface neu, um abzuschließen."
L["|cffffd100Everything you need to learn Musca Auras on WoW Forever:|r how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import.\n\nOpen this guide again with the |cffffd100Guide|r button at the top of the |cffffd100/wa|r window, or with |cffffd100/wa tutorial|r."] = "|cffffd100Alles, was du brauchst, um Musca Auras auf WoW Forever zu lernen:|r wie eine Aura funktioniert, was sich im Kampf geändert hat, was funktioniert und was nicht, Rezepte Schritt für Schritt und fertige Auren zum Importieren.\n\nÖffne diese Anleitung erneut über die Schaltfläche |cffffd100Leitfaden|r oben im |cffffd100/wa|r-Fenster oder mit |cffffd100/wa tutorial|r."
L["How Musca Auras works on WoW Forever, and how to build auras that keep working in combat.\n\nWoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data from addons. This guide explains what that changes and gives step-by-step recipes.\n\nSection 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game."] = "Wie Musca Auras auf WoW Forever funktioniert und wie du Auren baust, die im Kampf weiter funktionieren.\n\nWoW Forever sieht aus wie Classic, läuft aber auf der modernen Spiel-Engine 12.1. Diese Engine verbirgt die meisten Kampfdaten vor Addons. Diese Anleitung erklärt, was das ändert, und enthält Rezepte Schritt für Schritt.\n\nAbschnitt 3 nennt, was in Forever im Spiel getestet wurde und was nicht. Wenn du dir nicht sicher bist, teste im Spiel."
L["1. Musca Auras in 2 minutes"] = "1. Musca Auras in 2 Minuten"
L["An aura is something Musca Auras shows on your screen: an icon, a bar, a text or a texture. Every aura has 4 parts, one per tab in the options:\n\n- |cffffd100Display|r: What it looks like: icon, size, colors, text.\n- |cffffd100Trigger|r: When it shows: a buff, a cooldown, a cast, an item count, a game event.\n- |cffffd100Conditions|r: What changes while it is shown, for example red when less than 3 seconds remain.\n- |cffffd100Load|r: When Musca Auras even looks at it: class, in combat, in a group, zone.\n\nThe |cffffd100Actions|r tab adds a sound, a chat message or a glow when the aura shows or hides.\n\nBasic steps:\n\n1. Type |cff99ccff/wa|r.\n2. Click |cffffd100New|r, then choose a display type: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r or |cffffd100Texture|r.\n3. Fill in the |cffffd100Trigger|r tab.\n4. Set the |cffffd100Load|r tab, so the aura only loads when it is useful.\n5. Close the options and test."] = "Eine Aura ist etwas, das Musca Auras auf deinem Bildschirm anzeigt: ein Symbol, eine Leiste, ein Text oder eine Textur. Jede Aura hat 4 Teile, je einen pro Reiter in den Optionen:\n\n- |cffffd100Anzeige|r: Wie sie aussieht: Symbol, Größe, Farben, Text.\n- |cffffd100Auslöser|r: Wann sie angezeigt wird: ein Buff, eine Abklingzeit, ein Zauber, eine Gegenstandsanzahl, ein Spielereignis.\n- |cffffd100Bedingungen|r: Was sich ändert, während sie angezeigt wird, zum Beispiel rot, wenn weniger als 3 Sekunden übrig sind.\n- |cffffd100Laden|r: Wann Musca Auras sie überhaupt beachtet: Klasse, im Kampf, in einer Gruppe, Zone.\n\nDer Reiter |cffffd100Aktionen|r fügt einen Ton, eine Chatnachricht oder ein Leuchten hinzu, wenn die Aura angezeigt oder verborgen wird.\n\nGrundlegende Schritte:\n\n1. Gib |cff99ccff/wa|r ein.\n2. Klicke auf |cffffd100Neu|r und wähle dann einen Anzeigetyp: |cffffd100Symbol|r, |cffffd100Fortschrittsbalken|r, |cffffd100Text|r oder |cffffd100Textur|r.\n3. Fülle den Reiter |cffffd100Auslöser|r aus.\n4. Stelle den Reiter |cffffd100Laden|r ein, damit die Aura nur geladen wird, wenn sie nützlich ist.\n5. Schließe die Optionen und teste."
L["Place your auras on the screen"] = "Platziere deine Auren auf dem Bildschirm"
L["Type |cff99ccff/wa unlock|r, or click |cffffd100Unlock|r at the top of the |cff99ccff/wa|r window. The screen darkens under a grid and every aura gets a box: drag it where you want. Auras snap to the grid, to the screen edges and to the other auras. Hold |cffffd100Shift|r to turn the snap off. The panel of the selected aura sets its exact position and size. Click |cffffd100Save and quit|r when you are done. Placement mode does not open during combat."] = "Gib |cff99ccff/wa unlock|r ein oder klicke oben im |cff99ccff/wa|r-Fenster auf |cffffd100Entsperren|r. Der Bildschirm wird unter einem Raster abgedunkelt und jede Aura erhält einen Rahmen: Ziehe ihn, wohin du willst. Auren rasten am Raster, an den Bildschirmrändern und an anderen Auren ein. Halte |cffffd100Umschalt|r gedrückt, um das Einrasten auszuschalten. Das Fenster der ausgewählten Aura legt ihre genaue Position und Größe fest. Klicke auf |cffffd100Speichern und beenden|r, wenn du fertig bist. Der Platzierungsmodus lässt sich im Kampf nicht öffnen."
L["2. What changed on Forever"] = "2. Was sich in Forever geändert hat"
L["Secret values"] = "Geheime Werte"
L["During combat, boss encounters and PvP matches, the game gives addons \"secret\" values: Musca Auras receives the data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.\n\nWhat that means for your auras, tested in game on Forever unless marked otherwise:\n\n- |cffffd100The game draws what Musca Auras cannot read.|r Cooldown swipes and numbers, timer bars, and health or power bars keep moving in combat. A text made only of |cff99ccff%p|r and |cff99ccff%t|r (for example |cff99ccff%p|r or |cff99ccff%p / %t|r) is drawn by the game too, as a raw number.\n- |cffffd100Buffs and debuffs are refused to addons in combat.|r An aura that was showing before the pull keeps counting down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.\n- |cffffd100Your own recast restarts the timer.|r When you cast again a buff that you put on yourself, the timer of an Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else. A recast by someone else is not seen.\n- |cffffd100A buff or debuff applied for the first time in combat|r is only seen when combat ends.\n- |cffffd100Logic on secret data keeps its last state.|r A condition such as \"Health < 50%\" keeps the state it had when combat started, then updates when combat ends. The health of a target that is not a player is hidden by the game even out of combat: such a condition on the Target unit never changes. Use \"Show only below (%)\" on the Health trigger instead."] = "Im Kampf, bei Bosskämpfen und in PvP-Kämpfen gibt das Spiel Addons \"geheime\" Werte: Musca Auras erhält die Daten, kann sie aber weder lesen noch vergleichen noch damit rechnen. Außerhalb des Kampfes funktioniert fast alles wie zuvor.\n\nWas das für deine Auren bedeutet, im Spiel auf Forever getestet, sofern nicht anders angegeben:\n\n- |cffffd100Das Spiel zeichnet, was Musca Auras nicht lesen kann.|r Abklingzeit-Animationen und -Zahlen, Timerleisten sowie Lebens- oder Ressourcenleisten bewegen sich im Kampf weiter. Ein Text, der nur aus |cff99ccff%p|r und |cff99ccff%t|r besteht (zum Beispiel |cff99ccff%p|r oder |cff99ccff%p / %t|r), wird ebenfalls vom Spiel gezeichnet, als reine Zahl.\n- |cffffd100Buffs und Debuffs werden Addons im Kampf verweigert.|r Eine Aura, die vor dem Pull angezeigt wurde, zählt von ihrer zuletzt bekannten Zeit weiter herunter. Ihre Stapel bleiben eingefroren. Alles wird nach dem Kampf neu gelesen.\n- |cffffd100Dein eigenes erneutes Wirken startet den Timer neu.|r Wenn du einen Buff, den du auf dich selbst wirkst, erneut wirkst, startet der Timer eines Aura-Auslösers für die Einheit Spieler mit seiner zuletzt bekannten Dauer neu, auch wenn dieser Zauber auf jemand anderen ging. Ein erneutes Wirken durch andere wird nicht erkannt.\n- |cffffd100Ein Buff oder Debuff, der im Kampf zum ersten Mal angewendet wird,|r wird erst nach dem Kampf erkannt.\n- |cffffd100Logik mit geheimen Daten behält ihren letzten Zustand.|r Eine Bedingung wie \"Gesundheit < 50%\" behält den Zustand, den sie bei Kampfbeginn hatte, und wird nach dem Kampf aktualisiert. Die Gesundheit eines Ziels, das kein Spieler ist, wird vom Spiel auch außerhalb des Kampfes verborgen: Eine solche Bedingung auf die Einheit Ziel ändert sich nie. Verwende stattdessen \"Nur unterhalb von (%) anzeigen\" beim Auslöser Gesundheit."
L["The combat log is closed"] = "Das Kampflog ist geschlossen"
L["Triggers that use the combat log (|cff99ccffCLEU|r, \"Combat Log\") never fire. For damage taken, use the event |cff99ccffUNIT_COMBAT:player|r."] = "Auslöser, die das Kampflog verwenden (|cff99ccffCLEU|r, \"Kampflog\"), werden nie ausgelöst. Für erlittenen Schaden verwende das Ereignis |cff99ccffUNIT_COMBAT:player|r."
L["Other changes"] = "Weitere Änderungen"
L["- |cffffd100Spells by name or ID.|r In the spell lists of an Aura (Modern) trigger, type a spell name in the game language: it becomes the IDs of all its ranks. Elsewhere, name search may not find spells: type the spell ID. Get the ID of your rank out of combat: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic spells have one ID per rank.\n- |cffffd100Talent load options|r list the talents of your own specialization only. Select it alone in the |cffffd100Class and Specialization|r load option first.\n- |cffffd100Chat Message action|r can be blocked during encounters and PvP matches.\n- |cffffd100Old functions in custom code|r no longer exist (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzard Cooldown Manager.|r |cff99ccff/wa cdm|r shows or hides it, out of combat. On the Forever beta it is not enabled for every class: for some classes it has no spell and no buff, and the \"From the Cooldown Manager\" lists of the Cooldown and Aura triggers are empty."] = "- |cffffd100Zauber nach Name oder ID.|r In den Zauberlisten eines Aura-Auslösers (Modern) gib einen Zaubernamen in der Spielsprache ein: Er wird zu den IDs all seiner Stufen. Anderswo findet die Namenssuche Zauber möglicherweise nicht: Gib die Zauber-ID ein. Ermittle die ID deiner Stufe außerhalb des Kampfes: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic-Zauber haben eine ID pro Stufe.\n- |cffffd100Talent-Ladeoptionen|r listen nur die Talente deiner eigenen Spezialisierung auf. Wähle sie zuerst allein in der Ladeoption |cffffd100Klasse und Spezialisierung|r aus.\n- |cffffd100Die Aktion Chatnachricht|r kann bei Bosskämpfen und in PvP-Kämpfen blockiert sein.\n- |cffffd100Alte Funktionen im benutzerdefinierten Code|r gibt es nicht mehr (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Verwende |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzards Cooldown Manager.|r |cff99ccff/wa cdm|r zeigt oder verbirgt ihn, außerhalb des Kampfes. In der Forever-Beta ist er nicht für jede Klasse aktiviert: Bei manchen Klassen hat er weder Zauber noch Buff, und die Listen \"Aus dem Cooldown Manager\" der Auslöser Abklingzeit und Aura sind leer."
L["3. What you can use"] = "3. Was du verwenden kannst"
L["|cffffd100Tested in game, works in combat:|r\n\n- Spell cooldowns: icon swipe and number. With |cffffd100Show Global Cooldown|r, the \"On Global Cooldown\" condition can hide the number during the global cooldown.\n- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.\n- Health bar of your target and power bar of yourself, with a |cff99ccff%p / %t|r text.\n- Swing timer, main hand.\n- Your own casts: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (see the recipes below).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Tested in game:|r\n\n- Temporary weapon enchants (poison, oil, sharpening stone), both hands.\n- |cffffd100Elapsed Time|r filter of the Aura trigger.\n- Bag Space trigger.\n- Role trigger (role chosen in the group finder).\n- |cff99ccff/wa cdm|r, and the \"From the Cooldown Manager\" lists, for the classes that have it.\n\n|cffffd100Works, with limits:|r\n\n- Stacks stay frozen in combat.\n- Conditions and filters on percentages, stacks or remaining time use the value from before combat.\n- A filter checked in the trigger itself (for example \"Health (%) < 50\") freezes the trigger in combat instead of hiding the aura.\n\n|cffffd100Not tested in game yet:|r\n\n- Swing timer off hand, ranged and wand, \"Target In Range\" option.\n- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.\n- Border and icon colored by dispel type.\n- Aura triggers in party or raid mode, glows, range conditions.\n- Encounter start and end: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Does not work:|r\n\n- Aura trigger filtered by |cffffd100Game Categories|r (crowd control, cast by me...): nothing shows at the moment.\n- Other players' casts.\n- Enemy names and IDs in instances.\n- Mana or energy tick timer in combat.\n- Combat log triggers."] = "|cffffd100Im Spiel getestet, funktioniert im Kampf:|r\n\n- Zauber-Abklingzeiten: Symbol-Animation und Zahl. Mit |cffffd100Globale Abklingzeit anzeigen|r kann die Bedingung \"Bei globaler Abklingzeit\" die Zahl während der globalen Abklingzeit verbergen.\n- Buffs auf dir selbst, die vor dem Kampf bekannt waren: Symbol und Timer. Dein eigenes erneutes Wirken startet den Timer neu.\n- Lebensleiste deines Ziels und Ressourcenleiste von dir selbst, mit einem Text |cff99ccff%p / %t|r.\n- Schlagtimer, Haupthand.\n- Deine eigenen Zauber: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (siehe die Rezepte weiter unten).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Im Spiel getestet:|r\n\n- Temporäre Waffenverzauberungen (Gift, Öl, Wetzstein), beide Hände.\n- Filter |cffffd100Verstrichene Zeit|r des Aura-Auslösers.\n- Auslöser Taschenplatz.\n- Auslöser Rolle (in der Gruppensuche gewählte Rolle).\n- |cff99ccff/wa cdm|r und die Listen \"Aus dem Cooldown Manager\" für die Klassen, die ihn haben.\n\n|cffffd100Funktioniert, mit Einschränkungen:|r\n\n- Stapel bleiben im Kampf eingefroren.\n- Bedingungen und Filter auf Prozentwerte, Stapel oder Restzeit verwenden den Wert von vor dem Kampf.\n- Ein Filter, der im Auslöser selbst geprüft wird (zum Beispiel \"Gesundheit (%) < 50\"), friert den Auslöser im Kampf ein, anstatt die Aura zu verbergen.\n\n|cffffd100Im Spiel noch nicht getestet:|r\n\n- Schlagtimer Nebenhand, Fernkampf und Zauberstab, Option \"Ziel in Reichweite\".\n- Auslöser Munition, Ausrüstungshaltbarkeit, Nachverfolgung, Ladeoption Instanzschwierigkeit.\n- Rahmen und Symbol nach Bannart gefärbt.\n- Aura-Auslöser im Gruppen- oder Schlachtzugsmodus, Leuchten, Reichweitenbedingungen.\n- Beginn und Ende eines Bosskampfes: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Funktioniert nicht:|r\n\n- Aura-Auslöser, gefiltert nach |cffffd100Spielkategorien|r (Massenkontrolle, von mir gewirkt...): Im Moment wird nichts angezeigt.\n- Zauber anderer Spieler.\n- Namen und IDs von Feinden in Instanzen.\n- Mana- oder Energie-Tick-Timer im Kampf.\n- Auslöser des Kampflogs."
L["4. New way of thinking: prepare or deduce"] = "4. Eine neue Denkweise: vorbereiten oder ableiten"
L["Stop reading the combat. |cffffd100Prepare|r before the pull, or |cffffd100deduce|r from what you do.\n\n- Debuff on target, show its timer: You cast the DoT, start a fixed timer\n- Buff missing in combat, alert: Check buffs and consumables before the pull\n- Boss casts X, alert: Boss timeline from the pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown ready, flash: Let the action bar show the cooldown\n- Low mana, alert: Power trigger, \"Show only below (%)\" option\n\nFor debuffs on enemies, the Blizzard nameplates and target frame can show them (\"only my debuffs\"). Use them for what only the game can see."] = "Hör auf, den Kampf zu lesen. Vor dem Pull |cffffd100vorbereiten|r oder aus dem, was du tust, |cffffd100ableiten|r.\n\n- Debuff auf dem Ziel, Timer anzeigen: Du wirkst den DoT, starte einen festen Timer\n- Buff fehlt im Kampf, Warnung: Prüfe Buffs und Verbrauchsgüter vor dem Pull\n- Boss wirkt X, Warnung: Boss-Zeitleiste ab dem Pull (|cff99ccffENCOUNTER_START|r)\n- Abklingzeit bereit, Blinken: Lass die Aktionsleiste die Abklingzeit anzeigen\n- Wenig Mana, Warnung: Auslöser Ressource, Option \"Nur unterhalb von (%) anzeigen\"\n\nFür Debuffs auf Feinden können die Blizzard-Namensplaketten und der Zielrahmen sie anzeigen (\"nur meine Debuffs\"). Nutze sie für das, was nur das Spiel sehen kann."
L["5. Recipe: DoT or buff timer from your cast"] = "5. Rezept: DoT- oder Buff-Timer aus deinem Zauber"
L["Not tested in game yet. No custom code. Example: Corruption on your target.\n\n1. Out of combat, get the ID of your rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Note the |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (or |cffffd100Progress Bar|r).\n3. |cffffd100Trigger|r tab:\n    - Type: |cffffd100Other Events|r, then |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: your spell ID (for example 11672)\n    - |cffffd100Hide when target dies|r: checked\n    - |cffffd100Hide After|r, Duration: the spell duration from its tooltip (Corruption: 18)\n4. Test on any mob.\n\nThe trigger gives the icon of the spell.\n\nLimits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted or dispelled. It follows one target only.\n\n|cffffd100Hide when target dies|r only sees the death of your current target. If you change target and the mob with your DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff on yourself, leave the box unchecked.\n\n|cffffd100Hide when target changes|r hides the timer as soon as you target another mob or clear your target. A target change during a cast is not seen. Targeting the first mob again does not bring the timer back.\n\nA missed or resisted spell still starts the timer: the game reports the cast as succeeded, and the combat log that tells misses is not available to addons on WoW Forever.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Im Spiel noch nicht getestet. Kein benutzerdefinierter Code. Beispiel: Verderbnis auf deinem Ziel.\n\n1. Ermittle außerhalb des Kampfes die ID deiner Stufe: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Notiere die |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100Neu|r, |cffffd100Symbol|r (oder |cffffd100Fortschrittsbalken|r).\n3. Reiter |cffffd100Auslöser|r:\n    - Typ: |cffffd100Andere Ereignisse|r, dann |cffffd100Zauber erfolgreich gewirkt|r\n    - Zaubernde Einheit: |cffffd100Spieler|r\n    - |cffffd100Genaue Zauber-ID(s)|r: deine Zauber-ID (zum Beispiel 11672)\n    - |cffffd100Verbergen, wenn das Ziel stirbt|r: angehakt\n    - |cffffd100Verbergen nach|r, Dauer: die Zauberdauer laut Tooltip (Verderbnis: 18)\n4. Teste an einem beliebigen Gegner.\n\nDer Auslöser liefert das Symbol des Zaubers.\n\nEinschränkungen: eine Aura pro Zauber. Erneutes Wirken startet den Timer neu. Die Aura weiß nicht, ob der Zauber widerstanden oder gebannt wurde. Sie verfolgt nur ein Ziel.\n\n|cffffd100Verbergen, wenn das Ziel stirbt|r sieht nur den Tod deines aktuellen Ziels. Wenn du das Ziel wechselst und der Gegner mit deinem DoT stirbt, läuft der Timer weiter. Wenn du das Ziel wechselst und das neue Ziel stirbt, wird der Timer verborgen. Für einen Buff auf dir selbst lass das Kästchen leer.\n\n|cffffd100Verbergen, wenn das Ziel wechselt|r verbirgt den Timer, sobald du einen anderen Gegner anvisierst oder dein Ziel aufhebst. Ein Zielwechsel während eines Zaubers wird nicht erkannt. Den ersten Gegner erneut anzuvisieren bringt den Timer nicht zurück.\n\nEin verfehlter oder widerstandener Zauber startet den Timer trotzdem: Das Spiel meldet den Zauber als erfolgreich, und das Kampflog, das Fehlschläge anzeigt, steht Addons auf WoW Forever nicht zur Verfügung.\n\nFertiges Beispiel für Feuerbrand Stufe 1 (Zauber-ID 348, 15 Sekunden). Klicke unten auf die Schaltfläche Importieren."
L["Import the DoT timer"] = "DoT-Timer importieren"
L["Variant: one timer per mob, on its nameplate"] = "Variante: ein Timer pro Gegner, auf seiner Namensplakette"
L["Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.\n\n|cffffd100Only with the default Blizzard nameplates.|r Addons that replace the nameplates (EllesmereUI, ElvUI, Plater, Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places. The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the Musca Auras side. With a nameplate addon, use the single timer above.\n\nEnemy nameplates must be shown (key |cffffd100V|r).\n\nHow it works:\n\n- The aura is a |cffffd100Dynamic Group|r with |cffffd100Group by Frame|r set to |cffffd100Nameplates|r, and one icon inside.\n- The icon uses a |cffffd100Trigger State Updater|r on |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- When you cast the spell, the code looks for the nameplate of your target: it tests |cff99ccffnameplate1|r to |cff99ccffnameplate40|r with |cff99ccffUnitIsUnit(token, \"target\")|r, which stays readable in combat. It starts a timer for that nameplate and stores the nameplate in the state (|cff99ccffunit = token|r), so the group puts the icon on it.\n- When a nameplate disappears (the mob died or went out of range), its timer is removed.\n\nLimits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does not know if the spell was resisted or dispelled.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Im Spiel auf Forever getestet. Jeder Gegner, auf den du den Zauber wirkst, erhält ein eigenes Symbol und einen eigenen Timer über seiner Namensplakette.\n\n|cffffd100Nur mit den standardmäßigen Blizzard-Namensplaketten.|r Addons, die die Namensplaketten ersetzen (EllesmereUI, ElvUI, Plater, Kui usw.), verbergen die Blizzard-Lebensleiste, an der diese Aura angeheftet wird: Die Symbole werden dann nirgends oder an zufälligen Stellen angezeigt. Das Spiel erlaubt es Addons nicht, geschützte Bereiche der Namensplaketten zu messen oder daran anzuheften, daher kann Musca Auras das nicht beheben. Mit einem Namensplaketten-Addon verwende den einzelnen Timer weiter oben.\n\nGegnerische Namensplaketten müssen angezeigt werden (Taste |cffffd100V|r).\n\nSo funktioniert es:\n\n- Die Aura ist eine |cffffd100Dynamische Gruppe|r mit |cffffd100Nach Frame gruppieren|r auf |cffffd100Namensplaketten|r und einem Symbol darin.\n- Das Symbol verwendet einen |cffffd100Trigger State Updater|r auf |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- Wenn du den Zauber wirkst, sucht der Code die Namensplakette deines Ziels: Er testet |cff99ccffnameplate1|r bis |cff99ccffnameplate40|r mit |cff99ccffUnitIsUnit(token, \"target\")|r, was im Kampf lesbar bleibt. Er startet einen Timer für diese Namensplakette und speichert sie im Zustand (|cff99ccffunit = token|r), damit die Gruppe das Symbol daran anbringt.\n- Wenn eine Namensplakette verschwindet (der Gegner ist gestorben oder außer Reichweite), wird ihr Timer entfernt.\n\nEinschränkungen: Ein Timer geht verloren, wenn die Namensplakette verschwindet, zum Beispiel wenn du dich vom Gegner entfernst. Die Aura weiß nicht, ob der Zauber widerstanden oder gebannt wurde.\n\nFertiges Beispiel für Feuerbrand Stufe 1 (Zauber-ID 348, 15 Sekunden). Klicke unten auf die Schaltfläche Importieren."
L["Import the nameplate DoT timer"] = "DoT-Timer auf Namensplakette importieren"
L["6. Recipe: pre-pull checklist"] = "6. Rezept: Checkliste vor dem Pull"
L["The idea: one group of icons that shows what is missing, only out of combat and in a group.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Name it \"Pre-pull\".\n2. In the group, |cffffd100Load|r tab: |cffffd100In Combat|r unchecked twice (the box shows a cross = \"not in combat\"), |cffffd100In Group|r checked.\n3. Add one icon per check, inside the group.\n\n|cffffd100Missing buff|r (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):\n\n- Trigger type: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.\n- Show On: |cffffd100Aura(s) Missing|r\n\n|cffffd100Weapon enchant|r (poison, oil, stone): trigger |cffffd100Weapon Enchant|r, show when missing.\n\n|cffffd100Reagents and ammo|r (Soul Shards, arrows, Symbol of Kings...):\n\n- Trigger type: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: the item ID\n- Count: lower than the number you want, for example |cff99ccff< 5|r\n\nBecause the group only loads out of combat, secret data never matters here.\n\nReady-made example for a Warlock (tested in game on Forever). Click the import button below.\n\n- Fortitude: the buff is missing (every rank, Prayer of Fortitude included) (in a party or raid)\n- Mark of the Wild: the buff is missing (every rank, Gift of the Wild included) (in a party or raid)\n- Arcane Intellect: the buff is missing (every rank, Arcane Brilliance included) (in a party or raid)\n- Demon Skin / Armor: neither Demon Skin nor Demon Armor is active (Warlock, solo included)\n- Soul Shards: fewer than 3 Soul Shards (item 6265) in your bags (Warlock, solo included)\n\nNone of them loads in combat. Buffs are matched by spell ID, so the group works with any client language. The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it."] = "Die Idee: eine Gruppe von Symbolen, die zeigt, was fehlt, nur außerhalb des Kampfes und in einer Gruppe.\n\n1. |cff99ccff/wa|r, |cffffd100Neu|r, |cffffd100Dynamische Gruppe|r. Nenne sie \"Pre-pull\".\n2. In der Gruppe, Reiter |cffffd100Laden|r: |cffffd100Im Kampf|r zweimal abgewählt (das Kästchen zeigt ein Kreuz = \"nicht im Kampf\"), |cffffd100In Gruppe|r angehakt.\n3. Füge pro Prüfung ein Symbol in die Gruppe ein.\n\n|cffffd100Fehlender Buff|r (Machtwort: Seelenstärke, Mal der Wildnis, Arkane Intelligenz, Segen, Dornen, Fläschchen, Essen):\n\n- Auslösertyp: |cffffd100Aura|r\n- Einheit: |cffffd100Spieler|r, Typ: |cffffd100Buff|r\n- Aurenname oder Zauber-ID: der Buff. Bei Buffs mit Stufen füge jede Stufe hinzu, die du akzeptieren willst.\n- Anzeigen bei: |cffffd100Aura(en) fehlend|r\n\n|cffffd100Waffenverzauberung|r (Gift, Öl, Stein): Auslöser |cffffd100Waffenverzauberung|r, anzeigen, wenn sie fehlt.\n\n|cffffd100Reagenzien und Munition|r (Seelensplitter, Pfeile, Symbol der Könige...):\n\n- Auslösertyp: |cffffd100Gegenstand|r, |cffffd100Gegenstandsanzahl|r\n- Gegenstand: die Gegenstands-ID\n- Anzahl: kleiner als die gewünschte Zahl, zum Beispiel |cff99ccff< 5|r\n\nDa die Gruppe nur außerhalb des Kampfes geladen wird, spielen geheime Daten hier keine Rolle.\n\nFertiges Beispiel für einen Hexenmeister (im Spiel auf Forever getestet). Klicke unten auf die Schaltfläche Importieren.\n\n- Seelenstärke: der Buff fehlt (jede Stufe, Gebet der Seelenstärke eingeschlossen) (in einer Gruppe oder einem Schlachtzug)\n- Mal der Wildnis: der Buff fehlt (jede Stufe, Gabe der Wildnis eingeschlossen) (in einer Gruppe oder einem Schlachtzug)\n- Arkane Intelligenz: der Buff fehlt (jede Stufe, Arkane Brillanz eingeschlossen) (in einer Gruppe oder einem Schlachtzug)\n- Dämonenhaut / Dämonenrüstung: weder Dämonenhaut noch Dämonenrüstung ist aktiv (Hexenmeister, auch solo)\n- Seelensplitter: weniger als 3 Seelensplitter (Gegenstand 6265) in deinen Taschen (Hexenmeister, auch solo)\n\nKeine davon wird im Kampf geladen. Buffs werden anhand der Zauber-ID erkannt, daher funktioniert die Gruppe mit jeder Client-Sprache. Die IDs stammen aus den Daten von Classic 1.12: Wenn ein Symbol sichtbar bleibt, obwohl du den Buff hast, melde es."
L["Import the pre-pull checklist"] = "Checkliste vor dem Pull importieren"
L["7. Recipe: boss timeline"] = "7. Rezept: Boss-Zeitleiste"
L["Not tested in game yet.\n\n1. Find the encounter ID. Out of combat, create a test aura on |cff99ccffENCOUNTER_START|r and print the ID, or search it on Wowhead.\n2. For each boss ability, create a |cffffd100Progress Bar|r:\n    - Trigger type: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: the time of the first cast after the pull, in seconds.\n3. |cffffd100Load|r tab: |cffffd100Encounter ID(s)|r = the same ID. The aura unloads when the encounter ends, so a wipe does not leave the bar on screen.\n4. If a readable event marks a new phase (an emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use it to restart the timers.\n\nAbilities based on boss health % or on random timings cannot be predicted."] = "Im Spiel noch nicht getestet.\n\n1. Finde die Begegnungs-ID. Erstelle außerhalb des Kampfes eine Testaura auf |cff99ccffENCOUNTER_START|r und gib die ID aus, oder suche sie auf Wowhead.\n2. Erstelle für jede Boss-Fähigkeit einen |cffffd100Fortschrittsbalken|r:\n    - Auslösertyp: |cffffd100Benutzerdefiniert|r, Ereignistyp: |cffffd100Ereignis|r\n    - Ereignis(se): |cff99ccffENCOUNTER_START|r\n    - Benutzerdefinierter Auslöser:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- durch die Begegnungs-ID des Bosses ersetzen|r\n|cff99ccff    end|r\n\n    - Verbergen: |cffffd100Zeitgesteuert|r, Dauer: die Zeit bis zum ersten Zauber nach dem Pull, in Sekunden.\n3. Reiter |cffffd100Laden|r: |cffffd100Begegnungs-ID(s)|r = dieselbe ID. Die Aura wird entladen, wenn die Begegnung endet, daher bleibt nach einem Wipe die Leiste nicht auf dem Bildschirm.\n4. Wenn ein lesbares Ereignis eine neue Phase markiert (ein Emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), verwende es, um die Timer neu zu starten.\n\nFähigkeiten, die auf dem Lebensprozentsatz des Bosses oder auf zufälligen Zeitpunkten beruhen, lassen sich nicht vorhersagen."
L["8. Custom code"] = "8. Benutzerdefinierter Code"
L["In custom code, check every value before you compare it or do math with it:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nWithout this check, the code stops with a Lua error in combat. Musca Auras does not show those errors: the aura just keeps its last state.\n\nIn combat, the |cff99ccffC_UnitAuras|r functions refuse addon code when auras are secret. They stop the code with \"Auras cannot be accessed when secret while tainted\" (tested in game): call them under |cff99ccffpcall|r, or only out of combat.\n\nFor health events, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r does not exist on Forever.\n\nOther tools:\n\n- |cff99ccff/dump <expression>|r shows the content of a value in chat, secret values included.\n- |cff99ccff/eventtrace|r shows events and which of their values are secret.\n- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend."] = "Prüfe im benutzerdefinierten Code jeden Wert, bevor du ihn vergleichst oder damit rechnest:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nOhne diese Prüfung bricht der Code im Kampf mit einem Lua-Fehler ab. Musca Auras zeigt diese Fehler nicht an: Die Aura behält einfach ihren letzten Zustand.\n\nIm Kampf verweigern die Funktionen von |cff99ccffC_UnitAuras|r Addon-Code, wenn Auren geheim sind. Sie brechen den Code mit \"Auras cannot be accessed when secret while tainted\" ab (im Spiel getestet): Rufe sie unter |cff99ccffpcall|r auf oder nur außerhalb des Kampfes.\n\nFür Gesundheitsereignisse verwende |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r existiert in Forever nicht.\n\nWeitere Werkzeuge:\n\n- |cff99ccff/dump <expression>|r zeigt den Inhalt eines Wertes im Chat an, auch geheime Werte.\n- |cff99ccff/eventtrace|r zeigt Ereignisse und welche ihrer Werte geheim sind.\n- In Forever gibt es keine Trainingspuppen. Teste im echten Kampf: Greife einen beliebigen Gegner an oder fordere einen Freund zum Duell heraus."
L["9. Importing auras from Wago"] = "9. Auren von Wago importieren"
L["Most packs made for Classic Era, Season of Discovery or Retail need work:\n\n- replace combat log triggers (section 5 for DoTs, |cff99ccffUNIT_COMBAT:player|r for damage taken);\n- replace spell names by the spell IDs of your ranks;\n- rewrite custom code that calls old functions;\n- move buff and consumable checks out of combat (section 6).\n\nFound an aura that should work and does not? Report it: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"] = "Die meisten Pakete, die für Classic Era, Saison der Entdeckungen oder Retail gemacht wurden, brauchen Nacharbeit:\n\n- Auslöser des Kampflogs ersetzen (Abschnitt 5 für DoTs, |cff99ccffUNIT_COMBAT:player|r für erlittenen Schaden);\n- Zaubernamen durch die Zauber-IDs deiner Stufen ersetzen;\n- benutzerdefinierten Code, der alte Funktionen aufruft, neu schreiben;\n- Buff- und Verbrauchsgut-Prüfungen aus dem Kampf herausnehmen (Abschnitt 6).\n\nEine Aura gefunden, die funktionieren sollte und es nicht tut? Melde sie: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"
L["10. Coming from ForeverAuras"] = "10. Wechsel von ForeverAuras"
L["Export your auras from ForeverAuras, then paste the strings in the Musca Auras import window. Groups work too.\nMusca Auras converts them on import, and lists in the chat what it could not convert.\n\nWhat each one becomes:\n\n- Cooldown Manager trigger, cooldown: Cooldown trigger (spell ID, or name if ForeverAuras used names)\n- Cooldown Manager trigger, buff: Aura trigger (your buffs, or your debuffs on the target)\n- Cooldown Manager trigger, item: Item cooldown trigger\n- Aura (Blizzard) trigger: Aura trigger with Game Categories (sorting removed). Game Categories shows nothing at the moment.\n- Dispel type icon: Dispel Type Icon sub element\n- Dispel type border: Border colored by dispel type\n- Swing Timer, Ammo: same triggers (Ammo: the item list now filters the equipped ammo)\n- Role, Tracking, Equipment Durability, Bag Space: same triggers (Tracking: by spell ID only, no \"always\" mode)\n\nNot converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one.\nDo not run both addons at the same time."] = "Exportiere deine Auren aus ForeverAuras und füge die Zeichenketten dann im Importfenster von Musca Auras ein. Gruppen funktionieren ebenfalls.\nMusca Auras konvertiert sie beim Import und listet im Chat auf, was es nicht konvertieren konnte.\n\nWas aus den einzelnen Elementen wird:\n\n- Cooldown-Manager-Auslöser, Abklingzeit: Auslöser Abklingzeit (Zauber-ID oder Name, falls ForeverAuras Namen verwendete)\n- Cooldown-Manager-Auslöser, Buff: Aura-Auslöser (deine Buffs oder deine Debuffs auf dem Ziel)\n- Cooldown-Manager-Auslöser, Gegenstand: Auslöser Gegenstands-Abklingzeit\n- Auslöser Aura (Blizzard): Aura-Auslöser mit Spielkategorien (Sortierung entfernt). Spielkategorien zeigt im Moment nichts an.\n- Symbol Bannart: Unterelement Symbol Bannart\n- Rahmen Bannart: nach Bannart gefärbter Rahmen\n- Schlagtimer, Munition: dieselben Auslöser (Munition: Die Gegenstandsliste filtert jetzt die angelegte Munition)\n- Rolle, Nachverfolgung, Ausrüstungshaltbarkeit, Taschenplatz: dieselben Auslöser (Nachverfolgung: nur nach Zauber-ID, kein Modus \"immer\")\n\nNicht konvertiert: TimelineParser-Auslöser (sie benötigen das Addon ExRT_Reminder und eine Boss-Zeitleiste, die WoW Forever nicht anzeigt). Ein Cooldown-Manager-Abklingzeit-Auslöser mit mehreren Zaubern behält den ersten.\nBetreibe nicht beide Addons gleichzeitig."
L["|cff00ccffMusca Auras|r - Guide"] = "|cff00ccffMusca Auras|r - Anleitung"
L["Show always"] = "Immer anzeigen"
L["Show in combat"] = "Im Kampf anzeigen"
L["Show out of combat"] = "Außerhalb des Kampfes anzeigen"
L["Enable"] = "Aktivieren"
L["Disable"] = "Deaktivieren"
L["Edit in /wa"] = "In /wa bearbeiten"
L["Click the aura %s will follow. Right click: cancel."] = "Klicke auf die Aura, der %s folgen soll. Rechtsklick: abbrechen."
L["Keep the changes made to the placement of your auras?"] = "Änderungen an der Platzierung deiner Auren behalten?"
L["Save and quit"] = "Speichern und beenden"
L["Discard"] = "Verwerfen"
L["Snap"] = "Einrasten"
L["Revert"] = "Zurücksetzen"
L["Quit"] = "Beenden"
L["Placement mode suspended during combat."] = "Platzierungsmodus während des Kampfes pausiert."
L["Close the Edit Mode first."] = "Schließe zuerst den Bearbeitungsmodus."
L["Anchor to..."] = "Anheften an..."
L["Remove Anchor"] = "Anheftung entfernen"
L["Its groups"] = "Ihre Gruppen"
L["Drag: moves the whole group. Click inside: selects one level lower."] = "Ziehen: verschiebt die ganze Gruppe. Hineinklicken: wählt eine Ebene tiefer aus."
L["Follows: %s"] = "Folgt: %s"
L["Follows: its group"] = "Folgt: ihrer Gruppe"
L["Follows: the screen"] = "Folgt: dem Bildschirm"
L["The placement mode does not open during combat."] = "Der Platzierungsmodus lässt sich im Kampf nicht öffnen."
L["Unlock"] = "Entsperren"
L["Opens the placement mode (/wa unlock): move, size and anchor the auras on the screen."] = "Öffnet den Platzierungsmodus (/wa unlock): Auren auf dem Bildschirm verschieben, in der Größe ändern und anheften."
L["Guide"] = "Leitfaden"
L["Guide:"] = "Leitfaden:"
L["learn Musca Auras"] = "Musca Auras lernen"
L["Musca Auras Guide"] = "Musca Auras-Leitfaden"
L["Learn everything about Musca Auras on WoW Forever: how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import."] = "Alles über Musca Auras auf WoW Forever: wie eine Aura funktioniert, was sich im Kampf geändert hat, was geht und was nicht, Rezepte Schritt für Schritt und fertige Auren zum Importieren."
L["/wa tutorial - Guide: learn everything about Musca Auras on WoW Forever, with auras to import"] = "/wa tutorial - Leitfaden: alles über Musca Auras auf WoW Forever lernen, mit Auren zum Importieren"
L["/wa cdm - Show or hide the Blizzard Cooldown Manager"] = "/wa cdm - Den Abklingzeitmanager von Blizzard ein- oder ausblenden"
L["/wa unlock - Place your auras on the screen: move, resize, anchor them to each other"] = "/wa unlock - Eure Auren auf dem Bildschirm platzieren: verschieben, Größe ändern, aneinander verankern"
L["/wa demo [aura name] - Show every loaded aura, or one aura, with sample timers to set up your layout"] = "/wa demo [Auraname] - Alle geladenen Auren oder eine Aura mit Beispieltimern zeigen, um das Layout einzurichten"
L["/wa backups - List the daily copies of your auras"] = "/wa backups - Die täglichen Kopien eurer Auren auflisten"
L["/wa restore <number> - Replace your auras with a daily copy and reload the UI"] = "/wa restore <Nummer> - Eure Auren durch eine tägliche Kopie ersetzen und das Interface neu laden"
L["/wa deleted - List the auras deleted in the last 30 days"] = "/wa deleted - Die in den letzten 30 Tagen gelöschten Auren auflisten"
L["/wa undelete <number> - Import a deleted aura again"] = "/wa undelete <Nummer> - Eine gelöschte Aura erneut importieren"
L["Time in Musca Auras: %.2fs / %ds (%.1f%%)"] = "Zeit in Musca Auras: %.2fs / %ds (%.1f%%)"

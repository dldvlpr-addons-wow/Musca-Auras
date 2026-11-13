if (GAME_LOCALE or GetLocale()) ~= "itIT" then
  return
end

local L = WeakAuras.L

-- WeakAuras
--[[Translation missing --]]
L[ [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=] ] = [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=]
L["%s Overlay Color"] = "%s Colore Overlay"
L["* Suffix"] = "* Suffisso"
L["/wa help - Show this message"] = "/wa help - Mostra questo messaggio"
L["/wa minimap - Toggle the minimap icon"] = "/wa minimap - Mostra/Nascondi l'icona della minimappa"
L["/wa pprint - Show the results from the most recent profiling"] = "/wa pprint - Mostra i risultati del più recente profiling"
L["/wa pstart - Start profiling. Optionally include a duration in seconds after which profiling automatically stops. To profile the next combat/encounter, pass a \"combat\" or \"encounter\" argument."] = "/wa pstart - Inizia il profiling. Si può includere una durata in secondi dopo la quale il profiling termina automaticamente. Per profilare il prossimo combattimento, passare un argomento ''combat'' o ''encounter''."
L["/wa pstop - Finish profiling"] = "/wa pstop - Termina il profiling"
L["/wa repair - Repair tool"] = "/wa riparazione - Strumento di riparazione"
L["|cffeda55fLeft-Click|r to toggle showing the main window."] = "|cffeda55fClick Sinistro|r per mostrare/nascondere la finestra principale."
L["|cffeda55fMiddle-Click|r to toggle the minimap icon on or off."] = "|cffeda55fClick Centrale|r per mostrare/nascondere l'icona della minimappa."
L["|cffeda55fRight-Click|r to toggle performance profiling window."] = "|cffeda55fFare clic con il pulsante destro del mouse|r per attivare/disattivare la finestra di profilazione delle prestazioni."
L["|cffeda55fShift-Click|r to pause addon execution."] = "|cffeda55fShift Click|r per mettere in pausa l'addon."
--[[Translation missing --]]
L["|cffff0000deprecated|r"] = "|cffff0000deprecated|r"
L["|cFFFF0000Not|r Item Bonus Id Equipped"] = "|cFFFF0000Not|r Bonus Id oggetto equipaggiato"
L["|cFFFF0000Not|r Item Equipped"] = "|cFFFF0000Not|r Oggetto Equipaggiato "
L["|cFFFF0000Not|r Player Name/Realm"] = "|cFFFF0000Not|r Nome Giocatore/Reame"
L["|cFFFF0000Not|r Spell Known"] = "|cFFFF0000Not|r Incantesimo Conosciuto"
--[[Translation missing --]]
L[ [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=] ] = [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=]
L["|cFFffcc00Extra Options:|r %s"] = "|cFFffcc00Opzioni Extra:|r %s"
L["|cFFffcc00Extra Options:|r None"] = "|cFFffcc00Opzioni Extra:|r Nessuna"
L[ [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=] ] = "• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r e |cff00ff00Pet|r corrispondono direttamente a quei singoli unitID.  • |cff00ff00Unità specifica|r consente di fornire uno specifico ID unità valido da guardare.  |cffff0000Nota|r: il gioco non attiverà eventi per tutti gli unitID validi, rendendone alcuni non tracciabili da questa attivazione.  • |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r e |cffffff00Nameplate|r possono corrispondere a più ID unità corrispondenti.  • |cffffff00Smart Group|r si adatta al tipo di gruppo corrente, abbinando solo il \"giocatore\" in modalità solista, le unità \"party\" (incluso il \"giocatore\") in un party o le unità \"raid\" in un raid.  |cffffff00*|r Le impostazioni dell'unità gialla creeranno cloni per ciascuna unità corrispondente mentre questa attivazione fornisce informazioni dinamiche all'aura."
L["1. Profession 1. Accessory"] = "1. Professione 1. Accessorio"
L["1. Profession 2. Accessory"] = "1. Professione 2. Accessorio"
L["1. Professsion Tool"] = "1. Strumento Professione "
L["10 Man Raid"] = "Incursione da 10 giocatori"
L["10 Player Raid"] = "Raid da 10 giocatori"
L["10 Player Raid (Heroic)"] = "Raid da 10 giocatori (Eroico)"
L["10 Player Raid (Normal)"] = "Raid da 10 giocatori (Normale)"
L["2. Profession 1. Accessory"] = "2. Professione 1. Accessorio"
L["2. Profession 2. Accessory"] = "2. Professione 2. Accessorio"
L["2. Professsion Tool"] = "2. Strumento Professione"
L["20 Man Raid"] = "incursione da 20 giocatori"
L["20 Player Raid"] = "Raid da 20 giocatori"
L["25 Man Raid"] = "Incursione da 25 giocatori"
L["25 Player Raid"] = "Raid da 25 giocatori"
L["25 Player Raid (Heroic)"] = "Raid da 25 giocatori (Eroico)"
L["25 Player Raid (Normal)"] = "Raid da 25 giocatori (Normale)"
--[[Translation missing --]]
L["25 Player Raid (Titan Reforged)"] = "25 Player Raid (Titan Reforged)"
L["40 Man Raid"] = "incursione da 40 giocatori"
L["40 Player Raid"] = "Raid da 40 giocatori"
L["5 Man Dungeon"] = "Spedizione da 5 giocatori"
L[ [=[A detailed overview of your auras and Musca Auras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=] ] = "Una panoramica dettagliata delle tue aure e dei sistemi Musca Auras, Copia l'intero testo su Discord di Weakaura se hai bisogno di assistenza."
--[[Translation missing --]]
L["A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."] = "A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."
L["Abbreviate"] = "Abbreviare"
L["AbbreviateLargeNumbers (Blizzard)"] = "AbbreviareGrandiNumeri (Blizzard)"
L["AbbreviateNumbers (Blizzard)"] = "Abbreviare i numeri (Blizzard)"
L["Absorb"] = "Assorbimento"
--[[Translation missing --]]
L["Absorb and Healing"] = "Absorb and Healing"
L["Absorbed"] = "Assorbito"
L["Action Button Glow"] = "Bagliore Pulsante Azioni"
L["Actions"] = "Azioni"
L["Active"] = "Attivo"
L[ [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = "Componente aggiuntivo mod boss attivo: |cFFffcc00BigWigs|r Nota: Questa attivazione utilizzerà BigWigs o DBM, in quest'ordine se entrambi sono installati."
L[ [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = "Componente aggiuntivo mod boss attivo: |cFFffcc00DBM|r Nota: questa attivazione utilizzerà BigWigs o DBM, in quest'ordine se entrambi sono installati."
L["Add"] = "Aggiungi"
L["Add Missing Auras"] = "Aggiungi Aure Mancanti"
L["Advanced Caster's Target Check"] = "Controllo del bersaglio dell'incantatore avanzato"
L["Affected"] = "Affetto"
L["Affected Unit Count"] = "Conta Unità Interessate"
--[[Translation missing --]]
L["Afk"] = "Afk"
L["Aggro"] = "Aggro"
L["Agility"] = "Agilità"
L["Ahn'Qiraj"] = "Ahn'Qiraj"
--[[Translation missing --]]
L["Alert Type"] = "Tipo di Allerta"
L["Alive"] = "Vivo"
L["All"] = "Tutto"
L["All children of this aura will also not be loaded, to minimize the chance of further corruption."] = "Anche tutti i bambini di quest'aura non verranno caricati, per ridurre al minimo la possibilità di ulteriore corruzione."
--[[Translation missing --]]
L["All States table contains a non table at key: '%s'."] = "All States table contains a non table at key: '%s'."
L["All Triggers"] = "Tutte le attivazioni"
L["Alliance"] = "Alleanza"
L["Alpha"] = "Alfa"
L["Always"] = "Sempre"
L["Always active trigger"] = "Innesco sempre attivo"
L["Always include realm"] = "Includi sempre il reame"
L["Always True"] = "Sempre Vero"
L["Amount"] = "Quantità"
L["Anchoring"] = "Ancoraggio"
L["And Talent"] = "E Talento "
--[[Translation missing --]]
L["Angle and Radius"] = "Angolo e Raggio"
L["Animations"] = "Animazioni"
L["Anticlockwise"] = "Antiorario"
--[[Translation missing --]]
L["Anub'Rekhan"] = "Anub'Rekhan"
L["Any"] = "Qualsiasi"
L["Any Triggers"] = "Qualsiasi attivazione"
--[[Translation missing --]]
L["AOE"] = "AOE"
L["Arcane Resistance"] = "Resistenza Arcana"
--[[Translation missing --]]
L[ [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=] ] = "Vuoi eseguire lo strumento di riparazione |cffff0000EXPERIMENTAL|r? Ciò sovrascriverà tutte le modifiche apportate dall'ultimo aggiornamento del database. Ultimo aggiornamento: %s"
L["Arena"] = "Arena"
L["Armor Rating"] = "Grado di armatura"
--[[Translation missing --]]
L["Array"] = "Array"
L["Ascending"] = "Crescente"
L["Assigned Role"] = "Ruolo assegnato"
L["Assigned Role Icon"] = "Icona del ruolo assegnato"
--[[Translation missing --]]
L["Assist"] = "Assist"
L["At Least One Enemy"] = "Almeno un nemico"
L["At missing Value"] = "Al valore mancante"
L["At Percent"] = "In Percentuale"
L["At Value"] = "Al valore"
L["At War"] = "In guerra"
L["Attach to End"] = "Aggiungi alla Fine"
--[[Translation missing --]]
L["Attach to End, backwards"] = "Attach to End, backwards"
--[[Translation missing --]]
L["Attach to Point"] = "Attach to Point"
L["Attach to Start"] = "Aggiungi all'inizio"
L["Attack Power"] = "Potenza d'attacco"
L["Attackable"] = "Attaccabile"
L["Attackable Target"] = "Bersaglio attaccabile"
--[[Translation missing --]]
L["Aura"] = "Aura"
--[[Translation missing --]]
L["Aura '%s': %s"] = "Aura '%s': %s"
L["Aura Applied"] = "Aura applicata"
L["Aura Applied Dose"] = "Parte di aura applicata"
L["Aura Broken"] = "Aura finita"
L["Aura Broken Spell"] = "Aura di magia finita"
L["Aura is using deprecated SetDurationInfo"] = "Aura utilizza SetDurationInfo deprecato"
L["Aura loaded"] = "Aura caricata"
L["Aura Name"] = "Nome Aura"
L["Aura Names"] = "Nomi Aura"
L["Aura Refresh"] = "Aura rinnovata"
L["Aura Removed"] = "Aura rimossa"
L["Aura Removed Dose"] = "Parte di aura rimossa"
L["Aura Stack"] = "Aura Stack"
L["Aura Type"] = "Tipo di aura"
L["Aura Version: %s"] = "Versione dell'aura: %s"
L["Aura(s) Found"] = "Aura(e) Trovata(e)"
L["Aura(s) Missing"] = "Aura(e) Mancante(i)"
L["Aura:"] = "Aura:"
L["Auras"] = "Aure"
L["Auras:"] = "Aure:"
L["Author Options"] = "Opzioni Autore"
--[[Translation missing --]]
L["Auto"] = "Auto"
--[[Translation missing --]]
L["Autocast Shine"] = "Autocast Shine"
L["Automatic"] = "Automatico"
L["Automatic Length"] = "Lunghezza Automatica"
L["Automatic Rotation"] = "Rotazione Automatica"
L["Available features: %s"] = "Funzionalità disponibili: %s"
L["Ayamiss the Hunter"] = "Ayamiss il Cacciatore"
--[[Translation missing --]]
L["Azuregos"] = "Azuregos"
L["Back and Forth"] = "Avanti e indietro"
L["Background"] = "Sfondo"
L["Background Color"] = "Colore Sfondo"
--[[Translation missing --]]
L["Balnazzar"] = "Balnazzar"
--[[Translation missing --]]
L["Bar"] = "Bar"
--[[Translation missing --]]
L["Bar and Icon"] = "Bar and Icon"
L["Bar Color/Gradient Start"] = "Inizio Colore/Inclinazione della Barra"
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
L["Baron Geddon"] = "Barone Geddon"
--[[Translation missing --]]
L["Battle for Azeroth"] = "Battle for Azeroth"
L["Battle.net Whisper"] = "Sussurri di Battle.net"
L["Battleground"] = "Campo di battaglia"
L["Battleguard Sartura"] = "Guardia di battaglia Sartura"
--[[Translation missing --]]
L["Beastmaster"] = "Beastmaster"
--[[Translation missing --]]
L["Beatrix"] = "Beatrix"
--[[Translation missing --]]
L["BG>Raid>Party>Say"] = "BG>Raid>Party>Say"
--[[Translation missing --]]
L["BG-System Alliance"] = "BG-System Alliance"
--[[Translation missing --]]
L["BG-System Horde"] = "BG-System Horde"
--[[Translation missing --]]
L["BG-System Neutral"] = "BG-System Neutral"
L["Big Number"] = "Grande Numero"
L["BigWigs Addon"] = "BigWigs Add-on"
L["BigWigs Message"] = "Messaggio di BigWigs"
--[[Translation missing --]]
L["BigWigs Stage"] = "BigWigs Stage"
L["BigWigs Timer"] = "Timer di BigWigs"
--[[Translation missing --]]
L["Black Wing Lair"] = "Sotterranei dell'Ala Nera"
--[[Translation missing --]]
L["Bleed"] = "Bleed"
L["Blizzard Combat Text"] = "Testo di combattimento Blizzard"
L["Blizzard Cooldown Reduction"] = "Riduzione Cooldown Blizzard"
L["Block"] = "Bloccare"
L["Block (%)"] = "Blocco (%)"
L["Block Value"] = "Valore di Blocco"
L["Blocked"] = "Bloccato"
L["Bloodlord Mandokir"] = "Signore del Sangue Mandokir"
L["Border"] = "Bordo"
L["Boss"] = "Boss"
L["Boss Emote"] = "Boss Emote"
--[[Translation missing --]]
L["Boss Mod Announce"] = "Boss Mod Announce"
--[[Translation missing --]]
L["Boss Mod Stage"] = "Boss Mod Stage"
--[[Translation missing --]]
L["Boss Mod Stage (Event)"] = "Boss Mod Stage (Event)"
--[[Translation missing --]]
L["Boss Mod Timer"] = "Boss Mod Timer"
--[[Translation missing --]]
L["Boss Whisper"] = "Boss Whisper"
L["Bottom"] = "Basso"
L["Bottom Left"] = "Basso a sinistra"
L["Bottom Right"] = "Basso a destra"
L["Bottom to Top"] = "Basso verso l'alto"
L["Bounce"] = "Balzo"
L["Bounce with Decay"] = "Bounce with Decay"
--[[Translation missing --]]
L["Break"] = "Break"
--[[Translation missing --]]
L["BreakUpLargeNumbers (Blizzard)"] = "BreakUpLargeNumbers (Blizzard)"
L["Broodlord Lashlayer"] = "Signore della Progenie Lashlayer"
--[[Translation missing --]]
L["Buff"] = "Buff"
--[[Translation missing --]]
L["Buff/Debuff"] = "Buff/Debuff"
L["Buffed/Debuffed"] = "Buffato/Debuffato"
--[[Translation missing --]]
L["Burning Crusade"] = "Burning Crusade"
--[[Translation missing --]]
L["Buru the Gorger"] = "Buru the Gorger"
--[[Translation missing --]]
L["Caldoran"] = "Caldoran"
L["Callback function"] = "Funzione di richiamata"
L["Can be used for e.g. checking if \"boss1target\" is the same as \"player\"."] = "Può essere usato per esempio per controllare se \"boss1target\" sia uguale a \"player\"."
L["Cancel"] = "Cancella"
L[ [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = "Non è possibile modificare il frame protetto durante il blocco del combattimento. Trova ulteriori informazioni: https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames"
L["Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."] = "Impossibile programmare il timer con %i, a causa di un bug di World of Warcraft con tempi di attività elevati del computer.  (Tempo di attività: %i).  Riavvia il computer."
L["Capped"] = "Limitato"
L["Cast"] = "Cast"
L["Cast Bar"] = "Barra del cast"
L["Cast Failed"] = "Cast fallito"
L["Cast Start"] = "Inizio cast"
L["Cast Success"] = "Cast terminato con successo"
L["Cast Type"] = "Tipo di cast"
--[[Translation missing --]]
L["Caster"] = "Caster"
L["Caster Name"] = "Nome del Caster"
L["Caster Realm"] = "Reame del Caster"
L["Caster Unit"] = "Unità del Caster"
L["Casters Name/Realm"] = "Nome/Reame dei Caster"
L["Caster's Target"] = "Bersaglio dei Caster"
--[[Translation missing --]]
L["Cataclysm"] = "Cataclysm"
--[[Translation missing --]]
L["Ceil"] = "Ceil"
L["Center"] = "Centro"
L["Center, then alternating bottom and top"] = "Al centro, poi alternando il basso e l'alto"
L["Center, then alternating left and right"] = "Al centro, poi alternando sinistra e destra"
L["Center, then alternating right and left"] = "Al centro, poi alternando destra e sinistra"
L["Center, then alternating top and bottom"] = "Al centro, poi alternando la parte superiore e quella inferiore"
L["Centered Horizontal"] = "Centrato orizzontalmente"
L["Centered Horizontal, then Centered Vertical"] = "Centrato orizzontalmente, poi centrato verticalmente"
L["Centered Horizontal, then Down"] = "Centrato orizzontalmente, poi in basso"
L["Centered Horizontal, then Up"] = "Centrato orizzontalmente, poi in alto"
L["Centered Vertical"] = "Centrato verticalmente"
L["Centered Vertical, then Centered Horizontal"] = "Centrato verticalmente, poi centrato orizzontalmente "
L["Centered Vertical, then Left"] = "Centrato verticalmente, poi a sinistra"
L["Centered Vertical, then Right"] = "Centrato verticalmente, poi a destra"
L["Changed"] = "Modificato"
L["Channel"] = "Canale"
L["Channel (Spell)"] = "Canale (Magia)"
L["Character Stats"] = "Statistiche del Personaggio "
L["Character Type"] = "Tipo di carattere"
L["Charge gained/lost"] = "Carica guadagnata/persa"
L["Charges"] = "Cariche"
L["Charges Changed Event"] = "Evento modificato caricato"
L["Chat Frame"] = "Cornice di chat"
L["Chat Message"] = "Messaggio di chat"
L["Check if a single talent match a Rank"] = "Controlla se un singolo talento corrisponde a un grado"
L["Check nameplate's target every 0.2s"] = "Controllare le barre del bersaglio ogni 0,2 s"
--[[Translation missing --]]
L["Chromaggus"] = "Chromaggus"
L["Circle"] = "Cerchio"
--[[Translation missing --]]
L["Circular Texture"] = "Circular Texture"
L["Clamp"] = "Morso"
L["Class"] = "Classe"
L["Class and Specialization"] = "Classe e Specializzazione"
--[[Translation missing --]]
L["Classic"] = "Classic"
L["Classification"] = "Classificazione"
L["Clockwise"] = "Senso Orario"
L["Clone per Event"] = "Clona per evento"
L["Clone per Match"] = "Clona per partita"
--[[Translation missing --]]
L["Coin Precision"] = "Coin Precision"
L["Color"] = "Colore"
L["Color Animation"] = "Animazione a colori"
L["Combat Log"] = "Registro di combattimento"
--[[Translation missing --]]
L["Communities"] = "Communities"
--[[Translation missing --]]
L["Condition Custom Test"] = "Condition Custom Test"
L["Conditions"] = "Condizioni"
L["Contains"] = "Contiene"
L["Continuously update Movement Speed"] = "Aggiorna continuamente la velocità di movimento"
--[[Translation missing --]]
L["Cooldown"] = "Cooldown"
L["Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"] = "Le barre di Cooldown mostrano il tempo trascorso prima che un'abilità sia pronta per essere utilizzata, BigWigs le prefissa con '~'"
--[[Translation missing --]]
L["Cooldown Progress (Item)"] = "Cooldown Progress (Item)"
--[[Translation missing --]]
L["Cooldown Progress (Slot)"] = "Cooldown Progress (Slot)"
L["Cooldown Ready Event"] = "Cooldiwn evento pronto"
L["Cooldown Ready Event (Item)"] = "Cooldown evento pronto (Oggetto)"
L["Cooldown Ready Event (Slot)"] = "Cooldown evento pronto (Slot)"
L["Cooldown Reduction changes the duration of seconds instead of showing the real time seconds."] = "La riduzione del Cooldown modifica la durata dei secondi invece di mostrare i secondi in tempo reale."
L["Cooldown/Charges/Count"] = "Cooldown/Cariche/Conteggio "
--[[Translation missing --]]
L["Copper"] = "Copper"
L["Could not load Musca Auras Archive, the addon is %s"] = "Impossibile caricare l'archivio Musca Auras, il componente aggiuntivo è %s"
L["Count"] = "Conteggio "
L["Counter Clockwise"] = "Conteggio Antiorario"
L["Create"] = "Crea"
L["Critical"] = "Critico"
L["Critical (%)"] = "Critico (%)"
--[[Translation missing --]]
L["Crop X"] = "Crop X"
--[[Translation missing --]]
L["Crop Y"] = "Crop Y"
--[[Translation missing --]]
L["Crowd Controlled"] = "Crowd Controlled"
L["Crushing"] = "Frantumazione "
--[[Translation missing --]]
L["C'thun"] = "C'thun"
L["Cumulated time used during profiling"] = "Tempo cumulativo utilizzato durante la profilazione"
L["Current Experience"] = "Esperienza Attuale"
L["Current Instance"] = "Spedizione Attuale "
L["Current Movement Speed (%)"] = "Velocità di movimento attuale (%)"
L["Current Zone"] = "Zona Attuale "
L["Current Zone Group"] = "Gruppo di Zona Attuale "
L["Curse"] = "Maledizione"
--[[Translation missing --]]
L["Custom"] = "Custom"
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
--[[Translation missing --]]
L["Custom Function"] = "Custom Function"
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
--[[Translation missing --]]
L["Damage"] = "Damage"
--[[Translation missing --]]
L["Damage Shield"] = "Damage Shield"
--[[Translation missing --]]
L["Damage Shield Missed"] = "Damage Shield Missed"
--[[Translation missing --]]
L["Damage Split"] = "Damage Split"
--[[Translation missing --]]
L["DBM Announce"] = "DBM Announce"
--[[Translation missing --]]
L["DBM Stage"] = "DBM Stage"
--[[Translation missing --]]
L["DBM Timer"] = "DBM Timer"
--[[Translation missing --]]
L["Dead"] = "Dead"
--[[Translation missing --]]
L["Debuff"] = "Debuff"
--[[Translation missing --]]
L["Debuff Class"] = "Debuff Class"
--[[Translation missing --]]
L["Debuff Class Icon"] = "Debuff Class Icon"
--[[Translation missing --]]
L["Debuff Type"] = "Debuff Type"
--[[Translation missing --]]
L["Debug Log contains more than 1000 entries"] = "Debug Log contains more than 1000 entries"
--[[Translation missing --]]
L["Debug Logging enabled"] = "Debug Logging enabled"
--[[Translation missing --]]
L["Debug Logging enabled for '%s'"] = "Debug Logging enabled for '%s'"
--[[Translation missing --]]
L["Defensive Stats"] = "Defensive Stats"
--[[Translation missing --]]
L["Deflect"] = "Deflect"
--[[Translation missing --]]
L["Delve"] = "Delve"
--[[Translation missing --]]
L["Desaturate"] = "Desaturate"
--[[Translation missing --]]
L["Desaturate Background"] = "Desaturate Background"
--[[Translation missing --]]
L["Desaturate Foreground"] = "Desaturate Foreground"
--[[Translation missing --]]
L["Descending"] = "Descending"
L["Description"] = "Descrizione"
--[[Translation missing --]]
L["Dest Raid Mark"] = "Dest Raid Mark"
--[[Translation missing --]]
L["Destination Affiliation"] = "Destination Affiliation"
--[[Translation missing --]]
L["Destination GUID"] = "Destination GUID"
--[[Translation missing --]]
L["Destination Info"] = "Destination Info"
--[[Translation missing --]]
L["Destination Name"] = "Destination Name"
--[[Translation missing --]]
L["Destination NPC Id"] = "Destination NPC Id"
--[[Translation missing --]]
L["Destination Object Type"] = "Destination Object Type"
--[[Translation missing --]]
L["Destination Reaction"] = "Destination Reaction"
--[[Translation missing --]]
L["Destination Unit"] = "Destination Unit"
--[[Translation missing --]]
L["Destination unit's raid mark index"] = "Destination unit's raid mark index"
--[[Translation missing --]]
L["Destination unit's raid mark texture"] = "Destination unit's raid mark texture"
--[[Translation missing --]]
L["Difficulty"] = "Difficulty"
--[[Translation missing --]]
L["Disable Spell Known Check"] = "Disable Spell Known Check"
--[[Translation missing --]]
L["Disabled"] = "Disabled"
--[[Translation missing --]]
L["Disabled feature %q"] = "Disabled feature %q"
--[[Translation missing --]]
L["Disabled Spell Known Check"] = "Disabled Spell Known Check"
--[[Translation missing --]]
L["Disease"] = "Disease"
--[[Translation missing --]]
L["Dispel"] = "Dispel"
--[[Translation missing --]]
L["Dispel Failed"] = "Dispel Failed"
--[[Translation missing --]]
L["Display"] = "Display"
L["Distance"] = "Distanza"
--[[Translation missing --]]
L["Do Not Disturb"] = "Do Not Disturb"
--[[Translation missing --]]
L["Dodge"] = "Dodge"
--[[Translation missing --]]
L["Dodge (%)"] = "Dodge (%)"
--[[Translation missing --]]
L["Down"] = "Down"
--[[Translation missing --]]
L["Down, then Centered Horizontal"] = "Down, then Centered Horizontal"
--[[Translation missing --]]
L["Down, then Left"] = "Down, then Left"
--[[Translation missing --]]
L["Down, then Right"] = "Down, then Right"
--[[Translation missing --]]
L["Dragonflight"] = "Dragonflight"
--[[Translation missing --]]
L["Drain"] = "Drain"
--[[Translation missing --]]
L["Dropdown Menu"] = "Dropdown Menu"
--[[Translation missing --]]
L["Dumping table"] = "Dumping table"
--[[Translation missing --]]
L["Dungeon (Heroic)"] = "Dungeon (Heroic)"
--[[Translation missing --]]
L["Dungeon (Mythic)"] = "Dungeon (Mythic)"
--[[Translation missing --]]
L["Dungeon (Mythic+)"] = "Dungeon (Mythic+)"
--[[Translation missing --]]
L["Dungeon (Normal)"] = "Dungeon (Normal)"
--[[Translation missing --]]
L["Dungeon (Timewalking)"] = "Dungeon (Timewalking)"
--[[Translation missing --]]
L["Durability Damage"] = "Durability Damage"
--[[Translation missing --]]
L["Durability Damage All"] = "Durability Damage All"
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
--[[Translation missing --]]
L["Edge"] = "Edge"
--[[Translation missing --]]
L["Edge of Madness"] = "Edge of Madness"
--[[Translation missing --]]
L["Effective Spell Id"] = "Effective Spell Id"
--[[Translation missing --]]
L["Elide"] = "Elide"
--[[Translation missing --]]
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
--[[Translation missing --]]
L["Empty"] = "Empty"
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
--[[Translation missing --]]
L["Energize"] = "Energize"
--[[Translation missing --]]
L["Enrage"] = "Enrage"
--[[Translation missing --]]
L["Enter a name or a spellId"] = "Enter a name or a spellId"
--[[Translation missing --]]
L["Entering"] = "Entering"
--[[Translation missing --]]
L["Entering/Leaving Combat"] = "Entering/Leaving Combat"
--[[Translation missing --]]
L["Entering/Leaving Encounter"] = "Entering/Leaving Encounter"
--[[Translation missing --]]
L["Entry Order"] = "Entry Order"
--[[Translation missing --]]
L["Environment Type"] = "Environment Type"
--[[Translation missing --]]
L["Environmental"] = "Environmental"
--[[Translation missing --]]
L["Equipment"] = "Equipment"
--[[Translation missing --]]
L["Equipment Slot"] = "Equipment Slot"
--[[Translation missing --]]
L["Equipped"] = "Equipped"
--[[Translation missing --]]
L["Error"] = "Errore"
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
--[[Translation missing --]]
L["Error Frame"] = "Error Frame"
--[[Translation missing --]]
L["ERROR in '%s' unknown or incompatible sub element type '%s'"] = "ERROR in '%s' unknown or incompatible sub element type '%s'"
--[[Translation missing --]]
L["Error in Aura '%s'"] = "Error in Aura '%s'"
--[[Translation missing --]]
L["Error not receiving display information from %s"] = "Error not receiving display information from %s"
--[[Translation missing --]]
L["Evade"] = "Evade"
L["Event"] = "Evento"
--[[Translation missing --]]
L["Event(s)"] = "Event(s)"
--[[Translation missing --]]
L["Every Frame"] = "Every Frame"
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
--[[Translation missing --]]
L["Extra Amount"] = "Extra Amount"
--[[Translation missing --]]
L["Extra Attacks"] = "Extra Attacks"
--[[Translation missing --]]
L["Extra Spell Id"] = "Extra Spell Id"
--[[Translation missing --]]
L["Extra Spell Name"] = "Extra Spell Name"
--[[Translation missing --]]
L["Faction"] = "Faction"
--[[Translation missing --]]
L["Faction Name"] = "Faction Name"
--[[Translation missing --]]
L["Faction Reputation"] = "Faction Reputation"
--[[Translation missing --]]
L["Fade Animation"] = "Fade Animation"
--[[Translation missing --]]
L["Fade In"] = "Fade In"
--[[Translation missing --]]
L["Fade Out"] = "Fade Out"
--[[Translation missing --]]
L["Fail Alert"] = "Fail Alert"
--[[Translation missing --]]
L["False"] = "False"
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
--[[Translation missing --]]
L["Fire Resistance"] = "Fire Resistance"
--[[Translation missing --]]
L["Firemaw"] = "Firemaw"
--[[Translation missing --]]
L["First"] = "First"
--[[Translation missing --]]
L["First Value of Tooltip Text"] = "First Value of Tooltip Text"
--[[Translation missing --]]
L["Fixed"] = "Fixed"
--[[Translation missing --]]
L["Fixed Names"] = "Fixed Names"
--[[Translation missing --]]
L["Fixed Size"] = "Fixed Size"
--[[Translation missing --]]
L["Flamegor"] = "Flamegor"
--[[Translation missing --]]
L["Flash"] = "Flash"
--[[Translation missing --]]
L["Flex Raid"] = "Flex Raid"
--[[Translation missing --]]
L["Flip"] = "Flip"
--[[Translation missing --]]
L["Floor"] = "Floor"
--[[Translation missing --]]
L["Follower Dungeon"] = "Follower Dungeon"
--[[Translation missing --]]
L["Font"] = "Font"
--[[Translation missing --]]
L["Font Size"] = "Font Size"
--[[Translation missing --]]
L["Forbidden function or table: %s"] = "Forbidden function or table: %s"
--[[Translation missing --]]
L["Foreground"] = "Foreground"
--[[Translation missing --]]
L["Foreground Color"] = "Foreground Color"
L["Form"] = "Forma"
--[[Translation missing --]]
L["Format"] = "Format"
--[[Translation missing --]]
L["Format Gold"] = "Format Gold"
--[[Translation missing --]]
L["Formats |cFFFFCC00%unit|r"] = "Formats |cFFFFCC00%unit|r"
--[[Translation missing --]]
L["Formats Player's |cFFFFCC00%guid|r"] = "Formats Player's |cFFFFCC00%guid|r"
--[[Translation missing --]]
L["Forward"] = "Forward"
--[[Translation missing --]]
L["Forward, Reverse Loop"] = "Forward, Reverse Loop"
--[[Translation missing --]]
L["Fourth Value of Tooltip Text"] = "Fourth Value of Tooltip Text"
--[[Translation missing --]]
L["Frame Selector"] = "Frame Selector"
--[[Translation missing --]]
L["Frequency"] = "Frequency"
--[[Translation missing --]]
L["Friendly"] = "Friendly"
--[[Translation missing --]]
L["Friendly Fire"] = "Friendly Fire"
--[[Translation missing --]]
L["Frost"] = "Frost"
--[[Translation missing --]]
L["Frost Resistance"] = "Frost Resistance"
--[[Translation missing --]]
L["Full"] = "Full"
--[[Translation missing --]]
L["Full Region"] = "Full Region"
--[[Translation missing --]]
L["Full/Empty"] = "Full/Empty"
--[[Translation missing --]]
L["Gahz'ranka"] = "Gahz'ranka"
--[[Translation missing --]]
L["Gained"] = "Gained"
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
--[[Translation missing --]]
L["Glancing"] = "Glancing"
--[[Translation missing --]]
L["Global Cooldown"] = "Global Cooldown"
--[[Translation missing --]]
L["Glow"] = "Glow"
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
--[[Translation missing --]]
L["Gradient"] = "Gradient"
--[[Translation missing --]]
L["Gradient Enabled"] = "Gradient Enabled"
--[[Translation missing --]]
L["Gradient End"] = "Gradient End"
--[[Translation missing --]]
L["Gradient Orientation"] = "Gradient Orientation"
--[[Translation missing --]]
L["Gradient Pulse"] = "Gradient Pulse"
--[[Translation missing --]]
L["Grand Widow Faerlina"] = "Grand Widow Faerlina"
--[[Translation missing --]]
L["Grid"] = "Grid"
--[[Translation missing --]]
L["Grobbulus"] = "Grobbulus"
--[[Translation missing --]]
L["Group"] = "Group"
--[[Translation missing --]]
L["Group Arrangement"] = "Group Arrangement"
--[[Translation missing --]]
L["Group Leader/Assist"] = "Group Leader/Assist"
--[[Translation missing --]]
L["Group Size"] = "Group Size"
--[[Translation missing --]]
L["Group Type"] = "Group Type"
--[[Translation missing --]]
L["Grow"] = "Grow"
--[[Translation missing --]]
L["GTFO Alert"] = "GTFO Alert"
--[[Translation missing --]]
L["Guardian"] = "Guardian"
--[[Translation missing --]]
L["Guild"] = "Guild"
--[[Translation missing --]]
L["Hakkar"] = "Hakkar"
--[[Translation missing --]]
L["Hardcore"] = "Hardcore"
--[[Translation missing --]]
L["Has Target"] = "Has Target"
--[[Translation missing --]]
L["HasPet"] = "HasPet"
--[[Translation missing --]]
L["Haste (%)"] = "Haste (%)"
--[[Translation missing --]]
L["Heal"] = "Heal"
--[[Translation missing --]]
L["Heal Absorbed"] = "Heal Absorbed"
--[[Translation missing --]]
L["Health"] = "Health"
--[[Translation missing --]]
L["Health (%)"] = "Health (%)"
--[[Translation missing --]]
L["Health Deficit"] = "Health Deficit"
--[[Translation missing --]]
L["Heigan the Unclean"] = "Heigan the Unclean"
--[[Translation missing --]]
L["Height"] = "Height"
--[[Translation missing --]]
L["Heroic Party"] = "Heroic Party"
--[[Translation missing --]]
L["Hide"] = "Hide"
--[[Translation missing --]]
L["Hide 0 cooldowns"] = "Hide 0 cooldowns"
--[[Translation missing --]]
L["Hide Timer Text"] = "Hide Timer Text"
--[[Translation missing --]]
L["High Damage"] = "High Damage"
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
L["Higher Than Tank"] = "Higher Than Tank"
--[[Translation missing --]]
L["Highest Spell Id"] = "Highest Spell Id"
--[[Translation missing --]]
L["Holy Resistance"] = "Holy Resistance"
--[[Translation missing --]]
L["Horde"] = "Horde"
--[[Translation missing --]]
L["Horizontal"] = "Horizontal"
--[[Translation missing --]]
L["Hostile"] = "Hostile"
--[[Translation missing --]]
L["Hostility"] = "Hostility"
--[[Translation missing --]]
L["Humanoid"] = "Humanoid"
--[[Translation missing --]]
L["Hybrid"] = "Hybrid"
--[[Translation missing --]]
L["Icon"] = "Icon"
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
--[[Translation missing --]]
L["Ignore Rune CD"] = "Ignore Rune CD"
--[[Translation missing --]]
L["Ignore Rune CDs"] = "Ignore Rune CDs"
--[[Translation missing --]]
L["Ignore Self"] = "Ignore Self"
--[[Translation missing --]]
L["Ignore Spell Cooldown/Charges"] = "Ignore Spell Cooldown/Charges"
--[[Translation missing --]]
L["Ignore Spell Override"] = "Ignore Spell Override"
--[[Translation missing --]]
L["Immune"] = "Immune"
--[[Translation missing --]]
L["Important"] = "Important"
--[[Translation missing --]]
L["Importing will start after combat ends."] = "Importing will start after combat ends."
--[[Translation missing --]]
L["In Combat"] = "In Combat"
--[[Translation missing --]]
L["In Encounter"] = "In Encounter"
--[[Translation missing --]]
L["In Group"] = "In Group"
--[[Translation missing --]]
L["In Party"] = "In Party"
--[[Translation missing --]]
L["In Raid"] = "In Raid"
--[[Translation missing --]]
L["In Range"] = "In Range"
--[[Translation missing --]]
L["Include Bank"] = "Include Bank"
--[[Translation missing --]]
L["Include Charges"] = "Include Charges"
--[[Translation missing --]]
L["Include Pets"] = "Include Pets"
--[[Translation missing --]]
L["Incoming Heal"] = "Incoming Heal"
--[[Translation missing --]]
L["Increase Precision Below"] = "Increase Precision Below"
--[[Translation missing --]]
L["Increases by one per stage or intermission."] = "Increases by one per stage or intermission."
--[[Translation missing --]]
L["Information"] = "Information"
--[[Translation missing --]]
L["Inherited"] = "Inherited"
--[[Translation missing --]]
L["Instakill"] = "Instakill"
--[[Translation missing --]]
L["Install the addons BugSack and BugGrabber for detailed error logs."] = "Install the addons BugSack and BugGrabber for detailed error logs."
--[[Translation missing --]]
L["Instance"] = "Instance"
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
--[[Translation missing --]]
L["Instance Type"] = "Instance Type"
--[[Translation missing --]]
L["Instructor Razuvious"] = "Instructor Razuvious"
--[[Translation missing --]]
L["Insufficient Resources"] = "Insufficient Resources"
--[[Translation missing --]]
L["Intellect"] = "Intellect"
--[[Translation missing --]]
L["Interrupt"] = "Interrupt"
--[[Translation missing --]]
L["Interrupt School"] = "Interrupt School"
--[[Translation missing --]]
L["Interrupted School Text"] = "Interrupted School Text"
--[[Translation missing --]]
L["Interruptible"] = "Interruptible"
--[[Translation missing --]]
L["Inverse"] = "Inverse"
--[[Translation missing --]]
L["Inverse Pet Behavior"] = "Inverse Pet Behavior"
--[[Translation missing --]]
L["Is Away from Keyboard"] = "Is Away from Keyboard"
--[[Translation missing --]]
L["Is Exactly"] = "Is Exactly"
--[[Translation missing --]]
L["Is Moving"] = "Is Moving"
--[[Translation missing --]]
L["Is Off Hand"] = "Is Off Hand"
--[[Translation missing --]]
L["Is Paused"] = "Is Paused"
--[[Translation missing --]]
L["is useable"] = "is useable"
--[[Translation missing --]]
L["Island Expedition (Heroic)"] = "Island Expedition (Heroic)"
--[[Translation missing --]]
L["Island Expedition (Mythic)"] = "Island Expedition (Mythic)"
--[[Translation missing --]]
L["Island Expedition (Normal)"] = "Island Expedition (Normal)"
--[[Translation missing --]]
L["Island Expeditions (PvP)"] = "Island Expeditions (PvP)"
--[[Translation missing --]]
L["Item"] = "Item"
--[[Translation missing --]]
L["Item Bonus Id"] = "Item Bonus Id"
--[[Translation missing --]]
L["Item Bonus Id Equipped"] = "Item Bonus Id Equipped"
--[[Translation missing --]]
L["Item Count"] = "Item Count"
--[[Translation missing --]]
L["Item Equipped"] = "Item Equipped"
--[[Translation missing --]]
L["Item Id"] = "Item Id"
--[[Translation missing --]]
L["Item in Range"] = "Item in Range"
--[[Translation missing --]]
L["Item Name"] = "Item Name"
--[[Translation missing --]]
L["Item Set Equipped"] = "Item Set Equipped"
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
--[[Translation missing --]]
L["Leaving"] = "Leaving"
--[[Translation missing --]]
L["Leech"] = "Leech"
--[[Translation missing --]]
L["Left"] = "Left"
--[[Translation missing --]]
L["Left to Right"] = "Left to Right"
--[[Translation missing --]]
L["Left, then Centered Vertical"] = "Left, then Centered Vertical"
--[[Translation missing --]]
L["Left, then Down"] = "Left, then Down"
--[[Translation missing --]]
L["Left, then Up"] = "Left, then Up"
--[[Translation missing --]]
L["Legacy Looking for Raid"] = "Legacy Looking for Raid"
--[[Translation missing --]]
L["Legacy RGB Gradient"] = "Legacy RGB Gradient"
--[[Translation missing --]]
L["Legacy RGB Gradient Pulse"] = "Legacy RGB Gradient Pulse"
--[[Translation missing --]]
L["Legion"] = "Legion"
--[[Translation missing --]]
L["Length"] = "Length"
--[[Translation missing --]]
L["Level"] = "Level"
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
--[[Translation missing --]]
L["Load Conditions"] = "Load Conditions"
--[[Translation missing --]]
L["Loatheb"] = "Loatheb"
--[[Translation missing --]]
L["Location"] = "Location"
--[[Translation missing --]]
L["Looking for Raid"] = "Looking for Raid"
--[[Translation missing --]]
L["Loop"] = "Loop"
--[[Translation missing --]]
L["Loot"] = "Loot"
--[[Translation missing --]]
L["Lorewalking"] = "Lorewalking"
--[[Translation missing --]]
L["Lost"] = "Lost"
--[[Translation missing --]]
L["Low Damage"] = "Low Damage"
--[[Translation missing --]]
L["Lower Than Tank"] = "Lower Than Tank"
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
--[[Translation missing --]]
L["Magic"] = "Magic"
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
--[[Translation missing --]]
L["Manual Rotation"] = "Manual Rotation"
--[[Translation missing --]]
L["Marked First"] = "Marked First"
--[[Translation missing --]]
L["Marked Last"] = "Marked Last"
--[[Translation missing --]]
L["Mason"] = "Mason"
--[[Translation missing --]]
L["Master"] = "Master"
--[[Translation missing --]]
L["Match Count"] = "Match Count"
--[[Translation missing --]]
L["Match Count per Unit"] = "Match Count per Unit"
--[[Translation missing --]]
L["Matches (Pattern)"] = "Matches (Pattern)"
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
--[[Translation missing --]]
L["Message"] = "Message"
--[[Translation missing --]]
L["Message Type"] = "Message Type"
--[[Translation missing --]]
L["Message type:"] = "Message type:"
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
--[[Translation missing --]]
L["Mirror"] = "Mirror"
--[[Translation missing --]]
L["Miscellaneous"] = "Miscellaneous"
--[[Translation missing --]]
L["Miss"] = "Miss"
--[[Translation missing --]]
L["Miss Type"] = "Miss Type"
--[[Translation missing --]]
L["Missed"] = "Missed"
--[[Translation missing --]]
L["Missing"] = "Missing"
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
--[[Translation missing --]]
L["Molten Core"] = "Molten Core"
--[[Translation missing --]]
L["Money"] = "Money"
--[[Translation missing --]]
L["Monochrome"] = "Monochrome"
--[[Translation missing --]]
L["Monochrome Outline"] = "Monochrome Outline"
--[[Translation missing --]]
L["Monochrome Thick Outline"] = "Monochrome Thick Outline"
--[[Translation missing --]]
L["Monster Emote"] = "Monster Emote"
--[[Translation missing --]]
L["Monster Party"] = "Monster Party"
--[[Translation missing --]]
L["Monster Say"] = "Monster Say"
--[[Translation missing --]]
L["Monster Whisper"] = "Monster Whisper"
--[[Translation missing --]]
L["Monster Yell"] = "Monster Yell"
--[[Translation missing --]]
L["Most remaining time"] = "Most remaining time"
--[[Translation missing --]]
L["Mounted"] = "Mounted"
--[[Translation missing --]]
L["Mouse Cursor"] = "Mouse Cursor"
--[[Translation missing --]]
L["Multi-target"] = "Multi-target"
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
--[[Translation missing --]]
L["Nature Resistance"] = "Nature Resistance"
--[[Translation missing --]]
L["Naxxramas"] = "Naxxramas"
--[[Translation missing --]]
L["Nefarian"] = "Nefarian"
--[[Translation missing --]]
L["Neutral"] = "Neutral"
--[[Translation missing --]]
L["Never"] = "Never"
--[[Translation missing --]]
L["Next Combat"] = "Next Combat"
--[[Translation missing --]]
L["Next Encounter"] = "Next Encounter"
--[[Translation missing --]]
L[ [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L["No Extend"] = "No Extend"
--[[Translation missing --]]
L["No Instance"] = "No Instance"
--[[Translation missing --]]
L["No Profiling information saved."] = "No Profiling information saved."
--[[Translation missing --]]
L["No Progress Information available."] = "No Progress Information available."
--[[Translation missing --]]
L["None"] = "None"
--[[Translation missing --]]
L["Non-player Character"] = "Non-player Character"
--[[Translation missing --]]
L["Normal"] = "Normal"
--[[Translation missing --]]
L["Normal Party"] = "Normal Party"
--[[Translation missing --]]
L["Not in Group"] = "Not in Group"
--[[Translation missing --]]
L["Not in Smart Group"] = "Not in Smart Group"
--[[Translation missing --]]
L["Not on Cooldown"] = "Not on Cooldown"
--[[Translation missing --]]
L["Not On Threat Table"] = "Not On Threat Table"
--[[Translation missing --]]
L["Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."] = "Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."
--[[Translation missing --]]
L["Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."] = "Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."
--[[Translation missing --]]
L["Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"] = "Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"
--[[Translation missing --]]
L["Noth the Plaguebringer"] = "Noth the Plaguebringer"
--[[Translation missing --]]
L["NPC"] = "NPC"
--[[Translation missing --]]
L["Npc ID"] = "Npc ID"
--[[Translation missing --]]
L["Number"] = "Number"
--[[Translation missing --]]
L["Number Affected"] = "Number Affected"
--[[Translation missing --]]
L["Object"] = "Object"
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
--[[Translation missing --]]
L["Officer"] = "Officer"
--[[Translation missing --]]
L["Offset from progress"] = "Offset from progress"
--[[Translation missing --]]
L["Offset Timer"] = "Offset Timer"
--[[Translation missing --]]
L["Old Blizzard (2h | 3m | 10s | 2.4)"] = "Old Blizzard (2h | 3m | 10s | 2.4)"
--[[Translation missing --]]
L["On Cooldown"] = "On Cooldown"
--[[Translation missing --]]
L["On Taxi"] = "On Taxi"
--[[Translation missing --]]
L["Only if on a different realm"] = "Only if on a different realm"
--[[Translation missing --]]
L["Only if Primary"] = "Only if Primary"
--[[Translation missing --]]
L["Onyxia"] = "Onyxia"
--[[Translation missing --]]
L["Opaque"] = "Opaque"
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
--[[Translation missing --]]
L["Orbit"] = "Orbit"
--[[Translation missing --]]
L["Orientation"] = "Orientation"
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
--[[Translation missing --]]
L["Outline"] = "Outline"
--[[Translation missing --]]
L["Over Energize"] = "Over Energize"
--[[Translation missing --]]
L["Overhealing"] = "Overhealing"
--[[Translation missing --]]
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
--[[Translation missing --]]
L["Parry"] = "Parry"
--[[Translation missing --]]
L["Parry (%)"] = "Parry (%)"
--[[Translation missing --]]
L["Party"] = "Party"
--[[Translation missing --]]
L["Party Kill"] = "Party Kill"
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
--[[Translation missing --]]
L["Paused"] = "Paused"
--[[Translation missing --]]
L["Periodic Spell"] = "Periodic Spell"
--[[Translation missing --]]
L["Personal Resource Display"] = "Personal Resource Display"
--[[Translation missing --]]
L["Pet"] = "Pet"
--[[Translation missing --]]
L["Pet Behavior"] = "Pet Behavior"
--[[Translation missing --]]
L["Pet Specialization"] = "Pet Specialization"
--[[Translation missing --]]
L["Pet Spell"] = "Pet Spell"
--[[Translation missing --]]
L["Pets only"] = "Pets only"
--[[Translation missing --]]
L["Phase"] = "Phase"
--[[Translation missing --]]
L["Pixel Glow"] = "Pixel Glow"
--[[Translation missing --]]
L["Placement"] = "Placement"
--[[Translation missing --]]
L["Placement %i"] = "Placement %i"
--[[Translation missing --]]
L["Placement Mode"] = "Placement Mode"
--[[Translation missing --]]
L["Play"] = "Play"
--[[Translation missing --]]
L["Player"] = "Player"
--[[Translation missing --]]
L["Player Character"] = "Player Character"
--[[Translation missing --]]
L["Player Class"] = "Player Class"
--[[Translation missing --]]
L["Player Experience"] = "Player Experience"
--[[Translation missing --]]
L["Player Faction"] = "Player Faction"
--[[Translation missing --]]
L["Player Level"] = "Player Level"
--[[Translation missing --]]
L["Player Location ID(s)"] = "Player Location ID(s)"
--[[Translation missing --]]
L["Player Money"] = "Player Money"
--[[Translation missing --]]
L["Player Name/Realm"] = "Player Name/Realm"
--[[Translation missing --]]
L["Player Race"] = "Player Race"
--[[Translation missing --]]
L["Player(s) Affected"] = "Player(s) Affected"
--[[Translation missing --]]
L["Player(s) Not Affected"] = "Player(s) Not Affected"
--[[Translation missing --]]
L["Player/Unit Info"] = "Player/Unit Info"
--[[Translation missing --]]
L["Players and Pets"] = "Players and Pets"
--[[Translation missing --]]
L["Poison"] = "Poison"
--[[Translation missing --]]
L["Power"] = "Power"
--[[Translation missing --]]
L["Power (%)"] = "Power (%)"
--[[Translation missing --]]
L["Power Deficit"] = "Power Deficit"
--[[Translation missing --]]
L["Power Type"] = "Power Type"
--[[Translation missing --]]
L["Precision"] = "Precision"
--[[Translation missing --]]
L["Preset"] = "Preset"
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
--[[Translation missing --]]
L["Progress Total"] = "Progress Total"
--[[Translation missing --]]
L["Progress Value"] = "Progress Value"
--[[Translation missing --]]
L["Pull"] = "Pull"
--[[Translation missing --]]
L["Pulse"] = "Pulse"
--[[Translation missing --]]
L["PvP Flagged"] = "PvP Flagged"
--[[Translation missing --]]
L["PvP Mode Active"] = "PvP Mode Active"
--[[Translation missing --]]
L["Quest Party"] = "Quest Party"
--[[Translation missing --]]
L["Queued Action"] = "Queued Action"
--[[Translation missing --]]
L["Radius"] = "Radius"
--[[Translation missing --]]
L["Ragnaros"] = "Ragnaros"
--[[Translation missing --]]
L["Raid"] = "Raid"
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
--[[Translation missing --]]
L["Raid Warning"] = "Raid Warning"
--[[Translation missing --]]
L["Range"] = "Range"
--[[Translation missing --]]
L["Range Check"] = "Range Check"
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
--[[Translation missing --]]
L["Ready Check"] = "Ready Check"
--[[Translation missing --]]
L["Realm"] = "Realm"
--[[Translation missing --]]
L["Realm Name"] = "Realm Name"
--[[Translation missing --]]
L["Realm of Caster's Target"] = "Realm of Caster's Target"
--[[Translation missing --]]
L["Reborn Council"] = "Reborn Council"
--[[Translation missing --]]
L["Receiving %s Bytes"] = "Receiving %s Bytes"
--[[Translation missing --]]
L["Receiving display information"] = "Receiving display information"
--[[Translation missing --]]
L["Reflect"] = "Reflect"
--[[Translation missing --]]
L["Region type %s not supported"] = "Region type %s not supported"
--[[Translation missing --]]
L["Relative"] = "Relative"
--[[Translation missing --]]
L["Relative X-Offset"] = "Relative X-Offset"
--[[Translation missing --]]
L["Relative Y-Offset"] = "Relative Y-Offset"
--[[Translation missing --]]
L["Remaining Duration"] = "Remaining Duration"
--[[Translation missing --]]
L["Remaining Time"] = "Remaining Time"
--[[Translation missing --]]
L["Remove Obsolete Auras"] = "Remove Obsolete Auras"
--[[Translation missing --]]
L["Repair"] = "Repair"
--[[Translation missing --]]
L["Repeat"] = "Repeat"
--[[Translation missing --]]
L["Report Summary"] = "Report Summary"
--[[Translation missing --]]
L["Reputation"] = "Reputation"
--[[Translation missing --]]
L["Reputation (%)"] = "Reputation (%)"
--[[Translation missing --]]
L["Requested display does not exist"] = "Requested display does not exist"
--[[Translation missing --]]
L["Requested display not authorized"] = "Requested display not authorized"
--[[Translation missing --]]
L["Requesting display information from %s ..."] = "Requesting display information from %s ..."
--[[Translation missing --]]
L["Require Valid Target"] = "Require Valid Target"
--[[Translation missing --]]
L["Resist"] = "Resist"
--[[Translation missing --]]
L["Resistances"] = "Resistances"
--[[Translation missing --]]
L["Resisted"] = "Resisted"
--[[Translation missing --]]
L["Rested"] = "Rested"
--[[Translation missing --]]
L["Rested Experience"] = "Rested Experience"
--[[Translation missing --]]
L["Rested Experience (%)"] = "Rested Experience (%)"
--[[Translation missing --]]
L["Resting"] = "Resting"
--[[Translation missing --]]
L["Resurrect"] = "Resurrect"
--[[Translation missing --]]
L["Resurrect Pending"] = "Resurrect Pending"
--[[Translation missing --]]
L["Right"] = "Right"
--[[Translation missing --]]
L["Right to Left"] = "Right to Left"
--[[Translation missing --]]
L["Right, then Centered Vertical"] = "Right, then Centered Vertical"
--[[Translation missing --]]
L["Right, then Down"] = "Right, then Down"
--[[Translation missing --]]
L["Right, then Up"] = "Right, then Up"
--[[Translation missing --]]
L["Role"] = "Role"
--[[Translation missing --]]
L["Rollback snapshot is complete. Thank you for your patience!"] = "Rollback snapshot is complete. Thank you for your patience!"
--[[Translation missing --]]
L["Rotate Animation"] = "Rotate Animation"
--[[Translation missing --]]
L["Rotate Left"] = "Rotate Left"
--[[Translation missing --]]
L["Rotate Right"] = "Rotate Right"
--[[Translation missing --]]
L["Rotation"] = "Rotation"
--[[Translation missing --]]
L["Round"] = "Round"
--[[Translation missing --]]
L["Round Mode"] = "Round Mode"
--[[Translation missing --]]
L["Ruins of Ahn'Qiraj"] = "Ruins of Ahn'Qiraj"
--[[Translation missing --]]
L["Run Custom Code"] = "Run Custom Code"
--[[Translation missing --]]
L["Run Speed (%)"] = "Run Speed (%)"
--[[Translation missing --]]
L["Sapphiron"] = "Sapphiron"
--[[Translation missing --]]
L["Say"] = "Say"
--[[Translation missing --]]
L["Scale"] = "Scale"
--[[Translation missing --]]
L["Scarlet Enclave"] = "Scarlet Enclave"
--[[Translation missing --]]
L["Scenario"] = "Scenario"
--[[Translation missing --]]
L["Scenario (Heroic)"] = "Scenario (Heroic)"
--[[Translation missing --]]
L["Scenario (Normal)"] = "Scenario (Normal)"
--[[Translation missing --]]
L["Screen"] = "Screen"
--[[Translation missing --]]
L["Screen/Parent Group"] = "Screen/Parent Group"
--[[Translation missing --]]
L["Season of Discovery"] = "Season of Discovery"
--[[Translation missing --]]
L["Second"] = "Second"
--[[Translation missing --]]
L["Second Value of Tooltip Text"] = "Second Value of Tooltip Text"
--[[Translation missing --]]
L["Secondary Stats"] = "Secondary Stats"
--[[Translation missing --]]
L["Seconds"] = "Seconds"
--[[Translation missing --]]
L[ [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Select Frame"] = "Select Frame"
--[[Translation missing --]]
L["Select the type of timer to filter"] = "Select the type of timer to filter"
--[[Translation missing --]]
L["Selection Mode"] = "Selection Mode"
--[[Translation missing --]]
L["Separator"] = "Separator"
--[[Translation missing --]]
L["Set IDs can be found on websites such as wowhead.com/classic/item-sets"] = "Set IDs can be found on websites such as wowhead.com/classic/item-sets"
--[[Translation missing --]]
L["Shadow Resistance"] = "Shadow Resistance"
--[[Translation missing --]]
L["Shadowlands"] = "Shadowlands"
--[[Translation missing --]]
L["Shake"] = "Shake"
--[[Translation missing --]]
L["Shazzrah"] = "Shazzrah"
--[[Translation missing --]]
L["Shift-Click to resume addon execution."] = "Shift-Click to resume addon execution."
--[[Translation missing --]]
L["Show"] = "Show"
--[[Translation missing --]]
L["Show CD of Charge"] = "Show CD of Charge"
--[[Translation missing --]]
L["Show GCD"] = "Show GCD"
--[[Translation missing --]]
L["Show Global Cooldown"] = "Show Global Cooldown"
--[[Translation missing --]]
L["Show Incoming Heal"] = "Show Incoming Heal"
--[[Translation missing --]]
L["Show Loss of Control"] = "Show Loss of Control"
--[[Translation missing --]]
L["Show On"] = "Show On"
--[[Translation missing --]]
L["Show Rested Overlay"] = "Show Rested Overlay"
--[[Translation missing --]]
L["Shrink"] = "Shrink"
--[[Translation missing --]]
L["Silithid Royalty"] = "Silithid Royalty"
--[[Translation missing --]]
L["Silver"] = "Silver"
--[[Translation missing --]]
L["Simple"] = "Simple"
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
--[[Translation missing --]]
L["Size & Position"] = "Size & Position"
--[[Translation missing --]]
L["Slide Animation"] = "Slide Animation"
--[[Translation missing --]]
L["Slide from Bottom"] = "Slide from Bottom"
--[[Translation missing --]]
L["Slide from Left"] = "Slide from Left"
--[[Translation missing --]]
L["Slide from Right"] = "Slide from Right"
--[[Translation missing --]]
L["Slide from Top"] = "Slide from Top"
--[[Translation missing --]]
L["Slide to Bottom"] = "Slide to Bottom"
--[[Translation missing --]]
L["Slide to Left"] = "Slide to Left"
--[[Translation missing --]]
L["Slide to Right"] = "Slide to Right"
--[[Translation missing --]]
L["Slide to Top"] = "Slide to Top"
--[[Translation missing --]]
L["Slider"] = "Slider"
--[[Translation missing --]]
L["Slug"] = "Slug"
--[[Translation missing --]]
L["Slug Outline"] = "Slug Outline"
--[[Translation missing --]]
L["Small"] = "Small"
--[[Translation missing --]]
L["Smart Group"] = "Smart Group"
--[[Translation missing --]]
L["Soft Enemy"] = "Soft Enemy"
--[[Translation missing --]]
L["Soft Friend"] = "Soft Friend"
--[[Translation missing --]]
L["Solistrasza"] = "Solistrasza"
--[[Translation missing --]]
L["Sound"] = "Sound"
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
--[[Translation missing --]]
L["Source Name"] = "Source Name"
--[[Translation missing --]]
L["Source NPC Id"] = "Source NPC Id"
--[[Translation missing --]]
L["Source Object Type"] = "Source Object Type"
--[[Translation missing --]]
L["Source Raid Mark"] = "Source Raid Mark"
--[[Translation missing --]]
L["Source Reaction"] = "Source Reaction"
--[[Translation missing --]]
L["Source Unit"] = "Source Unit"
--[[Translation missing --]]
L["Source Unit Name/Realm"] = "Source Unit Name/Realm"
--[[Translation missing --]]
L["Source unit's raid mark index"] = "Source unit's raid mark index"
--[[Translation missing --]]
L["Source unit's raid mark texture"] = "Source unit's raid mark texture"
--[[Translation missing --]]
L["Space"] = "Space"
--[[Translation missing --]]
L["Spacing"] = "Spacing"
--[[Translation missing --]]
L["Spark"] = "Spark"
--[[Translation missing --]]
L["Specialization"] = "Specialization"
--[[Translation missing --]]
L["Specific Type"] = "Specific Type"
--[[Translation missing --]]
L["Specific Unit"] = "Specific Unit"
--[[Translation missing --]]
L["Spell"] = "Spell"
--[[Translation missing --]]
L["Spell (Building)"] = "Spell (Building)"
--[[Translation missing --]]
L["Spell Cast Succeeded"] = "Spell Cast Succeeded"
--[[Translation missing --]]
L["Spell Cost"] = "Spell Cost"
--[[Translation missing --]]
L["Spell Count"] = "Spell Count"
--[[Translation missing --]]
L["Spell ID"] = "Spell ID"
--[[Translation missing --]]
L["Spell Id"] = "Spell Id"
--[[Translation missing --]]
L["Spell ID:"] = "Spell ID:"
--[[Translation missing --]]
L["Spell IDs:"] = "Spell IDs:"
--[[Translation missing --]]
L["Spell in Range"] = "Spell in Range"
--[[Translation missing --]]
L["Spell Known"] = "Spell Known"
--[[Translation missing --]]
L["Spell Name"] = "Spell Name"
--[[Translation missing --]]
L["Spell Power"] = "Spell Power"
--[[Translation missing --]]
L["Spell School"] = "Spell School"
--[[Translation missing --]]
L["Spell Usable"] = "Spell Usable"
--[[Translation missing --]]
L["Spellname"] = "Spellname"
--[[Translation missing --]]
L["Spike"] = "Spike"
--[[Translation missing --]]
L["Spin"] = "Spin"
--[[Translation missing --]]
L["Spiral"] = "Spiral"
--[[Translation missing --]]
L["Spiral In And Out"] = "Spiral In And Out"
--[[Translation missing --]]
L["Spirit"] = "Spirit"
--[[Translation missing --]]
L["Stack Count"] = "Stack Count"
--[[Translation missing --]]
L["Stack trace:"] = "Stack trace:"
--[[Translation missing --]]
L["Stacks"] = "Stacks"
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
--[[Translation missing --]]
L["Stamina"] = "Stamina"
--[[Translation missing --]]
L["Stance/Form/Aura"] = "Stance/Form/Aura"
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
--[[Translation missing --]]
L["Status"] = "Status"
--[[Translation missing --]]
L["Status Bar"] = "Status Bar"
--[[Translation missing --]]
L["Stolen"] = "Stolen"
--[[Translation missing --]]
L["Stop"] = "Stop"
--[[Translation missing --]]
L["Stop Motion"] = "Stop Motion"
--[[Translation missing --]]
L["Story Raid"] = "Story Raid"
--[[Translation missing --]]
L["Strength"] = "Strength"
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
--[[Translation missing --]]
L["Summon"] = "Summon"
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
L["Swing"] = "Swing"
--[[Translation missing --]]
L["Swing Timer"] = "Swing Timer"
--[[Translation missing --]]
L["Swipe"] = "Swipe"
--[[Translation missing --]]
L["Syntax /wa feature <toggle|on|enable|disable|off> <feature>"] = "Syntax /wa feature <toggle|on|enable|disable|off> <feature>"
--[[Translation missing --]]
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
--[[Translation missing --]]
L["Talent Selected"] = "Talent Selected"
--[[Translation missing --]]
L["Talent Specialization"] = "Talent Specialization"
--[[Translation missing --]]
L["Tanking And Highest"] = "Tanking And Highest"
--[[Translation missing --]]
L["Tanking But Not Highest"] = "Tanking But Not Highest"
--[[Translation missing --]]
L["Target"] = "Target"
--[[Translation missing --]]
L["Targeted"] = "Targeted"
--[[Translation missing --]]
L["Tertiary Stats"] = "Tertiary Stats"
--[[Translation missing --]]
L["Test if bar is enabled in BigWigs settings"] = "Test if bar is enabled in BigWigs settings"
--[[Translation missing --]]
L["Test if bar is enabled in Boss Mod addon settings"] = "Test if bar is enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Test if bar is enabled in DBM settings"] = "Test if bar is enabled in DBM settings"
--[[Translation missing --]]
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
--[[Translation missing --]]
L["Thick Outline"] = "Thick Outline"
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
--[[Translation missing --]]
L["Threat Situation"] = "Threat Situation"
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
--[[Translation missing --]]
L["Timed"] = "Timed"
--[[Translation missing --]]
L["Timed Progress"] = "Timed Progress"
--[[Translation missing --]]
L["Timer"] = "Timer"
--[[Translation missing --]]
L["Timer Id"] = "Timer Id"
--[[Translation missing --]]
L["Toggle"] = "Toggle"
--[[Translation missing --]]
L["Toggle List"] = "Toggle List"
--[[Translation missing --]]
L["Toggle Options Window"] = "Toggle Options Window"
--[[Translation missing --]]
L["Toggle Performance Profiling Window"] = "Toggle Performance Profiling Window"
--[[Translation missing --]]
L["Tooltip"] = "Tooltip"
--[[Translation missing --]]
L["Tooltip 1"] = "Tooltip 1"
--[[Translation missing --]]
L["Tooltip 2"] = "Tooltip 2"
--[[Translation missing --]]
L["Tooltip 3"] = "Tooltip 3"
--[[Translation missing --]]
L["Tooltip Value 1"] = "Tooltip Value 1"
--[[Translation missing --]]
L["Tooltip Value 2"] = "Tooltip Value 2"
--[[Translation missing --]]
L["Tooltip Value 3"] = "Tooltip Value 3"
--[[Translation missing --]]
L["Tooltip Value 4"] = "Tooltip Value 4"
--[[Translation missing --]]
L["Top"] = "Top"
--[[Translation missing --]]
L["Top Left"] = "Top Left"
--[[Translation missing --]]
L["Top Right"] = "Top Right"
--[[Translation missing --]]
L["Top to Bottom"] = "Top to Bottom"
--[[Translation missing --]]
L["Torghast"] = "Torghast"
--[[Translation missing --]]
L["Total Duration"] = "Total Duration"
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
--[[Translation missing --]]
L["Totem"] = "Totem"
--[[Translation missing --]]
L["Totem #%i"] = "Totem #%i"
--[[Translation missing --]]
L["Totem Icon"] = "Totem Icon"
--[[Translation missing --]]
L["Totem Name"] = "Totem Name"
--[[Translation missing --]]
L["Totem Name Pattern Match"] = "Totem Name Pattern Match"
--[[Translation missing --]]
L["Totem Number"] = "Totem Number"
--[[Translation missing --]]
L["Track Cooldowns"] = "Track Cooldowns"
--[[Translation missing --]]
L["Tracking Charge %i"] = "Tracking Charge %i"
--[[Translation missing --]]
L["Tracking Charge CDs"] = "Tracking Charge CDs"
--[[Translation missing --]]
L["Tracking Only Cooldown"] = "Tracking Only Cooldown"
--[[Translation missing --]]
L["Transmission error"] = "Transmission error"
--[[Translation missing --]]
L["Trigger"] = "Trigger"
--[[Translation missing --]]
L["Trigger %i"] = "Trigger %i"
--[[Translation missing --]]
L["Trigger %s"] = "Trigger %s"
--[[Translation missing --]]
L["Trigger 1"] = "Trigger 1"
--[[Translation missing --]]
L["Trigger State Updater (Advanced)"] = "Trigger State Updater (Advanced)"
--[[Translation missing --]]
L["Trigger Update"] = "Trigger Update"
--[[Translation missing --]]
L["Trigger:"] = "Trigger:"
--[[Translation missing --]]
L["Trivial (Low Level)"] = "Trivial (Low Level)"
--[[Translation missing --]]
L["True"] = "True"
--[[Translation missing --]]
L["Trying to repair broken conditions in %s likely caused by a Musca Auras bug."] = "Trying to repair broken conditions in %s likely caused by a Musca Auras bug."
--[[Translation missing --]]
L["Twin Emperors"] = "Twin Emperors"
--[[Translation missing --]]
L["Type"] = "Type"
--[[Translation missing --]]
L["Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."] = "Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."
--[[Translation missing --]]
L["Unaffected"] = "Unaffected"
--[[Translation missing --]]
L["Undefined"] = "Undefined"
--[[Translation missing --]]
L["Unit"] = "Unit"
--[[Translation missing --]]
L["Unit Characteristics"] = "Unit Characteristics"
--[[Translation missing --]]
L["Unit Destroyed"] = "Unit Destroyed"
--[[Translation missing --]]
L["Unit Died"] = "Unit Died"
--[[Translation missing --]]
L["Unit Dissipates"] = "Unit Dissipates"
--[[Translation missing --]]
L["Unit Frame"] = "Unit Frame"
--[[Translation missing --]]
L["Unit Frames"] = "Unit Frames"
--[[Translation missing --]]
L["Unit is Unit"] = "Unit is Unit"
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
--[[Translation missing --]]
L["Unlimited"] = "Unlimited"
--[[Translation missing --]]
L["Untrigger %s"] = "Untrigger %s"
--[[Translation missing --]]
L["Up"] = "Up"
--[[Translation missing --]]
L["Up, then Centered Horizontal"] = "Up, then Centered Horizontal"
--[[Translation missing --]]
L["Up, then Left"] = "Up, then Left"
--[[Translation missing --]]
L["Up, then Right"] = "Up, then Right"
--[[Translation missing --]]
L["Update Position"] = "Update Position"
--[[Translation missing --]]
L["Usage:"] = "Usage:"
--[[Translation missing --]]
L["Use /wa minimap to show the minimap icon again."] = "Use /wa minimap to show the minimap icon again."
--[[Translation missing --]]
L["Use Custom Color"] = "Use Custom Color"
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
--[[Translation missing --]]
L["Visibility"] = "Visibility"
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
L["Weapon"] = "Weapon"
--[[Translation missing --]]
L["Weapon Enchant"] = "Weapon Enchant"
--[[Translation missing --]]
L["Whisper"] = "Whisper"
--[[Translation missing --]]
L["Width"] = "Width"
--[[Translation missing --]]
L["Wobble"] = "Wobble"
--[[Translation missing --]]
L["World Boss"] = "World Boss"
--[[Translation missing --]]
L["World Bosses"] = "World Bosses"
--[[Translation missing --]]
L["Wrap"] = "Wrap"
--[[Translation missing --]]
L["Wrath of the Lich King"] = "Wrath of the Lich King"
--[[Translation missing --]]
L["Writing to the WeakAuras table is not allowed."] = "Writing to the WeakAuras table is not allowed."
--[[Translation missing --]]
L["X-Offset"] = "X-Offset"
--[[Translation missing --]]
L["Yell"] = "Yell"
--[[Translation missing --]]
L["Y-Offset"] = "Y-Offset"
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
--[[Translation missing --]]
L["Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."] = "Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."
--[[Translation missing --]]
L["Your total threat on the mob."] = "Your total threat on the mob."
--[[Translation missing --]]
L["Zone Group ID"] = "Zone Group ID"
--[[Translation missing --]]
L["Zone ID"] = "Zone ID"
--[[Translation missing --]]
L["Zone Name"] = "Zone Name"
--[[Translation missing --]]
L["Zoom"] = "Zoom"
--[[Translation missing --]]
L["Zoom Animation"] = "Zoom Animation"
--[[Translation missing --]]
L["Zul'Gurub"] = "Zul'Gurub"
L["New name, new look: the addon now shows its own name, Musca Auras."] = "Nuovo nome, nuovo aspetto: l'addon ora mostra il proprio nome, Musca Auras."
L["- New colors and a new icon, in the |cffffd100/wa|r window, the Guide, the chat and the minimap."] = "- Nuovi colori e una nuova icona, nella finestra |cffffd100/wa|r, nella Guida, nella chat e sulla minimappa."
L["- Two more ways to open it: the addon menu of the minimap, and a page in Options > AddOns."] = "- Altri due modi per aprirlo: il menu degli addon della minimappa e una pagina in Opzioni > AddOns."
L["Nothing else changes: |cffffd100/wa|r, your auras, their positions and the Wago imports work as before."] = "Nient'altro cambia: |cffffd100/wa|r, le tue aure, le loro posizioni e le importazioni da Wago funzionano come prima."
L["Open Musca Auras"] = "Apri Musca Auras"
L["You can also type |cffffd100/wa|r in the chat, or click the icon of the minimap."] = "Puoi anche digitare |cffffd100/wa|r nella chat o fare clic sull'icona della minimappa."
L["The Cooldown Manager configuration was updated by Musca Auras. Reload the UI to finish."] = "Musca Auras ha aggiornato la configurazione del Gestore dei tempi di recupero. Ricarica l'interfaccia per terminare."
L["|cffffd100Everything you need to learn Musca Auras on WoW Forever:|r how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import.\n\nOpen this guide again with the |cffffd100Guide|r button at the top of the |cffffd100/wa|r window, or with |cffffd100/wa tutorial|r."] = "|cffffd100Tutto ciò che serve per imparare Musca Auras su WoW Forever:|r come funziona un'aura, cosa è cambiato in combattimento, cosa funziona e cosa no, ricette passo per passo e aure pronte da importare.\n\nRiapri questa guida con il pulsante |cffffd100Guida|r in alto nella finestra |cffffd100/wa|r, oppure con |cffffd100/wa tutorial|r."
L["How Musca Auras works on WoW Forever, and how to build auras that keep working in combat.\n\nWoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data from addons. This guide explains what that changes and gives step-by-step recipes.\n\nSection 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game."] = "Come funziona Musca Auras su WoW Forever e come creare aure che continuano a funzionare in combattimento.\n\nWoW Forever sembra Classic, ma gira sul moderno motore di gioco 12.1. Questo motore nasconde agli addon la maggior parte dei dati di combattimento. Questa guida spiega cosa cambia e offre ricette passo per passo.\n\nLa sezione 3 indica cosa è stato testato in gioco su Forever e cosa no. Se non sei sicuro, prova in gioco."
L["1. Musca Auras in 2 minutes"] = "1. Musca Auras in 2 minuti"
L["An aura is something Musca Auras shows on your screen: an icon, a bar, a text or a texture. Every aura has 4 parts, one per tab in the options:\n\n- |cffffd100Display|r: What it looks like: icon, size, colors, text.\n- |cffffd100Trigger|r: When it shows: a buff, a cooldown, a cast, an item count, a game event.\n- |cffffd100Conditions|r: What changes while it is shown, for example red when less than 3 seconds remain.\n- |cffffd100Load|r: When Musca Auras even looks at it: class, in combat, in a group, zone.\n\nThe |cffffd100Actions|r tab adds a sound, a chat message or a glow when the aura shows or hides.\n\nBasic steps:\n\n1. Type |cff99ccff/wa|r.\n2. Click |cffffd100New|r, then choose a display type: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r or |cffffd100Texture|r.\n3. Fill in the |cffffd100Trigger|r tab.\n4. Set the |cffffd100Load|r tab, so the aura only loads when it is useful.\n5. Close the options and test."] = "Un'aura è qualcosa che Musca Auras mostra sul tuo schermo: un'icona, una barra, un testo o una texture. Ogni aura ha 4 parti, una per scheda nelle opzioni:\n\n- |cffffd100Display|r: Che aspetto ha: icona, dimensione, colori, testo.\n- |cffffd100Trigger|r: Quando viene mostrata: un buff, un cooldown, un lancio, un numero di oggetti, un evento di gioco.\n- |cffffd100Condizioni|r: Cosa cambia mentre è mostrata, ad esempio rossa quando mancano meno di 3 secondi.\n- |cffffd100Load|r: Quando Musca Auras la prende in considerazione: classe, in combattimento, in gruppo, zona.\n\nLa scheda |cffffd100Azioni|r aggiunge un suono, un messaggio in chat o un bagliore quando l'aura viene mostrata o nascosta.\n\nPassi di base:\n\n1. Digita |cff99ccff/wa|r.\n2. Clicca su |cffffd100New|r, poi scegli un tipo di display: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r o |cffffd100Texture|r.\n3. Compila la scheda |cffffd100Trigger|r.\n4. Imposta la scheda |cffffd100Load|r, in modo che l'aura venga caricata solo quando serve.\n5. Chiudi le opzioni e prova."
L["Place your auras on the screen"] = "Posiziona le tue aure sullo schermo"
L["Type |cff99ccff/wa unlock|r, or click |cffffd100Unlock|r at the top of the |cff99ccff/wa|r window. The screen darkens under a grid and every aura gets a box: drag it where you want. Auras snap to the grid, to the screen edges and to the other auras. Hold |cffffd100Shift|r to turn the snap off. The panel of the selected aura sets its exact position and size. Click |cffffd100Save and quit|r when you are done. Placement mode does not open during combat."] = "Digita |cff99ccff/wa unlock|r, oppure clicca su |cffffd100Sblocca|r in alto nella finestra |cff99ccff/wa|r. Lo schermo si scurisce sotto una griglia e ogni aura riceve un riquadro: trascinalo dove vuoi. Le aure si agganciano alla griglia, ai bordi dello schermo e alle altre aure. Tieni premuto |cffffd100Maiusc|r per disattivare l'aggancio. Il pannello dell'aura selezionata imposta la sua posizione e dimensione esatte. Clicca su |cffffd100Salva ed esci|r quando hai finito. La modalità di posizionamento non si apre durante il combattimento."
L["2. What changed on Forever"] = "2. Cosa è cambiato su Forever"
L["Secret values"] = "Valori segreti"
L["During combat, boss encounters and PvP matches, the game gives addons \"secret\" values: Musca Auras receives the data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.\n\nWhat that means for your auras, tested in game on Forever unless marked otherwise:\n\n- |cffffd100The game draws what Musca Auras cannot read.|r Cooldown swipes and numbers, timer bars, and health or power bars keep moving in combat. A text made only of |cff99ccff%p|r and |cff99ccff%t|r (for example |cff99ccff%p|r or |cff99ccff%p / %t|r) is drawn by the game too, as a raw number.\n- |cffffd100Buffs and debuffs are refused to addons in combat.|r An aura that was showing before the pull keeps counting down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.\n- |cffffd100Your own recast restarts the timer.|r When you cast again a buff that you put on yourself, the timer of an Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else. A recast by someone else is not seen.\n- |cffffd100A buff or debuff applied for the first time in combat|r is only seen when combat ends.\n- |cffffd100Logic on secret data keeps its last state.|r A condition such as \"Health < 50%\" keeps the state it had when combat started, then updates when combat ends. The health of a target that is not a player is hidden by the game even out of combat: such a condition on the Target unit never changes. Use \"Show only below (%)\" on the Health trigger instead."] = "Durante i combattimenti, gli incontri con i boss e le partite PvP, il gioco fornisce agli addon valori \"segreti\": Musca Auras riceve il dato ma non può leggerlo, confrontarlo né fare calcoli con esso. Fuori dal combattimento quasi tutto funziona come prima.\n\nCosa significa per le tue aure, testato in gioco su Forever salvo diversa indicazione:\n\n- |cffffd100Il gioco disegna ciò che Musca Auras non può leggere.|r Le animazioni e i numeri dei cooldown, le barre dei timer e le barre di salute o di risorsa continuano a muoversi in combattimento. Anche un testo composto solo da |cff99ccff%p|r e |cff99ccff%t|r (ad esempio |cff99ccff%p|r o |cff99ccff%p / %t|r) viene disegnato dal gioco, come numero grezzo.\n- |cffffd100Buff e debuff vengono negati agli addon in combattimento.|r Un'aura che era mostrata prima del pull continua il conto alla rovescia dall'ultimo tempo noto. I suoi stack restano congelati. Tutto viene riletto a fine combattimento.\n- |cffffd100Il tuo lancio ripetuto riavvia il timer.|r Quando lanci di nuovo un buff che hai messo su te stesso, il timer di un trigger Aura sull'unità Player riparte dall'ultima durata nota, anche se quel lancio è andato a qualcun altro. Un nuovo lancio da parte di altri non viene rilevato.\n- |cffffd100Un buff o debuff applicato per la prima volta in combattimento|r viene rilevato solo a fine combattimento.\n- |cffffd100La logica su dati segreti mantiene il suo ultimo stato.|r Una condizione come \"Health < 50%\" mantiene lo stato che aveva all'inizio del combattimento, poi si aggiorna a fine combattimento. La salute di un bersaglio che non è un giocatore è nascosta dal gioco anche fuori dal combattimento: una tale condizione sull'unità Target non cambia mai. Usa invece \"Show only below (%)\" sul trigger Health."
L["The combat log is closed"] = "Il combat log è chiuso"
L["Triggers that use the combat log (|cff99ccffCLEU|r, \"Combat Log\") never fire. For damage taken, use the event |cff99ccffUNIT_COMBAT:player|r."] = "I trigger che usano il combat log (|cff99ccffCLEU|r, \"Combat Log\") non scattano mai. Per i danni subiti, usa l'evento |cff99ccffUNIT_COMBAT:player|r."
L["Other changes"] = "Altre modifiche"
L["- |cffffd100Spells by name or ID.|r In the spell lists of an Aura (Modern) trigger, type a spell name in the game language: it becomes the IDs of all its ranks. Elsewhere, name search may not find spells: type the spell ID. Get the ID of your rank out of combat: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic spells have one ID per rank.\n- |cffffd100Talent load options|r list the talents of your own specialization only. Select it alone in the |cffffd100Class and Specialization|r load option first.\n- |cffffd100Chat Message action|r can be blocked during encounters and PvP matches.\n- |cffffd100Old functions in custom code|r no longer exist (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzard Cooldown Manager.|r |cff99ccff/wa cdm|r shows or hides it, out of combat. On the Forever beta it is not enabled for every class: for some classes it has no spell and no buff, and the \"From the Cooldown Manager\" lists of the Cooldown and Aura triggers are empty."] = "- |cffffd100Incantesimi per nome o ID.|r Nelle liste di incantesimi di un trigger Aura (Modern), digita il nome di un incantesimo nella lingua del gioco: diventa gli ID di tutti i suoi rank. Altrove la ricerca per nome potrebbe non trovare gli incantesimi: digita l'ID dell'incantesimo. Ottieni l'ID del tuo rank fuori dal combattimento: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Gli incantesimi di Classic hanno un ID per rank.\n- |cffffd100Le opzioni di caricamento dei talenti|r elencano solo i talenti della tua specializzazione. Selezionala prima da sola nell'opzione di caricamento |cffffd100Classe e Specializzazione|r.\n- |cffffd100L'azione Messaggio di chat|r può essere bloccata durante gli incontri e le partite PvP.\n- |cffffd100Le vecchie funzioni nel codice personalizzato|r non esistono più (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Usa |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Cooldown Manager di Blizzard.|r |cff99ccff/wa cdm|r lo mostra o lo nasconde, fuori dal combattimento. Nella beta di Forever non è attivo per tutte le classi: per alcune non ha né incantesimi né buff, e le liste \"From the Cooldown Manager\" dei trigger Cooldown e Aura sono vuote."
L["3. What you can use"] = "3. Cosa puoi usare"
L["|cffffd100Tested in game, works in combat:|r\n\n- Spell cooldowns: icon swipe and number. With |cffffd100Show Global Cooldown|r, the \"On Global Cooldown\" condition can hide the number during the global cooldown.\n- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.\n- Health bar of your target and power bar of yourself, with a |cff99ccff%p / %t|r text.\n- Swing timer, main hand.\n- Your own casts: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (see the recipes below).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Tested in game:|r\n\n- Temporary weapon enchants (poison, oil, sharpening stone), both hands.\n- |cffffd100Elapsed Time|r filter of the Aura trigger.\n- Bag Space trigger.\n- Role trigger (role chosen in the group finder).\n- |cff99ccff/wa cdm|r, and the \"From the Cooldown Manager\" lists, for the classes that have it.\n\n|cffffd100Works, with limits:|r\n\n- Stacks stay frozen in combat.\n- Conditions and filters on percentages, stacks or remaining time use the value from before combat.\n- A filter checked in the trigger itself (for example \"Health (%) < 50\") freezes the trigger in combat instead of hiding the aura.\n\n|cffffd100Not tested in game yet:|r\n\n- Swing timer off hand, ranged and wand, \"Target In Range\" option.\n- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.\n- Border and icon colored by dispel type.\n- Aura triggers in party or raid mode, glows, range conditions.\n- Encounter start and end: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Does not work:|r\n\n- Aura trigger filtered by |cffffd100Game Categories|r (crowd control, cast by me...): nothing shows at the moment.\n- Other players' casts.\n- Enemy names and IDs in instances.\n- Mana or energy tick timer in combat.\n- Combat log triggers."] = "|cffffd100Testato in gioco, funziona in combattimento:|r\n\n- Cooldown degli incantesimi: animazione dell'icona e numero. Con |cffffd100Show Global Cooldown|r, la condizione \"On Global Cooldown\" può nascondere il numero durante il cooldown globale.\n- Buff su te stesso noti prima del combattimento: icona e timer. Il tuo lancio ripetuto riavvia il timer.\n- Barra della salute del tuo bersaglio e barra di risorsa di te stesso, con un testo |cff99ccff%p / %t|r.\n- Swing timer, mano principale.\n- I tuoi lanci: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (vedi le ricette più sotto).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Testato in gioco:|r\n\n- Incantamenti temporanei delle armi (veleno, olio, pietra per affilare), entrambe le mani.\n- Filtro |cffffd100Elapsed Time|r del trigger Aura.\n- Trigger Bag Space.\n- Trigger Role (ruolo scelto nella ricerca gruppo).\n- |cff99ccff/wa cdm|r e le liste \"From the Cooldown Manager\", per le classi che lo hanno.\n\n|cffffd100Funziona, con limiti:|r\n\n- Gli stack restano congelati in combattimento.\n- Le condizioni e i filtri su percentuali, stack o tempo rimanente usano il valore di prima del combattimento.\n- Un filtro controllato nel trigger stesso (ad esempio \"Health (%) < 50\") congela il trigger in combattimento invece di nascondere l'aura.\n\n|cffffd100Non ancora testato in gioco:|r\n\n- Swing timer mano secondaria, a distanza e bacchetta, opzione \"Target In Range\".\n- Trigger Ammo, Equipment Durability, Tracking, opzione di caricamento per difficoltà dell'istanza.\n- Bordo e icona colorati in base al tipo di dissolvenza.\n- Trigger Aura in modalità gruppo o incursione, bagliori, condizioni di portata.\n- Inizio e fine dell'incontro: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Non funziona:|r\n\n- Trigger Aura filtrato per |cffffd100Game Categories|r (controllo di massa, lanciato da me...): al momento non viene mostrato nulla.\n- I lanci degli altri giocatori.\n- Nomi e ID dei nemici nelle istanze.\n- Timer del tick di mana o energia in combattimento.\n- I trigger del combat log."
L["4. New way of thinking: prepare or deduce"] = "4. Un nuovo modo di pensare: preparare o dedurre"
L["Stop reading the combat. |cffffd100Prepare|r before the pull, or |cffffd100deduce|r from what you do.\n\n- Debuff on target, show its timer: You cast the DoT, start a fixed timer\n- Buff missing in combat, alert: Check buffs and consumables before the pull\n- Boss casts X, alert: Boss timeline from the pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown ready, flash: Let the action bar show the cooldown\n- Low mana, alert: Power trigger, \"Show only below (%)\" option\n\nFor debuffs on enemies, the Blizzard nameplates and target frame can show them (\"only my debuffs\"). Use them for what only the game can see."] = "Smetti di leggere il combattimento. |cffffd100Prepara|r prima del pull, oppure |cffffd100deduci|r da ciò che fai.\n\n- Debuff sul bersaglio, mostrarne il timer: lanci il DoT, avvii un timer fisso\n- Buff mancante in combattimento, avviso: controlla buff e consumabili prima del pull\n- Il boss lancia X, avviso: timeline del boss dal pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown pronto, lampeggio: lascia che la barra delle azioni mostri il cooldown\n- Mana basso, avviso: trigger Power, opzione \"Show only below (%)\"\n\nPer i debuff sui nemici, le nameplate di Blizzard e il riquadro del bersaglio possono mostrarli (\"solo i miei debuff\"). Usali per ciò che solo il gioco può vedere."
L["5. Recipe: DoT or buff timer from your cast"] = "5. Ricetta: timer di DoT o buff dal tuo lancio"
L["Not tested in game yet. No custom code. Example: Corruption on your target.\n\n1. Out of combat, get the ID of your rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Note the |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (or |cffffd100Progress Bar|r).\n3. |cffffd100Trigger|r tab:\n    - Type: |cffffd100Other Events|r, then |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: your spell ID (for example 11672)\n    - |cffffd100Hide when target dies|r: checked\n    - |cffffd100Hide After|r, Duration: the spell duration from its tooltip (Corruption: 18)\n4. Test on any mob.\n\nThe trigger gives the icon of the spell.\n\nLimits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted or dispelled. It follows one target only.\n\n|cffffd100Hide when target dies|r only sees the death of your current target. If you change target and the mob with your DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff on yourself, leave the box unchecked.\n\n|cffffd100Hide when target changes|r hides the timer as soon as you target another mob or clear your target. A target change during a cast is not seen. Targeting the first mob again does not bring the timer back.\n\nA missed or resisted spell still starts the timer: the game reports the cast as succeeded, and the combat log that tells misses is not available to addons on WoW Forever.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Non ancora testato in gioco. Nessun codice personalizzato. Esempio: Corruzione sul tuo bersaglio.\n\n1. Fuori dal combattimento, ottieni l'ID del tuo rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Annota lo |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (oppure |cffffd100Progress Bar|r).\n3. Scheda |cffffd100Trigger|r:\n    - Type: |cffffd100Other Events|r, poi |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: l'ID del tuo incantesimo (ad esempio 11672)\n    - |cffffd100Hide when target dies|r: selezionato\n    - |cffffd100Hide After|r, Duration: la durata dell'incantesimo dal suo tooltip (Corruzione: 18)\n4. Prova su un mob qualsiasi.\n\nIl trigger fornisce l'icona dell'incantesimo.\n\nLimiti: un'aura per incantesimo. Lanciarlo di nuovo riavvia il timer. L'aura non sa se l'incantesimo è stato resistito o dissolto. Segue un solo bersaglio.\n\n|cffffd100Hide when target dies|r vede solo la morte del tuo bersaglio attuale. Se cambi bersaglio e il mob con il tuo DoT muore, il timer continua. Se cambi bersaglio e il nuovo bersaglio muore, il timer viene nascosto. Per un buff su te stesso, lascia la casella deselezionata.\n\n|cffffd100Hide when target changes|r nasconde il timer appena selezioni un altro mob o deselezioni il bersaglio. Un cambio di bersaglio durante un lancio non viene rilevato. Selezionare di nuovo il primo mob non riporta il timer.\n\nUn incantesimo mancato o resistito avvia comunque il timer: il gioco segnala il lancio come riuscito, e il combat log che indica i mancati non è disponibile agli addon su WoW Forever.\n\nEsempio pronto per Immolazione rank 1 (ID incantesimo 348, 15 secondi). Clicca sul pulsante di importazione qui sotto."
L["Import the DoT timer"] = "Importa il timer del DoT"
L["Variant: one timer per mob, on its nameplate"] = "Variante: un timer per mob, sulla sua nameplate"
L["Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.\n\n|cffffd100Only with the default Blizzard nameplates.|r Addons that replace the nameplates (EllesmereUI, ElvUI, Plater, Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places. The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the Musca Auras side. With a nameplate addon, use the single timer above.\n\nEnemy nameplates must be shown (key |cffffd100V|r).\n\nHow it works:\n\n- The aura is a |cffffd100Dynamic Group|r with |cffffd100Group by Frame|r set to |cffffd100Nameplates|r, and one icon inside.\n- The icon uses a |cffffd100Trigger State Updater|r on |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- When you cast the spell, the code looks for the nameplate of your target: it tests |cff99ccffnameplate1|r to |cff99ccffnameplate40|r with |cff99ccffUnitIsUnit(token, \"target\")|r, which stays readable in combat. It starts a timer for that nameplate and stores the nameplate in the state (|cff99ccffunit = token|r), so the group puts the icon on it.\n- When a nameplate disappears (the mob died or went out of range), its timer is removed.\n\nLimits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does not know if the spell was resisted or dispelled.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Testato in gioco su Forever. Ogni mob su cui lanci l'incantesimo ottiene la propria icona e il proprio timer, sopra la sua nameplate.\n\n|cffffd100Solo con le nameplate predefinite di Blizzard.|r Gli addon che sostituiscono le nameplate (EllesmereUI, ElvUI, Plater, Kui, ecc.) nascondono la barra della salute di Blizzard a cui questa aura si aggancia: le icone allora non compaiono da nessuna parte, o in posti casuali. Il gioco non permette agli addon di misurare le regioni protette delle nameplate né di agganciarsi ad esse, quindi Musca Auras non può correggerlo. Con un addon per le nameplate, usa il timer singolo qui sopra.\n\nLe nameplate dei nemici devono essere mostrate (tasto |cffffd100V|r).\n\nCome funziona:\n\n- L'aura è un |cffffd100Dynamic Group|r con |cffffd100Group by Frame|r impostato su |cffffd100Nameplates|r, e un'icona al suo interno.\n- L'icona usa un |cffffd100Trigger State Updater|r su |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- Quando lanci l'incantesimo, il codice cerca la nameplate del tuo bersaglio: prova da |cff99ccffnameplate1|r a |cff99ccffnameplate40|r con |cff99ccffUnitIsUnit(token, \"target\")|r, che resta leggibile in combattimento. Avvia un timer per quella nameplate e la memorizza nello stato (|cff99ccffunit = token|r), così il gruppo vi posiziona l'icona.\n- Quando una nameplate scompare (il mob è morto o fuori portata), il suo timer viene rimosso.\n\nLimiti: un timer va perso quando la nameplate scompare, ad esempio quando ti allontani dal mob. L'aura non sa se l'incantesimo è stato resistito o dissolto.\n\nEsempio pronto per Immolazione rank 1 (ID incantesimo 348, 15 secondi). Clicca sul pulsante di importazione qui sotto."
L["Import the nameplate DoT timer"] = "Importa il timer del DoT sulla nameplate"
L["6. Recipe: pre-pull checklist"] = "6. Ricetta: checklist pre-pull"
L["The idea: one group of icons that shows what is missing, only out of combat and in a group.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Name it \"Pre-pull\".\n2. In the group, |cffffd100Load|r tab: |cffffd100In Combat|r unchecked twice (the box shows a cross = \"not in combat\"), |cffffd100In Group|r checked.\n3. Add one icon per check, inside the group.\n\n|cffffd100Missing buff|r (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):\n\n- Trigger type: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.\n- Show On: |cffffd100Aura(s) Missing|r\n\n|cffffd100Weapon enchant|r (poison, oil, stone): trigger |cffffd100Weapon Enchant|r, show when missing.\n\n|cffffd100Reagents and ammo|r (Soul Shards, arrows, Symbol of Kings...):\n\n- Trigger type: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: the item ID\n- Count: lower than the number you want, for example |cff99ccff< 5|r\n\nBecause the group only loads out of combat, secret data never matters here.\n\nReady-made example for a Warlock (tested in game on Forever). Click the import button below.\n\n- Fortitude: the buff is missing (every rank, Prayer of Fortitude included) (in a party or raid)\n- Mark of the Wild: the buff is missing (every rank, Gift of the Wild included) (in a party or raid)\n- Arcane Intellect: the buff is missing (every rank, Arcane Brilliance included) (in a party or raid)\n- Demon Skin / Armor: neither Demon Skin nor Demon Armor is active (Warlock, solo included)\n- Soul Shards: fewer than 3 Soul Shards (item 6265) in your bags (Warlock, solo included)\n\nNone of them loads in combat. Buffs are matched by spell ID, so the group works with any client language. The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it."] = "L'idea: un gruppo di icone che mostra ciò che manca, solo fuori dal combattimento e in gruppo.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Chiamalo \"Pre-pull\".\n2. Nel gruppo, scheda |cffffd100Load|r: |cffffd100In Combat|r deselezionato due volte (la casella mostra una croce = \"non in combattimento\"), |cffffd100In Group|r selezionato.\n3. Aggiungi un'icona per ogni controllo, dentro il gruppo.\n\n|cffffd100Buff mancante|r (Parola del Potere: Fortitudine, Marchio della Natura, Intelletto Arcano, Benedizioni, Spine, elisir, cibo):\n\n- Tipo di trigger: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Nome o ID incantesimo dell'aura: il buff. Per i buff con rank, aggiungi ogni rank che vuoi accettare.\n- Show On: |cffffd100Aura(e) Mancante(i)|r\n\n|cffffd100Incantamento dell'arma|r (veleno, olio, pietra): trigger |cffffd100Weapon Enchant|r, mostra quando manca.\n\n|cffffd100Reagenti e munizioni|r (Frammenti d'Anima, frecce, Simbolo dei Re...):\n\n- Tipo di trigger: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: l'ID dell'oggetto\n- Count: inferiore al numero desiderato, ad esempio |cff99ccff< 5|r\n\nPoiché il gruppo si carica solo fuori dal combattimento, i dati segreti qui non contano.\n\nEsempio pronto per uno Stregone (testato in gioco su Forever). Clicca sul pulsante di importazione qui sotto.\n\n- Fortitudine: il buff manca (ogni rank, Preghiera della Fortitudine inclusa) (in gruppo o in incursione)\n- Marchio della Natura: il buff manca (ogni rank, Dono della Natura incluso) (in gruppo o in incursione)\n- Intelletto Arcano: il buff manca (ogni rank, Brillantezza Arcana inclusa) (in gruppo o in incursione)\n- Pelle del Demone / Armatura del Demone: né Pelle del Demone né Armatura del Demone è attiva (Stregone, anche in solitario)\n- Frammenti d'Anima: meno di 3 Frammenti d'Anima (oggetto 6265) nelle tue borse (Stregone, anche in solitario)\n\nNessuna si carica in combattimento. I buff sono riconosciuti tramite ID incantesimo, quindi il gruppo funziona con qualsiasi lingua del client. Gli ID provengono dai dati di Classic 1.12: se un'icona resta visibile mentre hai il buff, segnalalo."
L["Import the pre-pull checklist"] = "Importa la checklist pre-pull"
L["7. Recipe: boss timeline"] = "7. Ricetta: timeline del boss"
L["Not tested in game yet.\n\n1. Find the encounter ID. Out of combat, create a test aura on |cff99ccffENCOUNTER_START|r and print the ID, or search it on Wowhead.\n2. For each boss ability, create a |cffffd100Progress Bar|r:\n    - Trigger type: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: the time of the first cast after the pull, in seconds.\n3. |cffffd100Load|r tab: |cffffd100Encounter ID(s)|r = the same ID. The aura unloads when the encounter ends, so a wipe does not leave the bar on screen.\n4. If a readable event marks a new phase (an emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use it to restart the timers.\n\nAbilities based on boss health % or on random timings cannot be predicted."] = "Non ancora testato in gioco.\n\n1. Trova l'ID dell'incontro. Fuori dal combattimento, crea un'aura di prova su |cff99ccffENCOUNTER_START|r e stampa l'ID, oppure cercalo su Wowhead.\n2. Per ogni abilità del boss, crea una |cffffd100Progress Bar|r:\n    - Tipo di trigger: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- sostituisci con l'ID dell'incontro del boss|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: il tempo del primo lancio dopo il pull, in secondi.\n3. Scheda |cffffd100Load|r: |cffffd100Encounter ID(s)|r = lo stesso ID. L'aura viene scaricata alla fine dell'incontro, quindi un wipe non lascia la barra sullo schermo.\n4. Se un evento leggibile segna una nuova fase (un emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), usalo per riavviare i timer.\n\nLe abilità basate sulla percentuale di salute del boss o su tempi casuali non possono essere previste."
L["8. Custom code"] = "8. Codice personalizzato"
L["In custom code, check every value before you compare it or do math with it:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nWithout this check, the code stops with a Lua error in combat. Musca Auras does not show those errors: the aura just keeps its last state.\n\nIn combat, the |cff99ccffC_UnitAuras|r functions refuse addon code when auras are secret. They stop the code with \"Auras cannot be accessed when secret while tainted\" (tested in game): call them under |cff99ccffpcall|r, or only out of combat.\n\nFor health events, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r does not exist on Forever.\n\nOther tools:\n\n- |cff99ccff/dump <expression>|r shows the content of a value in chat, secret values included.\n- |cff99ccff/eventtrace|r shows events and which of their values are secret.\n- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend."] = "Nel codice personalizzato, controlla ogni valore prima di confrontarlo o fare calcoli con esso:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nSenza questo controllo, il codice si interrompe con un errore Lua in combattimento. Musca Auras non mostra questi errori: l'aura mantiene semplicemente il suo ultimo stato.\n\nIn combattimento, le funzioni |cff99ccffC_UnitAuras|r rifiutano il codice degli addon quando le aure sono segrete. Interrompono il codice con \"Auras cannot be accessed when secret while tainted\" (testato in gioco): chiamale sotto |cff99ccffpcall|r, oppure solo fuori dal combattimento.\n\nPer gli eventi di salute, usa |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r non esiste su Forever.\n\nAltri strumenti:\n\n- |cff99ccff/dump <expression>|r mostra il contenuto di un valore in chat, compresi i valori segreti.\n- |cff99ccff/eventtrace|r mostra gli eventi e quali dei loro valori sono segreti.\n- Su Forever non ci sono manichini da addestramento. Prova in un vero combattimento: attacca un mob qualsiasi o sfida un amico a duello."
L["9. Importing auras from Wago"] = "9. Importare aure da Wago"
L["Most packs made for Classic Era, Season of Discovery or Retail need work:\n\n- replace combat log triggers (section 5 for DoTs, |cff99ccffUNIT_COMBAT:player|r for damage taken);\n- replace spell names by the spell IDs of your ranks;\n- rewrite custom code that calls old functions;\n- move buff and consumable checks out of combat (section 6).\n\nFound an aura that should work and does not? Report it: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"] = "La maggior parte dei pacchetti creati per Classic Era, Season of Discovery o Retail richiede un po' di lavoro:\n\n- sostituire i trigger del combat log (sezione 5 per i DoT, |cff99ccffUNIT_COMBAT:player|r per i danni subiti);\n- sostituire i nomi degli incantesimi con gli ID dei tuoi rank;\n- riscrivere il codice personalizzato che chiama vecchie funzioni;\n- spostare fuori dal combattimento i controlli di buff e consumabili (sezione 6).\n\nHai trovato un'aura che dovrebbe funzionare e non funziona? Segnalala: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"
L["10. Coming from ForeverAuras"] = "10. Se vieni da ForeverAuras"
L["Export your auras from ForeverAuras, then paste the strings in the Musca Auras import window. Groups work too.\nMusca Auras converts them on import, and lists in the chat what it could not convert.\n\nWhat each one becomes:\n\n- Cooldown Manager trigger, cooldown: Cooldown trigger (spell ID, or name if ForeverAuras used names)\n- Cooldown Manager trigger, buff: Aura trigger (your buffs, or your debuffs on the target)\n- Cooldown Manager trigger, item: Item cooldown trigger\n- Aura (Blizzard) trigger: Aura trigger with Game Categories (sorting removed). Game Categories shows nothing at the moment.\n- Dispel type icon: Dispel Type Icon sub element\n- Dispel type border: Border colored by dispel type\n- Swing Timer, Ammo: same triggers (Ammo: the item list now filters the equipped ammo)\n- Role, Tracking, Equipment Durability, Bag Space: same triggers (Tracking: by spell ID only, no \"always\" mode)\n\nNot converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one.\nDo not run both addons at the same time."] = "Esporta le tue aure da ForeverAuras, poi incolla le stringhe nella finestra di importazione di Musca Auras. Funzionano anche i gruppi.\nMusca Auras le converte all'importazione ed elenca in chat ciò che non ha potuto convertire.\n\nCosa diventa ciascun elemento:\n\n- Trigger Cooldown Manager, cooldown: trigger Cooldown (ID dell'incantesimo, o nome se ForeverAuras usava i nomi)\n- Trigger Cooldown Manager, buff: trigger Aura (i tuoi buff, o i tuoi debuff sul bersaglio)\n- Trigger Cooldown Manager, oggetto: trigger Item cooldown\n- Trigger Aura (Blizzard): trigger Aura con Game Categories (ordinamento rimosso). Game Categories al momento non mostra nulla.\n- Icona del tipo di dissolvenza: sotto-elemento Dispel Type Icon\n- Bordo del tipo di dissolvenza: bordo colorato in base al tipo di dissolvenza\n- Swing Timer, Ammo: stessi trigger (Ammo: la lista degli oggetti ora filtra le munizioni equipaggiate)\n- Role, Tracking, Equipment Durability, Bag Space: stessi trigger (Tracking: solo per ID incantesimo, nessuna modalità \"always\")\n\nNon convertiti: i trigger TimelineParser (richiedono l'addon ExRT_Reminder e una timeline del boss, che WoW Forever non mostra). Un trigger di cooldown Cooldown Manager con più incantesimi mantiene il primo.\nNon usare i due addon contemporaneamente."
L["|cff00ccffMusca Auras|r - Guide"] = "|cff00ccffMusca Auras|r - Guida"
L["Show always"] = "Mostra sempre"
L["Show in combat"] = "Mostra in combattimento"
L["Show out of combat"] = "Mostra fuori dal combattimento"
L["Enable"] = "Attiva"
L["Disable"] = "Disattiva"
L["Edit in /wa"] = "Modifica in /wa"
L["Click the aura %s will follow. Right click: cancel."] = "Clicca sull'aura che %s seguirà. Clic destro: annulla."
L["Keep the changes made to the placement of your auras?"] = "Mantenere le modifiche apportate al posizionamento delle tue aure?"
L["Save and quit"] = "Salva ed esci"
L["Discard"] = "Scarta"
L["Snap"] = "Aggancia"
L["Revert"] = "Ripristina"
L["Quit"] = "Esci"
L["Placement mode suspended during combat."] = "Modalità di posizionamento sospesa durante il combattimento."
L["Close the Edit Mode first."] = "Chiudi prima la Modalità Modifica."
L["Anchor to..."] = "Ancora a..."
L["Remove Anchor"] = "Rimuovi ancoraggio"
L["Its groups"] = "I suoi gruppi"
L["Drag: moves the whole group. Click inside: selects one level lower."] = "Trascina: sposta l'intero gruppo. Clic all'interno: seleziona un livello più in basso."
L["Follows: %s"] = "Segue: %s"
L["Follows: its group"] = "Segue: il suo gruppo"
L["Follows: the screen"] = "Segue: lo schermo"
L["The placement mode does not open during combat."] = "La modalità di posizionamento non si apre durante il combattimento."
L["Unlock"] = "Sblocca"
L["Opens the placement mode (/wa unlock): move, size and anchor the auras on the screen."] = "Apre la modalità di posizionamento (/wa unlock): sposta, ridimensiona e ancora le aure sullo schermo."
L["Guide"] = "Guida"
L["Guide:"] = "Guida:"
L["learn Musca Auras"] = "impara Musca Auras"
L["Musca Auras Guide"] = "Guida di Musca Auras"
L["Learn everything about Musca Auras on WoW Forever: how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import."] = "Impara tutto su Musca Auras in WoW Forever: come funziona un'aura, cosa è cambiato in combattimento, cosa funziona e cosa no, ricette passo passo e aure pronte da importare."
L["/wa tutorial - Guide: learn everything about Musca Auras on WoW Forever, with auras to import"] = "/wa tutorial - Guida: impara tutto su Musca Auras in WoW Forever, con aure da importare"
L["/wa cdm - Show or hide the Blizzard Cooldown Manager"] = "/wa cdm - Mostra o nascondi il gestore dei tempi di recupero di Blizzard"
L["/wa unlock - Place your auras on the screen: move, resize, anchor them to each other"] = "/wa unlock - Posiziona le tue aure sullo schermo: spostale, ridimensionale, ancorale tra loro"
L["/wa demo [aura name] - Show every loaded aura, or one aura, with sample timers to set up your layout"] = "/wa demo [nome aura] - Mostra tutte le aure caricate, o una sola, con timer di esempio per impostare la disposizione"
L["/wa backups - List the daily copies of your auras"] = "/wa backups - Elenca le copie giornaliere delle tue aure"
L["/wa restore <number> - Replace your auras with a daily copy and reload the UI"] = "/wa restore <numero> - Sostituisci le tue aure con una copia giornaliera e ricarica l'interfaccia"
L["/wa deleted - List the auras deleted in the last 30 days"] = "/wa deleted - Elenca le aure eliminate negli ultimi 30 giorni"
L["/wa undelete <number> - Import a deleted aura again"] = "/wa undelete <numero> - Importa di nuovo un'aura eliminata"
L["Time in Musca Auras: %.2fs / %ds (%.1f%%)"] = "Tempo in Musca Auras: %.2fs / %ds (%.1f%%)"

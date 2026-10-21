if (GAME_LOCALE or GetLocale()) ~= "frFR" then
  return
end

local L = WeakAuras.L

-- WeakAuras
L[ [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=] ] = "Filtres supportés : 'Pseudo', 'Pseudo-Serveur', '-Serveur'. Supporte les entrées multiples, séparées par des virgules; utiliser \\ pour \"échapper\" à -."
L["%s Overlay Color"] = "%s couleur de la superposition"
L["* Suffix"] = "* Suffixe"
L["/wa help - Show this message"] = "/wa help - Affiche ce message"
L["/wa minimap - Toggle the minimap icon"] = "/wa minimap - Afficher l'icône sur la mini-carte"
L["/wa pprint - Show the results from the most recent profiling"] = "/wa pprint - Affiche les résultats du profilage le plus récent"
L["/wa pstart - Start profiling. Optionally include a duration in seconds after which profiling automatically stops. To profile the next combat/encounter, pass a \"combat\" or \"encounter\" argument."] = "/wa pstart - Démarre le profilage. Vous pouvez inclure une durée en secondes après laquelle le profilage s'arrête automatiquement. Pour établir le profil du prochain combat / contretemps, passez un argument \"combat\" ou \"rencontre\"."
L["/wa pstop - Finish profiling"] = "/wa pstop - Arrêter le profilage"
L["/wa repair - Repair tool"] = "/wa repair - Utilitaire de réparation"
L["|cff33ff99Fully usable in combat.|r"] = "|cff33ff99Entièrement utilisable en combat.|r"
L["|cffeda55fLeft-Click|r to toggle showing the main window."] = "|cffeda55fClic-Gauche|r pour déclencher l'affichage de la fenêtre principale."
L["|cffeda55fMiddle-Click|r to toggle the minimap icon on or off."] = "Clique du milieu pour activer ou désactiver l'icône de la mini-carte."
L["|cffeda55fRight-Click|r to toggle performance profiling window."] = "|cffeda55fClic-Droit|r pour basculer la fenêtre de profilage des performances."
L["|cffeda55fShift-Click|r to pause addon execution."] = "|cffeda55fMaj-Clic|r Pour suspendre l'exécution de l'addon."
L["|cffff0000deprecated|r"] = "|cffff0000obsolète|r"
L["|cFFFF0000Not|r Item Bonus Id Equipped"] = "ID du bonus de l'objet |cFFFF0000non|r équipé"
L["|cFFFF0000Not|r Item Equipped"] = "Objet |cFFFF0000non|r équipé"
L["|cFFFF0000Not|r Player Name/Realm"] = "|cFFFF0000Not|r Nom du joueur / serveur"
L["|cFFFF0000Not|r Spell Known"] = "|cFFFF0000Sort|r non connu"
L[ [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=] ] = "|cFFFF0000La prise en charge des événements COMBAT_LOG_EVENT_UNFILTERED non filtrés est obsolète|r Les événements COMBAT_LOG_EVENT_UNFILTERED sans filtre sont désactivés, car ils nuisent fortement aux performances. Plus d'informations : https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events"
L["|cffff2020Ignored in combat:|r %s |cffff9933(other units' casts are unreadable)|r"] = "|cffff2020Ignoré en combat :|r %s |cffff9933(les incantations des autres unités sont illisibles)|r"
L["|cffff9933Other units' casts: shown in combat, never filtered.|r"] = "|cffff9933Incantations des autres unités : affichées en combat, jamais filtrées.|r"
L["|cFFffcc00Extra Options:|r %s"] = "|cFFffcc00Options supplémentaires :|r %s"
L["|cFFffcc00Extra Options:|r None"] = "|cFFffcc00Options supplémentaires :|r aucun"
L[ [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=] ] = "• |cff00ff00Joueur|r, |cff00ff00Cible|r, |cff00ff00Focalisation|r et |cff00ff00Familier|r correspondent directement à ces identifiants d’unité spécifiques. • |cff00ff00Unité spécifique|r vous permet d’indiquer un identifiant d’unité valide à surveiller. |cffff0000Remarque|r : Le jeu ne déclenche pas d’événements pour tous les identifiants d’unité valides, ce qui rend certains non traçables par ce déclencheur. • |cffffff00Groupe|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arène|r et |cffffff00Barre de vie|r peuvent correspondre à plusieurs identifiants d’unité associés. • |cffffff00Groupe intelligent|r s’ajuste en fonction de votre type de groupe actuel : il correspond uniquement au \"joueur\" en solo, aux unités du \"groupe\" (y compris le joueur) en groupe, ou aux unités du \"raid\" en raid. |cffffff00*|r Les paramètres d’unité en jaune créeront des clones pour chaque unité correspondante tant que ce déclencheur fournit des informations dynamiques à l’aura."
L["1. Profession 1. Accessory"] = "1. Profession 1. Accessoire"
L["1. Profession 2. Accessory"] = "1. Profession 2. Accessoire"
L["1. Professsion Tool"] = "1. Outil de profession"
L["10 Man Raid"] = "Raid 10 Joueurs"
L["10 Player Raid"] = "Raid à 10 Joueurs"
L["10 Player Raid (Heroic)"] = "Raid à 10 Joueurs (Héroïque)"
L["10 Player Raid (Normal)"] = "Raid à 10 Joueurs (Normal)"
L["2. Profession 1. Accessory"] = "2. Profession 1. Accessoire"
--[[Translation missing --]]
L["2. Profession 2. Accessory"] = "2. Profession 2. Accessory"
--[[Translation missing --]]
L["2. Professsion Tool"] = "2. Professsion Tool"
L["20 Man Raid"] = "Raid 20 Joueurs"
L["20 Player Raid"] = "Raid à 20 joueurs"
L["25 Man Raid"] = "Raid 25 Joueurs"
L["25 Player Raid"] = "Raid à 25 joueurs"
L["25 Player Raid (Heroic)"] = "Raid 25 Joueurs (Héroïque)"
L["25 Player Raid (Normal)"] = "Raid 25 Joueurs (Normal)"
--[[Translation missing --]]
L["25 Player Raid (Titan Reforged)"] = "25 Player Raid (Titan Reforged)"
L["40 Man Raid"] = "Raid 40 Personnes"
L["40 Player Raid"] = "Raid 40 Joueurs"
L["5 Man Dungeon"] = "Donjon 5 joueurs"
--[[Translation missing --]]
L[ [=[A detailed overview of your auras and WeakAuras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=] ] = [=[A detailed overview of your auras and WeakAuras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=]
L["A custom text runs its code on each frame. Set an update throttle to lower its CPU cost."] = "Un texte personnalisé exécute son code à chaque image. Réglez son délai de mise à jour pour baisser son coût CPU."
L["A custom trigger runs its code on each frame. Set an update throttle to lower its CPU cost."] = "Un déclencheur personnalisé exécute son code à chaque image. Réglez un délai de mise à jour pour baisser son coût CPU."
L["A custom trigger runs its code on each frame. Use a less frequent event to lower its CPU cost."] = "Un déclencheur personnalisé exécute son code à chaque image. Choisissez un événement moins fréquent pour baisser son coût CPU."
--[[Translation missing --]]
L["A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."] = "A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."
L["Abbreviate"] = "Abréger"
L["AbbreviateLargeNumbers (Blizzard)"] = "AbrégerGrandsNombres (Blizzard)"
L["AbbreviateNumbers (Blizzard)"] = "AbrégerNombres (Blizzard)"
L["Absorb"] = "Absorbe"
--[[Translation missing --]]
L["Absorb and Healing"] = "Absorb and Healing"
L["Absorbed"] = "Absorbé"
L["Action Button Glow"] = "Bouton d'action brillant"
L["Actions"] = "Actions"
L["Active"] = [=[Actif
]=]
L[ [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = "Addon de boss actif : |cFFffcc00BigWigs|r Remarque : ce déclencheur utilisera BigWigs ou DBM, dans cet ordre si les deux sont installés."
L[ [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = "Addon de boss actif : |cFFffcc00DBM|r Remarque : ce déclencheur utilisera BigWigs ou DBM, dans cet ordre si les deux sont installés."
L["Add"] = "Ajouter"
L["Add Missing Auras"] = "Ajouter les auras manquantes"
--[[Translation missing --]]
L["Advanced Caster's Target Check"] = "Advanced Caster's Target Check"
L["Affected"] = "Affecté"
L["Affected Unit Count"] = "Nombre d'unités Affectées"
--[[Translation missing --]]
L["Afk"] = "Afk"
L["Aggro"] = "Aggro"
L["Agility"] = "Agilité"
L["Ahn'Qiraj"] = "Ahn'Qiraj"
--[[Translation missing --]]
L["Alert Type"] = "Type d'alerte"
L["Alive"] = "En vie"
L["All"] = "Tous"
L["All children of this aura will also not be loaded, to minimize the chance of further corruption."] = "Tous les éléments enfants de cette aura ne seront également pas chargés, afin de minimiser le risque de corruption supplémentaire."
L["All States table contains a non table at key: '%s'."] = "La table All States contient une valeur non-table à la clé : « %s »."
L["All Triggers"] = "Tous les déclencheurs"
L["Alliance"] = "Alliance"
L["Alpha"] = "Opacité"
L["Always"] = "Toujours"
L["Always active trigger"] = "Déclencheur toujours actif"
L["Always include realm"] = "Toujours inclure le royaume"
L["Always True"] = "Toujours Vrai"
L["Ammo"] = "Munitions"
L["Ammo Item"] = "Objet de munitions"
L["Amount"] = "Quantité"
L["Anchoring"] = "Ancrage"
L["And Talent"] = "Et talent"
--[[Translation missing --]]
L["Angle and Radius"] = "Angle et rayon"
L["Animations"] = "Animations"
L["Anticlockwise"] = "Sens anti-horaire"
--[[Translation missing --]]
L["Anub'Rekhan"] = "Anub'Rekhan"
L["Any"] = "N'importe lequel"
L["Any Triggers"] = "Au moins un déclencheur"
L["AOE"] = "AOE"
L["Arcane Resistance"] = "Résistance aux arcanes"
--[[Translation missing --]]
L[ [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=] ] = "Êtes-vous sûr de vouloir exécuter l'outil de réparation |cffff0000expérimental|r ? Cela écrasera toutes les modifications que vous avez apportées depuis la dernière mise à niveau de la base de données. Dernière mise à jour : %s"
L["Arena"] = "Arène"
L["Armor Rating"] = "Categorie d'armure"
L["Array"] = "Tableau"
L["Ascending"] = "Croissant"
L["Assigned Role"] = "Rôle assigné"
L["Assigned Role Icon"] = "Icône de rôle assigné"
L["Assist"] = "Assister"
L["At Least One Enemy"] = "Au moins un ennemi"
L["At missing Value"] = "À la valeur manquante"
L["At Percent"] = "À pourcentage"
L["At Value"] = "À la valeur"
--[[Translation missing --]]
L["At War"] = "At War"
L["Attach to End"] = "Attacher à la Fin"
L["Attach to End, backwards"] = "Attacher à la fin, en arrière"
L["Attach to Point"] = "Attacher au point"
L["Attach to Start"] = "Attacher au Début"
L["Attack Power"] = "Puissance d'attaque"
L["Attackable"] = "Attaquable"
L["Attackable Target"] = "Cible attaquable"
--[[Translation missing --]]
L["Aura"] = "Aura"
L["Aura '%s': %s"] = "Aura '%s' : %s"
L["Aura Applied"] = "Aura appliquée"
L["Aura Applied Dose"] = "Dose de l'aura appliquée"
L["Aura Broken"] = "Aura Cassée"
L["Aura Broken Spell"] = "Sort de l'Aura Cassée"
L["Aura is using deprecated SetDurationInfo"] = "L’aura utilise la fonction obsolète SetDurationInfo"
L["Aura loaded"] = "Aura chargée"
L["Aura Name"] = "Nom de l'aura"
L["Aura Names"] = "Nom des auras"
L["Aura Refresh"] = "Aura rafraichie"
L["Aura Removed"] = "Aura Supprimé"
L["Aura Removed Dose"] = "Aura Supprimé Dose"
L["Aura Shown"] = "Aura affichée"
L["Aura Stack"] = "Pile d'aura"
L["Aura Type"] = "Type Aura"
L["Aura Version: %s"] = "Version de l’aura : %s"
L["Aura(s) Found"] = "Aura(s) Trouvée(s)"
L["Aura(s) Missing"] = "Aura(s) Manquante"
L["Aura:"] = "Aura:"
L["Auras"] = "Auras"
L["Auras:"] = "Auras:"
L["Author Options"] = "Options de l'auteur"
L["Auto"] = "auto"
--[[Translation missing --]]
L["Autocast Shine"] = "Autocast Shine"
L["Automatic"] = "Automatique"
L["Automatic Length"] = "Longueur automatique"
L["Automatic Rotation"] = "Rotation automatique"
--[[Translation missing --]]
L["Available features: %s"] = "Available features: %s"
L["Ayamiss the Hunter"] = "Ayamiss le Chasseur"
--[[Translation missing --]]
L["Azuregos"] = "Azuregos"
L["Back and Forth"] = "D'avant en arrière"
L["Background"] = "Arrière-plan"
L["Background Color"] = "Couleur d'arrière-plan"
L["Bag Space"] = "Espace des sacs"
L["Balnazzar"] = "Balnazzar"
--[[Translation missing --]]
L["Bar"] = "Bar"
--[[Translation missing --]]
L["Bar and Icon"] = "Bar and Icon"
L["Bar Color/Gradient Start"] = "Couleur/gradient de départ de la barre"
L["Bar enabled in BigWigs settings"] = "Barre activée dans les paramètres de BigWigs"
L["Bar enabled in Boss Mod addon settings"] = "Barre activée dans les paramètres de l’addon de boss mod"
L["Bar enabled in DBM settings"] = [=[Barre activée dans les paramètres de DBM








]=]
L["Bar Texture"] = "Texture de la barre"
--[[Translation missing --]]
L["Bar Type"] = "Bar Type"
L["Baron Geddon"] = "Baron Geddon"
L["Battle for Azeroth"] = "Battle for Azeroth"
L["Battle.net Whisper"] = "Message Battle.net"
L["Battleground"] = [=[Champ De Bataille 
]=]
L["Battleguard Sartura"] = "Garde de guerre Sartura"
--[[Translation missing --]]
L["Beastmaster"] = "Beastmaster"
--[[Translation missing --]]
L["Beatrix"] = "Beatrix"
L["BG>Raid>Party>Say"] = "BG>Raid>Groupe>Dire"
L["BG-System Alliance"] = "Système-BG Alliance"
L["BG-System Horde"] = "Système-BG Horde"
L["BG-System Neutral"] = "Système-BG Neutre"
L["Big Defensive"] = "Défensif majeur"
L["Big Number"] = "Grand nombre"
L["BigWigs Addon"] = "Addon BigWigs"
L["BigWigs Message"] = "Message BigWigs"
--[[Translation missing --]]
L["BigWigs Module Loaded for Encounter ID"] = "Module BigWigs chargé pour l'ID de rencontre"
L["BigWigs Stage"] = "BigWigs Stage"
L["BigWigs Timer"] = "Temps BigWigs"
--[[Translation missing --]]
L["Black Wing Lair"] = "Black Wing Lair"
--[[Translation missing --]]
L["Bleed"] = "Bleed"
L["Blizzard Combat Text"] = "Texte de Combat Blizzard"
L["Blizzard Cooldown Manager hidden."] = "Gestionnaire de temps de recharge Blizzard masqué."
L["Blizzard Cooldown Manager shown."] = "Gestionnaire de temps de recharge Blizzard affiché."
L["Blizzard Cooldown Reduction"] = "Réduction du temps de recharge de Blizzard"
L["Block"] = "Bloc"
L["Block (%)"] = "Blocage"
L["Block Value"] = "Valeur du bloc"
L["Blocked"] = "Bloqué"
L["Bloodlord Mandokir"] = "Seigneur sanglant Mandokir"
L["Bonus Healing"] = "Bonus aux soins"
L["Border"] = "Encadrement"
L["Boss"] = "Boss"
L["Boss Emote"] = "Emote de boss"
--[[Translation missing --]]
L["Boss Mod Announce"] = "Boss Mod Announce"
--[[Translation missing --]]
L["Boss Mod Stage"] = "Boss Mod Stage"
--[[Translation missing --]]
L["Boss Mod Stage (Event)"] = "Boss Mod Stage (Event)"
--[[Translation missing --]]
L["Boss Mod Timer"] = "Boss Mod Timer"
L["Boss Whisper"] = "Chuchotement de Boss"
L["Bottom"] = "Bas"
L["Bottom Left"] = "Bas Gauche"
L["Bottom Right"] = "Bas Droite"
L["Bottom to Top"] = "De Bas en Haut"
L["Bounce"] = "Rebond"
L["Bounce with Decay"] = "Rebond décroissant"
--[[Translation missing --]]
L["Break"] = "Break"
--[[Translation missing --]]
L["BreakUpLargeNumbers (Blizzard)"] = "BreakUpLargeNumbers (Blizzard)"
--[[Translation missing --]]
L["Broken Items"] = "Objets cassés"
L["Broodlord Lashlayer"] = "Broodlord Lashlayer"
--[[Translation missing --]]
L["Buff"] = "Amélioration"
L["Buff/Debuff"] = "Amélioration / affaiblissement"
L["Buffed/Debuffed"] = "Amélioré/Affaiblit"
--[[Translation missing --]]
L["Burning Crusade"] = "Burning Crusade"
L["Buru the Gorger"] = "Buru Grandgosier"
--[[Translation missing --]]
L["Caldoran"] = "Caldoran"
--[[Translation missing --]]
L["Callback function"] = "Callback function"
L["Can Apply or Dispel"] = "Peut appliquer ou dissiper"
L["Can be used for e.g. checking if \"boss1target\" is the same as \"player\"."] = "Peut être utilisé pour par exemple vérifier si l'unité \"boss1target\" est la même que \"player\"."
L["Cancel"] = "Annuler"
--[[Translation missing --]]
L["Cancelable"] = "Annulable"
L[ [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."] = "Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."
--[[Translation missing --]]
L["Cannot change the Cooldown Manager in combat."] = "Impossible de modifier le gestionnaire de temps de recharge en combat."
L["Capped"] = "Capped"
L["Cast"] = "Incantation"
L["Cast Bar"] = "Barre d'incantation"
L["Cast by Me or my Pet"] = "Lancé par moi ou mon familier"
L["Cast Failed"] = "Incantation ratée"
L["Cast Start"] = "Incantation débutée"
L["Cast Success"] = "Incantation réussie"
L["Cast Type"] = "Type d'incantation"
L["Caster"] = "Lanceur de sort"
L["Caster Name"] = "Nom du Lanceur de sort "
L["Caster Realm"] = "Royaume du Lanceur de sort"
L["Caster Unit"] = "Unité lanceur de sort"
--[[Translation missing --]]
L["Casters Name/Realm"] = "Casters Name/Realm"
L["Caster's Target"] = "Cible du Lanceur de sort"
L["Casts the game marks as important. Unknown while the game hides the spell: the filter then hides the cast."] = "Incantations que le jeu marque comme importantes. Inconnu tant que le jeu cache le sort : le filtre masque alors l'incantation."
L["Cataclysm"] = "Cataclysm"
L["Ceil"] = "Cellule"
L["Center"] = "Centre"
L["Center, then alternating bottom and top"] = "Centrer, puis alterner bas et haut"
L["Center, then alternating left and right"] = "Centrer, puis alterner gauche et droite"
L["Center, then alternating right and left"] = "Centrer, puis alterner droite et gauche"
L["Center, then alternating top and bottom"] = "Centrer, puis alterner haut et bas"
L["Centered Horizontal"] = "Centrer horizontalement"
L["Centered Horizontal, then Centered Vertical"] = "Centrer horizontalement, puis centrer verticalement"
L["Centered Horizontal, then Down"] = "Centrer horizontalement, puis vers le haut"
L["Centered Horizontal, then Up"] = "Centrer horizontalement, puis vers le bas"
L["Centered Vertical"] = "Centré verticalement"
--[[Translation missing --]]
L["Centered Vertical, then Centered Horizontal"] = "Centered Vertical, then Centered Horizontal"
--[[Translation missing --]]
L["Centered Vertical, then Left"] = "Centered Vertical, then Left"
--[[Translation missing --]]
L["Centered Vertical, then Right"] = "Centered Vertical, then Right"
L["Changed"] = "Modifié"
L["Changing this option invalidates the selected forms: select them again."] = "Changer cette option invalide les formes choisies : choisissez-les à nouveau."
L["Channel"] = "Canal"
L["Channel (Spell)"] = "Canalisation"
L["Character Stats"] = "Stats Personnage"
L["Character Type"] = "Type de Personnage"
L["Charge gained/lost"] = "Charge gagné/perdu"
L["Charged"] = "Chargé"
L["Charges"] = "Charges"
--[[Translation missing --]]
L["Charges Changed Event"] = "Charges Changed Event"
L["Chat Frame"] = "Fenêtre de discussion"
L["Chat Message"] = "Message écrit"
--[[Translation missing --]]
L["Check if a single talent match a Rank"] = "Check if a single talent match a Rank"
--[[Translation missing --]]
L["Check nameplate's target every 0.2s"] = "Check nameplate's target every 0.2s"
--[[Translation missing --]]
L["Chromaggus"] = "Chromaggus"
L["Circle"] = "Cercle"
--[[Translation missing --]]
L["Circular Texture"] = "Circular Texture"
L["Clamp"] = "Attache"
L["Class"] = "Classe"
L["Class and Specialization"] = "Classe et spécialisation"
L["Classic"] = "Classic"
L["Classification"] = "Classification"
L["Clockwise"] = "Sens horaire"
L["Clone per Event"] = "Clone pour chaque Évènement"
L["Clone per Match"] = "Clone pour chaque Correspondance"
--[[Translation missing --]]
L["Coin Precision"] = "Coin Precision"
L["Color"] = "Couleur"
--[[Translation missing --]]
L["Color Animation"] = "Color Animation"
L["Combat Log"] = "Journal de combat"
--[[Translation missing --]]
L["Communities"] = "Communities"
--[[Translation missing --]]
L["Condition Custom Test"] = "Condition Custom Test"
L["Conditions"] = "Conditions"
L["Contains"] = "Contient"
--[[Translation missing --]]
L["Continuously update Movement Speed"] = "Continuously update Movement Speed"
L["Cooldown"] = "Temps de recharge"
--[[Translation missing --]]
L["Cooldown / aura duration"] = "Temps de recharge / durée de l'aura"
L["Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"] = "Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"
L["Cooldown Progress (Item)"] = "Progression du temps de recharge (Objet)"
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
L["Could not load WeakAuras Archive, the addon is %s"] = "Could not load WeakAuras Archive, the addon is %s"
L["Count"] = "Nombre"
L["Counter Clockwise"] = "Sens Antihoraire"
L["Create"] = "Créer"
L["Critical"] = "Critique"
L["Critical (%)"] = "Critique (%)"
--[[Translation missing --]]
L["Crop X"] = "Crop X"
--[[Translation missing --]]
L["Crop Y"] = "Crop Y"
L["Crowd Control"] = "Contrôle de foule"
L["Crowd Controlled"] = "Contrôlé"
L["Crushing"] = "Ecrasant"
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
L["Curse"] = "Malédiction"
L["Custom"] = "Personnalisé"
--[[Translation missing --]]
L["Custom Action"] = "Custom Action"
--[[Translation missing --]]
L["Custom Anchor"] = "Custom Anchor"
--[[Translation missing --]]
L["Custom Check"] = "Custom Check"
L["Custom Color"] = "Couleur personnalisée"
--[[Translation missing --]]
L["Custom Condition Code"] = "Custom Condition Code"
L["Custom Configuration"] = "Configuration personnalisée"
--[[Translation missing --]]
L["Custom Fade Animation"] = "Custom Fade Animation"
L["Custom Function"] = "Fonction personnalisée"
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
L["Damage"] = "Dégâts"
L["Damage Absorb"] = "Absorption des dégâts"
L["Damage Shield"] = "Bouclier de dégâts"
L["Damage Shield Missed"] = "Bouclier de dégâts raté"
L["Damage Split"] = "Répartition des dégâts"
L["DBM Announce"] = "Annonce DBM"
--[[Translation missing --]]
L["DBM Stage"] = "DBM Stage"
L["DBM Timer"] = "Temps DBM"
--[[Translation missing --]]
L["Dead"] = "Dead"
L["Debuff"] = "Affaiblissement"
--[[Translation missing --]]
L["Debuff Class"] = "Debuff Class"
--[[Translation missing --]]
L["Debuff Class Icon"] = "Debuff Class Icon"
L["Debuff Type"] = "Type d’affaiblissement"
--[[Translation missing --]]
L["Debug Log contains more than 1000 entries"] = "Debug Log contains more than 1000 entries"
--[[Translation missing --]]
L["Debug Logging enabled"] = "Debug Logging enabled"
--[[Translation missing --]]
L["Debug Logging enabled for '%s'"] = "Debug Logging enabled for '%s'"
--[[Translation missing --]]
L["Defensive Stats"] = "Defensive Stats"
L["Deflect"] = "Déviation"
--[[Translation missing --]]
L["Delve"] = "Delve"
L["Desaturate"] = "Désaturer"
L["Desaturate Background"] = "Désaturer l'Arrière-plan"
L["Desaturate Foreground"] = "Désaturer le Premier-plan"
L["Desaturate while on cooldown"] = "Désaturer pendant le temps de recharge"
L["Descending"] = "Décroissant"
L["Description"] = "Description"
L["Dest Raid Mark"] = "Marqueur de raid"
--[[Translation missing --]]
L["Destination Affiliation"] = "Destination Affiliation"
--[[Translation missing --]]
L["Destination GUID"] = "Destination GUID"
--[[Translation missing --]]
L["Destination Info"] = "Destination Info"
L["Destination Name"] = "Nom de destination"
--[[Translation missing --]]
L["Destination NPC Id"] = "Destination NPC Id"
--[[Translation missing --]]
L["Destination Object Type"] = "Destination Object Type"
--[[Translation missing --]]
L["Destination Reaction"] = "Destination Reaction"
L["Destination Unit"] = "Unité de destination"
--[[Translation missing --]]
L["Destination unit's raid mark index"] = "Destination unit's raid mark index"
--[[Translation missing --]]
L["Destination unit's raid mark texture"] = "Destination unit's raid mark texture"
--[[Translation missing --]]
L["Difficulty"] = "Difficulty"
L["Disable Spell Known Check"] = "Désactiver la vérification des sorts connus"
--[[Translation missing --]]
L["Disabled"] = "Disabled"
--[[Translation missing --]]
L["Disabled feature %q"] = "Disabled feature %q"
L["Disabled Spell Known Check"] = "Vérification des sorts connus désactivées"
L["Disease"] = "Maladie"
L["Dispel"] = "Dissipation"
L["Dispel Failed"] = "Dissipation échouée"
L["Dispel Type Icon"] = "Icône du type de dissipation"
L["Dispellable"] = "Dissipable"
L["Dispellable by the Group"] = "Dissipable par le groupe"
L["Display"] = "Affichage"
L["Distance"] = "Distance"
--[[Translation missing --]]
L["Do Not Disturb"] = "Do Not Disturb"
L["Dodge"] = "Esquive"
L["Dodge (%)"] = "Esquive (%)"
--[[Translation missing --]]
L["Down"] = "Bas"
--[[Translation missing --]]
L["Down, then Centered Horizontal"] = "Down, then Centered Horizontal"
L["Down, then Left"] = "Bas puis Gauche"
L["Down, then Right"] = "Bas puis Droite"
L["Dragonflight"] = "Dragonflight"
L["Drain"] = "Drain"
L["Dropdown Menu"] = "Menu Déroulant"
--[[Translation missing --]]
L["Dumping table"] = "Dumping table"
L["Dungeon (Heroic)"] = "Donjon (Héroïque)"
L["Dungeon (Mythic)"] = "Donjon (Mythique)"
--[[Translation missing --]]
L["Dungeon (Mythic+)"] = "Dungeon (Mythic+)"
L["Dungeon (Normal)"] = "Donjon (Normal)"
L["Dungeon (Timewalking)"] = "Donjon (Marcheurs du temps)"
L["Durability Damage"] = "Perte de durabilité"
L["Durability Damage All"] = "Perte de durabilité sur tout"
--[[Translation missing --]]
L["Duration"] = "Duration"
--[[Translation missing --]]
L["Duration Function"] = "Duration Function"
--[[Translation missing --]]
L["Duration Function (fallback state)"] = "Duration Function (fallback state)"
--[[Translation missing --]]
L["Ease In"] = "Ease In"
L["Ease In and Out"] = "Faciliter l'entrée et la sortie"
--[[Translation missing --]]
L["Ease Out"] = "Ease Out"
L["Ebonroc"] = "Rochébène"
L["Edge"] = "Marge"
--[[Translation missing --]]
L["Edge of Madness"] = "Edge of Madness"
--[[Translation missing --]]
L["Effective Spell Id"] = "Effective Spell Id"
L["Elide"] = "Elider"
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
L["Empty"] = "Vide"
--[[Translation missing --]]
L["Enabled feature %q"] = "Enabled feature %q"
--[[Translation missing --]]
L["Enables (incorrect) round down of seconds, which was the previous default behavior."] = "Enables (incorrect) round down of seconds, which was the previous default behavior."
L["Enchant Applied"] = "Enchantement appliqué"
L["Enchant Found"] = "Enchantement présent"
--[[Translation missing --]]
L["Enchant ID"] = "Enchant ID"
L["Enchant Missing"] = "Enchantement manquant"
L["Enchant Name or ID"] = "Nom ou ID de l'Enchantement"
L["Enchant Removed"] = "Enchantement retiré"
L["Enchanted"] = "Enchanté"
L["Encounter ID(s)"] = "ID de la Rencontre"
L["Energize"] = "Gain d'énergie"
L["Enrage"] = "Enrager"
--[[Translation missing --]]
L["Enter a name or a spellId"] = "Enter a name or a spellId"
L["Entering"] = "Entrer"
L["Entering/Leaving Combat"] = "Entrer / sortir de combat"
--[[Translation missing --]]
L["Entering/Leaving Encounter"] = "Entering/Leaving Encounter"
--[[Translation missing --]]
L["Entry Order"] = "Entry Order"
L["Environment Type"] = "Type d'environnement"
L["Environmental"] = "Environnement"
L["Equipment"] = "Équipement"
L["Equipment Durability"] = "Durabilité de l'équipement"
L["Equipment Slot"] = "Emplacement d'équipement"
L["Equipped"] = "Équipé "
--[[Translation missing --]]
L["Error"] = "Erreur"
--[[Translation missing --]]
L[ [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Error decoding."] = "Error decoding."
--[[Translation missing --]]
L["Error decompressing"] = "Error decompressing"
--[[Translation missing --]]
L["Error decompressing. This doesn't look like a WeakAuras import."] = "Error decompressing. This doesn't look like a WeakAuras import."
--[[Translation missing --]]
L["Error deserializing"] = "Error deserializing"
L["Error Frame"] = "Fenêtre d'erreur"
--[[Translation missing --]]
L["ERROR in '%s' unknown or incompatible sub element type '%s'"] = "ERROR in '%s' unknown or incompatible sub element type '%s'"
--[[Translation missing --]]
L["Error in Aura '%s'"] = "Error in Aura '%s'"
L["Error in custom code: %s"] = "Erreur dans le code personnalisé : %s"
L["Expertise (%)"] = "Expertise (%)"
L["External Defensive"] = "Défensif externe"
L["Free Slots"] = "Emplacements libres"
L["Hide GCD Text"] = "Masquer le texte du temps de recharge global"
L["Hide when target changes"] = "Masquer au changement de cible"
L["Hide when target dies"] = "Masquer à la mort de la cible"
L["Hides the countdown numbers while only the global cooldown runs. The swipe still shows it."] = "Masque les chiffres du compte à rebours tant que seul le temps de recharge global tourne. Le balayage l'affiche toujours."
L["Hides the timer when you change or clear your target. Targeting the first mob again does not bring the timer back."] = "Masque le minuteur quand tu changes de cible ou que tu n'en as plus. Recibler le premier monstre ne fait pas revenir le minuteur."
L["Hides the timer when your current target dies. The death of a mob that is no longer your target is not seen. If you change target and the new target dies, the timer is hidden too."] = "Masque le minuteur quand ta cible actuelle meurt. La mort d'un monstre qui n'est plus ta cible n'est pas vue. Si tu changes de cible et que la nouvelle cible meurt, le minuteur est masqué aussi."
L["Ignore out of checking range"] = "Ignorer hors de la plage de vérification"
L["Ignores group members the game has not loaded (UnitIsVisible), about 100 yards away. Updated when a member comes in or goes out of that range."] = "Ignore les membres du groupe que le jeu n'a pas chargés (UnitIsVisible), à environ 100 mètres. Mis à jour quand un membre entre dans cette portée ou en sort."
L["Include Specialty Bags"] = "Inclure les sacs spécialisés"
L["Incomplete expression"] = "Expression incomplète"
L["Install %s HUD"] = "Installer le HUD %s"
L["Later"] = "Plus tard"
L["Lowest Item Durability (%)"] = "Durabilité de l'objet la plus basse (%)"
L["Matches the talent tree where you have spent the most points. Two trees with the same points both match. No match without any talent point. Select multiple specializations to match any of them. Feral Combat includes both cat and bear builds. Your assigned Role is checked separately."] = "Correspond à l'arbre de talents où vous avez dépensé le plus de points. Deux arbres avec le même nombre de points correspondent tous les deux. Aucune correspondance sans point de talent. Sélectionnez plusieurs spécialisations pour correspondre à l'une d'elles. Combat farouche inclut les builds chat et ours. Votre rôle assigné est vérifié séparément."
L["Missing closing parenthesis"] = "Parenthèse fermante manquante"
L["On Global Cooldown"] = "Pendant le temps de recharge global"
L["Only with Show Global Cooldown enabled. Set Hide Cooldown Text on it to hide the countdown during the global cooldown."] = "Uniquement si Afficher le Temps de Recharge Global est activé. Activez Masquer le texte du minuteur dessus pour masquer le décompte pendant le temps de recharge global."
L["Out of Range"] = "Hors de portée"
L["Overall Durability (%)"] = "Durabilité globale (%)"
L["Ranged Attack Power"] = "Puissance d'attaque à distance"
L["Ranged Haste (%)"] = "Hâte à distance (%)"
L["Game Hides Combat Data"] = "Le jeu cache les données de combat"
L["Show at or above the value instead"] = "Afficher plutôt à partir de la valeur"
L["Show only below (%)"] = "Afficher seulement en dessous de (%)"
L["Show while the unit is out of the spell's range instead."] = "Afficher plutôt lorsque l'unité est hors de portée du sort."
L["Shown on Raid Frames in Combat"] = "Affiché sur les cadres de raid en combat"
L["Spell Haste (%)"] = "Hâte des sorts (%)"
L["Target In Range"] = "Cible à portée"
L["The class pack changed in this version. Update it to get the new auras: your positions and options are kept."] = "Le pack de classe a changé dans cette version. Mets-le à jour pour avoir les nouvelles auras : tes positions et options sont gardées."
L["The game desaturates the icon while the spell is on cooldown, global cooldown excluded. Works in combat. Icon and Progress Bar icons only."] = "Le jeu désature l'icône pendant le temps de recharge du sort, hors temps de recharge global. Marche en combat. Icônes des régions Icône et Barre de progression seulement."
L["The game hides combat data from addons: in combat, boss encounters and PvP matches."] = "Le jeu masque les données de combat aux addons : en combat, lors des rencontres de boss et des matchs JcJ."
L["The game hides the aura while the percent is at or above this value, in combat too. The aura stays active: sounds, glows and other actions still run. Replaces the alpha of the aura: alpha conditions are not kept, and an alpha animation shows the aura while it runs. With several triggers using this option, only one is used."] = "Le jeu masque l'aura tant que le pourcentage est supérieur ou égal à cette valeur, en combat aussi. L'aura reste active : les sons, les brillances et les autres actions continuent. Remplace l'opacité de l'aura : les conditions d'opacité ne sont pas gardées, et une animation d'opacité affiche l'aura pendant qu'elle tourne. Si plusieurs déclencheurs utilisent cette option, un seul est pris en compte."
L["The game hides the aura while the percent is at or above this value, in combat too. With \"Show at or above the value instead\", it hides the aura while the percent is below this value. The aura stays active: sounds, glows and other actions still run. Replaces the alpha of the aura: alpha conditions are not kept, and an alpha animation shows the aura while it runs. With several triggers using this option, only one is used."] = "Le jeu masque l'aura tant que le pourcentage est supérieur ou égal à cette valeur, en combat aussi. Avec « Afficher plutôt à partir de la valeur », il masque l'aura tant que le pourcentage est inférieur à cette valeur. L'aura reste active : les sons, les brillances et les autres actions continuent. Remplace l'opacité de l'aura : les conditions d'opacité ne sont pas gardées, et une animation d'opacité affiche l'aura pendant qu'elle tourne. Si plusieurs déclencheurs utilisent cette option, un seul est pris en compte."
L["Total Carried"] = "Total porté"
L["Tracking"] = "Pistage"
L["Tracking Spell"] = "Sort de pistage"
L["Trigger %s does not exist"] = "Le déclencheur %s n'existe pas"
L["Trigger Expression"] = "Expression de déclencheurs"
L["Unexpected \"%s\""] = "\"%s\" inattendu"
L["Update %s HUD"] = "Mettre à jour le HUD %s"
L["Musca Auras is still loading. Try again in a few seconds."] = "Musca Auras est en cours de chargement. Réessaie dans quelques secondes."
L["Replace the 5 folders WeakAuras, WeakAurasArchive, WeakAurasModelPaths, WeakAurasOptions and WeakAurasTemplates with the same version, then restart the game."] = "Remplace les 5 dossiers WeakAuras, WeakAurasArchive, WeakAurasModelPaths, WeakAurasOptions et WeakAurasTemplates par la même version, puis relance le jeu."
L["The class pack can't be imported during combat. The import will start when combat ends."] = "Le pack de classe ne peut pas être importé en combat. L'import démarrera à la fin du combat."
L["Compatibility with WoW Forever:"] = "Compatibilité avec WoW Forever :"
L["%s: uses the combat log, which addons cannot read on WoW Forever. Use a custom trigger on the UNIT_COMBAT:player event instead."] = "%s : utilise le journal de combat, illisible par les addons sur WoW Forever. Utilise plutôt un déclencheur personnalisé sur l'événement UNIT_COMBAT:player."
L["%s: tracks an aura that the game hides in combat. Change the trigger type to Aura (Modern)."] = "%s : suit une aura que le jeu cache en combat. Passez le type de déclencheur en Aura (moderne)."
L["%s: %s may not work in combat, because the game hides the data."] = "%s : %s peut ne pas marcher en combat, car le jeu cache les données."
L["%s: casts of units other than the player or the pet cannot be read, in or out of combat."] = "%s : les sorts lancés par une autre unité que le joueur ou son familier sont illisibles, en combat comme hors combat."
L["%s calls %s, which does not exist on WoW Forever."] = "%s appelle %s, qui n'existe pas sur WoW Forever."
L["%s calls %s, which does not exist on WoW Forever. Musca-Auras replaces it."] = "%s appelle %s, qui n'existe pas sur WoW Forever. Musca-Auras la remplace."
L["Aura (Modern)"] = "Aura (moderne)"
L["Secret Auras"] = "Auras secrètes"
L["%s (+%d more)"] = "%s (+%d de plus)"
L["%s, remaining %s %s s"] = "%s, reste %s %s s"
L["Spell IDs (All Ranks)"] = "ID de sorts (tous les rangs)"
L["Exact Spell IDs"] = "ID exacts des sorts"
L["WoW Forever runs on the modern game engine (12.x). The game limits what addons can do, so many Classic auras need changes."] = "WoW Forever tourne sur le moteur de jeu moderne (12.x). Le jeu limite ce que les addons peuvent faire, donc beaucoup d'auras Classic demandent des changements."
L["|cffffcc00Not possible or limited:|r"] = "|cffffcc00Impossible ou limité :|r"
L["- Combat log triggers never fire: the game closes the combat log to addons."] = "- Les déclencheurs du journal de combat ne se déclenchent jamais : le jeu ferme le journal de combat aux addons."
L["- During combat, the game can hide combat data (buffs, casts, cooldowns) from addons. Buff and debuff triggers then keep their last state and update when combat ends."] = "- Pendant le combat, le jeu peut cacher aux addons les données de combat (buffs, incantations, temps de recharge). Les déclencheurs de buffs et debuffs gardent alors leur dernier état et se mettent à jour à la fin du combat."
L["- The swing timer does not reset on melee hits."] = "- Le minuteur de mêlée ne se remet pas à zéro lors des coups de mêlée."
L["- Talent load options work for your own specialization only."] = "- Les options de chargement par talents ne marchent que pour votre propre spécialisation."
L["- Spell names work in the spell lists of Aura (Modern) triggers. Elsewhere, type spell IDs."] = "- Les noms de sorts marchent dans les listes de sorts des déclencheurs Aura (moderne). Ailleurs, tapez les ID de sorts."
L["- The \"Chat Message\" action may not send in instances or during combat."] = "- L'action « Message dans le chat » peut ne pas partir en instance ou pendant le combat."
L["Click |cffffd100Guide|r below, or the Guide button in |cffffd100/wa|r, to learn everything about WeakAuras here."] = "Cliquez sur |cffffd100Guide|r ci-dessous, ou sur le bouton Guide dans |cffffd100/wa|r, pour tout apprendre sur WeakAuras ici."
L["Report other problems on the addon page."] = "Signalez les autres problèmes sur la page de l'addon."
L["Guide"] = "Guide"
L["In Aura (Modern) conditions, kind and dispel checks only accept == (is) and ~= (is not)."] = "Dans les conditions Aura (moderne), les tests de type et de dissipation n'acceptent que == (est) et ~= (n'est pas)."
L["In Aura (Modern) conditions, time checks only accept < (less than) and >= (at least)."] = "Dans les conditions Aura (moderne), les tests de durée n'acceptent que < (inférieur à) et >= (au moins)."
L["This sub element is not supported by Aura (Modern). Use Text, Texture or Glow."] = "Ce sous-élément n'est pas pris en charge par Aura (moderne). Utilisez Texte, Texture ou Brillance."
L["Aura (Modern) supports one text element for each of %p, %s and %n. Remove the duplicate or turn off Show Text."] = "Aura (moderne) accepte un seul élément de texte pour chacun de %p, %s et %n. Retirez le doublon ou désactivez Afficher le texte."
L["10. Coming from ForeverAuras"] = "10. Venir de ForeverAuras"
L["Export your auras from ForeverAuras, then paste the strings in the WeakAuras import window. Groups work too.\nMusca Auras converts them on import, and lists in the chat what it could not convert.\n\nWhat each one becomes:\n\n- Cooldown Manager trigger, cooldown: Cooldown trigger (spell ID, or name if ForeverAuras used names)\n- Cooldown Manager trigger, buff: Aura trigger (your buffs, or your debuffs on the target)\n- Cooldown Manager trigger, item: Item cooldown trigger\n- Aura (Blizzard) trigger: Aura trigger with Game Categories (sorting removed). Game Categories shows nothing at the moment.\n- Dispel type icon: Dispel Type Icon sub element\n- Dispel type border: Border colored by dispel type\n- Swing Timer, Ammo: same triggers (Ammo: the item list now filters the equipped ammo)\n- Role, Tracking, Equipment Durability, Bag Space: same triggers (Tracking: by spell ID only, no \"always\" mode)\n\nNot converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one.\nDo not run both addons at the same time."] = "Exportez vos auras depuis ForeverAuras, puis collez les chaînes dans la fenêtre d'import de WeakAuras. Les groupes marchent aussi.\nMusca Auras les convertit à l'import et liste dans le chat ce qu'il n'a pas pu convertir.\n\nCe que devient chaque élément :\n\n- Déclencheur Cooldown Manager, recharge : déclencheur Recharge (ID du sort, ou nom si ForeverAuras utilisait des noms)\n- Déclencheur Cooldown Manager, amélioration : déclencheur Aura (vos améliorations, ou vos affaiblissements sur la cible)\n- Déclencheur Cooldown Manager, objet : déclencheur Recharge d'objet\n- Déclencheur Aura (Blizzard) : déclencheur Aura avec Catégories du jeu (tri retiré). Catégories du jeu n'affiche rien pour le moment.\n- Icône de type de dispel : sous-élément Icône de type de dispel\n- Bordure de type de dispel : bordure colorée selon le type de dispel\n- Minuteur de mêlée, Munitions : mêmes déclencheurs (Munitions : la liste d'objets filtre désormais les munitions équipées)\n- Rôle, Pistage, Durabilité de l'équipement, Espace des sacs : mêmes déclencheurs (Pistage : par ID de sort uniquement, pas de mode « toujours »)\n\nNon converti : les déclencheurs TimelineParser (ils demandent l'addon ExRT_Reminder et une chronologie de boss, que WoW Forever n'affiche pas). Un déclencheur de recharge Cooldown Manager avec plusieurs sorts garde le premier.\nNe lancez pas les deux addons en même temps."
L["This client cannot draw circular Progress Textures this way."] = "Ce client ne peut pas dessiner de textures de progression circulaires de cette façon."
L["Animations are not available on an Aura (Modern) trigger."] = "Les animations ne sont pas disponibles sur un déclencheur Aura (moderne)."
L["Aura (Modern) sounds accept sound files only, not Sound Kit IDs or Stop Sound."] = "Les sons d'Aura (moderne) acceptent seulement des fichiers son, pas les ID de Sound Kit ni Arrêter le son."
L["Only Chat Message, Play Sound and Hide Glows can run in On Show/On Hide for an Aura (Modern) trigger. Custom Init is available."] = "Seuls Message dans le chat, Jouer un son et Cacher les lueurs peuvent s'exécuter à l'affichage ou au masquage d'un déclencheur Aura (moderne). L'init personnalisée reste disponible."
L["This client does not provide aura sound registration."] = "Ce client ne permet pas d'enregistrer des sons d'aura."
L["Display > Aura (Modern) Settings changes will apply when the game stops hiding combat data."] = "Les changements de Affichage > Paramètres d'Aura (moderne) s'appliqueront quand le jeu cessera de cacher les données de combat."
L["|cffffd100Everything you need to learn WeakAuras on WoW Forever:|r how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import.\n\nOpen this guide again with the |cffffd100Guide|r button at the top of the |cffffd100/wa|r window, or with |cffffd100/wa tutorial|r."] = "|cffffd100Tout ce qu'il faut pour apprendre WeakAuras sur WoW Forever :|r comment fonctionne une aura, ce qui a changé en combat, ce qui marche et ce qui ne marche pas, des recettes pas à pas et des auras prêtes à importer.\n\nRouvrez ce guide avec le bouton |cffffd100Guide|r en haut de la fenêtre |cffffd100/wa|r, ou avec |cffffd100/wa tutorial|r."
L["How WeakAuras works on WoW Forever, and how to build auras that keep working in combat.\n\nWoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data from addons. This guide explains what that changes and gives step-by-step recipes.\n\nSection 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game."] = "Comment fonctionne WeakAuras sur WoW Forever, et comment créer des auras qui continuent de marcher en combat.\n\nWoW Forever ressemble à Classic, mais tourne sur le moteur de jeu moderne 12.1. Ce moteur cache la plupart des données de combat aux addons. Ce guide explique ce que cela change et donne des recettes pas à pas.\n\nLa section 3 dit ce qui a été testé en jeu sur Forever, et ce qui ne l'a pas été. En cas de doute, testez en jeu."
L["1. WeakAuras in 2 minutes"] = "1. WeakAuras en 2 minutes"
L["An aura is something WeakAuras shows on your screen: an icon, a bar, a text or a texture. Every aura has 4 parts, one per tab in the options:\n\n- |cffffd100Display|r: What it looks like: icon, size, colors, text.\n- |cffffd100Trigger|r: When it shows: a buff, a cooldown, a cast, an item count, a game event.\n- |cffffd100Conditions|r: What changes while it is shown, for example red when less than 3 seconds remain.\n- |cffffd100Load|r: When WeakAuras even looks at it: class, in combat, in a group, zone.\n\nThe |cffffd100Actions|r tab adds a sound, a chat message or a glow when the aura shows or hides.\n\nBasic steps:\n\n1. Type |cff99ccff/wa|r.\n2. Click |cffffd100New|r, then choose a display type: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r or |cffffd100Texture|r.\n3. Fill in the |cffffd100Trigger|r tab.\n4. Set the |cffffd100Load|r tab, so the aura only loads when it is useful.\n5. Close the options and test."] = "Une aura est ce que WeakAuras affiche à l'écran : une icône, une barre, un texte ou une texture. Chaque aura a 4 parties, une par onglet des options :\n\n- |cffffd100Affichage|r : son apparence : icône, taille, couleurs, texte.\n- |cffffd100Déclencheur|r : quand elle s'affiche : un buff, un temps de recharge, une incantation, un nombre d'objets, un évènement du jeu.\n- |cffffd100Conditions|r : ce qui change pendant qu'elle est affichée, par exemple rouge quand il reste moins de 3 secondes.\n- |cffffd100Chargement|r : quand WeakAuras la prend en compte : classe, en combat, en groupe, zone.\n\nL'onglet |cffffd100Actions|r ajoute un son, un message dans le chat ou une lueur quand l'aura s'affiche ou se cache.\n\nÉtapes de base :\n\n1. Tapez |cff99ccff/wa|r.\n2. Cliquez sur |cffffd100Nouveau|r, puis choisissez un type d'affichage : |cffffd100Icône|r, |cffffd100Barre de progression|r, |cffffd100Texte|r ou |cffffd100Texture|r.\n3. Remplissez l'onglet |cffffd100Déclencheur|r.\n4. Réglez l'onglet |cffffd100Chargement|r, pour que l'aura ne soit chargée que quand elle est utile.\n5. Fermez les options et testez."
L["2. What changed on Forever"] = "2. Ce qui a changé sur Forever"
L["Secret values"] = "Valeurs cachées"
L["During combat, boss encounters and PvP matches, the game gives addons \"secret\" values: WeakAuras receives the data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.\n\nWhat that means for your auras, tested in game on Forever unless marked otherwise:\n\n- |cffffd100The game draws what WeakAuras cannot read.|r Cooldown swipes and numbers, timer bars, and health or power bars keep moving in combat. A text made only of |cff99ccff%p|r and |cff99ccff%t|r (for example |cff99ccff%p|r or |cff99ccff%p / %t|r) is drawn by the game too, as a raw number.\n- |cffffd100Buffs and debuffs are refused to addons in combat.|r An aura that was showing before the pull keeps counting down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.\n- |cffffd100Your own recast restarts the timer.|r When you cast again a buff that you put on yourself, the timer of an Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else. A recast by someone else is not seen.\n- |cffffd100A buff or debuff applied for the first time in combat|r is only seen when combat ends.\n- |cffffd100Logic on secret data keeps its last state.|r A condition such as \"Health < 50%\" keeps the state it had when combat started, then updates when combat ends. The health of a target that is not a player is hidden by the game even out of combat: such a condition on the Target unit never changes. Use \"Show only below (%)\" on the Health trigger instead."] = "Pendant les combats, les rencontres de boss et les matchs JcJ, le jeu cache certaines valeurs aux addons : WeakAuras reçoit la donnée mais ne peut ni la lire, ni la comparer, ni calculer avec. Hors combat, presque tout marche comme avant.\n\nCe que cela veut dire pour vos auras, testé en jeu sur Forever sauf mention contraire :\n\n- |cffffd100Le jeu dessine ce que WeakAuras ne peut pas lire.|r Les balayages et les chiffres de temps de recharge, les barres de minuteur, et les barres de vie ou de puissance continuent de bouger en combat. Un texte fait uniquement de |cff99ccff%p|r et |cff99ccff%t|r (par exemple |cff99ccff%p|r ou |cff99ccff%p / %t|r) est lui aussi dessiné par le jeu, comme un nombre brut.\n- |cffffd100Les buffs et debuffs sont refusés aux addons en combat.|r Une aura qui s'affichait avant le pull continue de décompter depuis son dernier temps connu. Ses cumuls restent figés. Tout est relu à la fin du combat.\n- |cffffd100Votre propre relance remet le minuteur à zéro.|r Quand vous relancez un buff que vous vous êtes posé, le minuteur d'un déclencheur Aura sur l'unité Joueur repart de sa dernière durée connue, même si ce sort est allé sur quelqu'un d'autre. La relance par quelqu'un d'autre n'est pas vue.\n- |cffffd100Un buff ou debuff appliqué pour la première fois en combat|r n'est vu qu'à la fin du combat.\n- |cffffd100Une logique qui porte sur une donnée cachée garde son dernier état.|r Une condition comme « Santé < 50% » garde l'état qu'elle avait au début du combat, puis se met à jour à la fin du combat. La santé d'une cible qui n'est pas un joueur est cachée par le jeu, même hors combat : une telle condition sur l'unité Cible ne change jamais. Utilisez « Afficher seulement en dessous de (%) » sur le déclencheur Vie à la place."
L["The combat log is closed"] = "Le journal de combat est fermé"
L["Triggers that use the combat log (|cff99ccffCLEU|r, \"Combat Log\") never fire. For damage taken, use the event |cff99ccffUNIT_COMBAT:player|r."] = "Les déclencheurs qui utilisent le journal de combat (|cff99ccffCLEU|r, « Journal de combat ») ne se déclenchent jamais. Pour les dégâts subis, utilisez l'évènement |cff99ccffUNIT_COMBAT:player|r."
L["Other changes"] = "Autres changements"
L["- |cffffd100Spells by name or ID.|r In the spell lists of an Aura (Modern) trigger, type a spell name in the game language: it becomes the IDs of all its ranks. Elsewhere, name search may not find spells: type the spell ID. Get the ID of your rank out of combat: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic spells have one ID per rank.\n- |cffffd100Talent load options|r list the talents of your own specialization only. Select it alone in the |cffffd100Class and Specialization|r load option first.\n- |cffffd100Chat Message action|r can be blocked during encounters and PvP matches.\n- |cffffd100Old functions in custom code|r no longer exist (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzard Cooldown Manager.|r |cff99ccff/wa cdm|r shows or hides it, out of combat. On the Forever beta it is not enabled for every class: for some classes it has no spell and no buff, and the \"From the Cooldown Manager\" lists of the Cooldown and Aura triggers are empty."] = "- |cffffd100Sorts par nom ou par ID.|r Dans les listes de sorts d'un déclencheur Aura (moderne), tapez un nom de sort dans la langue du jeu : il devient les ID de tous ses rangs. Ailleurs, la recherche par nom peut ne pas trouver les sorts : tapez l'ID du sort. Relevez l'ID de votre rang hors combat : |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Les sorts Classic ont un ID par rang.\n- |cffffd100Les options de chargement par talents|r ne listent que les talents de votre propre spécialisation. Sélectionnez-la d'abord seule dans l'option de chargement |cffffd100Classe et spécialisation|r.\n- |cffffd100L'action Message dans le chat|r peut être bloquée pendant les rencontres et les matchs JcJ.\n- |cffffd100Les anciennes fonctions dans le code personnalisé|r n'existent plus (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Utilisez |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Gestionnaire de recharges de Blizzard.|r |cff99ccff/wa cdm|r l'affiche ou le cache, hors combat. Sur la bêta de Forever, il n'est pas activé pour toutes les classes : pour certaines, il n'a ni sort ni buff, et les listes « Depuis le gestionnaire de recharges » des déclencheurs Recharge et Aura sont vides."
L["3. What you can use"] = "3. Ce que vous pouvez utiliser"
L["|cffffd100Tested in game, works in combat:|r\n\n- Spell cooldowns: icon swipe and number. With |cffffd100Show Global Cooldown|r, the \"On Global Cooldown\" condition can hide the number during the global cooldown.\n- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.\n- Health bar of your target and power bar of yourself, with a |cff99ccff%p / %t|r text.\n- Swing timer, main hand.\n- Your own casts: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (see the recipes below).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Tested in game:|r\n\n- Temporary weapon enchants (poison, oil, sharpening stone), both hands.\n- |cffffd100Elapsed Time|r filter of the Aura trigger.\n- Bag Space trigger.\n- Role trigger (role chosen in the group finder).\n- |cff99ccff/wa cdm|r, and the \"From the Cooldown Manager\" lists, for the classes that have it.\n\n|cffffd100Works, with limits:|r\n\n- Stacks stay frozen in combat.\n- Conditions and filters on percentages, stacks or remaining time use the value from before combat.\n- A filter checked in the trigger itself (for example \"Health (%) < 50\") freezes the trigger in combat instead of hiding the aura.\n\n|cffffd100Not tested in game yet:|r\n\n- Swing timer off hand, ranged and wand, \"Target In Range\" option.\n- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.\n- Border and icon colored by dispel type.\n- Aura triggers in party or raid mode, glows, range conditions.\n- Encounter start and end: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Does not work:|r\n\n- Aura trigger filtered by |cffffd100Game Categories|r (crowd control, cast by me...): nothing shows at the moment.\n- Other players' casts.\n- Enemy names and IDs in instances.\n- Mana or energy tick timer in combat.\n- Combat log triggers."] = "|cffffd100Testé en jeu, marche en combat :|r\n\n- Temps de recharge des sorts : balayage de l'icône et chiffre. Avec |cffffd100Afficher le temps de recharge global|r, la condition « Sur temps de recharge global » peut cacher le chiffre pendant le temps de recharge global.\n- Buffs sur vous-même connus avant le combat : icône et minuteur. Votre propre relance remet le minuteur à zéro.\n- Barre de vie de votre cible et barre de puissance de vous-même, avec un texte |cff99ccff%p / %t|r.\n- Minuteur de mêlée, main droite.\n- Vos propres incantations : |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (voir les recettes plus bas).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Testé en jeu :|r\n\n- Enchantements temporaires d'arme (poison, huile, pierre à aiguiser), les deux mains.\n- Filtre |cffffd100Temps écoulé|r du déclencheur Aura.\n- Déclencheur Espace dans les sacs.\n- Déclencheur Rôle (rôle choisi dans la recherche de groupe).\n- |cff99ccff/wa cdm|r, et les listes « Depuis le gestionnaire de recharges », pour les classes qui l'ont.\n\n|cffffd100Marche, avec des limites :|r\n\n- Les cumuls restent figés en combat.\n- Les conditions et filtres sur des pourcentages, des cumuls ou un temps restant utilisent la valeur d'avant le combat.\n- Un filtre vérifié dans le déclencheur lui-même (par exemple « Santé (%) < 50 ») fige le déclencheur en combat au lieu de cacher l'aura.\n\n|cffffd100Pas encore testé en jeu :|r\n\n- Minuteur de mêlée main gauche, distance et baguette, option « Cible à portée ».\n- Déclencheur Munitions, Durabilité de l'équipement, Pistage, option de chargement par difficulté d'instance.\n- Bordure et icône colorées selon le type de dissipation.\n- Déclencheurs Aura en mode groupe ou raid, lueurs, conditions de portée.\n- Début et fin de rencontre : |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Ne marche pas :|r\n\n- Déclencheur Aura filtré par |cffffd100Catégories du jeu|r (contrôle de foule, lancé par moi...) : rien ne s'affiche pour le moment.\n- Les incantations des autres joueurs.\n- Les noms et ID des ennemis en instance.\n- Minuteur de régénération de mana ou d'énergie en combat.\n- Les déclencheurs du journal de combat."
L["4. New way of thinking: prepare or deduce"] = "4. Une nouvelle façon de penser : préparer ou déduire"
L["Stop reading the combat. |cffffd100Prepare|r before the pull, or |cffffd100deduce|r from what you do.\n\n- Debuff on target, show its timer: You cast the DoT, start a fixed timer\n- Buff missing in combat, alert: Check buffs and consumables before the pull\n- Boss casts X, alert: Boss timeline from the pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown ready, flash: Let the action bar show the cooldown\n- Low mana, alert: Power trigger, \"Show only below (%)\" option\n\nFor debuffs on enemies, the Blizzard nameplates and target frame can show them (\"only my debuffs\"). Use them for what only the game can see."] = "Arrêtez de lire le combat. |cffffd100Préparez|r avant le pull, ou |cffffd100déduisez|r de ce que vous faites.\n\n- Debuff sur la cible, afficher son minuteur : vous lancez le DoT, démarrez un minuteur fixe\n- Buff manquant en combat, alerte : vérifiez buffs et consommables avant le pull\n- Le boss lance X, alerte : chronologie du boss depuis le pull (|cff99ccffENCOUNTER_START|r)\n- Recharge prête, clignotement : laissez la barre d'action montrer la recharge\n- Mana basse, alerte : déclencheur Puissance, option « Afficher seulement en dessous de (%) »\n\nPour les debuffs sur les ennemis, les barres de vie Blizzard et le cadre de cible peuvent les afficher (« seulement mes debuffs »). Utilisez-les pour ce que seul le jeu peut voir."
L["5. Recipe: DoT or buff timer from your cast"] = "5. Recette : minuteur de DoT ou de buff depuis votre incantation"
L["Not tested in game yet. No custom code. Example: Corruption on your target.\n\n1. Out of combat, get the ID of your rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Note the |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (or |cffffd100Progress Bar|r).\n3. |cffffd100Trigger|r tab:\n    - Type: |cffffd100Other Events|r, then |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: your spell ID (for example 11672)\n    - |cffffd100Hide when target dies|r: checked\n    - |cffffd100Hide After|r, Duration: the spell duration from its tooltip (Corruption: 18)\n4. Test on any mob.\n\nThe trigger gives the icon of the spell.\n\nLimits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted or dispelled. It follows one target only.\n\n|cffffd100Hide when target dies|r only sees the death of your current target. If you change target and the mob with your DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff on yourself, leave the box unchecked.\n\n|cffffd100Hide when target changes|r hides the timer as soon as you target another mob or clear your target. A target change during a cast is not seen. Targeting the first mob again does not bring the timer back.\n\nA missed or resisted spell still starts the timer: the game reports the cast as succeeded, and the combat log that tells misses is not available to addons on WoW Forever.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Pas encore testé en jeu. Aucun code personnalisé. Exemple : Corruption sur votre cible.\n\n1. Hors combat, relevez l'ID de votre rang : |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Notez le |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100Nouveau|r, |cffffd100Icône|r (ou |cffffd100Barre de progression|r).\n3. Onglet |cffffd100Déclencheur|r :\n    - Type : |cffffd100Autres évènements|r, puis |cffffd100Sort lancé avec succès|r\n    - Unité lanceur : |cffffd100Joueur|r\n    - |cffffd100ID exact(s) du sort|r : l'ID de votre sort (par exemple 11672)\n    - |cffffd100Masquer à la mort de la cible|r : coché\n    - |cffffd100Masquer après|r, Durée : la durée du sort d'après son infobulle (Corruption : 18)\n4. Testez sur n'importe quel monstre.\n\nLe déclencheur donne l'icône du sort.\n\nLimites : une aura par sort. Relancer le sort remet le minuteur à zéro. L'aura ne sait pas si le sort a été résisté ou dissipé. Elle ne suit qu'une seule cible.\n\n|cffffd100Masquer à la mort de la cible|r ne voit que la mort de votre cible actuelle. Si vous changez de cible et que le monstre qui porte votre DoT meurt, le minuteur continue. Si vous changez de cible et que la nouvelle cible meurt, le minuteur est caché. Pour un buff sur vous-même, laissez la case décochée.\n\n|cffffd100Masquer au changement de cible|r cache le minuteur dès que vous ciblez un autre monstre ou que vous videz votre cible. Un changement de cible pendant une incantation n'est pas vu. Recibler le premier monstre ne ramène pas le minuteur.\n\nUn sort raté ou résisté démarre quand même le minuteur : le jeu signale l'incantation comme réussie, et le journal de combat qui indique les ratés n'est pas disponible pour les addons sur WoW Forever.\n\nExemple prêt à l'emploi pour Immolation rang 1 (ID de sort 348, 15 secondes). Cliquez sur le bouton d'import ci-dessous."
L["Import the DoT timer"] = "Importer le minuteur de DoT"
L["Variant: one timer per mob, on its nameplate"] = "Variante : un minuteur par monstre, sur sa barre de vie"
L["Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.\n\n|cffffd100Only with the default Blizzard nameplates.|r Addons that replace the nameplates (EllesmereUI, ElvUI, Plater, Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places. The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the WeakAuras side. With a nameplate addon, use the single timer above.\n\nEnemy nameplates must be shown (key |cffffd100V|r).\n\nHow it works:\n\n- The aura is a |cffffd100Dynamic Group|r with |cffffd100Group by Frame|r set to |cffffd100Nameplates|r, and one icon inside.\n- The icon uses a |cffffd100Trigger State Updater|r on |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- When you cast the spell, the code looks for the nameplate of your target: it tests |cff99ccffnameplate1|r to |cff99ccffnameplate40|r with |cff99ccffUnitIsUnit(token, \"target\")|r, which stays readable in combat. It starts a timer for that nameplate and stores the nameplate in the state (|cff99ccffunit = token|r), so the group puts the icon on it.\n- When a nameplate disappears (the mob died or went out of range), its timer is removed.\n\nLimits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does not know if the spell was resisted or dispelled.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Testé en jeu sur Forever. Chaque monstre sur lequel vous lancez le sort a sa propre icône et son propre minuteur, au-dessus de sa barre de vie.\n\n|cffffd100Uniquement avec les barres de vie Blizzard par défaut.|r Les addons qui remplacent les barres de vie (EllesmereUI, ElvUI, Plater, Kui, etc.) cachent la barre de vie Blizzard à laquelle cette aura s'accroche : les icônes ne s'affichent alors nulle part, ou à des endroits au hasard. Le jeu ne permet pas aux addons de mesurer les zones protégées des barres de vie ni de s'y accrocher, donc WeakAuras ne peut pas corriger cela. Avec un addon de barres de vie, utilisez le minuteur unique ci-dessus.\n\nLes barres de vie ennemies doivent être affichées (touche |cffffd100V|r).\n\nFonctionnement :\n\n- L'aura est un |cffffd100Groupe dynamique|r avec |cffffd100Grouper par cadre|r réglé sur |cffffd100Barres de vie|r, et une icône à l'intérieur.\n- L'icône utilise un |cffffd100Trigger State Updater|r sur |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- Quand vous lancez le sort, le code cherche la barre de vie de votre cible : il teste |cff99ccffnameplate1|r à |cff99ccffnameplate40|r avec |cff99ccffUnitIsUnit(token, \"target\")|r, qui reste lisible en combat. Il démarre un minuteur pour cette barre de vie et la range dans l'état (|cff99ccffunit = token|r), pour que le groupe y place l'icône.\n- Quand une barre de vie disparaît (le monstre est mort ou hors de portée), son minuteur est supprimé.\n\nLimites : un minuteur est perdu quand la barre de vie disparaît, par exemple quand vous vous éloignez du monstre. L'aura ne sait pas si le sort a été résisté ou dissipé.\n\nExemple prêt à l'emploi pour Immolation rang 1 (ID de sort 348, 15 secondes). Cliquez sur le bouton d'import ci-dessous."
L["Import the nameplate DoT timer"] = "Importer le minuteur de DoT sur barre de vie"
L["6. Recipe: pre-pull checklist"] = "6. Recette : liste de contrôle avant le pull"
L["The idea: one group of icons that shows what is missing, only out of combat and in a group.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Name it \"Pre-pull\".\n2. In the group, |cffffd100Load|r tab: |cffffd100In Combat|r unchecked twice (the box shows a cross = \"not in combat\"), |cffffd100In Group|r checked.\n3. Add one icon per check, inside the group.\n\n|cffffd100Missing buff|r (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):\n\n- Trigger type: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.\n- Show On: |cffffd100Aura(s) Missing|r\n\n|cffffd100Weapon enchant|r (poison, oil, stone): trigger |cffffd100Weapon Enchant|r, show when missing.\n\n|cffffd100Reagents and ammo|r (Soul Shards, arrows, Symbol of Kings...):\n\n- Trigger type: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: the item ID\n- Count: lower than the number you want, for example |cff99ccff< 5|r\n\nBecause the group only loads out of combat, secret data never matters here.\n\nReady-made example for a Warlock (tested in game on Forever). Click the import button below.\n\n- Fortitude: the buff is missing (every rank, Prayer of Fortitude included) (in a party or raid)\n- Mark of the Wild: the buff is missing (every rank, Gift of the Wild included) (in a party or raid)\n- Arcane Intellect: the buff is missing (every rank, Arcane Brilliance included) (in a party or raid)\n- Demon Skin / Armor: neither Demon Skin nor Demon Armor is active (Warlock, solo included)\n- Soul Shards: fewer than 3 Soul Shards (item 6265) in your bags (Warlock, solo included)\n\nNone of them loads in combat. Buffs are matched by spell ID, so the group works with any client language. The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it."] = "L'idée : un groupe d'icônes qui montre ce qui manque, seulement hors combat et en groupe.\n\n1. |cff99ccff/wa|r, |cffffd100Nouveau|r, |cffffd100Groupe dynamique|r. Nommez-le \"Pre-pull\".\n2. Dans le groupe, onglet |cffffd100Chargement|r : |cffffd100En combat|r décoché deux fois (la case affiche une croix = « pas en combat »), |cffffd100En groupe|r coché.\n3. Ajoutez une icône par vérification, à l'intérieur du groupe.\n\n|cffffd100Buff manquant|r (Mot de pouvoir : Robustesse, Marque du fauve, Intelligence des arcanes, Bénédictions, Épines, flasque, nourriture) :\n\n- Type de déclencheur : |cffffd100Aura|r\n- Unité : |cffffd100Joueur|r, Type : |cffffd100Buff|r\n- Nom ou ID de sort de l'aura : le buff. Pour les buffs à rangs, ajoutez chaque rang que vous acceptez.\n- Afficher sur : |cffffd100Aura(s) manquante(s)|r\n\n|cffffd100Enchantement d'arme|r (poison, huile, pierre) : déclencheur |cffffd100Enchantement d'arme|r, afficher quand il manque.\n\n|cffffd100Composants et munitions|r (fragments d'âme, flèches, symbole des rois...) :\n\n- Type de déclencheur : |cffffd100Objet|r, |cffffd100Nombre d'objets|r\n- Objet : l'ID de l'objet\n- Nombre : inférieur au nombre voulu, par exemple |cff99ccff< 5|r\n\nComme le groupe ne se charge que hors combat, les données cachées n'ont aucune importance ici.\n\nExemple prêt à l'emploi pour un Démoniste (testé en jeu sur Forever). Cliquez sur le bouton d'import ci-dessous.\n\n- Robustesse : le buff manque (tous les rangs, Prière de robustesse comprise) (en groupe ou en raid)\n- Marque du fauve : le buff manque (tous les rangs, Don du fauve compris) (en groupe ou en raid)\n- Intelligence des arcanes : le buff manque (tous les rangs, Illumination des arcanes comprise) (en groupe ou en raid)\n- Peau de démon / Armure démoniaque : ni Peau de démon ni Armure démoniaque n'est active (Démoniste, en solo compris)\n- Fragments d'âme : moins de 3 fragments d'âme (objet 6265) dans vos sacs (Démoniste, en solo compris)\n\nAucune ne se charge en combat. Les buffs sont reconnus par ID de sort, donc le groupe marche quelle que soit la langue du client. Les ID viennent des données de Classic 1.12 : si une icône reste affichée alors que vous avez le buff, signalez-le."
L["Import the pre-pull checklist"] = "Importer la liste de contrôle avant le pull"
L["7. Recipe: boss timeline"] = "7. Recette : chronologie de boss"
L["Not tested in game yet.\n\n1. Find the encounter ID. Out of combat, create a test aura on |cff99ccffENCOUNTER_START|r and print the ID, or search it on Wowhead.\n2. For each boss ability, create a |cffffd100Progress Bar|r:\n    - Trigger type: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: the time of the first cast after the pull, in seconds.\n3. |cffffd100Load|r tab: |cffffd100Encounter ID(s)|r = the same ID. The aura unloads when the encounter ends, so a wipe does not leave the bar on screen.\n4. If a readable event marks a new phase (an emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use it to restart the timers.\n\nAbilities based on boss health % or on random timings cannot be predicted."] = "Pas encore testé en jeu.\n\n1. Trouvez l'ID de la rencontre. Hors combat, créez une aura de test sur |cff99ccffENCOUNTER_START|r et affichez l'ID, ou cherchez-le sur Wowhead.\n2. Pour chaque capacité du boss, créez une |cffffd100Barre de progression|r :\n    - Type de déclencheur : |cffffd100Personnalisé|r, Type d'évènement : |cffffd100Évènement|r\n    - Évènement(s) : |cff99ccffENCOUNTER_START|r\n    - Déclencheur personnalisé :\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- remplacez par l'ID de rencontre du boss|r\n|cff99ccff    end|r\n\n    - Masquer : |cffffd100Temporisé|r, Durée : le délai de la première incantation après le pull, en secondes.\n3. Onglet |cffffd100Chargement|r : |cffffd100ID de rencontre|r = le même ID. L'aura se décharge à la fin de la rencontre, donc un wipe ne laisse pas la barre à l'écran.\n4. Si un évènement lisible marque une nouvelle phase (un emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), utilisez-le pour relancer les minuteurs.\n\nLes capacités basées sur le pourcentage de vie du boss ou sur des délais aléatoires ne peuvent pas être prévues."
L["8. Custom code"] = "8. Code personnalisé"
L["In custom code, check every value before you compare it or do math with it:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nWithout this check, the code stops with a Lua error in combat. Musca Auras does not show those errors: the aura just keeps its last state.\n\nIn combat, the |cff99ccffC_UnitAuras|r functions refuse addon code when auras are secret. They stop the code with \"Auras cannot be accessed when secret while tainted\" (tested in game): call them under |cff99ccffpcall|r, or only out of combat.\n\nFor health events, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r does not exist on Forever.\n\nOther tools:\n\n- |cff99ccff/dump <expression>|r shows the content of a value in chat, secret values included.\n- |cff99ccff/eventtrace|r shows events and which of their values are secret.\n- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend."] = "Dans le code personnalisé, vérifiez chaque valeur avant de la comparer ou de calculer avec :\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nSans cette vérification, le code s'arrête avec une erreur Lua en combat. Musca Auras n'affiche pas ces erreurs : l'aura garde simplement son dernier état.\n\nEn combat, les fonctions |cff99ccffC_UnitAuras|r refusent le code des addons quand les auras sont cachées. Elles arrêtent le code avec « Auras cannot be accessed when secret while tainted » (testé en jeu) : appelez-les sous |cff99ccffpcall|r, ou seulement hors combat.\n\nPour les évènements de santé, utilisez |cff99ccffUNIT_HEALTH|r : |cff99ccffUNIT_HEALTH_FREQUENT|r n'existe pas sur Forever.\n\nAutres outils :\n\n- |cff99ccff/dump <expression>|r affiche le contenu d'une valeur dans le chat, valeurs cachées comprises.\n- |cff99ccff/eventtrace|r montre les évènements et lesquelles de leurs valeurs sont cachées.\n- Il n'y a pas de mannequin d'entraînement sur Forever. Testez en vrai combat : attaquez un monstre ou provoquez un ami en duel."
L["9. Importing auras from Wago"] = "9. Importer des auras depuis Wago"
L["Most packs made for Classic Era, Season of Discovery or Retail need work:\n\n- replace combat log triggers (section 5 for DoTs, |cff99ccffUNIT_COMBAT:player|r for damage taken);\n- replace spell names by the spell IDs of your ranks;\n- rewrite custom code that calls old functions;\n- move buff and consumable checks out of combat (section 6).\n\nFound an aura that should work and does not? Report it: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"] = "La plupart des packs faits pour Classic Era, Saison de la Découverte ou Retail demandent du travail :\n\n- remplacer les déclencheurs du journal de combat (section 5 pour les DoT, |cff99ccffUNIT_COMBAT:player|r pour les dégâts subis) ;\n- remplacer les noms de sorts par les ID de vos rangs ;\n- réécrire le code personnalisé qui appelle d'anciennes fonctions ;\n- sortir du combat les vérifications de buffs et de consommables (section 6).\n\nVous avez trouvé une aura qui devrait marcher et ne marche pas ? Signalez-la : https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"
L["|cff00ccffMusca Auras|r - Guide"] = "|cff00ccffMusca Auras|r - Guide"
L["Looping Animation"] = "Animation en boucle"
L["Error not receiving display information from %s"] = "Erreur de non-réception d'informations d'affichage de %s"
L["Evade"] = "Evite"
L["Event"] = "Evènement"
L["Event(s)"] = "Evènement(s)"
L["Every Frame"] = "Chaque image"
L["Every Frame (High CPU usage)"] = "Chaque image (utilisation importante du CPU)"
L["Exact Spell ID(s)"] = "Correspondance exacte de l'ID du/des sort(s)"
--[[Translation missing --]]
L["Execute Conditions"] = "Execute Conditions"
L["Experience (%)"] = "Expérience (%)"
L["Extend Outside"] = "Étendre à l'extérieur"
L["Extra Amount"] = "Quantité extra"
L["Extra Attacks"] = "Attaques supplémentaires"
--[[Translation missing --]]
L["Extra Spell Id"] = "Extra Spell Id"
L["Extra Spell Name"] = "Nom de Sort supplémentaire"
L["Faction"] = "Faction"
--[[Translation missing --]]
L["Faction Name"] = "Nom de la Faction"
L["Faction Reputation"] = "Réputation envers la Faction"
--[[Translation missing --]]
L["Fade Animation"] = "Fade Animation"
L["Fade In"] = "Fondu entrant"
L["Fade Out"] = "Fondu sortant"
L["Fail Alert"] = "Alerte d'échec"
L["False"] = "Faux"
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
L["Fire Resistance"] = "Résistance au feu"
L["Firemaw"] = "Gueule-de-feu"
L["First"] = "Premier"
L["First Value of Tooltip Text"] = "Première Valeur du Texte de l'Info-bulle"
L["Fixed"] = "Fixé"
--[[Translation missing --]]
L["Fixed Names"] = "Fixed Names"
--[[Translation missing --]]
L["Fixed Size"] = "Fixed Size"
--[[Translation missing --]]
L["Flamegor"] = "Flamegor"
L["Flash"] = "Flash"
L["Flex Raid"] = "Raid Dynamique"
L["Flip"] = "Retourner"
L["Floor"] = "Plancher"
L["Follows the chosen aura one frame later. Auras that watch each other in a loop never show."] = "Suit l'aura choisie avec une image de retard. Des auras qui se surveillent en boucle ne s'affichent jamais."
--[[Translation missing --]]
L["Follower Dungeon"] = "Follower Dungeon"
--[[Translation missing --]]
L["Font"] = "Font"
L["Font Size"] = "Taille de Police"
L["Fonts & Text Style"] = "Polices et style de texte"
--[[Translation missing --]]
L["Forbidden function or table: %s"] = "Forbidden function or table: %s"
L["Foreground"] = "Premier plan"
L["Foreground Color"] = "Couleur de Premier Plan"
L["Form"] = "Forme"
L["Form by position"] = "Forme par position"
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
L["Frequency"] = "Fréquence"
L["Friendly"] = "Amical"
L["Friendly Fire"] = "Tir ami"
--[[Translation missing --]]
L["Frost"] = "Frost"
L["Frost Resistance"] = "Résistance au givre"
L["Full"] = "Plein"
--[[Translation missing --]]
L["Full Region"] = "Full Region"
L["Full/Empty"] = "Plein/Vide"
--[[Translation missing --]]
L["Gahz'ranka"] = "Gahz'ranka"
L["Gained"] = "Gagné"
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
L["Glancing"] = "Erafle"
L["Global Cooldown"] = "Temps de recharge global"
L["Glow"] = "Brillance"
L["Glow External Element"] = "Élément externe brillant"
--[[Translation missing --]]
L["Gluth"] = "Gluth"
--[[Translation missing --]]
L["Gold"] = "Gold"
--[[Translation missing --]]
L["Golemagg the Incinerator"] = "Golemagg the Incinerator"
--[[Translation missing --]]
L["Gothik the Harvester"] = "Gothik the Harvester"
L["Gradient"] = "Dégradé"
--[[Translation missing --]]
L["Gradient Enabled"] = "Gradient Enabled"
--[[Translation missing --]]
L["Gradient End"] = "Gradient End"
--[[Translation missing --]]
L["Gradient Orientation"] = "Gradient Orientation"
L["Gradient Pulse"] = "Pulsation dégradée"
--[[Translation missing --]]
L["Grand Widow Faerlina"] = "Grand Widow Faerlina"
L["Grid"] = "Grille"
--[[Translation missing --]]
L["Grobbulus"] = "Grobbulus"
L["Group"] = "Groupe"
L["Group Arrangement"] = "Arrangement du Groupe"
--[[Translation missing --]]
L["Group Leader/Assist"] = "Group Leader/Assist"
--[[Translation missing --]]
L["Group Size"] = "Group Size"
--[[Translation missing --]]
L["Group Type"] = "Group Type"
L["Grow"] = "Grandir"
--[[Translation missing --]]
L["GTFO Alert"] = "Alerte GTFO"
--[[Translation missing --]]
L["Guardian"] = "Guardian"
L["Guild"] = "Guilde"
--[[Translation missing --]]
L["Hakkar"] = "Hakkar"
--[[Translation missing --]]
L["Hardcore"] = "Hardcore"
L["Has Target"] = "A une Cible"
L["HasPet"] = "Avoir un familier (vivant)"
L["Haste (%)"] = "Hâte (%)"
L["Heal"] = "Soin"
L["Heal Absorb"] = "Absorption des soins"
--[[Translation missing --]]
L["Heal Absorbed"] = "Heal Absorbed"
L["Health"] = "Vie"
L["Health (%)"] = "Vie (%)"
--[[Translation missing --]]
L["Health Deficit"] = "Health Deficit"
--[[Translation missing --]]
L["Heigan the Unclean"] = "Heigan the Unclean"
L["Height"] = "Hauteur"
--[[Translation missing --]]
L["Heroic Party"] = "Heroic Party"
--[[Translation missing --]]
L["Hide"] = "Cacher"
--[[Translation missing --]]
L["Hide 0 cooldowns"] = "Hide 0 cooldowns"
L["Hide Timer Text"] = "Masquer le texte du minuteur"
--[[Translation missing --]]
L["High Damage"] = "Dégâts élevés"
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
L["Higher Than Tank"] = "Plus haut que le tank"
--[[Translation missing --]]
L["Highest Spell Id"] = "Highest Spell Id"
L["Holy Resistance"] = "Résistance au sacré"
L["Horde"] = "Horde"
--[[Translation missing --]]
L["Horizontal"] = "Horizontal"
L["Hostile"] = "Hostile"
L["Hostility"] = "Hostilité"
L["Humanoid"] = "Humanoïde"
L["Hybrid"] = "Hybride"
--[[Translation missing --]]
L["Icon"] = "Icône"
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
L["Ignore Dead"] = "Ignorer la mort"
L["Ignore Disconnected"] = "Ignorer les déconnectés"
L["Ignore Rune CD"] = "Ignorer le rechargement des runes"
L["Ignore Rune CDs"] = "Ignorer les rechargements des runes"
L["Ignore Self"] = "Ignorer soi-même"
--[[Translation missing --]]
L["Ignore Spell Cooldown/Charges"] = "Ignore Spell Cooldown/Charges"
--[[Translation missing --]]
L["Ignore Spell Override"] = "Ignore Spell Override"
--[[Translation missing --]]
L["Immune"] = "Immunité"
L["Important"] = "Important"
--[[Translation missing --]]
L["Importing will start after combat ends."] = "Importing will start after combat ends."
L["In Combat"] = "En combat"
L["In Encounter"] = "En rencontre"
L["In Group"] = "En groupe"
L["In Party"] = "En groupe"
L["In Raid"] = "En raid"
--[[Translation missing --]]
L["In Range"] = "In Range"
L["Include Bank"] = "Inclure la Banque"
L["Include Charges"] = "Inclure charges"
L["Include Pets"] = "Inclure les familiers"
L["Incoming Heal"] = "Soins en Cours"
--[[Translation missing --]]
L["Increase Precision Below"] = "Increase Precision Below"
--[[Translation missing --]]
L["Increases by one per stage or intermission."] = "Increases by one per stage or intermission."
L["Information"] = "Information"
L["Inherited"] = "Hérité"
L["Instakill"] = "Mort instant."
--[[Translation missing --]]
L["Install the addons BugSack and BugGrabber for detailed error logs."] = "Install the addons BugSack and BugGrabber for detailed error logs."
L["Instance"] = "Instance"
--[[Translation missing --]]
L["Instance Id"] = "Instance Id"
--[[Translation missing --]]
L["Instance ID"] = "Instance ID"
--[[Translation missing --]]
L["Instance Info"] = "Instance Info"
--[[Translation missing --]]
L["Instance Name"] = "Instance Name"
L["Instance Size Type"] = "Taille de l'instance"
L["Instance Type"] = "Type d'instance"
--[[Translation missing --]]
L["Instructor Razuvious"] = "Instructor Razuvious"
L["Insufficient Resources"] = "Ressources insuffisantes"
L["Intellect"] = "Intelligence"
L["Interrupt"] = "Interruption"
--[[Translation missing --]]
L["Interrupt School"] = "Interrupt School"
--[[Translation missing --]]
L["Interrupted School Text"] = "Interrupted School Text"
L["Interruptible"] = "Interruptible"
L["Inverse"] = "Inverser"
L["Inverse Pet Behavior"] = "Inverser le comportement du familier"
--[[Translation missing --]]
L["Is Away from Keyboard"] = "Is Away from Keyboard"
L["Is Exactly"] = "Est exactement"
L["Is Moving"] = "Est en mouvement"
L["Is Off Hand"] = "Est une Main gauche"
--[[Translation missing --]]
L["Is Paused"] = "Is Paused"
L["is useable"] = "est utilisable"
--[[Translation missing --]]
L["Island Expedition (Heroic)"] = "Island Expedition (Heroic)"
--[[Translation missing --]]
L["Island Expedition (Mythic)"] = "Island Expedition (Mythic)"
--[[Translation missing --]]
L["Island Expedition (Normal)"] = "Island Expedition (Normal)"
--[[Translation missing --]]
L["Island Expeditions (PvP)"] = "Island Expeditions (PvP)"
L["Item"] = "Objet"
L["Item Bonus Id"] = "ID du bonus de l'objet"
L["Item Bonus Id Equipped"] = "ID du bonus de l'objet équipé"
L["Item Count"] = "Nombre d'objets"
L["Item Equipped"] = "Objet équipé"
--[[Translation missing --]]
L["Item Id"] = "Item Id"
L["Item in Range"] = "Objet à porté"
--[[Translation missing --]]
L["Item Name"] = "Item Name"
L["Item Set Equipped"] = "Ensemble d'objets équipé"
L["Item Set Id"] = "ID de l'Ensemble d'Equipement"
--[[Translation missing --]]
L["Item Slot"] = "Item Slot"
--[[Translation missing --]]
L["Item Slot String"] = "Item Slot String"
L["Item Type"] = "Type d'objet"
L["Item Type Equipped"] = "Type d'objet équipé"
--[[Translation missing --]]
L["ItemId"] = "ItemId"
--[[Translation missing --]]
L["Jin'do the Hexxer"] = "Jin'do the Hexxer"
--[[Translation missing --]]
L["Journal Stage"] = "Journal Stage"
--[[Translation missing --]]
L["Kazzak"] = "Kazzak"
L["Keep Inside"] = "Garder à l'Intérieur"
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
L["Least remaining time"] = "Moins de temps restant"
L["Leaving"] = "Quitter"
L["Leech"] = "Drain"
L["Left"] = "Gauche"
L["Left to Right"] = "De Gauche à Droite"
--[[Translation missing --]]
L["Left, then Centered Vertical"] = "Left, then Centered Vertical"
L["Left, then Down"] = "Gauche, puis bas"
L["Left, then Up"] = "Gauche, puis haut"
--[[Translation missing --]]
L["Legacy Looking for Raid"] = "Legacy Looking for Raid"
L["Legacy RGB Gradient"] = "Dégradé RVB Hérité"
L["Legacy RGB Gradient Pulse"] = "Impulsion de Dégradé RVB héritée"
--[[Translation missing --]]
L["Legion"] = "Legion"
L["Length"] = "Longueur"
--[[Translation missing --]]
L["Level"] = "Niveau"
--[[Translation missing --]]
L["LibSharedMedia"] = "LibSharedMedia"
--[[Translation missing --]]
L["Lillian Voss"] = "Lillian Voss"
L["Limited"] = "Limité"
--[[Translation missing --]]
L["Linear Texture"] = "Linear Texture"
--[[Translation missing --]]
L["Lines & Particles"] = "Lines & Particles"
L["Load Conditions"] = "Conditions de Chargement"
--[[Translation missing --]]
L["Loatheb"] = "Loatheb"
--[[Translation missing --]]
L["Location"] = "Location"
--[[Translation missing --]]
L["Looking for Raid"] = "Looking for Raid"
L["Loop"] = "Boucle"
--[[Translation missing --]]
L["Loot"] = "Loot"
--[[Translation missing --]]
L["Lorewalking"] = "Lorewalking"
L["Lost"] = "Perdu"
L["Low Damage"] = "Dégâts faibles"
L["Lower Than Tank"] = "Plus bas que le tank"
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
L["Magic"] = "Magique"
--[[Translation missing --]]
L["Magmadar"] = "Magmadar"
--[[Translation missing --]]
L["Majordomo Executus"] = "Majordomo Executus"
L["Malformed WeakAuras link"] = "Lien WeakAuras mal formé"
--[[Translation missing --]]
L["Manual"] = "Manual"
--[[Translation missing --]]
L["Manual Icon"] = "Manual Icon"
L["Manual Rotation"] = "Rotation manuelle"
L["Marked First"] = "Marqué en premier"
L["Marked Last"] = "Marqué en dernier"
--[[Translation missing --]]
L["Mason"] = "Mason"
L["Master"] = "Maître"
L["Match Count"] = "taux de rencontre"
--[[Translation missing --]]
L["Match Count per Unit"] = "Match Count per Unit"
L["Matches (Pattern)"] = "Correspond (format)"
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
L["Max Charges"] = "Charges Max"
--[[Translation missing --]]
L["Max Health"] = "Max Health"
--[[Translation missing --]]
L["Max Power"] = "Max Power"
L["Maximum Estimate"] = "Estimation Maximale"
--[[Translation missing --]]
L["Maximum Progress"] = "Maximum Progress"
--[[Translation missing --]]
L["Maximum time used on a single frame"] = "Maximum time used on a single frame"
--[[Translation missing --]]
L["Media"] = "Media"
L["Medium"] = "Moyen"
--[[Translation missing --]]
L["Melee"] = "Melee"
L["Message"] = "Message"
L["Message Type"] = "Type de message"
L["Message type:"] = "Type de message :"
L["Meta Data"] = "Métadonnées"
--[[Translation missing --]]
L["Mine"] = "Mine"
L["Minimum Estimate"] = "Estimation minimale"
--[[Translation missing --]]
L["Minimum Progress"] = "Minimum Progress"
--[[Translation missing --]]
L["Minus (Small Nameplate)"] = "Minus (Small Nameplate)"
L["Mirror"] = "Miroir"
--[[Translation missing --]]
L["Miscellaneous"] = "Miscellaneous"
L["Miss"] = "Raté"
L["Miss Type"] = "Type de raté"
L["Missed"] = "Raté"
L["Missing"] = "Manquant"
--[[Translation missing --]]
L["Mists of Pandaria"] = "Mists of Pandaria"
L["Moam"] = "Moam"
L["Model"] = "Modèle"
L["Modern Blizzard (1h 3m | 3m 7s | 10s | 2.4)"] = "Blizzard moderne (1h 3min | 3m 7s | 10s | 2.4)"
--[[Translation missing --]]
L["Modernize"] = "Modernize"
--[[Translation missing --]]
L["Molten Core"] = "Molten Core"
--[[Translation missing --]]
L["Money"] = "Money"
L["Monochrome"] = "Monochrome"
L["Monochrome Outline"] = "Contour monochrome"
L["Monochrome Thick Outline"] = "Contour épais monochrome"
L["Monster Emote"] = "Emote de Monstre"
L["Monster Party"] = "Groupe de Monstre"
L["Monster Say"] = "Dire de Monstre"
L["Monster Whisper"] = "Chuchotement de Monstre"
L["Monster Yell"] = "Cri de monstre"
--[[Translation missing --]]
L["Most remaining time"] = "Plus de temps restant"
--[[Translation missing --]]
L["Mounted"] = "En monture"
L["Mouse Cursor"] = "Curseur de la souris"
L["Multi-target"] = "Multi-cibles"
--[[Translation missing --]]
L["Mythic Keystone"] = "Clé mythique"
--[[Translation missing --]]
L["Name"] = "Nom"
--[[Translation missing --]]
L["Name Function"] = "Name Function"
--[[Translation missing --]]
L["Name Function (fallback state)"] = "Name Function (fallback state)"
L["Name of Caster's Target"] = "Nom de la cible du lanceur"
L["Name of the (sub-)zone currently shown above the minimap."] = "Nom de la (sous-)zone actuellement affichée au-dessus de la mini-carte."
--[[Translation missing --]]
L["Name(s)"] = "Name(s)"
L["Name/Realm of Caster's Target"] = "Nom/Royaume de la Cible du Lanceur de sort"
L["Nameplate"] = "Barre de vie"
L["Nameplates"] = "Barres de vie"
L["Names of affected Players"] = "Noms des joueurs affectés"
L["Names of unaffected Players"] = "Noms des joueurs non affectés"
L["Nature Resistance"] = "Résistance à la nature"
L["Naxxramas"] = "Naxxramas"
L["Nefarian"] = "Nefarian"
--[[Translation missing --]]
L["Neutral"] = "Neutre"
L["Never"] = "Jamais"
L["Next Combat"] = "Prochain combat"
--[[Translation missing --]]
L["Next Encounter"] = "Next Encounter"
--[[Translation missing --]]
L[ [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L["No Extend"] = "No Extend"
L["No Instance"] = "Aucune instance"
L["No Profiling information saved."] = "Aucune information de profilage enregistrée."
--[[Translation missing --]]
L["No Progress Information available."] = "No Progress Information available."
L["None"] = "Aucun"
L["Non-player Character"] = "Personnage non-joueur"
L["Normal"] = "Normal"
--[[Translation missing --]]
L["Normal Party"] = "Normal Party"
--[[Translation missing --]]
L["Not in Group"] = "N'est pas en groupe"
L["Not in Smart Group"] = "N'est pas dans un petit groupe"
L["Not on Cooldown"] = "Pas en recharge"
L["Not On Threat Table"] = "Pas sur la table de menace"
--[[Translation missing --]]
L["Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."] = "Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."
L["Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."] = "Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."
L["Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"] = "Remarque : Ce type de déclencheur estime la portée du masque de collision (hitbox) d'une unité. La portée réelle des joueurs amis est généralement supérieure de 3 mètres à l'estimation. Les capacités de vérification de la portée dépendent de votre classe actuelle et de vos capacités connues, ainsi que du type d'unité à vérifier. Certaines des portées peuvent également ne pas fonctionner avec certains PNJ.|n|n|cFFAAFFAAUnités amies :|r %s|n|cFFFFAAAAUnités nuisibles :|r %s|n|cFFAAAAFFUnités diverses :|r %s"
L["Noth the Plaguebringer"] = "Noth le Porte-peste"
L["NPC"] = "PNJ"
L["Npc ID"] = "ID PNJ"
L["Number"] = "Nombre"
L["Number Affected"] = "Nombre affecté"
L["Object"] = "Objet"
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
L["Officer"] = "Officier"
--[[Translation missing --]]
L["Offset from progress"] = "Offset from progress"
L["Offset Timer"] = "Décalage de la durée"
L["Old Blizzard (2h | 3m | 10s | 2.4)"] = "Blizzard ancien (2h | 3m | 10s | 2.4)"
L["On Cooldown"] = "En recharge"
--[[Translation missing --]]
L["On Taxi"] = "On Taxi"
--[[Translation missing --]]
L["Only if on a different realm"] = "Only if on a different realm"
L["Only if Primary"] = "Seulement si primaire"
L["Onyxia"] = "Onyxia"
L["Opaque"] = "Opaque"
--[[Translation missing --]]
L["Option Group"] = "Option du groupe"
--[[Translation missing --]]
L["Options could not be loaded, the addon is %s"] = "Options could not be loaded, the addon is %s"
L["Options will finish loading after combat ends."] = "Les options finiront de se charger après la fin du combat."
L["Options will open after the login process has completed."] = "Les options s'ouvriront après la fin du chargement."
--[[Translation missing --]]
L["Or Talent"] = "Or Talent"
L["Orbit"] = "Orbite"
L["Orientation"] = "Orientation"
L["Ossirian the Unscarred"] = "Ossirian l'Intouché"
L["Other"] = "Autre"
L["Other Addons"] = "Autre Addons"
L["Other Events"] = "Autre Événements"
L["Ouro"] = "Ouro"
L["Outline"] = "Contour"
--[[Translation missing --]]
L["Over Energize"] = "Over Energize"
L["Overhealing"] = "Soin en excès"
L["Overkill"] = "Dégâts en excès"
L["Overlay %s"] = "Superposer %s"
L["Overlay Cost of Casts"] = "Superposer le coût des incantations"
L["Overlay Latency"] = "Superposer la Latence"
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
L["Parry"] = "Parade"
L["Parry (%)"] = "Parade (%)"
L["Party"] = "Groupe"
L["Party Kill"] = "Tué par le groupe"
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
L["Paused"] = "En pause"
L["Periodic Spell"] = "Sort périodique"
L["Personal Resource Display"] = "Cadre des ressources personnelles"
L["Pet"] = "Familier "
L["Pet Behavior"] = "Comportement du familier"
L["Pet Specialization"] = "Spécialisation du familier"
L["Pet Spell"] = "Sort du familier"
L["Pets only"] = "Familiers seulement"
L["Phase"] = "Phase"
L["Pixel Glow"] = "Pixel brillant"
L["Placement"] = "Placement"
--[[Translation missing --]]
L["Placement %i"] = "Placement %i"
--[[Translation missing --]]
L["Placement Mode"] = "Placement Mode"
L["Play"] = "Jouer"
L["Player"] = "Joueur"
L["Player Character"] = "Personnage Joueur"
L["Player Class"] = "Classe du joueur"
--[[Translation missing --]]
L["Player Experience"] = "Player Experience"
L["Player Faction"] = "Faction joueur"
L["Player Level"] = "Niveau du joueur"
--[[Translation missing --]]
L["Player Location ID(s)"] = "Player Location ID(s)"
--[[Translation missing --]]
L["Player Money"] = "Player Money"
L["Player Name/Realm"] = "Nom du joueur / serveur"
L["Player Race"] = "Race du joueur"
L["Player(s) Affected"] = "Joueur(s) affecté(s)"
L["Player(s) Not Affected"] = "Joueur(s) non affecté(s)"
--[[Translation missing --]]
L["Player/Unit Info"] = "Player/Unit Info"
L["Players and Pets"] = "Joueurs et familiers"
L["Poison"] = "Poison"
L["Power"] = "Puissance"
L["Power (%)"] = "Puissance (%)"
--[[Translation missing --]]
L["Power Deficit"] = "Power Deficit"
L["Power Type"] = "Type de puissance"
L["Precision"] = "Précision"
L["Preset"] = "Préréglé"
--[[Translation missing --]]
L["Primary Stats"] = "Primary Stats"
--[[Translation missing --]]
L["Princess Huhuran"] = "Princess Huhuran"
L["Print Profiling Results"] = "Afficher les résultats de profilage"
L["Proc Glow"] = "Génère une brillance"
L["Profiling already started."] = "Le profilage a déjà commencé."
--[[Translation missing --]]
L["Profiling automatically started."] = "Profiling automatically started."
L["Profiling not running."] = "Le profilage ne fonctionne pas."
L["Profiling started."] = "Le profilage a commencé."
--[[Translation missing --]]
L["Profiling started. It will end automatically in %d seconds"] = "Profiling started. It will end automatically in %d seconds"
L["Profiling still running, stop before trying to print."] = "Le profilage est toujours en cours, arrêtez avant d'essayer de l'afficher"
L["Profiling stopped."] = "Le profilage s'est arrêté."
L["Progress"] = "Progrès"
--[[Translation missing --]]
L["Progress Source"] = "Progress Source"
L["Progress Total"] = "Progrès Total"
L["Progress Value"] = "Valeur de progression"
--[[Translation missing --]]
L["Pull"] = "Pull"
L["Pulse"] = "Pulsation"
L["PvP Flagged"] = "JcJ activé"
--[[Translation missing --]]
L["PvP Mode Active"] = "PvP Mode Active"
--[[Translation missing --]]
L["Quest Party"] = "Quest Party"
--[[Translation missing --]]
L["Queued Action"] = "Queued Action"
L["Radius"] = "Rayon"
--[[Translation missing --]]
L["Ragnaros"] = "Ragnaros"
L["Raid"] = "Raid "
L["Raid (Heroic)"] = "Raid (Héroïque)"
L["Raid (Mythic)"] = "Raid (Mythique)"
L["Raid (Normal)"] = "Raid (Normal)"
L["Raid (Timewalking)"] = "Raid (Marcheurs du temps)"
L["Raid Mark"] = "Marque de raid"
L["Raid Mark Icon"] = "Icône pour la marque de raid"
L["Raid Role"] = "Rôle de raid"
L["Raid Warning"] = "Avertissement de raid"
L["Range"] = "Portée"
L["Range Check"] = "Vérification de la portée"
--[[Translation missing --]]
L["Ranged"] = "Ranged"
--[[Translation missing --]]
L["Rank"] = "Rank"
L["Rare"] = "Rare"
--[[Translation missing --]]
L["Rare Elite"] = "Rare Elite"
L["Rated Arena"] = "Arène Coté"
L["Rated Battleground"] = "Champ de bataille Coté"
--[[Translation missing --]]
L["Raw Threat Percent"] = "Raw Threat Percent"
--[[Translation missing --]]
L["Razorgore the Untamed"] = "Razorgore the Untamed"
L["Ready Check"] = "Appel de Raid"
L["Realm"] = "Royaume"
L["Realm Name"] = "Nom du Royaume"
L["Realm of Caster's Target"] = "Royaume de la Cible du Lanceur de sort"
--[[Translation missing --]]
L["Reborn Council"] = "Reborn Council"
--[[Translation missing --]]
L["Receiving %s Bytes"] = "Receiving %s Bytes"
L["Receiving display information"] = "Réception d'information de graphique de %s..."
L["Reflect"] = "Renvoi"
L["Region type %s not supported"] = "Région de type %s non supporté"
L["Relative"] = "Relatif"
L["Relative X-Offset"] = "Décalage sur l'axe X"
L["Relative Y-Offset"] = "Décalage sur l'axe Y"
--[[Translation missing --]]
L["Remaining Duration"] = "Durée Restante"
L["Remaining Time"] = "Temps restant"
L["Remove Obsolete Auras"] = "Retirer les auras obsolètes"
L["Repair"] = "Réparer"
L["Repeat"] = "Répéter"
--[[Translation missing --]]
L["Report Summary"] = "Report Summary"
--[[Translation missing --]]
L["Reputation"] = "Reputation"
--[[Translation missing --]]
L["Reputation (%)"] = "Reputation (%)"
L["Requested display does not exist"] = "L'affichage demandé n'existe pas"
L["Requested display not authorized"] = "L'affichage demandé n'est pas autorisé"
L["Requesting display information from %s ..."] = "Demande des informations de l'affichage depuis %s ..."
L["Addon whispers are paused for now. Try this link again in a moment."] = "Les chuchotements d'addon sont suspendus pour l'instant. Réessayez ce lien dans un moment."
L["Addon whispers are off on this realm. Use an import string to share this aura."] = "Les chuchotements d'addon sont désactivés sur ce royaume. Partagez cette aura par une chaîne d'import."
L["Require Valid Target"] = "Exige une cible valide"
L["Resist"] = "Résiste"
--[[Translation missing --]]
L["Resistances"] = "Resistances"
L["Resisted"] = "Résisté"
L["Rested"] = "Reposé"
--[[Translation missing --]]
L["Rested Experience"] = "Rested Experience"
--[[Translation missing --]]
L["Rested Experience (%)"] = "Rested Experience (%)"
L["Resting"] = "Repos"
L["Resurrect"] = "Résurrection"
--[[Translation missing --]]
L["Resurrect Pending"] = "Resurrect Pending"
L["Right"] = "Droite"
L["Right to Left"] = "Droite à Gauche"
L["Right, then Centered Vertical"] = "Droite, puis centrer verticalement"
L["Right, then Down"] = "Droite, puis bas"
L["Right, then Up"] = "Droite, puis haut"
L["Role"] = "Rôle"
--[[Translation missing --]]
L["Rollback snapshot is complete. Thank you for your patience!"] = "Rollback snapshot is complete. Thank you for your patience!"
--[[Translation missing --]]
L["Rotate Animation"] = "Rotate Animation"
L["Rotate Left"] = "Rotation gauche"
L["Rotate Right"] = "Rotation droite"
L["Rotation"] = "Rotation"
L["Round"] = "Ronde"
--[[Translation missing --]]
L["Round Mode"] = "Round Mode"
L["Ruins of Ahn'Qiraj"] = "Ruines d'Ahn'Qiraj"
L["Run Custom Code"] = "Exécuter le code personnalisé"
--[[Translation missing --]]
L["Run Speed (%)"] = "Run Speed (%)"
--[[Translation missing --]]
L["Sapphiron"] = "Sapphiron"
--[[Translation missing --]]
L["Say"] = "Dire"
L["Scale"] = "Échelle"
--[[Translation missing --]]
L["Scarlet Enclave"] = "Scarlet Enclave"
L["Scenario"] = "Scénario"
--[[Translation missing --]]
L["Scenario (Heroic)"] = "Scenario (Heroic)"
--[[Translation missing --]]
L["Scenario (Normal)"] = "Scenario (Normal)"
--[[Translation missing --]]
L["Screen"] = "Screen"
L["Screen/Parent Group"] = "Écran/Groupe parent"
--[[Translation missing --]]
L["Season of Discovery"] = "Season of Discovery"
L["Second"] = "Deuxième"
L["Second Value of Tooltip Text"] = "Deuxième valeur du texte de l'info-bulle"
--[[Translation missing --]]
L["Secondary Stats"] = "Secondary Stats"
L["Seconds"] = "Secondes"
--[[Translation missing --]]
L[ [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
L["Select Frame"] = "Sélectionner le cadre"
--[[Translation missing --]]
L["Select the type of timer to filter"] = "Select the type of timer to filter"
--[[Translation missing --]]
L["Selection Mode"] = "Selection Mode"
L["Separator"] = "Séparateur"
--[[Translation missing --]]
L["Set IDs can be found on websites such as wowhead.com/classic/item-sets"] = "Set IDs can be found on websites such as wowhead.com/classic/item-sets"
--[[Translation missing --]]
L["Shadow Resistance"] = "Résistance à l'ombre"
--[[Translation missing --]]
L["Shadowlands"] = "Shadowlands"
--[[Translation missing --]]
L["Shake"] = "Secouer"
--[[Translation missing --]]
L["Shazzrah"] = "Shazzrah"
L["Shift-Click to resume addon execution."] = "Maj-Clic pour reprendre l'exécution de l'addon."
L["Show"] = "Montrer"
L["Show Absorb"] = "Afficher l'absorption des dégâts"
L["Show CD of Charge"] = "Afficher le Temps de Recharge de la charge"
L["Show GCD"] = "Afficher GCD"
L["Show Global Cooldown"] = "Afficher le Temps de Recharge Global"
L["Show Heal Absorb"] = "Afficher l'absorption des soins"
L["Show Incoming Heal"] = "Afficher les Soins en Cours"
--[[Translation missing --]]
L["Show Loss of Control"] = "Show Loss of Control"
L["Show On"] = "Afficher Sur"
L["Show Rested Overlay"] = "Superposer l'XP en reposé"
L["Shrink"] = "Rétrécir"
--[[Translation missing --]]
L["Silithid Royalty"] = "Silithid Royalty"
--[[Translation missing --]]
L["Silver"] = "Silver"
L["Simple"] = "Basique"
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
L["Size & Position"] = "Taille & Position"
--[[Translation missing --]]
L["Slide Animation"] = "Slide Animation"
L["Slide from Bottom"] = "Glisser d'en bas"
L["Slide from Left"] = "Glisser de la gauche"
L["Slide from Right"] = "Glisser de la droite"
L["Slide from Top"] = "Glisser d'en haut"
L["Slide to Bottom"] = "Glisser en bas"
L["Slide to Left"] = "Glisser à gauche"
L["Slide to Right"] = "Glisser à droite"
L["Slide to Top"] = "Glisser en haut"
--[[Translation missing --]]
L["Slider"] = "Slider"
--[[Translation missing --]]
L["Slug"] = "Slug"
--[[Translation missing --]]
L["Slug Outline"] = "Slug Outline"
L["Small"] = "Petit"
--[[Translation missing --]]
L["Smart Group"] = "Smart Group"
--[[Translation missing --]]
L["Soft Enemy"] = "Soft Enemy"
--[[Translation missing --]]
L["Soft Friend"] = "Soft Friend"
--[[Translation missing --]]
L["Solistrasza"] = "Solistrasza"
L["Sound"] = "Son"
L["Sound by Kit ID"] = "Son par Kit ID"
L["Source"] = "Source"
--[[Translation missing --]]
L["Source Affiliation"] = "Source Affiliation"
--[[Translation missing --]]
L["Source GUID"] = "Source GUID"
--[[Translation missing --]]
L["Source Info"] = "Source Info"
L["Source Name"] = "Nom de source"
--[[Translation missing --]]
L["Source NPC Id"] = "Source NPC Id"
--[[Translation missing --]]
L["Source Object Type"] = "Source Object Type"
--[[Translation missing --]]
L["Source Raid Mark"] = "Source Raid Mark"
--[[Translation missing --]]
L["Source Reaction"] = "Source Reaction"
L["Source Unit"] = "Unité source"
--[[Translation missing --]]
L["Source Unit Name/Realm"] = "Source Unit Name/Realm"
--[[Translation missing --]]
L["Source unit's raid mark index"] = "Source unit's raid mark index"
--[[Translation missing --]]
L["Source unit's raid mark texture"] = "Source unit's raid mark texture"
L["Space"] = "Ecart"
L["Spacing"] = "Ecartement"
L["Spark"] = "Étincelle"
--[[Translation missing --]]
L["Specialization"] = "Specialization"
L["Specific Type"] = "Type spécifique"
L["Specific Unit"] = "Unité spécifique"
L["Spell"] = "Sort"
L["Spell (Building)"] = "Sort (croissant)"
--[[Translation missing --]]
L["Spell Cast Succeeded"] = "Spell Cast Succeeded"
L["Spell Cost"] = "Coût des sorts"
--[[Translation missing --]]
L["Spell Count"] = "Spell Count"
L["Spell ID"] = "ID de Sort"
L["Spell Id"] = "ID de Sort"
L["Spell ID:"] = "ID de sort:"
L["Spell IDs:"] = "IDs de sort"
L["Spell in Range"] = "Sort à portée"
L["Spell Known"] = "Sort connu"
L["Spell Name"] = "Nom du sort"
--[[Translation missing --]]
L["Spell Power"] = "Spell Power"
--[[Translation missing --]]
L["Spell School"] = "Spell School"
L["Spell Usable"] = "Sort Utilisable"
--[[Translation missing --]]
L["Spellname"] = "Spellname"
--[[Translation missing --]]
L["Spike"] = "Spike"
L["Spin"] = "Tourne"
L["Spiral"] = "Spirale"
L["Spiral In And Out"] = "Spirale entrante et sortante"
--[[Translation missing --]]
L["Spirit"] = "Spirit"
L["Stack Count"] = "Nombre de Piles"
--[[Translation missing --]]
L["Stack trace:"] = "Stack trace:"
L["Stacks"] = "Piles"
--[[Translation missing --]]
L["Stacks Function"] = "Stacks Function"
--[[Translation missing --]]
L["Stacks Function (fallback state)"] = "Stacks Function (fallback state)"
--[[Translation missing --]]
L["Stage"] = "Stage"
--[[Translation missing --]]
L["Stage Counter"] = "Stage Counter"
L["Stage Total"] = "Étapes au total"
--[[Translation missing --]]
L["Stagger"] = "Stagger"
L["Stagger Scale"] = "espacer"
L["Stamina"] = "Endurance"
L["Stance/Form/Aura"] = "Posture/Forme/Aura"
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
L["Status"] = "Statut"
--[[Translation missing --]]
L["Status Bar"] = "Status Bar"
L["Stolen"] = "Volé"
L["Stop"] = "Arrêter"
--[[Translation missing --]]
L["Stop Motion"] = "Stop Motion"
--[[Translation missing --]]
L["Story Raid"] = "Story Raid"
L["Strength"] = "Force"
L["String"] = "Séquence"
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
L["Summon"] = "Invocation"
L["Supports multiple entries, separated by commas"] = "Prend en charge plusieurs entrées, séparées par des virgules"
L[ [=[Supports multiple entries, separated by commas
]=] ] = "Prend en charge plusieurs entrées, séparées par des virgules"
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
L["Swing"] = "Coup"
L["Swing Timer"] = "Vitesse d'attaque"
L["Swipe"] = "Balayage"
--[[Translation missing --]]
L["Syntax /wa feature <toggle|on|enable|disable|off> <feature>"] = "Syntax /wa feature <toggle|on|enable|disable|off> <feature>"
L["System"] = "Système"
--[[Translation missing --]]
L["Systems"] = "Systems"
L["Tab "] = "Onglet"
--[[Translation missing --]]
L["Talent"] = "Talent"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Known"] = "Talent |cFFFF0000Not|r Known"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Selected"] = "Talent |cFFFF0000Not|r Selected"
--[[Translation missing --]]
L["Talent Known"] = "Talent Known"
L["Talent Selected"] = "Talent sélectionné"
L["Talent Specialization"] = "Spécialisation"
L["Tanking And Highest"] = "Tank et le plus haut"
L["Tanking But Not Highest"] = "Tank mais pas le plus haut"
L["Target"] = "Cible"
L["Targeted"] = "Ciblé"
--[[Translation missing --]]
L["Tertiary Stats"] = "Tertiary Stats"
--[[Translation missing --]]
L["Test if bar is enabled in BigWigs settings"] = "Test if bar is enabled in BigWigs settings"
--[[Translation missing --]]
L["Test if bar is enabled in Boss Mod addon settings"] = "Test if bar is enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Test if bar is enabled in DBM settings"] = "Test if bar is enabled in DBM settings"
L["Text"] = "Texte"
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
L["There are %i updates to your auras ready to be installed!"] = [=[
Il y a %i mises à jour de vos auras prêtes à être installées!]=]
L["Thick Outline"] = "Contour épais"
L["Thickness"] = "Épaisseur"
L["Third"] = "Troisième"
L["Third Value of Tooltip Text"] = "Troisième valeur du texte de l'info-bulle"
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
L["Threat Situation"] = "Situation de Menace"
--[[Translation missing --]]
L["Threat Value"] = "Threat Value"
L["Tick"] = "Coche"
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
L["Timed"] = "Temporisé"
--[[Translation missing --]]
L["Timed Progress"] = "Timed Progress"
--[[Translation missing --]]
L["Timer"] = "Timer"
--[[Translation missing --]]
L["Timer Id"] = "Timer Id"
L["Toggle"] = "Basculer"
L["Toggle List"] = "Basculer la liste"
L["Toggle Options Window"] = "Activer/Désactiver la Fenêtre d'Options"
--[[Translation missing --]]
L["Toggle Performance Profiling Window"] = "Toggle Performance Profiling Window"
L["Tooltip"] = "Info-bulle"
L["Tooltip 1"] = "Info-bulle 1"
L["Tooltip 2"] = "Info-bulle 2"
L["Tooltip 3"] = "Info-bulle 3"
L["Tooltip Value 1"] = "Valeur de l'info-bulle 1"
L["Tooltip Value 2"] = "Valeur de l'info-bulle 2"
L["Tooltip Value 3"] = "Valeur de l'info-bulle 3"
L["Tooltip Value 4"] = "Valeur de l'info-bulle 4"
L["Top"] = "Haut"
L["Top Left"] = "Haut Gauche"
L["Top Right"] = "Haut Droite"
L["Top to Bottom"] = "Haut en Bas"
--[[Translation missing --]]
L["Torghast"] = "Torghast"
L["Total Duration"] = "Duration Totale"
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
L["Total Units"] = "Unités Total"
L["Totem"] = "Totem"
L["Totem #%i"] = "Totem #%i"
--[[Translation missing --]]
L["Totem Icon"] = "Totem Icon"
L["Totem Name"] = "Nom Totem"
--[[Translation missing --]]
L["Totem Name Pattern Match"] = "Totem Name Pattern Match"
L["Totem Number"] = "Numéro du Totem"
L["Track Cooldowns"] = "Suivre les temps de recharge "
L["Tracking Charge %i"] = "Suivi de charge %i"
L["Tracking Charge CDs"] = "Suivi des CD de charge"
L["Tracking Only Cooldown"] = "Suivi du temps de recharge"
L["Transmission error"] = "Erreur de transmission"
--[[Translation missing --]]
L["Trigger"] = "Déclencheur"
--[[Translation missing --]]
L["Trigger %i"] = "Trigger %i"
--[[Translation missing --]]
L["Trigger %s"] = "Trigger %s"
L["Trigger 1"] = "Déclencheur 1"
L["Trigger State Updater (Advanced)"] = [=[
Mise à jour de l'état du déclencheur (Avancé)]=]
L["Trigger Update"] = "Mise-à-jour du déclencheur"
L["Trigger:"] = "Déclencheur :"
--[[Translation missing --]]
L["Trivial (Low Level)"] = "Trivial (Low Level)"
L["True"] = "Vrai"
--[[Translation missing --]]
L["Trying to repair broken conditions in %s likely caused by a WeakAuras bug."] = "Trying to repair broken conditions in %s likely caused by a WeakAuras bug."
--[[Translation missing --]]
L["Twin Emperors"] = "Twin Emperors"
L["Type"] = "Type"
--[[Translation missing --]]
L["Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the WeakAuras team."] = "Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the WeakAuras team."
L["Unaffected"] = "Non-affecté"
L["Undefined"] = "Non-défini"
L["Unit"] = "Unité"
L["Unit Characteristics"] = "Caractéristique d'unité"
L["Unit Destroyed"] = "Unité détruite"
L["Unit Died"] = "Unité morte"
--[[Translation missing --]]
L["Unit Dissipates"] = "Unit Dissipates"
--[[Translation missing --]]
L["Unit Frame"] = "Unit Frame"
L["Unit Frames"] = "Cadre d'unité"
L["Unit is Unit"] = "L'unité est l'unité"
L["Unit Name"] = "Nom de l'Unité"
--[[Translation missing --]]
L["Unit Name/Realm"] = "Unit Name/Realm"
L["Units Affected"] = "Unités Concernés"
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
L["Unlimited"] = "Illimité"
--[[Translation missing --]]
L["Untrigger %s"] = "Untrigger %s"
L["Up"] = "Haut"
L["Up, then Centered Horizontal"] = "Haut, puis centrer horizontalement"
L["Up, then Left"] = "Haut, puis gauche"
L["Up, then Right"] = "Haut, puis droite"
--[[Translation missing --]]
L["Update Position"] = "Update Position"
L["Usage:"] = "Utilisation:"
L["Use /wa minimap to show the minimap icon again."] = "Utilisez /wa minimap pour afficher à nouveau l’icône de la mini-carte."
L["Use Custom Color"] = "Utiliser couleur personnalisée"
--[[Translation missing --]]
L["Use Legacy floor rounding"] = "Use Legacy floor rounding"
--[[Translation missing --]]
L["Use Texture"] = "Use Texture"
--[[Translation missing --]]
L["Use Watched Faction"] = "Use Watched Faction"
--[[Translation missing --]]
L["Used Slots"] = "Emplacements utilisés"
L["Using WeakAuras.clones is deprecated. Use WeakAuras.GetRegion(id, cloneId) instead."] = "L'utilisation de WeakAuras.clones est obsolète. Utilisez plutôt WeakAuras.GetRegion(id, cloneId)."
L["Using WeakAuras.regions is deprecated. Use WeakAuras.GetRegion(id) instead."] = "L'utilisation de WeakAuras.regions est obsolète. Utilisez plutôt WeakAuras.GetRegion(id)."
L["Vaelastrasz the Corrupt"] = "Vaelastrasz le Corrompu"
L["Vertical"] = "Verticale"
--[[Translation missing --]]
L["Viscidus"] = "Viscidus"
L["Visibility"] = "Visibilité"
L["Visions of N'Zoth"] = "Visions de N'Zoth"
L["Warfront (Heroic)"] = "Front de guerre (Héroïque)"
L["Warfront (Normal)"] = "Front de guerre (Normal)"
L["Warlords of Draenor"] = "Warlords of Draenor"
L["Warning"] = "Attention"
--[[Translation missing --]]
L["Warning for unknown aura:"] = "Warning for unknown aura:"
--[[Translation missing --]]
L["Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"] = "Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"
L["WeakAuras Built-In (63:42 | 3:07 | 10 | 2.4)"] = "WeakAuras Built-In (63:42 | 3:07 | 10 | 2.4)"
--[[Translation missing --]]
L["WeakAuras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."] = "WeakAuras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."
--[[Translation missing --]]
L[ [=[WeakAuras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=] ] = [=[WeakAuras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=]
--[[Translation missing --]]
L["WeakAuras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."] = "WeakAuras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."
--[[Translation missing --]]
L["WeakAuras Profiling"] = "WeakAuras Profiling"
--[[Translation missing --]]
L["WeakAuras Profiling Report"] = "WeakAuras Profiling Report"
--[[Translation missing --]]
L["WeakAuras Version: %s"] = "WeakAuras Version: %s"
L["Weapon"] = "Arme"
L["Weapon Enchant"] = "Enchantement d'arme"
L["Whisper"] = "Chuchoter"
L["Width"] = "Largeur"
L["Wobble"] = "Osciller"
L["World Boss"] = "Boss de Monde"
--[[Translation missing --]]
L["World Bosses"] = "World Bosses"
L["Wrap"] = "Emballage, absorbe"
--[[Translation missing --]]
L["Wrath of the Lich King"] = "Wrath of the Lich King"
--[[Translation missing --]]
L["Writing to the WeakAuras table is not allowed."] = "Writing to the WeakAuras table is not allowed."
L["X-Offset"] = "Décalage X"
L["Yell"] = "Crier"
L["Y-Offset"] = "Décalage Y"
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
L["Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."] = "Votre menace sur le monstre en pourcentage du montant requis pour attirer l'aggro. Monte l'aggro à 100."
L["Your total threat on the mob."] = "Votre menace totale sur le monstre."
L["Zone Group ID"] = "Zone Groupe ID"
L["Zone ID"] = "Zone ID"
L["Zone Name"] = "Nom de la zone"
L["Zoom"] = "Zoom"
--[[Translation missing --]]
L["Zoom Animation"] = "Zoom Animation"
L["Zul'Gurub"] = "Zul'Gurub"
--[[Translation missing --]]

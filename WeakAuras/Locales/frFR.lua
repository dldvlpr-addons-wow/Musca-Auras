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
L["Casts the game marks as important. Unknown while the spell is secret: the filter then hides the cast."] = "Incantations que le jeu marque comme importantes. Inconnu tant que le sort est secret : le filtre masque alors l'incantation."
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
L["Secret Restrictions Active"] = "Restrictions secrètes actives"
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
L["%s: tracks an aura that turns secret in combat. Change the trigger type to Aura (Modern)."] = "%s : suit une aura qui devient secrète en combat. Passe le type de déclencheur en Aura (Modern)."
L["%s: %s may not work in combat (secret values)."] = "%s : %s peut ne pas marcher en combat (valeurs secrètes)."
L["%s: casts of units other than the player or the pet cannot be read, in or out of combat."] = "%s : les sorts lancés par une autre unité que le joueur ou son familier sont illisibles, en combat comme hors combat."
L["%s calls %s, which does not exist on WoW Forever."] = "%s appelle %s, qui n'existe pas sur WoW Forever."
L["%s calls %s, which does not exist on WoW Forever. Musca-Auras replaces it."] = "%s appelle %s, qui n'existe pas sur WoW Forever. Musca-Auras la remplace."
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
L["Show CD of Charge"] = "Afficher le Temps de Recharge de la charge"
L["Show GCD"] = "Afficher GCD"
L["Show Global Cooldown"] = "Afficher le Temps de Recharge Global"
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

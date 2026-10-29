if not WeakAuras.IsLibsOK() then return end

if (GAME_LOCALE or GetLocale()) ~= "frFR" then
  return
end

local L = WeakAuras.L

-- WeakAuras/Options
	L["%s number(s) left out: a number is only replaced by a number."] = "%s nombre(s) écarté(s) : un nombre n'est remplacé que par un nombre."
	L[" and |cFFFF0000mirrored|r"] = "et  |cFFFF0000mirrored|r"
	L["%s (%s filter)"] = "%s (filtre %s)"
	L["%s (rendered by the game client)"] = "%s (affiché par le client du jeu)"
	L["-- Do not remove this comment, it is part of this aura: "] = "-- Ne supprimez pas ce commentaire, il fait partie de cette aura :"
	L[" rotated |cFFFF0000%s|r degrees"] = "degrés de |cFFFF0000%s|r  rotation"
	L["% - To show a percent sign"] = "% - Pour afficher un signe de pourcentage"
	L["% of Progress"] = "% de progression"
	L["%.2f ms per second, longest run %.2f ms, during the last profiling. /wa pstart starts a new one."] = "%.2f ms par seconde, plus long passage %.2f ms, pendant le dernier profilage. /wa pstart en lance un nouveau."
	L["%s could not be archived and is not deleted."] = "%s n'a pas pu être archivée et n'est pas supprimée."
	L["%d |4aura:auras; added"] = "%d |4aura:auras; ajoutée(s)"
	L["%d |4aura:auras; deleted"] = "%d |4aura:auras; supprimée(s)"
	L["%d |4aura:auras; modified"] = "%d |4aura:auras; modifiée(s)"
	L["%d |4aura:auras; with meta data modified"] = "%d |4aura:auras; avec métadonnées modifiées"
	L["%d displays loaded"] = "%d affichages chargés"
	L["%d displays not loaded"] = "%d affichages non chargé"
	L["%d displays on standby"] = "%d affichages en attente"
	L["%i auras selected"] = "%i auras sélectionnées"
	L["%i."] = "%i."
	L["%i. %s"] = "%i. %s"
	L["%s - %i. Trigger"] = "%s - %i. Déclencheur"
	L["%s - Alpha Animation"] = "%s - Opacité de l'animation"
	L["%s - Color Animation"] = "%s - Couleur de l'animation"
	L["%s - Condition Custom Chat %s"] = "%s - Condition personnalisée du chat %s"
	L["%s - Condition Custom Check %s"] = "%s - Condition vérifiée du chat %s"
	L["%s - Condition Custom Code %s"] = "%s - Code de condition personnalisé %s"
	L["%s - Custom Anchor"] = "%s - Ancre personnalisée"
	L["%s - Custom Grow"] = "%s - Surbrillance personnalisée"
	L["%s - Custom Sort"] = "%s - Sort personnalisé"
	L["%s - Custom Text"] = "%s - Texte personnalisé"
	L["%s - Finish"] = "%s - Terminer"
	L["%s - Finish Action"] = "%s - Termine l'action"
	L["%s - Finish Custom Text"] = "%s - Terminer le texte personnalisé"
	L["%s - Init Action"] = "%s - Initialiser l'action"
	L["%s - Main"] = "%s - Principal"
	L["%s - OnLoad"] = "%s - Au chargement"
	L["%s - OnUnload"] = "%s - Au déchargement"
	L["%s - Option #%i has the key %s. Please choose a different option key."] = "%s - L'option #%i est actuellement attribuée à la touche %s. Veuillez choisir une touche différente."
	L["%s - Rotate Animation"] = "%s - Rotation de l'animation"
	L["%s - Scale Animation"] = "%s - Animation de l'échelle"
	L["%s - Start"] = "%s - Démarrer"
	L["%s - Start Action"] = "%s - Démarrer une action"
	L["%s - Start Custom Text"] = "%s - Démarrer un texte personnalisé"
	L["%s - Translate Animation"] = "%s - Traduire l'animation"
	L["%s - Trigger Logic"] = "%s - Logique du déclencheur"
	L["%s %s, Lines: %d, Frequency: %0.2f, Length: %d, Thickness: %d"] = "%s %s, Lignes : %d, Fréquence : %0.2f, Longueur : %d, Épaisseur : %d"
	L["%s %s, Particles: %d, Frequency: %0.2f, Scale: %0.2f"] = "%s %s, Particules : %d, Fréquence : %0.2f, Échelle : %0.2f"
	L["%s %u. Overlay Function"] = "%s %u. Fonction de superposition"
	L["%s (%s)"] = "%s (%s)"
	L["%s Alpha: %d%%"] = "%s Opacité : %d%%"
	L["%s Color"] = "%s Couleur"
	L["%s Custom Variables"] = "%s Variables personnalisées"
	L["%s Default Alpha, Zoom, Icon Inset, Aspect Ratio"] = "%s Opacité par défaut, Zoom, Marge de l’icône, Rapport d’aspect"
	L["%s Duration Function"] = "%s Durée de la fonction"
	L["%s Icon Function"] = "%s Fonction de l’icône"
	L["%s Inset: %d%%"] = "%s Insérer : %d%%"
	L["%s is not a valid SubEvent for COMBAT_LOG_EVENT_UNFILTERED"] = "%s n’est pas un sous-événement valide pour COMBAT_LOG_EVENT_UNFILTERED"
	L["%s Keep Aspect Ratio"] = "%s Conserver les proportions"
	L["%s Name Function"] = "%s Nom de la fonction"
	--[[Translation missing --]]
	L["%s Stacks Function"] = "%s Stacks Function"
	L["%s stores around %s KB of data"] = "%s stocke environ %s Ko de données"
	L["%s Texture"] = "%s texture"
	L["%s Texture Function"] = "%s Texture de la fonction"
	L["%s total auras"] = "%s auras au total"
	L["%s Trigger Function"] = "%s Fonction de déclenchement"
	L["%s Untrigger Function"] = "%s Fonction d’annulation du déclencheur"
	L["%s X offset by %d"] = "%s Décalage horizontal de %d"
	L["%s Y offset by %d"] = "%s Décalage vertical de %d"
	L["%s Zoom: %d%%"] = "%s Zoom: %d%%"
	L["%s, Border"] = "%s, Bordure"
	L["%s, Offset: %0.2f;%0.2f"] = "%s, Décaler: %0.2f;%0.2f"
	L["%s, offset: %0.2f;%0.2f"] = "%s, décaler: %0.2f;%0.2f"
	L["%s, Start Animation"] = "%s, Démarrer l’animation"
	L["%s|cFFFF0000custom|r texture with |cFFFF0000%s|r blend mode%s%s"] = "%s|cFFFF0000custom|r texture avec |cFFFF0000%s|r mode fusionné%s%s"
	L["(Right click to rename)"] = "(Clic-Droit pour renommer)"
	L["Add Detached %s"] = "Ajouter %s détaché"
	L["Add to new Modern Aura Group"] = "Ajouter à un nouveau groupe d'auras modernes"
	L["added"] = "ajouté"
	L["Adds an element that stays visible on the display while Aura (Modern) draws the auras."] = "Ajoute un élément qui reste visible sur l'affichage pendant qu'Aura (moderne) dessine les auras."
	L["Adds the spell IDs of a buff tracked by the Cooldown Manager."] = "Ajoute les ID de sort d'une amélioration suivie par le gestionnaire de temps de recharge."
	L["Alpha (%)"] = "Opacité (%)"
	L["Also allows auras normally returned only for nameplate displays. Other filters still apply."] = "Autorise aussi les auras normalement renvoyées uniquement pour l'affichage des barres de vie. Les autres filtres restent appliqués."
	L["Also track the pets of the group members."] = "Suit aussi les familiers des membres du groupe."
	L["Animation Duration"] = "Durée de l'animation"
	L["Applied out of combat; unchecking restores the original opacity."] = "Appliqué hors combat ; décocher rétablit l'opacité d'origine."
	L["Approximate Match"] = "Correspondance approximative"
	L["Approximates the selected spell ID based on its duration and other learned information."] = "Approxime l'ID de sort sélectionné d'après sa durée et d'autres informations apprises."
	L["Aura (Modern)"] = "Aura (moderne)"
	L["Aura (Modern) Settings"] = "Paramètres d'Aura (moderne)"
	L["Aura Active"] = "Aura active"
	L["Aura Filters"] = "Filtres d'aura"
	L["Aura growth direction"] = "Direction de croissance des auras"
	L["Aura Missing"] = "Aura manquante"
	L["Aura Set"] = "Jeu d'auras"
	L["Out of the aura set of this character: %s"] = "Hors du jeu d'auras de ce personnage : %s"
	L["Aura set of this character: the tag of the auras it loads. Empty: all auras."] = "Jeu d'auras de ce personnage : le tag des auras qu'il charge. Vide : toutes les auras."
	L["Aura spacing"] = "Espacement des auras"
	L["Blizzard CDM Entries"] = "Entrées du CDM de Blizzard"
	L["Blizzard CDM Filters"] = "Filtres du CDM de Blizzard"
	L["Blizzard controls aura visibility. Use a condition from another trigger to send chat messages."] = "Blizzard contrôle la visibilité des auras. Utilisez une condition d'un autre déclencheur pour envoyer des messages de discussion."
	L["Blizzard Default"] = "Par défaut (Blizzard)"
	L["Blizzard-controlled aura display: only supported actions are available."] = "Affichage d'aura contrôlé par Blizzard : seules les actions prises en charge sont disponibles."
	L["Blizzard: Buff"] = "Blizzard : amélioration"
	L["Blizzard: Debuff"] = "Blizzard : affaiblissement"
	L["Blizzard: Dispellable"] = "Blizzard : dissipable"
	L["Buff and Debuff use your filters. Blizzard Classification also applies Blizzard's unit-frame visibility and dispel rules, so some auras may be hidden."] = "Amélioration et affaiblissement utilisent vos filtres. La classification Blizzard applique aussi les règles de visibilité des cadres d'unité et de dissipation de Blizzard ; certaines auras peuvent donc être masquées."
	L["Buff or Debuff"] = "Amélioration ou affaiblissement"
	L["Cast value checks:"] = "Vérifications des valeurs d'incantation :"
	L["Caster unit checks:"] = "Vérifications du lanceur :"
	L["CDM Dispel Type Icon"] = "Icône du type de dissipation du CDM"
	L["Character stat checks:"] = "Vérifications des statistiques du personnage :"
	L["Charge count checks:"] = "Vérifications du nombre de charges :"
	L["Charge recharge"] = "Recharge de charge"
	L["Chooses a tag for this character: it then loads only the auras with this tag, or whose group has it.\nThe other characters keep their own choice."] = "Choisit un tag pour ce personnage : il ne charge plus que les auras qui portent ce tag, elles-mêmes ou par leur groupe.\nLes autres personnages gardent leur propre choix."
	L["Class colours"] = "Couleurs de classe"
	L["Color by Dispel Type"] = "Couleur selon le type de dissipation"
	L["Comma separated. Type #tag in the search box to list the auras with this tag."] = "Séparés par des virgules. Tapez #tag dans la recherche pour lister les auras qui portent ce tag."
	L["Cooldown time checks:"] = "Vérifications du temps de recharge :"
	L["Detached %s"] = "%s détaché"
	L["Dispel Type Border"] = "Encadrement du type de dissipation"
	L["Dispel Type Icon %s"] = "Icône du type de dissipation %s"
	L["elapsed"] = "écoulé"
	L["Elapsed Time"] = "Temps écoulé"
	L["Enter a non-negative number of seconds."] = "Saisissez un nombre de secondes positif ou nul."
	L["Enter a non-negative whole number."] = "Saisissez un nombre entier positif ou nul."
	L["Enter a number of seconds above 0."] = "Saisissez un nombre de secondes supérieur à 0."
	L["Enter a number of seconds, 0 or more."] = "Saisissez un nombre de secondes, 0 ou plus."
	L["Enter a positive whole-number Item ID."] = "Saisissez un ID d'objet entier positif."
	L["Enter a positive whole-number Spell ID."] = "Saisissez un ID de sort entier positif."
	L["Enter a Spell ID or a spell name to track all ranks of that spell. A name is replaced by the IDs of all its ranks."] = "Saisissez un ID de sort ou un nom de sort pour suivre tous les rangs de ce sort. Un nom est remplacé par les ID de tous ses rangs."
	L["Enter a unit such as party1, raid5, boss1 or arena2."] = "Saisissez une unité telle que party1, raid5, boss1 ou arena2."
	L["Enter a whole number from 0 to %d."] = "Saisissez un nombre entier de 0 à %d."
	L["Enter character names separated by commas. Include both the first name and surname, keeping the space between them. Capitalization does not matter. Only group members whose names are available to addons can match."] = "Saisissez des noms de personnages séparés par des virgules. Indiquez le prénom et le nom de famille, en gardant l'espace entre les deux. La casse n'a pas d'importance. Seuls les membres du groupe dont le nom est accessible aux addons peuvent correspondre."
	L["Exact Item ID(s)"] = "ID d'objet exact(s)"
	L["Exact Spell ID or Name"] = "ID ou nom de sort exact"
	L["Exclude dispel types"] = "Exclure des types de dissipation"
	L["Extra Options:"] = "Options supplémentaires :"
	L["Extra space around the unit frame. Zero follows its edges."] = "Espace supplémentaire autour du cadre d'unité. Zéro suit ses bords."
	L["Favourites"] = "Favoris"
	L["Filters active auras using readable CDM stack counts. Missing stack counts, or counts the game hides, do not match. All enabled filters must match."] = "Filtre les auras actives selon les nombres de piles lisibles du CDM. Les nombres de piles absents, ou cachés par le jeu, ne correspondent pas. Tous les filtres activés doivent correspondre."
	L["Filters active, timed auras using readable CDM %s time. Missing and permanent timers, or timers the game hides, do not match."] = "Filtre les auras actives à durée selon le temps %s lisible du CDM. Les minuteurs absents, permanents ou cachés par le jeu ne correspondent pas."
	L["Filters with the aura categories of the game. They work in combat too: without a name or spell ID filter and any other filter, auras applied in combat show, with the icon, timer and stack text drawn by the game."] = "Filtre avec les catégories d'aura du jeu. Ils fonctionnent aussi en combat : sans filtre de nom ou d'ID de sort ni autre filtre, les auras appliquées en combat s'affichent, avec l'icône, le minuteur et le texte de piles dessiné par le jeu."
	L["Find in all auras: a spell ID or name, a texture, a font or a sound."] = "Chercher dans toutes les auras : un ID ou nom de sort, une texture, une police ou un son."
	L["Find in the selected auras: a spell ID or name, a texture, a font or a sound."] = "Chercher dans les auras sélectionnées : un ID ou nom de sort, une texture, une police ou un son."
	L["From the Cooldown Manager"] = "Depuis le gestionnaire de temps de recharge"
	L["Glow Anchored Unit Frame"] = "Faire briller le cadre d'unité ancré"
	L["Group Roles"] = "Rôles du groupe"
	L["Guide:"] = "Guide :"
	L["Hardcoded text. Use Conditions from other triggers to show, hide or change this message."] = "Texte fixe. Utilisez les conditions d'autres déclencheurs pour afficher, masquer ou modifier ce message."
	L["Healer"] = "Soigneur"
	L["Health value checks and calculations:"] = "Vérifications et calculs des valeurs de santé :"
	L["Hide Blizzard's CDM"] = "Masquer le CDM de Blizzard"
	L["Hide Frozen Value Padlock"] = "Masquer le cadenas de valeur figée"
	L["Hide GCD text"] = "Masquer le texte du GCD"
	L["Hide global cooldown text"] = "Masquer le texte du temps de recharge global"
	L["Hide this member's auras while it is dead or a ghost."] = "Masquer les auras de ce membre tant qu'il est mort ou fantôme."
	L["Hide this member's auras while it is offline."] = "Masquer les auras de ce membre tant qu'il est hors ligne."
	L["Hides GCD countdown numbers, including %p and %t text. Spell cooldown and charge recharge text remain visible while the GCD swipe is shown."] = "Masque les chiffres du compte à rebours du GCD, y compris le texte %p et %t. Le texte du temps de recharge des sorts et de la recharge des charges reste visible tant que le balayage du GCD est affiché."
	L["Ignored Spell ID or Name"] = "ID ou nom de sort ignoré"
	L["Ignored while the progress source is not an Aura (Modern) trigger."] = "Ignoré tant que la source de progression n'est pas un déclencheur Aura (moderne)."
	L["In combat, an Aura trigger keeps its last state and a padlock shows on the aura. Hides this padlock."] = "En combat, un déclencheur Aura garde son dernier état et un cadenas s'affiche sur l'aura. Masque ce cadenas."
	L["Include dispel types"] = "Inclure des types de dissipation"
	L["Include nameplate-only auras"] = "Inclure les auras réservées aux barres de vie"
	L["Is"] = "Est"
	L["Is Not"] = "N'est pas"
	L["Item ID"] = "ID d'objet"
	L["Join the Musca Auras Discord server."] = "Rejoignez le serveur Discord de Musca Auras."
	L["Keep border thickness and offset in screen pixels, regardless of UI or parent scale. Use a size of 1 for a one-pixel border."] = "Conserve l'épaisseur et le décalage de l'encadrement en pixels d'écran, quelle que soit l'échelle de l'interface ou du parent. Utilisez une taille de 1 pour un encadrement d'un pixel."
	L["Keep this trigger active while there is no such unit. Otherwise it is inactive then, so other triggers can supply the display."] = "Garde ce déclencheur actif tant qu'aucune unité de ce type n'existe. Sinon il est inactif, ce qui permet à d'autres déclencheurs de fournir l'affichage."
	L["Learn everything about WeakAuras on WoW Forever: how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import."] = "Tout apprendre sur WeakAuras dans WoW Forever : fonctionnement d'une aura, changements en combat, ce qui marche ou non, recettes pas à pas et auras prêtes à importer."
	L["learn WeakAuras"] = "apprendre WeakAuras"
	L["Legacy Auras rarely function in combat as most are Blizzard-controlled."] = "Les auras classiques fonctionnent rarement en combat, car la plupart sont contrôlées par Blizzard."
	L["Maximum auras"] = "Nombre maximal d'auras"
	L["Maximum auras per unit. Drag up to 40, or type a larger number."] = "Nombre maximal d'auras par unité. Faites glisser jusqu'à 40, ou saisissez un nombre plus grand."
	L["Minutes and seconds"] = "Minutes et secondes"
	L["Modern Aura Group"] = "Groupe d'auras modernes"
	L["Modern Aura Group Settings"] = "Paramètres du groupe d'auras modernes"
	L["Musca Auras Guide"] = "Guide de Musca Auras"
	L["Musca Auras: WoW Forever 1.60 port by dldvlpr, based on WeakAuras by The WeakAuras Team."] = "Musca Auras : portage pour WoW Forever 1.60 par dldvlpr, basé sur WeakAuras de The WeakAuras Team."
	L["Name of the aura"] = "Nom de l'aura"
	L["The game's own aura layout uses a fixed text area."] = "La disposition d'aura propre au jeu utilise une zone de texte fixe."
	L["Game Categories"] = "Catégories du jeu"
	L["New group for Aura (Modern) displays: laid out left to right, 2 pixels apart, with the layout kept in combat."] = "Nouveau groupe pour les affichages Aura (moderne) : disposés de gauche à droite, espacés de 2 pixels, avec la disposition conservée en combat."
	L["Next"] = "Suivant"
	L["Next Active Trigger"] = "Prochain déclencheur actif"
	L["Nothing equal to \"%s\"."] = "Rien n'est égal à \"%s\"."
	L["Not %s"] = "Pas %s"
	L["Not available in On Show/On Hide for Aura (Modern) auras. Sound files are supported; live TTS and custom callbacks are not."] = "Indisponible à l'affichage ou au masquage pour les auras Aura (moderne). Les fichiers son sont pris en charge ; la synthèse vocale en direct et les rappels personnalisés ne le sont pas."
	L["Not Usable"] = "Inutilisable"
	L["Note: Trigger Always Active"] = "Note : déclencheur toujours actif"
	L["Number of stacks"] = "Nombre de piles"
	L["One aura is shown, chosen by Sort by under Aura (Modern) Settings in Display."] = "Une seule aura est affichée, choisie par Trier par dans Paramètres d'Aura (moderne), sous Affichage."
	L["Only match auras Blizzard marks for display on all nameplates. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura."] = "Ne correspond qu'aux auras que Blizzard marque pour un affichage sur toutes les barres de vie. Ceci vérifie l'indicateur de barre de vie de Blizzard. Cela ne change ni l'emplacement de l'icône ni le lanceur de l'aura."
	L["Only match auras marked for Blizzard's personal-debuff display on nameplates. This does not refer to your personal resource bar. This checks Blizzard's nameplate flag. It does not change where the icon appears or who cast the aura."] = "Ne correspond qu'aux auras marquées pour l'affichage des affaiblissements personnels de Blizzard sur les barres de vie. Cela ne concerne pas votre barre de ressource personnelle. Ceci vérifie l'indicateur de barre de vie de Blizzard. Cela ne change ni l'emplacement de l'icône ni le lanceur de l'aura."
	L["Only show this trigger's auras while you have a target you can attack. Applies to all selected entries and all Show modes."] = "N'affiche les auras de ce déclencheur que lorsque vous avez une cible attaquable. S'applique à toutes les entrées sélectionnées et à tous les modes d'affichage."
	L["Only track members with the selected assigned group roles. This also limits configured aura sounds. Player-name and role filters must both match when enabled."] = "Ne suit que les membres ayant les rôles de groupe assignés sélectionnés. Cela limite aussi les sons d'aura configurés. Les filtres de nom de joueur et de rôle doivent tous deux correspondre lorsqu'ils sont activés."
	L["Only track these group members. This also limits which units can play configured aura sounds."] = "Ne suit que ces membres du groupe. Cela limite aussi les unités pouvant jouer les sons d'aura configurés."
	L["Open CDM"] = "Ouvrir le CDM"
	L["Other ranks could not be found for: %s. Only the IDs you entered will be tracked. To track another rank, add its ID under Exact Spell ID(s)."] = "Les autres rangs sont introuvables pour : %s. Seuls les ID saisis seront suivis. Pour suivre un autre rang, ajoutez son ID sous Correspondance exacte de l'ID du/des sort(s)."
	L["Padding"] = "Marge"
	L["party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 or arena1-5."] = "party1-4, partypet1-4, raid1-40, raidpet1-40, boss1-8 ou arena1-5."
	L["Pixel Perfect"] = "Pixel parfait"
	L["Play when one of the trigger's exact spell IDs is %s. Works even if Blizzard cannot display the aura. Uses the selected unit and exact spell IDs, excluding ignored IDs; other display filters do not affect sounds."] = "Joue lorsqu'un des ID de sort exacts du déclencheur est %s. Fonctionne même si Blizzard ne peut pas afficher l'aura. Utilise l'unité sélectionnée et les ID de sort exacts, hors ID ignorés ; les autres filtres d'affichage n'affectent pas les sons."
	L["Player Name(s)"] = "Nom(s) de joueur"
	L["Player Names"] = "Noms des joueurs"
	L["Power value checks and calculations:"] = "Vérifications et calculs des valeurs de puissance :"
	L["Pulse Glow"] = "Brillance pulsante"
	L["Recent colours"] = "Couleurs récentes"
	L["Refresh from Blizzard CDM"] = "Actualiser depuis le CDM de Blizzard"
	L["remaining"] = "restant"
	L["removed"] = "retiré"
	L["Replace"] = "Remplacer"
	L["Replace %s value(s) in %s aura(s)? Undo reverts it."] = "Remplacer %s valeur(s) dans %s aura(s) ? Annuler les rétablit."
	L["Replace \"%s\" with:"] = "Remplacer \"%s\" par :"
	L["Replaces a spell, a texture, a font or a sound in the selected auras, or in all auras when none is selected.\nThe changes are shown in the chat before the confirmation, and Undo reverts them."] = "Remplace un sort, une texture, une police ou un son dans les auras sélectionnées, ou dans toutes les auras si aucune n'est sélectionnée.\nLes changements s'affichent dans le chat avant la confirmation, et Annuler les rétablit."
	L["Require attackable target"] = "Exiger une cible attaquable"
	L["Reverse Sort"] = "Inverser le tri"
	L["Reverse the selected order. For Remaining time, later expirations and permanent auras come first."] = "Inverse l'ordre sélectionné. Pour Remaining time, les expirations les plus tardives et les auras permanentes passent en premier."
	L["Right-click to favourite"] = "Clic droit pour ajouter aux favoris"
	L["Right-click to remove"] = "Clic droit pour retirer"
	L["Save favourite"] = "Enregistrer en favori"
	L["Search"] = "Rechercher"
	L["In combat, the game hides some values of this trigger. The aura can display them but cannot compare them, so some features may not work in combat."] = "En combat, le jeu cache certaines valeurs de ce déclencheur. L'aura peut les afficher mais pas les comparer, donc certaines fonctions peuvent ne pas marcher en combat."
	L["The game hides the spells cast by units other than you or your pet, in or out of combat. This trigger cannot read them."] = "Le jeu cache les sorts lancés par d'autres unités que vous ou votre familier, en combat comme hors combat. Ce déclencheur ne peut pas les lire."
	L["Selected value checks:"] = "Vérifications des valeurs sélectionnées :"
	L["Sets the Cooldown Manager viewers to zero opacity. They stay shown, so aura tracking is unaffected."] = "Règle l'opacité des fenêtres du gestionnaire de temps de recharge à zéro. Elles restent affichées, le suivi des auras n'est donc pas affecté."
	L["Share one display per unit between the auras of this group, and start a new line after a set number of auras."] = "Partage un affichage par unité entre les auras de ce groupe, et commence une nouvelle ligne après un nombre d'auras défini."
	L["Show Dispel Type Icon"] = "Afficher l'icône du type de dissipation"
	L["Show global cooldown"] = "Afficher le temps de recharge global"
	L["Show only available"] = "Afficher seulement les disponibles"
	L["Show only max rank"] = "Afficher seulement le rang maximal"
	L["Show the auras on each unit's frame or nameplate. The Position and Size settings place them on the frame."] = "Affiche les auras sur le cadre ou la barre de vie de chaque unité. Les réglages Position and Size Settings les placent sur le cadre."
	L["Shows a resizable border coloured by dispel type."] = "Affiche un encadrement redimensionnable coloré selon le type de dissipation."
	L["Shows the dispel type of a Cooldown Manager buff trigger."] = "Affiche le type de dissipation d'un déclencheur d'amélioration du gestionnaire de temps de recharge."
	L["Shows the dispel type of the aura"] = "Affiche le type de dissipation de l'aura"
	L["Shows the dispel type of the aura shown. During combat restrictions, a circle in the dispel type color replaces the icon."] = "Affiche le type de dissipation de l'aura affichée. Pendant les restrictions de combat, un cercle de la couleur du type de dissipation remplace l'icône."
	L["Snaps the textures of this aura to the screen pixels: sharp edges, but progress and slides move by whole pixels."] = "Aligne les textures de cette aura sur les pixels de l'écran : bords nets, mais la progression et les glissements avancent pixel par pixel."
	L["Sort by"] = "Trier par"
	L["Sort each unit's auras. Remaining time puts the soonest-expiring aura first, with permanent auras last. Blizzard priority applies caster and priority rules before time or name. Unit-frame debuffs also enables debuff classification, which can hide auras."] = "Trie les auras de chaque unité. Remaining time place en premier l'aura qui expire le plus tôt, les auras permanentes en dernier. Blizzard priority applique les règles de lanceur et de priorité avant le temps ou le nom. Unit-frame debuffs active aussi la classification des affaiblissements, ce qui peut masquer des auras."
	L["Space reserved for each aura's text. Set its width in Font Flags."] = "Espace réservé au texte de chaque aura. Réglez sa largeur dans Font Flags."
	L["Spell count checks:"] = "Vérifications du nombre de sorts :"
	L["Spell ID or Name"] = "ID ou nom de sort"
	L["Spell ID(s) (All Ranks)"] = "ID de sort (tous les rangs)"
	L["Spells must be active in the CDM to be displayed. Type /cdm and add them."] = "Les sorts doivent être actifs dans le CDM pour être affichés. Tapez /cdm et ajoutez-les."
	L["Stagger value checks and calculations:"] = "Vérifications et calculs des valeurs de report :"
	L["Style the glow on the anchored unit frame."] = "Définit le style de la brillance sur le cadre d'unité ancré."
	L["Swipe Color"] = "Couleur du balayage"
	L["Tags"] = "Tags"
	L["Tank"] = "Tank"
	L["Text Area Height"] = "Hauteur de la zone de texte"
	L["The most auras each display shows."] = "Le nombre maximal d'auras affichées par chaque affichage."
	L["The name of this character cannot be read here, try again out of the instance."] = "Le nom de ce personnage n'est pas lisible ici, réessayez hors de l'instance."
	L["The number of auras on each line."] = "Le nombre d'auras par ligne."
	L["The order of the auras inside each display."] = "L'ordre des auras à l'intérieur de chaque affichage."
	L["The trigger's Show On or Remaining Time shows one aura in this display's position. Sort by chooses which aura when several match."] = "Afficher sur ou Temps restant du déclencheur montre une aura à la position de cet affichage. Trier par choisit laquelle quand plusieurs correspondent."
	L["Threat checks:"] = "Vérifications de la menace :"
	L["Time left on the aura"] = "Temps restant sur l'aura"
	L["Time since the aura was applied. Auras without duration never match."] = "Temps écoulé depuis l'application de l'aura. Les auras sans durée ne correspondent jamais."
	L["total"] = "total"
	L["Track cooldowns"] = "Suivre les temps de recharge"
	L["Trigger that supplies Dynamic Information while no aura passes the Aura (Modern) filters."] = "Déclencheur qui fournit les informations dynamiques tant qu'aucune aura ne passe les filtres d'Aura (moderne)."
	L["Unassigned"] = "Non assigné"
	L["Unit frame glows set from Display > Aura (Modern) Settings are removed too. Aura (Modern) glows also stop once no aura matches or the display unloads."] = "Les brillances de cadre d'unité définies depuis Affichage > Paramètres d'Aura (moderne) sont aussi retirées. Les brillances d'Aura (moderne) s'arrêtent aussi quand plus aucune aura ne correspond ou que l'affichage se décharge."
	L["Unit identity checks:"] = "Vérifications de l'identité de l'unité :"
	L["Unknown Item"] = "Objet inconnu"
	L["Unknown spell name. Enter its Spell ID, or its exact name as shown in the game."] = "Nom de sort inconnu. Saisissez son ID de sort, ou son nom exact tel qu'affiché dans le jeu."
	L["Usable"] = "Utilisable"
	L["Usable checks Blizzard's spell requirements, including reactive abilities and resources. It does not replace cooldown or range checks. If usability is unavailable, neither usability mode matches."] = "Utilisable vérifie les prérequis de sort de Blizzard, y compris les capacités réactives et les ressources. Cela ne remplace pas les vérifications de temps de recharge ou de portée. Si l'utilisabilité est indisponible, aucun des deux modes d'utilisabilité ne correspond."
	L["Use %p for duration, %s for stacks or %n for the aura name. Each code needs its own text element. Literal text is also supported."] = "Utilisez %p pour la durée, %s pour les piles ou %n pour le nom de l'aura. Chaque code nécessite son propre élément de texte. Le texte littéral est aussi pris en charge."
	L["Use Unit Frames anchoring in Display. The frame glows while any aura matches your filters and stops automatically. Exact Spell IDs are not required."] = "Utilisez l'ancrage Cadre d'unité dans Affichage. Le cadre brille tant qu'une aura correspond à vos filtres et s'arrête automatiquement. Les ID de sort exacts ne sont pas requis."
	L["Uses Blizzard's assigned group role. Members without a role assigned match Unassigned."] = "Utilise le rôle de groupe assigné par Blizzard. Les membres sans rôle assigné correspondent à Non assigné."
	L["Uses the dispel type color of the aura shown, and the border color when it has none."] = "Utilise la couleur du type de dissipation de l'aura affichée, et la couleur de l'encadrement quand elle n'en a pas."
	L["Values to replace, listed above:"] = "Valeurs à remplacer, listées ci-dessus :"
	L["When Aura (Modern) Filters Are Not Met, Use"] = "Quand les filtres d'Aura (moderne) ne sont pas remplis, utiliser"
	L["You cannot control clones with an Aura (Modern). Use the Aura (Modern) Settings under Display."] = "Vous ne pouvez pas contrôler les clones avec une Aura (moderne). Utilisez les paramètres d'Aura (moderne) sous Affichage."
	L["|c%02x%02x%02x%02xCustom Color|r"] = "|c%02x%02x%02x%02xCouleur personnalisée|r"
	L["|cff999999Triggers tracking multiple units will default to being active even while no affected units are found without a Unit Count or Match Count setting applied.|r"] = "|cff999999Les déclencheurs suivant plusieurs unités seront actifs par défaut même si aucune unité affectée n’est trouvée, sauf si un paramètre de nombre d’unités ou de correspondances est appliqué.|r"
	L["|cFFE0E000Note:|r This sets the description only on '%s'"] = "|cFFE0E000Note:|r Ceci définit la description uniquement sur '%s'"
	L["|cFFE0E000Note:|r This sets the URL on all selected auras"] = "|cFFE0E000Note:|r Ceci définit l'URL sur toutes les auras sélectionnées"
	L["|cFFE0E000Note:|r This sets the URL on this group and all its members."] = "|cFFE0E000Note:|r Ceci définit l'URL sur ce groupe et tous ses membres."
	L["|cFFFF0000Automatic|r length"] = "|cFFFF0000Automatic|r longueur"
	L["|cFFFF0000default|r texture"] = "|cFFFF0000default|r texture"
	L["|cFFFF0000desaturated|r "] = "|cFFFF0000desaturated|r"
	L["|cFFFF0000Note:|r The unit '%s' is not a trackable unit."] = "|cFFFF0000Note:|r Cette unité '%s' n'est pas une unité traçable."
	L["|cFFFF0000Note:|r The unit '%s' requires soft target cvars to be enabled."] = "|cFFFF0000Remarque :|r L’unité « %s » nécessite que les cvars de ciblage souple soient activées."
	L["|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r"] = "|cFFffcc00Ancrages :|r Ancré |cFFFF0000%s|r au cadre de |cFFFF0000%s|r"
	L["|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"] = "|cFFffcc00Ancrages :|r Ancré |cFFFF0000%s|r au cadre de ... |cFFFF0000%s|r avec un décalage de |cFFFF0000%s/%s|r"
	L["|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r"] = "|cFFffcc00Ancrages :|r Ancré au cadre de |cFFFF0000%s|r"
	L["|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"] = "|cFFffcc00Ancrages :|r Ancré au cadre de ... |cFFFF0000%s|r avec un décalage de |cFFFF0000%s/%s|r"
	L["|cFFffcc00Extra Options:|r"] = "|cFFffcc00Options supplémentaires :|r"
	L["|cFFffcc00Extra:|r %s and %s %s"] = "|cFFffcc00Extra:|r %s et %s %s"
	--[[Translation missing --]]
	L["|cFFffcc00Font Flags:|r"] = "|cFFffcc00Font Flags:|r"
	--[[Translation missing --]]
	L["|cFFffcc00Font Flags:|r none"] = "|cFFffcc00Font Flags:|r none"
	L["|cffffcc00Format Options|r"] = "|cffffcc00Options de formatage|r"
	L["|cffffd100Aura (Modern)|r: works in combat. Timer, stacks and glow. Text limited to %p, %s and %n, sub elements limited to Text, Texture, Border and Glow. Icon, Progress Bar, Progress Texture and Text auras only.\n|cffffd100Aura|r: out of combat or advanced conditions. In combat, the game hides most auras and they stop updating."] = "|cffffd100Aura (moderne)|r : fonctionne en combat. Minuteur, piles et brillance. Texte limité à %p, %s et %n, sous-éléments limités à Texte, Texture, Encadrement et Brillance. Auras Icône, Barre de progression, Texture de progression et Texte uniquement.\n|cffffd100Aura|r : hors combat ou conditions avancées. En combat, le jeu cache la plupart des auras et elles cessent de se mettre à jour."
	L[ [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.
• |cffffff00Multi-target|r attempts to use the Combat Log events, rather than unitID, to track affected units.
|cffff0000Note|r: Without a direct relationship to actual unitIDs, results may vary.

|cffffff00*|r Yellow Unit settings can match multiple units and will default to being active even while no affected units are found without a Unit Count or Match Count setting.]=] ] = "• |cff00ff00Joueur|r, |cff00ff00Cible|r, |cff00ff00Focalisation|r et |cff00ff00Familier|r correspondent directement à ces identifiants d’unité (unitIDs) individuels. • |cff00ff00Unité spécifique|r permet d’indiquer un identifiant d’unité valide à surveiller. |cffff0000Remarque|r : Le jeu ne déclenche pas d’événements pour tous les identifiants d’unité valides, ce qui rend certains non détectables par ce déclencheur. • |cffffff00Groupe|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arène|r et |cffffff00Plaque de nom|r peuvent correspondre à plusieurs identifiants d’unité associés. • |cffffff00Groupe intelligent|r s’adapte à votre type de groupe actuel : il correspond uniquement au \"joueur\" en solo, aux unités \"groupe\" (y compris \"joueur\") en groupe, ou aux unités \"raid\" en raid. • |cffffff00Cibles multiples|r tente d’utiliser les événements du journal de combat (Combat Log), plutôt que les unitIDs, pour suivre les unités affectées. |cffff0000Remarque|r : En l’absence de lien direct avec des unitIDs réels, les résultats peuvent varier. |cffffff00\\*|r Les paramètres d’unité en jaune peuvent correspondre à plusieurs unités et seront actifs par défaut même si aucune unité affectée n’est détectée, sauf si un paramètre de nombre d’unités ou de correspondance est défini."
	L["A 20x20 pixels icon"] = "Une icône de 20x20 pixels"
	L["A 32x32 pixels icon"] = "Une icône de 32x32 pixels"
	L["A 40x40 pixels icon"] = "Une icône de 40x40 pixels"
	L["A 48x48 pixels icon"] = "Une icône de 48x48 pixels"
	L["A 64x64 pixels icon"] = "Une icône de 64x64 pixels"
	L["A group that dynamically controls the positioning of its children"] = "Un groupe qui contrôle dynamiquement le positionnement de ses enfants"
	L[ [=[A timer will automatically be displayed according to default Interface Settings (overridden by some addons).
Enable this setting if you want this timer to be hidden, or when using a WeakAuras text to display the timer]=] ] = "Une minuterie sera automatiquement affichée selon les paramètres d'interface par défaut (remplacés par certains addons). Activez ce paramètre si vous souhaitez que le minuteur soit masqué, ou si vous utilisez plutôt un texte WeakAuras pour afficher le minuteur."
	L["A Unit ID (e.g., party1)."] = "Un ID d'unité (par exemple, groupe1)."
	L["Ace: Funkeh, Nevcairiel"] = "Ace : Funkeh, Nevcairiel"
	L["Active Aura Filters and Info"] = "Filtres et infos des auras actives"
	L["Add %s"] = "Ajouter %s"
	L["Add a new display"] = "Ajouter un nouvel affichage"
	L["Add Condition"] = "Ajouter une Condition"
	L["Add Entry"] = "Ajouter une entrée"
	L["Add Extra Elements"] = "Ajouter des éléments supplémentaires"
	L["Add Option"] = "Ajouter une option"
	L["Add Overlay"] = "Ajouter un Overlay"
	L["Add Property Change"] = "Ajouter un Changement de Propriété"
	L["Add Snippet"] = "Ajouter un extrait"
	L["Add Sub Option"] = "Ajouter une sous-option"
	L["Add to group %s"] = "Ajouter au groupe %s"
	L["Add to new Dynamic Group"] = "Ajouter à un nouveau groupe dynamique"
	L["Add to new Group"] = "Ajouter à un nouveau groupe"
	L["Add Trigger"] = "Ajouter un déclencheur"
	L["Additional Events"] = "Événements supplémentaires"
	L["Advanced"] = "Avancé"
	--[[Translation missing --]]
	L["Affected Unit Filters and Info"] = "Affected Unit Filters and Info"
	L["Align"] = "Aligner"
	--[[Translation missing --]]
	L["Aligned left"] = "Aligned left"
	--[[Translation missing --]]
	L["Aligned right"] = "Aligned right"
	L["Alignment"] = "Alignement"
	L["All maintainers of the libraries we use, especially:"] = "Tous les mainteneurs des bibliothèques que nous utilisons, en particulier :"
	L["All of"] = "Tous vos"
	L["Allow Full Rotation"] = "Autoriser la rotation complète"
	L["Anchor"] = "Ancrage"
	L["Anchor Mode"] = "Mode d’ancrage"
	L["Anchor Point"] = "Point d'ancrage"
	L["Anchored To"] = "Ancré à"
	L["And "] = "Et"
	L["and"] = "et"
	L["and %s"] = "et %s"
	L["And our Patreons, Discord Regulars and Subscribers, and Friends of the Addon:"] = "Et nos Patreon, habitués de Discord, abonnés et amis de l’addon :"
	L["and rotated left"] = "et tourné vers la gauche"
	L["and rotated right"] = "et tourné vers la droite"
	--[[Translation missing --]]
	L["and shadow |c%sColor|r with offset |cFFFF0000%s/%s|r"] = "and shadow |c%sColor|r with offset |cFFFF0000%s/%s|r"
	--[[Translation missing --]]
	L["and smooth scaling"] = "and smooth scaling"
	L["and with width |cFFFF0000%s|r and %s"] = "et avec une largeur de |cFFFF0000%s|r et %s"
	L["Angle"] = "Angle"
	L["Angle Between Auras"] = "Angle entre les auras"
	L["Animate"] = "Animer"
	L["Animated Expand and Collapse"] = "Expansion et réduction animés"
	L["Animates progress changes"] = "Animer les changement de progression"
	L["Animation End"] = "Fin de l'animation"
	L["Animation Mode"] = "Mode d’animation"
	L["Animation relative duration description"] = [=[La durée de l'animation par rapport à la durée du graphique, exprimée en fraction (1/2), pourcentage (50%), ou décimal (0.5).
|cFFFF0000Note :|r si un graphique n'a pas de progression (déclencheur d'événement sans durée définie, aura sans durée, etc), l'animation ne jouera pas.

|cFF4444FFPar exemple :|r
Si la durée de l'animation est définie à |cFF00CC0010%|r, et le déclencheur du graphique est une amélioration qui dure 20 secondes, l'animation de début jouera pendant 2 secondes.
Si la durée de l'animation est définie à |cFF00CC0010%|r, et le déclencheur du graphique n'a pas de durée définie, aucune d'animation de début ne jouera (mais elle jouerait si vous aviez spécifié une durée en secondes).
]=]
	L["Animation Sequence"] = "Séquence d'animation"
	L["Animation Start"] = "Démarrer l'animation"
	L["Any of"] = "Un de"
	L["Apply Template"] = "Appliquer le modèle"
	L["Area"] = "Zone"
	L["At a position a bit left of Left HUD position."] = "Une position à gauche de la Position ATH Gauche."
	L["At a position a bit left of Right HUD position"] = "Une position à droite de la Position ATH Droite."
	L["At the same position as Blizzard's spell alert"] = "À la même position que l'alerte de sort de Blizzard"
	L["Attach to Foreground"] = "Attacher au premier plan"
	L[ [=[Aura is
Off Screen]=] ] = "L’aura est hors écran"
	L["Aura (Modern) does not apply this effect."] = "Aura (Modern) n'applique pas cet effet."
	L["Aura Name Pattern"] = "Modèle de Nom de l'Aura"
	L["Aura Order"] = "Ordre des auras"
	L["Aura received from: %s"] = "Aura reçue de : %s"
	L["The aura stops updating in combat once the game hides it. Switch to classic mode?"] = "L'aura ne se met plus à jour en combat dès que le jeu la cache. Passer en mode classique ?"
	L["Aura: '%s'"] = "Aura : '%s'"
	L["Auras to Import"] = "Auras à importer"
	L["Auto-Clone (Show All Matches)"] = "Clonage Automatique (Afficher tous les résultats)"
	L["Automatic length"] = "Longueur automatique"
	L["Backdrop Color"] = "Couleur de Fond"
	L["Backdrop in Front"] = "Fond Devant"
	L["Backdrop Style"] = "Style de Fond"
	--[[Translation missing --]]
	L["Background Inner"] = "Background Inner"
	L["Background Offset"] = "Décalage du Fond "
	L["Background Texture"] = "Texture d'arrière plan"
	L["Bar Alpha"] = "Opacité de la barre"
	L["Bar Color Settings"] = "Paramètres de la barre de couleur"
	L["Big Icon"] = "Grande icône"
	L["Blend Mode"] = "Mode du fusion"
	L["Border %s"] = "Encadrement %s"
	L["Border Anchor"] = "Ancrage de l'encadrement"
	L["Border Color"] = "Couleur de l'encadrement"
	L["Border in Front"] = "Bordure Devant"
	L["Border Inset"] = "Encart Fond"
	L["Border Offset"] = "Décalage Bordure"
	L["Border Settings"] = "Paramètres de l'encadrement"
	L["Border Size"] = "Taille de l'encadrement"
	L["Border Style"] = "Style d'encadrement"
	L["Bracket Matching"] = "Crochet Correspondant"
	L["Browse Wago, the largest collection of auras."] = "Parcourez Wago, la plus grande collection d'auras."
	--[[Translation missing --]]
	L["By default this shows the information from the trigger selected via dynamic information. The information from a specific trigger can be shown via e.g. %2.p."] = "By default this shows the information from the trigger selected via dynamic information. The information from a specific trigger can be shown via e.g. %2.p."
	L["Can be a UID (e.g., party1)."] = "Peut être un UID (par exemple, groupe1)."
	--[[Translation missing --]]
	L["Can set to 0 if Columns * Width equal File Width"] = "Can set to 0 if Columns * Width equal File Width"
	--[[Translation missing --]]
	L["Can set to 0 if Rows * Height equal File Height"] = "Can set to 0 if Rows * Height equal File Height"
	--[[Translation missing --]]
	L["Case Insensitive"] = "Case Insensitive"
	--[[Translation missing --]]
	L["Cast by a Player Character"] = "Cast by a Player Character"
	--[[Translation missing --]]
	L["Categories to Update"] = "Categories to Update"
	--[[Translation missing --]]
	L["Changelog"] = "Changelog"
	L["Changes the Aura (Modern) triggers of this aura to Aura, which unlocks the greyed out options."] = "Change les déclencheurs Aura (Modern) de cette aura en Aura, ce qui débloque les options grisées."
	L["Check On..."] = "Vérifier sur..."
	L["Check out our wiki for a large collection of examples and snippets."] = "Consultez notre wiki pour trouver une grande collection d'exemples et d'extraits."
	L["Children Conditions"] = "Conditions des enfants"
	L["Children:"] = "Enfant :"
	L["Choose"] = "Choisir"
	--[[Translation missing --]]
	L["Circular Texture %s"] = "Circular Texture %s"
	--[[Translation missing --]]
	L["Clear Debug Logs"] = "Clear Debug Logs"
	--[[Translation missing --]]
	L["Clear Saved Data"] = "Clear Saved Data"
	--[[Translation missing --]]
	L["Click to replace the name with %s."] = "Click to replace the name with %s."
	L["Clip Overlays"] = "Superposition de l'attache "
	--[[Translation missing --]]
	L["Clipped by Foreground"] = "Clipped by Foreground"
	L["Close"] = "Fermer"
	--[[Translation missing --]]
	L["Code Editor"] = "Code Editor"
	L["Collapse"] = "Réduire"
	L["Collapse all loaded displays"] = "Réduire tous les affichages chargés"
	L["Collapse all non-loaded displays"] = "Réduire tous les affichage non-chargés"
	--[[Translation missing --]]
	L["Collapse all pending Import"] = "Collapse all pending Import"
	--[[Translation missing --]]
	L["Collapsible Group"] = "Collapsible Group"
	L["color"] = "couleur"
	L["Column Height"] = "Hauteur de colonne"
	L["Column Space"] = "Espace de colonne"
	L["Columns"] = "Colonnes"
	--[[Translation missing --]]
	L["COMBAT_LOG_EVENT_UNFILTERED with no filter can trigger frame drops in raid environment."] = "COMBAT_LOG_EVENT_UNFILTERED with no filter can trigger frame drops in raid environment."
	L["Combinations"] = "Combinaisons"
	L["Combine Matches Per Unit"] = "Combiner toutes les Correspondances Par Unité"
	L["Common Text"] = "Texte commun"
	L["Compare against the number of units affected."] = "Comparer contre le nombre d'unités affectées."
	L["Compatibility Options"] = "Options de compatibilité"
	L["Compress"] = "Compresser"
	L["Configure what options appear on this panel."] = "Configurez les options qui apparaissent sur ce panneau."
	L["Constant Factor"] = "Facteur constant"
	L["Control-click to select multiple displays"] = "Ctrl-Clic pour sélectionner plusieurs affichages"
	L["Controls the positioning and configuration of multiple displays at the same time"] = "Contrôle la position et la configuration de plusieurs affichages en même temps"
	L["Convert to..."] = "Convertir en..."
	--[[Translation missing --]]
	L["Cooldown Numbers might be added by WoW. You can configure these in the game settings."] = "Cooldown Numbers might be added by WoW. You can configure these in the game settings."
	L["Copy"] = "Copier"
	L["Copy Condition"] = "Copier la condition"
	L["Copy settings..."] = "Copier les paramètres..."
	L["Copy to all auras"] = "Copier toutes les auras"
	L["Copy Trigger"] = "Copier le déclencheur"
	--[[Translation missing --]]
	L["Could not parse '%s'. Expected a table."] = "Could not parse '%s'. Expected a table."
	L["Counts the number of matches over all units."] = "Comptes de tout le nombre de correspondances sur toutes les unités."
	--[[Translation missing --]]
	L["Counts the number of matches per unit."] = "Counts the number of matches per unit."
	L["CPU Cost"] = "Coût CPU"
	--[[Translation missing --]]
	L["Create a Copy"] = "Create a Copy"
	L["Creating buttons: "] = "Création de boutons :"
	L["Creating options: "] = "Création d'options :"
	--[[Translation missing --]]
	L["Custom - Allows you to define a custom Lua function that returns a list of string values. %c1 will be replaced by the first value returned, %c2 by the second, etc."] = "Custom - Allows you to define a custom Lua function that returns a list of string values. %c1 will be replaced by the first value returned, %c2 by the second, etc."
	L["Custom Code"] = "Code personnalisé"
	--[[Translation missing --]]
	L["Custom Code Viewer"] = "Custom Code Viewer"
	L["Custom Frames"] = "Cadres personnalisés"
	--[[Translation missing --]]
	L["Custom Functions"] = "Custom Functions"
	--[[Translation missing --]]
	L["Custom Init"] = "Custom Init"
	--[[Translation missing --]]
	L["Custom Load"] = "Custom Load"
	L["Custom Options"] = "Options personnalisées"
	L["Custom Text Update Throttle"] = "Délai de mise à jour du texte personnalisé"
	L["Custom Trigger"] = "Déclencheur personnalisé"
	L["Custom trigger event tooltip"] = [=[
Choisissez quels évènements peuvent activer le déclencheur.
Plusieurs évènements peuvent être spécifiés avec des virgules ou des espaces.

|cFF4444FFPar exemple:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
	L["Custom trigger status tooltip"] = [=[
Choisissez quels évènements peuvent activer le déclencheur.
Comme c'est un déclencheur de type statut, les évènements spécifiés peuvent être appelés par WeakAuras sans les arguments attendus.
Plusieurs évènements peuvent être spécifiés avec des virgules ou des espaces.

|cFF4444FFPar exemple:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
	L["Custom trigger Update Throttle"] = "Délai de mise à jour du déclencheur personnalisé"
	--[[Translation missing --]]
	L["Custom Trigger: Ignore Lua Errors on OPTIONS event"] = "Custom Trigger: Ignore Lua Errors on OPTIONS event"
	--[[Translation missing --]]
	L["Custom Trigger: Send fake events instead of STATUS event"] = "Custom Trigger: Send fake events instead of STATUS event"
	--[[Translation missing --]]
	L["Custom Unload"] = "Custom Unload"
	L["Custom Untrigger"] = "Désactivation personnalisée"
	--[[Translation missing --]]
	L["Debug Log"] = "Debug Log"
	--[[Translation missing --]]
	L["Debug Log:"] = "Debug Log:"
	L["Default"] = "Par défaut"
	L["Default Color"] = "Couleur par défaut"
	--[[Translation missing --]]
	L["Delay"] = "Delay"
	L["Delete"] = "Supprimer"
	L["Delete all"] = "Supprimer tout"
	L["Delete children and group"] = "Supprimer enfants et groupe"
	L["Delete Entry"] = "Supprimer l'entrée"
	L["Deletes the auras no character of the account loaded for 30 days, and the empty groups.\nThe list is shown in the chat before the confirmation."] = "Supprime les auras qu'aucun personnage du compte n'a chargées depuis 30 jours, et les groupes vides.\nLa liste s'affiche dans le chat avant la confirmation."
	--[[Translation missing --]]
	L["Deleting auras: "] = "Deleting auras: "
	L["Description Text"] = "Texte de Description"
	--[[Translation missing --]]
	L["Determines how many entries can be in the table."] = "Determines how many entries can be in the table."
	L["Differences"] = "Différences"
	--[[Translation missing --]]
	L["Disallow Entry Reordering"] = "Disallow Entry Reordering"
	--[[Translation missing --]]
	L["Discord"] = "Discord"
	L["Display Name"] = "Nom de l'affichage"
	L["Display Text"] = "Afficher le texte"
	L["Displays a text, works best in combination with other displays"] = "Affiche du texte, fonctionne mieux en combinaison avec d'autres affichages."
	L["Distribute Horizontally"] = "Distribuer horizontalement"
	L["Distribute Vertically"] = "Distribuer verticalement"
	L["Do not group this display"] = "Ne pas grouper cet affichage"
	--[[Translation missing --]]
	L["Do you want to enable updates for this aura"] = "Do you want to enable updates for this aura"
	--[[Translation missing --]]
	L["Do you want to ignore updates for this aura"] = "Do you want to ignore updates for this aura"
	L["Documentation"] = "Documentation"
	L["Done"] = "Terminé"
	L["Drag to move"] = "Glisser pour déplacer"
	L["Duplicate"] = "Doubler"
	L["Duplicate All"] = "Doubler Tout"
	L["Duration (s)"] = "Durée (s)"
	L["Duration Info"] = "Info de durée"
	L["Dynamic Duration"] = "Durée Dynamique"
	L["Dynamic Group"] = "Groupe Dynamique"
	L["Dynamic Group Settings"] = "Paramètres des groupes dynamiques"
	L["Dynamic Information"] = "Information Dynamique"
	L["Dynamic information from first active trigger"] = "Information dynamique depuis le premier déclencheur"
	L["Dynamic information from Trigger %i"] = "Information dynamique du Déclencheur %i"
	--[[Translation missing --]]
	L["Dynamic Text Replacements"] = "Dynamic Text Replacements"
	--[[Translation missing --]]
	L["Ease Strength"] = "Ease Strength"
	--[[Translation missing --]]
	L["Ease type"] = "Ease type"
	--[[Translation missing --]]
	L["eliding"] = "eliding"
	--[[Translation missing --]]
	L["Else If"] = "Else If"
	--[[Translation missing --]]
	L["Else If %s"] = "Else If %s"
	--[[Translation missing --]]
	L["Empty Base Region"] = "Empty Base Region"
	--[[Translation missing --]]
	L["Enable \"Edge\" part of the overlay"] = "Enable \"Edge\" part of the overlay"
	L["Enable \"swipe\" part of the overlay"] = "Activer la partie \"balayage\" de la superposition"
	--[[Translation missing --]]
	L["Enable Debug Log"] = "Enable Debug Log"
	--[[Translation missing --]]
	L["Enable Debug Logging"] = "Enable Debug Logging"
	--[[Translation missing --]]
	L["Enable Gradient"] = "Enable Gradient"
	L["Enable Swipe"] = "Activer le balayage"
	L["Enable the \"Swipe\" radial overlay"] = "Activer la superposition radiale du \"balayage\""
	L["Enabled"] = "Activé"
	L["End Angle"] = "Angle de fin"
	L["End of %s"] = "Fin de %s"
	--[[Translation missing --]]
	L["Enemy nameplate(s) found"] = "Enemy nameplate(s) found"
	--[[Translation missing --]]
	L["Enter a Spell ID. You can use the addon idTip to determine spell ids."] = "Enter a Spell ID. You can use the addon idTip to determine spell ids."
	L["Enter an Aura Name, partial Aura Name, or Spell ID. A Spell ID will match any spells with the same name."] = "Saisissez un nom d'aura, un nom d'aura partiel ou un ID de sort. L'ID d'un sort correspondra à tous les sorts portant le même nom."
	L["Enter Author Mode"] = "Entrer en mode auteur"
	--[[Translation missing --]]
	L["Enter in a value for the tick's placement."] = "Enter in a value for the tick's placement."
	--[[Translation missing --]]
	L["Enter static or relative values with %"] = "Enter static or relative values with %"
	L["Enter User Mode"] = "Entrer en mode utilisateur"
	L["Enter user mode."] = "Entrer en mode utilisateur"
	--[[Translation missing --]]
	L["Entry %i"] = "Entry %i"
	--[[Translation missing --]]
	L["Entry limit"] = "Entry limit"
	--[[Translation missing --]]
	L["Entry Name Source"] = "Entry Name Source"
	L["Event Type"] = "Type d'évènement"
	L["Everything"] = "Tous"
	L["Exact Item Match"] = "Correspondance exacte de l'objet"
	L["Exact Spell Match"] = "Correspondance exacte du sort"
	L["Expand"] = "Agrandir"
	L["Expand all loaded displays"] = "Agrandir tous affichages chargés"
	L["Expand all non-loaded displays"] = "Agrandir tous affichage non-chargés"
	--[[Translation missing --]]
	L["Expand all pending Import"] = "Expand all pending Import"
	L["Expansion is disabled because this group has no children"] = "L'expansion est désactivée car ce groupe n'a pas d'enfants"
	--[[Translation missing --]]
	L["Export debug table..."] = "Export debug table..."
	--[[Translation missing --]]
	L["Export..."] = "Export..."
	--[[Translation missing --]]
	L["Exporting"] = "Exporting"
	L["External"] = "Externe"
	--[[Translation missing --]]
	L["Extra Height"] = "Extra Height"
	--[[Translation missing --]]
	L["Extra Width"] = "Extra Width"
	L["Fade"] = "Fondu"
	--[[Translation missing --]]
	L["Fadeout Sound"] = "Fadeout Sound"
	--[[Translation missing --]]
	L["Fadeout Time (seconds)"] = "Fadeout Time (seconds)"
	--[[Translation missing --]]
	L["Fetch Affected/Unaffected Names and Units"] = "Fetch Affected/Unaffected Names and Units"
	--[[Translation missing --]]
	L["Fetch Raid Mark Information"] = "Fetch Raid Mark Information"
	--[[Translation missing --]]
	L["Fetch Role Information"] = "Fetch Role Information"
	--[[Translation missing --]]
	L["Fetch Tooltip Information"] = "Fetch Tooltip Information"
	--[[Translation missing --]]
	L["File Height"] = "File Height"
	--[[Translation missing --]]
	L["File Width"] = "File Width"
	--[[Translation missing --]]
	L["Filter based on the spell Name string."] = "Filter based on the spell Name string."
	L["Filter by Class"] = "Filtrer par Classe"
	L["Filter by Group Role"] = "Filtrer par rôle de groupe"
	--[[Translation missing --]]
	L["Filter by Hostility"] = "Filter by Hostility"
	--[[Translation missing --]]
	L["Filter by Npc ID"] = "Filter by Npc ID"
	L["Filter by Raid Role"] = "Filtrer par rôle de raid"
	--[[Translation missing --]]
	L["Filter by Unit Name"] = "Filter by Unit Name"
	--[[Translation missing --]]
	L[ [=[Filter formats: 'Name', 'Name-Realm', '-Realm'.

Supports multiple entries, separated by commas
Can use \ to escape -.]=] ] = [=[Filter formats: 'Name', 'Name-Realm', '-Realm'.

Supports multiple entries, separated by commas
Can use \ to escape -.]=]
	--[[Translation missing --]]
	L["Filter to only dispellable de/buffs of the given type(s)"] = "Filter to only dispellable de/buffs of the given type(s)"
	--[[Translation missing --]]
	L["Find Auras"] = "Find Auras"
	L["Finish"] = "Finir"
	--[[Translation missing --]]
	L["Finishing..."] = "Finishing..."
	--[[Translation missing --]]
	L["Flat Framelevels"] = "Flat Framelevels"
	L["Foreground Texture"] = "Texture premier-plan"
	L["Format for %s"] = "Format pour %s"
	L["Found a Bug?"] = "Signaler un bug"
	L["Frame"] = "Cadre"
	--[[Translation missing --]]
	L["Frame Count"] = "Frame Count"
	--[[Translation missing --]]
	L["Frame Height"] = "Frame Height"
	--[[Translation missing --]]
	L["Frame Rate"] = "Frame Rate"
	L["Frame Strata"] = "Strate du cadre"
	--[[Translation missing --]]
	L["Frame Width"] = "Frame Width"
	--[[Translation missing --]]
	L["Full Bar"] = "Full Bar"
	L["Full Circle"] = "Cercle Complet"
	L["Full UI pack for your class: rotation, cooldowns, buffs and resources, ready to play"] = "Pack d'interface complet pour ta classe : rotation, temps de recharge, améliorations et ressources, prêt à jouer"
	L["Packs"] = "Packs"
	L["Class HUD"] = "HUD de classe"
	L["Whole HUD"] = "Tout le HUD"
	L["Whole HUD updates every block to the pack settings. A single block leaves the other installed blocks as they are."] = "Tout le HUD remet chaque bloc aux réglages du pack. Un seul bloc laisse les autres blocs installés tels quels."
	L["Reminders"] = "Rappels"
	L["Warns when a class buff is missing or fading, or when your resource runs low"] = "Prévient quand un buff de classe manque ou s'estompe, ou quand ta ressource est basse"
	L["Melee Range"] = "Portée de mêlée"
	L["Red text when your target is out of melee range, in combat"] = "Texte rouge quand ta cible est hors de portée de mêlée, en combat"
	L["Procs"] = "Procs"
	L["Lights up when a proc or a reactive ability can be used"] = "S'allume quand un proc ou une technique réactive est utilisable"
	L["Buffs and Debuffs"] = "Buffs et debuffs"
	L["Your buffs, and your debuffs on the target, with their time left"] = "Tes buffs, et tes debuffs sur la cible, avec leur temps restant"
	L["Stack Segments"] = "Segments de cumuls"
	L["One segment per stack of a key buff"] = "Un segment par cumul d'un buff clé"
	L["Combo Points"] = "Points de combo"
	L["Combo points as pips above the resource bar"] = "Les points de combo en pastilles au-dessus de la barre de ressource"
	L["Resource Bars"] = "Barres de ressource"
	L["Mana, rage or energy bar, plus the form bar for druids"] = "Barre de mana, de rage ou d'énergie, plus la barre de forme pour les druides"
	L["Rotation"] = "Rotation"
	L["Rotation spells with their cooldown, in a grid"] = "Les sorts de rotation avec leur temps de recharge, en grille"
	L["Cooldowns"] = "Temps de recharge"
	L["Utility and defensive cooldowns, trinkets and racials"] = "Temps de recharge utilitaires et défensifs, bijoux et raciaux"
	L["Timer Bars"] = "Barres de temps"
	L["Cast bar and target cast, plus the swing timer, pet health or five second rule of your class"] = "Barre d'incantation et incantation de la cible, plus le temps de frappe, la vie du familier ou la règle des cinq secondes selon la classe"
	L["Upkeep"] = "Entretien"
	L["Long buffs and weapon enchants to keep up"] = "Buffs longs et enchantements d'arme à maintenir"
	L["Totems"] = "Totems"
	L["Your four totem slots with their time left and their buffs"] = "Tes quatre emplacements de totem avec leur temps restant et leurs buffs"
	L["Combat"] = "Combat"
	L["Group and Buffs"] = "Groupe et buffs"
	L["Target and Enemies"] = "Cible et ennemis"
	L["Character"] = "Personnage"
	L["Utility Packs"] = "Packs utilitaires"
	L["Ready Flash"] = "Sort prêt"
	L["Buff Check"] = "Contrôle des buffs"
	L["Target Debuffs"] = "Debuffs de la cible"
	L["Pre-Pull Check"] = "Prêt au pull"
	L["Nameplate Aggro"] = "Aggro des barres de nom"
	L["Shield Meter"] = "Jauge de bouclier"
	L["Crowd Control"] = "Contrôles de foule"
	L["Armor Shred"] = "Réduction d'armure"
	L["Enemy Targets"] = "Cibles ennemies"
	L["Center Mark"] = "Repère central"
	L["Level Progress"] = "Progression de niveau"
	L["Raid Coverage"] = "Couverture des buffs"
	L["Combat Items"] = "Objets de combat"
	L["Flashes a cooldown, a racial or a trinket the moment it is ready"] = "Fait clignoter un temps de recharge, un racial ou un bijou dès qu'il est prêt"
	L["Group buffs on you out of combat, missing ones in grey"] = "Buffs de groupe sur toi hors combat, ceux qui manquent en gris"
	L["Raid debuffs on your target in combat, missing ones in grey"] = "Debuffs de raid sur ta cible en combat, ceux qui manquent en gris"
	L["Flask and food missing or fading before the pull"] = "Flacon et nourriture absents ou qui s'estompent avant le pull"
	L["Your threat percent above each enemy nameplate"] = "Ton pourcentage de menace au-dessus de chaque barre de nom ennemie"
	L["Damage shields on you with their remaining time"] = "Boucliers d'absorption sur toi avec leur temps restant"
	L["Crowd control on each enemy nameplate with its countdown"] = "Contrôles sur chaque barre de nom ennemie avec leur décompte"
	L["Sunder Armor and Expose Armor under each enemy nameplate"] = "Fracasser armure et Exposer l'armure sous chaque barre de nom ennemie"
	L["The target of each enemy above its nameplate, in combat"] = "La cible de chaque ennemi au-dessus de sa barre de nom, en combat"
	L["A dot at the center of the screen in combat"] = "Un point au centre de l'écran en combat"
	L["Experience bar with rested experience below level 60"] = "Barre d'expérience avec l'expérience reposée sous le niveau 60"
	L["How many group members carry each raid buff, out of combat"] = "Nombre de membres du groupe qui portent chaque buff de raid, hors combat"
	L["Potions, stones and explosives in your bags with their cooldown, in combat"] = "Potions, pierres et explosifs de tes sacs avec leur temps de recharge, en combat"
	L["World"] = "Monde"
	L["Engineering Items"] = "Objets d'ingénieur"
	L["Conjured Supplies"] = "Eau et nourriture invoquées"
	L["Character Stats"] = "Stats du personnage"
	L["World Reminders"] = "Rappels du monde"
	L["Campfire"] = "Feu de camp"
	L["Cloaking device and rocket boots while equipped, grey on cooldown"] = "Dispositif de camouflage et bottes-fusées quand ils sont équipés, en gris pendant le temps de recharge"
	L["Mage only: conjured water and food in your bags with their count, out of combat"] = "Mage seulement : eau et nourriture invoquées de tes sacs avec leur nombre, hors combat"
	L["Strength, agility, stamina, intellect, spirit, attack and spell power, crit, dodge and armor, out of combat"] = "Force, agilité, endurance, intelligence, esprit, puissance d'attaque et des sorts, critique, esquive et armure, hors combat"
	L["Leyline zone buffs missing or fading, and herb or mineral tracking off, out of combat"] = "Buffs de la zone des lignes telluriques absents ou qui s'estompent, et repérage des herbes ou des minerais coupé, hors combat"
	L["Tells you to sit by a campfire while its buff is missing or fading, click to sit, with a sound when it comes in"] = "T'invite à t'asseoir près d'un feu de camp quand son buff manque ou s'estompe, un clic pour t'asseoir, avec un son quand il arrive"
	L["Combat Text"] = "Texte de combat"
	L["Announcements"] = "Annonces"
	L["Group Experience"] = "Expérience du groupe"
	L["Equipment Sets"] = "Ensembles d'équipement"
	L["Guild Campfires"] = "Feux de camp de la guilde"
	L["Object Highlight"] = "Objets en surbrillance"
	L["Hits and heals you take stack up beside you; turns on the game's damage numbers for the damage you deal"] = "Les coups et les soins reçus s'empilent à côté de toi ; active les chiffres de dégâts du jeu pour les dégâts que tu infliges"
	L["Tells your group about your battle rez, soulstone and summon, and whispers the rezzed player"] = "Annonce au groupe ta résurrection en combat, ta pierre d'âme et ton invocation, et chuchote au joueur ressuscité"
	L["Level and experience of the group members who also run this pack"] = "Niveau et expérience des membres du groupe qui utilisent aussi ce pack"
	L["One icon per equipment set, grey when not worn; click to equip, out of combat"] = "Une icône par ensemble d'équipement, en gris quand il n'est pas porté ; un clic l'équipe, hors combat"
	L["Shows where a guild member who runs this pack just placed a campfire on your map, and sends yours"] = "Montre où un membre de la guilde qui utilise ce pack vient de poser un feu de camp sur ta carte, et envoie les tiens"
	L["Turns on the game's interaction icons over herbs, veins and chests; they stay on after removing the pack"] = "Active les icônes d'interaction du jeu sur les herbes, les filons et les coffres ; elles restent actives après le retrait du pack"
	L["Global Conditions"] = "Conditions globales"
	L["Glow %s"] = "Faire briller %s"
	L["Glow Action"] = "Action de la brillance"
	L["Glow Anchor"] = "Ancre de la brillance"
	L["Glow Color"] = "Couleur de la brillance"
	L["Glow Frame Type"] = "Type de cadre brillant"
	L["Glow Type"] = "Type de la brillance"
	L["Greyed out options are unavailable with Aura (Modern): the game draws this element itself. Hover an option to see why."] = "Les options grisées sont indisponibles avec Aura (Modern) : le jeu dessine lui-même cet élément. Survolez une option pour voir pourquoi."
	L["Grid direction"] = "Direction de la grille"
	L["Group (verb)"] = "Groupe (verbe)"
	--[[Translation missing --]]
	L["Group Alpha"] = "Group Alpha"
	--[[Translation missing --]]
	L[ [=[Group and anchor each auras by frame.

- Nameplates: attach to nameplates per unit.
- Unit Frames: attach to unit frame buttons per unit.
- Custom Frames: choose which frame each region should be anchored to.]=] ] = [=[Group and anchor each auras by frame.

- Nameplates: attach to nameplates per unit.
- Unit Frames: attach to unit frame buttons per unit.
- Custom Frames: choose which frame each region should be anchored to.]=]
	L["Group aura count description"] = [=[Le nombre de membres du %s qui doivent être affectés par une ou plusieurs des auras sélectionnées pour que l'affichage soit déclenché.
Si le nombre entré est un entier (ex. 5), le nombre de membres du raid affectés sera comparé au nombre entré.
Si le nombre entré est decimal (ex. 0.5), une fraction (ex. 1/2), ou un pourcentage (ex. 50%%), alors cette fraction du %s doit être affectée.

|cFF4444FFPar exemple :|r
|cFF00CC00> 0|r se déclenchera quand n'importe quel membre du %s est affecté
|cFF00CC00= 100%%|r se déclenchera quand tous les membres du %s sont affectés
|cFF00CC00!= 2|r se déclenchera quand le nombre de membres du %s affectés est différent de 2
|cFF00CC00<= 0.8|r se déclenchera quand moins de 80%% du %s est affecté (4 des 5 membres du groupe, 8 des 10 ou 20 des 25 membres du raid )
|cFF00CC00> 1/2|r se déclenchera quand plus de la moitié du %s est affecté
|cFF00CC00>= 0|r se déclenchera toujours, quoi qu'il arrive
]=]
	--[[Translation missing --]]
	L["Group by Frame"] = "Group by Frame"
	L["Group Conditions"] = "Conditions du groupe"
	L["Group Description"] = "Description du groupe"
	L["Group Icon"] = "Icône du groupe"
	--[[Translation missing --]]
	L["Group key"] = "Group key"
	L["Group Options"] = "Options du groupe"
	--[[Translation missing --]]
	L["Group player(s) found"] = "Group player(s) found"
	L["Group Role"] = "Rôle du groupe"
	L["Group Scale"] = "Échelle du Groupe"
	L["Group Settings"] = "Paramètres du groupe"
	L["Hawk"] = "Faucon"
	L["Help"] = "Aide"
	--[[Translation missing --]]
	L["Hide After"] = "Hide After"
	--[[Translation missing --]]
	L["Hide auras on setting show to nil in custom triggers"] = "Hide auras on setting show to nil in custom triggers"
	--[[Translation missing --]]
	L["Hide Background"] = "Hide Background"
	L["Hide Glows applied by this aura"] = "Cacher les brillances appliquées par cette aura"
	L["Hide on"] = "Cacher à"
	L["Hide this group's children"] = "Cacher les enfants de ce groupe"
	--[[Translation missing --]]
	L["Highlights"] = "Highlights"
	L["Horizontal Align"] = "Aligner horizontalement"
	L["Horizontal Bar"] = "Barre horizontale"
	L["Huge Icon"] = "Énorme icône"
	L["Hybrid Position"] = "Position hybride"
	L["Hybrid Sort Mode"] = "Mode de tri hybride"
	--[[Translation missing --]]
	L["Icon - The icon associated with the display"] = "Icon - The icon associated with the display"
	L["Icon Info"] = "Info d'icône"
	L["Icon Inset"] = "Objet inséré"
	--[[Translation missing --]]
	L["Icon Picker"] = "Icon Picker"
	L["Icon Position"] = "Position de l'icône"
	L["Icon Settings"] = "Paramètres de l'icône"
	--[[Translation missing --]]
	L["Icon Source"] = "Icon Source"
	L["If"] = "Si"
	--[[Translation missing --]]
	L["If %s"] = "If %s"
	--[[Translation missing --]]
	L["If checked, then the combo box in the User settings will be sorted."] = "If checked, then the combo box in the User settings will be sorted."
	--[[Translation missing --]]
	L["If checked, then the user will see a multi line edit box. This is useful for inputting large amounts of text."] = "If checked, then the user will see a multi line edit box. This is useful for inputting large amounts of text."
	--[[Translation missing --]]
	L["If checked, then this group will not merge with other group when selecting multiple auras."] = "If checked, then this group will not merge with other group when selecting multiple auras."
	--[[Translation missing --]]
	L["If checked, then this option group can be temporarily collapsed by the user."] = "If checked, then this option group can be temporarily collapsed by the user."
	--[[Translation missing --]]
	L["If checked, then this option group will start collapsed."] = "If checked, then this option group will start collapsed."
	L["If checked, then this separator will include text. Otherwise, it will be just a horizontal line."] = [=[
Si cette case est cochée, ce séparateur inclura du texte. Sinon, ce sera juste une ligne horizontale]=]
	L["If checked, then this space will span across multiple lines."] = "Si cette case est cochée, cet espace s'étendra sur plusieurs lignes."
	L["If unchecked, then a default color will be used (usually yellow)"] = "Si cette case n'est pas cochée, une couleur par défaut sera utilisée (généralement jaune)"
	L["If unchecked, then this space will fill the entire line it is on in User Mode."] = "Si cette case n'est pas cochée, cet espace remplira toute la ligne sur laquelle il se trouve en mode utilisateur."
	L["Ignore out of checking range"] = "Ignorer hors de la plage de vérification"
	--[[Translation missing --]]
	L["Ignore Wago updates"] = "Ignore Wago updates"
	L["Ignored"] = "Ignoré"
	L["Ignored Aura Name"] = "Ignorer par nom d'aura"
	L["Ignored Exact Spell ID(s)"] = "Ignorer par correspondance exacte de l'ID du/des sort(s)"
	L["Ignored Name(s)"] = "Ignorer par nom(s)"
	L["Ignored Spell ID"] = "Ignorer par ID de sort"
	L["Import"] = "Importer"
	--[[Translation missing --]]
	L["Import / Export"] = "Import / Export"
	L["Import a display from an encoded string"] = "Importer un graphique d'un texte encodé"
	--[[Translation missing --]]
	L["Import as Copy"] = "Import as Copy"
	--[[Translation missing --]]
	L["Import has no UID, cannot be matched to existing auras."] = "Import has no UID, cannot be matched to existing auras."
	--[[Translation missing --]]
	L["Importing"] = "Importing"
	--[[Translation missing --]]
	L["Importing %s"] = "Importing %s"
	--[[Translation missing --]]
	L["Importing a group with %s child auras."] = "Importing a group with %s child auras."
	--[[Translation missing --]]
	L["Importing a stand-alone aura."] = "Importing a stand-alone aura."
	--[[Translation missing --]]
	L["Importing...."] = "Importing...."
	--[[Translation missing --]]
	L["Incompatible changes to group region types detected"] = "Incompatible changes to group region types detected"
	--[[Translation missing --]]
	L["Incompatible changes to group structure detected"] = "Incompatible changes to group structure detected"
	L["Incompatible condition: %s"] = "Condition incompatible : %s"
	--[[Translation missing --]]
	L["Indent Size"] = "Indent Size"
	L["Inner"] = "Intérieur"
	--[[Translation missing --]]
	L["Insert text replacement codes to make text dynamic."] = "Insert text replacement codes to make text dynamic."
	--[[Translation missing --]]
	L["Invalid Item ID"] = "Invalid Item ID"
	L["Invalid Item Name/ID/Link"] = "Nom d'objet / ID / lien invalide"
	L["Invalid Spell ID"] = "ID de sort invalide"
	L["Invalid Spell Name/ID/Link"] = "Nom du sort / ID / lien invalide"
	--[[Translation missing --]]
	L["Invalid target aura"] = "Invalid target aura"
	--[[Translation missing --]]
	L["Invalid type for '%s'. Expected 'bool', 'number', 'select', 'string', 'timer' or 'elapsedTimer'."] = "Invalid type for '%s'. Expected 'bool', 'number', 'select', 'string', 'timer' or 'elapsedTimer'."
	L["Invalid type for property '%s' in '%s'. Expected '%s'"] = "Type non valide pour la propriété '%s' dans '%s'. Attendu '%s'."
	L["Inverse Slant"] = "Inclinaison inversée"
	--[[Translation missing --]]
	L["Invert the direction of progress"] = "Invert the direction of progress"
	--[[Translation missing --]]
	L["Is Boss Debuff"] = "Is Boss Debuff"
	L["Is Stealable"] = "Est subtilisable "
	--[[Translation missing --]]
	L["Is Unit"] = "Is Unit"
	L["Justify"] = "Justification"
	L["Keep Aspect Ratio"] = "Conserver les Proportions"
	L["Keep your Wago imports up to date with the Companion App."] = "Gardez vos importations Wago à jour avec l'application Companion."
	--[[Translation missing --]]
	L["Large Input"] = "Large Input"
	L["Leaf"] = "Feuille"
	L["Left 2 HUD position"] = "Position ATH Gauche 2"
	L["Left HUD position"] = "Position ATH Gauche"
	--[[Translation missing --]]
	L["Length of |cFFFF0000%s|r"] = "Length of |cFFFF0000%s|r"
	--[[Translation missing --]]
	L["LibCompress: Galmok"] = "LibCompress: Galmok"
	--[[Translation missing --]]
	L["LibCustomGlow: Dooez"] = "LibCustomGlow: Dooez"
	--[[Translation missing --]]
	L["LibDeflate: Yoursafety"] = "LibDeflate: Yoursafety"
	--[[Translation missing --]]
	--[[Translation missing --]]
	L["LibSerialize: Sanjo"] = "LibSerialize: Sanjo"
	--[[Translation missing --]]
	L["Limit"] = "Limite"
	--[[Translation missing --]]
	L["Line"] = "Line"
	--[[Translation missing --]]
	L["Linear Texture %s"] = "Linear Texture %s"
	--[[Translation missing --]]
	L["Linked aura: "] = "Linked aura: "
	--[[Translation missing --]]
	L["Linked Auras"] = "Linked Auras"
	L["Load"] = "Chargement"
	L["Loaded"] = "Chargé"
	--[[Translation missing --]]
	L["Loaded/Standby"] = "Loaded/Standby"
	L["Lock Positions"] = "Verrouiller"
	L["Low Mana"] = "Mana bas"
	L["Magnetically Align"] = "Aimantation"
	L["Main"] = "Principal"
	--[[Translation missing --]]
	L["Manual with %i/%i"] = "Manual with %i/%i"
	--[[Translation missing --]]
	L["Matches %s spells"] = "Matches %s spells"
	L["Matches the height setting of a horizontal bar or width for a vertical bar."] = "Correspond au paramètre de hauteur d'une barre horizontale ou de largeur pour une barre verticale."
	L["Max"] = "Max"
	L["Max Length"] = "Longueur max"
	--[[Translation missing --]]
	L["Maximum"] = "Maximum"
	--[[Translation missing --]]
	L["Media Type"] = "Media Type"
	L["Medium Icon"] = "Icône moyenne"
	L["Min"] = "Min (minutes?)"
	--[[Translation missing --]]
	L["Minimum"] = "Minimum"
	L["Model %s"] = "Modèle %s"
	--[[Translation missing --]]
	L["Model Picker"] = "Model Picker"
	L["Model Settings"] = "Paramètres du modèle"
	--[[Translation missing --]]
	L["ModelPaths could not be loaded, the addon is %s"] = "ModelPaths could not be loaded, the addon is %s"
	L["Move Above Group"] = "Déplacer au dessus du groupe"
	L["Move Below Group"] = "Déplacer en dessous du grouoe"
	L["Move Down"] = "Déplacer vers le bas"
	L["Move Entry Down"] = "Déplacer l'entrée vers le bas"
	L["Move Entry Up"] = "Déplacer l'entrée vers le haut"
	--[[Translation missing --]]
	L["Move Into Above Group"] = "Move Into Above Group"
	--[[Translation missing --]]
	L["Move Into Below Group"] = "Move Into Below Group"
	L["Move this display down in its group's order"] = "Déplacer cet affichage vers le bas dans l'ordre de son groupe"
	L["Move this display up in its group's order"] = "Déplacer cet affichage vers le haut dans l'ordre de son groupe"
	L["Move Up"] = "Déplacer vers le haut"
	--[[Translation missing --]]
	L["Moving auras: "] = "Moving auras: "
	L["Multiple Displays"] = "Affichages multiples"
	L["Multiselect ignored tooltip"] = "Infobulle ignorée de la sélection multiple"
	L["Multiselect multiple tooltip"] = [=[
|cFF777777Ignoré|r - |cFF777777Unique|r - |cFF00FF00Multiple|r
Plusieurs valeurs peuvent être choisies]=]
	L["Multiselect single tooltip"] = [=[
|cFF777777Ignoré|r - |cFF00FF00Unique|r - |cFF777777Multiple|r
Seule une unique valeur peut être choisie]=]
	--[[Translation missing --]]
	L["Must be a power of 2"] = "Must be a power of 2"
	--[[Translation missing --]]
	L["Name - The name of the display (usually an aura name), or the display's ID if there is no dynamic name"] = "Name - The name of the display (usually an aura name), or the display's ID if there is no dynamic name"
	L["Name Info"] = "Info du nom"
	L["Name Pattern Match"] = "Correspondance de modèle de nom"
	L["Name:"] = "Nom:"
	L["Negator"] = "Pas"
	L["New Aura"] = "Nouvelle aura"
	--[[Translation missing --]]
	L["New Template"] = "New Template"
	L["New Value"] = "Nouvelle Valeur"
	L["No aura unused for %d days. Loads are counted since %s."] = "Aucune aura inutilisée depuis %d jours. Les chargements sont comptés depuis le %s."
	L["No Children"] = "Aucun enfant"
	--[[Translation missing --]]
	L["No Logs saved."] = "No Logs saved."
	L["Not a table"] = "N'est pas une table"
	L["Not all children have the same value for this option"] = "Tous les enfants n'ont pas la même valeur pour cette option"
	L["Not Loaded"] = "Non chargé"
	--[[Translation missing --]]
	L["Note: Automated Messages to SAY and YELL are blocked outside of Instances."] = "Note: Automated Messages to SAY and YELL are blocked outside of Instances."
	--[[Translation missing --]]
	L["Note: This progress source does not provide a total value/duration. A total value/duration must be set via \"Set Maximum Progress\""] = "Note: This progress source does not provide a total value/duration. A total value/duration must be set via \"Set Maximum Progress\""
	L["Number of Entries"] = "Nombre d'entrées"
	--[[Translation missing --]]
	L[ [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3]=] ] = [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3]=]
	--[[Translation missing --]]
	L["OFF"] = "OFF"
	--[[Translation missing --]]
	L["Offer a guided way to create auras for your character"] = "Offer a guided way to create auras for your character"
	--[[Translation missing --]]
	L["Offset by |cFFFF0000%s|r/|cFFFF0000%s|r"] = "Offset by |cFFFF0000%s|r/|cFFFF0000%s|r"
	L["Offset by 1px"] = "Décalage de 1px"
	L["Okay"] = "Okay"
	--[[Translation missing --]]
	L["ON"] = "ON"
	L["On Hide"] = "Au masquage"
	L["On Show"] = "A l'affichage"
	--[[Translation missing --]]
	L["Only Match auras cast by a player (not an npc)"] = "Only Match auras cast by a player (not an npc)"
	--[[Translation missing --]]
	L["Only match auras cast by people other than the player or their pet"] = "Only match auras cast by people other than the player or their pet"
	--[[Translation missing --]]
	L["Only match auras cast by the player or their pet"] = "Only match auras cast by the player or their pet"
	L["Operator"] = "Opérateur"
	L["Option %i"] = "Option %i"
	L["Option key"] = "Clef de l'option"
	L["Option Type"] = "Type d'option"
	L["Options will open after combat ends."] = "Les options s'ouvriront après la fin du combat."
	L["or"] = "ou"
	--[[Translation missing --]]
	L["or %s"] = "or %s"
	--[[Translation missing --]]
	L["Our translators (too many to name)"] = "Our translators (too many to name)"
	L["Outer"] = "Extérieur"
	L["Overflow"] = "Débordement"
	L["Overlay %s Info"] = "%s Infos en Superposition"
	L["Overlays"] = "Superpositions"
	L["Own Only"] = "Le mien uniquement"
	L["Paste Action Settings"] = "Coller les paramètres d'actions"
	L["Paste Animations Settings"] = "Coller les paramètres d'animations"
	L["Paste Author Options Settings"] = "Coller les paramètres des options de l'auteur"
	L["Paste Condition"] = "Coller la condition"
	L["Paste Condition Settings"] = "Coller les paramètres de conditions"
	L["Paste Custom Configuration"] = "Coller les Options personnalisées"
	L["Paste Display Settings"] = "Coller les paramètres d'affichage"
	L["Paste Group Settings"] = "Coller les paramètres du groupe"
	L["Paste Load Settings"] = "Coller les paramètres de chargement"
	L["Paste Settings"] = "Coller les paramètres"
	L["Paste text below"] = "Coller le texte ci-dessous"
	L["Paste Trigger"] = "Coller le déclencheur"
	L["Paste Trigger Settings"] = "Coller les paramètres de déclencheurs"
	--[[Translation missing --]]
	L["Places a tick on the bar"] = "Places a tick on the bar"
	L["Play Sound"] = "Jouer un son"
	--[[Translation missing --]]
	L["Player Spells found:"] = "Player Spells found:"
	L["Portrait Zoom"] = "Zoom Portrait"
	--[[Translation missing --]]
	L["Position and Size Settings"] = "Position and Size Settings"
	--[[Translation missing --]]
	L["Preferred Match"] = "Preferred Match"
	--[[Translation missing --]]
	L["Premade Auras"] = "Premade Auras"
	--[[Translation missing --]]
	L["Premade Snippets"] = "Premade Snippets"
	--[[Translation missing --]]
	L["Preparing auras: "] = "Preparing auras: "
	L["Press Ctrl+C to copy"] = "Appuyer sur Ctrl+C pour copier"
	L["Press Ctrl+C to copy the URL"] = "Appuyer sur Ctrl+C pour copier l'URL"
	--[[Translation missing --]]
	L["Prevent Merging"] = "Prevent Merging"
	--[[Translation missing --]]
	L["Progress - The remaining time of a timer, or a non-timer value"] = "Progress - The remaining time of a timer, or a non-timer value"
	L["Progress Bar"] = "Barre de progression"
	L["Progress Bar Settings"] = "Paramètres de la barre de progression"
	--[[Translation missing --]]
	L["Progress Settings"] = "Progress Settings"
	L["Progress Texture"] = "Texture de progression"
	L["Progress Texture Settings"] = "Paramètres de la texture de progression"
	L["Put this display in a group"] = "Placer cet affichage dans un groupe"
	--[[Translation missing --]]
	L["Range in yards"] = "Range in yards"
	--[[Translation missing --]]
	L["Ready for Install"] = "Ready for Install"
	--[[Translation missing --]]
	L["Ready for Update"] = "Ready for Update"
	L["Re-center X"] = "Re-centrer X"
	L["Re-center Y"] = "Rec-entrer Y"
	--[[Translation missing --]]
	L["Reciprocal TRIGGER:# requests will be ignored!"] = "Reciprocal TRIGGER:# requests will be ignored!"
	--[[Translation missing --]]
	L["Redo"] = "Rétablir"
	L["Regions of type \"%s\" are not supported."] = "Les régions de type \"%s\" ne sont pas prises en charge."
	L["Remove"] = "Retirer"
	--[[Translation missing --]]
	L["Remove All Sounds"] = "Remove All Sounds"
	--[[Translation missing --]]
	L["Remove All Text To Speech"] = "Remove All Text To Speech"
	L["Remove this display from its group"] = "Retirer cet affichage de son groupe"
	L["Remove this property"] = "Retirer cette propriété"
	L["Rename"] = "Renommer"
	L["Repeat After"] = "Répéter Après"
	L["Repeat every"] = "Répéter tous les"
	L["Report bugs on our issue tracker."] = "Signalez les bugs sur notre système de suivi des problèmes."
	--[[Translation missing --]]
	L["Require unit from trigger"] = "Require unit from trigger"
	L["Required for Activation"] = "Requis pour l'activation"
	L["Reset all options to their default values."] = "Réinitialiser toutes les options à leurs valeurs par défaut."
	--[[Translation missing --]]
	L["Reset Entry"] = "Reset Entry"
	L["Reset to Defaults"] = "Réinitialiser les paramètres par défaut"
	L["Right 2 HUD position"] = "Position ATH Droite 2"
	L["Right HUD position"] = "Position ATH Droite"
	L["Right-click for more options"] = "Clic-Droit pour plus d'options"
	L["Rotate"] = "Tourner"
	L["Rotate In"] = "Rotation entrante"
	L["Rotate Out"] = "Rotation sortante"
	L["Rotate Text"] = "Tourner le texte"
	--[[Translation missing --]]
	L["Rotated left"] = "Rotated left"
	--[[Translation missing --]]
	L["Rotated right"] = "Rotated right"
	L["Rotation Mode"] = "Mode de rotation"
	--[[Translation missing --]]
	L["Row Space"] = "Row Space"
	--[[Translation missing --]]
	L["Row Width"] = "Row Width"
	L["Rows"] = "Lignes"
	--[[Translation missing --]]
	L["Run on..."] = "Run on..."
	L["Same"] = "Le même"
	--[[Translation missing --]]
	L["Same texture as Foreground"] = "Same texture as Foreground"
	--[[Translation missing --]]
	L["Saved Data"] = "Saved Data"
	--[[Translation missing --]]
	L["Scale Factor"] = "Scale Factor"
	--[[Translation missing --]]
	L["Search API"] = "Search API"
	--[[Translation missing --]]
	L["Select Talent"] = "Select Talent"
	L["Select the auras you always want to be listed first"] = "Choisissez les auras que vous voulez toujours voir apparaître en premier dans la liste"
	--[[Translation missing --]]
	L["Selected Frame"] = "Selected Frame"
	L["Send To"] = "Envoyer vers"
	L["Separator Text"] = "Texte Séparateur"
	L["Separator text"] = "texte séparateur"
	--[[Translation missing --]]
	L["Set Maximum Progress"] = "Set Maximum Progress"
	--[[Translation missing --]]
	L["Set Minimum Progress"] = "Set Minimum Progress"
	L["Set Parent to Anchor"] = "Définir Parent à l'Ancrage"
	L["Set Thumbnail Icon"] = "Définir la miniature"
	--[[Translation missing --]]
	L["Sets the anchored frame as the aura's parent, causing the aura to inherit attributes such as visibility and scale."] = "Sets the anchored frame as the aura's parent, causing the aura to inherit attributes such as visibility and scale."
	L["Settings"] = "Paramètres"
	--[[Translation missing --]]
	L["Shadow |c%sColor|r with offset |cFFFF0000%s/%s|r"] = "Shadow |c%sColor|r with offset |cFFFF0000%s/%s|r"
	--[[Translation missing --]]
	L["Shadow Color"] = "Shadow Color"
	L["Shadow X Offset"] = "Décalage X de l'ombre"
	L["Shadow Y Offset"] = "Décalage Y de l'ombre"
	L["Shift-click to create chat link"] = "Maj-Clic pour créer un lien de discussion"
	L["Show \"Edge\""] = "Afficher le \"Bord\""
	L["Show \"Swipe\""] = "Afficher le \"Balayage\""
	--[[Translation missing --]]
	L["Show and Clone Settings"] = "Show and Clone Settings"
	L["Show Border"] = "Afficher l'encadrement"
	--[[Translation missing --]]
	L["Show Circular Texture"] = "Show Circular Texture"
	--[[Translation missing --]]
	L["Show Debug Logs"] = "Show Debug Logs"
	L["Show Glow"] = "Brillance"
	L["Show Icon"] = "Afficher l'icône"
	--[[Translation missing --]]
	L["Show If Unit Does Not Exist"] = "Show If Unit Does Not Exist"
	--[[Translation missing --]]
	L["Show Linear Texture"] = "Show Linear Texture"
	--[[Translation missing --]]
	L["Show Matches for"] = "Show Matches for"
	--[[Translation missing --]]
	L["Show Matches for Units"] = "Show Matches for Units"
	--[[Translation missing --]]
	L["Show Model"] = "Show Model"
	L["Show model of unit "] = "Montrer le modèle de l'unité"
	--[[Translation missing --]]
	L["Show Sound Setting"] = "Show Sound Setting"
	L["Show Spark"] = "Afficher l'étincelle"
	--[[Translation missing --]]
	L["Show Stop Motion"] = "Show Stop Motion"
	L["Show Text"] = "Afficher Texte"
	--[[Translation missing --]]
	L["Show Text To Speech Setting"] = "Show Text To Speech Setting"
	--[[Translation missing --]]
	L["Show Texture"] = "Show Texture"
	L["Show this group's children"] = "Afficher les enfants de ce groupe"
	--[[Translation missing --]]
	L["Show Tick"] = "Show Tick"
	L["Shows a 3D model from the game files"] = "Affiche un modèle 3D tiré du jeu"
	L["Shows a border"] = "Affiche un encadrement"
	--[[Translation missing --]]
	L["Shows a Circular Progress Texture"] = "Shows a Circular Progress Texture"
	L["Shows a custom texture"] = "Affiche une texture personnalisée"
	L["Shows a glow"] = "Afficher les brillantes"
	--[[Translation missing --]]
	L["Shows a Linear Progress Texture"] = "Shows a Linear Progress Texture"
	L["Shows a model"] = "Affiche un modèle"
	L["Shows a progress bar with name, timer, and icon"] = "Affiche une barre de progression avec nom, temps, et icône"
	L["Shows a spell icon with an optional cooldown overlay"] = "Affiche une icône de sort avec optionnellement la durée ou le temps de recharge intégré"
	--[[Translation missing --]]
	L["Shows a Stop Motion"] = "Shows a Stop Motion"
	--[[Translation missing --]]
	L["Shows a stop motion texture"] = "Shows a stop motion texture"
	--[[Translation missing --]]
	L["Shows a Texture"] = "Shows a Texture"
	L["Shows a texture that changes based on duration"] = "Affiche une texture qui change selon la durée"
	--[[Translation missing --]]
	L["Shows nothing, except sub elements"] = "Shows nothing, except sub elements"
	L["Shows one or more lines of text, which can include dynamic information such as progress or stacks"] = "Affiche une ligne de texte ou plus, qui peut inclure des infos dynamiques telles que progression ou piles."
	L["Size"] = "Taille"
	--[[Translation missing --]]
	L["Slant Amount"] = "Slant Amount"
	--[[Translation missing --]]
	L["Slant Mode"] = "Slant Mode"
	L["Slanted"] = "Incliné"
	L["Slide"] = "Glisser"
	L["Slide In"] = "Glisser entrant"
	L["Slide Out"] = "Glisser sortant"
	--[[Translation missing --]]
	L["Slider Step Size"] = "Slider Step Size"
	L["Small Icon"] = "Petite icône"
	--[[Translation missing --]]
	L["Smooth Font"] = "Smooth Font"
	L["Smooth Progress"] = "Progrès Doux"
	--[[Translation missing --]]
	L["Smooth scaling"] = "Smooth scaling"
	--[[Translation missing --]]
	L["Smooths text height, preventing it from snapping to the nearest whole number when scaled."] = "Smooths text height, preventing it from snapping to the nearest whole number when scaled."
	--[[Translation missing --]]
	L["Snippets"] = "Snippets"
	--[[Translation missing --]]
	L["Soft Max"] = "Soft Max"
	--[[Translation missing --]]
	L["Soft Min"] = "Soft Min"
	L["Sort"] = "Trier"
	L["Sound Channel"] = "Canal sonore"
	L["Sound File Path"] = "Chemin fichier son"
	L["Sound Kit ID"] = "ID Kit Son"
	L["Space Horizontally"] = "Espacer horizontalement"
	L["Space Vertically"] = "Espacer verticalement"
	L["Spark Settings"] = "Paramètres de l'étincelle"
	L["Spark Texture"] = "Texture de l'étincelle"
	--[[Translation missing --]]
	L["Spell Selection Filters"] = "Spell Selection Filters"
	--[[Translation missing --]]
	L["Spells found:"] = "Spells found:"
	--[[Translation missing --]]
	L["Squelch Sounds/Actions on Load"] = "Squelch Sounds/Actions on Load"
	--[[Translation missing --]]
	L["Squelched"] = "Squelched"
	L["Stack Info"] = "Info de Piles"
	--[[Translation missing --]]
	L["Stacks - The number of stacks of an aura (usually)"] = "Stacks - The number of stacks of an aura (usually)"
	--[[Translation missing --]]
	L["Standby"] = "Standby"
	L["Star"] = "Étoile"
	L["Start"] = "Début"
	L["Start Angle"] = "Angle de départ"
	--[[Translation missing --]]
	L["Start Collapsed"] = "Start Collapsed"
	--[[Translation missing --]]
	L["Start of %s"] = "Start of %s"
	--[[Translation missing --]]
	L["Step Size"] = "Step Size"
	--[[Translation missing --]]
	L["Stop Motion %s"] = "Stop Motion %s"
	--[[Translation missing --]]
	L["Stop Motion Settings"] = "Stop Motion Settings"
	L["Stop Sound"] = "Arrêter le son"
	--[[Translation missing --]]
	L["Stretched by Foreground"] = "Stretched by Foreground"
	--[[Translation missing --]]
	L["Sub Elements"] = "Sub Elements"
	--[[Translation missing --]]
	L["Sub Option %i"] = "Sub Option %i"
	--[[Translation missing --]]
	L["Subevent"] = "Subevent"
	--[[Translation missing --]]
	L["Subevent Suffix"] = "Subevent Suffix"
	L["Swipe Overlay Settings"] = "Paramètres de la superposition des balayages"
	L["Switch to classic mode"] = "Passer en mode classique"
	--[[Translation missing --]]
	L["Templates could not be loaded, the addon is %s"] = "Templates could not be loaded, the addon is %s"
	L["Temporary Group"] = "Groupe temporaire"
	L["Text %s"] = "Texte %s"
	L["Text Color"] = "Couleur Texte"
	L["Text Settings"] = "Paramètres du texte"
	--[[Translation missing --]]
	L["Texture %s"] = "Texture %s"
	L["Texture Info"] = "Info Texture"
	--[[Translation missing --]]
	L["Texture Selection Mode"] = "Texture Selection Mode"
	L["Texture Settings"] = "Paramètres de la texture"
	L["Texture Wrap"] = "Enveloppe de texture"
	--[[Translation missing --]]
	L["Texture X Offset"] = "Texture X Offset"
	--[[Translation missing --]]
	L["Texture Y Offset"] = "Texture Y Offset"
	--[[Translation missing --]]
	L["Thanks"] = "Thanks"
	--[[Translation missing --]]
	L["The addon ElvUI is enabled. It might add cooldown numbers to the swipe. You can configure these in the ElvUI settings."] = "The addon ElvUI is enabled. It might add cooldown numbers to the swipe. You can configure these in the ElvUI settings."
	--[[Translation missing --]]
	L["The addon OmniCC is enabled. It might add cooldown numbers to the swipe. You can configure these in the OmniCC settings."] = "The addon OmniCC is enabled. It might add cooldown numbers to the swipe. You can configure these in the OmniCC settings."
	L["The Aura (Modern) display ignores the mouse, so it shows no tooltip."] = "L'affichage Aura (Modern) ignore la souris, il n'a donc pas d'infobulle."
	L["The duration of the animation in seconds."] = "La durée de l'animation en secondes."
	L["The duration of the animation in seconds. The finish animation does not start playing until after the display would normally be hidden."] = "La durée de l'animation en secondes. L'animation de fin ne commence qu'après le moment où l'affichage est normalement caché."
	L["The game fills the bar or the swipe itself and hides the progress from addons: this effect needs to read the progress."] = "Le jeu remplit lui-même la barre ou le balayage et cache la progression aux addons : cet effet a besoin de lire la progression."
	L["The game starts this glow itself, without the start animation."] = "Le jeu lance lui-même cette surbrillance, sans l'animation de départ."
	L["The game writes this text itself: custom code cannot run on it."] = "Le jeu écrit lui-même ce texte : du code personnalisé ne peut pas s'y appliquer."
	L["The game writes this value itself: only the time format applies."] = "Le jeu écrit lui-même cette valeur : seul le format de temps s'applique."
	--[[Translation missing --]]
	L["The group and all direct children will share the same base frame level."] = "The group and all direct children will share the same base frame level."
	--[[Translation missing --]]
	L["The Multi Target mode is less reliable and not recommended."] = "The Multi Target mode is less reliable and not recommended."
	--[[Translation missing --]]
	L["The Multi Target mode requires a name or spell id filter"] = "The Multi Target mode requires a name or spell id filter"
	--[[Translation missing --]]
	L["The trigger number is optional. When no trigger number is specified, the trigger selected via dynamic information will be used."] = "The trigger number is optional. When no trigger number is specified, the trigger selected via dynamic information will be used."
	L["The type of trigger"] = "Le type de déclencheur"
	--[[Translation missing --]]
	L["The WeakAuras Options Addon version %s doesn't match the WeakAuras version %s. If you updated the addon while the game was running, try restarting World of Warcraft. Otherwise try reinstalling WeakAuras"] = "The WeakAuras Options Addon version %s doesn't match the WeakAuras version %s. If you updated the addon while the game was running, try restarting World of Warcraft. Otherwise try reinstalling WeakAuras"
	L["Then "] = "Alors"
	--[[Translation missing --]]
	L["There are several special codes available to make this text dynamic. Click to view a list with all dynamic text codes."] = "There are several special codes available to make this text dynamic. Click to view a list with all dynamic text codes."
	--[[Translation missing --]]
	L["This adds %raidMark as text replacements."] = "This adds %raidMark as text replacements."
	--[[Translation missing --]]
	L["This adds %role, %roleIcon as text replacements. Does nothing if the unit is not a group member."] = "This adds %role, %roleIcon as text replacements. Does nothing if the unit is not a group member."
	--[[Translation missing --]]
	L["This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 and %tooltip4 as text replacements and also allows filtering based on the tooltip content/values."] = "This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 and %tooltip4 as text replacements and also allows filtering based on the tooltip content/values."
	--[[Translation missing --]]
	L[ [=[This aura contains custom Lua code.
Make sure you can trust the person who sent it!]=] ] = [=[This aura contains custom Lua code.
Make sure you can trust the person who sent it!]=]
	--[[Translation missing --]]
	L["This aura is marked as an update to an aura '%s', but cannot be used to update that aura. This usually happens if an aura is moved out of a group."] = "This aura is marked as an update to an aura '%s', but cannot be used to update that aura. This usually happens if an aura is moved out of a group."
	--[[Translation missing --]]
	L["This aura is marked as an update to auras '%s', but cannot be used to update them. This usually happens if an aura is moved out of a group."] = "This aura is marked as an update to auras '%s', but cannot be used to update them. This usually happens if an aura is moved out of a group."
	--[[Translation missing --]]
	L[ [=[This aura was created with a different version (%s) of World of Warcraft.
It might not work correctly!]=] ] = [=[This aura was created with a different version (%s) of World of Warcraft.
It might not work correctly!]=]
	--[[Translation missing --]]
	L[ [=[This aura was created with a newer version of WeakAuras.
Upgrade your version of WeakAuras or wait for next release before installing this aura.]=] ] = [=[This aura was created with a newer version of WeakAuras.
Upgrade your version of WeakAuras or wait for next release before installing this aura.]=]
	L["This display is currently loaded"] = "Cet affichage est actuellement chargé"
	L["This display is not currently loaded"] = "Cet affichage n'est pas chargé"
	--[[Translation missing --]]
	L["This display is on standby, it will be loaded when needed."] = "This display is on standby, it will be loaded when needed."
	L["This enables the collection of debug logs. Custom code can add debug information to the log through the function DebugPrint."] = "Cela permet de collecter les journaux de débogage. Un code personnalisé peut ajouter des informations de débogage au journal grâce à la fonction DebugPrint."
	--[[Translation missing --]]
	L["This is a modified version of your aura, |cff9900FF%s.|r"] = "This is a modified version of your aura, |cff9900FF%s.|r"
	--[[Translation missing --]]
	L["This is a modified version of your group: |cff9900FF%s|r"] = "This is a modified version of your group: |cff9900FF%s|r"
	L["This region of type \"%s\" is not supported."] = "Cette région de type \"%s\" n'est pas supportée."
	L["This setting controls what widget is generated in user mode."] = "Ce paramètre contrôle le widget généré en mode utilisateur."
	--[[Translation missing --]]
	L["Thumbnail Icon"] = "Thumbnail Icon"
	L["Tick %s"] = "Coche %s"
	--[[Translation missing --]]
	L["Tick Area %s"] = "Tick Area %s"
	--[[Translation missing --]]
	L["Tick Center %s"] = "Tick Center %s"
	--[[Translation missing --]]
	L["Tick Mode"] = "Tick Mode"
	--[[Translation missing --]]
	L["Tick Placement"] = "Tick Placement"
	L["Time in"] = "Temps entrant"
	L["Tiny Icon"] = "Très petite icône"
	L["To Frame's"] = "Au cadre de"
	--[[Translation missing --]]
	L["To Group's"] = "To Group's"
	L["To Personal Ressource Display's"] = "À ... du cadre des Res. Perso"
	--[[Translation missing --]]
	L["To Region's"] = "To Region's"
	L["To Screen's"] = "À ... de l'écran"
	L["Toggle the visibility of all loaded displays"] = "Change la visibilité de tous les affichages chargés"
	L["Toggle the visibility of all non-loaded displays"] = "Change la visibilité de tous les affichages non-chargés"
	L["Toggle the visibility of this display"] = "Activer/Désactiver la visibilité de cet affichage"
	L["Tooltip Content"] = "Contenu de l'info-bulle"
	L["Tooltip on Mouseover"] = "Info-bulle à la souris"
	L["Tooltip Pattern Match"] = "Correspondance de modèle de l'info-bulle"
	L["Tooltip Text"] = "Texte de l'Info-bulle."
	L["Tooltip Value"] = "Valeur de l'info-bulle"
	L["Tooltip Value #"] = "Valeur de l'info-bulle #"
	L["Top HUD position"] = "Position ATH Haute"
	--[[Translation missing --]]
	L["Total"] = "Total"
	--[[Translation missing --]]
	L["Total - The maximum duration of a timer, or a maximum non-timer value"] = "Total - The maximum duration of a timer, or a maximum non-timer value"
	--[[Translation missing --]]
	L["Total Angle"] = "Total Angle"
	--[[Translation missing --]]
	L["Total Time"] = "Total Time"
	--[[Translation missing --]]
	L["Trigger %i: %s"] = "Trigger %i: %s"
	--[[Translation missing --]]
	L["Trigger Combination"] = "Trigger Combination"
	L["Trigger numbers combined with and, or, not and parentheses, such as 1 and (2 or not 3). An Aura (Modern) trigger counts as active as long as its settings are valid and its unit exists, whether or not the aura is present: the actual presence of the aura is shown by the game and does not enter the expression."] = "Numéros de déclencheurs combinés par and (et), or (ou), not (non) et des parenthèses, par exemple 1 and (2 or not 3). Un déclencheur Aura (Modern) compte comme actif tant que ses réglages sont valides et que son unité existe, que l'aura soit présente ou non : la présence réelle de l'aura est affichée par le jeu et n'entre pas dans l'expression."
	--[[Translation missing --]]
	L["Type 'select' for '%s' requires a values member'"] = "Type 'select' for '%s' requires a values member'"
	--[[Translation missing --]]
	L["Undo"] = "Annuler"
	L["Ungroup"] = "Dissocier"
	--[[Translation missing --]]
	L["Unit %s is not a valid unit for RegisterUnitEvent"] = "Unit %s is not a valid unit for RegisterUnitEvent"
	L["Unit Count"] = "Nombre d'unité"
	--[[Translation missing --]]
	L["Unknown"] = "Unknown"
	--[[Translation missing --]]
	L["Unknown property '%s' found in '%s'"] = "Unknown property '%s' found in '%s'"
	--[[Translation missing --]]
	L["Unknown Spell"] = "Unknown Spell"
	L["Unlike the start or finish animations, the main animation will loop over and over until the display is hidden."] = "Contrairement aux animations de début et de fin, l'animation principale bouclera tant que l'affichage est visible."
	L["Unused Auras"] = "Auras inutilisées"
	L["Unused for %d days, listed above:"] = "Inutilisées depuis %d jours, listées ci-dessus :"
	--[[Translation missing --]]
	L["Update"] = "Update"
	L["Update Auras"] = "Mettre à jour"
	L["Update Custom Text On..."] = "Mettre à jour le texte personnalisé sur..."
	L["URL"] = "URL"
	--[[Translation missing --]]
	L["Url: %s"] = "Url: %s"
	L["Use Display Info Id"] = "Utiliser les informations d'identifiant de l'affichage"
	L["Use SetTransform"] = "Utiliser SetTransform"
	L["Used in Auras:"] = "Utilisé(e) dans les Auras:"
	L["Used in auras:"] = "Utilisé dans les auras:"
	--[[Translation missing --]]
	L["Uses Texture Coordinates to rotate the texture."] = "Uses Texture Coordinates to rotate the texture."
	--[[Translation missing --]]
	L["Uses UnitIsVisible() to check if game client has loaded a object for this unit. This distance is around 100 yards. This is polled every second."] = "Uses UnitIsVisible() to check if game client has loaded a object for this unit. This distance is around 100 yards. This is polled every second."
	--[[Translation missing --]]
	L["Value"] = "Value"
	L["Value %i"] = "Valeur %i"
	L["Values are in normalized rgba format."] = "Les valeurs sont normalisées dans le format rvba"
	--[[Translation missing --]]
	L["Values/Remaining Time above this value are displayed as full progress."] = "Values/Remaining Time above this value are displayed as full progress."
	--[[Translation missing --]]
	L["Values/Remaining Time below this value are displayed as zero progress."] = "Values/Remaining Time below this value are displayed as zero progress."
	L["Values:"] = "Valeurs:"
	L["Version: "] = "Version: "
	--[[Translation missing --]]
	L["Version: %s"] = "Version: %s"
	L["Vertical Align"] = "Aligner verticalement"
	L["Vertical Bar"] = "Barre verticale"
	L["View"] = "Vue"
	L["View custom code"] = "Afficher le code personnalisé"
	--[[Translation missing --]]
	L["Voice Settings"] = "Voice Settings"
	--[[Translation missing --]]
	L["We thank"] = "We thank"
	--[[Translation missing --]]
	L["WeakAuras %s on WoW %s"] = "WeakAuras %s on WoW %s"
	--[[Translation missing --]]
	L["WeakAuras recommends using spell ids instead of names. Spell ids are automatically localized."] = "WeakAuras recommends using spell ids instead of names. Spell ids are automatically localized."
	--[[Translation missing --]]
	L["What do you want to do?"] = "What do you want to do?"
	--[[Translation missing --]]
	L["Whole Area"] = "Whole Area"
	--[[Translation missing --]]
	L["Width |cFFFF0000%s|r and %s"] = "Width |cFFFF0000%s|r and %s"
	--[[Translation missing --]]
	L["wrapping"] = "wrapping"
	L["X Offset"] = "Décalage X"
	L["X Rotation"] = "Rotation X"
	L["X Scale"] = "Echelle X"
	L["x-Offset"] = "x-Décalage"
	L["Y Offset"] = "Décalage Y"
	L["Y Rotation"] = "Rotation Y"
	L["Y Scale"] = "Echelle Y"
	L["y-Offset"] = "y-Décalage"
	--[[Translation missing --]]
	L["You already have this group/aura. Importing will create a duplicate."] = "You already have this group/aura. Importing will create a duplicate."
	L["You are about to delete %d aura(s). They can be imported again for 30 days with /wa deleted. Would you like to continue?"] = "Vous êtes sur le point de supprimer %d aura(s). Elles pourront être réimportées pendant 30 jours avec /wa deleted. Voulez-vous continuer ?"
	L["You are about to delete %d aura(s). |cFFFF0000This cannot be undone!|r Would you like to continue?"] = "Vous êtes sur le point de supprimer %d aura(s). |cFFFF0000Cela ne peut pas être annulé !|r Voulez-vous continuer ?"
	--[[Translation missing --]]
	L["You are about to delete a trigger. |cFFFF0000This cannot be undone!|r Would you like to continue?"] = "You are about to delete a trigger. |cFFFF0000This cannot be undone!|r Would you like to continue?"
	--[[Translation missing --]]
	L[ [=[You are about to Import an Aura with custom Lua code on a Hardcore server.

|cFFFF0000There is a risk the custom code could be used to kill your hardcore character!|r

Would you like to continue?]=] ] = [=[You are about to Import an Aura with custom Lua code on a Hardcore server.

|cFFFF0000There is a risk the custom code could be used to kill your hardcore character!|r

Would you like to continue?]=]
	--[[Translation missing --]]
	L[ [=[You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the Anchor Code on.

WeakAuras will always run custom anchor code if you include 'changed' in this list, or when a region is added, removed, or re-ordered.]=] ] = [=[You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the Anchor Code on.

WeakAuras will always run custom anchor code if you include 'changed' in this list, or when a region is added, removed, or re-ordered.]=]
	--[[Translation missing --]]
	L[ [=[You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the Grow Code on.

WeakAuras will always run custom grow code if you include 'changed' in this list, or when a region is added, removed, or re-ordered.]=] ] = [=[You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the Grow Code on.

WeakAuras will always run custom grow code if you include 'changed' in this list, or when a region is added, removed, or re-ordered.]=]
	--[[Translation missing --]]
	L["You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the sort code on.WeakAuras will always run custom sort code if you include 'changed' in this list, or when a region is added, removed."] = "You can add a comma-separated list of state values here that (when changed) WeakAuras should also run the sort code on.WeakAuras will always run custom sort code if you include 'changed' in this list, or when a region is added, removed."
	--[[Translation missing --]]
	L["Your Saved Snippets"] = "Your Saved Snippets"
	L["Z Offset"] = "Décalage Z"
	L["Z Rotation"] = "Rotation Z"
	L["Zoom In"] = "Zoom avant"
	L["Zoom Out"] = "Zoom arrière"


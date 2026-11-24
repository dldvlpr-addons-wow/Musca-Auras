# Tests en jeu de la 1.21.0 : fiabilité et diagnostic

Version 1.21.0 du 2026-11-23, entrée du même jour de `CHANGES.md`. Banc headless : 137 scénarios, 0 échec. Rien
n'est testé en jeu. Reprend l'étape 17 de `SUIVI-BUGS-ET-TESTS.md`.

Un seul 🔴 en échec bloque la mise en production. Noter pour chaque échec : la ligne du test, ce qui s'affiche, et
le texte de l'erreur Lua s'il y en a une.

Durée : 30 à 40 min. Les libellés cités sont en anglais ; client français entre parenthèses.

## 0. Préparation

1. [ ] Copier l'addon dans `Interface\AddOns\` (copie, pas de lien), lancer le jeu.
2. [ ] `/console scriptErrors 1`, puis `/reload`.
3. [ ] Avoir sous la main :
   - le HUD de la classe installé (`/wa welcome`, « Install the full HUD ») ;
   - une aura à code personnalisé, par exemple un déclencheur Custom qui fait `print("custom")` ;
   - une aura avec une animation de début (Slide ou Fade) ;
   - un mob à frapper pour les tests en combat.

## 1. Safe mode `/wa safemode`

1. [ ] 🔴 `/wa safemode` : l'interface se recharge. Aucune aura ne s'affiche. Ligne dans le chat « Safe mode: every
   aura is paused and no custom code runs... » (« Mode sans échec : ... »). Aucune erreur Lua, aucun
   « custom » dans le chat.
2. [ ] `/wa` s'ouvre. Modifier une aura, puis en supprimer une : aucune erreur.
3. [ ] 🔴 Fermer `/wa` : les auras restent invisibles, aucun « custom » dans le chat.
4. [ ] `/wa toggle` : la ligne du safe mode revient dans le chat, les auras restent invisibles.
5. [ ] `/wa unlock`, puis « Save and quit » : aucune erreur, les auras restent invisibles.
6. [ ] 🔴 `/wa safemode` à nouveau : rechargement sans ligne du safe mode. Les auras reviennent, le code
   personnalisé tourne (« custom » dans le chat), l'animation de début joue.
7. [ ] `/wa safemode`, puis `/reload` simple : le jeu redémarre en mode normal.
8. [ ] `/wa help` : la ligne `/wa safemode` est présente.

## 2. Médias manquants à l'import

1. [ ] Sans addon de médias (SharedMedia désactivé), importer une aura qui utilise une police ou une texture de
   barre d'un tel addon. Dans la vue d'import, ligne dorée « Media missing from your addons, replaced by the default
   one: » (« Médias absents de vos addons, remplacés par celui par défaut : ») suivie du type et du nom, par
   exemple « Font: Expressway ».
2. [ ] Importer l'aura : elle s'affiche avec la police ou la texture par défaut, sans erreur.
3. [ ] Importer une aura qui n'utilise que les médias du jeu : aucune ligne dorée.
4. [ ] Si possible, réactiver l'addon de médias, `/reload`, réimporter : aucune ligne dorée.

## 3. Option de chargement « AddOn Loaded »

Dans `/wa`, onglet **Load** d'une aura simple toujours visible, cocher « AddOn Loaded » (« AddOn chargé »).

1. [ ] Infobulle : nom de dossier de l'addon, plusieurs noms séparés par des virgules.
2. [ ] 🔴 Nom d'un addon installé et activé (nom du dossier dans `Interface\AddOns\`) : l'aura se charge.
3. [ ] 🔴 Nom d'un addon absent : l'aura ne se charge pas.
4. [ ] `<addon installé>, <addon absent>` : l'aura ne se charge pas. Deux addons installés : elle se charge.
5. [ ] Champ vide, case cochée : l'aura se charge, aucune erreur.
6. [ ] Addon chargé à la demande : mettre `Blizzard_TimeManager` (ou un autre addon Blizzard pas encore chargé)
   dans le champ, vérifier que l'aura n'est pas chargée, puis `/run C_AddOns.LoadAddOn("Blizzard_TimeManager")` :
   l'aura se charge sans `/reload`.

## 4. Rapport de diagnostic `/wa report`

1. [ ] 🔴 `/wa report` hors combat : fenêtre titrée « Musca Auras Diagnostic Report » (« Rapport de diagnostic
   Musca Auras »). Elle contient : version de Musca, version du client, build, interface, langue, classe et
   niveau, nombre d'auras, addons chargés avec leur version, auras à avertissement.
2. [ ] 🔴 Aucun nom de personnage, de royaume ni de guilde dans le texte.
3. [ ] Ctrl+A puis Ctrl+C dans la fenêtre : le texte se colle dans un éditeur, une ligne par information.
4. [ ] `/wa toggle` (auras en pause), puis `/wa report` : le nombre d'auras porte « paused ». En safe mode : « safe
   mode ».
5. [ ] `/wa pstart`, `/wa pstop`, `/wa pprint` après `/wa report` : titre « Musca Auras Profiling Report ».
   `/wa report` ensuite : le titre du rapport de diagnostic revient.
6. [ ] En combat, `/wa report` : ligne « Type this command again after combat. » (« Retapez cette commande après le
   combat. »), aucune fenêtre.
7. [ ] Sur GitHub, « New issue » : le modèle « Bug report » demande de coller le rapport.

## 5. Sorts de pack `/wa packcheck`

1. [ ] 🔴 HUD de classe installé, hors combat, `/wa packcheck` : ligne « Class pack check: N spell(s) checked, M not
   known. » (« Vérification du pack de classe : ... »), puis une ligne par sort non connu : nom de l'aura, ID du
   sort, nom du sort, « not learned » (« non appris »).
2. [ ] Chaque sort n'apparaît qu'une fois par aura.
3. [ ] Un sort appris à un rang supérieur au rang 1 n'apparaît pas.
4. [ ] Les sorts listés sont des talents non pris ou des sorts au-dessus du niveau du personnage. Dernière ligne :
   « A talent spell you have not taken, or a rank above your level, shows as not learned. ».
5. [ ] Tout appris (ou aucun sort manquant) : seulement la ligne de bilan, avec 0 non connu.
6. [ ] Personnage sans aura de pack (supprimer le HUD ou autre classe sans HUD) : « No class pack aura is installed. »
   (« Aucune aura de pack de classe n'est installée. »).
7. [ ] En combat : ligne « Type this command again after combat. », rien d'autre.

## 6. Aide et traductions

1. [ ] `/wa help` : lignes safemode, report, packcheck, pcancel, pshow, ff, aucune clé brute en anglais sur un
   client français.
2. [ ] Si un client allemand ou russe est disponible : les lignes de `/wa help` et le message du safe mode ne
   débordent pas et restent lisibles.

## 7. Non-régression

1. [ ] 🔴 Étape 2 de `SUIVI-BUGS-ET-TESTS.md` (combat de base) rejouée sur un mob : aucune erreur.
2. [ ] Auras à code personnalisé hors safe mode : elles tournent comme en 1.20.
3. [ ] Une aura à avertissement (par exemple une fonction supprimée dans son code) garde son avertissement dans
   `/wa`.

## 8. Packs et `/wa unlock` (ajouts du 2026-11-24)

- [ ] Connexion : la popup « Update <Classe> HUD » s'affiche sur un perso qui a le HUD. Mise à jour faite.
- [ ] Gnome prêtre : icônes Eureka!, Confounding Flash et Contingency Plan présentes (recharges).
- [ ] Gnome d'une autre classe : Eureka! présente (ID propre à la classe, trouvé par le nom).
- [ ] Non-gnome : aucune de ces trois icônes.
- [ ] Ready Flash : Eureka! flashe dans l'icône « Racials ».
- [ ] `/wa unlock` : aucune boîte ni aperçu pour les auras d'une autre classe ; une aura « en combat » a sa boîte.
- [ ] `/wa unlock` : Disable puis Enable sur une boîte, la boîte reste ; Disable puis Revert, la boîte reste.

## Résultat

- Date du test :
- Client et build (`/dump GetBuildInfo()`) :
- Classe et niveau :
- Échecs (numéro, constat, erreur Lua) :

# Tickets par version

Établi le 2026-10-27, reclassé le 2026-11-21. 85 tickets : 66 livrés (1.15 à 1.21), 1 clos sans développement (Dette 5), 18 à faire (1.22 à 1.29). L'avancement est dans la section « Déjà fait » de chaque version sortie.

Séries :
- « Packs » : compléments des packs de classe (8, livrés) ;
- « Dette » : dette technique et bugs (23 ; reste Dette 3) ;
- « Placement » : grille et magnétisme (15, dont 8 ajoutés le 2026-11-10 ; reste Placement 7) ;
- « Rebranding » : interface de la 1.18 (9, livrés sauf Rebranding 9, reporté en 1.22) ;
- « Accueil » : accueil du nouveau joueur (4, à faire) ;
- « Populaire » : demandes populaires de WeakAuras (11, dont les auras cliquables ajoutées le 2026-11-13 ; Populaire 11 livré) ;
- « API » : API publique pour les modules d'addons tiers (8, ajoutés le 2026-11-21, à faire) ;
- « Outils » : diagnostic, sauvegardes et outillage de sortie (7, ajoutés le 2026-11-21, à faire).

Vérification de référence : `lua5.1 Tests/run.lua` depuis la racine, avec `WOW_UI_SOURCE` pointant sur le source Forever. `luacheck` n'est pas installé sur le poste : il ne tourne qu'en CI (`.github/workflows/lint.yml`).

## Règles d'ordre

1. Les bugs passent avant les fonctionnalités.
2. Un ticket qui sécurise un fichier (test, correctif) précède celui qui le modifie en profondeur.
3. Les textes et écrans neufs viennent après la charte de la 1.18, pour ne les écrire qu'une fois.
4. Une version mélange du S visible et au plus un ou deux M. Les L ferment le plan.
5. Chaque version se teste en jeu avant sa sortie (`SUIVI-BUGS-ET-TESTS.md`).
6. Les numéros de ligne d'un ticket datent de sa rédaction : les revérifier à l'ouverture du ticket.

## Sommaire

| Version | Sortie | Thème | Tickets |
|---|---|---|---|
| 1.15 | 2026-11-05 | Packs | Packs 2, 3, 4, 6, 8, 1 |
| 1.16 | 2026-11-07 | Stabilisation | Dette 2, 9, 10 à 23, Packs 5, 7, Dette 6, 8 |
| 1.16.1 | 2026-11-09 | Correctifs | Hors ticket |
| 1.17 | 2026-11-12 | Placement | Dette 7, Dette 1, Placement 2, 1, 3, 5, 4, 6, puis 9, 8, 10 à 15 |
| 1.18 | 2026-11-13 | Rebranding | Rebranding 1, 2, 3, 5, 6, 7, 8, 4 (Rebranding 9 reporté en 1.22) |
| 1.18.1, 1.18.2 | 2026-11-15, 2026-11-16 | Correctifs du trigger Cooldown | Hors ticket |
| 1.19 | 2026-11-18 | Auras cliquables | Dette 4, Populaire 11 |
| 1.20 | 2026-11-22 | Accueil et commandes | Outils 1, 3, Accueil 2, 1, 3, 4, Populaire 1, 10 |
| 1.21 | 2026-11-23 | Fiabilité et diagnostic | Dette 3, Populaire 5, 3, 2, Outils 2, 4 |
| 1.22 | 2026-11-25 | Édition d'auras et design classique | Populaire 4, 6, Placement 7, Rebranding 9 |
| 1.23 | à faire | Sauvegardes | Outils 5, 6 |
| 1.24 | à faire | Groupes dynamiques et annonce de version | Populaire 7, Outils 7 |
| 1.25 | à faire | API : fondations | API 1, 3, 2, 4 |
| 1.26 | à faire | API : packs, ancrage, triggers | API 5, 6, 7 |
| 1.27 | à faire | Templates personnalisés | Populaire 8 |
| 1.28 | à faire | Animations conditionnelles | Populaire 9 |
| 1.29 | à faire | API : auras possédées par un addon | API 8 |

Tests en jeu en retard sur des versions sorties : 1.15 (étape 13 du suivi), 1.16 et 1.17 (aucune étape), 1.19 (étape 15).

## Dépendances

Seules les dépendances entre tickets à faire sont listées. Levées par une sortie : Dette 1, 4, 6, 7, 17, 18, Packs 2, Placement 4, Rebranding 1.

| Avant | Après | Raison |
|---|---|---|
| Outils 1 | Accueil 1 à 4, Populaire 1, 10, Outils 2, 4, 5, 6, 7 | Chaque texte neuf est contrôlé par le scénario des clés |
| Accueil 2 | Accueil 1 | Mêmes boutons |
| Accueil 3 | API 5 | Même page Packs, même compteur d'auras |
| Populaire 4 | Populaire 9 | Animations et conditions |
| Outils 5 | Outils 6 | Même zone de la fenêtre, mêmes confirmations |
| API 1 | API 2 à 8 | Chaque fonction publique neuve entre dans la liste figée |
| API 1, API 2 | API 4 | Le registre lit la version d'API et s'appuie sur les événements |
| API 4 | API 5 | Les packs tiers s'inscrivent à l'étape « options chargées » |
| API 3 | API 7 | Validation à l'enregistrement, même principe |

---

## 1.15 : packs

Sortie le 2026-11-05 (1.15.0). Les six tickets Packs sont livrés. Packs 2 est passé en premier : il valide les ID déjà livrés, et Packs 3 s'est tranché pendant le même passage dans le DB2.

### Déjà fait

Entrées du 2026-10-25, du 2026-10-26, du 2026-10-29 et du 2026-11-05 de `CHANGES.md`. Banc headless vert à la sortie (86 scénarios, 0 échec).

- Code custom : `WeakAuras.IsSpellReady`, `GetSpellCooldownDurationNoGCD`, `SetSpellCooldownState`, `SetLoadFlag`.
- Page Packs : HUD complet ou bloc par bloc, 24 packs utilitaires.
- Packs de classe :
  - son sur les procs, rappels « Fading », barre Enemy Cast, swing timer distance ;
  - listes de référence de Fojji, lanceur affiché sur les buffs, icône Defensives, option `anyCaster`, PW:S en une seule icône ;
  - buffs, procs et debuffs manquants ajoutés pour toutes les classes ;
  - Paladin : proc Infusion of Light. Mage : segments Arcane Blast (scénario 89) ;
  - debuffs sur le joueur en Approximate Match ;
  - la notice des packs de classe se réaffiche pour la 1.15.0 (`CLASS_PACK_VERSION`, `WeakAuras/WeakAuras.lua:390`).
- Retiré : son de voix enregistrée.
- Corrigés : Threat Situation avec valeurs secrètes ; format de nombre en précision 0 avec un nombre secret.
- Guides `Classes/*.md`, README, DESCRIPTION et harness de test mis à jour.
- Packs 2 : durées et charges de tous les ID revérifiées dans le DB2 70532. Les segments Arcane Blast n'ont pris leur durée de 18 s qu'en 1.17.0.
- Packs 3 : auras « non vérifiées » tranchées, Deep Wounds retiré du pack. Restent des tests en jeu notés dans les `NOTES.md` : debuffs sur soi (Paladin, Prêtre), segments (Mage).
- Packs 4 : icône Defensives pour Guerrier, Druide, Voleur et Chasseur.
- Packs 6 : `fading = 60` sur Righteous Fury (`PackPaladin.lua`).
- Packs 8 : `meleeRange` pour le Chasseur (`PackChasseur.lua`), option ajoutée au builder.
- Packs 1 : poisons au rang le plus haut connu (`PackVoleur.lua`), munitions équipées sous 200 (`PackChasseur.lua`). Écart au ticket : pas d'ID d'objet par entrée.

### Reste ouvert

La version est sortie, deux points restent.

1. Tests en jeu de la 1.15 : étape 13 de `SUIVI-BUGS-ET-TESTS.md`, aucune case cochée.
2. `CHANGES.md` n'a pas de ligne « Released as 1.15.0. Tested in game… ». La dernière est celle de la 1.13.0 : les entrées suivantes disent seulement « Tested in game » ou « Not yet tested in game ».

### Ordre

1. Packs 2 : Revérifier durées et charges de tous les ID des packs en 70532
2. Packs 3 : Trancher les auras « non vérifiées » restantes
3. Packs 4 : Défensifs de classe manquants
4. Packs 6 : `fading` sur Righteous Fury
5. Packs 8 : `meleeRange` pour le Chasseur
6. Packs 1 : Rappels de stock de poisons et de munitions

---

### Packs 2 : Revérifier durées et charges de tous les ID des packs en 70532

**Pourquoi.** Arcane Blast a changé entre les builds 70245 et 70532 : 8 s devenues 15 s, charge de proc retirée (`Tests/Packs/Mage/NOTES.md:45`). Les autres sorts n'ont été vérifiés que sur leur présence.

**Valeur.** Pas de minuteur ni de cumul faux dans les packs livrés en 1.15.

**À faire.**
- Script en lecture seule : pour chaque ID de sort et d'aura des `Pack*.lua`, relever dans le DB2 70532 la durée (`DurationIndex`), les cumuls et les charges de proc.
- Comparer aux valeurs codées en dur dans les packs (`warn`, `fading`, `segments`, durées) et aux NOTES.
- Corriger ce qui a bougé.

**Coût.** S.

**Risque.** Nul : lecture seule tant que rien n'a bougé.

**Fichiers.**
- Aucun si rien n'a bougé, sinon `Tests/Packs/*/Pack*.lua` et `NOTES.md`

---

### Packs 3 : Trancher les auras « non vérifiées » restantes

**Pourquoi.** Il restait 44 mentions dans les NOTES ; il en reste une douzaine. Le Voleur est à 0. Restent :
- Chasseur : Freezing Trap et Frost Trap (3355, 14308, 14309, 13810) ;
- Démoniste : Shadow Ward (6229, 11739, 11740, 28610), Shadowburn 17877, Siphon Life 18265, sorts de familier (Spell Lock 19244, Seduction 6358, Suffering 17735) ;
- Druide : Lacerate, Prowl, Nature's Grasp, Pounce (9007, 9824, 9826) ;
- Guerrier : Deep Wounds 12162 ;
- Mage : debuffs Frostbolt, Pyroblast et Polymorph (ID de rang utilisés comme ID d'aura) ;
- Prêtre : Vampiric Embrace 15286, Spirit Tap 15271.

**Valeur.** Des icônes qui s'allument vraiment.

**À faire.**
- Trancher chaque ID dans le DB2 70532, pendant le passage de Packs 2.
- Corriger l'ID ou retirer l'aura, puis mettre à jour la NOTES et le guide `Classes/*.md`.

**Coût.** S à M.

**Risque.** Faible.

**Fichiers.**
- `Tests/Packs/*/Pack*.lua`, `Tests/Packs/*/NOTES.md`, `Classes/*.md`

---

### Packs 4 : Défensifs de classe manquants

**Pourquoi.** Le champ `defensives` n'est utilisé que par Démoniste, Mage et Paladin. `PackBuilder.lua:494-496` les ajoute à l'icône Defensives commune.

**Valeur.** L'icône Defensives montre aussi les défensifs des autres classes.

**À faire.**
- Ajouter `defensives = { ... }` (ID d'aura, tous les rangs) :
  - Guerrier : Shield Wall, Last Stand ;
  - Druide : Barkskin ;
  - Voleur : Evasion ;
  - Chasseur : Deterrence, s'il existe dans le DB2 70532.

**Coût.** S.

**Risque.** Faible.

**Fichiers.**
- `Tests/Packs/Guerrier/PackGuerrier.lua`, `Tests/Packs/Druide/PackDruide.lua`, `Tests/Packs/Voleur/PackVoleur.lua`, `Tests/Packs/Chasseur/PackChasseur.lua`

---

### Packs 6 : `fading` sur Righteous Fury

**Pourquoi.** Seul Blessing a `fading = 60` (`Tests/Packs/Paladin/PackPaladin.lua:98`). Le rappel Righteous Fury (`l.100`) ne prévient que quand le buff manque. Slice and Dice a déjà `warn = 3` (`Tests/Packs/Voleur/PackVoleur.lua:36`) : rien à ajouter, `fading` ne sert qu'aux rappels hors combat.

**Valeur.** Un tank voit avant le pull que Righteous Fury va tomber.

**À faire.**
- Ajouter `fading = 60` à l'entrée Righteous Fury des `reminders` Paladin.

**Coût.** S.

**Risque.** Nul. `fading` est ignoré en variante ForeverAuras (`PackBuilder.lua:453`).

**Fichiers.**
- `Tests/Packs/Paladin/PackPaladin.lua`

---

### Packs 8 : `meleeRange` pour le Chasseur

**Pourquoi.** Cinq classes ont `meleeRange` (Chaman, Druide, Guerrier, Paladin, Voleur), pas le Chasseur.

**Valeur.** Le Chasseur voit quand sa cible est au corps à corps.

**À faire.**
- Ajouter `meleeRange = { { name = "Raptor Strike", spell = 2973 } }` au pack Chasseur. Vérifier l'ID de rang 1 dans le DB2.

**Coût.** S.

**Risque.** Nul. Ignoré en variante ForeverAuras (`PackBuilder.lua:467`).

**Fichiers.**
- `Tests/Packs/Chasseur/PackChasseur.lua`

---

### Packs 1 : Rappels de stock de poisons et de munitions

**Pourquoi.** Seul le Soul Shard a un rappel de stock (`Tests/Packs/Demoniste/PackDemoniste.lua:72`, `item = 6265, below = 1`). Le Voleur n'a qu'un rappel de poison manquant sur l'arme (`enchant`, `PackVoleur.lua:70-71`), sans stock en sac. Le Chasseur n'a aucun rappel de munitions. Les NOTES écartaient ces rappels faute d'ID d'objet : ItemSparse et ItemEffect (build 70532) les donnent maintenant.

**Valeur.** On n'arrive plus en donjon sans poisons ni flèches.

**À faire.**
- Relever dans ItemSparse les ID d'objet des poisons (par rang) et des munitions (flèches, balles).
- Ajouter les entrées `{ name = ..., item = ..., below = ..., known = ... }` dans les `reminders` du Voleur et du Chasseur.
- `PackBuilder.lua:434-437` ne prend qu'un objet par entrée (`itemName = entry.item`) : une entrée par objet, ou seulement le rang le plus courant.

**Coût.** S.

**Risque.** Faible. Un rappel par rang d'objet peut s'afficher à tort quand le joueur porte un autre rang.

**Fichiers.**
- `Tests/Packs/Voleur/PackVoleur.lua`, `Tests/Packs/Chasseur/PackChasseur.lua`
- `NOTES.md` des deux classes

---

## 1.16 : stabilisation

Sortie le 2026-11-07 (1.16.0), puis 1.16.1 le 2026-11-09. Première version après les packs de la 1.15. Corriger les bugs connus avant d'ajouter des fonctionnalités évite de les mêler aux régressions de ce contenu. Packs 5 et 7 demandent une vérification en jeu ou des ID à trancher : ils passent ici, avant Dette 6 (régénération et synchronisation des packs).

### Déjà fait

Entrée du 2026-11-06 de `CHANGES.md`. Banc headless vert à la sortie (124 scénarios, 0 échec). Aucune étape de `SUIVI-BUGS-ET-TESTS.md` ne couvre la 1.16.

- Dette 2 : scénario 91 (version et date de `Changelog.lua`, premier titre de `CHANGELOG.md`, `## Version:` des cinq TOC).
- Dette 9 : durée custom secrète sans timer (scénario 92). Dette 10 : arguments du trigger DBM Timer.
- Dette 11 : signature déjà juste (`RunTriggerFunc` passe l'unité deux fois), scénario 93 sans changement de code.
- Dette 12 : Location, overlays TSU, `modRate`, `%raidMark`, Threat `boss`, format « Modern Blizzard » (« 3m »).
- Dette 13 : `SetAdjustedMax`, synchro des animations de groupe au premier départ seulement (scénario 95),
  mode compress de la texture linéaire (largeur fixe, échelle, progression bornée à 1), spinners circulaires.
- Dette 14 : seuil de 16 Ko, `GetData` hors environnement, callback `C_Timer` retrouvé par uid après renommage.
- Dette 15 : groupe dynamique, renumérotation de `secretFallback`. Dette 16 : menus et multi-sélection.
- Dette 17 : Actions On Hide et couleur Main. Dette 18 : Custom Options, dont la garde de `getUserColor`.
- Dette 19 : sous-régions et placements de tick. Dette 20 : sélecteur de frame, TexturePicker, lignes de milieu.
- Dette 21 : SpinBox, MiniTalent, glisser d'un objet, insertion de lien par `ChatFrameUtil.InsertLink`.
- Dette 22 : profiling, renommage après import, modèles Duration masqués sans Combat Log.
- Dette 23 : StopMotion `anchor_mode`, test atlas (`TextureBase:IsAtlas`).
- Hors tickets : `WeakAuras.SetModel` (unité avant Display Info), filtre de nom avec nom secret, repère de raid et
  GUID de barre de vie secrets (`BuffTrigger2.lua`), « Add to new Modern Aura Group » grisé dans un groupe dynamique.
- Packs 5 : segments de Sunder Armor sur la cible, pack Guerrier. À vérifier en jeu : cumuls secrets en combat.
- Packs 7 : Divine Aegis 431624 ajouté en buff au pack Prêtre. Binding Heal, Setup, Initiative, Reckoning et
  Lightning Overload n'ont pas d'aura (notes des guides), donc hors des packs.
- Dette 6 : `lua5.1 Tests/Packs/Regenerate.lua`, scénario 94, `VerificationPack.lua` lancé par `Tests/run.lua`
  pour chaque pack ; un seul `ForeverAurasExport1.txt` (`Tests/Fixtures/`).
- Dette 8 : `luac.out`, tests de build toujours faux (`WoW80`, `BuildInfo > 80100` de `Model.lua`),
  `flavorFromTocToNumber` retirés. Le reste du ticket est dans « Dette notée, sans ticket ».
- `CLASS_PACK_VERSION` passe à `"1.16.0"` : la notice des packs se réaffiche. Elle vaut `"1.17.0"` depuis la 1.17.0.
- 1.16.1, hors ticket : Proc Glow dans la liste des types de glow, option d'auteur sans nom qui ne casse plus le
  panneau. Testé en jeu.

### Reste ouvert

- Packs 5 : cumuls secrets de Sunder Armor en combat, à tester en jeu. Aucune étape dans le suivi.
- Dette 13 : mode compress de la texture linéaire, test en jeu demandé par le ticket, non fait.
- Non revérifiés dans le code le 2026-11-21 : overlays TSU (Dette 12), `option.default` (Dette 15).

### Ordre

1. Dette 2 : Une seule source pour la version du fork
2. Dette 9 : Bug : durée custom secrète qui coupe la passe d'événements
3. Dette 10 : Bug : trigger DBM Timer, arguments décalés
4. Dette 11 : Bug probable : Spell Cast Succeeded, `spellId` reçoit `castBarID`
5. Dette 12 : Bug : triggers, valeurs perdues ou absentes
6. Dette 13 : Bug : régions, état ou rendu faux
7. Dette 14 : Bug : environnement d'aura
8. Dette 15 : Bug : données d'aura
9. Dette 16 : Bug : multi-sélection et menus de la liste d'auras
10. Dette 17 : Bug : options Actions et Animations
11. Dette 18 : Bug : options d'auteur (Custom Options)
12. Dette 19 : Bug : sous-régions
13. Dette 20 : Bug : outils d'édition
14. Dette 21 : Bug : widgets AceGUI
15. Dette 22 : Bug : divers (profiling, import, modèles)
16. Dette 23 : Bug : options visibles à tort (StopMotion, textures atlas)
17. Packs 5 : Segments de Sunder Armor
18. Packs 7 : Procs absents des guides
19. Dette 6 : Packs : une commande de régénération et une vérification de synchronisation
20. Dette 8 : Retirer le code mort interne

---

### Dette 2 : Une seule source pour la version du fork

**Pourquoi.** La version de Musca Auras vit à deux endroits sans lien entre eux :
- `WeakAurasOptions/Changelog.lua:13` : `versionString '1.14.0'` et `dateString` en dur ;
- le premier titre de `WeakAuras/CHANGELOG.md`.

`.github/workflows/release.yml:34-37` ne contrôle que `CHANGELOG.md`. La version d'origine `5.22.0` est aussi écrite en dur dans `WeakAuras/Init.lua:384`, en plus de `WeakAuras/WeakAuras.toc:8`.

**Valeur.** Une fenêtre « Quoi de neuf » toujours à jour. Prépare Rebranding 4.

**À faire.**
- Ajouter un scénario headless qui compare `versionString` et `dateString` de `Changelog.lua` au premier titre de `WeakAuras/CHANGELOG.md`.
- Ou générer `Changelog.lua` à partir de `CHANGELOG.md`, sur le modèle de `Tests/Packs/Embed*.lua`.

**Coût.** S.

**Risque.** Nul.

**Fichiers.**
- `WeakAurasOptions/Changelog.lua`
- `WeakAuras/CHANGELOG.md`
- Nouveau scénario dans `Tests/Scenarios/`

---

### Dette 9 : Bug : durée custom secrète qui coupe la passe d'événements

Ajouté le 2026-10-27, après la chasse aux bugs sur les fichiers d'origine modifiés pour Forever.

**Pourquoi.** Dans `Private.ActivateEvent` (`GenericTrigger.lua:576-631`), la `durationFunc` d'un trigger custom est appelée sous `xpcall`, mais ses retours sont ensuite comparés hors `xpcall`. En jeu, une valeur secrète a le type `number`, donc `type(arg1) == "number"` (l.577-578) la laisse passer. Exemple : `return aura.duration, aura.expirationTime` sous restriction. Trois comparaisons lèvent alors une erreur :
- `state.value ~= arg1` (l.608) ;
- `arg2 <= arg1` (l.624) ;
- `arg1 > 0.01` (l.631).

`RunTriggerFunc` et `Private.ScanEventsInternal` (l.1058) ne sont pas protégés. L'erreur interrompt la boucle :
- les autres auras du même événement ne sont pas mises à jour ;
- `Private.ActivateAuraEnvironment` et `Private.cdmScanBatch` ne sont pas restaurés ;
- l'erreur part vers `geterrorhandler` sans le filtre « secret » de `waErrorHandler` (`WeakAuras.lua:107`).

Le cas voisin est déjà gardé : `callFunctionForActivateEvent` (l.543) teste `Private.IsSecret` sur les retours de name, icon, texture et stacks.

**Valeur.** Une aura custom qui renvoie une durée secrète se dégrade seule, sans bloquer les autres auras ni afficher d'erreur Lua.

**À faire.**
- Après le `xpcall` de la l.576, traiter `Private.IsSecret(arg1, arg2)` comme un échec. Reprendre le repli de l'état de repli (l.5488-5495) : `progressType = "timed"`, `duration = 0`, `expirationTime = math.huge`.
- Ajouter un scénario headless. Le banc emballe les secrets en userdata, donc `type()` ne rend pas `number` : simuler un secret de type number pour reproduire le cas, ou tester directement le chemin `IsSecret`.

**Coût.** S.

**Risque.** Faible. Le chemin n'est atteint que par des durées custom.

**Fichiers.**
- `WeakAuras/GenericTrigger.lua`
- Nouveau scénario dans `Tests/Scenarios/`

---

### Dette 10 : Bug : trigger DBM Timer, arguments décalés

**Pourquoi.** Dans `BossMods.lua` (l.578, 593, 614, 623, 629), `isBarEnabled` est passé à la place du paramètre `noCastBar`. Le filtre « barre activée » ne s'applique donc pas, et `noCastBar` reçoit une valeur qui n'a pas de rapport. Amont.

**À faire.** Passer les arguments dans l'ordre de la signature : `triggerId, triggerDbmType, nil, isBarEnabled`.

**Coût.** S.

**Fichiers.**
- `WeakAuras/BossMods.lua`

---

### Dette 11 : Bug probable : Spell Cast Succeeded, `spellId` reçoit `castBarID`

**Pourquoi.** Dans `Prototypes.lua:7114-7116`, deux args vides se suivent (`{}` et `{ -- castGUID }`). Le générateur (`GenericTrigger.lua:353-400`) écrit un `_` par arg vide. La signature générée est donc `(state, counter, event, unit, _, _, spellId)`. Or le payload Forever de `UNIT_SPELLCAST_SUCCEEDED` est `unitTarget, castGUID, spellID, castBarID` (`UnitDocumentation.lua:4852-4855`). `spellId` reçoit donc `castBarID`, et le filtre par sort ne marche pas. Le scénario 89 utilise un trigger custom et ne couvre pas ce prototype.

**À faire.**
- Confirmer en jeu : `/dump` sur un trigger Spell Cast Succeeded, ou scénario headless qui envoie le payload Forever.
- Retirer une des deux entrées vides.
- Ajouter le scénario headless.

**Coût.** S.

**Fichiers.**
- `WeakAuras/Prototypes.lua`
- Nouveau scénario dans `Tests/Scenarios/`

---

### Dette 12 : Bug : triggers, valeurs perdues ou absentes

**Pourquoi.** Six défauts indépendants, chacun sur un chemin atteignable :
- **Location** (`Prototypes.lua:9671-9677`) : l'arg `instance` a `store = true` sans `init`. Le store (`GenericTrigger.lua:462-470`) écrit `state.instance = instance`, qui vaut nil. `instanceName`, déclaré l.9594, n'est jamais utilisé.
- **Overlays TSU** (`GenericTrigger.lua:4963`) : `local count = 0` masque le compteur de la portée englobante. Le nombre d'overlays reste faux.
- **modRate** (`GenericTrigger.lua:5161`) : `modRate = varData.modRate` au lieu de `modRateProperty`. Amont.
- **`%raidMark` vide** (`BuffTrigger2.lua:1792-1794`) : `UpdateStateWithNoMatch` est appelé sans `mark`.
- **Threat** (`Types.lua:1252`) : `threat_unit_types.boss` n'est pas retiré dans le bloc Forever (l.4174-4209).
- **Format de temps « Modern Blizzard »** (`Types.lua:105`) : l'entrée `[2]` n'a pas de formateur dans `simpleFormatters.time` (l.191-220). Elle retombe sur `[99]` (l.365-367).

**À faire.**
- Location : `init = "instanceName"`.
- TSU : retirer `local`.
- modRate : lire `varData.modRateProperty`.
- raidMark : passer `mark` à `UpdateStateWithNoMatch`.
- Threat : `Private.threat_unit_types.boss = nil` dans le bloc Forever.
- Format de temps : ajouter le formateur `[2]`, ou retirer l'entrée si Forever n'en a pas l'équivalent.

**Coût.** S.

**Fichiers.**
- `WeakAuras/Prototypes.lua`
- `WeakAuras/GenericTrigger.lua`
- `WeakAuras/BuffTrigger2.lua`
- `WeakAuras/Types.lua`

---

### Dette 13 : Bug : régions, état ou rendu faux

**Pourquoi.**
- **`SetAdjustedMax`** (`RegionPrototype.lua:405-414`) : ne remet pas à nil `adjustedMax` ni `adjustedMaxRelPercent`, contrairement à `SetAdjustedMin`. Un max ajusté reste appliqué après retour à la valeur par défaut.
- **Synchro des animations** (`Animations.lua:347`) : `not anim.duration_type == "relative"` est toujours faux. La synchro des animations Main entre frères de groupe ne tourne jamais. Amont.
- **Mode compress de la texture linéaire** (`LinearProgressTexture.lua:219-233`) : `self:SetWidth` modifie `self.width` (l.334-341), qui rétrécit à chaque tick. Les `startProgress` et `endProgress` recalculés sont des locaux jamais relus.
- **Spinners circulaires** (`RegionTypes/ProgressTexture.lua:385-430`) : `ApplyAdditionalProgressCircular` ne cache pas les spinners en trop dans la branche `if additionalProgress`.

**À faire.**
- `SetAdjustedMax` : même remise à nil que `SetAdjustedMin`.
- `Animations.lua:347` : `anim.duration_type ~= "relative"`.
- Compress : calculer à partir d'une largeur de référence fixe, et utiliser les progressions recalculées.
- Spinners : `hideExtraTextures(self.extraSpinners, #additionalProgress + 1)`.

**Coût.** S à M (le mode compress demande un test en jeu).

**Fichiers.**
- `WeakAuras/RegionTypes/RegionPrototype.lua`
- `WeakAuras/Animations.lua`
- `WeakAuras/BaseRegions/LinearProgressTexture.lua`
- `WeakAuras/RegionTypes/ProgressTexture.lua`

---

### Dette 14 : Bug : environnement d'aura

**Pourquoi.**
- **Seuil d'avertissement** (`AuraEnvironment.lua:283`) : `16 * 1024 * 1024`, soit 16 Mo au lieu de 16 Ko. L'avertissement ne se déclenche jamais.
- **`GetData` hors environnement** (`AuraEnvironment.lua:537`) : `getDataCallCounts[currentId] + 1` lève une erreur quand `current_uid` vaut nil.
- **C_Timer après renommage** (`AuraEnvironmentWrappedSystems.lua:27`) : `OnRename` déplace le wrapper, mais sa closure garde l'ancien id. Après renommage, le callback tourne sans `aura_env` et sans `xpcall`.

**À faire.**
- `16 * 1024`.
- `(getDataCallCounts[currentId] or 0) + 1`, avec une garde quand `currentId` vaut nil.
- `OnRename` : `wrappers[oldId] = nil` sans déplacer le wrapper, qui sera recréé avec le nouvel id.

**Coût.** S.

**Fichiers.**
- `WeakAuras/AuraEnvironment.lua`
- `WeakAuras/AuraEnvironmentWrappedSystems.lua`

---

### Dette 15 : Bug : données d'aura

**Pourquoi.**
- **Groupe dynamique** (`WeakAuras.lua:2967`) : `data.type == "dynamicgroup"` au lieu de `data.regionType`. La branche ne s'exécute jamais. L'impact visible reste à mesurer.
- **Options custom** (`WeakAuras.lua:2985`, `:2991`) : `not option.default == nil` est toujours faux. La validation des valeurs par défaut des options custom ne s'applique pas. Amont.
- **`secretFallback`** (`TriggerOptions.lua`, `moveTriggerDownImpl` l.350-380 et suppression l.494-510) : quand on déplace ou supprime un trigger, `data.triggers.secretFallback` n'est pas renuméroté. Le repli pointe alors sur un autre trigger, ou sur aucun. Propre au fork.

**À faire.**
- `data.regionType == "dynamicgroup"`.
- `option.default ~= nil`.
- Renuméroter `secretFallback` au déplacement et à la suppression d'un trigger, comme les autres références à un numéro de trigger.

**Coût.** S.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/TriggerOptions.lua`

---

### Dette 16 : Bug : multi-sélection et menus de la liste d'auras

**Pourquoi.**
- **Entrée de menu en double** (`WeakAurasOptions.lua:452`) : `menu[2].text = "|cFF777777"..menu[1].text` recopie le libellé de la première entrée.
- **Multi-sélection perdue** (`WeakAurasOptions.lua:1762`) : `IsDisplayPicked(data)` reçoit la table au lieu de `data.id`, et rend toujours faux.
- **Menu « Copy settings »** (`AceGUIWidget-WeakAurasDisplayButton.lua:308-309`, `:319-320`) : `copyAuthorOptionsEntry` et `copyUserConfigEntry` sont remplacées par nil ou une chaîne, au lieu de modifier leur `.text`.

**À faire.**
- `menu[2].text = "|cFF777777"..menu[2].text`.
- `IsDisplayPicked(data.id)`.
- Écrire dans `.text` des deux entrées.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/WeakAurasOptions.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`

---

### Dette 17 : Bug : options Actions et Animations

**Pourquoi.**
- **Glow On Hide** (`ActionOptions.lua:1084`, `:1105`) : teste `start.glow_type` au lieu de `finish.glow_type`. Les options de glow On Hide s'affichent selon le réglage On Show.
- **Ordre des options On Hide** (`ActionOptions.lua:1037`, `:1053`) : `order` vaut 10.801 et 10.802 au lieu de 30.801 et 30.802. Les deux options s'affichent dans le bloc On Show.
- **Couleur de l'animation Main** (`AnimationOptions.lua:680`, `:686`, `:692`, `:698`) : le `set` de `main_color` écrit dans `{"animation","finish",...}` au lieu de `main`. Le réglage est perdu.

**À faire.** Corriger les chemins et les `order` dans les deux fichiers.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/ActionOptions.lua`
- `WeakAurasOptions/AnimationOptions.lua`

---

### Dette 18 : Bug : options d'auteur (Custom Options)

**Pourquoi.**
- **Onglet Custom Options** (`AuthorOptions.lua:381`) : `childOption.path` vaut nil, au lieu de `optionData.path`.
- **`getUserColor`** (`AuthorOptions.lua:540-542`) : la fonction fait `return` dans la boucle. Un conflit de couleur entre enfants n'est jamais détecté.
- **Champ Max** (`AuthorOptions.lua:1886`) : `desc(option, "min")` au lieu de `"max"`. La description du champ Max affiche celle du Min.
- **Multiselect** (`AuthorOptions.lua:2379-2385`) : la suppression passe par TimeMachine, puis la l.2385 refait un `tremove`. Deux entrées sont supprimées au lieu d'une.

**À faire.**
- `optionData.path`.
- `getUserColor` : parcourir tous les enfants avant de rendre le résultat.
- `desc(option, "max")`.
- Retirer le `tremove` de la l.2385, après avoir vérifié que TimeMachine applique bien la suppression.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/AuthorOptions.lua`

---

### Dette 19 : Bug : sous-régions

**Pourquoi.**
- **Suppression d'une sous-région servant d'ancre** (`SubRegionCommon.lua:32`) : `ReplacePrefix` concatène `deleteCondition`, qui est une table. Supprimer une sous-région référencée par une autre (`sub.N.`) lève une erreur.
- **Placements de tick** (`SubRegionOptions/Tick.lua:303`) : `tremove(data.tick_placements, i)` ne décale pas `data.progressSources`, lu en parallèle (`SubRegionTypes/Tick.lua:514`). Après suppression, les ticks suivants prennent la mauvaise source.

**À faire.**
- `SubRegionCommon.lua:32` : passer la bonne chaîne à la concaténation.
- `Tick.lua:303` : `tremove(data.progressSources, i)` avec le même indice.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/SubRegionOptions/SubRegionCommon.lua`
- `WeakAurasOptions/SubRegionOptions/Tick.lua`

---

### Dette 20 : Bug : outils d'édition

**Pourquoi.**
- **Sélecteur de frame** (`FrameChooser.lua:86`) : `focusIsGroup = focusIsGroup` au lieu de `isGroup`. En plus (l.21-22), `oldFocus` et `oldFocusName` ne sont pas remis à nil dans `StartFrameChooser` : l'état d'un lancement précédent est repris.
- **TexturePicker, Cancel** (`TexturePicker.lua:337-348`) : `CancelClose` ne restaure pas `width` et `height`, modifiés par `SetAll` avec `adjustSize`.
- **Lignes de milieu** (`MoverSizer.lua:838`) : `self:CreateMiddleLines()` est appelé sans `sizerPoint`.

**À faire.**
- `focusIsGroup = isGroup`, et remise à nil de `oldFocus` / `oldFocusName` au lancement.
- Sauvegarder `width` / `height` à l'ouverture du picker et les restaurer dans `CancelClose`.
- Passer `sizerPoint` à `CreateMiddleLines`.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/FrameChooser.lua`
- `WeakAurasOptions/OptionsFrames/TexturePicker.lua`
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`

---

### Dette 21 : Bug : widgets AceGUI

**Pourquoi.**
- **SpinBox en pourcentage** (`AceGUIWidget-WeakAurasSpinBox.lua:104-106`) : `tonumber(value) / 100` lève une erreur sur une saisie vide ou non numérique.
- **MiniTalent** (`AceGUIWidget-WeakAurasMiniTalent.lua:150`) : `ceil(shown / 11)`, alors que le placement met 9 icônes par ligne (l.144). La hauteur est fausse. Propre au fork.
- **Glisser un objet** (`AceGUIWidget-WeakAurasMultiLineEditBox.lua:116-129`, et pareil dans `AceGUIWidget-WeakAurasMultiLineEditBoxWithEnter.lua:122-135`) : le 4e retour de `GetCursorInfo` vaut nil pour un objet, donc `Insert(nil)`.
- **Insertion de lien** (`AceGUIWidget-WeakAurasMultiLineEditBoxWithEnter.lua:31`) : cherche `_G[("MultiLineEditBox%uEdit"):format(i)]`, alors que le vrai nom est `Type .. i .. "Edit"` avec `Type = "WeakAuras-MultiLineEditBoxWithEnter"` (l.7, l.353). Le shift-clic d'un lien n'insère rien.

**À faire.**
- SpinBox : ignorer une saisie non numérique.
- MiniTalent : `ceil(shown / 9)`.
- Glisser : insérer le lien (3e retour) quand le type vaut `"item"`, dans les deux widgets.
- Insertion de lien : `_G[Type .. i .. "Edit"]`.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasSpinBox.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMultiLineEditBox.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMultiLineEditBoxWithEnter.lua`

---

### Dette 22 : Bug : divers (profiling, import, modèles)

**Pourquoi.**
- **Profiling, total** (`Profiling.lua:421`) : `AddText` reçoit deux arguments, et le total en ms n'est pas affiché.
- **Profiling, tri par pic** (`Profiling.lua:422`) : `"spike"` est passé à `ipairs` au lieu de `SortProfileMap`. Le tri par pic ne s'applique pas.
- **Renommage après mise à jour d'import** (`WeakAurasOptions/OptionsFrames/Update.lua:2171`) : `targetName[aura.uid]` au lieu de `targetNames[...]`. Amont.
- **Modèles « Duration »** (`WeakAurasTemplates/TriggerTemplates.lua:308`, `createDurationTrigger`) : ils créent un trigger Combat Log, inerte sur Forever. Aucune garde `hasCombatLog` dans les modèles.

**À faire.**
- `Profiling.lua:421` : concaténer en un seul argument.
- `Profiling.lua:422` : passer par `SortProfileMap`.
- `Update.lua:2171` : `targetNames[aura.uid]`.
- Modèles : masquer les modèles Duration quand `Private.hasCombatLog` est faux, ou les rebrancher sur un trigger qui marche sur Forever.

**Coût.** S.

**Fichiers.**
- `WeakAuras/Profiling.lua`
- `WeakAurasOptions/OptionsFrames/Update.lua`
- `WeakAurasTemplates/TriggerTemplates.lua`

---

### Dette 23 : Bug : options visibles à tort (StopMotion, textures atlas)

**Pourquoi.** Deux défauts d'affichage des options, hérités de WeakAuras :
- **Scale Factor de StopMotion** (`WeakAurasOptions/SubRegionOptions/StopMotion.lua:292`) : la condition lit `data.anchorMode`, alors que la clé réelle est `data.anchor_mode` (l.276, l.298, `WeakAuras/SubRegionTypes/StopMotion.lua:32`). Sur une barre, en ancrage `area` / `fg` avec « Clipped by Foreground », l'option « Scale Factor » reste visible. Le rendu ignore pourtant `scale` dans ce cas (`SubRegionTypes/StopMotion.lua:205-216`).
- **`IsAtlas` appelé avec un point** : `Private.TextureBase:IsAtlas(input)` est déclarée avec `:` (`WeakAuras/BaseRegions/Texture.lua:41`). Les appels `TextureBase.IsAtlas(x)` passent `x` comme `self`, donc `input` vaut nil et le test rend toujours faux. Pour une texture atlas, « Allow Full Rotation » et « Texture Wrap » restent affichés sans effet : le rendu ignore `canRotate` sur un atlas (`BaseRegions/Texture.lua:66`). Appels concernés :
  - `WeakAurasOptions/SubRegionOptions/Texture.lua:87`, qui lit en plus `data.texture` au lieu de `data.textureTexture` ;
  - `WeakAurasOptions/RegionOptions/Texture.lua:85` et `:92`.

**À faire.**
- `StopMotion.lua:292` : `data.anchor_mode`.
- Remplacer les trois appels par `TextureBase:IsAtlas(...)`, et lire `data.textureTexture` dans la sous-région.
- Le `hidden` de ces options est évalué une seule fois, à la construction des options. Le passer en fonction pour qu'il suive un changement de texture.

**Coût.** S.

**Fichiers.**
- `WeakAurasOptions/SubRegionOptions/StopMotion.lua`
- `WeakAurasOptions/SubRegionOptions/Texture.lua`
- `WeakAurasOptions/RegionOptions/Texture.lua`

---

### Packs 5 : Segments de Sunder Armor

**Pourquoi.** Le guide `Classes/Guides/Warrior.md` le demande. Le Sunder est suivi en icône avec cumuls (`Tests/Packs/Guerrier/PackGuerrier.lua:65`, `stacks = true, anyCaster = true`), sans segments. `segments.aura` existe déjà (Maelstrom du Chaman, `PackBuilder.lua:508-522`). Un debuff sur la cible n'est pas exclu des filtres : seuls ceux sur le joueur le sont.

**Valeur.** Les 5 cumuls de Sunder lisibles d'un coup d'œil.

**À faire.**
- Ajouter `segments = { name = "Sunder Armor", count = 5, aura = { 7386, 7405, 8380, 11596, 11597 }, ... }` au pack Guerrier, unité cible.

**Coût.** S.

**Risque.** Les cumuls d'aura sont secrets en combat : vérifier en jeu que les segments s'affichent quand même. C'est pourquoi il passe en 1.16 et pas en 1.15.

**Fichiers.**
- `Tests/Packs/Guerrier/PackGuerrier.lua`

---

### Packs 7 : Procs absents des guides

**Pourquoi.** Les guides `Classes/Guides/*.md` citent des procs absents des packs. Aucun n'apparaît dans les `Pack*.lua`.

**Valeur.** Les procs annoncés dans les guides s'affichent.

**À faire.**
- Trancher les ID d'aura dans le DB2 70532, puis les ajouter aux `procs` :
  - Voleur : Setup, Initiative ;
  - Prêtre : Divine Aegis, Binding Heal ;
  - Paladin : Reckoning ;
  - Chaman : Lightning Overload.
- Retirer du guide un proc absent du DB2.

**Coût.** S à M.

**Risque.** Faible. Un ID douteux reste hors du pack.

**Fichiers.**
- `Tests/Packs/*/Pack*.lua`, `Classes/Guides/*.md`

---

### Dette 6 : Packs : une commande de régénération et une vérification de synchronisation

**Pourquoi.** Chaque pack existe en trois copies commitées :
- la source `Tests/Packs/<Classe>/Pack<X>.lua` (qui appelle `PackBuilder.lua`) ;
- la chaîne encodée `Pack<X>.txt` (et `Pack<X>ForeverAuras.txt` avec `PACK_TARGET=ForeverAuras`) ;
- la chaîne embarquée dans `WeakAurasOptions/ClassPacks.lua` ou `UtilityPacks.lua` (`EmbedClassPacks.lua`, `EmbedUtilityPacks.lua`).

La régénération se fait à la main, en plusieurs étapes décrites dans les en-têtes « usage ». Le scénario 86 compare l'embarqué aux `.txt` pour les packs utilitaires, mais rien ne vérifie que les `.txt` correspondent au builder, ni les variantes ForeverAuras. Les `Verification*.lua` se lancent à la main (`PACK=`) et pas par `run.lua`. `ForeverAurasExport1.txt` est présent en double (`Tests/Fixtures/` et `Tests/Packs/`).

**Valeur.** Un pack modifié ne peut plus être livré à moitié régénéré.

**À faire.**
- Un script Lua unique qui régénère `.txt`, `ForeverAuras.txt`, `ClassPacks.lua` et `UtilityPacks.lua` dans l'ordre (pas de Python : `python3` est l'alias Microsoft Store sur le poste).
- Un scénario qui reconstruit chaque pack depuis sa source et le compare au `.txt` et à l'embarqué.
- Brancher `VerificationPack.lua` sur tous les packs dans `run.lua`, ou dans ce scénario.
- Garder un seul `ForeverAurasExport1.txt`.

**Coût.** M.

**Risque.** Faible. La comparaison doit ignorer ce que l'encodage rend non déterministe (ordre des clés), sinon le scénario échoue sans raison.

**Fichiers.**
- `Tests/Packs/PackBuilder.lua`, `EmbedClassPacks.lua`, `EmbedUtilityPacks.lua`, `VerificationPack.lua`, `AuraTool.lua`
- `Tests/run.lua`
- Nouveau scénario dans `Tests/Scenarios/`

---

### Dette 8 : Retirer le code mort interne

**Pourquoi.**
- `WeakAuras/luac.out` (644 lignes) : artefact de compilation commité, absent du toc.
- Tests de build toujours faux sur Forever (Interface 16001, build 1.60.1) : `WoW80` dans `WeakAurasOptions/AceGUI-Widgets/AceGUIContainer-WeakAurasTreeGroup.lua:12`, `WeakAuras.BuildInfo > 80100` dans `WeakAurasOptions/RegionOptions/Model.lua:18` et `:41`.
- `flavorFromTocToNumber` (`WeakAuras/Init.lua:395-402`) liste 6 saveurs, dont 5 impossibles avec `X-Flavor: Vanilla`.
- Le stub de données « minimal data stub which prevents false positives in diff » est copié 3 fois : `WeakAuras.lua:3144` (`oldDataStub`), `WeakAuras.lua:3192` (`oldDataStub2`), `Types.lua:3636` (`Private.data_stub`).

**Valeur.** Moins de code à lire et à relire. Aucune branche trompeuse.

**À faire.**
- Supprimer `luac.out`.
- Remplacer les tests toujours vrais par leur branche vraie.
- Faire pointer les deux stubs de `WeakAuras.lua` vers `Private.data_stub`, après avoir vérifié qu'ils sont identiques.
- Garder les fonctions publiques `WeakAuras.IsRetail`, `IsClassic`, `IsClassicEra`… : le code custom des auras importées peut les appeler.

**Coût.** S.

**Risque.** Faible. Un stub modifié par erreur fausse le diff des imports (`OptionsFrames/Update.lua`) : relancer les scénarios d'import (16, 42).

**Fichiers.**
- `WeakAuras/luac.out`
- `WeakAuras/Init.lua`, `WeakAuras/WeakAuras.lua`, `WeakAuras/Types.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIContainer-WeakAurasTreeGroup.lua`
- `WeakAurasOptions/RegionOptions/Model.lua`

---

## 1.17 : placement

Sortie le 2026-11-12 (1.17.0). Dette 7 est passée d'abord : les tickets de placement ajoutent des scénarios. Dette 1 a corrigé `MoverSizer.lua` avant qu'on le retravaille. Placement 7 reste ouvert, en 1.22 : les liens d'ancrage de la 1.17.0 en couvrent l'essentiel.

### Contexte du placement

Deux outils placent aujourd'hui les auras, sans logique commune :

- `WeakAuras/EditModePlacement.lua` : mode édition Blizzard. Il place les auras de premier niveau ancrées à l'écran et les cale sur la grille Blizzard au lâcher (un fantôme montre la place calée pendant le glisser depuis Placement 3).
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua` : déplacement dans `/wa`. Il cale sur les bords des autres auras et sur le centre de l'écran, sans grille régulière.

Contraintes API (source Forever 1.60.1.70532) :

- Aucune API publique ne permet d'inscrire une frame d'addon dans le mode édition.
- `EditModeMagnetismManager`, `EditModeGridMixin` et `ProcessMovementKey` sont des internes Blizzard. Les appeler ou les hooker expose au taint : recopier leur logique.
- Lectures sans risque : `EditModeManagerFrame:IsEditModeActive()`, callbacks `EditMode.Enter` et `EditMode.Exit`, `EditModeManagerFrame.Grid:IsShown()`, `EditModeManagerFrame.Grid.gridSpacing` (défaut 100, de 20 à 300).

### Déjà fait

Entrées du 2026-11-08 au 2026-11-12 de `CHANGES.md`. Aucune étape de `SUIVI-BUGS-ET-TESTS.md` ne couvre la 1.17 : les « À vérifier en jeu » ci-dessous restent ouverts.

- Dette 7 : `Tests/Harness/Assertions.lua` (`Same`, `Near`, seuls helpers identiques), filtre de `run.lua` par numéro
  ou par nom, sans les packs. Aucun scénario migré : migration au fil des modifications.
- Dette 1 : `parentData.regionType == "dynamicgroup"`, coin fixe opposé au bord tiré (calage juste sur les bords
  droit et haut). À vérifier en jeu : redimensionner un enfant de groupe dynamique dans `/wa`, puis contrôler ses
  offsets.
- Placement 2 : arrondi à l'unité au lâcher (`OnDragStop`, `doneMoving`) et en fin de redimensionnement
  (`doneSizing` : largeur ou hauteur et offsets modifiés, sur les axes que le bord tiré déplace), sauf sur un axe calé sur une ligne de grille ou
  d'alignement, qui garde sa valeur exacte. Les flèches de `moveOnePxl` arrondissent l'offset puis avancent d'une
  unité. Le banc gagne `math.round` (`Round = math.round` dans `MathUtil.lua`), jusque-là remplacé par un stub qui
  rendait 0, et charge `MoverSizer.lua` (scénario 96). À vérifier en jeu : glisser une aura dans `/wa` puis
  cliquer sur les flèches ; redimensionner une aura ; caler une aura de largeur impaire sur une ligne ; arrondi
  des demis par le client (`/dump Round(0.5), Round(1.5), Round(-0.5), Round(-1.5)`).
- Placement 1 : lignes des bords d'écran avec l'aimantation, et bouton « Grille » (`gridAlign`, désactivé par défaut)
  qui ajoute les lignes de la grille du mode édition, centrées sur l'écran, au pas de
  `EditModeManagerFrame.Grid.gridSpacing` (100 sans grille du client). Pas de réglage propre du pas. Les lignes
  restent tirées du pool existant, seulement quand elles sont mises en évidence. À vérifier en jeu : activer
  « Grille », glisser et redimensionner une aura près d'une ligne de grille et d'un bord d'écran, comparer avec la
  grille du mode édition ; aspect de l'icône du bouton (`square_border_1px`) ; barre d'outils à la largeur
  minimale de la fenêtre (750) en frFR, la case du CDM ne doit pas déborder.
- Placement 3 : boîte fantôme jaune (`box.snapPreview`) à la position calée pendant le glisser dans le mode édition,
  par un `OnUpdate` posé au début du glisser et retiré au lâcher (`PreviewSnap`, `StopPreview`). Cachée quand aucun
  axe n'est près d'une ligne. À vérifier en jeu : glisser une aura près d'une ligne de la grille du mode édition,
  le fantôme doit montrer la place du lâcher ; couleur et lisibilité du fantôme.
- Placement 5 : flèches du clavier, 1 unité (10 avec Maj), sur la boîte cliquée en dernier dans le mode édition et
  sur l'aura du déplaceur `/wa` (pas avec « Verrouiller les positions »). L'axe non déplacé garde sa valeur. Clavier
  rendu au jeu en combat. Sélection suivie au renommage, perdue à la suppression et au clic sur un cadre Blizzard
  (`hooksecurefunc` sur `SelectSystem`, sans appel à `ClearSelectedSystem`, pour éviter le taint). À vérifier en
  jeu : flèches avec et sans Maj dans les deux outils ; entrée en combat touche tenue ; saisie dans un champ de
  texte du dialogue Blizzard pendant qu'une aura est sélectionnée ; clic sur un cadre Blizzard puis flèches.
- Placement 4 : moteur de calage commun `WeakAuras/PlacementSnap.lua`, utilisé par le déplaceur `/wa` et le mode
  édition. Le mode édition cale aussi sur les bords et centres des autres boîtes et sur les bords d'écran, dès que
  l'option d'aimantation du mode édition est active, grille affichée ou non. Ligne d'aura prioritaire sur une ligne
  de grille plus proche, Ctrl pour les centres, Maj pour ne pas caler. Distance stricte (< 8). À vérifier en jeu :
  dans le mode édition, glisser une aura près du bord d'une autre, avec et sans Ctrl, avec Maj, grille cachée puis
  affichée ; même geste dans `/wa` avec « Aligner magnétiquement » et « Grille ».
- Placement 6 : enfants de groupe simple (groupes imbriqués compris) placables dans le mode édition, boîte au-dessus
  de celle du groupe ; Alt sur la boîte d'un enfant sélectionne et déplace son groupe, que ses enfants peuvent couvrir.
  Enfants de groupe dynamique et de Modern Aura Group toujours exclus. Pas de calage d'une boîte sur son groupe ni ses
  enfants. Offsets relatifs au groupe, groupes ajoutés de nouveau au lâcher pour recalculer leur boîte. À vérifier en
  jeu : glisser un enfant d'un groupe simple, la boîte du groupe doit suivre ; groupe mis à l'échelle ; annuler dans
  `/wa`, la boîte du groupe doit revenir ; « Revert All Changes » ; Alt + glisser sur un enfant ; enfant d'un groupe
  dynamique ou d'un Modern Aura Group sans boîte.
- Suivis de Placement 5 et 6 : l'annulation et le rétablissement ajoutent de nouveau les groupes de l'aura
  (`TimeMachine`, effet `add`), le déplaceur et la bordure d'un groupe dans `/wa` suivent ; Alt remonte d'un niveau
  par clic dans des groupes imbriqués, puis revient au premier groupe ; aucune région créée pour un enfant de groupe
  dynamique à l'entrée du mode édition ; flèches de `/wa` rendues au jeu en multi-sélection, pendant le glisser et
  pour un enfant de groupe dynamique. À vérifier en jeu : dans `/wa`, déplacer un enfant de groupe, annuler, la
  bordure du groupe doit revenir ; Alt + clics successifs sur un enfant de groupes imbriqués ; multi-sélection puis
  flèches (la caméra ou le personnage doit répondre) ; taint après un clic sur un cadre Blizzard (`/console
  taintLog 1`).
- Grille aimantée visible dans `/wa` : avec « Grille », la grille est dessinée sur tout l'écran tant que `/wa` est
  ouvert, lignes centrales plus marquées, redessinée au changement de taille de l'écran. Pas propre `gridSpacing`
  (64 par défaut, curseur de 8 à 128 au clic droit sur « Grille »), qui remplace le pas de la grille du mode édition
  dans `/wa` ; pas enregistré hors bornes ramené entre 8 et 128. Le mode édition garde la grille Blizzard, et la
  grille de `/wa` est cachée tant que le mode édition est ouvert. À vérifier en jeu : clic droit sur « Grille », bouger le
  curseur, la grille doit suivre ; aura glissée près d'une ligne ; fermer `/wa`, la grille doit disparaître ;
  lisibilité des lignes sur un décor clair ; curseur lisible au-dessus de la liste des auras.
- Placement 9 : bords des petits groupes (`snapInsetX`, `snapInsetY`, `EditModePlacement.lua`).
- Placement 8 : lignes du milieu de l'écran (`ScreenLines`, `PlacementSnap.lua`).
- Placement 10 : même seuil (10) et Ctrl pour les centres dans les deux outils.
- Placement 11 : offsets affichés à côté de la boîte pendant le glisser.
- Placement 12 : aura de référence mise en évidence (`ColorBoxes`).
- Placement 13 : ligne d'espacement égal (`AddSpacingLines`). Guide borné : non revérifié à part le 2026-11-21.
- Placement 14 : poignée de redimensionnement aimantée du mode édition (`DropSize`, `OnSizerDown`, `OnSizerUp`).
- Placement 15 : bloc « Align Selection » en multi-sélection dans `/wa` (`PlacementSnap.AlignShifts`,
  `DisplayOptions.lua`).
- Hors tickets : mode placement `/wa unlock` (scénario 99), panneau de placement (X, Y, taille, croissance du groupe
  dynamique), liens d'ancrage (bouton « Link », menu d'ancrage du mode édition, scénario 98), clic droit sur une
  boîte, nouveau look de la fenêtre `/wa`, popup « Quoi de neuf 1.17 », partie placement du Guide.

### Ordre

1. Dette 7 : Bibliothèque commune pour les scénarios et filtre dans `run.lua`
2. Dette 1 : Bug : enfant de groupe dynamique redimensionné
3. Placement 2 : Offsets arrondis au lâcher
4. Placement 1 : Grille régulière et bords d'écran dans le déplacement `/wa`
5. Placement 3 : Aperçu du calage en direct dans le mode édition
6. Placement 5 : Déplacement aux flèches du clavier
7. Placement 4 : Un seul moteur de calage pour les deux outils
8. Placement 6 : Enfants de groupe simple dans le mode édition

---

### Dette 7 : Bibliothèque commune pour les scénarios et filtre dans `run.lua`

**Pourquoi.** Les scénarios `*Contract` (31 à 51) redéfinissent chacun leurs helpers d'assertion : `Near`, `Same`, `Rule`, `Change`, `Recorder` (`43_ConditionsContract.lua:9-51`), `Fmt`, `DumpTree`, `Case`, `Probe` (`31_OptionsContract.lua:14-134`). `Tests/Harness/` ne contient que le banc. `run.lua:115-135` lance tous les scénarios à la suite, sans filtre, un processus `lua` par scénario.

**Valeur.** Écrire un scénario plus vite. Relancer un seul scénario pendant un correctif.

**À faire.**
- Un module `Tests/Harness/Assertions.lua` avec les helpers réellement identiques.
- Un argument de `run.lua` qui filtre par numéro ou par nom (ex. `lua5.1 Tests/run.lua 68`).
- Migrer les scénarios vers le module au fil des modifications, pas en une fois.

**Coût.** S à M.

**Risque.** Nul si les scénarios gardent leurs assertions actuelles. Ne pas toucher au bloc `EXPECTED` du scénario 31, qui fige le contrat des options.

**Fichiers.**
- Nouveau `Tests/Harness/Assertions.lua`
- `Tests/run.lua`
- `Tests/Scenarios/31` à `51`, au fil de l'eau

---

### Dette 1 : Bug : enfant de groupe dynamique redimensionné

**Pourquoi.** `MoverSizer.lua:1122-1123` lit `local parentData = WeakAuras.GetData(parent)`, puis teste `if parentData == "dynamicgroup" then`. Une table est comparée à une chaîne, donc la condition est toujours fausse. La branche prévue pour un enfant de groupe dynamique ne s'exécute jamais : le redimensionner écrit `xOffset`/`yOffset` alors que le groupe calcule sa position.

**Valeur.** Un redimensionnement dans un groupe dynamique qui ne laisse plus d'offsets parasites.

**À faire.**
- Remplacer par `parentData.regionType == "dynamicgroup"`.
- Vérifier en jeu : redimensionner un enfant de groupe dynamique dans `/wa`, puis contrôler ses offsets.

**Coût.** S.

**Risque.** Faible. La branche réactivée n'a jamais tourné dans le fork : relire son contenu avant.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`

---

### Placement 2 : Offsets arrondis au lâcher

**Pourquoi.** Trois endroits écrivent des nombres à virgule dans `xOffset` et `yOffset` :
- `doneMoving` (`MoverSizer.lua:1281-1282`) : `dX/scale + xDelta/scale` ;
- `moveOnePxl` (`MoverSizer.lua:46`) : ajoute des fractions de pixel physique ;
- `OnDragStop` (`EditModePlacement.lua:100-101`).

**Valeur.** Des valeurs X/Y lisibles dans les options. Des auras alignées au pixel près.

**Coût.** S.

**Risque.** Aucune migration : le format des données ne change pas. Arrondir à l'unité ou au pixel physique, selon ce que rend `AlignToPixelX` et `AlignToPixelY` (`MoverSizer.lua:645-658`).

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `WeakAuras/EditModePlacement.lua`

---

### Placement 1 : Grille régulière et bords d'écran dans le déplacement `/wa`

**Pourquoi.** `AlignmentLines.CreateLines` (`MoverSizer.lua:832`) ne crée que les deux lignes centrales de l'écran. Le reste est déjà prévu pour des lignes de grille : couleurs `gridColor` et `gridHighlightColor`, score 0 (`:576`), préférence donnée aux lignes d'aura. Le calage ne tient compte d'aucun bord d'écran.

**Valeur.** La même grille que le mode édition, centrée sur `UIParent`. Le pas vient de `EditModeManagerFrame.Grid.gridSpacing`, ou d'un réglage propre si la grille Blizzard est absente. Les bords d'écran deviennent des cibles de calage.

**À faire.**
- Ajouter dans `CreateLines`, après `CreateMiddleLines`, des lignes `CreateLineInformation(pos, true)` à pas régulier, verticales et horizontales.
- Ajouter quatre lignes pour les bords de l'écran.
- Ajouter un bouton « Grille » dans la barre d'outils, à côté de « Magnetically Align », avec sa valeur par défaut dans `WeakAurasOptionsSaved`.

**Coût.** S.

**Risque.** Faible. Une soixantaine de lignes peuvent s'afficher : réutiliser un pool de lignes au lieu d'en créer à chaque déplacement. Aucune migration de données.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` (lignes 735 à 778)
- `WeakAurasOptions/WeakAurasOptions.lua` (vers la ligne 211)

---

### Placement 3 : Aperçu du calage en direct dans le mode édition

**Pourquoi.** `ShiftOfSnap` (`EditModePlacement.lua:60`) ne s'applique qu'au `OnDragStop`. L'aura saute à sa place au lâcher, sans indication pendant le glisser.

**Valeur.** Le même ressenti que les cadres Blizzard : le joueur voit où l'aura va se poser avant de la lâcher.

**À faire.**
- Ajouter un `OnUpdate` sur la boîte pendant le glisser.
- Calculer le décalage de calage à chaque frame et le montrer : ligne de grille mise en évidence, ou boîte fantôme à la position calée.
- Retirer l'`OnUpdate` au lâcher.

**Coût.** S à M.

**Risque.** Le coût de l'`OnUpdate`, limité à la durée du glisser.

**Fichiers.**
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Placement 5 : Déplacement aux flèches du clavier

**Pourquoi.** Le réglage fin passe aujourd'hui par 4 boutons cliquables autour de la boîte (`moveOnePxl`, `MoverSizer.lua:46`). Le mode édition n'en a aucun. Blizzard gère déjà les flèches pour ses propres cadres (`EditModeSystemMixin:ProcessMovementKey`, `Blizzard_EditMode/Shared/EditModeSystemTemplates.lua:48`), mais c'est interne au mixin.

**Valeur.** Un placement précis sans souris : 1 px par appui, 10 px avec Shift, comme chez Blizzard.

**À faire.**
- Poser `OnKeyDown` et `OnKeyUp` sur la boîte sélectionnée, avec `EnableKeyboard(true)`.
- Laisser passer toutes les autres touches avec `SetPropagateKeyboardInput(true)`.
- Écrire les offsets par le même chemin que `moveOnePxl`.

**Coût.** S à M.

**Risque.** `SetPropagateKeyboardInput` porte `HasRestrictions` dans le source, sans préciser lesquelles. Sans propagation, la boîte capterait toutes les touches du joueur. Vérifier en jeu, en combat, avant de livrer.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `WeakAuras/EditModePlacement.lua`

---

### Placement 4 : Un seul moteur de calage pour les deux outils

**Pourquoi.** Le calage existe en deux logiques sans rien en commun :
- `EditModePlacement.lua` (`ShiftToGrid`, `ShiftOfSnap`, lignes 46 à 72) : grille Blizzard seulement, seuil 8 px ;
- `MoverSizer.lua` (lignes 575 à 1027) : bords et centres d'auras, centre de l'écran, seuil 10 px (`MAGNETIC_ALIGNMENT`).

Le mode édition n'aligne ni sur les autres auras, ni sur les bords d'écran. Le calage de `MoverSizer` n'a aucun test headless.

**Valeur.** Le même comportement partout : grille, auras, bords d'écran, Ctrl pour aligner les centres, Shift pour désactiver le calage. Des calculs testables hors jeu.

**À faire.**
- Créer un module de calage dans `WeakAuras/`. Les options se chargent à la demande, alors que le mode édition tourne sans elles.
- Y mettre les calculs purs : liste des cibles, sélection de la meilleure ligne, décalage à appliquer.
- Faire appeler ce module par `EditModePlacement.lua` et `MoverSizer.lua`.
- Ajouter un scénario headless sur les cas de calage.

**Coût.** M.

**Risque.** Régression du déplacement dans `/wa`, aujourd'hui non testé. Écrire le scénario avant de déplacer le code.

**Fichiers.**
- Nouveau module de calage dans `WeakAuras/`, déclaré dans `WeakAuras/WeakAuras.toc`
- `WeakAuras/EditModePlacement.lua`
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- Nouveau scénario dans `Tests/Scenarios/`

---

### Placement 6 : Enfants de groupe simple dans le mode édition

**Pourquoi.** `CanBePlaced` (`EditModePlacement.lua:137`) exclut toute aura qui a un `data.parent`. On ne peut pas placer depuis le mode édition les éléments d'un HUD rangés dans un groupe.

**Valeur.** Placer chaque élément d'un groupe simple sans ouvrir `/wa`.

**À faire.**
- Accepter les enfants de groupe simple dans `CanBePlaced`. Les enfants de groupe dynamique restent exclus, car le groupe calcule leur position.
- Convertir le déplacement en offsets relatifs au groupe.
- Recalculer la boîte englobante du groupe après le lâcher.

**Coût.** M.

**Risque.** Offsets relatifs mal convertis. Boîte du groupe décalée après déplacement d'un enfant (`RegionTypes/Group.lua`).

**Fichiers.**
- `WeakAuras/EditModePlacement.lua`
- `WeakAuras/RegionTypes/Group.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Suite du placement (2026-11-10)

Issue de `/evolutions` sur la feature placement, après Placement 1 à 6 et les guides d'alignement du mode édition. Ordre : bug d'abord (Placement 9), puis les S, puis les M, puis le L.

1. Placement 9 : Bords des petits groupes dans le mode édition
2. Placement 8 : Ligne du milieu de l'écran dans le mode édition
3. Placement 10 : Même seuil, même Maj, même centre dans les deux outils
4. Placement 11 : Coordonnées pendant le glisser dans le mode édition
5. Placement 12 : Aura de référence mise en évidence
6. Placement 13 : Guides bornés et espacement égal
7. Placement 14 : Redimensionnement aimanté dans le mode édition
8. Placement 15 : Aligner et répartir plusieurs auras dans `/wa`

Écartés : lignes vers les cadres Blizzard (la liste des cadres du mode édition est le champ interne `registeredSystemFrames`, risque de taint ; `GetRect` peut renvoyer nil ou une valeur secrète), aimantation des enfants de groupe dynamique (le groupe calcule leur position), seuil réglable (une option de plus pour peu de gain).

Dette notée : `ShiftOfSnap` reconstruit et trie toutes les lignes à chaque `OnUpdate` du glisser ; `Candidates` écrit `line.delta` dans les lignes ; `MoverSizer.lua:1472` divise par `GetScale()` au lieu de l'échelle effective ; aucun test avec une échelle différente de 1.

---

### Placement 9 : Bords des petits groupes dans le mode édition

**Pourquoi.** `CoverRegion` (`EditModePlacement.lua:53`) donne à la boîte d'un groupe au moins 16 de côté. Les lignes d'aimantation viennent de la boîte : un groupe plus petit propose des bords qui ne sont pas les siens.

**Valeur.** Une aura se cale sur le vrai bord du groupe.

**À faire.**
- Garder la boîte cliquable à 16 au moins.
- Tirer les lignes d'aimantation du vrai rectangle du groupe.

**Coût.** S.

**Risque.** Faible.

**Fichiers.**
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Placement 8 : Ligne du milieu de l'écran dans le mode édition

**Pourquoi.** Sans grille, `PlacementSnap.ScreenLines` (`PlacementSnap.lua:26`) ne rend que les deux bords de l'écran. Grille Blizzard cachée, rien ne passe au centre de l'écran en mode édition. `/wa` a cette ligne (`CreateMiddleLines`, `MoverSizer.lua:589`).

**Valeur.** Centrer une aura sans afficher la grille.

**À faire.** Ajouter le milieu de l'écran aux lignes de `ScreenLines`.

**Coût.** S.

**Risque.** Faible. `/wa` passe aussi par `ScreenLines` : vérifier que le milieu n'y est pas compté deux fois.

**Fichiers.**
- `WeakAuras/PlacementSnap.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`, `97_PlacementSnap.lua`

---

### Placement 10 : Même seuil, même Maj, même centre dans les deux outils

**Pourquoi.** Seuil de 8 en mode édition (`EditModePlacement.lua:15`), de 10 dans `/wa` (`MAGNETIC_ALIGNMENT`, `MoverSizer.lua:27`). Maj coupe l'aimantation en mode édition et l'inverse dans `/wa`. Le centre de l'aura s'aimante aux lignes d'écran sans Ctrl en mode édition, pas dans `/wa`.

**Valeur.** Un même geste donne le même résultat dans les deux outils.

**À faire.**
- Une constante de seuil dans `PlacementSnap`, lue par les deux outils.
- Aligner le centre de l'aura sur les lignes d'écran et de grille dans `/wa`, comme en mode édition.
- Maj : garder l'inversion de `/wa` (option « Aligner magnétiquement » désactivée, Maj l'active) ; en mode édition, l'option est celle de Blizzard, Maj y coupe.

**Coût.** S.

**Risque.** Habitude des joueurs changée.

**Fichiers.**
- `WeakAuras/PlacementSnap.lua`
- `WeakAuras/EditModePlacement.lua`
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`, `96_MoverSizerRounding.lua`, `97_PlacementSnap.lua`

---

### Placement 11 : Coordonnées pendant le glisser dans le mode édition

**Pourquoi.** `/wa` affiche les offsets pendant le glisser (`MoverSizer.lua:1472`). La boîte du mode édition n'affiche que le nom de l'aura (`EditModePlacement.lua:380`).

**Valeur.** Placer au pixel près sans ouvrir `/wa`.

**À faire.** Pendant le glisser, afficher sur la boîte les offsets que l'aura aura au lâcher (position calée comprise), puis revenir au nom.

**Coût.** S.

**Risque.** Faible.

**Fichiers.**
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Placement 12 : Aura de référence mise en évidence

**Pourquoi.** Aucun des deux outils ne montre sur quelle aura on s'aimante. `/wa` surligne la ligne (`SelectLines`, `MoverSizer.lua:832`), pas l'aura. `AddAuraLines` reçoit déjà l'id de l'aura.

**Valeur.** Comprendre tout de suite un calage inattendu.

**À faire.**
- Garder l'id de l'aura dans la ligne retenue.
- Mode édition : surligner la boîte de cette aura pendant le glisser.

**Coût.** S à M.

**Risque.** Faible.

**Fichiers.**
- `WeakAuras/PlacementSnap.lua`
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Placement 13 : Guides bornés et espacement égal

**Pourquoi.** `ShowGuide` (`EditModePlacement.lua:244`) trace la ligne sur tout l'écran, alors que la ligne d'une aura porte sa portée (`pos1`, `pos2`). Aucun guide d'espacement égal entre auras.

**Valeur.** Moins de bruit à l'écran. Rangées d'icônes à intervalles réguliers.

**À faire.**
- Guide d'une ligne d'aura borné entre l'aura dragée et l'aura de référence.
- Lignes d'espacement égal : à côté d'une aura voisine, la position qui reproduit l'écart entre deux auras déjà alignées.

**Coût.** M.

**Risque.** Nouvelles lignes qui l'emportent à tort sur une ligne de bord.

**Fichiers.**
- `WeakAuras/PlacementSnap.lua`
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`, `97_PlacementSnap.lua`

---

### Placement 14 : Redimensionnement aimanté dans le mode édition

**Pourquoi.** Le mode édition ne fait que déplacer (`StartMoving`, `EditModePlacement.lua:286`). `/wa` redimensionne avec aimantation (`doneSizing`). `SetResizable`, `SetResizeBounds` et `StartSizing(point)` existent dans Forever 1.60.1.70790, sans restriction sur une frame d'addon non protégée.

**Valeur.** Régler la taille sans quitter le mode édition.

**À faire.**
- Poignée sur le coin bas droit de la boîte sélectionnée, auras à `width` et `height` seulement (pas les groupes).
- Au lâcher : bord tiré calé sur la ligne la plus proche, taille convertie à l'échelle de l'aura et arrondie.

**Coût.** M.

**Risque.** Conversion d'échelle. Auras dont la taille vient d'ailleurs (texte, modèle).

**Fichiers.**
- `WeakAuras/EditModePlacement.lua`
- `Tests/Scenarios/68_EditModePlacement.lua`

---

### Placement 15 : Aligner et répartir plusieurs auras dans `/wa`

**Pourquoi.** En multi-sélection, le déplaceur `/wa` ne bouge que la première aura (`MoverSizer.lua:1197-1204`). Aucune commande d'alignement ni de répartition.

**Valeur.** Aligner une barre de 6 icônes en un clic.

**À faire.**
- Commandes sur la multi-sélection : aligner à gauche, à droite, en haut, en bas, centres ; répartir horizontalement et verticalement.
- Annulables par `TimeMachine`.
- Auras de même ancrage seulement.

**Coût.** L.

**Risque.** Ancrages mixtes. Groupes dynamiques exclus.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua` ou `OptionsFrame.lua`
- Nouveau scénario dans `Tests/Scenarios/`

---

## 1.18 : rebranding

Sortie le 2026-11-13 (1.18.0), puis 1.18.1 (2026-11-15) et 1.18.2 (2026-11-16). Rien d'autre que le rebranding dans la 1.18.0 : le rendu ne se vérifie qu'en jeu.

### Principe : ne pas perdre l'utilisateur

On change ce que le joueur voit : nom affiché, couleurs, icônes, cadres. On garde ce qu'il connaît : disposition et gestes.

À garder tel quel :

- la disposition de la fenêtre d'options : arbre d'auras à gauche, onglets à droite, barre d'outils au-dessus de la liste, filtre, pied de page ;
- les commandes `/wa` et `/weakauras`, et leurs sous-commandes ;
- les clics de la minicarte : gauche pour ouvrir, Shift pour mettre en pause, droit pour le profilage, milieu pour cacher l'icône.

À ne jamais renommer (compatibilité) :

- les données sauvegardées : `WeakAurasSaved` ;
- l'API des imports et des addons tiers : `WeakAuras.*`, `WeakAuras.prettyPrint`, le préfixe d'export `!WA:2!` ;
- les noms de frames : `WeakAurasOptions`, `WeakAurasFilterInput`, `WeakAurasTextReplacements`, `WeakAurasForeverTutorial` ;
- les clés de popups `WEAKAURAS_*` ;
- l'id LDB et LDBIcon `"WeakAuras"` ;
- l'appel `RegisterOptionsTable("WeakAuras")` ;
- les dossiers d'addon ;
- le layout du mode édition `"WeakAuras"` (`Tests/Scenarios/26_CDMSetup.lua:176`).

### Contraintes d'ordre

1. Rebranding 1 passe en premier : les autres appliquent sa charte.
2. Rebranding 7 précède Rebranding 9.
3. Rebranding 4 passe en dernier : il présente ce que les autres ont changé.

Aucun test headless ne couvre le rendu (couleurs, textures, titres) : chaque ticket se vérifie en jeu.

### Déjà fait

Entrée du 2026-11-13 de `CHANGES.md`. Banc headless vert à la sortie (128 scénarios, 0 échec). Testé en jeu : `SUIVI-BUGS-ET-TESTS.md`, étape 14, OK le 2026-11-13.

- Rebranding 1 : charte `DESIGN.md`.
- Rebranding 2 : « Musca Auras » dans les 11 locales, le tutoriel, le chat et les textes en dur. Attribution à
  WeakAuras et identifiants de compatibilité inchangés.
- Rebranding 3 : `## Notes:` du toc, `README.md`, `DESCRIPTION.md`, `.github/logo.png`. Écart au ticket :
  `## X-Wago-ID` est toujours dans `WeakAuras/WeakAuras.toc`.
- Rebranding 5 : page Options > AddOns et entrée du menu des addons de la minicarte.
- Rebranding 6 : fenêtre Guide construite avec `Style`, logo Musca dans la bande de titre comme la fenêtre d'options.
- Rebranding 7 : `Style.Hex`, `Style.Markup`, couleurs des widgets d'options et couleurs écrites (`|cff`) du cœur et
  des options passées aux tokens, infobulle de la minicarte, `Profiling.lua` et `Profiling.xml`, axes de
  `RegionOptions/DynamicGroup.lua` et `Group.lua`. Teinte aléatoire de l'icône de la minicarte retirée. Gardés
  exprès : la couleur du lien de chat de `Transmission.lua` (lue par les autres clients) et les
  `SetVertexColor(1, 1, 1)` des widgets, qui retirent une teinte.
- Rebranding 8 : `icon.tga` dérivée du logo rond, `icon.blp` supprimée. Restent `logo_64.tga` et `logo_256.tga`,
  proposés dans la liste des textures sous le libellé « WeakAuras logo » (`Types.lua`).
- Rebranding 4 : popup 1.18, `WHATS_NEW_VERSION`, changelogs et version des toc. Écart au ticket : le popup s'ouvre
  à la connexion, comme celui de la 1.17, et non au premier `/wa`. Il se relit par le bouton « Changelog » de la
  fenêtre d'options.
- Rebranding 9 : écarté le 2026-11-13, repris en 1.22 le 2026-11-24 à la demande de l'auteur.
- 1.18.1, hors ticket : en combat, un sort hors du temps de recharge global (Judgement, Bloodrage) ne s'affiche plus
  prêt pendant son temps de recharge.
- 1.18.2, hors ticket : « Hide GCD Text » cache aussi un texte `%p` ou `%t` et marche en combat ; la condition
  « On Global Cooldown » marche en combat.

### Ordre

1. Rebranding 1 : Charte `DESIGN.md`
2. Rebranding 2 : Nom affiché partout
3. Rebranding 3 : Fiche publique
4. Rebranding 5 : Nouveaux points d'entrée
5. Rebranding 6 : Fenêtre Guide alignée sur la fenêtre d'options
6. Rebranding 7 : Module de thème central
7. Rebranding 9 : Bascule « apparence classique » (reporté en 1.22)
8. Rebranding 8 : Icônes de marque
9. Rebranding 4 : Écran « Quoi de neuf 1.18 » au premier lancement

---

### Rebranding 1 : Charte `DESIGN.md`

**Pourquoi.** Le projet n'a pas de `DESIGN.md`. Trois teintes de marque se mélangent dans l'interface :

- `|cff00ccff` (cyan) : nom Musca Auras, `WeakAuras/WeakAuras.lua:2598` et `WeakAuras/ForeverTutorial.lua:71` ;
- `|cff9900ff` (violet WeakAuras) : préfixe du chat, `WeakAuras/Init.lua:553` ;
- `|cffffd100` (or Blizzard) : titres et bouton Guide, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua:358`.

**Valeur.** Une référence unique pour Rebranding 2 à 9 : palette vérifiée en contraste, polices (celles du jeu et celles de `WeakAuras/Media/Fonts`), icônes, et la liste « à garder » ci-dessus comme interdits.

**À faire.**
- Lancer l'agent `designer-ui-ux` en mode conception.
- Partir du portrait `logo_musca_round.tga`, déjà en place, et du cyan Musca.

**Coût.** S.

**Risque.** Aucun : aucun code touché.

**Fichiers.** `DESIGN.md` (nouveau).

---

### Rebranding 2 : Nom affiché partout

**Pourquoi.** L'interface affiche encore « WeakAuras » à plusieurs endroits :

- `WeakAuras/Init.lua:553` : préfixe `|cff9900ffWeakAuras:|r` de `prettyPrint`, utilisé par tous les messages du chat ;
- `WeakAuras/WeakAuras.lua:1288` : texte LDB `"WeakAuras"`. L'id du même appel (`:1286`) reste inchangé ;
- `WeakAuras/WeakAuras.lua:210` : aide de `/wa`, écrite en dur, non localisée ;
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua:358` : `L["learn WeakAuras"]` ;
- `WeakAuras/ForeverTutorial.lua:11,14,17,42` : textes du tutoriel ;
- `WeakAuras/Locales/enUS.lua` :
  - `:487` et `:847` : erreurs d'import ;
  - `:1519` : réparation après retour à une version antérieure ;
  - `:1531-1533` : profilage ;
- `WeakAurasOptions/Locales/enUS.lua` :
  - `:1145` : contrôle de version ;
  - `:1159-1161` : import créé par une version plus récente ;
  - `:1236` : affichage de version ;
  - `:1237` : conseil sur les spell IDs.

**Valeur.** Un seul nom à l'écran, sans changer aucun geste du joueur.

**À faire.**
- Remplacer le texte visible par « Musca Auras », dans la couleur de la charte.
- Garder les noms de dossiers dans le message de réparation (`WeakAuras/Locales/enUS.lua:520`) : ce sont les vrais dossiers à copier.
- Garder les liens d'attribution vers WeakAuras (wiki, Patreon `OptionsFrame.lua:539`).
- Ne pas réécrire l'historique de `WeakAurasOptions/Changelog.lua`.

**Coût.** S à M.

**Risque.** Dans les locales, la clé est le texte anglais. Changer le texte anglais rend orphelines les traductions des 10 autres langues (deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW). Pour chaque clé changée, mettre à jour toutes les locales ou garder la clé et ne changer que la valeur. Les scénarios `86_UtilityPacks.lua:89` et `88_PackLibrary.lua:66` vérifient l'existence de clés en enUS et frFR. Le scénario `16_ForeverAurasImport.lua:9-10` remplace `WeakAuras.prettyPrint` : le nom de la fonction reste.

**Fichiers.**
- `WeakAuras/Init.lua`
- `WeakAuras/WeakAuras.lua`
- `WeakAuras/ForeverTutorial.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAurasOptions/VersionCheck.lua`
- `WeakAuras/Locales/*.lua`, `WeakAurasOptions/Locales/*.lua`

---

### Rebranding 3 : Fiche publique

**Pourquoi.**
- `WeakAuras/WeakAuras.toc:11` : `## Notes` est encore la phrase WeakAuras d'origine (« A powerful, comprehensive utility… »).
- `## X-Wago-ID: bGoYzp60` est hérité.
- `README.md`, `DESCRIPTION.md` et `.github/logo.png` doivent suivre la charte.

**Valeur.** Une description cohérente dans la liste d'addons du jeu, sur GitHub et sur CurseForge.

**À faire.**
- Réécrire `## Notes` dans les deux toc.
- Vérifier à quoi renvoie `X-Wago-ID: bGoYzp60` avant de le garder, le changer ou le retirer.
- Aligner `README.md`, `DESCRIPTION.md` et le logo GitHub sur la charte.

**Coût.** S.

**Risque.** Le `X-Wago-ID` : s'il pointe vers le projet WeakAuras, un outil de mise à jour pourrait proposer WeakAuras à la place de Musca Auras.

**Fichiers.**
- `WeakAuras/WeakAuras.toc`, `WeakAurasOptions/WeakAurasOptions.toc`
- `README.md`, `DESCRIPTION.md`, `.github/logo.png`

---

### Rebranding 5 : Nouveaux points d'entrée

**Pourquoi.** L'addon ne s'ouvre que par `/wa` et par l'icône de la minicarte. Aucune page dans les réglages du jeu (aucun `Settings.Register*` dans le dépôt). Pas d'entrée dans le compartiment d'addons. Les deux existent sur Forever 1.60.1.70532 :

- page de réglages :
  - `Settings.RegisterCanvasLayoutCategory(frame, name)` (`Blizzard_Settings_Shared/Blizzard_Settings.lua:162`) ;
  - `Settings.RegisterAddOnCategory(category)` (`:134`) ;
  - `Settings.OpenToCategory(categoryID)` (`:144`), où `categoryID` est le nombre rendu par `category:GetID()` ;
- compartiment : `AddonCompartmentFrame` (`Blizzard_Minimap/Camelot/AddonCompartment.xml:3`), branché par les champs du toc `## AddonCompartmentFunc`, `## AddonCompartmentFuncOnEnter` et `## AddonCompartmentFuncOnLeave`.

**Valeur.** Le joueur qui ne connaît pas `/wa` trouve l'addon par Échap > Options > AddOns ou par le bouton des addons de la minicarte.

**À faire.**
- Créer une page de réglages courte : nom, version, bouton « Ouvrir Musca Auras », rappel de `/wa`.
- Déclarer une fonction globale dans le toc pour le compartiment. Elle ouvre les options comme le clic gauche de la minicarte.

**Coût.** S.

**Risque.**
- `C_SettingsUtil.OpenSettingsPanel` porte `HasRestrictions` : tester l'ouverture en combat.
- Le compartiment appelle la fonction en mode non sécurisé (`forceinsecure`) : elle ne doit rien appeler de protégé.
- Vérifier en jeu que `AddonCompartmentFrame` s'affiche sur Forever (règle `UserAddonsDisabled`).

**Fichiers.**
- `WeakAuras/WeakAuras.toc`
- `WeakAuras/WeakAuras.lua`

---

### Rebranding 6 : Fenêtre Guide alignée sur la fenêtre d'options

**Pourquoi.** Le tutoriel (`WeakAuras/ForeverTutorial.lua:50-62`) utilise un cadre de dialogue Blizzard : `BackdropTemplate` avec `UI-DialogBox-Background-Dark` et `UI-DialogBox-Border`. La fenêtre d'options utilise `PortraitFrameTemplate` avec le portrait Musca (`OptionsFrame.lua:103`, `:125`).

**Valeur.** Les fenêtres de l'addon ont toutes le même aspect.

**À faire.**
- Passer le tutoriel sur `PortraitFrameTemplate` avec le même portrait et le même fond (`PANEL_BACKGROUND_COLOR`).
- Garder le nom de frame `WeakAurasForeverTutorial` et la commande `/wa tutorial`.

**Coût.** S.

**Risque.** Faible : texte du tutoriel à remettre en page dans le nouveau cadre.

**Fichiers.** `WeakAuras/ForeverTutorial.lua`.

---

### Rebranding 7 : Module de thème central

**Pourquoi.** Aucun fichier ne centralise les couleurs ni les textures. Elles sont écrites en dur, par widget :

- `AceGUIWidget-WeakAurasDisplayButton.lua` : 10 ;
- `AceGUIWidget-WeakAurasToolbarButton.lua` : 9 ;
- `AceGUIWidget-WeakAurasSpinBox.lua` : 9 ;
- `AceGUIWidget-WeakAurasMiniTalent.lua` : 8 ;
- `MoverSizer.lua` : 7 ;
- en plus les popups, le tutoriel et les locales (`|cffffd100`, `|cff00ccff`).

`WeakAurasOptions/ColorPalette.lua` n'est pas un thème : c'est le sélecteur de couleur des auras.

**Valeur.** Appliquer la charte en un seul endroit, et pouvoir la retoucher plus tard sans parcourir 30 fichiers. C'est aussi la condition de Rebranding 9.

**À faire.**
- Créer dans `WeakAuras/` un fichier de thème : couleurs nommées (marque, titre, avertissement, fond de panneau, surlignage) et chemins de textures de marque.
- Le charger dans le toc avant les fichiers qui l'utilisent.
- Remplacer les couleurs en dur des widgets, de `OptionsFrame.lua`, du tutoriel et des popups par les couleurs nommées.
- Laisser intactes les couleurs choisies par le joueur dans ses auras.

**Coût.** M.

**Risque.** Régression visuelle non couverte par les tests. Une couleur oubliée garde l'ancien look : vérifier par grep `|cff`, `SetColorTexture`, `SetVertexColor`, `SetTextColor`, `SetBackdropColor` après la migration.

**Fichiers.**
- Nouveau fichier de thème dans `WeakAuras/`, déclaré dans `WeakAuras/WeakAuras.toc`
- `WeakAurasOptions/AceGUI-Widgets/*.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAuras/ForeverTutorial.lua`, `WeakAuras/WeakAuras.lua`

---

### Rebranding 9 : Bascule « apparence classique »

Reporté en 1.22 le 2026-11-24 : le ticket à jour est dans la section 1.22. Texte d'origine ci-dessous.

**Pourquoi.** C'est un filet de sécurité pour les habitués de WeakAuras. Une fois le thème central en place (Rebranding 7), revenir à l'ancien look revient à choisir une autre table de couleurs et de textures.

**Valeur.** Un joueur dérangé par le nouveau look revient à l'ancien en un clic, sans quitter Musca Auras.

**À faire.**
- Ajouter une seconde palette « classique » au fichier de thème : violet WeakAuras, anciennes icônes.
- Ajouter le réglage dans `WeakAurasOptionsSaved`, avec le nouveau look par défaut.
- Mettre l'interrupteur dans la fenêtre d'options, et le mentionner dans l'écran « Quoi de neuf » (Rebranding 4).

**Coût.** M.

**Risque.** Deux palettes à maintenir dans le temps. Chaque nouvel écran doit être vérifié avec les deux.

**Fichiers.**
- Fichier de thème (Rebranding 7)
- `WeakAurasOptions/WeakAurasOptions.lua` (valeurs par défaut, vers la ligne 211)
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`

---

### Rebranding 8 : Icônes de marque

**Pourquoi.** `WeakAuras/Media/Textures/icon.blp` sert d'icône à trois endroits : le toc (`## IconTexture`), la minicarte (`WeakAuras.lua:1289`) et `AceGUIWidget-WeakAurasDisplayButton.lua:1944`. Les logos `logo_256.tga`, `logo_256_round.tga`, `logo_256_round_pride.tga`, `logo_64.tga` et `logo_64_nobg.tga` restent ceux de WeakAuras. Seul `logo_musca_round.tga` est déjà à la marque Musca.

**Valeur.** L'addon se reconnaît d'un coup d'œil dans la liste d'addons, sur la minicarte et dans le compartiment (Rebranding 5).

**À faire.**
- Produire l'icône Musca aux tailles nécessaires, au format `.blp` ou `.tga` lisible par le client.
- Pointer le toc, la minicarte et `DisplayButton` vers elle.
- Retirer les logos WeakAuras inutilisés, après grep de chaque nom de fichier.

**Coût.** M, surtout pour produire les fichiers.

**Risque.** Aucun risque de code. Une texture manquante s'affiche en carré vert : vérifier chaque chemin en jeu.

**Fichiers.**
- `WeakAuras/Media/Textures/`
- `WeakAuras/WeakAuras.toc`
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`

---

### Rebranding 4 : Écran « Quoi de neuf 1.18 » au premier lancement

**Pourquoi.** C'est le garde-fou de « ne pas perdre l'utilisateur ». Le changelog en jeu existe déjà (`WeakAurasOptions/Changelog.lua`). Sa `versionString` vaut encore `'1.14.0'` (`:13`).

**Valeur.** Au premier `/wa` après la mise à jour, le joueur voit ce qui change (nom, couleurs, icônes, nouveaux points d'entrée) et ce qui ne bouge pas : `/wa`, ses auras, leurs positions, les imports Wago.

**À faire.**
- Ouvrir l'écran une seule fois, au premier `/wa` en 1.18, avec un drapeau « vu » dans `WeakAurasSaved`.
- Le laisser accessible ensuite depuis la fenêtre d'options.
- Mettre à jour `Changelog.lua` et `CHANGES.md`.

**Coût.** S à M.

**Risque.** Faible : le drapeau ajoute une clé à `WeakAurasSaved`, sans migration.

**Fichiers.**
- `WeakAurasOptions/Changelog.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `CHANGES.md`

---

## 1.19 : auras cliquables

Sortie le 2026-11-18 (1.19.0). Version à un seul sujet, décidée le 2026-11-13 : l'auteur classe les auras cliquables indispensables. Populaire 11 est un L. Il sort seul avec Dette 4, pour ne tester en jeu qu'un sujet. Les versions suivantes ont glissé d'un cran.

Dette 4 (tests de migration) précède tous les tickets qui ajoutent des champs aux auras : Populaire 11 ici, puis ceux des versions suivantes.

### Déjà fait

Entrée du 2026-11-18 de `CHANGES.md`.

- Dette 4 : scénarios 102, 103 et 104 (migration et restauration des données).
- Populaire 11 : sous-élément Click Action (`ClickButtons.lua`, `SubRegionTypes/ClickAction.lua`,
  `SubRegionOptions/ClickAction.lua`), touche par aura, « Clickable in Combat », scénario 101, `GUIDE.md`.
- Hors ticket : trigger Health, « Show Absorb » dessine le bouclier en overlay d'une Progress Bar, en combat aussi.

### Reste ouvert

Entrée du 2026-11-19 de `CHANGES.md`, écrite après la sortie et absente du CHANGELOG 1.19.0 : `WeakAuras.CreateAuraSlot`,
rapports `/wa modern` et `/wa cdm`, scénario 107, correctifs, boutons retirés. Hors ticket, non testée en jeu. Sa version
de sortie reste à décider.

Tests en jeu : étape 15 de `SUIVI-BUGS-ET-TESTS.md`. Seuls le clic gauche (sort) et le clic droit (retrait de buff)
sont passés, le 2026-11-18.

### Ordre

1. Tests en jeu de Populaire 11 (liste « À tester en jeu avant de coder » du ticket) : un échec change la conception.
2. Dette 4 : Tester la migration et la restauration des données
3. Populaire 11 : Auras cliquables et raccourcis clavier

---

### Dette 4 : Tester la migration et la restauration des données

**Pourquoi.** Plusieurs chemins qui touchent aux données sauvegardées n'ont aucun scénario :
- `WeakAuras/BlizzardAuraDisplayMigration.lua` : `DropVoiceSound`, `DropLegacySoundFields` (retrait des sons de la 1.14.0). Le nettoyage s'applique avec ou sans trigger `secretAura`, et quel que soit le kind choisi depuis : aucune clé `sound_<ancien>` ne reste dans les SavedVariables ni dans les exports (scénario 102).
- `RestoreDeletedAura` (`WeakAuras/AuraBackups.lua:141`, appelée depuis `WeakAuras.lua:297`). `ListDeletedAuras` est testée, pas la restauration.
- `WeakAuras/BlizzardAuraDisplayValidation.lua`.

**Valeur.** Aucune perte ni corruption silencieuse de données lors d'une mise à jour ou d'une restauration.

**À faire.**
- Scénario migration : données 1.14.0 avec et sans trigger `secretAura`, kind ancien et kind déjà renommé. Vérifier qu'il ne reste aucune clé `sound_*` obsolète.
- Scénario restauration : supprimer une aura, la restaurer, comparer aux données d'origine (uid, parent, enfants).
- Scénario validation : un cas valide et un cas invalide par règle.

**Coût.** M.

**Risque.** Nul : tests seulement. Un scénario qui échoue révèle un bug à traiter à part.

**Fichiers.**
- Nouveaux scénarios dans `Tests/Scenarios/`

---

### Populaire 11 : Auras cliquables et raccourcis clavier

**Pourquoi.** Demandé par l'auteur le 2026-11-13, classé indispensable. Aucune aura n'est cliquable aujourd'hui : le seul clic est `ClickToPick` (`WeakAuras/RegionTypes/RegionPrototype.lua:1089`), actif quand `/wa` est ouvert. Lancer un sort, utiliser un objet ou retirer un buff demande un bouton sécurisé. Vérifié dans le source Forever 70862, rien en jeu : `SecureActionButtonTemplate` existe (`Blizzard_FrameXML/SecureTemplates.xml:4`) avec les types `spell`, `item`, `macro`, `target` et `cancelaura` ; `Show`, `Hide`, `SetPoint`, `SetSize`, `SetParent` et `EnableMouse` sont protégées sur un bouton sécurisé ; `RegisterStateDriver` existe ; l'environnement restreint n'a aucune API d'aura et `SecureAuraHeaderTemplate` n'est pas chargé sur Forever ; `SetOverrideBindingClick` est appelée par Blizzard (`Blizzard_GamepadSharedUtility/InputBindingStack/InputButtonBinding.lua:28`).

**Valeur.** Cliquer une aura, ou appuyer sur une touche, pour lancer le sort, utiliser l'objet ou la macro qu'elle représente, cibler une unité ou retirer un buff. Les consommables des packs deviennent utilisables depuis leur icône.

**Principe.** Un bouton sécurisé séparé, enfant de `UIParent`, jamais ancré à l'aura, ni l'aura à lui : une région ancrée à un cadre protégé risque de devenir protégée, et l'addon ne pourrait plus l'afficher en combat. L'addon recopie la position et la taille de l'aura sur le bouton hors combat.

**À faire.**
- Sous-région « Click action » pour `icon`, `aurabar`, `text`, `texture`, `progresstexture` et `empty`, abonnée à `PreShow` et `PreHide` de la région.
- Réserve de boutons `SecureActionButtonTemplate` nommés, sans `:` dans le nom, avec `RegisterForClicks("AnyDown", "AnyUp")`. Création, attributs, position, taille et visibilité seulement hors combat (`InCombatLockdown()`), recalage après le combat.
- Options par bouton de souris (gauche, droit, milieu) : lancer un sort, utiliser un objet, macro, cibler une unité, retirer un buff. Unité visée : par défaut, `player`, `target`, `mouseover`, `focus`.
- Raccourci clavier : une touche par aura, qui déclenche l'action du clic gauche, posée par `SetOverrideBindingClick` hors combat et retirée quand l'aura est déchargée ou supprimée. Avertissement dans les options si la touche est déjà prise par le jeu ou par une autre aura.
- Clic et raccourci en combat, trois modes : « aura visible à l'entrée en combat », « toujours », « condition de macro » (`RegisterStateDriver`, par exemple `[combat][mod:shift] show; hide`).
- Avertissement dans les options pour les limites ci-dessous.
- Harnais de test : gabarit sécurisé, `RegisterStateDriver` et raccourcis simulés, un scénario.
- Section dans `GUIDE.md`, textes dans les 11 locales.

**Limites du client.**
- Groupe dynamique : la zone cliquable reste à sa position d'entrée en combat, puis se recale après le combat.
- Clone apparu en combat : pas de clic avant la fin du combat.
- Aura déplacée ou redimensionnée en combat (animation, condition) : la zone ne suit pas.
- Mode « toujours » : un clic sur la zone lance l'action même quand l'aura est cachée.
- Clic ou raccourci actif seulement quand un buff est présent, en combat : impossible, aucun accès aux auras côté sécurisé.

**À tester en jeu avant de coder.**
- `SetAttribute` sur un bouton sécurisé d'addon en combat.
- `RegisterStateDriver` avec `[combat]` et `[mod]` sur un bouton d'addon.
- `macrotext` et `type="item"` en combat, clic physique.
- Raccourci `CLICK` sur un bouton caché (`Hide`).
- `SetOverrideBindingClick` depuis l'addon, en combat puis hors combat.
- État `IsProtected()` d'une région d'aura voisine du bouton, avant et après.

**Coût.** L.

**Risque.** Élevé. Une action protégée lancée en combat lève `ADDON_ACTION_BLOCKED` : tout passe par `InCombatLockdown()`. Un raccourci prioritaire masque la touche du jeu tant qu'il est posé. Nouveaux champs dans les auras, d'où Dette 4 juste avant : une sous-région inconnue d'une version plus ancienne est ignorée, à vérifier par un import croisé.

**Fichiers.**
- `WeakAuras/SubRegionTypes/ClickAction.lua` (neuf)
- `WeakAuras/ClickButtons.lua` (neuf)
- `WeakAurasOptions/SubRegionOptions/ClickAction.lua` (neuf)
- `WeakAuras/Types.lua`
- `WeakAuras/WeakAuras.toc`, `WeakAurasOptions/WeakAurasOptions.toc`
- `Tests/Harness/Frames.lua`, `Tests/Harness/WowApi.lua`, un scénario neuf
- `GUIDE.md`, `CHANGES.md`, `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`
- Locales

---

## 1.20 : accueil et commandes

Sortie le 2026-11-22 (1.20.0).

L'accueil et les nouvelles commandes ajoutent des textes et des boutons, dans la charte de la 1.18. Outils 1 passe en premier : son scénario contrôle les clés de locale de tous les textes neufs, ici et dans les versions suivantes. Outils 3 suit : le script de sortie sert dès cette version. Tous les tickets sont S, sauf Accueil 4 (S à M).

### Parcours actuel au premier login

Lu dans le code le 2026-11-21, non testé en jeu :

- Aucune aura n'est installée d'office. `ADDON_LOADED` crée `WeakAurasSaved` avec `displays = {}`.
- `PLAYER_LOGIN`, après `Private.Login`, ouvre une seule popup, dans cet ordre (`WeakAuras/WeakAuras.lua`) :
  - `WEAKAURAS_FOREVER_DISCLAIMER` si `not db.foreverDisclaimerSeen` ;
  - sinon `WEAKAURAS_WHATS_NEW` si `db.whatsNewSeen ~= WHATS_NEW_VERSION` ; la notice des packs suit à sa fermeture ;
  - sinon la notice des packs de classe, si `db.classPackNoticeSeen ~= CLASS_PACK_VERSION` et `HasClassPack()`.
- Popup Forever : les limites de Forever et trois boutons, `OKAY`, `Guide`, `Install <Classe> HUD`. Son `OnShow` pose `foreverDisclaimerSeen`, `classPackNoticeSeen` et `whatsNewSeen`.
- Le HUD complet passe par `WeakAuras.ImportClassPack()`, qui se met en file en combat et refuse pendant le login.
- Le choix bloc par bloc et les 24 packs utilitaires ne sont accessibles que par `/wa` > New Aura > Packs (`frame:OpenPacks`, `OptionsFrame.lua`, `WeakAurasOptions/PackLibrary.lua`).
- Aucun écran pour une liste d'auras vide, aucun compteur d'auras par pack, aucun flag par personnage.

### Ordre

1. Outils 1 : Scénario « toute clé de locale utilisée existe dans enUS »
2. Outils 3 : Script de sortie, version et changelog en une commande
3. Accueil 2 : Accueil court, séparé de l'avertissement Forever
4. Accueil 1 : Proposer le HUD au premier login de chaque classe
5. Accueil 3 : Nombre d'auras par pack et par bloc dans la page Packs
6. Accueil 4 : Écran pour une liste d'auras vide dans `/wa`
7. Populaire 1 : Commande `/wa toggle`
8. Populaire 10 : Mute global des sons

### Déjà fait

Entrée du 2026-11-21 de `CHANGES.md`. Les huit tickets sont codés, banc headless à 137 scénarios, 0 échec. Testé en
jeu : `SUIVI-BUGS-ET-TESTS.md`, étape 16, OK le 2026-11-22.

- Outils 1 : scénario 108. Il a fait retirer de enUS et frFR les textes de l'ancienne popup de premier login.
- Outils 3 : `Tests/PrepareRelease.py`. Écart avec le ticket : la source est `WeakAuras/CHANGELOG.md`, pas
  `CHANGES.md`, dont le texte s'adresse aux développeurs.
- Accueil 2 : accueil court à quatre boutons (HUD complet, blocs, Guide, plus tard), flags posés au clic,
  `/wa welcome`, ligne Swing Timer dans le Guide.
- Accueil 1 : `classPackOffered` par classe, offre après « Quoi de neuf ».
- Accueil 3 : nombre d'auras du HUD, de chaque bloc et de chaque pack utilitaire.
- Accueil 4 : encart de liste vide avec Packs, Guide, Import.
- Populaire 1 : `/wa toggle` ; fenêtre d'options ou mode placement ouvert, une ligne du chat demande de le
  fermer.
- Populaire 10 : `/wa mute`, case « Mute » de la barre d'outils, rappel au login, sons des Aura (Modern) compris.
  Les sons en cours sont coupés, sauf une synthèse vocale déjà lancée.
- Corrigé en plus : `/wa unlock` tapé pendant le chargement ne bloque plus le login ; la notice « class pack
  changed » compte comme vue à la réponse, plus à l'affichage ; `WeakAuras.Import` ne lève plus sur une donnée
  illisible.

### Reste ouvert

- Rendu de la popup à quatre boutons et des libellés longs (allemand, russe) à voir en jeu.

---

### Outils 1 : Scénario « toute clé de locale utilisée existe dans enUS »

**Pourquoi.** Le repli des tables de locale (`setmetatable` à la fin de `WeakAuras/Locales/enUS.lua`) rend la clé elle-même : une clé absente ou mal tapée s'affiche en anglais dans toutes les langues, sans erreur. Aucun scénario de `Tests/Scenarios/` ne parcourt les `L["..."]` du code.

**Valeur.** Une faute de frappe dans une clé est attrapée au banc, pas chez le joueur.

**À faire.**
- Scénario neuf : lire les fichiers Lua de `WeakAuras/` et de `WeakAurasOptions/` (hors `Libs/` et `Locales/`), relever les `L["..."]` littéraux, vérifier que chacun existe dans le `enUS.lua` du même addon.
- Liste d'exceptions courte pour les clés construites à l'exécution, avec la raison en commentaire.
- Corriger les clés manquantes que le scénario trouve.

**Coût.** S.

**Risque.** Faible. Le nombre de clés déjà manquantes n'est pas connu : la correction peut dépasser le S.

**Fichiers.**
- `Tests/Scenarios/` (scénario neuf)
- `WeakAuras/Locales/enUS.lua`, `WeakAurasOptions/Locales/enUS.lua`

---

### Outils 3 : Script de sortie, version et changelog en une commande

**Pourquoi.** Une sortie demande sept écritures à la main : la ligne `## Version` des cinq `.toc`, `versionString` et `dateString` de `WeakAurasOptions/Changelog.lua:7`, le premier titre de `WeakAuras/CHANGELOG.md`. Le scénario `Tests/Scenarios/91_ForkVersionMatches.lua` détecte un écart, il ne l'écrit pas. `Changelog.lua` recopie le texte de `CHANGES.md` à la main (dette notée).

**Valeur.** Une sortie ne part plus avec une version incohérente ni un changelog en jeu en retard. `.github/workflows/release.yml` refuse déjà un tag qui diffère du premier titre du changelog.

**À faire.**
- Script dans `Tests/`, sur le modèle de `Tests/GenerateTutorial.py` : un argument, le numéro de version. Il écrit les sept endroits.
- Générer le corps de `WeakAurasOptions/Changelog.lua` depuis l'entrée correspondante de `CHANGES.md`.
- Option `--check` : sortie en erreur si les fichiers ne correspondent pas à ce que le script produirait.
- Le script n'exécute aucune commande git.

**Coût.** S.

**Risque.** Faible. La conversion du Markdown de `CHANGES.md` vers le format de `Changelog.lua` est à relire sur les trois dernières sorties.

**Fichiers.**
- `Tests/` (script neuf)
- `WeakAurasOptions/Changelog.lua`
- les cinq `.toc`, `WeakAuras/CHANGELOG.md`

---

### Accueil 2 : Accueil court, séparé de l'avertissement Forever

**Pourquoi.**
- L'action utile, installer le HUD, est le 3e bouton (`button3`, posé au `PLAYER_LOGIN`), sous une liste de limites techniques (texte de `WEAKAURAS_FOREVER_DISCLAIMER`).
- Le HUD s'installe en entier : la popup ne mentionne pas le choix par bloc de la page Packs.
- `OnShow` pose `foreverDisclaimerSeen`, `classPackNoticeSeen` et `whatsNewSeen`. Fermer par Échap sans rien choisir compte comme vu, sans retour possible.

**Valeur.** Au premier login, le joueur choisit clairement le volume d'auras qu'il veut : tout, une sélection, ou rien pour l'instant.

**À faire.**
- Remplacer le texte par un accueil court : une phrase sur l'addon, une sur le HUD de classe.
- Trois boutons :
  - « Installer le HUD complet » : `WeakAuras.ImportClassPack()` ;
  - « Choisir les blocs » : charger les options (`Private.LoadOptions`), ouvrir `/wa`, puis `frame:OpenPacks()` ;
  - « Plus tard ».
- Déplacer la liste des limites dans le Guide, qui a déjà « What changes on Forever » (`TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`). Ajouter un lien Guide dans l'accueil.
- Poser les trois flags au clic d'un bouton, plus à `OnShow`. Un compte neuf ne doit toujours pas voir « Quoi de neuf » (`WEAKAURAS_WHATS_NEW`) ni la notice des packs juste après l'accueil.
- Ajouter `/wa welcome` pour réafficher l'accueil, et le citer dans `Private.PrintHelp`.

**Coût.** S.

**Risque.**
- Les options se chargent à la demande. « Choisir les blocs » doit passer par `LoadOptions`, qui attend déjà la fin du login et du combat.
- Fermer par Échap ne pose plus aucun flag : l'accueil revient au login suivant, tant qu'aucun bouton n'est cliqué.
- Mettre à jour `DESCRIPTION.md` (« Quick start », étape 2) et les locales.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAuras/ForeverTutorial.lua`, `TUTORIAL.md`
- `DESCRIPTION.md`
- Locales

---

### Accueil 1 : Proposer le HUD au premier login de chaque classe

**Pourquoi.** `foreverDisclaimerSeen` est stocké dans `WeakAurasSaved`, au niveau du compte. Seul le premier personnage reçoit la proposition. Un personnage d'une autre classe ne se voit jamais proposer son HUD : il doit trouver `/wa` > Packs seul.

**Valeur.** Chaque nouveau personnage se voit proposer le HUD de sa classe au premier login.

**À faire.**
- Ajouter une table `classPackOffered` dans `WeakAurasSaved`, indexée par le jeton de classe (`select(2, UnitClass("player"))`).
- Au `PLAYER_LOGIN`, quand l'accueil a déjà été vu sur le compte : si `not HasClassPack()` et que la classe n'est pas dans `classPackOffered`, afficher une popup courte « Installer le HUD <Classe> », puis marquer la classe.
- Une seule popup par login. Le login a trois branches exclusives (accueil, « Quoi de neuf », notice des packs) : la proposition passe après « Quoi de neuf », comme la notice des packs (`ShowDueClassPackNotice`).
- Réutiliser les boutons de l'Accueil 2.

**Coût.** S.

**Risque.** Faible : une popup de plus au premier login d'une classe. Aucune migration : une table absente vaut « jamais proposé ». Pour ne pas relancer les comptes existants, marquer d'office les classes qui ont déjà leur pack (`HasClassPack`).

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- Locales (`WeakAuras/Locales/`)

---

### Accueil 3 : Nombre d'auras par pack et par bloc dans la page Packs

**Pourquoi.** La page Packs (`OptionsFrame.lua:1432-1507`) affiche un titre et une description par bloc et par pack utilitaire, sans dire combien d'auras chaque import ajoute. `PackLibrary.lua` décode déjà les packs de classe à l'exécution (`GetClassPackBlocks`, `l.59`). Les packs utilitaires ont leur table `data` (`WeakAurasOptions/UtilityPacks.lua:6-75`).

**Valeur.** Le joueur sait, avant de cliquer, si un bloc ajoute 2 ou 15 auras. Cela répond à la crainte d'un trop-plein d'auras au démarrage.

**À faire.**
- Compter les auras feuilles (hors groupes) de chaque bloc, du HUD complet et de chaque pack utilitaire.
- Afficher le nombre dans le libellé ou l'infobulle du bouton, par exemple « Procs (4 auras) ».
- Calculer une fois, à l'ouverture de la page.

**Coût.** S.

**Risque.** Quasi nul : affichage seulement. Le décodage des packs de classe a un coût : réutiliser le résultat déjà décodé par `GetClassPackBlocks`.

**Fichiers.**
- `WeakAurasOptions/PackLibrary.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `Tests/Scenarios/88_PackLibrary.lua`

---

### Accueil 4 : Écran pour une liste d'auras vide dans `/wa`

**Pourquoi.** Sans aucune aura, la liste de `/wa` est vide, sans texte. Aucune occurrence d'état vide dans `WeakAurasOptions.lua`. Les packs ne sont accessibles que par le bouton « Packs » du panneau « New Aura » (`frame.NewAura`, `OptionsFrame.lua`).

**Valeur.** Un joueur qui a ignoré l'accueil, ou supprimé toutes ses auras, voit tout de suite quoi faire : Packs, Guide, Import.

**À faire.**
- Quand `WeakAurasSaved.displays` est vide, afficher dans la zone de liste un encart avec trois boutons : « Packs » (`frame:OpenPacks()`), « Guide » (`Private.ShowForeverTutorial()`), « Import ».
- Masquer l'encart dès qu'une aura existe : à l'ajout, à l'import, à la restauration (`/wa undelete`).

**Coût.** S à M.

**Risque.** La liste AceGUI est reconstruite à chaque mise à jour (`SortDisplayButtons`, filtre de recherche). Ne pas confondre « aucune aura » avec « aucun résultat pour la recherche ».

**Fichiers.**
- `WeakAurasOptions/WeakAurasOptions.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- Locales

---

### Populaire 1 : Commande `/wa toggle`

**Pourquoi.** Demande #760, refusée en amont. Le contournement est `/run WeakAuras.Toggle()`. `WeakAuras.Toggle` existe déjà (`WeakAuras/WeakAuras.lua:1629`), avec le Shift+clic sur l'icône de la minimap (`l.1294`) et le binding `WEAKAURASTOGGLE`. La commande manque dans le dispatch (`l.238-306`).

**Valeur.** Couper ou rallumer toutes les auras depuis une macro.

**À faire.**
- Ajouter `elseif msg == "toggle" then WeakAuras.Toggle()` dans le dispatch.
- Citer la commande dans `Private.PrintHelp` (`l.206-224`).

**Coût.** S.

**Risque.** Nul.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- Locales

---

### Populaire 10 : Mute global des sons

**Pourquoi.** Demande historique de WeakAuras2. Le seul moyen de faire taire les auras est d'éditer chaque aura ou de baisser le canal du jeu. Aucune occurrence de « mute » dans `WeakAuras/` ni `WeakAurasOptions/`. Toutes les lectures de son passent par `SoundPlayHelper` (`WeakAuras/RegionTypes/RegionPrototype.lua:185-216`) : fichier, `custom` et `KitID`. La synthèse vocale passe par l'action `TTS` (`WeakAuras/WeakAuras.lua:3900-3906`).

**Valeur.** Couper tous les sons des auras d'un coup, par exemple en stream ou en vocal, sans modifier une seule aura.

**À faire.**
- Ajouter un flag `soundsMuted` dans `WeakAurasSaved`, au niveau du compte.
- Ajouter `/wa mute`, qui bascule le flag et affiche l'état dans le chat. Le citer dans `Private.PrintHelp` (`l.206-224`).
- Sortir tôt de `SoundPlayHelper` et de la branche `TTS` quand le flag est posé, comme pour `SquelchingActions`.
- Ajouter une case à cocher dans la barre d'outils de `/wa`, ou dans le menu de l'icône de la minimap.

**Coût.** S.

**Risque.** Faible. Un joueur qui oublie le mute croit ses sons cassés : rappeler l'état au login quand le flag est posé. Le mute ne coupe pas un son déjà en cours.

**Fichiers.**
- `WeakAuras/RegionTypes/RegionPrototype.lua`
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- Locales

---

## 1.21 : fiabilité et diagnostic

Sortie le 2026-11-23 (1.21.0).

Un seul M (Populaire 5), le reste S ou S à M. Dette 5 est close sans développement : voir « Clos sans développement ». Outils 2 et Outils 4 ajoutent deux commandes de diagnostic.

### Ordre

1. Dette 3 : Un seul jeu de helpers pour les secrets
2. Populaire 5 : Safe mode `/wa safemode`
3. Populaire 3 : Alerte des médias manquants à l'import
4. Populaire 2 : Condition de chargement « AddOn chargé »
5. Outils 2 : `/wa report`, rapport de diagnostic à copier
6. Outils 4 : `/wa packcheck`, sorts de pack absents du grimoire

### Déjà fait

Entrée du 2026-11-23 de `CHANGES.md`. Les six tickets sont codés, banc headless à 137 scénarios, 0 échec. Non testé
en jeu : `SUIVI-BUGS-ET-TESTS.md`, étape 17.

- Dette 3 : `Private.IsSecret`, `Private.IsTable`, `Private.Round` partagés, `Shared.IsSecret` retiré. Écart avec le
  ticket : `FirstProblem`, `SameValue` et `ReadLevel` restent par fichier, leurs comportements diffèrent (liste de
  fonctions ou de paires, comparaison profonde ou par index, nil ou 0 sur un secret).
- Populaire 5 : `/wa safemode`, `LoadFunction` rend nil, aucune aura reprise au login, ligne de chat. Le drapeau est
  effacé au chargement : une session au plus.
- Populaire 3 : médias LSM absents listés en doré dans la vue d'import.
- Populaire 2 : option de chargement « AddOn Loaded », noms séparés par des virgules, rescan sur `ADDON_LOADED`.
- Outils 2 : `/wa report` dans la fenêtre du profilage, gabarit `.github/ISSUE_TEMPLATE/bug_report.md`, ligne du
  Guide.
- Outils 4 : `/wa packcheck`, auras reconnues par le préfixe d'uid de `PackBuilder.lua`, triggers de sort et option
  « Spell Known » ; les ID d'auras (buffs, débuffs) ne sont pas vérifiés.
- En plus : `/wa help` liste `pcancel`, `pshow` et `ff`, déjà présentes.

### Reste ouvert

- Tout est à voir en jeu, en particulier la reprise normale après `/wa safemode` et le rescan d'une aura « AddOn
  Loaded » sur un addon chargé à la demande.

---

### Dette 3 : Un seul jeu de helpers pour les secrets

**Pourquoi.** `Private.IsSecret` existe (`WeakAuras/SecretRestrictions.lua:8`) et cinq fichiers l'utilisent. Pourtant, plusieurs fichiers du fork redéfinissent leurs propres helpers :
- `IsSecret` : `SecretAuraAppearance.lua:42`, `SecretAuraSingle.lua:41` (et `Shared.IsSecret` dans `SecretAuraSingleLearning.lua:11`) ;
- `Round` : `SecretAuraAppearance.lua:58`, `SecretAuraSingle.lua:45` ;
- `IsTable` : `SecretAuraConditions.lua:31`, `SecretAuraSingle.lua:40` ;
- `FirstProblem` : `SecretAuraConditions.lua:44`, `SecretAuraSingle.lua:75` ;
- `SameValue` : `CooldownViewerStates.lua:461`, `SecretAuraConditions.lua:1095` ;
- `ReadLevel` : `BlizzardAuraDisplayButtons.lua:38`, `SecretAuraAppearance.lua:66`.

Deux tests de secret qui divergent produisent une erreur Lua en jeu, sur un chemin que le banc ne voit pas.

**Valeur.** Un seul endroit à corriger quand la règle des secrets change.

**À faire.**
- Comparer chaque paire de définitions. Un écart de comportement devient un constat à trancher, pas une fusion silencieuse.
- Remplacer les copies de `IsSecret` par `Private.IsSecret`.
- Pour les autres helpers identiques, les poser une fois sur `Private` (ou sur la table partagée déjà utilisée par `SecretAuraSingle*`).
- Relancer le banc.

**Coût.** S à M.

**Risque.** Régression sous secrets, invisible en headless : `Tests/Harness/Secret.lua` emballe les secrets en userdata, alors qu'en jeu `type(secret)` vaut `"number"`.

**Fichiers.**
- `WeakAuras/SecretAuraAppearance.lua`, `SecretAuraSingle.lua`, `SecretAuraSingleLearning.lua`, `SecretAuraConditions.lua`
- `WeakAuras/CooldownViewerStates.lua`, `BlizzardAuraDisplayButtons.lua`
- `WeakAuras/SecretRestrictions.lua`

---

### Populaire 5 : Safe mode `/wa safemode`

**Pourquoi.** Demande #5369. Une aura custom qui plante en boucle au login n'a aucune issue en jeu : il faut supprimer la SavedVariable à la main.

**Valeur.** Démarrer en pause et sans code custom pour réparer ou supprimer l'aura fautive.

**À faire.**
- `/wa safemode` pose un flag dans `WeakAurasSaved` et lance `ReloadUI()`.
- Au login (`WeakAuras/WeakAuras.lua:1397-1398`), si le flag est posé : rester en `Pause`, ne compiler aucun code custom, afficher un message.
- Retirer le flag au login suivant, ou par une commande de sortie.

**Coût.** M.

**Risque.** Rester bloqué en safe mode si le flag n'est pas retiré. Les options doivent rester utilisables sans code custom compilé.

**Fichiers.**
- `WeakAuras/WeakAuras.lua` (login, commandes `l.227-306`)
- Locales

---

### Populaire 3 : Alerte des médias manquants à l'import

**Pourquoi.** Demande #5477. La fenêtre d'import n'affiche que `scamCheckText` (`WeakAurasOptions/OptionsFrames/Update.lua`). Une aura qui utilise la texture, la police ou le son d'un addon absent s'importe sans prévenir, puis s'affiche avec le média par défaut. `LSM:IsValid(mediatype, key)` existe dans la lib embarquée (`WeakAuras/Libs/LibSharedMedia-3.0/LibSharedMedia-3.0.lua:289`).

**Valeur.** Le joueur sait avant d'importer qu'il lui manque un addon de médias.

**À faire.**
- Parcourir les données importées (auras et sous-régions) et relever les champs de média : texture, police, son.
- Pour chaque nom LSM, tester `LSM:IsValid`. Ignorer les chemins de fichier et les ID numériques.
- Afficher la liste des médias manquants sous le texte de vérification d'import.

**Coût.** S à M.

**Risque.** Faible : affichage seulement. Le relevé doit couvrir tous les champs de média, sans signaler à tort un chemin direct.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/Update.lua`
- `WeakAuras/Transmission.lua`
- Locales

---

### Populaire 2 : Condition de chargement « AddOn chargé »

**Pourquoi.** Demande #5643. Aucune condition de chargement ne dépend d'un autre addon. `C_AddOns.IsAddOnLoaded` est déjà appelé sur Forever (`WeakAuras/BlizzardAuraDisplayLifecycle.lua:100`, `WeakAuras/WeakAuras.lua:79`).

**Valeur.** Une aura qui ne se charge que si l'addon dont elle dépend est présent : boss mod, pack de voix, etc.

**À faire.**
- Ajouter une entrée de type chaîne dans `load_prototype` (`WeakAuras/Prototypes.lua:1212-1768`), après `enabledBossModID` (`l.1696`). Test : `C_AddOns.IsAddOnLoaded(nom)`.
- Réévaluer le chargement à `ADDON_LOADED`, pour les addons chargés à la demande.

**Coût.** S.

**Risque.** Faible. Un nom mal saisi rend l'aura jamais chargée : l'afficher dans la section « Not Loaded ».

**Fichiers.**
- `WeakAuras/Prototypes.lua`
- `WeakAuras/WeakAuras.lua` (événements de chargement)
- Locales

---

### Outils 2 : `/wa report`, rapport de diagnostic à copier

**Pourquoi.** Le joueur n'a aucun moyen d'exporter un diagnostic, et `.github/` ne contient aucun gabarit d'issue. `waErrorHandler` (`WeakAuras/WeakAuras.lua:106-140`) pose déjà les avertissements `LuaError` et `SecretValueRead` par aura. `/wa pprint` n'affiche que le dernier profilage.

**Valeur.** Un rapport de bug arrive avec les informations qui manquent aujourd'hui, sans échange de questions.

**À faire.**
- Commande `/wa report` : fenêtre de texte à copier, comme celle de `/wa pprint`.
- Contenu : version de l'addon, numéro d'interface, classe et niveau, langue du client, addons chargés, nombre d'auras, liste des auras en avertissement avec la clé de l'avertissement.
- Aucun nom de personnage, de royaume ni de guilde dans le rapport.
- Refusée en combat, comme `/wa loadcost`.
- Ajouter la commande à `Private.PrintHelp`, avec `pcancel`, `pshow` et `ff` qui n'y figurent pas (`WeakAuras/WeakAuras.lua:224`).
- Gabarit d'issue dans `.github/ISSUE_TEMPLATE/` qui demande de coller le rapport.

**Coût.** S à M.

**Risque.** Faible. La liste des clés d'avertissement de `WeakAuras/AuraWarnings.lua` n'a pas été lue.

**À tester en jeu.** `/wa report` hors combat puis en combat. Une aura en erreur Lua apparaît dans la liste.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAuras/AuraWarnings.lua`
- `.github/ISSUE_TEMPLATE/` (neuf), `GUIDE.md`
- les `Locales/enUS.lua` et `frFR.lua`

---

### Outils 4 : `/wa packcheck`, sorts de pack absents du grimoire

**Pourquoi.** Les `Tests/Packs/*/NOTES.md` gardent des ID « pas encore vérifiés en jeu » : Chaman (`NOTES.md:52`), Wyvern Sting du Chasseur (`:26`), Holy Strike du Paladin (`:48`), rangs de Fire Ward, Frost Ward et Slow Fall du Mage (`:14`). Le banc n'a pas de grimoire, donc seul le jeu peut trancher.

**Valeur.** La vérification d'un pack par classe tient en une commande. Le joueur voit pourquoi une aura reste vide.

**À faire.**
- Commande `/wa packcheck` : pour chaque aura installée qui vient d'un pack de classe, relever les sorts de ses triggers et de ses conditions de chargement, puis lister ceux que `WeakAuras.IsSpellKnownIncludingPet` ne connaît pas.
- Sortie dans le chat : nom de l'aura, ID du sort, nom du sort quand le client le donne.
- Distinguer « sort inconnu du client » de « sort non appris ».
- Refusée en combat.

**Coût.** S à M.

**Risque.** Faible. Les sorts de talent non pris sortent comme non appris : le dire dans le message.

**À tester en jeu.** Une classe avec son HUD complet installé, personnage de bas niveau puis de haut niveau.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/ClassPacks.lua`
- les `Locales/enUS.lua` et `frFR.lua`

---

## 1.22 : édition d'auras et design classique

Sortie le 2026-11-25 (1.22.0).

Deux M (Populaire 4, Populaire 6), Placement 7, réduit à S à M depuis les liens d'ancrage de la 1.17.0, et Rebranding 9 (M à L), ajouté le 2026-11-24 à la demande de l'auteur. La version dépasse la règle 4 : décision de l'auteur. Populaire 7 passe en 1.24.

### Ordre

1. Populaire 4 : Nom de trigger éditable
2. Populaire 6 : Options custom conditionnelles
3. Placement 7 : Ancrer une aura à une autre en la calant dessus
4. Rebranding 9 : Mode « design classique » de WeakAuras. En dernier : les écrans des trois tickets précédents se vérifient dans les deux designs.

### Déjà fait

Entrée du 2026-11-25 de `CHANGES.md`. Les quatre tickets sont codés, banc headless à 138 scénarios, 0 échec. Non
testé en jeu : `SUIVI-BUGS-ET-TESTS.md`, étape 18, et `TESTS-1.22.md`.

- Populaire 4 : champ « Trigger Name » (`triggers[n].name`), `Private.TriggerName` et `Private.TriggerLabel`. Le nom
  remplace « Trigger N » dans le titre du trigger, les conditions, la liste des propriétés de condition et la source
  d'icône. Champ vide ou blanc : le numéro reste.
- Populaire 6 : règle « Visible If » (`visibleIf = { key, value }`) sur toute option custom, cible de même niveau
  (toggle, select, input, number, range). Appliquée en mode utilisateur, groupe et sous-options compris. Une cible
  supprimée laisse l'option visible ; une version sans le champ l'ignore.
- Placement 7 : modificateur Alt au lâcher. `AnchorLinks.SnapLink` lit les lignes de calage et crée le lien par
  `AnchorLinks.LinkInPlace` / `LinkTo`, sans second chemin d'écriture. Dans le mode édition, Alt déjà tenu au clic
  garde son rôle (groupe) : seul un Alt pressé pendant le glissement ancre.
- Rebranding 9 : `/wa design` et case « Classic design » de la barre d'outils, réglage `WeakAurasSaved.classicDesign` au
  niveau du compte, Musca par défaut, `/reload` demandé. `Style.UseClassic` remplace la palette et les polices ;
  logo WeakAuras dans la bande de titre.

### Reste ouvert

- Tout est à voir en jeu, dans les deux designs.
- Écart avec Rebranding 9 : le mode classique change les couleurs, les polices et le logo, pas le dessin des cadres,
  boutons, barres de défilement et champs. Les interdits 3 et 5 de `DESIGN.md` refusent `UIPanelButtonTemplate`,
  les textures Blizzard et un écran mi-Blizzard mi-Musca : à trancher par l'auteur. Logo carré `logo_256.tga`,
  `logo_256_round.tga` n'existant plus.
- Écart avec Populaire 6 : la règle ne s'applique pas en mode auteur (l'auteur voit toutes ses options), et rien
  n'est grisé : l'option est masquée.
- Placement 7 : pas de lien sur un coin, seulement bord contre bord.
- Couleurs écrites hors de `Style` (relevé du 2026-11-25) : `|cff` dans `CommonOptions.lua`,
  `WeakAurasOptions.lua`, `TriggerOptions.lua`, `BuffTrigger2.lua`, `InformationOptions.lua`, `Update.lua`. Elles
  gardent leur couleur en mode classique.
- Couleurs figées au chargement d'un fichier, avant `Style.UseClassic` (relecture du 2026-11-25) : `Profiling.lua:12`,
  `SecretAuraSingle.lua:23`, `Types.lua` (688, 850, 1261, 1280-1283, 1947-1948), `Prototypes.lua` (1511, 1555,
  1771, 1798, 9143), popups de `WeakAuras.lua` (3044, 3064), `BossMods.lua:1464-1466`, `EditModePlacement.lua`
  (302, 569). Elles restent Musca en mode classique : à construire à l'affichage si l'écart gêne.

---

### Populaire 4 : Nom de trigger éditable

**Pourquoi.** Demande #4617. Un trigger n'a pas de nom libre. Seul `customName` existe, et c'est une fonction. Les conditions et la liste affichent « Trigger 3 ».

**Valeur.** Des conditions lisibles sur les auras qui ont plusieurs triggers.

**À faire.**
- Ajouter un champ texte `name` au trigger, dans l'en-tête des options (`WeakAurasOptions/TriggerOptions.lua:262`).
- L'afficher dans les titres de trigger et dans les listes de `ConditionOptions.lua`, à la place de « Trigger N » quand il est rempli.

**Coût.** M.

**Risque.** Nouveau champ de data. Aucune migration : un champ absent garde le libellé actuel. Vérifier qu'il passe à l'export.

**Fichiers.**
- `WeakAurasOptions/TriggerOptions.lua`
- `WeakAurasOptions/ConditionOptions.lua`
- Locales

---

### Populaire 6 : Options custom conditionnelles

**Pourquoi.** Demande #4496. Une option d'auteur ne peut pas se masquer ou se griser selon la valeur d'une autre (`WeakAurasOptions/AuthorOptions.lua`).

**Valeur.** Des packs avec des réglages plus simples : on n'affiche que les options utiles au choix fait.

**À faire.**
- Ajouter à chaque option une règle « visible si » : une autre option et sa valeur.
- L'appliquer en mode utilisateur et en mode auteur, dans les `hidden` ou `disabled` d'AceConfig.

**Coût.** M.

**Risque.** La règle se sérialise avec l'aura : rester compatible à l'import vers une version qui ne la connaît pas (champ ignoré). Une règle qui vise une option supprimée ne doit pas planter.

**Fichiers.**
- `WeakAurasOptions/AuthorOptions.lua`
- Locales

---

### Placement 7 : Ancrer une aura à une autre en la calant dessus

**Pourquoi.** Depuis la 1.17.0, le bouton « Link » du déplaceur `/wa` et le menu d'ancrage des boîtes du mode édition lient une aura à une autre (`AnchorLinks.lua`, `AnchorLinker.lua`, scénario 98). Les boucles sont refusées (`AnchorLinks.DependsOn`). Il manque le geste direct : lâcher une aura sur le bord d'une autre pour créer le lien.

**Valeur.** Des auras collées qui bougent ensemble, sans passer par un bouton ni un menu.

**À faire.**
- Au lâcher calé sur un bord d'aura, avec un modificateur à choisir, créer le lien par les fonctions d'`AnchorLinks.lua`. Pas de second chemin d'écriture de l'ancrage.
- Même geste dans le déplaceur `/wa` et dans le mode édition.

**Coût.** S à M. Le ticket valait L avant les liens d'ancrage de la 1.17.0.

**Risque.** Ctrl (centres), Maj (sans calage dans le mode édition, inverse « Aligner magnétiquement » dans `/wa`) et Alt (groupe, dans le mode édition) sont déjà pris : le modificateur est à trouver. Aura qui disparaît quand l'aura cible n'est pas chargée, comme pour les liens actuels.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `WeakAuras/EditModePlacement.lua`
- `WeakAuras/AnchorLinks.lua`

---

### Rebranding 9 : Mode « design classique » de WeakAuras

**Pourquoi.** Demandé par l'auteur le 2026-11-24. Depuis la 1.17 et la 1.18, la fenêtre `/wa`, le mode édition, le Guide et les popups ont le look Musca : fonds plats, or et anthracite. Un habitué de WeakAuras peut vouloir retrouver le look d'origine. Le module de thème existe depuis la 1.18 : `WeakAuras/Style.lua` (`Style.colors`, `Style.Fill`, `Style.NewButton`, `Style.SkinScrollBar`, `Style.SkinEditBox`, `Style.SetFont`…), utilisé par 73 fichiers.

**Valeur.** Un joueur revient au look WeakAuras d'origine en un clic, sans quitter Musca Auras.

**À faire.**
- Relever le look d'origine dans le source WeakAuras 5.22.0 : couleurs, cadre de la fenêtre d'options, boutons, barres de défilement, champs, police, logo.
- Ajouter à `Style.lua` un second jeu « classique » : `Style.colors` et ce que dessinent `Style.Fill`, `Style.NewButton`, `Style.SkinScrollBar`, `Style.SkinEditBox` et `Style.SetFont`. Les appelants ne changent pas.
- Ajouter le réglage au compte, avec le design Musca par défaut, et l'interrupteur dans la fenêtre d'options et en commande `/wa`. Le changement demande un `/reload` : le dire au joueur.
- Remettre le logo WeakAuras (`logo_256_round.tga`) dans la bande de titre en mode classique (`OptionsFrame.lua:116`).
- Ne pas toucher aux auras du joueur ni au nom « Musca Auras ».

**Coût.** M à L. Plus large que l'estimation M de la 1.18 : le thème porte aussi les cadres, les boutons et les barres, pas seulement les couleurs.

**Risque.** Deux habillages à maintenir : chaque nouvel écran se vérifie dans les deux, en jeu. Un widget qui écrit sa couleur hors de `Style` garde le look Musca : vérifier par grep `SetColorTexture`, `SetVertexColor`, `SetTextColor`, `SetBackdropColor` et `|cff` hors de `Style.lua`. Régression visuelle non couverte par le banc.

**Fichiers.**
- `WeakAuras/Style.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAurasOptions/WeakAurasOptions.lua` (valeurs par défaut)
- `WeakAuras/WeakAuras.lua` (commande)
- Locales

---

## 1.23 : sauvegardes

Deux M. Outils 5 et Outils 6 touchent la même zone de la fenêtre d'options et s'appuient sur les tests de restauration de Dette 4 (1.19).

### Ordre

1. Outils 5 : Sauvegardes dans la fenêtre `/wa`
2. Outils 6 : « Revenir à la version importée » pour une aura

---

### Outils 5 : Sauvegardes dans la fenêtre `/wa`

**Pourquoi.** `/wa backups`, `/wa restore <n>`, `/wa deleted` et `/wa undelete <n>` n'existent qu'en commande (`WeakAuras/WeakAuras.lua:262-390`). Une recherche de « backup » ne trouve rien dans `OptionsFrame.lua`, `DisplayButton.lua` ni `WeakAurasOptions.lua`. Le moteur garde pourtant trois copies quotidiennes et les auras supprimées pendant 30 jours (`WeakAuras/AuraBackups.lua:5-9`, `:86-89`).

**Valeur.** Un joueur qui supprime une aura par erreur la retrouve sans connaître la commande.

**À faire.**
- Entrée « Sauvegardes » dans la fenêtre : liste des copies quotidiennes avec leur date et leur nombre d'auras, liste des auras supprimées avec leur date de suppression.
- Bouton de restauration d'une aura supprimée : même chemin que `/wa undelete`, par la fenêtre d'import.
- Bouton de restauration d'une copie : même confirmation `WEAKAURAS_CONFIRM_RESTORE` que la commande, puis rechargement.
- Désactivé en combat.
- Suivre `DESIGN.md` s'il existe, et la charte de la 1.18.

**Coût.** M.

**Risque.** Moyen. La restauration d'une copie remplace toutes les auras : la confirmation ne doit pas pouvoir être contournée.

**À tester en jeu.** Supprimer une aura, la restaurer par le bouton. Restaurer une copie de la veille. Bouton grisé en combat.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAuras/AuraBackups.lua`
- les `Locales/enUS.lua` et `frFR.lua`

---

### Outils 6 : « Revenir à la version importée » pour une aura

**Pourquoi.** `Private.SetHistory` est appelé à l'import (`WeakAurasOptions/OptionsFrames/Update.lua:2111`), mais rien ne relit cet historique : aucune fonction de lecture ni de restauration trouvée, aucune interface.

**Valeur.** Le joueur annule ses modifications sur un pack ou une aura importée sans la réimporter.

**À faire.**
- Lire `WeakAuras/History.lua` pour établir ce qui est gardé (aura seule ou groupe entier, durée de conservation) avant de concevoir.
- Entrée « Revenir à la version importée » dans le menu de l'aura, visible seulement quand un historique existe.
- Confirmation avant remplacement. L'action passe par l'annulation de `WeakAuras/TimeMachine.lua` pour rester réversible.
- Pas de badge « modifiée » dans la liste : ce marquage a été écarté le 2026-10-27.

**Coût.** M.

**Risque.** Moyen. Le contenu réel de l'historique n'a pas été lu : si seule la dernière version importée est gardée sans les enfants, le ticket se limite aux auras seules.

**À tester en jeu.** Importer un pack, modifier une aura, revenir à la version importée, annuler par le bouton d'annulation.

**Fichiers.**
- `WeakAuras/History.lua`
- `WeakAurasOptions/OptionsFrames/Update.lua`
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`
- Scénario neuf

---

## 1.24 : groupes dynamiques et annonce de version

Deux M sans lien entre eux, chacun testable seul. Outils 7 : vérifier l'API des messages d'addon avec `wow-api` avant de coder.

### Ordre

1. Populaire 7 : Taille imposée aux enfants d'un groupe dynamique
2. Outils 7 : Annonce de nouvelle version entre joueurs

---

### Populaire 7 : Taille imposée aux enfants d'un groupe dynamique

**Pourquoi.** Demande #4057. Chaque enfant d'un groupe dynamique garde sa propre taille (`WeakAuras/RegionTypes/DynamicGroup.lua`, vers `l.1507`). Pour redimensionner une barre d'icônes, il faut modifier chaque aura.

**Valeur.** Une seule taille à régler pour toutes les icônes d'un groupe.

**À faire.**
- Ajouter au groupe dynamique une option « Taille des enfants » : largeur et hauteur.
- L'appliquer aux régions enfants à la mise en place, sans réécrire leurs données.

**Coût.** M.

**Risque.** Rendre sa taille propre à un enfant qui sort du groupe. Ne pas toucher aux types de région sans taille réglable.

**Fichiers.**
- `WeakAuras/RegionTypes/DynamicGroup.lua`
- Options du groupe dynamique (`WeakAurasOptions/RegionOptions/`)
- Locales

---

### Outils 7 : Annonce de nouvelle version entre joueurs

**Pourquoi.** `WeakAurasOptions/VersionCheck.lua` compare seulement la version des options à celle du moteur. Le moteur n'envoie aucun message d'addon de version : les seuls envois sont dans des packs utilitaires et dans la demande d'aura de `WeakAuras/Transmission.lua:680-695`.

**Valeur.** Un joueur en retard d'une version l'apprend en guilde ou en groupe, une fois par session.

**À faire.**
- Vérifier d'abord avec `wow-api` l'envoi de messages d'addon sur Forever : canaux permis, restrictions en instance et en combat (`GetWhisperBlock`, `WeakAuras/Transmission.lua:236-243`).
- Fichier neuf `WeakAuras/VersionCheck.lua` : envoi de la version à l'entrée en groupe et au login en guilde, hors combat.
- À la réception d'une version plus récente : une ligne dans le chat, une seule fois par session.
- Ne jamais répondre à un message reçu, pour éviter les rafales.
- Option pour couper l'annonce.

**Coût.** M.

**Risque.** Moyen. Si les messages d'addon sont bloqués en instance, la valeur se limite à la guilde. Comparaison de versions à écrire avec soin (`1.9.0` avant `1.19.0`).

**À tester en jeu.** Deux comptes en groupe avec deux versions différentes. Aucun message en combat. Une seule ligne par session.

**Fichiers.**
- `WeakAuras/VersionCheck.lua` (neuf), `WeakAuras/WeakAuras.toc`
- `WeakAuras/WeakAuras.lua`
- Scénario neuf, `GUIDE.md`

---

## 1.25 : API, fondations

Série décidée le 2026-11-21. But de l'auteur : une API sur laquelle d'autres addons, par exemple les addons d'interface, branchent des modules pour utiliser le moteur. Un seul M (API 4).

État lu dans le code le 2026-11-21, rien testé en jeu :

- Environ 185 symboles sur la table globale `WeakAuras`. Aucun numéro d'API : seuls `WeakAuras.versionString`, `buildTime` et `BuildInfo` (`WeakAuras/Init.lua:397-400`) et `WeakAuras.InternalVersion` (`WeakAuras/WeakAuras.lua:98`) existent.
- `Private` est la table `select(2, ...)` de l'addon (`Init.lua:2`). Elle n'est exposée nulle part en global : un addon tiers n'y accède pas.
- Aucun scénario ne joue un addon tiers, aucun test ne fige la liste des fonctions publiques.
- Les fonctions d'enregistrement sont bloquées dans l'environnement du code custom des auras (`WeakAuras/AuraEnvironment.lua:485-497`). Elles le restent.

Comportement en combat d'appels venus d'un addon tiers (valeurs secrètes, taint) : non vérifié. Chaque ticket qui ouvre une fonction liste ses tests en jeu.

### Ordre

1. API 1 : Contrat public versionné
2. API 3 : Types de région publics et validation des systèmes de trigger
3. API 2 : Bus d'événements public
4. API 4 : Registre de modules

---

### API 1 : Contrat public versionné

**Pourquoi.** Un addon tiers ne peut pas savoir ce qu'il a le droit d'appeler, ni tester la version de l'API. La table `WeakAuras` mélange environ 185 symboles : fonctions d'enregistrement, lecture d'état, actions, et utilitaires destinés au code custom des auras. Aucun test ne signale le retrait ou le changement d'une fonction publique.

**Valeur.** Un auteur d'addon lit une liste courte de fonctions garanties et teste un numéro. Un changement cassant se voit dans le banc avant la sortie.

**À faire.**
- Ajouter `WeakAuras.API_VERSION`, un entier qui monte à chaque changement cassant.
- Écrire la liste des fonctions garanties. Départ : `RegisterSubRegionType`, `RegisterSubRegionOptions`, `RegisterTriggerSystem`, `RegisterTriggerSystemOptions`, `GetData`, `GetRegion`, `GetTriggerStateForTrigger`, `GetActiveStates`, `IsAuraLoaded`, `IsAuraActive`, `IsOptionsOpen`, `IsLoginFinished`, `IsRestricted`, `GetUnitFrame`, `GetUnitNameplate`, `ScanEvents`, `Import`, `ImportClassPack`, `OpenOptions`, `Toggle`. Tout le reste est déclaré interne dans la documentation.
- Scénario qui fige cette liste : nom et type de chaque entrée.
- Scénario « addon tiers » : du code chargé après `WeakAuras`, sans accès à `Private`, appelle chaque fonction de la liste.
- Section « API for addon authors » dans `GUIDE.md`.

**Coût.** S.

**Risque.** Nul pour le joueur. La liste engage : n'y mettre que ce qui restera stable.

**Fichiers.**
- `WeakAuras/Init.lua`
- Deux scénarios neufs dans `Tests/Scenarios/`
- `GUIDE.md`, `CHANGES.md`

---

### API 3 : Types de région publics et validation des systèmes de trigger

**Pourquoi.**
- `RegisterRegionType` et `RegisterRegionOptions` n'existent que sur `Private` (`WeakAuras/WeakAuras.lua:631`, `:739`, stubs à `Init.lua:604-610`), alors que les sous-régions s'enregistrent par `WeakAuras.RegisterSubRegionType` (`:675`). Un addon tiers ne peut pas ajouter son propre type d'affichage.
- `WeakAuras.RegisterTriggerSystem(types, triggerSystem)` (`:5157`) ne valide rien, alors que le moteur appelle 12 méthodes sur chaque système : `UnloadAll`, `LoadDisplays`, `UnloadDisplays`, `FinishLoadUnload`, `Delete`, `Rename`, `Add`, `GetAdditionalProperties`, `GetProgressSources`, `GetTriggerConditions`, `CreateFallbackState`, `SetToolTip`. Une méthode absente donne une erreur plus tard, loin de sa cause.

**Valeur.** Un addon tiers ajoute un type de région. Une erreur de sa part sort à l'enregistrement, avec son nom, pas en plein combat.

**À faire.**
- Exposer `WeakAuras.RegisterRegionType` et `WeakAuras.RegisterRegionOptions`, qui appellent les fonctions de `Private` avec leur validation actuelle.
- Dans `RegisterTriggerSystem` : lever une erreur (`error(..., 2)`) quand une des 12 méthodes manque ou qu'un type est déjà pris.
- Garder ces fonctions bloquées dans l'environnement du code custom (`AuraEnvironment.lua:492-497`), et y ajouter les deux nouvelles.
- Ajouter les deux fonctions à la liste figée d'API 1.

**Coût.** S.

**Risque.** Faible. La validation peut refuser un système interne incomplet : `aura2`, les types génériques et `secretAura` passent par le banc. Une aura sauvegardée dont le type de région vient d'un addon absent : vérifier qu'elle se décharge sans erreur.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`, `WeakAuras/Init.lua`
- `WeakAuras/AuraEnvironment.lua`
- Un scénario neuf

---

### API 2 : Bus d'événements public

**Pourquoi.** `Private.callbacks` est un bus interne, sans désabonnement (`WeakAuras/WeakAuras.lua:40-47`). Il émet déjà `Add`, `Delete`, `Rename`, `RenameFirst`, `AboutToDelete`, `ScanForLoads`, `AuraWarningsUpdated`, `ProfileCostsUpdated` et `RestrictionChanged` (`WeakAuras/SecretRestrictions.lua:90`). Rien n'est exposé sur `WeakAuras`. Aucun événement ne signale la fin du chargement des options (les seuls sont `BeforeReload` et `AfterReload`, `WeakAurasOptions/LoadOptions.lua:1007`, `:1010`), ni l'affichage d'une aura.

**Valeur.** Un addon d'interface réagit au moteur, par exemple quand une aura apparaît ou quand les restrictions de combat changent, sans le sonder à intervalle.

**À faire.**
- `WeakAuras.RegisterCallback(owner, event, func)` et `WeakAuras.UnregisterCallback(owner, event)`, posées sur `Private.callbacks`. Ajouter le désabonnement au bus.
- Événements publics : `Add`, `Delete`, `Rename`, `ScanForLoads`, `RestrictionChanged`, plus trois neufs : `OptionsLoaded`, `AuraShown` (id, cloneId) et `AuraHidden` (id, cloneId).
- Appeler chaque fonction d'un tiers de façon protégée : une erreur est signalée avec le nom de son propriétaire et ne coupe ni le moteur ni les autres abonnés.
- Ajouter les deux fonctions et la liste des événements à API 1.

**Coût.** S à M.

**Risque.** Faible. `AuraShown` et `AuraHidden` partent à chaque changement d'état : ne rien émettre quand personne n'est abonné. Ne passer que des identifiants, jamais une valeur lue en combat.

**À tester en jeu.** Abonnement à `AuraShown` sur une aura de buff, en combat : pas d'erreur, pas de chute de fps.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAuras/RegionTypes/RegionPrototype.lua`
- `WeakAurasOptions/WeakAurasOptions.lua`
- Un scénario neuf, `GUIDE.md`

---

### API 4 : Registre de modules

**Pourquoi.** Le modèle de module actuel ne sert que les cinq addons du dépôt : `WeakAuras` charge `WeakAurasOptions` à la demande (`WeakAuras/WeakAuras.lua:164`) et lui passe `Private` par `UsePrivate` (`WeakAurasOptions/WeakAurasOptions.lua:793`). Les options de région s'enregistrent une seule fois, à ce moment-là (`:793-800`) : un addon tiers qui s'inscrit après n'est jamais appelé, et il ne peut pas savoir si les options sont déjà chargées.

**Valeur.** Un point d'entrée unique. L'addon tiers déclare son module, et le moteur appelle chaque étape au bon moment, quel que soit l'ordre de chargement des addons.

**À faire.**
- `WeakAuras.RegisterModule(name, module)`, où `module` est une table : `apiVersion` (obligatoire), `OnEngineReady` et `OnOptionsLoaded` (facultatives).
- `OnEngineReady` : appelée à la fin du login, ou tout de suite si le login est fini (`WeakAuras.IsLoginFinished`).
- `OnOptionsLoaded` : appelée après `UsePrivate`, ou tout de suite si les options sont ouvertes. C'est là qu'un module enregistre ses options de région, de sous-région et de trigger.
- Refuser un module dont `apiVersion` dépasse `WeakAuras.API_VERSION`, avec un message dans le chat qui nomme le module. Refuser un nom déjà pris.
- Appels protégés, comme dans API 2.
- `WeakAuras.GetModules()` : noms des modules inscrits, pour le diagnostic. Les lister dans `/wa pprint`.
- Addon d'exemple minimal dans `Tests/Fixtures/`, chargé par un scénario.

**Coût.** M.

**Risque.** Moyen. Ordre des appels pendant le login, où `ImportClassPack` refuse déjà de tourner (`WeakAuras.lua:198-203`). Un module qui enregistre un type de région après le chargement des auras sauvegardées : les auras de ce type doivent être recréées, à vérifier dans le scénario.

**Fichiers.**
- `WeakAuras/Modules.lua` (neuf), `WeakAuras/WeakAuras.toc`
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/WeakAurasOptions.lua`
- `Tests/Fixtures/`, un scénario neuf
- `GUIDE.md`, `CHANGES.md`

---

## 1.26 : API, packs, ancrage et triggers

Trois tickets indépendants entre eux. API 5 dépend d'API 4 (1.25) et d'Accueil 3 (1.20). API 7 est le plus lourd (M à L) : il peut sortir seul si la version devient trop grosse.

### Ordre

1. API 5 : Packs fournis par un addon tiers
2. API 6 : Cadres d'ancrage déclarés par les addons
3. API 7 : Prototypes de trigger tiers

---

### API 5 : Packs fournis par un addon tiers

**Pourquoi.** Les packs utilitaires sont une table privée, `OptionsPrivate.utilityPacks`, remplie par un fichier du toc des options (`WeakAurasOptions/UtilityPacks.lua:5-8`, `WeakAurasOptions.toc:74-76`). Format : `{ name, description, category, icon, data = "!WA:2!..." }`. Aucune fonction d'enregistrement. `WeakAuras.ImportClassPack()` ne sert que le pack de classe du joueur.

**Valeur.** Un addon d'interface livre ses auras prêtes à installer, visibles dans la page Packs à côté des packs utilitaires.

**À faire.**
- `WeakAuras.RegisterPack(owner, pack)`, même format que les packs utilitaires. Les packs inscrits avant le chargement des options sont gardés en attente.
- Afficher ces packs dans la page Packs (`WeakAurasOptions/OptionsFrames/OptionsFrame.lua:1709`, `:1736`), dans une catégorie au nom de l'addon fournisseur.
- L'import passe par `WeakAuras.Import` et sa fenêtre de confirmation, comme aujourd'hui.
- Valider à l'enregistrement : champs présents, chaîne décodable (`Private.StringToTable`). Un pack invalide est refusé avec le nom de son propriétaire.
- Compteur d'auras d'Accueil 3 appliqué à ces packs.

**Coût.** S.

**Risque.** Faible. Un pack tiers peut contenir du code custom : la fenêtre de confirmation le montre déjà, ne pas l'affaiblir.

**Fichiers.**
- `WeakAurasOptions/PackLibrary.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAuras/WeakAuras.lua`
- `Tests/Scenarios/88_PackLibrary.lua`

---

### API 6 : Cadres d'ancrage déclarés par les addons

**Pourquoi.** L'ancrage « Unit Frame » passe par `WeakAuras.GetUnitFrame = LGF.GetUnitFrame` (`WeakAuras/AuraEnvironment.lua:158-159`), soit LibGetFrame-1.0. La lib reconnaît les addons par des motifs de noms écrits en dur (`WeakAuras/Libs/LibGetFrame-1.0/LibGetFrame-1.0.lua:35-200`), plus deux cas particuliers (`:552`, `:559`). Un addon d'unit frames absent de cette liste n'est pas trouvé, et rien côté moteur ne permet de l'ajouter.

**Valeur.** Une aura s'ancre aux cadres de n'importe quel addon d'interface, sans attendre une mise à jour de la lib.

**À faire.**
- `WeakAuras.RegisterUnitFrameProvider(owner, func)`, où `func(unit)` renvoie un cadre ou `nil`. Les fournisseurs sont consultés avant LibGetFrame.
- `WeakAuras.UnregisterUnitFrameProvider(owner)`.
- Relancer l'ancrage des auras concernées quand un fournisseur s'inscrit.
- Ne pas modifier la lib embarquée.

**Coût.** S à M.

**Risque.** Faible. Un cadre protégé comme ancre peut rendre la région protégée (voir le principe de Populaire 11) : refuser l'ancre quand `frame:IsProtected()` est vrai, ou le documenter après test.

**À tester en jeu.** Aura ancrée à un cadre fourni par un addon tiers, en combat : elle s'affiche et se cache sans `ADDON_ACTION_BLOCKED`.

**Fichiers.**
- `WeakAuras/AuraEnvironment.lua`
- `WeakAuras/AnchorLinks.lua`
- `WeakAuras/RegionTypes/RegionPrototype.lua`
- Un scénario neuf

---

### API 7 : Prototypes de trigger tiers

**Pourquoi.** Les triggers à options générées viennent de `Private.event_prototypes` (`WeakAuras/Prototypes.lua:2038`), une table interne. Pour exposer ses données, un addon tiers a deux chemins : écrire un système de trigger complet avec ses 12 méthodes et ses options, ou envoyer `WeakAuras.ScanEvents` et laisser le joueur écrire du code custom (`WeakAuras/GenericTrigger.lua:962`).

**Valeur.** L'addon d'interface expose ses données comme un trigger normal, réglable par le joueur sans une ligne de code.

**À faire.**
- `WeakAuras.RegisterTriggerPrototype(owner, name, prototype)`, qui ajoute le prototype à la catégorie « addons » (`Private.category_event_prototype.addons`).
- Valider le prototype à l'enregistrement : `type`, `events`, `name`, `args`. Refuser un nom déjà pris.
- Aura dont le prototype est absent, parce que l'addon fournisseur n'est pas chargé : elle reste déchargée, sans erreur, avec un avertissement dans les options.
- Documenter le format d'un prototype dans `GUIDE.md`, sur un exemple complet.

**Coût.** M à L.

**Risque.** Moyen. Les prototypes servent à générer du code à partir de chaînes : repasser les chemins de `ConstructTest` sur un prototype tiers (correctif `%q` du 2026-10-30, `Tests/Scenarios/90_GenericTestQuoting.lua`). Un prototype mal écrit peut ralentir tous les triggers génériques.

**Fichiers.**
- `WeakAuras/Prototypes.lua`
- `WeakAuras/GenericTrigger.lua`
- `WeakAurasOptions/GenericTrigger.lua`
- Un scénario neuf, `GUIDE.md`

---

## 1.27 : templates personnalisés

Les trois dernières versions portent chacune un seul gros ticket : les L ferment le plan (règle 4). Populaire 8 est M à L.

### Ordre

1. Populaire 8 : Templates personnalisés

---

### Populaire 8 : Templates personnalisés

**Pourquoi.** Demande #3773. `WeakAurasTemplates` ne contient que des données fixes. On ne peut pas enregistrer une aura comme modèle.

**Valeur.** Créer une nouvelle aura à partir de sa propre aura modèle, sans copier puis modifier.

**À faire.**
- Ajouter une action « Enregistrer comme template » sur une aura. Elle stocke une copie dans les SavedVariables des options.
- Lister ces templates dans le panneau « New » (`frame.NewAura`, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua:1509+`).
- Permettre de supprimer un template.

**Coût.** M à L.

**Risque.** Taille des SavedVariables. Copie sans `id`, `uid` ni `parent`, pour ne pas lier le modèle à l'aura d'origine.

**Fichiers.**
- `WeakAurasTemplates/`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAurasOptions/WeakAurasOptions.lua`
- Locales

---

## 1.28 : animations conditionnelles

Un seul ticket, L. Populaire 9 touche aux conditions comme Populaire 4 (1.22) : il passe après.

### Ordre

1. Populaire 9 : Animations conditionnelles

---

### Populaire 9 : Animations conditionnelles

**Pourquoi.** Demande #314, la plus votée, marquée « Accepted » en amont mais jamais faite. Une condition ne peut pas lancer d'animation.

**Valeur.** Un pulse, un shake ou un flash quand une condition devient vraie, par exemple un sort prêt.

**À faire.**
- Ajouter une propriété de condition « Jouer une animation » (`WeakAurasOptions/ConditionOptions.lua:526`).
- La déclencher au passage à vrai (`WeakAuras/Conditions.lua:150`), par le moteur `WeakAuras/Animations.lua`.

**Coût.** L.

**Risque.** Conflit avec les animations start, main et finish de l'aura. Une animation relancée à chaque mise à jour au lieu d'une seule fois au changement d'état.

**Fichiers.**
- `WeakAurasOptions/ConditionOptions.lua`
- `WeakAuras/Conditions.lua`
- `WeakAuras/Animations.lua`
- Locales

---

## 1.29 : API, auras possédées par un addon

Un seul ticket, L, à risque élevé : il sort seul, comme Populaire 11 en 1.19. À ne lancer que quand un addon d'interface réel en a besoin.

### Ordre

1. API 8 : Auras possédées par un addon, non sauvegardées

---

### API 8 : Auras possédées par un addon, non sauvegardées

**Pourquoi.** `WeakAuras.Add(data)` écrit toujours dans `WeakAurasSaved` (`WeakAuras/WeakAuras.lua:3638`, `:3663`, `:3711`). Il n'existe aucune notion d'aura possédée par un addon : un addon qui crée ses auras par code les mélange à celles du joueur, elles restent après sa désinstallation, et elles partent dans les exports et les sauvegardes.

**Valeur.** Un addon d'interface fait tourner ses propres affichages sur le moteur sans rien écrire dans les données du joueur.

**À faire.**
- `WeakAuras.AddOwned(owner, data)` et `WeakAuras.DeleteOwned(owner, id)`. L'addon recrée ses auras à chaque session.
- Ranger ces auras hors de `db.displays`, ou les marquer et les retirer à la sauvegarde : à trancher à la conception, selon le nombre de lectures de `db.displays` à adapter.
- Les exclure des exports (`WeakAuras/Transmission.lua`), des sauvegardes (`WeakAuras/AuraBackups.lua`) et de la migration.
- Dans `/wa` : les afficher dans un groupe au nom de l'addon, en lecture seule, ou les masquer. À trancher.
- Identifiants préfixés par le nom du propriétaire, pour éviter une collision avec une aura du joueur.
- Refuser le code custom dans une aura possédée, ou l'accepter : à trancher. L'aura ne passe pas par la fenêtre de confirmation.

**Coût.** L.

**Risque.** Élevé. `db.displays` est lu dans tout le moteur et dans les options. Une aura possédée qui fuit dans `WeakAurasSaved` reste orpheline. Dette 4 (tests de migration et de restauration) doit couvrir ce cas avant.

**À tester en jeu.** Aura possédée créée au login puis en combat. `/reload` : aucune trace dans `WeakAurasSaved`. Addon fournisseur désactivé : aucune aura orpheline.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAuras/Transmission.lua`, `WeakAuras/AuraBackups.lua`
- `WeakAurasOptions/WeakAurasOptions.lua`
- Scénarios neufs, `GUIDE.md`

---

## Dette notée, sans ticket

### Dette technique

- `GenericTrigger.lua:3744` et `:3969` : même TODO sur le retour de `GetItemCooldown` (`1/0` ou `true/false`), bloc recopié deux fois. Vérifier d'abord l'API Forever avec `wow-api`.
- `GenericTrigger.lua:3413` (`shortcut:`) : les charges sont ignorées, un sort qui a encore des charges est lu comme non prêt.
- `AuraBackups.lua:42` (`ponytail:`) : l'archive sérialise toute la liste en une fois par jour.
- `.luacheckrc` : environ 491 globaux déclarés en écriture (`globals`) plutôt qu'en lecture, et `Tests/**` exclu.
- Page Packs : textes traduits en enUS et frFR seulement. `OptionsFrame.lua` passe déjà les libellés de `PackLibrary.lua:7-18` par `L[...]`, mais les 9 autres locales de `WeakAurasOptions/Locales/` n'ont aucune clé propre à Musca Auras (« Whole HUD », « Utility Packs », blocs, packs utilitaires).
- `Tests/Harness/Environment.lua:14-26` : chemin en dur vers un dossier utilisateur Windows, en dernier repli de `WOW_UI_SOURCE`.
- `WeakAuras/Animations.lua:354` (`shortcut:`) : seule la région de base du frère est comparée, pas ses clones.
- Reste de Dette 8 : `oldDataStub` et `oldDataStub2` de `WeakAuras.lua` ne pointent pas vers `Private.data_stub` (ancien format de trigger, différents du stub de `Types.lua`). `Types.lua` garde un test `BuildInfo <= 80100`.

### Placement

- Le test Shift/`magnetAlign` est recopié 4 fois (`MoverSizer.lua`).
- Les 8 poignées de redimensionnement sont du copier-coller (`MoverSizer.lua:147-372`, `:1410-1441`).

### Rebranding

- Aucun test ne couvre le rendu de l'interface (titres, couleurs, textures).
- `WeakAurasOptions/Changelog.lua` : écrit par `Tests/PrepareRelease.py` depuis `WeakAuras/CHANGELOG.md` (Outils 3,
  1.20). L'entrée 1.19.0, reformulée à la main, diffère encore de ce que le script écrirait.
- `logo_64.tga` et `logo_256.tga` restent dans la liste des textures, libellés « WeakAuras logo » (reste de Rebranding 8).
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` fait 2059 lignes (2026-11-21).

### Accueil

- `OnShow` de `WEAKAURAS_FOREVER_DISCLAIMER` (`WeakAuras.lua`) marque l'accueil vu avant tout choix. Corrigé par Accueil 2.

## Clos sans développement

- Dette 5, « Durcir les lectures de secrets ouvertes dans le suivi » (clos le 2026-11-21) : les gardes A2, A3, A4, A5, A7 et A8 étaient déjà dans le code à la rédaction du ticket (entrée du 2026-10-13 de `CHANGES.md`). Relu le 2026-11-21 : `Private.ApplyCooldown` (`Icon.lua`), `Private.ReadableOrNil` (`BuffTrigger2.lua`), `C_Timer.After(0, Update)` (`SecretRestrictions.lua`), `pcall(C_Item.IsItemInRange…)` (`GenericTrigger.lua`), `Private.IsSecret` (`AuraEnvironment.lua`, `BuffTriggerNativeFilter.lua`). Restent les tests en jeu de l'étape 12 du suivi, dont la section « Risques » décrit encore l'état d'avant.

## Écartés

### Dette technique

- Couleurs et préfixes de chat en dur (`|cffffd100` 78 fois, préfixe « WeakAuras » à `Init.lua:553`, `GenericTrigger.lua:559`, `WeakAurasOptions.lua:863`) : couverts par Rebranding 7.
- Découper les gros fichiers d'origine (`Prototypes.lua` 9874 lignes, `ConditionOptions.lua`, `AuthorOptions.lua`…) : coût L, et reprendre des correctifs de WeakAuras deviendrait très difficile.
- Assouplir le snapshot du scénario 31 : il fige le contrat des options, c'est voulu.

### Rebranding

- Renommer les identifiants listés plus haut : casserait les imports Wago, les auras installées et les addons tiers.
- Renommer le layout du mode édition `"WeakAuras"` : casserait les layouts déjà sauvegardés par les joueurs.
- Refondre la disposition de la fenêtre d'options : c'est contraire à « ne pas perdre l'utilisateur ».

### Accueil

- Message d'aide au placement après l'import d'un pack : non retenu le 2026-10-27.
- Visite guidée avec surbrillance des boutons de `/wa` : coût L. L'interface AceGUI est reconstruite en permanence, donc la surbrillance serait fragile à maintenir.
- Ouvrir `/wa` automatiquement au premier login : intrusif, et bloqué en combat.
- Installer le HUD automatiquement : impose des auras, contraire au but.
- Ouvrir le mode édition Blizzard par code après l'import : internes Blizzard, risque de taint (voir le contexte de la 1.17).

### API

- Exposer `Private` en global : plus aucun changement interne possible sans casser les addons tiers.
- Import silencieux par un addon : la fenêtre de confirmation protège le joueur contre du code custom installé sans son accord.
- Ouvrir les fonctions d'enregistrement au code custom des auras : bloquées exprès (`WeakAuras/AuraEnvironment.lua:485-497`).
- Moteur embarquable comme librairie dans d'autres addons : un seul global `WeakAuras` et un seul `WeakAurasSaved`.
- Nouveau nom de global pour l'API : même raison que le renommage des identifiants, plus haut.

### Outils

- Traduire les clés propres à Musca Auras dans les 9 autres langues (environ 127 dans `WeakAuras/Locales/`, 329 dans `WeakAurasOptions/Locales/`) : coût L, aucune demande constatée (2026-11-21).

### Demandes populaires

Elles viennent des issues GitHub de WeakAuras2 les plus votées (tri `sort:reactions-+1-desc`, sans le nombre de votes). L'état dans Musca-Auras a été vérifié dans le code, pas testé en jeu.

- Auras inutilisées, seuil réglable et invitation au nettoyage (#4912) : non retenu le 2026-10-27.
- Groupes dans les groupes dynamiques (#3786) : bloqué à trois endroits (`WeakAuras.lua:2757-2761`, `:4751`, `WeakAurasOptions.lua:2355`). Il faudrait réécrire le moteur.
- CLEU vers un trigger custom (#1959) : CLEU est interdit sur Forever.
- Caster's Target multi-unités (#5163) : valeurs secrètes.
- Traduction des auras (#1134) : coût L pour une valeur faible.
- Profils d'aura (#171), loadout de talents (#599) : refusés en amont, rien de nouveau sur Forever.
- Pack utilitaire Swing Timer, marquage des auras modifiées depuis l'import : non retenus le 2026-10-27.
- Alerte « ce sort me cible », suivi des interrupts du groupe, tic de mana en combat, timeline de boss : infaisables sur Forever. Les casts des autres joueurs et le combat log ne sont pas lisibles, le tic de mana ne marche pas en combat, aucune timeline de boss (`WeakAuras/ForeverTutorial.lua:23`, `:42`).

### Demandes populaires déjà présentes, sans ticket

- valeurs par défaut des options custom (#983) ;
- option de type tableau (#4708) ;
- condition de chargement sur la taille du groupe ;
- indication d'aura non chargée (#4262) ;
- mode édition (#5041).

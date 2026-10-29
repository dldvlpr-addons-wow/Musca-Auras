# Tickets par version

Établi le 2026-10-27. La 1.15 reprend le travail fait et non commité, plus six compléments de packs. Les 61 tickets vont de la 1.15 à la 1.22, dans l'ordre de réalisation. Aucun ticket n'est implémenté.

Séries :
- « Packs » : compléments des packs de classe (8) ;
- « Dette » : dette technique et bugs (23) ;
- « Placement » : grille et magnétisme (7) ;
- « Rebranding » : interface de la 1.18 (9) ;
- « Accueil » : accueil du nouveau joueur (4) ;
- « Populaire » : demandes populaires de WeakAuras (10).

Vérification de référence : `lua5.1 Tests/run.lua` depuis la racine, avec `WOW_UI_SOURCE` pointant sur le source Forever. `luacheck` n'est pas installé sur le poste : il ne tourne qu'en CI (`.github/workflows/lint.yml`).

## Règles d'ordre

1. Les bugs passent avant les fonctionnalités.
2. Un ticket qui sécurise un fichier (test, correctif) précède celui qui le modifie en profondeur.
3. Les textes et écrans neufs viennent après la charte de la 1.18, pour ne les écrire qu'une fois.
4. Une version mélange du S visible et au plus un ou deux M. Les L ferment le plan.
5. Chaque version se teste en jeu avant sa sortie (`SUIVI-BUGS-ET-TESTS.md`).

## Sommaire

| Version | Thème | Tickets |
|---|---|---|
| 1.15 | Packs (gros du travail fait, non commité) | Packs 2, 3, 4, 6, 8, 1 |
| 1.16 | Stabilisation | Dette 2, 9, 10 à 23, Packs 5, 7, Dette 6, 8 |
| 1.17 | Placement | Dette 7, Dette 1, Placement 2, 1, 3, 5, 4, 6 |
| 1.18 | Rebranding | Rebranding 1, 2, 3, 5, 6, 7, 9, 8, 4 |
| 1.19 | Accueil et commandes | Accueil 2, 1, 3, 4, Populaire 1, 10 |
| 1.20 | Fiabilité, chargement et import | Dette 3, 5, 4, Populaire 5, 3, 2 |
| 1.21 | Édition d'auras | Populaire 4, 6, 7 |
| 1.22 | Gros chantiers | Populaire 8, Placement 7, Populaire 9 |

## Dépendances

| Avant | Après | Raison |
|---|---|---|
| Dette 1 | Placement 1 à 6 | Même fichier, `MoverSizer.lua` |
| Dette 7 | Placement 4 | Le moteur commun demande un scénario |
| Placement 4 | Placement 7 | L'ancrage s'appuie sur le calage commun |
| Rebranding 1 | Accueil 2, Populaire 10 | Textes et boutons dans la charte |
| Accueil 2 | Accueil 1 | Mêmes boutons |
| Dette 6 | Accueil 3 | Le compteur lit les packs |
| Packs 2 | Packs 3, 5, 7 | Les ID se tranchent dans le même passage du DB2 |
| Dette 4 | Populaire 4, 6, 7, 8 | Nouveaux champs dans les auras |
| Dette 18 | Populaire 6 | Même fichier, `AuthorOptions.lua` |
| Dette 17, Populaire 4 | Populaire 9 | Animations et conditions |

---

## 1.15 : packs

Le gros du travail est fait et non commité. Il reste six compléments de packs, tous S, dans les mêmes fichiers : les faire avant le test en jeu évite un second passage. Packs 2 passe en premier : il valide les ID déjà livrés, et Packs 3 se tranche pendant le même passage dans le DB2.

### Déjà fait

Entrées du 2026-10-25 et du 2026-10-26 de `CHANGES.md`. Banc headless vert (85 scénarios, 0 échec). Rien n'est testé en jeu.

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

### Avant la sortie, après les tickets

1. Régénérer les packs, relancer `lua5.1 Tests/run.lua`.
2. `WeakAurasOptions/Changelog.lua:13-14` : `versionString = '1.15.0'`, `dateString` du jour. Réécrire `highlightText` et `commitText`, qui décrivent encore la 1.14.
3. `DESCRIPTION.md:31` : ajouter un bloc 1.15 à « New in ».
4. `CHANGES.md` : ajouter une entrée pour les tickets Packs ci-dessous.
5. `SUIVI-BUGS-ET-TESTS.md` : ajouter les tests de la 1.15, puis les passer en jeu :
   - les 4 fonctions de code custom ;
   - la page Packs : HUD complet et bloc par bloc ;
   - les 24 packs utilitaires ;
   - une aura 1.14.0 avec voix enregistrée : le son disparaît ;
   - Threat Situation et format de nombre en précision 0 avec valeurs secrètes ;
   - les packs de classe : sons de proc, « Fading », Enemy Cast, swing timer distance, Defensives, PW:S, Infusion of Light, Arcane Blast, et les ajouts des tickets Packs ;
   - la notice des packs de classe, réaffichée une seule fois.
6. Après le test, écrire « Released as 1.15.0. Tested in game… » dans `CHANGES.md`, comme pour les versions précédentes.

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

Première version après les packs de la 1.15. Corriger les bugs connus avant d'ajouter des fonctionnalités évite de les mêler aux régressions de ce contenu. Packs 5 et 7 demandent une vérification en jeu ou des ID à trancher : ils passent ici, avant Dette 6 (régénération et synchronisation des packs).

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
- Tests de build toujours vrais sur Forever (Interface 16001, build 1.60.1) : `WoW80` dans `WeakAurasOptions/AceGUI-Widgets/AceGUIContainer-WeakAurasTreeGroup.lua:12`, `WeakAuras.BuildInfo > 80100` dans `WeakAurasOptions/RegionOptions/Model.lua:18` et `:41`.
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

Dette 7 passe d'abord : les tickets de placement ajoutent des scénarios. Dette 1 corrige `MoverSizer.lua` avant qu'on le retravaille. Placement 7 passe en 1.22 : il modifie les données d'ancrage sauvegardées et dépend du moteur commun (Placement 4).

### Contexte du placement

Deux outils placent aujourd'hui les auras, sans logique commune :

- `WeakAuras/EditModePlacement.lua` : mode édition Blizzard. Il place les auras de premier niveau ancrées à l'écran et les cale sur la grille Blizzard, seulement au lâcher.
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua` : déplacement dans `/wa`. Il cale sur les bords des autres auras et sur le centre de l'écran, sans grille régulière.

Contraintes API (source Forever 1.60.1.70532) :

- Aucune API publique ne permet d'inscrire une frame d'addon dans le mode édition.
- `EditModeMagnetismManager`, `EditModeGridMixin` et `ProcessMovementKey` sont des internes Blizzard. Les appeler ou les hooker expose au taint : recopier leur logique.
- Lectures sans risque : `EditModeManagerFrame:IsEditModeActive()`, callbacks `EditMode.Enter` et `EditMode.Exit`, `EditModeManagerFrame.Grid:IsShown()`, `EditModeManagerFrame.Grid.gridSpacing` (défaut 100, de 20 à 300).

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

## 1.18 : rebranding

Rien d'autre dans cette version : le rendu ne se vérifie qu'en jeu.

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

### Ordre

1. Rebranding 1 : Charte `DESIGN.md`
2. Rebranding 2 : Nom affiché partout
3. Rebranding 3 : Fiche publique
4. Rebranding 5 : Nouveaux points d'entrée
5. Rebranding 6 : Fenêtre Guide alignée sur la fenêtre d'options
6. Rebranding 7 : Module de thème central
7. Rebranding 9 : Bascule « apparence classique »
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

## 1.19 : accueil et commandes

L'accueil et les nouvelles commandes ajoutent des textes et des boutons : les écrire après le changement de nom et de charte de la 1.18 évite de les refaire. Accueil 3 lit les packs régénérés par Dette 6 (1.16).

### Parcours actuel au premier login

Parcours actuel au premier login (lu dans le code, non testé en jeu) :

- Aucune aura n'est installée d'office. `ADDON_LOADED` crée `WeakAurasSaved` avec `displays = {}` (`WeakAuras/WeakAuras.lua:1484-1521`).
- `PLAYER_LOGIN` affiche la popup `WEAKAURAS_FOREVER_DISCLAIMER` si `not db.foreverDisclaimerSeen` (`WeakAuras.lua:1540`). Contenu : les limites de Forever, et trois boutons : `OKAY`, `Guide`, `Install <Classe> HUD` (`l.2597-2623`).
- Le HUD complet passe par `WeakAuras.ImportClassPack()` (`l.180-204`), qui se met en file en combat et refuse pendant le login.
- Le choix bloc par bloc et les 24 packs utilitaires ne sont accessibles que par `/wa` > Packs (`OptionsFrame.lua:1432-1507`, `WeakAurasOptions/PackLibrary.lua`).
- Aucun écran pour une liste d'auras vide, aucun compteur d'auras par pack, aucun flag par personnage.

### Ordre

1. Accueil 2 : Accueil court, séparé de l'avertissement Forever
2. Accueil 1 : Proposer le HUD au premier login de chaque classe
3. Accueil 3 : Nombre d'auras par pack et par bloc dans la page Packs
4. Accueil 4 : Écran pour une liste d'auras vide dans `/wa`
5. Populaire 1 : Commande `/wa toggle`
6. Populaire 10 : Mute global des sons

---

### Accueil 2 : Accueil court, séparé de l'avertissement Forever

**Pourquoi.**
- L'action utile, installer le HUD, est le 3e bouton (`button3`, `WeakAuras.lua:1541`), sous une liste de limites techniques (`l.2598-2608`).
- Le HUD s'installe en entier : la popup ne mentionne pas le choix par bloc de la page Packs.
- `OnShow` coche `foreverDisclaimerSeen` et `classPackNoticeSeen` (`l.2619-2622`). Fermer par Échap sans rien choisir compte comme vu, sans retour possible.

**Valeur.** Au premier login, le joueur choisit clairement le volume d'auras qu'il veut : tout, une sélection, ou rien pour l'instant.

**À faire.**
- Remplacer le texte par un accueil court : une phrase sur l'addon, une sur le HUD de classe.
- Trois boutons :
  - « Installer le HUD complet » : `WeakAuras.ImportClassPack()` ;
  - « Choisir les blocs » : charger les options (`Private.LoadOptions`), ouvrir `/wa`, puis `frame:OpenPacks()` ;
  - « Plus tard ».
- Déplacer la liste des limites dans le Guide, qui a déjà « What changes on Forever » (`TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`). Ajouter un lien Guide dans l'accueil.
- Cocher le flag au clic d'un bouton, plus à `OnShow`.
- Ajouter `/wa welcome` pour réafficher l'accueil, et le citer dans `Private.PrintHelp` (`l.206-224`).

**Coût.** S.

**Risque.**
- Les options se chargent à la demande. « Choisir les blocs » doit passer par `LoadOptions`, qui attend déjà la fin du login et du combat (`l.148-168`).
- Mettre à jour `DESCRIPTION.md` (« Quick start », étape 2) et les locales.

**Fichiers.**
- `WeakAuras/WeakAuras.lua`
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`
- `WeakAuras/ForeverTutorial.lua`, `TUTORIAL.md`
- `DESCRIPTION.md`
- Locales

---

### Accueil 1 : Proposer le HUD au premier login de chaque classe

**Pourquoi.** `foreverDisclaimerSeen` est stocké dans `WeakAurasSaved`, au niveau du compte (`WeakAuras.lua:1540`, `:2620`). Seul le premier personnage reçoit la proposition. Un personnage d'une autre classe ne se voit jamais proposer son HUD : il doit trouver `/wa` > Packs seul.

**Valeur.** Chaque nouveau personnage se voit proposer le HUD de sa classe au premier login.

**À faire.**
- Ajouter une table `classPackOffered` dans `WeakAurasSaved`, indexée par le jeton de classe (`select(2, UnitClass("player"))`).
- Au `PLAYER_LOGIN`, quand l'accueil a déjà été vu sur le compte : si `not HasClassPack()` (`l.392-402`) et que la classe n'est pas dans `classPackOffered`, afficher une popup courte « Installer le HUD <Classe> », puis marquer la classe.
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

**Pourquoi.** Sans aucune aura, la liste de `/wa` est vide, sans texte. Aucune occurrence d'état vide dans `WeakAurasOptions.lua`. Les packs ne sont accessibles que par le bouton « Packs » de la barre d'outils, et sont absents du panneau « New » (`frame.NewAura`, `OptionsFrame.lua:1509+`).

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

## 1.20 : fiabilité, chargement et import

Dette 4 (tests de migration) précède les tickets qui ajoutent des champs aux auras, en 1.21 et 1.22.

### Ordre

1. Dette 3 : Un seul jeu de helpers pour les secrets
2. Dette 5 : Durcir les lectures de secrets ouvertes dans le suivi
3. Dette 4 : Tester la migration et la restauration des données
4. Populaire 5 : Safe mode `/wa safemode`
5. Populaire 3 : Alerte des médias manquants à l'import
6. Populaire 2 : Condition de chargement « AddOn chargé »

---

### Dette 3 : Un seul jeu de helpers pour les secrets

**Pourquoi.** `Private.IsSecret` existe (`WeakAuras/SecretRestrictions.lua:8`) et cinq fichiers l'utilisent. Pourtant, plusieurs fichiers du fork redéfinissent leurs propres helpers :
- `IsSecret` : `SecretAuraAppearance.lua:42`, `SecretAuraSingle.lua:41` (et `Shared.IsSecret` dans `SecretAuraSingleLearning.lua:11`) ;
- `Round` : `SecretAuraAppearance.lua:58`, `SecretAuraSingle.lua:45` ;
- `IsTable` : `SecretAuraConditions.lua:31`, `SecretAuraSingle.lua:40` ;
- `FirstProblem` : `SecretAuraConditions.lua:44`, `SecretAuraSingle.lua:75` ;
- `SameValue` : `CooldownViewerStates.lua:461`, `SecretAuraConditions.lua:1087` ;
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

### Dette 5 : Durcir les lectures de secrets ouvertes dans le suivi

**Pourquoi.** L'audit `wow-api` du 2026-10-08 (`SUIVI-BUGS-ET-TESTS.md`, section 2) liste des appels sans `pcall` ni garde de secret, toujours ouverts :
- A2 : `WeakAuras/RegionTypes/Icon.lua:454,686,715`, `SetCooldown*` sans `pcall` ;
- A3 : rôle et portée lus sans garde (`BuffTrigger2.lua:189,1463,1588`, `GenericTrigger.lua:4080,4090`, `WeakAuras.lua:1753`) ;
- A4 : `SecretRestrictions.lua:87-100`, pas de relecture différée après `PLAYER_REGEN_ENABLED` ;
- A5 : `GenericTrigger.lua:5212`, `IsItemInRange` sans `pcall` ;
- A7 : `AuraEnvironment.lua:28-39`, `WA_GetUnitAura` sans test de secret ;
- A8 : `BuffTriggerNativeFilter.lua:32-34`, comparaison hors `pcall`.

**Valeur.** Moins d'erreurs Lua en instance et en combat, là où les valeurs deviennent secrètes.

**À faire.**
- Faire revérifier par `wow-api` chaque API concernée (champs secrets, `HasRestrictions`) avant de toucher au code.
- Poser la garde au plus près de l'appel, avec `Private.IsSecret` (voir Dette 3).
- Ajouter un scénario par garde quand le banc peut le prouver.
- Cocher les étapes correspondantes de la section 3 du suivi après le test en jeu.

**Coût.** M.

**Risque.** Une garde qui masque une valeur légitime : l'aura ne s'affiche plus. Le banc ne prouve pas une garde qui ne protège qu'une comparaison (Lua 5.1 n'appelle pas `__eq` entre types différents) : test en jeu obligatoire.

**Fichiers.**
- `WeakAuras/RegionTypes/Icon.lua`, `BuffTrigger2.lua`, `GenericTrigger.lua`, `WeakAuras.lua`
- `WeakAuras/SecretRestrictions.lua`, `AuraEnvironment.lua`, `BuffTriggerNativeFilter.lua`
- `SUIVI-BUGS-ET-TESTS.md`

---

### Dette 4 : Tester la migration et la restauration des données

**Pourquoi.** Plusieurs chemins qui touchent aux données sauvegardées n'ont aucun scénario :
- `WeakAuras/BlizzardAuraDisplayMigration.lua` : `RenameVoiceSound`, `DropLegacySoundFields` (renommage des sons de la 1.14.0). Piège connu : la clé `sound_<ancien>` n'est nettoyée que si le kind est encore l'ancien et si l'aura a un trigger `secretAura`. Sinon elle reste dans les SavedVariables et dans les exports.
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

**Pourquoi.** Demande #5477. La fenêtre d'import n'affiche que `scamCheckText` (`WeakAuras/Update.lua:1702`). Une aura qui utilise la texture, la police ou le son d'un addon absent s'importe sans prévenir, puis s'affiche avec le média par défaut. `LSM:IsValid(mediatype, key)` existe dans la lib embarquée (`WeakAuras/Libs/LibSharedMedia-3.0/LibSharedMedia-3.0.lua:289`).

**Valeur.** Le joueur sait avant d'importer qu'il lui manque un addon de médias.

**À faire.**
- Parcourir les données importées (auras et sous-régions) et relever les champs de média : texture, police, son.
- Pour chaque nom LSM, tester `LSM:IsValid`. Ignorer les chemins de fichier et les ID numériques.
- Afficher la liste des médias manquants sous le texte de vérification d'import.

**Coût.** S à M.

**Risque.** Faible : affichage seulement. Le relevé doit couvrir tous les champs de média, sans signaler à tort un chemin direct.

**Fichiers.**
- `WeakAuras/Update.lua`
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

## 1.21 : édition d'auras

### Ordre

1. Populaire 4 : Nom de trigger éditable
2. Populaire 6 : Options custom conditionnelles
3. Populaire 7 : Taille imposée aux enfants d'un groupe dynamique

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

## 1.22 : gros chantiers

Tickets L ou M à L. Chacun peut sortir seul, en 1.22, 1.23 et 1.24, si la version devient trop lourde. Populaire 9 touche aux conditions comme Populaire 4 : il passe après.

### Ordre

1. Populaire 8 : Templates personnalisés
2. Placement 7 : Ancrer une aura à une autre en la calant dessus
3. Populaire 9 : Animations conditionnelles

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

### Placement 7 : Ancrer une aura à une autre en la calant dessus

**Pourquoi.** Le calage aligne une aura sur une autre sans créer de lien entre elles. Pour qu'une aura suive une autre, il faut aujourd'hui régler l'ancrage dans les options (`anchorFrameType`, `CommonOptions.lua:1346`).

**Valeur.** Des auras collées qui bougent ensemble, comme `SnapToFrame` sur les cadres Blizzard.

**À faire.**
- Au lâcher sur un bord d'aura, avec un modificateur à choisir, écrire l'ancrage relatif : `anchorFrameType`, `anchorFrameFrame`, `selfPoint`, `anchorPoint`, offsets.
- Refuser un ancrage qui créerait une boucle (A ancrée à B, B ancrée à A).

**Coût.** L.

**Risque.** Modifie les données d'ancrage sauvegardées. Ancrages en boucle. Aura qui disparaît quand l'aura cible n'est pas chargée.

**Fichiers.**
- `WeakAurasOptions/OptionsFrames/MoverSizer.lua`
- `WeakAuras/EditModePlacement.lua`
- `WeakAurasOptions/CommonOptions.lua`

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

## Dette notée, sans ticket

### Dette technique

- `GenericTrigger.lua:3744` et `:3969` : même TODO sur le retour de `GetItemCooldown` (`1/0` ou `true/false`), bloc recopié deux fois. Vérifier d'abord l'API Forever avec `wow-api`.
- `GenericTrigger.lua:3413` (`shortcut:`) : les charges sont ignorées, un sort qui a encore des charges est lu comme non prêt.
- `AuraBackups.lua:42` (`ponytail:`) : l'archive sérialise toute la liste en une fois par jour.
- `.luacheckrc` : environ 491 globaux déclarés en écriture (`globals`) plutôt qu'en lecture, et `Tests/**` exclu.
- `WeakAurasOptions/PackLibrary.lua:7-18` : libellés en anglais hors `L[...]`.

### Placement

- `MoverSizer.lua:1123` : `parentData == "dynamicgroup"` compare une table à une chaîne, donc la condition est toujours fausse. La branche prévue pour un enfant de groupe dynamique qu'on redimensionne ne s'exécute jamais. Correctif : `parentData.regionType == "dynamicgroup"`.
- Le test Shift/`magnetAlign` est recopié 4 fois (`MoverSizer.lua:835`, `:916`, `:1266`, `:1368`).
- Les 8 poignées de redimensionnement sont du copier-coller (`MoverSizer.lua:147-372`, `:1410-1441`).

### Rebranding

- Aucun test ne couvre le rendu de l'interface (titres, couleurs, textures).
- `WeakAurasOptions/Changelog.lua` recopie à la main le texte de `CHANGES.md`.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` fait 1814 lignes.

### Accueil

- `WeakAuras.lua:2619-2622` : `OnShow` marque l'accueil vu avant tout choix. Corrigé par Accueil 2.

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

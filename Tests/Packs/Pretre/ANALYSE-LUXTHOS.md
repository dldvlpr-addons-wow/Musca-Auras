# Analyse du pack « Luxthos - Priest (Classic Era) »

Source : `wago.io/LuxthosPriestClassicEra` (version 5, semver 1.15.4, tocversion 11505), chaîne décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca.

Le moteur commun, les groupes et les options sont décrits dans `ANALYSE-AURAS-LUXTHOS.md` (chaman). Ce fichier ne relève que les écarts et le contenu propre au Prêtre.

## 0. Chiffres

- 40 entrées sous la racine (chaman : 34) : 7 groupes enfants et 33 feuilles (chaman : 27).
- Groupes : Dynamic Effects (3), Core (17), Left Side (0), Right Side (0), Utilities (2), Maintenance (5), Resources (3, statique).
- Feuilles : 2 icônes « moteur » invisibles (Class Options, General Options), 1 barre Mana Tick, 27 icônes (3 effets, 17 Core, 2 utilitaires, 5 maintenance), 3 barres (vie, mana, incantation).
- Par déclencheur : 16 icônes avec un `Cooldown Progress (Spell)` (dont une avec un déclencheur personnalisé de totem), 11 icônes en `aura2` seul (3 effets, Pain, Starshards, Shadowguard, 5 maintenance), 3 barres natives (`Health`, `Power`, `Cast`).
- Aucune animation, aucun son, aucun message, aucune texture de proc, aucun swing timer, aucun pop-up.

## 1. Gabarit : identique au chaman

Oui. Même moteur « LWA » : `config` et `authorOptions` de General Options, Class Options, Mana Tick, Health Bar, Mana Bar et Cast Bar sont strictement égaux à ceux du chaman ; mêmes sept groupes, mêmes ancrages, mêmes tailles et marges (Core 48x40, débordement 44x36, rangées annexes 38x32, barres 20 de haut), même croissance personnalisée, même ordre de contrôle. Le code du moteur, du Mana Tick et de la barre d'incantation est le même au caractère près.

Écarts :

- Version du pack : 5 / 1.15.4 (chaman : 3 / 1.15.2).
- Pas de totem, pas d'imbue, pas de rangée de 4 totems : le Core compte 17 icônes (plafond d'affichage 8, puis débordement) au lieu de 10.
- Pas de `Weapon Enchant` ni d'événement `Totem` (sauf une icône personnalisée, Lightwell, §2.2).
- Maintenance : 5 icônes (chaman : 2), chacune avec sa propre option de comportement (§3).
- Barre d'incantation : même trois déclencheurs que le chaman, y compris celui qui coupe la barre Blizzard.
- Class Options : une seule rubrique, la barre de mana, valeurs identiques.
- Restes du gabarit : la barre de mana est chargée pour `WARLOCK` en multi et la spécialisation 264 ; Mana Tick a `spellknown` 768 (forme de félin) désactivé ; Shadowguard porte l'option de comportement de Lightning Shield ; les filtres `spec` / `role` / `class_and_spec` sont sans effet en Classic Era. Beaucoup de noms de sort de déclencheurs CD sont périmés (Fear Ward, Chakra) : le déclencheur lit l'ID dans `spellName`.

## 2. Auras par rangée

Convention : « CD » = `Cooldown Progress (Spell)` en `showAlways`. Style commun du chaman (zoom 0,3, bordure 1 px, grisé en recharge, lueur pixel quand l'effet est actif). Conditions CD identiques à celles du chaman pour la lueur « prêt » : elles ne l'allument jamais.

### 2.1 Dynamic Effects (3, chargement par index de talent)

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Spirit Tap | `aura2` buff joueur 15271, siens | talent index 85, spé 1 / rôle dégâts (restes) | lueur pixel |
| Focused Casting (Priest) | `aura2` buff joueur 14743 | talent index 85 | lueur pixel |
| Shadow Weaving | `aura2` débuff cible 15258, siens | talent index 81 | aucune condition : présent ou absent |

Ce sont les seules auras chargées par index de talent (`use_talent`), les autres utilisent `spellknown`.

### 2.2 Core (17, dans l'ordre du groupe)

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Shadow Word: Pain | `aura2` débuff cible 589, siens | `spellknown` 589 | absent : désaturé alpha 0,5 ; lueur coupée hors combat |
| Starshards | `aura2` débuff cible 10797, siens | `spellknown` 10797 | idem Pain |
| Mind Blast | CD 8092 avec GCD + `aura2` buff joueur 33371 | `spellknown` 8092 | grisé en recharge ; rouge + grisé hors de portée ; lueur « bouton » quand l'aura 33371 est à 2 piles |
| Power Word: Shield | `aura2` buff joueur 17 (siens), `aura2` débuff joueur 6788 (non exploité), CD 17 avec GCD | `spellknown` 17, classe | buff actif : lueur pixel, désaturation et inversion coupées, bord de balayage ; en recharge et sort inutilisable : texte d'absorption (tooltip 3) |
| Vampiric Embrace | `aura2` débuff cible 15286 (siens) + CD 15286 | `spellknown` 15286 | débuff présent : lueur pixel, bord de balayage ; en recharge : grisé |
| Fade | `aura2` buff joueur 586 + CD 586 | `spellknown` 586 | buff actif : lueur pixel ; en recharge : grisé |
| Devouring Plague | `aura2` débuff cible 2944 (siens) + CD 2944 | `spellknown` 2944 | débuff présent : lueur pixel ; en recharge : grisé |
| Touch of Weakness | `aura2` buff joueur 19266 + CD du même ID | `spellknown` 2944 (erreur de copie) | en recharge : grisé ; sans autre condition |
| Hex of Weakness | `aura2` buff joueur 9035 + CD | `spellknown` 9035 | idem ; l'unité lue est le joueur alors que l'effet est un débuff de cible |
| Shadowguard | `aura2` buff joueur 18137 (déclencheur de type « Item Count » résiduel) | `spellknown` 18137 | absent : alpha 0,51 grisé |
| Feedback | `aura2` buff joueur 13896 + CD 13896 | `spellknown` 13896 | grisé en recharge |
| Desperate Prayer | CD 19236 (rang élevé) | `spellknown` 19236 | grisé en recharge |
| Fear Ward | `aura2` buff groupe 6346 + CD 6346 | `spellknown` 6346 | buff présent sur un allié : lueur pixel ; en recharge : grisé |
| Elune's Grace | `aura2` buff joueur 2651 + CD 2651 | `spellknown` 2651 | grisé en recharge |
| Inner Focus | `aura2` buff groupe 14751 + CD 14751 sans GCD | `spellknown` 14751 | buff actif : lueur pixel ; en recharge : grisé |
| Power Infusion | `aura2` buff groupe 10060 + CD 10060 sans GCD | `spellknown` 10060 | idem |
| Lightwell | déclencheur personnalisé sur `PLAYER_TOTEM_UPDATE` (lit l'emplacement de totem et compare l'icône) + CD 724 avec GCD | `spellknown` 724 | puits posé : lueur pixel et durée en balayage ; en recharge : grisé |

Pas de teinte rouge ou bleue sauf Mind Blast (portée). Le chargement est partout `spellknown` sur le rang 1 sauf les trois effets de §2.1.

### 2.3 Utilities (2)

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Silence | `aura2` débuff cible 15487 ; CD `showAlways` ; CD `showOnCooldown` (logique personnalisée qui choisit selon l'option) | `spellknown` 15487 | grisé en recharge ; lueur pixel tant que le débuff est sur la cible |
| Psychic Scream | idem avec 8122 | `spellknown` 8122 | idem |

### 2.4 Maintenance (5)

Tous : 5 déclencheurs `aura2` buff joueur par nom (liste d'IDs), plus l'état « zone de repos » et un événement d'options ; trois comportements (présent / absent / toujours, défaut absent), masqué en zone de repos ; absent : alpha 0,5 grisé.

| Aura | IDs lus | Seuil de durée | Chargement |
|---|---|---|---|
| Shadowform | 15473 | aucun | `spellknown` 15473 |
| Power Word: Fortitude | 1243, 21562 | 300 s | `spellknown` 1243 |
| Shadow Protection | 976, 27683 | 120 s | `spellknown` 976 |
| Divine Spirit | 14752, 27681 | 300 s | `spellknown` 14752 |
| Inner Fire | 588 | 300 s, et charges <= 3 avec le même seuil de durée | `spellknown` 588 ; texte `%s` des charges au-dessus de l'icône |

### 2.5 Resources

Health Bar (désactivée par défaut), Mana Bar (dégradé bleu, texte de format choisi), Cast Bar (nom à gauche, temps à droite, couleurs par état) : identiques au chaman. Mana Tick : voir §5.

## 3. Options d'auteur propres à la classe

- Class Options : uniquement les réglages de la barre de mana (hauteur, format du texte, police, taille, deux couleurs, dégradé), comme le chaman.
- Par aura : un sélecteur « comportement » pour chacune des cinq icônes de Maintenance (Shadowform, Fortitude, Shadow Protection, Divine Spirit, Inner Fire), défaut « si absent » ; un sélecteur « sur recharge / toujours » pour Silence et Psychic Scream, défaut « sur recharge ».
- Aucune option propre au Prêtre dans General Options.

## 4. Code personnalisé propre à la classe (idées seulement)

- Lightwell : suit le puits comme un totem. À chaque mise à jour des emplacements de totem, il lit l'emplacement et compare l'icône à celle du puits pour savoir si un puits est posé et pour afficher son temps restant.
- Rappels de Maintenance : une fonction de logique par aura choisit entre présent, absent ou toujours, masque en zone de repos, et regroupe « absent », « durée sous le seuil » et (Inner Fire) « charges faibles ».
- Utilities : la même logique choisit entre « toujours » et « sur recharge ».
- Tout le reste (moteur de disposition, Mana Tick, barres) est le code commun du chaman.

## 5. Bloqué sur Forever

- Journal de combat : aucun usage.
- Valeur secrète comparée en Lua : tic de mana du curseur Mana Tick (compare la mana avant et après un lancement) ; formatage du texte des barres de vie et de mana ; couleur du texte de mana par seuil.
- `aura2` en combat : toutes les icônes d'effets, de Core et de Maintenance du pack (buffs, débuffs, groupe et cible) lisent leurs auras par `aura2` ; dans Musca, tout passe par `secretAura`. Les piles d'une aura (Mind Blast sur 33371, Inner Fire sur les charges) sont lues par `aura2` : comparaison de piles non transposable en combat, le texte natif des charges l'est.
- À vérifier : `PLAYER_TOTEM_UPDATE` / emplacements de totem pour Lightwell sur le moteur 12.x ; absorption affichée par le tooltip du Shield (valeur secrète).

## 6. Écarts avec le pack Musca actuel

Le plan v2 (`PLAN-V2.md`) couvre déjà la majorité du contenu. Idées du pack reprises ou à ajouter : Shadow Protection en Entretien (absent du plan), lueur pendant l'effet sur Fade, Fear Ward, Silence et Psychic Scream (double état recharge puis effet), durée du puits de Lightwell, chargement par sort connu partout (le chargement par index de talent du pack n'est pas transposable). IDs lus dans le pack et absents de `Classes/Priest.md` : 14743 (Focused Casting), 33371 (aura de Mind Blast).

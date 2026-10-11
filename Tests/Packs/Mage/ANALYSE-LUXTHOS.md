# Analyse du pack « Luxthos - Mage (Classic Era) »

Source : `wago.io/LuxthosMageClassicEra` (version 2, semver 1.15.1, tocversion 11506), décodé avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca.

Modèle commun : `ANALYSE-AURAS-LUXTHOS.md` (chaman). Ce fichier ne relève que les écarts et le contenu propre au mage.

## 0. Chiffres

- 37 entrées : la racine, 7 groupes enfants (6 dynamiques, 1 statique « Resources ») et 29 feuilles.
- Feuilles : 25 icônes et 4 barres.
  - Icônes : 2 icônes moteur invisibles (Class Options, General Options), 4 effets, 11 Core, 5 utilitaires, 3 maintenance.
  - Barres : Mana Tick, vie (désactivée par défaut), mana, incantation.
- Aucune animation, aucun son, aucun message, aucune texture de proc, aucun swing timer, aucun pop-up, aucune lecture du journal de combat.
- Déclencheurs : recharge = `Cooldown Progress (Spell)` ; buffs et débuffs = `aura2` par nom ; gemmes = `Item Count` ; puissance = unité `Power` ; incantation = unité `Cast` ; le reste en déclencheurs personnalisés.

## 1. Gabarit : identique au chaman

Oui, c'est le même gabarit « LWA » : même moteur General Options (4 déclencheurs, ~1070 lignes contre ~1000), mêmes options d'auteur et mêmes valeurs par défaut (Core 48x40, débordement 44x36, 5 à 8 icônes, autres rangées 38x32, zoom 30, bordure 1/1, ressources sous le Core), mêmes groupes (Dynamic Effects, Core, Left Side vide, Right Side vide, Utilities, Maintenance, Resources), même ancrage sur le cadre General Options, même racine (centre écran, y -170), mêmes restes de gabarit (filtres `spec` et `class_and_spec` sans effet, `spellknown` 768 mort sur Mana Tick, `spellknown` 18265 mort sur les effets).

Écarts avec le chaman :

- Class Options : mêmes champs que le chaman (barre de mana seule, mêmes couleurs bleues). Aucune option propre au mage.
- Pas de totems, d'imbue ni de charges de bouclier : aucun texte maison de charges.
- Core : 11 icônes toutes de recharge, aucun sort de rotation (ni Fireball, Frostbolt, Scorch...). Avec plus de 8 sorts connus, le débordement sert toujours.
- Utilitaires : option d'affichage (sur recharge ou toujours) sur chacun des 5, dont une icône de gemmes de mana (déclencheur `Item Count`, absent chez le chaman).
- Maintenance : 3 icônes au lieu de 2, avec une option de comportement par icône (présent, absent, toujours) au lieu d'une option commune ; seuil unique de 5 minutes (pas de seuil à 30 s) ; défaut « absent » pour Intelligence et armures, « présent » pour Amplify/Dampen. Les 3 icônes sont masquées en zone de repos.
- Effets : chargement par classe seule (le sort connu est écrit mais désactivé). Un seul filtre de talent actif : Ignite.
- Mana Tick : même code que le chaman (voir section 5).
- Version 2 du pack (le chaman : version 3).

## 2. Auras par rangée

Convention : « CD » = `Cooldown Progress (Spell)`. Toutes les icônes ont zoom 0,3, balayage de recharge, bordure carrée noire 1 px, lueur de type pixel allumée par une condition d'effet actif. Les lueurs « prêt » sont des conditions mortes (comme le chaman). Rouge hors de portée et bleu-violet sans ressource : seulement sur Fire Blast (portée et ressource) et Counterspell (portée).

### 2.1 Effets dynamiques (4, au-dessus du Core)

| Aura | Déclencheur | Chargement | Visuel |
|---|---|---|---|
| Winter's Chill | `aura2` débuff cible, posé par le joueur, recherché par le nom du talent 11180 | classe | lueur pixel actif ; texte de cumuls (`%s`) |
| Ignite | `aura2` débuff cible, posé par le joueur, recherché par le nom du talent 11119 | classe + filtre de talent actif (index 52) | lueur pixel actif |
| Fire Vulnerability | `aura2` débuff cible (tous lanceurs), 22959 | classe | lueur pixel actif ; texte de cumuls |
| Clearcasting | `aura2` buff joueur, 12536 | classe | lueur pixel actif |

Ni Arcane Blast, ni Missile Barrage, ni Fingers of Frost, ni Heating Up, ni Hot Streak dans le pack.

### 2.2 Core (11)

Tous chargés par `spellknown`, rang 1.

| Aura | Déclencheur | ID | Conditions visuelles |
|---|---|---|---|
| Fire Blast | CD | 2136 | grisé en recharge ; rouge hors portée ; bleu-violet sans mana |
| Cone of Cold | CD | 120 | grisé en recharge |
| Frost Nova | CD + `aura2` débuff cible (siens) | 122 | grisé en recharge ; si la racine est posée : lueur pixel, dégrisé, bord de balayage |
| Ice Barrier | CD + `aura2` buff joueur (siens) | 11426 | grisé en recharge ; bouclier actif : lueur pixel, bord de balayage |
| Counterspell | CD + `aura2` débuff cible (tous lanceurs) | 2139 | grisé en recharge ; rouge hors portée ; verrou posé : lueur pixel, dégrisé |
| Blink | CD | 1953 | grisé en recharge |
| Blast Wave | CD | 11113 | grisé en recharge |
| Combustion | CD + `aura2` buff joueur + `aura2` débuff cible | 11129 | grisé en recharge ; actif : lueur pixel ; grisé aussi si la cible n'a pas un des 2 débuffs de DoT cherchés (413841, 44457, absents de `Classes/Mage.md`) ; texte de cumuls |
| Presence of Mind | CD + `aura2` buff joueur (siens) | 12043 | grisé en recharge ; actif : lueur pixel, bord de balayage |
| Arcane Power | CD + `aura2` buff joueur (siens) | 12042 | idem |
| Evocation | CD + `aura2` buff joueur (canal) | 12051 | idem |

Les icônes à deux états (recharge, puis durée de l'effet avec lueur) sont la règle du Core : Frost Nova, Ice Barrier, Counterspell, Combustion, Presence of Mind, Arcane Power, Evocation.

### 2.3 Utilitaires (5)

Tous : option d'affichage (sur recharge, défaut ; ou toujours). Grisé en recharge. Chargés par `spellknown`.

| Aura | Déclencheur | ID | Remarque |
|---|---|---|---|
| Mana Shield | CD x2 + `aura2` buff joueur | 1463 | lueur pixel bouclier posé |
| Fire Ward (« Mage Ward ») | CD x2 + `aura2` buff joueur (siens) | 543 | lueur pixel actif ; pas de Frost Ward |
| Ice Block | CD x2 | 11958 | recharge seule, pas d'aura |
| Cold Snap | CD x2 | 12472 | recharge seule |
| Gemmes de mana | `Item Count` sur 4 objets (5514, 5513, 8007, 8008) + état « conditions » | `spellknown` 759 (Conjure Mana Agate) | option : afficher si recharge ou absent, ou toujours ; grisé et teinté s'il n'y a aucune gemme ; deux textes de compte (`%2.s`, `%3.s`) au-dessus de l'icône |

### 2.4 Maintenance (3)

Logique commune : masqué en zone de repos ; comportement choisi par option (présent, absent, toujours). Reste <= 300 s sur le 2e déclencheur. Absent : grisé et teinté.

| Aura | Noms cherchés (`aura2` joueur) | Chargement |
|---|---|---|
| Arcane Intellect | 1459, 23028 (Intellect et Brilliance) | `spellknown` 1459 |
| Amplify & Dampen Magic | 1008, 604 | `spellknown` 10174 (Dampen Magic rang 5) |
| Armures | 168 (Frost), 6117 (Mage), 7302 (Ice) : une icône pour les 3 familles | `spellknown` 7301 |

### 2.5 Ressources

| Aura | Détail |
|---|---|
| Mana | barre bleue ; texte multi-format par Lua ; texte orange à 30 % ou moins, rose à 15 % ou moins ; 20 de haut |
| Vie | barre verte ; désactivée par défaut (`use_never`) |
| Incantation | unité `Cast` joueur ; couleurs normale, non interruptible (gris), canalisée ; étincelle ; nom du sort et temps ; un 3e déclencheur retire les événements de la barre d'incantation Blizzard au chargement |
| Mana Tick | curseur de tic de mana sur la barre de mana ; options : tolérance (0,08), décalage de tic (0,01) |

## 3. Options d'auteur propres à la classe (Class Options)

Une seule : barre de mana (hauteur 20, format de texte 1 à 5, police et taille 14, couleurs 1 et 2, sens du dégradé). Identique au chaman. Options par aura propres au mage : comportement d'affichage des 5 utilitaires (surtout gemmes), comportement des 3 icônes de maintenance, tolérance et décalage du Mana Tick.

## 4. Code personnalisé propre à la classe (idées)

- Retrait de la barre d'incantation native : le pack coupe les événements du cadre de lancement natif quand la barre maison charge. À vérifier sur le moteur 12.x (nom du cadre, taint).
- Rappels de maintenance : une logique booléenne sur les déclencheurs (repos, présent, absent). Pur booléen, sans valeur secrète.
- Mana Tick : détecte un sort qui coûte de la mana en comparant la mana avant et après, puis estime le prochain tic (cycle de 2 s, pause de 5 s). Aucun code propre au mage, identique au chaman.
- Aucun code lié à un sort du mage (pas de pile d'Arcane Blast, pas de suivi d'Ignite par Lua).

## 5. Bloqué sur Forever

- Lecture d'aura par `aura2` en combat : les 4 effets, les parties « buff actif » des icônes à deux états, Fire Ward, Mana Shield, Intelligence, Amplify/Dampen, armures. Remplacement : `secretAura`.
- Comparaison de valeur secrète : Mana Tick (différence de `UnitPower` avant et après), texte de mana formaté en K ou en pourcentage par Lua. Remplacement : texte natif `%c` et `%p`, seuil natif.
- Cumuls en combat (texte `%s` de Winter's Chill, Fire Vulnerability, Combustion) : pile secrète, présence seulement.
- Condition croisée : Combustion grisé selon un débuff de la cible (état d'un autre trigger) : bloqué.
- Journal de combat : aucun usage.
- À vérifier : `Item Count` en combat (gemmes) ; retrait de la barre d'incantation native.

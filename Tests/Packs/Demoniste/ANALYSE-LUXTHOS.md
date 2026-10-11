# Analyse du pack « Luxthos - Warlock (Classic Era) »

Source : `wago.io/LuxthosWarlockClassicEra` (version 3, semver 1.15.2, tocversion 11506), chaîne `!WA:2!` décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca. Modèle d'analyse : `ANALYSE-AURAS-LUXTHOS.md` (chaman). Le moteur commun n'est pas réanalysé ici.

Réserve : mêmes restes de gabarit que le chaman. Les filtres `spec` / `role` / `class_and_spec` (ex. 264, 2, 3), `spellknown` 768 sur Mana Tick et `Command Demon` dans le tri du groupe Utilities sont des restes sans effet en Classic Era. Le chargement réel repose sur la classe et sur `spellknown`.

## 0. Chiffres

- 38 entrées sous la racine : 7 groupes enfants (6 dynamiques, 1 statique « Resources ») et 31 feuilles.
- Feuilles : 27 icônes (2 moteur invisibles, 2 effets, 10 Core, 9 utilitaires, 4 maintenance) et 4 barres (Mana Tick, vie, mana, incantation).
- Aucune animation, aucun son, aucun message, aucune texture de proc, aucun swing timer.
- Déclencheurs : `aura2` (par nom ou ID, `ownOnly` sur la cible), `Cooldown Progress (Spell)`, `Item Count`, `Cooldown Progress (Item)`, `Conditions` (HasPet, repos, combat), `Health` / `Power` / `Cast` en unité, et des déclencheurs personnalisés (section 5).

## 1. Gabarit

Identique au chaman : oui. Même racine (centre écran, y -170, strate 2), mêmes groupes dans le même ordre, même moteur Lua (GrowCore, GrowDynamicEffects, GrowSide, GrowUtilities, GrowMaintenance), mêmes General Options (valeurs par défaut identiques : Core 48x40, 5 à 8 icônes, débordement 44x36, autres rangées 38x32, barres de 20 de haut), même Class Options (barre de mana : hauteur, format de texte, police, couleurs, dégradé). Géométrie et carte d'écran : voir le chaman.

Écarts :

- Contenu des rangées : Dynamic Effects 2 icônes (chaman 4), Core 10 (10), Utilities 9 (5), Maintenance 4 (2), Left/Right Side vides.
- Les DoT et malédictions sont dans le Core, en `showAlways` : l'icône reste, grisée à alpha 0,5, quand l'effet est absent. Le Core est donc quasi statique (10 icônes chargées = 8 plus 2 en débordement).
- Les icônes de Maintenance ont chacune trois modes d'affichage (présent / absent / toujours), avec des défauts différents : Soul Link absent, Sacrifice démoniaque présent, armure absente. Toutes masquées en zone de repos.
- Les utilitaires portent tous l'option « sur recharge ou absent / toujours » (défaut 1).
- Triggers absents du chaman : `Item Count`, `Cooldown Progress (Item)`, aura sur `group` et sur `multi`, `Conditions` avec HasPet.
- Pas de totems, pas d'imbue, pas de Core à double état aussi poussé : Amplify Curse, Fel Domination, Shadowburn, Spell Lock combinent aura et recharge.
- Le texte d'option de l'armure parle d'une armure d'une autre édition (reste de copie).

## 2. Auras par rangée

Style commun : zoom 0,3, bordure noire 1 px, balayage de recharge natif. Recharges : grisé en recharge, rouge hors portée (0,87 / 0,34 / 0,33), bleu-violet sans ressource. Lueur pixel sur « effet actif ». Pas d'autre texte maison que le compte au-dessus de Soul Shard.

### 2.1 Dynamic Effects (au-dessus)

| Aura | Sort ou aura (ID) | Trigger | Chargement | Conditions |
|---|---|---|---|---|
| Debuff d'Improved Shadow Bolt | 17800 (et 22959, Fire Vulnerability) | `aura2` débuff sur la cible, par ID, tous lanceurs | classe seulement | lueur Blizzard coupée ; icône automatique |
| Drain Soul | 1120 | `Health` unité cible, `<= 25 %` | `spellknown` 1120 | aucune condition notable |

### 2.2 Core (DoT, procs, recharges)

| Aura | Sort (ID) | Trigger | Chargement | Conditions notables |
|---|---|---|---|---|
| Immolate | 348 | `aura2` débuff cible, siens, `showAlways` | `spellknown` 348 | absent : désaturé + alpha 0,5 ; lueur coupée hors combat |
| Malédiction (icône unique) | Agony 980, Doom 603, Tongues 1714, Weakness 702, Shadow 17862, Elements 1490, Exhaustion 18223, Recklessness 704 | `aura2` débuff cible, siens, une seule icône pour les 8, `showAlways` | `spellknown` 980 | absent : grisé alpha 0,5 ; l'icône suit la malédiction posée |
| Corruption | 172 | `aura2` débuff cible, siens, `showAlways` | `spellknown` 172 | comme Immolate |
| Siphon Life | 18265 | `aura2` débuff cible, siens, `showAlways` | `spellknown` 18881 (rang 4 : choix discutable) | comme Immolate |
| Nightfall | 17941 | `aura2` buff joueur, `showAlways` | talent (index) | absent : grisé alpha 0,5 ; proc : lueur Blizzard (vraie lueur) |
| Conflagrate | 17962 | `Cooldown Progress (Spell)`, sans GCD | `spellknown` 17962 | recharge, portée, ressource |
| Shadowburn | 17877 | débuff cible (17877) + recharge | `spellknown` 17877 | recharge ; lueur pixel et bord de balayage quand le débuff est actif |
| Soul Fire | 6353 | recharge | `spellknown` 6353 | recharge, portée, ressource |
| Amplify Curse | 18288 | buff joueur (18288) + recharge | `spellknown` 18288 | lueur pixel quand le buff est actif, sinon recharge |
| Fel Domination | 18708 | buff joueur (18708, par nom) + recharge | `spellknown` 18708 | idem |

Pas de Shadow Bolt, Life Tap, Incinerate, Drain Life ni Searing Pain.

### 2.3 Utilities

Tous : option « sur recharge ou absent / toujours » ; deux déclencheurs de recharge `showAlways` / `showOnCooldown` plus, selon l'icône, un déclencheur d'effet actif ; grisé en recharge ; lueur pixel quand l'effet est actif.

| Aura | Sort (ID) | Effet actif (trigger) | Chargement |
|---|---|---|---|
| Spell Lock (Felhunter) | 19647 (rang 1 : 19244) | débuff 19244 sur `multi` (toute unité), siens, nombre >= 1 | `spellknown` 19647 (sort de familier) |
| Soothing Kiss (nommé autrement dans le pack) | 6360 | aucun | `spellknown` 6360 |
| Sacrifice (Voidwalker) | 7812 | buff joueur 19441 | `spellknown` 7812 |
| Death Coil | 6789 | débuff cible 6789, siens | `spellknown` 6789 |
| Howl of Terror | 5484 | débuff cible 5484 | `spellknown` 5484 |
| Shadow Ward | 6229 | buff joueur 6229 | `spellknown` 6229 |
| Soulstone | objets 5232, 16892, 16893, 16895, 16896 | `Item Count` des pierres ou buff de résurrection 20765 sur le groupe (siens, nombre >= 1) | `spellknown` 693 ; grisé alpha 0,5 si personne n'a la pierre |
| Healthstone | 15 objets (5509 à 5512, 9421, 19004 à 19013) | `Item Count` par objet (15 triggers) et `Cooldown Progress (Item)` de la pierre 5512 | `spellknown` 6201 ; grisé si aucune pierre, grisé en recharge |
| Soul Shard | objet 6265 | `Item Count` ; texte au-dessus (18 px, `%p`, usage du compte non confirmé) | `spellknown` 6201 ; grisé quand le compte tombe à 0 |

### 2.4 Maintenance

| Aura | ID | Trigger | Chargement | Conditions |
|---|---|---|---|---|
| Familier absent | 688 (sort de chargement) | `Conditions` : sans familier, en combat, hors repos | `spellknown` 688 | lueur Blizzard dès qu'il est visible |
| Soul Link | aura 25228 | buff joueur présent / absent, avec familier, hors repos | `spellknown` 19028 | absent : grisé alpha 0,5 ; défaut « si absent » |
| Sacrifice démoniaque | 18789 à 18792 (auras d'Imp, Voidwalker, Succubus, Felhunter) | buff joueur : présent / reste <= 30 s / absent, hors repos | `spellknown` 18788 | absent : grisé alpha 0,5 ; défaut « si présent » |
| Armure | 687, 706 (par nom : tous rangs) | buff joueur présent / absent, hors repos | `spellknown` 687 | absent : grisé alpha 0,5 ; défaut « si absent » |

### 2.5 Ressources

Mêmes quatre barres que le chaman : vie (désactivée par défaut), mana (texte orange à 30 % ou moins, rose à 15 % ou moins), incantation (couleurs par état), Mana Tick. Aucune barre de familier ni de compteur d'éclats en barre.

## 3. Options d'auteur propres à la classe (Class Options et auras)

- Class Options : identique au chaman (barre de mana seulement).
- Mana Tick : tolérance (0,08) et décalage de tic (0,01).
- Utilitaires (Spell Lock, Soothing Kiss, Sacrifice, Death Coil, Howl of Terror, Shadow Ward) : « afficher sur recharge ou absent » ou « toujours » (défaut 1).
- Soul Link : présent / absent / toujours (défaut absent). Sacrifice démoniaque : défaut présent. Armure : défaut absent.
- Aucune option sur Core, DoT, Soulstone, Healthstone, Soul Shard.

## 4. Code personnalisé propre à la classe (idées)

Très peu de code propre au Démoniste : le moteur est celui du chaman.

- Logique de déclencheurs des utilitaires : choisit entre « toujours visible » et « visible en recharge ou quand l'effet est actif ».
- Logique de déclencheurs de Maintenance : booléen simple, masque en zone de repos, exige un familier pour Soul Link, ajoute un seuil de 30 s pour le Sacrifice démoniaque.
- Healthstone : un agrégat de 15 déclencheurs d'objets, vrai s'il en existe au moins un.
- Mana Tick : même code que le chaman (cycle de 2 s, gel de 5 s après un lancement coûtant de la mana). Life Tap fausse le repérage du tic dans le pack.
- Cast Bar : couleur par interruptibilité et retrait de la barre Blizzard, comme le chaman.

## 5. Bloqué sur Forever

- Lecture d'aura en combat via `aura2` : toutes les auras du pack (DoT, malédictions, Nightfall, Improved Shadow Bolt, Amplify Curse, Fel Domination, Death Coil, Howl, Shadow Ward, Sacrifice, Spell Lock, Soul Link, Sacrifice démoniaque, armure, buff de Soulstone sur le groupe). Remplacement : `secretAura`.
- Mana Tick : comparaison de `UnitPower` avant / après (secrète en combat) : bloqué. Seule la règle des 5 s par `Spell Cast Succeeded` reste possible.
- Texte formaté des barres de vie et de mana (K, pourcentage par Lua) : bloqué, texte natif `%c` / `%p`.
- Journal de combat : aucun usage dans le pack.
- Valeur de recharge comparée en Lua : aucune.
- À vérifier : `Item Count` et `Cooldown Progress (Item)` en combat ; santé de la cible `<= 25 %` en combat ; chargement `spellknown` sur un sort de familier ; aura sur `group` et `multi`.

## 6. IDs lus dans le pack et absents de `Classes/Warlock.md`

17862 (Curse of Shadow), 1490 (Curse of the Elements Era), 18789 à 18792 (auras du Sacrifice démoniaque), 20765 (aura de la Soulstone), 22959, 54374 (reste), tous les IDs d'objets (Soul Shard 6265, Healthstone, Soulstone). Seuls les objets restent des candidats à lire en jeu ; le reste est exclu.

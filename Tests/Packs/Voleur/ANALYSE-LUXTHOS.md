# Analyse du pack « Luxthos - Rogue (Classic Era) »

Source : `wago.io/LuxthosRogueClassicEra`, version 6, semver 1.15.5, tocversion 11505 (lus dans les entrées), décodé avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca.

Le moteur commun (General Options, placement, bordures, alpha global) est décrit dans `ANALYSE-AURAS-LUXTHOS.md` (chaman). Ce fichier ne relève que les écarts et le contenu propre au voleur.

## 0. Chiffres

- 44 entrées sous la racine : 8 groupes et 36 feuilles.
- Groupes : 6 dynamiques (Dynamic Effects, Core, Left Side, Right Side, Utilities, Maintenance), 1 statique (Resources), 1 dynamique imbriqué (Combo Points, croissance centrée vers la droite, 5 segments).
- Feuilles : 27 icônes (2 « moteur » invisibles, 3 effets, 11 Core, 8 utilitaires, 3 maintenance) et 9 barres (Energy Tick, vie, énergie, 5 segments de points de combo, incantation). Total 27 + 9 = 36.
- Aucune animation, son ni message. Left Side et Right Side sont vides.
- Aucune icône de constructeur ni de finisher dans le Core : ni Backstab, Sinister Strike, Mutilate, Eviscerate, Ambush ni Cheap Shot. Le pack suit uniquement recharges, buffs et débuffs.

## 1. Gabarit

Identique au chaman : même moteur de General Options (config par défaut identique : Core 48x40, débordement 44x36, 5 à 8 icônes, effets / utilitaires / maintenance 38x32, barres de 20 de haut, zoom 30, bordure noire 1 px), mêmes groupes, mêmes ancrages, mêmes événements de réinitialisation. Les restes de gabarit (chargement `WARLOCK` en multi, filtres `spec` 2 / 3, rôle dégâts, talents par index) n'ont pas d'effet en Classic Era.

Écarts :

| Point | Chaman | Voleur |
|---|---|---|
| Class Options | options de classe seulement (barre de mana) | options énergie et points de combo ; un second déclencheur lit le journal de combat (voir §5) |
| Barre de tic | Mana Tick | Energy Tick (barre 200x10 à étincelle, ancrée sur la barre d'énergie) |
| Resources | vie, mana, incantation | vie, énergie, groupe de 5 segments de points de combo, incantation |
| Groupe Core | 10 icônes dont 4 totems | 11 icônes, aucun constructeur |
| Maintenance | bouclier et imbue | Furtivité, poison main droite, poison main gauche |
| Utilitaires | 5 sorts de totem | 8 sorts : Kidney Shot, Kick, Gouge, Evasion, Sprint, Blind, Feint, Distract |

## 2. Auras par rangée

Convention : « CD » = Cooldown Progress (Spell). « aura2 » = lecture d'aura par nom. Le chargement réel est `spellknown` sur l'ID de rang 1 (sauf mention). Les icônes de CD sont grisées en recharge ; la lueur « prêt » est neutralisée (conditions mortes), seule la lueur pixel « effet actif » agit.

### 2.1 Effets dynamiques (au-dessus)

| Aura | ID | Trigger | Chargement | Conditions |
|---|---|---|---|---|
| Garrote | 703 | aura2 débuff cible, siens | `spellknown` 703 | lueur pixel quand actif |
| Expose Armor | 8647 | aura2 débuff cible, siens | `spellknown` 8647 | lueur pixel ; cumuls en texte |
| Remorseless Attacks | 14143, 14149 | aura2 buff joueur | `spellknown` 34503 (reste d'un autre jeu), talent par index désactivé | lueur pixel |

14143, 14149 et 34503 sont absents du DB2 de Forever (`Classes/Rogue.md` : 14144 et 14148 seulement).

### 2.2 Core

| Aura | ID | Trigger | Chargement | Conditions |
|---|---|---|---|---|
| Hemorrhage | 16511 | aura2 débuff cible, siens, `showAlways` | `spellknown` 16511 | absent : grisé + alpha 0,5 ; actif : lueur pixel ; cumuls en texte |
| Rupture | 1943 | idem | `spellknown` 1943 | idem |
| Slice and Dice | 5171 | aura2 buff joueur, `showAlways` | `spellknown` 5171 | idem |
| Ghostly Strike | 14278 | aura2 buff joueur + CD | `spellknown` 14278 | recharge grisée ; buff actif : lueur pixel, balayage du buff, inversion coupée |
| Riposte | 14251 | CD seul, avec l'état « utilisable » | `spellknown` 14251 | grisé tant que le sort n'est pas utilisable ou en recharge ; dégrisé quand il l'est |
| Blade Flurry | 13877 | aura2 buff joueur + CD | `spellknown` 13877 | double état |
| Adrenaline Rush | 13750 | aura2 buff joueur + CD | `spellknown` 13750 | double état |
| Cold Blood | 14177 | aura2 buff joueur + CD | `spellknown` 14177 | double état |
| Premeditation | 14183 | **journal de combat** (réussite du sort, durée 20 s) + CD | `spellknown` 14183 | double état |
| Preparation | 14185 | CD seul | `spellknown` 14185, talent par index | recharge |
| Vanish | 1856 | CD seul (avec GCD) | `spellknown` 1856 | recharge |

Aucune condition de portée ni de ressource dans le Core.

### 2.3 Utilitaires

Tous : 2 ou 3 déclencheurs (CD `showAlways`, CD `showOnCooldown`, parfois une aura) avec logique personnalisée qui choisit selon l'option d'auteur « sur recharge / toujours » (défaut : sur recharge).

| Aura | ID | Aura associée | Conditions |
|---|---|---|---|
| Kidney Shot | 408 | aura2 sur la cible (étourdissement) | grisé en recharge ; bleu-violet + grisé si énergie insuffisante ; aura active : lueur pixel, balayage de l'aura |
| Kick | 1766 | aucune | idem (ressource) |
| Gouge | 1776 | aura2 sur la cible | idem Kidney Shot |
| Evasion | 5277 | aura2 buff joueur | double état |
| Sprint | 2983 | aura2 buff joueur | double état |
| Blind | 2094 | aura2 sur n'importe quelle unité (`multi`) | double état |
| Feint | 1966 | aucune (un trigger d'aura mal réglé, sans effet) | recharge |
| Distract | 1725 | aucune | recharge, sans condition de ressource |

### 2.4 Maintenance

| Aura | Trigger | Chargement | Conditions |
|---|---|---|---|
| Furtivité | aura2 sur Stealth (1784) et Vanish (1856), plus CD de Stealth sur recharge | `spellknown` 1784 | actif : lueur pixel, balayage de l'aura ; recharge : grisé |
| Poison main droite | Weapon Enchant main droite : présent, ≤ 300 s, absent ; zone de repos ; événement d'options ; recharge de l'emplacement 16 | classe, niveau ≥ 20, type d'arme équipée (7 types) | option « Behavior » : si présent / si absent / toujours, défaut si absent ; masqué en zone de repos ; vide : alpha 0,5 + grisé |
| Poison main gauche | idem, emplacement 17 | classe, niveau ≥ 20, talent par index 68 (probablement double maniement) | idem |

La liste d'`auranames` des poisons est un reste sans effet (identifiants d'un autre jeu) ; l'enchantement est lu par emplacement, sans filtre de poison.

### 2.5 Ressources

| Aura | Détails |
|---|---|
| Health Bar | 405x20, désactivée par défaut (`use_never`). |
| Energy Bar | 405x20, Power énergie (type 3), jaune dégradé, texte pourcentage. Un second déclencheur « Spell Known » (sort 200806, absent de Forever) conditionne un changement de couleur sous 50 % : mort sur Forever. |
| Combo Points | 5 barres de 56x20 dans un groupe imbriqué (croissance à droite, espace 2, hauteur d'option 15), chacune sur Power points de combo (type 4). Couleur par palier : 1 à 3 normal, 4 mis en avant, 5 plein (blanc). Chaque segment décide son remplissage par Lua. Options de couleur « charged » et « supercharged » : restes d'un autre jeu. |
| Cast Bar | 405x20, unité `Cast` joueur ; un déclencheur coupe les événements de la barre native (`UnregisterAllEvents`). |
| Energy Tick | barre 200x10 transparente, étincelle seule. |

## 3. Options d'auteur propres à la classe

Class Options, groupe « Resources & Class Settings » :

- Energy Bar : hauteur (20), police, taille (14), couleurs 1 et 2 (jaune), dégradé, couleurs 1 et 2 de l'état « ex », dégradé.
- Combo Points : hauteur (15), police, taille (14), couleurs et dégradé de quatre états (normal rouge-orangé, mis en avant vert, plein blanc, « charged » bleu) plus un état violet « supercharged » ; ces deux derniers sont des restes.

Auras individuelles : poison, comportement (si présent / si absent / toujours, défaut si absent) ; utilitaires, comportement (sur recharge / toujours, défaut sur recharge). Energy Tick : aucune option exportée.

## 4. Code personnalisé propre à la classe (idées seulement)

| Pièce | Ce qu'elle fait | Statut Forever |
|---|---|---|
| Class Options, init | Crée deux tables d'instantanés (Rupture, Garrote) et une troisième, jamais lue ici. | ok, inutile |
| Class Options, 2e déclencheur | Lit le journal de combat : à la pose d'un Garrote ou d'une Rupture, note si le voleur était furtif (Stealth, Vanish, plus des buffs d'autres versions) pour marquer la cible comme « posée en furtivité ». Aucune aura du pack ne lit le résultat dans cette version. | **bloqué** (journal de combat et lecture d'aura en Lua) ; mort dans le pack lui-même |
| Energy Tick | Compare l'énergie avant / après sur `UNIT_POWER_FREQUENT` pour détecter un gain, puis cycle de 2 s. | **bloqué** (comparaison de `UnitPower` en combat) |
| Barres de points de combo | Chaque condition appelle un événement qui colore le segment selon la valeur. | ok pour le principe ; en natif : un seuil par aura |
| Energy Bar, couleur sous 50 % | Condition sur `percentpower` avec une aura Spell Known d'un autre jeu. | seuil natif possible ; la condition de sort est morte |
| Cast Bar, désactivation native | Désinscrit les événements du cadre de lancement natif. | à vérifier (nom du cadre et taint) |
| Logique des utilitaires et des poisons | Choix du mode d'affichage et masquage en zone de repos. | ok, remplaçable par deux triggers CD et `resting` |

## 5. Bloqué sur Forever

- Journal de combat : Premeditation (buff détecté par la réussite du sort), instantanés Rupture / Garrote de Class Options.
- Comparaison d'une valeur secrète : Energy Tick (énergie avant / après), cycle de 2 s.
- `aura2` en combat (aucune lecture des auras secrètes) : Garrote, Expose Armor, Remorseless Attacks, Hemorrhage, Rupture, Slice and Dice, Ghostly Strike, Blade Flurry, Adrenaline Rush, Cold Blood, Kidney Shot, Gouge, Evasion, Sprint, Blind, Furtivité. Remplacement : `secretAura`.
- Cooldown Progress (Spell) et Weapon Enchant sont natifs : restent valables.
- Points de combo et énergie en Power : valeurs lisibles selon le plan voleur (à tester).

## 6. Idées utiles pour Musca

- Débuffs et Slice and Dice toujours visibles, grisés à demi-alpha quand absents, lueur à l'application.
- Double état (recharge puis buff) pour Ghostly Strike, Cold Blood, Blade Flurry, Adrenaline Rush, Evasion, Sprint, Blind.
- Kidney Shot et Gouge : durée de l'effet sur la cible dans la même icône que la recharge.
- Riposte : grisée tant qu'elle n'est pas utilisable.
- Mode d'affichage des utilitaires : sur recharge (défaut) ou toujours.
- Poisons : chargés dès le niveau 20, main gauche conditionnée à la seconde arme, seuil de 300 s, masqués en zone de repos.
- Points de combo : le 4e point prend une couleur distincte du 1 à 3, le 5e une couleur pleine.
- Furtivité : icône d'état (actif / en recharge) en Entretien.

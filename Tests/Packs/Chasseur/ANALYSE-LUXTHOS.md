# Analyse du pack « Luxthos - Hunter (Classic Era) »

Source : `wago.io/LuxthosHunterClassicEra` (version 9, semver 1.15.8, tocversion 11505), chaîne `!WA:2!` décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca.

Modèle commun : `ANALYSE-AURAS-LUXTHOS.md` (chaman). Seuls les écarts et le contenu propre au chasseur sont décrits ici. Les restes de gabarit du chaman s'appliquent aussi : filtres `spec`, `role` et `class_and_spec` sans effet, chargement réel par `spellknown`, conditions de lueur « prêt » mortes, paramètres de rangées par défaut identiques.

## 0. Chiffres

- 43 entrées avec la racine : 42 sous la racine, dont 7 groupes (6 dynamiques, 1 statique « Resources ») et 35 feuilles.
- Feuilles : 2 icônes moteur invisibles (Class Options, General Options), 1 barre Mana Tick, 2 icônes Effets, 11 icônes Core, 11 icônes Utilitaires, 3 icônes Maintenance, 5 barres de ressource (vie, mana, tir à distance, mêlée, incantation).
- Par type de région : 29 icônes, 6 barres, 7 groupes.
- Aucun son, aucun message, aucune animation, aucune texture de proc, aucun pop-up.
- Rien sur le familier en dehors de trois auras lues sur `pet` (Bestial Wrath, Intimidation, Cower) et d'une icône « sans familier ». Pas de barre de vie du familier, pas de bonheur, pas de Mend Pet, pas de Feed Pet.

## 1. Gabarit

Identique au chaman : même moteur « General Options » (cadre d'ancrage redimensionné par Lua, 4 déclencheurs), même « Class Options », mêmes groupes (Dynamic Effects, Core, Left Side, Right Side, Utilities, Maintenance, Resources), mêmes ancrages, mêmes options d'auteur globales et mêmes valeurs par défaut (Core 48x40 avec 5 à 8 emplacements, débordement 44x36, autres rangées 38x32, barres 20 de haut, zoom 0,3, bordure noire 1 px, lueur pixel). Racine centrée en x = 0, y = -170.

Écarts :

| Point | Chaman | Chasseur |
|---|---|---|
| Version | 3, semver 1.15.2, toc 11506 | 9, semver 1.15.8, toc 11505 |
| Effets | 4 icônes | 2 icônes |
| Core | 10 icônes | 11 icônes : 3 en débordement sur la 2e ligne |
| Utilitaires | 5 icônes | 11 icônes |
| Maintenance | 2 icônes | 3 icônes (aspects, munitions, sans familier) |
| Barres | vie, mana, incantation | vie, mana, tir à distance, mêlée, incantation (5) |
| Class Options | barre de mana seule | barre de mana et deux barres de swing (hauteur 10, orange pour la mêlée, violet pour la distance) |
| Incantation | unité `Cast` native | déclencheur personnalisé sur le journal de combat |
| Comportement utilitaires | option sur recharge ou toujours, défaut sur recharge | idem, défaut sur recharge |
| Comportement maintenance | option sur les deux icônes, défaut « si absent » | option sur l'icône aspects seule, défaut « si présent » ; les munitions ont la même option sans logique derrière |
| Mana Tick | présent | présent, code identique (gabarit), chargé pour toute la classe |
| Familier | aucun | trois auras lues sur `pet`, une icône Conditions « sans familier » |
| Restes de copie | nom périmé du sort de totem | icône du familier absent portée par Kill Command, Volley et Multi-Shot avec un nom de sort périmé, Aspects avec un déclencheur « Item Count » sur un objet de gabarit (6265) |

## 2. Auras une par une

Convention : CD = Cooldown Progress (Spell) en `showAlways` avec GCD (sans GCD pour Bestial Wrath, Volley, Rapid Fire, Intimidation, Deterrence, Disengage). Toutes les icônes de CD ont les conditions du chaman : grisé en recharge, rouge hors de portée, bleu-violet sans ressource (seulement sur Arcane Shot, Aimed Shot, Multi-Shot et Raptor Strike), lueur coupée hors combat. Chargement : classe `HUNTER` + `spellknown` sauf mention.

### 2.1 Effets dynamiques

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Hunter's Mark (1130) | `aura2` débuff cible, par nom | sort connu 1130 | condition de désaturation écrite sur un cas impossible (morte) : aucun effet |
| Quick Shots (6150) | `aura2` buff joueur, par nom, les siens | talent par index (Improved Aspect of the Hawk), pas de sort connu | lueur pixel à l'apparition |

### 2.2 Core (11 icônes, 3 en débordement)

| Aura | Déclencheur | Chargement | Conditions notables |
|---|---|---|---|
| Arcane Shot (3044) | CD ; second déclencheur « talent connu » (index 106, inversé) en mode « tous » : l'icône disparaît si ce talent est pris | sort connu | quatre conditions standard |
| Aimed Shot (19434) | CD | sort connu | idem |
| Multi-Shot (2643) | CD | sort connu | idem ; un sous-texte inutilisé |
| Stings (1978, 3043, 3034 ; 19386 dans la liste) | `aura2` débuff cible, par nom, les siens, 4 piqûres, `showAlways` | sort connu 1978 | aucune piqûre sur la cible : grisé + alpha 0,5 ; la condition « aucune piqûre en combat » écrit une lueur éteinte : pas de lueur |
| Concussive Shot (5116) | `aura2` débuff cible + CD | sort connu | double état : débuff actif = lueur pixel, bord de balayage, non grisé ; sinon recharge |
| Raptor Strike (2973) | Action Usable sur Mongoose Bite rang 4 (14271) ; CD Raptor Strike ; CD de Wing Clip (2974) pour la portée | sort connu | Mongoose Bite utilisable : lueur, non grisé ; hors de portée de mêlée mesurée sur Wing Clip ; bleu sans mana |
| Counterattack (19306) | CD, mode « tous » | sort connu | utilisable et hors recharge : lueur ; non utilisable : grisé |
| Bestial Wrath (19574) | `aura2` buff sur `pet`, par nom + CD sans GCD | sort connu | double état : buff actif = lueur pixel, bord, non grisé |
| Volley (1510) | CD sans GCD | sort connu | grisé en recharge (le sort n'a pas de vraie recharge) |
| Readiness (23989) | CD | sort connu | idem |
| Rapid Fire (3045) | `aura2` buff joueur + CD | sort connu | double état comme Bestial Wrath |

### 2.3 Utilitaires (11 icônes)

Chaque icône a deux ou trois déclencheurs CD du même sort (toujours, sur recharge) et une logique qui choisit selon l'option `utility.behavior` (défaut sur recharge). Quand une aura existe, elle donne un double état : lueur pixel et bord pendant l'effet.

| Aura | Aura lue en plus | Remarque |
|---|---|---|
| Intimidation (19577) | `aura2` sur `pet` | effet actif sur le familier |
| Scatter Shot (19503) | `aura2` débuff cible | rouge hors de portée |
| Wyvern Sting (19386) | aucune | ID absent du DB2 des sorts |
| Deterrence (19263) | `aura2` buff joueur | |
| Disengage (781) | aucune | |
| Distracting Shot (20736) | `aura2` débuff cible, les siens, compte > 0 | |
| Feign Death (5384) | `aura2` buff joueur, compte > 0 | |
| Flare (1543) | aucune | |
| Tranquilizing Shot (19801) | aucune | |
| Freezing Trap (1499) | aucune | sort par ID exact, sans override : un seul piège de la famille |
| Cower (1742) | `aura2` sur `pet`, compte > 0 | pas de chargement par sort connu : s'affiche pour tout chasseur |

Absents du pack : Frost, Immolation et Explosive Trap, Disengage rangs, Mend Pet, Call Pet, Revive Pet, Intimidation talent, Black Arrow, Wing Clip, Lacerate, Mongoose Bite en icône propre.

### 2.4 Maintenance (3 icônes)

| Aura | Déclencheur | Détails |
|---|---|---|
| Aspects | `aura2` joueur sur 5 aspects par nom (Hawk 13165, Cheetah 5118, Pack 13159, Wild 20043, Monkey 13163), en deux versions (présent, absent), plus « zone de repos » et événement d'options | option : si présent (défaut), si absent, toujours ; masquée en zone de repos ; absent : alpha 0,5 + grisé. Pas de Beast, Viper ni Falcon. Chargement : sort connu 13165 |
| Ammo | Cooldown Progress (Equipment Slot), emplacement 0 (munitions) | compteur en texte `%s` sur l'icône ; grisé à 0. Pas de seuil bas, pas de chargement par arme, pas de masquage en repos |
| Not Pet (sans familier) | Conditions joueur : pas de familier (vivant), hors zone de repos, hors véhicule, en combat | chargement sort connu 883 (Call Pet) ; lueur Blizzard en combat ; icône portée par le sort Kill Command (34026) |

### 2.5 Ressources

| Aura | Détails |
|---|---|
| Health Bar | identique au chaman, désactivée par défaut |
| Mana Bar | unité `Power` mana, options de Class Options, texte formaté par Lua |
| Mana Tick | voir chaman |
| Swing Timer Range Bar | événement `Swing Timer`, main `ranged`, barre violette de 10 de haut, deux déclencheurs (swing, conditions) ; condition hors combat : change l'état de couleur par code |
| Swing Timer Melee Bar | événement `Swing Timer`, main `main`, barre orange de 10 de haut ; même logique |
| Cast Bar | voir §4 |

Les barres de swing sont chargées pour un chasseur avec filtres de spécialisation périmés (reste de gabarit). Elles n'ont pas de texte maison.

## 3. Finition visuelle

Identique au chaman. Différences : lueur Blizzard (proc) réellement allumée sur Counterattack (utilisable et hors recharge), Raptor Strike (Mongoose Bite utilisable) et Not Pet ; une condition de lueur sans déclencheur référencé sur Aimed Shot, Multi-Shot et Raptor Strike a un comportement indéfini (probablement morte) ; lueur pixel sur les doubles états (Concussive Shot, Bestial Wrath, Rapid Fire, utilitaires). Le bord de balayage s'allume pendant l'effet. Aucune teinte propre au chasseur.

## 4. Options d'auteur propres à la classe (Class Options)

Groupe « Resources & Class Settings » :

- Mana Bar : hauteur (20), format du texte (5 choix), police, taille (14), deux couleurs (bleu), sens du dégradé.
- Swing Timer - Range : hauteur (10), police, taille (14), deux couleurs (violet), sens du dégradé.
- Swing Timer - Melee : hauteur (10), police, taille (14), deux couleurs (orange), sens du dégradé.

Options d'auras : Cast Bar : « afficher le rechargement d'Auto Shot » (non) et « afficher l'incantation d'Auto Shot » (non). Aspects : comportement (si présent par défaut). Utilitaires : comportement (sur recharge par défaut). Mana Tick : tolérance (0,08), décalage (0,01). General Options : mêmes champs que le chaman.

## 5. Code personnalisé propre à la classe (idées seulement)

| Pièce | Ce qu'elle fait |
|---|---|
| Barre d'incantation, déclencheur 1 | Écoute le journal de combat : début, succès, échec d'un sort du joueur parmi Aimed Shot, Multi-Shot, Auto Shot ; calcule durée et fin ; calcule le recul (pushback) à chaque dégât reçu pendant l'incantation. |
| Barre d'incantation, init | Table des carquois et de leur bonus de vitesse (1,10 à 1,15), durée = temps de lancement / (hâte à distance x carquois). Aimed Shot fixé à 3,5 s. Recul : 1, 0,8, 0,6, 0,4, 0,2 s selon le nombre de coups. |
| Barre d'incantation, déclencheur 3 | Barre de rechargement d'Auto Shot : durée de l'arme à distance moins une demi-seconde de lancement, relancée à chaque tir réussi (sort 75), seulement avec l'option. |
| Barre d'incantation, conditions | Change la couleur selon l'état (normal, non interruptible) par événement interne. |
| Barres de swing, conditions | Choisissent un état de couleur hors combat par événement interne. |
| Aspects | Logique à trois comportements : voir §2.4. |

## 6. Bloqué sur Forever

- Barre d'incantation, déclencheur 1 : lit le journal de combat (début de sort, dégâts reçus, dégâts d'environnement). Le recul (pushback) en dépend : bloqué. La durée de lancement par hâte de carquois lit des valeurs de hâte : à vérifier si elles sont secrètes.
- Mana Tick : compare la mana avant / après (`UnitPower` secret en combat) : bloqué, comme chez le chaman. Seule la règle des 5 s reste faisable.
- Texte de mana et de vie formaté en Lua et seuils de couleur de texte : arithmétique sur valeur secrète en combat : bloqué ; remplacé par texte natif et seuil natif.
- `aura2` en combat : Hunter's Mark, Quick Shots, les quatre piqûres, Concussive Shot, Bestial Wrath et Intimidation et Cower sur `pet`, Rapid Fire, Scatter Shot, Deterrence, Distracting Shot, Feign Death, les aspects. Tout passe en `secretAura`.
- Swing Timer : événement natif, aucune lecture secrète ; sa disponibilité sur Forever reste à tester (le prototype est retiré seulement pour Cataclysm et Pandaria).
- Munitions : emplacement 0 du Cooldown Progress (Equipment Slot) existe dans Musca ; son comptage et l'existence de munitions sur Forever sont à tester.
- Familier : la condition « a un familier (vivant) » du déclencheur Conditions lit seulement l'existence et la mort : pas de valeur secrète.

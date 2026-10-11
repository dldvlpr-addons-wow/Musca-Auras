# Plan v2 du pack Druide (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Plan seul : aucun code, aucune chaîne d'import.

Socle commun : `PLAN-AURAS-V2.md` (rangées, style, éléments bloqués). Règles v1 : `PLAN-AURAS-CLASSES.md`.
IDs et présence des sorts sur Forever : `Classes/Druid.md` (DB2 1.60.1.70245), qui fait foi.
Pack actuel : `Tests/Packs/Druide/PackDruide.lua`, préfixe `mcDruiV1`. Pack v2 : préfixe `mcDruiV2`.

États : **acquis** (testé en jeu), **à tester** (trigger natif, pas vu en combat sur Forever), **bloqué**.
Aucun élément du pack Druide n'est acquis en jeu : le pack v1 n'a pas encore passé la grille de test. Les types de
trigger `secretAura`, Power (seuil), Cooldown Progress et Weapon Enchant sont acquis ailleurs (chaman) ; la colonne
État dit alors « type acquis, ID à confirmer ».

## 1. Sources et spécialisations couvertes

Sources :

- `Classes/Druid.md` : sorts, rangs, talents, IDs d'aura déclenchés du DB2.
- `RECHERCHE-AURAS-CLASSES.md` : packs Classic du druide (powershift, tick d'énergie, Omen of Clarity, formes,
  rappels Mark of the Wild et Thorns).
- `ANALYSE-AURAS-FOJJI.md` section 7 : barres de rage, énergie et mana par forme, 5 segments de combo, débuffs
  Moonfire et Insect Swarm hors barre, barre de recharge par forme.
- `Tests/Packs/Druide/ANALYSE-LUXTHOS.md` : pack Luxthos Druid (Classic Era) décodé (formes lues par aura, mana fine en
  forme, 5 segments de combo, icônes doubles avec lueur, maintenances à trois comportements). Idées seulement.
- `ANALYSE-AURAS-LUXTHOS.md`, `ANALYSE-AURAS-WAGO.md` : gabarit commun (comportement présent / absent, alpha 0,5 grisé
  si absent, rappels cachés en zone de repos). Idées seulement.

Arbres Classic de Forever :

- Équilibre : Moonfire, Wrath, Starfire, Insect Swarm (talent), Hurricane, Moonkin Form (talent), Nature's Grace,
  Eclipse (ID incertain).
- Combat farouche : formes Chat et Ours, Feral Charge, Primal Bite, Shifting Power, Berserk (ID incertain).
- Restauration : Rejuvenation, Regrowth, Swiftmend, Nature's Swiftness, Wild Growth, Tranquility, Innervate, Rebirth.

Variantes de jeu (codes utilisés dans les tableaux) :

| Code | Variante | Usage | Chargement |
|---|---|---|---|
| H | Humanoïde, sans talent de spé | solo, montée de niveau | forme absente, Swiftmend inconnu |
| E | Équilibre (Moonkin) | solo, donjon, raid dégâts | sort connu Moonkin Form 24858 |
| R | Restauration | donjon, raid soins | sort connu Swiftmend 18562 |
| C | Chat | solo, donjon dégâts | forme Chat (768) |
| O | Ours | solo, donjon tank | forme Ours (5487) ou Dire Bear (9634) |

H et E partagent le même jeu d'icônes de sorts de lanceur. E ajoute seulement Nature's Grace, Eclipse et l'indicateur
de forme. Le raid hors soins et hors tank n'a pas de variante propre.

## 2. Tableaux par rangée

Notes de lecture :

- « Dual » : une seule icône à deux états, recharge ou absence d'abord, puis durée de l'effet (point 8 de la section 5
  de `PLAN-AURAS-V2.md`, à vérifier).
- Hors combat et sans cible : alpha 0,4 sur Principal et Utilitaires, posé aura par aura.
- Grisé en recharge, rouge hors de portée, bleu sans ressource : les trois conditions du style commun, sur toute
  icône de sort qui a un coût ou une portée.
- Rangs : tous listés, un trigger par aura avec la liste d'IDs. Chargement par `spellknown` du rang 1.
- Aucune forme requise n'est indiquée par `Classes/Druid.md`, sauf mention. Le chargement par forme se déduit du
  type de sort (énergie = Chat, rage = Ours) et reste à tester.

### 2.1 Rappels (y +150, hors combat, cachés en zone de repos)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mark of the Wild manquant | rebuffer avant le pull | `secretAura` joueur HELPFUL, absent, OU reste < 5 min | sorts 1126, 5232, 6756, 5234, 8907, 9884, 9885 ; Gift of the Wild 21849, 21850 | sort connu 1126 ; hors combat ; zone de repos masquée | icône 32, lueur fixe tant qu'affiché | type acquis, ID d'aura à confirmer |
| Thorns manquant | idem, option tank et PvP | `secretAura` joueur HELPFUL, absent | 467, 782, 1075, 8914, 9756, 9910 | sort connu 467 ; hors combat ; zone de repos masquée | icône 32 | type acquis, ID d'aura à confirmer |
| MANA BAS | boire ou Innervate | Power mana, joueur, seuil « sous 20 % » | type 0 | classe ; hors combat ; zone de repos masquée | texte rouge | acquis (type Power seuil) |

Trois rappels. « Forme manquante » n'est pas un rappel : l'indicateur de forme est dans Entretien.

### 2.2 Effets (y +60, icônes 32 : procs, buffs courts, debuffs posés)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Clearcasting | lancer un sort gratuit | `secretAura` joueur HELPFUL | 16870 (déclenché par 16864) | sort connu 16864 ; H, E, R, C, O | lueur pixel à l'apparition ; durée en texte | à tester ; s'efface seul si le talent 16864 est inactif |
| Nature's Grace | enchaîner un cast plus rapide | `secretAura` joueur HELPFUL | 16886 (talent 16880) | sort connu 16880 ; H, E | lueur pixel ; durée 3 s | à tester |
| Eclipse | lancer Starfire raccourci | `secretAura` joueur HELPFUL, texte des charges | candidats 408248, 408255, 409813, 441260, 1286115 | aucun `spellknown` fiable ; H, E | lueur pixel ; charges en texte `%s` | à tester, ID à confirmer (section 6) |
| Pounce (saignement) | ne pas relancer trop tôt | `secretAura` cible HARMFUL, posé par le joueur | 9007, 9824, 9826 (déclenchés par 9005, 9823, 9827) | sort connu 9005 ; C | texte de durée rouge sous 3 s | à tester, ID à confirmer |
| Entangling Roots (cible) | ne pas casser le contrôle | `secretAura` cible HARMFUL | 339, 1062, 5195, 5196, 9852, 9853 ; Nature's Grasp déclenche 19970 à 19975 | sort connu 339 ; H, E, R | durée en texte, rouge sous 3 s | type acquis, ID d'aura à confirmer |
| Hibernate (cible) | relancer avant la fin | `secretAura` cible HARMFUL | 2637, 18657, 18658 | sort connu 2637 ; H, E | durée en texte, rouge sous 3 s | type acquis, ID d'aura à confirmer |

Six auras. Clearcasting, Nature's Grace et Eclipse sont chargées par talent, pas par forme.

### 2.3 Principal (y 0, icônes 44, 8 au plus par variante)

Variante C (Chat), 7 icônes :

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Rake | poser ou renouveler le saignement | `secretAura` cible HARMFUL joueur, dual avec Cooldown Progress pour portée et énergie | 1822, 1823, 1824, 9904 | sort connu 1822 ; C | actif : durée, rouge sous 3 s ; absent : grisé alpha 0,5 ; rouge hors portée ; bleu sans énergie | type acquis, dual à tester, ID d'aura à confirmer |
| Rip | idem, finisseur | idem | 1079, 9492, 9493, 9752, 9894, 9896 | sort connu 1079 ; C | idem | idem |
| Ferocious Bite | dépenser les points de combo | Cooldown Progress + trigger Power combo | 22568, 22827, 22828, 22829, 31018 | sort connu 22568 ; C | lueur à 5 points de combo ; rouge hors portée ; bleu sans énergie | à tester (combo en seuil) |
| Shred | construire des points de combo par derrière | Cooldown Progress | 5221, 6800, 8992, 9829, 9830 | sort connu 5221 ; C | rouge hors portée ; bleu sans énergie | acquis (type) |
| Claw | construire des points de combo de face | Cooldown Progress | 1082, 3029, 5201, 9849, 9850 | sort connu 1082 ; C | idem | acquis (type) |
| Berserk | enclencher le gros cooldown | Cooldown Progress, dual avec buff joueur | candidat 417141 (sort) ; aura non départagée | sort connu 417141 (à confirmer) ; C | grisé en recharge ; actif : lueur pixel | à tester, ID à confirmer |
| Shifting Power | regagner 40 énergie contre 55 % de mana | Cooldown Progress | 1322605 | sort connu 1322605 ; C | grisé en recharge 16 s ; bleu sans mana | à tester |

Variante O (Ours), 8 icônes :

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Maul | dépenser la rage sur le prochain coup | Queued Action | 6807, 6808, 6809, 8972, 9745, 9880, 9881 | sort connu 6807 ; O | lueur tant que le coup est en file ; bleu sans rage | à tester |
| Swipe | menace de zone | Cooldown Progress | 779, 780, 769, 9754, 9908 | sort connu 779 ; O | rouge hors portée ; bleu sans rage | acquis (type) |
| Lacerate | poser le saignement de menace | `secretAura` cible HARMFUL, texte des charges | 414644, 1235826, 1235827 | sort connu 414644 ; O | actif : durée et charges ; absent : grisé alpha 0,5 | à tester, ID d'aura à confirmer |
| Demoralizing Roar | réduire les dégâts des mobs | `secretAura` cible HARMFUL, dual | 99, 1735, 9490, 9747, 9898 | sort connu 99 ; O | actif : durée, rouge sous 3 s ; absent : grisé alpha 0,5 | type acquis, ID d'aura à confirmer |
| Bash | étourdir ou interrompre un incanteur | Cooldown Progress, dual avec debuff de cible | 5211, 6798, 8983 | sort connu 5211 ; O | grisé en recharge 1 min ; étourdissement posé : lueur ; bleu sans rage | recharge acquise, debuff à tester, ID d'aura à confirmer |
| Growl | reprendre l'aggro | Cooldown Progress, dual avec debuff de cible | 6795 (sort ; aura de cible supposée identique) | sort connu 6795 ; O | grisé en recharge 8 s ; actif sur la cible : lueur ; rouge hors portée | recharge acquise, debuff à tester, ID d'aura à confirmer |
| Primal Bite | attaque à recharge courte | Cooldown Progress | 407995, 1238069, 1238070, 1238073 | sort connu 407995 ; O | grisé en recharge 6 s ; bleu sans rage | à tester |
| Enrage | gagner de la rage, avant un pull | Cooldown Progress, dual avec buff joueur | 5229 (sort ; aura non vérifiée) | sort connu 5229 ; O | grisé en recharge 1 min ; actif : lueur, durée 10 s | à tester, ID d'aura à confirmer |

Variante H et E (lanceur et Moonkin), 6 icônes :

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Moonfire | poser le DoT | `secretAura` cible HARMFUL, dual avec portée et mana | 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 | sort connu 8921 ; H, E | actif : durée, rouge sous 3 s ; absent : grisé alpha 0,5 ; rouge hors portée ; bleu sans mana | type acquis, ID d'aura à confirmer |
| Insect Swarm | poser le second DoT | idem | 5570, 24974, 24975, 24976, 24977 | sort connu 5570 (talent) ; H, E | idem | idem |
| Starfire | sort principal, cast long | Cooldown Progress | 2912, 8949, 8950, 8951, 9875, 9876, 25298 | sort connu 2912 ; H, E | rouge hors portée ; bleu sans mana | acquis (type) |
| Wrath | sort de remplissage | Cooldown Progress | 5176, 5177, 5178, 5179, 5180, 6780, 8905, 9912 | sort connu 5176 ; H, E | idem | acquis (type) |
| Faerie Fire | baisser l'armure de la cible | `secretAura` cible HARMFUL, dual avec mana | 770, 778, 9749, 9907 | sort connu 770 ; H, E | actif : durée ; absent : grisé alpha 0,5 | type acquis, ID d'aura à confirmer |
| Hurricane | zone canalisée | Cooldown Progress | 16914, 17401, 17402 | sort connu 16914 ; H, E | bleu sans mana (880 mana et plus) | acquis (type) |

Variante R (Restauration), 6 icônes :

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Rejuvenation | HoT de base | `secretAura` cible HELPFUL joueur, dual avec mana | 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 | sort connu 774 ; R | actif : durée ; absent : grisé alpha 0,5 ; bleu sans mana | type acquis, ID d'aura à confirmer |
| Regrowth | HoT et soin direct | idem | 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 | sort connu 8936 ; R | idem | idem |
| Wild Growth | soin de zone | Cooldown Progress | 408120, 1238214, 1238215 | sort connu 408120 ; R | grisé en recharge 6 s ; bleu sans mana | à tester |
| Swiftmend | consommer un HoT pour un soin immédiat | Cooldown Progress + Action Usable | 18562 | sort connu 18562 ; R | grisé en recharge 15 s ; grisé si inutilisable (aucun HoT sur la cible) | recharge acquise, usable à tester |
| Healing Touch | gros soin direct | Cooldown Progress | 5185, 5186, 5187, 5188, 5189, 6778, 8903, 9758, 9888, 9889, 25297 | sort connu 5185 ; R | bleu sans mana ; rouge hors portée | acquis (type) |
| Tranquility | soin de groupe canalisé | Cooldown Progress | 740, 8918, 9862, 9863 | sort connu 740 ; R | grisé en recharge 5 min ; bleu sans mana | acquis (type) |

Total Principal : 27 icônes définies, jamais plus de 8 chargées en même temps.

### 2.4 Débordement (y -30, icônes 36)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Ravage | ouverture furtive de face | Cooldown Progress + second trigger Prowl joueur présent, mode « tous » | 6785, 6787, 9866, 9867 | sort connu 6785 ; C | visible seulement sous Prowl ; bleu sans énergie ; rouge hors portée | à tester |
| Pounce | ouverture furtive étourdissante | idem | 9005, 9823, 9827 | sort connu 9005 ; C | idem | à tester |

Aucune variante n'a plus de 8 icônes en Principal. Le Débordement sert aux ouvertures furtives du Chat, qui sortent
du Principal pour ne pas pousser Shifting Power hors des 8. Prowl : sorts 5215, 6783, 9913 ; ID d'aura à confirmer.

### 2.5 Utilitaires (y -120, icônes 32, alpha 0,4 hors combat et sans cible)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Barkskin | réduire les dégâts reçus | Cooldown Progress, dual avec buff joueur | 22812 | sort connu 22812 ; toutes formes | grisé en recharge 1 min ; actif : lueur, durée 15 s | à tester (forme requise inconnue) |
| Innervate | rendre de la mana | Cooldown Progress, dual avec buff joueur ou allié | 29166 | sort connu 29166 | grisé en recharge 6 min ; actif sur soi ou un allié : lueur, durée 20 s | à tester (unité de groupe pour l'allié) |
| Nature's Swiftness | cast instantané | Cooldown Progress, dual avec buff joueur | 17116 | sort connu 17116 | grisé en recharge 3 min ; actif : lueur | à tester |
| Rebirth | résurrection en combat | Cooldown Progress | 20484, 20739, 20742, 20747, 20748 | sort connu 20484 | grisé en recharge 30 min ; bleu sans mana | acquis (type) |
| Nature's Grasp | racines sur les coups reçus | Cooldown Progress, dual avec buff joueur | 16689, 16810, 16811, 16812, 16813, 17329 | sort connu 16689 | grisé en recharge 1 min ; buff posé : lueur ; bleu sans mana | à tester (talent « absent » mais sorts présents) |
| Feral Charge | immobiliser ou interrompre à distance | Cooldown Progress | 1238122 (aura 19675) | sort connu 1238122 ; O | grisé en recharge 15 s ; rouge hors portée 25 m ; bleu sans rage | à tester |
| Challenging Roar | forcer les mobs sur soi | Cooldown Progress | 5209 | sort connu 5209 ; O | grisé en recharge 10 min ; bleu sans rage | acquis (type) |
| Frenzied Regeneration | soigner en convertissant la rage | Cooldown Progress, dual avec buff joueur | 22842 | sort connu 22842 ; O | grisé en recharge 3 min ; actif : lueur, durée 10 s | à tester |
| Dash | déplacement rapide | Cooldown Progress, dual avec buff joueur | 1850, 9821 | sort connu 1850 ; C | grisé en recharge 5 min ; actif : lueur | à tester |
| Cower | baisser sa menace | Cooldown Progress | 8998, 9000, 9892 | sort connu 8998 ; C | grisé en recharge 10 s ; bleu sans énergie | acquis (type) |

Dix auras. Le druide n'a pas d'interruption en Classic : Bash (Principal Ours) et Feral Charge en tiennent lieu.

### 2.6 Entretien (y -160, icônes 32)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Forme Chat | savoir si l'on est en forme | `secretAura` joueur HELPFUL | 768 | sort connu 768 | actif : lueur ; absent : grisé alpha 0,5 | à tester (ID d'aura) |
| Forme Ours | idem | `secretAura` joueur HELPFUL | 5487, 9634 | sort connu 5487 | idem | à tester |
| Forme Moonkin | idem | `secretAura` joueur HELPFUL | 24858 ; Moonkin Aura 24907 ; passif 24905 | sort connu 24858 ; E | idem | à tester, ID à confirmer |
| Prowl actif | savoir si l'on est furtif avant Ravage ou Pounce | `secretAura` joueur HELPFUL, dual avec Cooldown Progress | 5215, 6783, 9913 | sort connu 5215 ; C | actif : lueur ; en recharge 10 s : grisé | à tester, ID d'aura à confirmer |

Quatre auras. Une seule icône de forme à liste d'IDs (768, 5487, 9634, 24858) est possible si les trois icônes
prennent trop de place : à tester. Le choix de la bonne forme évite un powershift raté ; les formes Voyage et Aquatique ne changent aucune
décision (exclues, section 5).

### 2.7 Barres (Ressource, Secondaire, Incantation)

| Barre | Rangée | Décision | Trigger Musca | Chargement | Style | État |
|---|---|---|---|---|---|---|
| Mana | Ressource | gérer la mana (H, E, R) | Power mana, joueur | H, E, R : formes absentes | 390x18, bleu, texte `%p` | type acquis |
| Énergie | Ressource | cadence du Chat | Power énergie (type 3), second trigger forme Chat | C | 390x18 jaune, texte `%c` | à tester (visibilité en combat) |
| Rage | Ressource | cadence de l'Ours | Power rage (type 1), second trigger forme Ours | O | 390x18 rouge, texte `%c` | à tester |
| Mana (forme) | Ressource, moitié droite | pouvoir sortir de forme ou powershifter | Power mana, joueur | C, O | 126x18 bleu, à côté d'Énergie ou de Rage (260 px) ; couleur différente à 85 % de mana ou plus : bloqué, condition sur une puissance secrète | à tester (barre), bloqué (seuil) |
| Points de combo | Secondaire | choisir Rip ou Ferocious Bite | Power combo (type 4), 5 segments, seuil « à partir de N » | C | 5 segments 390x10, couleur « haute » à 4 points, lueur et couleur « pleine » à 5 | à tester |
| Règle des 5 s | Secondaire | savoir quand la mana revient | Spell Cast Succeeded, durée fixe 5 s | H, E, R | barre 390x10 | à tester |
| Incantation | Incantation | suivre un cast ou une canalisation | trigger natif de lancer du joueur | H, E, R (aussi sorti de forme) | 390x16, visible pendant un cast | à tester (trigger natif à vérifier) |

Sept barres. La règle des 5 s compare par nom de sort : l'ID de rang 1 suffit pour tous les rangs.

## 3. Variantes : échanges d'auras et chargement

- Forme : Chat charge le jeu C ; Ours charge le jeu O ; sans forme charge H, E ou R. Moonkin charge E.
- Chargement de forme : trigger Stance/Form/Aura sur les icônes, en second trigger, mode « tous ». La
  condition `formID` manque dans Musca (suivi de `PLAN-AURAS-CLASSES.md`) : ne pas l'utiliser.
- Filtre de secours des formes, celui de la v1 : type de puissance primaire (énergie = Chat, rage = Ours, mana = le
  reste). Il ne sépare pas Moonkin de Restauration : `spellknown` s'en charge.
- Séparation H, E et R sans forme : H et E chargent sans Swiftmend connu ; R charge avec Swiftmend (18562) connu. Le
  chargement « non connu » est à vérifier dans Musca. Si absent : H et E restent chargés pour tous les lanceurs et R
  s'ajoute, ce qui fait 12 icônes en Principal pour un Restauration. Dans ce cas, cacher H et E avec une option.
- Dire Bear (9634) remplace Bear (5487) au niveau 40 : l'aura de forme Ours porte les deux IDs.
- Les auras de talent (Clearcasting, Nature's Grace, Eclipse, Insect Swarm, Shifting Power, Primal Bite, Feral
  Charge, Berserk) chargent par `spellknown` : une icône apparaît dès que le sort est appris.
- Utilitaires de lanceur (Innervate, Nature's Swiftness, Rebirth, Barkskin, Nature's Grasp) restent chargés dans
  toutes les formes. Les sorts utilisables en forme sans quitter la forme sont à tester (section 7).

## 4. Rappels

| Rappel | Trigger | Hors combat | Zone de repos |
|---|---|---|---|
| Mark of the Wild | `secretAura` absent, ou reste < 5 min | oui | masqué |
| Thorns | `secretAura` absent | oui | masqué |
| MANA BAS | Power mana, sous 20 % | oui | masqué |

Pas de rappel de forme, de Prowl, de familier ou de munition : le druide n'en a pas besoin. Pas de rappel Omen of
Clarity : c'est un talent passif, pas un buff à maintenir (le rappel v1 est retiré).

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Tiger's Fury | absent en jeu sur Forever : 5217 et 417045 jamais appris, aucun sort attribué. Exclu |
| Faerie Fire (Feral) | absent du DB2 70245, exclu. Le Faerie Fire de lanceur (770 et suivants) reste, en H et E |
| Starfall, Force of Nature, Cyclone, Mangle, Savage Roar | absents de `Classes/Druid.md` : absent du DB2, exclu |
| Tick d'énergie | demande le journal de combat, ou la comparaison de l'énergie à sa valeur précédente (secrète en combat). Bloqué |
| Compteur de powershift | compare la mana, secrète en combat. Bloqué |
| Tick de mana | journal de combat. Bloqué |
| Minuteur de Rip, de Rake ou de Lacerate calculé par le joueur | bloqué ; seul le temps restant de l'aura de cible est affiché |
| Lueur ou son piloté par le temps restant d'un debuff, ou par les charges de Lacerate | valeur secrète en combat. Bloqué ; seule la couleur du texte suit un seuil, à tester |
| Furor, Blood Frenzy, Natural Reaction (procs de rage, d'énergie, de point de combo) | aucune décision à changer, IDs non départagés. Exclu |
| Leader of the Pack | redondant avec l'indicateur de forme, aucune décision. Exclu |
| Tree Form | IDs non départagés (775, 22688, 3122, 5420, 439733, 439745, 439766, 439734), talent non confirmé. Exclu jusqu'à confirmation |
| Formes Voyage (783) et Aquatique (1066) | aucune décision. Exclues |
| Prowl (icône de recharge seule) | recharge 10 s sans effet sur la décision ; l'aura Prowl sert de condition (Ravage, Pounce) et d'icône d'état dans Entretien |
| Icône de présence d'Omen of Clarity | le passif 16864 est suivi, non le proc 16870 ; talent donné absent de Forever. Exclu (le proc reste dans Effets) |
| Cure Poison, Abolish Poison, Remove Curse | aucune recharge à suivre, état des debuffs du joueur secret en combat. Exclus |
| Swing main hand (Chat, Ours) | aucune décision dans ce pack ; Swing Timer acquis si on le veut plus tard |
| Soothe Animal, Teleport: Moonglade, Revive, Healing Touch en combat solo hors Restauration | hors boucle de jeu ; Revive suit déjà une incantation |
| Hurricane comme recharge | pas de recharge. Reste une icône de mana dans H et E |

## 6. IDs à confirmer en jeu

Le DB2 ne donne que l'ID du sort lancé pour la plupart des auras. Commande de relevé : `/run` sur le buff ou debuff
posé, ID lu dans la liste d'auras (agent `wow-api` avant la commande), puis noté dans `Classes/Druid.md`.

| Aura | IDs candidats | À vérifier |
|---|---|---|
| HoT : Rejuvenation, Regrowth, Wild Growth | ID du sort lancé | l'aura porte-t-elle le même ID ? |
| DoT : Moonfire, Insect Swarm, Rake, Rip, Lacerate | ID du sort lancé | idem, sur la cible ; Pounce : 9007, 9824, 9826 |
| Faerie Fire, Demoralizing Roar, Entangling Roots, Hibernate | ID du sort lancé | idem ; racines de Nature's Grasp : 19970 à 19975 |
| Mark of the Wild, Gift of the Wild, Thorns | ID du sort lancé | idem ; l'aura de Gift est-elle celle de Mark ? |
| Enrage, Frenzied Regeneration, Barkskin, Innervate, Nature's Swiftness, Dash | ID du sort lancé | idem sur le joueur |
| Clearcasting | 16870 (DB2) ; homonymes 467735, 12536, 16246, 457342 | l'aura existe-t-elle ? Omen of Clarity 16864 est-il appris ? |
| Nature's Grace | 16886 (talent 16880) | durée 3 s, effet de proc |
| Eclipse | 408248, 408255, 409813, 441260, 1286115 | lequel apparaît sur le joueur, quel nombre de charges |
| Berserk | 417141 (sort) ; 14 homonymes SpellName | le sort existe-t-il, quel ID d'aura |
| Moonkin Form | 24858 (forme), 24907 (aura), 24905 (passif) | lequel est l'aura visible |
| Forme Chat, Forme Ours, Dire Bear | 768 ; 5487, 9634 | ID d'aura de la forme |
| Prowl | 5215, 6783, 9913 | ID d'aura pour la condition de Ravage et Pounce |
| Shifting Power | 1322605 ; effets 1291059, 1322670 | sort lancé en Chat ; effet de recharge |
| Lacerate | 414644, 1235826, 1235827 | charges et durée |
| Feral Charge | 1238122, aura 19675 | portée 25 m ; effet de l'interruption ; 16979 est l'ID du talent (Talent.csv), jamais un `spellknown` |
| Growl, Bash (debuffs de cible) | 6795 ; 5211, 6798, 8983 | l'aura de cible porte-t-elle l'ID du sort ? |
| Nature's Grasp (buff joueur) | 16689, 16810 à 16813, 17329 | l'aura joueur porte-t-elle l'ID du sort ? |

## 7. Tests en jeu propres au druide

À ajouter à la grille de `PLAN-AURAS-CLASSES.md` section 4.

1. Forme : entrer et sortir de Chat, Ours et Moonkin hors combat, puis en combat. Seul le jeu de la forme s'affiche.
2. Powershift en combat : sortir de forme et y revenir. Les icônes se rechargent sans erreur, la barre de mana en
   forme apparaît.
3. Chargement par puissance primaire : énergie, rage et mana lisibles en combat pour la sélection de forme.
4. Barre de mana à côté d'Énergie et de Rage : visible en Chat et en Ours, hors combat et en combat.
5. Points de combo : 5 segments en Chat ; changement de cible ; mort de la cible ; lueur au 5e point.
6. Rake et Rip : état « actif » puis « absent » en combat, dual durée et portée. Couleur de texte sous 3 s.
7. Maul en file : lueur après la mise en file, retrait au coup.
8. Ravage et Pounce : visibles seulement sous Prowl ; disparaissent à la sortie de furtivité, y compris en combat.
9. Berserk, Shifting Power, Primal Bite, Feral Charge : sorts appris ou non selon les talents du personnage.
10. Clearcasting et Nature's Grace : proc et durée. Si Omen of Clarity est absent en jeu, le retrait propre de l'icône.
11. Eclipse : trouver l'aura, vérifier les charges.
12. Swiftmend : grisé sans HoT sur la cible, normal avec HoT (test Action Usable).
13. HoT sur cible amie : Rejuvenation et Regrowth sur soi, puis sur un allié, puis changement de cible.
14. Règle des 5 s : se relance sur un rang haut de Healing Touch, Regrowth, Rejuvenation, Wrath, Starfire,
    Moonfire.
15. Incantation : Starfire (3,5 s), Healing Touch ; canalisation de Hurricane et de Tranquility.
16. Utilitaires en forme : Barkskin, Innervate, Nature's Swiftness, Rebirth utilisables ou non selon la forme.
17. `/reload` en forme, en combat : disposition, rangée de la forme et barres conservées.
18. Personnage bas niveau (10, 20, 30) : rangs bas, sorts non appris absents, formes absentes avant leur niveau.
19. Lueurs sur cible : Bash et Growl allument l'icône tant que le debuff est sur la cible ; Nature's Grasp tant que
    le buff est posé ; Innervate lancé sur un allié.
20. Mana en forme : visible seulement en Chat et en Ours, couleur fixe.

## 8. Écart avec la v1 (`PackDruide.lua`)

**Ajouts**

- Rangées Effets, Débordement, Utilitaires et Entretien au sens du socle v2, en plus des Rappels et du Principal.
- Icônes de rotation du Chat : Rake, Rip, Ferocious Bite, Shred, Claw, Berserk, Shifting Power.
- Icônes de rotation de l'Ours : Swipe, Lacerate, Demoralizing Roar, Primal Bite.
- Icônes de rotation du lanceur : Starfire, Wrath, Moonfire, Insect Swarm, Faerie Fire, Hurricane.
- Icônes de Restauration : Rejuvenation, Regrowth, Wild Growth, Swiftmend, Healing Touch, Tranquility.
- Ravage et Pounce sous Prowl (Débordement). Pounce (saignement) en Effets.
- Eclipse, Nature's Grace et Clearcasting dans Effets, avec lueur.
- Indicateurs de forme dans Entretien.
- Barre de mana en forme côte à côte avec Énergie et Rage. Barre d'Incantation (barre absente en v1).
- Points de combo en 5 segments (la v1 a une seule barre de type 4).
- Variantes H, E, R, C, O : une aura par variante dans la même rangée.

**Changements**

- Rake, Rip, Moonfire, Insect Swarm, Faerie Fire, Demoralizing Roar, Entangling Roots, Hibernate : de debuffs sans
  condition à icônes duales (durée, absence grisée, portée, ressource).
- Barkskin, Innervate, Nature's Swiftness, Frenzied Regeneration, Enrage, Dash : les paires « recharge » et
  « (actif) » de la v1 fusionnent en une icône duale.
- Rejuvenation et Regrowth : de buffs joueur à HoT de la cible amie, dans le Principal Restauration.
- Mark of the Wild : seuil « reste < 5 min » ajouté en plus de l'absence.
- Règle des 5 s : la v1 liste les rangs 1 (5176, 2912, 8921, 5570, 5185, 8936, 774) ; suffisant, le trigger
  compare par nom.
- Chargement de forme par second trigger de forme en plus du filtre de puissance primaire.

**Retraits**

- Hurricane de la liste des cooldowns : pas de recharge, devient une icône de mana de H et E.
- Rappel Omen of Clarity : talent passif, aucune décision.
- Les doublons « (actif) » des buffs Enrage, Frenzied Regeneration, Barkskin, Innervate, Nature's Swiftness et Dash.
- Growl, Bash, Cower : de « rotation » et « cooldowns » v1 aux rangées Principal et Utilitaires v2.

## 9. Besoins du générateur propres au druide

Hors de la section 5 de `PLAN-AURAS-V2.md`. Seulement les vrais besoins.

1. **Second trigger générique** : `PackBuilder.lua` n'en a qu'un, le trigger « tous » de `gate` (puissance primaire).
   Il faut une option `form` (Stance/Form/Aura, IDs de forme) et une option `requireAura` (Prowl joueur présent).
   Sert à Ravage, Pounce, Énergie, Rage et au chargement par forme.
2. **Barres côte à côte** dans Ressource : Énergie ou Rage (260 px) plus mana (126 px). Option de largeur et
   décalage par barre.
3. **Segments de combo** : 5 auras à seuil « à partir de N » (`use_nativeThresholdAbove` existe pour Power).
   Une table `segments = 5` pour les générer, avec lueur au dernier. Deux seuils de couleur par segment (4 puis 5
   points).
4. **Chargement par sort inconnu** (Swiftmend absent pour H et E) : option `unknown`, ou option utilisateur de
   repli. Condition « non connu » à vérifier dans Musca.
5. **Icône duale sur cible amie** : option d'unité et de filtre pour l'aura de HoT (`target`, `HELPFUL`), au lieu
   du seul `HARMFUL` de la cible actuelle. Ajouter l'unité de groupe pour Innervate sur un allié.

Pas de besoin d'indicateur de posture : les formes sont des auras joueur, couvertes par `secretAura`. Pas de barre
de familier. Le coup en file (Maul) existe déjà via `queued`.

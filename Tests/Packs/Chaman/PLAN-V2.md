# Plan v2 du pack Chaman (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Plan seulement : aucun code, aucune chaîne d'import.

Socle : `PLAN-AURAS-V2.md` (rangées, style, états). Règles v1 : `PLAN-AURAS-CLASSES.md`. IDs et présence des sorts sur
Forever : `Classes/Shaman.md` (DB2 1.60.1.70245), qui fait foi. Idées seulement depuis Luxthos, Fojji et les packs
Wago : aucun nom, code ou chaîne repris.

États : **acquis** (testé en jeu), **à tester** (trigger natif, pas encore vu en combat sur Forever), **bloqué**
(journal de combat ou lecture de valeur secrète).

## 1. Sources et spécialisations couvertes

Arbres Classic du chaman sur Forever : Elemental Combat (16 talents), Enhancement (18), Restoration (16).

| Variante | Style de jeu | Clé de chargement | Cœur de la rotation |
|---|---|---|---|
| Élémentaire | solo, donjon, raid dégâts à distance | `spellknown` Lava Burst 408490 (talent) | Lava Burst, Flame Shock, Earth Shock, Chain Lightning |
| Amélioration | solo (niveaux), donjon, raid mêlée | `spellknown` Stormstrike 17364 (talent) | Stormstrike, Lava Lash, chocs, Fire Nova |
| Restauration | donjon, raid soigneur | `spellknown` Improved Healing Wave 16182 | Healing Wave, Chain Heal, Riptide, Earth Shield |
| Base (sans talent clé) | leveling jusqu'aux premiers talents | aucune clé de spé | Earth Shock, Frost Shock, Fire Nova, Chain Lightning |

Un hybride voit l'union des variantes qu'il a apprises. Si l'union dépasse 8 icônes dans Principal, l'excédent
tombe dans Débordement, dans l'ordre de priorité des tableaux. Le niveau n'entre jamais dans le chargement : les
rangs bas et les sorts non appris restent absents par `spellknown`.

Sources lues : `Classes/Shaman.md` (IDs), `PackChaman.lua` et `NOTES.md` (v1), `RECHERCHE-AURAS-CLASSES.md`
(Maelstrom Weapon, totems, imbues), `ANALYSE-AURAS-LUXTHOS.md` (gabarit commun), `ANALYSE-AURAS-FOJJI.md`
(section 7, extras chaman : swing, rappel Ankh, barres de totem), `ANALYSE-AURAS-WAGO.md` (comparatif chaman).

## 2. Tables par rangée

Colonnes : aura, décision changée, trigger Musca, IDs, chargement, conditions et style, état. Tous les rangs sont
listés. Les triggers sont ceux de `PLAN-AURAS-CLASSES.md` section 3.

### 2.1 Rappels (hors combat, cachés en zone de repos)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Bouclier de foudre manquant | poser le bouclier avant le pull | `secretAura`, joueur, absent | 324, 325, 905, 945, 8134, 10431, 10432 | `spellknown` 324 ; Water Shield 408510 non connu | icône 32, alpha 0,4 hors zone utile, texte rouge sous 30 s si présent | acquis (manquant testé) |
| Bouclier d'eau manquant | idem, soigneur | `secretAura`, joueur, absent | 408510 (sort), 408511, 409941 (candidats) | `spellknown` 408510 | idem | à tester |
| Imbue arme principale manquante | rebuffer l'arme | Weapon Enchant, main, absent | sorts 8017-8019, 10399, 16314-16316 (Rockbiter) ; 8024, 8027, 8030, 16339, 16341, 16342 (Flametongue) ; 8033, 8038, 10456, 16355, 16356 (Frostbrand) ; 8232, 8235, 10486, 16362 (Windfury) | `spellknown` 8017, arme équipée | texte rouge sous 5 min (reste de l'imbue) | acquis |
| Imbue arme secondaire manquante | idem main gauche | Weapon Enchant, off, absent | mêmes sorts | `spellknown` 8017, arme en main gauche, variante Amélioration | idem | à tester |
| Mana basse | économiser ou boire | Power, joueur, mana, Show only below 20 % | aucun | classe | texte « MANA BAS », pas de glow | acquis |
| Ankh manquante | racheter l'objet de Reincarnation | Item Count, objet de Reincarnation, sous 5 | ID d'objet à confirmer en jeu | `spellknown` 20608 | alpha 0,75, zone de repos masquée (ville) | à tester |

Le rappel du Bouclier de foudre se charge seulement si Water Shield 408510 n'est pas connu (besoin builder 2,
section 9).

### 2.2 Effets (icônes 32, procs, buffs courts, debuffs posés)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Horion de flammes sur la cible | relancer le DoT | `secretAura`, cible, nocif, posé par le joueur | 8050, 8052, 8053, 10447, 10448, 29228 | `spellknown` 8050 | actif : glow pixel ; absent : désaturé alpha 0,5 ; texte rouge sous 3 s | acquis |
| Frappe-tempête sur la cible | lancer le sort de nature amplifié | `secretAura`, cible, nocif, posé par le joueur | 17364 (410156 candidat) | variante Amélioration | actif : glow pixel ; texte rouge sous 3 s | à tester |
| Idées claires (Elemental Focus) | sort gratuit | `secretAura`, joueur, bénéfique | 16246 (déclenché par 16164) | `spellknown` 16164 | glow pixel à l'apparition | à tester |
| Rafale (Flurry) | enchaîner les coups | `secretAura`, joueur, bénéfique | 16257, 12966, 17687 (candidats) | `spellknown` 16256 | glow pixel, texte de charges | à tester |
| Maelstrom Weapon (charges) | lancer un sort instantané | `secretAura`, joueur, bénéfique | 408498, 408505, 409946, 408501 (candidats) | variante Amélioration | texte de charges `%s` ; glow à l'apparition | à tester |
| Rapidité de la nature active | enchaîner le soin ou l'éclair | `secretAura`, joueur, bénéfique | 16188 | `spellknown` 16188 | glow pixel ; sert de repli si l'icône à double état échoue (2.5) | à tester |
| Earth Shield sur la cible | refaire le bouclier du tank | `secretAura`, cible amicale, bénéfique | 408514, 408519 (sorts), aura à confirmer | `spellknown` 408514, variante Restauration | glow pixel ; texte de charges ; rouge sous 10 s | à tester |
| Marée de mana active (durée 12 s) | caler les gros soins | Totem, emplacement Eau, sort 16190, 17354, 17359 | 16190, 17354, 17359 | `spellknown` 16190 | glow pixel pendant le totem | à tester |

Les pistes écartées sont en section 5.

### 2.3 Principal (icônes 44, 8 au plus par variante)

Trigger de toutes les lignes : Cooldown Progress (Spell), recherche par nom donc rang indifférent. Conditions
communes : grisé en recharge, rouge hors de portée, bleu si mana manque, alpha 0,4 hors combat et sans cible.

**Variante Élémentaire (6)**

| Aura | Décision | IDs | Chargement | Style | État |
|---|---|---|---|---|---|
| Lava Burst | lancer en priorité | 408490, 1238299, 1238300 (408491, 1238373, 1238376 non retenus) | `spellknown` 408490 | recharge seule, pas de glow | à tester |
| Horion de terre | interrompre ou dégâts | 8042, 8044, 8045, 8046, 10412, 10413, 10414 | `spellknown` 8042 | rouge hors portée | acquis |
| Chaîne d'éclairs | dégâts de zone | 421, 930, 2860, 10605 (408479-408484 rangs Forever) | `spellknown` 421 | bleu si mana manque | acquis (v1 ; absente niveau 17 normal) |
| Horion de givre | ralentir ou finir | 8056, 8058, 10472, 10473 | `spellknown` 8056 | idem | acquis |
| Nova de feu | dégâts de zone proches | 408341, 408342, 408343, 408344, 408345 | `spellknown` 408341 | idem | acquis |
| Molten Blast | dégâts à distance | 425339 | `spellknown` 425339 | recharge seule, pas de minuteur de proc (voir 5) | à tester |

**Variante Amélioration (8)**

| Aura | Décision | IDs | Chargement | Style | État |
|---|---|---|---|---|---|
| Frappe-tempête | lancer à chaque recharge (8 s) | 17364 | `spellknown` 17364 | rouge hors portée mêlée | acquis |
| Lava Lash | frapper main gauche | 408507 | `spellknown` 408507 | idem | à tester |
| Horion de terre | interrompre | rangs 2.3 Élémentaire | `spellknown` 8042 | idem | acquis |
| Horion de givre | ralentir | rangs 2.3 Élémentaire | `spellknown` 8056 | idem | acquis |
| Nova de feu | zone | rangs 2.3 Élémentaire | `spellknown` 408341 | idem | acquis |
| Molten Blast | burst | 425339 | `spellknown` 425339 | idem | à tester |
| Rage of the Farseer | sort de talent à effet à confirmer | 425336 | `spellknown` 425336 | idem | à tester |
| Chaîne d'éclairs | zone, usage Maelstrom Weapon | rangs 2.3 Élémentaire | `spellknown` 421 | idem | acquis |

**Variante Restauration (6)**

| Aura | Décision | IDs | Chargement | Style | État |
|---|---|---|---|---|---|
| Vague de soins | soin de base | 331, 332, 547, 913, 939, 959, 8005, 10395, 10396, 25357 | `spellknown` 16182 | bleu si mana manque | à tester (sort sans recharge) |
| Vague de soins inférieure | soin rapide | 8004, 8008, 8010, 10466, 10467, 10468 | `spellknown` 16182 | idem | à tester |
| Salve de guérison (Chain Heal) | soin de groupe | 1064, 10622, 10623 | `spellknown` 1064 | idem | à tester |
| Riptide | soin plus recharge | 408521, 1239242, 1239243 | `spellknown` 408521 | rouge hors portée | à tester |
| Healing Rain | zone de soins | 415236, 415242 | `spellknown` 415236 | bleu si mana manque | à tester |
| Horion de terre | interrompre | rangs 2.3 Élémentaire | `spellknown` 8042 | rouge hors portée | acquis |

Un sort sans recharge (soins) ne montre que l'état du GCD, de la portée et de la mana. À valider en jeu avant de
le garder.

### 2.4 Débordement (icônes 36)

Vide par construction chez le chaman : chaque variante tient en 8 icônes ou moins. Elle sert uniquement à
l'hybride qui dépasse 8 (union des variantes, section 1).

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Sorts de Principal au-delà de 8 | arbitrer chez un hybride | Cooldown Progress | rangs de 2.3 | `spellknown` comme dans Principal | icône 36, mêmes conditions | à tester |

### 2.5 Utilitaires (icônes 32)

Trigger : Cooldown Progress (Spell), `showAlways` pour les gros cooldowns. Grisé en recharge, alpha 0,4 hors
combat et sans cible.

| Aura | Décision | IDs | Chargement | Style | État |
|---|---|---|---|---|---|
| Rapidité de la nature | soin ou éclair instantané | 16188 | `spellknown` 16188 | icône à double état (recharge, puis durée du buff, glow) ; sinon repli 2.2 | à tester (double état) |
| Totem de marée de mana | regain de mana du groupe | 16190, 17354, 17359 | `spellknown` 16190 | bleu si mana manque | acquis (recharge) |
| Totem de glèbe (Grounding) | absorber un sort | 8177 | `spellknown` 8177 | recharge 15 s | acquis |
| Totem lien terrestre | ralentir les poursuivants | 2484 | `spellknown` 2484 | recharge 15 s | à tester |
| Totem de griffe de pierre | bouclier et provocation | 5730, 6390, 6391, 6392, 10427, 10428 | `spellknown` 5730 | recharge 30 s | à tester |
| Projection totémique | replacer les totems | 437009 | `spellknown` 437009 | recharge 1 min | à tester |
| Rappel astral | retour à la pierre | 556 | `spellknown` 556 | recharge 15 min | à tester |
| Dissipation (Purge) | retirer un buff ennemi | 370, 8012 | `spellknown` 370 | rouge hors portée, bleu sans mana | à tester |
| Totem leurre (Decoy) | détourner un coup | 425874 | `spellknown` 425874 | recharge à confirmer | à tester |
| Réincarnation | savoir si l'Ankh est prête | 21169 (sort), 20608 (passif) | `spellknown` 20608 | recharge visible | à tester |

### 2.6 Entretien (icônes 32, buffs longs, imbues, totems)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Totem de feu | relancer le totem | Totem, emplacement 1 | sorts 3599, 6363, 6364, 6365, 10437, 10438 (Searing) ; 8190, 10585, 10586, 10587 (Magma) ; 8227, 8249, 10526, 16387 (Flametongue) ; 8184, 10537, 10538 (Résistance feu) | classe | toujours visible, grisé alpha 0,5 si vide ; texte jaune sous 5 s ; glow tant que le buff est sur le joueur | acquis hors combat ; combat à tester |
| Totem de terre | idem | Totem, emplacement 2 | 8071, 8154, 8155, 10406, 10407, 10408 (Stoneskin) ; 8075, 8160, 8161, 10442, 25361 (Strength of Earth) ; 5730... (Stoneclaw) ; 8143 (Tremor) ; 2484 (Earthbind) | classe | idem | idem |
| Totem d'eau | idem | Totem, emplacement 3 | 5394, 6375, 6377, 10462, 10463 (Healing Stream) ; 5675, 10495, 10496, 10497 (Mana Spring) ; 16190, 17354, 17359 (Mana Tide) ; 8166, 8170 (nettoyage) ; 8181, 10478, 10479 (Résistance givre) | classe | idem | idem |
| Totem d'air | idem | Totem, emplacement 4 | 8512, 10613, 10614 (Windfury) ; 8835, 10627, 25359 (Grace of Air) ; 15107, 15111, 15112 (Windwall) ; 10595, 10600, 10601 (Résistance nature) ; 8177 (Grounding) ; 6495 (Sentry) | classe | idem | idem |
| Bouclier de foudre | entretenir le bouclier | `secretAura`, joueur | 324, 325, 905, 945, 8134, 10431, 10432 (26545 déclenché) | `spellknown` 324 ; Water Shield inconnu | charges `%s` ; texte rouge sous 60 s ; glow à l'apparition | acquis |
| Bouclier d'eau | idem, mana | `secretAura`, joueur | 408510, 408511, 409941 (candidats) | `spellknown` 408510 | charges `%s` ; texte rouge sous 60 s | à tester |
| Imbue arme principale | durée de l'imbue | Weapon Enchant, main | sorts de 2.1 | `spellknown` 8017 | texte rouge sous 5 min | acquis |
| Imbue arme secondaire | durée de l'imbue | Weapon Enchant, off | sorts de 2.1 | `spellknown` 8017, arme main gauche | texte rouge sous 5 min | à tester |

### 2.7 Barres

**Ressource (390x18)**

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mana | gérer la mana | Power, joueur, mana (type 0) | aucun | classe | bleu, texte `%p` ou `%c` natif ; texte orange sous 30 %, rose sous 15 % par seuil natif | acquis |

**Secondaire (390x10 ou 5 segments)**

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Règle des 5 s | savoir quand la mana revient | Spell Cast Succeeded, sorts à mana, durée fixe 5 s | 331, 8004, 1064, 403, 421, 8042, 8050, 8056 (liste v1, à étendre aux rangs) | classe | barre fine grise, cachée à mana pleine | à tester |
| Swing arme principale | caler les coups | Swing Timer, main | aucun | variante Amélioration | barre fine, couleur neutre | acquis |
| Swing arme secondaire | idem | Swing Timer, off | aucun | variante Amélioration, arme main gauche | barre fine | à tester |
| Maelstrom Weapon, 5 segments | décider d'un sort instantané | `secretAura` joueur, un segment par charge | 408498, 408505, 409946, 408501 (candidats) | variante Amélioration | 5 segments, seuil « Show at or above » | à tester |

**Incantation (390x16, visible pendant un cast)**

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Barre d'incantation joueur | interrompre ou annuler un cast | Cast, joueur | aucun | classe | rouge ; gris si non interruptible ; nom à gauche, temps à droite | acquis (barre de cast testée) ; trigger du builder à vérifier |

Barres de familier : aucune. Le chaman n'a pas de familier dans `Classes/Shaman.md`. Spirit of the Alpha (408696)
n'est pas décrit : exclu tant que son effet n'est pas lu en jeu.

## 3. Variantes par spécialisation, forme ou talent

| Aura | Base | Élémentaire | Amélioration | Restauration | Chargement |
|---|---|---|---|---|---|
| Lava Burst | non | oui | non | non | `spellknown` 408490 |
| Stormstrike, Lava Lash, Rage of the Farseer | non | non | oui | non | `spellknown` du sort |
| Soins (Vague, Inférieure, Chain Heal) | non | non | non | oui | `spellknown` 16182 ou 1064 |
| Riptide, Healing Rain, Earth Shield | non | non | non | oui | `spellknown` du sort |
| Idées claires | non | oui | oui | non | `spellknown` 16164 |
| Rafale, swing, Maelstrom segments | non | non | oui | non | `spellknown` 16256 ou 17364 |
| Bouclier de foudre (rappel et entretien) | oui | oui | oui | si Water Shield inconnu | `spellknown` 324, Water Shield non connu |
| Bouclier d'eau (rappel et entretien) | non | non | non | oui | `spellknown` 408510 |
| Imbue arme secondaire | non | non | oui | non | arme main gauche équipée |
| Marée de mana active, Earth Shield cible | non | non | non | oui | `spellknown` du sort |

Aucune forme ni posture chez le chaman. Ghost Wolf (2645) n'a pas de variante : exclu (section 5).

## 4. Rappels : liste, trigger, hors combat

| Rappel | Trigger | Quand |
|---|---|---|
| Bouclier de foudre | `secretAura` absent | hors combat, caché en zone de repos |
| Bouclier d'eau | `secretAura` absent | idem |
| Imbue principale | Weapon Enchant absent | idem |
| Imbue secondaire | Weapon Enchant absent | idem, variante Amélioration |
| Mana basse | Power sous 20 % | combat et hors combat, sans masquage |
| Ankh manquante | Item Count sous 5 | idem, masqué en repos hors ville |

Le masquage en zone de repos demande l'option de chargement du builder (point 5 du socle, à vérifier dans Musca).
Les rappels de totems manquants sont portés par les emplacements d'Entretien : pas de rappel séparé.

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Minuteur de Molten Blast ou de proc lié | journal de combat : bloqué |
| Compteurs de coups Windfury, compteurs de procs sans aura | journal de combat : bloqué |
| Tic de mana, tic d'énergie | journal de combat : bloqué |
| Texte de mana formaté par calcul (K, pourcentage mêlé) | comparaison Lua d'une valeur secrète : bloqué |
| Son ou lueur sur seuil de mana ou de charges | valeur secrète : bloqué |
| Power Surge (proc) | absent du DB2, exclu |
| Elemental Mastery (16166) | absent du DB2, exclu |
| Fire Nova Totem (1535) | absent du DB2, exclu (remplacé par Fire Nova 408341-408345) |
| Tranquil Air Totem | absent du DB2, exclu |
| Windfury Attack (aura de proc) | absent du DB2, exclu |
| Auras d'imbue (Rockbiter, Flametongue, Frostbrand, Windfury) | absent du DB2 : lecture par le trigger Weapon Enchant |
| Lightning Overload, Earthbound, Mental Dexterity, Mental Quickness, Shamanistic Focus, Improved Stormstrike | talents passifs sans aura utile : exclus |
| Frost Shock sur la cible | ralentissement : ne change pas une décision |
| Cure Poison, Cure Disease, Ghost Wolf, Far Sight, Water Breathing, Water Walking | hors combat ou sans décision de rotation : exclus |
| Riptide (HoT sur la cible) | aura non listée dans le DB2 : suivi par la recharge seulement |
| Focused Casting 27828, Elemental Devastation 30160 et 30165 | procs mineurs, IDs non départagés : exclus |
| Healing Way 29206, Ancestral Healing 16177 | buffs sur alliés mineurs : exclus |
| Barre de santé, curseur de mana, barres de totem 39x6 | hors socle commun : exclus |

## 6. IDs à confirmer en jeu

| Aura | Candidats (DB2) | À vérifier |
|---|---|---|
| Rafale | 16257, 12966, 17687 | `/dump` des auras du joueur après un crit en mêlée : lequel porte la hâte |
| Idées claires | 16246 | aura présente après un crit de sort, texte de durée |
| Maelstrom Weapon | 408498, 408505, 409946, 408501 (« Maelstrom Ready! ») | ID qui monte de 1 à 5 charges ; ID du proc prêt |
| Bouclier d'eau | 408510, 408511, 409941 | ID de l'aura sur soi, charges |
| Frappe-tempête | 17364, 410156 | aura sur la cible ou sur soi, durée 12 s |
| Aura du Bouclier de foudre | 324 acquis ; 26545 déclenché ; 26363-26370 | rangs hauts : l'ID d'aura suit-il le rang |
| Horion de flammes, rangs 2 à 6 | 8052, 8053, 10447, 10448, 29228 | ID d'aura du rang haut sur la cible |
| Totems : buffs sur le joueur | Windfury 8515, 10609, 10612 contre 8516, 10608, 10610 ; Stoneskin 28995 ; Mana Spring 24853 | ID du buff posé par chaque totem, pour le glow |
| Earth Shield | 408514, 408519 | sort contre aura, charges |
| Lava Burst | 408490, 1238299, 1238300 contre 408491, 1238373, 1238376 | série connue du joueur selon le rang |
| Healing Rain | 415236, 415242 | lancement contre effet au sol |
| Riptide | 408521, 1239242, 1239243 | rangs connus |
| Réincarnation | 20608 (passif), 21169 (sort) | lequel porte la recharge |
| Rage of the Farseer | 425336 | effet réel et type (sort, aura) |
| Molten Blast, Lava Lash, Decoy Totem | 425339, 408507, 425874 | sort bien connu sur Forever, recharge |
| Objet d'Ankh | non listé dans `Classes/Shaman.md` | ID d'objet pour Item Count |
| Rangs de Fire Nova | 408341-408345 | série apprise selon le niveau |

## 7. Tests en jeu propres au chaman

En plus de la grille commune de `PLAN-AURAS-CLASSES.md` section 4 :

1. Totems : poser les quatre, vérifier icône, durée, glow, grisé et alpha 0,5 quand l'emplacement est vide,
   y compris en combat.
2. Rappel du bouclier : le bouclier tombe en combat et se repose en combat (acquis pour 324, à refaire avec Water
   Shield).
3. Imbue : poser, laisser passer sous 5 min, retirer ; refaire sur la main gauche en Amélioration.
4. Double maniement : arme main gauche équipée, retirée, remise ; les rangées du swing et de l'imbue suivent.
5. Chocs : vérifier si les trois horions partagent une recharge de 6 s ou en ont chacun une.
6. Maelstrom Weapon : 1 à 5 charges, chute à 0 après dépense, segments et texte `%s` en combat.
7. Rafale et Idées claires : apparition au crit, durée, glow, disparition.
8. Frappe-tempête : aura sur la cible ou sur soi, texte de durée.
9. Earth Shield sur un allié ciblé, changement de cible, mort de la cible.
10. Règle des 5 s : la barre se relance à chaque cast à mana et se vide à 5 s.
11. Rapidité de la nature : icône à double état ou repli en Effets.
12. Rappel d'Ankh en ville, puis après usage de la Réincarnation.
13. Spécialisation : changer de talents, `/reload`, vérifier que seules les icônes de la variante restent.
14. Personnage bas niveau (niveau 17) : Chaîne d'éclairs et sorts de talent absents, pas de trou dans les rangées.

## 8. Écart avec la v1 (PackChaman.lua)

**Ajouter**

- Variantes Élémentaire, Amélioration et Restauration par `spellknown`.
- Sorts : Lava Burst, Lava Lash, Molten Blast, Rage of the Farseer, Riptide, Healing Rain, Vague de soins, Vague
  inférieure, Chain Heal, Earth Shield.
- Buffs : Bouclier d'eau (rappel et entretien), Maelstrom Weapon, Frappe-tempête sur la cible, Marée de mana
  active, Earth Shield sur la cible.
- Imbue arme secondaire (rappel et entretien), swing principal et secondaire, Maelstrom en 5 segments.
- Utilitaires : Totem lien terrestre, Griffe de pierre, Projection totémique, Rappel astral, Dissipation, Totem
  leurre, Réincarnation.
- Rappel d'Ankh par Item Count.
- Barre d'incantation joueur.
- Style commun : zoom 0,3, bordure, glow pixel, seuils de temps, alpha hors combat, rouge hors portée.

**Changer**

- Horion de flammes : sort de la rotation v1 vers Effets (débuff), sans icône de recharge dans Principal.
- Rapidité de la nature et Marée de mana : de Cooldowns v1 vers Utilitaires.
- Totems : de la rotation v1 vers Entretien, toujours visibles et grisés.
- Rappels : icônes à la place du texte, masquage en zone de repos.
- Règle des 5 s : liste de sorts étendue à tous les rangs.
- Idées claires et Rafale : de Buffs v1 vers Effets.

**Retirer**

- Aucune aura de la v1 n'est retirée sans équivalent. Seule l'icône de recharge d'Horion de flammes disparaît.
- Texte « MANA BAS » : remplacé par le rappel de mana, même seuil.

## 9. Besoins du générateur propres au chaman

À ajouter à la section 5 de `PLAN-AURAS-V2.md`, seulement s'ils sont de vrais besoins :

1. Segments par charge d'aura : 5 segments pilotés par une aura à charges (Maelstrom Weapon). Le socle ne couvre que
   les points de combo par Power.
2. Chargement sur « sort non connu » : le rappel du Bouclier de foudre se masque quand Water Shield est connu.
3. Chargement sur arme main gauche équipée : imbue et swing secondaires.
4. Item Count en icône (rappel d'Ankh) : le rappel texte existe (`entry.item`) ; manquent l'icône et l'ID d'objet.
5. Totem à deux triggers : le trigger Totem plus l'aura de buff du totem sur le joueur, pour le glow.
6. Icône de sort sans recharge (soins) : état de portée et de mana seulement, à valider avec le point 8 du socle.

# Mage — WoW Forever 1.60.1
Sources et build lus, date 2026-10-08.
- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName). Le DB2 fait foi pour les IDs. Il contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- Spell IDs, noms, rangs : https://wow-forever.gg/db/spells/browse/class/mage/ (liste de 199 sorts, build 1.60.1.70245 sur les pages de sort).
- Niveau, coût, recharge, durée : https://endgametools.com/en/wow-forever/spells/mage (build 1.60.1.70245, 184 entrées, aucun ID affiché). Recoupement : https://wowforevertalents.com/abilities/mage/ (build 1.60.1.70245) et /mage/ (talents).
- Wowhead Forever : pages de sort lues pour les auras (https://www.wowhead.com/forever/spell=ID). La liste filtrée par classe n'existe pas sur Wowhead Forever (pas de filtre classe).
- Coût en mana sauf mention. « % base » = % du mana de base. Durée : effet ou aura (rien = non affiché).

## Sorts de base (entraîneur)
Tableau trié par nom puis rang. Les rangs 1 d'Arcane Blast, Ice Lance, Pyroblast, Blast Wave et Ice Barrier sont enseignés par talent. Ils sont dans la liste wow-forever.gg avec leur ID mais absents de la liste entraîneur endgametools. Polymorph (Turtle/Pig), Cow : variantes de niveau 60.

| Nom | Rang | Spell ID | Niveau | Coût / ressource | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Amplify Magic | 1 | 1008 | 18 | 150 | — | 10 min |  |
| Amplify Magic | 2 | 8455 | 30 | 250 | — | 10 min |  |
| Amplify Magic | 3 | 10169 | 42 | 350 | — | 10 min |  |
| Amplify Magic | 4 | 10170 | 54 | 450 | — | 10 min |  |
| Arcane Blast | 1 | 400574 | talent | voir note | — | — | rang 1 donné par le talent ; niveau/coût : non trouvé (rang 1 absent de la liste entraîneur endgametools) |
| Arcane Blast | 2 | 1239696 | 30 | 15% base | — | 8 s buff |  |
| Arcane Blast | 3 | 1239697 | 40 | 15% base | — | 8 s buff |  |
| Arcane Blast | 4 | 1239699 | 50 | 15% base | — | 8 s buff |  |
| Arcane Blast | 5 | 1239700 | 60 | 15% base | — | 8 s buff |  |
| Arcane Brilliance | — | 23028 | 56 | 3400 | — | 1 h |  |
| Arcane Explosion | 1 | 1449 | 14 | 75 | — | — |  |
| Arcane Explosion | 2 | 8437 | 22 | 120 | — | — |  |
| Arcane Explosion | 3 | 8438 | 30 | 185 | — | — |  |
| Arcane Explosion | 4 | 8439 | 38 | 250 | — | — |  |
| Arcane Explosion | 5 | 10201 | 46 | 315 | — | — |  |
| Arcane Explosion | 6 | 10202 | 54 | 390 | — | — |  |
| Arcane Intellect | 1 | 1459 | 1 | 60 | — | 1 h |  |
| Arcane Intellect | 2 | 1460 | 14 | 185 | — | 1 h |  |
| Arcane Intellect | 3 | 1461 | 28 | 520 | — | 1 h |  |
| Arcane Intellect | 4 | 10156 | 42 | 945 | — | 1 h |  |
| Arcane Intellect | 5 | 10157 | 56 | 1510 | — | 1 h |  |
| Arcane Missiles | 1 | 5143 | 8 | 85 | — | 3 s canal |  |
| Arcane Missiles | 2 | 5144 | 16 | 140 | — | 4 s canal |  |
| Arcane Missiles | 3 | 5145 | 24 | 235 | — | 5 s canal |  |
| Arcane Missiles | 4 | 8416 | 32 | 320 | — | 5 s canal |  |
| Arcane Missiles | 5 | 8417 | 40 | 410 | — | 5 s canal |  |
| Arcane Missiles | 6 | 10211 | 48 | 500 | — | 5 s canal |  |
| Arcane Missiles | 7 | 10212 | 56 | 595 | — | 5 s canal |  |
| Arcane Missiles | 8 | 25345 | 56 | 655 | — | 5 s canal |  |
| Blast Wave | 1 | 11113 | talent | voir note | — | — | rang 1 donné par le talent ; niveau/coût : non trouvé (rang 1 absent de la liste entraîneur endgametools) |
| Blast Wave | 2 | 13018 | 36 | 270 | 45 s | 6 s hébétement |  |
| Blast Wave | 3 | 13019 | 44 | 355 | 45 s | 6 s hébétement |  |
| Blast Wave | 4 | 13020 | 52 | 450 | 45 s | 6 s hébétement |  |
| Blast Wave | 5 | 13021 | 60 | 545 | 45 s | 6 s hébétement |  |
| Blink | — | 1953 | 20 | 35% base | 15 s | — |  |
| Blizzard | 1 | 10 | 20 | 320 | — | 8 s canal |  |
| Blizzard | 2 | 6141 | 28 | 520 | — | 8 s canal |  |
| Blizzard | 3 | 8427 | 36 | 720 | — | 8 s canal |  |
| Blizzard | 4 | 10185 | 44 | 935 | — | 8 s canal |  |
| Blizzard | 5 | 10186 | 52 | 1160 | — | 8 s canal |  |
| Blizzard | 6 | 10187 | 60 | 1400 | — | 8 s canal |  |
| Cone of Cold | 1 | 120 | 26 | 210 | 10 s | 6 s ralent. |  |
| Cone of Cold | 2 | 8492 | 34 | 290 | 10 s | 6 s ralent. |  |
| Cone of Cold | 3 | 10159 | 42 | 380 | 10 s | 6 s ralent. |  |
| Cone of Cold | 4 | 10160 | 50 | 465 | 10 s | 6 s ralent. |  |
| Cone of Cold | 5 | 10161 | 58 | 555 | 10 s | 6 s ralent. |  |
| Conjure Food | 1 | 587 | 6 | 60 | — | — |  |
| Conjure Food | 2 | 597 | 12 | 105 | — | — |  |
| Conjure Food | 3 | 990 | 22 | 180 | — | — |  |
| Conjure Food | 4 | 6129 | 32 | 285 | — | — |  |
| Conjure Food | 5 | 10144 | 42 | 420 | — | — |  |
| Conjure Food | 6 | 10145 | 52 | 585 | — | — |  |
| Conjure Food | 7 | 28612 | 60 | 705 | — | — |  |
| Conjure Mana Agate | — | 759 | 28 | 530 | — | — |  |
| Conjure Mana Citrine | — | 10053 | 48 | 1130 | — | — |  |
| Conjure Mana Jade | — | 3552 | 38 | 800 | — | — |  |
| Conjure Mana Ruby | — | 10054 | 58 | 1470 | — | — |  |
| Conjure Water | 1 | 5504 | 4 | 60 | — | — |  |
| Conjure Water | 2 | 5505 | 10 | 105 | — | — |  |
| Conjure Water | 3 | 5506 | 20 | 180 | — | — |  |
| Conjure Water | 4 | 6127 | 30 | 285 | — | — |  |
| Conjure Water | 5 | 10138 | 40 | 420 | — | — |  |
| Conjure Water | 6 | 10139 | 50 | 585 | — | — |  |
| Conjure Water | 7 | 10140 | 60 | 780 | — | — |  |
| Conjure Water | 8 | 468766 | 60 | 845 | — | — | présent dans le DB2 (SkillLineAbility Arcane, 468766 Conjure Water) ; wowforevertalents le signale comme donnée SoD absente de la bêta Forever : actif en jeu non vérifié |
| Counterspell | — | 2139 | 24 | 100 | 30 s | verrou 10 s |  |
| Dampen Magic | 1 | 604 | 12 | 100 | — | 10 min |  |
| Dampen Magic | 2 | 8450 | 24 | 200 | — | 10 min |  |
| Dampen Magic | 3 | 8451 | 36 | 300 | — | 10 min |  |
| Dampen Magic | 4 | 10173 | 48 | 400 | — | 10 min |  |
| Dampen Magic | 5 | 10174 | 60 | 500 | — | 10 min |  |
| Evocation | — | 12051 | 20 | — | 8 min | 8 s canal |  |
| Felfire | — | 24530 | 60 | 100 | — | — | nouveau Forever |
| Fire Blast | 1 | 2136 | 6 | 40 | 8 s | — |  |
| Fire Blast | 2 | 2137 | 14 | 75 | 8 s | — |  |
| Fire Blast | 3 | 2138 | 22 | 115 | 8 s | — |  |
| Fire Blast | 4 | 8412 | 30 | 165 | 8 s | — |  |
| Fire Blast | 5 | 8413 | 38 | 220 | 8 s | — |  |
| Fire Blast | 6 | 10197 | 46 | 280 | 8 s | — |  |
| Fire Blast | 7 | 10199 | 54 | 340 | 8 s | — |  |
| Fire Ward | 1 | 543 | 20 | 85 | 30 s | 30 s |  |
| Fire Ward | 2 | 8457 | 30 | 135 | 30 s | 30 s |  |
| Fire Ward | 3 | 8458 | 40 | 195 | 30 s | 30 s |  |
| Fire Ward | 4 | 10223 | 50 | 255 | 30 s | 30 s |  |
| Fire Ward | 5 | 10225 | 60 | 320 | 30 s | 30 s |  |
| Fireball | 1 | 133 | 1 | 30 | — | 4 s DoT |  |
| Fireball | 2 | 143 | 6 | 45 | — | 6 s DoT |  |
| Fireball | 3 | 145 | 12 | 65 | — | 6 s DoT |  |
| Fireball | 4 | 3140 | 18 | 95 | — | 8 s DoT |  |
| Fireball | 5 | 8400 | 24 | 140 | — | 8 s DoT |  |
| Fireball | 6 | 8401 | 30 | 185 | — | 8 s DoT |  |
| Fireball | 7 | 8402 | 36 | 220 | — | 8 s DoT |  |
| Fireball | 8 | 10148 | 42 | 260 | — | 8 s DoT |  |
| Fireball | 9 | 10149 | 48 | 305 | — | 8 s DoT |  |
| Fireball | 10 | 10150 | 54 | 350 | — | 8 s DoT |  |
| Fireball | 11 | 10151 | 60 | 395 | — | 8 s DoT |  |
| Fireball | 12 | 25306 | 60 | 410 | — | 8 s DoT |  |
| Flamestrike | 1 | 2120 | 16 | 195 | — | 8 s DoT |  |
| Flamestrike | 2 | 2121 | 24 | 330 | — | 8 s DoT |  |
| Flamestrike | 3 | 8422 | 32 | 490 | — | 8 s DoT |  |
| Flamestrike | 4 | 8423 | 40 | 650 | — | 8 s DoT |  |
| Flamestrike | 5 | 10215 | 48 | 815 | — | 8 s DoT |  |
| Flamestrike | 6 | 10216 | 56 | 990 | — | 8 s DoT |  |
| Frost Armor | 1 | 168 | 1 | 60 | — | 30 min |  |
| Frost Armor | 2 | 7300 | 10 | 110 | — | 30 min |  |
| Frost Armor | 3 | 7301 | 20 | 170 | — | 30 min |  |
| Frost Nova | 1 | 122 | 10 | 55 | 25 s | 8 s racine |  |
| Frost Nova | 2 | 865 | 26 | 85 | 25 s | 8 s racine |  |
| Frost Nova | 3 | 6131 | 40 | 115 | 25 s | 8 s racine |  |
| Frost Nova | 4 | 10230 | 54 | 145 | 25 s | 8 s racine |  |
| Frost Ward | 1 | 6143 | 22 | 85 | 30 s | 30 s |  |
| Frost Ward | 2 | 8461 | 32 | 135 | 30 s | 30 s |  |
| Frost Ward | 3 | 8462 | 42 | 195 | 30 s | 30 s |  |
| Frost Ward | 4 | 10177 | 52 | 255 | 30 s | 30 s |  |
| Frost Ward | 5 | 28609 | 60 | 320 | 30 s | 30 s |  |
| Frostbolt | 1 | 116 | 4 | 25 | — | 5 s ralentissement |  |
| Frostbolt | 2 | 205 | 8 | 35 | — | 6 s ralent. |  |
| Frostbolt | 3 | 837 | 14 | 50 | — | 6 s ralent. |  |
| Frostbolt | 4 | 7322 | 20 | 65 | — | 7 s ralent. |  |
| Frostbolt | 5 | 8406 | 26 | 100 | — | 7 s ralent. |  |
| Frostbolt | 6 | 8407 | 32 | 130 | — | 8 s ralent. |  |
| Frostbolt | 7 | 8408 | 38 | 160 | — | 8 s ralent. |  |
| Frostbolt | 8 | 10179 | 44 | 195 | — | 9 s ralent. |  |
| Frostbolt | 9 | 10180 | 50 | 225 | — | 9 s ralent. |  |
| Frostbolt | 10 | 10181 | 56 | 260 | — | 9 s ralent. |  |
| Frostbolt | 11 | 25304 | 60 | 290 | — | 9 s ralent. |  |
| Frostfire Bolt | 1 | 401502 | 40 | 205 | — | 9 s ralent./DoT | nouveau Forever |
| Frostfire Bolt | 2 | 1237312 | 50 | 285 | — | 9 s ralent./DoT | nouveau Forever |
| Frostfire Bolt | 3 | 1237313 | 60 | 370 | — | 9 s ralent./DoT | nouveau Forever |
| Ice Armor | 1 | 7302 | 30 | 240 | — | 30 min |  |
| Ice Armor | 2 | 7320 | 40 | 320 | — | 30 min |  |
| Ice Armor | 3 | 10219 | 50 | 410 | — | 30 min |  |
| Ice Armor | 4 | 10220 | 60 | 500 | — | 30 min |  |
| Ice Barrier | 1 | 11426 | talent | voir note | — | — | rang 1 donné par le talent ; niveau/coût : non trouvé (rang 1 absent de la liste entraîneur endgametools) |
| Ice Barrier | 2 | 13031 | 46 | 360 | 30 s | 1 min |  |
| Ice Barrier | 3 | 13032 | 52 | 420 | 30 s | 1 min |  |
| Ice Barrier | 4 | 13033 | 58 | 480 | 30 s | 1 min |  |
| Ice Lance | 1 | 1312002 | talent | voir note | — | — | rang 1 donné par le talent ; niveau/coût : non trouvé (rang 1 absent de la liste entraîneur endgametools) |
| Ice Lance | 2 | 400640 | 28 | 55 | — | — |  |
| Ice Lance | 3 | 1240044 | 34 | 70 | — | — |  |
| Ice Lance | 4 | 1240045 | 42 | 105 | — | — |  |
| Ice Lance | 5 | 1240046 | 48 | 120 | — | — |  |
| Ice Lance | 6 | 1240047 | 56 | 160 | — | — |  |
| Mage Armor | 1 | 6117 | 34 | 270 | — | 30 min |  |
| Mage Armor | 2 | 22782 | 46 | 380 | — | 30 min |  |
| Mage Armor | 3 | 22783 | 58 | 490 | — | 30 min |  |
| Mana Shield | 1 | 1463 | 20 | 40 | — | 1 min |  |
| Mana Shield | 2 | 8494 | 28 | 60 | — | 1 min |  |
| Mana Shield | 3 | 8495 | 36 | 80 | — | 1 min |  |
| Mana Shield | 4 | 10191 | 44 | 100 | — | 1 min |  |
| Mana Shield | 5 | 10192 | 52 | 120 | — | 1 min |  |
| Mana Shield | 6 | 10193 | 60 | 140 | — | 1 min |  |
| Polymorph | 1 | 118 | 8 | 60 | — | 20 s |  |
| Polymorph | 2 | 12824 | 20 | 90 | — | 30 s |  |
| Polymorph | 3 | 12825 | 40 | 120 | — | 40 s |  |
| Polymorph | 4 | 12826 | 60 | 150 | — | 50 s |  |
| Polymorph (Pig) | — | 28272 | 60 | 150 | — | 50 s |  |
| Polymorph (Turtle) | — | 28271 | 60 | 150 | — | 50 s |  |
| Polymorph: Cow | — | 28270 | 60 | 150 | — | 50 s |  |
| Portal: Darnassus | — | 11419 | 50 | 850 | 1 min | — |  |
| Portal: Ironforge | — | 11416 | 40 | 850 | 1 min | — |  |
| Portal: Orgrimmar | — | 11417 | 40 | 850 | 1 min | — |  |
| Portal: Stormwind | — | 10059 | 40 | 850 | 1 min | — |  |
| Portal: Thunder Bluff | — | 11420 | 50 | 850 | 1 min | — |  |
| Portal: Undercity | — | 11418 | 40 | 850 | 1 min | — |  |
| Pyroblast | 1 | 11366 | talent | voir note | — | — | rang 1 donné par le talent ; niveau/coût : non trouvé (rang 1 absent de la liste entraîneur endgametools) |
| Pyroblast | 2 | 12505 | 24 | 150 | — | 12 s DoT |  |
| Pyroblast | 3 | 12522 | 30 | 195 | — | 12 s DoT |  |
| Pyroblast | 4 | 12523 | 36 | 240 | — | 12 s DoT |  |
| Pyroblast | 5 | 12524 | 42 | 285 | — | 12 s DoT |  |
| Pyroblast | 6 | 12525 | 48 | 335 | — | 12 s DoT |  |
| Pyroblast | 7 | 12526 | 54 | 385 | — | 12 s DoT |  |
| Pyroblast | 8 | 18809 | 60 | 440 | — | 12 s DoT |  |
| Remove Lesser Curse | — | 475 | 18 | 10% base | — | — |  |
| Scorch | 1 | 2948 | 22 | 50 | — | — |  |
| Scorch | 2 | 8444 | 28 | 65 | — | — |  |
| Scorch | 3 | 8445 | 34 | 80 | — | — |  |
| Scorch | 4 | 8446 | 40 | 100 | — | — |  |
| Scorch | 5 | 10205 | 46 | 115 | — | — |  |
| Scorch | 6 | 10206 | 52 | 135 | — | — |  |
| Scorch | 7 | 10207 | 58 | 150 | — | — |  |
| Slow Fall | — | 130 | 12 | 40 | — | 30 s |  |
| Teleport: Dalaran | — | 1297659 | 50 | 120 | — | — | nouveau Forever |
| Teleport: Darnassus | — | 3565 | 30 | 120 | — | — |  |
| Teleport: Ironforge | — | 3562 | 20 | 120 | — | — |  |
| Teleport: Orgrimmar | — | 3567 | 20 | 120 | — | — |  |
| Teleport: Stormwind | — | 3561 | 20 | 120 | — | — |  |
| Teleport: Thunder Bluff | — | 3566 | 30 | 120 | — | — |  |
| Teleport: Undercity | — | 3563 | 20 | 120 | — | — |  |

Remarque : Detect Magic n'existe pas dans Forever (wowforevertalents) : non trouvé (absent du DB2 70245). Comprehend Scroll et Study (onglet « Comprehension », niveau 6) : candidats DB2 (SkillLineAbility, ligne 3012), non tranché. Comprehend Scroll : 1296017 (classe Mage), 1309965, 1309973, 1310029, 1310030 (sans masque de classe). Study : 1302508 (classe Mage) ; 1302696 existe dans SpellName sans ligne SkillLineAbility.

## Talents
Sources : wowforevertalents.com/mage (effets) et wow-forever.gg/talents/mage (structure). IDs par rang : table Talent du DB2 client 1.60.1.70245 (SpellRank_0 à SpellRank_n, dans l'ordre des rangs). Les rangs et effets viennent des sources web, les IDs du DB2. Un talent absent de la table Talent est marqué « absent de Talent (DB2) » ; écarts de nombre de rangs ou d'ID : voir « Écarts avec le DB2 client ».

### Arcane (18)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Wand Specialization | 2 : 6057, 6085 | baguettes +13 / +25 % |
| Arcane Focus | 5 : 11222, 12839, 12840, 12841, 12842 | toucher Arcane +1 à +5 % |
| Improved Channeling | 5 : 11237, 12463, 12464, 16769, 16770 | anti-interruption canalisation (Missiles 20 à 100 %) |
| Arcane Subtlety | 2 : 11210, 12592 | résistance cible -8 / -15, menace Arcane -15 / -30 % |
| Magic Absorption | 5 (DB2) : 29441, 29444, 29445, 29446, 29447 | résistances +5 / +10, 1 / 2 % mana si résisté (source web : 2 rangs, écart signalé) |
| Arcane Concentration | 5 : 11213, 12574, 12575, 12576, 12577 | chance de Clearcasting 2 à 10 % |
| Arcane Resilience | 1 (DB2) : 28574 | armure +25 / +50 % de l'Intelligence (source web : 2 rangs, écart signalé) |
| Arcane Geometry | 2 : 11247, 12606 | portée Arcane +3 / +6 m |
| Arcane Impact | 3 : 11242, 12467, 12469 | crit Arcane +2 à +6 % |
| Arcane Blast | 1 : 400574 (rang 1) ; absent de Talent (DB2), 400574 vient de SkillLineAbility (Arcane) | 57-66 dégâts ; cumuls jusqu'à 4 |
| Arcane Shielding | 2 : 11252, 12605 | Mana Shield -17 / -33 % perte, Mage Armor résistances +25 / +50 % |
| Improved Counterspell | 2 : 11255, 12598 | silence 2 / 4 s |
| Arcane Meditation | 3 : 18462, 18463, 18464 | régén. mana en incantation 17 à 50 % |
| Missile Barrage | 1 : absent de Talent (DB2) ; sorts de même nom : voir « Buffs, debuffs et procs » | proc Arcane Missiles gratuit (40 % Arcane Blast, 20 % Fireball/Frostbolt/Frostfire Bolt) |
| Presence of Mind | 1 : 12043 | prochain sort < 10 s instantané, recharge 3 min |
| Arcane Mind | 5 : 11232, 12500, 12501, 12502, 12503 | Intelligence +2 à +10 % ; bonus crit Arcane +20 à +100 % |
| Arcane Instability | 3 : 15058, 15059, 15060 | dégâts et crit +1 à +3 % |
| Arcane Power | 1 : 12042 | 15 s : +30 % dégâts, +30 % coût ; recharge 3 min |

### Feu (17)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Wake of Fire | 3 (DB2) : 11078, 11080, 12342 | Fire Blast recharge -1 / -2 s ; après kill +25 / +50 % crit (source web : 2 rangs, écart signalé) |
| Incineration | 2 (DB2) : 18459, 18460 | crit +2 à +6 % (Fire Blast, Ice Lance, Arcane Blast, Scorch) (source web : 3 rangs, écart signalé) |
| Improved Fireball | 5 : 11069, 12338, 12339, 12340, 12341 | incantation -0,1 à -0,5 s |
| Ignite | 5 : 11119, 11120, 12846, 12847, 12848 | crits Feu : +8 à +40 % sur 4 s |
| Flame Throwing | 2 : 11100, 12353 | portée Feu +3 / +6 m |
| Impact | 5 (DB2) : 11103, 12357, 12358, 12359, 12360 | Feu étourdit 2 s, 3 à 10 % (source web : 3 rangs, écart signalé ; 12355 = aura déclenchée) |
| Burning Soul | 2 (DB2) : 11083, 12351 | 23 à 70 % de ne pas perdre l'incantation ; menace -10 à -30 % (source web : 3 rangs, écart signalé) |
| Improved Flamestrike | 3 : 11108, 12349, 12350 | crit +5 à +15 % |
| Pyroblast | 1 : 11366 (rang 1) | 100-132 + 44 sur 12 s ; incantation 6 s |
| Improved Scorch | 3 : 11095, 12872, 12873 | 33 à 100 % ; +3 % dégâts Feu, 30 s, 5 cumuls |
| Improved Fire Ward | 2 : 11094, 13043 | réflexion 10 / 20 % |
| Heating Up | 1 : absent de Talent (DB2) ; sorts de même nom : voir « Buffs, debuffs et procs » | crit Feu direct : -25 % incantation Pyroblast par cumul (3 max, 20 s) |
| Master of Elements | 3 : 29074, 29075, 29076 | crit Feu/Givre rend 10 à 30 % du mana de base (29077 : sort de même nom, hors rangs Talent) |
| Critical Mass | 3 : 11115, 11367, 11368 | crit Feu +2 à +6 % |
| Blast Wave | 1 : 11113 (rang 1) | 153-185, ralentit 50 % 6 s, 45 s |
| Fire Power | 5 : 11124, 12378, 12398, 12399, 12400 | dégâts Feu +2 à +10 % |
| Combustion | 1 : 11129 | +10 % crit Feu par coup jusqu'à 3 crits ; 3 min |

### Givre (19)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Frost Warding | 2 : 11189, 28332 | Frost/Ice Armor +15 / +30 %, réflexion Frost Ward 10 / 20 % |
| Improved Frostbolt | 5 : 11070, 12473, 16763, 16765, 16766 | incantation -0,1 à -0,5 s |
| Elemental Precision | 3 (DB2) : 29438, 29439, 29440 | toucher Feu/Givre +1 à +5 % (source web : 5 rangs, écart signalé) |
| Ice Shards | 5 : 11207, 12672, 15047, 15052, 15053 | bonus crit Givre +20 à +100 % |
| Permafrost | 3 : 11175, 12569, 12571 | durée Chill +11 à +33 % |
| Improved Frost Nova | 2 : 11165, 12475 | recharge -2 / -4 s |
| Frostbite | 3 : 11071, 12496, 12497 | Chill : 5 à 15 % de geler 5 s (12494 = aura déclenchée) |
| Piercing Ice | 3 : 11151, 12952, 12953 | dégâts Givre +2 à +6 % |
| Frost Channeling | 3 : 11160, 12518, 12519 | coût Givre -5 à -15 % |
| Ice Lance | 1 : 1312002 (rang 1) ; absent de Talent (DB2), 1312002 vient de SkillLineAbility (Frost) | 28-33 Givre, +300 % vs Gelé ; 45 mana |
| Improved Blizzard | 3 : 11185, 12487, 12488 | Chill 15 à 40 % |
| Arctic Reach | 2 : 16757, 16758 | portée/rayon +10 / +20 % |
| Ice Block | 1 : 11958 | 10 s d'immunité ; 5 min |
| Shatter | 5 (DB2) : 11170, 12982, 12983, 12984, 12985 | crit vs Gelé +17 à +50 % (source web : 3 rangs, écart signalé) |
| Improved Cone of Cold | 3 : 11190, 12489, 12490 | dégâts +12 à +35 % |
| Cold Snap | 1 : 12472 | réinitialise les recharges Givre ; 10 min |
| Fingers of Frost | 2 : absent de Talent (DB2) ; sorts de même nom : voir « Buffs, debuffs et procs » | 15 % après Chill : 1 / 2 sorts comptent comme Gelé, 15 s |
| Winter's Chill | 5 : 11180, 28592, 28593, 28594, 28595 (aura : 12579) | 20 à 100 % de proc, +2 % crit cumulable, 15 s |
| Ice Barrier | 1 : 11426 (rang 1) | absorbe 448 ; 1 min ; 30 s |

## Buffs, debuffs et procs à suivre en WeakAuras
IDs lus sur wow-forever.gg ou Wowhead Forever. Les valeurs d'ID de sort lancé servent aussi pour l'aura sauf mention.

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Clearcasting | 12536 (15 s, dissipable Magic ; DB2 : déclenché par Arcane Concentration 11213, aura) ; 16246, 16870, 457342, 467735 : autres sorts de même nom dans SpellName, rôle non vérifié | proc joueur | wow-forever.gg, DB2 |
| Arcane Power | 12042 (15 s) | buff joueur | wow-forever.gg |
| Presence of Mind | 12043 (recharge 3 min après la fin de l'aura) | buff joueur | Wowhead Forever |
| Combustion | 11129 (lancé) ; 28682 (aura, +11 % crit ; DB2 : déclenché par 11129) | buff joueur | Wowhead Forever, DB2 |
| Chilled | 12484 (1,5 s, -29 % vitesse) ; DB2 : 6136 déclenché par Frost Armor (168, 7300, 7301), 7321 déclenché par Ice Armor (7302, 7320, 10219, 10220) | debuff cible | Wowhead Forever, DB2 |
| Winter's Chill | 12579 (15 s, +3 % crit par cumul affiché ; DB2 : déclenché par Winter's Chill 11180) | debuff cible | Wowhead Forever, DB2 |
| Fire Vulnerability | 22959 (30 s, +4 % dégâts reçus ; DB2 : déclenché par Improved Scorch 11095) | debuff cible | Wowhead Forever, DB2 |
| Frostbite (gel) | 12494 (DB2 : déclenché par Frostbite 11071) | debuff cible | DB2 |
| Impact (étourdissement) | 12355 (DB2 : déclenché par Impact 11103) | debuff cible | DB2 |
| Ignite | 11119 (talent rang 1, aura). Debuff sur la cible : candidats nommés « Ignite » dans SpellName, sans lien de déclenchement depuis le talent : 3261 (aura 3), 412538 (aura 226), 412545 (effet direct, sans aura), 1234540 (aura 3). 12654 est lié à la ligne de compétence Feu (SkillLineAbility) mais sans nom dans SpellName. Non tranché | debuff cible | DB2 |
| Ice Block | 11958 | buff joueur | wow-forever.gg |
| Mana Shield | 1463, 8494, 8495, 10191, 10192, 10193 (rangs 1 à 6) | buff joueur | wow-forever.gg |
| Arcane Intellect / Brilliance | 1459, 1460, 1461, 10156, 10157 / 23028 | buff joueur (aura de groupe Brilliance : 23028 est le seul sort nommé « Arcane Brilliance » dans SpellName, avec effet aura ; aucun sort de groupe distinct trouvé) | wow-forever.gg, DB2 |
| Frost Armor | 168, 7300, 7301 | buff joueur | wow-forever.gg |
| Ice Armor | 7302, 7320, 10219, 10220 | buff joueur | wow-forever.gg |
| Mage Armor | 6117, 22782, 22783 | buff joueur | wow-forever.gg |
| Ice Barrier | 11426, 13031, 13032, 13033 | buff joueur | wow-forever.gg |
| Fire Ward / Frost Ward | voir tableau des sorts | buff joueur | wow-forever.gg |
| Dampen Magic / Amplify Magic | voir tableau des sorts | buff joueur / cible | wow-forever.gg |
| Arcane Blast (cumuls) | Aucun lien de déclenchement depuis 400574 / 1239696 à 1239700 dans le DB2. Sorts nommés « Arcane Blast » avec effet aura : 400573 (aura 108), 400586 (aura 108), 401729 (aura 332), 1300176 (aura 108), 1300177 (aura 4). Autres sorts de même nom sans aura : 10833, 16067, 18091, 20883, 22893, 22920, 22940, 24857, 42896, 1214029 (hors Mage probable). Non tranché | buff joueur | DB2 |
| Missile Barrage | Candidats nommés « Missile Barrage » dans SpellName (absents de Talent et de SkillLineAbility) : 400588 (aura 42, déclenche 400589), 400589 (aura 108/107), 401736 (aura 332), 467409 (aura 108/107). Non tranché | proc joueur | DB2 |
| Fingers of Frost | Candidats : 400647 (aura 4), 400669 (aura 262), 400670 (aura 4), 401741 (aura 332). Absents de Talent et de SkillLineAbility. Non tranché | proc joueur | DB2 |
| Heating Up | Candidats : 400624 (aura 4), 400625 (aura 108/4), 460878 (aura 23, déclenche 462337). Absents de Talent et de SkillLineAbility. Non tranché | proc joueur | DB2 |
| Improved Scorch (vulnérabilité Feu) | 22959 (Fire Vulnerability), déclenché par Improved Scorch 11095 | debuff cible | DB2 |

## Points non vérifiés
- IDs par rang des talents : issus du DB2 client (table Talent). Le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu. Aucune vérification en jeu.
- Ignite : talent 11119 à 12848 (DB2) ; ID du debuff sur la cible non tranché (4 candidats, voir tableau des auras).
- Auras d'Arcane Blast, Missile Barrage, Fingers of Frost, Heating Up : sorts de même nom dans SpellName, non rattachés à un talent ni à SkillLineAbility ; candidats listés, non tranchés.
- Sorts Mage du DB2 absents du fichier (non ajoutés, actif en jeu non vérifié) : Arcane Barrage 400610, Living Bomb 400613 / 400614, Fire Blast 400616 à 400623, Rewind Time 401462, Living Flame 401556 / 401558, Regeneration 401417, Mass Regeneration 412510, Spellfrost Bolt 412532, Icy Veins 425121, Arcane Surge 425124, Balefire Bolt 428878, Expanded Intellect 436949, Frozen Orb 440802 / 440809.

### Écarts avec le DB2 client
- Nombre de rangs source web ≠ DB2 : Magic Absorption (web 2, DB2 5), Arcane Resilience (web 2, DB2 1), Wake of Fire (web 2, DB2 3), Incineration (web 3, DB2 2), Impact (web 3, DB2 5), Burning Soul (web 3, DB2 2), Elemental Precision (web 5, DB2 3), Shatter (web 3, DB2 5). Le tableau garde les IDs du DB2.
- Impact : 12355 (fichier d'origine, rang) est l'aura déclenchée par 11103, pas un rang de la table Talent. Frostbite : 12494 idem (déclenchée par 11071). Master of Elements : 29077 absent des rangs Talent (rangs 29074 à 29076), présent en SkillLineAbility sans aura.
- Talents absents de la table Talent du DB2 : Arcane Blast, Ice Lance (rang 1 via SkillLineAbility), Missile Barrage, Heating Up, Fingers of Frost (aucun rang de talent).
- Arcane Geometry rang 2 : 12606 est nommé « Magic Attunement » dans SkillLineAbility (nom ≠ talent).
- Tous les autres IDs du tableau des sorts de base existent dans SkillLineAbility du DB2 (aucun écart d'ID).
- Wowhead Forever n'a pas de filtre par classe ; wow-forever.gg annonce 199 sorts Mage (dont 10 talents/effets), endgametools 184 entrées, wowforevertalents 53 capacités : écarts de comptage, pas de divergence d'ID constatée.
- Conjure Water rang 8 (468766) : wowforevertalents le signale comme donnée Season of Discovery non vue en bêta Forever.
- Niveaux, coûts, recharges et durées viennent d'endgametools ; recoupement partiel avec wowforevertalents (plages cohérentes). Les en-têtes de niveau d'endgametools affichent « niveau + nombre de sorts » (ex. « 13 » = niveau 1, 3 sorts).
- Fire Vulnerability : 4 % lu sur Wowhead Forever pour l'ID 22959 ; nombre de cumuls non affiché.
- Études / Comprehend Scroll : IDs candidats DB2 non tranchés (voir remarque sous le tableau des sorts). Teleport/Portal : durées et coûts non vérifiés sur page de sort.
- Wowhead Forever Frostbolt 10181 : page cohérente avec 260 mana (rang 10).

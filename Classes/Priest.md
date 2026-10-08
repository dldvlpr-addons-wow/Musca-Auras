# Prêtre — WoW Forever 1.60.1

Sources et build lus, date 2026-10-08.

- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName) : source de référence, elle fait foi sur les autres. Le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- IDs, noms, rangs : wow-forever.gg `/db/spells/browse/class/priest/` (build 1.60.1.70245, 242 entrées).
- Niveau, coût, cast, recharge, durée, race : endgametools.com `/en/wow-forever/spells/priest` (build 1.60.1.70245, 232 rangs) ; recoupé avec wowforevertalents.com `/abilities/priest/` (build 1.60.1.70245, 50 capacités).
- Talents (noms, rangs max) : wow-forever.gg `/talents/priest/`, endgametools.com `/en/wow-forever/planner/priest`.
- Wowhead Forever : pages de liste (`/forever/spells`, `/spells/abilities/priest`, `/spells/talents/priest`) sans résultats exploitables (filtres seuls, résultats chargés en JS) ; seule la page `spell=15270` a pu être lue.
- Les IDs du tableau des sorts de base viennent de wow-forever.gg ; les 242 ont été recoupés avec le DB2 (SpellName : nom identique, tous présents). endgametools et wowforevertalents n'affichent aucun spell ID. Les IDs de talents et d'auras viennent du DB2.

## Sorts de base (entraîneur)

Colonne « Coût / ressource » : coût puis temps d'incantation. « Canalisé » = sort canalisé. « base » = % de la mana de base. Les sorts raciaux indiquent la race en Notes. « talent » = sort fourni par un talent (le rang 1 est un sort-talent, absent de la liste endgametools). Les lignes sont en ordre de niveau.

| Nom | Rang | Spell ID | Niveau | Coût / ressource ; cast | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Lesser Heal | 1 | 2050 | 1 | 30 Mana ; 1.5 s | — | — | — |
| Power Word: Fortitude | 1 | 1243 | 1 | 60 Mana ; Instant | — | 1 h | — |
| Shadowfiend | — | 401977 | 1 | — ; Instant | 5 min | 15 s | — |
| Smite | 1 | 585 | 1 | 20 Mana ; 1.5 s | — | — | — |
| Lesser Heal | 2 | 2052 | 4 | 45 Mana ; 2 s | — | — | — |
| Shadow Word: Pain | 1 | 589 | 4 | 25 Mana ; Instant | — | 18 s | — |
| Power Word: Shield | 1 | 17 | 6 | 45 Mana ; Instant | 4 s | 30 s | — |
| Smite | 2 | 591 | 6 | 30 Mana ; 2 s | — | — | — |
| Fade | 1 | 586 | 8 | 40 Mana ; Instant | 30 s | 10 s | — |
| Renew | 1 | 139 | 8 | 30 Mana ; Instant | — | 15 s | — |
| Confounding Flash | — | 1277455 | 10 | 3% base ; 0.5 s | 2 min | 3 s | Gnome |
| Desperate Prayer | 1 | 13908 | 10 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 1 | 1277370 | 10 | — ; Instant | 10 min | — | Human |
| Hex of Weakness | 1 | 9035 | 10 | 35 Mana ; Instant | — | 2 min | Troll |
| Lesser Heal | 3 | 2053 | 10 | 75 Mana ; 2.5 s | — | — | — |
| Mind Blast | 1 | 8092 | 10 | 50 Mana ; 1.5 s | 8 s | — | — |
| Resurrection | 1 | 2006 | 10 | 75% base ; 10 s | — | — | — |
| Shadow Word: Pain | 2 | 594 | 10 | 50 Mana ; Instant | — | 18 s | — |
| Starshards | 1 | 10797 | 10 | 50 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Touch of Weakness | 1 | 2652 | 10 | 25 Mana ; Instant | — | 2 min | Mort-vivant |
| Inner Fire | 1 | 588 | 12 | 30 Mana ; Instant | — | 10 min | — |
| Power Word: Fortitude | 2 | 1244 | 12 | 155 Mana ; Instant | — | 1 h | — |
| Power Word: Shield | 2 | 592 | 12 | 80 Mana ; Instant | 4 s | 30 s | — |
| Cure Disease | — | 528 | 14 | 15% base ; Instant | — | — | — |
| Psychic Scream | 1 | 8122 | 14 | 100 Mana ; Instant | 30 s | 8 s | — |
| Renew | 2 | 6074 | 14 | 65 Mana ; Instant | — | 15 s | — |
| Smite | 3 | 598 | 14 | 60 Mana ; 2.5 s | — | — | — |
| Heal | 1 | 2054 | 16 | 155 Mana ; 3 s | — | — | — |
| Mind Blast | 2 | 8102 | 16 | 80 Mana ; 1.5 s | 8 s | — | — |
| Desperate Prayer | 2 | 19236 | 18 | — ; Instant | 10 min | — | Dwarf |
| Dispel Magic | 1 | 527 | 18 | 18% base ; Instant | — | — | — |
| Divine Grace | 2 | 1277371 | 18 | — ; Instant | 10 min | — | Human |
| Power Word: Shield | 3 | 600 | 18 | 130 Mana ; Instant | 4 s | 30 s | — |
| Shadow Word: Pain | 3 | 970 | 18 | 95 Mana ; Instant | — | 18 s | — |
| Starshards | 2 | 19296 | 18 | 85 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Chastise | 1 | 1277331 | 20 | 50 Mana ; Instant | 2 min | — | Dwarf |
| Contingency Plan | 1 | 1277462 | 20 | — ; Instant | 10 min | — | Gnome |
| Dark Sacrifice | 1 | 1277324 | 20 | — ; Instant | 10 min | — | Mort-vivant |
| Devouring Plague | 1 | 2944 | 20 | 215 Mana ; Instant | 1 min | 24 s | — |
| Elune's Grace | — | 2651 | 20 | 3% base ; Instant | 5 min | 15 s | Elfe de la nuit |
| Fade | 2 | 9578 | 20 | 75 Mana ; Instant | 30 s | 10 s | — |
| Fear Ward | — | 6346 | 20 | 100 Mana ; Instant | 3 min | 3 min | — |
| Feedback | 1 | 13896 | 20 | 55 Mana ; Instant | 3 min | 15 s | Human |
| Flash Heal | 1 | 2061 | 20 | 125 Mana ; 1.5 s | — | — | — |
| Hex of Weakness | 2 | 19281 | 20 | 55 Mana ; Instant | — | 2 min | Troll |
| Holy Fire | 1 | 14914 | 20 | 85 Mana ; 3.5 s | — | — | — |
| Inner Fire | 2 | 7128 | 20 | 65 Mana ; Instant | — | 10 min | — |
| Mind Soothe | 1 | 453 | 20 | 50 Mana ; Instant | — | 15 s | — |
| Renew | 3 | 6075 | 20 | 105 Mana ; Instant | — | 15 s | — |
| Shackle Undead | 1 | 9484 | 20 | 90 Mana ; 1.5 s | — | — | — |
| Shadowguard | 1 | 18137 | 20 | 50 Mana ; Instant | — | 10 min | Troll |
| Touch of Weakness | 2 | 19261 | 20 | 45 Mana ; Instant | — | 2 min | Mort-vivant |
| Heal | 2 | 2055 | 22 | 205 Mana ; 3 s | — | — | — |
| Mind Blast | 3 | 8103 | 22 | 110 Mana ; 1.5 s | 8 s | — | — |
| Mind Vision | 1 | 2096 | 22 | 65 Mana ; Canalisé | — | 1 min | — |
| Resurrection | 2 | 2010 | 22 | 75% base ; 10 s | — | — | — |
| Smite | 4 | 984 | 22 | 95 Mana ; 2.5 s | — | — | — |
| Holy Fire | 2 | 15262 | 24 | 95 Mana ; 3.5 s | — | — | — |
| Mana Burn | 1 | 8129 | 24 | 95 Mana ; 3 s | — | — | — |
| Power Word: Fortitude | 3 | 1245 | 24 | 400 Mana ; Instant | — | 1 h | — |
| Power Word: Shield | 4 | 3747 | 24 | 175 Mana ; Instant | 4 s | 30 s | — |
| Desperate Prayer | 3 | 19238 | 26 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 3 | 1277372 | 26 | — ; Instant | 10 min | — | Human |
| Flash Heal | 2 | 9472 | 26 | 155 Mana ; 1.5 s | — | — | — |
| Renew | 4 | 6076 | 26 | 140 Mana ; Instant | — | 15 s | — |
| Shadow Word: Pain | 4 | 992 | 26 | 155 Mana ; Instant | — | 18 s | — |
| Starshards | 3 | 19299 | 26 | 140 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Devouring Plague | 2 | 19276 | 28 | 350 Mana ; Instant | 1 min | 24 s | — |
| Heal | 3 | 6063 | 28 | 255 Mana ; 3 s | — | — | — |
| Holy Nova | 2 | 15430 | 28 | 290 Mana ; Instant | — | — | talent (rang 1 = talent) |
| Mind Blast | 4 | 8104 | 28 | 150 Mana ; 1.5 s | 8 s | — | — |
| Mind Flay | 2 | 17311 | 28 | 70 Mana ; Canalisé | — | 3 s | talent (rang 1 = talent) |
| Psychic Scream | 2 | 8124 | 28 | 140 Mana ; Instant | 30 s | 8 s | — |
| Shadowguard | 2 | 19308 | 28 | 85 Mana ; Instant | — | 10 min | Troll |
| Chastise | 2 | 1277332 | 30 | 100 Mana ; Instant | 2 min | — | Dwarf |
| Contingency Plan | 2 | 1277634 | 30 | — ; Instant | 10 min | — | Gnome |
| Dark Sacrifice | 2 | 1277325 | 30 | — ; Instant | 10 min | — | Mort-vivant |
| Divine Spirit | 1 | 14752 | 30 | 285 Mana ; Instant | — | 1 h | — |
| Fade | 3 | 9579 | 30 | 125 Mana ; Instant | 30 s | 10 s | — |
| Feedback | 2 | 19271 | 30 | 100 Mana ; Instant | 3 min | 15 s | Human |
| Hex of Weakness | 3 | 19282 | 30 | 90 Mana ; Instant | — | 2 min | Troll |
| Holy Fire | 3 | 15263 | 30 | 125 Mana ; 3.5 s | — | — | — |
| Inner Fire | 3 | 602 | 30 | 105 Mana ; Instant | — | 10 min | — |
| Mind Control | 1 | 605 | 30 | 350 Mana ; Canalisé | — | 1 min | — |
| Power Word: Shield | 5 | 6065 | 30 | 210 Mana ; Instant | 4 s | 30 s | — |
| Prayer of Healing | 1 | 596 | 30 | 410 Mana ; 3 s | — | — | — |
| Shadow Protection | 1 | 976 | 30 | 250 Mana ; Instant | — | 10 min | — |
| Smite | 5 | 1004 | 30 | 140 Mana ; 2.5 s | — | — | — |
| Touch of Weakness | 3 | 19262 | 30 | 75 Mana ; Instant | — | 2 min | Mort-vivant |
| Abolish Disease | — | 552 | 32 | 15% base ; Instant | — | — | — |
| Binding Heal | 2 | 1240770 | 32 | 185 Mana ; 1.5 s | — | — | talent (rang 1 = talent) |
| Flash Heal | 3 | 9473 | 32 | 185 Mana ; 1.5 s | — | — | — |
| Mana Burn | 2 | 8131 | 32 | 140 Mana ; 3 s | — | — | — |
| Renew | 5 | 6077 | 32 | 170 Mana ; Instant | — | 15 s | — |
| Shadow Word: Death | 1 | 1309595 | 32 | 175 Mana ; Instant | 15 s | — | — |
| Desperate Prayer | 4 | 19240 | 34 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 4 | 1277374 | 34 | — ; Instant | 10 min | — | Human |
| Heal | 4 | 6064 | 34 | 305 Mana ; 3 s | — | — | — |
| Levitate | — | 1706 | 34 | 100 Mana ; Instant | — | 2 min | — |
| Mind Blast | 5 | 8105 | 34 | 185 Mana ; 1.5 s | 8 s | — | — |
| Resurrection | 3 | 10880 | 34 | 75% base ; 10 s | — | — | — |
| Shadow Word: Pain | 5 | 2767 | 34 | 230 Mana ; Instant | — | 18 s | — |
| Starshards | 4 | 19302 | 34 | 190 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Devouring Plague | 3 | 19277 | 36 | 495 Mana ; Instant | 1 min | 24 s | — |
| Dispel Magic | 2 | 988 | 36 | 18% base ; Instant | — | — | — |
| Holy Fire | 4 | 15264 | 36 | 145 Mana ; 3.5 s | — | — | — |
| Holy Nova | 3 | 15431 | 36 | 400 Mana ; Instant | — | — | talent |
| Mind Flay | 3 | 17312 | 36 | 100 Mana ; Canalisé | — | 3 s | talent |
| Mind Soothe | 2 | 8192 | 36 | 70 Mana ; Instant | — | 15 s | — |
| Power Word: Fortitude | 4 | 2791 | 36 | 745 Mana ; Instant | — | 1 h | — |
| Power Word: Shield | 6 | 6066 | 36 | 250 Mana ; Instant | 4 s | 30 s | — |
| Shadowguard | 3 | 19309 | 36 | 120 Mana ; Instant | — | 10 min | Troll |
| Binding Heal | 3 | 1240771 | 38 | 215 Mana ; 1.5 s | — | — | talent |
| Flash Heal | 4 | 9474 | 38 | 215 Mana ; 1.5 s | — | — | — |
| Renew | 6 | 6078 | 38 | 205 Mana ; Instant | — | 15 s | — |
| Smite | 6 | 6060 | 38 | 185 Mana ; 2.5 s | — | — | — |
| Chastise | 3 | 1277333 | 40 | 135 Mana ; Instant | 2 min | — | Dwarf |
| Contingency Plan | 3 | 1277638 | 40 | — ; Instant | 10 min | — | Gnome |
| Dark Sacrifice | 3 | 1277326 | 40 | — ; Instant | 10 min | — | Mort-vivant |
| Divine Spirit | 2 | 14818 | 40 | 420 Mana ; Instant | — | 1 h | — |
| Fade | 4 | 9592 | 40 | 175 Mana ; Instant | 30 s | 10 s | — |
| Feedback | 3 | 19273 | 40 | 140 Mana ; Instant | 3 min | 15 s | Human |
| Greater Heal | 1 | 2060 | 40 | 370 Mana ; 3 s | — | — | — |
| Hex of Weakness | 4 | 19283 | 40 | 130 Mana ; Instant | — | 2 min | Troll |
| Inner Fire | 4 | 1006 | 40 | 165 Mana ; Instant | — | 10 min | — |
| Lightwell | 1 | 724 | 40 | 225 Mana ; 1.5 s | 10 min | 3 min | — |
| Mana Burn | 3 | 10874 | 40 | 185 Mana ; 3 s | — | — | — |
| Mind Blast | 6 | 8106 | 40 | 225 Mana ; 1.5 s | 8 s | — | — |
| Penance | 2 | 1240720 | 40 | 185 Mana ; Canalisé | 12 s | — | talent |
| Prayer of Healing | 2 | 996 | 40 | 560 Mana ; 3 s | — | — | — |
| Shackle Undead | 2 | 9485 | 40 | 120 Mana ; 1.5 s | — | 40 s | — |
| Shadow Word: Death | 2 | 1309633 | 40 | 205 Mana ; Instant | 15 s | — | — |
| Touch of Weakness | 4 | 19264 | 40 | 105 Mana ; Instant | — | 2 min | Mort-vivant |
| Desperate Prayer | 5 | 19241 | 42 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 5 | 1277376 | 42 | — ; Instant | 10 min | — | Human |
| Holy Fire | 5 | 15265 | 42 | 170 Mana ; 3.5 s | — | — | — |
| Power Word: Shield | 7 | 10898 | 42 | 300 Mana ; Instant | 4 s | 30 s | — |
| Psychic Scream | 3 | 10888 | 42 | 180 Mana ; Instant | 30 s | 8 s | — |
| Shadow Protection | 2 | 10957 | 42 | 450 Mana ; Instant | — | 10 min | — |
| Shadow Word: Pain | 6 | 10892 | 42 | 305 Mana ; Instant | — | 18 s | — |
| Starshards | 5 | 19303 | 42 | 245 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Binding Heal | 4 | 1240772 | 44 | 265 Mana ; 1.5 s | — | — | talent |
| Devouring Plague | 4 | 19278 | 44 | 645 Mana ; Instant | 1 min | 24 s | — |
| Flash Heal | 5 | 10915 | 44 | 265 Mana ; 1.5 s | — | — | — |
| Holy Nova | 4 | 27799 | 44 | 520 Mana ; Instant | — | — | talent |
| Mind Control | 2 | 10911 | 44 | 550 Mana ; Canalisé | — | 1 min | — |
| Mind Flay | 4 | 17313 | 44 | 135 Mana ; Canalisé | — | 3 s | talent |
| Mind Vision | 2 | 10909 | 44 | 150 Mana ; Canalisé | — | 1 min | — |
| Renew | 7 | 10927 | 44 | 250 Mana ; Instant | — | 15 s | — |
| Shadowguard | 4 | 19310 | 44 | 160 Mana ; Instant | — | 10 min | Troll |
| Greater Heal | 2 | 10963 | 46 | 455 Mana ; 3 s | — | — | — |
| Mind Blast | 7 | 10945 | 46 | 265 Mana ; 1.5 s | 8 s | — | — |
| Resurrection | 4 | 10881 | 46 | 75% base ; 10 s | — | — | — |
| Smite | 7 | 10933 | 46 | 230 Mana ; 2.5 s | — | — | — |
| Holy Fire | 6 | 15266 | 48 | 200 Mana ; 3.5 s | — | — | — |
| Mana Burn | 4 | 10875 | 48 | 225 Mana ; 3 s | — | — | — |
| Power Word: Fortitude | 5 | 10937 | 48 | 1170 Mana ; Instant | — | 1 h | — |
| Power Word: Shield | 8 | 10899 | 48 | 355 Mana ; Instant | 4 s | 30 s | — |
| Prayer of Fortitude | 1 | 21562 | 48 | 2600 Mana ; Instant | — | 1 h | — |
| Shadow Word: Death | 3 | 1309635 | 48 | 250 Mana ; Instant | 15 s | — | — |
| Binding Heal | 5 | 1240773 | 50 | 315 Mana ; 1.5 s | — | — | talent |
| Chastise | 4 | 1277334 | 50 | 180 Mana ; Instant | 2 min | — | Dwarf |
| Contingency Plan | 4 | 1277639 | 50 | — ; Instant | 10 min | — | Gnome |
| Dark Sacrifice | 4 | 1277327 | 50 | — ; Instant | 10 min | — | Mort-vivant |
| Desperate Prayer | 6 | 19242 | 50 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 6 | 1277377 | 50 | — ; Instant | 10 min | — | Human |
| Divine Spirit | 3 | 14819 | 50 | 785 Mana ; Instant | — | 1 h | — |
| Fade | 5 | 10941 | 50 | 225 Mana ; Instant | 30 s | 10 s | — |
| Feedback | 4 | 19274 | 50 | 190 Mana ; Instant | 3 min | 15 s | Human |
| Flash Heal | 6 | 10916 | 50 | 315 Mana ; 1.5 s | — | — | — |
| Hex of Weakness | 5 | 19284 | 50 | 180 Mana ; Instant | — | 2 min | Troll |
| Inner Fire | 5 | 10951 | 50 | 235 Mana ; Instant | — | 10 min | — |
| Lightwell | 2 | 27870 | 50 | 295 Mana ; 1.5 s | 10 min | 3 min | — |
| Penance | 3 | 1240721 | 50 | 270 Mana ; Canalisé | 12 s | — | talent |
| Prayer of Healing | 3 | 10960 | 50 | 770 Mana ; 3 s | — | — | — |
| Prayer of Mending | 2 | 1240826 | 50 | 305 Mana ; Instant | 10 s | — | talent (rang 1 = talent) |
| Renew | 8 | 10928 | 50 | 305 Mana ; Instant | — | 15 s | — |
| Shadow Word: Pain | 7 | 10893 | 50 | 385 Mana ; Instant | — | 18 s | — |
| Starshards | 6 | 19304 | 50 | 300 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Touch of Weakness | 5 | 19265 | 50 | 145 Mana ; Instant | — | 2 min | Mort-vivant |
| Devouring Plague | 5 | 19279 | 52 | 810 Mana ; Instant | 1 min | 24 s | — |
| Greater Heal | 3 | 10964 | 52 | 545 Mana ; 3 s | — | — | — |
| Holy Nova | 5 | 27800 | 52 | 635 Mana ; Instant | — | — | talent |
| Mind Blast | 8 | 10946 | 52 | 310 Mana ; 1.5 s | 8 s | — | — |
| Mind Flay | 5 | 17314 | 52 | 165 Mana ; Canalisé | — | 3 s | talent |
| Mind Soothe | 3 | 10953 | 52 | 90 Mana ; Instant | — | 15 s | — |
| Shadowguard | 5 | 19311 | 52 | 200 Mana ; Instant | — | 10 min | Troll |
| Holy Fire | 7 | 15267 | 54 | 230 Mana ; 3.5 s | — | — | — |
| Power Word: Shield | 9 | 10900 | 54 | 425 Mana ; Instant | 4 s | 30 s | — |
| Smite | 8 | 10934 | 54 | 280 Mana ; 2.5 s | — | — | — |
| Binding Heal | 6 | 1240774 | 56 | 380 Mana ; 1.5 s | — | — | talent |
| Flash Heal | 7 | 10917 | 56 | 380 Mana ; 1.5 s | — | — | — |
| Mana Burn | 5 | 10876 | 56 | 270 Mana ; 3 s | — | — | — |
| Prayer of Shadow Protection | — | 27683 | 56 | 1300 Mana ; Instant | — | 20 min | — |
| Psychic Scream | 4 | 10890 | 56 | 210 Mana ; Instant | 30 s | 8 s | — |
| Renew | 9 | 10929 | 56 | 365 Mana ; Instant | — | 15 s | — |
| Shadow Protection | 3 | 10958 | 56 | 650 Mana ; Instant | — | 10 min | — |
| Shadow Word: Death | 4 | 1309636 | 56 | 340 Mana ; Instant | 15 s | — | — |
| Desperate Prayer | 7 | 19243 | 58 | — ; Instant | 10 min | — | Dwarf |
| Divine Grace | 7 | 1277378 | 58 | — ; Instant | 10 min | — | Human |
| Greater Heal | 4 | 10965 | 58 | 655 Mana ; 3 s | — | — | — |
| Mind Blast | 9 | 10947 | 58 | 350 Mana ; 1.5 s | 8 s | — | — |
| Mind Control | 3 | 10912 | 58 | 750 Mana ; Canalisé | — | 1 min | — |
| Resurrection | 5 | 20770 | 58 | 75% base ; 10 s | — | — | — |
| Shadow Word: Pain | 8 | 10894 | 58 | 470 Mana ; Instant | — | 18 s | — |
| Starshards | 7 | 19305 | 58 | 350 Mana ; Canalisé | 30 s | 6 s | Elfe de la nuit |
| Chastise | 5 | 1277335 | 60 | 225 Mana ; Instant | 2 min | — | Dwarf |
| Contingency Plan | 5 | 1277640 | 60 | — ; Instant | 10 min | — | Gnome |
| Dark Sacrifice | 5 | 1277328 | 60 | — ; Instant | 10 min | — | Mort-vivant |
| Devouring Plague | 6 | 19280 | 60 | 985 Mana ; Instant | 1 min | 24 s | — |
| Divine Spirit | 4 | 27841 | 60 | 970 Mana ; Instant | — | 1 h | — |
| Fade | 6 | 10942 | 60 | 275 Mana ; Instant | 30 s | 10 s | — |
| Feedback | 5 | 19275 | 60 | 230 Mana ; Instant | 3 min | 15 s | Human |
| Greater Heal | 5 | 25314 | 60 | 710 Mana ; 3 s | — | — | — |
| Hex of Weakness | 6 | 19285 | 60 | 240 Mana ; Instant | — | 2 min | Troll |
| Holy Fire | 8 | 15261 | 60 | 255 Mana ; 3.5 s | — | — | — |
| Holy Nova | 6 | 27801 | 60 | 750 Mana ; Instant | — | — | talent |
| Inner Fire | 6 | 10952 | 60 | 315 Mana ; Instant | — | 10 min | — |
| Lightwell | 3 | 27871 | 60 | 365 Mana ; 1.5 s | 10 min | 3 min | — |
| Mind Flay | 6 | 18807 | 60 | 205 Mana ; Canalisé | — | 3 s | talent |
| Penance | 4 | 1316995 | 60 | 355 Mana ; Canalisé | 12 s | — | talent |
| Power Word: Fortitude | 6 | 10938 | 60 | 1695 Mana ; Instant | — | 1 h | — |
| Power Word: Shield | 10 | 10901 | 60 | 500 Mana ; Instant | 4 s | 30 s | — |
| Prayer of Fortitude | 2 | 21564 | 60 | 3400 Mana ; Instant | — | 1 h | — |
| Prayer of Healing | 4 | 10961 | 60 | 1030 Mana ; 3 s | — | — | — |
| Prayer of Healing | 5 | 25316 | 60 | 1070 Mana ; 3 s | — | — | — |
| Prayer of Mending | 3 | 1240827 | 60 | 390 Mana ; Instant | 10 s | — | talent |
| Prayer of Spirit | 1 | 27681 | 60 | 1940 Mana ; Instant | — | 1 h | — |
| Renew | 10 | 25315 | 60 | 410 Mana ; Instant | — | 15 s | — |
| Shackle Undead | 3 | 10955 | 60 | 150 Mana ; 1.5 s | — | 50 s | — |
| Shadowguard | 6 | 19312 | 60 | 250 Mana ; Instant | — | 10 min | Troll |
| Touch of Weakness | 6 | 19266 | 60 | 195 Mana ; Instant | — | 2 min | Mort-vivant |

Sorts présents uniquement dans wow-forever.gg (talents ou sorts dérivés ; niveau, coût, recharge non lus dans les sources de recoupement) :

| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Mind Flay | 1 | 15407 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Holy Nova | 1 | 15237 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Binding Heal | 1 | 401937 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Penance | 1 | 402174 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Prayer of Mending | 1 | 401859 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Vampiric Embrace | — | 15286 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Power Infusion | — | 10060 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Lightwell Renew | 1 | 7001 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Lightwell Renew | 2 | 27873 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |
| Lightwell Renew | 3 | 27874 | non lu | non lu | non lu | non lu | présent seulement dans wow-forever.gg (talent / sort dérivé) |

Lignes de sorts dans le tableau principal : 232 (plus 10 lignes complémentaires = 242, total wow-forever.gg).

## Talents

IDs par rang issus du DB2 client (table Talent, ordre rang 1 à N). Noms et rangs max des paragraphes ci-dessous : wow-forever.gg et endgametools. Le DB2 contient des talents retirés par correctif serveur : présence ≠ actif en jeu. « Rangs DB2 » = nombre de rangs dans le DB2 ; entre parenthèses, rang max annoncé par le web quand il diffère.

**Discipline** (TabID 201)

| Talent | Position (col/rangée) | Rangs DB2 | IDs rang 1..N |
|---|---|---|---|
| Wand Specialization | 2/0 | 5 (web : 2) | 14524, 14525, 14526, 14527, 14528 |
| Silent Resolve | 0/1 | 5 (web : 3) | 14523, 14784, 14785, 14786, 14787 |
| Improved Power Word: Shield | 2/1 | 3 | 14748, 14768, 14769 |
| Martyrdom | 3/1 | 2 | 14531, 14774 |
| Inner Focus | 1/2 | 1 | 14751 |
| Meditation | 2/2 | 3 | 14521, 14776, 14777 |
| Improved Inner Fire | 0/3 | 3 | 14747, 14770, 14771 |
| Mental Agility | 1/3 | 5 (web : 3) | 14520, 14780, 14781, 14782, 14783 |
| Improved Mana Burn | 3/3 | 2 | 14750, 14772 |
| Mental Strength | 1/4 | 5 | 18551, 18552, 18553, 18554, 18555 |
| Power Infusion | 1/6 | 1 | 10060 |
| Power in Light | absent de Talent | — | 1309969 (SpellName seul, nom unique ; IDs de rang non connus) |
| Twin Disciplines | absent de Talent | — | 1225132 (SpellName seul, nom unique ; IDs de rang non connus) |
| Holy Precision | absent de Talent | — | 1309957 (SpellName seul, nom unique ; IDs de rang non connus) |
| Soul Warding | absent de Talent | — | candidats SpellName : 402000, 402834 (non départagés) |
| Penance | absent de Talent | — | rang 1 : 402174 ; rangs 2 à 4 : 1240720, 1240721, 1316995 (sorts du tableau principal). Autres « Penance » en SkillLineAbility, rang non établi : 402284, 402289, 1240723, 1240724, 1240727, 1240730, 1316991, 1316993 |
| Renewed Hope | absent de Talent | — | candidats SpellName : 425280, 425303 (non départagés) |
| Divine Aegis | absent de Talent | — | candidats SpellName, rang non établi : 431622, 431624, 431649 |

Talents Discipline du DB2 absents des listes web : Unbreakable Will (1/0 ; 14522, 14788, 14789, 14790, 14791), Improved Power Word: Fortitude (1/1 ; 14749, 14767), Divine Spirit (2/4 ; 14752), Force of Will (2/5 ; 18544, 18547, 18548, 18549, 18550).

**Sacré** (TabID 202)

| Talent | Position (col/rangée) | Rangs DB2 | IDs rang 1..N |
|---|---|---|---|
| Twilight Focus | 0/0 | 2 (web : 3) | 14913, 15012 |
| Improved Renew | 1/0 | 3 | 14908, 15020, 17191 |
| Holy Specialization | 2/0 | 5 | 14889, 15008, 15009, 15010, 15011 |
| Spell Warding | 1/1 | 5 | 27900, 27901, 27902, 27903, 27904 |
| Divine Fury | 2/1 | 5 | 18530, 18531, 18533, 18534, 18535 |
| Holy Nova | 0/2 | 1 | 15237 |
| Blessed Recovery | 1/2 | 3 | 27811, 27815, 27816 |
| Inspiration | 3/2 | 3 | 14892, 15362, 15363 |
| Holy Reach | 0/3 | 2 | 27789, 27790 |
| Improved Healing | 1/3 | 3 | 14912, 15013, 15014 |
| Searing Light | 2/3 | 2 | 14909, 15017 |
| Spirit of Redemption | 1/4 | 1 | 20711 |
| Spiritual Guidance | 2/4 | 5 | 14901, 15028, 15029, 15030, 15031 |
| Spiritual Healing | 2/5 | 5 (web : 3) | 14898, 15349, 15354, 15355, 15356 |
| Binding Heal | absent de Talent | — | rang 1 : 401937 ; rangs 2 à 6 : 1240770, 1240771, 1240772, 1240773, 1240774 (sorts du tableau principal) |
| Litany of Light | absent de Talent | — | 1317006, 1317007 (SpellName ; 1317006 en SkillLineAbility, 1317007 SpellName seul ; ordre des rangs non vérifié) |
| Prayer of Mending | absent de Talent | — | rang 1 : 401859 ; rangs 2 et 3 : 1240826, 1240827 (sorts du tableau principal). Autre « Prayer of Mending » en SkillLineAbility, rang non établi : 401863 |

Talents Sacré du DB2 absents des listes web : Lightwell (1/6 ; 724) ; un talent sans nom dans le DB2 en 0/4 (14911, 15018).

**Magie de l'ombre** (TabID 203)

| Talent | Position (col/rangée) | Rangs DB2 | IDs rang 1..N |
|---|---|---|---|
| Spirit Tap | 1/0 | 5 | 15270, 15335, 15336, 15337, 15338 |
| Blackout | 2/0 | 5 | 15268, 15323, 15324, 15325, 15326 |
| Shadow Affinity | 0/1 | 3 | 15318, 15272, 15320 |
| Improved Shadow Word: Pain | 1/1 | 2 | 15275, 15317 |
| Shadow Focus | 2/1 | 5 | 15260, 15327, 15328, 15329, 15330 |
| Improved Psychic Scream | 0/2 | 2 | 15392, 15448 |
| Improved Mind Blast | 1/2 | 5 | 15273, 15312, 15313, 15314, 15316 |
| Mind Flay | 2/2 | 1 | 15407 (rangs 2 à 6 : sorts 17311, 17312, 17313, 17314, 18807, tableau principal) |
| Improved Fade | 1/3 | 2 | 15274, 15311 |
| Shadow Reach | 2/3 | 3 (web : 2) | 17322, 17323, 17325 |
| Shadow Weaving | 3/3 | 5 (web : 3) | 15257, 15331, 15332, 15333, 15334 |
| Silence | 0/4 | 1 | 15487 |
| Vampiric Embrace | 1/4 | 1 | 15286 |
| Darkness | 2/5 | 5 | 15259, 15307, 15308, 15309, 15310 |
| Shadowform | 1/6 | 1 | 15473 |
| Improved Mind Flay | absent de Talent | — | 1225139 (SpellName seul, nom unique ; IDs de rang non connus) |
| Devouring Contagion | absent de Talent | — | 1309950 (SpellName seul, nom unique ; IDs de rang non connus) |
| Early Demise | absent de Talent | — | 1310076 (SpellName seul, nom unique ; IDs de rang non connus) |

Talent Ombre du DB2 absent des listes web : Improved Vampiric Embrace (2/4 ; 27839, 27840).

Le tableau Spirit Tap / Blackout d'origine est remplacé par les lignes ci-dessus : l'aura de Spirit Tap est 15271 (déclenchée par chaque rang de 15270) et celle de Blackout 15269 (déclenchée par chaque rang), voir « Buffs, debuffs et procs ».

**Discipline (18)** : Power in Light 5 (Smite et Penance : dégâts accrus sur cible sous Holy Fire) ; Wand Specialization 2 ; Twin Disciplines 5 (sorts instantanés) ; Silent Resolve 3 ; Holy Precision 3 ; Improved Power Word: Shield 3 ; Martyrdom 2 ; Mental Agility 3 ; Inner Focus 1 (prochain sort sans mana) ; Meditation 3 ; Improved Inner Fire 3 ; Mental Strength 5 ; Soul Warding 1 ; Improved Mana Burn 2 ; Penance 1 ; Renewed Hope 5 ; Divine Aegis 3 (bouclier sur soin critique) ; Power Infusion 1 (15 s).

**Sacré (17)** : Twilight Focus 3 ; Improved Renew 3 ; Holy Specialization 5 ; Spell Warding 5 ; Divine Fury 5 ; Holy Nova 1 ; Blessed Recovery 3 ; Inspiration 3 (soin critique : armure accrue sur la cible) ; Holy Reach 2 ; Improved Healing 3 ; Searing Light 2 ; Binding Heal 1 ; Litany of Light 2 ; Spirit of Redemption 1 (15 s) ; Spiritual Guidance 5 ; Spiritual Healing 3 ; Prayer of Mending 1.

**Magie de l'ombre (18)** : Shadow Focus 5 ; Blackout 5 ; Spirit Tap 5 ; Shadow Affinity 3 ; Improved Shadow Word: Pain 2 ; Shadow Reach 2 ; Improved Mind Blast 5 ; Improved Psychic Scream 2 (prérequis : Blackout 5) ; Mind Flay 1 ; Improved Mind Flay 2 ; Improved Fade 2 ; Vampiric Embrace 1 ; Shadow Weaving 3 (n'avantage que le prêtre lanceur, selon la recherche web, annonce officielle Blizzard) ; Silence 1 ; Devouring Contagion 2 ; Early Demise 2 ; Darkness 5 ; Shadowform 1 (prérequis : Vampiric Embrace).

Total 53 talents. endgametools place en plus une seconde « Holy Specialization » dans l'arbre Ombre (hors comptage wow-forever.gg).

## Buffs, debuffs et procs à suivre en WeakAuras

IDs issus du DB2 client : sorts déclenchés (SpellEffect, source → déclenché) et colonne aura (SkillLineAbility, effet APPLY_AURA). Quand le sort lancé porte lui-même l'aura (colonne aura = oui, aucun sort déclenché), l'ID d'aura est l'ID du rang lancé du tableau ci-dessus. Plusieurs entrées de même nom dans SpellName sans lien établi avec la classe : tous les candidats sont listés, sans choix.

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Spirit Tap (buff Esprit, 15 s) | 15271 | proc (buff joueur) | DB2 : déclenché par 15270 |
| Blackout (étourdissement 3 s) | 15269 (aura déclenchée ; 15268 = talent rang 1) | debuff cible, proc | DB2 : déclenché par 15268, 15323, 15324, 15325, 15326 |
| Shadow Word: Pain | rangs 589, 594, 970, 992, 2767, 10892, 10893, 10894 (aura = oui, aucun sort déclenché) | debuff cible | DB2 |
| Devouring Plague | rangs 2944, 19276 à 19280 (aura = oui, aucun sort déclenché) ; entrées SpellName 459713 et 1219275 hors SkillLineAbility Prêtre, non retenues comme rangs | debuff cible | DB2 |
| Power Word: Shield | rangs 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 (aura = oui, aucun sort déclenché) | buff joueur (30 s) | DB2 |
| Weakened Soul | 6788 | debuff joueur | DB2 SpellName (nom unique) ; aucun sort source lié en SpellEffect |
| Inner Focus | 14751 | proc / buff joueur | DB2 : talent 14751, aura = oui, aucun sort déclenché |
| Inspiration | candidats : 14892 (talent rang 1, aura = oui ; rangs 2 et 3 : 15362, 15363) et 14893 (SpellName seul) | proc (buff joueur) | DB2 ; aucun sort déclenché lié, non départagés |
| Shadow Weaving | 15258 | debuff cible / buff lanceur | DB2 : déclenché par 15257, 15331, 15332, 15333, 15334 (15258 = aura) |
| Power Infusion | 10060 (aura = oui, aucun sort déclenché) | buff cible, 15 s | DB2 |
| Vampiric Embrace | 15286 (SkillLineAbility, aura = oui) ; autres « Vampiric Embrace » en SpellName sans lien établi : 15290, 461966, 1237618 | buff | DB2 |
| Shadowform | 15473 (talent, aura = oui) ; autres « Shadowform » en SpellName sans lien établi : 16592, 22917, 401980, 412527, 412569, 426223, 1213334 | buff | DB2 |
| Divine Aegis | candidats SpellName, non reliés à un sort source : 431622, 431624, 431649 | buff | DB2 |
| Fear Ward | 6346 (aura = oui) ; autre entrée SpellName sans lien établi : 459699 | buff | DB2 |
| Renew | rangs 139, 6074 à 6078, 10927 à 10929, 25315 (aura = oui) ; la SkillLineAbility Sacré liste aussi 425268 à 425277 (aura = oui), non reliés aux rangs | buff / HoT | DB2 |
| Power Word: Fortitude | 1243, 1244, 1245, 2791, 10937, 10938 (aura = oui) ; Prayer of Fortitude 21562, 21564 | buff | DB2 |
| Inner Fire | 588, 602, 1006, 7128, 10951, 10952 (aura = oui) | buff | DB2 |
| Martyrdom | 14531 déclenche 27828 Focused Casting (aura) | proc (buff joueur) | DB2 |
| Searing Light | 14909 déclenche 1284536 Holy Purpose (aura) | proc (buff joueur) | DB2 |
| Blessed Recovery | talent 27811 (aura = oui) ; 27813 (SkillLineAbility, aura = oui) ; 1240755 (SpellName seul) ; aucun sort déclenché | proc | DB2, non départagés |
| Spirit of Redemption | 20711 (talent, aura = oui) ; autres « Spirit of Redemption » en SpellName sans lien établi : 27792, 27795, 27827 | buff | DB2 |

## Points non vérifiés

- Wowhead Forever : listes par classe, talents et recherche non exploitables via lecture web (filtres seuls). Une seule page de sort lue (15270). Aucun recoupement Wowhead des IDs de sorts de classe.
- endgametools et wowforevertalents ne publient aucun spell ID : l'ensemble des IDs du tableau repose sur une seule source (wow-forever.gg). Niveaux, coûts, recharges et durées sont concordants entre endgametools et wowforevertalents sur les points comparés.
- IDs de rang des talents : tranchés par le DB2 (voir Talents). Reste non établi : IDs de rang des talents absents de la table Talent (Power in Light, Twin Disciplines, Holy Precision, Improved Mind Flay, Devouring Contagion, Early Demise : un seul ID SpellName chacun ; ordre des rangs de Divine Aegis, Litany of Light, Soul Warding, Renewed Hope et des Penance / Prayer of Mending hors tableau principal).
- Auras sans sort déclenché lié dans le DB2 (Inspiration, Divine Aegis, Blessed Recovery, Weakened Soul) : candidats listés, non départagés. Le DB2 ne dit pas quelles entrées sont actives en jeu.
- Divergences relevées sur wow-forever.gg, tranchées par le DB2 :
  - Blackout rang 1 : DB2 = 15268 (talent rang 1, Talent et SkillLineAbility) ; 15269 est l'aura déclenchée par 15268 et 15323 à 15326. Rangs 2 à 5 : 15323 à 15326 (confirmé).
  - Devouring Plague : DB2 = 2944 et 19276 à 19280 (SkillLineAbility Ombre, aura = oui). 459713 et 1219275 existent dans SpellName mais sont absents de SkillLineAbility et de SpellEffect Prêtre.
  - Power Word: Shield rang 10 : DB2 = 10901 (SkillLineAbility Discipline). 27607 existe dans SpellName (« Power Word: Shield ») mais n'est ni dans SkillLineAbility ni dans Talent : non retenu.
  - Spirit Tap : DB2 = talent 15270 (rangs 15270, 15335 à 15338) qui déclenche l'aura 15271 ; 15271 ne se renvoie pas vers 15270 dans SpellEffect.

### Écarts avec le DB2 client

- Blackout rang 1 : le fichier citait 15269 comme rang 1 ; le DB2 donne 15268 (le tableau Talents garde 15268). 15269 reste l'ID d'aura.
- Rangs max du web différents des rangs DB2 : Wand Specialization (2 / 5), Silent Resolve (3 / 5), Mental Agility (3 / 5), Twilight Focus (3 / 2), Spiritual Healing (3 / 5), Shadow Reach (2 / 3), Shadow Weaving (3 / 5). Le tableau Talents garde les IDs DB2.
- Talents du fichier absents de la table Talent du DB2 : Power in Light, Twin Disciplines, Holy Precision, Soul Warding, Penance, Renewed Hope, Divine Aegis, Binding Heal, Litany of Light, Prayer of Mending, Improved Mind Flay, Devouring Contagion, Early Demise.
- Talents du DB2 absents du fichier : Unbreakable Will, Improved Power Word: Fortitude, Divine Spirit, Force of Will, Lightwell, Improved Vampiric Embrace, un talent sans nom en Sacré 0/4 (14911, 15018).
- IDs 459713 et 1219275 (Devouring Plague) et 27607 (Power Word: Shield) : présents dans le fichier d'origine comme rang ou citation, absents des tables de classe du DB2 (voir divergences).
- Les 242 IDs du tableau des sorts de base ont tous un nom identique dans SpellName : aucun écart.
- Sorts-talents (rang 1 de Holy Nova, Mind Flay, Binding Heal, Penance, Prayer of Mending), Vampiric Embrace, Power Infusion, Lightwell Renew : niveau, coût, recharge non lus dans les sources de recoupement. Les rangs suivants de ces sorts ont les valeurs d'endgametools.
- Prayer of Mending : effet dépendant des stats, aucun chiffre publié. Fear Ward : wowforevertalents note durée 3 min (Classic : 30 s de recharge, 10 min).
- Build beta : les IDs peuvent changer avant la sortie.

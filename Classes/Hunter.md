# Chasseur — WoW Forever 1.60.1
Sources et build lus, date 2026-10-08 :
- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName). Le DB2 fait foi pour les IDs. Il contient aussi des talents et sorts retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- IDs, niveaux : wow-forever.gg `/db/spells/browse/class/hunter/` (build 1.60.1.70245 d'après la page de Rapid Fire), 159 lignes (rangs et effets de pièges inclus).
- Coûts, recharges, durées : endgametools.com `/en/wow-forever/spells/hunter` (build 1.60.1.70205) et wowforevertalents.com `/abilities/hunter/`, concordants. Ces deux sites ne publient PAS d'IDs.
- Talents (noms, rangs, effets courts) : guildorder.com (données bêta, sans IDs).
- Wowhead Forever : pages sort non exploitables (WebFetch ne renvoie pas l'ID), liste `/forever/spells` sans filtre classe.

## Sorts de base (entraîneur)
Coût en mana (sauf mention). Colonne vide = valeur non publiée par les sources. Les niveaux de endgametools sont des niveaux de compétence internes, ignorés ; niveaux ci-dessous = wow-forever.gg (identiques à wowforevertalents).

| Nom | Rang | Spell ID | Niveau | Coût (mana) | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Aspect of the Viper |  | 415423 | 1 |  |  |  |  |
| Auto Shot |  | 75 | 1 |  |  |  |  |
| Heart of the Lion |  | 409580 | 1 | 8% mana base |  |  |  |
| Raptor Strike | 1 | 2973 | 1 | 10 | 6 s |  |  |
| Track Beasts |  | 1494 | 1 |  |  |  |  |
| Aspect of the Monkey |  | 13163 | 4 | 20 |  |  |  |
| Serpent Sting | 1 | 1978 | 4 | 15 |  | 15 s |  |
| Arcane Shot | 1 | 3044 | 6 | 25 | 6 s |  |  |
| Hunter's Mark | 1 | 1130 | 6 | 15 |  | 2 min |  |
| Concussive Shot |  | 5116 | 8 | 8% mana base | 12 s | 4 s |  |
| Raptor Strike | 2 | 14260 | 8 | 25 | 6 s |  |  |
| Aspect of the Hawk | 1 | 13165 | 10 | 20 |  |  |  |
| Call Pet |  | 883 | 10 |  |  |  |  |
| Dismiss Pet |  | 2641 | 10 |  |  |  |  |
| Feed Pet |  | 6991 | 10 |  |  |  |  |
| Revive Pet |  | 982 | 10 | 100% mana base |  |  |  |
| Serpent Sting | 2 | 13549 | 10 | 30 |  | 15 s |  |
| Tame Beast |  | 1515 | 10 | 60% mana base |  | canal 20 s |  |
| Track Humanoids |  | 19883 | 10 |  |  |  |  |
| Arcane Shot | 2 | 14281 | 12 | 35 | 6 s |  |  |
| Distracting Shot | 1 | 20736 | 12 | 20 | 8 s |  |  |
| Mend Pet | 1 | 136 | 12 | 50 |  | 5 s (canal) |  |
| Wing Clip | 1 | 2974 | 12 | 40 |  | 10 s |  |
| Eagle Eye |  | 6197 | 14 | 25 |  | 1 min |  |
| Eyes of the Beast |  | 1002 | 14 | 20 |  | 2 min |  |
| Scare Beast | 1 | 1513 | 14 | 35 | 30 s | 10/15/20 s |  |
| Immolation Trap | 1 | 13795 | 16 | 50 | 30 s | 1 min (piege) |  |
| Immolation Trap Effect | 1 | 13797 | 16 |  |  |  | effet de dégâts du piège |
| Mongoose Bite | 1 | 1495 | 16 | 30 | 5 s |  |  |
| Raptor Strike | 3 | 14261 | 16 | 35 | 6 s |  |  |
| Aspect of the Hawk | 2 | 14318 | 18 | 35 |  |  |  |
| Multi-Shot |  | 2643 | 18 | 13.9% mana base | 6 s |  |  |
| Serpent Sting | 3 | 13550 | 18 | 50 |  | 15 s |  |
| Track Undead |  | 19884 | 18 |  |  |  |  |
| Aimed Shot | 1 | 19434 | 20 | 75 | 6 s |  |  |
| Arcane Shot | 3 | 14282 | 20 | 50 | 6 s |  |  |
| Aspect of the Cheetah |  | 5118 | 20 | 40 |  |  |  |
| Deterrence |  | 19263 | 20 |  |  |  |  |
| Disengage | 1 | 781 | 20 | 50 | 5 s |  |  |
| Distracting Shot | 2 | 14274 | 20 | 30 | 8 s |  |  |
| Freezing Trap | 1 | 1499 | 20 | 50 | 30 s | 1 min (piege) |  |
| Mend Pet | 2 | 3111 | 20 | 90 |  | 5 s (canal) |  |
| Hunter's Mark | 2 | 14323 | 22 | 30 |  | 2 min |  |
| Scorpid Sting |  | 3043 | 22 | 9% mana base |  | 20 s |  |
| Beast Lore |  | 1462 | 24 | 40 |  |  |  |
| Raptor Strike | 4 | 14262 | 24 | 45 | 6 s |  |  |
| Track Hidden |  | 19885 | 24 |  |  |  |  |
| Summon Hawk | 1 | 1293241 | 25 | non lu | 6 s |  |  |
| Trueshot Aura | 1 | 1299346 | 25 | non lu |  | 30 min (rang 3-5) |  |
| Immolation Trap | 2 | 14302 | 26 | 90 | 30 s | 1 min (piege) |  |
| Immolation Trap Effect | 2 | 14298 | 26 |  |  |  | effet de dégâts du piège |
| Rapid Fire |  | 3045 | 26 | 100 | 5 min | 15 s |  |
| Serpent Sting | 4 | 13551 | 26 | 80 |  | 15 s |  |
| Track Elementals |  | 19880 | 26 |  |  |  |  |
| Aimed Shot | 2 | 20900 | 28 | 115 | 6 s |  |  |
| Arcane Shot | 4 | 14283 | 28 | 80 | 6 s |  |  |
| Aspect of the Hawk | 3 | 14319 | 28 | 50 |  |  |  |
| Frost Trap |  | 13809 | 28 | 60 | 30 s | 1 min (piege) |  |
| Mend Pet | 3 | 3661 | 28 | 155 |  | 5 s (canal) |  |
| Aspect of the Beast | 1 | 13161 | 30 | 50 |  |  |  |
| Counterattack | 1 | 19306 | 30 | non lu | 5 s |  |  |
| Counterattack | 2 | 1242634 | 30 | 45 | 5 s |  |  |
| Distracting Shot | 3 | 15629 | 30 | 50 | 8 s |  |  |
| Feign Death |  | 5384 | 30 | 80 | 30 s |  |  |
| Intimidation |  | 19577 | 30 |  |  |  |  |
| Lacerate | 1 | 24118 | 30 | 40 |  | 21 s |  |
| Mongoose Bite | 2 | 14269 | 30 | 40 | 5 s |  |  |
| Scare Beast | 2 | 14326 | 30 | 50 | 30 s | 10/15/20 s |  |
| Scatter Shot |  | 19503 | 30 |  |  |  |  |
| Strider Kick | 1 | 1317257 | 30 |  |  |  |  |
| Enchanted Flare |  | 1221404 | 32 | 50 | 30 s | 30 s |  |
| Flare |  | 1543 | 32 | 50 | 15 s | 30 s |  |
| Raptor Strike | 5 | 14263 | 32 | 55 | 6 s |  |  |
| Track Demons |  | 19878 | 32 |  |  |  |  |
| Trueshot Aura | 2 | 1299348 | 32 | 245 |  | 30 min (rang 3-5) |  |
| Disengage | 2 | 14272 | 34 | 100 | 5 s |  |  |
| Explosive Trap | 1 | 13813 | 34 | 275 | 30 s | 1 min (piege) |  |
| Explosive Trap Effect | 1 | 13812 | 34 |  |  |  | effet de dégâts du piège |
| Serpent Sting | 5 | 13552 | 34 | 115 |  | 15 s |  |
| Aimed Shot | 3 | 20901 | 36 | 160 | 6 s |  |  |
| Arcane Shot | 5 | 14284 | 36 | 105 | 6 s |  |  |
| Immolation Trap | 3 | 14303 | 36 | 135 | 30 s | 1 min (piege) |  |
| Immolation Trap Effect | 3 | 14299 | 36 |  |  |  | effet de dégâts du piège |
| Mend Pet | 4 | 3662 | 36 | 225 |  | 5 s (canal) |  |
| Summon Hawk | 2 | 1293525 | 36 | 105 | 6 s |  |  |
| Viper Sting | 1 | 3034 | 36 | 135 | 15 s | 8 s |  |
| Aspect of the Hawk | 4 | 14320 | 38 | 70 |  |  |  |
| Wing Clip | 2 | 14267 | 38 | 60 |  | 10 s |  |
| Aspect of the Beast | 2 | 1299445 | 40 | 70 |  |  |  |
| Aspect of the Pack |  | 13159 | 40 | 100 |  |  |  |
| Bestial Wrath |  | 19574 | 40 |  |  |  |  |
| Distracting Shot | 4 | 15630 | 40 | 70 | 8 s |  |  |
| Freezing Trap | 2 | 14310 | 40 | 75 | 30 s | 1 min (piege) |  |
| Hunter's Mark | 3 | 14324 | 40 | 45 |  | 2 min |  |
| Lacerate | 2 | 24119 | 40 | 65 |  | 21 s |  |
| Raptor Strike | 6 | 14264 | 40 | 70 | 6 s |  |  |
| Sniper Shot | 1 | 1310687 | 40 | non lu | 15 s | 10 s |  |
| Track Giants |  | 19882 | 40 |  |  |  |  |
| Trueshot Aura | 3 | 19506 | 40 | 325 |  | 30 min (rang 3-5) |  |
| Volley | 1 | 1510 | 40 | 350 |  | 6 s (canal) |  |
| Counterattack | 3 | 20909 | 42 | 65 | 5 s |  |  |
| Serpent Sting | 6 | 13553 | 42 | 150 |  | 15 s |  |
| Aimed Shot | 4 | 20902 | 44 | 210 | 6 s |  |  |
| Arcane Shot | 6 | 14285 | 44 | 135 | 6 s |  |  |
| Explosive Trap | 2 | 14316 | 44 | 395 | 30 s | 1 min (piege) |  |
| Explosive Trap Effect | 2 | 14314 | 44 |  |  |  | effet de dégâts du piège |
| Mend Pet | 5 | 13542 | 44 | 300 |  | 5 s (canal) |  |
| Mongoose Bite | 3 | 14270 | 44 | 50 | 5 s |  |  |
| Aspect of the Wild | 1 | 20043 | 46 | 90 |  |  |  |
| Immolation Trap | 4 | 14304 | 46 | 190 | 30 s | 1 min (piege) |  |
| Immolation Trap Effect | 4 | 14300 | 46 |  |  |  | effet de dégâts du piège |
| Scare Beast | 3 | 14327 | 46 | 75 | 30 s | 10/15/20 s |  |
| Viper Sting | 2 | 14279 | 46 | 175 | 15 s | 8 s |  |
| Aspect of the Hawk | 5 | 14321 | 48 | 90 |  |  |  |
| Disengage | 3 | 14273 | 48 | 150 | 5 s |  |  |
| Raptor Strike | 7 | 14265 | 48 | 85 | 6 s |  |  |
| Sniper Shot | 2 | 1310785 | 48 | 365 | 15 s | 10 s |  |
| Summon Hawk | 3 | 1293526 | 48 | 135 | 6 s |  |  |
| Aspect of the Beast | 3 | 1299446 | 50 | 90 |  |  |  |
| Black Arrow | 1 | 3674 | 50 | - |  | 30 s |  |
| Distracting Shot | 5 | 15631 | 50 | 90 | 8 s |  |  |
| Lacerate | 3 | 24120 | 50 | 80 |  | 21 s |  |
| Serpent Sting | 7 | 13554 | 50 | 190 |  | 15 s |  |
| Track Dragonkin |  | 19879 | 50 |  |  |  |  |
| Trueshot Aura | 4 | 20905 | 50 | 425 |  | 30 min (rang 3-5) |  |
| Volley | 2 | 14294 | 50 | 420 |  | 6 s (canal) |  |
| Aimed Shot | 5 | 20903 | 52 | 260 | 6 s |  |  |
| Arcane Shot | 7 | 14286 | 52 | 160 | 6 s |  |  |
| Mend Pet | 6 | 13543 | 52 | 385 |  | 5 s (canal) |  |
| Counterattack | 4 | 20910 | 54 | 85 | 5 s |  |  |
| Explosive Trap | 3 | 14317 | 54 | 520 | 30 s | 1 min (piege) |  |
| Explosive Trap Effect | 3 | 14315 | 54 |  |  |  | effet de dégâts du piège |
| Aspect of the Wild | 2 | 20190 | 56 | 115 |  |  |  |
| Immolation Trap | 5 | 14305 | 56 | 245 | 30 s | 1 min (piege) |  |
| Immolation Trap Effect | 5 | 14301 | 56 |  |  |  | effet de dégâts du piège |
| Raptor Strike | 8 | 14266 | 56 | 100 | 6 s |  |  |
| Viper Sting | 3 | 14280 | 56 | 215 | 15 s | 8 s |  |
| Aspect of the Hawk | 6 | 14322 | 58 | 110 |  |  |  |
| Hunter's Mark | 4 | 14325 | 58 | 60 |  | 2 min |  |
| Mongoose Bite | 4 | 14271 | 58 | 65 | 5 s |  |  |
| Serpent Sting | 8 | 13555 | 58 | 230 |  | 15 s |  |
| Sniper Shot | 3 | 1310786 | 58 | 365 | 15 s | 10 s |  |
| Volley | 3 | 14295 | 58 | 490 |  | 6 s (canal) |  |
| Aimed Shot | 6 | 20904 | 60 | 310 | 6 s |  |  |
| Arcane Shot | 8 | 14287 | 60 | 190 | 6 s |  |  |
| Aspect of the Beast | 4 | 1299447 | 60 | 110 |  |  |  |
| Aspect of the Falcon |  | 469145 | 60 | 120 |  |  |  |
| Aspect of the Hawk | 7 | 25296 | 60 | 120 |  |  |  |
| Black Arrow | 2 | 14296 | 60 | - |  | 30 s |  |
| Distracting Shot | 6 | 15632 | 60 | 110 | 8 s |  |  |
| Freezing Trap | 3 | 14311 | 60 | 100 | 30 s | 1 min (piege) |  |
| Improved Mend Pet |  | 24406 | 60 |  |  |  |  |
| Lacerate | 4 | 1299332 | 60 | 95 |  | 21 s |  |
| Mend Pet | 7 | 13544 | 60 | 480 |  | 5 s (canal) |  |
| Serpent Sting | 9 | 25295 | 60 | 250 |  | 15 s |  |
| Summon Hawk | 4 | 1293527 | 60 | 190 | 6 s |  |  |
| Tranquilizing Shot |  | 19801 | 60 | 270 | 20 s |  |  |
| Trueshot Aura | 5 | 20906 | 60 | 525 |  | 30 min (rang 3-5) |  |
| Wing Clip | 3 | 14268 | 60 | 80 |  | 10 s |  |

Particularités Forever vues dans la liste (sorts absents de Classic Era ou modifiés) : Heart of the Lion (409580), Aspect of the Viper (415423), Aspect of the Falcon (469145), Summon Hawk (1293241 / 1293525 / 1293526 / 1293527), Sniper Shot (1310687 / 1310785 / 1310786), Strider Kick (1317257), Enchanted Flare (1221404), Counterattack rang 2 (1242634), Aspect of the Beast rangs 2-4 (1299445 / 1299446 / 1299447), Trueshot Aura rangs 1-2 (1299346 / 1299348), Lacerate rang 4 (1299332). Rapid Fire : +40 % vitesse d'attaque à distance ET mêlée en Forever (wow-forever.gg).

## Capacités de familier
Source : DB2 70245 (SkillLineAbility lignes « Pet - <famille> », « Pet - Generic », « Beast Training » ; SpellEffect pour les liens). Une ligne par capacité et par rang, un spell ID présent dans plusieurs familles = une seule ligne. Rang = chaîne « Remplace » du DB2 (vide si le DB2 n'en donne pas). « Sort d'apprentissage » = sort Beast Training (que le chasseur apprend) dont l'effet déclenche la capacité. Les capacités sans aucune ligne « Pet - * » (Harass, Cobra Reflexes...) sont connues par ce déclenchement seul. Lignes « Tamed Pet Passive (DND) », « Hunter Pet Scaling », « Summoning » : passifs techniques.

| Capacité | Rang | Spell ID | Familles | Aura | Sort d'apprentissage |
|---|---|---|---|---|---|
| Arcane Resistance | 1 | 24493 | Generic | oui | 24495 |
| Arcane Resistance | 2 | 24497 | Generic | oui | 24508 |
| Arcane Resistance | 3 | 24500 | Generic | oui | 24509 |
| Arcane Resistance | 4 | 24501 | Generic | oui | 24510 |
| Bite | 1 | 17253 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17254 |
| Bite | 2 | 17255 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17262 |
| Bite | 3 | 17256 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17263 |
| Bite | 4 | 17257 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17264 |
| Bite | 5 | 17258 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17265 |
| Bite | 6 | 17259 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17266 |
| Bite | 7 | 17260 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17267 |
| Bite | 8 | 17261 | Bat, Bear, Boar, Carrion Bird, Cat, Core Hound, Crocilisk, Fox, Gorilla, Hyena, Raptor, Spider, Tallstrider, Turtle, Wind Serpent, Wolf |  | 17268 |
| Charge |  | 27685 | Boar | oui | 28343 |
| Charge | 1 | 7371 | Boar | oui | 7370 |
| Charge | 2 | 26177 | Boar | oui | 26184 |
| Charge | 3 | 26178 | Boar | oui | 26185 |
| Charge | 4 | 26179 | Boar | oui | 26186 |
| Charge | 5 | 26201 | Boar | oui | 26202 |
| Claw | 1 | 16827 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2980 |
| Claw | 2 | 16828 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2981 |
| Claw | 3 | 16829 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2982 |
| Claw | 4 | 16830 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 3667 |
| Claw | 5 | 16831 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2975 |
| Claw | 6 | 16832 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2976 |
| Claw | 7 | 3010 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 2977 |
| Claw | 8 | 3009 | Bear, Bird of Prey, Carrion Bird, Cat, Crab, Raptor, Scorpid |  | 3666 |
| Cobra Reflexes |  | 25076 | aucune ligne Pet - * (cible du sort d apprentissage Beast Training) | oui | 25077 |
| Cower | 1 | 1742 | Generic |  | 1747 |
| Cower | 2 | 1753 | Generic |  | 1748 |
| Cower | 3 | 1754 | Generic |  | 1749 |
| Cower | 4 | 1755 | Generic |  | 1750 |
| Cower | 5 | 1756 | Generic |  | 1751 |
| Cower | 6 | 16697 | Generic |  | 16698 |
| Dash | 1 | 23099 | Bear, Boar, Cat, Crab, Crocilisk, Fox, Gorilla, Hyena, Raptor, Scorpid, Spider, Tallstrider, Turtle, Wolf | oui | 23100 |
| Dash | 2 | 23109 | Bear, Boar, Cat, Crab, Crocilisk, Fox, Gorilla, Hyena, Raptor, Scorpid, Spider, Tallstrider, Turtle, Wolf | oui | 23111 |
| Dash | 3 | 23110 | Bear, Boar, Cat, Crab, Crocilisk, Fox, Gorilla, Hyena, Raptor, Scorpid, Spider, Tallstrider, Turtle, Wolf | oui | 23112 |
| Demoralizing Screech | 1 | 24423 | Carrion Bird | oui | 24424 |
| Demoralizing Screech | 2 | 24577 | Carrion Bird | oui | 24580 |
| Demoralizing Screech | 3 | 24578 | Carrion Bird | oui | 24581 |
| Demoralizing Screech | 4 | 24579 | Carrion Bird | oui | 24582 |
| Dismember | 1 | 1264758 | Crocilisk | oui | 1264937 |
| Dismember | 2 | 1264927 | Crocilisk | oui | 1264939 |
| Dismember | 3 | 1264929 | Crocilisk | oui | 1264970 |
| Dismember | 4 | 1264930 | Crocilisk | oui | 1264971 |
| Dismember | 5 | 1264933 | Crocilisk | oui | 1264972 |
| Dive | 1 | 23145 | Bird of Prey, Carrion Bird, Wind Serpent | oui | 23146 |
| Dive | 2 | 23147 | Bat, Bird of Prey, Carrion Bird, Wind Serpent | oui | 23149 |
| Dive | 3 | 23148 | Bat, Bird of Prey, Carrion Bird, Wind Serpent | oui | 23150 |
| Dust Cloud | 1 | 1265899 | Tallstrider | oui | 1265907 |
| Dust Cloud | 2 | 1265901 | Tallstrider | oui | 1265908 |
| Dust Cloud | 3 | 1265902 | Tallstrider | oui | 1265909 |
| Dust Cloud | 4 | 1265903 | Tallstrider | oui | 1265913 |
| Dust Cloud | 5 | 1265904 | Tallstrider | oui | 1265911 |
| Faster Attack I |  | 1263099 | Generic | oui |  |
| Faster Attack II |  | 1263100 | Generic | oui |  |
| Faster Attack III |  | 1263102 | Generic | oui |  |
| Faster Attack IV |  | 1263104 | Generic | oui |  |
| Faster Attack V |  | 1263107 | Generic | oui |  |
| Faster Attack VI |  | 1263109 | Generic | oui |  |
| Faster Attack VII |  | 1263110 | Generic | oui |  |
| Fire Resistance | 1 | 23992 | Generic | oui | 24440 |
| Fire Resistance | 2 | 24439 | Generic | oui | 24441 |
| Fire Resistance | 3 | 24444 | Generic | oui | 24463 |
| Fire Resistance | 4 | 24445 | Generic | oui | 24464 |
| Frost Resistance | 1 | 24446 | Generic | oui | 24475 |
| Frost Resistance | 2 | 24447 | Generic | oui | 24476 |
| Frost Resistance | 3 | 24448 | Generic | oui | 24477 |
| Frost Resistance | 4 | 24449 | Generic | oui | 24478 |
| Furious Howl | 1 | 24604 | Wolf | oui | 24609 |
| Furious Howl | 2 | 24605 | Wolf | oui | 24608 |
| Furious Howl | 3 | 24603 | Wolf | oui | 24607 |
| Furious Howl | 4 | 24597 | Wolf | oui | 24599 |
| Great Stamina | 1 | 4187 | Generic | oui | 4195 |
| Great Stamina | 2 | 4188 | Generic | oui | 4196 |
| Great Stamina | 3 | 4189 | Generic | oui | 4197 |
| Great Stamina | 4 | 4190 | Generic | oui | 4198 |
| Great Stamina | 5 | 4191 | Generic | oui | 4199 |
| Great Stamina | 6 | 4192 | Generic | oui | 4200 |
| Great Stamina | 7 | 4193 | Generic | oui | 4201 |
| Great Stamina | 8 | 4194 | Generic | oui | 4202 |
| Great Stamina | 9 | 5041 | Generic | oui | 5048 |
| Great Stamina | 10 | 5042 | Generic | oui | 5049 |
| Growl | 1 | 2649 | Generic |  | 1853 |
| Growl | 2 | 14916 | Generic |  | 14922 |
| Growl | 3 | 14917 | Generic |  | 14923 |
| Growl | 4 | 14918 | Generic |  | 14924 |
| Growl | 5 | 14919 | Generic |  | 14925 |
| Growl | 6 | 14920 | Generic |  | 14926 |
| Growl | 7 | 14921 | Generic |  | 14927 |
| Harass |  | 23162 | aucune ligne Pet - * (cible du sort d apprentissage Beast Training) | oui | 23163 |
| Harass |  | 23164 | aucune ligne Pet - * (cible du sort d apprentissage Beast Training) | oui | 23166 |
| Harass |  | 23165 | aucune ligne Pet - * (cible du sort d apprentissage Beast Training) | oui | 23167 |
| Hunter Pet Scaling |  | 415429 | toutes les familles (19) | oui |  |
| Intimidation |  | 19577 | Generic | oui |  |
| Intimidation |  | 24394 | Generic | oui |  |
| Lava Breath | 1 | 444678 | Core Hound | oui | 444680 |
| Lava Breath | 2 | 444681 | Core Hound | oui | 444682 |
| Lightning Breath | 1 | 24844 | Wind Serpent |  | 24845 |
| Lightning Breath | 2 | 25008 | Wind Serpent |  | 25013 |
| Lightning Breath | 3 | 25009 | Wind Serpent |  | 25014 |
| Lightning Breath | 4 | 25010 | Wind Serpent |  | 25015 |
| Lightning Breath | 5 | 25011 | Wind Serpent |  | 25016 |
| Lightning Breath | 6 | 25012 | Wind Serpent |  | 25017 |
| Mine! | 1 | 1265054 | Bird of Prey | oui | 1265059 |
| Mine! | 2 | 1265055 | Bird of Prey | oui | 1265060 |
| Mine! | 3 | 1265056 | Bird of Prey | oui | 1265061 |
| Mine! | 4 | 1265057 | Bird of Prey | oui | 1265062 |
| Mine! | 5 | 1265058 | Bird of Prey | oui | 1265064 |
| Natural Armor | 1 | 24545 | Generic | oui | 24547 |
| Natural Armor | 2 | 24549 | Generic | oui | 24556 |
| Natural Armor | 3 | 24550 | Generic | oui | 24557 |
| Natural Armor | 4 | 24551 | Generic | oui | 24558 |
| Natural Armor | 5 | 24552 | Generic | oui | 24559 |
| Natural Armor | 6 | 24553 | Generic | oui | 24560 |
| Natural Armor | 7 | 24554 | Generic | oui | 24561 |
| Natural Armor | 8 | 24555 | Generic | oui | 24562 |
| Natural Armor | 9 | 24629 | Generic | oui | 24631 |
| Natural Armor | 10 | 24630 | Generic | oui | 24632 |
| Nature Resistance | 1 | 24492 | Generic | oui | 24494 |
| Nature Resistance | 2 | 24502 | Generic | oui | 24511 |
| Nature Resistance | 3 | 24503 | Generic | oui | 24512 |
| Nature Resistance | 4 | 24504 | Generic | oui | 24513 |
| Pet Aggression | 1 | 6311 | Generic | oui |  |
| Pet Aggression | 2 | 6314 | Generic | oui |  |
| Pet Aggression | 3 | 6315 | Generic | oui |  |
| Pet Aggression | 4 | 6316 | Generic | oui |  |
| Pet Aggression | 5 | 6317 | Generic | oui |  |
| Pet Hardiness | 1 | 6280 | Generic | oui |  |
| Pet Hardiness | 2 | 6281 | Generic | oui |  |
| Pet Hardiness | 3 | 6282 | Generic | oui |  |
| Pet Hardiness | 4 | 6283 | Generic | oui |  |
| Pet Hardiness | 5 | 6286 | Generic | oui |  |
| Pet Recovery | 1 | 6328 | Generic | oui |  |
| Pet Recovery | 2 | 6331 | Generic | oui |  |
| Pet Recovery | 3 | 6332 | Generic | oui |  |
| Pet Recovery | 4 | 6333 | Generic | oui |  |
| Pet Recovery | 5 | 6334 | Generic | oui |  |
| Pet Resistance | 1 | 6443 | Generic | oui |  |
| Pet Resistance | 2 | 6444 | Generic | oui |  |
| Pet Resistance | 3 | 6445 | Generic | oui |  |
| Pet Resistance | 4 | 6446 | Generic | oui |  |
| Pet Resistance | 5 | 6447 | Generic | oui |  |
| Pinch | 1 | 1264735 | Crab | oui | 1264745 |
| Pinch | 2 | 1264736 | Crab | oui | 1264749 |
| Pinch | 3 | 1264739 | Crab | oui | 1264750 |
| Pinch | 4 | 1264741 | Crab | oui | 1264751 |
| Pinch | 5 | 1264742 | Crab | oui | 1264752 |
| Prowl | 1 | 24450 | Cat | oui | 24451 |
| Prowl | 2 | 24452 | Cat | oui | 24454 |
| Prowl | 3 | 24453 | Cat | oui | 24455 |
| Savage Rend | 1 | 1265065 | Raptor | oui | 1265831 |
| Savage Rend | 2 | 1265066 | Raptor | oui | 1265833 |
| Savage Rend | 3 | 1265067 | Raptor | oui | 1265834 |
| Savage Rend | 4 | 1265068 | Raptor | oui | 1265835 |
| Savage Rend | 5 | 1265069 | Raptor | oui | 1265836 |
| Scorpid Poison | 1 | 24640 | Scorpid | oui | 24641 |
| Scorpid Poison | 2 | 24583 | Scorpid | oui | 24584 |
| Scorpid Poison | 3 | 24586 | Scorpid | oui | 24588 |
| Scorpid Poison | 4 | 24587 | Scorpid | oui | 24589 |
| Shadow Resistance | 1 | 24488 | Generic | oui | 24490 |
| Shadow Resistance | 2 | 24505 | Generic | oui | 24514 |
| Shadow Resistance | 3 | 24506 | Generic | oui | 24515 |
| Shadow Resistance | 4 | 24507 | Generic | oui | 24516 |
| Shell Shield |  | 26064 | Turtle | oui | 26065 |
| Slower Attack II |  | 1263113 | Generic | oui |  |
| Slower Attack III |  | 1263114 | Generic | oui |  |
| Sonic Blast |  | 1264478 | Bat | oui |  |
| Sonic Blast |  | 1264479 | Bat | oui |  |
| Sonic Blast |  | 1264480 | Bat | oui |  |
| Sonic Blast |  | 1264481 | Bat | oui |  |
| Sonic Blast |  | 1264482 | Bat | oui |  |
| Summoning |  | 1278934 | Bat |  |  |
| Swipe | 1 | 1264494 | Bear |  | 1264727 |
| Swipe | 2 | 1264497 | Bear |  | 1264729 |
| Swipe | 3 | 1264498 | Bear |  | 1264730 |
| Swipe | 4 | 1264501 | Bear |  | 1264731 |
| Swipe | 5 | 1264502 | Bear |  | 1264732 |
| Tamed Pet Passive (DND) |  | 7000 | Boar | oui |  |
| Tamed Pet Passive (DND) |  | 8875 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 17206 | Bat | oui |  |
| Tamed Pet Passive (DND) |  | 17208 | Bear | oui |  |
| Tamed Pet Passive (DND) |  | 17209 | Carrion Bird | oui |  |
| Tamed Pet Passive (DND) |  | 17210 | Cat | oui |  |
| Tamed Pet Passive (DND) |  | 17211 | Crab | oui |  |
| Tamed Pet Passive (DND) |  | 17212 | Crocilisk | oui |  |
| Tamed Pet Passive (DND) |  | 17214 | Gorilla | oui |  |
| Tamed Pet Passive (DND) |  | 17215 | Hyena | oui |  |
| Tamed Pet Passive (DND) |  | 17216 | Bird of Prey | oui |  |
| Tamed Pet Passive (DND) |  | 17217 | Raptor | oui |  |
| Tamed Pet Passive (DND) |  | 17218 | Scorpid | oui |  |
| Tamed Pet Passive (DND) |  | 17219 | Spider | oui |  |
| Tamed Pet Passive (DND) |  | 17220 | Tallstrider | oui |  |
| Tamed Pet Passive (DND) |  | 17221 | Turtle | oui |  |
| Tamed Pet Passive (DND) |  | 17222 | Wind Serpent | oui |  |
| Tamed Pet Passive (DND) |  | 17223 | Fox, Wolf | oui |  |
| Tamed Pet Passive (DND) |  | 19580 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 19581 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 19582 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 19589 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 19591 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 20782 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 20784 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 409365 | toutes les familles (19) | oui |  |
| Tamed Pet Passive (DND) |  | 444831 | Core Hound | oui |  |
| Tendon Rip | 1 | 1265038 | Hyena | oui | 1265043 |
| Tendon Rip | 2 | 1265039 | Hyena | oui | 1265045 |
| Tendon Rip | 3 | 1265040 | Hyena | oui | 1265046 |
| Tendon Rip | 4 | 1265041 | Hyena | oui | 1265047 |
| Tendon Rip | 5 | 1265042 | Hyena | oui | 1265048 |
| Thunderstomp | 1 | 26090 | Gorilla |  | 26094 |
| Thunderstomp | 2 | 26187 | Gorilla |  | 26189 |
| Thunderstomp | 3 | 26188 | Gorilla |  | 26190 |
| Thunderstomp | 4 | 1264455 | Gorilla |  | 1264456 |
| Trickster's Dance |  | 1310612 | Fox | oui | 1310617 |
| Web | 1 | 1265843 | Spider | oui | 1265887 |
| Web | 2 | 1265878 | Spider | oui | 1265888 |
| Web | 3 | 1265880 | Spider | oui | 1265890 |
| Web | 4 | 1265881 | Spider | oui | 1265891 |
| Web | 5 | 1265883 | Spider | oui | 1265892 |
| Beast Training | | 5149 | Beast Training | | |

## Talents
Noms, rangs et effets courts : guildorder.com (bêta). IDs par rang : Talent.csv du DB2 70245, dans l'ordre des rangs (tous les IDs de rang du DB2, nom DB2 = nom du sort de rang 1). Le DB2 contient aussi des talents retirés par correctif serveur : présence ≠ actif en jeu.

### Maîtrise des bêtes
| Nom | Rangs | IDs par rang | Effet court |
|---|---|---|---|
| Improved Aspect of the Hawk | 5 | 19552, 19553, 19554, 19555, 19556 (Talent.csv, case 1/0, nom DB2 « Deadly Aspects ») ; sort nommé « Improved Aspect of the Hawk » : 23559 (hors Talent.csv). Candidats, non tranché | proc vitesse distance, 1-5 % (valeurs bêta variables) |
| Endurance Training | 5 | 19583, 19584, 19585, 19586, 19587 | PV familier +3-15 % |
| Improved Eyes of the Beast | 2 | 19557, 19558 | durée +30/+60 s |
| Improved Aspect of the Monkey | 5 | 19549, 19550, 19551, 24386, 24387 | esquive +1-5 % |
| Thick Hide | 3 | 19609, 19610, 19612 | armure familier +10/20/30 % |
| Improved Revive Pet | 2 | 24443, 19575 | incantation -3/-6 s |
| Pathfinding | 2 | 19559, 19560 | vitesse Cheetah/Pack +3/+6 % |
| Bestial Swiftness | 1 | 19596 | vitesse familier +30 % |
| Unleashed Fury | 5 | 19616, 19617, 19618, 19619, 19620 | dégâts familier +4-20 % |
| Improved Mend Pet | 2 | 19572, 19573 (Talent.csv) ; 24406 = sort passif SkillLineAbility sans rang, autre sort nommé : 23560 | purge 15/50 % |
| Ferocity | 5 | 19598, 19599, 19600, 19601, 19602 | crit familier +3-15 % |
| Spirit Bond | 2 | 19578, 20895 (aussi sorts passifs « Spirit Bond » 24529, 1310725 liés entre eux) | régén 1/2 % PV / 10 s |
| Intimidation | 1 | 19577 | étourdissement 3 s |
| Bestial Discipline | 2 | 19590, 19592 | focus familier +10/+20 % |
| Frenzy | 5 | 19621, 19622, 19623, 19624, 19625 | proc vitesse d'attaque +30 %, chance 20-100 % |
| Bestial Wrath | 1 | 19574 | dégâts familier +50 % 18 s |

### Précision
| Nom | Rangs | IDs par rang | Effet court |
|---|---|---|---|
| Improved Concussive Shot | 5 | 19407, 19412, 19413, 19414, 19415 | chance d'étourdir 3 s |
| Efficiency | 5 | 19416, 19417, 19418, 19419, 19420 | coût tirs/piqûres -2 à -10 % |
| Improved Hunter's Mark | 5 | 19421, 19422, 19423, 19424, 19425 | PA à distance +3-15 % |
| Lethal Shots | 5 | 19426, 19427, 19429, 19430, 19431 (Talent.csv, case 2/1, nom DB2 « Lethal Attacks ») ; sorts nommés « Lethal Shots » : 450403, 462653, 462654, 462656, 462657, 462658 (hors Talent.csv). Candidats, non tranché | crit +1/2/3/5/5 % |
| Aimed Shot | 1 | 19434 (rang 1) | dégâts +70 |
| Improved Arcane Shot | 5 | 19454, 19455, 19456, 19457, 19458 | recharge réduite (valeur non publiée) |
| Hawk Eye | 3 | 19498, 19499, 19500 | portée +2/4/6 m |
| Improved Serpent Sting | 5 | 19464, 19465, 19466, 19467, 19468 | dégâts +2-10 % |
| Mortal Shots | 5 | 19485, 19487, 19488, 19489, 19490 | dégâts crit +6-30 % |
| Scatter Shot | 1 | 19503 | désoriente 4 s |
| Barrage | 3 | 19461, 19462, 24691 | Multi-Shot/Volley +5/10/15 % |
| Improved Scorpid Sting | 3 | non trouvé (absent du DB2 70245) ; Talent.csv a une ligne sans nom en case Marksmanship 2/4 : 19491, 19493, 19494 (3 rangs) | -10/20/30 % endurance |
| Ranged Weapon Specialization | 5 | 19507, 19508, 19509, 19510, 19511 | dégâts +1-5 % |
| Trueshot Aura | 1 | 19506 (Talent.csv, 1 rang, case Marksmanship 1/6, voir écarts) ; sorts Trueshot Aura SkillLineAbility : 1299346, 1299348, 19506, 20905, 20906 | PA groupe +50 (talent niveau 25 en Forever) |

Rapid Fire : un sort nommé Rapid Fire de 28755 (+4 s de durée) est signalé par la page wow-forever.gg de 3045, sans plus de détail.

### Survie
| Nom | Rangs | IDs par rang | Effet court |
|---|---|---|---|
| Monster Slaying | 3 | 24294, 24295 (sorts nommés « Monster Slaying ») ; Talent.csv case Survival 0/0 : 24293, 24294, 24295 (nom DB2 « Improved Tracking »). Candidats, non tranché | dégâts +1-3 % |
| Humanoid Slaying | 3 | 19151, 19152, 19153 | dégâts +1-3 % |
| Deflection | 5 | 19295, 19297, 19298, 19301, 19300 | parade +1-5 % |
| Entrapment | 5 | 19184, 19387, 19388, 19389, 19390 | chance d'entraver 5 s |
| Savage Strikes | 2 | 19159, 19160 | crit Raptor Strike/Mongoose +10/20 % |
| Improved Wing Clip | 5 | 19228, 19232, 19233, 19234, 19235 | chance d'immobiliser 5 s |
| Clever Traps | 2 | 19239, 19245 | durée/dégâts pièges +15/30 % |
| Survivalist | 5 | 19255, 19256, 19257, 19258, 19259 | PV +2-10 % |
| Deterrence | 1 | 19263 | esquive/parade +25 % 10 s |
| Trap Mastery | 2 | non trouvé (absent du DB2 70245) ; Talent.csv case Survival 0/3 : « Survival Tactics » 19376, 19377 (2 rangs, nom différent) | résistance pièges -5/-10 % |
| Surefooted | 3 | 19290, 19294, 24283 | toucher +1-3 % |
| Improved Feign Death | 2 | 19286, 19287 | résistance -2/-4 % |
| Killer Instinct | 3 | 19370, 19371, 19373 | crit +1-3 % |
| Counterattack | 1 | 19306 (rang 1), 1242634 (rang 2), 20909 (rang 3), 20910 (rang 4) | 40 dégâts, immobilise 5 s |
| Lightning Reflexes | 5 | 19168, 19180, 19181, 24296, 24297 | agilité +3-15 % |
| Wyvern Sting | 1 | sorts nommés « Wyvern Sting » : 24335, 24336, 26180, 26233, 1215753 ; Talent.csv a une ligne sans nom en case Survival 1/6 : 19386. Candidats, non tranché ; présence DB2 ≠ actif (file : absent de Forever d'après wowforevertalents) | absent de Forever d'après wowforevertalents |

Summon Hawk (talent niveau 25 ; absent de Talent.csv, sorts en SkillLineAbility Beast Mastery, effet déclenchant le sort 1312639 « Summon Hawk ») : IDs 1293241 / 1293525 / 1293526 / 1293527 (rangs 1-4). Sniper Shot : 1310687 / 1310785 / 1310786.

## Buffs, debuffs et procs à suivre en WeakAuras
IDs issus du DB2 70245. « Aura sur le sort lancé » = le sort lancé porte lui-même un effet APPLY_AURA (colonne aura de SkillLineAbility) ; les auras déclenchées viennent de la section « Sorts déclenchés » (SpellEffect). Candidats de même nom listés quand il y en a plusieurs. Présence DB2 ≠ actif en jeu ; vérification en jeu : `/dump C_UnitAuras` ou `AuraUtil`.

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Rapid Fire | 3045 (aura sur le sort lancé) ; autres sorts nommés Rapid Fire : 28755, 1227772 | buff joueur 15 s | wow-forever.gg |
| Hunter's Mark | 1130, 14323, 14324, 14325 (aura sur le sort lancé) ; autre sort nommé : 1213268 | debuff cible, 2 min | wow-forever.gg |
| Serpent Sting | 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 (aura sur le sort lancé) ; autres lignes SkillLineAbility Marksmanship nommées Serpent Sting : 425728, 425729, 425730, 425732, 425733, 425734, 425735, 425736, 425737 ; autres sorts nommés : 1232979, 1232980, 1232981, 1232982, 1264747, 1287976 | debuff cible, 15 s | idem |
| Viper Sting | 3034, 14279, 14280 (aura sur le sort lancé) | debuff cible, 8 s | idem |
| Scorpid Sting | 3043 (aura sur le sort lancé) ; autre sort nommé : 18545 | debuff cible, 20 s | idem |
| Black Arrow | 3674, 14296 (aura sur le sort lancé) ; autres sorts nommés : 20733, 20734 | debuff cible, 30 s (Forever) | idem |
| Wing Clip | 2974, 14267, 14268 (aura sur le sort lancé) ; autres sorts nommés : 14340, 27633, 1310180 | debuff cible, 10 s | idem |
| Lacerate | 24118, 24119, 24120, 1299332 (aura sur le sort lancé) ; autres sorts nommés : 5422, 414644, 414647, 415760, 468843, 1235826, 1235827 | debuff cible, 21 s | idem |
| Concussive Shot | 5116 (aura sur le sort lancé) ; autres sorts nommés : 17174, 22914, 27634, 1236191 | debuff cible, 4 s | idem |
| Freezing / Frost Trap | sorts lancés 1499, 14310, 14311 et 13809 sans aura (piège). Candidats de nom proche, lien piège vers effet non vérifié : « Freezing Trap Effect » 3355, 14308, 14309 ; « Frost Trap Aura » 13810 ; autres sorts nommés Freezing Trap : 27753, 1285994, 1288849, 1288851, 1288852, 1294351, 1294353, 1294444 | debuff cible | idem |
| Aspects (Hawk, Monkey, Cheetah, Pack, Beast, Wild, Viper, Falcon) | aura sur le sort lancé : Hawk 13165, 14318, 14319, 14320, 14321, 14322, 25296 ; Monkey 13163 ; Cheetah 5118 ; Pack 13159 ; Beast 13161, 1299445, 1299446, 1299447 ; Wild 20043, 20190 ; Viper 415423 (autres sorts nommés : 34074, 415424, 415718) ; Falcon 469145. Auras déclenchées : Hawk vers Quick Shots 6150 ; Beast vers Quick Strikes 1299448 ; Falcon vers Quick Strikes 469144 ; Cheetah et Pack vers Dazed 15571 | buff joueur | idem |
| Trueshot Aura | 1299346, 1299348, 19506, 20905, 20906 (aura sur le sort lancé) | buff groupe 30 min | idem |
| Quick Shots (Improved Aspect of the Hawk, Forever : Deadly Aspects selon Blizzard) | 6150 « Quick Shots » (déclenchée par chaque rang d'Aspect of the Hawk) ; talent : voir Improved Aspect of the Hawk (19552 à 19556, 23559) | proc : +30 % vitesse distance 12 s | guildorder.com |
| Frenzy (familier) | 19615 (déclenchée par 20784 Tamed Pet Passive) ; talent 19621 à 19625 ; autres sorts nommés Frenzy : 19451, 19812, 21340, 22428, 23128, 23342, 26041, 26051, 28371, 428728, 431606, 1215755 | proc familier +30 % vitesse d'attaque | guildorder.com |
| Bestial Wrath | 19574 (aura sur le sort lancé) ; autre sort nommé : 1310831 | buff familier 18 s | idem |
| Deterrence | 19263 (aura sur le sort lancé) | buff joueur 10 s | idem |
| Feign Death | 5384 (aura sur le sort lancé) | buff joueur | idem |

## Points non vérifiés
- Auras : le DB2 donne l'aura sur le sort lancé (effet APPLY_AURA) ou via la section « Sorts déclenchés » ; durées et pourcentages restent à vérifier en jeu. Lien piège vers effet (Freezing Trap Effect, Frost Trap Aura) non vérifié dans le DB2 extrait.
- Talents sans correspondance de nom au DB2 : Improved Scorpid Sting et Trap Mastery (absents), Improved Aspect of the Hawk, Lethal Shots, Monster Slaying, Wyvern Sting (candidats listés dans les tableaux, non tranchés). Rangs de talents sans nom dans SpellName : normal, SpellName ne nomme que le rang 1.
- Capacités de familier : rangs vides quand le DB2 ne donne pas de chaîne « Remplace » (ex. Charge 27685, Harass, Cobra Reflexes) ; niveaux d'apprentissage non lus.
- Coûts de Trueshot Aura rang 1, Sniper Shot rang 1, Summon Hawk rang 1, Counterattack rang 1, Black Arrow : non publiés (sources) ; Aimed Shot rang 1 coût lu sur endgametools seulement (75).
- Durée de Scare Beast : 10/15/20 s selon endgametools par rang ; non confirmée par wowforevertalents.
- Durées de Aspects, de Trueshot Aura rangs 1-2 : non publiées.
- Divergence : endgametools affiche des niveaux internes (15, 42, 62...) différents des niveaux réels (1, 4, 6...) de wowforevertalents et wow-forever.gg. Niveaux retenus : wow-forever.gg.
- Build : wow-forever.gg 1.60.1.70245, endgametools 1.60.1.70205.
- Le total wow-forever.gg annonce 159 lignes (65 capacités distinctes, rangs inclus) ; guildorder indique des valeurs bêta modifiables.

### Écarts avec le DB2 client
- Improved Mend Pet : le fichier donnait 24406 comme ID du talent ; Talent.csv donne 19572, 19573 (24406 existe en SkillLineAbility Beast Mastery, sans rang). Valeur DB2 gardée dans le tableau.
- Trueshot Aura (talent) : le fichier donnait 1299346 comme rang 1 du talent ; Talent.csv a un seul rang, 19506 (case Marksmanship 1/6). Les 5 sorts 1299346, 1299348, 19506, 20905, 20906 existent en SkillLineAbility ; le talent Forever de niveau 25 n'est pas vérifiable par le DB2.
- Noms de talent différents du DB2 (IDs absents du fichier, pas de contradiction d'ID) : Improved Aspect of the Hawk (DB2 : Deadly Aspects), Lethal Shots (DB2 : Lethal Attacks), Monster Slaying (DB2 : Improved Tracking en 0/0), Trap Mastery (DB2 : Survival Tactics en 0/3).
- Wyvern Sting : le fichier le dit absent de Forever ; le DB2 contient une ligne de talent sans nom en Survival 1/6 (19386). Présence DB2 ≠ actif en jeu.
- Les 159 IDs du tableau des sorts de base ont tous été recoupés avec SpellName et SkillLineAbility Hunter : aucun écart de nom ni d'ID.

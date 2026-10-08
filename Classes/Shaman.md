# Chaman — WoW Forever 1.60.1
Sources lues le 2026-10-08 : DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName), qui fait foi (le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu) ; wow-forever.gg (liste `/db/spells/browse/class/shaman/`, 181 entrées, IDs lus dans les URL) ; endgametools.com (build 1.60.1.70245, coûts/recharges/durées par rang, sans IDs) ; wowforevertalents.com (build 1.60.1.70245, plages de niveau, sans IDs) ; guildorder.com (talents, valeurs bêta build 69913) ; page wow-forever.gg de Nature's Swiftness et Stormstrike. Wowhead Forever : pas de filtre par classe, `spell=25311` renvoie Corruption (page sans ID dans le texte récupéré), donc non exploitable comme source d'IDs.

Les IDs de sorts viennent de wow-forever.gg et ont été recoupés avec le DB2 (SkillLineAbility + SpellName : tous les IDs et noms du tableau « Sorts de base » concordent). Les IDs de talents et d'auras viennent du DB2. endgametools et wowforevertalents n'affichent aucun spell ID (les nombres dans leurs liens sont des IDs d'icônes).

## Sorts de base (entraîneur)
Coût en mana (fixe) sauf mention « % base ». Niveau : plage premier-dernier rang (wowforevertalents) ; le niveau par rang n'est pas fiable (voir points non vérifiés). Totems : l'élément est dans Notes.

| Nom | Rang | Spell ID | Niveau (plage) | Coût (mana) | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Healing Wave | 1 | 331 | 1-60 | 25 | — | — | Soin |
| Healing Wave | 2 | 332 | 1-60 | 45 | — | — |  |
| Healing Wave | 3 | 547 | 1-60 | 80 | — | — |  |
| Healing Wave | 4 | 913 | 1-60 | 155 | — | — |  |
| Healing Wave | 5 | 939 | 1-60 | 200 | — | — |  |
| Healing Wave | 6 | 959 | 1-60 | 265 | — | — |  |
| Healing Wave | 7 | 8005 | 1-60 | 340 | — | — |  |
| Healing Wave | 8 | 10395 | 1-60 | 440 | — | — |  |
| Healing Wave | 9 | 10396 | 1-60 | 560 | — | — |  |
| Healing Wave | 10 | 25357 | 1-60 | 620 | — | — |  |
| Lesser Healing Wave | 1 | 8004 | 20-60 | 105 | — | — | Soin |
| Lesser Healing Wave | 2 | 8008 | 20-60 | 145 | — | — |  |
| Lesser Healing Wave | 3 | 8010 | 20-60 | 185 | — | — |  |
| Lesser Healing Wave | 4 | 10466 | 20-60 | 235 | — | — |  |
| Lesser Healing Wave | 5 | 10467 | 20-60 | 305 | — | — |  |
| Lesser Healing Wave | 6 | 10468 | 20-60 | 380 | — | — |  |
| Chain Heal | 1 | 1064 | 40-54 | 260 | — | — | Soin |
| Chain Heal | 2 | 10622 | 40-54 | 315 | — | — |  |
| Chain Heal | 3 | 10623 | 40-54 | 405 | — | — |  |
| Lightning Bolt | 1 | 403 | 1-56 | 15 | — | — | Dégâts Nature |
| Lightning Bolt | 2 | 529 | 1-56 | 30 | — | — |  |
| Lightning Bolt | 3 | 548 | 1-56 | 45 | — | — |  |
| Lightning Bolt | 4 | 915 | 1-56 | 60 | — | — |  |
| Lightning Bolt | 5 | 943 | 1-56 | 85 | — | — |  |
| Lightning Bolt | 6 | 6041 | 1-56 | 110 | — | — |  |
| Lightning Bolt | 7 | 10391 | 1-56 | 135 | — | — |  |
| Lightning Bolt | 8 | 10392 | 1-56 | 160 | — | — |  |
| Lightning Bolt | 9 | 15207 | 1-56 | 190 | — | — |  |
| Lightning Bolt | 10 | 15208 | 1-56 | 220 | — | — |  |
| Chain Lightning | 1 | 421 | 32-56 | 225 | 6 s | — | Dégâts Nature |
| Chain Lightning | 2 | 930 | 32-56 | 305 | 6 s | — |  |
| Chain Lightning | 3 | 2860 | 32-56 | 390 | 6 s | — |  |
| Chain Lightning | 4 | 10605 | 32-56 | 485 | 6 s | — |  |
| Earth Shock | 1 | 8042 | 4-60 | 30 | 6 s | — | Choc (terre), interrompt |
| Earth Shock | 2 | 8044 | 4-60 | 50 | 6 s | — |  |
| Earth Shock | 3 | 8045 | 4-60 | 85 | 6 s | — |  |
| Earth Shock | 4 | 8046 | 4-60 | 145 | 6 s | — |  |
| Earth Shock | 5 | 10412 | 4-60 | 240 | 6 s | — |  |
| Earth Shock | 6 | 10413 | 4-60 | 345 | 6 s | — |  |
| Earth Shock | 7 | 10414 | 4-60 | 450 | 6 s | — |  |
| Flame Shock | 1 | 8050 | 10-60 | 55 | 6 s | 12 s | Choc (feu), DoT |
| Flame Shock | 2 | 8052 | 10-60 | 95 | 6 s | 12 s |  |
| Flame Shock | 3 | 8053 | 10-60 | 160 | 6 s | 12 s |  |
| Flame Shock | 4 | 10447 | 10-60 | 250 | 6 s | 12 s |  |
| Flame Shock | 5 | 10448 | 10-60 | 345 | 6 s | 12 s |  |
| Flame Shock | 6 | 29228 | 10-60 | 410 | 6 s | 12 s |  |
| Frost Shock | 1 | 8056 | 20-58 | 115 | 6 s | 8 s | Choc (givre), ralentit |
| Frost Shock | 2 | 8058 | 20-58 | 225 | 6 s | 8 s |  |
| Frost Shock | 3 | 10472 | 20-58 | 325 | 6 s | 8 s |  |
| Frost Shock | 4 | 10473 | 20-58 | 430 | 6 s | 8 s |  |
| Purge | 1 | 370 | 12-32 | 10% base | — | — | Dissipation, coût 10% mana de base |
| Purge | 2 | 8012 | 12-32 | 10% base | — | — |  |
| Fire Nova | 1 | 408341 | 12-52 | 95 | 10 s | — | Nova de feu (rangs 408341-5, nouvelle série Forever) |
| Fire Nova | 2 | 408342 | 12-52 | 170 | 10 s | — |  |
| Fire Nova | 3 | 408343 | 12-52 | 280 | 10 s | — |  |
| Fire Nova | 4 | 408344 | 12-52 | 395 | 10 s | — |  |
| Fire Nova | 5 | 408345 | 12-52 | 520 | 10 s | — |  |
| Ancestral Spirit | 1 | 2008 | 12-60 | 90% base | — | — | Résurrection, coût 90% mana de base |
| Ancestral Spirit | 2 | 20609 | 12-60 | 90% base | — | — |  |
| Ancestral Spirit | 3 | 20610 | 12-60 | 90% base | — | — |  |
| Ancestral Spirit | 4 | 20776 | 12-60 | 90% base | — | — |  |
| Ancestral Spirit | 5 | 20777 | 12-60 | 90% base | — | — |  |
| Lightning Shield | 1 | 324 | 8-56 | 45 | — | 10 min | Bouclier (aura sur soi) |
| Lightning Shield | 2 | 325 | 8-56 | 80 | — | 10 min |  |
| Lightning Shield | 3 | 905 | 8-56 | 125 | — | 10 min |  |
| Lightning Shield | 4 | 945 | 8-56 | 180 | — | 10 min |  |
| Lightning Shield | 5 | 8134 | 8-56 | 240 | — | 10 min |  |
| Lightning Shield | 6 | 10431 | 8-56 | 305 | — | 10 min |  |
| Lightning Shield | 7 | 10432 | 8-56 | 370 | — | 10 min |  |
| Rockbiter Weapon | 1 | 8017 | 1-54 | 15 | — | 60 min | Arme enchantée |
| Rockbiter Weapon | 2 | 8018 | 1-54 | 25 | — | 60 min |  |
| Rockbiter Weapon | 3 | 8019 | 1-54 | 50 | — | 60 min |  |
| Rockbiter Weapon | 4 | 10399 | 1-54 | 75 | — | 60 min |  |
| Rockbiter Weapon | 5 | 16314 | 1-54 | 100 | — | 60 min |  |
| Rockbiter Weapon | 6 | 16315 | 1-54 | 125 | — | 60 min |  |
| Rockbiter Weapon | 7 | 16316 | 1-54 | 150 | — | 60 min |  |
| Flametongue Weapon | 1 | 8024 | 10-56 | 30 | — | 60 min | Arme enchantée |
| Flametongue Weapon | 2 | 8027 | 10-56 | 55 | — | 60 min |  |
| Flametongue Weapon | 3 | 8030 | 10-56 | 80 | — | 60 min |  |
| Flametongue Weapon | 4 | 16339 | 10-56 | 105 | — | 60 min |  |
| Flametongue Weapon | 5 | 16341 | 10-56 | 130 | — | 60 min |  |
| Flametongue Weapon | 6 | 16342 | 10-56 | 155 | — | 60 min |  |
| Frostbrand Weapon | 1 | 8033 | 20-58 | 60 | — | 60 min | Arme enchantée |
| Frostbrand Weapon | 2 | 8038 | 20-58 | 85 | — | 60 min |  |
| Frostbrand Weapon | 3 | 10456 | 20-58 | 110 | — | 60 min |  |
| Frostbrand Weapon | 4 | 16355 | 20-58 | 135 | — | 60 min |  |
| Frostbrand Weapon | 5 | 16356 | 20-58 | 160 | — | 60 min |  |
| Windfury Weapon | 1 | 8232 | 30-60 | 90 | — | 60 min | Arme enchantée |
| Windfury Weapon | 2 | 8235 | 30-60 | 115 | — | 60 min |  |
| Windfury Weapon | 3 | 10486 | 30-60 | 140 | — | 60 min |  |
| Windfury Weapon | 4 | 16362 | 30-60 | 165 | — | 60 min |  |
| Stoneskin Totem | 1 | 8071 | 4-54 | 30 | — | 5 min | TOTEM TERRE |
| Stoneskin Totem | 2 | 8154 | 4-54 | 60 | — | 5 min |  |
| Stoneskin Totem | 3 | 8155 | 4-54 | 90 | — | 5 min |  |
| Stoneskin Totem | 4 | 10406 | 4-54 | 115 | — | 5 min |  |
| Stoneskin Totem | 5 | 10407 | 4-54 | 160 | — | 5 min |  |
| Stoneskin Totem | 6 | 10408 | 4-54 | 210 | — | 5 min |  |
| Strength of Earth Totem | 1 | 8075 | 10-60 | 25 | — | 5 min | TOTEM TERRE |
| Strength of Earth Totem | 2 | 8160 | 10-60 | 65 | — | 5 min |  |
| Strength of Earth Totem | 3 | 8161 | 10-60 | 125 | — | 5 min |  |
| Strength of Earth Totem | 4 | 10442 | 10-60 | 225 | — | 5 min |  |
| Strength of Earth Totem | 5 | 25361 | 10-60 | 275 | — | 5 min |  |
| Stoneclaw Totem | 1 | 5730 | 8-58 | 15 | 30 s | 15 s | TOTEM TERRE |
| Stoneclaw Totem | 2 | 6390 | 8-58 | 30 | 30 s | 15 s |  |
| Stoneclaw Totem | 3 | 6391 | 8-58 | 55 | 30 s | 15 s |  |
| Stoneclaw Totem | 4 | 6392 | 8-58 | 75 | 30 s | 15 s |  |
| Stoneclaw Totem | 5 | 10427 | 8-58 | 105 | 30 s | 15 s |  |
| Stoneclaw Totem | 6 | 10428 | 8-58 | 140 | 30 s | 15 s |  |
| Earthbind Totem | — | 2484 | 6 | 6% base | 15 s | 45 s | TOTEM TERRE, un seul rang |
| Tremor Totem | — | 8143 | 18 | 60 | — | 5 min | TOTEM TERRE, un seul rang |
| Searing Totem | 1 | 3599 | 10-60 | 25 | — | 30/35/40/45/50/55 s (rangs 1-6) | TOTEM FEU |
| Searing Totem | 2 | 6363 | 10-60 | 45 | — | 30/35/40/45/50/55 s (rangs 1-6) |  |
| Searing Totem | 3 | 6364 | 10-60 | 75 | — | 30/35/40/45/50/55 s (rangs 1-6) |  |
| Searing Totem | 4 | 6365 | 10-60 | 110 | — | 30/35/40/45/50/55 s (rangs 1-6) |  |
| Searing Totem | 5 | 10437 | 10-60 | 145 | — | 30/35/40/45/50/55 s (rangs 1-6) |  |
| Searing Totem | 6 | 10438 | 10-60 | 170 | — | 30/35/40/45/50/55 s (rangs 1-6) |  |
| Magma Totem | 1 | 8190 | 26-56 | 230 | — | 20 s | TOTEM FEU |
| Magma Totem | 2 | 10585 | 26-56 | 360 | — | 20 s |  |
| Magma Totem | 3 | 10586 | 26-56 | 500 | — | 20 s |  |
| Magma Totem | 4 | 10587 | 26-56 | 650 | — | 20 s |  |
| Flametongue Totem | 1 | 8227 | 28-58 | 90 | — | 5 min | TOTEM FEU |
| Flametongue Totem | 2 | 8249 | 28-58 | 140 | — | 5 min |  |
| Flametongue Totem | 3 | 10526 | 28-58 | 200 | — | 5 min |  |
| Flametongue Totem | 4 | 16387 | 28-58 | 275 | — | 5 min |  |
| Fire Resistance Totem | 1 | 8184 | 28-58 | 75 | — | 5 min | TOTEM FEU |
| Fire Resistance Totem | 2 | 10537 | 28-58 | 120 | — | 5 min |  |
| Fire Resistance Totem | 3 | 10538 | 28-58 | 180 | — | 5 min |  |
| Healing Stream Totem | 1 | 5394 | 20-60 | 40 | — | 5 min | TOTEM EAU |
| Healing Stream Totem | 2 | 6375 | 20-60 | 50 | — | 5 min |  |
| Healing Stream Totem | 3 | 6377 | 20-60 | 60 | — | 5 min |  |
| Healing Stream Totem | 4 | 10462 | 20-60 | 70 | — | 5 min |  |
| Healing Stream Totem | 5 | 10463 | 20-60 | 80 | — | 5 min |  |
| Mana Spring Totem | 1 | 5675 | 26-56 | 40 | — | 5 min | TOTEM EAU |
| Mana Spring Totem | 2 | 10495 | 26-56 | 60 | — | 5 min |  |
| Mana Spring Totem | 3 | 10496 | 26-56 | 80 | — | 5 min |  |
| Mana Spring Totem | 4 | 10497 | 26-56 | 100 | — | 5 min |  |
| Mana Tide Totem | 1 | 16190 | 48-58 (rang 1 = talent) | talent | 5 min | 12 s | TOTEM EAU; rang 1 = talent |
| Mana Tide Totem | 2 | 17354 | 48-58 (rang 1 = talent) | 30 | 5 min | 12 s |  |
| Mana Tide Totem | 3 | 17359 | 48-58 (rang 1 = talent) | 60 | 5 min | 12 s |  |
| Poison Cleansing Totem | — | 8166 | 22 | 10% base | — | 5 min | TOTEM EAU, un rang |
| Disease Cleansing Totem | — | 8170 | 38 | 10% base | — | 5 min | TOTEM EAU, un rang |
| Frost Resistance Totem | 1 | 8181 | 24-54 | 75 | — | 5 min | TOTEM EAU |
| Frost Resistance Totem | 2 | 10478 | 24-54 | 120 | — | 5 min |  |
| Frost Resistance Totem | 3 | 10479 | 24-54 | 180 | — | 5 min |  |
| Windfury Totem | 1 | 8512 | 32-52 | 115 | — | 5 min | TOTEM AIR |
| Windfury Totem | 2 | 10613 | 32-52 | 175 | — | 5 min |  |
| Windfury Totem | 3 | 10614 | 32-52 | 250 | — | 5 min |  |
| Grace of Air Totem | 1 | 8835 | 42-60 | 155 | — | 5 min | TOTEM AIR |
| Grace of Air Totem | 2 | 10627 | 42-60 | 250 | — | 5 min |  |
| Grace of Air Totem | 3 | 25359 | 42-60 | 310 | — | 5 min |  |
| Windwall Totem | 1 | 15107 | 36-56 | 115 | — | 5 min | TOTEM AIR |
| Windwall Totem | 2 | 15111 | 36-56 | 170 | — | 5 min |  |
| Windwall Totem | 3 | 15112 | 36-56 | 225 | — | 5 min |  |
| Nature Resistance Totem | 1 | 10595 | 30-60 | 75 | — | 5 min | TOTEM AIR |
| Nature Resistance Totem | 2 | 10600 | 30-60 | 120 | — | 5 min |  |
| Nature Resistance Totem | 3 | 10601 | 30-60 | 180 | — | 5 min |  |
| Grounding Totem | — | 8177 | 30 | 6% base | 15 s | 45 s | TOTEM AIR, un rang |
| Sentry Totem | — | 6495 | 34 | 65 | — | 5 min | TOTEM AIR, un rang |
| Cure Poison | — | 526 | 16 | 9% base | — | — |  |
| Cure Disease | — | 2870 | 22 | 9% base | — | — |  |
| Ghost Wolf | — | 2645 | 20 | 100 | — | — |  |
| Far Sight | — | 6196 | 26 | 80 | — | 1 min |  |
| Water Breathing | — | 131 | 22 | 50 | — | 10 min |  |
| Water Walking | — | 546 | 28 | 95 | — | 10 min |  |
| Astral Recall | — | 556 | 30 | 150 | 15 min | — |  |
| Totemic Projection | — | 437009 | 22 | 25% base | 1 min | — | 25% mana base |
| Totemic Recall | — | 36936 | 20 | — | — | — |  |
| Call of the Elements | — | 66842 | 20 | — | — | — |  |
| Call of the Ancestors | — | 66843 | 30 | — | — | — |  |
| Call of the Spirits | — | 66844 | 40 | — | — | — |  |
| Reincarnation (passif / sort) | — | 20608 | 30 | — | — | — | IDs 20608 (passif) et 21169 (sort) |
| Reincarnation (passif / sort) | — | 21169 | 30 | — | — | — |  |

## Talents
Liste actuelle = wow-forever.gg (50 talents, nom : rangs max). IDs de rang : DB2 Talent (ordre rang 1 à N), sauf indication. Effets chiffrés : guildorder (bêta, peut différer de la liste actuelle).

### Elemental Combat (16)
Convection 5 (16039, 16109, 16110, 16111, 16112) ; Concussion 5 (16035, 16105, 16106, 16107, 16108) ; Elemental Warding 3 (28996, 28997, 28998) ; Reverberation 5 (16040, 16113, 16114, 16115, 16116) ; Call of Flame 3 (16038, 16160, 16161) ; Elemental Devastation 3 (30160, 29179, 29180) ; Elemental Focus 1 (16164 ; prochain sort dégâts à 0 mana, proc sur crit) ; Elemental Alacrity 3 (DB2 : 5 rangs 16578, 16579, 16580, 16581, 16582) ; Improved Fire Nova 2 (16086, 16544) ; Eye of the Storm 3 (29062, 29064, 29065) ; Call of Thunder 1 (DB2 : 5 rangs 16041, 16117, 16118, 16119, 16120 ; nom lu sur 16120 dans SkillLineAbility) ; Elemental Reach 2 (28999, 29000) ; Lightning Overload 3 (absent de Talent ; sort de ce nom dans SpellName : 408438) ; Earthbound 1 (absent de Talent ; sorts de ce nom dans SpellName : 1222988, 1238289, candidats non départagés) ; Elemental Fury 5 (DB2 : 1 rang 16089) ; Lava Burst 1 (ID 408490 pour le sort rang 1 ; absent de Talent).
Elemental Mastery : listé « retiré » par wow-forever.gg, présent chez guildorder ; non trouvé (absent du DB2 70245) par nom (le DB2 Talent a un talent sans nom en colonne 1 rangée 6, ID 16166, non attribué).

### Enhancement (18)
Earth's Grasp 2 (16043, 16130 ; DB2 : arbre Elemental Combat) ; Thundering Strikes 5 (16255, 16302, 16303, 16304, 16305) ; Ancestral Knowledge 5 (17485, 17486, 17487, 17488, 17489) ; Guardian Totems 2 (16258, 16293) ; Mental Dexterity 3 (absent de Talent ; sorts de ce nom dans SpellName : 415140, 415144, 415713, candidats non départagés) ; Improved Ghost Wolf 2 (16262, 16287) ; Improved Lightning Shield 3 (16261, 16290, 16291) ; Elemental Weapons 3 (16266, 29079, 29080) ; Shamanistic Focus 1 (absent de Talent ; sort de ce nom dans SpellName : 1223030) ; Anticipation 3 (DB2 : 5 rangs 16254, 16271, 16272, 16273, 16274) ; Toughness 5 (16252, 16306, 16307, 16308, 16309) ; Flurry 5 (16256, 16281, 16282, 16283, 16284 ; attaque +10/15/20/25/30 % pendant 3 coups après crit, guildorder) ; Stormstrike 1 (ID 17364) ; Spirit Weapons 1 (16268) ; Mental Quickness 2 (absent de Talent ; sort de ce nom dans SpellName : 30812) ; Improved Stormstrike 2 (absent de Talent ; sorts de ce nom dans SpellName : 1223031, 1238931, candidats non départagés) ; Maelstrom Weapon 5 (absent de Talent ; sorts de ce nom dans SpellName : 408498, 408505, 409946, candidats non départagés) ; Rage of the Farseer 1 (ID 425336).

### Restoration (16)
Improved Healing Wave 5 (16182, 16226, 16227, 16228, 16229) ; Totemic Focus 5 (16173, 16222, 16223, 16224, 16225) ; Mindfulness 3 (absent de Talent ; sort de ce nom dans SpellName : 1223033) ; Natural Grace 3 (29187, 29189, 29191) ; Tidal Focus 5 (16179, 16214, 16215, 16216, 16217) ; Improved Reincarnation 2 (16184, 16209) ; Ancestral Healing 3 (16176, 16235, 16240) ; Healing Focus 3 (DB2 : 5 rangs 16181, 16230, 16232, 16233, 16234) ; Water Shield 1 (sort 408510 ; absent de Talent) ; Tidal Mastery 5 (16194, 16218, 16219, 16220, 16221) ; Restorative Totems 5 (16187, 16205, 16206, 16207, 16208) ; Mana Tide Totem 1 (ID 16190) ; Healing Way 3 (29206, 29205, 29202) ; Nature's Swiftness 1 (ID 16188 ; 17116 = version Druide) ; Purification 5 (16178, 16210, 16211, 16212, 16213) ; Riptide 1 (ID 408521 ; absent de Talent).

### IDs de talents retirés (wow-forever.gg, pour info)
Shield Specialization 16253 ; Enhancing Totems 16259 ; Two-Handed Axes and Maces 16269 ; Improved Weapon Totems 29192 ; Weapon Mastery 29082 ; Nature's Guidance 16180 ; Totemic Mastery 16189.

Divergence : guildorder (bêta) liste d'autres talents (Call of Thunder 5, Elemental Mastery, Healing Focus 5, Anticipation 5, Parry, Storm Reach, Lightning Mastery...) que wow-forever.gg (Forever actuel). La liste wow-forever.gg est retenue.

## Buffs, debuffs et procs à suivre en WeakAuras
IDs d'aura issus du DB2 : colonne aura de SkillLineAbility (le sort de rang applique lui-même l'aura), sorts déclenchés de SpellEffect, ou sorts de même nom que le totem sans « Totem » (effet d'aura de zone). Le DB2 s'arrête à la créature invoquée par un totem (effet 28) : le lien totem → sort d'aura n'y figure pas, les sorts d'aura ci-dessous sont des correspondances par nom. Plusieurs IDs listés = candidats non départagés.

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Flame Shock | 8050, 8052, 8053, 10447, 10448, 29228 (le sort de rang applique l'aura) | debuff cible | DB2 SkillLineAbility |
| Frost Shock | 8056, 8058, 10472, 10473 (le sort de rang applique l'aura) | debuff cible (ralentissement) | DB2 SkillLineAbility |
| Stormstrike | 17364 (colonne aura) ; autre sort nommé Stormstrike : 410156 (effet sans aura, hors SkillLineAbility), candidat non départagé ; build 70245 : CD 8 s, buff 12 s, +20 % prochain Lightning Bolt / Chain Lightning / Earth Shock | debuff cible | DB2 SkillLineAbility, wow-forever.gg |
| Lightning Shield | 324, 325, 905, 945, 8134, 10431, 10432 (colonne aura) ; sort déclenché par chaque rang : 26545 | buff joueur | DB2 SkillLineAbility, SpellEffect |
| Rockbiter / Flametongue / Frostbrand / Windfury Weapon | non trouvé (absent du DB2 70245 : les sorts d'enchant n'ont pas d'aura dans le DB2 ; à lire via GetWeaponEnchantInfo) | buff joueur (arme) | — |
| Strength of Earth | 8076, 8162, 8163, 10441, 25362 (sorts « Strength of Earth », aura de zone, par nom) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Grace of Air | 8836, 10626, 25360 (sorts « Grace of Air », aura de zone, par nom) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Windfury Totem | candidats nommés « Windfury Totem » hors invocation : 8515, 10609, 10612 (aura de zone) et 8516, 10608, 10610 (aura + attaque supplémentaire) ; lien avec 8512, 10613, 10614 non donné par le DB2 | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Stoneskin | 8072, 8156, 8157, 10403, 10404, 10405 (sorts « Stoneskin », aura de zone, par nom) ; 28995 « Stoneskin » est un autre sort (effet 6), candidat non départagé | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Windwall | 15108, 15109, 15110 (sorts « Windwall », aura de zone, par nom) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Mana Spring | 5677, 10491, 10493, 10494, 24853 (sorts « Mana Spring », aura de zone ; 24853 appartient à 24854, hors SkillLineAbility) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Healing Stream | 5672, 6371, 6372, 10460, 10461 (sorts « Healing Stream », aura de zone, par nom) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Fire / Frost / Nature Resistance (totems) | Fire Resistance : 8185, 10534, 10535 ; Frost Resistance : 8182, 10476, 10477 ; Nature Resistance : 10596, 10598, 10599 (sorts du nom de la résistance, effet 65 aura de zone, par nom ; d'autres sorts portent ces noms hors totem) | buff joueur (totem) | DB2 SpellName, SpellEffect |
| Elemental Focus (Clearcasting) | 16246 (Clearcasting, déclenché par 16164) | proc | DB2 SpellEffect |
| Elemental Mastery | non trouvé (absent du DB2 70245) | proc / buff | — |
| Flurry | candidats nommés Flurry avec effet de hâte (aura 319) : 16257, 12966, 17687 ; le DB2 ne rattache pas ces sorts à la classe (talent : 16256, 16281, 16282, 16283, 16284) | proc | DB2 SpellName, SpellEffect |
| Windfury Attack | non trouvé (absent du DB2 70245) ; sorts à effet d'attaque supplémentaire sous d'autres noms : 8516, 10608, 10610 (Windfury Totem), 8233, 8236 (Windfury Weapon) | proc | — |
| Nature's Swiftness | 16188 (talent, effet d'aura sur le sort lui-même) | buff joueur | DB2 SkillLineAbility |
| Healing Way | 29206 (seul sort de ce nom, effet d'aura ; 29205 et 29202, rangs 2 et 3 du talent, n'ont ni nom ni effet dans le DB2) | buff cible (soin) | DB2 Talent, SpellEffect |
| Ancestral Healing | 16177 (Ancestral Fortitude, déclenché par 16176) | buff cible | DB2 SpellEffect |
| Eye of the Storm / Focused Casting | Eye of the Storm : 29062 (talent, effet d'aura) ; Focused Casting : 27828 (seul sort de ce nom, hors SkillLineAbility Chaman) | proc | DB2 SpellName, SpellEffect |
| Elemental Devastation | 30160 (talent, rang 1) et 30165 (effet de critique) : candidats non départagés | proc | DB2 SkillLineAbility, SpellEffect |
| Maelstrom Weapon | candidats : 408498, 408505, 409946 (« Maelstrom Weapon »), 408501 (« Maelstrom Ready! ») | proc | DB2 SpellName, SpellEffect |
| Water Shield | 408510 (sort), 408511 (déclenché par 408510), 409941 (autre sort du même nom, effet 332) : candidats non départagés | buff joueur | DB2 SkillLineAbility, SpellEffect |

## Points non vérifiés
- IDs d'aura, de proc et de rang de talent : tirés du DB2 70245 (voir sources). Reste non vérifié en jeu : le DB2 ne relie pas un totem au sort d'aura de sa créature, ni les rangs d'un talent à leur buff ; les IDs d'aura de totems sont des correspondances par nom. Le DB2 contient des talents retirés par correctif serveur : présence ≠ actif en jeu. À confirmer en jeu (`/dump` aura, ou `C_UnitAuras`).
- Wowhead Forever non exploitable (pas de filtre classe ; la page `spell=25311` renvoie Corruption). Aucune vérification croisée des IDs par une deuxième source.
- Niveaux par rang : endgametools donne des valeurs en échelle étrange (13, 42, 85... jusqu'à 601, probablement ×10 ou autre unité) : non reprises ; seules les plages wowforevertalents sont utilisées. Mana Tide Totem rang 1 est un talent.
- Divergence de nombre : wow-forever.gg 181 entrées (inclut doublons Reincarnation, Nature's Swiftness, Rage of the Farseer, talents, Stormstrike) ; endgametools 174 sorts et rangs ; wowforevertalents 52 capacités. Nombre de rangs identique entre endgametools et wow-forever.gg sur les sorts de base.
- Rangs de Fire Nova (408341-408345), Lava Burst (408490, 1238299, 1238300) et Riptide (408521, 1239242, 1239243) : IDs hors plage classique, propres à Forever. Lava Burst et Riptide rang 1 sont des talents.
- Totems et enchants manquants dans la liste Forever : Fire Nova Totem et Tranquil Air Totem absents (wowforevertalents).
- Coûts et durées d'endgametools : durées des Searing Totem par rang (30/35/40/45/50/55 s) déduites de la colonne rang ; non testées en jeu.
- Éléments non cherchés : sorts de racial, compétences d'armes et d'armures, Reincarnation (20608 passif, 21169 sort : rôle exact non vérifié).

### Écarts avec le DB2 client
- Rangs max différents (fichier → DB2 Talent) : Elemental Alacrity 3 → 5 (16578-16582 ; 16579-16582 nommés Lightning Mastery dans SkillLineAbility) ; Elemental Fury 5 → 1 ; Call of Thunder 1 → 5 ; Anticipation 3 → 5 ; Healing Focus 3 → 5. Valeurs DB2 gardées dans le tableau.
- Arbre différent : Earth's Grasp classé Enhancement dans le fichier, Elemental Combat dans le DB2.
- Talents du fichier absents de la table Talent : Lightning Overload, Earthbound, Lava Burst, Mental Dexterity, Shamanistic Focus, Mental Quickness, Improved Stormstrike, Maelstrom Weapon, Rage of the Farseer, Mindfulness, Water Shield, Riptide (seuls des sorts de même nom existent, voir listes ci-dessus).
- Lava Burst : le fichier retient 408490, 1238299, 1238300 ; SkillLineAbility nomme aussi Lava Burst 408491, 1238373, 1238376 (non retenus, rôle non vérifié).
- Elemental Mastery : aucun sort de ce nom dans le DB2 ; talent sans nom en colonne 1 rangée 6 (ID 16166) non attribué.
- Sorts Chaman du DB2 absents du tableau « Sorts de base » : Lava Lash 408507, Molten Blast 425339, Decoy Totem 425874, Earth Shield 408514 et 408519, Healing Rain 415236 et 415242, Ancestral Guidance 409324, 409333 et 409337, Spirit of the Alpha 408696 ; rangs Lightning Bolt (408439-408443, 408472-408477) et Chain Lightning (408479-408484) hors des rangs listés ; Lightning Shield 26363-26370.
- IDs nommés comme des totems du fichier mais hors SkillLineAbility Chaman, non retenus : Windfury Totem 27621 (même créature 7484 que 10614), Mana Spring Totem 24854, Grace of Air Totem 10628.

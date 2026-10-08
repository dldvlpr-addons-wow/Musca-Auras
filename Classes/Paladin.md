# Paladin — WoW Forever 1.60.1
Sources et build lus, date 2026-10-08.
- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName). Le DB2 fait foi pour les IDs. Il contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- IDs et niveaux des sorts d'entraîneur : https://wow-forever.gg/db/spells/browse/class/paladin/ (166 lignes, IDs lus dans les URLs).
- Coût / recharge / durée / cast : https://endgametools.com/en/wow-forever/spells/paladin (158 lignes, build 1.60.1.70205 ; **aucun spell ID** sur cette page). Recoupement partiel : https://wowforevertalents.com/abilities/paladin/ (aucun ID de sort d'entraîneur).
- Effets de talents : https://wowforevertalents.com/paladin/ (aucun ID de talent).
- Auras : pages https://www.wowhead.com/forever/spell=ID (seules pages Wowhead Forever qui ont répondu ; les pages de liste Wowhead renvoient seulement le formulaire de filtres).
- Les 8 lignes sans coût/recharge ci-dessous (« n/l ») sont absentes d'endgametools ; « base » = % de mana de base ; « — » = aucune valeur sur la page.

## Sorts de base (entraîneur)
Niveau et ID : wow-forever.gg. Coût, recharge, durée : endgametools. Les lignes de talent (rang 1 de Holy Shock, Light's Vigil, Holy Shield, Seal of Command) sont dans l'entraîneur-liste classe mais apprises via talent.

### Sceaux et jugement
| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Seal of Righteousness | 1 | 20154 | 1 | 20 Mana | — | 30 s | |
| Seal of Righteousness | 2 | 20287 | 10 | 40 Mana | — | 30 s | |
| Seal of Righteousness | 3 | 20288 | 18 | 60 Mana | — | 30 s | |
| Seal of Righteousness | 4 | 20289 | 26 | 90 Mana | — | 30 s | |
| Seal of Righteousness | 5 | 20290 | 34 | 120 Mana | — | 30 s | |
| Seal of Righteousness | 6 | 20291 | 42 | 140 Mana | — | 30 s | |
| Seal of Righteousness | 7 | 20292 | 50 | 170 Mana | — | 30 s | |
| Seal of Righteousness | 8 | 20293 | 58 | 200 Mana | — | 30 s | |
| Seal of the Crusader | 1 | 21082 | 6 | 25 Mana | — | 30 s | juge 40 s |
| Seal of the Crusader | 2 | 20162 | 12 | 40 Mana | — | 30 s | |
| Seal of the Crusader | 3 | 20305 | 22 | 65 Mana | — | 30 s | |
| Seal of the Crusader | 4 | 20306 | 32 | 90 Mana | — | 30 s | |
| Seal of the Crusader | 5 | 20307 | 42 | 125 Mana | — | 30 s | |
| Seal of the Crusader | 6 | 20308 | 52 | 160 Mana | — | 30 s | |
| Seal of Fury | 1 | 1311649 | 10 | 40 Mana | — | 30 s | taunt au jugement |
| Seal of Fury | 2 | 1311656 | 18 | 60 Mana | — | 30 s | |
| Seal of Fury | 3 | 20163 | 25 | 90 Mana | — | 30 s | |
| Seal of Fury | 4 | 20419 | 34 | 120 Mana | — | 30 s | |
| Seal of Fury | 5 | 20421 | 42 | 140 Mana | — | 30 s | |
| Seal of Fury | 6 | 20422 | 50 | 170 Mana | — | 30 s | |
| Seal of Fury | 7 | 20423 | 58 | 200 Mana | — | 30 s | |
| Seal of Justice | — | 20164 | 22 | 13% base | — | 30 s | juge 10 s |
| Seal of Command | 1 | 20375 | 20 | 65 Mana (wowforevertalents) | — | 30 s | talent |
| Seal of Command | 2 | 20915 | 30 | 110 Mana | — | — | |
| Seal of Command | 3 | 20918 | 40 | 140 Mana | — | — | |
| Seal of Command | 4 | 20919 | 50 | 180 Mana | — | — | |
| Seal of Command | 5 | 20920 | 60 | 210 Mana | — | — | |
| Seal of Light | 1 | 20165 | 30 | 110 Mana | — | 30 s | juge 40 s |
| Seal of Light | 2 | 20347 | 40 | 140 Mana | — | 30 s | |
| Seal of Light | 3 | 20348 | 50 | 180 Mana | — | 30 s | |
| Seal of Light | 4 | 20349 | 60 | 210 Mana | — | 30 s | |
| Seal of Wisdom | 1 | 20166 | 38 | 135 Mana | — | 30 s | juge 40 s |
| Seal of Wisdom | 2 | 20356 | 48 | 170 Mana | — | 30 s | |
| Seal of Wisdom | 3 | 20357 | 58 | 200 Mana | — | 30 s | |
| Judgement | — | 20271 | 4 | 6% base | 10 s | — | |
| Swift Judgement (talent) | — | 1310994 | 1 | n/l | 1 min (wowforevertalents) | — | prochain Judgement gratuit |

Sorts déclenchés par les sceaux (DB2 SpellEffect.EffectTriggerSpell ; tous les sceaux du tableau portent un effet APPLY_AURA) :
| Sceau (Spell ID) | Déclenche (ID) | Remarque |
|---|---|---|
| Seal of Righteousness (20154, 20287-20293) | aucun | Judgement of Righteousness : 20187, 20280-20286 (SkillLineAbility, sans lien de déclenchement) ; 21084 « Seal of Righteousness » remplace 20154 |
| Seal of the Crusader (21082, 20162, 20305-20308) | aucun | Judgement of the Crusader : 20188, 20300-20303 (aura, sans lien) |
| Seal of Fury 20163 / 20419 / 20421 / 20422 / 20423 | 20231 / 20415 + 20411 (Judgement of Fury) / 20416 / 20417 / 20418 | seul 20419 relie 20411 ; 20183, 20412-20414 sans lien |
| Seal of Fury 1311649 / 1311656 | 1311647 / 1311654 | |
| Seal of Justice 20164 | 20170 (Stun, aura) | Judgement of Justice 20184 (aura) |
| Seal of Light 20165 / 20347 / 20348 / 20349 | 20167 / 20333 / 20334 / 20340 | Judgement of Light 20185, 20344-20346 déclenchent 5373 (« Judgement of Light Intermediate ») |
| Seal of Wisdom 20166 / 20356 / 20357 | 20168 / 20350 / 20351 | Judgement of Wisdom 20186, 20354, 20355 déclenchent 1826 (« Judgement of Wisdom Intermediate ») |
| Seal of Command 20375, 20915, 20918, 20919, 20920 | 20424 (Seal of Command) | Judgement of Command : 20425, 20467, 20961-20968 (sans lien) |

### Bénédictions
| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Blessing of Might | 1 | 19740 | 4 | 20 Mana | — | 1 h | |
| Blessing of Might | 2 | 19834 | 12 | 30 Mana | — | 1 h | |
| Blessing of Might | 3 | 19835 | 22 | 45 Mana | — | 1 h | |
| Blessing of Might | 4 | 19836 | 32 | 60 Mana | — | 1 h | |
| Blessing of Might | 5 | 19837 | 42 | 85 Mana | — | 1 h | |
| Blessing of Might | 6 | 19838 | 52 | 110 Mana | — | 1 h | |
| Blessing of Might | 7 | 25291 | 60 | 130 Mana | — | 1 h | |
| Blessing of Wisdom | 1 | 19742 | 14 | 30 Mana | — | 1 h | |
| Blessing of Wisdom | 2 | 19850 | 24 | 45 Mana | — | 1 h | |
| Blessing of Wisdom | 3 | 19852 | 34 | 65 Mana | — | 1 h | |
| Blessing of Wisdom | 4 | 19853 | 44 | 90 Mana | — | 1 h | |
| Blessing of Wisdom | 5 | 19854 | 54 | 115 Mana | — | 1 h | |
| Blessing of Wisdom | 6 | 25290 | 60 | 125 Mana | — | 1 h | |
| Blessing of Kings | — | 20217 | 20 | 8% base | — | 1 h | |
| Blessing of Salvation | — | 1038 | 26 | 8% base | — | 1 h | |
| Blessing of Light | 1 | 19977 | 40 | 85 Mana | — | 1 h | |
| Blessing of Light | 2 | 19978 | 50 | 110 Mana | — | 1 h | |
| Blessing of Light | 3 | 19979 | 60 | 135 Mana | — | 1 h | |
| Blessing of Protection | 1 | 1022 | 10 | 25 Mana | 5 min | 6 s | Forbearance 1 min |
| Blessing of Protection | 2 | 5599 | 24 | 45 Mana | 5 min | 8 s | |
| Blessing of Protection | 3 | 10278 | 38 | 7% base | 5 min | 10 s | |
| Blessing of Freedom | — | 1044 | 18 | 10% base | 20 s | 10 s | |
| Blessing of Sacrifice | 1 | 6940 | 46 | 80 Mana | — | 30 s | |
| Blessing of Sacrifice | 2 | 20729 | 54 | 100 Mana | — | 30 s | |
| Greater Blessing of Might | 1 | 25782 | 52 | 220 Mana | — | 1 h | réactif Symbol of Kings |
| Greater Blessing of Might | 2 | 25916 | 60 | 260 Mana | — | 1 h | |
| Greater Blessing of Wisdom | 1 | 25894 | 54 | 230 Mana | — | 1 h | |
| Greater Blessing of Wisdom | 2 | 25918 | 60 | 250 Mana | — | 1 h | |
| Greater Blessing of Kings | — | 25898 | 60 | 150 Mana | — | 1 h | |
| Greater Blessing of Light | — | 25890 | 60 | 260 Mana | — | 1 h | |
| Greater Blessing of Salvation | — | 25895 | 60 | 16% base | — | 1 h | |

Blessing of Sanctuary et Greater Blessing of Sanctuary : absents de Forever (wowforevertalents).

### Auras
| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Devotion Aura | 1 | 465 | 1 | — | — | aura | |
| Devotion Aura | 2 | 10290 | 10 | — | — | aura | |
| Devotion Aura | 3 | 643 | 20 | — | — | aura | |
| Devotion Aura | 4 | 10291 | 30 | — | — | aura | |
| Devotion Aura | 5 | 1032 | 40 | — | — | aura | |
| Devotion Aura | 6 | 10292 | 50 | — | — | aura | |
| Devotion Aura | 7 | 10293 | 60 | — | — | aura | |
| Retribution Aura | 1 | 7294 | 16 | — | — | aura | |
| Retribution Aura | 2 | 10298 | 26 | — | — | aura | |
| Retribution Aura | 3 | 10299 | 36 | — | — | aura | |
| Retribution Aura | 4 | 10300 | 46 | — | — | aura | |
| Retribution Aura | 5 | 10301 | 56 | — | — | aura | |
| Concentration Aura | — | 19746 | 22 | — | — | aura | |
| Shadow Resistance Aura | 1 | 19876 | 28 | — | — | aura | |
| Shadow Resistance Aura | 2 | 19895 | 40 | — | — | aura | |
| Shadow Resistance Aura | 3 | 19896 | 52 | — | — | aura | |
| Frost Resistance Aura | 1 | 19888 | 32 | — | — | aura | |
| Frost Resistance Aura | 2 | 19897 | 44 | — | — | aura | |
| Frost Resistance Aura | 3 | 19898 | 56 | — | — | aura | |
| Fire Resistance Aura | 1 | 19891 | 36 | — | — | aura | |
| Fire Resistance Aura | 2 | 19899 | 48 | — | — | aura | |
| Fire Resistance Aura | 3 | 19900 | 60 | — | — | aura | |

### Soins
| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Holy Light | 1 | 635 | 1 | 35 Mana | — | cast 2,5 s | |
| Holy Light | 2 | 639 | 6 | 60 Mana | — | 2,5 s | |
| Holy Light | 3 | 647 | 14 | 110 Mana | — | 2,5 s | |
| Holy Light | 4 | 1026 | 22 | 190 Mana | — | 2,5 s | |
| Holy Light | 5 | 1042 | 30 | 275 Mana | — | 2,5 s | |
| Holy Light | 6 | 3472 | 38 | 365 Mana | — | 2,5 s | |
| Holy Light | 7 | 10328 | 46 | 465 Mana | — | 2,5 s | |
| Holy Light | 8 | 10329 | 54 | 580 Mana | — | 2,5 s | |
| Holy Light | 9 | 25292 | 60 | 660 Mana | — | 2,5 s | |
| Flash of Light | 1 | 19750 | 20 | 35 Mana | — | cast 1,5 s | |
| Flash of Light | 2 | 19939 | 26 | 50 Mana | — | 1,5 s | |
| Flash of Light | 3 | 19940 | 34 | 70 Mana | — | 1,5 s | |
| Flash of Light | 4 | 19941 | 42 | 90 Mana | — | 1,5 s | |
| Flash of Light | 5 | 19942 | 50 | 115 Mana | — | 1,5 s | |
| Flash of Light | 6 | 19943 | 58 | 140 Mana | — | 1,5 s | |
| Holy Shock | 1 | 1311606 | 30 | 160 Mana (wowforevertalents) | 10 s | — | talent ; absent d'endgametools |
| Holy Shock | 2 | 20473 | 40 | 225 Mana | 10 s | — | |
| Holy Shock | 3 | 20929 | 48 | 275 Mana | 10 s | — | |
| Holy Shock | 4 | 20930 | 56 | 325 Mana | 10 s | — | |
| Light's Vigil | 1 | 1310911 | 40 | 730 Mana (wowforevertalents) | 6 s | 30 s | talent |
| Light's Vigil | 2 | 1311590 | 50 | 1000 Mana | 6 s | 30 s | |
| Light's Vigil | 3 | 1311595 | 60 | 1340 Mana | 6 s | 30 s | |
| Lay on Hands | 1 | 633 | 10 | tout le mana | 20 min | — | |
| Lay on Hands | 2 | 2800 | 30 | tout le mana | 20 min | — | |
| Lay on Hands | 3 | 10310 | 50 | tout le mana | 20 min | — | |
| Redemption | 1 | 7328 | 12 | 80% base | — | cast 10 s | |
| Redemption | 2 | 10322 | 24 | 80% base | — | 10 s | |
| Redemption | 3 | 10324 | 36 | 80% base | — | 10 s | |
| Redemption | 4 | 20772 | 48 | 80% base | — | 10 s | |
| Redemption | 5 | 20773 | 60 | 80% base | — | 10 s | |
| Purify | — | 1152 | 8 | 8% base | — | — | |
| Cleanse | — | 4987 | 42 | 8% base | — | — | |

### Dégâts, contrôle, défensifs, divers
| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Holy Strike | 1 | 679 | 6 | 5 Mana | 10 s | — | |
| Holy Strike | 2 | 678 | 12 | 9 Mana | 10 s | — | |
| Holy Strike | 3 | 1866 | 20 | 12 Mana | 10 s | — | |
| Holy Strike | 4 | 680 | 28 | 14 Mana | 10 s | — | |
| Holy Strike | 5 | 2495 | 36 | 16 Mana | 10 s | — | |
| Holy Strike | 6 | 5569 | 44 | 17 Mana | 10 s | — | |
| Holy Strike | 7 | 10332 | 52 | 19 Mana | 10 s | — | |
| Holy Strike | 8 | 10333 | 60 | 20 Mana | 10 s | — | |
| Exorcism | 1 | 879 | 20 | 85 Mana | 15 s | — | |
| Exorcism | 2 | 5614 | 28 | 135 Mana | 15 s | — | |
| Exorcism | 3 | 5615 | 36 | 180 Mana | 15 s | — | |
| Exorcism | 4 | 10312 | 44 | 235 Mana | 15 s | — | |
| Exorcism | 5 | 10313 | 52 | 285 Mana | 15 s | — | |
| Exorcism | 6 | 10314 | 60 | 345 Mana | 15 s | — | |
| Consecration | 1 | 26573 | 20 | 135 Mana | 8 s | 8 s | |
| Consecration | 2 | 20116 | 30 | 235 Mana | 8 s | 8 s | |
| Consecration | 3 | 20922 | 40 | 320 Mana | 8 s | 8 s | |
| Consecration | 4 | 20923 | 50 | 435 Mana | 8 s | 8 s | |
| Consecration | 5 | 20924 | 60 | 565 Mana | 8 s | 8 s | |
| Hammer of Wrath | 1 | 24275 | 44 | 295 Mana | 6 s | cast 1 s | cible <= 20% PV |
| Hammer of Wrath | 2 | 24274 | 52 | 360 Mana | 6 s | 1 s | |
| Hammer of Wrath | 3 | 24239 | 60 | 425 Mana | 6 s | 1 s | |
| Holy Wrath | 1 | 2812 | 50 | 645 Mana | 1 min | cast 2 s | |
| Holy Wrath | 2 | 10318 | 60 | 805 Mana | 1 min | 2 s | |
| Hammer of the Righteous | — | 407632 | 40 | 6% base | 6 s | — | |
| Hammer of Justice | 1 | 853 | 8 | 30 Mana | 1 min | stun 3 s | |
| Hammer of Justice | 2 | 5588 | 24 | 50 Mana | 1 min | 4 s | |
| Hammer of Justice | 3 | 5589 | 40 | 75 Mana | 1 min | 5 s | |
| Hammer of Justice | 4 | 10308 | 54 | 100 Mana | 1 min | 6 s | |
| Divine Protection | 1 | 498 | 6 | 15 Mana | 5 min | 6 s | Forbearance |
| Divine Protection | 2 | 5573 | 18 | 35 Mana | 5 min | 8 s | |
| Divine Shield | 1 | 642 | 34 | 75 Mana | 5 min | 10 s | |
| Divine Shield | 2 | 1020 | 50 | 110 Mana | 5 min | 12 s | |
| Holy Shield | 1 | 20925 | 40 | 150 Mana (wowforevertalents) | 10 s | 10 s | talent |
| Holy Shield | 2 | 20927 | 50 | 195 Mana | 10 s | 10 s | |
| Holy Shield | 3 | 20928 | 60 | 240 Mana | 10 s | 10 s | |
| Righteous Fury | — | 25780 | 16 | 30% base | — | 30 min | |
| Divine Intervention | — | 19752 | 30 | — | 1 h | 3 min | réactif Symbol of Divinity |
| Turn Undead | 1 | 2878 | 24 | 35 Mana | 30 s | 10 s | |
| Turn Undead | 2 | 5627 | 38 | 50 Mana | 30 s | 15 s | |
| Turn Undead | 3 | 10326 | 52 | 75 Mana | 30 s | 20 s | |
| Sense Undead | — | 5502 | 20 | — | — | — | |
| Repentance (talent) | — | 20066 | 20 | 60 Mana (wowforevertalents) | 1 min | 6 s | |
| Voice of Truth (talent) | — | 1310897 | 20 | n/l | 3 min | 6 s | |
| Templar's Bulwark (talent) | — | 1311015 | 30 | 110 Mana (wowforevertalents) | 5 min | 8 s | Forbearance 1 min |

## Talents
Noms, rangs max et effets : wowforevertalents.com/paladin. Les sources web ne publiaient aucun ID de talent par rang ; les IDs ci-dessous viennent du DB2 (Talent.csv : IDs de rang 1 à N dans l'ordre ; SkillLineAbility / SpellName pour les talents Forever absents de Talent.csv, où un seul ID est trouvé). « Rangs : IDs » : nombre de rangs du fichier, puis IDs du DB2 ; quand les deux nombres diffèrent, c'est indiqué (voir « Écarts avec le DB2 client »).

### Holy (17)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Divine Strength | 5 : 20262, 20263, 20264, 20265, 20266 | Force +2% à +10% |
| Divine Intellect | 5 : 20257, 20258, 20259, 20260, 20261 | Intelligence +2% à +10% |
| Healing Light | 3 : 20237, 20238, 20239 | Soins +4% à +12% |
| Spiritual Focus | 2 (fichier) ; DB2 : 5 IDs : 20205, 20206, 20207, 20209, 20208 | Évite la perte de cast 35% / 70% |
| Improved Seals | 3 (fichier) ; DB2 : 5 IDs : 20224, 20225, 20330, 20331, 20332 | Dégâts sceau/jugement +5% à +15% |
| Unyielding Faith | 2 : 9453, 25836 | Durée peur/désorientation -15% / -30% |
| Voice of Truth | 1 : 1310897 (SkillLineAbility ; absent de Talent.csv) | Immunité silence/interruption 6 s, 3 min |
| Reverence | 3 : 1310899 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; IDs des autres rangs non trouvés) | Regen mana en cast +10% à +30% |
| Purifying Power | 2 : candidats 429144, 429254 (SpellName seul, non départagés) | Coût Cleanse/Purify -10/-20% ; recharge Exorcism/Holy Wrath -17/-33% |
| Infusion of Light | 2 : candidats 53672, 426065, 426179, 437063, 437877 (SpellName seul, non départagés) | Cast Holy Light -0,5 / -1 s, fenêtre 15 s |
| Illumination | 5 : 20210, 20212, 20213, 20214, 20215 (20210 = fiche « Illumination », buff, pas de durée) | Proc 20% à 100%, rend 50% du coût de base |
| Divine Favor | 1 : 20216 (page « Divine Favor », buff) | Prochain soin 100% critique, 2 min |
| Divine Precision | 3 : 1310904 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; IDs des autres rangs non trouvés) | Toucher Sacré +6% à +18% |
| Holy Shock | 1 : candidats 20473 (Talent.csv) et 1311606 (SkillLineAbility, Holy Shock rang 1 du tableau) | 129-139 dégâts / 110-118 soins, 160 mana, 10 s |
| Consecrated Ground | 2 : 1310905 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; ID du rang 2 non trouvé) | Dégâts sacrés sur 4 premiers ennemis +5/+10% |
| Holy Power | 5 : 5923, 5924, 5925, 5926, 25829 | Crit Holy Shock/Holy Strike +3% à +15% ; autres +1% à +5% |
| Light's Vigil | 1 : 1310911 (SkillLineAbility ; absent de Talent.csv ; rangs 2-3 = 1311590, 1311595) | 730 mana, 30 s, 6 s recharge |

### Protection (16)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Toughness | 5 : 20143, 20144, 20145, 20146, 20147 | Armure objets +2% à +10% |
| Redoubt | 5 : 20127, 20130, 20135, 20136, 20137 (bloc 4/8/12/16/20) | Proc 10% ; buff bloc 10 s ou 5 blocs |
| Precision | 3 : 20189, 20192, 20193 | Toucher +1% à +3% |
| Guardian's Favor | 2 : 20174, 20175 | Recharge BoP -1/-2 min ; BoF +3/+6 s |
| Anticipation | 5 : 20096, 20097, 20098, 20099, 20100 | Défense +4 à +20 |
| Improved Seal of Fury | 1 : candidats 1314103 (SkillLineAbility) et 1314104 (SpellName seul), non départagés | Rend 60 mana |
| Improved Righteous Fury | 3 : 20468, 20469, 20470 | Dégâts subis -2% à -6% |
| Shield Specialization | 3 : 20148, 20149, 20150 | Absorption bouclier +10% à +30% |
| Sacred Duty | 2 : 1224697 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; ID du rang 2 non trouvé) | Endurance +2/+4% ; recharge boucliers -30/-60 s |
| Swift Judgement | 1 : 1310994 (SkillLineAbility ; 467530 = autre sort de même nom dans SpellName) | 1 min, prochain Judgement gratuit |
| One-Handed Weapon Specialization | 3 (fichier) ; DB2 : 5 IDs : 20196, 20197, 20198, 20199, 20200 | Dégâts 1 main +3% à +10% |
| Improved Hammer of Justice | 3 : 20487, 20488, 20489 | Recharge -5 à -15 s |
| Templar's Bulwark | 1 : 1311015 | 110 mana, 5 min, absorbe 100% PV max 8 s |
| Reckoning | 5 : 20177, 20179, 20181, 20180, 20182 (ordre du DB2 ; bloc 8/16/24/32/40) | Attaque supplémentaire après blocage / crit |
| Iron Creed | 5 : candidats 1311033, 1311034 (SpellName seul, non départagés) | Menace Holy Strike +5% à +25% |
| Holy Shield | 1 : 20925 (Talent.csv ; rangs 2-3 = 20927, 20928) | 150 mana, bloc +30%, 10 s, 4 charges |

### Retribution (17)
| Nom | Rangs : IDs | Effet court |
|---|---|---|
| Deflection | 5 : 20060, 20061, 20062, 20063, 20064 | Parade +1% à +5% |
| Benediction | 5 : 20101, 20102, 20103, 20104, 20105 | Coût sorts instantanés -2% à -10% |
| Improved Judgement | 2 : 25956, 25957 | Recharge Judgement -1 / -2 s |
| Holy Conduit | 2 : 1237268 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; ID du rang 2 non trouvé) | Coût Consecration/Holy Wrath/Exorcism/Hammer of Wrath -20/-40% |
| Conviction | 5 : 20117, 20118, 20119, 20120, 20121 | Crit mêlée +1% à +5% |
| Vindication | 3 : 9452, 26016, 26021 (67 = autre sort de même nom, SkillLineAbility, aura, non relié) | Force/Agilité de la cible -5% 10 s (rang 1) |
| Sanctified Judgement | 3 : candidats 1311074 (SkillLineAbility) et 1311077 (SpellName seul), non départagés | Retour de mana au jugement |
| Seal of Command | 1 : 20375 (Talent.csv) | 65 mana, 70% arme, 30 s |
| Pursuit of Justice | 2 : 26022, 26023 | Vitesse +8% / +15% |
| Eye for an Eye | 2 : 9799, 25988 (25997 = autre sort de même nom, SkillLineAbility, sans aura, non relié) | Renvoie 5/10% des crits subis |
| Sacred Arbiter | 1 : 1311087 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility) | Holy Strike +20% |
| Two-Handed Weapon Specialization | 3 : 20111, 20112, 20113 | Dégâts 2 mains +2% à +6% |
| Vengeance | 3 (fichier) ; DB2 : 5 IDs : 20049, 20056, 20057, 20058, 20059 | +1% à +3% par cumul, 3 cumuls, 30 s |
| Repentance | 1 : 20066 | 60 mana, 20 m, 1 min, 6 s |
| Champion of the Light | 3 : 1311084 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; IDs des autres rangs non trouvés) | Dégâts sorts 20% à 60% de l'Intelligence |
| Instrument of Law | 2 : 1311085 (seul ID de ce nom, SpellName ; ni Talent ni SkillLineAbility ; ID du rang 2 non trouvé) | Cast Hammer of Wrath -0,5 / -1 s |
| Twist of Light | 1 : 1310735 (SkillLineAbility ; absent de Talent.csv) | Coût sceaux -20% |

Talents Classic retirés de Forever (wow-forever.gg, IDs Classic cités par la page) : Consecration 26573 (devenu sort d'entraîneur), Improved Blessing of Wisdom 20244, Lasting Judgement 20359, Improved Devotion Aura 20138, Blessing of Kings 20217 (devenu sort d'entraîneur), Improved Concentration Aura 20254, Improved Blessing of Might 20042, Improved Seal of the Crusader 20335, Improved Retribution Aura 20091, Sanctity Aura 20218. Le DB2 70245 contient encore tous ces talents dans Talent.csv, avec les mêmes IDs de rang 1 (rangs : 20244-20245, 20359-20361, 20138-20142, 20254-20256, 20042/20045-20048, 20335-20337, 20091-20092, 20218, 26573, 20217) : présence dans le DB2 ≠ actif en jeu.

## Buffs, debuffs et procs à suivre en WeakAuras
Lus sur https://www.wowhead.com/forever/spell=ID. « Type » = type annoncé par Wowhead (qui classe tout en « Buff ») ; la colonne indique l'usage WeakAuras.
| Nom | Spell ID de l'aura | Type | Source / remarque |
|---|---|---|---|
| Judgement of the Crusader | candidats 21183 (fichier ; SpellName seul) et 20188, 20300-20303 (SkillLineAbility, aura) | debuff cible | Wowhead : 40 s, +24 dégâts Holy subis ; non départagés |
| Judgement of Light | 20185 | debuff cible | Wowhead : 40 s ; DB2 : aura, déclenche 5373 ; rangs 20344-20346 |
| Judgement of Wisdom | 20186 | debuff cible | Wowhead : 40 s ; DB2 : aura, déclenche 1826 ; rangs 20354, 20355 |
| Judgement of Justice | 20184 | debuff cible | Wowhead : 10 s ; DB2 : aura (SkillLineAbility) |
| Forbearance | 25771 | debuff joueur | Wowhead : 1 min, immunité (Divine Shield/Protection, BoP, Templar's Bulwark). DB2 : seul déclencheur trouvé = Avenging Wrath 407788 (aucun EffectTriggerSpell pour les autres sorts cités) |
| Redoubt (proc) | 20128 | proc buff joueur | Wowhead : 10 s, bloc +31% (valeur page) ; talent = 20127 (rangs 20127, 20130, 20135-20137). 20128 existe dans SpellName ; aucun lien de déclenchement 20127 vers 20128 dans le DB2 |
| Vengeance (buff) | 20050 | proc buff joueur | Wowhead : 30 s, +4% dégâts Holy/Physique (rang 1 ?) ; talent = 20049. DB2 : 20049 déclenche 20050 (aura), confirmé |
| Reckoning | 20178 | proc | Wowhead : proc trigger caché, 100% ; talent = 20177. DB2 : 20177 déclenche 20178, confirmé (20178 non marqué aura) |
| Divine Favor | 20216 | buff joueur | fiche Wowhead sans durée ; DB2 : aura |
| Illumination | 20210 | proc | fiche Wowhead sans durée ; DB2 : 20210 déclenche 18350 « Dummy Trigger » |
| Seals / Blessings / Auras / Divine Shield / Divine Protection / BoP / Holy Shield | ID du sort lancé (voir tableaux) | buff joueur | DB2 : tous ces sorts portent un effet APPLY_AURA (colonne aura) ; ce n'est pas la preuve que l'ID de l'aura posée est celui du sort lancé. Auras déclenchées par les sceaux : voir tableau des sceaux |

## Points non vérifiés
- Les sources web ne donnaient aucun ID de talent par rang ; ils viennent désormais du DB2 (Talent.csv). Redoubt 20127 / Reckoning 20177 / Vengeance 20049 / Divine Favor 20216 / Illumination 20210 sont confirmés comme talents par Talent.csv.
- Talents Forever absents de Talent.csv : seuls SkillLineAbility ou SpellName donnent un ID (un seul, sans les autres rangs). Ceux de SpellName seul (Reverence, Divine Precision, Consecrated Ground, Sacred Duty, Holy Conduit, Sacred Arbiter, Champion of the Light, Instrument of Law) sont reliés au talent par le nom uniquement.
- Talent.csv contient deux talents sans nom dans SpellName : Holy colonne 2 / rangée 2 (20234, 20235) et Protection colonne 1 / rangée 4 (20911) ; non reliés à un talent du fichier.
- Illumination et Divine Favor : IDs de fiches lus, mais sans durée ni lien clair avec le buff réel (DB2 : 20210 déclenche 18350 « Dummy Trigger »).
- 20178 : la fiche 20177 renvoie un titre « Spell ID 20178 » pour Reckoning ; le rôle (proc ou passif) vient de cette seule lecture.
- Redoubt 20128 : valeur de bloc lue 31% sur la page alors que le talent annonce +4% à +20% par rang (probable valeur indépendante du rang, à tester en jeu).
- Vengeance 20050 : 4% ; le talent annonce +1% à +3% par cumul (3 cumuls). Fiche rang 1 uniquement ; ID des cumuls non trouvé.
- IDs d'aura pour les sceaux actifs, bénédictions, auras de joueur : le DB2 confirme un effet APPLY_AURA sur chaque sort lancé, pas l'ID de l'aura posée (hypothèse = ID du sort lancé).
- Greater Blessing of Light/Kings/Salvation : pas de rang dans les sources.
- Niveaux : wow-forever.gg ; la colonne « Level » d'endgametools est sur une autre échelle (13, 42, 64... = niveau x ~10) et n'a pas été utilisée ; wowforevertalents donne des niveaux de plage cohérents.
- Divergences entre sources : wowforevertalents donne Seal of Command R2-5 / Holy Shield R2-3 / Holy Shock R3-4 / Light's Vigil R2-3 comme sorts d'entraîneur, avec rang 1 = talent ; wow-forever.gg liste les rangs 1 avec un niveau (30 ou 40). Endgametools ne liste pas Holy Shock R1, Light's Vigil R1, Holy Shield R1, Seal of Command R1 (marqués talent), ni Repentance, Voice of Truth, Swift Judgement, Templar's Bulwark, ni Judgement/Seal of Fury R1 : coûts des lignes concernées issues de wowforevertalents ou « n/l ».
- Wowhead Forever : pages de liste (spells, abilities/paladin, talents/paladin) renvoient seulement le formulaire de filtres via WebFetch ; seules les pages /spell=ID ont fourni des données. endgametools : 158 lignes ; wow-forever.gg : 166 lignes (8 de plus : talents + Swift Judgement, Voice of Truth, Repentance, Templar's Bulwark, Holy Shield R1, Holy Shock R1, Light's Vigil R1, Seal of Fury R1 ou Seal of Command R1). Écart non explicité par les sources ; le tableau du fichier compte 166 lignes, dont exactement 8 lignes de talent (Holy Shock R1, Light's Vigil R1, Holy Shield R1, Seal of Command R1, Swift Judgement, Voice of Truth, Repentance, Templar's Bulwark) : 166 - 8 = 158, cohérent avec la page endgametools qui les omet. Le DB2 ne contient pas de liste « sorts d'entraîneur » pour le vérifier directement ; il confirme que ces 8 sorts existent (SkillLineAbility), dont 4 comme talents dans Talent.csv (Holy Shock 20473, Holy Shield 20925, Seal of Command 20375, Repentance 20066).
- Cooldown/durées issus des textes endgametools (pas de champ dédié) ; Seal of Justice juge 10 s, Seal of the Crusader juge 40 s (wowforevertalents).

### Écarts avec le DB2 client
Valeur du DB2 gardée dans les tableaux ; ancienne valeur du fichier citée ici.
1. Holy Shock rang 1 : le fichier donnait 1311606 ; Talent.csv donne 20473 pour le talent, SkillLineAbility contient 1311606 (Holy Shock). Les deux sont listés dans le tableau des talents, non départagés ; le tableau des sorts garde 1311606 (rang 1) et 20473 (rang 2).
2. Judgement of the Crusader : le fichier donnait 21183 (existe dans SpellName, absent de SkillLineAbility) ; SkillLineAbility donne 20188, 20300-20303 ; SpellName porte aussi ce nom sur 25942, 25943, 456496. Non départagés. Vindication : SpellName porte aussi 440667, 440668 (non reliés). Blessing / Greater Blessing of Sanctuary : nom absent de SpellName (revérifié en CSV exact).
3. Vengeance : le fichier donnait 3 rangs ; Talent.csv en liste 5 (20049, 20056-20059).
4. Spiritual Focus : 2 rangs dans le fichier ; 5 dans Talent.csv.
5. Improved Seals : 3 rangs dans le fichier ; 5 dans Talent.csv.
6. One-Handed Weapon Specialization : 3 rangs dans le fichier ; 5 dans Talent.csv.
7. Redoubt, Reckoning, Vengeance : le fichier les décrivait en « ID unique » (trait à rangs) ; le DB2 donne un ID par rang.
8. Sorts du DB2 portant le nom d'un sort du fichier mais absents du fichier : Seal of Righteousness 21084 (remplace 20154) ; Holy Light 19968, 19980-19982, 1313348-1313352 ; Flash of Light 19993, 412020, 1313342-1313346 ; Holy Shock 25902, 25903, 25911-25914 ; Righteous Fury 407627 ; Exorcism 415068-415073. Non reliés à un rang (aucune source ne les cite).
- Talents du fichier absents de Talent.csv (IDs pris dans SkillLineAbility) : Voice of Truth, Light's Vigil, Swift Judgement, Templar's Bulwark, Twist of Light, Improved Seal of Fury ; Reverence, Divine Precision, Consecrated Ground, Sacred Duty, Holy Conduit, Sacred Arbiter, Champion of the Light, Instrument of Law, Sanctified Judgement : SpellName seul sauf Sanctified Judgement (1311074 en SkillLineAbility).
- Aucun ID du fichier (166 lignes de sorts) n'est absent de SkillLineAbility, et aucun nom ne diffère du DB2 pour ces IDs.

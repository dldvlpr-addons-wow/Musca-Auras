# Voleur — WoW Forever 1.60.1

Sources lues le 2026-10-08 :
- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName) : fait foi pour les IDs. Le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- wow-forever.gg `/db/spells/browse/class/rogue/` (build 1.60.1.70245) : source des IDs, niveaux et rangs (98 entrées, page unique).
- endgametools.com `/en/wow-forever/spells/rogue` (build 1.60.1.70205) : coûts, recharges, durées. Aucun ID. Ses niveaux sont incohérents (valeurs x10 + 3, ex. « 143 »), ignorés ; niveaux pris sur wow-forever.gg.
- wowforevertalents.com `/abilities/rogue/` et `/rogue/` (70245) : niveaux par rang, coûts, talents. Aucun ID de sort Forever.
- wowhead.com/forever/spell=ID : pages 1943, 2818, 434312, 5171, 1310703 seulement. Les pages de liste Wowhead Forever ne rendent que le formulaire de filtre (inutilisables).

Tous les IDs ci-dessous sont lus sur wow-forever.gg sauf mention contraire. Colonne « Coût » : énergie, sauf mention. Les finishers coûtent en plus 1 à 5 points de combo.

## Sorts de base (entraîneur)

| Nom | Rang | Spell ID | Niveau | Coût / ressource | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Sinister Strike | 1 | 1752 | 1 | 45 | - | - | |
| Sinister Strike | 2 | 1757 | 6 | 45 | - | - | |
| Sinister Strike | 3 | 1758 | 14 | 45 | - | - | |
| Sinister Strike | 4 | 1759 | 22 | 45 | - | - | |
| Sinister Strike | 5 | 1760 | 30 | 45 | - | - | |
| Sinister Strike | 6 | 8621 | 38 | 45 | - | - | |
| Sinister Strike | 7 | 11293 | 46 | 45 | - | - | |
| Sinister Strike | 8 | 11294 | 54 | 45 | - | - | |
| Eviscerate | 1 | 2098 | 1 | 35 + PC | - | - | finisher |
| Eviscerate | 2 | 6760 | 8 | 35 + PC | - | - | |
| Eviscerate | 3 | 6761 | 16 | 35 + PC | - | - | |
| Eviscerate | 4 | 6762 | 24 | 35 + PC | - | - | |
| Eviscerate | 5 | 8623 | 32 | 35 + PC | - | - | |
| Eviscerate | 6 | 8624 | 40 | 35 + PC | - | - | |
| Eviscerate | 7 | 11299 | 48 | 35 + PC | - | - | |
| Eviscerate | 8 | 11300 | 56 | 35 + PC | - | - | |
| Eviscerate | 9 | 31016 | 60 | 35 + PC | - | - | |
| Backstab | 1 | 53 | 4 | 60 | - | - | dague, dans le dos |
| Backstab | 2 | 2589 | 12 | 60 | - | - | |
| Backstab | 3 | 2590 | 20 | 60 | - | - | |
| Backstab | 4 | 2591 | 28 | 60 | - | - | |
| Backstab | 5 | 8721 | 36 | 60 | - | - | |
| Backstab | 6 | 11279 | 44 | 60 | - | - | |
| Backstab | 7 | 11280 | 52 | 60 | - | - | |
| Backstab | 8 | 11281 | 60 | 60 | - | - | |
| Backstab | 9 | 25300 | 60 | 60 | - | - | |
| Stealth | 1 | 1784 | 1 | - | 10 s | jusqu'à annulation | |
| Stealth | 2 | 1785 | 20 | - | 10 s | idem | |
| Stealth | 3 | 1786 | 40 | - | 10 s | idem | |
| Stealth | 4 | 1787 | 60 | - | 10 s | idem | |
| Redirect | - | 438040 | 1 | - | 10 s | - | |
| Pick Pocket | - | 921 | 4 | - | - | - | |
| Gouge | 1 | 1776 | 6 | 45 | 10 s | 4 s (étourdissement selon endgametools) | |
| Gouge | 2 | 1777 | 18 | 45 | 10 s | idem | |
| Gouge | 3 | 8629 | 32 | 45 | 10 s | idem | |
| Gouge | 4 | 11285 | 46 | 45 | 10 s | idem | |
| Gouge | 5 | 11286 | 60 | 45 | 10 s | idem | |
| Evasion | - | 5277 | 8 | - | 5 min | 15 s | |
| Sap | 1 | 6770 | 10 | 65 | - | 25 s | |
| Sap | 2 | 2070 | 28 | 65 | - | 35 s | |
| Sap | 3 | 11297 | 48 | 65 | - | 45 s | |
| Slice and Dice | 1 | 5171 | 10 | 25 + PC | - | 9 à 21 s selon PC (endgametools) ; page Wowhead affiche 6 s | |
| Slice and Dice | 2 | 6774 | 42 | 25 + PC | - | idem | |
| Sprint | 1 | 2983 | 10 | - | 5 min | 15 s | |
| Sprint | 2 | 8696 | 34 | - | 5 min | 15 s | |
| Sprint | 3 | 11305 | 58 | - | 5 min | 15 s | |
| Kick | 1 | 1766 | 12 | 25 | 10 s | 5 s | |
| Kick | 2 | 1767 | 26 | 25 | 10 s | 5 s | |
| Kick | 3 | 1768 | 42 | 25 | 10 s | 5 s | |
| Kick | 4 | 1769 | 58 | 25 | 10 s | 5 s | |
| Expose Armor | 1 | 8647 | 14 | 25 + PC | - | 30 s | |
| Expose Armor | 2 | 8649 | 26 | 25 + PC | - | 30 s | |
| Expose Armor | 3 | 8650 | 36 | 25 + PC | - | 30 s | |
| Expose Armor | 4 | 11197 | 46 | 25 + PC | - | 30 s | |
| Expose Armor | 5 | 11198 | 56 | 25 + PC | - | 30 s | |
| Garrote | 1 | 703 | 14 | 50 | - | 18 s | furtif, dans le dos |
| Garrote | 2 | 8631 | 22 | 50 | - | 18 s | |
| Garrote | 3 | 8632 | 30 | 50 | - | 18 s | |
| Garrote | 4 | 8633 | 38 | 50 | - | 18 s | |
| Garrote | 5 | 11289 | 46 | 50 | - | 18 s | |
| Garrote | 6 | 11290 | 54 | 50 | - | 18 s | |
| Feint | 1 | 1966 | 16 | 20 | 10 s | - | |
| Feint | 2 | 6768 | 28 | 20 | 10 s | - | |
| Feint | 3 | 8637 | 40 | 20 | 10 s | - | |
| Feint | 4 | 11303 | 52 | 20 | 10 s | - | |
| Feint | 5 | 25302 | 60 | 20 | 10 s | - | |
| Ambush | 1 | 8676 | 18 | 60 | - | - | furtif |
| Ambush | 2 | 8724 | 26 | 60 | - | - | |
| Ambush | 3 | 8725 | 34 | 60 | - | - | |
| Ambush | 4 | 11267 | 42 | 60 | - | - | |
| Ambush | 5 | 11268 | 50 | 60 | - | - | |
| Ambush | 6 | 11269 | 58 | 60 | - | - | |
| Rupture | 1 | 1943 | 20 | 25 + PC | - | 8 à 16 s selon PC (endgametools) ; page Wowhead affiche 6 s | |
| Rupture | 2 | 8639 | 28 | 25 + PC | - | idem | |
| Rupture | 3 | 8640 | 36 | 25 + PC | - | idem | |
| Rupture | 4 | 11273 | 44 | 25 + PC | - | idem | |
| Rupture | 5 | 11274 | 52 | 25 + PC | - | idem | |
| Rupture | 6 | 11275 | 60 | 25 + PC | - | idem | |
| Distract | - | 1725 | 22 | 30 | 30 s | 10 s | |
| Vanish | 1 | 1856 | 22 | - | 5 min | 10 s | |
| Vanish | 2 | 1857 | 42 | - | 5 min | 10 s | |
| Detect Traps (passif) | - | 2836 | 24 | - | - | - | |
| Cheap Shot | - | 1833 | 26 | 60 | - | 4 s | furtif |
| Disarm Trap | - | 1842 | 30 | - | - | cast 2 s | |
| Kidney Shot | 1 | 408 | 30 | 25 + PC | 20 s | 1 à 5 s selon PC | |
| Kidney Shot | 2 | 8643 | 50 | 25 + PC | 20 s | 2 à 6 s selon PC | |
| Blind | - | 2094 | 34 | 30 | 5 min | jusqu'à 10 s | |
| Safe Fall (passif) | - | 1860 | 40 | - | - | - | |
| Mutilate | 1 | 1310707 | 30 | 60 | - | - | wowforevertalents : R1 = rang de talent niveau 40 ; wow-forever.gg : niveau 30 |
| Mutilate | 2 | 399956 | 40 | 60 | - | - | |
| Mutilate | 3 | 1241582 | 50 | 60 | - | - | |
| Mutilate | 4 | 1241584 | 60 | 60 | - | - | |
| Hemorrhage | - | 16511 | 30 | non lu | non lu | - | wowforevertalents : talent ; endgametools : « not in Forever » (divergence) |
| Coup de Grace | - | 1310709 | 30 | non lu | non lu | - | non documenté sur les autres sources |
| Premeditation | - | 14183 | 20 | - | 2 min (wowforevertalents) | fenêtre 20 s | talent |
| Blade Flurry | - | 13877 | 1 | - | 2 min (wowforevertalents) | 15 s | talent |
| Hack and Slash | - | 13706 | 1 | - | - | - | talent (passif) |
| Venom | - | 1310703 | 40 | - | - | 9 à 21 s selon PC (wowforevertalents) ; page Wowhead affiche 6 s | talent finisher |

### Poisons (fabrication, application, effets)

Rôles établis avec SpellEffect (DB2 70245) : fabrication = effet CREATE_ITEM (24), présent dans SkillLineAbility (ligne Poisons 40, ClassMask 8) ; application sur l'arme = effet d'enchantement temporaire (360, ou 54 pour les poisons récents), amplitude 1800 s ; effet sur la cible = effet SCHOOL_DAMAGE (2) ou APPLY_AURA (6). Format de la colonne IDs : fabrication / application arme / effet cible. Niveaux par rang et coûts : wowforevertalents.com (aucun ID). Autres IDs lus sur wow-forever.gg et Wowhead Forever spell=1310703.

| Nom | Rang | Spell IDs (fabrication / application arme / effet cible) | Niveau | Notes |
|---|---|---|---|---|
| Instant Poison | 1 | 8681 / 8679 / 8680 | 20 | |
| Instant Poison | 2 | 8687 / 8686 / 8685 | 28 | |
| Instant Poison | 3 | 8691 / 8688 / 8689 | 36 | |
| Instant Poison | 4 | 11341 / 11338 / 11335 | 44 | |
| Instant Poison | 5 | 11342 / 11339 / 11336 | 52 | |
| Instant Poison | 6 | 11343 / 11340 / 11337 | 60 | DB2 : 11345 et 11346 (« Instant Poison », effet LEARN_SPELL vers 11342 et 11343) ; 28429 « Instant Poison Proc » déclenche 28428, rang non établi |
| Deadly Poison | 1 | 2835 / 2823 / 2818 ou 434312 | 30 | effet cible, 2 candidats : 2818 (base 6, période 3 s) et 434312 (base 9, période 3 s). 2818 : aura 12 s, 7 dégâts / 3 s (Wowhead Forever) |
| Deadly Poison | 2 | 2837 / 2824 / 2819 ou 434313 | 38 | effet cible, 2 candidats (2819 base 9, 434313 base 13) |
| Deadly Poison | 3 | 11357 / 11355 / 11353 ou 434314 | 46 | effet cible, 2 candidats (11353 base 14, 434314 base 20) |
| Deadly Poison | 4 | 11358 / 11356 / 11354 ou 434315 | 54 | effet cible, 2 candidats (11354 base 18, 434315 base 27) ; 25348 : voir « Écarts avec le DB2 client » |
| Deadly Poison | 5 | 25347 / 25351 / 25349 ou 434316 | 60 | effet cible, 2 candidats (25349 base 23, 434316 base 34) ; 434312 : aura 12 s, 10 dégâts / 3 s ; 2818 et 434312 sont deux versions distinctes (classic / Forever probable) |
| Deadly Poison (autres) | - | 3583, 13582, 21787 | - | auras poison de période 10 s (base 2, 2, 3), déclenchées par 10022 (vers 3583) et 21788 (vers 21787) ; 25974 : LEARN_SPELL vers 25347 ; rang non établi |
| Crippling Poison | 1 | 3420 / 3408 / 3409 ou 25809 | 20 | effet cible, 2 candidats identiques (aura 33, -50) : 3409 et 25809 (wow-forever.gg : tous deux « Rank 1 ») |
| Crippling Poison | 2 | 3421 / 11202 / 11201 | 50 | |
| Mind-numbing Poison | 1 à 3 | R1 5763 / 5761 / 5760 ou 25810 ; R2 8694 / 8693 / 8692 ; R3 11400 / 11399 / 11398 | 24 / 38 / 52 | R1 effet cible, 2 candidats : 5760 (aura 65, -40) et 25810 (aura 65, -50, même valeur que 8692) |
| Wound Poison | 1 à 4 | R1 13220 / 13219 / 13218 ; R2 13228 / 13225 / 13222 ; R3 13229 / 13226 / 13223 ; R4 13230 / 13227 / 13224 | 32 / 40 / 48 / 56 | rang de l'effet cible déduit de la valeur (-67, -92, -128, -165) ; 13221 : LEARN_SPELL vers 13220 |
| Occult Poison | 1 | 458822 / 458821 / 458820 | 54 | 462286 (« Occult Poison I », aura 87, base 4) : autre effet possible, rôle non établi |
| Occult Poison | 2 | 1214168 / 1214171 / 1214170 | 60 | 1214169 : LEARN_SPELL vers 1214168 |
| Atrophic Poison | - | 439503 / 439465 / 439473 | 60 | |
| Numbing Poison | - | 439505 / 439464 / 439472 | 60 | |
| Sebacious Poison | - | 439500 / 439462 / 439471 | 60 | |
| Blinding Powder | - | 6510 | 34 | effet CREATE_ITEM, SkillLineAbility ligne 40 |
| Pick Lock | - | 1804, 6461 ou 6463 | 1 | 3 candidats de même nom ; seul 1804 figure dans SkillLineAbility (ligne 633, ClassMask 8) |

## Talents

IDs de rang lus dans le DB2 client 70245 (table Talent, dans l'ordre des rangs). Mutilate, Venom, Puncturing Wounds, Flawless Execution, Dirty Tricks, Improved Distract, Quietus, Cutthroat, Thousand Cuts ne figurent pas dans la table Talent : IDs pris par nom dans SpellName / SkillLineAbility. Effets issus de wowforevertalents.com. Le placement dans les arbres reste celui du fichier ; les écarts avec le DB2 (arbre, nombre de rangs) sont listés dans « Points non vérifiés ».

IDs hors talents : Blade Flurry 13877 ; Premeditation 14183 ; Hemorrhage 16511 ; Mutilate R1 1310707 (R2 399956, R3 1241582, R4 1241584) ; Venom 1310703 ; Redirect 438040 ; Coup de Grace 1310709.

### Assassination

| Nom | Rangs max | IDs | Effet court |
|---|---|---|---|
| Improved Gouge | 3 | 13741, 13793, 13792 | durée Gouge +0,5 à +1,5 s |
| Remorseless Attacks | 2 | 14144, 14148 | +20 / 40 % crit sur la prochaine attaque après kill, 20 s |
| Malice | 5 | 14138, 14139, 14140, 14141, 14142 | +1 à 5 % crit |
| Ruthlessness | 3 | 14156, 14160, 14161 | 20 / 40 / 60 % PC bonus sur finisher |
| Murder | 2 | 14158, 14159 | +2 / 4 % dégâts Humanoïde, Géant |
| Improved Slice and Dice | 3 | 14165, 14166, 14167 | durée +15 à 45 % |
| Relentless Strikes | 1 | 14179 | 20 % par PC de rendre 25 énergie |
| Improved Expose Armor | 2 | 14168, 14169 | coût -5 / -10 ; rembourse 1 à 2 PC à 5 PC |
| Lethality | 5 | 14128, 14132, 14135, 14136, 14137 | dégâts crit +4 à 20 % |
| Vile Poisons | 5 | 16513, 16514, 16515, 16719, 16720 | dégâts poisons +4 à 20 % |
| Cold Blood | 1 | 14177 | prochain coup +100 % crit, 3 min |
| Improved Poisons | 5 | 14113, 14114, 14115, 14116, 14117 | application +2 à 10 % |
| Vigor | 2 | 14983 | énergie max +5 / +10 |
| Mutilate | 1 | 1310707, 399956, 1241582, 1241584 (rangs 1 à 4, chaîne SupercedesSpell ; hors table Talent) | frappe 2 armes, 2 PC |
| Improved Kidney Shot | 2 | 14174, 14175, 14176 | cible étourdie +5 / 10 % dégâts |
| Seal Fate | 5 | 14186, 14190, 14193, 14194, 14195 | PC bonus sur crit 20 à 100 % |
| Venom | 1 | 1310703 | +30 % dégâts poison, +10 % application |

### Combat

| Nom | Rangs max | IDs | Effet court |
|---|---|---|---|
| Improved Eviscerate | 3 | 14162, 14163, 14164 | +7 à 20 % |
| Improved Sinister Strike | 2 | 13732, 13863 | coût -3 / -5 |
| Lightning Reflexes | 5 | 13712, 13788, 13789, 13790, 13791 | esquive +1 à 5 % |
| Puncturing Wounds | 3 | 1224716 (hors table Talent ; un seul ID, autres rangs non trouvés ; déclenche 1310710 « Improved Backstab ») | crit Backstab +10 à 30 % |
| Deflection | 3 | 13713, 13853, 13854, 13855, 13856 | parade +2 à 6 % |
| Precision | 3 | 13705, 13832, 13843, 13844, 13845 | toucher +1 à 3 % |
| Endurance | 2 | 13742, 13872 | recharge Sprint/Evasion -30 / -60 % |
| Riposte | 1 | 14251 | contre après parade, 6 s, recharge 6 s |
| Improved Sprint | 2 | 13743, 13875 | 50 / 100 % retire entrave |
| Improved Kick | 2 | 13754, 13867 | silence 50 / 100 %, 2 s |
| Flawless Execution | 1 | 1310711 (hors table Talent) | Eviscerate -10 énergie |
| Dual Wield Specialization | 5 | 13715, 13848, 13849, 13851, 13852 | main gauche +5 à 25 % |
| Blade Flurry | 1 | 13877 | vitesse +20 %, 15 s, 2 min |
| Hack and Slash | 5 | 3 candidats de même nom : 13706, 13804, 13805, 13806, 13807 (TabID 181, col. 1 rangée 3) ; 13709, 13800, 13801, 13802, 13803 (TabID 181, col. 0 rangée 4) ; 13960, 13961, 13962, 13963, 13964 (TabID 181, col. 2 rangée 4). Hors talent, même nom : 16459, 1290312 | selon arme |
| Weapon Expertise | 2 | 30919, 30920 | -1 / -2 % esquive/parade adverse |
| Aggression | 3 | 18427, 18428, 18429 | +2 à 6 % |
| Adrenaline Rush | 1 | 13750 | énergie +100 %, 15 s, 5 min |

### Subtlety

| Nom | Rangs max | IDs | Effet court |
|---|---|---|---|
| Camouflage | 5 | 13975, 14062, 14063, 14064, 14065 | pénalité vitesse furtif -3 à -15 % |
| Master of Deception | 3 | 13958, 13970, 13971, 13972, 13973 | détection réduite |
| Opportunity | 2 | 14057, 14072, 14073, 14074, 14075 | +5 / 10 % dégâts |
| Setup | 3 | 13983, 14070, 14071 | 33 à 100 % PC après esquive |
| Elusiveness | 2 | 13981, 14066 | recharge Vanish/Blind -45 / -90 s |
| Dirty Tricks | 2 | 1224782 (SpellName seul, hors Talent et SkillLineAbility ; autres rangs non trouvés) | coût Sap/Blind -25 / -50 % |
| Improved Ambush | 3 | 14079, 14080, 14081 | crit +15 à 45 % |
| Initiative | 3 | 13976, 13979, 13980 (13977 « Initiative » : sort déclenché) | PC bonus 33 à 100 % |
| Ghostly Strike | 1 | 14278 | 125 % arme, esquive +15 % 7 s, 20 s |
| Improved Distract | 2 | 14084 (SpellName seul, hors Talent et SkillLineAbility ; autres rangs non trouvés) | rayon +3 / +5 m |
| Heightened Senses | 2 | 30894, 30895 | détection +1 à 3 niveaux |
| Premeditation | 1 | 14183 | +2 PC, 20 s, 2 min |
| Serrated Blades | 3 | 14171, 14172, 14173 | Rupture +10 à 30 % |
| Dirty Deeds | 2 | 14082, 14083 | coût Cheap Shot/Garrote -10 / -20 |
| Preparation | 1 | 14185 | réinitialise recharges, 10 min |
| Hemorrhage | 1 | 16511 | 100 % arme, 1 PC |
| Quietus | 5 | 2 candidats, hors Talent et SkillLineAbility (pas de TabID) : 1231651, 1310728 | +2 à 10 % si cible < 35 % |
| Cutthroat | 5 | 4 candidats, hors Talent et SkillLineAbility (pas de TabID) : 424980, 462707, 462708, 1241810 | chance Ambush sans furtivité |
| Thousand Cuts | 1 | 2 candidats, hors Talent et SkillLineAbility (pas de TabID) : 1310721, 1310723 | -3 énergie par tick, 5 cumuls |

Talents classiques absents des arbres Forever (IDs Classic lus sur wowforevertalents.com) : Dagger Specialization 13706, Fist Weapon Specialization 13707, Improved Backstab 13733, Mace Specialization 13709, Deadliness 30902, Improved Sap 14076, Sleight of Hand 30892. Remarque : 13706 est aussi listé « Hack and Slash » sur wow-forever.gg (divergence de nom).

Présents dans la table Talent du DB2 70245 (présence ≠ actif en jeu), IDs de rang dans l'ordre : Fist Weapon Specialization 13707, 13966, 13967, 13968, 13969 (Combat, col. 3 rangée 4) ; Improved Sap 14076, 14094, 14095 (Subtlety, col. 1 rangée 3) ; Sleight of Hand 30892, 30893 (Subtlety, col. 0 rangée 1) ; Deadliness 30902, 30903, 30904, 30905, 30906 (Subtlety, col. 2 rangée 5) ; Improved Backstab : ID 13733, 13865, 13866 (Combat, col. 0 rangée 1), nom absent de SpellName (le seul « Improved Backstab » de SpellName est 1310710, sort déclenché) ; 13706 et 13709 : nommés « Hack and Slash » dans SpellName (voir Combat).

## Buffs, debuffs et procs à suivre en WeakAuras

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Slice and Dice | 5171 (R1), 6774 (R2) : l'ID de l'aura n'a pas été vérifié distinct du sort lancé | buff joueur | wow-forever.gg / Wowhead Forever (+21 % vitesse mêlée affiché) |
| Rupture | 1943, 8639, 8640, 11273, 11274, 11275 (aura distincte non vérifiée) | debuff cible | wow-forever.gg |
| Expose Armor | 8647, 8649, 8650, 11197, 11198 (idem) | debuff cible | wow-forever.gg |
| Garrote | 703, 8631, 8632, 8633, 11289, 11290 (idem) | debuff cible | wow-forever.gg |
| Deadly Poison (effet sur cible) | 2818 / 434312 (R1) ... voir tableau poisons | debuff cible | Wowhead Forever spell=2818, 434312 |
| Venom | 1310703 | buff joueur | Wowhead Forever |
| Blade Flurry | 13877 | buff joueur | wow-forever.gg |
| Evasion | 5277 | buff joueur | wow-forever.gg |
| Sprint | 2983, 8696, 11305 | buff joueur | wow-forever.gg |
| Stealth | 1784, 1785, 1786, 1787 | buff joueur | wow-forever.gg |
| Vanish | 1856, 1857 | buff joueur | wow-forever.gg |
| Premeditation | 14183 | buff joueur | wow-forever.gg |
| Riposte (disponible) | 14251 (sort et aura, SkillLineAbility aura oui) ; 3 autres sorts de même nom hors SkillLineAbility : 5237, 6187, 6569 (aucun sort déclenché dans le DB2) | proc | DB2 70245 |
| Remorseless Attacks | 14144, 14148 (talent) ; aucun sort déclenché dans le DB2 : ID de l'aura de proc non établi | proc | DB2 70245 |
| Cold Blood | 14177 (SkillLineAbility aura oui) | buff joueur | DB2 70245 |
| Adrenaline Rush | 13750 (SkillLineAbility aura oui) ; 2 autres sorts de même nom hors SkillLineAbility : 28752, 28753 | buff joueur | DB2 70245 |
| Hemorrhage (debuff) | 16511 (aura distincte non vérifiée) | debuff cible | wow-forever.gg |
| Kidney Shot / Cheap Shot / Gouge / Sap / Blind / Kick (silence) | IDs des sorts lancés ci-dessus ; auras distinctes non vérifiées | debuff cible | wow-forever.gg |
| Thousand Cuts (cumuls) | 2 candidats : 1310721, 1310723 (hors Talent et SkillLineAbility) | buff joueur | DB2 70245 |
| Vanish (aura) | 11327 (R1), 11329 (R2), déclenchés par 1856 / 1857 ; 18461 « Vanish Purge » déclenché par les deux | buff joueur | DB2 70245 (sorts déclenchés) |
| Improved Sprint / Improved Kick (silence) | 30918 (déclenché par 13743) ; 18425 « Silenced - Kick » (déclenché par 13754) | buff / debuff | DB2 70245 (sorts déclenchés) |
| Procs de talents | Ruthlessness 14157 (par 14156) ; Relentless Strikes 14181 (par 14179) ; Initiative 13977 (par 13976) ; Setup 15250 (par 13983) ; Improved Expose Armor 1310697 (par 14168) ; Improved Backstab 1310710 (par Puncturing Wounds 1224716) ; Vanished 14093 (par Improved Sap 14076 / 14094 / 14095) | proc | DB2 70245 (sorts déclenchés) |

## Points non vérifiés

- Wowhead Forever : les pages de liste (abilities, talents) ne rendent que le formulaire de filtre ; seules des pages `spell=ID` isolées ont pu être lues. Elles n'affichent ni rang ni niveau.
- endgametools.com : aucun spell ID. wowforevertalents.com : aucun ID Forever de talent ni de sort.
- IDs d'aura distincts du sort lancé : non vérifiés (la page spell=5171 ne montre aucun lien lié). À confirmer en jeu avec `C_UnitAuras` / `/dump`.
- Poisons : rôles établis par SpellEffect (voir tableau). Candidats multiples non départagés : effet cible Deadly Poison (2818 / 434312, etc.), Crippling R1 (3409 / 25809), Mind-numbing R1 (5760 / 25810), Pick Lock (1804 / 6461 / 6463).
- Talents : Quietus, Cutthroat, Thousand Cuts (candidats multiples) et Hack and Slash (3 positions) non départagés ; Remorseless Attacks : ID de l'aura de proc non établi.

### Écarts avec le DB2 client

- Deadly Poison R4 : 25348 est nommé « Copy of Deadly Poison IV » dans SpellName (aura 27 / 3 s, hors SkillLineAbility), pas un rang d'effet ; tableau poisons : valeur du DB2 (11354 / 434315).
- Talents : le fichier place Improved Gouge dans Assassination ; le DB2 la place dans Combat (TabID 181). Improved Eviscerate : fichier Combat, DB2 Assassination (TabID 182).
- Nombre de rangs : Vigor 2 (fichier) contre 1 (DB2) ; Improved Kidney Shot 2 contre 3 ; Deflection 3 contre 5 ; Precision 3 contre 5 ; Master of Deception 3 contre 5 ; Opportunity 2 contre 5. Le tableau garde les IDs du DB2.
- Hack and Slash 13706 : le fichier l'attribue au talent unique (5 rangs) ; le DB2 a 3 talents de ce nom (13706, 13709, 13960).
- Talents « absents des arbres Forever » (paragraphe ci-dessus) : Fist Weapon Specialization, Improved Backstab (ID 13733, nom absent de SpellName), Deadliness, Improved Sap, Sleight of Hand et les IDs 13706 / 13709 sont présents dans la table Talent du DB2 70245.
- Talents : Riposte, Remorseless Attacks, Cold Blood, Adrenaline Rush, Preparation, Ghostly Strike : signalés « absents de la liste de classe » par le fichier ; tous présents dans la table Talent du DB2 (14251, 14144, 14177, 13750, 14185, 14278).
- Auras : Rupture, Expose Armor, Garrote, Slice and Dice, Gouge, Kidney Shot, Cheap Shot, Sap, Blind, Hemorrhage, Premeditation, Blade Flurry, Evasion, Sprint, Stealth : SkillLineAbility marque l'ID du sort lancé comme portant lui-même un effet APPLY_AURA et aucun sort déclenché n'est listé ; aura distincte non établie par le DB2.
- Hemorrhage : présent sur wow-forever.gg (ID 16511, niveau 30) et wowforevertalents.com (talent), marqué « not in Forever » par endgametools.
- Niveaux Mutilate R1 : 30 (wow-forever.gg) contre rang de talent niveau 40 (wowforevertalents.com).
- Durées Slice and Dice, Rupture, Venom : 6 s sur les pages Wowhead spell=ID (base), 9 à 21 s / 8 à 16 s sur endgametools / wowforevertalents (selon PC).
- Coûts et recharges de Hemorrhage, Coup de Grace, Premeditation, Blade Flurry : non lus (hors Premeditation et Blade Flurry recharges via wowforevertalents).
- Backstab R8/R9 et Eviscerate R9 : deux rangs niveau 60 (IDs 11281 / 25300, 31016) ; différence R8/R9 non explicitée.

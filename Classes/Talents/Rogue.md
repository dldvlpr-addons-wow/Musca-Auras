# Rogue : arbres de talents (WoW Forever)

Source : https://wow-forever.gg/talents/rogue/ (build 1.60.1.70245, JSON `#trait-data`, lu le 2026-10-09). Plafond 51 points ; bêta : niveau max 30, soit 21 points (1 point par niveau dès le niveau 10).
Palier = points requis dans l'arbre. Colonne 1 à 4 de gauche à droite. Valeurs `a/b/c` = rang 1/2/3.
IDs de rang : repris de `Classes/Rogue.md`, pas de wow-forever.gg. « ⚠ » = ID absent du DB2 Talent, candidat, nombre d'IDs différent du nombre de rangs, ID annexe (aura déclenchée, homonyme) ou talent renommé : voir le fichier de classe.

## Assassination (17 talents, 48 points)

| Palier | Col. | Talent | Rangs | Prérequis | IDs de rang | Effet | Changement vs Classic |
|---|---|---|---|---|---|---|---|
| 0 | 1 | Improved Gouge | 3 |  | 13741, 13793, 13792 | Increases the duration of your Gouge ability by 0.5/1/1.5 sec. | retiré : effect ; déplacé : from **Combat** to **Assassination** |
| 0 | 2 | Remorseless Attacks | 2 |  | 14144, 14148 | After killing a non-trivial enemy, gives you a 20%/40% increased critical strike chance on your next Sinister Strike, Backstab, Ambush, Mutilate, or Ghostly Strike. Lasts 20 sec. | retiré : an opponent that yields experience or honor ; ajouté : a non-trivial enemy ; ajouté : Mutilate |
| 0 | 3 | Malice | 5 |  | 14138, 14139, 14140, 14141, 14142 | Increases your critical strike chance with all attacks and Poisons by 1%/2%/3%/4%/5%. | ajouté : with all attacks and Poisons |
| 5 | 1 | Ruthlessness | 3 |  | 14156, 14160, 14161 | Gives your finishing moves a 20%/40%/60% chance to add a Combo Point to your target. | identique à Classic |
| 5 | 2 | Murder | 2 |  | 14158, 14159 | Increases all damage dealt by 2%/4% against Humanoid and Giant targets. | reformulé : Classic: Increases all damage caused against Humanoid, Giant, Beast and Dragonkin targets by 2%. |
| 5 | 4 | Improved Slice and Dice | 3 |  | 14165, 14166, 14167 | Increases the duration of your Slice and Dice ability by 15%/30%/45%. | identique à Classic |
| 10 | 1 | Relentless Strikes | 1 |  | 14179 | Your finishing moves have a 20% chance per Combo Point to restore 25 Energy. | identique à Classic |
| 10 | 2 | Improved Expose Armor | 2 |  | 14168, 14169 | Reduces the Energy cost of your Expose Armor ability by 5/10, and refunds 1/2 Combo Point/Points when cast with 5 Combo Points. | reformulé : Classic: Increases the armor reduced by your Expose Armor ability by 50%. |
| 10 | 3 | Lethality | 5 | Malice | 14128, 14132, 14135, 14136, 14137 | Increases the critical strike damage bonus of your Sinister Strike, Gouge, Backstab, Mutilate, Ghostly Strike, and Hemorrhage abilities by 4%/8%/12%/16%/20%. | ajouté : Mutilate ; modifié : ~~30%~~ → **20%** |
| 15 | 1 | Vile Poisons | 5 |  | 16513, 16514, 16515, 16719, 16720 | Increases the damage dealt by your poisons by 4%/8%/12%/16%/20% and gives your poisons an additional 8%/16%/24%/32%/40% chance to resist dispel effects. | déplacé : column ~~2~~ → **1** |
| 15 | 2 | Cold Blood | 1 |  | 14177 | When activated, increases the critical strike chance of your next Sinister Strike, Backstab, Ambush, Eviscerate, or Mutilate by 100%. | ajouté : or Mutilate ; déplacé : **earlier**: was 20 points deep, now **15** · reachable at level **25** instead of 30 · row ~~5~~ → **4** |
| 15 | 3 | Improved Poisons | 5 |  | 14113, 14114, 14115, 14116, 14117 | Increases the chance to apply Poisons to your target by 2%/4%/6%/8%/10%, and gives Poison applications a 10%/20%/30%/40%/50% chance to not consume a charge. | ajouté : and gives Poison applications a **50%** chance to not consume a charge |
| 20 | 1 | Vigor | 2 |  | 14983 ⚠ | Increases your maximum Energy by 5/10. | rangs : was **1**, now **2** ; déplacé : **earlier**: was 30 points deep, now **20** · reachable at level **30** instead of 40 · row ~~7~~ → **5** · column ~~2~~ → **1** |
| 20 | 2 | Mutilate | 1 |  | 1310707, 399956, 1241582, 1241584 ⚠ | Instantly attacks with both weapons for 75% weapon damage plus an additional 17.2 with each weapon. Damage increased by 20% against Poisoned targets. Awards 2 Combo Points. | nouveau dans Forever |
| 20 | 3 | Improved Kidney Shot | 2 |  | 14174, 14175, 14176 ⚠ | Enemies Stunned by your Kidney Shot ability take 5%/10% increased damage from your poisons and attacks. | reformulé : Classic: While affected by your Kidney Shot ability, the target receives an additional 6% damage from all sources. ; rangs : was **3**, now **2** |
| 25 | 3 | Seal Fate | 5 |  | 14186, 14190, 14193, 14194, 14195 | Your critical strikes from abilities that add Combo Points have a 20%/40%/60%/80%/100% chance to add an additional Combo Point. | déplacé : column ~~2~~ → **3** ; prérequis : was Cold Blood, now nothing |
| 30 | 2 | Venom | 1 | Mutilate | 1310703 | Finishing move that increases the damage of your Poisons by 30% and your chance to apply Poisons by 10%. Lasts longer per combo point: 1 point  : 9 sec 2 points: 12 sec 3 points: 15 sec 4 points: 18 sec 5 points: 21 sec | nouveau dans Forever |

## Combat (17 talents, 44 points)

| Palier | Col. | Talent | Rangs | Prérequis | IDs de rang | Effet | Changement vs Classic |
|---|---|---|---|---|---|---|---|
| 0 | 1 | Improved Eviscerate | 3 |  | 14162, 14163, 14164 | Increases the damage done by your Eviscerate ability by 7%/13%/20%. | modifié : ~~15%~~ → **20%** ; déplacé : from **Assassination** to **Combat** |
| 0 | 2 | Improved Sinister Strike | 2 |  | 13732, 13863 | Reduces the Energy cost of your Sinister Strike ability by 3/5. | identique à Classic |
| 0 | 3 | Lightning Reflexes | 5 |  | 13712, 13788, 13789, 13790, 13791 | Increases your Dodge chance by 1%/2%/3%/4%/5%. | identique à Classic |
| 5 | 1 | Puncturing Wounds | 3 |  | 1224716, 1310710 ⚠ | Increases the critical strike chance of your Backstab by 10%/20%/30% and your Mutilate by 5%/10%/15%, and gives Backstab a 15%/30%/45% chance to add an additional Combo Point. | nouveau dans Forever |
| 5 | 2 | Deflection | 3 |  | 13713, 13853, 13854, 13855, 13856 ⚠ | Increases your Parry chance by 2%/4%/6%. | modifié : ~~3%~~ → **6%** ; rangs : was **5**, now **3** |
| 5 | 3 | Precision | 3 |  | 13705, 13832, 13843, 13844, 13845 ⚠ | Improves your chance to hit by 1%/2%/3%. | modifié : ~~Increases~~ → **Improves** ; retiré : with melee weapons ; rangs : was **5**, now **3** |
| 10 | 1 | Endurance | 2 |  | 13742, 13872 | Reduces the cooldown of your Sprint and Evasion abilities by 30%/60%. | modifié : ~~1.5 min~~ → **60%** |
| 10 | 2 | Riposte | 1 | Deflection | 14251 | A strike that becomes active after parrying an opponent's attack. | identique à Classic |
| 10 | 4 | Improved Sprint | 2 |  | 13743, 13875 | Gives a 50%/100% chance to remove all movement impairing effects when you activate your Sprint ability. | identique à Classic |
| 15 | 1 | Improved Kick | 2 |  | 13754, 13867 | Gives your Kick ability a 50%/100% chance to Silence the target for 2 sec. | identique à Classic |
| 15 | 2 | Flawless Execution | 1 |  | 1310711 | Reduces the Energy cost of your Eviscerate ability by 10. | nouveau dans Forever |
| 15 | 3 | Dual Wield Specialization | 5 | Precision | 13715, 13848, 13849, 13851, 13852 | Increases the damage done by your off-hand weapon by 5%/10%/15%/20%/25%. | modifié : ~~50%~~ → **25%** |
| 20 | 2 | Blade Flurry | 1 |  | 13877 | Increases your melee attack speed by 20% and your melee attacks strike an additional nearby opponent. Lasts 15 sec. | ajouté : melee ; modifié : ~~In addition~~ → **and your melee** |
| 20 | 3 | Hack and Slash | 5 |  | 13706, 13804, 13805, 13806, 13807, 13709, 13800, 13801, 13802, 13803, 13960, 13961, 13962, 13963, 13964, 16459, 1290312 ⚠ | Gives your melee weapon attacks a benefit depending on the weapon. Axe/Sword: Your successful melee attacks have a 1%/2%/3%/4%/5% chance to trigger an extra attack on the target. Dagger/Fist: Increases your critical strike chance by 1%/2%/3%/4%/5%. Mace: Your attacks ignore 3%/6%/9%/12%/15% of your target's armor. | renommé : ~~Sword Specialization~~ → **Hack and Slash** ; reformulé : Classic: Gives you a 5% chance to get an extra attack on the same target after dealing damage with your Sword. |
| 25 | 2 | Weapon Expertise | 2 | Blade Flurry | 30919, 30920 | Reduces the chance for your attacks to be Dodged or Parried by 1%/2%. | reformulé : Classic: Increases your skill with Sword, Fist and Dagger weapons by 5. |
| 25 | 3 | Aggression | 3 |  | 18427, 18428, 18429 | Increases the damage of your Sinister Strike, Backstab, and Eviscerate abilities by 2%/4%/6%. | ajouté : Backstab |
| 30 | 2 | Adrenaline Rush | 1 |  | 13750 | Increases your Energy regeneration rate by 100% for 15 sec. | identique à Classic |

## Subtlety (19 talents, 47 points)

| Palier | Col. | Talent | Rangs | Prérequis | IDs de rang | Effet | Changement vs Classic |
|---|---|---|---|---|---|---|---|
| 0 | 1 | Camouflage | 5 |  | 13975, 14062, 14063, 14064, 14065 | Reduces your speed penalty from your Stealth ability by 3%/6%/9%/12%/15% and reduces its cooldown by 2/3/4/5/6 sec. | reformulé : Classic: Increases your speed while stealthed by 15% and reduces the cooldown of your Stealth ability by 5 sec. ; déplacé : **earlier**: was 5 points deep, now **0** · reachable at level **10** instead of 15 · row ~~2~~ → **1** · column ~~3~~ → **1** |
| 0 | 2 | Master of Deception | 3 |  | 13958, 13970, 13971, 13972, 13973 ⚠ | Reduces the chance enemies have to detect you while in Stealth mode as if you were 1 level/2 levels/3 levels higher. | retiré : More effective than Master of Deception (Rank **2**) ; ajouté : as if you were **3** levels higher ; rangs : was **5**, now **3** |
| 0 | 3 | Opportunity | 2 |  | 14057, 14072, 14073, 14074, 14075 ⚠ | Increases the damage dealt by your Backstab, Garrote, Ambush, and Mutilate abilities by 5%/10%. | modifié : ~~when striking from behind with~~ → **by** ; ajouté : and Mutilate ; modifié : ~~8%~~ → **10%** ; rangs : was **5**, now **2** |
| 5 | 1 | Setup | 3 |  | 13983, 14070, 14071 | Gives you a 33%/67%/100% chance to add a Combo Point to your target after Dodging one of their attacks or fully resisting one of their spells. | modifié : ~~45%~~ → **100%** ; ajouté : one of ; modifié : ~~attack~~ → **attacks** ; déplacé : **earlier**: was 15 points deep, now **5** · reachable at level **15** instead of 25 · row ~~4~~ → **2** |
| 5 | 2 | Elusiveness | 2 |  | 13981, 14066 | Reduces the cooldown of your Vanish and Blind abilities by 45/90 sec. | modifié : ~~1.5 min~~ → **90 sec** |
| 5 | 3 | Dirty Tricks | 2 |  | 1224782 ⚠ | Reduces the Energy cost of your Sap and Blind abilities by 25%/50%. | nouveau dans Forever |
| 5 | 4 | Improved Ambush | 3 |  | 14079, 14080, 14081 | Increases the critical strike chance of your Ambush ability by 15%/30%/45%. | déplacé : **earlier**: was 10 points deep, now **5** · reachable at level **15** instead of 20 · row ~~3~~ → **2** · column ~~3~~ → **4** |
| 10 | 1 | Initiative | 3 |  | 13976, 13979, 13980, 13977 ⚠ | Gives you a 33%/67%/100% chance to add an additional combo point to your target when using your Ambush, Garrote, or Cheap Shot ability. | modifié : ~~75%~~ → **100%** |
| 10 | 2 | Ghostly Strike | 1 |  | 14278 | A strike that deals 125% (180% if a Dagger is equipped in your Main Hand) weapon damage and increases your chance to dodge by 15% for 7 sec.  Awards 1 combo point. | ajouté : (**180%** if a Dagger is equipped in your Main Hand) |
| 10 | 3 | Improved Distract | 2 |  | 14084 ⚠ | Increases the radius of your Distract ability by 3/5 yds, and further reduces the Stealth detection of distracted enemies as though they were an additional 1 level/2 levels lower. | nouveau dans Forever |
| 15 | 1 | Heightened Senses | 2 |  | 30894, 30895 | Increases your Stealth detection as if you were 1 level/3 levels higher and reduces your chance to be hit by spells and ranged attacks by 2%/4%. | ajouté : as if you were **3** levels higher ; modifié : ~~you are~~ → **to be** ; retiré : More effective than Heightened Senses (Rank **1**) ; déplacé : **earlier**: was 20 points deep, now **15** · reachable at level **25** instead of 30 · row ~~5~~ → **4** |
| 15 | 2 | Premeditation | 1 |  | 14183 | Adds 2 Combo Points to your target. You must add to or use those combo points within 20 sec or the combo points are lost. | retiré : When used ; modifié : ~~10~~ → **20** ; déplacé : **earlier**: was 30 points deep, now **15** · reachable at level **25** instead of 40 · row ~~7~~ → **4** ; prérequis : was Preparation, now nothing |
| 15 | 3 | Serrated Blades | 3 |  | 14171, 14172, 14173 | Causes your attacks to ignore 3%/6%/9% of your target's Armor and increases the damage dealt by your Rupture ability by 10%/20%/30%. | modifié : ~~0~~ → **9%** ; retiré : The amount of Armor reduced increases with your level |
| 20 | 1 | Dirty Deeds | 2 |  | 14082, 14083 | Reduces the Energy cost of your Cheap Shot and Garrote abilities by 10/20, and your Garrote ability no longer requires you to be behind your target. | ajouté : and your Garrote ability no longer requires you to be behind your target ; déplacé : column ~~3~~ → **1** |
| 20 | 2 | Preparation | 1 |  | 14185 | When activated, this ability immediately finishes the cooldown on your other Rogue abilities. | identique à Classic |
| 20 | 3 | Hemorrhage | 1 | Serrated Blades | 16511 | An instant strike that deals 100% weapon damage (145% if a Dagger is equipped) and causes the target to take 15% increased Rupture damage from the Rogue. Lasts 15 sec. Awards 1 Combo Point. | reformulé : Classic: An instant strike that damages the opponent and causes the target to hemorrhage, increasing any Physical damage dealt to the target by up to 3. Lasts 30 charges or 15 sec. Awards 1 combo point. ; déplacé : column ~~4~~ → **3** |
| 25 | 1 | Quietus | 5 | Dirty Deeds | 1231651, 1310728 ⚠ | Your Sinister Strike, Ghostly Strike, and Hemorrhage abilities cause 2%/4%/6%/8%/10% more damage against targets below 35% health. | nouveau dans Forever |
| 25 | 3 | Cutthroat | 5 |  | 424980, 462707, 462708, 1241810 ⚠ | Your Backstab has a 3%/6%/9%/12%/15% chance to cause your next Ambush within 10 sec to not require Stealth. | nouveau dans Forever |
| 30 | 2 | Thousand Cuts | 1 | Preparation | 1310721, 1310723 ⚠ | When your Rupture ability deals periodic damage, the Energy cost of your next Hemorrhage or Backstab ability within 10 sec is reduced by 3, stacking up to 5 times. | nouveau dans Forever |

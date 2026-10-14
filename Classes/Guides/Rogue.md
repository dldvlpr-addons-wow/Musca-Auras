# Guides Rogue (Voleur) — WoW Forever 1.60.1

Synthèse orientée addon, reformulée en notes courtes. IDs issus de `Classes/Rogue.md` uniquement. Quand un sort n'y figure pas : « ID absent de Classes/Rogue.md ». Pour les sorts à plusieurs rangs, les IDs listés sont ceux de tous les rangs.

## Sources lues

Icy Veins (https://www.icy-veins.com/forever/) :
- rogue-class-overview — Last Updated Sep 20, 2026 — Sellin
- assassination-rogue-melee-dps-pve-guide — Sep 17, 2026 — Sellin
- combat-rogue-melee-dps-pve-guide — Sep 17, 2026 — Sellin
- subtlety-rogue-melee-dps-pve-guide — Oct 8, 2026 — Seliathan

Wowhead (https://www.wowhead.com/forever/guide/classes/rogue/), tous par warstry, relus par Simonize :
- assassination/overview-pve-dps — 2026/10/07
- assassination/dps-abilities — 2026/10/08
- assassination/level-20-dps-overview — 2026/09/29
- assassination/level-30-dps-overview — 2026/10/06
- combat/overview-pve-dps — 2026/10/07
- combat/dps-abilities — 2026/10/08
- combat/level-20-dps-overview — 2026/09/29
- combat/level-30-dps-overview — 2026/10/06
- subtlety/overview-pve-dps — 2026/10/07
- subtlety/dps-abilities — 2026/10/08
- subtlety/level-20-dps-overview — 2026/09/29
- subtlety/level-30-dps-overview — 2026/10/06

Absentes ou en échec : aucune (16 pages lues, 0 échec).

Limite : aucune rotation « niveau max » n'est documentée, la bêta plafonne au niveau 30. Les rotations ci-dessous couvrent les niveaux 20 et 30.

## Points communs à toutes les spés

- Énergie : régénération continue et lissée (pas par ticks), classe rapide, beaucoup d'actions par minute. Wowhead juge la régénération lente. Une capacité ratée rend une partie de l'énergie.
- Points de combo : conservés sur la cible, plus perdus au changement de cible (on peut Coup de pied un autre mob puis revenir), mais non transférables. Aucun nouveau point ne doit être construit entre-temps.
- Poisons : puissance liée à la puissance d'attaque, cumulables avec Totem Windfury et pierres d'affûtage.
- Pas de buff ni debuff de raid fourni par le Voleur.
- Hébétement (Sap) ne brise plus le Camouflage ; Sprint ne le brise pas non plus.
- Spécialisations d'armes fusionnées dans Hack and Slash.
- Nouvelle race : Skyborne (Wind Blessed, +1 % hâte).

Durées et coûts utiles (Wowhead) :
- Kick (1766, 1767, 1768, 1769) : verrouillage de 5 s de l'école.
- Sprint (2983, 8696, 11305) : 15 s.
- Evasion (5277) : +50 % esquive, 15 s.
- Gouge (1776, 1777, 8629, 11285, 11286) : 4 s.
- Blind (2094) : 10 s.
- Vanish (1856, 1857 ; aura 11327, 11329) : 10 s.
- Distract (1725) : 10 s.
- Expose Armor (8647, 8649, 8650, 11197, 11198) : 30 s.
- Garrote (703, 8631, 8632, 8633, 11289, 11290) : saignement 18 s.
- Cheap Shot (1833) : 4 s, 2 points de combo, 60 énergie.
- Sap (6770, 2070, 11297) : jusqu'à 25 s.
- Kidney Shot (408, 8643) : durée selon les points de combo.
- Ambush (8676, 8724, 8725, 11267, 11268, 11269) : 250 % dégâts d'arme, 60 énergie, dague, dans le dos.
- Backstab (53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300) : 150 %, 60 énergie, dague, dans le dos.
- Sinister Strike (1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294) : 45 énergie.
- Mutilate (1310707, 399956, 1241582, 1241584) : 60 énergie, 2 points de combo, 75 % d'arme, +20 % sur cible empoisonnée, deux dagues.
- Hemorrhage (16511) : 35 énergie, 100 % (145 % avec dague), la cible subit +15 % de dégâts de Rupture. Note : Classes/Rogue.md signale 16511 comme contesté (marqué « absent de Forever » par endgametools).
- Venom (1310703) : jusqu'à 21 s selon les points de combo, +30 % dégâts de poison, +10 % application.
- Hardiness : -20 % durée des étourdissements (ID absent de Classes/Rogue.md).

Poisons (Wowhead) :
- Crippling Poison : 30 %, -50 % vitesse, 12 s. R1 3420 / 3408 / 3409 ou 25809 ; R2 3421 / 11202 / 11201.
- Mind-numbing Poison : 20 %, +40 % temps d'incantation, 10 s. R1 5763 / 5761 / 5760 ou 25810 ; R2 8694 / 8693 / 8692 ; R3 11400 / 11399 / 11398.
- Instant Poison : 20 %, nature. R1 8681 / 8679 / 8680 ; R2 8687 / 8686 / 8685 ; R3 8691 / 8688 / 8689 ; R4 11341 / 11338 / 11335 ; R5 11342 / 11339 / 11336 ; R6 11343 / 11340 / 11337.
- Deadly Poison : 30 %, 12 s, 5 cumuls. R1 2835 / 2823 / 2818 ou 434312 ; R2 2837 / 2824 / 2819 ou 434313 ; R3 11357 / 11355 / 11353 ou 434314 ; R4 11358 / 11356 / 11354 ou 434315 ; R5 25347 / 25351 / 25349 ou 434316.
- Wound Poison : 30 %, -soins, 15 s, 5 cumuls. R1 13220 / 13219 / 13218 ; R2 13228 / 13225 / 13222 ; R3 13229 / 13226 / 13223 ; R4 13230 / 13227 / 13224.
- Triplets = fabrication / application sur l'arme / effet sur la cible, comme dans Classes/Rogue.md.

Actifs raciaux de combat :
- Elune's Light (Elfe de la nuit) : +10 % critique, 15 s — ID absent de Classes/Rogue.md.
- Eureka! (Gnome) : voir « Désaccords » — ID absent de Classes/Rogue.md.
- Blood Fury (Orc) : +10 % puissance d'attaque, 15 s — ID absent de Classes/Rogue.md.
- Berserking (Troll) : +10 % vitesse d'attaque, 10 s — ID absent de Classes/Rogue.md.
- Touch of the Grave (Mort-vivant) : 5 % de proc, 1 s de recharge interne — ID absent de Classes/Rogue.md.

---

## Assassinat (DPS mêlée)

### Rotation / priorité

Niveau 30 (Icy Veins) :
1. Poisons sur les deux armes (Instant Poison conseillé).
2. Ouverture : Ambush (8676, 8724, 8725, 11267, 11268, 11269) depuis le Camouflage.
3. Mutilate (1310707, 399956, 1241582, 1241584) ; sinon Backstab (53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300) dans le dos ; sinon Sinister Strike (1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294).
4. Slice and Dice (5171, 6774) à 5 points de combo si la cible vit assez longtemps.
5. Sinon Eviscerate (2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016).

Niveau 30 (Wowhead) :
1. Mutilate à 3 points de combo ou moins, jamais à 4 ou plus.
2. Maintenir Slice and Dice (rafraîchir vers 0,1 s restante).
3. Expose Armor (8647, 8649, 8650, 11197, 11198) si le groupe est surtout physique.
4. Points en excès : Eviscerate sur cible peu blindée, Rupture (1943, 8639, 8640, 11273, 11274, 11275) sur cible très blindée.
- Sur un mob mourant, vider les points avec Slice and Dice ou Eviscerate.
- Cheap Shot (1833) utilisable via Vanish.

Niveau 20 (Wowhead) : joue comme Combat, construction au Backstab (Puncturing Wounds x3 réduit le coût de Backstab (valeur non indiquée)). Ordre : Backstab, Slice and Dice, Expose Armor si groupe physique.

### Procs et buffs à suivre

- Slice and Dice (5171, 6774) : buff à garder actif en permanence (ID d'aura distinct non vérifié).
- Venom (1310703) : second « Slice and Dice » à gérer, jusqu'à 21 s (Wowhead l'omet de sa rotation niveau 30).
- Cold Blood (14177) : à utiliser à la recharge (Icy Veins) ; étendu à Mutilate. L'aura a le même ID que le sort.
- Remorseless Attacks (14144, 14148) : ID d'aura du proc non établi ; étendu à Mutilate.
- Ruthlessness (14156, 14160, 14161 ; proc 14157) : point de combo gratuit.
- Relentless Strikes (14179 ; proc 14181) : effet non indiqué dans les guides lus (talent dès le niveau 20 selon Icy Veins).
- Improved Expose Armor (14168, 14169 ; proc 1310697) : réduit le coût d'énergie et rend 2 points de combo à 5 points.
- Malice (14138-14142) : critique, étendu aux poisons.

### Debuffs à maintenir sur la cible

- Poisons : Deadly Poison (cumuls x5), Instant Poison, Wound Poison, selon les listes d'IDs ci-dessus.
- Expose Armor (8647, 8649, 8650, 11197, 11198), 30 s, si groupe physique ; ID du debuff distinct non vérifié.
- Rupture (1943, 8639, 8640, 11273, 11274, 11275) sur cible très blindée ; ID du debuff distinct non vérifié.

### Recharges importantes

- Cold Blood (14177).
- Evasion (5277), Sprint (2983, 8696, 11305), Vanish (1856, 1857).
- Kick (1766, 1767, 1768, 1769).

### Ressources (énergie, points de combo, poisons)

- Énergie : Mutilate 60, Backstab 60, Sinister Strike 45.
- Points de combo : Mutilate en donne 2, d'où la règle « pas de Mutilate à 4 ou plus ».
- Poisons : charges consommables ; Improved Poisons (14113-14117) donne 50 % de chance de ne pas consommer de charge. Poisons = source principale de dégâts. Vile Poisons (16513, 16514, 16515, 16719, 16720).
- Wowhead : Deadly Poison sur au moins une arme (bonus de Mutilate).

### Talents clés

- Icy Veins : Remorseless Attacks (14144, 14148), Malice (14138-14142), Ruthlessness (14156, 14160, 14161), Relentless Strikes (14179, dès niveau 20), Lethality (14128, 14132, 14135, 14136, 14137) x4, Cold Blood (14177), Improved Poisons (14113-14117), Mutilate. Skippe Improved Slice and Dice (14165-14167). Points Legacy : Improved Poisons, Vile Poisons.
- Wowhead, points Legacy : Opportunity (14057, 14072-14075), Improved Eviscerate (14162-14164).
- Lethality étendu à Mutilate (4 % par point) ; Murder (14158, 14159) à 2 % par point, ne marche plus sur Bêtes et Draconiens ; Improved Kidney Shot (14174-14176) ne booste que les dégâts sur la cible étourdie ; Vigor (14983) remonté (2 points) ; Seal Fate (14186, 14190, 14193, 14194, 14195) ; Improved Gouge (13741, 13793, 13792).

### Mécaniques propres à Forever

- Mutilate +20 % sur cible empoisonnée.
- Les immunités nature pénalisent la spé.
- Venom comme deuxième entretien à gérer (niveau 30+).
- Talent Legacy « Talented » : ID absent de Classes/Rogue.md.

---

## Combat (DPS mêlée, meilleur cleave)

### Rotation / priorité

Niveau 30 (Icy Veins) :
1. Poisons.
2. Ambush (8676, 8724, 8725, 11267, 11268, 11269) avec dague, ou Garrote (703, 8631, 8632, 8633, 11289, 11290).
3. Blade Flurry (13877) tôt et souvent.
4. Riposte (14251) quand disponible.
5. Backstab (53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300) avec dague, ou Sinister Strike (1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294).
6. Slice and Dice (5171, 6774) à 5 points de combo.
7. Eviscerate (2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016).

Niveau 30 (Wowhead) :
1. Backstab (dague) ou Sinister Strike.
2. Slice and Dice.
3. Expose Armor (8647, 8649, 8650, 11197, 11198) si groupe physique.
4. Blade Flurry (13877) à énergie élevée avec plusieurs ennemis ou sur un boss.
5. Excès : Eviscerate sur cible peu blindée, Rupture (1943, 8639, 8640, 11273, 11274, 11275) sur cible très blindée.

Niveau 20 (Wowhead) : Sinister Strike, Slice and Dice, Expose Armor. Talents non négociables : Improved Sinister Strike, Improved Eviscerate, Precision.

### Procs et buffs à suivre

- Blade Flurry (13877) : fenêtre de burst / cleave.
- Adrenaline Rush (13750 ; aussi 28752, 28753) : pas encore dispo au niveau 30 selon Wowhead.
- Slice and Dice (5171, 6774).
- Riposte (14251) : aura de même ID.
- Improved Backstab via Puncturing Wounds (1224716 ; proc 1310710) : 45 % de chance de point de combo supplémentaire sur Backstab.
- Racial actif (voir plus haut) aligné avec Blade Flurry.

### Debuffs à maintenir sur la cible

- Expose Armor (8647, 8649, 8650, 11197, 11198) si groupe physique ; ID du debuff distinct non vérifié.
- Rupture (1943, 8639, 8640, 11273, 11274, 11275) sur cibles très blindées.
- Pas de dépendance aux poisons ni aux saignements (Wowhead).

### Recharges importantes

- Blade Flurry (13877), Adrenaline Rush (13750), racial : burst.
- Evasion (5277) et Sprint (2983, 8696, 11305), réduites de 30 / 60 % par Endurance (13742, 13872).
- Vanish (1856, 1857), Kick (1766, 1767, 1768, 1769), Kidney Shot (408, 8643).

### Ressources (énergie, points de combo, poisons)

- Eviscerate -10 énergie via Flawless Execution (1310711).
- Backstab 60 énergie, Sinister Strike 45 (réduit par Improved Sinister Strike 13732, 13863).
- Poisons sur les deux armes (Instant Poison conseillé par Icy Veins).

### Talents clés

- Icy Veins : Improved Sinister Strike (13732, 13863), Improved Eviscerate (14162-14164), Precision x3 (13705, 13832, 13843, 13844, 13845), Riposte (14251), Endurance x2 (13742, 13872), Lightning Reflexes (13712, 13788-13791), Flawless Execution (1310711), Dual Wield Specialization x4 (13715, 13848, 13849, 13851, 13852), Blade Flurry (13877). Puncturing Wounds (1224716) facultatif avec une dague. Le Voleur gère mal l'AoE, d'où l'importance de Blade Flurry.
- Wowhead : Hack and Slash (13706, 13804-13807 ; autres candidats existent) : haches et épées +5 % d'attaque supplémentaire, dagues et poings +5 % critique, masses ignorent 15 % d'armure. Aggression (18427-18429) booste aussi Backstab. Weapon Expertise (30919, 30920). Improved Sprint (13743, 13875), Improved Kick (13754, 13867).
- Points Legacy : Hack and Slash.

### Mécaniques propres à Forever

- Puncturing Wounds remplace Improved Backstab : critique sur Backstab et Mutilate.
- Hack and Slash fusionne les spécialisations d'armes.
- Precision plafonne à 3 points (+3 %). Dual Wield Specialization 5 % par point.
- Au niveau 30 : Flawless Execution, Dual Wield Specialization, Blade Flurry, Cheap Shot, Kidney Shot, Vanish. Pas de Riposte dans le build Wowhead.

---

## Finesse (Subtlety, DPS mêlée)

### Rotation / priorité

Début / niveau 20 :
- Icy Veins : Backstab (dos) ou Sinister Strike en construction, Eviscerate en finisseur, Slice and Dice sur cibles durables, Ambush (8676, 8724, 8725, 11267, 11268, 11269) depuis le Camouflage.
- Wowhead niveau 20 : construction Backstab / Ambush ; Puncturing Wounds x3 réduit le coût de Backstab (valeur non indiquée).

Niveau 30 (Icy Veins) :
1. Hemorrhage (16511) remplace les deux constructeurs, sans contrainte de position même avec dague.
2. Rupture (1943, 8639, 8640, 11273, 11274, 11275) sur les cibles qui vivent toute la durée, meilleure que Slice and Dice pour l'instant.
3. Evasion (5277) pour tanker et générer des points via Setup (13983, 14070, 14071).
4. Vanish (1856, 1857) pour réinitialiser la menace.
5. Attendre que le tank ait de la menace avant le burst. Pas d'AoE.

Niveau 30 (Wowhead) :
1. Toujours Garrote (703, 8631, 8632, 8633, 11289, 11290) depuis le Camouflage.
2. Maintenir Slice and Dice (5171, 6774).
3. Vanish + Preparation (14185) pour réappliquer Garrote à son expiration.
4. Expose Armor (8647, 8649, 8650, 11197, 11198) si groupe physique.
5. Excès : Eviscerate (2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016) sur cible peu blindée, Rupture sur cible très blindée.
6. Sinon Hemorrhage (16511) en constructeur.

### Procs et buffs à suivre

- Slice and Dice (5171, 6774).
- Thousand Cuts : cumuls de réduction de coût (candidats 1310721 ou 1310723).
- Setup (13983, 14070, 14071 ; proc 15250) : point de combo à 100 % sur esquive ou résistance totale.
- Initiative (13976, 13979, 13980 ; proc 13977) : point de combo en plus sur capacité de Camouflage, 100 %. Vanish puis Garrote = 2 points pour environ 15 énergie chacun.
- Cutthroat (424980, 462707, 462708 ou 1241810) : Backstab rend le prochain Ambush utilisable sans Camouflage (3 % par point).
- Premeditation (14183) : plus de Camouflage requis, fenêtre de 20 s.
- Vanished (14093), Vanish Purge (18461).
- Opportunity (14057, 14072-14075).

### Debuffs à maintenir sur la cible

- Garrote (703, 8631, 8632, 8633, 11289, 11290), 18 s ; ID du debuff distinct non vérifié.
- Rupture (1943, 8639, 8640, 11273, 11274, 11275) : finisseur secondaire optimal selon la page abilities (Hemorrhage +15 %, Serrated Blades +30 %, Thousand Cuts).
- Expose Armor (8647, 8649, 8650, 11197, 11198) si groupe physique.
- Ghostly Strike (14278) : dégâts, bonus avec dague.

### Recharges importantes

- Vanish (1856, 1857), Preparation (14185), Evasion (5277), Sprint (2983, 8696, 11305).
- Premeditation (14183), Ghostly Strike (14278), Cold Blood (14177) si pris.
- Kick (1766, 1767, 1768, 1769), Blind (2094), Sap (6770, 2070, 11297).

### Ressources (énergie, points de combo, poisons)

- Garrote 30 énergie (via Dirty Deeds), Cheap Shot 20 énergie par point de combo.
- Hemorrhage 35 énergie.
- Thousand Cuts : chaque tick de Rupture réduit de 3 énergie le prochain Hemorrhage / Backstab (5 cumuls, 10 s), environ 1,5 énergie/s à uptime parfait.
- Dirty Tricks (1224782) : Sap et Blind -25 % énergie par point.
- Poisons : Instant Poison sur les deux armes (Icy Veins).

### Talents clés

- Icy Veins niveau 30 : Camouflage (13975, 14062-14065), Improved Ambush (14079-14081), Setup, Ghostly Strike (14278), Remorseless Attacks (14144, 14148) facultatif. Points Legacy : Preparation (14185) et 2 points de Remorseless Attacks.
- Wowhead obligatoires niveau 30 : Opportunity, Initiative, Premeditation, Serrated Blades (14171-14173), Hemorrhage (16511).
- Nouveaux : Thousand Cuts, Quietus (1231651 ou 1310728 : +10 % dégâts de Sinister Strike, Hemorrhage, Ghostly Strike sous 35 % de vie), Dirty Tricks, Cutthroat.
- Autres : Master of Deception (13958, 13970-13973), Elusiveness (13981, 14066), Improved Distract (14084), Heightened Senses (30894, 30895), Dirty Deeds (14082, 14083).

### Mécaniques propres à Forever

- Premeditation sans Camouflage, fenêtre de 20 s.
- Camouflage : le premier point réduit la recharge de Stealth (1784, 1785, 1786, 1787) d'1 s de plus.
- Opportunity à 2 points (+10 %). Improved Sap supprimé.
- Initiative à 100 % (75 % avant).
- Serrated Blades = réduction d'armure fixe.
- Dirty Deeds retire la contrainte de position de Garrote.
- Faiblesse : immunité aux saignements.
- Icy Veins : Thousand Cuts rend Rupture quasi obligatoire.
- Macros de changement d'arme (dague pour Ambush et Backstab, arme lente pour Sinister Strike) : pas un sort, pas d'ID.

---

## Idées d'auras

- Énergie et points de combo (ressource) : jauge avec seuils à 35 / 45 / 60 selon le constructeur de la spé.
- Slice and Dice : durée restante, alerte de rafraîchissement ; ID d'aura à vérifier en jeu.
- Mutilate : alerte « 4 points de combo ou plus, ne pas lancer » (Assassinat).
- Cold Blood (14177), Blade Flurry (13877), Adrenaline Rush (13750) : icônes de burst avec temps restant.
- Poisons : charges et durée restantes sur chaque arme ; Deadly Poison sur la cible, cumuls x5.
- Rupture, Garrote, Expose Armor sur la cible : debuffs avec timer (IDs d'aura à vérifier).
- Thousand Cuts : compteur de cumuls (Finesse).
- Camouflage / Premeditation (14183) / Vanish (1856, 1857) / Preparation (14185) : séquence de réapplication de Garrote.
- Riposte (14251), Setup (proc 15250), Initiative (proc 13977), Remorseless Attacks : procs courts.
- Interruption : Kick (1766, 1767, 1768, 1769) en recharge, verrou 5 s.
- Racial actif selon la race du joueur (IDs absents).

## Désaccords entre sources

- Ambush en Assassinat : Icy Veins ouvre avec ; Wowhead dit qu'il n'a pas d'usage pratique en PvE (coût élevé). Venom : Wowhead le présente comme second finisseur mais l'omet de sa rotation niveau 30.
- Mutilate : Icy Veins « dès que possible » ; Wowhead « jamais à 4 points de combo ou plus ».
- Poison Assassinat : Icy Veins conseille Instant Poison sur les deux armes ; Wowhead Deadly Poison sur au moins une arme.
- Finesse niveau 30 : Icy Veins préfère Rupture à Slice and Dice ; Wowhead garde Slice and Dice en entretien permanent et réserve Rupture aux cibles très blindées.
- Combat : Icy Veins ouvre avec Ambush ou Garrote et utilise Riposte ; la rotation Wowhead niveau 30 n'a ni l'un ni l'autre.
- Improved Expose Armor : -5 énergie par point (page overview Wowhead) contre -10 (page abilities).
- Eureka! (Gnome) : Icy Veins parle de +10 % dégâts sur les 3 prochaines capacités ; Wowhead de -10 % d'énergie et +10 % dégâts, avec « 20 % de coût en moins » dans le texte.
- Icy Veins Finesse : une phrase cite le « plafond bêta actuel de 20 » alors que la page Assassinat vise le niveau 30 (incohérence interne).

## Sorts cités sans ID dans Classes/Rogue.md

Pierres d'affûtage (Sharpening Stone), Elune's Light, Eureka!, Blood Fury, Berserking, Touch of the Grave, Wind Blessed, Shadowmeld, Hardiness, talent Legacy « Talented », Thistle Tea ; en plus : auras distinctes de Slice and Dice, Rupture, Expose Armor et Garrote (non vérifiées), Remorseless Attacks (proc), Thousand Cuts (candidats seulement).

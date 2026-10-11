# Pack Voleur (Musca)

Fichiers : `PackVoleur.lua` (données), `PackVoleur.txt` (chaîne encodée). Préfixe d'uid `mcRogueV1`. IDs tirés de `Classes/Rogue.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Ghostly Strike, Kidney Shot, Gouge.
- Cooldowns : Kick, Blind, Vanish, Sprint, Evasion, Adrenaline Rush, Blade Flurry, Cold Blood, Preparation, Premeditation, Distract, Stealth. Les doublons de nom avec un buff portent le suffixe « (recharge) » (identifiants uniques exigés).
- Procs : Riposte (Action Usable).
- Buffs : Slice and Dice, Blade Flurry, Adrenaline Rush, Cold Blood, Premeditation, Evasion, Sprint, Stealth, Vanish.
- Debuffs cible : Rupture, Garrote, Expose Armor, Kidney Shot, Cheap Shot, Gouge, Blind, Sap, Hemorrhage, Deadly / Wound / Crippling / Mind-numbing Poison.
- Barres : énergie (type 3), points de combo (type 4), swing main droite et main gauche.
- Enchantements temporaires (poisons) main droite et main gauche.
- Rappels : poison manquant main droite, poison manquant main gauche.

## IDs à confirmer en jeu
- Auras de Slice and Dice, Rupture, Expose Armor, Garrote, Gouge, Kidney Shot, Cheap Shot, Sap, Blind, Hemorrhage, Premeditation, Blade Flurry, Evasion, Sprint, Stealth : le DB2 ne montre pas d'aura distincte du sort lancé, l'ID du sort est utilisé. Vérifier avec `/dump` sur `C_UnitAuras`.
- Vanish : 1856 / 1857 et 11327 / 11329 (sorts déclenchés) tous listés.
- Poisons sur la cible : Deadly Poison a deux familles d'IDs (2818... classique, 434312... probable Forever), les deux sont listées. Crippling R1 (3409 / 25809) et Mind-numbing R1 (5760 / 25810) : candidats multiples. Wound Poison : rangs 1 à 4 (13218, 13222, 13223, 13224).
- Riposte : 14251 (autres sorts de même nom 5237, 6187, 6569 non utilisés).

## Sorts écartés
- Sinister Strike, Backstab, Eviscerate, Mutilate, Hemorrhage (sans recharge) : absents de la rotation. Cheap Shot : pas en cooldown. Surprise Attack : absent du fichier. Shiv : absent du fichier.
- Rappel de stock de poisons : aucun ID d'objet dans le fichier, non fait.
- Règle des 5 secondes : sans objet (énergie). Le tick d'énergie n'est volontairement pas fait.

## À tester en jeu
- Barre des points de combo (type 4) : affichage en combat, remise à zéro hors cible.
- Barre d'énergie (type 3).
- Swing main gauche (`off`) avec deux armes.
- Riposte (Action Usable) : apparition après une parade, sort connu.
- Poisons : rappels hors combat et icônes d'enchantement, main droite et gauche.

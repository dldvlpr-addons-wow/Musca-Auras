# Pack Voleur (Musca)

Fichiers : `PackVoleur.lua` (données), `PackVoleur.txt` (chaîne encodée). Préfixe d'uid `mcRogueV1`. IDs tirés de `Classes/Rogue.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Sinister Strike, Backstab, Mutilate, Hemorrhage, Ambush, Eviscerate, Ghostly Strike.
- Cooldowns : Kick, Blind, Feint, Kidney Shot, Gouge, Vanish, Sprint, Evasion, Adrenaline Rush, Blade Flurry, Cold Blood, Preparation, Premeditation, Distract, Stealth. Les doublons de nom avec un buff portent le suffixe « (cooldown) » (identifiants uniques exigés).
- Procs : Riposte (Action Usable).
- Buffs : Slice and Dice, Blade Flurry, Adrenaline Rush, Cold Blood, Premeditation, Sprint, Stealth, Vanish.
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
- Cheap Shot : pas en cooldown. Surprise Attack : absent du fichier. Shiv : absent du fichier.
- Règle des 5 secondes : sans objet (énergie). Le tick d'énergie n'est volontairement pas fait.

## À tester en jeu
- Barre des points de combo (type 4) : affichage en combat, remise à zéro hors cible. `ComboPoints` est le seul type de puissance `NeverSecret` (relevé en jeu 1.60.1.70450) : en combat, `/dump issecretvalue(GetComboPoints("player","target")), issecretvalue(UnitPower("player",4)), issecretvalue(UnitPowerMax("player",4))` doit rendre `false, false, false`.
- Barre d'énergie (type 3).
- Swing main gauche (`off`) avec deux armes.
- Riposte (Action Usable) : apparition après une parade, sort connu.
- Poisons : rappels hors combat et icônes d'enchantement, main droite et gauche.

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Rappels sans aura suivie (poisons main droite et gauche) : l'icône pulse, le texte clignote.
- Texte « Not in melee range » (Sinister Strike 1752) : chargé en combat, caché à portée, affiché hors de portée (condition `spellInRange` sur l'alpha). Absent de la variante ForeverAuras.

## Comparaison avec les packs Fojji (2026-10-26), à tester en jeu
- Buffs sur le joueur : plus de filtre « lancé par le joueur », un buff reçu d'un autre joueur s'affiche.
- Nouvelle icône Defensives (toutes classes, reprise des packs Fojji, GPL-2) : Blessing of Protection, Freedom, Sacrifice, Power Word: Shield, Pain Suppression et potions défensives, de tout lanceur.
- Recharge de Riposte ajoutée, et son debuff (désarmement 14251) sur la cible.
- Buffs ajoutés : Venom 1310703, Remorseless Attacks 14143 (« Remorseless » dans le DB2 70245).

## Pack 1.15.0 (2026-10-29), à tester en jeu
- Evasion 5277 active dans l'icône Defensives ; buff Evasion retiré, la recharge reste.
- Rappel de stock de poisons dans les sacs, sous 5 : Instant Poison (6947 à 8928) et Deadly Poison (2892 à 20844). Un rappel par rang, chargé si la recette du rang est connue et celle du rang suivant inconnue : seul le plus haut rang connu s'affiche. Crippling, Mind-numbing et Wound Poison non couverts.

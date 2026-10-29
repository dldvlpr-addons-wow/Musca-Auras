# Pack Chasseur (Musca) — notes

IDs issus de `Classes/Hunter.md` (DB2 1.60.1.70245). Préfixe d'uid `mcHuntV1`.

## Contenu
- Rotation : Aimed Shot, Multi-Shot, Arcane Shot, Concussive Shot.
- Procs : Raptor Strike (Queued Action), Mongoose Bite et Counterattack (Action Usable).
- Cooldowns : Rapid Fire, Bestial Wrath, Intimidation, Feign Death, Freezing Trap, Frost Trap, Immolation Trap, Explosive Trap, Scatter Shot, Disengage, Deterrence, Flare (1543), Tranquilizing Shot (19801), Distracting Shot (20736). Chaque sort ne se charge que s'il est appris (rang 1 suffit).
- Buffs : Rapid Fire (actif), Quick Shots, Aspect of the Hawk (7 rangs).
- Debuffs cible : Serpent Sting, Hunter's Mark, Black Arrow, Wing Clip, Concussive Shot, Scorpid Sting, Viper Sting.
- Barres : mana, familier (vie), swing à distance (Auto Shot), règle des 5 s (Arcane Shot, Multi-Shot, Aimed Shot, Serpent Sting, Hunter's Mark).
- Rappels : aspect manquant (Hawk, Monkey, Cheetah, Pack, Beast, Wild, Viper, Falcon), Trueshot Aura, MANA BAS.

## IDs à confirmer en jeu
- Quick Shots 6150 : aura déclenchée par l'Aspect of the Hawk, source guildorder, nom DB2 du talent « Deadly Aspects ».
- Freezing Trap et Frost Trap : auras confirmées dans le DB2 70532 (3355, 14308, 14309 : étourdissement 10, 15 et 20 s ; 13810 : aura de zone persistante), suivies en debuff cible.
- Black Arrow (3674, 14296) : durée 30 s annoncée « Forever », présence DB2 ne prouve pas l'activité.
- Aspects Beast (13161, 1299445 à 1299447), Wild, Falcon, Viper : aura sur le sort lancé, non vue en jeu.
- Trueshot Aura : rappel conditionné au sort connu 1299346 (rang 1 entraîneur) ; le talent Classic est 19506. Si le rappel ne s'affiche jamais, changer `known`.
- Counterattack : rang 1 = 19306 (rang 2 = 1242634, atypique).

## Sorts écartés
- Kill Command, Readiness, Silencing Shot, Misdirection, Lock and Load, Snake Trap (Quazii Cata) : absents de `Classes/Hunter.md`.
- Serpent Sting, Hunter's Mark, Wing Clip, Scorpid Sting, Viper Sting : sans recharge, suivis en debuff seulement.
- Raptor Strike : proc Queued Action, pas d'icône de rotation.
- Wyvern Sting : seulement des candidats (24335, 24336, 26180, 26233, 1215753, talent 19386), « absent de Forever » selon une source.
- Bestial Wrath : buff porté par le familier, non suivi en aura joueur ; le cooldown suffit.

## À tester en jeu
- Flare, Tranquilizing Shot, Distracting Shot : absents sous le niveau d'apprentissage (32, 60, 12), présents ensuite avec leur recharge.
- Swing « ranged » : doit suivre Auto Shot.
- Queued Action : Raptor Strike s'affiche entre l'activation et le coup suivant.
- Action Usable : Mongoose Bite et Counterattack n'apparaissent que lorsqu'ils sont utilisables.
- Barre Familier : vie du familier, absente sans familier invoqué.
- Rappel d'aspect : disparaît dès qu'un aspect est actif.

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Barre de mana rouge sous 30 % par une condition sur le pourcentage secret, en combat aussi ; plus de copie rouge superposée (la variante ForeverAuras la garde).
- Rappels sans aura suivie (familier absent) : l'icône pulse, le texte clignote.

## Comparaison avec les packs Fojji (2026-10-26), à tester en jeu
- Buffs sur le joueur : plus de filtre « lancé par le joueur », un buff reçu d'un autre joueur s'affiche.
- Nouvelle icône Defensives (toutes classes, reprise des packs Fojji, GPL-2) : Blessing of Protection, Freedom, Sacrifice, Power Word: Shield, Pain Suppression et potions défensives, de tout lanceur.
- Recharges ajoutées : Strider Kick 1317257, Summon Hawk 1293527. Volley 1510 non ajouté : canalisation sans recharge dans `Classes/Hunter.md`.
- Buffs du familier : Bestial Wrath 19574, Frenzy 19615 (du familier de tout chasseur).
- Debuffs cible ajoutés : Freezing Trap (3355, 14308, 14309), Frost Trap 13810, Scatter Shot, Intimidation 24394, Scare Beast, Counterattack (immobilisation).

## Pack 1.15.0 (2026-10-29), à tester en jeu
- Deterrence 19263 active dans l'icône Defensives ; icône « Deterrence (active) » retirée, la recharge reste.
- Texte « In melee range » (Raptor Strike 2973) : chargé en combat, affiché quand la cible est au contact (`inside = true` de PackBuilder). Absent de la variante ForeverAuras.
- Rappel de munitions : déclencheur Ammo, munitions équipées sous 200, chargé si Auto Shot 75 est connu. Absent de la variante ForeverAuras (champs du déclencheur différents).

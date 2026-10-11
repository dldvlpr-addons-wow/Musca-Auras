# Pack Chasseur (Musca) — notes

IDs issus de `Classes/Hunter.md` (DB2 1.60.1.70245). Préfixe d'uid `mcHuntV1`.

## Contenu
- Rotation : Aimed Shot, Multi-Shot, Arcane Shot, Concussive Shot.
- Procs : Raptor Strike (Queued Action), Mongoose Bite et Counterattack (Action Usable).
- Cooldowns : Rapid Fire, Bestial Wrath, Intimidation, Feign Death, Freezing Trap, Frost Trap, Immolation Trap, Explosive Trap, Scatter Shot, Disengage, Deterrence.
- Buffs : Rapid Fire (actif), Quick Shots, Aspect of the Hawk (7 rangs), Deterrence (actif).
- Debuffs cible : Serpent Sting, Hunter's Mark, Black Arrow, Wing Clip, Concussive Shot, Scorpid Sting, Viper Sting.
- Barres : mana, familier (vie), swing à distance (Auto Shot), règle des 5 s (Arcane Shot, Multi-Shot, Aimed Shot, Serpent Sting, Hunter's Mark).
- Rappels : aspect manquant (Hawk, Monkey, Cheetah, Pack, Beast, Wild, Viper, Falcon), Trueshot Aura, MANA BAS.

## IDs à confirmer en jeu
- Quick Shots 6150 : aura déclenchée par l'Aspect of the Hawk, source guildorder, nom DB2 du talent « Deadly Aspects ».
- Freezing Trap et Frost Trap : aucun debuff de cible suivi (IDs d'effet 3355, 14308, 14309, 13810 non vérifiés).
- Black Arrow (3674, 14296) : durée 30 s annoncée « Forever », présence DB2 ne prouve pas l'activité.
- Aspects Beast (13161, 1299445 à 1299447), Wild, Falcon, Viper : aura sur le sort lancé, non vue en jeu.
- Trueshot Aura : rappel conditionné au sort connu 1299346 (rang 1 entraîneur) ; le talent Classic est 19506. Si le rappel ne s'affiche jamais, changer `known`.
- Counterattack : rang 1 = 19306 (rang 2 = 1242634, atypique).

## Sorts écartés
- Serpent Sting, Hunter's Mark, Wing Clip, Scorpid Sting, Viper Sting : sans recharge, suivis en debuff seulement.
- Raptor Strike : proc Queued Action, pas d'icône de rotation.
- Kill Command, Readiness : absents du fichier.
- Wyvern Sting : seulement des candidats (24335, 24336, 26180, 26233, 1215753, talent 19386), « absent de Forever » selon une source.
- Bestial Wrath : buff porté par le familier, non suivi en aura joueur ; le cooldown suffit.
- Munitions faibles : aucun ID d'objet dans le fichier.

## À tester en jeu
- Swing « ranged » : doit suivre Auto Shot.
- Queued Action : Raptor Strike s'affiche entre l'activation et le coup suivant.
- Action Usable : Mongoose Bite et Counterattack n'apparaissent que lorsqu'ils sont utilisables.
- Barre Familier : vie du familier, absente sans familier invoqué.
- Rappel d'aspect : disparaît dès qu'un aspect est actif.

# Pack Guerrier (Musca) — notes

Fichiers : `PackGuerrier.lua` (données), `PackGuerrier.txt` (chaîne encodée). IDs tirés de `Classes/Warrior.md` (DB2 1.60.1.70245), préfixe `mcWarrV1`.

## Contenu
- Rotation : Mortal Strike, Bloodthirst, Shield Slam, Whirlwind, Slam, Sunder Armor, Thunder Clap.
- Procs (Action Usable) : Overpower, Revenge, Execute, Victory Rush. Procs (Queued Action) : Heroic Strike, Cleave.
- Cooldowns : Recklessness, Death Wish, Shield Wall, Last Stand, Retaliation, Berserker Rage, Bloodrage, Pummel, Shield Bash, Charge, Intercept, Intimidating Shout, Sweeping Strikes, Taunt, Mocking Blow, Challenging Shout, Disarm, Concussion Blow.
- Buffs : Battle Shout, Enrage, Flurry, Shield Block, Sweeping Strikes, Death Wish, Recklessness, Berserker Rage, Bloodrage, Last Stand, Shield Wall, Retaliation (suffixe « (actif) » pour éviter les collisions d'identifiant avec les cooldowns).
- Debuffs cible : Rend, Sunder Armor, Thunder Clap, Demoralizing Shout, Hamstring (avec 23694 d'Improved Hamstring), Disarm, Concussion Blow, Mocking Blow, Deep Wounds, Mortal Strike.
- Barres : Rage, Swing main, Swing off. Rappel : Battle Shout manquant (hors combat).
- Pas de règle des 5 secondes (classe sans mana).

## IDs à confirmer en jeu
- Enrage : 12880 seul retenu (seul candidat portant une aura 79 en SpellEffect). Les autres homonymes (12317 talent, etc.) non liés. Vérifier par `/dump` de l'aura réelle.
- Flurry : 12966 seul retenu (SkillLineAbility Fury, aura oui, aura 319). Candidats écartés : 12319 (talent), 15088, 16256, 16257, 17687.
- Last Stand : aura 12976 (12975 = sort lancé sans aura ; lien non établi).
- Sweeping Strikes : aura 12292 (12723 homonyme sans aura écarté).
- Deep Wounds : 12162 (déclenché par 12834) ; type de l'aura non vérifié.
- Victory Rush : usable sur 402927, aucune aura ; homonyme 403434 non lié.

## Sorts écartés (absents de Classes/Warrior.md)
- Rangs de Flurry et d'Enrage au-delà du premier (aucun ID fourni). Aucun autre sort demandé n'est absent du fichier.
- Silences de Shield Bash et Pummel : pas d'aura reliée, donc aucun debuff cible (cooldown seul).

## Triggers à tester en jeu
- Action Usable : Overpower (après esquive), Revenge (après blocage/esquive/parade), Execute (cible <= 20 % PV), Victory Rush (20 s après un kill).
- Queued Action : Heroic Strike et Cleave (affichés quand armés sur le prochain coup).
- Swing off hand : barre « Swing off » avec armes à deux mains (doit rester vide) et en dual wield.
- Auras cible en combat (secrètes) : Rend, Sunder Armor, Thunder Clap, Demoralizing Shout, Hamstring, Disarm, Concussion Blow, Mocking Blow, Deep Wounds, Mortal Strike.
- Postures (règles Classic, sans table SpellShapeshift locale) : Taunt et Disarm visibles en Defensive seulement, Mocking Blow en Battle seulement, Shield Bash en Battle et Defensive.
- Slam (1240193) : rang 1 propre à Forever, cooldown suivi par nom.

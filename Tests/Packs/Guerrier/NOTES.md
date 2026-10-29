# Pack Guerrier (Musca) — notes

Fichiers : `PackGuerrier.lua` (données), `PackGuerrier.txt` (chaîne encodée). IDs tirés de `Classes/Warrior.md` (DB2 1.60.1.70245), préfixe `mcWarrV1`.

## Contenu
- Rotation : Mortal Strike, Bloodthirst, Shield Slam, Whirlwind, Slam, Sunder Armor, Thunder Clap.
- Procs (Action Usable) : Overpower, Revenge, Execute, Victory Rush. Procs (Queued Action) : Heroic Strike, Cleave.
- Cooldowns : Recklessness, Death Wish, Shield Wall, Last Stand, Retaliation, Berserker Rage, Bloodrage, Pummel, Shield Bash, Charge, Intercept, Intimidating Shout, Sweeping Strikes, Taunt, Mocking Blow, Challenging Shout, Disarm, Concussion Blow.
- Buffs : Battle Shout, Enrage, Flurry, Shield Block, Sweeping Strikes, Death Wish, Recklessness, Berserker Rage, Bloodrage, Retaliation (suffixe « (actif) » pour éviter les collisions d'identifiant avec les cooldowns).
- Debuffs cible : Rend, Sunder Armor, Thunder Clap, Demoralizing Shout, Hamstring (avec 23694 d'Improved Hamstring), Disarm, Concussion Blow, Mocking Blow, Mortal Strike.
- Barres : Rage, Swing main, Swing off. Rappel : Battle Shout manquant (hors combat).
- Pas de règle des 5 secondes (classe sans mana).

## IDs à confirmer en jeu
- Enrage : 12880 seul retenu (seul candidat portant une aura 79 en SpellEffect). Les autres homonymes (12317 talent, etc.) non liés. Vérifier par `/dump` de l'aura réelle.
- Flurry : 12966 seul retenu (SkillLineAbility Fury, aura oui, aura 319). Candidats écartés : 12319 (talent), 15088, 16256, 16257, 17687.
- Last Stand : aura 12976 (12975 = sort lancé sans aura ; lien non établi).
- Sweeping Strikes : aura 12292 (12723 homonyme sans aura écarté).
- Deep Wounds : retiré en 1.15. 12162 n'a qu'un effet Dummy sans aura dans le DB2 70532, et le saignement 12721 en est absent.
- Victory Rush : usable sur 402927, aucune aura ; homonyme 403434 non lié.

## Sorts écartés (absents de Classes/Warrior.md)
- Rangs de Flurry et d'Enrage au-delà du premier (aucun ID fourni). Aucun autre sort demandé n'est absent du fichier.
- Silences de Shield Bash et Pummel : pas d'aura reliée, donc aucun debuff cible (cooldown seul).

## Triggers à tester en jeu
- Action Usable : Overpower (après esquive), Revenge (après blocage/esquive/parade), Execute (cible <= 20 % PV), Victory Rush (20 s après un kill).
- Queued Action : Heroic Strike et Cleave (affichés quand armés sur le prochain coup).
- Swing off hand : barre « Swing off » avec armes à deux mains (doit rester vide) et en dual wield.
- Auras cible en combat (secrètes) : Rend, Sunder Armor, Thunder Clap, Demoralizing Shout, Hamstring, Disarm, Concussion Blow, Mocking Blow, Mortal Strike.
- Postures (règles Classic, sans table SpellShapeshift locale) : Taunt et Disarm visibles en Defensive seulement, Mocking Blow en Battle seulement, Shield Bash en Battle et Defensive.
- Slam (1240193) : rang 1 propre à Forever, cooldown suivi par nom.

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Texte « Not in melee range » (Sunder Armor 7386) : chargé en combat, caché à portée, affiché hors de portée (condition `spellInRange` sur l'alpha). Absent de la variante ForeverAuras.

## Pack 1.12.0 (2026-10-18)
- Aucun changement. Fusion recharge et buff (E6) écartée : le buff de Recklessness, Shield Wall, Retaliation, Berserker Rage ou Sweeping Strikes survit au changement de posture, et l'icône limitée à la posture le cacherait (danse de postures). Les icônes « (active) » restent.

## Comparaison avec les packs Fojji (2026-10-26), à tester en jeu
- Buffs sur le joueur : plus de filtre « lancé par le joueur », un buff reçu d'un autre joueur s'affiche.
- Nouvelle icône Defensives (toutes classes, reprise des packs Fojji, GPL-2) : Blessing of Protection, Freedom, Sacrifice, Power Word: Shield, Pain Suppression et potions défensives, de tout lanceur.
- Last Stand (actif) : 12975 et 12976.
- Victory Rush : suivi par l'aura 402975 « Victorious », déclenchée par 402974 Victorious State dans le DB2 70245 ; 402927 n'a aucune aura au lieu de « Action Usable ».
- Buffs ajoutés : Bloodthrill 1289682, Blood Craze 16488.
- Sunder Armor de tout lanceur ; Expose Armor (de tout lanceur) et Challenging Shout ajoutés en debuffs cible.

## Pack 1.15.0 (2026-10-29), à tester en jeu
- Deep Wounds retiré des debuffs cible (12162 sans aura dans le DB2 70532).
- Shield Wall 871 et Last Stand 12976 actifs dans l'icône Defensives ; icônes « (active) » retirées, les recharges restent.

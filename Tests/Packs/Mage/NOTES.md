# Pack Mage (Musca) — notes

Fichiers : `PackMage.lua` (données, préfixe `mcMageV1`), `PackMage.txt` (chaîne encodée). Tous les IDs viennent de `Classes/Mage.md`.

## Contenu
- Rotation : Fire Blast, Frost Nova, Cone of Cold, Blast Wave, Arcane Blast (rang 1 par talent).
- Cooldowns : Counterspell, Blink, Ice Block, Evocation, Arcane Power, Combustion, Presence of Mind, Cold Snap, Ice Barrier.
- Buffs : Clearcasting, Arcane Power, Combustion, Presence of Mind, Ice Barrier, Mana Shield, Ice Block, Armure (Frost, Ice, Mage Armor en une icône), Arcane Intellect.
- Debuffs cible : Winter's Chill, Fire Vulnerability, Ignite, Pyroblast (DoT), Frostbolt (ralentissement), Polymorph.
- Barres : mana et règle des 5 s (Frostbolt, Fireball, Arcane Missiles, Scorch, Fire Blast, Frost Nova, Cone of Cold, Arcane Explosion, Blizzard, Flamestrike, Pyroblast, Polymorph, Arcane Blast).
- Rappels : Arcane Intellect manquant, armure manquante, MANA BAS.

## IDs à confirmer en jeu
- Ignite (debuff cible) : 3261, 412538, 1234540 (candidats nommés « Ignite », non tranchés ; 412545 exclu, sans aura).
- Clearcasting : 12536 seul retenu ; 16246, 16870, 457342, 467735 (même nom) non utilisés.
- Combustion : aura 28682 (déclenchée par 11129).
- Frostbolt / Pyroblast / Polymorph (debuffs) : les IDs de rang servent d'IDs d'aura, à vérifier (Chilled 12484 non utilisé).

## Sorts ignorés
- Arcane Explosion (sans recharge), Arcane Missiles, Ice Lance, Scorch, Fireball, Frostbolt (pas de recharge).
- Icy Veins (425121), Arcane Barrage, Living Bomb : absents des tableaux de sorts de `Classes/Mage.md`.
- Auras Arcane Blast (cumuls), Missile Barrage, Fingers of Frost, Heating Up : candidats non tranchés, aucune icône.
- Rappel Mana Gem : aucun ID d'objet dans `Classes/Mage.md`.

## Triggers à tester en jeu
- Aura Clearcasting (12536) au proc d'Arcane Concentration, en combat.
- Debuffs cible (Ignite, Winter's Chill, Fire Vulnerability) : affichage et durée en combat.
- Icône Arcane Blast (rang 1 par talent) : chargement conditionné à `spellknown`.
- Rappels hors combat : Arcane Intellect, armure.

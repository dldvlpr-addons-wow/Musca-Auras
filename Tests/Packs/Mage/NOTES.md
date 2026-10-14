# Pack Mage (Musca) — notes

Fichiers : `PackMage.lua` (données, préfixe `mcMageV1`), `PackMage.txt` et `PackMageForeverAuras.txt` (chaînes encodées). Tous les IDs viennent de `Classes/Mage.md`.

## Contenu
- Rotation : Fire Blast, Frost Nova, Cone of Cold, Blast Wave, Arcane Blast (rang 1 par talent).
- Cooldowns : Counterspell, Blink, Ice Block, Evocation, Arcane Power, Combustion, Presence of Mind, Cold Snap, Ice Barrier, Fire Ward (543), Frost Ward (6143). Chaque sort ne se charge que s'il est appris (rang 1, repli par nom).
- Buffs : Clearcasting, Arcane Power, Combustion, Presence of Mind, Ice Barrier, Mana Shield, Ice Block, Fire Ward et Frost Ward (tous rangs), Slow Fall (130), Armure (Frost, Ice, Mage Armor en une icône), Arcane Intellect.
- Debuffs cible : Winter's Chill et Fire Vulnerability (lueur dans la fenêtre de rafraîchissement, `dot`), Ignite, Pyroblast (DoT), Frostbolt (ralentissement), Polymorph.
- Barres : mana et règle des 5 s (Frostbolt, Fireball, Arcane Missiles, Scorch, Fire Blast, Frost Nova, Cone of Cold, Arcane Explosion, Blizzard, Flamestrike, Pyroblast, Polymorph, Arcane Blast).
- Rappels : Arcane Intellect manquant, armure manquante, MANA BAS.

## IDs à confirmer en jeu
- Fire Ward / Frost Ward / Slow Fall (buffs) : IDs de rang du sort lancé utilisés comme IDs d'aura (aucune aura distincte dans le fichier). Vérifier par `/dump`.
- Ignite (debuff cible) : 3261, 412538, 1234540 (candidats nommés « Ignite », non tranchés ; 412545 exclu, sans aura).
- Clearcasting : 12536 seul retenu ; 16246, 16870, 457342, 467735 (même nom) non utilisés.
- Combustion : aura 28682 (déclenchée par 11129).
- Frostbolt / Pyroblast / Polymorph (debuffs) : les IDs de rang servent d'IDs d'aura, à vérifier (Chilled 12484 non utilisé).

## Sorts ignorés
- Runes SoD (Fingers of Frost, Hot Streak, Missile Barrage, débuff Arcane Blast) : IDs d'aura non tranchés dans `Classes/Mage.md` et aucun sort appris pour conditionner le chargement ; Brain Freeze, Living Bomb, Balefire Bolt, Temporal Beacon, Icy Veins, Arcane Surge, Deep Freeze absents du fichier.
- Glow « prêt et à portée » (Frost Nova, Cone of Cold, Counterspell, Blast Wave, Fire Blast) : exige un test de portée absent du générateur et lu en combat (secret). Dragon's Breath, Spellsteal, Mana Gem : absents du fichier.
- Arcane Explosion (sans recharge), Arcane Missiles, Ice Lance, Scorch, Fireball, Frostbolt (pas de recharge).
- Icy Veins (425121), Arcane Barrage, Living Bomb : absents des tableaux de sorts de `Classes/Mage.md`.
- Auras Arcane Blast (cumuls), Missile Barrage, Fingers of Frost, Heating Up : candidats non tranchés, aucune icône.
- Rappel Mana Gem : aucun ID d'objet dans `Classes/Mage.md`.

## Triggers à tester en jeu
- Fire Ward / Frost Ward : icône de recharge et buff actif (tous rangs) ; Slow Fall actif ; absence des icônes tant que le sort n'est pas appris.
- Winter's Chill / Fire Vulnerability : lueur dans la fenêtre de rafraîchissement.
- Aura Clearcasting (12536) au proc d'Arcane Concentration, en combat.
- Debuffs cible (Ignite, Winter's Chill, Fire Vulnerability) : affichage et durée en combat.
- Icône Arcane Blast (rang 1 par talent) : chargement conditionné à `spellknown`.
- Rappels hors combat : Arcane Intellect, armure.

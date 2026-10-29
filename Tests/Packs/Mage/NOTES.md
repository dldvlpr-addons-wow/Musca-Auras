# Pack Mage (Musca) — notes

Fichiers : `PackMage.lua` (données, préfixe `mcMageV1`), `PackMage.txt` et `PackMageForeverAuras.txt` (chaînes encodées). Tous les IDs viennent de `Classes/Mage.md`.

## Contenu
- Rotation : Fire Blast, Frost Nova, Cone of Cold, Blast Wave, Arcane Blast (rang 1 par talent).
- Cooldowns : Counterspell, Blink, Ice Block, Evocation, Arcane Power, Combustion, Presence of Mind, Cold Snap, Ice Barrier, Fire Ward (543), Frost Ward (6143). Chaque sort ne se charge que s'il est appris (rang 1, repli par nom).
- Buffs : Clearcasting, Missile Barrage, Fingers of Frost, Heating Up, Arcane Power, Combustion, Presence of Mind, Ice Block, Slow Fall (130), Armure (Frost, Ice, Mage Armor en une icône), Arcane Intellect. Ice Barrier, Fire Ward, Frost Ward et Mana Shield actifs : icône Defensives.
- Debuffs cible : Winter's Chill et Fire Vulnerability (lueur dans la fenêtre de rafraîchissement, `dot`), Ignite, Pyroblast (DoT), Frostbolt (ralentissement), Polymorph.
- Barres : mana et règle des 5 s (Frostbolt, Fireball, Arcane Missiles, Scorch, Fire Blast, Frost Nova, Cone of Cold, Arcane Explosion, Blizzard, Flamestrike, Pyroblast, Polymorph, Arcane Blast).
- Rappels : Arcane Intellect manquant, armure manquante, MANA BAS.

## IDs à confirmer en jeu
- Fire Ward / Frost Ward / Slow Fall (buffs) : IDs de rang du sort lancé utilisés comme IDs d'aura (aucune aura distincte dans le fichier). Vérifier par `/dump`.
- Ignite (debuff cible) : 3261, 412538, 1234540 (candidats nommés « Ignite », non tranchés ; 412545 exclu, sans aura).
- Clearcasting : 12536 seul retenu ; 16246, 16870, 457342, 467735 (même nom) non utilisés.
- Combustion : aura 28682 (déclenchée par 11129).
- Frostbolt / Pyroblast / Polymorph (debuffs) : les IDs de rang posent l'aura eux-mêmes dans le DB2 70532 (Frostbolt 5 à 9 s, Pyroblast 12 s périodique, Polymorph 20 à 50 s ; Chilled 12484 non utilisé).

## Sorts ignorés
- Runes SoD (débuff Arcane Blast) : aura 400573, comptée par les lancers (voir plus bas). Fingers of Frost, Heating Up et Missile Barrage : candidats retenus par Fojji, sans sort appris pour conditionner le chargement ; Brain Freeze, Living Bomb, Balefire Bolt, Temporal Beacon, Icy Veins, Arcane Surge, Deep Freeze absents du fichier.
- Glow « prêt et à portée » (Frost Nova, Cone of Cold, Counterspell, Blast Wave, Fire Blast) : exige un test de portée absent du générateur et lu en combat (secret). Dragon's Breath, Spellsteal, Mana Gem : absents du fichier.
- Arcane Explosion (sans recharge), Arcane Missiles, Ice Lance, Scorch, Fireball, Frostbolt (pas de recharge).
- Icy Veins (425121), Arcane Barrage, Living Bomb : absents des tableaux de sorts de `Classes/Mage.md`.
- Auras Arcane Blast (cumuls) : 400573, débuff sur soi, suivi par un compteur de lancers (voir plus bas).
- Rappel Mana Gem : aucun ID d'objet dans `Classes/Mage.md`.

## Triggers à tester en jeu
- Fire Ward / Frost Ward : icône de recharge et buff actif (tous rangs) ; Slow Fall actif ; absence des icônes tant que le sort n'est pas appris.
- Winter's Chill / Fire Vulnerability : lueur dans la fenêtre de rafraîchissement.
- Aura Clearcasting (12536) au proc d'Arcane Concentration, en combat.
- Debuffs cible (Ignite, Winter's Chill, Fire Vulnerability) : affichage et durée en combat.
- Icône Arcane Blast (rang 1 par talent) : chargement conditionné à `spellknown`.
- Rappels hors combat : Arcane Intellect, armure.

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Barre de mana rouge sous 30 % par une condition sur le pourcentage secret, en combat aussi ; plus de copie rouge superposée (la variante ForeverAuras la garde).

## Comparaison avec les packs Fojji (2026-10-26), à tester en jeu
- Buffs sur le joueur : plus de filtre « lancé par le joueur », un buff reçu d'un autre joueur s'affiche.
- Nouvelle icône Defensives (toutes classes, reprise des packs Fojji, GPL-2) : Blessing of Protection, Freedom, Sacrifice, Power Word: Shield, Pain Suppression et potions défensives, de tout lanceur.
- Ice Barrier, Fire Ward et Frost Ward : simple recharge, comme Fojji. Boucliers actifs (Ice Barrier, Fire Ward, Frost Ward, Mana Shield) dans l'icône Defensives ; les buffs « (active) » et Mana Shield sont retirés.
- Procs ajoutés : Missile Barrage 400589, Fingers of Frost 400670 (cumuls), Heating Up 400625 (cumuls, « Hot Streak » chez Icy Veins). Candidats DB2 de `Classes/Mage.md`, retenus par Fojji.
- Clearcasting chargé sur la classe, sans `known = 11213`. Rappel d'armure : alerte d'expiration à 300 s.
- Cumuls d'Arcane Blast : aura 400573 (DB2 70532 : 4 cumuls, DurationIndex 8 = 15 s, 0 charge de proc ; en 70245 : 31 = 8 s, 1 charge), débuff sur soi illisible par ID de sort en combat. Quatre segments comptent les lancers (`segments.casts` de PackBuilder, déclencheur custom sur `UNIT_SPELLCAST_SUCCEEDED:player`) : chaque rang d'Arcane Blast ajoute un cumul (4 max) et relance les 15 s ; aucun autre sort ne les efface, ils expirent. Aucun sort du DB2 70532 ne référence 400573. Non vérifié en jeu, ni sur ForeverAuras. Scénario `Tests/Scenarios/89_ArcaneBlastStacks.lua`.

## Pack 1.15.0 (2026-10-29), à tester en jeu
- Aucun changement de pack. Auras « à vérifier » tranchées dans le DB2 70532, voir plus haut.

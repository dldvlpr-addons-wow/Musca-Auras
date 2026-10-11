# Pack Druide (Musca) - notes

Source des IDs : `Classes/Druid.md` (DB2 1.60.1.70245). Préfixe d'uid `mcDruiV1`. Fichier généré : `PackDruide.txt` (encode de `PackDruide.lua`).

## Contenu
- Rotation : Bash, Growl (forme ours), Swiftmend (mana).
- Cooldowns : Cower, Dash (félin) ; Enrage, Frenzied Regeneration, Challenging Roar, Feral Charge (ours) ; Hurricane, Nature's Swiftness, Innervate, Rebirth, Barkskin, Tranquility (lanceur).
- Procs : Maul (action en file, ours).
- Buffs : Clearcasting, Nature's Grace, Enrage, Frenzied Regeneration, Barkskin, Innervate, Nature's Swiftness, Dash, Rejuvenation, Regrowth. Les six premiers doublons de nom avec un cooldown portent le suffixe « (actif) ».
- Debuffs cible : Moonfire, Insect Swarm, Rake, Rip, Pounce (saignement), Faerie Fire, Demoralizing Roar, Entangling Roots, Hibernate.
- Barres : Énergie et Points de combo (félin), Rage (ours), Mana (toutes formes), règle des 5 s (Wrath, Starfire, Moonfire, Insect Swarm, Healing Touch, Regrowth, Rejuvenation).
- Rappels : Mark of the Wild, Thorns, Omen of Clarity, MANA BAS.

## IDs à confirmer en jeu
- Auras de HoT, DoT et buffs : seul l'ID du sort lancé est connu, pas l'aura (Rejuvenation, Regrowth, Moonfire, Insect Swarm, Rake, Rip, Faerie Fire, Demoralizing Roar, Entangling Roots, Hibernate, Mark of the Wild, Thorns, Enrage, Frenzied Regeneration, Barkskin, Innervate, Nature's Swiftness, Dash).
- Pounce : 9007, 9824, 9826 (Pounce Bleed, déclenchés dans le DB2, aura non vérifiée en jeu).
- Clearcasting 16870 et Nature's Grace 16886 : déclenchés par les talents 16864 et 16880 dans le DB2.
- Omen of Clarity (16864) : talent donné absent de Forever par wowforevertalents.com, présent dans le DB2. Si absent en jeu, Clearcasting et le rappel ne s'afficheront jamais (chargement conditionné au sort connu).
- Feral Charge : sort 1238122 (talent Farouche), aura d'immobilisation 19675 non utilisée.
- Entangling Roots cible : l'aura peut avoir un autre ID (Nature's Grasp déclenche 19970 à 19975).

## Sorts écartés
- Tiger's Fury : absent en jeu sur Forever (5217 et 417045 jamais appris).
- Faerie Fire (Feral) : absent du DB2.
- Starfall, Force of Nature : absents du fichier.
- Pounce et Ravage (recharge nulle), Swipe, Moonfire (pas de recharge), Claw, Shred, Ferocious Bite : pas de recharge, non suivis en cooldown.
- Compteur de powershift : volontairement non fait.

## À tester en jeu
- Filtre de forme par type de puissance primaire : énergie = félin, rage = ours, mana = lanceur, Moonkin, Restauration. Vérifier qu'une icône n'apparaît que dans sa forme, y compris en combat (puissance secrète).
- Maul : déclencheur « Queued Action » (prochaine attaque), visible seulement en ours.
- Barre de mana visible en forme de félin et d'ours (déclencheur sans filtre de forme).
- Barre de points de combo en félin hors combat et en combat.
- Règle des 5 s : se relance sur les lancers listés.

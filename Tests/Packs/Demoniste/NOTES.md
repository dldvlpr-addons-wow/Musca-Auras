# Pack Démoniste (Musca) — notes

Données : `PackDemoniste.lua` (builder `Tests/Packs/PackBuilder.lua`), chaîne importable : `PackDemoniste.txt`. IDs tirés de `Classes/Warlock.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Shadowburn, Conflagrate, Soul Fire, Death Coil.
- Cooldowns : Howl of Terror, Fel Domination, Amplify Curse, Bane of Doom, Shadow Ward, Inferno, et sorts de familier (Spell Lock, Seduction, Suffering : chargés seulement si le familier correspondant est invoqué).
- Buffs : Shadow Trance, Demon Skin / Demon Armor (tous rangs), Soul Link (aura 25228 ou 19028), Amplify Curse (actif), Sacrifice (Voidwalker, 6 rangs), Fel Domination (actif), Pyroclasm.
- Debuffs cible : Corruption, Immolate, Bane of Agony, Bane of Doom, Curse of the Elements, Curse of Recklessness, Curse of Weakness, Curse of Tongues, Siphon Life, Shadow Vulnerability, Fear et Banish (les deux avec glow, contrôle).
- Barres : mana, familier, règle des 5 s (Shadow Bolt, Immolate, Corruption, Bane of Agony, Searing Pain, Incinerate, Drain Life, Drain Soul, Fear, Soul Fire, Rain of Fire, Hellfire ; Life Tap exclu).
- Rappels : armure manquante (Demon Skin / Demon Armor), Soul Link manquant, Soul Shard à 0 (objet 6265), familier absent, MANA BAS.

## IDs à confirmer en jeu
- Aucun ID d'aura de DoT ou de malédiction n'est vérifié séparément : repris des IDs de sort (le DB2 indique que le sort porte lui-même l'effet APPLY_AURA).
- Demon Skin 687 / 696 et Demon Armor r1-r4 : IDs de sort, seul r5 (11735) lu sur Wowhead.
- Soul Link : 19028 (sort/talent) ; aura posée 25228 (Wowhead Forever).
- Amplify Curse (actif) : 18288, l'aura porte l'ID du talent (Wowhead Forever).
- Shadow Ward (actif, icône Defensives) : 6229 / 11739 / 11740 / 28610 (absorption 30 s, auras confirmées dans le DB2 70532).
- Bane of Doom (debuff cible) : 603 ; 18662 est l'effet d'invocation, pas un debuff.
- Conflagrate : rang 1 = 1293817 (fichier) ; Talent.csv donne 17962. Le chargement par sort connu dépend de ce choix.
- Shadowburn r1 17877 et Siphon Life r1 18265 : sorts de talent (Talent 963 et 1041 dans le DB2 70532), rangs de Siphon Life 18879 à 18881 ; chargement par sort connu à vérifier en jeu.

- Sacrifice : 7812, 19438, 19440-19443 (sorts du Marcheur du Vide) lus comme IDs d'aura ; chargé si Summon Voidwalker 697 est connu. Buffs des autres familiers sacrifiés (18789-18792) non suivis.
- Pyroclasm : aura 1293803 (18093 = étourdissement de la cible), chargement sur le talent 18096 (Talent.csv) ; talent peut-être retiré côté serveur.
- Spell Lock 19244, Seduction 6358, Suffering 17735 : sorts de familier, suivis en Cooldown Progress (DB2 70532 : Spell Lock et Suffering sans aura, Seduction avec aura) ; le « sort connu » du familier est à vérifier en jeu.
- Banish : 710 / 18647 (sorts), aura supposée identique.

## Sorts écartés
- Chaos Bolt, Haunt, Unstable Affliction, Curse of Shadow, Backlash, Backdraft : absents du fichier.
- Rappel Soul Shard bas : ID d'objet Soul Shard absent du fichier.
- Soul Link (cooldown) : toggle.
- Curse of Exhaustion, Death Coil (debuff), Shadow and Flame : hors décision de rotation.

## Triggers à tester en jeu
- Familiers : Spell Lock (Chasseur corrompu), Seduction (Succube), Suffering (Marcheur du Vide) n'apparaissent qu'avec le familier concerné, et leur recharge se met à jour.
- Rappel Soul Link : affiché hors combat sans Soul Link actif, talent connu et familier présent seulement (masqué après Demonic Sacrifice).
- Fear et Banish sur la cible : icône avec glow tant que le contrôle dure.
- Sacrifice, Fel Domination (actif), Pyroclasm : visibles à l'activation.
- Shadow Trance (proc Nightfall) visible en combat sur le buff 17941.
- Debuffs cible : aura filtrée sur le joueur, lecture en combat (secret).
- Armure manquante : rappel affiché hors combat quand aucun rang n'est actif.
- Règle des 5 s : le décompte repart sur chaque rang des sorts listés (correspondance par nom).
- Barre familier : sans familier, la barre doit rester vide ou masquée.
- Cooldowns Conflagrate / Shadowburn : icône affichée uniquement si le sort est connu.

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Barre de mana rouge sous 30 % par une condition sur le pourcentage secret, en combat aussi ; plus de copie rouge superposée (la variante ForeverAuras la garde).
- Rappels sans aura suivie (Soul Shard à 0, familier absent) : l'icône pulse, le texte clignote.

## Comparaison avec les packs Fojji (2026-10-26), à tester en jeu
- Buffs sur le joueur : plus de filtre « lancé par le joueur », un buff reçu d'un autre joueur s'affiche.
- Nouvelle icône Defensives (toutes classes, reprise des packs Fojji, GPL-2) : Blessing of Protection, Freedom, Sacrifice, Power Word: Shield, Pain Suppression et potions défensives, de tout lanceur.
- Shadow Ward : simple recharge, comme Fojji ; bouclier actif dans l'icône Defensives, le buff « (active) » est retiré.
- Buffs ajoutés : Demonic Sacrifice (18789 Burning Shadow, 18790 Fel Stamina, 18791 Touch of Fire, 18792 Fel Energy : noms du DB2 70245), Decimation 440873 (candidat DB2 retenu par Fojji).
- Debuffs cible ajoutés : Bane of Havoc 1225228, Death Coil (6789, 17925, 17926), Howl of Terror (5484, 17928), Seduction 6358 (lancée par la succube, de tout lanceur).

## Pack 1.15.0 (2026-10-29), à tester en jeu
- Aucun changement de pack. Auras « à vérifier » tranchées dans le DB2 70532, voir plus haut.

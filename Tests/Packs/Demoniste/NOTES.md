# Pack Démoniste (Musca) — notes

Données : `PackDemoniste.lua` (builder `Tests/Packs/PackBuilder.lua`), chaîne importable : `PackDemoniste.txt`. IDs tirés de `Classes/Warlock.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Shadowburn, Conflagrate, Soul Fire, Death Coil.
- Cooldowns : Howl of Terror, Fel Domination, Amplify Curse, Bane of Doom, Shadow Ward.
- Buffs : Shadow Trance, Demon Skin / Demon Armor (tous rangs), Shadow Ward (actif), Soul Link, Amplify Curse (actif).
- Debuffs cible : Corruption, Immolate, Bane of Agony, Bane of Doom, Curse of the Elements, Curse of Recklessness, Curse of Weakness, Curse of Tongues, Siphon Life, Shadow Vulnerability, Fear.
- Barres : mana, familier, règle des 5 s (Shadow Bolt, Immolate, Corruption, Bane of Agony, Searing Pain, Incinerate, Drain Life, Drain Soul, Fear, Soul Fire, Rain of Fire, Hellfire ; Life Tap exclu).
- Rappels : armure manquante (Demon Skin / Demon Armor), MANA BAS.

## IDs à confirmer en jeu
- Aucun ID d'aura de DoT ou de malédiction n'est vérifié séparément : repris des IDs de sort (le DB2 indique que le sort porte lui-même l'effet APPLY_AURA).
- Demon Skin 687 / 696 et Demon Armor r1-r4 : IDs de sort, seul r5 (11735) lu sur Wowhead.
- Soul Link : 19028 (sort/talent) ; aura posée 25228 (Wowhead Forever).
- Amplify Curse (actif) : 18288, l'aura porte l'ID du talent (Wowhead Forever).
- Shadow Ward (actif) : 6229 / 11739 / 11740 / 28610 (IDs de sort, non vérifiés).
- Bane of Doom (debuff cible) : 603 ; 18662 est l'effet d'invocation, pas un debuff.
- Conflagrate : rang 1 = 1293817 (fichier) ; Talent.csv donne 17962. Le chargement par sort connu dépend de ce choix.
- Shadowburn r1 17877 et Siphon Life r1 18265 : sorts de talent, chargement par sort connu à vérifier.

## Sorts écartés
- Chaos Bolt, Haunt, Unstable Affliction, Curse of Shadow, Backlash, Backdraft : absents du fichier.
- Rappel Soul Shard bas : ID d'objet Soul Shard absent du fichier.
- Soul Link (cooldown), Spell Lock : toggle ou sort du familier.
- Curse of Exhaustion, Banish, Death Coil (debuff), Pyroclasm, Shadow and Flame : hors décision de rotation.

## Triggers à tester en jeu
- Shadow Trance (proc Nightfall) visible en combat sur le buff 17941.
- Debuffs cible : aura filtrée sur le joueur, lecture en combat (secret).
- Armure manquante : rappel affiché hors combat quand aucun rang n'est actif.
- Règle des 5 s : le décompte repart sur chaque rang des sorts listés (correspondance par nom).
- Barre familier : sans familier, la barre doit rester vide ou masquée.
- Cooldowns Conflagrate / Shadowburn : icône affichée uniquement si le sort est connu.

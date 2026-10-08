# Guerrier — WoW Forever 1.60.1

Sources et build lus, date 2026-10-08.
- DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName). Le DB2 fait foi pour les IDs. Il contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- IDs et niveaux : https://wow-forever.gg/db/spells/browse/class/warrior/ (127 lignes, build 1.60.1.70245, données au 2026-10-06).
- Coûts, recharges, durées : https://endgametools.com/en/wow-forever/spells/warrior et https://wowforevertalents.com/abilities/warrior/ (build 1.60.1.70245). Ces deux pages ne donnent aucun spell ID.
- IDs de talents : https://wow-forever.gg/classes/warrior/{arms,fury,protection}/.
- Wowhead Forever : pages de sorts lisibles (spell=12292, 12317, 12319), mais la liste filtrée par classe n'est pas exploitable (formulaire sans résultats) et les pages ne montrent pas l'ID du sort.
- Colonnes vides (—) : valeur non listée par les sources. Les durées de Rend et Thunder Clap viennent d'endgametools (rang par rang).

## Sorts de base (entraîneur)

Le tableau reprend les 127 lignes de wow-forever.gg : sorts d'entraîneur, passifs de posture, et talents/sorts de talent que cette source étiquette « Warrior » (Death Wish, Last Stand, Improved Pummel, etc.). Bloodthirst, Mortal Strike et Shield Slam : rang 1 = talent.

| Nom | Rang | Spell ID | Niveau | Coût / ressource | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Battle Shout | 1 | 6673 | 1 | 10 Rage | — | 3 min | — |
| Battle Stance | — | 2457 | 1 | — | — | — | — |
| Battle Stance Passive | — | 21156 | 1 | — | — | — | — |
| Death Wish | — | 12328 | 1 | — | — | 30 s (wow-forever.gg) | talent Fury |
| Heroic Strike | 1 | 78 | 1 | 15 Rage | — | — | — |
| Improved Challenging Shout | 1 | 12327 | 1 | — | — | — | — |
| Improved Challenging Shout | 2 | 12886 | 1 | — | — | — | — |
| Improved Pummel | 1 | 12288 | 1 | — | — | — | — |
| Improved Pummel | 2 | 12707 | 1 | — | — | — | — |
| Improved Pummel | 3 | 12708 | 1 | — | — | — | — |
| Last Stand | — | 12975 | 1 | — | — | — | — |
| Spearing Strike | — | 1310222 | 1 | — | — | — | — |
| Unbridled Wrath | — | 12964 | 1 | — | — | — | — |
| Weaponmaster | — | 12281 | 1 | — | — | — | — |
| Charge | 1 | 100 | 4 | — | 15 s | étourdi 1 s | génère 9/12/15 Rage (rangs 1/2/3) |
| Rend | 1 | 772 | 4 | 10 Rage | — | 9 s | saignement |
| Thunder Clap | 1 | 6343 | 6 | 20 Rage | 6 s | 10 s | ralentissement |
| Hamstring | 1 | 1715 | 8 | 10 Rage | — | 15 s | ralentissement |
| Heroic Strike | 2 | 284 | 8 | 15 Rage | — | — | — |
| Bloodrage | — | 2687 | 10 | 20 % PV de base | 1 min | 10 s | Rage sur 10 s |
| Defensive Stance | — | 71 | 10 | — | — | — | — |
| Defensive Stance Passive | — | 7376 | 10 | — | — | — | — |
| Rend | 2 | 6546 | 10 | 10 Rage | — | 12 s | saignement |
| Sunder Armor | 1 | 7386 | 10 | 15 Rage | — | 30 s | debuff cible |
| Taunt | — | 355 | 10 | — | 8 s | — | — |
| Battle Shout | 2 | 5242 | 12 | 10 Rage | — | 3 min | — |
| Overpower | 1 | 7384 | 12 | 5 Rage | 5 s | — | après esquive de la cible |
| Shield Bash | 1 | 72 | 12 | 10 Rage | 12 s | silence 6 s | interruption |
| Demoralizing Shout | 1 | 1160 | 14 | 10 Rage | — | 45 s | debuff cible |
| Revenge | 1 | 6572 | 14 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Tactical Mastery | — | 1310185 | 14 | — | — | passif | conserve jusqu'à 10 Rage au changement de posture |
| Heroic Strike | 3 | 285 | 16 | 15 Rage | — | — | — |
| Mocking Blow | 1 | 694 | 16 | 10 Rage | 2 min | taunt 6 s | — |
| Shield Block | — | 2565 | 16 | 10 Rage | 5 s | 7 s | — |
| Disarm | — | 676 | 18 | 20 Rage | 1 min | 10 s | — |
| Thunder Clap | 2 | 8198 | 18 | 20 Rage | 6 s | 14 s | ralentissement |
| Cleave | 1 | 845 | 20 | 20 Rage | — | — | — |
| Piercing Howl | — | 12323 | 20 | — | — | — | talent Fury, non détaillé par endgametools/wowforevertalents |
| Rend | 3 | 6547 | 20 | 10 Rage | — | 15 s | saignement |
| Retaliation | — | 20230 | 20 | — | 15 min | 15 s | — |
| Slam | 1 | 1240193 | 20 | 15 Rage | 18 s (endgametools / wowforevertalents) | — | incantation 1,5 s |
| Victory Rush | — | 402927 | 20 | — | 30 s | — | utilisable 20 s après un kill |
| Battle Shout | 3 | 6192 | 22 | 10 Rage | — | 3 min | — |
| Intimidating Shout | — | 5246 | 22 | 25 Rage | 3 min | peur 8 s | — |
| Sunder Armor | 2 | 7405 | 22 | 15 Rage | — | 30 s | debuff cible |
| Demoralizing Shout | 2 | 6190 | 24 | 10 Rage | — | 45 s | debuff cible |
| Execute | 1 | 5308 | 24 | 15 Rage | — | — | cible <= 20 % PV |
| Heroic Strike | 4 | 1608 | 24 | 15 Rage | — | — | — |
| Revenge | 2 | 6574 | 24 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Challenging Shout | — | 1161 | 26 | 5 Rage | 10 min | 6 s | — |
| Charge | 2 | 6178 | 26 | — | 15 s | étourdi 1 s | génère 9/12/15 Rage (rangs 1/2/3) |
| Mocking Blow | 2 | 7400 | 26 | 10 Rage | 2 min | taunt 6 s | — |
| Overpower | 2 | 7887 | 28 | 5 Rage | 5 s | — | après esquive de la cible |
| Shield Wall | — | 871 | 28 | — | 15 min | 12 s | — |
| Thunder Clap | 3 | 8204 | 28 | 20 Rage | 6 s | 18 s | ralentissement |
| Berserker Stance | — | 2458 | 30 | — | — | — | — |
| Berserker Stance Passive | — | 7381 | 30 | — | — | — | — |
| Cleave | 2 | 7369 | 30 | 20 Rage | — | — | — |
| Concussion Blow | — | 12809 | 30 | — | — | — | — |
| Intercept | 1 | 20252 | 30 | 10 Rage | 30 s | étourdi 3 s | — |
| Rend | 4 | 6548 | 30 | 10 Rage | — | 18 s | saignement |
| Slam | 2 | 1464 | 30 | 15 Rage | 18 s (endgametools / wowforevertalents) | — | incantation 1,5 s |
| Sweeping Strikes | — | 12292 | 30 | — | — | — | — |
| Battle Shout | 4 | 11549 | 32 | 10 Rage | — | 3 min | — |
| Berserker Rage | — | 18499 | 32 | — | 30 s | 10 s | — |
| Execute | 2 | 20658 | 32 | 15 Rage | — | — | cible <= 20 % PV |
| Hamstring | 2 | 7372 | 32 | 10 Rage | — | 15 s | ralentissement |
| Heroic Strike | 5 | 11564 | 32 | 15 Rage | — | — | — |
| Shield Bash | 2 | 1671 | 32 | 10 Rage | 12 s | silence 6 s | interruption |
| Demoralizing Shout | 3 | 11554 | 34 | 10 Rage | — | 45 s | debuff cible |
| Revenge | 3 | 7379 | 34 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Sunder Armor | 3 | 8380 | 34 | 15 Rage | — | 30 s | debuff cible |
| Mocking Blow | 3 | 7402 | 36 | 10 Rage | 2 min | taunt 6 s | — |
| Whirlwind | — | 1680 | 36 | 25 Rage | 10 s | — | jusqu'à 4 cibles |
| Pummel | 1 | 6552 | 38 | 10 Rage | 10 s | silence 4 s | interruption |
| Slam | 3 | 8820 | 38 | 15 Rage | 18 s (endgametools / wowforevertalents) | — | incantation 1,5 s |
| Thunder Clap | 4 | 8205 | 38 | 20 Rage | 6 s | 22 s | ralentissement |
| Bloodthirst | 1 | 23881 | 40 | 30 Rage | 6 s | 10 s (endgametools) | talent ; rang 1 = ID du talent |
| Cleave | 3 | 11608 | 40 | 20 Rage | — | — | — |
| Execute | 3 | 20660 | 40 | 15 Rage | — | — | cible <= 20 % PV |
| Heroic Strike | 6 | 11565 | 40 | 15 Rage | — | — | — |
| Mortal Strike | 1 | 12294 | 40 | 30 Rage | 6 s | 10 s (malus soins) | talent |
| Rend | 5 | 11572 | 40 | 10 Rage | — | 21 s | saignement |
| Shield Slam | 1 | 23922 | 40 | 20 Rage | 6 s | — | talent |
| Battle Shout | 5 | 11550 | 42 | 10 Rage | — | 3 min | — |
| Intercept | 2 | 20616 | 42 | 10 Rage | 30 s | étourdi 3 s | — |
| Demoralizing Shout | 4 | 11555 | 44 | 10 Rage | — | 45 s | debuff cible |
| Overpower | 3 | 11584 | 44 | 5 Rage | 5 s | — | après esquive de la cible |
| Revenge | 4 | 11600 | 44 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Charge | 3 | 11578 | 46 | 15 Rage (endgametools) | 15 s | étourdi 1 s | génère 9/12/15 Rage (rangs 1/2/3) |
| Mocking Blow | 4 | 20559 | 46 | 10 Rage | 2 min | taunt 6 s | — |
| Slam | 4 | 11604 | 46 | 15 Rage | 18 s (endgametools / wowforevertalents) | — | incantation 1,5 s |
| Sunder Armor | 4 | 11596 | 46 | 15 Rage | — | 30 s | debuff cible |
| Bloodthirst | 2 | 23892 | 48 | 30 Rage | 6 s | 10 s (endgametools) | talent ; rang 1 = ID du talent |
| Execute | 4 | 20661 | 48 | 15 Rage | — | — | cible <= 20 % PV |
| Heroic Strike | 7 | 11566 | 48 | 15 Rage | — | — | — |
| Mortal Strike | 2 | 21551 | 48 | 30 Rage | 6 s | 10 s (malus soins) | talent |
| Shield Slam | 2 | 23923 | 48 | 20 Rage | 6 s | — | talent |
| Thunder Clap | 5 | 11580 | 48 | 20 Rage | 6 s | 26 s | ralentissement |
| Cleave | 4 | 11609 | 50 | 20 Rage | — | — | — |
| Recklessness | — | 1719 | 50 | — | 30 min | 15 s | — |
| Rend | 6 | 11573 | 50 | 10 Rage | — | 21 s | saignement |
| Battle Shout | 6 | 11551 | 52 | 10 Rage | — | 3 min | — |
| Intercept | 3 | 20617 | 52 | 10 Rage | 30 s | étourdi 3 s | — |
| Shield Bash | 3 | 1672 | 52 | 10 Rage | 12 s | silence 6 s | interruption |
| Bloodthirst | 3 | 23893 | 54 | 30 Rage | 6 s | 10 s (endgametools) | talent ; rang 1 = ID du talent |
| Demoralizing Shout | 5 | 11556 | 54 | 10 Rage | — | 45 s | debuff cible |
| Hamstring | 3 | 7373 | 54 | 10 Rage | — | 15 s | ralentissement |
| Mortal Strike | 3 | 21552 | 54 | 30 Rage | 6 s | 10 s (malus soins) | talent |
| Revenge | 5 | 11601 | 54 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Shield Slam | 3 | 23924 | 54 | 20 Rage | 6 s | — | talent |
| Slam | 5 | 11605 | 54 | 15 Rage | 18 s (endgametools / wowforevertalents) | — | incantation 1,5 s |
| Execute | 5 | 20662 | 56 | 15 Rage | — | — | cible <= 20 % PV |
| Heroic Strike | 8 | 11567 | 56 | 15 Rage | — | — | — |
| Mocking Blow | 5 | 20560 | 56 | 10 Rage | 2 min | taunt 6 s | — |
| Pummel | 2 | 6554 | 58 | 10 Rage | 10 s | silence 4 s | interruption |
| Sunder Armor | 5 | 11597 | 58 | 15 Rage | — | 30 s | debuff cible |
| Thunder Clap | 6 | 11581 | 58 | 20 Rage | 6 s | 30 s | ralentissement |
| Battle Shout | 7 | 25289 | 60 | 10 Rage | — | 3 min | — |
| Bloodthirst | 4 | 23894 | 60 | 30 Rage | 6 s | 10 s (endgametools) | talent ; rang 1 = ID du talent |
| Cleave | 5 | 20569 | 60 | 20 Rage | — | — | — |
| Heroic Strike | 9 | 25286 | 60 | 15 Rage | — | — | — |
| Mortal Strike | 4 | 21553 | 60 | 30 Rage | 6 s | 10 s (malus soins) | talent |
| Overpower | 4 | 11585 | 60 | 5 Rage | 5 s | — | après esquive de la cible |
| Rend | 7 | 11574 | 60 | 10 Rage | — | 21 s | saignement |
| Revenge | 6 | 25288 | 60 | 5 Rage | 5 s | — | après blocage/esquive/parade |
| Shield Slam | 4 | 23925 | 60 | 20 Rage | 6 s | — | talent |

## Talents

Source : wow-forever.gg pour les noms et rangs max, DB2 Talent (build 1.60.1.70245) pour les IDs de rang, dans l'ordre rang 1 à N. Rangs = nombre de rangs max. Les écarts avec le DB2 sont listés dans « Points non vérifiés ».

### Arms
| Nom | Rangs (max) : IDs | Effet court |
|---|---|---|
| Improved Heroic Strike | 3 : 12282, 12663, 12664 | non détaillé |
| Deflection | 5 : 16462, 16463, 16464, 16465, 16466 | non détaillé |
| Improved Rend | 3 : 12286, 12658, 12659 | non détaillé |
| Improved Charge | 2 : 12285, 12697 | non détaillé |
| Improved Tactical Mastery | 5 : 12295, 12676, 12677, 12678, 12679 | non détaillé |
| Improved Overpower | 2 : 12290, 12963 | non détaillé |
| Anger Management | 1 : 12296 | non détaillé |
| Deep Wounds | 3 : 12834, 12849, 12867 | saignement sur critique (20/40/60 % selon une section de la page, 20 % selon une autre) |
| Spearing Strike | 1 : 1310222 (absent de Talent.csv, présent en sort Arms) | nouveau Forever |
| Two-Handed Weapon Specialization | DB2 : 5 : 12163, 12711, 12712, 12713, 12714 (source : 3) | non détaillé |
| Impale | 2 : 16493, 16494 | non détaillé |
| Bloodthrill | 5 : 1289682 (absent de Talent.csv ; SpellName : Bloodthrill) | proc d'Overpower |
| Sweeping Strikes | 1 : 12292 | durée 20 s (Wowhead Forever) ; aura factice gérée côté serveur |
| Weaponmaster | 5 : 1290261 (absent de Talent.csv). Candidats DB2, 3 talents homonymes Arms, non tranché : TabID 161, colonne/rangée 0/4 : 12700, 12781, 12783, 12784, 12785 ; TabID 161, 2/4 : 12284, 12701, 12702, 12703, 12704 ; TabID 161, 3/4 : 12281, 12812, 12813, 12814, 12815 | non détaillé (12281 « Weaponmaster » apparaît aussi dans la liste de sorts, niveau 1) |
| Improved Slam | DB2 : Fury (TabID 164, 0/4), 5 : 12862, 12330, 20497, 20498, 20499 (source : Arms, 2) | non détaillé |
| Improved Hamstring | 3 : 12289, 12668, 23695 | non détaillé |
| Mortal Strike | 1 : 12294 | talent 30 points ; rangs 2-4 : 21551 / 21552 / 21553 (confirmés par SkillLineAbility « Remplace ») |
| Improved Thunder Clap | DB2 : Arms (TabID 161, 3/1), 3 : 12287, 12665, 12666 (source : listé en Protection) | non détaillé |

### Fury
| Nom | Rangs (max) : IDs | Effet court |
|---|---|---|
| Booming Voice | 5 : 12321, 12835, 12836, 12837, 12838 | non détaillé |
| Cruelty | 5 : 12320, 12852, 12853, 12855, 12856 | non détaillé |
| Iron Will | DB2 : Protection (TabID 163, 3/1), 5 : 12300, 12959, 12960, 12961, 12962 (source : Fury, ID 12962) | non détaillé (wowforevertalents : déplacé vers Protection ; wow-forever.gg le liste en Fury ; le DB2 le place en Protection) |
| Unbridled Wrath | 5 : 12322, 12999, 13000, 13001, 13002 | non détaillé (12322 déclenche 12964 « Unbridled Wrath », voir section Sorts déclenchés) |
| Improved Cleave | 3 : 12329, 12950, 20496 | wowforevertalents : retiré (hotfix) |
| Piercing Howl | 1 : 12323 | |
| Blood Craze | 3 : 16487, 16489, 16492 | non détaillé |
| Boundless Rage | 3 : 1310236 (absent de Talent.csv ; SpellName : Boundless Rage) | wowforevertalents : retiré (hotfix) |
| Dual Wield Specialization | 5 : 23584, 23585, 23586, 23587, 23588 | non détaillé |
| Raging Blows | 1 : 1310315 (absent de Talent.csv ; SpellName : Raging Blows) | non détaillé |
| Enrage | 5 : 12317, 13045, 13046, 13047, 13048 | proc 30 % ; bonus 2/4/6/8/10 % |
| Improved Execute | 2 : 20502, 20503 | non détaillé |
| Precision | 3 : 1225295 (absent de Talent.csv ; SpellName : Precision) | wowforevertalents : retiré (hotfix) |
| Death Wish | 1 : 12328 | actif, 30 s |
| Improved Intercept | 2 : 20504, 20505 | non détaillé |
| Improved Berserker Rage | 2 : 20500, 20501 | non détaillé |
| Flurry | 5 : 12319, 12971, 12972, 12973, 12974 | vitesse d'attaque 5/10/15/20/25 % après critique |
| Bloodthirst | 1 : 23881 | talent 30 points ; rangs 2-4 : 23892 / 23893 / 23894 (confirmés par SkillLineAbility « Remplace ») |

### Protection
| Nom | Rangs (max) : IDs | Effet court |
|---|---|---|
| Shield Specialization | 5 : 12298, 12724, 12725, 12726, 12727 | Rage sur blocage (12298 déclenche 1310318 « Shield Specialization ») |
| Anticipation | 5 : 12297, 12750, 12751, 12752, 12753 | non détaillé |
| Improved Bloodrage | 2 : 12301, 12818 | non détaillé |
| Toughness | 5 : 12299, 12761, 12762, 12763, 12764 | wowforevertalents : retiré (hotfix) |
| Last Stand | 1 : 12975 | actif |
| Master of Defense | 2 : 1310316 (absent de Talent.csv ; SpellName : Master of Defense) | Rage sur esquive/parade |
| Improved Revenge | 3 : 12797, 12799, 12800 | non détaillé |
| Defiance | DB2 : 5 : 12303, 12788, 12789, 12791, 12792 (source : 3, ID 12792) | non détaillé |
| Improved Sunder Armor | 3 : 12308, 12810, 12811 | non détaillé |
| Improved Disarm | 3 : 12313, 12804, 12807 | non détaillé |
| Vanguard | 1 : 1310317 (absent de Talent.csv ; SpellName : Vanguard) | non détaillé |
| Improved Shield Wall | 2 : 12312, 12803 | non détaillé |
| Concussion Blow | 1 : 12809 | actif |
| Improved Shield Bash | 2 : 12311, 12958 | non détaillé |
| Bastion | 5 : 16538, 16539, 16540, 16541, 16542 | non détaillé |
| Focused Rage | 3 : 29787 (absent de Talent.csv ; SpellName : Focused Rage) | non détaillé |
| Shield Slam | 1 : 23922 | talent 30 points ; rangs 2-4 : 23923 / 23924 / 23925 (confirmés par SkillLineAbility « Remplace ») |

Ajouts Fury/Protection cités par wowforevertalents (Lingering Rage, Furious Precision, Gore Drinker) : non trouvé (absent du DB2 70245).

Talents présents dans le DB2 mais absents de ce fichier (source wow-forever.gg), avec TabID, colonne/rangée et IDs de rang 1..N :
- Arms (161) 0/5, nom « ? » dans le DB2 : 12165, 12830, 12831, 12832, 12833.
- Protection (163) Improved Shield Block, 1/2 : 12945, 12307, 12944.
- Protection (163) Improved Taunt, 2/3 : 12302, 12765.
- Fury (164) Improved Demoralizing Shout, 1/1 : 12324, 12876, 12877, 12878, 12879.
- Fury (164) Improved Battle Shout, 3/2 : 12318, 12857, 12858, 12860, 12861.

## Buffs, debuffs et procs à suivre en WeakAuras

Les IDs d'aura viennent du DB2 : section « Sorts déclenchés » (source → déclenché) et colonne aura de SkillLineAbility (« oui » = le sort applique lui-même l'aura, l'ID d'aura est alors celui du sort). Enrage et Flurry : le DB2 ne donne aucun sort déclenché (effets d'aura factice, script serveur). À récupérer en jeu (`/dump C_UnitAuras` ou `AuraUtil` sur le buff réel) avant d'écrire la WeakAura.

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Enrage (buff après coup reçu) | aucun sort déclenché par 12317 dans SpellEffect (talent : 12317, 13045, 13046, 13047, 13048 ; 12317 = effet aura factice). Candidats par nom exact « Enrage » (SpellName, non liés, non tranché) : 1640, 3019, 5229, 8269, 8599, 12317, 12686, 12795, 12880, 15061, 15097, 15716, 18501, 19516, 19953, 23537, 24318, 25503, 26527, 27897, 28131, 28468, 28747, 28798, 425415, 427066, 440483, 446327, 460862, 461347, 461348, 461349, 462885, 1223458, 1284435, 1288972, 1303979, 1323289 ; parmi eux 12880 porte l'aura 79 (SpellEffect) | proc | wow-forever.gg ; Wowhead : passif caché, proc 30 % |
| Flurry (buff de vitesse) | aucun sort déclenché par 12319 dans SpellEffect (talent : 12319 ; effet aura factice). Candidats par nom exact « Flurry » (non liés, non tranché) : 12319 (talent), 12966 (SkillLineAbility Fury, aura oui, aura 319 en SpellEffect), 15088, 16256, 16257, 17687 (17687 déclenché par 15088, hors Guerrier) | proc | wow-forever.gg ; Wowhead : passif caché |
| Overpower disponible | pas d'aura attendue : utiliser l'utilisabilité du sort 7384 / 7887 / 11584 / 11585 | proc | wow-forever.gg |
| Revenge disponible | idem : 6572 / 6574 / 7379 / 11600 / 11601 / 25288 | proc | wow-forever.gg |
| Execute disponible | idem (cible <= 20 % PV) : 5308 / 20658 / 20660 / 20661 / 20662 | proc | wow-forever.gg |
| Victory Rush disponible | usable 20 s après un kill ; ID du sort 402927 ; aura : aucune pour 402927 (SpellEffect sans effet d'aura ni sort déclenché) ; homonyme « Victory Rush » 403434, lien non établi | proc | wow-forever.gg, endgametools |
| Death Wish | 12328 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Battle Shout | IDs des rangs (voir tableau, 6673 à 25289) ; aura = sort lancé (colonne aura oui) | buff de groupe | wow-forever.gg |
| Berserker Rage | 18499 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Bloodrage | 29131 (déclenché par 2687, aura oui) | buff joueur | wow-forever.gg |
| Recklessness | 1719 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Shield Wall | 871 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Shield Block | 2565 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Last Stand | 12976 (SkillLineAbility Protection, aura oui, même nom ; 12975 = sort lancé sans aura ; lien non établi par SpellEffect) | buff joueur | wow-forever.gg |
| Retaliation | 20230 (aura = sort lancé, colonne aura oui) | buff joueur | wow-forever.gg |
| Sweeping Strikes | 12292 (aura = sort, colonne aura oui ; 12723 « Sweeping Strikes » sans aura aussi présent) | buff joueur | Wowhead Forever (20 s) |
| Rend | IDs de rang du tableau (772 à 11574) ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg |
| Sunder Armor | 7386, 7405, 8380, 11596, 11597 ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg |
| Thunder Clap | 6343 à 11581 ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg |
| Demoralizing Shout | 1160 à 11556 ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg |
| Hamstring | 1715, 7372, 7373 ; aura = sort lancé (colonne aura oui) ; Improved Hamstring 12289 déclenche 23694 (aura) | debuff cible | wow-forever.gg |
| Mortal Strike (malus soins) | 12294, 21551, 21552, 21553 ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg, endgametools |
| Deep Wounds | 12162 (déclenché par 12834) | debuff cible | wow-forever.gg |
| Disarm, Mocking Blow, Concussion Blow | IDs de sort du tableau ; aura = sort lancé (colonne aura oui) | debuff cible | wow-forever.gg |
| Intimidating Shout | 20511 (déclenché par 5246, aura oui) | debuff cible | wow-forever.gg |
| Shield Bash (silence), Pummel (silence) | aucun effet d'aura ni sort déclenché pour 72, 1671, 1672, 6552, 6554 (SpellEffect). Homonymes exacts, liens non établis : « Silenced » 1852, 18498 ; « Shield Bash » 11972 ; « Pummel » 12555, 13491, 15615, 19639, 19640. Talents : Improved Shield Bash 12311 déclenche 18498 « Silenced » ; Improved Pummel 12288, 12707, 12708 déclenchent 12705 « Long Daze » | debuff cible | wow-forever.gg |
| Charge (étourdissement) | 7922 (déclenché par 100, 6178, 11578, aura oui) | debuff cible | wow-forever.gg |
| Intercept (étourdissement) | 20253 (rang 1, source 20252), 20614 (rang 2, source 20616), 20615 (rang 3, source 20617) | debuff cible | wow-forever.gg |
| Execute | 26651 (déclenché par 5308, 20658, 20660, 20661, 20662, aura oui) | aura déclenchée (type non vérifié) | DB2 |
| Blood Craze | 16488 (déclenché par 16487, aura oui) | aura déclenchée (type non vérifié) | DB2 |
| Unbridled Wrath | 12964 (déclenché par 12322) | aura déclenchée (type non vérifié) | DB2 |

## Points non vérifiés

- Le DB2 (Talent, SkillLineAbility, SpellEffect, SpellName ; build 1.60.1.70245) contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- Auras : seules celles du DB2 (sorts déclenchés, colonne aura) sont renseignées. Enrage et Flurry (buff), Shield Bash/Pummel (silence) et Victory Rush : aucun lien SpellEffect vers une aura, homonymes listés sans choix. Lingering Rage, Furious Precision, Gore Drinker : absents de SpellName (comparaison exacte). Type buff/debuff des auras déclenchées Execute, Blood Craze, Unbridled Wrath : non vérifié.
- IDs des rangs 2 à N de chaque talent : fournis par Talent.csv du DB2 pour les talents présents ; les talents absents de Talent.csv n'ont que l'ID de la source.

### Écarts avec le DB2 client

- Weaponmaster : 1290261 (source) absent de Talent.csv (SpellName : « Weaponmaster »). Le DB2 a 3 talents Arms homonymes (TabID 161, 0/4 rang 1 12700 ; 2/4 rang 1 12284 ; 3/4 rang 1 12281), non tranché.
- Absents de Talent.csv, IDs de la source conservés (le nom existe dans SpellName) : Bloodthrill 1289682, Boundless Rage 1310236, Raging Blows 1310315, Precision 1225295, Master of Defense 1310316, Vanguard 1310317, Focused Rage 29787.
- Spearing Strike 1310222 : présent en sort Arms (SkillLineAbility), pas dans Talent.csv.
- Iron Will : ID source 12962 = rang 5 en DB2 (rang 1 = 12300) ; talent en Protection (TabID 163, 3/1), pas en Fury.
- Defiance : ID source 12792 = rang 5 en DB2 (rang 1 = 12303) ; 5 rangs en DB2, 3 dans la source.
- Improved Thunder Clap : DB2 en Arms (TabID 161), source en Protection.
- Improved Slam : DB2 en Fury (TabID 164, 0/4) avec 5 rangs ; source en Arms avec 2 rangs.
- Two-Handed Weapon Specialization : 5 rangs en DB2, 3 dans la source.
- Wowhead Forever : liste filtrée par classe inaccessible (formulaire sans résultats) ; recoupement des IDs avec Wowhead non fait. endgametools et wowforevertalents ne publient aucun spell ID : IDs d'une seule source (wow-forever.gg).
- Divergences de niveau : endgametools affiche des niveaux incohérents (valeurs à 3 chiffres) ; niveaux retenus = wow-forever.gg, cohérents avec wowforevertalents (ex. Charge 4/26/46, Hamstring 8/32/54).
- Divergences de contenu : Slam rang 1 = ID 1240193 (niveau 20), Tactical Mastery 1310185, Victory Rush 402927, Spearing Strike 1310222, Raging Blows 1310315 : IDs hors plage Classic Era (nouveautés Forever). Weaponmaster (1290261 talent vs 12281 sort) : non tranché, voir « Écarts avec le DB2 client ». Unbridled Wrath : 12322 = talent (DB2), 12964 = sort déclenché par 12322.
- Talents retirés/ajoutés par hotfix serveur (wowforevertalents : retirés Improved Cleave, Precision, Boundless Rage, Toughness ; ajoutés Lingering Rage, Furious Precision, Gore Drinker ; Iron Will déplacé en Protection) mais encore listés par wow-forever.gg : état réel en jeu non vérifié.
- Charge rang 3 : coût 15 Rage selon endgametools seul ; Slam recharge 18 s indiquée par les deux sources de coûts (valeur inhabituelle, non recoupée avec Wowhead).
- Coûts non listés (—) pour stances, Bloodrage (20 % PV de base selon wowforevertalents), Victory Rush, Retaliation, Recklessness, Shield Wall, Berserker Rage, Taunt.
- Piercing Howl, Death Wish, Last Stand, Concussion Blow, Sweeping Strikes : coût/recharge non listés par endgametools ou wowforevertalents.
- Passifs « Stance Passive » : rôle non vérifié.

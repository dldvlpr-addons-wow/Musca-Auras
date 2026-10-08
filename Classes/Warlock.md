# Démoniste — WoW Forever 1.60.1

Date : 2026-10-08. Build lu : 1.60.1.70245 (wow-forever.gg, wowforevertalents.com, endgametools.com ; foreverchanges.pro mentionne 70245 aussi).

Sources :
- **DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName)** : fait foi. Le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu.
- **IDs** : wow-forever.gg `/db/spells/browse/class/warlock/` (171 entrées, une page). Aucune autre source lue n'affiche d'ID (endgametools, foreverchanges, wowforevertalents : zéro ID, sauf Corruption r7 = 25311 sur foreverchanges). Wowhead Forever : listes filtrées vides (filtres JS), mais pages `spell=ID` lisibles (utilisées pour vérifier les auras).
- **Niveau / coût / recharge / durée** : wowforevertalents.com/abilities/warlock/ (niveaux par rang), recoupé avec endgametools (coûts identiques). Les niveaux d'endgametools sont illisibles (valeurs x10, ex. « 105 » = 10) : ignorés.
- Coût : mana, sauf mention. « base » = % du mana de base. Recharge « — » = aucune.

## Sorts de base (entraîneur)

Les rangs sans niveau lu sont marqués « ? ».

### Affliction / malédictions

| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Corruption | 1 | 172 | 4 | 35 | — | 12 s | cast 2 s |
| Corruption | 2 | 6222 | 14 | 55 | — | 15 s | |
| Corruption | 3 | 6223 | 24 | 100 | — | 18 s | |
| Corruption | 4 | 7648 | 34 | 160 | — | 18 s | |
| Corruption | 5 | 11671 | 44 | 225 | — | 18 s | |
| Corruption | 6 | 11672 | 54 | 290 | — | 18 s | |
| Corruption | 7 | 25311 | 60 | 340 | — | 18 s | confirmé aussi par foreverchanges |
| Curse of Weakness | 1 | 702 | 4 | 20 | — | 2 min | |
| Curse of Weakness | 2 | 1108 | 12 | 35 | — | 2 min | |
| Curse of Weakness | 3 | 6205 | 22 | 70 | — | 2 min | |
| Curse of Weakness | 4 | 7646 | 32 | 95 | — | 2 min | |
| Curse of Weakness | 5 | 11707 | 42 | 130 | — | 2 min | |
| Curse of Weakness | 6 | 11708 | 52 | 175 | — | 2 min | |
| Life Tap | 1 | 1454 | 6 | santé | — | — | convertit santé en mana |
| Life Tap | 2 | 1455 | 16 | santé | — | — | |
| Life Tap | 3 | 1456 | 26 | santé | — | — | |
| Life Tap | 4 | 11687 | 36 | santé | — | — | |
| Life Tap | 5 | 11688 | 46 | santé | — | — | |
| Life Tap | 6 | 11689 | 56 | santé | — | — | 424 + Esprit selon wowforevertalents |
| Bane of Agony | 1 | 980 | 8 | 25 | — | 24 s | ex-Curse of Agony |
| Bane of Agony | 2 | 1014 | 18 | 50 | — | 24 s | |
| Bane of Agony | 3 | 6217 | 28 | 90 | — | 24 s | |
| Bane of Agony | 4 | 11711 | 38 | 130 | — | 24 s | |
| Bane of Agony | 5 | 11712 | 48 | 170 | — | 24 s | |
| Bane of Agony | 6 | 11713 | 58 | 215 | — | 24 s | |
| Bane of Doom | — | 603 | 60 | 300 | 1 min | frappe après 1 min | ex-Curse of Doom |
| Bane of Doom Effect | — | 18662 | — | — | — | 15 s | invoque le Garde funeste (page Wowhead : buff, Summon Doomguard) |
| Fear | 1 | 5782 | 8 | 15% base | — | fuite 10 s | cast 1,5 s |
| Fear | 2 | 6213 | 32 | 15% base | — | 15 s | |
| Fear | 3 | 6215 | 56 | 15% base | — | 20 s | |
| Drain Soul | 1 | 1120 | 10 | 55 | — | 15 s (canalisé) | |
| Drain Soul | 2 | 8288 | 24 | 125 | — | 15 s | |
| Drain Soul | 3 | 8289 | 38 | 210 | — | 15 s | |
| Drain Soul | 4 | 11675 | 52 | 290 | — | 15 s | |
| Curse of Recklessness | 1 | 704 | 14 | 35 | — | 2 min | |
| Curse of Recklessness | 2 | 7658 | 28 | 60 | — | 2 min | |
| Curse of Recklessness | 3 | 7659 | 42 | 90 | — | 2 min | |
| Curse of Recklessness | 4 | 11717 | 56 | 115 | — | 2 min | |
| Drain Life | 1 | 689 | 14 | 55 | — | 5 s | |
| Drain Life | 2 | 699 | 22 | 85 | — | 5 s | |
| Drain Life | 3 | 709 | 30 | 135 | — | 5 s | |
| Drain Life | 4 | 7651 | 38 | 185 | — | 5 s | |
| Drain Life | 5 | 11699 | 46 | 240 | — | 5 s | |
| Drain Life | 6 | 11700 | 54 | 300 | — | 5 s | |
| Curse of the Elements | 1 | 440892 | 20 | 50 | — | 5 min | |
| Curse of the Elements | 2 | 1311676 | 30 | 100 | — | 5 min | |
| Curse of the Elements | 3 | 1311677 | 40 | 150 | — | 5 min | |
| Curse of the Elements | 4 | 1311680 | 50 | 200 | — | 5 min | |
| Drain Mana | 1 | 5138 | 24 | 95 | — | 5 s | |
| Drain Mana | 2 | 6226 | 34 | 155 | — | 5 s | |
| Drain Mana | 3 | 11703 | 44 | 225 | — | 5 s | |
| Drain Mana | 4 | 11704 | 54 | 310 | — | 5 s | |
| Curse of Tongues | 1 | 1714 | 26 | 80 | — | 30 s | |
| Curse of Tongues | 2 | 11719 | 50 | 110 | — | 30 s | |
| Siphon Life | 1 | 18265 | 38 | talent | — | 30 s | rangs 2-4 : coût 205 / 285 / 365 |
| Siphon Life | 2 | 18879 | 38 | 205 | — | 30 s | niveau 38 sur wowforevertalents (à vérifier) |
| Siphon Life | 3 | 18880 | 48 | 285 | — | 30 s | |
| Siphon Life | 4 | 18881 | 58 | 365 | — | 30 s | |
| Howl of Terror | 1 | 5484 | 40 | 150 | 40 s | fuite 10 s | cast 2 s |
| Howl of Terror | 2 | 17928 | 54 | 200 | 40 s | 15 s | |
| Death Coil | 1 | 6789 | 42 | 435 | 2 min | horreur 3 s | |
| Death Coil | 2 | 17925 | 50 | 525 | 2 min | 3 s | |
| Death Coil | 3 | 17926 | 58 | 600 | 2 min | 3 s | |
| Wrack | 1 | 1316697 | talent | ? | ? | 6 s | talent, nouveau Forever |

### Destruction

| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Shadow Bolt | 1 | 686 | 1 | 25 | — | — | cast 1,7 s |
| Shadow Bolt | 2 | 695 | 6 | 40 | — | — | |
| Shadow Bolt | 3 | 705 | 12 | 70 | — | — | |
| Shadow Bolt | 4 | 1088 | 20 | 110 | — | — | |
| Shadow Bolt | 5 | 1106 | 28 | 160 | — | — | |
| Shadow Bolt | 6 | 7641 | 36 | 210 | — | — | |
| Shadow Bolt | 7 | 11659 | 44 | 265 | — | — | |
| Shadow Bolt | 8 | 11660 | 52 | 315 | — | — | |
| Shadow Bolt | 9 | 11661 | 60 | 370 | — | — | |
| Shadow Bolt | 10 | 25307 | 60 | 380 | — | — | |
| Immolate | 1 | 348 | 1 | 25 | — | 15 s | cast 2 s |
| Immolate | 2 | 707 | 10 | 45 | — | 15 s | |
| Immolate | 3 | 1094 | 20 | 90 | — | 15 s | |
| Immolate | 4 | 2941 | 30 | 155 | — | 15 s | |
| Immolate | 5 | 11665 | 40 | 220 | — | 15 s | |
| Immolate | 6 | 11667 | 50 | 295 | — | 15 s | |
| Immolate | 7 | 11668 | 60 | 370 | — | 15 s | |
| Immolate | 8 | 25309 | 60 | 380 | — | 15 s | |
| Searing Pain | 1 | 5676 | 18 | 45 | — | — | cast 1,5 s |
| Searing Pain | 2 | 17919 | 26 | 68 | — | — | |
| Searing Pain | 3 | 17920 | 34 | 91 | — | — | |
| Searing Pain | 4 | 17921 | 42 | 118 | — | — | |
| Searing Pain | 5 | 17922 | 50 | 141 | — | — | |
| Searing Pain | 6 | 17923 | 58 | 168 | — | — | |
| Rain of Fire | 1 | 5740 | 20 | 295 | — | 8 s | |
| Rain of Fire | 2 | 6219 | 34 | 605 | — | 8 s | |
| Rain of Fire | 3 | 11677 | 46 | 885 | — | 8 s | |
| Rain of Fire | 4 | 11678 | 58 | 1185 | — | 8 s | |
| Shadowburn | 1 | 17877 | talent | ? | 15 s | — | + Soul Shard |
| Shadowburn | 2 | 18867 | 24 | 130 | 15 s | — | |
| Shadowburn | 3 | 18868 | 32 | 190 | 15 s | — | |
| Shadowburn | 4 | 18869 | 40 | 245 | 15 s | — | |
| Shadowburn | 5 | 18870 | 48 | 305 | 15 s | — | |
| Shadowburn | 6 | 18871 | 56 | 365 | 15 s | — | |
| Hellfire | 1 | 1949 | 30 | 645 | — | 15 s | |
| Hellfire | 2 | 11683 | 42 | 975 | — | 15 s | |
| Hellfire | 3 | 11684 | 54 | 1300 | — | 15 s | |
| Conflagrate | 1 | 1293817 | talent | ? | 10 s | — | |
| Conflagrate | 2 | 1293818 | 32 | 130 | 10 s | — | |
| Conflagrate | 3 | 17962 | ? | 165 (endgametools) | 10 s | — | wowforevertalents omet le rang 3 |
| Conflagrate | 4 | 18930 | 48 | 200 | 10 s | — | |
| Conflagrate | 5 | 18931 | 54 | 230 | 10 s | — | |
| Conflagrate | 6 | 18932 | 60 | 255 | 10 s | — | |
| Soul Fire | 1 | 6353 | 48 | 305 + Soul Shard | 1 min | — | cast 6 s |
| Soul Fire | 2 | 17924 | 56 | 335 + Soul Shard | 1 min | — | |
| Incinerate | 1 | 412758 | talent | ? | — | — | nouveau Forever |
| Incinerate | 2 | 1293812 | 50 | 265 | — | — | cast 2,5 s |
| Incinerate | 3 | 1293813 | 60 | 325 | — | — | |

### Démonologie : armures, pierres, invocations, utilitaires

| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Demon Skin | 1 | 687 | 1 | 50 | — | 30 min | |
| Demon Skin | 2 | 696 | 10 | 120 | — | 30 min | |
| Demon Armor | 1 | 706 | 20 | 275 | — | 30 min | |
| Demon Armor | 2 | 1086 | 30 | 520 | — | 30 min | |
| Demon Armor | 3 | 11733 | 40 | 800 | — | 30 min | |
| Demon Armor | 4 | 11734 | 50 | 1150 | — | 30 min | |
| Demon Armor | 5 | 11735 | 60 | 1580 | — | 30 min | |
| Summon Imp | — | 688 | 1 | 80% base | — | — | cast 10 s |
| Summon Voidwalker | — | 697 | 10 | 100% base + Soul Shard | — | — | |
| Summon Succubus | — | 712 | 20 | 100% base + Soul Shard | — | — | |
| Summon Incubus | — | 713 | 20 | 100% base + Soul Shard | — | — | présent dans le DB2 (Démonologie) ; absent de la liste Wowhead |
| Summon Felhunter | — | 691 | 30 | 100% base + Soul Shard | — | — | |
| Summon Felsteed | — | 5784 | 40 | — | — | — | DB2 : SkillLineAbility ligne Mounts (777), pas ligne Démonologie ; seul sort de ce nom exact |
| Summon Dreadsteed | — | 23161 | 60 | — | — | — | idem ; autres sorts proches (noms différents, non retenus) : 23152 Summon Xorothian Dreadsteed, 23159 Summon Dreadsteed Spirit (DND) |
| Inferno | — | 1122 | 50 | 100% base + Infernal Stone | 1 h | Infernal 5 min | |
| Ritual of Summoning | — | 698 | 20 | 300 + Soul Shard | — | — | |
| Ritual of Doom | — | 18540 | 60 | 100% base + Demonic Figurine | 1 h | — | |
| Portal of Summoning | — | 437169 | 60 | 12% base + Soul Shard | 2 min | — | marqué « pas encore vu en beta » |
| Eye of Kilrogg | — | 126 | 22 | 100 | — | — | |
| Sense Demons | — | 5500 | 24 | — | — | jusqu'à annulation | |
| Unending Breath | — | 5697 | 16 | 50 | — | 10 min | |
| Detect Invisibility | 1 | 132 | 26 | 50 | — | 10 min | |
| Detect Invisibility | 2 | 2970 | 38 | 90 | — | 10 min | |
| Detect Invisibility | 3 | 11743 | 50 | 140 | — | 10 min | |
| Banish | 1 | 710 | 28 | 100 | — | 20 s | cast 1,5 s |
| Banish | 2 | 18647 | 48 | 200 | — | 30 s | |
| Subjugate Demon | 1 | 1098 | 30 | 300 + Soul Shard | — | 5 min | |
| Subjugate Demon | 2 | 11725 | 44 | 500 + Soul Shard | — | 5 min | |
| Subjugate Demon | 3 | 11726 | 58 | 700 | — | 5 min | |
| Health Funnel | 1 | 755 | 12 | 11 santé + 5/s | — | 10 s | |
| Health Funnel | 2 | 3698 | 20 | 15 + 10/s | — | 10 s | |
| Health Funnel | 3 | 3699 | 28 | 24 + 17/s | — | 10 s | |
| Health Funnel | 4 | 3700 | 36 | 39 + 25/s | — | 10 s | |
| Health Funnel | 5 | 11693 | 44 | 45 + 35/s | — | 10 s | |
| Health Funnel | 6 | 11694 | 52 | 62 + 47/s | — | 10 s | |
| Health Funnel | 7 | 11695 | 60 | 79 + 61/s | — | 10 s | |
| Shadow Ward | 1 | 6229 | 32 | 135 | 30 s | 30 s | |
| Shadow Ward | 2 | 11739 | 42 | 195 | 30 s | 30 s | |
| Shadow Ward | 3 | 11740 | 52 | 255 | 30 s | 30 s | |
| Shadow Ward | 4 | 28610 | 60 | 320 | 30 s | 30 s | |

### Pierres (création)

| Nom | Rang | Spell ID | Niveau | Coût | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Create Healthstone | 1 | 6201 | 10 | 95 + Soul Shard | — | — | cast 3 s |
| Create Healthstone | 2 | 6202 | 22 | 240 + Soul Shard | — | — | |
| Create Healthstone | 3 | 5699 | 34 | 475 + Soul Shard | — | — | |
| Create Healthstone | 4 | 11729 | 46 | 750 + Soul Shard | — | — | |
| Create Healthstone | 5 | 11730 | 58 | 1120 + Soul Shard | — | — | |
| Create Soulstone | 1 | 693 | 18 | 85% base + Soul Shard | — | — | |
| Create Soulstone | 2 | 20752 | 30 | idem | — | — | |
| Create Soulstone | 3 | 20755 | 40 | idem | — | — | |
| Create Soulstone | 4 | 20756 | 50 | idem | — | — | |
| Create Soulstone | 5 | 20757 | 60 | idem | — | — | |
| Create Firestone | 1 | 6366 | 28 | 500 + Soul Shard | — | — | |
| Create Firestone | 2 | 17951 | 36 | 700 + Soul Shard | — | — | |
| Create Firestone | 3 | 17952 | 46 | 900 + Soul Shard | — | — | |
| Create Firestone | 4 | 17953 | 56 | 1100 + Soul Shard | — | — | |
| Create Spellstone | 1 | 2362 | 36 | 500 + Soul Shard | — | — | cast 5 s |
| Create Spellstone | 2 | 17727 | 48 | 750 + Soul Shard | — | — | |
| Create Spellstone | 3 | 17728 | 60 | 1000 + Soul Shard | — | — | |

## Sorts des familiers

Source : DB2 SkillLineAbility, lignes « Pet - ». Rangs dans l'ordre de la chaîne « Remplace » du DB2. Les sorts « Effect » et les auras déclenchées sont séparés (SpellEffect, section Sorts déclenchés).

| Familier | Sort | Rang | Spell ID | Notes |
|---|---|---|---|---|
| Imp | Firebolt | 1-7 | 3110, 7799, 7800, 7801, 7802, 11762, 11763 | |
| Imp | Blood Pact | 1-5 | 6307, 7804, 7805, 11766, 11767 | aura |
| Imp | Fire Shield | 1-5 | 2947, 8316, 8317, 11770, 11771 | aura |
| Imp | Phase Shift | — | 4511 | aura |
| Voidwalker | Torment | 1-6 | 3716, 7809, 7810, 7811, 11774, 11775 | |
| Voidwalker | Sacrifice | 1-6 | 7812, 19438, 19440, 19441, 19442, 19443 | aura |
| Voidwalker | Suffering | 1-4 | 17735, 17750, 17751, 17752 | |
| Voidwalker | Consume Shadows | 1-6 | 17767, 17850, 17851, 17852, 17853, 17854 | aura |
| Succubus | Lash of Pain | 1-6 | 7814, 7815, 7816, 11778, 11779, 11780 | |
| Succubus | Seduction | — | 6358 | aura |
| Succubus | Soothing Kiss | 1-4 | 6360, 7813, 11784, 11785 | |
| Succubus | Lesser Invisibility | — | 7870 | aura |
| Felhunter | Devour Magic | 1-4 | 19505, 19731, 19734, 19736 | effets : 19658, 19732, 19733, 19735 (Devour Magic Effect) |
| Felhunter | Spell Lock | 1-2 | 19244, 19647 | déclenche l'aura 24259 |
| Felhunter | Paranoia | — | 19480 | aura |
| Felhunter | Tainted Blood | 1-4 | 19478, 19655, 19656, 19660 | auras déclenchées (Tainted Blood Effect) : 19479, 19652, 19653, 19654 |
| Felguard | Anguish | — | 427742 | |
| Felguard | Avoidance | — | 427743 | aura |
| Felguard | Cleave | — | 427744 | |
| Felguard | Intercept | — | 427745 | déclenche Intercept Stun 427746 (aura) |
| Doomguard, Infernal | aucune capacité | — | — | seulement les passifs ci-dessous |
| Tous | Warlock Pet Scaling | — | 416189 | aura |
| Tous | Tamed Pet Passive (DND) | — | 412729 | aura ; passifs par famille : Imp 18728, 18737, 18740 ; Voidwalker et Felguard 18727, 18735, 18742 ; Succubus 18729, 18736, 18741 ; Felhunter 18730, 18738, 18739, 19007 |

Sorts d'invocation des familiers : voir tableau Démonologie (688, 697, 712, 691).

## Talents

IDs de rang : DB2 Talent.csv (tous les rangs, dans l'ordre). Talents absents de Talent.csv (ajouts serveur) : ID SpellName par nom exact ; plusieurs candidats = tous listés, aucun choisi. Présence dans le DB2 ≠ actif en jeu. Rangs max et effets : wow-forever.gg/talents/warlock/ (52 talents, dont 18 nouveaux vs Era).

### Affliction (17)
| Talent | Rangs | IDs | Effet court |
|---|---|---|---|
| Improved Life Tap | 2 | 18182, 18183 | +10/20% mana du Life Tap |
| Suppression | 5 | 18174, 18175, 18176, 18177, 18178 | +1-5% toucher, -4-20% menace |
| Improved Corruption | 5 | 17810, 17811, 17812, 17813, 17814 | -0,4 à -2 s d'incantation, +2-10% dégâts |
| Malediction | 5 | 1225177 (SpellName seul ; absent de Talent) | +1-5% dégâts périodiques |
| Soul Harvest | 2 | candidats SpellName, absents de Talent : 437032, 1242853 | +50/100% régén. mana après kill drainé |
| Improved Drains | 3 | 403511 (SpellName seul ; absent de Talent) | +7/13/20% dégâts Drain et Wrack |
| Improved Bane of Agony | 2 | 18827, 18829, 18830 | +5/10% dégâts |
| Fel Concentration | 3 | 17783, 17784, 17785, 17786, 17787 | 23/47/70% anti-interruption |
| Amplify Curse | 1 | 18288 | +50% prochain Weakness/Agony |
| Pandemic | 3 | candidats SpellName, absents de Talent : 427712, 429283 | +33/67/100% bonus crit DoTs |
| Malevolence | 5 | candidats SpellName, absents de Talent : 449919, 449920, 1310949 | +1-5% crit Ombre |
| Nightfall | 2 | 18094, 18095 | 2/4% Shadow Trance (Corruption, Drain Life) |
| Curse of Exhaustion | 1 | 18223 | -30% vitesse 12 s |
| Siphon Life | 1 | 18265 | 11 PV/3 s pendant 30 s |
| Soul Siphon | 3 | 17804, 17805, 17806, 17807, 17808 | +4/8/12% par effet Affliction (max 12/24/36%) |
| Shadow Mastery | 5 | 18271, 18272, 18273, 18274, 18275 | +1-5% dégâts Ombre |
| Wrack | 1 | 1316697 (SkillLineAbility ; absent de Talent) | 36 dégâts Ombre/s, requiert Siphon Life |

### Démonologie (19)
| Talent | Rangs | IDs | Effet court |
|---|---|---|---|
| Improved Health Funnel | 2 | 18703, 18704 | +20/40% soins, -15/30% coût |
| Improved Imp | 3 | 18694, 18695, 18696 | +10/20/30% Firebolt, Fire Shield |
| Demonic Embrace | 5 | 18697, 18698, 18699, 18700, 18701 | +3-15% Endurance |
| Unholy Power | 5 | 18769, 18770, 18771, 18772, 18773 | +2-10% dégâts démons |
| Demonic Aegis | 2 | candidats SpellName, absents de Talent : 470279, 1235316 | +15/30% Demon Skin/Armor |
| Improved Voidwalker | 3 | 18705, 18706, 18707 | +10-30% |
| Fel Vitality | 3 | 18731, 18743, 18744, 18745, 18746 | +5-15% PV/mana démon |
| Demonic Energies | 2 | candidats SpellName, absents de Talent : 1225214, 1243028 | soin familier 8/15% des dégâts |
| Improved Sayaad | 3 | 18754, 18755, 18756 | +10-30% effets Succube/Incube |
| Demonic Sacrifice | 1 | 18788 | sacrifie le démon pour un buff |
| Master Summoner | 2 | 18709, 18710 | -2/4 s invocation, -20/40% mana |
| Decimation | 2 | candidats SpellName, absents de Talent : 440870, 440873, 440923 | -45/90% recharge Soul Fire |
| Fel Domination | 1 | 18708 | prochaine invocation -5,5 s, -50% mana |
| Demonic Brand | 3 | candidats SpellName, absents de Talent : 1293695, 1293696, 1293697, 1293698, 1293699 | -17-50% menace Searing Pain |
| Improved Felhunter | 3 | 1225217 (SpellName seul ; absent de Talent) | +10-30%, Spell Lock -2-6 s |
| Soul Link | 1 | 19028 (Talent.csv) | 30% des dégâts subis vont au démon ; coût 20% base, GCD 1,5 s (Wowhead) |
| Demonic Knowledge | 3 | candidats SpellName, absents de Talent : 412732, 412735, 415749, 1243120 | bonus dégâts sorts selon démon |
| Master Demonologist | 5 | 23785, 23822, 23823, 23824, 23825 | +2-10% effets par démon |
| Demonic Pact | 1 | candidats SpellName, absents de Talent : 425464, 425466, 425467, 425473 | l'effet du sacrifice persiste |

### Destruction (16)
| Talent | Rangs | IDs | Effet court |
|---|---|---|---|
| Destructive Reach | 2 | 17917, 17918 | +10/20% portée |
| Improved Shadow Bolt | 5 | 17793, 17796, 17801, 17802, 17803 | +4-20% dégâts Ombre subis après crit Shadow Bolt |
| Bane | 5 | 17788, 17789, 17790, 17791, 17792 | -0,1 à -0,5 s Shadow Bolt/Immolate/Incinerate |
| Molten Skin | 5 | 1225220 (SpellName seul ; absent de Talent) | -2-10% dégâts subis |
| Cataclysm | 3 | 17778, 17779, 17780, 17781, 17782 | -3/6/10% coût Destruction |
| Aftermath | 5 | 18119, 18120, 18121, 18122, 18123 | +10-50% dégâts initiaux Immolate |
| Ruin | 5 | 17959 | +20-100% bonus crit |
| Shadowburn | 1 | 17877 | talent actif (Talent.csv 17877) |
| Intensity | 3 | 18135, 18136 | 23/47/70% anti-interruption |
| Agonizing Flames | 3 | 17927, 17929, 17930, 17931, 17932 | +3/7/10% crit Searing Pain |
| Conflagrate | 1 | 17962 | talent actif (Talent.csv ; la valeur 1293817 du fichier est écartée, voir Points non vérifiés) |
| Pyroclasm | 2 | 18096, 18073 (Talent.csv, ligne nommée « Apocalypse » ; 18073 = Pyroclasm dans SpellName) | 13/26% étourdissement |
| Bane of Havoc | 1 | 1225228 (SkillLineAbility ; absent de Talent ; autres sorts de même nom dans SpellName : 1243338, 1243339) | partage 15% des dégâts, 5 min |
| Fire and Brimstone | 3 | 412751 (SpellName seul ; absent de Talent) | +8/17/25% crit Conflagrate |
| Shadow and Flame | 5 | candidats SpellName, absents de Talent : 426316, 426449 | +2-10% dégâts Ombre/Feu après Conflagrate/Shadowburn |
| Incinerate | 1 | 412758 | talent actif (SkillLineAbility ; absent de Talent) |

## Buffs, debuffs et procs à suivre en WeakAuras

Seuls les IDs lus sur une page sont listés. Pour tous les DoTs/malédictions, l'ID d'aura n'a pas été vérifié séparément de l'ID de sort (en Classic Era il est en général identique, mais non confirmé ici).

| Nom | Spell ID de l'aura | Type | Source |
|---|---|---|---|
| Shadow Trance (proc Nightfall) | 17941 | proc / buff joueur, 10 s, -99% temps d'incantation Shadow Bolt | wowhead.com/forever/spell=17941 |
| Shadow Vulnerability (Improved Shadow Bolt) | 17794 | debuff cible, 12 s, +5% dégâts du lanceur (valeur page) | wowhead.com/forever/spell=17794 |
| Demon Armor r5 | 11735 (= ID du sort) | buff joueur, 30 min | wowhead forever, aussi wow-forever.gg ; l'ID d'aura des autres rangs n'est pas vérifié |
| Soul Link | 19028 (= ID du talent/sort) | buff joueur ; effet « Dummy » côté serveur | wowhead.com/forever/spell=19028 ; DB2 : 19028 sans effet APPLY_AURA ; autre sort du même nom dans SpellName : 25228 (candidat d'aura, non confirmé) |
| Bane of Doom Effect | 18662 | invocation du Garde funeste après 1 min | wowhead, wow-forever.gg |
| Corruption r1-7 / Immolate r1-8 / Bane of Agony r1-6 / Siphon Life r1-4 | identiques aux IDs de sort ci-dessus | debuff cible (DoT) | DB2 : le sort porte lui-même l'effet APPLY_AURA, aucun sort déclenché |
| Curse of the Elements r1-4, Weakness, Recklessness, Tongues, Exhaustion (18223) | identiques aux IDs de sort | debuff cible (malédiction) | DB2 : effet APPLY_AURA porté par le sort lui-même |
| Backlash | non trouvé (absent du DB2 70245) | proc | aucun sort de ce nom exact ; seuls « Magic Backlash » 4947 et « Void Backlash » 427144 (noms différents, non retenus) ; absent de Talent et SkillLineAbility |
| Aftermath (daze) | 18118 | debuff déclenché par 18119 (SpellEffect) | DB2 |
| Pyroclasm (buff) | candidats : 18093, 1293803 ; 18073 déclenche 18350 « Dummy Trigger » (pas une aura) | proc / buff | DB2 SpellName ; 18093 porte APPLY_AURA (SkillLineAbility) |
| Shadow and Flame | candidats : 426316, 426449 | proc / buff | DB2 SpellName |
| Decimation | candidats : 440870, 440873, 440923 | proc / buff | DB2 SpellName |
| Demonic Sacrifice | 18788 (sans effet APPLY_AURA dans le DB2) | buff | DB2 ; ID d'aura distinct : non trouvé (absent du DB2 70245) |
| Shadow Ward absorb | 28610 (r4) etc. (a priori ID de sort) | buff joueur 30 s | non vérifié |

## Points non vérifiés

- **IDs des talents** : issus du DB2 Talent.csv ; talents absents de Talent.csv : voir candidats dans les tableaux.
- **Summon Felsteed / Summon Dreadsteed** : IDs DB2 5784 / 23161 (ligne Mounts, pas classe). Summon Incubus 713 présent dans le DB2.
- **Auras** (sources web) : seuls Shadow Trance (17941), Shadow Vulnerability (17794), Demon Armor r5 (11735) et Soul Link (19028) lus sur Wowhead. Shadow Vulnerability : une page wowhead `spell=17800` a renvoyé 404 (ID non lu). Aucun ID d'aura distinct de DoT/malédiction vérifié.
- **Divergences** : Siphon Life et Conflagrate listés « talent » rang 1 mais avec niveau 38/32 sur wowforevertalents ; niveau de Conflagrate r3 absent ; niveaux endgametools inutilisables (x10, parfois décalés) ; Create Healthstone r1 niveau 10 (wowforevertalents) contre 1 (foreverchanges, dans le texte de page) ; Create Soulstone/Subjugate/Death Coil durées et valeurs de dégâts divergent selon les sources, non reprises ; Fear r1 10 s (wowforevertalents/endgametools) contre « up to 20 s » (foreverchanges, rang 3 seulement).
- Pyroclasm : voir Écarts avec le DB2 client.
- Coût Life Tap, dégâts : non repris (valeurs « selon stats »).
- Wowhead `/forever/spells` et filtres de classe : listes non chargées (JS), donc aucune validation croisée des IDs de la liste wow-forever.gg hors les 4 pages auras lues + Corruption 25311.

### Écarts avec le DB2 client

Valeur du DB2 gardée dans les tableaux.
- **Conflagrate (talent)** : fichier 1293817 ; Talent.csv rang 1 = 17962. Dans le tableau des sorts, 1293817 (rang 1), 1293818 (r2), 17962 (r3), 18930-18932 existent tous dans SkillLineAbility : non modifiés.
- **Pyroclasm** : fichier 18093 ; Talent.csv rangs 18096, 18073. 18093 existe dans SkillLineAbility/SpellName (aura), pas comme rang de talent.
- **Rangs max** : DB2 Talent.csv diffère du fichier pour Improved Bane of Agony (3 au lieu de 2), Fel Concentration (5 / 3), Soul Siphon (5 / 3), Cataclysm (5 / 3), Ruin (1 / 5), Intensity (2 / 3), Agonizing Flames (5 / 3), Fel Vitality (5 / 3). Colonne « Rangs » non modifiée.
- **Absents de Talent.csv** (IDs du fichier présents dans SkillLineAbility) : Wrack 1316697, Incinerate 412758, Bane of Havoc 1225228, Portal of Summoning 437169.
- **Talents DB2 absents du fichier** : Improved Firebolt, Improved Lash of Pain, Devastation, Apocalypse/Pyroclasm, Improved Immolate, Emberstorm, Improved Curse of Weakness, Grim Reach, Improved Curse of Exhaustion, Improved Healthstone, Improved Subjugate Demon, Improved Firestone, Improved Spellstone ; plus 6 emplacements sans nom (Affliction 1/1 : 18213, 18372 ; 3/3 : 17864, 18393 ; 1/6 : 18220 ; Démonologie 2/2 : 18748-18752). Probablement retirés par correctif serveur : actif en jeu non vérifié.
- Aucun ID de la section « Sorts de base » absent du DB2 ou différent.

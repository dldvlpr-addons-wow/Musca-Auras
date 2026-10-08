# Druide — WoW Forever 1.60.1
Sources et build lus, date 2026-10-08.

- **DB2 client wago.tools build 1.60.1.70245 (Talent, SkillLineAbility, SpellEffect, SpellName)** : source de référence (fait foi). Le DB2 contient aussi des talents retirés par correctif serveur : présence dans le DB2 ≠ actif en jeu. Les talents Forever sans ligne dans Talent.csv (Genesis, Eclipse, etc.) sont repris de SpellName seul (« SpellName seul »), sans lien talent confirmé.
- **IDs des sorts** : wow-forever.gg `/db/spells/browse/class/druid/` (212 lignes, build 1.60.1.70245). Les pages de liste Wowhead Forever (`/forever/spells`, `/spells/abilities/druid`, `/spells/talents/druid`) ne renvoient que les filtres, sans lignes. Wowhead Forever lu en recoupement ponctuel : `spell=25299` (Rejuvenation R11, 360 mana, 12 s, cohérent), URLs `spell=16870` (Clearcasting), `spell=17007` (Leader of the Pack), `spell=24858` (Moonkin Form).
- **Niveaux, coûts, recharges, durées** : endgametools.com `/en/wow-forever/spells/druid` (201 lignes, build 1.60.1.70245) et wowforevertalents.com `/abilities/druid/` (70245). Ces deux sites n'affichent aucun spell ID.
- **Talents** : wowforevertalents.com `/druid/` et wow-forever.gg `/talents/druid/` (52 talents). Aucun des deux n'affiche d'ID.
- Le « Coût » est celui du rang indiqué. Forme requise : non indiquée par les sources sauf mention en Notes ; « — » = non indiqué.

## Sorts de base (entraîneur)

Formes (sorts de forme) : Bear Form 5487, Dire Bear Form 9634, Cat Form 768, Travel Form 783, Aquatic Form 1066, Moonkin Form 24858 (voir tableau).

| Nom | Rang | Spell ID | Niveau | Coût / ressource | Recharge | Durée | Notes |
|---|---|---|---|---|---|---|---|
| Healing Touch | 1 | 5185 | 1 | 25 mana | — | — | humanoïde ; incantation 1,5 s (R1) à 3,5 s |
| Healing Touch | 2 | 5186 | 8 | 55 mana | — | — | |
| Healing Touch | 3 | 5187 | 14 | 110 mana | — | — | |
| Healing Touch | 4 | 5188 | 20 | 190 mana | — | — | |
| Healing Touch | 5 | 5189 | 26 | 280 mana | — | — | |
| Healing Touch | 6 | 6778 | 32 | 350 mana | — | — | |
| Healing Touch | 7 | 8903 | 38 | 425 mana | — | — | |
| Healing Touch | 8 | 9758 | 44 | 520 mana | — | — | |
| Healing Touch | 9 | 9888 | 50 | 630 mana | — | — | |
| Healing Touch | 10 | 9889 | 56 | 755 mana | — | — | |
| Healing Touch | 11 | 25297 | 60 | 840 mana | — | — | |
| Mark of the Wild | 1 | 1126 | 1 | 20 mana | — | 1 h | humanoïde |
| Mark of the Wild | 2 | 5232 | 10 | 50 mana | — | 1 h | |
| Mark of the Wild | 3 | 6756 | 20 | 100 mana | — | 1 h | |
| Mark of the Wild | 4 | 5234 | 30 | 160 mana | — | 1 h | |
| Mark of the Wild | 5 | 8907 | 40 | 240 mana | — | 1 h | |
| Mark of the Wild | 6 | 9884 | 50 | 340 mana | — | 1 h | |
| Mark of the Wild | 7 | 9885 | 60 | 445 mana | — | 1 h | |
| Gift of the Wild | 1 | 21849 | 50 | 900 mana | — | 1 h | humanoïde |
| Gift of the Wild | 2 | 21850 | 60 | 1200 mana | — | 1 h | |
| Wrath | 1 | 5176 | 1 | 10 mana | — | — | humanoïde ; incantation 1,5 s à 2 s |
| Wrath | 2 | 5177 | 6 | 20 mana | — | — | |
| Wrath | 3 | 5178 | 14 | 40 mana | — | — | |
| Wrath | 4 | 5179 | 22 | 50 mana | — | — | |
| Wrath | 5 | 5180 | 30 | 70 mana | — | — | |
| Wrath | 6 | 6780 | 38 | 80 mana | — | — | |
| Wrath | 7 | 8905 | 46 | 100 mana | — | — | |
| Wrath | 8 | 9912 | 54 | 120 mana | — | — | |
| Moonfire | 1 | 8921 | 4 | 25 mana | — | 9 s | humanoïde (autres formes non précisées) |
| Moonfire | 2 | 8924 | 10 | 50 mana | — | 12 s | |
| Moonfire | 3 | 8925 | 16 | 75 mana | — | 12 s | |
| Moonfire | 4 | 8926 | 22 | 105 mana | — | 12 s | |
| Moonfire | 5 | 8927 | 28 | 150 mana | — | 12 s | |
| Moonfire | 6 | 8928 | 34 | 190 mana | — | 12 s | |
| Moonfire | 7 | 8929 | 40 | 235 mana | — | 12 s | |
| Moonfire | 8 | 9833 | 46 | 280 mana | — | 12 s | |
| Moonfire | 9 | 9834 | 52 | 325 mana | — | 12 s | |
| Moonfire | 10 | 9835 | 58 | 375 mana | — | 12 s | |
| Rejuvenation | 1 | 774 | 4 | 25 mana | — | 12 s | humanoïde ou arbre ; pas en Moonkin (page wow-forever.gg) ; portée 40 m |
| Rejuvenation | 2 | 1058 | 10 | 40 mana | — | 12 s | |
| Rejuvenation | 3 | 1430 | 16 | 75 mana | — | 12 s | |
| Rejuvenation | 4 | 2090 | 22 | 105 mana | — | 12 s | |
| Rejuvenation | 5 | 2091 | 28 | 135 mana | — | 12 s | |
| Rejuvenation | 6 | 3627 | 34 | 160 mana | — | 12 s | |
| Rejuvenation | 7 | 8910 | 40 | 195 mana | — | 12 s | |
| Rejuvenation | 8 | 9839 | 46 | 235 mana | — | 12 s | |
| Rejuvenation | 9 | 9840 | 52 | 280 mana | — | 12 s | |
| Rejuvenation | 10 | 9841 | 58 | 335 mana | — | 12 s | |
| Rejuvenation | 11 | 25299 | 60 | 360 mana | — | 12 s | |
| Regrowth | 1 | 8936 | 12 | 70 mana | — | 21 s | humanoïde ; incantation 2 s |
| Regrowth | 2 | 8938 | 18 | 125 mana | — | 21 s | |
| Regrowth | 3 | 8939 | 24 | 170 mana | — | 21 s | |
| Regrowth | 4 | 8940 | 30 | 210 mana | — | 21 s | |
| Regrowth | 5 | 8941 | 36 | 250 mana | — | 21 s | |
| Regrowth | 6 | 9750 | 42 | 305 mana | — | 21 s | |
| Regrowth | 7 | 9856 | 48 | 370 mana | — | 21 s | |
| Regrowth | 8 | 9857 | 54 | 445 mana | — | 21 s | |
| Regrowth | 9 | 9858 | 60 | 525 mana | — | 21 s | |
| Thorns | 1 | 467 | 6 | 35 mana | — | 10 min | humanoïde |
| Thorns | 2 | 782 | 14 | 60 mana | — | 10 min | |
| Thorns | 3 | 1075 | 24 | 105 mana | — | 10 min | |
| Thorns | 4 | 8914 | 34 | 170 mana | — | 10 min | |
| Thorns | 5 | 9756 | 44 | 240 mana | — | 10 min | |
| Thorns | 6 | 9910 | 54 | 320 mana | — | 10 min | |
| Entangling Roots | 1 | 339 | 8 | 50 mana | — | 12 s | incantation 1,5 s |
| Entangling Roots | 2 | 1062 | 18 | 65 mana | — | 15 s | |
| Entangling Roots | 3 | 5195 | 28 | 80 mana | — | 18 s | |
| Entangling Roots | 4 | 5196 | 38 | 95 mana | — | 21 s | |
| Entangling Roots | 5 | 9852 | 48 | 110 mana | — | 24 s | |
| Entangling Roots | 6 | 9853 | 58 | 125 mana | — | 27 s | |
| Teleport: Moonglade | — | 18960 | 10 | 120 mana | — | — | incantation 10 s |
| Faerie Fire | 1 | 770 | 18 | 55 mana | — | 40 s | |
| Faerie Fire | 2 | 778 | 30 | 75 mana | — | 40 s | |
| Faerie Fire | 3 | 9749 | 42 | 95 mana | — | 40 s | |
| Faerie Fire | 4 | 9907 | 54 | 115 mana | — | 40 s | |
| Hibernate | 1 | 2637 | 18 | 90 mana | — | 20 s | incantation 1,5 s |
| Hibernate | 2 | 18657 | 38 | 120 mana | — | 30 s | |
| Hibernate | 3 | 18658 | 58 | 150 mana | — | 40 s | |
| Nature's Grasp | 1 | 16689 | 10 | 50 mana | 1 min | 45 s | présent dans les sorts ; talent « Nature's Grasp » absent des arbres Forever |
| Nature's Grasp | 2 | 16810 | 18 | 65 mana | 1 min | 45 s | |
| Nature's Grasp | 3 | 16811 | 28 | 80 mana | 1 min | 45 s | |
| Nature's Grasp | 4 | 16812 | 38 | 95 mana | 1 min | 45 s | |
| Nature's Grasp | 5 | 16813 | 48 | 110 mana | 1 min | 45 s | |
| Nature's Grasp | 6 | 17329 | 58 | 125 mana | 1 min | 45 s | |
| Starfire | 1 | 2912 | 20 | 95 mana | — | — | incantation 3,5 s |
| Starfire | 2 | 8949 | 26 | 135 mana | — | — | |
| Starfire | 3 | 8950 | 34 | 180 mana | — | — | |
| Starfire | 4 | 8951 | 42 | 230 mana | — | — | |
| Starfire | 5 | 9875 | 50 | 275 mana | — | — | |
| Starfire | 6 | 9876 | 58 | 315 mana | — | — | |
| Starfire | 7 | 25298 | 60 | 340 mana | — | — | |
| Soothe Animal | 1 | 2908 | 22 | 50 mana | — | 15 s | incantation 1,5 s |
| Soothe Animal | 2 | 8955 | 38 | 75 mana | — | 15 s | |
| Soothe Animal | 3 | 9901 | 54 | 100 mana | — | 15 s | |
| Insect Swarm | 1 | 5570 | 20 (ID listé) | — | — | 12 s | talent Balance en Forever (rang 1 = talent) |
| Insect Swarm | 2 | 24974 | 30 | 85 mana | — | 12 s | |
| Insect Swarm | 3 | 24975 | 40 | 100 mana | — | 12 s | |
| Insect Swarm | 4 | 24976 | 50 | 140 mana | — | 12 s | |
| Insect Swarm | 5 | 24977 | 60 | 160 mana | — | 12 s | |
| Hurricane | 1 | 16914 | 40 | 880 mana | — | 10 s | canalisé |
| Hurricane | 2 | 17401 | 50 | 1180 mana | — | 10 s | |
| Hurricane | 3 | 17402 | 60 | 1495 mana | — | 10 s | |
| Barkskin | — | 22812 | 44 | — | 1 min | 15 s | |
| Moonkin Form | — | 24858 | 40 (ID listé) | 35 % mana de base | — | — | talent (Balance) ; forme sélénienne |
| Revive | 1 | 437138 | 12 | 75 % mana de base | — | — | incantation 10 s ; hors combat |
| Revive | 2 | 1237948 | 24 | 75 % mana de base | — | — | |
| Revive | 3 | 1237949 | 36 | 75 % mana de base | — | — | |
| Revive | 4 | 1237950 | 48 | 75 % mana de base | — | — | |
| Revive | 5 | 1237951 | 60 | 75 % mana de base | — | — | |
| Rebirth | 1 | 20484 | 20 | 85 % mana de base | 30 min | — | incantation 2 s |
| Rebirth | 2 | 20739 | 30 | 85 % mana de base | 30 min | — | |
| Rebirth | 3 | 20742 | 40 | 85 % mana de base | 30 min | — | |
| Rebirth | 4 | 20747 | 50 | 85 % mana de base | 30 min | — | |
| Rebirth | 5 | 20748 | 60 | 85 % mana de base | 30 min | — | |
| Cure Poison | — | 8946 | 14 | 16 % mana de base | — | — | |
| Abolish Poison | — | 2893 | 26 | 16 % mana de base | — | 8 s | effet : 3137 (« Abolish Poison Effect ») |
| Remove Curse | — | 2782 | 24 | 10 % mana de base | — | — | |
| Tranquility | 1 | 740 | 30 | 375 mana | 5 min | 10 s | canalisé |
| Tranquility | 2 | 8918 | 40 | 505 mana | 5 min | 10 s | |
| Tranquility | 3 | 9862 | 50 | 695 mana | 5 min | 10 s | |
| Tranquility | 4 | 9863 | 60 | 925 mana | 5 min | 10 s | |
| Innervate | — | 29166 | 40 | 5 % mana de base | 6 min | 20 s | |
| Swiftmend | — | 18562 | 1 (ID listé) | 20 % mana de base | 15 s | — | talent Restauration ; portée 40 m |
| Nature's Swiftness | — | 17116 | 1 (ID listé) | — | 3 min | — | talent Restauration |
| Wild Growth | 1 | 408120 | 40 (ID listé) | 550 mana (talent) | 6 s | 7 s | talent Restauration ; rang 1 = talent |
| Wild Growth | 2 | 1238214 | 50 | 755 mana | 6 s | 7 s | |
| Wild Growth | 3 | 1238215 | 60 | 1050 mana | 6 s | 7 s | |
| Bear Form | — | 5487 | 10 | 55 % mana de base | — | — | forme ours ; passifs liés : 1178, 21178 |
| Dire Bear Form | — | 9634 | 40 | 55 % mana de base | — | — | forme ours ; passif lié : 9635 |
| Cat Form | — | 768 | 20 | 55 % mana de base | — | — | forme félin ; passif lié : 3025 (niveau 6 listé) |
| Travel Form | — | 783 | 30 | 20 % mana de base | — | — | forme voyage |
| Aquatic Form | — | 1066 | 16 | 20 % mana de base | — | — | forme aquatique ; passif lié : 5421 |
| Growl | — | 6795 | 10 | — | 8 s | — | ours |
| Demoralizing Roar | 1 | 99 | 10 | 10 rage | — | 30 s | ours |
| Demoralizing Roar | 2 | 1735 | 20 | 10 rage | — | 30 s | |
| Demoralizing Roar | 3 | 9490 | 32 | 10 rage | — | 30 s | |
| Demoralizing Roar | 4 | 9747 | 42 | 10 rage | — | 30 s | |
| Demoralizing Roar | 5 | 9898 | 52 | 10 rage | — | 30 s | |
| Maul | 1 | 6807 | 10 | 15 rage | — | — | ours |
| Maul | 2 | 6808 | 18 | 15 rage | — | — | |
| Maul | 3 | 6809 | 26 | 15 rage | — | — | |
| Maul | 4 | 8972 | 34 | 15 rage | — | — | |
| Maul | 5 | 9745 | 42 | 15 rage | — | — | |
| Maul | 6 | 9880 | 50 | 15 rage | — | — | |
| Maul | 7 | 9881 | 58 | 15 rage | — | — | |
| Enrage | — | 5229 | 12 | — | 1 min | 10 s | ours |
| Bash | 1 | 5211 | 14 | 10 rage | 1 min | 2 s | ours |
| Bash | 2 | 6798 | 30 | 10 rage | 1 min | 3 s | |
| Bash | 3 | 8983 | 46 | 10 rage | 1 min | 4 s | |
| Swipe | 1 | 779 | 16 | 20 rage | — | — | ours (R1 779 selon la liste ; la liste porte aussi 780, 769, 9754, 9908) |
| Swipe | 2 | 780 | 24 | 20 rage | — | — | |
| Swipe | 3 | 769 | 34 | 20 rage | — | — | |
| Swipe | 4 | 9754 | 44 | 20 rage | — | — | |
| Swipe | 5 | 9908 | 54 | 20 rage | — | — | |
| Challenging Roar | — | 5209 | 28 | 15 rage | 10 min | 6 s | ours |
| Frenzied Regeneration | — | 22842 | 36 | — | 3 min | 10 s | ours |
| Lacerate | 1 | 414644 | 42 | 15 rage | — | 15 s | ours (saignement) |
| Lacerate | 2 | 1235826 | 50 | 15 rage | — | 15 s | |
| Lacerate | 3 | 1235827 | 58 | 15 rage | — | 15 s | |
| Primal Bite | 1 | 407995 | 25 (ID listé) | 20 rage | 6 s | — | talent Farouche ; rang 1 = talent ; ours |
| Primal Bite | 2 | 1238069 | 36 | 20 rage | 6 s | — | |
| Primal Bite | 3 | 1238070 | 48 | 20 rage | 6 s | — | |
| Primal Bite | 4 | 1238073 | 60 | 20 rage | 6 s | — | |
| Feral Charge | — | 1238122 | 20 (ID listé) | 5 rage | 15 s | immobilise 4 s | talent Farouche |
| Claw | 1 | 1082 | 20 | 45 énergie | — | — | félin |
| Claw | 2 | 3029 | 28 | 45 énergie | — | — | |
| Claw | 3 | 5201 | 38 | 45 énergie | — | — | |
| Claw | 4 | 9849 | 48 | 45 énergie | — | — | |
| Claw | 5 | 9850 | 58 | 45 énergie | — | — | |
| Prowl | 1 | 5215 | 20 | — | 10 s | jusqu'à annulation | félin |
| Prowl | 2 | 6783 | 40 | — | 10 s | jusqu'à annulation | |
| Prowl | 3 | 9913 | 60 | — | 10 s | jusqu'à annulation | |
| Rip | 1 | 1079 | 20 | 30 énergie | — | 12 s | félin ; points de combo |
| Rip | 2 | 9492 | 28 | 30 énergie | — | 12 s | |
| Rip | 3 | 9493 | 36 | 30 énergie | — | 12 s | |
| Rip | 4 | 9752 | 44 | 30 énergie | — | 12 s | |
| Rip | 5 | 9894 | 52 | 30 énergie | — | 12 s | |
| Rip | 6 | 9896 | 60 | 30 énergie | — | 12 s | |
| Shred | 1 | 5221 | 22 | 60 énergie | — | — | félin ; derrière la cible |
| Shred | 2 | 6800 | 30 | 60 énergie | — | — | |
| Shred | 3 | 8992 | 38 | 60 énergie | — | — | |
| Shred | 4 | 9829 | 46 | 60 énergie | — | — | |
| Shred | 5 | 9830 | 54 | 60 énergie | — | — | |
| Rake | 1 | 1822 | 24 | 40 énergie | — | 9 s | félin ; saignement |
| Rake | 2 | 1823 | 34 | 40 énergie | — | 9 s | |
| Rake | 3 | 1824 | 44 | 40 énergie | — | 9 s | |
| Rake | 4 | 9904 | 54 | 40 énergie | — | 9 s | |
| Dash | 1 | 1850 | 26 | — | 5 min | 15 s | félin |
| Dash | 2 | 9821 | 46 | — | 5 min | 15 s | |
| Cower | 1 | 8998 | 28 | 20 énergie | 10 s | — | félin |
| Cower | 2 | 9000 | 40 | 20 énergie | 10 s | — | |
| Cower | 3 | 9892 | 52 | 20 énergie | 10 s | — | |
| Ferocious Bite | 1 | 22568 | 32 | 35 énergie | — | — | félin |
| Ferocious Bite | 2 | 22827 | 40 | 35 énergie | — | — | |
| Ferocious Bite | 3 | 22828 | 48 | 35 énergie | — | — | |
| Ferocious Bite | 4 | 22829 | 56 | 35 énergie | — | — | |
| Ferocious Bite | 5 | 31018 | 60 | 35 énergie | — | — | rang 5 présent sur endgametools et wow-forever.gg ; absent de wowforevertalents (rangs 1-4) |
| Ravage | 1 | 6785 | 32 | 60 énergie | — | — | félin ; furtif |
| Ravage | 2 | 6787 | 42 | 60 énergie | — | — | |
| Ravage | 3 | 9866 | 50 | 60 énergie | — | — | |
| Ravage | 4 | 9867 | 58 | 60 énergie | — | — | |
| Pounce | 1 | 9005 | 36 | 50 énergie | — | 18 s | félin ; furtif ; saignement |
| Pounce | 2 | 9823 | 46 | 50 énergie | — | 18 s | |
| Pounce | 3 | 9827 | 56 | 50 énergie | — | 18 s | |
| Track Humanoids | — | 5225 | 32 | — | — | — | félin |
| Feline Grace | — | 20719 | 40 | passif | — | — | félin |

## Talents

Les IDs de talent viennent du DB2 client (Talent.csv, IDs de rang dans l'ordre). Les talents absents de Talent.csv sont repris de SpellName (« SpellName seul ») ; plusieurs candidats = tous listés, non départagés. Effets en chiffres, rangs max (fichier ; écarts de nombre de rangs dans « Points non vérifiés »).

### Équilibre (16)
| Nom | Rangs | Effet court |
|---|---|---|
| Improved Wrath | 5 : 16814, 16815, 16816, 16817, 16818 | incantation -0,1 à -0,5 s ; coût -10 à -50 % |
| Genesis | 5 : absent de Talent.csv ; candidats SpellName seul : 1213163, 1223081 | dégâts/soins périodiques +1 à +5 % |
| Moonglow | 3 : 16845, 16846, 16847 | coût sorts offensifs -8 à -25 % |
| Improved Moonfire | 5 (DB2) : 16821, 16822, 16823, 16824, 16825 | dégâts et critique Moonfire +5 à +10 % |
| Nature's Majesty | 2 : absent de Talent.csv ; SpellName seul : 1223082 (un seul ID pour 2 rangs) | critique sorts et mêlée +2 à +4 % |
| Nature's Reach | 2 : 16819, 16820 | portée +10 à +20 % ; toucher +2 à +4 % |
| Improved Entangling Roots | 3 : 16918, 16919, 16920 | dégâts racines +25 à +75 % |
| Nature's Splendor | 1 : absent de Talent.csv ; SpellName seul : 1223083 | Moonfire et Rejuvenation +3 s, Regrowth +6 s, Insect Swarm +2 s |
| Insect Swarm | 1 : 5570 (Talent.csv, onglet Restauration) | 48 dégâts Nature sur 12 s |
| Vengeance | 5 : 16909, 16910, 16911, 16912, 16913 | bonus dégâts critiques Arcane/Nature +20 à +100 % |
| Improved Starfire | 5 : 16850, 16923, 16924, 16925, 16926 | incantation -0,1 à -0,5 s ; étourdissement 3 à 15 %, 3 s (étourdissement : 16922) |
| Overgrowth | 4 (DB2) : 17245, 17247, 17248, 17249 | Entangling Roots +1 à +2 cibles |
| Nature's Grace | 1 : 16880 (aura déclenchée : 16886) | après critique non périodique : incantation et GCD plus rapides de 10 % pendant 3 s |
| Eclipse | 3 : absent de Talent.csv ; candidats SpellName seul : 408248, 408255, 409813, 441260, 1286115 (non départagés) | 2 prochains Starfire raccourcis de 0,17 à 0,5 s ; jusqu'à 4 charges ; 15 s |
| Moonfury | 5 : 16896, 16897, 16899, 16900, 16901 | dégâts Arcane et Nature +2 à +10 % |
| Moonkin Form | 1 : 24858 (Talent.csv ; sort de forme) | armure objets +360 % ; critique groupe +3 % à 45 m ; 35 % mana de base |

### Combat farouche (20)
| Nom | Rangs | Effet court |
|---|---|---|
| Ferocity | 5 : 16934, 16935, 16936, 16937, 16938 | coût capacités -1 à -5 rage/énergie |
| Heart of the Wild | 5 : 17003, 17004, 17005, 17006, 24894 | Intel +2 à +10 % ; Endu ours +4 à +20 % ; Force félin +2 à +10 % |
| Feral Swiftness | 2 : 17002, 24866 | vitesse félin +15 à +30 % ; esquive +2 à +4 % |
| Feral Instinct | 5 (DB2) : 16947, 16948, 16949, 16950, 16951 | Swipe +10 à +30 % |
| Brutal Impact | 2 : 16940, 16941 | Bash/Pounce +0,5 à +1 s ; recharge Bash -15 à -30 s |
| Thick Hide | 5 (DB2) : 16929, 16930, 16931, 16932, 16933 | armure +1 à +3 par niveau |
| Shredding Attacks | 2 (DB2) : 16966, 16968 (16968 nommé « Improved Shred ») | coût Shred -6 à -18 ; Lacerate -1 à -3 rage |
| Savage Fury | 2 : 16998, 16999 | Claw/Rake/Shred/Maul/Swipe +5 à +10 % |
| Feral Charge | 1 : 16979 (Talent.csv, « Feral Charge (Bear) ») ; sort : 1238122 (aura déclenchée : 19675) | 5 rage ; 25 m ; recharge 15 s ; immobilise/interrompt 4 s |
| Sharpened Claws | 3 (DB2) : 16942, 16943, 16944 | critique ours et félin +3 à +6 % |
| Shifting Power | 1 : absent de Talent.csv ; sort SkillLineAbility Feral : 1322605 | 55 % mana de base vers 40 énergie ; recharge 16 s |
| Primal Bite | 1 : 407995 (SkillLineAbility ; absent de Talent.csv) | 20 rage ; recharge 6 s |
| Predatory Strikes | 3 : 16972, 16974, 16975 | puissance d'attaque mêlée +50 à +150 % du niveau |
| Blood Frenzy | 2 : 16958, 16961 (aura déclenchée : 16959) | proc rage (ours) / point de combo (félin) 50 à 100 % |
| Improved Shifting Power | 2 : absent de Talent.csv ; SpellName seul : 1322670 (un seul ID pour 2 rangs) | recharge Shifting Power -4 à -8 s |
| Leader of the Pack | 1 : 17007 (Talent.csv) ; autre « Leader of the Pack » dans SpellName : 24932 (voir auras) | critique groupe +3 % à 45 m |
| Predatory Instincts | 2 : absent de Talent.csv ; SpellName seul : 1223242 (un seul ID pour 2 rangs) | dégâts critiques mêlée +10 à +20 % |
| Natural Reaction | 5 : absent de Talent.csv ; candidats SpellName seul : 417051, 417053 (non départagés) | esquive +1 à +5 % ; proc 5 rage sur esquive 20 à 100 % |
| Rend and Tear | 5 : absent de Talent.csv ; SpellName seul : 1223246 (un seul ID pour 5 rangs) | dégâts mêlée sur cibles saignantes +2 à +10 % |
| Berserk | 1 : absent de Talent.csv ; candidats : 417141 (SkillLineAbility Feral Combat, seul lié à la classe) ; autres « Berserk » SpellName seul : 23397, 26068, 26615, 26662, 27680, 28498, 365122, 368388, 424759, 442211, 1215885, 1231375, 1237939, 1289125 (non départagés) | recharge 3 min ; 15 s ; critique points de combo +100 % |

### Restauration (16)
| Nom | Rangs | Effet court |
|---|---|---|
| Nature's Focus | 5 : 17063, 17065, 17066, 17067, 17068 | évite interruption 14 à 70 % |
| Furor | 5 : 17056, 17058, 17059, 17060, 17061 | proc rage (ours) / énergie (félin) 20 à 100 % |
| Naturalist | 5 : 17069, 17070, 17071, 17072, 17073 | incantation Healing Touch -0,1 à -0,5 s ; dégâts +1 à +5 % |
| Subtlety | 5 (DB2) : 17118, 17119, 17120, 17121, 17122 | menace Nature/Arcane -10 à -30 % |
| Natural Shapeshifter | 3 : 16833, 16834, 16835 (Talent.csv, onglet Équilibre) | coût formes -10 à -30 % |
| Reflection | 3 : 17106, 17107, 17108 | régénération mana en incantation 17 à 50 % |
| Gift of Nature | 5 : 17104, 24943, 24944, 24945, 24946 | soins +2 à +10 % |
| Gift of the Earthmother | 1 : absent de Talent.csv ; SpellName seul : 414673 | GCD -0,5 s sur Rejuvenation, Swiftmend, Wild Growth |
| Tranquil Spirit | 5 : 24968, 24969, 24970, 24971, 24972 | coût Healing Touch/Tranquility -2 à -10 % |
| Improved Rejuvenation | 3 : 17111, 17112, 17113 | effet Rejuvenation +5 à +15 % |
| Swiftmend | 1 : 18562 | 20 % mana de base ; 40 m ; recharge 15 s |
| Nature's Swiftness | 1 : 17116 | recharge 3 min ; prochain sort Nature instantané |
| Living Spirit | 3 : absent de Talent.csv ; SpellName seul : 1309631 (un seul ID pour 3 rangs) | Esprit +5 à +15 % |
| Improved Tranquility | 2 : 17123, 17124 | menace -50 à -100 % ; recharge -30 à -60 % |
| Improved Regrowth | 5 : 17074, 17075, 17076, 17077, 17078 | critique Regrowth +10 à +50 % |
| Wild Growth | 1 : 408120 (SkillLineAbility ; absent de Talent.csv) | 550 mana ; 40 m ; recharge 6 s ; 336 soins sur 7 s |

Talents Classic donnés absents de Forever (selon wowforevertalents.com) mais présents dans le DB2 Talent.csv (présence ≠ actif en jeu) : Improved Thorns 16836, 16839, 16840 ; Natural Weapons 16902-16906 ; Nature's Grasp 16689 ; Omen of Clarity 16864 ; Feral Aggression 16858-16862 ; Improved Enrage 17079, 17082 ; Improved Mark of the Wild 17050, 17051, 17053, 17054, 17055. Faerie Fire (Feral) : non trouvé (absent du DB2 70245). Tiger's Fury : 5217 et 417045 présents dans SkillLineAbility Feral Combat (autres « Tiger's Fury » SpellName : 1289238, 1312152). Talents Feral sans nom dans le DB2 (Talent.csv) : colonne 2 rangée 3 (16952, 16954) et colonne 2 rangée 4 (16857), non associés à un nom.

## Buffs, debuffs et procs à suivre en WeakAuras

Règle : l'ID d'aura vient de la section « Sorts déclenchés » du DB2 (SpellEffect.EffectTriggerSpell) quand elle existe. Pour les autres sorts ci-dessous, l'ID donné est celui du **sort lancé** ; l'ID d'aura éventuellement différent est **non vérifié** (aucun déclenchement dans le DB2).

| Nom | Spell ID | Type | Source |
|---|---|---|---|
| Clearcasting (proc Omen of Clarity) | 16870 (DB2 : déclenché par Omen of Clarity 16864, talent Équilibre) | proc | DB2 tranche : 16870. 467735 (fichier précédent, wow-forever.gg) ne correspond à aucun déclenchement druide dans le DB2 (voir écarts) ; autres homonymes SpellName : 12536, 16246, 457342. Omen of Clarity : passif listé niveau 20 sur endgametools, mais talent absent de Forever selon wowforevertalents.com (présent dans le DB2) |
| Nature's Grace (proc) | 16886 (DB2 : déclenché par le talent 16880) | proc | talent, 10 % incantation/GCD, 3 s |
| Leader of the Pack | 17007 (talent, effet aura Dummy dans le DB2) ; autre candidat « Leader of the Pack » : 24932 (effet aura de groupe, SpellName) | buff joueur / groupe | talent Farouche, +3 % critique à 45 m, exclusif avec Moonkin ; les deux IDs listés, non départagés |
| Moonkin Form / Moonkin Aura | 24858 (forme) ; 24907 (Moonkin Aura, DB2 : déclenché par 24858) ; 24905 (Moonkin Form (Passive)) | buff joueur | Moonkin Form double aussi le taux de proc d'Omen of Clarity (Wowhead Forever, Blizzard) |
| Mark of the Wild | 1126 / 5232 / 6756 / 5234 / 8907 / 9884 / 9885 | buff joueur | ID de sort, aura non vérifiée |
| Gift of the Wild | 21849 / 21850 | buff joueur | ID de sort, aura non vérifiée |
| Thorns | 467 / 782 / 1075 / 8914 / 9756 / 9910 | buff joueur | ID de sort, aura non vérifiée |
| Rejuvenation | 774 ... 25299 (voir tableau) | buff joueur (HoT) | ID de sort, aura non vérifiée |
| Regrowth | 8936 ... 9858 (voir tableau) | buff joueur (HoT) | ID de sort, aura non vérifiée |
| Wild Growth | 408120 / 1238214 / 1238215 | buff joueur (HoT) | ID de sort, aura non vérifiée |
| Moonfire | 8921 ... 9835 (voir tableau) | debuff cible | ID de sort, aura non vérifiée |
| Insect Swarm | 5570 / 24974-24977 | debuff cible | ID de sort, aura non vérifiée |
| Entangling Roots | 339 / 1062 / 5195 / 5196 / 9852 / 9853 | debuff cible | ID de sort, aura non vérifiée |
| Nature's Grasp | 16689 / 16810-16813 / 17329 | buff joueur | ID de sort ; DB2 déclenche Entangling Roots (aura cible) : 16689 → 19975, 16810 → 19974, 16811 → 19973, 16812 → 19972, 16813 → 19971, 17329 → 19970 |
| Faerie Fire | 770 / 778 / 9749 / 9907 | debuff cible | ID de sort, aura non vérifiée |
| Hibernate | 2637 / 18657 / 18658 | debuff cible | ID de sort |
| Demoralizing Roar | 99 / 1735 / 9490 / 9747 / 9898 | debuff cible | ID de sort, aura non vérifiée |
| Rake | 1822 / 1823 / 1824 / 9904 | debuff cible (saignement) | ID de sort, aura non vérifiée |
| Rip | 1079 / 9492 / 9493 / 9752 / 9894 / 9896 | debuff cible (saignement) | ID de sort, aura non vérifiée |
| Pounce | 9005 / 9823 / 9827 | debuff cible (saignement) | ID de sort ; DB2 déclenche Pounce Bleed (aura) : 9005 → 9007, 9823 → 9824, 9827 → 9826 ; l'étourdissement n'a pas d'ID séparé dans le DB2 |
| Lacerate | 414644 / 1235826 / 1235827 | debuff cible (saignement) | ID de sort, aura non vérifiée |
| Bash | 5211 / 6798 / 8983 | debuff cible (étourdissement) | ID de sort |
| Abolish Poison (effet) | 3137 | buff joueur | ligne « Abolish Poison Effect » de la liste wow-forever.gg |
| Barkskin | 22812 | buff joueur | ID de sort |
| Enrage | 5229 | buff joueur | ID de sort |
| Frenzied Regeneration | 22842 | buff joueur | ID de sort |
| Dash | 1850 / 9821 | buff joueur | ID de sort |
| Prowl | 5215 / 6783 / 9913 | buff joueur | ID de sort |
| Innervate | 29166 | buff joueur | ID de sort |
| Nature's Swiftness | 17116 | buff joueur | ID de sort |
| Tranquility | 740 / 8918 / 9862 / 9863 | buff joueur (canalisé) | ID de sort |
| Formes (Bear 5487, Dire Bear 9634, Cat 768, Travel 783, Aquatic 1066, Moonkin 24858) | voir tableau | buff joueur | ID de sort ; Tree Form, candidats SpellName (non départagés) : 775 et 22688 (« Tree Form »), 3122 et 5420 (« Tree Form (Passive) » / « (Passive) 2 »), 439733, 439745, 439766 (« Tree of Life »), 439734 (« Tree of Life (Passive) ») |
| Eclipse (effet) | candidats SpellName seul : 408248, 408255, 409813, 441260, 1286115 | proc / buff joueur | non départagés ; aucun lien de déclenchement dans le DB2 |
| Berserk (effet) | candidats : 417141 (SkillLineAbility Feral Combat) ; autres « Berserk » SpellName seul : 23397, 26068, 26615, 26662, 27680, 28498, 365122, 368388, 424759, 442211, 1215885, 1231375, 1237939, 1289125 | buff joueur | non départagés |
| Furor (effet) | talent 17056 (+ rangs 17058-17061) ; candidats SpellName « Furor » : 17057, 17099, 1238181 | proc | non départagés ; aucun lien de déclenchement dans le DB2 |
| Shifting Power (effets) | 1322605 (sort, SkillLineAbility Feral) ; candidats SpellName : 1291059 (« Shifting Power Cooldown Reduction »), 1322670 (« Improved Shifting Power ») | proc / buff joueur | aucun lien de déclenchement dans le DB2 |
| Autres auras déclenchées (DB2) | Starfire Stun 16922 (Improved Starfire 16850) ; Blood Frenzy 16959 (16958) ; Improved Enrage 17080 (17079) et 17081 (17082) ; Feral Charge 19675 (16979 et 1238122) | proc / debuff cible | |

## Points non vérifiés

- Wowhead Forever (source prioritaire) : les pages de liste ne renvoient que des filtres vides. Seul `spell=25299` a été lu directement ; les IDs viennent de wow-forever.gg.
- endgametools.com et wowforevertalents.com n'affichent aucun spell ID (seuls niveaux, coûts, durées).
- IDs de talent : issus du DB2 Talent.csv ; les talents sans ligne Talent (Genesis, Nature's Majesty, Nature's Splendor, Eclipse, Shifting Power, Improved Shifting Power, Predatory Instincts, Natural Reaction, Rend and Tear, Berserk, Gift of the Earthmother, Living Spirit, Primal Bite, Wild Growth) viennent de SpellName ou SkillLineAbility seuls : lien talent non confirmé. Un seul ID pour plusieurs rangs : Nature's Majesty, Improved Shifting Power, Predatory Instincts, Rend and Tear, Living Spirit.
- Aura distincte du sort lancé : seulement celles de la section « Sorts déclenchés » du DB2 ; pour les autres HoT, DoT et buffs, seul l'ID du sort lancé est donné.
- Faerie Fire (Feral) : non trouvé (absent du DB2 70245).

### Écarts avec le DB2 client
Valeur du DB2 gardée dans les tableaux.
- Clearcasting : le fichier donnait 16870 et 467735 ; le DB2 montre Omen of Clarity 16864 → Clearcasting 16870. 467735 existe dans SpellName (« Clearcasting ») sans lien avec un sort druide (écart).
- Insect Swarm (talent 5570) : fichier = arbre Équilibre ; DB2 Talent.csv = Restauration (écart).
- Natural Shapeshifter : fichier = Restauration ; DB2 = Équilibre (écart).
- Nombre de rangs fichier ≠ DB2 : Improved Moonfire (2 vs 5), Overgrowth (2 vs 4), Feral Instinct (3 vs 5), Thick Hide (3 vs 5), Shredding Attacks (3 vs 2), Sharpened Claws (2 vs 3), Subtlety (3 vs 5) ; peut venir d'un correctif serveur (écarts).
- Tiger's Fury : fichier = absent de Forever ; DB2 SkillLineAbility Feral Combat = 5217 et 417045 (écart).
- Omen of Clarity, Natural Weapons, Improved Thorns, Feral Aggression, Improved Enrage, Improved Mark of the Wild, Nature's Grasp (talent) : donnés absents de Forever, présents dans le DB2 (écart ; présence ≠ actif).
- Aucun ID de sort de la table « Sorts de base » ne diffère du DB2 (nom et ID vérifiés) ; aucun absent du DB2.
- Omen of Clarity : passif niveau 20 sur endgametools (201 sorts) mais absent de la liste wow-forever.gg (212 sorts) et marqué absent de Forever par wowforevertalents.com. Même cas pour Nature's Grasp : sorts présents, talent « absent ».
- Ferocious Bite rang 5 (31018, niveau 60) : présent sur endgametools et wow-forever.gg, rangs 1-4 seulement sur wowforevertalents.
- Wowforevertalents : Primal Bite rangs 2-4, Wild Growth rangs 2-3, Insect Swarm rangs 2-5 ; le rang 1 est un talent.
- Niveaux de sorts talents (Insect Swarm 20, Moonkin 40, Swiftmend 1, Nature's Swiftness 1, Wild Growth 40, Primal Bite 25, Feral Charge 20) : valeurs de la liste wow-forever.gg, non cohérentes avec les paliers de talents (marqués « ID listé »).
- Primal Bite rang 1 : coût et recharge tirés des talents (20 rage, 6 s), pas d'une page de sort.
- Les formes requises par sort ne sont données par aucune source ; déduites seulement quand la source l'indique (Rejuvenation) ou par le coût en ressource.
- Swipe : rangs 1-5 = 779, 780, 769, 9754, 9908 (liste wow-forever.gg).
- Mana de base (%) et coûts à rang élevé : relevés tels que publiés, non testés en jeu.

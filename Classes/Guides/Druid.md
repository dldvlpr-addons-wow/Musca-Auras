# Druide — synthèse des guides WoW Forever (patch 1.60.1)

Notes courtes, reformulées, orientées auras. IDs pris dans `Classes/Druid.md`, sinon « ID absent de Classes/Druid.md ». Lecture du 2026-10-09.

## Sources lues

Icy Veins (4 pages) :
- https://www.icy-veins.com/wow-forever/druid-class-overview : Last Updated Sep 20, 2026 ; Meyra, Voulk (page d'accueil, sans rotation)
- .../balance-druid-ranged-dps-pve-guide : Oct 6, 2026 ; Voulk
- .../feral-druid-melee-dps-and-tank-pve-guide : Oct 7, 2026 ; Meyra
- .../restoration-druid-healer-pve-guide : Sep 18, 2026 ; Voulk

Wowhead Forever (`https://www.wowhead.com/forever/guide/classes/druid/...`, 16 pages) :
- balance/overview-pve-dps (2026/10/07, DrWonder), balance/dps-abilities (2026/10/08), balance/level-20-dps-overview (2026/10/09, DrWonder), balance/level-30-dps-overview (2026/10/09, DrWonder)
- feral/overview-pve-dps (2026/10/07, Lexolas), feral/dps-abilities (2026/10/08, Lexolas), feral/level-20-dps-overview (2026/09/29, Lexolas), feral/level-30-dps-overview (2026/10/06, Lexolas)
- feral/overview-pve-tank (2026/10/07, L0uki), feral/tank-abilities (2026/10/08, L0uki), feral/level-20-tank-overview (2026/09/29, L0uki), feral/level-30-tank-overview (2026/10/06, L0uki)
- restoration/overview-pve-healer (2026/10/07, Frankensteak), restoration/healer-abilities (2026/10/08, Frankensteak), restoration/level-20-healer-overview (2026/09/29, Frankensteak), restoration/level-30-healer-overview (2026/10/06, Frankensteak)

Pages absentes ou en échec : aucune. Non lu : guide de leveling Balance Icy Veins (hors demande).

## Balance (dps)

### Rotation / priorité
Niveau max (Wowhead + Icy Veins) :
1. Pré-cast Wrath (Wrath 5176…9912).
2. Maintenir Moonfire (8921…9835) puis Insect Swarm (5570 / 24974-24977) sur la cible.
3. Alterner Starfire (2912…25298, sort principal) et Wrath selon Eclipse ; proc Nature's Grace (16886) : incantation plus rapide, le placer sur Starfire.
4. En mouvement : Moonfire / Insect Swarm bas rang.
5. 2-4 cibles : dotter 2 cibles ; 5 et plus : Hurricane (16914/17401/17402).

Niveau 30 : hard-cast Wrath d'ouverture (accumule des charges Eclipse), Entangling Roots (339…), Starfire x2, Wrath, Starfire x2, répéter. Variante DoT : Insect Swarm, Moonfire, propager, Rejuvenation (774…25299) sur soi, Thorns (467…9910) pour le cleave.
Niveau 20 : Wrath à portée max, Moonfire, Entangling Roots, Wrath.
Icy Veins (bêta) : Moonfire puis Wrath, Insect Swarm dès le niveau 25 ; Hurricane niveau 40 (hors bêta).

### Procs et buffs à suivre
- Eclipse : IDs d'effet non départagés (408248, 408255, 409813, 441260, 1286115 selon Druid.md). Talent lié à la rotation Wrath/Starfire.
- Nature's Grace (16886), proc après critique non périodique.
- Clearcasting (16870), proc d'Omen of Clarity (talent 16864 ; Omen de base niveau 20 selon Wowhead). Le Moonkin double le taux de proc.
- Moonkin Form (24858) / Moonkin Aura (24907) : +5 % crit groupe (3 % sur la page Resto).
- Barkskin (22812), Innervate (29166).
- Nature's Splendor (ID absent de Classes/Druid.md ; SpellName seul 1223083) prolonge DoT/HoT : suivre la durée réelle plutôt qu'une constante.

### Debuffs à maintenir sur la cible
- Moonfire (8921…9835), DoT 12 s.
- Insect Swarm (5570 / 24974-24977), DoT 12 s, -2 % toucher cible.
- Faerie Fire (770/778/9749/9907) : réduction d'armure.
- Entangling Roots (339/1062/5195/5196/9852/9853) en contrôle ; Hurricane (canalisé 10 s) ralentit les attaques ennemies.

### Recharges importantes
Innervate (29166, 6 min), Barkskin (22812, 1 min), Nature's Swiftness (17116, 3 min), Tranquility (740/8918/9862/9863, 5 min selon Druid.md), Rebirth (20484/20739/20742/20747/20748, 30 min selon Druid.md), Hurricane.

### Ressources
Mana : facteur limitant en hard-cast. Moonglow (16845-16847) et Improved Wrath (16814-16818) baissent le coût. Stats : spell power, hit cap 16 %, crit (Vengeance), haste (n'accélère pas le tick des DoT), Intellect/Esprit secondaires.

### Talents clés
Improved Wrath (cast et coût), Eclipse, Nature's Splendor, Insect Swarm (Balance en Forever), Nature's Grace (16880), Vengeance, Improved Starfire (16850), Nature's Reach, Overgrowth (17245-17249) et Improved Entangling Roots (16918-16920) pour les racines multi-cibles, Moonglow.

### Mécaniques propres à Forever
- Eclipse nouveau (alternance Wrath/Starfire), Nature's Splendor nouveau.
- Entangling Roots utilisable en intérieur.
- Omen of Clarity de base, Insect Swarm dans l'arbre Balance.
- Wrath +50 % de dégâts de base après patch de la première semaine ; coefficients spell power Wrath 57,1 %, Starfire 100 %.
- Spellbear recommandé en leveling ; Thorns scale avec le spell power (coef. 6 %).
- Moonkin Aura et Leader of the Pack exclusifs entre eux.

## Feral (dps et tank)

### Rotation / priorité
Cat, niveau 30 (Wowhead Lexolas) :
1. Shifting Power (1322605) si aucun gaspillage (énergie < 50, pas de Clearcasting actif). Recharge 16 s, 8 s avec Improved Shifting Power (1322670).
2. Rip (1079…9896) à 4/5 points si la cible vit encore 6 s ou plus ; ne jamais réappliquer s'il est actif ; viser 5 points.
3. Rake (1822/1823/1824/9904), mêmes règles.
4. Faerie Fire (770…9907) si inactif et sans gaspiller d'énergie.
5. Shred (5221…9830) derrière la cible.
6. Claw (1082…9850) si pas derrière.
7. Faerie Fire pour tenter un Clearcasting.
Niveau 20 : 4/5 points et cible vivante 6 s : Rip, sinon Claw. Icy Veins : Shred pour les points, Rip quand la cible vit, Shifting Power à chaque recharge, Omen of Clarity sur Shred, Rake moins prioritaire. Ferocious Bite (22568…31018) rarement utilisé.

Bear tank (niveau max) :
1. Pré-pull Faerie Fire, Demoralizing Roar (99…9898) maintenu.
2. Primal Bite (407995/1238069/1238070/1238073) dès qu'il est prêt (recharge 6 s, 20 rage).
3. Lacerate (414644/1235826/1235827), empilable 5, menace élevée.
4. Swipe (779/780/769/9754/9908) en multi-cibles ; Maul (6807…9881) pour dépenser la rage en excès.
5. Omen of Clarity : dépenser sur Primal Bite, sinon Swipe/Maul.
Niveaux 10-20 : pré-cast Wrath, Bear Form, Demoralizing Roar, Swipe, Maul.

### Procs et buffs à suivre
- Clearcasting (16870).
- Berserk (effet : ID non départagé, candidat 417141) : 15 s, +100 % crit des générateurs de points, immunité Fear ; en Bear Primal Bite touche 3 cibles sans recharge.
- Enrage (5229) : 30 rage sur 10 s, réduit l'armure.
- Frenzied Regeneration (22842), Barkskin (22812), Dash (1850/9821, +60 % vitesse selon la plupart des pages), Prowl (5215/6783/9913).
- Leader of the Pack (17007 ou 24932, non départagés) : +3 % crit groupe.
- Natural Reaction (ID non départagé : 417051, 417053) : esquive et 5 rage.
- Blood Frenzy : proc de point de combo ou de rage (aura 16959).
- Elune's Light (Night Elf) : +10 % crit 15 s ; ID absent de Classes/Druid.md.

### Debuffs à maintenir sur la cible
Rip, Rake, Pounce (9005/9823/9827, bleed 18 s), Lacerate (5 charges), Faerie Fire (réduction d'armure, CD 6 s en forme sur la page tank), Demoralizing Roar (30 s), Bash (5211/6798/8983), Challenging Roar (5209).

### Recharges importantes
Shifting Power 16 s (8 s améliorée), Primal Bite 6 s, Feral Charge (1238122) 15 s, Berserk 3 min, Enrage 1 min, Bash 1 min, Frenzied Regeneration 3 min, Challenging Roar 10 min, Growl (6795, 8 s), Dash 5 min, Barkskin 1 min.

### Ressources
Énergie en Cat : Shifting Power convertit du mana en énergie (55 % du mana de base vers 40 énergie) ; l'utiliser sous 60 énergie (Icy Veins) ou 50 (Wowhead) pour ne rien perdre. Points de combo (Rip/Ferocious Bite). Rage en Bear : dégâts reçus, auto-attaques, Enrage, Natural Reaction, Blood Frenzy. Pas de powershift classique en Forever.

### Talents clés
Shifting Power et Improved Shifting Power, Primal Bite, Berserk, Rend and Tear, Leader of the Pack, Feral Charge, Feral Swiftness, Savage Fury, Shredding Attacks, Sharpened Claws, Blood Frenzy, Natural Reaction, Predatory Strikes/Instincts, Furor refondu (17056), Genesis, Natural Instinct, Naturalist.

### Mécaniques propres à Forever
- Primal Bite (la page ability dit « Mangle ») et Lacerate nouveaux en Bear.
- Shifting Power remplace le powershift ; Furor refondu.
- Omen of Clarity de base, Nature's Grasp de base niveau 10 lançable en forme, Revive de base.
- Tiger's Fury et King of the Jungle : voir Désaccords.
- Les formes scalent avec le DPS d'arme ; Thorns scale avec le spell power.
- Leader of the Pack exclusif avec le buff Moonkin.
- Consommables utilisables en forme.

## Restoration (healer)

### Rotation / priorité
Niveau max (Wowhead + Icy Veins) :
1. Thorns (467…9910) sur le tank avant le pull, Rejuvenation (774…25299) sur le tank et les cibles à risque.
2. Besoin de direct heal : Regrowth (8936…9858) pour poser le HoT, puis Healing Touch (5185…25297) bas rang pour combler. Si Regrowth déjà actif : Healing Touch.
3. Urgence : Swiftmend (18562), même sans HoT : Rejuvenation puis Swiftmend à 1 s ; sinon Nature's Swiftness (17116) + Healing Touch max rang.
4. Wipe imminent : Tranquility (740/8918/9862/9863).
5. Omen of Clarity : dépenser sur Regrowth ou Healing Touch max rang (et Wild Growth).
6. Mana confortable : Moonfire puis Wrath, Insect Swarm en Deep Balance, Entangling Roots sur un mob éloigné.
7. Attendre sans lancer pour la régénération (règle des 5 s).

### Procs et buffs à suivre
Clearcasting (16870), Nature's Grace (16886, +10 % haste 3 s), Nature's Swiftness (17116), Rejuvenation / Regrowth / Wild Growth (408120/1238214/1238215) sur les alliés, Thorns sur le tank, Innervate (29166), Barkskin (22812), Elune's Light (ID absent de Classes/Druid.md).

### Debuffs à maintenir sur la cible
Peu : Moonfire, Insect Swarm en Deep Balance, Entangling Roots (CC). Faerie Fire possible mais hors rôle.

### Recharges importantes
Swiftmend (15 s), Nature's Swiftness (3 min), Tranquility (5 min ; 2 min avec Improved Tranquility), Wild Growth (6 s), Innervate (6 min), Barkskin (1 min), Rebirth (30 min selon Druid.md).

### Ressources
Mana : HoT efficients, direct heals espacés, Reflection (17106-17108, régénération en incantation jusqu'à 50 %), Nature's Focus (17063-17068), Innervate. Cat Form pour regagner du mana en Deep Restoration. Haste raccourcit les casts, pas les ticks de HoT. Crit soins +50 %, HoT peuvent critiquer.

### Talents clés
Swiftmend, Nature's Swiftness, Improved Tranquility (CD 2 min), Gift of the Earthmother (414673 : GCD à 1 s pour Rejuvenation, Swiftmend, Wild Growth), Genesis (+5 % HoT), Nature's Majesty, Reflection, Gift of Nature, Improved Rejuvenation, Nature's Splendor, Nature's Focus, Subtlety, Heart of the Wild, Living Spirit.

### Mécaniques propres à Forever
- Wild Growth nouveau (HoT AoE limité au groupe de la cible, dégressif).
- Swiftmend soigne la durée totale du HoT sans le consommer.
- HoT critiques ; Omen de base, déclenchable sur sorts.
- Pas de Lifebloom, Nourish, Efflorescence ni Tree of Life ; pas de dissipation magie/maladie (Abolish Poison 2893/3137 et Remove Curse 2782 seulement)
- Thorns scale avec le spell power ; Moonglow n'affecte que les dégâts ; Moonkin sans soins.
- Quêtes de classe : Bear niveau 10, Cure Poison 14, Aquatic 16, Cat 20.

## Idées d'auras
- Rejuvenation / Regrowth / Wild Growth / Thorns : HoT et buff sur alliés avec durée restante (Nature's Splendor allonge).
- Swiftmend et Nature's Swiftness : recharge et disponibilité.
- Clearcasting (16870) : alerte forte pour tous les spés.
- Moonfire / Insect Swarm sur la cible avec timer ; Eclipse et Nature's Grace en proc (IDs d'effet à confirmer en jeu).
- Cat : énergie, points de combo, Rip / Rake / Faerie Fire sur la cible, Shifting Power en recharge et seuil < 60 énergie, Berserk.
- Bear : rage, Primal Bite recharge 6 s, Lacerate piles, Demoralizing Roar, Enrage.
- Tranquility, Innervate, Barkskin, Rebirth : recharges défensives.

## Désaccords entre sources
- Rebirth : recharge 20 min (Balance, Resto) contre 30 min (Feral, Druid.md).
- Barkskin : 12 s (Balance, Resto) contre 15 s (tank, Druid.md).
- Tranquility : recharge 10 min (Balance), 5 min (Feral, Resto, Druid.md) ; durée 8 s (Balance, Resto) contre 10 s (Feral, Druid.md).
- Dash : +60 % (Balance, Feral) contre +70 % (Resto).
- Moonkin crit groupe : 5 % (Balance, Feral) contre 3 % (Resto).
- Insect Swarm : 16 points Balance (page Balance) contre 11 (page Resto).
- Entangling Roots : extérieur seulement (Feral DPS) contre utilisable en intérieur (autres pages).
- Nature's Grasp : lançable en forme (Feral) contre extérieur seulement (Resto).
- Mark of the Wild : 30 min, 60 min ou 1 h selon la page.
- Hurricane : -20 % vitesse (Feral DPS) contre +25 % intervalle d'attaque (Balance, Resto).
- Primal Bite appelé Mangle sur la page tank-abilities.
- Leader of the Pack : 21 points (page tank) contre niveau 30 (Icy Veins).
- Tiger's Fury et King of the Jungle : cités par Wowhead Feral (CD 30 s, +15 % dégâts, +60 énergie), absents des rotations Icy Veins. Druid.md : Tiger's Fury absent en jeu (confirmé ; lignes 5217/417045 jamais apprises). Ne pas suivre Tiger's Fury ; ID absent de Classes/Druid.md. King of the Jungle : ID absent de Classes/Druid.md.
- Omen of Clarity : de base niveau 20 (Wowhead) ; Druid.md le signale absent de la liste de sorts wow-forever.gg ; le proc Clearcasting 16870 reste l'ID à suivre.

## Sorts cités sans ID trouvé
Tiger's Fury, King of the Jungle, Elune's Light, Nature's Splendor (SpellName seul 1223083 non confirmé comme sort), Eclipse (candidats non départagés), Berserk (candidat 417141 non confirmé), Natural Reaction (candidats non départagés), Genesis (candidats non départagés), Furor effet (non départagé), Omen of Clarity sort (seul le proc 16870 est tranché), Improved Tranquility, Nature's Majesty, Gift of Nature, Improved Rejuvenation, Subtlety, Heart of the Wild, Living Spirit, Vengeance, Natural Instinct, Naturalist, Feral Swiftness.

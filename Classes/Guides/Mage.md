# Guides Forever 1.60.1 : Mage

Synthèse orientée auras, reformulée en notes courtes. IDs tirés de `Classes/Mage.md` ; sinon « ID absent de Classes/Mage.md ». Aucun ID inventé.

## Sources lues (16 pages, 0 échec, 0 absente)

Icy Veins (dates « Last Updated ») :
- Mage, vue d'ensemble de la classe : 27 sept. 2026 (gizka)
- Mage Arcane : 19 sept. 2026 (gizka ; changelog au 24 sept.)
- Mage Fire : 19 sept. 2026 (gizka ; changelog au 24 sept.)
- Mage Frost : 1er oct. 2026 (Teloril)

Wowhead Forever (`https://www.wowhead.com/forever/guide/classes/mage/<spé>/<page>`) :
- arcane : overview-pve-dps, dps-abilities, level-20-dps-overview, level-30-dps-overview. Auteur Foolipe. Dates : overview 2026/10/07, abilities 2026/10/08, level-20 2026/09/29, level-30 2026/10/06.
- fire : overview-pve-dps, dps-abilities, level-20-dps-overview, level-30-dps-overview. Auteur Foolipe. Dates : overview 2026/10/07, abilities 2026/10/08, level-20 2026/09/29, level-30 2026/10/06.
- frost/overview-pve-dps : Porom, 2026/10/08.
- frost/dps-abilities : Porom, 2026/10/08.
- frost/level-20-dps-overview : Porom, 2026/09/29.
- frost/level-30-dps-overview : Foolipe, 2026/10/07.

Toutes les sources parlent de la bêta (niveau max 30), build 1.60.1. Tout peut encore changer.

## Arcane (DPS)

### Rotation / priorité
Niveau 30 :
1. Arcane Blast (400574 rang 1 talent ; 1239696, 1239697, 1239699, 1239700). Ne pas monter haut en stacks hors boss (Wowhead : 2 max ; Icy Veins : 2-3).
2. Arcane Missiles (5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345) dès que Missile Barrage proc.
3. Sinon Fire Blast (2136, 2137, 2138, 8412, 8413, 10197, 10199) pour remettre les stacks à zéro.
4. Baguette (Wand/Shoot : ID absent de Classes/Mage.md) pour finir.

Niveau 20 : Blast jusqu'à 2-3 stacks puis Missiles ; la baguette reste compétitive. Ouverture solo possible à Frostbolt (116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304).

AoE : pré-cast Flamestrike (2120, 2121, 8422, 8423, 10215, 10216) puis spam Arcane Explosion (1449, 8437, 8438, 8439, 10201, 10202). Groupes : Blizzard (10, 6141, 8427, 10185, 10186, 10187). Pack engagé : Frost Nova (122, 865, 6131, 10230) + Cone of Cold (120, 8492, 10159, 10160, 10161).

### Procs et buffs à suivre
- Stacks d'Arcane Blast : ID de l'aura non tranché dans Mage.md (candidats 400573, 400586, 401729, 1300176, 1300177). Chaque stack booste le sort suivant (+10 %) et le coût (+175 % par stack, 4 max). Un autre sort efface les stacks. Le buff améliore aussi le prochain sort de zone (Icy Veins).
- Missile Barrage : Arcane Missiles gratuit, canalisation deux fois plus rapide. ID non tranché (candidats 400588, 400589, 401736, 467409). Pas de Talent ID. Wowhead niveau 30 : 12 % de chance de ne pas proc même après 4 Blasts.
- Clearcasting (12536, 15 s), via Arcane Concentration (11213, 12574, 12575, 12576, 12577). Wowhead : bugué, proc par cible touchée.
- Arcane Power (12042) : +30 % dégâts et +30 % coût pendant 15 s.
- Arcane Intellect (1459, 1460, 1461, 10156, 10157) / Arcane Brilliance (23028) à garder actif.
- Armure : Frost Armor (168, 7300, 7301) contre physique, Mage Armor (6117, 22782, 22783) pour la régénération. Ice Armor (7302, 7320, 10219, 10220) remplace Frost Armor (niveau non indiqué). Icy Veins cite Mage Armor au niveau 34 ; Frost/Ice/Mage Armor s'excluent mutuellement.
- Mana Shield (1463, 8494, 8495, 10191, 10192, 10193) : ne pas le garder par défaut.

### Debuffs à maintenir sur la cible
Aucun debuff d'entretien pour Arcane dans les guides.

### Recharges importantes
- Arcane Power (12042) : 3 min.
- Evocation (12051) : 8 min.
- Counterspell (2139) : 30 s, silence 10 s selon Wowhead.
- Fire Blast : 8 s.
- Mana gems : Agate 759, Jade 3552, Citrine 10053, Ruby 10054 (Wowhead cite le Mana Ruby ; gemmes dès le niveau 28 selon Icy Veins).
- Outils de mana raciaux : Ley Line (Read Ley Line : ID absent de Classes/Mage.md), Cannibalize (ID absent de Classes/Mage.md).

### Ressources
- Le mana est la ressource centrale : finir les combats proche de 0.
- Stacks d'Arcane Blast = coût croissant.
- Arcane Meditation (18462, 18463, 18464) : 50 % de régénération en lançant (100 % avec Mage Armor).

### Talents clés qui changent le jeu
- Arcane Concentration (11213, 12574, 12575, 12576, 12577)
- Arcane Mind (11232, 12500, 12501, 12502, 12503) : +100 % dégâts critiques Arcane
- Arcane Focus (11222, 12839, 12840, 12841, 12842) : refondu, 1 % par point, 5 % max
- Arcane Meditation (18462, 18463, 18464)
- Presence of Mind (12043), Arcane Power (12042)
- Incineration (18459, 18460) : s'applique aussi à Arcane Blast et Ice Lance
- Wand Specialization (6057, 6085) : temporaire, utile jusqu'à 30
- Missile Barrage : pas de Talent ID, débloqué niveau 25 (Icy Veins)
- Build niveau 30 (Icy Veins) : 21 points Arcane

### Mécaniques propres à Forever
- Arcane Blast (nouveau, niveau 20) et Missile Barrage (niveau 25), absents de Classic.
- Flamestrike : les rangs ne se chevauchent plus.
- Quête de baguette (Nether Force Wand) au niveau 30.
- Comprehend Scroll : système de parchemins réservé aux mages (ID candidat 1296017 non tranché).

## Fire (DPS)

### Rotation / priorité
Niveau 30 (Wowhead) :
1. Scorch (2948, 8444, 8445, 8446, 10205, 10206, 10207) x5 sur une cible à beaucoup de vie.
2. Fireball (133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306).
3. Pyroblast (11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809) quand Heating Up est empilé.

Icy Veins : ouverture Pyroblast (Fireball avant 20), puis Fireball, Fire Blast pour finir et consommer Wake of Fire. Frostfire Bolt (401502, 1237312, 1237313) remplace Fireball au niveau 40 ; Frostbolt seulement pour le ralentissement.

Niveau 20 : pré-cast Pyroblast, Fireball.

AoE : pré-cast Flamestrike puis Arcane Explosion ; Blast Wave (11113, 13018, 13019, 13020, 13021) en groupe tanké.

### Procs et buffs à suivre
- Heating Up (Icy Veins : Hot Streak) : empile jusqu'à 3, -25 % temps d'incantation de Pyroblast par stack. Pas de Talent ID ; candidats 400624, 400625, 460878 non tranchés. « Hot Streak » : ID absent de Classes/Mage.md.
- Wake of Fire (11078, 11080, 12342) : après un kill, prochain Fire Blast à +50 % crit et -2 s de recharge.
- Combustion (11129, aura 28682) : +10 % crit par coup, jusqu'à 3 crits (Wowhead overview) ou 4 (page abilities).
- Impact (11103, aura 12355).
- Armures et Arcane Intellect comme Arcane.

### Debuffs à maintenir sur la cible
- Ignite (talent 11119, 11120, 12846, 12847, 12848) : 40 % des dégâts du crit sur 4 s, personnel, ne se cumule pas entre mages. ID du debuff non tranché (candidats 3261, 412538, 412545, 1234540).
- Fire Vulnerability (22959, 30 s, +4 %) via Improved Scorch (11095, 12872, 12873). Personnel, jusqu'à +15 % dégâts de Feu. Obligatoire au 60 (Icy Veins).

### Recharges importantes
- Combustion (11129).
- Fire Blast : 8 s (réduit de 2 s par Wake of Fire).
- Blast Wave : 45 s.
- Evocation (12051) : 8 min.

### Ressources
- Mana, standard. Les baguettes sont très fortes jusqu'à 30.
- Hit : les talents donnent 5 % à chaque spé.
- Fire est faible à 30 faute de chance de crit (Wowhead).

### Talents clés qui changent le jeu
- Wake of Fire (11078, 11080, 12342)
- Improved Fireball (11069, 12338, 12339, 12340, 12341)
- Ignite (11119, 11120, 12846, 12847, 12848)
- Flame Throwing (11100, 12353)
- Burning Soul (11083, 12351)
- Improved Scorch (11095, 12872, 12873)
- Heating Up : pas de Talent ID
- Combustion (11129), Critical Mass (11115, 11367, 11368), Fire Power (11124, 12378, 12398, 12399, 12400), Master of Elements (29074, 29075, 29076), Incineration (18459, 18460)
- Build niveau 30 (Icy Veins) : 21 points Fire, dont Heating Up 1 et Blast Wave 1.

### Mécaniques propres à Forever
- Heating Up, Wake of Fire, Frostfire Bolt (Icy Veins attend qu'il contourne la résistance Feu en prenant l'école la plus basse), Felfire (24530).
- Ignite et Improved Scorch deviennent personnels.
- Quête de baguette : Ragefire Wand.

## Frost (DPS)

### Rotation / priorité
Niveau 30 :
1. Frostbolt en continu.
2. Fingers of Frost proc : annuler le cast en cours si le proc vient d'un Frostbolt terminé, puis Ice Lance (1312002 rang 1 ; 400640, 1240044, 1240045, 1240046, 1240047).
3. Frostbite proc : mettre Ice Lance en file après le prochain Frostbolt.
4. Cible gelée : Ice Lance tant que le gel dure.
5. Frost Nova (122, 865, 6131, 10230) pour geler soi-même et gagner de la place.
6. Cone of Cold après un Frostbolt si cible gelée (Shatter sur deux sorts).

Niveau 20 (Wowhead) : Blizzard (3+), Arcane Explosion si mobilité, Frost Nova généreux, Ice Lance sur cible gelée, Frostbolt puis Fire Blast pour finir ; baguette quand le mana est bas ou si la cible vous frappe.

AoE 3+ (Icy Veins) : Cone of Cold pour les procs, Ice Lance sur non-gelées pour brûler Fingers of Frost, puis sur gelées. 5+ : Cone of Cold à chaque recharge, Blizzard entre les casts, Arcane Explosion si aggro.
Wowhead niveau 30 propose Flamestrike en pré-cast puis Arcane Explosion.

### Procs et buffs à suivre
- Fingers of Frost : 15 % de chance sur Chill, le prochain sort traite la cible comme gelée, 15 s. Pas de Talent ID ; candidats 400647, 400669, 400670, 401741 non tranchés.
- Frostbite : proc à l'impact (talent 11071, 12496, 12497 ; aura de gel 12494).
- Clearcasting 12536 si Arcane Concentration (rare en Frost).
- Armures : Ice Armor (7302, 7320, 10219, 10220) ou Frost Armor.
- Ice Barrier (11426, 13031, 13032, 13033), Ice Block (11958) en défensif.

### Debuffs à maintenir sur la cible
- Chilled (12484) : Frostbolt donne un ralentissement garanti.
- Winter's Chill (aura 12579 ; talent 11180, 28592, 28593, 28594, 28595).
- Gel de Frost Nova : ID de l'état « Freeze » absent de Classes/Mage.md. Le gel casse au moindre dégât.

### Recharges importantes
- Frost Nova : 25 s.
- Cone of Cold : 10 s.
- Evocation (12051) : 8 min.
- Cold Snap (12472) : remet les recharges Frost à zéro (surtout PvP).
- Ice Block (11958).
- Aucun cooldown offensif en Frost.

### Ressources
- Mana, plus sûr qu'Arcane. Ice Lance sans recharge ni coût de stacks.
- Baguette en secours.
- Gemmes de mana (Agate 759).

### Talents clés qui changent le jeu
- Improved Frostbolt (11070, 12473, 16763, 16765, 16766)
- Elemental Precision (29438, 29439, 29440)
- Ice Shards (11207, 12672, 15047, 15052, 15053) : +100 % dégâts critiques Frost selon Icy Veins
- Shatter (11170, 12982, 12983, 12984, 12985) : réduit à 3 points
- Frostbite (11071, 12496, 12497)
- Permafrost (11175, 12569, 12571)
- Piercing Ice (11151, 12952, 12953)
- Improved Frost Nova (11165, 12475), Arctic Reach (16757, 16758)
- Fingers of Frost (pas de Talent ID, débloqué à 21 points)
- Cold Snap (12472), Ice Block (11958)
- Build niveau 30 (Wowhead) : 21 points. Variante avec 5 points legacy : Ice Block, Cold Snap, dernier point Fingers of Frost, fin d'Improved Frostbolt.

### Mécaniques propres à Forever
- Ice Lance (+300 % contre cible gelée, instantané, sans recharge), Fingers of Frost, Frostfire Bolt.
- Nerf Improved Blizzard : chill 15/25/40 % au lieu de 30/50/65.
- Le trick de Frostbolt rang 1 pour Frostbite est retiré (Wowhead), alors qu'Icy Veins le recommande encore.
- Shatter est à 3 points, Cold Snap plus bas dans l'arbre, le talent de hit coûte 2 points de plus pour 1 % de moins.
- Forces : contrôle, sécurité, mobilité. Faiblesses : aucun burst, immunités Frost.

## Idées d'auras

- Compteur de stacks d'Arcane Blast (0 à 4) avec alerte au seuil 2 ou 3 (ID de l'aura à trancher).
- Proc Missile Barrage : alerte « Arcane Missiles gratuit » (ID à trancher).
- Clearcasting (12536) : icône courte 15 s.
- Heating Up (Fire) : compteur 1 à 3 stacks avant Pyroblast (ID à trancher).
- Wake of Fire : rappel « Fire Blast boosté » après un kill.
- Ignite et Fire Vulnerability (22959) : durée restante sur la cible.
- Fingers of Frost : alerte « Ice Lance maintenant » (ID à trancher), 15 s.
- Cible gelée / Chilled (12484) / Winter's Chill (12579) : indicateur pour Ice Lance.
- Barre de recharges : Frost Nova (25 s), Cone of Cold (10 s), Fire Blast (8 s), Counterspell (30 s), Evocation (8 min), Arcane Power (3 min), Blast Wave (45 s), Cold Snap, Ice Block.
- Armure active (Frost, Ice ou Mage Armor) et Arcane Intellect manquants.
- Jauge de mana avec repère de fin de combat proche de 0 pour Arcane.

## Désaccords entre sources

- Stacks d'Arcane Blast : Icy Veins dit de pousser à 2-3 puis de purger avec Fire Blast ; Wowhead dit de ne pas dépasser 2 hors boss.
- Combustion : Wowhead Fire overview dit 3 crits, la page abilities dit 4.
- Wake of Fire : Icy Veins parle de « +50 % de crit » sur Fire Blast ; Wowhead ajoute -2 s de recharge et la condition « après un kill ».
- Frostbolt rang 1 en Frost : Icy Veins le recommande pour des ralentissements bon marché ; Wowhead niveau 30 indique que le proc de Frostbite par ce moyen est retiré.
- Heating Up (Wowhead) et Hot Streak (Icy Veins) : même mécanique, deux noms.
- Armure : Icy Veins cite Mage Armor au niveau 34 ; Ice Armor remplace Frost Armor (Wowhead, niveau non indiqué).
- Incineration et Arcane Focus : les rangs web diffèrent de la DB2 (voir « Écarts » dans `Classes/Mage.md`).

## Sorts cités sans ID dans Classes/Mage.md

Hot Streak, Read Ley Line, Cannibalize, Wand (Shoot), état Freeze (gel), Missile Barrage / Heating Up / Fingers of Frost / Ignite debuff / stacks Arcane Blast (candidats seulement, non tranchés). Arcane Barrage, Living Bomb, Icy Veins, Arcane Surge et Frozen Orb existent en DB2 mais ne sont pas cités par les guides.

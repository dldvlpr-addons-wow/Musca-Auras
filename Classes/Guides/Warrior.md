# Guerrier — synthèse des guides WoW Forever (patch 1.60.1, bêta, niveau max 30)

Synthèse orientée addon, reformulée. IDs issus uniquement de `Classes/Warrior.md`. Quand un ID manque : « ID absent de Classes/Warrior.md ».

## Sources lues

Icy Veins (préfixe `https://www.icy-veins.com/wow-forever/`), Last Updated Sep 27, 2026, auteur Abide, changelog 02 Oct 2026 (nouveaux talents) et 29 Sep 2026 (cap niveau 30) :
- `warrior-class-overview` (pas d'auteur dans le texte de la page, « Abide » en en-tête)
- `arms-warrior-melee-dps-pve-guide`
- `fury-warrior-melee-dps-pve-guide`
- `protection-warrior-tank-pve-guide`

Wowhead (préfixe `https://www.wowhead.com/forever/guide/classes/warrior/`) :
- `arms/overview-pve-dps` : shoop, 2026/10/07
- `arms/dps-abilities` : shoop, 2026/10/08
- `arms/level-20-dps-overview` : shoop, 2026/09/29
- `arms/level-30-dps-overview` : shoop, 2026/10/06
- `fury/overview-pve-dps` : Babyhoof, 2026/10/07
- `fury/dps-abilities` : Babyhoof, 2026/10/08
- `fury/level-20-dps-overview` : Babyhoof, 2026/09/29
- `fury/level-30-dps-overview` : Babyhoof, 2026/10/06
- `protection/overview-pve-tank` : Riyani, 2026/10/07
- `protection/tank-abilities` : Riyani, 2026/10/08
- `protection/level-20-tank-overview` : Riyani, 2026/10/02
- `protection/level-30-tank-overview` : Riyani, 2026/10/06

Total : 16 pages lues, 0 en échec ni absente. Guides en bêta, susceptibles de changer.

## Mécaniques communes Forever

- Rage normalisée (génération et dégâts découplés de l'arme). Swing timer intégré à l'interface.
- Tactical Mastery de base (1310185) : garde 10 Rage au changement de posture.
- Battle Shout (25289 rang 7 ; autres rangs 6673, 5242, 6192, 11549, 11550, 11551) : 3 min, à garder en permanence.
- Bloodrage (2687, aura 29131) entre les pulls.
- Victory Rush (402927) : buff « Victorious » après un kill (fenêtre 20 s), soin 10 % PV max, recharge 30 s. Victorious : ID absent de Classes/Warrior.md.
- Charge (11578 rang 3 ; 100, 6178 ; étourdissement 7922) génère de la Rage. Intercept (20252, 20616, 20617 ; étourdissements 20253, 20614, 20615) via la quête de Berserker Stance niveau 30.
- Stances : Battle 2457, Defensive 71, Berserker 2458 (passifs 21156, 7376, 7381). Berserker : +3 % crit, +10 % dégâts subis.
- Thunder Clap (11581 rang 6 ; 6343, 8198, 8204, 8205, 11580) : -20 % vitesse d'attaque (10 % en Classic), recharge 6 s, utilisable en Defensive.
- Demoralizing Shout (11556 rang 5 ; 1160, 6190, 11554, 11555) : 45 s ; plus de menace en Forever.
- Système Legacy : jusqu'à +5 points via « Talented » (ID absent de Classes/Warrior.md), 10 points Legacy requis.
- Retaliation (20230) niveau 20, recharge 15 min. Shield Wall (871) 60 % pendant 12 s, 15 min. Intimidating Shout (5246, aura 20511) niveau 22. Execute (5308 ; 20658, 20660, 20661, 20662 ; aura 26651) niveau 24.

## Arms (dps)

### Rotation / priorité
Niveau 30 (mono-cible, fusion des deux sources) :
1. Battle Shout (25289) permanent.
2. Bloodrage (2687) entre les pulls, Charge (11578) à l'engagement.
3. Rend (11574) tôt, pas sur cible mourante ; il scale avec la puissance d'attaque et peut critiquer.
4. Overpower (11585) après esquive, ou via le proc Bloodthrill.
5. Thunder Clap (11581).
6. Sunder Armor (11597) : 5 stacks selon Wowhead, 1 à 2 seulement selon Icy Veins.
7. Spearing Strike (1310222) : 15 Rage.
8. Slam (11605) juste après un coup blanc, hors tank.
9. Victory Rush (402927) quand Victorious est actif.
10. Heroic Strike (25286) en dépense de Rage excédentaire.
- Demoralizing Shout (11556) à l'engagement.

Multi-cible : Rend sur toutes les cibles, Thunder Clap, Sweeping Strikes (12292) quand Overpower est prêt (garder la Rage avant), Overpower, Sunder, Cleave (20569), Victory Rush.

Niveau 20 (Wowhead) : Battle Shout, Rend, Slam après un swing, Thunder Clap, Victory Rush, Heroic Strike ; AoE : idem plus Cleave.

### Procs et buffs à suivre
- Battle Shout (25289), Victorious (ID absent de Classes/Warrior.md).
- Proc Bloodthrill (1289682, talent Legacy) : chance d'Overpower pendant 6 s sur cible sous Rend.
- Sweeping Strikes (12292), 20 s, 5 attaques.
- Recklessness (1719) : 100 % crit 15 s, +20 % dégâts subis.
- Execute (aura 26651) sous 20 % PV.

### Debuffs à maintenir sur la cible
- Rend (11574), Deep Wounds (12162 sans aura dans le DB2 70532 ; talent 12834, 12849, 12867), Sunder Armor (11597, 5 stacks, 30 s), Thunder Clap (11581), Demoralizing Shout (11556), Hamstring (7373, -50 % 15 s).

### Recharges importantes
- Overpower (11585) partage sa recharge avec Revenge.
- Slam (11605) : 15 s (Wowhead) ou 18 s (endgametools, noté dans Classes/Warrior.md).
- Victory Rush 30 s ; Sweeping Strikes 20 s d'effet ; Recklessness ; Retaliation (20230) 15 min ; Shield Wall (871) 15 min ; Pummel (6554) 4 s d'interruption ; Shield Bash (1672) 6 s.

### Ressources
- Rage normalisée. Charge et Bloodrage (10 + 10 sur 10 s) en génèrent. Anger Management (12296) : 1 Rage toutes les 3 s en combat. Heroic Strike (25286) est un coup jaune.
- Stances : Battle pour Charge et Overpower ; Berserker pour Whirlwind (1680), Pummel, Intercept.

### Talents clés
- Improved Rend (12286, 12658, 12659), Deflection (16462 à 16466), Improved Overpower (12290, 12963), Improved Tactical Mastery (12295, 12676 à 12679), Anger Management (12296), Deep Wounds (12834, 12849, 12867), Two-Handed Weapon Specialization (12163, 12711 à 12714), Improved Hamstring (12289, 12668, 23695), Improved Thunder Clap (12287, 12665, 12666), Improved Slam (12862, 12330, 20497 à 20499), Spearing Strike (1310222), Sweeping Strikes (12292).
- Legacy : Bloodthrill (1289682).
- Weaponmaster : 1290261 (talent), 12281 (sort) ; Wowhead cite 12785 pour le même effet (non tranché).

### Mécaniques propres à Forever
- Spearing Strike (1310222) : 40 % des dégâts d'arme, +80 % contre Géants, Draconiques et cibles montées (démonte).
- Bloodthrill, Weaponmaster (fusion des spécialisations d'armes), Improved Slam (incantation réduite, ne remet plus le swing à zéro), Deep Wounds peut critiquer.
- Mortal Strike (12294 ; 21551, 21552, 21553) : indisponible au niveau 30 selon Wowhead.
- Execute convertit la Rage au-dessus de 15.
- Retaliation : plus de partage de recharge.

## Fury (dps)

### Rotation / priorité
Niveau 30 :
1. Battle Shout (25289), Bloodrage (2687), Charge (11578).
2. Demoralizing Shout (11556).
3. Victory Rush (402927).
4. Rend (11574) si la cible vit encore.
5. Overpower (11585).
6. Sunder Armor (11597) 1 à 2 fois (Icy Veins), seulement au-dessus de 70 % PV (Wowhead).
7. Execute (5308 ; 20662) : Wowhead l'inclut, Icy Veins le déconseille en leveling.
8. Heroic Strike (25286) / Cleave (20569) pour la Rage en excès, sans abuser.
- Hamstring (7373) en filler pour déclencher Flurry (Wowhead).
- Bloodthirst (23894) : 35 % de la PA (45 % avant) ; Whirlwind (1680) : en Berserker.

Niveau 20 : Rend si la cible vit, Overpower, Sunder au-dessus de 70 %, Heroic Strike / Cleave. Pas de dual-wield avant niveau 20.

### Procs et buffs à suivre
- Enrage (talent 12317, 13045 à 13048) : déclenché sur tout dégât direct reçu en Forever (au lieu des seuls crits). Aucun aura-ID tranché dans Classes/Warrior.md.
- Flurry (talent 12319, 12971 à 12974) : aura candidate 12966, tranché : 12966 (règle 3, départage Fojji, DB2 70245 relu le 2026-10-26). Conseillé en point Legacy.
- Death Wish (12328) : +20 % dégâts physiques, +5 % dégâts subis, 30 s, 3 min.
- Recklessness (1719), recharge 30 min en Forever.
- Raging Blows (1310315, Legacy) : Whirlwind à la main gauche.
- Unbridled Wrath : talent 12322, sort déclenché 12964 (chance de +1 Rage, armes à une main).
- Victorious, Furious Precision, Lingering Rage : ID absent de Classes/Warrior.md.

### Debuffs à maintenir sur la cible
- Rend (11574), Sunder Armor (11597), Thunder Clap (11581), Demoralizing Shout (11556), Hamstring (7373).
- Faerie Fire et Curse of Recklessness ne cumulent plus la réduction d'armure.

### Recharges importantes
- Death Wish 3 min, Recklessness 30 min, Bloodthirst (23894), Whirlwind (1680), Berserker Rage (18499), Pummel (6554), Piercing Howl (12323, ralentit 50 % pendant 6 s).

### Ressources
- Rage normalisée. Cruelty (12320, 12852, 12853, 12855, 12856) : +5 % crit. Unbridled Wrath ajoute de la Rage.
- Malus dual-wield : 19 %, miss 27 % ; Dual Wield Specialization (23584 à 23588) et Furious Precision : toucher main gauche.

### Talents clés
- Cruelty, Unbridled Wrath (12322), Dual Wield Specialization (23584 à 23588), Death Wish (12328), Enrage, Flurry, Piercing Howl (12323), Improved Berserker Rage (20500, 20501), Blood Craze (16487, 16489, 16492).
- Legacy : Raging Blows (1310315), Improved Berserker Rage, Improved Bloodrage (12301, 12818).

### Mécaniques propres à Forever
- Enrage sur tout dégât direct reçu ; Dual Wield Specialization +10 % toucher main gauche ; Bloodthirst réduit à 35 % PA ; Tactical Mastery de base ; Raging Blows ; Recklessness 30 min.

## Protection (tank)

### Rotation / priorité
Mono-cible, niveau 30 (Wowhead) :
1. Charge (11578) à l'engagement, Bloodrage (2687).
2. Shield Block (2565), neutre en Rage grâce à Shield Specialization.
3. Revenge (25288), proc fiable via Shield Block.
4. Thunder Clap (11581).
5. Demoralizing Shout (11556), seulement pour appliquer le debuff.
6. Sunder Armor (11597) en groupe ; 5 stacks sur les boss.
7. Rend (11574) si la menace est déjà haute.
8. Heroic Strike (25286) avec Rage en excès et 5 Sunder sur le boss.
- Execute (20662) sous 20 % : exige de quitter Defensive. À éviter avec Rage haute ou dégâts entrants forts.

Multi-cible : Charge, Bloodrage, Thunder Clap, Shield Block, Revenge, Demoralizing Shout, Rend sur plusieurs cibles, Cleave (20569) avec Rage en excès. Retaliation (20230) fort en AoE, surtout avec une arme à deux mains.

Icy Veins : ordre voisin, Rend avant Shield Block, Shield Block en recharge (+75 % blocage). Taunt (355) niveau 10, Challenging Shout (1161) niveau 26 (6 s, sans menace), Shield Wall (871) niveau 28.

### Procs et buffs à suivre
- Revenge disponible (proc après esquive, parade ou blocage).
- Shield Block (2565) : 7 s, 2 attaques bloquées.
- Shield Specialization (12298 à 12727) : Rage sur blocage, aura déclenchée 1310318.
- Master of Defense (1310316) : 5 Rage sur esquive ou parade avec bouclier.
- Anticipation (12297, 12750 à 12753) : +20 défense.
- Last Stand (12975, aura 12976, lien non établi).
- Battle Shout (25289).
- Heroic Strike en tant que buff : ID absent de Classes/Warrior.md.

### Debuffs à maintenir sur la cible
- Sunder Armor (11597, 5 stacks), Thunder Clap (11581), Demoralizing Shout (11556), Rend (11574).
- Menace de Sunder faible (10) en bêta, plus de tab-sunder.

### Recharges importantes
- Shield Wall (871) 60 %, 12 s, 15 min (Improved Shield Wall 12312, 12803 : -11 min, 4 min).
- Retaliation (20230), Last Stand (12975), Concussion Blow (12809), Shield Bash (1672), Taunt (355), Challenging Shout (1161), Disarm (676), Revenge (25288, partage avec Overpower).

### Ressources
- Rage normalisée ; Shield Specialization et Master of Defense en font la source principale. Improved Bloodrage (12301, 12818) +50 %. Focused Rage (29787) : -3 Rage sur coûts offensifs.
- Defensive Stance (71) : -10 % dégâts subis, +30 % menace. Vanguard (1310317, niveau 25) permet Charge en Defensive Stance (pas en combat) ; avant, passer par Battle Stance. Intercept niveau 30 en Berserker.

### Talents clés
- Shield Specialization (12298 à 12727), Improved Revenge (12797, 12799, 12800, +60 %), Master of Defense (1310316), Defiance (12303, 12788, 12789, 12791, 12792), Improved Thunder Clap (12287, 12665, 12666), Improved Bloodrage, Vanguard (1310317), Improved Rend (12286, 12658, 12659), Cruelty (12320 à 12856), Bastion (16538 à 16542), Improved Shield Wall, Focused Rage (29787), Improved Sunder Armor (12308, 12810, 12811), Concussion Blow (12809).
- Points Legacy : 2 Improved Sunder Armor, 3 Focused Rage (ou Cruelty).

### Mécaniques propres à Forever
- Thunder Clap en Defensive Stance ; Demoralizing Shout sans menace ; Revenge avec modificateur de puissance d'attaque ; Shield Block neutre en Rage ; Improved Disarm ; Tactical Mastery de base (10 Rage).
- Les effets thorns (Retribution Aura, Thorns) portent les dégâts en donjon ; le Guerrier n'en a pas : ID absent de Classes/Warrior.md.

## Idées d'auras

- Battle Shout actif ou manquant (25289).
- Victory Rush disponible : buff Victorious (ID absent de Classes/Warrior.md) et timer 20 s.
- Overpower / Revenge prêts (procs, recharge partagée).
- Slam après coup blanc (1240193, 11605) avec le swing timer.
- Rend / Sunder Armor / Thunder Clap sur la cible, avec le compteur de stacks Sunder.
- Execute utilisable (sous 20 %).
- Rage : seuil pour Heroic Strike / Cleave et jauge pour Sweeping Strikes.
- Enrage et Flurry (auras tranchées dans Classes/Warrior.md : Enrage 12880, Flurry 12966, départage Fojji).
- Death Wish, Recklessness, Sweeping Strikes (12292), Shield Block (2565) avec 2 charges.
- Cooldowns défensifs : Shield Wall (871), Last Stand (12975), Retaliation (20230).
- Stance courante (2457, 71, 2458), surtout pour le switch Intercept.

## Désaccords entre sources

- Rage sur crit : Wowhead Fury dit aucune Rage supplémentaire ; Wowhead Arms niveau 30 parle d'une Rage double sur crit dans la dernière bêta ; Icy Veins Fury dit que Cruelty augmente la Rage.
- Sunder Armor : Icy Veins Arms 1 à 2 stacks, pas sous 50 % PV ; Wowhead Arms niveau 30, 5 stacks maintenus ; Wowhead Fury, seulement au-dessus de 70 % PV.
- Slam : Icy Veins Arms l'inclut ; Wowhead Fury et Protection l'écartent ; recharge 15 s (Wowhead) contre 18 s (Classes/Warrior.md).
- Execute : Icy Veins le déconseille en leveling ; Wowhead Fury niveau 30 le met en rotation ; Wowhead Protection l'interdit en Defensive.
- Heroic Strike : Wowhead Fury en filler de Rage excédentaire ; Icy Veins Arms le présente comme coup jaune sans Rage.
- Weaponmaster : 1290261 / 12281 dans Classes/Warrior.md, 12785 cité par Wowhead.
- Mortal Strike : Wowhead Arms le dit indisponible au niveau 30, alors qu'il figure dans Classes/Warrior.md.
- Ordre Protection : Wowhead place Shield Block avant Revenge et Thunder Clap ; Icy Veins place Rend avant Shield Block.

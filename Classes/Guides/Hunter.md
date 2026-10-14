# Chasseur — synthèse des guides WoW Forever 1.60.1 (orientée auras)
Lu le 2026-10-09. IDs issus de `Classes/Hunter.md` (DB2 70245). « ID absent de Classes/Hunter.md » = aucun ID dans ce fichier. Guides basés sur la bêta : valeurs et bugs susceptibles de changer.

## Sources lues
Icy Veins (auteur : Impakt) :
- https://www.icy-veins.com/wow-forever/hunter-class-overview — Last Updated : Sep 20, 2026 (Impakt)
- https://www.icy-veins.com/wow-forever/beast-mastery-hunter-ranged-dps-pve-guide — Last Updated : Oct 5, 2026 (Impakt)
- https://www.icy-veins.com/wow-forever/marksmanship-hunter-ranged-dps-pve-guide — Last Updated : Oct 5, 2026 (Impakt)
- https://www.icy-veins.com/wow-forever/survival-hunter-melee-dps-pve-guide — Last Updated : Oct 5, 2026 (Impakt)

Wowhead Forever (auteur : Docoda, relecture Neteyes), préfixe https://www.wowhead.com/forever/guide/classes/hunter/ :
- beast-mastery/overview-pve-dps — Updated 2026/10/07
- beast-mastery/dps-abilities — Updated 2026/10/08
- beast-mastery/level-20-dps-overview — Updated 2026/09/29
- beast-mastery/level-30-dps-overview — Updated 2026/10/07
- marksmanship/overview-pve-dps — Updated 2026/10/07
- marksmanship/dps-abilities — Updated 2026/10/08
- marksmanship/level-20-dps-overview — Updated 2026/09/29
- marksmanship/level-30-dps-overview — Updated 2026/10/07
- survival/overview-pve-dps — Updated 2026/10/07
- survival/dps-abilities — Updated 2026/10/08
- survival/level-20-dps-overview — Updated 2026/09/29
- survival/level-30-dps-overview — Updated 2026/10/07

Absentes / en échec : aucune. Les liens du menu n'ont pas été relevés par script (retour vide) ; les 12 URLs prévues ont toutes répondu avec le bon titre.

## Général Chasseur (commun aux spés)
- Paliers : bêta niveau 30 max (système « Legacy » : jusqu'à 5 points de talent en plus). Niveau 60 non encore disponible. Sortie complète annoncée le 4 novembre.
- Auto Shot (75) : plus de cast caché de 0,5 s, continue pendant l'incantation d'autres sorts ; il faut rester immobile pour tirer. Wowhead/niv. 30 note que c'est « confirmé comme un bug » : risque de retour en arrière.
- Aimed Shot (19434, rangs 20900 à 20904) : de base (plus un talent), cast 2 s, recharge 6 s, partagée avec Multi-Shot (2643, plus de rangs).
- Pièges utilisables en combat ; recharge de base 30 s (Immolation 13795, Explosive 13813, Frost 13809, Freezing 1499).
- Familier : stats héritées (2 PV par Endurance, 30 % de l'armure, 10 % de la meilleure PA, 100 % du crit du joueur), évitement, plus de buffs d'autres classes. Bonheur et nourrir toujours présents (Feed Pet 6991). Chaque famille a une capacité propre (voir Classes/Hunter.md, table familier).
- Munitions : aucun changement, carquois/sac à balles (un sac en moins).
- Zone morte : cible à moins de 8 m = pas de tirs à distance.
- Aspects : un seul actif. Aspect of the Hawk (13165 … 25296) en combat ; Cheetah (5118) hors combat (dazed 15571 si touché) ; Aspect of the Beast (13161, 1299445 à 1299447) = aspect DPS mêlée.
- Rapid Fire (3045) : +attaque vitesse distance ET mêlée en Forever ; recharge réduite par des talents Précision.
- Raciales utiles : Night Elf Elune's Light (+10 % crit 15 s, 3 min ; ID absent de Classes/Hunter.md), Orc Blood Fury (2 min, distance et mêlée ; ID absent), Troll Berserking (ID absent). Humain : Sword Specialization +2 % crit, mais Wowhead BM note qu'il ne s'applique pas aux tirs (bug supposé, commentaires contraires).

## Maîtrise des bêtes (DPS à distance + familier)

### Rotation / priorité
Niveau max atteignable (30, Summon Hawk disponible dès 25) :
1. Hunter's Mark (1130 … 14325) avant le pull.
2. Familier attaque d'abord (capacités en auto-cast), puis Serpent Sting (1978 … 25295), à rafraîchir.
3. Summon Hawk (1293241 / 1293525 / 1293526 / 1293527) à chaque recharge, toujours 2 faucons actifs (max 2, 18 s chacun).
4. Aimed Shot (single) ou Multi-Shot (multi), intercalés.
5. Arcane Shot (3044 … 14287) : Summon Hawk partage sa recharge avec Arcane Shot (6 s). Cycle Wowhead : Hawk, Aimed/Multi, Hawk, Aimed/Multi, Arcane, Aimed/Multi, répéter. Icy Veins : Arcane Shot quand mana plein et 2 faucons actifs plus de 6 s.
6. Auto Shot en continu ; Disengage (781, 14272, 14273) si le familier perd l'aggro ; Mend Pet (136 … 13544) ; Feed Pet.
Niveau 20 : même liste sans Summon Hawk (Aimed/Multi + Arcane Shot à la recharge). Wowhead note Summon Hawk à 20 avec Legacy, 25 sans.

### Procs et buffs à suivre
- Aspect of the Hawk (13165, 14318 à 14322, 25296) en permanence en combat.
- Quick Shots (6150) : proc +30 % vitesse distance 12 s via Deadly Aspects / Improved Aspect of the Hawk (talent 19552 à 19556 ou 23559, non tranché dans Classes/Hunter.md).
- Frenzy (famil. 19615 ; talent 19621 à 19625) : bonus de vitesse d'attaque du familier sur crit, valeur non indiquée par les guides.
- Bestial Wrath (19574, 31 points) : effet et durée non indiqués par les guides (Wowhead : dégâts du familier accrus, familier incontrôlable) ; Wowhead : fenêtre de burst, à coupler avec Rapid Fire (3045) et Elune's Light.
- Summon Hawk : nombre de faucons actifs (0 à 2) et durée restante.
- Aspect of the Cheetah (5118) en déplacement.

### Debuffs à maintenir sur la cible
- Hunter's Mark (1130, 14323, 14324, 14325), durée 2 min (Classes/Hunter.md).
- Serpent Sting (1978, 13549 à 13555, 25295), durée 15 s (Classes/Hunter.md).
- Concussive Shot (5116), 4 s, utilitaire.

### Recharges importantes
- Summon Hawk / Arcane Shot (3044) : 6 s partagés.
- Aimed Shot / Multi-Shot : 6 s partagés.
- Bestial Wrath (19574) ; Rapid Fire (3045), 5 min (Classes/Hunter.md) ; Intimidation (19577) ; Disengage (781) 5 s (Classes/Hunter.md) ; Feign Death (5384) 30 s (Classes/Hunter.md).
- Valeur de recharge de Bestial Wrath : non publiée dans les guides ni dans Classes/Hunter.md.

### Ressources
- Mana : sorts à entretenir (Serpent Sting, Aimed Shot, Multi-Shot) ; en panne de mana, Auto Shot + familier restent efficaces.
- Focus du familier : Bestial Discipline (19590, 19592) +20 % régénération de focus ; Claw comme filler pour ne pas perdre de focus.
- Munitions : consommées par les tirs, à surveiller (carquois / sac).

### Talents clés
- Deadly Aspects / Improved Aspect of the Hawk (19552 à 19556, candidat) : meilleur talent à 5 points selon Icy Veins.
- Pathfinding (19559, 19560) : effet non indiqué par les guides.
- Unleashed Fury (19616 à 19620), Ferocity (19598 à 19602), Frenzy (19621 à 19625), Bestial Discipline (19590, 19592), Bestial Wrath (19574, à 31 points), Intimidation (19577), Improved Revive Pet (24443, 19575), Bestial Swiftness (19596), Hawk Eye (19498 à 19500).
- Focused Fire : ID absent de Classes/Hunter.md (+2 % dégâts joueur et familier tant que le familier est actif).
- Lethal Attacks / Lethal Shots (19426 … 19431, candidat).
- Icy Veins niv. 30 : Deadly Aspects, Pathfinding, Unleashed Fury max, Summon Hawk, Ferocity ; extra Legacy : Ferocity 5, Bestial Discipline 2, Frenzy 1.

### Mécaniques propres à Forever
- Summon Hawk : nouveau (équivalent « Murder of Crows »), 2 faucons max, recharge partagée avec Arcane Shot, touché par Unleashed Fury et Ferocity.
- Familier : scaling des stats, évitement, capacités par famille (Dust Cloud 1265899 à 1265904 réduit l'armure, Dismember 1264758 etc. réduit les soins, Mine! 1265054 etc. désarme, Swipe 1264494 etc. cleave).
- Aimed Shot de base ; Multi-Shot touche 3 cibles sans rangs ; Arcane Shot scale légèrement avec la PA ; Volley (1510, 14294, 14295) sans recharge ; Serpent Sting scale avec la PA.
- Improved Aspect of the Monkey (19549 … 24387) : +6 % esquive, 50 % de l'effet au familier. Intimidation : étourdit 3 s sur la prochaine attaque, crit garanti.
- Bug signalé (Wowhead niv. 30) : talents de dégâts du familier non fonctionnels ; meilleur familier PvE = chat rapide avec Claw rang 4.

## Précision (DPS à distance)

### Rotation / priorité
Niveau 30 et 20 (Wowhead, identiques) :
1. Hunter's Mark (1130 … 14325) si le temps le permet.
2. Serpent Sting (1978 … 25295).
3. Arcane Shot et Aimed Shot (single) ou Multi-Shot (multi) à la recharge.
Icy Veins : Hunter's Mark avant le pull, familier en premier, Serpent Sting, Aimed Shot à la recharge, Auto Shot en continu, Disengage si aggro, Arcane Shot si mana plein.
Sniper Shot (1310687 / 1310785 / 1310786) : sort de burst du talent de fin d'arbre, hors du niveau 30 (arbre profond).

### Procs et buffs à suivre
- Aspect of the Hawk en combat ; Quick Shots (6150) via Deadly Aspects.
- Rapid Fire (3045) ; Trueshot Aura (1299346, 1299348, 19506, 20905, 20906), buff de groupe 30 min : +50 PA distance seulement (plus de PA mêlée).
- Rapid Recuperation : ID absent de Classes/Hunter.md (Serpent Sting touche : 50 % régén mana en cast 15 s ; consommer Rapid Killing : 100 %).

### Debuffs à maintenir sur la cible
- Hunter's Mark, Serpent Sting (même IDs que BM). Scorpid Sting (3043, 20 s selon Classes/Hunter.md ; durée +45 s par Improved Stings) et Viper Sting (3034, 14279, 14280) utilitaires.

### Recharges importantes
- Aimed Shot / Multi-Shot 6 s partagées ; Arcane Shot 6 s ; Sniper Shot : cast 4 s, recharge 15 s selon Wowhead (aussi cité « 4 s de recharge » dans Icy Veins, voir Désaccords) ; Rapid Fire 5 min (Classes/Hunter.md), réduit par des talents Précision (Wowhead).

### Ressources
- Mana : Intelligence donne de la PA via Careful Aim (ID absent de Classes/Hunter.md) ; Rapid Recuperation pour la mana. Munitions identiques.

### Talents clés
- Lone Wolf (ID absent de Classes/Hunter.md) : +20 % dégâts sans familier actif. Rend les auras de familier inutiles dans cette config.
- Sniper Shot (talent de fin d'arbre), Trueshot Aura (19506), Mortal Shots (19485 à 19490), Improved Stings (ID absent), Rapid Recuperation (ID absent), Careful Aim (ID absent), Improved Tracking (nom DB2 de 24293 à 24295, candidat).
- Icy Veins niv. 30 : 21 points en Précision pour Lone Wolf + Trueshot Aura, build « donjon / AoE », pas un build général ; alternative BM avec Deadly Aspects. Wowhead : ne pas prendre Lone Wolf, un familier fait plus de dégâts.

### Mécaniques propres à Forever
- Aimed Shot de base, Sniper Shot nouveau (cast 4 s), Trueshot Aura affaibli (PA distance +50, 45 m), Scorpid Sting réduit la chance de toucher.
- Pas de bonus de groupe réel ; viabilité jugée douteuse par Wowhead.

## Survie (DPS de mêlée)

### Rotation / priorité
Niveau 30 (Wowhead, mêlée) :
1. Hunter's Mark, puis Serpent Sting (1978 … 25295).
2. Raptor Strike (2973, 14260 à 14266) en file dès qu'on est au contact.
3. Mongoose Bite (1495, 14269, 14270, 14271) > Strider Kick (1317257) > Counterattack (19306, 1242634, 20909, 20910) quand disponible au contact.
4. Strider Kick pour sortir de portée et intercaler Arcane Shot, Serpent Sting, Aimed Shot jusqu'au retour des recharges de Raptor Strike et Mongoose Bite.
5. Disengage si le familier perd l'aggro.
Niveau 20 : Hunter's Mark, Serpent Sting, Raptor Strike au contact, alterner distance et mêlée.
Icy Veins niv. 30 : même ordre (Raptor Strike à la recharge, Mongoose Bite dès qu'il est disponible, Strider Kick à la recharge). Variante à distance : celle des autres spés avec Arcane Shot.

### Procs et buffs à suivre
- Mongoose Bite utilisable : après une esquive, ou par Expose Prey (ID absent de Classes/Hunter.md), proc 10 % sur cible marquée, 5 s. Counterattack utilisable après une parade.
- Aspect of the Beast (13161, 1299445 à 1299447) : Quick Strikes (1299448).
- Resourcefulness (ID absent) : crit donne de la régénération mana 30 s.
- Strider Kick : bonus de vitesse de déplacement 3 s.

### Debuffs à maintenir sur la cible
- Hunter's Mark (1130 … 14325), Serpent Sting (1978 … 25295).
- Lacerating Strikes (ID absent) : saignement après Mongoose Bite (capstone). Lacerate (24118 à 24120, 1299332) : durée 21 s (Classes/Hunter.md).
- Wing Clip (2974, 14267, 14268) ralentit 10 s (Wowhead, Classes/Hunter.md) ; Entrapment : racine 5 s avec les pièges.

### Recharges importantes
- Raptor Strike 6 s, Mongoose Bite 5 s, Counterattack 5 s (Classes/Hunter.md) ; Strider Kick 8 s (Wowhead) ; pièges 30 s (réduits de 40 % par Survivalist's Discipline, ID absent), Deterrence (19263).

### Ressources
- Mana : Resourcefulness réduit de 60 % le coût des pièges et attaques de mêlée ; mana plus tendue sinon. Munitions : moins utilisées. Familier optionnel.

### Talents clés
- Savage Strikes (19159, 19160), Predator's Edge (ID absent : crit mêlée +30 %, main gauche +50 %), Strider Kick (1317257), Expose Prey, Resourcefulness, Survivalist's Discipline, Lacerating Strikes (IDs absents), Counterattack (19306 …), Survival Tactics (19376, 19377, candidat), Entrapment (19184, 19387 à 19390), Improved Wing Clip (19228 à 19235), Clever Traps (19239, 19245).
- Icy Veins niv. 30 : Savage Strikes, Predator's Edge 5/5, Strider Kick. Extra Legacy : Resourcefulness, Expose Prey, 1 point Survival Tactics.

### Mécaniques propres à Forever
- Spé de mêlée : Strider Kick (ne coupe pas les incantations), Mongoose Bite basé sur dégâts d'arme, Counterattack idem, Entrapment racine toujours.
- Improved Tracking : fusion Monster/Humanoid Tracking, +5 % dégâts contre le type suivi ; fonctionne avec tous les suivis.
- Wyvern Sting absent de Forever selon Classes/Hunter.md.
- Le spé ne devient efficace qu'autour du niveau 30-32 ; faible pour monter en niveau.

## Idées d'auras
- Statut du familier : présent / mort (Revive Pet 982), PV bas (Mend Pet 136 … 13544), bonheur (Feed Pet 6991), nombre de faucons (BM) et Frenzy (19615).
- Swing Auto Shot (75) et zone morte 8 m : barre de swing, indicateur « trop près ».
- Aspect actif et manquant (Hawk / Beast / Cheetah), avec Quick Shots (6150).
- Hunter's Mark et Serpent Sting (durée restante) sur la cible.
- Recharges : Summon Hawk / Arcane Shot (6 s), Aimed Shot / Multi-Shot (6 s), Sniper Shot, Rapid Fire (3045), Bestial Wrath (19574), pièges (30 s), Raptor Strike / Mongoose Bite / Strider Kick (Survie).
- Mongoose Bite ou Counterattack « utilisable » (proc d'esquive, de parade ou Expose Prey).
- Mana (Rapid Recuperation, Resourcefulness) et munitions restantes.
- Alerte aggro sur le joueur (Disengage 781), Feign Death (5384).

## Désaccords entre sources
- Arcane Shot en BM : Icy Veins le réserve à « mana plein avec 2 faucons actifs plus de 6 s » ; Wowhead l'insère dans un cycle fixe (Hawk, Aimed/Multi, Hawk, Aimed/Multi, Arcane, Aimed/Multi) parce qu'il partage la recharge de Summon Hawk.
- Sniper Shot : Icy Veins dit « recharge de 4 s » ; Wowhead : cast 4 s, recharge 15 s (cohérent avec Classes/Hunter.md : recharge 15 s).
- Lone Wolf (MM) : Icy Veins le prend en build « donjon / AoE » ; Wowhead le déconseille car un familier fait plus de dégâts.
- Aspect de mêlée / Hawk : Icy Veins mentionne Aspect of the Hawk pour Survie niv. 30 ; Wowhead indique Aspect of the Beast pour mêlée.
- Sword Specialization Humain : Icy Veins dit +2 % crit général (distance incluse) ; Wowhead (BM, MM) : ne s'applique pas à distance (bug supposé), les commentaires affirment le contraire.
- Valeur du familier à niveau 30 : Icy Veins « 80 % de la puissance du Chasseur » vient du familier et de l'attaque de base ; Wowhead : talents de dégâts de familier bugués en bêta.

## Sorts cités sans ID
Focused Fire, Lone Wolf, Rapid Recuperation, Careful Aim, Improved Stings, Predator's Edge, Expose Prey, Resourcefulness, Survivalist's Discipline, Lacerating Strikes, Elune's Light, Blood Fury, Berserking, Rapid Killing : tous marqués « ID absent de Classes/Hunter.md » ci-dessus. Quick Strikes (1299448) et Sniper Shot (1310687, 1310785, 1310786) ont un ID dans Classes/Hunter.md.

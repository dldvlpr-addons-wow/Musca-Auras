# Plan v2 du pack Guerrier (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Socle commun : `PLAN-AURAS-V2.md`. Règles v1 : `PLAN-AURAS-CLASSES.md`.
IDs de sort et d'aura : `Classes/Warrior.md` (DB2 1.60.1.70245) fait foi. Aucun nom, code ou chaîne repris des packs de référence.

Légende des états : **acquis** (trigger déjà testé en combat sur Forever), **à tester** (trigger natif, jamais vu en combat sur Forever), **bloqué** (journal de combat ou valeur secrète). Le pack v1 n'a jamais été importé en jeu : « acquis » désigne donc le type de trigger, pas l'ID.

## 1. Sources et spécialisations couvertes

- Arbres de talents Classic : Armes (Mortal Strike 12294, Sweeping Strikes 12292, Deep Wounds, Improved Overpower), Fureur (Bloodthirst 23881, Death Wish 12328, Enrage, Flurry, Dual Wield Specialization), Protection (Shield Slam 23922, Last Stand 12975, Concussion Blow 12809, Improved Shield Block).
- Références d'idées : Defcon (glows Bloodthirst et Whirlwind, Heroic Strike et Cleave en file, indicateur de posture, rappel Battle Shout), Fojji (trois barres par posture, procs Overpower et Revenge, Execute, Victory Rush), Luxthos (rangées, état grisé, alpha hors combat).
- Source décodée : pack Luxthos Warrior (Classic Era), version 5, analysé dans `ANALYSE-LUXTHOS.md`. Même moteur que le chaman, contenu propre au guerrier. Idées seulement.
- Styles de jeu : solo et niveaux 1 à 40 (sans talent de 30 points), donjon (Protection en tank, Fureur ou Armes en dégâts), raid (Sunder Armor, Thunder Clap, Demoralizing Shout, Execute).
- Variantes de chargement : par `spellknown` du talent de 30 points (Mortal Strike, Bloodthirst, Shield Slam) et par posture (Battle 2457, Defensive 71, Berserker 2458). Variante « Base » : aucun des trois talents connu.
- Slam rang 1 (1240193, niveau 20) et Victory Rush (402927) sont propres à Forever. Ils comptent comme sorts de base.

## 2. Tables par rangée

Colonnes : aura, décision changée, trigger Musca, IDs (tous les rangs), chargement, conditions et style, état. « CD » = Cooldown Progress (Spell), icône toujours visible. Style commun de `PLAN-AURAS-V2.md` section 3 appliqué partout : grisé en recharge, rouge hors de portée, bleu si rage insuffisante.

Chargement : classe WARRIOR pour toutes les auras. Les colonnes ne répètent que le reste.

### 2.1 Rappels (hors combat, cachés en zone de repos)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Battle Shout manquant | Relancer le cri avant le combat | Aura (Modern), player, HELPFUL, absent | 6673, 5242, 6192, 11549, 11550, 11551, 25289 | `spellknown` 6673 ; hors combat | icône 32, alpha 0,5 ; texte du temps restant rouge sous 30 s | acquis |
| Posture défensive absente | Repasser en Defensive avant un pull de tank | Stance/Form/Aura, Defensive absente | 71 | `spellknown` 23922 (Shield Slam) ; hors combat | icône de la posture, lueur pixel à l'apparition | à tester |

### 2.2 Effets (procs, buffs courts, debuffs posés sur la cible)

Les lignes « repli » deviennent inutiles si l'icône à double état marche (section 9, besoin 3) : le buff actif s'affiche alors dans l'icône de recharge.

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Overpower utilisable | Lancer Overpower après une esquive de la cible (repli : CD toujours visible, lueur quand utilisable) | Action Usable | 7384, 7887, 11584, 11585 | `spellknown` 7384 ; posture Battle | visible si utilisable ; lueur pixel à l'apparition | à tester |
| Revenge utilisable | Lancer Revenge après blocage, esquive ou parade (repli : CD toujours visible, lueur quand utilisable) | Action Usable | 6572, 6574, 7379, 11600, 11601, 25288 | `spellknown` 6572 ; posture Defensive | visible si utilisable ; lueur pixel | à tester |
| Execute utilisable | Passer en finisseur sous 20 % | Action Usable ; repli : Health, target, Show only below 20 % | 5308, 20658, 20660, 20661, 20662 | `spellknown` 5308 ; postures Battle et Berserker ; caché avec la variante Protection | visible si utilisable ; lueur pixel | à tester |
| Victory Rush utilisable | Utiliser le soin gratuit après un kill (20 s) | Action Usable | 402927 | `spellknown` 402927 | visible si utilisable ; texte de recharge natif | à tester |
| Enrage | Savoir que la hausse de dégâts est active | Aura (Modern), player, HELPFUL | 12880 (candidat, voir section 6) | `spellknown` 12317 | lueur pixel ; texte du temps restant | à tester |
| Flurry | Savoir que la vitesse d'attaque est accrue | Aura (Modern), player, HELPFUL | 12966 (candidat, voir section 6) | `spellknown` 12319 | lueur pixel ; texte du temps restant | à tester |
| Blood Craze | Savoir que la régénération après un coup critique subi est active | Aura (Modern), player, HELPFUL | 16488 (déclenché par 16487) | `spellknown` 16487 | lueur pixel ; décision faible, à garder en dernier | à tester |
| Sweeping Strikes actif (repli) | Cibler les ennemis proches pendant 20 s | Aura (Modern), player, HELPFUL | 12292 (12723 écarté) | `spellknown` 12292 | lueur pixel ; temps restant rouge sous 5 s | à tester |
| Death Wish actif (repli) | Caler les gros coups dans la fenêtre de 30 s | Aura (Modern), player, HELPFUL | 12328 | `spellknown` 12328 | lueur pixel ; temps restant rouge sous 5 s | acquis |
| Recklessness actif (repli) | Caler les gros coups dans la fenêtre de 15 s | Aura (Modern), player, HELPFUL | 1719 | `spellknown` 1719 | lueur pixel ; temps restant rouge sous 5 s | acquis |
| Shield Block actif (repli) | Savoir si les blocages sont garantis (7 s) | Aura (Modern), player, HELPFUL | 2565 | `spellknown` 2565 ; posture Defensive | lueur pixel ; temps restant rouge sous 3 s | acquis |
| Shield Wall actif (repli) | Savoir si la réduction de dégâts tient encore (12 s) | Aura (Modern), player, HELPFUL | 871 | `spellknown` 871 ; posture Defensive | lueur pixel ; temps restant rouge sous 3 s | acquis |
| Last Stand actif (repli) | Savoir si les PV bonus tiennent encore | Aura (Modern), player, HELPFUL | 12976 (12975 = sort sans aura) | `spellknown` 12975 | lueur pixel ; temps restant rouge sous 3 s | à tester |
| Rend sur la cible | Rafraîchir le saignement | Aura (Modern), target, HARMFUL, posé par le joueur | 772, 6546, 6547, 6548, 11572, 11573, 11574 | `spellknown` 772 ; variantes Armes et Base | grisé et alpha 0,5 si absent ; temps restant rouge sous 3 s | acquis |
| Sunder Armor sur la cible | Empiler jusqu'à 5 charges | Aura (Modern), target, HARMFUL, posé par le joueur | 7386, 7405, 8380, 11596, 11597 | `spellknown` 7386 ; variantes Protection, Armes, Fureur | charges en texte natif (à tester en combat) ; rouge sous 5 s | acquis |
| Thunder Clap sur la cible | Rafraîchir le ralentissement et la réduction de vitesse | Aura (Modern), target, HARMFUL, posé par le joueur | 6343, 8198, 8204, 8205, 11580, 11581 | `spellknown` 6343 ; variante Protection | grisé si absent ; rouge sous 3 s | acquis |
| Demoralizing Shout sur la cible | Rafraîchir la réduction de dégâts des mobs (45 s) | Aura (Modern), target, HARMFUL, posé par le joueur | 1160, 6190, 11554, 11555, 11556 | `spellknown` 1160 ; variante Protection | grisé si absent ; rouge sous 5 s | acquis |
| Hamstring sur la cible | Reposer le ralentissement sur un fuyard ou un joueur | Aura (Modern), target, HARMFUL, posé par le joueur | 1715, 7372, 7373, 23694 | `spellknown` 1715 ; variantes Base et Armes ; postures Battle et Berserker | grisé si absent ; rouge sous 3 s | acquis |

### 2.3 Principal (8 au plus par variante)

Toutes les icônes sont des CD, sauf indication. Spells par ID, tous les rangs ; suivi par nom pour que le rang appris soit pris.

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mortal Strike | Lancer en priorité (6 s) | CD | 12294, 21551, 21552, 21553 | `spellknown` 12294 (Armes) | rouge hors portée, bleu sans rage, grisé en recharge ; pas de lueur « prêt » | acquis |
| Bloodthirst | Lancer en priorité (6 s) | CD | 23881, 23892, 23893, 23894 | `spellknown` 23881 (Fureur) | idem | acquis |
| Shield Slam | Lancer en priorité (6 s) | CD | 23922, 23923, 23924, 23925 | `spellknown` 23922 (Protection) | idem ; nécessite un bouclier | acquis |
| Whirlwind | Lancer à chaque recharge (10 s, 4 cibles) | CD | 1680 | `spellknown` 1680 ; posture Berserker | idem | acquis |
| Slam | Lancer entre deux coups de mêlée (1,5 s) | CD | 1240193, 1464, 8820, 11604, 11605 | `spellknown` 1240193 ; variantes Base, Armes, Fureur | idem | acquis |
| Sweeping Strikes | Armer avant un combat à plusieurs cibles | CD (double état avec le buff, voir besoin 3) | 12292 | `spellknown` 12292 ; posture Battle | grisé en recharge | acquis |
| Death Wish | Lancer avec les gros cooldowns | CD (double état) | 12328 | `spellknown` 12328 (Fureur) | grisé en recharge | acquis |
| Recklessness | Lancer pour une fenêtre de 15 s | CD (double état) | 1719 | `spellknown` 1719 ; posture Berserker ; variantes Armes et Fureur | grisé en recharge | acquis |
| Thunder Clap | Ralentir et réduire la vitesse des mobs (6 s) | CD | 6343, 8198, 8204, 8205, 11580, 11581 | `spellknown` 6343 ; variantes Protection et Base ; posture Battle ou Defensive | idem | acquis |
| Shield Block | Déclencher avant un gros coup physique (5 s) | CD (double état) | 2565 | `spellknown` 2565 ; posture Defensive | idem | acquis |
| Heroic Strike en file | Savoir si le coup est armé sur le prochain swing | Queued Action | 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286 | `spellknown` 78 ; toutes variantes | lueur pixel quand armé ; repli : CD avec condition ressource insuffisante | à tester |

Composition par variante (maximum 8) :

- **Armes** (6) : Mortal Strike, Whirlwind, Slam, Sweeping Strikes, Recklessness, Heroic Strike en file.
- **Fureur** (6) : Bloodthirst, Whirlwind, Slam, Death Wish, Recklessness, Heroic Strike en file.
- **Protection** (4) : Shield Slam, Thunder Clap, Shield Block, Heroic Strike en file.
- **Base** (4) : Slam, Whirlwind, Thunder Clap, Heroic Strike en file.

### 2.4 Débordement (au-delà de 8, ou second rang)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Cleave en file | Passer à Cleave quand plusieurs cibles sont proches | Queued Action ; repli : CD avec ressource insuffisante | 845, 7369, 11608, 11609, 20569 | `spellknown` 845 ; toutes variantes | lueur pixel quand armé | à tester |
| Thunder Clap (Armes, Fureur) | Ralentir en groupe | CD | 6343, 8198, 8204, 8205, 11580, 11581 | `spellknown` 6343 ; variantes Armes et Fureur ; posture Battle | idem Principal | acquis |

Aucune variante ne dépasse 8 en Principal : Débordement ne reçoit que ces deux icônes.

### 2.5 Utilitaires (défensifs, interruptions, contrôle, déplacements)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Pummel | Interrompre un lanceur (10 s) | CD | 6552, 6554 | `spellknown` 6552 ; posture Berserker | rouge hors de portée ; alpha 0,4 hors combat | acquis |
| Shield Bash | Interrompre un lanceur (12 s) | CD | 72, 1671, 1672 | `spellknown` 72 ; postures Battle et Defensive | rouge hors de portée | acquis |
| Charge | Fermer la distance ou ouvrir un pull | CD | 100, 6178, 11578 | `spellknown` 100 ; posture Battle | rouge hors de portée ; alpha 0,4 hors combat | acquis |
| Intercept | Fermer la distance en combat | CD | 20252, 20616, 20617 | `spellknown` 20252 ; posture Berserker | rouge hors de portée ; bleu sans rage | acquis |
| Berserker Rage | Briser peur ou incapacité | CD (double état) | 18499 | `spellknown` 18499 ; posture Berserker | grisé en recharge | acquis |
| Bloodrage | Gagner de la rage avant un pull | CD (double état avec le buff 29131) | 2687, 29131 | `spellknown` 2687 | grisé en recharge | acquis |
| Intimidating Shout | Fuite ou contrôle de groupe (3 min) ; second état : durée de la peur sur la cible | CD (double état, cible) | 5246 | `spellknown` 5246 | grisé en recharge ; lueur pixel tant que le débuff 20511 est sur la cible | à tester |
| Shield Wall | Réduire fortement les dégâts (15 min) | CD (double état) | 871 | `spellknown` 871 ; posture Defensive | grisé en recharge | acquis |
| Last Stand | Gagner des PV en urgence | CD (double état avec le buff 12976) | 12975, 12976 | `spellknown` 12975 | grisé en recharge | acquis |
| Retaliation | Renvoyer les coups de mêlée (15 min) | CD (double état) | 20230 | `spellknown` 20230 ; posture Battle | grisé en recharge | acquis |
| Taunt | Reprendre l'aggro (8 s) | CD | 355 | `spellknown` 355 ; posture Defensive ; variante Protection | rouge hors de portée | acquis |
| Challenging Shout | Reprendre l'aggro de groupe (10 min) | CD | 1161 | `spellknown` 1161 ; variante Protection | grisé en recharge | acquis |
| Concussion Blow | Étourdir un lanceur ; second état : étourdissement sur la cible | CD (double état, cible) | 12809 | `spellknown` 12809 ; variante Protection | rouge hors de portée ; lueur pixel tant que le débuff est sur la cible | à tester |
| Disarm | Désarmer un mob dangereux (1 min) ; second état : désarmement sur la cible (10 s) | CD (double état, cible) | 676 | `spellknown` 676 ; posture Defensive | rouge hors de portée ; lueur pixel tant que le débuff est sur la cible | à tester |
| Mocking Blow | Reprendre l'aggro à distance de mêlée (2 min) | CD | 694, 7400, 7402, 20559, 20560 | `spellknown` 694 ; posture Battle ; variante Protection | rouge hors de portée | acquis |
| Piercing Howl | Ralentir un groupe | CD | 12323 | `spellknown` 12323 | grisé en recharge | acquis |

### 2.6 Entretien (buffs longs, posture)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Battle Shout (entretien) | Relancer le cri sous 30 s en combat | Aura (Modern), player, HELPFUL, durée restante | 6673, 5242, 6192, 11549, 11550, 11551, 25289 | `spellknown` 6673 | toujours visible ; grisé et alpha 0,5 si absent ; texte rouge sous 30 s | acquis |
| Posture Battle | Savoir dans quelle posture on est | Stance/Form/Aura | 2457 | posture Battle | icône 32 sans texte ; une seule des trois visible | à tester |
| Posture Defensive | idem | Stance/Form/Aura | 71 | posture Defensive | idem | à tester |
| Posture Berserker | idem | Stance/Form/Aura | 2458 | posture Berserker ; `spellknown` 2458 | idem | à tester |

### 2.7 Ressource

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Barre de rage | Savoir si Heroic Strike, Execute ou le gros coup sont payables | Power, player, rage (type 1) | — | classe | 390x18, rouge, fond noir 50 %, texte `%p` natif ; repères fixes à 15 et 30 (voir section 9, besoin 4) | acquis |

### 2.8 Secondaire

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Swing main hand | Caler Heroic Strike et Slam sur le swing | Swing Timer, main hand | — | classe | 390x10 ; orange en combat, gris translucide hors combat (condition `incombat` sur la couleur, besoin 8) ; étincelle cachée quand la barre est vide | acquis |
| Swing off hand | Même calage en double main | Swing Timer, off hand | — | `spellknown` 23584 (Dual Wield Specialization) ou posture Berserker | 390x6 sous la barre principale ; masquée sans seconde arme | à tester |

### 2.9 Incantation

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Incantation du joueur | Voir la fin de Slam (1,5 s) avant le swing suivant | Cast, player | 1240193, 1464, 8820, 11604, 11605 | `spellknown` 1240193 | 390x16, visible pendant un cast seulement | à tester |

## 3. Variantes par spécialisation, posture ou talent

- **Chargement par talent** : Armes `spellknown` 12294 ; Fureur `spellknown` 23881 ; Protection `spellknown` 23922. Les trois talents sont exclusifs en pratique (30 points). Base : aucun des trois connu (condition « sort non connu » à vérifier dans Musca).
- **Chargement par posture** : Battle, Defensive, Berserker, une aura par variante dans la même rangée. Les auras sans condition de posture restent chargées dans les trois.
- **Ce qui change avec la posture** : Overpower, Mocking Blow, Retaliation, Charge, Sweeping Strikes en Battle ; Revenge, Shield Block, Shield Wall, Taunt, Disarm en Defensive ; Whirlwind, Pummel, Intercept, Berserker Rage, Recklessness en Berserker. Ces restrictions viennent des règles Classic, absentes de `Classes/Warrior.md` : à confirmer (section 6).
- **Armes à deux mains ou double main** : la barre de swing off hand dépend de Dual Wield Specialization (23584) ou de la posture ; sinon elle reste vide.
- **Ordre de décision en jeu** : variante de talent d'abord, posture ensuite. Un guerrier Fureur en Battle voit Overpower dans Effets et perd Whirlwind dans Principal.

## 4. Rappels

| Rappel | Trigger | Hors combat | Masqué en zone de repos |
|---|---|---|---|
| Battle Shout manquant | Aura (Modern), absent | oui | oui |
| Posture Defensive absente (Protection) | Stance/Form/Aura, absent | oui | oui |

Pas de rappel de poison, de familier, de munitions ou d'imbue : le guerrier n'en a pas. Les pierres à aiguiser ne figurent pas dans `Classes/Warrior.md` et sont exclues.

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Compteur de procs d'Enrage ou de Flurry sans aura (charges restantes) | bloqué : journal de combat |
| Gain de rage par coup reçu ou donné, minuteur de rage | bloqué : journal de combat |
| Swing déduit des coups parés ou reçus, repères d'annulation de Heroic Strike | bloqué : journal de combat et swing variable |
| Couleur de la barre de rage par seuil, son ou lueur à 15 rage | bloqué : comparaison d'une valeur secrète (repli : repères fixes, section 9) |
| Lueur « prêt » sur Heroic Strike quand la rage suffit | bloqué : comparaison d'une valeur secrète |
| Glows Bloodthirst et Whirlwind liés au nombre d'ennemis proches | bloqué : nombre de cibles, pas d'API sans code |
| Salvation en posture défensive | absent du DB2 de Classes/Warrior.md, exclu (sort d'une autre classe) |
| Silences de Shield Bash et Pummel sur la cible | aucun lien d'aura dans le DB2, exclu (recharge seule) |
| Mortal Strike (malus de soins) et Deep Wounds sur la cible | ne changent aucune décision : exclus par rapport à la v1 |
| Étourdissements de Charge (7922) et d'Intercept (20253, 20614, 20615) | ne changent aucune décision, exclus |
| Execute 26651, Unbridled Wrath 12964, Shield Specialization 1310318 | auras de gain de rage ou de régénération sans décision, exclues (Blood Craze 16488 reprise en Effets) |
| Buff d'une autre extension (50227, 57519) et sort de retail (190456) | absents du DB2 de Classes/Warrior.md, exclus |
| Buffs de force d'un autre buffeur (19740, 25782) comptés comme équivalents de Battle Shout | IDs d'une autre classe, absents de Classes/Warrior.md, exclus |
| Improved Cleave, Boundless Rage, Precision, Toughness | talents retirés par correctif d'après `Classes/Warrior.md` : aucun chargement sur eux |
| Lingering Rage, Furious Precision, Gore Drinker | absents du DB2 70245 : absent du DB2, exclu |
| Rallying Cry, Commanding Shout, Spell Reflection, Heroic Throw | absents de Classes/Warrior.md : absent du DB2, exclu |
| Pierres à aiguiser, bandages | objets hors `Classes/Warrior.md`, exclus |
| Icône « prochain meilleur sort » | exige une logique de priorité en code : exclue |

## 6. IDs à confirmer en jeu

| Aura | Candidats | Vérification |
|---|---|---|
| Enrage (buff) | 12880 retenu (seul porteur d'une aura 79) ; 12317 (talent) et 37 autres homonymes | Se faire frapper avec le talent, `/dump` de l'aura du joueur, noter l'ID réel |
| Flurry (buff) | 12966 retenu (aura 319) ; 12319 (talent), 15088, 16256, 16257 | Critiquer avec le talent, `/dump` de l'aura du joueur |
| Last Stand (aura) | 12976 retenu ; 12975 = sort lancé sans aura | Lancer Last Stand, lire l'ID de l'aura |
| Sweeping Strikes (aura) | 12292 retenu ; 12723 homonyme sans aura | Lancer le sort, lire l'ID ; durée attendue 20 s |
| Bloodrage (aura) | 29131 déclenché par 2687 | Lancer le sort, lire l'ID |
| Hamstring supplémentaire | 23694 (Improved Hamstring) | Vérifier qu'il remplace ou double 1715 |
| Victory Rush | 402927 (usable) ; 403434 homonyme non lié | Tuer un mob, vérifier que 402927 devient utilisable pendant 20 s |
| Weaponmaster | 3 talents homonymes Armes ; 12281 aussi en sort niveau 1 | Aucune aura utile : ne rien charger dessus |
| Bloodthrill (1289682) | proc d'Overpower, aura inconnue | Vérifier si une aura apparaît après une esquive ; sinon rester sur Action Usable |
| Spearing Strike (1310222) | nouveau sort Armes sans coût, recharge ni description | Lire l'infobulle et la recharge ; décider ensuite de l'ajouter à Armes |
| Raging Blows (1310315) | talent Fureur, effet non détaillé | Lire l'infobulle ; ajouter si c'est un sort à recharge |
| Slam rang 1 (1240193) | recharge 18 s inhabituelle, non recoupée | Lancer Slam, lire la recharge réelle |
| Restrictions de posture | règles Classic, absentes du fichier | Tester chaque sort dans les trois postures (section 7) |
| Charge rang 3 | coût 15 rage non recoupé | Lire le coût en jeu ; sans effet sur le trigger |
| Charges de Sunder Armor | texte natif en combat | Vérifier que les charges s'affichent malgré la valeur secrète |
| Posture d'Overpower | restriction de posture non recoupée ; le plan le charge en Battle | Tester Overpower dans les trois postures (section 7) |
| Blood Craze | 16488 retenu (déclenché par 16487) | Subir un critique avec le talent, `/dump` de l'aura du joueur |
| Second état sur la cible (Disarm 676, Concussion Blow 12809, Intimidating Shout 20511) | auras posées par le sort ou déclenchées par lui, selon le DB2 | Lancer le sort, lire l'ID du débuff sur la cible ; vérifier le mélange Cooldown Progress et `secretAura` cible |
| Chargement du swing | chargement prévu par classe seule, sans identifiant de spécialisation | Vérifier que le chargement par classe seule suffit |

## 7. Tests en jeu propres au guerrier (au-delà de la grille commune)

1. Changer de posture hors combat puis en combat : l'icône de posture suit, les auras chargées par posture apparaissent et disparaissent sans trou.
2. Overpower : esquive de la cible, l'icône apparaît dans Effets et disparaît après 5 s.
3. Revenge : blocage, esquive ou parade subis en Defensive, l'icône apparaît ; hors Defensive, elle reste cachée.
4. Execute : cible à 21 % puis à 19 %, l'icône apparaît sous 20 % seulement. Comparer Action Usable et le repli Health.
5. Victory Rush : tuer un mob, l'icône apparaît 20 s ; changer de posture pendant ce temps.
6. Heroic Strike et Cleave en file : armer, annuler, frapper ; l'icône suit l'état armé.
7. Swing off hand : 2 mains (barre masquée), puis double main (barre active) ; changement d'arme en combat.
8. Double état des cooldowns : lancer Recklessness, Death Wish, Shield Block ; l'icône passe de la recharge à la durée du buff puis revient.
9. Sunder Armor : empiler 5 charges en combat ; texte des charges lisible malgré la valeur secrète.
10. Rend et Thunder Clap posés pendant le combat : ils apparaissent sur la cible ; changer de cible et mourir ne laisse rien.
11. Rage : barre qui suit les gains en combat ; texte `%p` lisible ; repères fixes à 15 et 30.
12. Charge hors combat puis en combat : l'icône reste grisée en combat si Charge est verrouillée.
13. Chargement par talent : personnage sans talent (Base), puis avec Mortal Strike, Bloodthirst ou Shield Slam.
14. Slam : barre d'incantation visible 1,5 s ; recharge de 18 s correcte sur l'icône.
15. `/reload` en combat : toutes les icônes de Principal reviennent sans erreur BugSack.

## 8. Écart avec la v1 (`PackGuerrier.lua`, préfixe `mcWarrV1`)

**Ajouter**
- Second état sur la cible pour Disarm, Concussion Blow et Intimidating Shout (durée du débuff).
- Blood Craze en Effets ; Execute caché avec la variante Protection.
- Couleur de la barre de swing selon le combat.
- Chargement par posture sur toutes les auras concernées (v1 : aucun).
- Chargement par talent de 30 points et variante Base (v1 : tout chargé pour tous).
- Indicateur de posture (3 auras) en Entretien.
- Rangées Effets, Débordement, Utilitaires et Entretien (v1 : trois blocs seulement).
- Rappel de posture Defensive pour la variante Protection.
- Battle Shout en Entretien avec seuil de 30 s, en plus du rappel hors combat.
- Utilitaires manquants : Taunt, Challenging Shout, Concussion Blow, Disarm, Mocking Blow, Piercing Howl.
- Barre d'incantation (Slam) et repères fixes sur la barre de rage.
- Icône à double état pour les cooldowns longs.

**Changer**
- Overpower, Revenge, Execute, Victory Rush : passent de « procs » à Effets, chargés par posture.
- Heroic Strike et Cleave : Principal et Débordement, avec repli CD si Queued Action échoue.
- Rotation : Sunder Armor et Whirlwind déplacés selon la variante ; Sunder Armor devient un debuff d'Effets, plus une icône de recharge.
- Thunder Clap : Principal (Protection, Base) ou Débordement (Armes, Fureur).
- Swing off hand : chargement lié au double main.
- Auras « (actif) » : repli en Effets tant que le double état n'est pas validé.
- Overpower, Revenge, Execute : variante de repli en CD toujours visible avec lueur quand utilisable, si Action Usable échoue.

**Retirer**
- Deep Wounds (12162) et Mortal Strike (malus de soins) comme debuffs cible.
- Sweeping Strikes, Death Wish, Recklessness, Last Stand, Retaliation, Shield Wall, Shield Block, Berserker Rage, Bloodrage comme auras séparées, une fois le double état validé.
- Cooldown de Sunder Armor (sans recharge utile).

## 9. Besoins du générateur propres au guerrier

À ajouter à `PLAN-AURAS-V2.md` section 5 (le générateur actuel ne gère pas la posture) :

1. **Chargement par posture** : option `stance` (Battle, Defensive, Berserker) sur chaque entrée, par liste ou valeur unique. Vérifier d'abord que le chargement Stance/Form/Aura existe dans Musca.
2. **Indicateur de posture** : trois auras de même position, une visible par posture, sans trou dans la rangée Entretien.
3. **Icône à double état** (déjà au point 8 de la section 5) : indispensable ici pour 9 cooldowns longs. Sans elle, 9 auras « (actif) » restent en Effets.
4. **Repères fixes sur la barre de rage** : sous-régions de graduation à 15 et 30 rage, valeur fixe. Si Musca ne les gère pas, abandonner.
5. **Secondaire à deux barres** : swing main hand et off hand empilés (390x10 puis 390x6), la seconde masquée sans arme. Le générateur doit empiler les barres d'une rangée.
6. **Chargement « sort non connu »** pour la variante Base. À vérifier dans Musca.
7. **Repli de file** : une aura Heroic Strike ou Cleave avec Queued Action et un repli CD (ressource insuffisante), le repli étant choisi après le test en jeu.
8. **Couleur de barre selon le combat** : condition `incombat` qui change la couleur de la barre de swing (orange en combat, gris translucide hors combat). Classes concernées : Guerrier, Chasseur, Paladin.
9. **Double état sur la cible** : une aura Cooldown Progress + `secretAura` sur `target` (Disarm, Concussion Blow, Intimidating Shout). À vérifier avec le besoin 3.

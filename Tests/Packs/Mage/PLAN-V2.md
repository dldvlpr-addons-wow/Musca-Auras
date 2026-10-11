# Plan v2 du pack Mage (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Suit `PLAN-AURAS-V2.md` (socle commun) et son point 6.1.
Pack v1 : `Tests/Packs/Mage/PackMage.lua` (préfixe `mcMageV1`). Racine v2 : `Mage (Musca)`.

Conventions du tableau :

- **IDs** : `Classes/Mage.md` fait foi. Tous les rangs sont listés. Un sort absent du fichier est marqué « absent du DB2, exclu ».
- **État** : *acquis* = testé en jeu ; *à tester* = trigger natif, jamais vu en combat sur Forever ; *bloqué* = journal de combat ou lecture de valeur secrète.
  Aucune aura Mage n'a été testée en jeu. Le type de trigger est acquis (recharge, `secretAura`, puissance, testés sur le chaman). La mention « (type acquis) » le rappelle.
- **Chargement** : `spellknown` sur l'ID du rang 1 (ou du talent). Pas de chargement par niveau.
- **Style commun** (PLAN-AURAS-V2.md, point 3) : grise en recharge, rouge hors de portée, bleue sans mana, lueur sur buff ou proc, alpha 0,4 hors combat sans cible sur Principal et Utilitaires. Les cellules « style » n'indiquent que l'écart.

## 1. Sources et spés couvertes

Sources :

- `Classes/Mage.md` : arbres Arcane (18 talents), Feu (17), Givre (19), sorts de base, auras candidates.
- `PLAN-AURAS-CLASSES.md` section 5.3 : rotation, cooldowns, procs, buffs, rappels de la v1.
- Idées de contenu : `RECHERCHE-AURAS-CLASSES.md` (packs Mage : buffs de classe, stacks de Scorch et d'Ignite, portails), `ANALYSE-AURAS-FOJJI.md` section 7 (barre Arcane Blast à segments, procs Arcane Missiles, Fingers of Frost, Heating Up), gabarit Luxthos (rangées, rappels masqués au repos, barre d'incantation, indicateur de règle des 5 s).
- Pack Luxthos Mage (Classic Era), décodé : `Tests/Packs/Mage/ANALYSE-LUXTHOS.md` (idées seulement). Apports : icônes à deux états (recharge puis effet), racine de Frost Nova et silence de Counterspell sur la cible (le verrou d'école n'est pas une aura ; repris par le silence 18469 d'Improved Counterspell), Fire Ward actif, gemmes de mana par `Item Count`, rappel Amplify/Dampen Magic. Il n'a ni sorts de rotation, ni Arcane Blast, ni procs de talent.

Forever n'a pas de spécialisation (`GetSpecialization` absent). Une « spé » est une variante de **talent** chargée par `spellknown` :

| Variante | Chargement | Style de jeu |
|---|---|---|
| Base (leveling, solo) | aucun talent requis | Frostbolt ou Fireball, Fire Blast, Frost Nova, Arcane Missiles, Evocation |
| Arcane | `spellknown` Arcane Blast 400574 | Arcane Blast en cumuls, Presence of Mind, Arcane Power, Clearcasting |
| Feu | `spellknown` Pyroblast 11366 ou Combustion 11129 | Scorch, Fireball, Pyroblast, Combustion, Ignite |
| Givre | `spellknown` Ice Barrier 11426 ou Cold Snap 12472 | Frostbolt, Ice Lance, Frost Nova, Cone of Cold, Ice Barrier |

Modes : solo/leveling (Base), donjon (AoE : Blizzard, Flamestrike, Arcane Explosion, contrôle Polymorph), raid (cooldowns, debuffs Scorch et Winter's Chill, mana). Les rôles sont tous DPS. Le mage n'a pas de variante tank ou soin.

## 2. Rangées

### 2.1 Rappels (icônes 32, hors combat, cachés en zone de repos)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Arcane Intellect manquant | rebuffer avant le pull | `secretAura`, player, HELPFUL, absent | 1459, 1460, 1461, 10156, 10157, 23028 | `spellknown` 1459 ; hors combat | cache en repos ; lueur | à tester (type acquis) |
| Armure manquante | choisir et poser une armure | `secretAura`, player, HELPFUL, absent | Frost 168, 7300, 7301 ; Ice 7302, 7320, 10219, 10220 ; Mage 6117, 22782, 22783 | `spellknown` 168 ; hors combat | cache en repos ; une icône pour les 3 armures | à tester (type acquis) |
| Mana basse | boire ou Evocation | Power mana, player, sous 20 % | type 0 | classe Mage ; texte | texte rouge, combat seulement ; barre seule, pas de valeur lue | à tester (type acquis) |

3 lignes. Conjure Water/Food, Mana Gem : voir section 5.

### 2.2 Effets (icônes 32 : procs, buffs courts, debuffs cible)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Clearcasting | lancer un sort gratuit | `secretAura`, player, HELPFUL | 12536 (15 s) ; autres candidats 16246, 16870, 457342, 467735 | `spellknown` 11213 (Arcane Concentration, 5 rangs : 11213, 12574, 12575, 12576, 12577) | lueur pixel ; temps restant rouge sous 3 s | à tester (type acquis) |
| Arcane Power actif | fin de la fenêtre | `secretAura`, player | 12042 | `spellknown` 12042 | lueur ; rouge sous 3 s | à tester (type acquis) |
| Presence of Mind actif | prochain sort instantané | `secretAura`, player | 12043 | `spellknown` 12043 | lueur | à tester (type acquis) |
| Combustion actif | fin de la fenêtre | `secretAura`, player | 28682 (aura) ; 11129 (sort) | `spellknown` 11129 | lueur ; rouge sous 3 s | à tester (type acquis) |
| Ice Barrier actif | rebuff le bouclier | `secretAura`, player | 11426, 13031, 13032, 13033 | `spellknown` 11426 | lueur ; texte rouge sous 10 s | à tester (type acquis) |
| Mana Shield actif | bouclier posé | `secretAura`, player | 1463, 8494, 8495, 10191, 10192, 10193 | `spellknown` 1463 | lueur | à tester (type acquis) |
| Ice Block actif | immunité en cours | `secretAura`, player | 11958 | `spellknown` 11958 | lueur ; rouge sous 3 s | à tester (type acquis) |
| Missile Barrage | Arcane Missiles gratuit | `secretAura`, player | candidats 400588, 400589, 401736, 467409 | `spellknown` du talent : aucun ID de talent | lueur | à tester ; ID à confirmer |
| Fingers of Frost | Ice Lance compte comme gelé | `secretAura`, player | candidats 400647, 400669, 400670, 401741 | aucun ID de talent | lueur ; charge 1 ou 2 non lue | à tester ; ID à confirmer |
| Heating Up | proc de critique Feu | `secretAura`, player | candidats 400624, 400625, 460878 | aucun ID de talent | lueur | à tester ; ID à confirmer |
| Arcane Blast cumuls | savoir si un cumul tourne | `secretAura`, player | candidats 400573, 400586, 401729, 1300176, 1300177 | `spellknown` 400574 | lueur ; pas de compteur | à tester ; ID à confirmer |
| Winter's Chill (cible) | cumuls de critique Givre | `secretAura`, target, HARMFUL, posé par le joueur | 12579 (15 s) | `spellknown` 11180 (rangs 11180, 28592, 28593, 28594, 28595) | texte rouge sous 3 s | à tester (type acquis) |
| Fire Vulnerability (cible) | Scorch à rafraîchir | `secretAura`, target, HARMFUL | 22959 (30 s) | `spellknown` 11095 (rangs 11095, 12872, 12873) | rouge sous 5 s | à tester (type acquis) |
| Ignite (cible) | DoT de critique en cours | `secretAura`, target, HARMFUL | candidats 3261, 412538, 1234540 ; 412545 exclu (sans aura) | `spellknown` 11119 (rangs 11119, 11120, 12846, 12847, 12848) | aucun seuil | à tester ; ID à confirmer |
| Pyroblast DoT (cible) | DoT posé | `secretAura`, target, HARMFUL | 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 | `spellknown` 11366 | rouge sous 3 s | à tester ; ID à confirmer |
| Chilled (cible) | cible ralentie | `secretAura`, target, HARMFUL | 12484 ; 6136 (Frost Armor) ; 7321 (Ice Armor) | classe Mage | aucun | à tester ; ID à confirmer |
| Polymorph (cible) | contrôle en cours | `secretAura`, target, HARMFUL | 118, 12824, 12825, 12826, 28272, 28271, 28270 | `spellknown` 118 | rouge sous 5 s | à tester (type acquis) |
| Frostbite gel (cible) | cible gelée | `secretAura`, target, HARMFUL | 12494 | `spellknown` 11071 (rangs 11071, 12496, 12497) | aucun | à tester |
| Frost Nova racine (cible) | durée de la racine | `secretAura`, target, HARMFUL, posé par le joueur | 122, 865, 6131, 10230 | `spellknown` 122 | lueur ; rouge sous 3 s | à tester ; ID d'aura = ID de sort, la racine est portée par le sort (Wowhead Forever) |
| Counterspell silence (cible) | durée du silence | `secretAura`, target, HARMFUL | 18469 | `spellknown` 11255 (Improved Counterspell) | lueur | à tester ; 2139 n'a qu'un effet d'interruption, le verrou d'école n'est pas une aura ; 18469 « Counterspell - Silenced » (4 s, Wowhead Forever), posé par le talent via un script serveur |
| Fire Ward actif | bouclier de Feu posé | `secretAura`, player, HELPFUL | 543, 8457, 8458, 10223, 10225 | `spellknown` 543 | lueur ; rouge sous 5 s | à tester ; ID d'aura = ID de sort sur les 5 rangs (Wowhead Forever) |
| Frost Ward actif | bouclier de Givre posé | `secretAura`, player, HELPFUL | 6143, 8461, 8462, 10177, 28609 | `spellknown` 6143 | lueur ; rouge sous 5 s | à tester ; ID d'aura = ID de sort sur les 5 rangs (Wowhead Forever) |

22 lignes. Impact (12355, étourdissement du talent 11103) : retiré, 2 s trop court pour une décision.

### 2.3 Principal (icônes 44, 8 au plus par variante)

Une aura par variante, chargée par talent. Les sorts sans recharge propre (Fireball, Frostbolt, Arcane Missiles, Scorch, Ice Lance) n'affichent que le GCD (secret en combat, corrigé en 1.7.0). Ils servent pour la portée, la mana et la disponibilité. Trigger commun : Cooldown Progress (Spell) avec conditions On Cooldown, Insufficient Resources, Spell in Range, Desaturate.

**Base (leveling)**, 6 icônes :

| Aura | Décision | IDs (tous rangs) | Chargement | Conditions et style | État |
|---|---|---|---|---|---|
| Frostbolt | filler de leveling | 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 | `spellknown` 116 | rouge hors portée ; bleue sans mana | à tester (type acquis) |
| Fireball | filler alternatif | 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 | `spellknown` 133 | idem | à tester (type acquis) |
| Arcane Missiles | canalisation | 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 | `spellknown` 5143 | idem | à tester (type acquis) |
| Fire Blast | finisseur instantané | 2136, 2137, 2138, 8412, 8413, 10197, 10199 | `spellknown` 2136 | grise 8 s | acquis (recharge, type) |
| Evocation | regagner la mana | 12051 | `spellknown` 12051 | grise 8 min | à tester (type acquis) |
| Cone of Cold | ralentir un groupe | 120, 8492, 10159, 10160, 10161 | `spellknown` 120 | grise 10 s | à tester (type acquis) |

**Arcane**, 8 icônes :

| Aura | Décision | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|
| Arcane Blast | sort principal | 400574, 1239696, 1239697, 1239699, 1239700 | `spellknown` 400574 | rouge hors portée ; bleue sans mana (15 % base) | à tester (type acquis) |
| Arcane Missiles | proc ou filler | 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 | `spellknown` 5143 | lueur quand Clearcasting ou Missile Barrage actif | à tester (type acquis) |
| Arcane Explosion | AoE de zone | 1449, 8437, 8438, 8439, 10201, 10202 | `spellknown` 1449 | bleue sans mana | à tester (type acquis) |
| Fire Blast | mouvement | 2136, 2137, 2138, 8412, 8413, 10197, 10199 | `spellknown` 2136 | grise 8 s | acquis (recharge, type) |
| Arcane Power | fenêtre de dégâts | 12042 | `spellknown` 12042 | grise 3 min | à tester (type acquis) |
| Presence of Mind | sort lourd instantané | 12043 | `spellknown` 12043 | grise 3 min | à tester (type acquis) |
| Evocation | mana | 12051 | `spellknown` 12051 | grise 8 min | à tester (type acquis) |
| Cone of Cold | ralentir | 120, 8492, 10159, 10160, 10161 | `spellknown` 120 | grise 10 s | à tester (type acquis) |

**Feu**, 8 icônes :

| Aura | Décision | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|
| Fireball | filler | 133 à 25306 (liste Base) | `spellknown` 133 | rouge hors portée | à tester (type acquis) |
| Scorch | maintenir Fire Vulnerability | 2948, 8444, 8445, 8446, 10205, 10206, 10207 | `spellknown` 2948 | lueur si Fire Vulnerability absent ou sous 5 s | à tester (type acquis) |
| Pyroblast | ouverture ou proc | 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 | `spellknown` 11366 | bleue sans mana | à tester (type acquis) |
| Fire Blast | instant | 2136, 2137, 2138, 8412, 8413, 10197, 10199 | `spellknown` 2136 | grise 8 s | acquis (recharge, type) |
| Blast Wave | AoE et ralentissement | 11113, 13018, 13019, 13020, 13021 | `spellknown` 11113 | grise 45 s | à tester (type acquis) |
| Flamestrike | AoE de zone | 2120, 2121, 8422, 8423, 10215, 10216 | `spellknown` 2120 | bleue sans mana | à tester (type acquis) |
| Combustion | fenêtre de critiques | 11129 | `spellknown` 11129 | grise 3 min | à tester (type acquis) |
| Evocation | mana | 12051 | `spellknown` 12051 | grise 8 min | à tester (type acquis) |

**Givre**, 8 icônes :

| Aura | Décision | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|
| Frostbolt | filler | 116 à 25304 (liste Base) | `spellknown` 116 | rouge hors portée | à tester (type acquis) |
| Ice Lance | dégâts sur cible gelée | 1312002, 400640, 1240044, 1240045, 1240046, 1240047 | `spellknown` 1312002 | lueur si Fingers of Frost actif (une fois l'ID confirmé) | à tester (type acquis) |
| Frostfire Bolt | filler hybride | 401502, 1237312, 1237313 | `spellknown` 401502 | rouge hors portée | à tester (type acquis) |
| Cone of Cold | ralentir | 120, 8492, 10159, 10160, 10161 | `spellknown` 120 | grise 10 s | à tester (type acquis) |
| Blizzard | AoE canalisée | 10, 6141, 8427, 10185, 10186, 10187 | `spellknown` 10 | bleue sans mana | à tester (type acquis) |
| Fire Blast | instant | 2136, 2137, 2138, 8412, 8413, 10197, 10199 | `spellknown` 2136 | grise 8 s | acquis (recharge, type) |
| Ice Barrier | bouclier à rebuffer | 11426, 13031, 13032, 13033 | `spellknown` 11426 | grise 30 s ; remplace l'icône d'effet quand actif | à tester (type acquis) |
| Cold Snap | réinitialise le Givre | 12472 | `spellknown` 12472 | grise 10 min | à tester (type acquis) |

Total : 6 + 8 + 8 + 8 = 30 lignes (au plus 8 par variante). Frost Nova est en Utilitaires.

Icône à double état : Arcane Power, Presence of Mind, Combustion, Ice Barrier et Evocation peuvent n'occuper qu'une icône, qui affiche la recharge puis, tant que l'effet dure, la durée avec lueur. Cela remplacerait les lignes « actif » correspondantes de 2.2 (Arcane Power, Presence of Mind, Combustion, Ice Barrier). État : à tester (mélange `Cooldown Progress` et `secretAura` dans une même aura, point 8 de la section 5 du socle). Tant que non vérifié, garder les deux lignes séparées.

### 2.4 Débordement (icônes 36, au-delà de 8)

| Aura | Décision | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|
| Arcane Missiles (Feu et Givre) | proc Clearcasting | 5143 à 25345 | `spellknown` 5143 | lueur sur proc | à tester (type acquis) |
| Scorch (Givre, Arcane) | Fire Vulnerability sans talent Feu | 2948 à 10207 | `spellknown` 2948, variante non Feu | grise inutile | à tester (type acquis) |
| Arcane Explosion (Feu, Givre) | AoE de contact | 1449 à 10202 | `spellknown` 1449 | bleue sans mana | à tester (type acquis) |
| Flamestrike (Arcane, Givre) | AoE de zone | 2120 à 10216 | `spellknown` 2120 | bleue sans mana | à tester (type acquis) |
| Blast Wave (Arcane, Givre) | ralentissement de zone | 11113 à 13021 | `spellknown` 11113 | grise 45 s | à tester (type acquis) |

5 lignes. Chaque variante déplace dans Débordement ce qui dépasse 8 dans Principal.

### 2.5 Utilitaires (icônes 32, une rangée pour toutes les variantes)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Counterspell | interrompre | Cooldown Progress | 2139 | `spellknown` 2139 | grise 30 s ; rouge hors portée | à tester (type acquis) |
| Blink | se déplacer ou fuir | Cooldown Progress | 1953 | `spellknown` 1953 | grise 15 s | à tester (type acquis) |
| Frost Nova | racine de mêlée | Cooldown Progress | 122, 865, 6131, 10230 | `spellknown` 122 | grise 25 s | à tester (type acquis) |
| Ice Block | défensif d'urgence | Cooldown Progress | 11958 | `spellknown` 11958 | grise 5 min | à tester (type acquis) |
| Fire Ward | absorber des dégâts Feu | Cooldown Progress | 543, 8457, 8458, 10223, 10225 | `spellknown` 543 | grise 30 s | à tester (type acquis) |
| Frost Ward | absorber des dégâts Givre | Cooldown Progress | 6143, 8461, 8462, 10177, 28609 | `spellknown` 6143 | grise 30 s | à tester (type acquis) |
| Polymorph | contrôle | Cooldown Progress (portée seule) | 118, 12824, 12825, 12826 | `spellknown` 118 | rouge hors portée ; sans recharge propre | à tester (type acquis) |
| Mana Shield | défensif contre la mana | Cooldown Progress | 1463, 8494, 8495, 10191, 10192, 10193 | `spellknown` 1463 | bleue sans mana | à tester (type acquis) |
| Gemme de mana | avoir une gemme sous la main | `Item Count`, 4 objets | objets 5514, 5513, 8007, 8008 (Wowhead Forever) ; sorts de création 759, 3552, 10053, 10054 | `spellknown` 759 | grisée sans gemme ; texte du nombre de gemmes | à tester |

9 lignes. Variantes Polymorph Pig, Turtle, Cow (28272, 28271, 28270) : uniquement en debuff cible (2.2).

### 2.6 Entretien (icônes 32, buffs longs)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Arcane Intellect (durée) | rebuffer avant expiration | `secretAura`, player | 1459, 1460, 1461, 10156, 10157, 23028 | `spellknown` 1459 | texte rouge sous 5 min ; 1 h de durée | à tester (type acquis) |
| Armure (durée) | suivre l'armure active | `secretAura`, player | 168, 7300, 7301, 7302, 7320, 10219, 10220, 6117, 22782, 22783 | `spellknown` 168 | rouge sous 5 min ; 30 min de durée | à tester (type acquis) |
| Dampen Magic ou Amplify Magic | rebuffer hors combat | `secretAura`, player | Amplify 1008, 8455, 10169, 10170 ; Dampen 604, 8450, 8451, 10173, 10174 | `spellknown` 604 | rouge sous 5 min ; 10 min de durée ; masqué en repos | à tester (type acquis) ; ID d'aura = ID de sort sur tous les rangs (Wowhead Forever) |

3 lignes. Dampen ou Amplify Magic est retenu en priorité basse (retiré de « exclu »).

### 2.7 Ressource (barre 390x18)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mana | gérer la mana, boire ou Evocation | Power, player, type 0 (mana) | type 0 | classe Mage | bleue ; texte natif `%p` ; couleur fixe ; couleur par seuil : bloqué | à tester (type acquis), bloqué (seuil) |

### 2.8 Secondaire (barre 390x10 ou segments)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Règle des 5 s | boire sans casser la régénération | Spell Cast Succeeded, durée fixe 5 s | 116, 133, 5143, 2948, 2136, 122, 120, 1449, 10, 2120, 11366, 118, 400574 (liste v1) | classe Mage | barre grise qui se vide en 5 s ; masquée sinon | à tester |
| Arcane Blast cumuls (4 segments) | savoir où en est le cumul | `secretAura` sur l'aura des cumuls, un segment par pile | candidats 400573, 400586, 401729, 1300176, 1300177 | `spellknown` 400574 | 4 segments ; pile non lisible en combat | bloqué tant que la pile est secrète ; ID à confirmer |

### 2.9 Incantation (barre 390x16, visible pendant un cast)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Barre d'incantation du joueur | juger la fin d'un cast, annuler, bouger | Cast, unit player (trigger natif à vérifier) | tous les sorts | classe Mage | barre bleue ; cachée hors cast ; marque du canal pour Arcane Missiles et Blizzard | à tester |

## 3. Variantes par spé, forme ou talent

- **Pas de forme ni de posture.** Le mage n'a aucune forme. Toute la bascule passe par `spellknown`.
- **Principal** : quatre blocs (Base, Arcane, Feu, Givre) chargés par talent. Base se charge si aucun des trois talents-pivots n'est connu. Arcane = 400574, Feu = 11366 ou 11129, Givre = 11426 ou 12472.
- **Cumul de talents** : un mage hybride peut connaître 400574 et 11129. Les deux blocs se chargent alors et se chevauchent. Règle proposée : l'ordre d'exclusion Arcane, puis Feu, puis Givre, en chargeant Feu seulement si Arcane est absent. Une aura peut porter une condition de chargement négative sur `spellknown`. À vérifier dans Musca (section 9, point 1).
- **Effets** : les auras de talent se chargent seules (une aura par `spellknown`), donc un seul jeu d'effets apparaît par build.
- **Utilitaires et Entretien** : identiques pour toutes les variantes.
- **Armure** : une seule icône couvre les 3 familles. Les rangs de chaque famille sont des IDs d'aura de la même aura multi-ID.

## 4. Rappels

| Rappel | Trigger | Hors combat | Masqué au repos |
|---|---|---|---|
| Arcane Intellect manquant | `secretAura` absent, player | oui | oui |
| Armure manquante | `secretAura` absent, player | oui | oui |
| Mana basse | Power mana, sous 20 % | non (combat) | oui |

Condition de repos : option de chargement de Musca, à vérifier (PLAN-AURAS-V2.md point 5.5).

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Compteur de pile d'Arcane Blast (valeur de pile) | pile secrète en combat ; seule la présence de l'aura est affichable |
| Compteur d'Ignite, de Scorch ou de Winter's Chill (pile, dégâts) | pile et dégâts secrets ou issus du journal de combat |
| Minuteur d'Ignite sans aura | demande le journal de combat |
| Seuil de mana (son, glow) | valeur de puissance secrète en combat ; seulement une couleur de barre |
| Hot Streak | absent du DB2, exclu (Heating Up est le seul équivalent Classes/Mage.md) |
| Conjure Water/Food en rappel | aucun ID d'objet dans `Classes/Mage.md` ; exclu (la gemme de mana est reprise en 2.5) |
| Curseur de tic de mana (cycle de 2 s) | comparer la mana avant et après un tic lit une valeur de puissance secrète : bloqué. Seule la règle des 5 s reste (2.8) |
| Texte de mana en K ou valeur et pourcentage | formatage Lua d'une valeur secrète : bloqué ; texte natif `%c` et `%p` seulement |
| Combustion grisée si la cible n'a pas de DoT | état d'un autre trigger (bloqué) ; les ID de DoT 413841 et 44457 sont absents du DB2 de Forever, exclus |
| Detect Magic | absent du DB2, exclu |
| Impact (12355, étourdissement) | durée trop courte pour une décision |
| Arcane Barrage 400610, Living Bomb 400613/400614, Rewind Time 401462, Living Flame 401556/401558, Regeneration 401417, Mass Regeneration 412510, Spellfrost Bolt 412532, Icy Veins 425121, Arcane Surge 425124, Balefire Bolt 428878, Expanded Intellect 436949, Frozen Orb 440802/440809 | listés dans « Points non vérifiés » du DB2 mais non confirmés actifs en jeu ; exclus du pack tant qu'un test en jeu ne les confirme pas |
| Fire Blast 400616 à 400623 | doublons runiques possibles du DB2 ; non retenus (rangs normaux 2136 à 10199 suffisent) |
| Felfire 24530, Teleport/Portal | pas de décision de combat |
| Comprehend Scroll, Study | IDs candidats non tranchés ; hors rotation |

## 6. IDs à confirmer en jeu

Commande par aura posée : `/run` de lecture d'aura de joueur ou de cible, hors combat (aucun secret), puis relevé dans `Classes/Mage.md`.

| Aura | Candidats | À vérifier |
|---|---|---|
| Clearcasting | 12536 (retenu), 16246, 16870, 457342, 467735 | lancer jusqu'au proc, relever le spellID de l'aura |
| Combustion | 28682 (aura), 11129 (sort) | relever le spellID du buff pendant les 3 critiques |
| Ignite (cible) | 3261, 412538, 1234540 (412545 exclu) | frapper une cible en critique de Feu, lire le debuff ; le débuff porterait le nom du talent 11119, ID non tranché |
| Arcane Blast cumuls | 400573, 400586, 401729, 1300176, 1300177 | lancer le sort 2 à 4 fois, lire le buff, vérifier les 8 s |
| Missile Barrage | 400588, 400589, 401736, 467409 | talent disponible sur Forever ? lancer Arcane Blast ou Fireball |
| Fingers of Frost | 400647, 400669, 400670, 401741 | talent disponible ? lancer Frostbolt sur une cible ralentie |
| Heating Up | 400624, 400625, 460878 | talent disponible ? critique Feu direct |
| Chilled | 12484 ; 6136 (Frost Armor) ; 7321 (Ice Armor) | frapper avec Frostbolt, armure de Givre, armure de glace |
| Frostbolt, Pyroblast, Polymorph (debuffs) | IDs de rang (v1) | vérifier que l'ID de rang est bien l'ID d'aura |
| Fire Vulnerability | 22959 | vérifier la durée de 30 s et la présence sans le talent |
| Racine de Frost Nova, silence de Counterspell, Amplify/Dampen | Frost Nova et Amplify/Dampen : ID d'aura = ID de sort ; silence 18469 (Wowhead Forever) | lire les auras en jeu ; le silence n'existe qu'avec Improved Counterspell |
| Gemmes de mana | objets 5514, 5513, 8007, 8008 (Wowhead Forever) | `GetItemInfo` hors combat, confirmer l'ID d'objet |

## 7. Tests en jeu propres au mage

Au-delà de la grille de `PLAN-AURAS-CLASSES.md` section 4 :

1. Rappel Arcane Intellect puis armure : visibles hors combat sans buff, cachés en repos, absents une fois le buff posé.
2. Changement d'armure (Frost vers Ice vers Mage) : la même icône reste cohérente, sans doublon.
3. Chargement par talent : un mage de niveau bas voit le bloc Base. Après le talent, le bloc de la variante apparaît. Un mage hybride ne voit qu'un bloc.
4. Clearcasting : proc en combat sur un mob, lueur visible, retrait à l'utilisation.
5. Debuffs de cible (Winter's Chill, Fire Vulnerability, Ignite) : affichage en combat, retrait à la mort de la cible, changement de cible.
6. Barre de mana : couleur fixe, lecture sans erreur BugSack pendant le combat.
7. Règle des 5 s : se lance au cast d'un sort à mana, tombe à zéro après 5 s sans cast.
8. Barre d'incantation : Frostbolt (cast), Arcane Missiles et Blizzard (canal), annulation par mouvement.
9. Presence of Mind puis Pyroblast : l'icône de PoM passe de recharge à aura puis à recharge (icône à double état, point 5.8 du socle).
10. Ice Barrier : pose, absorption, expiration, nouvelle recharge de 30 s.
11. Blink en combat : recharge visible malgré la valeur secrète.
12. Polymorph : debuff cible visible, portée rouge hors de 30 m.
13. Gemme de mana : icône grisée sans gemme, nombre juste après Conjure Mana Agate, lecture sans erreur BugSack en combat.
14. Frost Nova et Counterspell : racine et silence (talent Improved Counterspell) visibles sur la cible en combat.

## 8. Écart avec la v1 (`PackMage.lua`)

**Ajouter**

- Rangées Effets (22), Principal par variante (30), Débordement (5), Utilitaires (9), Entretien (3), Secondaire, Incantation.
- Sorts de rotation absents de la v1 : Frostbolt, Fireball, Arcane Missiles, Arcane Explosion, Scorch, Pyroblast, Flamestrike, Blizzard, Ice Lance, Frostfire Bolt.
- Utilitaires : Fire Ward, Frost Ward, Polymorph (recharge), Frost Nova.
- Effets : Chilled, Frostbite (gel), racine de Frost Nova, silence de Counterspell (talent), Fire Ward et Frost Ward actifs, auras candidates de Missile Barrage, Fingers of Frost, Heating Up, Arcane Blast.
- Utilitaires : gemme de mana. Entretien : Amplify/Dampen Magic.
- Seuil de temps restant par aura, lueur fixe, style d'icône commun, alpha hors combat.
- Barre d'incantation, indicateur de règle des 5 s en Secondaire.
- Variantes Base, Arcane, Feu, Givre chargées par `spellknown`.

**Changer**

- Groupes v1 (Rotation, Procs, Cooldowns, Buffs, Debuffs) remplacés par les rangées v2.
- Cooldowns de la v1 répartis : Counterspell, Blink, Ice Block vers Utilitaires ; Arcane Power, Combustion, Presence of Mind, Cold Snap, Ice Barrier, Evocation vers Principal selon la variante.
- Auras « actif » (Arcane Power, Combustion, Presence of Mind, Ice Barrier, Ice Block) vers Effets.
- Rappel « MANA BAS » : texte devenu icône, montré sous le seuil par Show only below.
- Ignite : lister 3261, 412538, 1234540 jusqu'à la confirmation en jeu.
- Armure et Arcane Intellect : doublées en Rappel (manquant) et Entretien (durée).

**Retirer**

- Aura Polymorph de la v1 en debuff isolé : conservée en Effets avec seuil, mais retirée de la rangée Debuffs.
- Frostbolt en debuff seul : remplacé par Chilled si l'ID est confirmé, sinon gardé.
- Rien d'autre n'est retiré.

## 9. Besoins du générateur propres au mage

Seuls les besoins réels, au-delà de PLAN-AURAS-V2.md section 5 :

1. **Chargement négatif par `spellknown`** (Base absent si un talent-pivot est connu, Feu absent si Arcane connu). À vérifier dans Musca.
2. **Auras à chargement par talent sans ID de talent** (Missile Barrage, Fingers of Frost, Heating Up) : le chargement se fait sur la présence de l'aura, pas sur `spellknown`. Le générateur doit permettre un chargement par classe seule.
3. **Segments de pile d'Arcane Blast** (4 segments par pile) : bloqué par la pile secrète. À reprendre si Musca expose un segment par pile secrète.
4. **Lueur d'Ice Lance liée à Fingers of Frost** : bloqué (lueur sur état d'un autre trigger). Remplacement : lueur fixe sur l'icône d'effet de Fingers of Frost.
5. **Barre d'incantation avec marque de canal** (Arcane Missiles, Blizzard) : option d'affichage de canal à vérifier avec le trigger natif.
6. **Icône `Item Count`** (gemmes de mana, 4 objets dans une aura, texte du nombre) : rappel texte existant pour un objet (`entry.item`) ; manquent l'icône et plusieurs objets dans une aura.
7. **Icône à double état** (Arcane Power, Presence of Mind, Combustion, Ice Barrier, Evocation) : point 8 du socle, mage ajouté aux classes concernées.
8. **Mode d'affichage présent, absent ou toujours** par rappel d'entretien (Arcane Intellect, armures, Amplify/Dampen) : pas d'option joueur ; chez Musca, une aura de rappel par mode ou un choix fixe du générateur.

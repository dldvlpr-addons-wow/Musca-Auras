# Plan v2 du pack Chasseur (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Suit `PLAN-AURAS-V2.md` (socle commun, section 6 point 1).

Les IDs viennent de `Classes/Hunter.md` (DB2 1.60.1.70245). Les états sont ceux de `PLAN-AURAS-V2.md` section 1 :
**acquis**, **à tester**, **bloqué**. Aucun code, aucune chaîne d'import ici. Les packs Luxthos, Fojji et Wago ne
fournissent que des idées.

## 1. Sources et spécialisations couvertes

Sources : socle `PLAN-AURAS-V2.md`, règles v1 `PLAN-AURAS-CLASSES.md` (section 3 et 5.4), `Classes/Hunter.md`,
pack v1 `PackChasseur.lua` et `NOTES.md`, `RECHERCHE-AURAS-CLASSES.md` (castbar Auto/Aimed/Multi Shot, familier,
munitions, portée et zone morte, aspect et Trueshot manquants), `ANALYSE-AURAS-FOJJI.md` section 7 (Auto Shot en
minuteur, bloc familier, 18 slots de recharge), pack Luxthos Hunter (Classic Era) décodé et résumé dans
`ANALYSE-LUXTHOS.md` (même dossier) : gabarit de rangées, doubles états, swing, munitions, familier absent.

Arbres de talents Classic de la classe (Forever n'a pas de spécialisation, seulement des talents) :

- Maîtrise des bêtes : Bestial Wrath, Intimidation, Frenzy, Spirit Bond, Improved Mend Pet.
- Précision : Aimed Shot, Trueshot Aura, Improved Hunter's Mark, Barrage, Improved Serpent Sting, Scatter Shot.
- Survie : Counterattack, Deterrence, Improved Wing Clip, Clever Traps, Entrapment, Savage Strikes.

Styles de jeu couverts :

- Solo et montée en niveau : Raptor Strike, Mongoose Bite, Serpent Sting, Mend Pet, familier vivant.
- Donjon : Multi-Shot, Arcane Shot, Distracting Shot, Feign Death, Freezing Trap, Hunter's Mark.
- Raid : Rapid Fire, Aimed Shot, Multi-Shot, Arcane Shot, Trueshot Aura, Tranquilizing Shot, Feign Death.

Variantes de rôle : un seul rôle (dégâts à distance). Le familier tanke en solo et en donjon, donc le bloc familier reste.

## 2. Tables par rangée

Chargement : classe `HUNTER` pour toutes les auras, puis `spellknown` indiqué. Style : celui de `PLAN-AURAS-V2.md`
section 3 (zoom 0,3, bordure noire, recharge grisée, rouge hors de portée, bleu sans mana, lueur à l'apparition).
Raccourcis : CP = Cooldown Progress (Spell), SA = `secretAura` (Aura Modern), AU = Action Usable, QA = Queued Action.
Le trigger CP se pose par nom de sort : un seul trigger couvre tous les rangs.

### 2.1 Rappels (icônes 32, hors combat, cachés en zone de repos)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Aspect manquant | Poser un aspect avant le pull | SA player HELPFUL, absent, liste d'aspects | Hawk 13165, 14318, 14319, 14320, 14321, 14322, 25296 ; Monkey 13163 ; Cheetah 5118 ; Pack 13159 ; Beast 13161, 1299445, 1299446, 1299447 ; Wild 20043, 20190 ; Viper 415423 ; Falcon 469145 | spellknown 13165 | masqué en repos, lueur fixe | à tester (Hawk seul vérifié par type de trigger) |
| Familier absent | Appeler le familier | Conditions du joueur, « a un familier (vivant) » inversé (existence et mort, aucune valeur secrète) | sort Call Pet 883 pour l'icône | spellknown 883 | masqué en repos, visible aussi en combat (familier tué pendant le combat) ; lueur en combat ; vrai aussi quand le familier est mort | à tester (le doublon avec Familier mort est à trancher en jeu) |
| Familier mort | Ressusciter avant le pull | Health sur `pet`, valeur 0 | Revive Pet 982 | spellknown 982 | masqué en repos | à tester |
| Trueshot Aura manquant | Rebuffer le groupe | SA player HELPFUL, absent | 1299346, 1299348, 19506, 20905, 20906 | spellknown 1299346 ou 19506 | masqué en repos | à tester |
| Munitions basses | Acheter des flèches ou balles | Cooldown Progress (Equipment Slot) sur l'emplacement 0 (munitions), compteur en texte `%s` ; repli : Item Count avec ID d'objet à relever | aucun ID d'objet avec l'emplacement | arme à distance équipée | grisé à 0, seuil bas, masqué en repos | à tester (présence de munitions sur Forever et comptage de l'emplacement à vérifier) |

### 2.2 Effets (icônes 32 : procs, buffs courts, debuffs sur la cible)

Rangée dynamique : seules les auras actives occupent de la place. Au plus 8 actives en même temps en pratique.

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Quick Shots | Savoir si le proc de vitesse est actif | SA player HELPFUL | 6150 | spellknown 13165 | lueur à l'apparition | à tester (ID) |
| Rapid Fire actif | Enchaîner les tirs pendant les 15 s | SA player HELPFUL | 3045 | spellknown 3045 | lueur, texte de durée rouge sous 3 s | à tester (double état avec l'icône Principal) |
| Deterrence actif | Savoir que l'esquive est active | SA player HELPFUL | 19263 | spellknown 19263 | lueur, durée 10 s | à tester |
| Mongoose Bite utilisable | Contre-coup après une esquive | AU, Mongoose Bite | 1495, 14269, 14270, 14271 | spellknown 1495 | rouge hors de portée de mêlée | à tester |
| Counterattack utilisable | Contre-coup après une parade | AU, Counterattack | 19306, 1242634, 20909, 20910 | spellknown 19306 | rouge hors de portée de mêlée | à tester |
| Hébété (Cheetah, Pack) | Changer d'aspect si le déplacement est ralenti | SA player HARMFUL | 15571 | spellknown 5118 ou 13159 | lueur rouge à l'apparition | à tester |
| Bestial Wrath familier | Savoir que le familier est enragé | SA unit `pet` HELPFUL | 19574 | spellknown 19574 | durée 18 s | à tester (aura sur `pet`) |
| Frenzy familier | Voir le proc de vitesse du familier | SA unit `pet` HELPFUL | 19615 | talent Frenzy (spellknown 19621) | durée courte | à tester (ID) |
| Mend Pet actif | Ne pas relancer le canal | SA unit `pet` HELPFUL | ID de l'aura inconnu (sorts 136, 3111, 3661, 3662, 13542, 13543, 13544) | spellknown 136 | durée 5 s | à tester (ID) |
| Serpent Sting | Poser ou rafraîchir le DoT | SA target HARMFUL, posé par le joueur | 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 | spellknown 1978 | durée rouge sous 3 s | acquis (type de trigger testé) |
| Hunter's Mark | Marquer la cible | SA target HARMFUL | 1130, 14323, 14324, 14325 | spellknown 1130 | durée rouge sous 10 s | acquis (type de trigger testé) |
| Black Arrow | Garder le DoT de 30 s | SA target HARMFUL | 3674, 14296 | spellknown 3674 | durée rouge sous 3 s | à tester (actif sur Forever ?) |
| Wing Clip | Savoir si la cible est ralentie | SA target HARMFUL | 2974, 14267, 14268 | spellknown 2974 | durée 10 s | acquis (type de trigger testé) |
| Concussive Shot | Savoir si la cible est ralentie | SA target HARMFUL | 5116 | spellknown 5116 | durée 4 s | acquis (type de trigger testé) |
| Lacerate | Garder le saignement de 21 s | SA target HARMFUL | 24118, 24119, 24120, 1299332 | spellknown 24118 | durée rouge sous 3 s | à tester (ID) |
| Intimidation actif sur le familier | Savoir que le familier étourdira au prochain coup | SA unit `pet` HELPFUL | 19577 (buff de 15 s posé sur le familier, Wowhead Forever) ; 24394 est l'étourdissement de la cible, exclu | spellknown 19577 | texte de durée | à tester (aura sur `pet`, ID) |
| Cower du familier | Voir que le familier ne tanke plus | SA unit `pet` HELPFUL | 1742, 1753, 1754, 1755, 1756 (sorts du familier) | aucun `spellknown` fiable : sort du familier | lueur rouge à l'apparition | à tester (l'aura existe-t-elle ?) |

Total : 17 auras, dont 6 debuffs cible, 3 buffs ou débuffs joueur, 2 procs utilisables, 5 effets sur le familier, 1 proc de Hawk.

Serpent Sting : l'idée d'une icône unique de piqûres toujours visible en combat, grisée à alpha 0,5 quand la cible n'en porte
aucune, s'applique à la ligne Serpent Sting (état : à tester, la rangée Effets est sinon dynamique).

### 2.3 Principal (icônes 44, 8 au plus)

Six icônes, ordonnées. Chargement par `spellknown`, pas de groupe par spécialisation.

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Raptor Strike | Frapper en mêlée pendant la zone morte | CP, avec QA pour le coup en file | 2973, 14260, 14261, 14262, 14263, 14264, 14265, 14266 | spellknown 2973 | grisé en recharge, rouge hors portée de mêlée, bleu sans mana, lueur en file ; lueur aussi quand Mongoose Bite est utilisable (AU) ; portée mesurée sur Wing Clip 2974 si Raptor Strike ne renvoie pas de portée | à tester (QA, AU, portée) |
| Arcane Shot | Remplir entre deux Aimed Shot | CP | 3044, 14281, 14282, 14283, 14284, 14285, 14286, 14287 | spellknown 3044 | grisé, rouge hors portée ou zone morte, bleu sans mana | acquis (CP et conditions testés) |
| Multi-Shot | Dégâts de zone et remplissage | CP | 2643 | spellknown 2643 | idem | acquis |
| Aimed Shot | Tir lourd hors mouvement | CP | 19434, 20900, 20901, 20902, 20903, 20904 | spellknown 19434 | idem | acquis |
| Rapid Fire | Placer le gros cooldown | CP, puis durée du buff | 3045 | spellknown 3045 | grisé 5 min, lueur pendant les 15 s | à tester (double état, PLAN-AURAS-V2 5.8) |
| Bestial Wrath | Placer le cooldown du familier | CP | 19574 | spellknown 19574 | grisé, rouge si familier hors de portée | à tester (portée du sort) |

### 2.4 Débordement (icônes 36, au-delà de 8 dans Principal)

Principal n'atteint que 6. La rangée porte les sorts à talent dont l'effet n'est pas encore lu en jeu.

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Sniper Shot | Tir à 15 s de recharge, durée 10 s | CP | 1310687, 1310785, 1310786 | spellknown 1310687 | grisé, bleu sans mana | à tester (effet inconnu) |
| Summon Hawk | Sort Forever à 6 s de recharge | CP | 1293241, 1293525, 1293526, 1293527 | spellknown 1293241 | grisé, bleu sans mana | à tester (effet inconnu) |
| Distracting Shot | Reprendre l'aggro en donjon | CP | 20736, 14274, 15629, 15630, 15631, 15632 | spellknown 20736 | grisé 8 s, rouge hors de portée | acquis (CP testé) |

### 2.5 Utilitaires (icônes 32)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Feign Death | Vider l'aggro | CP | 5384 | spellknown 5384 | grisé 30 s | acquis |
| Disengage | Reculer d'un pas | CP | 781, 14272, 14273 | spellknown 781 | grisé 5 s | acquis |
| Deterrence | Esquive défensive | CP | 19263 | spellknown 19263 | grisé | acquis |
| Concussive Shot | Ralentir une cible | CP | 5116 | spellknown 5116 | grisé 12 s, rouge hors de portée | acquis |
| Scatter Shot | Désorienter | CP | 19503 | spellknown 19503 | grisé, rouge hors de portée | acquis |
| Intimidation | Étourdir par le familier | CP | 19577 | spellknown 19577 | grisé | acquis |
| Tranquilizing Shot | Retirer un enrage | CP | 19801 | spellknown 19801 | grisé 20 s, rouge hors de portée | acquis |
| Freezing Trap | Piéger une cible | CP | 1499, 14310, 14311 | spellknown 1499 | grisé 30 s | acquis |
| Frost Trap | Ralentir une zone | CP | 13809 | spellknown 13809 | grisé 30 s | acquis |
| Immolation Trap | Dégâts de zone au sol | CP | 13795, 14302, 14303, 14304, 14305 | spellknown 13795 | grisé 30 s | acquis |
| Explosive Trap | Dégâts de zone au sol | CP | 13813, 14316, 14317 | spellknown 13813 | grisé 30 s | acquis |
| Strider Kick | Coup Forever, effet inconnu | CP | 1317257 | spellknown 1317257 | grisé | à tester (effet) |

Les pièges partagent peut-être une recharge : à vérifier en jeu (section 7). Les quatre icônes restent, car chaque piège change la décision.

Double état (CP puis durée de l'effet, lueur et bord de balayage tant que l'effet dure) pour Deterrence
(19263), Feign Death (5384), Scatter Shot (19503, aura sur la cible), Distracting Shot (20736, aura sur la cible) et
Intimidation (19577, aura sur `pet`). Deterrence est déjà dans Effets. État : à tester (PLAN-AURAS-V2 5.8), sinon bloqué
et seule la recharge reste. Option d'affichage par icône : sur recharge seulement, ou toujours (défaut sur
recharge) : à tester.

### 2.6 Entretien (icônes 32)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Aspect actif | Voir l'aspect posé | SA player HELPFUL, une aura par aspect, un seul emplacement | listes de 2.1 | spellknown 13165 | grisé à alpha 0,5 quand aucun aspect | à tester |
| Trueshot Aura | Garder le buff de groupe | SA player HELPFUL | 1299346, 1299348, 19506, 20905, 20906 | spellknown 1299346 ou 19506 | texte de durée coloré sous 5 min | à tester |
| Heart of the Lion | Garder le buff Forever | SA player HELPFUL | 409580 | spellknown 409580 | texte de durée coloré sous 5 min | à tester (aura ou sort ?) |

### 2.7 Barres

| Barre | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Ressource : mana (390x18) | Gérer la mana | Power mana, texte natif `%p` | type de puissance 0 | classe | bleue, rouge sous 20 % | acquis (seuil par Show only below testé) |
| Secondaire : Auto Shot (390x10) | Ne pas retarder le prochain tir | Swing Timer, main `ranged` | Auto Shot 75 | spellknown 75 | texture unie, fond noir 50 %, violette ; phase de visée de 0,5 s distinguée du rechargement en option | à tester |
| Secondaire : swing de mêlée (390x10) | Caler Raptor Strike sur le coup de mêlée | Swing Timer, main `main` | aucun ID | arme de mêlée équipée, spellknown 2973 | orange, fine, sous la barre Auto Shot | à tester (disponibilité de Swing Timer sur Forever) |
| Secondaire : règle des 5 s | Savoir quand la mana revient | Spell Cast Succeeded, durée fixe 5 s | 3044, 14281 à 14287, 2643, 19434, 20900 à 20904, 1978, 13549 à 13555, 25295, 1130, 14323 à 14325 | classe | fine, sous la barre Auto Shot | à tester |
| Familier : vie | Soigner ou non le familier | Health sur `pet` | aucun | familier présent | verte, rouge sous 35 % | à tester |
| Incantation (390x16) | Voir le cast d'Aimed Shot et Mend Pet | Cast du joueur | 19434 et rangs, 136 et rangs | classe | visible pendant un cast seulement | à tester (PLAN-AURAS-V2 5.6) |

La barre Familier a besoin d'une rangée dédiée (section 9).

## 3. Variantes par talent et style de jeu

Pas de groupe par spécialisation. Chaque variante est une aura chargée par `spellknown` dans la même rangée.

| Variante | Auras qui s'ajoutent | Chargement |
|---|---|---|
| Niveau 1 à 19 | Raptor Strike, Arcane Shot, Serpent Sting, Hunter's Mark, Mend Pet, Wing Clip, aspect | sorts appris par niveau |
| Niveau 20 et plus | Aimed Shot, Multi-Shot, Freezing Trap, Deterrence, Disengage | spellknown 19434, 2643, 1499, 19263, 781 |
| Maîtrise des bêtes | Bestial Wrath (Principal et Effets familier), Intimidation, Frenzy familier | spellknown 19574, 19577, talent 19621 |
| Précision | Trueshot Aura (Entretien, Rappels), Scatter Shot, Sniper Shot, Summon Hawk | spellknown 19506, 19503, 1310687, 1293241 |
| Survie | Counterattack, Mongoose Bite, Lacerate, Wing Clip rangs hauts | spellknown 19306, 1495, 24118 |
| Raid | Tranquilizing Shot, Rapid Fire, Trueshot Aura | spellknown 19801, 3045 |
| Donjon | Distracting Shot, Feign Death, Freezing Trap | spellknown 20736, 5384, 1499 |

Raid et Donjon ne se chargent pas par type d'instance : le sort connu suffit. Une option de chargement par instance
reste à vérifier dans Musca. Sans elle, les deux variantes se confondent avec le niveau 60.

Aspect : un seul emplacement dans Entretien, une aura par aspect. Les rangs d'Aspect of the Hawk suivent le
`spellknown` du rang.

## 4. Rappels

| Rappel | Trigger | Hors combat | Masqué en repos |
|---|---|---|---|
| Aspect manquant | SA player, absent | oui | oui |
| Familier absent | Conditions, « a un familier (vivant) » inversé | oui | oui (visible aussi en combat) |
| Familier mort | Health `pet` à 0 | oui | oui |
| Trueshot Aura manquant | SA player, absent | oui | oui |
| Munitions basses | Equipment Slot 0 avec compteur, ou Item Count, seuil bas | oui | oui |

Quatre rappels se chargent hors combat ; Familier absent reste aussi visible en combat. L'option de masquage en zone de repos reste à vérifier dans Musca
(PLAN-AURAS-V2 5.5).

## 5. Éléments exclus ou bloqués

| Élément | Raison | Décision |
|---|---|---|
| Compteurs de procs Frenzy et Quick Shots | journal de combat | bloqué |
| Déclenchement d'un piège (Freezing Trap touche la cible) | journal de combat | bloqué |
| Minuteur d'effet de piège sur la cible | IDs d'effet 3355, 14308, 14309, 13810 non vérifiés ; lien piège vers effet non confirmé | à tester d'abord |
| Pushback de Aimed Shot, Multi-Shot ou Auto Shot | valeurs de cast secrètes sur la cible, pas de lecture du pushback | bloqué |
| Compteur de tirs ou de dégâts restants de Volley | journal de combat | bloqué |
| Alerte sonore ou lueur sur seuil de mana | comparaison d'une valeur secrète | bloqué (barre colorée seulement) |
| Bonheur, loyauté et régime du familier | API de bonheur à vérifier sur Forever | à tester d'abord, sinon exclu |
| Feed Pet (6991) | dépend du bonheur | exclu |
| Kill Command (34026), Readiness (23989), Misdirection, Steady Shot, Chimera Shot | absent du DB2, exclu | exclu |
| Wyvern Sting | seulement des candidats (24335, 24336, 26180, 26233, 1215753, 19386), « absent de Forever » d'après `Classes/Hunter.md` ; 19386 est une ligne de talent sans nom | exclu |
| Improved Scorpid Sting, Trap Mastery | absent du DB2 (noms DB2 différents) | exclu |
| Viper Sting (3034, 14279, 14280), Scorpid Sting (3043) | aucune décision en PvE courant, rangée Effets déjà chargée | retiré de la v1 |
| Volley (1510, 14294, 14295) | pas de recharge, canal | exclu des icônes |
| Flare (1543, présent au DB2), Enchanted Flare | détection d'invisibles, PvP | exclu |
| Calcul de la durée de cast par bonus de carquois et hâte, recul (pushback) d'Aimed Shot calculé sur les dégâts reçus | le recul demande le journal de combat ; le trigger `Cast` natif donne la durée réelle ; aucun carquois dans `Classes/Hunter.md` | bloqué (recul), exclu (carquois) |
| Compteur de tic de mana (phase de 2 s) | compare la mana avant et après (`UnitPower` secret en combat) | bloqué (règle des 5 s seulement) |
| Eagle Eye, Eyes of the Beast, Beast Lore, Scare Beast, Tame Beast, pistages (Track *) | aucune décision en combat | exclu |
| Bestial Wrath côté joueur | aura portée par le familier | suivi sur `pet` seulement |
| Timer d'ouverture de piège (1 min) | aucune donnée de lecture | exclu |

## 6. IDs à confirmer en jeu

À relever avec `/dump` sur l'aura posée, jamais par recoupement DB2 seul.

- Quick Shots 6150 : aura déclenchée par Aspect of the Hawk. Talent source non tranché (19552 à 19556, ou sort 23559).
- Mend Pet : ID de l'aura de soin sur le familier. Les sorts 136 à 13544 sont des sorts lancés, pas l'aura.
- Frenzy familier : 19615 contre les autres sorts nommés Frenzy (19451, 19812, 428728, 1215755).
- Bestial Wrath : 19574 sur le familier contre 1310831.
- Serpent Sting : 1978 à 25295 contre les candidats 425728 à 425737, 1232979 à 1232982, 1264747, 1287976. Vérifier que l'aura posée porte bien l'ID du sort lancé.
- Hunter's Mark : 1130 à 14325 contre 1213268.
- Black Arrow : 3674 et 14296 contre 20733 et 20734. Vérifier la durée de 30 s et que le sort existe en jeu.
- Wing Clip : 2974 à 14268 contre 14340, 27633, 1310180.
- Concussive Shot : 5116 contre 17174, 22914, 27634, 1236191.
- Lacerate : 24118 à 24120 et 1299332 contre 5422, 414644, 414647, 415760, 468843, 1235826, 1235827.
- Rapid Fire : 3045 contre 28755 (+4 s) et 1227772.
- Aspects Beast (13161, 1299445 à 1299447), Wild (20043, 20190), Falcon (469145), Viper (415423 contre 34074, 415424, 415718), Monkey, Cheetah, Pack : aura sur le sort lancé, jamais vue en jeu.
- Aspect of the Beast et Falcon : auras déclenchées Quick Strikes 1299448 et 469144, utiles seulement si elles changent une décision.
- Hébété : 15571 déclenché par Cheetah et Pack.
- Trueshot Aura : 1299346 et 1299348 (rangs entraîneur) contre 19506 (talent). Choisir le `spellknown` de chargement.
- Summon Hawk : le sort déclenché 1312639 est-il l'aura ou un effet ?
- Sniper Shot (1310687, 1310785, 1310786) : effet et durée de 10 s inconnus.
- Strider Kick 1317257 : effet inconnu.
- Heart of the Lion 409580 : sort lancé ou aura ?
- Counterattack : rang 1 = 19306 ou 1242634 selon le client. Ordre des rangs 20909 et 20910.
- Intimidation : confirmer en jeu l'aura 19577 sur `pet` (buff de 15 s, Wowhead Forever) ; 24394 est l'étourdissement de 3 s sur la cible.
- Freezing Trap : effets 3355, 14308, 14309. Frost Trap : aura 13810.
- Munitions : existence de la mécanique sur Forever, et comptage de l'emplacement 0 (Equipment Slot) ; ID d'objet seulement en repli.
- Cower : le sort 1742 est un sort du familier ; l'aura sur `pet` n'est pas confirmée.

## 7. Tests en jeu propres à la classe

À ajouter à la grille commune de `PLAN-AURAS-CLASSES.md` section 4.

1. Aspect : changer d'aspect, le rappel disparaît, l'icône Entretien suit. Vérifier chaque aspect appris.
2. Auto Shot : la barre de swing démarre au premier tir, repart à chaque tir, s'arrête sans cible.
3. Raptor Strike : l'icône se met en lueur entre l'activation et le coup, rouge hors de la portée de mêlée.
4. Zone morte : cible à 6 m, Aimed Shot et Arcane Shot rouges, Raptor Strike rouge aussi. Cible à 3 m, Raptor Strike non rouge.
5. Mongoose Bite et Counterattack : l'icône n'apparaît qu'après une esquive ou une parade, jamais sans.
6. Familier : appeler, renvoyer, tuer, ressusciter. Rappels absent et mort, barre de vie, Mend Pet actif sur le familier en combat.
7. Auras sur `pet` en combat : Bestial Wrath, Frenzy, Mend Pet. Vérifier qu'elles s'affichent comme sur `player`.
8. Pièges : poser Freezing Trap puis Frost Trap. La recharge est-elle partagée entre les quatre pièges ?
9. Debuffs cible en combat : Serpent Sting, Hunter's Mark, Black Arrow, Lacerate, Wing Clip, Concussive Shot, rafraîchis pendant le combat.
10. Feign Death : la cible perd l'aggro, l'icône Utilitaires grise, aucune erreur au relèvement.
11. Rapid Fire : l'icône passe de la recharge à la durée du buff (double état) et revient à la recharge.
12. Barre d'incantation : Aimed Shot affiche la barre, un déplacement l'interrompt, la barre disparaît.
13. Règle des 5 s : la barre démarre à chaque sort à mana et se vide en 5 s.
14. Munitions : retirer les munitions, le rappel apparaît. Vérifier d'abord que la mécanique existe sur Forever.
15. Personnage bas niveau : seuls Raptor Strike, Arcane Shot, Serpent Sting, Hunter's Mark, Mend Pet, Wing Clip, aspects de base chargent.
16. Familier tué en combat : le rappel Familier absent apparaît en combat (Conditions, sans valeur secrète) ; Revive Pet le fait disparaître.
17. Swing de mêlée : la barre démarre au coup de mêlée et se vide ; vérifier d'abord que Swing Timer existe sur Forever.
18. Portée de Raptor Strike : si l'icône ne rougit jamais hors mêlée, mesurer la portée sur Wing Clip.
19. Doubles états d'Utilitaires (Feign Death, Scatter Shot, Distracting Shot, Intimidation) : lueur pendant l'effet, retour à la recharge.

## 8. Écart avec la v1 (`PackChasseur.lua`)

Ajouter :

- Rappels : Familier absent, Familier mort, Munitions basses. La v1 n'a que Aspect, Trueshot et MANA BAS.
- Effets : Hébété (15571), Lacerate, Bestial Wrath et Frenzy et Mend Pet, Intimidation et Cower sur `pet`.
- Utilitaires : doubles états (recharge puis durée de l'effet) pour Deterrence, Feign Death, Scatter Shot, Distracting Shot, Intimidation.
- Barres : swing de mêlée sous Auto Shot.
- Principal : Raptor Strike passe d'un proc à une icône de rotation avec QA, Bestial Wrath et Rapid Fire y rejoignent Arcane Shot, Multi-Shot et Aimed Shot.
- Débordement : Sniper Shot, Summon Hawk, Distracting Shot (sorts Forever absents de la v1, Distracting Shot présent dans la table du DB2).
- Utilitaires : Tranquilizing Shot (19801), Strider Kick (1317257).
- Entretien : rangée dédiée avec Aspect actif, Trueshot Aura et Heart of the Lion (409580).
- Style : zoom, bordure, lueur à l'apparition, alpha hors combat et sans cible, texte de durée coloré.

Changer :

- Rotation v1 : Concussive Shot quitte la rotation pour Utilitaires.
- Procs v1 : Mongoose Bite et Counterattack passent dans Effets.
- Cooldowns v1 : les 11 icônes passent dans Utilitaires (traps, Feign Death, Deterrence, Disengage, Scatter Shot, Intimidation) ou Principal (Rapid Fire, Bestial Wrath).
- Buffs v1 : Rapid Fire et Deterrence passent dans Effets. Aspect of the Hawk sort du pack de buffs et rejoint Entretien avec les autres aspects.
- Barre Familier v1 : garde sa fonction, change de rangée.
- Règle des 5 s : liste de sorts complétée avec tous les rangs.
- MANA BAS : le texte disparaît, la barre de mana change de couleur sous 20 %.

Retirer :

- Viper Sting et Scorpid Sting (debuffs v1).
- Rappel MANA BAS en texte.
- Les rappels listés en un seul texte pour les aspects, remplacés par une aura par aspect.

## 9. Besoins du générateur propres à la classe

Seulement ce que `PLAN-AURAS-V2.md` section 5 ne couvre pas.

1. Trigger d'existence du familier : Health sur `pet` ne dit pas « familier absent ». Le trigger Conditions du joueur a une case « a un familier (vivant) » (`HasPet`, tri-état), à inverser pour le rappel. Elle ne distingue pas absent et mort : Familier mort reste sur Health `pet`. À exposer dans le générateur et à tester en jeu.
2. Rangée Familier : barre 390x8 sous la barre Secondaire (y = -80), avec Incantation décalée à -95. Le socle commun n'a pas cette rangée.
3. Auras SA sur l'unité `pet` : le générateur doit accepter `unit = "pet"` pour `secretAura`. À vérifier en jeu avant d'écrire la rangée Effets familier.
4. Emplacement d'aspect : une aura par aspect dans un seul emplacement d'Entretien, grisé quand vide, sur le modèle des totems (point 3 du socle).
5. Munitions sans ID fixe : trigger Cooldown Progress (Equipment Slot) sur l'emplacement 0, avec compteur en texte (remplace Item Count pour la classe). Seulement si les munitions existent sur Forever.
6. Barre Swing Timer sur la main `main` en plus de `ranged` (mêlée du chasseur), fine et empilée sous Auto Shot.
7. Option par icône « sur recharge seulement ou toujours » pour les Utilitaires, et doubles états sur ces icônes.

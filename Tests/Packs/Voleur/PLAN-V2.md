# Plan v2 du pack Voleur (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Format : `PLAN-AURAS-V2.md` section 6, point 1. Plan seul : aucun code, aucune chaîne d'import.

Classe `ROGUE`, racine `Voleur (Musca)`, préfixe d'uid v2 `mcRogueV2`. Les états suivent `PLAN-AURAS-V2.md` section 1 :
**acquis** (type de trigger testé en combat sur Forever, table de `PLAN-AURAS-CLASSES.md` section 3), **à tester**, **bloqué**.
« Acquis » vaut pour le type de trigger. Les IDs d'aura propres au voleur restent à confirmer en jeu (section 6).

## 1. Sources et spécialisations couvertes

Sources : `Classes/Rogue.md` (IDs et présence sur Forever, DB2 1.60.1.70245), `PackVoleur.lua` et `NOTES.md` (v1), `RECHERCHE-AURAS-CLASSES.md`
(idées Vahdis, Rogue V3, poisons), `ANALYSE-AURAS-FOJJI.md` section 7 (extras voleur), gabarit Luxthos (rangées) pour la disposition.
Pack décodé : Luxthos Rogue (Classic Era), analysé dans `ANALYSE-LUXTHOS.md` (même dossier).
Idées seulement : aucun nom, code ni chaîne repris.

Arbres Classic de Forever :

| Spé | Talents qui chargent ses auras | Rôle |
|---|---|---|
| Assassination | Mutilate 1310707, Cold Blood 14177, Venom 1310703, Seal Fate 14186 | dégâts, daguées |
| Combat | Blade Flurry 13877, Adrenaline Rush 13750, Riposte 14251 | dégâts, armes variées |
| Subtlety | Hemorrhage 16511, Ghostly Strike 14278, Premeditation 14183, Preparation 14185 | dégâts, daguées, ouverture furtive |

Aucun rôle de tank ni de soigneur pour le voleur. Un seul rôle : dégâts.

Styles de jeu et ce qui change :

- **Solo et montée de niveau** : rangs bas, peu de talents. Charger par `spellknown` du rang 1. Garder Principal court. Sap et Distract hors combat ne sont pas suivis.
- **Donjon** : interruption (Kick), contrôle (Gouge, Kidney Shot, Blind), Feint, Redirect, Expose Armor facultatif.
- **Raid** : Expose Armor, Slice and Dice sans trou, poisons à jour, Feint, Vanish.

## 2. Tables par rangée

Colonnes : aura, décision qu'elle change, trigger Musca, IDs (tous les rangs, `Classes/Rogue.md`), chargement, conditions et style, état.
Style commun de `PLAN-AURAS-V2.md` section 3 appliqué partout (zoom 0,3, bordure noire, texte natif, alpha 0,4 hors combat et sans cible sur Principal et Utilitaires).
Légende : « recharge » = grisée en recharge, rouge hors de portée, bleue si l'énergie manque.

### 2.1 Rappels (y +150, hors combat, cachés en zone de repos)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Poison main droite | Poser ou rafraîchir avant le pull | Weapon Enchant, emplacement main droite | aucun ID de sort (par emplacement) | classe ROGUE, `spellknown` 8681 ou 2835 ou 3420 (poisons dès le niveau 20) | affiché si absent ou reste ≤ 300 s ; texte rouge ; zone de repos : caché | acquis (type) |
| Poison main gauche | idem, main gauche | Weapon Enchant, emplacement main gauche | idem | idem, arme en main gauche équipée (option de chargement à vérifier) | idem | à tester (chargement par arme) |
| Stock de poisons bas | Acheter ou fabriquer avant le donjon | Item Count | IDs d'objet absents de `Classes/Rogue.md` | classe ROGUE | seuil de nombre ; icône de la fiole | bloqué (ID d'objet à relever) |

### 2.2 Effets (y +60, icônes 32)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Slice and Dice actif | Rafraîchir avant la fin | Blizzard Cooldown Manager ; repli Aura (Modern) player | 5171, 6774 | `spellknown` 5171 | texte de durée natif ; seuil de couleur sous 3 s par la courbe native de `secretAura` (pas sur le CDM) | acquis (CDM), à tester (seuil) |
| Slice and Dice absent | Le poser maintenant | Aura (Modern) player, mode « absent » | 5171, 6774 | `spellknown` 5171, cible hostile | apparition = lueur fixe ; aucun son | à tester (absence en combat) |
| Rupture sur la cible | Poser ou rafraîchir le DoT | Aura (Modern) target HARMFUL, posé par le joueur | 1943, 8639, 8640, 11273, 11274, 11275 | `spellknown` 1943 | durée native ; lueur à l'apparition | acquis (type) ; ID d'aura à confirmer |
| Garrote sur la cible | Idem | Aura (Modern) target | 703, 8631, 8632, 8633, 11289, 11290 | `spellknown` 703 | durée native | acquis (type) ; ID à confirmer |
| Deadly Poison sur la cible | Entretien des charges du poison | Aura (Modern) target | 2818, 2819, 11353, 11354, 25349 et 434312 à 434316 ; 3583, 13582, 21787 | `spellknown` 2835 | cumuls en texte natif `%s`, sans condition sur leur valeur | à tester (cumuls en combat) ; IDs à confirmer |
| Expose Armor sur la cible | Savoir si l'armure est baissée | Aura (Modern) target | 8647, 8649, 8650, 11197, 11198 | `spellknown` 8647 | durée native | acquis (type) ; ID à confirmer |
| Hemorrhage sur la cible | Entretien du debuff | Aura (Modern) target | 16511 | `spellknown` 16511 | durée native | à tester ; ID à confirmer |
| Venom actif | Garder le finisher à jour | Aura (Modern) player | 1310703 | `spellknown` 1310703 | lueur à l'apparition ; durée native | à tester ; ID à confirmer |
| Étourdissement sur la cible | Savoir que la cible est étourdie | Aura (Modern) target | Kidney Shot 408, 8643 ; Cheap Shot 1833 | `spellknown` 408 ou 1833 | icône du sort posé ; durée native | acquis (type) ; ID à confirmer |
| Incapacité sur la cible | Ne pas casser Gouge, Blind ou Sap | Aura (Modern) target | Gouge 1776, 1777, 8629, 11285, 11286 ; Blind 2094 ; Sap 6770, 2070, 11297 | `spellknown` 1776 ou 2094 ou 6770 | icône du sort posé ; durée native | acquis (type) ; ID à confirmer |
| Blind sur n'importe quelle cible | Savoir si un Blind est posé ailleurs que sur la cible | Aura (Modern) sur toute unité hostile | 2094 | `spellknown` 2094 | durée native | bloqué (aucune unité « toutes » dans Musca, à vérifier) |
| Riposte disponible | Placer Riposte après une parade | Action Usable ; repli Cooldown Progress avec l'état « utilisable » (grisée tant qu'elle ne l'est pas) | 14251 | `spellknown` 14251 | apparition = lueur fixe | à tester |
| Thousand Cuts (cumuls) | Suivre les cumuls d'énergie | Aura (Modern) player | 1310721 ou 1310723 | `spellknown` du talent (ID à trancher) | cumuls en texte natif | à tester ; ID à confirmer |
| Remorseless Attacks actif | Profiter du crit après un kill | Aura (Modern) player | 14144, 14148 (talent) ; ID de l'aura non établi | `spellknown` 14144 | lueur à l'apparition | bloqué (ID d'aura inconnu, à relever en jeu) |

### 2.3 Principal (y 0, icônes 44, 8 au plus par variante)

Icônes de sort : Cooldown Progress (Spell) pour la recharge, la portée et l'énergie. Les sorts sans recharge n'utilisent que portée et énergie.
Les entrées marquées « double » portent deux états (recharge, puis durée du buff) : à vérifier (`PLAN-AURAS-V2.md` section 5, point 8).

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mutilate | Constructeur d'Assassination | Cooldown Progress (Spell) | 1310707, 399956, 1241582, 1241584 | `spellknown` 1310707 | recharge ; grisée si arme non adaptée | acquis (type) ; ID à confirmer |
| Backstab | Constructeur sur dague, dans le dos | Cooldown Progress (Spell) | 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300 | `spellknown` 53 | recharge ; grisée si le sort n'est pas utilisable (arme) | acquis (type) ; usage « non utilisable » à tester |
| Sinister Strike | Constructeur de Combat | Cooldown Progress (Spell) | 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294 | `spellknown` 1752 ET non `spellknown` 1310707 (tristate à vérifier) | recharge | acquis (type) |
| Eviscerate | Finisher de dégâts | Cooldown Progress (Spell) | 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016 | `spellknown` 2098 | recharge | acquis (type) |
| Rupture | Finisher DoT | Cooldown Progress (Spell) | 1943, 8639, 8640, 11273, 11274, 11275 | `spellknown` 1943 | recharge | acquis (type) |
| Venom | Finisher d'Assassination | Cooldown Progress (Spell) | 1310703 | `spellknown` 1310703 | recharge | à tester (coût non lu) |
| Cold Blood (double) | Placer le crit garanti | Cooldown Progress puis Aura (Modern) player | 14177 | `spellknown` 14177 | recharge, puis durée du buff avec lueur | à tester (double état) |
| Hemorrhage | Constructeur de Subtlety | Cooldown Progress (Spell) | 16511 | `spellknown` 16511 | recharge | à tester (présence sur Forever divergente) |
| Ghostly Strike (double) | Esquive et dégâts | Cooldown Progress puis Aura (Modern) player | 14278 | `spellknown` 14278 | recharge, puis 7 s avec lueur | à tester (double état) |
| Premeditation (double) | Points de combo avant l'ouverture | Cooldown Progress puis Aura (Modern) player | 14183 | `spellknown` 14183 | recharge, puis fenêtre de 20 s | à tester (double état) |
| Preparation | Remettre les recharges à zéro | Cooldown Progress (Spell) | 14185 | `spellknown` 14185 | recharge | acquis (type) |
| Blade Flurry (double) | Vitesse d'attaque en AoE | Cooldown Progress puis Aura (Modern) player | 13877 | `spellknown` 13877 | recharge, puis 15 s avec lueur | à tester (double état) |
| Adrenaline Rush (double) | Gros burst d'énergie | Cooldown Progress puis Aura (Modern) player | 13750 | `spellknown` 13750 | recharge, puis 15 s avec lueur | à tester (double état) |

Occupation par variante (jamais plus de 8) :

- Assassination : Mutilate, Backstab, Eviscerate, Rupture, Venom, Cold Blood = 6.
- Combat : Sinister Strike, Backstab (grisé sans dague), Eviscerate, Rupture, Blade Flurry, Adrenaline Rush = 6.
- Subtlety : Backstab, Hemorrhage, Eviscerate, Rupture, Ghostly Strike, Premeditation, Preparation = 7.
- Hybride Assassination et Combat : 8 (Mutilate, Backstab, Eviscerate, Rupture, Venom, Cold Blood, Blade Flurry, Adrenaline Rush). Sinister Strike se cache.

### 2.4 Débordement (y -30, icônes 36)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Expose Armor | Baisser l'armure en raid | Cooldown Progress (Spell) | 8647, 8649, 8650, 11197, 11198 | `spellknown` 8647 | recharge | acquis (type) |
| Ambush (ouverture) | Ouvrir depuis la furtivité | Aura Stealth ET Cooldown Progress, activation « tous » | Ambush 8676, 8724, 8725, 11267, 11268, 11269 ; Stealth 1784 à 1787 | `spellknown` 8676 | visible en furtivité seulement ; énergie bleue | à tester (deux triggers) |
| Garrote (ouverture) | Ouvrir par un DoT silencieux | idem | Garrote 703, 8631, 8632, 8633, 11289, 11290 ; Stealth idem | `spellknown` 703 | idem | à tester |
| Cheap Shot (ouverture) | Ouvrir par un étourdissement | idem | Cheap Shot 1833 ; Stealth idem | `spellknown` 1833 | idem | à tester |

### 2.5 Utilitaires (y -120, icônes 32)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Kick | Interrompre un sort | Cooldown Progress (Spell) | 1766, 1767, 1768, 1769 | `spellknown` 1766 | recharge ; rouge hors de portée ; bleue si l'énergie manque | acquis (type) |
| Kidney Shot | Étourdir avec les points de combo | Cooldown Progress (Spell) | 408, 8643 | `spellknown` 408 | recharge ; bleue si l'énergie manque | acquis (type) |
| Gouge | Casser le contact | Cooldown Progress (Spell) | 1776, 1777, 8629, 11285, 11286 | `spellknown` 1776 | recharge ; bleue si l'énergie manque | acquis (type) |
| Blind | Contrôle de longue durée | Cooldown Progress (Spell) | 2094 | `spellknown` 2094 | recharge | acquis (type) |
| Vanish (double) | Sortir du combat | Cooldown Progress puis Aura (Modern) player | sorts 1856, 1857 ; auras 11327, 11329 | `spellknown` 1856 | recharge, puis durée de 10 s | à tester (double état, ID d'aura) |
| Evasion (double) | Défensif contre les coups de mêlée | Cooldown Progress puis Aura (Modern) player | 5277 | `spellknown` 5277 | recharge, puis 15 s avec lueur | à tester (double état) |
| Sprint (double) | Fuir ou rattraper | Cooldown Progress puis Aura (Modern) player | 2983, 8696, 11305 | `spellknown` 2983 | recharge, puis 15 s | à tester (double état) |
| Feint | Réduire la menace | Cooldown Progress (Spell) | 1966, 6768, 8637, 11303, 25302 | `spellknown` 1966 | recharge ; bleue si l'énergie manque | acquis (type) |
| Redirect | Reporter les points de combo | Cooldown Progress (Spell) | 438040 | `spellknown` 438040 | recharge | acquis (type) |

Affichage des utilitaires : par défaut visibles en recharge seulement ; variante « toujours visibles » par deux triggers Cooldown Progress (`showAlways`, `showOnCooldown`) : à tester.
Kidney Shot et Gouge : durée de l'effet posé sur la cible dans la même icône que la recharge, comme pour les états doubles : à tester (même point que `PLAN-AURAS-V2.md` section 5, point 8).

### 2.6 Entretien (y -160, icônes 32)

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Poison main droite | Voir le temps restant | Weapon Enchant, main droite | par emplacement | `spellknown` 8681 ou 2835 ou 3420 | texte de durée coloré sous 5 min ; alpha 0,5 quand vide | acquis (type) |
| Poison main gauche | Idem | Weapon Enchant, main gauche | par emplacement | idem + arme en main gauche | idem | à tester (chargement par arme) |
| Furtivité (état) | Savoir que l'ouverture est disponible | Aura (Modern) player ; recharge de Stealth en repli | 1784, 1785, 1786, 1787 ; Vanish 11327, 11329 | `spellknown` 1784 | lueur fixe tant que actif ; grisée en recharge | à tester (aura distincte du sort non établie) |

### 2.7 Barres

| Aura | Décision | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Ressource : énergie (390x18) | Attendre ou frapper | Power, énergie (type 3) | sans objet | classe ROGUE | jaune, texte `%c` natif ; couleur fixe ; couleur par seuil : bloqué (énergie secrète) | à tester (énergie ; Power testé sur mana), bloqué (seuil) |
| Secondaire : points de combo (5 segments, 390x10) | Choisir le moment du finisher | Power, points de combo (type 4), une aura par point, « afficher à partir de la valeur » | sans objet | classe ROGUE, cible hostile | segments 1 à 3 jaunes, 4 d'une couleur distincte, 5 rouge ; remise à zéro sans cible | à tester (`GetComboPoints` est lisible en combat selon les règles Forever) |
| Incantation (390x16) | Voir une canalisation ou un crochetage | Cast, unité player | sans objet | classe ROGUE | visible pendant un cast seulement | à tester (trigger natif à vérifier) |

Totaux : Rappels 3, Effets 14, Principal 13 (6 à 8 chargées), Débordement 4, Utilitaires 9, Entretien 3, barres 3 (7 régions avec les 5 segments).

## 3. Variantes par spé, forme ou talent

Le voleur n'a ni forme ni posture. Les variantes passent par `spellknown`.

| Variante | Auras chargées de plus | Auras cachées |
|---|---|---|
| Aucun talent (montée de niveau) | Sinister Strike, Backstab, Eviscerate | Mutilate, Venom, Cold Blood, Hemorrhage, Ghostly Strike, Premeditation, Preparation, Blade Flurry, Adrenaline Rush |
| Assassination | Mutilate, Venom, Cold Blood | Sinister Strike (non `spellknown` 1310707) |
| Combat | Blade Flurry, Adrenaline Rush, Riposte (Effets) | Mutilate, Venom |
| Subtlety | Hemorrhage, Ghostly Strike, Premeditation, Preparation | Sinister Strike si Mutilate connu |
| Ouverture furtive (toutes spés) | Ambush, Garrote, Cheap Shot (Débordement), visibles en furtivité | rien |

Règles :

- Le chargement de Sinister Strike repose sur un tristate « non connu » de `spellknown` : à vérifier dans Musca.
- Si l'état double (section 2.3) ne marche pas, Cold Blood, Blade Flurry, Adrenaline Rush, Premeditation, Ghostly Strike, Vanish, Evasion et Sprint se scindent en deux auras : recharge en Principal ou Utilitaires, buff actif en Effets avec lueur.
- Les builds hybrides cumulent leurs auras. Le plafond de 8 icônes en Principal tient pour les builds testés (section 7).

## 4. Rappels

| Rappel | Trigger | Hors combat | Zone de repos |
|---|---|---|---|
| Poison main droite absent ou ≤ 300 s | Weapon Enchant, main droite | oui | caché |
| Poison main gauche absent ou ≤ 300 s | Weapon Enchant, main gauche | oui | caché |
| Stock de poisons bas | Item Count | oui | caché |

Le troisième rappel reste bloqué faute d'ID d'objet. Pas de rappel de Slice and Dice : il ne se pose qu'au pull (aura « absent » en Effets).

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Tick d'énergie | bloqué : lecture de puissance secrète, comparaison avant / après de l'énergie, déduction par journal de combat |
| Seuil de son ou de lueur sur l'énergie ou la durée | bloqué : comparaison d'une valeur secrète |
| Couleur du temps restant en combat sur le CDM (Slice and Dice, Rupture) | bloqué sur le CDM ; passer par `secretAura`, dont la courbe de couleur native marche en combat (à tester) |
| Compteurs de procs sans aura (Seal Fate, Ruthlessness, Relentless Strikes, Setup, Initiative) | bloqué : journal de combat ; et ils ne changent pas une décision |
| Détection « dans le dos » pour Backstab, Ambush, Garrote | bloqué : aucun trigger natif de position |
| Réussite d'un Kick (silence posé) | bloqué : journal de combat |
| Premeditation détecté par la réussite du sort, marquage « posé en furtivité » de Rupture et Garrote | bloqué : journal de combat ; la fenêtre de Premeditation passe par l'aura du joueur |
| Désactivation de la barre d'incantation native | à vérifier : nom du cadre sur 12.x et risque de taint ; laisser la barre native tant que non prouvé |
| Sort de l'aura de proc Remorseless Attacks 14143, 14149 ; Exsanguinate 200806 | exclu : absents du DB2 de Forever |
| Remorseless Attacks (aura de proc) | bloqué tant que l'ID n'est pas relevé en jeu |
| Stock de poisons, Blinding Powder | bloqué : ID d'objet absent de `Classes/Rogue.md` |
| Swing main et gauche (v1) | exclu : aucune décision de rotation ne dépend du swing chez le voleur |
| Deadly Throw, Envenom, Shadowstep, Shadow Dance, Fan of Knives, Roll the Bones, Shiv, Surprise Attack | absent du DB2, exclu |
| Wound Poison, Crippling Poison, Mind-numbing Poison (debuffs cible, v1) | exclu : posés par proc, ne changent pas une décision ; le poison d'arme reste suivi en Entretien |
| Stealth (recharge de 10 s), Distract (v1) | exclu : sans décision en combat |
| Pick Pocket 921, Pick Lock, Disarm Trap, Safe Fall, Detect Traps | exclu : hors combat, aucune alerte utile |
| Coup de Grace 1310709 | exclu : coût, recharge et effet non lus ; à documenter avant tout ajout |

## 6. IDs à confirmer en jeu

À relever avec `/dump` sur `C_UnitAuras` (commande `/run` fournie par l'agent `wow-api`, exécutée par l'utilisateur).

| Aura | Candidats | À vérifier |
|---|---|---|
| Slice and Dice, Rupture, Expose Armor, Garrote, Gouge, Kidney Shot, Cheap Shot, Sap, Blind, Hemorrhage, Premeditation, Blade Flurry, Evasion, Sprint, Stealth | ID du sort lancé, aura distincte non établie | l'ID du sort lancé est-il l'ID de l'aura ? |
| Vanish | 1856, 1857 ou 11327, 11329 (18461 « Vanish Purge » écarté) | lequel porte l'aura de 10 s |
| Deadly Poison cible | 2818 ou 434312 (R1), 2819 ou 434313, 11353 ou 434314, 11354 ou 434315, 25349 ou 434316 ; 3583, 13582, 21787 | famille Forever ; nombre de cumuls ; durée de l'aura |
| Crippling Poison R1 | 3409 ou 25809 | hors v2 sauf demande ; à garder en note |
| Occult Poison cible | 458820, 1214170, 462286 | rôle de 462286 |
| Venom | 1310703 (sort et aura ?) | aura distincte du sort ; durée réelle |
| Thousand Cuts | 1310721 ou 1310723 | lequel est l'aura des cumuls |
| Remorseless Attacks | aucun sort déclenché dans le DB2 | ID de l'aura de proc |
| Riposte | 14251 (autres : 5237, 6187, 6569) | Action Usable avec 14251 suffit-il |
| Mutilate | 1310707, 399956, 1241582, 1241584 | chaîne de rangs ; niveau de R1 (30 ou 40) |
| Hemorrhage | 16511 | sort présent sur Forever (divergence entre sources) |
| Hack and Slash, Quietus, Cutthroat | candidats multiples | hors v2 (aucune aura prévue) |
| Poisons d'arme | emplacement, pas d'ID | texture affichée par Weapon Enchant selon le poison |

## 7. Tests en jeu propres au voleur

En plus de la grille commune (`PLAN-AURAS-CLASSES.md` section 4) :

1. Entrer en furtivité hors combat : Ambush, Garrote et Cheap Shot apparaissent en Débordement et disparaissent à la sortie.
2. Vanish en combat : l'ouverture apparaît, Vanish passe en état « durée », la recharge reprend ensuite.
3. Points de combo : 1 à 5 segments, changement de cible, mort de la cible, Redirect, `/reload` en combat.
4. Slice and Dice : actif, absent en combat, rafraîchi avant la fin, Cooldown Manager actif ou non.
5. Poisons : main droite seule, deux armes, poison expirant sous 5 min, rappel caché en zone de repos.
6. Arme en main gauche retirée : rappel et icône de la main gauche disparaissent.
7. Mutilate appris : Sinister Strike se cache ; Mutilate oublié : il revient.
8. Backstab avec une épée : l'icône est grisée ou masquée, sans erreur.
9. Riposte : apparition après une parade, disparition à la fin.
10. Cold Blood, Premeditation, Adrenaline Rush, Blade Flurry : état double (recharge puis buff) et retour à la recharge.
11. Preparation : les icônes de Vanish, Evasion, Sprint, Kick et Kidney Shot repassent en « prêt » sans clignoter.
12. Deadly Poison : cumuls affichés en texte en combat, présence du debuff sur 5 cumuls.
13. Trois builds hybrides (Assassination et Combat, Combat et Subtlety, Subtlety et Assassination) : au plus 8 icônes en Principal.
14. Personnage bas niveau (niveau 10) : seuls les rangs connus se chargent, aucune aura de talent.
15. Cible hostile en zone de repos, puis sortie de la zone : rappels masqués puis visibles.
16. Personnage de niveau 19 puis 20 : les rappels de poison n'apparaissent qu'à partir du niveau 20.
17. Furtivité : l'icône d'état s'allume en furtivité, se grise en recharge ; Ghostly Strike en état double.

## 8. Écart avec la v1 (`PackVoleur.lua`)

**Ajouter**

- Principal : Mutilate, Backstab, Sinister Strike, Eviscerate, Rupture, Venom, Hemorrhage (sorts lancés, avec portée et énergie).
- Débordement : Expose Armor (déplacé), Ambush, Garrote, Cheap Shot en ouverture furtive.
- Effets : Slice and Dice absent, Venom actif, Thousand Cuts, Étourdissement, Incapacité, Riposte avec lueur.
- Utilitaires : Feint, Redirect.
- Entretien : poisons main droite et main gauche avec temps restant.
- Barre d'incantation, points de combo en 5 segments, rappel de poison expirant (≤ 300 s).
- Rangées nommées, style commun, alpha hors combat et sans cible.

**Changer**

- Ghostly Strike : de « rotation » vers Principal (état double). Kidney Shot et Gouge : vers Utilitaires.
- Cold Blood, Blade Flurry, Adrenaline Rush, Premeditation, Ghostly Strike : une seule icône à double état (recharge puis buff), au lieu d'une icône de recharge et d'un buff séparé.
- Vanish, Evasion, Sprint : idem en Utilitaires.
- Cheap Shot, Kidney Shot : fusionnés en « Étourdissement ». Gouge, Blind, Sap : fusionnés en « Incapacité ».
- Barre de points de combo : de barre unique à 5 segments.
- Barre d'énergie : couleur fixe (couleur par seuil bloquée).
- Slice and Dice : trigger Cooldown Manager, repli Aura (Modern).
- Rappels de poison : texte vers icônes, masqués en zone de repos.

**Retirer**

- Swing main droite et main gauche.
- Buffs séparés Stealth, Vanish, Evasion, Sprint, Cold Blood, Blade Flurry, Adrenaline Rush, Premeditation (absorbés par les icônes à double état).
- Recharges Stealth et Distract.
- Debuffs Wound Poison, Crippling Poison, Mind-numbing Poison.

## 9. Besoins du générateur propres au voleur

Hors `PLAN-AURAS-V2.md` section 5. Seulement les besoins réels :

1. **Barre à segments pour les points de combo** : 5 auras Power (type 4) en « afficher à partir de la valeur », 390 px partagés, dernier segment rouge. Le générateur v1 ne sait faire qu'une barre unique.
2. **Deux triggers en activation « tous »** pour l'ouverture (Stealth ET recharge du sort). À vérifier avec le point 8 de la section 5 (icône à double état).
3. **Chargement « non connu »** (tristate `spellknown`) et chargement par arme équipée (main gauche, dague) : cacher Sinister Strike avec Mutilate, masquer le rappel de la main gauche sans seconde arme.
4. **Icône Weapon Enchant par emplacement** avec seuil de 300 s et couleur à 5 min, paramétrable par rangée (Rappels et Entretien).
5. **Item Count en icône** (stock de poisons, Blinding Powder) : le rappel texte existe déjà (`entry.item`) ; manque l'icône, inactive tant que les IDs d'objet manquent.

6. **Chargement par niveau minimal** (poisons dès 20) : option de chargement `level` à vérifier dans Musca.
7. **Icône de cible toujours visible, grisée quand l'aura est absente** (Rupture, Hemorrhage, Slice and Dice) : variante « absente = grisée à demi-alpha » du `secretAura`, comme les totems vides (`PLAN-AURAS-V2.md` section 5, point 3).
8. **Choix « sur recharge / toujours »** des utilitaires, par deux triggers Cooldown Progress.

Pas de besoin pour : barres de familier, indicateur de posture, coup en file (le voleur n'en a pas).

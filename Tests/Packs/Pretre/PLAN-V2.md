# Plan v2 du pack Prêtre (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Socle commun : `PLAN-AURAS-V2.md`. Règles v1 : `PLAN-AURAS-CLASSES.md`.
IDs et présence des sorts sur Forever : `Classes/Priest.md` (DB2 1.60.1.70245). Idées seulement : aucun nom, code ni chaîne repris des packs Luxthos, Fojji ou Wago.

Convention d'état (`PLAN-AURAS-V2.md` section 1) :

- **acquis** : le type de trigger est déjà testé en combat sur Forever (pack chaman). L'ID du Prêtre reste à vérifier par la grille de test.
- **à tester** : trigger natif jamais vu en combat sur Forever, ou ID d'aura incertain.
- **bloqué** : journal de combat ou lecture de valeur secrète.

Chargement : classe `PRIEST`, puis `spellknown` sur le sort ou le talent. Pas de spé lue : `GetSpecialization` n'existe pas sur Forever. Les variantes sortent des sorts connus.

## 1. Sources et specs couvertes

Sources : `Classes/Priest.md` (IDs, rangs, talents), `PackPretre.lua` et `NOTES.md` (v1), `RECHERCHE-AURAS-CLASSES.md` (section Prêtre : rappels Fortitude, Inner Fire et Divine Spirit, DoT multi-cibles, tic des 5 s), `ANALYSE-AURAS-FOJJI.md` section 7 (Prêtre : tic des 5 s, sorts raciaux, Power Word: Shield selon Inner Focus), `ANALYSE-AURAS-LUXTHOS.md` et `ANALYSE-AURAS-WAGO.md` (gabarit commun : rangées, rappels en deux états, seuils de durée), `ANALYSE-LUXTHOS.md` (pack Luxthos Priest décodé : même gabarit que le chaman, 17 icônes Core, 5 icônes de maintenance, effet actif en lueur sur les icônes de recharge).

Arbres de talents Classic de `Classes/Priest.md` :

| Arbre | TabID | Talents qui changent l'affichage |
|---|---|---|
| Discipline | 201 | Inner Focus 14751, Power Infusion 10060, Penance 402174, Divine Spirit 14752, Martyrdom 14531, Divine Aegis (IDs incertains) |
| Sacré | 202 | Prayer of Mending 401859, Binding Heal 401937, Lightwell 724, Holy Nova 15237, Spirit of Redemption 20711, Inspiration 14892 |
| Magie de l'ombre | 203 | Shadowform 15473, Vampiric Embrace 15286, Silence 15487, Mind Flay 15407, Spirit Tap 15270, Shadow Weaving 15257 |

Styles de jeu :

- **Solo et montée** : Ombre ou Discipline, dégâts à distance (Mind Blast, Pain, Holy Fire, Smite, Mind Flay), Power Word: Shield de survie, Renew.
- **Donjon** : soigneur (Sacré ou Discipline) ou Ombre en dégâts. Le soigneur lit surtout ses cadres de groupe. Le pack ne montre que recharges, boucliers et procs perso.
- **Raid** : Sacré, Discipline ou Ombre. Fear Ward, Power Infusion, Shadowfiend, Prayer of Mending.

Variantes de rotation (noms dans les tableaux : O = Ombre, D = Discipline ou solo à sorts sacrés, S = Sacré). Une aura se charge par son propre `spellknown`. Il n'y a pas de test de spé.

## 2. Tables par rangée

Colonnes : décision que l'aura change, trigger Musca, IDs (tous les rangs), chargement, conditions et style, état. Style commun de `PLAN-AURAS-V2.md` section 3 (zoom 0,3, bordure 1 px, grisé en recharge, rouge hors de portée, bleu sans mana). Le texte de recharge est natif.

Les « Cooldown » ci-dessous utilisent Cooldown Progress (Spell). Le rang 1 suffit pour le suivi par nom, les autres rangs sont listés pour la vérification du chargement.

### 2.1 Rappels (icônes 32, hors combat, cachés en zone de repos)

Détail en section 4. Cinq auras :

| Aura | Décision | Trigger | IDs | Chargement | Style | État |
|---|---|---|---|---|---|---|
| Fortitude manquante | Lancer le buff avant le pull | Aura (Modern), joueur, HELPFUL, absente | 1243, 1244, 1245, 2791, 10937, 10938 ; Prayer of Fortitude 21562, 21564 | `spellknown` 1243 | icône pleine, lueur fixe | acquis |
| Inner Fire manquant | Relancer l'armure | Aura (Modern), joueur, absente | 588, 602, 1006, 7128, 10951, 10952 | `spellknown` 588 | idem | acquis |
| Shadowform manquante | Reprendre la forme | Aura (Modern), joueur, absente | 15473 | `spellknown` 15473 | idem | à tester (ID) |
| Divine Spirit manquant | Relancer le buff d'esprit | Aura (Modern), joueur, absente | 14752, 14818, 14819, 27841 ; Prayer of Spirit 27681 | `spellknown` 14752 | idem | à tester |
| Mana basse | Boire ou ralentir | Power, mana, Show only below (%) 20 | type 0 | classe | texte rouge, visible aussi en combat, caché en repos | acquis |

### 2.2 Effets (icônes 32 : procs, buffs courts, debuffs sur la cible)

| Aura | Décision | Trigger | IDs | Chargement | Style | État |
|---|---|---|---|---|---|---|
| Weakened Soul (sur soi) | Bouclier impossible tant qu'il dure | secretAura, joueur, HARMFUL | 6788 | `spellknown` 17 | lueur rouge, temps restant, seuil rouge sous 3 s | à tester (debuff joueur) |
| Spirit Tap | Régénération d'esprit active | secretAura, joueur, HELPFUL | 15271 (déclenché par 15270, 15335 à 15338) | `spellknown` 15270 | lueur à l'apparition | à tester (ID) |
| Inner Focus actif | Prochain sort gratuit | secretAura, joueur | 14751 | `spellknown` 14751 | lueur | acquis |
| Power Infusion actif | Sorts accélérés 15 s | secretAura, joueur | 10060 | `spellknown` 10060 | lueur, seuil rouge sous 5 s | acquis |
| Focused Casting | Incantation sans recul | secretAura, joueur | 27828 (déclenché par Martyrdom 14531, 14774) | `spellknown` 14531 | lueur | à tester (ID) |
| Inspiration | Armure accrue sur la cible du soin | secretAura, joueur ou cible | 14893 ou 14892 (candidats) | `spellknown` 14892 | lueur | à tester (ID) |
| Divine Aegis | Bouclier sur critique | secretAura, joueur | 431622, 431624, 431649 (candidats) | Divine Aegis connu | lueur | à tester (ID) |
| Spirit of Redemption | Forme spirituelle, continuer à soigner | secretAura, joueur | 20711 | `spellknown` 20711 | lueur, temps restant | à tester |
| Elune's Grace (elfe de la nuit) | Esquive accrue 15 s | secretAura, joueur | 2651 | `spellknown` 2651 | lueur | à tester |

Les debuffs et HoT posés par le joueur (Pain, Embrace, Plague, Renew) vivent en Principal (2.3), pas ici. Neuf auras en Effets.

### 2.3 Principal (icônes 44, 8 au plus par variante)

Règle de non-doublon : un sort sans recharge propre (Pain, Embrace, Renew) a une seule icône, en Principal, avec le debuff ou le HoT comme trigger.

Variante O (Ombre) : 5 auras. Variante D (Discipline ou solo) : 8 auras. Variante S (Sacré) : 6 auras.

| Aura | Var. | Décision | Trigger | IDs | Chargement | Style | État |
|---|---|---|---|---|---|---|---|
| Mind Blast | O, D | Lancer à chaque fin de recharge de 8 s | Cooldown Progress | 8092, 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947 | `spellknown` 8092 | grisé en recharge, rouge hors portée, bleu sans mana | acquis |
| Shadow Word: Pain | O, D | Reposer le DoT | secretAura cible HARMFUL, posé par le joueur | 589, 594, 970, 992, 2767, 10892, 10893, 10894 | `spellknown` 589 | texte de durée, rouge sous 3 s, absent : alpha 0,5 grisé | acquis (type) |
| Devouring Plague | O | DoT et soin, 1 min de recharge | double état : Cooldown Progress puis secretAura cible | 2944, 19276, 19277, 19278, 19279, 19280 | `spellknown` 2944 | grisé en recharge, lueur sur cible affectée | à tester (double état) |
| Shadow Word: Death | O, D | Exécution à 15 s de recharge | Cooldown Progress | 1309595, 1309633, 1309635, 1309636 | `spellknown` 1309595 | mêmes quatre conditions | acquis |
| Vampiric Embrace | O | Entretenir le soin passif | secretAura cible | 15286 | `spellknown` 15286 | seuil rouge sous 5 s | à tester (ID) |
| Holy Fire | D | Lancer à 3,5 s, dégâts instantanés puis DoT | Cooldown Progress (portée et mana) | 14914, 15262, 15263, 15264, 15265, 15266, 15267, 15261 | `spellknown` 14914 | rouge hors portée, bleu sans mana | acquis |
| Penance | D | Rafale canalisée de 12 s de recharge | Cooldown Progress | 402174, 1240720, 1240721, 1316995 | `spellknown` 402174 | grisé en recharge | à tester (ID rang 1) |
| Power Word: Shield | D, S | Bouclier de 30 s, recharge 4 s | Cooldown Progress | 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 | `spellknown` 17 | grisé tant que Weakened Soul (lu en 2.2) | acquis |
| Power Infusion | D, S | Gros cooldown de 3 min | Cooldown Progress | 10060 | `spellknown` 10060 | grisé en recharge | acquis |
| Inner Focus | D, S | Sort gratuit de 3 min | Cooldown Progress | 14751 | `spellknown` 14751 | grisé en recharge | acquis |
| Prayer of Mending | S | Rebond de soin toutes les 10 s | Cooldown Progress | 401859, 1240826, 1240827 | `spellknown` 401859 | grisé en recharge | à tester (ID rang 1) |
| Renew sur la cible | S | Rafraîchir le HoT | secretAura cible HELPFUL, posé par le joueur | 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 | `spellknown` 139 | seuil rouge sous 3 s | à tester |
| Lightwell | S | Poser le puits (10 min), puis voir combien de temps il reste (3 min) | Cooldown Progress ; durée du puits posé par le trigger `Totem` (double état) | 724, 27870, 27871 | `spellknown` 724 | grisé en recharge ; lueur et balayage de durée tant que le puits est posé | à tester (le puits peut ne pas occuper d'emplacement de totem) |

Comptes : O = Mind Blast, Pain, Plague, Death, Embrace = 5. D = Mind Blast, Pain, Death, Holy Fire, Penance, Shield, Power Infusion, Inner Focus = 8. S = Shield, Power Infusion, Inner Focus, Prayer of Mending, Renew, Lightwell = 6.

La rangée Effets compte 9 auras, listées en 2.2.

### 2.4 Débordement (icônes 36)

Aucune aura. D est à 8, O à 5, S à 6. Rangée créée vide, utilisable plus tard.

### 2.5 Utilitaires (icônes 32, alpha 0,4 hors combat et sans cible)

| Aura | Décision | Trigger | IDs | Chargement | Style | État |
|---|---|---|---|---|---|---|
| Psychic Scream | Peur de zone, 30 s | Cooldown Progress ; lueur tant que le debuff est sur la cible (secretAura cible HARMFUL, double état) | 8122, 8124, 10888, 10890 | `spellknown` 8122 | grisé en recharge, lueur pendant le debuff | acquis (recharge) ; à tester (double état) |
| Fade | Réduire la menace, 30 s | Cooldown Progress ; lueur pendant l'effet par secretAura joueur (double état) | 586, 9578, 9579, 9592, 10941, 10942 | `spellknown` 586 | grisé en recharge, lueur tant que l'effet dure | acquis (recharge) ; à tester (lueur d'effet) |
| Fear Ward | Protéger contre la peur, 3 min | Cooldown Progress ; lueur tant que le buff est sur la cible amie (secretAura cible HELPFUL, double état) | 6346 | `spellknown` 6346 | grisé en recharge, lueur tant que la protection est posée | acquis (recharge) ; à tester (lueur d'effet) |
| Silence | Interrompre (Ombre) | Cooldown Progress ; lueur tant que le debuff est sur la cible (secretAura cible HARMFUL, double état) | 15487 | `spellknown` 15487 | grisé, rouge hors portée, lueur pendant le debuff | à tester (ID talent, double état) |
| Shadowfiend | Mana et dégâts, 5 min | Cooldown Progress | 401977 | `spellknown` 401977 | grisé en recharge | à tester (niveau 1 douteux) |
| Desperate Prayer (nain) | Soin d'urgence, 10 min | Cooldown Progress | 13908, 19236, 19238, 19240, 19241, 19242, 19243 | `spellknown` 13908 | grisé en recharge | acquis (type) |
| Chastise (nain) | Contrôle, 2 min | Cooldown Progress | 1277331, 1277332, 1277333, 1277334, 1277335 | `spellknown` 1277331 | grisé en recharge | à tester |
| Feedback (humain) | Brûle la mana, 3 min | Cooldown Progress | 13896, 19271, 19273, 19274, 19275 | `spellknown` 13896 | grisé en recharge | à tester |
| Starshards (elfe de la nuit) | Dégâts canalisés, 30 s | Cooldown Progress ; suivi du debuff cible (secretAura cible HARMFUL posé par le joueur, double état) | 10797, 19296, 19299, 19302, 19303, 19304, 19305 | `spellknown` 10797 | grisé en recharge, texte de durée tant que le debuff est sur la cible | à tester |
| Divine Grace (humain) | Recharge de 10 min, effet non décrit | Cooldown Progress | 1277370, 1277371, 1277372, 1277374, 1277376, 1277377, 1277378 | `spellknown` 1277370 | grisé en recharge | à tester |
| Contingency Plan (gnome) | Recharge de 10 min, effet non décrit | Cooldown Progress | 1277462, 1277634, 1277638, 1277639, 1277640 | `spellknown` 1277462 | grisé en recharge | à tester |
| Confounding Flash (gnome) | Recharge de 2 min, 3 s | Cooldown Progress | 1277455 | `spellknown` 1277455 | grisé en recharge | à tester |
| Dark Sacrifice (mort-vivant) | Recharge de 10 min, effet non décrit | Cooldown Progress | 1277324, 1277325, 1277326, 1277327, 1277328 | `spellknown` 1277324 | grisé en recharge | à tester |

Un personnage a une seule race. Il voit au plus 4 raciaux sur 9 sorts raciaux listés (nain 2, humain 2, gnome 2, elfe 2, mort-vivant 1, plus Elune's Grace en Effets). L'effet exact des sorts de recharge 10 min (Divine Grace, Contingency Plan, Dark Sacrifice) n'est pas décrit dans `Classes/Priest.md` : l'icône suit seulement la recharge.

### 2.6 Entretien (icônes 32, buffs longs, grisés et à alpha 0,5 quand absents)

| Aura | Décision | Trigger | IDs | Chargement | Style | État |
|---|---|---|---|---|---|---|
| Inner Fire | Armure de 10 min, charges natives | secretAura, joueur | 588, 602, 1006, 7128, 10951, 10952 | `spellknown` 588 | texte du temps restant rouge sous 2 min, charges en texte natif | acquis |
| Power Word: Fortitude | Buff d'une heure | secretAura, joueur | 1243, 1244, 1245, 2791, 10937, 10938, 21562, 21564 | `spellknown` 1243 | rouge sous 5 min | acquis |
| Divine Spirit | Buff d'une heure | secretAura, joueur | 14752, 14818, 14819, 27841, 27681 | `spellknown` 14752 | rouge sous 5 min | à tester |
| Shadowform | Forme active | secretAura, joueur | 15473 | `spellknown` 15473 | lueur permanente | à tester (ID) |
| Touch of Weakness (mort-vivant) | Buff de 2 min | secretAura, joueur | 2652, 19261, 19262, 19264, 19265, 19266 | `spellknown` 2652 | rouge sous 30 s | à tester |
| Shadowguard (troll) | Buff de 10 min | secretAura, joueur | 18137, 19308, 19309, 19310, 19311, 19312 | `spellknown` 18137 | rouge sous 2 min | à tester |
| Shadow Protection | Résistance à l'ombre, 10 min (20 min en prière) | secretAura, joueur | 976, 10957, 10958 ; Prayer of Shadow Protection 27683 | `spellknown` 976 | rouge sous 2 min | à tester |
| Hex of Weakness (troll) | Debuff cible de 2 min | secretAura, cible HARMFUL | 9035, 19281, 19282, 19283, 19284, 19285 | `spellknown` 9035 | rouge sous 30 s | à tester |

### 2.7 Ressource (barre 390x18)

| Aura | Décision | Trigger | Style | État |
|---|---|---|---|---|
| Barre de mana | Ralentir ou boire | Power, joueur, mana (type 0), texte natif `%p` | bleu uni, fond noir 50 %, couleur fixe ; couleur par seuil : bloqué (mana secrète) | acquis (barre), bloqué (seuil) |

### 2.8 Secondaire (barre 390x10)

| Aura | Décision | Trigger | IDs | Style | État |
|---|---|---|---|---|---|
| Règle des 5 s | Savoir quand la mana revient | Spell Cast Succeeded, durée fixe 5 s | tous les rangs de : Mind Blast, Pain, Smite, Holy Fire, Mind Flay, Lesser Heal, Heal, Flash Heal, Greater Heal, Renew, Power Word: Shield, Prayer of Healing, Penance, Binding Heal, Prayer of Mending, Devouring Plague, Shadow Word: Death | barre grise qui se vide, cachée hors besoin | à tester |

Les IDs de rang sont tous dans `Classes/Priest.md`. Fade, Inner Fire, Fortitude et Psychic Scream ne déclenchent pas la barre dans le jeu (confirmé par `NOTES.md` v1).

### 2.9 Incantation (barre 390x16)

| Aura | Décision | Trigger | Style | État |
|---|---|---|---|---|
| Barre d'incantation du joueur | Voir le cast de Holy Fire, Heal, Greater Heal, la canalisation de Mind Flay et de Penance | Cast, joueur, avec canalisations | rouge uni, nom du sort à gauche, temps à droite | à tester (canalisation) |

## 3. Variantes par spé, forme ou talent

| Variante | Sorts qui la déclenchent | Auras qui s'ajoutent | Auras qui disparaissent |
|---|---|---|---|
| Ombre (O) | 15473 Shadowform, 15286 Vampiric Embrace, 15487 Silence | Devouring Plague (recharge puis debuff), Vampiric Embrace, Shadowform en Entretien, Spirit Tap en Effets | Holy Fire, Penance, Prayer of Mending (non connus) |
| Discipline (D) | 14751 Inner Focus, 10060 Power Infusion, 402174 Penance, 14752 Divine Spirit | Holy Fire, Penance, Inner Focus, Power Infusion, Focused Casting, Divine Aegis | Shadowform, Embrace, Plague (selon talents) |
| Sacré (S) | 401859 Prayer of Mending, 401937 Binding Heal, 724 Lightwell, 20711 Spirit of Redemption | Prayer of Mending, Renew sur la cible, Lightwell, Inspiration, Spirit of Redemption | Shadow Word: Death (si non appris) |
| Solo, bas niveau | rangs bas | seulement les sorts appris | tout le reste |

Chaque aura utilise son propre `spellknown`. Une build mixte (Discipline avec Shadowform par exemple) charge l'union des deux variantes. Principal est alors limité à 8 par la règle de l'ordre de priorité : Mind Blast, Pain, Death, Holy Fire, Penance, Shield, Power Infusion, Inner Focus, puis les autres auras sont masquées par le plafond du groupe.

En Shadowform, les sorts sacrés ne sont pas lançables (comportement Classic). L'état « sort non utilisable » n'est pas lu. Les icônes sacrées se grisent par la condition de ressource et de portée uniquement. À tester.

## 4. Rappels

Visibles hors combat uniquement, cachés en zone de repos (option de chargement à vérifier dans Musca, `PLAN-AURAS-V2.md` section 5 point 5).

| Rappel | Trigger | Visible quand |
|---|---|---|
| Fortitude manquante | Aura (Modern), joueur, absente, ID de 2.1 | hors combat, hors repos, sort connu |
| Inner Fire manquant | idem | idem |
| Shadowform manquante | idem | idem, `spellknown` 15473 ; disparaît à l'activation |
| Divine Spirit manquant | idem | idem, `spellknown` 14752 |
| Mana basse | Power sous 20 % | hors repos, aussi en combat |

Un buff posé par un autre prêtre compte comme présent (filtre sans « posé par le joueur »). Les rappels pour les autres joueurs ne sont pas possibles : leurs auras sont secrètes en combat et leur identité est restreinte.

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Vampiric Touch | absent du DB2, exclu |
| Holy Concentration, Clearcasting | absent du DB2, exclu |
| Pain Suppression, Circle of Healing, Dispersion, Holy Word, Symbol of Hope, Surge of Light | absents du DB2, exclus |
| Shoot (baguette) et minuteur de baguette | absent de `Classes/Priest.md`, exclu |
| Sacred Candle (réactif des prières) | ID d'objet absent de `Classes/Priest.md`, Item Count exclu |
| Debuff de Holy Fire | aucun ID d'aura dans le DB2, exclu |
| Ralentissement de Mind Flay | aucun ID d'aura dans le DB2, exclu |
| Blackout (étourdissement 3 s, 15269) | n'aide aucune décision, exclu |
| Aura 33371 sur Mind Blast (lueur à 2 piles) | absente de `Classes/Priest.md`, exclue ; la lueur par comparaison de piles serait de toute façon une valeur secrète |
| Focused Casting 14743 | absent de `Classes/Priest.md`, exclu ; on garde 27828 déclenché par Martyrdom |
| Phase du tic de mana (curseur à 2 s) | compare la mana avant et après un lancement, valeur secrète en combat, bloqué ; seule la règle des 5 s reste |
| Holy Purpose 1284536 (déclenché par Searing Light) | effet non documenté dans le DB2, exclu |
| Blessed Recovery (27811, 27813, 1240755) | candidats non départagés, pas de décision, exclu |
| Compteurs de procs sans aura, tic de Mind Flay, tic de mana | journal de combat, bloqué |
| Rebonds de Prayer of Mending | journal de combat, bloqué |
| Durée restante d'un bouclier ou valeur d'absorption | valeur secrète, bloqué (texte natif d'affichage seulement) |
| Seuil de couleur sur les charges d'Inner Fire | comparaison d'une valeur secrète, bloqué (charges en texte natif) |
| Shadow Weaving (15258) | piles secrètes en combat, aucune décision, retiré de v1 |
| Suivi des buffs ou debuffs sur tout le groupe, dispel automatique | noms et auras secrets en combat, bloqué |
| Smite, Lesser Heal, Heal, Flash Heal, Greater Heal, Prayer of Healing, Holy Nova, Binding Heal | sorts sans recharge, icône inutile, utilisés seulement pour la règle des 5 s |
| Dispel Magic, Cure Disease, Abolish Disease, Levitate, Mind Control, Shackle Undead, Mana Burn, Mind Soothe, Mind Vision, Resurrection | sans recharge ni aura qui change une décision, exclus |
| Power Word: Shield 27607 | présent dans SpellName seulement, non retenu par `Classes/Priest.md` |

## 6. IDs à confirmer en jeu

| Aura | Candidats | À vérifier |
|---|---|---|
| Weakened Soul | 6788 | debuff joueur sur soi après un Shield ; ID réel de l'aura |
| Vampiric Embrace | 15286, 15290, 461966, 1237618 | debuff sur la cible ou buff sur soi, quel ID porte l'aura (15286 peut-être un debuff de la cible posé par le joueur) |
| Shadowform | 15473, 16592, 22917, 401980, 412527, 412569, 426223, 1213334 | quel ID est le buff du joueur |
| Spirit Tap | 15271 | l'aura posée après une mort de mob |
| Inspiration | 14892, 14893 | quel ID est l'aura |
| Divine Aegis | 431622, 431624, 431649 | existence du talent en jeu, ID de l'aura |
| Spirit of Redemption | 20711, 27792, 27795, 27827 | quel ID s'affiche à la mort |
| Fear Ward | 6346, 459699 | ID du buff sur la cible |
| Renew | 139 à 25315 et 425268 à 425277 | si les IDs 4252xx sont une autre aura |
| Prayer of Mending | 401859, 1240826, 1240827 et 401863 | ID du sort lancé et ID du buff du rebond |
| Penance | 402174 et la liste de 1240720, 1240721, 1316995 | ID du sort connu et de la recharge |
| Devouring Plague | 2944 à 19280 ; 459713, 1219275 | si une seule famille d'IDs vaut |
| Shadowfiend 401977 | niveau 1 dans le DB2 | si le sort est connu avant le niveau voulu |
| Power Infusion 10060 | un seul ID | si l'ID du sort lancé est aussi l'aura |
| Focused Casting 27828 | 27828 | l'aura après un critique avec Martyrdom |
| Shadow Protection 976 | 976, 10957, 10958 et 27683 | 27683 existe sur Forever (20 min, Wowhead) ; confirmer en jeu que l'aura porte cet ID |
| Lightwell 724 | 724, 27870, 27871 | si le puits posé remonte dans le trigger `Totem` |
| Mind Flay 15407 | 15407, 17311, 17312, 17313, 17314, 18807 | la liste de rangs pour la règle des 5 s |

## 7. Tests en jeu propres à la classe

Au-delà de la grille commune (`PLAN-AURAS-CLASSES.md` section 4) :

1. Shadowform : activer la forme. Le rappel disparaît, l'icône d'Entretien s'allume, les icônes sacrées restent affichées sans erreur.
2. Power Word: Shield : lancer sur soi. Weakened Soul apparaît avec un temps restant de 15 s et le Shield passe en grisé.
3. Renew et Shield sur un coéquipier ciblé : l'aura de cible amie s'affiche et le seuil rouge marche en combat.
4. Devouring Plague : l'icône passe de la recharge au debuff cible sans conflit entre les deux triggers.
5. Mind Flay et Penance : la barre d'incantation suit la canalisation et se vide dans le bon sens.
6. Règle des 5 s : elle se déclenche sur un rang élevé de Heal et de Mind Blast, pas sur Fade ni Inner Fire.
7. Inner Fire : le texte natif donne les charges en combat sans erreur.
8. Fortitude lancée par un autre prêtre : le rappel disparaît.
9. Spirit Tap : tuer un mob en combat et lire l'apparition de l'aura.
10. Racial : un personnage nain ou humain voit ses deux raciaux, un autre n'en voit aucun d'incompatible.
11. Zone de repos : tous les rappels cachés, la mana basse aussi.
12. Bas niveau : seuls les sorts appris s'affichent, aucune recharge d'un sort inconnu.
13. Prayer of Mending : lancer sur un allié, noter l'ID du buff de rebond.

## 8. Écart avec la v1 (`PackPretre.lua`)

Ajouter :

- Devouring Plague en Principal avec recharge puis debuff, et ses IDs de rang complets.
- Weakened Soul (debuff joueur) en Effets, grisage du Shield.
- Power Infusion en Principal (D, S), Inner Focus en Principal (D, S).
- Renew sur la cible, Lightwell, Focused Casting, Inspiration, Divine Aegis, Spirit of Redemption, Elune's Grace.
- Shadow Protection en Entretien (absent de la v1 et du premier jet de la v2).
- Lueur pendant l'effet sur Fade, Fear Ward, Silence, Psychic Scream (double état recharge puis effet) et durée du puits de Lightwell.
- Divine Spirit (rappel et Entretien) et les raciaux (nain, humain, gnome, elfe de la nuit, mort-vivant, troll).
- Barre d'incantation (Mind Flay, Penance, Heal).
- Rangées Effets, Entretien, Utilitaires, style commun, alpha hors combat et sans cible, seuils de durée.
- Règle des 5 s : tous les rangs (v1 ne listait que les rangs 1).

Changer :

- Rappels : Mana basse reste, Fortitude et Inner Fire passent en icônes 32 et en deux états (rappel absent, Entretien présent).
- Spirit Tap passe des buffs vers Effets.
- Vampiric Embrace passe en Principal (variante O).
- Cooldowns v1 scindés : Psychic Scream, Fade, Fear Ward, Silence, Shadowfiend, Desperate Prayer vers Utilitaires. Inner Focus et Power Infusion vers Principal.
- Prayer of Mending : rangs 2 et 3 ajoutés (1240826, 1240827).

Retirer :

- Shadow Weaving (aucune décision, piles secrètes).
- « Fear Ward (actif) » buff sur soi : remplacé par l'icône Utilitaires.
- « Power Infusion (actif) » en liste de buffs : devient Effets.

## 9. Besoins de générateur propres au Prêtre

Seulement les besoins réels, au-delà de `PLAN-AURAS-V2.md` section 5 :

1. **Debuff sur le joueur** : Weakened Soul. `NOTES.md` v1 note que le builder ne suit que les buffs du joueur. Ajouter un champ pour un debuff HARMFUL sur `player`.
2. **Aura sur une cible amie** : Renew, Shield posés sur un allié ciblé. Ajouter l'unité `target` avec filtre HELPFUL et « posé par le joueur ».
3. **Barre d'incantation avec canalisation** : Mind Flay et Penance sont canalisés. Vérifier que le trigger Cast du joueur couvre aussi `UNIT_SPELLCAST_CHANNEL_*`.
4. **Icône à double état** (déjà en section 5 point 8 du socle) : Devouring Plague en a besoin en premier. À valider sur ce sort. Même besoin avec un debuff sur la cible (Silence, Psychic Scream, Starshards) ou un buff sur un allié (Fear Ward) ou sur soi (Fade).
5. **Durée d'un objet posé par le trigger `Totem`** : Lightwell, si le puits occupe un emplacement de totem. À tester.

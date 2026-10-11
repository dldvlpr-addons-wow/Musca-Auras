# Plan v2 du pack Démoniste (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Suit le format de `PLAN-AURAS-V2.md` section 6, point 1.

Classe : Démoniste (Warlock, `WARLOCK`). Pack v1 : `Tests/Packs/Demoniste/PackDemoniste.lua`, préfixe `mcLockV1`.

Légende des états (`PLAN-AURAS-V2.md` section 1) :

- **acquis** : le type de trigger est déjà testé en combat sur Forever (pack chaman). L'aura du Démoniste elle-même n'a pas encore été vue en jeu.
- **à tester** : trigger natif, jamais vu en combat sur Forever, ou ID d'aura incertain.
- **bloqué** : journal de combat ou lecture de valeur secrète.

Les IDs viennent de `Classes/Warlock.md` (DB2 1.60.1.70245). Les rangs sont listés du plus bas au plus haut.

## 1. Sources et specs couvertes

Sources : `Classes/Warlock.md`, `NOTES.md` du pack v1, `PLAN-AURAS-CLASSES.md` section 3, `RECHERCHE-AURAS-CLASSES.md` (Vim's Warlock Buffs, Nightfall, DoT, rappels d'armure et de pierre de soins), `ANALYSE-AURAS-FOJJI.md` section 7 (éclats d'âme, réactifs bas, familier absent, tic des 5 s). Pack Luxthos « Warlock (Classic Era) » (version 3, 1.15.2), décodé dans `ANALYSE-LUXTHOS.md` (même dossier). Idées seulement, rien n'est copié.

Arbres Classic de Forever : Affliction (17 talents), Démonologie (19), Destruction (16). Voir `Classes/Warlock.md`, section Talents.

Styles de jeu :

- Solo et montée de niveau : DoT, Drain Life, Health Funnel, familier Voidwalker ou Imp. Peu de talents.
- Donjon : malédiction utile au groupe (Elements, Recklessness), Fear et Banish pour le contrôle, interruption du Felhunter.
- Raid : Shadow Bolt en boucle avec Improved Shadow Bolt (Destruction), ou DoT en Affliction, une malédiction par Démoniste.

Rôle : un seul rôle (dégâts). La variante vient du talent clé, pas d'un rôle. Le familier change le jeu (Imp, Voidwalker, Succubus, Felhunter, Felguard). Il n'est pas une spé.

Quatre variantes de Principal et Débordement, exclusives par priorité (section 3) : Base, Affliction, Destruction, Démonologie.

Absent de Forever, donc de ce plan : Chaos Bolt, Haunt, Unstable Affliction, Curse of Shadow, Backlash, Backdraft (voir section 5).

## 2. Tables par rangée

Colonne « chargement » : classe `WARLOCK` toujours, puis `spellknown`. Pour les sorts à rang, `spellknown` porte sur le rang 1 (une aura par sort, tous les rangs dans le trigger). Variantes : B = Base, A = Affliction, D = Destruction, M = Démonologie (section 3).

Style commun (`PLAN-AURAS-V2.md` section 3) : zoom 0,3, bordure noire 1 px, recharge native, grisé en recharge, rouge hors portée, bleu sans mana. Seules les exceptions sont notées. Alpha 0,4 hors combat sans cible sur Principal et Utilitaires.

### 2.1 Rappels (hors combat, cachés en zone de repos)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Armure absente | Relancer Demon Skin ou Armor | Aura (Modern), joueur, HELPFUL, absente | Demon Skin 687, 696 ; Demon Armor 706, 1086, 11733, 11734, 11735 | `spellknown` 687 | Icône 32, visible hors combat et hors repos | acquis (buff manquant) |
| Familier absent | Invoquer le démon | Santé (ou Puissance) sur `pet`, absent ET aura Sacrifice démoniaque absente (tous les triggers) | Invocations 688, 697, 712, 713, 691 ; Sacrifice 18788 | `spellknown` 688 | Icône Summon Imp ; caché si le sacrifice est actif ; visible aussi en combat (familier mort), avec lueur, jamais en zone de repos | à tester |
| Soul Link absent | Relancer le lien, familier présent | Aura (Modern), joueur, HELPFUL, absente ET familier présent (Santé sur `pet`) | 19028 ; aura 25228 (buff, Wowhead Forever) | `spellknown` 19028 | Icône grisée alpha 0,5 ; visible hors combat et hors repos | à tester |
| Éclats d'âme bas | Refaire des éclats avant un donjon | Item Count, objet Soul Shard, seuil bas | objet 6265 (Wowhead Forever) | `spellknown` 686 | Compte natif ; rouge sous 3 | à tester |
| Pierre de soins absente | Créer une pierre | Item Count, objets Healthstone (tous rangs), à 0 | objets 5512, 5511, 5509, 5510, 9421 et variantes du talent 19004 à 19013 (Wowhead Forever). Sorts de création : 6201, 6202, 5699, 11729, 11730 | `spellknown` 6201 | Visible hors combat ; en groupe ou donjon seulement si possible | à tester |
| Pierre d'âme à poser | Poser la pierre avant un donjon | Aura (Modern), joueur, absente | aura 20707, 20762, 20763, 20764, 20765 (Wowhead Forever). Sorts : 693, 20752, 20755, 20756, 20757 | `spellknown` 693 | Caché en solo (condition de groupe à vérifier) | à tester |
| Pierre de feu ou de sort absente | Appliquer la pierre sur l'arme | Weapon Enchant, main hand, absent | Sorts : Firestone 6366, 17951, 17952, 17953 ; Spellstone 2362, 17727, 17728 ; sur Forever, les pierres s'appliquent sur l'arme (« Use: Imbues your weapon », Wowhead Forever) | `spellknown` 6366 ou 2362 | Icône de la pierre connue | à tester |
| Mana basse hors combat | Boire ou Life Tap | Puissance (mana), joueur, seuil bas | Mana (type 0) | classe | Texte, sous 20 %, hors combat | acquis (seuil Power) |

### 2.2 Effets (icônes 32 : procs, buffs courts, debuffs posés sur la cible)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Shadow Trance | Lancer Shadow Bolt instantané | Aura (Modern), joueur, HELPFUL | 17941 | `spellknown` 18094 (Nightfall) | Lueur pixel à l'apparition | acquis (type de trigger) |
| Shadow Vulnerability | Ne pas la reposer, profiter de la fenêtre | Aura (Modern), cible, HARMFUL, tout lanceur | 17794 | `spellknown` 17793 (Improved Shadow Bolt) | Texte durée (12 s), rouge sous 3 s | à tester |
| Malédiction absente | Voir qu'aucune malédiction ne tient sur la cible | Aura (Modern), cible, HARMFUL, lanceur joueur, une seule icône pour la liste des malédictions, affichée à l'absence | 980, 603, 702, 1714, 18223, 704, 440892 (rangs de la section 2.2) | `spellknown` 980 | Icône grisée alpha 0,5 ; prend l'icône de la malédiction posée | à tester |
| Pyroclasm actif | Profiter du bonus | Aura (Modern), joueur, HELPFUL | candidats 18093, 1293803 | `spellknown` 18096 | Lueur pixel | à tester (ID) |
| Shadow and Flame | Profiter du bonus d'Ombre et de Feu | Aura (Modern), joueur ou cible selon l'ID | candidats 426316, 426449 | talent (ID de talent à confirmer) | Lueur pixel | à tester (ID) |
| Decimation | Soul Fire rapide disponible | Aura (Modern), joueur, HELPFUL | candidats 440870, 440873, 440923 | talent (ID à confirmer) | Lueur pixel | à tester (ID) |
| Shadow Ward actif | Savoir si l'absorption tient | Aura (Modern), joueur, HELPFUL | 6229, 11739, 11740, 28610 | `spellknown` 6229 | Texte durée (30 s), rouge sous 5 s | à tester (ID) |
| Amplify Curse actif | Lancer Agony ou Weakness maintenant | Aura (Modern), joueur, HELPFUL | 18288 (ID d'aura = ID du talent, l'effet est porté par le sort, Wowhead Forever) | `spellknown` 18288 | Lueur pixel | à tester |
| Corruption | Reposer le DoT | Aura (Modern), cible, HARMFUL, lanceur joueur | 172, 6222, 6223, 7648, 11671, 11672, 25311 | `spellknown` 172 | Texte durée, rouge sous 3 s | à tester (durée sur cible) |
| Immolate | Reposer le DoT | Aura (Modern), cible, HARMFUL, lanceur joueur | 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 | `spellknown` 348 | Texte durée, rouge sous 3 s | à tester |
| Bane of Agony | Reposer la malédiction | Aura (Modern), cible, HARMFUL, lanceur joueur | 980, 1014, 6217, 11711, 11712, 11713 | `spellknown` 980 | Texte durée, rouge sous 3 s | à tester |
| Siphon Life | Reposer le DoT de soin | Aura (Modern), cible, HARMFUL, lanceur joueur | 18265, 18879, 18880, 18881 | `spellknown` 18265 | Texte durée, rouge sous 3 s | à tester |
| Wrack | Reposer le DoT de 6 s | Aura (Modern), cible, HARMFUL, lanceur joueur | 1316697 (ID de sort ; ID d'aura à confirmer) | `spellknown` 1316697 | Texte durée, rouge sous 2 s | à tester (ID) |
| Bane of Doom | Savoir si le Garde funeste arrive | Aura (Modern), cible, HARMFUL, lanceur joueur | 603 | `spellknown` 603 | Texte durée, rouge sous 5 s | à tester |
| Curse of the Elements | Maintenir la malédiction de groupe | Aura (Modern), cible, HARMFUL, lanceur joueur | 440892, 1311676, 1311677, 1311680 | `spellknown` 440892 | Texte durée, rouge sous 30 s | à tester |
| Curse of Recklessness | Maintenir la baisse d'armure | Aura (Modern), cible, HARMFUL, lanceur joueur | 704, 7658, 7659, 11717 | `spellknown` 704 | Texte durée, rouge sous 30 s | à tester |
| Curse of Weakness | Maintenir la baisse de dégâts | Aura (Modern), cible, HARMFUL, lanceur joueur | 702, 1108, 6205, 7646, 11707, 11708 | `spellknown` 702 | Texte durée, rouge sous 30 s | à tester |
| Curse of Tongues | Maintenir le ralentissement d'incantation | Aura (Modern), cible, HARMFUL, lanceur joueur | 1714, 11719 | `spellknown` 1714 | Texte durée, rouge sous 5 s | à tester |
| Curse of Exhaustion | Maintenir le ralentissement | Aura (Modern), cible, HARMFUL, lanceur joueur | 18223 | `spellknown` 18223 | Texte durée, rouge sous 3 s | à tester |

Un Démoniste ne tient qu'une malédiction et qu'une Bane par cible. Le groupe dynamique n'affiche que celles posées. Les 18 auras ne s'affichent donc jamais ensemble.

Variante d'affichage à tester pour Corruption, Immolate et Siphon Life : emplacement fixe grisé à demi-alpha quand le DoT est absent, au lieu de disparaître. À trancher après le premier test en jeu.

### 2.3 Principal (icônes 44, 8 au plus par variante)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Shadow Bolt | Savoir si le sort part (portée, mana) | Cooldown Progress (Spell) | 686, 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307 | `spellknown` 686 ; B, A, D, M | Rouge hors portée, bleu sans mana | acquis |
| Life Tap | Convertir la vie en mana | Puissance (mana), joueur, seuil bas | 1454, 1455, 1456, 11687, 11688, 11689 | `spellknown` 1454 ; B, A, D, M | Visible sous 40 % de mana seulement | acquis (seuil Power) |
| Death Coil | Soin et horreur d'urgence | Cooldown Progress (Spell) | 6789, 17925, 17926 | `spellknown` 6789 ; B, A, D, M | Grisé en recharge (2 min), rouge hors portée | acquis |
| Bane of Doom | Poser la Bane de 1 min | Cooldown Progress (Spell) | 603 | `spellknown` 603 ; B, A, M | Grisé en recharge, bleu sans mana | acquis |
| Drain Life | Soigner en canalisant | Cooldown Progress (Spell) | 689, 699, 709, 7651, 11699, 11700 | `spellknown` 689 ; B, A, M | Rouge hors portée, bleu sans mana | acquis |
| Drain Soul | Créer un éclat sur cible faible | Santé, cible, Show only below (%) 25 | 1120, 8288, 8289, 11675 | `spellknown` 1120 ; B, A | Visible sous 25 % de vie de la cible | à tester |
| Wrack | Lancer le DoT canalisé | Cooldown Progress (Spell) | 1316697 | `spellknown` 1316697 ; A | Rouge hors portée, bleu sans mana | à tester |
| Amplify Curse | Doubler la prochaine malédiction | Cooldown Progress (Spell) | 18288 | `spellknown` 18288 ; A | Grisé en recharge ; double état avec le buff : lueur pixel tant qu'il dure (aura 18288) | acquis |
| Searing Pain | Menace faible ou dégâts rapides | Cooldown Progress (Spell) | 5676, 17919, 17920, 17921, 17922, 17923 | `spellknown` 5676 ; B, D | Rouge hors portée, bleu sans mana | acquis |
| Health Funnel | Soigner le familier | Cooldown Progress (Spell) | 755, 3698, 3699, 3700, 11693, 11694, 11695 | `spellknown` 755 ; B, M | Visible si le familier est blessé (Santé sur `pet`, à tester) | à tester |
| Incinerate | Sort de Feu principal | Cooldown Progress (Spell) | 412758, 1293812, 1293813 | `spellknown` 412758 ; D | Rouge hors portée, bleu sans mana | acquis |
| Conflagrate | Détruire l'Immolate | Cooldown Progress (Spell) | 1293817, 1293818, 17962, 18930, 18931, 18932 | `spellknown` 1293817 ou 17962 ; D | Grisé en recharge (10 s) | acquis (ID de chargement à confirmer) |
| Shadowburn | Finisseur | Cooldown Progress (Spell) | 17877, 18867, 18868, 18869, 18870, 18871 | `spellknown` 17877 ; D | Grisé en recharge (15 s) | acquis |
| Soul Fire | Gros sort à éclat | Cooldown Progress (Spell) | 6353, 17924 | `spellknown` 6353 ; D, M | Grisé en recharge (1 min) | acquis |
| Fel Domination | Invocation rapide et moins chère | Cooldown Progress (Spell) | 18708 | `spellknown` 18708 ; M | Grisé en recharge | acquis |

Comptes par variante : Base 8 (Shadow Bolt, Life Tap, Death Coil, Bane of Doom, Drain Life, Drain Soul, Searing Pain, Health Funnel). Affliction 8 (Shadow Bolt, Life Tap, Death Coil, Bane of Doom, Drain Life, Drain Soul, Wrack, Amplify Curse). Destruction 8 (Shadow Bolt, Life Tap, Death Coil, Searing Pain, Incinerate, Conflagrate, Shadowburn, Soul Fire). Démonologie 8 (Shadow Bolt, Life Tap, Death Coil, Bane of Doom, Drain Life, Health Funnel, Soul Fire, Fel Domination).

### 2.4 Débordement (icônes 36)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Rain of Fire | Dégâts de zone | Cooldown Progress (Spell) | 5740, 6219, 11677, 11678 | `spellknown` 5740 ; B, A, D, M | Bleu sans mana | acquis |
| Hellfire | Dégâts de zone sur soi | Cooldown Progress (Spell) | 1949, 11683, 11684 | `spellknown` 1949 ; B, A, D, M | Bleu sans mana | acquis |
| Searing Pain | Menace faible ou dégâts rapides | Cooldown Progress (Spell) | 5676, 17919, 17920, 17921, 17922, 17923 | `spellknown` 5676 ; A, M | Rouge hors portée, bleu sans mana | acquis |
| Health Funnel | Soigner le familier | Cooldown Progress (Spell) | 755, 3698, 3699, 3700, 11693, 11694, 11695 | `spellknown` 755 ; A, D | Comme en Principal | à tester |
| Drain Life | Soigner en canalisant | Cooldown Progress (Spell) | 689, 699, 709, 7651, 11699, 11700 | `spellknown` 689 ; D | Rouge hors portée, bleu sans mana | acquis |
| Drain Soul | Créer un éclat sur cible faible | Santé, cible, Show only below (%) 25 | 1120, 8288, 8289, 11675 | `spellknown` 1120 ; D, M | Visible sous 25 % de vie de la cible | à tester |

### 2.5 Utilitaires (icônes 32)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Howl of Terror | Fuite de zone | Cooldown Progress (Spell) | 5484, 17928 | `spellknown` 5484 | Grisé en recharge (40 s) ; lueur pixel tant que la peur dure sur la cible (même ID, à tester) | acquis |
| Shadow Ward | Absorber les dégâts d'Ombre | Cooldown Progress (Spell) | 6229, 11739, 11740, 28610 | `spellknown` 6229 | Grisé en recharge (30 s) ; lueur pixel tant que l'absorption dure | acquis |
| Fear sur cible | Ne pas relancer, savoir quand il casse | Aura (Modern), cible, HARMFUL, lanceur joueur | 5782, 6213, 6215 | `spellknown` 5782 | Texte durée (10 à 20 s) | à tester |
| Banish sur cible | Idem, pour un démon ou élémentaire | Aura (Modern), cible, HARMFUL, lanceur joueur | 710, 18647 | `spellknown` 710 | Texte durée (20 à 30 s) | à tester |
| Spell Lock (familier) | Interrompre | Cooldown Progress (Spell) | 19244, 19647 | Felhunter invoqué | Grisé en recharge ; lueur pixel pendant le silence (aura 24259 déclenchée, Aura (Modern), toute unité, à tester) | à tester (sort de familier) |
| Devour Magic (familier) | Dissiper | Cooldown Progress (Spell) | 19505, 19731, 19734, 19736 | Felhunter invoqué | Grisé en recharge | à tester |
| Soothing Kiss (familier) | Réduire la menace du Succubus | Cooldown Progress (Spell) | 6360, 7813, 11784, 11785 | Succubus invoqué | Grisé en recharge | à tester |
| Pierre de soins utilisable | Manger la pierre au bon moment | Cooldown Progress (Item), pierre de soins | objets 5512, 5511, 5509, 5510, 9421 et variantes du talent 19004 à 19013 (Wowhead Forever). Sorts de création : 6201, 6202, 5699, 11729, 11730 | `spellknown` 6201 | Grisé en recharge d'objet, grisé à 0 pierre | à tester |
| Pierre d'âme sur le groupe | Savoir si un allié porte la pierre | Item Count de la pierre, ou Aura (Modern) sur `group` (nombre >= 1) | aura 20707, 20762, 20763, 20764, 20765 (Wowhead Forever) ; objets 5232, 16892, 16893, 16895, 16896. Sorts : 693, 20752, 20755, 20756, 20757 | `spellknown` 693 | Grisé alpha 0,5 si personne ne la porte | à tester |
| Seduction (familier) | Contrôle | Cooldown Progress (Spell) | 6358 | Succubus invoqué | Grisé en recharge | à tester |
| Sacrifice (familier) | Absorption de secours du Voidwalker | Cooldown Progress (Spell) | 7812, 19438, 19440, 19441, 19442, 19443 | Voidwalker invoqué | Grisé en recharge ; lueur pixel pendant l'absorption | à tester |
| Consume Shadows (familier) | Soin du Voidwalker | Cooldown Progress (Spell) | 17767, 17850, 17851, 17852, 17853, 17854 | Voidwalker invoqué | Grisé en recharge | à tester |
| Torment (familier) | Provocation du Voidwalker | Cooldown Progress (Spell) | 3716, 7809, 7810, 7811, 11774, 11775 | Voidwalker invoqué | Grisé en recharge | à tester |
| Intercept (familier) | Charge du Felguard | Cooldown Progress (Spell) | 427745 | Felguard invoqué | Grisé en recharge | à tester |

### 2.6 Entretien (icônes 32 : buffs longs, objets, familier)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Armure active | Savoir quand la renouveler | Aura (Modern), joueur, HELPFUL | 687, 696, 706, 1086, 11733, 11734, 11735 | `spellknown` 687 | Texte durée (30 min), rouge sous 5 min | acquis |
| Soul Link | Vérifier que le lien tient | Aura (Modern), joueur, HELPFUL | 19028 ; aura 25228 (buff, Wowhead Forever) | `spellknown` 19028 | Aucun texte de durée | à tester |
| Sacrifice démoniaque | Savoir que le démon est sacrifié | Aura (Modern), joueur, HELPFUL | 18788 (sans effet d'aura au DB2) | `spellknown` 18788 | Texte durée si l'aura en porte une ; rouge sous 30 s ; caché en zone de repos | à tester (ID) |
| Éclats d'âme | Compter les éclats | Item Count, objet Soul Shard | objet 6265 (Wowhead Forever) | `spellknown` 686 | Compte natif, rouge sous 3 | à tester |
| Pierre de soins | Compter les pierres | Item Count, objets Healthstone | objets 5512, 5511, 5509, 5510, 9421, 19004 à 19013 (Wowhead Forever) | `spellknown` 6201 | Compte natif, grisé à 0 | à tester |

### 2.7 Ressource (barre 390x18)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Mana | Décider du Life Tap | Puissance, joueur, mana | type 0 | classe | Bleu, texte `%p`. Couleur par seuil de pourcentage : bloqué, la mana est secrète | acquis (barre), bloqué (seuil) |

### 2.8 Secondaire (barres 390x10, deux demi-barres de 190)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Règle des 5 s | Attendre ou utiliser Life Tap | Spell Cast Succeeded, durée fixe 5 s | Tous les rangs des sorts à mana : Shadow Bolt, Immolate, Corruption, Bane of Agony, Searing Pain, Incinerate, Drain Life, Drain Soul, Fear, Soul Fire, Rain of Fire, Hellfire, Conflagrate, Shadowburn, malédictions. Life Tap exclu | classe | Gris-bleu, visible en combat | à tester |
| Familier (vie) | Soigner ou remplacer le démon | Santé, `pet` (mana en option) | `pet` | `spellknown` 688 | Vert ; masquée sans familier ou avec le sacrifice actif | à tester |

### 2.9 Incantation (barre 390x16)

| Aura | Décision | Trigger Musca | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Incantation joueur | Voir la fin d'un cast ou d'un canal | Barre d'incantation du joueur (trigger natif à vérifier) | tous les sorts | classe | Visible pendant un cast ou un canal ; Soul Fire dure 6 s, invocations 10 s | à tester |

## 3. Variantes par spé, forme, posture ou talent

Le Démoniste n'a ni forme ni posture. La variante vient du talent clé. Quatre variantes exclusives, une seule chargée à la fois.

Ordre de priorité (la première vraie gagne) :

1. Destruction : `spellknown` 17877 (Shadowburn) ou 412758 (Incinerate) ou Conflagrate.
2. Démonologie : `spellknown` 19028 (Soul Link) ou 18708 (Fel Domination).
3. Affliction : `spellknown` 18265 (Siphon Life) ou 1316697 (Wrack) ou 18288 (Amplify Curse).
4. Base : aucun des talents clés (montée de niveau).

Chaque aura de Principal et Débordement porte la condition « variante propre connue, variantes plus prioritaires inconnues ». Il faut un `spellknown` inversé (section 9).

Un build hybride (par exemple Destruction et Démonologie) tombe dans la variante la plus prioritaire. Les auras des autres talents restent chargées en Effets, qui n'est pas exclusif.

Variantes de familier (Utilitaires) : chargées par le démon invoqué. Voir section 9.

## 4. Rappels

| Rappel | Trigger | Hors combat | Caché en repos |
|---|---|---|---|
| Armure absente | Aura (Modern), absente | oui | oui |
| Familier absent | Santé sur `pet` absent et Sacrifice absent | oui, et en combat (familier mort) | oui |
| Soul Link absent | Aura (Modern) absente ET familier présent | oui | oui |
| Éclats d'âme bas | Item Count sous 3 | oui | oui |
| Pierre de soins absente | Item Count à 0 | oui | oui |
| Pierre d'âme à poser | Aura (Modern) absente, en groupe | oui | oui |
| Pierre de feu ou de sort absente | Weapon Enchant main hand absent | oui | oui |
| Mana basse | Puissance sous 20 % | oui | oui |

Un rappel de Soulstone, Healthstone ou éclats ne sert pas en solo bas niveau. Le chargement par `spellknown` du sort de création limite le bruit.

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Chaos Bolt, Haunt, Unstable Affliction | absent du DB2, exclu |
| Curse of Shadow | absent du DB2, exclu (Curse of the Elements couvre le besoin) |
| Backlash, Backdraft | absent du DB2, exclu (Backlash : seuls « Magic Backlash » 4947 et « Void Backlash » 427144 existent, noms différents) |
| Shoot (baguette), minuteur de baguette | absent de `Classes/Warlock.md`, exclu |
| Metamorphosis, Fel Armor, Dark Pact | absent du DB2, exclu |
| Compteur de procs sans aura (Nightfall, Improved Shadow Bolt) | bloqué : journal de combat |
| Piles de Shadow Vulnerability en combat | bloqué : valeur de pile figée en combat ; présence seulement |
| Tic des DoT, fenêtre Pandemic, réajustement de rafraîchissement | bloqué : journal de combat et comparaison de valeur secrète |
| Son ou lueur déclenchés par un seuil de durée de DoT | bloqué : valeur secrète ; seule la couleur du texte suit le seuil |
| Tic de mana, gain de Life Tap en chiffres | bloqué : journal de combat |
| Curse of the Elements (ID Era) 1490, Curse of Shadow 17862 | IDs Era absents du DB2 de Forever : exclus |
| Shadow Vulnerability 17800 | absent de `Classes/Warlock.md` : exclu, seul 17794 est suivi |
| Auras du Sacrifice démoniaque 18789 à 18792 | IDs Era absents du DB2 : exclus (l'aura se lit en jeu, section 6) |
| Soulstone 22959, 54374 | 22959 est Fire Vulnerability sur Forever, 54374 n'existe pas : exclus |
| Curseur de tic de mana par comparaison avant et après un lancement | bloqué : valeur de mana secrète en combat ; seule la règle des 5 s reste |
| Aftermath (étourdissement 18118) | hors décision, exclu |
| Bane of Doom Effect 18662 | invocation, pas un debuff : exclu |
| Fel Domination actif | ID d'aura absent du fichier, exclu |
| Soul Link (recharge), Spell Lock côté joueur | bascule ou sort du familier, exclu |
| Suivi de DoT sur plusieurs cibles (nameplates) | hors socle commun, exclu |
| Soul Harvest (régénération après kill drainé) | aucune aura connue : absent du DB2 (candidats de talent seulement), exclu |

## 6. IDs à confirmer en jeu

À lire par `/run` (aura posée, lecture de l'ID), puis à noter dans `Classes/Warlock.md`.

| Aura | Candidats | Vérification |
|---|---|---|
| DoT et malédictions (Corruption, Immolate, Agony, Siphon Life, Elements, Recklessness, Weakness, Tongues, Exhaustion, Doom) | ID de sort = ID d'aura (DB2) | Poser chaque rang, lire l'ID de l'aura sur la cible |
| Demon Skin 687, 696 et Demon Armor 706 à 11734 | IDs de sort ; seul 11735 a un ID d'aura dans `Classes/Warlock.md` | Poser l'armure à bas rang, lire l'ID |
| Soul Link | 19028, aura 25228 (Wowhead Forever) | Activer le lien, confirmer l'aura 25228 sur le joueur |
| Amplify Curse actif | 18288, aura portée par le sort (Wowhead Forever) | Lancer le talent, lire l'aura |
| Shadow Ward actif | 6229, 11739, 11740, 28610 | Lancer chaque rang, lire l'aura |
| Pyroclasm actif | 18093, 1293803 | Obtenir le proc, lire l'aura |
| Shadow and Flame | 426316, 426449 | Lancer Conflagrate ou Shadowburn, lire l'aura sur le joueur ou la cible |
| Decimation | 440870, 440873, 440923 | Tuer sous 35 % de vie avec le talent, lire l'aura |
| Sacrifice démoniaque | 18788 sans effet d'aura ; 18789 à 18792 absents du DB2 | Sacrifier le démon, lire l'ID de l'aura |
| Wrack | 1316697 | Poser le sort, lire l'ID de l'aura sur la cible |
| Shadow Vulnerability | 17794 | Crit Shadow Bolt avec le talent, lire l'aura sur la cible |
| Soulstone, résurrection | aura 20707, 20762, 20763, 20764, 20765 (Wowhead Forever) | Poser la pierre sur soi, confirmer l'ID de l'aura |
| Silence du Spell Lock | 24259 (`Classes/Warlock.md`) | Interrompre avec le Felhunter, lire l'aura sur la cible |
| Objets Soul Shard, Healthstone (tous rangs), Soulstone, Firestone, Spellstone | Soul Shard 6265 ; Healthstone 5512, 5511, 5509, 5510, 9421, 19004 à 19013 ; Soulstone 5232, 16892, 16893, 16895, 16896 ; Firestone 1254, 13699, 13700, 13701 ; Spellstone 5522, 13602, 13603 (Wowhead Forever) | Confirmer par le lien d'objet |
| Chargement Conflagrate | 1293817 (fichier), 17962 (Talent.csv) | Connaître le sort, tester `spellknown` sur chaque ID |
| Chargement Shadowburn 17877 et Siphon Life 18265 | sorts de talent | Vérifier que `spellknown` répond au rang 1 |
| Chargement des talents sans ID de talent sûr (Shadow and Flame, Decimation, Pandemic) | candidats SpellName | Tester `spellknown` sur chaque candidat |
| Sorts de familier (Spell Lock 19244 et 19647, Devour Magic, Seduction 6358, Sacrifice, Consume Shadows, Torment, Intercept 427745) | IDs de la table Sorts des familiers | Vérifier que Cooldown Progress lit un sort de familier |

## 7. Tests en jeu propres au Démoniste

Après la grille commune de `PLAN-AURAS-CLASSES.md` section 4.

1. Variantes : respécialiser en Destruction, Démonologie, Affliction, puis sans talent. Compter les icônes de Principal (8 au plus) et vérifier l'exclusivité.
2. Build hybride (Destruction avec Soul Link) : vérifier que Destruction gagne et que Soul Link reste en Entretien.
3. DoT en combat : poser Corruption, Immolate, Bane of Agony. Vérifier icône, durée et rouge sous 3 s.
4. Rangs bas : poser Corruption rang 1 à bas niveau. L'aura doit s'afficher.
5. Changer de malédiction : remplacer Weakness par Elements. L'ancienne icône disparaît.
6. Bane of Doom : l'aura reste 1 min. Vérifier qu'aucune icône ne naît de l'effet 18662.
7. Shadow Trance : provoquer le proc Nightfall. La lueur apparaît, l'icône part à l'usage.
8. Shadow Vulnerability posée par un autre Démoniste (groupe) : l'icône s'affiche-t-elle ?
9. Familier : invoquer Imp, Voidwalker, Succubus, Felhunter. Le rappel disparaît, la barre apparaît.
10. Mort du familier en combat : la barre disparaît, le rappel de familier apparaît avec sa lueur, jamais en zone de repos.
11. Sacrifice démoniaque : le rappel de familier reste caché, l'icône d'Entretien apparaît.
12. Pierre de soins et éclats : vérifier le compte après usage de Soul Fire en combat.
13. Life Tap : sous 40 % de mana l'icône apparaît, la règle des 5 s ne repart pas.
14. Canalisations : Drain Life et Drain Soul animent la barre d'incantation.
15. Soul Fire (6 s) et invocation (10 s) sur la barre d'incantation.
16. Sorts de familier : Spell Lock du Felhunter donne une recharge lisible en combat.
17. Soulstone : le rappel apparaît en groupe, pas en solo.
18. Fear : l'icône sur la cible disparaît quand le Fear casse.
19. Drain Soul : l'icône apparaît sous 25 % de vie de la cible, pas avant.
20. Shadow Ward : l'absorption et son compte à rebours de 30 s, lueur pendant l'effet.
21. Malédiction absente : l'icône est grisée sans malédiction, prend celle de la malédiction posée, redevient grise quand elle tombe.
22. Pierre de soins : l'icône d'Utilitaires suit la recharge d'objet en combat, grisée à 0 pierre.
23. Soul Link : le rappel apparaît familier présent et lien absent, pas familier absent.
24. Spell Lock : la lueur dure le temps du silence sur la cible.

## 8. Écart avec la v1 (`PackDemoniste.lua`)

### Ajouter

- Rangées nommées : Rappels, Effets, Principal, Débordement, Utilitaires, Entretien, Ressource, Secondaire, Incantation.
- Quatre variantes exclusives de Principal et Débordement (Base, Affliction, Destruction, Démonologie).
- Principal : Shadow Bolt, Life Tap, Drain Life, Drain Soul, Searing Pain, Incinerate, Wrack, Health Funnel (v1 ne couvre que 4 sorts de rotation).
- Débordement : Rain of Fire et Hellfire.
- Effets : Wrack, Pyroclasm, Shadow and Flame, Decimation, Curse of Exhaustion, seuil de temps restant sur chaque DoT.
- Utilitaires : sorts de familier (Spell Lock, Devour Magic, Seduction, Sacrifice, Consume Shadows, Torment, Intercept).
- Entretien : Sacrifice démoniaque, compte d'éclats, compte de pierres de soins.
- Rappels : familier absent (aussi en combat), Soul Link absent, éclats bas, pierre de soins, pierre d'âme, pierre de feu ou de sort.
- Effets : icône unique de malédiction absente.
- Utilitaires : Soothing Kiss, pierre de soins en recharge d'objet, pierre d'âme sur le groupe, lueurs d'effet actif (Howl of Terror, Shadow Ward, Sacrifice, Spell Lock).
- Barre d'incantation, barre de vie du familier en demi-largeur.
- Style commun (zoom, bordure, lueur sur Shadow Trance et procs, alpha hors combat).

### Modifier

- Rotation devient Principal ; Cooldowns devient Utilitaires ; Buffs et Debuffs deviennent Effets et Entretien.
- Conflagrate : chargement par `spellknown` à confirmer (1293817 ou 17962).
- Shadow Vulnerability : chargée par Improved Shadow Bolt (17793), plus par la classe seule.
- Règle des 5 s : tous les rangs des sorts à mana, pas seulement le rang 1.
- Mana basse : texte montré sous le seuil par le seuil natif ; barre de couleur fixe.
- Soul Link et Amplify Curse : conservés. Aura de Soul Link 25228 (Wowhead Forever) à confirmer en jeu ; aura d'Amplify Curse 18288 (Wowhead Forever) à confirmer en jeu.

### Retirer

- Fear et Banish comme debuffs d'Effets : ils passent en Utilitaires, en durée sur la cible.
- Rappel « MANA BAS » texte en combat : gardé, montré par le seuil natif, avec l'icône Life Tap.
- Rang unique pour les sorts à rangs dans les chargements : remplacé par `spellknown` du rang 1 et tous les rangs dans le trigger.

## 9. Besoins du générateur propres à la classe

À ajouter à `PackBuilder.lua`, en plus de `PLAN-AURAS-V2.md` section 5 :

1. **Chargement exclusif par priorité de variante** : `spellknown` inversé (« sort inconnu ») pour que Base, Affliction, Destruction et Démonologie ne se cumulent pas.
2. **Chargement par familier invoqué** : la famille du démon (Felhunter, Succubus, Voidwalker, Felguard, Imp) pour les icônes de sorts de familier. À vérifier : Cooldown Progress lit-il un sort de familier ?
3. **Barre double en Secondaire** : deux demi-barres côte à côte (règle des 5 s et vie du familier), car la rangée prévoit une seule barre.
4. **Item Count avec seuil bas** : texte de compte, couleur sous un seuil, objets de plusieurs rangs réunis dans un trigger (éclats, pierres de soins).
5. **Combinaison de triggers en ET** : familier absent ET Sacrifice démoniaque absent, pour le rappel de familier.
6. **Barre d'incantation en canal** : prise en charge des sorts canalisés (Drain Life, Drain Soul, Wrack, Health Funnel). Déjà prévue en section 5 point 6 pour le cast seul ; le canal est à vérifier.
7. **Cooldown Progress (Item)** : recharge d'une pierre de soins ou d'un objet. Classes : Démoniste ; aussi potions et breloques de toutes les classes.
8. **Aura sur `group` et sur `multi`** (nombre de porteurs >= 1) : pierre d'âme sur un allié, silence du Spell Lock sur n'importe quelle cible. Classes : Démoniste ; Prêtre, Druide, Paladin pour les buffs de groupe.
9. **Condition « familier présent »** combinée à repos et combat (Soul Link, familier mort en combat). Classes : Démoniste, Chasseur.
10. **Icône unique à liste d'auras, affichée à l'absence** : malédiction absente. Classes : Démoniste ; Chaman (totems, imbues), Paladin (auras).
11. **Chargement par `spellknown` d'un sort de familier**, alternative au chargement par démon invoqué du point 2. Classes : Démoniste, Chasseur.
12. **Double état recharge et buff dans une même icône** (Amplify Curse). Déjà relevé pour le chaman.

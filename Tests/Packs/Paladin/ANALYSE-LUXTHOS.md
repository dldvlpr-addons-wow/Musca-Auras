# Analyse du pack « Luxthos - Paladin (Classic Era) »

Source : `wago.io/LuxthosPaladinClassicEra` (version 4, semver 1.15.3, tocversion 11505), chaîne décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca. Le moteur commun (« LWA ») est décrit dans `ANALYSE-AURAS-LUXTHOS.md` (chaman) : ici, seuls les écarts et le contenu propre au paladin.

Réserve de lecture : les chargements `spec`, `role`, `talent`, `class_and_spec` sont des restes du gabarit (ex. Judgement chargé sur la spécialisation 2, Hammer of Justice chargé sur le sort 20271, Forbearance sur un sort 34503, Mana Tick sur 768). Le chargement réel repose sur la classe et, quand `use_spellknown` est vrai, sur le sort connu. Les noms `Warlock` dans les groupes (multi de classes) sont aussi des restes.

## 0. Chiffres

- 42 entrées sous la racine (groupe statique, centre écran, y -170) : 7 groupes enfants (6 dynamiques : Dynamic Effects, Core, Left Side, Right Side, Utilities, Maintenance ; 1 statique : Resources) et 35 feuilles.
- Feuilles : 30 icônes (2 icônes moteur invisibles, 4 effets, 9 Core, 11 utilitaires, 4 maintenance) et 5 barres (Mana Tick, vie, mana, swing timer, incantation). Chiffres chaman : 27 feuilles, 3 barres de ressource.
- Les 2 groupes Left Side / Right Side sont vides.
- Aucune animation, aucun son, aucun message, aucune texture de proc, aucun pop-up. Actions utilisées : init de Class Options et de General Options, init de Mana Tick, init de Consecration, démarrage du Cast Bar.
- Déclencheurs : recharges = `Cooldown Progress (Spell)` ; buffs et débuffs = `aura2` ; swing = `Swing Timer` main hand natif ; puissance = `Power` ; incantation = `Cast` ; le reste en déclencheurs personnalisés.

## 1. Gabarit

Même moteur General Options et Class Options que le chaman. Mêmes groupes, mêmes ancrages, mêmes valeurs par défaut de géométrie (Core 48 x 40, 5 à 8 icônes, débordement 44 x 36, effets / utilitaires / maintenance 38 x 32, barres 20 de haut), mêmes options d'auteur de General Options (style, alpha, rangées, ressources). Écarts :

- Groupe Core : 9 icônes au lieu de 10.
- Utilities : 11 icônes (chaman : 5). Maintenance : 4 icônes (chaman : 2).
- Une barre de swing timer main hand de plus dans Resources (chaman : aucune). Class Options porte donc deux blocs : barre de mana et barre de swing (10 de haut, dégradé violet).
- Pas de totems ni d'imbue : l'équivalent est une icône de sceau unique en tête du Core.
- Le comportement « si présent / si absent / toujours » (option d'auteur) existe sur trois icônes de Maintenance (auras, Righteous Fury, bénédictions), défauts respectifs : absent, présent, absent. Utilitaires : même option « sur recharge / toujours » que le chaman.
- Cast Bar : le démarrage retire les événements du cadre de lancement natif (même idée que le chaman).

## 2. Auras par rangée

Convention : « CD » = `Cooldown Progress (Spell)` en `showAlways` (sauf mention). Toutes les icônes gardent l'habillage du chaman (zoom 0,3, bordure noire 1 px, rouge hors portée, bleu-violet sans ressource, grisé en recharge, lueur pixel sur effet actif). Les lueurs « prêt » sur les CD sont mortes (conditions résiduelles), comme pour le chaman.

### 2.1 Effets dynamiques (au-dessus)

| Aura | Sort ou aura (ID) | Déclencheur | Chargement | Conditions |
|---|---|---|---|---|
| Judgement Seals (icône unique) | débuffs de jugement : 21183 (Crusader), 20185 (Light), 20186 (Wisdom), 20184 (Justice) | `aura2` débuff sur la cible, par nom, siens seulement | classe | texte des piles ; aucune condition visuelle |
| Reckoning | 20178 | `aura2` buff joueur | classe | lueur pixel quand actif |
| Redoubt | 20132 | `aura2` buff joueur | classe | lueur pixel quand actif |
| Vengeance | 20050 | `aura2` buff joueur | classe | lueur pixel ; texte des piles |

### 2.2 Core

| Aura | Sort ou aura (ID) | Déclencheur | Chargement | Conditions |
|---|---|---|---|---|
| Seals (icône unique) | 21084 Righteousness, 20164 Justice, 20166 Wisdom, 20165 Light, 20375 Command, 21082 Crusader (Seal of Fury absent) | `aura2` buff joueur, par nom, `showAlways`, mode « le plus haut » ; 2e déclencheur : zone de repos | classe | aucun sceau : alpha 0,5 + grisé. Un seul emplacement pour tous les sceaux : l'icône montre le sceau en cours |
| Judgement | 20271 | CD | sort connu 20271 | grisé en recharge, rouge hors portée, grisé sans ressource |
| Holy Shock | 20473 ; aura 88819 | CD + buff joueur 88819 | sort connu 20473 | rouge hors portée seulement si cible ; lueur bouton Blizzard quand 88819 est actif (88819 absent du DB2 Forever) |
| Holy Shield | 20925 | buff joueur (siens) + CD | sort connu 20925 | double état : buff actif = lueur pixel, désaturation et inversion coupées, bord de balayage affiché (durée du buff) ; sinon recharge grisée |
| Consecration | 26573 | CD | sort connu 26573 | grisé en recharge ; init : change la texture et l'agrandissement de l'icône |
| Hammer of Wrath | 24275 | CD | sort connu 24275 | lueur quand le sort est utilisable (cible sous 20 %), grisé si inutilisable |
| Exorcism | 879 | CD | sort connu 879 | grisé, rouge hors portée |
| Holy Wrath | 2812 | CD | sort connu 2812 | grisé |
| Divine Favor | 20216 | buff joueur (siens) + CD | sort connu 20216 | double état identique à Holy Shield |

Pas d'icône pour Holy Strike, Hammer of the Righteous, Light's Vigil, Swift Judgement (contenu propre à Forever, absent du pack).

### 2.3 Utilitaires

Même mécanique que le chaman : deux CD du même sort (toujours / sur recharge) et un choix par option d'auteur ; une troisième source (aura) ajoute le double état.

| Aura | Sort (ID) | Troisième source | Chargement |
|---|---|---|---|
| Hammer of Justice | 853 | `aura2` débuff cible, siens (durée du stun) | sort connu 20271 (reste) |
| Repentance | 20066 | `aura2` débuff cible | sort connu 20066 |
| Turn Undead | 10326 | `aura2` débuff cible | sort connu 10326 |
| Divine Shield | 642 | `aura2` buff joueur, piles > 0, siens | sort connu 642 |
| Divine Protection | 498 | idem | sort connu 498 |
| Lay on Hands | 633 | aucune (deux CD seulement) | sort connu 633 |
| Divine Intervention | 19752 | aucune | sort connu 19752 |
| Blessing of Freedom | 1044 | `aura2` buff sur `group`, siens | sort connu 1044 |
| Blessing of Protection | 1022 | idem | sort connu 1022 |
| Blessing of Sacrifice | 6940 | idem | sort connu 6940 |
| Salvation (icône de recharge) | 1038 | idem | sort connu 1038 |

Double état : source aura active = lueur pixel, désaturation coupée, inversion, bord de balayage (durée de l'effet) ; sinon CD grisé. Les cibles et les alliés d'un groupe sont lus par `aura2`.

### 2.4 Maintenance (rappels, masqués en zone de repos)

| Aura | Auras ou sorts (ID) | Déclencheur | Chargement | Comportement |
|---|---|---|---|---|
| Auras | 465 Devotion, 7294 Retribution, 19746 Concentration, 19896 / 19898 / 19900 résistances, 20218 Sanctity (absent du DB2 Forever) | `aura2` joueur, présent ou absent, siens | sort connu 465 | défaut : si absent ; toute aura de la liste compte comme présente |
| Righteous Fury | 25780 | `aura2` joueur | sort connu 25780 (spécialisation protection dans le gabarit) | défaut : si présent |
| Blessings | 19740 Might, 25782 Greater Might, 19742 Wisdom, 25894 Greater Wisdom, 20217 Kings, 25898 Greater Kings, 20911 / 25899 Sanctuary (absents du DB2) | 3 déclencheurs : présent, présent avec reste <= 120 s, absent ; plus zone de repos et options | sort connu 19740 | défaut : si absent ; en mode absent : absent ou reste <= 2 min. Light et Salvation absents de la liste |
| Forbearance | 25771 | `aura2` débuff joueur | classe | actif seulement ; pas de condition |

Le déclencheur « Item Count » vu dans l'export est un reste ; le déclencheur réel est `aura2`.

### 2.5 Ressources

| Aura | Détails |
|---|---|
| Health Bar | `Health` joueur, absorption en surcouche, désactivée par défaut dans le gabarit (comme chaman) |
| Mana Bar | `Power` mana, texte `%c`, option de coût affiché ; couleur du texte orange à 30 % ou moins, rose-rouge à 15 % ou moins |
| Swing Timer Bar | `Swing Timer` main hand, toujours affichée, 20 de haut, dégradé violet ; changement de couleur hors combat (par code) ; aucune marque de fenêtre de twist |
| Cast Bar | `Cast` joueur, identique au chaman ; démarrage : retire les événements du cadre natif |
| Mana Tick | identique au chaman (voir section 5) |

## 3. Options d'auteur propres à la classe (Class Options)

- Mana Bar : hauteur 20, format du texte (1 = valeur ; 5 choix), police, taille 14, couleurs 1 et 2 (bleu), dégradé horizontal.
- Swing Timer Bar : hauteur 10, police, taille 14, couleurs 1 et 2 (violet puis lilas), dégradé.
- Par aura : Mana Tick (tolérance 0,08, décalage 0,01), Auras / Righteous Fury / Blessings (comportement présent, absent ou toujours), Utilitaires (sur recharge ou toujours).

## 4. Code personnalisé propre à la classe (idées seulement)

- Class Options : range les options (mana, swing) dans une table globale lue par le moteur. Sans objet côté Musca.
- Swing Timer Bar : une condition de couleur selon le combat (barre atténuée hors combat) qui demande un recalcul au moteur. Réplicable par une condition native `incombat`.
- Consecration : remplace l'icône et réduit l'agrandissement. Esthétique seulement.
- Mana Tick (déclencheur sur lancement + déclencheur de gain) : devine le prochain tic de mana en comparant la mana avant et après chaque sort, cycle de 2 s, règle des cinq secondes implicite.
- Cast Bar : retire les événements du cadre de lancement natif.
- Aucune pièce sur les sceaux, jugements ou bénédictions : tout passe par les listes de noms d'`aura2`.

## 5. Bloqué sur Forever

- Tout ce qui lit une aura : sceaux, jugements, Reckoning, Redoubt, Vengeance, Holy Shield et Divine Favor (état actif), Righteous Fury, bénédictions, auras de paladin, Forbearance, débuffs de cible (stun, Repentance, Turn Undead), bénédictions sur le groupe : `aura2` ne voit rien en combat. Remplacement : `secretAura`.
- Mana Tick : compare `UnitPower` avant et après un sort, donc bloqué en combat. Seule la règle des cinq secondes (durée fixe après un sort à mana) est reproductible.
- Texte de mana formaté (valeur en K, pourcentage) calculé par Lua : bloqué en combat ; texte natif `%c` / `%p` seulement.
- Fenêtre de twist de sceau : absente du pack, et non reconstructible (temps de swing restant secret).
- Rien ne lit le journal de combat. Aucune comparaison de recharge en Lua.

## 6. Éléments à ne pas reprendre

- Ids absents du DB2 Forever : 88819 (aura de Holy Shock), 20132 (Redoubt de Luxthos ; Forever : 20128), 20218 (Sanctity Aura), 20911 (talent sans nom côté Forever, nommé Sanctuary par le pack), 25899 (Greater Sanctuary), 34503, 18265, 6265 (restes d'autres classes).
- Hand of Salvation en icône de recharge : Blessing of Salvation n'a pas de recharge.
- Blessing of Sacrifice en icône de recharge : même constat (déjà exclu du plan).

# Analyse du pack « Luxthos - Warrior (Classic Era) »

Source : `wago.io/LuxthosWarriorClassicEra` (version 5, semver 1.15.4, tocversion 11505), chaîne `!WA:2!` décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca. Le moteur commun « LWA » est décrit dans `ANALYSE-AURAS-LUXTHOS.md` (chaman) et n'est pas réanalysé ici. Décodage brut : `scratchpad/dec/luxthos-warrior.lua`.

Réserve de lecture : comme pour le chaman, le gabarit traîne des restes (chargement `WARLOCK` / `EVOKER` en multi, spécialisations 71 / 72 / 73 de retail, `role = DAMAGER`, noms de sort copiés d'une aura à l'autre, spell Known 190456 de retail sur la barre de rage). Le chargement réel repose sur `spellknown`, la classe, des index de talent et la posture.

## 0. Chiffres

- 47 entrées sous la racine : 7 groupes enfants (6 dynamiques + « Resources » statique) et 40 feuilles.
- Feuilles : 2 icônes « moteur » invisibles (Class Options 1x1, General Options 405x100), 4 icônes Effets, 18 Core, 11 Utilitaires, 1 Maintenance, 4 barres (vie, rage, swing, incantation).
- Aucune animation, aucun son, aucun message, aucune texture de proc. Seules actions : l'init Lua des deux auras moteur et des quatre barres.
- Déclencheurs : recharge = `Cooldown Progress (Spell)` ; buffs et débuffs = `aura2` par nom ; posture = `Stance/Form/Aura` ; file d'attaque = `Queued Action` ; rage = `Power` ; swing = `Swing Timer` main hand ; incantation = `Cast`.

## 1. Gabarit : identique au chaman

Oui pour le moteur : le code d'init de « General Options », ses trois déclencheurs personnalisés, ses options d'auteur et sa `config` sont identiques octet pour octet à ceux du chaman. Mêmes groupes (Dynamic Effects, Core, Left Side, Right Side, Utilities, Maintenance, Resources), mêmes ancrages sur le cadre « General Options », mêmes fonctions de croissance personnalisées, mêmes dimensions par défaut (Core 48x40, rangées secondaires 38x32), même centre écran, y -170.

Écarts :

- Pas de Mana Tick ; la barre de mana est remplacée par une barre de rage.
- Class Options porte les options de la barre de rage et du swing, non de la mana.
- Resources : 4 barres (vie désactivée par défaut, rage, swing, incantation) au lieu de 3 (vie, mana, incantation) + curseur de tic.
- Core : 18 auras au lieu de 10, donc débordement d'office (le moteur en admet 8 par ligne, le reste sur une seconde ligne plus petite).
- Maintenance : une seule icône (Battle Shout), sans équivalent d'imbue.
- Effets : 4 auras (2 débuffs cible, 2 buffs joueur) au lieu de 4 buffs / débuffs chaman.
- Aucun groupe Left Side / Right Side rempli (vides, comme au chaman).
- Beaucoup de logique de posture (index de forme) que le chaman n'a pas.

## 2. Auras par rangée

Convention : « CD » = Cooldown Progress (Spell). Style commun des icônes de CD : grisé en recharge, rouge hors de portée, bleu-violet si rage insuffisante, zoom 0,3, bordure noire 1 px. Les lueurs « prêt » du pack sont presque toutes mortes (conditions qui mettent `false` ou rien) ; seule la lueur pixel d'effet actif et la lueur bouton de quelques icônes « utilisable » fonctionnent.

### 2.1 Effets dynamiques (4)

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Sunder Armor | `aura2` débuff cible, siens, par nom (7386) | `spellknown` 7386 | aucune |
| Demoralizing Shout | `aura2` débuff cible, siens, par nom (1160) | `spellknown` 1160 | lueur pixel quand actif |
| Enrage | `aura2` buff joueur, par nom : 12880 et un second ID de WotLK (57519) | `spellknown` 18265, talents d'index | lueur pixel |
| Blood Craze | `aura2` buff joueur, par nom (16488) | talents d'index | lueur pixel |

### 2.2 Core (18)

| Aura | Déclencheur | Chargement | Conditions notables |
|---|---|---|---|
| Mortal Strike (12294), Bloodthirst (23881) | CD, avec GCD | `spellknown` | quatre styles communs |
| Shield Slam (23922) | buff joueur 50227 (reste de WotLK) + CD | `spellknown`, talent | quatre styles ; buff actif : lueur bouton, bord de balayage |
| Heroic Strike (78) | CD + `Queued Action` | `spellknown` ; **désactivé par défaut** (`use_never`) | lueur quand en file |
| Overpower (7384) | CD + posture ; logique : visible sauf si la posture lue vaut 2 | `spellknown`, Armes et Protection par `class_and_spec` | lueur bouton quand utilisable ; gris sinon |
| Revenge (6572) | CD + posture 2 (Defensive), les deux requis | `spellknown` ; talent 12 non pris | lueur bouton quand utilisable ; style de portée / ressource |
| Shield Block (2565) | buff 2565 + CD | `spellknown`, Protection | buff actif : lueur pixel, bord de balayage |
| Rend (772) | `aura2` débuff cible, siens, `showAlways` | `spellknown`, Armes et Protection | absent : grisé, alpha 0,5 |
| Whirlwind (1680) | CD + posture 3 (Berserker), les deux requis | `spellknown`, talent d'index | caché hors posture |
| Thunder Clap (6343) | CD + posture 1 ou 2 | `spellknown`, talents d'index | caché hors Battle et Defensive |
| Execute (5308) | CD, condition « utilisable » | `spellknown` ; Armes et Fureur ; masqué si le talent de Shield Slam est connu | lueur bouton quand utilisable |
| Bloodrage (2687) | buff 29131 + CD | `spellknown` | double état : buff actif = lueur pixel, bord, dé-grisé |
| Sweeping Strikes (12292), Death Wish (12328) | buff + CD | `spellknown` | double état |
| Recklessness (1719) en deux copies, une par arbre | buff (compte > 0) + CD | `spellknown` + talent d'index (Armes / Fureur) | double état |
| Retaliation (20230) | buff + CD | `spellknown` ; **désactivé par défaut** | double état |
| Shield Wall (871) | buff + CD | `spellknown`, Protection | double état |

### 2.3 Utilitaires (11)

Taunt (355), Mocking Blow (694), Challenging Shout (1161), Charge (100), Intercept (20252), Pummel (6552) : 2 déclencheurs CD du même sort (toujours / sur recharge) ; un seul style (grisé en recharge ; pas de portée ni de ressource). Concussion Blow (12809), Disarm (676), Berserker Rage (18499), Last Stand (12975), Intimidating Shout (5246) : 3 déclencheurs, soit buff joueur ou débuff cible (`aura2` par nom) + les deux CD ; avec l'option « sur recharge », l'icône apparaît aussi tant que l'effet est actif (étourdissement, désarmement, peur chez la cible ; buff chez le joueur), lueur pixel et bord de balayage. Option d'auteur : comportement d'affichage (sur recharge par défaut / toujours). Chargement : `spellknown`.

### 2.4 Maintenance (1)

Battle Shout : buff par nom, 6673 plus deux IDs d'une autre classe (19740 et 25782, le buff de force de groupe d'un autre buffeur compte donc comme équivalent). Quatre déclencheurs : actif, actif avec reste <= 30 s, absent, zone de repos. Trois comportements (si présent / si absent / toujours), défaut « si absent », masqué en zone de repos. Absent : alpha 0,5, grisé. Chargement : `spellknown` 6673. Un item de sorcier traîne dans les triggers (reste de copie).

### 2.5 Ressources (groupe statique)

| Aura | Détails |
|---|---|
| Health Bar | Désactivée par défaut. Vie du joueur avec absorption en surcouche ; format de texte calculé par Lua (voir §5). |
| Rage Bar | 405x20 (taille réelle par option), rouge dégradé, fond noir 30 %, texte `%p` natif, aperçu du coût du sort activé. Aucun repère de seuil. |
| Swing Timer Bar | Swing main hand uniquement (pas d'off hand), 5 px de haut par option, orange en combat, gris translucide hors combat (couleurs par condition personnalisée), texte masqué, étincelle cachée quand vide. Chargement avec un identifiant de spécialisation de retail (71) : à vérifier qu'il charge bien en Classic Era. |
| Cast Bar | Barre d'incantation du joueur, remplace la barre Blizzard (qui est désenregistrée par Lua) ; couleur « ininterruptible » par condition personnalisée. Inutile pour un guerrier hors Slam. |

## 3. Options d'auteur propres à la classe (Class Options)

- Barre de rage : hauteur 5-50 (20), police, taille 6-72 (14), couleur 1 (rouge 0,69 / 0 / 0), couleur 2 (orange-rouge), sens du dégradé (horizontal par défaut / vertical / aucun).
- Barre de swing : mêmes champs, hauteur 5, couleurs 1 et 2 en combat (orange), et couleurs 1 et 2 hors combat (gris translucide), dégradé hors combat.
- Par aura : comportement des Utilitaires (sur recharge / toujours) et de Battle Shout (présent / absent / toujours).
- Tout le reste (tailles, marges, alpha global, bordure, zoom) vient de General Options, identique au chaman.

## 4. Code personnalisé propre à la classe (idées seulement)

- Logique de déclencheur des icônes de posture : combine la recharge et la posture lue (« tous » pour Revenge et Whirlwind, « un parmi » pour Thunder Clap, « sauf » pour Overpower). Équivalent Musca : second trigger en mode « tous » (besoin déjà relevé).
- Logique des utilitaires : choisit le déclencheur « toujours » ou « sur recharge » selon l'option. Équivalent Musca : un seul des deux déclencheurs CD selon la donnée du générateur.
- Logique de Battle Shout : trois modes + masquage en zone de repos. Équivalent Musca : rappel et entretien séparés (déjà au plan).
- Conditions de la barre de swing et de l'incantation : posent un état de couleur lu par le moteur pour recolorer la barre selon le combat ou l'interruptibilité. Équivalent Musca : condition native `incombat` qui change la couleur de la barre.
- Texte de la barre de vie : formate valeur et pourcentage par Lua. Sans objet pour la rage (texte `%p` natif).
- Désenregistrement de la barre d'incantation Blizzard au chargement.

## 5. Bloqué ou douteux sur Forever

- **`aura2` en combat** : tous les buffs et débuffs (Sunder Armor, Demoralizing Shout, Enrage, Blood Craze, Rend, Shield Block, Bloodrage, Sweeping Strikes, Death Wish, Recklessness, Retaliation, Shield Wall, Berserker Rage, Last Stand, Concussion Blow, Disarm, Intimidating Shout, Battle Shout). Remplacement : `secretAura`.
- **Lecture d'aura par nom** : les IDs du pack sont des noms de sort, pas des IDs d'aura (Last Stand 12975 est le sort, l'aura est 12976 ; Intimidating Shout pose 20511).
- **Formatage Lua de la barre de vie** (valeur secrète) : bloqué ; remplacé par `%c` / `%p` natifs.
- **Désenregistrement de la barre d'incantation Blizzard** : risque de taint, à vérifier.
- **Aucune lecture du journal de combat**, aucune comparaison de recharge, aucune comparaison de ressource en Lua : le pack ne contient rien de ce genre côté guerrier.
- **Conditions « utilisable » sur CD en combat** (Overpower, Revenge, Execute, Heroic Strike) : à tester sur Forever (état de valeur secrète non vérifié).
- **Restes sans effet** : buffs d'une autre extension (50227, 57519), spell Known 190456, filtres de talent par index désactivés, un item de sorcier, noms de sorts copiés d'une aura à l'autre.

## 6. Écarts avec notre pack

Notre pack v1 : trois blocs seulement, sans posture, sans lueur, sans style commun.

Ce que Luxthos a et le plan n'avait pas : débuffs de cible dans les icônes d'utilitaires à double état (Concussion Blow, Disarm, Intimidating Shout) ; Blood Craze en Effets ; icône d'Overpower, Revenge et Execute toujours visible avec lueur quand utilisable ; couleur du swing en combat et hors combat ; masquage d'Execute pour la variante Protection ; Battle Shout accepte un buff équivalent d'une autre classe.

Ce que le plan a et que Luxthos n'a pas : Slam, Cleave, Victory Rush, Hamstring, Shield Bash, Piercing Howl, indicateur de posture, rappel de posture, swing off hand, barre d'incantation utile (Slam), repères de rage, variantes par talent de 30 points.

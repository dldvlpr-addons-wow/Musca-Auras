# Analyse du pack « Luxthos - Druid (Classic Era) »

Source : `wago.io/LuxthosDruidClassicEra` (version 6, semver 1.15.5, tocversion 11505), chaîne décodée avec `Tests/Packs/AuraTool.lua`. Idées seulement : aucun code ni texte du pack n'est repris dans les packs Musca. Modèle de lecture et moteur commun : `ANALYSE-AURAS-LUXTHOS.md` (chaman), non repris ici. Décodage brut : `scratchpad/dec/luxthos-druid.lua`.

Réserve : comme au chaman, les filtres `spec`, `role` et `class_and_spec` (ids 748, 750, 752, 102 à 105, WARLOCK, EVOKER) sont des restes du gabarit commun, sans effet fiable en Classic Era. Le chargement réel repose sur `spellknown` et, pour la forme, sur une aura de forme lue par `aura2`.

## 0. Chiffres

- 57 entrées sous la racine : 8 groupes (7 dynamiques : Dynamic Effects, Core, Left Side, Right Side, Utilities, Maintenance, Combo Points ; 1 statique : Resources) et 49 feuilles.
- Feuilles : 36 icônes (2 icônes « moteur » invisibles, 34 icônes de sort) et 13 barres.
- Icônes de sort : Effets 5, Core 16, Utilitaires 8, Maintenance 5. Barres : Energy Tick, Mana Tick, vie, mana, rage, énergie, 5 segments de combo, mana hors forme (« Off-Spec »), incantation.
- Déclencheurs : buffs et débuffs en `aura2` par ID de sort écrit dans le champ nom ; recharges en `Cooldown Progress (Spell)` ; barres en `Power` (types 0, 1, 3, 4) et `Cast` ; ticks en code personnalisé. Aucun journal de combat.
- Pas d'animation, de son, de swing timer, de texture de proc ni de pop-up (comme au chaman).

## 1. Gabarit

Identique au chaman : même moteur « General Options » (même arbre d'options, mêmes groupes d'icônes, croissance `CUSTOM` appelant le moteur commun, cadre d'ancrage redimensionné), même « Class Options » (aura invisible qui porte les options de classe), mêmes rangées et ancrages, mêmes valeurs par défaut de taille (Core 48x40, débordement 44x36, autres 38x32, barres 20 de haut).

Écarts :

- Class Options porte cinq groupes de barres au lieu d'un : mana (hauteur 20, format de texte), mana hors forme (hauteur 5, couleur d'état « haute »), énergie (20), rage (20), points de combo (hauteur 10, quatre états de couleur : normal, haut, plein, dépassé). Pas de police ni de format de texte pour énergie, rage et combo au-delà de la police et de la taille.
- Nouveau groupe dynamique imbriqué « Combo Points » (dans Resources), croissance `CUSTOM` via une fonction de ressource dédiée du moteur : 5 segments de 65x20, côte à côte.
- Deux ticks au lieu d'un : Mana Tick (comme au chaman) et Energy Tick (nouveau). Tous deux sont ancrés sur la barre concernée.
- Les barres de ressource sont chargées selon la forme : mana pleine hors forme, mana fine (« Off-Spec ») en forme, énergie et combo en Chat, rage en Ours.
- Pas de barre de totem ni d'imbue. Core de 16 icônes (chaman : 10), donc débordement plus fréquent.
- Quelques noms internes : « Combot Point » (faute dans le pack), « Faerie Fire (Feral) ».

## 2. Auras par rangée

Convention : « CD » = Cooldown Progress en `showAlways`. « Lueur » = lueur pixel allumée par une condition d'effet actif. Les conditions de lueur « prêt » (type bouton Blizzard) sont mortes, comme au chaman.

### 2.1 Effets dynamiques (5)

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Faerie Fire (lanceur) | `aura2` débuff cible, siens, 770 | sort connu 770 | aucune |
| Faerie Fire (Feral) | `aura2` débuff cible 16857 + CD du même ID | sort connu 16857 | grisé en recharge ; bord de balayage quand le débuff est là |
| Clearcasting | `aura2` buff joueur 16870 | sort connu 16864 | lueur |
| Nature's Grace | `aura2` buff joueur 16886 | talent par index (reste) | lueur |
| Demoralizing Roar | `aura2` débuff cible, siens, 99 | sort connu 99 | lueur |

### 2.2 Core (16)

Les débuffs de DoT sont doubles : un trigger de débuff cible (`showAlways`, siens) et un trigger de forme. Aucune icône de rotation de lanceur ou de Chat « de dépense » (Wrath, Starfire, Shred, Claw, Ferocious Bite) n'est dans le pack.

| Aura | Déclencheur | Chargement | Conditions |
|---|---|---|---|
| Moonfire (8921) | débuff cible + forme absente (Chat, Ours, Dire Bear : `showOnMissing`) | sort connu 8921 | absent : grisé alpha 0,5 ; lueur coupée hors combat (résiduel) |
| Insect Swarm (5570) | idem | sort connu 5570 | idem |
| Rejuvenation (774) | buff joueur (siens) + forme absente | sort connu 774 | idem |
| Regrowth (8936) | idem | sort connu 8936 ; « non connu » sur un ID d'Insect Swarm (reste) | idem |
| Rake (1822) | débuff cible + forme Chat présente | sort connu 1822 | idem |
| Rip (1079) | idem | sort connu 1079 | idem |
| Maul (6807) | CD + forme Ours ou Dire Bear présente | sort connu 6807 | grisé en recharge ; rouge hors de portée ; bleu-violet sans rage |
| Swipe (779) | idem | sort connu 779 | idem |
| Enrage (5229) | buff joueur + CD ; la logique ne retient que la forme Ours | sort connu 5229 | CD grisé ; buff actif : lueur, bord de balayage |
| Tiger's Fury (5217) | buff + CD ; forme Chat | sort connu 5217 | comme Enrage, plus bleu sans énergie |
| Frenzied Regeneration (22842) | buff joueur + CD | sort connu 22842 | double état : grisé en recharge, lueur et bord quand actif |
| Barkskin (22812) | buff joueur + CD | sort connu 22812 | idem ; aucune forme exigée |
| Feral Charge | CD sur 16979 (ID de talent, pas de sort) + forme Ours (Bear seulement, pas Dire Bear) | sort connu 16979, exact | grisé en recharge |
| Innervate (29166) | buff sur le groupe (siens) + CD | sort connu 29166 | double état avec lueur |
| Nature's Swiftness (17116) | buff joueur + CD | sort connu 17116 | double état avec lueur |
| Tranquility (740) | CD | sort connu 740 | grisé en recharge |

### 2.3 Utilitaires (8)

Growl (6795), Challenging Roar (5209), Bash (5211), Nature's Grasp (16689), Hurricane (17402, rang 3), Dash (1850), Rebirth (20484), Cower (8998). Chacun : deux CD du même sort (`showAlways` et `showOnCooldown`) et, pour cinq d'entre eux, un trigger d'aura (débuff sur la cible pour Growl, Challenging Roar et Bash ; buff joueur pour Nature's Grasp et Dash). Logique personnalisée qui choisit selon l'option « sur recharge / toujours » (défaut : sur recharge). Conditions : grisé en recharge ; lueur quand l'aura est là (Growl, Challenging Roar, Bash, Nature's Grasp, Dash). Chargement : sort connu. Hurricane et Rebirth : CD seul.

### 2.4 Maintenance (5)

| Aura | Déclencheur | Particularités |
|---|---|---|
| Prowl (5215) | buff joueur + CD `showOnCooldown` | actif : lueur et bord ; en recharge : grisé |
| Form | un buff parmi Chat, Ours, Dire Bear, Voyage (783), Moonkin (24858) | une seule icône pour toutes les formes ; chargée sur le sort connu 5215 (Prowl) ; aucune forme aquatique |
| Mark of the Wild (1126, Gift 21850) | présent, reste <= 300 s, absent, zone de repos | option « Behavior » (présent / absent / toujours) ; masquée en zone de repos ; absent : alpha 0,5 grisé |
| Omen of Clarity (16864) | mêmes six déclencheurs que Mark of the Wild | suit l'ID du talent passif (16864), pas le proc 16870 : icône sans valeur sur Forever |
| Thorns (467) | mêmes six déclencheurs | idem, par nom donc tous les rangs |

### 2.5 Ressources et barres

| Barre | Déclencheur | Chargement | Remarques |
|---|---|---|---|
| Health Bar | `Health` joueur | désactivée par défaut | comme au chaman |
| Mana Bar | `Power` mana + forme absente (`showOnMissing`) | classe | mana pleine uniquement hors forme |
| Mana Bar (Off-Spec) | `Power` mana + forme Chat, Ours ou Dire Bear présente | classe | fine (5 de haut par défaut), couleur différente à 85 % de mana ou plus (seuil natif) |
| Rage Bar | `Power` type 1 + forme Ours ou Dire Bear | classe | texte de valeur |
| Energy Bar | `Power` type 3 + forme Chat + code du tick d'énergie | sort connu 768 | porte le tick d'énergie |
| Combo Points | 5 barres, `Power` type 4 chacune + forme Chat | sort connu 768 | segment i allumé au i-ème point ; couleur « haute » à 4 points, « pleine » à 5, « dépassée » à 6 ; changement de couleur par code de condition |
| Energy Tick | forme (stance) Chat + `Power` énergie | sort connu 768 | curseur à étincelle, cycle de 2 s |
| Mana Tick | comme au chaman | - | curseur de tic de mana |
| Cast Bar | `Cast` joueur | classe + reste de rôle | couleurs normale / ininterruptible / canalisée ; coupe la barre Blizzard au chargement |

### 2.6 Formes, mana en forme, points de combo, Omen of Clarity

- Formes : le pack ne s'appuie jamais sur la condition `formID`. Il lit une aura de forme (IDs 768, 5487, 9634) par `aura2`, en mode « présent » pour Chat et Ours, en mode « absent » pour les icônes de lanceur. Forme Voyage et Moonkin ne servent qu'à l'icône « Form ». Aucune icône spéciale Moonkin n'existe pour les procs.
- Mana en forme : barre de mana fine, visible seulement en forme ; la barre pleine disparaît en forme.
- Points de combo : 5 segments chargés sur le sort Cat Form (768). Chaque segment lit le type de puissance 4 ; la couleur change à 4 points (un point de l'objectif), à 5 (plein) et à 6 (dépassé).
- Omen of Clarity : une icône de maintenance sur le talent passif et une icône Clearcasting (16870) dans les effets, avec lueur.

## 3. Options d'auteur propres à la classe (Class Options)

Barre de mana (hauteur, format de texte à cinq choix, police, taille, deux couleurs, sens du dégradé) ; barre de mana hors forme (hauteur, police, taille, couleurs normale et « haute », dégradés) ; barre d'énergie, barre de rage (hauteur, police, taille, couleurs, dégradé) ; points de combo (hauteur, police, taille, couleurs normale, haute, pleine, dépassée, dégradés). Options par aura : Mana Tick (tolérance, décalage), icônes utilitaires et maintenance (comportement d'affichage). Les options générales sont celles du chaman.

## 4. Code personnalisé propre à la classe (idées seulement)

- Energy Tick : un état chronométré de 2 s relancé quand l'énergie remonte ou quand l'énergie est pleine, comparaison avec la dernière valeur lue. Bloqué (voir 5).
- Mana Tick : comme au chaman (comparaison avant / après de la mana, cycle de 2 s, pause de 5 s après un lancement coûtant de la mana).
- Fonction de croissance « ressource » : place les 5 segments de combo côte à côte dans le cadre de ressources. Remplaçable par un groupe dynamique ou des offsets du générateur.
- Conditions des segments de combo : code qui fixe un état de couleur et demande une mise à jour du dégradé. Remplaçable par des seuils natifs.
- Logique « Behavior » des maintenances et logique « utilitaire » : comme au chaman.
- Désactivation de la barre d'incantation Blizzard au chargement : comme au chaman.

## 5. Bloqué sur Forever

- Tick d'énergie : compare la puissance à sa valeur précédente. Valeurs secrètes en combat, bloqué.
- Tick de mana : idem (comme au chaman).
- Texte de la barre de mana avec formats (K, pourcentage) calculé en Lua : arithmétique sur valeur secrète. Remplaçable par les formats natifs `%c` et `%p`.
- Toutes les auras lues par `aura2` en combat : Faerie Fire, Clearcasting, Nature's Grace, Demoralizing Roar, Moonfire, Insect Swarm, Rejuvenation, Regrowth, Rake, Rip, Enrage, Frenzied Regeneration, Barkskin, Innervate, Nature's Swiftness, Prowl, Form, Mark of the Wild, Thorns, Dash, Nature's Grasp, buffs et débuffs de cible des utilitaires, et toutes les conditions de forme (rangées et barres). Remplaçable par `secretAura` ; la lecture de la forme par `secretAura` est à confirmer en combat.
- Aucun usage du journal de combat. Aucune comparaison de recharge en Lua.

## 6. Éléments douteux sur Forever

- Tiger's Fury (5217) et Faerie Fire (Feral) (16857) : absents du DB2 70245, icônes mortes.
- Feral Charge chargé sur 16979 : ID de talent (Talent.csv), le sort de Forever est 1238122.
- Hurricane chargé sur le rang 3 (17402) : l'icône n'apparaît qu'au niveau 60 ; le sort n'a pas de recharge.
- Omen of Clarity 16864 : talent donné absent de Forever, aura passive.
- Feral Charge ne lit que la forme Bear (5487) : Dire Bear (9634) le masque. Les formes Ours doivent porter les deux IDs.

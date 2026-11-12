# DESIGN.md — Musca Auras, interface d'options et mode placement

Addon World of Warcraft (WoW Forever 1.60.x, moteur retail 12.x, Lua 5.1). Périmètre : fenêtre d'options `/wa` et toutes ses fenêtres montées (éditeur de texte, sélecteurs d'icône, de texture, de modèle, import/export, revue de code, mise à jour, journal), fenêtre de confirmation, et mode placement `/wa unlock` (barre, panneau, boîtes d'aura, liens d'ancrage, grille).

**L'organisation et le contenu des options ne changent pas.** Même arborescence, mêmes onglets, mêmes widgets, mêmes libellés. Seul l'aspect change : couleurs, polices, bordures, états, mouvement.

Aperçu de référence : `design-apercu.html` (racine du dépôt), mêmes valeurs que ce fichier.

Charte de marque prolongée : celle du site Musca (graine or `#e8b543`, graphite chaud, givre `#66caff`). Le jeu impose le reste : thème sombre seul, angles droits, aucun fichier image nouveau.

---

## 1. Direction

**Précis, dense, laiton sur graphite.**

- **Matière : un instrument de mesure.** Boîtier en graphite mat presque noir, graduations et repères gravés en laiton (l'or du logo), un seul témoin froid (le givre) pour ce qui relie deux éléments (ancrage, aimantation). Le logo rond Musca, un monogramme or dans un anneau, se lit comme le cadran de l'instrument : il sert d'emblème au mode placement.
- **Pourquoi** : `/wa` est un outil de réglage fin (positions au pixel, seuils, conditions). On y passe des heures, par-dessus un monde 3D chargé. Il faut une surface calme et opaque, des repères nets, et une seule couleur qui dit « ceci est actif ».
- **Densité : outil métier dense.** Contrôles de 22 px, lignes de liste de 32 px, échelle typographique 1,2. On ne gagne pas d'air au prix d'un défilement de plus.
- **Forme : angles droits partout.** Le jeu n'arrondit pas sans texture. Le seul cercle de l'interface est le logo.
- **Lumière** : un filet or de 1 px en dégradé (transparent → or → transparent) sous chaque barre de titre, et rien d'autre ne brille. Pas de halo, pas de flou.
- **Thème : sombre seul.** Les fenêtres du jeu le sont, et un fond clair éblouit par-dessus la scène. Pas de variante claire.

## 2. Couleur graine et accent

- **Graine : or Musca `#e8b543`** (oklch 0.80 0.140 84). C'est l'or de la marque (site, logos). Le logo en jeu mesure `#c8a969` (oklch 0.75 0.090 84) : même teinte, plus éteint. On garde la graine de marque, plus lumineuse, pour qu'elle porte l'état « actif » sur un fond presque noir.
- **Accent : givre `#66caff`** (oklch 0.80 0.120 234), complémentaire adjacent de la graine (`palette.sh harmonie`). Rôle unique : **la relation** (ligne d'ancrage, « Follows: », guide et cible d'aimantation, info). Jamais pour un bouton ni pour la sélection.
- **Neutres : graphite chaud** teinte 84, chroma 0,004 à 0,011 (les valeurs du site). La gamme `--neutre` de l'outil (chroma 0,015 à 0,020) tire au brun : écartée.
- **Écarté : le bleu actuel du mode placement** (bordure `0.1, 0.5, 0.9` = `#1a80e6`, oklch 0.60 0.177 254, fond `#131d24` teinte 239). Bleu d'interface par défaut, sans lien avec la marque. Le fond bleuté du logo (`#121d31`, teinte 262) reste dans le logo, il ne devient pas une couleur d'interface.
- **Écarté : l'or Blizzard** `1, 0.82, 0` (guides d'aimantation, cible de lien actuels). Remplacé par les tokens ci-dessous.

## 3. Gammes (sorties de `palette.sh`)

Format WoW : `r, g, b` en flottants 0-1, alpha donné par le rôle.

### Or, teinte 84 (`gamme "#e8b543"`)

| Pas | Hex | oklch | WoW r, g, b | Usage |
|---|---|---|---|---|
| 100 | `#fbe9c6` | 0.94 0.050 | 0.984, 0.914, 0.776 | reflet de l'emblème |
| 200 | `#f4d392` | 0.88 0.090 | 0.957, 0.827, 0.573 | survol du principal, focus |
| 300 | `#e8b543` | 0.80 0.140 (graine) | 0.910, 0.710, 0.263 | primaire, sélection, axes, filet |
| 400 | `#cc9800` | 0.71 0.146 | 0.800, 0.596, 0.000 | bas du dégradé du principal, enfoncé |
| 500 | `#aa7e00` | 0.62 0.127 | 0.667, 0.494, 0.000 | remplissage du curseur |
| 950 | `#2d1f00` | 0.25 0.052 | 0.176, 0.122, 0.000 | fond de la boîte sélectionnée (mode placement) |
| sélection | `#2f2512` | 0.27 0.035 | 0.184, 0.145, 0.071 | fond de ligne sélectionnée (`info "oklch(0.27 0.035 84)"`) |

### Graphite chaud, teinte 84 (valeurs du site, `palette.sh info`)

| Pas | Hex | oklch | WoW r, g, b | Rôle |
|---|---|---|---|---|
| 1000 | `#080706` | 0.13 0.004 | 0.031, 0.027, 0.024 | puits (champs, éditeur), voile |
| 950 | `#0f0e0c` | 0.165 0.005 | 0.059, 0.055, 0.047 | fond de fenêtre |
| 925 | `#151411` | 0.19 0.006 | 0.082, 0.078, 0.067 | bande (titre, outils, onglets, pied) |
| 900 | `#1d1c18` | 0.225 0.007 | 0.114, 0.110, 0.094 | surface (zone d'onglet, panneau) |
| 850 | `#272521` | 0.265 0.008 | 0.153, 0.145, 0.129 | surface relevée, survol |
| 800 | `#32302b` | 0.31 0.009 | 0.196, 0.188, 0.169 | bordure |
| 700 | `#45423c` | 0.38 0.010 | 0.271, 0.259, 0.235 | bordure de survol, pouce de défilement |
| 550 | `#7a7770` | 0.57 0.011 | 0.478, 0.467, 0.439 | bordure de champ, texte désactivé, indicatif |
| 400 | `#a29e97` | 0.70 0.011 | 0.635, 0.620, 0.592 | texte discret |
| 200 | `#cac7c2` | 0.83 0.008 | 0.792, 0.780, 0.761 | texte secondaire, icônes au repos |
| 50 | `#f1f0ed` | 0.955 0.004 | 0.945, 0.941, 0.929 | texte |

### Givre, teinte 234 (`gamme "#66caff"`)

| Pas | Hex | WoW r, g, b | Usage |
|---|---|---|---|
| 200 | `#abe0ff` | 0.671, 0.878, 1.000 | ligne d'ancrage de l'aura sélectionnée |
| 300 | `#66caff` | 0.400, 0.792, 1.000 | accent, guides d'aimantation, « Follows: » |
| 400 | `#00aff0` | 0.000, 0.686, 0.941 | lignes d'ancrage au repos |
| 950 | `#002537` | 0.000, 0.145, 0.216 | remplissage de la cible d'aimantation |

### Sémantiques (clarté 0,70 à 0,78, comme la graine)

| Rôle | Hex | oklch | WoW r, g, b |
|---|---|---|---|
| succès (chargée, valide) | `#67d283` | 0.78 0.150 150 | 0.404, 0.824, 0.514 |
| alerte (avertissement) | `#f8a052` | 0.78 0.140 60 | 0.973, 0.627, 0.322 |
| erreur | `#f66d67` | 0.70 0.170 25 | 0.965, 0.427, 0.404 |
| info | = givre-300 `#66caff` | 0.80 0.120 234 | 0.400, 0.792, 1.000 |

## 4. Rôles

Alpha donné en quatrième valeur (`r, g, b, a`). Répartition 60-30-10 : graphite (fonds, textes), or (actif, primaire, sélection, filets), givre (relations, info).

### Fenêtres

| Rôle | Pas | WoW `r, g, b, a` |
|---|---|---|
| `fond` | graphite-950 | 0.059, 0.055, 0.047, 0.97 |
| `bande` | graphite-925 | 0.082, 0.078, 0.067, 1 |
| `surface` | graphite-900 | 0.114, 0.110, 0.094, 1 |
| `surface-relevee` | graphite-850 | 0.153, 0.145, 0.129, 1 |
| `survol` | graphite-850 | 0.153, 0.145, 0.129, 1 |
| `selection` | or-sélection | 0.184, 0.145, 0.071, 1 |
| `puits` | graphite-1000 | 0.031, 0.027, 0.024, 1 |
| `bordure` | graphite-800 | 0.196, 0.188, 0.169, 1 |
| `bordure-survol` | graphite-700 | 0.271, 0.259, 0.235, 1 |
| `bordure-champ` | graphite-550 | 0.478, 0.467, 0.439, 1 |
| `texte` | graphite-50 | 0.945, 0.941, 0.929, 1 |
| `texte-secondaire` | graphite-200 | 0.792, 0.780, 0.761, 1 |
| `texte-discret` | graphite-400 | 0.635, 0.620, 0.592, 1 |
| `texte-desactive` | graphite-550 | 0.478, 0.467, 0.439, 1 |
| `primaire` | or-300 | 0.910, 0.710, 0.263, 1 |
| `primaire-survol` | or-200 | 0.957, 0.827, 0.573, 1 |
| `primaire-bas` | or-400 | 0.800, 0.596, 0.000, 1 |
| `sur-primaire` | graphite-950 | 0.059, 0.055, 0.047, 1 |
| `accent` | givre-300 | 0.400, 0.792, 1.000, 1 |
| `succes`, `alerte`, `erreur`, `info` | § 3 | alpha 1 |
| `focus` | or-200 | 0.957, 0.827, 0.573, 1 |
| `reflet` (liseré haut des bandes) | blanc | 1, 1, 1, 0.04 |
| `filet` (dégradé sous les titres) | or-300 | centre 0.910, 0.710, 0.263, 0.55 ; bords alpha 0 |

### Mode placement

| Rôle | Valeur | WoW `r, g, b, a` |
|---|---|---|
| `voile` | graphite-1000 | 0.031, 0.027, 0.024, 0.40 |
| `grille` (toutes les 32 px) | graphite-50 | 0.945, 0.941, 0.929, 0.07 |
| `grille-majeure` (toutes les 128 px) | graphite-50 | 0.945, 0.941, 0.929, 0.14 |
| `grille-axe` (centre de l'écran) | or-300 | 0.910, 0.710, 0.263, 0.45 |
| `barre-fond` | graphite-925 | 0.082, 0.078, 0.067, 0.96 |
| `panneau-fond` | graphite-900 | 0.114, 0.110, 0.094, 0.96 |
| `boite-fond` repos | graphite-1000 | 0.031, 0.027, 0.024, 0.30 |
| `boite-bord` repos | graphite-200 | 0.792, 0.780, 0.761, 0.55 |
| `boite-fond` survol | graphite-1000 | 0.031, 0.027, 0.024, 0.45 |
| `boite-bord` survol | graphite-50 | 0.945, 0.941, 0.929, 0.90 |
| `boite-fond` sélection | or-950 | 0.176, 0.122, 0.000, 0.35 |
| `boite-bord` sélection, poignées | or-300 | 0.910, 0.710, 0.263, 1 |
| `etiquette-fond` (plaque du nom) | graphite-950 | 0.059, 0.055, 0.047, 0.85 |
| `guide-aimant` | givre-300 | 0.400, 0.792, 1.000, 0.90 |
| `cible-aimant` bord / fond | givre-300 / givre-950 | 0.400, 0.792, 1.000, 1 / 0.000, 0.145, 0.216, 0.35 |
| `lien` repos / aura sélectionnée | givre-400 / givre-200 | 0.000, 0.686, 0.941, 0.80 / 0.671, 0.878, 1.000, 1 |
| `boite-invalide` (cycle d'ancrage, cible refusée) | erreur | 0.965, 0.427, 0.404, 1 |

## 5. Contrastes vérifiés (WCAG 2, `palette.sh contraste`)

| Texte | fond `#0f0e0c` | bande `#151411` | surface `#1d1c18` | relevée `#272521` | puits `#080706` | sélection `#2f2512` |
|---|---|---|---|---|---|---|
| texte `#f1f0ed` | 16,92 | 16,16 | 14,96 | 13,42 | 17,66 | 13,21 |
| secondaire `#cac7c2` | 11,44 | 10,92 | 10,11 | 9,07 | 11,94 | 8,93 |
| discret `#a29e97` | 7,23 | 6,90 | 6,39 | 5,73 | 7,54 | 5,64 |
| or-300 `#e8b543` | 10,21 | 9,75 | 9,03 | 8,10 | 10,65 | 7,97 |
| givre `#66caff` | 10,52 | 10,04 | 9,30 | 8,34 | 10,98 | 8,21 |
| succès `#67d283` | 10,21 | 9,75 | 9,03 | 8,10 | 10,66 | 7,97 |
| alerte `#f8a052` | 9,31 | 8,89 | 8,23 | 7,38 | 9,72 | 7,27 |
| erreur `#f66d67` | 6,70 | 6,40 | 5,92 | 5,31 | 6,99 | 5,23 |
| désactivé / bord de champ `#7a7770` | 4,31 | 4,12 | 3,81 | 3,42 | **4,50** | — |

- Boutons : `sur-primaire` `#0f0e0c` sur or-300 10,21 ; sur or-400 (bas du dégradé, paire la plus faible) 7,40 ; sur or-200 (survol) 13,39 ; sur erreur (danger) 6,70.
- **Paire limite** : `#7a7770` en texte indicatif (placeholder) sur `puits` = 4,50, juste AA. Indicatif autorisé **seulement dans un puits**. Sur surface (3,81) ou relevée (3,42), `#7a7770` sert de bordure de champ (≥ 3 UI) ou de texte désactivé (exempté), jamais de texte lisible.
- Par-dessus le monde, pire cas mesuré sur un monde blanc (mélange par script, puis `contraste`) :
  - plaque d'étiquette `graphite-950` à 0,85 = `#333230` : texte 11,23, or 6,78 ;
  - barre à 0,96 = `#1e1d1b` : secondaire 9,99, discret 6,31 ;
  - panneau à 0,96 = `#262521` : discret 5,75, bord de champ 3,43.
  - En dessous de ces alphas, le texte n'est plus garanti : **alpha minimum 0,85 sous tout texte du mode placement**.

## 6. Typographie

Polices déjà livrées par Musca (`WeakAuras/Media/Fonts`, SIL OFL, déjà enregistrées dans LibSharedMedia par `WeakAuras/Types.lua`). Une seule famille, Fira, en trois coupes. Aucune police du jeu dans le chrome latin, sauf le repli CJK.

| Token | Fichier | Nom LSM | Usage |
|---|---|---|---|
| `police-texte` | `FiraSans-Medium.ttf` | `Fira Sans Medium` | libellés, boutons, onglets, valeurs, liste d'auras, infobulles maison |
| `police-titre` | `FiraSansCondensed-Heavy.ttf` | `Fira Sans Condensed Black` | titre de fenêtre, en-têtes de section de la liste, titres `Heading` en capitales |
| `police-chiffres` | `FiraMono-Medium.ttf` | `Fira Mono Medium` | coordonnées X/Y, tailles, valeurs de curseur et de SpinBox, version, éditeur de code, chaînes d'import |

`PT Sans Narrow` et `Fira Sans Condensed Medium` restent des polices d'aura, pas du chrome.

### Échelle (ratio 1,2, base 12 px)

| Token | Taille | Usage |
|---|---|---|
| `taille-xs` | 10 | méta (nombre d'auras d'un groupe, version), étiquettes de boîtes, en-têtes de section en capitales |
| `taille-s` | 12 | texte courant : libellés, valeurs, boutons, onglets, noms d'auras, code |
| `taille-m` | 14 | titre de fenêtre, nom de l'aura en tête du panneau de placement, titre `Heading` |
| `taille-l` | 17 | titre des fenêtres montées (Import, Update, Code Review) |

- Hauteur de ligne : 1,35 pour le texte multi-ligne (`FontString:SetSpacing(3)` à 12 px), 1 pour les contrôles.
- Capitales (`string.upper` à l'affichage) : seulement en `police-titre` `taille-xs` (en-têtes de section, titres `Heading`). Le jeu n'a pas d'interlettrage : capitales réservées au condensé gras, qui reste lisible serré.
- Contours : **aucun `OUTLINE`** dans les fenêtres (fond opaque). Dans le mode placement : ombre `SetShadowOffset(1, -1)`, `SetShadowColor(0, 0, 0, 0.9)` sur tout texte posé sur le monde, plus la plaque `etiquette-fond`. `OUTLINE` interdit sous 12 px (bave).
- Longueur de ligne : textes d'aide et descriptions (onglet Information, popups) bornés à 420 px (≈ 70 caractères à 12 px).

### Repli CJK et autres alphabets

- Fira couvre latin, cyrillique et grec : enUS, frFR, deDE, esES, esMX, itIT, ptBR, ruRU utilisent Fira.
- **zhCN, zhTW, koKR : les trois rôles passent sur `STANDARD_TEXT_FONT`** (la police du client : `Fonts\ARKai_T.ttf` en chinois, la police coréenne du jeu en coréen ; `Fonts\K_Pagetext.TTF` acceptable en coréen). Choix fait une fois au chargement selon `GetLocale()`, taille + 1 (ces polices sont plus petites à corps égal). Ne jamais coder les chemins CJK en dur ailleurs que dans la table de tokens.
- Éditeur de code en zh/ko : `STANDARD_TEXT_FONT` aussi (une chaîne Lua peut contenir des idéogrammes que Fira Mono n'a pas).
- Nom d'aura en caractères CJK sur un client latin : comportement actuel conservé (les polices du jeu latin n'ont pas ces glyphes non plus), pas de régression.

## 7. Espace, forme, mouvement

### Espacement (base 4 px)

`espace-1` 2, `espace-2` 4, `espace-3` 8, `espace-4` 12, `espace-5` 16, `espace-6` 24. Marges intérieures de fenêtre 8, entre groupes de widgets 12, entre fenêtres et monde 16.

### Hauteurs fixes

| Élément | Hauteur |
|---|---|
| barre de titre | 28 |
| barre d'outils (recherche + boutons-icônes) | 30 |
| onglet | 26 |
| contrôle (bouton, champ, liste déroulante) | 22 |
| case à cocher | 14 (zone cliquable 22) |
| ligne d'aura | 32 (icône 26) |
| en-tête de section de liste | 22 |
| pied | 22 |
| barre du mode placement | 40 |
| bouton-icône | 24 × 24 (icône 16) |

### Forme

- **Rayon : 0.** Angles droits partout, aucune texture d'angle. Le logo est le seul cercle.
- **Bordures : 1 px physique**, `BackdropTemplate` avec `edgeFile = "Interface\\Buttons\\WHITE8X8"`, `edgeSize` = 1 px réel (`PixelUtil.GetNearestPixelSize(1, frame:GetEffectiveScale(), 1)`). Un bord flou de 2 px est un défaut.
- **Marqueurs d'état : 2 px.** Soulignement d'onglet actif, barre gauche de ligne sélectionnée, haut de popup.
- **Élévation, un seul niveau** : les fenêtres flottantes (popup, liste déroulante ouverte, fenêtre principale) ont une ombre `Media\\Textures\\Border_DropShadow.blp` (déjà livrée) en noir 0,6, décalée de 4 px. Rien d'autre n'a d'ombre.
- **Reflet** : liseré `reflet` 1 px en haut de chaque bande. **Filet** : 1 px sous la barre de titre et sous la barre du mode placement, deux textures `WHITE8X8` côte à côte avec `SetGradient("HORIZONTAL", …)` (alpha 0 → 0,55 puis 0,55 → 0).
- Icônes existantes (`Media/Textures/*.tga`) teintées par `SetVertexColor` : `texte-secondaire` au repos, `texte` au survol, `primaire` quand l'interrupteur est actif.

### Mouvement

Règles :
1. **Une animation = une `AnimationGroup`** (Alpha, Scale, Translation) qui s'arrête seule. `SetToFinalAlpha(true)`. Pilote Lua `OnUpdate` seulement si la courbe est impossible en `AnimationGroup`, et il se retire (`SetScript("OnUpdate", nil)`) à `t >= 1`. **Aucun `OnUpdate` permanent.**
2. **Aucune animation pendant un glisser** (aura, poignée, curseur, fenêtre). Le retour est immédiat.
3. **Sortie instantanée** : fermeture de `/wa`, sortie du mode placement, fermeture de popup.
4. **Combat = coupure nette** : `PLAYER_REGEN_DISABLED` arrête toutes les `AnimationGroup` (`:Stop()`) et cache ; `PLAYER_REGEN_ENABLED` remet l'état final, sans animation.
5. **L'entrée ne bloque jamais la saisie** : boîtes, barre et panneau réagissent dès `t = 0`.
6. Survols et changements de couleur : **instantanés** (le jeu n'a pas de transition de couleur sans pilote ; un pilote par survol coûte plus qu'il ne rapporte).

Courbes nommées (lissage WoW `Animation:SetSmoothing`, équivalent CSS de l'aperçu) :

| Token | WoW | CSS |
|---|---|---|
| `courbe-lineaire` | `NONE` | `linear` |
| `courbe-sortie` | `OUT` | `cubic-bezier(0.25, 0.46, 0.45, 0.94)` |
| `courbe-entree` | `IN` | `cubic-bezier(0.55, 0.085, 0.68, 0.53)` |
| `courbe-entree-sortie` | `IN_OUT` | `cubic-bezier(0.455, 0.03, 0.515, 0.955)` |

Durées : `duree-breve` 0,12 s, `duree-courte` 0,20 s, `duree-moyenne` 0,35 s, `duree-longue` 0,45 s.

#### Ouverture de `/wa`

Alpha 0 → 1 + translation verticale −8 → 0 px, `duree-breve`, `courbe-sortie`. Fermeture instantanée. Retour depuis le mode placement : instantané (pas d'animation sur une sortie).

#### Onglets, listes

Changement d'onglet : contenu et soulignement instantanés (AceGUI reconstruit le contenu, une animation dessus ferait clignoter). Dépliage d'un groupe de la liste : instantané.

#### Entrée du mode placement : « Mise au point » (1,15 s, chevauchée)

L'instrument fait sa mise au point sur l'écran : l'emblème se pose, un réticule converge sur lui, ses branches deviennent les axes, la graduation se propage du centre vers les bords, puis les outils arrivent. Pas de rotation, pas de rebond, pas de scintillement.

| Départ | Durée | Élément | Animation | Courbe |
|---|---|---|---|---|
| 0,00 | 0,16 | fenêtre `/wa` | alpha 1 → 0, échelle 1 → 0,97, puis `Hide()` | `sortie` |
| 0,00 | 0,30 | voile | alpha 0 → 0,40 | `lineaire` |
| 0,05 | 0,20 | emblème (`logo_musca_round.tga`, 112 px, centre de l'écran) | alpha 0 → 1 | `sortie` |
| 0,05 | 0,35 | emblème | échelle 1,15 → 1 (« mise au point ») | `sortie` |
| 0,05 | 0,35 | réticule : 4 segments or-300 de 1 × 20 px | translation de 120 px à 64 px du centre, alpha 0 → 1 | `sortie` |
| 0,40 | 0,30 | axes de la grille (or-300 à 0,45) | échelle 0 → 1 depuis le centre (les branches du réticule s'allongent jusqu'aux bords) | `sortie` |
| 0,45 | 0,15 par bande | grille | 6 bandes concentriques (cadres parents des lignes, par distance au centre), départs décalés de 0,05 s : alpha 0 → valeur finale | `lineaire` |
| 0,45 | 0,18 par boîte | boîtes d'aura | alpha 0 → repos, départ décalé de 0,03 s par boîte selon la distance au centre, décalage total plafonné à 0,25 s | `sortie` |
| 0,50 | 0,25 | barre du haut | translation depuis −40 px (hors écran) → 0, alpha 0 → 1 en 0,12 | `sortie` |
| 0,55 | 0,25 | panneau de droite | translation +24 px → 0, alpha 0 → 1 | `sortie` |
| 0,55 | 0,25 | reflet de l'emblème | un aplat or-100 de 2 px, masqué au disque du logo, traverse en diagonale, alpha 0,6 | `entree-sortie` |
| 0,70 | 0,45 | emblème et réticule | alpha 1 → 0, puis `Hide()` | `entree` |

Fin à 1,15 s. Aucune boucle. Le mode est utilisable dès 0 s.

#### Réactions dans le mode placement

- **Survol d'une boîte** : fond et bord passent au survol **immédiatement**. Après `duree-breve` d'intention (`C_Timer.NewTimer(0.12)`, annulé à la sortie du curseur), les actions de la boîte (bouton d'ancrage) apparaissent en alpha 0 → 1 sur `duree-breve`. Départ du curseur : actions masquées après 0,12 s, instantanément.
- **Sélection** : bord or-300 + poignées, puis deux pulsations du bord (alpha 1 → 0,35 → 1, 2 × 0,25 s, `entree-sortie`), et c'est tout.
- **Glisser** : aucune animation. Coordonnées affichées en `police-chiffres` dans une plaque près du curseur.
- **Aimantation** : guides givre 1 px sur toute la largeur ou hauteur de l'écran et cible en contour givre 2 px, **instantanés et fixes** (pas de pulsation : on est en plein glisser).
- **Ligne d'ancrage** : apparaît et disparaît sans transition.

## 8. Composants

### Fenêtre `/wa` et fenêtres montées

| Composant | Règle |
|---|---|
| Cadre | Remplace `PortraitFrameTemplate` : cadre `BackdropTemplate`, fond `fond`, bord `bordure`, ombre portée. Plus de portrait Blizzard ni de `Bg` gris. |
| Barre de titre | 28 px, `bande` + `reflet` ; logo rond 18 px à 8 px du bord ; « Musca Auras » `police-titre` `taille-m` `texte` ; version en `police-chiffres` `taille-xs` `texte-discret` ; filet or dessous. Zone de glisser = toute la barre. |
| Fermer | 28 × 28 à droite, croix de deux aplats 1,5 × 12 px tournés à 45° (`SetRotation`), `texte-secondaire` ; survol : fond `survol`, croix `erreur`. |
| Maximiser | 28 × 28, carré de 10 px en bord 1 px `texte-secondaire` ; état maximisé : deux carrés décalés ; survol : fond `survol`, trait `texte`. |
| Redimensionner | angle bas-droit 16 × 16 : trois diagonales de 1 px `bordure-champ` ; survol : `primaire`. Remplace les textures `SizeGrabber`. |
| Barre d'outils | 30 px, `bande`, bord bas `bordure`. Recherche à gauche, boutons-icônes 24 px à droite, groupés (historique / création / interrupteurs / outils) séparés par un trait vertical 1 × 14 px `bordure`. Le groupe des interrupteurs commence par Unlock (Placer), bouton principal à réticule en aplats `sur-primaire`. Une icône dont le dessin occupe une petite partie de sa texture est recadrée sur ce dessin (~14 px) ; une icône trop pâle est redessinée en aplats 1 px. Le bouton qui supprime passe en `erreur` au survol. |
| Recherche | champ `puits`, bord `bordure-champ`, loupe dessinée (anneau = `Circle_White_Border.tga` déjà livré, manche = aplat tourné) `texte-discret`, indicatif « Search » `texte-desactive` ; effacement « × » discret dès qu'il y a du texte. |
| Bouton-icône | 24 × 24, sans fond ; icône `texte-secondaire` ; survol : fond `survol`, icône `texte` ; interrupteur actif (verrou, aimant, grille, inutilisés) : icône `primaire` + trait 2 px `primaire` sous l'icône ; désactivé : alpha 0,45. Infobulle obligatoire. |
| Pied | 22 px, `bande`, bord haut `bordure`, icônes de liens 14 px `texte-discret`, survol `texte`. |
| Onglets | rangée sur `bande` ; onglet 26 px, texte `police-texte` `taille-s` `texte-secondaire`, marge 12 ; survol : `texte` ; actif : fond `surface`, texte `texte`, soulignement 2 px `primaire`, pas de bord. Remplace `UI-OptionsFrame-*Tab`. |
| Zone d'onglet | fond `surface`, marges 8, défilement à droite. |
| Fenêtre montée (éditeur, sélecteurs, import) | même zone que l'onglet, titre `taille-l` `texte`, actions en bas à droite : Done/Import en principal, Cancel en secondaire. |

### Contrôles

| Composant | Règle |
|---|---|
| Bouton principal | dégradé vertical `primaire` → `primaire-bas` (`SetGradient("VERTICAL", bas, haut)`), texte `sur-primaire` `police-texte` 12, hauteur 22, marge 12 ; survol : `primaire-survol` → `primaire` ; enfoncé : aplat `primaire-bas`, texte décalé de 1 px ; focus clavier : contour 1 px `focus` décalé de 2 px ; désactivé : alpha 0,45 ; attente : libellé remplacé par « … », largeur figée, clic ignoré. **Un seul par fenêtre ou panneau** (Done, Import, Save and quit ; dans la fenêtre /wa : Unlock de la barre d'outils). |
| Bouton secondaire | fond `surface-relevee`, bord `bordure-champ`, texte `texte` ; survol : bord `primaire`, fond `bordure` ; enfoncé : fond `puits` ; désactivé : alpha 0,45. Tous les `UIPanelButtonTemplate` actuels deviennent secondaires sauf les principaux nommés ci-dessus. |
| Bouton discret | sans fond ni bord, texte `texte-secondaire` ; survol : texte `primaire-survol`. (Revert, Cancel dans un popup.) |
| Bouton danger | fond `erreur`, texte `sur-primaire` ; réservé à la confirmation d'une suppression. Le bouton qui ouvre la confirmation est secondaire avec texte `erreur`. |
| Case à cocher | carré 14 px `puits`, bord `bordure-champ` ; cochée : bord `primaire`, carré intérieur 8 px `primaire` ; troisième état (cases tristate) : barre intérieure 8 × 2 `primaire` ; survol : bord `texte-secondaire` ; libellé `texte` à 6 px, cliquable aussi. |
| Champ de saisie | 22 px, fond `puits`, bord `bordure-champ`, texte `texte`, marge 6, indicatif `texte-desactive` ; focus : bord `primaire` ; erreur : bord `erreur` + ligne d'aide `erreur` `taille-xs` qui dit quoi saisir ; nombres en `police-chiffres`. Remplace `InputBoxTemplate`. |
| Liste déroulante | fermée = champ + chevron (deux aplats 1 × 6 px tournés) `texte-secondaire` ; ouverte : fond `surface-relevee`, bord `bordure-survol`, ombre, lignes 20 px, survol fond `bordure`, valeur courante marquée d'un carré 4 px `primaire` à gauche ; titre de groupe dans la liste en `police-titre` `taille-xs` `texte-discret`. Habille LibUIDropDownMenu sans changer ses entrées. |
| Curseur (Slider) | piste 4 px `puits` bord `bordure` ; partie remplie `or-500` ; pouce 8 × 16 `texte`, bord `fond` ; survol pouce `primaire-survol` ; valeur dans un champ 22 px `police-chiffres` à droite. Libellé au-dessus, bornes en `texte-discret` `taille-xs`. |
| SpinBox / Input numériques | champ `puits` `police-chiffres`, boutons − / + 22 × 22 en bouton-icône. |
| Sélecteur de couleur | pastille 22 × 14, bord `bordure-champ`, damier de transparence en deux gris graphite (aplats 4 px) ; survol bord `primaire`. |
| Titre `Heading` | `police-titre` `taille-xs` capitales `texte-secondaire`, trait 1 px `bordure` à droite du texte jusqu'au bord (pas des deux côtés : alignement à gauche). |
| Groupe `InlineGroup` | fond `surface-relevee`, bord `bordure`, marge 8 ; titre au-dessus en `taille-s` `texte-secondaire`. |
| `Expand` | chevron 10 px `texte-secondaire` + libellé ; ouvert : chevron vers le bas, libellé `texte`. |
| Barre de défilement | 6 px, sans flèches, piste transparente, pouce `bordure-survol` ; survol `bordure-champ` ; glisser `primaire-bas`. |
| Éditeur de code | fond `puits`, `police-chiffres` 12, numéros de ligne `texte-desactive` sur `fond`, ligne courante `surface`. Coloration : mots-clés `accent`, chaînes `succes`, nombres `alerte`, commentaires `texte-discret`, fonctions du jeu `primaire-survol`, reste `texte`. Erreur de compilation : bandeau `erreur` en tête, texte `sur-primaire`. |
| Infobulle | conserve `GameTooltip` (partagée avec le jeu, ne pas la reskinner). |

### Liste d'auras (colonne gauche)

| Composant | Règle |
|---|---|
| En-tête de section (Loaded, Not loaded…) | 22 px, `bande`, `police-titre` `taille-xs` capitales `texte-secondaire`, compte en `police-chiffres` `texte-discret` à droite, chevron. Remplace `UI-Listbox-Highlight2`. |
| Ligne au repos | 32 px, fond transparent ; icône 26 px avec bord 1 px `fond` ; nom `taille-s` `texte` ; sous-ligne `taille-xs` `texte-discret` (type, nombre d'enfants). |
| Survol | fond `survol` ; flèches haut/bas et œil apparaissent (instantané) en `texte-secondaire`. |
| Sélectionnée | fond `selection`, barre gauche 2 px `primaire`, nom `texte`. Multisélection : même rendu sur chaque ligne. |
| Enfant de groupe | retrait 12 px, trait vertical 1 px `bordure` au niveau du retrait. |
| Statuts | carré 6 px à droite du nom : `succes` chargée, `alerte` avertissement, `erreur` erreur ; non chargée : nom en `texte-discret`, pas de carré. Jamais la couleur seule : l'infobulle dit le statut. |
| Masquée (œil fermé) | icône à alpha 0,45, œil barré `texte-discret`. |
| Cible de glisser-déposer | trait 2 px `primaire` entre deux lignes ; groupe cible : bord 1 px `primaire`. |
| Liste vide / recherche sans résultat | ligne `texte-secondaire` qui dit quoi faire (« No aura matches "x". Clear the search. ») + bouton discret. |

### Popup de confirmation (remplace le `StaticPopup` du mode placement et des suppressions)

Cadre 360 px, `surface-relevee`, bord `bordure-survol`, haut 2 px `primaire` (ou `erreur` pour une suppression), ombre ; texte `taille-s` `texte`, 420 px max ; boutons à droite : principal (Save and quit) ou danger (Delete), secondaire (Discard), discret (Cancel). Échap = Cancel. Apparition instantanée.

### Mode placement

| Composant | Règle |
|---|---|
| Voile | plein écran, `voile`. |
| Grille | lignes 1 px tous les 32 px `grille`, toutes les 128 px `grille-majeure`, axes centraux `grille-axe`. Bascule Grid : instantané. |
| Barre du haut | centrée en haut, 40 px, marge 16 du bord, `barre-fond`, bord `bordure`, filet or dessous ; gauche : logo 20 px + « Musca Auras » `police-titre` `taille-m` + « Placement » `texte-discret` ; centre : cases Grid, Snap ; droite : Revert (discret), Quit (secondaire), Save and quit (principal). |
| Panneau de droite | 220 px, à 16 px du bord, `panneau-fond`, bord `bordure` ; en-tête : nom de l'aura `taille-m` `texte`, type `taille-xs` `texte-discret` ; lignes 22 px : libellé `texte-secondaire` à gauche, valeur dans un champ `police-chiffres` à droite (X Offset, Y Offset, Width, Height, Space) ; Grow et Align en bouton secondaire qui affiche la valeur ; « Follows: nom » en `accent` ; Anchor to… secondaire, Remove Anchor secondaire texte `erreur`. Aucune sélection : ligne `texte-secondaire` « Click an aura to edit its position. » |
| Boîte d'aura, repos | fond et bord `boite-*` repos ; nom sur plaque `etiquette-fond` collée au-dessus du coin haut-gauche, `taille-xs` `texte`, ombre. |
| Survol | fond et bord survol ; actions après l'intention (§ 7). |
| Sélection | bord `primaire`, fond or-950 à 0,35, 8 poignées 6 × 6 `primaire` (coins et milieux), nom sur plaque en `primaire`. |
| Glisser | rendu sélection + plaque de coordonnées `police-chiffres` `taille-xs` (« x 120  y −84 »). |
| Aimantation | guides `guide-aimant`, cible en `cible-aimant`. |
| Invalide | bord 2 px `erreur`, curseur refusé. |
| Lien d'ancrage | `Frame:CreateLine`, épaisseur 1 px réel, `lien` repos ; extrémité source : carré 4 px plein ; extrémité cible : carré 6 px en bord 1 px. Lien de l'aura sélectionnée : `lien` sélectionnée. |
| Choix d'une cible (Anchor to…) | voile renforcé (`voile` + 0,25), candidates en bord `accent` à 0,7, survol bord `accent` plein + fond `cible-aimant` ; cible refusée : bord `erreur`. Texte d'aide dans la barre : « Click the aura to follow. Esc to cancel. » |

## 9. Interdits du projet

1. Ne rien reprendre d'EllesmereUI : ni textures, ni logo cadenas, ni palette, ni code. Seul le principe de phases chevauchées est commun.
2. Aucun nouveau fichier image. Tout est aplat `WHITE8X8`, `SetColorTexture`, `SetGradient`, bordure 1 px, police, ou média déjà livré (logo rond, `Circle_White_Border.tga`, `Border_DropShadow.blp`, icônes de `Media/Textures`).
3. Aucune texture Blizzard de décor dans le chrome reskinné : pas de parchemin, de cadre or, de `UI-Panel-*`, de `UI-OptionsFrame-*Tab`, de `UIPanelButtonTemplate`, de `PortraitFrameTemplate`. Un écran mi-Blizzard mi-Musca est un défaut.
4. Aucun `OnUpdate` permanent ; aucune animation en boucle ; aucune animation pendant un glisser ou en combat.
5. Aucune couleur en dur hors de la table de tokens : pas de `1, 0.82, 0`, pas de `0.1, 0.5, 0.9`, pas de gris pur `0.5, 0.5, 0.5`.
6. L'or n'est ni décoratif ni réparti partout : actif, sélection, principal, axes, filet. Le givre ne sert qu'aux relations et à l'info.
7. Pas de dégradé de fond, pas de halo, pas de transparence sous 0,85 derrière un texte.
8. Pas de coins arrondis simulés, pas de cartes ombrées pour chaque groupe d'options.
9. Pas de `OUTLINE` sur du texte de fenêtre ; pas de texte gris sous 4,5:1.
10. Ne pas changer l'ordre, le nom ou l'emplacement d'une option : le reskin est visuel seulement.

## 10. Intégration

- Un seul fichier de tokens côté options (ex. `WeakAurasOptions/Style/StyleTokens.lua`) qui expose la table ci-dessous et le choix de police selon `GetLocale()`. Chaque widget lit cette table.
- Les mêmes valeurs en CSS pour l'aperçu et le site.

### Table Lua

```lua
-- Couleurs : { r, g, b, a }
local couleur = {
  fond               = { 0.059, 0.055, 0.047, 0.97 }, -- #0f0e0c graphite-950
  bande              = { 0.082, 0.078, 0.067, 1 },    -- #151411 graphite-925
  surface            = { 0.114, 0.110, 0.094, 1 },    -- #1d1c18 graphite-900
  surfaceRelevee     = { 0.153, 0.145, 0.129, 1 },    -- #272521 graphite-850
  survol             = { 0.153, 0.145, 0.129, 1 },    -- #272521
  selection          = { 0.184, 0.145, 0.071, 1 },    -- #2f2512 or-sélection
  puits              = { 0.031, 0.027, 0.024, 1 },    -- #080706 graphite-1000
  bordure            = { 0.196, 0.188, 0.169, 1 },    -- #32302b graphite-800
  bordureSurvol      = { 0.271, 0.259, 0.235, 1 },    -- #45423c graphite-700
  bordureChamp       = { 0.478, 0.467, 0.439, 1 },    -- #7a7770 graphite-550
  texte              = { 0.945, 0.941, 0.929, 1 },    -- #f1f0ed graphite-50
  texteSecondaire    = { 0.792, 0.780, 0.761, 1 },    -- #cac7c2 graphite-200
  texteDiscret       = { 0.635, 0.620, 0.592, 1 },    -- #a29e97 graphite-400
  texteDesactive     = { 0.478, 0.467, 0.439, 1 },    -- #7a7770 graphite-550
  primaire           = { 0.910, 0.710, 0.263, 1 },    -- #e8b543 or-300
  primaireSurvol     = { 0.957, 0.827, 0.573, 1 },    -- #f4d392 or-200
  primaireBas        = { 0.800, 0.596, 0.000, 1 },    -- #cc9800 or-400
  primaireRemplissage= { 0.667, 0.494, 0.000, 1 },    -- #aa7e00 or-500
  surPrimaire        = { 0.059, 0.055, 0.047, 1 },    -- #0f0e0c
  accent             = { 0.400, 0.792, 1.000, 1 },    -- #66caff givre-300
  succes             = { 0.404, 0.824, 0.514, 1 },    -- #67d283
  alerte             = { 0.973, 0.627, 0.322, 1 },    -- #f8a052
  erreur             = { 0.965, 0.427, 0.404, 1 },    -- #f66d67
  info               = { 0.400, 0.792, 1.000, 1 },    -- #66caff
  focus              = { 0.957, 0.827, 0.573, 1 },    -- #f4d392
  reflet             = { 1, 1, 1, 0.04 },
  filet              = { 0.910, 0.710, 0.263, 0.55 }, -- centre du dégradé, bords à 0
  -- mode placement
  voile              = { 0.031, 0.027, 0.024, 0.40 },
  grille             = { 0.945, 0.941, 0.929, 0.07 },
  grilleMajeure      = { 0.945, 0.941, 0.929, 0.14 },
  grilleAxe          = { 0.910, 0.710, 0.263, 0.45 },
  barreFond          = { 0.082, 0.078, 0.067, 0.96 },
  panneauFond        = { 0.114, 0.110, 0.094, 0.96 },
  boiteFond          = { 0.031, 0.027, 0.024, 0.30 },
  boiteBord          = { 0.792, 0.780, 0.761, 0.55 },
  boiteFondSurvol    = { 0.031, 0.027, 0.024, 0.45 },
  boiteBordSurvol    = { 0.945, 0.941, 0.929, 0.90 },
  boiteFondSelection = { 0.176, 0.122, 0.000, 0.35 }, -- #2d1f00 or-950
  etiquetteFond      = { 0.059, 0.055, 0.047, 0.85 },
  guideAimant        = { 0.400, 0.792, 1.000, 0.90 },
  cibleAimantFond    = { 0.000, 0.145, 0.216, 0.35 }, -- #002537 givre-950
  lien               = { 0.000, 0.686, 0.941, 0.80 }, -- #00aff0 givre-400
  lienSelection      = { 0.671, 0.878, 1.000, 1 },    -- #abe0ff givre-200
}

local MEDIA = "Interface\\AddOns\\WeakAuras\\Media\\Fonts\\"
local police = {
  texte    = MEDIA .. "FiraSans-Medium.ttf",
  titre    = MEDIA .. "FiraSansCondensed-Heavy.ttf",
  chiffres = MEDIA .. "FiraMono-Medium.ttf",
}
local taille = { xs = 10, s = 12, m = 14, l = 17 }
local locale = GetLocale()
if locale == "zhCN" or locale == "zhTW" or locale == "koKR" then
  police.texte, police.titre, police.chiffres = STANDARD_TEXT_FONT, STANDARD_TEXT_FONT, STANDARD_TEXT_FONT
  for nom, valeur in pairs(taille) do taille[nom] = valeur + 1 end
end

local espace = { 2, 4, 8, 12, 16, 24 }
local duree = { breve = 0.12, courte = 0.20, moyenne = 0.35, longue = 0.45 }
local courbe = { lineaire = "NONE", sortie = "OUT", entree = "IN", entreeSortie = "IN_OUT" }
```

### Variables CSS (aperçu)

```css
:root {
  color-scheme: dark;
  /* fenêtres */
  --couleur-fond: oklch(0.165 0.005 84 / 0.97);       /* #0f0e0c */
  --couleur-bande: oklch(0.19 0.006 84);              /* #151411 */
  --couleur-surface: oklch(0.225 0.007 84);           /* #1d1c18 */
  --couleur-surface-relevee: oklch(0.265 0.008 84);   /* #272521 */
  --couleur-survol: oklch(0.265 0.008 84);            /* #272521 */
  --couleur-selection: oklch(0.27 0.035 84);          /* #2f2512 */
  --couleur-puits: oklch(0.13 0.004 84);              /* #080706 */
  --couleur-bordure: oklch(0.31 0.009 84);            /* #32302b */
  --couleur-bordure-survol: oklch(0.38 0.010 84);     /* #45423c */
  --couleur-bordure-champ: oklch(0.57 0.011 84);      /* #7a7770 */
  --couleur-texte: oklch(0.955 0.004 84);             /* #f1f0ed */
  --couleur-texte-secondaire: oklch(0.83 0.008 84);   /* #cac7c2 */
  --couleur-texte-discret: oklch(0.70 0.011 84);      /* #a29e97 */
  --couleur-texte-desactive: oklch(0.57 0.011 84);    /* #7a7770 */
  --couleur-primaire: oklch(0.80 0.140 84);           /* #e8b543 */
  --couleur-primaire-survol: oklch(0.88 0.090 84);    /* #f4d392 */
  --couleur-primaire-bas: oklch(0.71 0.146 84);       /* #cc9800 */
  --couleur-primaire-remplissage: oklch(0.62 0.127 84); /* #aa7e00 */
  --couleur-sur-primaire: oklch(0.165 0.005 84);      /* #0f0e0c */
  --couleur-accent: oklch(0.80 0.120 234);            /* #66caff */
  --couleur-succes: oklch(0.78 0.150 150);            /* #67d283 */
  --couleur-alerte: oklch(0.78 0.140 60);             /* #f8a052 */
  --couleur-erreur: oklch(0.70 0.170 25);             /* #f66d67 */
  --couleur-info: oklch(0.80 0.120 234);              /* #66caff */
  --couleur-focus: oklch(0.88 0.090 84);              /* #f4d392 */
  /* mode placement */
  --couleur-voile: oklch(0.13 0.004 84 / 0.40);
  --couleur-grille: oklch(0.955 0.004 84 / 0.07);
  --couleur-grille-majeure: oklch(0.955 0.004 84 / 0.14);
  --couleur-grille-axe: oklch(0.80 0.140 84 / 0.45);
  --couleur-barre-fond: oklch(0.19 0.006 84 / 0.96);
  --couleur-panneau-fond: oklch(0.225 0.007 84 / 0.96);
  --couleur-boite-fond: oklch(0.13 0.004 84 / 0.30);
  --couleur-boite-bord: oklch(0.83 0.008 84 / 0.55);
  --couleur-boite-fond-selection: oklch(0.25 0.052 84 / 0.35); /* #2d1f00 */
  --couleur-etiquette-fond: oklch(0.165 0.005 84 / 0.85);
  --couleur-guide-aimant: oklch(0.80 0.120 234 / 0.90);
  --couleur-cible-aimant-fond: oklch(0.25 0.053 234 / 0.35); /* #002537 */
  --couleur-lien: oklch(0.71 0.149 234 / 0.80);       /* #00aff0 */
  --couleur-lien-selection: oklch(0.88 0.070 234);    /* #abe0ff */
  /* polices */
  --police-texte: "Fira Sans", sans-serif;            /* FiraSans-Medium, poids 500 */
  --police-titre: "Fira Sans Condensed", sans-serif;  /* FiraSansCondensed-Heavy, poids 900 */
  --police-chiffres: "Fira Mono", monospace;          /* FiraMono-Medium, poids 500 */
  --taille-xs: 10px; --taille-s: 12px; --taille-m: 14px; --taille-l: 17px;
  /* espace, forme */
  --espace-1: 2px; --espace-2: 4px; --espace-3: 8px; --espace-4: 12px; --espace-5: 16px; --espace-6: 24px;
  --rayon: 0;
  --bord: 1px;
  --marqueur: 2px;
  /* mouvement */
  --duree-breve: 120ms; --duree-courte: 200ms; --duree-moyenne: 350ms; --duree-longue: 450ms;
  --courbe-lineaire: linear;
  --courbe-sortie: cubic-bezier(0.25, 0.46, 0.45, 0.94);
  --courbe-entree: cubic-bezier(0.55, 0.085, 0.68, 0.53);
  --courbe-entree-sortie: cubic-bezier(0.455, 0.03, 0.515, 0.955);
}
```

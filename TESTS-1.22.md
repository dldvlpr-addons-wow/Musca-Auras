# Tests en jeu de la 1.22.0 : édition d'auras et design classique

Version 1.22.0 du 2026-11-25, entrée du même jour de `CHANGES.md`. Banc headless : 138 scénarios, 0 échec. Rien
n'est testé en jeu. Reprend l'étape 18 de `SUIVI-BUGS-ET-TESTS.md`.

Un seul 🔴 en échec bloque la mise en production. Noter pour chaque échec : la ligne du test, ce qui s'affiche, et
le texte de l'erreur Lua s'il y en a une.

Durée : 30 à 40 min. Les libellés cités sont en anglais ; client français entre parenthèses.

## 0. Préparation

1. [ ] Copier l'addon dans `Interface\AddOns\` (copie, pas de lien), lancer le jeu.
2. [ ] `/console scriptErrors 1`, puis `/reload`.
3. [ ] Avoir sous la main :
   - une aura à deux triggers avec une condition sur le trigger 2 ;
   - deux auras simples (icônes) visibles, non groupées ;
   - une aura importée de WeakAuras qui a des options custom, si possible.

## 1. Nom de trigger

1. [ ] Onglet **Trigger** de l'aura à deux triggers : champ « Trigger Name » (« Nom du déclencheur ») dans l'en-tête
   du trigger, avec une infobulle.
2. [ ] 🔴 Taper « Interrupt » dans le trigger 2 : le titre du trigger devient « Interrupt ». Onglet **Conditions** :
   « If Interrupt » à la place de « If Trigger 2 ». La liste des propriétés de condition montre « Interrupt ».
3. [ ] Onglet **Display**, source de l'icône : « Interrupt » à la place de « Trigger 2 ». Onglet **Trigger**, liste
   « Dynamic information » : « Dynamic information from Interrupt ».
4. [ ] Vider le champ, ou n'y mettre que des espaces : « Trigger 2 » revient partout.
5. [ ] `/reload` : le nom est gardé. Exporter l'aura puis la réimporter : le nom est gardé.

## 2. Options custom conditionnelles « Visible If »

Dans `/wa`, onglet **Custom Options** d'une aura, bouton du mode auteur.

1. [ ] Ajouter une option Toggle « Show text » et une option Input « Text ». Sur « Text », liste « Visible If »
   (« Visible si ») : « Always » (« Toujours ») et « Show text ».
2. [ ] 🔴 Choisir « Show text », valeur « True » (« Vrai »). Quitter le mode auteur : « Text » n'apparaît que si
   « Show text » est coché. Cocher et décocher : l'option apparaît et disparaît.
3. [ ] Avec une option Select comme cible : la liste des valeurs reprend ses choix. Avec une option Number comme
   cible : un champ texte demande la valeur.
4. [ ] Un groupe d'options avec une règle : tout son contenu disparaît avec lui.
5. [ ] 🔴 Supprimer l'option cible « Show text » : « Text » reste visible en mode utilisateur, aucune erreur Lua.
6. [ ] Remettre « Always » : l'option est toujours visible.
7. [ ] Exporter l'aura et l'importer dans WeakAuras (ou une version antérieure de Musca) si disponible : l'option
   reste visible, aucune erreur.

## 3. Ancrage en calant une aura sur une autre (Alt)

1. [ ] 🔴 `/wa`, sélectionner l'aura A. La glisser contre le bord droit de l'aura B jusqu'au trait d'alignement,
   tenir Alt, lâcher : A est ancrée à B (onglet **Display**, « Anchored To » : B). A n'a pas bougé à l'écran.
2. [ ] 🔴 Déplacer B : A suit.
3. [ ] Même chose sous B (bord bas) : ancrage en dessous.
4. [ ] Lâcher sans Alt : alignement seul, pas d'ancrage.
5. [ ] Lâcher avec Alt loin de tout bord, ou sur deux bords alignés côte à côte (même bord droit) : pas d'ancrage.
6. [ ] Ancrer A à B, puis tenter d'ancrer B à A : pas de boucle, aucune erreur.
   Lien refusé (l'autre aura n'a pas de position à l'écran) : ligne « The aura was not linked… » dans le chat.
7. [ ] 🔴 `/wa unlock` : glisser la boîte de A contre la boîte de B, presser Alt pendant le glissement (pas avant le
   clic), lâcher : A est ancrée à B. Alt tenu dès le clic : le comportement d'avant (pas de nouvel ancrage).
8. [ ] Redimensionner une aura avec Alt tenu : pas d'ancrage.

## 3 bis. Couleur des cadres en mode placement

Avoir un groupe avec deux auras, une aura ancrée à une autre (test 3), une aura seule.

1. [ ] 🔴 `/wa unlock` : quatre pastilles dans la barre, « Group », « In group », « Anchored », « Alone »
   (« Groupe », « Dans un groupe », « Ancrée », « Seule »). Survol : infobulle. Aucune erreur Lua.
2. [ ] 🔴 Clic sur « Group » : le sélecteur de couleur du jeu s'ouvre au-dessus de la barre. Choisir un rouge : le
   cadre de la boîte du groupe devient rouge pendant le choix, les autres boîtes ne changent pas.
3. [ ] Même chose pour les trois autres pastilles : chaque boîte prend la couleur de son rôle. Une aura ancrée dans
   un groupe prend la couleur « Anchored ».
4. [ ] Réduire l'opacité dans le sélecteur : le cadre devient transparent. « Annuler » : la couleur d'avant revient.
5. [ ] Clic droit sur une pastille : cadre par défaut.
6. [ ] Sélectionner une boîte colorée : le cadre de sélection garde la priorité. Le désélectionner : sa couleur revient.
7. [ ] « Save and quit », `/reload`, `/wa unlock` : couleurs gardées. Autre personnage : mêmes couleurs.
8. [ ] Mode Édition du jeu (Échap > Mode Édition) : les boîtes Musca ont les mêmes couleurs.
9. [ ] En design classique : mêmes pastilles, mêmes couleurs ; sans choix, boîtes sans cadre comme avant.
10. [ ] Rôle à couleur choisie : cadre de 2 px au lieu de 1, trait de 3 px de la couleur pleine à gauche du nom de
    chaque boîte, même avec l'opacité baissée. Clic droit sur la pastille : cadre de 1 px, trait retiré.

## 4. Design classique `/wa design`

1. [ ] 🔴 `/wa design` : ligne « Classic WeakAuras design chosen. Type /reload to apply it. » (« Design classique de
   WeakAuras choisi. Tapez /reload pour l'appliquer. »). Rien ne change avant `/reload`.
2. [ ] 🔴 `/reload`, `/wa` : même rendu qu'en 1.16. Cadre à portrait du jeu avec le logo WeakAuras, boutons
   et cases du jeu, recherche et onglets du jeu, barres de défilement du jeu, liste d'auras aux icônes du jeu. La case
   « Classic design » de la barre du haut est cochée.
   Vérifier aussi : la fenêtre se déplace par sa barre de titre ; réduire/agrandir marche ; glisser une aura dans un
   groupe montre le trait de dépôt ; `/wa unlock` montre les boîtes bleues ; le guide s'ouvre dans un cadre du jeu.
3. [ ] Parcourir les onglets Display, Trigger, Conditions, Custom Options, Load : texte lisible, aucune zone illisible.
4. [ ] Les auras à l'écran sont identiques à celles du design Musca.
5. [ ] Décocher « Classic design » : ligne « Musca design chosen. Type /reload to apply it. ». `/reload` : le design Musca
   revient.
6. [ ] Le réglage vaut pour tout le compte : se connecter avec un autre personnage, même design.
7. [ ] `/wa help` : ligne `/wa design`.
8. [ ] Rejouer les tests 1 à 3 en design classique : aucune erreur.

## 5. Non-régression

1. [ ] 🔴 Étape 2 de `SUIVI-BUGS-ET-TESTS.md` (combat de base) rejouée sur un mob : aucune erreur.
2. [ ] Aura importée de WeakAuras avec options custom : ses options s'affichent comme en 1.21.
3. [ ] `/wa unlock`, glisser une boîte avec Alt tenu dès le clic : même comportement qu'en 1.21.

## Résultat

- Date du test :
- Client et build (`/dump GetBuildInfo()`) :
- Classe et niveau :
- Design testé (Musca, classique, les deux) :
- Échecs (numéro, constat, erreur Lua) :

# Pack chaman (Forever) — notes de reprise

État au 2026-10-07 : premier jet importé et fonctionnel en jeu. Pas encore de retour aura par aura.

## Fichiers

- `PackChaman.lua` : générateur. Il renvoie la table d'export (groupe racine, deux groupes dynamiques, barre de mana, texte « MANA BAS »).
- `PackChaman.txt` : chaîne d'import `!WA:2!` actuelle.
- `VerificationPackChaman.lua` : scénario du banc. Il charge le pack et vérifie que les 5 auras « Aura (Modern) » passent la validation du moteur. Le banc n'émule pas `AuraContainer` : leur affichage se vérifie en jeu seulement.
- `../AuraTool.lua` : encodeur et décodeur de chaînes `!WA:2!`.

Commandes, depuis la racine du dépôt :

```
lua Tests/Packs/AuraTool.lua . encode Tests/Packs/Chaman/PackChaman.lua > Tests/Packs/Chaman/PackChaman.txt
lua Tests/run.lua --scenario Tests/Packs/Chaman/VerificationPackChaman.lua
lua Tests/Packs/AuraTool.lua . decode <fichier contenant une chaîne>
```

Le banc n'a pas de grimoire : les icônes de recharge n'y sont pas testables.

## Contenu du premier jet

- Rotation : Horion de flammes sur la cible (rouge sous 4 s), Horion de terre, Frappe-tempête, Chaîne d'éclairs, Nova de feu, Totem de glèbe, Rapidité de la nature, Totem de vague de mana, Idées claires, Rafale. Recharges suivies par nom (rang indifférent), icône désaturée en recharge, bleue si mana insuffisant, rouge hors de portée. Sorts de talent chargés seulement s'ils sont connus.
- Buffs : Bouclier de foudre (charges, rouge sous 60 s), enchantement d'arme, totems des 4 éléments, alertes « ! » hors combat si le bouclier ou l'enchantement manque.
- Mana : barre en pourcentage, texte « MANA BAS » sous 20 % par le seuil natif (courbe `UnitPowerPercent`, marche en combat).

Auras de buff et débuff (Bouclier de foudre actif et manquant, Horion de flammes sur la cible, Idées claires, Rafale) sur le trigger `secretAura` (« Aura (Modern) ») depuis le 2026-10-09 : `aura2` ne voit pas les auras secrètes en combat (tests en jeu : icônes disparues en combat, Horion de flammes jamais affiché). Le seuil de temps restant colore le texte `%p` (le moteur refuse la couleur de l'icône sur `faAuraRemaining`). Dans un groupe dynamique, ces auras gardent leur place même cachées.

Tests en jeu du 2026-10-09 : Lightning Shield = 324 confirmé. Après passage en `secretAura` : bouclier présent, manquant, maintenu en combat et reposé en combat OK ; Horion de flammes sur la cible OK. Rafale et Idées claires pas encore testées en jeu. Chaîne d'éclairs absente au niveau 17 (sort de niveau 32, chargée seulement si connue).

Les identifiants de sorts suivent `Classes/Shaman.md` (DB2 client 1.60.1.70245), pas encore vérifiés en jeu. Écarts avec Classic Era corrigés : Fire Nova Totem (1535) absent de Forever, remplacé par le sort Fire Nova (408341) ; Elemental Mastery (16166) absent du DB2, retiré ; Rafale suivie par les candidats d'aura 16257, 12966, 17687 au lieu des rangs Classic 16277-16280.

## Ce qui est possible sur Forever (matrice API vérifiée dans le source 1.60.1.70058)

- Lisible en combat (conditions possibles) : sort prêt (`isActive`, `isOnGCD`, `maxCharges`), `IsSpellUsable`, `IsUsableAction`, procs (`IsSpellOverlayed`, événements `SPELL_ACTIVATION_OVERLAY_GLOW_SHOW/HIDE`), portée, `GetRuneCooldown`, `UnitPowerType`, valeurs max sur `player`, spé, forme, monture, combat.
- Affichable seulement (widget, pas de comparaison en Lua) : puissance, vie, absorptions, durées de recharge et d'aura (objets Duration), charges courantes, cast ennemi.
- Seuils quand même possibles par le jeu : courbe en escalier (`Show only below (%)`, `Show at or above the value instead`), conditions alpha, couleur et désaturation sur valeur secrète, temps restant inférieur ou supérieur via l'objet Duration. Effets visuels seulement, un seul seuil par aura.
- Bloqué : journal de combat (`COMBAT_LOG_EVENT_UNFILTERED`, `CombatLogGetCurrentEventInfo`), stacks et champs d'aura secrets, sons ou actions selon un seuil.
- Non tranché par le source : types de puissance et sorts « jamais secrets ».

## Recherche à faire avant la v2

1. Ce que le jeu cache en combat pour le chaman : mana, un buff sur soi (Bouclier de foudre), un DoT sur la cible (Horion de flammes), une recharge (Horion de terre). Vérifier aussi qu'un buff posé pendant le combat apparaît tout de suite (bug signalé par le banc).
2. Identifiants : relevés hors jeu dans `Classes/Shaman.md`. Reste à confirmer en jeu l'ID des buffs et débuffs réellement posés (Bouclier de foudre, Horion de flammes, Rafale, Idées claires).
3. Style de jeu : spé et talents visés, tranche de niveau, solo, donjon ou raid. Pour chaque spé : les 5 à 8 sorts lancés, les procs qui changent une décision, les buffs à maintenir.
4. Référence visuelle : une ou deux captures d'un pack aimé (Fojji, Luxthos Classic, pack chaman Wago), avec ce qu'il faut garder (disposition, taille, ce qui disparaît hors combat).
5. Retour sur le premier jet : une ligne par aura (marche, jamais affichée, affichée à tort, inutile) et le texte exact des erreurs BugSack.

Le point 1 bloque le reste. Proposition en attente : préparer des commandes `/run` qui affichent en combat ce qui est secret ou lisible (API à faire vérifier par l'agent `wow-api` avant).

# Pack chaman (Musca) — notes de reprise

État au 2026-10-07 : premier jet importé et fonctionnel en jeu. Pas encore de retour aura par aura.

## Fichiers

Depuis le 2026-10-10, le pack est une table de données passée au générateur commun `../PackBuilder.lua`, comme les 8 autres classes. Le groupe racine s'appelle « Chaman (Musca) » au lieu de « Chaman (Forever) » : supprimer l'ancien groupe en jeu avant l'import.

Depuis le 2026-10-12, `PackBuilder.lua` dispose le HUD au gabarit Quazii : largeur commune de 334 px ; rappels, procs et effets au-dessus ; ressource fine ; rangée principale (grille de 8, 40x30) puis utilitaires (grille de 9, 34x26) ; entretien, totems, barres de cast, swing et règle des 5 s en dessous. À partir de la ressource, chaque rangée est ancrée au bas réel de la précédente : une 2e ligne (débordement au-delà de 8 sorts principaux connus, 2e barre de ressource du druide) pousse le reste. Les uid changent, car l'ordre de création des groupes a changé : supprimer le groupe « <Classe> (Musca) » en jeu avant de réimporter.

Toujours le 2026-10-12, l'uid de chaque aura est un hachage de son id : il ne dépend plus de l'ordre de création. Supprimer une dernière fois le groupe en jeu avant ce réimport. Ensuite, un réimport (bouton Class Pack ou page « HUD de classe » de l'assistant AeonUI) met le groupe à jour en place et garde la position, la taille et les options utilisateur.

- `PackChaman.lua` : données du pack (sorts, auras, rappels).
- `PackChaman.txt` : chaîne d'import `!WA:2!` actuelle.
- `../VerificationPack.lua` : scénario commun du banc. Il vérifie ids et uids uniques, parents, chargement de chaque aura pour la classe, et la validation moteur des auras « Aura (Modern) ». Le banc n'émule pas `AuraContainer` : leur affichage se vérifie en jeu seulement.
- `../AuraTool.lua` : encodeur et décodeur de chaînes `!WA:2!`.

Commandes, depuis la racine du dépôt :

```
PACK=Tests/Packs/Chaman/PackChaman.lua TEMP=$TMPDIR WOW_UI_SOURCE=$HOME/wow-ui-source/forever lua Tests/run.lua --scenario Tests/Packs/VerificationPack.lua
lua Tests/Packs/AuraTool.lua . encode Tests/Packs/Chaman/PackChaman.lua > Tests/Packs/Chaman/PackChaman.txt
lua Tests/Packs/AuraTool.lua . decode <fichier contenant une chaîne>
```

## Contenu actuel (refonte Quazii, 2026-10-14)

- Rotation : Lava Burst, Stormstrike, Lava Lash, Earth Shock, Chain Lightning, Frost Shock, Fire Nova, Molten Blast, Rage of the Farseer, soins (Healing Wave, Lesser Healing Wave, Chain Heal si Improved Healing Wave), Riptide, Healing Rain. Chaque sort se charge seulement s'il est connu.
- Cooldowns : Nature's Swiftness, Mana Tide Totem, Ancestral Guidance (ajout), Grounding, Earthbind, Stoneclaw, Totemic Projection, Decoy Totem, Purge, Reincarnation, Astral Recall.
- Buffs : Mana Tide actif, Clearcasting, Flurry, Earth Shield (cible), Ancestral Fortitude sur la cible (ajout, 16177, talent 16176), Water Walking (ajout, 546). Débuffs cible : Flame Shock (brille s'il manque en combat), Stormstrike (brille tant que le débuff est posé, ajout).
- Maelstrom Weapon en 5 segments, entretien Lightning Shield / Water Shield, 4 totems + buffs de totem, enchantements main/off, barre d'incantation, swing main + off, règle des 5 s.
- Rappels hors combat : Lightning Shield, Water Shield, enchantements main et off, Ankh, MANA BAS.

Écarts Quazii écartés : Power Surge, Tidal Waves, Two-Handed Mastery, Feral Spirits, Elemental Devastation 29177, Eye of the Storm 29063 (IDs absents de `Classes/Shaman.md`) ; Mental Dexterity (talent, IDs candidats seulement) ; Elemental Mastery (absent du DB2) ; Earth Shield en rappel de groupe (le générateur n'a pas d'unité de groupe) ; glow de Chain Lightning / Lava Burst à 5 Maelstrom (overlay consommateur, impossible) ; Lightning Bolt (aucun cooldown, ID Quazii suspect).

À confirmer en jeu : Ancestral Fortitude 16177 (Quazii utilise 16240, ID de rang du talent) ; Ancestral Guidance 409324 (cooldown par nom, rangs 409333 et 409337 non listés) ; Water Walking 546 en buff sur soi.

Les sections ci-dessous gardent l'historique du premier jet (30 auras à l'époque).

Le banc n'a pas de grimoire : les icônes de recharge n'y sont pas testables.

## Contenu du premier jet

- Rotation : Horion de flammes sur la cible (clignote en rouge sous 3 s), Horion de terre, Frappe-tempête, Chaîne d'éclairs, Nova de feu, Totem de glèbe, Rapidité de la nature, Totem de vague de mana, Idées claires, Rafale. Recharges suivies par nom (rang indifférent), icône désaturée en recharge, bleue si mana insuffisant, rouge hors de portée. Sorts de talent chargés seulement s'ils sont connus.
- Buffs : Bouclier de foudre (charges, clignote en rouge sous 60 s), enchantement d'arme, totems des 4 éléments, alertes « ! » hors combat si le bouclier ou l'enchantement manque.
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

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Barre de mana rouge sous 30 % par une condition sur le pourcentage secret, en combat aussi ; plus de copie rouge superposée (la variante ForeverAuras la garde).
- Rappels sans aura suivie (enchantements main et off, Ankh) : l'icône pulse, le texte clignote.
- Texte « Not in melee range » (Stormstrike 17364) : chargé en combat, caché à portée, affiché hors de portée (condition `spellInRange` sur l'alpha). Absent de la variante ForeverAuras.

## Pack 1.12.0 (2026-10-18), à tester en jeu
- Chargement par spécialisation (`forever_spec`) : Healing Wave, Lesser Healing Wave, Chain Heal et Healing Rain en Restauration, Lava Lash et Molten Blast en Amélioration. Sans point de talent, la spé se lit sur un sort signature : Riptide (Restauration), Rage of the Farseer (Amélioration) ; sans l'un ni l'autre, ces sorts ne se chargent pas. La variante ForeverAuras les charge dans toutes les spés.

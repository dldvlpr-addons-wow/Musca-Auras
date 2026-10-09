# Suivi des bugs et des tests : Musca Auras

Fichier interne unique (non publié, exclu par `.pkgmeta`). Il remplace `BUGS-A-TRAITER.txt` et `TESTS-EN-JEU.md`
(fusionnés le 2026-10-08) et ajoute les constats de l'audit `wow-api` du même jour.

1. Bugs à traiter : signalements reçus et tests KO, avec leur état.
2. Audit `wow-api` du 2026-10-08 : écarts entre le code et le source Blizzard de Forever 70245.
3. Tests en jeu : l'ordre des tests, ce qu'il faut voir, les résultats déjà notés.
4. Résultats reçus, puis le prompt à donner à Claude à la fin.

Pour chaque test, note **OK**, **KO** (avec le texte exact de l'erreur ou ce que tu vois) ou **non testé**.
Les tests marqués 🔴 sont bloquants : s'ils échouent, note-le et passe quand même aux suivants.

---

# 1. Bugs à traiter

### B1. Throw Weapon absent (non reproduit 2026-10-09 : Thrown présent dans Load, Item Type Equipped)
Signalement : « The Throw Weapon item type is missing in both the trigger type and in the "Load" conditionals. »

Constat dans le code : `WeakAuras/Types.lua:4484-4488` n'exclut pas le type 16 (Thrown) sur Forever, seul Glaives (9)
l'est. La liste vient de `C_Item.GetItemSubClassInfo(2, i)` (`Types.lua:4490-4494`) et sert au trigger
(`Prototypes.lua:9394-9397`) comme au chargement (`Prototypes.lua:2223-2229`), d'où l'absence aux deux endroits.
Cause probable, non vérifiée : `C_Item.GetItemSubClassInfo(2, 16)` renvoie nil sur Forever. Test : étape 12.1.

### B2. Masque : icônes géantes en jeu (corrigé 2026-10-09 selon le rapport, à tester : étape 12.6)
Signalement court : « using any masque skin, any WA you make looks normal when you have the options menu open and
making the aura, as soon as it triggers in game the icon is like gigantic ».

Rapport détaillé (ForeverAuras 0.70.3-BETA.1, Masque 12.1.1-Alpha), résumé :
- Symptôme : une icône skinnée par Masque est plus grande que la largeur et la hauteur de l'aura. Ça arrive dès qu'un
  nouveau bouton d'aura apparaît en combat, et après un relog pour toutes les icônes skinnées. Changer la taille dans
  les options corrige jusqu'au prochain nouveau bouton.
- Cause : Masque recalcule l'échelle du skin depuis `Frame:GetSize()` à chaque passe (`_mcfg:ForceUpdate()` puis
  `SetFrameSize()` sans argument, `Core/Core.lua` de Masque). Une taille donnée par `Group:SetFrameSize()` ne sert que
  si `GetSize()` est secret. Dans `SecretAuraAppearance.lua`, `SkinWithMasque` skinne la base depuis le callback
  `initializeFrame` du conteneur, avant que Blizzard pose le bouton à `elementWidth`/`elementHeight` et le restreigne.
  `GetSize()` renvoie alors la taille d'avant la mise en page. Masque la garde en cache, puis `GetSize()` devient
  secret et Masque ne la remet plus à jour. `RegionTypes/Icon.lua`, `UpdateSize`, a le même défaut pour les régions
  Icon dans une géométrie secrète.
- Correctif proposé : fixer la taille configurée dans la config Masque du bouton (`_MSQ_CFG.FrameWidth` et
  `FrameHeight`) et remplacer le `SetFrameSize` du bouton : sans argument (ForceUpdate de Masque), il garde la taille
  fixée ; avec arguments (`Group:SetFrameSize`), il la met à jour. Une fonction `Private.MasquePinSize(button, width,
  height)`, appelée dans `SkinWithMasque` avant `SetFrameSize`/`ReSkin`, et dans `Icon.lua`, `UpdateSize`, avant le
  `ReSkin` de `UpdateTexCoords`. Taille fixée : `Display.Dimensions(data)` (chemin natif), `region.width * |scalex|`
  (chemin Icon).
- Testé par l'auteur du rapport : la taille tient en entrant en combat avec de nouveaux buffs et après un relog.
- Note de l'auteur : le défaut est surtout chez Masque ; le correctif reste sans effet si Masque change.
- Vérifié dans Musca Auras (2026-10-08) : le rapport vise ForeverAuras, mais le même chemin existe ici sous d'autres
  noms. `SkinWithMasque` y correspond à `AttachToMasque` (`SecretAuraAppearance.lua:105-126`), appelée par
  `Display.StyleMasque` (`:128`). Elle passe `Display.Dimensions(data)` à `group:SetFrameSize` puis `ReSkin`, sans
  fixer la taille dans `_MSQ_CFG`. `Icon.lua`, `UpdateSize` (`:348`) puis `UpdateTexCoords` (`:361`) : même
  exposition. Le bug a donc toutes les chances de se produire aussi dans Musca Auras.
- Test : étape 12.6.

Texte d'origine du rapport détaillé :

```text
Version: ForeverAuras 0.70.3-BETA.1, Masque 12.1.1-Alpha

Symptom
Icons with a Masque skin applied are drawn larger than the aura's configured width/height. It happens as soon as a fresh aura button appears in combat, and after a relog for every skinned icon. Changing the width/height in the options "fixes" it until the next fresh button.

Cause
Masque computes its skin scale from Frame:GetSize() at the start of every skin pass (_mcfg:ForceUpdate() -> SetFrameSize() with no arguments in Core/Core.lua). A size supplied via Group:SetFrameSize() is kept only as a fallback for when GetSize() returns a secret — if the size is readable, Masque overwrites the supplied value with whatever it measures.

In SecretAuraAppearance.lua -> SkinWithMasque, the shared base is skinned from the container's initializeFrame callback, i.e. before Blizzard has laid the button out to elementWidth/elementHeight and before it restricts the frame. GetSize() is still readable at that moment and returns the pre-layout size, so Masque caches that and scales the Icon/Cooldown regions to it. Once the button is restricted, GetSize() is secret and Masque keeps using the stale cached size. Re-styling an already laid-out button (e.g. editing the size in options) reads the correct size, which is why that appears to fix it temporarily.

RegionTypes/Icon.lua -> UpdateSize has the same exposure for ordinary Icon regions inside secret geometry.

Fix (patch attached)
Pin the configured size on the button's Masque config so Masque never re-derives it from GetSize(): set _MSQ_CFG.FrameWidth/FrameHeight and replace the per-button SetFrameSize so a no-argument call (Masque's ForceUpdate) keeps the pinned size, while an explicit call (Group:SetFrameSize) still updates it. One helper, Private.MasquePinSize(button, width, height), called from:

    SecretAuraAppearance.lua SkinWithMasque — before SetFrameSize/ReSkin
    RegionTypes/Icon.lua UpdateSize — before the ReSkin in UpdateTexCoords

The pinned size is Display.Dimensions(data) (native path) / region.width * |scalex| (Icon path) — the same values already passed to Masque, so intended sizing is unchanged.

Tested: icons hold their configured size through entering combat with fresh buffs and through a relog.

Note: The root issue is arguably Masque's — SetFrameSize() without arguments shouldn't overwrite an explicitly supplied size. The pin works with the current Masque API and would be harmless if Masque changes that later.
```

### B3. Tests KO notés à l'étape 5 (à confirmer)
Code relu le 2026-10-09 contre l'API Forever 70291 : Durability et Tracking collent à l'API, aucune cause trouvée. Instance Type : ids Forever 242, 243, 233, 250 sans nom dans `Types.lua`. Corrections suspendues aux `/dump` de l'étape 12.7.
- **Equipment Durability** : ok 2026-10-09 (overall 17, lowest 0, broken 1 ; aura du slot 6 ok), aucun correctif.
- **Tracking** : ok 2026-10-09 (Find Herbs 2383 et Inverse), aucun correctif.
- **Load, Instance Type** : ok 2026-10-09 (Gouffre de Ragefeu, difficulté 1 : Dungeon (Normal) chargé dedans, None dehors), aucun correctif.
- À trancher : `CHANGES.md` (2026-10-04) dit Equipment Durability et Tracking « Tested in game on WoW Forever 70124 ».
  Refaire ces tests pour savoir lequel est à jour, puis corriger `CHANGES.md` ou le code.

### B4. Étape 8 marquée « bug » sans détail
Le titre de l'étape 8 portait « bug » sans précision. Noter le test concerné et ce qui a été vu.

---

# 2. Audit `wow-api` du 2026-10-08

Source : mémoire de l'agent `wow-api` (clone Blizzard Forever 1.60.1.70245, live 12.1.0.69933). Tous les TOC
sont en Interface 16001 : seul Forever est concerné. Aucun bug bloquant.

### Important (prouvé dans le source)
- **A1. Absorbs masqués sur Forever.** `Prototypes.lua:3361-3367` (événements `UNIT_ABSORB_AMOUNT_CHANGED`,
  `UNIT_HEAL_ABSORB_AMOUNT_CHANGED`) et `Prototypes.lua:3578-3592` (champs `absorb`, `healabsorb`) sont réservés à
  `IsMistsOrRetail()`. Or `UnitGetTotalAbsorbs` et `UnitGetTotalHealAbsorbs` existent sur Forever
  (`UnitDocumentation.lua:1286` et `:1302`, événements `:4090` et `:4297`). Comportement en jeu non prouvé : étape 12.2.

### Risques (information non vérifiée, à tester en jeu)
- **A2. Cooldown des icônes sans `pcall`.** `RegionTypes/Icon.lua:454-455`, `:686-688`, `:715` appellent `SetCooldown`
  et `SetCooldownFromDurationObject`, marquées protégées dans le source Forever. `SecretAuraSingle.lua:1196` et `:1201`
  utilisent `pcall`. Le test 2.1 (icône de cooldown en combat) est OK : pas d'erreur vue sur ce chemin.
- **A3. Valeurs pouvant être secrètes, lues sans garde.** Rôle (`UnitGroupRolesAssigned`) : `BuffTrigger2.lua:1463`
  (clé de table) et `:1588`, `GenericTrigger.lua:4080` et `:4090`, `WeakAuras.lua:1753`. Portée (`UnitInRange`) :
  `BuffTrigger2.lua:189-190`. Spécialisation d'arène (`GetArenaOpponentSpec`) : `BuffTrigger2.lua:1481`. Modèle déjà
  protégé : `ClassicEraTriggers.lua:373`. Test : étape 12.3.
- **A4. Sortie de combat sans nouvel essai différé.** `SecretRestrictions.lua:87-100` relance la mise à jour sur
  `PLAYER_REGEN_ENABLED` sans relecture différée. Selon des sources web, le secret se lève 0,3 à 1 s après la fin du
  combat. Sans `ADDON_RESTRICTION_STATE_CHANGED` ensuite, les auras ne seraient pas relues. Test : étape 12.4.
- **A5. `C_Item.IsItemInRange` sans `pcall`.** `GenericTrigger.lua:5212`. Des sources web la disent protégée en
  combat. `IsSpellInRange` est sous `pcall` (`Prototypes.lua:35`). Test : étape 12.5.
- **A6. Enchantement d'arme.** Les champs de `GetWeaponEnchantInfo` ne passent pas par `IsSecret`
  (`GenericTrigger.lua:4521-4525`). Unité de `timeLeft` non documentée (le code la traite en millisecondes). Le test
  de l'étape 3 (enchantement temporaire) est OK.
- **A7. `WA_GetUnitAura` (code des utilisateurs).** `AuraEnvironment.lua:28-39` : aucun test de secret ; un résultat
  vide en combat ne prouve pas que l'aura est absente.
- **A8. `IsAuraFilteredOutByInstanceID`.** `BuffTriggerNativeFilter.lua:32-34` compare le résultat hors du `pcall`.
  Qu'il ne soit pas secret est une supposition. Réponse attendue de la commande 1.14.

### Pistes (API disponibles, non utilisées)
- `PLAYER_PVP_FLAG_CHANGED` (Forever) : le chargement sur le flag PvP ne se rafraîchit que via `UNIT_FLAGS`
  (`WeakAuras.lua:1987`).
- `UnitUsesAmmo`, `C_Spell.GetItemCooldown` : présents seulement en 70245, tester leur existence avant l'appel.
- `C_Secrets.CanCompareUnitTokens` : utile pour `Private.UnitIsUnit` (`SecretRestrictions.lua:20-33`).

### Conforme
`C_Secrets`, objets `Duration`, `SetTimerDuration`, `GetAuraDuration`, `GetAuraApplicationDisplayCount`, options des
conteneurs d'auras et des textures de dissipation, `C_SwingTimer`, `IsSpellKnown`, `AddAuraSound`, filtre
`IMPORTANT`, `GetTotemDuration`, `C_LossOfControl`, détection de saveur (par le TOC).

### Non couvert
Reste de `Prototypes.lua` pour les rôles ; `WeakAurasOptions/` (grep seulement). Deux écarts sans effet tant qu'il n'y
a pas de TOC retail : `RemoveDispelTypeTexture` (`SecretAuraConditions.lua:1032`), `SetAuraGroupEnabled` sans garde.

---

# 3. Tests en jeu

---

## Étape 0 : préparation (5 min)

- [ ] Installer **BugGrabber + BugSack** : ils gardent le texte complet des erreurs, mieux que la fenêtre de base.
- [ ] Désactiver ForeverAuras (les deux addons ne doivent pas tourner ensemble).
- [ ] En jeu : `/console scriptErrors 1`, puis `/reload`.
- [ ] `/wa` ouvre les options, sans erreur.
- [ ] `/wa tutorial` ouvre le tutoriel, et les deux boutons d'import marchent.

Pour copier une erreur : ouvre BugSack, copie la première ligne et les 5 lignes de pile qui suivent.

---

## Étape 1 : vérifications du client (2 min, à coller telles quelles)

Tape chaque commande et note le résultat affiché.

| # | Commande | Résultat attendu | Résultat noté |
|---|---|---|---|
| 1.1 | `/dump select(4, GetBuildInfo())` | un nombre inférieur à 20000 (16001) | OK : 16001 |
| 1.2 | `/dump WOW_PROJECT_ID, WOW_PROJECT_MAINLINE` | noter les deux valeurs | 1, 1 (voir note) |
| 1.3 | `/dump C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()` | un numéro de spé, ou nil | OK : 1 |
| 1.4 | `/dump C_Secrets ~= nil, issecretvalue ~= nil` | `true, true` | OK : true, true |
| 1.5 | `/dump C_CooldownViewer ~= nil` | `true` | OK : true |
| 1.6 | `/dump GetInventoryItemDurability(1)` | deux nombres (si casque équipé) | OK (2026-10-09) |
| 1.7 | `/dump C_Minimap.GetNumTrackingTypes()` | un nombre ≥ 1 | OK : 23 |
| 1.8 | `/dump GetInstanceInfo()` dans un donjon | noter le 3ᵉ nombre (ID de difficulté) | fait hors donjon (Kalimdor, 0) : à refaire en donjon |
| 1.9 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureAvailable()` | noter (décide la phase E) | false (hors combat de boss) |
| 1.10 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureEnabled()` | noter | false (hors combat de boss) |
| 1.11 | `/dump C_Texture.GetAtlasInfo("RaidFrame-Icon-DebuffMagic") ~= nil` | `true` | OK : true |
| 1.12 | `/run local f=CreateFrame("Frame") print(pcall(f.RegisterEvent,f,"COMBAT_LOG_EVENT_UNFILTERED"))` | noter : `true` = journal de combat utilisable, `false` + erreur = interdit | interdit (2026-10-09) : `true false` + `ADDON_ACTION_FORBIDDEN` (ForceTaint_Strong, `UNKNOWN()`) |
| 1.13 | `/dump C_CombatLog.IsCombatLogRestricted(), CombatLogGetCurrentEventInfo ~= nil` | `true false` (2026-10-09) : journal restreint, `CombatLogGetCurrentEventInfo` absent |
| 1.14 | **en combat**, avec un buff sur toi : `/run local a=C_UnitAuras.GetAuraDataByIndex("player",1,"HELPFUL") print(a and issecretvalue(C_UnitAuras.IsAuraFilteredOutByInstanceID("player",a.auraInstanceID,"RAID")))` | noter : `false` = on peut reconnaître un buff secret par ses filtres, `true` = non | erreur (2026-10-09) : « GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by '*** ForceTaint_Strong ***' ». Non mesurable par `/run` en combat (A8) |

Notes :
- Tape la commande seule, sans le texte de la colonne « Résultat attendu » : coller `` ` | `true, true` `` à la suite
  donne l'erreur `` '<eof>' expected near '`' ``.
- 1.2 : `WOW_PROJECT_ID` = 1 sur le client testé (70124). D'après le source 70245, `WOW_PROJECT_ID` vaut
  `WOW_PROJECT_CAMELOT` (18) sur les builds récents. Sans effet sur l'addon : la saveur vient du TOC (`Init.lua:389-398`).
- 1.9 et 1.10 : false hors combat de boss. Refaire pendant un boss (étape 10) avant de fermer la phase E.

---

## Étape 2 : 🔴 le combat de base (15 min, sur n'importe quel mob)

### 2.1 Icône de cooldown en combat
- [ok ] Crée une aura Icon, trigger **Cooldown** sur un de tes sorts (ID exact).
- [ ok] Hors combat : lance le sort, le cadran tourne et le chiffre descend.
- [ ok] En combat : pareil, sans erreur. **Risque n°1** : si une erreur parle de `SetCooldown` ou de fonction protégée, note-la en entier.

### 2.2 Buff posé en combat
- [ ok] Aura Icon, trigger **Aura**, sur toi, un buff que tu te poses (spell ID exact).
- [ok 2026-10-09] Ajoute un texte `%p` et un texte `%s`.
- [ok 2026-10-09] Hors combat : icône, durée qui descend, stacks.
- [ok, corrigé] Pose le buff **en combat** : l'icône apparaît, `%p` descend, `%s` montre les stacks. Relance en combat de ton propre buff : minuteur remis à zéro (option B). Stacks figés en combat : limite du moteur, notée dans TUTORIAL.md.
- [ok] À la fin du combat, l'aura reste juste (pas de doublon, pas de figé).

### 2.3 Barre de vie et de mana en combat
- [ok] Aura Progress Bar, trigger **Health** sur `target`, puis une autre **Power** sur `player`.
- [ok, corrigé : UNIT_HEALTH, texte %p / %t natif] En combat, les deux barres bougent.
- [ok 2026-09-30, natif] Même chose en **Progress Texture** : Left to Right sur Health `target`, Clockwise sur Power `player`, les deux bougent en combat.
- [ok 2026-09-30, natif] Aura **Text** `%percenthealth% (%health / %maxhealth)` sur `target` : les chiffres changent en combat.
- [ok 2026-09-30, natif] Aura **Progress Bar**, trigger **Cast** sur `target` : la barre apparaît et avance quand le mob incante en combat.
- [corrigé 2026-10-09 (doc) : TUTORIAL.md:54 corrigé, cible non joueur = « Show only below (%) ». ko 2026-10-09 : la barre ne passe jamais au rouge. `/dump issecretvalue(UnitHealth("target"))` = true hors combat : PV de la cible secrets même hors combat, condition numérique ignorée (`Conditions.lua:323`). TUTORIAL.md:54 à corriger pour la cible. Contournement natif « Show only below (%) » 50 sur Health `target` : ok 2026-10-09, la barre s'affiche] Ajoute une condition « Health < 50 % » : elle garde son dernier état en combat (attendu), et se remet à jour à la fin.

### 2.4 Global Cooldown
- [ok 2026-10-09] Trigger **Global Cooldown** : il s'affiche à chaque sort, en combat aussi.
- [ok 2026-10-09, pack chaman] `/wa pstart`, 20 s de combat, `/wa pstop`, `/wa pprint` : 117 ms dans WA sur 19,7 s (0,59 %). Auras : Bouclier de foudre 138,83 ms, Chaman - Mana 85,56 ms, Horion de terre 39,09 ms. Systèmes : frame tick 317,59 ms, dynamic conditions 67,67 ms, UNIT_POWER_FREQUENT 25,39 ms. Anomalie : « generictrigger cd tracking ERROR: count is not zero: 6 ».

---

## Étape 3 : armes, munitions, enchantements (10 min)

- [ok ] **Swing Timer, main hand** : la barre repart à chaque coup.
- [non testé, écarté par l'utilisateur 2026-10-09] **Off hand** (si deux armes) : barre séparée, juste après un buff de vitesse d'attaque.
- [ok 2026-10-09, chasseur] **Ranged / baguette** : la barre suit le tir automatique.
- [ok 2026-10-09 après correctif : Out of Range loin sans coup, In Range au contact avant le premier coup, In Range + Inverse au contact sans coup seulement. Filtre de portée actif sans coup en cours (`Prototypes.lua`). ko 2026-10-09, chasseur : « MÊLÉE » et sans cible OK, « LOIN » (Out of Range) jamais affiché. API OK (`IsTargetWithinSwingRange` true collé, false loin). Cause confirmée : le trigger exige un coup en cours (`duration > 0`, `Prototypes.lua:7029`), aucun coup de loin. Avec Inverse + Out of Range : loin affiché, collé caché, sans cible caché, ok. À trancher : filtre de portée sans coup en cours, ou doc « Inverse pour hors portée »] **Swing Timer, Target In Range** : réglé sur In Range, l'aura s'affiche au corps à corps ; sur Out of Range, loin de la cible ; sans cible, ni l'un ni l'autre.
- [ok 2026-10-09, chasseur : Count, Total Carried, filtre Ammo Item] **Ammo** (chasseur, guerrier, voleur) : Count = munitions équipées, Total Carried = toutes les munitions des sacs ; le filtre d'objet Ammo Item ne montre l'aura qu'avec la munition choisie.
- [ok ] **Enchantement temporaire** (poison, pierre à aiguiser, huile) : sur les deux armes, les deux s'affichent avec leur durée.

---

## Étape 4 : dissipation (10 min, un mob ou un joueur qui pose des débuffs)

Reporté le 2026-10-09 : pas de source de débuffs disponible pour le moment.

- [ ] Bordure avec **Color by Dispel Type** sur une aura de débuff : magie bleue, malédiction violette, poison verte, maladie marron.
- [ ] Même test **en combat** : les couleurs restent justes. Si une couleur est fausse, note le type et la couleur vue (les ID de type sont supposés).
- [ ] Sous-élément **Dispel Type Icon** : hors combat, l'icône Blizzard du type ; en combat, un rond de la couleur du type.
- [ ] Une condition qui change la couleur de la bordure gagne toujours sur la couleur de dissipation.

---

## Étape 5 : nouveaux triggers et options (15 min)

- [ok] **Bag Space** : ramasse un objet, Free Slots baisse ; Include Specialty Bags compte le carquois.
- [ok 2026-10-09] **Equipment Durability** : meurs une fois, Lowest et Overall baissent ; un seul slot fonctionne.
- [ok, corrigé] **Role** : en groupe, choisis un rôle dans la recherche de groupe, l'aura suit.
- [ok 2026-10-09] **Tracking** : Find Herbs par son ID de sort, l'aura suit l'activation ; Inverse fait l'inverse.
- [ok 2026-10-09] **Load, Instance Type** : dans un donjon, la liste des difficultés est remplie et le filtre marche.
- [ok 2026-10-09, chaman] **Conditions, Secret Restrictions Active** : vrai en combat, faux après.
- [ ok] **Cooldown, condition On Global Cooldown** (avec Show Global Cooldown) + Hide Cooldown Text : le chiffre disparaît pendant le GCD seulement.
- [ ok] **Aura, Elapsed Time ≥ 5** : l'aura s'affiche 5 s après la pose du buff.
- [ok 2026-10-09 après correctif : WeakAuras `9:59`, Old `9m`, Modern `9m 59s` (groupe « Test %p Old Modern », Bouclier de foudre). Règles Old / Modern ajoutées au formatter natif (`DurationText.lua`). ko 2026-10-09, chaman, Bouclier de foudre en secretAura : les 3 formats (WeakAuras, Old, Modern) donnent le même affichage `9:59`. Formatter natif `SubTextNative.lua:8-29` mis hors de cause : `/run` hors combat, `CreateSecondsFormatter` puis `Format(599)` donne « 9 Minutes 59 Seconds » par défaut, « 9 m » avec SetDesiredUnitCount(1) + OneLetter, « 9 m 59 s » avec 2, pcall true. Le texte `9:59` ne vient donc pas de ce formatter : le binding n'est pas utilisé ou ignore SetFormatter. À corriger après les tests] **Texte `%p`** : format Old / Modern et Increase Precision Below suivent les réglages, en combat aussi.

---

## Étape 6 : Cooldown Manager (5 min)

- [ ok] `/wa cdm` hors combat : le Cooldown Manager de Blizzard s'affiche / se cache. En combat : message de refus.
- [ok ] Après `/wa cdm`, aucune erreur « action bloquée » (taint) en combat.
- [ok] Trigger Cooldown : la liste **From the Cooldown Manager** est remplie et règle le sort.
- [ok ] Trigger Aura (Exact Spell ID coché) : la liste **From the Cooldown Manager** ajoute les ID d'un buff suivi.

### 6.5 Lien Cooldown Manager ↔ aura en combat (décide si on reconnaît un buff secret par son sort)

But : savoir si un addon peut lire, en combat, quel buff le Cooldown Manager affiche. Si oui, on pourra reconnaître
par son ID de sort un buff posé en combat dont les données sont secrètes (comme le fait ForeverAuras).

1. [ok 2026-10-09, chaman, Bouclier de foudre suivi] Hors combat : `/wa cdm` pour afficher le Cooldown Manager. Dans ses réglages (Edit Mode > Cooldown Manager),
   mets 2 ou 3 de tes buffs dans **Tracked Buffs**, dont un qui apparaît en combat (proc, bijou, talent).
2. [ok 2026-10-09 : 6 lignes ; Bouclier de foudre = `200311 15 324` (entrée, instance, sort lisibles) ; 5 autres entrées `nil nil`] Hors combat, buff actif, colle cette commande (une seule ligne) :
   ```
   /run local S=issecretvalue for _,v in ipairs({BuffIconCooldownViewer,BuffBarCooldownViewer})do for _,f in ipairs(v:GetItemFrames())do local c,a,s=f.cooldownID,f.auraInstanceID,f.auraSpellID if c then print(c,S(a)and"S"or a,S(s)and"S"or s)end end end
   ```
   Note ce qui s'affiche : une ligne par buff suivi (ID d'entrée, ID d'instance, ID de sort ; S = secret).
3. [fait 2026-10-09 : buff gardé depuis le hors combat, `200311 15 324` lisible. Bouclier reposé en combat : `200311 S S`, ID d'entrée lisible, ID d'instance et ID de sort secrets. Conclusion : l'ID d'instance ne sert pas ; l'ID d'entrée Cooldown Manager reste lisible et identifie le buff suivi] **En combat**, avec le buff posé pendant le combat, recolle la même commande. Note les lignes.
4. [interdit 2026-10-09 : « GetUnitAuraInstanceIDs(): Auras cannot be accessed when secret while tainted by '*** ForceTaint_Strong ***' », non mesurable par `/run`] Toujours en combat, colle :
   ```
   /run local t=C_UnitAuras.GetUnitAuraInstanceIDs("player","HELPFUL") print(#t) for _,i in ipairs(t) do print(i, C_Secrets and C_Secrets.ShouldUnitAuraInstanceBeSecret and C_Secrets.ShouldUnitAuraInstanceBeSecret("player", i)) end
   ```
   Résultat déjà noté (combat non précisé) : 3 auras, ID 25, 3 et 1, toutes `false`.
   Note si l'ID d'instance vu à l'étape 3 apparaît ici, et si sa ligne dit `true` (aura secrète).

Résultat utile : à l'étape 3, l'ID d'entrée est un nombre et l'ID d'instance est un nombre (pas `SECRET`), présent à
l'étape 4. Si la commande 2 ou 3 affiche une erreur, copie-la en entier.

---

## Étape 7 : 🔴 filtres natifs et auras secrètes (10 min)

Passée le 2026-10-09 : pas de contrôle disponible (chaman niveau 16). Aura de test prête (groupe « Test 7 Filtres natifs »). Reste bloquante pour la release.

- [ ] Trigger Aura sur `target`, Debuff, **Native Filter** seul, Is = Crowd Control.
- [ ] Hors combat : un contrôle posé s'affiche, avec son nom.
- [ ] En combat : un contrôle posé s'affiche sans nom, avec icône, durée et stacks dessinés par le jeu.
- [ ] Même aura avec **Clones** et deux contrôles : pas d'erreur, deux icônes.
- [ ] Is = Cast by Me or my Pet : seulement tes débuffs.
- [ ] Une aura sans filtre natif se comporte exactement comme avant.

---

## Étape 8 : groupe, glow, divers (10 min) (marquée « bug », voir B4)

- [ok 2026-10-09, Pixel, Autocast, Bouton, Proc] Action **Glow** (Pixel, Autocast, Proc) sur une icône : le glow est visible et bien dessiné.
- [non testé 2026-10-09, pas de groupe] Trigger Aura en mode groupe (party) : les membres sont trouvés, pas d'erreur de GUID en combat.
- [ok 2026-10-09] L'unité Multi-target n'est plus proposée dans le trigger Aura.
- [ok 2026-10-09] Un trigger Combat Log affiche l'avertissement « combat log fermé ».
- [ok 2026-10-09 : condition spellInRange sur Horion de terre, condition range ≤ 10 sur Range Check target] Portée : une aura avec condition de portée sur la cible change bien en s'éloignant.

---

## Étape 9 : import ForeverAuras (10 min)

Validée avant le 2026-10-09 selon l'utilisateur. Aucune trace écrite des résultats (texte du chat, auras qui diffèrent).

- [ ] Dans ForeverAuras (réactivé seul), exporte 3 ou 4 auras variées : Cooldown Manager, Aura (Blizzard), Swing, Ammo, Bag Space, bordure ou icône de dispel.
- [ ] Désactive ForeverAuras, réactive Musca Auras, importe les chaînes.
- [ ] Le chat affiche « Converted from ForeverAuras. » et la liste de ce qui n'est pas converti.
- [ ] Chaque aura importée marche comme dans ForeverAuras. Note celles qui diffèrent.

---

## Étape 10 : donjon ou raid (si possible, 30 min)

Reportée le 2026-10-09 : pas de donjon ni de raid accessible (chaman niveau 16).

- [ ] Un vrai combat de boss avec 5 à 10 auras chargées : pas d'erreur, pas de chute de FPS.
- [ ] `/wa pstart encounter`, fais le boss, `/wa pprint` : note les 3 lignes les plus chères.
- [ ] Refais les commandes 1.9 et 1.10 pendant le combat.

---

## Étape 11 : tests du 2026-10-05 (chaman 16, 30 min)

Exports à importer avec `/wa` > Import. Relance le jeu avant (nouveaux fichiers). Garde BugSack ouvert.

### 11.1 Lot 2 BuffTrigger2 (code déplacé, même comportement attendu)
1. [ok 2026-10-09, couvert par l'étape 2 (buff sur soi hors combat, en combat, relance)] **Lightning Shield sur toi** : l'icône apparaît avec la durée et les charges. Relance avant la fin : la durée repart à zéro.
   Export « Lot2 A: Lightning Shield player » :
   ```
   !WA:2!DnvZoTTtqCqTsizPIu9bouHudrcU0cTkPLdi1pIPofQcXiBdxtw7DS9wS31S76abPEHt9CEeY5EIl9EEcwLhH(iKNGURnv)L(7dZoFS78BMFZ417BxyJTX)C75KygnGvXJHTxBjQsMX4ELscJkSMJbbswXrsiJp1ljras8MZ5qQoC40sWX8y)ywoJ)TNO)CUJXkw)(yglhZUHo2)gcwMD9I)5WfNQZekUo9h6lKiU0kkHqjImlh9H06EjNKMcCXM7XFunXrQXYhPlKoZmskQaeVOt3oVJxjGHARXllqY4mqeKXUXJUquF0td0eq3frvjjM6LFI7GZ7FXaNknurL5OPaFwf9rCSkFoQ(fHn2NXWWVwZjNHWxotd0O4CKqmosIYbQCl)IQCjXYV27ErccnnhIcoP3z9gQAB5ikH4TQvi3bgLveQe4uu(L62tZa)E1vau2ZCpPpsZjzZqusHrJEO6z9xInuV2yKP)5cqt2yHY2HYOWcajGajhOPYSnU3yz6q1(oficTV6vQxRSv7Royd1B0hB()90MGlF5aMStREh1Aajnts1nqRGmcKJB1qnpGOX61HZz6cp6y3HHU(ZeqEsTdv3vnH7Z1dad2rbh776oKFBZMY0ovempzIbKECcDIPfYMlQI8RxGehTLYEP2mcfFvkNvrXtu2CTdjCRCMrmYiAVB5IAJjebjkhgVOb3rLMYyXPdh66pYXlm07SL13lHrLbAoFNMN99kHKKmv19)IwVl4Dr4Gth6QXu9b1hBVRq9PXQp)NM8f6DU)PF9KqLZoQJvDvFr5gLbgA665MXaP5pKhi0egVzKzfPdKqsTSfrV)GoDo4T2tE6p(7
   ```
2. [ko 2026-10-09 : rien ne s'affiche (trigger aura2). Même constat que le pack chaman avant passage en secretAura] **Flame Shock sur la cible** : l'icône apparaît. Relance sur le même mob : la durée repart. Change de cible : l'icône disparaît.
   Export « Lot2 B: Flame Shock target » :
   ```
   !WA:2!DnvZoTnqqyqfjKSurQ(ahqCiej4sluuqGQqQ)etDkursqogUMS2ES9wS31S76abPEHt9CEeY5EIl9EEcwLhH(iWtqN1MQkvFy35BMDMVz)2Xl3Xo3oYo6hBoJgYzd4LIqyZLwqkvPCr)cfLZKwZIajrvkikivmPFCSeuRyntajyy)jfGJjzVqEgx81xGFo3Z55l)qiNNfXVLnY7wAKk9M5)1HBucwjsyv5pYtQicLvqmLrLPwo4MY6bLGMKac5A7iE2m2rHC5rWgP1uZkJKdYnCE3(hUVOuc9q4Of5evykihKYVTpBUSARnY0yaVgbLXXMgwCABVUDU8CNsKRaK(eqnTK9mrwfVIuLHFnUlpc(5sozCs0vtrIggMrKYryEzatTUxEzMIA5v5DNajLLKbbdoTD3290nTCKfq46vg07bJXtuMcems2v49dLGF901au02CoLhbfL0Pegn3yXos)YolImApcgAeaHeq1osQTDyCgmhisyGsaSev6QpyqMBOExNCcL1r)A9B026D17TQ(T42A)VNM0OInoNRA1W54gDYqnSbQDHx3OwvEKWcXrHl4yphCIBpFxVPsilUYH(GNQd3rG5zOnyWjEUU9e3vpLmPvjnsep2uFhbLn209PZKLbEvdpYJxxBVaHbKWRte8sw0yTTaDOG7utnldnln3UyEfymvsdYGrZR5DyHPnMFwVEUEdD6773V7IQZfZzQbOCVvDAFRuQOXt0h8VOvJb9V0)8Z65ICQFV(dn3wQ)4i9N(DD987FH3zF5uFTZw6t0hO)S2nifOjPQBMzEbO1)D8iLfZf1VwwbyGyAILTm4W9A1AV9ThVY3)Zp
   ```
3. [ko 2026-10-09 : rien ne s'affiche, comme le test 2] **Flame Shock, filtre natif Cast by Me** : comme le test 2, seul ton Flame Shock compte. Si rien ne s'affiche alors que le test 2 marche, note-le.
   Export « Lot2 C: Flame Shock target native PLAYER » :
   ```
   !WA:2!Dn1ZQTntq8eAHacAGAd(qPhCdKqpL6AiMsovjJuC(WwoiReONSwjTsABK3vz3voXb6LCO0Z(rWN7PaLE3pbl(rOpc(j4BwPuAP6WUZF2zMFZVz0UonM1iUr83E9kseJoHvYJWVENnOszgJpUqsyuHXQySajl5ijoJVyCsIal)Xkoof86VOaBPJ1lILZ4)3ZGpR7zSz7(qeJLhZULg4DljwMDZ6FBWoofsekQk798esexAeMqOerMHfCjnEqYjPPyUy)J4pj(1TLcSlssMJDi5smpWscf3dbaRlVY3mCWsTkfKeVY6dDoPZA6FfrRWlgA(jBVGnZqYOmSysg72X01IQlZi9lHMnSmjr3x8bMEJCUCOvjaPqaLPy5Ys6t4XO4LOQi8R1hXIXFFhRCgk(QLaCMgLJeIaiUCmv2YBwzUKy4vz9OqbHMMJdNmWCKPR6qdlrboQvLa5ESwylHcqMIYVcObGP(52RX4ct97KEqtXYwIOKzAjAp1lC2eRNqGYunTWfyyOelunTOmkEngjWtKCmnvMT3dAnDhQ6yndrOoQJvVt1u1r9(9uDHR9)xlhqIlE7qMSB7(N22jh432a3fDD7AwPDnl3UMEFerJG1Nlyqhe232132BPaNNuzq1BBTBhoKfnicN03Z22LFx9M1IULKyEYCD16Zj056EjBLOm0RAJtCAlvZnGAik66uoRKgpx1KdgK47Kl1ht1hhCyX6kL5ebjmhhSUUUtl0Wy95UU2EtTg77pE0MQ3LWOYja5)M6W(CPqsswO69hVvlfJV0F45U2qnvFuzEWHcLvGQ)VQZN)4l8o)Sb(k73OCu9uNPgeMHjPzYBwPNhK6)OEKqty86zNri4iHKA0qeEYXD7ECNgZF(x()d
   ```

### 11.2 Barre de progression dans un Modern Aura Group
4. [ok 2026-10-09] Le groupe s'affiche avec la barre Lightning Shield (temps à droite) et l'icône Flame Shock à côté. Plus de message « use an Icon display ». En combat aussi.
   Export « Fix 1: Modern Aura Group with bar » :
   ```
   !WA:2!Ls5ZpTXruCCCjPu2wf14KqXuizdQH2qBPGtaLsvtLxQnqLXGwBSQ6f7z3D8Utz9mBMzwZpK6fupWz)NGpNtCj39FbpXFk8xqFZA3gAupePAjVEEJN5nV33VF2jxZ8(lFXdhW8f86IuPpD(j8siskxN84kStSxBt79ebuj3UuQKyVTuKMyFmthz7rKxrs1rc5(jAMGRSCmzPDFfnUZbcgx7Tv5Ank7kpD)oDuuDUbsAiUWgNMqLemByg8IOSWi9tLA6j6uj9CNy2zNrKb9n5QLIfqDQwUsJR9i(hfIhopylrSq(l5YL7GjxDL1DpMfOJ(Zprs8ZkInCvAIuB51HXzQiSM4mT15AjlmKkv3zj54HntEGI6lP6dvuxc)O6j044D)zvBhnwFdg9FMEo5tn16nxYCfFwXNpiG6L2PtwZSt5Qhu5WQoP4z5LetoLk7NYhFqwj31uB9OngfBKZxprMI3YpRxMe)CnQxOktIBIvj2iVXjwqcA2pvrB5htuQ2EAsmAlZ42nnwZSCZMDjpfJhgt9QVtP9kvd(klhvc1FMSbSZOMb9jCwxIrD2aUxLRcWUXe0Y0NsSpf8afuWHl40HuIIwxJ2FOoAQZnrMgewZPlHXRaFhSkuawdkof8m8N7)UZSiliz(mSHSPDvJZYXYZUEeJghyiMljCFKyYWdyQZXzgzNgVSyMHIsXO1urs6MD6E13YTC5AYtgJrftzb970dpM1W9lz8EM2iAGk1ZndWulpdu4km8TqtpOGeNWqz9npAzES4tsgMf0JPyEX02dhDYTsmL3L7wRwz3wU7U9onUkBzDeCDDuulmAx)EQsZ6CQ77SImIy)dBuD3ALVuizONLP3d2zF3D)T9R1Ou1bgnNn6LMlz8oc5i)XYd)JoSqRlwaYn)eWTSGpaMejnfrBCnAe8r5GPHB7(wWX5mHOBUZ9fI4aXX82WDF1W)oOCqiUL8OTBb33cEGfmZDwc(SMWSTrtBo4ZNZ5fRU(QWcYDk5UhsWWJqktgs1WJTGfF9eWtAcl1g(sdgbpDjyz4RnJ(MS4Vn75x8MRpIstkzWoTRPnIGvmG27clp)9dFMndF820Usm6)i6i8pY28YcSbmf8H43xaFpSzo4hgZamFo8JrWlNdnD4NGp(vqvlyplOMv(U5dYhCXSj5XTRLI4yAWwrS4aKVxgwh(vuG98es86nuyJNgM21qljd9gFjuLyXXT)363CO(TbuW1CNqr4rGnSa8quTgokpJruuvsYFZSG3BESoc2()J0atMCVBMZ6jeF8TRB)FjkHYKm96LwVhw4)OxkV1xPyXvwnFVB9h)1d
   ```

### 11.3 Remaining Time avec une texture en plus
5. [partiel 2026-10-09 : trigger ok (même réglage sans bande de texture : rien avant 5 s, icône sous 5 s). Aura complète avec bande et sous-texte %s : rien ne s'affiche, cause non trouvée (export d'origine sans backslashes dans le chemin de texture ; région à suspecter)] Flame Shock sur un mob : rien les 7 premières secondes, puis sous 5 s l'icône **et** la bande rouge apparaissent ensemble, et disparaissent ensemble. En combat aussi.
   Export « Fix 2: Flame Shock under 5 s with texture » :
   ```
   !WA:2!DnvZUTnoq4y0TOaQaz3y4Mdl6bVfTbOhQRRbCqBrVyLAVXlITdKusoAtjosI1sKkKuo)aSxYHIE2pc(WEApLl9UFci8JqFeYtWskPTPO6G4W5B4WVVrFQ2G6c)UT60Pv76P1X1XF5PRibmQllNhapDRnOCzmJpjtsyuH1kmiqYCoscX8RMegkajE7vCisd7DvgyBoStalHX)RhOFSVMXsRDtaJLGzxqN5CbblJpF9)NOpos3juqr733rirCPLFiHseXw26fP1nsojkc4IT3Jxf(5SNiGaoipraoi6C3mijz4hfZSLAoSQeRNMMRVVmiDw2VH05(Xd872VTD32llRsxYJ1c0ppm0if(H9Cgn4KJY257Wt0zrsgV(hSZ1uZxZ2iqUmNwXlRSDmszb4vUFedd)7w2jme(0L5cyAqcsiMPpxcqL76KMNijwofz3ZxqOrjGV7H9g1BS65w2Imiy3IaY1Gj4ocvcCkk5u94qpX(6DZbiRNPoPdspdJxIOKuteDF12d2GnFQ0BMAMlCToyuSq1WMYOWAajaxjhOrY4hDJzNr2QxBNIi0bQxPAPAOETQ9JuVrV8R)CMNrWzVCa5YMDEFZbjOuOPBmlyEZCkg4n72u08cImUPeUuByGBr0aTr6yMwc(h0FSxFh9ypjSiHQ7DLWd46(yyHV7bo97pMFzPh7Qo5e8YWf6RRdhs5e6cJCIxjY9DkmFI3VRQXg9wFuW8iotZI)r1WGxra17Q9TQqVYLSUdnJZqua0dJNqfNbO5gxJyeGjOQQeUNNJ4W0b5jjNftKG6XNVYW8PzfAXEIN3KrRRA9bLo)A1o(bTBTFLONMQ9bofLRE4d9JbsuSCN1vGf574n54fQg8k(U08AQ51ZErwrVNUGii(jWm1HRhoECFNPLx8McWqgv6Qnj)rzTFkxijHxP6EpAHJEYjEhnCCF1FE(kJtGu(t9TeAiJx6AS81aHKiR6l(L)()(d
   ```
6. [ ] Même aura, ajoute un texte `%s` : sous le seuil, il suit les stacks (pas figé).

### 11.4 Power « Show at or above the value instead »
7. [ok 2026-10-09] Le texte « MANA OK » s'affiche à 50 % de mana ou plus, disparaît en dessous, en combat aussi.
   Export « Fix A: Mana 50% or more » :
   ```
   !WA:2!TjvZUnnqq4gfKQKbHGGuHdfKBLApwfvibesCWUkw8tBsXX0cNAw7DC8IC21A21PjvIlrCGZ5apa5mN6fUZnUzLhbEeYta7AhXHkU4D(2XZ8nFZ(vZRHmS1bhE4bnBmQbTb9Bpbf5QughWEFi4430TZSybx1NDfSZssUkrG9YumbxADnLjZsjtdGjQfN401XU37S3lZnvqONnpxcxeLsKYbHkskWvB5pkpvXS8lVD)qjJpmfc7)AhDTf32YvMbrBvgOjZeGt7fhlb1VxGWqnLbtZaxLMTLYecvC5hRsxFn8tvWT3y2LcKEosYMD(6GfXSja9CgvL8178hTmeJikwu5fUoAisIkfvBFPIGkRWygNjtSC1hkRzkKnCiGY7UpUo87UkZ0KRtN9aJw56gogcsqqMisPd8HXAr7FQ4sal2n0SOaCEMbAQS2QBuWUTAM9O)tJCcfJHblnz(xXdMzGgUhmpNVEISYUVre6sRWNiOWp2W186LDppKDL97ZjuKOi2bbRyCfGCs6zAvPf(pXpNlvS4PUh3XlyoHZmlibVDX2ElP5yj4cd3OeIeCQSyhxUGd)cisOVcb(qvYMZmiZZurB3reg3R4zfTk2PODXZ3S4f6JhFZB2LrZEOhBITZlTpHWj2TAUNTaThjqWpsKkW3EA9Mh8uZN21RpxcPXNk0tF4rD6g0XFfHhP9KEizujXH9pYVtNU4KkZqTdZz05XJ1m4OxFxx93LnO4vlK5H(LolTzUYdDujJ1QvR(cJkzRD6mESaR2iwH6eXSHwngFRV83
   ```
8. [ok 2026-10-09, pas d'erreur Lua. « MANA » reste blanc de 100 à 0 de mana, hors combat aussi : puissance secrète, condition toujours fausse. Disparition de toutes les auras vue une fois avec le groupe complet « Test 11 Restants » après un combat (pas d'erreur BugSack, IsPaused false, WeakAurasFrame affiché). Non reproduite ensuite : ni avec le groupe découpé en 4 (A Cast Succeeded, B Cast, C Power, D Glow), ni avec le groupe complet réimporté (deux combats), ni au banc. À surveiller] Ajoute une condition numérique « Power >= 50 » sur un trigger Power : en combat, aucune erreur Lua (la condition reste fausse, attendu).
9. [ ] (voleur, si possible) Swing Timer « Remaining <= 0.2 » + Power sans comparaison, Show only below 80 + Show at or above coché, All Triggers : « NOW » s'affiche en fin de swing avec 80 d'énergie ou plus.

### 11.5 Pixel Glow
10. [ok 2026-10-09] Lightning Shield actif : les points du glow tournent. Clique plusieurs fois sur l'aura dans `/wa` : le glow continue de tourner.
   Export « Fix B: Lightning Shield pixel glow » :
   ```
   !WA:2!DjvSUTnpq4eexeanK2y46HIm4MHmKMAeO2KHUzLAH0cNedzNSgtkEsIW0KYKu2XbOlE4h)Z(rWZDklDppbe(rjpbLu2fOOAG8UV70DFFhVTdRQWN103V5PvhvLuL8)hSKgl49efYy4GTwHk0zc5n5AQGR8wsafsxirAito7MKefOR4TucP2W9NLdbUFokwWeYVVJ9l4rHy02ZJfcgrmLpiAkLOZg)8FaAtsTvcfxw(ZJuAKu7HtOCQkZlWEP9MRL00uqQ27i5gZ7YFRcILG(wfeH4d7Ldm23(QAqG2YHLRJ1YsZ83GSN)DkVZ)t(F2kdCrsIJWYlB3PB4TDckS9cNZqZa5Ic(Mg5LVVJBtG(R9VsqGFUvatGi3TOqb3hZqk1aSgXaUUE0OcMM6fvIEewr5Pma37Ywx16AZ79cu5qC9sd6JGZ4fkxdsoIDNvF2rWVEzia5TC5PJq2Hs2ceNoYzXp3Sx4kIB2BDU3juPvOcorzQfWfC4zaPGEAjWt1z7o355uO5KGrikp0CS5dMAMtmFCxtt71R)xKdPK8ddPp0i4ln6qtZ0Cl)B0lJcmsJC6daRrktm9jep2Us0vy5o(I2x3VD0cfWskbm(VSoCOenQS94Exe1U91YhwVTmZVGswKmX2NGu2ujLpXPJSLQcCu5AK646MARSUyu8WuPOGt(VfUgFXMTQT3XutAJ7Ww5ocLW4cGhpRBLtB6F2ChMR1rDDKUmL(z04HCqPE1g6FpscOdXPLvUd1gA)aN5aCg40(4LUrlD9A)tuEIqU(zWdBdKqt9QoPYp(n
   ```
11. [ok 2026-10-09, glow Proc (le type Pulse n'existe pas)] Même chose avec le glow principal de l'aura (onglet Display, Glow, type Proc puis Pulse) : visible et animé après un clic.
12. [ok 2026-10-09] Même chose dans un Modern Aura Group.

### 11.6 Include Pets (Aura Modern)
13. [ ] En groupe avec un chasseur ou un démoniste : Aura (Modern), unité Party, Include Pets = Pets only, un buff du familier : seul le familier est suivi.
14. [ ] Players and Pets : joueurs et familiers. Le familier invoqué après coup est pris en compte sans `/reload`.

### 11.7 Jamais testés (anciennes versions)
15. [ ] **Charges de sort en combat** : Cooldown Progress (Spell) avec `%s`, sur un sort à charges.
16. [ok 2026-10-09] **Hide when target dies** (Spell Cast Succeeded) : l'aura se cache à la mort de la cible.
17. [ok 2026-10-09] **Hide when target changes** (Spell Cast Succeeded) : l'aura se cache au changement de cible.
18. [ok 2026-10-09] **Important** sur les incantations des autres unités (trigger Cast).
19. [ ] **Ignore out of checking range** (Unit Characteristics, en groupe) : un membre hors de portée est ignoré.

---

## Étape 12 : tests issus de l'audit du 2026-10-08 (20 min)

### 12.1 Throw Weapon (B1)
1. [fait 2026-10-09 : "Thrown", false. Le sous-type Thrown existe sur Forever] `/dump C_Item.GetItemSubClassInfo(2, 16)` : noter le résultat (nil, ou le nom du type).
2. [fait 2026-10-09 : 9 = "Warglaives", false ; 15 = "Daggers", false] `/dump C_Item.GetItemSubClassInfo(2, 9)` et `/dump C_Item.GetItemSubClassInfo(2, 15)` : noter, pour comparer.
3. [ok 2026-10-09 : Thrown présent dans Load ; le trigger lit la même liste] Un guerrier ou un voleur avec une arme de jet équipée : trigger Item Type Equipped (Item Type) et Load, Item Type Equipped.
   Le type Thrown est-il proposé ?

### 12.2 Absorbs (A1)
4. [fait 2026-10-09, chaman sans bouclier : « secret 0 » (valeur secrète, puis 0)] `/dump UnitGetTotalAbsorbs("player"), UnitGetTotalHealAbsorbs("player")` sans bouclier : noter (0 attendu).
5. [ ] Avec un bouclier d'absorption sur toi (prêtre : Power Word: Shield, ou un objet) : refaire la commande 4, noter.
   Deux nombres corrects = les absorbs peuvent être ouverts sur Forever.

### 12.3 Rôle et portée en groupe, en combat (A3)
6. [ ] En groupe, rôle choisi, **en combat** : `/dump issecretvalue(UnitGroupRolesAssigned("party1"))`. Noter.
7. [ ] Même chose avec `/dump issecretvalue((UnitInRange("party1")))`. Noter.
8. [ ] Une aura Aura (Legacy) en mode groupe, filtrée par rôle : en combat, pas d'erreur Lua.

### 12.4 Sortie de combat (A4)
9. [ok 2026-10-09, Lot2 A Bouclier de foudre posé en combat, mis à jour à la sortie] Aura Icon, trigger Aura sur un buff posé **en combat**. Sors du combat sans rien toucher : l'aura se met à
   jour (durée, stacks) dans les 2 secondes, sans changer de cible ni relancer le buff. Noter le délai vu.

### 12.5 Portée d'objet en combat (A5)
10. [ ] Trigger Cooldown Progress (Item) sur un objet utilisable à distance, condition **Item in Range** : sur une
    cible ennemie, **en combat**, pas d'erreur `ADDON_ACTION_BLOCKED` ni d'action bloquée dans BugSack.

### 12.6 Masque (B2)
11. [ ] Masque installé, un skin appliqué. Aura Icon sur un buff posé en combat : l'icône garde la taille réglée.
12. [ ] `/reload` puis relog : les icônes skinnées gardent leur taille.

### 12.7 Diagnostics des KO sans cause (B1, B3, 11.1)
13. [ok 2026-10-09 : 1, 19 ; slots lus ; aura de test conforme (overall 17, lowest 0, broken 1)] Durability : `/dump INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED`, puis `/run for s=1,19 do print(s, GetInventoryItemDurability(s)) end`. Noter ce que « un seul slot fonctionne » veut dire (quel réglage, quelle valeur vue).
14. [ok 2026-10-09 : active true, spellID 2383 ; aura de test et Inverse conformes] Tracking : Find Herbs actif, `/run for i=1,C_Minimap.GetNumTrackingTypes() do local t=C_Minimap.GetTrackingInfo(i) print(i, t.name, t.active, t.spellID) end`. Noter la ligne Find Herbs.
15. [ok 2026-10-09 : difficulté 1, Normal, party ; aura de test conforme dedans et dehors] Instance Type, **dans un donjon** : `/dump select(3, GetInstanceInfo())` et `/dump GetDifficultyInfo(select(3, GetInstanceInfo()))`. Noter, puis ouvrir la liste Instance Type du Load.
16. [ok 2026-10-09 : IsClassicEra() = true ; Thrown présent dans la liste du Load] Thrown : `/dump WeakAuras.IsClassicEra()`. Puis la liste Item Type du Load : Thrown présent ?
17. [écarté 2026-10-09 par l'utilisateur : débuff de cible = trigger Aura (Modern)] Flame Shock aura2 (11.1 tests 2 et 3), sur un mob, hors combat, Flame Shock posé : `/dump issecretvalue(C_UnitAuras.GetAuraDataByIndex("target",1,"HARMFUL|PLAYER").spellId)`. true = le trigger Aura (Legacy) ne peut pas voir ce débuff, utiliser Aura (Modern).

---

# 4. Résultats reçus et prompt de fin

## Profilage reçu (`/wa pprint`, démoniste, auras du pack Forever)

```
Total time: 39092.01ms ()
Time inside WA: 27.32ms (0.88ms)
Time spent inside WA: 0.07%

Auras:
Pre-pull checklist (Forever) 1.38ms, 64.82% (0.19ms)
Immolate timer (Forever) 0.57ms, 26.87% (0.28ms)
Low: Soul Shards 0.09ms, 4.35% (0.09ms)
Missing: Demon Skin / Armor 0.08ms, 3.95% (0.02ms)

Systems (les 5 plus chers):
bufftrigger2 - OnUpdate 21.35ms, 78.16% (0.03ms)
load 2.36ms, 8.64% (0.88ms)
dynamicgroup 1.38ms, 5.06% (0.19ms)
generictrigger UNIT_SPELLCAST_SUCCEEDED player 0.53ms, 1.95% (0.30ms)
generictrigger PLAYER_TARGET_DIED 0.14ms, 0.52% (0.14ms)
```

Lecture : 0,07 % du temps dans l'addon, pas de problème de performance. `bufftrigger2 - OnUpdate` fait l'essentiel du
temps de l'addon (21 ms sur 39 s).

## Prompt à donner à Claude à la fin

Copie ce bloc, remplis les résultats, colle le tout dans une nouvelle conversation dans ce dossier :

```
Voici les résultats des tests en jeu de Musca Auras, dans l'ordre de SUIVI-BUGS-ET-TESTS.md.
Lis SUIVI-BUGS-ET-TESTS.md et CHANGES.md pour le contexte.

Étape 1 (valeurs encore à noter) :
1.6 = ...   1.8 = ...   1.12 = ...  1.13 = ...  1.14 = ...

Étape 6.5 (lien Cooldown Manager, lignes affichées) :
hors combat = ...
en combat = ...
commande 4 = ...

Étape 10 (1.9 et 1.10 pendant un boss) = ...
Étape 10 (profilage boss, /wa pprint, 3 lignes les plus chères) :
- ...

Étape 12 (valeurs) :
12.1 = ...   12.2 = ...   12.3 = ...   12.4 (délai) = ...

Tests KO (numéro d'étape, ce que j'ai fait, ce que j'ai vu, erreur BugSack complète) :
- ...

Tests non faits :
- ...

Ce que je veux :
1. Corrige les tests KO et les bugs de la section 1, du plus grave au moins grave (🔴 d'abord), sans rien ajouter
   d'autre.
2. Si 1.9 et 1.10 sont true pendant un boss, code le trigger natif « Encounter Timeline » de la phase E, sinon ferme
   la phase E.
2b. Si l'étape 6.5 montre en combat un ID d'instance lisible, relie les auras secrètes du trigger Aura aux entrées du
    Cooldown Manager pour les reconnaître par ID de sort, avec une aide hors combat qui range les buffs voulus dans
    Tracked Buffs. Sinon, note la limite dans TUTORIAL.md.
2c. Pour chaque constat de l'audit (section 2) que l'étape 12 confirme, corrige-le ; sinon, note-le comme écarté.
3. Utilise wow-api pour toute API non vérifiée et relecteur avant de dire terminé.
4. Mets à jour CHANGES.md et coche dans SUIVI-BUGS-ET-TESTS.md ce qui est corrigé.
5. Donne-moi à la fin la liste des tests à refaire en jeu.
```

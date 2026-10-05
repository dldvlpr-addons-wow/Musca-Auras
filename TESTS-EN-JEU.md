# Tests en jeu : Musca Auras

Rien de ce qui a été codé n'a été testé en jeu. Ce fichier donne l'ordre des tests, ce qu'il faut voir, et le prompt
à donner à Claude à la fin.

Pour chaque test, note **OK**, **KO** (avec le texte exact de l'erreur ou ce que tu vois) ou **non testé**.
Les tests marqués 🔴 sont bloquants : s'ils échouent, note-le et passe quand même aux suivants.

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

| # | Commande | Résultat attendu |
|---|---|---|
| 1.1 | `/dump select(4, GetBuildInfo())` | un nombre inférieur à 20000 (16001) |
| 1.2 | `/dump WOW_PROJECT_ID, WOW_PROJECT_MAINLINE` | noter les deux valeurs |
| 1.3 | `/dump C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()` | un numéro de spé, ou nil |
| 1.4 | `/dump C_Secrets ~= nil, issecretvalue ~= nil` | `true, true` |
| 1.5 | `/dump C_CooldownViewer ~= nil` | `true` |
| 1.6 | `/dump GetInventoryItemDurability(1)` | deux nombres (si casque équipé) |
| 1.7 | `/dump C_Minimap.GetNumTrackingTypes()` | un nombre ≥ 1 |
| 1.8 | `/dump GetInstanceInfo()` dans un donjon | noter le 3ᵉ nombre (ID de difficulté) |
| 1.9 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureAvailable()` | noter (décide la phase E) |
| 1.10 | `/dump C_EncounterTimeline and C_EncounterTimeline.IsFeatureEnabled()` | noter |
| 1.11 | `/dump C_Texture.GetAtlasInfo("RaidFrame-Icon-DebuffMagic") ~= nil` | `true` |

---

## Étape 2 : 🔴 le combat de base (15 min, sur n'importe quel mob)

### 2.1 Icône de cooldown en combat
- [ok ] Crée une aura Icon, trigger **Cooldown** sur un de tes sorts (ID exact).
- [ ok] Hors combat : lance le sort, le cadran tourne et le chiffre descend.
- [ ok] En combat : pareil, sans erreur. **Risque n°1** : si une erreur parle de `SetCooldown` ou de fonction protégée, note-la en entier.

### 2.2 Buff posé en combat
- [ ok] Aura Icon, trigger **Aura**, sur toi, un buff que tu te poses (spell ID exact).
- [ ] Ajoute un texte `%p` et un texte `%s`.
- [partiel ] Hors combat : icône, durée qui descend, stacks.
- [ok, corrigé] Pose le buff **en combat** : l'icône apparaît, `%p` descend, `%s` montre les stacks. Relance en combat de ton propre buff : minuteur remis à zéro (option B). Stacks figés en combat : limite du moteur, notée dans TUTORIAL.md.
- [ok] À la fin du combat, l'aura reste juste (pas de doublon, pas de figé).

### 2.3 Barre de vie et de mana en combat
- [ok] Aura Progress Bar, trigger **Health** sur `target`, puis une autre **Power** sur `player`.
- [ok, corrigé : UNIT_HEALTH, texte %p / %t natif] En combat, les deux barres bougent.
- [ok 2026-09-30, natif] Même chose en **Progress Texture** : Left to Right sur Health `target`, Clockwise sur Power `player`, les deux bougent en combat.
- [ok 2026-09-30, natif] Aura **Text** `%percenthealth% (%health / %maxhealth)` sur `target` : les chiffres changent en combat.
- [ok 2026-09-30, natif] Aura **Progress Bar**, trigger **Cast** sur `target` : la barre apparaît et avance quand le mob incante en combat.
- [ ] Ajoute une condition « Health < 50 % » : elle garde son dernier état en combat (attendu), et se remet à jour à la fin.

### 2.4 Global Cooldown
- [ ] Trigger **Global Cooldown** : il s'affiche à chaque sort, en combat aussi.
- [ ] `/wa pstart`, 20 s de combat, `/wa pstop`, `/wa pprint` : note les 3 lignes les plus chères.

---

## Étape 3 : armes, munitions, enchantements (10 min)

- [ok ] **Swing Timer, main hand** : la barre repart à chaque coup.
- [ ] **Off hand** (si deux armes) : barre séparée, juste après un buff de vitesse d'attaque.
- [ ] **Ranged / baguette** : la barre suit le tir automatique.
- [ ] **Swing Timer, Target In Range** : réglé sur In Range, l'aura s'affiche au corps à corps ; sur Out of Range, loin de la cible ; sans cible, ni l'un ni l'autre.
- [ ] **Ammo** (chasseur, guerrier, voleur) : Count = munitions équipées, Total Carried = toutes les munitions des sacs ; le filtre d'objet Ammo Item ne montre l'aura qu'avec la munition choisie.
- [ok ] **Enchantement temporaire** (poison, pierre à aiguiser, huile) : sur les deux armes, les deux s'affichent avec leur durée.

---

## Étape 4 : dissipation (10 min, un mob ou un joueur qui pose des débuffs)

- [ ] Bordure avec **Color by Dispel Type** sur une aura de débuff : magie bleue, malédiction violette, poison verte, maladie marron.
- [ ] Même test **en combat** : les couleurs restent justes. Si une couleur est fausse, note le type et la couleur vue (les ID de type sont supposés).
- [ ] Sous-élément **Dispel Type Icon** : hors combat, l'icône Blizzard du type ; en combat, un rond de la couleur du type.
- [ ] Une condition qui change la couleur de la bordure gagne toujours sur la couleur de dissipation.

---

## Étape 5 : nouveaux triggers et options (15 min)

- [ok] **Bag Space** : ramasse un objet, Free Slots baisse ; Include Specialty Bags compte le carquois.
- [ko ] **Equipment Durability** : meurs une fois, Lowest et Overall baissent ; un seul slot fonctionne.
- [ok, corrigé] **Role** : en groupe, choisis un rôle dans la recherche de groupe, l'aura suit.
- [ko ] **Tracking** : Find Herbs par son ID de sort, l'aura suit l'activation ; Inverse fait l'inverse.
- [ko ] **Load, Instance Type** : dans un donjon, la liste des difficultés est remplie et le filtre marche.
- [ ] **Conditions, Secret Restrictions Active** : vrai en combat, faux après.
- [ ok] **Cooldown, condition On Global Cooldown** (avec Show Global Cooldown) + Hide Cooldown Text : le chiffre disparaît pendant le GCD seulement.
- [ ok] **Aura, Elapsed Time ≥ 5** : l'aura s'affiche 5 s après la pose du buff.
- [ ] **Texte `%p`** : format Old / Modern et Increase Precision Below suivent les réglages, en combat aussi.

---

## Étape 6 : Cooldown Manager (5 min)

- [ ok] `/wa cdm` hors combat : le Cooldown Manager de Blizzard s'affiche / se cache. En combat : message de refus.
- [ok ] Après `/wa cdm`, aucune erreur « action bloquée » (taint) en combat.
- [ok] Trigger Cooldown : la liste **From the Cooldown Manager** est remplie et règle le sort.
- [ok ] Trigger Aura (Exact Spell ID coché) : la liste **From the Cooldown Manager** ajoute les ID d'un buff suivi.

### 6.5 Lien Cooldown Manager ↔ aura en combat (décide si on reconnaît un buff secret par son sort)

But : savoir si un addon peut lire, en combat, quel buff le Cooldown Manager affiche. Si oui, on pourra reconnaître
par son ID de sort un buff posé en combat dont les données sont secrètes (comme le fait ForeverAuras).

1. [ ] Hors combat : `/wa cdm` pour afficher le Cooldown Manager. Dans ses réglages (Edit Mode > Cooldown Manager),
   mets 2 ou 3 de tes buffs dans **Tracked Buffs**, dont un qui apparaît en combat (proc, bijou, talent).
2. [ ] Hors combat, buff actif, colle cette commande (une seule ligne) :
   ```
   /run local S=issecretvalue for _,v in ipairs({BuffIconCooldownViewer,BuffBarCooldownViewer})do for _,f in ipairs(v:GetItemFrames())do local c,a,s=f.cooldownID,f.auraInstanceID,f.auraSpellID if c then print(c,S(a)and"S"or a,S(s)and"S"or s)end end end
   ```
   Note ce qui s'affiche : une ligne par buff suivi (ID d'entrée, ID d'instance, ID de sort ; S = secret).
3. [ ] **En combat**, avec le buff posé pendant le combat, recolle la même commande. Note les lignes.
4. [ ] Toujours en combat, colle :
   ```
   /run local t=C_UnitAuras.GetUnitAuraInstanceIDs("player","HELPFUL") print(#t) for _,i in ipairs(t) do print(i, C_Secrets and C_Secrets.ShouldUnitAuraInstanceBeSecret and C_Secrets.ShouldUnitAuraInstanceBeSecret("player", i)) end
   3
25 false
3 false
1 false
   ```
   Note si l'ID d'instance vu à l'étape 3 apparaît ici, et si sa ligne dit `true` (aura secrète).

Résultat utile : à l'étape 3, l'ID d'entrée est un nombre et l'ID d'instance est un nombre (pas `SECRET`), présent à
l'étape 4. Si la commande 2 ou 3 affiche une erreur, copie-la en entier.

---

## Étape 7 : 🔴 filtres natifs et auras secrètes (10 min)

- [ ] Trigger Aura sur `target`, Debuff, **Native Filter** seul, Is = Crowd Control.
- [ ] Hors combat : un contrôle posé s'affiche, avec son nom.
- [ ] En combat : un contrôle posé s'affiche sans nom, avec icône, durée et stacks dessinés par le jeu.
- [ ] Même aura avec **Clones** et deux contrôles : pas d'erreur, deux icônes.
- [ ] Is = Cast by Me or my Pet : seulement tes débuffs.
- [ ] Une aura sans filtre natif se comporte exactement comme avant.

---

## Étape 8 : groupe, glow, divers (10 min) bug

- [ ] Action **Glow** (Pixel, Autocast, Proc) sur une icône : le glow est visible et bien dessiné.
- [ ] Trigger Aura en mode groupe (party) : les membres sont trouvés, pas d'erreur de GUID en combat.
- [ ] L'unité Multi-target n'est plus proposée dans le trigger Aura.
- [ ] Un trigger Combat Log affiche l'avertissement « combat log fermé ».
- [ ] Portée : une aura avec condition de portée sur la cible change bien en s'éloignant.

---

## Étape 9 : import ForeverAuras (10 min)

- [ ] Dans ForeverAuras (réactivé seul), exporte 3 ou 4 auras variées : Cooldown Manager, Aura (Blizzard), Swing, Ammo, Bag Space, bordure ou icône de dispel.
- [ ] Désactive ForeverAuras, réactive Musca Auras, importe les chaînes.
- [ ] Le chat affiche « Converted from ForeverAuras. » et la liste de ce qui n'est pas converti.
- [ ] Chaque aura importée marche comme dans ForeverAuras. Note celles qui diffèrent.

---

## Étape 10 : donjon ou raid (si possible, 30 min)

- [ ] Un vrai combat de boss avec 5 à 10 auras chargées : pas d'erreur, pas de chute de FPS.
- [ ] `/wa pstart encounter`, fais le boss, `/wa pprint` : note les 3 lignes les plus chères.
- [ ] Refais les commandes 1.9 et 1.10 pendant le combat.

---

## Étape 11 : tests du 2026-10-05 (chaman 16, 30 min)

Exports à importer avec `/wa` > Import. Relance le jeu avant (nouveaux fichiers). Garde BugSack ouvert.

### 11.1 Lot 2 BuffTrigger2 (code déplacé, même comportement attendu)
1. [ ] **Lightning Shield sur toi** : l'icône apparaît avec la durée et les charges. Relance avant la fin : la durée repart à zéro.
   Export « Lot2 A: Lightning Shield player » :
   ```
   !WA:2!DnvZoTTtqCqTsizPIu9bouHudrcU0cTkPLdi1pIPofQcXiBdxtw7DS9wS31S76abPEHt9CEeY5EIl9EEcwLhH(iKNGURnv)L(7dZoFS78BMFZ417BxyJTX)C75KygnGvXJHTxBjQsMX4ELscJkSMJbbswXrsiJp1ljras8MZ5qQoC40sWX8y)ywoJ)TNO)CUJXkw)(yglhZUHo2)gcwMD9I)5WfNQZekUo9h6lKiU0kkHqjImlh9H06EjNKMcCXM7XFunXrQXYhPlKoZmskQaeVOt3oVJxjGHARXllqY4mqeKXUXJUquF0td0eq3frvjjM6LFI7GZ7FXaNknurL5OPaFwf9rCSkFoQ(fHn2NXWWVwZjNHWxotd0O4CKqmosIYbQCl)IQCjXYV27ErccnnhIcoP3z9gQAB5ikH4TQvi3bgLveQe4uu(L62tZa)E1vau2ZCpPpsZjzZqusHrJEO6z9xInuV2yKP)5cqt2yHY2HYOWcajGajhOPYSnU3yz6q1(oficTV6vQxRSv7Royd1B0hB()90MGlF5aMStREh1Aajnts1nqRGmcKJB1qnpGOX61HZz6cp6y3HHU(ZeqEsTdv3vnH7Z1dad2rbh776oKFBZMY0ovempzIbKECcDIPfYMlQI8RxGehTLYEP2mcfFvkNvrXtu2CTdjCRCMrmYiAVB5IAJjebjkhgVOb3rLMYyXPdh66pYXlm07SL13lHrLbAoFNMN99kHKKmv19)IwVl4Dr4Gth6QXu9b1hBVRq9PXQp)NM8f6DU)PF9KqLZoQJvDvFr5gLbgA665MXaP5pKhi0egVzKzfPdKqsTSfrV)GoDo4T2tE6p(7
   ```
2. [ ] **Flame Shock sur la cible** : l'icône apparaît. Relance sur le même mob : la durée repart. Change de cible : l'icône disparaît.
   Export « Lot2 B: Flame Shock target » :
   ```
   !WA:2!DnvZoTnqqyqfjKSurQ(ahqCiej4sluuqGQqQ)etDkursqogUMS2ES9wS31S76abPEHt9CEeY5EIl9EEcwLhH(iWtqN1MQkvFy35BMDMVz)2Xl3Xo3oYo6hBoJgYzd4LIqyZLwqkvPCr)cfLZKwZIajrvkikivmPFCSeuRyntajyy)jfGJjzVqEgx81xGFo3Z55l)qiNNfXVLnY7wAKk9M5)1HBucwjsyv5pYtQicLvqmLrLPwo4MY6bLGMKac5A7iE2m2rHC5rWgP1uZkJKdYnCE3(hUVOuc9q4Of5evykihKYVTpBUSARnY0yaVgbLXXMgwCABVUDU8CNsKRaK(eqnTK9mrwfVIuLHFnUlpc(5sozCs0vtrIggMrKYryEzatTUxEzMIA5v5DNajLLKbbdoTD3290nTCKfq46vg07bJXtuMcems2v49dLGF901au02CoLhbfL0Pegn3yXos)YolImApcgAeaHeq1osQTDyCgmhisyGsaSev6QpyqMBOExNCcL1r)A9B026D17TQ(T42A)VNM0OInoNRA1W54gDYqnSbQDHx3OwvEKWcXrHl4yphCIBpFxVPsilUYH(GNQd3rG5zOnyWjEUU9e3vpLmPvjnsep2uFhbLn209PZKLbEvdpYJxxBVaHbKWRte8sw0yTTaDOG7utnldnln3UyEfymvsdYGrZR5DyHPnMFwVEUEdD6773V7IQZfZzQbOCVvDAFRuQOXt0h8VOvJb9V0)8Z65ICQFV(dn3wQ)4i9N(DD987FH3zF5uFTZw6t0hO)S2nifOjPQBMzEbO1)D8iLfZf1VwwbyGyAILTm4W9A1AV9ThVY3)Zp
   ```
3. [ ] **Flame Shock, filtre natif Cast by Me** : comme le test 2, seul ton Flame Shock compte. Si rien ne s'affiche alors que le test 2 marche, note-le.
   Export « Lot2 C: Flame Shock target native PLAYER » :
   ```
   !WA:2!Dn1ZQTntq8eAHacAGAd(qPhCdKqpL6AiMsovjJuC(WwoiReONSwjTsABK3vz3voXb6LCO0Z(rWN7PaLE3pbl(rOpc(j4BwPuAP6WUZF2zMFZVz0UonM1iUr83E9kseJoHvYJWVENnOszgJpUqsyuHXQySajl5ijoJVyCsIal)Xkoof86VOaBPJ1lILZ4)3ZGpR7zSz7(qeJLhZULg4DljwMDZ6FBWoofsekQk798esexAeMqOerMHfCjnEqYjPPyUy)J4pj(1TLcSlssMJDi5smpWscf3dbaRlVY3mCWsTkfKeVY6dDoPZA6FfrRWlgA(jBVGnZqYOmSysg72X01IQlZi9lHMnSmjr3x8bMEJCUCOvjaPqaLPy5Ys6t4XO4LOQi8R1hXIXFFhRCgk(QLaCMgLJeIaiUCmv2YBwzUKy4vz9OqbHMMJdNmWCKPR6qdlrboQvLa5ESwylHcqMIYVcObGP(52RX4ct97KEqtXYwIOKzAjAp1lC2eRNqGYunTWfyyOelunTOmkEngjWtKCmnvMT3dAnDhQ6yndrOoQJvVt1u1r9(9uDHR9)xlhqIlE7qMSB7(N22jh432a3fDD7AwPDnl3UMEFerJG1Nlyqhe232132BPaNNuzq1BBTBhoKfnicN03Z22LFx9M1IULKyEYCD16Zj056EjBLOm0RAJtCAlvZnGAik66uoRKgpx1KdgK47Kl1ht1hhCyX6kL5ebjmhhSUUUtl0Wy95UU2EtTg77pE0MQ3LWOYja5)M6W(CPqsswO69hVvlfJV0F45U2qnvFuzEWHcLvGQ)VQZN)4l8o)Sb(k73OCu9uNPgeMHjPzYBwPNhK6)OEKqty86zNri4iHKA0qeEYXD7ECNgZF(x()d
   ```

### 11.2 Barre de progression dans un Modern Aura Group
4. [ ] Le groupe s'affiche avec la barre Lightning Shield (temps à droite) et l'icône Flame Shock à côté. Plus de message « use an Icon display ». En combat aussi.
   Export « Fix 1: Modern Aura Group with bar » :
   ```
   !WA:2!Ls5ZpTXruCCCjPu2wf14KqXuizdQH2qBPGtaLsvtLxQnqLXGwBSQ6f7z3D8Utz9mBMzwZpK6fupWz)NGpNtCj39FbpXFk8xqFZA3gAupePAjVEEJN5nV33VF2jxZ8(lFXdhW8f86IuPpD(j8siskxN84kStSxBt79ebuj3UuQKyVTuKMyFmthz7rKxrs1rc5(jAMGRSCmzPDFfnUZbcgx7Tv5Ank7kpD)oDuuDUbsAiUWgNMqLemByg8IOSWi9tLA6j6uj9CNy2zNrKb9n5QLIfqDQwUsJR9i(hfIhopylrSq(l5YL7GjxDL1DpMfOJ(Zprs8ZkInCvAIuB51HXzQiSM4mT15AjlmKkv3zj54HntEGI6lP6dvuxc)O6j044D)zvBhnwFdg9FMEo5tn16nxYCfFwXNpiG6L2PtwZSt5Qhu5WQoP4z5LetoLk7NYhFqwj31uB9OngfBKZxprMI3YpRxMe)CnQxOktIBIvj2iVXjwqcA2pvrB5htuQ2EAsmAlZ42nnwZSCZMDjpfJhgt9QVtP9kvd(klhvc1FMSbSZOMb9jCwxIrD2aUxLRcWUXe0Y0NsSpf8afuWHl40HuIIwxJ2FOoAQZnrMgewZPlHXRaFhSkuawdkof8m8N7)UZSiliz(mSHSPDvJZYXYZUEeJghyiMljCFKyYWdyQZXzgzNgVSyMHIsXO1urs6MD6E13YTC5AYtgJrftzb970dpM1W9lz8EM2iAGk1ZndWulpdu4km8TqtpOGeNWqz9npAzES4tsgMf0JPyEX02dhDYTsmL3L7wRwz3wU7U9onUkBzDeCDDuulmAx)EQsZ6CQ77SImIy)dBuD3ALVuizONLP3d2zF3D)T9R1Ou1bgnNn6LMlz8oc5i)XYd)JoSqRlwaYn)eWTSGpaMejnfrBCnAe8r5GPHB7(wWX5mHOBUZ9fI4aXX82WDF1W)oOCqiUL8OTBb33cEGfmZDwc(SMWSTrtBo4ZNZ5fRU(QWcYDk5UhsWWJqktgs1WJTGfF9eWtAcl1g(sdgbpDjyz4RnJ(MS4Vn75x8MRpIstkzWoTRPnIGvmG27clp)9dFMndF820Usm6)i6i8pY28YcSbmf8H43xaFpSzo4hgZamFo8JrWlNdnD4NGp(vqvlyplOMv(U5dYhCXSj5XTRLI4yAWwrS4aKVxgwh(vuG98es86nuyJNgM21qljd9gFjuLyXXT)363CO(TbuW1CNqr4rGnSa8quTgokpJruuvsYFZSG3BESoc2()J0atMCVBMZ6jeF8TRB)FjkHYKm96LwVhw4)OxkV1xPyXvwnFVB9h)1d
   ```

### 11.3 Remaining Time avec une texture en plus
5. [ ] Flame Shock sur un mob : rien les 7 premières secondes, puis sous 5 s l'icône **et** la bande rouge apparaissent ensemble, et disparaissent ensemble. En combat aussi.
   Export « Fix 2: Flame Shock under 5 s with texture » :
   ```
   !WA:2!DnvZUTnoq4y0TOaQaz3y4Mdl6bVfTbOhQRRbCqBrVyLAVXlITdKusoAtjosI1sKkKuo)aSxYHIE2pc(WEApLl9UFci8JqFeYtWskPTPO6G4W5B4WVVrFQ2G6c)UT60Pv76P1X1XF5PRibmQllNhapDRnOCzmJpjtsyuH1kmiqYCoscX8RMegkajE7vCisd7DvgyBoStalHX)RhOFSVMXsRDtaJLGzxqN5CbblJpF9)NOpos3juqr733rirCPLFiHseXw26fP1nsojkc4IT3Jxf(5SNiGaoipraoi6C3mijz4hfZSLAoSQeRNMMRVVmiDw2VH05(Xd872VTD32llRsxYJ1c0ppm0if(H9Cgn4KJY257Wt0zrsgV(hSZ1uZxZ2iqUmNwXlRSDmszb4vUFedd)7w2jme(0L5cyAqcsiMPpxcqL76KMNijwofz3ZxqOrjGV7H9g1BS65w2Imiy3IaY1Gj4ocvcCkk5u94qpX(6DZbiRNPoPdspdJxIOKuteDF12d2GnFQ0BMAMlCToyuSq1WMYOWAajaxjhOrY4hDJzNr2QxBNIi0bQxPAPAOETQ9JuVrV8R)CMNrWzVCa5YMDEFZbjOuOPBmlyEZCkg4n72u08cImUPeUuByGBr0aTr6yMwc(h0FSxFh9ypjSiHQ7DLWd46(yyHV7bo97pMFzPh7Qo5e8YWf6RRdhs5e6cJCIxjY9DkmFI3VRQXg9wFuW8iotZI)r1WGxra17Q9TQqVYLSUdnJZqua0dJNqfNbO5gxJyeGjOQQeUNNJ4W0b5jjNftKG6XNVYW8PzfAXEIN3KrRRA9bLo)A1o(bTBTFLONMQ9bofLRE4d9JbsuSCN1vGf574n54fQg8k(U08AQ51ZErwrVNUGii(jWm1HRhoECFNPLx8McWqgv6Qnj)rzTFkxijHxP6EpAHJEYjEhnCCF1FE(kJtGu(t9TeAiJx6AS81aHKiR6l(L)()(d
   ```
6. [ ] Même aura, ajoute un texte `%s` : sous le seuil, il suit les stacks (pas figé).

### 11.4 Power « Show at or above the value instead »
7. [ ] Le texte « MANA OK » s'affiche à 50 % de mana ou plus, disparaît en dessous, en combat aussi.
   Export « Fix A: Mana 50% or more » :
   ```
   !WA:2!TjvZUnnqq4gfKQKbHGGuHdfKBLApwfvibesCWUkw8tBsXX0cNAw7DC8IC21A21PjvIlrCGZ5apa5mN6fUZnUzLhbEeYta7AhXHkU4D(2XZ8nFZ(vZRHmS1bhE4bnBmQbTb9Bpbf5QughWEFi4430TZSybx1NDfSZssUkrG9YumbxADnLjZsjtdGjQfN401XU37S3lZnvqONnpxcxeLsKYbHkskWvB5pkpvXS8lVD)qjJpmfc7)AhDTf32YvMbrBvgOjZeGt7fhlb1VxGWqnLbtZaxLMTLYecvC5hRsxFn8tvWT3y2LcKEosYMD(6GfXSja9CgvL8178hTmeJikwu5fUoAisIkfvBFPIGkRWygNjtSC1hkRzkKnCiGY7UpUo87UkZ0KRtN9aJw56gogcsqqMisPd8HXAr7FQ4sal2n0SOaCEMbAQS2QBuWUTAM9O)tJCcfJHblnz(xXdMzGgUhmpNVEISYUVre6sRWNiOWp2W186LDppKDL97ZjuKOi2bbRyCfGCs6zAvPf(pXpNlvS4PUh3XlyoHZmlibVDX2ElP5yj4cd3OeIeCQSyhxUGd)cisOVcb(qvYMZmiZZurB3reg3R4zfTk2PODXZ3S4f6JhFZB2LrZEOhBITZlTpHWj2TAUNTaThjqWpsKkW3EA9Mh8uZN21RpxcPXNk0tF4rD6g0XFfHhP9KEizujXH9pYVtNU4KkZqTdZz05XJ1m4OxFxx93LnO4vlK5H(LolTzUYdDujJ1QvR(cJkzRD6mESaR2iwH6eXSHwngFRV83
   ```
8. [ ] Ajoute une condition numérique « Power >= 50 » sur un trigger Power : en combat, aucune erreur Lua (la condition reste fausse, attendu).
9. [ ] (voleur, si possible) Swing Timer « Remaining <= 0.2 » + Power sans comparaison, Show only below 80 + Show at or above coché, All Triggers : « NOW » s'affiche en fin de swing avec 80 d'énergie ou plus.

### 11.5 Pixel Glow
10. [ ] Lightning Shield actif : les points du glow tournent. Clique plusieurs fois sur l'aura dans `/wa` : le glow continue de tourner.
   Export « Fix B: Lightning Shield pixel glow » :
   ```
   !WA:2!DjvSUTnpq4eexeanK2y46HIm4MHmKMAeO2KHUzLAH0cNedzNSgtkEsIW0KYKu2XbOlE4h)Z(rWZDklDppbe(rjpbLu2fOOAG8UV70DFFhVTdRQWN103V5PvhvLuL8)hSKgl49efYy4GTwHk0zc5n5AQGR8wsafsxirAito7MKefOR4TucP2W9NLdbUFokwWeYVVJ9l4rHy02ZJfcgrmLpiAkLOZg)8FaAtsTvcfxw(ZJuAKu7HtOCQkZlWEP9MRL00uqQ27i5gZ7YFRcILG(wfeH4d7Ldm23(QAqG2YHLRJ1YsZ83GSN)DkVZ)t(F2kdCrsIJWYlB3PB4TDckS9cNZqZa5Ic(Mg5LVVJBtG(R9VsqGFUvatGi3TOqb3hZqk1aSgXaUUE0OcMM6fvIEewr5Pma37Ywx16AZ79cu5qC9sd6JGZ4fkxdsoIDNvF2rWVEzia5TC5PJq2Hs2ceNoYzXp3Sx4kIB2BDU3juPvOcorzQfWfC4zaPGEAjWt1z7o355uO5KGrikp0CS5dMAMtmFCxtt71R)xKdPK8ddPp0i4ln6qtZ0Cl)B0lJcmsJC6daRrktm9jep2Us0vy5o(I2x3VD0cfWskbm(VSoCOenQS94Exe1U91YhwVTmZVGswKmX2NGu2ujLpXPJSLQcCu5AK646MARSUyu8WuPOGt(VfUgFXMTQT3XutAJ7Ww5ocLW4cGhpRBLtB6F2ChMR1rDDKUmL(z04HCqPE1g6FpscOdXPLvUd1gA)aN5aCg40(4LUrlD9A)tuEIqU(zWdBdKqt9QoPYp(n
   ```
11. [ ] Même chose avec le glow principal de l'aura (onglet Display, Glow, type Proc puis Pulse) : visible et animé après un clic.
12. [ ] Même chose dans un Modern Aura Group.

### 11.6 Include Pets (Aura Modern)
13. [ ] En groupe avec un chasseur ou un démoniste : Aura (Modern), unité Party, Include Pets = Pets only, un buff du familier : seul le familier est suivi.
14. [ ] Players and Pets : joueurs et familiers. Le familier invoqué après coup est pris en compte sans `/reload`.

### 11.7 Jamais testés (anciennes versions)
15. [ ] **Charges de sort en combat** : Cooldown Progress (Spell) avec `%s`, sur un sort à charges.
16. [ ] **Hide when target dies** (Spell Cast Succeeded) : l'aura se cache à la mort de la cible.
17. [ ] **Hide when target changes** (Spell Cast Succeeded) : l'aura se cache au changement de cible.
18. [ ] **Important** sur les incantations des autres unités (trigger Cast).
19. [ ] **Ignore out of checking range** (Unit Characteristics, en groupe) : un membre hors de portée est ignoré.

---

## Prompt à donner à Claude à la fin

Copie ce bloc, remplis les résultats, colle le tout dans une nouvelle conversation dans ce dossier :

```
Voici les résultats des tests en jeu de Musca Auras, dans l'ordre de TESTS-EN-JEU.md.
Lis TESTS-EN-JEU.md et CHANGES.md pour le contexte.

Étape 1 (valeurs) :
1.1 = ...   1.2 = ...   1.3 = ...   1.4 = ...   1.5 = ...   1.6 = ...
1.7 = ...   1.8 = ...   1.9 = ...   1.10 = ...  1.11 = ...

Étape 6.5 (lien Cooldown Manager, lignes affichées) :
hors combat = ...
en combat = ...
commande 4 = ...

Tests KO (numéro d'étape, ce que j'ai fait, ce que j'ai vu, erreur BugSack complète) :
- ...

Tests non faits :
- ...

Profilage (/wa pprint, 3 lignes les plus chères) :
- ...

Ce que je veux :
1. Corrige les tests KO, du plus grave au moins grave (🔴 d'abord), sans rien ajouter d'autre.
2. Si 1.9 et 1.10 sont true, code le trigger natif « Encounter Timeline » de la phase E, sinon ferme la phase E.
2b. Si l'étape 6.5 montre en combat un ID d'instance lisible, relie les auras secrètes du trigger Aura aux entrées du
    Cooldown Manager pour les reconnaître par ID de sort, avec une aide hors combat qui range les buffs voulus dans
    Tracked Buffs. Sinon, note la limite dans TUTORIAL.md.
3. Utilise wow-api pour toute API non vérifiée et relecteur avant de dire terminé.
4. Mets à jour CHANGES.md et coche dans TESTS-EN-JEU.md ce qui est corrigé.
5. Donne-moi à la fin la liste des tests à refaire en jeu.
```


Dump: value=select(4, GetBuildInfo())
[1]=16001,
[2]="",
[3]=" "
Dump: value=WOW_PROJECT_ID, WOW_PROJECT_MAINLINE
[1]=1,
[2]=1
Dump: value=C_SpecializationInfo and C_SpecializationInfo.GetSpecialization()
[1]=1
Dump: value=C_Secrets ~= nil, issecretvalue ~= nil` | `true, true
Dump: ERROR: [string "return C_Secrets ~= nil, issecretvalue ~= nil` | `true, true"]:1: '<eof>' expected near '`'
Dump: value=C_Secrets ~= nil, issecretvalue ~= nil` | `true, true`
Dump: ERROR: [string "return C_Secrets ~= nil, issecretvalue ~= nil` | `true, true`"]:1: '<eof>' expected near '`'
Dump: value=C_Secrets ~= nil, issecretvalue ~= nil
[1]=true,
[2]=true
Dump: value=C_CooldownViewer ~= nil
[1]=true
Dump: value=GetInventoryItemDurability(1)
empty result
Dump: value=C_Minimap.GetNumTrackingTypes()
[1]=23
Dump: value=GetInstanceInfo()
[1]="Kalimdor",
[2]="none",
[3]=0,
[4]="",
[5]=0,
[6]=0,
[7]=false,
[8]=1,
[9]=0,
[11]=false
Dump: value=C_EncounterTimeline and C_EncounterTimeline.IsFeatureAvailable()
[1]=false
Dump: value=C_EncounterTimeline and C_EncounterTimeline.IsFeatureEnabled()
[1]=false
Dump: value=C_Texture.GetAtlasInfo("RaidFrame-Icon-DebuffMagic") ~= nil
[1]=true

Total time: 39092.01ms ()
Time inside WA: 27.32ms (0.88ms)
Time spent inside WA: 0.07%

Note: Not every aspect of each aura can be tracked.
You can ask on our discord https://discord.gg/weakauras for help interpreting this output.

Auras:
Total time attributed to auras: 
Pre-pull checklist (Forever) 1.38ms, 64.82% (0.19ms)
Immolate timer (Forever) 0.57ms, 26.87% (0.28ms)
Low: Soul Shards 0.09ms, 4.35% (0.09ms)
Missing: Demon Skin / Armor 0.08ms, 3.95% (0.02ms)

Systems:
bufftrigger2 - OnUpdate 21.35ms, 78.16% (0.03ms)
load 2.36ms, 8.64% (0.88ms)
dynamicgroup 1.38ms, 5.06% (0.19ms)
generictrigger UNIT_SPELLCAST_SUCCEEDED player 0.53ms, 1.95% (0.30ms)
generictrigger PLAYER_TARGET_DIED 0.14ms, 0.52% (0.14ms)
generictrigger BAG_UPDATE_DELAYED 0.11ms, 0.39% (0.11ms)
bufftrigger2 - PLAYER_SOFT_ENEMY_CHANGED 0.09ms, 0.33% (0.04ms)
bufftrigger2 - PLAYER_TARGET_CHANGED 0.08ms, 0.31% (0.03ms)
bufftrigger2 - UNIT_FLAGS 0.06ms, 0.24% (0.01ms)
bufftrigger2 - NAME_PLATE_UNIT_REMOVED 0.04ms, 0.16% (0.02ms)
bufftrigger2 - NAME_PLATE_UNIT_ADDED 0.04ms, 0.16% (0.03ms)
bufftrigger2 - UNIT_AURA 0.04ms, 0.16% (0.01ms)
sound 0.03ms, 0.12% (0.00ms)
generictrigger NAME_PLATE_UNIT_REMOVED 0.03ms, 0.11% (0.01ms)
bufftrigger2 - PLAYER_ENTERING_WORLD 0.02ms, 0.09% (0.02ms)
generictrigger NAME_PLATE_UNIT_ADDED 0.02ms, 0.06% (0.01ms)
generictrigger WA_RESTRICTION_CHANGED 0.01ms, 0.02% (0.00ms)

LibGetFrame:
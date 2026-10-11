# Plan v2 du pack Paladin (2026-10-11)

Fichier interne, exclu du paquet par `.pkgmeta`. Format : `PLAN-AURAS-V2.md` section 6, point 1.

Règles reprises : aucun code custom, buffs et debuffs en `secretAura`, aucun son ni lueur sur valeur secrète, rien
d'affiché qui ne change pas une décision. Les IDs viennent de `Classes/Paladin.md` (DB2 1.60.1.70245). Les packs de
référence ne donnent que des idées : aucun nom, code ni chaîne repris.

États : **acquis** (type de trigger déjà testé en combat sur Forever), **à tester**, **bloqué**.
Le pack Paladin lui-même n'a jamais été joué : tout ID d'aura posée reste « à tester » même sur un trigger acquis.

## 1. Sources et spécialisations couvertes

Sources :

- `Classes/Paladin.md` : IDs de sorts, rangs, talents, présence sur Forever. Fait foi.
- `PackPaladin.lua` et `NOTES.md` : pack v1 et ses hypothèses d'ID.
- `RECHERCHE-AURAS-CLASSES.md` : les packs Classic du paladin tournent autour du swing timer avec fenêtre de twist
  de sceau, et des rappels sceau, bénédiction et aura manquants.
- `ANALYSE-AURAS-FOJJI.md` section 7 : sceau actif, Holy Shield, Light's Vigil, variantes sans Divine Favor et sans
  Light's Vigil, bénédictions.
- `ANALYSE-AURAS-LUXTHOS.md` et `ANALYSE-AURAS-WAGO.md` : gabarit de rangées, finition, alpha global, rappels. Idées
  seulement.
- Pack Luxthos Paladin (Classic Era), version 4, décodé et analysé dans `Tests/Packs/Paladin/ANALYSE-LUXTHOS.md` :
  même gabarit que le chaman, plus une barre de swing, une icône de sceau unique, des icônes à double état sur
  la cible ou l'allié, des rappels à trois comportements. Idées seulement.

Arbres Forever couverts (talents de `Classes/Paladin.md`) :

| Arbre | Talents clés pour le pack | Marqueur de chargement |
|---|---|---|
| Holy | Holy Shock, Divine Favor, Light's Vigil, Infusion of Light, Illumination (invisible) | `spellknown` Divine Favor 20216 |
| Protection | Holy Shield, Redoubt, Reckoning, Swift Judgement, Templar's Bulwark, Improved Righteous Fury | `spellknown` Holy Shield 20925 |
| Retribution | Seal of Command, Vengeance, Repentance, Sanctified Judgement, Sacred Arbiter | `spellknown` Seal of Command 20375 |

Styles de jeu :

- **Solo et leveling** : Retribution à deux mains. Sceau, Judgement, Holy Strike, Consecration, Hammer of Wrath,
  mana entre deux packs. Le chargement par `spellknown` gère les rangs bas.
- **Donjon** : tank Protection (Righteous Fury, Holy Shield, Consecration, Hammer of the Righteous) ou soigneur Holy
  (Holy Shock, Light's Vigil, bénédictions).
- **Raid** : soigneur Holy, tank Protection, Retribution en mêlée. Jugements de raid (Light, Wisdom) et bénédictions
  à garder à jour.

Le paladin n'a ni forme ni posture : les auras de paladin sont des buffs. Aucun chargement par forme.

## 2. Rangées

Racine `Paladin (Musca)`. Noms de rangées et coordonnées de `PLAN-AURAS-V2.md` section 2.

Légende des colonnes : « Déc. » = décision que l'aura change. Les conditions de style suivent la section 3 du plan
commun (grisé en recharge, rouge hors portée, bleu sans mana). Alpha 0,4 hors combat sans cible sur Principal et
Utilitaires, aura par aura.

### 2.1 Rappels (icônes 32, hors combat, cachés en zone de repos)

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Bénédiction manquante | Rebuffer avant le pull | `secretAura` player HELPFUL, absent | Might 19740, 19834-19838, 25291 ; Wisdom 19742, 19850, 19852-19854, 25290 ; Kings 20217 ; Salvation 1038 ; Light 19977-19979 ; Greater Might 25782, 25916 ; Greater Wisdom 25894, 25918 ; Greater Kings 25898 ; Greater Light 25890 ; Greater Salvation 25895 | classe | Icône pleine, texte « Bénédiction ». Caché en repos | à tester |
| Aura de paladin manquante | Choisir une aura | `secretAura` player HELPFUL, absent | Devotion 465, 10290, 643, 10291, 1032, 10292, 10293 ; Retribution 7294, 10298-10301 ; Concentration 19746 ; Shadow Resistance 19876, 19895, 19896 ; Frost Resistance 19888, 19897, 19898 ; Fire Resistance 19891, 19899, 19900 | classe | Idem. Les trois résistances comptent comme présentes | à tester |
| Righteous Fury manquant | Tanker sans menace | `secretAura` player, absent | 25780 | `spellknown` Holy Shield 20925 | Idem. Caché en repos | à tester |
| Symboles bas | Prévoir le prochain Greater Blessing ou Divine Intervention | Item Count | ID d'objet à lire en jeu | `spellknown` 25898 ou 19752 | Rappel texte (`entry.item`), seuil de quantité. Caché en repos | à tester |
| MANA BAS | Boire avant le pull | Power mana, Show only below (%) 20 | — | classe | Texte rouge. Caché en repos | acquis |

### 2.2 Effets (icônes 32 : procs, buffs courts, debuffs posés)

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Hammer of Wrath utilisable | Frapper sous 20 % | Action Usable, repli Health target sous 20 % | 24275, 24274, 24239 | `spellknown` 24275 | Lueur à l'apparition, grisé tant que le sort n'est pas utilisable. Rouge hors portée | à tester |
| Sceau actif (7 icônes, une par sceau) | Savoir quel sceau, quand le refaire | `secretAura` player HELPFUL | Righteousness 20154, 20287-20293, 21084 ; Crusader 21082, 20162, 20305-20308 ; Command 20375, 20915, 20918-20920, 20424 ; Wisdom 20166, 20356, 20357 ; Light 20165, 20347-20349 ; Justice 20164 ; Fury 1311649, 1311656, 20163, 20419, 20421-20423 | `spellknown` du rang 1 de chaque sceau | Pas de lueur (le sceau reste actif en permanence). Texte du temps en orange sous 5 s | à tester |
| Judgement of the Crusader | Maintenir le debuff de dégâts Holy | `secretAura` target HARMFUL, posé par le joueur | 20188, 20300-20303, 21183 (non départagés) | `spellknown` 21082 | Texte coloré sous 3 s | à tester |
| Judgement of Light | Soin au coup en raid | idem | 20185, 20344-20346 | `spellknown` 20165 | idem | à tester |
| Judgement of Wisdom | Mana au coup en raid | idem | 20186, 20354, 20355 | `spellknown` 20166 | idem | à tester |
| Judgement of Justice | Empêcher la fuite | idem | 20184 | `spellknown` 20164 | idem | à tester |
| Aucun sceau actif | Refaire un sceau en plein combat | `secretAura` player HELPFUL, toujours affiché, icône unique pour tous les sceaux de la ligne Sceau actif | IDs de la ligne Sceau actif | classe | Grisée à demi-alpha quand aucun sceau n'est posé, icône du sceau en cours sinon. Remplace le rappel hors combat (exclu, section 5) | à tester |
| Repentance posée | Suivre l'incapacité sur la cible | `secretAura` target HARMFUL, posé par le joueur | 20066 | `spellknown` 20066 | Texte coloré sous 2 s. Double état avec la recharge de 2.6 | à tester |
| Turn Undead posé | Suivre la fuite d'un mort-vivant | idem | 2878, 5627, 10326 | `spellknown` 2878 | Texte coloré sous 2 s | à tester |
| Étourdissement Hammer of Justice | Placer la suite pendant le stun | idem | 853, 5588, 5589, 10308 | `spellknown` 853 | Texte coloré sous 2 s | à tester |
| Holy Shield actif | Savoir s'il reste des charges | `secretAura` player, charges | 20925, 20927, 20928 | `spellknown` 20925 | Lueur, charges en texte | à tester |
| Redoubt | Le bloc est monté : encaisser | `secretAura` player | 20128 (talent 20127) ; ne pas utiliser 20132, absent du DB2 | `spellknown` 20127 | Lueur à l'apparition | à tester |
| Reckoning | Une attaque gratuite arrive | `secretAura` player | 20178 (talent 20177) | `spellknown` 20177 | Lueur. Retirer si aucune aura n'existe | à tester |
| Vengeance | Dégâts augmentés | `secretAura` player, charges | 20050 (talent 20049, IDs de charges inconnus) | `spellknown` 20049 | Lueur, charges en texte | à tester |
| Divine Favor actif | Lancer le soin critique garanti | `secretAura` player | 20216 | `spellknown` 20216 | Lueur à l'apparition | à tester |
| Infusion of Light | Holy Light moins chère et plus rapide | `secretAura` player | candidats 53672, 426065, 426179, 437063, 437877 | talent (ID à choisir) | Lueur, fenêtre 15 s | à tester |

### 2.3 Principal (icônes 44, 8 au plus)

Chargement par `spellknown` du sort. Tous les rangs d'un sort partagent une aura (Cooldown Progress, nom ou liste
d'IDs). Ordre commun à tous les variants : Judgement, Holy Shield, Holy Strike, Hammer of the Righteous,
Consecration, Holy Shock, Light's Vigil, Divine Favor.

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Judgement | Lancer dès que prêt | Cooldown Progress (Spell) | 20271 | classe | Grisé en recharge, rouge hors portée, bleu sans mana | acquis |
| Holy Shield | Tenir le bouclier actif | idem | 20925, 20927, 20928 | `spellknown` 20925 | idem | acquis |
| Holy Strike | Frappe sacrée de rotation | idem | 679, 678, 1866, 680, 2495, 5569, 10332, 10333 | `spellknown` 679 | idem | acquis |
| Hammer of the Righteous | Frappe de zone | idem | 407632 | `spellknown` 407632 | idem | acquis |
| Consecration | Poser la zone | idem | 26573, 20116, 20922, 20923, 20924 | `spellknown` 26573 | idem. Cible hostile non requise | acquis |
| Holy Shock | Dégât ou soin instantané | idem | 1311606, 20473, 20929, 20930 | `spellknown` 1311606 | idem | acquis |
| Light's Vigil | Soin de zone, 30 s | idem | 1310911, 1311590, 1311595 | `spellknown` 1310911 | idem | acquis |
| Divine Favor | Préparer le gros soin | idem | 20216 | `spellknown` 20216 | idem. Lueur pendant l'effet : voir 2.2 | acquis |

Maximum simultané : 8 (tous les talents connus). Par spécialisation type : Retribution 4 à 5, Protection 5, Holy 7.

### 2.4 Débordement (icônes 36)

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Exorcism | Mort-vivant ou démon seulement | Cooldown Progress | 879, 5614, 5615, 10312-10314 | `spellknown` 879 | Grisé, rouge hors portée | acquis |
| Holy Wrath | Rafale de zone sur mort-vivants | idem | 2812, 10318 | `spellknown` 2812 | idem | acquis |
| Swift Judgement | Judgement gratuit, menace | idem | 1310994 | `spellknown` 1310994 | idem | acquis |

### 2.5 Ressource, Secondaire, Incantation (barres)

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Barre de mana 390x18 | Soigner ou lancer maintenant | Power mana, texte `%p` | — | classe | Bleue. Couleur du texte par seuil de pourcentage : bloqué, la mana est secrète et la condition reste fausse | acquis (barre), bloqué (seuil) |
| Swing main hand 390x10 | Placer le twist de sceau | Swing Timer main hand | — | `spellknown` Seal of Command 20375 ou Holy Shield 20925 | Barre unie, couleur atténuée hors combat par condition native. Fenêtre de twist : voir section 5 | acquis |
| Règle des 5 s 390x10 | Régénérer la mana | Spell Cast Succeeded, durée fixe 5 s, sorts à mana par nom, tous rangs | Holy Light, Flash of Light, Holy Shock, Light's Vigil, Cleanse, Purify, Lay on Hands, sceaux, bénédictions, Judgement, Consecration, Exorcism | `spellknown` Divine Favor 20216 | Barre pâle, vide hors des 5 s | à tester |
| Incantation 390x16 | Voir le cast en cours | Cast du joueur (à vérifier) | Holy Light, Flash of Light, Holy Wrath, Hammer of Wrath, Redemption | classe | Visible pendant le cast seulement | à tester |

### 2.6 Utilitaires (icônes 32)

Alpha 0,4 hors combat sans cible. Le paladin n'a pas d'interruption : Hammer of Justice est son seul contrôle de cast.

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Hammer of Justice | Stun ou interruption | Cooldown Progress | 853, 5588, 5589, 10308 | `spellknown` 853 | Grisé, rouge hors portée | acquis |
| Divine Protection | Défensif court | idem | 498, 5573 | `spellknown` 498 | Grisé. Double état : voir section 9 | acquis |
| Divine Shield | Immunité totale | idem | 642, 1020 | `spellknown` 642 | Grisé. Double état | acquis |
| Lay on Hands | Sauver une cible | idem | 633, 2800, 10310 | `spellknown` 633 | Grisé | acquis |
| Blessing of Protection | Immunité physique alliée | idem | 1022, 5599, 10278 | `spellknown` 1022 | Grisé. Double état, buff lu sur l'allié (groupe) : `secretAura` hors du joueur, à tester | acquis |
| Blessing of Freedom | Briser un ralentissement | idem | 1044 | `spellknown` 1044 | Grisé. Double état sur l'allié (groupe), à tester | acquis |
| Templar's Bulwark | Absorption de crise | idem | 1311015 | `spellknown` 1311015 | Grisé | acquis |
| Repentance | Contrôle d'un humanoïde | idem | 20066 | `spellknown` 20066 | Grisé, rouge hors portée. Double état sur la cible : voir 2.2 | acquis |
| Voice of Truth | Immunité silence et interruption | idem | 1310897 | `spellknown` 1310897 | Grisé | acquis |
| Turn Undead | Contrôle de morts-vivants | idem | 2878, 5627, 10326 | `spellknown` 2878 | Grisé, rouge hors portée. Double état sur la cible : voir 2.2 | acquis |
| Divine Intervention | Sauver un allié en raid | idem | 19752 | `spellknown` 19752 | Grisé | acquis |
| Forbearance | Savoir quand une immunité est refusée | `secretAura` player HARMFUL | 25771 | classe | Texte du temps ; lueur rouge à l'apparition | à tester |

### 2.7 Entretien (icônes 32 : buffs longs)

| Aura | Déc. | Trigger | IDs | Chargement | Conditions et style | État |
|---|---|---|---|---|---|---|
| Bénédiction sur soi | Rebuffer avant l'expiration | `secretAura` player HELPFUL | liste de 2.1 | classe | Texte orange sous 5 min | à tester |
| Aura de paladin active | Voir l'aura portée | idem | liste de 2.1 | classe | Icône de l'aura portée | à tester |
| Righteous Fury | Durée restante | idem | 25780 | `spellknown` 20925 | Texte orange sous 5 min | à tester |

## 3. Variantes par spécialisation, forme, posture ou talent

Aucune forme ni posture. Les variantes se chargent par `spellknown`, aura par aura :

- **Retribution** : Seal of Command (Effets), barre de swing (Secondaire). Vengeance, Repentance.
- **Protection** : Holy Shield (Principal et Effets), Righteous Fury (Rappels, Entretien), barre de swing, Redoubt,
  Reckoning, Templar's Bulwark, Swift Judgement.
- **Holy** : Divine Favor, Light's Vigil, Infusion of Light, barre de règle des 5 s (remplace la barre de swing).
- **Commun** : Judgement, Consecration, Holy Strike, Hammer of the Righteous, sceaux, bénédictions, défensifs.
- Les rangs partagent une aura. Les rangs hauts ne s'ajoutent pas : une aura par sort, liste d'IDs.
- Hybrides : plusieurs marqueurs peuvent être connus. Principal reste à 8 au plus (section 2.3).

## 4. Rappels

| Rappel | Trigger | Hors combat | Masqué en zone de repos |
|---|---|---|---|
| Bénédiction | `secretAura` absent, tous rangs et Greater | oui | oui |
| Aura de paladin | `secretAura` absent, résistances incluses | oui | oui |
| Righteous Fury | `secretAura` absent, si Holy Shield connu | oui | oui |
| Symboles bas | Item Count sous seuil | oui | oui |
| MANA BAS | Power mana sous 20 % | oui | oui |

Chaque rappel se charge « hors combat » et disparaît au pull. Option de masquage en repos : à vérifier dans Musca
(`PLAN-AURAS-V2.md` section 5, point 5).

## 5. Éléments exclus ou bloqués

| Élément | Raison |
|---|---|
| Crusader Strike | absent du DB2, exclu |
| Divine Storm | absent du DB2, exclu |
| Redoubt 20132 | absent du DB2, exclu (Redoubt suivi par 20128) |
| Avenging Wrath | absent du DB2, exclu (407788 apparaît seulement comme déclencheur de Forbearance : à confirmer) |
| Blessing of Sanctuary, Greater Blessing of Sanctuary | absent du DB2, exclu |
| Illumination | proc sans aura visible (20210 déclenche 18350 « Dummy Trigger »), aucune décision |
| Fenêtre de twist exacte (0,4 s avant le coup) | bloqué : exige de lire le temps de swing restant, valeur secrète en combat. Repli : barre de swing seule |
| Compteur de procs sans aura (Reckoning charges, Vengeance cumuls) | bloqué : journal de combat |
| Sceau manquant hors combat | exclu : un sceau dure 30 s, il manquerait en permanence. En combat, l'icône unique de 2.2 reste permise |
| Aura de Holy Shock 88819 (lueur de proc) | absent du DB2 Forever : pas de lueur sur le soin instantané, le sort reste en Principal |
| Sanctity Aura 20218, Sanctuary 20911, Greater Sanctuary 25899 | absents du DB2 (20911 est un talent Protection sans nom) : hors des listes de rappel |
| Blessing of Salvation en icône de recharge | exclu : aucune recharge, aucune décision à afficher (comme Blessing of Sacrifice) |
| Blessing of Sacrifice | exclu : aucune recharge, aucune décision à afficher |
| Cleanse, Purify | exclus : aucune recharge ; le statut des alliés n'est pas lisible en combat |
| Redemption | exclu : rappel de mort, aucune recharge |
| Tic de mana, règle des 5 s déduite des coups reçus | bloqué : journal de combat |

## 6. IDs à confirmer en jeu

- **Aura posée par chaque sceau, bénédiction, aura de paladin, Righteous Fury, Divine Shield, Divine Protection,
  Blessing of Protection, Holy Shield.** Le DB2 confirme APPLY_AURA, pas l'ID de l'aura posée. À vérifier : ID réel
  sur le joueur après le lancer (`/run` sur `C_UnitAuras`, lecture hors combat), pour chaque rang.
- **Judgement of the Crusader.** Candidats 21183, 20188, 20300-20303, 25942, 25943, 456496. À vérifier : l'ID
  présent sur la cible après Judgement avec Seal of the Crusader.
- **Judgement of Light et Wisdom.** 20185/20344-20346 et 20186/20354/20355 vus. À vérifier : debuff sur la cible et
  filtre « posé par le joueur » dans un groupe avec un autre paladin.
- **Judgement of Fury (taunt de Seal of Fury).** IDs 20231, 20415, 20411, 20416-20418 (sorts déclenchés), 1311647,
  1311654. À vérifier : aura de taunt sur la cible, pour décider d'un suivi.
- **Hammer of Justice.** Les IDs de rang servent d'ID d'étourdissement. À vérifier : 20170 est le stun du Seal of
  Justice, pas celui de Hammer of Justice.
- **Holy Shock rang 1.** 1311606 ou 20473. À vérifier : le sort connu en jeu avec le talent, pour `spellknown`.
- **Vengeance.** 20050 est le rang 1. À vérifier : les IDs de charge (talent 20049, 20056-20059).
- **Redoubt 20128 et Reckoning 20178.** Reliés par le nom. À vérifier : buff réel sur le joueur, existence d'une
  aura pour Reckoning. Ne pas utiliser 20132, absent du DB2 (section 5).
- **Infusion of Light.** Cinq candidats non départagés. À vérifier : l'ID de l'aura sur le joueur après un crit.
- **Divine Favor 20216.** À vérifier : l'aura de 2 min existe avec cet ID.
- **Forbearance 25771.** À vérifier : posée par Divine Shield, Divine Protection, Blessing of Protection, Lay on
  Hands et Templar's Bulwark.
- **Item de Symbole (Kings, Divinity).** ID à lire en jeu.

## 7. Tests en jeu propres au paladin

À ajouter à la grille de `PLAN-AURAS-CLASSES.md` section 4 :

1. Twist de sceau : changer de sceau pendant le combat ; l'icône de sceau suit, la barre de swing reste juste.
2. Judgement : le bon debuff apparaît sur la cible. Le debuff d'un autre paladin ne s'affiche pas.
3. Hammer of Wrath : l'icône apparaît seulement sous 20 % et se grise en recharge.
4. Holy Shield : charges visibles, lueur à l'apparition, fin à zéro charge ou à 10 s.
5. Forbearance : visible après Divine Shield, l'icône de recharge confirme l'immunité refusée.
6. Bénédictions : rappel absent avec n'importe quel rang, Greater, ou une bénédiction d'un autre paladin.
7. Aura de paladin : le rappel disparaît avec une aura de résistance.
8. Righteous Fury : rappel chargé en Protection seulement.
9. Règle des 5 s : la barre redémarre sur un sort à mana, y compris une bénédiction.
10. Changement de spécialisation par talents : chargement des variantes sans `/reload`.
11. Icône de sceau unique : visible et grisée sans sceau, icône du sceau en cours après un lancer, y compris en combat.
12. Double état sur cible ou allié : Hammer of Justice, Repentance, Turn Undead, Blessing of Protection, Blessing of Freedom.

## 8. Écart avec la v1 (`PackPaladin.lua`)

**Ajouter**

- Rangées complètes : Effets, Principal, Débordement, Utilitaires, Entretien.
- Judgement of Fury : suivi à décider (section 6), non ajouté d'office.
- Forbearance (debuff joueur), Templar's Bulwark, Voice of Truth, Light's Vigil, Swift Judgement, Holy Wrath,
  Divine Intervention, Turn Undead.
- Reckoning, Infusion of Light (à tester).
- Résistances dans le rappel d'aura, Blessing of Salvation et Light dans le rappel de bénédiction (la v1 les ignore,
  donc le rappel s'affiche à tort).
- Barre d'incantation.
- Bénédiction sur soi, aura active, Righteous Fury durée (Entretien).
- Rappel de Symboles (Item Count).
- Règle des 5 s : liste complète des sorts à mana.
- Seuils de temps restant et lueur à l'apparition d'un proc.

**Changer**

- Hammer of Wrath : de « procs » vers Effets, avec repli Health sous 20 % si Action Usable échoue.
- Sceaux : un par sceau en Effets, sans lueur, pas dans une rangée de buffs.
- Divine Favor : une seule aura (recharge dans Principal, buff dans Effets), chargée seulement pour Holy.
- Barre de swing : chargée selon la spécialisation, plus pour Holy.
- Exorcism et Holy Wrath en Débordement. Divine Protection, Divine Shield, Blessing of Protection : double état
  (section 9).
- MANA BAS : rappel texte montré sous le seuil par le seuil natif ; couleur de barre bloquée.

**Retirer**

- Aura « Divine Shield (actif) » séparée si le double état fonctionne. Sinon, la garder.
- Hammer of Justice dans les debuffs de cible, remplacé par l'étourdissement en Effets avec seuil de temps.
- Divine Favor et Repentance dans une rangée « cooldowns » à plat : répartis selon 2.3 et 2.6.

## 9. Besoins du générateur propres au paladin

Besoins réels, absents de la section 5 de `PLAN-AURAS-V2.md` :

1. **Marque sur la barre de swing.** Repère de fenêtre de twist. Seulement si le trigger Swing Timer expose un temps
   restant lisible ; sinon le besoin tombe (élément bloqué en section 5).
2. **Liste d'IDs de plusieurs rangs dans une seule aura de rappel « absent »**, avec condition « présent » si l'un
   des rangs est actif. Le générateur le fait déjà pour la v1 ; garder le comportement.
3. **Double état (recharge puis durée du buff).** Déjà au point 8 de la section 5. Le paladin en a besoin pour
   Divine Shield, Divine Protection et Blessing of Protection.
4. **Chargement par `spellknown` sur plusieurs marqueurs** (Seal of Command ou Holy Shield pour la barre de swing).
   Si Musca n'a pas de « OU », dupliquer l'aura par marqueur.

5. **Aura toujours affichée, grisée à demi-alpha si absente** (`secretAura` avec liste d'IDs) : sceau actif unique.
   Le point 3 de la section 5 du socle couvre les totems ; celui-ci porte sur un buff.
6. **Double état sur la cible ou l'allié.** Recharge du sort et `secretAura` sur `target` ou sur le groupe
   (Hammer of Justice, Repentance, Turn Undead, Blessing of Protection, Blessing of Freedom). Étend le point 3.
7. **Couleur de barre selon le combat.** Barre de swing atténuée hors combat, par condition native.

Pas de besoin : segments de points de combo, barre de familier, indicateur de posture, coup en file d'attente.

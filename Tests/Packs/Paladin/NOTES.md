# Pack paladin (Forever) — notes

Générateur : `PackPaladin.lua` (builder `../PackBuilder.lua`), chaîne d'import : `PackPaladin.txt`. IDs tous issus de `Classes/Paladin.md` (DB2 1.60.1.70245).

```
PACK=Tests/Packs/Paladin/PackPaladin.lua TEMP=$TMPDIR WOW_UI_SOURCE=$HOME/wow-ui-source/forever lua Tests/run.lua --scenario Tests/Packs/VerificationPack.lua
lua Tests/Packs/AuraTool.lua . encode Tests/Packs/Paladin/PackPaladin.lua > Tests/Packs/Paladin/PackPaladin.txt
```

## Contenu

- Proc : Hammer of Wrath (Action Usable, cible sous 20 %).
- Rotation : Judgement, Holy Strike, Hammer of the Righteous, Consecration, Exorcism, Holy Shock, Holy Shield (talents chargés seulement si connus).
- Cooldowns : Hammer of Justice, Divine Shield, Divine Protection, Lay on Hands, Blessing of Protection, Blessing of Freedom, Divine Favor, Repentance, Holy Wrath (2812), Turn Undead (2878), Divine Intervention (19752). Chaque sort ne se charge que s'il est appris (rang 1).
- Buffs : un par sceau (Righteousness, Crusader, Command, Wisdom, Light, Justice, Fury), Righteous Fury, Divine Favor (actif), Holy Shield (actif) (charges), Divine Shield (actif), Divine Protection (actif) (498, 5573), Vengeance (charges), Redoubt.
- Debuffs cible : Judgement of the Crusader / Light / Wisdom / Justice, Hammer of Justice (étourdissement).
- Barres : mana, swing main (sceau twisting), règle des 5 s (soins, Holy Shock, Exorcism, Consecration, Hammer of Wrath, Judgement, sceaux, par nom).
- Rappels hors combat : bénédiction manquante (Might, Wisdom, Kings et versions Greater, tous rangs), aura de paladin manquante (Devotion, Retribution, Concentration), Righteous Fury manquant (chargé si Holy Shield connu, donc Protection), MANA BAS sous 20 %.

## IDs à confirmer en jeu

- Aura posée par chaque sceau, bénédiction, aura de paladin, Divine Shield, Holy Shield, Righteous Fury : hypothèse = ID du sort lancé (le DB2 confirme seulement APPLY_AURA). Candidats ajoutés : 21084 (Seal of Righteousness), 20424 (Seal of Command).
- Judgement of the Crusader : 21183 et 20188, 20300-20303 non départagés (tous listés).
- Hammer of Justice : IDs des rangs utilisés comme ID d'aura d'étourdissement.
- Vengeance 20050 (rang 1 ; IDs des cumuls inconnus) et Redoubt 20128 (liés au talent par le nom/proximité seulement).
- Holy Shock rang 1 : 1311606 (20473 = rang 2 / talent).

## Absent ou écarté

- Absents de Forever (fichier) : Crusader Strike, Divine Storm, Avenging Wrath, Blessing of Sanctuary. Aucun n'est dans le pack.
- Écartés : Lay on Hands (armure).
- Écarts Quazii écartés : runes SoD absentes du fichier (Crusader Strike, Divine Storm, Avenger's Shield, Rebuke, Hand of Reckoning, Divine Sacrifice, Horn of Lordaeron, procs SoD) ; Forbearance qui grise les bulles ; Exorcism / Holy Wrath selon le type de créature et Art of War (custom, overlay) ; texte unique de l'aura active (custom, API secrète).
- Absents du pack : Templar's Bulwark, Swift Judgement, Blessing of Salvation/Light/Sacrifice.

## À tester en jeu

- Action Usable de Hammer of Wrath (apparaît sous 20 % seulement).
- Aura de chaque sceau en combat (ID réel) et changement de sceau (twisting) avec la barre de swing.
- Debuffs de jugement sur la cible en combat (ID de Judgement of the Crusader).
- Rappel de bénédiction : se déclenche avec n'importe quel rang et les versions Greater.
- Righteous Fury : n'apparaît qu'avec Holy Shield connu.
- Règle des 5 s : se relance sur les sorts listés (correspondance par nom).
- Holy Wrath, Turn Undead, Divine Intervention : icônes de recharge visibles seulement une fois le sort appris.
- Divine Protection (actif) : icône pendant la bulle (ID d'aura 498 / 5573 supposé = ID du sort).

## Pack 1.11.0 (2026-10-18), à tester en jeu
- Barre de mana rouge sous 30 % par une condition sur le pourcentage secret, en combat aussi ; plus de copie rouge superposée (la variante ForeverAuras la garde).
- Texte « Not in melee range » (Holy Strike 679, ID à confirmer sur Forever) : chargé en combat, caché à portée, affiché hors de portée (condition `spellInRange` sur l'alpha). Absent de la variante ForeverAuras.
- Rappel « Missing: Seal » : chargé en combat seulement, affiché quand aucun sceau n'est actif.
- Limite : en combat, sans sceau et sous 20 % de mana, le 2e rappel empilé peut recouvrir le texte de portée.

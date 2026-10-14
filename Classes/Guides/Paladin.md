# Guides Paladin – WoW Forever (patch 1.60.1, bêta, niveau max 30)

Synthèse personnelle (notes reformulées) pour Musca-Auras. IDs issus de `Classes/Paladin.md` uniquement.

## Sources lues

Icy Veins :
- https://www.icy-veins.com/wow-forever/paladin-class-overview — Last Updated Sep 20, 2026 — Meyra, Mytholxgy
- https://www.icy-veins.com/wow-forever/retribution-paladin-melee-dps-pve-guide — Last Updated Oct 7, 2026 — Meyra
- https://www.icy-veins.com/wow-forever/protection-paladin-tank-pve-guide — Last Updated Oct 1, 2026 — Mytholxgy
- https://www.icy-veins.com/wow-forever/holy-paladin-healer-pve-guide — Last Updated Oct 1, 2026 — Mytholxgy

Wowhead (base `https://www.wowhead.com/forever/guide/classes/paladin/`) :
- `holy/overview-pve-healer` — Harreks — 2026/10/07
- `holy/healer-abilities` — Harreks — 2026/10/08
- `holy/level-20-healer-overview` — Harreks — 2026/09/29
- `holy/level-30-healer-overview` — Harreks — 2026/10/06
- `protection/overview-pve-tank` — Riyani — 2026/10/07
- `protection/tank-abilities` — Riyani — 2026/10/08
- `protection/level-20-tank-overview` — Riyani — 2026/09/29
- `protection/level-30-tank-overview` — Riyani — 2026/10/06
- `retribution/overview-pve-dps` — Surveillant — 2026/10/08
- `retribution/dps-abilities` — Surveillant — 2026/10/08
- `retribution/level-20-dps-overview` — Surveillant — 2026/09/29
- `retribution/level-30-dps-overview` — Surveillant — 2026/10/08

URLs absentes ou en échec : aucune (16 pages lues sur 16).

## Notes communes à la classe

- Les bénédictions durent 1 h au lieu de 5 min. Les buffs de camp (Lodestone, Fish Bowl, Mana Well) ne se cumulent pas avec la bénédiction équivalente.
- Le Jugement (Judgement (20271)) ne consomme plus le sceau. Un seul Jugement actif par cible.
- Forbearance (25771) : debuff après Divine Shield, Lay on Hands, Templar's Bulwark, etc.
- Paladin mort-vivant nouveau côté Horde. Racials remaniés (épée +2 % crit Humain, masse +1 % crit Nain).
- Sorts à puissance des sorts : sceaux, Jugement, Holy Strike, Consécration.

---

## Rétribution (DPS mêlée)

### Rotation / priorité

Niveau 30 (max) :
1. Optionnel, cible longue : Seal of the Crusader (21082) puis Judgement (20271) pour le debuff Judgement of the Crusader, puis retour au sceau principal.
2. Sceau principal actif en permanence : Seal of Righteousness (20154) ou Seal of Command (20375). Le renouveler à l'expiration.
3. Judgement (20271) à chaque recharge (macro possible avec Holy Strike).
4. Holy Strike (679) à chaque recharge.
5. Consecration (26573) seulement si 3-4 ennemis ou plus (coûteux en mana).
6. Exorcism (879) sur Mort-vivant et Démon.
7. Hammer of Justice (853) sur cible dangereuse.
8. Variante Shockadin : Holy Shock (1311606) à chaque recharge (problèmes de mana au 30 selon Wowhead).

Niveau 20 : même liste sans Sacred Arbiter, Vengeance reformée, ni Holy Shock. Consecration disponible dès 20. Judgement of the Crusader en ouverture si le combat dure.

Niveau 20 : conseil Wowhead, Seal of Command pas vraiment meilleur que Righteousness.

### Procs et buffs à suivre

- Seal of Righteousness (20154) / Seal of Command (20375, proc 20424) / Seal of the Crusader (21082) : sceau actif.
- Vengeance (20050) : buff empilable (3 fois) après un coup critique non périodique, 30 s.
- Retribution Aura (7294) sur soi/groupe.
- Blessing of Might (19740) ou Blessing of Kings (20217) ; Greater Blessing of Might (25782).
- Sacred Arbiter (1311087) : Holy Strike rafraîchit tous les Jugements sur la cible.
- Divine Favor (20216) et Illumination (20210) si build Holy.

### Debuffs à maintenir sur la cible

- Judgement of the Crusader : ID ambiguë dans `Classes/Paladin.md` (21183 ou 20188, rangs 20300-20303).
- Judgement of Righteousness (20187), Judgement of Command (20425), Judgement of Light (20185), Judgement of Wisdom (20186), Judgement of Justice (20184).
- Une seule Judgement active à la fois sur la cible. Sacred Arbiter garde le Jugement en vie via Holy Strike.

### Recharges importantes

- Judgement (20271) : 10 s. Holy Strike (679) : 10 s. Exorcism (879) : 15 s. Consecration (26573) : 8 s. Holy Shock (1311606) : 10 s. Hammer of Justice (853) : 1 min. Repentance (20066) : 1 min. Blessing of Freedom (1044) : 20 s. Blessing of Protection (1022) : 5 min. Lay on Hands (633) : 20 min (voir désaccords).
- Pas de gros cooldown de dégâts (pas d'Avenging Wrath dans les guides).

### Ressources

- Mana : petite réserve, la Rétribution peut manquer de mana. Consecration chère.
- Benediction (20101) et Sanctified Judgement (1311074 ou 1311077 : ID ambiguë) rendent du mana. Sanctified Judgement rend du mana à chaque Jugement.
- Pas d'interruption, pas de gap closer. Mobilité : Pursuit of Justice (26022) et Blessing of Freedom (1044).

### Talents clés qui changent le jeu

- Niveau 30, build 0/0/21 : Benediction (20101), Conviction (20117), Sanctified Judgement, Pursuit of Justice (26022), Sacred Arbiter (1311087), Seal of Command (20375), Improved Judgement (25956), Vengeance (20049), Repentance (20066), Two-Handed Weapon Specialization (20111).
- Points Legacy (talent Talented : +5 points) : Vengeance 3/3, Two-Handed Weapon Specialization 2/3, Champion of the Light (1311084, ID partielle) 1/3, convertit une part de l'Intelligence en dégâts de sorts.
- Holy Conduit (1237268, ID partielle) cité par Icy Veins.
- Deux builds évoqués : Shockadin (Holy Shock + Champion of the Light, plus fort en PvE selon Wowhead niv. 20) et Seal Twist (Twist of Light, meilleur en burst PvP).

### Mécaniques propres à Forever

- Twist of Light (1310735) : capstone. Changer de sceau transforme l'ancien en « Echo » appliqué à l'attaque suivante (deux sceaux sur un swing). Hors de portée au niveau 30. Contesté par les joueurs.
- Holy Strike (679) : équivalent de Crusader Strike, dès le niveau 6, cooldown de base 10 s.
- Judgement hors GCD ; Judgement ne consomme plus le sceau.
- Swift Judgement (1310994) : présent dans la liste de sorts.
- Holy Shock apprenable dès le 30 (au lieu de 40), 160 mana, 10 s.
- Seal of Command : 70 % des dégâts d'arme ; Judgement double sur cible étourdie ou incapacitée (Hammer of Justice ou Repentance avant le Jugement).
- Seal of the Crusader : +40 % vitesse d'attaque, -40 % dégâts d'arme.
- Sorts de puissance des sorts : l'équipement de puissance des sorts rivalise avec la Force.

---

## Protection (tank)

### Rotation / priorité

Niveaux 20 et 30 (identiques d'après Wowhead) :
- Cible unique : Seal of Fury (1311649 rang 1, 1311656 rang 2) permanent, Judgement (20271), Exorcism (879) sur Mort-vivant et Démon, Holy Strike (679), Consecration (26573) si le mana le permet.
- Zone : Seal of Fury, Consecration (26573), Judgement, Exorcism, Holy Strike.
- Icy Veins : Seal of Fury toujours, Consecration selon le mana, Judgement pour menace et taunt, Holy Strike à chaque recharge.
- Avant le pull : Righteous Fury (25780) et Retribution Aura (7294) dès le niveau 16 ; Seal of the Crusader (21082) pour le premier Jugement contre Mort-vivant et Démon.

### Procs et buffs à suivre

- Righteous Fury (25780) : permanent (bonus de menace : non indiqué).
- Seal of Fury (1311649) : 30 s, +10 % de puissance des sorts Sacré sur coups en mêlée ; absorbe 50 % des dégâts avec bouclier.
- Holy Shield (20925) : blocage +20 %, 10 s, dégâts Sacré par blocage, menace +20 %.
- Redoubt (20128 le proc) : 10 % de chance, blocage +30 % pendant 10 s ou 5 blocs.
- Reckoning (20178) : 40 % d'attaque supplémentaire sur blocage.
- Retribution Aura (7294) ou Devotion Aura (465). Concentration Aura (19746) : 35 % de chance d'ignorer le recul.
- Blessing of Might (19740) sur le groupe. Blessing of Salvation (1038) niveau 26 : règle la menace en donjon.
- Iron Creed (1311033 ou 1311034) : -15 % dégâts subis 6 s avec Righteous Fury.

### Debuffs à maintenir sur la cible

- Judgement of Fury (20411) : taunt 4 s au Jugement.
- Judgement of Justice (20184), Judgement of Light (20185), Judgement of the Crusader (ID ambiguë, voir plus haut). Un seul à la fois.
- Seal of Justice (20164) : chance d'étourdir et empêche la fuite. Seal of Light (20165) : soigne les attaquants.

### Recharges importantes

- Templar's Bulwark (1311015) : 5 min, absorbe 100 % des PV max pendant 8 s, Forbearance (25771) 1 min. Seul cooldown défensif utilisable sans perdre la menace.
- Divine Protection (498) : 5 min. Divine Shield (642) : 5 min. Lay on Hands (633). Blessing of Protection (1022) : 5 min. Blessing of Freedom (1044) : 20 s. Divine Intervention (19752) : 1 h.
- Holy Shield (20925) : 10 s. Judgement (20271) : 10 s. Holy Strike (679) : 10 s. Exorcism (879) : 15 s. Consecration (26573) : 8 s. Hammer of Justice (853) : 1 min. Hammer of Wrath (24275) : 6 s.
- Swift Judgement (1310994) : 1 min, réinitialise Judgement et rend le suivant gratuit.

### Ressources

- Mana. Shield Specialization (20148) : un blocage rend 6 % du mana max, une fois toutes les 3 s.
- Improved Seal of Fury (1314103 ou 1314104) : rend 60 mana quand le bouclier est entièrement absorbé.
- Lay on Hands vide tout le mana du paladin.

### Talents clés qui changent le jeu

- Redoubt (20127), Precision (20189), Anticipation (20096), Shield Specialization (20148), Improved Seal of Fury, Reckoning (20177), Improved Righteous Fury (20468), Toughness (20143), Guardian's Favor (20174), One-Handed Weapon Specialization (20196), Improved Hammer of Justice (20487).
- Sacred Duty (1224697, ID partielle) : +4 % Endurance, -60 s sur Divine Shield, Divine Protection et Templar's Bulwark.
- Holy Conduit (1237268, ID partielle) via l'arbre Rétribution (Icy Veins).

### Mécaniques propres à Forever

- Seal of Fury : sceau de tank (taunt 4 s au Jugement, absorption avec bouclier).
- Templar's Bulwark (1311015), Swift Judgement (1310994), Iron Creed, Sacred Duty : nouveaux.
- Consecration refaite : 64 dégâts sur 8 s plus bonus pour les 4 premiers ennemis (9,5 % SP x 8).
- Holy Strike 42 % des dégâts d'arme, Voice of Truth (1310897) 3 min.
- Bug de bêta signalé : Seal of Fury rend du mana via Improved Seal of Fury même sans le talent ; dégâts de Consecration incohérents au bord du rayon ; Reckoning possiblement cassé (ICD 1,5 s ajouté).
- Lay on Hands : soigne le max de PV, rend 550 mana à la cible, vide le mana du paladin.

---

## Sacré (soigneur)

### Rotation / priorité

Niveau 20 (Wowhead) : Seal of Righteousness (20154), Judgement (20271), Holy Strike (679), Consecration (26573) pour les dégâts ; Flash of Light (19750) comme soin principal après le niveau 20.

Niveau 30, soigneur : Judgement (20271) avec Seal of Light (20165) pour Judgement of Light (20185), Holy Shock (1311606), Flash of Light (19750) ou Holy Light (635).

Niveau 30, dégâts : Seal of Righteousness, Judgement, Holy Strike, Exorcism (879) sur Mort-vivant et Démon, Holy Shock, Consecration.

Icy Veins : Flash of Light pour la plupart des soins, Holy Light pour les gros soins, Holy Shock instantané, Lay on Hands (633) en urgence.

### Procs et buffs à suivre

- Seal of Light (20165) / Seal of Wisdom (20166).
- Divine Favor (20216), Illumination (20210), Infusion of Light (IDs candidates 53672, 426065, 426179, 437063, 437877 : ambiguë).
- Blessing of Might (19740) et Blessing of Wisdom (19742) ; Devotion Aura (465) ou Retribution Aura (7294) ; Concentration Aura (19746).
- Light's Vigil (1310911) : buff 30 s, le prochain Holy Shock sur la cible ne déclenche pas de recharge et soigne le groupe. Sur un ennemi : dégâts Sacré et remboursement de 75 % du coût.

### Debuffs à maintenir sur la cible

- Judgement of Light (20185) et Judgement of Wisdom (20186), 40 s selon `Classes/Paladin.md` ; les auto-attaques les rafraîchissent.
- Holy Strike (679) applique Voice of Truth (1310897), 6 s.

### Recharges importantes

- Holy Shock (1311606) : 10 s. Light's Vigil (1310911) : 6 s. Lay on Hands (633) : 20 min. Divine Shield (642) : 5 min. Divine Protection (498) : 5 min. Blessing of Protection (1022) : 5 min. Judgement (20271) : 10 s. Holy Strike (679) : 10 s. Consecration (26573) : 8 s. Divine Favor (20216).
- Light's Vigil arrive niveau 40 selon Wowhead (non disponible en bêta 30).

### Ressources

- Mana. Reverence (1310899, ID partielle) : régénération en lançant des sorts. Divine Intellect (20257), Illumination (20210), Spiritual Focus (20205). Lay on Hands vide tout le mana.
- Holy Shock coûte 160 mana (niveau 30) : faible rendement par mana selon un commentaire Wowhead.

### Talents clés qui changent le jeu

- Niveau 30 : Reverence, Illumination (20210), Improved Seals (20224), Holy Shock (talent 1311606).
- Points Legacy : Infusion of Light, Divine Precision (1310904, ID partielle), Holy Power (5923).
- Autres cités : Divine Intellect (20257), Healing Light (20237), Spiritual Focus (20205), Divine Favor (20216), Divine Strength (20262), Consecrated Ground (1310905, ID partielle), Purifying Power (candidats 429144, 429254).

### Mécaniques propres à Forever

- Light's Vigil (1310911, rangs 1311590, 1311595) : outil de soin de zone.
- Holy Shock apprenable au 30 (talent, 20 points Sacré), pas 40.
- Judgement of Light est le premier soin de zone passif.
- Holy Strike (679) : 40 % des dégâts d'arme (Sacré), Voice of Truth (1310897).
- Buffs de camp exclusifs avec les bénédictions.

---

## Idées d'auras

- Sceau actif : un seul sceau de la liste (Righteousness 20154, Command 20375, Fury 1311649, Light 20165, Crusader 21082), avec durée restante.
- Judgement actif sur la cible (une seule icône) : 20185, 20186, 20187, 20184, 20411, 20425.
- Vengeance (20050), à empiler jusqu'à 3.
- Righteous Fury (25780) actif/inactif pour Protection.
- Holy Shield (20925), Redoubt (20128), Reckoning (20178).
- Forbearance (25771) sur le joueur.
- Light's Vigil (1310911) 30 s sur la cible.
- Cooldowns à afficher : Judgement, Holy Strike, Holy Shock, Consecration, Templar's Bulwark (1311015), Swift Judgement (1310994), Lay on Hands.
- Compteur de swing pour Twist of Light (1310735), l'interface de bêta ajoute un swing timer.
- Bénédiction manquante sur le groupe : Might, Wisdom, Kings, Salvation (1038).
- Aura de paladin active : Devotion (465), Retribution (7294), Concentration (19746).

## Désaccords entre sources

- Seal of Command contre Righteousness (Rétribution) : Icy Veins dit que Command peut l'emporter avec une arme lente ou peu de puissance des sorts ; Wowhead niveau 20 dit qu'il n'est pas vraiment meilleur.
- Race Rétribution/Protection : Icy Veins (Rétribution) préfère légèrement l'Humain ; Wowhead (Protection) dit que le Nain peut être meilleur selon le cas.
- Divine Protection et Blessing of Protection : Icy Veins parle d'immunité aux dégâts (Divine Protection) et physiques (Blessing of Protection) ; Wowhead Sacré parle de protection contre les effets physiques. Non tranché.
- Lay on Hands : Icy Veins parle d'un soin complet qui vide le mana ; Wowhead Protection ajoute 550 mana rendus à la cible et un cooldown de 1 h ; `Classes/Paladin.md` indique 20 min. À vérifier en jeu avant de coder la recharge.
- Light's Vigil : Wowhead dit que le prochain Holy Shock n'a pas de recharge ; `Classes/Paladin.md` donne 6 s de recharge au sort. Rôle des deux valeurs non clair.
- Shockadin : Wowhead niveau 20 le juge plus fort en PvE ; Wowhead niveau 30 le juge problématique (mana, peu de talents Rétribution). Icy Veins le range dans les builds possibles.

## Sorts cités sans ID trouvé

- Judgement of the Crusader : IDs candidates 21183 ou 20188, non tranchées dans `Classes/Paladin.md`.
- Avenging Wrath : ID absent de `Classes/Paladin.md` (seulement mentionné comme déclencheur de Forbearance 407788, non confirmé).
- Blessing of Sanctuary : absent de Forever.
- Plusieurs talents ont une ID partielle ou ambiguë (Reverence, Divine Precision, Consecrated Ground, Infusion of Light, Purifying Power, Sanctified Judgement, Improved Seal of Fury, Iron Creed, Sacred Duty, Holy Conduit, Champion of the Light) : à confirmer avant usage.

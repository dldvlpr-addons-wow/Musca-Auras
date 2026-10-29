# Chaman — synthèse des guides WoW Forever (patch 1.60.1)

Notes de lecture orientées auras, reformulées. Lecture le 2026-10-09. Contexte des guides : bêta, plafond niveau 30, sortie complète annoncée le 4 novembre. Les rangs et IDs viennent de `Classes/Shaman.md` ; le rang maximal est cité entre parenthèses quand il compte. Chiffres entre parenthèses après un sort : ID (ou liste des rangs).

## Sources lues (date « Last Updated » / auteur affichés)
Icy Veins :
- https://www.icy-veins.com/wow-forever/shaman-class-overview — Sep 20, 2026 — Seksixeny
- https://www.icy-veins.com/wow-forever/elemental-shaman-ranged-dps-pve-guide — Oct 4, 2026 — Seksixeny
- https://www.icy-veins.com/wow-forever/enhancement-shaman-melee-dps-pve-guide — Oct 5, 2026 — Wordup
- https://www.icy-veins.com/wow-forever/restoration-shaman-healer-pve-guide — Oct 4, 2026 — Seksixeny

Wowhead (préfixe https://www.wowhead.com/forever/guide/classes/shaman/), « Updated » / auteur :
- elemental/overview-pve-dps — 2026/10/07 — Lucenia
- elemental/dps-abilities — 2026/10/08 — Lucenia
- elemental/level-20-dps-overview — 2026/09/29 — Lucenia
- elemental/level-30-dps-overview — 2026/10/06 — Lucenia
- enhancement/overview-pve-dps — 2026/10/07 — Yebb
- enhancement/dps-abilities — 2026/10/08 — Yebb
- enhancement/level-20-dps-overview — 2026/09/29 — Yebb
- enhancement/level-30-dps-overview — 2026/10/08 — Yebb
- restoration/overview-pve-healer — 2026/10/07 — Woah
- restoration/healer-abilities — 2026/10/08 — Woah
- restoration/level-20-healer-overview — 2026/09/27 — Woah
- restoration/level-30-healer-overview — 2026/10/07 — Woah

URLs absentes ou en échec : aucune (16 pages lues sur 16). Les URL Wowhead ont été vérifiées par le menu de navigation (`a[href*="/forever/guide/classes/shaman"]`, spé Elemental).

Limites : les guides sont écrits pour le plafond 30 de la bêta ; le niveau max (60) n'est pas couvert, les parties « niveau max » ci-dessous sont un aperçu tiré des textes de présentation. Les arbres de talents (images) ne sont pas lisibles en texte, seuls les points cités dans le texte sont repris. Les commentaires de lecteurs Wowhead n'ont pas été utilisés comme source.

## Éléments communs à la classe

### Totems (Forever)
- Pose instantanée, recharge globale réduite à 1 s (Icy Veins, Enhancement).
- Call of the Elements (66842, niv. 20), Call of the Ancestors (66843, niv. 30), Call of the Spirits (66844, niv. 40) : chacun pose un jeu préconfiguré de 4 totems, cast de 3 s.
- Totemic Recall (36936) : détruit tous les totems, rend 25 % du mana de chacun.
- Totemic Projection (437009, niv. 22, 1 min de recharge) : déplace les totems actifs vers un point à 30 m.
- Fire Nova (408341-408345) n'est plus un totem : explosion en anneau autour du totem de feu actif (10 yd), dégâts très élevés, coût en mana élevé.
- Quêtes de totems : terre niv. 4, feu niv. 10, eau niv. 20 (longue), air niv. 30 (difficile, groupe requis).
- Windfury Totem (8512, 10613, 10614) est appris au niv. 32 ; au niveau 30, l'air offre surtout Grounding Totem (8177).

### Armes enchantées et boucliers (tous niveaux)
- Rockbiter Weapon (8017, 8018, 8019, 10399, 16314, 16315, 16316), Flametongue Weapon (8024, 8027, 8030, 16339, 16341, 16342), Frostbrand Weapon (8033, 8038, 10456, 16355, 16356), Windfury Weapon (8232, 8235, 10486, 16362, niv. 30). Durée 60 min.
- Lightning Shield (324, 325, 905, 945, 8134, 10431, 10432) : 10 min, déclenché par 26545.
- Water Shield (408510 ; talent Restoration), voir section Restoration.
- Windfury Weapon + Flametongue Totem (8227, 8249, 10526, 16387) se cumulent, de même que Flametongue Weapon + Windfury Totem (Wowhead Enhancement). Les totems Windfury et Flametongue de groupe ne se remplacent plus par enchant d'arme ; entre eux, l'un prend le pas sur l'autre.

### Utilitaires cités
Purge (370, 8012 ; retire 2 effets), Earth Shock (8042, 8044, 8045, 8046, 10412, 10413, 10414 ; interrompt), Frost Shock (8056, 8058, 10472, 10473 ; ralentit 8 s), Ghost Wolf (2645 ; +40 % vitesse, cast 2 s ; instantané et utilisable en intérieur avec Improved Ghost Wolf 16262, 16287), Ancestral Spirit (2008, 20609, 20610, 20776, 20777), Reincarnation (20608 passif, 21169 sort ; 20 % vie et mana, 1 h de recharge, nécessite un Ankh), Astral Recall (556, 15 min), Cure Poison (526), Cure Disease (2870), Far Sight (6196), Water Breathing (131), Water Walking (546).

## Elemental (dps)

### Rotation / priorité
Niveau max (aperçu Wowhead) : Lava Burst (408490) est le sort de talent capstone (31 points), 10 s de recharge, +20 % dégâts si Flame Shock est sur la cible. Fire Nova est l'AoE principal. Lightning Bolt reste le filler.

Palier 30 (Wowhead, ordre de lecture) :
1. Strength of Earth Totem (8075, 8160, 8161, 10442, 25361) pour le groupe.
2. Lightning Bolt (403, 529, 548, 915, 943, 6041, 10391, 10392, 15207, 15208) à distance.
3. Searing Totem (3599, 6363, 6364, 6365, 10437, 10438) en mono-cible, Magma Totem (8190, 10585, 10586, 10587) en multi-cible.
4. Fire Nova (408341-408345) sur les procs Clearcasting (16246) en priorité.
5. Fire Nova sur plusieurs cibles.
6. Alterner Flame Shock (8050, 8052, 8053, 10447, 10448, 29228) et Earth Shock.
7. Mêlée pour regagner du mana.

Palier 30 (Icy Veins) : poser tous les totems avant le pull, Searing en dernier (durée courte) ; Lightning Bolt pour pull ; Fire Nova à chaque recharge si 3 cibles ou plus ; Flame Shock juste après, à rafraîchir sur cible longue ; retour à Lightning Bolt.

Palier 20 (Wowhead) : Strength of Earth Totem ; Lightning Bolt si on veut rester lanceur, sinon Flame Shock / Earth Shock en alternance ; Searing Totem puis Fire Nova à chaque recharge jusqu'à faible mana en multi-cible ; mêlée pour récupérer du mana. Le guide recommande de jouer hybride mêlée/lanceur jusqu'à la fin de la trentaine voire la quarantaine.

### Procs et buffs à suivre
- Clearcasting (16246), déclenché par Elemental Focus (16164) : prochain sort à 0 mana ; à dépenser sur Fire Nova.
- Lightning Overload (408438 ; talent, 3 rangs, 3/6/10 % d'après Wowhead overview, 1/2/3 % d'après Wowhead niveau 30) : second sort à demi-dégâts, sans menace. Aura de proc : ID absent de Classes/Shaman.md (seul le sort de talent y est listé).
- Lightning Shield (324...10432) avant le pull ; à rafraîchir en combat seulement après un choc et avec du mana (Icy Veins Enhancement, applicable à tous).
- Weapon imbue : Windfury Weapon (8232...) ou Rockbiter / Flametongue selon l'arme (2 mains lente vs 1 main rapide).
- Totems de groupe : Strength of Earth Totem, Flametongue Totem (8227...), Mana Spring Totem (5675, 10495, 10496, 10497). Icy Veins : garder les totems de buff plutôt que lancer un Lightning Bolt de plus.
- Mindfulness (1223033) : 17/33/50 % de régénération de mana en lançant (cité comme source de mana par Wowhead).

### Debuffs à maintenir sur la cible
- Flame Shock (8050, 8052, 8053, 10447, 10448, 29228) : DoT 12 s ; rafraîchir à la fin ; sa présence augmente de 20 % Lava Burst.
- Frost Shock (8056, 8058, 10472, 10473) : ralentissement 8 s, pour kiter (situationnel).
- Earthbound (talent, racine d'Earthbind Totem 2484) : tranché : 1238289 (seule aura réelle : aura 26 racine, 1222988 est un dummy, présent dans un pack Fojji, DB2 70245 relu le 2026-10-26) dans Classes/Shaman.md (autre candidat 1222988).

### Totems à garder actifs
Strength of Earth Totem (8075...), Searing Totem (3599...) ou Magma Totem (8190...) selon le nombre de cibles, Flametongue Totem (8227...) en groupe, Mana Spring Totem (5675...), Tremor Totem (8143) si peur / charme / sommeil, Grounding Totem (8177, 15 s de recharge), résistances (Frost Resistance Totem 8181, 10478, 10479 ; Fire Resistance Totem 8184, 10537, 10538 ; Nature Resistance Totem 10595, 10600, 10601) selon les dégâts du combat. Searing Totem a une durée courte (30 à 55 s selon le rang) : aura de durée utile.

### Recharges importantes
Fire Nova (10 s, plus court avec Improved Fire Nova 16086, 16544), Chain Lightning (421, 930, 2860, 10605 ; 6 s), Lava Burst (10 s), Earth Shock / Flame Shock / Frost Shock (6 s chacun), Totemic Projection (1 min), Stoneclaw Totem (30 s), Grounding Totem (15 s), Astral Recall (15 min), Racial Blood Fury (Orc, 2 min) : sort sans ID dans Classes/Shaman.md, non suivi.

### Ressources
Mana uniquement. Coût de Fire Nova très élevé, à piloter selon le mana ; Totemic Recall rend 25 % du coût des totems. Règle des 5 secondes : finir à l'auto-attaque pour regagner du mana. Intellect donne 15 mana par point.

### Talents clés qui changent le jeu
- Elemental Alacrity (16578, 16579, 16580, 16581, 16582) : réduit le temps d'incantation de Lightning Bolt, Chain Lightning, Lava Burst (Lightning Bolt passe à 2 s).
- Eye of the Storm (29062, 29064, 29065) : jusqu'à 70 % de pushback en moins (23/46/70 %).
- Call of Thunder (16041, 16117, 16118, 16119, 16120) : critique de Lightning Bolt / Chain Lightning.
- Improved Fire Nova (16086, 16544) : dégâts en plus, recharge en moins.
- Elemental Focus (16164), Call of Flame (16038, 16160, 16161) : +15 % Flame Shock et Searing Totem selon Icy Veins, Concussion (16035, 16105, 16106, 16107, 16108) : +5 % dégâts.
- Elemental Fury (16089 en DB2 ; 5 rangs côté guide : +20 à +100 % de bonus de critique).
- Lava Burst (408490), Lightning Overload (408438).
- Mindfulness (1223033), Water Shield (408510) : choisis dans la branche Restoration pour le mana (build « Mana Management », Wowhead).
- Legacy (points bonus) : Earthbound, Lightning Overload, un point d'Elemental Fury.

### Mécaniques propres à Forever
- Lava Burst : sort de talent, bonus fixe de +20 % avec Flame Shock (et non critique garanti comme en Burning Crusade).
- Fire Nova : sort de base lié au totem de feu actif.
- Dégâts de base des sorts abaissés, davantage de Spell Damage sur l'équipement ; Rank 3 de Lightning Bolt pire que Rank 2 à bas niveau ; Elemental est faible sous le niveau 40 environ.
- Totemic Recall, Totemic Projection, Call of the *, Mindfulness, Water Shield : nouveautés.
- Eye of the Storm : réduit désormais le pushback en permanence (avant : après critique reçu).
- Meilleure arme niveau 30 : Lightning's Grasp avec Elementalist's Guard (objets, pas de sort).

## Enhancement (dps)

### Rotation / priorité
Niveau max (aperçu) : Maelstrom Weapon à 5 charges permet un Lightning Bolt instantané et gratuit ; Stormstrike est l'unique frappe active ; Rage of the Farseer (425336) augmente la vitesse d'attaque / d'incantation de 30 % pendant 25 s, 3 min de recharge. Spé à deux mains uniquement (pas de double maniement).

Palier 30 (Icy Veins, rotation construite sur le timer de 8 s de Stormstrike) :
1. Windfury Weapon (8232, 8235, 10486, 16362) en permanence.
2. Totems : Call of the Elements (66842) ; terre = Stoneskin Totem (8071, 8154, 8155, 10406, 10407, 10408) si beaucoup de dégâts, sinon Strength of Earth Totem ; feu = Flametongue Totem (8227...) ou Magma Totem (8190...) ; eau = Mana Spring Totem (5675...) ; air = Grounding Totem si besoin.
3. Lightning Shield (324...) avant l'engagement.
4. Lightning Bolt rang 1 pour pull.
5. Stormstrike (17364) à chaque recharge, réagir aux resets d'Improved Stormstrike.
6. Earth Shock à chaque recharge pour consommer le debuff de Stormstrike ; en groupe, alterner Flame Shock et Earth Shock ; Frost Shock à la place si la menace est un souci.
7. Fire Nova (408341-408345) avec un totem de feu actif si mana disponible.
8. Auto-attaque jusqu'à la mort.

Palier 30 (Wowhead) : essentiellement auto-attaques ; chocs ou Lightning Bolt pour pull ; Stormstrike occasionnel pour viser un reset d'Improved Stormstrike ; Lightning Shield entre les pulls ; en donjon, Searing Totem puis Fire Nova jusqu'au risque de menace ou panne de mana. En donjon, éviter Windfury Weapon (menace), préférer Flametongue Weapon (8024...) selon Icy Veins et Wowhead.

Palier 20 : Rockbiter Weapon (2 mains lente) ou Flametongue Weapon (1 main rapide) ; Lightning Shield entre pulls ; chocs ou Lightning Bolt pour pull ; Searing Totem et Fire Nova en multi-cible.

### Procs et buffs à suivre
- Stormstrike : débuff de 12 s sur la cible, +20 % au prochain Lightning Bolt / Chain Lightning / Earth Shock (Classes/Shaman.md : tranché : 17364 (seule aura réelle : aura 271, 410156 sans aura, présent dans un pack Fojji, DB2 70245 relu le 2026-10-26), autre candidat 410156) ; recharge 8 s.
- Improved Stormstrike (tranché : 1238931 (seule aura réelle : aura 134 régénération de mana, 1223031 est un dummy, DB2 70245 relu le 2026-10-26) ; autre candidat 1223031) : rang 2, 100 % de régénération de mana continue après un sort et 100 % de reset de Stormstrike sur esquive ou parade.
- Maelstrom Weapon : charges (tranché : 408505 (seule aura réelle : CumulativeAura 5 = 5 charges, présent dans un pack Fojji, DB2 70245 relu le 2026-10-26) ; autres candidats 408498, 409946 ; 408501 « Maelstrom Ready! »). Dépenser immédiatement à 5 charges pour éviter de gaspiller. Icy Veins : 5 rangs nécessaires pour être utile, un seul point possible au niveau 30, à éviter.
- Flurry (16256, 16281, 16282, 16283, 16284) : vitesse d'attaque +10/15/20/25/30 % pendant 3 coups après un critique ; aura tranché : 16257 (départage Fojji, seul dans le pack Fojji Chaman ; 12966 figure dans le pack Guerrier, DB2 70245 relu le 2026-10-26) ; autres candidats 12966, 17687.
- Weapon imbue (Windfury Weapon) : à lire via GetWeaponEnchantInfo (pas d'aura dans le DB2).
- Windfury Attack (proc) : ID absent de Classes/Shaman.md (non trouvé dans le DB2) ; sorts d'attaque supplémentaire sous d'autres noms, non confirmés : 8516, 10608, 10610 (Windfury Totem), 8233, 8236 (Windfury Weapon).
- Lightning Shield (324...10432, déclenché 26545), Rage of the Farseer (425336), Elemental Weapons (16266, 29079, 29080) renforce les imbues.
- Spirit Weapons (16268) : parade, menace -30 % (+30 % avec Rockbiter Weapon).

### Debuffs à maintenir sur la cible
Stormstrike (17364, 12 s), Flame Shock (8050...), Frost Shock (8056...) si menace ou kite.

### Totems à garder actifs
Windfury Totem (8512, 10613, 10614) dès le niveau 32 : indispensable pour les groupes de mêlée ; Strength of Earth Totem, Flametongue Totem, Mana Spring Totem, Searing Totem (nécessaire pour Fire Nova), Magma Totem (si mana). Un totem de feu actif conditionne Fire Nova.

### Recharges importantes
Stormstrike (8 s, contre 12 s en Classic), Fire Nova (10 s), Earth Shock / Flame Shock / Frost Shock (6 s), Rage of the Farseer (3 min, 25 s), Totemic Projection (1 min), Call of the Elements (cast 3 s), Grounding Totem (15 s).

### Ressources
Mana : contrainte principale en bêta (Stormstrike et Fire Nova coûtent cher). Improved Stormstrike, Shamanistic Focus (1223030 ; réduit le coût des chocs), Mental Dexterity (415140, 415144, 415713) : Intelligence donne de la puissance d'attaque. Mental Quickness (30812) : 30 % de l'Intelligence en puissance des sorts. Spirit utile en combat avec Improved Stormstrike. Maelstrom Weapon donne un Lightning Bolt sans mana.

### Talents clés qui changent le jeu
Stormstrike (17364), Improved Stormstrike, Shamanistic Focus (1223030), Thundering Strikes (16255, 16302, 16303, 16304, 16305), Elemental Weapons (16266, 29079, 29080), Flurry, Mental Dexterity, Improved Ghost Wolf (16262, 16287), Spirit Weapons (16268), Mental Quickness (30812), Maelstrom Weapon, Rage of the Farseer (425336).

### Mécaniques propres à Forever
- Classe à deux mains seulement, double maniement retiré.
- Maelstrom Weapon : Lightning Bolt instantané à 5 charges ; Rage of the Farseer : nouveau cooldown de vitesse (3 min).
- Stormstrike : recharge 8 s au lieu de 12 s ; Improved Stormstrike : régénération de mana et resets sur esquive / parade ; Spirit Weapons : parade et menace ; Mental Quickness : Intelligence au lieu de puissance d'attaque vers puissance des sorts.
- Improved Ghost Wolf : utilisable en intérieur, instantané au rang 2.
- Windfury Totem devient un buff de groupe statique qui se cumule avec les enchantements d'arme ; Flametongue Totem pulse un buff de coups de main principale ; Windfury Weapon et Flametongue Weapon se cumulent avec les totems correspondants.
- Fire Nova lié au totem de feu. Totemic Projection en nouveauté.
- Intellect donne 1 puissance d'attaque par point (Mental Dexterity) ; Strength 2 par point.
- Tranquil Air Totem : listé dans une page Wowhead Restoration ; ID absent de Classes/Shaman.md (qui le note absent de la liste Forever).

## Restoration (healer)

### Rotation / priorité
Niveau max (aperçu) : Riptide (408521) instantané, 6 s de recharge, soin initial puis HoT de 15 s et +25 % à Chain Heal (1064, 10622, 10623) lancé sur la cible ; Chain Heal à 3 cibles ; Healing Wave (331...25357) comme soin principal en mono-cible (talents Healing Way, Improved Healing Wave) ; Lesser Healing Wave (8004...10468) pour les soins rapides. Ni Healing Wave ni Chain Heal n'ont de recharge.

Palier 30 (Icy Veins) : poser les totems avant le pull, Searing en dernier ; Healing Wave sur les cibles blessées, rang réduit si les dégâts ne justifient pas le rang max ; Fire Nova en multi-cibles ou Lightning Bolt si aucun soin urgent ; garder les totems de buff.
Palier 30 (Wowhead) : poser des totems de support (Strength of Earth Totem, Call of the Elements en pré-pull) ; Healing Wave sur les cibles très blessées, tank en priorité ; Searing Totem et Fire Nova à chaque recharge en multi-cible s'il n'y a pas de dégâts importants entrants ; mêlée pour regagner du mana.
Palier 20 : même ordre ; les premiers points vont vers Mindfulness et Water Shield, Tidal Focus en option pour le toucher de Fire Nova.

### Procs et buffs à suivre
- Water Shield (408510 ; déclenché 408511 ; autre 409941) : orbes qui rendent du mana lors de critiques.
- Nature's Swiftness (16188) : prochain sort Nature instantané, 3 min de recharge ; pour urgences.
- Ancestral Healing (16176, 16235, 16240 ; buff 16177) : +25 % d'armure 15 s sur la cible après un soin critique.
- Healing Way (29206 ; rangs 29205, 29202) : bonus permanent au soin de Healing Wave (jusqu'à +25 %), plus de cumul en pile.
- Riptide (408521, 1239242, 1239243) : HoT 15 s sur la cible, à suivre par cible.
- Mana Tide Totem (16190, 17354, 17359) : restitue du mana au groupe pendant 12 s, 5 min de recharge.
- Healing Focus (16181, 16230, 16232, 16233, 16234) : 70 % d'interruption en moins ; Natural Grace (29187, 29189, 29191).
- Lightning Shield (324...), buffs de totems de groupe (Strength of Earth, Grace of Air, Mana Spring, Healing Stream).

### Debuffs à maintenir sur la cible
Aucun propre au rôle healer. Pour la phase de dégâts : Flame Shock (8050...).

### Totems à garder actifs
Healing Stream Totem (5394, 6375, 6377, 10462, 10463 ; +50 % avec Restorative Totems 16187, 16205, 16206, 16207, 16208), Mana Spring Totem (5675, 10495, 10496, 10497 ; +25 % rendu avec Restorative Totems), Strength of Earth Totem (8075...), Grace of Air Totem (8835, 10627, 25359), Windfury Totem (8512, 10613, 10614) selon la composition, Stoneskin Totem (8071...), Tremor Totem (8143), Poison Cleansing Totem (8166), Disease Cleansing Totem (8170), résistances selon dégâts. Tranquil Air Totem : ID absent de Classes/Shaman.md.

### Recharges importantes
Riptide (6 s), Nature's Swiftness (3 min), Mana Tide Totem (5 min), Reincarnation (réduite par Improved Reincarnation 16184, 16209 ; 1 h de base), Totemic Projection (1 min), Fire Nova (10 s), Call of the Elements (cast 3 s).

### Ressources
Mana. Mindfulness (1223033) : 17/33/50 % de régénération pendant l'incantation ; Spirit devient plus fort ; Tidal Focus (16179, 16214, 16215, 16216, 16217) réduit le coût et ajoute jusqu'à 5 % de toucher ; Water Shield, Mana Tide Totem, Mana Spring Totem ; MP5 supérieur au Spirit en cast continu ; Intellect 15 mana par point.

### Talents clés qui changent le jeu
Riptide (408521), Mindfulness (1223033), Water Shield (408510), Mana Tide Totem (16190), Nature's Swiftness (16188), Healing Way (29206...), Improved Healing Wave (16182, 16226, 16227, 16228, 16229 ; jusqu'à 0,5 s de cast en moins), Tidal Mastery (16194, 16218, 16219, 16220, 16221), Ancestral Healing (16176...), Healing Focus (16181...), Restorative Totems (16187...), Tidal Focus (16179...), Totemic Focus (16173, 16222, 16223, 16224, 16225), Improved Reincarnation (16184, 16209).

### Mécaniques propres à Forever
- Riptide et Water Shield (venus de BC / Wrath), Mindfulness (nouveau), Totemic Recall / Projection / Call of the *.
- Healing Way : bonus permanent (plus de pile) ; Improved Reincarnation : +4 % de vie max ; Tidal Focus : +toucher.
- Le plafond de buffs est supprimé (Icy Veins, aperçu) ; Chain Heal renforcé par Riptide.
- Meilleure arme niveau 30 : Tidebringer's Claw avec Elementalist's Guard (objets).

## Idées d'auras
- Fire Nova (408341-408345) : recharge 10 s, et présence d'un totem de feu actif (sinon impossible).
- Totems actifs par élément (terre / feu / eau / air) avec durée restante ; alerte pour Searing Totem (durée courte), Strength of Earth Totem, Windfury Totem, Flametongue Totem, Mana Spring Totem, Healing Stream Totem.
- Clearcasting (16246) : proc de sort gratuit, pour Fire Nova.
- Flame Shock (8050...) sur la cible : durée restante 12 s ; Frost Shock (8056...) si ralentissement.
- Recharges des chocs (6 s) : Earth Shock (8042...) pour l'interruption.
- Lightning Shield (324...) : présence et durée, jusqu'à 10 min.
- Enhancement : débuff Stormstrike (17364, 12 s, recharge 8 s), charges de Maelstrom Weapon avec alerte à 5, Flurry (3 coups, +10 à +30 %), Rage of the Farseer (425336, 25 s / 3 min), imbue d'arme active (via GetWeaponEnchantInfo).
- Elemental : Lava Burst (408490, 10 s), Lightning Overload (proc).
- Restoration : Riptide (408521) par cible, Water Shield (408510, orbes), Nature's Swiftness (16188), Mana Tide Totem (16190, 5 min), Ancestral Healing (armure +25 %), Healing Way.
- Mana (bêta : contrainte majeure) : barre de mana avec seuil pour Fire Nova / Stormstrike ; Totemic Recall (36936) rend 25 % du coût des totems.
- Utilitaires : Grounding Totem (8177, 15 s), Tremor Totem (8143) si peur / sommeil / charme, Totemic Projection (437009, 1 min).

## Désaccords entre sources
- Tapis de rotation hors niveau 30 : Icy Veins et Wowhead jouent Elemental de façon différente. Icy Veins : Lightning Bolt à distance, Fire Nova à chaque recharge si 3 cibles ou plus, puis Flame Shock. Wowhead (niveau 30) : totem Searing / Magma, Fire Nova sur Clearcasting, alternance Flame Shock / Earth Shock, mêlée pour le mana. Pas de contradiction stricte.
- Lightning Overload : Wowhead overview donne 3 / 6 / 10 % de chance (3 rangs), Wowhead niveau 30 donne 1 / 2 / 3 %. Icy Veins ne chiffre pas. Contradiction interne à Wowhead.
- Windfury Weapon en donjon : Icy Veins (Enhancement) recommande Windfury Weapon partout une fois débloqué ; Wowhead (niveau 30) conseille de ne pas l'utiliser en donjon pour éviter la menace (Icy Veins conseille Flametongue Weapon en donjon, avant le niveau 30, pour la même raison).
- Flametongue Totem et Windfury Totem : Wowhead Enhancement abilities dit que Flametongue Totem remplace Windfury Totem et prend la priorité ; Wowhead Elemental abilities et Icy Veins disent simplement qu'ils ne se cumulent pas ; Wowhead Enhancement overview dit que Windfury Totem se cumule avec les enchantements d'arme.
- Maelstrom Weapon : Icy Veins et Wowhead s'accordent (inutile avant 5 rangs au niveau 30).
- Statut d'Elemental pour les donjons : Icy Veins le juge faible ; Wowhead juge l'AoE (Fire Nova) très fort mais le mono-cible faible. Même constat, nuances différentes.
- Tranquil Air Totem : cité par Wowhead (Restoration, abilities), absent des listes Icy Veins ; Classes/Shaman.md le note absent de la liste Forever.

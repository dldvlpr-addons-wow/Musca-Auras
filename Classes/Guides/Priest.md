# Prêtre : synthèse des guides WoW Forever (patch 1.60.1)

Synthèse orientée addon (Musca-Auras). Guides basés sur la bêta (niveau 30, niveau 60 à la sortie du 4 novembre) : susceptibles de changer.
IDs tirés de `Classes/Priest.md`. Les IDs entre plusieurs rangs : premier rang cité, voir `Classes/Priest.md` pour les autres.

## Sources lues

Icy Veins (4 pages) :
- Aperçu Prêtre : auteur Rainy, mis à jour le 20/09/2026.
- Discipline : auteur Rainy, 17/09/2026.
- Sacré : auteur Rainy, 17/09/2026.
- Ombre : auteur Anshlun, 17/09/2026.

Wowhead (12 pages) :
- Discipline : auteur Voulk ; aperçu 07/10/2026, abilities 08/10/2026, niveau 20 29/09/2026, niveau 30 06/10/2026.
- Sacré : auteur Spanklord ; aperçu 07/10/2026, abilities 08/10/2026, niveau 20 29/09/2026, niveau 30 06/10/2026.
- Ombre aperçu : Jereico, 08/10/2026.
- Ombre abilities : Jereico, 08/10/2026.
- Ombre niveau 20 : Jereico, 29/09/2026.
- Ombre niveau 30 : Jereico, 08/10/2026.

Pages en échec ou absentes : aucune. Total : 16 pages lues, 0 échec. Dates et chiffres relus et audités le 09/10/2026.

## Discipline (soigneur / hybride)

### Rotation / priorité
Niveau 30 (max bêta), soin :
1. Bouclier : Power Word: Shield (10901) sur le tank avant le pull (inutile sur Guerrier / Druide, tanks à rage).
2. Renew (10929) sur le tank.
3. Heal (6064) en soin principal.
4. Flash Heal (10917) en urgence.
5. Prayer of Healing (25316) si le groupe est bas (coûteux).
6. Wand quand stable ; boire entre les pulls. Fade (10942) si aggro.
7. Dispel Magic (988) / Cure Disease (528) au besoin.

Dégâts : Fortitude (10938) et Inner Fire (10952), bouclier, Holy Fire (15267), Smite (10934), Mind Blast (10947), Shadow Word: Pain (10894), Wand.
Niveau 20 : même ordre, Holy Fire dès qu'il est appris sinon Smite ; Renew si inquiet. Niveau 20 et 30 ne diffèrent que par les sorts appris (Penance, Divine Spirit, Prayer of Healing).

### Procs et buffs à suivre
- Power Word: Shield (10901), Inner Fire (10952), Power Word: Fortitude (10938), Prayer of Fortitude (21564), Divine Spirit (14752 ; 27841 rang appris), Prayer of Spirit (27681, niveau 60).
- Inner Focus (14751) : prochain sort gratuit, +25 % critique (à coupler avec Heal ou Holy Fire).
- Power Infusion (10060) : +20 % dégâts et soins, 15 s.
- Fear Ward (6346), de base à 3 min.
- Spirit Tap (aura 15271).
- Divine Aegis : absorbe sur critique de soin ; candidats 431622, 431624, 431649 (non tranché dans Classes/Priest.md).

### Debuffs à maintenir sur la cible
- Shadow Word: Pain (10894), Holy Fire (15267, DoT ; durée non indiquée).
- Weakened Soul (6788) sur l'allié : empêche un nouveau bouclier, 15 s selon Wowhead.
- Hex of Weakness (9035), troll : réduit les soins reçus par la cible (pourcentage non indiqué) ; 2 min.

### Recharges importantes
- Mind Blast (10947) : 8 s (Wowhead).
- Psychic Scream (10890) : peur 8 s, recharge 30 s.
- Fear Ward (6346) : 3 min.
- Power Infusion (10060) : 3 min (page Ombre Wowhead).
- Penance (1316995 rang max ; rang 1 402174) : canalisé (durée non indiquée), recharge 12 s (Classes/Priest.md).
- Divine Grace (1277378) : 10 min. Contingency Plan (1277462) : 10 min. Desperate Prayer (13908) : 10 min. Dark Sacrifice (1277324) : 10 min. Feedback (13896) : 3 min. Elune's Grace (2651) : 5 min. Confounding Flash (1277455) : 2 min. Chastise (1277331) : 2 min.

### Ressources
- Mana, règle des 5 secondes ; pas de régénération en combat avant Meditation (14521).
- Meditation : 50 % de la régénération d'Esprit en lançant (15 % en Classic).
- Sous-rangs recommandés pour économiser le mana.
- Gnome : Eureka! aide le mana (ID absent de Classes/Priest.md). Humain : Divine Grace retire Weakened Soul.

### Talents clés qui changent le jeu
- Spirit Tap (15270) : mana au dernier coup.
- Power in Light (1309969) : Smite plus fort sur cible sous Holy Fire.
- Soul Warding (candidats 402000, 402834) et Renewed Hope (candidats 425280, 425303) : réduisent la recharge / durée de Weakened Soul.
- Improved Power Word: Shield (14748), Holy Precision (1309957), Improved Renew (14908), Twilight Focus (14913), Divine Fury (18530), Mental Strength (18551), Wand Specialization (14524), Inner Focus (14751), Meditation (14521).
- Penance : demande 20 points Discipline.
- Divine Fury : réduit le temps d'incantation de Heal et Greater Heal.

### Mécaniques propres à Forever
- Penance (402174), Divine Aegis, Dark Sacrifice (1277324), Contingency Plan (1277462) nouveaux.
- Fear Ward (6346) et Devouring Plague (2944, recharge 1 min) de base.
- Power Word: Shield ne peut pas critiquer.
- Elune's Light (ID absent de Classes/Priest.md) + Divine Aegis : fenêtre de burst (Elfe de la nuit).
- Divine Spirit (14752) devenu sort de base niveau 30 (était un talent Discipline).
- Shadowguard (18137) : nombre de charges non indiqué.

## Sacré (soigneur)

### Rotation / priorité
Niveau 30 :
1. Power Word: Shield (10901) pour gagner du temps / sur le tank.
2. Renew (10929) sur le tank.
3. Heal (6064).
4. Flash Heal (10917) quand quelqu'un va mourir.
5. Binding Heal (401937) si toi et le tank êtes blessés.
6. Prayer of Healing (25316) seulement si presque tout le groupe est bas.
7. Holy Nova (15237) si le proc Searing Light est actif et que personne n'est en danger (Icy Veins) ; coûteux, pas pour le soin de groupe.
8. Dispels, Wand quand stable.

Dégâts : Fortitude, Inner Fire, Power Word: Shield, Smite (10934), Mind Blast (10947), Shadow Word: Pain (10894), Wand. Niveau 20+ : Holy Fire (15267) en ouverture. Niveau 20 : même base sans Binding Heal.

### Procs et buffs à suivre
- Holy Purpose (1284536), déclenché par Searing Light (14909).
- Inspiration (candidats 14892, 14893) : armure sur critique de soin.
- Spirit of Redemption (20711) : 15 s (10 s Classic), 20 points Sacré.
- Blessed Recovery (candidats 27811, 27813, 1240755).
- Power Word: Fortitude (10938), 1 h au rang max ; Inner Fire (10952).
- Spirit Tap (aura 15271) dans les builds de montée.

### Debuffs à maintenir sur la cible
- Weakened Soul (6788), 15 s.
- Holy Fire (15267) et Shadow Word: Pain (10894) en dégâts.
- Touch of Weakness (2652), mort-vivant, avant le pull.

### Recharges importantes
- Prayer of Mending (rang 1 401859 ; 1240826, 1240827) : dernier talent (31 points), rebondit jusqu'à 5 fois sur 20 m, un seul actif par lanceur.
- Fade (10942), Divine Grace (1277378), Desperate Prayer (13908) comme ci-dessus.

### Ressources
- Mana : point faible. Litany of Light (1317006) rembourse du mana en alternant les soins.
- Faiblesses : dégâts physiques, mobilité (Renew et Power Word: Shield en mouvement), mana.

### Talents clés qui changent le jeu
- Improved Renew (14908), Holy Specialization (14889), Divine Fury (18530), Holy Nova (15237), Inspiration, Holy Reach (27789), Binding Heal (401937), Spirit of Redemption (20711).
- Litany of Light (1317006), Spiritual Guidance (14901), Spiritual Healing (14898), Searing Light (14909), Improved Healing (14912).
- Wand Specialization (2 points) entre en conflit avec Spirit of Redemption au niveau 30.

### Mécaniques propres à Forever
- Retirés de l'arbre Sacré : Healing Focus, Improved Prayer of Healing (IDs absents de Classes/Priest.md) et Lightwell (724, présent dans Classes/Priest.md).
- Ajoutés : Binding Heal (1,5 s, soigne cible et lanceur, peu de menace, 15 points), Prayer of Mending, Litany of Light.
- Prayer of Healing (25316) : portée 40 m (30 en Classic).
- Searing Light : augmente les dégâts Sacré, les ticks de Holy Fire peuvent donner un Holy Nova gratuit.
- Holy Nova : 10 m, ne génère pas de menace.

## Ombre (dégâts)

### Rotation / priorité
Niveau 30 (Wowhead et Icy Veins concordent) :
1. Fortitude (10938), Inner Fire (10952), Touch of Weakness (2652) pour mort-vivant.
2. Power Word: Shield (10901) avant le pull (optionnel).
3. Mind Blast (10947) en ouverture, à la recharge.
4. Shadow Word: Pain (10894), sur tous les ennemis en donjon si mana OK.
5. Devouring Plague (19280) si dispo ; à sauter si mana serré ou ennemis qui meurent vite.
6. Mind Flay (18807), optionnel : pas plus fort que la Wand à ce niveau et remet la règle des 5 s à zéro ; subit le pushback.
7. Wand pour finir.
Avant Mind Flay : Smite (10934) à la place (Icy Veins). Niveau 20 : bouclier, optionnellement Touch of Weakness, Holy Fire (15267) ou Smite, Mind Blast, Shadow Word: Pain, Wand.
Shadow Word: Death (1309636) à partir du niveau 32, exécution avec Early Demise (1310076, sous 20 % PV), recharge 15 s, contrecoup de 10 % PV max si la cible survit.

### Procs et buffs à suivre
- Shadowform (15473) : niveau 40 selon Wowhead ; +10 % dégâts Ombre, -50 % coût en mana des sorts Ombre, +100 % bonus de dégâts critiques Ombre, -15 % dégâts physiques subis, bloque les soins.
- Spirit Tap (aura 15271), dernier coup requis ; Vampiric Embrace (15286) peut l'activer sur mort d'un ennemi affecté.
- Shadow Weaving (aura 15258) : augmente seulement les dégâts Ombre du lanceur.
- Blackout (stun 15269), Inner Focus (14751) en combo avec Devouring Plague.
- Elune's Light (ID absent de Classes/Priest.md) : +10 % critique 15 s (Elfe de la nuit).
- Power Word: Shield (10901) : empêche le pushback.

### Debuffs à maintenir sur la cible
- Shadow Word: Pain (10894) : 18 s (intervalle de tick non indiqué).
- Devouring Plague (19280) : 24 s, soigne du montant infligé.
- Vampiric Embrace (15286) : 30 s, soigne le groupe.
- Pas de snapshot en Forever : les DoT se mettent à jour dynamiquement (Icy Veins).
- Hex of Weakness (9035) pour troll.

### Recharges importantes
- Mind Blast (10947) : 8 s ; 6 s à 4 points d'Improved Mind Blast (15273) au niveau 60.
- Devouring Plague (19280) : 1 min. Shadow Word: Death (1309636) : 15 s. Vampiric Embrace (15286) : 1 min.
- Silence (15487) : 3 s d'interruption, 1 point. Psychic Scream (10890) : 30 s. Starshards (19305) : 30 s. Elune's Grace (2651) : 5 min.
- Power Infusion (10060) : 3 min, non compatible avec Shadowform (talent Discipline ; nombre de points non indiqué).

### Ressources
- Mana, règle des 5 secondes ; Wand sans effet sur la règle ; Spirit Tap et Meditation (14521) comme moteur.
- Multi-DoT très coûteux en mana. Shadowform divise le coût Ombre par 2.
- Statistiques : puissance des sorts, puis critique, puis toucher (central en fin de jeu).
- Dark Sacrifice (1277324) : vie contre mana, 15 s, 10 min.

### Talents clés qui changent le jeu
- Wand Specialization (14524), Spirit Tap (15270), Improved Shadow Word: Pain (15275), Shadow Focus (15260), Shadow Reach (17322), Twilight Focus (14913), Blackout (15268).
- Mind Flay (15407) et Improved Mind Flay (1225139), Improved Mind Blast (15273), Vampiric Embrace (15286), Shadow Weaving (15257), Devouring Contagion (1309950), Early Demise (1310076), Silence (15487).
- Shadow Affinity (menace) : ID absent de Classes/Priest.md.
- Variante Meditation (14521) : environ 13 points Discipline, coûteuse (Icy Veins).
- Twin Disciplines (1225132) mène à Meditation et Inner Focus.
- Niveau 20 : Wand Specialization 2, Spirit Tap 1, Improved Shadow Word: Pain 2, Shadow Focus 2 (ou Twilight Focus, Shadow Reach, Twin Disciplines).

### Mécaniques propres à Forever
- Devouring Plague (2944) de base, 1 min (3 min Classic, mort-vivant seul).
- Shadow Word: Death (1309595) nouveau, exécution.
- Shadowform repensé : +10 % (15 % Classic), -50 % mana ; sorts Sacré et utilitaires lançables en forme (seuls les soins bloqués).
- Shadow Weaving ne baisse plus la résistance de la cible.
- Silence : vraie interruption, 1 point, plus lié à Improved Psychic Scream.
- Mind Flay disponible dès le niveau 20, Mana Burn (8129) au niveau 24, Divine Spirit (14752) au niveau 30.
- Racial : Starshards (10797), Touch of Weakness (2652), Touch of the Grave (ID absent de Classes/Priest.md, passif de dégâts).
- Mind Control (605), Shackle Undead (9484), Mind Soothe (453), Levitate (1706) restent des utilitaires.

## Idées d'auras
- Mana et règle des 5 secondes : indicateur de régénération active.
- Spirit Tap (15271) : fenêtre active après un dernier coup.
- Weakened Soul (6788) sur le tank (Discipline) et durée restante de Power Word: Shield (10901).
- Shadow Word: Pain (10894) et Devouring Plague (19280) : durée sur la cible, par cible (multi-DoT).
- Mind Blast (10947) : recharge 8 s.
- Shadow Word: Death (1309636) : disponible et cible sous 20 %.
- Vampiric Embrace (15286) : durée 30 s, recharge 1 min.
- Shadowform (15473) : actif ou non (bloque les soins).
- Inner Fire (10952) : charges restantes (20). Fortitude (10938) / Prayer of Fortitude (21564) et Divine Spirit (14752) manquants.
- Inner Focus (14751) prêt, Power Infusion (10060) prêt / actif.
- Searing Light, Holy Purpose (1284536) : proc pour Holy Nova (15237).
- Prayer of Mending (401859) : charges sur le groupe ; Binding Heal (401937).
- Penance (402174) prêt ; Divine Aegis (candidats 431622, 431624, 431649) sur le groupe.
- Fear Ward (6346) : recharge 3 min et buff sur l'allié.
- Défensifs raciaux : Desperate Prayer (13908), Divine Grace (1277370), Contingency Plan (1277462), Dark Sacrifice (1277324), Elune's Grace (2651), Shadowguard (18137), Touch of Weakness (2652).
- Fade (10942) quand l'aggro est tirée.

## Désaccords entre sources
- Shadowform : l'aperçu Icy Veins parle seulement d'une baisse de mana et d'une identité tardive ; Wowhead donne niveau 40, +10 % dégâts Ombre, -50 % mana, +100 % dégâts critiques.
- Meilleure race Ombre Alliance : Icy Veins met l'Elfe de la nuit en tête (Mort-vivant côté Horde) ; la page Ombre de Wowhead cite le Gnome en premier et l'Elfe de la nuit en mention honorable.
- Weakened Soul : Icy Veins cite Soul Warding et Renewed Hope pour raccourcir le bouclier ; Wowhead ne cite que Soul Warding.
- Critique : Icy Veins Sacré le met en dernier (surguérison) ; Icy Veins Discipline le valorise (Renewed Hope, Divine Aegis). Contradiction interne plus qu'entre sources.
- Divine Spirit : les deux guides le donnent comme sort de base au niveau 30, mais `Classes/Priest.md` le liste aussi comme talent Discipline (14752) ; vérifier en jeu.
- Penance : Wowhead Discipline niveau 30 demande 20 points Discipline ; la page abilities Ombre de Wowhead parle de 21 points.
- Weakened Soul 15 s : donné par la page abilities Sacré de Wowhead, pas par la page Discipline.

## Sorts cités sans ID dans Classes/Priest.md
ID absent de Classes/Priest.md : attaque à la Wand, Eureka!, Elune's Light, Will of the Forsaken, Cannibalize, Touch of the Grave, Healing Focus, Improved Prayer of Healing, Shadow Affinity, Expansive Mind, Quickness, Will to Survive, Sword Specialization.

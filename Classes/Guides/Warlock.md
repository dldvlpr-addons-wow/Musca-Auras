# Démoniste — synthèse des guides WoW Forever 1.60.1

Notes reformulées pour Musca-Auras. Les IDs viennent uniquement de `Classes/Warlock.md`. Beta plafonnée au niveau 30, sortie complète le 4 novembre. Tout est susceptible de changer.

## Sources lues

Icy Veins (auteur : Abide) :
- Vue d'ensemble de la classe : dernière mise à jour 20 sept. 2026
- Affliction : 17 sept. 2026
- Démonologie : 17 sept. 2026
- Destruction : 17 sept. 2026

Wowhead (auteur : Zephan) :
- Affliction `overview-pve-dps` : 2026/10/07
- Affliction `dps-abilities` : 2026/10/08
- Affliction `level-20-dps-overview` : 2026/09/30
- Affliction `level-30-dps-overview` : 2026/10/06
- Démonologie `overview-pve-dps` : 2026/10/07
- Démonologie `dps-abilities` : 2026/10/08
- Démonologie `level-20-dps-overview` : 2026/09/30
- Démonologie `level-30-dps-overview` : 2026/10/06
- Destruction `overview-pve-dps` : 2026/10/07
- Destruction `level-20-dps-overview` : 2026/09/30
- Destruction `level-30-dps-overview` : 2026/10/06
- Destruction `dps-abilities` : 2026/10/08

Aucune page non lue, aucune en échec (16 pages lues).

## Mécaniques communes Forever

- Bane of Agony (980) et Bane of Doom (603) ne sont plus des malédictions : un Bane et une malédiction coexistent sur la même cible. Un seul Bane et une seule malédiction par démoniste et par cible.
- Life Tap (1454) dépend maintenant de l'Esprit. Wowhead donne (430 + Esprit) de vie convertis en mana. Coût en vie élevé en leveling.
- Les fragments d'âme sont des composants (sac séparé, non empilables). Drain Soul (1120) génère des fragments sur kill, avec une chance sur les ticks selon Wowhead.
- Les DoTs peuvent crit, se mettent à jour dynamiquement (pas de snapshot). La Hâte n'accélère ni les DoTs ni les canalisations.
- Les familiers gagnent des stats de ton personnage (Warlock Pet Scaling, 416189). Nouvelle commande "Move To" (ID absent de Classes/Warlock.md).
- Les pierres de rencontre n'invoquent pas : seul Ritual of Summoning (698) raccourcit le trajet. Portal of Summoning (437169) existe en talent Démonologie.
- Voidwalker (697) tient la menace dès le niveau 10 (Torment, nouveau rang tous les 10 niveaux). Succubus (712) fait environ x1,5 les dégâts du Voidwalker. Imp (688) plus faible et à sec de mana vite. Felhunter (691) = utilitaire (Spell Lock 19244, Devour Magic 19505).
- Pierres de feu et de sort (Create Firestone 6366, Create Spellstone 2362) fonctionnent comme des huiles d'arme.
- Raciaux : Orc Blood Fury (ID absent de Classes/Warlock.md) et Shatter Curse (ID absent de Classes/Warlock.md) ; Gnome Eureka! (ID absent de Classes/Warlock.md) ; Troll Berserking (ID absent de Classes/Warlock.md, n'affecte pas DoTs ni canalisations, meilleur en Destruction) ; Undead Touch of the Grave (ID absent de Classes/Warlock.md).

## Affliction (DPS)

### Rotation / priorité

Niveau 30 (Icy Veins) :
1. Familier en premier (Succubus 712 ou autre).
2. Malédiction : Curse of Recklessness (704) ou Curse of the Elements (440892).
3. Immolate (348) en pré-cast.
4. Bane of Agony (980) si la cible vit assez longtemps.
5. Siphon Life (18265) si la cible vit 20 s ou plus.
6. Corruption (172), instantanée avec Improved Corruption.
7. Drain Life (689) pour la vie.
8. Shadow Bolt (686) sur proc Shadow Trance (17941).
9. Baguette sur cible basse.
10. Drain Soul (1120) pour les fragments.
11. Life Tap (1454) pour le mana.

Niveau 30 (Wowhead, style drain-tank) : Succubus, Corruption et Bane of Agony, puis Drain Life jusqu'à la mort de la cible. Mana bas : Life Tap (Drain Life rembourse le coût en vie). Cible sous environ 20 % ou vie pleine : baguette. Fear (5782) en jonglage entre deux mobs.

Niveau 20 (Wowhead) : Succubus, Bane of Agony, Corruption, Immolate en dernier (le coup initial crée de la menace), puis baguette. Drain Life pas rentable à ce niveau.

### Procs et buffs à suivre

- Shadow Trance (17941) : prochain Shadow Bolt instantané (Nightfall 18094). Wowhead : DoTs et Drain Life peuvent le proc.
- Soul Harvest : mana regen boosté après kill d'une cible sous Drain Soul. IDs candidats 437032, 1242853, aucun retenu.
- Demon Armor (11735 pour le rang 5) à maintenir ; pas de Fel Armor.
- Raciaux : Blood Fury, Berserking, Eureka! (IDs absents de Classes/Warlock.md).

### Debuffs à maintenir sur la cible

- Corruption (172), 18 s au rang 3 selon Wowhead.
- Bane of Agony (980), 24 s, dégâts croissants.
- Siphon Life (18265).
- Immolate (348), utile surtout pour Firestone et Conflagrate.
- Malédiction : Curse of the Elements (440892, couvre maintenant toutes les écoles), Curse of Recklessness (704, armure réduite, empêche la fuite), Curse of Weakness (702), Curse of Tongues (1714), Curse of Exhaustion (18223).
- Wrack (1316697) au talent capstone.
- Soul Siphon (17804) : +12 % par effet Affliction sur la cible, max +36 % : garder 3 effets ou plus.

### Recharges importantes

- Howl of Terror (5484) : fear de zone, 40 s de recharge selon Wowhead.
- Death Coil (6789).
- Fear (5782) : jusqu'à 20 s.
- Banish (710), Shadow Ward (6229).
- Eureka!, Blood Fury, Berserking, Shatter Curse : IDs absents de Classes/Warlock.md.

### Ressources

- Mana : Life Tap (1454) avec Improved Life Tap (18182), rang 3 à 26 qui double la base.
- Fragments d'âme : Drain Soul (1120) ; Soulstone (693) et Healthstone (6201) en consommables.
- Familier : Succubus de préférence ; Health Funnel (755) pour le soigner.

### Talents clés qui changent le jeu

- Improved Corruption (17810) : Corruption instantanée et +10 % dégâts.
- Suppression (18174), Malediction (1225177), Amplify Curse (18288), Improved Bane of Agony (18827).
- Pandemic : crit des DoTs et drains +100 %. IDs candidats 427712, 429283, aucun retenu.
- Malevolence : +5 % crit Ombre. IDs candidats 449919, 449920, 1310949, aucun retenu.
- Improved Drains (403511) : +20 % sur Drain Life, Drain Soul, Wrack.
- Soul Siphon (17804), Siphon Life (18265), Nightfall (18094), Shadow Mastery (18271).
- Wrack (1316697) à 31 points, donc hors cap beta 30.

### Mécaniques propres à Forever

- Pas de snapshot des DoTs.
- Bane of Doom (603) : 1 min, chance d'invoquer un Doomguard (18662) si la cible meurt, pas sur joueurs.
- Niveau 20 : 7 points legacy possibles avant 25, 2 talents supplémentaires. Niveau 30 : 5 points legacy gratuits.
- Weaknesses : peu de burst, Hâte inutile.

## Démonologie (DPS, familier)

### Rotation / priorité

Niveau 30 (Wowhead, build Demonic Brand) :
1. Envoyer la Succubus (712).
2. Corruption (172) puis Bane of Agony (980) si le mob a beaucoup de vie.
3. Searing Pain (5676) pour appliquer Demonic Brand.
4. Drain Life (689) pour le reste du combat.
5. Relancer Searing Pain à chaque chute de la marque, environ toutes les 6 s.
6. Mana bas : Life Tap (1454). Mob sous environ 20 % : baguette.

Icy Veins : vérifier le familier et Soul Link (19028) ; familier, malédiction, Immolate pré-cast, Bane of Agony, Corruption, Drain Life et Healthstone pour la vie (Drain Life soigne aussi le démon via Demonic Energies), baguette, Drain Soul pour les fragments, Life Tap (le démon reçoit 100 % du mana).

Niveau 20 : Succubus, Bane of Agony, Corruption, Immolate, baguette. Shadow Bolt pas rentable à 20.

Wowhead overview : garder les DoTs, Searing Pain pour la marque, Shadow Bolt en filler, Soul Fire (6353) quand Decimation est actif.

### Procs et buffs à suivre

- Demonic Brand : marque 10 s ou 2 attaques du familier par rang, menace double. IDs candidats 1293695 à 1293699, aucun retenu.
- Decimation : cible sous 35 % de vie, Soul Fire plus rapide et sans fragment 10 s. IDs candidats 440870, 440873, 440923, aucun retenu.
- Soul Link (19028).
- Demon Armor (11735 rang 5).
- Demonic Sacrifice (18788), aucun ID d'aura distinct.
- Master Demonologist (23785) : bonus selon le démon actif.

### Debuffs à maintenir sur la cible

- Corruption (172), Bane of Agony (980), Immolate (348), Bane of Doom (603).
- Malédiction (Curse of the Elements 440892, Recklessness 704).
- Marque de Demonic Brand (voir candidats ci-dessus).

### Recharges importantes

- Decimation : Soul Fire 6 s de recharge, pas de chaîne.
- Spell Lock (19244) du Felhunter, Seduction (6358) du Succubus.
- Fel Domination (18708), Demonic Sacrifice (18788).

### Ressources

- Mana : Life Tap (1454) ; avec Demonic Energies, le démon gagne 100 % du mana.
- Familier : Succubus préférée ; Health Funnel (755), Fel Vitality (18731).
- Fragments pour Soul Fire, Soulstone.

### Talents clés qui changent le jeu

- Unholy Power (18769) : +10 % dégâts du familier (20 % avant).
- Demonic Energies : candidats 1225214, 1243028, aucun retenu.
- Demonic Brand, Improved Sayaad (18754), Fel Vitality (18731), Master Summoner (18709), Demonic Embrace (18697).
- Decimation, Fel Domination (18708), Soul Link (19028).
- Demonic Knowledge (candidats 412732, 412735, 415749, 1243120, aucun retenu).
- Demonic Pact (candidats 425464, 425466, 425467, 425473) : capstone au niveau 31, hors cap beta.
- Improved Felhunter (1225217), Demonic Aegis (candidats 470279, 1235316).

### Mécaniques propres à Forever

- Demonic Sacrifice dure 2 h : Imp +15 % Ombre, Succubus +15 % Feu, Voidwalker restaure du mana, Felhunter restaure de la vie.
- Soul Link plus Demonic Embrace : environ 64 % de vie effective en plus.
- Dépend du familier et du placement.
- Succubus (712) et Incubus (713) ont chacun leur quête et leur sort d'invocation.

## Destruction (DPS, burst et AoE)

### Rotation / priorité

Niveau 30 :
1. Familier d'abord (Voidwalker 697 plus sûr que Succubus pour Destruction).
2. Bane of Agony (980), Corruption (172), Immolate (348).
3. Shadow Bolt (686) comme filler (Incinerate, 412758, est le capstone à 31 points, hors cap beta) ; baguette par défaut.
4. Conflagrate (17962) juste avant la fin d'Immolate.
5. Shadowburn (17877) en coup final, quand la cible est sous un coup (environ 150 au niveau 30), pour récupérer le fragment.
6. Life Tap (1454) pour le mana ; Drain Life (689) possible en quête.

Icy Veins ajoute : pré-cast Shadow Bolt puis Immolate (temps de vol), Searing Pain (5676) pour un cast rapide, Conflagrate consomme Immolate au niveau 30.

Niveau 20 : Succubus, Bane of Agony, Corruption, Immolate, puis Shadow Bolt ou baguette.

### Procs et buffs à suivre

- Shadow and Flame : candidats 426316, 426449, aucun retenu. Conflagrate donne +10 % Ombre 20 s, Shadowburn +10 % Feu 20 s.
- Pyroclasm : talent 18096 ou 18073, aura candidate 18093 ou 1293803, aucune retenue.
- Aftermath daze (18118) après Conflagrate.
- Improved Shadow Bolt (17793) : debuff Ombre sur la cible après crit.

### Debuffs à maintenir sur la cible

- Immolate (348), Corruption (172), Bane of Agony (980) ou Bane of Havoc (1225228, aucun ID de debuff distinct).
- Malédiction (Recklessness 704 ou Elements 440892).
- Bane of Havoc : 15 % des dégâts sur les autres cibles aussi sur la cible Havoc ; un Bane par cible, donc incompatible avec Bane of Agony sur la même.

### Recharges importantes

- Shadowburn (17877) : 15 s de recharge selon Icy Veins.
- Conflagrate (17962) : instantané.
- Hellfire (1949), Rain of Fire (5740) pour l'AoE.

### Ressources

- Mana : Cataclysm (17778) réduit le coût de 10 %, Life Tap (1454).
- Fragments : Shadowburn les rend à la mort ; Drain Soul (1120) pour en gagner.
- Familier : Voidwalker (Torment 3716).

### Talents clés qui changent le jeu

- Bane (17788) : Shadow Bolt et Immolate plus rapides.
- Aftermath (18119), Ruin (17959), 5 points requis.
- Agonizing Flames (17927) : +10 % dégâts Destruction.
- Shadowburn (17877), Conflagrate (17962), Cataclysm (17778), Destructive Reach (17917), Intensity (18135), Molten Skin (1225220).
- Fire and Brimstone (412751) : +25 % crit Conflagrate. Shadow and Flame voir ci-dessus.
- Incinerate (412758) : capstone à 31 points (hors cap beta 30), nouveau filler principal ensuite, +25 % dégâts si Immolate actif.
- Wowhead abilities : Shadow Bolt est le filler principal jusqu'à Incinerate ; Searing Pain (5676) en cast de 1,5 s sans temps de vol quand le filler arriverait après la mort du boss ; Conflagrate à lancer sur les derniers ticks sauf Shadow and Flame 5/5 ; Soothing Kiss (7813) en autocast pour la Succubus.

### Mécaniques propres à Forever

- Shadow and Flame à 5/5 : Conflagrate ne consomme pas Immolate et Shadowburn rend toujours le fragment.
- Destructive Reach affecte tous les sorts de dégâts.
- Firestone (6366) donne crit et puissance Feu : surtout utile à Immolate.
- Point faible : cleave, pas de bonus Ombre sur les DoTs.

## Idées d'auras

- Shadow Trance (17941) proc, avec glow sur Shadow Bolt.
- Durée restante de Corruption (172), Bane of Agony (980), Immolate (348), Siphon Life (18265) sur la cible.
- Malédiction active sur la cible (704 ou 440892) et Bane (980 ou 603).
- Demonic Brand sur la cible (IDs candidats seulement) et timer de 6 s pour relancer Searing Pain (5676).
- Decimation actif (candidats seulement), pour Soul Fire (6353).
- Soul Link (19028) et Demon Armor (11735).
- Familier absent ou mort (Succubus 712, Voidwalker 697).
- Mana bas : rappel Life Tap (1454).
- Compteur de fragments d'âme (sans ID).
- Cooldown Shadowburn (17877) et Conflagrate (17962).

## Désaccords entre sources

- Suppression : Icy Veins donne +3 % toucher et -12 % menace à 3 points ; Wowhead +5 % et -20 % au max, avec 4 points suffisants pour le cap toucher.
- Malediction (1225177) : Icy Veins +5 %, Wowhead +10 %.
- Improved Bane of Agony : Icy Veins et Wowhead overview disent +10 % ; Classes/Warlock.md donne +5/10 % par rang.
- Eureka! : Icy Veins -50 % de coût mana, Wowhead -10 %.
- Filler Affliction : Icy Veins garde Drain Life pour la vie et la baguette comme filler ; Wowhead niveau 30 en fait le filler principal.
- Build Affliction : Icy Veins recommande Nightfall, Pandemic, Siphon Life ; Wowhead niveau 30 priorise Improved Drains et Soul Siphon.
- Firestone et Spellstone : Icy Veins donne les valeurs du rang 1 (niveau 28), Wowhead les valeurs majeures.
- Decimation : Wowhead le met dans la boucle ; Icy Veins ne le cite pas dans sa rotation.
- Familier Destruction : Icy Veins reste neutre, Wowhead préfère le Voidwalker (menace) à la Succubus pour Destruction.

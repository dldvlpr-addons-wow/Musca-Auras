# Pack Prêtre (mcPrieV1)

Source des IDs : `Classes/Priest.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Mind Blast, Shadow Word: Death, Holy Fire, Penance, Prayer of Mending (rang 1, suivi par nom).
- Cooldowns : Psychic Scream, Fade, Inner Focus, Fear Ward, Shadowfiend, Silence, Power Infusion, Desperate Prayer (chargé seulement si le sort est connu, donc nain).
- Buffs : Power Word: Shield, Renew, Inner Fire, Shadowform, Inner Focus (actif), Power Infusion (actif), Fear Ward (actif), Spirit Tap.
- Debuffs cible : Shadow Word: Pain, Vampiric Embrace, Devouring Plague, Shadow Weaving.
- Barre de mana, règle des 5 s (12 sorts de mana).
- Rappels : Power Word: Fortitude (rangs et Prayer of Fortitude), Inner Fire, Shadowform, MANA BAS.
- Les buffs « (actif) » portent ce suffixe car l'id d'une aura doit être unique et le cooldown du même nom existe déjà.

## IDs à confirmer en jeu
- Vampiric Embrace 15286 : le DB2 le classe « buff » ; en Classic c'est un debuff sur la cible. Affiché en debuff cible, à vérifier.
- Shadow Weaving 15258 : « debuff cible / buff lanceur » selon le DB2. À vérifier sur la cible.
- Spirit Tap 15271 : aura déclenchée par 15270, à vérifier.
- Penance 402174 et Prayer of Mending 401859 : rang 1 = sort de talent, ID « non lu » hors wow-forever.gg.
- Mind Flay 15407 (règle des 5 s) : rang 1 présent seulement dans wow-forever.gg ; les rangs 2 à 6 comptent aussi par nom.

## Ignoré
- Weakened Soul (6788) : debuff sur le joueur, le builder ne suit que les buffs du joueur.
- Vampiric Touch, Holy Concentration / Clearcasting : absents de `Classes/Priest.md`.
- Debuff Holy Fire et ralentissement de Mind Flay : aucun ID d'aura dans le fichier.
- Smite, Flash Heal, etc. : sans recharge, utiles seulement pour la règle des 5 s.

## À tester en jeu
- Les cooldowns Penance, Prayer of Mending, Shadow Word: Death s'affichent seulement si le sort est connu.
- Shadowform : buff et rappel (le rappel doit disparaître une fois en forme).
- Les icônes d'aura de cible en combat (valeurs secrètes) : Pain, Plague, Weaving, Embrace.
- Règle des 5 s : se déclenche après un sort de la liste, pas sur Fade ni Inner Fire.

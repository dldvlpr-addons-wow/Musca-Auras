# Pack Prêtre (mcPrieV1)

Source des IDs : `Classes/Priest.md` (DB2 1.60.1.70245).

## Contenu
- Rotation : Mind Blast, Shadow Word: Death, Holy Fire, Penance, Prayer of Mending (rang 1, suivi par nom).
- Cooldowns : Psychic Scream, Fade, Inner Focus, Fear Ward, Shadowfiend, Silence, Power Infusion, Desperate Prayer (chargé seulement si le sort est connu, donc nain).
- Buffs : Power Word: Shield, Renew, Inner Fire, Shadowform, Inner Focus (actif), Power Infusion (actif), Fear Ward (actif), Spirit Tap, Divine Spirit (4 rangs 14752, 14818, 14819, 27841 ; chargé si 14752 connu).
- Debuffs cible : Shadow Word: Pain, Vampiric Embrace, Devouring Plague, Shadow Weaving. Shadow Word: Pain et Devouring Plague sont des DoT : glow dans la fenêtre de rafraîchissement (équivalent du glow sous 3 s de Quazii).
- Barre de mana, règle des 5 s (12 sorts de mana).
- Rappels : Power Word: Fortitude (rangs et Prayer of Fortitude), Inner Fire, Shadowform, MANA BAS. Barre d'incantation présente. Weakened Soul (6788) suivi comme aura du joueur (known 17).
- Les buffs « (actif) » portent ce suffixe car l'id d'une aura doit être unique et le cooldown du même nom existe déjà.

## IDs à confirmer en jeu
- Vampiric Embrace 15286 : le DB2 le classe « buff » ; en Classic c'est un debuff sur la cible. Affiché en debuff cible, à vérifier.
- Shadow Weaving 15258 : « debuff cible / buff lanceur » selon le DB2. À vérifier sur la cible.
- Spirit Tap 15271 : aura déclenchée par 15270, à vérifier.
- Penance 402174 et Prayer of Mending 401859 : rang 1 = sort de talent, ID « non lu » hors wow-forever.gg.
- Mind Flay 15407 (règle des 5 s) : rang 1 présent seulement dans wow-forever.gg ; les rangs 2 à 6 comptent aussi par nom.

## Ignoré
- Weakened Soul grisant Power Word: Shield, rappel Shadowform en combat : le builder ne les permet pas (rappels hors combat seulement).
- Holy Concentration, Vampiric Touch, Psychic Horror, Hymn of Hope : écartés (absents de la liste).
- Debuff Holy Fire et ralentissement de Mind Flay : aucun ID d'aura dans le fichier.
- Smite, Flash Heal, etc. : sans recharge, utiles seulement pour la règle des 5 s.

## À tester en jeu
- Divine Spirit : icône à l'application du buff, absente si le sort n'est pas appris. Glow des DoT Pain et Plague en fin de durée.
- Les cooldowns Penance, Prayer of Mending, Shadow Word: Death s'affichent seulement si le sort est connu.
- Shadowform : buff et rappel (le rappel doit disparaître une fois en forme).
- Les icônes d'aura de cible en combat (valeurs secrètes) : Pain, Plague, Weaving, Embrace.
- Règle des 5 s : se déclenche après un sort de la liste, pas sur Fade ni Inner Fire.

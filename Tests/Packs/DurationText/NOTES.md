# Pack de vérification du texte de durée (Forever)

Vérifie en jeu `Private.GetDurationTextFormatter` (`WeakAuras/DurationText.lua`) sur le Bouclier de foudre (324, buff de 10 min).

## Fichiers

- `VerificationDurationText.lua` : générateur, renvoie la table d'export (groupe dynamique horizontal « Test - Texte de durée », 7 icônes « Aura (Modern) »).
- `PackDurationText.txt` : chaîne d'import `!WA:2!`.
- `VerificationPackDurationText.lua` : scénario du banc, charge le pack et valide les 7 auras `secretAura`.

```
lua Tests/Packs/AuraTool.lua . encode Tests/Packs/DurationText/VerificationDurationText.lua > Tests/Packs/DurationText/PackDurationText.txt
lua Tests/run.lua --scenario Tests/Packs/DurationText/VerificationPackDurationText.lua
```

## Réglages testés

Champs du sous-texte `%p` : `text_text_format_p_time_format`, `text_text_format_p_time_legacy_floor` (vrai = arrondi vers le bas, format 0), `text_text_format_p_time_dynamic_threshold`, `text_text_format_p_time_precision`. Chemin : `SecretAuraAppearance.lua` `BindDurationText`. L'icône 7 ajoute le filtre du trigger « Total Duration >= 1 » : le texte passe alors par les chiffres du cooldown (`SecretAuraSingle.lua` `styleCountdownNumbers`).

Les formats 1 et 2 ne sont pas proposés dans les options d'une aura « Aura (Modern) » (seulement Blizzard Default, Minutes and seconds, Seconds) : ils viennent de l'import. Ne pas modifier ces deux icônes dans les options.

## Texte attendu

Lecture : temps restant réel juste sous la valeur de la colonne (9:58,5 pour « 9:59 », 58,5 s pour « 59 s »). L'icône 1 sert de référence : quand elle affiche la valeur de la colonne, les autres doivent afficher la ligne correspondante.

| Icône (libellé) | 9:59 | 2:05 | 1:01 | 59 s | 12.3 s | 2.5 s |
|---|---|---|---|---|---|---|
| 1 `99 / M:SS` | 9:59 | 2:05 | 1:01 | 59 | 13 | 3 |
| 2 `0 / M:SS` | 9:58 | 2:04 | 1:00 | 58 | 12 | 2 |
| 3 `99 / Nm` | 9m | 2m | 1m | 59s | 13s | 3s |
| 4 `99 / Nm Ns` | 9m 59s | 2m 5s | 1m 1s | 59s | 13s | 3s |
| 5 `99 / secondes` | 599 | 125 | 61 | 59 | 13 | 3 |
| 6 `99 / M:SS <3 .1` | 9:59 | 2:05 | 1:01 | 59 | 13 | 2.5 |
| 7 `Total>=1 99 / M:SS <3 .1` | 9:59 | 2:05 | 1:01 | 59 | 13 | 2.5 |

Icône 3 : la minute vient de la division entière des secondes arrondies (599 s donne 9m). Si le jeu affiche 10m, 3m, 2m, l'arrondi s'applique à la minute : à signaler, pas forcément faux (l'ancien format Blizzard arrondissait à la minute supérieure).

Points de bascule à surveiller : passage de 1:00 à 59 (icônes 1 et 6 : « 60 » possible entre 59,0 et 60,0 s avec l'arrondi haut), passage à une décimale sous 3 s (icônes 6 et 7), rien d'affiché à 0.

## Non couvert

- `CDMAuraProgress.lua` (triggers du Cooldown Manager) : demande un trigger Cooldown Viewer, pas dans ce pack.
- `SecretAuraSingle.lua` repli `GetDurationTextFormatter(99, 0, 0)` (affichage « manquant » qui suit un autre trigger) : pas de réglage, non testé.
- Le banc n'émule pas `AuraContainer` ni `C_StringUtil` en rendu : le texte se vérifie en jeu seulement.

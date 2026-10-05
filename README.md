<img src=".github/logo.png" alt="Musca Auras logo" width="128" align="right">

# Musca Auras

The WeakAuras you know, running on WoW Forever (client 1.60.1).
Open the options with `/wa` or `/weakauras`, or with the minimap icon.

## ⚠ Before you import auras

WoW Forever looks like Classic, but it runs on the modern game engine (12.1).
That engine changed what addons are allowed to see, so many auras made for
Classic Era, SoD or Retail will not work as they are:

- Auras that read the combat log (CLEU triggers, "Combat Log" events) never
  fire. The combat log is closed to addons on this engine.
- Most combat data is hidden from addons during combat. Musca Auras
  lets the game draw it (timers, bars, texts set to only `%p` or `%s`), but conditions
  and thresholds on that data wait until combat ends.
- Some old game functions no longer exist. Custom code calling them errors
  and must be updated to the modern C_ API (`C_Spell`, `C_UnitAuras`, `C_Item`...).
- Talent load options are empty (use the Class and Specialization load option), and
  spells must be entered by ID.

In short: expect to adapt most of the auras you import, especially the ones
with custom code. Damage taken, for example, works through `UNIT_COMBAT:player`
instead of the combat log.

Read the [tutorial](TUTORIAL.md): how WeakAuras works on Forever, and
step-by-step recipes for auras that keep working in combat.

Coming from ForeverAuras? Paste your exported strings in the import window:
they are converted (tutorial, section 10).

## Installation

Copy the five folders `WeakAuras`, `WeakAurasArchive`, `WeakAurasModelPaths`,
`WeakAurasOptions` and `WeakAurasTemplates` into
`World of Warcraft/_classic_beta_/Interface/AddOns/`.

## Compatibility

Folder, slash commands and saved settings are the same as WeakAuras, so your
Wago imports and existing auras load without conversion.
Do not install it next to another WeakAuras build.

## Support

Found a bug? https://github.com/dldvlpr-addons-wow/Musca-Auras/issues

Discord: coming soon

## ⚖ License

Fork of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2) © The WeakAuras Team, with code from [ForeverAuras](https://github.com/neroxrw/foreverauras) (Neroxrw) and [M33kAuras](https://github.com/m33shoq/M33kAuras) (m33shoq). Changes © 2026 dldvlpr. [GPL v2](LICENSE), no warranty. Changes: [CHANGES.md](CHANGES.md). Data: talentsforever.com (CC-BY 4.0). Not affiliated with the WeakAuras Team or Blizzard Entertainment.

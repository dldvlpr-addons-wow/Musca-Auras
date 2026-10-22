# Musca Auras

Port of [WeakAuras](https://github.com/WeakAuras/WeakAuras2) 5.22.0 (Classic Era flavor) to WoW Forever 1.60.1,
a Classic client running on the modern 12.x engine (interface 16001).

Original work: The WeakAuras Team, GPL-2.0 (see `WeakAuras/LICENSE`).
Modifications: dldvlpr, GPL-2.0.
Versions up to 1.12 held code derived from ForeverAuras (Neroxrw, GPL-2.0), a WeakAuras fork for WoW Forever. All
of it is now rewritten from behavior specifications, without ForeverAuras code, as listed below. The lines still
shared with ForeverAuras 0.87.6 are fixed by the kept behavior: WoW API calls, saved field names, public names and
default values. Rewriting them again gives the same lines (2026-10-21 section).
The rewrites of 2026-10-04 changed local names and equivalent expressions only. The features "also found in
ForeverAuras" listed on 2026-10-04 were written for this fork, with ForeverAuras as the behavior reference only.
Rewritten without ForeverAuras code:
- on 2026-10-10: `WeakAuras/DurationText.lua`, `WeakAuras/SubRegionTypes/CDMDispel.lua`,
  `WeakAuras/SubRegionTypes/CDMDispelBorder.lua`, `WeakAuras/DispelTypeDisplay.lua`, `WeakAuras/CDMAuraProgress.lua`
  and `WeakAuras/CooldownViewerCatalog.lua`;
- on 2026-10-15: `WeakAuras/CDMBackground.lua`, `WeakAuras/CDMSetup.lua` and `WeakAuras/CooldownViewerTrigger.lua`,
  with the new `WeakAuras/CooldownViewerSelection.lua` and `WeakAuras/CooldownViewerStates.lua`;
  `WeakAuras/RegionTypes/AuraBarNative.lua` and `WeakAuras/ProgressTextureNative.lua` (without M33kAuras code
  either), around the new `WeakAuras/NativeProgressPainter.lua`; `WeakAurasOptions/AuraDisplayOptions.lua`,
  `WeakAurasOptions/ColorPalette.lua`, `WeakAurasOptions/CooldownViewerOptions.lua`,
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`, `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua`
  and the Cooldown Manager blocks of `WeakAurasOptions/GenericTrigger.lua`;
- on 2026-10-16: `WeakAuras/PrototypeSecretHelpers.lua`, `WeakAuras/SecretConditions.lua`,
  `WeakAuras/SecretAuraTrigger.lua`, `WeakAuras/SecretSpellCooldown.lua`, `WeakAuras/GenericTriggerRestricted.lua`,
  `WeakAuras/ClassicEraTriggers.lua`, `WeakAuras/TextStyle.lua`, the code of `WeakAuras/PlayerSpecialization.lua`,
  `WeakAurasOptions/AuraTriggerOptions.lua`, `WeakAurasOptions/TriggerSecretWarnings.lua`,
  `WeakAurasOptions/VersionCheck.lua`, `WeakAurasOptions/RegionOptions/GroupModernFlow.lua`,
  `WeakAurasOptions/SubRegionOptions/CDMDispel.lua`, `WeakAurasOptions/SubRegionOptions/CDMDispelBorder.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.lua` (still based on the AceGUI-3.0 ColorPicker
  widget), `WeakAuras/SecretAuraGlow.lua`, `WeakAuras/SecretAuraPreview.lua`, `WeakAuras/SecretAuraAppearance.lua`,
  `WeakAuras/SecretAuraConditions.lua`, `WeakAuras/SecretAuraFlow.lua` with the new `WeakAuras/SecretAuraAnchor.lua`,
  `WeakAuras/SecretAuraFlowShadow.lua`, `WeakAuras/SecretAuraFlowUnits.lua`, `WeakAuras/SecretAuraFlowGrid.lua` and
  `WeakAuras/SecretAuraFlowPreview.lua`, `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAuraSingle.lua`,
  the code of `WeakAuras/SecretAuraRanks.lua`, the talent data reader of `WeakAuras/Prototypes.lua`, and the fork
  code in the WeakAuras files listed on 2026-10-16, including the glow start check of
  `WeakAuras/SubRegionTypes/Glow.lua`;
- on 2026-10-17: `WeakAuras/CooldownViewerCatalog.lua` and `WeakAuras/SecretAuraAppearance.lua` again, and the fork
  blocks of `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/RegionTypes/Icon.lua`, `WeakAuras/CDMSetup.lua`,
  `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/ColorPalette.lua`, `WeakAurasOptions/CooldownViewerOptions.lua` and
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`;
- on 2026-10-21: `WeakAuras/SecretAuraAppearance.lua`, `WeakAuras/CooldownViewerCatalog.lua`,
  `WeakAuras/CooldownViewerSelection.lua`, `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/SecretAuraGlow.lua`,
  `WeakAuras/SecretAuraPreview.lua`, `WeakAuras/SpellCooldownState.lua`, `WeakAuras/BuffTriggerNativeFilter.lua`,
  `WeakAuras/SubRegionTypes/DispelIcon.lua`, `WeakAurasTemplates/TriggerTemplatesDataForever.lua`, and the fork code
  of `WeakAuras/RegionTypes/AuraBar.lua`, `WeakAuras/RegionTypes/ProgressTexture.lua`,
  `WeakAuras/SubRegionTypes/Border.lua`, `WeakAuras/Animations.lua`, `WeakAuras/Transmission.lua`,
  `WeakAurasOptions/LoadOptions.lua` and `WeakAurasOptions/OptionsFrames/Update.lua`. The lines still shared with
  ForeverAuras in `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasSpinBox.lua`,
  `WeakAurasOptions/OptionsFrames/FrameChooser.lua` and `WeakAurasOptions/SubRegionOptions/SubText.lua` are WoW API
  calls (`IsMouseOver`) and a public name (`IsCDMBuffText`), kept unchanged.
`WeakAuras/RegionTypes/ProgressTextureSecret.lua`, `WeakAuras/SubRegionTypes/SubTextNative.lua` and
`WeakAuras/BuffTriggerRestrictedAuras.lua`, created by the moves of 2026-10-04, hold code written for this fork only.
`WeakAuras/SecretRestrictions.lua`, created the same day, held code derived from ForeverAuras until 2026-10-16.
The rewritten files keep the saved field names and trigger types of ForeverAuras, so that its auras import as they
are. Thanks to Neroxrw for ForeverAuras.
Code derived from M33kAuras (m33shoq, GPL-2.0) was in `WeakAuras/RegionTypes/AuraBarNative.lua` and
`WeakAuras/ProgressTextureNative.lua` until their rewrite of 2026-10-15. Thanks to m33shoq for M33kAuras.
Specialization data in `WeakAuras/PlayerSpecialization.lua` comes from talentsforever.com under CC-BY 4.0, see `WeakAuras/SpecializationData-LICENSE.txt`, and the spell rank data in `WeakAuras/SecretAuraRanks.lua`
too, see `WeakAuras/SpellRankData-LICENSE.txt`.

This file lists every file changed from the upstream 5.22.0 release, as required by GPL-2.0 section 2a.

## 2026-10-22

Not yet tested in game: undo and redo of Start Collapsed, `/wa tutorial` in French, the random timers of
`/wa demo`. Headless test bench: 80 scenarios, 0 failed.

### Changed
- `/wa demo`: sample timers now get a random duration of 4 to 20 seconds and random stacks (1 to 5). An expired
  timer hides for 1 to 6 seconds, then starts again, like cooldowns and buffs in a fight. The timers that start
  together are spread at the start of the demo, and sample states made again during the demo (eye toggled, aura
  edited) get a demo timer too. Aura (Modern) samples now show the timer and stacks of their sample state. The demo
  ends when the options close. Files: `WeakAuras/WeakAuras.lua`, `WeakAuras/SecretAuraPreview.lua`,
  `WeakAurasOptions/WeakAurasOptions.lua`, `Tests/Scenarios/84_DemoRandomTimers.lua`.

- Author options: Start Collapsed on an option group now goes through the undo history. Undo and redo set the saved
  value back and collapse or expand the group on screen. Files: `WeakAurasOptions/AuthorOptions.lua`,
  `Tests/Scenarios/78_StartCollapsedUndo.lua`.
- `TUTORIAL.md` is now the only source of the in-game tutorial texts. `Tests/GenerateTutorial.py` rewrites the
  `blocks` table of `WeakAuras/ForeverTutorial.lua` from it; with `--check` it writes nothing and exits with code 1
  when the table is out of date. Text shown only in game sits in `<!-- game: ... -->` comments, import button labels
  in `<!-- import label: ... -->` comments. The generated table is identical to the previous one. Scenario 75 now
  also checks that every tutorial text has a French translation. Files: `TUTORIAL.md`,
  `WeakAuras/ForeverTutorial.lua`, `Tests/GenerateTutorial.py`, `Tests/Scenarios/75_TutorialCopies.lua`.
- `IsTargetInSwingRange`, `GetSpellCooldownDurationObject` and `IsSpellCooldownSecret` move from the global
  `WeakAuras` table to the private trigger environment, and the `WeakAuras.IsSecretStateActive` alias is removed.
  Custom code that called these four names through `WeakAuras` no longer works.
  Files: `WeakAuras/GenericTrigger.lua`, `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`,
  `WeakAuras/SecretRestrictions.lua`.
- Split the last five functions over 200 lines into file-level local functions, with no change of behavior:
  `Initialize` of the aura list button, `modify` of the icon and of the text sub-element, `replaceNameDescFuncs` of
  the common options and `GenericTrigger.Add`. New scenarios cover them first: 79 (aura list button menu and
  callbacks), 80 (custom triggers) and 83 (names and descriptions of a multiple selection). Files:
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`, `WeakAuras/RegionTypes/Icon.lua`,
  `WeakAuras/SubRegionTypes/SubText.lua`, `WeakAurasOptions/CommonOptions.lua`, `WeakAuras/GenericTrigger.lua`,
  `Tests/Scenarios/79_DisplayButtonInitialize.lua`, `Tests/Scenarios/80_GenericTriggerCustomAdd.lua`,
  `Tests/Scenarios/83_ReplaceNameDescFuncs.lua`.

### Fixed
- Options: sample timers stopped looping from the second opening of the options in a session (bug also in
  WeakAuras 5.22). File: `WeakAuras/WeakAuras.lua`.

## 2026-10-21

Released as 1.13.0. Tested in game on WoW Forever: the options toolbar and footer in French, and the combo points
of the Rogue HUD (text and pips) after a target change, in and out of combat. Not yet tested in game: Show Absorb and
Show Heal Absorb. Headless test bench: 75 scenarios, 0 failed. luacheck: 0 warnings in 259 files.

### Added
- Health trigger: added Show Absorb and Show Heal Absorb toggles. They store `absorb` and `healabsorb`
  (UnitGetTotalAbsorbs / UnitGetTotalHealAbsorbs) for text display and listen to UNIT_ABSORB_AMOUNT_CHANGED /
  UNIT_HEAL_ABSORB_AMOUNT_CHANGED. Both amounts are always secret on WoW Forever: they are shown through native text,
  kept out of the readable-state scrub, and give no numeric condition or threshold. Formatting a secret placeholder
  value now runs the formatter protected and falls back to the raw value. The absorb overlay on the health bar is not
  provided because it requires arithmetic on a secret value. Scenario 76 also checks that the absorb events are
  registered only with their toggle and that the amounts offer no condition. Files: `WeakAuras/Prototypes.lua`,
  `WeakAuras/WeakAuras.lua`, `WeakAuras/SubRegionTypes/SubTextNative.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`, `Tests/Harness/Units.lua`, `Tests/Scenarios/76_HealthAbsorbs.lua`.

### Changed
- All code derived from ForeverAuras is rewritten from behavior specifications, without reading the ForeverAuras or
  previous code (files listed in the header, "on 2026-10-21"). The behavior stays the same, with four differences
  from the first rewrite corrected after review: Cooldown Manager progress skips unloaded auras only while the options
  are closed (`WeakAuras/CDMAuraProgress.lua`), the Aura (Modern) preview walks sparse element lists
  (`WeakAuras/SecretAuraPreview.lua`), tiled border pieces keep their vertical texture coordinates, and a missing
  LibSharedMedia entry falls back to the default media (`WeakAuras/SecretAuraAppearance.lua`).
  `WeakAurasOptions/ClassPacks.lua` is regenerated from the rewritten templates, byte for byte identical.
  `README.md` and `DESCRIPTION.md` now credit ForeverAuras for import compatibility only.
- Split the two largest Lua files by responsibility, with no change of behavior. `WeakAuras/BlizzardAuraDisplay.lua`
  now holds the catalogs and the `Display` table; the rest moved to `WeakAuras/BlizzardAuraDisplayUnits.lua`,
  `BlizzardAuraDisplayTrigger.lua`, `BlizzardAuraDisplayMigration.lua`, `BlizzardAuraDisplaySounds.lua`,
  `BlizzardAuraDisplayValidation.lua`, `BlizzardAuraDisplayPlacement.lua`, `BlizzardAuraDisplayButtons.lua`,
  `BlizzardAuraDisplayInstances.lua`, `BlizzardAuraDisplayUnitRefresh.lua`, `BlizzardAuraDisplayQueues.lua`,
  `BlizzardAuraDisplayLifecycle.lua` and `BlizzardAuraDisplayEvents.lua`. `WeakAuras/SecretAuraSingle.lua` keeps the
  constants, helpers and predicates; the rest moved to `WeakAuras/SecretAuraSingleFallback.lua`,
  `SecretAuraSingleLearning.lua`, `SecretAuraSingleGates.lua`, `SecretAuraSingleGateDisplay.lua`,
  `SecretAuraSingleStatus.lua`, `SecretAuraSingleFollow.lua`, `SecretAuraSingleMissing.lua` and
  `SecretAuraSingleRemaining.lua`. The pieces share their locals through `Private.AuraDisplayShared` and
  `Private.AuraSingleShared`. `WeakAuras/WeakAuras.toc` lists the new files.
- Split the longest functions of the options editor and of the dynamic group region into smaller named local
  functions, with no change in behavior:
  - `addControlsForChange`, `addControlsForIfLine` and `addControlsForCondition` (condition editor)
  - `addAuthorModeOption`, `addUserModeOption` and the `group` control adder (custom options editor)
  - `modify` (dynamic group region)
  Files: `WeakAurasOptions/ConditionOptions.lua`, `WeakAurasOptions/AuthorOptions.lua`,
  `WeakAuras/RegionTypes/DynamicGroup.lua`.
- Player-facing texts rewritten without internal jargon ("secret", "native"), all routed through `L[]` with enUS and
  frFR. Labels renamed: "Native Filter" -> "Game Categories", "Secret Restrictions Active" -> "Game Hides Combat
  Data". The in-game tutorial gains section 10 "Coming from ForeverAuras" and its Secret values section now carries
  the non-player-target health note. Scenario 75 compares every tutorial section with `TUTORIAL.md`. Files:
  `WeakAuras/ForeverTutorial.lua`, `SecretAuraTrigger.lua`, `WeakAuras.lua` (welcome popup), `Prototypes.lua` (texts
  only), `BlizzardAuraDisplayButtons.lua`, `BlizzardAuraDisplaySounds.lua`, `BlizzardAuraDisplayValidation.lua`,
  `SecretAuraAppearance.lua`, `SecretAuraConditions.lua`, `Locales/enUS.lua`, `Locales/frFR.lua`;
  `WeakAurasOptions/TriggerSecretWarnings.lua`, `OptionsFrames/Update.lua`, `AuraDisplayOptions.lua`,
  `ActionOptions.lua`, `CooldownViewerOptions.lua`, `CommonOptions.lua`, `BuffTrigger2.lua`, `Locales/enUS.lua`,
  `Locales/frFR.lua`;
  `TUTORIAL.md`, `GUIDE.md`; `Tests/Scenarios` 31, 34, 39, 47, 50 and 75 (new).
- `WeakAuras/Compatibility.lua`: removed the dead branches on the global `GetSpellInfo`, `GetSpellTexture` and
  `IsUsableSpell`, absent from the WoW Forever client. `Private.ExecEnv.GetSpellInfo` is built on
  `C_Spell.GetSpellInfo`; `GetSpellName`, `GetSpellIcon` and `IsUsableSpell` map to `C_Spell.GetSpellName`,
  `C_Spell.GetSpellTexture` and `C_Spell.IsSpellUsable`.
- Templates: removed spell IDs absent from the WoW Forever client (in-game spell survey 1.60.1.70450): Season of
  Discovery Avenger's Shield 407669, Crusader Strike 407676, Hand of Reckoning 407631 (Paladin), Explosive Shot 409552
  and a duplicate entry reusing its ID (Hunter), Envenom 399963 (Rogue), and the Troll Berserking variants 26297,
  26296, 26635 (only 20554 remains). Metamorphosis 403789 and the other Season of Discovery IDs present in Forever are
  kept. File: `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`.
- Options window: the toolbar overflowed the window, most of all in French. Unused Auras, Replace and Hide
  Blizzard's CDM now show an icon or a checkbox alone, with their name in the tooltip, like Aura Set. The Guide
  button takes the width of its text. Shorter French labels: Verrouiller, Aimantation, Annuler, Rétablir,
  Mettre à jour, Signaler un bug. Files: `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`,
  `WeakAurasOptions/Locales/frFR.lua`.

### Fixed
- Scenario 32 used the wrong `Enum.SecrecyLevel` values. It now uses those of the client
  (`NeverSecret = 0, AlwaysSecret = 1, ContextuallySecret = 2`), and the case without a secrecy level uses a spell ID
  that is never secret, so the case fails if the trigger ignores the missing enum. File: `Tests/Scenarios/32_SecretTriggerContract.lua`.
  The pack notes record the in-game survey of 1.60.1.70450 (only the ComboPoints power type is never secret) in
  `Tests/Packs/Chaman/NOTES.md` and `Tests/Packs/Voleur/NOTES.md`, and the new file of each moved function in
  `Tests/Packs/DurationText/NOTES.md`.
- Power trigger, Combo Points on the player: the value stayed the same after a target change. On WoW Forever the
  combo points are stored on the target (`GetComboPoints("player", "target")`), and the client sends
  `PLAYER_TARGET_CHANGED` and `COMBO_TARGET_CHANGED`, not a power event, when they move. The trigger now listens to
  both through the existing `Private.WatchCOMBO_TARGET_CHANGED`, which was never called. The native threshold
  (combo point pips) is now computed from the readable combo point count instead of `UnitPowerPercent`, which
  does not follow the target. Files: `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`,
  `WeakAuras/PrototypeSecretHelpers.lua`, new scenario `Tests/Scenarios/77_ComboPointsTarget.lua`.

## 2026-10-19

Released as 1.12.0. Loaded in game on WoW Forever with the test pack
`Tests/Packs/Essai/PackTestEvolutionsForeverAuras.lua` (warrior and shaman), which covers the form filters by spell,
migration 92, specialization loads, the Caster Unit warning and the ForeverAuras imports. Not yet tested in game:
tags, Aura Sets, Undo/Redo, Replace, Aura Shown, Edit Mode placement, group conditions, `/wa demo`, the frozen value
padlock and Pixel Perfect. Headless test bench: 72 scenarios, 0 failed. luacheck: 0 warnings in 239 files.

### Added
- `/wa demo` opens the options and shows every loaded aura with its sample states, as the eye of the "Loaded/Standby"
  header does, to set up a HUD without a fight. `/wa demo <aura name>` shows only that aura, with its children for a
  group, and selects it. During combat, the command says to type it again after combat. Scenario 74 checks the
  command. Files: `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/WeakAurasOptions.lua`,
  `Tests/Scenarios/74_DemoCommand.lua`.
- ForeverAuras imports: an anchor or a glow frame set to another ForeverAuras aura (`ForeverAuras:<id>`) is renamed
  to `WeakAuras:<id>`. The `ForeverAuras` global points to `WeakAuras` when ForeverAuras is not loaded, for custom
  code that reaches it without the import renaming; inside custom code, `ForeverAuras` is the same read-only table as
  `WeakAuras`. An aura imported before this change keeps its `ForeverAuras:<id>` anchor: import it again. A condition whose trigger has no such condition shows
  "Incompatible condition" in the options, instead of an empty line. Scenario 16 checks the import. Files:
  `WeakAuras/ForeverAurasImport.lua`, `WeakAuras/AuraEnvironment.lua`, `WeakAurasOptions/ConditionOptions.lua`, `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `.luacheckrc`, `Tests/Scenarios/16_ForeverAurasImport.lua`.
- Scenario 46 covers the centered growth with Limit on clones (one shadow per clone, capped by the limit) and with
  Show On Missing (one shadow of one slot behind the center). File: `Tests/Scenarios/46_FlowLayoutContract.lua`.
- Spell Cast Succeeded: the secret warning shows when the Caster Unit is neither the player nor the pet, since
  `UNIT_SPELLCAST_SUCCEEDED` is secret for other casters, in or out of combat. The warning and the import report say
  so. Scenario 34 checks it. Files: `WeakAurasOptions/TriggerSecretWarnings.lua`,
  `WeakAurasOptions/OptionsFrames/Update.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/34_OptionsFilesContract.lua`.
- Talents: `ACTIVE_COMBAT_CONFIG_CHANGED` also refreshes the talent and specialization load conditions. Scenario 48
  checks it. Files: `WeakAuras/TalentReader.lua`, `Tests/Scenarios/48_Lot6aContract.lua`.
- Stance/Form/Aura: the trigger stores the form spell ID instead of its position on the stance bar, so a stance learned
  later no longer shifts the selection. Dire Bear Form counts as Bear Form, and every rank of Stealth, of the paladin
  auras and of the hunter aspects counts as its first rank. The "Form by position" option keeps the old behaviour.
  Migration 92 marks existing triggers as by position; during the login, an aura loaded only for the player's class
  gets its positions and its form conditions converted from the player's stance bar, and stays by position when a
  selected position does not resolve. The form value of the state, `%form` included, becomes the spell ID after the
  conversion; custom code that reads it is not converted. Form conditions get their values from the trigger.
  ForeverAuras imports now run the migrations from version 92. The warrior and druid templates use spell IDs.
  Scenarios 04, 16 and 19 check it. Files: `WeakAuras/Types.lua`, `WeakAuras/Prototypes.lua`,
  `WeakAuras/Modernize.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/WeakAuras.lua`,
  `WeakAuras/ForeverAurasImport.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`,
  `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`, `Tests/Scenarios/04_TemplateSpellIds.lua`,
  `Tests/Scenarios/16_ForeverAurasImport.lua`, `Tests/Scenarios/19_Modernize.lua`.
- Stance/Form/Aura: ForeverAuras imports convert the form ID filter into form spell IDs, from the game's form
  constants, for the selected mode only; a form ID without equivalent is removed with a warning, and a single one
  removes the filter. Form ID conditions get the form spell ID; a form condition by position or a form filter by
  position replaced by the import gets a warning. An aura loaded only by Forever specializations
  of the player's class gets its forms converted too. Migration 92 keeps a "Form by position" option already set.
  The trigger name shows the current form spell name, or "Humanoid". Scenarios 16 and 19 check it. Files:
  `WeakAuras/ForeverAurasImport.lua`, `WeakAuras/Modernize.lua`, `WeakAuras/PlayerSpecialization.lua`,
  `WeakAuras/Prototypes.lua`, `Tests/Scenarios/16_ForeverAurasImport.lua`, `Tests/Scenarios/19_Modernize.lua`.

### Changed
- Credits: the README and the CurseForge description say the fork includes code from ForeverAuras (Neroxrw, GPL v2),
  and that versions before 1.10 also held code from M33kAuras. Files: `README.md`, `DESCRIPTION.md`.
- Locales: the 225 texts of the code that had no locale entry are added in English and French (41 in the core, 184 in
  the options), so a French client shows them in French. The 91 entries no code uses any more are removed from every
  language: 87 in the core (bosses and zones of other contents, former conversion warnings), 3 in the options (former
  Discord and library credits) and "Bloodlust/Heroism" in the templates. Files: `WeakAuras/Locales/*.lua`,
  `WeakAurasOptions/Locales/*.lua`, `WeakAurasTemplates/Locales/*.lua`.
- Tags: a "Tags" field in the Information tab (comma separated, on every selected aura for a multi-selection). A
  search for `#raid` in the aura list shows the auras tagged "raid" and the members of a group tagged "raid". Tags
  are not exported, an update keeps them, and `/wa undelete` puts them back. Files: `WeakAurasOptions/InformationOptions.lua`,
  `WeakAurasOptions/WeakAurasOptions.lua` (search text), `WeakAuras/Types.lua` (`non_transmissable_fields`),
  `WeakAuras/AuraBackups.lua` (archive of a deleted aura), `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/59_UnusedAuras.lua`, `Tests/Scenarios/63_AuraTags.lua`.
- Undo and redo: the Undo and Redo buttons of the options window are shown in every build, and they now cover every
  tab, not only Information, Actions, Animations and Author. Each edit of a selected aura is compared with a copy taken
  when it was selected; edits less than one second apart (a slider drag, a multi-selection) make one step, and the
  history keeps the last 50 steps. Renaming, moving, deleting, converting and importing still clear the history, as
  does an edit of an aura not selected since the options window was opened; the other auras changed by the same
  operation are not recorded either. Undo and Redo also refresh the group, thumbnail and mover of the restored auras.
  Files: `WeakAuras/TimeMachine.lua`, `WeakAuras/WeakAuras.lua` (`WeakAuras.Add`, `Private.Convert`),
  `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`, `Tests/Scenarios/64_UndoRedo.lua`.
- Find and replace: the Replace button of the options toolbar asks for a value and its kind (spell, texture, font or
  sound), then its replacement, lists in the chat every value that would change, and replaces them after a
  confirmation. It covers the selected auras and their children, or every aura when none is selected. A value matches
  when it equals the searched text under a key of that kind (`auraspellids`, `auranames`, `cdmExactIDs`, `cdmNames`,
  `displayIcon`, `texture`, `text_font`, `sound`...), or in a list held by such a key; the settings of the kind
  (`text_fontSize`, `iconSource`, `sound_channel`...) are not. A number is only replaced by a number, and a value
  changed between the preview and the confirmation is left out. The replacement is one step of the undo history, and
  Undo and Redo now refresh the thumbnails of the auras they change. A condition change that sets one property
  (`property` and `value` fields) is not searched, except the sound of a sound change. Files: `WeakAuras/ReplaceValues.lua` (new), `WeakAuras/WeakAuras.toc`,
  `WeakAurasOptions/WeakAurasOptions.lua`, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/65_ReplaceValues.lua`.
- Trigger "Aura Shown" (Events category): active while another aura is shown, or hidden with Inverse. The watched
  aura is stored by uid, so a rename keeps the link. The watcher follows one frame later: a change of shown state
  queues the event `WA_AURA_SHOWN:<uid>` for the next frame, only when an aura watches it. Auras that watch each other
  in a loop never show, Inverse included, whichever of their triggers closes the loop; an aura that only watches one of
  them still follows it. Pause (options open) does not wake the watchers. An import as a copy, a duplicated group and
  a uid change in /wa point the watch at the new uid of the watched aura. With no aura chosen, or a reference that is
  not a uid, the trigger watches nothing and never shows, Inverse included. Files:
  `WeakAuras/AuraShownTrigger.lua` (new), `WeakAuras/WeakAuras.toc`, `WeakAuras/GenericTrigger.lua`,
  `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/OptionsFrames/Update.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`, `Tests/Scenarios/66_AuraShownTrigger.lua`.
- Aura sets per character: the "Aura Set" button of the toolbar picks a tag for the current character, which then
  loads only the auras that carry this tag, themselves or through one of their groups. "#pvp" names the same tag as
  "pvp". An empty tag loads every aura again. While the name of the character is secret, every aura loads; the set
  applies once the name is readable. The choice is kept in `WeakAurasSaved.characterAuraSets` by "Name-Realm", so
  each character of the account keeps its own HUD from the same auras. WoW Forever has no specialization, so the set
  is per character only. The tooltip of an unloaded aura names the set it is out of. Files: `WeakAuras/AuraSets.lua`
  (new), `WeakAuras/WeakAuras.toc`,
  `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/WeakAurasOptions.lua`, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/67_AuraSets.lua`.
- Placement with the Edit Mode: while the Edit Mode of Blizzard is open, each top-level aura anchored to the screen and
  loaded, or waiting for a load condition such as combat, gets a labelled box, shown even when the aura is not.
  Dragging the box moves the aura and saves its offsets, undoable in /wa. Auras anchored to a unit, a nameplate, the
  mouse or a custom frame, groups spread over unit frames, and protected regions, get none. The boxes hide while a
  settings panel of the Edit Mode is open, and stay under the selections of Blizzard. An aura added, loaded, renamed or
  deleted meanwhile gets, keeps or loses its box. With Snap on and the grid shown, a dropped box sticks to the nearest
  grid line by its edges or its center, within 8 pixels, like the frames of Blizzard. "Revert All Changes" also puts
  back the auras moved since the Edit Mode opened or its layout was saved; a move enables the button. Leaving the Edit
  Mode without saving keeps the auras where they were dropped. /wa, when open, shows the new offsets. The box of a
  group with sub groups covers their children where they are drawn, at the scale of each sub group; the border of
  such a group follows too. Files: `WeakAuras/EditModePlacement.lua`
  (new), `WeakAuras/WeakAuras.toc`, `WeakAuras/RegionTypes/Group.lua`, `Tests/Scenarios/68_EditModePlacement.lua`.
- Frozen value marker: while the combat restriction lasts, an aura with an Aura trigger shows a small padlock at its
  top right corner, since what it shows may be out of date. The padlock is 14 pixels, down to 8 on a small icon. Health
  and power triggers get none: they never freeze, they show the secret values or turn inactive. "Hide Frozen Value
  Padlock" in Size & Position turns it
  off per aura. Groups, empty regions, Aura (Modern) and CDM auras, and Aura triggers that use only native filters get
  none, since they still follow the secret auras. Files: `WeakAuras/FrozenMarker.lua` (new),
  `WeakAuras/BuffTrigger2.lua`, `WeakAuras/WeakAuras.toc`, `WeakAuras/RegionTypes/RegionPrototype.lua`,
  `WeakAurasOptions/CommonOptions.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/69_FrozenMarker.lua`.
- Pixel perfect option: "Pixel Perfect" in Size & Position snaps the textures of the aura to the screen pixels, for
  sharp edges. Glows keep their own snapping, their textures are shared with other auras. Textures created after the
  aura is loaded (extra bars, CDM and Modern aura buttons) snap when created. Off by default, since
  progress and slides then move by whole pixels and existing auras would shift. Turned off again, each texture gets its
  own snapping back. Files: `WeakAuras/PixelSnapping.lua` (new),
  `WeakAuras/WeakAuras.toc`, `WeakAuras/WeakAuras.lua`, `WeakAuras/RegionTypes/AuraBar.lua`,
  `WeakAuras/RegionTypes/AuraBarNative.lua`, `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/SecretAuraSingle.lua`,
  `WeakAuras/SecretAuraFlowGrid.lua`, `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAurasOptions/CommonOptions.lua`,
  locales enUS and frFR, `Tests/Harness/Frames.lua` (snapping getters), `Tests/Scenarios/70_PixelSnapping.lua`.
- Group conditions: the Conditions tab of a group shows "Group Conditions" above "Children Conditions". A condition
  of the group uses the global checks (combat, etc.) and changes the group itself: alpha, offsets, sound, chat message
  or custom code; the children follow its alpha and its offsets. A group runs its conditions while one of its children
  is loaded and the options are closed; when they stop, the group gets its settings back and a sound or a message plays
  again the next time. "Children Conditions" still edits the conditions of all the children at once. Files:
  `WeakAuras/Conditions.lua`, `WeakAuras/WeakAuras.lua`, `WeakAuras/RegionTypes/RegionPrototype.lua`,
  `WeakAuras/RegionTypes/Group.lua`, `WeakAuras/RegionTypes/DynamicGroup.lua`,
  `WeakAurasOptions/ConditionOptions.lua`, locales enUS and frFR, `Tests/Scenarios/36_OptionsBlocksContract.lua`,
  `Tests/Scenarios/71_GroupConditions.lua`.
- Cleanup without effect on the game: the `Globe-Main` and `Globe-Post` lines of the four TOC files, the
  commented-out blocks of `WeakAurasOptions/Libs/LibUIDropDownMenu/LibUIDropDownMenu.xml` and
  `WeakAurasOptions/Libs/AceConfig-3.0/AceConfig-3.0.xml`, and an obsolete TODO of `WeakAuras/BuffTrigger2.lua`
  are removed, with the unused textures `WeakAuras/Media/Textures/editdown.tga` and `logo_64_nobg.tga`.
- The `## Notes-*` lines of the TOC files, upstream WeakAuras text in five languages, are removed; the English
  `## Notes:` of Options, Model Paths and Templates now names Musca Auras. The unused textures
  `WeakAuras/Media/Textures/logo_256_round.tga` and `logo_256_round_pride.tga` are removed.
- Hot paths: `Private.ScanEvents` of `WeakAuras/GenericTrigger.lua` returns before building its profiling label
  when no aura listens to the event, and the player movement watcher stops its `OnUpdate` once the last aura that
  watches movement or speed is unloaded (it ran until the next reload before). Loading any aura that listens to
  these events restarts it, custom triggers included. A new scenario checks the stop and the restart.
- The talent reader leaves `WeakAuras/Prototypes.lua` for its own file, `WeakAuras/TalentReader.lua`, loaded after
  `WeakAuras/PlayerSpecialization.lua`. The `Private.talentInfo` table, which nothing read, goes, and so does the
  second read of the talents one second after login, whose result was thrown away. The talent check frame,
  `WeakAuras.GetTalentById` and `WeakAuras.CheckTalentId` keep the WeakAuras code, credited in the file header.
- `Private.Modernize` of `WeakAuras/Modernize.lua` is no longer one function of 2 300 lines: each version upgrade is
  its own function in an ordered list, run on the data saved before that version, and the repair of data saved by
  version 49 runs on that version only. The order and the code of the upgrades do not change: on the 1 404 auras of
  the test packs of `Tests/Packs` and of a ForeverAuras export, started from every version between 1 and 92, the old and the new
  code give the same data. Scenario 19 checks the version 49 repair.
- Purge of the flavor branches: the add-on only runs on WoW Forever, so every branch for Retail, Mists, Cataclysm,
  Wrath and TBC is removed from 27 files of `WeakAuras`, `WeakAurasOptions` and `WeakAurasTemplates`, and only the
  Classic Era branch is kept (about 4 000 lines removed, 3 200 net). The trigger and load arguments disabled on
  Forever are removed from `WeakAuras/Prototypes.lua`, except the hidden load arguments that the load function receives by
  position, and the `enable = true` and `hidden = false` fields are left at their default. A new scenario checks that
  the race and level load options still match. Also removed: the "Modern Blizzard" time formatter (the option already
  fell back to the built-in formatter), the always hidden "Filter by Specialization", "Filter by Arena Spec" and
  "Ignore out of casting range" options of the aura trigger, the Retail addon compartment entry, the pet battle guard
  of the load scan, and the helpers left unused. The flavor functions of `WeakAuras/Init.lua` stay
  defined for custom code, and five Retail globals leave `.luacheckrc`. The 125 locale entries only these branches
  used are removed from every language (111 in `WeakAuras`, 14 in `WeakAurasOptions`).
- The Currency trigger, already removed on Forever, loses its code: its prototype in `WeakAuras/Prototypes.lua`, the
  currency list of `WeakAuras/Types.lua`, the two currency helpers of `WeakAuras/GenericTrigger.lua`, and its 20 entries
  in every locale. The 40 global declarations that no file uses any more leave `.luacheckrc`, and an empty `if` of
  `WeakAurasOptions/OptionsFrames/Update.lua` is removed.
- Seven triggers that Classic never offered lose their prototype in `WeakAuras/Prototypes.lua`, which only deleted
  them at load: Alternate Power, Spell Activation Overlay, PvP Talent Selected, Loot Specialization, Evoker Essence,
  Death Knight Rune and Equipment Set. The rune and essence value lists of `WeakAuras/Types.lua`, which only these
  triggers read, go too, and so do the unreachable currency branches of `WeakAurasOptions/LoadOptions.lua`. The 34
  locale entries left unused leave every language (33 in `WeakAuras`, 1 in `WeakAurasOptions`). The matching public
  `WeakAuras.*` functions stay for custom code.

### Fixed
- The nameplate target watcher of `WeakAuras/GenericTrigger.lua` is registered in `Private.frames` once created, so
  `WeakAuras.ProfileFrames` lists it (it registered `nil` before).

## 2026-10-18

Released as 1.11.0. Tested in game on WoW Forever with the Shaman test pack `Tests/Packs/Essai/PackTestChaman.lua`:
partial import, trigger expression, search, condition copy and paste, greyed out options and classic mode, CPU
warning, secret value text, `/wa pstart combat` with the window closed. Headless test bench: 60 scenarios, 0 failed. luacheck: 0 warnings in 232 files.

### Changed
- Class packs 1.12.0: the Shaman healing spells (Healing Wave, Lesser Healing Wave, Chain Heal, Healing Rain) load in
  the Restoration specialization only, Lava Lash and Molten Blast in Enhancement only; a Druid cooldown limited to a
  form (Dash, Enrage, Frenzied Regeneration) now shows its buff, then its cooldown, in one icon (trigger expression),
  and its separate "(active)" buff icon is gone. The Warrior pack is unchanged: a stance buff outlives the stance, and
  the merged icon would hide it after a stance change. The ForeverAuras packs keep the former layout. Files:
  `Tests/Packs/PackBuilder.lua`, `Tests/Packs/VerificationPack.lua` (trigger expressions must compile),
  `Tests/Packs/{Chaman,Druide}/Pack<Class>.lua`, the Shaman and Druid pack strings, `WeakAurasOptions/ClassPacks.lua`,
  `WeakAuras/WeakAuras.lua` (`CLASS_PACK_VERSION`).
- Class packs 1.11.0: the mana bar turns red under 30 % through a secret power percent condition, without the red
  copy laid over it (the ForeverAuras packs keep the copy); reminders that do not track an aura pulse (icon) or
  flash (text); a "Not in melee range" text for the melee specs (Shaman, Rogue, Paladin, Warrior, Druid cat and
  bear), read in combat, Musca packs only; the Paladin "Missing: Seal" reminder loads in combat only, the Priest Shadowform reminder in
  and out of combat. Files: `Tests/Packs/PackBuilder.lua`, `Tests/Packs/<Class>/Pack<Class>.lua` (Shaman, Rogue,
  Paladin, Warrior, Druid, Priest), the 18 pack strings, `WeakAurasOptions/ClassPacks.lua`, `WeakAuras/WeakAuras.lua`
  (`CLASS_PACK_VERSION`). Bench: `VerificationPack` OK on the 9 classes, 59 scenarios OK.
- French translation of the 20 core texts and 2 options texts that had none (stats, cooldown desaturation, timer
  hiding, threshold alpha, range check, class pack). Files: `WeakAuras/Locales/frFR.lua`,
  `WeakAurasOptions/Locales/frFR.lua`.
- Talent load options are no longer described as empty: they list the talents of your own specialization. Files:
  `README.md`, `TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`, `WeakAuras/WeakAuras.lua` (first login popup).
- `Tests/Packs/Chaman/NOTES.md`, `Tests/Packs/Paladin/NOTES.md`, `Tests/Packs/DurationText/NOTES.md`: the bench
  commands set `TEMP` and `WOW_UI_SOURCE`.
- The aura list search also matches the description, the spell names and IDs and item names of the
  triggers (Aura, Cast, Cooldown Manager, spell and item triggers), and the texts of the aura. File: `WeakAurasOptions/WeakAurasOptions.lua`.
- Aura update: new category "Fonts & Text Style", unchecked by default. It holds the font, outline and shadow
  of the texts, and the size of the texts of icons and bars (a Text aura keeps its size in "Size & Position", in "Group Arrangement"
  inside a group), so
  an update of the display keeps your fonts. Files: `WeakAuras/Types.lua`,
  `WeakAurasOptions/OptionsFrames/Update.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`,
  `Tests/Scenarios/56_UpdateFontCategory.lua`.
- Copy and paste of a single trigger or condition: "Copy Trigger" at the end of each trigger, "Copy Condition"
  at the end of each condition, then "Paste Trigger" or "Paste Condition" next to the add button of any aura adds
  it after the existing ones. A pasted condition keeps its trigger numbers, a number past the triggers of the aura
  is cleared. A paste that an Aura (Modern) cannot use is undone, with a message in the chat.
  Files: `WeakAurasOptions/TriggerOptions.lua`, `WeakAurasOptions/ConditionOptions.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`,
  `Tests/Scenarios/57_PasteConditionTriggers.lua`.
- Trigger Expression: a new "Required for Activation" mode combines the triggers with an expression such as
  `1 and (2 or not 3)`, without Lua code. The expression is checked when it is entered, an error is shown under the
  field, and trigger numbers follow when a trigger is moved or deleted. Files: `WeakAuras/TriggerExpression.lua`,
  `WeakAuras/WeakAuras.toc`, `WeakAuras/WeakAuras.lua`, `WeakAuras/Types.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`, `WeakAurasOptions/TriggerOptions.lua`, `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/58_TriggerExpression.lua`.
- Unused Auras: a new toolbar button lists in the chat the auras no character of the account loaded for 30 days and
  the empty groups, a whole unused group in place of its auras, then asks to delete them. Load dates are counted from
  the first login with this version, and a new or imported aura counts as loaded when it is added. Every aura deleted
  from the options is now kept for 30 days in WeakAurasArchive as an export string, and an aura that cannot be archived
  is not deleted. `/wa deleted` lists them and `/wa undelete <number>` opens the import window on one. Files:
  `WeakAuras/UnusedAuras.lua`, `WeakAuras/AuraBackups.lua`, `WeakAuras/WeakAuras.toc`, `WeakAuras/WeakAuras.lua`,
  `WeakAurasOptions/WeakAurasOptions.lua`, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`,
  `WeakAurasOptions/Locales/enUS.lua`, `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/59_UnusedAuras.lua`.
- CPU cost: after a profiling (`/wa pstart`, then `/wa pstop`), each aura that ran during it shows a badge colored by
  its cost (green under 0.1 ms per second, yellow under 1 ms, red above), with the cost and the longest run in its
  tooltip. A click opens the profiling window with its results. A custom trigger or custom text that runs its code on
  each frame without an update throttle, or a custom event trigger on `FRAME_UPDATE`, gets a warning. Files:
  `WeakAuras/Profiling.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`, `WeakAurasOptions/WeakAurasOptions.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`, `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/60_CpuCost.lua`.
- Secret value text: a secret value or total in a text now takes the number format chosen in the
  options (abbreviated number, precision). A format that needs to read the number, such as a time or a rounding, keeps
  the raw value, and a secret number is not padded. Files: `WeakAuras/SubRegionTypes/SubTextNative.lua`,
  `WeakAuras/Types.lua`, `Tests/Scenarios/61_SecretAbbreviatedText.lua`.
- Greyed out options explained: each display option greyed out by Aura (Modern) now gives its own reason in its
  tooltip, such as a display that ignores the mouse or a bar filled by the game. Under the note of the group, a "Switch to classic
  mode" button changes the Aura (Modern) triggers to Aura after a confirmation, except in a Flow group. Files:
  `WeakAurasOptions/AuraDisplayOptions.lua`, `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/31_OptionsContract.lua`.
- Partial import: importing a new group, or a copy of a group, now lists its child auras with a checkbox each.
  An unchecked aura is left out of the import, with its own children. Unchecking a group unchecks its content, and
  checking an aura checks the groups above it. Updating an existing group does not change. Files:
  `WeakAurasOptions/OptionsFrames/Update.lua`, `WeakAurasOptions/Locales/enUS.lua`,
  `WeakAurasOptions/Locales/frFR.lua`, `Tests/Scenarios/62_PartialImport.lua`.

### Fixed
- Aura (Modern) background follows every restyle: it takes the crop, rotation, mirror and offset of the aura, and a
  partial ring no longer shows a full disc behind it. File: `WeakAuras/ProgressTextureNative.lua`.
- A spell description whose only duration is 0 no longer counts as a known duration. File:
  `WeakAuras/SecretAuraSingle.lua`.
- Cooldown Manager catalog reads are protected against API errors. Files: `WeakAuras/CooldownViewerCatalog.lua`,
  `WeakAuras/CooldownViewerSelection.lua`.
- Secret checks: the element glow tests secrecy before the size, and `WeakAuras/CDMBackground.lua` uses the shared
  helper. File: `WeakAuras/SecretAuraGlow.lua`.
- `/wa pstart combat` and `/wa pstart encounter` now profile the next combat or encounter even when the profiling
  window was never opened: the event handler was set when the window first showed. Opening the window
  (`/wa pshow`, minimap button) now lists the results of the last profiling, also one that ran with the window
  closed. The list fills when the window really shows, so the window also works when first opened with the
  interface hidden (Alt+Z). Files: `WeakAuras/Profiling.lua`, `Tests/Scenarios/60_CpuCost.lua`.

## 2026-10-17

Released as 1.10.0. Headless test bench: 53 scenarios, 0 failed.

### Added
- Conditions on a secret health or power value: "Health", "Health (%)", "Health Deficit", "Power", "Power (%)" and
  "Power Deficit" with `<`, `<=`, `>` or `>=` now drive the secret capable properties (Alpha, Color, Desaturate)
  when the value is secret, in
  combat and, for mana, out of combat. The engine reads the unit percent through a step curve
  (`UnitHealthPercent` or `UnitPowerPercent`); a raw value or a deficit is turned into a percent with the readable
  maximum, and stays ignored when the maximum is secret. In an AND or OR, the percent test is placed last, after the
  tests without a curve. Limits: a curve condition (percent or timer) placed after another secret condition on the
  same property does not stack on it, two curve tests in one AND or OR do not combine, and the other properties
  still ignore the condition while the value is secret. A bool condition placed after a curve condition stacks on it.
  Files: `WeakAuras/SecretConditions.lua` (test kind "percent", `Private.ExecEnv.SecretPercentSelect`),
  `WeakAuras/PrototypeSecretHelpers.lua` (`Private.ExecEnv.UnitPercentStep`, step curves shared with
  `ThresholdAlpha`), `WeakAuras/Prototypes.lua` (`conditionSecretPercent` on the six arguments),
  `WeakAuras/GenericTrigger.lua` (copied to the condition template as `secretPercent`).
- Text region: Alpha property (default 1), usable in conditions. File: `WeakAuras/RegionTypes/Text.lua`.
- Secret conditions on sub elements: Visibility of the sub text, border, glow, texture, circular and linear progress
  textures, stop motion and tick follows a secret condition through the sub element alpha (a hidden sub element is
  shown at alpha 0), and is restored when the value turns readable or the sub element is released. Desaturate of
  the texture, circular and linear progress texture, stop motion and tick sub elements, and of the foreground and
  background of the Progress Texture and Stop Motion regions, takes a secret value. Color of the sub text, border,
  glow, texture, progress textures, stop motion, tick, and the icon, background and spark colors of the bar region,
  takes a secret value. A secret alpha on the color of an Action Button glow is replaced by 1, the glow computes
  with it. Limits: the bar gradient end color (`barColor2`), the Model sub element, the dispel sub elements, the
  bar icon visibility, and size, position and visibility through `SetShown` stay on the readable path. A sub
  element shown at alpha 0 runs its start animation hidden: a timed stop motion in "once" mode can be on its last
  frame when the condition turns true, and restarts from frame 0 when the value turns readable; the Action Button
  glow entry animation and the Proc glow start animation play hidden the same way.
  Files: `WeakAuras/SecretConditions.lua` (`secretSetter` for any property type, `secretRestore`,
  `Private.SetSecretSubRegionVisible`, `Private.ClearSecretSubRegionVisible`), `WeakAuras/WeakAuras.lua` (sub
  element release), `WeakAuras/BaseRegions/Texture.lua`, `WeakAuras/BaseRegions/CircularProgressTexture.lua`,
  `WeakAuras/BaseRegions/LinearProgressTexture.lua`, `WeakAuras/BaseRegions/StopMotion.lua` (`SetDesaturation`),
  `WeakAuras/SubRegionTypes/Texture.lua`, `WeakAuras/SubRegionTypes/CircularProgressTexture.lua`,
  `WeakAuras/SubRegionTypes/LinearProgressTexture.lua`, `WeakAuras/SubRegionTypes/StopMotion.lua`,
  `WeakAuras/SubRegionTypes/Tick.lua`, `WeakAuras/SubRegionTypes/Border.lua`, `WeakAuras/SubRegionTypes/SubText.lua`,
  `WeakAuras/SubRegionTypes/Glow.lua`, `WeakAuras/RegionTypes/ProgressTexture.lua`,
  `WeakAuras/RegionTypes/StopMotion.lua`, `WeakAuras/RegionTypes/AuraBar.lua`.
- Text region: a condition that changes the text follows a secret condition. The base text and each condition text
  are drawn as layered font strings with the main text style; a secret alpha shows the one the conditions select.
  Each layer alpha is a product of factors, one per later condition, carried by parent frames, so several curve
  conditions on the text stack. The main text comes back when the value turns readable. Limits: the region size
  follows the main text only, and `%c` in a condition text uses the custom text computed for the main text.
  A call to `Color` from custom code, or a color animation, repaints the layers at once, without waiting for the next
  text update.
  Files: `WeakAuras/RegionTypes/Text.lua` (`SetSecretTextLayers`, `ClearSecretTextLayers`, `Color`, `ColorAnim`),
  `WeakAuras/SecretConditions.lua` (layer properties).
- `Tests/Harness/Units.lua`: `UnitHealthPercent` and `UnitPowerPercent` with a curve.
- `Tests/Harness/Frames.lua`: `SetDesaturation`, `GetDesaturation`, `SetTextColor` and `GetTextColor`;
  `SetDesaturated` also sets the desaturation read by `GetDesaturation`. `SetGradient` keeps its colors, and
  `SetVertexColor` clears them, as in game.
- `Tests/Harness/WowApi.lua`: `table.indexof`, used by `tIndexOf`.
- `Tests/Harness/Secret.lua`: `Secret.Wrap` returns a value that is already secret as it is, without a second wrap.
- `Tests/Scenarios/55_SecretSubRegionConditions.lua`: sub text, border, glow and texture visibility, colors and
  desaturation from a secret power percent; tick, circular progress, linear progress and stop motion sub elements
  of a bar, bar color with a gradient (plain secret color), bar icon desaturation, bar icon, background and spark
  colors, and Action Button glow color with its secret alpha replaced by 1; text layers with two curve conditions,
  their color after `Color`, and the number of layers changed by a modification; release of the sub elements on a
  modification; a "spell usable" bool condition stacked on a secret power percent condition, through a real
  cooldown trigger; in and out of combat, and the readable restore of the icon sub elements, of the bar gradient
  and icon desaturation, and of the text.
- `Tests/Scenarios/54_SecretPercentConditions.lua`: alpha on text and icon from a secret power percent, raw value and
  deficit, AND with a readable test, color from a secret health percent, in and out of combat, and the "Warlock - LOW
  MANA" aura of the ForeverAuras warlock pack hidden at full mana.
- Condition property "Looping Animation" (`conditionAnimation`): while the condition is true, the aura plays the
  chosen main animation preset instead of its own main animation, which comes back when the condition turns false.
  A running start or finish animation is not cut: the condition animation starts when the start animation ends.
  In combat, on a condition that reads a secret value, the property waits for the end of combat like the other
  properties that are not secret capable. A preset that needs scale or rotation is ignored on a region without it.
  Files: `WeakAuras/RegionTypes/RegionPrototype.lua` (property, setter `SetConditionAnimation`, main animation
  start), `WeakAuras/WeakAuras.lua` (main animation restart after a simple change in the options),
  `WeakAuras/Animations.lua` (`Private.IsMainAnimationReplaceable`),
  `WeakAuras/Conditions.lua` (a setter property can give a `resetValue` used when the aura data has no value),
  `WeakAuras/Locales/enUS.lua` and `WeakAuras/Locales/frFR.lua`.
- `Tests/Scenarios/53_ConditionAnimation.lua`: condition animation start and stop, main animation restored, start
  and finish animations kept, simple change, preset not supported by the region.
- `Tests/Scenarios/52_RemovedFunctionReplacements.lua`: replacements of the removed functions in custom code.
- `Tests/Scenarios/49_CooldownViewerCatalogContract.lua`: Cooldown Manager catalog exports, categories, identity,
  aura and cooldown state, refresh event and countdown text.
- `Tests/Scenarios/50_AppearanceContract.lua`: Aura (Modern) appearance exports, migration, frame levels, icon,
  cooldown, bar, text, sub elements, border and Masque.
- `Tests/Scenarios/51_Lot7cBlocksContract.lua`: fork blocks of the Cooldown Manager aura progress, icon region,
  Cooldown Manager setup, `pAdd` warnings, color palette and Cooldown Manager and secret aura trigger options.

### Changed
- `.luacheckrc`: `CANCEL` is a known game global, used by the backup restore popup in `WeakAuras/WeakAuras.lua`.
- `WeakAuras/WeakAuras.lua`: `CLASS_PACK_VERSION` is 1.10.0, so the login popup offers the class pack update once.
- `WeakAuras/CooldownViewerCatalog.lua` and `WeakAuras/SecretAuraAppearance.lua`: rewritten from a behavior
  specification, without reading the previous code or ForeverAuras. Behavior unchanged. The border texture
  coordinates follow `Blizzard_SharedXML/Backdrop.lua`.
- `WeakAuras/CDMAuraProgress.lua` (native container, `Modify`, `Style`, `Update`), `WeakAuras/RegionTypes/Icon.lua`
  (cooldown draw state, `UpdateValue`, `UpdateTime`, `PreShow`), `WeakAuras/CDMSetup.lua` (detached layout),
  `WeakAuras/WeakAuras.lua` (Blizzard aura display warnings in `pAdd`), `WeakAurasOptions/ColorPalette.lua` (palette
  panel), `WeakAurasOptions/CooldownViewerOptions.lua` (options context) and
  `WeakAurasOptions/SecretAuraTriggerOptions.lua` (options assembly): fork blocks rewritten the same way. Behavior
  unchanged. Comments removed from `WeakAuras/CDMSetup.lua` and `WeakAurasOptions/ColorPalette.lua`.
- Lines still shared with ForeverAuras after these rewrites, where the shared behavior fixes the code: cooldown
  setter calls and texture element defaults, style call order and duration text migration defaults in
  `WeakAuras/SecretAuraAppearance.lua`; cooldown completion, frame cache and item name fallback in
  `WeakAuras/CooldownViewerCatalog.lua`; cooldown setters in `WeakAuras/CDMAuraProgress.lua`; native progress guards
  in `WeakAuras/RegionTypes/Icon.lua`; Blizzard layout manager setup in `WeakAuras/CDMSetup.lua`; warning resets in
  `WeakAuras/WeakAuras.lua`; backdrop colors in `WeakAurasOptions/ColorPalette.lua`; options assembly in
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`.
- `Tests/GenerateSpellData.py`: reads files with Windows line endings and writes each file back with its own line
  endings.
- `WeakAuras/SecretAuraGlow.lua`: the glow size check tests for a missing width or height before the secret check,
  without comparing a value that may be secret.
- `Tests/Scenarios/48_Lot6aContract.lua`: checks that hiding the preview notice leaves its text unchanged.
  `Tests/Scenarios/39_AppearanceContract.lua`: no longer passes an unused fifth argument to `StyleAppearance`.
- Comments removed from `WeakAurasOptions/CooldownViewerOptions.lua` and
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`. `WeakAuras/CDMAuraProgress.lua` gets the fork header.
- `CHANGES.md`: the header gives the M33kAuras history.
- `Tests/Packs/PackBuilder.lua`: the shaman totem buff icons mark their display as shared, so loading the pack no
  longer replaces their sub-elements, and keep `inverse` like the other icons. `Tests/Packs/Chaman/PackChaman.txt`,
  `Tests/Packs/Chaman/PackChamanForeverAuras.txt` and `WeakAurasOptions/ClassPacks.lua`
  regenerated.
- `Tests/Packs/Guerrier/PackTestGuerrier10.lua`: new level 10 warrior test pack, with its import string.
- `WeakAuras/AuraEnvironment.lua`: custom code gets replacements for `UnitAura`, `UnitBuff`, `UnitDebuff`,
  `GetSpellInfo`, `GetSpellTexture`, `IsUsableSpell`, `GetSpellCooldown` and `GetSpellCharges`, which do not exist
  on WoW Forever. They are built on `C_UnitAuras`, `AuraUtil` and `C_Spell` and return the values of the original
  functions in the same order, and return nothing for a spell book slot. A function still defined by the game is
  used instead.
  `WeakAurasOptions/OptionsFrames/Update.lua`: the import compatibility report says when a call is replaced. New
  locale key in `WeakAuras/Locales/enUS.lua` and `WeakAuras/Locales/frFR.lua`. `GUIDE.md` updated.

### Fixed
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua`: the widget registered its reload
  callbacks when the file loaded, before the options received `Private`, so `/wa` failed with "attempt to index
  field 'Private' (a nil value)". The callbacks are now registered when the options open.

## 2026-10-16

Released as 1.10.0. Headless test bench: 46 scenarios, 0 failed.

### Added
- `Tests/Scenarios/32_SecretTriggerContract.lua`: secret aura trigger, secret conditions, spell cooldown state and
  secret prototype helpers, through their public exports.
- `Tests/Scenarios/33_RestrictedTriggersContract.lua`: restricted triggers (totems), Classic Era triggers, text style
  and the specialization code.
- `Tests/Scenarios/34_OptionsFilesContract.lua`: aura trigger options, trigger secret warnings, version check, Aura
  (Modern) group options and icon, CDM dispel sub element options and the color picker widget.
- `Tests/Scenarios/35_RegionBlocksContract.lua`: fork code in the icon, sub text, dynamic group, text, region
  prototype and group regions.
- `Tests/Scenarios/36_OptionsBlocksContract.lua`: fork code in the action, trigger, buff trigger, sub element, group,
  common, display and condition options.
- `Tests/Scenarios/37_CoreBlocksContract.lua`: fork code in the core files, including the BigWigs encounter load
  option and the "Spell in Range" trigger.
- `Tests/Scenarios/38_GlowPreviewContract.lua`: native element glow (deferred build queue, cache key, settings
  normalization, cleanup), options preview of the native aura display, and the glow start check of the glow sub
  element.
- `Tests/Scenarios/39_AppearanceContract.lua`: appearance of the native aura display (supported and detached
  elements, validation, migration of the old element types, text bindings, styling of the icon, bar and sub elements).
- `Tests/Scenarios/40_UnitGlowContract.lua`: glow on unit frames (pulse and Proc types, color, padding, first
  display through the deferred build queue, cleanup, single shown animation per button).
- `Tests/Scenarios/43_ConditionsContract.lua`, `Tests/Scenarios/44_FlowAnchorContract.lua`,
  `Tests/Scenarios/45_SingleContract.lua` and `Tests/Scenarios/46_FlowLayoutContract.lua`: native aura display
  conditions, flow and anchoring, single aura display, and flow layout (screen centering, grids, editor preview).
- `Tests/Scenarios/47_DisplayCoreContract.lua`: native aura display core (apply, activate, modify, release and
  restore, budgeted apply and instance queues, unit status and alpha, unit glow, nameplate tokens, event filters per
  unit mode, combat replay, sounds, text style).
- `Tests/Scenarios/48_Lot6aContract.lua`: spell rank families (content and rank order, catalog, unknown IDs), talent
  data reader (config ID, load data, events, subtrees) and head of the native aura display (label and filter tables,
  saved trigger, units, validation, migration, sounds, preview notice).
- `WeakAuras/AuraBackups.lua`: a daily copy of the saved auras in WeakAurasArchive, taken after a login that went to
  the end, never for an empty aura list, three copies kept. `/wa backups` lists them and `/wa restore <number>` puts one
  back after a confirmation, then reloads the UI (`WeakAuras/WeakAuras.lua`, `WeakAuras/WeakAuras.toc`). A disabled
  archive addon skips the copy silently, a copy that fails half-way leaves no entry, and a restore saves the custom
  data of the running auras first so the reload can't write it into the copy.
- `Tests/Scenarios/41_AuraBackups.lua`: daily copies (one per day, three kept, frozen content, empty list skipped),
  the slash commands, the restore and a copy that fails half-way. `Tests/Scenarios/25_SavedVariablesSurviveLogin.lua` also checks that a login
  that died takes no copy.
- `Tests/Scenarios/42_ForeverAurasRealExport.lua` and `Tests/Fixtures/ForeverAurasExport1.txt`: a real ForeverAuras
  export (Simonize Forever Rogue Auras, ForeverAuras 0.44.0-BETA.1, 37 auras) decoded, converted and saved before the
  login, then loaded for a rogue of specialization 1488 and played through a combat without any Lua error.
- `Tests/CompareWithForeverAuras.py`: `--base <WeakAuras release>` leaves out the lines also found in upstream
  WeakAuras.

### Changed
- Rewritten from a behavior specification, without ForeverAuras code: `WeakAuras/PrototypeSecretHelpers.lua`,
  `WeakAuras/SecretConditions.lua`, `WeakAuras/SecretAuraTrigger.lua`, `WeakAuras/SecretSpellCooldown.lua`,
  `WeakAuras/GenericTriggerRestricted.lua`, `WeakAuras/ClassicEraTriggers.lua`, `WeakAuras/TextStyle.lua`, the code of
  `WeakAuras/PlayerSpecialization.lua` (same CC-BY data), `WeakAurasOptions/AuraTriggerOptions.lua`,
  `WeakAurasOptions/TriggerSecretWarnings.lua`, `WeakAurasOptions/VersionCheck.lua`,
  `WeakAurasOptions/RegionOptions/GroupModernFlow.lua`, `WeakAurasOptions/SubRegionOptions/CDMDispel.lua`,
  `WeakAurasOptions/SubRegionOptions/CDMDispelBorder.lua` and
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.lua`, `WeakAuras/SecretAuraGlow.lua` (glow
  builders per type, part pool and deferred build queue) and `WeakAuras/SecretAuraPreview.lua` (sample button methods
  generated from one binding table), `WeakAuras/SecretAuraAppearance.lua` (one styler per sub element type, one
  migration per old element type), `WeakAuras/SecretAuraConditions.lua` (condition variables, properties and highlight
  fields declared in tables, validation through ordered validators) and `WeakAuras/SecretAuraFlow.lua` (split into
  the new `WeakAuras/SecretAuraFlowShadow.lua`, `WeakAuras/SecretAuraFlowUnits.lua`, `WeakAuras/SecretAuraFlowGrid.lua`
  and `WeakAuras/SecretAuraFlowPreview.lua`). The six copies of the anchor lookup, protected-frame guard, growth tables,
  reparenting and group position in `WeakAuras/SecretAuraFlow.lua` and `WeakAuras/BlizzardAuraDisplay.lua` are merged
  into the new `WeakAuras/SecretAuraAnchor.lua` (`WeakAuras/WeakAuras.toc`); unit frame and nameplate anchoring goes
  through its combat guard too. `WeakAuras/SecretAuraSingle.lua` (trigger checks, stack and duration ranges declared
  in rule tables, validation through an ordered step list); ten of its validation messages are reworded. The display
  core of `WeakAuras/BlizzardAuraDisplay.lua` (region life cycle, budgeted queues, unit status, unit glow, nameplate
  tokens, events declared in rule tables per event and per unit mode) and its head (label and filter tables built
  from catalogs, saved trigger, units, validation, migration, sounds, preview notice). The code of
  `WeakAuras/SecretAuraRanks.lua` (one table of rank families per label, same CC BY 4.0 data, regenerated as is by
  `Tests/GenerateSpellData.py`) and the talent data reader of `WeakAuras/Prototypes.lua`. Their
  ForeverAuras header is replaced by
  the Musca Auras header, except `VersionCheck.lua` and `Prototypes.lua`, WeakAuras files, which have none. The color picker keeps its
  credit to the AceGUI-3.0 ColorPicker widget.
- Fork code rewritten the same way, without ForeverAuras code, in `WeakAuras/SecretRestrictions.lua` (a fork file)
  and in the WeakAuras files `WeakAuras/WeakAuras.lua`, `WeakAuras/Prototypes.lua` (its ForeverAuras header is removed with the
  talent data reader rewrite), `WeakAuras/GenericTrigger.lua`, `WeakAuras/Conditions.lua`, `WeakAuras/BossMods.lua`,
  `WeakAuras/Modernize.lua`, `WeakAuras/BuffTrigger2.lua`, `WeakAuras/RegionTypes/Icon.lua`,
  `WeakAuras/RegionTypes/Text.lua`, `WeakAuras/RegionTypes/DynamicGroup.lua`, `WeakAuras/RegionTypes/Group.lua`,
  `WeakAuras/RegionTypes/RegionPrototype.lua`, `WeakAuras/SubRegionTypes/SubText.lua`,
  `WeakAuras/SubRegionTypes/Glow.lua`,
  `WeakAurasOptions/ActionOptions.lua`, `WeakAurasOptions/TriggerOptions.lua`, `WeakAurasOptions/BuffTrigger2.lua`,
  `WeakAurasOptions/SubRegionOptions/SubRegionCommon.lua`, `WeakAurasOptions/RegionOptions/Group.lua`,
  `WeakAurasOptions/CommonOptions.lua`, `WeakAurasOptions/DisplayOptions.lua`, `WeakAurasOptions/ConditionOptions.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`,
  `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` and `WeakAurasOptions/WeakAurasOptions.lua`. Comments added by
  this fork in these files are removed; four upstream comments of `WeakAuras/RegionTypes/Icon.lua` are restored.
  Same option trees and saved fields. Code lines outside locales also found in ForeverAuras 0.87.6 and not in
  WeakAuras 5.22.0: 1781 in 76 files before, 1276 in 71 files after.
- `WeakAuras/SecretAuraGlow.lua` gains a stretched mode (the glow fills its anchor when no size is given, widened by
  the X and Y offsets) and an internal `pulse` type. The glow on unit frames of `WeakAuras/BlizzardAuraDisplay.lua`
  now goes through it instead of its own Proc and pulse layers; the unused main glow code is removed.
- `WeakAuras/SecretAuraGlow.lua`: the alpha fade of `pulse` and Shine and the action button alert halo of
  `buttonOverlay` and `pulse` are each written once (`Builder:Fade`, `Builder:Alert`). Same calls in the same order,
  same rendering. `Tests/Scenarios/38_GlowPreviewContract.lua` now checks the halo sizes (1.4 times the icon, ants
  1.2 times, pulse follows the scale).
- Behavior changes:
  - the property blocks of the generated trigger code are sorted by name;
  - `IsNeverSecretSpell` returns false when `NeverSecret` is missing;
  - a color component given as a string is read with `tonumber`;
  - `Private.ApplyTextFont` replaces a nil font flag with `""`;
  - the "Charge count checks" warning no longer fires on a secret `maxCharges`;
  - `ColorPickerFrame` is read again on each call;
  - the secret remaining time default (`secretRem = "5"`) is set only when the option is turned on;
  - a unit whose power type is secret is ignored;
  - trigger entries without a trigger table are skipped, and a name that is not a string or is secret is refused;
  - without BigWigs, `WeakAuras.IsBossModEnabled` returns nil;
  - an unknown name pattern operator adds no filter;
  - `MigrateCDMCooldownTrigger` does nothing when the trigger is nil;
  - the "Enabled BossMod ID(BW Only)" load option is now labeled "BigWigs Module Loaded for Encounter ID" and listens
    to `WA_BIGWIGS_ENCOUNTER_MODULES_CHANGED` (was `WA_BOSSMOD_ENABLED_STATE_CHANGED`); the saved field
    `enabledBossModID` is unchanged;
  - "Spell in Range": a spell saved by ID shows its name when known and its ID otherwise; the trigger icon and the
    name in the options look a saved ID up as an ID, in exact mode or not; in exact mode a name that is not an ID
    gives no icon, and a trigger without a spell has no icon (was the icon of spell 0);
  - the generated stat code checks again that `GetSpellBonusHealing`, `UnitSpellHaste` and `GetExpertise` exist;
  - reworded combat status of the "Cast" trigger: "Fully usable in combat.", "Other units' casts: shown in combat,
    never filtered." and "Ignored in combat: ... (other units' casts are unreadable)";
  - the glow on unit frames appears through the deferred build queue, one frame later on its first display;
  - the native element glow resets the tint of reused textures, so the Pixel border background no longer keeps the
    color of a former dot;
  - the display options no longer raise an error when a sub element removed from the aura is read back;
  - the "Hide Blizzard's CDM" check box reads its value again each time it is shown;
  - the rank families are listed in the order of their labels, and the rank order inside each family is unchanged;
  - the talent data reader treats a subtree that `C_Traits.GetSubTreeInfo` does not describe as inactive (was a Lua
    error);
  - the classification messages of the native aura display are reworded, except "Choose a supported unit and Buff or
    Debuff." and the two messages checked by `Tests/Scenarios/31_OptionsContract.lua`; three
    unreachable messages and `HasAdditionalFilters` are removed, and `ResolveFojjiRecordedSound` is no longer
    exported;
  - reworded messages of the native aura display: the FojjiCore recorded sound warnings, "Pick a sound file in the
    Actions tab.", the warning when the client refuses an aura sound, and the preview notice; the tooltips of the
    "Marked for all nameplates" and "Marked for personal debuff display" filters take the longer text already shown
    by the options;
  - the native aura display skips a unit name that is not a string;
  - reworded help texts: "Add Detached", the Blizzard text codes `p`, `s` and `n`, the "When Aura (Modern) Filters Are Not Met, Use" option, the Cooldown
    Manager tooltip and the Aura (Modern) group button.
- Texts written by this fork in the options files are now localized through `L[]`, with the same English text:
  `WeakAurasOptions/AuraDisplayOptions.lua`, `CooldownViewerOptions.lua`, `SecretAuraTriggerOptions.lua`,
  `AuraTriggerOptions.lua`, `TriggerOptions.lua`, `OptionsFrames/OptionsFrame.lua`, `DisplayOptions.lua`,
  `WeakAurasOptions.lua`, `CommonOptions.lua`, `RegionOptions/Group.lua`,
  `AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`, `TriggerSecretWarnings.lua`,
  `RegionOptions/GroupModernFlow.lua`, `SubRegionOptions/CDMDispel.lua`, `SubRegionOptions/CDMDispelBorder.lua` and
  `ColorPalette.lua`.
- `WeakAuras/CHANGELOG.md` and `WeakAurasOptions/Changelog.lua`: new label of the BigWigs load option.
- `Tests/Scenarios/36_OptionsBlocksContract.lua`: table addresses printed as `0x...` (Linux) are recognized.

### Removed
- `WeakAuras/Libs/LibSpellRange-1.0` (`WeakAuras/embeds.xml`, `WeakAuras/Init.lua`, `WeakAuras/Prototypes.lua`): only a
  fallback of `WeakAuras.IsSpellInRange` for a client without `C_Spell.IsSpellInRange`, which WoW Forever has. Without
  that API the function now returns nil. This ends the dead code cleanup started on 2026-10-15. Kept on purpose: the public
  `WeakAuras.IsWrathOrRetail`, `IsWrathOrMistsOrRetail`, `IsWrathOrMists`, `IsClassicOrWrath`, `ProfileFrames`,
  `ProfileDisplays`, `ToggleProfile` and `SetupClassPackCDM`, which the custom code of imported auras and the class
  packs can call, and the `isSecret` / `IsSecret` upvalues, which are used.

## 2026-10-15

Released as 1.10.0. Headless test bench: 29 scenarios, 0 failed.

### Added
- `Tests/Scenarios/25_SavedVariablesSurviveLogin.lua`: an error in the middle of login and an aura with corrupt data
  leave `WeakAurasSaved` unchanged on logout.
- `Tests/Harness/Loader.lua`: `Loader.LoadAddon` takes a `beforeLogin` hook that runs between `ADDON_LOADED` and
  `PLAYER_LOGIN`.
- `Tests/Scenarios/26_CDMSetup.lua`: the class pack Cooldown Manager setup rejects bad input, gives up after its retry
  limit, skips a layout that already matches, waits for the end of combat, then saves the layout and its backup.
- `Tests/Scenarios/27_SecretAuraFlow.lua`: flow settings, sort order, flow problems, flow start and end frames, and
  chaining deferred until the end of combat.
- `Tests/Scenarios/28_SecretAuraPreview.lua`: preview samples per spell, layout by growth direction, bindings filled
  and ticking, hidden when the options close, and the missing mode.
- `Tests/Scenarios/29_CooldownViewerTriggerBehavior.lua`: Cooldown Manager trigger states per type, spell and buff
  selection by ID and by name, picker, remaining time and stack filters with secret values, and migration.
- `WeakAuras/CooldownViewerSelection.lua` (catalog, queries, spell resolution, picker, migration) and
  `WeakAuras/CooldownViewerStates.lua` (state filling per type, buff filters), loaded before
  `WeakAuras/CooldownViewerTrigger.lua` in `WeakAuras/WeakAuras.toc`.
- `Tests/Scenarios/30_NativeProgressPainting.lua`: native painting of aura bars (secret value, timer, mask per
  orientation, additional bars, Cooldown Manager bar), of secret progress textures (linear and radial) and of the
  Aura (Modern) progress texture. `Tests/Harness/Frames.lua`: status bar, mask and radial methods that record their
  arguments.
- `WeakAuras/NativeProgressPainter.lua`: native widget painting shared by aura bars, secret progress textures and
  Aura (Modern): driver bar, edge mask, fill direction, secret value, timer, color, art and radial progress. Loaded
  before `WeakAuras/ProgressTextureNative.lua` in `WeakAuras/WeakAuras.toc`.
- `Tests/Scenarios/31_OptionsContract.lua`: option trees, values read and written, and callbacks of the aura
  display options, the secret aura trigger options and the Cooldown Manager trigger options. In this scenario and in
  `Tests/Scenarios/17_SpellNameInput.lua`, `OptionsPrivate.Private` is set after the options files load, as in game.
- `Tests/CompareWithForeverAuras.py`: counts the code lines of given files also found in a ForeverAuras release.

### Changed
- `CHANGES.md`: the header lists the files no longer derived from ForeverAuras, dates the name-only rewrites to
  2026-10-04, covers the code moved into new files that day, and says that the features "also found in ForeverAuras"
  only used it as a behavior reference.
- Two-line header crediting ForeverAuras (Neroxrw, GPL-2.0) at the top of the 24 files still derived from it:
  `WeakAuras/` BlizzardAuraDisplay, ClassicEraTriggers, GenericTriggerRestricted, PlayerSpecialization, Prototypes,
  PrototypeSecretHelpers, SecretAuraAppearance, SecretAuraConditions, SecretAuraFlow, SecretAuraGlow, SecretAuraPreview, SecretAuraRanks,
  SecretAuraSingle, SecretAuraTrigger, SecretConditions, SecretSpellCooldown, TextStyle;
  `WeakAurasOptions/` AuraTriggerOptions, TriggerSecretWarnings, VersionCheck, RegionOptions/GroupModernFlow,
  SubRegionOptions/CDMDispel, SubRegionOptions/CDMDispelBorder, AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.
- `WeakAuras/RegionTypes/AuraBarNative.lua` and `WeakAuras/ProgressTextureNative.lua`: rewritten from a behavior
  specification, without M33kAuras or ForeverAuras code, on top of `WeakAuras/NativeProgressPainter.lua`.
  `WeakAuras/RegionTypes/ProgressTextureSecret.lua` uses that module too. Every write to the Blizzard Cooldown Manager
  bar goes through one combat guard. An Aura (Modern) progress texture without a foreground color is drawn white
  instead of raising an error.
- `WeakAurasOptions/AuraDisplayOptions.lua`, `WeakAurasOptions/SecretAuraTriggerOptions.lua`,
  `WeakAurasOptions/CooldownViewerOptions.lua`, `WeakAurasOptions/ColorPalette.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua` and the Cooldown Manager blocks of
  `WeakAurasOptions/GenericTrigger.lua`: rewritten from a behavior specification, without ForeverAuras code. Same
  option trees and saved fields. Behavior changes: the Aura (Modern) options no longer raise an error when the aura has
  no `blizzardAuraDisplay` table, which is created on the first write; a secret aura name made only of spaces is saved
  as an empty name instead of being refused; the color palette adds a color to the recent colors on OK only, not on
  Cancel, accepts an alpha typed as "50 %", and its Alpha field sits under the picker when the picker has no
  `Content` frame.
- `WeakAuras/CHANGELOG.md` and `WeakAurasOptions/Changelog.lua`: ForeverAuras credited to Neroxrw instead of m33shoq.
- `WeakAuras/CDMBackground.lua` and `WeakAuras/CDMSetup.lua`: rewritten from a behavior specification, without
  ForeverAuras code. Same behavior: Cooldown Manager background, class pack layout setup with its backup, retries and
  end-of-combat wait.
- `WeakAuras/CooldownViewerTrigger.lua`: rewritten from a behavior specification, without ForeverAuras code, and split
  into three files. Behavior changes: states are rebuilt on each pass and no longer shared between two identical auras;
  on a key collision the first visible state wins; Cooldown Manager data changes are coalesced into one refresh, and
  `SPELL_UPDATE_COOLDOWN` queues one too; a secret target counts as no target; spell cooldown times come from
  `SpellCooldownState` instead of the Cooldown Manager frame; a buff selected by name with no known candidate keeps all
  matches; the remaining time filter and the boolean properties no longer offer `only_equal`, and only spell ID, name,
  item ID and Cooldown Manager category are stored for conditions. A buff selected by name now tracks every spell ID
  of that name and gets one clone per Cooldown Manager entry; an item selected by text must be known; a spell counts
  as known when another rank of the same name is known.
- `WeakAurasOptions/ConditionOptions.lua`: the error lines under custom condition code (custom check, custom text
  function, run custom code) load the code through `Private.LoadFunction` in the built-in sandbox environment, like the other
  custom code fields, instead of a bare `loadstring`. An error raised while the code loads now shows too.

### Removed
- Functions without any caller: `Private.CanConvertBuffTrigger2` and `Private.ConvertBuffTrigger2`
  (`WeakAuras/BuffTrigger2.lua`), `Private.SetAllStatesHiddenExcept` and `Private.CreatingRegions`
  (`WeakAuras/WeakAuras.lua`), `Private.UsesDurationText` and `Private.GetTextDuration` (`WeakAuras/DurationText.lua`),
  `Private.RestoreFromHistory` (`WeakAuras/History.lua`), `Private.IsEnvironmentInitialized`
  (`WeakAuras/AuraEnvironment.lua`), `OptionsPrivate.AddDisplayButton` (`WeakAurasOptions/WeakAurasOptions.lua`), and
  the `WeakAuras.IsLibsOk` override (`WeakAurasOptions/VersionCheck.lua`).
- `Private.CDMNativeSelections` (`WeakAuras/CooldownViewerTrigger.lua`), replaced by states rebuilt on each pass.

## 2026-10-14

Released as 1.9.1. Tested in game on WoW Forever: the class pack swipe and red pulse. Headless test bench:
22 scenarios, 0 failed. luacheck: 0 warnings in 221 files.

### Added
- `WeakAuras/WeakAuras.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`: a login popup asks players
  who have the class pack of their class to update it, once per class pack version (`CLASS_PACK_VERSION`), with an "Update <class> HUD"
  button that calls `WeakAuras.ImportClassPack()`. New players see the first login popup instead.
- `Tests/Scenarios/18_SecretAuraRanks.lua` to `Tests/Scenarios/21_AnchorToContent.lua`: scenarios for the spell rank
  families, `Modernize`, the native glows and the native aura anchors (container on a grouped aura, unit frame and
  nameplate lookup, inner and outer points, text offset conditions).
- `Tests/GenerateSpellData.py`: regenerates the rank families of `WeakAuras/SecretAuraRanks.lua` and the final talents
  of `WeakAuras/PlayerSpecialization.lua` from talentsforever.com `data.json` and the client `SpellName.csv`, with
  the source dates of both `*-LICENSE.txt` files.
- `Tests/Harness/Frames.lua`: `CreateControlPoint` on animations.
- Class packs: a cast bar for every class, the global cooldown swipe (without countdown) on every cooldown icon, a
  glow on the proc icons, the
  Forbearance and Weakened Soul debuffs on the player, Sunder Armor and Fire Vulnerability stacks, and for the
  warlock a missing pet reminder and a Soul Shard count at 0. The missing pet reminders (hunter and warlock) now also
  show in combat. The druid energy tick bar is removed.
  The rogue pack shows the builders and finishers (Sinister Strike, Backstab, Mutilate, Hemorrhage, Ambush,
  Eviscerate), Feint, Kidney Shot and Gouge with the cooldowns, and the Slice and Dice timer in red under
  3 seconds; each icon loads only once the spell is known.
  The warrior pack adds Taunt, Mocking Blow, Challenging Shout, Disarm and Concussion Blow to the cooldowns,
  and the Disarm, Concussion Blow and Mocking Blow debuffs on the target. Shield Bash only shows in Battle and
  Defensive stances.
  The hunter pack adds Flare, Tranquilizing Shot and Distracting Shot cooldown icons, each loaded only once the
  spell is learned.
  The priest pack adds a Divine Spirit buff icon (all ranks, shown only when the spell is known) and a refresh glow
  on the Devouring Plague debuff, like Shadow Word: Pain.
  The paladin pack adds Holy Wrath, Turn Undead and Divine Intervention cooldowns, plus a Divine Protection buff
  icon. Each spell only appears once it is learned.
  The shaman pack adds Ancestral Guidance, Ancestral Fortitude on the target and Water Walking, all loaded only
  when learned. Stormstrike now glows on the target while its debuff is active.
  The druid pack adds Lacerate stacks (bear), Prowl, Nature's Grasp (buff and cooldown), Wild Growth and a Moonkin
  Form reminder outside cat and bear forms. Each loads only when its spell is known.
  The mage pack adds Fire Ward and Frost Ward cooldowns and active buffs on every rank, plus a Slow Fall buff.
  Winter's Chill and Fire Vulnerability now glow when they can be refreshed. Every added spell loads only once it
  is learned.
  The warlock pack adds Inferno, Spell Lock, Seduction and Suffering (shown only with the matching pet), Sacrifice,
  Fel Domination, Pyroclasm and Banish glow, a missing Soul Link reminder (only while a pet is out, so not
  after Demonic Sacrifice), and a glow on Fear. Soul Link now follows its applied aura.
- `WeakAuras/SecretAuraFlow.lua`, `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAuraAppearance.lua`,
  `WeakAuras/SecretAuraConditions.lua`: `UnitAnchor`, `LocateAnchor`, `SplitAnchorTarget` and `AnchorOffsetApplier`
  are exported on `Private.BlizzardAuraDisplay` for the anchor scenario. No behavior change.

### Changed
- `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`, `DESCRIPTION.md`: describe 1.9.1.
- Class packs (`Tests/Packs/PackBuilder.lua`): icons show no timer numbers any more, only the cooldown swipe. An
  aura icon pulses red (Proc glow) in its last 3 seconds, or the `warn` seconds of the pack entry; an aura that
  flashes on gain (a proc) pulses only with an explicit `warn`, and then no longer flashes. The pulse starts from the
  last duration seen for the aura: a variable duration (Slice and Dice, Rupture) pulses earlier or later than set.
- `Tests/Scenarios/23_ClassPacksConditions.lua`: every secret aura of the class packs must pass the native single
  and condition checks.
- `WeakAuras/SecretAuraRanks.lua`, `WeakAuras/PlayerSpecialization.lua`, `WeakAuras/SpellRankData-LICENSE.txt`,
  `WeakAuras/SpecializationData-LICENSE.txt`: regenerated by `Tests/GenerateSpellData.py` from talentsforever.com
  `data.json` of 2026-10-13. Rank families: Druid Shifting Power and Hunter Sonic Blast added, Druid Tiger's Fury and
  Priest Lightwell removed (gone from the game). Tree icons of Warrior Protection and Priest Holy follow the source.
  Both license files now say "Modified for Musca Auras" instead of "Modified for ForeverAuras".
- `WeakAuras/PlayerSpecialization.lua`, `WeakAuras/Prototypes.lua`: the "Specialization" load option (`forever_spec`)
  matches the talent tree with the most points spent, read with `C_Traits.GetGroupCurrencyInfo` like the Blizzard
  talent frame. Before, it needed the final talent of the tree, so a Shaman with 13 points in Enhancement matched no
  specialization. The final talent check stays as the fallback when the points cannot be read or none is spent. The
  option also rechecks on `CHARACTER_POINTS_CHANGED` and `WA_TALENT_UPDATE`. New scenario `Tests/Scenarios/22_ForeverSpecialization.lua`.
- `.luacheckrc`: every warning code is checked, except the codes listed in `ignore` that still have warnings in the
  code. 28 APIs absent from WoW Forever (`GetSpellInfo`, `UnitAura`, `GetSpecialization`, `C_Seasons`...) are no
  longer global: they are allowed only in the files that already call them.
- `WeakAuras/WeakAuras.toc`: `OptionalDeps` keeps only the addons the code uses (`Masque`, `GTFO`, `CustomNames`,
  `BigWigs`, `DBM-Core`). The embedded libraries, `LibButtonGlow-1.0` and `!!AddonLocale` are removed from it.
- `WeakAuras/BuffTrigger2.lua`: `FixDebuffClass` keeps only the Classic version. The retail version used LibDispel
  for bleeds and never ran on WoW Forever.
- `WeakAuras/Init.lua`: no longer lists `LibSpecialization` among the libraries checked at load on retail.
- `WeakAuras/Libs/Archivist/Archivist.xml`: no longer loads its own copies of LibStub and LibDeflate. `embeds.xml`
  already loads both before Archivist.
- `WeakAuras/SecretAuraGlow.lua`: the glow parts (textures, edge frames, animation groups) are kept per element and
  reused when the glow settings change, instead of being dropped and created again. The Pixel and Shine glows move
  each line with 5 chained `Translation` animations instead of a `Path` of about 20 control points. The Shine fade
  runs in its own animation group. Building the Pixel glows caused the freezes at import, deletion and selection.
  A glow whose settings did not change stays attached to its aura button: it is no longer removed and added again
  through `AddAuraShownAnimation`, whose checks cost about 5 ms per glow on each restyle.
  The first glow of a live aura button or of an options preview is built a few frames later, within 8 ms per
  frame and never under aura restrictions: each new aura container creates a batch of 10 buttons at once, and
  building their 10 Pixel glows in the same frame took about 100 ms on each import or re-add. After each batch, the aura buttons refresh their
  shown animations, so the glows of empty buttons stop. Under aura restrictions the glow is still built at once.
- `WeakAuras/SecretAuraAppearance.lua`: a restyle marks the element glows as stale instead of clearing them, and
  clears only the glows that the new style did not confirm.
  Each element entry keeps its native view for that refresh. `WeakAuras/BlizzardAuraDisplay.lua` exposes
  `Display.RefreshShownAnimations`.
- `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAuraFlow.lua`: the aura buttons that a new aura container or
  a new Modern Flow aura group creates are styled once, when they are created. They were styled a second time right
  after, with the same settings, which doubled the style cost of each import or re-add.
- `WeakAurasOptions/WeakAurasOptions.lua`: the aura list is no longer sorted after each load scan during an import or
  update. `WeakAurasOptions/OptionsFrames/Update.lua` sorts it once at the end. Each added aura sorted the whole aura
  list, about 5 ms per aura that grew with the size of the list.
- `Tests/Scenarios/20_SecretAuraGlow.lua`: checks that the Pixel parts are reused and hidden after a type change, and
  that an unchanged glow is not added to the button again, and that the first glow of a live button is deferred and
  dropped when cleared before it is built.
- `Tests/Scenarios/04_TemplateSpellIds.lua`: also checks the spell IDs of the Warrior stance and Druid form loops of
  `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua` against `Classes/<Class>.md`, and the form position of the
  Druid templates.

### Fixed
- `WeakAuras/SecretAuraAppearance.lua`: a secret aura icon shows its cooldown swipe. The restyle hid the native
  cooldown, and only the Total Duration countdown path showed it again. With "Hide Timer Text" off, the native
  countdown numbers of the client can now show on such an icon.
- `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`: the Druid form templates take their form position from
  `GetShapeshiftFormInfo`. The position was the rank in the template list, so the Cat Form template of a druid who
  knows Aquatic Form matched Aquatic Form. Dire Bear Form 9634, Aquatic Form 1066 and Moonkin Form 24858 are added;
  only the forms the druid knows when the template window first opens in the session get a template. A form learned
  after that needs a /reload.
- Class packs (`Tests/Packs/<Class>/Pack<Class>.lua`, `WeakAurasOptions/ClassPacks.lua`): every buff reminder loads only
  once the player knows its first spell (Aspect 415423, Demon Armor 687, Mark of the Wild 1126, Thorns 467, Battle
  Shout 6673, Arcane Intellect 1459, mage armor 168, Blessing 19740, Paladin aura 465, Power Word: Fortitude 1243,
  Inner Fire 588, poisons 8681). A level 1 rogue no longer sees the missing poison reminders. The off-hand poison
  reminder needs an off-hand weapon. `Tests/Packs/PackBuilder.lua` refuses a reminder or a tracked missing DoT without
  `known` or `level` (LOW MANA excepted).
- `WeakAuras/SecretAuraSingle.lua`: an aura icon that falls back to its spell cooldown (shaman Nature's Swiftness)
  now honors "Hide GCD Text" and no longer shows the global cooldown countdown.
- `WeakAurasOptions/BuffTrigger2.lua`, `WeakAurasOptions/Locales/enUS.lua`: the Debuff Type tooltip no longer
  mentions LibDispel, which is not shipped.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: the credits no longer list LibDispel and LibSpecialization,
  which are not shipped.

### Removed
- `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`, `Tests/Scenarios/10_EnergyTick.lua`: the Energy Tick trigger and its scenario.
  Energy regenerates continuously on WoW Forever (a gain about every 0.2 s, checked in game), so there is no
  2 second tick to show.
- `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`: spell IDs 114282 and 1394966 from the Druid form loop.
  They are retail forms, absent from the 1.60.1.70245 SpellName DB2, so the loop already skipped them.
- `WeakAuras/Libs/LibSpecialization`, `WeakAuras/Libs/LibDispel`, `WeakAuras/Libs/TaintLess`: never loaded by
  `embeds.xml`.
- `WeakAuras/Libs/Archivist/libs`, and the LibStub and CallbackHandler copies and `LibGetFrame-1.0.xml` in
  `WeakAuras/Libs/LibGetFrame-1.0`: duplicates. LibStub ignored the Archivist copies (same or older version), and the
  LibGetFrame copies were never loaded.
- Upstream files never loaded by the game in `WeakAuras/Libs` and `WeakAurasOptions/Libs`: library `.toc` files,
  `README` files, `cspell.json`, `stylua.toml` and the LibStub tests. License files are kept.
- `lib.xml` of LibCompress, LibDBIcon-1.0, LibDeflate and LibSpellRange-1.0, and
  `WeakAurasOptions/Libs/LibUIDropDownMenu/LibEasyMenu.lua`: never loaded. `embeds.xml` loads the library `.lua`
  files directly, and LibUIDropDownMenu has its own `EasyMenu`.

## 2026-10-13

Released as 1.9.0. Tested in game on WoW Forever 1.60.1.70338, except the aura link sent to another player and the
options window logo and Discord link (not tested in game yet). Headless test bench: 17 scenarios, 0 failed.

### Added
- `WeakAurasOptions/SecretAuraTriggerOptions.lua`, `WeakAuras/SecretAuraRanks.lua`: the spell lists of Aura (Modern)
  accept a spell name. A name is replaced by the IDs of all its ranks, found in the rank families (names read in the
  game language) or, for a spell the character knows, by `C_Spell.GetSpellIDForSpellIdentifier`. `README.md`,
  `DESCRIPTION.md`, `GUIDE.md`, `TUTORIAL.md`, the in-game guide (`WeakAuras/ForeverTutorial.lua`) and the first
  login popup (`WeakAuras/WeakAuras.lua`) no longer say that spells must be entered by ID.
- `Tests/Scenarios/17_SpellNameInput.lua`: scenario for the spell name input.
- `WeakAuras/WeakAuras.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`: third button
  "Install <class> HUD" on the first login popup, which calls `WeakAuras.ImportClassPack()`.
- `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/VersionCheck.lua`: popup `WEAKAURAS_ACTION_BLOCKED`. The class pack
  import asked in combat waits for the end of combat and says so; an import asked before login ends says to try
  again; a version mismatch between WeakAuras and WeakAurasOptions opens a popup that names the 5 folders to replace.
- `WeakAuras/AuraEnvironment.lua`, `WeakAuras/WeakAuras.lua`: a custom code that fails to compile or to run shows the
  error as an aura warning ("Error in custom code"); a run failure was silent before. The check made while typing in
  the code editor sets no warning. The warning is cleared when the aura is saved, except on a simple change.
- `WeakAuras/Transmission.lua`: a received display message is checked before it is handled, and the cache purge
  runs at most once every 60 s.
- `WeakAurasOptions/TriggerSecretWarnings.lua`, `WeakAurasOptions/WeakAurasOptions.lua`: the secret trigger warning
  also shows in the aura list.
- `WeakAurasOptions/AuraDisplayOptions.lua`: a grey line under each display group of an Aura (Modern) that has
  greyed out options, with the reason.
- `WeakAurasOptions/CommonOptions.lua`: a description under the trigger type of an Aura trigger, which tells
  Aura (Modern) and Aura apart with the limits of each.
- `WeakAurasOptions/OptionsFrames/Update.lua`: a compatibility report before the import confirmation, aura by aura:
  combat log triggers, auras that turn secret in combat, checks on values that turn secret in combat, and calls in
  custom code to functions absent from WoW Forever, with the known fix when there is one.
- `Tests/Scenarios/12_SecretRestrictionsHelpers.lua` to `Tests/Scenarios/16_ForeverAurasImport.lua`,
  `Tests/Harness/Units.lua`: scenarios for the secret value helpers, `SpellCooldownState`, secret conditions, Cooldown
  Viewer triggers and the ForeverAuras import; the mock Duration gains `EvaluateRemainingDuration` and
  `EvaluateElapsedDuration`, and step curves are evaluated as steps.

### Changed
- `WeakAuras/AuraEnvironment.lua`: the custom code sandbox also blocks `getmetatable`, `ConsoleExec`, `Logout`,
  `Quit`, `ForceQuit`, the guild management and guild bank functions, and the `debug`, `C_GuildInfo`, `C_Club`,
  `C_AccountStore` and `C_CatalogShop` tables. `collectgarbage` only accepts "count". Still allowed on purpose:
  `SetCVar` and `C_CVar` (nameplate and camera auras), `ReloadUI` (reload buttons), `SendAddonMessage` and
  `C_ChatInfo` (group sync), `InviteUnit` (auto invite), `string.dump` (`loadstring` is blocked).
- `WeakAuras/SecretRestrictions.lua`: shared helpers `Private.ReadableOrNil`, `Private.IsReadableNumber`,
  `Private.ApplyCooldown` and `Private.ApplyCooldownDuration`; the restriction state is read again one frame after
  the end of combat.
- `WeakAuras/RegionTypes/Icon.lua`: the cooldown swipe goes through these helpers and hides instead of raising an
  error when a time is secret.
- `WeakAuras/BuffTrigger2.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`:
  range, group role, arena specialization, item range and weapon enchant checks skip secret values; weapon enchants
  are read again at the end of combat. `Private.ExecEnv.ReadableOrNil` is shared with generated trigger code.
- `WeakAuras/AuraEnvironment.lua`: `WA_GetUnitAura` skips an aura whose name or spell ID is secret.
- `WeakAuras/BuffTriggerNativeFilter.lua`: a secret filter answer counts as not filtered out.
- `WeakAuras/BuffTrigger2.lua`, `WeakAuras/AuraEnvironment.lua`, `WeakAuras/Prototypes.lua`: no longer rely on the
  `Blizzard_Deprecated` shims `UnitAura` and `GetSpellInfo`.
- `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAurasOptions/WeakAurasOptions.lua`: a new Icon, Progress Bar, Progress
  Texture or Text aura starts with an Aura (Modern) trigger on a player buff; other region types keep Aura.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`, `WeakAuras/Media/Textures/logo_musca_round.tga`: the options
  window shows the Musca Auras logo at the top left, all year round, and its Discord button gives the invite link
  https://discord.gg/EyYpyMq2km instead of "Coming soon".
- `README.md`, `DESCRIPTION.md`: Discord invite link https://discord.gg/EyYpyMq2km; `DESCRIPTION.md` describes 1.9.0.
- `.pkgmeta`: the package leaves out the working documents, `Tests`, `Classes` and `Wago`.
- `CHANGES.md`: the header says which code derived from ForeverAuras is still in this fork.

## 2026-10-12

Released as 1.8.1. Tested in game on WoW Forever: `%1.percenthealth% / %2.percentpower%` and `%1.unit %1.percentpower%`
show the percents, and an equipment slot trigger follows its item.

### Added
- `WeakAuras/WeakAuras.lua`, `WeakAurasOptions/ClassPacks.lua`, `Tests/Packs/EmbedClassPacks.lua`: public
  `WeakAuras.ImportClassPack()`, so another addon can import the player's class pack. It loads the options, opens
  the import window of the built-in pack, and returns false in combat, before login ends, when the database needs a repair, when the options cannot load,
  when the class has no pack, or when the import fails.
  `WeakAuras.GetClassPack(class)` returns a pack string once the options are loaded.
- `Tests/Packs/PackBuilder.lua`, `Tests/Packs/Chasseur/PackChasseur.lua`, `Tests/Packs/Guerrier/PackGuerrier.lua`,
  their `.txt` strings, `WeakAurasOptions/ClassPacks.lua`: the hunter pack shows "Missing: Pet" out of combat and
  out of rest areas when no living pet is out, except on a taxi or in a vehicle. The warrior pack shows the icon of
  the current stance on the effects row, left of the HUD.

### Changed
- `Tests/Packs/PackBuilder.lua`, the nine `Tests/Packs/<Class>/Pack<Class>.txt`, `WeakAurasOptions/ClassPacks.lua`:
  class packs use a compact HUD 334 px wide: reminders, procs and effects above, a thin resource bar, a main row
  (grid of 8, 40x30) and a utility row (grid of 9, 34x26), then the bars, upkeep and totem rows. The rows below the
  utility row are offset from its real bottom, so a second line of spells pushes them down.
- `Tests/Packs/PackBuilder.lua`: the uid of each class pack aura is a hash of its id, no longer its creation order.
  A new import updates the auras already in place and keeps their position, size and user options. The uids change
  once: delete the "<Class> (Musca)" group in game before this import.
- `Tests/Packs/PackBuilder.lua`, `Tests/Packs/Chaman/PackChaman.lua`, `Tests/Packs/Chasseur/PackChasseur.lua`,
  `Tests/Packs/Demoniste/PackDemoniste.lua`, `Tests/Packs/Druide/PackDruide.lua`, `Tests/Packs/Pretre/PackPretre.lua`,
  `Tests/Packs/Voleur/PackVoleur.lua`: damage over time debuffs glow when they can be refreshed, other debuffs
  (Sunder Armor, Judgements, curses) no longer glow, and a damage over time debuff tracked while missing loads in
  combat only.
- `Tests/Packs/Guerrier/PackGuerrier.lua`: a stance spell shows only in its stance.
- `Tests/Packs/VerificationPack.lua`, `Tests/Harness/WowApi.lua`: the pack check also tests the anchors between
  groups. The harness has `GetInventoryItemCooldown` and `GetInventoryItemCount`.

### Fixed
- `WeakAuras/GenericTrigger.lua`: an equipment slot that is empty when the aura loads stays in the cooldown scan. A
  trinket equipped later shows its cooldown without a `/reload`. An empty slot no longer sends
  `ITEM_SLOT_COOLDOWN_ITEM_CHANGED` on every cooldown update.
- `Tests/Packs/PackBuilder.lua`, the nine `Tests/Packs/<Class>/Pack<Class>.txt`, `WeakAurasOptions/ClassPacks.lua`:
  class pack icons that have a `%p` timer text hide the native cooldown numbers. With the `countdownForCooldowns`
  CVar on, these icons showed two timers. Spell cooldown icons, which have no timer text, keep the native numbers.
- `WeakAuras/Modernize.lua`: the same fix for class pack icons already imported, on every class, without a new
  import. An icon with a class pack uid (`mc<Class>V<hex>`) and a centered `%p` text gets `cooldownTextDisabled`
  each time the aura is loaded or edited, so the native numbers cannot be turned back on for these icons.
- `WeakAuras/SubRegionTypes/SubTextNative.lua`: a secret value text also accepts placeholders with a trigger number
  (`%1.percentpower`, `%2.health`, `%1.maxpower`...). Each one reads the secret value, total and percent of its own
  trigger. Before, these texts stayed empty while the value was secret, which is always the case for the player's
  power on WoW Forever. A text that mixes a secret value with a readable one (`%1.percenthealth% / %2.percentpower%`
  out of combat) shows both: the readable value, total or percent of the trigger is printed as a whole number next to
  the secret one. A text with no secret value keeps the usual placeholder formatting. Any other placeholder in the
  same text (`%n`, `%1.name`, `%c`...) is filled by the usual placeholder formatting, so it no longer empties the
  whole text (`WeakAuras/RegionTypes/Text.lua` and `WeakAuras/SubRegionTypes/SubText.lua` pass their formatters).
  A `\n` typed in such a text starts a new line, as in the usual formatting.

## 2026-10-11

Released as 1.8.0. Tested in game on WoW Forever: the frame rate stays the same after opening `/wa`, clicking
an aura and closing the options.

### Added
- `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Locales/enUS.lua`,
  `WeakAuras/Locales/frFR.lua`: Energy Tick trigger, a timed bar to the next 2 second energy tick. It locks on energy
  gains that do not come with a player cast, and keeps cycling at full energy.
- `Tests/Scenarios/10_EnergyTick.lua`: headless scenario for the energy tick lock.
- `WeakAurasOptions/ClassPacks.lua`, `WeakAurasOptions/WeakAurasOptions.toc`,
  `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`, `WeakAurasOptions/Locales/enUS.lua`: Class Pack button at the top
  of the New Aura panel, imports the built-in pack of the player's class. `ClassPacks.lua` is generated by
  `Tests/Packs/EmbedClassPacks.lua` from the class pack strings.

### Fixed
- `WeakAuras/WeakAuras.lua`: an aura anchored to another aura with Set Parent to Anchor no longer shows at its
  group's origin while the target aura has no region (a Never load child of a dynamic group, whose region is not
  created at login). It stays hidden until the target region exists, then the existing anchor retry attaches it.
- `WeakAuras/CDMAuraProgress.lua`: a Cooldown Manager spare clone anchored to another aura creates the target region
  before anchoring, with or without Set Parent to Anchor. A spare taken in combat follows the target instead of
  staying hidden, or sitting at its group's origin, until the end of combat. The native display of a target created
  this way is released when the target is not loaded.
- `WeakAuras/Types.lua`: the Cartoon Hop sound is no longer registered, its file is not shipped. LibSharedMedia
  reported "Attempt to register a file that doesn't exist" at login.
- `Tests/Scenarios/11_AnchorParentMissingTarget.lua`, `Tests/Scenarios/09_CDMSpareAnchorInCombat.lua`: headless
  scenarios for these cases.
- `WeakAuras/WeakAuras.lua`: closing the options releases the Blizzard aura display of every aura that is not loaded,
  and deleting an aura releases it too. Before, an aura shown in the options preview but not loaded kept handling
  unit events until the next /reload, which cost frame rate.
- `WeakAuras/SecretAuraPreview.lua`: hiding the options preview stops the glows and condition pulses of the sample
  buttons. Before, their animations kept playing after the options were closed.
- `WeakAuras/BlizzardAuraDisplay.lua`: after a restyle, each native button and the unit glow button bind a hidden
  dispel type text, so the engine refreshes them and stops the glow animations of the empty pooled buttons. Retiring a
  display stops its main and unit glows.
- `WeakAuras/SecretAuraConditions.lua`: the Border/Glow (Pulsing) condition registers its pulse as an aura shown
  animation, so the engine stops it on empty buttons too.
- `WeakAuras/SecretAuraSingle.lua`, `WeakAuras/SecretAuraPreview.lua`: disabling the Missing display of a single aura
  stops its glows and condition pulses.
- `WeakAuras/SecretAuraConditions.lua`, `WeakAuras/SecretAuraSingle.lua`: a glow condition on elapsed time
  ("elapsed < N") is turned into "remaining > total - N" through the late glow path.

## 2026-10-10

Released as 1.7.1. Tested in game on WoW Forever with a Shaman (Lightning Shield, Flame Shock) on Cooldown Manager
aura triggers, in and out of combat: icon swipe, draining bar and `%p` duration text keep the aura timing in combat,
show the full duration on a recast in combat, and follow the aura after combat. Older auras keep working. After the
rewrite of the Cooldown Manager files: the dispel border shows, an exact spell ID trigger keeps its icon in combat
and follows a rank change, and a Cooldown Manager clone that ends in combat (Flame Shock next to Lightning Shield)
hides without error.

### Fixed
- `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/RegionTypes/AuraBarNative.lua`, `WeakAuras/RegionTypes/AuraBar.lua`:
  a Cooldown Manager aura bar no longer stays full or frozen in combat; the native bar is not hidden or shown again
  while restricted, and follows the bar texture and color. The native bar styling no longer raises an error at login.
- `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/WeakAuras.lua`: clones for Cooldown Manager auras are prepared out of
  combat, so an aura cast for the first time in combat shows its timer instead of the last known state. This also
  covers textures and icons without a cooldown that use a `%p` Cooldown Manager text.
- `WeakAuras/CDMAuraProgress.lua`: the `%p` timer text follows the selected time format and is rebuilt after combat.
- `WeakAuras/WeakAuras.lua`, `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/SubRegionTypes/SubText.lua`: a region or
  clone holding a protected Blizzard aura container is anchored after combat instead of calling `SetParent` in
  combat (`ADDON_ACTION_BLOCKED`); spare clones are anchored when prepared out of combat, and a text already on the
  right parent is not parented again.
- `WeakAuras/CooldownViewerCatalog.lua`: after combat, an exact spell ID Cooldown Manager trigger reads the player
  aura by spell ID when the Cooldown Manager frame still holds a secret spell ID. In combat, the trigger keeps the
  last spell ID read on that frame, updated when the player casts another rank, so the aura stays shown.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: subregions are released in reverse order, so two or more texts keep
  their order when a region is reused.
- `WeakAuras/CDMAuraProgress.lua`: a spare clone that gets no aura container goes back to the clone pool instead of
  being lost, and the next spare reuses a pooled clone instead of creating a new frame each time; a reused clone or
  spare first drops what an Aura (Modern) aura left on it (hidden parts, native display state).
- `WeakAuras/WeakAuras.lua`: a released clone holding a Blizzard aura container goes back to the clone pool; in combat
  it is faded out and pooled after combat, instead of being dropped with a secure clone warning.

### Changed
- `WeakAuras/DurationText.lua`, `WeakAuras/SubRegionTypes/CDMDispel.lua`,
  `WeakAuras/SubRegionTypes/CDMDispelBorder.lua`, `WeakAuras/DispelTypeDisplay.lua`, `WeakAuras/CDMAuraProgress.lua`,
  `WeakAuras/CooldownViewerCatalog.lua`: rewritten without ForeverAuras code.
- `Tests/`: headless scenarios for Cooldown Manager timing in combat, native fallback, protected anchors and
  protected clone release; the harness provides `C_StringUtil.CreateNumericRuleFormatter`.

## 2026-10-09

Released as 1.7.0. Tested in game on WoW Forever with a Shaman: Not on Cooldown and On Cooldown spell triggers with
Show Global Cooldown unchecked, in combat.

### Fixed
- `WeakAuras/WeakAuras.lua`: a full `WeakAuras.Add` on a loaded aura outside the editor (for example the rebuild of
  a group child after a growth change) unloads the old aura and loads the new one, so its icon no longer stays hidden
  until `/reload`.
- `WeakAuras/SecretSpellCooldown.lua`, `WeakAuras/GenericTrigger.lua`: a secret spell cooldown held only by the
  global cooldown is flagged as GCD-only and counts as ready, as with readable cooldowns. A `Not on Cooldown` trigger
  with `Show Global Cooldown` unchecked stays active during the GCD instead of reading a one-hour cooldown. With
  `Show Global Cooldown` checked, `On Cooldown` no longer shows on every GCD.

### Changed
- `.github/workflows/release.yml`: the Discord announcement and changelog post link to CurseForge and Wago only;
  the GitHub release link and the GitHub lines of the changelog section are left out.

## 2026-10-09

Released as 1.6.2.

### Fixed
- `WeakAuras/Prototypes.lua`: the Swing Timer trigger with Target In Range or Out of Range now shows with no swing
  in progress, so Out of Range works when the player stands away from the target.
- `WeakAuras/SecretAuraAppearance.lua`, `WeakAuras/RegionTypes/Icon.lua`: with a Masque skin, an Icon keeps its set
  size once it shows in game; the size given to Masque is pinned on each reskin.
- `WeakAuras/DurationText.lua`, `WeakAuras/SecretAuraAppearance.lua`, `WeakAuras/SecretAuraSingle.lua`,
  `WeakAuras/CDMAuraProgress.lua`: native `%p` duration text follows the Old Blizzard (`3m`, `10s`) and Modern
  Blizzard (`3m 7s`, `1h 3m`) time formats instead of always showing `3:07`.
- `WeakAuras/CooldownViewerTrigger.lua`, `WeakAuras/SpellCooldownState.lua`: while Shoot (wand) runs, Cooldown
  Manager spell triggers show the timer copied before the shot instead of the Shoot timer.
- `WeakAuras/Transmission.lua`, `WeakAuras/Locales/enUS.lua`, `WeakAuras/Locales/frFR.lua`: aura link requests
  are not whispered while addon chat is blocked; the player gets a message instead of a silent failure.
- `WeakAuras/WeakAuras.lua`: lower per-frame budget for normal threads while addon restrictions are active.
- `WeakAurasTemplates/TriggerTemplatesDataForever.lua` (new), `WeakAurasTemplates/WeakAurasTemplates.toc`,
  `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`: class templates use WoW Forever spell IDs; IDs missing
  from the client are removed, Forever spells are added when known.

### Changed
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: the options window title reads "Musca Auras" and the Musca
  Auras version instead of "WeakAuras" and the WeakAuras version.
- `WeakAuras/ForeverTutorial.lua`: removed the last section of the in-game guide.
- `WeakAuras/WeakAuras.toc`: added the Wago project ID (`## X-Wago-ID`).

## 2026-10-07

Released as 1.6.1.

### Fixed
- `WeakAuras/RegionTypes/Text.lua`: a Text region shown only through native secret text (`%power`, `%health`...)
  no longer keeps zero-sized bounds; its first size is measured on a sample number, with fallback dimensions.
- `WeakAuras/Prototypes.lua`, `WeakAuras/PrototypeSecretHelpers.lua`: the Cast trigger no longer reports
  "Forbidden function or table: pcall"; its generated code calls `C_Spell.IsSpellImportant` through
  `Private.ExecEnv.IsSpellImportant` instead of `pcall` inside the aura sandbox.
- `WeakAuras/WeakAuras.lua`: a text placeholder typed without a trigger number (`%unit`) gets its formatter
  arguments, so `%unit` defaults to class colors. Auras saved before this fix keep their format; set Color to
  Class in the text options.

## 2026-10-06

Released as 1.6.0. Tested in game on WoW Forever with a Shaman: spell cooldowns, Aura (Modern), totems, weapon
enchants, bars, `/reload` in combat. Not tested in game: Grid mode, Ignore Dead and Ignore Disconnected, more than 40
nameplates, exports shared between players.

### Added
- `WeakAuras/SpellCooldownState.lua`, `WeakAuras/WeakAuras.toc`: one spell cooldown state module (per-spell secret
  check, charges, GCD-only, loss of control, wand hold, desaturation choice). `WeakAuras/AuraEnvironment.lua` exposes
  it to built-in trigger code.
- `WeakAuras/SecretAuraFlow.lua`, `WeakAurasOptions/RegionOptions/GroupModernFlow.lua`: Grid mode for Modern Aura
  Groups. One shared aura container per group and per unit (screen, unit frames, nameplates) wraps its lines natively.
  It is rebuilt only when options, units or children change, waits for the end of combat and restrictions, and is
  removed when the group is unloaded, deleted or leaves the grid. Options: Grid, Grid direction, Row Width / Column
  Height, Row Space, Column Space. Grid is off by default, so existing groups keep their layout.
- `WeakAurasOptions/SecretAuraTriggerOptions.lua`, `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAuraFlow.lua`:
  Ignore Dead and Ignore Disconnected on Aura (Modern) triggers for group, party and raid. Only the member that
  changes is refreshed; a secret state hides the container natively instead of being read.

### Changed
- `WeakAuras/SecretAuraFlow.lua`, `WeakAuras/SecretAuraSingle.lua`: aura group and slot names renamed with this
  fork's prefix (`MuscaShadow`, `MuscaMissing`, `MuscaPresence`, `MuscaRemainIcon`, `MuscaRemainGate`).
- `WeakAuras/Transmission.lua`: exports keep the `!WA:2!` prefix, but their compressed bytes are encrypted with a
  stream cipher and a random nonce, so ForeverAuras and upstream WeakAuras fail to decompress them. Imports and chat
  links read both Musca and plain WeakAuras strings; link requests stay plain so other players still answer them.
- `WeakAuras/SecretAuraRanks.lua`, `WeakAuras/PlayerSpecialization.lua`: the CC BY 4.0 attribution of the
  talentsforever.com data is back at the top of each file, with the list of changes; rank families keep their class
  and spell comments.
- `WeakAuras/SecretRestrictions.lua`, `WeakAuras/SecretAuraSingle.lua`, `WeakAuras/SecretAuraConditions.lua`: one
  restriction check, `WeakAuras.IsRestricted`. It covers combat, secret auras and secret cooldowns, and treats an
  unreadable answer as restricted.
- `WeakAuras/SecretSpellCooldown.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Prototypes.lua`,
  `WeakAuras/SecretConditions.lua`, `WeakAuras/PrototypeSecretHelpers.lua`, `WeakAuras/WeakAuras.lua`: spell
  cooldowns go through `SpellCooldownState`. Only secret spells are tracked, with a timer at the readable end instead
  of polling. A GCD alone no longer sends a ready event or desaturates a spell. New `durationObjectWithoutGCD` field.
- `WeakAuras/SecretAuraFlow.lua`: Modern Aura Group chaining runs once per group on the next frame instead of once
  per child.
- `WeakAuras/BlizzardAuraDisplay.lua`: trigger copies are cached per saved trigger; containers are re-anchored only
  when their anchor changes; extra unit containers are removed when the unit count drops.
- `WeakAuras/BlizzardAuraDisplay.lua`: Aura (Modern) on nameplates is no longer capped at 40 nameplates; the token
  list grows with the nameplates seen and is shared across events.
- `WeakAuras/SecretAuraConditions.lua`: threshold rules and color ownership are cached per aura; a condition
  property set to its current value is not applied again.
- `WeakAurasOptions/RegionOptions/GroupModernFlow.lua`, `WeakAuras/BlizzardAuraDisplay.lua`: Sort and Reverse Sort
  apply to live containers without adding every child again.
- `WeakAuras/CooldownViewerTrigger.lua`, `WeakAuras/CooldownViewerCatalog.lua`, `WeakAuras/CDMBackground.lua`,
  `WeakAuras/CDMAuraProgress.lua`: cache keys no longer build a table; local secret checks use `Private.IsSecret`.
- `WeakAuras/SecretAuraSingle.lua`: aura learning no longer creates closures and tables on every UNIT_AURA event.
- `WeakAuras/SecretAuraConditions.lua`, `WeakAuras/Conditions.lua`, `WeakAuras/SecretAuraFlow.lua`: unused
  `FilterGlobalConditions`, `flowFrameModes` and `FlowGrowthKey` removed; highlight definitions built once.
- `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAura*.lua`, `WeakAuras/SecretConditions.lua`,
  `WeakAuras/SecretRestrictions.lua`, `WeakAuras/SecretSpellCooldown.lua`: short note on each file's role and callers.

### Fixed
- `WeakAuras/BlizzardAuraDisplay.lua`: queued Modern Aura applies run under `xpcall` within 8 ms per frame, wait
  for the end of login and resume when restrictions end; Restore no longer puts back a stale Update or PreShow.
- `WeakAuras/SecretAuraFlow.lua`: group chaining and unit frame links skipped in combat are replayed at the end of
  combat, even while a PvP or key restriction stays active.
- `WeakAuras/CDMAuraProgress.lua`: native aura containers are not created under restrictions; `%N.p` and `%N.s`
  texts build their source when the aura loads, so they are no longer empty in the first combat.
- `WeakAuras/GenericTrigger.lua`: spells added while secret get their charges; stale secret charges are no longer
  reported.
- `WeakAuras/SecretAuraAppearance.lua`: a manual icon source with an empty path shows the aura icon.
- `WeakAuras/SecretAuraConditions.lua`, `WeakAuras/SecretAuraPreview.lua`: condition migration no longer errors on
  auras without triggers; the preview pandemic window follows the sample duration.

## 2026-10-05

### Changed
- The fork is renamed from "WeakAuras Forever" to "Musca Auras". Folders, files, saved variables, the `WeakAuras`
  API, the `/wa` and `/weakauras` commands and the import format keep the WeakAuras names.
- `WeakAuras/WeakAuras.toc`, `WeakAurasArchive/WeakAurasArchive.toc`, `WeakAurasModelPaths/WeakAurasModelPaths.toc`,
  `WeakAurasOptions/WeakAurasOptions.toc`, `WeakAurasTemplates/WeakAurasTemplates.toc`: new `## Title`.
- `WeakAuras/WeakAuras.lua`: title of the first login message.
- `WeakAuras/ForeverTutorial.lua`: title and text of the in-game guide.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: Guide button tooltip, thanks text and Discord text.
- `WeakAuras/Libs/LibCustomGlow-1.0/LibCustomGlow-1.0.lua`, `WeakAuras/Libs/LibRangeCheck-3.0/LibRangeCheck-3.0.lua`,
  `WeakAuras/Libs/Chomp/Internal.lua`: comments only.
- `.github/workflows/release.yml`: changelog heading check and CurseForge file name.
- `README.md` (with a new license section), `DESCRIPTION.md`, `GUIDE.md`, `TUTORIAL.md`, `TESTS-EN-JEU.md`,
  `CHANGES.md` (title, ForeverAuras author corrected to Neroxrw, M33kAuras credit),
  `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`: new name, version 1.5.0.
- Repository URLs point to `github.com/dldvlpr-addons-wow/Musca-Auras` (the five `.toc` `X-Website`, `README.md`,
  `DESCRIPTION.md`, `GUIDE.md`, `TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`,
  `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`, `WeakAurasOptions/Changelog.lua`, the 1.5.0 entry of
  `WeakAuras/CHANGELOG.md`). Past changelog entries keep the old URL, which GitHub redirects.
- Fork code moved out of `WeakAuras/BuffTrigger2.lua` again, same behavior: `WeakAuras/BuffTriggerRestrictedAuras.lua`
  now also holds the refresh of the auras during the restriction, the reset of the player auras on a recast, the
  rescan when the restriction ends and the per aura protection of the state update; new
  `WeakAuras/BuffTriggerNativeFilter.lua` (native filter of the Aura trigger, loaded before `BuffTrigger2.lua`),
  `WeakAuras/WeakAuras.toc` lists it.
- Fork code moved out of `WeakAuras/GenericTrigger.lua`, same behavior: new `WeakAuras/GenericTriggerRestricted.lua`
  (loaded before `GenericTrigger.lua`, listed in `WeakAuras/WeakAuras.toc`) holds the `WA_RESTRICTION_CHANGED` and
  `WA_SECRET_STATE_UPDATE` events sent when the restriction changes, the combat log and secret threshold warnings
  (`GenericTrigger.lua` calls `Private.UpdateRestrictedTriggerWarnings` at the end of the trigger load) and the
  totem slots read while totems are secret (`Private.ExecEnv.GetTotemSlotInfo`).
- Fork code moved out of `WeakAuras/GenericTrigger.lua`, same behavior: new `WeakAuras/SecretSpellCooldown.lua`
  (loaded before `GenericTrigger.lua`, listed in `WeakAuras/WeakAuras.toc`) holds the reading of secret spell
  cooldowns: the GCD flag of each spell, the wand shot hold, the readiness check and its polling
  (`Private.CreateSecretSpellCooldown`, which adds `UpdateSecretReady` and `ClearSecretReady` to the spell cooldown
  tracker and returns the handler of its events), and `Private.IsDurationObjectRunning`, used by the Global
  Cooldown trigger.

### Fixed
- `WeakAuras/SecretSpellCooldown.lua`: while cooldowns are secret, Cooldown Ready could fire after a global cooldown
  alone, because the end of the global cooldown is seen at the next 0.1 s check and a frame hitch adds to it. A spell
  must now stay not ready for more than 2 s instead of 1.6 s before Cooldown Ready fires.
- `WeakAuras/SecretAuraFlow.lua`: an aura in a Modern Aura Group can use a Progress Bar display, not only an Icon.
- `WeakAuras/SecretAuraSingle.lua`: an Icon on Aura (Modern) with a Remaining Time threshold showed only the icon
  and the duration text; its other display elements (textures, other texts, borders) stayed hidden. A second aura
  slot of the game's aura widget now drives an invisible duration text whose width follows the threshold, and these
  elements are drawn inside a frame clipped to that text, so they show and hide with the icon.
- `WeakAuras/SecretAuraGlow.lua`, `WeakAuras/BlizzardAuraDisplay.lua`: on Aura (Modern), a glow restyled while the
  aura is shown (for example when the aura is clicked in the options) stayed still or disappeared, because the game
  plays the registered animations only when the aura appears. The element glows and the main glow now start right
  after they are registered.
- `WeakAuras/Conditions.lua`: a number condition on a secret value is false instead of raising a Lua error.

### Added
- `WeakAuras/Prototypes.lua`, `WeakAuras/PrototypeSecretHelpers.lua`: Power trigger, "Show at or above the value
  instead" for "Show only below (%)": the step curve passed to `UnitPowerPercent` is inverted (0 below the value, 1
  from the value). With a secret power, a Power trigger with a comparison is inactive; this option shows the aura
  from a value without comparing it, for example with a Swing Timer trigger and "All Triggers".
  `WeakAuras/Locales/enUS.lua`: the new string.
- `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAurasOptions/SecretAuraTriggerOptions.lua`: Aura (Modern), "Include Pets"
  (Players and Pets, Pets only) for the group, party and raid units: the pets of the tracked members (`pet`,
  `partypetN`, `raidpetN`) that exist are added after the name and role filters, the unit list and the native aura
  sounds are rebuilt on `UNIT_PET`, and Players and Pets doubles the number of unit slots.

## 2026-10-04

### Added
- `WeakAuras/Prototypes.lua`: "Show only below (%)" option of the Health and Power triggers (not for Stagger).
  `Private.ExecEnv.ThresholdAlpha` passes a step curve (1 below the value, 0 from the value) to `UnitHealthPercent`
  or `UnitPowerPercent` and stores the result, secret in combat, as `thresholdAlpha`. `WeakAuras/WeakAuras.lua`:
  `thresholdAlpha` is not scrubbed, and it is set as the alpha of the region when the state is applied, Text and
  Stop Motion regions included, except while the options are open; the alpha of the aura comes back when the
  option is off. Alpha conditions are not kept, an alpha animation wins while it runs, and with several triggers
  using the option only one is used. `WeakAuras/Animations.lua`:
  an animation that starts on a secret alpha starts from 1. `WeakAuras/Locales/enUS.lua`: the two new strings.
  Curve checked in game on WoW Forever 70124 (a frame alpha follows the energy of the player in combat).
- Features also found in ForeverAuras, written for this fork with ForeverAuras as the behavior reference. Tested
  in game on WoW Forever 70124: Desaturate while on cooldown with its condition, Hide GCD Text, `%N.p` and `%N.s`
  on Aura (Modern), restriction events, the new Character Stats (values match the game API out of combat, hidden in
  combat), Important on the casts of the player. The rest is not tested in game yet.
  - `WeakAuras/Prototypes.lua`: Cast trigger, "Important" tristate and condition, read from
    `C_Spell.IsSpellImportant`; a secret value is unknown and hides the cast when the filter is used.
  - `WeakAuras/Prototypes.lua`: Cooldown Progress (Spell) trigger, "Desaturate while on cooldown" (state
    `desaturateSpell`) and "Hide GCD Text" (with Show Global Cooldown, sets the `cdmHideGCDText`, `cdmGCDOnly` and
    `cdmTextDurationObject` fields already read by `WeakAuras/DurationText.lua` and the Icon region);
    `Private.ExecEnv.GetSpellCooldownDurationWithoutGCD`. `WeakAuras/WeakAuras.lua`: while a state carries
    `desaturateSpell`, the icon desaturation is set every 0.1 s from
    `C_CurveUtil.EvaluateColorValueFromBoolean(duration:IsZero(), 0, 1)`, secret in combat, through
    `Private.SetNativeRefresh`, one shared 0.1 s ticker for visible regions. A Desaturate setting or condition of the
    aura wins over the option and comes back when the option is off (`WeakAuras/RegionTypes/Icon.lua` keeps it in
    `desaturateWanted`, `WeakAuras/RegionTypes/AuraBar.lua` in `desaturateIcon`). `WeakAuras/RegionTypes/Icon.lua`:
    the countdown alpha read from `cdmTextDurationObject` is evaluated again by the same ticker, so the numbers hide
    when the cooldown ends during a global cooldown, for the Cooldown Manager trigger too.
  - `WeakAuras/Prototypes.lua`: Character Stats trigger, Bonus Healing, Ranged Attack Power, Spell Haste (%),
    Ranged Haste (%) and Expertise (%) on Classic Era clients, with the `UNIT_RANGED_ATTACK_POWER`,
    `UNIT_SPELL_HASTE` and `UNIT_RANGEDDAMAGE` events; `WeakAuras.GetEffectiveAttackPower(ranged)`,
    `Private.ExecEnv.GetRangedHastePercent`.
  - `WeakAuras/Prototypes.lua`: Unit Characteristics trigger, "Ignore out of checking range" (`UnitIsVisible`) for
    group units, refreshed on `PARTY_MEMBER_ENABLE` and `PARTY_MEMBER_DISABLE`.
  - `WeakAuras/CDMAuraProgress.lua`: a `%N.p` or `%N.s` text whose trigger N is an Aura (Modern) trigger on one
    unit, in an aura not drawn by the game's aura widgets, is drawn by an aura container bound to that trigger
    (created out of combat only, refreshed on target, focus and pet changes). A new time format applies out of
    combat without a reload; the per frame update allocates nothing once bound.
  - `WeakAuras/Init.lua`: the restriction state is checked again on `PLAYER_IN_COMBAT_CHANGED`,
    `ENCOUNTER_STATE_CHANGED`, `CHALLENGE_MODE_START` and the `PVP_MATCH_*` events.
  - `WeakAuras/Locales/enUS.lua`: the new strings.
- Spell charges in combat. `WeakAuras/Prototypes.lua`: `Private.ExecEnv.GetSpellDisplayCount` reads
  `C_Spell.GetSpellDisplayCount`; the Cooldown Progress (Spell) trigger stores it as `secretStacks` while the cooldown
  of a spell with charges or a count is secret, shown by a `%s` text. `WeakAuras/GenericTrigger.lua`:
  `WeakAuras.IsSpellCooldownSecret`. Not tested in game yet.
- Conditions on secret values. `WeakAuras/Conditions.lua`: when a condition tests a value the game keeps secret,
  the alpha, color and desaturation it changes are computed by the game itself
  (`C_CurveUtil.EvaluateColorValueFromBoolean` for booleans, a step curve on the duration object for "remaining time
  lower or greater than"), in priority order with the other conditions; the normal values come back when the value is
  readable again. The remaining time is refreshed every 0.1 s while it is secret. Linked conditions keep the normal
  behavior. `WeakAuras/GenericTrigger.lua`: `conditionSecretTest` of a trigger argument. `WeakAuras/Prototypes.lua`:
  secret tests for Interruptible and Important (Cast), Spell Usable, Insufficient Resources and Spell in Range; the
  Spell Usable and Insufficient Resources tests no longer compare a secret value. `WeakAuras/WeakAuras.lua`: the
  `secretFlag` fields of a state stay secret. `WeakAuras/RegionTypes/RegionPrototype.lua`, `Icon.lua`, `Text.lua`,
  `Texture.lua`, `AuraBar.lua`: the alpha, color and desaturation properties accept a secret value, with a secret
  desaturation setter. `WeakAuras/Animations.lua`: no color animation from a secret color. Tested in game on WoW
  Forever 70124: Interruptible color, Spell in Range, Insufficient Resources, remaining time lower than a value.

### Fixed
- Secret values no longer raise Lua errors. Not tested in game yet.
  - `WeakAuras/GenericTrigger.lua`: a trigger filter on a secret value fails alone instead of stopping the whole
    trigger function; dynamic fields (name, icon...) that turn secret are stored without comparison; a secret unit
    GUID counts as unknown, so the unit change events are still sent and the GUID tables stay current.
  - `WeakAuras/Prototypes.lua`: Cast trigger, `C_Spell.IsSpellImportant` is called under `pcall`, as the spell ID
    of another unit is secret, and a secret stage count of a channel is skipped.
  - `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`, `WeakAuras/RegionTypes/Text.lua`,
    `WeakAuras/SubRegionTypes/SubText.lua`: Cast trigger keeps a
    secret spell name in `state.secretName`; the `%n` placeholder gives it to the text as is, the text, raid
    marker replacement and rotated subtext offset skip a secret string, and chat actions other than print and combat text are skipped
    when the message is secret. A secret text is set without measuring it, so the text region keeps its last
    readable size instead of shrinking to 1 pixel and disappearing. Tested in game on WoW Forever 70124.
  - `WeakAuras/SubRegionTypes/Glow.lua`: no glow while the size of the region is secret.
  - `WeakAuras/Animations.lua`: a zoom animation starts from the configured size when the size is secret.
  - `WeakAuras/Prototypes.lua`: Bag Space and Equipment Durability give no value while the game keeps it secret.

### Changed
- Rewritten in this fork's own way (names and expressions only, still derived from ForeverAuras), same behavior,
  from the files taken from ForeverAuras on 2026-10-03:
  `WeakAuras/TextStyle.lua`, `WeakAuras/DurationText.lua`, `WeakAuras/ProgressTextureNative.lua`,
  `WeakAuras/CDMBackground.lua`, `WeakAuras/DispelTypeDisplay.lua`, `WeakAuras/SubRegionTypes/CDMDispel.lua`,
  `WeakAuras/SubRegionTypes/CDMDispelBorder.lua`, `WeakAurasOptions/ColorPalette.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.lua`, `WeakAurasOptions/TriggerSecretWarnings.lua`,
  `WeakAurasOptions/VersionCheck.lua`, `WeakAurasOptions/SubRegionOptions/CDMDispel.lua`,
  `WeakAurasOptions/SubRegionOptions/CDMDispelBorder.lua`. Tested in game on WoW Forever 70124.
- Rewritten the same way, same behavior: `WeakAuras/CooldownViewerTrigger.lua` (the unused `hasTimer` argument is
  gone), `WeakAuras/CooldownViewerCatalog.lua`, `WeakAuras/CDMSetup.lua`, `WeakAuras/CDMAuraProgress.lua`,
  `WeakAurasOptions/CooldownViewerOptions.lua`. Tested in game on WoW Forever 70124 (cooldown and buff triggers;
  class pack setup ran on a character already set up, so it changed nothing).
- Rewritten the same way, same behavior, Aura (Modern): `WeakAuras/BlizzardAuraDisplay.lua`,
  `WeakAuras/SecretAuraSingle.lua`, `WeakAuras/SecretAuraFlow.lua`, `WeakAuras/SecretAuraConditions.lua`,
  `WeakAuras/SecretAuraAppearance.lua`, `WeakAuras/SecretAuraGlow.lua`, `WeakAuras/SecretAuraTrigger.lua`,
  `WeakAuras/SecretAuraPreview.lua`, `WeakAurasOptions/AuraDisplayOptions.lua`,
  `WeakAurasOptions/AuraTriggerOptions.lua` (two unused constants removed),
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`. Tested in game on WoW Forever 70124 (player buff by exact and
  all-ranks spell ID, target debuff, remaining time condition, native ring, Modern Aura Group).
- Rewritten the same way, same behavior, talent picker of the load options:
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua` (widget type and version kept). Tested in
  game on WoW Forever 70124.
- Second pass, local names and equivalent expressions only, same behavior: `WeakAuras/ProgressTextureNative.lua`,
  `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/CDMSetup.lua`, `WeakAuras/SecretAuraConditions.lua`,
  `WeakAuras/SecretAuraSingle.lua`. Tested in game on WoW Forever 70124.
- Fork code moved out of `WeakAuras/Prototypes.lua` to keep the upstream file closer to 5.22.0, same behavior:
  new `WeakAuras/ClassicEraTriggers.lua` (Ammo, Bag Space, Equipment Durability, Role and Tracking triggers, loaded
  after `Prototypes.lua`), new `WeakAuras/PrototypeSecretHelpers.lua` (secret value and cast helpers, loaded before
  `Prototypes.lua`), Cooldown Manager spell lists moved to `WeakAuras/CooldownViewerCatalog.lua`, `WeakAuras/WeakAuras.toc`
  lists the two new files. Tested in game on WoW Forever 70124 (Bag Space, Equipment Durability, Role, Tracking,
  health and mana percent, player cast bar, Cooldown Manager triggers); Ammo not tested yet.
- Fork code moved out of `WeakAuras/RegionTypes/AuraBar.lua` the same way, same behavior: new
  `WeakAuras/RegionTypes/AuraBarNative.lua` (native StatusBar drawing for secret values and additional bars, loaded
  before `AuraBar.lua`), `WeakAuras/WeakAuras.toc` lists it. Tested in game on WoW Forever 70124 (player cast bar).
- Fork code moved out of `WeakAuras/Conditions.lua` the same way, same behavior: new `WeakAuras/SecretConditions.lua`
  (conditions on secret values: generated code, secret pick, boolean and remaining time selection, refresh), loaded
  after `Conditions.lua`, `WeakAuras/WeakAuras.toc` lists it. Tested in game on WoW Forever 70124 (interruptible color,
  range and mana, remaining time and combat conditions).
- Fork code moved out of `WeakAuras/RegionTypes/ProgressTexture.lua`, `WeakAuras/SubRegionTypes/SubText.lua` and
  `WeakAuras/Init.lua` the same way, same behavior: new `WeakAuras/RegionTypes/ProgressTextureSecret.lua` (native ring
  and bar for secret progress, loaded before `ProgressTexture.lua`), new `WeakAuras/SubRegionTypes/SubTextNative.lua`
  (native text for secret values and duration text, loaded before `SubText.lua`), new `WeakAuras/SecretRestrictions.lua`
  (combat log, secret value and restriction detection, loaded right after `Init.lua`), `WeakAuras/WeakAuras.toc` lists
  them. Tested in game on WoW Forever 70124 (native ring and text on an aura, restriction detection in and out of
  combat).
- Fork code moved out of `WeakAuras/BuffTrigger2.lua` the same way, same behavior: new
  `WeakAuras/BuffTriggerRestrictedAuras.lua` (readable auras added during the restriction, loaded before
  `BuffTrigger2.lua`), `WeakAuras/WeakAuras.toc` lists it. Tested in game on WoW Forever 70124 (Aura trigger
  in and out of combat).
- Fork code moved out of `WeakAurasOptions/RegionOptions/Group.lua` the same way, same behavior: new
  `WeakAurasOptions/RegionOptions/GroupModernFlow.lua` (Aura (Modern) group options and icon, loaded before
  `Group.lua`), `WeakAurasOptions/WeakAurasOptions.toc` lists it. Tested in game on WoW Forever 70124.
- Comments added by this fork removed from the WeakAuras files and from `WeakAuras/ForeverAurasImport.lua`,
  `WeakAuras/SubRegionTypes/DispelIcon.lua`, no code change.
- `TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`: the low mana alert points to the new option instead of "Does not
  work".
- `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`, `DESCRIPTION.md`: 1.4.1.
- `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`: 1.4.2.
- `DESCRIPTION.md`: the ForeverAuras credit is one line pointing to this file.

## 2026-10-03

### Added
- `WeakAuras/Prototypes.lua`: "Hide when target changes" option of the Spell Cast Succeeded trigger. When it is
  checked, the trigger also listens to `PLAYER_TARGET_CHANGED`. `WeakAuras/GenericTrigger.lua`: on that event, every
  state of the trigger is removed, as for "Hide when target dies"; both options now apply to the Spell Cast
  Succeeded trigger only. `WeakAuras/Locales/enUS.lua`: the two new strings. `TUTORIAL.md`,
  `WeakAuras/ForeverTutorial.lua`: the option and the missed spell limit. Tested in game on WoW Forever 70124.

Port of the ForeverAuras features this fork did not have yet. Code taken from ForeverAuras and adapted to this
fork's names and existing mechanisms. Not tested in game yet.

### Added
- `WeakAuras/PlayerSpecialization.lua`, `WeakAuras/SpecializationData-LICENSE.txt`: "Specialization" load option
  (`forever_spec`), deduced from the final talents learned in each of the 27 talent trees.
- `WeakAuras/Prototypes.lua`: load options "Secret Restrictions Active" (`addonRestrictionsActive`) and "Enabled
  BossMod ID (BW Only)" (`enabledBossModID`); "Spell in Range" trigger; combat readability status in the Cast
  trigger options, read from `C_Secrets.GetSpellCastSecrecy`.
- `WeakAuras/BossMods.lua`: `WeakAuras.IsBossModEnabled`, `WA_BOSSMOD_ENABLED_STATE_CHANGED`.
- `WeakAuras/TextStyle.lua`: `Private.ApplyTextFont`, shared font and shadow setup for Text regions and sub texts.
- `WeakAuras/DurationText.lua`: duration text formatters.
- `WeakAuras/ProgressTextureNative.lua`: native progress texture helpers.
- `WeakAurasOptions/ColorPalette.lua`, `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasColorPicker.lua`:
  palette next to the color picker (class colors, favorites, recent colors, hex field), saved in
  `WeakAurasOptionsSaved.colorPalette`.
- `WeakAurasOptions/VersionCheck.lua`: the options do not open when the Options and WeakAuras versions differ.
- `WeakAurasOptions/TriggerSecretWarnings.lua`: warning in the trigger options for fields that are secret in combat
  (`WeakAurasOptions/GenericTrigger.lua`, `WeakAurasOptions/BuffTrigger2.lua`).
- Blizzard Cooldown Manager trigger type (`cdm`): `WeakAuras/CooldownViewerTrigger.lua`,
  `WeakAuras/CooldownViewerCatalog.lua`, `WeakAuras/CDMAuraProgress.lua`, `WeakAuras/CDMBackground.lua`,
  `WeakAuras/CDMSetup.lua`, `WeakAuras/SubRegionTypes/CDMDispel.lua`,
  `WeakAurasOptions/SubRegionOptions/CDMDispel.lua`, `WeakAurasOptions/CooldownViewerOptions.lua`. Hooked into
  `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Modernize.lua` (old cooldown manager
  triggers moved to `cdm`), `WeakAuras/RegionTypes/RegionPrototype.lua`, `WeakAuras/RegionTypes/Icon.lua`,
  `WeakAuras/RegionTypes/AuraBar.lua`, `WeakAuras/RegionTypes/ProgressTexture.lua`,
  `WeakAuras/SubRegionTypes/SubText.lua`, `WeakAurasOptions/GenericTrigger.lua`,
  `WeakAurasOptions/BuffTrigger2.lua`, `WeakAurasOptions/CommonOptions.lua`,
  `WeakAurasOptions/RegionOptions/Icon.lua`, `WeakAurasOptions/SubRegionOptions/SubText.lua`, and
  `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` ("Hide Blizzard's CDM", saved as `cdmHideBlizzard`).
- Aura (Modern) trigger type (`secretAura`), drawn by the game's aura widgets: `WeakAuras/SecretAuraRanks.lua`,
  `WeakAuras/BlizzardAuraDisplay.lua`, `WeakAuras/SecretAuraPreview.lua`, `WeakAuras/DispelTypeDisplay.lua`,
  `WeakAuras/SecretAuraAppearance.lua`, `WeakAuras/SecretAuraConditions.lua`, `WeakAuras/SecretAuraSingle.lua`
  (learned durations saved in `WeakAurasSaved.auraDurations` and `WeakAurasSaved.auraProfiles`),
  `WeakAuras/SecretAuraGlow.lua`, `WeakAuras/SecretAuraFlow.lua` (Modern Aura Group), `WeakAuras/SecretAuraTrigger.lua`,
  `WeakAuras/SubRegionTypes/CDMDispelBorder.lua`, `WeakAurasOptions/SubRegionOptions/CDMDispelBorder.lua`,
  `WeakAurasOptions/AuraDisplayOptions.lua`, `WeakAurasOptions/AuraTriggerOptions.lua`,
  `WeakAurasOptions/SecretAuraTriggerOptions.lua`. Hooked into `WeakAuras/WeakAuras.lua` (release, migration,
  restore and modify around the region, native actions, unit frame and nameplate anchoring),
  `WeakAuras/Conditions.lua` (native conditions), `WeakAuras/RegionTypes/RegionPrototype.lua`,
  `WeakAuras/RegionTypes/Group.lua` (`blizzardFlow*` settings), `WeakAurasOptions/CommonOptions.lua`,
  `WeakAurasOptions/ConditionOptions.lua`, `WeakAurasOptions/DisplayOptions.lua`, `WeakAurasOptions/TriggerOptions.lua`
  (`secretFallback`), `WeakAurasOptions/ActionOptions.lua`, `WeakAurasOptions/WeakAurasOptions.lua`,
  `WeakAurasOptions/RegionOptions/Group.lua`, `WeakAurasOptions/OptionsFrames/OptionsFrame.lua` (New "Modern Aura
  Group"), `WeakAurasOptions/SubRegionOptions/SubRegionCommon.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasDisplayButton.lua`.

### Changed
- `WeakAuras/Init.lua`: `WeakAuras.IsSecretStateActive`.
- `WeakAuras/GenericTrigger.lua`:
  - spell cooldowns under secret values: a public ready state is polled every 0.1 s for spells on cooldown, kept
    not ready for 1.6 s after a global cooldown, and Cooldown Ready fires once on the transition, ignoring the
    shared Shoot cooldown;
  - Loss of Control cooldown read through `C_Spell.GetSpellLossOfControlCooldownInfo` first;
  - totem name, icon and spell are kept from the last readable values when they become secret
    (`WeakAurasSaved.totemSpells`);
  - crit and hit chance return 0 while unit stats are secret;
  - the swing timer no longer registers the combat log;
  - `WA_SECRET_STATE_UPDATE` is fired with the restriction change.
- `WeakAuras/Prototypes.lua`: Spell in Range through `C_Spell.IsSpellInRange`, attack and spell power and Character
  Stats guarded against secret values, Totem trigger through the kept slot values.
- `WeakAuras/WeakAuras.lua`: load options are evaluated again when restrictions or boss mod modules change; `/wa cdm`
  hides the Blizzard Cooldown Manager by opacity instead of turning its CVar off, so `cdm` triggers keep working.
- `WeakAuras/ForeverAurasImport.lua`: ForeverAuras `cdm` and `secretAura` triggers and dispel borders are kept as
  they are instead of being converted; "Converted from ForeverAuras." is printed only when something was converted.
- `WeakAuras/CHANGELOG.md`, `WeakAurasOptions/Changelog.lua`: 1.4.0.
- `WeakAurasOptions/LoadOptions.lua`: a description whose text is a function receives the trigger.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: `durationObject` progress source, secret value and total kept apart,
  guards on secret alpha, times and texture paths.
- `WeakAuras/RegionTypes/ProgressTexture.lua`: native linear fill with inverse direction, smoothing, and native
  ring with crop, rotation, mirror and start and end angles.
- `WeakAuras/RegionTypes/AuraBar.lua`: inverse direction and smoothing for a secret value, native additional bars.
- `WeakAuras/RegionTypes/Text.lua`, `WeakAuras/SubRegionTypes/SubText.lua`: `ApplyTextFont`, secret text and size
  guards.
- `WeakAuras/RegionTypes/DynamicGroup.lua`: layout delayed to the end of combat when an anchor is protected,
  secret anchor sizes clamped to 1.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: color options use the palette color picker.
- `WeakAuras/WeakAuras.toc`, `WeakAurasOptions/WeakAurasOptions.toc`: new files.
- `.luacheckrc`: game globals read by the ported files.

### Fixed
- `WeakAuras/BuffTrigger2.lua`: the Name Pattern Match filter of the Aura trigger matched every aura. The equality
  test was written `not name == pattern`, which is never true, and without an operator chosen the filter was
  skipped. The operator now defaults to equality, and a secret aura name never matches.
- `WeakAuras/Transmission.lua`: an aura exported by this addon is no longer run through the ForeverAuras import
  conversion, found by the sender version of the import string.
- `WeakAuras/Init.lua`, `WeakAuras/Libs/Archivist/Archivist.lua`: the alpha, experimental and debug blocks are
  removed. They were already in the form the BigWigs packager writes, so the packager closed them a second time
  (`--@end-alpha@]=]]=]`), and the 1.3.2 zip built by the release workflow did not load (`unexpected symbol near
  ']'`, then `attempt to index global 'WeakAuras'`). These blocks were never run in a release.
- `WeakAuras/Prototypes.lua`: the Action Usable trigger read `paused` from the 5th return of
  `WeakAuras.GetSpellCooldown`, which is `modRate`; it now reads the 6th.
- `WeakAuras/Prototypes.lua`: `WeakAuras.GetRange` and `WeakAuras.CheckRange` call LibRangeCheck under `pcall` and
  return nothing when the range is secret.
- `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`: `WeakAuras.GetCritChance`, `GetHitChance`,
  `GetEffectiveAttackPower` and `GetEffectiveSpellPower` return `nil` instead of `0` while the stats are secret.
- `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`: the "Secret Restrictions Active" load option is computed once
  per load scan and passed to the load functions, instead of once per aura.
- `WeakAurasOptions/TriggerSecretWarnings.lua`: `UnitStagger` is only called when the client has it.

## 2026-10-02

### Added
- `WeakAuras/Prototypes.lua`: "Hide when target dies" option of the Spell Cast Succeeded trigger. When it is
  checked, the trigger also listens to `PLAYER_TARGET_DIED`. `WeakAuras/GenericTrigger.lua`: on that event, every
  state of the trigger is removed, so the timer hides before its duration ends. The event has no payload: it only
  tells the death of the current target. `WeakAuras/Locales/enUS.lua`: the two new strings. Not tested in game yet.

### Changed
- `TUTORIAL.md`, `WeakAuras/ForeverTutorial.lua`: section 5 (DoT or buff timer from your cast) uses the Spell Cast
  Succeeded trigger with "Hide when target dies" instead of custom code. The "hide the timer when your target
  dies" variant is merged into the recipe, and the ready-made Immolate aura is exported again with this trigger.
- `.github/workflows/release.yml`: a pushed tag is also uploaded to CurseForge (project 1713094) by a step of the
  workflow, with the game version read from `## Interface` and the first section of `WeakAuras/CHANGELOG.md` as
  changelog. The workflow stops before packaging when that section is not for the pushed tag.

### Fixed
- `WeakAurasOptions/Cache.lua`: an aura name typed in the Aura trigger (and in the Load tab) is kept as typed when
  there is no combat log. The spell cache is never built there (see 2026-09-26), so the name correction found no
  match, stored an empty name, and the trigger matched nothing while an extra "or" row appeared.

## 2026-09-30

### Changed
- `WeakAuras/RegionTypes/ProgressTexture.lua`: a secret progress is drawn natively, like the Progress Bar. Left to
  Right, Right to Left, Bottom to Top and Top to Bottom textures follow an invisible `StatusBar` (`SetMinMaxValues`
  and `SetValue` for a secret value, `SetTimerDuration` for a duration object) through a mask on the foreground
  texture. Clockwise and Anticlockwise textures draw a native radial fill (`Texture:SetRadialProgressBarPercent`)
  from `state.secretPercent`, or from `EvaluateRemainingPercent` of the duration object on every frame. Not drawn
  natively: an inverted static value, extra textures, slant, crop, mirror and the start and end angles. Seen in
  game on WoW Forever 70124: a Left to Right texture on the health of a hostile target and a Clockwise texture on
  the power of the player move in combat. Colors, texture and desaturation follow the native radial texture, and a
  change of orientation or of the inverse setting redraws the native progress.
- `WeakAuras/Prototypes.lua`: the Health and Power triggers set `state.secretPercent` from `UnitHealthPercent` or
  `UnitPowerPercent` with the `CurveConstants.ZeroToOne` curve while the value is secret. `WeakAuras/WeakAuras.lua`
  does not scrub it, `WeakAuras/RegionTypes/RegionPrototype.lua` passes it with the main progress.
- `WeakAuras/RegionTypes/Text.lua`: a Text aura draws secret values natively like a Text sub element
  (`WeakAuras/SubRegionTypes/SubTextNative.lua`, shared `Private.UpdateNativeText`): a text that is only `%p` follows the
  duration object, and a text made of `%p`, `%t`, `%value`, `%total`, `%health`, `%maxhealth`, `%power`, `%maxpower`,
  `%percenthealth`, `%percentpower` and plain text shows the secret value, total and percent (the Health and Power
  triggers store `secretPercentText` from the `CurveConstants.ScaleTo100` curve); a literal `%` is kept, a text
  with `{` (raid markers, `%{...}` placeholders) is not drawn natively. Format options and other
  placeholders keep the last readable values. The size of a Text aura is not recomputed while it is drawn natively.
  A Text aura updates its progress before its text, so a native text shows the current event, not the previous one.
  Once its FontString has shown a secret text, its width and height are secret: the size of the Text aura is
  then left as is (seen in game on WoW Forever 70124).
- `WeakAuras/Prototypes.lua`: while the cast of a unit is secret, the Cast trigger keeps a `durationObject` from
  `UnitCastingDuration` or `UnitChannelDuration`, so the bar, the swipe and a `%p` text run in combat. Its name,
  icon and spell ID are secret: the name is shown empty and the icon is drawn from `secretIcon`, instead of the
  name and icon of the last readable cast. A trigger filtered by spell name or ID, by "Remaining Time" or by
  "Interruptible" does not match a secret cast.
- `WeakAuras/Prototypes.lua`: while a totem slot is secret, the Totem trigger keeps a `durationObject` from
  `GetTotemDuration`; the totem name, icon and spell ID filters accept a secret totem
  (`WeakAuras/GenericTrigger.lua`), the "Remaining Time" filter does not.
- `WeakAuras/Init.lua`: `Private.UnitIsUnit(unitA, unitB)` (`Private.ExecEnv.UnitIsUnit` in trigger code) returns
  the last readable result of the same pair when `UnitIsUnit` is secret (compound tokens like `targettarget` on
  restricted maps), nil when there is none. Used by the Specific Unit, Unit is Unit, Ignore Self, Source Unit and
  Destination Unit checks of the unit triggers (`WeakAuras/Prototypes.lua`) and by the unit event dispatch
  (`WeakAuras/GenericTrigger.lua`).
- `WeakAuras/WeakAuras.lua`: internal version 91, the one ForeverAuras now uses too, so an aura exported from
  either addon imports into the other without a version warning. Auras saved or exported at 90 still load: no
  migration step is needed, `Modernize` only raises their number. `WeakAuras/ForeverAurasImport.lua`: since the
  number no longer tells the two addons apart, a ForeverAuras export is found by its content only: ForeverAuras
  trigger and sub element types, dispel indicator, Blizzard aura display, the ForeverAuras fields of the Swing
  Timer, Tracking, Ammo and Bag Space triggers, a TimelineParser trigger, a media path to `AddOns\ForeverAuras`
  (one or more separators) in any string, or a `ForeverAuras` API reference in custom code. Not detectable: a
  ForeverAuras aura whose only triggers are Role or Equipment Durability, imported as is. The Tracking conversion
  only runs on ForeverAuras fields, so an aura of this addon with a ForeverAuras media path keeps its Tracking
  settings. `WeakAuras/Transmission.lua`: comment.

### Fixed
- `WeakAuras/Compatibility.lua`: on WoW Forever, `C_SpecializationInfo.GetTalentInfo` refuses the Classic Era
  query (`specializationIndex`, `talentIndex`) with "query.tier must be specified", and the error stopped the
  import of any aura with a Talent load condition (`GetTalentInfo(): C_SpecializationInfo.GetTalent: query.tier
  must be specified`). The call is now under `pcall` and returns nothing on this client.
- Talents on WoW Forever, like ForeverAuras: `WeakAuras/Compatibility.lua` sets `Private.traitTalents` (retail, or a
  WoW Forever client with `C_Traits` and `C_SpecializationInfo.GetCombatConfigIDForSpecGroup`).
  `WeakAuras/Prototypes.lua`: `Private.GetTalentConfigID()` and `Private.GetTalentData(specId)` (copied from
  ForeverAuras `Types_Forever.lua`) read the Classic
  talent trees of the player's specialization from the trait config of the active spec group (`C_Traits`), one
  entry per trait entry ID, the same IDs ForeverAuras exports. The talent check frame, `WeakAuras.CheckTalentId`
  and `WeakAuras.GetTalentById` run on this client (`ACTIVE_TALENT_GROUP_CHANGED` refreshes them too), and the
  Talent and Or Talent load conditions and the Talent Known trigger use them, with the talent picker
  (`WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent.lua`, from ForeverAuras, listed in
  `WeakAurasOptions/WeakAurasOptions.toc`) once a single Class and Specialization is selected.
  `WeakAuras/GenericTrigger.lua`: the talents are read after `PLAYER_ENTERING_WORLD` on this client. The
  ForeverAuras Specialization load condition (`forever_spec`) is not converted on import.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: on WoW Forever, a texture path that ends with `.tga` or `.blp` does
  not load (seen in game on 70124: `SetTexture` leaves the texture empty, the same path without the extension
  works). `Private.SetTextureOrAtlas` strips the extension, so the `.tga` entries of the texture picker (rings,
  circles, squares) and imported auras that use them are drawn.
- `WeakAuras/GenericTrigger.lua`: while cooldowns are secret, the Global Cooldown trigger reads whether the GCD runs
  from `isActive` of `C_Spell.GetSpellCooldown`, which is never secret. It relied on `IsZero` and `HasExpired` of the
  duration object, and `IsZero` is secret in combat on WoW Forever, so the trigger never showed in combat.
- `WeakAuras/BuffTrigger2.lua`: a `UNIT_AURA` whose unit or `isFullUpdate` flag is already secret is handled like
  any update received while aura data is secret, even when the `RestrictionChanged` callback has not fired yet. At
  the start of a fight, the payload could be secret one frame before that callback, which printed "Aura triggers
  paused until the end of combat" (`attempt to perform boolean test on field 'isFullUpdate'`). For the same reason,
  a full scan of a unit and the error filter of the aura updates also ask `Private.IsRestricted("auras")`, so that
  a scan started by another event during that frame (target change, encounter start, roster update) keeps the
  matched auras instead of cleaning them before failing on secret data.

## 2026-09-29

### Added
- `.luacheckrc`: luacheck checks syntax and global variables only. Every global the addons use is listed, so a new
  one (a typo, or an API not checked on WoW Forever) is reported. `.github/workflows/lint.yml` runs it on every push
  and pull request.

### Changed
- `WeakAuras/Init.lua`: `Private.IsRestricted(kind, ...)` asks `C_Secrets` whether auras, cooldowns, a spell
  cooldown, unit stats or unit identity are secret, and returns `nil` when the client cannot tell.
  `WeakAuras.IsRestricted()` is true while aura or cooldown data is secret (in combat without `C_Secrets`).
  The `RestrictionChanged` callback fires when that state changes. `Private.IsDurationObject(value)`.
- `WeakAuras/BuffTrigger2.lua`: aura triggers paused on secret data are rescanned when the restriction ends,
  instead of at the end of combat only.
- `WeakAuras/GenericTrigger.lua`: cooldowns are checked again when the restriction ends.
- `WeakAuras/RegionTypes/RegionPrototype.lua`: a timed trigger state can carry a `durationObject` (a duration object
  of the 12.x engine). Regions receive it with the trigger's main timer, unless the timer is paused or min or max
  progress is adjusted.
- `WeakAuras/RegionTypes/Icon.lua`: the cooldown swipe draws a `durationObject` with
  `SetCooldownFromDurationObject`, so it keeps running when the duration is secret.
- `WeakAuras/RegionTypes/AuraBar.lua`: an invisible native `StatusBar` runs a `durationObject` with
  `SetTimerDuration`, and the bar foreground mask follows its fill, so the bar keeps running when the duration is
  secret. In that mode the spark is shown unless it is set to always hidden.
- `WeakAuras/GenericTrigger.lua`: `WeakAuras.GetSpellCooldownDurationObject(id, showgcd, ignoreSpellKnown, track)`
  returns the duration object of `C_Spell.GetSpellCooldownDuration` (or `C_Spell.GetSpellChargeDuration` for charges)
  while the spell cooldown is secret. Spells with a secret cooldown send `SPELL_COOLDOWN_CHANGED` on every check.
  A `SPELL_UPDATE_COOLDOWN` with a secret payload checks every spell once on the next frame, instead of on every
  event. `WeakAuras/RegionTypes/Icon.lua`: the swipe of a duration object restarts only when its direction changes.
- `WeakAuras/Init.lua`: `Private.hasAuraInstanceAPI`, true when the aura instance API is available (Retail and the
  12.x engine). `WeakAuras/BuffTrigger2.lua` and `WeakAuras.GetAuraInstanceTooltipInfo` (`WeakAuras/WeakAuras.lua`)
  use it instead of `WeakAuras.IsRetail()`, so aura triggers handle `UNIT_AURA` incrementally by `auraInstanceID`.
- `WeakAuras/BuffTrigger2.lua`: while aura data is secret, `UNIT_AURA` no longer reads its payload. Once per frame,
  the auras already matched get a `durationObject` from `C_UnitAuras.GetAuraDuration`, and the ones that no longer
  exist are removed. Auras applied during the restriction, stacks and other fields are only read when it ends.
- `WeakAuras/Prototypes.lua`: the "Cooldown/Charges/Count" trigger sets `state.durationObject`, so its icon swipe and
  bar keep running in combat. Showing only on cooldown or when ready, and tracking a specific charge, still use the
  last readable cooldown.
- `WeakAuras/WeakAuras.lua`: when `value` or `total` of a trigger state is secret, both are also kept in
  `state.secretValue` and `state.secretTotal`, which are not scrubbed. `WeakAuras/RegionTypes/RegionPrototype.lua`
  passes them to regions with the main progress, unless min or max progress is adjusted.
  `WeakAuras/RegionTypes/AuraBar.lua` draws them with an invisible native `StatusBar` (`SetMinMaxValues`,
  `SetValue`), like duration objects, so health and power bars keep moving in combat. An inverted bar still shows the
  last readable value.
- `WeakAuras/Init.lua`, `WeakAuras/GenericTrigger.lua`, `WeakAuras/Prototypes.lua`: generated trigger code no longer
  errors on secret health or power without a threshold: the state store compares secret values without reading
  them, percent and deficit are `nil` while value or total is secret, and a secret raid marker is ignored. A
  threshold on a secret value (for example health >= 1000) still errors.
- `WeakAuras/GenericTrigger.lua`: without combat log, a trigger that errors keeps its last state instead of being
  untriggered, as described on 2026-09-28. Before, a trigger with automatic hiding was hidden.
- `WeakAuras/GenericTrigger.lua`: without combat log, the options warn about combat log triggers and CLEU events,
  which never fire, and about thresholds of Health and Power triggers, which cannot be checked on secret values.
- `WeakAuras/BuffTrigger2.lua`: an aura update that fails on secret data no longer stops the profiler from counting
  that aura.
- `WeakAuras/Compatibility.lua`: `Private.hasSpecializations`, true on Classic Era when the client has
  `C_SpecializationInfo` (WoW Forever). `WeakAuras/Types.lua`, `WeakAuras/Prototypes.lua`, `WeakAuras/WeakAuras.lua`:
  in that case the "Class and Specialization" load option and the "Class and Specialization" trigger are available,
  and loads are checked again on `PLAYER_SPECIALIZATION_CHANGED`.
- `WeakAuras/Prototypes.lua`: "Ammo" trigger on Classic Era, with the count, name and icon of the ammo in the ammo
  slot. `.luacheckrc`: `INVSLOT_AMMO`.
- `WeakAuras/Init.lua`: `Private.IsRestricted("auraInstance", unit, auraInstanceID)`.
  `WeakAuras/BuffTrigger2.lua`: while aura data is secret, auras applied during the restriction are listed with
  `C_UnitAuras.GetUnitAuraInstanceIDs`, and the ones that `C_Secrets.ShouldUnitAuraInstanceBeSecret` reports as
  readable are handled right away. The matched auras also get their stack text from
  `C_UnitAuras.GetAuraApplicationDisplayCount`, kept in `state.secretStacks` (`WeakAuras/WeakAuras.lua` does not scrub
  it).
- `WeakAuras/SubRegionTypes/SubText.lua`: a text that is only `%p` is drawn by a `C_DurationUtil` duration text
  binding when the region has a `durationObject`, and a text that is only `%s` shows `state.secretStacks`, so both
  keep updating in combat. In that mode `%p` uses the client's seconds format instead of the text format options,
  and `%s` is empty below 2 stacks. `.luacheckrc`: `C_DurationUtil`, `C_StringUtil`, and for the entries below `C_SwingTimer`, `C_CurveUtil`,
  `NUM_BAG_SLOTS`.
- `WeakAuras/GenericTrigger.lua`: when the restriction ends, unit health and power events are scanned again, so
  health and power triggers do not keep their last readable values until the next change. `WeakAuras/Init.lua`:
  `RestrictionChanged` also fires when only the unit stats restriction changes.
- `WeakAuras/Compatibility.lua`: `Private.hasNativeSwingTimer`, true when `C_SwingTimer` exists.
  `WeakAuras/GenericTrigger.lua`: the swing timer starts on `PLAYER_SWING` with the swing duration of the client,
  for main hand, off hand and ranged (wand included), and a secret attack speed keeps the last readable one.
  With `PLAYER_SWING`, only a swing paused by a cast restarts when the cast ends. `WeakAuras.IsTargetInSwingRange(hand)`.
  `WeakAuras/Prototypes.lua`: the Swing Timer trigger has a Target In Range option, updated by
  `PLAYER_SWING_RANGE_UPDATE`.
- `WeakAuras/GenericTrigger.lua`: without the global `GetWeaponEnchantInfo`, the weapon enchant trigger reads
  `C_Item.GetWeaponEnchantInfo` for main hand, off hand and ranged.
- `WeakAuras/GenericTrigger.lua`: while cooldowns are secret, the global cooldown comes from the duration object of
  `C_Spell.GetSpellCooldownDuration` (spell 61304, 29515 on Classic), returned by `WeakAuras.GetGCDInfo` as a sixth
  value. `WeakAuras/Prototypes.lua`: the Global Cooldown trigger stores it as `durationObject`.
- `WeakAuras/SubRegionTypes/Border.lua`: Color by Dispel Type option. The border takes the dispel type color of the
  aura, from `C_UnitAuras.GetAuraDispelTypeColor` (secret colors included), else from the readable debuff class,
  else the border color, also used for auras without dispel type. A border color set by a condition wins.
  `WeakAurasOptions/SubRegionOptions/Border.lua`: its toggle.
- `WeakAuras/Prototypes.lua`: the Ammo trigger filters by ammo item and gives the total of projectiles in the bags.
- `WeakAuras/Prototypes.lua`: `Private.GetCooldownManagerSpells()` lists the spells of the Cooldown Manager catalog
  (`C_CooldownViewer`). `WeakAurasOptions/LoadOptions.lua`: the Cooldown trigger has a From the Cooldown Manager
  picker that sets the spell to an exact spell ID of that catalog.
- `WeakAuras/ForeverAurasImport.lua` (new, listed in `WeakAuras/WeakAuras.toc`): auras exported by ForeverAuras
  (found by their ForeverAuras trigger or sub element types, see 2026-09-30) are converted on
  import, before the version check (`WeakAuras/Transmission.lua`). Their
  Cooldown Manager triggers become Cooldown, Aura or Item Cooldown triggers, Blizzard Aura triggers become Aura
  triggers, dispel type borders become borders colored by dispel type, the Swing Timer weapon and the Ammo
  item list are mapped, media paths to ForeverAuras point to WeakAuras, and so do API references in custom code. What has no
  equivalent is listed in the chat.
- `WeakAuras/ForeverTutorial.lua`, `TUTORIAL.md`, `README.md`: what works in combat now, and a section on
  importing ForeverAuras auras. `.pkgmeta`: `TUTORIAL.md` is not packaged. `.github/workflows/release.yml`:
  CurseForge and Wago keys, used once the .toc files carry project IDs.
- `WeakAuras/GenericTrigger.lua`: an attack speed change rescales the off hand swing by the off hand speed, instead of
  the main hand one.
- `WeakAuras/Prototypes.lua`, `WeakAuras/Types.lua`: the Swing Timer Target In Range option is a choice between In Range
  and Out of Range (`Private.swing_range_types`), so an unknown range (no target) matches neither.
- `WeakAuras/BuffTrigger2.lua`: a secret unit name or GUID is replaced by an empty name or the previous GUID instead
  of being compared.
- `WeakAuras/Libs/LibRangeCheck-3.0`, `WeakAuras/Libs/LibCustomGlow-1.0`, `WeakAuras/Libs/Chomp`: WoW Forever reports
  the retail project ID with a Classic interface version. These libraries use their Classic Era spells, items,
  textures and chat throttle there, and LibRangeCheck keeps its secret GUID handling.
- `WeakAuras/SubRegionTypes/SubText.lua`: the client-drawn `%p` text follows the Old or Modern Blizzard time format
  and the Increase Precision Below threshold (one decimal at most).
- `WeakAuras/GenericTrigger.lua`: after an attack speed change, the off hand swing keeps an offset like the main hand,
  so its shown end matches its timer, and both hands count the offset of an earlier change. `WeakAuras/Modernize.lua`: a Swing Timer Target In Range set with the former
  yes/no option is converted to In Range or Out of Range.
- `WeakAuras/Types.lua`: without the combat log, the Aura trigger no longer offers the Multi-target unit.
  `WeakAuras/BuffTrigger2.lua`: its unit tracking skips secret GUIDs.
- `WeakAuras/WeakAuras.lua`: `/wa cdm` shows or hides the Blizzard Cooldown Manager through the
  `cooldownViewerEnabled` CVar, outside combat only. `.luacheckrc`: `C_CooldownViewer`.
- `WeakAuras/Prototypes.lua`: new Bag Space (free and used slots of the carried bags, specialty bags on request),
  Equipment Durability (lowest item, overall, broken items, all slots or one), Role (group role of the player) and
  Tracking (active minimap tracking, by spell ID, or inverse) triggers. `WeakAuras/Types.lua`:
  `Private.durability_progress_types`. `.luacheckrc`: `C_Minimap`, `GetInventoryItemDurability`,
  `INVSLOT_FIRST_EQUIPPED`, `INVSLOT_LAST_EQUIPPED`.
- `WeakAuras/Prototypes.lua`, `WeakAuras/Types.lua`, `WeakAuras/WeakAuras.lua`: the Instance Type load option (by
  difficulty ID) is available. The difficulty names come from `GetDifficultyInfo`, without the outdated version
  warning for unknown IDs.
- `WeakAuras/Prototypes.lua`, `WeakAuras/GenericTrigger.lua`: the Conditions trigger has a Secret Restrictions Active
  option, updated on the `RestrictionChanged` callback (`WA_RESTRICTION_CHANGED`).
- `WeakAuras/Prototypes.lua`: the Cooldown trigger has an On Global Cooldown condition, with Show Global Cooldown
  enabled, for example to hide the cooldown text during the global cooldown.
- `WeakAuras/SubRegionTypes/DispelIcon.lua`, `WeakAurasOptions/SubRegionOptions/DispelIcon.lua` (new, listed in the
  .toc files): Dispel Type Icon sub element. It shows the dispel type icon of the default UI when the dispel type is
  readable, and a circle colored by the client (`C_UnitAuras.GetAuraDispelTypeColor`) when it is secret.
  `WeakAuras/SubRegionTypes/Border.lua` shares its dispel colors and curve, and no longer reads a secret dispel type.
- `WeakAuras/BuffTrigger2.lua`, `WeakAurasOptions/BuffTrigger2.lua`: the Aura trigger has an Elapsed Time filter, and
  a From the Cooldown Manager picker that adds the aura spell IDs of a tracked buff (linked spells, tooltip spell and
  spell, like the default UI). `WeakAuras/Prototypes.lua`: `Private.GetCooldownManagerAuras()`,
  `Private.GetCooldownManagerAuraSpellIDs(cooldownID)`.
- `WeakAuras/ForeverAurasImport.lua`: ForeverAuras Role, Tracking, Equipment Durability and Bag Space triggers,
  dispel type icons, and the elapsed and total time filters of Cooldown Manager buffs are converted too.
- `WeakAuras/BuffTrigger2.lua`, `WeakAurasOptions/BuffTrigger2.lua`, `WeakAuras/Types.lua`: the Aura trigger has a
  Native Filter option, with the aura categories of the client (`Private.aura_native_filter_types`: cast by me,
  crowd control, important, big and external defensive, dispellable...), each one required or excluded, tested with
  `C_UnitAuras.IsAuraFilteredOutByInstanceID`. When it is the only filter, auras applied during the restriction also
  match: their data stays secret, so the name is empty, and the game draws their icon (`state.secretIcon`,
  `WeakAuras/RegionTypes/Icon.lua`, kept by `WeakAuras/WeakAuras.lua`), timer and stack text. They are read again
  when the restriction ends. `WeakAuras/ForeverAurasImport.lua`: the native filters of Blizzard Aura triggers are
  converted, and their own auras filter becomes the native one.
  TimelineParser Stage triggers are listed as not converted, like TimelineParser Timer ones.
- `TUTORIAL.md`: sections 2 and 3 rewritten from the in-game tests (tested, limited, not tested, not working),
  notes on the boss timeline, custom code and the ForeverAuras Native Filter.
- `WeakAuras/ForeverTutorial.lua`: the tutorial window becomes the full guide, generated from `TUTORIAL.md` (all
  sections, code examples, and import buttons for the DoT timer, the nameplate DoT timer and the pre-pull
  checklist). The window is larger, and hides when an import button is clicked so the import dialog is visible.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: a "Guide: learn WeakAuras" button in the title bar of the
  `/wa` window opens the guide, with a tooltip that describes it. `WeakAuras/WeakAuras.lua`: the `/wa` help line
  and the first login popup point to the guide.

### Fixed
- `WeakAuras/Prototypes.lua`: the Role trigger checks secret roles with `Private.ExecEnv.IsSecret`, available to
  the generated trigger code. The Npc ID of the unit triggers (Unit Characteristics, Health, Power, Threat Situation, Cast) is
  `nil` when the unit GUID is secret, instead of failing the trigger: an Npc ID filter then hides the aura.
  The Health trigger listens to `UNIT_HEALTH`, since the engine has no `UNIT_HEALTH_FREQUENT` (its health bar did
  not move in combat). The percent and deficit of the Health, Power, Faction Reputation and Experience triggers
  (`Private.ExecEnv.PercentOrSecret`, `Private.ExecEnv.DeficitOrSecret`) stay secret when their value is, so that
  `WeakAuras/WeakAuras.lua` keeps their last readable value, and a "Health < 50%" condition keeps its last state in
  combat instead of turning false. The Equipment Durability percentages are rounded down to whole numbers, so "below N" thresholds are unchanged.
- `WeakAuras/SubRegionTypes/SubText.lua`: while a progress value is secret, a text made only of `%p`, `%t` and
  plain text (for example `%p / %t`) is drawn from the secret value and total, unformatted, without raid marks or
  line breaks.

## 2026-09-28

### Added
- `WeakAuras/ForeverTutorial.lua`, listed in `WeakAuras/WeakAuras.toc`: in-game tutorial window (`/wa tutorial`)
  explaining how auras work on WoW Forever, with two example auras that can be imported from the window (a DoT
  timer from the player's own cast, and a pre-pull checklist).

### Changed
- `WeakAurasOptions/Changelog.lua`, `WeakAuras/CHANGELOG.md`: WeakAuras Forever changelog instead of the upstream
  one.
- `WeakAuras/WeakAuras.lua`: a popup listing the WoW Forever limitations is shown once, at the first login.
- `WeakAuras/GenericTrigger.lua`: the Loss of Control cooldown uses `C_Spell.GetSpellLossOfControlCooldown` when it
  exists, and `GetSpellLossOfControlCooldown` otherwise.
- `WeakAuras/Prototypes.lua`: `FindBaseSpellByID`, `FindSpellOverrideByID`, `IsSpellKnown` and `IsPlayerSpell`
  fall back on `C_SpellBook`. The "Queued Action" trigger uses `C_Spell.IsCurrentSpell`.
- `WeakAurasOptions/LoadOptions.lua`: `IsPlayerSpell` falls back on `C_SpellBook.IsSpellKnown`.
- `WeakAuras/WeakAuras.lua`: `/wa tutorial` and `/wa tuto` open the tutorial, `/wa help` lists it, and the first
  login popup has a "Tutorial" button.
- `WeakAuras/Init.lua`: `Private.IsSecret(...)`, true when any argument is a secret value.
- `WeakAuras/WeakAuras.lua`: secret values in a changed trigger state, and in fallback states, are replaced by the
  last readable value of that field (or `nil`). Nested tables such as overlays are not scrubbed. Lua errors raised
  on a secret value inside protected aura code (custom code, generated triggers, conditions) are not reported:
  the aura keeps its last state until the data is readable again. `GetNumTalentTabs` and `GetSpecialization` are
  optional in the talent caches.
- `WeakAuras/GenericTrigger.lua`: when spell, charge, item or item slot cooldowns are secret, the cooldown tracker
  keeps the last readable cooldown, so a cooldown still becomes ready at its known end time.
  `WeakAuras.GetSpellCooldownUnified` returns `false` alone in that case. The GCD ends at its known end time, and
  the Shoot cooldown is not stored when secret. Secret `SPELL_UPDATE_COOLDOWN` and `SPELL_UPDATE_USES` payloads
  are ignored, overlay values that are secret are dropped, and every cooldown is checked again on
  `PLAYER_REGEN_ENABLED`.
- `WeakAuras/BuffTrigger2.lua`: `UnitExistsFixed` returns `true` when the unit GUID is secret.
- `WeakAuras/GenericTrigger.lua`: the unit change tracker (target, focus, nameplates, group) no longer errors when
  unit GUIDs, raid markers, reactions or roles are secret, for example creature GUIDs inside instances: the unit
  is reported as changed, and GUID-based "unit is unit" tracking is skipped for it. The nameplate target tracker
  ignores secret target GUIDs.

## 2026-09-26

### Added
- `WeakAuras/WeakAuras.toc`, `WeakAurasArchive/WeakAurasArchive.toc`, `WeakAurasModelPaths/WeakAurasModelPaths.toc`,
  `WeakAurasOptions/WeakAurasOptions.toc`, `WeakAurasTemplates/WeakAurasTemplates.toc`: copies of the `_Vanilla.toc`
  files with `Interface: 16001`, title `WeakAuras Forever`, fork author, `X-License`, and the CurseForge, Wago,
  WoWInterface and website identifiers removed, `X-Website` set to the fork repository.

### Changed
- `WeakAuras/Init.lua`: `Private.hasCombatLog`, false on the 12.x engine.
- `WeakAuras/GenericTrigger.lua`: `COMBAT_LOG_EVENT_UNFILTERED` is not registered without combat log (generic
  triggers and swing timer). `UnitGroupRolesAssigned` is optional.
- `WeakAuras/BuffTrigger2.lua`: `UnitAura` fallback on `C_UnitAuras.GetAuraDataByIndex`. Without combat log, the
  multi-target aura frame skips the combat log, and aura reads that fail on secret data are caught: triggers keep
  their last state and every unit is rescanned on `PLAYER_REGEN_ENABLED`.
- `WeakAuras/Types.lua`, `WeakAuras/WeakAuras.lua`: legacy talent API (`GetNumTalentTabs`, `GetNumTalents`) is
  optional. `C_Engraving` is optional.
- `WeakAurasOptions/Cache.lua`: no full spell ID scan without combat log, because querying some spell IDs crashes
  the client (`Aura used in Client PlayerCondition is not known on the client`). `IsSpellKnown` falls back on
  `C_SpellBook.IsSpellKnown`.
- `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasSpinBox.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasPendingInstallButton.lua`,
  `WeakAurasOptions/AceGUI-Widgets/AceGUIWidget-WeakAurasPendingUpdateButton.lua`,
  `WeakAurasOptions/OptionsFrames/FrameChooser.lua`: `MouseIsOver(frame)` replaced by `frame:IsMouseOver()`.
- `WeakAurasOptions/OptionsFrames/OptionsFrame.lua`: fork credit added at the top of the "Thanks" tooltip, original
  credits unchanged. "Documentation" and "Found a Bug?" point to the fork repository, "Discord" says "Coming soon".
- `WeakAurasTemplates/TriggerTemplatesDataClassicEra.lua`: `GetSpellInfo` and `GetSpellDescription` fall back on
  `C_Spell`.

### Removed
Forever only: files that no other client flavor needs here.
- Every flavor toc (`*_Vanilla.toc`, `*_TBC.toc`, `*_Wrath.toc`, `*_Cata.toc`, `*_Mists.toc`) in the 5 addons.
- `WeakAuras/`: `Dragonriding.lua`, `Legendaries.lua`, `LibSpecializationWrapper.lua`, `PatreonList.lua`,
  `Types_Cata.lua`, `Types_Mists.lua`, `Types_Retail.lua`, `Types_TBC.lua`, `Types_Wrath.lua`.
- `WeakAurasModelPaths/`: `ModelPaths.lua`, `ModelPathsCata.lua`, `ModelPathsClassic.lua`, `ModelPathsMists.lua`,
  `ModelPathsTBC.lua`, `ModelPathsWrath.lua`.
- `WeakAurasOptions/`: `VersionCheck.lua`, `AceGUI-Widgets/AceGUIWidget-WeakAurasMiniTalent_Cata.lua`,
  `_Mists.lua`, `_TWW.lua`, `_Wrath.lua`.
- `WeakAurasTemplates/`: `TriggerTemplatesData.lua`, `TriggerTemplatesDataCataclysm.lua`,
  `TriggerTemplatesDataMists.lua`, `TriggerTemplatesDataTBC.lua`, `TriggerTemplatesDataWrath.lua`.

## Known limitations

- Combat log triggers (`CLEU:...`, "Combat Log" event) never fire: the engine forbids the combat log to addons.
  Damage taken is available through `UNIT_COMBAT:player`.
- Aura triggers freeze during combat when aura data is secret, and update when combat ends. The `C_UnitAuras`
  calls of the restricted path (`GetAuraDuration`, `GetAuraApplicationDisplayCount`, `GetUnitAuraInstanceIDs`,
  `GetAuraDataByAuraInstanceID`) fail for addon code in combat ("Auras cannot be accessed when secret while
  tainted", confirmed in game for `GetAuraDuration` and `GetUnitAuraInstanceIDs`): stacks stay frozen, and a buff
  cast by someone else does not reset its timer. `WeakAuras/BuffTrigger2.lua`: during the restriction,
  `UNIT_SPELLCAST_SUCCEEDED` on `player` resets the timer of a buff on the player cast by the player with the same
  spell ID, to its last readable duration, whatever the target of the cast (the event does not give it). Only
  triggers on the Player unit. A buff first applied during combat is still only seen when combat ends.
- The swing timer does not reset on melee hits (it used the combat log).
- Spell and item cooldowns are frozen in combat when they are secret. A cooldown known before combat still becomes
  ready at its end time, but a cooldown started in combat is only seen when combat ends. An aura loaded during
  combat sees its spell as ready.
- Talent load options are empty, and the options do not suggest spells or icons by name: type the spell ID.
- The folder name `WeakAuras` and the global `WeakAuras` are kept on purpose, so auras from Wago and existing
  SavedVariables keep working. Do not install it next to the official WeakAuras.

# Musca Auras

Port of [WeakAuras](https://github.com/WeakAuras/WeakAuras2) 5.22.0 (Classic Era flavor) to WoW Forever 1.60.1,
a Classic client running on the modern 12.x engine (interface 16001).

Original work: The WeakAuras Team, GPL-2.0 (see `WeakAuras/LICENSE`).
Modifications: dldvlpr, GPL-2.0.
Portions taken from ForeverAuras (Neroxrw, GPL-2.0), a WeakAuras fork for WoW Forever: the talent data reader and
the talent picker widget, see 2026-09-30; the secret value handling, load options and options panels listed on
2026-10-03. Specialization data in `WeakAuras/PlayerSpecialization.lua` comes from talentsforever.com under
CC-BY 4.0, see `WeakAuras/SpecializationData-LICENSE.txt`, and the spell rank data in `WeakAuras/SecretAuraRanks.lua`
too, see `WeakAuras/SpellRankData-LICENSE.txt`.
`WeakAuras/RegionTypes/AuraBarNative.lua` contains code from M33kAuras (m33shoq, GPL-2.0).

This file lists every file changed from the upstream 5.22.0 release, as required by GPL-2.0 section 2a.

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
- Rewritten in this fork's own way, same behavior, from the files taken from ForeverAuras on 2026-10-03:
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

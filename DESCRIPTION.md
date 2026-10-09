<h1 style="text-align: center;"><span style="color: #0cf;">Musca</span> <span style="color: #ffd100;">Auras</span></h1>

**The WeakAuras you know, rebuilt for WoW Forever.**  
Icons, bars, texts and timers that keep working on the modern engine, even in combat.

***

## <span style="color: #ff6b35;">⚠️ Heads-up: 1.7.0</span>

*   <span style="color: #ffd100;"><strong>Restart the game after the update:</strong></span> a new file is not loaded by a `/reload`.
*   <span style="color: #3c3;"><strong>Tested in game on WoW Forever:</strong></span> spell cooldowns, Aura (Modern) buffs and debuffs, totems (out of combat), weapon enchants, health, power, swing and cast bars, `/reload` in combat, Swing Timer range, `%p` time formats, spell cooldowns during the global cooldown in combat.
*   <span style="color: #ff9800;"><strong>Not tested in game yet:</strong></span> Grid mode, more than 40 nameplates, Masque skins, rebuilt auras.
*   <span style="color: #ffd100;"><strong>Lua errors, or an aura no longer behaves as in 1.6.2?</strong></span> Install **1.6.2** again from the **Files** tab of the CurseForge page.
*   <span style="color: #3c3;"><strong>Your auras are kept.</strong></span> The saved data format did not change.
*   <span style="color: #0cf;"><strong>Please report it</strong></span> on GitHub or CurseForge, with the text of the error.

***

## <span style="color: #0cf;">⚡ What is it?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **Musca Auras** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1):

*   <span style="color: #ffd100;"><strong>Same addon, same habits.</strong></span> `/wa` opens the options, and your saved auras load as they are.
*   <span style="color: #ffd100;"><strong>No Lua error storm in combat.</strong></span> When the game hides a value, the aura keeps its last state and updates when the data is readable again.
*   <span style="color: #ffd100;"><strong>The game draws what addons cannot read.</strong></span> Cooldown swipes, timer bars, health and power bars, progress textures, texts, buffs and debuffs keep moving in combat.
*   <span style="color: #ffd100;"><strong>Wago auras import.</strong></span> See below what to expect.

***

## <span style="color: #0cf;">✨ New in 1.6: lots of fixes and improvements</span>

This version brings a large batch of patches and bug fixes, and one new layout option.

<span style="color: #ffd100;"><strong>New</strong></span>

*   **Grid mode for the Modern Aura Group:** one grid per group, on the screen, the unit frames or the nameplates, with direction, row width or column height, and row and column space. Off by default: existing groups keep their layout.
*   **Aura (Modern) on nameplates** is no longer limited to 40 nameplates.

<span style="color: #3c3;"><strong>Fixes</strong></span>

*   **Spell cooldowns:** a global cooldown alone no longer sets off Cooldown Ready or desaturates a spell.
*   **Spell charges** no longer show outdated values after combat.
*   **Modern Aura Group:** changes made in combat are applied at the end of combat, also in battlegrounds and arenas.
*   **Aura (Modern):** displays are applied smoothly after login and after combat, without stale updates.
*   **`%N.p` and `%N.s` texts** are no longer empty in the first combat after a `/reload`.
*   **Manual icon:** an empty path now shows the aura icon.
*   **Conditions:** no more Lua error on auras without triggers; the pandemic window of the preview follows the sample duration.

<span style="color: #3c3;"><strong>Fixed in 1.6.1</strong></span>

*   **Text displays** that show only `%power`, `%health` or another value hidden by the game are visible again.
*   **Cast trigger:** no more "Forbidden function or table: pcall" error.
*   **`%unit`** without a trigger number is colored by class by default. For an aura saved before 1.6.1, set Color to Class in the text options.

<span style="color: #3c3;"><strong>Fixed in 1.6.2</strong></span>

*   **Swing Timer:** Target In Range and Out of Range work again with no swing in progress.
*   **`%p` texts** follow the Old Blizzard (`3m`, `10s`) and Modern Blizzard (`3m 7s`) time formats.
*   **Cooldown Manager spell triggers** no longer show the wand Shoot timer while you shoot.
*   **Aura links:** a message tells you when addon whispers are blocked.
*   **Templates** use the WoW Forever spell IDs.
*   **Masque:** an Icon keeps its size once it shows in game. Not tested in game yet.

<span style="color: #3c3;"><strong>Fixed in 1.7.0</strong></span>

*   **Spell cooldowns in combat:** the global cooldown alone no longer counts as a cooldown. Not on Cooldown with Show Global Cooldown unchecked stays shown during the GCD.
*   **Rebuilt auras:** an aura rebuilt while loaded, for example a group child after a growth change, no longer stays hidden until `/reload`. Not tested in game yet.

<span style="color: #0cf;"><strong>Performance</strong></span>

*   Fewer updates for Modern Aura Groups, conditions, nameplates and the Cooldown Manager trigger.

***

## <span style="color: #0cf;">🧰 Built for WoW Forever</span>

*   **Aura (Modern) trigger:** buffs and debuffs drawn by the game's own aura widgets, so duration and stacks keep moving in combat. With the **Modern Aura Group** to lay out Icons and Progress Bars, `%1.p` / `%1.s` texts, and an Include Pets option for group, party and raid.
*   **Low energy, mana or health alerts in combat:** the Health and Power triggers have a **Show only below (%)** option, or **Show at or above the value instead**. The game itself hides the aura on the other side of the value. Example: an icon that shows at or above 80 energy.
*   **Conditions in combat:** Interruptible, Important, Spell Usable, Insufficient Resources, Spell in Range and remaining time lower or greater than a value keep working in combat. The game applies the alpha, color and desaturation they set.
*   **Blizzard Cooldown Manager trigger:** cooldowns, buffs, debuffs and items shown by the game's Cooldown Manager, drawn natively. "Hide Blizzard's CDM" keeps the triggers working while the Blizzard frame is hidden.
*   **Cooldown Progress (Spell) trigger:** Desaturate while on cooldown, Hide GCD Text, and a `%s` text that shows the charges of a spell.
*   **Spell Cast Succeeded trigger:** Hide when target dies, Hide when target changes. DoT timers from your own cast, with no custom code.
*   **Cast trigger:** Important filter and condition, and the spell name of a mob's cast with `%n` in combat.
*   **Load conditions:** Specialization (deduced from the talents you learned), Secret Restrictions Active, Enabled BossMod ID (BigWigs).
*   **Also:** Spell in Range trigger, new Character Stats (Bonus Healing, Ranged Attack Power, Spell and Ranged Haste, Expertise), Ignore out of checking range for group members, color picker palette, and warnings in the trigger options for values the game hides in combat.

***

## <span style="color: #0cf;">📖 Learn everything, in game</span>

Click the <span style="color: #ffd100;"><strong>Guide</strong></span> button at the top of the `/wa` window, or type `/wa tutorial`. The guide covers:

*   how an aura works, tab by tab;
*   what changed on WoW Forever, and what works in combat;
*   step-by-step recipes: DoT timer from your own cast, one timer per mob on its nameplate, pre-pull checklist, boss timeline, custom code;
*   <span style="color: #ffd100;"><strong>ready-made auras to import in one click</strong></span>.

***

## <span style="color: #0cf;">🌐 Auras from Wago</span>

<span style="color: #4caf50;"><strong>Auras from Wago work in Musca Auras.</strong></span> Import them the usual way.

<span style="color: #ff9800;"><strong>Some of them can have bugs.</strong></span> They were made for an older game engine, and the engine change on WoW Forever affects them:

*   triggers that read the combat log never fire: the game forbids the combat log to addons;
*   values the game hides in combat (buffs, cooldowns, health, power, casts of enemies) are frozen or drawn natively, so a threshold or a custom check on them can stop working in combat;
*   spells typed by name can miss: every rank has its own ID, type spell IDs instead;
*   custom code that calls removed functions (`GetSpellInfo`, `UnitBuff`…) shows an error: update it to `C_Spell`, `C_UnitAuras`, `C_Item`.

If an aura from Wago misbehaves, the guide shows how to rebuild the part that breaks. Report anything that looks like a Musca Auras bug on GitHub.

***

## <span style="color: #0cf;">🎯 What you can use</span>

<span style="color: #4caf50;"><strong>✔ Tested in game, works in combat</strong></span>

*   Spell cooldowns: swipe and number, with an "On Global Cooldown" condition, Desaturate while on cooldown, Hide GCD Text and Cooldown Ready.
*   Global Cooldown trigger.
*   Buffs on yourself and debuffs on your target with the Aura (Modern) trigger, with the remaining time condition, the native ring and the Modern Aura Group.
*   Blizzard Cooldown Manager trigger: cooldowns and buffs.
*   Health bar of your target and power bar of yourself, as bars, progress textures or a `%p / %t` text.
*   Show only below (%) on your energy.
*   Cast bar of your target, its Interruptible color, and its spell name with `%n`.
*   Conditions: Spell in Range, Insufficient Resources, remaining time lower than a value.
*   Swing timer, main hand.
*   Range Check trigger.
*   Your own casts (`UNIT_SPELLCAST_SUCCEEDED:player`) with an exact spell ID, `PLAYER_TARGET_DIED`, Hide when target changes.
*   `/reload` in combat.

<span style="color: #4caf50;"><strong>✔ Tested in game</strong></span>

*   Totem trigger (one aura per totem slot), temporary weapon enchants, Elapsed Time filter, Bag Space, Equipment Durability, Role, Tracking, Character Stats (hidden in combat), Secret Restrictions Active load condition, `/wa cdm`.

<span style="color: #ff9800;"><strong>⚠ Works, with limits</strong></span>

*   With the classic Aura trigger, buffs and debuffs are hidden in combat: stacks stay frozen, and a buff applied for the first time in combat only shows when combat ends. Use Aura (Modern) for combat.
*   Aura (Modern) needs the spell ID of the aura itself, which can differ from the spell you cast.
*   The Modern Aura Group only lays out Aura (Modern) displays. Put other triggers (totems, weapon enchants, cooldowns) in a Dynamic Group.
*   Conditions in combat: only alpha, color and desaturation follow them; sounds, glows and other changes wait for the end of combat. Conditions on percentages, such as target health, or on stacks keep the value from before combat.
*   Show only below (%) uses a percent of the maximum, and replaces the alpha of the aura.
*   Spells must be entered by ID: the options do not suggest spells by name.
*   Nameplate anchoring only works with the default Blizzard nameplates.

<span style="color: #f44336;"><strong>✖ Does not work</strong></span>

*   Combat log triggers: the game forbids the combat log to addons.
*   Other players' casts, enemy names and IDs in instances.
*   The Native Filter of the classic Aura trigger shows nothing at the moment.

***

<span style="color: #f44336;"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

***

## <span style="color: #0cf;">🐞 Support</span>

Found a bug, or an aura that should work and does not? [Open an issue on GitHub](https://github.com/dldvlpr-addons-wow/Musca-Auras/issues).

Discord: coming soon.

***

## <span style="color: #0cf;">⚖ License and credits</span>

*   **Musca Auras** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/LICENSE). Changes © 2026 dldvlpr, same license.
*   It also includes code from [M33kAuras](https://github.com/m33shoq/M33kAuras) by m33shoq and from [ForeverAuras](https://github.com/neroxrw/foreverauras) by Neroxrw, both under the GPL v2.
*   **Specialization and spell rank data** come from talentsforever.com, under CC-BY 4.0.
*   **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`.
*   **Source code and change list:** every modified file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/Musca-Auras](https://github.com/dldvlpr-addons-wow/Musca-Auras).
*   **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
*   Not affiliated with or endorsed by The WeakAuras Team, m33shoq, Neroxrw or Blizzard Entertainment. World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc.

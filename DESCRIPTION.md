<p style="text-align:center">![Musca Auras](https://raw.githubusercontent.com/dldvlpr-addons-wow/Musca-Auras/main/.github/logo.png)</p>

# <span style="color:#0cf">WeakAuras</span> <span style="color:#ffd100">Forever</span>

**The WeakAuras you know, rebuilt for WoW Forever.**  
Icons, bars, texts and timers that keep working on the modern engine, even in combat.

***

## <span style="color:#0cf">⚡ What is it?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **Musca Auras** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1):

*   <span style="color:#ffd100"><strong>Same addon, same habits.</strong></span> `/wa` opens the options, and your saved auras load as they are.
*   <span style="color:#ffd100"><strong>No Lua error storm in combat.</strong></span> When the game hides a value, the aura keeps its last state and updates when the data is readable again.
*   <span style="color:#ffd100"><strong>The game draws what addons cannot read.</strong></span> Cooldown swipes, timer bars, health and power bars, progress textures, texts, buffs and debuffs keep moving in combat.
*   <span style="color:#ffd100"><strong>Wago and ForeverAuras auras import.</strong></span> See below what to expect.

***

## <span style="color:#0cf">✨ New in 1.4</span>

*   **Low energy, mana or health alerts in combat:** the Health and Power triggers have a **Show only below (%)** option. The game itself hides the aura above the value. Example: an icon that shows under 70 energy.
*   **Aura (Modern) trigger:** buffs and debuffs drawn by the game's own aura widgets, so duration and stacks keep moving in combat. With the **Modern Aura Group** to lay them out.
*   **Blizzard Cooldown Manager trigger:** cooldowns, buffs, debuffs and items shown by the game's Cooldown Manager, drawn natively. "Hide Blizzard's CDM" keeps the triggers working while the Blizzard frame is hidden.
*   **Spell Cast Succeeded trigger:** Hide when target dies, Hide when target changes. DoT timers from your own cast, with no custom code.
*   **Load conditions:** Specialization (deduced from the talents you learned), Secret Restrictions Active, Enabled BossMod ID (BigWigs).
*   **Spell in Range trigger**, color picker palette, and warnings in the trigger options for values the game hides in combat.

***

## <span style="color:#0cf">📖 Learn everything, in game</span>

Click the <span style="color:#ffd100"><strong>Guide</strong></span> button at the top of the `/wa` window, or type `/wa tutorial`. The guide covers:

*   how an aura works, tab by tab;
*   what changed on WoW Forever, and what works in combat;
*   step-by-step recipes: DoT timer from your own cast, one timer per mob on its nameplate, pre-pull checklist, boss timeline, custom code;
*   <span style="color:#ffd100"><strong>ready-made auras to import in one click</strong></span>.

***

## <span style="color:#0cf">🌐 Auras from Wago</span>

<span style="color:#4caf50"><strong>Auras from Wago work in Musca Auras.</strong></span> Import them the usual way.

<span style="color:#ff9800"><strong>Some of them can have bugs.</strong></span> They were made for an older game engine, and the engine change on WoW Forever affects them:

*   triggers that read the combat log never fire: the game forbids the combat log to addons;
*   values the game hides in combat (buffs, cooldowns, health, power, casts of enemies) are frozen or drawn natively, so a threshold or a custom check on them can stop working in combat;
*   spells typed by name can miss: every rank has its own ID, type spell IDs instead;
*   custom code that calls removed functions (`GetSpellInfo`, `UnitBuff`…) shows an error: update it to `C_Spell`, `C_UnitAuras`, `C_Item`.

If an aura from Wago misbehaves, the guide shows how to rebuild the part that breaks. Report anything that looks like a Musca Auras bug on GitHub.

Auras exported from **ForeverAuras** import as they are: same data version, same talent IDs, and their Aura (Modern) and Cooldown Manager triggers are kept. What has no equivalent is listed in the chat.

***

## <span style="color:#0cf">🎯 What you can use</span>

<span style="color:#4caf50"><strong>✔ Tested in game, works in combat</strong></span>

*   Spell cooldowns: swipe and number, with an "On Global Cooldown" condition.
*   Buffs on yourself with the Aura (Modern) trigger, out of combat and in combat.
*   Health bar of your target and power bar of yourself, as bars, progress textures or a `%p / %t` text.
*   Show only below (%) on your energy.
*   Cast bar of your target.
*   Swing timer, main hand.
*   Range Check trigger.
*   Your own casts (`UNIT_SPELLCAST_SUCCEEDED:player`) and `PLAYER_TARGET_DIED`.

<span style="color:#4caf50"><strong>✔ Tested in game</strong></span>

*   Temporary weapon enchants, Elapsed Time filter, Bag Space, Role, Secret Restrictions Active load condition, `/wa cdm`.

<span style="color:#ff9800"><strong>⚠ Works, with limits</strong></span>

*   With the classic Aura trigger, buffs and debuffs are hidden in combat: stacks stay frozen, and a buff applied for the first time in combat only shows when combat ends. Use Aura (Modern) for combat.
*   Aura (Modern) needs the spell ID of the aura itself, which can differ from the spell you cast.
*   Conditions on percentages, stacks or remaining time use the value from before combat.
*   Show only below (%) uses a percent of the maximum, and replaces the alpha of the aura.
*   Nameplate anchoring only works with the default Blizzard nameplates.

<span style="color:#f44336"><strong>✖ Does not work</strong></span>

*   Combat log triggers: the game forbids the combat log to addons.
*   Other players' casts, enemy names and IDs in instances.
*   The Native Filter of the Aura trigger shows nothing at the moment.

<span style="color:#9e9e9e"><em>Not tested in game yet: Cooldown Manager trigger, Hide when target changes, Totem trigger in combat, Equipment Durability, Tracking, Ammo, Instance Type, off hand and ranged swing timer, dispel type colors, dungeons and raids.</em></span>

***

## <span style="color:#0cf">📦 Installation</span>

Install with the CurseForge app, or copy the five folders `WeakAuras`, `WeakAurasArchive`, `WeakAurasModelPaths`, `WeakAurasOptions` and `WeakAurasTemplates` into `World of Warcraft/_classic_beta_/Interface/AddOns/`.

<span style="color:#f44336"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

`/wa` is also used by ForeverAuras: disable ForeverAuras, or type `/weakauras`.

***

## <span style="color:#0cf">🐞 Support</span>

Found a bug, or an aura that should work and does not? [Open an issue on GitHub](https://github.com/dldvlpr-addons-wow/Musca-Auras/issues).

Discord: coming soon.

***

## <span style="color:#0cf">⚖ License and credits</span>

*   **Musca Auras** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/LICENSE). Changes © 2026 dldvlpr, same license. This project is not affiliated with, nor endorsed by, the WeakAuras Team.
*   Portions derived from ForeverAuras (m33shoq, GPL v2), see CHANGES.md.
*   **Specialization and spell rank data** come from talentsforever.com, under CC-BY 4.0.
*   **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`: Ace3 (AceComm, AceSerializer, AceTimer, CallbackHandler, LibStub), Archivist, Chomp, LibCompress, LibCustomGlow, LibDBIcon, LibDataBroker, LibDeflate, LibDispel, LibGetFrame, LibRangeCheck, LibSerialize, LibSharedMedia, LibSpecialization, LibSpellRange, TaintLess.
*   **Source code and change list:** every modified file, with the date and the nature of the change, is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/Musca-Auras](https://github.com/dldvlpr-addons-wow/Musca-Auras).
*   **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
*   World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc. This addon is a fan project, not affiliated with Blizzard.

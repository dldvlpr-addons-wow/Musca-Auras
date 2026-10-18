<h1 style="text-align: center;"><span style="color: #0cf;">Musca</span> <span style="color: #ffd100;">Auras</span></h1>

<p style="text-align: center;"><strong>The WeakAuras you know, with a ready-made HUD for your class in one click, that keeps working in combat on WoW Forever.</strong></p>

<p style="text-align: center;"><a href="https://discord.gg/EyYpyMq2km"><strong>💬 Discord</strong></a> · <a href="https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/GUIDE.md"><strong>📖 Guide</strong></a> · <a href="https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"><strong>🐞 Report a bug</strong></a></p>

---

## <span style="color: #ff6b35;">🎮 Your class HUD, ready to play</span>

One click imports a complete set of auras for your class: buffs to keep up, procs, cooldowns, a resource bar and timer bars, already placed on your screen.

<p style="text-align: center;"><strong><span style="color: #FF7C0A;">Druid</span> · <span style="color: #AAD372;">Hunter</span> · <span style="color: #3FC7EB;">Mage</span> · <span style="color: #F48CBA;">Paladin</span> · <span style="color: #FFFFFF;">Priest</span> · <span style="color: #FFF468;">Rogue</span> · <span style="color: #0070DD;">Shaman</span> · <span style="color: #8788EE;">Warlock</span> · <span style="color: #C69B6D;">Warrior</span></strong></p>

---

## <span style="color: #0cf;">🚀 Quick start</span>

1. **Install** Musca Auras and start the game.
2. On the welcome popup, click <span style="color: #ffd100;"><strong>Install &lt;your class&gt; HUD</strong></span>. Missed it? Type <span style="color: #ffd100;"><strong>/wa</strong></span> and click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel.
3. **Make it yours:** type <span style="color: #ffd100;"><strong>/wa</strong></span> to move, resize or change any aura. New to auras? Click <span style="color: #ffd100;"><strong>Guide</strong></span> at the top of the `/wa` window.

<span style="color: #f44336;"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

---

## <span style="color: #0cf;">⚡ Why Musca Auras?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **Musca Auras** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1).

| | Regular WeakAuras | Musca Auras |
|---|:---:|:---:|
| Buffs, debuffs, cooldowns, health and power keep updating in combat | ✖ | ✔ |
| No flood of Lua errors in combat | ✖ | ✔ |
| Ready-made HUD for all nine classes | ✖ | ✔ |
| Import check that warns about auras that cannot work on WoW Forever | ✖ | ✔ |

---

## <span style="color: #0cf;">🧰 What you get</span>

- <span style="color: #ffd100;"><strong>Low health and low resource alerts in combat,</strong></span> for example an icon when you have 80 energy or more.
- <span style="color: #ffd100;"><strong>Colors that react in combat:</strong></span> interruptible casts, spells out of range, not enough mana or rage, a timer about to run out.
- <span style="color: #ffd100;"><strong>Damage over time timers from your own casts,</strong></span> with no code to write.
- <span style="color: #ffd100;"><strong>Type spells by name,</strong></span> in your game language: every rank of the spell is tracked.

---

## <span style="color: #3c3;">🆕 New in the last releases (1.10 and 1.11)</span>

- <span style="color: #ffd100;"><strong>Health and power conditions in combat:</strong></span> Health (%), Power (%) and their siblings change alpha, color and desaturate even when the game hides the value. On an enemy, the % conditions work.
- <span style="color: #ffd100;"><strong>Trigger Expression:</strong></span> combine triggers with an expression such as `1 and (2 or not 3)`, no code needed.
- <span style="color: #ffd100;"><strong>Copy and paste a single trigger or condition,</strong></span> and pick which child auras to import from a group.
- <span style="color: #ffd100;"><strong>Your auras are safe:</strong></span> a daily backup (`/wa backups`, `/wa restore`), and every deleted aura kept for 30 days (`/wa deleted`, `/wa undelete`).
- <span style="color: #ffd100;"><strong>Find what costs CPU:</strong></span> after a profiling, each aura shows a badge colored by its cost, and an Unused Auras button cleans up what no character loads.
- <span style="color: #ffd100;"><strong>Class packs:</strong></span> a "Not in melee range" text for melee specs, reminders that pulse, and a mana bar that turns red under 30 %.

Full list in the **Files** tab.

---

## <span style="color: #0cf;">🎯 Limits</span>

### <span style="color: #ff9800;">⚠ Works, with limits</span>

- Buffs and debuffs move in combat only with the **Aura (Modern)** trigger, used by default for new auras. The classic Aura trigger freezes in combat.
- In combat, conditions only change transparency, color, grey-out, text and the visibility of sub elements.

### <span style="color: #f44336;">✖ Does not work</span>

- Combat log triggers never fire: the game forbids the combat log to addons.
- Other players' casts, enemy names and IDs in instances are hidden.

---

## <span style="color: #0cf;">🌐 Auras made elsewhere</span>

- <span style="color: #4caf50;"><strong>Auras from Wago or the regular WeakAuras import the usual way.</strong></span> <span style="color: #ff9800;"><strong>Those that rely on the combat log need to be updated.</strong></span>
- <span style="color: #4caf50;"><strong>Coming from ForeverAuras?</strong></span> Its Aura (Modern) and Cooldown Manager auras import as they are.
- Some removed functions (`GetSpellInfo`, `UnitBuff`…) are replaced in custom code, but `UnitAura`, `UnitBuff` and `UnitDebuff` stop in combat on a hidden aura. Auras that call other removed functions need to be updated: the import report tells you which ones.

---

## <span style="color: #ff6b35;">🔄 Updating from an older version</span>

Install the latest version, then click <span style="color: #ffd100;"><strong>Update &lt;your class&gt; HUD</strong></span> in the message shown at login, or <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel. Your positions and options are kept.

- <span style="color: #3c3;"><strong>Your own auras are kept.</strong></span> The saved data format did not change.
- <span style="color: #ffd100;"><strong>Skipped a version?</strong></span> Read the [changelog](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/WeakAuras/CHANGELOG.md) of each version you skipped, its After the update steps first.
- <span style="color: #ffd100;"><strong>Lua errors, or an aura no longer behaves as before?</strong></span> Install the previous version again from the **Files** tab, and report it on Discord, GitHub or CurseForge with the text of the error.

---

## <span style="color: #0cf;">⚖ License and credits</span>

- **Musca Auras** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/LICENSE). Changes © 2026 dldvlpr, same license.
- It also includes code from [M33kAuras](https://github.com/m33shoq/M33kAuras) by m33shoq and from [ForeverAuras](https://github.com/neroxrw/foreverauras) by Neroxrw, both under the GPL v2.
- **Specialization and spell rank data** come from talentsforever.com, under CC-BY 4.0.
- **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`.
- **Source code and change list:** every modified file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/Musca-Auras](https://github.com/dldvlpr-addons-wow/Musca-Auras).
- **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
- Not affiliated with or endorsed by The WeakAuras Team, m33shoq, Neroxrw or Blizzard Entertainment. World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc.

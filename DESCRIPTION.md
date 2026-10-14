<h1 style="text-align: center;"><span style="color: #0cf;">Musca</span> <span style="color: #ffd100;">Auras</span></h1>

<p style="text-align: center;"><strong>A ready-made combat HUD for your class in one click, that keeps working in combat on WoW Forever.</strong></p>

<p style="text-align: center;">The WeakAuras you know, rebuilt for the modern engine of WoW Forever.</p>

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

---

## <span style="color: #0cf;">⚡ Why Musca Auras?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **Musca Auras** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1).

| | Regular WeakAuras | Musca Auras |
|---|:---:|:---:|
| Buffs, debuffs and cooldowns keep ticking in combat | ✖ | ✔ |
| No flood of Lua errors in combat | ✖ | ✔ |
| Ready-made HUD for all nine classes | ✖ | ✔ |
| Import check that warns about auras that cannot work on WoW Forever | ✖ | ✔ |
| Your saved auras and `/wa` | ✔ | ✔ |

<span style="color: #ffd100;"><strong>Coming from ForeverAuras?</strong></span> Its Aura (Modern) and Cooldown Manager auras import as they are.

---

## <span style="color: #0cf;">🧰 What you get</span>

- <span style="color: #ffd100;"><strong>Timers that keep moving in combat.</strong></span> The game itself draws cooldown swipes, timer bars, health and power bars and texts, even when it hides the numbers from addons.
- <span style="color: #ffd100;"><strong>Buffs and debuffs on screen, on your unit frames or on nameplates,</strong></span> with duration and stacks updated in combat.
- <span style="color: #ffd100;"><strong>Low health and low resource alerts in combat,</strong></span> for example an icon when you have 80 energy or more.
- <span style="color: #ffd100;"><strong>Colors that react in combat:</strong></span> interruptible casts, spells out of range, not enough mana or rage, a timer about to run out.
- <span style="color: #ffd100;"><strong>Damage over time timers from your own casts,</strong></span> with no code to write.
- <span style="color: #ffd100;"><strong>Type spells by name,</strong></span> in your game language: every rank of the spell is tracked.
- <span style="color: #ffd100;"><strong>In-game guide:</strong></span> click <span style="color: #ffd100;"><strong>Guide</strong></span> at the top of the `/wa` window, or type `/wa tutorial`.

---

## <span style="color: #3c3;">🆕 New in 1.9.1</span>

- <span style="color: #ffd100;"><strong>Cleaner class packs:</strong></span> no timer numbers on the icons, a grey swipe instead, and a red pulse in the last 3 seconds.
- <span style="color: #ffd100;"><strong>More spells in every class pack,</strong></span> each shown once it is learned.
- <span style="color: #ffd100;"><strong>No more freezes</strong></span> when importing, deleting or selecting auras with glows.

Full list in the **Files** tab.

---

## <span style="color: #0cf;">🎯 Limits</span>

### <span style="color: #ff9800;">⚠ Works, with limits</span>

- Buffs and debuffs move in combat only with the **Aura (Modern)** trigger, used by default for new auras. The classic Aura trigger freezes in combat.
- In combat, conditions only change transparency, color and grey-out.

### <span style="color: #f44336;">✖ Does not work</span>

- Combat log triggers never fire: the game forbids the combat log to addons.
- Other players' casts, enemy names and IDs in instances are hidden.

---

## <span style="color: #0cf;">🌐 Auras made elsewhere</span>

<span style="color: #4caf50;"><strong>Auras from Wago or the regular WeakAuras import the usual way.</strong></span> <span style="color: #ff9800;"><strong>Those that rely on the combat log or on removed functions (`GetSpellInfo`, `UnitBuff`…) need to be updated:</strong></span> the import report tells you which ones.

<span style="color: #f44336;"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

---

## <span style="color: #ff6b35;">🔄 Updating from an older version</span>

1. Install **1.9.1**, then click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel to update your HUD. Coming from **1.8.1** or older? **Restart the game**: the new logo is not loaded by a <span style="color: #ffd100;"><strong>/reload</strong></span>
2. Coming from **1.8.0** or older? Open <span style="color: #ffd100;"><strong>/wa</strong></span>, **delete** the <span style="color: #ffd100;"><strong>&lt;Class&gt; (Musca)</strong></span> group, then click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel. Aura ids changed once in 1.8.1.

- <span style="color: #3c3;"><strong>Your own auras are kept.</strong></span> The saved data format did not change. An aura that used the removed Energy Tick trigger becomes a Health trigger: delete it.
- <span style="color: #ffd100;"><strong>Lua errors, or an aura no longer behaves as in 1.9.0?</strong></span> Install **1.9.0** again from the **Files** tab, and report it on Discord, GitHub or CurseForge with the text of the error.

---

## <span style="color: #0cf;">🐞 Support</span>

<span style="color: #ffd100;"><strong>Found a bug?</strong></span> [Open an issue on GitHub](https://github.com/dldvlpr-addons-wow/Musca-Auras/issues).

<span style="color: #ffd100;"><strong>Questions, ideas, news?</strong></span> [Join the Musca Auras Discord](https://discord.gg/EyYpyMq2km).

---

## <span style="color: #0cf;">⚖ License and credits</span>

- **Musca Auras** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/LICENSE). Changes © 2026 dldvlpr, same license.
- It also includes code from [M33kAuras](https://github.com/m33shoq/M33kAuras) by m33shoq and from [ForeverAuras](https://github.com/neroxrw/foreverauras) by Neroxrw, both under the GPL v2.
- **Specialization and spell rank data** come from talentsforever.com, under CC-BY 4.0.
- **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`.
- **Source code and change list:** every modified file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/Musca-Auras](https://github.com/dldvlpr-addons-wow/Musca-Auras).
- **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
- Not affiliated with or endorsed by The WeakAuras Team, m33shoq, Neroxrw or Blizzard Entertainment. World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc.

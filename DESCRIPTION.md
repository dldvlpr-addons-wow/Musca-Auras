<h1 style="text-align: center;"><span style="color: #0cf;">Musca</span> <span style="color: #ffd100;">Auras</span></h1>

<p style="text-align: center;"><strong>The WeakAuras you know, rebuilt for WoW Forever.</strong></p>

<p style="text-align: center;">Icons, bars, texts and timers that keep working on the modern engine, even in combat.</p>

---

## <span style="color: #ff6b35;">🔄 Update to 1.9.0</span>

1. Install **1.9.0**, then **restart the game**: the new logo is not loaded by a <span style="color: #ffd100;"><strong>/reload</strong></span>
2. Coming from **1.8.0** or older? Open <span style="color: #ffd100;"><strong>/wa</strong></span>, **delete** the <span style="color: #ffd100;"><strong>&lt;Class&gt; (Musca)</strong></span> group, then click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel. Aura ids changed once in 1.8.1.

- <span style="color: #3c3;"><strong>Your own auras are kept.</strong></span> The saved data format did not change.
- <span style="color: #ffd100;"><strong>Lua errors, or an aura no longer behaves as in 1.8.1?</strong></span> Install **1.8.1** again from the **Files** tab, and report it on Discord, GitHub or CurseForge with the text of the error.

---

## <span style="color: #ff6b35;">🆕 NEW: a full UI pack for your class</span>

Open `/wa`, click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel, and the ready-made auras of your class are imported in one click. Available for all nine classes: Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock and Warrior.

### <span style="color: #3c3;">New in 1.9.0</span>

- <span style="color: #ffd100;"><strong>Spells by name:</strong></span> type a spell name in the spell lists of an Aura (Modern) trigger, it becomes the IDs of all its ranks.
- <span style="color: #ffd100;"><strong>Install HUD button:</strong></span> the first login popup opens the Class Pack import of your class.
- <span style="color: #ffd100;"><strong>Import report:</strong></span> before an import, each aura that uses the combat log, values hidden in combat or functions missing from WoW Forever is listed, with the fix when there is one.
- <span style="color: #ffd100;"><strong>Custom code errors shown:</strong></span> a custom code that fails shows "Error in custom code" on the aura instead of failing silently.
- <span style="color: #ffd100;"><strong>Aura (Modern) by default:</strong></span> a new Icon, Progress Bar, Progress Texture or Text aura starts with an Aura (Modern) trigger.
- <span style="color: #ffd100;"><strong>Discord:</strong></span> the Discord button of the `/wa` window gives the invite link: https://discord.gg/EyYpyMq2km.

### <span style="color: #3c3;">Fixed in 1.9.0</span>

- <span style="color: #ffd100;"><strong>Fewer Lua errors in combat:</strong></span> range, group role, weapon enchant and cooldown swipe checks skip the values the game hides.
- <span style="color: #ffd100;"><strong>Safer custom code:</strong></span> custom code can no longer quit the game, manage the guild or read the debug library.

---

## <span style="color: #0cf;">⚡ What is it?</span>

WoW Forever looks like Classic, but it runs on the **modern game engine**. That engine hides most combat data from addons, and the regular WeakAuras breaks. **Musca Auras** is WeakAuras 5.22.0 ported to WoW Forever (client 1.60.1):

- <span style="color: #ffd100;"><strong>Same addon, same habits.</strong></span> `/wa` opens the options, and your saved auras load as they are.
- <span style="color: #ffd100;"><strong>No Lua error storm in combat.</strong></span> When the game hides a value, the aura keeps its last state and updates when the data is readable again.
- <span style="color: #ffd100;"><strong>The game draws what addons cannot read.</strong></span> Cooldown swipes, timer bars, health and power bars, texts, buffs and debuffs keep moving in combat.

---

## <span style="color: #0cf;">🧰 Built for WoW Forever</span>

- <span style="color: #ffd100;"><strong>Aura (Modern) trigger and Modern Aura Group:</strong></span> buffs and debuffs drawn by the game itself, duration and stacks keep moving in combat, on the screen, the unit frames or the nameplates.
- <span style="color: #ffd100;"><strong>Blizzard Cooldown Manager trigger:</strong></span> cooldowns, buffs and debuffs with swipe, bar and `%p` text that keep the aura timing in combat.
- <span style="color: #ffd100;"><strong>Health and Power alerts in combat:</strong></span> Show only below (%), for example an icon at 80 energy or more.
- <span style="color: #ffd100;"><strong>Conditions in combat:</strong></span> Interruptible, Spell Usable, Insufficient Resources, Spell in Range and remaining time.
- <span style="color: #ffd100;"><strong>DoT timers from your own cast,</strong></span> with no custom code.
- <span style="color: #ffd100;"><strong>In-game guide:</strong></span> click <span style="color: #ffd100;"><strong>Guide</strong></span> at the top of the `/wa` window, or type `/wa tutorial`.

---

## <span style="color: #0cf;">🎯 Limits</span>

### <span style="color: #ff9800;">⚠ Works, with limits</span>

- With the classic Aura trigger, buffs and debuffs are frozen in combat. Use Aura (Modern).
- In combat, conditions only change alpha, color and desaturation.
- Aura (Modern) spell lists take a spell ID or a spell name: a name is replaced by the IDs of all its ranks.

### <span style="color: #f44336;">✖ Does not work</span>

- Combat log triggers never fire: the game forbids the combat log to addons.
- Other players' casts, enemy names and IDs in instances are hidden.

---

## <span style="color: #0cf;">🌐 Auras made elsewhere</span>

<span style="color: #4caf50;"><strong>Auras from Wago or the regular WeakAuras import the usual way.</strong></span> <span style="color: #ff9800;"><strong>Those that rely on the combat log or on removed functions (`GetSpellInfo`, `UnitBuff`…) need to be updated.</strong></span>

<span style="color: #f44336;"><strong>Do not install it next to another WeakAuras build.</strong></span> The folder name and the saved settings are the same, on purpose, so your existing auras keep working.

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

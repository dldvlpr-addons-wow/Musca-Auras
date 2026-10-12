<h1 style="text-align: center;"><span style="color: #0cf;">Musca</span> <span style="color: #ffd100;">Auras</span></h1>

**The WeakAuras you know, rebuilt for WoW Forever.**

Icons, bars, texts and timers that keep working on the modern engine, even in combat.

---

## <span style="color: #ff6b35;">🆕 NEW: a full UI pack for your class</span>

Open `/wa`, click <span style="color: #ffd100;"><strong>Class Pack</strong></span> at the top of the New Aura panel, and the ready-made auras of your class are imported in one click. Available for all nine classes: Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock and Warrior.

### <span style="color: #3c3;">Also in 1.8.0</span>

- <span style="color: #ffd100;"><strong>Energy Tick trigger:</strong></span> a bar to the next 2 second energy tick.
- <span style="color: #ffd100;"><strong>Smoother frame rate:</strong></span> no more drop after opening `/wa` and clicking an aura.
- <span style="color: #ffd100;"><strong>Glows and anchors:</strong></span> glow conditions on elapsed time work, and an aura anchored to another aura follows its target, in combat too.

---

## <span style="color: #ff6b35;">⚠️ Heads-up: 1.8.0</span>

- <span style="color: #ffd100;"><strong>Restart the game after the update:</strong></span> a new file is not loaded by a `/reload`.
- <span style="color: #3c3;"><strong>Your auras are kept.</strong></span> The saved data format did not change.
- <span style="color: #ffd100;"><strong>Lua errors, or an aura no longer behaves as in 1.7.1?</strong></span> Install **1.7.1** again from the **Files** tab, and report it on GitHub or CurseForge with the text of the error.

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
- Spells must be entered by ID: every rank has its own ID.

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

---

## <span style="color: #0cf;">⚖ License and credits</span>

- **Musca Auras** is a modified version of [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), © The WeakAuras Team, released under the [GNU General Public License v2](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/LICENSE). Changes © 2026 dldvlpr, same license.
- It also includes code from [M33kAuras](https://github.com/m33shoq/M33kAuras) by m33shoq and from [ForeverAuras](https://github.com/neroxrw/foreverauras) by Neroxrw, both under the GPL v2.
- **Specialization and spell rank data** come from talentsforever.com, under CC-BY 4.0.
- **Bundled libraries** keep their own licenses, included in their folders under `WeakAuras/Libs/`.
- **Source code and change list:** every modified file is listed in [CHANGES.md](https://github.com/dldvlpr-addons-wow/Musca-Auras/blob/main/CHANGES.md), as required by the GPL v2 section 2a. Full source: [github.com/dldvlpr-addons-wow/Musca-Auras](https://github.com/dldvlpr-addons-wow/Musca-Auras).
- **No warranty.** This addon is provided as is, without warranty of any kind, as stated in the GPL v2.
- Not affiliated with or endorsed by The WeakAuras Team, m33shoq, Neroxrw or Blizzard Entertainment. World of Warcraft and WoW Forever are trademarks of Blizzard Entertainment, Inc.

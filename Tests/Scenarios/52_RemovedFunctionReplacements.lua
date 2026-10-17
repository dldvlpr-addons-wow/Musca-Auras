return function(test)
  AuraUtil = AuraUtil or {}
  AuraUtil.UnpackAuraData = function(auraData)
    return auraData.name, auraData.icon, auraData.applications, auraData.dispelName, auraData.duration,
      auraData.expirationTime, auraData.sourceUnit, auraData.isStealable, auraData.nameplateShowPersonal,
      auraData.spellId, auraData.canApplyAura, auraData.isBossAura, auraData.isFromPlayerOrPlayerPet,
      auraData.nameplateShowAll, auraData.timeMod
  end
  C_Spell = C_Spell or {}
  C_Spell.GetSpellInfo = function(spell)
    if spell == 6673 then
      return { name = "Battle Shout", iconID = 132333, originalIconID = 132334, castTime = 0, minRange = 0,
               maxRange = 5, spellID = 6673 }
    end
  end
  C_Spell.GetSpellTexture = function(spell) if spell == 6673 then return 132333, 132334 end end
  C_Spell.IsSpellUsable = function(spell) return spell == 6673, spell ~= 6673 end
  C_Spell.GetSpellCooldown = function(spell)
    if spell == 6673 then return { startTime = 100, duration = 8, isEnabled = true, modRate = 1 } end
    if spell == 2565 then return { startTime = 0, duration = 0, isEnabled = false, modRate = 1 } end
  end
  C_Spell.GetSpellCharges = function(spell)
    if spell == 100 then
      return { currentCharges = 1, maxCharges = 2, cooldownStartTime = 50, cooldownDuration = 20, chargeModRate = 1 }
    end
  end
  GetSpellTexture = nil
  IsUsableSpell = nil

  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local function Run(code)
    local func = WeakAuras.LoadFunction("return function() " .. code .. " end", "removed-functions")
    assert(func, "custom code not compiled: " .. code)
    return { func() }
  end
  local function Same(actual, expected, label)
    for index = 1, math.max(#expected, #actual) do
      assert(actual[index] == expected[index],
        ("%s: return %d is %s, expected %s"):format(label, index, tostring(actual[index]), tostring(expected[index])))
    end
  end

  test.Units.ApplyAura("player", { name = "Battle Shout", spellId = 6673, icon = 132333, applications = 0,
    duration = 120, sourceUnit = "player", isHelpful = true })
  test.Units.ApplyAura("player", { name = "Weakened Soul", spellId = 6788, icon = 135871, applications = 0,
    dispelName = "Magic", duration = 15, sourceUnit = "player", isHarmful = true })

  local function FirstTen(values) return { unpack(values, 1, 10) } end
  local buffExpiration = C_UnitAuras.GetBuffDataByIndex("player", 1).expirationTime
  local debuffExpiration = C_UnitAuras.GetDebuffDataByIndex("player", 1).expirationTime
  Same(FirstTen(Run("return UnitBuff('player', 1)")),
    { "Battle Shout", 132333, 0, nil, 120, buffExpiration, "player", false, false, 6673 }, "UnitBuff")
  Same(FirstTen(Run("return UnitDebuff('player', 1)")),
    { "Weakened Soul", 135871, 0, "Magic", 15, debuffExpiration, "player", false, false, 6788 }, "UnitDebuff")
  Same(FirstTen(Run("return UnitAura('player', 1, 'HARMFUL')")),
    { "Weakened Soul", 135871, 0, "Magic", 15, debuffExpiration, "player", false, false, 6788 }, "UnitAura")
  Same(Run("return UnitBuff('player', 2)"), {}, "UnitBuff past the last aura")
  test.Units.ApplyAura("player", { name = "Power Word: Fortitude", spellId = 1243, duration = 1800,
    sourceUnit = "party1", isHelpful = true })
  test.Units.ApplyAura("player", { name = "Rend", spellId = 772, duration = 9, sourceUnit = "target", isHarmful = true })
  assert(Run("return UnitBuff('player', 2)")[1] == "Power Word: Fortitude", "UnitBuff second buff")
  Same(Run("return UnitBuff('player', 2, 'PLAYER')"), {}, "UnitBuff filter")
  assert(Run("return UnitDebuff('player', 2)")[1] == "Rend", "UnitDebuff second debuff")
  Same(Run("return UnitDebuff('player', 2, 'PLAYER')"), {}, "UnitDebuff filter")
  Same(Run("return GetSpellInfo(6673, 'spell')"), {}, "GetSpellInfo with a spell book slot")
  Same(Run("return GetSpellTexture(6673, 'spell')"), {}, "GetSpellTexture with a spell book slot")
  Same(Run("return IsUsableSpell(6673, 'spell')"), {}, "IsUsableSpell with a spell book slot")
  Same(Run("return GetSpellCooldown(6673, 'spell')"), {}, "GetSpellCooldown with a spell book slot")

  Same(Run("return GetSpellInfo(6673)"), { "Battle Shout", nil, 132333, 0, 0, 5, 6673, 132334 }, "GetSpellInfo")
  Same(Run("return GetSpellInfo(1)"), {}, "GetSpellInfo unknown spell")
  Same(Run("return GetSpellTexture(6673)"), { 132333, 132334 }, "GetSpellTexture")
  Same(Run("return IsUsableSpell(6673)"), { true, false }, "IsUsableSpell")
  Same(Run("return GetSpellCooldown(6673)"), { 100, 8, 1, 1 }, "GetSpellCooldown")
  Same(Run("return GetSpellCooldown(2565)"), { 0, 0, 0, 1 }, "GetSpellCooldown disabled")
  Same(Run("return GetSpellCooldown(nil)"), {}, "GetSpellCooldown without spell")
  Same(Run("return GetSpellCharges(100)"), { 1, 2, 50, 20, 1 }, "GetSpellCharges")
  Same(Run("return GetSpellCharges(1)"), {}, "GetSpellCharges without charges")

  assert(private.HasRemovedFunctionReplacement("UnitBuff"), "UnitBuff not reported as replaced")
  assert(not private.HasRemovedFunctionReplacement("GetTalentInfo"), "GetTalentInfo reported as replaced")

  local gameFunction = function() return "game" end
  UnitBuff = gameFunction
  Same(Run("return UnitBuff('player', 1)"), { "game" }, "UnitBuff defined by the game")
  assert(not private.HasRemovedFunctionReplacement("UnitBuff"), "UnitBuff reported as replaced while defined")
  UnitBuff = nil
end

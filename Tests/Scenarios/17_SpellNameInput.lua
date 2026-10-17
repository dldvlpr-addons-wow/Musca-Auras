-- SpellNameInput: a spell name typed in an Aura (Modern) spell list becomes the IDs of all its ranks.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local names = { [8050] = "Flame Shock", [11366] = "Pyroblast" }
  private.ExecEnv.GetSpellName = function(id) return names[id] end
  local realIdentifier = C_Spell.GetSpellIDForSpellIdentifier
  C_Spell.GetSpellIDForSpellIdentifier = function(name)
    if name == "Lightning Shield Totem" then return 999001 end
  end

  local buildOptions
  local realRegister = WeakAuras.RegisterTriggerSystemOptions
  WeakAuras.RegisterTriggerSystemOptions = function(_, builder) buildOptions = builder end
  local optionsPrivate = {
    commonOptions = { AddCommonTriggerOptions = function() end },
    AuraEditor = { AddOptions = function() end },
    AddTriggerMetaFunctions = function() end,
    SaveAuraTrigger = function() end,
    QueueOptionsRefresh = function() end,
    CreateAuraSpellOptions = function(options, data, triggernum, size, _, _, prefix, _, _, optionKey)
      local trigger = data.triggers[triggernum].trigger
      for i = 1, size do
        options[prefix .. i] = {
          set = function(_, value)
            trigger[optionKey] = trigger[optionKey] or {}
            trigger[optionKey][i] = value
          end,
        }
      end
    end,
  }
  local ok, message = test.Loader.RunFile(test.tocPath:gsub("WeakAuras/WeakAuras.toc$", "WeakAurasOptions/SecretAuraTriggerOptions.lua"), "WeakAurasOptions", optionsPrivate)
  -- In game, WeakAuras.ToggleOptions sets Private only after the options addon has loaded.
  optionsPrivate.Private = private
  WeakAuras.RegisterTriggerSystemOptions = realRegister
  assert(ok, tostring(message))
  assert(buildOptions, "secretAura options not registered")

  local function Options(trigger)
    local data = { id = "Test", triggers = { { trigger = trigger } } }
    return buildOptions(data, 1)["trigger.1.secretAura"]
  end

  local trigger = { type = "secretAura", unit = "player" }
  local options = Options(trigger)
  local rankInput = options.rankspellid1
  assert(rankInput.validate(nil, "flame shock") == true, "known name refused")
  assert(rankInput.validate(nil, "8050") == true, "spell ID refused")
  assert(type(rankInput.validate(nil, "Not A Spell")) == "string", "unknown name accepted")
  assert(type(rankInput.validate(nil, "-3")) == "string", "negative ID accepted")

  rankInput.set(nil, "Flame Shock")
  local ids = table.concat(trigger.auraRankSpellIDs, ",")
  assert(ids == "8050,8052,8053,10447,10448,29228", "Flame Shock ranks: " .. ids)

  rankInput = Options(trigger).rankspellid7
  rankInput.set(nil, "PYROBLAST")
  ids = table.concat(trigger.auraRankSpellIDs, ",")
  assert(ids == "8050,8052,8053,10447,10448,29228,11366,12505,12522,12523,12524,12525,12526,18809", "Pyroblast appended: " .. ids)

  Options(trigger).rankspellid1.set(nil, "Flame Shock")
  assert(#trigger.auraRankSpellIDs == 14, "duplicate ranks added: " .. #trigger.auraRankSpellIDs)

  local partial = { type = "secretAura", unit = "player", auraRankSpellIDs = { "8050" } }
  Options(partial).rankspellid2.set(nil, " flame shock ")
  ids = table.concat(partial.auraRankSpellIDs, ",")
  assert(ids == "8050,8052,8053,10447,10448,29228", "first rank already listed: " .. ids)

  local imported = { type = "secretAura", unit = "player", auraspellids = { "Flame Shock" } }
  Options(imported).spellid2.set(nil, "Pyroblast")
  assert(imported.auraspellids[2] == "11366", "non numeric entry in list")

  local exact = { type = "secretAura", unit = "player" }
  Options(exact).spellid1.set(nil, "Lightning Shield Totem")
  assert(exact.auraspellids[1] == "999001" and #exact.auraspellids == 1, "learned spell fallback")
  Options(exact).spellid2.set(nil, "12345")
  assert(exact.auraspellids[2] == "12345", "spell ID stored as typed")

  C_Spell.GetSpellIDForSpellIdentifier = realIdentifier
end

-- Every secret aura of the class packs passes the native checks: an invalid condition (two timed glows,
-- a property the native display cannot drive) turns the aura off in game. A timed glow without a positive number
-- of seconds is ignored silently, so it is checked here.
local classes = { "Chaman", "Chasseur", "Demoniste", "Druide", "Essai", "Guerrier", "Mage", "Paladin", "Pretre", "Voleur" }

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  local Display = private.BlizzardAuraDisplay
  local problems, checked = {}, 0
  for _, class in ipairs(classes) do
    local pack = dofile("Tests/Packs/" .. class .. "/Pack" .. class .. ".lua")
    for _, child in ipairs(pack.c) do
      local trigger = child.triggers[1].trigger
      if trigger.type == "secretAura" then
        checked = checked + 1
        local problem = Display.ValidateSingle(child, trigger) or Display.ValidateConditions(child)
        for _, condition in ipairs(child.conditions) do
          local variable, seconds = condition.check.variable, tonumber(condition.check.value)
          if (variable == "faAuraElapsed" or variable == "faAuraRemaining") and not (seconds and seconds > 0) then
            problem = problem or (variable .. " without a positive number of seconds")
          end
        end
        if problem then problems[#problems + 1] = child.id .. ": " .. problem end
      end
    end
  end
  assert(checked > 0, "no secret aura checked")
  assert(#problems == 0, #problems .. " pack aura(s) rejected:\n" .. table.concat(problems, "\n"))
end

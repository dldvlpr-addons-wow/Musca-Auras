-- A secret value or total is shown with the number format chosen in the options.
-- A format that needs to read the number (time) keeps the raw value.
return function(test)
  local Secret = test.Secret
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)

  local function Abbreviate(value)
    return Secret.IsSecret(value) and Secret.Wrap(Secret.Reveal(value) .. "K") or value .. "K"
  end
  _G.AbbreviateNumbers, _G.AbbreviateLargeNumbers = Abbreviate, Abbreviate

  local function Show(text, options, secretValue, secretTotal)
    local formatters = private.CreateFormatters(text, function(key, default)
      local value = options[key]
      if value == nil then return default end
      return value
    end, false, { triggers = {} })
    local shown
    local holder = { text = { SetText = function(_, value) shown = value end } }
    local parent = { state = { progressType = "static" }, secretValue = secretValue, secretTotal = secretTotal }
    assert(private.UpdateNativeText(holder, parent, text, formatters), text .. " not painted natively")
    return Secret.Reveal(shown)
  end

  local secret = Secret.Wrap(1200)
  local same = function(got, want, message) assert(got == want, message .. ": " .. tostring(got)) end
  same(Show("%value", { value_format = "BigNumber" }, secret), "1200K", "AbbreviateNumbers on a secret value")
  same(Show("%value", { value_format = "BigNumber", value_big_number_format = "AbbreviateLargeNumbers" }, secret),
    "1200K", "AbbreviateLargeNumbers does not round a secret")
  same(Show("%value / %total", { value_format = "BigNumber", total_format = "BigNumber" }, secret, Secret.Wrap(5000)),
    "1200K / 5000K", "value and total")
  same(Show("%value", {}, secret), "1200", "no format")
  same(Show("%p", {}, secret), "1200", "time format keeps the raw value")
  same(Show("%value", { value_format = "BigNumber", value_pad = true }, secret), "1200K", "no pad on a secret")
end

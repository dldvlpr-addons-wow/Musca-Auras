-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local L = WeakAuras.L

-- The options builder lives in CDMDispel.lua, loaded just before this file.
OptionsPrivate.RegisterDispelSubRegionOptions({
  subRegion = "subcdmdispelborder",
  title = L["Dispel Type Border"],
  description = L["Shows a resizable border coloured by dispel type."],
  entries = {
    dispelVisible = { type = "toggle", name = L["Show Border"], order = 1 },
    dispelBorderSize = {
      type = "range", control = "WeakAurasSpinBox", name = L["Thickness"], order = 2,
      min = 1, max = 32, step = 1,
    },
    -- Soft bounds only: the spin box still accepts a typed value outside them.
    dispelBorderOffset = {
      type = "range", control = "WeakAurasSpinBox", name = L["Border Offset"], order = 3,
      softMin = -16, softMax = 32, step = 1,
    },
  },
})

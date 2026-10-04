if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local SUBTYPE = "subcdmdispelborder"

local function collectAnchors(parentData)
  local pointAnchors, areaAnchors = {}, {}
  local Private = OptionsPrivate.Private
  for child in Private.TraverseLeafsOrAura(parentData) do
    Mixin(pointAnchors, Private.GetAnchorsForData(child, "point"))
    Mixin(areaAnchors, Private.GetAnchorsForData(child, "area"))
  end
  return pointAnchors, areaAnchors
end

local function spinBox(label, order)
  return {
    type = "range",
    control = "WeakAurasSpinBox",
    name = label,
    order = order,
    step = 1,
    width = WeakAuras.normalWidth,
  }
end

local function createOptions(parentData, data, index, subIndex)
  local pointAnchors, areaAnchors = collectAnchors(parentData)

  local options = {}
  options.__title = "Dispel Type Border " .. subIndex
  options.__order = 1
  options.dispelVisible = {
    type = "toggle",
    name = "Show Border",
    order = 1,
    width = WeakAuras.normalWidth,
  }

  options.dispelBorderSize = spinBox("Thickness", 2)
  options.dispelBorderSize.min = 1
  options.dispelBorderSize.max = 32

  options.dispelBorderOffset = spinBox("Border Offset", 3)
  options.dispelBorderOffset.softMin = -16
  options.dispelBorderOffset.softMax = 32

  OptionsPrivate.commonOptions.PositionOptionsForSubElement(data, options, 10, areaAnchors, pointAnchors)
  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, SUBTYPE)
  return options
end

WeakAuras.RegisterSubRegionOptions(SUBTYPE, createOptions,
  "Shows a resizable border coloured by dispel type.")

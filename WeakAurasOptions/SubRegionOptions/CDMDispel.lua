if not WeakAuras.IsLibsOK() then return end
local _, OptionsPrivate = ...

local SUBTYPE = "subcdmdispel"

local function collectAnchors(parentData)
  local pointAnchors, areaAnchors = {}, {}
  local Private = OptionsPrivate.Private
  for child in Private.TraverseLeafsOrAura(parentData) do
    Mixin(pointAnchors, Private.GetAnchorsForData(child, "point"))
    Mixin(areaAnchors, Private.GetAnchorsForData(child, "area"))
  end
  return pointAnchors, areaAnchors
end

local function createOptions(parentData, data, index, subIndex)
  local pointAnchors, areaAnchors = collectAnchors(parentData)

  local options = {}
  options.__title = "CDM Dispel Type Icon " .. subIndex
  options.__order = 1
  options.dispelVisible = {
    type = "toggle",
    name = "Show Icon",
    order = 1,
    width = WeakAuras.normalWidth,
  }

  OptionsPrivate.commonOptions.PositionOptionsForSubElement(data, options, 10, areaAnchors, pointAnchors)
  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, SUBTYPE)
  return options
end

WeakAuras.RegisterSubRegionOptions(SUBTYPE, createOptions,
  "Shows the dispel type of a Cooldown Manager buff trigger.")

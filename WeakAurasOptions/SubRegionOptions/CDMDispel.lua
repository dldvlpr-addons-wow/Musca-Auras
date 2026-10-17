-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local AddonName, OptionsPrivate = ...

local L = WeakAuras.L

-- Shared by the dispel icon and the dispel border: both have their own entries, then the usual
-- position block (anchored to any child of the parent) and the move, delete and duplicate buttons.
function OptionsPrivate.RegisterDispelSubRegionOptions(layout)
  local function createOptions(parentData, data, index, subIndex)
    local Private = OptionsPrivate.Private
    local anchors = { point = {}, area = {} }
    for child in Private.TraverseLeafsOrAura(parentData) do
      for kind, collected in pairs(anchors) do
        Mixin(collected, Private.GetAnchorsForData(child, kind))
      end
    end

    local options = { __title = layout.title .. " " .. subIndex, __order = 1 }
    for key, entry in pairs(layout.entries) do
      local option = { width = WeakAuras.normalWidth }
      for field, value in pairs(entry) do option[field] = value end
      options[key] = option
    end
    OptionsPrivate.commonOptions.PositionOptionsForSubElement(data, options, 10, anchors.area, anchors.point)
    OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, layout.subRegion)
    return options
  end
  WeakAuras.RegisterSubRegionOptions(layout.subRegion, createOptions, layout.description)
end

OptionsPrivate.RegisterDispelSubRegionOptions({
  subRegion = "subcdmdispel",
  title = L["CDM Dispel Type Icon"],
  description = L["Shows the dispel type of a Cooldown Manager buff trigger."],
  entries = {
    dispelVisible = { type = "toggle", name = L["Show Icon"], order = 1 },
  },
})

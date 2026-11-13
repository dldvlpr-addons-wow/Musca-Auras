if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)
local L = WeakAuras.L

local flattenRegionOptions = OptionsPrivate.commonOptions.flattenRegionOptions
local fixMetaOrders = OptionsPrivate.commonOptions.fixMetaOrders
local parsePrefix = OptionsPrivate.commonOptions.parsePrefix
local removeFuncs = OptionsPrivate.commonOptions.removeFuncs
local replaceNameDescFuncs = OptionsPrivate.commonOptions.replaceNameDescFuncs
local replaceImageFuncs = OptionsPrivate.commonOptions.replaceImageFuncs
local replaceValuesFuncs = OptionsPrivate.commonOptions.replaceValuesFuncs
local disabledAll = OptionsPrivate.commonOptions.CreateDisabledAll("region")
local hiddenAll = OptionsPrivate.commonOptions.CreateHiddenAll("region")
local getAll = OptionsPrivate.commonOptions.CreateGetAll("region")
local setAll = OptionsPrivate.commonOptions.CreateSetAll("region", getAll)

local modernStartValues = {
  subglow = { glowType = "Proc" },
  subtext = { text_text = "Text" },
}

local function BuildSubRegionData(subRegionName, regionType, detached, modern)
  local default = OptionsPrivate.Private.subRegionTypes[subRegionName].default
  local built = type(default) == "function" and default(regionType) or CopyTable(default)
  built.type = subRegionName
  if detached then
    built.secretAuraDetached = true
  end
  if modern then
    for key, value in pairs(modernStartValues[subRegionName] or {}) do
      built[key] = value
    end
  end
  return built
end

local function NewSwipeColorOption()
  return {
    type = "color",
    name = L["Swipe Color"],
    hasAlpha = true,
    order = 11.9,
    width = WeakAuras.normalWidth,
  }
end

local function AddSubRegion(data, subRegionName, detached)
  local Display = OptionsPrivate.Private.BlizzardAuraDisplay
  for data in OptionsPrivate.Private.TraverseLeafsOrAura(data) do
    data.subRegions = data.subRegions or {}
    if OptionsPrivate.Private.subRegionTypes[subRegionName] and OptionsPrivate.Private.subRegionTypes[subRegionName] then
      local subRegionType = OptionsPrivate.Private.subRegionTypes[subRegionName]
      if Display.CanAddElement(data, subRegionName) and subRegionType.supports(data.regionType) then
        tinsert(data.subRegions, BuildSubRegionData(subRegionName, data.regionType, detached, Display.Enabled(data)))
        WeakAuras.Add(data)
        OptionsPrivate.ClearOptions(data.id)
      end
    end
  end
  if Display.Enabled(data) then
    OptionsPrivate.QueueOptionsRefresh(data.id)
  else
    WeakAuras.ClearAndUpdateOptions(data.id)
  end
end

local function AddOptionsForSupportedSubRegion(regionOption, data, supported)
  if not next(supported) then
    return
  end
  local hasSubRegions = false

  local result = {}
  local order = 1
  result.__order = 300
  result.__title = L["Add Extra Elements"]
  result.__topLine = true
  result.__withoutheader = true
  result["subregiontypespace"] = {
    type = "description",
    width = WeakAuras.doubleWidth,
    name = "",
    order = order,
  }
  order = order + 1
  for subRegionType in pairs(supported) do
    if OptionsPrivate.Private.subRegionTypes[subRegionType].supportsAdd then
      hasSubRegions = true
      result[subRegionType] = {
        type = "execute",
        width = WeakAuras.normalWidth,
        name = string.format(L["Add %s"], OptionsPrivate.Private.subRegionTypes[subRegionType].displayName),
        order = order,
        func = function()
          AddSubRegion(data, subRegionType)
        end,
      }
      order = order + 1
    end
  end
  if OptionsPrivate.Private.BlizzardAuraDisplay.Enabled(data) then
    local detachableKinds = { "subtext", "subtexture" }
    for position = 1, #detachableKinds do
      local kind = detachableKinds[position]
      if supported[kind] then
        result[kind .. "Detached"] = {
          type = "execute",
          width = WeakAuras.normalWidth,
          name = L["Add Detached %s"]:format(OptionsPrivate.Private.subRegionTypes[kind].displayName),
          desc = L["Adds an element that stays visible on the display while Aura (Modern) draws the auras."],
          order = order,
          func = function()
            AddSubRegion(data, kind, true)
          end,
        }
        order = order + 1
      end
    end
  end
  regionOption["sub"] = result;
  return hasSubRegions
end

local function union(table1, table2)
  local meta = {};
  for i,v in pairs(table1) do
    meta[i] = v;
  end
  for i,v in pairs(table2) do
    meta[i] = v;
  end
  return meta;
end

-- Rectangle of an aura in the units of its offsets, around its anchor point.
local function OffsetRect(data)
  local width, height = data.width or 0, data.height or 0
  -- A text is sized by its region, built on demand: a multi-selection does not build it.
  local region = data.regionType == "text" and OptionsPrivate.Private.EnsureRegion(data.id)
  if region then
    width, height = region.width or 0, region.height or 0
  end
  local selfPoint = data.selfPoint or "CENTER"
  local left, bottom = data.xOffset or 0, data.yOffset or 0
  if selfPoint:find("RIGHT") then
    left = left - width
  elseif not selfPoint:find("LEFT") then
    left = left - width / 2
  end
  if selfPoint:find("TOP") then
    bottom = bottom - height
  elseif not selfPoint:find("BOTTOM") then
    bottom = bottom - height / 2
  end
  return { left = left, bottom = bottom, right = left + width, top = bottom + height }
end

-- The auras of the multi-selection that can be aligned: at least two, none a group nor in a dynamic group, all with
-- the same anchor, so that their offsets share one origin. nil otherwise. A unit frame, nameplate or custom anchor
-- is resolved per aura, and a Modern Aura Group places its children itself: left out.
local alignAnchorTypes = { SCREEN = true, UIPARENT = true, SELECTFRAME = true, MOUSE = true }
local function AurasToAlign(data)
  local auras, anchor = {}, nil
  for _, childId in ipairs(data.controlledChildren) do
    local child = WeakAuras.GetData(childId)
    local parent = child and child.parent and WeakAuras.GetData(child.parent)
    if not child or child.controlledChildren or not alignAnchorTypes[child.anchorFrameType or "SCREEN"]
      or (parent and (parent.regionType == "dynamicgroup" or parent.blizzardFlow)) then
      return nil
    end
    -- The anchor the engine uses (WeakAuras.lua, AnchorFrame): a frame only with SELECTFRAME, with its parenting, and
    -- CENTER for the mouse and for a child on the screen. Hidden leftover fields do not count.
    local anchorType = child.anchorFrameType or "SCREEN"
    local selectFrame = anchorType == "SELECTFRAME"
    local anchorPoint = child.anchorPoint or ""
    if anchorType == "MOUSE" or (child.parent and anchorType == "SCREEN") then
      anchorPoint = "CENTER"
    end
    local childAnchor = table.concat({ child.parent or "", anchorType, selectFrame and child.anchorFrameFrame or "",
      selectFrame and tostring(child.anchorFrameParent ~= false) or "", anchorPoint }, "|")
    if anchor and anchor ~= childAnchor then
      return nil
    end
    anchor = childAnchor
    auras[#auras + 1] = child
  end
  return #auras > 1 and auras or nil
end

local alignCommands = {
  { "LEFT", L["Left Edges"] }, { "RIGHT", L["Right Edges"] }, { "CENTERX", L["Centers on a Column"] },
  { "TOP", L["Top Edges"] }, { "BOTTOM", L["Bottom Edges"] }, { "CENTERY", L["Centers on a Row"] },
  { "SPREADX", L["Distribute Horizontally"] }, { "SPREADY", L["Distribute Vertically"] },
}

-- Commands of the multi-selection that align or spread its auras, after the position settings. One step of the time
-- machine: the auras are added in the same click.
local function AddAlignSelection(args, data, order)
  args["alignSelection.header"] = { type = "header", name = L["Align Selection"], order = order, hidden = false }
  for index, command in ipairs(alignCommands) do
    args["alignSelection." .. command[1]] = {
      type = "execute",
      name = command[2],
      desc = L["Needs at least two auras with the same anchor point on the screen, a frame or the mouse, not groups nor in a group that places its children."],
      width = WeakAuras.normalWidth,
      order = order + index / 10,
      hidden = false,
      disabled = function() return not AurasToAlign(data) end,
      func = function()
        local auras = AurasToAlign(data)
        if not auras then
          return
        end
        local rects = {}
        for auraIndex, aura in ipairs(auras) do
          rects[auraIndex] = OffsetRect(aura)
        end
        local Private = OptionsPrivate.Private
        for auraIndex, shift in ipairs(Private.PlacementSnap.AlignShifts(rects, command[1])) do
          local aura = auras[auraIndex]
          if shift[1] ~= 0 or shift[2] ~= 0 then
            Private.TimeMachine:Watch(aura)
            aura.xOffset = (aura.xOffset or 0) + shift[1]
            aura.yOffset = (aura.yOffset or 0) + shift[2]
            WeakAuras.Add(aura)
            Private.AddParents(aura)
          end
        end
        WeakAuras.ClearAndUpdateOptions(data.id)
        OptionsPrivate.ResetMoverSizer()
      end,
    }
  end
end

function OptionsPrivate.GetDisplayOptions(data)
  local id = data.id

  if not data.controlledChildren then
    local regionOption;
    local commonOption = {};

    local hasSubElements = false

    if(OptionsPrivate.Private.regionOptions[data.regionType]) then
      regionOption = OptionsPrivate.Private.regionOptions[data.regionType].create(id, data);

      if data.subRegions then
        local subIndex = {}
        for index, subRegionData in ipairs(data.subRegions) do
          local subRegionType = subRegionData.type
          if OptionsPrivate.Private.subRegionOptions[subRegionType] then
            hasSubElements = true
            subIndex[subRegionType] = subIndex[subRegionType] and subIndex[subRegionType] + 1 or 1
            local options, common = OptionsPrivate.Private.subRegionOptions[subRegionType].create(data, subRegionData, index, subIndex[subRegionType])
            options.__order = 200 + index
            options.__collapsed = true
            regionOption["sub." .. index .. "." .. subRegionType] = options
            commonOption[subRegionType] = common
          end
        end
      end

      local commonOptionIndex = 0
      for option, optionData in pairs(commonOption) do
        commonOptionIndex = commonOptionIndex + 1
        optionData.__order = 100 + commonOptionIndex
        regionOption[option] = optionData
      end

      local supported = {}
      for subRegionName, subRegionType in pairs(OptionsPrivate.Private.subRegionTypes) do
        if subRegionType.supports(data.regionType) and OptionsPrivate.Private.BlizzardAuraDisplay.CanAddElement(data, subRegionName) then
          supported[subRegionName] = true
        end
      end
      hasSubElements = AddOptionsForSupportedSubRegion(regionOption, data, supported) or hasSubElements
    else
      regionOption = {
        [data.regionType] = {
          __title = OptionsPrivate.Private.Style.Hex("primary") .. data.regionType,
          __order = 1,
          unsupported = {
            type = "description",
            name = L["This region of type \"%s\" is not supported."]:format(data.regionType),
            order = 2,
          }
        }
      };
    end

    if hasSubElements then
      regionOption["SubElementsHeader"] = {
        __order = 100,
        __noHeader = true,
        header = {
          type = "header",
          name = L["Sub Elements"],
          order = 1
        }
      }
    end

    OptionsPrivate.PrepareSecretDisplayOptions(data, regionOption)
    local options = flattenRegionOptions(regionOption, true)

    for _, option in pairs(options) do
      if option.type == "range" then
        option.control = "WeakAurasSpinBox"
      end
    end

    local region = {
      type = "group",
      name = L["Display"],
      order = 10,
      get = function(info)
        local base, property = parsePrefix(info[#info], data);
        if(info.type == "color") then
          local color = base and base[property]
          local red, green, blue, alpha = 1, 1, 1, 1
          if color then
            red, green, blue, alpha = color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1
          end
          return red, green, blue, alpha
        end
        return base and base[property]
      end,
      set = function(info, v, g, b, a)
        local base, property = parsePrefix(info[#info], data, true);
        if(info.type == "color") then
          base[property] = base[property] or {};
          local c = base[property];
          c[1], c[2], c[3], c[4] = v, g, b, a;
        elseif(info.type == "toggle") then
          base[property] = v;
        else
          base[property] = (v ~= "" and v) or nil;
        end
        WeakAuras.Add(data);
        WeakAuras.UpdateThumbnail(data);
        OptionsPrivate.Private.AddParents(data)
        OptionsPrivate.ResetMoverSizer();
      end,
      args = options
    };
    return region
  else
    -- Multiple Auras
    -- We call the create functions of the relevant region types with
    -- the parentData once per region type
    -- For sub regions, the relevant create function is called with the parentData
    -- once per index/sub region type
    local handledRegionTypes = {}
    local handledSubRegionTypes = {}

    local allOptions = {};
    local commonOption = {};
    local unsupportedCount = 0
    local supportedSubRegions = {}
    local hasSubElements = false

    for child in OptionsPrivate.Private.TraverseLeafs(data) do
      if child and not handledRegionTypes[child.regionType] then
        handledRegionTypes[child.regionType] = true;
        if OptionsPrivate.Private.regionOptions[child.regionType] then
          allOptions = union(allOptions, OptionsPrivate.Private.regionOptions[child.regionType].create(id, data));
        else
          unsupportedCount = unsupportedCount + 1
          allOptions["__unsupported" .. unsupportedCount] =  {
            __title = OptionsPrivate.Private.Style.Hex("primary") .. child.regionType,
            __order = 1,
            warning = {
              type = "description",
              name = L["Regions of type \"%s\" are not supported."]:format(child.regionType),
              order = 1
            },
          }
        end
        for subRegionName, subRegionType in pairs(OptionsPrivate.Private.subRegionTypes) do
          if subRegionType.supports(child.regionType) then
            supportedSubRegions[subRegionName] = true
          end
        end
      end
      if child.subRegions then
        local subIndex = {}
        for index, subRegionData in ipairs(child.subRegions) do
          local subRegionType = subRegionData.type
          local alreadyHandled = handledSubRegionTypes[index] and handledSubRegionTypes[index][subRegionType]
          if OptionsPrivate.Private.subRegionOptions[subRegionType] and not alreadyHandled then
            handledSubRegionTypes[index] = handledSubRegionTypes[index] or {}
            handledSubRegionTypes[index][subRegionType] = true
            hasSubElements = true
            subIndex[subRegionType] = subIndex[subRegionType] and subIndex[subRegionType] + 1 or 1

            local options, common = OptionsPrivate.Private.subRegionOptions[subRegionType].create(data, nil, index, subIndex[subRegionType])
            options.__order = 200 + index

            allOptions["sub." .. index .. "." .. subRegionType] = options
            commonOption[subRegionType] = common
          end
        end
      end
    end

    local commonOptionIndex = 0
    for option, optionData in pairs(commonOption) do
      commonOptionIndex = commonOptionIndex + 1
      optionData.__order = 100 + commonOptionIndex
      allOptions[option] = optionData
    end

    hasSubElements = AddOptionsForSupportedSubRegion(allOptions, data, supportedSubRegions) or hasSubElements

    if hasSubElements then
      allOptions["SubElementsHeader"] = {
        __order = 100,
        __noHeader = true,
        header = {
          order = 1,
          type = "header",
          name = L["Sub Elements"],
        }
      }
    end

    local Display = OptionsPrivate.Private.BlizzardAuraDisplay
    for child in OptionsPrivate.Private.TraverseLeafs(data) do
      if Display.Enabled(child) then
        if not (allOptions.secretAura or Display.FlowGroup(child)) then
          allOptions.secretAura = OptionsPrivate.GetSecretAuraSettings(child)
        end
        if child.regionType == "icon" and allOptions.icon and allOptions.icon.secretSwipeColor == nil then
          allOptions.icon.secretSwipeColor = NewSwipeColorOption()
        end
      end
    end

    fixMetaOrders(allOptions);

    local region = {
      type = "group",
      name = L["Display"],
      order = 10,
      args = flattenRegionOptions(allOptions, false);
    };

    removeFuncs(region);
    replaceNameDescFuncs(region, data, "region");
    replaceImageFuncs(region, data, "region");
    replaceValuesFuncs(region, data, "region");

    region.get = function(info, ...) return getAll(data, info, ...); end;
    region.set = function(info, ...)
      setAll(data, info, ...);
      if(type(data.id) == "string") then
        WeakAuras.Add(data);
        WeakAuras.UpdateThumbnail(data);
        OptionsPrivate.ResetMoverSizer();
      end
    end
    region.hidden = function(info, ...) return hiddenAll(data, info, ...); end;
    region.disabled = function(info, ...) return disabledAll(data, info, ...); end;
    for _, options in pairs(allOptions) do
      if type(data.id) == "table" and options.__title == L["Position and Size Settings"] then
        AddAlignSelection(region.args, data, options.__order * 1000 + 900)
      end
    end
    return region
  end

end

return function(test)
  local savedPolicy = CustomAuraContainerAuraProcessingPolicy
  local savedIsLoaded = C_AddOns.IsAddOnLoaded
  local savedStringUtil = C_StringUtil
  local savedFormatter = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
  local savedCreateFrame = CreateFrame

  CustomAuraContainerAuraProcessingPolicy = { None = 0 }
  C_AddOns.IsAddOnLoaded = function(name)
    if name == "Blizzard_AuraContainer" then return true end
    return savedIsLoaded(name)
  end
  C_StringUtil = C_StringUtil or {}
  C_StringUtil.CreateNumericRuleFormatter = function() return { SetBreakpoints = function() end } end
  local noop = function() end
  CreateFrame = function(frameType, name, parent, template)
    if frameType ~= "AuraContainer" then return savedCreateFrame(frameType, name, parent, template) end
    local container = savedCreateFrame("Frame", name, parent)
    test.Frames.SetProtected(container, true)
    for _, method in ipairs({ "SetEnabled", "SetAuraProcessingPolicy", "SetUnit", "SetAuraSlotFilterString",
      "SetAuraSlotCandidateFilters", "SetAuraSlotSortMethod", "UpdateAllAuras" }) do
      container[method] = noop
    end
    container.AddAuraSlot = function(self, _, _, options)
      local button = savedCreateFrame("Frame", nil, self)
      for _, method in ipairs({ "SetDurationText", "SetDurationCooldown", "SetApplicationCount", "SetDurationBar" }) do
        button[method] = noop
      end
      options.initializeFrame(button)
    end
    return container
  end

  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Spare = {
      id = "Spare", uid = "Spare", regionType = "texture", internalVersion = 91,
      triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
        useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnActive" }, untrigger = {} },
        activeTriggerMode = -10 },
      load = {}, conditions = {}, actions = { start = {}, finish = {}, init = {} },
      animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
      subRegions = { { type = "subtext", text_text = "%bp" }, { type = "subtext", text_text = "%n" } },
      width = 64, height = 64, anchorPoint = "TOP", selfPoint = "TOP",
      anchorFrameType = "SCREEN", xOffset = 100, yOffset = -50,
    },
  } })
  test.Environment.Advance(1)
  assert(private.EnsureRegion("Spare"), "region not created")

  local function AssertPlaced(clone, step)
    local point, relativeTo, relativePoint, x, y = clone:GetPoint(1)
    assert(point == "TOP" and relativeTo == WeakAurasFrame and relativePoint == "TOP" and x == 100 and y == -50,
      step .. " clone at " .. tostring(point) .. " " .. tostring(relativePoint) .. " " .. tostring(x) .. " " .. tostring(y))
  end

  test.Units.SetCombat(true)
  local clone = private.EnsureRegion("Spare", "c1")
  assert(clone and clone:IsProtected(), "spare with container not taken")
  assert(#test.Environment.forbidden == 0, "spare taken in combat touched protected frames")
  AssertPlaced(clone, "in combat")
  test.Environment.Advance(1.5)
  test.Units.SetCombat(false)
  test.Environment.Advance(1.5)
  assert(#test.Environment.forbidden == 0, "postponed spare anchor touched protected frames")
  AssertPlaced(clone, "after combat")

  test.Units.SetCombat(true)
  private.ReleaseClone("Spare", "c1", "texture")
  assert(clone:GetAlpha() == 0, "protected clone released in combat not faded")
  assert(#test.Environment.forbidden == 0, "release in combat touched protected frames")
  test.Units.SetCombat(false)
  test.Environment.Advance(0.1)
  assert(not clone:IsShown() and clone:GetAlpha() ~= 0, "protected clone not restored after combat")
  assert(private.EnsureRegion("Spare", "c2") == clone, "protected clone not returned to pool")

  local progress = private.CDMAuraProgress
  local savedHasContainer = progress.HasContainer
  progress.HasContainer = function() return false end
  local pool, created = {}, 0
  local function Create()
    created = created + 1
    return private.regionTypes.texture.create(WeakAurasFrame, WeakAuras.GetData("Spare"))
  end
  local leftover = Create()
  local hiddenPart = leftover:CreateTexture()
  hiddenPart:SetAlpha(0)
  leftover.blizzardSuppressed = { [hiddenPart] = 0.7 }
  local leftoverState = { instances = {}, data = WeakAuras.GetData("Spare"), active = true, gridMember = true }
  leftover.blizzardAuraDisplay = leftoverState
  pool[1] = leftover
  for _ = 1, 3 do progress.AddSpareClone(pool, "texture", WeakAuras.GetData("Spare"), Create, nil) end
  progress.HasContainer = savedHasContainer
  assert(created == 1 and #pool == 1 and pool[1] == leftover, "spare without container created " .. created .. " frames")
  assert(leftover.blizzardSuppressed == nil and hiddenPart:GetAlpha() == 0.7, "recycled clone kept Aura (Modern) leftovers")
  assert(leftoverState.active == false and leftoverState.gridMember == nil, "recycled clone kept Aura (Modern) display active")

  local reserve = Create()
  reserve.cdmProgressData = WeakAuras.GetData("Spare")
  local reserveState = { instances = {}, data = WeakAuras.GetData("Spare"), active = true }
  reserve.blizzardAuraDisplay = reserveState
  progress.HasContainer = function(region) return region == reserve end
  progress.AddSpareClone({ reserve }, "texture", WeakAuras.GetData("Spare"), Create, nil)
  progress.HasContainer = savedHasContainer
  assert(reserveState.active == false, "existing spare kept Aura (Modern) display active")

  CreateFrame = savedCreateFrame
  C_StringUtil = savedStringUtil
  if savedStringUtil then savedStringUtil.CreateNumericRuleFormatter = savedFormatter end
  C_AddOns.IsAddOnLoaded = savedIsLoaded
  CustomAuraContainerAuraProcessingPolicy = savedPolicy
end

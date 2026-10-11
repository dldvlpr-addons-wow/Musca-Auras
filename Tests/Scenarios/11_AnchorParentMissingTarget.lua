local function Icon(id, load, extra)
  local data = {
    id = id, uid = id, regionType = "icon", internalVersion = 91,
    triggers = { { trigger = { type = "aura2", unit = "player", debuffType = "HELPFUL",
      useExactSpellId = true, auraspellids = { "324" }, matchesShowOn = "showOnMissing" }, untrigger = {} },
      activeTriggerMode = -10 },
    load = load, conditions = {}, actions = { start = {}, finish = {}, init = {} },
    animation = { start = { type = "none" }, main = { type = "none" }, finish = { type = "none" } },
    subRegions = {}, width = 64, height = 64, anchorPoint = "CENTER", selfPoint = "CENTER",
    anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
  }
  for key, value in pairs(extra or {}) do
    data[key] = value
  end
  return data
end

return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", { displays = {
    Skills = {
      id = "Skills", uid = "Skills", regionType = "dynamicgroup", internalVersion = 91,
      controlledChildren = { "Dependency" }, load = {}, triggers = {}, conditions = {},
      actions = { start = {}, finish = {}, init = {} }, subRegions = {},
      anchorPoint = "CENTER", selfPoint = "CENTER", anchorFrameType = "SCREEN", xOffset = 0, yOffset = 0,
    },
    Dependency = Icon("Dependency", { use_never = true }, { parent = "Skills" }),
    Reminder = Icon("Reminder", {}, {
      anchorFrameType = "SELECTFRAME", anchorFrameFrame = "WeakAuras:Dependency", anchorFrameParent = true,
    }),
  } })
  test.Environment.Advance(1)

  local reminder = WeakAuras.GetRegion("Reminder")
  assert(reminder, "reminder region not created")
  assert(not WeakAuras.GetRegion("Dependency"), "never loaded target has a region")
  assert(reminder:GetParent() == WeakAuras.HiddenFrames,
    "reminder not parented to HiddenFrames while target has no region")

  local reminderData = WeakAuras.GetData("Reminder")
  reminderData.anchorFrameParent = false
  private.AnchorFrame(reminderData, reminder, WeakAurasFrame)
  assert(reminder:GetParent() ~= WeakAuras.HiddenFrames, "position only anchoring parented to HiddenFrames")

  reminderData.anchorFrameParent = true
  private.AnchorFrame(reminderData, reminder, WeakAurasFrame)
  local dependency = private.EnsureRegion("Dependency")
  assert(dependency, "target region not created")
  test.Environment.Advance(1.5)
  assert(reminder:GetParent() == dependency, "postponed anchor did not attach the target once created")
end

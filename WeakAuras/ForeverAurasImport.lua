if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local addonsPathPrefix = "[Aa][Dd][Dd][Oo][Nn][Ss][\\/]+"
local apiReferencePattern = "ForeverAuras([%.:%[])"
local frameReferenceKeys = { anchorFrameFrame = true, glow_frame = true }

if ForeverAuras == nil then
  ForeverAuras = WeakAuras
end

local handBySwingType = { [0] = "main", [1] = "off", [2] = "ranged" }

local formSpellByFormID = {
  [0] = 0, [1] = 768, [3] = 783, [4] = 1066, [5] = 5487, [8] = 5487, [16] = 2645, [17] = 2457, [18] = 71,
  [19] = 2458, [28] = 15473, [30] = 1784, [31] = 24858, [35] = 24858,
}

local unsupportedEvents = {
  ["TimelineParser Timer"] = true,
  ["TimelineParser Stage"] = true,
}

local function IsCodeField(tbl, key)
  return type(key) == "string" and (key:find("custom", 1, true) or (key == "value" and tbl.variable == "customcheck"))
end

local function HasForeverAurasReferences(tbl)
  for key, value in pairs(tbl) do
    if type(value) == "string" then
      if value:find(addonsPathPrefix .. "ForeverAuras") or (IsCodeField(tbl, key) and value:find(apiReferencePattern))
         or (frameReferenceKeys[key] and value:find("^ForeverAuras:")) then
        return true
      end
    elseif type(value) == "table" and HasForeverAurasReferences(value) then
      return true
    end
  end
  return false
end

local function IsForeverAurasDispelSubRegion(subRegion)
  return subRegion.type == "subcdmdispelborder"
    or (subRegion.type == "subcdmdispel" and subRegion.dispelStyle ~= nil and subRegion.dispelStyle ~= "Icon")
end

local function HasForeverAurasContent(data)
  if data.cdmDispelIndicator or data.blizzardAuraDisplay then
    return true
  end
  for _, triggerData in ipairs(type(data.triggers) == "table" and data.triggers or {}) do
    local trigger = type(triggerData) == "table" and triggerData.trigger
    if type(trigger) == "table" and (trigger.type == "cdm" or trigger.type == "secretAura"
       or trigger.swingType ~= nil or trigger.trackingType ~= nil or trigger.trackingShow ~= nil
       or trigger.ammoItemIDs ~= nil or trigger.use_totalSlots ~= nil or trigger.use_freePercent ~= nil
       or trigger.use_formID ~= nil
       or unsupportedEvents[trigger.event]) then
      return true
    end
  end
  for _, subRegion in ipairs(type(data.subRegions) == "table" and data.subRegions or {}) do
    if type(subRegion) == "table" and IsForeverAurasDispelSubRegion(subRegion) then
      return true
    end
  end
  return HasForeverAurasReferences(data)
end

local function IsForeverAurasData(data)
  return type(data) == "table" and HasForeverAurasContent(data)
end

local function RenameReferences(tbl)
  local renamed = false
  for key, value in pairs(tbl) do
    if type(value) == "string" then
      local count, codeCount
      value, count = value:gsub("(" .. addonsPathPrefix .. ")ForeverAuras", "%1WeakAuras")
      if IsCodeField(tbl, key) then
        value, codeCount = value:gsub(apiReferencePattern, "WeakAuras%1")
        count = count + codeCount
      end
      if frameReferenceKeys[key] then
        local frameCount
        value, frameCount = value:gsub("^ForeverAuras:", "WeakAuras:")
        count = count + frameCount
      end
      if count > 0 then
        tbl[key] = value
        renamed = true
      end
    elseif type(value) == "table" then
      renamed = RenameReferences(value) or renamed
    end
  end
  return renamed
end

local function ConvertTrigger(trigger, warn)
  if trigger.event == "Swing Timer" then
    local hand = handBySwingType[tonumber(trigger.swingType)]
    if hand and (trigger.hand ~= hand or not trigger.use_hand) then
      trigger.hand = hand
      trigger.use_hand = true
      return true
    end
  elseif trigger.event == "Ammo" then
    if type(trigger.ammoItemIDs) == "string" and trigger.ammoItemIDs ~= "" then
      local items = {}
      for id in trigger.ammoItemIDs:gmatch("%d+") do
        tinsert(items, tonumber(id))
      end
      trigger.use_ammoItem = items[1] and true or nil
      trigger.ammoItem = items[1] and items or nil
      warn("Ammo item list now filters the equipped ammo, instead of counting these items in the bags")
      return true
    end
  elseif trigger.event == "Role" then
    if trigger.use_role == nil and trigger.role ~= nil then
      trigger.use_role = true
      return true
    end
  elseif trigger.event == "Tracking" and (trigger.trackingType ~= nil or trigger.trackingShow ~= nil) then
    local spellID = tonumber(trigger.trackingType)
    trigger.use_trackingSpell = spellID and true or nil
    trigger.trackingSpell = spellID and { spellID } or nil
    trigger.use_inverse = trigger.trackingShow == "inactive" or nil
    if not spellID and trigger.trackingType and trigger.trackingType ~= "" then
      warn("Tracking without a spell ID, now shows on any active tracking")
    end
    if trigger.trackingShow == "always" then
      warn("Tracking shown always, now shown when active")
    end
    return true
  elseif trigger.event == "Equipment Durability" then
    local slot = tonumber(trigger.durabilitySlot)
    if trigger.use_durabilitySlot == nil and slot and slot > 0 then
      trigger.use_durabilitySlot = true
      trigger.durabilitySlot = slot
      return true
    end
  elseif trigger.event == "Stance/Form/Aura" and trigger.use_formID ~= nil then
    local formID = type(trigger.formID) == "table" and trigger.formID or {}
    local function FormSpell(id)
      local spell = formSpellByFormID[tonumber(id)]
      if not spell then
        warn(("Form ID %s has no equivalent, removed from the form filter"):format(tostring(id)))
      end
      return spell
    end
    if trigger.use_form ~= nil then
      warn("Form filter by position replaced by the form ID filter")
    end
    local form = { multi = {} }
    trigger.use_form = trigger.use_formID
    if trigger.use_formID == true then
      form.single = formID.single ~= nil and FormSpell(formID.single) or nil
      if form.single == nil then trigger.use_form = nil end
    elseif trigger.use_formID == false then
      for id, selected in pairs(type(formID.multi) == "table" and formID.multi or {}) do
        local spell = FormSpell(id)
        if spell then form.multi[spell] = selected end
      end
    end
    trigger.form = form
    trigger.use_formByPosition = false
    trigger.use_formID, trigger.formID = nil, nil
    return true
  elseif trigger.event == "Bag Space" then
    if trigger.use_totalSlots or trigger.use_freePercent then
      warn("Bag Space total slots or free percent filter, removed")
    end
  elseif unsupportedEvents[trigger.event] then
    warn(("%s trigger has no equivalent, the aura will not show"):format(trigger.event))
  end
  return false
end

local function ConvertAura(data, warnings)
  local warningCount = #warnings
  local function warn(message)
    tinsert(warnings, ("%s: %s"):format(data.id or "?", message))
  end

  local changed = RenameReferences(data)
  data.information = data.information or {}
  if data.information.showNilIsFalse ~= true then
    data.information.showNilIsFalse = true
    changed = true
  end

  local formTriggers = {}
  if type(data.triggers) == "table" then
    for index, triggerData in ipairs(data.triggers) do
      if type(triggerData.trigger) == "table" then
        formTriggers[index] = triggerData.trigger.event == "Stance/Form/Aura" and triggerData.trigger.use_formID ~= nil
        changed = ConvertTrigger(triggerData.trigger, warn) or changed
      end
    end
  end

  local function ConvertFormConditions(check)
    if type(check) ~= "table" then
      return
    end
    if formTriggers[check.trigger] and check.variable == "formID" then
      local spell = formSpellByFormID[tonumber(check.value)]
      if not spell then
        warn(("Condition on form ID %s has no equivalent, it never matches"):format(tostring(check.value)))
      end
      check.variable, check.value = "form", spell
      changed = true
    elseif formTriggers[check.trigger] and check.variable == "form" then
      warn("Condition on form by position, select the form again")
    end
    for _, subCheck in ipairs(type(check.checks) == "table" and check.checks or {}) do
      ConvertFormConditions(subCheck)
    end
  end
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    ConvertFormConditions(type(condition) == "table" and condition.check)
  end

  local function WarnConditionVariables(check)
    if type(check) ~= "table" then
      return
    end
    if check.variable == "totalSlots" or check.variable == "freePercent" then
      warn(("Condition on Bag Space %s, it never matches"):format(check.variable))
    end
    for _, subCheck in ipairs(type(check.checks) == "table" and check.checks or {}) do
      WarnConditionVariables(subCheck)
    end
  end
  for _, condition in ipairs(type(data.conditions) == "table" and data.conditions or {}) do
    WarnConditionVariables(type(condition) == "table" and condition.check)
  end

  data.internalVersion = (tonumber(data.internalVersion) or 0) >= 90 and 91 or 89
  return changed or #warnings > warningCount
end

function Private.ConvertForeverAurasImport(data, children)
  local converted = false
  local warnings = {}
  if IsForeverAurasData(data) then
    converted = ConvertAura(data, warnings) or converted
  end
  if type(children) == "table" then
    for _, child in ipairs(children) do
      if IsForeverAurasData(child) then
        converted = ConvertAura(child, warnings) or converted
      end
    end
  end
  if converted then
    WeakAuras.prettyPrint("Converted from ForeverAuras.")
    for _, message in ipairs(warnings) do
      WeakAuras.prettyPrint(message)
    end
  end
  return converted
end

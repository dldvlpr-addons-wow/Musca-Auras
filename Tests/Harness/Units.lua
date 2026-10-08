local Secret = require("Secret")
local Clock = require("Clock")

local Units = {
  units = {},
  restricted = false,
  nextAuraInstanceID = 100,
  addonName = "WeakAuras",
}

local auraFields = {
  "name", "icon", "applications", "dispelName", "duration", "expirationTime", "sourceUnit", "isStealable",
  "nameplateShowPersonal", "nameplateShowAll", "spellId", "canApplyAura", "isBossAura", "isFromPlayerOrPlayerPet",
  "timeMod", "points", "isHarmful", "isHelpful", "isRaid", "isNameplateOnly", "isPriorityAura",
}

function Units.DefineUnit(token, definition)
  local unit = {
    token = token,
    exists = true,
    name = definition.name or token,
    guid = definition.guid or ("Player-0000-" .. token),
    class = definition.class or "WARRIOR",
    level = definition.level or 60,
    health = definition.health or 1000,
    healthMax = definition.healthMax or 1000,
    power = definition.power or 100,
    powerMax = definition.powerMax or 100,
    powerType = definition.powerType or 1,
    isPlayerControlled = definition.isPlayerControlled ~= false,
    canAttack = definition.canAttack == true,
    auras = {},
  }
  Units.units[token] = unit
  return unit
end

function Units.Get(token)
  if Secret.IsSecret(token) then
    error("unit token must not be secret", 3)
  end
  return Units.units[token]
end

local function IsAuraSecret(aura)
  if aura.secrecy == "never" then
    return false
  end
  if aura.secrecy == "always" then
    return true
  end
  return Units.restricted
end

local function BuildAuraData(aura, forceSecret)
  local data = { auraInstanceID = aura.auraInstanceID }
  local secret = forceSecret or IsAuraSecret(aura)
  for _, field in ipairs(auraFields) do
    local value = aura[field]
    if secret and value ~= nil and type(value) ~= "table" then
      value = Secret.Wrap(value)
    end
    data[field] = value
  end
  return data
end

local function DenyAccess(aura)
  if IsAuraSecret(aura) and Units.restricted then
    error("Auras cannot be accessed when secret while tainted by '" .. Units.addonName .. "'", 3)
  end
end

local function MatchesFilter(aura, filter)
  filter = filter or "HELPFUL"
  if filter:find("HARMFUL", 1, true) then
    if not aura.isHarmful then return false end
  elseif not aura.isHelpful then
    return false
  end
  if filter:find("PLAYER", 1, true) and not aura.isFromPlayerOrPlayerPet then
    return false
  end
  return true
end

local function FilteredAuras(unit, filter)
  local result = {}
  for _, aura in ipairs(unit and unit.auras or {}) do
    if MatchesFilter(aura, filter) then
      result[#result + 1] = aura
    end
  end
  return result
end

local function FindAura(unit, auraInstanceID)
  for _, aura in ipairs(unit and unit.auras or {}) do
    if aura.auraInstanceID == auraInstanceID then
      return aura
    end
  end
end

local function FireAuraEvent(token, updateInfo)
  Units.fire("UNIT_AURA", token, updateInfo)
end

function Units.ApplyAura(token, definition)
  local unit = assert(Units.units[token], "unknown unit " .. tostring(token))
  Units.nextAuraInstanceID = Units.nextAuraInstanceID + 1
  local duration = definition.duration or 0
  local aura = {
    auraInstanceID = Units.nextAuraInstanceID,
    name = definition.name or ("Spell " .. tostring(definition.spellId)),
    icon = definition.icon or 136243,
    applications = definition.applications or 0,
    dispelName = definition.dispelName,
    duration = duration,
    expirationTime = duration > 0 and (Clock.now + duration) or 0,
    sourceUnit = definition.sourceUnit or "player",
    isStealable = definition.isStealable == true,
    nameplateShowPersonal = false,
    nameplateShowAll = false,
    spellId = definition.spellId,
    canApplyAura = definition.canApplyAura == true,
    isBossAura = definition.isBossAura == true,
    isFromPlayerOrPlayerPet = definition.sourceUnit == nil or definition.sourceUnit == "player"
      or definition.sourceUnit == "pet",
    timeMod = 1,
    points = definition.points or {},
    isHarmful = definition.isHarmful == true,
    isHelpful = definition.isHarmful ~= true,
    isRaid = false,
    isNameplateOnly = false,
    isPriorityAura = false,
    secrecy = definition.secrecy or "contextual",
  }
  unit.auras[#unit.auras + 1] = aura
  FireAuraEvent(token, { isFullUpdate = false, addedAuras = { BuildAuraData(aura) } })
  return aura
end

function Units.UpdateAura(token, aura, changes)
  for key, value in pairs(changes) do
    aura[key] = value
  end
  if changes.duration then
    aura.expirationTime = changes.duration > 0 and (Clock.now + changes.duration) or 0
  end
  FireAuraEvent(token, { isFullUpdate = false, updatedAuraInstanceIDs = { aura.auraInstanceID } })
end

function Units.RemoveAura(token, aura)
  local unit = Units.units[token]
  for index = #unit.auras, 1, -1 do
    if unit.auras[index] == aura then
      table.remove(unit.auras, index)
    end
  end
  FireAuraEvent(token, { isFullUpdate = false, removedAuraInstanceIDs = { aura.auraInstanceID } })
end

function Units.ExpireAuras()
  for token, unit in pairs(Units.units) do
    for index = #unit.auras, 1, -1 do
      local aura = unit.auras[index]
      if aura.expirationTime > 0 and aura.expirationTime <= Clock.now then
        Units.RemoveAura(token, aura)
      end
    end
  end
end

local function NewDuration()
  local duration = { startTime = 0, total = 0, modRate = 1, secret = false }
  local methods = {}
  local function Value(value)
    if duration.secret then
      return Secret.Wrap(value)
    end
    return value
  end
  function methods:SetTimeFromStart(startTime, total, modRate)
    duration.startTime, duration.total, duration.modRate = startTime, total, modRate or 1
    duration.secret = Secret.IsSecret(startTime) or Secret.IsSecret(total)
    duration.startTime, duration.total = Secret.Reveal(startTime), Secret.Reveal(total)
  end
  function methods:SetTimeFromEnd(endTime, total, modRate)
    self:SetTimeFromStart(Secret.Reveal(endTime) - Secret.Reveal(total), total, modRate)
    duration.secret = duration.secret or Secret.IsSecret(endTime)
  end
  function methods:SetTimeSpan(startTime, endTime)
    self:SetTimeFromStart(startTime, math.max(0, Secret.Reveal(endTime) - Secret.Reveal(startTime)))
  end
  function methods:Reset() duration.startTime, duration.total = 0, 0 end
  function methods:SetToDefaults() duration.startTime, duration.total, duration.secret = 0, 0, false end
  function methods:HasSecretValues() return duration.secret end
  function methods:GetStartTime() return Value(duration.startTime) end
  function methods:GetEndTime() return Value(duration.startTime + duration.total) end
  function methods:GetTotalDuration() return Value(duration.total) end
  function methods:GetElapsedDuration() return Value(math.min(duration.total, Clock.now - duration.startTime)) end
  function methods:GetRemainingDuration()
    return Value(math.max(0, duration.startTime + duration.total - Clock.now))
  end
  function methods:GetRemainingPercent()
    if duration.total <= 0 then return Value(0) end
    return Value(math.max(0, duration.startTime + duration.total - Clock.now) / duration.total)
  end
  function methods:GetElapsedPercent()
    if duration.total <= 0 then return Value(0) end
    return Value(math.min(1, (Clock.now - duration.startTime) / duration.total))
  end
  function methods:IsZero() return Value(duration.total <= 0) end
  function methods:HasExpired() return Value(duration.startTime + duration.total <= Clock.now) end
  function methods:IsActive() return Value(duration.total > 0 and duration.startTime + duration.total > Clock.now) end
  function methods:HasStarted() return Value(duration.startTime <= Clock.now) end
  function methods:GetModRate() return duration.modRate end
  function methods:Copy()
    local copy = NewDuration()
    copy:SetTimeFromStart(duration.startTime, duration.total, duration.modRate)
    if duration.secret then copy:SetTimeFromStart(Secret.Wrap(duration.startTime), duration.total) end
    return copy
  end
  function methods:Assign(other) self:SetTimeFromStart(other:GetStartTime(), other:GetTotalDuration()) end
  local proxy = newproxy(true)
  local metatable = getmetatable(proxy)
  metatable.__index = methods
  metatable.__tostring = function() return "LuaDurationObject" end
  return proxy
end
Units.NewDuration = NewDuration

local function RestrictionState(active)
  return active and 2 or 0
end

function Units.SetCombat(inCombat)
  if Units.restricted == inCombat then
    return
  end
  Units.wowApi.inCombat = inCombat
  if inCombat then
    Units.fire("ADDON_RESTRICTION_STATE_CHANGED", 0, 1)
    Units.restricted = true
    Units.fire("PLAYER_REGEN_DISABLED")
    Units.fire("PLAYER_IN_COMBAT_CHANGED", true)
  else
    Units.restricted = false
    Units.fire("ADDON_RESTRICTION_STATE_CHANGED", 0, 0)
    Units.fire("PLAYER_REGEN_ENABLED")
    Units.fire("PLAYER_IN_COMBAT_CHANGED", false)
  end
end

function Units.Install(target, fire, wowApi)
  Units.fire = fire
  Units.wowApi = wowApi
  local C_UnitAuras = target.C_UnitAuras or {}
  target.C_UnitAuras = C_UnitAuras

  function C_UnitAuras.GetAuraSlots(token, filter, maxSlots, continuationToken)
    local unit = Units.Get(token)
    local slots = {}
    for index, aura in ipairs(unit and unit.auras or {}) do
      if MatchesFilter(aura, filter) then
        slots[#slots + 1] = index
      end
    end
    return nil, unpack(slots)
  end

  function C_UnitAuras.GetAuraDataBySlot(token, slot)
    local unit = Units.Get(token)
    local aura = unit and unit.auras[slot]
    if aura then
      DenyAccess(aura)
      return BuildAuraData(aura)
    end
  end

  function C_UnitAuras.GetAuraDataByIndex(token, index, filter)
    local aura = FilteredAuras(Units.Get(token), filter)[index]
    if aura then
      DenyAccess(aura)
      return BuildAuraData(aura)
    end
  end
  C_UnitAuras.GetBuffDataByIndex = function(token, index, filter)
    return C_UnitAuras.GetAuraDataByIndex(token, index, "HELPFUL" .. (filter and ("|" .. filter) or ""))
  end
  C_UnitAuras.GetDebuffDataByIndex = function(token, index, filter)
    return C_UnitAuras.GetAuraDataByIndex(token, index, "HARMFUL" .. (filter and ("|" .. filter) or ""))
  end

  function C_UnitAuras.GetAuraDataByAuraInstanceID(token, auraInstanceID)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    if aura then
      DenyAccess(aura)
      return BuildAuraData(aura)
    end
  end

  local function BySpell(token, predicate)
    local unit = Units.Get(token)
    for _, aura in ipairs(unit and unit.auras or {}) do
      if predicate(aura) then
        if IsAuraSecret(aura) then
          return nil
        end
        return BuildAuraData(aura)
      end
    end
  end
  function C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    return BySpell("player", function(aura) return aura.spellId == spellID end)
  end
  function C_UnitAuras.GetUnitAuraBySpellID(token, spellID)
    return BySpell(token, function(aura) return aura.spellId == spellID end)
  end
  function C_UnitAuras.GetAuraDataBySpellName(token, name, filter)
    return BySpell(token, function(aura) return aura.name == name and MatchesFilter(aura, filter) end)
  end

  function C_UnitAuras.GetUnitAuraInstanceIDs(token, filter, maxCount)
    local ids = {}
    for _, aura in ipairs(FilteredAuras(Units.Get(token), filter)) do
      ids[#ids + 1] = aura.auraInstanceID
    end
    return ids
  end

  function C_UnitAuras.IsAuraFilteredOutByInstanceID(token, auraInstanceID, filter)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    return not (aura and MatchesFilter(aura, filter))
  end

  function C_UnitAuras.GetAuraDuration(token, auraInstanceID)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    if not aura then
      return nil
    end
    DenyAccess(aura)
    local duration = NewDuration()
    duration:SetTimeFromStart(aura.expirationTime - aura.duration, aura.duration)
    return duration
  end

  function C_UnitAuras.GetAuraApplicationDisplayCount(token, auraInstanceID, minDisplayCount)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    if not aura then
      return nil
    end
    local count = aura.applications >= (minDisplayCount or 2) and tostring(aura.applications) or ""
    if IsAuraSecret(aura) then
      return Secret.Wrap(count)
    end
    return count
  end

  function C_UnitAuras.DoesAuraHaveExpirationTime(token, auraInstanceID)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    if aura then
      local value = aura.expirationTime > 0
      return IsAuraSecret(aura) and Secret.Wrap(value) or value
    end
  end

  local function NewCurve(isColor)
    local points = {}
    local curve = {}
    function curve:AddPoint(x, y) points[#points + 1] = { x = x, y = y } table.sort(points, function(a, b) return a.x < b.x end) end
    function curve:ClearPoints() points = {} end
    function curve:GetPointCount() return #points end
    function curve:SetType() end
    function curve:Evaluate(x)
      local secret = Secret.IsSecret(x)
      x = Secret.Reveal(x)
      local result
      for index, point in ipairs(points) do
        if x <= point.x or index == #points then
          result = point.y
          local previous = points[index - 1]
          if previous and x > previous.x and not isColor then
            result = previous.y + (point.y - previous.y) * (x - previous.x) / (point.x - previous.x)
          end
          break
        end
      end
      return secret and Secret.Wrap(result) or result
    end
    return curve
  end
  target.C_CurveUtil = target.C_CurveUtil or {}
  target.C_CurveUtil.CreateCurve = function() return NewCurve(false) end
  target.C_CurveUtil.CreateColorCurve = function() return NewCurve(true) end
  target.C_CurveUtil.EvaluateColorValueFromBoolean = function(value, trueValue, falseValue)
    local result = Secret.Reveal(value) and trueValue or falseValue
    return Secret.IsSecret(value) and Secret.Wrap(result) or result
  end

  target.C_DurationUtil = target.C_DurationUtil or {}
  target.C_DurationUtil.CreateDuration = NewDuration

  local C_Secrets = target.C_Secrets or {}
  target.C_Secrets = C_Secrets
  C_Secrets.HasSecretRestrictions = function() return true end
  C_Secrets.ShouldAurasBeSecret = function() return Units.restricted end
  C_Secrets.ShouldCooldownsBeSecret = function() return Units.restricted end
  C_Secrets.ShouldUnitStatsBeSecret = function() return Units.restricted end
  C_Secrets.ShouldSpellCooldownBeSecret = function() return Units.restricted end
  C_Secrets.ShouldUnitIdentityBeSecret = function() return false end
  C_Secrets.ShouldUnitAuraInstanceBeSecret = function(token, auraInstanceID)
    local aura = FindAura(Units.Get(token), auraInstanceID)
    return aura ~= nil and IsAuraSecret(aura)
  end
  C_Secrets.GetSpellAuraSecrecy = function() return 2 end
  C_Secrets.GetSpellCastSecrecy = function() return 2 end
  C_Secrets.GetSpellCooldownSecrecy = function() return 2 end

  local C_RestrictedActions = target.C_RestrictedActions or {}
  target.C_RestrictedActions = C_RestrictedActions
  C_RestrictedActions.IsAddOnRestrictionActive = function(restrictionType)
    return restrictionType == 0 and Units.restricted
  end
  C_RestrictedActions.GetAddOnRestrictionState = function(restrictionType)
    return RestrictionState(restrictionType == 0 and Units.restricted)
  end

  local function Read(token, field)
    local unit = Units.Get(token)
    return unit and unit[field]
  end
  target.UnitExists = function(token) return Units.Get(token) ~= nil end
  target.UnitName = function(token)
    local name = Read(token, "name")
    return name, nil
  end
  target.UnitFullName = function(token) return Read(token, "name"), "TestRealm" end
  target.GetUnitName = function(token) return Read(token, "name") end
  target.UnitGUID = function(token) return Read(token, "guid") end
  target.UnitClass = function(token)
    local class = Read(token, "class")
    if class then
      return class:sub(1, 1) .. class:sub(2):lower(), class, 1
    end
  end
  target.UnitClassBase = function(token) return Read(token, "class"), 1 end
  target.UnitLevel = function(token) return Read(token, "level") or 0 end
  target.UnitEffectiveLevel = target.UnitLevel
  target.UnitRace = function() return "Human", "Human", 1 end
  target.UnitSex = function() return 2 end
  target.UnitFactionGroup = function() return "Alliance", "Alliance" end
  target.UnitIsUnit = function(a, b)
    local unitA, unitB = Units.Get(a), Units.Get(b)
    return unitA ~= nil and unitA == unitB
  end
  target.UnitIsPlayer = function(token) return Read(token, "isPlayerControlled") == true end
  target.UnitPlayerControlled = target.UnitIsPlayer
  target.UnitCanAttack = function(_, token) return Read(token, "canAttack") == true end
  target.UnitIsFriend = function(_, token) return Units.Get(token) ~= nil and not Read(token, "canAttack") end
  target.UnitIsEnemy = function(_, token) return Read(token, "canAttack") == true end
  target.UnitReaction = function(_, token) return Read(token, "canAttack") and 2 or 5 end
  target.UnitIsDeadOrGhost = function(token) return Read(token, "dead") == true end
  target.UnitIsDead = target.UnitIsDeadOrGhost
  target.UnitIsConnected = function(token) return Units.Get(token) ~= nil end
  target.UnitIsVisible = target.UnitIsConnected
  target.UnitAffectingCombat = function() return Units.restricted end
  target.UnitInParty = function() return false end
  target.UnitInRaid = function() return nil end
  target.IsInGroup = function() return false end
  target.IsInRaid = function() return false end
  target.GetNumGroupMembers = function() return 0 end
  target.GetNumSubgroupMembers = function() return 0 end
  target.UnitHealth = function(token)
    local value = Read(token, "health")
    return value and Secret.Wrap(value)
  end
  target.UnitHealthMax = function(token)
    local value = Read(token, "healthMax")
    if value and not Read(token, "isPlayerControlled") then
      return Secret.Wrap(value)
    end
    return value
  end
  target.UnitPower = function(token)
    local value = Read(token, "power")
    return value and Secret.Wrap(value)
  end
  target.UnitPowerMax = function(token)
    local value = Read(token, "powerMax")
    if value and not Read(token, "isPlayerControlled") then
      return Secret.Wrap(value)
    end
    return value
  end
  target.UnitPowerType = function(token) return Read(token, "powerType") or 0, "RAGE" end
end

return Units

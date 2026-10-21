-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local AuraDisplay = Private.BlizzardAuraDisplay
local Shared = Private.AuraSingleShared
local AnchorsToUnitFrame = Shared.AnchorsToUnitFrame
local BAD = Shared.BAD
local CAUTION = Shared.CAUTION
local FindCondition = Shared.FindCondition
local FirstProblem = Shared.FirstProblem
local GOOD = Shared.GOOD
local IsTable = Shared.IsTable
local Paint = Shared.Paint
local UsesRemaining = Shared.UsesRemaining
local WantsMissing = Shared.WantsMissing

local function NeedsIconForGlow(auraData)
  if auraData.regionType == "icon" then return end
  local conditionEntry = FindCondition(auraData, function(check, owner)
    if check.variable ~= "faAuraRemaining" and check.variable ~= "faAuraElapsed" then return false end
    if not AuraDisplay.NativeConditionKind(auraData, check) then return false end
    for _, change in ipairs(owner.changes or {}) do
      if IsTable(change) and AuraDisplay.IsGlowProperty(auraData, change.property) then return true end
    end
    return false
  end)
  if conditionEntry then return "A Remaining Time or Elapsed Time glow needs an Icon display." end
end

local function WrongCountdownCondition(auraData)
  local conditionEntry = FindCondition(auraData, function(check)
    return AuraDisplay.NativeConditionKind(auraData, check) and AuraDisplay.IsNativeDurationCondition(check)
      and check.variable ~= "faAuraRemaining"
  end)
  return conditionEntry ~= nil
end

local function PlacementProblem(auraData, auraTrigger, window)
  local label = window and "Remaining Time" or ("Show On: " .. AuraDisplay.showOnValues[AuraDisplay.RawShowOn(auraTrigger)])
  return FirstProblem({
    { window and auraData.regionType ~= "icon", label .. " is available for Icon displays. Use Show On: Aura(s) Found for other display types." },
    { not window and not AuraDisplay.missingTypes[auraData.regionType], label .. " is available for Icon, Bar, Progress Texture and Text displays." },
    { AnchorsToUnitFrame(auraData), label .. " cannot anchor to unit frames or nameplates. Anchor the aura to the screen or a frame." },
  })
end

local function SingleUnitProblem(auraData, auraTrigger)
  if not AuraDisplay.IsSingleUnit(auraTrigger) then
    return "Aura(s) Missing, Always and Remaining Time watch one unit: choose Player, Target, Focus, Pet, Target of Target, Target of Focus or a Specific Unit."
  end
  local window = AuraDisplay.RemainingWindow(auraTrigger) ~= nil
  if UsesRemaining(auraTrigger) and not window then
    return "Remaining Time: pick a comparison and a seconds value of 0 or more."
  end
  if WantsMissing(auraTrigger) or window then
    local fault = PlacementProblem(auraData, auraTrigger, window)
    if fault then return fault end
  end
  if WantsMissing(auraTrigger) and auraTrigger.debuffType == "HARMFUL" and (auraTrigger.unit == "player" or auraTrigger.unit == "pet")
    and (AuraDisplay.UsesSpellIDs(auraTrigger) or AuraDisplay.UsesRankSpellIDs(auraTrigger)) and not AuraDisplay.UsesApproximate(auraTrigger) then
    return "In combat, the client hides your own and your pet's debuffs from spell ID lookup. Enable Approximate Match."
  end
  if window then
    if not (AuraDisplay.SupportsDurationColorCondition and AuraDisplay.SupportsDurationColorCondition()) then
      return "Remaining Time filtering is not available on this client."
    end
    if WrongCountdownCondition(auraData) then
      return "Countdown conditions used with Remaining Time must compare Remaining Time in seconds."
    end
  end
end

local VALIDATION_STEPS = {
  function(auraData, auraTrigger) return AuraDisplay.TotalFilterProblem(auraData, auraTrigger) end,
  function(auraData, auraTrigger) return AuraDisplay.StackFilterProblem(auraData, auraTrigger) end,
  function(auraData, auraTrigger) return AuraDisplay.RemainingGateProblem(auraData, auraTrigger) end,
  function(auraData) return AuraDisplay.FallbackProblem(auraData) end,
  function(auraData) return NeedsIconForGlow(auraData) end,
  function(auraData, auraTrigger)
    if AuraDisplay.IsSingle(auraTrigger, auraData) then return SingleUnitProblem(auraData, auraTrigger) end
  end,
}

function AuraDisplay.ValidateSingle(auraData, auraTrigger)
  for _, step in ipairs(VALIDATION_STEPS) do
    local fault = step(auraData, auraTrigger)
    if fault then return fault end
  end
end

local function Failure(message)
  return Paint(BAD, "Won't work:") .. " " .. message
end

local function ApproximateNote(auraData, auraTrigger)
  local _, _, origin, fault = AuraDisplay.GateRange(auraData, auraTrigger)
  if origin and not fault then return "Approximate match, may not be exact." end
  return "Approximate match: shorter debuffs can match too."
end

local function GlowNote(auraData, auraTrigger)
  local edge, _, _, _, elapsed = AuraDisplay.LateGlowSpec(auraData, auraTrigger)
  if not edge then return end
  local lateTotal = AuraDisplay.LateGlowTotal(auraTrigger)
  if not (lateTotal and (elapsed or lateTotal > edge)) then return "Glow starts once the aura's duration is known." end
end

function AuraDisplay.TriggerStatus(auraData, auraTrigger)
  local fault = AuraDisplay.Validate(auraData)
  if fault then return Failure(fault) end
  local severity, reason = AuraDisplay.SpellIDFilterNote(auraTrigger)
  if severity == "error" then return Failure(reason) .. " " .. Paint(CAUTION, "Sounds in Actions still play.") end
  local notes = {}
  if AuraDisplay.UsesApproximate(auraTrigger) then
    if not AuraDisplay.ApproximateProfile(auraTrigger) then
      return Failure("the duration of this debuff is not known yet. Add a Total Duration filter.")
    end
    notes[#notes + 1] = ApproximateNote(auraData, auraTrigger)
  end
  if severity == "note" then
    notes[#notes + 1] = auraTrigger.debuffType == "HARMFUL" and "Hostile units only." or "Friendly units only."
  end
  if AuraDisplay.InDynamicGroup(auraData) then
    notes[#notes + 1] = "In a Dynamic Group this display keeps a fixed position. A Modern Aura Group lays it out properly."
  end
  notes[#notes + 1] = GlowNote(auraData, auraTrigger)
  local caption = Paint(GOOD, "Fully usable in combat.")
  for _, note in ipairs(notes) do caption = caption .. " " .. Paint(CAUTION, note) end
  return caption
end

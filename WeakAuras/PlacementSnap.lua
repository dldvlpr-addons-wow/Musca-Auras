-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Snap of a moved or resized aura, shared by the mover of /wa (MoverSizer.lua, an option file loaded on demand) and the
-- Edit Mode boxes (EditModePlacement.lua). Pure calculations on positions in UIParent units, no frame: the lines on one
-- axis, the shift that puts an edge of the aura on a line, and the choice of the best line.
-- A line is { position = number, gridLine = boolean, references = { { id, side, pos1, pos2 } } }: a grid line is a
-- screen, middle or grid line; the others are edges or centers of other auras, with the span they cover.
local PlacementSnap = {}
Private.PlacementSnap = PlacementSnap

local abs, floor, max, min = math.abs, math.floor, math.max, math.min

local mirrorSides = { LEFT = "RIGHT", RIGHT = "LEFT", TOP = "BOTTOM", BOTTOM = "TOP", CENTERX = "CENTERX",
  CENTERY = "CENTERY" }
-- The sides that bound the span of a line, across its direction.
local spanSides = { LEFT = { "BOTTOM", "TOP" }, RIGHT = { "BOTTOM", "TOP" }, CENTERX = { "BOTTOM", "TOP" },
  TOP = { "LEFT", "RIGHT" }, BOTTOM = { "LEFT", "RIGHT" }, CENTERY = { "LEFT", "RIGHT" } }

function PlacementSnap.NewLine(position, gridLine)
  return { position = position, gridLine = gridLine, references = {} }
end

--- Positions on one axis of the screen edges, 0 and length, and with a spacing the grid lines through center.
function PlacementSnap.ScreenLines(length, center, spacing)
  local positions = { 0, length }
  if spacing then
    for step = -floor(center / spacing), floor((length - center) / spacing) do
      positions[#positions + 1] = center + step * spacing
    end
  end
  return positions
end

--- Adds the lines of another aura, rect = { left, bottom, right, top, centerX, centerY }, any of them nil when
--- unknown: its edges, or with centers its centers only. NewLine(position, gridLine) makes the line.
function PlacementSnap.AddAuraLines(verticalLines, horizontalLines, id, rect, centers, addVertical, addHorizontal,
                                    NewLine)
  local left, bottom, right, top, centerX, centerY = unpack(rect, 1, 6)
  local function Add(lines, position, side, pos1, pos2)
    if position and pos1 and pos2 then
      local line = NewLine(position, false)
      table.insert(line.references, { id = id, side = side, pos1 = pos1, pos2 = pos2 })
      lines[#lines + 1] = line
    end
  end
  if centers then
    if addVertical then Add(verticalLines, centerX, "CENTERX", bottom, top) end
    if addHorizontal then Add(horizontalLines, centerY, "CENTERY", left, right) end
  else
    if addVertical then
      Add(verticalLines, left, "LEFT", bottom, top)
      Add(verticalLines, right, "RIGHT", bottom, top)
    end
    if addHorizontal then
      Add(horizontalLines, top, "TOP", left, right)
      Add(horizontalLines, bottom, "BOTTOM", left, right)
    end
  end
end

--- Sorts the aura lines and merges the ones under one unit apart, at their mean position.
function PlacementSnap.MergeLines(lines)
  table.sort(lines, function(a, b) return a.position < b.position end)
  local result = {}
  local first, sum, count
  for index = 1, #lines + 1 do
    local line = lines[index]
    if first and (not line or line.position - first.position >= 1) then
      first.position = sum / count
      result[#result + 1] = first
      first = nil
    end
    if line then
      if first then
        table.insert(first.references, line.references[1])
        sum, count = sum + line.position, count + 1
      else
        first, sum, count = line, line.position, 1
      end
    end
  end
  return result
end

--- Score of a line for an aura at positions (LEFT, RIGHT, TOP, BOTTOM, CENTERX, CENTERY): 0 for a grid line, more
--- for an aura line, the most for the same side as the edge it snaps and an aura near across.
function PlacementSnap.Score(line, positions, maxDistance)
  if line.gridLine then
    return 0
  end
  local score = -1
  for _, ref in ipairs(line.references) do
    local auraPos = positions[ref.side]
    local mirrorPos = positions[mirrorSides[ref.side]]
    if auraPos then
      local dist = abs(auraPos - line.position)
      if dist < maxDistance then
        -- Same side: heavily preferred to the lines of other sides.
        score = max(score, 100 + (maxDistance - dist))
      elseif mirrorPos then
        dist = abs(mirrorPos - line.position)
        score = max(score, 10 + (maxDistance - dist))
      end
      -- Up to 80 points for a reference near across.
      local span = spanSides[ref.side]
      local auraPos1, auraPos2 = positions[span[1]], positions[span[2]]
      if auraPos1 and auraPos2 then
        local minDistanceOrth = min(abs(auraPos1 - ref.pos1), abs(auraPos2 - ref.pos2))
        if minDistanceOrth < 10 * maxDistance then
          score = score + 8 * (10 * maxDistance - minDistanceOrth)
        end
      end
    end
  end
  return score
end

--- Lines in reach of one of the given edges, each with delta, the shift that puts its nearest edge on it.
--- lines is any table of lines; isCandidate[line] is true for the returned ones.
function PlacementSnap.Candidates(lines, maxDistance, ...)
  local candidates, isCandidate = {}, {}
  for _, line in pairs(lines) do
    local delta
    for i = 1, select("#", ...) do
      local edge = select(i, ...)
      if edge and abs(line.position - edge) < maxDistance
        and (not delta or abs(line.position - edge) < abs(delta)) then
        delta = line.position - edge
      end
    end
    if delta then
      line.delta = delta
      candidates[#candidates + 1] = line
      isCandidate[line] = true
    end
  end
  return candidates, isCandidate
end

--- Best of the candidates: the highest score, the nearest line between equal scores. nil without candidates.
function PlacementSnap.Best(candidates, positions, maxDistance)
  if #candidates == 1 then
    return candidates[1]
  end
  local bestScore, bestLine = -1, nil
  for _, line in ipairs(candidates) do
    local score = PlacementSnap.Score(line, positions, maxDistance)
    if score > bestScore or (score == bestScore and bestLine and abs(line.delta) < abs(bestLine.delta)) then
      bestScore, bestLine = score, line
    end
  end
  return bestLine
end

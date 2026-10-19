-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- Pixel perfect option: the regions turn off the snapping of their textures to the pixel grid, so that progress and
-- slides stay smooth, at the cost of blurred edges. data.pixelPerfect snaps every texture of the aura again. Off by
-- default: turning it on for all would move existing auras by up to one pixel.

-- Snapping of a texture before the option touched it, to give it back when the option is turned off.
local originalSnapping = setmetatable({}, { __mode = "k" })

local function SnapTextures(frame, snap)
  for _, layered in ipairs({ frame:GetRegions() }) do
    if layered.SetSnapToPixelGrid then
      local original = originalSnapping[layered]
      if snap then
        if not original then
          originalSnapping[layered] = { layered:IsSnappingToPixelGrid(), layered:GetTexelSnappingBias() }
        end
        layered:SetSnapToPixelGrid(true)
        layered:SetTexelSnappingBias(0)
      elseif original then
        layered:SetSnapToPixelGrid(original[1])
        layered:SetTexelSnappingBias(original[2])
        originalSnapping[layered] = nil
      end
    end
  end
  for _, child in ipairs({ frame:GetChildren() }) do
    -- Another aura parented to this one, a group child, follows its own option. A glow draws with textures that
    -- LibCustomGlow shares with every aura and addon through its pools, snapping them would leak to the others.
    if child.id == nil and child.glowStart == nil then
      SnapTextures(child, snap)
    end
  end
end

--- Snaps the textures of a region to the pixel grid when its aura asks for it, gives them back otherwise.
function Private.ApplyPixelSnapping(region, data)
  region.pixelPerfect = data.pixelPerfect == true
  -- Nothing to snap nor to give back while no aura ever used the option.
  if data.controlledChildren or data.pixelPerfect ~= true and next(originalSnapping) == nil then
    return
  end
  SnapTextures(region, data.pixelPerfect == true)
end

--- Snaps the textures of a frame created after its aura was loaded: extra bars, aura buttons made by Blizzard. The
--- region is the aura the frame draws for, by default the nearest aura region among its parents.
function Private.SnapLateTextures(frame, region)
  region = region or frame
  while region and region.id == nil do
    region = region:GetParent()
  end
  if region and region.pixelPerfect then
    SnapTextures(frame, true)
  end
end

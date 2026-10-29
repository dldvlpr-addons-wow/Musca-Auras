local Utility = dofile("Tests/Packs/Utility/UtilityPackBuilder.lua")
local Parts = Utility.Parts

-- A small dot at the center of the screen, in combat, to keep track of your character in a crowded fight.
local pack = Utility.New("Center Mark", "muUtilCenterMarkV1", {})

local always = Parts.Generic({ type = "unit", event = "Conditions", use_alwaystrue = true })
local data = pack.Add("Dot", "texture", { always }, { inCombat = true })
data.texture = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Circle_White"
data.width, data.height, data.color, data.blendMode = 8, 8, {1, 1, 1, 0.8}, "BLEND"
data.desaturate, data.rotation, data.mirror, data.rotate = false, 0, false, false

return pack.Finish()

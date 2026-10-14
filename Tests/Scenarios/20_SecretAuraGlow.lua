-- SecretAuraGlow: each glow type builds its parts, clear hides them, same settings reuse them.
return function(test)
  local private = test.Loader.LoadAddon(test.tocPath, "WeakAuras", {})
  test.Environment.Advance(1)
  local Display = private.BlizzardAuraDisplay

  local shown, added = {}, 0
  local button = {
    AddAuraShownAnimation = function(_, group)
      assert(not shown[group], "animation added twice")
      shown[group] = true
      added = added + 1
    end,
    RemoveAuraShownAnimation = function(_, group) shown[group] = nil end,
  }
  local parent = CreateFrame("Frame")

  local function Style(entry, element)
    Display.StyleElementGlow(entry, button, parent, parent, element, 40, 40)
    return entry.nativeGlow
  end

  local entry = {}
  assert(Style(entry, { glow = false }) == nil, "glow built while disabled")

  local cancelled = {}
  assert(Style(cancelled, { glow = true }) == nil, "first glow of a live button built at once")
  Display.ClearElementGlow(cancelled)
  assert(Style(entry, { glow = true, glowXOffset = 5 }) == nil, "first glow of a live button built at once")
  test.Environment.Advance(0.1)
  assert(cancelled.nativeGlow == nil, "cleared pending glow built")
  local proc = entry.nativeGlow
  assert(proc and #proc.textures == 1 and #proc.groups == 1, "Proc parts")
  assert(proc.textures[1]:GetAtlas() == "UI-HUD-ActionBar-Proc-Loop-Flipbook", "Proc atlas")
  assert(proc.groups[1]:IsPlaying() and shown[proc.groups[1]], "Proc animation not playing")
  local point, relativeTo, relativePoint = proc.holder:GetPoint(1)
  assert(point == "CENTER" and relativeTo == parent and relativePoint == "CENTER", "holder anchor")
  assert(proc.holder:GetWidth() == 50 and proc.holder:GetHeight() == 40, "holder size with offset")

  Display.ClearElementGlow(entry)
  assert(entry.nativeGlow == nil and entry.keptGlow == proc, "clear did not keep the glow")
  assert(not proc.groups[1]:IsPlaying() and not shown[proc.groups[1]], "cleared animation still playing")
  assert(not proc.holder:IsShown() and not proc.textures[1]:IsShown(), "cleared glow still shown")

  assert(Style(entry, { glow = true, glowXOffset = 5 }) == proc, "same settings rebuilt the glow")
  assert(proc.groups[1]:IsPlaying() and proc.holder:IsShown(), "restored glow not shown")
  local addedBefore = added
  assert(Style(entry, { glow = true, glowXOffset = 5 }) == proc and added == addedBefore, "unchanged glow added again")
  assert(proc.groups[1]:IsPlaying() and shown[proc.groups[1]], "kept glow not playing")

  local colored = Style(entry, { glow = true, useGlowColor = true, glowColor = { 0.1, 0.2, 0.3, 1 } })
  assert(colored ~= proc and colored.holder == proc.holder, "new settings not rebuilt, or holder not reused")
  local r, g, b = colored.textures[1]:GetVertexColor()
  assert(colored.textures[1]:IsDesaturated() and r == 0.1 and g == 0.2 and b == 0.3, "glow color")

  local overlay = Style(entry, { glow = true, glowType = "buttonOverlay" })
  assert(#overlay.textures == 2 and #overlay.groups == 1, "buttonOverlay parts")

  local pixel = Style(entry, { glow = true, glowType = "Pixel", glowLines = 3 })
  assert(#pixel.frames == 4, "Pixel edges: " .. #pixel.frames)
  assert(#pixel.textures == 12 and #pixel.groups == 12, ("Pixel lines: %d textures, %d groups"):format(#pixel.textures, #pixel.groups))

  local thicker = Style(entry, { glow = true, glowType = "Pixel", glowLines = 3, glowThickness = 4 })
  assert(thicker ~= pixel and thicker.textures[12] == pixel.textures[12] and thicker.frames[4] == pixel.frames[4], "Pixel parts not reused")
  assert(#thicker.textures == 12 and thicker.textures[1]:IsShown(), "reused Pixel parts not shown")

  local shine = Style(entry, { glow = true, glowType = "Shine" })
  assert(#shine.textures == 4 and #shine.groups == 8, "Shine parts")
  assert(not pixel.textures[1]:IsShown() and not pixel.frames[1]:IsShown(), "Pixel parts left shown")

  Display.ClearElementGlow(entry)
  for group in pairs(shown) do
    error("animation left on the button: " .. tostring(group))
  end
end

-- Musca Auras, original work by dldvlpr, GPL-2.0. See CHANGES.md.
if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

-- The SLUG renderer draws its own outline: a drop shadow on top of it doubles the glyphs.
local shadowlessFlags = { ["OUTLINE|SLUG"] = true, ["THICKOUTLINE|SLUG"] = true }

local ownedFonts = setmetatable({}, { __mode = "k" })
local createdFonts = 0

local function OwnedFont(text)
  local font = ownedFonts[text]
  if not font then
    createdFonts = createdFonts + 1
    font = CreateFont("WeakAuras-NativeText-Font" .. createdFonts)
    ownedFonts[text] = font
  end
  return font
end

function Private.ApplyTextFont(text, fontObject, fontPath, size, flags, shadowColor, shadowX, shadowY)
  flags = flags or ""
  local font = fontObject or OwnedFont(text)
  if shadowlessFlags[flags] then
    shadowX, shadowY = 0, 0
  end
  font:SetFont(STANDARD_TEXT_FONT, size, flags)
  font:SetShadowColor(unpack(shadowColor))
  font:SetShadowOffset(shadowX, shadowY)

  text:SetFontObject(font)
  text:SetFont(fontPath, size, flags)
  if text:GetFont() then
    return
  end
  if fontPath then
    font:SetFont(fontPath, size, flags)
    text:SetFontObject(font)
    if text:GetFont() then
      return
    end
  end
  text:SetFont(STANDARD_TEXT_FONT, size, flags)
end

if not WeakAuras.IsLibsOK() then return end
local _, Private = ...

local sharedFonts = setmetatable({}, {__mode = "k"})
local createdFonts = 0
local slugFlags = {
  ["OUTLINE|SLUG"] = true,
  ["THICKOUTLINE|SLUG"] = true,
}

local function ResolveFontObject(text, given)
  if given then
    return given
  end
  local cached = sharedFonts[text]
  if not cached then
    createdFonts = createdFonts + 1
    cached = CreateFont("WeakAuras-NativeText-Font" .. createdFonts)
    sharedFonts[text] = cached
  end
  return cached
end

local function ConfigureFontObject(object, size, flags, shadowColor, shadowX, shadowY)
  object:SetFont(STANDARD_TEXT_FONT, size, flags)
  object:SetShadowColor(unpack(shadowColor))
  if slugFlags[flags] then
    shadowX, shadowY = 0, 0
  end
  object:SetShadowOffset(shadowX, shadowY)
end

function Private.ApplyTextFont(text, fontObject, fontPath, size, flags, shadowColor, shadowX, shadowY)
  local object = ResolveFontObject(text, fontObject)
  ConfigureFontObject(object, size, flags, shadowColor, shadowX, shadowY)
  text:SetFontObject(object)
  text:SetFont(fontPath, size, flags)

  if text:GetFont() then
    return
  end
  if fontPath then
    object:SetFont(fontPath, size, flags)
    text:SetFontObject(object)
  end
  if not text:GetFont() then
    text:SetFont(STANDARD_TEXT_FONT, size, flags)
  end
end

-- The version and date shown in the What's New window match the first heading of WeakAuras/CHANGELOG.md, the one
-- the release workflow checks against the tag.
local function ReadFile(path)
  local file = assert(io.open(path, "rb"))
  local text = file:read("*a")
  file:close()
  return text
end

return function()
  local heading = ReadFile("WeakAuras/CHANGELOG.md"):match("^[^\n]*")
  local headingVersion, headingDate = heading:match("^# Musca Auras (%S+) %((%d%d%d%d%-%d%d%-%d%d)%)")
  assert(headingVersion, "unexpected first heading of WeakAuras/CHANGELOG.md: " .. heading)

  local changelog = ReadFile("WeakAurasOptions/Changelog.lua")
  local versionString = changelog:match("versionString = '([^']*)'")
  local dateString = changelog:match("dateString = '([^']*)'")
  assert(versionString == headingVersion,
    "Changelog.lua versionString " .. tostring(versionString) .. " ~= CHANGELOG.md " .. headingVersion)
  assert(dateString == headingDate,
    "Changelog.lua dateString " .. tostring(dateString) .. " ~= CHANGELOG.md " .. headingDate)

  -- The TOC versions are the ones the player sees in the addon list.
  for _, toc in ipairs({ "WeakAuras/WeakAuras.toc", "WeakAurasArchive/WeakAurasArchive.toc",
                         "WeakAurasModelPaths/WeakAurasModelPaths.toc", "WeakAurasOptions/WeakAurasOptions.toc",
                         "WeakAurasTemplates/WeakAurasTemplates.toc" }) do
    local tocVersion = ReadFile(toc):match("\n## Version: *([^%s]+)")
    assert(tocVersion == headingVersion,
      toc .. " version " .. tostring(tocVersion) .. " ~= CHANGELOG.md " .. headingVersion)
  end
end

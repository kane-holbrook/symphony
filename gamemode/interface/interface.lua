AddCSLuaFile()

Interface = {}

include("2d/xml.lua")
include("2d/fonts.lua")
include("2d/basepanel.lua")
include("2d/rect.lua")
include("2d/text.lua")
include("2d/img.lua")

if SERVER then
    return
end
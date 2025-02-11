AddCSLuaFile()

Interface = {}

include("2d/gradients.lua")
include("2d/fonts.lua")
include("2d/vgui.lua")
include("2d/base.lua")
include("2d/rect.lua")
include("2d/xml.lua")
--include("2d/fonts.lua")
--include("2d/basepanel.lua")
--include("2d/rect.lua")
--include("2d/text.lua")
--include("2d/img.lua")
--include("2d/window.lua")

if SERVER then
    return
end

--[[
    PANEL - as a type of Interface
]]
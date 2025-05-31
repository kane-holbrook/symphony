AddCSLuaFile()

Interface = {}

include("2d/xml.lua")
include("2d/gradients.lua")
include("2d/fonts.lua")
include("2d/basepanel.lua")
include("2d/rect.lua")
include("2d/text.lua")
include("2d/img.lua")
include("2d/window.lua")
include("2d/button.lua")
include("2d/hr.lua")

if SERVER then
    return
end


if IsValid(p) then
    p:Remove()
end
p = Interface.CreateFromXML(nil, [[
    <Img 
        Width="100%" 
        Height="100%" 
        Material="sstrp25/ui/views/intro/backdrop.png" 
        FillColor="255, 255, 255, 255"
        Flex="5"
    >
        <Window Closeable="true" Moveable="true" X="25%" Y="10%" Width="50%" Height="75%" Title="Interface test">
            <Text Content="Welcome to SSTRP." /> 
        </Window>
    </Img>
]])
print(p)

--[[
    PANEL - as a type of Interface
]]
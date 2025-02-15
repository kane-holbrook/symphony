AddCSLuaFile()

Interface = {}

include("2d_v2/fonts.lua")
include("2d_v2/base.lua")
include("2d_v2/gradients.lua")
include("2d_v2/vgui.lua")
include("2d_v2/gradients.lua")
include("2d_v2/rect.lua")
include("2d_v2/xml.lua")

if SERVER then
    return
end


if IsValid(p) then
    p:Remove()
end
p = Interface.CreateFromXML(nil, [[
    <Panel Test="Hello World" X="25%" Y="25%" Width="50%" Height="50%">
        <Panel Ref="top" :X="Parent.Width/2 - Width/2" :Y="Parent.Height/2 - Height/2" Width="128" Height="128" Fill="yellow">
            <Panel Fill="red" Ref="red" Width="1cw" Height="1cw" />     

        </Panel>
    </Panel>
]])

--[[

    <Rect>
        <Animate Property="Position" Repeat="true">
            <KeyFrame Time="0" Property="X" Value="0" />
            <KeyFrame Time="3" Property="X" Value="100" />
        </Animate>
    </Rect>
]]
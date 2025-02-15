AddCSLuaFile()

Interface = {}

include("2d_v2/fonts.lua")
include("2d_v2/vgui.lua")
include("2d_v2/base.lua")
include("2d_v2/gradients.lua")
include("2d_v2/label.lua")
include("2d_v2/xml.lua")

if SERVER then
    return
end


if IsValid(p) then
    p:Remove()
end
p = Interface.CreateFromXML(nil, [[
    <Gradient X="25%" Y="25%" Width="100" Height="100" Align="1" PaddingLeft="1" PaddingRight="1" PaddingTop="1" PaddingBottom="1" Start="0, 0, 0, 255" Stop="0, 0, 255, 255" Mid="0.5">
        <Rect Fill="red" Width="25%" Height="100%" />
        <Rect Fill="green" Grow="true" Height="100%" />
    </Gradient>
]])

--[[

    <Rect>
        <Animate Property="Position" Repeat="true">
            <KeyFrame Time="0" Property="X" Value="0" />
            <KeyFrame Time="3" Property="X" Value="100" />
        </Animate>
    </Rect>
]]
AddCSLuaFile()

Interface = {}

include("2d_v2/base.lua")
include("2d_v2/fonts.lua")
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
    <Panel :X="Parent.Width/2 - Width/2" :Y="Parent.Height/2 - Height/2" Width="1024" Height="1024">
        <Panel :X="Parent.Width/2 - Width/2 + (math.cos(math.rad(CurTime()*200)) * Parent.Height/4)" :Y="Parent.Height/2 - Height/2 + (math.sin(math.rad(CurTime()*200)) * Parent.Height/4)" Width="128" Height="128" Fill="#ffff00ff">
            <Listen Event="Paint" Properties="X,Y" />
        </Panel>
    </Panel>
]])
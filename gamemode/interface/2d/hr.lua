AddCSLuaFile()
if SERVER then
    return 
end

--[[
    Close button
    Wrap text
    Moveable
    Size handles
    Scrollbar
]]
local PANEL = Interface.RegisterFromXML("hr", [[
    <Rect Root="true" Width="100%" Height="2.5ssh" PaddingX="8" MarginY="4" Direction="Y">
        <Img Material="sstrp25/ui/window-hazard.png" Width="100%" Height="100%" Repeat="true" Scale="0.04" Radius="1" Color="255, 255, 255, 22" />
    </Rect>
]])

function PANEL:Init()
    Interface.Apply(self)
    self:LoadXML()
end
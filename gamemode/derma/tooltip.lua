AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Tooltip", [[
    <Rect>
        <XLabel :Text="isstring(Label) and Label" />
        <Popover Slot="Default">
        </Popover>   
    </Rect>
]])
function PANEL:Init()
    self:LoadXML()
end
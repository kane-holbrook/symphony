AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Tree", [[
    <Rect Ref="Top" Flex="4" :Depth="Parent.Depth and Parent.Depth + 1 or 0">
        <Rect Slot="Default" :MarginLeft="ScreenScale(Depth or 0)" />
    </Rect>    
]])
function PANEL:Init()
    self:LoadXML()
end

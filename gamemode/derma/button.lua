AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("Button", [[
    <Rect 
        Hover="true" 
        Cursor="hand" 
        PaddingX="5ss" 
        PaddingY="2ss" 
        StrokeWidth="1" 
        Radius="2ss"
        StrokeColor="Color(255, 255, 255, 16)" 
        Fill="Material(sstrp25/ui/hex.png)"
        FillColor="Color(146, 183, 196, 255)" 
        FillRepeatX="true" 
        FillRepeatY="true" 
        FillRepeatScale="0.1"
        Hover:StrokeColor="Color(255, 255, 255, 64)"
        OverrideAlpha="32"
        Flex="4"
        Gap="1ss"
        FontSize="12"
        FontWeight="800"
        FontColor="Color(182, 208, 216, 255)" 
        FontName="Rajdhani" 
    >
    </Rect>
]])
function PANEL:Init()
    self:LoadXML()
end

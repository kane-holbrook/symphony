AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Radio", [[
    <Rect Ref="RadioButton`" Height="1.25ch" Flex="4" Hover="true" Cursor="hand" Checked="false" :On:Click="function (...)
        self:Emit('Change:Value', true)
        self:InvalidateLayout()
        return true
    end">
        <Rect Ref="Mid"
            Height="1ph"
            Width="1ph"
            StrokeWidth="1" 
            Radius="0.5ph"
            StrokeColor="Color(255, 255, 255, 16)" 
            Fill="Material(sstrp25/ui/window-hazard.png)"
            FillColor="Color(158, 200, 213, 16)" 
            FillRepeatX="true" 
            FillRepeatY="true" 
            FillRepeatScale="0.01"
            Hover:StrokeColor="Color(255, 255, 255, 64)"
            Hover:FillColor="Color(158, 200, 213, 64)"
            Flex="5"
            Gap="1ss"
            :FontSize="(PH * (ScrH()/480))/8"
            FontWeight="800"
            MarginRight="2cw"
        >
            <Rect Ref="RadioBox" Width="0.5pw" Height="0.5ph" Radius="0.25ph" :FillColor="Selected and Color(192, 192, 192, 192) or color_transparent" :Hover:FillColor="Selected and Color(255, 255, 255, 255) or color_transparent" />
        </Rect>

        <XLabel :Text="Label or ''" />
    </Rect>    
]])
function PANEL:Init()
    self:LoadXML()

    radio = self
end

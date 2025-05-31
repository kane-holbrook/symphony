AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Checkbox", [[
    <Rect Height="1.25ch" Flex="4" Hover="true" Cursor="hand" Value="false" :On:Click="function (...)
        if not isfunction(self:GetProperty('Value', true)) then
            self:SetProperty('Value', not self:GetProperty('Value', true))
        end
        self:Emit('Change:Value', self, self:GetProperty('Value', true))
        self:InvalidateLayout()
        return true
    end">
        <Rect Ref="Top" 
            Height="1ph"
            Width="1ph"
            StrokeWidth="1" 
            Radius="2ss"
            StrokeColor="Color(255, 255, 255, 16)" 
            Fill="Material(sstrp25/ui/window-hazard.png)"
            FillColor="Color(158, 200, 213, 16)" 
            FillRepeatX="true" 
            FillRepeatY="true" 
            FillRepeatScale="0.01"
            Hover:StrokeColor="Color(255, 255, 255, 32)"
            Hover:FillColor="Color(158, 200, 213, 32)"
            Flex="5"
            Gap="1ss"
            :FontSize="(PH * (ScrH()/480))/7"
            FontWeight="800"
            MarginRight="2cw"
        >
            <XLabel :Text="Value and '✓' or ''" />
        </Rect>

        <XLabel :Text="isstring(Label) and Label or ''" />
    </Rect>    
]])
function PANEL:Init()
    self:LoadXML()
end

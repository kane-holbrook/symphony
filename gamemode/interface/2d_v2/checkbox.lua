AddCSLuaFile()
if SERVER then return end

local PANEL = Interface.RegisterFromXML("Checkbox", [[
    <Rect Height="1.25ch" Align="4" Hoverable="true" Cursor="hand" Value="false" On:Click="function (...)
        self:Click()
    end" On:Child:Click="function (...) self:Click() end">
        <Rect 
            Height="1ph"
            Width="1ph"
            StrokeWidth="1" 
            Radius="2ss"
            :StrokeColor="Hovered and Color(255, 255, 255, 64) or Color(255, 255, 255, 16)" 
            Fill="sstrp25/ui/window-hazard.png"
            :FillColor="Hovered and Color(158, 200, 213, 64) or Color(158, 200, 213, 16)" 
            FillRepeatX="true" 
            FillRepeatY="true" 
            FillRepeatScale="0.01"
            Align="5"
            Gap="1ss"
            :FontSize="(Parent.Height * (ScrH()/480))/10"
            FontWeight="800"
            MarginRight="1cw"
        >
            <Label :Text="Value and '✓' or ''">
                <Listen Event="Parent:Change:Value" Properties="Text" />
            </Label>
        </Rect>

        <Slot />
    </Rect>    
]])

PANEL:CreateProperty("Value", Type.Boolean)
PANEL:CreateProperty("Label", Type.String)

function PANEL.Prototype:Initialize()
    base(self, "Initialize")
    self:Setup()
end

function PANEL.Prototype:Click()
    self:SetValue(not self:GetValue())
    Event:Cancel()
end
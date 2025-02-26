AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("Picklist", [[
    <Rect Ref="Top"
        Cursor="hand" 
        Height="1.25ch"
        Hover="true"
        Width="1pw"
        StrokeWidth="1" 
        Radius="2ss"
        StrokeColor="Color(255, 255, 255, 16)" 
        Fill="Material(sstrp25/ui/window-hazard.png)"
        FillColor="Color(158, 200, 213, 16)" 
        FillRepeatX="true" 
        FillRepeatY="true" 
        FillRepeatScale="0.01"
        Flex="4"
        Gap="1ss"
        FontSize="12"
        FontWeight="800"
        FontColor="Color(182, 208, 216, 255)" 
        FontName="Rajdhani" 
        :Click="function ()
            self.Menu:Toggle()
        end"
        :On:Change:Value="function (el, value)
            self:SetProperty('Value', value)
            self:EmitParent('Change:Value', value)
            self.Menu:Close()
            self:InvalidateChildren(true)
            return true
        end"
    >
        
        <Rect Ref="Content" Grow="true"
            FontSize="8"
            Flex="4"
            FontColor="Color(182, 208, 216, 255)" 
            FontName="Rajdhani"
            FontWeight="500"
            PaddingLeft="2ss"
            PaddingRight="2ss">
            <XLabel :Text="Value" />
        </Rect>

        <Rect 
            Fill="Material(sstrp25/ui/picklist.png)" 
            FillColor="Color(158, 200, 213, 64)"
            Hover:FillColor="Color(158, 200, 213, 255)"
            Width="0.5ch" 
            Height="0.5ch" 
            MarginLeft="1.5cw"
            Cursor="hand"
            MarginRight="1.5cw"
        />

        <Popover 
            Ref="Menu" 
            Width="1pw" 
            Y="1ph"
            Blur="5"
            FillColor="Color(0, 0, 0, 230)"
            StrokeWidth="1"
            StrokeColor="Color(255, 255, 255, 16)"
            PaddingBottom="2ss"
            BottomLeftRadius="2ss"
            BottomRightRadius="2ss"
            Cursor="none"
            Slot="Default"
            Direction="Y"
            FontSize="8"
            FontWeight="500"
            FontColor="Color(182, 208, 216, 255)" 
            FontName="Rajdhani"
        >           
        </Popover>
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()

    Dropdown = self
end

function PANEL:OnPropertyChanged(key, value)
    if key == "Placeholder" then
        self.TextEntry:SetPlaceholderText(value)
    end
end



PANEL = xvgui.RegisterFromXML("PicklistEntry", [[
    <Rect 
        Hover="true" 
        Padding="2ss" 
        Width="1pw" 
        FillColor="Color(0, 0, 0, 0)" 
        Cursor="hand" 
        Hover:FillColor="Color(255, 255, 255, 8)"
        :Click="function ()
            self:Emit('Change:Value', self:GetValue())
        end"
    >
        <Rect Ref="Content" Slot="Default" />
    </Rect>
]])

function PANEL:GetValue()
    local c = self:GetChildren()[1]
    local v = c:GetProperty("Value", true)
    if v then
        return v
    else
        c = c:GetChildren()[1]
        if c then 
            return c:GetProperty("Text", true) 
        end
    end
end
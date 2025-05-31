AddCSLuaFile()
if SERVER then
    return 
end

local PANEL = Interface.RegisterFromXML("Button", [[
    <Rect Flex="5" Direction="Y" Root="true">
        <Rect Hover="true" Cursor="hand" Direction="Y" :Background="ButtonColor" Radius="2" FontWeight="800" Padding="0.25" Gap="0.25" Width="100%">
            <Rect Cursor="hand" Background="000000FF" TopLeftRadius="2" TopRightRadius="2" Width="100%" Height="3ssh">
                <Img Material="sstrp25/ui/window-hazard.png" TopLeftRadius="2" TopRightRadius="2" Repeat="true" Scale="0.04" Width="100%" Height="100%" :Color="ButtonColor" />
            </Rect>

            <Rect Flex="5" Slot="Default" Padding="2" FontWeight="800" :FontColor="ButtonColor" Grow="true" Direction="Y" Cursor="hand" Background="000000FF" BottomLeftRadius="2" BottomRightRadius="2" Height="15ssh" />
        </Rect>
    </Rect>
]])

function PANEL:Init()
    Interface.Apply(self)
    self:LoadXML()

    self:SetProperty("ButtonColor", Color(97, 148, 109))
end

function PANEL:OnPropertyChanged(name, value, old)
    if name == "Type" then
        value = string.lower(value)
        print(value)
        if value == "secondary" then
            self:SetProperty("ButtonColor", Color(174, 174, 174))
        elseif value == "tertiary" then
            self:SetProperty("ButtonColor", Color(97, 140, 148))
        elseif value == "destructive" then
            self:SetProperty("ButtonColor", Color(187, 97, 97))
        elseif value == "warning" then
            self:SetProperty("ButtonColor", Color(187, 187, 97))
        elseif value == "disabled" then
            self:SetProperty("ButtonColor", Color(68, 68, 68))
        else
            self:SetProperty("ButtonColor", Color(97, 148, 109))
        end
        self:InvalidateLayout()
    end
end
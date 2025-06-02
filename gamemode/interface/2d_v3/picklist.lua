AddCSLuaFile()
if SERVER then 
    return 
end
local Picklist = Interface.RegisterFromXML("Picklist", [[
    <Rect 
        Width="100%" 
        Height="2ch"
        Align="4"
        Hover="true" 
        Cursor="hand" 
        Stroke="Color(255, 255, 255, 16)"
        StrokeWidth="1" 
        Fill="White"
        :Material="RadialGradient(
            Color(0, 14, 30, 254),
            0.0,
            Color(0, 14, 30, 254),
            0.9,
            Color(0, 3, 10, 254)
        )" 
        
        :Shape="{
            0, 0,
            Width, 0, -- Top left corner
            Width, Height - ScreenScale(1), -- Top right corner
            Width - ScreenScale(1), Height, -- Bottom right corner
            ScreenScale(1), Height, -- Bottom left corner
            0, Height, -- Bottom left corner
        }"
        :DisplayValue="Value or ''"
        On:MousePressed="function ()
            self._Default:Toggle()
            return true
        end"
    >
        <Text Margin="2ss" :Content="tostring(DisplayValue)" :Width="Parent.Width - ScreenScale(11)" />
        <Text Content="▼" FontSize="5" :FontColor="IsHovered and color_white or Color(255, 255, 255, 32)" />

        <Popover OffsetY="1ph" :Width="Parent.Width - ScreenScale(1)" Interactive="true" Name="_Default" On:MousePressed="function (src) return Parent:OnSelect(src) end">
        </Popover>        
    </Rect>
]])
Picklist:CreateProperty("Value", Type.Any, {
    Default = nil
})
Picklist:CreateProperty("DisplayValue", Type.String)

function Picklist.Prototype:OnSelect(src)
    if src == self then
        return
    end

    local tgt = src
    while not tgt.Value do
        tgt = tgt:GetParent()
        
        if tgt == self then
            return
        end

        if tgt.Value then
            src = tgt
            break
        end
    end

    self:SetProperty("Value", src.Value)
    self:Emit("ValueChanged", src.Value)
    self._Default:SetDisplay(false)
    self:InvalidateLayout()
    return true
end


local PicklistEntry = Interface.RegisterFromXML("PicklistEntry", [[
    <Rect Width="100%" Padding="2ss" Hover="true" :Fill="IsHovered and Color(32, 32, 32, 255) or Color(0, 0, 0, 225)" Cursor="hand">
    </Rect>
]])
PicklistEntry:CreateProperty("Value")

function PicklistEntry.Prototype:PerformLayout()
    base(self, "PerformLayout")

    if not self:GetValue() then
        local children = self:GetChildren()
        assert(#children == 1, "PicklistEntry must have just text or a value defined.")

        local child = children[1]
        assert(child and child.GetContent, "PicklistEntry must have a Text element as its child.")

        self:SetValue(child:GetContent())
    end
end
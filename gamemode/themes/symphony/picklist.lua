AddCSLuaFile()
if SERVER then 
    return 
end
local Picklist = Theme.Symphony:RegisterFromXML("Picklist", [[
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
            Color(15, 2, 21, 254),
            0.9,
            Color(0, 3, 10, 254)
        )" 
        :DisplayValue="Value or ''"
        On:MousePressed="function ()
            self._Default:Toggle()
            return true
        end"
    >
        <Label Margin="2ss" :Text="tostring(DisplayValue)" :Width="Parent.Width - ScreenScale(11)" />
        <Label Text="▼" FontSize="5" :FontColor="IsHovered and color_white or Color(255, 255, 255, 32)" />

        <Popover OffsetY="1ph" :Width="Parent.Width" Interactive="true" Name="_Default" On:MousePressed="function (src) return Parent:OnSelect(src) end">
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


local PicklistEntry = Theme.Symphony:RegisterFromXML("PicklistEntry", [[
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
        assert(child and child.GetText, "PicklistEntry must have a Label element as its child.")

        self:SetValue(child:GetContent())
    end
end
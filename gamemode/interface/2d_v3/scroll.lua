AddCSLuaFile()
if SERVER then 
    return 
end

local SCROLL = Interface.RegisterFromXML("Scroll", [[
    <Rect 
        Width="100%" 
        Height="100%"
        Align="7"
        Gap="5ss"
        Flow="X"
    >
        <Rect Name="_Default" Absolute="true" X="0" Y="0" :Width="Parent.Width - ScreenScale(15)" Flow="Y" Align="7">
        </Rect>
        
        <Rect 
            Name="Bar"
            Absolute="true"
            :X="Parent.Width - ScreenScale(5)"
            Width="1.5ss"
            Height="100%"
            Fill="Color(255, 255, 255, 16)"
            Align="5"
        >
            <Rect Name="Track" Width="100%" :Height="Parent.Height - ScreenScale(5)" Cursor="hand">
                <Rect
                    Name="Handle"
                    Absolute="true"
                    X="0"
                    :Y="ScrollPosition"
                    Width="100%"
                    Height="5ss"
                    Hover="true"
                    :Fill="IsHovered and Color(255, 255, 255, 96) or Color(255, 255, 255, 32)"
                />
            </Rect>
        </Rect>
    </Rect>
]])
SCROLL:CreateProperty("ScrollPosition", Type.Number, {
    Default = 0
})

function SCROLL.Prototype:PerformLayout()
    base(self, "PerformLayout")


end

function SCROLL.Prototype:OnMouseWheeled(delta)

    local _, ch = self:GetChildrenSize()

    local track = self.Bar.Track
    local hndl = track.Handle

    local scrollPos = self:GetScrollPosition()
    scrollPos = math.Clamp(scrollPos - delta * 20, 0, track:GetHeight() - hndl:GetHeight()) -- Adjust the scroll speed as needed
    self:SetScrollPosition(scrollPos) -- Prevent scrolling above 0
    self:Emit("Scroll")
    self:InvalidateLayout(true)
    return true
end
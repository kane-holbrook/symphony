AddCSLuaFile()
if SERVER then
    return
end

local WINDOW = Theme.Default:RegisterFromXML("Window", [[
    <Rect 
        Absolute="true"
        X="25%" 
        Y="25%" 
        Width="50%" 
        Height="50%" 
        Fill="white" 
        FontFamily="Rajdhani"
        FontSize="8"
        :Material="RadialGradient(
            Color(0, 3, 10, 225),
            0.5,
            Color(0, 14, 30, 225),
            0.75,
            Color(0, 3, 10, 225)
        )" 
        Align="5" 
        Popup="true"
        Blur="4"
        :Shape="
        {
            0, Height - ScreenScale(5), -- Bottom left corner
            0, ScreenScale(5), -- Top left corner
            ScreenScale(5), ScreenScale(5),
            ScreenScale(10), 0, -- Top left corner
            Width - ScreenScale(10), 0, -- Top right corner
            Width - ScreenScale(5), ScreenScale(5),
            Width, ScreenScale(5),
            Width, Height - ScreenScale(5),

            Width - ScreenScale(5), Height,
            ScreenScale(5), Height
        }"
        Stroke="Color(0, 0, 0, 192)"
        StrokeWidth="1"
        Align="7"
        >
            <Rect 
                Name="_Default"
                Absolute="true"
                X="2ss"
                Y="2ss"
                Flow="Y"
                PaddingTop="7.5ss"
                PaddingLeft="10ss"
                PaddingRight="0"
                PaddingBottom="7.5ss"
                :Width="Parent.Width - ScreenScale(4)"
                :Height="Parent.Height - ScreenScale(4)"
                :Shape="
                CloseButton and
                {
                    0, Height - ScreenScale(5), -- Bottom left corner
                    0, ScreenScale(5), -- Top left corner
                    ScreenScale(5), ScreenScale(5),
                    ScreenScale(10), 0, -- Top left corner
                    Width - ScreenScale(25), 0, -- Top right corner
                    Width - ScreenScale(20), ScreenScale(5),
                    Width, ScreenScale(5),
                    Width, Height - ScreenScale(5),

                    Width - ScreenScale(5), Height,
                    ScreenScale(5), Height,
                } or {
                    0, Height - ScreenScale(5), -- Bottom left corner
                    0, ScreenScale(5), -- Top left corner
                    ScreenScale(5), ScreenScale(5),
                    ScreenScale(10), 0, -- Top left corner
                    Width - ScreenScale(10), 0, -- Top right corner
                    Width - ScreenScale(5), ScreenScale(5),
                    Width, ScreenScale(5),
                    Width, Height - ScreenScale(5),

                    Width - ScreenScale(5), Height,
                    ScreenScale(5), Height,
                }" 
                Stroke="Color(255, 255, 255, 16)" 
                StrokeWidth="1"
                Grow="true"
                Fill="Color(0, 0, 0, 128)"
                Align="7"
            />

            <Rect 
                Name="Close" 
                :Display="CloseButton == true"
                Absolute="true" 
                :X="Parent.Width - ScreenScale(25)" 
                Y="0" 
                Width="20ss" 
                Height="5ss"
                Fill="white"
                Hover="true"
                Cursor="hand"
                On:MousePressed="Parent:OnClose()"
                
                :Material="IsHovered and
                    RadialGradient(
                        Color(137, 18, 18, 254),
                        0.3,
                        Color(120, 0, 0, 254),
                        0.5,
                        Color(120, 0, 0, 254)
                    ) 
                or 
                    RadialGradient(
                        Color(57, 18, 18, 254),
                        0.3,
                        Color(40, 0, 0, 254),
                        0.5,
                        Color(40, 0, 0, 254)
                )"
                
                :Shape="{
                    ScreenScale(5), Height,
                    0, 0,
                    Width - ScreenScale(5), 0,
                    Width, Height
                }">
            </Rect>
    </Rect>
]])

WINDOW:CreateProperty("CloseButton", Type.Boolean, { Default = true })

function WINDOW.Prototype:OnClose()
    self:Dispose()
    return true
end
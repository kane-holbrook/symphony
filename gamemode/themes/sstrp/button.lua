AddCSLuaFile()
if SERVER then 
    return 
end
local BUTTON = Theme.Symphony:RegisterFromXML("Button", [[
    <Rect 
        Padding="6ss, 3ss"
        Align="5"
        Cursor="hand" 
        Hover="true" 
        Fill="white"
        :Material="self:GenerateBackground()"
        StrokeWidth="1"
        Stroke="Color(255, 255, 255, 16)"
        :Shape="{
            0, ScreenScale(1.5),
            ScreenScale(1.5), 0, -- Top left corner
            Width - ScreenScale(1.5), 0,
            Width, ScreenScale(1.5), -- Top right corner
            Width, Height - ScreenScale(1.5), -- Bottom right corner
            Width - ScreenScale(1.5), Height, -- Bottom right corner
            ScreenScale(1.5), Height, -- Bottom left corner
            0, Height - ScreenScale(1.5), -- Bottom left corner
        }"
    >
        
    </Rect>
]])
BUTTON:CreateProperty("Color", Type.Color, { Default = Color(0, 14, 30, 254) })

BUTTON.Primary = Color(0, 14, 30, 254)
BUTTON.Secondary = Color(11, 11, 15, 254)
BUTTON.Green = Color(0, 30, 2, 254)
BUTTON.Red = Color(30, 0, 0, 254)
BUTTON.Yellow = Color(30, 30, 0, 254)

function BUTTON.Prototype:GenerateBackground()
    local col = self:GetColor()
    local col2 = col:Darken(0.5)
    
    local c1 = ColorAlpha(col, self.IsHovered and 160 or 90)
    local c2 = ColorAlpha(col2, self.IsHovered and 160 or 90)

    return RadialGradient(
        c1,
        0.5,
        c2,
        0.75,
        c1
    )

end
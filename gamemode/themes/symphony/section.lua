AddCSLuaFile()
if SERVER then
    return
end

local SECTION = Theme.Symphony:RegisterFromXML("Section", [[
    <Rect 
        Fill="white" 
        :Material="RadialGradient(
            Color(0, 3, 10, 254),
            0.5,
            Color(0, 14, 30, 254),
            0.75,
            Color(0, 3, 10, 254)
        )" 
        Stroke="Color(255, 255, 255, 12)"
        StrokeWidth="1"
        Padding="4ss"
        Align="7"
        >
            
    </Rect>
]])
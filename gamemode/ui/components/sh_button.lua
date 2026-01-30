AddCSLuaFile()

if SERVER then
    return
end

local BTN = vguix.RegisterFromXML("SSTRP.Button", [[
    <Rect 
        Name="Component"
        Func:LeftClick="function () 
            self:InvokeParent('LeftClick')
            return true
        end"

        Padding="16, 8" 
        :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
        :Cursor="Disabled and 'none' or 'hand'"
        Hover="true"
        FontSize="10" 
        FontName="Orbitron"
        :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
        Fill="white"
        Hover="true"
        :Mat="RadialGradient(
            Color(0, 14, 30, IsHovered and 255 or 128),
            0.3,
            Color(0, 14, 30, IsHovered and 255 or 128),
            0.9,
            Color(0, 3, 10, IsHovered and 255 or 128)
        )"
        Stroke="white"
        StrokeWidth="4"
        :StrokeMat="
        LinearGradient(
            Color(0, 28, 60, 255),
            0.1,
            Color(0, 28, 60, 192),
            1,
            Color(0, 6, 20, 0),
            90
        )"
        :Alpha="IsHovered and 255 or 128"
        Align="4"
    >
    </Rect>
]])


vguix.RegisterFromXML("SSTRP.SecondaryButton", [[
    <SSTRP.Button 
        Name="Component"
        Cursor="hand"
        :Mat="RadialGradient(
            Color(30, 30, 30, IsHovered and 255 or 128),
            0.3,
            Color(30, 30, 30, IsHovered and 255 or 128),
            0.9,
            Color(10, 10, 10, IsHovered and 255 or 128)
        )"
        :StrokeMat="LinearGradient(
            Color(60, 60, 60, 255),
            0.1,
            Color(60, 60, 60, 192),
            1,
            Color(40, 42, 46, 0),
            90
        )"
    >
    </SSTRP.Button>
]])


vguix.RegisterFromXML("SSTRP.WarnButton", [[
    <SSTRP.Button 
        Name="Component"
        Cursor="hand"
        :Mat="RadialGradient(
            Color(30, 15, 0, IsHovered and 255 or 128),
            0.3,
            Color(30, 15, 0, IsHovered and 255 or 128),
            0.9,
            Color(10, 5, 0, IsHovered and 255 or 128)
        )"
        :StrokeMat="
        LinearGradient(
            Color(60, 30, 0, 255),
            0.1,
            Color(60, 30, 0, 192),
            1,
            Color(20, 10, 0, 0),
            90
        )"
    >
    </SSTRP.Button>
]])

vguix.RegisterFromXML("SSTRP.DestructiveButton", [[
    <SSTRP.Button 
        Name="Component"
        Cursor="hand"
        :Mat="RadialGradient(
            Color(30, 0, 0, IsHovered and 255 or 128),
            0.3,
            Color(30, 0, 0, IsHovered and 255 or 128),
            0.9,
            Color(10, 0, 0, IsHovered and 255 or 128)
        )"
        :StrokeMat="
        LinearGradient(
            Color(60, 0, 0, 255),
            0.1,
            Color(60, 0, 0, 192),
            1,
            Color(20, 0, 0, 0),
            90
        )"
    >
    </SSTRP.Button>
]])

vguix.RegisterFromXML("SSTRP.SuccessButton", [[
    <SSTRP.Button 
        Name="Component"
        Cursor="hand"
        :Mat="RadialGradient(
            Color(0, 30, 0, IsHovered and 255 or 128),
            0.3,
            Color(0, 30, 0, IsHovered and 255 or 128),
            0.9,
            Color(0, 10, 0, IsHovered and 255 or 128)
        )"
        :StrokeMat="
        LinearGradient(
            Color(0, 60, 0, 255),
            0.1,
            Color(0, 60, 0, 192),
            1,
            Color(0, 20, 0, 0),
            90
        )"
    >
    </SSTRP.Button>
]])
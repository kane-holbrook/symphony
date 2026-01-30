if SERVER then
    AddCSLuaFile()
end

vguix.RegisterFromXML("Circle",
[[
    <Rect 
        Name="Component"
        :Shape="RoundedBox(Width, Height, Height/2, Height/2, Height/2, Height/2)"
        >
    </Rect>
]])
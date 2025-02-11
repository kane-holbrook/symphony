AddCSLuaFile()
if SERVER then 
    return
end 

local RECT = Interface.Register("Rect", "Panel")

function RECT:Paint(w, h)
    local s = self:GetBase()
    s.Paint(self, w, h)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(0, 0, w, h)
end

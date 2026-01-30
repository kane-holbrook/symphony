if SERVER then
    AddCSLuaFile()
end

local PANEL = {}
vguix.AccessorFunc(PANEL, "Curviness", "Curviness", "Number")
vguix.AccessorFunc(PANEL, "Radius", "Radius", "Number")
vguix.AccessorFunc(PANEL, "TopLeft", "TopLeft", "Bool")
vguix.AccessorFunc(PANEL, "TopRight", "TopRight", "Bool")
vguix.AccessorFunc(PANEL, "BottomLeft", "BottomLeft", "Bool")
vguix.AccessorFunc(PANEL, "BottomRight", "BottomRight", "Bool")




function PANEL:Init()
    self:SetMat(nil)
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(0, 0)
    paint.roundedBoxes.roundedBoxEx(self:GetRadius(), x, y, w, h, self:GetFill(), self:GetTopLeft(), self:GetTopRight(), self:GetBottomRight(), self:GetBottomLeft(),  self:GetMat(), 0, 0, 1, 1, self:GetCurviness())
end


vgui.Register("RoundedBox", PANEL, "Rect")
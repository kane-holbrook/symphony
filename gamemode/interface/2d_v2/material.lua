AddCSLuaFile()
if SERVER then
    return
end

local PANEL = Interface.Register("Material", "Rect")
PANEL:CreateProperty("Material", Type.String, { Parse = function (value) return Material(value, "mips smooth noclamp") end })
PANEL:CreateProperty("Color", Type.Color)
PANEL:CreateProperty("Repeat", Type.Boolean)

function PANEL.Prototype:Initialize()
    base(self, "Initialize")
    self:SetProperty("Material", "")
    self:SetProperty("Color", color_white)
    self:SetProperty("Repeat", false)
    self:SetProperty("Scale", 1)
end

function PANEL.Prototype:Paint(w, h)
    base(self, "Paint", w, h)
    
    if self:GetProperty("Material") then
        self:StartStencil(w, h)
        local mat = self:GetProperty("Material")
        surface.SetDrawColor(self:GetProperty("Color"))
        surface.SetMaterial(mat)

        if self:GetProperty("Repeat") then
            local scale = self:GetProperty("Scale")
            surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w / (mat:Width() * scale), h / (mat:Height() * scale))
        else
            surface.DrawTexturedRect(0, 0, w, h)
        end
        self:FinishStencil()
    end
end
AddCSLuaFile()
if SERVER then
    return
end

local PANEL = {}

function PANEL:Init()
    self:SetProperty("Material", "")
    self:SetProperty("FillColor", color_white)
    self:SetProperty("Repeat", false)
    self:SetProperty("Scale", 1)
end

function PANEL:OnPropertyChanged(name, value, old)
    Rect.OnPropertyChanged(self, name, value, old)
end

function PANEL:Paint(w, h)
    if self:GetProperty("Material") then
        self:StartStencil(w, h)
        local mat = self:GetProperty("Material")
        surface.SetDrawColor(self:GetProperty("FillColor"))
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

function PANEL:ParseContent(text, node, ctx)
    self:SetProperty("Content", text)
end
vgui.Register("Img", PANEL, "Rect")

Interface.RegisterAttribute("Img", "Material", function (value)
    return Material(value, "mips smooth noclamp")
end)
Interface.RegisterAttribute("Img", "FillColor", Type.Color)
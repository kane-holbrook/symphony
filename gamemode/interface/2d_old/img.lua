AddCSLuaFile()
if SERVER then
    return
end

local PANEL = {}

function PANEL:Init()
    self:SetProperty("Material", "")
    self:SetProperty("Color", color_white)
end

function PANEL:OnPropertyChanged(name, value, old)
    Rect.OnPropertyChanged(self, name, value, old)
end

function PANEL:Paint(w, h)
    if self:GetProperty("Material") then
        surface.SetDrawColor(self:GetProperty("Color"))
        surface.SetMaterial(self:GetProperty("Material"))
        surface.DrawTexturedRect(0, 0, w, h)
    end
end

function PANEL:ParseContent(text, node, ctx)
    self:SetProperty("Content", text)
end
vgui.Register("Img", PANEL, "Rect")

Interface.RegisterAttribute("Img", "Material", function (value)
    return Material(value, "mips smooth")
end)
Interface.RegisterAttribute("Img", "Color", Type.Color)
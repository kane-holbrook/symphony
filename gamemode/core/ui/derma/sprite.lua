if SERVER then
    return
end

local PANEL = {}

local MaterialCache = weaktable(false, true)
function PANEL:Init()
    self:RegisterProperty("Color", color_white)
    self:RegisterProperty("Rotation", 0)
    self:RegisterProperty("Material", nil)
end

function PANEL:OnPropertyChanged(name, value, old)
    if value == old then
        return
    end

    if name == "Material" then
        self.Material = Material(value)
    end
end

function PANEL:SizeToChildren(sizeW, sizeH)
    local mat = self:GetProperty("Material")
    local w, h = mat:Width(), mat:Height()
    local pl, pt, pr, pb = self:CalculatePadding()

    self:SetSize(sizeW and w + pl + pr or self:GetWide(), sizeH and h + pt + pb or self:GetTall())
end

function PANEL:CalculateName()
    local t = XPanel.CalculateName(self)
    return t .. "[\"" .. self.Material:GetName() .. "\"]"
end

function PANEL:PerformLayout(w, h)
    XPanel.PerformLayout(self, w, h)
    print(self:GetProperty("Ref"), self:GetProperty("RefParent"))
end

function PANEL:Paint(w, h)
    XPanel.Paint(self, w, h)
    
    if self.Material then
        surface.SetDrawColor(self:GetProperty("Color"))
        surface.SetMaterial(self.Material)
        surface.DrawTexturedRectRotated(w/2, h/2, w, h, self:GetProperty("Rotation"))
    end
end
vgui.Register("SymSprite", PANEL, "XPanel")


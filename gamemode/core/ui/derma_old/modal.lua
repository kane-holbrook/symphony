if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetFlexIgnore(true)

    self.SizeEx = { REL(1), REL(1) }
    self:SetFlex(5)

    self.Frame = vgui.Create("SymFrame", self)
    self.Frame:SetSizeEx(REL(0.3), REL(0.3))
    self.Frame:SetFlex(5)
    self.Frame:SetFlexFlow(FLEX_FLOW_Y)
    self:SetCanDismiss(true)

    self:SetDisplay(DISPLAY_NONE)
end

function PANEL:SetSizeEx(...)
    return self.Frame:SetSizeEx(...)
end

function PANEL:GetSizeEx(...)
    return self.Frame:GetSizeEx()
end

function PANEL:Open()
    self.LastParent = self.LastParent or self:GetParent()

    self.StartTime = CurTime()
    self:SetParent(nil)
    self:SetDisplay(DISPLAY_VISIBLE)

    self:InvalidateLayout()
    self:MakePopup()
end

function PANEL:Close()
    self:SetParent(self.LastParent)
    self:SetDisplay(DISPLAY_NONE)
    self.LastParent = nil
end

function PANEL:IsOpen()
    return self:GetDisplay() == DISPLAY_VISIBLE
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    Derma_DrawBackgroundBlur(self, self.StartTime)

    surface.SetDrawColor(0, 0, 0, 225)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:SetCanDismiss(enable)
    self.CanDismiss = enable
    self:SetCursor(enable and "hand" or "none")
end

function PANEL:GetCanDismiss()
    return self.CanDismiss
end

function PANEL:OnMousePressed(mouse)
    if self:GetCanDismiss() then
        self:Close()
    end
end

function PANEL:Think()
    if self.LastParent and not IsValid(self.LastParent) then
        self:Remove()
    end
end

function PANEL:OnChildAdded(child)
    SymPanel.OnChildAdded(self, child)
    child:SetParent(self.Frame)
end

vgui.Register("SymModal", PANEL, "SymPanel")
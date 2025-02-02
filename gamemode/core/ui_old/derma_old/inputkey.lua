if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetBackground(Color(73, 87, 100))

    self:SetFlex(5)
    self:SetFlexGap(CHRW(sym.fonts.default, "0"))
    self:SetCursor("hand")
end

function PANEL:SetContent(...)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    SymPanel.CreateContent(self, ...)
end

function PANEL:Paint(w, h)
    --SymPanel.Paint(self, w, h)

    draw.RoundedBox(ScreenScale(1), 0, 0, w, h, self:IsHovered() and Color(128, 128, 128, 90) or Color(128, 128, 128, 64))
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h)
end
vgui.Register("SymKey", PANEL, "SymPanel")
if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetFlex(5)

    self:SetSizeEx(SS(3.5), SS(3.5))
    self:SetCursor("hand")

    self.Label = vgui.Create("SymLabel", self)
    self.Label:SetText("i")
    self.Label:SetFont(sym.Font(nil, 13))
    self.Label:SetColor(color_black)
    self.Label:SetFlexMargin(SS(1), SS(1), SS(1), SS(1))

    self.Tooltip = vgui.Create("SymTooltip", self)
    self.Tooltip:SetAlignment(6)
end

function PANEL:SetContent(...)
    self.Tooltip:SetContent(...)
end

function PANEL:SetAlignment(num)
    self.Tooltip:SetAlignment(num)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(h*2, 0, 0, w, h, self:IsHovered() and color_white or Color(255, 255, 255, 64))
end
vgui.Register("SymInfo", PANEL, "SymPanel")
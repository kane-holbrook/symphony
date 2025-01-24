if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetFlex(5)
    self:NoClipping(true)
    self:SetNoHover(true)
end

function PANEL:SetContent(...)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    local font = sym.Font(nil, 7)
    for k, v in pairs({...}) do
        if isstring(v) then
            self:Add("SymLabel", { Font = font, Text = v })
        elseif TypeID(v) == TYPE_MATERIAL then
            self:Add("SymSprite", { Material = v, SizeEx = { CHRH(font), CHRH(font) } })
        elseif ispanel(v) then
            v:SetParent(self)
        end
    end
    self:InvalidateChildren(true)
    self:SizeToChildren(true, true, SS(10), SS(5))
end

function PANEL:Paint(w, h)    
    local p = ScreenScale(5)

    local ss = ScreenScale(0)
    local col = Color(0, 0, 0, 255)

    draw.RoundedBox(ss, p + ss, ss, w-ss-p, h-ss, col)

end
vgui.Register("SymTooltip", PANEL, "SymPopover")

if SERVER then
    return
end

if SERVER then
    return
end

local PANEL = {}
PANEL.IsInput = true

function PANEL:Init()
    self:SetFlex(4)
    self:SetFlexFlow(FLEX_FLOW_X)

    self.Left = vgui.Create("SymPanel", self)
    self.Left:SetSize(0, 0)

    self.Radio = vgui.Create("SymPanel", self)
    self.Radio.Paint = self.PaintRadio
    self.Radio:SetBackground(Color(40, 40, 40, 255))
    self.Radio:SetHover(Color(60, 60, 60, 255))
    self.Radio:SetNoHover(true)
    self.Radio:SetFlex(5)
    self.Radio:SetSizeEx(SS(10), SS(10))

    --self.Radio:SizeToChildren(true, true)
    self:SizeToChildren(true, true)


    self:SetCursor("hand")
    self:SetValue(false)
end

function PANEL:Label(...)
    self.Radio:SetFlexMargin(SS(0), SS(0), SS(2), SS(0))
    SymPanel.CreateContent(self, ...)
    self:SizeToChildren(true, true)
end

function PANEL:SetController(controller, key)
    self.Controller = controller
    self.Key = key
    controller:Add(key, self)
end

function PANEL:GetController()
    return self.Controller
end

function PANEL:SetValue(checked)
    local p = self:GetParent()
    self.Value = checked

    self:OnChanged(checked)
end

function PANEL:OnChanged(value)
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:Click()
    
    local controller = self:GetController()
    assert(controller, "Radio buttons must have a controller")

    controller:SetValue(self.Key, self)
end

function PANEL:OnMousePressed(mouse)
    if mouse == MOUSE_LEFT then
        self:Click()
    end
end

function PANEL:PaintRadio(w, h)
    local parent = self:GetParent()
    local hovered = parent:IsHovered()

    local sz = h/5
    for i=0, sz do 
        local alpha = hovered and 255 or 64
        surface.DrawCircle(w/2, h/2, (w - i)/2, 255, 255, 255, alpha)
    end

    if parent:GetValue() then
        local vsz = h/2
        local alpha = hovered and 255 or 64
        for i=0, vsz do
            surface.DrawCircle(w/2, h/2, i/2, 255, 255, 255, alpha)
        end
    end

end

vgui.Register("SymInputRadio", PANEL, "SymPanel")
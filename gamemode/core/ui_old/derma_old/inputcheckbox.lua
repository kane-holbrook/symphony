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

    self.Checkbox = vgui.Create("SymPanel", self)
    self.Checkbox.Paint = self.PaintCheckbox
    self.Checkbox:SetBackground(Color(40, 40, 40, 255))
    self.Checkbox:SetHover(Color(60, 60, 60, 255))
    self.Checkbox:SetNoHover(true)
    self.Checkbox:SetFlex(5)
    self.Checkbox:NoClipping(true)
    self.Checkbox:SetSizeEx(SS(10), SS(10))

    self.Mark = vgui.Create("SymLabel", self.Checkbox)
    self.Mark:SetNoHover(true)
    self.Mark:SetColor(color_white)
    self.Mark:SetFont(sym.Font("Oxanium ExtraBold", 10))
    self.Mark:InvalidateLayout(true)

    --self.Checkbox:SizeToChildren(true, true)
    self:SizeToChildren(true, true)


    self:SetCharacter("✓")
    self:SetCursor("hand")
    self:SetValue(false)
end

function PANEL:Label(...)
    self.Checkbox:SetFlexMargin(SS(0), SS(0), SS(2), SS(0))
    SymPanel.CreateContent(self, ...)
    self:SizeToChildren(true, true)
end

function PANEL:SetCheckboxSize(sz, markSz)
    self.Checkbox:SetSizeEx(sz, sz)
    
    self.Mark:SetFont(sym.Font("Oxanium ExtraBold", markSz))
end

function PANEL:GetCheckboxSize(sz)
    return self.Mark:GetSize()
end

function PANEL:SetController(controller, key)
    self.Controller = controller
    self.Key = key
    controller:Add(key, self)
end

function PANEL:GetController()
    return self.Controller
end

function PANEL:SetLight(enable)
    self.LightMode = enable

    if enable then
        self.Checkbox:SetBackground(Color(180, 180, 180, 255))
        self.Checkbox:SetHover(Color(200, 200, 200, 255))
    else
        self.Checkbox:SetBackground(Color(40, 40, 40, 255))
        self.Checkbox:SetHover(Color(60, 60, 60, 255))
    end
end

function PANEL:SetValue(checked, skip)
    local p = self:GetParent()
    self.Value = checked

    if checked then
        self.Mark:SetDisplay(DISPLAY_VISIBLE)
        self.Mark:SetColor(self.LightMode and Color(0, 0, 0) or Color(255, 255, 255, 255))
    else
        if self:IsHovered() then
            self.Mark:SetColor(self.LightMode and Color(64, 64, 64, 255) or Color(255, 255, 255, 32))
        else
            self.Mark:SetDisplay(DISPLAY_HIDDEN)
        end
    end
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:GetCharacter()
    return self.Mark:GetText()
end

function PANEL:SetCharacter(chr)
    self.Mark:SetText(chr)
end

function PANEL:Click()
    
    local controller = self:GetController()
    if controller then
        controller:SetValue(self.Key, not self:GetValue())
    else
        self:SetValue(not self:GetValue())
    end
end

function PANEL:OnMousePressed(mouse)
    if mouse == MOUSE_LEFT then
        self:Click()
    end
end

function PANEL:OnCursorEntered()
    if not self:GetValue() then
        self.Mark:SetDisplay(DISPLAY_VISIBLE)
        self.Mark:SetColor(Color(255, 255, 255, 32))
    end
end

function PANEL:OnCursorExited()
    if not self:GetValue() then
        self.Mark:SetDisplay(DISPLAY_HIDDEN)
        self.Mark:SetColor(Color(255, 255, 255, 255))
    end
end

function PANEL:PaintCheckbox(w, h)
    local parent = self:GetParent()
    local p = ScreenScale(0.5)
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(p, p, w - p, h - p)

    surface.SetDrawColor(parent:IsHovered() and self:GetHover() or self:GetBackground())
    surface.DrawRect(0, 0, w - p, h - p)
end

vgui.Register("SymInputCheckbox", PANEL, "SymPanel")
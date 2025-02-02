if SERVER then
    return
end

local PANEL = {}
PANEL.IsInput = true

function PANEL:Init()

    self:SetFlex(5)

    self.Left = vgui.Create("SymPanel", self)
    self.Left:SetSizeEx(ABS(0), ABS(0))

    self.Container = vgui.Create("SymPanel", self)
    self.Container:SetFlexGrow(true)
    self.Container:SetFlexMargin(SS(2), 0, SS(2), 0)

    self.Handle = vgui.Create("SymPanel", self.Container)
    self.Handle:NoClipping(true)
    self.Handle:SetNoHover(true)
    self.Handle:SetSizeEx(SS(5), SS(5))
    self.Handle.Paint = self.PaintHandle

    self.Hint = vgui.Create("SymPopover", self)
    self.Hint:SetNoHover(true)
    self.Hint:SetFlex(5)
    self.Hint:SetOn("click")
    self.Hint.Paint = self.PaintHint

    self.Hint.Label = vgui.Create("SymLabel", self.Hint)
    self.Hint.Label:SetFont(sym.fonts.p)

    self.Hint:SetDisplay(DISPLAY_NONE)
    self.Hint:NoClipping(true)
    self.Hint:SetAlignment(nil)

    self.Container:SetCursor("hand")
    self.Container.OnMousePressed = self.ContainerPressed
    self:SetValue(0)
    self:SetBounds(0, 1)
    self:SetDecimals()
end

function PANEL:SetDecimals(value)
    self.Decimals = value
end

function PANEL:GetDecimals()
    return self.Decimals
end

function PANEL:SetValue(val)
    val = math.Round(val, self:GetDecimals())

    self.Value = val
    self.Hint.Label:SetText(val)
    self.Hint:SizeToChildren(true, true, SS(3), SS(3))
    self:InvalidateLayout()

    self:ValueChanged(val)
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:ValueChanged(val)
end

function PANEL:SetBounds(min, max)
    self.Bounds = { min, max }
end

function PANEL:GetBounds()
    return self.Bounds
end

function PANEL:SetTickInterval(n)
    self.TickInterval = n
end

function PANEL:GetTickInterval()
    return self.TickInterval
end

function PANEL:Paint(w, h)
    local sz = ScreenScale(1)
    surface.SetDrawColor(self:IsHovered() and Color(255, 255, 255, 94) or Color(255, 255, 255, 32))
    surface.DrawRect(0, h/2-sz/2, w, sz)

    local ti = self:GetTickInterval()
    if not ti then
        local min, max = unpack(self:GetBounds())
        ti = (max - min)/10
    end

    if ti and ti ~= 0 then
        local tw = math.floor(w / ti)
        local th = sz
        surface.SetDrawColor(255, 255, 255, 32)
        for x = tw, w, tw do
            surface.DrawLine(x, h/2 - th/2, x, h/2 + th)
        end
    end
end

function PANEL:PaintHandle(w, h)
    local sz = ScreenScale(5)
    draw.RoundedBox(h, 0, 0, w, h, color_white)
end

function PANEL:PaintHint(w, h)
    draw.RoundedBox(h, 0, 0, w, h, Color(255, 102, 0, 231))
end

function PANEL:CalculateSize(w, h)
    w, h = SymPanel.CalculateSize(self, w, h)
    return w, ScreenScaleH(10)
end

function PANEL:ContainerPressed(mouse)
    local parent = self:GetParent()
    if mouse == MOUSE_LEFT then
        parent.Hint:Open()
        hook.Add("Think", self, function ()
            local x, y = self:LocalCursorPos()
            local w, h = self:GetSize()
            local bounds = parent:GetBounds()
            parent:SetValue(math.Remap(math.Clamp(x/w, 0, 1), 0, 1, bounds[1], bounds[2]))

            if not input.IsMouseDown(MOUSE_LEFT) then
                parent.Hint:Close()
                hook.Remove("Think", self)
            end
        end)
    end
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h, true)
    local w2, h2 = self.Container:GetSize()
    
    local value = self:GetValue()
    local bounds = self:GetBounds()
    local progress = math.Remap(value, bounds[1], bounds[2], 0, 1)
    self.Handle:SetPos((w2 * progress) - self.Handle:GetWide()/2, h/2 - self.Handle:GetTall()/2)
    self.Hint:SetPos(self.Container:LocalToScreen((w2 * progress) - self.Hint:GetWide()/2, h/2 - self.Handle:GetTall()/2 + ScreenScale(10)))
    self:SetSize(w, h)

    return w, h
end


vgui.Register("SymInputSlider", PANEL, "SymPanel")
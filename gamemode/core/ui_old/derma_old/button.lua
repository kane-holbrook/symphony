if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetBackground(255)    
    self:SetHover(192)

    self:SetFlex(5)
    self:SetFlexGap(CHRW(sym.fonts.default, "0"))
    self:SetCursor("hand")
end

function PANEL:SetController(controller, key)
    self.Controller = controller
    self.Key = key
    controller:Add(key, self)
end

function PANEL:GetController()
    return self.Controller
end

function PANEL:SetValue(enable)
    self._Background = self._Background or self:GetBackground()
    self._Hover = self._Hover or self:GetHover()
    
    self.Value = enable
    if enable then
        self:SetBackground(self._Hover)
    else
        self:SetBackground(self._Background)
    end

    if not self.OnMousePressed then
        self.OnMousePressed = function (p)
            self:GetController():SetValue(self.Key)
        end
    end
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:SetContent(...)
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end

    SymPanel.CreateContent(self, ...)
end

function PANEL:Paint(w, h)
    SymPanel.Paint(self, w, h)

    local hndl = ScreenScale(2)
    surface.SetDrawColor(255, 255, 255, 16)
    surface.DrawLine(0, 0, w, 0)
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(0, 0, w, 0)
    surface.DrawLine(0, h-1, w, h-1)
    surface.DrawLine(w-1, 0, w-1, h)
end

vgui.Register("SymButton", PANEL, "SymPanel")
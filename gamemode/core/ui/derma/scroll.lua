if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetProperty("Grow", true)
    self:SetProperty("Flex", 7)
    self:SetProperty("Direction", "X")
    self:NoClipping(true)

    self.Content = vgui.Create("XPanel", self)
    self.Content:SetProperty("Absolute", true)
    self.Content:SetProperty("Flex", 7)
    self.Content:SetProperty("Direction", "Y")
    self.Content:SetProperty("Width", function ()
        return PW - ScreenScale(2)
    end)
    self.DefaultSlot = self.Content
    
    self.Scrollbar = vgui.Create("XPanel", self)
    self.Scrollbar:SetCursor("hand")
    self.Scrollbar:SetProperty("Absolute", true)
    self.Scrollbar:SetProperty("Background", Color(255, 255, 255, 16))
    self.Scrollbar:SetProperty("X", function () return PW - ScreenScale(2) end)
    self.Scrollbar:SetProperty("Y", 0)
    self.Scrollbar:SetProperty("Width", function () return ScreenScale(2) end)
    self.Scrollbar:SetProperty("Height", function () return Parent.Height end)
    self.Scrollbar:SetProperty("Display", function () 
        return self.Content:GetTall() > PH
    end)

    self.Scrollbar.OnMousePressed = function (s, c) 
        if c == MOUSE_LEFT then
            self:PressScroll() 
        end
    end

    self.Scrollbar.Handle = vgui.Create("XPanel", self.Scrollbar)
    self.Scrollbar.Handle:SetCursor("hand")
    self.Scrollbar.Handle:SetProperty("Background", color_white)
    self.Scrollbar.Handle:SetProperty("Absolute", true)
    self.Scrollbar.Handle:SetProperty("Width", function () return PW end)
    self.Scrollbar.Handle:SetProperty("Height", function () 
        return math.Clamp(PH/self.Content:GetTall(), 0, 1) * PH
    end)
    self.Scrollbar.Handle:SetProperty("Y", function () 
        return (math.Clamp(-self.Content:GetY()/self.Content:GetTall(), 0, 1) * PH)
    end)

    self.Scrollbar.Handle.OnMousePressed = function (s, c) 
        if c == MOUSE_LEFT then
            self:PressHandle() 
        end
    end
end

function PANEL:OnMouseWheeled(scrollDelta)
    local x, y = self.Content:GetPos()
    local cw, ch = self.Content:CalculateChildrenSize()
    local h = self:GetTall()
    self.Content:SetPos(x, math.Clamp(y + scrollDelta * 10, -ch + h, 0))
end

function PANEL:PressScroll()
    local cw, ch = self.Content:CalculateChildrenSize()
    local x, y = self.Scrollbar:LocalCursorPos()
    local ax, ay = self.Scrollbar.Handle:GetSize()
    local h = self.Scrollbar:GetTall()
    local p = math.Clamp((y - ay/2)/h, 0, 1)
    
    self.Content:SetProperty("Y", math.Clamp(-self.Content:GetTall() * p, -ch + h, 0))

    timer.Simple(0, function ()
        self:PressHandle()
    end)
end

function PANEL:PressHandle()
    local ax, ay = self.Scrollbar.Handle:LocalCursorPos()
    hook.Add("Think", self, function ()
        if not IsValid(self) then
            return
        end

        local cw, ch = self.Content:CalculateChildrenSize()
        local x, y = self.Scrollbar:LocalCursorPos()
        local h = self.Scrollbar:GetTall()
        local p = math.Clamp((y - ay)/h, 0, 1)

        self.Content:SetProperty("Y", math.Clamp(-self.Content:GetTall() * p, -ch + h, 0))
        
        if not input.IsMouseDown(MOUSE_LEFT) then
            hook.Remove("Think", self)
        end
    end)
end

function PANEL:PerformLayout(w, h)
    w, h = XPanel.PerformLayout(self, w, h)
    self.Scrollbar:InvalidateLayout()
    self.Scrollbar.Handle:InvalidateLayout()
end

function PANEL:OnChildAdded(child)
    child:SetParent(self.Content)
end

vgui.Register("SymScroll", PANEL, "XPanel")
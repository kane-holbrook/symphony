if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetFlexIgnore(true)
    self:SetDisplay(DISPLAY_NONE)
    self:SetOn("hover")
    self:SetAlignment(6)
    self:SetFlexMargin(SS(2), SS(2), SS(2), SS(2))
    self:NoClipping(true)
    self:SetOpenParent(nil)
    self:SetDrawOnTop(true)
end

function PANEL:SetOpenParent(ele)
    self.OpenParent = ele
end

function PANEL:GetOpenParent()
    return self.OpenParent
end

function PANEL:SetOn(text)
    self.On = string.lower(text)
end

function PANEL:IsOnHover()
    return string.find(self.On, "hover")
end

function PANEL:IsOnClick()
    return string.find(self.On, "click")
end

function PANEL:IsOpen()
    return self.Opened
end

function PANEL:SetAlignment(align)
    self.Alignment = align
end

function PANEL:GetAlignment()
    return self.Alignment
end

function PANEL:GetRealParent()
    if not self._Parent then
        self._Parent = self:GetParent()
        self._Parent.Popover = self
    end

    return self._Parent
end

function PANEL:Open()
    
    if not self._Parent then
        self._Parent = self:GetParent()
        self._Parent.Popover = self
    end

    local parent = self._Parent
    if not IsValid(parent) then
        self:Remove()
        return
    end

    self:SetParent(self:GetOpenParent())
    self:SetDisplay(DISPLAY_VISIBLE)
    self:InvalidateLayout(true)

    self:DoPositioning()

    self:MakePopup()
    self:SetPopupStayAtBack(true)
    
    self.Opened = true

    hook.Add("VGUIMousePressed", self, function (pnl, mouse)
        if not self:IsOurChild(pnl) and pnl ~= parent and not parent:IsOurChild(pnl) then
            self:Close()
        end
    end)
end

function PANEL:DoPositioning()    
    local parent = self._Parent
    if not IsValid(parent) then
        self:Remove()
    end

    local pw, ph = parent:GetSize()
    local x, y
    
    local align = self:GetAlignment()

    local ml, mt, mr, mb = self:CalculateFlexMargin()

    -- vertical
    local w, h = self:GetSize()
    if align then
        if align == 4 then
            x, y = parent:LocalToScreen(-w, ph/2 - h/2)
        elseif align == 8 then
            x, y = parent:LocalToScreen(pw/2 - w/2, -h)
        elseif align == 6 then
            x, y = parent:LocalToScreen(pw, ph/2 - h/2)
        elseif align == 2 then
            x, y = parent:LocalToScreen(pw/2 - w/2, ph)
        else
            x, y = input.GetCursorPos()
            y = y - h/2
        end

        local OpenParent = self:GetOpenParent()
        if OpenParent then
            x, y = OpenParent:ScreenToLocal(x, y)
        end

        self:SetPos(x, y)
    end
end

function PANEL:Close()
    local parent = self._Parent
    if not IsValid(parent) then
        self:Remove()
        return
    end

    self:SetParent(parent)
    self:SetDisplay(DISPLAY_NONE)
    self:SetKeyboardInputEnabled(false)
    self:KillFocus()
    self:SetMouseInputEnabled(false)
    hook.Remove("VGUIMousePressed", self)
    self.Opened = false
end

function PANEL:CalculateSize(w, h)
    local parent = self:GetParent()
    local pw, ph 
    if parent then
        pw = parent:GetWide()
        ph = parent:GetTall()
    else
        pw = ScrW()
        ph = ScrH()
    end
    
    if self.SizeEx then
        if self.SizeEx[1] then
            w = self.SizeEx[1](pw, self)
        end 
        
        if self.SizeEx[2] then
            h = self.SizeEx[2](ph, self)
        end

        if not self:GetFlexGrow() then
            return w, h
        end
    end
    return
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h) 
end

function PANEL:Paint(w, h) 
    if self:IsOpen() then
        self:DoPositioning()
    end
end

function PANEL:Think()
    if not self._Parent then
        self._Parent = self:GetParent()
        self._Parent.Popover = self
    end

    local parent = self._Parent
    if not IsValid(parent) then
        self:Remove()
        return
    end

    if self:IsOpen() then
        self:DoPositioning()
    end

    if not self:IsOnHover() then
        return
    end

    if (parent:IsHovered() or parent:IsChildHovered() or self:IsHovered()) then
        local hov = vgui.GetHoveredPanel()
        if hov ~= parent and hov.Popover then
            -- Child popovers take precedence
            return
        end

        self:Open()
    elseif self:IsOpen() then        
        self:Close()
    end
end

vgui.Register("SymPopover", PANEL, "SymPanel")
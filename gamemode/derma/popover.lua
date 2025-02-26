AddCSLuaFile()

if SERVER then return end

local PANEL = {}

local Popovers = {}

function PANEL:Init()
    self:SetProperty("Absolute", true)
end

function PANEL:Open()
	-- Make sure it's visible!
    self:SetProperty("Display", true)
    self:SetProperty("Opened", true)
    self:MakePopup()

    -- Why does it take two layouts to calculate the size?
    self:InvalidateChildren(true)
    self:InvalidateChildren(true)
    

    Popovers[self] = true
end

function PANEL:Close()
    self:SetProperty("Display", false)
    self:SetProperty("Opened", false)
    self:InvalidateChildren(true)
    

    Popovers[self] = nil
end

function PANEL:Toggle()
    if self:GetProperty("Opened", true) == true then
        self:Close()
    else
        self:Open()
    end
end

function PANEL:Paint(w, h)
    XPanel.Paint(self, w, h)

    if not self:GetProperty("Display", true) then
        return
    end

    self:CalculatePosition()
end

function PANEL:CalculatePosition()
    
    local p = self:GetParent()

    if self:GetProperty("FollowCursor", true) then
        local mx, my = gui.MousePos()
        local x = mx + (self:GetProperty("X", true) or 0)
        local y = my + (self:GetProperty("Y", true) or 0)
        
        self:SetPos(x, y)
        return x, y
    else
        local x, y = p:LocalToScreen(0, 0)
        x = x + (self:GetProperty("X", true) or 0)
        y = y + (self:GetProperty("Y", true) or 0)

        self:SetPos(x, y)
        return x, y
    end
end

function PANEL:Reposition()
end
vgui.Register("Popover", PANEL, "Rect")


hook.Add("VGUIMousePressed", "PopoverClose", function(pnl, code)
    for k, v in pairs(Popovers) do
        if not IsValid(k) then
            Popovers[k] = nil
            continue
        end

        local p = pnl:GetParent()

        if p and p:IsOurChild(pnl) then
            continue
        end

        k:Close()
    end
end)
AddCSLuaFile()
if SERVER then
    return
end

local Popover = Interface.Register("Popover", Rect)
Popover:CreateProperty("FollowCursor", Type.Boolean, { Default = false })
Popover:CreateProperty("OffsetX", Type.Number, { Default = 0, Parse = Interface.ExtentX })
Popover:CreateProperty("OffsetY", Type.Number, { Default = 0, Parse = Interface.ExtentY })
Popover:CreateProperty("Interactive", Type.Boolean, { Default = false })

local Popovers = {}

function Popover.Prototype:Initialize()
    base(self, "Initialize")
    self:SetAbsolute(true)
    self:SetDisplay(false)
    self:SetParentShouldIgnoreSize(true)
end

function Popover.Prototype:Open()
	-- Make sure it's visible!
    self:SetDisplay(true)
    self:InvalidateLayout()

    Popovers[self] = true
end

function Popover.Prototype:Close()
    self:SetDisplay(false)
    self:InvalidateLayout()    

    Popovers[self] = nil
end

function Popover.Prototype:Toggle()
    if self:GetDisplay() == true then
        self:Close()
    else
        self:Open()
    end
end

function Popover.Prototype:OnStartDisplay()
    base(self, "OnStartDisplay")

    local pnl = self:GetPanel()
    pnl:MakePopup()

    pnl:SetKeyboardInputEnabled(false)
    pnl:SetDrawOnTop(true)

    self:InvalidateLayout()
end

local NoFunc = function() return false end

function Popover.Prototype:PerformLayout()
    base(self, "PerformLayout")

    self.TestHover = self:GetInteractive() and Type.Rect.Prototype.TestHover or NoFunc
end

function Popover.Prototype:Paint(w, h)
    base(self, "Paint", w, h)

    self:CalculatePosition()
end

function Popover.Prototype:CalculatePosition()
    if self:GetFollowCursor() then
        local mx, my = gui.MousePos()
        local x = mx + self:GetX()
        local y = my + self:GetY()
        
        self:SetPos(x, y)
        self:RenderProperty("X")
        self:RenderProperty("Y")
        return x, y
    else
        local p = self:GetParent():GetPanel()
        local x, y = p:LocalToScreen(0, 0)
        x = x + self:GetOffsetX()
        y = y + self:GetOffsetY()

        self:SetPos(x, y)
        self:RenderProperty("X")
        self:RenderProperty("Y")
        return x, y
    end
end


hook.Add("VGUIMousePressed", "PopoverClose", function(pnl, code)
    for k, v in pairs(Popovers) do
        if not IsValid(k) then
            Popovers[k] = nil
            continue
        end

        local p = pnl:GetParent()

        if p and (pnl == p or p:IsOurChild(pnl)) then
            continue
        end

        k:Close()
    end
end)
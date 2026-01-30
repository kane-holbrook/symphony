AddCSLuaFile()

if SERVER then
    return
end

DEFINE_BASECLASS("Popover")

local PANEL = {}
vguix.AccessorFunc(PANEL, "Anchor", "Anchor", "Number")


local DockEnum = {
    ["FILL"] = FILL,
    ["LEFT"] = LEFT,
    ["RIGHT"] = RIGHT,
    ["TOP"] = TOP,
    ["BOTTOM"] = BOTTOM,
    ["NODOCK"] = NODOCK
}

function PANEL:SetAnchor(value)
    if isstring(value) then
        value = DockEnum[string.upper(value)]
        assert(value, "Invalid value")
    end

    self["Anchor"] = value
    self:GetFuncEnv()["Anchor"] = value
    if f then
        f(pnl, value)
    end
end

function PANEL:Init()
    self:SetFuncEnv("FontName", "Rajdhani")
    self:SetFuncEnv("FontSize", 7)

    self:SetBlur(5)
    
    self:SetDrawOnTop(true)
    self:SetAnchor(BOTTOM)
    self:SetPadding(10)
    self:SetFill(Color(0, 0, 0, 255))
    self:SetMat(LinearGradient(
        Color(0, 10, 20, 192),
        0.1,
        Color(0, 10, 20, 192),
        1,
        Color(0, 1, 5, 192),
        90
    ))
    self:SetStrokeWidth(8)
    self:SetStroke(color_white)
    self:SetStrokeMat(LinearGradient(
        Color(18, 41, 68, 192),
        0.1,
        Color(0, 14, 30, 255),
        1,
        Color(0, 1, 5, 0),
        90
    ))
    self:SetInteractive(false)

    self:SetComputed("Visible", function ()
        local is_visible = self.VisibleFunc and self:VisibleFunc() or self:GetParent():GetFuncEnv("IsHovered")

        if is_visible then
            self:MakePopup()
        elseif self:GetVisible() and not is_visible then
            self:SetKeyboardInputEnabled(false)
            self:SetMouseInputEnabled(false)
        end
        return is_visible
    end, -10)

    self:SetComputed("OffsetX", function ()
        local a = self:GetAnchor()

        if isany(a, BOTTOM, TOP) then
            return self:GetParent():GetWide() / 2 - self:GetWide() / 2
        elseif a == LEFT then
            return -self:GetWide() - 5
        elseif a == RIGHT then
            return self:GetParent():GetWide() + 5
        end
    end)

    self:SetComputed("OffsetY", function ()
        local a = self:GetAnchor()

        if isany(a, LEFT, RIGHT) then
            return self:GetParent():GetTall() / 2 - self:GetTall() / 2
        elseif a == TOP then
            return -self:GetTall() - 5
        elseif a == BOTTOM then
            return self:GetParent():GetTall() + 5
        end
    end)

    self:SetComputed("PaddingTop", function ()
        if self:GetAnchor() == BOTTOM then
            return 20
        else
            return 10
        end
    end, -10)
    

    self:SetComputed("PaddingLeft", function ()
        if self:GetAnchor() == RIGHT then
            return 20
        else
            return 10
        end
    end, -10)

    self:SetComputed("PaddingRight", function ()
        if self:GetAnchor() == LEFT then
            return 20
        else
            return 10
        end
    end, -10)
    

    self:SetComputed("PaddingBottom", function ()
        if self:GetAnchor() == TOP then
            return 20
        else
            return 10
        end
    end, -10)

    self:SetComputed("Shape", function ()
        local hw, hh = Width/2, Height/2
        local a = self:GetAnchor()
        if a == BOTTOM then
            return {
                0, 10, 
                hw - 5, 10,
                hw, 0,
                hw + 5, 10,
                Width, 10,
                Width, Height,
                0, Height
            }
        elseif a == RIGHT then
            return {
                10, 0, 
                10, hh - 5,
                0, hh,
                10, hh + 5,
                10, Height,
                Width, Height,
                Width, 0
            }
        elseif a == LEFT then
            return {
                Width - 10, 0, 
                Width - 10, hh - 5,
                Width, hh,
                Width - 10, hh + 5,
                Width - 10, Height,
                0, Height,
                0, 0
            }
        elseif a == TOP then
            return {
                0, Height - 10, 
                hw - 5, Height - 10,
                hw, Height,
                hw + 5, Height - 10,
                Width, Height - 10,
                Width, 0,
                0, 0
            }
        end
    end, 0)
end

function PANEL:Paint(w, h)
    --ix.util.DrawBlur(self, 5)
    BaseClass.Paint(self, w, h)
end

vgui.Register("Tooltip", PANEL, "Popover")
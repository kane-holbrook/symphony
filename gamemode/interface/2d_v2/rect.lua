AddCSLuaFile()
if SERVER then 
    return
end 

local RECT = Interface.Register("Rect", "Panel")

-- Align
RECT:CreateProperty("Align", Type.Number)
RECT:CreateProperty("Flow", Type.Number, { Parse = function (v)
    v = string.lower(v)
    if v == "right" then
        return 0
    elseif v == "down" then
        return 1
    end
end })
RECT:CreateProperty("Gap", Type.Number, { Parse = Interface.ExtentW })
RECT:CreateProperty("PaddingLeft", Type.Number, { Parse = Interface.ExtentW })
RECT:CreateProperty("PaddingTop", Type.Number, { Parse = Interface.ExtentH })
RECT:CreateProperty("PaddingRight", Type.Number, { Parse = Interface.ExtentW })
RECT:CreateProperty("PaddingBottom", Type.Number, { Parse = Interface.ExtentH })


-- Display
RECT:CreateProperty("Fill", Type.Color)
RECT:CreateProperty("Stroke", Type.Color)
RECT:CreateProperty("StrokeWidth", Type.Color)
RECT:CreateProperty("Shadow", Type.Color)
RECT:CreateProperty("ShadowSize", Type.Number)
RECT:CreateProperty("TopLeftRadius", Type.Number)
RECT:CreateProperty("TopRightRadius", Type.Number)
RECT:CreateProperty("BottomLeftRadius", Type.Number)
RECT:CreateProperty("BottomRightRadius", Type.Number)

function RECT.Prototype:Initialize()
    base(self, "Initialize")
    self:SetFill(color_transparent)
    self:SetAlign(7)
    self:SetFlow(0)
    self:SetGap(0)
    self:SetPaddingLeft(0)
    self:SetPaddingTop(0)
    self:SetPaddingRight(0)
    self:SetPaddingBottom(0)
end

function RECT.Prototype:Paint(w, h)
    base(self, "Paint", w, h)

    self:PaintMask(w, h)
    self:PaintShadow(w, h)
    self:PaintBorder(w, h)
    self:PaintBackground(w, h)
end

function RECT.Prototype:PaintMask(w, h)
    -- Handles masking
end

function RECT.Prototype:PaintShadow(w, h)
    -- Handles masking
end

function RECT.Prototype:PaintBorder(w, h)
    -- Handles masking
end

function RECT.Prototype:PaintBackground(w, h)
    surface.SetDrawColor(self:GetFill())
    surface.DrawRect(0, 0, w, h)
end

function RECT.Prototype:PerformRefresh(ctx)
    base(self, "PerformRefresh", ctx)
    self:LayoutChildren()
end

function RECT.Prototype:GetContentBox()
    local x, y = self.Env["PaddingLeft"] or 0, self.Env["PaddingTop"] or 0
    local w, h = self.Env["Width"] or 0, self.Env["Height"] or 0
    w = w - (self.Env["PaddingRight"] or 0) - (self.Env["PaddingLeft"] or 0)
    h = h - (self.Env["PaddingBottom"] or 0) - (self.Env["PaddingTop"] or 0)
    return x, y, w, h
end

function RECT.Prototype:LayoutChildren()
    local align = self:GetAlign()
    local flow = self:GetFlow()
    local gap = self:GetGap()

    local x, y, w, h = self:GetContentBox()

    for k, v in pairs(self:GetChildren()) do
        -- If width or height is true
    end
end
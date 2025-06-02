AddCSLuaFile()
if SERVER then 
    return 
end
local SLIDER = Interface.RegisterFromXML("Slider", [[
    <Rect 
        Width="100%" 
        Height="5ss"
        Align="5"
        Hover="true"
        Cursor="hand"
        Value="0"
        :DisplayValue="tostring(math.Round(Value, 2))"
    >
        <Rect Name="Bar" :Width="Parent.Width - ScreenScale(5)" Height="1" :Fill="IsHovered and Color(255, 255, 255, 32) or Color(255, 255, 255, 16)">
            <Rect Name="Handle"
                Absolute="true"
                :X="(Parent.Width * Value) - Width/2"
                :Y="-Height/2"
                Width="5ss" 
                Height="5ss" 
                Fill="White"
                :Material="RadialGradient(
                    Color(0, 14, 30, 254),
                    0.0,
                    Color(0, 48, 120, 254),
                    0.5,
                    Color(0, 14, 30, 254)
                )" 
                Cursor="hand"
                On:MousePressed="function (src, btn)
                    self:GetParent():GetParent():StartDrag()
                end"
                :Shape="function (pnl, w, h) return CirclePoly(pnl, w, h, 16) end"
            >
                <Popover Name="Hint" :OffsetY="Parent.Height + 6" FontSize="6" Align="5">
                    <Text :Content="tostring(DisplayValue)" />
                </Popover>
            </Rect>
        </Rect>
    </Rect>
]])
SLIDER:CreateProperty("Value", Type.Number, { Default = 0 })
SLIDER:CreateProperty("Min", Type.Number, { Default = 0 })
SLIDER:CreateProperty("Max", Type.Number, { Default = 1 })
SLIDER:CreateProperty("Step", Type.Number, { Default = 0.01 })
SLIDER:CreateProperty("DisplayValue", Type.String, { Default = "" })

function SLIDER.Prototype:StartDrag()
    self.Bar.Handle.Hint:Open()

    local p = self.Bar.Handle:GetPanel()
    local ax, ay = p:ScreenToLocal(gui.MousePos())
    
    
    hook.Add("Think", self, function ()
        if not input.IsMouseDown(MOUSE_LEFT) then
            self:StopDrag()
            return
        end

        local rp = self:GetPanel()
        local mx, my = rp:ScreenToLocal(gui.MousePos())

        mx = math.Clamp(mx , 0, self:GetWidth())

        local value = mx / self:GetWidth()
        self:SetValue(value)
        self:InvalidateLayout(true)
    end)
end

function SLIDER.Prototype:StopDrag()
    self.Bar.Handle.Hint:Close()
    hook.Remove("Think", self)
end

function SLIDER.Prototype:OnMousePressed(mouse)
    base(self, "OnMousePressed", mouse)

    local mx, my = gui.MousePos()
    local rp = self.Bar:GetPanel()
    mx, my = rp:ScreenToLocal(mx, my)
    mx = math.Clamp(mx, 0, self:GetWidth())
    local value = mx / self:GetWidth()
    self:SetValue(value)
    self:InvalidateLayout(true)

    if mouse == MOUSE_LEFT then
        self:StartDrag()
        return true
    end

    return false
end

function SLIDER.Prototype:PerformLayout()
    base(self, "PerformLayout")

    local p = self.Bar.Handle:GetPanel()
    if p then
        p:NoClipping(true)
    end
end

function SLIDER.Prototype:OnDisposed()
    base(self, "OnDisposed")
    self:StopDrag()
end
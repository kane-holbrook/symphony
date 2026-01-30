
AddCSLuaFile()

if SERVER then
    return
end

DEFINE_BASECLASS("Rect")

local PANEL = vguix.RegisterFromXML("SSTRP.Slider", [[
    <Rect Name="Component" Width="100%" Height="24" Hover="true" Cursor="hand">
        <Rect Name="Handle" Absolute="true" Hover="true" Cursor="hand" Func:LeftClick="function () return self:InvokeParent('ClickHandle') end" Width="24" Height="24" 
            :X="math.Remap(Value, Min, Max, 0, Parent.Width - 24)" 
            :Shape="RoundedBox(Width, Height, Height/2, Height/2, Height/2, Height/2)" 
            :Fill="IsHovered and Color(255, 255, 255, 192) or Color(255, 255, 255, 64)"
        >
            <Tooltip Name="Tooltip" Func:VisibleFunc="Component.Dragging or self:GetParent():GetFuncEnv('IsHovered')">
                <Text :Value="Component:DisplayValue()" />
            </Tooltip>
        </Rect>
    </Rect>
]])
vguix.AccessorFunc(PANEL, "Value", "Value", "Number")
vguix.AccessorFunc(PANEL, "DP", "DP", "Number")
vguix.AccessorFunc(PANEL, "Min", "Min", "Number")
vguix.AccessorFunc(PANEL, "Max", "Max", "Number")

function PANEL:SetValue(value)
    self.Value = math.Clamp(math.Round(value, self:GetDP()), self:GetMin(), self:GetMax())
    self:GetFuncEnv()["Value"] = self.Value
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, h*0.25, w, h/2, Color(255, 255, 255, 16))
end

function PANEL:Init()
    self:SetMin(0)
    self:SetMax(1)
    self:SetDP(2)
    self:SetValue(0)
end

function PANEL:DisplayValue()
    return tostring(self.Value)
end

function PANEL:ClickHandle()
    -- how far into the handle you clicked (0 – 16)
    local clickOffsetX = self.Handle:ScreenToLocal(gui.MouseX(), 0)
    self.Dragging = true

    hook.Add("Think", self, function()
        -- stop dragging once mouse is up
        if not input.IsMouseDown(MOUSE_LEFT) then
            hook.Remove("Think", self)
            self.Dragging = false
            self:InvalidateChildren(true)
            return
        end

        -- mouse pos in slider coords:
        local mouseX, _ = self:ScreenToLocal(gui.MouseX(), 0)

        -- where handle's left edge *should* be:
        local handleLeft = mouseX - clickOffsetX
        handleLeft = math.Clamp(
          handleLeft,
          0,
          self:GetWide() - self.Handle:GetWide()
        )

        -- fraction along track (0–1):
        local frac = handleLeft / (self:GetWide() - self.Handle:GetWide())

        -- new value in [Min,Max]:
        local newValue = math.Round(math.Remap(frac, 0, 1, self:GetMin(), self:GetMax()), self:GetDP())

        if newValue ~= self:GetValue() then
            self:SetValue(newValue)
            debounce(self, 0.05, function()
                self:Invoke("ChangeValue", newValue)
            end)
        end

        -- re-layout with new X binding
        self:InvalidateChildren(true)
    end)

    return true
end
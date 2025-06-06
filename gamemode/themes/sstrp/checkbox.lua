AddCSLuaFile()
if SERVER then 
    return 
end
local Checkbox = Theme.Default:RegisterFromXML("Checkbox", [[
    <Rect Align="7" Flow="X" Hover="true" Cursor="hand" 
        On:MousePressed="function (src)
            if not self.Propagate then
                self:SetChecked(not self:GetChecked())
                self:InvalidateLayout()
                return true
            end
        end">
        <Rect 
            Width="1ch"
            Height="1ch"
            Align="5"
            Fill="white"
            :Material="self:GetParent():GenerateBackground()"
            StrokeWidth="1"
            :Stroke="IsHovered and _G.Color(255, 255, 255, 32) or _G.Color(255, 255, 255, 16)"
            MarginRight="3cw"
        >
            <Label Text="✓" FontSize="7" :Display="Checked" />
        </Rect>
        
    </Rect>
]])
Checkbox:CreateProperty("Color", Type.Color, { Default = Color(0, 14, 30, 254) })
Checkbox:CreateProperty("Value", Type.Bool, { Default = false })
Checkbox:CreateProperty("Checked", Type.Bool)
Checkbox:CreateProperty("Propagate", Type.Bool, { Default = false })

function Checkbox.Prototype:GenerateBackground()
    local col = self:GetColor()
    local col2 = col:Darken(0.5)
    
    local c1 = ColorAlpha(col, self.IsHovered and 254 or 90)
    local c2 = ColorAlpha(col2, self.IsHovered and 254 or 90)

    return RadialGradient(
        c1,
        0.5,
        c2,
        0.75,
        c1
    )

end

function Checkbox.Prototype:PerformLayout()
    base(self, "PerformLayout")

    if not self:GetValue() then
        local children = self:GetChildren()
        assert(#children == 2, "Checkbox must have just text or a value defined.")

        local child = children[2]
        assert(child and child.GetText, "Checkbox must have a Label element as its child.")

        self:SetValue(child:GetText())
    end
end
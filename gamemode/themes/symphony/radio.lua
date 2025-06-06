AddCSLuaFile()
if SERVER then 
    return 
end
local Radio = Theme.Symphony:RegisterFromXML("Radio", [[
    <Rect Align="7" Flow="X" Hover="true" Cursor="hand" :Checked="Parent.Value and Parent.Value == self:GetValue()" On:MousePressed="function (src)
        if src ~= self then
            self:EmitParent('MousePressed') -- Re-emit from ourself
        end
        return true
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
            :Shape="function (pnl, w, h) return CirclePoly(pnl, w, h, 32) end"
        >
            <Rect 
                Width="0.5ch"
                Height="0.5ch"
                Fill="white"
                StrokeWidth="1"
                Stroke="Color(255, 255, 255, 16)"
                :Display="Checked == true"
                :Shape="function (pnl, w, h) return CirclePoly(pnl, w, h, 32) end"
            />
        </Rect>
        
    </Rect>
]])
Radio:CreateProperty("Color", Type.Color, { Default = Color(15, 2, 21, 254) })
Radio:CreateProperty("Checked", Type.Bool)
Radio:CreateProperty("Value")

function Radio.Prototype:GenerateBackground()
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

function Radio.Prototype:PerformLayout()
    base(self, "PerformLayout")

    if not self:GetValue() then
        local children = self:GetChildren()
        assert(#children == 2, "Radio must have just text or a value defined.")

        local child = children[2]
        assert(child and child.GetText, "Radio must have a Label element as its child.")

        self:SetValue(child:GetText())
    end
end
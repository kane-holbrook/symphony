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
            :Shape="{
                0, ScreenScale(1.5),
                ScreenScale(1.5), 0, -- Top left corner
                Width - ScreenScale(1.5), 0,
                Width, ScreenScale(1.5), -- Top right corner
                Width, Height - ScreenScale(1.5), -- Bottom right corner
                Width - ScreenScale(1.5), Height, -- Bottom right corner
                ScreenScale(1.5), Height, -- Bottom left corner
                0, Height - ScreenScale(1.5), -- Bottom left corner
            }"
        >
            <Rect 
                Width="0.5ch"
                Height="0.5ch"
                Fill="white"
                StrokeWidth="1"
                Stroke="Color(255, 255, 255, 16)"
                :Display="Checked == true"
                :Shape="function (pnl, w, h) return CirclePoly(pnl, w, h, 8) end"
            />
        </Rect>
        
    </Rect>
]])
Radio:CreateProperty("Color", Type.Color, { Default = Color(0, 14, 30, 254) })
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
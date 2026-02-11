AddCSLuaFile()

if SERVER then
    return
end

-- Text
do
    local Text = Interface.Register("Text", PNL)
    Text:CreateProperty("Value", Type.String, { Default = "" })
    Text:CreateProperty("Wrap", Type.Boolean, { Default = false })

    function Text.Prototype:Initialize()
        base(self, "Initialize")
    end

    function Text.Prototype:PerformLayout(noPropagate)
        self.Lines = string.Split(self:Compute("Value"), "\n")

        if self:GetWrap() then
            local mw = self:Compute("Width")
            
            local out = {}
            surface.SetFont(self:GetFont())
            for _, l in pairs(self.Lines) do
                local current = {}
                local w = 0
                for _, word in pairs(string.Split(l, " ")) do
                    local tw, th = surface.GetTextSize(word .. " ")
                    if w + tw > mw then
                        table.insert(out, table.concat(current, " "))
                        current = { word }
                        w = tw
                    else
                        table.insert(current, word)
                        w = w + tw
                    end
                end

                if #current > 0 then
                    table.insert(out, table.concat(current, " "))
                end

                self.Lines = out
            end
        end

        return base(self, "PerformLayout", noPropagate)
    end

    function Text.Prototype:SetWidth(value)
        self:SetComputed("Width", nil)
        self.WidthMode = 0

        if value == nil then
            self:SetComputed("Width", function (self)
                if not self.Lines then
                    self:InvalidateLayout(true)
                end

                local w = 0
                for k, v in pairs(self.Lines) do
                    surface.SetFont(self:GetFont())
                    local tw, th = surface.GetTextSize(v)
                    w = math.max(w, tw)
                end

                self.WidthMode = 1
                return w 
            end)
            return self
        else
            return base(self, "SetWidth", value)
        end
    end

    function Text.Prototype:SetHeight(value)
        self:SetComputed("Height", nil)
        self.HeightMode = 0

        if value == nil then
            self:SetComputed("Height", function (self)
                if not self.Lines then
                    self:InvalidateLayout(true)
                end
                
                local h = 0
                for k, v in pairs(self.Lines) do
                    surface.SetFont(self:GetFont())
                    local tw, th = surface.GetTextSize(v)
                    h = h + th
                end

                self.HeightMode = 1
                return h 
            end)
            return self
        else
            return base(self, "SetHeight", value)
        end
    end

    function Text.Prototype:Paint()
        base(self, "Paint")

        local txt = self:Compute("Value")
        if txt ~= self.Last then
            self:InvalidateLayout(true)
        end

        if self:Compute("Visible") then
            self:SetScissorRect()
            if self.Lines then
                local y = 0
                surface.SetFont(self:GetFont())
                for k, v in pairs(self.Lines) do
                    local _, th = surface.GetTextSize(v)
                    surface.SetTextPos(0, y)
                    surface.SetTextColor(self:GetTextColor())
                    surface.DrawText(v)
                    y = y + th
                end
            end

            if self.PaintAfter then
                self:PaintAfter()
            end
            
            render.SetScissorRect(0, 0, 0, 0, false)
        end

        self.Last = txt
    end
end

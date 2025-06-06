AddCSLuaFile()
if SERVER then
    return
end

local TEXT = Theme.Symphony:Register("Label")
TEXT:CreateProperty("Text", Type.String, { Default = "" })

function TEXT.Prototype:Initialize()
    base(self, "Initialize")
    self:SetSize("auto", "auto")
end

function TEXT.Prototype:CalculateBounds()
    return self:GetChildrenSize()
end

function TEXT.Prototype:GetChildrenSize()
    self:RenderProperty("Text")
    
    surface.SetFont(self:GetFont())
    
    self.Lines = string.Split(self:GetText(), "\n")
    for k, v in pairs(self.Lines) do
        self.Lines[k] = string.Trim(v)
    end

    local p = self:GetParent()

    if self:IsSizingAuto() and not p:IsWidthAuto() then
        local w = p:GetWidth() - p:GetPaddingLeft() - p:GetPaddingRight()
        local lines = {}
        
        local spacer = surface.GetTextSize(" ")

        for k, v in pairs(self.Lines) do
            local buf = {}
            local bw = 0
            
            for _, word in pairs(string.Split(string.Trim(v), " ")) do

                local tw, th = surface.GetTextSize(word)
                if bw + tw > w then
                    table.insert(lines, table.concat(buf, " "))
                    buf = { word }
                    bw = tw + spacer
                else
                    table.insert(buf, word)
                    bw = bw + tw + spacer
                end
            end    

            if #buf > 0 then
                table.insert(lines, table.concat(buf, " "))
            end
        end

        self.Lines = lines
    end

    local w, h = 0, 0
    for k, v in pairs(self.Lines) do
        local tw, th = surface.GetTextSize(v)
        w = math.max(w, tw)
        h = h + th
    end

    self.Width = w
    self.Height = h

    self:RenderProperty("X")
    self:RenderProperty("Y")

    return self:RenderProperty("Width"), self:RenderProperty("Height")
end

function TEXT.Prototype:Paint(w, h)
    base(self, "Paint", w, h)

    
    surface.SetFont(self:GetFont())
    surface.SetTextColor(self.Cache.FontColor)
    local y = 0


    for k, v in pairs(self.Lines) do
        
        local tx, ty = surface.GetTextSize(v)
        local x = 0

        for i=1, self.Cache.FontShadow do
            surface.SetTextColor(0, 0, 0, 255 * (i / self.Cache.FontShadow))
            surface.SetTextPos(x + 1 + i, y + 1 + i)
            surface.DrawText(v)
        end

        surface.SetTextColor(self.Cache.FontColor)
        surface.SetTextPos(x, y)
        surface.DrawText(v, self.Cache.FontAdditive)
        
        y = y + ty
    end

end
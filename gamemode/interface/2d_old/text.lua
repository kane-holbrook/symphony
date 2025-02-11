AddCSLuaFile()
if SERVER then
    return
end

local PANEL = {}
PANEL.IsXLabel = true

function PANEL:Init()
    self:SetProperty("Content", "")
    self:SetProperty("Flex", 4)
end

function PANEL:OnPropertyChanged(name, value, old)
    Rect.OnPropertyChanged(self, name, value, old)

    if name == "Content" then
        self.Lines = string.Split(value, "\n")
    end
end

function PANEL:CalculateSize()

    surface.SetFont(self:CalculateFont())

    local x2, y2 = surface.GetTextSize(self:GetProperty("Content", true) or "")

    self:SetSize(x2, y2)
    return x2, y2
end

function PANEL:CalculateName()
    local t = Rect.CalculateName(self)
    return t .. "[\"" .. stringex.Truncate(tostring(self:GetProperty("Content", true) or ""), 16) .. "\"]"
end

function PANEL:Paint(w, h)
    surface.SetTextColor(self.FuncEnv.FontColor)
    surface.SetFont(self.FuncEnv.Font)

    if self.Lines then
        local mh = 0
        for k, v in pairs(self.Lines) do
            surface.SetTextPos(0, mh)
            surface.DrawText(v)
            
            local x, y = surface.GetTextSize(v)
            mh = mh + y
        end
    else
        surface.SetTextPos(0, 0)
        surface.DrawText(self.FuncEnv.Text)        
    end
end

function PANEL:ParseContent(text, node, ctx)
    self:SetProperty("Content", text)
end
vgui.Register("Text", PANEL, "Rect")


local function RegisterTypography(name, size, weight)
    vgui.Register(name, {
        Init = function(self)
            self:SetProperty("FontSize", size)
            self:SetProperty("FontWeight", weight)
        end
    }, "Text")
end

RegisterTypography("h1", 14, 700)
RegisterTypography("h2", 12, 700)
RegisterTypography("h3", 10, 700)
RegisterTypography("h4", 8, 700)
RegisterTypography("h5", 6, 700)
RegisterTypography("h6", 5, 700)
RegisterTypography("p", 6, 400)
RegisterTypography("small", 4.5, 400)

local wp = vgui.GetWorldPanel()

-- GMod default: 13px Tahoma, anti-aliased.
wp:SetProperty("FontName", "Tahoma")
wp:SetProperty("FontSize", 4.5)
wp:SetProperty("FontWeight", 400)
wp:SetProperty("FontColor", color_white)
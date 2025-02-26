AddCSLuaFile()
if SERVER then
    return
end

local XVGUI_FONTS = XVGUI_FONTS or {}
function xvgui.Font(font, sz, weight)

    if isnumber(font) then
        sz = font
        font = nil
    end

    local ratio = ScrH()/480

    local wp = vgui.GetWorldPanel()
    font = font or wp:GetProperty("FontName") or "Tahoma"
    sz = sz or wp:GetProperty("FontSize") or 13
    weight = weight or wp:GetProperty("FontWeight") or 500

    local key = font .. ":" .. sz .. ":" .. weight
    if XVGUI_FONTS[key] then
        return key
    end

    surface.CreateFont(key, {
        font = font,
        size = sz * ratio,
        weight = weight,
        antialias = true
    })

    XVGUI_FONTS[key] = true

    return key
end


local PANEL = {}
PANEL.IsXLabel = true

function PANEL:Init()
    self:SetProperty("Text", "")
    self:SetProperty("Flex", 4)
end

function PANEL:OnPropertyChanged(name, value, old)
    XPanel.OnPropertyChanged(self, name, value, old)

    if name == "Text" then
        self.Lines = string.Split(value, "\n")
    end
end

function PANEL:CalculateSize()

    surface.SetFont(self:CalculateFont())

    local x2, y2 = surface.GetTextSize(self:GetProperty("Text", true) or "")

    self:SetSize(x2, y2)
    return x2, y2
end

function PANEL:CalculateName()
    local t = XPanel.CalculateName(self)
    return t .. "[\"" .. stringex.Truncate(tostring(self:GetProperty("Text", true) or ""), 16) .. "\"]"
end

function PANEL:Paint(w, h)
    --XPanel.Paint(self, w, h)

    surface.SetTextColor(self.FuncEnv.FontColor)
    surface.SetFont(self:CalculateFont())

    if self.Lines then
        local mh = 0
        for k, v in pairs(self.Lines) do
            surface.SetTextPos(0, mh)
            surface.DrawText(v)
            
            local x, y = surface.GetTextSize(v)
            mh = mh + y
        end     
    end
end

function PANEL:XMLHandleText(text, node, ctx)
    self:SetProperty("Text", text)
end
vgui.Register("XLabel", PANEL, "XPanel")

local wp = vgui.GetWorldPanel()

-- GMod default: 13px Tahoma, anti-aliased.
wp:SetProperty("FontName", "Tahoma")
wp:SetProperty("FontSize", 4.5)
wp:SetProperty("FontWeight", 400)
wp:SetProperty("FontColor", color_white)


hook.Add("OnScreenSizeChanged", "XVGUI", function ()
    XVGUI_FONTS = {}
end)
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
    self:SetProperty("Wrap", false)
end

function PANEL:OnPropertyChanged(name, value, old)
    XPanel.OnPropertyChanged(self, name, value, old)

    if name == "Text" then
        self:CalculateWrap(value)
    end
end

function PANEL:CalculateWrap(value)
    self.Lines = {}

    if self:GetProperty("Wrap", true) then
       
        local words = string.Split(self:GetProperty("Text", true) or "", " ")

        self.Lines = {}

        local x = 0
        local y = 0
        local h2 = 0
        for k, v in pairs(words) do
            local w, h = surface.GetTextSize(v)
            h2 = h

            if x + w > self:GetWide() then
                y = y + h
                x = 0
            end

            if not self.Lines[y] then
                self.Lines[y] = ""
            end

            self.Lines[y] = self.Lines[y] .. v .. " "
            x = x + w
        end
        self.WrapW = x
        self.WrapH = y + h2/2

    else
        self.Lines = string.Split(value or self:GetProperty("Text", true), "\n")
    end
end

function PANEL:CalculateSize()

    if self:GetProperty("Wrap", true) then
        self:SetSize(self.WrapW, self.WrapH)
        return self.WrapW, self.WrapH
    end

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
        local flex = self:GetProperty("Flex", true) or 7
        for k, v in pairs(self.Lines) do
            
            local x, y = 0, mh
            local w2, h2 = surface.GetTextSize(v)

            if isany(flex, 8, 5, 2) then
                x = (w - w2) / 2
            elseif isany(flex, 9, 6, 3) then
                w = w - w2
            end

            surface.SetTextPos(x, mh)
            surface.DrawText(v)
            mh = mh + h2
            
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
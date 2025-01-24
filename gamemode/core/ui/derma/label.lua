if SERVER then
    return
end

sym.FontCache = {}

local PANEL = {}
PANEL.IsSymLabel = true

function PANEL:Init()
    self:SetProperty("Text", "")
    self:SetProperty("Flex", 4)
end

function PANEL:OnPropertyChanged(name, value, old)
    XPanel.OnPropertyChanged(self, name, value, old)
end

function PANEL:CalculateSize()
    
    local mw, mh = XPanel.CalculateSize(self)

    surface.SetFont(self:CalculateFont())

    local x2, y2 = surface.GetTextSize(self:GetProperty("Text"))
    mw = math.max(mw, x2)
    mh = math.max(mh, mh + y2)

    self:SetSize(mw, mh)
    return mw, mh
end

function PANEL:CalculateName()
    local t = XPanel.CalculateName(self)
    return t .. "[\"" .. stringex.Truncate(tostring(self:GetRawProperty("Text")), 16) .. "\"]"
end

function PANEL:Paint(w, h)
    XPanel.Paint(self, w, h)

    surface.SetTextColor(self:GetProperty("FontColor"))

    surface.SetFont(self:CalculateFont())

    local lines = string.Split(self:GetProperty("Text") or "", "\n")
    local mh = 0
    for k, v in pairs(lines) do
        surface.SetTextPos(0, mh)
        surface.DrawText(v)
        
        local x, y = surface.GetTextSize(v)
        mh = mh + y
    end
end

function PANEL:XMLHandleText(text)
    local l = vgui.Create("SymLabel", self)
    l:SetProperty("Text", text)
end

vgui.Register("SymLabel", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontWeight", 800)
end
vgui.Register("b", PANEL, "XPanel")

local PANEL = {}
vgui.Register("p", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontSize", 5)
end
vgui.Register("small", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontSize", 14)
end
vgui.Register("h1", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontSize", 12)
end
vgui.Register("h2", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontSize", 10)
end
vgui.Register("h3", PANEL, "XPanel")

local PANEL = {}
function PANEL:Init()
    self:SetProperty("FontSize", 8)
end
vgui.Register("h4", PANEL, "XPanel")


local wp = vgui.GetWorldPanel()
wp:SetProperty("FontName", "Oxanium")
wp:SetProperty("FontSize", 7)
wp:SetProperty("FontWeight", 400)
wp:SetProperty("FontColor", color_white)
wp:SetProperty("Cursor", "none")

--[[

function SymLabel(parent, text, font, data)
    local p = vgui.Create("SymLabel", parent)
    
    data = data or {}
    data.Font = data.Font or font
    data.Text = data.Text or text
    XPanel.Set(p, data)

    return p
end


local PANEL = {}
function PANEL:Paint(w, h)
    XPanel.Paint(self, w, h)

    local y = 0
    for k, v in pairs(self.Lines) do
        surface.SetTextColor(self:GetColor())
        
        local font = tostring(self:GetFont())
        if not isstring(font) then
            return
        end
        
        surface.SetFont(font)
        surface.SetTextPos(0, y)
        surface.DrawText(v)

        local _, y2 = surface.GetTextSize(v)
        y = y + y2
    end
end

function PANEL:GetTextHeight()
    return self.TextHeight
end

PANEL.CalculateSize = XPanel.CalculateSize

function PANEL:PerformLayout(w, h)
    w, h = XPanel.PerformLayout(self, w, h)

    local txt = self:GetText()

    local font = tostring(self:GetFont())
    if not isstring(font) then
        return
    end
    surface.SetFont(font)
    
    local lines = {}
    
    local line = {}
    local word = {}
    local word_idx = 1

    local tw, th = 0, 0

    local spaceSz, lh = surface.GetTextSize(" ")

    for i=1, #txt do
        local c = txt[i]

        --[[if c == "\n" then
            table.insert(line, table.concat(buffer, ""))
            
            buffer = {}
            tw = 0
            continue
        end--]]

        -- Wrap by word
        --[[
        if c == "\n" then
            table.Add(line, word)
            word = {}
            word_idx = 1
            tw = 0
            
            table.insert(lines, line)
            line = {}
            th = th + lh
        elseif c == " " then
            table.insert(word, " ")
            table.Add(line, word)
            word = {}
            word_idx = 1

            tw = tw + spaceSz
        else
            local w2 = surface.GetTextSize(c)
            
            word[word_idx] = c
            word_idx = word_idx + 1
            
            if tw + w2 >= w then
                table.insert(lines, line)

                tw = 0
                line = word

                word = {}
                word_idx = 1
                
                th = th + lh

            end

            tw = tw + w2
        end
    end
    table.Add(line, word)
    table.insert(lines, line)
    th = th + lh

    self.TextHeight = th

    self.Lines = {}
    for i=1, #lines do
        self.Lines[i] = string.Trim(table.concat(lines[i], ""))
    end
    
    return w, h
end

vgui.Register("SymWrapLabel", PANEL, "SymLabel")


--]]
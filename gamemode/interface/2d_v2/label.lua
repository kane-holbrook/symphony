AddCSLuaFile()
if SERVER then
    return
end

local LABEL = Interface.Register("Label", "Rect")
LABEL:CreateProperty("Text", Type.String)
LABEL:CreateProperty("Additive", Type.Boolean)

function LABEL.Prototype:Initialize()
    base(self, "Initialize")    
end

function LABEL.Prototype:SizeToChildren()
    if not self:GetText() then
        return
    end

    surface.SetFont(self.Env.Font)
    local w, h = surface.GetTextSize(self:GetText())
    self:SetWidth(w)
    self:SetHeight(h)
end

function LABEL.Prototype:ReceiveEvent(event, ...)
    base(self, "ReceiveEvent", event, ...)
    
    if event == "Change:Text" or event == "Change:Font" or event == "Parent:Change:Font" then
        self:SizeToChildren()
    end
end

function LABEL.Prototype:Paint(w, h)
    base(self, "Paint", w, h)
    
    surface.SetTextPos(0, 0)
    surface.SetFont(self.Env.Font)
    surface.SetTextColor(self.Env.FontColor)
    surface.DrawText(self:GetText(), self:GetAdditive())
end
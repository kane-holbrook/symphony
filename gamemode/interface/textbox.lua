AddCSLuaFile()

if SERVER then
    return
end

local TEXTBOX = Interface.RegisterFromXML("Textbox", [[
    <Panel 
        Width="100%"
        Cursor="beam"
    >
    </Panel>
]])
TEXTBOX:CreateProperty("Value", Type.String)
TEXTBOX:CreateProperty("Placeholder", Type.String, { Default = "Enter text..." })
TEXTBOX:CreateProperty("UpdateOnType", Type.Boolean, { Default = false })
TEXTBOX:CreateProperty("CursorColor", Type.Color, { Default = Color(255, 255, 255, 255) })
TEXTBOX:CreateProperty("HighlightColor", Type.Color, { Default = Color(255, 255, 255, 192) })
TEXTBOX:CreateProperty("PlaceholderColor", Type.Color, { Default = Color(255, 255, 255, 32) })
TEXTBOX:CreateProperty("Numeric", Type.Boolean, { Default = false })

function TEXTBOX.Prototype:Initialize()
    base(self, "Initialize")

    self.TextEntry = vgui.Create("DTextEntry", Interface.VGUI)
    self.TextEntry:SetPaintedManually(true)
    self.TextEntry.Interface = self
    self.TextEntry.Paint = self.PaintTextEntry
    self.TextEntry.TestHover = self.TextEntryTestHover
    self.TextEntry.AllowInput = self.AllowInput
    self.TextEntry.OnValueChange = self.OnValueChange
    self.TextEntry.OnGetFocus = self.TextEntryGetFocus
    self.TextEntry.OnLoseFocus = self.TextEntryLoseFocus
    self.TextEntry:SetUpdateOnType(true)

    self:SetComputed("Height", function ()
        surface.SetFont(self:GetFont())
        local _, th = surface.GetTextSize("0")
        return th + 16
    end)
end

function TEXTBOX.Prototype:SetValue(val)
    self:SetProperty("Value", val)
    self.TextEntry:SetText(val)
    return self
end

function TEXTBOX.Prototype:SetNumeric(val)
    self:SetProperty("Numeric", val)
    self.TextEntry:SetNumeric(val)
    return self
end

function TEXTBOX.Prototype:TextEntryGetFocus()
    
    local intf = self.Interface
    local host = intf:GetHost()
    local p = intf
    while p do
        if p:Compute("Focusable") then
            host:SetFocus(p) 
            return
        end
        p = p:GetParent()
    end
end

function TEXTBOX.Prototype:TextEntryLoseFocus()
    local host = self.Interface:GetHost()
    if host:GetFocusedPanel() == self.Interface then
        host:SetFocus(nil)
    end
end

function TEXTBOX.Prototype:PaintTextEntry(w, h)
    local parent = self.Interface
    self:SetPos(parent:LocalToScreen(0, 0))
    self:SetFontInternal(parent:GetFont())
    
    local value = parent:Compute("Value")
    if stringex.IsBlank(value) then
        self:SetText(parent:Compute("Placeholder"))
        self:DrawTextEntryText(parent:Compute("PlaceholderColor"), parent:Compute("HighlightColor"), parent:Compute("CursorColor"))
        self:SetText("")
    else
        self:DrawTextEntryText(parent:GetTextColor(), parent:Compute("HighlightColor"), parent:Compute("CursorColor"))
    end

end

function TEXTBOX.Prototype:TextEntryTestHover(x, y)
    local p = self.Interface
    local hp = p:GetHost():GetHoveredPanel()
    if hp ~= p then
        return false
    end

    local localX, localY = self:ScreenToLocal(x, y)
    return localX >= 0 and localY >= 0 and localX <= self:GetWidth() and localY <= self:GetHeight()
end

function TEXTBOX.Prototype:AllowInput(chr)
    return self.Interface:InvokeParent("AllowInput", chr)
end

function TEXTBOX.Prototype:OnValueChange(text)

    local old = self.Interface:GetProperty("Value")
    if stringex.IsBlank(text) then
        text = nil
    end

    self.Interface:SetProperty("Value", text)
    return self.Interface:InvokeParent("ChangeValue", text, old)
end



function TEXTBOX.Prototype:PaintMesh()
    base(self, "PaintMesh")
    
    local m = Matrix()
    cam.PushModelMatrix(m)
    self.TextEntry:PaintManual()
    cam.PopModelMatrix()
end

function TEXTBOX.Prototype:PerformLayout()
    base(self, "PerformLayout")

    self.TextEntry:SetSize(self:GetWidth(), self:GetHeight())
end

function TEXTBOX.Prototype:OnMousePressed(button)
    self.TextEntry:RequestFocus()
    self.TextEntry:OnMousePressed(button)
end

function TEXTBOX.Prototype:StartHover(src, last)
    base(self, "StartHover", src, last)
end

function TEXTBOX.Prototype:EndHover(src, new)
    base(self, "EndHover", src, new)
end

function TEXTBOX.Prototype:OnDisposed()
    base(self, "OnDisposed")
    self.TextEntry:Remove()
end

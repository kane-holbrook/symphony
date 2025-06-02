AddCSLuaFile()
if SERVER then 
    return 
end
local TEXTENTRY = Interface.RegisterFromXML("TextEntry", [[
    <Rect 
        Width="100%" Height="2ch"
        Align="4"
        Hover="true" 
        Cursor="beam" 
        :Stroke="IsHovered and Color(255, 255, 255, 92) or Color(255, 255, 255, 64)" 
        StrokeWidth="1" 
        :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 118)"
        
        :Shape="{
            0, 0,
            Width, 0, -- Top left corner
            Width, Height - ScreenScale(1), -- Top right corner
            Width - ScreenScale(1), Height, -- Bottom right corner
            ScreenScale(1), Height, -- Bottom left corner
            0, Height, -- Bottom left corner
        }"
    >
        
    </Rect>
]])
TEXTENTRY:CreateProperty("Value", Type.String, { Default = "" })
TEXTENTRY:CreateProperty("Placeholder", Type.String, { Default = "" })
TEXTENTRY:CreateProperty("CursorColor", Type.Color, { Default = Color(182, 208, 216) })
TEXTENTRY:CreateProperty("HighlightColor", Type.Color, { Default = Color(0, 110, 141) })
TEXTENTRY:CreateProperty("PlaceholderColor", Type.Color, { Default = Color(128, 149, 155, 128) })

function TEXTENTRY.Prototype:Initialize()
    base(self, "Initialize")
end

function TEXTENTRY.Prototype:OnStartDisplay()
    base(self, "OnRender")

    self:GetPanel():DockPadding(ScreenScale(2), 0, ScreenScale(2), 0)
    self.TextEntry = vgui.Create("DTextEntry", self:GetPanel())
    self.TextEntry:Dock(FILL)
    self.TextEntry.m_bBackground = false

    self.TextEntry.OnValueChange = function ()
        if self.Setting then
            return
        end

        self:SetValue(self.TextEntry:GetValue())
        self:Emit("ValueChanged")
    end

    self.TextEntry.OnCursorEntered = function ()
        self:Emit("CursorEntered")
    end

    self.TextEntry.OnCursorExited = function ()
        self:Emit("CursorExited")
    end

    self.TextEntry.OnGetFocus = function ()
        self:Emit("GetFocus")
    end

    self.TextEntry.OnLoseFocus = function ()
        self:Emit("LoseFocus")
    end

end

function TEXTENTRY.Prototype:OnMousePressed(button)
    base(self, "OnMousePressed", button)

    if button == MOUSE_LEFT then
        self.TextEntry:RequestFocus()
    end
end

function TEXTENTRY.Prototype:PerformLayout()
    base(self, "PerformLayout")
    
    if self.TextEntry then
        self.TextEntry:SetFont(self:GetFont())
        self.TextEntry:SetTextColor(self.Cache.FontColor)
        self.TextEntry:SetCursorColor(self:GetCursorColor())
        self.TextEntry:SetHighlightColor(self:GetHighlightColor())
        self.TextEntry:SetPlaceholderColor(self:GetPlaceholderColor())
        self.TextEntry:SetUpdateOnType(true)

        self.TextEntry:SetPlaceholderText(self:GetPlaceholder())

        -- Causes caret to change position on hovers otherwise
        if self.TextEntry:GetText() ~= self:GetValue() then
            self.TextEntry:SetText(self:GetValue())
        end
    end
end
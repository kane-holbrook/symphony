AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("Textbox", [[
    <Rect Ref="Top"
        Hover="true" 
        Cursor="beam" 
        Height="1.25ch"
        Width="1pw"
        StrokeWidth="1" 
        Radius="2ss"
        StrokeColor="Color(255, 255, 255, 16)" 
        Fill="Material(sstrp25/ui/window-hazard.png)"
        FillColor="Color(158, 200, 213, 8)" 
        FillRepeatX="true" 
        FillRepeatY="true" 
        FillRepeatScale="0.01"
        Hover:StrokeColor="Color(255, 255, 255, 32)"
        Flex="4"
        PaddingLeft="1cw"
        PaddingRight="1cw"
        Gap="1ss"
        FontSize="12"
        FontWeight="800"
        FontColor="Color(182, 208, 216, 255)" 
        FontName="Rajdhani" 
    >
        <Rect Flex="5" Slot="Left" Height="1ph" />
        <DTextEntry Ref="TextEntry" Grow="true" :Font="Font" />
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()

    self.TextEntry.m_bBackground = false
    self.TextEntry:SetFont(xvgui.Font("Rajdhani", 8.5))
    self.TextEntry:SetTextColor(Color(182, 208, 216))
    self.TextEntry:SetCursorColor(Color(182, 208, 216))
    self.TextEntry:SetHighlightColor(Color(0, 110, 141))
    self.TextEntry:SetPlaceholderColor(Color(128, 149, 155, 128))
    self.TextEntry:SetUpdateOnType(true)

    self.TextEntry.OnValueChange = function ()
        if self.Setting then
            return
        end

        local new = self.TextEntry:GetValue()
        if self:Emit("Change:Value", new, self:GetProperty("Value", true)) then
            self.Setting = true
            self.TextEntry:SetText(self:GetProperty("Value", true))
            self.Setting = false
            return
        end

        self:SetProperty("Value", self.TextEntry:GetValue())
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

function PANEL:OnPropertyChanged(key, value)
    if XPanel.OnPropertyChanged(self, key, value) then
        return true
    end

    if key == "Value" then
        self.Setting = true
        self.TextEntry:SetValue(value)
        self.Setting = false
        self:Emit("Change:Value", value)
    end

    if key == "Placeholder" then
        self.TextEntry:SetPlaceholderText(value)
    end
end
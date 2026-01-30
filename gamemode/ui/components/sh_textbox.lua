
AddCSLuaFile()

if SERVER then
    return
end

local PANEL = vguix.RegisterFromXML("Textbox", [[
    <Rect Name="Component" Align="4" Width="100%" Height="48" FontSize="10" FontName="Orbitron" :Shape="RoundedBox(Width, Height, 8, 8, 8, 8)" MarginTop="2" Padding="8, 0" :Fill="Enabled and Color(255, 255, 255, 16) or Color(255, 255, 255, 2)">
        <DTextEntry Grow="true" Height="100%" Color:CursorColor="Color(119, 162, 255)" :Enabled="Enabled" Color:HighlightColor="Color(42, 110, 255)" Name="DTextEntry" UpdateOnType="true" :PlaceholderText="Placeholder" :Value="Value" Init:Font="self:GetSurfaceFont()" :TextColor="FontColor" PaintBackground="false"
            Func:OnChange="function (pnl, val) 
                self:InvokeParent('OnValueChanged', self:GetText()) 
            end" 
        />
    </Rect>
]])
vguix.AccessorFunc(PANEL, "Value", "Value", "String")
vguix.AccessorFunc(PANEL, "Placeholder", "Placeholder", "String")
vguix.AccessorFunc(PANEL, "Enabled", "Enabled", "Bool")


function PANEL:Init()
    self:SetValue("")
    self:SetEnabled(true)
    self:SetPlaceholder("Enter text here...")
end

function PANEL:OnValueChanged(src, txt)
    self:SetValue(txt)
    self:InvokeParent("OnValueChanged", txt) -- Re-emit
    return true
end




PANEL = vguix.RegisterFromXML("Textarea", [[
    <Rect Name="Component" Align="7" Gap="16" Width="100%" Height="144" FontSize="10" FontName="Orbitron" :Shape="RoundedBox(Width, Height, 8, 8, 8, 8)" MarginTop="2" Padding="8, 8" :Fill="Enabled and Color(255, 255, 255, 16) or Color(255, 255, 255, 2)">
        <DTextEntry Grow="true" Height="100%" Multiline="true" Color:CursorColor="Color(119, 162, 255)" :Enabled="Enabled" Color:HighlightColor="Color(42, 110, 255)" Name="DTextEntry" UpdateOnType="true" :PlaceholderText="Placeholder" :Value="Value" Init:Font="self:GetSurfaceFont()" :TextColor="FontColor" PaintBackground="false"
            Func:OnChange="function (pnl, val) 
                self:InvokeParent('OnValueChanged', self:GetText()) 
            end" 
        />
    </Rect>
]])
vguix.AccessorFunc(PANEL, "Value", "Value", "String")
vguix.AccessorFunc(PANEL, "Placeholder", "Placeholder", "String")
vguix.AccessorFunc(PANEL, "Enabled", "Enabled", "Bool")


function PANEL:Init()
    self:SetValue("")
    self:SetEnabled(true)
    self:SetPlaceholder("Enter text here...")
end

function PANEL:OnValueChanged(src, txt)
    self:SetValue(txt)
    self:InvokeParent("OnValueChanged", txt) -- Re-emit
    return true
end
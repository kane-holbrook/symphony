AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("ColorPicker", [[
    <Rect Ref="ColorPicker">
        <Textbox Ref="Input" DebugRef="true"  Width="50ss">
            <Slot Name="Left">
                <Rect Ref="Color" Width="0.3ph" Height="0.3ph" Radius="0.15ph" FillColor="Color(255, 255, 0, 255)" />
            </Slot>

            <Popover Ref="Popover">
                
            </Popover>
        </Textbox>
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()

    IColor = self
end
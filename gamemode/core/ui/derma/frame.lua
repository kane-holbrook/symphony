if SERVER then
    return
end

local PANEL = {}

function PANEL:Init()
    
    self:SetProperty("X", function () return ScrW()*0.25 end)
    self:SetProperty("Y", function () return ScrW()*0.25 end)
    self:SetProperty("Width", function () return ScrW()*0.5 end)
    self:SetProperty("Height", function () return ScrH()*0.5 end)

    xvgui.CreateFromXML([[
        <XPanel Flex="7" Direction="Y" :X="PW * 0.25" :Y="PH*0.25" :Width="PW * 0.5" :Height="PH * 0.5">
            <XPanel Ref="Header" Direction="X" Flex="4" :Padding="ScreenScale(2)" :Width="PW" :Height="ScreenScaleH(20)" :Background="{
                HTMLCircleGradient(Width, Height, Color(14, 17, 127, 255), 0, Color(0, 0, 0, 245), 95, Color(49, 56, 185, 245), 100),
                HTMLRepeatingLinearGradient(Width, Height, 0, color_transparent, '5px', Color(0, 0, 100, 255), '10px', color_transparent, '15px')
            }">
                <XPanel Ref="Content" Flex="4" Grow="true">
                    <XPanel FontSize="10" FontWeight="800">Symphony interface elements</XPanel>
                </XPanel>

                <XPanel Ref="Buttons" Flex="6">
                    <XPanel FontSize="10" FontWeight="800"></XPanel>
                </XPanel>
            </XPanel>

            <XPanel Ref="Body" Direction="Y" Grow="true" :Background="{
                HTMLCircleGradient(Width, Height, Color(14, 17, 27, 255), 0, Color(0, 0, 0, 225), 95, Color(49, 56, 85, 225), 100),
                    HTMLRepeatingLinearGradient(Width, Height, 0, color_transparent, '5px', Color(0, 0, 0, 64), '10px', color_transparent, '15px')
            }">
            TEST
            </XPanel>
        </XPanel>
    ]], self)
end
vgui.Register("SymFrame", PANEL, "XPanel")
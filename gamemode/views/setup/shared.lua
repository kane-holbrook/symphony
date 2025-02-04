if SERVER then
    return
end

local PANEL = {}

xvgui.RegisterFromXML("SymSetup", [[
    <XPanel :Width="PW" :Height="PH" :Background="Color(0, 0, 0, 255)" Flex="5" Direction="Y">
        <XPanel FontSize="13">
            Hi <XLabel :MarginLeft="ScreenScale(2.5)" FontWeight="800" :Text="LocalPlayer():Name()" />, welcome to <XPanel MarginLeft="10" FontWeight="800">Symphony</XPanel>!
        </XPanel>

        <XPanel MarginTop="32" FontSize="8">
            To begin, please enter your secure key:
        </XPanel>
    </XPanel>
]])

if IsValid(SYM_SETUP) then
    SYM_SETUP:Remove()
end

SYM_SETUP = vgui.Create("SymSetup")
SYM_SETUP:MakePopup()
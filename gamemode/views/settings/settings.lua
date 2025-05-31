AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Sym_Settings", [[
    <Rect 
        Ref="Top" 
        Width="1pw" 
        Height="1ph" 
        Flex="7" 
        FillColor="Color(0, 0, 0, 245)" 
        Blur="3"
        FontName="Rajdhani"
        FontSize="8.5"
    >
        <Rect 
            Width="1pw" 
            Gap="5ss"
            PaddingX="5ss"
            PaddingY="2.5ss"
        >
            <Rect MarginRight="2.5ss" Fill="Material(sstrp25/ui/symphony.png)" FillColor="Color(255, 255, 255, 255)" Width="1ch" Height="1ch" />
            <XLabel Text="File" />
            <XLabel Text="View" />
            <XLabel Text="Help" />
        </Rect>
    </Rect>
]])

--[[
    Console
    Exceptions

]]
function PANEL:Init()
    self:LoadXML()
end

concommand.Add("sym_dev", function()
    if IsValid(SETTINGS) then
        SETTINGS:Remove()
        return
    end

    SETTINGS = vgui.Create("Sym_Settings")
    SETTINGS:MakePopup()
end)
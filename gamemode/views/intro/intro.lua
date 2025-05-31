AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("Sym_Intro", [[
    <Rect 
        Ref="Top" 
        Width="1pw" 
        Height="1ph" 
        Flex="5"
        Direction="Y"
        Fill="Material(sstrp25/ui/views/intro/backdrop.png)"
        FillColor="Color(128, 128, 128, 255)"
        FontName="Rajdhani"
        FontSize="10"
        PaddingTop="30ss"
        PaddingLeft="15ss"
        PaddingRight="15ss"
        PaddingBottom="5ss"

    >
        <Rect Width="1pw" Height="1ph" Direction="Y" Flex="5">
            <Rect 
                Fill="Material(sstrp25/ui/logo.png)" 
                FillColor="Color(255, 255, 255, 255)"
                Width="50ss"
                Height="50ss" 
                MarginBottom="60ss"
            />

            <Rect :Display="Top.Page == 1" Direction="Y" Flex="5">
This server features mature themes that may be disturbing to some users, including:

    •   Graphic depictions of war and violence.

    •   Themes of authoritarianism, death, and trauma.

    •   Moral ambiguity and disturbing scenarios.

    •   Loud noises, explosions, and flashing lights (which may trigger photosensitive epilepsy).

This is a serious storytelling environment. Player discretion is advised.

                <Rect 
                    :On:Click="function (el, ...)
                        Top.Page = 2
                        Top:InvalidateChildren(true)
                        return true
                    end" 
                    Cursor="hand" 
                    FillColor="Color(255, 255, 255, 1)" 
                    Hover="true" 
                    Hover:FillColor="Color(255, 255, 255, 5)" 
                    Blur="4" 
                    MarginTop="30ss" 
                    Flex="5" 
                    FontSize="15" 
                    StrokeWidth="1ss" 
                    StrokeColor="Color(255, 255, 255, 255)" 
                    PaddingX="15ss" 
                    PaddingY="5ss"
                >
                    Press any key to continue
                </Rect>
            </Rect>

            <Rect Ref="Test" :Display="Top.Page == 2" Direction="Y" Flex="5">
    It looks like this is the first time you've played.

            </Rect>

            <Rect Grow="true" Flex="2" Width="1pw">
                <XLabel Wrap="true" Width="1pw" Flex="5">
                    All trademarks, logos, and brand names are the property of their respective owners. All company, product, and service names used are for identification purposes only. The use of these names, trademarks, and brands does not imply endorsement.
                </XLabel>
            </Rect>
        </Rect>
    </Rect>
]])

--[[
    Console
    Exceptions

]]
function PANEL:Init()
    self:LoadXML()
    self.Page = 1
end

concommand.Add("sym_intro", function()
    if IsValid(INTRO) then
        INTRO:Remove()
        return
    end

    INTRO = vgui.Create("Sym_Intro")
    INTRO:MakePopup()
end)
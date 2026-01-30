
if BRANCH ~= "x86-64" then
    net.Start("Symphony:NoX64")
    net.SendToServer()
    error("This server requires a 64-bit version of Garry's Mod. Please update your game.")
end

include("shared.lua")

print("Starting Symphony")


rtc.Start("Symphony:Init")
rtc.SendToServer()

rtc.Receive("Symphony:Init", function (len)
    local lp = LocalPlayer()
    local account = rtc.ReadObject()
    lp:SetAccount(account)
    lp.Characters = rtc.ReadObject()
    local active = rtc.ReadString()

    if active then
        for k, v in pairs(lp.Characters) do
            if v:GetId() == active then
                lp.Character = v
                break
            end
        end
    end

    if IsValid(TabMenu) then 
        TabMenu:Remove() 
    end

    TabMenu = vgui.Create("SSTRP.Menu")
    TabMenu:SetVisible(false)

    if table.IsEmpty(lp.Characters) then
        local p = vgui.Create('SSTRP.CreateCharacter')
        p:SetPos(0, 0)
        p.CloseButton:Remove() -- Remove close button
        p:MakePopup()

        local v = vguix.CreateFromXML(p, [[
            <SSTRP.Modal Name="Intro">
                <Rect Absolute="true" :X="Parent.Width/2 - Width/2" :Y="Parent.Height/2 - Height/2" Width="66%" Height="80%" Align="8" Flow="Y" Gap="16">
                    <Rect FontName="Eurostile Extended" FontSize="16">WELCOME TO SSTRP</Rect>
                        <Rect 
                        Cursor="none" 
                        Grow="true" 
                        Fill="white" 
                        Width="100%" 
                        Stroke="white"
                        StrokeWidth="8"
                        :StrokeMat="
                            LinearGradient(
                                Color(0, 28, 60, 255),
                                0.1,
                                Color(0, 28, 60, 192),
                                1,
                                Color(0, 6, 20, 0),
                                90
                            )
                        "

                        :Shape="RoundedBox(Width, Height, 16, 16, 16, 16)"

                        :Mat="RadialGradient(
                            Color(0, 14, 30, 128),
                            0.3,
                            Color(0, 14, 30, 128),
                            0.9,
                            Color(0, 3, 10, 128)
                        )"
                        Flow="Y"
                        Align="7"
                        Padding="32" 
                        Gap="16"
                        FontSize="9"
                        Align="5"
                    >
                        <SSTRP.HTML Grow="true" Width="100%">
                            <div style="width:66%; margin-left:auto; margin-right:auto;">
                                <div style="text-align:center">
                                    <img src="asset://garrysmod/materials/sstrp25/v2/logo128.png" width="128" height="128" /><br /><br /><br />
                                    
                                    <b>Welcome to our humble little Starship Troopers roleplay server!</b>
                                </div>
                                <br />

                                <p>If you're a new player joining for the first time, welcome. If you're a returning player, welcome back.</p>

                                <p>This 2026 iteration of SSTRP is a little different: <b><u>we are not playing as the Mobile Infantry</u>.</b></p>
                                
                                <p>Instead, we are playing as <b>The Black Cross</b>, a group of outlaw mercenaries near the SQZ on the fringes of Federation space.</p>
                                
                                <p>Our mission is to survive, get paid, and to protect the unofficial, frontier settlements from the various threats that lurk so far beyond the core worlds.</p>

                                <p>Before you proceed, it would be wise to familiarise yourself on <b><a href="#" onclick="GMod.OpenURL('https://sstrp.net/rules')" target="_blank">our rules</a></b> and read up 
                                the <b><a href="#" onclick="GMod.OpenURL('https://sstrp.net/The_Black_Cross')" target="_blank">lore of the Black Cross.</a></b></p>

                                <p>To proceed with creating your character, press the "Continue" button below.</p>

                                <p>Good hunting, trooper.</p>

                                <p style="margin-left:64;">- Xalphox</p>
                            </div>
                        
                        </SSTRP.HTML>
                        <SSTRP.Button Func:LeftClick="function ()
                            Intro:Remove()
                            ClickSound()
                        end">Continue</SSTRP.Button>
                    </Rect>

                </Rect>
            </SSTRP.Modal>
        ]])
        v:MakePopup()
    else        
        TabMenu:Open()
    end

    hook.Run("PlayerInitialized", lp)
end)

function ClickSound() 
    surface.PlaySound("symphony/ui/click.ogg")
end

function HoverSound()
	surface.PlaySound('symphony/ui/hover.ogg')
end


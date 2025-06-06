AddCSLuaFile()
if SERVER then
    return
end

local WINDOW = Theme.Default:RegisterFromXML("Window", [[
    <Rect 
        Absolute="true"
        X="25%" 
        Y="25%" 
        Width="50%" 
        Height="50%" 
        Fill="white" 
        FontFamily="Roboto"
        FontSize="7"
        :Material="RadialGradient(
            Color(6, 0, 10, 225),
            0.5,
            Color(27, 7, 33, 225),
            0.75,
            Color(9, 0, 10, 225)
        )" 
        Align="5" 
        Popup="true"
        Blur="4"
        Stroke="Color(0, 0, 0, 192)"
        StrokeWidth="1"
        Align="7"
        Flow="Y"
        Padding="2ss, 2ss, 2ss, 2ss"
        >
            <Rect Name="Header" Width="100%" Height="5ss" Flow="X" MarginBottom="2ss">
                <Rect Align="4" Width="Fill" Height="1ch">
                    <Rect Fill="white" Width="0.8ch" Height="0.8ch" :Material="Icon" MarginRight="1cw"/>
                    <Label :Text="Title" />
                </Rect>
                <Rect 
                    Name="Close" 
                    :Display="CloseButton == true"
                    Width="5ss" 
                    Height="5ss"
                    Fill="white"
                    Hover="true"
                    Cursor="hand"
                    On:MousePressed="Parent.Parent:OnClose()"
                    
                    :Material="IsHovered and
                        RadialGradient(
                            Color(137, 18, 18, 254),
                            0.3,
                            Color(120, 0, 0, 254),
                            0.5,
                            Color(120, 0, 0, 254)
                        ) 
                    or 
                        RadialGradient(
                            Color(57, 18, 18, 254),
                            0.3,
                            Color(40, 0, 0, 254),
                            0.5,
                            Color(40, 0, 0, 254)
                    )">
                </Rect>
            </Rect>

            <Rect 
                Name="_Default"
                Flow="Y"
                PaddingTop="7.5ss"
                PaddingLeft="10ss"
                PaddingRight="0"
                PaddingBottom="7.5ss"
                Width="100%"
                Height="Fill"
                Stroke="Color(255, 255, 255, 16)" 
                StrokeWidth="1"
                Grow="true"
                Fill="Color(0, 0, 0, 128)"
                Align="7"
            />
    </Rect>
]])

WINDOW:CreateProperty("Title", Type.String, { Default = "" })
WINDOW:CreateProperty("Icon", Type.Material, { Default = Material("symphony/logo64.png", "smooth noclamp") })
WINDOW:CreateProperty("CloseButton", Type.Boolean, { Default = true })

function WINDOW.Prototype:OnClose()
    self:Dispose()
    return true
end
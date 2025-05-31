AddCSLuaFile()
if SERVER then
    return
end

local PANEL = Interface.RegisterFromXML("Window", 
[[
    <Rect 
        :Top="self"
        FontColor="182 208 216 255" 
        FontName="Rajdhani" 
        FontSize="8.5" 
        FillColor="0 0 0 245" 
        Radius="5"
        Flow="Y"
        Gap="1"
        Popup="true"
    > 
        <Rect 
            Ref="Header" 
            FontName="Orbitron SemiBold" 
            FontColor="158 200 213 255"
            FontSize="12"
            Align="4"
            Gap="4"
            Width="100%"
            MarginBottom="5"
            >

            <Rect 
                Fill="sstrp25/ui/window-hazard.png"
                FillColor="255, 255, 255, 22" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.1" 
                Width="2cw" 
                Height="100%" 
                Radius="0.25cw"
            />

            <Label Ref="TitleElement" :Text="Title">
                <Listen Debug="true" Event="Parent:Change:Title" Properties="Text" />
            </Label>

            <Rect
                Fill="sstrp25/ui/window-hazard.png"
                FillColor="255, 255, 255, 22" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.1" 
                Grow="true"
            />

            <Rect Gap="1.5" Align="7" Height="100%">
                
                <Rect 
                    StrokeWidth="1" 
                    Width="0.5cw" 
                    Height="0.5cw" 
                    Radius="0.25cw" 
                    Align="7" 
                    StrokeColor="255, 255, 255, 16" 
                    StrokeWidth="0.5" 
                    Padding="0" 
                    Hoverable="true"
                    :FillColor="Hovered and Color(173, 0, 0) or Color(97, 0, 0, 98)"
                    On:Click="function (...) Top:Remove() end"
                    Cursor="hand"
                >
                </Rect>
            </Rect>

        </Rect>
    </Rect>
]])
PANEL:CreateProperty("Draggable", Type.Boolean)
PANEL:CreateProperty("Sizeable", Type.Boolean)
PANEL:CreateProperty("Closeable", Type.Boolean)
PANEL:CreateProperty("Title", Type.String)

function PANEL.Prototype:Initialize()
    base(self, "Initialize")
    self:SetTitle("Window")
    self:SetDraggable(true)
    self:SetSizeable(true)
    self:SetCloseable(true)
    self:Setup()
end
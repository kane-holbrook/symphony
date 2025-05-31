AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Character_Create", [[
    <Rect Ref="Top" Width="1pw" Height="1ph" Flex="5" FillColor="Color(0, 0, 0, 255)">
        <Rect 
            Fill="Material(sstrp25/ui/window-hazard.png)"
            FillColor="Color(139, 139, 139, 3)"
            FillRepeatX="true"
            FillRepeatY="true"
            FillRepeatScale="1"
            Grow="true"
            Width="1pw"
            Height="1ph"
            Flex="8"
            Direction="Y"
            Padding="5ss"
            Gap="15ss"
        >  
            <Rect 
                Ref="Header"
                FontName="Orbitron SemiBold" 
                FontColor="Color(158, 200, 213, 255)"
                FontSize="16"
                Flex="4"
                Width="1pw"
                Direction="X"
                Gap="5ss"
            >
                <Rect 
                    Fill="Material(sstrp25/ui/window-hazard.png)"
                    FillColor="Color(158, 200, 213, 32)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.1" 
                    Width="4cw" 
                    Height="1ph" 
                    TopLeftRadius="0.5ph"
                    BottomLeftRadius="0.5ph"
                    PaddingLeft="4ss"
                    PaddingRight="4ss"
                    MarginTop="4ss"
                    MarginBottom="5ss"
                />

                <XLabel Text="Create a character" />

                <Rect 
                    Fill="Material(sstrp25/ui/window-hazard.png)"
                    FillColor="Color(158, 200, 213, 32)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.1" 
                    Grow="true"
                    Height="1ph" 
                    TopRightRadius="0.5ph"
                    BottomRightRadius="0.5ph"
                    PaddingLeft="4ss"
                    PaddingRight="4ss"
                    MarginTop="4ss"
                    MarginBottom="5ss"
                />
            </Rect>

            <Rect Grow="true" Flex="7">
                <Rect 
                    Width="0.33pw" 
                    Height="1ph"
                    Direction="Y"
                    Gap="5ss"
                >
                    <Rect 
                        FontName="Orbitron SemiBold" 
                        FontColor="Color(158, 200, 213, 255)"
                        FontSize="12"
                        Flex="4"
                        Width="1pw"
                        Direction="X"
                        Gap="2.5ss"
                    >
                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Width="4cw" 
                            Height="1ph" 
                            TopLeftRadius="0.5ph"
                            BottomLeftRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginTop="4ss"
                            MarginBottom="5ss"
                        />

                        <XLabel Text="Character" />

                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Grow="true"
                            Height="1ph" 
                            TopRightRadius="0.5ph"
                            BottomRightRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginTop="4ss"
                            MarginBottom="5ss"
                        />
                    </Rect>
                
                    <Rect
                        Width="1pw"
                        Grow="true"
                        Flex="4"
                        FillColor="Color(12, 12, 12, 225)"
                        Radius="5ss"
                        StrokeWidth="1"
                        StrokeColor="Color(255, 255, 255, 8)"
                    >
                        <Rect Width="10ss" Height="1ph" Direction="Y">
                            <Style 
                                Ref="NavButton" 
                                Width="10ss" 
                                Height="10ss" 
                                StrokeWidth="1" 
                                StrokeColor="Color(255, 255, 255, 8)" 
                                Hover="true" 
                                Hover:StrokeColor="Color(255, 255, 255, 32)" 
                                Cursor="hand" 
                                Fill="Material(sstrp25/ui/hex.png)" 
                                FillRepeatX="true" 
                                FillRepeatY="true" 
                                FillRepeatScale="0.1" 
                                FillColor="Color(158, 200, 213, 128)" 
                                Hover:FillColor="Color(158, 200, 213, 225)"
                            />
                            
                            <Rect TopLeftRadius="5ss" Width="10ss" Height="7.5ss" Fill="Material(sstrp25/ui/window-hazard.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.01" FillColor="Color(255, 255, 255, 5)">
                            </Rect>

                            <Rect Style="NavButton">
                            </Rect>

                            <Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 8)" Hover="true" Hover:StrokeColor="Color(255, 255, 255, 32)" Cursor="hand" Fill="Material(sstrp25/ui/hex.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.1" FillColor="Color(158, 200, 213, 128)" Hover:FillColor="Color(158, 200, 213, 225)">
                            </Rect>

                            <Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 8)" Hover="true" Hover:StrokeColor="Color(255, 255, 255, 32)" Cursor="hand" Fill="Material(sstrp25/ui/hex.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.1" FillColor="Color(158, 200, 213, 128)" Hover:FillColor="Color(158, 200, 213, 225)">
                            </Rect>

                            <Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 8)" Hover="true" Hover:StrokeColor="Color(255, 255, 255, 32)" Cursor="hand" Fill="Material(sstrp25/ui/hex.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.1" FillColor="Color(158, 200, 213, 128)" Hover:FillColor="Color(158, 200, 213, 225)">
                            </Rect>

                            <Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 8)" Hover="true" Hover:StrokeColor="Color(255, 255, 255, 32)" Cursor="hand" Fill="Material(sstrp25/ui/hex.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.1" FillColor="Color(158, 200, 213, 128)" Hover:FillColor="Color(158, 200, 213, 225)">
                            </Rect>

                            <Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 8)" Hover="true" Hover:StrokeColor="Color(255, 255, 255, 32)" Cursor="hand" Fill="Material(sstrp25/ui/hex.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.1" FillColor="Color(158, 200, 213, 128)" Hover:FillColor="Color(158, 200, 213, 225)">
                            </Rect>
                            
                            <Rect BottomLeftRadius="5ss" Grow="true" Fill="Material(sstrp25/ui/window-hazard.png)" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.01" FillColor="Color(255, 255, 255, 5)" />

                            <!--<Rect Width="10ss" Height="10ss" StrokeWidth="1" StrokeColor="Color(255, 255, 255, 32)">
                            </Rect>-->
                        </Rect>

                        <Rect 
                            Grow="True" 
                            Fill="Material(sstrp25/ui/hex.png)"
                            FillColor="Color(255, 255, 255, 20)"
                            FillRepeatX="true"
                            FillRepeatY="true"
                            FillRepeatScale="0.15"
                            FillUnder="Color(0, 0, 0, 245)"
                            Radius="5ss"
                            FontName="Rajdhani"
                            FontSize="8.5"
                            :On:Set:Screen="function (el, screen) 
                                self:SetProperty('Screen', screen)
                                self:InvalidateLayout()
                            end"
                        >
                        </Rect>
                    </Rect>
                </Rect>

                <Rect Grow="true" Flex="2" Gap="4ss" Direction="Y">
                
                    <Rect Gap="2ss" Flex="5">
                        <Button Width="20ss" Height="20ss" />
                        <Button Width="20ss" Height="20ss" />
                        <Button Width="20ss" Height="20ss" />
                        <Button Width="20ss" Height="20ss" />
                        <Button Width="20ss" Height="20ss" />
                    </Rect>

                </Rect>

                <Rect 
                    Width="0.25pw" 
                    Height="1ph"
                    Direction="Y"
                >
                    <Rect Flex="6" Width="1pw" Direction="Y">
                        <Rect Width="1pw" Flex="6"
                        >
                            <Rect FontName="Orbitron SemiBold" FontColor="Color(158, 200, 213, 255)" FontSize="25" MarginRight="5ss"
                                
                            
                            Fill="Material(sstrp25/ui/hex.png)"
                            FillColor="Color(255, 255, 255, 105)"
                            FillRepeatX="true"
                            FillRepeatY="true"
                            FillRepeatScale="0.1"
                            StrokColor="Color(255, 255, 255, 16)"
                            StrokeWidth="1ss"
                            FillUnder="Color(0, 0, 0, 245)"
                            Radius="10ss"
                            Padding="8ss"
                            Height="27ss"
                            Flex="5"
                            >
                            151
                            </Rect>
                            <XLabel Text="Points remaining" FontName="Orbitron SemiBold" FontColor="Color(158, 200, 213, 255)" FontSize="10" MarginRight="3cw" />
                        </Rect>
                        
                    </Rect>

                    <Rect 
                        FontName="Orbitron SemiBold" 
                        FontColor="Color(158, 200, 213, 255)"
                        FontSize="12"
                        Flex="4"
                        Width="1pw"
                        Direction="X"
                        Gap="2.5ss"
                        MarginTop="10ss"
                        MarginBottom="5ss"
                    >
                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Width="4cw" 
                            Height="1ph" 
                            TopLeftRadius="0.5ph"
                            BottomLeftRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginBottom="5ss"
                        />

                        <XLabel Text="Stats" />

                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Grow="true"
                            Height="1ph" 
                            TopRightRadius="0.5ph"
                            BottomRightRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginTop="4ss"
                            MarginBottom="5ss"
                        />
                    </Rect>
                
                    <Rect
                        Width="1pw"
                        Height="0.33ph"
                        Flex="4"
                        FillColor="Color(12, 12, 12, 225)"
                        Radius="5ss"
                        StrokeWidth="1"
                        StrokeColor="Color(255, 255, 255, 8)"
                    >
                        <Rect 
                            Grow="True" 
                            Fill="Material(sstrp25/ui/hex.png)"
                            FillColor="Color(255, 255, 255, 20)"
                            FillRepeatX="true"
                            FillRepeatY="true"
                            FillRepeatScale="0.15"
                            FillUnder="Color(0, 0, 0, 245)"
                            Radius="5ss"
                            FontName="Rajdhani"
                            FontSize="8.5"
                            :On:Set:Screen="function (el, screen) 
                                self:SetProperty('Screen', screen)
                                self:InvalidateLayout()
                            end"
                        >
                        </Rect>
                    </Rect>

                    <Rect 
                        FontName="Orbitron SemiBold" 
                        FontColor="Color(158, 200, 213, 255)"
                        FontSize="12"
                        Flex="4"
                        Width="1pw"
                        Direction="X"
                        Gap="2.5ss"
                        MarginTop="10ss"
                        MarginBottom="5ss"
                    >
                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Width="4cw" 
                            Height="1ph" 
                            TopLeftRadius="0.5ph"
                            BottomLeftRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginTop="4ss"
                            MarginBottom="5ss"
                        />

                        <XLabel Text="Weapon" />

                        <Rect 
                            Fill="Material(sstrp25/ui/window-hazard.png)"
                            FillColor="Color(158, 200, 213, 32)" 
                            FillRepeatX="true" 
                            FillRepeatY="true" 
                            FillRepeatScale="0.05" 
                            Grow="true"
                            Height="1ph" 
                            TopRightRadius="0.5ph"
                            BottomRightRadius="0.5ph"
                            PaddingLeft="4ss"
                            PaddingRight="4ss"
                            MarginTop="4ss"
                            MarginBottom="5ss"
                        />
                    </Rect>
                
                    <Rect
                        Width="1pw"
                        Height="0.2ph"
                        Flex="4"
                        FillColor="Color(12, 12, 12, 225)"
                        Radius="5ss"
                        StrokeWidth="1"
                        StrokeColor="Color(255, 255, 255, 8)"
                    >
                        <Rect 
                            Grow="True" 
                            Fill="Material(sstrp25/ui/hex.png)"
                            FillColor="Color(255, 255, 255, 20)"
                            FillRepeatX="true"
                            FillRepeatY="true"
                            FillRepeatScale="0.15"
                            FillUnder="Color(0, 0, 0, 245)"
                            Radius="5ss"
                            FontName="Rajdhani"
                            FontSize="8.5"
                            :On:Set:Screen="function (el, screen) 
                                self:SetProperty('Screen', screen)
                                self:InvalidateLayout()
                            end"
                        >
                        </Rect>
                    </Rect>

                    <Rect Grow="true" MarginTop="5ss" MarginBottom="5ss" Fill="Material(sstrp25/ui/window-hazard.png)" FillColor="Color(255, 255, 255, 2)" Radius="5ss" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.5" />

                    <Rect Flex="6" Width="1pw">
                        <Rect Padding="2ss" Fill="Material(sstrp25/ui/window-hazard.png)" FillColor="Color(217, 255, 0, 101)" Radius="5ss" FillRepeatX="true" FillRepeatY="true" FillRepeatScale="0.5">
                            <Button Height="2.0ch" FontSize="16" Flex="5" FillColor="Color(255, 174, 0)" FillUnder="Color(0, 0, 0, 255)" Direction="Y" >
                                Create character
                            </Button>
                        </Rect>
                    </Rect>
                </Rect>
            </Rect>
        </Rect>
    </Rect>
]])
function PANEL:Init()
    self:LoadXML()

    local ent = ClientsideModel("models/Humans/Group01/male_02.mdl")
    ent:SetAngles(Angle(0, 180, 0))

    clent = ent
    function self:Paint(w, h)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(color_white)

        cam.Start3D(Vector(-50, 3.5, 50), Angle(0, 0, 0))
            ent:DrawModel()
        cam.End3D()
    end

    function self:OnRemove()
        ent:Remove()
    end
end

concommand.Add("sym_create", function ()
    
    if IsValid(CHARACTER_CREATE) then
        CHARACTER_CREATE:Remove()
        return
    end

    CHARACTER_CREATE = vgui.Create("Character_Create")
    CHARACTER_CREATE:MakePopup()
end)
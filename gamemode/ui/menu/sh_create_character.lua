if SERVER then
else

    DEFINE_BASECLASS("Rect")
    local PERK = vguix.RegisterFromXML("SSTRP.CreateCharacter.Perk", [[
        <Rect 
            Name="Component" 
            :Height="Width"
            Stroke="white" 
            StrokeWidth="4" 
            :StrokeMat="
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 192),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )"
            :Fill="Color(255, 255, 255, 255)"
            :Mat="RadialGradient(
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.3,
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.9,
                Color(0, 3, 10, self:HoveredOrActive() and 255 or 64)
            )"
            :Alpha="self:HoveredOrActive() and 255 or 64"
            Align="5"
            Cursor="hand"
            Hover="true"
            :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
        >
            <Tooltip Anchor="BOTTOM">
                <Text :Value="Component:GetValue()" />
            </Tooltip>
        </Rect>
    ]])
    vguix.AccessorFunc(PERK, "Icon", "Icon", "Material")
    vguix.AccessorFunc(PERK, "Cost", "Cost", "Number")
    vguix.AccessorFunc(PERK, "Value", "Value", "String")

    function PERK:Init()
        self:SetCost(math.Round(math.Rand(10, 20), 0))
    end

    function PERK:LeftClick()

        if CHARCREATE.Payload[self:GetName()] == self:GetValue() then
            if self:GetName() == "Rank" then
                return
            end
            
            CHARCREATE.Payload[self:GetName()] = nil
            CHARCREATE.Points = CHARCREATE.Points + self:GetCost()
            ClickSound()
            return true
        else
            if CHARCREATE.Points - self:GetCost() < 0 then
                return true
            end

            CHARCREATE.Payload[self:GetName()] = self:GetValue()
            CHARCREATE.Points = CHARCREATE.Points - self:GetCost()
            ClickSound()
            return true
        end
    end

    function PERK:HoveredOrActive()
        return self:GetFuncEnv("IsHovered")
    end

    function PERK:Paint(w, h)
        BaseClass.Paint(self, w, h)

        if self:GetIcon() then
            surface.SetDrawColor(255, 255, 255, 128)
            surface.SetMaterial(self:GetIcon())
        end
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * 0.8, h *0.8, 0)

        if CHARCREATE.Payload[self:GetName()] == self:GetValue() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("sstrp25/v2/checked32.png"))
            surface.DrawTexturedRectRotated(w /2, h / 2, 32, 32, 0)
        end

        draw.WordBox(4, w - 6, 6, "★ " .. tostring(self:GetCost()), "DermaDefault", Color(255, 255, 255, 32), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    local CHRCLASS = vguix.RegisterFromXML("SSTRP.CreateCharacter.Class", [[
        <Rect 
            Name="Component" 
            :Height="Width"
            Stroke="white" 
            StrokeWidth="4" 
            :StrokeMat="
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 192),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )"
            :Fill="Color(255, 255, 255, 255)"
            :Mat="RadialGradient(
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.3,
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.9,
                Color(0, 3, 10, self:HoveredOrActive() and 255 or 64)
            )"
            :Alpha="self:HoveredOrActive() and 255 or 64"
            Align="5"
            Cursor="hand"
            Hover="true"
            :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
        >
            <Tooltip Anchor="BOTTOM">
                <Text :Value="Component:GetName()" />
            </Tooltip>
        </Rect>
    ]])
    vguix.AccessorFunc(CHRCLASS, "Icon", "Icon", "Material")

    function CHRCLASS:LeftClick()
        CHARCREATE.Payload.Class = self:GetName()
        ClickSound()
        return true
    end

    function CHRCLASS:HoveredOrActive()
        return self:GetFuncEnv("IsHovered")
    end

    function CHRCLASS:Paint(w, h)
        BaseClass.Paint(self, w, h)

        if self:GetIcon() then
            surface.SetDrawColor(255, 255, 255, 128)
            surface.SetMaterial(self:GetIcon())
        end
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * 0.8, h *0.8, 0)

        if self:GetName() == CHARCREATE.Payload.Class then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material("sstrp25/v2/checked32.png"))
            surface.DrawTexturedRectRotated(w /2, h / 2, 32, 32, 0)
        end
    end

    local PREVIEW = vguix.RegisterFromXML("SSTRP.CreateCharacter.Preset", [[
        <Rect 
            Name="Component" 
            :Height="Width"
            Stroke="white" 
            StrokeWidth="4" 
            :StrokeMat="
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 192),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )"
            :Fill="Color(255, 255, 255, 255)"
            :Mat="RadialGradient(
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.3,
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.9,
                Color(0, 3, 10, self:HoveredOrActive() and 255 or 64)
            )"
            :Alpha="self:HoveredOrActive() and 255 or 64"
            Align="5"
            Cursor="hand"
            Hover="true"
            :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
        >
        </Rect>
    ]])

    function PREVIEW:HoveredOrActive()
        return self:GetFuncEnv("IsHovered")
    end

    function PREVIEW:SetData(b64)
        self.Data = b64
    end

    local spinner = Material("sstrp25/v2/spinner256.png")
    function PREVIEW:Paint(w, h)
        BaseClass.Paint(self, w, h)

        -- Forces rendering only when they open the page!
        if not self.Data then
            return
        end

        if not self.ActorMat then
            self.ActorMat = Actor.Material(self.Data)
        end

        if self.ActorMat and self.ActorMat:IsLoaded() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(self.ActorMat)
            surface.DrawTexturedRectRotated(w/2, h/2, w - 2, h - 2, 0)
        else
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(spinner)
            surface.DrawTexturedRectRotated(w/2, h/2, w*0.5, h*0.5, 0)
        end
    end

    function PREVIEW:LeftClick()
        CHARCREATE.Actor:FromBase64(self.Data)
        CHARCREATE.Actor:ResetSequence("idle_relaxed_shotgun_6")
        --CHARCREATE:UpdateVest()
        --CHARCREATE:RefreshAppearance()
        ClickSound()
        return true
    end

    
    local PANEL = vguix.RegisterFromXML("SSTRP.CharacterCreate.Flex", [[
        <Rect Name="Component" Width="0" Gap="1cw" Align="4">
            <Rect Width="11cw" Height="100%" FontSize="7" Align="4" >
                <Text :Value="Part or ('FX' .. tostring(Id))" />
            </Rect>

            <SSTRP.Slider
                Name="Component"
                
                :Min="function ()
                    local b, t = CHARCREATE.Actor:GetFlexBounds(Id)
                    return b 
                end"
                
                :Max="function ()
                    local b, t = CHARCREATE.Actor:GetFlexBounds(Id)
                    return t 
                end"

                Func:ChangeValue="function (pnl, src, value)
                    CHARCREATE.Actor:SetFaceParam(Id, value)
                    return true
                end"

                Grow="true"

                DP="2"
            />
        </Rect>
    ]])
    vguix.AccessorFunc(PANEL, "Id", "Id", "Number")
    vguix.AccessorFunc(PANEL, "Part", "Part", "String")




    local PANEL = vguix.RegisterFromXML("SSTRP.ColorPalette", [[
        <Rect Name="Component" Opened="false" Width="64" Height="32" Padding="4" Hover="true" Cursor="hand" Align="5" :Fill="Color(0, 0, 0, 225)" 
            Func:LeftClick="function () 
                self.Popover:Toggle()
                ClickSound()
                return true
            end"
        >
            <Rect Width="100%" Height="100%" :Fill="Value" />
            <Popover Func:LeftClick="function ()
                return true
            end" Hover="true" Cursor="false" Name="Popover" Interactive="true" Width="256" :OffsetX="Parent.Width - Width" :OffsetY="Parent.Height + 8" :Fill="Color(0, 0, 0, 225)" :Shape="RoundedBox(Width, Height, 8, 8, 8, 8)" Padding="8">
                <Grid Name="Grid" Columns="8" Gap="4" Width="100%">
                </Grid>
            </Popover>
        </Rect>
    ]])
    vguix.AccessorFunc(PANEL, "Value", "Value")
    vguix.AccessorFunc(PANEL, "Colors", "Colors")

    function PANEL:SetColors(tbl)
        local popover = self.Popover:GetChildren()[1]
        for k, v in pairs(tbl) do
            local pnl = vgui.Create("Rect", popover)
            pnl:SetFill(v)
            pnl:SetCursor("hand")

            pnl.LeftClick = function ()
                self:SetValue(v)
                self:Invoke("OnValueChanged", v)
                ClosePopovers()
                ClickSound()
                self:InvalidateChildren(true)
                return true
            end
        end
        
        self.Colors = tbl
    end


    local TAB = vguix.RegisterFromXML("SSTRP.CreateCharacter.Tab", [[
        <Rect Name="Component" Width="100%" Height="32"
            Func:LeftClick="function ()
                CHARCREATE:SetPage(self:GetName())
                ClickSound()
                return true
            end" 
            Stroke="white" 
            StrokeWidth="4" 
            :StrokeMat="
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 192),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )"
            :Fill="Color(255, 255, 255, 255)"
            :Mat="RadialGradient(
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.3,
                Color(0, 14, 30, self:HoveredOrActive() and 255 or 64),
                0.9,
                Color(0, 3, 10, self:HoveredOrActive() and 255 or 64)
            )"
            :Alpha="self:HoveredOrActive() and 255 or 64"
            Align="5"
            Cursor="hand"
            Hover="true"
            :Shape="RoundedBox(Width, Height, Height/2, 0, 0, Height/2)">
            <Tooltip Anchor="RIGHT">
                <Text :Value="Label" />
            </Tooltip>
        </Rect>
    ]])
    vguix.AccessorFunc(TAB, "Label", "Label", "String")

    function TAB:HoveredOrActive()
        return self:GetFuncEnv("IsHovered") -- or CreateCharacter:GetPage() == self:GetName()
    end

    local PAGE = vguix.RegisterFromXML("SSTRP.CreateCharacter.Page", [[
        <Rect Name="Component" Align="7" Flow="Y" Width="100%" Height="100%" :Visible="CHARCREATE:GetPage() == self:GetName()">
        </Rect>
    ]])

    local CREATE = vguix.RegisterFromXML("SSTRP.CreateCharacter", [[
        <Rect Name="CreateCharacter" Width="1vw" Height="1vh" Align="8" Flow="Y" Absolute="true" X="0" Y="0" Fill="255, 255, 255, 255" Mat="sstrp25/v2/create_bg.jpg" Align="4" Flow="X" Padding="16">
            <Rect 
                Width="0.4pw"
                Height="100%"
            >
                <Rect Name="Nav" Width="32" Height="100%" Flow="Y" Align="8" PaddingTop="16" PaddingBottom="16" Gap="8">
                    <SSTRP.CreateCharacter.Tab Name="Details" Label="Details"><Rect Mat="sstrp25/v2/palette16.png" Fill="white" Width="33%" Height="33%" /></SSTRP.CreateCharacter.Tab>
                    <!--<SSTRP.CreateCharacter.Tab Name="Backstory" Label="Backstory"><Rect Mat="sstrp25/v2/create_backstory.png" Fill="white" Width="33%" Height="33%" /></SSTRP.CreateCharacter.Tab>-->
                    <SSTRP.CreateCharacter.Tab Name="Appearance" Label="Appearance"><Rect Mat="sstrp25/v2/palette16.png" Fill="white" Width="33%" Height="33%" /></SSTRP.CreateCharacter.Tab>
                    <SSTRP.CreateCharacter.Tab Name="Perks" Label="Perks"><Rect Mat="sstrp25/v2/star16.png" Fill="white" Width="33%" Height="33%" /></SSTRP.CreateCharacter.Tab>

                </Rect>

                <Rect Name="Body" Height="100%" Grow="true" Fill="0, 0, 0, 255" Padding="16"
                    Stroke="white" 
                    StrokeWidth="4"
                    MarginLeft="-1"
                    :StrokeMat="
                        LinearGradient(
                            Color(0, 28, 60, 255),
                            0.1,
                            Color(0, 28, 60, 192),
                            1,
                            Color(0, 6, 20, 0),
                            90
                        )"
                    :Fill="Color(255, 255, 255, 255)"
                    :Mat="RadialGradient(
                        Color(0, 14, 30, 128),
                        0.3,
                        Color(0, 14, 30, 128),
                        0.9,
                        Color(0, 3, 10, 128)
                    )"
                    Align="5"
                    Blur="4"
                    :Shape="RoundedBox(Width, Height, 0, 16, 16, 0)">
                    <SSTRP.CreateCharacter.Page Name="Details">
                        <Rect Flow="Y">
                            <Rect FontName="Eurostile Extended" FontSize="8" Align="4">CREATE A NEW CHARACTER</Rect>
                            <Rect FontName="Eurostile Extended" FontSize="12" Align="4" MarginBottom="32"><Rect Mat="sstrp25/v2/checklist64.png" Width="0.8ch" Height="0.8ch" MarginRight="2cw" Fill="white" /> NAME & DETAILS</Rect>
                        </Rect>
                        <Scroll Name="Scroll" Grow="true">
                            <Rect Debug:Global="Container" Align="7" Flow="Y" Width="100%" Gap="32">
                                <Rect Width="100%" Gap="16" FontSize="8">
                                    <Rect Flow="Y" Grow="true">
                                        <Rect>Forename(s)</Rect>
                                        <Textbox Name="Forenames" Placeholder="John" />
                                    </Rect>

                                    <Rect Flow="Y" Width="33%">
                                        <Rect>Surname</Rect>
                                        <Textbox Name="Surname" Placeholder="Doe" />
                                    </Rect>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="16" FontSize="8">
                                    <Rect>Description</Rect>
                                    <Textarea Name="Description" Placeholder="A tall man...." />
                                </Rect>
                            </Rect>
                        </Scroll>
                    </SSTRP.CreateCharacter.Page>
                    <SSTRP.CreateCharacter.Page Name="Appearance">
                        <Rect Flow="Y">
                            <Rect FontName="Eurostile Extended" FontSize="8" Align="4">CREATE A NEW CHARACTER</Rect>
                            <Rect FontName="Eurostile Extended" FontSize="12" Align="4" MarginBottom="32"><Rect Mat="sstrp25/v2/palette64.png" Width="0.8ch" Height="0.8ch" MarginRight="2cw" Fill="white" /> CUSTOMIZE YOUR APPEARANCE</Rect>
                        </Rect>

                        <Scroll Name="Scroll" Grow="true">
                            <Override Name="Content" Gap="32">
                                <Rect Width="100%" Gap="16" FontSize="8" Flow="Y">
                                    <Rect>Base</Rect>
                                    <Grid Columns="4" Gap="8" Width="100%" Name="Presets">
                                    </Grid>
                                </Rect>
                                
                                <Rect Width="100%" Gap="16" FontSize="8" Flow="Y">
                                    <Rect>Skin</Rect>
                                    <SSTRP.Slider Name="Face" Width="100%" Func:ChangeValue="function (self, src, value)
                                        CHARCREATE.Actor:SetFace(value)
                                        return true
                                    end" Value="1" Min="1" :Max="#CHARCREATE.Actor.Base.Faces" DP="0" />
                                </Rect>
                                

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Hair" FontSize="8" FontName="Orbitron" />
                                    <Rect Width="100%" Gap="16" Align="4">
                                        <SSTRP.Slider Name="Hair" Debug:Global="Hair" Grow="true" Func:ChangeValue="function (self, src, value)
                                            CHARCREATE.Actor:SetHair(value)
                                            return true
                                        end" Min="0" Value="1" :Max="#CHARCREATE.Actor.Base.Hair" DP="0" />

                                        
                                        <SSTRP.ColorPalette Name="HairColor" :Colors="CHARCREATE.Actor.Base.HairColor" MarginRight="16" Init:Value="Color(255, 255, 255, 255)" Func:OnValueChanged="function (pnl, src, val)
                                            CHARCREATE.Actor:SetHairColor(val)
                                            return true
                                        end" />
                                    </Rect>
                                </Rect>
                                
                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Eye Colour" FontSize="8" FontName="Orbitron" />
                                    <SSTRP.Slider Width="100%" Func:ChangeValue="function (self, src, value)
                                        CHARCREATE.Actor:SetEyes(value)
                                        return true
                                    end" Value="1" Min="1" :Max="#CHARCREATE.Actor.Base.Eyes" DP="0" />
                                </Rect>
                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Eye Brows" FontSize="8" FontName="Orbitron" />
                                    <SSTRP.Slider Name="EyeBrows" Width="100%" Func:ChangeValue="function (self, src, value)
                                        CHARCREATE.Actor:SetEyeBrows(value) 
                                        return true
                                    end" Value="1" Min="1" :Max="#CHARCREATE.Actor.Base.EyeBrows" DP="0" />
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8" :Visible="CHARCREATE.Actor.Base.Mustaches ~= nil">
                                        <Text Value="Mustache" FontSize="8" FontName="Orbitron" />
                                        <SSTRP.Slider Name="Mustache" Width="100%" Func:ChangeValue="function (self, src, value)
                                        CHARCREATE.Actor:SetMustache(value) 
                                        return true
                                    end" Value="1" Min="1" :Max="CHARCREATE.Actor.Base.Mustaches and #CHARCREATE.Actor.Base.Mustaches or 0" DP="0" />
                                </Rect> 

                                <Rect Flow="Y" Width="100%" Gap="8" :Visible="CHARCREATE.Actor.Base.Beards ~= nil">
                                    <Text Value="Beard" Name="Beard" FontSize="8" FontName="Orbitron" />
                                    <SSTRP.Slider Name="Beard" Width="100%" Func:ChangeValue="function (self, src, value)
                                        CHARCREATE.Actor:SetBeard(value) 
                                        return true
                                    end" Value="1" Min="1" :Max="CHARCREATE.Actor.Base.Beards and #CHARCREATE.Actor.Base.Beards or 0" DP="0" />
                                </Rect> 


                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Eyes" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="EY01" Id="5" />
                                        <SSTRP.CharacterCreate.Flex Part="EY02" Id="10" />
                                        <SSTRP.CharacterCreate.Flex Part="EY03" Id="15" />
                                        <SSTRP.CharacterCreate.Flex Part="EY04" Id="20" />
                                        <SSTRP.CharacterCreate.Flex Part="EY05" Id="25" />
                                        <SSTRP.CharacterCreate.Flex Part="EY06" Id="30" />
                                        <SSTRP.CharacterCreate.Flex Part="EY07" Id="35" />
                                        <SSTRP.CharacterCreate.Flex Part="EY08" Id="40" />
                                        <SSTRP.CharacterCreate.Flex Part="EY09" Id="45" />
                                        <SSTRP.CharacterCreate.Flex Part="EY11" Id="50" />
                                        <SSTRP.CharacterCreate.Flex Part="EY12" Id="55" />
                                        <SSTRP.CharacterCreate.Flex Part="EY13" Id="60" />
                                        <SSTRP.CharacterCreate.Flex Part="EY14" Id="65" />
                                        <SSTRP.CharacterCreate.Flex Part="EY15" Id="70" />
                                        <SSTRP.CharacterCreate.Flex Part="EY16" Id="75" />
                                        <SSTRP.CharacterCreate.Flex Part="EY17" Id="80" />
                                        <SSTRP.CharacterCreate.Flex Part="EY18" Id="85" />
                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Ears" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="EA01" Id="4" />
                                        <SSTRP.CharacterCreate.Flex Part="EA02" Id="9" />
                                        <SSTRP.CharacterCreate.Flex Part="EA03" Id="14" />
                                        <SSTRP.CharacterCreate.Flex Part="EA04" Id="19" />
                                        <SSTRP.CharacterCreate.Flex Part="EA05" Id="24" />
                                        <SSTRP.CharacterCreate.Flex Part="EA06" Id="29" />
                                        <SSTRP.CharacterCreate.Flex Part="EA07" Id="34" />
                                        <SSTRP.CharacterCreate.Flex Part="EA08" Id="39" />
                                        <SSTRP.CharacterCreate.Flex Part="EA09" Id="44" />
                                        <SSTRP.CharacterCreate.Flex Part="EA10" Id="49" />
                                        <SSTRP.CharacterCreate.Flex Part="EA11" Id="54" />
                                        <SSTRP.CharacterCreate.Flex Part="EA12" Id="59" />
                                        <SSTRP.CharacterCreate.Flex Part="EA13" Id="64" />
                                        <SSTRP.CharacterCreate.Flex Part="EA14" Id="69" />
                                        <SSTRP.CharacterCreate.Flex Part="EA15" Id="74" />
                                        <SSTRP.CharacterCreate.Flex Part="EA16" Id="79" />
                                        <SSTRP.CharacterCreate.Flex Part="EA17" Id="84" />
                                        <SSTRP.CharacterCreate.Flex Part="EA18" Id="89" />
                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Nose" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="NO01" Id="1" />
                                        <SSTRP.CharacterCreate.Flex Part="NO02" Id="6" />
                                        <SSTRP.CharacterCreate.Flex Part="NO03" Id="11" />
                                        <SSTRP.CharacterCreate.Flex Part="NO04" Id="16" />
                                        <SSTRP.CharacterCreate.Flex Part="NO05" Id="21" />
                                        <SSTRP.CharacterCreate.Flex Part="NO06" Id="26" />
                                        <SSTRP.CharacterCreate.Flex Part="NO07" Id="31" />
                                        <SSTRP.CharacterCreate.Flex Part="NO08" Id="36" />
                                        <SSTRP.CharacterCreate.Flex Part="NO09" Id="41" />
                                        <SSTRP.CharacterCreate.Flex Part="NO10" Id="46" />
                                        <SSTRP.CharacterCreate.Flex Part="NO11" Id="51" />
                                        <SSTRP.CharacterCreate.Flex Part="NO12" Id="56" />
                                        <SSTRP.CharacterCreate.Flex Part="NO13" Id="61" />
                                        <SSTRP.CharacterCreate.Flex Part="NO14" Id="66" />
                                        <SSTRP.CharacterCreate.Flex Part="NO15" Id="71" />
                                        <SSTRP.CharacterCreate.Flex Part="NO16" Id="76" />
                                        <SSTRP.CharacterCreate.Flex Part="NO17" Id="81" />
                                        <SSTRP.CharacterCreate.Flex Part="NO18" Id="86" />
                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Mouth" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="MO01" Id="2" />
                                        <SSTRP.CharacterCreate.Flex Part="MO02" Id="7" />
                                        <SSTRP.CharacterCreate.Flex Part="MO03" Id="12" />
                                        <SSTRP.CharacterCreate.Flex Part="MO04" Id="17" />
                                        <SSTRP.CharacterCreate.Flex Part="MO05" Id="22" />
                                        <SSTRP.CharacterCreate.Flex Part="MO06" Id="27" />
                                        <SSTRP.CharacterCreate.Flex Part="MO07" Id="32" />
                                        <SSTRP.CharacterCreate.Flex Part="MO08" Id="37" />
                                        <SSTRP.CharacterCreate.Flex Part="MO09" Id="42" />
                                        <SSTRP.CharacterCreate.Flex Part="MO10" Id="47" />
                                        <SSTRP.CharacterCreate.Flex Part="MO11" Id="52" />
                                        <SSTRP.CharacterCreate.Flex Part="MO12" Id="57" />
                                        <SSTRP.CharacterCreate.Flex Part="MO13" Id="62" />
                                        <SSTRP.CharacterCreate.Flex Part="MO14" Id="67" />
                                        <SSTRP.CharacterCreate.Flex Part="MO15" Id="72" />
                                        <SSTRP.CharacterCreate.Flex Part="MO16" Id="77" />
                                        <SSTRP.CharacterCreate.Flex Part="MO17" Id="82" />
                                        <SSTRP.CharacterCreate.Flex Part="MO18" Id="87" />
                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Jaw" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="JA01" Id="3" />
                                        <SSTRP.CharacterCreate.Flex Part="JA02" Id="8" />
                                        <SSTRP.CharacterCreate.Flex Part="JA03" Id="13" />
                                        <SSTRP.CharacterCreate.Flex Part="JA04" Id="18" />
                                        <SSTRP.CharacterCreate.Flex Part="JA05" Id="23" />
                                        <SSTRP.CharacterCreate.Flex Part="JA06" Id="28" />
                                        <SSTRP.CharacterCreate.Flex Part="JA07" Id="33" />
                                        <SSTRP.CharacterCreate.Flex Part="JA08" Id="38" />
                                        <SSTRP.CharacterCreate.Flex Part="JA09" Id="43" />
                                        <SSTRP.CharacterCreate.Flex Part="JA10" Id="48" />
                                        <SSTRP.CharacterCreate.Flex Part="JA11" Id="53" />
                                        <SSTRP.CharacterCreate.Flex Part="JA12" Id="58" />
                                        <SSTRP.CharacterCreate.Flex Part="JA13" Id="63" />
                                        <SSTRP.CharacterCreate.Flex Part="JA14" Id="68" />
                                        <SSTRP.CharacterCreate.Flex Part="JA15" Id="73" />
                                        <SSTRP.CharacterCreate.Flex Part="JA16" Id="78" />
                                        <SSTRP.CharacterCreate.Flex Part="JA17" Id="83" />
                                        <SSTRP.CharacterCreate.Flex Part="JA18" Id="88" />
                                    </Grid>
                                </Rect>
                            </Override>
                        </Scroll>
                    </SSTRP.CreateCharacter.Page>
                    <SSTRP.CreateCharacter.Page Name="Perks">
                                    
                        <Rect Flow="Y" Width="100%">
                            <Rect FontName="Eurostile Extended" FontSize="8" Align="4">CREATE A NEW CHARACTER</Rect>
                            <Rect FontName="Eurostile Extended" FontSize="12" Align="4" MarginBottom="16"><Rect Mat="sstrp25/v2/star64.png" Width="0.8ch" Height="0.8ch" MarginRight="2cw" Fill="white" /> CHOOSE YOUR STARTING PERKS</Rect>
                            <Rect Width="100%" FontName="Orbitron" FontWeight="1200" FontSize="10" Align="5" MarginBottom="32">
                                <Rect Padding="8" Align="5" :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)" Fill="255, 255, 255, 32">
                                    <Rect Mat="sstrp25/v2/star16.png" Width="0.8ch" Height="0.8ch" MarginRight="1cw" Fill="white" />
                                    <Text Name="Points" Value="0" Func:Think="function ()
                                        self:SetText(CHARCREATE.Points)
                                    end" />
                                </Rect>
                            </Rect>
                        </Rect>

                        <Scroll Name="Scroll" Grow="true">
                            <Override Name="Content" Gap="32">
                            
                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Money" FontSize="8" FontName="Orbitron" />
                                    <SSTRP.Slider Name="Money" Width="100%" Value="1" Min="1" Max="10000" DP="0" />
                                </Rect> 
                                
                                <Rect Flow="Y" Width="100%" Gap="16" FontSize="8">
                                    <Rect>Rank</Rect>
                                    <Grid Columns="6" Gap="8" Width="100%">
                                        <SSTRP.CreateCharacter.Perk Name="Rank" Value="Private" Cost="0" Icon="sstrp25/v2/ranks/frameless/64x64/pvt.png" />
                                        <SSTRP.CreateCharacter.Perk Name="Rank" Value="Private First Class" Cost="20" Icon="sstrp25/v2/ranks/frameless/64x64/pfc.png" />
                                        <SSTRP.CreateCharacter.Perk Name="Rank" Value="Lance Corporal" Cost="40" Icon="sstrp25/v2/ranks/frameless/64x64/lcpl.png" />
                                        <SSTRP.CreateCharacter.Perk Name="Rank" Value="Corporal" Cost="80" Icon="sstrp25/v2/ranks/frameless/64x64/cpl.png" />
                                        <SSTRP.CreateCharacter.Perk Name="Rank" Value="Sergeant" Cost="160" Icon="sstrp25/v2/ranks/frameless/64x64/sgt.png" />

                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="16" FontSize="8">
                                    <Rect>Weapon</Rect>
                                    <Grid Columns="6" Gap="8" Width="100%">
                                        <SSTRP.CreateCharacter.Perk Name="Weapon" Value="Morita Mk1" Cost="0" :Icon="Type./>
                                    </Grid>
                                </Rect>

                                <Rect Flow="Y" Width="100%" Gap="8">
                                    <Text Value="Stats" FontSize="8" FontName="Orbitron" />
                                    <Grid Width="100%" Columns="2" RowHeight="32" Gap="16">
                                        <SSTRP.CharacterCreate.Flex Part="STM" Id="3" />
                                        <SSTRP.CharacterCreate.Flex Part="STR" Id="3" />
                                        <SSTRP.CharacterCreate.Flex Part="CON" Id="8" />
                                        <SSTRP.CharacterCreate.Flex Part="DEX" Id="28" />
                                        <SSTRP.CharacterCreate.Flex Part="WIS" Id="13" />
                                        <SSTRP.CharacterCreate.Flex Part="PER" Id="18" />
                                        <SSTRP.CharacterCreate.Flex Part="GUN" Id="18" />
                                        <SSTRP.CharacterCreate.Flex Part="MEL" Id="18" />
                                    </Grid>
                                </Rect>
                            </Override>
                        </Scroll>
                    
                    </SSTRP.CreateCharacter.Page>
                    <SSTRP.CreateCharacter.Page Name="Backstory">Backstory Page</SSTRP.CreateCharacter.Page>
                </Rect>
            </Rect>
            

            <Rect Name="Preview" Cursor="sizeall" Grow="true" Align="2" Height="100%" Padding="32">
                <SSTRP.SecondaryButton Name="Reset" Visible="false">Reset camera</SSTRP.SecondaryButton>
            </Rect>

            <SSTRP.DestructiveButton Name="CloseButton" Absolute="true" :X="Parent.Width - 16 - Width" Y="16" Width="32" Padding="0" Height="32" Align="5" Func:LeftClick="CreateCharacter:Close()"> 
                <Rect Mat="sstrp25/v2/cross64.png" Fill="white" Width="50%" Height="50%" />
            </SSTRP.DestructiveButton>
            

            <SSTRP.SuccessButton Absolute="true" :X="Parent.Width - 16 - Width" :Y="Parent.Height - 16 - Height" Func:LeftClick="CreateCharacter:Submit()"> 
                <Text Value="Create" MarginBottom="15" />
                <Rect Mat="sstrp25/v2/submit64.png" Width="0.8ch" Height="0.8ch" Fill="white" MarginLeft="2cw"/>
            </SSTRP.SuccessButton>
        </Rect>
    ]])

    function CREATE:Init()
        if IsValid(CHARCREATE) then
            CHARCREATE:Remove()
        end
        CHARCREATE = self
        self.Page = "Details"

        self.Payload = {
            Rank = "Private",
            Weapon = "Morita Mk1",
            Perks = {
            }
        }

        self.CamPos = Vector(50, 0, 55)
        self.CamAngles = Angle(0, 180, 0)
        self.CamFOV = 50
        self.CamGoalX = 0

        self.Actor = ents.CreateClientside("actor")
        self.Actor:SetPos(Vector(0, 0, 0))
        self.Actor:Spawn()
        self.Actor:FromBase64(table.Random(Actor.Presets))

        self.Points = 100

        --self.Actor:SetModel("models/xalphox/heads/male_ref.mdl")
        --self.Actor:AddPart("Torso", "models/xalphox/mi/male_torso_trooper.mdl", "000000011")
        --self.Actor:AddPart("Legs", "models/xalphox/mi/male_legs_trooper.mdl")

        self.Actor:GiveWeapon("models/weapons/arc9/mk1rifle.mdl")
        self.Actor:ResetSequence("idle_relaxed_shotgun_6")
        
        if not IsValid(self.Actor) then
            print("Failed to create actor entity for character creation panel.")
            return
        end
        
        function self.Preview.LeftClick(pnl)
            local ax, ay = gui.MousePos()

            local yaw = self.Actor:GetAngles().yaw

            self.Preview.Reset:SetVisible(true)

            hook.Add("Think", self.Preview, function ()
                if not input.IsMouseDown(MOUSE_LEFT) then
                    hook.Remove("Think", self.Preview)
                    return
                end

                local mx, my = gui.MousePos()
                local dx, dy = mx - ax, my - ay
                
                local ang = self.Actor:GetAngles()
                ang.yaw = yaw + (dx * 0.1)
                self.Actor:SetAngles(ang)
            end)
            return true
        end

        
        function self.Preview.RightClick(pnl)
            local ax, ay = gui.MousePos()

            local pos = self.Actor:GetPos()
            self.Preview.Reset:SetVisible(true)

            hook.Add("Think", self.Preview, function ()
                if not input.IsMouseDown(MOUSE_RIGHT) then
                    hook.Remove("Think", self.Preview)
                    return
                end

                local mx, my = gui.MousePos()
                local dx, dy = mx - ax, my - ay

                local newpos = self.Actor:GetPos()
                newpos.y = pos.y + (dx * 0.1)
                newpos.z = pos.z - (dy * 0.1)

                newpos.y = math.Clamp(newpos.y, -30, 30)
                newpos.z = math.Clamp(newpos.z, -30, 60)
                self.Actor:SetPos(newpos)
            end)
            return true
        end

        function self.Preview.Reset.LeftClick()
            self.Actor:SetPos(Vector(0, 0, 0))
            self.Actor:SetAngles(Angle(0, 0, 0))
            

            self.CamPos = Vector(50, 0, 55)
            self.CamAngles = Angle(0, 180, 0)
            self.CamFOV = 50
            self.CamGoalX = 0

            self.Preview.Reset:SetVisible(false)
            ClickSound()
        end

        function self.Preview.OnMouseWheeled(pnl, delta)
            self.CamGoalX = math.Clamp(self.CamGoalX + (delta * 2), -60, 25)
            self.Preview.Reset:SetVisible(true)
        end

        function self.Preview.Think(pnl)
            local newpos = self.Actor:GetPos()
            newpos.x = math.Approach(newpos.x, self.CamGoalX, 0.25)
            self.Actor:SetPos(newpos)
        end

        function self.Preview.Paint(pnl, w, h)
            if not IsValid(self.Actor) then
                return
            end

            local x, y = self.Preview:LocalToScreen(0, 0)
            surface.SetDrawColor(0, 0, 0, 192)
            surface.DrawRect(0, 0, w, h)
            
            render.SuppressEngineLighting(true)
            render.ResetModelLighting(0, 0, 0)

            render.SetLocalModelLights({
                {
                    type = MATERIAL_LIGHT_SPOT,
                    color = Vector(0.1, 0.5, 0.5),
                    pos = Vector(60, 0, 0),
                    dir = Vector(-1, 0, 0),
                    innerAngle = 40,
                    outerAngle = 180,
                    angularFalloff = 25
                },
            })

            
            cam.Start3D(self.CamPos, self.CamAngles, self.CamFOV, x, y, w, h)
                self.Actor:DrawModel()
            cam.End3D()

            render.SuppressEngineLighting(false)
        end


        -- Appearance
        local appearance = self.Body.Appearance.Scroll.Content.Presets
        for k, b64 in pairs(Actor.Presets) do
            local v = vgui.Create("SSTRP.CreateCharacter.Preset", appearance)
            v:SetWidth(192)
            v:SetHeight(192)
            v:SetData(b64)
        end

    end

    function CREATE:OnRemove()
        if IsValid(self.Actor) then
            self.Actor:Remove()
        end
    end

    function CREATE:GetAge()
        local dt = os.date('*t')
        local age = (dt.year + 291) - tonumber(self.Payload.BirthYear)

        return age
    end

    function CREATE:OnValueChanged(src, value)
        local name = src:GetName()
        if not name then
            return true
        end

        self.Payload[src:GetName()] = value

        return true
    end

    function CREATE:Validate(field, value)
        return true
    end

    function CREATE:Submit()
        self.Payload.Appearance = self.Actor:ToBase64()

        RPC.Call("Character.Create", self.Payload):Then(function (succ, chr)
            if not succ then
                return
            end

            table.insert(LocalPlayer().Characters, chr)
            LocalPlayer().Character = chr
            hook.Run("CharacterCreated", LocalPlayer(), chr)

            TabMenu:Remove()
            TabMenu = vgui.Create("SSTRP.Menu")
            TabMenu:Open()
            
            if IsValid(SelectCharacter) then
                SelectCharacter:Remove()
            end
            self:Close()
        end)
    end

    function CREATE:Close()
        local t = 0.25
        self:MoveTo(0, ScrH(), t, 0, -1, function()
            self:Remove()
        end)

        if IsValid(SelectCharacter) then
            SelectCharacter:MoveTo(0, 0, t)
        end

        if IsValid(TabMenu) then
            TabMenu:MoveTo(0, 0, t)
        end
    end

    function CREATE:SetPage(pg)
        local old = self.Page
        self.Page = pg
        self.Body[old]:SetVisible(false)
        self.Body[pg]:InvalidateChildren(true)
    end

    function CREATE:GetPage()
        return self.Page
    end

        
    function CREATE:UpdateVest()
        local class = self.Payload.class
        if class == "Medical" then
            self.Actor.Children.Torso:SetSubMaterial(1, "sstrp25/mi/vest_medic")
        elseif class == "Engineering" then
            self.Actor.Children.Torso:SetSubMaterial(1, "sstrp25/mi/vest_engineer")
        elseif class == "Flight" then
            self.Actor.Children.Torso:SetSubMaterial(1, "sstrp25/mi/vest_flight")
        elseif class == "Intelligence" then
            self.Actor.Children.Torso:SetSubMaterial(1, "sstrp25/mi/vest_intel")
        end
    end

    function CREATE:RefreshAppearance()
        assert(IsValid(self.Actor), "Actor entity is not valid!")

        local app = self.Window.Pages.Appearance.Params.Content
        _app = app

        app.Eyes:SetFuncEnv("Value", self.Actor:GetEyes())
        app.EyeBrows:SetFuncEnv("Value", tonumber(self.Actor:GetEyeBrows()) or 1)
        app.Mustache:SetFuncEnv("Value", tonumber(self.Actor:GetMustache()) or 1)
        app.Beard:SetFuncEnv("Value", tonumber(self.Actor:GetBeard()) or 1)
        app.Hair:SetFuncEnv("Value", self.Actor:GetHair())
        app.HairColor:SetFuncEnv("Value", self.Actor:GetHairColor())
        app.Face:SetFuncEnv("Value", self.Actor:GetFace())

        local function IterateFlexes(tgt)
            for k, v in pairs(tgt:GetChildren()) do
                if tgt.ClassName == "SSTRP.CreateCharacter.Flex" then
                    local id = v:GetFuncEnv("Id")
                    v:SetFuncEnv("Value", self.Actor:GetFlexWeight(id))
                end

                IterateFlexes(v)
            end
        end
        IterateFlexes(app)

        app:InvalidateChildrenEx(true, true)
    end
end
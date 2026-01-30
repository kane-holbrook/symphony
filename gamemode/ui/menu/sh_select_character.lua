if SERVER then
else
    local CHR = vguix.RegisterFromXML("SSTRP.SelectCharacter.Character", [[
        <Rect 
            Name="Component"
            Width="100%"
            FontName="Eurostile Extended" 
            FontSize="14" 
            Align="4"
            Gap="16"
        >
            <Rect 
                Hover="true"
                Padding="8" 
                Align="4"
                :Cursor="Component:IsSelected() and 'none' or 'hand'"
                :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
                Fill="white"
                Hover="true"
                :Mat="RadialGradient(
                    Color(0, 14, 30, Component:ShouldHighlight() and 255 or 64),
                    0.3,
                    Color(0, 14, 30, Component:ShouldHighlight() and 255 or 64),
                    0.9,
                    Color(0, 3, 10, Component:ShouldHighlight() and 255 or 64)
                )"
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
                Padding="16"
                Gap="16"
                Grow="true"
                
            >
                    <Circle Width="0.8ph" Height="0.8ph" Fill="white" />
                    <Rect Flow="Y" Grow="true">
                        <Text FontName="Orbitron" FontSize="7" :Value="Character:GetRank() or 'Civilian'" />
                        <Text FontName="Orbitron" FontSize="10" :Value="Character:GetName()" />
                        <Text FontName="Orbitron" MarginTop="4" FontSize="7" :FontColor="Color(192, 192, 192, 255)" :Value="Deref(Character, 'GetDescription') or 'No description.'" />
                    </Rect>
                    <Rect Mat="sstrp25/v2/checked32.png" Fill="white" Width="32" Height="32" :Visible="Component:IsSelected()" />
            </Rect>

            <Rect Hover="true" Cursor="hand" Mat="sstrp25/v2/trash64.png" Width="32" Height="32" :Fill="Color(255, 0, 0, IsHovered and 255 or 64)" />
        </Rect>
    ]])
    vguix.AccessorFunc(CHR, "Character", "Character")

    function CHR:IsSelected()
        return LocalPlayer():GetCharacter() == self:GetCharacter()
    end

    function CHR:ShouldHighlight()
        return self:IsSelected() or self:IsChildHovered()
    end

    function CHR:LeftClick()
        if self:IsSelected() then
            return
        end

        RPC.Call("Character.Select", self:GetCharacter():GetId()):Then(function (succ)
            if succ then
                LocalPlayer().Character = self:GetCharacter()
                CHARACTER_SELECT:Remove()
                CHARACTER_SELECT = nil
                TabMenu:Remove()
                TabMenu = vgui.Create("SSTRP.Menu")
                TabMenu:SetVisible(false)
            end
        end)
    end

    local SELECT = vguix.RegisterFromXML("SSTRP.SelectCharacter", [[
        <SSTRP.Modal Name="SelectCharacter">
            <Rect Absolute="true" :X="Parent.Width/2 - Width/2" :Y="Parent.Height/2 - Height/2" Width="66%" Height="80%" Align="8" Flow="Y" Gap="16">
                <Rect FontName="Eurostile Extended" FontSize="16">SELECT A CHARACTER</Rect>
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
                    Align="8"
                    Padding="32" 
                    Gap="16"
                >
                    <Rect Width="100%" Align="4" Gap="16">
                        <SSTRP.Button Func:LeftClick="function ()
                            local p = vgui.Create('SSTRP.CreateCharacter')
                            p:SetPos(0, ScrH())
                            p:MakePopup()

                            local t = 0.25
                            p:MoveTo(0, 0, t)
                            SelectCharacter:MoveTo(0, -ScrH(), t, 0, -1, function()
                                SelectCharacter:Remove()
                            end)
                            TabMenu:MoveTo(0, -ScrH(), t)

                            ClickSound()
                            return true
                        end"><Rect Width="1ch" Height="1ch" Mat="sstrp25/v2/add-user64.png" Fill="white" MarginRight="2cw" /> Create new character</SSTRP.Button>
                        <SSTRP.SecondaryButton><Rect Width="1ch" Height="1ch" Mat="sstrp25/v2/archive64.png" Fill="white" MarginRight="2cw" /> View archived characters</SSTRP.SecondaryButton>
                    </Rect>

                    <Scroll Name="Scroll" Width="100%" Grow="true" Fill="0, 0, 0, 64">
                        <Override Name="Content" Padding="16" Gap="8" />
                    </Scroll>
                </Rect>
            </Rect>
        </SSTRP.Modal>
    ]])

    function SELECT:Init()
        if IsValid(CHARACTER_SELECT) then
            CHARACTER_SELECT:Remove()
        end

        CHARACTER_SELECT = self
        self:Refresh()
    end

    function SELECT:Refresh()
        local lst = self.Scroll.Content
        for k, v in pairs(lst:GetChildren()) do
            v:Remove()
        end

        local characters = self:GetCharacters()
        for k, v in pairs(characters) do
            local charPanel = lst:Add("SSTRP.SelectCharacter.Character")
            charPanel:SetCharacter(v)
        end

    end
    
    function SELECT:GetCharacters()
        return tablex.SortByMemberEx(LocalPlayer():GetCharacters(), "GetName", true)
    end
end
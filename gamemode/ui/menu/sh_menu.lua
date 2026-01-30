if SERVER then
else

    DEFINE_BASECLASS("Rect")

    local INV = vguix.RegisterFromXML("SSTRP.Menu.Page.Inventory", [[
    <SSTRP.Menu.Page Name="Character.Inventory" Gap="32">
        
    </SSTRP.Menu.Page>
    ]])

    function INV:Init()
        if not LocalPlayer():GetInventory() then
            return
        end

        LocalPlayer():GetInventory():BuildVGUI(self)
    end

    local NAV = vguix.RegisterFromXML("SSTRP.Menu.Nav", [[
        <Rect
            Name="Component" 
            Padding="8" 
            Align="5" 
            Hover="true"
            Cursor="hand"
            FontName="Orbitron"
            FontSize="8"
            Padding="0, 12"
            :Width="math.min(200, (Parent.Width - (Parent.Width * 0.33) - (Parent.Width * 0.04)) / 4)"

            Stroke="white"
            StrokeWidth="8"
            :StrokeMat="IsHovered and 
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 255),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )
            or
                LinearGradient(
                    Color(0, 28, 60, 255),
                    0.1,
                    Color(0, 28, 60, 255),
                    1,
                    Color(0, 6, 20, 0),
                    90
                )
            "

            :Mat="RadialGradient(
                Color(0, 28, 60, (IsHovered or Menu:GetCategory() == self:GetName()) and 255 or 32),
                0.3,
                Color(0, 28, 60, (IsHovered or Menu:GetCategory() == self:GetName()) and 255 or 32),
                0.9,
                Color(0, 6, 20, (IsHovered or Menu:GetCategory() == self:GetName()) and 255 or 32)
            )"
            >

            
        </Rect>
    ]])

    function NAV:Select()
        local Menu = TabMenu

        if not self.Last then
            local pg = Menu:GetPages(self:GetName())
            assert(pg[1], "No pages found for category " .. self:GetName())
            self.Last = pg[1][1]
        end

        Menu:SetPage(self.Last)
    end

    function NAV:LeftClick(mc)
        self:Select()
        ClickSound()
    end
    
    vguix.RegisterFromXML("SSTRP.Menu.SubNav", [[
        <Rect
            Name="Component" 
            Align="5"
            Padding="8, 0"
            Height="24"
            :Fill="(IsHovered or Menu:GetPage() == self:GetName()) and Color(255, 255, 255, 64) or Color(255, 255, 255, 32)"
            FontName="Orbitron"
            FontSize="7"
            Cursor="hand"
            Hover="true"
            :Visible="string.StartsWith(self:GetName(), Menu:GetCategory())"
            :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)"
            Func:OnMousePressed="function(self, mc)
                if mc == MOUSE_LEFT then
                    TabMenu:SetPage(self:GetName())
                    ClickSound()
                end
            end"
        >
        </Rect>

    ]])

    local PAGE = vguix.RegisterFromXML("SSTRP.Menu.Page", [[
        <Rect Name="Component" Padding="16" Width="100%" Height="100%" />
    ]])

    function PAGE:OnOpen()
    end

    function PAGE:OnClose()
    end

    local MENU = vguix.RegisterFromXML("SSTRP.Menu", [[
        <Rect Name="Menu" Width="100%" Height="100%" Fill="0, 0, 0, 225" Align="8" Flow="Y">
            <Rect Width="100%" Height="128" Align="8" Padding="16" Fill="0, 0, 0, 225" 
                Fill="white"
                
                :Mat="RadialGradient(
                    Color(0, 14, 30, 192),
                    0.3,
                    Color(0, 8, 17, 192),
                    0.7,
                    Color(0, 0, 0, 192)
                )"
                
                :Shape="{
                    0, 0,
                    Width, 0,
                    Width, Height - 8,
                    Width - 128, Height - 8,
                    Width - 128 - 32, Height - 32 - 8,
                    128 + 32, Height - 32 - 8,
                    128, Height - 8,
                    0, Height - 8,
                }"
            >


                <Rect Hover="true" Width="25%" Height="100%" Align="4" Gap="16" Padding="4" Cursor="hand" Func:LeftClick="function (self, src, a)
                    ClickSound()
                    vgui.Create('SSTRP.SelectCharacter'):MakePopup()
                    return true
                end">

                    <Circle Align="5" Width="0.7ph" Height="0.7ph" 
                        Fill="white" 
                    >
                        Portrait
                    </Circle>

                    <Rect Flow="Y" Grow="true" Align="4">
                        <Rect FontName="Eurostile" FontSize="8"><Text :Value="Deref(LocalPlayer(), 'GetCharacter', 'GetRank') or 'Civilian'" /></Rect>
                        <Rect FontName="Eurostile" FontSize="12"><Text :Value="Deref(LocalPlayer(), 'GetCharacter', 'GetName') or 'No character selected'" /></Rect>
                    </Rect>

                    
                    <Rect Align="5" :Visible="IsHovered" Absolute="true" X="0" Y="0" :Width="self:GetParent():GetWide()" :Height="self:GetParent():GetTall()" Fill="white" 
                        :Shape="{
                            0, 4,
                            4, 0,
                            Width - 4, 0,
                            Width, 4,
                            Width, Height - 16 - 10,
                            Width - 4, Height - 12 - 10,
                            Width - 128 - 192, Height,
                            4, Height,
                            0, Height - 4
                        }"            
                        FontName="Eurostile" FontSize="10"          
                        
                        :Fill="Color(0, 0, 0, IsHovered and 192 or 0)"
                        Blur="2"

                        Cursor="hand"

                        Func:TestHover="function () return false end"   
                    >
                        Create or select a new character.
                    </Rect>
                </Rect>

                <Rect Align="5" Flow="Y" Grow="true" Gap="16">
                    <Rect Name="Nav" Align="5" Width="100%">
                        <Circle Hover="true" Cursor="hand" Func:LeftClick="function () 
                            Menu:PrevCategory() 
                            ClickSound()
                        end" Name="Prev" Width="0.015vw" Height="0.015vw" MarginRight="16" Align="5" :Fill="Color(255, 255, 255, IsHovered and 255 or 64)" :FontColor="Color(0, 0, 0, 255)" FontName="Orbitron" FontSize="7">Q</Circle>
                        
                        <SSTRP.Menu.Nav Name="Sitrep" :Shape="{
                            0, 8,
                            8, 0,
                            Width - 16, 0,
                            Width, Height,
                            8, Height,
                            0, Height - 8
                        }">
                            SITREP
                        </SSTRP.Menu.Nav>

                        <SSTRP.Menu.Nav Name="Character" :Shape="{
                            0, 0,
                            Width - 16, 0,
                            Width, Height,
                            16, Height
                        }">
                            CHARACTER
                        </SSTRP.Menu.Nav>

                        <Rect Mat="sstrp25/v2/logo64.png" Fill="white" Width="0.033vw" Height="0.033vw" Margin="16, 0" />

                        <SSTRP.Menu.Nav Name="Codex" :Shape="{
                            16, 0,
                            Width, 0,
                            Width - 16, Height,
                            0, Height
                        }">
                            CODEX
                        </SSTRP.Menu.Nav>

                        <SSTRP.Menu.Nav Name="Settings" :Shape="{
                            16, 0,
                            Width - 8, 0,
                            Width, 8,
                            Width, Height - 8,
                            Width - 8, Height,
                            0, Height
                        }">
                            SETTINGS
                        </SSTRP.Menu.Nav>

                        <Circle Hover="true" Cursor="hand" Func:LeftClick="function () 
                            Menu:NextCategory() 
                            ClickSound()
                        end" Name="Next" Width="0.015vw" Height="0.015vw" MarginLeft="16" Align="5" :Fill="Color(255, 255, 255, IsHovered and 255 or 64)" :FontColor="Color(0, 0, 0, 255)" FontName="Orbitron" FontSize="7">E</Circle>
                    </Rect>

                    <Rect Name="SubNav" Align="5" Width="100%" Gap="4">
                        <Circle Name="Prev" Width="0.01vw" Height="0.01vw" MarginRight="12" Align="5" Hover="true" Cursor="hand" Func:LeftClick="function () 
                            TabMenu:PrevPage() 
                            ClickSound()
                        end" :Fill="Color(255, 255, 255, IsHovered and 255 or 32)" :FontColor="Color(0, 0, 0, 255)" FontName="Orbitron" FontSize="7">A</Circle>

                        <SSTRP.Menu.SubNav Name="Sitrep.Briefing">Briefing</SSTRP.Menu.SubNav>

                        <SSTRP.Menu.SubNav Name="Character.Inventory">Inventory</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Character.Attributes">Attributes</SSTRP.Menu.SubNav>

                        <SSTRP.Menu.SubNav Name="Codex.Factions">Factions</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Codex.Worlds">Worlds</SSTRP.Menu.SubNav>
                        
                        <SSTRP.Menu.SubNav Name="Settings.Account">Account</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Settings.Gameplay">Gameplay</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Settings.Performance">Performance</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Settings.Audio">Audio</SSTRP.Menu.SubNav>
                        <SSTRP.Menu.SubNav Name="Settings.Keybinds">Keybinds</SSTRP.Menu.SubNav>


                        <Circle Name="Next" Width="0.01vw" Height="0.01vw" MarginLeft="12" Align="5" Hover="true" Cursor="hand" Func:LeftClick="function () 
                            TabMenu:NextPage() 
                            ClickSound()
                        end" :Fill="Color(255, 255, 255, IsHovered and 255 or 32)" :FontColor="Color(0, 0, 0, 255)" FontName="Orbitron" FontSize="7">D</Circle>
                    </Rect>
                </Rect>

                
                <Rect Width="25%" Height="100%" Align="9" Gap="8">
                    <Rect Hover="true" Cursor="hand" Mat="sstrp25/v2/help32.png" :Fill="IsHovered and color_white or Color(255, 255, 255, 128)" Width="32" Height="32" />
                    <Rect Hover="true" Cursor="hand" Mat="sstrp25/v2/discord32.png" :Fill="IsHovered and color_white or Color(255, 255, 255, 128)" Width="32" Height="32" />
                </Rect>
            </Rect>

            <Rect Name="Canvas" Width="100%" Grow="true">
                <SSTRP.Menu.Page Name="Sitrep.Briefing" Gap="32">
                    <Rect Grow="true" :Shape="{0, 0, Width, 0, Width, Height, 0, Height}" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Main
                    </Rect>
                    
                    <Rect Width="33%" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Main
                    </Rect>
                </SSTRP.Menu.Page>

                <SSTRP.Menu.Page Name="Sitrep.Starmap" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Starmap
                    </Rect>
                </SSTRP.Menu.Page>
                                
                <SSTRP.Menu.Page.Inventory />

                <SSTRP.Menu.Page Name="Codex.Factions" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Factions
                    </Rect>
                </SSTRP.Menu.Page>
                
                <SSTRP.Menu.Page Name="Settings.Account" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Account
                    </Rect>
                </SSTRP.Menu.Page>
                
                <SSTRP.Menu.Page Name="Settings.Gameplay" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Gameplay
                    </Rect>
                </SSTRP.Menu.Page>
                
                <SSTRP.Menu.Page Name="Settings.Performance" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Performance
                    </Rect>
                </SSTRP.Menu.Page>
                
                <SSTRP.Menu.Page Name="Settings.Audio" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Audio
                    </Rect>
                </SSTRP.Menu.Page>
                
                <SSTRP.Menu.Page Name="Settings.Keybinds" Gap="32">
                    <Rect Grow="true" Height="100%" Align="4" Padding="16" Fill="0, 0, 0, 255">
                        Keybinds 
                    </Rect>
                </SSTRP.Menu.Page>
                
            </Rect>
        
        </Rect>
    ]])

    function MENU:Init()
        self.Page = "Sitrep.Briefing"
    end

    function MENU:GetCategory()
        return string.Split(self.Page, ".")[1]
    end

    function MENU:GetPage()
        return self.Page
    end

    function MENU:SetPage(pg)
        self.Page = pg

        local cat = string.Split(pg, ".")[1]
        local categories = self:GetCategories()
        for k, v in pairs(categories) do
            if v[1] == cat then
                v[2].Last = pg
                break
            end
        end

        local canvases = self:GetCanvases()
        for k, v in pairs(canvases) do
            local show = (k == pg)
            if not show and v:GetVisible() then
                v:SetVisible(false)
                v:OnClose()
            end

            if show then
                v:SetVisible(true)
                v:InvalidateChildren(true)
                v:OnOpen()
            end
        end

        self:InvalidateChildren(true)
    end

    function MENU:GetCategories()
        local c = {}
        for k, v in pairs(self.Nav:GetChildren()) do
            if v.ClassName == "SSTRP.Menu.Nav" then
                table.insert(c, { v:GetName(), v })
            end
        end

        return c
    end

    function MENU:GetPages(cat)
        local p = {}
        for k, v in pairs(self.SubNav:GetChildren()) do
            if v.ClassName == "SSTRP.Menu.SubNav" and string.StartsWith(v:GetName(), cat) then
                table.insert(p, { v:GetName(), v })
            end
        end

        return p
    end
    
    function MENU:GetCanvases()
        local c = {}
        for k, v in pairs(self.Canvas:GetChildren()) do
            if v.ClassName == "SSTRP.Menu.Page" then
                c[v:GetName()] = v
            end
        end

        return c
    end

    function MENU:GetCurrentCanvas()
        local canvases = self:GetCanvases()
        return canvases[self.Page]
    end

    function MENU:NextCategory()
        local currentCategory = self:GetCategory()
        local categories = self:GetCategories()
            
        for i=1, #categories do
            if categories[i][1] == currentCategory then
                local nxt = categories[i + 1]
                if not nxt then
                    return
                end


                nxt[2]:Select()
                
                return
            end
        end
    end

    function MENU:PrevCategory()
        local currentCategory = self:GetCategory()
        local categories = self:GetCategories()
            
        for i=#categories, 1, -1 do
            if categories[i][1] == currentCategory then
                local nxt = categories[i - 1]
                if not nxt then
                    return
                end


                nxt[2]:Select()
                
                return
            end
        end
    end

    function MENU:NextPage()
        local currentPage = self:GetPage()
        local pages = self:GetPages(self:GetCategory())
            
        for i=1, #pages do
            if pages[i][1] == currentPage then
                local nxt = pages[i + 1]
                if not nxt then
                    return
                end
                self:SetPage(nxt[1])
                return
            end
        end
    end

    function MENU:PrevPage()
        local currentPage = self:GetPage()
        local pages = self:GetPages(self:GetCategory())
            
        for i=#pages, 1, -1 do
            if pages[i][1] == currentPage then
                local nxt = pages[i - 1]
                if not nxt then
                    return
                end
                self:SetPage(nxt[1])
                return
            end
        end
    end

    function MENU:OnKeyCodePressed(key)
        if key == KEY_E then
            self.Nav.Next:LeftClick()
            self.Nav.Next:SetColor(Color(255, 255, 255, 255))
            self.Nav.Next:ColorTo(Color(255, 255, 255, 64), 0.25)
        elseif key == KEY_Q then
            self.Nav.Prev:LeftClick()
            self.Nav.Prev:SetColor(Color(255, 255, 255, 255))
            self.Nav.Prev:ColorTo(Color(255, 255, 255, 64), 0.25)
        elseif key == KEY_D then
            self.SubNav.Next:LeftClick()
            self.SubNav.Next:SetColor(Color(255, 255, 255, 255))
            self.SubNav.Next:ColorTo(Color(255, 255, 255, 32), 0.25)
        elseif key == KEY_A then
            self.SubNav.Prev:LeftClick()
            self.SubNav.Prev:SetColor(Color(255, 255, 255, 255))
            self.SubNav.Prev:ColorTo(Color(255, 255, 255, 32), 0.25)
        elseif key == KEY_TAB then
            self:Close()
        end
    end

    function MENU:Open()
        self:MakePopup()
        self:SetVisible(true)
        self:SetKeyboardInputEnabled(true)
        self:SetMouseInputEnabled(true)
        self.OpenTime = CurTime()
    end

    function MENU:Close()
        self:SetVisible(false)
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
        self.OpenTime = nil
    end

    --[[local duration = 0.2
    function MENU:Paint(w, h)
        local m = Matrix()

        local elapsed = CurTime() - self.OpenTime
        local progress = math.Clamp(elapsed/duration, 0, 1)

        local scale = Vector(0.9 + 0.2 * progress, 0.9 + 0.2 * progress, 1)

        m:Translate(Vector(w/2, h/2))        
        m:Scale(scale)
        m:Translate(Vector(-w/2, -h/2))
        cam.PushModelMatrix(m, true)
            BaseClass.Paint(self, w, h)
    end

    function MENU:PaintOver(w, h)
        cam.PopModelMatrix()
    end--]]

    concommand.Add("TabMenu", function ()
        if IsValid(TabMenu) then
            TabMenu:Remove()
            return
        end

        local menu = vgui.Create("SSTRP.Menu")
        TabMenu = menu
        menu:MakePopup()
        
    end)


    hook.Add("ScoreboardShow", "SSTRP.OpenMenu", function ()
        if not IsValid(TabMenu) then
            TabMenu = vgui.Create("SSTRP.Menu") 
        end
        TabMenu:Open()
        return true
    end)
end
AddCSLuaFile()

if SERVER then
    return true
end

local PANEL = {}
function PANEL:Init()
    if IsValid(MAIN_MENU) then
        MAIN_MENU:Remove()
    end
    MAIN_MENU = self

    self.Navigation = sym.RadioGroup()
    self:SetVisible(false)
    
    self:SetSizeEx(REL(1), REL(1))
    self:SetFlex(8)
    self:SetFlexFlow(FLEX_FLOW_Y)

    self
        :AddEx("SymPanel", { Ref = "Header", Flex = 5, SizeEx = { REL(1), SSH(33) }, Background = color_black })
            :AddEx("SymPanel", { Ref = "Left", Flex = 7, SizeEx = { SS(100), REL(1, SS(-15)) }, FlexMargin = { SS(5), SS(15), 0, 0 }, FlexGap = SS(2.5) })
                :Add("SymSprite", {
                    Material = "symphony/ranks/2lt.png",
                    SizeEx = { SS(10), SS(10) }
                })

                :AddEx("SymPanel", { Flex = 4, FlexFlow = FLEX_FLOW_Y })
                    :Add("SymLabel", {
                        Text = "2Lt. Brian C. Larsen",
                        Color = Color(255, 174, 0),
                        Font = sym.Font("Orbitron", 20)
                    })

                    :Add("SymLabel", {
                        Text = "Level 36 Infantryman",
                        Font = sym.Font("Orbitron", 14)
                    })

                    :SizeToChildren(true, true)
                    :GetParent()
                :GetParent()
            
            :AddEx("SymPanel", { Ref = "Centre", Flex = 8, FlexFlow = FLEX_FLOW_Y, SizeEx = { nil, REL(1) }, FlexGap = SS(2), FlexGrow = true, Background = Color(0, 0, 0, 255), FlexMargin = { 0, SS(5), 0, 0 }})
            
                -- Main Nav Menu
                :AddEx("SymPanel", { Ref = "Nav", Flex = 5, SizeEx = { REL(1), SS(10) }, FlexGap = SS(2), Background = Color(0, 0, 0, 255)})
                    :Add("SymKey", {
                        Content = { 
                            "Q"
                        },
                        SizeEx = { SS(10), SS(10) },
                        Ref = "Q",
                        Click = function ()
                            self.Navigation:Previous()
                        end
                    })
                    
                    :AddEx("SymPanel", {
                        Ref = "Buttons",
                        Flex = 4,
                        FlexGap = SS(1)
                    })
                        :GetParent()
                    
                    :Add("SymKey", {
                        Ref = "E",
                        Content = { 
                            "E"
                        },
                        SizeEx = { SS(10), SS(10) },
                        Click = function ()
                            self.Navigation:Next()
                        end
                    })
                    :GetParent()
                :GetParent()

            :AddEx("SymPanel", { Ref = "Right", Flex = 4, FlexGap = SS(3), SizeEx = { SS(100), REL(1) }, Background = Color(0, 0, 0, 255)})
                    

                :GetParent()

            :GetParent()

                
        :AddEx("SymPanel", { Ref = "Body", SizeEx = { REL(1), nil }, FlexGrow = true, Background = Color(0, 0, 32, 254) })
            :AddEx("SymPanel", { Ref = "Content", Flex = 4, SizeEx = { REL(1), REL(1) }, NoClipping = true, Background = Color(0, 0, 32, 254) })
            :GetParent()
        :GetParent()

    self.Body.Content.Think = self.ContentThink
    self.Body.Content.GoalX = 0
    self.Body.Content.VelX  = 0

    self.Pages = {}

    self.Lobby = self:AddPage("Lobby")
    self.Lobby:SetBackground(Material("symphony/ui/mainmenu/lobby.jpg"))

    self.Inventory = self:AddPage("Inventory")
    self.Inventory:SetBackground(Material("symphony/ui/mainmenu/inventory.jpg"))
    self.Inventory.Main = self.Inventory:AddPage("Main")
    self.Inventory.Storage = self.Inventory:AddPage("Storage")

    self.Stats = self:AddPage("Stats")
    self.Stats:SetBackground(Material("symphony/ui/mainmenu/stats.jpg"))
    self.Stats.Core = self.Stats:AddPage("Core")
    self.Stats.Skills = self.Stats:AddPage("Skills")

    self.Quests = self:AddPage("Quests")
    self.Quests.InProgress = self.Quests:AddPage("In Progress")
    self.Quests.Completed = self.Quests:AddPage("Completed")

    self.Database = self:AddPage("Database")
    self.Database:SetBackground(Material("symphony/ui/mainmenu/database.jpg"))

    self.Settings = self:AddPage("Settings")
    self.Settings:SetBackground(Material("symphony/ui/mainmenu/settings.jpg"))

    self.Settings.Profile = self.Settings:AddPage("Profile")
    self.Settings.Gameplay = self.Settings:AddPage("Gameplay")
    self.Settings.Graphics = self.Settings:AddPage("Graphics")
    self.Settings.Sound = self.Settings:AddPage("Sound")
    
    self.Settings.Developer = self.Settings:AddPage("Developer")
    self.Settings.Developer.Nav = sym.RadioGroup()

    self.Settings.Developer
        :AddEx("SymPanel", { 
            SizeEx = { REL(0.75), REL(0.95) },
            Flex = 4, 
            FlexMargin = { SS(5) },
            FlexGap = SS(2)
        })

            :AddEx("SymPanel", { 
                SizeEx = { SS(100), REL(1) }, 
                Flex = 8,
                Background = 240,
                FlexFlow = FLEX_FLOW_Y,
                FlexGap = SS(1)
            })

                :Add("SymButton", {
                    SizeEx = { REL(1, SS(-3)), SSH(15) },
                    FlexMargin = { 0, SS(1.5), 0, 0 },
                    Content = "Log",
                    Controller = { self.Settings.Developer.Nav, "Console" }
                })

                :Add("SymButton", {
                    SizeEx = { REL(1, SS(-3)), SSH(15) },
                    FlexMargin = { 0, SS(1.5), 0, 0 },
                    Content = "Exceptions",
                    Controller = { self.Settings.Developer.Nav, "Exceptions" }
                })

                :GetParent()

            :AddEx("SymPanel", { 
                FlexGrow = true, 
                Flex = 5,
                Background = true
            })
                :GetParent()

            :GetParent()
    
    self.Settings.Developer.Nav:SetValue("Console")





            
    
    self.Header.Centre.Nav.Buttons:SizeToChildren(true, true)

    self.Body.Content:SizeToChildren(true, false)

    function self.Navigation.OnChange(r, new)
        local pg = self.Pages[new]

        local x, y = pg:GetPos()
        self.Body.Content.GoalX = -x

        if self.Page then
            self.Page.SubNav:SetDisplay(DISPLAY_NONE)
        end

        if table.Count(pg.Pages) > 0 then
            pg.SubNav:SetDisplay(DISPLAY_VISIBLE)
        end

        self.Page = pg
        sym.ClickSound()
    end
    
    self.Navigation:SetValue("Lobby")

    hook.Add("ScoreboardShow", self, function ()
        self:MakePopup()
        self:SetVisible(true)

        local openTime = CurTime()
        local toggled = false
        hook.Add("Think", self, function ()
            local tabDown = input.IsKeyDown(KEY_TAB)
            if not tabDown and not toggled then
                -- Tapped tab, so keep it open til they press tab again.
                if CurTime() - openTime < 0.2 then
                    toggled = true
                else
                    hook.Remove("Think", self)
                    self:SetKeyboardInputEnabled(false)
                    self:SetMouseInputEnabled(false)
                    self:SetVisible(false)
                end
            elseif tabDown and toggled then
                toggled = false
                hook.Remove("Think", self)
                self:SetKeyboardInputEnabled(false)
                self:SetMouseInputEnabled(false)
                self:SetVisible(false)
            end
        end)

        return true
    end)
end

function PANEL:ContentThink(w, h)
    local x, y = self:GetPos()
    x = math.Approach(x, self.GoalX, x < self.GoalX and -50 or 50)
    self:SetPos(x, y)
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_Q then
        self.Header.Centre.Nav.Q:OnMousePressed(MOUSE_LEFT)
    end

    if key == KEY_E then
        self.Header.Centre.Nav.E:OnMousePressed(MOUSE_LEFT)
    end

    if self.Page and table.Count(self.Page.Pages) > 0 then
        if key == KEY_A then
            self.Page.SubNav.A:OnMousePressed(MOUSE_LEFT)
        end

        if key == KEY_D then
            self.Page.SubNav.D:OnMousePressed(MOUSE_LEFT)
        end
    end
end


function PANEL:AddPage(title)
    local pg = vgui.Create("SymMainMenu_Page", self.Body.Content)

    pg.Button = vgui.Create("SymGlassButton", self.Header.Centre.Nav.Buttons)
    pg.Button:SetController(self.Navigation, title)
    pg.Button:SetSizeEx(SS(40), SS(10))
    pg.Button:Add("SymLabel", {
            Text = string.upper(title),
            Font = sym.Font("Orbitron", 22),
            Color = color_white
    })
    pg.Button.Page = self

    self.Pages[title] = pg
    return pg
end
vgui.Register("SymMainMenu", PANEL, "SymPanel")


local PANEL = {}
function PANEL:Init()
    self.Radio:SetDisplay(DISPLAY_NONE)
    self:SetFlex(5)    
    
    self.bg = sym.CreateMaterial()
        :AddBoxGradient({ 
            0, Color(40, 48, 56, 255),
            0.3, Color(31, 40, 48),
            1, Color(72, 78, 83),
        })
        :Generate()
    
    self:SetBackground(self.bg)
    
    self.hover = sym.CreateMaterial()
        :AddBoxGradient({ 
            0, Color(57, 68, 80),
            0.3, Color(56, 71, 85),
            1, Color(111, 120, 128),
        })
        :Generate()
    
    self:SetHover(self.hover)
end

function PANEL:OnChanged(checked)
    if checked then            
        self:SetBackground(self.hover)
    else
        self:SetBackground(self.bg)
    end
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(ScreenScale(1), 0, 0, w, h, Color(123, 129, 123, 255))
    draw.NoTexture()

    local mat = self:IsHovered() and self:GetHover():GetMaterial() or self:GetBackground():GetMaterial()
    surface.SetMaterial(mat)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(1, 1, w-2, h-2)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(1, 1, w-2, h-2)

    --[[self.left()
    surface.DrawTexturedRectUV(h/2, 0, w-h, h, h/2/w, 0, 1 - h/2/w, 1)
    self.right()--]]
end
vgui.Register("SymGlassButton", PANEL, "SymInputRadio")


local PANEL = {}
function PANEL:Init()
    self:SetSizeEx(ScrW, REL(1))
    self:SetFlex(5)
    self.Pages = {}

    self.RadioGroup = sym.RadioGroup()

    function self.RadioGroup.OnChange(r, new)
        local pg = self.Pages[new]

        if self.Page then
            self.Page:SetDisplay(DISPLAY_NONE)
        end

        self.Page = pg
        pg:SetDisplay(DISPLAY_VISIBLE)


        sym.ClickSound()
    end

    self.SubNav = vgui.Create("SymPanel", MAIN_MENU.Header.Centre)
    self.SubNav:SetSizeEx(REL(1), SS(1))
    self.SubNav:SetFlex(5)
    self.SubNav:SetFlexGap(SS(1))

    self.SubNav:Add("SymKey", {
            Content = { 
                "A"
            },
            SizeEx = { SS(7.5), SS(7.5) },
            Ref = "A",
            Click = function ()
                self.RadioGroup:Previous()
            end
        })

    self.SubNav:Add("SymPanel", { Ref = "Buttons", Flex = 5, FlexGap = SS(1), SizeEx = { nil, REL(1) } })
    
    self.SubNav:Add("SymKey", {
            Content = { 
                "D"
            },
            SizeEx = { SS(7.5), SS(7.5) },
            Ref = "D",
            Click = function ()
                self.RadioGroup:Next()
            end
        })

    self.SubNav:SizeToChildren(false, true)
    self.SubNav:SetDisplay(DISPLAY_NONE)
end

function PANEL:AddPage(title)
    local pg = vgui.Create("SymMainMenu_Page", self)
    pg:SetDisplay(DISPLAY_NONE)

    pg.Button = vgui.Create("SymGlassButton", self.SubNav.Buttons)
    pg.Button:SetController(self.RadioGroup, title)
    pg.Button:SetSizeEx(SS(40), SS(7.5))
    pg.Button:Add("SymLabel", {
            Text = string.upper(title),
            Font = sym.Font("Orbitron", 22),
            Color = color_white
    })
    pg.Button.Page = self

    self.SubNav.Buttons:SizeToChildren(true, false)

    self.Pages[title] = pg

    if table.Count(self.Pages) == 1 then
        self.RadioGroup:SetValue(title)
    end

    return pg
end

vgui.Register("SymMainMenu_Page", PANEL, "SymPanel")


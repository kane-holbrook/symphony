AddCSLuaFile()

if SERVER then
    sym.http.Hook("views/console", "web/")
    return
end

local PANEL = {}
function PANEL:Init()
    if IsValid(SYM_CONSOLE) then
        SYM_CONSOLE:Remove()
    end

    SYM_CONSOLE = self
    self:SetPosEx(REL(0.025), REL(0.025))
    self:SetSizeEx(REL(0.95), REL(0.95))
    self:SetFlex(5)

    self.Nav = vgui.Create("SymPanel", self)
    self.Nav:SetSizeEx(REL(0.15), REL(1))
    self.Nav:SetFlex(7)
    self.Nav:SetFlexFlow(FLEX_FLOW_Y)
    self.Nav:SetBackground(
        HTMLCircleGradient(Color(40, 50, 80, 225), Color(49, 56, 85, 245), ScrW(), ScrH())
    )

    self.Nav
        :AddEx("SymPanel", { FlexGrow = true, FlexFlow = FLEX_FLOW_Y, Flex = 7, FlexGap = SS(3), FlexMargin = SS(5) })
            :AddEx("SymInputSelect", { SizeEx = { REL(1), SSH(15) } })
                :AddItem("Console")
                :AddItem("Objects")
                :AddItem("Performance")
                :GetParent()
            
            :Add("SymLabel", { Text = "Search", Font = sym.Font(5), FlexMargin = { 0, SS(3), 0, SS(0) } })
            :Add("SymInputText", { SizeEx = { REL(1), SSH(15) } })
            
            :Add("SymLabel", { Text = "Realm", Font = sym.Font(5), FlexMargin = { 0, SS(5), 0, SS(1) } })
            :Add("SymInputCheckbox", { Label = "Client", CheckboxSize = { SS(5), 6 } })
            :Add("SymInputCheckbox", { Label = "Server", CheckboxSize = { SS(5), 6 } })

            :Add("SymLabel", { Text = "Type", Font = sym.Font(5), FlexMargin = { 0, SS(6), 0, SS(1) } })

                :Add("SymInputCheckbox", { Label = { vgui.Create("SymLabel", { Text = "FRAMEWORK", Font = sym.Font(6) }) }, FlexMargin = { 0, 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                :Add("SymInputCheckbox", { Label = "LUA", FlexMargin = { 0, 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "EXCEPTION", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "INCLUDE", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                :Add("SymInputCheckbox", { Label = "DATABASE", FlexMargin = { 0, 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "CONNECT", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "QUERY", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "ERROR", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                :Add("SymInputCheckbox", { Label = "NET", FlexMargin = { 0, 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "TRANSMIT", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "RECEIVE", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                :Add("SymInputCheckbox", { Label = "PLAYER", FlexMargin = { 0, 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "CONNECT", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "DISCONNECT", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })
                    :Add("SymInputCheckbox", { Label = "DEATH", FlexMargin = { SS(5), 0, 0, 0 }, CheckboxSize = { SS(5), 6 } })

            :GetParent()
    

    self.Content = vgui.Create("SymPanel", self)
    self.Content:SetBackground(255)
    self.Content:SetFlexGrow(true)
    self.Content:SetFlex(8)

    self.Html = vgui.Create("DHTML", self.Content)
    self.Html:SetFlexGrow(true)
    self.Html:OpenURL(HttpServer.GetPath("views/console/console.htm"))

end

function PANEL:Open()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)
    self:SetAlpha(255)
    self:MakePopup()
    self.Opened = true
end

function PANEL:IsOpen()
    return self.Opened
end

function PANEL:AddMessage(msg)
    -- Escape and safely convert the Lua table to a JSON string
    local jsonMsg = util.TableToJSON(msg)
    local safeJson = string.JavascriptSafe(jsonMsg)

    -- Queue JavaScript to call the PushMessage function
    self.Html:QueueJavascript([[GMod.PushMessage("]] .. safeJson .. [[");]])
end

function PANEL:Close()
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
    self:SetAlpha(0)
    self.Opened = false
end

vgui.Register("SymConsole", PANEL, "SymPanel")


local lock = false
hook.Add("Think", "SymConsole", function ()
    if gui.IsConsoleVisible() or gui.IsGameUIVisible() then
        return
    end

    --local consoleKey = input.LookupBinding("toggleconsole")
    if input.IsKeyDown(KEY_TAB) and input.IsKeyDown(KEY_LSHIFT) then
        if lock then
            return
        end

        if SYM_CONSOLE:IsOpen() then
            SYM_CONSOLE:Close()
        else
            SYM_CONSOLE:Open()
        end

        lock = true
    elseif lock then
        lock = false
    end
end)
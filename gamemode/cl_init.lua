include("shared.lua")

concommand.Add("sym_ui", function()
    if IsValid(p) then
        p:Remove()
        return
    end

    p = xvgui.CreateFromXML(nil, [[
        <Window 
            X="0.25pw"
            Y="0.25ph"
            Width="0.5pw"
            Height="0.5ph"
            Closeable="true"
            Moveable="true"
            Sizeable="true"
            Title="USER INTERFACE"
        >
            <Scroll>
                <Rect Direction="Y" Width="1pw" Gap="5ss">
                    <Button>
                        Continue 
                        <Rect 
                            Fill="Material(sstrp25/ui/double-chevron.png)" 
                            FillColor="Color(158, 200, 213, 64)"
                            Hover:FillColor="Color(158, 200, 213, 255)"
                            Width="0.66ch" 
                            Height="0.66ch" 
                            MarginLeft="1.5cw"
                        />
                    </Button>

                    <Rect Direction="Y" Gap="1ss" Width="1pw" Value="Test" :On:Change:Value="function (el, new)
                        if not stringex.IsBlank(new) and not tonumber(new) then
                            print('Returning true')
                            return true
                        end

                        print('Change')
                        self:SetProperty('Value', new)
                        self:InvalidateLayout()
                    end">
                        <Rect>Textbox: <XLabel :Text="' ' .. Value" /></Rect>
                        <Textbox Placeholder="A Text Entry" Width="0.5pw" :Value="Value" />
                    </Rect>

                    <Rect Direction="Y" Gap="1ss" Init:Selected="{ ['Checkbox 1'] = true }" :On:Change:Value="function (el, new, ticked)
                        Selected[new:GetProperty('Label', true)] = ticked and true or nil
                        self:InvalidateLayout()
                        return true
                    end">
                        <Rect>
                            Checkbox: 

                            <Rect>
                                <For Each="k, v in pairs(Selected)">
                                    <XLabel :Text="' ' .. tostring(k)" />
                                </For>
                            </Rect>
                        </Rect>

                        <Checkbox Label="Checkbox 1" :Value="Selected[Label]" />
                        <Checkbox Label="Checkbox 2" :Value="Selected[Label]" />
                        <Checkbox Label="Checkbox 3" :Value="Selected[Label]" />
                        <Checkbox Label="Checkbox 4" :Value="Selected[Label]" />
                    </Rect>         

                    <Rect Direction="Y" Gap="1ss" Value="false" 
                        :On:Change:Value="function (el)
                            self:SetProperty('Value', el:GetProperty('Label', true))
                            self:InvalidateChildren(true)
                            return true
                        end">
                        <Rect>Radio: <XLabel :Text="' ' .. tostring(Value)" /></Rect>
                        <Radio Label="Radio 1" :Selected="Value == Label" />
                        <Radio Label="Radio 2" :Selected="Value == Label" />
                        <Radio Label="Radio 3" :Selected="Value == Label" />
                    </Rect>
                    
                    <Rect Direction="Y" Gap="1ss" Width="0.33pw"
                        :On:Change:Value="function (el, val)
                            self:SetProperty('Value', val)
                            self:InvalidateChildren(true)
                            return true
                        end" Value="Item 1">
                        <Rect>Picklist: <XLabel :Text="' ' .. Value" /></Rect>
                        <Picklist :Value="Value">
                            <PicklistEntry>Item 1</PicklistEntry>
                            <PicklistEntry>Item 2</PicklistEntry>
                        </Picklist>
                    </Rect>
                    
                    <Rect Direction="Y" Gap="1ss" Width="1pw" 
                        :On:Change:Value="function (el, val)
                            self:SetProperty('Value', val)
                            self:InvalidateChildren(true)
                            return true
                        end" Value="256"
                    >
                        <Rect>Slider: <XLabel :Text="' ' .. Value" /></Rect>
                        <XSlider Width="0.5pw" Min="0" Max="512" :Value="Value" />
                    </Rect>

                    <Rect Direction="Y" Gap="1ss" Width="1pw">
                        Colour picker
                        <ColorPicker />
                    </Rect>
                                    

                    <Rect Direction="Y" Gap="1ss">
                        Tree
                    </Rect>

                    <Rect Direction="Y" Gap="1ss">
                        Drag'n'drop
                    </Rect>

                    <Rect Direction="Y" Gap="1ss">
                        WrapText
                    </Rect>
                                    
                    <Rect Direction="Y" Gap="1ss" Hover="true" 
                        :On:StartHover="function (...) 
                            self.Popover:Open() 
                            return true
                        end"
                        
                        :On:StopHover="function (...) 
                            self.Popover:Close() 
                            return true
                        end"

                        
                        >
                        Popover
                        <Popover Ref="Popover" FollowCursor="true" X="1pw" Width="50ss" Height="25ss" FillColor="Color(255, 0, 0, 128)">
                            Test
                        </Popover>
                    </Rect>
                </Rect>
            </Scroll>
        </Window>
    ]])
    p:MakePopup()
end)





concommand.Add("sym_gamma", function()
    if IsValid(p) then
        p:Remove()
        return
    end

    p = xvgui.CreateFromXML(nil, [[
        <Rect
            Ref="UI"
            X="0"
            Y="0"
            Width="1vw"
            Height="1vh"
            Fill="Material(sstrp25/ui/backdrops/backdrop1.jpg)"
            FillColor="Color(255, 255, 255, 255)"
            >

            <Window 
                Absolute="true"
                X="0.25pw"
                Y="0.25ph"
                Width="0.5pw"
                Height="0.5ph"
                Title="Adjust screen brightness"
            >

                <Rect 
                    Fill="Material(sstrp25/ui/window-hazard.png)" 
                    FillColor="Color(212, 213, 158, 40)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.2" 
                    Width="0.1pw" 
                    Height="1ph" 
                    TopLeftRadius="5ss"
                    BottomLeftRadius="5ss"
                />

                <Rect Ref="Content" Direction="Y" Flex="5" Grow="true" Gap="10ss" Width="1pw"
                
                    Fill="Material(sstrp25/ui/window-hazard.png)" 
                    FillColor="Color(55, 75, 82, 40)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.2" 
                    Flex="5"
                >
                
                    <Rect Gap="5ss" MarginBottom="15ss">
                        <Rect Fill="Material(sstrp25/ui/logo.png)" FillColor="Color(255, 255, 255, 255)" Width="60ss" Height="60ss" />
                        <Rect Ref="Ghost" Width="60ss" Height="60ss" />
                    </Rect>

                    <XSlider Width="0.66pw" Min="-1" Max="1" Value="0.5" :On:Change:Value="function (el, value)
                        _top = Top
                        UI:UpdateBrightness(value)
                    end" />
                
                    <Rect >
                        Move the slider above until the image on the right is barely visible.
                    </Rect>

                    <Button >Continue</Button>
                </Rect>

                
                <Rect 
                    Fill="Material(sstrp25/ui/window-hazard.png)" 
                    FillColor="Color(212, 213, 158, 40)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.2" 
                    Width="0.1pw" 
                    Height="1ph" 
                    TopRightRadius="5ss"
                    BottomRightRadius="5ss"
                />
            </Window>
        </Rect>
    ]])
    p:MakePopup()


    local val = 0
    local mat = Material("sstrp25/ui/logo.png")
    local pp = Material("pp/colour")
    function p.Body.Content.Ghost:Paint(w, h)
        
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetMaterial(pp)
        surface.SetDrawColor(255, 255, 255, 255)
        pp:SetFloat("$pp_colour_brightness", val)
        pp:SetFloat("$pp_colour_contrast", 1)
        pp:SetFloat("$pp_colour_colour", 1)
        pp:SetFloat("$pp_colour_mulr", 0)
        pp:SetFloat("$pp_colour_mulg", 0)
        pp:SetFloat("$pp_colour_mulb", 0)
        pp:Recompute()
        render.UpdateScreenEffectTexture()

        local x, y = self:ScreenToLocal(0, 0)
        surface.DrawTexturedRect(x, y, ScrW(), ScrH())

    end

    function p:UpdateBrightness(value)
        print(value)
        val = value
    end
end)
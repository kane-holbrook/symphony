include("shared.lua")
sym.log("FRAMEWORK", "Framework finished loading in " .. math.Round((SysTime() - SYM_START_TIME) * 1000, 2) .. "ms.")
concommand.Add("sym_dev", function()
    if IsValid(XVGUI) then XVGUI:Remove() return end
    -- I should be able to set borders, including border radiuses.
    -- I should be able to apply stencils?
    -- I should be able to add elements to children using <Slot:##RefName##>. 
    -- <Slot:Default></Slot:Default> is a placeholder for defaults.
    -- I should be able to wrap elements, especially text.
    -- I should be able to generate XML?
    -- etc.

    
    XVGUI = xvgui.CreateFromXML(nil, [[
        <XPanel :X="0" :Y="0" :Width="PW" :Height="PH" :Background="Color(0, 0, 0, 225)" Direction="Y">
            <XPanel Ref="Header" :Width="PW" Flex="4" :Background="Color(0, 0, 0, 192)">
                <XPanel Grow="true" :Height="PH" Flex="4" :Gap="ScreenScale(1)">
                    <XPanel FontWeight="800" :PaddingX="ScreenScale(2)" :MarginX="ScreenScale(1)">Symphony</XPanel>
                    <XPanel Cursor="hand" :PaddingX="ScreenScale(2)" :Height="PH" Flex="5">File</XPanel>
                    <XPanel Cursor="hand" :PaddingX="ScreenScale(2)" :Height="PH" Flex="5">Edit</XPanel>
                    <XPanel Cursor="hand" :PaddingX="ScreenScale(2)" :Height="PH" Flex="5">View</XPanel>
                    <XPanel Cursor="hand" :PaddingX="ScreenScale(2)" :Height="PH" Flex="5">Help</XPanel>
                </XPanel>

                <XPanel :MarginRight="ScreenScale(22.5)" :Gap="ScreenScale(1)">
                    <XPanel :Background="Color(3, 159, 244, 192)" :Padding="ScreenScale(1)" Flex="5" :Radius="ScreenScale(1)"><XPanel FontWeight="800" :MarginRight="ScreenScale(1)">Ticks:</XPanel>
                    <XLabel :Text="math.Round(1/Tickrate, 0)">
                            <Listen Delay="1" />
                        </XLabel>
                    </XPanel>
                    <XPanel :Background="Color(222, 169, 9, 192)" :Padding="ScreenScale(1)" Flex="5" :Radius="ScreenScale(1)"><XPanel FontWeight="800" :MarginRight="ScreenScale(1)">FPS:</XPanel>
                        <XLabel :Text="math.Round(1/RealFrameTime(), 0)">
                            <Listen Delay="1" />
                        </XLabel>
                    </XPanel>
                    <XPanel :Background="Color(222, 169, 9, 192)" :Padding="ScreenScale(1)" Flex="5" :Radius="ScreenScale(1)"><XPanel FontWeight="800" :MarginRight="ScreenScale(1)">RAM:</XPanel>
                        <XLabel :Text="math.Round(collectgarbage('count')/1000, 0)">
                            <Listen Delay="1" />
                        </XLabel> MB
                    </XPanel>
                </XPanel>
            </XPanel>

            <XPanel Ref="Body" Grow="true" :Background="Color(0, 0, 0, 128)">
                <XPanel :Width="PW * 0.33" :Height="PH" Direction="Y">
                    <XPanel :Padding="ScreenScale(2)">
                        <XPanel Direction = "Y">
                            <XPanel Direction="Y">
                                <XPanel FontWeight="800">- Files</XPanel>
                                <XPanel :MarginLeft="ScreenScale(3)" Direction = "Y">
                                    <XPanel Direction="Y">
                                        <XPanel FontWeight="800">- /interface</XPanel>
                                        <XPanel :MarginLeft="ScreenScale(3)" Direction="Y">
                                            <XPanel>background.png</XPanel>
                                            <XPanel>button.png</XPanel>
                                            <XPanel>button_down.png</XPanel>
                                            <XPanel>button_hover.png</XPanel>
                                        </XPanel>
                                    </XPanel>

                                    <XPanel Direction="Y">
                                        <XPanel FontWeight="800">- /types</XPanel>
                                        <XPanel :MarginLeft="ScreenScale(3)" Direction="Y">
                                            <XPanel>background.png</XPanel>
                                            <XPanel>button.png</XPanel>
                                            <XPanel>button_down.png</XPanel>
                                            <XPanel>button_hover.png</XPanel>
                                        </XPanel>
                                    </XPanel>

                                    <XPanel>shared.lua</XPanel>
                                    <XPanel>cl_init.lua</XPanel>
                                    <XPanel>init.lua</XPanel>
                                </XPanel>
                            </XPanel>
                        </XPanel>
                    </XPanel>
                </XPanel>

                <XPanel Grow="true" Direction="Y">
                    <XPanel Grow="true">
                        Content
                    </XPanel>
                    <XPanel :Height="PH * 0.2">
                        Bottom
                    </XPanel>
                </XPanel>

                <XPanel :Width="PW * 0.2" :Height="PH" Direction="Y">
                    RightBar
                </XPanel>
            </XPanel>
        </XPanel>
    ]])

    local last = SysTime()
    XVGUI:SetProperty("Tickrate", 0)
    hook.Add("Tick", XVGUI, function ()
        XVGUI:SetProperty("Tickrate", SysTime() - last)
        last = SysTime()
    end)

    XVGUI:MakePopup()
end)
gameevent.Listen("player_activate")
gameevent.Listen("player_disconnect")
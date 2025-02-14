AddCSLuaFile()

Interface = {}

include("2d_v2/base.lua")
include("2d_v2/fonts.lua")
include("2d_v2/gradients.lua")
include("2d_v2/vgui.lua")
include("2d_v2/gradients.lua")
include("2d_v2/rect.lua")
include("2d_v2/xml.lua")

if SERVER then
    return
end


if IsValid(p) then
    p:Remove()
end
p = Interface.CreateFromXML(nil, [[
    <Panel On:Child:Click="function (el, ...)
        print(el, ...) 
    end">
        <Panel Ref="Child" />
    </Panel>
]])

--[[
    PANEL - as a type of Interface
]]

--[[
    Sizing & child evaluation
        XUnit
        YUnit
        WidthUnit
        HeightUnit
        GapUnit
        PaddingLeftUnit
        PaddingRightUnit
        PaddingTopUnit
        PaddingBottomUnit
        etc.
    Align
    Padding
    Margin
    Gap
    Grow
    Stencils
    Background

    <Rect>
        <Paint:Stencil>
            <Poly Origin="0.5w 0.5h">
                0w, 0h, color
                1w - 15ss, 0h, color
                1w, 1h, color
                0w, 1h, color
            </Poly>
        </Paint:Stencil>

        <Paint:Fill>
            <Stencil>
                <Rect />
                <Gradient />
            </Stencil>
        </Paint:Fill>

        <Paint:Stroke>
        </Paint:Stroke>        
    </Rect>

    <Rect>
        <Rect Flow="Down" Padding="1">
            <!-- Top bar -->
            <Rect Width="100%" Height="5">
                <Image Source="sstrp/ui/window_top_left.png" Width="5" Height="100%" />
                <Image Source="sstrp/ui/window_top.png" Grow="true" Height="100%" RepeatX="true" />
                <Image Source="sstrp/ui/window_top_right.png" Width="5" Height="100%" />
            </Rect>

            <Rect Width="100%" Padding="2" Flow="Down">

                <!-- Content -->
                <Rect Width="100%" Gap="2">
                    <Rect><Text :Value="Title" /></Rect>>
                    <Image Grow="true" Height="100%" Source="sstrp/ui/window_hazard.png" RepeatX="true" />
                </Rect>
                
                <!-- Horizontal rule -->
                <Rect Width="100%">
                    <Rect>
                        <Paint:Fill>
                            <Gradient Type="Radial" From="0, 0, 0, 0" To="0, 0, 0, 255" />
                        </Paint:Fill>
                    </Rect>
                </Rect>
            </Rect>
        </Rect>
    </Rect>

]]
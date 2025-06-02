--[[
    Interface V3 spec
    1. Interface elements virtually wrap a panel.
    2. Interface elements can be nested.
    3. Interface elements can be created via XML.
      a. Attributes are read in the order in which they are specified
      b. Attributes can be cast. 
        String: 
        Number: 
        etc.
    4. Attributes can be types.
    5. Attributes can be animated kinematically.
    6. Interface elements wrap Set and Get functions.
]]


Interface = {}

function Interface.Create(class, parent)
    local obj = Type.New(class)
    obj:SetParent(parent)
    return obj
end

function Interface.Register(name, base, options)
    base = base or Type.VirtualPanel
    return Type.Register(name, base, options)
end

local VGUIToInterface = {}
function Interface.RegisterFromVGUI(control)
    local t = VGUIToInterface[control]
    if t then
        return t
    end

    local v = vgui.GetControlTable(control)
    t = Type.Register(control, VirtualPanel, { VGUI = control })
    for k, f in pairs(v) do
        if string.StartsWith(k, "Set") then
            k = string.sub(k, 4)
            t:CreateProperty(k, Type.Any, { Set = f, Get = v["Get" .. k] })
        end
    end
    return t
end

include("2d_v3/fonts.lua")
include("2d_v3/draw.lua")
include("2d_v3/panel.lua")
include("2d_v3/for.lua")
include("2d_v3/label.lua")
include("2d_v3/popover.lua")
include("2d_v3/xml.lua")
include("2d_v3/scroll.lua")
include("2d_v3/window.lua")
include("2d_v3/textentry.lua")
include("2d_v3/button.lua")
include("2d_v3/checkbox.lua")
include("2d_v3/radio.lua")
include("2d_v3/picklist.lua")
include("2d_v3/slider.lua")
include("2d_v3/section.lua")

if not CLIENT then
    return
end

-- <Element>
-- <For>
-- <Slot> and Slot=""
-- Bind:Prop="Proxy"
-- <Listen />
-- Labels
-- <Stencil> <Poly>
-- Transitions?
-- Mutex
-- Stroke, Radius, Shadow, Glow
-- Events

-- Use promises for events
-- Net.Receive, trigger a promise?

-- Symphony
  -- Console
  -- Performance
  -- Database (Object and Record Explorer)
  -- Hooks
  -- Objects
  -- Interface
  -- Worlds
  -- Settings
  -- Quests
    -- Settings
    -- Worlds
      -- Entities




      

if IsValid(pan) then
    if IsValid(pan.Ent) then
        pan.Ent:Remove()
    end

    pan:Dispose()
end


function PrintReturn(msg, f)
    print(msg)
    return f
end

-- Absolute:
-- Flex

-- Y, 9, PR=50 causes a 50 pixel PB?

pan = Interface.CreateFromXML(nil, [[
    <Rect Absolute="true" X="0" Y="0" Width="100%" Height="100%" Fill="white" Init:Material="Material('sstrp25/ui/backdrops/backdrop2.png')">
        <Window Name="Window" X="1%" Y="1%" Width="98%" Height="98%">
            <Rect Name="Body" Width="100%" Height="100%" PaddingTop="15ss">
                <Rect Width="15%" Height="100%" Flow="Y">
                    <Rect Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="Color(0, 0, 0, 192)" :FontColor="Color(255, 255, 255, 255)">
                        Name & description
                    </Rect>
                    
                    <Rect Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Backstory
                    </Rect>
                    
                    <Rect Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Relationships
                    </Rect>

                    <Rect MarginTop="4ss" Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Appearance
                    </Rect>

                    
                    <Rect Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Clothing & apparel
                    </Rect>

                    <Rect MarginTop="4ss" Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Traits
                    </Rect>                    
                    
                    <Rect Padding="4ss" Hover="true" Cursor="hand" Width="90%" :Fill="IsHovered and Color(0, 0, 0, 192) or Color(0, 0, 0, 96)" :FontColor="IsHovered and Color(255, 255, 255, 255) or Color(255, 255, 255, 96)">
                        Equipment
                    </Rect>
                </Rect>

                <Rect Width="Fill" Height="100%" Flow="Y" Padding="5ss, 0ss, 5ss, 5ss" Gap="2ch">
                    <Rect Flow="Y">
                        <Text FontSize="10" Content="Create a new character" />
                        <Text FontSize="18" FontWeight="800" Content="Set your character's name, age & description" />
                    </Rect>
                    
                    <Rect Gap="0.2ch" Width="100%" Name="CharName" Flow="Y">
                        <Text FontWeight="800" Content="1. Character name" />
                        <Text Width="100%" FontColor="Color(192, 192, 192, 255)" Content="What's your character called?" />
                        <TextEntry Width="100%" Placeholder="Joe Bloggs" />
                    </Rect>

                    <Rect Gap="0.2ch" Width="100%" Name="CharDOB" Flow="Y" Gap="0.4ch">
                        <Text FontWeight="800" Content="2. Date of Birth" />
                        <Text Width="100%" FontColor="Color(192, 192, 192, 255)" Content="How old your character is. Don't worry about the year - we'll calculate that automatically for you based on what age you select." />

                        <Rect Flow="X" Width="100%" Gap="1ch">
                            <Rect Flow="Y" Gap="0.2ch">
                                <Text Content="Day" />
                                <TextEntry Width="10cw" Placeholder="dd" />
                            </Rect>
                            
                            <Rect Flow="Y" Gap="0.2ch">
                                <Text Content="Month" />
                                <Picklist Width="40cw" Placeholder="January">
                                    <PicklistEntry>January</PicklistEntry>
                                    <PicklistEntry>February</PicklistEntry>
                                    <PicklistEntry>March</PicklistEntry>
                                    <PicklistEntry>April</PicklistEntry>
                                    <PicklistEntry>May</PicklistEntry>
                                    <PicklistEntry>June</PicklistEntry>
                                    <PicklistEntry>July</PicklistEntry>
                                    <PicklistEntry>August</PicklistEntry>
                                    <PicklistEntry>September</PicklistEntry>
                                    <PicklistEntry>October</PicklistEntry>
                                    <PicklistEntry>November</PicklistEntry>
                                    <PicklistEntry>December</PicklistEntry>
                                </Picklist>                                
                            </Rect>
                            
                            
                            <Rect Flow="Y" Gap="0.2ch" MarginLeft="10cw">
                                <Text Content="Age" />     
                                <Rect Align="4" Flow="X" Gap="3cw"><TextEntry Width="10cw" Placeholder="18" /> years old</Rect>                          
                            </Rect>
                        </Rect>
                    </Rect>

                    <Rect Gap="0.2ch" Width="100%" Name="CharDesc" Flow="Y">
                        <Text FontWeight="800" Content="3. Description of how you sound and appear to others" />
                        <Text Width="100%" FontColor="Color(192, 192, 192, 255)" Content="This will appear under your nametag and in the chatbox if someone doesn't recognise you. You should use it to describe things like how tall you are, any distinct visual features like tattoos or scars, any accents, etc." />
                        <TextEntry Width="100%" Height="10ch" Multiline="true" />
                    </Rect>

                    <Rect Width="100%" Height="Fill" Align="3" PaddingBottom="15ss">
                        <Rect Align="6" Gap="8ss">
                            <Button FontSize="14">Continue</Button>
                        </Rect>
                    </Rect>
                </Rect>

                <Rect Name="Character" Width="44%" Height="100%">
                
                </Rect>
            </Rect>
        </Window>
    </Rect>
]])
pan:InvalidateLayout()


local clientsideEnt = ClientsideModel("models/Humans/Group01/male_02.mdl")
pan.Ent = clientsideEnt
pan.Ent:SetSequence("idle_all_01")

function pan.Window._Default.Body.Character:Paint(w, h)

    local x, y = self:GetPanel():LocalToScreen(0, 0)
    cam.Start3D(Vector(50, 0, 50), Angle(0, 180, 0), 60, x, y, w, h)
        clientsideEnt:DrawModel()
    cam.End3D()
end

function pan.Window:OnClose()
    pan:Dispose()
end

-- Radio
-- Checkbox
-- Scrolls
-- Colorpicker

timer.Create("0.25Hz", 4, 0, function()
    hook.Run("0.25Hz")
end)

timer.Create("0.5Hz", 2, 0, function()
    hook.Run("0.5Hz")
end)

timer.Create("1Hz", 1, 0, function()
    hook.Run("1Hz")
end)

timer.Create("2Hz", 0.5, 0, function()
    hook.Run("2Hz")
end)

timer.Create("4Hz", 0.25, 0, function()
    hook.Run("4Hz")
end)

timer.Create("8Hz", 0.125, 0, function()
    hook.Run("8Hz")
end)


-- Repeaters
-- Stencils
-- Blur
-- Labels
-- Make sure VGUI works

-- Make sure


-- Bind
-- RoundedBox

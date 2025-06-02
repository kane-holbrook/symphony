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
include("2d_v3/xml.lua")
include("2d_v3/window.lua")
include("2d_v3/textentry.lua")

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
    <Window X="25%" Y="25%" Width="50%" Height="50%">
        <TextEntry Name="TextEntry" Placeholder="Test" Width="50%" />
    </Window>
    
]])
pan:InvalidateLayout()

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

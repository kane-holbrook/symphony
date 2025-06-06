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
Theme = {}

local ThemeObj = Type.Register("Theme")
ThemeObj.Label = "Symphony"
ThemeObj.Controls = {}

function Theme.Register(label, base)
    base = base or ThemeObj
    assert(base)
    local t = Type.Register("Theme<" .. label .. ">", base)
    t.Label = label
    t.Controls = setmetatable({}, {
        __index = base and base.Controls
    })

    Theme[label] = t
    return t
end

function Theme.Get(label)
    return Theme[label]
end

function ThemeObj:New(id)
    assert("Attempt to instantiate Theme, which is a static class.")
end

function ThemeObj:Register(name, base, options)
    local baseObj = base and self.Controls[base] or self.Controls.Rect
    assert(baseObj, "Base control '" .. tostring(base) .. "' not found in theme '" .. self.Label .. "'.")

    local t = Type.Register("UI<" .. self.Name .. ">[" .. name .. "]", baseObj, options)
    t.Theme = self
    self.Controls[name] = t
    return t
end
Theme.Symphony = ThemeObj
Theme.Default = ThemeObj

function ThemeObj:Create(name, parent)
    local control = isstring(name) and self.Controls[name] or name
    assert(control, "Control '" .. tostring(name) .. "' not found in theme '" .. self.Label .. "'.")

    local obj = Type.New(control)
    obj:SetParent(parent)
    return obj
end

function ThemeObj:GetControls()
    return self.Controls
end

function ThemeObj:GetControl(name)
    return self.Controls[name]
end

include("symphony/fonts.lua")
include("symphony/draw.lua")
include("symphony/rect.lua")

include("symphony/for.lua")
include("symphony/label.lua")
include("symphony/popover.lua")
include("symphony/xml.lua")
include("symphony/scroll.lua")
include("symphony/window.lua")
include("symphony/textentry.lua")
include("symphony/button.lua")
include("symphony/checkbox.lua")
include("symphony/radio.lua")
include("symphony/picklist.lua")
include("symphony/slider.lua")
include("symphony/section.lua")

if not CLIENT then
    return
end

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

pan = Theme.Default:CreateFromXML(nil, [[
    <Window Title="Symphony Console" X="25%" Y="25%" Width="50%" Height="50%">
        <Scroll Width="100%" Height="100%">
            <Rect Width="100%" Gap="5ss" Flow="Y">
                <TextEntry Name="TextEntry" Placeholder="TextEntry" Width="50%" />
                <Rect Flow="X" Gap="5ss">
                    <Button>Primary</Button>
                    <Button Init:Color="_G.Color(32, 32, 32, 254)">Secondary</Button>
                </Rect>
                <Picklist :DisplayValue="IsEntity(Value) and Value:Name() or ''">
                    <For Each="_, ply in pairs(tablex.SortByMemberEx(player.GetAll(), 'Name', true))" Width="100%" Flow="Y">
                        <PicklistEntry :Value="ply"><Label :Text="ply:Name()" /></PicklistEntry>
                    </For>
                </Picklist>
                <Slider Value="0.5" />
                <Rect Init:Value="{ ABC = true, DEF = true }" On:MousePressed="function (src)
                    local val = src.Value
                    if val then
                        self.Value[val] = not self.Value[val]
                        self:InvalidateLayout()
                        return true
                    end
                end" Gap="10ss">
                    <Checkbox Propagate="true" Value="ABC">ABC</Checkbox>
                    <Checkbox Propagate="true" Value="DEF">DEF</Checkbox>
                </Rect>

                <Rect Flow="Y" Gap="0.3ch" Init:Value="'Test3'" On:MousePressed="function (src)
                    if src:GetProperty('Value') then
                        self:SetProperty('Value', src:GetProperty('Value'))
                        self:InvalidateLayout()
                    end
                    return true
                end">
                    <Radio>Test</Radio>
                    <Radio>Test2</Radio>
                    <Radio>Test3</Radio>
                </Rect>
            </Rect>
        </Scroll>
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
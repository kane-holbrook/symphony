AddCSLuaFile()

if SERVER then
    return
end

local uix = Type.Register("uix")
function uix.Parse(p)
    
end

local uiy = Type.Register("uiy", uix)
-- auto, 2ss, 3ssh, 3, 3px, 50%, 100vh, 100vw


local t = Type.Register("Rect", nil)
t:CreateProperty("Ref", Type.String) -- Reference
t:CreateProperty("Parent") -- Parent element
t:CreateProperty("ZIndex", Type.Number) -- Display order
t:CreateProperty("X", Type.Number) -- X
t:CreateProperty("Y", Type.Number) -- Y
t:CreateProperty("Width", Type.Number) -- Width
t:CreateProperty("Height", Type.Number) -- Height
t:CreateProperty("Display", Type.Boolean) -- Display or hide element
t:CreateProperty("Absolute", Type.Boolean) -- Absolute positioning, ignoring parent layout

t:CreateProperty("Background") -- Draw color or material
t:CreateProperty("Blur") -- Draw pp/blur behind element
t:CreateProperty("Mask") -- Stencil
t:CreateProperty("BoxShadow") -- Probably just draw the mask behind it?
t:CreateProperty("BoxShadowColor")
t:CreateProperty("BorderLeft") -- Color or material?
t:CreateProperty("BorderLeftSize")
t:CreateProperty("BorderTop")
t:CreateProperty("BorderTopSize")
t:CreateProperty("BorderRight")
t:CreateProperty("BorderRightSize")
t:CreateProperty("BorderBottom")
t:CreateProperty("BorderBottomSize")
t:CreateProperty("BorderTopLeftRadius")
t:CreateProperty("BorderTopRightRadius")
t:CreateProperty("BorderBottomRightRadius")
t:CreateProperty("BorderBottomLeftRadius")
-- Border: Set all borders at once
-- BorderSize: Similar

t:CreateProperty("Alignment") -- Numpad key, think Flex
t:CreateProperty("Gap") -- Gap between children
t:CreateProperty("Grow") -- Whether a child should grow to fill the space
t:CreateProperty("Shrink") -- Whether a child should shrink to fit the space
t:CreateProperty("Wrap") -- Wrap children to the next line

-- For labels
-- t:CreateProperty("Text")
-- t:CreateProperty("Color")
-- t:CreateProperty("Truncate")

t:CreateProperty("MarginLeft")
t:CreateProperty("MarginTop")
t:CreateProperty("MarginRight")
t:CreateProperty("MarginBottom")

t:CreateProperty("PaddingLeft")
t:CreateProperty("PaddingTop")
t:CreateProperty("PaddingRight")
t:CreateProperty("PaddingBottom")

t:CreateProperty("Font")
t:CreateProperty("FontSize")
t:CreateProperty("FontWeight")

t:CreateProperty("Alpha")
t:CreateProperty("Matrix") -- Amends the position, rotation, scale, etc. of the element
t:CreateProperty("Cursor")

t:CreateProperty("Rotate")
t:CreateProperty("Stretch")
t:CreateProperty("Skew")
t:CreateProperty("Scale")

-- Events
t:CreateProperty("On:Think")
t:CreateProperty("On:Click")
t:CreateProperty("On:ContextMenu") -- Right click
t:CreateProperty("On:Scroll")
t:CreateProperty("On:Move")
t:CreateProperty("On:Resize")
t:CreateProperty("On:Hover")
t:CreateProperty("On:HoverFinish")
t:CreateProperty("On:Drag")
t:CreateProperty("On:DragOver")
t:CreateProperty("On:DraggedOver")
t:CreateProperty("On:Drop")
t:CreateProperty("On:DroppedOn")
t:CreateProperty("On:ChildAdded")
t:CreateProperty("On:ChildRemoved")

-- Selectors
-- :Property - The following property is a Lua function
-- Hover:Property="value" - When the panel is hovered over, property is set to value
-- Set:Field="value" - Manually set a field to a value
-- On:Name - Run the following function when an event is emitted.
-- Transition:Property="true, math.ease.Linear, 0.5" - When the property changes, animate it over 0.5 seconds using a linear easing function.

-- First foray into shaders - a simple shader to draw a gradient?

-- Properties for panels need - 
-- 1. A CalculatedValue parameter, which points to a function
-- 2. RecalculateOn - a table of events that should trigger a recalculation
-- 3. Validation
-- 4. LastCalculated timestamp

--t:CreateProperty("OverflowX") -> scroll.lua
--t:CreateProperty("OverflowY") -> scroll.lua

-- t.Prototype:WillOverflow() -> If all of the children are larger than the bounds, return true and a list of elements
-- Transitions



function t.Prototype:Initialize()
    self.Children = {}
    self:SetBackground(color_transparent)
end

function t.Prototype:Paint(w, h)
    local x, y = self:GetX(), self:GetY()

    local m = Matrix()
    m:Translate(Vector(x, y))
    cam.PushModelMatrix(m)

        local bg = self:GetBackground()
        if IsColor(bg) then
            surface.SetDrawColor(bg)
            surface.DrawRect(0, 0, w, h)
        else
            surface.SetDrawColor(color_white)
            surface.SetMaterial(bg)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        for k, v in pairs(self.Children) do
            v:Paint(v:GetWidth(), v:GetHeight())
        end

    cam.PopModelMatrix()
end

function t.Prototype:Add(type)
    local c = new(type)
    c:SetParent(self)
    return c
end

function t.Prototype:OnPropertyChanged(name, value, old)
    if name == "Parent" then
        if old then
            old.Children[self:GetZIndex()] = nil
        end

        if value then
            self:SetZIndex(table.insert(value.Children, self))
        end
    end
end

function t.Prototype:PerformLayout(w, h)
end
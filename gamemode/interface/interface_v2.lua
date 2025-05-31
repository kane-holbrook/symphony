AddCSLuaFile()

Interface = {}

include("2d_v2/fonts.lua")
include("2d_v2/vgui.lua")
include("2d_v2/base.lua")
include("2d_v2/xml.lua")
include("2d_v2/gradients.lua")
include("2d_v2/label.lua")
include("2d_v2/window.lua")
include("2d_v2/checkbox.lua")

if SERVER then
    return
end


if IsValid(p) then
    p:Remove()
end

p = Interface.Create("Rect")
p:SetRef("Top")
p:SetX("0.25pw")
p:SetY("0.25ph")
p:SetWidth("0.5pw")
p:SetHeight("0.5ph")
p:SetFillColor(color_black)
p:SetAlign(5)
TP = p

local lp = p
--[[for i=1, 15 do
    lp = Interface.Create("Rect", lp)
    lp:SetPaddingLeft("5ss")
    lp:SetPaddingRight("5ss")
    lp:SetPaddingBottom("5ss")
    lp:SetPaddingTop("5ss")
    lp:SetAlign(5)
    lp:SetFillColor(ColorAlpha(VectorRand(0, 255), 255))
end--]]

lp = Interface.Create("Rect", lp)
lp:SetRef("Mid")
lp:SetAlign(5)
lp:SetFillColor(ColorAlpha(VectorRand(0, 255), 255))
MID = lp

lp = Interface.Create("Rect", lp)
lp:SetRef("Bottom")
lp:SetWidth("15ss")
lp:SetHeight("15ss")
lp:SetFillColor(ColorAlpha(VectorRand(0, 255), 255))

BTM = lp

-- When a parent has its size changed, iterate through the children to see if any have computed X/Y/W/H. If so, schedule a layout. LayoutWhenParentChanged.
-- When a child has its size changed, check the immediate parent to see if it sizes to children. If so, layout the parent.

--[[

    <Rect>
        <Animate Property="Position" Repeat="true">
            <KeyFrame Time="0" Property="X" Value="0" />
            <KeyFrame Time="3" Property="X" Value="100" />
        </Animate>
    </Rect>
]]
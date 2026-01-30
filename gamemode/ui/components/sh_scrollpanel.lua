
AddCSLuaFile()

if SERVER then
    return
end

local PANEL = vguix.RegisterFromXML("Scroll", [[
    <Rect Name="Component" Width="100%" Height="100%" Align="false">
        <Rect Absolute="true" X="0" :Y="-ScrollPos" Name="Content" Flow="Y" Align="7" :Width="Parent.Width - 16">
        </Rect>

        <Rect Name="Bar" Width="8" Height="100%" Absolute="true" :X="Parent.Width - Width" Y="0" MarginLeft="16" Hover="true" Cursor="hand" :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)" Fill="Color(255, 255, 255, 16)">
            <Rect Name="Handle" Absolute="true" Hover="true" Cursor="hand" Func:LeftClick="function () return self:InvokeParent('ClickHandle') end" :Height="math.min(Parent.Height, Parent.Height * (Component:GetTall() / Component.Content:GetTall()))" Width="100%" :Shape="RoundedBox(Width, Height, 4, 4, 4, 4)" :Fill="IsHovered and Color(255, 255, 255, 192) or Color(255, 255, 255, 64)"
            :Y="math.Remap(
                ScrollPos,
                0,
                (Component.Content:GetTall() - Component:GetTall()),
                0,
                (Parent.Height - Height)
        )">
            </Rect>
        </Rect>
    </Rect>
]])
vguix.AccessorFunc(PANEL, "ScrollPos", "ScrollPos", "Number")

function PANEL:Init()
    self:SetScrollPos(0)
end

function PANEL:ClickHandle()
    if self.Content:GetTall() <= self:GetTall() then
        return
    end

    -- how far down in the handle we clicked (0 -> Handle.Height)
    local _, clickOffsetY = self.Bar.Handle:ScreenToLocal(gui.MouseX(), gui.MouseY())

    hook.Add("Think", self, function()
        if not input.IsMouseDown(MOUSE_LEFT) then
            hook.Remove("Think", self)
            return
        end

        -- mouse pos in bar-coordinates
        local _, mouseY = self.Bar:ScreenToLocal(gui.MouseX(), gui.MouseY())

        -- compute the new top-of-handle (0 -> trackLength)
        local handleTop = mouseY - clickOffsetY
        local trackLength = self.Bar:GetTall() - self.Bar.Handle:GetTall()
        handleTop = math.Clamp(handleTop, 0, trackLength)

        -- fraction along track, then remap to scroll-range
        local frac = handleTop / trackLength
        local maxScroll = self.Content:GetTall() - self:GetTall()
        local newScroll = math.Round( math.Remap(frac, 0, 1, 0, maxScroll), 0 )

        -- apply it
        self:SetScrollPos(newScroll)
        self.Content:SetY(-newScroll)
        self.Bar:InvalidateChildren(true)
    end)

    return true
end

function PANEL:OnMouseWheeled(delta)
    if self.Content:GetTall() <= self:GetTall() then
        return
    end

    local newScrollPos = self:GetScrollPos() - delta * 20
    newScrollPos = math.Clamp(newScrollPos, 0, self.Content:GetTall() - self:GetTall())
    self:SetScrollPos(newScrollPos)
    self.Content:SetY(-newScrollPos)
    self.Bar:InvalidateChildren(true)
end

function PANEL:OnChildAdded(child)
    if self.Initialized then
        child:SetParent(self.Content)
    end
end
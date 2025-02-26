AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("Scroll", [[
    <Rect 
        Ref="Scroll"
        Grow="true"
        Gap="4ss"
        Flex="6"
    >
        <Rect Ref="Content" Absolute="true" Slot="Default" :Width="PW - ScreenScale(6)"> 
        </Rect>

        <Rect PaddingTop="1.5ss" PaddingBottom="1.5ss" Width="2ss" Height="1ph" Radius="1ss" FillColor="Color(255, 255, 255, 16)">
            <Rect Ref="Scrollbar" Grow="true">
                <Rect Ref="Handle" Absolute="true" X="0" Y="0" Width="1pw" Cursor="hand" FillColor="Color(255, 255, 255, 128)" Hover="true" Hover:FillColor="Color(255, 255, 255, 255)" />
            </Rect>
        </Rect>
        
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()

    function self.Scrollbar.Handle.OnMousePressed(el, w, h)
        local ax, ay = el:ScreenToLocal(gui.MousePos())

        hook.Add("Think", self, function ()
            if not input.IsMouseDown(MOUSE_LEFT) then
                hook.Remove("Think", self)
                return
            end

            local x, y = self.Scrollbar:ScreenToLocal(gui.MousePos())
            y = y - ay

            y = math.Clamp(y, 0, self.Scrollbar:GetTall() - el:GetTall())

            self.Content:SetY(-(y/self.Scrollbar:GetTall() * self.Content:GetTall()))
            el:SetY(y)
        end)
    end

    function self.Scrollbar.Handle.PerformLayout(el, w, h)

        local sh = self.Content:GetTall()
        local ch = self:GetTall()

        local h = ch / sh * ch
        el:SetHeight(h)

        el:SetY(-self.Content:GetY() / sh * ch)
    end
end

function PANEL:OnMouseWheeled(delta)
    local y = math.Clamp(self.Content:GetY() + delta * 10, -self.Content:GetTall() + self:GetTall(), 0)
    self.Content:SetY(y)
    self.Scrollbar.Handle:InvalidateLayout()
end

function PANEL:ClickHandle(el)
    
end